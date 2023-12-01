unit FastBMP;

interface
uses
  Graphics, Types;

type
  TARGBQuadruple = packed record
    A, R, G, B: Byte;
  end;

  PARGBQuadruple = ^TARGBQuadruple;
  TARGBQuadrupleArray = ARRAY[Word] of TARGBQuadruple;
  PARGBQuadrupleArray = ^TARGBQuadrupleArray;
  TFastBMP = class
  private
    FOriginalBitmap:TBitmap;
    FBitmap:TBitmap;
    FLines: array of PARGBQuadrupleArray;
    procedure InitializeBitmap(const AWidth,AHeight:Integer; const APixelFormat:TPixelFormat = pf32bit);


    procedure BuildLineAccessArray;
    function GetPixel(X, Y: Integer): PARGBQuadruple; inline;
    function GetHeight: Integer;
    function GetWidth: Integer;
    procedure FillDWord(ACount,ABuffer : DWORD; var Dest) ;
  public
    procedure AssignBitmap(const ABitmap:TBitmap);overload;
    procedure AssignBitmap(const ABitmap:TFastBMP);overload;
    procedure AttachToBitmap(const ABitmap:TBitmap);
    procedure UnattachBitmap;
    procedure FillLine(const AY:Integer; const AX:Integer; const ACount:Integer; const AColor:TARGBQuadruple); overload; inline;
    procedure FillLine(const AY:Integer; const AX:Integer; const ACount:Integer; const AGreyValue:Byte); overload; inline;

    constructor Create(const AWidth,AHeight:Integer);overload;
    constructor Create(const ABitmap:TBitmap); overload;
    destructor Destroy;

    property Pixels[X:Integer;Y:Integer]:PARGBQuadruple read GetPixel;
    property Width:Integer read GetWidth;
    property Height:Integer read GetHeight;
  end;

implementation
uses
  SysUtils;

{ TFastBMP }

constructor TFastBMP.Create(const AWidth, AHeight: Integer);
begin
  FBitmap:= TBitmap.Create;
  InitializeBitmap(AWidth,AHeight,pf32bit); //for now only 24 bit is supported
end;

procedure TFastBMP.AssignBitmap(const ABitmap: TBitmap);
begin
  FBitmap.Assign(ABitmap);
  FBitmap.PixelFormat:= pf32bit; //for now only 24 bit is supported
  BuildLineAccessArray;
end;


procedure TFastBMP.AssignBitmap(const ABitmap: TFastBMP);
begin
  {
    we always want to assign our primary bitmap
    this means also an attached bitmap might be copied this way
  }
  AssignBitmap(ABitmap.FBitmap);
end;

procedure TFastBMP.AttachToBitmap(const ABitmap: TBitmap);
begin

  if not Assigned(FOriginalBitmap) then //in case we already have an attached bitmap we can just override the pointer
  begin
      FOriginalBitmap:= FBitmap; //store the managed bitmap pointer for later release
  end;
  FBitmap:= ABitmap;
  FBitmap.PixelFormat:= pf32bit; // we always need to do this ;)
  BuildLineAccessArray;
end;

procedure TFastBMP.BuildLineAccessArray;
var
  i:Integer;
begin
  setlength(FLines,FBitmap.Height);
  for i := 0 to FBitmap.Height-1 do
  begin
    FLines[i]:= PARGBQuadrupleArray(FBitmap.ScanLine[i]);
  end;
end;

constructor TFastBMP.Create(const ABitmap: TBitmap);
begin
  FBitmap:= TBitmap.Create;
  AssignBitmap(ABitmap);
end;


destructor TFastBMP.Destroy;
begin
  {
    in case we're attached to another resource, we don't want to free this resource
  }
  if Assigned(FOriginalBitmap) then
    FOriginalBitmap.Free
  else
    FBitmap.Free;

end;

procedure TFastBMP.FillDWord(ACount, ABuffer: DWORD; var Dest);assembler;
begin
   asm
    MOV EDI,Dest ;
    MOV ECX,ACount ;
    MOV EAX,ABuffer ;
    CLD ;
    REP STOSD
   end ;
end;

procedure TFastBMP.FillLine(const AY, AX, ACount: Integer;
  const AGreyValue: Byte);
begin
  FillChar(GetPixel(AX,AY)^,SizeOf(TARGBQuadruple)*ACount,AGreyValue);
end;

procedure TFastBMP.FillLine(const AY:Integer; const AX, ACount: Integer;
  const AColor: TARGBQuadruple);
begin
  FillDWord(ACount,DWORD(AColor),GetPixel(AX,AY)^);
end;

function TFastBMP.GetHeight: Integer;
begin
  Result:= FBitmap.Height;
end;

function TFastBMP.GetPixel(X, Y: Integer): PARGBQuadruple;
begin
  Result:= @FLines[Y][X];
end;

function TFastBMP.GetWidth: Integer;
begin
  Result:= FBitmap.Width;
end;

procedure TFastBMP.InitializeBitmap(const AWidth, AHeight: Integer;
  const APixelFormat: TPixelFormat);
begin
  FBitmap.Width:= AWidth;
  FBitmap.Height:= AHeight;
  FBitmap.PixelFormat:= APixelFormat;
  BuildLineAccessArray;
end;

procedure TFastBMP.UnattachBitmap;
begin
  if Assigned(FOriginalBitmap) then
  begin
    FBitmap:= FOriginalBitmap;
    FOriginalBitmap:= nil;
  end;
end;

end.
