{
Changelog:
- 31 oct 2015
  - removed (commented out (**) ) extension support and IPC message in order
    to just use console output instead of buggy memory leak extensions BUT
    i will be kept afterall, for FREERAM purposes since Flash still clutters
    ram for after downloading new song
}
unit subprocess_main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cefvcl, ceflib, Vcl.StdCtrls, psapi;


const
  TH_MSG = 3;
const
(*  WM_JAVASCRIPT = 1024;
  WM_GETSONGNAME = WM_USER + 1;
  WM_GETARTISTNAME = WM_USER + 2;
  WM_GETCOVERARTURL = WM_USER + 3;
  WM_GETSONGDURATION = WM_USER + 4;
  WM_GETSONGPOSITION = WM_USER + 5;
  WM_ISPLAYCONTROLENABLED = WM_USER + 6;
  WM_ISMUSICPLAYING = WM_USER + 7;*)
  WM_FREERAM = WM_USER + 8;
type
  TForm1 = class(TForm)
    Label1: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TCustomRenderProcessHandler = class(TCefRenderProcessHandlerOwn)
  protected
    procedure OnWebKitInitialized; override;
{    function OnProcessMessageReceived(const browser: ICefBrowser; sourceProcess: TCefProcessId;
          const message: ICefProcessMessage): Boolean; override;}
  end;

  TMusic = class(TThread)
    class function getJavaScriptValue(const TaskID: Integer;const val: ICefv8Value): Boolean;
//    class procedure getSongName(_songname : string);
//    class procedure getArtistName(_artistname : string);
//    class procedure getCoverArtURL(_coverarturl: string);
//    class procedure getSongDuration(_songduration: string);
//    class procedure getSongPosition(_songposition: string);
//    class procedure isPlayControlEnabled(_query: string);
//    class procedure isMusicPlaying(_query: string);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TCustomRenderProcessHandler.OnWebKitInitialized;
begin
  TCefRTTIExtension.Register('gmusic',TMusic);
end;

class function TMusic.getJavaScriptValue(const TaskID: Integer;const val: ICefv8Value): Boolean;
(*var
  MainHWND: HWND;
  MsgStr: UTF8String;
  Msg: PCopyDataStruct;  *)
begin

  if TaskID = WM_FREERAM then
  begin
//    OutputDebugString(PChar(IntToStr(TaskID))); //it works !!!!!
    try
      EmptyWorkingSet(GetCurrentProcess)
    except
    end;

    (*MsgStr := 'Memory was released.';*)
  end;
  (*else
  MsgStr := val.GetStringValue;
  Msg := nil;
  New(Msg);
  Msg^.dwData := TaskID;
  Msg^.cbData := Length(MsgStr)+1;
  Msg^.lpData := PAnsiChar(UTF8String(MsgStr));

  MainHWND := FindWindow('GMusicWndClass', nil);
  if MainHWND <> 0 then
  begin
    SendMessageTimeout(MainHWND, WM_COPYDATA, CurrentThread.Handle, Integer(Msg),SMTO_ABORTIFHUNG,500,nil);
  end;

  Dispose(Msg);*)

  Result := True;
end;

initialization

  CefRenderProcessHandler := TCustomRenderProcessHandler.Create;
end.
