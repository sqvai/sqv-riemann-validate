use std::env;
use std::fs::{self, File};
use std::io::{self, Read};
use std::path::{Path, PathBuf};
use std::process::{Command, Output};
use std::time::{SystemTime, UNIX_EPOCH};

fn usage() -> ! {
    eprintln!(
        "rh-audit\n\n\
         Commands:\n\
           scan-lean <path>\n\
           generate-axiom-audit <upstream-dir> <out.lean>\n\
           verify-axioms <stdout.log> [required_theorem...]\n\
           run-command <receipt-dir> <gate> <workdir> <program> [args...]\n\
           status <receipt-dir>\n"
    );
    std::process::exit(2);
}

fn json_escape(s: &str) -> String {
    let mut out = String::with_capacity(s.len() + 8);
    for c in s.chars() {
        match c {
            '"' => out.push_str("\\\""),
            '\\' => out.push_str("\\\\"),
            '\n' => out.push_str("\\n"),
            '\r' => out.push_str("\\r"),
            '\t' => out.push_str("\\t"),
            c if c.is_control() => out.push_str(&format!("\\u{:04x}", c as u32)),
            c => out.push(c),
        }
    }
    out
}

fn unix_now() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs()
}

fn output_text(output: &Output) -> (String, String) {
    (
        String::from_utf8_lossy(&output.stdout).to_string(),
        String::from_utf8_lossy(&output.stderr).to_string(),
    )
}

fn command_text(workdir: &Path, program: &str, args: &[String]) -> String {
    let output = Command::new(program)
        .args(args)
        .current_dir(workdir)
        .output();
    match output {
        Ok(o) if o.status.success() => String::from_utf8_lossy(&o.stdout).trim().to_string(),
        _ => String::new(),
    }
}

fn sha256(path: &Path) -> String {
    if !path.exists() {
        return String::new();
    }
    let output = Command::new("sha256sum").arg(path).output();
    match output {
        Ok(o) if o.status.success() => String::from_utf8_lossy(&o.stdout)
            .split_whitespace()
            .next()
            .unwrap_or("")
            .to_string(),
        _ => String::new(),
    }
}

fn collect_lean_files(root: &Path, files: &mut Vec<PathBuf>) -> io::Result<()> {
    if root.is_file() {
        if root.extension().and_then(|x| x.to_str()) == Some("lean") {
            files.push(root.to_path_buf());
        }
        return Ok(());
    }
    for entry in fs::read_dir(root)? {
        let path = entry?.path();
        if path.is_dir() {
            if path.file_name().and_then(|x| x.to_str()) == Some(".lake") {
                continue;
            }
            collect_lean_files(&path, files)?;
        } else if path.extension().and_then(|x| x.to_str()) == Some("lean") {
            files.push(path);
        }
    }
    Ok(())
}

fn is_ident_char(c: char) -> bool {
    c.is_alphanumeric() || c == '_' || c == '\'' || c == '.'
}

fn contains_token(line: &str, token: &str) -> bool {
    let mut start = 0;
    while let Some(pos) = line[start..].find(token) {
        let abs_pos = start + pos;
        let before_ok = if abs_pos == 0 {
            true
        } else {
            let prev = line[..abs_pos].chars().next_back().unwrap();
            !is_ident_char(prev)
        };
        let after_pos = abs_pos + token.len();
        let after_ok = if after_pos >= line.len() {
            true
        } else {
            let next = line[after_pos..].chars().next().unwrap();
            !is_ident_char(next)
        };
        if before_ok && after_ok {
            return true;
        }
        start = abs_pos + token.len();
    }
    false
}

fn classify(path: &Path) -> &'static str {
    let s = path.to_string_lossy();
    if s.contains("SQV_") {
        "AUDIT_HARNESS"
    } else if s.contains("ComparatorChallenges") {
        "REFERENCE_CHALLENGE"
    } else if s.contains("test") || s.contains("Test") {
        "TEST"
    } else if s.contains(".lake") {
        "DEPENDENCY"
    } else {
        "PROOF_SOURCE"
    }
}

