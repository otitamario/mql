//+------------------------------------------------------------------+
//|                                                  CDictionary.mqh |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Vasiliy Sokolov."
#property link      "http://www.mql5.com"

#include <Object.mqh>
#include <Arrays\List.mqh>
//+------------------------------------------------------------------+
//| Container to store CObject elements                              |
//+------------------------------------------------------------------+
class KeyValuePair : public CObject
  {
private:
   string            m_string_key;    // Stores a string key.
   double            m_double_key;    // Stores a floating-point key.
   ulong             m_ulong_key;     // Stores an unsigned integer key.
   ulong             m_hash;
public:
   CObject          *object;
   KeyValuePair     *next_kvp;
   KeyValuePair     *prev_kvp;
   template<typename T>
                     KeyValuePair(T key,ulong hash,CObject *obj);
                    ~KeyValuePair();
   template<typename T>
   bool              EqualKey(T key);
   template<typename T>
   void              GetKey(T& gkey);
   ulong GetHash(){return m_hash;}
  };
//+------------------------------------------------------------------+
//| Default constructor.                                             |
//+------------------------------------------------------------------+
template<typename T>
void KeyValuePair::KeyValuePair(T key,ulong hash,CObject *obj)
  {
   m_hash=hash;
   string name=typename(key);
   if(name=="string")
      m_string_key=(string)key;
   else if(name=="double" || name=="float")
      m_double_key=(double)key;
   else
      m_ulong_key=(ulong)key;
   object=obj;
  }
  
template<typename T>
KeyValuePair::GetKey(T& gkey)
{
   string name=typename(gkey);
   if(name=="string")
      gkey = (T)m_string_key;
   else if(name=="double" || name=="float")
      gkey=(T)m_double_key;
   else
      gkey=(T)m_ulong_key;
}
//+------------------------------------------------------------------+
//| Destructor.                                                      |
//+------------------------------------------------------------------+
KeyValuePair::~KeyValuePair()
  {
   delete object;
  }
//+------------------------------------------------------------------+
//| Returns true, if keys are equal.                             |
//+------------------------------------------------------------------+
template<typename T>
bool KeyValuePair::EqualKey(T key)
  {
   string name=typename(key);
   if(name=="string")
      return m_string_key == (string)key;
   if(name=="double" || name=="float")
      return m_double_key == (double)key;
   else
      return m_ulong_key == (ulong)key;
  }
//+------------------------------------------------------------------+
//| An associative array or dictionary storing elements as           |
//| <key - value>. Where a key may be represented by any base type,  |
//| and a value may a CObject object.                                |
//+------------------------------------------------------------------+
class CDictionary
  {
private:
   int               m_array_size;
   int               m_total;
   bool              m_free_mode;
   bool              m_auto_free;
   int               m_index;
   ulong             m_hash;
   CList            *m_array[];
   struct DoubleValue{ double value;} dValue;
   struct ULongValue { ulong value; } lValue;

   KeyValuePair     *m_first_kvp;
   KeyValuePair     *m_current_kvp;
   KeyValuePair     *m_last_kvp;

   ulong             Adler32(string line);
   int               GetIndexByHash(ulong hash);
   template<typename T>
   ulong             GetHashByKey(T key);
   void              Resize();
   int               FindNextSimpleNumber(int number);
   int               FindNextLevel();
   void              Init(int capacity);

public:
                     CDictionary();
                     CDictionary(int capacity);
                    ~CDictionary();
   void              Compress(void);
   ///
   /// Returns the total number of items.
   ///
   int Total(void){return m_total;}
   /// Returns the element at key    
   template<typename T>
   CObject          *GetObjectByKey(T key);
   template<typename T>
   bool              AddObject(T key,CObject *value);
   template<typename T>
   bool              DeleteObjectByKey(T key);
   template<typename T>
   bool              ContainsKey(T key);
   template<typename T>
   void              GetCurrentKey(T& key);
   bool FreeMode(void) { return(m_free_mode); }
   void FreeMode(bool free_mode) { m_free_mode=free_mode;}
   void AutoFreeMemory(bool autoFree){m_auto_free=autoFree;}
   void              Clear();

   CObject          *GetNextNode(void);
   CObject          *GetPrevNode(void);
   CObject          *GetCurrentNode(void);
   CObject          *GetFirstNode(void);
   CObject          *GetLastNode(void);
   
  };
//+------------------------------------------------------------------+
//| Default constructor.                                             |
//+------------------------------------------------------------------+
CDictionary::CDictionary()
  {
   m_auto_free=true;
   Init(3);
  }
//+------------------------------------------------------------------+
//| Creates a dictionary with predefined capacity.       |
//+------------------------------------------------------------------+
CDictionary::CDictionary(int capacity)
  {
   m_auto_free=true;
   Init(capacity);
  }
//+------------------------------------------------------------------+
//| Destructor.                                                      |
//+------------------------------------------------------------------+
CDictionary::~CDictionary()
  {
   Clear();
  }
