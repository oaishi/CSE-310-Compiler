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
int flag  = 1;
int labelCount=0;
int tempCount=0;
ofstream fout;
string currfunc="";
string datacode= ".MODEL SMALL\n.STACK 100H\n.DATA\n";
string printproc= "\n\nPRINT_NUMBER PROC\nPUSH AX\nPUSH BX\nPUSH CX\nPUSH DX\nOR AX,AX\nJGE POSITIVE\nNEGATIVE:\nPUSH AX\nMOV AH , 2\nMOV DL , '-'\nINT 21h\nPOP AX\nNEG AX\nPOSITIVE:\nMOV CX , 0\nMOV BX , 0Ah\nTOP:\nXOR DX,DX\nDIV BX\nPUSH DX\nINC CX\nOR AX,AX\nJNE TOP\nMOV AH , 2\nPRINT:\nPOP DX\nADD DL,48d\nINT 21h\nLOOP PRINT\nmov dl , 0dh\nINT 21h\nmov dl , 0ah\nINT 21h\nPOP DX\nPOP CX\nPOP BX\nPOP AX \nRET\nPRINT_NUMBER ENDP\n\n";
string tempcode = "";
char *newLabel()
{
	char *lb= new char[4];
	strcpy(lb,"L");
	char b[3];
	sprintf(b,"%d", labelCount);
	labelCount++;
	strcat(lb,b);
	return lb;
}

char *newTemp()
{
	char *t= new char[4];
	strcpy(t,"t");
	char b[3];
	sprintf(b,"%d", tempCount);
	tempCount++;
	strcat(t,b);
	tempcode+=string(t)+" dw ?\n";
	return t;
}


void yyerror(const char *s)
{
	errorcount++;
	fprintf(fp2,"\nError %d at Line %d : %s %s\n\n",errorcount,linecount,s,yytext);
	return;
}

void yyerror1(char *s)
{
	fprintf(fp2,"\nError %d at Line %d : %s \n\n",errorcount,linecount,s);
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
		$$=$1;
		fprintf(fp3 , "At line %d : start-> program\n",linecount);
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());
		datacode+=tempcode+"\n\n.CODE\n"+printproc;
		//if(errorcount==0){
		fout<<datacode;
		fout<<$1->code;
		fout<<"END main\n";//};
	}
	;

program : program unit 
	{
		fprintf(fp3 , "At line %d : program->program unit\n",linecount);
		$$ = new SymbolInfo();
		$$->SetName($1->GetName()+" "+$2->GetName());
		$$->code=$1->code+$2->code;
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());}
	| unit
	{
		fprintf(fp3 , "At line %d : program-> unit\n",linecount);
		$$ = $1;
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());}
	;
	
