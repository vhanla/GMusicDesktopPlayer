{

Changelog:
16 octubre 2011
- Fixed topmost popup, now works even when miniapp is not topmost
  on show it changes to fsAlwaysOnTop and on hide changes back to normal
  left Formcreate ontop changes to allow showing even when minimized
}
unit gadget;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, pngimage, ExtCtrls, StdCtrls;

type
  TfrmGadget = class(TForm)
    Image2: TImage;
    lblArtist: TLabel;
    lblSong: TLabel;
    Timer1: TTimer;
    procedure Image2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private
    { Private declarations }
    //to deny minimization
    procedure WMShowWindow(var msg: TWMShowWindow);
  public
    { Public declarations }
    Start: Cardinal;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMActivate(Var msg:tMessage); message WM_ACTIVATE;
  end;

var
  frmGadget: TfrmGadget;


implementation

{$R *.dfm}
uses gmusic_src;

procedure TfrmGadget.WMShowWindow(var msg: TWMShowWindow);
begin
  if not msg.Show then
  msg.Result:=0
  else
  inherited
end;

procedure TfrmGadget.FormCreate(Sender: TObject);
begin
  Start:=GetTickCount;
  left:=screen.WorkAreaLeft+Screen.WorkAreaWidth-width-10;
  top:=screen.WorkAreaTop+screen.WorkAreaHeight-height-10;


{  ShowWindow(self.Handle, SW_HIDE) ;
  SetWindowLong(self.Handle, GWL_EXSTYLE, getWindowLong(self.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW) ;
  ShowWindow(self.Handle, SW_SHOW) ;}

  SetWindowLong(self.Handle, GWL_EXSTYLE, GetWindowLong(self.Handle, GWL_EXSTYLE) Or WS_EX_LAYERED or {WS_EX_TRANSPARENT or} WS_EX_TOOLWINDOW {and not WS_EX_APPWINDOW});
   SetLayeredWindowAttributes(self.Handle,0,230, LWA_ALPHA);

   SetWindowPos(self.Handle,HWND_TOPMOST,Left,Top,Width, Height,SWP_NOMOVE or SWP_NOACTIVATE or SWP_NOSIZE);

end;

procedure TfrmGadget.FormShow(Sender: TObject);
begin
Timer1.Enabled:=true;

end;

procedure TfrmGadget.Image2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
ReleaseCapture;
  Perform(WM_SYSCOMMAND, $F012, 0);

end;

procedure TfrmGadget.Timer1Timer(Sender: TObject);
begin
if (GetTickCount-Start)>=form1.SpinEdit1.Value*1000 then //in seconds
begin
     //Timer2.Enabled:=false;
     self.FormStyle:=fsNormal;
     hide;
end;
end;

procedure TfrmGadget.Timer2Timer(Sender: TObject);
begin
if AlphaBlendValue<255 then
  AlphaBlendValue:=AlphaBlendValue+1;
end;

procedure TfrmGadget.CreateParams(var Params: TCreateParams);
begin
  inherited;
//  Params.Style:=WS_POPUP or WS_THICKFRAME;
  Params.WindowClass.Style := Params.WindowClass.Style or CS_DROPSHADOW;
end;

procedure TfrmGadget.WMActivate(var msg: TMessage);
begin
  if msg.WParam = WA_INACTIVE then
  hide;
end;

end.
