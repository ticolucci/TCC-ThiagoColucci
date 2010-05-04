all: ideias.pdf

ideias.pdf: seminario/ideias.tex
	pdflatex seminario/ideias.tex
	pdflatex seminario/ideias.tex
	pdflatex seminario/ideias.tex
	pdflatex seminario/ideias.tex
	rm -f ideias.dvi ideias.aux ideias.log ideias.toc ideias.out

clean:
	rm -f ideias.pdf
