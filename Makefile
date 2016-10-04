all: install

dependencies:
	go install -tags='dev' github.com/NebulousLabs/Sia/siad
	go install -race std
	go get -u github.com/golang/lint/golint

pkgs = ./sia-ant ./sia-antfarm

fmt:
	gofmt -s -l -w $(pkgs)

vet:
	go vet $(pkgs)

# install builds and installs binaries.
install:
	go install $(pkgs)

test: fmt vet install
	go test -timeout=600s -race -v $(pkgs)

lint:
	@for package in $(pkgs); do 													 \
		golint -min_confidence=1.0 $$package 								 \
		&& test -z $$(golint -min_confidence=1.0 $$package) ; \
	done

clean:
	rm -rf cover

cover: clean 
	mkdir -p cover/
	@for package in $(pkgs); do \
		go test -covermode=atomic -coverprofile=cover/$$package.out ./$$package \
		&& go tool cover -html=cover/$$package.out -o=cover/$$package.html \
		&& rm cover/$$package.out ; \
	done

.PHONY: all dependencies pkgs fmt vet install test lint clean cover
