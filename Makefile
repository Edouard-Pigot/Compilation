CC = gcc
FLEX = flex

LIBS = -lm 
CCFLAGS = -Wall -ggdb
YACC = bison -d -t

OBJ = analyseur_lexical_flex.o util.o syntabs.o affiche_arbre_abstrait.o analyseur_syntaxique.tab.o tabsymboles.o parcours_arbre_abstrait.o

all: compilo

compilo: compilo.c $(OBJ)
	$(CC) -o $@ compilo.c $(OBJ)

analyseur_syntaxique.tab.c : analyseur_syntaxique.y
	$(YACC) $<

analyseur_lexical_flex.c: analyseur_lexical.flex analyseur_syntaxique.tab.c
	$(FLEX) -o $@ $<

%.o: %.c
	$(CC) $(CCFLAGS) -c $^

.PHONY : clean

clean:
	- rm -f $(OBJ)
	- rm -f compilo
	- rm -f test_yylex
	- rm -f analyseur_lexical_flex.c
	- rm -f analyseur_syntaxique.tab.*
