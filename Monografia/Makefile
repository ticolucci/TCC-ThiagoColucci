BASE_NAME = tcc_thiago_r_colucci

LATEX     = latex
PDFLATEX  = pdflatex
BIBTEX    = bibtex
MAKEINDEX = makeindex

open_tcc: clean $(BASE_NAME).pdf 
	open $(BASE_NAME).pdf

$(BASE_NAME).pdf: $(BASE_NAME).tex 
	$(PDFLATEX) $(BASE_NAME).tex
	$(BIBTEX) $(BASE_NAME) 
	$(PDFLATEX) $(BASE_NAME).tex
	$(PDFLATEX) $(BASE_NAME).tex
	$(PDFLATEX) $(BASE_NAME).tex
	rm -f $(BASE_NAME)*.ps $(BASE_NAME)*.dvi *.log *.aux *.blg *.toc *.brf *.ilg *.ind *.idx missfont.log $(BASE_NAME)*.bbl $(BASE_NAME)*.out $(BASE_NAME)*.lof $(BASE_NAME)*.lot

clean:
	rm -f $(BASE_NAME)*.ps $(BASE_NAME)*.dvi *.log *.aux *.blg *.toc *.brf *.ilg *.ind *.idx missfont.log $(BASE_NAME)*.bbl $(BASE_NAME)*.pdf $(BASE_NAME)*.out $(BASE_NAME)*.lof $(BASE_NAME)*.lot 
