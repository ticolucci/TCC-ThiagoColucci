all: ideias.pdf

ideias.pdf: ideias.tex
	pdflatex ideias.tex
	pdflatex ideias.tex
	pdflatex ideias.tex
	pdflatex ideias.tex
	rm -f ideias.dvi ideias.aux ideias.log ideias.toc ideias.out

clean:
	rm -f ideias.pdf
