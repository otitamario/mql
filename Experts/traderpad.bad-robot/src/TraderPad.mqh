//+------------------------------------------------------------------+
//|                                   Copyright 2018, Erlon F. Souza |
//|                                       https://github.com/erlonfs |
//+------------------------------------------------------------------+

#property copyright "Copyright 2018, Erlon F. Souza"
#property link      "https://github.com/erlonfs"

#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Edit.mqh>
#include <Controls\Label.mqh>
#include <Controls\DatePicker.mqh>
#include <Controls\ListView.mqh>
#include <Controls\ComboBox.mqh>
#include <Controls\SpinEdit.mqh>
#include <Controls\RadioGroup.mqh>
#include <Controls\CheckGroup.mqh>

#include <BadRobot.Framework\Logger.mqh>
#include <BadRobot.Framework\BadRobotCore.mqh>

//--- indents and gaps
#define INDENT_LEFT                         	(8)      	// indent from left (with allowance for border width)
#define INDENT_TOP                          	(11)      	// indent from top (with allowance for border width)
#define INDENT_RIGHT                        	(11)      	// indent from right (with allowance for border width)
#define INDENT_BOTTOM                       	(11)      	// indent from bottom (with allowance for border width)
#define CONTROLS_GAP_X                      	(5)       	// gap by X coordinate
#define CONTROLS_GAP_Y                      	(5)       	// gap by Y coordinate
//--- for buttons
#define BUTTON_WIDTH                        	(80)     	// size by X coordinate
#define BUTTON_HEIGHT                       	(25)      	// size by Y coordinate
//--- for the indication area
#define EDIT_HEIGHT                         	(20)      	// size by Y coordinate
//--- for group controls
#define GROUP_WIDTH                         	(150)     	// size by X coordinate
#define LIST_HEIGHT                         	(179)     	// size by Y coordinate
#define RADIO_HEIGHT                        	(56)      	// size by Y coordinate
#define CHECK_HEIGHT                        	(93)      	// size by Y coordinate

#define PANEL_WIDTH                         	(193)      	// width of panel
#define PANEL_HEIGHT                        	(280)      	// height of panel
#define LABEL_FONT_SIZE                     	(8)			// height of panel
#define CONTROLS_DISTANCE_Y                 	(5)      	// height of panel
#define PANEL_FONT									("Tahoma")	//Font
#define PANEL_FONT_SIZE								(8)			//Font Size
#define PANEL_PAD_DISTANCE_X						(31)			//Pad Button Distance			

class TraderPad  : public BadRobotCore
{


	private:
	
	//Minima ou maxima dos ultimos candles
	int _countLastCandles;
	double _minLastCandles;
	double _maxLastCandles;
	
	MqlRates _rates[]; 
		                        
   CButton btnComprar;                       
   CButton btnVender; 
   CButton btnZerar; 
   CButton btnInverter;   
   CButton btnCancelar;   
   
   CButton btnPad1; 
   CButton btnPad2; 
   CButton btnPad3; 
   CButton btnPad4; 
   
   CButton btnPad5; 
   CButton btnPad6; 
   CButton btnPad7; 
   CButton btnPad8;    
   
   CButton btnPos; 
   CButton btnSald; 
   	           
	bool CreateBtnComprar(void)
   {
      int x1=INDENT_LEFT;
      int y1= CONTROLS_GAP_Y + CONTROLS_DISTANCE_Y;
      int x2=x1+BUTTON_WIDTH;
      int y2=y1+BUTTON_HEIGHT;

      if(!btnComprar.Create(m_chart_id,m_name+"BtnComprar",m_subwin,x1,y1,x2,y2))
         return(false);
      if(!btnComprar.Text("COMPRAR"))
         return(false);
      if(!Add(btnComprar))
         return(false);         

      return(true);
    }
              