fn scan_lean(root: &Path) -> io::Result<i32> {
    let patterns = [
        "sorry",
        "admit",
        "axiom",
        "unsafe",
        "implemented_by",
        "native_decide",
        "ofReduceBool",
    ];
    let mut files = Vec::new();
    collect_lean_files(root, &mut files)?;
    files.sort();
    let mut proof_hits = 0usize;
    println!("class\tpath\tline\tpattern\ttext");
    for path in files {
        let mut text = String::new();
        File::open(&path)?.read_to_string(&mut text)?;
        let mut comment_depth = 0usize;
        let mut in_string = false;
        let mut escaped = false;
        for (idx, raw_line) in text.lines().enumerate() {
            let mut active_code = String::new();
            let chars: Vec<char> = raw_line.chars().collect();
            let mut i = 0;

            while i < chars.len() {
                if comment_depth > 0 {
                    if i + 1 < chars.len() && chars[i] == '-' && chars[i + 1] == '/' {
                        comment_depth -= 1;
                        i += 2;
                    } else if i + 1 < chars.len() && chars[i] == '/' && chars[i + 1] == '-' {
                        comment_depth += 1;
                        i += 2;
                    } else {
                        i += 1;
                    }
                    continue;
                }

                if in_string {
                    if escaped {
                        escaped = false;
                        i += 1;
                    } else if chars[i] == '\\' {
                        escaped = true;
                        i += 1;
                    } else if chars[i] == '"' {
                        in_string = false;
                        i += 1;
                    } else {
                        i += 1;
                    }
                    continue;
                }

                if i + 1 < chars.len() && chars[i] == '-' && chars[i + 1] == '-' {
                    break;
                }

                if i + 1 < chars.len() && chars[i] == '/' && chars[i + 1] == '-' {
                    comment_depth += 1;
                    i += 2;
                    continue;
                }

                if chars[i] == '"' {
                    in_string = true;
                    escaped = false;
                    i += 1;
                    continue;
                }

                active_code.push(chars[i]);
                i += 1;
            }

            if active_code.is_empty() {
                continue;
            }

            for &pattern in &patterns {
                if contains_token(&active_code, pattern) {
                    let class = classify(&path);
                    if class == "PROOF_SOURCE" {
                        proof_hits += 1;
                    }
                    println!(
                        "{}\t{}\t{}\t{}\t{}",
                        class,
                        path.display(),
                        idx + 1,
                        pattern,
                        raw_line.trim()
                    );
                }
            }
        }
    }
    eprintln!("proof_source_hits={proof_hits}");
    Ok(if proof_hits == 0 { 0 } else { 1 })
}

fn verify_axioms(stdout_log: &Path, expected_theorems: &[String]) -> io::Result<i32> {
    let content = fs::read_to_string(stdout_log)?;
    let allowed_axioms = ["propext", "Classical.choice", "Quot.sound"];
    let default_theorems = [
        "riemannHypothesis".to_string(),
        "riemannZeta_eq_zero_re".to_string(),
        "LFunction_ne_zero_of_half_lt_re".to_string(),
        "LFunction_eq_zero_re".to_string(),
        "LFunction_eq_zero_re_of_isPrimitive".to_string(),
    ];
    let required_theorems: &[String] = if expected_theorems.is_empty() {
        &default_theorems
    } else {
        expected_theorems
    };

    let mut found_theorems = Vec::new();
    let mut unapproved_findings = Vec::new();

    for line in content.lines() {
        if let Some(rest) = line.strip_prefix('\'') {
            if let Some(quote_end) = rest.find('\'') {
                let theorem = &rest[..quote_end];
                let after_quote = &rest[quote_end + 1..];
                if let Some(idx) = after_quote.find("depends on axioms: [") {
                    let axioms_str = &after_quote[idx + "depends on axioms: [".len()..];
                    if let Some(end_bracket) = axioms_str.find(']') {
                        let list = axioms_str[..end_bracket].trim();
                        let axioms: Vec<&str> = if list.is_empty() {
                            Vec::new()
                        } else {
                            list.split(',').map(|s| s.trim()).collect()
                        };

                        found_theorems.push(theorem.to_string());
                        println!("[INFO] theorem '{}' depends on: {:?}", theorem, axioms);

                        for ax in &axioms {
                            if !allowed_axioms.contains(ax) {
                                unapproved_findings.push((theorem.to_string(), ax.to_string()));
                            }
                        }
                    }
                }
            }
        }
    }

    let mut missing_required = Vec::new();
    for req in required_theorems {
        if !found_theorems.iter().any(|t| t == req) {
            missing_required.push(req.clone());
        }
    }

    if !missing_required.is_empty() {
        eprintln!(
            "[FAIL] missing axiom check for required theorems: {:?}",
            missing_required
        );
        return Ok(1);
    }

    if !unapproved_findings.is_empty() {
        for (thm, ax) in &unapproved_findings {
            eprintln!(
                "[FAIL] unapproved axiom '{}' found in theorem '{}'",
                ax, thm
            );
        }
        return Ok(1);
    }

    println!(
        "[OK] all required theorems depend strictly on allowed axioms: {:?}",
        allowed_axioms
    );
    Ok(0)
}

