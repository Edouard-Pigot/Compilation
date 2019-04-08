#include <stdio.h>
#include "syntabs.h"
#include "util.h"
#include "tabsymboles.h"
#include "code3a.h"
#include <string.h>
#include <stdlib.h>

void parcours_n_prog(n_prog *n);
void parcours_l_instr(n_l_instr *n);
void parcours_instr(n_instr *n);
void parcours_instr_si(n_instr *n);
void parcours_instr_tantque(n_instr *n);
void parcours_instr_pour(n_instr *n);
void parcours_instr_affect(n_instr *n);
void parcours_instr_appel(n_instr *n);
void parcours_instr_retour(n_instr *n);
void parcours_instr_ecrire(n_instr *n);
void parcours_l_exp(n_l_exp *n);
operande* parcours_exp(n_exp *n);
operande* parcours_varExp(n_exp *n);
operande* parcours_opExp(n_exp *n);
operande* parcours_intExp(n_exp *n);
operande* parcours_lireExp(n_exp *n);
operande* parcours_appelExp(n_exp *n);
void parcours_l_dec(n_l_dec *n);
void parcours_dec(n_dec *n);
void parcours_foncDec(n_dec *n);
void parcours_varDec(n_dec *n);
void parcours_tabDec(n_dec *n);
operande* parcours_var(n_var *n);
operande* parcours_var_simple(n_var *n);
operande* parcours_var_indicee(n_var *n);
operande* parcours_appel(n_appel *n);
int nb_param(n_l_dec* liste);
int nb_argument(n_l_exp* liste);

extern int affichetab;
extern int portee;
extern int adresseLocaleCourante;
extern int adresseArgumentCourant;
extern code3a_ code3a;
int adresseGlobaleCourante = 0;

/*-------------------------------------------------------------------------*/

void parcours_n_prog(n_prog *n)
{
	code3a_init();
	portee = P_VARIABLE_GLOBALE;
	parcours_l_dec(n->variables);
	parcours_l_dec(n->fonctions); 
	 
	if(rechercheExecutable("main") == -1) {
	  erreur("Pas de fonction main");
	}
    if(tabsymboles.tab[rechercheExecutable("main")].complement !=  0) {
	  erreur("Main ne prend pas d'argument");
	}
}

/*-------------------------------------------------------------------------*/

void parcours_l_instr(n_l_instr *n)
{
  if(n){
  parcours_instr(n->tete);
  parcours_l_instr(n->queue);
  }
}

/*-------------------------------------------------------------------------*/

void parcours_instr(n_instr *n)
{
  if(n){
    if(n->type == blocInst) parcours_l_instr(n->u.liste);
    else if(n->type == affecteInst) parcours_instr_affect(n);
    else if(n->type == siInst) parcours_instr_si(n);
    else if(n->type == tantqueInst) parcours_instr_tantque(n);
    else if(n->type == appelInst) parcours_instr_appel(n);
    else if(n->type == retourInst) parcours_instr_retour(n);
    else if(n->type == ecrireInst) parcours_instr_ecrire(n);
  }
}

/*-------------------------------------------------------------------------*/

void parcours_instr_si(n_instr *n)
{  
  operande *si = code3a_new_etiquette_auto();
  operande *fin = code3a_new_etiquette_auto();
  
  operande *exp = parcours_exp(n->u.si_.test);
  
  code3a_ajoute_instruction(jump_if_equal,exp,code3a_new_constante(0),si,NULL);
 
  parcours_instr(n->u.si_.alors);
  
  if(n->u.si_.sinon){
	code3a_ajoute_instruction(jump, fin, NULL, NULL, NULL);
	code3a_ajoute_etiquette(si->u.oper_nom);
    parcours_instr(n->u.si_.sinon);
  }
  
  code3a_ajoute_etiquette(fin->u.oper_nom);
}

/*-------------------------------------------------------------------------*/

void parcours_instr_tantque(n_instr *n)
{
  operande* debut = code3a_new_etiquette_auto();
  operande* fin = code3a_new_etiquette_auto();
  
  code3a_ajoute_etiquette(debut->u.oper_nom);
  
  operande* pour = parcours_exp(n->u.pour_.test);

  code3a_ajoute_instruction(jump_if_equal, pour, code3a_new_constante(0), fin, NULL);

  parcours_instr(n->u.pour_.faire);

  code3a_ajoute_instruction(jump, debut, NULL, NULL, NULL);

  code3a_ajoute_etiquette(fin->u.oper_nom);
  }

/*-------------------------------------------------------------------------*/

