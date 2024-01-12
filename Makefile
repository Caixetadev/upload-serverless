.PHONY: build

GO := go
FUNCTIONS := upload notification

build:
	@for function in $(FUNCTIONS); do \
  	echo "Building $$function..."; \
    cd cmd/$$function/ && \
    GOOS=linux GOARCH=amd64 CGO_ENABLED=0 ${GO} build -o bootstrap && \
    mkdir -p ../../build/$$function/bin && \
		zip bootstrap bootstrap; \
		mv bootstrap.zip ../../build/$$function/bin/; \
    mv bootstrap ../../build/$$function/bin/; \
    cd -; \
	done
