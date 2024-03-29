//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#define VERSION "1.0"// Mudar aqui as Versões

#property copyright "Autor da Estratégia: Messias da Silva <trendbot@bol.com.br>"
#property version   VERSION
#property description   "AVISO DE ALTO RISCO: a negociação tem um alto nível de risco que pode não"
#property description   "ser adequado para todos os investidores. A alavancagem cria risco adicional"
#property description   "e exposição à perda. Antes de tomar qualquer decisão, considere cuidadosamente"
#property description   "seus objetivos de investimento, nível de experiência e tolerância ao risco."
#property description   "Você pode perder algum ou todo seu investimento inicial."
#property description   "Não invista dinheiro que não pode perder."


string keystr="892fb7a2097d7f0183c4c56498a36b00";
datetime data_validade;
string Only_Demo;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include<ChartObjects\ChartObjectsLines.mqh>
#include <Controls\Defines.mqh>
#undef CONTROLS_DIALOG_COLOR_BG
#undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#undef CONTROLS_DIALOG_COLOR_CAPTION_TEXT
//#undef CONTROLS_LABEL_COLOR  

color borda_bg=clrLightCyan;//Cor Borda
color painel_bg=clrNavy;//Cor Painel 
color cor_txt_borda_bg=clrBlue;//Cor Texto Borda
                               //color cor_txt_pn_bg=clrBlueViolet;//Cor Texto Painel

#define CONTROLS_DIALOG_COLOR_BG          borda_bg
#define CONTROLS_DIALOG_COLOR_CLIENT_BG   painel_bg
#define  CONTROLS_DIALOG_COLOR_CAPTION_TEXT cor_txt_borda_bg
//#define CONTROLS_LABEL_COLOR                cor_txt_pn_bg

#include <EAMessias\Params_CoyoteMy.mqh>
#include <EAMessias\HMAExp.mqh>

#include <Bcrypt.mqh>
CBcrypt B;

CAccountInfo      myaccount;
HMARobot MyHMAExp;

MyPanel ExtDialog;

CLabel            m_label[20];
CLabel            label_cotacao[20];
CLabel            label_porc[20];
CButton BotaoFechar;
CLabel Linha1;
CLabel Linha2;
CLabel Linha3;
CPanel painel;

#define LARGURA_PAINEL 310 // Largura Painel
#define ALTURA_PAINEL 220 // Altura Painel
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   if(!ChartSetInteger(ChartID(),CHART_SHIFT,0,50))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }

// TesterHideIndicators(true);

   if(!MQLInfoInteger(MQL_OPTIMIZATION))
     {
      if(!ExtDialog.Create(MyHMAExp,0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,ChartHeightInPixelsGet()-ALTURA_PAINEL,LARGURA_PAINEL,ChartHeightInPixelsGet()))
         return(INIT_FAILED);
      //--- run application 
      ExtDialog.Run();
     }
   return  MyHMAExp.OnInit();



//TesterHideIndicators(false);

//---
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   if(!ObjectDelete(0,"ViperImage"))
     {
      Print(__FUNCTION__,
            ": failed to delete \"Bitmap label\" object! Error code = ",GetLastError());
     }

   EventKillTimer();