void parcours_instr_pour(n_instr *n)
{
  operande* debut = code3a_new_etiquette_auto();
  operande* fin = code3a_new_etiquette_auto();
  
  code3a_ajoute_etiquette(debut->u.oper_nom);
  
  operande* tantque = parcours_exp(n->u.tantque_.test);

  code3a_ajoute_instruction(jump_if_equal, tantque, code3a_new_constante(0), fin, NULL);

  parcours_instr(n->u.tantque_.faire);

  code3a_ajoute_instruction(jump, debut, NULL, NULL, NULL);

  code3a_ajoute_etiquette(fin->u.oper_nom);
  }
  
/*-------------------------------------------------------------------------*/  

void parcours_instr_affect(n_instr *n)
{
  operande* var = parcours_var(n->u.affecte_.var);
  operande* exp = parcours_exp(n->u.affecte_.exp);
  
  if(var->u.oper_var.oper_indice != NULL && var->u.oper_var.oper_indice->oper_type == O_VARIABLE) {
    operande* tmp1 = code3a_new_temporaire();
    code3a_ajoute_instruction(assign, var->u.oper_var.oper_indice, NULL, tmp1, NULL);
    var->u.oper_var.oper_indice = tmp1;
  }
  if(exp->oper_type == O_VARIABLE && exp->u.oper_var.oper_indice != NULL && exp->u.oper_var.oper_indice->oper_type == O_VARIABLE) {
    operande* tmp2 = code3a_new_temporaire();
    code3a_ajoute_instruction(assign, exp->u.oper_var.oper_indice, NULL, tmp2, NULL);
    exp->u.oper_var.oper_indice = tmp2;
  }
  
  code3a_ajoute_instruction(assign, exp, NULL, var, NULL);
}

/*-------------------------------------------------------------------------*/

void parcours_instr_appel(n_instr *n)
{
  parcours_appel(n->u.appel);
  code3a_ajoute_instruction(func_call, code3a_new_etiquette(n->u.appel->fonction), NULL, NULL, NULL);
}

/*-------------------------------------------------------------------------*/

int nb_argument(n_l_exp* liste){
	if(liste == NULL)
		return 0;

	if(liste->tete->type == varExp){
		operande* var = parcours_varExp(liste->tete);
		code3a_ajoute_instruction(func_param, var, NULL, NULL, NULL);
	}

	if(liste->tete->type == intExp){
		operande* intexp = parcours_intExp(liste->tete);
		code3a_ajoute_instruction(func_param, intexp, NULL, NULL, NULL);
	}
	if(liste->tete->type == opExp){
		operande* op = parcours_opExp(liste->tete);
		code3a_ajoute_instruction(func_param, op, NULL, NULL, NULL);
	}
	return nb_argument(liste->queue) + 1;
}

operande* parcours_appel(n_appel *n)
{
  code3a_ajoute_instruction(alloc, code3a_new_constante(1), NULL, NULL,"Allocation place pour valeur retour");
  int nbargument = nb_argument(n->args);
  if (rechercheExecutable(n->fonction) == -1){
	erreur("Fonction non declarée");
  }
  else if ( nbargument != tabsymboles.tab[rechercheExecutable(n->fonction)].complement){
	erreur("Nombre arguments incorrect");		  
  }
  //parcours_l_exp(n->args);
  operande* etiquette = code3a_new_temporaire();
  return etiquette;
}

/*-------------------------------------------------------------------------*/

void parcours_instr_retour(n_instr *n)
{
  operande* retour = parcours_exp(n->u.retour_.expression);
  code3a_ajoute_instruction(func_val_ret, retour, NULL, NULL, "Sauvegarder valeur retour");
  code3a_ajoute_instruction(func_end, NULL, NULL, NULL, "Terminer exécution fonction");
}

/*-------------------------------------------------------------------------*/

void parcours_instr_ecrire(n_instr *n)
{
  operande* ecrire = parcours_exp(n->u.ecrire_.expression);

  if(ecrire->oper_type == O_VARIABLE && ecrire->u.oper_var.oper_indice != NULL) {
    operande* temporaire = code3a_new_temporaire();
    code3a_ajoute_instruction(assign, ecrire->u.oper_var.oper_indice, NULL, temporaire, NULL);
    ecrire->u.oper_var.oper_indice = temporaire;
  }
  
  code3a_ajoute_instruction(sys_write, ecrire, NULL, NULL, NULL);  
}

/*-------------------------------------------------------------------------*/

void parcours_l_exp(n_l_exp *n)
{
  if(n){
    parcours_exp(n->tete);
    parcours_l_exp(n->queue);
  }
}

/*-------------------------------------------------------------------------*/

