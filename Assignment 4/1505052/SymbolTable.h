#include <bits/stdc++.h>
using namespace std;
class SymbolInfo
{
    string name;
    string type;
    string def;
    string returntype;
    string sym;
public:
    SymbolInfo * next;
    SymbolInfo * parameter;
    string code;
    int flag;

    SymbolInfo( )
    {
        this->next = this;//initialized
	this->code = "";
	this->def = "";
	this->returntype = "";
    }

    SymbolInfo( string name,string type)
    {
        this->next = this;//initialized
	this->name = name;
	this->code = "";
	this->def = "";
	this->returntype = "";
	this->type = type;
    }

    string GetName()
    {
        return this->name;
    }

    void SetParam(SymbolInfo * parameter)
    {
	this->parameter = parameter;
    }

    SymbolInfo * GetParam()
    {
	return this->parameter;
    }

    void SetName(string name)
    {
        this->name = name;
    }

    string GetDef()
    {
        return this->def;
    }

    void SetDef(string def)
    {
        this->def = def;
    }

    string GetType()
    {
        return this->type;
    }

    void SetType(string type)
    {
        this->type = type;
    }


    string GetReturnType()
    {
        return this->returntype;
    }

    void SetReturnType(string returntype)
    {
        this->returntype = returntype;
    }

    string getSymbol()
    {
	return this->sym;
    }

    void setSymbol(string sym){
	this->sym = sym;
    }


    bool LookUp(string Name){ //this function is for checking uniqueness in parameter list
	SymbolInfo* symbol = this;
	while(1)
	{
	    if(symbol->GetName().compare(Name)==0)
	        return true;
	    if(symbol->next==symbol)//finds the last element
	        break;
	    symbol = symbol->next;
	}
	if(symbol->GetName().compare(Name)==0)
	return true;
	else
	return false;
	return false;
    }

    SymbolInfo* LookUpInfo(string Name){ //this function is for checking uniqueness in parameter list
	SymbolInfo* symbol = this;
	while(1)
	{
	    if(symbol->GetName().compare(Name)==0)
	        return symbol;
	    if(symbol->next==symbol)//finds the last element
	        break;
	    symbol = symbol->next;
	}
	return symbol;
    }

    bool Match(SymbolInfo* sym){ //this function is for verifying parameter list
	SymbolInfo* symbol = parameter;
	SymbolInfo* symbol1 = sym;
	if(symbol==NULL)
	return false;
	while(1)
	{
	    if(symbol->GetName().compare(symbol1->GetName())!=0 || symbol->GetType().compare(symbol1->GetType())!=0 )
	        return false;
	    if(symbol->next==symbol && symbol1->next==symbol1)//finds the last element
	        break;
	    else if(symbol->next==symbol && symbol1->next!=symbol1)
		return false;
	    else if(symbol->next!=symbol && symbol1->next==symbol1)
		return false;
	    symbol = symbol->next;
	    symbol1 = symbol1->next;
	}
	if(symbol->GetName().compare(symbol1->GetName())!=0 || symbol->GetType().compare(symbol1->GetType())!=0 )
	return false;
	else
	return true;
	return false;
    }

    bool Match2(SymbolInfo* sym){ //this function is for verifying argument list
	SymbolInfo* symbol = parameter;
	SymbolInfo* symbol1 = sym;
	if(symbol==NULL && symbol1->GetName().compare(" ")==0)
	return true;
	if(symbol==NULL)
	return false;
	if(symbol1==NULL)
	return false;
	while(1)
	{
	    if(symbol->GetType().compare(symbol1->GetType())!=0 )
	        return false;
	    if(symbol->next==symbol && symbol1->next==symbol1)//finds the last element
	        break;
	    else if(symbol->next==symbol && symbol1->next!=symbol1)
		return false;
	    else if(symbol->next!=symbol && symbol1->next==symbol1)
		return false;
	    symbol = symbol->next;
	    symbol1 = symbol1->next;
	}
	if(symbol->GetType().compare(symbol1->GetType())!=0 )
	return false;
	else
	return true;
	return false;
    }

};