fn generate_axiom_audit(_upstream: &Path, out: &Path) -> io::Result<()> {
    if let Some(parent) = out.parent() {
        fs::create_dir_all(parent)?;
    }
    let content = r#"import Main

#print axioms riemannHypothesis
#print axioms riemannZeta_eq_zero_re
#print axioms LFunction_ne_zero_of_half_lt_re
#print axioms LFunction_eq_zero_re
#print axioms LFunction_eq_zero_re_of_isPrimitive

#check riemannHypothesis
#check riemannZeta_eq_zero_re
#check LFunction_ne_zero_of_half_lt_re
#check LFunction_eq_zero_re
#check LFunction_eq_zero_re_of_isPrimitive
"#;
    fs::write(out, content)?;
    println!("wrote {}", out.display());
    Ok(())
}

fn run_command(
    receipt_dir: &Path,
    gate: &str,
    workdir: &Path,
    program: &str,
    args: &[String],
) -> io::Result<i32> {
    fs::create_dir_all(receipt_dir)?;
    let evidence_dir = receipt_dir
        .parent()
        .unwrap_or(receipt_dir)
        .join("evidence")
        .join(gate);
    fs::create_dir_all(&evidence_dir)?;

    let started = unix_now();
    let output = Command::new(program)
        .args(args)
        .current_dir(workdir)
        .output()?;
    let ended = unix_now();
    let (stdout, stderr) = output_text(&output);
    fs::write(evidence_dir.join("stdout.log"), &stdout)?;
    fs::write(evidence_dir.join("stderr.log"), &stderr)?;

    let exit_code = output.status.code().unwrap_or(-1);
    let git_sha = command_text(workdir, "git", &["rev-parse".into(), "HEAD".into()]);
    let raw_git_status = command_text(workdir, "git", &["status".into(), "--porcelain".into()]);
    let git_dirty = raw_git_status.lines().any(|line| {
        let trimmed = line.trim_start();
        !trimmed.starts_with("?? evidence/") && !trimmed.starts_with("?? receipts/")
    });
    let lean_toolchain = fs::read_to_string(workdir.join("lean-toolchain"))
        .unwrap_or_default()
        .trim()
        .to_string();
    let manifest_hash = sha256(&workdir.join("lake-manifest.json"));
    let stdout_hash = sha256(&evidence_dir.join("stdout.log"));
    let stderr_hash = sha256(&evidence_dir.join("stderr.log"));
    let status = if exit_code == 0 { "PASS" } else { "FAIL" };
    let command = std::iter::once(program.to_string())
        .chain(args.iter().cloned())
        .collect::<Vec<_>>()
        .join(" ");

    let receipt_path = receipt_dir.join(format!("{}.json", gate));
    let json = format!(
        concat!(
            "{{\n",
            "  \"schema\": \"sqv.math.audit.receipt.v1\",\n",
            "  \"gate\": \"{}\",\n",
            "  \"status\": \"{}\",\n",
            "  \"started_unix\": {},\n",
            "  \"ended_unix\": {},\n",
            "  \"elapsed_seconds\": {},\n",
            "  \"command\": \"{}\",\n",
            "  \"workdir\": \"{}\",\n",
            "  \"exit_code\": {},\n",
            "  \"git_sha\": \"{}\",\n",
            "  \"git_dirty\": {},\n",
            "  \"lean_toolchain\": \"{}\",\n",
            "  \"lake_manifest_sha256\": \"{}\",\n",
            "  \"stdout_sha256\": \"{}\",\n",
            "  \"stderr_sha256\": \"{}\"\n",
            "}}\n"
        ),
        json_escape(gate),
        status,
        started,
        ended,
        ended.saturating_sub(started),
        json_escape(&command),
        json_escape(&workdir.display().to_string()),
        exit_code,
        json_escape(&git_sha),
        if git_dirty { "true" } else { "false" },
        json_escape(&lean_toolchain),
        json_escape(&manifest_hash),
        json_escape(&stdout_hash),
        json_escape(&stderr_hash),
    );
    fs::write(&receipt_path, json)?;
    println!("{} {} -> {}", gate, status, receipt_path.display());
    Ok(if exit_code == 0 { 0 } else { 1 })
}

fn status(receipt_dir: &Path) -> io::Result<i32> {
    if !receipt_dir.exists() {
        println!("no receipts");
        return Ok(0);
    }
    let mut files: Vec<_> = fs::read_dir(receipt_dir)?
        .filter_map(Result::ok)
        .map(|e| e.path())
        .filter(|p| p.extension().and_then(|x| x.to_str()) == Some("json"))
        .collect();
    files.sort();
    for path in files {
        let text = fs::read_to_string(&path)?;
        let gate = extract_json_string(&text, "gate").unwrap_or_else(|| "?".into());
        let state = extract_json_string(&text, "status").unwrap_or_else(|| "?".into());
        println!("{gate}\t{state}\t{}", path.display());
    }
    Ok(0)
}

