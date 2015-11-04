{
  DropShadow Layered Windows with Transparent click
  Author: Victor Alberto Gil <vhanla>
  Written 07/09/2012
}
unit dropshadow_src;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  //for loading pictures
  gdipapi,gdipobj, activex;

type
  pTGPBitmap = ^TGPBitmap;
  TfrmShadow = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    //pictures
    osx, win, big: TGPBitmap;
    shadowType: integer; //0 = Windows, 1 = OSX and so on
    procedure UpdateShadow;
    procedure SetShadowType(const value:Integer);
  public
    { Public declarations }
  published
    Property Shadow: integer read shadowType write SetShadowType;
  end;

var
  frmShadow: TfrmShadow;
  frmShadowEnabled: boolean = false;
const
  WINDOWS = 0;
  MACOSX = 1;
  BIGSHADOW = 2;
implementation

{$R *.dfm}


procedure PremultiplyBitmap(Bitmap: TBitmap);
var
  Row, Col: integer;
  p: PRGBQuad;
  PreMult: array[byte, byte] of byte;
begin
  // precalculate all possible values of a*b
  for Row := 0 to 255 do
    for Col := Row to 255 do
    begin
      PreMult[Row, Col] := Row*Col div 255;
      if (Row <> Col) then
        PreMult[Col, Row] := PreMult[Row, Col]; // a*b = b*a
    end;

  for Row := 0 to Bitmap.Height-1 do
  begin
    Col := Bitmap.Width;
    p := Bitmap.ScanLine[Row];
    while (Col > 0) do
    begin
      p.rgbBlue := PreMult[p.rgbReserved, p.rgbBlue];
      p.rgbGreen := PreMult[p.rgbReserved, p.rgbGreen];
      p.rgbRed := PreMult[p.rgbReserved, p.rgbRed];
      inc(p);
      dec(Col);
    end;
  end;
end;

procedure TfrmShadow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  action:=caNone;
//  application.Terminate;
end;

procedure TfrmShadow.FormCreate(Sender: TObject);
var
  Stream: TStream;
  StreamAdapter: IStream;
begin
// let's load all pictures ^_^
  Stream:=TResourceStream.Create(HInstance,'OSX',RT_RCDATA);
  try
    StreamAdapter:=TStreamAdapter.Create(Stream);
    try
      osx:=TGPBitmap.Create(StreamAdapter);
    finally
      StreamAdapter:=nil;
    end;
  finally
    Stream.Free;
  end;

  Stream:=TResourceStream.Create(HInstance,'WINDOWS8',RT_RCDATA);
  try
    StreamAdapter:=TStreamAdapter.Create(Stream);
    try
      win:=TGPBitmap.Create(StreamAdapter);
    finally
      StreamAdapter:=nil;
    end;
  finally
    Stream.Free;
  end;

  Stream:=TResourceStream.Create(HInstance,'WINDOWS',RT_RCDATA);
  try
    StreamAdapter:=TStreamAdapter.Create(Stream);
    try
      big:=TGPBitmap.Create(StreamAdapter);
    finally
      StreamAdapter:=nil;
    end;
  finally
    Stream.Free;
  end;

  //ready


  BorderStyle:=bsNone;
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) Or WS_EX_LAYERED or WS_EX_TRANSPARENT or WS_EX_TOOLWINDOW );

  shadowType:=WINDOWS; //by default
  UpdateShadow;
end;

procedure TfrmShadow.FormDestroy(Sender: TObject);
begin
  win.Free;
  osx.Free;
  big.Free;
end;


procedure TfrmShadow.UpdateShadow;
var

  BlendFunction: TBlendFunction;
  Bitmap: TBitmap;
  BitmapPoint: TPoint;
  BitmapHandle: HBITMAP;
  BitmapSize: TSize;
  tmp: TGPGraphics;
  buf: TGPBitmap;
  r: TGPRect;

  shadowpic: pTGPBitmap;
