main: dist dist/indieauth-ticketing.html dist/indieauth-ticketing.txt

.PHONY:dist
dist:
	if [ ! -d dist ] ; then mkdir dist; fi

.tmp.xml: main.md
	@echo processing source markdown into xml2rfc
	~/go/bin/mmark -2 main.md > .tmp.xml

dist/indieauth-ticketing.html: .tmp.xml
	@echo converting xml2rfc file to rfc-html
	pyenv exec xml2rfc --html .tmp.xml
	mv .tmp.html dist/indieauth-ticketing.html

dist/indieauth-ticketing.txt: .tmp.xml
	@echo converting xml2rfc file to rfc-text
	pyenv exec xml2rfc .tmp.xml
	mv .tmp.txt dist/indieauth-ticketing.txt

#dist/indieauth-ticketing.pdf: .tmp.xml
#	pyenv exec xml2rfc --pdf .tmp.xml
#	mv .tmp.pdf dist/indieauth-ticketing.pdf

# for weasyprint (to get pdf output):
#   to BREW-WANTED, add pango libffi
#   to PIP-WANTED add pycairo weasyprint

BREW-WANTED := python@3.10 pyenv 
PIP-WANTED := xml2rfc 
.PHONY:ready
ready:
	for w in $(BREW-WANTED); do if brew list -1 | grep "^$$w" ; then echo $$w installed ; else echo not installed - installing $$w  && brew install $$w; fi; done

	@echo ensuring python version vis-à-vis pyenv installed
	@if pyenv version ; then echo python installed; else echo installing python && pyenv install; fi

	@echo ensuring up-to-date pip installed
	pyenv exec python -m pip install --upgrade pip

	# pyenv exec pip list
	@echo ensuring wanted things are installed or upgraded to latest
	@for w in $(PIP-WANTED); do if pyenv exec pip list | grep "^$$w" ; then echo $$w installed so upgrading && pyenv exec pip install --upgrade $$w; else echo not installed - installing $$w && pyenv exec pip install $$w; fi; done

	@echo ensuring go installed
	@if [ ! -f /usr/local/go/bin/go ] ; then echo please install go \(download pkg from go.dev/dl\) && exit 1; fi

	@if [ ! -f $USER/go/bin/mmark ]; then go get github.com/mmarkdown/mmark; fi
	@if [ ! -f $USER/go/bin/mmark ]; then go install github.com/mmarkdown/mmark; fi

clean:
	rm -rf .tmp.xml
	rm -rf dist/indieauth-ticketing*.txt
	rm -rf dist/indieauth-ticketing*.html
	rm -rf dist/indieauth-ticketing*.pdf