//---
   if(!MQLInfoInteger(MQL_OPTIMIZATION))
     {
      ExtDialog.Destroy(reason);
      painel.Destroy(reason);
     }
   MyHMAExp.OnDeinit(reason);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {

   MyHMAExp.OnTimer();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
   MyHMAExp.OnTradeTransaction(trans,request,result);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   MyHMAExp.OnTick();
   if(!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.OnTick(MyHMAExp);


   if(!MQLInfoInteger(MQL_OPTIMIZATION))
     {
      if(ExtDialog.Height()!=ChartHeightInPixelsGet()-ALTURA_PAINEL)
        {
         ExtDialog.Move(0,ChartHeightInPixelsGet()-ALTURA_PAINEL);
         painel.Move(0,ChartHeightInPixelsGet()-ALTURA_PAINEL);
        }
      //ExtDialog.Minimized(false);
     }

  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID   
                  const long& lparam,   // event parameter of the long type 
                  const double& dparam, // event parameter of the double type 
                  const string& sparam) // event parameter of the string type 
  {
   if(!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
bool MyPanel::Create(T &MyEA,const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {

   int xx1 = INDENT_LEFT;
   int yy1 = INDENT_TOP;
   int xx2 = x1 + BUTTON_WIDTH;
   int yy2 = INDENT_TOP + BUTTON_HEIGHT;
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return (false);
   if(!CreatePanel(chart,subwin,painel,x1,y1,x2,y2))
      return (false);

//--- create dependent controls

   string s_estrateg="";
   if(Estrategia == StatBW)
      s_estrateg = "Bw-Wiseman";
   if(Estrategia == StatCAP)
      s_estrateg = "CAPZACK";
   if(Estrategia == StatCoyote)
      s_estrateg = "Coyote";
   if(Estrategia == StatMedCross)
      s_estrateg = "Média Cross";
   if(Estrategia == StatHMA)
      s_estrateg = "HMA";


   color cor_labels=clrDeepSkyBlue;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[0],"Estratégia: "+s_estrateg,xx1,yy1,xx2,yy2))
      return (false);

   m_label[0].Color(cor_labels);

   xx1 = INDENT_LEFT;
   yy1 = INDENT_TOP + BUTTON_HEIGHT + CONTROLS_GAP_Y;
   xx2 = xx1 + BUTTON_WIDTH;
   yy2 = yy1 + BUTTON_HEIGHT;

   string str_pos;
   if(!MyEA.PosicaoAberta())
      str_pos="Zerado";
   if(MyEA.Buy_opened())
      str_pos="Comprado";
   if(MyEA.Sell_opened())
      str_pos="Vendido";
   if(!CreateLabel(m_chart_id,m_subwin,m_label[1],"Posição: "+str_pos,xx1,yy1,xx2,yy2))
      return (false);
   m_label[1].Color(cor_labels);

   xx1 = INDENT_LEFT;
   yy1 = INDENT_TOP + 2 * BUTTON_HEIGHT + CONTROLS_GAP_Y;
   xx2 = xx1 + BUTTON_WIDTH;
   yy2 = yy1 + BUTTON_HEIGHT;

   string str_vol_pos;
   if(!MyEA.PosicaoAberta())
      str_vol_pos="-";
   if(MyEA.Buy_opened())
      str_vol_pos=DoubleToString(MyEA.VolPosType(POSITION_TYPE_BUY),2);
   if(MyEA.Sell_opened())
      str_vol_pos=DoubleToString(MyEA.VolPosType(POSITION_TYPE_SELL),2);

   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],"Volume: "+str_vol_pos,xx1,yy1,xx2,yy2))
      return (false);
   m_label[2].Color(cor_labels);

/*  if(!CreateLabel(m_chart_id,m_subwin,Linha1,"_______________________________________",xx1,yy1,xx2,yy2-10))
      return (false);
   Linha1.Color(clrYellow);
*/

   xx1 = INDENT_LEFT;
   yy1 = INDENT_TOP + 3 * BUTTON_HEIGHT + CONTROLS_GAP_Y;
   xx2 = xx1 + BUTTON_WIDTH;
   yy2 = yy1 + BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[3],"Resultado Mensal: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalMes(),2),xx1,yy1,xx2,yy2))
      return (false);

   m_label[3].Color(cor_labels);

   xx1 = INDENT_LEFT;
   yy1 = INDENT_TOP + 4 * BUTTON_HEIGHT + CONTROLS_GAP_Y;
   xx2 = xx1 + BUTTON_WIDTH;
   yy2 = yy1 + BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[4],"Resultado Semanal: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalSemana(),2),xx1,yy1,xx2,yy2))
      return (false);

   m_label[4].Color(cor_labels);

   xx1 = INDENT_LEFT;
   yy1 = INDENT_TOP + 5 * BUTTON_HEIGHT + CONTROLS_GAP_Y;
   xx2 = xx1 + BUTTON_WIDTH;
   yy2 = yy1 + BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[5],"Resultado Diário: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotal(),2),xx1,yy1,xx2,yy2))
      return (false);
   m_label[5].Color(cor_labels);

   xx1 = INDENT_LEFT;
   yy1 = INDENT_TOP + 6 * BUTTON_HEIGHT + CONTROLS_GAP_Y;
   xx2 = xx1 + BUTTON_WIDTH;
   yy2 = yy1 + BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[6],"Licença Válida até: "+TimeToString(data_validade),xx1,yy1,xx2,yy2))
      return (false);
   m_label[6].Color(clrYellow);

   xx1 = INDENT_LEFT;
   yy1 = INDENT_TOP + 7 * BUTTON_HEIGHT + CONTROLS_GAP_Y;
   xx2 = xx1 + BUTTON_WIDTH;
   yy2 = yy1 + BUTTON_HEIGHT;


   if(!CreateLabel(m_chart_id,m_subwin,m_label[7],Only_Demo=="Sim"?"Uso Apenas em Conta Demo":"Uso Liberado Conta Real",xx1,yy1,xx2,yy2))
      return (false);
   m_label[7].Color(clrYellow);

   xx1=(int)(LARGURA_PAINEL-INDENT_RIGHT-0.7*BUTTON_WIDTH-CONTROLS_GAP_X);
   yy1=INDENT_TOP;
   xx2=(int)(xx1+0.7*BUTTON_WIDTH);
   yy2=(int)(yy1+1.5*BUTTON_HEIGHT);

   if(!CreateButton(m_chart_id,m_subwin,BotaoFechar,"ZERAR",xx1,yy1,xx2,yy2))
      return(false);
   BotaoFechar.ColorBackground(clrLime);
   Minimized(false);
