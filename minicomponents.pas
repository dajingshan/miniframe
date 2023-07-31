
//////////////////////////////////////////////////////////////////////////////////
///                                                                            ///
///  miniframe开源Web框架技术群：821855479 如果加不了群，请联系QQ：3123827806  ///
///  网页制作器网址：https://wyeditor.com                                      ///
///  源码及demo下载：https://wyeditor.com/miniframe/                           ///
///                                                                            ///
//////////////////////////////////////////////////////////////////////////////////

unit minicomponents;
{$ifdef fpc}
{$MODE Delphi}
{$endif}
{$if defined(unix) or defined(msdos) or defined(hasamiga) or defined(atari) or defined(win16)}
    {$define FINDHANDLE_IS_POINTER}
{$endif}
interface

uses
  Classes, SysUtils, Math, PubStringUnit, PubPWDUnit, mormot.core.base,
  PubMathUnit, mormot.core.variants, mormot.core.text,
  {$ifndef FPC}//ActiveX,  Windows, Vcl.Graphics,System.NetEncoding,
   System.Types, System.Zip// VCL.Imaging.Jpeg, VCL.Imaging.PngImage, VCL.Imaging.GIFImg
  {$else}zipper{$IFDEF LINUX},linux{$ENDIF} {$endif}, PubFileUnit;

{.$i ptypes.inc}