   bool CreateBtnVender(void)
   {
      int x1=INDENT_LEFT+(BUTTON_WIDTH + CONTROLS_GAP_X);
      int y1= CONTROLS_GAP_Y + CONTROLS_DISTANCE_Y;
      int x2=x1+BUTTON_WIDTH;
      int y2=y1+BUTTON_HEIGHT;
   
      if(!btnVender.Create(m_chart_id,m_name+"BtnVender",m_subwin,x1,y1,x2,y2))
         return(false);
      if(!btnVender.Text("VENDER"))
         return(false);
      if(!Add(btnVender))
         return(false);
   
      return(true);
   }  
       
   bool CreateBtnInverter(void)
   {
      int x1=INDENT_LEFT;
      int y1=BUTTON_HEIGHT + CONTROLS_GAP_Y + CONTROLS_DISTANCE_Y * 2;
      int x2=x1+BUTTON_WIDTH;
      int y2=y1+BUTTON_HEIGHT;
   
      if(!btnInverter.Create(m_chart_id,m_name+"BtnInverter",m_subwin,x1,y1,x2,y2))
         return(false);
      if(!btnInverter.Text("INVERTER"))
         return(false);
      if(!Add(btnInverter))
         return(false);
   
      return(true);
   }
   
   bool CreateBtnZerar(void)
   {
      int x1=INDENT_LEFT+(BUTTON_WIDTH+CONTROLS_GAP_X);
      int y1=BUTTON_HEIGHT + CONTROLS_GAP_Y + CONTROLS_DISTANCE_Y * 2;
      int x2=x1+BUTTON_WIDTH;
      int y2=y1+BUTTON_HEIGHT;
   
      if(!btnZerar.Create(m_chart_id,m_name+"BtnZerar",m_subwin,x1,y1,x2,y2))
         return(false);
      if(!btnZerar.Text("ZERAR"))
         return(false);
      if(!Add(btnZerar))
         return(false);
   
      return(true);
   }   
        
   bool CreateBtnCancelar(void)
   {
      int x1=INDENT_LEFT;
      int y1=BUTTON_HEIGHT * 2 + CONTROLS_GAP_Y + CONTROLS_DISTANCE_Y * 3;
      int x2=x1+BUTTON_WIDTH * 2 + CONTROLS_GAP_X;
      int y2=y1+BUTTON_HEIGHT;
   
      if(!btnCancelar.Create(m_chart_id,m_name+"btnCancelar",m_subwin,x1,y1,x2,y2))
         return(false);
      if(!btnCancelar.Text("CANCELAR ORDENS"))
         return(false);
      if(!Add(btnCancelar))
         return(false);
   
      return(true);
   }    
           
   bool DisableButton(CButton &btn)
   {
   	btn.Disable();
   	btn.ColorBackground(clrGray);
		btn.Color(clrDarkGray);
		btn.ColorBorder(clrGray);
		
		return true;
   }   
    
   bool EnableZerar(CButton &btn)
   {
   	btn.Enable();
   	btn.ColorBackground(clrChocolate);
		btn.Color(clrWhite);
		btn.ColorBorder(clrChocolate);
						
		return true;
		
   }  
   
   bool EnableInverter(CButton &btn)
   {
   	btn.Enable();
   	btn.ColorBackground(clrIndigo);
		btn.Color(clrWhite);
		btn.ColorBorder(clrIndigo);
						
		return true;
		
   }    
   
   bool EnableComprar(CButton &btn)
   {
   	btn.Enable();
   	btn.ColorBackground(clrDarkGreen);
		btn.Color(clrWhite);
		btn.ColorBorder(clrDarkGreen);
						
		return true;
		
   } 
   
   bool EnableVender(CButton &btn)
   {
   	btn.Enable();
   	btn.ColorBackground(clrFireBrick);
		btn.Color(clrWhite);
		btn.ColorBorder(clrFireBrick);
						
		return true;
		
   }       
   
