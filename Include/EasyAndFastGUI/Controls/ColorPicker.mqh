//+------------------------------------------------------------------+
//|                                                  ColorPicker.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "SpinEdit.mqh"
#include "SimpleButton.mqh"
#include "RadioButtons.mqh"
#include "ColorButton.mqh"
//+------------------------------------------------------------------+
//| Class for creating color picker to select a color                |
//+------------------------------------------------------------------+
class CColorPicker : public CElement
  {
private:
   //--- Pointer to the button that calls the color picker control
   CColorButton     *m_color_button;
   //--- Objects for creating the element
   CRectLabel        m_area;
   CRectCanvas       m_canvas;
   CRectLabel        m_current;
   CRectLabel        m_picked;
   CRectLabel        m_hover;
   //---
   CRadioButtons     m_radio_buttons;
   CSpinEdit         m_hsl_h_edit;
   CSpinEdit         m_hsl_s_edit;
   CSpinEdit         m_hsl_l_edit;
   //---
   CSpinEdit         m_rgb_r_edit;
   CSpinEdit         m_rgb_g_edit;
   CSpinEdit         m_rgb_b_edit;
   //---
   CSpinEdit         m_lab_l_edit;
   CSpinEdit         m_lab_a_edit;
   CSpinEdit         m_lab_b_edit;
   //---
   CSimpleButton     m_button_ok;
   CSimpleButton     m_button_cancel;
   //--- Color of the (1) background and (2) background frame
   color             m_area_color;
   color             m_area_border_color;
   //--- Color of the palette frame
   color             m_palette_border_color;
   //--- The (1) current color, (2) selected color and (3) the color specified by the mouse
   color             m_current_color;
   color             m_picked_color;
   color             m_hover_color;
   //--- Component values in different color models:
   //    HSL
   double            m_hsl_h;
   double            m_hsl_s;
   double            m_hsl_l;
   //--- RGB
   double            m_rgb_r;
   double            m_rgb_g;
   double            m_rgb_b;
   //--- Lab
   double            m_lab_l;
   double            m_lab_a;
   double            m_lab_b;
   //--- XYZ
   double            m_xyz_x;
   double            m_xyz_y;
   double            m_xyz_z;
   //--- Priorities of the left mouse button press
   int               m_area_zorder;
   int               m_canvas_zorder;
   //--- Timer counter for fast forwarding the list view
   int               m_timer_counter;
   //---
public:
                     CColorPicker(void);
                    ~CColorPicker(void);
   //--- Methods for creating the control
   bool              CreateColorPicker(const long chart_id,const int subwin,const int x_gap,const int y_gap);
   //---
private:
   bool              CreateArea(void);
   bool              CreatePalette(void);
   bool              CreateCurrentSample(void);
   bool              CreatePickedSample(void);
   bool              CreateHoverSample(void);
   bool              CreateRadioButtons(void);
   bool              CreateHslHEdit(void);
   bool              CreateHslSEdit(void);
   bool              CreateHslLEdit(void);
   bool              CreateRgbREdit(void);
   bool              CreateRgbGEdit(void);
   bool              CreateRgbBEdit(void);
   bool              CreateLabLEdit(void);
   bool              CreateLabAEdit(void);
   bool              CreateLabBEdit(void);
   bool              CreateButtonOK(const string text);
   bool              CreateButtonCancel(const string text);
   //---
public:
   //--- Returns pointers to form controls
   CRadioButtons    *GetRadioButtonsHslPointer(void)          { return(::GetPointer(m_radio_buttons)); }
   CSpinEdit        *GetSpinEditHslHPointer(void)             { return(::GetPointer(m_hsl_h_edit));    }
   CSpinEdit        *GetSpinEditHslSPointer(void)             { return(::GetPointer(m_hsl_s_edit));    }
   CSpinEdit        *GetSpinEditHslLPointer(void)             { return(::GetPointer(m_hsl_l_edit));    }
   CSpinEdit        *GetSpinEditRgbRPointer(void)             { return(::GetPointer(m_rgb_r_edit));    }
   CSpinEdit        *GetSpinEditRgbGPointer(void)             { return(::GetPointer(m_rgb_g_edit));    }
   CSpinEdit        *GetSpinEditRgbBPointer(void)             { return(::GetPointer(m_rgb_b_edit));    }
   CSpinEdit        *GetSpinEditLabLPointer(void)             { return(::GetPointer(m_lab_l_edit));    }
   CSpinEdit        *GetSpinEditLabAPointer(void)             { return(::GetPointer(m_lab_a_edit));    }
   CSpinEdit        *GetSpinEditLabBPointer(void)             { return(::GetPointer(m_lab_b_edit));    }
   CSimpleButton    *GetSimpleButtonOKPointer(void)           { return(::GetPointer(m_button_ok));     }
   CSimpleButton    *GetSimpleButtonCancelPointer(void)       { return(::GetPointer(m_button_cancel)); }
   //--- Set the color of (1) background, (2) background border, (3) and palette border
   void              AreaBackColor(const color clr)           { m_area_color=clr;                      }
   void              AreaBorderColor(const color clr)         { m_area_border_color=clr;               }
   void              PaletteBorderColor(const color clr)      { m_palette_border_color=clr;            }
   
   //--- Store the pointer to the button that calls the color picker
   void              ColorButtonPointer(CColorButton &object);
   //--- Set the color selected by user on the palette
   void              CurrentColor(const color clr);
   //---
public:
   //--- Chart event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- Timer
   virtual void      OnEventTimer(void);
   //--- Moving the element
   virtual void      Moving(const int x,const int y,const bool moving_mode=false);
   //--- (1) Show, (2) hide, (3) reset, (4) delete
   virtual void      Show(void);
   virtual void      Hide(void);
   virtual void      Reset(void);
   virtual void      Delete(void);
   //--- (1) Set, (2) reset priorities of the left mouse button click
   virtual void      SetZorders(void);
   virtual void      ResetZorders(void);
   //--- Zero the color
   virtual void      ResetColors(void) {}
   //---
private:
   //--- Get the color under the mouse cursor
   bool              OnHoverColor(const int x,const int y);
   //--- Handling the pressing on the palette
   bool              OnClickPalette(const string clicked_object);
   //--- Handling the pressing on the radio button
   bool              OnClickRadioButton(const long id,const int button_index,const string button_text);
   //--- Handling the entering new value in the edit box
   bool              OnEndEdit(const long id,const int button_index);
   //--- Handling the pressing the 'OK' button
   bool              OnClickButtonOK(const string clicked_object);
   //--- Handling the pressing the 'Cancel' button
   bool              OnClickButtonCancel(const string clicked_object);

   //--- Draw palette
   void              DrawPalette(const int index);
   //--- Draw palette based on the HSL color model (0: H, 1: S, 2: L)
   void              DrawHSL(const int index);
   //--- Draw palette based on the RGB color model (3: R, 4: G, 5: B)
   void              DrawRGB(const int index);
   //--- Draw palette based on the LAB color model (6: L, 7: a, 8: b)
   void              DrawLab(const int index);
   //--- Draw palette frame
   void              DrawPaletteBorder(void);

   //--- Calculate and set the color components
   void              SetComponents(const int index,const bool fix_selected);
   //--- Set the current parameters in the edit boxes
   void              SetControls(const int index,const bool fix_selected);

   //--- Set the parameters of color models according to (1) HSL, (2) RGB, (3) Lab
   void              SetHSL(void);
   void              SetRGB(void);
   void              SetLab(void);

   //--- Adjust the RGB components
   void              AdjustmentComponentRGB(void);
   //--- Adjust the HSL components
   void              AdjustmentComponentHSL(void);

   //--- Fast scrolling of values in the edit
   void              FastSwitching(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CColorPicker::CColorPicker(void) : m_area_color(clrWhiteSmoke),
                                   m_area_border_color(clrWhiteSmoke),
                                   m_palette_border_color(clrSilver),
                                   m_current_color(clrWhite),
                                   m_picked_color(clrCornflowerBlue),
                                   m_hover_color(clrRed)
  {
//--- Store the name of the element class in the base class
   CElementBase::ClassName(CLASS_NAME);
//--- Set priorities of the left mouse button click
   m_area_zorder   =0;
   m_canvas_zorder =1;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CColorPicker::~CColorPicker(void)
  {
  }
//+------------------------------------------------------------------+
//| Chart event handler                                              |
//+------------------------------------------------------------------+
void CColorPicker::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- Handling of the cursor movement event
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      //--- Leave, if the control is hidden
      if(!CElementBase::IsVisible())
         return;
      //--- Leave, if numbers of subwindows do not match
      if(!CElementBase::CheckSubwindowNumber())
         return;
      //--- Checking the focus over elements
      CElementBase::CheckMouseFocus();
      m_canvas.MouseFocus(m_mouse.X()>m_canvas.X() && m_mouse.X()<m_canvas.X2()-1 && m_mouse.Y()>m_canvas.Y() && m_mouse.Y()<m_canvas.Y2()-1);
      //--- Get the color under the mouse cursor
      if(OnHoverColor(m_mouse.X(),m_mouse.Y()))
         return;
      //---
      return;
     }
//--- Handling the left mouse button click on the object
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      //--- If the palette was pressed
      if(OnClickPalette(sparam))
         return;
      //---
      return;
     }
//--- Handling the value entering in the edit
   if(id==CHARTEVENT_CUSTOM+ON_END_EDIT)
     {
      //--- Check the input of the new value
      if(OnEndEdit(lparam,(int)dparam))
         return;
      //---
      return;
     }
//--- Handle clicking the control
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_LABEL)
     {
      //--- If the radio button was clicked
      if(OnClickRadioButton(lparam,(int)dparam,sparam))
         return;
      //---
      return;
     }