class ScopeTable
{
    int hashlength;
    int position ;
    int index1;
public:
    ScopeTable * parent;
    SymbolInfo** symbolinfos; // chain of the symbols stored
    int id; //identifier
    string pushcode;
    string popcode;
    ScopeTable(int hashlength)
    {
        this->hashlength = hashlength;
        this->parent = this; //to detect the parent table
        symbolinfos = new SymbolInfo*[hashlength]; // fixed size of bucket
	pushcode = "";
	popcode = "";
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

    int getposition()
    {
        return position;
    }

    int getindex()
    {
        return index1;
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

    bool Insert2(string Name, string Type)
    {
        SymbolInfo* symbol = LookUp(Name);
        if(symbol->GetName().empty()) // if the first element
        {
            symbol->SetName(Name);
            symbol->SetType(Type);
	    symbol->setSymbol(Name+to_string(id));
	    this->pushcode+="push "+Name+to_string(id)+"\n";
	    this->popcode="pop "+Name+to_string(id)+"\n"+this->popcode;
            return true;
        }
        else if(symbol->GetName().compare(Name)!=0)//could not find
        {
            SymbolInfo* newsymbol = new SymbolInfo();
            //newsymbol->next = newsymbol;
            symbol->next = newsymbol;
            newsymbol->SetName(Name);
            newsymbol->SetType(Type);
	    symbol->setSymbol(Name+to_string(id));
	    this->pushcode+="push "+Name+to_string(id)+"\n";
	    this->popcode="pop "+Name+to_string(id)+"\n"+this->popcode;
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
	    symbol->setSymbol(Name+to_string(id));
	    this->pushcode+="push "+Name+to_string(id)+"\n";
	    this->popcode="pop "+Name+to_string(id)+"\n"+this->popcode;
            position++;//value wasn't found , a new one is added at next pos
            return true;
	}
        return false;
    }

    bool Update(string Name, string Type)
    {
        SymbolInfo* symbol = LookUp(Name);
        if(symbol->GetName().empty()) // if the first element
        {
            return false;
        }
        else if(symbol->GetName().compare(Name)!=0)//could not find
        {
            return false;
        }
	else if((symbol->GetType().compare("ID")==0)) //updating the type
	{
	    symbol->SetType(Type);
            return true;
	}
        return false;
    }

    SymbolInfo* LookUp(string Name)
    {
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

    void Print(FILE *fp2)
    {
        SymbolInfo* symbol ;
        for(int i=0; i<hashlength; i++)
        {
            symbol = symbolinfos[i];
            if(symbol->GetName().empty())
                    continue;
	    fprintf(fp2 , "%d :",i);
            while(1)
            {
                if(symbol->GetName().empty())
                    break;
		fprintf(fp2 , "< %s , %s , %s > ",symbol->GetName().c_str(),symbol->GetType().c_str(),symbol->getSymbol().c_str());
                //cout<<"< "<<symbol->GetName()<<" , "<<symbol->GetType()<<" > ";
                if(symbol->next==symbol)
                    break;
                symbol = symbol->next;
            }
           // cout<<endl;
		fprintf(fp2 ,"\n");
        }
    }

};

class SymbolTable
{
    int hashlength;
    int id;

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
	id=1;
        scopetables.push_back(mainscope);
    }

    ~SymbolTable()
    {
        free(current);
        scopetables.clear();
    }

    void EnterScope(FILE *fp2)
    {
        ScopeTable* newscope = new ScopeTable(hashlength);
        newscope->id = ++id;
        newscope->parent = current;
        scopetables.push_back(newscope);
        current = newscope;
	fprintf(fp2 , "New ScopeTable with id  %d created\n",newscope->id);
    }

    void ExitScope(FILE *fp2)
    {
        if(scopetables.empty())
        {
            //cout<<"No scope available"<<endl;
            return;
        }
	fprintf(fp2 , "ScopeTable with id  %d removed\n",current->id);
        current = current->parent;
        scopetables.pop_back();
    }

    bool Insert(string Name, string Type)
    {
        if(scopetables.empty())
        {
           // cout<<"No scope available"<<endl;
            return false;
        }
        bool flag = current->Insert(Name,Type);
        /*if(flag)
            cout<<"Inserted in ScopeTable# "<< current->id
                <<" at position "<<current->getindex()<< " , "<<current->getposition()<<endl;
        else
            cout<<"<"<<Name<<" , "<<Type<<">"<<
            " already exists in current ScopeTable"<<endl;*/
        return flag;
    }

    bool Insert2(string Name, string Type)
    {
        if(scopetables.empty())
        {
           // cout<<"No scope available"<<endl;
            return false;
        }
        bool flag = current->Insert2(Name,Type);
        /*if(flag)
            cout<<"Inserted in ScopeTable# "<< current->id
                <<" at position "<<current->getindex()<< " , "<<current->getposition()<<endl;
        else
            cout<<"<"<<Name<<" , "<<Type<<">"<<
            " already exists in current ScopeTable"<<endl;*/
        return flag;
    }

    bool Update(string Name, string Type)
    {
        if(scopetables.empty())
        {
           // cout<<"No scope available"<<endl;
            return false;
        }
        bool flag = current->Update(Name,Type);
        /*if(flag)
            cout<<"Updated in ScopeTable# "<< current->id
                <<" at position "<<current->getindex()<< " , "<<current->getposition()<<endl;
        else
            cout<<"<"<<Name<<" , "<<Type<<">"<<
            " does not exist in current ScopeTable"<<endl;*/
        return flag;
    }


    bool Remove(string Name)
    {
        if(scopetables.empty())
        {
           // cout<<"No scope available"<<endl;
            return false;
        }
        bool flag = current->Delete(Name);
        if(flag)
        {
            /*cout<<"Found in ScopeTable# "<<current->id
                <<" at position "<<current->getindex()<< " , "<<current->getposition()<<endl;
            cout<<"Deleted entry at "<<current->getindex()<< " , "<<current->getposition()
            <<" from current ScopeTable"<<endl;*/
        }
        else{
            //cout<<"Not found"<<endl;
            //cout<<Name<<" not found"<<endl;
        }
        return flag;
    }

    SymbolInfo* LookUpAll(string Name)
    {
        SymbolInfo* symbol;
        if(scopetables.empty())
        {
            //cout<<"No scope available"<<endl;
            return symbol;
        }
        ScopeTable* temp = current;
        while(1)
        {
            symbol = temp->LookUp(Name);
            if(symbol->GetName().compare(Name)==0)
            {
                //cout<<"Found in ScopeTable# " <<temp->id << " at position "
                  //  <<temp->getindex() << " , " <<temp->getposition()<<endl;
                break;
            }
            if(temp->parent==temp)
                break;
            temp = temp->parent;
        }
        if(symbol->GetName().compare(Name)!=0)
        {
           // cout<<"Not Found "<<endl;
        }
        return symbol;
    }

    SymbolInfo* LookUp(string Name)
    {
        SymbolInfo* symbol;
        if(scopetables.empty())
        {
           // cout<<"No scope available"<<endl;
            return symbol;
        }
        ScopeTable* temp = current;
        symbol = temp->LookUp(Name);
        return symbol;
    }

    void PrintCurrent(FILE *fp2)
    {
        if(scopetables.empty())
        {
		fprintf(fp2 , "No scope available");
            return;
        }
	fprintf(fp2 , "Scopetable# %d :\n",current->id);
        current->Print(fp2);
    }

    int getID()
    {
	return id;
    }

    string pushcode()
    {
	return current->pushcode;
    }


    string popcode()
    {
	return current->popcode;
    }

    void PrintAll(FILE *fp2)
    {
        if(scopetables.empty())
        {
            fprintf(fp2 , "No scope available");
            return;
        }
        ScopeTable* temp = current;
        while(1)
        {
            fprintf(fp2 , "Scopetable# %d :\n",temp->id);
            temp->Print(fp2);
            if(temp->parent==temp)
                break;
            temp = temp->parent;
	    fprintf(fp2 , "\n");
            //cout<<endl;
        }
    }
};


