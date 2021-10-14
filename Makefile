TEMPLATES ?= $(patsubst ./%,%,$(shell find . -name '*.json' -maxdepth 1 -not -name '*.sample.json' -and -not -name vagrant-cloud.json))
BUILD_TOOLS += packer jq git
CHECK_TOOLS += packer

PACKER_ARGS ?=

include vendor/mk/base.mk
include vendor/mk/json.mk
include vendor/mk/shell.mk

build: $(TEMPLATES) ## Builds the sources
.PHONY: build

test: ## Runs all tests
.PHONY: test

check: check-shell check-json check-template ## Checks all linting, styling, & other rules
.PHONY: check

check-template: checktools
	@echo "--- $@"
	@for tmpl in $(TEMPLATES); do \
		echo "  - $$tmpl"; \
		packer validate \
			-var "git_revision=$$(git show -s --format=%h)" \
			$$tmpl; \
	done
.PHONY: check-template

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

upload-all: buildtools ## Uploads all built boxes
	@echo "--- $@"
	@find builds -name '*.metadata.json' -type f \
		| while read -r metadata; do \
			$(MAKE) upload METADATA=$$metadata || break; \
		done
.PHONY: upload-all

release-openbsd: clean openbsd-7.0-amd64.json openbsd-6.9-amd64.json upload-all ## Builds and uploads supported OpenBSD versions
.PHONY: release-openbsd

release-openbsd-7.0: clean openbsd-7.0-amd64.json upload-all ## Builds and uploads OpenBSD 7.0 boxes
.PHONY: release-openbsd-7.0

release-openbsd-6.9: clean openbsd-6.9-amd64.json upload-all ## Builds and uploads OpenBSD 6.9 boxes
.PHONY: release-openbsd-6.9

release-openbsd-6.8: clean openbsd-6.8-amd64.json upload-all ## Builds and uploads OpenBSD 6.8 boxes
.PHONY: release-openbsd-6.8