operande* parcours_exp(n_exp *n)
{
  operande* operande;
  if(n->type == varExp) operande = parcours_varExp(n);
  else if(n->type == opExp) operande = parcours_opExp(n);
  else if(n->type == intExp) operande = parcours_intExp(n);
  else if(n->type == appelExp) operande = parcours_appelExp(n);
  else if(n->type == lireExp) operande = parcours_lireExp(n);
  return operande;
}

/*-------------------------------------------------------------------------*/

operande* parcours_varExp(n_exp *n)
{
  operande* operande;
  operande = parcours_var(n->u.var);
  return operande;
}

/*-------------------------------------------------------------------------*/

operande* parcours_opExp(n_exp *n)
{	
  operande*  operande1 , *operande2;
  if( n->u.opExp_.op1 != NULL ) {
    operande1= parcours_exp(n->u.opExp_.op1);
  }
  if( n->u.opExp_.op2 != NULL ) {
    operande2 = parcours_exp(n->u.opExp_.op2);
  }
  
  if(operande1->oper_type == O_VARIABLE && operande1->u.oper_var.oper_indice != NULL && operande1->u.oper_var.oper_indice->oper_type == O_VARIABLE) {
    operande* tmp1 = code3a_new_temporaire();
    code3a_ajoute_instruction(assign, operande1->u.oper_var.oper_indice, NULL, tmp1, NULL);
    operande1->u.oper_var.oper_indice = tmp1;
  }
  if(operande2->oper_type == O_VARIABLE && operande2->u.oper_var.oper_indice != NULL && operande2->u.oper_var.oper_indice->oper_type == O_VARIABLE) {
    operande* tmp2 = code3a_new_temporaire();
    code3a_ajoute_instruction(assign, operande2->u.oper_var.oper_indice, NULL, tmp2, NULL);
    operande2->u.oper_var.oper_indice = tmp2;
  }
  instrcode operateur;
  
  switch (n->u.opExp_.op)
  {
    case plus :
      operateur = arith_add;
      break;
    case moins: 
      operateur = arith_sub;
      break;
    case fois: 
      operateur = arith_mult;
      break;
    case divise: 
      operateur = arith_div;
      break;
    case egal: 
      operateur = jump_if_equal;
      break;
    case inferieur: 
      operateur = jump_if_less;
      break;
    case ou: 
      operateur = jump_if_equal ;
      break;
    case et: 
      operateur = jump_if_equal;
      break;
    case non: 
      operateur = jump_if_equal;
      break;
  }
  if((n->u.opExp_.op) < egal) {
    operande* temporaire;
    temporaire = code3a_new_temporaire();
    code3a_ajoute_instruction(operateur, operande1, operande2, temporaire, NULL);
    return temporaire;
  }
  operande *exp = code3a_new_etiquette_auto();
  operande* temporaire = code3a_new_temporaire();
  code3a_ajoute_instruction(assign, code3a_new_constante(-1), NULL, temporaire, NULL);
  code3a_ajoute_instruction(operateur,operande1,operande2,exp,NULL);
  code3a_ajoute_instruction(assign, code3a_new_constante(0), NULL, temporaire, NULL);
  code3a_ajoute_etiquette(exp->u.oper_nom);  
  return temporaire;
}

/*-------------------------------------------------------------------------*/

operande* parcours_intExp(n_exp *n)
{
  operande* constante;
  constante = code3a_new_constante(n->u.entier);
  return constante;
}

/*-------------------------------------------------------------------------*/
operande* parcours_lireExp(n_exp *n)
{
  operande* temporaire = code3a_new_temporaire();
  code3a_ajoute_instruction(sys_read, NULL, NULL, temporaire, NULL);
  return temporaire;
}

/*-------------------------------------------------------------------------*/


operande* parcours_appelExp(n_exp *n)
{	
  operande* appel = parcours_appel(n->u.appel);
  char* nom = malloc(102*sizeof(char));
  sprintf (nom,"f%s",n->u.appel->fonction);
  code3a_ajoute_instruction(func_call, code3a_new_etiquette(nom), NULL, appel, NULL);
  return appel;
}

/*-------------------------------------------------------------------------*/

void parcours_l_dec(n_l_dec *n)
{
  if( n ){
    parcours_dec(n->tete);
    parcours_l_dec(n->queue);
  }
}

/*-------------------------------------------------------------------------*/

void parcours_dec(n_dec *n)
{
  if(n){
    if(n->type == foncDec) {
      parcours_foncDec(n);
    }
    else if(n->type == varDec) {
      parcours_varDec(n);
    }
    else if(n->type == tabDec) { 
      parcours_tabDec(n);
    }
  }
}

/*-------------------------------------------------------------------------*/
int nb_param(n_l_dec* liste){
	int n = 0;
	while(liste != NULL){
		n++;
		liste = liste->queue;
	}
	return n;
}

