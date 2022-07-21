prerequsites:
	docker build \
		--tag bouncmpe/rv32imc \
		--file docker/riscv-gnu-toolchain.dockerfile \
		--build-arg RISCV_ARCH=rv32imc \
		--build-arg RISCV_ABI=ilp32 \
		.
		
	docker build \
		--tag bouncmpe/whisper 
		--file docker/whisper.dockerfile \
		.

build:
	docker build \
		--tag bouncmpe/labs344:latest \
		.

run:
	docker run --rm -it bouncmpe/labs344:latest