.PHONY: upload

README.html: README.md
	pandoc --mathml -so README.html -c style.css README.md

upload: README.html style.css
	rsync --mkpath README.html style.css runxiyu.org:/var/www/docs/e2/
