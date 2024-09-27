CONTEXT ?= .

all: build

build:
	docker build ${CONTEXT} \
		-f containers/labs344/Dockerfile \
		--tag bouncmpe/labs344:latest \
		--target labs344
	
run:
	docker run --rm -it bouncmpe/labs344:latest

.PHONY: all build run