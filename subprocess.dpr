program subprocess;

uses
  Vcl.Forms,
  subprocess_main in 'subprocess_main.pas' {Form1},
  ceflib, Windows, Controls, SysUtils;

{$R *.res}

begin
{  if (FindWindow('GMusicWndClass', nil) = 0) then
 // (GetParent(Application.Handle) <> FindWindow('GMusicWndClass', nil)) then
  begin
    raise Exception.Create('This application doesn''t run standalone. It needs Gmusic.');
    Exit;
  end;}

  CefSingleProcess := False;
  if not CefLoadLibDefault then
    Exit;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
