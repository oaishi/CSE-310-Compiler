%{
#include <bits/stdc++.h>
#include "SymbolTable.h"

using namespace std;
int yyparse(void);
int yylex(void);
extern FILE *yyin;
FILE *fp, *fp2 , *fp3;
SymbolTable *table = new SymbolTable(50);
extern int linecount;
extern int errorcount;
extern int newlinecount;
extern char* yytext;
FILE *tokenout;
SymbolInfo *param;
void yyerror(const char *s)
{
	errorcount++;
	fprintf(fp3,"\nError at Line %d : %s %s\n\n",linecount,s,yytext);
	return;
}

void yyerror1(char *s)
{
	fprintf(fp3,"\nError at Line %d : %s \n\n",linecount,s);
	return;
}

%}

%union { SymbolInfo* info; char *str;  }
%token IF ELSE FOR WHILE INT FLOAT RETURN VOID ASSIGNOP NOT COMMA LPAREN RPAREN LTHIRD RTHIRD INCOP DECOP
%token RCURL
%token SEMICOLON
%token LCURL
%token <info> ID
%token <info> PRINTLN
%token <info> CONST_FLOAT
%token <info> CONST_INT
%token <info> LOGICOP
%token <info> RELOP
%token <info> MULOP
%token <info> ADDOP

%type <info> start
%type <info> program
%type <info> unit
%type <info> func_declaration
%type <info> func_definition
%type <info> parameter_list
%type <info> compound_statement
%type <info> var_declaration
%type <info> type_specifier
%type <info> declaration_list
%type <info> statements
%type <info> statement
%type <info> expression_statement
%type <info> variable
%type <info> expression
%type <info> logic_expression
%type <info> rel_expression
%type <info> simple_expression
%type <info> term
%type <info> unary_expression
%type <info> factor
%type <info> argument_list
%type <info> arguments
%define parse.lac full
%define parse.error verbose
//%left 
//%right

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE 


%%

start : program
	{
		fprintf(fp2 , "At line %d : start-> program\n",linecount);
		$$ = new SymbolInfo();
		$$->SetName($1->GetName());
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}
	;

program : program unit 
	{
		fprintf(fp2 , "At line %d : program->program unit\n",linecount);
		$$ = new SymbolInfo();
		$$->SetName($1->GetName()+" "+$2->GetName());
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}
	| unit
	{
		fprintf(fp2 , "At line %d : program-> unit\n",linecount);
		$$ = new SymbolInfo();
		$$->SetName($1->GetName());
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}
	;
	
