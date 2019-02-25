%{
#include<stdlib.h>
#include<stdio.h>
#define YYDEBUG 1
#include"syntabs.h" // pour syntaxe abstraite
extern n_prog *n;   // pour syntaxe abstraite
extern FILE *yyin;    // declare dans compilo
extern int yylineno;  // declare dans analyseur lexical
int yylex();          // declare dans analyseur lexical
int yyerror(char *s); // declare ci-dessous
int yydebug = 1;
%}

%union { int nval;
	char* idval;
	n_l_instr* nlinstr; 
	n_instr* ninstr;
	n_exp* nexp;
	n_l_exp* nlexp;
	n_var* nvar;
	n_l_dec* nldec;
	n_dec* ndec;
	n_prog* nprog;
	n_appel* nappel;
}

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
%token <idval>IDENTIF
%token <nval>NOMBRE
%token VIRGULE

%type <nprog> 	programme
%type <nlinstr> listeInstruction
%type <ninstr> 	instruction instructionAffectation instructionSi instructionTantQue instructionAppel instructionRetour instructionEcriture instructionVide instructionBloc
%type <nexp> 	expression e2 e3 e4 e5 e6 e7
%type <nlexp> 	listeExpression listeExpressionBis
%type <nvar> 	variable
%type <nldec> 	listeDeclarationVariables arguments listeDeclarationVariablesBis declarationVariable declarationFonction
%type <ndec> 	declarationVariables declarationFonctions
%type <nappel> 	appelFonction

%start programme
%%

programme : declarationVariables declarationFonctions {n = cree_n_prog($1, $2);};

//DECLARATION VARIABLES
declarationVariables: 			{$$ = NULL;} 
| listeDeclarationVariables POINT_VIRGULE {$$ = $1;};
listeDeclarationVariables:		declarationVariable listeDeclarationVariablesBis {$$ = cree_n_l_dec($1,$2);};
listeDeclarationVariablesBis: 	VIRGULE declarationVariable 
listeDeclarationVariablesBis {$$ = cree_n_l_dec($2,$3);}| {$$ = NULL;};
declarationVariable: ENTIER IDENTIF {$$ = cree_n_dec_var($2);} 
| ENTIER IDENTIF CROCHET_OUVRANT expression CROCHET_FERMANT {$$ = cree_n_dec_tab($2,$4);};

//DECLARATION FONCTIONS
declarationFonctions:	declarationFonction declarationFonctions {$$ = cree_n_l_dec($1,$2);}
| declarationFonction {$$ = cree_n_l_dec($1, NULL);};
declarationFonction:	IDENTIF PARENTHESE_OUVRANTE arguments PARENTHESE_FERMANTE
declarationVariables instructionBloc {$$ = cree_n_dec_fonc($1,$3,$5,$6);};
arguments:	{$$ = NULL;}| listeDeclarationVariables {$$ = $1;};

//EXPRESSION
expression: expression OU e2 {$$ = cree_n_exp_op(ou, $1, $3);}
| e3 {$$ = $1;};
e2:			e2 ET e3 {$$ = cree_n_exp_op(et, $1, $3);}
| e3 {$$ = $1;};
e3:			e3 EGAL e4 {$$ = cree_n_exp_op(egal, $1, $3);}
| e3 INFERIEUR e4 {$$ = cree_n_exp_op(inferieur, $1, $3);}
| e4 {$$ = $1;};
e4:			e4 PLUS e5 {$$ = cree_n_exp_op(plus, $1, $3);}
| e4 MOINS e5 {$$ = cree_n_exp_op(moins, $1, $3);}
| e5 {$$ = $1;};
e5:			e5 FOIS e6 {$$ = cree_n_exp_op(fois, $1, $3);}
| e5 DIVISE e6 {$$ = cree_n_exp_op(divise, $1, $3);}
| e6 {$$ = $1;};
e6:			NON e6 {$$ = cree_n_exp_op(non, $2, NULL);}
| e7 {$$ = $1;};
e7:			PARENTHESE_OUVRANTE expression PARENTHESE_FERMANTE {$$ = $2;}
| NOMBRE {$$ = cree_n_exp_entier($1);} 
| appelFonction {$$ = cree_n_exp_appel($1);}
| variable {$$ = cree_n_exp_var($1);}
| LIRE PARENTHESE_OUVRANTE PARENTHESE_FERMANTE{$$ = cree_n_exp_lire();};

//APPEL FONCTION
appelFonction:		IDENTIF PARENTHESE_OUVRANTE listeExpression PARENTHESE_FERMANTE
{$$ = cree_n_appel($1, $3);};
listeExpression:	expression listeExpressionBis {$$ = cree_n_l_exp($1, $2);} | {$$ = NULL;};
listeExpressionBis:	VIRGULE expression listeExpressionBis {$$ = cree_n_l_exp($2, $3);}| {$$ = NULL;};

//VARIABLE
variable:	IDENTIF {$$ = cree_n_var_simple($1);}| IDENTIF CROCHET_OUVRANT 
expression CROCHET_FERMANT {$$ = cree_n_var_indicee($1, $3);};

//INSTRUCTION
instruction:	instructionAffectation {$$ = $1;}
				| instructionBloc {$$ = $1;}
				| instructionSi {$$ = $1;}
				| instructionTantQue {$$ = $1;}
				| instructionAppel {$$ = $1;}
				| instructionRetour {$$ = $1;}
				| instructionEcriture {$$ = $1;}
				| instructionVide {$$ = $1;};

//INSTRUCTION AFFECTATION
instructionAffectation: variable EGAL expression POINT_VIRGULE {$$ = cree_n_instr_affect($1,$3);};

//INSTRUCTION BLOC
instructionBloc:		ACCOLADE_OUVRANTE listeInstruction ACCOLADE_FERMANTE {$$ = cree_n_instr_bloc($2);};
listeInstruction:		instruction listeInstruction {$$ = cree_n_l_instr($1,$2);}
			| {$$ = NULL;};

//INSTRUCTION SI
instructionSi:			SI expression ALORS instructionBloc {$$ = cree_n_instr_si($2,$4,NULL);}
						| SI expression ALORS instructionBloc SINON instructionBloc
						{$$ = cree_n_instr_si($2,$4,$6);};
//INSTRUCTION TANT QUE
instructionTantQue:		TANTQUE expression FAIRE instructionBloc {$$ = cree_n_instr_tantque($2,$4);};

//INSTRUCTION APPEL
instructionAppel:	appelFonction POINT_VIRGULE {$$ = cree_n_instr_appel($1);};

//INSTRUCTION RETOUR
instructionRetour:	RETOUR expression POINT_VIRGULE {$$ = cree_n_instr_retour($2);};

//INSTRUCTION ECRIRE
instructionEcriture:	ECRIRE PARENTHESE_OUVRANTE expression PARENTHESE_FERMANTE 
POINT_VIRGULE {$$ = cree_n_instr_ecrire($3);};

//INSTRUCTION VIDE
instructionVide:	POINT_VIRGULE {$$ = cree_n_instr_vide();};

%%

int yyerror(char *s) {
  fprintf(stderr, "erreur de syntaxe ligne %d\n", yylineno);
  fprintf(stderr, "%s\n", s);
  fclose(yyin);
  exit(1);
}











