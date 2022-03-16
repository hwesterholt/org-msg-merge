Emacs ?= emacs

TEST_DIR=$(shell pwd)/test

# Run alll tests by default
MATCH ?=

.PHONY: test

test:
$(EMACS) --batch -L. $(TEST_DIR) -l all-tests.el -eval '(ert-run-tests-batch-and-exit "$(MATCH)")'