type
  TDatatype = TDocVariantKind;
  TminiJson = class(TObject)
  private
    FmainI_: TDocVariantData;
    FmainI: PDocVariantData;
    Flist: TList;
    procedure SetmainI(const Value: PDocVariantData);
    function GS(const path: string): string;
    procedure SS(const path: string;  const Value: string);
    function GetO(const path: string): TminiJson;
    function GetB(const path: string): boolean;
    function GetD(const path: string): Double;
    function GetI(const path: string): Int64;
    procedure PutB(const path: string; const Value: boolean);
    procedure PutD(const path: string; const Value: Double);
    procedure PutI(const path: string; const Value: Int64);
    function GetCount: integer;
    function GetA(const path: string): TminiJson;
    procedure SetA(const path: string; const Value: TminiJson);
    function GetItems(const index: integer): TminiJson;
    procedure SetO(const path: string; const Value: TminiJson);
    function GetNames(const index: integer): string;
    function GetValues(const index: integer): variant;
    function GetA_GS(const index: integer): string;
    procedure SetA_S(const path, Value: string);
    function GetA_GI(const index: integer): Int64;
    procedure SetA_I(const path: string; const Value: Int64);
    function GetA_GB(const index: integer): boolean;
    function GetA_GD(const index: integer): double;
    procedure SetA_B(const path: string; const Value: boolean);
    procedure SetA_D(const path: string; const Value: double);
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddObject(O: TObject);
    procedure CreateJson();

    function AsJson(indent: boolean): string; //生成Json串
    function IsType(AType: TDocVariantKind): boolean; //判断结点是数组还是对象
    procedure SO; //初始化
    procedure SOS(const s: string); //从字符串初始化为
    procedure SOA(const Args: array of const); //从数组中初始化

    function SaveToStream(stream: TStream): string; //保存到流中，返回值不为空表示出错
    function SaveToFile(const FileName: string): string; //保存到文件，返回值不为空表示出错
    function LoadFromFile(FileName: string): string; //从文件中加载，返回值不为空表示出错
    function LoadFromString(s: string): string; //从串中加载，返回值不为空表示出错
    function LoadFromStream(stream: TStream): string; //从流中加载，返回值不为空表示出错
    function DeleteByIndex(Index: integer): boolean; //通过下标删除指定一项
    function DeleteByName(const aName: string): boolean; //通过名称删除指定一项
    function DeleteByPath(const aPath: string): boolean; //通过路径删除指定一项 aPathDelim: AnsiChar = '.'
  {$ifdef fpc}
  published
  {$endif}
    property O[const path: string]: TminiJson read GetO write SetO; //读取指定路径的对象，返回值为TminiJson
    property S[const path: string]: string read GS write SS;
    property B[const path: string]: boolean read GetB write PutB;
    property I[const path: string]: Int64 read GetI write PutI;
    property D[const path: string]: Double read GetD write PutD;

    //数组的访问
    property A[const path: string]: TminiJson read GetA write SetA; //增加一个数组对象项

    property A_S[const path: string]: string write SetA_S;          //增加一个数组字符串项
    property A_GS[const index: integer]: string read GetA_GS;       //读取一个数组字符串项

    property A_I[const path: string]: Int64 write SetA_I;           //增加一个数组整数项
    property A_GI[const index: integer]: Int64 read GetA_GI;        //读取一个数组整数项
    property A_B[const path: string]: boolean write SetA_B;           //增加一个数组boolean项
    property A_GB[const index: integer]: boolean read GetA_GB;        //读取一个数组boolean项
    property A_D[const path: string]: double write SetA_D;           //增加一个数组Double项
    property A_GD[const index: integer]: double read GetA_GD;        //读取一个数组Double项
    property Items[const index: integer]: TminiJson read GetItems; default; //当数组项是对象时，读取一个对象

    property Names[const index: integer]: string read GetNames;     //读取当前数组对象子对象对应下标的属性名称
    property Values[const index: integer]: variant read GetValues;  //读取当前数组对子对象象对应下标的值

  published
    property Count: integer read GetCount;                          //读取当前对象子对象个数
    property Length: integer read GetCount;                         //读取当前对象子对象个数
  public
    property mainI: PDocVariantData read FmainI write SetmainI;
    procedure Clear;
  end;

  TFileTime = class
  private
    FdwLowDateTime: Cardinal;
    FdwHighDateTime: Cardinal;
    procedure SetdwHighDateTime(const Value: Cardinal);
    procedure SetdwLowDateTime(const Value: Cardinal);
  published
    property dwLowDateTime: Cardinal read FdwLowDateTime write SetdwLowDateTime;
    property dwHighDateTime: Cardinal read FdwHighDateTime write SetdwHighDateTime;
  end;
  TWin32FindData = class
  private
    FcFileName: string;
    FnFileSizeHigh: Cardinal;
    FdwFileAttributes: {$ifdef FINDHANDLE_IS_POINTER}Pointer{$else}THandle{$endif};
    FcAlternateFileName: string;
    FftLastAccessTime: TFileTime;
    FftCreationTime: TFileTime;
    FdwReserved0: Cardinal;
    FdwReserved1: Cardinal;
    FnFileSizeLow: Cardinal;
    FftLastWriteTime: TFileTime;
    procedure SetcAlternateFileName(const Value: string);
    procedure SetcFileName(const Value: string);
    procedure SetdwFileAttributes(const Value: {$ifdef FINDHANDLE_IS_POINTER}Pointer{$else}THandle{$endif});
    procedure SetdwReserved0(const Value: Cardinal);
    procedure SetdwReserved1(const Value: Cardinal);
    procedure SetftCreationTime(const Value: TFileTime);
    procedure SetftLastAccessTime(const Value: TFileTime);
    procedure SetftLastWriteTime(const Value: TFileTime);
    procedure SetnFileSizeHigh(const Value: Cardinal);
    procedure SetnFileSizeLow(const Value: Cardinal);
  public
    constructor Create;
    destructor Destroy; override;
  {$ifdef FINDHANDLE_IS_POINTER}
  public
  {$else}
  published
  {$endif}
    property dwFileAttributes: {$ifdef FINDHANDLE_IS_POINTER}Pointer{$else}THandle{$endif} read FdwFileAttributes write SetdwFileAttributes;
  published
    property ftCreationTime: TFileTime read FftCreationTime write SetftCreationTime;
    property ftLastAccessTime: TFileTime read FftLastAccessTime write SetftLastAccessTime;
    property ftLastWriteTime: TFileTime read FftLastWriteTime write SetftLastWriteTime;
    property nFileSizeHigh: Cardinal read FnFileSizeHigh write SetnFileSizeHigh;
    property nFileSizeLow: Cardinal read FnFileSizeLow write SetnFileSizeLow;
    property dwReserved0: Cardinal read FdwReserved0 write SetdwReserved0;
    property dwReserved1: Cardinal read FdwReserved1 write SetdwReserved1;
    property cFileName: string read FcFileName write SetcFileName;
    property cAlternateFileName: string read FcAlternateFileName write SetcAlternateFileName;
  end;

  { TSearchRec }

  TSearchRec = class
  private
    FExcludeAttr: Integer;
    FMode: integer;
    FName: string;
    FFindHandle: {$ifdef FINDHANDLE_IS_POINTER}Pointer{$else}THandle{$endif};
    FTime: Integer;
    FSize: Integer;
    FAttr: Integer;
    FFindData: TWin32FindData;
    procedure SetAttr(const Value: Integer);
    procedure SetExcludeAttr(const Value: Integer);
    procedure SetFindHandle(const Value: {$ifdef FINDHANDLE_IS_POINTER}Pointer{$else}THandle{$endif});
    procedure SetMode(AValue: integer);
    procedure SetName(const Value: string);
    procedure SetSize(const Value: integer);
    procedure SetTime(const Value: Integer);
    procedure SetFindData(const Value: TWin32FindData);
  public
    constructor Create;
    destructor Destroy; override;
  published
    {$ifdef unix}
    property Mode : integer read FMode write SetMode;
    {$endif unix}
    property Time: Integer read FTime write SetTime;
    property Size: Integer read FSize write SetSize;
    property Attr: Integer read FAttr write SetAttr;
    property Name: string read FName write SetName;
    property ExcludeAttr: Integer read FExcludeAttr write SetExcludeAttr;
    property FindHandle: {$ifdef FINDHANDLE_IS_POINTER}Pointer{$else}THandle{$endif} read FFindHandle write SetFindHandle;
    property FindData: TWin32FindData read FFindData write SetFindData;
  end;

  //解压文件到一个文件夹
  function UnZipFileToFolder(ZipFile, ToPath: string): string;
  //压缩一个文件
  function ZipOneFile(SourceFile, ToFile: string): string;