unit : var_declaration
	{
		fprintf(fp3 , "At line %d : unit-> var_declaration\n",linecount);
		$$ = $1;
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());}
     | func_declaration
	{
		fprintf(fp3 , "At line %d : unit-> func_declaration\n",linecount);
		$$ = $1;
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());}
     | func_definition
	{
		fprintf(fp3 , "At line %d : unit-> func_definition\n",linecount);
		$$ = $1;
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());}
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON //probably no assembly code needed here
	{
		table->PrintAll(fp3);
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
		fprintf(fp3 , "At line %d : func_declaration-> type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n",linecount);
		$$->SetName($1->GetName()+" "+$2->GetName()+" "+"("+$4->GetDef()+");\n");
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());}

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
		fprintf(fp3 , "At line %d : func_declaration-> type_specifier ID LPAREN RPAREN SEMICOLON\n",linecount);
		$$->SetName($1->GetName()+" "+$2->GetName()+"();\n");
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());}

			|type_specifier ID LPAREN RPAREN error
	{	$$->SetName($1->GetName()+" "+$2->GetName()+" "+"( )\n");
		cout<<"error"<<endl;}
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN
		{SymbolInfo *s = table->LookUp($2->GetName());
		param = $4;
		currfunc = $2->GetName();
		if(s->GetName().empty()){
		table->Insert($2->GetName(),"ID");
		s = table->LookUp($2->GetName());
		s->SetParam($4);
		s->SetReturnType($1->GetType());
		s->flag=1;
		char *temp=newTemp(); s->SetDef(temp);		 //for recursion
		$2->code=string(temp);
		}
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
		char *temp=newTemp(); s->SetDef(temp);		 //for recursion
		$2->code=string(temp);
		}
		} compound_statement
		{$$ = new SymbolInfo();
		flag=1;
		if($2->GetName().compare("main")==0)
		$$->code="\nmain PROC\nmov ax, @DATA\nmov ds, ax\n";
		else
		$$->code="\n" + $2->GetName()+" PROC\n";
		if($2->GetName().compare("main")!=0)
		$$->code+="pop "+$2->code+"\n";		//pop the address after call if not main
		$$->code+=$4->code;
		SymbolInfo *s = table->LookUp($2->GetName());
		if(s->GetReturnType().compare($7->GetType())!=0){char msg[50];errorcount++;
		sprintf(msg,"%s","Return Type Does not Match");
		yyerror1(msg);}
		fprintf(fp3 , "At line %d : func_definition-> type_specifier ID LPAREN parameter_list RPAREN compound_statement\n",linecount);
		$$->SetName($1->GetName()+" "+$2->GetName()+"("+$4->GetDef()+")\n"+$7->GetName());
		$$->code+=$7->code;
		if($2->GetName().compare("main")!=0)
		$$->code+="push "+$2->code+"\n";	//push the address before ret if not main
		if($2->GetName().compare("main")==0)
		$$->code+="mov ah , 4ch\nINT 21h\n main ENDP\n";
		else
		$$->code+="ret\n"+ $2->GetName()+" ENDP\n\n";
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());
		}

		| type_specifier ID LPAREN RPAREN 
		{param = NULL;
		SymbolInfo *s = table->LookUp($2->GetName());
		currfunc = $2->GetName();
		if(s->GetName().empty()){
		table->Insert($2->GetName(),"ID");
		s = table->LookUp($2->GetName());
		s->parameter = NULL;
		s->SetReturnType($1->GetType());
		s->flag=1;
		char *temp=newTemp(); s->SetDef(temp);	$2->code=string(temp);	 //for recursion
		}
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
		char *temp=newTemp(); s->SetDef(temp);	$2->code=string(temp);	 //for recursion
		}
		} compound_statement
		{$$ = new SymbolInfo();
		if($2->GetName().compare("main")==0)
		$$->code="\nmain PROC\nmov ax, @DATA\nmov ds , ax\n";
		else
		$$->code="\n" + $2->GetName()+" PROC\n";
		if($2->GetName().compare("main")!=0)
		$$->code+="pop "+$2->code+"\n";		//pop the address after call if not main
		flag=1;
		SymbolInfo *s = table->LookUp($2->GetName());
		if(s->GetReturnType().compare($6->GetType())!=0){char msg[50];errorcount++;
		sprintf(msg,"%s","Return Type Does not Match");
		yyerror1(msg);}
		fprintf(fp3 , "At line %d : func_definition-> type_specifier ID LPAREN RPAREN compound_statement\n",linecount);
		$$->SetName($1->GetName()+" "+$2->GetName()+"( )"+$6->GetName());
		$$->code+=$6->code;
		if($2->GetName().compare("main")!=0)
		$$->code+="push "+$2->code+"\n";	//push the address before ret if it is not tmain
		if($2->GetName().compare("main")==0)
		$$->code+="mov ah , 4ch\nINT 21h\nmain ENDP\n";
		else
		$$->code+="ret\n"+ $2->GetName()+" ENDP\n\n";
		fprintf(fp3 , "\n %s \n\n", $$->GetName().c_str());
		}
 		;				


parameter_list  : parameter_list COMMA type_specifier ID //pop the arg values
		{$$ = new SymbolInfo();
		fprintf(fp3 , "At line %d : parameter_list-> parameter_list COMMA type_specifier ID\n",linecount);
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
		$$->code = "pop "+ $4->GetName() +to_string(table->getID()+1)+"\n"+$1->code;
		fprintf(fp3 , "\n %s \n\n", $$->GetDef().c_str());}

		| parameter_list COMMA type_specifier
		{$$ = new SymbolInfo();
		fprintf(fp3 , "At line %d : parameter_list-> parameter_list COMMA type_specifier\n",linecount);
		
		$3->SetType($3->GetName());
		$3->SetDef($1->GetDef()+","+$3->GetName());
		$3->next = $1; 
		$$ = $3;
		$$->code = "pop ax\n"+$1->code;
		fprintf(fp3 , "\n %s \n\n", $$->GetDef().c_str());}

 		| type_specifier ID
		{$$ = new SymbolInfo();
		fprintf(fp3 , "At line %d : parameter_list -> type_specifier ID\n",linecount);
		$2->SetType($1->GetName());
		$2->SetDef($1->GetName()+" "+$2->GetName()); $$ = $2;
		fprintf(fp3 , "\n %s \n\n", $$->GetDef().c_str());
		$$->code = "pop "+ $2->GetName() +to_string(table->getID()+1)+"\n";}


		| type_specifier
		{$$ = new SymbolInfo();
		fprintf(fp3 , "At line %d : parameter_list-> type_specifier\n",linecount);
		$1->SetType($1->GetName());
		$1->SetDef($1->GetName());
		$$ = $1;
		$$->code = "pop ax\n";
		fprintf(fp3 , "\n %s \n\n", $$->GetDef().c_str());}
 		;

 		