void parcours_foncDec(n_dec *n)
{
	if(rechercheDeclarative(n->nom) ==-1 ){
		int nbparam = nb_param (n->u.foncDec_.param);
		ajouteIdentificateur(n->nom,P_VARIABLE_GLOBALE,T_FONCTION,0, nbparam);
		tabsymboles.base++;
		entreeFonction();
		char* nom = malloc(102*sizeof(char));
		sprintf (nom,"f%s",n->nom);
		code3a_ajoute_etiquette(nom);
		code3a_ajoute_instruction(func_begin, NULL, NULL, NULL, NULL);
		parcours_l_dec(n->u.foncDec_.param);
		portee = P_VARIABLE_LOCALE;
		parcours_l_dec(n->u.foncDec_.variables);
		parcours_instr(n->u.foncDec_.corps);
		sortieFonction(affichetab);
		code3a_ajoute_instruction(func_end, NULL, NULL, NULL, NULL);
	}
	else 
		erreur("fonction déjà declarée");
}

/*-------------------------------------------------------------------------*/

void parcours_varDec(n_dec *n)
{
  if (rechercheDeclarative(n->nom) == -1) { 
    if (portee == P_VARIABLE_GLOBALE)
    {
		code3a_ajoute_instruction(alloc, code3a_new_constante(1), code3a_new_var(n->nom, portee, adresseGlobaleCourante), NULL, n->nom);
        ajouteIdentificateur(n->nom, portee, T_ENTIER, adresseGlobaleCourante, 1);
        tabsymboles.base++;
        adresseGlobaleCourante = adresseGlobaleCourante +4 ;
    }
    else if (portee == P_VARIABLE_LOCALE)
    {
		code3a_ajoute_instruction(alloc, code3a_new_constante(1), code3a_new_var(n->nom, portee, adresseLocaleCourante), NULL, n->nom);
        ajouteIdentificateur(n->nom, portee, T_ENTIER, adresseLocaleCourante, 1);
        adresseLocaleCourante = adresseLocaleCourante +4  ;
    }
    else if (portee == P_ARGUMENT)
    {
      ajouteIdentificateur(n->nom, portee, T_ENTIER, adresseArgumentCourant, 1);
      adresseArgumentCourant = adresseArgumentCourant +4;
    }
  }
  else erreur("Variable deja declarée");
}

/*-------------------------------------------------------------------------*/

void parcours_tabDec(n_dec *n)
{
  int result = rechercheDeclarative(n->nom);
  if (result == -1) {
    if (portee != P_VARIABLE_GLOBALE) 
		erreur("Un tableau est toujours une variable globale");
    ajouteIdentificateur(n->nom, portee, T_TABLEAU_ENTIER, adresseGlobaleCourante, n->u.tabDec_.taille);
    tabsymboles.base++;
    adresseGlobaleCourante += n->u.tabDec_.taille*4;
	code3a_ajoute_instruction(alloc, code3a_new_constante(n->u.tabDec_.taille), code3a_new_var(n->nom, portee, adresseGlobaleCourante), NULL, n->nom); 
  }
  else erreur("Tableau deja declaré");
}

/*-------------------------------------------------------------------------*/

operande* parcours_var(n_var *n)
{
  operande* operande;	
  if(n->type == simple) {
    operande = parcours_var_simple(n);
  }
  else if(n->type == indicee) {
	operande = parcours_var_indicee(n);
  }
  return operande;
}

/*-------------------------------------------------------------------------*/

operande* parcours_var_simple(n_var *n)
{
  if (rechercheExecutable(n->nom) == -1) 
	  erreur("Variable non declarée");
  else if (tabsymboles.tab[rechercheExecutable(n->nom)].type == T_TABLEAU_ENTIER) 
	  erreur("Tableau non indicé");
  operande* operande = code3a_new_var(n->nom, tabsymboles.tab[rechercheExecutable(n->nom)].portee, tabsymboles.tab[rechercheExecutable(n->nom)].adresse);
  return operande;
}

/*-------------------------------------------------------------------------*/

operande* parcours_var_indicee(n_var *n)
{
  if (rechercheExecutable(n->nom) == -1) 
	  erreur("Variable non declarée");
  else if (tabsymboles.tab[rechercheExecutable(n->nom)].type == T_ENTIER) {
	  erreur("Ce n'est pas un tableau");
  }
  operande* var = code3a_new_var(n->nom, tabsymboles.tab[rechercheExecutable(n->nom)].portee, tabsymboles.tab[rechercheExecutable(n->nom)].adresse);
  operande* indice = parcours_exp( n->u.indicee_.indice );
  var->u.oper_var.oper_indice = indice;

  return var;
}


