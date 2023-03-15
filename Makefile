PREFIX ?= $(HOME)/.local
BINDIR = $(PREFIX)/bin
COMPLETIONDIR = $(PREFIX)/completions
LIBDIR = $(PREFIX)/lib
BOTTLE = "$(shell ls *.gz)"
VERSION = "$(shell dots --version)"

bottle:
	swift run --configuration release --disable-sandbox builder bottle
	@echo "Run 'make upload-bottle', once you've updated the formula"

# Remove.
update-bottle-name:
	$(shell source "./scripts/update-bottle-name.sh")
	@echo "Updated bottle name"

upload-bottle:
	gh release upload "$(VERSION)" "$(BOTTLE)"
	$(MAKE) remove-bottle

remove-bottle:
	rm -rf "$(BOTTLE)"

build:
	swift run --configuration release --disable-sandbox builder build

install: build
	install -d "$(BINDIR)" "$(LIBDIR)"
	install ./.build/release/dots "$(BINDIR)"

uninstall:
	rm "$(BINDIR)/dots"
	rm "$(COMPLETIONDIR)/_dots"

clean:
	rm -rf ./.build

.PHONY: bottle update-bottle-name build install uninstall clean
