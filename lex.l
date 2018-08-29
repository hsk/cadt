%{
#include "adt/primitive.h"
#include "calc.h"
int lineno;
int yywrap(void) { return 1; }
#include "parser.tab.h"
%}
%%
[\ \t]        { lineno++ ; }
[0-9]+        { yylval.lval=atol(yytext); return INT; }
\+            { return *yytext; }
-             { return *yytext; }
\*            { return *yytext; }
\/            { return *yytext; }
\(            { return *yytext; }
\)            { return *yytext; }
<<EOF>>       { return 0; }
.             { return *yytext; }