unit : var_declaration
	{
		fprintf(fp2 , "At line %d : unit-> var_declaration\n",linecount);
		$$ = new SymbolInfo();
		$$->SetName($1->GetName());
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}
     | func_declaration
	{
		fprintf(fp2 , "At line %d : unit-> func_declaration\n",linecount);
		$$ = new SymbolInfo();
		$$->SetName($1->GetName());
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}
     | func_definition
	{
		fprintf(fp2 , "At line %d : unit-> func_definition\n",linecount);
		$$ = new SymbolInfo();
		$$->SetName($1->GetName());
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
	{
		table->PrintAll(fp2);
		SymbolInfo *s = table->LookUp($2->GetName());
		$$ = new SymbolInfo();
		if(s->GetName().empty()){
		table->Insert($2->GetName(),"ID");
		s = table->LookUp($2->GetName());
		s->SetParam($4);
		s->SetReturnType($1->GetType());
		s->flag=0;}
		else if(s->GetName().compare($2->GetName())==0){//check params
		if(s->flag){
		char msg[50];errorcount++;
		sprintf(msg,"%s","Multiple Declaration of Function");
		yyerror1(msg);}
		else{
		char msg[50];errorcount++;
		sprintf(msg,"%s","Function Already Defined");
		yyerror1(msg);}
		}
		else{table->Insert($2->GetName(),"ID");
		s = table->LookUp($2->GetName());
		s->SetParam($4);
		s->SetReturnType($1->GetType());
		s->flag=0;
		}
		fprintf(fp2 , "At line %d : func_declaration-> type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n",linecount);
		$$->SetName($1->GetName()+" "+$2->GetName()+" "+"("+$4->GetDef()+");\n");
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}

		|type_specifier ID LPAREN parameter_list RPAREN error
	{	$$->SetName($1->GetName()+" "+$2->GetName()+" "+"("+$4->GetDef()+")\n");
		cout<<"error"<<endl;}


		| type_specifier ID LPAREN RPAREN SEMICOLON
	{
		SymbolInfo *s = table->LookUp($2->GetName());
		if(s->GetName().empty()){
		table->Insert($2->GetName(),"ID");
		s = table->LookUp($2->GetName());
		s->parameter = NULL;
		s->SetReturnType($1->GetType());
		s->flag=0;}
		else if(s->GetName().compare($2->GetName())==0){
		if(s->flag){
		char msg[50];errorcount++;
		sprintf(msg,"%s","Multiple Declaration of Function");
		yyerror1(msg);}
		else{
		char msg[50];errorcount++;
		sprintf(msg,"%s","Function Already Defined");
		yyerror1(msg);}
		}
		else
		{table->Insert($2->GetName(),"ID");
		s = table->LookUp($2->GetName());
		s->parameter = NULL;
		s->SetReturnType($1->GetType());
		s->flag=0;
		}
		$$ = new SymbolInfo();
		fprintf(fp2 , "At line %d : func_declaration-> type_specifier ID LPAREN RPAREN SEMICOLON\n",linecount);
		$$->SetName($1->GetName()+" "+$2->GetName()+"();\n");
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}

			|type_specifier ID LPAREN RPAREN error
	{	$$->SetName($1->GetName()+" "+$2->GetName()+" "+"( )\n");
		cout<<"error"<<endl;}
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN 
		{SymbolInfo *s = table->LookUp($2->GetName());
		param = $4;
		if(s->GetName().empty()){
		table->Insert($2->GetName(),"ID");
		s = table->LookUp($2->GetName());
		s->SetParam($4);
		s->SetReturnType($1->GetType());
		s->flag=1;}
		else if(s->GetName().compare($2->GetName())==0){//check params
		if(s->flag==1){//check flag
		char msg[50];errorcount++;
		sprintf(msg,"%s","Function Already Defined");
		yyerror1(msg);
		}
		else if(s->flag==0 && s->Match($4) && s->GetReturnType().compare($1->GetType())==0)
		{s->flag=1;}
		else if(s->GetReturnType().compare($1->GetType())!=0)
		{char msg[50];errorcount++;
		sprintf(msg,"%s","Return Type Does not Match");
		yyerror1(msg);}
		else{char msg[50];errorcount++;
		sprintf(msg,"%s","Multiple Definition of Function");
		yyerror1(msg);}

		}
		else{table->Insert($2->GetName(),"ID");
		s = table->LookUp($2->GetName());
		s->SetParam($4);
		s->SetReturnType($1->GetType());
		s->flag=1;
		}

		} compound_statement
		{$$ = new SymbolInfo();
		SymbolInfo *s = table->LookUp($2->GetName());
		//cout<<s->GetReturnType()<<" "<<$7->GetType(); //check return type here
		if(s->GetReturnType().compare($7->GetType())!=0){char msg[50];errorcount++;
		sprintf(msg,"%s","Return Type Does not Match");
		yyerror1(msg);}
		fprintf(fp2 , "At line %d : func_definition-> type_specifier ID LPAREN parameter_list RPAREN compound_statement\n",linecount);
		$$->SetName($1->GetName()+" "+$2->GetName()+"("+$4->GetDef()+")\n"+$7->GetName());
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}

		| type_specifier ID LPAREN RPAREN 
		{/*table->Insert($2->GetName(),"ID");
		SymbolInfo *s = table->LookUp($2->GetName());
		s->parameter = NULL;
		s->SetReturnType($1->GetType());*/
		param = NULL;
		SymbolInfo *s = table->LookUp($2->GetName());
		if(s->GetName().empty()){
		table->Insert($2->GetName(),"ID");
		s = table->LookUp($2->GetName());
		s->parameter = NULL;
		s->SetReturnType($1->GetType());
		s->flag=1;}
		else if(s->GetName().compare($2->GetName())==0){//check params
		if(s->flag==1){//check flag
		char msg[50];errorcount++;
		sprintf(msg,"%s","Function Already Defined");
		yyerror1(msg);
		}
		else if(s->flag==0 && s->parameter==NULL && s->GetReturnType().compare($1->GetType())==0){
		s->flag=1;}
		else if(s->GetReturnType().compare($1->GetType())!=0)
		{char msg[50];errorcount++;
		sprintf(msg,"%s","Return Type Does not Match");
		yyerror1(msg);}
		else{char msg[50];errorcount++;
		sprintf(msg,"%s","Multiple Definition of Function");
		yyerror1(msg);}
		}
		else{table->Insert($2->GetName(),"ID");
		s = table->LookUp($2->GetName());
		s->parameter = NULL;
		s->SetReturnType($1->GetType());
		s->flag=1;
		}

		} compound_statement
		{$$ = new SymbolInfo();
		SymbolInfo *s = table->LookUp($2->GetName());
		//cout<<s->GetReturnType()<<" "<<$6->GetType();
		if(s->GetReturnType().compare($6->GetType())!=0){char msg[50];errorcount++;
		sprintf(msg,"%s","Return Type Does not Match");
		yyerror1(msg);}
		fprintf(fp2 , "At line %d : func_definition-> type_specifier ID LPAREN RPAREN compound_statement\n",linecount);
		$$->SetName($1->GetName()+" "+$2->GetName()+"( )"+$6->GetName());
		fprintf(fp2 , "\n %s \n\n", $$->GetName().c_str());}
 		;				


parameter_list  : parameter_list COMMA type_specifier ID
		{$$ = new SymbolInfo();
		fprintf(fp2 , "At line %d : parameter_list-> parameter_list COMMA type_specifier ID\n",linecount);
		$4->SetType($3->GetName());
		$4->SetDef($1->GetDef()+","+$3->GetName()+" "+$4->GetName());
		if($1->LookUp($4->GetName())) //generate an error message
		{char msg[60];errorcount++;
		sprintf(msg,"%s","Multiple Definition of single ID in parameter");		
		yyerror1(msg);
		//$$ = $1;
		$$ = $4;}
		else
		{$4->next = $1; 
		$$ = $4;}
		fprintf(fp2 , "\n %s \n\n", $$->GetDef().c_str());}

		| parameter_list COMMA type_specifier
		{$$ = new SymbolInfo();
		fprintf(fp2 , "At line %d : parameter_list-> parameter_list COMMA type_specifier\n",linecount);
		/*$$->SetName($1->GetName()+","+$3->GetName());
		$$->SetType("parameter_list");
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());*/


		$3->SetType($3->GetName());
		$3->SetDef($1->GetDef()+","+$3->GetName());
		$3->next = $1; 
		$$ = $3;
		fprintf(fp2 , "\n %s \n\n", $$->GetDef().c_str());}

 		| type_specifier ID
		{$$ = new SymbolInfo();
		fprintf(fp2 , "At line %d : parameter_list -> type_specifier ID\n",linecount);
		$2->SetType($1->GetName());
		$2->SetDef($1->GetName()+" "+$2->GetName()); $$ = $2;
		fprintf(fp2 , "\n %s \n\n", $$->GetDef().c_str());}


		| type_specifier
		{$$ = new SymbolInfo();
		fprintf(fp2 , "At line %d : parameter_list-> type_specifier\n",linecount);
		/*$$->SetName($1->GetName());
		$$->SetType("parameter_list");
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());*/
		$1->SetType($1->GetName());
		$1->SetDef($1->GetName());
		$$ = $1;
		fprintf(fp2 , "\n %s \n\n", $$->GetDef().c_str());}
 		;

 		
compound_statement : LCURL
		{table->EnterScope(fp2);
		} statements RCURL
		{$$ = new SymbolInfo();
		fprintf(fp2 , "At line %d : compound_statement -> LCURL statements RCURL\n",linecount);
		table->PrintAll(fp2);table->ExitScope(fp2);
		$$->SetName("{\n" + $3->GetName()+ "}\n");
		$$->SetType($3->GetType());
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}

 		    | LCURL {table->EnterScope(fp2);} RCURL
		{$$ = new SymbolInfo();
		table->PrintAll(fp2);table->ExitScope(fp2);
		$$->SetName("{}\n");
		$$->SetType("void"); //not sure if it should be void
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
		{$$ = new SymbolInfo();
		$$->SetName($1->GetName()+" "+$2->GetType()+ " ;\n" );
		fprintf(fp2 , "At line %d : var_declaration -> type_specifier declaration_list SEMICOLON\n" , linecount);
		for( $2 ; $2->next != $2; $2 = $2->next ){
		table->Update($2->GetName(),$1->GetName());
		//table->PrintCurrent(fp2);
		} 
		table->Update($2->GetName(),$1->GetName());
		//$$->SetType("var_declaration"); //this probably needs using type_specifier
		fprintf(fp2 ,"\n %s \n\n", $$->GetName().c_str());}

		|type_specifier declaration_list error
	{	$$->SetName($1->GetName()+" "+$2->GetName()+"\n");
		cout<<"error"<<endl;}
 		 ;
 		 
type_specifier	: INT
		{
		fprintf(fp2 , "At line %d : type_specifier -> INT\n",linecount);
		$$ = new  SymbolInfo("int" , "int");
		fprintf(fp2 , "\n %s \n\n", $$->GetName().c_str());}

 		| FLOAT
		{fprintf(fp2 , "At line %d : type_specifier -> FLOAT\n",linecount);
		$$ = new  SymbolInfo("float","float");
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}

 		| VOID
		{
		fprintf(fp2 , "At line %d : type_specifier -> VOID\n",linecount);
		$$ = new  SymbolInfo( "void","void");
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}
 		;
 		
declaration_list : declaration_list COMMA ID
		{fprintf(fp2 , "At line %d : declaration_list -> declaration_list COMMA ID\n",linecount);
		$3->SetType($1->GetType()+","+$3->GetName());
		SymbolInfo *s = table->LookUp($3->GetName());
		if(s->GetName().empty()){
		table->Insert($3->GetName(),"ID");
		s = table->LookUp($3->GetName());
		s->flag=0;}
		else if(s->GetName().compare($1->GetName())==0)
		{char msg[50];errorcount++;
		sprintf(msg,"%s","Multiple Definition");
		yyerror1(msg);}
		else{
		table->Insert($3->GetName(),"ID");
		s = table->LookUp($3->GetName());
		s->flag=0;}
		$3->next = $1; 
		$$ = new SymbolInfo();
		$$ = $3;
		fprintf(fp2 , "\n %s \n\n" , $$->GetType().c_str());
		}

 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
		{fprintf(fp2 , "At line %d : declaration_list -> declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n",linecount);
		$3->SetType($1->GetType()+","+$3->GetName()+"["+$5->GetName()+"]");
		SymbolInfo *s = table->LookUp($3->GetName());
		if(s->GetName().empty()){ //not found
		table->Insert($3->GetName(),"ID");
		s = table->LookUp($3->GetName());
		s->flag=CONST_INT;}
		else if(s->GetName().compare($1->GetName())==0) //found
		{char msg[50];errorcount++;
		sprintf(msg,"%s","Multiple Definition");
		yyerror1(msg);}
		else{ //not found
		table->Insert($3->GetName(),"ID");
		s = table->LookUp($3->GetName());
		s->flag=CONST_INT;}
		$3->next = $1; 
		$$ = new SymbolInfo();
		$$ = $3;
		fprintf(fp2 , "\n %s \n\n" , $$->GetType().c_str());}

 		  | ID
		{$$ = new SymbolInfo($1->GetName(),$1->GetName());
		fprintf(fp2 , "At line %d : declaration_list -> ID\n",linecount);
		SymbolInfo *s = table->LookUp($1->GetName());
		if(s->GetName().empty()){
		table->Insert($1->GetName(),"ID");
		s = table->LookUp($1->GetName());
		s->flag=0;}
		else if(s->GetName().compare($1->GetName())==0)
		{char msg[50];errorcount++;
		sprintf(msg,"%s","Multiple Definition");
		yyerror1(msg);}
		else{
		table->Insert($1->GetName(),"ID");
		s = table->LookUp($1->GetName());
		s->flag=0;}
		fprintf(fp2 , "\n %s \n\n" , $$->GetType().c_str());}

 		  | ID LTHIRD CONST_INT RTHIRD
		{$$ = new SymbolInfo($1->GetName(),$1->GetName()+"["+$3->GetName()+"]");
		fprintf(fp2 , "At line %d : declaration_list -> ID LTHIRD CONST_INT RTHIRD\n",linecount);
		SymbolInfo *s = table->LookUp($1->GetName());
		if(s->GetName().empty()){
		table->Insert($1->GetName(),"ID");
		s = table->LookUp($1->GetName());
		s->flag=CONST_INT;}
		else if(s->GetName().compare($1->GetName())==0)
		{char msg[50];errorcount++;
		sprintf(msg,"%s","Multiple Definition");
		yyerror1(msg);}
		else{
		table->Insert($1->GetName(),"ID");
		s = table->LookUp($1->GetName());
		s->flag=CONST_INT;}
		fprintf(fp2 , "\n %s \n\n" , $$->GetType().c_str());}
 		  ;
 		  
statements : statement
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : statements -> statement\n",linecount);
		$$->SetName($1->GetName());
		$$->SetType($1->GetType());
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}

	   | statements statement
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : statements -> statements statement\n",linecount);
		$$->SetName($1->GetName()+" "+$2->GetName());
		$$->SetType($2->GetType());
		fprintf(fp2 , "\n %s \n\n", $$->GetName().c_str());}
	   ;
	   
