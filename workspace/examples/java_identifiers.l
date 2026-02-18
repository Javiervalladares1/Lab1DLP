%{
#include <stdio.h>

int line = 1;
int col = 1;

static void print_token(const char *type, const char *value, int token_col) {
    printf("Token(%s, \"%s\", line=%d, col=%d)\n", type, value, line, token_col);
}
%}

DIGIT       [0-9]
LETTER      [A-Za-z_]
JAVA_ID     {LETTER}({LETTER}|{DIGIT})*
WS          [ \t\r]+

%%

{JAVA_ID}   { int token_col = col; print_token("JAVA_IDENTIFIER", yytext, token_col); col += yyleng; }
{WS}        { col += yyleng; }
\n          { line++; col = 1; }
.           { int token_col = col; print_token("INVALID_CHAR", yytext, token_col); col += yyleng; }

%%

int yywrap(void) {
    return 1;
}

int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            fprintf(stderr, "Cannot open file: %s\n", argv[1]);
            return 1;
        }
    }

    yylex();

    if (argc > 1) {
        fclose(yyin);
    }
    return 0;
}
