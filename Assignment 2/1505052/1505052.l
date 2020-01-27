%option noyywrap

%{
#include <bits/stdc++.h>
using namespace std;

int position ;
int index1;
int linecount = 1;
int errorcount = 0;
FILE *logout;
FILE *tokenout;

class SymbolInfo
{
    string name;
    string type;
public:
    SymbolInfo * next;

    SymbolInfo( )
    {
        this->next = this;//initialized ./1505052_outfile.out scanner.txt

    }

    string GetName()
    {
        return this->name;
    }

    void SetName(string name)
    {
        this->name = name;
    }

    string GetType()
    {
        return this->type;
    }

    void SetType(string type)
    {
        this->type = type;
    }

};

class ScopeTable
{
    int hashlength;

public:
    ScopeTable * parent;
    SymbolInfo** symbolinfos; // chain of the symbols stored
    int id; //identifier

    ScopeTable(int hashlength)
    {
        this->hashlength = hashlength;
        this->parent = this; //to detect the parent table
        symbolinfos = new SymbolInfo*[hashlength]; // fixed size of bucket
        for(int i = 0; i <hashlength; i++)
        {
            symbolinfos[i] = new SymbolInfo(); //initializing each bucket
        }
    }

    ~ScopeTable()
    {
        free(parent);
        for(int i=0; i<hashlength; i++)
            delete[] symbolinfos[i];
        symbolinfos =0;
    }

    int Hashkey(string word) //generated the hash key
    {
        int key = 0;
        for(int i=0; i<word.size(); i++)
            key = key + (word[i]*(i+1));
        key = key%hashlength;
        return key;
    }

    bool Insert(string Name, string Type)
    {
        SymbolInfo* symbol = LookUp(Name);
        if(symbol->GetName().empty()) // if the first element
        {
            symbol->SetName(Name);
            symbol->SetType(Type);
            return true;
        }
        else if(symbol->GetName().compare(Name)!=0)//could not find
        {
            SymbolInfo* newsymbol = new SymbolInfo();
            //newsymbol->next = newsymbol;
            symbol->next = newsymbol;
            newsymbol->SetName(Name);
            newsymbol->SetType(Type);
            position++;//value wasn't found , a new one is added at next pos
            return true;
        }
	else if((symbol->GetType().compare(Type)!=0))
	{
	    SymbolInfo* newsymbol = new SymbolInfo();
            //newsymbol->next = newsymbol;
            symbol->next = newsymbol;
            newsymbol->SetName(Name);
            newsymbol->SetType(Type);
            position++;//value wasn't found , a new one is added at next pos
            return true;
	}
        return false;
    }

    SymbolInfo* LookUp(string Name)
    {FILE *logout;
FILE *tokenout;
        SymbolInfo* symbol;
        position = 0;
        index1 = Hashkey(Name); //find the root element
        symbol = symbolinfos[index1];
        while(1)
        {
            if(symbol->GetName().compare(Name)==0)//checks if it matches
                break;
            if(symbol->next==symbol)//finds the last element
                break;
            symbol = symbol->next;
            position++;
        }
        return symbol;
    }

    bool Delete(string Name)
    {
        SymbolInfo *symbol, *parent, *branchmain;
        position = 0;
        index1 = Hashkey(Name);
        symbol = symbolinfos[index1];
        parent = symbol;
        branchmain = parent;
        while(1)
        {
            if(symbol->GetName().compare(Name)==0)//checks if it matches
                break;
            if(symbol->next==symbol)
                break;
            parent = symbol;
            symbol = symbol->next;
            position++;
        }
        if(symbol->GetName().compare(Name)==0)//value found
        {
            if(symbol==branchmain)//if it is the root element
            {
                if(symbol->next==symbol)//case 1 :it is the only element
                {
                    symbol->SetName("");
                    symbol->SetType("");
                }
                else //it is not the only element
                {
                    symbolinfos[index1] = symbol->next;
                    //free(symbol);
                }
            }
            else if(symbol->next==symbol)//it is the last element
            {
                parent->next = parent;
                //free(symbol);
            }
            else
            {
                parent->next = symbol->next;
                //free(symbol);
            }
            return true;
        }
        return false;
    }

    void Print()
    {
        SymbolInfo* symbol ;
        for(int i=0; i<hashlength; i++)
        {
            
            symbol = symbolinfos[i];
            if(symbol->GetName().empty())
                    continue;
	    //cout << i << ": " ;
	    fprintf(logout,"%d : ",i);
            while(1)
            {
                if(symbol->GetName().empty())
                    break;
                //cout<<"< "<<symbol->GetName()<<" , "<<symbol->GetType()<<" > ";
		fprintf(logout,"< %s : %s >",symbol->GetType().c_str(),symbol->GetName().c_str());
                if(symbol->next==symbol)
                    break;
                symbol = symbol->next;
            }
            //cout<<endl;
	    fprintf(logout,"\n");
        }
    }

};

class SymbolTable
{
    int hashlength;

public:
    ScopeTable * current;
    vector<ScopeTable*> scopetables ;// chain of the tables stored

    SymbolTable(int hashlength)
    {
        this->hashlength = hashlength;
        ScopeTable* mainscope = new ScopeTable(hashlength);
        mainscope->id = 1;
        //mainscope->parent = mainscope;
        current = mainscope;
        scopetables.push_back(mainscope);
    }

    ~SymbolTable()
    {
        free(current);
        scopetables.clear();
    }

    void EnterScope()
    {
        ScopeTable* newscope = new ScopeTable(hashlength);
        newscope->id = current->id + 1;
        newscope->parent = current;
        scopetables.push_back(newscope);
        current = newscope;
        cout<<"New ScopeTable with id "<<newscope->id<<" created"<<endl;
    }

    void ExitScope()
    {
        if(scopetables.empty())
        {
            cout<<"No scope available"<<endl;
            return;
        }
        cout<<"ScopeTable with id "<<current->id<<" removed"<<endl;
        current = current->parent;
        scopetables.pop_back();
    }

    bool Insert(string Name, string Type)
    {
        if(scopetables.empty())
        {
            //cout<<"No scope available"<<endl;
            return false;
        }
        bool flag = current->Insert(Name,Type);
        /*if(flag)
            cout<<"Inserted in ScopeTable# "<< current->id
                <<" at position "<<index1<< " , "<<position<<endl;
        else
            cout<<"<"<<Name<<" , "<<Type<<">"<<
            " already exists in current ScopeTable"<<endl;*/
        return flag;
    }

    bool Remove(string Name)
    {
        if(scopetables.empty())
        {
            cout<<"No scope available"<<endl;
            return false;
        }
        bool flag = current->Delete(Name);
        if(flag)
        {
            cout<<"Found in ScopeTable# "<<current->id
                <<" at position "<<index1<< " , "<<position<<endl;
            cout<<"Deleted entry at "<<index1<< " , "<<position
            <<" from current ScopeTable"<<endl;
        }
        else{
            cout<<"Not found"<<endl;
            cout<<Name<<" not found"<<endl;
        }
        return flag;
    }

    SymbolInfo* LookUp(string Name)
    {
        SymbolInfo* symbol;
        if(scopetables.empty())
        {
            cout<<"No scope available"<<endl;
            return symbol;
        }
        ScopeTable* temp = current;
        while(1)
        {
            symbol = temp->LookUp(Name);
            if(symbol->GetName().compare(Name)==0)
            {
                cout<<"Found in ScopeTable# " <<temp->id << " at position "
                    <<index1 << " , " <<position<<endl;
                break;
            }
            if(temp->parent==temp)
                break;
            temp = temp->parent;
        }
        if(symbol->GetName().compare(Name)!=0)
        {
            cout<<"Not Found "<<endl;
        }
        return symbol;
    }

    void PrintCurrent()
    {
        if(scopetables.empty())
        {
            cout<<"No scope available"<<endl;
            return;
        }
        cout<<"Scopetable# "<<current->id<< " :"<<endl;
        current->Print();
    }

    void PrintAll()
    {
        if(scopetables.empty())
        {
            cout<<"No scope available"<<endl;
            return;
        }
        ScopeTable* temp = current;
        while(1)
        {
	    fprintf(logout,"Scopetable# %d :\n",temp->id);
            //cout<<"Scopetable# "<<temp->id<< " :"<<endl;
            temp->Print();
            if(temp->parent==temp)
                break;
            temp = temp->parent;
            cout<<endl;
        }
    }
};

void FindAndReplace(string & data, string toSearch, string replaceStr)
{
	size_t pos = data.find(toSearch);
    while( pos != std::string::npos)
	{
		data.replace(pos, toSearch.size(), replaceStr);
		pos =data.find(toSearch, pos + toSearch.size());
	}
}

SymbolTable* symboltable = new SymbolTable(10);

%}

