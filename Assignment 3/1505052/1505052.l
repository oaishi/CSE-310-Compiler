%{
#include <bits/stdc++.h>
#include "SymbolTable.h"
#include "y.tab.h"

using namespace std;

extern YYSTYPE yylval;
extern SymbolTable *table ;
void yyerror(const char *);
int newlinecount;
int linecount = 1;
int errorcount = 0;
extern FILE *tokenout;
/*void FindAndReplace(string & data, string toSearch, string replaceStr)
{
	size_t pos = data.find(toSearch);
    while( pos != std::string::npos)
	{
		data.replace(pos, toSearch.size(), replaceStr);
		pos =data.find(toSearch, pos + toSearch.size());
	}
}*/

%}

Numeric [0-9]
AlphaNumeric [A-Za-z0-9_]
AlphaDash [A-Za-z_]
delim [ \t\r\f\v]
%%
{delim}+	{}
[\n]			 {linecount++;} 
"if" {fprintf(tokenout,"<IF, %s> ",yytext);return IF;}
"else" {fprintf(tokenout,"<ELSE, %s> ",yytext);return ELSE;}
"for" {fprintf(tokenout,"<FOR, %s> ",yytext);return FOR;}
"while" {fprintf(tokenout,"<WHILE, %s> ",yytext);return WHILE;}
"int" {fprintf(tokenout,"<INT, %s> ",yytext);return INT;}
"float" {fprintf(tokenout,"<FLOAT, %s> ",yytext);return FLOAT;}
"return" {fprintf(tokenout,"<RETURN, %s> ",yytext);return RETURN;}
"void" {fprintf(tokenout,"<VOID, %s> ",yytext);return VOID;}
"println"|"printf"	{fprintf(tokenout,"<PRINT, %s> ",yytext);SymbolInfo *s= new  SymbolInfo(yytext, "PRINTLN");
			yylval.info = s;
			return PRINTLN;}

[+-]			{	fprintf(tokenout,"<ADDOP, %s> ",yytext);SymbolInfo *s= new  SymbolInfo(yytext, "ADDOP");
			yylval.info = s;
			return ADDOP;}

[*/%]			{	fprintf(tokenout,"<MULOP, %s> ",yytext);SymbolInfo *s= new  SymbolInfo(yytext, "MULOP");
			yylval.info = s;
			return MULOP;}

"++" 			{fprintf(tokenout,"<INCOP, %s> ",yytext);return INCOP;}

"--" 			{fprintf(tokenout,"<DECOP, %s> ",yytext);return DECOP;}

(<|<=|>|>=|==|!=)	 {	fprintf(tokenout,"<RELOP, %s> ",yytext);SymbolInfo *s= new  SymbolInfo(yytext, "RELOP");
			yylval.info = s;
			return RELOP;	}

"=" 			{fprintf(tokenout,"<ASSIGNOP, %s> ",yytext);return ASSIGNOP;}

"&&"|"||"		{	fprintf(tokenout,"<LOGICOP, %s> ",yytext);SymbolInfo *s= new  SymbolInfo(yytext, "LOGICOP");
			yylval.info = s;
			return LOGICOP;}

"!"		{	fprintf(tokenout,"<NOT, %s> ",yytext);return NOT; }
"(" 	{fprintf(tokenout,"<LPAREN, %s> ",yytext);return LPAREN;}
")" 	{fprintf(tokenout,"<RPAREN, %s> ",yytext);return RPAREN;}
[{]	{fprintf(tokenout,"<LCURL, %s> ",yytext);
	return LCURL;}
[}] 	{fprintf(tokenout,"<RCURL, %s> ",yytext);
	return RCURL;}
"[" 	{fprintf(tokenout,"<LTHIRD, %s> ",yytext);return LTHIRD;}
"]" 	{fprintf(tokenout,"<RTHIRD, %s> ",yytext);return RTHIRD;}
[;]	{ fprintf(tokenout,"<SEMICOLON, %s> ",yytext);
	return SEMICOLON;}	
"," 	{fprintf(tokenout,"<COMMA, %s> ",yytext);return COMMA;}

{Numeric}+	{fprintf(tokenout,"<CONST_INT, %s> ",yytext);SymbolInfo *s= new  SymbolInfo(yytext, "CONST_INT");
				yylval.info = s;
				return CONST_INT;}

{Numeric}*[.]?{Numeric}+(E[-]?{Numeric}+)?	{	fprintf(tokenout,"<CONST_FLOAT, %s> ",yytext);
				SymbolInfo *s= new  SymbolInfo(yytext, "CONST_FLOAT");
				yylval.info = s;
				return CONST_FLOAT; }

{AlphaDash}{AlphaNumeric}* 	{fprintf(tokenout,"\n\n<ID, %s> \n",yytext);
				//table->Insert(yytext,"ID");
				SymbolInfo *s = new SymbolInfo(yytext,"ID");
				yylval.info = s;			
				return ID;}

{Numeric}+{AlphaDash}+		{//errorcount++;
fprintf(tokenout ,"Error %d at Line %d :Invalid Suffix on numeric constant or invalid prefix on identifier for character sequence %s \n",errorcount,linecount , yytext);}