statement : var_declaration
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : statement -> var_declaration\n",linecount);
		$$->SetName($1->GetName());
		$$->SetType("void");
		fprintf(fp2 , "\n %s \n\n", $$->GetName().c_str());}

	  | expression_statement
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : statement -> expression_statement\n",linecount);
		$$->SetName($1->GetName());
		$$->SetType("void");
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}

	  | compound_statement
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : statement -> compound_statement\n",linecount);
		$$->SetName($1->GetName());
		$$->SetType("void");
		fprintf(fp2 , "\n %s \n\n", $$->GetName().c_str());}

	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : statement -> FOR LPAREN expression_statement expression_statement expression RPAREN statement\n",linecount);
		$$->SetName("for ( "+$3->GetName()+" "+$4->GetName()+" "+$5->GetName()+ " ) \n"+$7->GetName());
		$$->SetType("void");
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}

	  | IF LPAREN expression RPAREN statement	
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : statement ->  IF LPAREN expression RPAREN statement\n",linecount);
		$$->SetName("if ( "+$3->GetName()+" ) \n"+$5->GetName());
		$$->SetType("void");
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str()); }%prec LOWER_THAN_ELSE ;
	  | IF LPAREN expression RPAREN statement ELSE statement
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : statement -> IF LPAREN expression RPAREN statement ELSE statement\n",linecount);
		$$->SetName("if ( "+$3->GetName()+" ) "+$5->GetName() + " else \n" + $7->GetName());
		$$->SetType("void");
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}

	  | WHILE LPAREN expression RPAREN statement
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : statement -> WHILE LPAREN expression RPAREN statement\n",linecount);
		$$->SetName("while ( "+$3->GetName()+" )\n "+$5->GetName());
		$$->SetType("void");
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}

	  | PRINTLN LPAREN ID RPAREN SEMICOLON
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : statement -> PRINTLN LPAREN ID RPAREN SEMICOLON\n",linecount);
		$$->SetName($1->GetName()+" ( "+$3->GetName()+" ) ;\n");
		$$->SetType("void");
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}

	|PRINTLN LPAREN ID RPAREN error
	{	$$->SetName($1->GetName()+"("+$3->GetDef()+");\n");
		cout<<"error"<<endl;}

	  | RETURN expression SEMICOLON
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : statement ->  RETURN expression SEMICOLON\n",linecount);
		$$->SetName("return "+$2->GetName()+";\n");
		$$->SetType($2->GetType());
		if($2->GetType().compare("void")==0)
		{
		$$->SetType("void");
		char msg[50];errorcount++;
		sprintf(msg,"%s","Void can not be assigned");
		yyerror1(msg);}
		//here probably we need to check if the return type matches the function declaration
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}
	
	|RETURN expression error
	{	$$->SetName("return "+$2->GetName()+"\n");
		cout<<"error"<<endl;}
	  ;
	  