compound_statement : LCURL			//data seg cast
		{table->EnterScope(fp3);
		if(flag==1 && param!=NULL){
		flag=0;
		SymbolInfo *symbol = new SymbolInfo();
		symbol=param;
		while(1){
		    if(symbol->next==symbol)//finds the last element
			{if(symbol->GetName().compare(symbol->GetType())!=0){
		    table->Insert2(symbol->GetName(),symbol->GetType());
			datacode+=symbol->GetName()+to_string(table->getID())+" dw ?\n";}
			break;}
		    //enter the params in the table
	            if(symbol->GetName().compare(symbol->GetType())!=0){
		    table->Insert2(symbol->GetName(),symbol->GetType());
		    datacode+=symbol->GetName()+to_string(table->getID())+" dw ?\n";}
		    symbol = symbol->next;}
		}
		} statements RCURL
		{$$ = $3;
		fprintf(fp3 , "At line %d : compound_statement -> LCURL statements RCURL\n",linecount);
		table->PrintAll(fp3);table->ExitScope(fp3);
		$$->SetName("{\n" + $3->GetName()+ "}\n");
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());
		}

 		    | LCURL RCURL
		{$$ = new SymbolInfo();
		fprintf(fp3 , "At line %d : compound_statement -> LCURL RCURL\n",linecount);
		table->PrintAll(fp3);
		$$->SetName("{}\n");
		$$->SetType("void"); //not sure if it should be void
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());}
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON //no assembly code needed
		{$$ = new SymbolInfo();
		$$->SetName($1->GetName()+" "+$2->GetType()+ " ;\n" );
		fprintf(fp3 , "At line %d : var_declaration -> type_specifier declaration_list SEMICOLON\n" , linecount);
		for( $2 ; $2->next != $2; $2 = $2->next ){
		table->Update($2->GetName(),$1->GetName());
		} 
		table->Update($2->GetName(),$1->GetName());
		fprintf(fp3 ,"\n %s \n\n", $$->GetName().c_str());}
 		 ;
 		 
type_specifier	: INT //no assembly code needed
		{
		fprintf(fp3 , "At line %d : type_specifier -> INT\n",linecount);
		$$ = new  SymbolInfo("int" , "int");
		fprintf(fp3 , "\n %s \n\n", $$->GetName().c_str());}

 		| FLOAT
		{fprintf(fp3 , "At line %d : type_specifier -> FLOAT\n",linecount);
		$$ = new  SymbolInfo("float","float");
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());}

 		| VOID
		{
		fprintf(fp3 , "At line %d : type_specifier -> VOID\n",linecount);
		$$ = new  SymbolInfo( "void","void");
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());}
 		;
 		
declaration_list : declaration_list COMMA ID //data seg cast
		{fprintf(fp3 , "At line %d : declaration_list -> declaration_list COMMA ID\n",linecount);
		$3->SetType($1->GetType()+","+$3->GetName());
		SymbolInfo *s = table->LookUp($3->GetName());
		if(s->GetName().empty()){
		table->Insert2($3->GetName(),"ID");
		s = table->LookUp($3->GetName());
		s->flag=0;}
		else if(s->GetName().compare($1->GetName())==0)
		{char msg[50];errorcount++;
		sprintf(msg,"%s","Multiple Definition");
		yyerror1(msg);}
		else{
		table->Insert2($3->GetName(),"ID");
		s = table->LookUp($3->GetName());
		s->flag=0;}
		$3->next = $1; 
		$$ = new SymbolInfo();
		$$ = $3;
		datacode+=$3->GetName()+to_string(table->getID())+" dw ?\n";
		fprintf(fp3 , "\n %s \n\n" , $$->GetType().c_str());
		}

 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
		{fprintf(fp3 , "At line %d : declaration_list -> declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n",linecount);
		$3->SetType($1->GetType()+","+$3->GetName()+"["+$5->GetName()+"]");
		SymbolInfo *s = table->LookUp($3->GetName());
		if(s->GetName().empty()){ //not found
		table->Insert2($3->GetName(),"ID");
		s = table->LookUp($3->GetName());
		s->flag=CONST_INT;}
		else if(s->GetName().compare($1->GetName())==0) //found
		{char msg[50];errorcount++;
		sprintf(msg,"%s","Multiple Definition");
		yyerror1(msg);}
		else{ //not found
		table->Insert2($3->GetName(),"ID");
		s = table->LookUp($3->GetName());
		s->flag=CONST_INT;}
		$3->next = $1; 
		$$ = new SymbolInfo();
		$$ = $3;
		datacode+=$3->GetName()+to_string(table->getID())+" dw "+$5->GetName() + " dup (0)\n";
		fprintf(fp3 , "\n %s \n\n" , $$->GetType().c_str());
		}

 		  | ID
		{$$ = new SymbolInfo($1->GetName(),$1->GetName());
		fprintf(fp3 , "At line %d : declaration_list -> ID\n",linecount);
		SymbolInfo *s = table->LookUp($1->GetName());
		if(s->GetName().empty()){
		table->Insert2($1->GetName(),"ID");
		s = table->LookUp($1->GetName());
		s->flag=0;}
		else if(s->GetName().compare($1->GetName())==0)
		{char msg[50];errorcount++;
		sprintf(msg,"%s","Multiple Definition");
		yyerror1(msg);}
		else{
		table->Insert2($1->GetName(),"ID");
		s = table->LookUp($1->GetName());
		s->flag=0;}
		datacode+=$1->GetName()+to_string(table->getID())+" dw ?\n";
		fprintf(fp3 , "\n %s \n\n" , $$->GetType().c_str());}

 		  | ID LTHIRD CONST_INT RTHIRD
		{$$ = new SymbolInfo($1->GetName(),$1->GetName()+"["+$3->GetName()+"]");
		fprintf(fp3 , "At line %d : declaration_list -> ID LTHIRD CONST_INT RTHIRD\n",linecount);
		SymbolInfo *s = table->LookUp($1->GetName());
		if(s->GetName().empty()){
		table->Insert2($1->GetName(),"ID");
		s = table->LookUp($1->GetName());
		s->flag=CONST_INT;}
		else if(s->GetName().compare($1->GetName())==0)
		{char msg[50];errorcount++;
		sprintf(msg,"%s","Multiple Definition");
		yyerror1(msg);}
		else{
		table->Insert2($1->GetName(),"ID");
		s = table->LookUp($1->GetName());
		s->flag=CONST_INT;}
		datacode+=$1->GetName()+to_string(table->getID())+" dw "+$3->GetName() + " dup (0)\n";
		fprintf(fp3 , "\n %s \n\n" , $$->GetType().c_str());}
 		  ;
 		  