-?{Numeric}*[.]{Numeric}*([.]{Numeric}*)+	{//errorcount++;
fprintf(tokenout ,"Error %d at Line %d : Too many decimal point error %s \n",errorcount,linecount , yytext);}

-?{Numeric}*([.]{Numeric}*)*(E(-)*{Numeric}*[.]+(-)*{Numeric}*[.]*(-)*{Numeric}*)+				{//errorcount++;
fprintf(tokenout ,"Error %d at Line %d : Ill formed number %s \n",errorcount,linecount , yytext);}


['][^ \n][']			{if(yytext[1]=='\\'||yytext[1]=='\''){//errorcount++;
fprintf(tokenout ,"Error %d at Line %d : Unfinished character %s found\n",errorcount,linecount,yytext);}
else
fprintf(tokenout ,"Line %d : Token <CONST_CHAR> Lexeme %s found\n",linecount , yytext);
				/*string line(yytext);
    				stringstream iss(line);
    				string segment;
				getline(iss, segment, '\'');
				getline(iss, segment, '\'');
				fprintf(tokenout,"<CONST_CHAR, %s> ",segment.c_str());
				bool flag = symboltable->Insert(yytext,"CONST_CHAR");
				if(flag)symboltable->PrintAll();}*/}

['][\\][^ \n'][']		{char chr = 's';
				if(yytext[2]=='\'') chr = '\'';
				else if(yytext[2]=='n')	chr = '\n';
				else if(yytext[2]=='t') chr = '\t';
				else if(yytext[2]=='\\') chr = '\\';
				else if(yytext[2]=='a') chr = '\a';
				else if(yytext[2]=='f') chr = '\f';
				else if(yytext[2]=='r') chr = '\r';
				else if(yytext[2]=='b') chr = '\b';
				else if(yytext[2]=='v') chr = '\v';
				else if(yytext[2]=='0') chr = '\0';
				if(chr == 's'){//errorcount++;
				fprintf(tokenout ,"Error %d at Line %d : Unrecognized character %s  found\n",errorcount,linecount,yytext);}
				else{
				fprintf(tokenout ,"Line %d : Token <CONST_CHAR> Lexeme %s found\n",linecount , yytext);
				/*char *rough = (char*) malloc(2*sizeof(char));
				rough[0] = chr;
				rough[1] = '\0';
				fprintf(tokenout,"<CONST_CHAR, %s> ",rough);
				free(rough);
				bool flag = symboltable->Insert(yytext,"CONST_CHAR");
				if(flag)symboltable->PrintAll();*/
				}}

['][^']*		{//errorcount++;
fprintf(tokenout ,"Error %d at Line %d : Unfinished character %s found\n",errorcount,linecount,yytext);}

['][^\\][^\\']+[']			{//errorcount++;
fprintf(tokenout ,"Error %d at Line %d : Multi character constant error for %s character sequence\n",errorcount,linecount,yytext);}

\"((\\)(\\n)|[^"\n])*\"  	{fprintf(tokenout ,"Line %d : Token <STRING> Lexeme %s found\n",linecount , yytext);
				string line(yytext);
    				stringstream iss(line);
    				string segment;
    				while(getline(iss, segment, '\n'))
   				linecount++;
				linecount--;
				/*FindAndReplace(line, "\\\\n", "\n");
				FindAndReplace(line, "\\n", "\n");	
				FindAndReplace(line, "\\t", "\t");
				FindAndReplace(line, "\\\\", "\\");
				//FindAndReplace(line, "\\a", "\a");
				//FindAndReplace(line, "\\f", "\f");
				//FindAndReplace(line, "\\r", "\r");
				//FindAndReplace(line, "\\b", "\b");
				//FindAndReplace(line, "\\v", "\v");
				FindAndReplace(line, "\\0", "\0");
				fprintf(tokenout,"<STRING, %s> ",line.c_str());*/}

"//".*("\\\n".*)*		{fprintf(tokenout ," %d :  <COMMENT , %s >\n",linecount , yytext);}

[/][*][^*]*[*]+([^*/][^*]*[*]+)*[/]     {string line(yytext);
    					stringstream iss(line);
    					string segment;
    					fprintf(tokenout ,"Line %d : Token <COMMENT> Lexeme %s found\n",linecount , yytext);
					while(getline(iss, segment, '\n'))
   					linecount++;
					linecount--;}

[/][*]([^*]*[\n]*)*[*]*([^*]*[\n]*)*[*]*	{string line(yytext);
    					stringstream iss(line);
    					string segment;
					//errorcount++;
    					fprintf(tokenout ,"Error %d at Line %d : Unfinished comment %s found\n",errorcount,linecount,yytext);
					while(getline(iss, segment, '\n'))
   					{linecount++;
    					}
					linecount--;}

.		{//errorcount++;
		char msg[20000];
		sprintf(msg,"Unrecognized character %s found",yytext);
		yyerror(msg);
/*fprintf(logout ,"Error %d at Line %d : Unrecognized Charater %s found\n",errorcount,linecount , yytext);
				string line(yytext);*/}
%%

/*int yywrap(void)
{
	return 1;
}*/