expression_statement 	: SEMICOLON			
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : expression_statement -> SEMICOLON\n",linecount);
		$$->SetName(";\n");
		$$->SetType("void");
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}
		|error
	{	$$->SetName("\n");
		cout<<"error"<<endl;}

			| expression SEMICOLON 
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : expression_statement -> expression SEMICOLON\n",linecount);
		$$->SetName($1->GetName()+ ";\n");
		$$->SetType($1->GetType());
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}
		| expression error
	{	$$->SetName($1->GetName()+"\n");
		cout<<"error"<<endl;}
			;
	  
variable : ID 		
		{//bool flag=false;
		fprintf(fp2 , "At line %d : variable -> ID\n",linecount);
		SymbolInfo *s = table->LookUpAll($1->GetName());
		if(param!=NULL && param->LookUp($1->GetName()))//found in parameter list
		{$$=param->LookUpInfo($1->GetName());}
		else if(s->GetName().empty()==false) //can be present in ST
		{

		if(s->GetName().compare($1->GetName())==0) //found in ST
		{
		//flag=true;
		if(s->flag!=0)//found but it is an array
		{$$=new SymbolInfo($1->GetName(),$1->GetType());
		char msg[50];errorcount++;
		sprintf(msg,"%s","Array index not given");
		yyerror1(msg);}
		else//correctly found
		$$=s;

		} 
		}
		else
		{//not found anywhere
		$$=new SymbolInfo($1->GetName(),"invalid");
		char msg[30];errorcount++;
		sprintf(msg,"%s","Undefined variable");
		yyerror1(msg);
		}
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}

	 | ID LTHIRD expression RTHIRD 
		{fprintf(fp2 , "At line %d : variable -> ID LTHIRD expression RTHIRD\n",linecount);
		/*SymbolInfo *s = table->LookUp($1->GetName());
		if(s->GetName().empty()){
		$$->SetType($1->GetType());}
		else
		$$->SetType(s->GetType());
		$$->SetName($1->GetName()+"["+$3->GetName()+"]");*/

		if($3->GetType().compare("float")==0)
		{
		$$->SetType("invalid");
		char msg[50];errorcount++;
		sprintf(msg,"%s","Non-integer Array Index");
		yyerror1(msg);}
		else if($3->GetType().compare("void")==0)
		{
		$$->SetType("invalid");
		char msg[50];errorcount++;
		sprintf(msg,"%s","Void can not be assigned");
		yyerror1(msg);}

		SymbolInfo *s = table->LookUpAll($1->GetName());
		/*if(param->LookUp($1->GetName()))//found in parameter list . we omit this , cuz our grammar does not have array arg
		{$$=param->LookUpInfo($1->GetName());}
		else*/ if(s->GetName().empty()==false) //can be present in ST
		{

		if(s->GetName().compare($1->GetName())==0) //found in ST
		{
		//flag=true;
		if(s->flag==0)//found but it is not an array
		{$$=new SymbolInfo($1->GetName()+"["+$3->GetName()+"]","invalid");
		char msg[50];errorcount++;
		sprintf(msg,"%s","Not declared as array");
		yyerror1(msg);}
		else//correctly found
		$$=new SymbolInfo($1->GetName()+"["+$3->GetName()+"]",s->GetType());
		} 
		}
		else
		{//not found anywhere
		$$=new SymbolInfo($1->GetName()+"["+$3->GetName()+"]","invalid");
		char msg[30];errorcount++;
		sprintf(msg,"%s","Undefined variable");
		yyerror1(msg);
		}

		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}
	 ;
	 