Numeric [0-9]
AlphaNumeric [A-Za-z0-9_]
AlphaDash [A-Za-z_]

%%
[ \t\v]+ {}
[\n]			 {linecount++;}

(if|else|for|while|do|break|int|char|float|double|void|return|switch|case|default|continue)		{	int i = 0;
				char output[32];
  				char c;
  				while (yytext[i])
  				{
    				c=yytext[i];
    				output[i]=(toupper(c));
    				i++;
  				}
				fprintf(tokenout,"<%s> ",output);
				fprintf(logout,"Line %d : Token < %s > Lexeme %s found\n",linecount , output , yytext);}

[+-]			{	fprintf(tokenout,"<ADDOP, %s> ",yytext);
				fprintf(logout,"Line %d : Token <ADDOP> Lexeme %s found\n",linecount , yytext);}

[*/%]			{	fprintf(tokenout,"<MULOP, %s> ",yytext);
				fprintf(logout ,"Line %d : Token <MULOP> Lexeme %s found\n",linecount , yytext);}

([+]{2}|[-]{2})		{	fprintf(tokenout,"<INCOP, %s> ",yytext);
				fprintf(logout ,"Line %d : Token <INCOP> Lexeme %s found\n",linecount , yytext);}

(<|<=|>|>=|==|!=)	{	fprintf(tokenout,"<RELOP, %s>",yytext);
				fprintf(logout ,"Line %d : Token <RELOP> Lexeme %s found\n",linecount , yytext);}