fn extract_json_string(text: &str, key: &str) -> Option<String> {
    let needle = format!("\"{}\"", key);
    let pos = text.find(&needle)?;
    let rest = &text[pos + needle.len()..];
    let colon = rest.find(':')?;
    let rest = rest[colon + 1..].trim_start();
    if !rest.starts_with('"') {
        return None;
    }
    let rest = &rest[1..];
    let end = rest.find('"')?;
    Some(rest[..end].to_string())
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        usage();
    }
    let rc = match args[1].as_str() {
        "scan-lean" if args.len() == 3 => scan_lean(Path::new(&args[2])).map_err(|e| e.to_string()),
        "generate-axiom-audit" if args.len() == 4 => {
            generate_axiom_audit(Path::new(&args[2]), Path::new(&args[3]))
                .map(|_| 0)
                .map_err(|e| e.to_string())
        }
        "verify-axioms" if args.len() >= 3 => {
            verify_axioms(Path::new(&args[2]), &args[3..]).map_err(|e| e.to_string())
        }
        "run-command" if args.len() >= 7 => run_command(
            Path::new(&args[2]),
            &args[3],
            Path::new(&args[4]),
            &args[5],
            &args[6..],
        )
        .map_err(|e| e.to_string()),
        "status" if args.len() == 3 => status(Path::new(&args[2])).map_err(|e| e.to_string()),
        _ => usage(),
    };
    match rc {
        Ok(code) => std::process::exit(code),
        Err(err) => {
            eprintln!("error: {err}");
            std::process::exit(1);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_contains_token_boundaries() {
        assert!(contains_token("by sorry", "sorry"));
        assert!(contains_token("sorry", "sorry"));
        assert!(!contains_token("sorryAx", "sorry"));
        assert!(!contains_token("my_sorry_helper", "sorry"));

        assert!(contains_token("admit", "admit"));
        assert!(!contains_token("admitted", "admit"));
        assert!(!contains_token("admittedly", "admit"));

        assert!(contains_token("axiom my_ax : Prop", "axiom"));
        assert!(!contains_token("#print axioms foo", "axiom"));
    }

    #[test]
    fn test_verify_axioms_valid() {
        let dir = tempfile_dir("valid_axioms");
        let path = dir.join("stdout.log");
        let content = "\
'riemannHypothesis' depends on axioms: [propext, Classical.choice, Quot.sound]\n\
'riemannZeta_eq_zero_re' depends on axioms: [propext, Classical.choice, Quot.sound]\n\
'LFunction_ne_zero_of_half_lt_re' depends on axioms: [propext, Classical.choice, Quot.sound]\n\
'LFunction_eq_zero_re' depends on axioms: [propext, Classical.choice, Quot.sound]\n\
'LFunction_eq_zero_re_of_isPrimitive' depends on axioms: [propext, Classical.choice, Quot.sound]\n";
        fs::write(&path, content).unwrap();
        let rc = verify_axioms(&path, &[]).unwrap();
        assert_eq!(rc, 0);
        let _ = fs::remove_dir_all(dir);
    }

    #[test]
    fn test_verify_axioms_unapproved() {
        let dir = tempfile_dir("unapproved_axioms");
        let path = dir.join("stdout.log");
        let content = "\
'riemannHypothesis' depends on axioms: [propext, sorryAx]\n\
'riemannZeta_eq_zero_re' depends on axioms: [propext, Quot.sound]\n\
'LFunction_ne_zero_of_half_lt_re' depends on axioms: [propext, Classical.choice, Quot.sound]\n\
'LFunction_eq_zero_re' depends on axioms: [propext, Classical.choice, Quot.sound]\n\
'LFunction_eq_zero_re_of_isPrimitive' depends on axioms: [propext, Classical.choice, Quot.sound]\n";
        fs::write(&path, content).unwrap();
        let rc = verify_axioms(&path, &[]).unwrap();
        assert_eq!(rc, 1);
        let _ = fs::remove_dir_all(dir);
    }

    #[test]
    fn test_verify_axioms_missing_required() {
        let dir = tempfile_dir("missing_axioms");
        let path = dir.join("stdout.log");
        let content = "\
'riemannHypothesis' depends on axioms: [propext, Classical.choice, Quot.sound]\n";
        fs::write(&path, content).unwrap();
        let rc = verify_axioms(&path, &[]).unwrap();
        assert_eq!(rc, 1);
        let _ = fs::remove_dir_all(dir);
    }

    fn tempfile_dir(prefix: &str) -> PathBuf {
        let p = std::env::temp_dir().join(format!("sqv_test_{}_{}", prefix, unix_now()));
        let _ = fs::create_dir_all(&p);
        p
    }
}