expression : logic_expression	
		{$$ = new SymbolInfo();
		fprintf(fp2 , "At line %d : expression -> logic_expression\n",linecount);
		$$->SetName($1->GetName());
		$$->SetType($1->GetType());
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}

	   | variable ASSIGNOP logic_expression
		{$$ = new SymbolInfo();
		fprintf(fp2 , "At line %d : expression -> variable ASSIGNOP logic_expression \n",linecount);
		$$->SetName($1->GetName()+" = "+$3->GetName());
                $$->SetType("int");
		if($1->GetType().compare("int")==0 && $3->GetType().compare("float")==0){
		$$->SetType("int");
		char msg[20];errorcount++;
		sprintf(msg,"%s","Type Mismatch");
		yyerror1(msg);}
		else if($1->GetType().compare("float")==0 && $3->GetType().compare("int")==0){
		$$->SetType("int");
		char msg[30];errorcount++;
		sprintf(msg,"%s","Integer converted to Float");
		yyerror1(msg);}
		else if($3->GetType().compare("void")==0 ||$1->GetType().compare("void")==0){
		$$->SetType("int");
		char msg[50];errorcount++;
		sprintf(msg,"%s","Void can not be assigned");
		yyerror1(msg);}
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}
	   ;
			
logic_expression : rel_expression 	
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : logic_expression ->  rel_expression\n",linecount);
		$$->SetName($1->GetName());
		$$->SetType($1->GetType());
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}

		 | rel_expression LOGICOP rel_expression 	
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : logic_expression ->  rel_expression LOGICOP rel_expression\n",linecount);
		$$->SetName($1->GetName()+" "+$2->GetName()+" "+$3->GetName());
		$$->SetType("int");//it should have been boolean , but we have int
		//$$->SetType("void");
		if($3->GetType().compare("void")==0 ||$1->GetType().compare("void")==0){
		char msg[50];errorcount++;$$->SetType("int");
		sprintf(msg,"%s","Void can not be a part of expression");
		yyerror1(msg);}
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}
		 ;
			