implementation

function UnZipFileToFolder(ZipFile, ToPath: string): string;
{$ifdef fpc}
var
  UnZipper: TUnZipper;
  TmpPath: string;
begin //先解压到一个文件夹防止一个文件出问题全解压不了
  try
    TmpPath := ExtractFilePath(ParamStr(0)) + 'T_tmp_UnzipData\';
    ForceDirectories(TmpPath);
    PubFile.FileDeleteDirectory(TmpPath);

    UnZipper := TUnZipper.Create;
    try
      UnZipper.FileName := ZipFile;
      UnZipper.OutputPath := TmpPath;
      UnZipper.Examine;
      UnZipper.UnZipAllFiles;

      //复制所有文件
      PubFile.FileCopyDirectory(TmpPath, ToPath);
    finally
      UnZipper.Free;
    end;
  except
    on e: exception do
    begin
      Result := e.Message;
    end;
  end;
  PubFile.FileDeleteDirectory(TmpPath);
end;

{$else}
var
  TmpPath: string;
begin //ExtractZipFile
  try
    TmpPath := ExtractFilePath(ParamStr(0)) + 'T_tmp_UnzipData\';
    ForceDirectories(TmpPath);
    PubFile.FileDeleteDirectory(TmpPath);
    TZipFile.ExtractZipFile(ZipFile, TmpPath);
    //if trim(Result) <> '' then exit;

    //复制所有文件
    PubFile.FileCopyDirectory(TmpPath, ToPath);
  except
    on e: exception do
      Result := e.Message;
  end;
  PubFile.FileDeleteDirectory(TmpPath);
end;
{$endif}