   bool CreateBtnPad1(void)
   {
 		int x1=INDENT_LEFT;
      int y1=(BUTTON_HEIGHT * 3) + CONTROLS_GAP_Y + CONTROLS_DISTANCE_Y * 4;
      int x2=x1+PANEL_PAD_DISTANCE_X + CONTROLS_GAP_X + 1;
      int y2=y1+BUTTON_HEIGHT;
   
      if(!btnPad1.Create(m_chart_id,m_name+"btnPad1",m_subwin,x1,y1,x2,y2))
         return(false);
      if(!btnPad1.Text("+1"))
         return(false);
      if(!Add(btnPad1))
         return(false);
   
      return(true);
   } 
   
   bool CreateBtnPad2(void)
   {
 		int x1=INDENT_LEFT + PANEL_PAD_DISTANCE_X + CONTROLS_GAP_X * 2;
      int y1=(BUTTON_HEIGHT * 3) + CONTROLS_GAP_Y + CONTROLS_DISTANCE_Y * 4;
      int x2=x1+PANEL_PAD_DISTANCE_X + CONTROLS_GAP_X + 1;
      int y2=y1+BUTTON_HEIGHT;
   
      if(!btnPad2.Create(m_chart_id,m_name+"btnPad2",m_subwin,x1,y1,x2,y2))
         return(false);
      if(!btnPad2.Text("+2"))
         return(false);
      if(!Add(btnPad2))
         return(false);
   
      return(true);
   }
   
   bool CreateBtnPad3(void)
   {
 		int x1=INDENT_LEFT + PANEL_PAD_DISTANCE_X * 2 + CONTROLS_GAP_X * 4;
      int y1=(BUTTON_HEIGHT * 3) + CONTROLS_GAP_Y + CONTROLS_DISTANCE_Y * 4;
      int x2=x1+PANEL_PAD_DISTANCE_X + CONTROLS_GAP_X + 4;
      int y2=y1+BUTTON_HEIGHT;
   
      if(!btnPad3.Create(m_chart_id,m_name+"btnPad3",m_subwin,x1,y1,x2,y2))
         return(false);
      if(!btnPad3.Text("+5"))
         return(false);
      if(!Add(btnPad3))
         return(false);
   
      return(true);
   }
   
   bool CreateBtnPad4(void)
   {
 		int x1=INDENT_LEFT + PANEL_PAD_DISTANCE_X * 3 + CONTROLS_GAP_X * 6 + 2;
      int y1=(BUTTON_HEIGHT * 3) + CONTROLS_GAP_Y + CONTROLS_DISTANCE_Y * 4;
      int x2=x1+PANEL_PAD_DISTANCE_X + CONTROLS_GAP_X + 5;
      int y2=y1+BUTTON_HEIGHT;
   
      if(!btnPad4.Create(m_chart_id,m_name+"btnPad4",m_subwin,x1,y1,x2,y2))
         return(false);
      if(!btnPad4.Text("+10"))
         return(false);
      if(!Add(btnPad4))
         return(false);
   
      return(true);
   }
            
   bool CreateBtnPad5(void)
   {
 		int x1=INDENT_LEFT;
      int y1=(BUTTON_HEIGHT * 4) + CONTROLS_GAP_Y + CONTROLS_DISTANCE_Y * 5;
      int x2=x1+PANEL_PAD_DISTANCE_X + CONTROLS_GAP_X;
      int y2=y1+BUTTON_HEIGHT;
   
      if(!btnPad5.Create(m_chart_id,m_name+"btnPad5",m_subwin,x1,y1,x2,y2))
         return(false);
      if(!btnPad5.Text("-1"))
         return(false);
      if(!Add(btnPad5))
         return(false);
   
      return(true);
   }
   
