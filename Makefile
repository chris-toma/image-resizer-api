GO_BUILD=GOOS=linux GOARCH=amd64 go build

build-only:
	mkdir -p bin
	cd functions && \
	for FUNCTION in *; do \
	  echo "Building $${FUNCTION}" && \
	  $(GO_BUILD) -o ../bin/ ./$${FUNCTION}; \
	done

zip:
	mkdir -p zipped
	cd bin && \
	for FUNCTION in *; do \
	  echo "Building $${FUNCTION}"; \
	  pwd; \
	  zip ../zipped/$$FUNCTION.zip ./$$FUNCTION ; \
	done

apply:
	terraform apply -auto-approve

all: build-only zip apply