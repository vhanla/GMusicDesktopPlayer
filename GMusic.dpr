program GMusic;

{$R *.dres}

uses
  Forms,
  Windows,
  Messages,
  gmusic_src in 'gmusic_src.pas' {Form1},
  ceflib,
  sysutils,
  gadget in 'gadget.pas' {frmGadget},
//  ScrobblerUtils in 'ScrobblerUtils.pas'},
  dropshadow_src in 'dropshadow_src.pas' {frmShadow};

{$R *.res}
procedure SwitchToThisWindow(h1: hWnd; x: bool); stdcall;
  external user32 Name 'SwitchToThisWindow';

procedure CustomCommandLine (const processType: ustring; const commandLine: ICefCommandLine);
begin
    commandLine.AppendSwitch('--enable-system-flash'); // since it doesn't need any value, that's enough, otherwise use AppendSwitchWithValue(switch, value);
end;
var
  MyWndClass : HWND;
//  Mutex: THandle;
//  MyMsg: Cardinal;
begin
//ClassName:CefBrowserWindow | DevTools
  MyWndClass := FindWindow('GMusicWndClass',nil);
  if (MyWndClass > 0) then// and (IsWindowVisible(MyWndClass) )then
  begin
    SwitchToThisWindow(MyWndClass,true);
    exit;
  end;

{Attempt to create a named mutex}
(*  MyMsg := RegisterWindowMessage(PChar(Application.ExeName + '_Mutex'));
  Mutex := CreateMutex(nil, false, PChar(Application.ExeName + '_Mutex'));
  //if it failed then there is another instance
  if (Mutex = 0) or (GetLastError = ERROR_ALREADY_EXISTS) then
    Exit; *) //this doesn't work

  CefCache:='cache';
//  CefUserAgent := 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.71 Safari/537.36 OPR/33.0.1990.43';
  CefOnBeforeCommandLineProcessing := CustomCommandLine;
  CefSingleProcess := False;
  if not FileExists(ExtractFilePath(ParamStr(0))+'subprocess.exe') then
  begin
    raise Exception.Create('subprocess.exe not found!');
    Exit;
  end;

  CefBrowserSubprocessPath := 'subprocess.exe';

  if not CefLoadLibDefault then
    Exit;

  Application.Initialize;
  Application.MainFormOnTaskBar:=true; //to show thumbnail buttons
  Application.Title := 'GMusic Desktop';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TfrmGadget, frmGadget);
  Application.CreateForm(TfrmShadow, frmShadow);
  Application.Run;
end.