statements : statement   //no assembly code needed
		{$$ = $1;
		fprintf(fp3 , "At line %d : statements -> statement\n",linecount);
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());
		}

	   | statements statement
		{fprintf(fp3 , "At line %d : statements -> statements statement\n",linecount);
		$$ = $1;
		$$->SetName($1->GetName()+" "+$2->GetName());
		$$->SetType($2->GetType());
		$$->code += $2->code;
		fprintf(fp3 , "\n %s \n\n", $$->GetName().c_str());}
	   ;
	   
statement : var_declaration    //no assembly code needed
		{$$ = $1;
		fprintf(fp3 , "At line %d : statement -> var_declaration\n",linecount);
		$$->SetName($1->GetName());
		$$->SetType("void");
		fprintf(fp3 , "\n %s \n\n", $$->GetName().c_str());}

	  | expression_statement
		{$$ = $1;
		fprintf(fp3 , "At line %d : statement -> expression_statement\n",linecount);
		$$->SetType("void");
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());
		}

	  | compound_statement
		{$$ = $1;
		fprintf(fp3 , "At line %d : statement -> compound_statement\n",linecount);
		$$->SetName($1->GetName());
		$$->SetType("void");
		fprintf(fp3 , "\n %s \n\n", $$->GetName().c_str());}

	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
		{$$ = new SymbolInfo();
		fprintf(fp3 , "At line %d : statement -> FOR LPAREN expression_statement expression_statement expression RPAREN statement\n",linecount);
		$$->SetName("for ( "+$3->GetName()+" "+$4->GetName()+" "+$5->GetName()+ " ) \n"+$7->GetName());
		$$->SetType("void");
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());
		$$->code=$3->code;
		char *label=newLabel();
		char *label2=newLabel();
		$$->code+=string(label)+":\n"+$4->code;
		$$->code+="mov ax, "+$4->getSymbol()+"\n";
		$$->code+="cmp ax, 0\n";
		$$->code+="je "+string(label2)+"\n"+$7->code+$5->code+"jmp "+string(label)+"\n"+string(label2)+":\n";
		/*
						$3's code at first, which is already done by assigning $$=$3
						create two labels and append one of them in $$->code
						compare $4's symbol with 0
						if equal jump to 2nd label
						append $7's code
						append $5's code
						append the second label in the code
					*/}

	  | IF LPAREN expression RPAREN statement	
		{$$ = new SymbolInfo();fprintf(fp3 , "At line %d : statement ->  IF LPAREN expression RPAREN statement\n",linecount);
		$$->SetName("if ( "+$3->GetName()+" ) \n"+$5->GetName());
		$$->SetType("void");
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str()); 
		$$->code=$3->code;
		char *label=newLabel();
		$$->code+="mov ax, "+$3->getSymbol()+"\n";
		$$->code+="cmp ax, 0\n";
		$$->code+="je "+string(label)+"\n";
		$$->code+=$5->code;
		$$->code+=string(label)+":\n";}%prec LOWER_THAN_ELSE ;
	  | IF LPAREN expression RPAREN statement ELSE statement
		{$$ = new SymbolInfo();fprintf(fp3 , "At line %d : statement -> IF LPAREN expression RPAREN statement ELSE statement\n",linecount);
		$$->SetName("if ( "+$3->GetName()+" ) "+$5->GetName() + " else \n" + $7->GetName());
		$$->SetType("void");
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());
		$$->code=$3->code;
		char *label=newLabel();
		char *label2=newLabel();
		$$->code+="mov ax, "+$3->getSymbol()+"\n";
		$$->code+="cmp ax, 0\n";
		$$->code+="je "+string(label)+"\n";
		$$->code+=$5->code+"\njmp "+string(label2)+"\n";
		$$->code+=string(label)+":\n";
		$$->code+=$7->code;
		$$->code+=string(label2)+":\n";}

	  | WHILE LPAREN expression RPAREN statement
		{$$ = new SymbolInfo();fprintf(fp3 , "At line %d : statement -> WHILE LPAREN expression RPAREN statement\n",linecount);
		$$->SetName("while ( "+$3->GetName()+" )\n "+$5->GetName());
		$$->SetType("void");
		char *label=newLabel();
		char *label2=newLabel();
		$$->code=string(label)+":\n"+$3->code;
		$$->code+="mov ax, "+$3->getSymbol()+"\n";
		$$->code+="cmp ax, 0\n";
		$$->code+="je "+string(label2)+"\n";
		$$->code+=$5->code + "jmp "+string(label) + "\n"+string(label2) + ":\n";
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());}

	  | PRINTLN LPAREN ID RPAREN SEMICOLON   //mov value to ax and call print function
		{
		$$ = new SymbolInfo();
		fprintf(fp3 , "At line %d : statement -> PRINTLN LPAREN ID RPAREN SEMICOLON\n",linecount);
		$$->SetName($1->GetName()+" ( "+$3->GetName()+" ) ;\n");
		$$->SetType("void");
		SymbolInfo *s = table->LookUpAll($3->GetName());
		$$->code="mov ax , "+s->getSymbol()+"\ncall PRINT_NUMBER\n";
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());}

	  | RETURN expression SEMICOLON     //make a new temp and stack push , pop in func_call rule
		{$$ = new SymbolInfo();fprintf(fp3 , "At line %d : statement ->  RETURN expression SEMICOLON\n",linecount);
		$$->SetName("return "+$2->GetName()+";\n");
		$$->SetType($2->GetType());
		if($2->GetType().compare("void")==0)
		{
		char msg[50];errorcount++;
		sprintf(msg,"%s","Void can not be assigned");
		yyerror1(msg);}
		//here probably we need to check if the return type matches the function declaration
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());
		$$->code=$2->code;
		$$->setSymbol($2->getSymbol());
		$$->code+="mov ax , "+ $2->getSymbol()+"\npush ax\n";}
	  ;
	  
