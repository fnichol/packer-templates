TEMPLATES ?= $(patsubst ./%,%,$(shell find . -name '*.json' -maxdepth 1 -not -name '*.sample.json' -and -not -name vagrant-cloud.json))
BUILD_TOOLS += packer jq git

PACKER_ARGS ?=

include vendor/mk/base.mk
include vendor/mk/json.mk
include vendor/mk/shell.mk

build: $(TEMPLATES) ## Builds the sources
.PHONY: build

test: ## Runs all tests
.PHONY: test

check: check-shell check-json ## Checks all linting, styling, & other rules
.PHONY: check

clean: clean-shell ## Cleans up project
	rm -rf builds packer_cache packer-*
.PHONY: clean

$(TEMPLATES): buildtools
	@echo "--- $@"
	mkdir -p builds
	packer build -var "git_revision=$$(git show -s --format=%h)" $(PACKER_ARGS) $@
.PHONY: $(TEMPLATES)

upload: buildtools ## Uploads a new version to Vagrant Cloud with all provider boxes
	@echo "--- $@"
	packer build -var metadata=$(METADATA) vagrant-cloud.json
.PHONY: upload