function ZipOneFile(SourceFile, ToFile: string): string;
{$ifdef fpc}
var
  Zipper: TZipper;
begin
  if trim(ToFile) = '' then
    ToFile := PubFile.FileGetTemporaryFileName('');
  try
    Zipper := TZipper.Create;
    try
      Zipper.FileName := ToFile;
      Zipper.Entries.AddFileEntry(SourceFile, ExtractFileName(SourceFile));
      Zipper.ZipAllFiles;
    finally
      Zipper.Free;
    end;
  except
    on e: exception do
    begin
      Result := e.Message;
    end;
  end;
  Result := ToFile;
end;
{$else}
var
  Zip: TZipFile;
begin //ExtractZipFile  压缩文件夹 TZipFile.ZipDirectoryContents('ZipFile.zip', 'C:\Zip\this\right\now');
  try
    if trim(ToFile) = '' then
      ToFile := PubFile.FileGetTemporaryFileName('.zip');
    Zip := TZipFile.Create;
    try
      Zip.Open(ToFile, zmWrite);
      Zip.Add(SourceFile);
    finally
      Zip.Free;
    end;
    Result := ToFile;
    Sleep(2);
  except
    on e: exception do
      Result := e.Message;
  end;
end;
{$endif}


{ TminiJson }

procedure TminiJson.AddObject(O: TObject);
begin
  Flist.Add(O);
end;

{function TminiJson.AsArray: TminiJsonArray;
begin
  Result := TminiJsonArray.Create;
  AddObject(Result);
  //Result.FSuperArray := mainI.;
end;}

function TminiJson.AsJSon(indent: boolean): string;
begin
  if indent then
    Result := FmainI^.ToJSON('', '', jsonEscapeUnicode)
  else
    Result := FmainI^.ToJSON('', '', jsonHumanReadable);
end;

constructor TminiJson.Create;
begin
  Flist := TList.Create;
end;

procedure TminiJson.CreateJson();
begin
  FmainI_.Init;
  FmainI := @FmainI_;
end;

function TminiJson.DeleteByIndex(Index: integer): boolean;
begin
  Result := FmainI^.Delete(Index);
end;

function TminiJson.DeleteByName(const aName: string): boolean;
begin
  Result := FmainI^.Delete(aName);
end;

function TminiJson.DeleteByPath(const aPath: string): boolean;
begin
  Result := FmainI^.Delete(aPath);
end;

procedure TminiJson.Clear;
begin
  try
    FmainI_.Clear;
  except
  end;
end;

destructor TminiJson.Destroy;
var
  lp: integer;
begin
  for lp := 0 to Flist.Count - 1 do
  try
    TminiJson(Flist.Items[lp]).Free;
  except
  end;
  Flist.Clear;
  Flist.Free;
  try
    FmainI_.Clear;
    FmainI := nil;
  except
  end;
  inherited;
end;

function TminiJson.GetA(const path: string): TminiJson;
begin
  Result := TminiJson.Create;
  AddObject(Result);
  Result.FmainI := Self.mainI^.A[Path];
end;

function TminiJson.GetA_GB(const index: integer): boolean;
begin
  Result := FmainI^.Values[index];
end;

function TminiJson.GetA_GD(const index: integer): double;
begin
  Result := FmainI^.Values[index];
end;

function TminiJson.GetA_GI(const index: integer): Int64;
begin
  Result := FmainI^.Values[index];
end;

function TminiJson.GetA_GS(const index: integer): string;
begin
  Result := FmainI^.Values[index];
end;

function TminiJson.GetB(const path: string): boolean;
begin
  Result := FmainI^.B[path];
end;

function TminiJson.GetCount: integer;
begin
  Result := FmainI^.Count;
end;

function TminiJson.GetD(const path: string): Double;
begin
  Result := FmainI^.D[path];
end;

function TminiJson.GetI(const path: string): Int64;
begin
  Result := FmainI^.I[path];
end;

