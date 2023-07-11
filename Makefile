PREFIX = $(HOME)/.local
BINDIR = $(PREFIX)/bin
SCRIPTS = $(wildcard bin/*[^~])
TARGETS = $(addprefix $(BINDIR)/,$(notdir $(SCRIPTS)))
STYLE ?= --stylesheet-dirs=etc
CLEAN = README.html $(addprefix doc/bibtools,.aux .log .fdb_latexmk .fls .nav .out .pdf .snm .toc .vrb)

info:
	@echo "Available targets:"
	@echo "- install: install scripts to $(BINDIR)"
	@echo "- uninstall: remove scripts from $(BINDIR)"
	@echo "- doc: create README.html and bibtools.pdf"
	@echo "- info: print this information"

# Install and uninstall.
install: $(TARGETS)
$(BINDIR)/% : bin/%
	install -m 755 $+ $(BINDIR)/

uninstall: | $(wildcard $(addprefix $(BINDIR)/,$(notdir $(SCRIPTS))))
	$(if $|,rm -f $|)

# Documentation.
doc: README.html doc/bibtools.pdf

clean:
	$(if $(wildcard $(CLEAN)),$(RM) $(wildcard $(CLEAN)))

%.html : %.rst
	$(if $(shell which rst2html),rst2html -t $(STYLE) $< $@,\
	$(info Please install 'python-docutils' to create html documentation.))

doc/bibtools.pdf: doc/bibtools.tex $(wildcard doc/figures/*.jpg)
	cd doc && latexmk -pdf bibtools && latexmk -c bibtools

# Testing.
test: shunit2/shunit2 install
	./test/test_runner

shunit2/shunit2:
	git submodule init
	git submodule update --remote


.PHONY: all doc test install uninstall clean info