	bool CreateBtnPad6(void)
   {
 		int x1=INDENT_LEFT + PANEL_PAD_DISTANCE_X + CONTROLS_GAP_X * 2;
      int y1=(BUTTON_HEIGHT * 4) + CONTROLS_GAP_Y + CONTROLS_DISTANCE_Y * 5;
      int x2=x1+PANEL_PAD_DISTANCE_X + CONTROLS_GAP_X + 1;
      int y2=y1+BUTTON_HEIGHT;
   
      if(!btnPad6.Create(m_chart_id,m_name+"btnPad6",m_subwin,x1,y1,x2,y2))
         return(false);
      if(!btnPad6.Text("-2"))
         return(false);
      if(!Add(btnPad6))
         return(false);
   
      return(true);
   }
   
   bool CreateBtnPad7(void)
   {
 		int x1=INDENT_LEFT + PANEL_PAD_DISTANCE_X * 2 + CONTROLS_GAP_X * 4;
      int y1=(BUTTON_HEIGHT * 4) + CONTROLS_GAP_Y + CONTROLS_DISTANCE_Y * 5;
      int x2=x1+PANEL_PAD_DISTANCE_X + CONTROLS_GAP_X + 4;
      int y2=y1+BUTTON_HEIGHT;
   
      if(!btnPad7.Create(m_chart_id,m_name+"btnPad7",m_subwin,x1,y1,x2,y2))
         return(false);
      if(!btnPad7.Text("-5"))
         return(false);
      if(!Add(btnPad7))
         return(false);
   
      return(true);
   }
   
   bool CreateBtnPad8(void)
   {
 		int x1=INDENT_LEFT + PANEL_PAD_DISTANCE_X * 3 + CONTROLS_GAP_X * 6 + 2;
      int y1=(BUTTON_HEIGHT * 4) + CONTROLS_GAP_Y + CONTROLS_DISTANCE_Y * 5;
      int x2=x1+PANEL_PAD_DISTANCE_X + CONTROLS_GAP_X + 5;
      int y2=y1+BUTTON_HEIGHT;
   
      if(!btnPad8.Create(m_chart_id,m_name+"btnPad8",m_subwin,x1,y1,x2,y2))
         return(false);
      if(!btnPad8.Text("-10"))
         return(false);
      if(!Add(btnPad8))
         return(false);
   
      return(true);
   }
        
   bool CreateBtnPos(void)
   {
 		int x1=INDENT_LEFT;
      int y1=BUTTON_HEIGHT * 5 + CONTROLS_GAP_Y + CONTROLS_DISTANCE_Y * 6;
      int x2=x1+PANEL_PAD_DISTANCE_X * 2 + CONTROLS_GAP_X * 4;
      int y2=y1+BUTTON_HEIGHT / 3 * 4;
   
      if(!btnPos.Create(m_chart_id,m_name+"btnPos",m_subwin,x1,y1,x2,y2))
         return(false);
      if(!btnPos.Text("POS " + DoubleToString(0, 0)))
         return(false);
      if(!Add(btnPos))
         return(false);
   
      return(true);
   } 
   
   bool CreateBtnSald(void)
   {
 		int x1=INDENT_LEFT + PANEL_PAD_DISTANCE_X * 2 + CONTROLS_GAP_X * 5;
      int y1=BUTTON_HEIGHT * 5 + CONTROLS_GAP_Y + CONTROLS_DISTANCE_Y * 6;
      int x2=x1+PANEL_PAD_DISTANCE_X * 2 + CONTROLS_GAP_X * 4 - 2;
      int y2=y1+BUTTON_HEIGHT / 3 * 4;
   
      if(!btnSald.Create(m_chart_id,m_name+"btnSald",m_subwin,x1,y1,x2,y2))
         return(false);
      if(!btnSald.Text("R$ " + DoubleToString(0, 2)))
         return(false);
      if(!Add(btnSald))
         return(false);
   
      return(true);
   }
   