function TminiJson.GetItems(const index: integer): TminiJson;
begin
  Result := TminiJson.Create;
  AddObject(Result);
  Result.FmainI := FmainI^._[index];
end;

function TminiJson.GetNames(const index: integer): string;
begin
  Result := FmainI^.Names[index];
end;

function TminiJson.GetO(const path: string): TminiJson;
begin
  Result := TminiJson.Create;
  Flist.Add(Result);
  Result.FmainI := FmainI^.GetAsDocVariantSafe(path);
end;

function TminiJson.GetValues(const index: integer): variant;
begin
  Result := FmainI^.Values[index];
end;

function TminiJson.GS(const path: string): string;
begin
  Result := FmainI^.s[path];
end;

function TminiJson.IsType(AType: TDocVariantKind): boolean;
begin
  Result := FmainI^.Kind = AType;
end;

function TminiJson.LoadFromFile(FileName: string): string;
begin
  try
    Result := '';
    Clear;
    FmainI_.InitJSONFromFile(FileName);
    FmainI := @FmainI_;
  except
    on e: exception do
      Result := e.Message;
  end;
end;

function TminiJson.LoadFromStream(stream: TStream): string;
var
  SL: TStringlist;
begin
  try
    SL := TStringlist.Create;
    try
      Result := '';
      Clear;
      try
        SL.LoadFromStream(stream, TEncoding.UTF8);
      except
        SL.LoadFromStream(stream);
      end;
      FmainI_.InitJson(SL.Text);
      FmainI := @FmainI_;
    finally
      SL.Free;
    end;
  except
    on e: exception do
      Result := e.Message;
  end;
end;

function TminiJson.LoadFromString(s: string): string;
begin
  try
    Result := '';
    Clear;
    FmainI_.InitJson(S);
    FmainI := @FmainI_;
  except
    on e: exception do
      Result := e.Message;
  end;
end;

procedure TminiJson.PutB(const path: string; const Value: boolean);
begin
  FmainI^.B[path] := Value;
end;

procedure TminiJson.PutD(const path: string; const Value: Double);
begin
  FmainI^.D[path] := Value;
end;

procedure TminiJson.PutI(const path: string; const Value: Int64);
begin
  FmainI^.I[path] := Value;
end;

procedure TminiJson.SO;
begin
  FmainI_.Init();
  FmainI := @FmainI_;
end;

procedure TminiJson.SOA(const Args: array of const);
begin
  FmainI_.InitArray(Args);
  FmainI := @FmainI_;
end;

procedure TminiJson.SOS(const s: string);
begin
  FmainI_.InitJson(s);
  FmainI := @FmainI_;
end;


function TminiJson.SaveToFile(const FileName: string): string;
begin
  try
    FmainI^.SaveToJsonFile(FileName);
  except
    on e: exception do
      Result := e.Message;
  end;
end;

function TminiJson.SaveToStream(stream: TStream): string;
var
  SL: TStringlist;
begin
  try
    SL := TStringlist.Create;
    try
      SL.Text := FmainI^.ToJSON('', '', jsonEscapeUnicode);
      SL.SaveToStream(stream, TEncoding.UTF8);
    finally
      SL.Free;
    end;
  except
    on e: exception do
      Result := e.Message;
  end;
end;

procedure TminiJson.SetA(const path: string; const Value: TminiJson);
var
  Data: Variant;
begin
  if Value = nil then
    FmainI^.A_[path]^.AddItem(null)
  else
  begin
    TDocVariantData(Data).InitJSON(Value.AsJSon(true));
    FmainI^.A_[path]^.AddItem(Data);
    TDocVariantData(Data).Clear;
  end;
end;

procedure TminiJson.SetA_B(const path: string; const Value: boolean);
begin
  FmainI^.A_[path]^.AddItem(Value);
end;

procedure TminiJson.SetA_D(const path: string; const Value: double);
begin
  FmainI^.A_[path]^.AddItem(Value);
end;