=			{	fprintf(tokenout,"<ASSIGNOP, %s> ",yytext);
				fprintf(logout ,"Line %d : Token <ASSIGNOP> Lexeme %s found\n",linecount , yytext);}

(&|[|]|^|<<|>>)		{	fprintf(tokenout,"<BITOP, %s> ",yytext);
				fprintf(logout ,"Line %d : Token <BITOP> Lexeme %s found\n",linecount , yytext);}

(&&|[|]{2})		{	fprintf(tokenout,"<LOGICOP, %s> ",yytext);
				fprintf(logout ,"Line %d : Token <LOGICOP> Lexeme %s found\n",linecount , yytext);}

!			{	fprintf(tokenout,"<NOT, %s> ",yytext);
				fprintf(logout ,"Line %d : Token <NOT> Lexeme %s found\n",linecount , yytext);}

\(			{	fprintf(tokenout,"<LPAREN, %s>",yytext);
				fprintf(logout ,"Line %d : Token <LPAREN> Lexeme %s found\n",linecount , yytext);}

\)			{	fprintf(tokenout,"<RPAREN, %s> ",yytext);
				fprintf(logout ,"Line %d : Token <RPAREN> Lexeme %s found\n",linecount , yytext);}

\{			{	fprintf(tokenout,"<LCURL, %s>",yytext);
				fprintf(logout ,"Line %d : Token <LCURL> Lexeme %s found\n",linecount , yytext);}

\}			{	fprintf(tokenout,"<RCURL, %s> ",yytext);
				fprintf(logout ,"Line %d : Token <RCURL> Lexeme %s found\n",linecount , yytext);}

\[			{	fprintf(tokenout,"<LTHIRD, %s> ",yytext);
				fprintf(logout ,"Line %d : Token <LTHIRD> Lexeme %s found\n",linecount , yytext);}

\]			{	fprintf(tokenout,"<RTHIRD, %s> ",yytext);
				fprintf(logout ,"Line %d : Token <RTHIRD> Lexeme %s found\n",linecount , yytext);}

,			{	fprintf(tokenout,"<COMMA, %s> ",yytext);
				fprintf(logout ,"Line %d : Token <COMMA> Lexeme %s found\n",linecount , yytext);}

;			{	fprintf(tokenout,"<SEMICOLON, %s> ",yytext);
				fprintf(logout ,"Line %d : Token <SEMICOLON> Lexeme %s found\n",linecount , yytext);}

-?{Numeric}+		{	fprintf(tokenout,"<CONST_INT, %s> ",yytext);
				fprintf(logout ,"Line %d : Token <CONST_INT> Lexeme %s found\n",linecount , yytext);
				bool flag = symboltable->Insert(yytext,"CONST_INT");
				if(flag)symboltable->PrintAll();}

-?{Numeric}*[.]{Numeric}*([.]{Numeric}*)+	{errorcount++;
fprintf(logout ,"Error %d at Line %d : Too many decimal point error %s \n",errorcount,linecount , yytext);}

-?{Numeric}*([.]{Numeric}*)*(E(-)*{Numeric}*[.]+(-)*{Numeric}*[.]*(-)*{Numeric}*)+				{errorcount++;
fprintf(logout ,"Error %d at Line %d : Ill formed number %s \n",errorcount,linecount , yytext);}

-?{Numeric}*[.]?{Numeric}+(E[-]?{Numeric}+)?	{fprintf(tokenout,"<CONST_FLOAT, %s> ",yytext);
				fprintf(logout ,"Line %d : Token <CONST_FLOAT> Lexeme %s found\n",linecount , yytext);
				bool flag = symboltable->Insert(yytext,"CONST_FLOAT");
				if(flag)symboltable->PrintAll();}

['][^\\\n][^\\' \n]+[']?			{errorcount++;
fprintf(logout ,"Error %d at Line %d : Multi character constant error for %s character sequence\n",errorcount,linecount,yytext);}