	bool Load()
	{
		if(_UninitReason == REASON_CHARTCHANGE)
		{
			return true;				
		}
		
		Comment("");
			
		CAppDialog::Destroy(_UninitReason);							
	   if(!CAppDialog::Create(0, GetRobotName() + " " + GetRobotVersion(), 0, 3, 50, PANEL_WIDTH, PANEL_HEIGHT))return(false);			  
	      
	   if(!CreateBtnComprar())return(false);
	   if(!CreateBtnVender())return(false);		   		   
	   if(!CreateBtnZerar())return(false);
	   if(!CreateBtnInverter())return(false);	   
	   if(!CreateBtnCancelar())return(false);
	   
	   if(!CreateBtnPad1())return(false);
	   if(!CreateBtnPad2())return(false);
	   if(!CreateBtnPad3())return(false);
	   if(!CreateBtnPad4())return(false);
	   
	   if(!CreateBtnPad5())return(false);
	   if(!CreateBtnPad6())return(false);
	   if(!CreateBtnPad7())return(false);
	   if(!CreateBtnPad8())return(false);	   
	   
	   if(!CreateBtnPos())return(false);
	   if(!CreateBtnSald())return(false);
	   		   		   		   
	   BringToTop();
	   
	  	btnComprar.ColorBackground(clrDarkGreen);
	   btnComprar.Color(clrWhite);
	   btnComprar.Font(PANEL_FONT);
	   btnComprar.FontSize(PANEL_FONT_SIZE);
	   btnComprar.ColorBorder(clrDarkGreen);
	   
	   btnVender.ColorBackground(clrFireBrick);
	   btnVender.Color(clrWhite);
	   btnVender.Font(PANEL_FONT);
	   btnVender.FontSize(PANEL_FONT_SIZE);
	   btnVender.ColorBorder(clrFireBrick);		  
	   
	   btnInverter.ColorBackground(clrIndigo);
	   btnInverter.Color(clrWhite);
	   btnInverter.Font(PANEL_FONT);
	   btnInverter.FontSize(PANEL_FONT_SIZE);
	   btnInverter.ColorBorder(clrIndigo);
	   
		btnZerar.ColorBackground(clrChocolate);
	   btnZerar.Color(clrWhite);
	   btnZerar.Font(PANEL_FONT);
	   btnZerar.FontSize(PANEL_FONT_SIZE);
	   btnZerar.ColorBorder(clrChocolate);
	   
	   btnCancelar.ColorBackground(clrSteelBlue);
	   btnCancelar.Color(clrWhite);
	   btnCancelar.Font(PANEL_FONT);
	   btnCancelar.FontSize(PANEL_FONT_SIZE);
	   btnCancelar.ColorBorder(clrSteelBlue);
	   	  		   
	  	btnPad1.ColorBackground(clrWhite);
	   btnPad1.Color(clrDarkGreen);
	   btnPad1.Font(PANEL_FONT);
	   btnPad1.FontSize(PANEL_FONT_SIZE);
	   btnPad1.ColorBorder(clrDarkGreen);
	   
	  	btnPad2.ColorBackground(clrWhite);
	   btnPad2.Color(clrDarkGreen);
	   btnPad2.Font(PANEL_FONT);
	   btnPad2.FontSize(PANEL_FONT_SIZE);
	   btnPad2.ColorBorder(clrDarkGreen);
	  		   
	  	btnPad3.ColorBackground(clrWhite);
	   btnPad3.Color(clrDarkGreen);
	   btnPad3.Font(PANEL_FONT);
	   btnPad3.FontSize(PANEL_FONT_SIZE);
	   btnPad3.ColorBorder(clrDarkGreen);

	  	btnPad4.ColorBackground(clrWhite);
	   btnPad4.Color(clrDarkGreen);
	   btnPad4.Font(PANEL_FONT);
	   btnPad4.FontSize(PANEL_FONT_SIZE);
	   btnPad4.ColorBorder(clrDarkGreen);
	   
	   btnPad5.ColorBackground(clrWhite);
	   btnPad5.Color(clrFireBrick);
	   btnPad5.Font(PANEL_FONT);
	   btnPad5.FontSize(PANEL_FONT_SIZE);
	   btnPad5.ColorBorder(clrFireBrick);
	   
	  	btnPad6.ColorBackground(clrWhite);
	   btnPad6.Color(clrFireBrick);
	   btnPad6.Font(PANEL_FONT);
	   btnPad6.FontSize(PANEL_FONT_SIZE);
	   btnPad6.ColorBorder(clrFireBrick);
	  		   
	  	btnPad7.ColorBackground(clrWhite);
	   btnPad7.Color(clrFireBrick);
	   btnPad7.Font(PANEL_FONT);
	   btnPad7.FontSize(PANEL_FONT_SIZE);
	   btnPad7.ColorBorder(clrFireBrick);

	  	btnPad8.ColorBackground(clrWhite);
	   btnPad8.Color(clrFireBrick);
	   btnPad8.Font(PANEL_FONT);
	   btnPad8.FontSize(PANEL_FONT_SIZE);
	   btnPad8.ColorBorder(clrFireBrick);
	   
	   btnPos.ColorBackground(clrWhite);
	   btnPos.Color(clrGray);
	   btnPos.Font(PANEL_FONT);
	   btnPos.FontSize(PANEL_FONT_SIZE + 2);
	   btnPos.ColorBorder(clrGray);
	   
	   btnSald.ColorBackground(clrWhite);
	   btnSald.Color(clrGray);
	   btnSald.Font(PANEL_FONT);
	   btnSald.FontSize(PANEL_FONT_SIZE + 2);
	   btnSald.ColorBorder(clrGray);		   
	   
	   ManageButtonStatus();
	  		   
	   CAppDialog::Run();		   
	   
      return (true);
	}
	
