prerequisites:
	docker build \
		--tag ghcr.io/bouncmpe/rv32imc \
		--file docker/riscv-gnu-toolchain.dockerfile \
		--build-arg RISCV_ARCH=rv32imc \
		--build-arg RISCV_ABI=ilp32 \
		.

	docker build \
		--tag ghcr.io/bouncmpe/whisper 
		--file docker/whisper.dockerfile \
		.

build:
	docker build \
		--tag ghcr.io/bouncmpe/labs344:latest \
		.

run:
	docker run --rm -it bouncmpe/labs344:latest