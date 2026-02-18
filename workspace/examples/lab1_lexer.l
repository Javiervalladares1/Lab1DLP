%{
#include <stdio.h>

int line = 1;
int col = 1;

static void print_token(const char *type, const char *value, int token_col) {
    printf("Token(%s, \"%s\", line=%d, col=%d)\n", type, value, line, token_col);
}

static void print_error(const char *message, const char *value, int token_col) {
    fprintf(stderr, "LexicalError(%s, \"%s\", line=%d, col=%d)\n", message, value, line, token_col);
}
%}

%option noyywrap
%x CCOMMENT

DIGIT         [0-9]
HEX           0[xX][0-9a-fA-F]+
EXP           [eE][+-]?{DIGIT}+
FLOAT_BASE    ({DIGIT}+\.{DIGIT}*)|({DIGIT}*\.{DIGIT}+)
SCIENTIFIC    ({FLOAT_BASE}|{DIGIT}+){EXP}
FLOAT         {FLOAT_BASE}
INTEGER       {DIGIT}+

LETTER        [A-Za-z_]
IDENTIFIER    {LETTER}({LETTER}|{DIGIT})*

VALID_STRING  \"([^\"\\\n]|\\[nt\"\\])*\"
ANY_STRING    \"([^\"\\\n]|\\.)*\"

WS            [ \t\r]+

%%

"//".*        { col += yyleng; }
"/*"          { col += yyleng; BEGIN(CCOMMENT); }

<CCOMMENT>"*/" { col += yyleng; BEGIN(INITIAL); }
<CCOMMENT>\n   { line++; col = 1; }
<CCOMMENT>.    { col += yyleng; }
<CCOMMENT><<EOF>> {
    print_error("unterminated_comment", "/*", col);
    return 1;
}

\"([^\"\\\n]|\\.)*\n {
    int token_col = col;
    print_error("unterminated_string", yytext, token_col);
    line++;
    col = 1;
}

{VALID_STRING} {
    int token_col = col;
    print_token("STRING_LITERAL", yytext, token_col);
    col += yyleng;
}

{ANY_STRING} {
    int token_col = col;
    print_error("invalid_escape_sequence", yytext, token_col);
    col += yyleng;
}

{HEX} {
    int token_col = col;
    print_token("HEX_LITERAL", yytext, token_col);
    col += yyleng;
}

{SCIENTIFIC} {
    int token_col = col;
    print_token("SCIENTIFIC_LITERAL", yytext, token_col);
    col += yyleng;
}

{FLOAT} {
    int token_col = col;
    print_token("FLOAT_LITERAL", yytext, token_col);
    col += yyleng;
}

{INTEGER} {
    int token_col = col;
    print_token("INTEGER_LITERAL", yytext, token_col);
    col += yyleng;
}

"==" {
    int token_col = col;
    print_token("REL_EQ", yytext, token_col);
    col += yyleng;
}

"!=" {
    int token_col = col;
    print_token("REL_NEQ", yytext, token_col);
    col += yyleng;
}

"<=" {
    int token_col = col;
    print_token("REL_LTE", yytext, token_col);
    col += yyleng;
}

">=" {
    int token_col = col;
    print_token("REL_GTE", yytext, token_col);
    col += yyleng;
}

"<" {
    int token_col = col;
    print_token("REL_LT", yytext, token_col);
    col += yyleng;
}

">" {
    int token_col = col;
    print_token("REL_GT", yytext, token_col);
    col += yyleng;
}

"&&" {
    int token_col = col;
    print_token("LOG_AND", yytext, token_col);
    col += yyleng;
}

"||" {
    int token_col = col;
    print_token("LOG_OR", yytext, token_col);
    col += yyleng;
}

"!" {
    int token_col = col;
    print_token("LOG_NOT", yytext, token_col);
    col += yyleng;
}

"+" {
    int token_col = col;
    print_token("ARITH_PLUS", yytext, token_col);
    col += yyleng;
}

"-" {
    int token_col = col;
    print_token("ARITH_MINUS", yytext, token_col);
    col += yyleng;
}

"*" {
    int token_col = col;
    print_token("ARITH_MULT", yytext, token_col);
    col += yyleng;
}

"/" {
    int token_col = col;
    print_token("ARITH_DIV", yytext, token_col);
    col += yyleng;
}

"=" {
    int token_col = col;
    print_token("ASSIGN", yytext, token_col);
    col += yyleng;
}

";" {
    int token_col = col;
    print_token("SEMICOLON", yytext, token_col);
    col += yyleng;
}

"(" {
    int token_col = col;
    print_token("LPAREN", yytext, token_col);
    col += yyleng;
}

")" {
    int token_col = col;
    print_token("RPAREN", yytext, token_col);
    col += yyleng;
}

"{" {
    int token_col = col;
    print_token("LBRACE", yytext, token_col);
    col += yyleng;
}

"}" {
    int token_col = col;
    print_token("RBRACE", yytext, token_col);
    col += yyleng;
}

{IDENTIFIER} {
    int token_col = col;
    print_token("IDENTIFIER", yytext, token_col);
    col += yyleng;
}

{WS}          { col += yyleng; }
\n            { line++; col = 1; }

. {
    int token_col = col;
    print_error("invalid_character", yytext, token_col);
    col += yyleng;
}

%%

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
