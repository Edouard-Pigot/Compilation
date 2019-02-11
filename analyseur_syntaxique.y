%{
#include<stdlib.h>
#include<stdio.h>
#define YYDEBUG 1
//#include"syntabs.h" // pour syntaxe abstraite
//extern n_prog *n;   // pour syntaxe abstraite
extern FILE *yyin;    // declare dans compilo
extern int yylineno;  // declare dans analyseur lexical
int yylex();          // declare dans analyseur lexical
int yyerror(char *s); // declare ci-dessous
int yydebug = 1;
%}

%token POINT_VIRGULE
%token PLUS
%token MOINS
%token FOIS
%token DIVISE
%token PARENTHESE_OUVRANTE
%token PARENTHESE_FERMANTE
%token CROCHET_OUVRANT
%token CROCHET_FERMANT
%token ACCOLADE_OUVRANTE
%token ACCOLADE_FERMANTE
%token EGAL
%token INFERIEUR
%token ET
%token OU
%token NON
%token SI
%token ALORS
%token SINON
%token TANTQUE
%token FAIRE
%token ENTIER
%token RETOUR
%token LIRE
%token ECRIRE
%token IDENTIF
%token NOMBRE
%token VIRGULE

%start programme
%%

programme : declarationVariables declarationFonctions;

//DECLARATION VARIABLES
declarationVariables: 			| listeDeclarationVariables POINT_VIRGULE;
listeDeclarationVariables:		declarationVariable listeDeclarationVariablesBis;
listeDeclarationVariablesBis: 	VIRGULE declarationVariable
listeDeclarationVariablesBis | ;
declarationVariable: type IDENTIF | type IDENTIF CROCHET_OUVRANT taille 
CROCHET_FERMANT;
type:	ENTIER;
taille: expression;

//DECLARATION FONCTIONS
declarationFonctions:	declarationFonction declarationFonctions | declarationFonction;
declarationFonction:	IDENTIF PARENTHESE_OUVRANTE arguments PARENTHESE_FERMANTE
declarationVariables instructionBloc;
arguments:	| listeDeclarationVariables;

//EXPRESSION
expression: expression OU e2 | e3;
e2:			e2 ET e3 | e3;
e3:			e3 EGAL e4 | e3 INFERIEUR e4 | e4;
e4:			e4 PLUS e5 | e4 MOINS e5 | e5;
e5:			e5 FOIS e6 | e5 DIVISE e6 | e6;
e6:			NON e6 | e7;
e7:			PARENTHESE_OUVRANTE expression PARENTHESE_FERMANTE | NOMBRE
| appelFonction | variable | LIRE;

//APPEL FONCTION
appelFonction:		IDENTIF PARENTHESE_OUVRANTE listeExpression PARENTHESE_FERMANTE;
listeExpression:	expression listeExpressionBis | ;
listeExpressionBis:	VIRGULE expression listeExpressionBis | ;

//VARIABLE
variable:	IDENTIF | IDENTIF CROCHET_OUVRANT expression CROCHET_FERMANT;

//INSTRUCTION
instruction:	instructionAffectation | instructionBloc | instructionSi
| instructionTantQue | instructionAppel | instructionRetour | instructionEcriture 
| instructionVide;

//INSTRUCTION AFFECTATION
instructionAffectation: variable EGAL expression POINT_VIRGULE;

//INSTRUCTION BLOC
instructionBloc:		ACCOLADE_OUVRANTE listeInstruction ACCOLADE_FERMANTE;
listeInstruction:		instruction listeInstruction | ;

//INSTRUCTION SI
instructionSi:			SI expression ALORS listeInstructionSi;
listeInstructionSi:		instructionBloc | instructionBloc SINON instructionBloc
| instructionBloc SINON instructionSi;

//INSTRUCTION TANT QUE
instructionTantQue:		TANTQUE expression FAIRE instructionBloc;

//INSTRUCTION APPEL
instructionAppel:	appelFonction POINT_VIRGULE;

//INSTRUCTION RETOUR
instructionRetour:	RETOUR expression POINT_VIRGULE;

//INSTRUCTION ECRIRE
instructionEcriture:	ECRIRE PARENTHESE_OUVRANTE expression PARENTHESE_FERMANTE 
POINT_VIRGULE;

//INSTRUCTION VIDE
instructionVide:	POINT_VIRGULE;

%%

int yyerror(char *s) {
  fprintf(stderr, "erreur de syntaxe ligne %d\n", yylineno);
  fprintf(stderr, "%s\n", s);
  fclose(yyin);
  exit(1);
}











