CONTEXT ?= .

all: build

toolchain:
	podman build  \
		-f containers/labs344/Dockerfile \
		--tag bouncmpe/labs344:latest-toolchain \
		--target labs344-toolchain
	${CONTEXT}

builder:
	podman build  \
		-f containers/labs344/Dockerfile \
		--tag bouncmpe/labs344:latest-builder \
		--target labs344-builder
	${CONTEXT}

labs344:
	podman build  \
		-f containers/labs344/Dockerfile \
		--tag bouncmpe/labs344:latest \
		--target labs344
	${CONTEXT}
	
run:
	docker run --rm -it bouncmpe/labs344:latest

.PHONY: all builder labs344 run