expression_statement 	: SEMICOLON			//no assem needed
		{$$ = new SymbolInfo(";\n","void");
		fprintf(fp3 , "At line %d : expression_statement -> SEMICOLON\n",linecount);
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());}

		| expression SEMICOLON 
		{$$ = new SymbolInfo();
		fprintf(fp3 , "At line %d : expression_statement -> expression SEMICOLON\n",linecount);
		$$->SetName($1->GetName()+ ";\n");
		$$->SetType($1->GetType());
		$$->setSymbol($1->getSymbol());
		$$->code = $1->code;
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());
		table->PrintAll(fp3);
		}
			;
	  
variable : ID 		
		{//bool flag=false;
		fprintf(fp3 , "At line %d : variable -> ID\n",linecount);
		SymbolInfo *s = table->LookUpAll($1->GetName());
		if(s->GetName().empty()==false) //can be present in ST
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
		//$$->setSymbol(s->GetName());
		} 
		}
		else
		{//not found anywhere
		$$=new SymbolInfo($1->GetName(),"invalid");
		char msg[30];errorcount++;
		sprintf(msg,"%s","Undefined variable");
		yyerror1(msg);
		}
		//$$->setSymbol($1->GetName());  //omit this later
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());}

	 | ID LTHIRD expression RTHIRD 
		{fprintf(fp3 , "At line %d : variable -> ID LTHIRD expression RTHIRD\n",linecount);
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
		if(s->GetName().empty()==false) //can be present in ST
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
		{$$=new SymbolInfo($1->GetName()+"["+$3->GetName()+"]",s->GetType());
		$$->setSymbol(s->getSymbol());}
		} 
		}
		else
		{//not found anywhere
		$$=new SymbolInfo($1->GetName()+"["+$3->GetName()+"]","invalid");
		char msg[30];errorcount++;
		sprintf(msg,"%s","Undefined variable");
		yyerror1(msg);
		}

		$$->flag=1;
		//$$->setSymbol($1->GetName());  //omit this later
		$$->code=$3->code+"mov bx, " +$3->getSymbol() +"\nadd bx, bx\n";

		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());
		}
	 ;
	 
