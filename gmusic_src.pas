{
Google Music Desktop Player for Windows 7

[TODO]
  11 feb 2015 : popup notification

Changelog:

- 03 Nov 2015 - v.1.9.15
  - New Chromium v45 (DCEF2 branch 2454)
  - Added PPAPI switch on Project's Source in order to enable the swtich --enable-system-flash
  - Updated onBeforeResourceLoad, since previous was not compatible
    changed Result := True to RV_CANCEL
  - Update OnBeforePopup method, since it has different params
- 31 Oct 2015 - v.1.9.14
  - Changed extension to use console debug output instead, so memory will not
    be impacted
  - Added WMMove event listener in order to make it smoother the shadow alignment on window dragging
  - Maintained Extension in order to send freeram, it will be used for Flash bad garbage accumulator
  - Removed search box previously added when it was not available
- 13 Feb 2015 - v.1.9.13
  - Added FreeRam WM_FREERAM event, in order to release unused memory in that hungry process
  - Fixed min width to 430 in order to avoid the settings text to over position on the caption text
  - Fixed non selectable html elements

- 12 Feb 2015 - v.1.9.12
  - Adding support to read custom colors from userstyle
    Modifying color of:
    imgTopBar.visible needs to be set false, in order to make it work, and change back if not used
    pnlTitleBar.color := $004C4C4C by default;
    Shape2.Brush.Color := $001E68D7;
    Shape1.Brush.Color := clGray;
    lblCaption.font.color := clWhite;
    lblSettings.Font.Color := clGray

    Format read: First lines | see LoadCustomCSS procedure
    TitleBarColor = $004C4C4C
    TitleBarTextColor = clWhite
    LoadingBarColor = $001E68D7
    LoadingBarBGColor = clGray
    SettingsTextColor = clGray

  -  fixed error on close, it was the .dpr code
     CefSingleProcess := False;
     if not CefLoadLibDefault then
       Exit;
     It needs to be in both executables

  - moved the extension code to the other executable
  - Removed Google name in order to avoid any undesireable actions from Google :P
  - Fixed loading animation
  - Fixed context menu, adding in resourceload the javascript to avoid it

- 11 Feb 2015 - v.1.9.11

  - Disabled popup notification;
    and free ram, since it is not single threaded anymore

  - Added function to disabled elements which are not available in this application, like miniplayer, upload music, etc.
    modified here procedure TForm1.Chromium1LoadEnd(Sender: TObject; const browser: ICefBrowser;

  - Added RTTI Extension now works on DCEF3 multi threaded
  - Modified CreateParams in order to name the first window as correct
  - Fixed functions to read status from the music: getmusic... gplay, gpause
  - Created an external process executable to handle extensions and allow the application
    not to block TChromium [NOT USED YET, SINCE IT POPS UP A HORRIBLE ERROR AT THE END OF THE APPLICATION]

  - Modified CreateParams in order to create only one instance, naming the others as _child prefixes
    but it doesn't work 100% since it still blocks the DevTools.

- 08 Feb 2015 - v.1.9.8
  - If flash is not present we open get.adobe.com/flashplayer from chromium
    in order to open in a normal web browser
  - Using Cefv8Handler instead of old rtti extension which doesn't work, and if worked before
    it generated a lot of memory increase

- 30 Jan 2015 - v.1.9.0 New DCEF3 version
  - ...

- 31 Jul 2014 - v.1.8.9 New DCEF3 version
  - DPR modified to use multithreading (disable it to debug extension)


- 12 Jun 2013 - v.1.8.8 HUNTING MEMORY LEAKS
  - Lets kick this out

- 27 May 2013 - v.1.8.7
  - Bug hunting
- 19 May 2013 - v.1.8.6
  - Changed trimmemoryspace with EmptyWorkingSet(GetCurrentProcess) to release unused RAM
    thanks to Flash Player that totally sucks

- Launch this version as v.2.0 since it uses DCEF3
- 15 May 2013 - v.1.8.5 - Google I/O Changes
  - Adjusting to changes done in Google I/O
  / Turns out that setting form1.position on formcreate, makes chromium to crash
  - Fixed scrolling on secondary monitor
  - DCEF3 working perfectly (changed to DCEF3)
  - Fixed shadow showing when onactivate event when maximized
  - Added search box
  - Custom style dark updated

- 10 March 2013 - v.1.8.3
  - Fixed getting Artist Name
  - Fixed on FormResize to hide the shadow when wsMinimized
  and also added code in PlayerStatus Timer to make sure it doesn't fail at all

- 11 Julio 2012 - v.1.8.2
  - Added custom shadow to mimic Metro better
    added on many events to make it better

  - Dropped old shadow method

- 07 Julio 2012 - v.1.8.1
  - Improved custom.css support for faster loading & unloading
  - deletefiles causes bad loading page - no css bug

- 06 julio 2012 - v.1.8
-----------------------
  - Added custom.css support
  - Now it loads faster (shows the webpage at first resource loading file)
  - Fixed scrollbars to look correctly as metro i.e. not rounded radius (3)
  - Added loading animation metro style (tmrLoading)

- 02 julio 2012 - v.1.7.5
----------------------
    - labs link}
//  labs SJBpost('playlistSelected', null, {id: 'labs'});
//  settings SJBpost('playlistSelected', null, {id: 'settings'});
//  trash SJBpost('playlistSelected', null, {id: 'auto-playlist-trash'});

{- 04 mayo 2012 - v.1.7
----------------------
  - Added only one instance feature
    on trying to start another one, switch to the actual one
  - Added classname GMusicWndClass
  - Fixed to new URL Play.google
  - Eliminated download url since google offers it


  TODO
  - Volume control on widget
    also transparency

- 28 febrero 2012 - v.1.6
---------------------
  TODO
  - Free Cache
  - CD Art Display integration
  - Fix Download Button
  - Remember window size
  - Thumbs Up -> love fm

- 16 octubre 2011 - v.1.5
---------------------
  - added userscript to fix ugly scrollbars
  - added userscript to allow music download
  - fixed popup info topmost feature working fine now
  - fixed multimonitor support for maximizing and aerosnap feature
    thanks to whichmonitor function
  - fixed popup showing at the end of the playlist
    with isplaycontrolenabled function


}
unit gmusic_src;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cefvcl, Menus,ceflib, ExtCtrls, ComObj, ShlObj, StdCtrls, pngimage,
  jpeg, ImgList, ActiveX, ShellAPI, IniFiles, XPMan, Md5, Synautil,DateUtils, Spin,
  Vcl.Imaging.GIFImg, dropshadow_src, psapi, System.ImageList;

type

  pICefBrowser = ^ICefBrowser;
  pComboBox = ^TComboBox;
  TForm1 = class(TForm)
    tmrUpdatePlayerStatus: TTimer;
    pnlTitleBar: TPanel;
    pnlResizeBorder: TPanel;
    imgResizer: TImage;
    imgTopBar: TImage;
    tmrHotKeys: TTimer;
    ImageList1: TImageList;
    tmrWin7TaskBar: TTimer;
    pnlSplashScreen: TPanel;
    Image1: TImage;
    pnlMiniPlayer: TPanel;
    pnlSettings: TPanel;
    imgMiniCover: TImage;
    Image2: TImage;
    imgPlay: TImage;
    lblCaption: TLabel;
    imgClose: TImage;
    imgMinimize: TImage;
    imgResize: TImage;
    Button1: TButton;
    imgMini: TImage;
    imgPrev: TImage;
    imgNext: TImage;
    imgClose2: TImage;
    imgMinimize2: TImage;
    imgMini2: TImage;
    imgVolume: TImage;
    lblSettings: TLabel;
    GroupBox1: TGroupBox;
    XPManifest1: TXPManifest;
    Memo1: TMemo;
    lblUserName: TLabel;
    CheckBox1: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    lblBtnAuthorize: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    GroupBox2: TGroupBox;
    CheckBox2: TCheckBox;
    Label7: TLabel;
    GroupBox3: TGroupBox;
    chkMiniOnTop: TCheckBox;
    chkNotify: TCheckBox;
    Image3: TImage;
    chkCustomCSS: TCheckBox;
    SpinEdit1: TSpinEdit;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    pnlLastFM: TPanel;
    lblPlayBackStatus: TLabel;
    lblArtist: TLabel;
    lblSong: TLabel;
    lblCover: TLabel;
    lblUpdated: TLabel;
    lblScrobbled: TLabel;
    Memo2: TMemo;
    ComboBox1: TComboBox;
    lblLabs: TLabel;
    lblTrash: TLabel;
    tmrLoading: TTimer;
    Shape1: TShape;
    Shape2: TShape;
    cbUserStyles: TComboBox;
    lblSearch: TLabel;
    tmrGadgetStatus: TTimer;
    Chromium1: TChromium;
    procedure FormCreate(Sender: TObject);
    procedure Artist1Click(Sender: TObject);
    procedure Song1Click(Sender: TObject);
    procedure Picture1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tmrUpdatePlayerStatusTimer(Sender: TObject);
    procedure HideMe1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure imgResizerMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure tmrHotKeysTimer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure tmrWin7TaskBarTimer(Sender: TObject);
    procedure lblCaptionMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblCaptionDblClick(Sender: TObject);
    procedure imgCloseMouseEnter(Sender: TObject);
    procedure imgCloseMouseLeave(Sender: TObject);
    procedure imgMinimizeMouseEnter(Sender: TObject);
    procedure imgMinimizeMouseLeave(Sender: TObject);
    procedure imgResizeMouseEnter(Sender: TObject);
    procedure imgResizeMouseLeave(Sender: TObject);
    procedure imgCloseClick(Sender: TObject);
    procedure imgResizeClick(Sender: TObject);
    procedure imgMinimizeClick(Sender: TObject);
    procedure imgMiniMouseEnter(Sender: TObject);
    procedure imgMiniMouseLeave(Sender: TObject);
    procedure imgMiniClick(Sender: TObject);
    procedure imgPlayMouseEnter(Sender: TObject);
    procedure imgPlayMouseLeave(Sender: TObject);
    procedure imgNextMouseEnter(Sender: TObject);
    procedure imgNextMouseLeave(Sender: TObject);
    procedure imgPrevMouseEnter(Sender: TObject);
    procedure imgPrevMouseLeave(Sender: TObject);
    procedure imgVolumeMouseEnter(Sender: TObject);
    procedure imgVolumeMouseLeave(Sender: TObject);
    procedure imgMini2MouseEnter(Sender: TObject);
    procedure imgMini2MouseLeave(Sender: TObject);
    procedure imgMinimize2MouseEnter(Sender: TObject);
    procedure imgMinimize2MouseLeave(Sender: TObject);
    procedure imgClose2MouseEnter(Sender: TObject);
    procedure imgClose2MouseLeave(Sender: TObject);
    procedure imgMini2Click(Sender: TObject);
    procedure imgMinimize2Click(Sender: TObject);
    procedure imgClose2Click(Sender: TObject);
    procedure imgPlayClick(Sender: TObject);
    procedure imgMiniCoverMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure lblSettingsClick(Sender: TObject);
    procedure lblSettingsMouseEnter(Sender: TObject);
    procedure lblSettingsMouseLeave(Sender: TObject);
    procedure imgPrevClick(Sender: TObject);
    procedure imgNextClick(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure lblBtnAuthorizeClick(Sender: TObject);
    //controlling music
    procedure GPlay;
    procedure GPause;
    procedure GRewind;
    procedure GForward;
    procedure GShowModal;
    procedure GHideModal;
    //lastfm scrobbling
    procedure lfmPlay(Artist, Song, Album, Length, Track: string);
    procedure lfmStop;
    procedure lfmNext(Artist, Song, Album, Length, Track: string);
    procedure Label3Click(Sender: TObject);
    procedure Label5Click(Sender: TObject);
    procedure Label6Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure chkMiniOnTopClick(Sender: TObject);
    procedure chkNotifyClick(Sender: TObject);
    procedure Label10Click(Sender: TObject);



    procedure lblLabsClick(Sender: TObject);
    procedure lblTrashClick(Sender: TObject);

    procedure Chromium1LoadStart(Sender: TObject; const browser: ICefBrowser;
      const frame: ICefFrame);
    procedure chkCustomCSSClick(Sender: TObject);
    procedure tmrLoadingTimer(Sender: TObject);
    procedure cbUserStylesChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Chromium1LoadEnd(Sender: TObject; const browser: ICefBrowser;
      const frame: ICefFrame; httpStatusCode: Integer);
    procedure Chromium1BeforeContextMenu(Sender: TObject;
      const browser: ICefBrowser; const frame: ICefFrame;
      const params: ICefContextMenuParams; const model: ICefMenuModel);
    procedure lblSearchClick(Sender: TObject);
    procedure tmrGadgetStatusTimer(Sender: TObject);
    procedure Chromium1ContextMenuCommand(Sender: TObject;
      const browser: ICefBrowser; const frame: ICefFrame;
      const params: ICefContextMenuParams; commandId: Integer;
      eventFlags: TCefEventFlags; out Result: Boolean);
    procedure Chromium1ConsoleMessage(Sender: TObject;
      const browser: ICefBrowser; const message, source: ustring; line: Integer;
      out Result: Boolean);
    procedure Chromium1BeforePopup(Sender: TObject; const browser: ICefBrowser;
      const frame: ICefFrame; const targetUrl, targetFrameName: ustring;
      targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean;
      var popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo;
      var client: ICefClient; var settings: TCefBrowserSettings;
      var noJavascriptAccess: Boolean; out Result: Boolean);
    procedure Chromium1BeforeResourceLoad(Sender: TObject;
      const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; const callback: ICefRequestCallback;
      out Result: TCefReturnValue);private
    { Private declarations }
    FTick : Int64;
    FButtons: array[0..3] of TThumbButton;
    FNormalIcon: Cardinal;
    FPauseIcon: Cardinal;
    FTaskBar: ITaskbarList3;
    //to deny minimization while in mini mode
    procedure WMShowWindow(var msg: TWMShowWindow);
    //sticky form for miniplayer mainly
    procedure WMWindowPosChanging(var Msg: TWMWindowPosChanging);message WM_WINDOWPOSCHANGING;
    //to move shadow while dragging main form
    procedure WMMove(var Msg: TWMMove); message WM_MOVE;
  public
    { Public declarations }
    actualcoverURL,coverURL: string;
    actualSong, songName: string;
    actualArtist, artistName,oldArtist,oldSong,oldDuration: string;
    actualDuration: string;
    songDuration, songPosition: string;
    isPlaying: string; //before was boolean;
    miniplayer: boolean;
    //for playback ocontrols
    isPlayBackEnabled: string; // boolean;
    nWidth,nHeight,nLeft,nTop: cardinal; // normal size of form to restore
    mWidth,mHeight,mLeft,mTop: cardinal; // mini size of form to minify
    songCompleted: Boolean;
    //for gadget monitoring
    prevPlaybackState : boolean; // false: not playing; true : playing

    //lastfm
    PlayerStatus: Integer;
    UserName,Key, Token: string;
    StartTime: longint;

    //dock
    Docked: Boolean;

    //custom css
    CSSLoaded: Boolean;
    CustomCSS: string;
  private
    FLoading: Boolean;
    procedure ListCustomCSS(listcss: pComboBox);
    procedure LoadCustomCSS(browser: pICefBrowser; cssfile: string);
    procedure UnLoadCustomCSS(browser: pICefBrowser);
    //FRMSHADOW
    procedure OnFocus(Sender: TObject);
    procedure OnLostFocus(Sender: TObject);
    //FRMSHADOW

    function IsMain(const b: ICefBrowser; const f: ICefFrame = nil): Boolean;
  protected
    procedure WndProc(var Message: TMessage);override;
    procedure CreateParams(var Params: TCreateParams);override;
    Procedure PlaybackMessage(Var aMsg: TMessage); message WM_User+850;
    procedure WMCopyData(var message: TMessage);message WM_COPYDATA;
  end;


var
  Form1: TForm1;
  //FRMSHADOW

const
  API_Key = '55f56f7b910a196d23b383efba6b5a91';
  API_secret ='8e10c944d9d67628b6deafd4773f767d';
  WM_PlayBack = WM_User + 850;
  UnixStartDate: TDateTime = 25569.0;
  ps_Stopped = 0;
  ps_Paused = 1;
  ps_Playing = 2;

procedure SwitchToThisWindow(h1: hWnd; x: bool); stdcall;
  external user32 Name 'SwitchToThisWindow';

implementation

{$R *.dfm}

{$R 'buttons.res'}
uses gadget,httpsend, ioutils {this is for css loading};

var
  WM_TASKBARBUTTONCREATED: Cardinal;
  isWindows7: boolean = false;

//******* Extensions support ***********///
const
  WM_JAVASCRIPT = 1024;
  WM_GETSONGNAME = WM_USER + 1;
  WM_GETARTISTNAME = WM_USER + 2;
  WM_GETCOVERARTURL = WM_USER + 3;
  WM_GETSONGDURATION = WM_USER + 4;
  WM_GETSONGPOSITION = WM_USER + 5;
  WM_ISPLAYCONTROLENABLED = WM_USER + 6;
  WM_ISMUSICPLAYING = WM_USER + 7;
  WM_FREERAM = WM_USER + 8;

//******* GLOBAL FUNCTIONS *************///

function GetCoverArtURL:string;
begin
  Form1.Chromium1.Browser.MainFrame.ExecuteJavaScript(
    'if(document.getElementById("playingAlbumArt")){console.log("WM_GETCOVERARTURL"+document.getElementById("playingAlbumArt").src);}','',0);


  if pos('//',form1.coverURL)=1 then
    result:='http:'+form1.coverURL
  else if pos('https://',form1.coverURL)=1 then
    result:='http://'+copy(form1.coverURL,9,StrLen(pchar(form1.coverURL))-9)
  else
    result := form1.coverURL;

end;

procedure GetCoverArt;
var
imagen: TJPEGImage;
imapng: TPngImage;
coverArtURI: string;
begin
coverArtURI:= GetCoverArtURL;
if coverArtURI='' then exit;

with THTTPSend.Create do
begin
  if HTTPMethod('GET',GetCoverArtURL) then
  try
    imagen:=TJPEGImage.Create;
    Document.Seek(0,0);
    imagen.LoadFromStream(Document);
    frmGadget.Image2.Picture.Graphic:=imagen;
    form1.imgMiniCover.Picture.Graphic:=imagen;
    imagen.Free;
  except
    //it might be a PNG file
    try
      imapng:=TPngImage.Create;
      Document.Seek(0,0);
      imapng.LoadFromStream(Document);
      frmGadget.Image2.Picture.Graphic:=imapng;
      form1.imgMiniCover.Picture.Graphic:=imapng;
      imapng.Free;
    except
      //just ignore it
    end;
  end;
  Free;
end;
end;

function GetArtistName:string;
begin
  Form1.Chromium1.Browser.MainFrame.ExecuteJavaScript(
    'if(document.getElementById("player-artist")){console.log("WM_GETARTISTNAME"+ document.getElementById("player-artist").innerText)}','',0);

  if form1.artistName<>'' then
   result:=form1.artistName
  else result:='';
end;

function GetSongName:string;
begin
  Form1.Chromium1.Browser.MainFrame.ExecuteJavaScript(
    'if(document.getElementById("player-song-title")){console.log("WM_GETSONGNAME"+document.getElementById("player-song-title").innerText)}','',0);

  if form1.songName<>'' then
    Result:=form1.songName
  else
    Result:='';
end;

function IsPlayControlEnabled:boolean;
begin
  Form1.Chromium1.Browser.MainFrame.ExecuteJavaScript(
    'if(document.querySelectorAll(''[data-id="play-pause"]'')[0]){console.log("WM_ISPLAYCONTROLENABLED"+document.querySelectorAll(''[data-id="play-pause"]'')[0].disabled )}','',0);

  if pos('true', form1.isPlayBackEnabled)>0 then //is it disabled? if true then false
    Result := False
  else
    Result := True;
end;

function GetDuration:string;
begin
  Form1.Chromium1.Browser.MainFrame.ExecuteJavaScript(
  'if(document.getElementById("time_container_duration")){console.log("WM_GETSONGDURATION"+document.getElementById("time_container_duration").innerHTML)}', '', 0);

  if form1.songDuration<>'' then
  result:=form1.songDuration
  else result:='';
end;

function GetPosition:string;
begin
  Form1.Chromium1.Browser.MainFrame.ExecuteJavaScript(
  'if(document.getElementById("time_container_current")){console.log("WM_GETSONGPOSITION"+document.getElementById("time_container_current").innerHTML)}', '', 0);

  if form1.songPosition<>'' then
  result:=form1.songPosition
  else result:='';
end;

function PlayBackStringToSeconds(playbackTime: string):integer;
var
  digito: string;
  minuto,segundo, dospuntos:integer;
begin
  //e.g. 1:11 to 1*60+11
  minuto:=0;
  segundo:=0;

  dospuntos:=pos(':',playbackTime);
  if dospuntos>1 then
  begin
    digito:=copy(playbackTime,1,dospuntos-1);
    try
      minuto:=StrToInt(digito)*60;
    except
    end;
    digito:=copy(playbackTime,dospuntos+1,Length(playbackTime)-dospuntos);
    try
      segundo:=StrToInt(digito);
    except
    end;
  end;

  result:=minuto+segundo;
end;

function MusicIsPlaying:boolean;
begin
  //the following will return "Play" or "Pause"
  Form1.Chromium1.Browser.MainFrame.ExecuteJavaScript(
  'if(document.querySelectorAll(''[data-id="play-pause"]'')[0]){console.log("WM_ISMUSICPLAYING"+document.querySelectorAll(''[data-id="play-pause"]'')[0].title)}', '', 0);

  if form1.isPlaying = 'Play' then
    Result := False
  else
    Result := True;

end;


{LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL LASTFM LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL}
procedure GetToken;
var
  sig : AnsiString;
begin
  sig :='api_key'+API_Key+'method'+'auth.gettoken'+API_secret;
  with THTTPSend.Create do
  begin
    if HTTPMethod('GET','http://ws.audioscrobbler.com/2.0/?method=auth.gettoken&api_key='+API_Key+'&api_sig='+LowerCase(MD5DigestToStr(MD5String(sig)))) then
    try
      Document.Seek(0,0);
      form1.Memo1.Lines.LoadFromStream(Document);
      if pos('status="ok"',form1.memo1.Text)>1 then
    begin //it's been successful the gettoken
      Form1.Token:=copy(Form1.memo1.Text,pos('<token>',form1.memo1.Text)+7,pos('</token>',form1.memo1.Text)-pos('<token>',form1.memo1.Text)-7);
      ShellExecute(GetDesktopWindow,'open', PChar('http://www.last.fm/api/auth/?api_key='+API_key+'&token='+form1.Token), nil, nil, SW_SHOW);
      form1.lblBtnAuthorize.Caption:='Confirm';
    end;
    except
      on e: exception do
      showmessage(e.Message);
    end;
    Free;
  end;

end;

procedure GetSession;
var
  sig : AnsiString;
  ini: TIniFile;
begin
  sig:='api_key'+API_Key+'method'+'auth.getsession'+'token'+form1.Token+API_secret;
  with THTTPSend.Create do
  begin
    if HTTPMethod('GET','http://ws.audioscrobbler.com/2.0/?method=auth.getsession&api_key='+API_Key+'&token='+form1.Token+'&api_sig='+LowerCase(MD5DigestToStr(MD5String(sig)))) then
    try
      Document.Seek(0,0);
      form1.Memo1.Lines.LoadFromStream(Document);
      if pos('status="ok"',form1.Memo1.Text)>1 then
      begin// all went great, it means it returned name and key
        form1.UserName:=copy(form1.memo1.Text,pos('<name>',form1.memo1.Text)+6,pos('</name>',form1.memo1.Text)-pos('<name>',form1.memo1.Text)-6);
        form1.key:=copy(form1.memo1.Text,pos('<key>',form1.memo1.Text)+5,pos('</key>',form1.memo1.Text)-pos('<key>',form1.memo1.Text)-5);
        //let's save to ini file
        ini:=TIniFile.Create(ExtractFilePath(ParamStr(0))+'settings.ini');
        try
          ini.WriteString('LastFM','user',form1.UserName);
          ini.WriteString('LastFM','key',form1.Key);
        finally
          ini.UpdateFile;
          ini.Free;
        end;
        form1.lblUserName.Caption:=form1.UserName;
        form1.lblBtnAuthorize.Caption:='Unauthorize';
        form1.lblBtnAuthorize.Color:=$009DC0E3;
      end;
    except
      on e: exception do
      begin
      showmessage(e.Message);
      form1.lblBtnAuthorize.Caption:='Try Again';
      end;
    end;
    Free;
  end;

end;

function ParamsEncode(const ASrc: Ansistring): AnsiString;
var i: Integer;
begin
  Result := '';
  for i := 1 to Length(ASrc) do
  begin
    if (ASrc[i] in ['&', '*','#','%','<','>',' ','[',']'])
       or (not (ASrc[i] in [#33..#128]))
    then
    begin
      Result := Result + '%' + IntToHex(Ord(ASrc[i]), 2);
    end
    else
    begin
      Result := Result + ASrc[i];
    end;
  end;
end;

procedure updateNowPlaying;
var
  sig : AnsiString;
  s: TSystemTime;
  upArtist, upSong, upTime: string;
begin

  upArtist:=form1.actualArtist;
  upSong:=form1.actualSong;
  upTime:=form1.actualDuration;

  sig:='api_key'+API_Key
      +'artist'+UTF8Encode(upArtist)
      +'duration'+upTime
      +'method'+'track.updatenowplaying'
      +'sk'+form1.Key
      +'track'+UTF8Encode(upSong)
      +API_secret;

  form1.lblUpdated.Caption:='Last Update: '+'artist'+UTF8Encode(upArtist)+'duration'+upTime+'track'+UTF8Encode(upSong);
  with THTTPSend.Create do
  begin
    WriteStrToStream(Document, 'api_key='+API_Key
      +'&artist='+UTF8Encode(upArtist)
      +'&duration='+upTime
      +'&method=track.updatenowplaying'
      +'&sk='+form1.Key
      +'&track='+UTF8Encode(upSong)
      +'&api_sig='+LowerCase(MD5DigestToStr(MD5String(sig))));

    MimeType := 'application/x-www-form-urlencoded';

    if HTTPMethod('POST','http://ws.audioscrobbler.com/2.0/') then
    try
      Document.Seek(0,0);
      form1.Memo1.Lines.LoadFromStream(Document);
      if pos('status="ok"',form1.Memo1.Text)>1 then
      begin
        //tracknowplaying OK :)
        GetSystemTime(s);
        form1.StartTime:=round((EncodeDateTime(s.wYear, s.wMonth, s.wDay, s.wHour, s.wMinute, s.wSecond, s.wMilliSeconds)-UnixDateDelta)*86400);
        //let's copy the NowPlaying Data in order to compare for Scrobbling procedure
        form1.oldArtist:=upArtist; //for scrobbling
        form1.oldSong:=upSong;
        form1.oldDuration:=upTime;
        form1.lblArtist.Caption:=form1.oldArtist;

      end;
    except
      on e: exception do
      showmessage(e.Message);
    end;
    Free;
  end;

end;

procedure Scrobble;
var
  s: TSystemTime;
  sig : AnsiString;
  scrobbleTime: longint;
  minimumTime:longint;
begin
  GetSystemTime(s);
  scrobbleTime:=round((EncodeDateTime(s.wYear, s.wMonth, s.wDay, s.wHour, s.wMinute, s.wSecond, s.wMilliSeconds)-unixstartdate)*86400);

  minimumTime:=(scrobbleTime-form1.StartTime);
  form1.lblPlayBackStatus.Caption:='attempted to scrobble'+IntToStr(minimumTime);

  if (minimumTime<30) {or (form1.oldArtist='')}then exit;

  form1.lblPlayBackStatus.Caption:='send scrobble'+IntToStr(Random(123));

  sig:='api_key'+API_Key+'artist'+UTF8Encode(form1.oldArtist)+'duration'+form1.actualDuration+'method'+'track.scrobble'+'sk'+form1.Key+'timestamp'+IntToStr(form1.StartTime)+'track'+UTF8Encode(form1.actualSong)+API_secret;
  form1.lblScrobbled.Caption:='Last Scrobbled: '+'artist'+UTF8Encode(form1.actualArtist)+'duration'+form1.actualDuration+'track'+UTF8Encode(form1.actualSong);
  with THTTPSend.Create do
  begin
    WriteStrToStream(Document, 'api_key='+API_Key+'&artist='+UTF8Encode(form1.oldArtist)
      +'&duration='+form1.actualDuration
      +'&method=track.scrobble'
      +'&sk='+form1.Key
      +'&timestamp='+IntToStr(form1.StartTime)
      +'&track='+UTF8Encode(form1.actualSong)
      +'&api_sig='+LowerCase(MD5DigestToStr(MD5String(sig))));
    MimeType := 'application/x-www-form-urlencoded';

    if HTTPMethod('POST','http://ws.audioscrobbler.com/2.0/') then
    try
      Document.Seek(0,0);
      form1.Memo1.Lines.LoadFromStream(Document);
      form1.Memo2.Lines:=form1.Memo1.Lines;
      if pos('status="ok"',form1.Memo1.Text)>1 then
      begin
      //tracknowplaying OK :)

      end;
    except
      on e: exception do
      showmessage(e.Message);
    end;
    Free;
  end;
  form1.StartTime:=scrobbleTime;
end;


procedure Deletefiles(APath, AFileSpec: string);
var
  lSearchRec:TSearchRec;
  lFind:integer;
  lPath:string;
  dirname: string;
begin
  lPath := IncludeTrailingPathDelimiter(APath);
  if DirectoryExists(lPath) then
  begin
    lFind := FindFirst(lPath+AFileSpec,faAnyFile,lSearchRec);
    while lFind = 0 do
    begin
      dirname := lSearchRec.Name;
      if (dirName <> '.')
      and (dirName <> '..')
      and (FileExists(lPath+dirName)) then
      begin

        DeleteFile(lPath+dirname);

      end;

      lFind := FindNext(lSearchRec);
    end;
    FindClose(lSearchRec);
  end;
end;

{################################ EL FORMULARIO ###############################}

procedure TForm1.WMWindowPosChanging(var Msg: TWMWindowPosMsg);
var
  rWorkArea: TRect;
  StickAt: Word;
begin
  if (miniplayer) and (Screen.monitorcount=0) then
  begin
    StickAt:=10;

    rWorkArea:= screen.WorkAreaRect;

    with Msg.WindowPos^ do
    begin
      //posible hack pero no sirve flags:=flags or SWP_NOZORDER or SWP_NOMOVE or SWP_NOSIZE or SWP_NOREPOSITION or SWP_NOOWNERZORDER;

      if x<=rWorkArea.Left + StickAt then
      begin
        x:=rWorkArea.Left;
        Docked:=TRUE;
      end;

      if x + cx >= rWorkArea.Right - StickAt then begin
        x := rWorkArea.Right - cx;
        Docked := TRUE;
      end;

      if y <= rWorkArea.Top + StickAt then begin
       y := rWorkArea.Top;
       Docked := TRUE;
      end;

      if y + cy >= rWorkArea.Bottom - StickAt then begin
       y := rWorkArea.Bottom - cy;
       Docked := TRUE;
      end;

      if Docked then begin
       with rWorkArea do begin
        // no moving out of the screen
        if x < Left then x := Left;
        if x + cx > Right then x := Right - cx;
        if y < Top then y := Top;
        if y + cy > Bottom then y := Bottom - cy;
       end; {with rWorkArea}
      end; {if Docked}
    end;

  end;

//BEGIN FRMSHADOW
  if frmShadowEnabled then // to avoid updating when frmShadow hasn't been created
  try
    with Msg.WindowPos^ do
    begin
      frmShadow.Left:=Form1.Left-42+1;
      frmShadow.Top:=Form1.Top-42+1;
    end;
  except

  end;
//END FRMSHADOW

  inherited;
end;

procedure TForm1.PlaybackMessage(var aMsg: TMessage);
var aList: TStrings;
    responseString,authURL: AnsiString;
    Ini: TMemIniFile;
begin
    Case aMsg.WParam of
        2: GroupBox1.Caption := 'Scrobble-Log (Status: Sending data...)';
    end;


end;

procedure TForm1.WMCopyData(var message: TMessage);
var
  Msg: PCopyDataStruct;
  Str: String;
  MsgID: Integer;
begin
  message.Result := 0;
  Msg := PCopyDataStruct(message.LParam);
  if Msg = nil then
    Exit;

  Str := String(UTF8String(PAnsiChar(Msg^.lpData)));
  MsgID := Msg^.dwData;
  case MsgID of
    WM_GETSONGNAME:
    begin
      songName := Str;
    end;
    WM_GETARTISTNAME:
    begin
      artistName := Str;
    end;
    WM_GETCOVERARTURL:
    begin
      coverURL := Str;
    end;
    WM_GETSONGDURATION:
    begin
      songDuration := Str;
    end;
    WM_GETSONGPOSITION:
    begin
      songPosition := Str;
    end;
    WM_ISPLAYCONTROLENABLED:
    begin
      isPlayBackEnabled := Str;
    end;
    WM_ISMUSICPLAYING:
    begin
      isPlaying := Str;
    end;
  end;
  message.Result := 1;
end;

procedure TForm1.WMShowWindow(var msg: TWMShowWindow);
begin
  if not msg.Show then
    msg.Result:=0
  else
  inherited
end;

procedure TForm1.WMMove(var Msg: TWMMove);
begin
  inherited;
//BEGIN FRMSHADOW
  if frmShadowEnabled then // to avoid updating when frmShadow hasn't been created
  try
    begin
      frmShadow.Left:=Form1.Left-42+1;
      frmShadow.Top:=Form1.Top-42+1;
    end;
  except

  end;
//END FRMSHADOW

end;

procedure TForm1.ListCustomCSS(listcss: pComboBox);
var
  lSearchRec: TSearchRec;
  lFind: integer;
  lPath: string;
  dirName : string;
begin
  lPath := ExtractFileDir(ParamStr(0))+'\userstyles\';
  if DirectoryExists(lPath) then
  begin
    lFind := FindFirst(lPath+'*.css',faAnyFile, lSearchRec);
    listcss.Clear;
    while lFind = 0 do
    begin
      dirName:=lSearchRec.Name;
      if (dirName <> '.')
      and (dirName <> '..')
      and (FileExists(lPath+dirName)) then
      listcss.Items.Add(dirName);
      lFind := FindNext(lSearchRec);
    end;
    //update index according to customcss
    cbUserStyles.ItemIndex:= cbUserStyles.Items.IndexOf(CustomCSS);
  end;

end;

procedure TForm1.LoadCustomCSS( browser:pICefBrowser;cssfile: string);
  function HTML2COLOR(ColorFromFile: String; Default: String):TColor;
  var
    HEXpos1: integer;
    HEXStr: String;
    I: Integer;
    rColor : TColor;
  begin

    rColor := StrToInt(Default);

    HEXpos1 := Pos('#',LowerCase(ColorFromFile));
    if (HEXpos1 > 0) and (Length(ColorFromFile)>3 )then
    begin
      HEXStr := '';
      for I := 1 to Length(ColorFromFile) do
      begin
        if (I<7) and (ColorFromFile[HEXpos1+I] in ['A'..'F','a'..'f','0'..'9']  ) then
          HEXStr := HEXStr+Copy(ColorFromFile,HEXpos1+I,1)
        else
        Break;
      end;

      if Length(HEXStr)=6 then
      begin
        HEXStr := '$00'+copy(HEXStr,5,2)+copy(HEXStr, 3,2)+copy(HEXStr,1,2);
        rColor := StrToInt(HEXStr);
      end
      else if Length(HEXStr)=3 then
      begin
        HEXStr := '$00'+copy(HEXStr,3,1)+copy(HEXStr,3,1)+copy(HEXStr, 2,1)+copy(HEXStr, 2,1)+copy(HEXStr,1,1)+copy(HEXStr, 1,1);
        rColor := StrToInt(HEXStr);
      end
      else
      begin
        //not a valid color, use default color
        imgTopBar.Visible := True;
      end;

    end;
      Result := rColor;
  end;
var
  UserStyle: string;
  CustomFile: TextFile;
  ColorFromFile: string;
begin
  if FileExists(cssfile) then
  begin
//    Chromium1.Options.AuthorAndUserStylesDisabled:=True;
    UserStyle:=TFile.ReadAllText(cssfile);
// avoid injections
    UserStyle:=StringReplace(UserStyle,'"','''',[rfReplaceAll]);
//    UserStyle:=StringReplace(UserStyle,'''','''''',[rfReplaceAll]); //esto no es necesario aquí
    UserStyle:=StringReplace(UserStyle,#13,' ',[rfReplaceAll]);
    UserStyle:=StringReplace(UserStyle,#10,'',[rfReplaceAll]);
    browser.Mainframe.ExecuteJavaScript('(function(){ '+
    'var style=document.getElementById(''gmusic_custom_css'');'+
    'if(!style){ style = document.createElement(''STYLE'');'+
    'style.type=''text/css'';'+
    'style.id=''gmusic_custom_css''; '+
//    'style.innerText = '''+UserStyle+''';'+
    'style.innerText = "'+UserStyle+'";'+ //to avoid injections
    'document.getElementsByTagName(''HEAD'')[0].appendChild(style);'+
    '} } )()','',0);

    //Custom colors for our window
    AssignFile(CustomFile,cssfile);
    try
      Reset(CustomFile);
      imgTopBar.visible := False;
      Readln(CustomFile);
      Readln(CustomFile);
      Readln(CustomFile);
      Readln(CustomFile, ColorFromFile);
      pnlTitleBar.color:= HTML2COLOR(ColorFromFile,'$004C4C4C');
      Readln(CustomFile, ColorFromFile);
      lblCaption.font.color := HTML2COLOR(ColorFromFile, '$00FFFFFF');
      Readln(CustomFile, ColorFromFile);
      Shape2.Brush.Color := HTML2COLOR(ColorFromFile,'$001E68D7');
      Readln(CustomFile, ColorFromFile);
      Shape1.Brush.Color := HTML2COLOR(ColorFromFile,'$00888888');
      Readln(CustomFile, ColorFromFile);
      lblSettings.Font.Color := HTML2COLOR(ColorFromFile,'$00888888');

    finally
      CloseFile(CustomFile);
    end;

  end;
end;

procedure TForm1.UnLoadCustomCSS(browser: pICefBrowser);
begin
  //
  browser.MainFrame.ExecuteJavaScript('(function(){'+
  'var style=document.getElementById(''gmusic_custom_css'');'+
  'if(style){style.parentNode.removeChild(style);}'+
  '})();','',0);

  // restore default gui colors
  imgTopBar.visible := True;
  pnlTitleBar.color := $004C4C4C;
  Shape2.Brush.Color := $001E68D7;
  Shape1.Brush.Color := clGray;
  lblCaption.font.color := clWhite;
  lblSettings.Font.Color := clGray
end;

//<!--BEGIN FRMSHADOW-->
procedure TForm1.OnFocus(Sender: TObject);
begin
  if (WindowState = wsNormal)then
  begin
    frmShadow.Shadow:=MACOSX;
    ShowWindow(frmShadow.Handle,SW_SHOWNA);
  end;
end;

procedure TForm1.OnLostFocus(Sender: TObject);
begin
  //
  //to hide shadow if application loses focus
  //  ShowWindow(frmShadow.Handle,SW_HIDE);
  frmShadow.Shadow:=0;
end;
//<!--END FRMSHADOW-->

function TForm1.IsMain(const b: ICefBrowser; const f: ICefFrame): Boolean;
begin
  Result := (b <> nil) and (b.Identifier = Chromium1.BrowserId) and ((f = nil) or (f.IsMain));
end;

procedure TForm1.WndProc(var Message: TMessage);
begin
  if Message.Msg = WM_NCCALCSIZE then
  begin
    Message.Msg:= WM_NULL;
  end;

  if Message.Msg = WM_TASKBARBUTTONCREATED then
  begin
    CoCreateInstance(CLSID_TaskbarList, nil, CLSCTX_INPROC_SERVER, IID_ITaskbarList3, FTaskBar);
    FTaskBar.HrInit;
    FTaskBar.SetProgressState(Handle, TBPF_NORMAL);

    FTaskBar.SetOverlayIcon(Handle, FNormalIcon, 'In progress');

    FTaskBar.ThumbBarSetImageList(Handle, ImageList1.Handle);

    FButtons[0].iId := 40001;
    FButtons[0].dwFlags := THBF_ENABLED;
    FButtons[0].iBitmap := 0;
    StringToWideChar('Previous', FButtons[0].szTip, 260);
    FButtons[0].dwMask := THB_BITMAP or THB_FLAGS or THB_TOOLTIP;

    FButtons[1].iId := 40002;
    FButtons[1].dwFlags := THBF_ENABLED;
    FButtons[1].iBitmap := 1;
    StringToWideChar('Pause', FButtons[1].szTip, 260);
    FButtons[1].dwMask := THB_BITMAP or THB_FLAGS or THB_TOOLTIP;

    FButtons[2].iId := 40003;
    FButtons[2].dwFlags := THBF_ENABLED;
    FButtons[2].iBitmap := 2;
    StringToWideChar('Play', FButtons[2].szTip, 260);
    FButtons[2].dwMask := THB_BITMAP or THB_FLAGS or THB_TOOLTIP;

    FButtons[3].iId := 40004;
    FButtons[3].dwFlags := THBF_ENABLED;
    FButtons[3].iBitmap := 3;
    StringToWideChar('Next', FButtons[3].szTip, 260);
    FButtons[3].dwMask := THB_BITMAP or THB_FLAGS or THB_TOOLTIP;

    FTaskBar.ThumbBarAddButtons(Handle, 4, @FButtons[0]);
    FTaskBar.SetThumbnailTooltip(Handle, 'GMusic');
    tmrWin7TaskBar.Enabled:=true;
  end;
  //Taskbar thumbnail buttons
  if Message.Msg = WM_COMMAND then
  begin
    if Message.WParamLo = 40001 then
    begin
      tmrWin7TaskBar.Enabled := True;
      FTaskBar.SetProgressState(Handle, TBPF_NORMAL);
      GRewind;
      FTick := 0;
    end;
    if Message.WParamLo = 40002 then
    begin
      if MusicIsPlaying then GPause; //it pauses music
      tmrWin7TaskBar.Enabled := False;
      FTaskBar.SetProgressState(Handle, TBPF_PAUSED);
      FTaskBar.SetOverlayIcon(Handle, FNormalIcon, 'In progress');
      FButtons[2].dwFlags := THBF_ENABLED;
      FTaskBar.ThumbBarUpdateButtons(Handle, 3, @FButtons[0])
    end;
    if Message.WParamLo = 40003 then
    begin
      if not MusicIsPlaying then GPlay; //plays music
      tmrWin7TaskBar.Enabled := true;
      FTaskBar.SetProgressState(Handle, TBPF_NORMAL);
      FTaskBar.SetOverlayIcon(Handle, FPauseIcon, 'Paused');
      FButtons[1].dwFlags := THBF_ENABLED;
      FTaskBar.ThumbBarUpdateButtons(Handle, 3, @FButtons[0])
    end;
    if Message.WParamLo = 40004 then
    begin
      GForward;
    end;
  end;
  inherited WndProc(Message);
end;

//function to find which monitor is located the app
function WhichMonitor(horizCenter,vertCenter: integer):integer;
var
  I: Integer;
begin
  result:=-1;
  for I := 0 to Screen.MonitorCount-1 do
  begin
    if(screen.Monitors[I].Left<horizCenter)
    and(screen.Monitors[I].Left+Screen.Monitors[I].Width>horizCenter)
    and(Screen.Monitors[I].Top<vertCenter)
    and(Screen.Monitors[I].Top+Screen.Monitors[I].Height>vertCenter)
    then
    result:=I;
  end;

end;

procedure TForm1.FormResize(Sender: TObject);
var
png: TPngImage;
begin
  //para corregir el tamaño
  if (WindowState = wsMaximized)
  ///and (self.Left>Screen.WorkAreaLeft-20) mal control para la ventana
  then
  begin
    //BEGIN FRMSHADOW
    ShowWindow(frmShadow.Handle,SW_HIDE);
    //END FRMSHADOW

    if Screen.MonitorCount>1 then
    begin
      with Screen.Monitors[WhichMonitor(left+width div 2,top+Height div 2)].WorkareaRect do
        Form1.SetBounds(Left, Top, Right - Left-0, Bottom - Top-1);
    end
    else
    with Screen.WorkAreaRect do
        Form1.SetBounds(Left, Top, Right - Left-0, Bottom - Top-1);
  end
  else if WindowState = wsNormal then
  begin
    //BEGIN FRMSHADOW
    try
      //BEGIN FRMSHADOW
        if not IsWindowVisible(frmShadow.Handle) then
           ShowWindow(frmShadow.Handle,SW_SHOWNA);
      //END FRMSHADOW
      frmShadow.ClientWidth:=ClientWidth+84-2;
      frmShadow.ClientHeight:=ClientHeight+84-2;
    except

    end;
    //END FRMSHADOW
  end
  else if WindowState = wsMinimized then
  begin
    ShowWindow(frmShadow.Handle,SW_HIDE);
  end;

  //update restore button
  png:=TPngImage.Create;
  try
  if WindowState=wsMaximized then
    png.LoadFromResourceName(HInstance, 'PNGRESTORE')
  else
    png.LoadFromResourceName(HInstance, 'PNGMAX');
    imgResize.Picture.Graphic:=png;
  finally
    png.Free;
  end;
  //settings panel
  pnlSettings.Left:=self.Width div 2 - pnlSettings.Width div 2;
  pnlSettings.Top:=self.Height div 2 - pnlSettings.Height div 2;

end;


procedure TForm1.CreateParams(var Params: TCreateParams);
begin
  inherited;

  if FindWindow('GMusicWndClass', nil) <> 0 then
    Params.WinClassName := 'GMusicWndClass_Child'
  else
    Params.WinClassName:= 'GMusicWndClass';

  Params.Style:=params.Style or WS_OVERLAPPEDWINDOW;
end;

//****************************************************************************//

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//FRMSHADOW
frmShadowEnabled:=false;
//FRMSHADOW
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  Ini: TIniFile;
  s: TSystemTime;
begin
  SetPriorityClass(GetCurrentProcess, $4000);//our app process below normal
  FLoading := False;
// to flush cache, but it also clears out our sessions
//    Deletefiles(ExtractFilePath(ParamStr(0))+'cache\','f_*');

  //FRMSHADOW
  Application.OnActivate:=OnFocus;
  Application.OnDeactivate:=OnLostFocus;
  //FRMSHADOW

  self.Caption:='GMusic';

  //resize correctly on netbooks
  //no necessary this if WhichMonitor(left+width div 2,top + height div 2) then
  if Screen.Height<Height then
  begin
    Height:=Screen.WorkAreaHeight-20;
    Position:=poScreenCenter;
  end;
  if Screen.Width<Width then
  begin
    Width:=Screen.WorkAreaWidth-20;
    Position:=poScreenCenter;
  end;

  self.Color:=$9d9d9d;

  pnlSplashScreen.Align:=alClient;
  //Constraints.MinHeight:=480;
  //Constraints.MinWidth:=640;
  Chromium1.Align:=alClient;


  Chromium1.Load('https://play.google.com/music/listen');


  //botones win7 taskbar
  if CheckWin32Version(6,1) then
  begin
     isWindows7:=true;

     SetCurrentProcessExplicitAppUserModelID('GoogleMusicTaskBar');
  end
  else
  begin
    if CheckWin32Version(6) then
      ShowMessage('Windows Vista is not supported')
    else
      ShowMessage('Your version of Windows is too old...');
    Application.Terminate;
  end;


  ini:=TIniFile.Create(ExtractFilePath(ParamStr(0))+'settings.ini');
  try
      UserName:=ini.ReadString('LastFM','user','');
      lblUserName.Caption:='LastFM User: '+UserName;
      Key:=ini.ReadString('LastFM','key','');
      CheckBox1.Checked:=ini.ReadBool('LastFM','scrobble',false);
      CheckBox2.Checked:=ini.ReadBool('System','forcefreeRAM',false);

      //read mini player position
      mLeft:=ini.ReadInteger('MiniPlayer','Left',0);
      mTop:=ini.ReadInteger('MiniPlayer','Top',0);

      chkMiniOnTop.Checked:=ini.ReadBool('MiniPlayer','OnTop',true);
      //gmusic
      chkNotify.Checked:=ini.ReadBool('GMusic','Notify',false);
      SpinEdit1.Value:=ini.ReadInteger('GMusic','NotifyInterval',2);

      // custom css
      chkCustomCSS.Checked:=ini.ReadBool('GMusic','UserStyleSheet',false);
        cbUserStyles.Enabled := chkCustomCSS.Checked;
      CustomCSS:=ini.ReadString('UserStyle','CSSFile','');
  finally
      ini.Free;
  end;

  if Key<>'' then    begin
      form1.lblBtnAuthorize.Caption:='Unauthorize';
      form1.lblBtnAuthorize.Color:=$009DC0E3;
  end;
  PlayerStatus := ps_Stopped;

  //default values for global variables
  actualcoverURL:='';
  coverURL:='';
  actualSong:='';
  songName:='';
  actualArtist:='';
  artistName:='';
  oldArtist:='';
  oldSong:='';
  oldDuration:='';
  actualDuration:='';
  songDuration:='';
  songPosition:='';
  isPlaying:='' ; //false;
  prevPlaybackState:=False; //for miniplayer update buttons
  miniplayer:=false;
  songCompleted:=true;

  GetSystemTime(s);
  form1.StartTime:=round((EncodeDateTime(s.wYear, s.wMonth, s.wDay, s.wHour, s.wMinute, s.wSecond, s.wMilliSeconds)-UnixDateDelta)*86400);

//enable custom user styles but not convenient to make changes at runtime, i.e. swtiching among them
//    Chromium1.Options.UserStyleSheetEnabled:=True;
//    Chromium1.UserStyleSheetLocation:= ExtractFilePath(ParamStr(0))+'userstyles\googleMusicForPlay.css';
//    Chromium1.UserStyleSheetLocation:= ExtractFilePath(ParamStr(0))+'userstyles';

// make pnlresizeborder transparent
  pnlResizeBorder.Brush.Style:=bsClear;
  pnlResizeBorder.BorderStyle:=bsNone;

// Animated loading
//  Shape1.Top:=imgTopBar.Height-5;
//  Shape2.Top:=imgTopBar.Height-5;

//snarl support - registering our app
//  snarl_register('application/x-vnd-codigobit.gmusic','Google Music Desktop Player','');
end;


procedure TForm1.FormDestroy(Sender: TObject);
var
ini:TIniFile;
begin
    Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'settings.ini');
    try
        ini.WriteInteger('MiniPlayer','Left',mLeft);
        ini.WriteInteger('MiniPlayer','Top',mtop);
        ini.WriteInteger('GMusic','NotifyInterval',SpinEdit1.Value);
        ini.WriteBool('GMusic','UserStyleSheet',chkCustomCSS.Checked);
        ini.WriteString('UserStyle','CSSFile',CustomCSS);
    finally
        Ini.UpdateFile;
        Ini.Free;
    end;
    Chromium1.Browser.StopLoad;

    // to flush cache contens, but session also is lost
//    Deletefiles(ExtractFilePath(ParamStr(0))+'cache\','f_*');
//    Deletefiles(ExtractFilePath(ParamStr(0))+'cache\','data_*');
//    Deletefiles(ExtractFilePath(ParamStr(0))+'cache\','index');
//  snarl_unregister('application/x-vnd-codigobit.gmusic');
end;

//public functions ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure Tform1.GShowModal;
begin
  //userscript added GMusicAppModalBG
  Chromium1.Browser.MainFrame.ExecuteJavaScript('var modalbg=document.getElementById("GMxBG");if(modalbg){modalbg.style.display=""}','',0);
end;

procedure TForm1.GHideModal;
begin
  //userscript added GMusicAppModalBG
  Chromium1.Browser.MainFrame.ExecuteJavaScript('var modalbg=document.getElementById("GMxBG");if(modalbg){modalbg.style.display="none"}','',0);
end;

procedure TForm1.GPlay;
begin
  Chromium1.Browser.MainFrame.ExecuteJavaScript('if(document.querySelectorAll(''[data-id="play-pause"]'')[0].title ==''Play''){document.querySelectorAll(''[data-id="play-pause"]'')[0].click();}','',0);
end;

procedure TForm1.GPause;
begin
  Chromium1.Browser.MainFrame.ExecuteJavaScript('if(document.querySelectorAll(''[data-id="play-pause"]'')[0].title ==''Pause''){document.querySelectorAll(''[data-id="play-pause"]'')[0].click();}','',0);
end;

procedure TForm1.GRewind;
begin
if MusicIsPlaying then
  Chromium1.Browser.MainFrame.ExecuteJavaScript('if(!document.querySelectorAll(''[data-id="rewind"]'')[0].disabled){document.querySelectorAll(''[data-id="rewind"]'')[0].click();}','',0);
end;

procedure TForm1.GForward;
begin
if MusicIsPlaying then
  Chromium1.Browser.MainFrame.ExecuteJavaScript('if(!document.querySelectorAll(''[data-id="forward"]'')[0].disabled){document.querySelectorAll(''[data-id="forward"]'')[0].click();}','',0);
end;

procedure TForm1.FormShow(Sender: TObject);
begin
//FRMSHADOW
  FormResize(self);
  ShowWindow(frmShadow.Handle,SW_SHOWNA);
  frmShadowEnabled :=true;
  frmShadow.Shadow:=MACOSX;
//FRMSHADOW
end;

procedure TForm1.HideMe1Click(Sender: TObject);
begin
self.Hide;
end;

{PayPal donations}
procedure TForm1.Image3Click(Sender: TObject);
var
durl : AnsiString;
begin
  //any amount by default
    durl := 'DGTZ4YZSMWKLJ';

  if ComboBox1.ItemIndex = 0 then
    //3 dollars
    durl := '6S34CNXAKM69G'
  else if ComboBox1.ItemIndex = 1 then
    //5 dollars
    durl := 'Q73PT6CD3APWQ'
  else if ComboBox1.ItemIndex = 2 then
    //10 dollars
    durl := '8FNYMAD2HPAA6'
  else if ComboBox1.ItemIndex = 3 then
    //any amount
    durl := 'DGTZ4YZSMWKLJ';

    ShellExecuteA(Handle, 'open', PAnsiChar('https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id='+durl), nil, nil, SW_SHOW);
end;

procedure TForm1.imgPlayClick(Sender: TObject);
begin
  if MusicIsPlaying then
    GPause
  else
    GPlay;
end;

procedure TForm1.imgPlayMouseEnter(Sender: TObject);
var
png: TPngImage;
begin
  png:=TPngImage.Create;
  try
  if MusicIsPlaying then
    png.LoadFromResourceName(HInstance, 'PNGMINIPAUSEHOVER')
  else
    png.LoadFromResourceName(HInstance, 'PNGMINIPLAYHOVER');
    imgPlay.Picture.Graphic:=png;
  finally
    png.Free;
  end;
end;

procedure TForm1.imgPlayMouseLeave(Sender: TObject);
var
png: TPngImage;
begin
  png:=TPngImage.Create;
  try
  if MusicIsPlaying then
    png.LoadFromResourceName(HInstance, 'PNGMINIPAUSE')
  else
    png.LoadFromResourceName(HInstance, 'PNGMINIPLAY');
    imgPlay.Picture.Graphic:=png;
  finally
    png.Free;
  end;
end;

procedure TForm1.imgPrevClick(Sender: TObject);
begin
GRewind;
end;

procedure TForm1.imgPrevMouseEnter(Sender: TObject);
var
png: TPngImage;
begin
  png:=TPngImage.Create;
  try
    png.LoadFromResourceName(HInstance, 'PNGMINIPREVHOVER');
    imgPrev.Picture.Graphic:=png;
  finally
    png.Free;
  end;
end;

procedure TForm1.imgPrevMouseLeave(Sender: TObject);
var
png: TPngImage;
begin
  png:=TPngImage.Create;
  try
    png.LoadFromResourceName(HInstance, 'PNGMINIPREV');
    imgPrev.Picture.Graphic:=png;
  finally
    png.Free;
  end;
end;

procedure TForm1.imgMiniMouseEnter(Sender: TObject);
var
png: TPngImage;
begin
  png:=TPngImage.Create;
  try
    png.LoadFromResourceName(HInstance, 'PNGMINIHOVER');
    imgMini.Picture.Graphic:=png;
  finally
    png.Free;
  end;
end;

procedure TForm1.imgMiniMouseLeave(Sender: TObject);
var
png: TPngImage;
begin
  png:=TPngImage.Create;
  try
    png.LoadFromResourceName(HInstance, 'PNGMINI');
    imgMini.Picture.Graphic:=png;
  finally
    png.Free;
  end;
end;

procedure TForm1.imgNextClick(Sender: TObject);
begin
GForward;
end;

procedure TForm1.imgNextMouseEnter(Sender: TObject);
var
png: TPngImage;
begin
  png:=TPngImage.Create;
  try
    png.LoadFromResourceName(HInstance, 'PNGMININEXTHOVER');
    imgNext.Picture.Graphic:=png;
  finally
    png.Free;
  end;
end;

procedure TForm1.imgNextMouseLeave(Sender: TObject);
var
png: TPngImage;
begin
  png:=TPngImage.Create;
  try
    png.LoadFromResourceName(HInstance, 'PNGMININEXT');
    imgNext.Picture.Graphic:=png;
  finally
    png.Free;
  end;
end;

procedure TForm1.imgClose2Click(Sender: TObject);
begin
application.Terminate;
end;

procedure TForm1.imgClose2MouseEnter(Sender: TObject);
var
png: TPngImage;
begin
  png:=TPngImage.Create;
  try
    png.LoadFromResourceName(HInstance, 'PNGCLOSEHOVER');
    imgClose2.Picture.Graphic:=png;
  finally
    png.Free;
  end;
end;

procedure TForm1.imgClose2MouseLeave(Sender: TObject);
var
png: TPngImage;
begin
  png:=TPngImage.Create;
  try
    png.LoadFromResourceName(HInstance, 'PNGCLOSE');
    imgClose2.Picture.Graphic:=png;
  finally
    png.Free;
  end;
end;

procedure TForm1.imgCloseClick(Sender: TObject);
begin
application.Terminate;
end;

procedure TForm1.imgCloseMouseEnter(Sender: TObject);
var
png:TPngImage;
begin
  png:=TPngImage.Create;
  try
    png.LoadFromResourceName(HInstance, 'PNGCLOSEHOVER');
    imgClose.Picture.Graphic:=png;
  finally
    png.Free;
  end;
end;

procedure TForm1.imgCloseMouseLeave(Sender: TObject);
var
png: TPngImage;
begin
  png:=TPngImage.Create;
  try
    png.LoadFromResourceName(HInstance, 'PNGCLOSE');
    imgClose.Picture.Graphic:=png;
  finally
    png.Free;
  end;
end;

procedure TForm1.imgMini2Click(Sender: TObject);
begin
imgMiniClick(imgMini2);
end;

procedure TForm1.imgMini2MouseEnter(Sender: TObject);
var
png: TPngImage;
begin
  png:=TPngImage.Create;
  try
    png.LoadFromResourceName(HInstance, 'PNGMINIHOVER');
    imgMini2.Picture.Graphic:=png;
  finally
    png.Free;
  end;
end;

procedure TForm1.imgMini2MouseLeave(Sender: TObject);
var
png: TPngImage;
begin
  png:=TPngImage.Create;
  try
    png.LoadFromResourceName(HInstance, 'PNGMINI');
    imgMini2.Picture.Graphic:=png;
  finally
    png.Free;
  end;
end;

procedure TForm1.imgMiniClick(Sender: TObject);
begin
  if MiniPlayer then
  begin
    mLeft:=self.Left;
    mTop:=self.Top;
    self.Constraints.MinWidth:=400;
    self.Width:=nWidth;
    self.Height:=nHeight;
    self.Left:=nLeft;
    self.Top:=nTop;

    MiniPlayer:=false;
    pnlMiniPlayer.Visible:=false;
    //to change window type
    ShowWindow(Self.Handle, SW_HIDE) ;

    SetWindowLong(Self.Handle, GWL_STYLE, getWindowLong(Self.Handle, GWL_STYLE) or WS_OVERLAPPEDWINDOW);
    ShowWindow(Self.Handle, SW_SHOW) ;
    //to avoid minimize
    SetWindowPos(Self.Handle,HWND_NOTOPMOST,Left,Top,Width, Height,SWP_NOMOVE or SWP_NOACTIVATE or SWP_NOSIZE);

    self.DoubleBuffered:=false;
  end
  else
  begin
    if WindowState=wsMaximized then
      imgResizeClick(imgResize);
    //activar miniplayer
    pnlMiniPlayer.Left:=0;
    pnlMiniPlayer.Top:=0;
    pnlMiniPlayer.Visible:=true;
    nWidth:=self.Width;
    nHeight:=self.Height;
    nLeft:=self.Left;
    nTop:=self.Top;
    self.Constraints.MinWidth:=130;
    self.Width:=130;
    self.Height:=130;

    self.Left:=mLeft;
    self.Top:=mTop;

    //avoid using a disconnected second monitor
    if (Screen.MonitorCount>1)and(WhichMonitor(mLeft + 65,mTop + 65)=-1) then
    begin
      self.Left:=Screen.Monitors[0].Width div 2 -65;
      self.Top:=Screen.Monitors[0].Height div 2 - 65;
    end;

    MiniPlayer:=true;
    //truco para cambiar de tipo de ventana
    ShowWindow(Self.Handle, SW_HIDE) ;

    SetWindowLong(Self.Handle, GWL_STYLE, getWindowLong(Self.Handle, GWL_STYLE) and not WS_OVERLAPPEDWINDOW);
    ShowWindow(Self.Handle, SW_SHOW) ;
    //para no minimizar
    if chkMiniOnTop.Checked then
    SetWindowPos(Self.Handle,HWND_TOPMOST,Left,Top,Width, Height,SWP_NOSIZE)
    else
    SetWindowPos(Self.Handle,HWND_NOTOPMOST,Left,Top,Width, Height,SWP_NOSIZE);

    self.DoubleBuffered:=true;
    if pnlSettings.Visible then
      lblSettingsClick(lblSettings);
  end;
end;

procedure TForm1.imgMiniCoverMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 ReleaseCapture;
  Perform(WM_SYSCOMMAND,$F012,0);

end;

procedure TForm1.imgMinimize2Click(Sender: TObject);
begin
imgMinimizeClick(imgMinimize2);
end;

procedure TForm1.imgMinimize2MouseEnter(Sender: TObject);
var
png: TPngImage;
begin
  png:=TPngImage.Create;
  try
    png.LoadFromResourceName(HInstance, 'PNGMINHOVER');
    imgMinimize2.Picture.Graphic:=png;
  finally
    png.Free;
  end;
end;

procedure TForm1.imgMinimize2MouseLeave(Sender: TObject);
var
png: TPngImage;
begin
  png:=TPngImage.Create;
  try
    png.LoadFromResourceName(HInstance, 'PNGMIN');
    imgMinimize2.Picture.Graphic:=png;
  finally
    png.Free;
  end;
end;

procedure TForm1.imgMinimizeClick(Sender: TObject);
begin
  form1.Perform(WM_SYSCOMMAND,SC_MINIMIZE,0)
end;

procedure TForm1.imgMinimizeMouseEnter(Sender: TObject);
var
png: TPngImage;
begin
  png:=TPngImage.Create;
  try
    png.LoadFromResourceName(HInstance, 'PNGMINHOVER');
    imgMinimize.Picture.Graphic:=png;
  finally
    png.Free;
  end;
end;

procedure TForm1.imgMinimizeMouseLeave(Sender: TObject);
var
png: TPngImage;
begin
  png:=TPngImage.Create;
  try
    png.LoadFromResourceName(HInstance, 'PNGMIN');
    imgMinimize.Picture.Graphic:=png;
  finally
    png.Free;
  end;
end;

procedure TForm1.imgResizeClick(Sender: TObject);
begin
  ReleaseCapture;
  if Form1.WindowState = wsMaximized then
  form1.Perform(WM_SYSCOMMAND,SC_RESTORE,0)
  else
  form1.Perform(WM_SYSCOMMAND,SC_MAXIMIZE,0);

end;

procedure TForm1.imgResizeMouseEnter(Sender: TObject);
var
png: TPngImage;
begin
  png:=TPngImage.Create;
  try
  if WindowState=wsMaximized then
    png.LoadFromResourceName(HInstance, 'PNGRESTOREHOVER')
  else
    png.LoadFromResourceName(HInstance, 'PNGMAXHOVER');
    imgResize.Picture.Graphic:=png;
  finally
    png.Free;
  end;
end;

procedure TForm1.imgResizeMouseLeave(Sender: TObject);
var
png: TPngImage;
begin
  png:=TPngImage.Create;
  try
  if WindowState=wsMaximized then
    png.LoadFromResourceName(HInstance, 'PNGRESTORE')
  else
    png.LoadFromResourceName(HInstance, 'PNGMAX');
    imgResize.Picture.Graphic:=png;
  finally
    png.Free;
  end;
end;

procedure TForm1.imgResizerMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
ReleaseCapture;
if form1.WindowState=wsNormal then
begin
  Perform(WM_SYSCOMMAND,$F008,0);
end;
{sc_DragMove = $f012;
sc_Leftsize = $f001;
sc_Rightsize = $f002;
sc_Upsize = $f003;
sc_UpLeftsize = $f004;
sc_UpRightsize = $f005;
sc_Dnsize = $f006;
sc_DnLeftsize = $f007;
sc_DnRightsize = $f008;}

end;

procedure TForm1.imgVolumeMouseEnter(Sender: TObject);
var
png: TPngImage;
begin
  png:=TPngImage.Create;
  try
    png.LoadFromResourceName(HInstance, 'PNGMINIVOLUMEHOVER');
    imgVolume.Picture.Graphic:=png;
  finally
    png.Free;
  end;
end;

procedure TForm1.imgVolumeMouseLeave(Sender: TObject);
var
png: TPngImage;
begin
  png:=TPngImage.Create;
  try
    png.LoadFromResourceName(HInstance, 'PNGMINIVOLUME');
    imgVolume.Picture.Graphic:=png;
  finally
    png.Free;
  end;
end;

procedure TForm1.Label10Click(Sender: TObject);
begin
  lblSettingsClick(lblSettings);
  Chromium1.Load('https://www.google.com/accounts/Logout?service=sj&continue=http://music.google.com/music/listen');
end;

procedure TForm1.lblSearchClick(Sender: TObject);
begin

  Chromium1.Browser.MainFrame.ExecuteJavaScript(
  'cef.test.test_object().GetMessage();',
  '',0);

end;

procedure TForm1.lblLabsClick(Sender: TObject);
begin
  Chromium1.Browser.MainFrame.ExecuteJavaScript('SJBpost(''playlistSelected'', null, {id: ''labs''});','',0);
end;

procedure TForm1.lblTrashClick(Sender: TObject);
begin
  Chromium1.Browser.MainFrame.ExecuteJavaScript('SJBpost(''playlistSelected'', null, {id: ''auto-playlist-trash''});','',0);
end;

procedure TForm1.Label3Click(Sender: TObject);
begin
  ShellExecuteA(Handle, 'open', PAnsiChar('http://apps.codigobit.info/gmusic'), nil, nil, SW_SHOW);
end;

procedure TForm1.Label5Click(Sender: TObject);
begin
  ShellExecuteA(Handle, 'open', PAnsiChar('http://vhanla.deviantart.com'), nil, nil, SW_SHOW);
end;

procedure TForm1.Label6Click(Sender: TObject);
begin
  lblSettingsClick(lblSettings);
end;

procedure TForm1.lblBtnAuthorizeClick(Sender: TObject);
var
ini:TIniFile;
begin
if (lblbtnAuthorize.Caption='Authorize')or(lblbtnAuthorize.Caption='Try Again') then
begin
  lblbtnAuthorize.Caption:='Please wait...';
  GetToken;
  lblUserName.Caption:='No user';
end
else if lblbtnAuthorize.Caption='Confirm' then
begin
  lblbtnAuthorize.Caption:='Please wait...';
  GetSession;
end
else if lblBtnAuthorize.Caption='Unauthorize' then
begin
  lblBtnAuthorize.Caption:='Authorize';
  lblBtnAuthorize.Color:=$00C8B755;
  UserName:='';
  key:='';
  token:='';
  ini:=TIniFile.Create(ExtractFilePath(ParamStr(0))+'settings.ini');
      try
        ini.WriteString('LastFM','user',form1.UserName);
        ini.WriteString('LastFM','key',form1.Key);
      finally
        ini.UpdateFile;
        ini.Free;
      end;
  lblUserName.Caption:='';
end
else
  lblBtnAuthorize.Caption:='Try Again';
end;

procedure TForm1.lblCaptionDblClick(Sender: TObject);
begin
  ReleaseCapture;
  if Form1.WindowState = wsMaximized then
  form1.Perform(WM_SYSCOMMAND,SC_RESTORE,0)
  else
  form1.Perform(WM_SYSCOMMAND,SC_MAXIMIZE,0);

end;

procedure TForm1.lblCaptionMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  //BEGIN FRMSHADOW
  frmShadow.Shadow:=0;
  //END FRMSHADOW
  Perform(WM_SYSCOMMAND,$F012,0);
  //BEGIN FRMSHADOW
  frmShadow.Shadow:=MACOSX;
  //END FRMSHADOW
end;

procedure TForm1.lblSettingsClick(Sender: TObject);
begin
  if not pnlSettings.Visible then
  begin
    GShowModal;
    pnlSettings.Left:=self.Width div 2 - pnlSettings.Width div 2;
    pnlSettings.Top:=self.Height div 2 - pnlSettings.Height div 2;
    pnlSettings.Visible:=true;
    //list custom CSSs
    ListCustomCSS(@cbUserStyles);
  end
  else
  begin
    GHideModal;
    pnlSettings.Visible:=false;
  end;
end;

procedure TForm1.lblSettingsMouseEnter(Sender: TObject);
begin
  TLabel(Sender).Font.Color:=clwhite;
end;

procedure TForm1.lblSettingsMouseLeave(Sender: TObject);
begin
  TLabel(Sender).Font.Color:=clSilver;
end;

procedure TForm1.Picture1Click(Sender: TObject);
begin
   GetCoverArt;
end;


procedure TForm1.Song1Click(Sender: TObject);
begin
{$IFDEF DELPHI14_UP}
Chromium1.Browser.MainFrame.VisitDomProc(
procedure (const doc: ICefDomDocument)
        var el: ICefDomNode;
        begin
          el := doc.GetElementById('playerSongTitle');
          if Assigned(el) then begin
            el:=el.FirstChild;
            if Assigned(el) then
            showmessage(el.ElementInnerText);
          end;
        end);
{$ENDIF}
end;

procedure TrimAppMemorySize;
var
  MainHandle : THandle;
begin
  try
    MainHandle := OpenProcess(PROCESS_ALL_ACCESS, false, GetCurrentProcessID) ;
    SetProcessWorkingSetSize(MainHandle, $FFFFFFFF, $FFFFFFFF) ;
    CloseHandle(MainHandle) ;
    //Log('Trimmed Memory Successfull!');
  except
    //Log('Failed to trim Memory!');
  end;
  Application.ProcessMessages;
end;

procedure TForm1.tmrUpdatePlayerStatusTimer(Sender: TObject);
var
tempCoverArtURL, tempSongName, tempArtistName: string;
begin
  //debugging only      lblcaption.Caption:=inttostr(Random(100))+ ' - '+GetPosition;
  tempCoverArtURL:=GetCoverArtURL;
  if actualcoverURL<>tempCoverArtURL then
  begin
    actualcoverURL:=tempCoverArtURL;
    GetCoverArt;
  end;

  tempArtistName:=GetArtistName;
  if actualArtist<>tempArtistName then
  begin
    actualArtist:=tempArtistName;
    frmGadget.lblArtist.Caption:=form1.actualArtist;
  end;

  tempSongName:=GetSongName;
  if actualSong<>tempSongName then
  begin
    //cambio a otra canción, sin embargo no sabemos si está reproduciendo la misma canción
    if (CheckBox1.Checked ){and  (key <>'') }then
      Scrobble;

    actualSong:=tempSongName;

    self.Caption:= actualArtist + ' - ' + actualSong;
    actualDuration:=inttostr(PlayBackStringToSeconds(GetDuration));
    lfmNext(actualArtist,actualSong,'',actualDuration,'');

    //this is dangerous but let's try
    //    if checkbox2.Checked then  TrimAppMemorySize; //old ways
    //lets use a better ?  approach
    if CheckBox2.Checked then
    begin
//      EmptyWorkingSet(GetCurrentProcess);
      Chromium1.Browser.MainFrame.ExecuteJavaScript('gmusic.getJavaScriptValue('+IntToStr(WM_FREERAM)+',1)','',0);
    end;

  end
  else
  begin
    if songCompleted then
    begin
      if (CheckBox1.Checked) {and (key<>'')} then
        Scrobble;

      songCompleted:=false; //está comenzando otra nueva canción, aunque sea repetida
      lfmNext(actualArtist,actualSong,'',inttostr(PlayBackStringToSeconds(GetDuration)),'');
    end;
  end;

  if WindowState = wsMinimized then
  begin
    ShowWindow(frmShadow.Handle,SW_HIDE);
  end;
end;


(* This will monitor playbakc status so it will update the buttons*)
procedure TForm1.tmrGadgetStatusTimer(Sender: TObject);
var
  tmpState: boolean;
begin
  // lets compare to old state
  tmpState := MusicIsPlaying;
  if prevPlaybackState <> tmpState  then
  begin
    // playback state has changed
    prevPlaybackState := tmpState;

    // update play button
    imgPlayMouseLeave(self);
  end;

end;

procedure TForm1.tmrHotKeysTimer(Sender: TObject);
const
{
Well just add all the keys you need to use here
more can be found at MSDN.microsoft.com
or here
http://www.howtodothings.com/showarticle.asp?article=308
}
VK_BROWSER_BACK = $A6; // Windows 2000 or later: Browser Back key
VK_BROWSER_FORWARD = $A7; // Windows 2000 or later: Browser Forward key
VK_BROWSER_REFRESH = $A8; // Windows 2000 or later: Browser Refresh key
VK_BROWSER_STOP = $A9; // Windows 2000 or later: Browser Stop key
VK_BROWSER_SEARCH = $AA; // Windows 2000 or later: Browser Search key
VK_BROWSER_FAVORITES = $AB; // Windows 2000 or later: Browser Favorites key
VK_BROWSER_HOME = $AC; // Windows 2000 or later: Browser Start and Home key
VK_VOLUME_MUTE = $AD; // Windows 2000 or later: Volume Mute key
VK_VOLUME_DOWN = $AE; // Windows 2000 or later: Volume Down key
VK_VOLUME_UP = $AF; // Windows 2000 or later: Volume Up key
VK_MEDIA_NEXT_TRACK = $B0; // Windows 2000 or later: Next Track key
VK_MEDIA_PREV_TRACK = $B1; // Windows 2000 or later: Prev Track key
VK_MEDIA_STOP = $B2; // Windows 2000 or later: Stop Media key
VK_MEDIA_PLAY_PAUSE = $B3; // Windows 2000 or later: Play/Pause Media key
VK_LAUNCH_MAIL = $B4; // Windows 2000 or later: Start Mail key
VK_LAUNCH_MEDIA_SELECT = $B5; // Windows 2000 or later: Select Media key
VK_LAUNCH_APP1 = $B6; // Windows 2000 or later: Start Application 1 key
VK_LAUNCH_APP2 = $B7; // Windows 2000 or later: Start Application 2 key
begin
  if GetAsyncKeyState(VK_MEDIA_NEXT_TRACK)<>0 then
       GForward
  else if GetAsyncKeyState(VK_MEDIA_PREV_TRACK)<>0 then
       GRewind
  else if GetAsyncKeyState(VK_MEDIA_PLAY_PAUSE)<>0 then
       GPlay//play pause
  else if GetAsyncKeyState(VK_MEDIA_STOP)<>0 then
      GPause;
  //show / hide resize border button
  try
    if (WindowState <> wsMaximized)
    and (ScreenToClient(Mouse.CursorPos).X > Form1.ClientWidth - 50)
    and (ScreenToClient(Mouse.CursorPos).X < Form1.ClientWidth)
    and (ScreenToClient(Mouse.CursorPos).Y > Form1.ClientHeight - 50)
    and (ScreenToClient(Mouse.CursorPos).Y < Form1.ClientHeight)
    then
      pnlResizeBorder.Visible:=true
    else
      pnlResizeBorder.Visible:=False;

  except

  end;
end;

procedure TForm1.tmrLoadingTimer(Sender: TObject);
begin
  Shape1.Width:=ClientWidth;
  if Shape2.Width >= Shape1.Width then
    Shape2.Width:=0
  else
    Shape2.Width:=Shape2.Width+50;
end;

procedure TForm1.tmrWin7TaskBarTimer(Sender: TObject);
var
duration: integer;
begin
  //for music trackbar progress
  if not MusicIsPlaying then exit;

  duration:=PlayBackStringToSeconds(GetDuration);
  FTick:=PlayBackStringToSeconds(GetPosition);
  FTaskBar.SetProgressValue(Handle, FTick, duration);

  if FTick >= duration then
  begin
    songCompleted:=true;
  end;
  if duration=0 then
    FTaskBar.SetProgressState(Handle, TBPF_NOPROGRESS)
  else if duration > 1 then
    FTaskBar.SetProgressState(Handle, TBPF_NORMAL);

end;

procedure TForm1.Button1Click(Sender: TObject);
begin
 Chromium1.ShowDevTools;
end;

procedure TForm1.cbUserStylesChange(Sender: TObject);
begin
  if (cbUserStyles.ItemIndex >=0) and (cbUserStyles.ItemIndex < cbUserStyles.Items.Count) then
  begin
    CustomCSS:=cbUserStyles.Items[cbUserStyles.ItemIndex];
     // let's disable and or enable at runtime
    if chkCustomCSS.Checked then
    begin
      UnLoadCustomCSS(@Chromium1.Browser);
      Sleep(100);
      LoadCustomCSS(@Chromium1.Browser, ExtractFilePath(ParamStr(0))+'userstyles\'+CustomCSS);
    end;
  end;
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
var Ini: TIniFile;
begin
  Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'settings.ini');
  try
      ini.WriteBool('LastFM','scrobble',CheckBox1.Checked);
  finally
      Ini.UpdateFile;
      Ini.Free;
  end;
end;

procedure TForm1.CheckBox2Click(Sender: TObject);
var Ini: TIniFile;
begin
  Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'settings.ini');
  try
      ini.WriteBool('System','forcefreeRAM',CheckBox2.Checked);
  finally
      Ini.UpdateFile;
      Ini.Free;
  end;
end;


procedure TForm1.chkCustomCSSClick(Sender: TObject);
var
ini:TIniFile;
begin
  Ini:=TIniFile.Create(ExtractFilePath(ParamStr(0))+'settings.ini');
  try
    ini.WriteBool('GMusic','UserStyleSheet',chkCustomCSS.Checked);
  finally
    Ini.UpdateFile;
    Ini.Free;
  end;
  cbUserStyles.Enabled := chkCustomCSS.Checked;
  // let's disable and or enable at runtime
  if chkCustomCSS.Checked then
    LoadCustomCSS(@Chromium1.Browser, ExtractFilePath(ParamStr(0))+'userstyles\'+CustomCSS)
  else
    UnLoadCustomCSS(@Chromium1.Browser);

end;

procedure TForm1.chkMiniOnTopClick(Sender: TObject);
var
ini:TIniFile;
begin
  Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'settings.ini');
  try
      ini.WriteBool('MiniPlayer','OnTop',chkMiniOnTop.Checked);
  finally
      Ini.UpdateFile;
      Ini.Free;
  end;
end;

procedure TForm1.chkNotifyClick(Sender: TObject);
var
ini:TIniFile;
begin
  Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'settings.ini');
  try
      ini.WriteBool('GMusic','Notify',chkNotify.Checked);
  finally
      Ini.UpdateFile;
      Ini.Free;
  end;
end;



procedure TForm1.Chromium1BeforeContextMenu(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame;
  const params: ICefContextMenuParams; const model: ICefMenuModel);
begin
  browser.MainFrame.ExecuteJavaScript('window.oncontextmenu = function(){return false}','',0);
  browser.MainFrame.ExecuteJavaScript('document.oncontextmenu = document.body.oncontextmenu = function(){return false}','',0);
end;

procedure TForm1.Chromium1BeforePopup(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame; const targetUrl,
  targetFrameName: ustring; targetDisposition: TCefWindowOpenDisposition;
  userGesture: Boolean; var popupFeatures: TCefPopupFeatures;
  var windowInfo: TCefWindowInfo; var client: ICefClient;
  var settings: TCefBrowserSettings; var noJavascriptAccess: Boolean;
  out Result: Boolean);
begin
  if pos('http',targeturl)=1 then

  ShellExecute(GetDesktopWindow,'open',pchar(targeturl),'','',SW_NORMAL);

  result:=true;
  if pos('dev',targeturl)>1 then
  result := false;
end;

procedure TForm1.Chromium1BeforeResourceLoad(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame;
  const request: ICefRequest; const callback: ICefRequestCallback;
  out Result: TCefReturnValue);
begin
  if IsMain(browser, frame) then
  begin
    if(pos('get.adobe.com/flashplayer', request.Url)>0)then
    begin
      ShellExecute(GetDesktopWindow, 'OPEN', pchar(request.Url),nil,nil, SW_SHOW);
      Result := RV_CANCEL;//True;
    end;

  end;

  if not CSSLoaded then
  begin

    CSSLoaded:=True; //let's make sureto only load the css once
                     // loadstart sets it to false
  //disable css from chromium
//    Chromium1.Options.AuthorAndUserStylesDisabled:=True;

  //-->>CSS Styling
  //there is no need to customize the scrollbar anymore, at least on windows 8
  browser.MainFrame.ExecuteJavaScript('(function(){var css=document.createElement("style");'+
  'css.type="text/css";css.innerText="::-webkit-scrollbar{width: 7px;height: 3p'+
  'x;}::-webkit-scrollbar-button:start:decrement,::-webkit-scrollbar-button:end'+
  ':increment{height: 10px;display: block;background-color: #ffffff;}::-webkit-'+
  'scrollbar-track-piece{background-color: #ffffff;-webkit-border-radius: 0px;}'+
  '::-webkit-scrollbar-thumb:vertical{height: 5px;background: #a4a4a4;-we'+
  'bkit-border-radius: 0px;}::-webkit-scrollbar-thumb:horizontal{width: 5px;bac'+
  'kground: #a4a4a4;-webkit-border-radius: 0px;}#_disabled_gb{visibility:hidden;}";'+
  'document.head.appendChild(css);})();','',0);

  browser.MainFrame.ExecuteJavaScript('(function(){var css=document.createElement("style");'+
  'css.type="text/css";css.innerText="#main,#nav{overflow:hidden;}";'+
  'document.head.appendChild(css);})();','',0);
  sleep(250);
  browser.MainFrame.ExecuteJavaScript('(function(){var css=document.createElement("style");'+
  'css.type="text/css";css.innerText="#main,#nav{overflow:auto;}#oneGoogleWrapper{display:none!important}";'+
  'document.head.appendChild(css);})();','',0);

  //fix to hide context menu, at least the ugly default one, not interfering with the right click of course
  browser.MainFrame.ExecuteJavaScript('window.oncontextmenu = function(){return false}','',0);
  browser.MainFrame.ExecuteJavaScript('document.oncontextmenu = document.body.oncontextmenu = function(){return false}','',0);
  //disable drag drop, doesn't seem to work
//  browser.MainFrame.ExecuteJavaScript('window.addEventListener("dragover",function(e){e = e || event;e.preventDefault();},false);','',0);
//  browser.MainFrame.ExecuteJavaScript('window.addEventListener("drop",function(e){e = e || event;e.preventDefault();},false);','',0);

  //disable selection of html elements and enable only on input elements
  browser.MainFrame.ExecuteJavaScript('(function(){var css=document.createElement("style");'+
  'css.type="text/css";css.innerText="*{-webkit-touch-callout:none;-webkit-user-select:none;'+
  'user-select:none;}input, textarea /*.contenteditable?*/ {-webkit-touch-callout:default;'+
  '-webkit-user-select:text;user-select:text;}";'+
  'document.head.appendChild(css);})();','',0);

  //CSS Styling <<--
  if chkCustomCSS.Checked then
  begin
    LoadCustomCSS(@browser, ExtractFilePath(ParamStr(0))+'userstyles\'+CustomCSS);
  end;

    pnlSplashScreen.Visible:=false;
  end;
end;

{This replaces WM_COPYDATA since extensions seems to leak memory on each call}
procedure TForm1.Chromium1ConsoleMessage(Sender: TObject;
  const browser: ICefBrowser; const message, source: ustring; line: Integer;
  out Result: Boolean);
begin
  if Pos('WM_GETSONGNAME',message) = 1 then
    songName := Copy(message, 15);

  if Pos('WM_GETCOVERARTURL',message) = 1 then
    coverURL := Copy(message, 18);

  if Pos('WM_GETARTISTNAME', message) = 1 then
    artistName := Copy(message, 17);

  if Pos('WM_ISPLAYCONTROLENABLED', message) = 1 then
    isPlayBackEnabled := Copy(message, 24);

  if Pos('WM_GETSONGDURATION',message) = 1 then
    songDuration := Copy(message, 19);

  if Pos('WM_GETSONGPOSITION', message) = 1 then
    songPosition := Copy(message, 19);

  if Pos('WM_ISMUSICPLAYING', message) = 1 then
    isPlaying := Copy(message, 17);
end;

procedure TForm1.Chromium1ContextMenuCommand(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame;
  const params: ICefContextMenuParams; commandId: Integer;
  eventFlags: TCefEventFlags; out Result: Boolean);
begin
 // Result := True;
end;

procedure TForm1.Chromium1LoadEnd(Sender: TObject; const browser: ICefBrowser;
  const frame: ICefFrame; httpStatusCode: Integer);
begin
  if IsMain(browser, frame) then
  begin
    FLoading := False;

    //see if they're using http or https
    if (pos('play.google.com/music/listen',frame.Url)=8)
    or(pos('play.google.com/music/listen',frame.Url)=9) then
    begin

    //desactivamos la animación de cargado
    Shape1.Visible:=False;
    Shape2.Visible:=False;
    tmrLoading.Enabled:=False;

    //ocultamos topBarContainer
    Frame.ExecuteJavaScript('document.getElementById("oneGoogleWrapper").style.visibility = "hidden"','',0);
    Frame.ExecuteJavaScript('document.getElementById("oneGoogleWrapper").style.display = "none"','',0);

    //inyectamos código para hacer click
    Frame.ExecuteJavaScript('var s=document.createElement(''script'');s.innerText=''function dispatchMouseEvent(t,e){var f=document.createEvent("MouseEvents");f.initMouseEvent(e,true,true,window,0,0,0,0,0,false,false,false,false,0,null);t.dispatchEvent(f)}'';document.head.appendChild(s);','',0);
    //ahora el mouseclick
    Frame.ExecuteJavaScript('var s=document.createElement(''script'');s.innerText=''function mouseClick(e){dispatchMouseEvent(e,"mouseover");dispatchMouseEvent(e,"mousedown");dispatchMouseEvent(e,"click");dispatchMouseEvent(e,"mouseup");}'';document.head.appendChild(s);','',0);

    //agregamos fondo para mostrar dialogos de la aplicación
    Frame.ExecuteJavaScript('var d=document.createElement(''div'');d.id="GMxBG";'
    +'d.setAttribute("style","position: fixed; z-index:5; width:100%;height:100%;'
    +'background:#777 -webkit-radial-gradient(rgba(127, 127, 127, 0.5), rgba(127, 127, 127, 0.5) 35%, rgba(0, 0, 0, 0.7));'
    +'left:0px;top:0px;opacity:0.7;display:none");if(!document.getElementById("GMxBG"))document.body.appendChild(d);','',0);
    //ahora maximizamos el volumen
    ///Chromium1.Browser.MainFrame.ExecuteJavaScript('document.getElementById("volume").style.display="block";mouseClick(document.getElementById("vslider"));document.getElementById("volume").style.display="none"','',0);

    // agregamos caja de búsqueda para

    //agregamos botones +1
    Frame.ExecuteJavaScript('q=document;d=q.createElement("div");d.id=''gmusicplus'',d.innerHTML=''<g:pl'
    +'usone size="medium"  href="http://apps.codigobit.info/gmusic"></g:plusone>'';d.setAttribute("style","position:absolute;z-index:4;");q.body.appendChild(d);','',0);
    //+'usone size="small" annotation="inline" href="http://apps.codigobit.info/2011/10/google-music-desktop-player.html"></g:plusone>'';d.setAttribute("style","position:absolute;z-index:4;");q.body.appendChild(d);','',0);

    Frame.ExecuteJavaScript('d.style.right="114px";d.style.top="24px";d.style.opacity=0.3;','',0);
    Frame.ExecuteJavaScript('d.setAttribute("onmouseover","d.style.opacity=1");','',0);
    Frame.ExecuteJavaScript('d.setAttribute("onmouseout","d.style.opacity=0.3");','',0);
    //frame.ExecuteJavaScript('d.innerHTML="<span><a href=''//https://www.google.com/accounts/Logout?service=sj&continue=http://music.google.com/music/listen''>Logout</a> |</span>"+d.innerHTML','',0);
    sleep(100);
    Frame.ExecuteJavaScript('(function(){var p=document.createElement(''script'');p.type=''text/javascript'';p.async=true;p.src=''https://apis.google.com/js/plusone.js'';var s=document.getElementsByTagName(''script'')[0];s.parentNode.insertBefore(p,s);})();','',0);

    //Let's add the search box // not anymore since new official theme uses top bar as search
(*    Frame.ExecuteJavaScript(
    'if(!document.getElementById("buscar")){if(document.getElementById("nav")){'
    +'var nav = document.getElementById("nav");var x = document.createElement("div");'
    +'x.id = "buscar";x.class="nav-section-header";x.setAttribute("align","center");x.innerHTML = "<input '
    +'placeholder=\"Search...\" type=''text'' name=''buscar'' onkeypress=''if(ev'
    +'ent.keyCode == 13){window.location.href = \"/music/listen#/sr/\"+this.valu'
    +'e}''><div class=\"nav-section-divider\"></div>";nav.insertBefore(x,nav.firstChild);}}',
    '',0);*)

    // Let's hide the flash player container
    //Frame.ExecuteJavaScript('document.getElementById("embed-container").style.visibility = "hidden"','',0);


    //Let's clear incompatible elements
    Frame.ExecuteJavaScript('document.querySelectorAll(''[data-id="show-miniplayer"]'')[0].disabled=true','',0);
    Frame.ExecuteJavaScript('document.querySelectorAll(''[data-id="upload-music"]'')[0].disabled=true','',0);
    Frame.ExecuteJavaScript('document.querySelectorAll(''[data-id="upload-music"]'')[0].style.display=''none''','',0);
    //hide incompatible elements
    Frame.ExecuteJavaScript('if(document.getElementById(":2b"))document.getElementById(":2b").style.display="none"','',0);
    Frame.ExecuteJavaScript('if(document.getElementById(":2c"))document.getElementById(":2c").style.display="none"','',0);
    Frame.ExecuteJavaScript('if(document.getElementById(":2d"))document.getElementById(":2d").style.display="none"','',0);
    Frame.ExecuteJavaScript('if(document.getElementById(":7"))document.getElementById(":7").style.display="none"','',0);
    //lets hide the settings button, no needed  :P
    Frame.ExecuteJavaScript('if(document.getElementById("extra-links-container"))document.getElementById("extra-links-container").style.display="none"','',0);

    end;


    pnlSplashScreen.Visible:=false;
  end;
end;

procedure TForm1.Chromium1LoadStart(Sender: TObject; const browser: ICefBrowser;
  const frame: ICefFrame);
begin
  if IsMain(browser,frame) then
  begin
    FLoading := True;

    if (pos('play.google.com/music/listen',frame.Url)=8)
    or(pos('play.google.com/music/listen',frame.Url)=9) then
    begin
      CSSLoaded:=False;
      Shape1.Visible:=True;
      Shape2.Visible:=True;
      Shape2.Width:=0;
      tmrLoading.Enabled:=True;
    end;
  end;
end;

procedure TForm1.Artist1Click(Sender: TObject);
begin
{$IFDEF DELPHI14_UP}
Chromium1.Browser.MainFrame.VisitDomProc(
procedure (const doc: ICefDomDocument)
        var el: ICefDomNode;
        begin
          el := doc.GetElementById('playerArtist');
          if Assigned(el) then begin
            el:=el.FirstChild;
            if Assigned(el) then
            showmessage(el.ElementInnerText);
          end;
        end);
{$ENDIF}
end;

//LastFM Scrobbling procedures
procedure TForm1.lfmPlay(Artist: string; Song: string; Album: string; Length: string; Track: string);
begin

 case PlayerStatus of
      ps_Stopped: begin
          PlayerStatus := ps_Playing;
        end;
      ps_Paused: begin
          PlayerStatus := ps_Playing;
        end;

      ps_Playing: begin
          PlayerStatus := ps_Paused;
        end;
    end;
end;

procedure TForm1.lfmStop;
begin
    Scrobble;
    PlayerStatus := ps_Stopped;
end;

procedure TForm1.lfmNext(Artist: string; Song: string; Album: string; Length: string; Track: string);
begin
    //to show a notification
  if (artist<>'')and(MusicIsPlaying)and(chkNotify.Checked)and(IsPlayControlEnabled) then
  begin
    frmGadget.lblSong.Caption:=Song;
    frmGadget.lblArtist.Caption:=Artist;
    frmGadget.Start:=GetTickCount;
    frmGadget.FormStyle:=fsStayOnTop;
    frmGadget.Show;
    frmGadget.BringToFront;
  end;
    PlayerStatus := ps_Playing;
   if (CheckBox1.Checked) and (key<>'') and (MusicIsPlaying)then
    updateNowPlaying;
end;


initialization
  WM_TASKBARBUTTONCREATED := RegisterWindowMessage('TaskbarButtonCreated');
end.

