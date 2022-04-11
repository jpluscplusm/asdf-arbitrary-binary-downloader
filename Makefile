.DEFAULT_GOAL := help
unit-test: ## Run unit tests in Dagger
	dagger do unit --log-format plain



help: ## Display this help text
	@grep -E '^[-a-zA-Z0-9_/.]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%s\033[0m\n\t%s\n", $$1, $$2}'
.PHONY: help unit-test