rel_expression	: simple_expression 
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : rel_expression ->  simple_expression\n",linecount);	
		$$->SetName($1->GetName());
		$$->SetType($1->GetType());
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());
		}

		| simple_expression RELOP simple_expression	
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : rel_expression ->  simple_expression RELOP simple_expression\n",linecount);
		$$->SetName($1->GetName()+" "+$2->GetName()+" "+$3->GetName());
		$$->SetType("int"); //it should have been boolean , but we have int
		//$$->SetType("void");
		if($3->GetType().compare("void")==0 ||$1->GetType().compare("void")==0){
		char msg[50];errorcount++;$$->SetType("int");
		sprintf(msg,"%s","Void can not be a part of expression");
		yyerror1(msg);}
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}
		;
				
simple_expression : term 
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : simple_expression ->  term\n",linecount);
		$$->SetName($1->GetName());
		$$->SetType($1->GetType());
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}

		  | simple_expression ADDOP term 
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : simple_expression ->  simple_expression\n",linecount);
		$$->SetName($1->GetName()+" "+$2->GetName()+" "+$3->GetName());
		if($3->GetType().compare("void")==0 ||$1->GetType().compare("void")==0){
		$$->SetType("int");
		char msg[50];errorcount++;
		sprintf(msg,"%s","Void can not be a part of expression");
		yyerror1(msg);}
		else if($1->GetType().compare("float")==0 || $3->GetType().compare("float")==0){ //not very sure
                $$->SetType("float");}
		else
		$$->SetType("int");
		//$$->SetType("void");
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());} 
		  ;
					
