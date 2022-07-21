build:
	docker build --tag bouncmpe/rv32imc --file docker/rv32imc.dockerfile .
	docker build --tag bouncmpe/whisper --file docker/whisper.dockerfile .
	docker build --tag bouncmpe/labs344-dev:latest .

run:
	docker run --rm -it bouncmpe/labs344-dev:latest