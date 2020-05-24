JSON_SOURCES ?= $(shell find . -type f -name '*.json' -not -path './tmp/*' -and -not -path './vendor/*')
CHECK_TOOLS += jq

check-json: checktools ## Checks JSON files are well formed
	@echo "--- $@"
	@for json in $(JSON_SOURCES); do echo "  - $$json"; jq empty "$$json"; done
.PHONY: check-json
