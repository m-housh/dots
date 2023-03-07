PREFIX ?= $(HOME)/.local
BINDIR = $(PREFIX)/bin
COMPLETIONDIR = $(PREFIX)/completions
LIBDIR = $(PREFIX)/lib

bottle:
	swift run -c release bottle

build:
	swift run -c release --disable-sandbox build

install: build
	install -d "$(BINDIR)" "$(LIBDIR)"
	install ./.build/release/dots "$(BINDIR)"

uninstall:
	rm "$(BINDIR)/dots"
	rm "$(COMPLETIONDIR)/_dots"

clean:
	rm -rf ./.build