begin
    Bitmap:=TBitmap.Create;
  try

    //let's draw it stretched
    buf:=TGPBitmap.Create(ClientWidth,ClientHeight,0,PixelFormat32bppARGB,nil);
    tmp:=TGPGraphics.Create(buf);
    try
      //tmp.Clear(ColorRefToARGB(ColorToRGB(clnone)));
      tmp.SetPixelOffsetMode(PixelOffsetModeHalf); //this will fix bad stretching :)
      tmp.Clear(MakeColor(0,0,0,0));
      tmp.SetInterpolationMode(InterpolationModeNearestNeighbor);
      // choose which shadow type
      if shadowType = WINDOWS then
        shadowpic:=@win
      else if shadowType = MACOSX then
        shadowpic:=@osx
      else shadowpic:=@big;

      //topleft
      r.X:=0;r.Y:=0;r.Width:=42;r.Height:=42;
      tmp.DrawImage(shadowpic^,r,0,0,42,43,UnitPixel);
      //top
      r.X:=42;r.Y:=0;r.Width:=ClientWidth-84;r.Height:=42;
      tmp.DrawImage(shadowpic^,r,42,0,168,43,UnitPixel);
      //topright
      r.X:=ClientWidth-42;r.Y:=0;r.Width:=42;r.Height:=42;
      tmp.DrawImage(shadowpic^,r,210,0,42,43,UnitPixel);
      //left
      r.X:=0;r.Y:=42;r.Width:=42;r.Height:=ClientHeight-84;
      tmp.DrawImage(shadowpic^,r,0,43,42,168,UnitPixel);
      //right
      r.X:=ClientWidth-42;r.Y:=42;r.Width:=42;r.Height:=ClientHeight-84;
      tmp.DrawImage(shadowpic^,r,210,43,42,168,UnitPixel);
      //bottomleft
      r.X:=0;r.Y:=ClientHeight-42;r.Width:=42;r.Height:=42;
      tmp.DrawImage(shadowpic^,r,0,211,42,42,UnitPixel);
      //bottom
      r.X:=42;r.Y:=ClientHeight-42;r.Width:=ClientWidth-84;r.Height:=42;
      tmp.DrawImage(shadowpic^,r,42,211,168,42,UnitPixel);
      //bottom right
      r.X:=ClientWidth-42;r.Y:=ClientHeight-42;r.Width:=42;r.Height:=42;
      tmp.DrawImage(shadowpic^,r,210,211,42,42,UnitPixel);
    finally
      tmp.Free;
    end;

    buf.GetHBITMAP(MakeColor(0,0,0,0),BitmapHandle);
    buf.Free;
    Bitmap.Handle:=BitmapHandle;

//    Assert(Bitmap.PixelFormat = pf32bit,'no alpha channel');
//    PremultiplyBitmap(Bitmap);

    BitmapSize.cx:=Bitmap.Width;
    BitmapSize.cy:=Bitmap.Height;

    BlendFunction.BlendOp := AC_SRC_OVER;
    BlendFunction.BlendFlags:= 0;
    BlendFunction.SourceConstantAlpha:=255;
    BlendFunction.AlphaFormat:=AC_SRC_ALPHA;

    BitmapPoint:=point(0,0);

    UpdateLayeredWindow(handle, 0,nil,@BitmapSize, Bitmap.Canvas.Handle,
         @BitmapPoint,0,@BlendFunction, ULW_ALPHA);
  finally
    Bitmap.Free;
  end;

end;

procedure TfrmShadow.SetShadowType(const value: Integer);
begin
  if value = MACOSX then
    shadowType:=value
  else if value = WINDOWS then
    shadowType:=value
  else shadowType:=BIGSHADOW;
  UpdateShadow;
end;



procedure TfrmShadow.FormResize(Sender: TObject);
begin
  UpdateShadow;
end;

end.
