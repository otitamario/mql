//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

input datetime validade=__DATETIME__;//Data de validade
input int conta=9011600;//Conta
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()

//+------------------------------------------------------------------+

  {

//  string text="The quick brown fox jumps over the lazy dog";
   string text=IntegerToString(conta)+"_"+TimeToString(validade,TIME_DATE|TIME_SECONDS);
   string keystr="1njanrhdkCnsahrebfdMvbjo32hqnd31";

   uchar src[],dst[],key[];

//--- prepare key

   StringToCharArray(keystr,key);

//--- copy text to source array src[]

   StringToCharArray(text,src);

//--- print initial data

   PrintFormat("Initial data: size=%d, string='%s'",ArraySize(src),CharArrayToString(src));

//--- encrypt src[] with AES 256-bit key in key[]

   int res=CryptEncode(CRYPT_AES256,src,key,dst);

//--- check error

   if(res>0)

     {

      //--- print encrypted data
      string senha=ArrayToHex(dst);
      PrintFormat("Encoded data: size=%d %s",res,senha);
      Alert(senha);

      //--- decode dst[] to src[]

      //--- decrypt dst[] with AES 256-bit key in key[]

      res=CryptDecode(CRYPT_AES256,dst,key,src);

      //--- check error     

      if(res>0)

        {

         //--- print decoded data

        PrintFormat("Decoded data: size=%d, string='%s'",ArraySize(src),CharArrayToString(src));
        }

      else

         Print("Error in CryptDecode. Error code=",GetLastError());

     }

   else

      Print("Error in CryptEncode. Error code=",GetLastError());

   return INIT_SUCCEEDED;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ArrayToHex(uchar &arr[],int count=-1)

  {

   string res="";

//--- check

   if(count<0 || count>ArraySize(arr))

      count=ArraySize(arr);

//--- transform to HEX string

   for(int i=0; i<count; i++)

      res+=StringFormat("%.2X",arr[i]);

//---

   return(res);

  }
