tl;dr

1. Ensure anything that needs to be installed (if you are on macOS) is installed:
```sh
# make ready
````

2. Build the documentation
```sh
# make
````

---

This repository contains a documentation set that needs to be built using the following toolchain:

~~~ ascii-art
MAIN.md --(1)--> .tmp.xml --(2)--> {whatever}.text
                                -> {whatever}.html
~~~

(1) is done using [`mmark`](https://mmark.miek.nl) - a go-based command line application which is installed using the `go get`/`go install` from `github.com/mmarkdown/mmark`.
(2) is done using [`xml2rfc`](https://xml2rfc.tools.ietf.org), a python-based command line application which is installed by  `pip install xml2rfc`.
