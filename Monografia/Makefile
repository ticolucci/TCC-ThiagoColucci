BASE_NAME = tcc

LATEX     = latex
PDFLATEX  = pdflatex
BIBTEX    = bibtex
MAKEINDEX = makeindex

open_tcc: clean tcc.pdf 
	open tcc.pdf

tcc.pdf: tcc.tex 
	$(PDFLATEX) tcc.tex
	$(BIBTEX) tcc 
	$(PDFLATEX) tcc.tex
	$(PDFLATEX) tcc.tex
	$(PDFLATEX) tcc.tex
	rm -f $(BASE_NAME)*.ps $(BASE_NAME)*.dvi *.log *.aux *.blg *.toc *.brf *.ilg *.ind *.idx missfont.log $(BASE_NAME)*.bbl $(BASE_NAME)*.out $(BASE_NAME)*.lof $(BASE_NAME)*.lot

clean:
	rm -f $(BASE_NAME)*.ps $(BASE_NAME)*.dvi *.log *.aux *.blg *.toc *.brf *.ilg *.ind *.idx missfont.log $(BASE_NAME)*.bbl $(BASE_NAME)*.pdf $(BASE_NAME)*.out $(BASE_NAME)*.lof $(BASE_NAME)*.lot 
