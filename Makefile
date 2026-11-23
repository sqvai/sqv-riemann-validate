.PHONY: build bootstrap v0 v1 v2 v3 v4 machine-gates status fmt test hyperagents-status wave graph-run
build:
	cargo build --release
bootstrap: build
	./scripts/bootstrap.sh
v0: build
	./scripts/v0-repro.sh
v1: build
	./scripts/v1-kernel.sh
v2: build
	./scripts/v2-comparator.sh
v3: build
	./scripts/v3-semantic.sh
v4: build
	./scripts/v4-paper.sh
machine-gates: build
	./scripts/run-machine-gates.sh
status: build
	./scripts/status.sh
hyperagents-status:
	UAIR_FORGE_WORKSPACE="$(CURDIR)" uair-forge self-improve hyperagents2 status
	UAIR_FORGE_WORKSPACE="$(CURDIR)" uair-forge self-improve hyperagents2 long-running-mission-check --dir ./missions/rh26-validate
wave: build
	UAIR_FORGE_WORKSPACE="$(CURDIR)" ./missions/rh26-validate/scripts/wave.sh
graph-run: build
	UAIR_FORGE_WORKSPACE="$(CURDIR)" uair-forge self-improve hyperagents2 graph-run \
		--seed RH26-V0 \
		--max-waves 5 \
		--promotion hold \
		--failure-typing \
		--work-cmd './missions/rh26-validate/scripts/wave.sh' \
		--advance-cmd './missions/rh26-validate/scripts/next-gate.sh'
fmt:
	cargo fmt --all -- --check
test:
	cargo test