//+------------------------------------------------------------------+
//| Initializes the dictionary.                                      |
//+------------------------------------------------------------------+
void CDictionary::Init(int capacity)
  {
   m_free_mode=true;
   m_array_size=ArrayResize(m_array,capacity);
   m_index= 0;
   m_hash = 0;
   m_total=0;
  }
//+------------------------------------------------------------------+
//| Finds the next size of dictionary.                               |
//+------------------------------------------------------------------+
int CDictionary::FindNextLevel()
  {
   double value=4;
   for(int i=2; i<=31; i++)
     {
      value=MathPow(2.0,(double)i);
      if(value > m_total)return (int)value;
     }
   return (int)value;
  }
//+------------------------------------------------------------------+
//| Accepts a string and returns a hashing 32-bit number, which      |
//| characterizes this string.                                       |
//+------------------------------------------------------------------+
ulong CDictionary::Adler32(string line)
  {
   ulong s1 = 1;
   ulong s2 = 0;
   uint buflength=StringLen(line);
   uchar char_array[];
   ArrayResize(char_array,buflength,0);
   StringToCharArray(line,char_array,0,-1,CP_ACP);
   for(uint n=0; n<buflength; n++)
     {
      s1 = (s1 + char_array[n]) % 65521;
      s2 = (s2 + s1)     % 65521;
     }
   return ((s2 << 16) + s1);
  }
//+------------------------------------------------------------------+
//| Calculates hash based on a transferred key. A key can be         |
//| any base MQL type.    
//+------------------------------------------------------------------+
template<typename T>
ulong CDictionary::GetHashByKey(T key)
  {
   ulong ukey = 0;
   string name=typename(key);
   if(name=="string")
      return Adler32((string)key);
   if(name=="double" || name=="float")
     {
      dValue.value=(double)key;
      lValue.value=(ulong)dValue.value;

;
      ukey=lValue.value;
     }
   else
      ukey=(ulong)key;
   return ukey;
  }
//+------------------------------------------------------------------+
//| Returns the key of current element                               |
//+------------------------------------------------------------------+
template<typename T>
void CDictionary::GetCurrentKey(T& key)
{
   m_current_kvp.GetKey(key);
}
//+------------------------------------------------------------------+
//| Returns index by key.                                            |
//+------------------------------------------------------------------+
int CDictionary::GetIndexByHash(ulong key)
  {
   return (int)(key%m_array_size);
  }
//+------------------------------------------------------------------+
//| Remove all values from dictionary                                |
//+------------------------------------------------------------------+
void CDictionary::Clear(void)
  {
   int size=ArraySize(m_array);
   for(int i=0; i<size; i++)
     {
      if(CheckPointer(m_array[i])!=POINTER_INVALID)
        {
         m_array[i].FreeMode(m_free_mode);
         delete m_array[i];
        }
     }
   ArrayFree(m_array);
   if(m_auto_free)
      Init(3);
   else
      Init(size);
   m_first_kvp=m_last_kvp=m_current_kvp=NULL;
  }
//+------------------------------------------------------------------+
//| Resizes data storage container.                                  |
//+------------------------------------------------------------------+
void CDictionary::Resize(void)
  {
   int level=FindNextLevel();
   int n=level;
   CList *temp_array[];
   ArrayCopy(temp_array,m_array);
   ArrayFree(m_array);
   m_array_size=ArrayResize(m_array,n);
   int total=ArraySize(temp_array);
   KeyValuePair *kv=NULL;
   for(int i=0; i<total; i++)
     {
      if(temp_array[i]==NULL)continue;
      CList *list=temp_array[i];
      int count=list.Total();
      list.FreeMode(false);
      kv=list.GetFirstNode();
      while(kv!=NULL)
        {
         int index=GetIndexByHash(kv.GetHash());
         if(CheckPointer(m_array[index])==POINTER_INVALID)
            m_array[index]=new CList();
         list.DetachCurrent();
         m_array[index].Add(kv);
         kv=list.GetCurrentNode();
        }
      delete list;
     }
   int size=ArraySize(temp_array);
   ArrayFree(temp_array);
  }
//+------------------------------------------------------------------+
//| Compresses the dictionary.                                                 |
//+------------------------------------------------------------------+
CDictionary::Compress(void)
  {
   if(!m_auto_free)return;
   double koeff=m_array_size/(double)(m_total+1);
   if(koeff < 2.0 || m_total <= 4)return;
   Resize();
  }
//+------------------------------------------------------------------+
//| Returns an object by key.                                        |
//+------------------------------------------------------------------+
template<typename T>
CObject *CDictionary::GetObjectByKey(T key)
  {
   if(!ContainsKey(key))
      return NULL;
   return m_current_kvp.object;
  }
