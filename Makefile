# GNU Make is required

.PHONY: upload default

default: build/language_description.html build/index.html build/style.css

.SUFFIXES: .md .html

build/%.html: %.md
	mkdir -p build
	pandoc --preserve-tabs --mathml -so $@ -c style.css $<

build/%.css: %.css
	mkdir -p build
	cp $< $@

upload:
	rsync --delete-after --recursive --mkpath build/ runxiyu.org:/var/www/docs/e2/