expression : logic_expression	
		{$$ = $1;
		fprintf(fp3 , "At line %d : expression -> logic_expression\n",linecount);
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());}

	   | variable ASSIGNOP logic_expression
		{$$ = new SymbolInfo();
		fprintf(fp3 , "At line %d : expression -> variable ASSIGNOP logic_expression \n",linecount);
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
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());
		$$->code=$3->code+$1->code;
		$$->code+="mov ax, "+$3->getSymbol()+"\n";
		if($1->flag==0){//not an array
		$$->code+= "mov "+$1->getSymbol()+", ax\n";
		}
		else{
		$$->code+= "mov "+$1->getSymbol()+"[bx], ax\n";
		}
		}
	   ;
			
logic_expression : rel_expression 	
		{$$ = $1;
		fprintf(fp3 , "At line %d : logic_expression ->  rel_expression\n",linecount);
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());}

		 | rel_expression LOGICOP rel_expression
		{$$ = new SymbolInfo();
		fprintf(fp3 , "At line %d : logic_expression ->  rel_expression LOGICOP rel_expression\n",linecount);
		$$->SetName($1->GetName()+" "+$2->GetName()+" "+$3->GetName());
		$$->SetType("int");
		if($3->GetType().compare("void")==0 ||$1->GetType().compare("void")==0){
		char msg[50];errorcount++;$$->SetType("int");
		sprintf(msg,"%s","Void can not be a part of expression");
		yyerror1(msg);}
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());
		$$->code=$1->code;
		char *label=newLabel();
		char *temp=newTemp();
		char *label2=newLabel();
		if($2->GetName()=="&&"){
		/* Check whether both operands value is 1. If both are one set value of a temporary variable to 1 otherwise 0*/
			$$->code+="cmp "+ $1->getSymbol() + " ,0\nje "+ string(label)+"\n";
			$$->code+=$3->code;
			$$->code+="cmp "+ $3->getSymbol() + " ,0\nje "+ string(label)+"\nmov "+string(temp)+" , 1\njmp "+ string(label2)+"\n";
			$$->code+=string(label)+":\nmov "+string(temp)+" , 0\n"+string(label2)+":\n";
					}
		else if($2->GetName()=="||"){
			$$->code+="cmp "+ $1->getSymbol() + " ,1\nje "+ string(label)+"\n";
			$$->code+=$3->code;
			$$->code+="cmp "+ $3->getSymbol() + " ,1\nje "+ string(label)+"\nmov "+string(temp)+" , 0\njmp "+ string(label2)+"\n";
			$$->code+=string(label)+":\nmov "+string(temp)+" , 1\n"+string(label2)+":\n";	
		}
		$$->setSymbol(temp);	
		}
		 ;
			
rel_expression	: simple_expression 
		{$$ = $1;
		fprintf(fp3 , "At line %d : rel_expression ->  simple_expression\n",linecount);	
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());
		}

		| simple_expression RELOP simple_expression	
		{$$ = new SymbolInfo();fprintf(fp3 , "At line %d : rel_expression ->  simple_expression RELOP simple_expression\n",linecount);
		$$->SetName($1->GetName()+" "+$2->GetName()+" "+$3->GetName());
		$$->SetType("int"); 
		if($3->GetType().compare("void")==0 ||$1->GetType().compare("void")==0){
		char msg[50];errorcount++;$$->SetType("int");
		sprintf(msg,"%s","Void can not be a part of expression");
		yyerror1(msg);}
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());

		$$->code=$1->code;
		$$->code+=$3->code;
		$$->code+="mov ax, " + $1->getSymbol()+"\n";
		$$->code+="cmp ax, " + $3->getSymbol()+"\n";
		char *temp=newTemp();
		char *label1=newLabel();
		char *label2=newLabel();
		if($2->GetName()=="<"){
			$$->code+="jl " + string(label1)+"\n";
		}
		else if($2->GetName()=="<="){
			$$->code+="jle " + string(label1)+"\n";
		}
		else if($2->GetName()==">"){
			$$->code+="jg " + string(label1)+"\n";
		}
		else if($2->GetName()==">="){
			$$->code+="jge " + string(label1)+"\n";
		}
		else if($2->GetName()=="=="){
			$$->code+="je " + string(label1)+"\n";
		}
		else{
			$$->code+="jne " + string(label1)+"\n";
		}
		$$->code+="mov "+string(temp) +" , 0\n";
		$$->code+="jmp "+string(label2) +"\n";
		$$->code+=string(label1)+":\nmov "+string(temp)+" , 1\n";
		$$->code+=string(label2)+":\n";
		$$->setSymbol(temp);}
		;
				
simple_expression : term 
		{$$ = $1;
		fprintf(fp3 , "At line %d : simple_expression ->  term\n",linecount);
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());}

		  | simple_expression ADDOP term 
		{$$ = new SymbolInfo();
		fprintf(fp3 , "At line %d : simple_expression ->  simple_expression ADDOP term \n",linecount);
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
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());
		char *temp=newTemp();
		$$->code=$1->code;
		$$->code+=$3->code;
		$$->setSymbol(temp);
