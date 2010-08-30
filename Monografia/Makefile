all: monograph.pdf

monograph.pdf: monograph.tex
	pdflatex monograph.tex
	pdflatex monograph.tex
	pdflatex monograph.tex
	pdflatex monograph.tex
	rm -f monograph.dvi monograph.aux monograph.log monograph.toc monograph.out

clean:
	rm -f monograph.pdf
