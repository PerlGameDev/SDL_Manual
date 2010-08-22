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
    src/preface.pod \
    src/first.pod \
	src/drawing.pod \
	src/events.pod \
	src/game.pod \
	src/pong.pod \
	src/tetris.pod \
	src/music.pod \
	src/CPAN.pod \
	src/profiling.pod \
	src/XS_effects.pod \
	src/PDL_OpenGL.pod 
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

release: pdf
	cp $(BOOK).pdf build/book-$$(date +"%Y-%m").$(PAPER).pdf

clean: 
	rm -rf build/

.PHONY: clean

# vim: set noexpandtab