term :	unary_expression
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : term -> unary_expression\n",linecount);
		$$->SetName($1->GetName());
		$$->SetType($1->GetType());
		fprintf(fp2 , "\n %s \n\n", $$->GetName().c_str());}

     |  term MULOP unary_expression
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : term -> term MULOP unary_expression\n",linecount);
		$$->SetName($1->GetName()+" "+$2->GetName()+" "+$3->GetName());
		if($1->GetType().compare("void")==0 || $3->GetType().compare("void")==0){
		char msg[50];errorcount++;
		$$->SetType("int");
		sprintf(msg,"%s","Void can not be a part of expression");
		yyerror1(msg);}
		if($1->GetType().compare("float")==0 || $3->GetType().compare("float")==0){ //not very sure
                $$->SetType("float");}
		else
		$$->SetType("int");
		if($2->GetName().compare("%")==0){
		if($1->GetType().compare("int")!=0 || $3->GetType().compare("int")!=0){
                $$->SetType("int");
		char msg[50];errorcount++;
		sprintf(msg,"%s","Integer operand on modulus operator");
		yyerror1(msg);}
            	}
		fprintf(fp2 , "\n%s \n\n" , $$->GetName().c_str());} 
     ;

unary_expression : ADDOP unary_expression 
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : unary_expression -> ADDOP unary_expression\n",linecount);
		$$->SetName($1->GetName()+" "+$2->GetName());
		$$->SetType($2->GetType());
		if($2->GetType().compare("void")==0){
		char msg[50];errorcount++;
		$$->SetType("int");
		sprintf(msg,"%s","Void can not be a part of expression");
		yyerror1(msg);}
		fprintf(fp2 , "\n %s \n\n", $$->GetName().c_str());} 

		 | NOT unary_expression //done with int
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : unary_expression -> NOT unary_expression \n",linecount);
		$$->SetName("!"+$2->GetName());
		$$->SetType("int");
		if($2->GetType().compare("void")==0){
		char msg[50];errorcount++;
		sprintf(msg,"%s","Void can not be a part of expression");
		yyerror1(msg);}
		fprintf(fp2 , "\n %s \n\n", $$->GetName().c_str());} 

		 | factor 
		{$$ = new SymbolInfo();
		fprintf(fp2 , "At line %d : unary_expression -> factor\n",linecount);
		$$->SetName($1->GetName());
		$$->SetType($1->GetType());
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());} 
		 ;
	
