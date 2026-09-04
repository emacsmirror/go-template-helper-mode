EMACS ?= emacs
PKG   := go-template-helper-mode
TESTS := tests/$(PKG)-test.el
GO_TEMPLATE_MODE_DIR ?= ../go-template-mode
EMACS_LOAD_PATH := -L . -L "$(GO_TEMPLATE_MODE_DIR)"

.PHONY: all compile test clean

all: compile test

compile:
	$(EMACS) -Q -batch $(EMACS_LOAD_PATH) \
	  -f batch-byte-compile $(PKG).el

test: compile
	$(EMACS) -Q -batch $(EMACS_LOAD_PATH) -L tests \
	  -l $(TESTS) \
	  -f ert-run-tests-batch-and-exit

clean:
	rm -f *.elc tests/*.elc
