.PHONY: it
it: coding-standards static-code-analysis tests ## Runs the coding-standards, static-code-analysis, and tests targets

.PHONY: coding-standards
coding-standards: vendor ## Fixes code style issues with friendsofphp/php-cs-fixer
	mkdir -p .build/php-cs-fixer
	vendor/bin/php-cs-fixer fix --config=.php_cs --diff --diff-format=udiff --verbose

.PHONY: help
help: ## Displays this list of targets with descriptions
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: static-code-analysis
static-code-analysis: vendor ## Runs a static code analysis with phpstan/phpstan
	mkdir -p .build/phpstan
	vendor/bin/phpstan analyse --configuration=phpstan-with-extension.neon
	vendor/bin/phpstan analyse --configuration=phpstan-without-extension.neon

.PHONY: static-code-analysis-baseline
static-code-analysis-baseline: vendor ## Generates a baseline for static code analysis with phpstan/phpstan
	echo '' > phpstan-with-extension-baseline.neon
	vendor/bin/phpstan analyze --configuration=phpstan-with-extension.neon --error-format=baselineNeon > phpstan-with-extension-baseline.neon || true
	echo '' > phpstan-without-extension-baseline.neon
	vendor/bin/phpstan analyze --configuration=phpstan-without-extension.neon --error-format=baselineNeon > phpstan-without-extension-baseline.neon || true

.PHONY: tests
tests: vendor ## Runs tests with phpunit/phpunit
	vendor/bin/phpunit --configuration=phpunit.xml

vendor: composer.json composer.lock
	composer validate --strict
	composer install --no-interaction --no-progress
	composer normalize
