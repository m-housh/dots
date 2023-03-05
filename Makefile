PREFIX ?= $(HOME)/.local
BINDIR = $(PREFIX)/bin
COMPLETIONDIR = $(PREFIX)/completions
LIBDIR = $(PREFIX)/lib

build:
	swiftc ./scripts/build.swift
	./build
	rm ./build

install: build
	install -d "$(BINDIR)" "$(LIBDIR)"
	install ./.build/release/dots "$(BINDIR)"

uninstall:
	rm "$(BINDIR)/dots"
	rm "$(COMPLETIONDIR)/_dots"

