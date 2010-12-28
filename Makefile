PERL = perl

ifeq "$(PAPER)" ""
	PAPER = $(shell paperconf)
endif

ifneq "$(TEST)" ""
	BOOK = build/test.$(PAPER)
	CHAPTERS = $(wildcard test/*.pod)
else
	BOOK = build/SDL_Manual.$(PAPER)
	CHAPTERS = \
    src/00-preface.pod \
    src/01-first.pod \
    src/02-drawing.pod \
    src/03-events.pod \
    src/04-game.pod \
    src/05-pong.pod \
    src/06-tetris.pod \
    src/07-puzz.pod \
    src/08-music_and_sound.pod \
    src/09-CPAN.pod \
    src/10-profiling.pod \
    src/11-XS_effects.pod \
    src/12-PDL_OpenGL.pod
 
endif

default: prepare pdf clean

prepare: clean
	mkdir build

html: prepare $(CHAPTERS) bin/book-to-html
	$(PERL) bin/book-to-html $(CHAPTERS) > $(BOOK).html

pdf: tex lib/Makefile
	#cp src/mmd-table.svg build/mmd-table.svg
	cd build && make -I ../lib -f ../lib/Makefile 

tex: prepare $(CHAPTERS) lib/SDLManualLatex.pm lib/book.sty bin/book-to-latex
	$(PERL) -Ilib bin/book-to-latex --paper $(PAPER) $(CHAPTERS) > $(BOOK).tex

rel_pdf: pdf
	cp $(BOOK).pdf dist/SDL_Manual.pdf

rel_html: html
	cp $(BOOK).html dist/SDL_Manual.html

bump: rel_pdf rel_html 

clean: 
	rm -rf build/

.PHONY: clean

# vim: set noexpandtab
