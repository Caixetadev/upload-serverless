.PHONY: build

GO := go
FUNCTIONS := upload notification

build:
	@for function in $(FUNCTIONS); do \
		echo "Building $$function..."; \
		cd internal/adapters/functions/$$function/ && \
		GOOS=linux GOARCH=amd64 CGO_ENABLED=0 ${GO} build -o bootstrap && \
		cd -; \
	done