/* move one of the operands to a register, perform addition or subtraction with the other operand and move the result in a temp variable*/ 			
		$$->code+="mov ax , "+$1->getSymbol()+"\n";	
		if($2->GetName()=="+"){	
		$$->code+="add ax,"+$3->getSymbol()+"\nmov "+string(temp)+" , ax\n";	
		}
		else{
		$$->code+="sub ax,"+$3->getSymbol()+"\nmov "+string(temp)+" , ax\n";	
		}
		} 
		  ;
					
term :	unary_expression
		{$$ = $1;
		fprintf(fp3 , "At line %d : term -> unary_expression\n",linecount);
		fprintf(fp3 , "\n %s \n\n", $$->GetName().c_str());}

     |  term MULOP unary_expression
		{$$ = new SymbolInfo();fprintf(fp3 , "At line %d : term -> term MULOP unary_expression\n",linecount);
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
		fprintf(fp3 , "\n%s \n\n" , $$->GetName().c_str());

		$$->code=$1->code;
		$$->code += $3->code;
		$$->code += "mov ax, "+ $1->getSymbol()+"\n";
		$$->code += "mov bx, "+ $3->getSymbol() +"\n";
		char *temp=newTemp();
		if($2->GetName()=="*"){
			$$->code += "mul bx\n";
			$$->code += "mov "+ string(temp) + " , ax\n";
			
		}
		else if($2->GetName()=="/"){
					// clear dx, perform 'div bx' and mov ax to temp
			$$->code += "xor dx,dx\ndiv bx\n";
			$$->code += "mov "+ string(temp) + " , ax\n";
		}
		else{
			// clear dx, perform 'div bx' and mov dx to temp
			$$->code += "xor dx,dx\ndiv bx\n";
			$$->code += "mov "+ string(temp) + " , dx\n";
		}
		$$->setSymbol(temp);} 
     ;

unary_expression : ADDOP unary_expression 
		{$$ = new SymbolInfo();fprintf(fp3 , "At line %d : unary_expression -> ADDOP unary_expression\n",linecount);
		$$->SetName($1->GetName()+" "+$2->GetName());
		$$->SetType($2->GetType());
		if($2->GetType().compare("void")==0){
		char msg[50];errorcount++;
		$$->SetType("int");
		sprintf(msg,"%s","Void can not be a part of expression");
		yyerror1(msg);}
		fprintf(fp3 , "\n %s \n\n", $$->GetName().c_str());
		char *temp=newTemp();
		if($1->GetName()=="+"){
			/*$$->code="mov ax, " + $2->getSymbol() + "\n";
			$$->code+="inc ax\n";
			$$->code+="mov "+string(temp)+", ax";*/
		}
		else{
			$$->code="mov ax , " + $2->getSymbol() + "\n";
			$$->code+="neg ax\n";
			$$->code+="mov "+string(temp)+" , ax\n";
		}
		$$->setSymbol(temp);
		} 

		 | NOT unary_expression 
		{$$ = new SymbolInfo();fprintf(fp3 , "At line %d : unary_expression -> NOT unary_expression \n",linecount);
		$$->SetName("!"+$2->GetName());
		$$->SetType("int");
		if($2->GetType().compare("void")==0){
		char msg[50];errorcount++;
		sprintf(msg,"%s","Void can not be a part of expression");
		yyerror1(msg);}
		fprintf(fp3 , "\n %s \n\n", $$->GetName().c_str());
		char *temp=newTemp();
		$$->code="mov ax , " + $2->getSymbol() + "\n";
		$$->code+="not ax\n";
		$$->code+="mov "+string(temp)+" , ax\n";
		$$->setSymbol(temp);} 

		 | factor 
		{$$ = $1;
		fprintf(fp3 , "At line %d : unary_expression -> factor\n",linecount);
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());} 
		 ;
	
