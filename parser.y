%{
#include "adt/primitive.h"
#include "calc.h"
#include <stdio.h>
extern int lineno;
extern int yylex(void);
void yyerror(char *s) {
  fprintf(stderr, "%d: %s\n", lineno, s);
}
expr* root;
%}
%union {
  long lval;
  struct expr_struct *eval;
}
%token <lval> INT
%type <eval> prog expr term fact
%start prog
%%
prog    : expr          { root = $1; }
expr    : term          { $$ = $1; }
        | expr '+' term { $$ = mkEADD($1,$3); }
        | expr '-' term { $$ = mkESUB($1,$3); }
term    : fact          { $$ = $1; }
        | term '*' fact { $$ = mkEMUL($1,$3); }
        | term '/' fact { $$ = mkEDIV($1,$3); }
fact    : INT           { $$ = mkEINT($1); }
        | '(' expr ')'  { $$ = $2; }