//--- Handle clicking the edit box spin buttons
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_INC || id==CHARTEVENT_CUSTOM+ON_CLICK_DEC)
     {
      //--- Check the input of the new value
      if(OnEndEdit(lparam,(int)dparam))
         return;
      //---
      return;
     }
//--- Handle clicking the control button
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
     {
      //--- Leave, if the identifiers do not match
      if(lparam!=CElementBase::Id())
         return;
      //--- If the "OK" button is clicked
      if(OnClickButtonOK(sparam))
         return;
      //--- If the "CANCEL" button is clicked
      if(OnClickButtonCancel(sparam))
         return;
      //---
      return;
     }
  }
//+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
void CColorPicker::OnEventTimer(void)
  {
//--- If the element is a drop-down
   if(CElementBase::IsDropdown())
      FastSwitching();
   else
     {
      //--- Track the fast scrolling of values, 
      //    only if the form is not blocked
      if(!m_wnd.IsLocked())
         FastSwitching();
     }
  }
//+------------------------------------------------------------------+
//| Create the Color Picker object                                   |
//+------------------------------------------------------------------+
bool CColorPicker::CreateColorPicker(const long chart_id,const int subwin,const int x_gap,const int y_gap)
  {
//--- Exit if there is no pointer to the form
   if(!CElement::CheckWindowPointer())
      return(false);
//--- Initializing variables
   m_id       =m_wnd.LastId()+1;
   m_chart_id =chart_id;
   m_subwin   =subwin;
   m_x_size   =348;
   m_y_size   =265;
   m_x        =CElement::CalculateX(x_gap);
   m_y        =CElement::CalculateY(y_gap);
//--- Margins from the edge
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
//--- Create objects of the control
   if(!CreateArea())
      return(false);
   if(!CreatePalette())
      return(false);
   if(!CreateCurrentSample())
      return(false);
   if(!CreatePickedSample())
      return(false);
   if(!CreateHoverSample())
      return(false);
   if(!CreateRadioButtons())
      return(false);
   if(!CreateHslHEdit())
      return(false);
   if(!CreateHslSEdit())
      return(false);
   if(!CreateHslLEdit())
      return(false);
   if(!CreateRgbREdit())
      return(false);
   if(!CreateRgbGEdit())
      return(false);
   if(!CreateRgbBEdit())
      return(false);
   if(!CreateLabLEdit())
      return(false);
   if(!CreateLabAEdit())
      return(false);
   if(!CreateLabBEdit())
      return(false);
   if(!CreateButtonOK("OK"))
      return(false);
   if(!CreateButtonCancel("Cancel"))
      return(false);
//--- Hide the element if the window is a dialog one or is minimized
   if(m_wnd.WindowType()==W_DIALOG || m_wnd.IsMinimized())
      Hide();
//--- Calculate the components of all color models and
//    draw the palette according to the selected radio button
   SetComponents(m_radio_buttons.SelectedButtonIndex(),false);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the common area                                          |
//+------------------------------------------------------------------+
bool CColorPicker::CreateArea(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_color_picker_bg_"+(string)CElementBase::Id();
//--- Coordinates
   int x=CElementBase::X();
   int y=CElementBase::Y();
//--- Create object
   if(!m_area.Create(m_chart_id,name,m_subwin,x,y,m_x_size,m_y_size))
      return(false);
//--- Properties
   m_area.BackColor(m_area_color);
   m_area.Color(m_area_border_color);
   m_area.BorderType(BORDER_FLAT);
   m_area.Corner(m_corner);
   m_area.Selectable(false);
   m_area.Z_Order(m_area_zorder);
   m_area.Tooltip("\n");
//--- Coordinates
   m_canvas.X(x);
   m_canvas.Y(y);
//--- Sizes
   m_canvas.XSize(m_x_size);
   m_canvas.YSize(m_y_size);
//--- Margins from the edge
   m_area.XGap(CElement::CalculateXGap(x));
   m_area.YGap(CElement::CalculateYGap(y));
//--- Store the object pointer
   CElementBase::AddToArray(m_area);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create color palette                                             |
//+------------------------------------------------------------------+
bool CColorPicker::CreatePalette(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_color_picker_palette_"+(string)CElementBase::Id();
//--- Coordinates
   int x=m_x+6;
   int y=m_y+5;
//--- Sizes
   int x_size=255;
   int y_size=255;
//--- Create object
   if(!m_canvas.CreateBitmapLabel(m_chart_id,m_subwin,name,x,y,x_size,y_size,COLOR_FORMAT_XRGB_NOALPHA))
      return(false);
//--- Attach to the chart
   if(!m_canvas.Attach(m_chart_id,name,m_subwin,1))
      return(false);
//--- Properties
   m_canvas.Tooltip("\n");
   m_canvas.Z_Order(m_canvas_zorder);
//--- Coordinates
   m_canvas.X(x);
   m_canvas.Y(y);
//--- Sizes
   m_canvas.XSize(x_size);
   m_canvas.YSize(y_size);
//--- Margins from the edge
   m_canvas.XGap(CElement::CalculateXGap(x));
   m_canvas.YGap(CElement::CalculateYGap(y));
//--- Store the object pointer
   CElementBase::AddToArray(m_canvas);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create a sample of the current color                             |
//+------------------------------------------------------------------+
bool CColorPicker::CreateCurrentSample(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_color_picker_csample_"+(string)CElementBase::Id();
//--- Coordinates
   int x=m_x+266;
   int y=m_y+5;
//--- Create object
   if(!m_current.Create(m_chart_id,name,m_subwin,x,y,76,25))
      return(false);
//--- Properties
   m_current.BackColor(m_current_color);
   m_current.Color(clrSilver);
   m_current.BorderType(BORDER_FLAT);
   m_current.Corner(m_corner);
   m_current.Selectable(false);
   m_current.Z_Order(m_area_zorder);
   m_current.Tooltip(::ColorToString(m_current_color));
//--- Margins from the edge
   m_current.XGap(CElement::CalculateXGap(x));
   m_current.YGap(CElement::CalculateYGap(y));
//--- Store the object pointer
   CElementBase::AddToArray(m_current);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create a sample of the selected color                            |
//+------------------------------------------------------------------+
bool CColorPicker::CreatePickedSample(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_color_picker_psample_"+(string)CElementBase::Id();
//--- Coordinates
   int x=m_x+290;
   int y=m_y+6;
//--- Create object
   if(!m_picked.Create(m_chart_id,name,m_subwin,x,y,26,23))
      return(false);
//--- Properties
   m_picked.BackColor(m_picked_color);
   m_picked.Color(m_picked_color);
   m_picked.BorderType(BORDER_FLAT);
   m_picked.Corner(m_corner);
   m_picked.Selectable(false);
   m_picked.Z_Order(m_area_zorder);
   m_picked.Tooltip(::ColorToString(m_picked_color));
//--- Margins from the edge
   m_picked.XGap(CElement::CalculateXGap(x));
   m_picked.YGap(CElement::CalculateYGap(y));
//--- Store the object pointer
   CElementBase::AddToArray(m_picked);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create a sample of color when hovered                            |
//+------------------------------------------------------------------+
bool CColorPicker::CreateHoverSample(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_color_picker_hsample_"+(string)CElementBase::Id();
//--- Coordinates
   int x=m_x+316;
   int y=m_y+6;
//--- Create object
   if(!m_hover.Create(m_chart_id,name,m_subwin,x,y,25,23))
      return(false);
//--- Properties
   m_hover.BackColor(m_hover_color);
   m_hover.Color(m_hover_color);
   m_hover.BorderType(BORDER_FLAT);
   m_hover.Corner(m_corner);
   m_hover.Selectable(false);
   m_hover.Z_Order(m_area_zorder);
   m_hover.Tooltip(::ColorToString(m_hover_color));
//--- Margins from the edge
   m_hover.XGap(CElement::CalculateXGap(x));
   m_hover.YGap(CElement::CalculateYGap(y));
//--- Store the object pointer
   CElementBase::AddToArray(m_hover);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates group of radio buttons                                   |
//+------------------------------------------------------------------+
bool CColorPicker::CreateRadioButtons(void)
  {
//--- Store pointer to the form
   m_radio_buttons.WindowPointer(m_wnd);
//--- Coordinates
   int x =CElement::CalculateXGap(m_x+267);
   int y =CElement::CalculateYGap(m_y+35);
//--- Properties
   int    buttons_x_offset[] ={0,0,0,0,0,0,0,0,0};
   int    buttons_y_offset[] ={0,19,38,60,79,98,120,139,158};
   string buttons_text[]     ={"H:","S:","L:","R:","G:","B:","L:","a:","b:"};
   int    buttons_width[]    ={80,80,80,80,80,80,80,80,80};
//--- Properties
   m_radio_buttons.AreaColor(m_area_color);
   m_radio_buttons.TextColor(clrBlack);
   m_radio_buttons.TextColorOff(clrSilver);
   m_radio_buttons.LabelXGap(17);
   m_radio_buttons.AnchorRightWindowSide(m_anchor_right_window_side);
   m_radio_buttons.AnchorBottomWindowSide(m_anchor_bottom_window_side);
//--- Add radio buttons with the specified properties
   for(int i=0; i<9; i++)
      m_radio_buttons.AddButton(buttons_x_offset[i],buttons_y_offset[i],buttons_text[i],buttons_width[i]);
//--- Create a group of buttons
   if(!m_radio_buttons.CreateRadioButtons(m_chart_id,m_subwin,x,y))
      return(false);
//--- Select the second radio button
   m_radio_buttons.SelectRadioButton(1);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the (hsl) H edit box                                      |
//+------------------------------------------------------------------+
bool CColorPicker::CreateHslHEdit(void)
  {
//--- Store pointer to the form
   m_hsl_h_edit.WindowPointer(m_wnd);
//--- Coordinates
   int x =CElement::CalculateXGap(m_x+307);
   int y =CElement::CalculateYGap(m_y+36);
//--- Properties
   m_hsl_h_edit.XSize(38);
   m_hsl_h_edit.YSize(18);
   m_hsl_h_edit.EditXSize(30);
   m_hsl_h_edit.MaxValue(360);
   m_hsl_h_edit.MinValue(0);
   m_hsl_h_edit.StepValue(1);
   m_hsl_h_edit.SetDigits(0);
   m_hsl_h_edit.SetValue(360);
   m_hsl_h_edit.Index(0);
   m_hsl_h_edit.AreaColor(m_area_color);
   m_hsl_h_edit.EditBorderColor(clrSilver);
   m_hsl_h_edit.AnchorRightWindowSide(m_anchor_right_window_side);
   m_hsl_h_edit.AnchorBottomWindowSide(m_anchor_bottom_window_side);
//--- Creating an element
   if(!m_hsl_h_edit.CreateSpinEdit(m_chart_id,m_subwin,"",x,y))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the (hsl) S edit box                                      |
//+------------------------------------------------------------------+
bool CColorPicker::CreateHslSEdit(void)
  {
//--- Store pointer to the form
   m_hsl_s_edit.WindowPointer(m_wnd);
//--- Coordinates
   int x =CElement::CalculateXGap(m_x+307);
   int y =CElement::CalculateYGap(m_y+55);
//--- Properties
   m_hsl_s_edit.XSize(38);
   m_hsl_s_edit.YSize(18);
   m_hsl_s_edit.EditXSize(30);
   m_hsl_s_edit.MaxValue(100);
   m_hsl_s_edit.MinValue(0);
   m_hsl_s_edit.StepValue(1);
   m_hsl_s_edit.SetDigits(0);
   m_hsl_s_edit.SetValue(100);
   m_hsl_s_edit.Index(1);
   m_hsl_s_edit.AreaColor(m_area_color);
   m_hsl_s_edit.EditBorderColor(clrSilver);
   m_hsl_s_edit.AnchorRightWindowSide(m_anchor_right_window_side);
   m_hsl_s_edit.AnchorBottomWindowSide(m_anchor_bottom_window_side);
//--- Creating an element
   if(!m_hsl_s_edit.CreateSpinEdit(m_chart_id,m_subwin,"",x,y))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the (hsl) L edit box                                      |
//+------------------------------------------------------------------+
bool CColorPicker::CreateHslLEdit(void)
  {
//--- Store pointer to the form
   m_hsl_l_edit.WindowPointer(m_wnd);
//--- Coordinates
   int x =CElement::CalculateXGap(m_x+307);
   int y =CElement::CalculateYGap(m_y+74);
//--- Properties
   m_hsl_l_edit.XSize(38);
   m_hsl_l_edit.YSize(18);
   m_hsl_l_edit.EditXSize(30);
   m_hsl_l_edit.MaxValue(100);
   m_hsl_l_edit.MinValue(0);
   m_hsl_l_edit.StepValue(1);
   m_hsl_l_edit.SetDigits(0);
   m_hsl_l_edit.SetValue(50);
   m_hsl_l_edit.Index(2);
   m_hsl_l_edit.AreaColor(m_area_color);
   m_hsl_l_edit.EditBorderColor(clrSilver);
   m_hsl_l_edit.AnchorRightWindowSide(m_anchor_right_window_side);
   m_hsl_l_edit.AnchorBottomWindowSide(m_anchor_bottom_window_side);
//--- Creating an element
   if(!m_hsl_l_edit.CreateSpinEdit(m_chart_id,m_subwin,"",x,y))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the (rgb) R edit box                                      |
//+------------------------------------------------------------------+
bool CColorPicker::CreateRgbREdit(void)
  {
//--- Store pointer to the form
   m_rgb_r_edit.WindowPointer(m_wnd);
//--- Coordinates
   int x =CElement::CalculateXGap(m_x+307);
   int y =CElement::CalculateYGap(m_y+96);
//--- Properties
   m_rgb_r_edit.XSize(38);
   m_rgb_r_edit.YSize(18);
   m_rgb_r_edit.EditXSize(30);
   m_rgb_r_edit.MaxValue(255);
   m_rgb_r_edit.MinValue(0);
   m_rgb_r_edit.StepValue(1);
   m_rgb_r_edit.SetDigits(0);
   m_rgb_r_edit.SetValue(50);
   m_rgb_r_edit.Index(3);
   m_rgb_r_edit.AreaColor(m_area_color);
   m_rgb_r_edit.EditBorderColor(clrSilver);
   m_rgb_r_edit.AnchorRightWindowSide(m_anchor_right_window_side);
   m_rgb_r_edit.AnchorBottomWindowSide(m_anchor_bottom_window_side);
//--- Creating an element
   if(!m_rgb_r_edit.CreateSpinEdit(m_chart_id,m_subwin,"",x,y))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the (rgb) G edit box                                      |
//+------------------------------------------------------------------+
bool CColorPicker::CreateRgbGEdit(void)
  {
//--- Store pointer to the form
   m_rgb_g_edit.WindowPointer(m_wnd);
//--- Coordinates
   int x =CElement::CalculateXGap(m_x+307);
   int y =CElement::CalculateYGap(m_y+115);
//--- Properties
   m_rgb_g_edit.XSize(38);
   m_rgb_g_edit.YSize(18);
   m_rgb_g_edit.EditXSize(30);
   m_rgb_g_edit.MaxValue(255);
   m_rgb_g_edit.MinValue(0);
   m_rgb_g_edit.StepValue(1);
   m_rgb_g_edit.SetDigits(0);
   m_rgb_g_edit.SetValue(50);
   m_rgb_g_edit.Index(4);
   m_rgb_g_edit.AreaColor(m_area_color);
   m_rgb_g_edit.EditBorderColor(clrSilver);
   m_rgb_g_edit.AnchorRightWindowSide(m_anchor_right_window_side);
   m_rgb_g_edit.AnchorBottomWindowSide(m_anchor_bottom_window_side);
//--- Creating an element
   if(!m_rgb_g_edit.CreateSpinEdit(m_chart_id,m_subwin,"",x,y))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the (rgb) B edit box                                      |
//+------------------------------------------------------------------+
bool CColorPicker::CreateRgbBEdit(void)
  {
//--- Store pointer to the form
   m_rgb_b_edit.WindowPointer(m_wnd);
//--- Coordinates
   int x =CElement::CalculateXGap(m_x+307);
   int y =CElement::CalculateYGap(m_y+134);
//--- Properties
   m_rgb_b_edit.XSize(38);
   m_rgb_b_edit.YSize(18);
   m_rgb_b_edit.EditXSize(30);
   m_rgb_b_edit.MaxValue(255);
   m_rgb_b_edit.MinValue(0);
   m_rgb_b_edit.StepValue(1);
   m_rgb_b_edit.SetDigits(0);
   m_rgb_b_edit.SetValue(50);
   m_rgb_b_edit.Index(5);
   m_rgb_b_edit.AreaColor(m_area_color);
   m_rgb_b_edit.EditBorderColor(clrSilver);
   m_rgb_b_edit.AnchorRightWindowSide(m_anchor_right_window_side);
   m_rgb_b_edit.AnchorBottomWindowSide(m_anchor_bottom_window_side);
//--- Creating an element
   if(!m_rgb_b_edit.CreateSpinEdit(m_chart_id,m_subwin,"",x,y))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the (Lab) L edit box                                      |
//+------------------------------------------------------------------+
bool CColorPicker::CreateLabLEdit(void)
  {
//--- Store pointer to the form
   m_lab_l_edit.WindowPointer(m_wnd);
//--- Coordinates
   int x =CElement::CalculateXGap(m_x+307);
   int y =CElement::CalculateYGap(m_y+156);
//--- Properties
   m_lab_l_edit.XSize(38);
   m_lab_l_edit.YSize(18);
   m_lab_l_edit.EditXSize(30);
   m_lab_l_edit.MaxValue(100);
   m_lab_l_edit.MinValue(0);
   m_lab_l_edit.StepValue(1);
   m_lab_l_edit.SetDigits(0);
   m_lab_l_edit.SetValue(50);
   m_lab_l_edit.Index(6);
   m_lab_l_edit.AreaColor(m_area_color);
   m_lab_l_edit.EditBorderColor(clrSilver);
   m_lab_l_edit.AnchorRightWindowSide(m_anchor_right_window_side);
   m_lab_l_edit.AnchorBottomWindowSide(m_anchor_bottom_window_side);
//--- Creating an element
   if(!m_lab_l_edit.CreateSpinEdit(m_chart_id,m_subwin,"",x,y))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the (Lab) a edit box                                      |
//+------------------------------------------------------------------+
bool CColorPicker::CreateLabAEdit(void)
  {
//--- Store pointer to the form
   m_lab_a_edit.WindowPointer(m_wnd);
//--- Coordinates
   int x =CElement::CalculateXGap(m_x+307);
   int y =CElement::CalculateYGap(m_y+175);
//--- Properties
   m_lab_a_edit.XSize(38);
   m_lab_a_edit.YSize(18);
   m_lab_a_edit.EditXSize(30);
   m_lab_a_edit.MaxValue(127);
   m_lab_a_edit.MinValue(-128);
   m_lab_a_edit.StepValue(1);
   m_lab_a_edit.SetDigits(0);
   m_lab_a_edit.SetValue(50);
   m_lab_a_edit.Index(7);
   m_lab_a_edit.AreaColor(m_area_color);
   m_lab_a_edit.EditBorderColor(clrSilver);
   m_lab_a_edit.AnchorRightWindowSide(m_anchor_right_window_side);
   m_lab_a_edit.AnchorBottomWindowSide(m_anchor_bottom_window_side);
//--- Creating an element
   if(!m_lab_a_edit.CreateSpinEdit(m_chart_id,m_subwin,"",x,y))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the (Lab) b edit box                                      |
//+------------------------------------------------------------------+
bool CColorPicker::CreateLabBEdit(void)
  {
//--- Store pointer to the form
   m_lab_b_edit.WindowPointer(m_wnd);
//--- Coordinates
   int x =CElement::CalculateXGap(m_x+307);
   int y =CElement::CalculateYGap(m_y+194);
//--- Properties
   m_lab_b_edit.XSize(38);
   m_lab_b_edit.YSize(18);
   m_lab_b_edit.EditXSize(30);
   m_lab_b_edit.MaxValue(127);
   m_lab_b_edit.MinValue(-128);
   m_lab_b_edit.StepValue(1);
   m_lab_b_edit.SetDigits(0);
   m_lab_b_edit.SetValue(50);
   m_lab_b_edit.Index(8);
   m_lab_b_edit.AreaColor(m_area_color);
   m_lab_b_edit.EditBorderColor(clrSilver);
   m_lab_b_edit.AnchorRightWindowSide(m_anchor_right_window_side);
   m_lab_b_edit.AnchorBottomWindowSide(m_anchor_bottom_window_side);
//--- Creating an element
   if(!m_lab_b_edit.CreateSpinEdit(m_chart_id,m_subwin,"",x,y))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the OK button                                             |
//+------------------------------------------------------------------+
bool CColorPicker::CreateButtonOK(const string text)
  {
//--- Store pointer to the form
   m_button_ok.WindowPointer(m_wnd);
//--- Coordinates
   int x=CElement::CalculateXGap(m_x+267);
   int y=CElement::CalculateYGap(m_y+220);
//--- Properties
   m_button_ok.ButtonXSize(75);
   m_button_ok.ButtonYSize(18);
   m_button_ok.BackColor(clrGainsboro);
   m_button_ok.BackColorHover(C'193,218,255');
   m_button_ok.BackColorPressed(C'190,190,200');
   m_button_ok.BorderColor(C'150,170,180');
   m_button_ok.Index(0);
   m_button_ok.AnchorRightWindowSide(m_anchor_right_window_side);
   m_button_ok.AnchorBottomWindowSide(m_anchor_bottom_window_side);
//--- Creating an element
   if(!m_button_ok.CreateSimpleButton(m_chart_id,m_subwin,text,x,y))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the Cancel button                                         |
//+------------------------------------------------------------------+
bool CColorPicker::CreateButtonCancel(const string text)
  {
//--- Store pointer to the form
   m_button_cancel.WindowPointer(m_wnd);
//--- Coordinates
   int x=CElement::CalculateXGap(m_x+267);
   int y=CElement::CalculateYGap(m_y+241);
//--- Properties
   m_button_cancel.ButtonXSize(75);
   m_button_cancel.ButtonYSize(18);
   m_button_cancel.BackColor(clrGainsboro);
   m_button_cancel.BackColorHover(C'193,218,255');
   m_button_cancel.BackColorPressed(C'190,190,200');
   m_button_cancel.BorderColor(C'150,170,180');
   m_button_cancel.Index(1);
   m_button_cancel.AnchorRightWindowSide(m_anchor_right_window_side);
   m_button_cancel.AnchorBottomWindowSide(m_anchor_bottom_window_side);
//--- Creating an element
   if(!m_button_cancel.CreateSimpleButton(m_chart_id,m_subwin,text,x,y))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Store the pointer to the button that calls the color picker and  |
//| open the window it is attached to                                |
//+------------------------------------------------------------------+
void CColorPicker::ColorButtonPointer(CColorButton &object)
  {
//--- Store the button pointer
   m_color_button=::GetPointer(object);
//--- Set the color of the passed button to all palette markers
   CurrentColor(object.CurrentColor());
//--- Open the window the palette is attached to
   m_wnd.Show();
  }
//+------------------------------------------------------------------+
//| Moving elements                                                  |
//+------------------------------------------------------------------+
void CColorPicker::Moving(const int x,const int y,const bool moving_mode=false)
  {
//--- Leave, if the control is hidden
   if(!CElementBase::IsVisible())
      return;
//--- If the management is delegated to the window, identify its location
   if(!moving_mode)
      if(m_wnd.ClampingAreaMouse()!=PRESSED_INSIDE_HEADER)
         return;
//--- If the anchored to the right
   if(m_anchor_right_window_side)
     {
      //--- Storing coordinates in the element fields
      CElementBase::X(m_wnd.X2()-XGap());
      //--- Storing coordinates in the fields of the objects
      m_area.X(m_wnd.X2()-m_area.XGap());
      m_canvas.X(m_wnd.X2()-m_canvas.XGap());
      m_current.X(m_wnd.X2()-m_current.XGap());
      m_picked.X(m_wnd.X2()-m_picked.XGap());
      m_hover.X(m_wnd.X2()-m_hover.XGap());
     }
   else
     {
      //--- Storing coordinates in the fields of the objects
      CElementBase::X(x+XGap());
      //--- Storing coordinates in the fields of the objects
      m_area.X(x+m_area.XGap());
      m_canvas.X(x+m_canvas.XGap());
      m_current.X(x+m_current.XGap());
      m_picked.X(x+m_picked.XGap());
      m_hover.X(x+m_hover.XGap());
     }
//--- If the anchored to the bottom
   if(m_anchor_bottom_window_side)
     {
      //--- Storing coordinates in the element fields
      CElementBase::Y(m_wnd.Y2()-YGap());
      //--- Storing coordinates in the fields of the objects
      m_area.Y(m_wnd.Y2()-m_area.YGap());
      m_canvas.Y(m_wnd.Y2()-m_canvas.YGap());
      m_current.Y(m_wnd.Y2()-m_current.YGap());
      m_picked.Y(m_wnd.Y2()-m_picked.YGap());
      m_hover.Y(m_wnd.Y2()-m_hover.YGap());
     }
   else
     {
      //--- Storing coordinates in the fields of the objects
      CElementBase::Y(y+YGap());
      //--- Storing coordinates in the fields of the objects
      m_area.Y(y+m_area.YGap());
      m_canvas.Y(y+m_canvas.YGap());
      m_current.Y(y+m_current.YGap());
      m_picked.Y(y+m_picked.YGap());
      m_hover.Y(y+m_hover.YGap());
     }
//--- Updating coordinates of graphical objects
   m_area.X_Distance(m_area.X());
   m_area.Y_Distance(m_area.Y());
   m_canvas.X_Distance(m_canvas.X());
   m_canvas.Y_Distance(m_canvas.Y());
   m_current.X_Distance(m_current.X());
   m_current.Y_Distance(m_current.Y());
   m_picked.X_Distance(m_picked.X());
   m_picked.Y_Distance(m_picked.Y());
   m_hover.X_Distance(m_hover.X());
   m_hover.Y_Distance(m_hover.Y());
  }
//+------------------------------------------------------------------+
//| Shows a menu item                                                |
//+------------------------------------------------------------------+
void CColorPicker::Show(void)
  {
//--- Leave, if the element is already visible
   if(CElementBase::IsVisible())
      return;
//--- Make all the objects visible
   m_area.Timeframes(OBJ_ALL_PERIODS);
   m_canvas.Timeframes(OBJ_ALL_PERIODS);
   m_current.Timeframes(OBJ_ALL_PERIODS);
   m_picked.Timeframes(OBJ_ALL_PERIODS);
   m_hover.Timeframes(OBJ_ALL_PERIODS);
//--- Visible state
   CElementBase::IsVisible(true);
//--- Update the position of objects
   Moving(m_wnd.X(),m_wnd.Y(),true);
  }
//+------------------------------------------------------------------+
//| Hides a menu item                                                |
//+------------------------------------------------------------------+
void CColorPicker::Hide(void)
  {
//--- Leave, if the control is hidden
   if(!CElementBase::IsVisible())
      return;
//--- Hide all objects
   m_area.Timeframes(OBJ_NO_PERIODS);
   m_canvas.Timeframes(OBJ_NO_PERIODS);
   m_current.Timeframes(OBJ_NO_PERIODS);
   m_picked.Timeframes(OBJ_NO_PERIODS);
   m_hover.Timeframes(OBJ_NO_PERIODS);
//--- Visible state
   CElementBase::IsVisible(false);
  }
//+------------------------------------------------------------------+
//| Redrawing                                                        |
//+------------------------------------------------------------------+
void CColorPicker::Reset(void)
  {
//--- Leave, if this is a drop-down element
   if(CElementBase::IsDropdown())
      return;
//--- Hide and show
   Hide();
   Show();
  }
//+------------------------------------------------------------------+
//| Remove                                                         |
//+------------------------------------------------------------------+
void CColorPicker::Delete(void)
  {
//--- Removing objects
   m_area.Delete();
   m_canvas.Delete();
   m_current.Delete();
   m_picked.Delete();
   m_hover.Delete();
//--- Emptying the array of the objects
   CElementBase::FreeObjectsArray();
//--- Initializing of variables by default values
   CElementBase::IsVisible(true);
  }
//+------------------------------------------------------------------+
//| Seth the priorities                                              |
//+------------------------------------------------------------------+
void CColorPicker::SetZorders(void)
  {
   m_area.Z_Order(m_area_zorder);
   m_canvas.Z_Order(m_canvas_zorder);
   m_current.Z_Order(m_area_zorder);
   m_picked.Z_Order(m_area_zorder);
   m_hover.Z_Order(m_area_zorder);
//---
   m_radio_buttons.SetZorders();
   m_hsl_h_edit.SetZorders();
   m_hsl_s_edit.SetZorders();
   m_hsl_l_edit.SetZorders();
//---
   m_rgb_r_edit.SetZorders();
   m_rgb_g_edit.SetZorders();
   m_rgb_b_edit.SetZorders();
//---
   m_lab_l_edit.SetZorders();
   m_lab_a_edit.SetZorders();
   m_lab_b_edit.SetZorders();
//---
   m_button_ok.SetZorders();
   m_button_cancel.SetZorders();
  }
//+------------------------------------------------------------------+
//| Reset the priorities                                             |
//+------------------------------------------------------------------+
void CColorPicker::ResetZorders(void)
  {
   m_area.Z_Order(-1);
   m_canvas.Z_Order(-1);
   m_current.Z_Order(-1);
   m_picked.Z_Order(-1);
   m_hover.Z_Order(-1);
//---
   m_radio_buttons.ResetZorders();
   m_hsl_h_edit.ResetZorders();
   m_hsl_s_edit.ResetZorders();
   m_hsl_l_edit.ResetZorders();
//---
   m_rgb_r_edit.ResetZorders();
   m_rgb_g_edit.ResetZorders();
   m_rgb_b_edit.ResetZorders();
//---
   m_lab_l_edit.ResetZorders();
   m_lab_a_edit.ResetZorders();
   m_lab_b_edit.ResetZorders();
//---
   m_button_ok.ResetZorders();
   m_button_cancel.ResetZorders();
  }
//+------------------------------------------------------------------+
//| Set the current color                                            |
//+------------------------------------------------------------------+
void CColorPicker::CurrentColor(const color clr)
  {
   m_hover_color=clr;
   m_hover.Color(clr);
   m_hover.BackColor(clr);
   m_hover.Tooltip(::ColorToString(clr));
//---
   m_picked_color=clr;
   m_picked.Color(clr);
   m_picked.BackColor(clr);
   m_picked.Tooltip(::ColorToString(clr));
//---
   m_current_color=clr;
   m_current.BackColor(clr);
   m_current.Tooltip(::ColorToString(clr));
  }
//+------------------------------------------------------------------+
//| Get the color under the mouse cursor                             |
//+------------------------------------------------------------------+
bool CColorPicker::OnHoverColor(const int x,const int y)
  {
//--- Leave, if the focus is on the palette
   if(!m_canvas.MouseFocus())
      return(false);
//--- Determine the color on the palette under the mouse cursor
   int lx =x-m_canvas.X();
   int ly =y-m_canvas.Y();
   m_hover_color=(color)::ColorToARGB(m_canvas.PixelGet(lx,ly),0);
//--- Set the color and tooltip to the corresponding sample (marker)
   m_hover.Color(m_hover_color);
   m_hover.BackColor(m_hover_color);
   m_hover.Tooltip(::ColorToString(m_hover_color));
//--- Set the tooltip to the palette
   m_canvas.Tooltip(::ColorToString(m_hover_color));
   return(true);
  }
//+------------------------------------------------------------------+
//| Handling the pressing on the palette                             |
//+------------------------------------------------------------------+
bool CColorPicker::OnClickPalette(const string clicked_object)
  {
//--- Leave, if the object name does not match
   if(clicked_object!=m_canvas.Name())
      return(false);
//--- Set the color and tooltip to the corresponding sample
   m_picked_color=m_hover_color;
   m_picked.Color(m_picked_color);
   m_picked.BackColor(m_picked_color);
   m_picked.Tooltip(::ColorToString(m_picked_color));
//--- Calculate and set the color components according to the selected radio button
   SetComponents();
   return(true);
  }
//+------------------------------------------------------------------+
//| Handling the pressing on the radio button                        |
//+------------------------------------------------------------------+
bool CColorPicker::OnClickRadioButton(const long id,const int button_index,const string button_text)
  {
//--- Leave, if the identifiers do not match
   if(id!=CElementBase::Id())
      return(false);
//--- Leave, if the radio button text does not match
   if(button_text!=m_radio_buttons.SelectedButtonText())
      return(false);
//--- Update the palette with consideration of the recent changes
   DrawPalette(button_index);
   return(true);
  }
//+------------------------------------------------------------------+
//| Handling the entering new value in the edit box                  |
//+------------------------------------------------------------------+
bool CColorPicker::OnEndEdit(const long id,const int button_index)
  {
//--- Leave, if the identifiers do not match
   if(id!=CElementBase::Id())
      return(false);
//--- Calculate and set the color components for all color models 
   SetComponents(button_index,false);
   return(true);
  }
//+------------------------------------------------------------------+
//| Handling the pressing the 'OK' button                            |
//+------------------------------------------------------------------+
bool CColorPicker::OnClickButtonOK(const string clicked_object)
  {
//--- Leave, if the object name does not match
   if(clicked_object!=m_button_ok.Text())
      return(false);
//--- Store the selected color
   m_current_color=m_picked_color;
   m_current.BackColor(m_current_color);
   m_current.Tooltip(::ColorToString(m_current_color));
//--- If there is a pointer to the button for calling the color picker window
   if(::CheckPointer(m_color_button)!=POINTER_INVALID)
     {
      //--- Set the selected color to the button
      m_color_button.CurrentColor(m_current_color);
      //--- Close the window
      m_wnd.CloseDialogBox();
      //--- Send a message about it
      ::EventChartCustom(m_chart_id,ON_CHANGE_COLOR,CElementBase::Id(),CElementBase::Index(),m_color_button.LabelText());
      //--- Reset the pointer
      m_color_button=NULL;
     }
   else
     {
      //--- If there is no pointer and the it is a dialog window,
      //    display a message that there is no pointer to the button for calling the control
      if(m_wnd.WindowType()==W_DIALOG)
         ::Print(__FUNCTION__," > Invalid pointer of the calling control (CColorButton).");
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Handling the pressing the 'Cancel' button                        |
//+------------------------------------------------------------------+
bool CColorPicker::OnClickButtonCancel(const string clicked_object)
  {
//--- Leave, if the object name does not match
   if(clicked_object!=m_button_cancel.Text())
      return(false);
//--- Close the window, if it is a dialog window
   if(m_wnd.WindowType()==W_DIALOG)
      m_wnd.CloseDialogBox();
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Draw palette                                                     |
//+------------------------------------------------------------------+
void CColorPicker::DrawPalette(const int index)
  {
   switch(index)
     {
      //--- HSL (0: H, 1: S, 2: L)
      case 0 : case 1 : case 2 :
        {
         DrawHSL(index);
         break;
        }
      //--- RGB (3: R, 4: G, 5: B)
      case 3 : case 4 : case 5 :
        {
         DrawRGB(index);
         break;
        }
      //--- LAB (6: L, 7: a, 8: b)
      case 6 : case 7 : case 8 :
        {
         DrawLab(index);
         break;
        }
     }
//--- Draw palette frame
   DrawPaletteBorder();
//--- Update the palette
   m_canvas.Update();
  }
//+------------------------------------------------------------------+
//| Draw HSL palette                                                 |
//+------------------------------------------------------------------+
void CColorPicker::DrawHSL(const int index)
  {
   switch(index)
     {
      //--- Hue (H) - color hue ranging from 0 to 360
      case 0 :
        {
         //--- Calculate the H component
         m_hsl_h=m_hsl_h_edit.GetValue()/360.0;
         //---
         for(int ly=0; ly<m_canvas.YSize(); ly++)
           {
            //--- Calculate the L-component
            m_hsl_l=ly/(double)m_canvas.YSize();
            //---
            for(int lx=0; lx<m_canvas.XSize(); lx++)
              {
               //--- Calculate the S-component
               m_hsl_s=lx/(double)m_canvas.XSize();
               //--- Conversion of the HSL components into the RGB components
               m_clr.HSLtoRGB(m_hsl_h,m_hsl_s,m_hsl_l,m_rgb_r,m_rgb_g,m_rgb_b);
               //--- Merge channels
               uint rgb_color=XRGB(m_rgb_r,m_rgb_g,m_rgb_b);
               m_canvas.PixelSet(lx,m_canvas.YSize()-ly,rgb_color);
              }
           }
         break;
        }
      //--- Saturation (S) - saturation ranging from 0 to 100
      case 1 :
        {
         //--- Calculate the S-component
         m_hsl_s=m_hsl_s_edit.GetValue()/100.0;
         //---
         for(int ly=0; ly<m_canvas.YSize(); ly++)
           {
            //--- Calculate the L-component
            m_hsl_l=ly/(double)m_canvas.YSize();
            //---
            for(int lx=0; lx<m_canvas.XSize(); lx++)
              {
               //--- Calculate the H component
               m_hsl_h=lx/(double)m_canvas.XSize();
               //--- Conversion of the HSL components into the RGB components
               m_clr.HSLtoRGB(m_hsl_h,m_hsl_s,m_hsl_l,m_rgb_r,m_rgb_g,m_rgb_b);
               //--- Merge channels
               uint rgb_color=XRGB(m_rgb_r,m_rgb_g,m_rgb_b);
               m_canvas.PixelSet(lx,m_canvas.YSize()-ly,rgb_color);
              }
           }
         break;
        }
      //--- Lightness (L) - lightness ranging from 0 to 100
      case 2 :
        {
         //--- Calculate the L-component
         m_hsl_l=m_hsl_l_edit.GetValue()/100.0;
         //---
         for(int ly=0; ly<m_canvas.YSize(); ly++)
           {
            //--- Calculate the S-component
            m_hsl_s=ly/(double)m_canvas.YSize();
            //---
            for(int lx=0; lx<m_canvas.XSize(); lx++)
              {
               //--- Calculate the H component
               m_hsl_h=lx/(double)m_canvas.XSize();
               //--- Conversion of the HSL components into the RGB components
               m_clr.HSLtoRGB(m_hsl_h,m_hsl_s,m_hsl_l,m_rgb_r,m_rgb_g,m_rgb_b);
               //--- Merge channels
               uint rgb_color=XRGB(m_rgb_r,m_rgb_g,m_rgb_b);
               m_canvas.PixelSet(lx,m_canvas.YSize()-ly,rgb_color);
              }
           }
         break;
        }
     }
  }
//+------------------------------------------------------------------+
//| Draw RGB palette                                                 |
//+------------------------------------------------------------------+
void CColorPicker::DrawRGB(const int index)
  {
//--- Steps along the X and Y axes for calculation of the RGB components
   double rgb_x_step=255.0/m_canvas.XSize();
   double rgb_y_step=255.0/m_canvas.YSize();
//---
   switch(index)
     {
      //--- Red (R) - red. The color range is from 0 to 255
      case 3 :
        {
         //--- Get the current R-component and zero the B-component
         m_rgb_r =m_rgb_r_edit.GetValue();
         m_rgb_b =0;
         //---
         for(int ly=0; ly<m_canvas.YSize(); ly++)
           {
            //--- Calculate the B-component and zero the R-component
            m_rgb_g=0;
            m_rgb_b+=rgb_y_step;
            //---
            for(int lx=0; lx<m_canvas.XSize(); lx++)
              {
               //--- Calculate the G-component
               m_rgb_g+=rgb_x_step;
               //--- Merge channels
               uint rgb_color=XRGB(m_rgb_r,m_rgb_g,m_rgb_b);
               m_canvas.PixelSet(lx,m_canvas.YSize()-ly,rgb_color);
              }
           }
         break;
        }
      //--- Green (G) - green. The color range is from 0 to 255
      case 4 :
        {
         //--- Get the current G-component and zero the B-component
         m_rgb_g =m_rgb_g_edit.GetValue();
         m_rgb_b =0;
         //---
         for(int ly=0; ly<m_canvas.YSize(); ly++)
           {
            //--- Calculate the B-component and zero the R-component
            m_rgb_r=0;
            m_rgb_b+=rgb_y_step;
            //---
            for(int lx=0; lx<m_canvas.XSize(); lx++)
              {
               //--- Calculate the R-component
               m_rgb_r+=rgb_x_step;
               //--- Merge channels
               uint rgb_color=XRGB(m_rgb_r,m_rgb_g,m_rgb_b);
               m_canvas.PixelSet(lx,m_canvas.YSize()-ly,rgb_color);
              }
           }
         break;
        }
      //--- Blue (B) - blue. The color range is from 0 to 255
      case 5 :
        {
         //--- Get the current B-component and zero the G-component
         m_rgb_g =0;
         m_rgb_b =m_rgb_b_edit.GetValue();
         //---
         for(int ly=0; ly<m_canvas.YSize(); ly++)
           {
            //--- Calculate the G-component and zero the R-component
            m_rgb_r=0;
            m_rgb_g+=rgb_y_step;
            //---
            for(int lx=0; lx<m_canvas.XSize(); lx++)
              {
               //--- Calculate the R-component
               m_rgb_r+=rgb_x_step;
               //--- Merge channels
               uint rgb_color=XRGB(m_rgb_r,m_rgb_g,m_rgb_b);
               m_canvas.PixelSet(lx,m_canvas.YSize()-ly,rgb_color);
              }
           }
         break;
        }
     }
  }
//+------------------------------------------------------------------+
//| Draw Lab palette                                                 |
//+------------------------------------------------------------------+
void CColorPicker::DrawLab(const int index)
  {
   switch(index)
     {
      //--- Lightness (L) - lightness ranging from 0 to 100
      case 6 :
        {
         //--- Get the current L-component
         m_lab_l=m_lab_l_edit.GetValue();
         //---
         for(int ly=0; ly<m_canvas.YSize(); ly++)
           {
            //--- Calculate the b-component
            m_lab_b=(ly/(double)m_canvas.YSize()*255.0)-128;
            //---
            for(int lx=0; lx<m_canvas.XSize(); lx++)
              {
               //--- Calculate the a-component
               m_lab_a=(lx/(double)m_canvas.XSize()*255.0)-128;
               //--- Conversion of the Lab components into the RGB components
               m_clr.CIELabToXYZ(m_lab_l,m_lab_a,m_lab_b,m_xyz_x,m_xyz_y,m_xyz_z);
               m_clr.XYZtoRGB(m_xyz_x,m_xyz_y,m_xyz_z,m_rgb_r,m_rgb_g,m_rgb_b);
               //--- Adjust the RGB components
               AdjustmentComponentRGB();
               //--- Merge channels
               uint rgb_color=XRGB(m_rgb_r,m_rgb_g,m_rgb_b);
               m_canvas.PixelSet(lx,m_canvas.YSize()-ly,rgb_color);
              }
           }
         break;
        }
      //--- Chromatic component 'a' - ranges from -128 (green) to 127 (magenta)
      case 7 :
        {
         //--- Get the current a-component
         m_lab_a=m_lab_a_edit.GetValue();
         //---
         for(int ly=0; ly<m_canvas.YSize(); ly++)
           {
            //--- Calculate the b-component
            m_lab_b=(ly/(double)m_canvas.YSize()*255.0)-128;
            //---
            for(int lx=0; lx<m_canvas.XSize(); lx++)
              {
               //--- Calculate the L-component
               m_lab_l=100.0*lx/(double)m_canvas.XSize();
               //--- Conversion of the Lab components into the RGB components
               m_clr.CIELabToXYZ(m_lab_l,m_lab_a,m_lab_b,m_xyz_x,m_xyz_y,m_xyz_z);
               m_clr.XYZtoRGB(m_xyz_x,m_xyz_y,m_xyz_z,m_rgb_r,m_rgb_g,m_rgb_b);
               //--- Adjust the RGB components
               AdjustmentComponentRGB();
               //--- Merge channels
               uint rgb_color=XRGB(m_rgb_r,m_rgb_g,m_rgb_b);
               m_canvas.PixelSet(lx,m_canvas.YSize()-ly,rgb_color);
              }
           }
         break;
        }
      //--- Chromatic component 'b' - ranges from -128 (blue) to 127 (yellow)
      case 8 :
        {
         //--- Get the current b-component
         m_lab_b=m_lab_b_edit.GetValue();
         //---
         for(int ly=0; ly<m_canvas.YSize(); ly++)
           {
            //--- Calculate the a-component
            m_lab_a=(ly/(double)m_canvas.YSize()*255.0)-128;
            //---
            for(int lx=0; lx<m_canvas.XSize(); lx++)
              {
               //--- Calculate the L-component
               m_lab_l=100.0*lx/(double)m_canvas.XSize();
               //--- Conversion of the Lab components into the RGB components
               m_clr.CIELabToXYZ(m_lab_l,m_lab_a,m_lab_b,m_xyz_x,m_xyz_y,m_xyz_z);
               m_clr.XYZtoRGB(m_xyz_x,m_xyz_y,m_xyz_z,m_rgb_r,m_rgb_g,m_rgb_b);
               //--- Adjust the RGB components
               AdjustmentComponentRGB();
               //--- Merge channels
               uint rgb_color=XRGB(m_rgb_r,m_rgb_g,m_rgb_b);
               m_canvas.PixelSet(lx,m_canvas.YSize()-ly,rgb_color);
              }
           }
         break;
        }
     }
  }
//+------------------------------------------------------------------+
//| Draw palette frame                                               |
//+------------------------------------------------------------------+
void CColorPicker::DrawPaletteBorder(void)
  {
//--- Palette size
   int x_size=m_canvas.XSize()-1;
   int y_size=m_canvas.YSize()-1;
//--- Draw frame
   m_canvas.Line(0,0,x_size,0,m_palette_border_color);
   m_canvas.Line(0,y_size,x_size,y_size,m_palette_border_color);
   m_canvas.Line(0,0,0,y_size,m_palette_border_color);
   m_canvas.Line(x_size,0,x_size,y_size,m_palette_border_color);
  }
//+------------------------------------------------------------------+
//| Calculate and set the color components                           |
//+------------------------------------------------------------------+
void CColorPicker::SetComponents(const int index=0,const bool fix_selected=true)
  {
//--- If it is necessary to adjust the colors according to the component selected by the radio button
   if(fix_selected)
     {
      //--- Split the selected color into the RGB components
      m_rgb_r=m_clr.GetR(m_picked_color);
      m_rgb_g=m_clr.GetG(m_picked_color);
      m_rgb_b=m_clr.GetB(m_picked_color);
      //--- Convert the RGB components into HSL components
      m_clr.RGBtoHSL(m_rgb_r,m_rgb_g,m_rgb_b,m_hsl_h,m_hsl_s,m_hsl_l);
      //--- Adjust the HSL components
      AdjustmentComponentHSL();
      //--- Convert the RGB components into LAB components
      m_clr.RGBtoXYZ(m_rgb_r,m_rgb_g,m_rgb_b,m_xyz_x,m_xyz_y,m_xyz_z);
      m_clr.XYZtoCIELab(m_xyz_x,m_xyz_y,m_xyz_z,m_lab_l,m_lab_a,m_lab_b);
      //--- Set the colors in the edit boxes
      SetControls(m_radio_buttons.SelectedButtonIndex(),true);
      return;
     }
//--- Set the parameter of the color models
   switch(index)
     {
      case 0 : case 1 : case 2 :
         SetHSL();
         break;
      case 3 : case 4 : case 5 :
         SetRGB();
         break;
      case 6 : case 7 : case 8 :
         SetLab();
         break;
     }
//--- Draw the palette according to the selected radio button
   DrawPalette(m_radio_buttons.SelectedButtonIndex());
  }
//+------------------------------------------------------------------+
//| Set the current parameters in the edit boxes                     |
//+------------------------------------------------------------------+
void CColorPicker::SetControls(const int index,const bool fix_selected)
  {
//--- If is necessary to fix the value in the edit box of the selected radio button
   if(fix_selected)
     {
      //--- HSL components
      if(index!=0)
         m_hsl_h_edit.ChangeValue(m_hsl_h);
      if(index!=1)
         m_hsl_s_edit.ChangeValue(m_hsl_s);
      if(index!=2)
         m_hsl_l_edit.ChangeValue(m_hsl_l);
      //--- RGB components
      if(index!=3)
         m_rgb_r_edit.ChangeValue(m_rgb_r);
      if(index!=4)
         m_rgb_g_edit.ChangeValue(m_rgb_g);
      if(index!=5)
         m_rgb_b_edit.ChangeValue(m_rgb_b);
      //--- Lab components
      if(index!=6)
         m_lab_l_edit.ChangeValue(m_lab_l);
      if(index!=7)
         m_lab_a_edit.ChangeValue(m_lab_a);
      if(index!=8)
         m_lab_b_edit.ChangeValue(m_lab_b);
      return;
     }
//--- If is necessary to adjust the values in the edit boxes of all color models
   m_hsl_h_edit.ChangeValue(m_hsl_h);
   m_hsl_s_edit.ChangeValue(m_hsl_s);
   m_hsl_l_edit.ChangeValue(m_hsl_l);
//---
   m_rgb_r_edit.ChangeValue(m_rgb_r);
   m_rgb_g_edit.ChangeValue(m_rgb_g);
   m_rgb_b_edit.ChangeValue(m_rgb_b);
//---
   m_lab_l_edit.ChangeValue(m_lab_l);
   m_lab_a_edit.ChangeValue(m_lab_a);
   m_lab_b_edit.ChangeValue(m_lab_b);
  }
//+------------------------------------------------------------------+
//| Set the parameters of color models according to HSL              |
//+------------------------------------------------------------------+
void CColorPicker::SetHSL(void)
  {
//--- Get the current values of the HSL components
   m_hsl_h=m_hsl_h_edit.GetValue();
   m_hsl_s=m_hsl_s_edit.GetValue();
   m_hsl_l=m_hsl_l_edit.GetValue();
//--- Conversion of the HSL components into the RGB components
   m_clr.HSLtoRGB(m_hsl_h/360.0,m_hsl_s/100.0,m_hsl_l/100.0,m_rgb_r,m_rgb_g,m_rgb_b);
//--- Conversion of the RGB components into the Lab components
   m_clr.RGBtoXYZ(m_rgb_r,m_rgb_g,m_rgb_b,m_xyz_x,m_xyz_y,m_xyz_z);
   m_clr.XYZtoCIELab(m_xyz_x,m_xyz_y,m_xyz_z,m_lab_l,m_lab_a,m_lab_b);
//--- Set the current parameters in the edit boxes
   SetControls(0,false);
  }
//+------------------------------------------------------------------+
//| Set the parameters of color models according to RGB              |
//+------------------------------------------------------------------+
void CColorPicker::SetRGB(void)
  {
//--- Get the current values of the RGB components
   m_rgb_r=m_rgb_r_edit.GetValue();
   m_rgb_g=m_rgb_g_edit.GetValue();
   m_rgb_b=m_rgb_b_edit.GetValue();
//--- Conversion of the RGB components into the HSL components
   m_clr.RGBtoHSL(m_rgb_r,m_rgb_g,m_rgb_b,m_hsl_h,m_hsl_s,m_hsl_l);
//--- Adjust the HSL components
   AdjustmentComponentHSL();
//--- Conversion of the RGB components into the Lab components
   m_clr.RGBtoXYZ(m_rgb_r,m_rgb_g,m_rgb_b,m_xyz_x,m_xyz_y,m_xyz_z);
   m_clr.XYZtoCIELab(m_xyz_x,m_xyz_y,m_xyz_z,m_lab_l,m_lab_a,m_lab_b);
//--- Set the current parameters in the edit boxes
   SetControls(0,false);
  }
//+------------------------------------------------------------------+
//| Set the parameters of color models according to Lab              |
//+------------------------------------------------------------------+
void CColorPicker::SetLab(void)
  {
//--- Get the current values of the Lab components
   m_lab_l=m_lab_l_edit.GetValue();
   m_lab_a=m_lab_a_edit.GetValue();
   m_lab_b=m_lab_b_edit.GetValue();
//--- Conversion of the Lab components into the RGB components
   m_clr.CIELabToXYZ(m_lab_l,m_lab_a,m_lab_b,m_xyz_x,m_xyz_y,m_xyz_z);
   m_clr.XYZtoRGB(m_xyz_x,m_xyz_y,m_xyz_z,m_rgb_r,m_rgb_g,m_rgb_b);
//--- Adjust the RGB components
   AdjustmentComponentRGB();
//--- Conversion of the RGB components into the HSL components
   m_clr.RGBtoHSL(m_rgb_r,m_rgb_g,m_rgb_b,m_hsl_h,m_hsl_s,m_hsl_l);
//--- Adjust the HSL components
   AdjustmentComponentHSL();
//--- Set the current parameters in the edit boxes
   SetControls(0,false);
  }
//+------------------------------------------------------------------+
//| Adjustment of the RGB components                                 |
//+------------------------------------------------------------------+
void CColorPicker::AdjustmentComponentRGB(void)
  {
   m_rgb_r=::fmin(::fmax(m_rgb_r,0),255);
   m_rgb_g=::fmin(::fmax(m_rgb_g,0),255);
   m_rgb_b=::fmin(::fmax(m_rgb_b,0),255);
  }
//+------------------------------------------------------------------+
//| Adjustment of the HSL components                                 |
//+------------------------------------------------------------------+
void CColorPicker::AdjustmentComponentHSL(void)
  {
   m_hsl_h*=360;
   m_hsl_s*=100;
   m_hsl_l*=100;
  }
//+------------------------------------------------------------------+
//| Fast scrolling of values in the edit                             |
//+------------------------------------------------------------------+
void CColorPicker::FastSwitching(void)
  {
//--- Leave, if the focus is not on the control
   if(!CElementBase::MouseFocus())
      return;
//--- Return counter to initial value if the mouse button is released если кнопка мыши отжата
   if(!m_mouse.LeftButtonState())
      m_timer_counter=SPIN_DELAY_MSC;
//--- If the mouse button is pressed down
   else
     {
      //--- Increase the counter by the set step
      m_timer_counter+=TIMER_STEP_MSC;
      //--- Exit if below zero
      if(m_timer_counter<0)
         return;
      //--- Determination of the activated counter of the activated radio button
      int index=WRONG_VALUE;
      if(m_radio_buttons.SelectedButtonIndex()==0 && (m_hsl_h_edit.StateInc() || m_hsl_h_edit.StateDec()))
         index=0;
      else if(m_radio_buttons.SelectedButtonIndex()==1 && (m_hsl_s_edit.StateInc() || m_hsl_s_edit.StateDec()))
         index=1;
      else if(m_radio_buttons.SelectedButtonIndex()==2 && (m_hsl_l_edit.StateInc() || m_hsl_l_edit.StateDec()))
         index=2;
      else if(m_radio_buttons.SelectedButtonIndex()==3 && (m_rgb_r_edit.StateInc() || m_rgb_r_edit.StateDec()))
         index=3;
      else if(m_radio_buttons.SelectedButtonIndex()==4 && (m_rgb_g_edit.StateInc() || m_rgb_g_edit.StateDec()))
         index=4;
      else if(m_radio_buttons.SelectedButtonIndex()==5 && (m_rgb_b_edit.StateInc() || m_rgb_b_edit.StateDec()))
         index=5;
      else if(m_radio_buttons.SelectedButtonIndex()==6 && (m_lab_l_edit.StateInc() || m_lab_l_edit.StateDec()))
         index=6;
      else if(m_radio_buttons.SelectedButtonIndex()==7 && (m_lab_a_edit.StateInc() || m_lab_a_edit.StateDec()))
         index=7;
      else if(m_radio_buttons.SelectedButtonIndex()==8 && (m_lab_b_edit.StateInc() || m_lab_b_edit.StateDec()))
         index=8;
      //--- If so, update the palette
      if(index!=WRONG_VALUE)
         DrawPalette(index);
      //--- Determine the activated counter
      index=WRONG_VALUE;
      if(m_hsl_h_edit.StateInc() || m_hsl_h_edit.StateDec())
         index=0;
      else if(m_hsl_s_edit.StateInc() || m_hsl_s_edit.StateDec())
         index=1;
      else if(m_hsl_l_edit.StateInc() || m_hsl_l_edit.StateDec())
         index=2;
      else if(m_rgb_r_edit.StateInc() || m_rgb_r_edit.StateDec())
         index=3;
      else if(m_rgb_g_edit.StateInc() || m_rgb_g_edit.StateDec())
         index=4;
      else if(m_rgb_b_edit.StateInc() || m_rgb_b_edit.StateDec())
         index=5;
      else if(m_lab_l_edit.StateInc() || m_lab_l_edit.StateDec())
         index=6;
      else if(m_lab_a_edit.StateInc() || m_lab_a_edit.StateDec())
         index=7;
      else if(m_lab_b_edit.StateInc() || m_lab_b_edit.StateDec())
         index=8;
      //--- If so, recalculate the components of all color models and update the palette
      if(index!=WRONG_VALUE)
         SetComponents(index,false);
     }
  }
//+------------------------------------------------------------------+
