unit FastBMP;

interface
uses
  Graphics;

type
  TRGBTriple = packed record
    R, G, B: Byte;
  end;

  PRGBTriple = ^TRGBTriple;
  TRGBTripleArray = ARRAY[Word] of TRGBTriple;
  PRGBTripleArray = ^TRGBTripleArray;
  TFastBMP = class
  private
    FOriginalBitmap:TBitmap;
    FBitmap:TBitmap;
    FLines: array of PRGBTripleArray;
    procedure InitializeBitmap(const AWidth,AHeight:Integer; const APixelFormat:TPixelFormat = pf24bit);


    procedure BuildLineAccessArray;
    function GetPixel(X, Y: Integer): PRGBTriple;
    function GetHeight: Integer;
    function GetWidth: Integer;
  public
    procedure AssignBitmap(const ABitmap:TBitmap);overload;
    procedure AssignBitmap(const ABitmap:TFastBMP);overload;
    procedure AttachToBitmap(const ABitmap:TBitmap);
    procedure UnattachBitmap;

    constructor Create(const AWidth,AHeight:Integer);overload;
    constructor Create(const ABitmap:TBitmap); overload;
    destructor Destroy;

    property Pixels[X:Integer;Y:Integer]:PRGBTriple read GetPixel;
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
  InitializeBitmap(AWidth,AHeight,pf24bit); //for now only 24 bit is supported
end;

procedure TFastBMP.AssignBitmap(const ABitmap: TBitmap);
begin
  FBitmap.Assign(ABitmap);
  FBitmap.PixelFormat:= pf24bit; //for now only 24 bit is supported
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
  FBitmap.PixelFormat:= pf24bit; // we always need to do this ;)
  BuildLineAccessArray;
end;

procedure TFastBMP.BuildLineAccessArray;
var
  i:Integer;
begin
  setlength(FLines,FBitmap.Height);
  for i := 0 to FBitmap.Height-1 do
  begin
    FLines[i]:= PRGBTripleArray(FBitmap.ScanLine[i]);
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

function TFastBMP.GetHeight: Integer;
begin
  Result:= FBitmap.Height;
end;

function TFastBMP.GetPixel(X, Y: Integer): PRGBTriple;
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
