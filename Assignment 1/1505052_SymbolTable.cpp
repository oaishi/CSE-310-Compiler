#include <bits/stdc++.h>
using namespace std;

int position ;
int index;

class SymbolInfo
{
    string name;
    string type;
public:
    SymbolInfo * next;

    SymbolInfo( )
    {
        this->next = this;//initialized
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
        return false;
    }

    SymbolInfo* LookUp(string Name)
    {
        SymbolInfo* symbol;
        position = 0;
        index = Hashkey(Name); //find the root element
        symbol = symbolinfos[index];
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
        index = Hashkey(Name);
        symbol = symbolinfos[index];
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
                    symbolinfos[index] = symbol->next;
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
            cout << i << ": " ;
            symbol = symbolinfos[i];
            while(1)
            {
                if(symbol->GetName().empty())
                    break;
                cout<<"< "<<symbol->GetName()<<" , "<<symbol->GetType()<<" > ";
                if(symbol->next==symbol)
                    break;
                symbol = symbol->next;
            }
            cout<<endl;
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
            cout<<"No scope available"<<endl;
            return false;
        }
        bool flag = current->Insert(Name,Type);
        if(flag)
            cout<<"Inserted in ScopeTable# "<< current->id
                <<" at position "<<index<< " , "<<position<<endl;
        else
            cout<<"<"<<Name<<" , "<<Type<<">"<<
            " already exists in current ScopeTable"<<endl;
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
                <<" at position "<<index<< " , "<<position<<endl;
            cout<<"Deleted entry at "<<index<< " , "<<position
            <<" from current ScopeTable"<<endl;
        }
        else{
            cout<<"Not found"<<endl;
            cout<<Name<<" not found"<<endl;
        }
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
                    <<index << " , " <<position<<endl;
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
            cout<<"Scopetable# "<<temp->id<< " :"<<endl;
            temp->Print();
            if(temp->parent==temp)
                break;
            temp = temp->parent;
            cout<<endl;
        }
    }
};


int main()
{
    int n;
    string Name, Type ;
    ifstream inFile;
    inFile.open("input.txt");
    if (!inFile)
    {
        cout << "Unable to open file";
        exit(1);
    }
    inFile >> n;
    SymbolTable* symboltable = new SymbolTable(n);
    string line;
    while (getline(inFile, line))
    {
        stringstream iss(line);
        string segment;
        vector<string> seglist;

        /*while(getline(iss, segment, ' '))
        {
            cout<<segment<<endl;
        }*/
        getline(iss, segment, ' ');
        if(segment.compare("I")==0)
        {
            cout<<segment<<" ";
            getline(iss, segment, ' ');
            Name = segment;
            getline(iss, segment, ' ');
            Type = segment;
            cout<<Name<<" "<<Type<<endl;
            cout<<endl;
            symboltable->Insert(Name,Type);
        }
        else if(segment.compare("S")==0)
        {
            cout<<segment<<" ";
            cout<<endl;
            symboltable->EnterScope();
        }
        else if(segment.compare("E")==0)
        {
            cout<<segment;
            cout<<endl;
            cout<<endl;
            symboltable->ExitScope();
        }
        else if(segment.compare("P")==0)
        {
            cout<<segment<<" ";
            getline(iss, segment, ' ');
            cout<<segment<<endl;
            cout<<endl;
            if(segment.compare("A")==0)
                symboltable->PrintAll();
            else if(segment.compare("C")==0)
                symboltable->PrintCurrent();
        }
        else if(segment.compare("D")==0)
        {
            cout<<segment<<" ";
            getline(iss, segment, ' ');
            cout<<segment<<endl;
            cout<<endl;
            symboltable->Remove(segment);
        }
        else if(segment.compare("L")==0)
        {
            cout<<segment<<" ";
            getline(iss, segment, ' ');
            cout<<segment<<endl;
            cout<<endl;
            symboltable->LookUp(segment);
        }
        cout<<endl;
    }
    inFile.close();
    return 0;
}
