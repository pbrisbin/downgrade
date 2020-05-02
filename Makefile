LOCALE_PREFIX ?= /usr
PREFIX    ?= /usr/local
MANPREFIX ?= $(PREFIX)/share/man
PANDOC    ?= $(shell which pandoc)

setup:
	command -v cram   || aurget cram
	command -v vbump  || aurget vbump-git
	command -v pandoc || stack install pandoc

locale:
	xgettext \
		--from-code=utf-8 -L shell \
		--package-name=downgrade \
		--copyright-holder=$(AUTHOR) \
		-o locale/downgrade.pot downgrade
	ls ./locale/*po | xargs -I {} msgmerge --update {} ./locale/downgrade.pot

man:
	$(PANDOC) --standalone --to man doc/downgrade.8.md -o doc/downgrade.8

test:
	cram test

install:
	install -Dm755 downgrade $(DESTDIR)/$(PREFIX)/bin/downgrade
	install -Dm644 doc/downgrade.8 $(DESTDIR)/$(MANPREFIX)/man8/downgrade.8
	install -Dm644 completion/bash $(DESTDIR)/$(PREFIX)/share/bash-completion/completions/downgrade
	install -Dm644 completion/zsh $(DESTDIR)/$(PREFIX)/share/zsh/site-functions/_downgrade

uninstall:
	$(RM) $(DESTDIR)/$(PREFIX)/bin/downgrade \
	  $(DESTDIR)/$(MANPREFIX)/man8/downgrade.8 \
	  $(DESTDIR)/$(PREFIX)/share/bash-completion/completions/downgrade \
	  $(DESTDIR)/$(PREFIX)/share/zsh/site-functions/_downgrade

.PHONY: setup test install uninstall locale

.PHONY: install.po
install.po:
	for po_file in $(shell ls ./locale/*po); do \
		locale="$$(basename "$$po_file" .po)" && \
		mkdir -p "$(DESTDIR)/$(LOCALE_PREFIX)/share/locale/$$locale/LC_MESSAGES/" && \
		msgfmt "$$po_file" -o "$(DESTDIR)/$(LOCALE_PREFIX)/share/locale/$$locale/LC_MESSAGES/downgrade.mo"; \
	done

.PHONY: uninstall.po
uninstall.po:
	for po_file in $(shell ls ./locale/*po); do \
		locale="$$(basename "$$po_file" .po)" && \
		$(RM) "$(DESTDIR)/$(LOCALE_PREFIX)/share/locale/$$locale/LC_MESSAGES/downgrade.mo"; \
	done

.PHONY: release.major
release.major: VERSION=$(shell git tag | vbump major | sed 's/^v//')
release.major: release

.PHONY: release.minor
release.minor: VERSION=$(shell git tag | vbump minor | sed 's/^v//')
release.minor: release

.PHONY: release.match
release.patch: VERSION=$(shell git tag | vbump patch | sed 's/^v//')
release.patch: release

.PHONY: release
release: test
	[ -n "$(VERSION)" ]
	git tag -s -m v$(VERSION) v$(VERSION)
	git push --follow-tags
	aur-release downgrade "$(VERSION)"
