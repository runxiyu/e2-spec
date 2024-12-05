.PHONY: upload default

default: language_description.html

.SUFFIXES: .md .html

.md.html:
	pandoc --mathml -so $@ -c style.css $<

upload: language_description.html style.css
	rsync --mkpath language_description.html style.css runxiyu.org:/var/www/docs/e2/
