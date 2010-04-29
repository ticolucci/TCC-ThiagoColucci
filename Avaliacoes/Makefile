all: avaliacao-calopsita.pdf avaliacao-visocor.pdf

avaliacao-calopsita.pdf: src/avaliacao-calopsita.tex
	pdflatex src/avaliacao-calopsita.tex
	pdflatex src/avaliacao-calopsita.tex
	pdflatex src/avaliacao-calopsita.tex
	pdflatex src/avaliacao-calopsita.tex
	rm -f avaliacao-calopsita.dvi avaliacao-calopsita.aux avaliacao-calopsita.log avaliacao-calopsita.toc avaliacao-calopsita.out

avaliacao-visocor.pdf: src/avaliacao-visocor.tex
	pdflatex src/avaliacao-visocor.tex
	pdflatex src/avaliacao-visocor.tex
	pdflatex src/avaliacao-visocor.tex
	pdflatex src/avaliacao-visocor.tex
	rm -f avaliacao-visocor.dvi avaliacao-visocor.aux avaliacao-visocor.log avaliacao-visocor.toc avaliacao-visocor.out

testDoc: all
	evince avaliacao-calopsita.pdf

clean:
	rm -f avaliacao-visocor.pdf avaliacao-calopsita.pdf