	void OnClickBtnComprar()
   {         
      BadRobotCore::Buy();         
   }
	
	void OnClickBtnVender()
   {         
      BadRobotCore::Sell();         
   }	
   
	void OnClickBtnInverter()
   {         
      BadRobotCore::InvertPosition();         
   }	
   
	void OnClickBtnZerar()
   {         
      ClosePosition();         
   }	
   
	void OnClickBtnParcial1()
   {         
		SetIsParcial(!IsParcial());
   }	      
   
	void OnClickBtnParcial2()
   {         
      ExecuteSegundaParcial();
   }
   
	void OnClickBtnParcial3()
   {         
      ExecuteTerceiraParcial();
   }            
    		
	void OnClickBtnPad1()
   {         
    	Buy(0.0, 1.0);
   }	
   
	void OnClickBtnPad2()
   {         
      Buy(0.0, 2.0);
   }
   
	void OnClickBtnPad3()
   {         
		Buy(0.0, 5.0);              
   }
   
	void OnClickBtnPad4()
   {         
      Buy(0.0, 10.0);    
   } 
   
	void OnClickBtnPad5()
   {         
   	Sell(0.0, 1.0);
   }	
   
	void OnClickBtnPad6()
   {         
   	Sell(0.0, 2.0);                
   }
   
	void OnClickBtnPad7()
   {         
   	Sell(0.0, 5.0);                
   }
   
	void OnClickBtnPad8()
   {         
   	Sell(0.0, 10.0);                
   }    
   
	void OnClickBtnCompraStop()
   {         
   	BuyStop(GetMaxLastCandles() + ToPoints(GetSpread()));
   }                          		                 
   
	void OnClickBtnCancelar()
   {               	
   	CancelPendingOrders();
   }      
   
   void OnClickBtnVendaStop()
   {       
   	SellStop(GetMinLastCandles() - ToPoints(GetSpread()));
   }
   
   void OnTimerHandler()
   {
   	btnPos.Text("POS " + GetPositionVolumeText());
		btnSald.Text(AccountInfoString(ACCOUNT_CURRENCY) + " " + DoubleToString(GetPositionProfit(), 2));
		
		if(GetPositionProfit() > 0)
		{
			btnSald.Color(clrDarkGreen);			
		}
		else
		{
			btnSald.Color(clrFireBrick);
		}
		
		if(IsPositionTypeBuy())
		{
		   btnPos.Color(clrDarkGreen);  
		}
		else
		{
		   btnPos.Color(clrFireBrick);
		}
		
		if(!HasPositionOpen())
		{
			btnSald.Color(clrGray);	
			btnPos.Color(clrGray);
		}
   }
   
