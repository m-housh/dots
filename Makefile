PREFIX ?= $(HOME)/.local
BINDIR = $(PREFIX)/bin
COMPLETIONDIR = $(PREFIX)/completions
LIBDIR = $(PREFIX)/lib
BOTTLE = "$(shell ls *.gz)"
VERSION = "$(shell dots --version)"

bottle:
	swift run -c release bottle
	$(MAKE) update-bottle-name

update-bottle-name:
	$(shell source "./scripts/update-bottle-name.sh")
	echo "Updated bottle name"

upload-bottle:
	gh release upload "$(VERSION)" "$(BOTTLE)"

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

.PHONY: bottle update-bottle-name build install uninstall clean