procedure TminiJson.SetA_I(const path: string; const Value: Int64);
begin
  FmainI^.A_[path]^.AddItem(Value);
end;

procedure TminiJson.SetA_S(const path, Value: string);
begin
  FmainI^.A_[path]^.AddItem(Value);
end;

procedure TminiJson.SetmainI(const Value: PDocVariantData);
begin
  FmainI := Value;
end;

procedure TminiJson.SetO(const path: string; const Value: TminiJson);
var
  Data: Variant;
begin
  TDocVariantData(Data).InitJSON(Value.AsJSon(true));
  FmainI^.Value[path] := Data;
  TDocVariantData(Data).Clear;
end;

procedure TminiJson.SS(const path: string;  const Value: string);
begin
  FmainI^.s[path] := Value;
end;


{ TSearchRec }

constructor TSearchRec.Create;
begin
  FFindData := TWin32FindData.Create;
end;

destructor TSearchRec.Destroy;
begin
  FFindData.Free;
  inherited;
end;

procedure TSearchRec.SetAttr(const Value: Integer);
begin
  FAttr := Value;
end;

procedure TSearchRec.SetExcludeAttr(const Value: Integer);
begin
  FExcludeAttr := Value;
end;

procedure TSearchRec.SetFindData(const Value: TWin32FindData);
begin
  FFindData := Value;
end;

procedure TSearchRec.SetFindHandle(const Value: {$ifdef FINDHANDLE_IS_POINTER}Pointer{$else}THandle{$endif});
begin
  FFindHandle := Value;
end;

procedure TSearchRec.SetMode(AValue: integer);
begin
  if FMode=AValue then Exit;
  FMode:=AValue;
end;

procedure TSearchRec.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TSearchRec.SetSize(const Value: integer);
begin
  FSize := Value;
end;

procedure TSearchRec.SetTime(const Value: Integer);
begin
  FTime := Value;
end;

{ TWin32FindData }

constructor TWin32FindData.Create;
begin
  ftCreationTime := TFileTime.Create;
  ftLastAccessTime := TFileTime.Create;
  ftLastWriteTime := TFileTime.Create;
end;

destructor TWin32FindData.Destroy;
begin
  ftCreationTime.Free;
  ftLastAccessTime.Free;
  ftLastWriteTime.Free;
  inherited;
end;

procedure TWin32FindData.SetcAlternateFileName(const Value: string);
begin
  FcAlternateFileName := Value;
end;

procedure TWin32FindData.SetcFileName(const Value: string);
begin
  FcFileName := Value;
end;

procedure TWin32FindData.SetdwFileAttributes(const Value: {$ifdef FINDHANDLE_IS_POINTER}Pointer{$else}THandle{$endif});
begin
  FdwFileAttributes := Value;
end;

procedure TWin32FindData.SetdwReserved0(const Value: Cardinal);
begin
  FdwReserved0 := Value;
end;

procedure TWin32FindData.SetdwReserved1(const Value: Cardinal);
begin
  FdwReserved1 := Value;
end;

procedure TWin32FindData.SetftCreationTime(const Value: TFileTime);
begin
  FftCreationTime := Value;
end;

procedure TWin32FindData.SetftLastAccessTime(const Value: TFileTime);
begin
  FftLastAccessTime := Value;
end;

procedure TWin32FindData.SetftLastWriteTime(const Value: TFileTime);
begin
  FftLastWriteTime := Value;
end;

procedure TWin32FindData.SetnFileSizeHigh(const Value: Cardinal);
begin
  FnFileSizeHigh := Value;
end;

procedure TWin32FindData.SetnFileSizeLow(const Value: Cardinal);
begin
  FnFileSizeLow := Value;
end;

{ TFileTime }

procedure TFileTime.SetdwHighDateTime(const Value: Cardinal);
begin
  FdwHighDateTime := Value;
end;

procedure TFileTime.SetdwLowDateTime(const Value: Cardinal);
begin
  FdwLowDateTime := Value;
end;

end.