   void OnShowInfoHandler()
   {             	   	
   	ManageButtonStatus();   	    		      	 
   } 
   
   void ManageButtonStatus()
   {   	
		if(HasPositionOpen())
		{
			EnableZerar(&btnZerar);	
			EnableInverter(&btnInverter);
		}
		else
		{
			DisableButton(&btnZerar);
			DisableButton(&btnInverter);
		}						
   }; 
   
	bool ManageMinAndMaxLastCandles()
	{		   		
		if (!IsNewCandle()){return false;}
		
		ZeroMemory(_rates);
		ArraySetAsSeries(_rates, true);
		ArrayFree(_rates);
		
		if (CopyRates(GetSymbol(), GetPeriod(), 0, _countLastCandles, _rates) <= 0)
		{
			return false;
		}
		
		double minAux = DBL_MAX;
		double maxAux = DBL_MIN;
		
		for(int i = 1; i < ArraySize(_rates); i++)
		{
			if(_rates[i].low < minAux)
			{
				minAux = _rates[i].low;
			}
			
			if(_rates[i].high > maxAux)
			{
				maxAux = _rates[i].high;
			}
		}
		
		_minLastCandles = minAux;
		_maxLastCandles = maxAux;
		
		if(GetLastPrice() < minAux)
		{
			_minLastCandles = 0;
		}
		
		if(GetLastPrice() > maxAux)
		{
			_maxLastCandles = 0;
		}
		
		return true;

	}	 
                                 	              	
	protected:
	
   EVENT_MAP_BEGIN(TraderPad)
      ON_EVENT(ON_CLICK,btnComprar,OnClickBtnComprar)
      ON_EVENT(ON_CLICK,btnVender,OnClickBtnVender)
      ON_EVENT(ON_CLICK,btnInverter,OnClickBtnInverter)
      ON_EVENT(ON_CLICK,btnZerar,OnClickBtnZerar)
      ON_EVENT(ON_CLICK,btnCancelar,OnClickBtnCancelar)
      ON_EVENT(ON_CLICK,btnPad1,OnClickBtnPad1)
      ON_EVENT(ON_CLICK,btnPad2,OnClickBtnPad2)
      ON_EVENT(ON_CLICK,btnPad3,OnClickBtnPad3)
      ON_EVENT(ON_CLICK,btnPad4,OnClickBtnPad4)
      ON_EVENT(ON_CLICK,btnPad5,OnClickBtnPad5)
      ON_EVENT(ON_CLICK,btnPad6,OnClickBtnPad6)
      ON_EVENT(ON_CLICK,btnPad7,OnClickBtnPad7)
      ON_EVENT(ON_CLICK,btnPad8,OnClickBtnPad8)      
   EVENT_MAP_END(CAppDialog)
		
		
	public:
			
		TraderPad()
		{
         
		}			
		
		~TraderPad()
		{
		   CAppDialog::Destroy(_UninitReason);
		}	
		
		int OnInitHandler()
		{
			if(!Load()) return INIT_FAILED;
			
			return INIT_SUCCEEDED;
			
		}
								
		void SetCountLastCandles(int value)
		{
			if(value <= 1) return;
		
			_countLastCandles = value;
		}
		
		int GetCountLastCandles()
		{
			return _countLastCandles;
		}
		
		void SetQtdCountLastCandles(int value)
		{
			_countLastCandles = value;
		}		
		
		double GetMinLastCandles()
		{
			return _minLastCandles;
		}
		
		double GetMaxLastCandles()
		{
			return _maxLastCandles;
		}			   	
};