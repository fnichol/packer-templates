TEMPLATES ?= $(patsubst ./%,%,$(shell find . -name '*.json' -maxdepth 1 -not -name '*.sample.json'))
CHECK_TOOLS += packer jq git

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
	rm -rf builds
.PHONY: clean

$(TEMPLATES): checktools
	@echo "--- $@"
	packer build -var "git_revision=$$(git show -s --format=%h)" $(PACKER_ARGS) $@
.PHONY: $(TEMPLATES)
