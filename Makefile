build:
	docker build containers/labs344 \
		--tag ghcr.io/bouncmpe/labs344:latest \
		--build-arg RISCV_ARCH=rv32im \
		--build-arg RISCV_ABI=ilp32 \
		--target labs344 

run:
	docker run --rm -it bouncmpe/labs344:latest

all: build