//--- succeed
   return (true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
void MyPanel::OnTick(T &MyEA)
  {
  if(TimeCurrent()%10==0) Maximize();
   string s_estrateg="";
   if(Estrategia == StatBW)
      s_estrateg = "Bw-Wiseman";
   if(Estrategia == StatCAP)
      s_estrateg = "CAPZACK";
   if(Estrategia == StatCoyote)
      s_estrateg = "Coyote";
   if(Estrategia == StatMedCross)
      s_estrateg = "Média Cross";
   if(Estrategia == StatHMA)
      s_estrateg = "HMA";

   string str_pos;
   if(!MyEA.PosicaoAberta())
      str_pos="Zerado";
   if(MyEA.Buy_opened())
      str_pos="Comprado";
   if(MyEA.Sell_opened())
      str_pos="Vendido";

   string str_vol_pos;
   if(!MyEA.PosicaoAberta())
      str_vol_pos="-";
   if(MyEA.Buy_opened())
      str_vol_pos=DoubleToString(MyEA.VolPosType(POSITION_TYPE_BUY),2);
   if(MyEA.Sell_opened())
      str_vol_pos=DoubleToString(MyEA.VolPosType(POSITION_TYPE_SELL),2);

   m_label[0].Text("Estratégia: " + s_estrateg);
   m_label[1].Text("Posição: " + str_pos);
   m_label[2].Text("Volume: " + str_vol_pos);
   m_label[3].Text("Resultado Mensal: " + MyEA.GetCurrency() + " " + DoubleToString(MyEA.LucroTotalMes(), 2));
   m_label[4].Text("Resultado Semanal: " + MyEA.GetCurrency() + " " + DoubleToString(MyEA.LucroTotalSemana(), 2));
   m_label[5].Text("Resultado Diário: " + MyEA.GetCurrency() + " " + DoubleToString(MyEA.LucroTotal(), 2));

  }
//+------------------------------------------------------------------+ 
//| Event Handling                                                   | 
//+------------------------------------------------------------------+ 
EVENT_MAP_BEGIN(MyPanel)
ON_EVENT(ON_CLICK,BotaoFechar,OnClickBotaoFechar)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
void OnClickBotaoFechar()
  {
   MyHMAExp.DeleteALL();
   MyHMAExp.CloseALL();

  }
//+------------------------------------------------------------------+

bool ValidarSenha(string password)
  {
   int trim;
   trim=StringTrimLeft(password);
   trim=StringTrimRight(password);
   ulong conta_usuario;
   B.Init(keystr);
   string decoded=B.Decrypt(password);
   string to_split = decoded; // Um string para dividir em substrings
   string sep = "_";          // Um separador como um caractere
   ushort u_sep;              // O código do caractere separador
   string result[];           // Um array para obter strings
//--- Obtém o código do separador
   u_sep=StringGetCharacter(sep,0);
//--- Divide a string em substrings
   int k=StringSplit(to_split,u_sep,result);
//--- Exibe um comentário
//--- Agora imprime todos os resultados obtidos
   if(k>0)
     {
      conta_usuario = StringToInteger(result[0]);
      data_validade = StringToTime(result[1]);
      Only_Demo=result[2];

      if(TimeCurrent()>data_validade)
        {
         string erro="Data de Validade Expirada";
         MessageBox(erro);
         Print(erro);
         return false;
        }
      if(AccountInfoInteger(ACCOUNT_LOGIN)!=conta_usuario)
        {
         string erro="Usuário Não Permitido";
         MessageBox(erro);
         Print(erro);
         return false;
        }

      if(Only_Demo=="Sim" && (ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE)!=ACCOUNT_TRADE_MODE_DEMO)
        {
         string erro="EA permitido apenas em conta DEMO";
         MessageBox(erro);
         Print(erro);
         return false;
        }

     }
   else
      return false;
   return true;
  }
//+------------------------------------------------------------------+

bool BitmapLabelCreate(const long              chart_ID=0,               // chart's ID
                       const string            name="BmpLabel",          // label name
                       const int               sub_window=0,             // subwindow index
                       const int               x=0,                      // X coordinate
                       const int               y=0,                      // Y coordinate
                       const string            file_on="",               // image in On mode
                       const string            file_off="",              // image in Off mode
                       const int               width=0,                  // visibility scope X coordinate
                       const int               height=0,                 // visibility scope Y coordinate
                       const int               x_offset=10,              // visibility scope shift by X axis
                       const int               y_offset=10,              // visibility scope shift by Y axis
                       const bool              state=false,              // pressed/released
                       const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                       const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type 
                       const color             clr=clrRed,               // border color when highlighted
                       const ENUM_LINE_STYLE   style=STYLE_SOLID,        // line style when highlighted
                       const int               point_width=1,            // move point size
                       const bool              back=false,               // in the background
                       const bool              selection=false,          // highlight to move
                       const bool              hidden=true,              // hidden in the object list
                       const long              z_order=0)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create a bitmap label
   if(!ObjectCreate(chart_ID,name,OBJ_BITMAP_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create \"Bitmap Label\" object! Error code = ",GetLastError());
      return(false);
     }
//--- set the images for On and Off modes
   if(!ObjectSetString(chart_ID,name,OBJPROP_BMPFILE,0,file_on))
     {
      Print(__FUNCTION__,
            ": failed to load the image for On mode! Error code = ",GetLastError());
      return(false);
     }
   if(!ObjectSetString(chart_ID,name,OBJPROP_BMPFILE,1,file_off))
     {
      Print(__FUNCTION__,
            ": failed to load the image for Off mode! Error code = ",GetLastError());
      return(false);
     }
//--- set label coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set visibility scope for the image; if width or height values
//--- exceed the width and height (respectively) of a source image,
//--- it is not drawn; in the opposite case,
//--- only the part corresponding to these values is drawn
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the part of an image that is to be displayed in the visibility scope
//--- the default part is the upper left area of an image; the values allow
//--- performing a shift from this area displaying another part of the image
   ObjectSetInteger(chart_ID,name,OBJPROP_XOFFSET,x_offset);
   ObjectSetInteger(chart_ID,name,OBJPROP_YOFFSET,y_offset);
//--- define the label's status (pressed or released)
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set the border color when object highlighting mode is enabled
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set the border line style when object highlighting mode is enabled
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set a size of the anchor point for moving an object
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,point_width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+

int ChartWidthInPixels(const long chart_ID=0)
  {
//--- prepare the variable to get the property value
   long result=-1;
//--- reset the error value
   ResetLastError();
//--- receive the property value
   if(!ChartGetInteger(chart_ID,CHART_WIDTH_IN_PIXELS,0,result))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- return the value of the chart property
   return((int)result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ChartHeightInPixelsGet(const long chart_ID=0,const int sub_window=0)
  {
//--- prepare the variable to get the property value
   long result=-1;
//--- reset the error value
   ResetLastError();
//--- receive the property value
   if(!ChartGetInteger(chart_ID,CHART_HEIGHT_IN_PIXELS,sub_window,result))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- return the value of the chart property
   return((int)result);
  }
//+------------------------------------------------------------------+
