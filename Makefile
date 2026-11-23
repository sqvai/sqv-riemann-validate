.PHONY: build bootstrap v0 v1 v2 v3 v4 machine-gates status fmt test
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
fmt:
	cargo fmt --all -- --check
test:
	cargo test