//+------------------------------------------------------------------+
//| Checks if dictionary contains a key of arbitrary T type.         |
//| RETURNS:                                                         |
//|   Returns true, if an object with this key already exists,       |
//|   otherwise returns false.                                       |
//+------------------------------------------------------------------+
template<typename T>
bool CDictionary::ContainsKey(T key)
  {
   m_hash=GetHashByKey(key);
   m_index=GetIndexByHash(m_hash);
   if(CheckPointer(m_array[m_index])==POINTER_INVALID)
      return false;
   CList *list=m_array[m_index];
   KeyValuePair *current_kvp=list.GetCurrentNode();
   if(current_kvp == NULL)return false;
   if(current_kvp.EqualKey(key))
     {
      m_current_kvp=current_kvp;
      return true;
     }
   current_kvp=list.GetFirstNode();
   while(true)
     {
      if(current_kvp.EqualKey(key))
        {
         m_current_kvp=current_kvp;
         return true;
        }
      current_kvp=list.GetNextNode();
      if(current_kvp==NULL)
         return false;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Adds CObject type element with a T key to the dictionary         |
//| INPUT PARAMETRS:                                                 |
//|   T key - any base type, for instance int, double or string.     |
//|   value - a class that derives from CObject.                         |
//| RETURNS:                                                         |
//|   True, if the element has been added, and false if otherwise.   |
//+------------------------------------------------------------------+
template<typename T>
bool CDictionary::AddObject(T key,CObject *value)
  {
   if(ContainsKey(key))
      return false;
   if(m_total==m_array_size)
   {
      Resize();
      ContainsKey(key);
   }
   if(CheckPointer(m_array[m_index])==POINTER_INVALID)
     {
      m_array[m_index]=new CList();
      m_array[m_index].FreeMode(m_free_mode);
     }
   KeyValuePair *kv=new KeyValuePair(key,m_hash,value);
   if(m_array[m_index].Add(kv)!=-1)
      m_total++;
   if(CheckPointer(m_current_kvp)==POINTER_INVALID)
     {
      m_first_kvp=kv;
      m_current_kvp=kv;
      m_last_kvp=kv;
     }
   else
     {
      //we add to the very end, because the current node can be anywhere 
      while(m_current_kvp.next_kvp != NULL)
         m_current_kvp = m_current_kvp.next_kvp;
      m_current_kvp.next_kvp=kv;
      kv.prev_kvp=m_current_kvp;
      m_current_kvp=kv;
      m_last_kvp=kv;
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Returns current object. Returns NULL if an object was not        |
//| NULL.                                                            |
//+------------------------------------------------------------------+
CObject *CDictionary::GetCurrentNode(void)
  {
   if(m_current_kvp==NULL)
      return NULL;
   return m_current_kvp.object;
  }
//+------------------------------------------------------------------+
//| Returns previous object. After call of method, the current       |
//| object becomes the previous one. If object not selected, returns |
//| NULL.                                                            |
//+------------------------------------------------------------------+
CObject *CDictionary:: GetPrevNode(void)
  {
   if(m_current_kvp==NULL)
      return NULL;
   if(m_current_kvp.prev_kvp==NULL)
      return NULL;
   KeyValuePair *kvp=m_current_kvp.prev_kvp;
   m_current_kvp=kvp;
   return kvp.object;
  }
//+------------------------------------------------------------------+
//| Returns the next object.     The current object becomes the next |
//| after call of the method. If object not selected, returns           |
//| NULL.                                                            |
//+------------------------------------------------------------------+
CObject *CDictionary::GetNextNode(void)
  {
   if(m_current_kvp==NULL)
      return NULL;
   if(m_current_kvp.next_kvp==NULL)
      return NULL;
   KeyValuePair *kvp=m_current_kvp.next_kvp;
   m_current_kvp=kvp;
   return kvp.object;
  }
//+------------------------------------------------------------------+
//| Returns first node in the node list. If dictionary has no nodes  |
//| it returns NULL.                                                 |
//+------------------------------------------------------------------+
CObject *CDictionary::GetFirstNode(void)
  {
   if(m_first_kvp==NULL)
      return NULL;
   m_current_kvp=m_first_kvp;
   ulong hash=m_first_kvp.GetHash();
   return m_first_kvp.object;
  }
//+------------------------------------------------------------------+
//| Returns last node in the node list. If dictionary has no nodes   |
//| it returns NULL.                                                 |
//+------------------------------------------------------------------+
CObject *CDictionary::GetLastNode(void)
  {
   if(m_last_kvp==NULL)
      return NULL;
   m_current_kvp=m_last_kvp;
   return m_last_kvp.object;
  }
//+------------------------------------------------------------------+
//| Deletes object with key from dictionary                          |
//+------------------------------------------------------------------+
template<typename T>
bool CDictionary::DeleteObjectByKey(T key)
  {
   if(!ContainsKey(key))
      return false;
   KeyValuePair* p_kvp = m_current_kvp.prev_kvp;
   KeyValuePair* n_kvp = m_current_kvp.next_kvp;
   if(CheckPointer(p_kvp)!=POINTER_INVALID)
      p_kvp.next_kvp=n_kvp;
   if(CheckPointer(n_kvp)!=POINTER_INVALID)
      n_kvp.prev_kvp=p_kvp;
   m_array[m_index].FreeMode(m_free_mode);
   bool res=m_array[m_index].DeleteCurrent();
   if(res)
     {
      m_total--;
      Compress();
     }
   return res;
  }
  
#define FOREACH_DICT(dict) for(CObject* node = (dict).GetFirstNode(); node != NULL; node = (dict).GetNextNode())
//+------------------------------------------------------------------+
