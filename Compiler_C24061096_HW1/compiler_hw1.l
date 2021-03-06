/* Definition section */
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    #define YY_NO_UNPUT
    #define YY_NO_INPUT

    int line_num = 0;
    int comment_num = 0;
    char buff[2];
    int over = 0;
%}

/* Define regular expression label */
%x string_const
%x C_COMMENT
%x CPLUS_COMMENT
letter [a-zA-Z_]
digit [0-9]
id {letter}+({letter}|{digit})*
inumber {digit}+
fnumber ({digit}*\.{digit}+)
string_constants ([^"]|\"\")*
comment "/*"([^*]|\*+[^*/])*"*/" 
single_comment "//"([^\n])*"\n"



/* Rules section */
%%

"\""			{ BEGIN(string_const); printf("%-8s \t %s\n", yytext, "QUOTA");}
<string_const>"\\\""	{ ECHO; }
<string_const>"\""	{ BEGIN(INITIAL); printf("%-8s \t QUOTA\n", yytext);}
<string_const>([^"]|\"\")*	{ printf("%-8s \t %s\n", yytext, "STRING"); }



"/*"			{ BEGIN(C_COMMENT); ECHO; }
<C_COMMENT>\n		{ comment_num++; line_num++; ECHO; printf("        \t %s\n","C Comment");  }
<C_COMMENT>[^*\n]+	{ ECHO; }
<C_COMMENT>"*/"		{ ECHO; BEGIN(INITIAL); printf("       \t C Comment\n"); over=1;}
<C_COMMENT>"*/"\n	{ BEGIN(INITIAL); comment_num++; line_num++; printf("%-8s \t C Comment\n","*/"); printf("%-8s \t %s\n", " ", "NEWLINE"); }

<C_COMMENT>.		{ ECHO; }


"//"	{ BEGIN(CPLUS_COMMENT); ECHO;  }
<CPLUS_COMMENT>\n	{ BEGIN(INITIAL); comment_num++; line_num++; printf(" \t C++ Comment\n%-8s \t %s\n", " ", "NEWLINE"); }
<CPLUS_COMMENT>.	{ ECHO; }


"+"         { printf("%-8s \t %s\n", yytext, "ADD"); }
"-"         { printf("%-8s \t %s\n", yytext, "SUB"); }
"*"         { printf("%-8s \t %s\n", yytext, "MUL"); }          
"/"         { printf("%-8s \t %s\n", yytext, "QUO"); }
"%"         { printf("%-8s \t %s\n", yytext, "REM"); }
"++"        { printf("%-8s \t %s\n", yytext, "INC"); }
"--"        { printf("%-8s \t %s\n", yytext, "DEC"); }
">"         { printf("%-8s \t %s\n", yytext, "GTR"); }
"<" 	    { printf("%-8s \t %s\n", yytext, "LSS"); }
">="	    { printf("%-8s \t %s\n", yytext, "GEQ"); }
"<=" 	    { printf("%-8s \t %s\n", yytext, "LEQ"); }
"=="	    { printf("%-8s \t %s\n", yytext, "EQL"); }
"!=" 	    { printf("%-8s \t %s\n", yytext, "NEQ"); }
"=" 	    { printf("%-8s \t %s\n", yytext, "ASSIGN"); }
"+="	    { printf("%-8s \t %s\n", yytext, "ADD_ASSIGN"); }
"-=" 	    { printf("%-8s \t %s\n", yytext, "SUB_ASSIGN"); }
"*="	    { printf("%-8s \t %s\n", yytext, "MUL_ASSIGN"); }
"/=" 	    { printf("%-8s \t %s\n", yytext, "QUO_ASSIGN"); }
"%="        { printf("%-8s \t %s\n", yytext, "REM_ASSIGN"); }
"&&"        { printf("%-8s \t %s\n", yytext, "LAND"); }
"||"	    { printf("%-8s \t %s\n", yytext, "LOR"); }
"!" 	    { printf("%-8s \t %s\n", yytext, "NOT"); }
"("	    { printf("%-8s \t %s\n", yytext, "LPAREN"); }	
")" 	    { printf("%-8s \t %s\n", yytext, "RPAREN"); }
"["         { printf("%-8s \t %s\n", yytext, "LBRACK"); }
"]"         { printf("%-8s \t %s\n", yytext, "RBRACKN"); }
"{"	    { printf("%-8s \t %s\n", yytext, "LBRACE"); }	
"}" 	    { printf("%-8s \t %s\n", yytext, "RBRACE"); }
";"         { printf("%-8s \t %s\n", yytext, "SEMICOLON"); }
","         { printf("%-8s \t %s\n", yytext, "COMMA"); }

\n	    { printf("%-8s \t %s\n", " "   , "NEWLINE");
		line_num++;}


"print"     { printf("%-8s \t %s\n", yytext, "PRINT"); }
"println"   { printf("%-8s \t %s\n", yytext, "PRINTLN"); }
"if"	    { printf("%-8s \t %s\n", yytext, "IF"); }
"else" 	    { printf("%-8s \t %s\n", yytext, "ELSE"); }
"for"	    { printf("%-8s \t %s\n", yytext, "FOR"); }
"int32"     { printf("%-8s \t %s\n", yytext, "INT"); }
"float32"   { printf("%-8s \t %s\n", yytext, "FLOAT"); }
"string"    { printf("%-8s \t %s\n", yytext, "STRING"); }
"bool"      { printf("%-8s \t %s\n", yytext, "BOOL"); }
"true"      { printf("%-8s \t %s\n", yytext, "TRUE"); }
"false"     { printf("%-8s \t %s\n", yytext, "FALSE"); }
"var"       { printf("%-8s \t %s\n", yytext, "VAR"); }

{fnumber}   { printf("%-8s \t %s\n", yytext, "FLOAT_LIT"); }
{inumber}   { printf("%-8s \t %s\n", yytext, "INT_LIT"); }
{id}        { printf("%-8s \t %s\n", yytext, "IDENT"); }




<<EOF>>     { line_num++; 
		if(over==1){
			comment_num++;
		}
		yyterminate(); 		
		}
.           {;over = 0;}

%%

/*  C Code section */
int yywrap(void)
{
    return 1;
}

int main(int argc, char *argv[])
{
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
    } else {
        yyin = stdin;
    }
    yylex();
    printf("\nFinish scanning,\n");
    printf("total line: %d\n", line_num);
    printf("comment line: %d\n", comment_num);
//	printf("buff %s\n",buff);
    fclose(yyin);
    return 0;
}