factor	: variable
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : factor -> variable\n",linecount);
		$$->SetName($1->GetName());
		$$->SetType($1->GetType()); 
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());} 

	| ID LPAREN argument_list RPAREN //function call
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : factor -> ID LPAREN argument_list RPAREN\n",linecount);
		$$->SetName($1->GetName() + "( " + $3->GetName() + " )");
		SymbolInfo *s=$1;
		$1=table->LookUpAll($1->GetName());
		if($1->GetName().empty())
		{char msg[50];errorcount++;
		sprintf(msg,"%s","Function Not Defined Yet");
		yyerror1(msg);
		$$->SetType("int");}
		else if($1->GetName().compare(s->GetName())!=0 || $1->GetType().compare("ID")!=0)
		{char msg[50];errorcount++;
		sprintf(msg,"%s","Function Not Defined Yet");
		yyerror1(msg);
		$$->SetType("int");}
		else if(!($1->Match2($3)))
		{char msg[50];errorcount++;
		sprintf(msg,"%s","Argument Mismatched");
		yyerror1(msg);
		$$->SetType($1->GetReturnType());}
		else 
		$$->SetType($1->GetReturnType());
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}

	| LPAREN expression RPAREN
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : factor -> LPAREN expression RPAREN\n",linecount);
		$$->SetName("( " + $2->GetName() + " )" );
		$$->SetType($2->GetType());
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());	}

	| CONST_INT 
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : factor -> CONST_INT\n",linecount);
		$$->SetName($1->GetName());
		$$->SetType("int");
		fprintf(fp2 , "\n %s \n\n", $$->GetName().c_str());	}

	| CONST_FLOAT
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : factor -> CONST_FLOAT\n",linecount);
		$$->SetName($1->GetName());
		$$->SetType("float");
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());	}

	| variable INCOP 
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : factor -> variable INCOP\n",linecount);
		$$->SetName($1->GetName() + "++" );
		if($1->GetType().compare("float")==0)
		{char msg[50];errorcount++;
		sprintf(msg,"%s","Integer operand on increment operator");
		yyerror1(msg);}
		$$->SetType("int");
		fprintf(fp2 ,"\n %s \n\n" , $$->GetName().c_str());}

	| variable DECOP
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : factor -> variable DECOP\n",linecount);
		$$->SetName($1->GetName() + "--" );
		if($1->GetType().compare("float")==0)
		{char msg[50];errorcount++;
		sprintf(msg,"%s","Integer operand on decrement operator");
		yyerror1(msg);}
		$$->SetType("int");
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());	}
	;
	
argument_list : arguments
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : argument_list -> arguments\n",linecount);
		$$=$1;
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}

			  |
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : argument_list -> empty\n",linecount);
		$$->SetName(" ");
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}
			  ;
	
arguments : arguments COMMA logic_expression
		{$$ = new SymbolInfo();
		fprintf(fp2 , "At line %d : arguments -> arguments COMMA logic_expression\n",linecount);
		$3->next = $1; 
		$$ = $3;
		$$->SetName($1->GetName() + " , " + $3->GetName());
		fprintf(fp2 ,"\n %s \n\n" , $$->GetType().c_str());}

	      | logic_expression
		{$$ = new SymbolInfo();fprintf(fp2 , "At line %d : unary_expression -> logic_expression\n",linecount);
		$$->SetName($1->GetName());
		$$->SetType($1->GetType());
		fprintf(fp2 , "\n %s \n\n" , $$->GetName().c_str());}
	      ;
 

%%
int main(int argc,char *argv[])
{

	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}

	if((fp2= fopen(argv[2],"w"))==NULL)
	{
		printf("Cannot Open File 2.\n");
		exit(1);
	}
	fclose(fp2);
	if((fp3= fopen(argv[3],"w"))==NULL)
	{
		printf("Cannot Open File 3.\n");
		exit(1);
	}
	fclose(fp3);
	
	fp2= fopen(argv[2],"a"); // log file
	fp3= fopen(argv[3],"a"); // error file
	
	tokenout= fopen("token.txt","w");
	yyin=fp;
	yyparse();
	
	table->PrintCurrent(fp2);
	fclose(fp2);
	fprintf(fp3,"\nTotal Error : %d\n\n",errorcount);
	fclose(fp3);
	fclose(tokenout);
	return 0;
}