factor	: variable
		{$$ = $1;
		fprintf(fp3 , "At line %d : factor -> variable\n",linecount);
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());
		if($$->flag==0){//do i need to do ath here?
				
		}
		else{
				char *temp= newTemp();
				$$->code+="mov ax , " + $1->getSymbol() + "[bx]\n";
				$$->code+= "mov " + string(temp) + " , ax\n";
				$$->setSymbol(temp);
			}} 

	| ID LPAREN argument_list RPAREN //function call 
		{$$ = new SymbolInfo();
		fprintf(fp3 , "At line %d : factor -> ID LPAREN argument_list RPAREN\n",linecount);
		$$->SetName($1->GetName() + "( " + $3->GetName() + " )");
		SymbolInfo *s=table->LookUpAll($1->GetName());
		$1=s;
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
		char *temp=newTemp();
		$$->setSymbol(temp);
		if(currfunc.compare($1->GetName())==0)   ///push variables if recursive call
		{
		$$->code=table->pushcode()+"push "+$1->GetDef()+"\n";
		}
		$$->code+=$3->code+"call "+$1->GetName()+"\n";
		if(($1->GetReturnType().compare("int")==0)||($1->GetReturnType().compare("float")==0)) //retrieve return value
		{$$->code+="pop "+string(temp)+"\n";}   
		if(currfunc.compare($1->GetName())==0)    //pop variables if recursive call
		{
		$$->code+="pop "+$1->GetDef()+"\n"+table->popcode();
		}
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());}

	| LPAREN expression RPAREN
		{$$ = $2;
		fprintf(fp3 , "At line %d : factor -> LPAREN expression RPAREN\n",linecount);
		$$->SetName("( " + $2->GetName() + " )" );
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());	}

	| CONST_INT 
		{$$ = new SymbolInfo();
		fprintf(fp3 , "At line %d : factor -> CONST_INT\n",linecount);
		$$->SetName($1->GetName());
		$$->SetType("int");
		$$->setSymbol($1->GetName());
		fprintf(fp3 , "\n %s \n\n", $$->GetName().c_str());	}

	| CONST_FLOAT
		{$$ = new SymbolInfo();
		fprintf(fp3 , "At line %d : factor -> CONST_FLOAT\n",linecount);
		$$->SetName($1->GetName());
		$$->SetType("float");
		$$->setSymbol($1->GetName());
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());	}

	| variable INCOP 
		{$$ = new SymbolInfo();
		fprintf(fp3 , "At line %d : factor -> variable INCOP\n",linecount);
		$$->SetName($1->GetName() + "++" );
		if($1->GetType().compare("float")==0)
		{char msg[50];errorcount++;
		sprintf(msg,"%s","Integer operand on increment operator");
		yyerror1(msg);}
		$$->SetType("int");
		$$->code=$1->code;
		$$->code+="mov ax , " + $1->getSymbol() + "\ninc ax\n";
		$$->code+="mov "+$1->getSymbol()+" , ax\n";
		fprintf(fp3 ,"\n %s \n\n" , $$->GetName().c_str());}

	| variable DECOP
		{$$ = new SymbolInfo();
		fprintf(fp3 , "At line %d : factor -> variable DECOP\n",linecount);
		$$->SetName($1->GetName() + "--" );
		if($1->GetType().compare("float")==0)
		{char msg[50];errorcount++;
		sprintf(msg,"%s","Integer operand on decrement operator");
		yyerror1(msg);}
		$$->SetType("int");
		$$->code=$1->code;
		$$->code+="mov ax , " + $1->getSymbol() + "\ndec ax\n";
		$$->code+="mov "+$1->getSymbol()+" , ax\n";
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());	}
	;
	
argument_list : arguments
		{$$ = new SymbolInfo();
		fprintf(fp3 , "At line %d : argument_list -> arguments\n",linecount);
		$$=$1;
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());}

			  |
		{$$ = new SymbolInfo();
		fprintf(fp3 , "At line %d : argument_list -> empty\n",linecount);
		$$->SetName(" ");
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());}
			  ;
	
arguments : arguments COMMA logic_expression		//push the arg value so that we can retrieve in the function def
		{$$ = new SymbolInfo();
		fprintf(fp3 , "At line %d : arguments -> arguments COMMA logic_expression\n",linecount);
		$3->next = $1; 
		$$ = $3;
		$$->SetName($1->GetName() + " , " + $3->GetName());
		$$->code= $1->code +$3->code +"mov ax , "+$3->getSymbol()+"\npush ax\n";
		fprintf(fp3 ,"\n %s \n\n" , $$->GetType().c_str());}

	      | logic_expression
		{$$ = new SymbolInfo();fprintf(fp3 , "At line %d : unary_expression -> logic_expression\n",linecount);
		$$->SetName($1->GetName());
		$$->SetType($1->GetType());
		$$->setSymbol($1->getSymbol());
		$$->code = $1->code +"mov ax , "+$1->getSymbol()+"\npush ax\n";
		fprintf(fp3 , "\n %s \n\n" , $$->GetName().c_str());}
	      ;
 

%%
int main(int argc,char *argv[])
{

	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}

	if((fp2= fopen("log.txt","w"))==NULL)
	{
		printf("Cannot Open File 2.\n");
		exit(1);
	}
	fclose(fp2);

	if((fp3= fopen("parserlog.txt","w"))==NULL)
	{
		printf("Cannot Open File 3.\n");
		exit(1);
	}
	fclose(fp3);
	
	fp2= fopen("log.txt","a"); // log file
	fp3= fopen("parserlog.txt","a"); // parser log file
	
	tokenout= fopen("token.txt","w");
	yyin=fp;

	fout.open("code.asm");
	yyparse();
	
	table->PrintCurrent(fp3);
	fprintf(fp2,"\nTotal Line : %d\n\n",linecount);
	fprintf(fp2,"\nTotal Error : %d\n\n",errorcount);
	fclose(fp2);
	fclose(fp3);
	fclose(tokenout);
	return 0;
}