['][^ \n]*[ ]		{errorcount++;
fprintf(logout ,"Error %d at Line %d : Unfinished character %s found\n",errorcount,linecount,yytext);}

['][^'\n]*[\n]		{errorcount++;
fprintf(logout ,"Error %d at Line %d : Unfinished character %s found\n",errorcount,linecount,yytext);
linecount++;}

['][^ \n][']			{if(yytext[1]=='\\'||yytext[1]=='\''){errorcount++;
fprintf(logout ,"Error %d at Line %d : Unfinished character %s found\n",errorcount,linecount,yytext);}
else{
fprintf(logout ,"Line %d : Token <CONST_CHAR> Lexeme %s found\n",linecount , yytext);
				string line(yytext);
    				stringstream iss(line);
    				string segment;
				getline(iss, segment, '\'');
				getline(iss, segment, '\'');
				fprintf(tokenout,"<CONST_CHAR, %s> ",segment.c_str());
				bool flag = symboltable->Insert(yytext,"CONST_CHAR");
				if(flag)symboltable->PrintAll();}}

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
				if(chr == 's'){errorcount++;
				fprintf(logout ,"Error %d at Line %d : Unrecognized character %s  found\n",errorcount,linecount,yytext);}
				else{
				fprintf(logout ,"Line %d : Token <CONST_CHAR> Lexeme %s found\n",linecount , yytext);
				char *rough = (char*) malloc(2*sizeof(char));
				rough[0] = chr;
				rough[1] = '\0';
				fprintf(tokenout,"<CONST_CHAR, %s> ",rough);
				free(rough);
				bool flag = symboltable->Insert(yytext,"CONST_CHAR");
				if(flag)symboltable->PrintAll();
				}}

{AlphaDash}{AlphaNumeric}*	{fprintf(tokenout,"<ID, %s> ",yytext);
				fprintf(logout ,"Line %d : Token <ID> Lexeme %s found\n",linecount , yytext);
				bool flag = symboltable->Insert(yytext,"ID");
				if(flag)symboltable->PrintAll();}

{Numeric}+{AlphaDash}+		{errorcount++;
fprintf(logout ,"Error %d at Line %d :Invalid Suffix on numeric constant or invalid prefix on identifier for character sequence %s \n",errorcount,linecount , yytext);}

\"(\\(.|\n)|[^\\"\n])*\"  	{fprintf(logout ,"Line %d : Token <STRING> Lexeme %s found\n",linecount , yytext);
				string line(yytext);
    				stringstream iss(line);
    				string segment;
    				while(getline(iss, segment, '\n'))
   				linecount++;
				linecount--;
				FindAndReplace(line, "\\\\n", "\n");
				FindAndReplace(line, "\\n", "\n");	
				FindAndReplace(line, "\\t", "\t");
				FindAndReplace(line, "\\\\", "\\");
				//FindAndReplace(line, "\\a", "\a");
				//FindAndReplace(line, "\\f", "\f");
				//FindAndReplace(line, "\\r", "\r");
				//FindAndReplace(line, "\\b", "\b");
				//FindAndReplace(line, "\\v", "\v");
				FindAndReplace(line, "\\0", "\0");
				fprintf(tokenout,"<STRING, %s> ",line.c_str());}

\"(\\(.|\n)|[^\\"\n])*  	{errorcount++;
fprintf(logout ,"Error %d at Line %d : Unfininshed string %s found\n",errorcount,linecount , yytext);
				string line(yytext);
    				stringstream iss(line);
    				string segment;
    				while(getline(iss, segment, '\n'))
   				linecount++;
				linecount--;}

"//".*("\\\n".*)*		{fprintf(logout ,"Line %d : Token <COMMENT> Lexeme %s found\n",linecount , yytext);}

[/][*][^*]*[*]+([^*/][^*]*[*]+)*[/]     {string line(yytext);
    					stringstream iss(line);
    					string segment;
    					fprintf(logout ,"Line %d : Token <COMMENT> Lexeme %s found\n",linecount , yytext);
					while(getline(iss, segment, '\n'))
   					linecount++;
					linecount--;}

[/][*]([^*]*[\n]*)*[*]*([^*]*[\n]*)*[*]*	{string line(yytext);
    					stringstream iss(line);
    					string segment;
					errorcount++;
    					fprintf(logout ,"Error %d at Line %d : Unfinished comment %s found\n",errorcount,linecount,yytext);
					while(getline(iss, segment, '\n'))
   					{linecount++;
    					}
					linecount--;}
.
%%



int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout= fopen("log.txt","w");
	tokenout= fopen("token.txt","w");

	yyin= fin;
	yylex();
	symboltable->PrintAll();

	fprintf(logout ,"\nTotal Line : %d\n",linecount);
	fprintf(logout ,"Total Error : %d\n",errorcount);
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}
