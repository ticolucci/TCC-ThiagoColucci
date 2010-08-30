all: proposta.pdf

proposta.pdf: src/proposta.tex
	pdflatex src/proposta.tex
	pdflatex src/proposta.tex
	pdflatex src/proposta.tex
	pdflatex src/proposta.tex
	rm -f proposta.dvi proposta.aux proposta.log proposta.toc proposta.out

testDoc: all
	evince proposta.pdf

clean:
	rm -f proposta.pdf
