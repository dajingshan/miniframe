
//////////////////////////////////////////////////////////////////////////////////
///                                                                            ///
///  miniframe开源Web框架技术群：821855479 如果加不了群，请联系QQ：3123827806  ///
///  网页制作器网址：https://wyeditor.com                                      ///
///  源码及demo下载：https://wyeditor.com/miniframe/                           ///
///                                                                            ///
//////////////////////////////////////////////////////////////////////////////////

unit minidb;

{$I PascalScript.inc}


interface

uses
  Classes, SysUtils, db, PubMathUnit, FmtBCD{$ifdef mswindows}, ActiveX{$endif} ,
  Uni, UniScript, SQLServerUniProvider, SQLiteUniProvider, VirtualTable;

type

  { TminiConnection }

  TminiConnection = class(TUniConnection)
  public
    procedure ConnBeforeConnect(Sender: TObject);
    procedure COnnConnAfterDisconnect(Sender: TObject);
  private
    FDbType: string;
    procedure SetDbType(const Value: string);
  public
    //打开连接
    function O(ConnStr: string; var ErrStr: string): boolean;
    function RepOpen(var ErrStr: string): boolean;

    //启动事务
    function StartTrans(var ErrStr: string): boolean;
    //回滚事务
    function Rollback(var ErrStr: string): boolean;
    //提交事务
    function Commit(var ErrStr: string): boolean;
    function DriverName: string;
    function GetDbType: string;
  published
    property InTransaction;
    property Connected;
    property DbType: string read GetDbType write SetDbType;
  end;

  { TminiQuery }

  TminiQuery = class(TUniQuery)
  public
    function Open(SQLText: string; var ErrStr: string): boolean;
    function O(SQLText: string; var ErrStr: string): boolean;
    function ExecSQL(SQLText: string; var ErrStr: string): boolean;
    function E(SQLText: string; var ErrStr: string): boolean;

    procedure S(FieldName, Value: string);
    function V(FieldName: string): string;
    function I(FieldName: string): integer;

    function F(FieldName: string): TField;
    function DataToStrs(FieldName: string): string;
  published
    property SQL;
    property RowsAffected;
  end;

  TminiMemTable = class(TVirtualTable)
  public
    function CopyDataSet(Ds: TminiQuery): string;
    function Open(var ErrStr: string): boolean;

    function SaveToFile(FileName: string; var ErrStr: string): boolean;
    function LoadFromFile(FileName: string; var ErrStr: string): boolean;

    function SaveToStream(Stream: TStream; var ErrStr: string): boolean;
    function LoadFromStream(Stream: TStream; var ErrStr: string): boolean;
  end;

  TminiStoredProc = class(TUniStoredProc)
  public
  end;

implementation

{ TminiQuery }

function TminiQuery.Open(SQLText: string; var ErrStr: string): boolean;
begin
  Result := false;
  Self.Close;
  Self.SQL.Text := SQLText;
  try
    inherited Open;
  except
    on e: exception do
    begin
      ErrStr := e.Message;
      exit;
    end;
  end;
  Result := true;
end;

function TminiQuery.O(SQLText: string; var ErrStr: string): boolean;
begin
  Result := Open(SQLText, ErrStr);
end;

function TminiQuery.ExecSQL(SQLText: string; var ErrStr: string): boolean;
begin
  Result := false;
  Self.Close;
  Self.SQL.Text := SQLText;
  try
    inherited ExecSQL;
  except
    on e: exception do
    begin
      ErrStr := e.Message;
      exit;
    end;
  end;
  Result := true;
end;

function TminiQuery.E(SQLText: string; var ErrStr: string): boolean;
begin
  Result := ExecSQL(SQLText, ErrStr);
end;

procedure TminiQuery.S(FieldName, Value: string);
begin
  FieldByName(FieldName).AsString := Value;
end;

function TminiQuery.V(FieldName: string): string;
var
  W: TBcd;
  DataType: TFieldType;
begin
  DataType := FieldByName(FieldName).DataType;
  if DataType = TFieldType.ftFloat then
  begin
    {$ifdef fpc}
    try
      Result := FormatFloat('0.0000000000', FieldByName(FieldName).AsFloat);
      Result := StrToFloat(Result).ToString;
    except
    end;
    {$else}
    Result := FieldByName(FieldName).AsString;
    {$endif}
  end else
  if DataType = TFieldType.ftFMTBcd then
  begin
    Result := BcdToStr(FieldByName(FieldName).AsBCD);
    {$ifdef fpc}
    while (Result <> '') and (Result[1] = '0') do
      Result := Copy(Result, 2, MaxInt);
    while (Result <> '') and (Result[length(Result)] = '0') do
      Result := Copy(Result, 1, length(Result) - 1);
    if (trim(Result) <> '') and (Result[length(Result)] = '.') then
      Result := Copy(Result, 1, length(Result) - 1);
    {$endif}
  end else
    Result := FieldByName(FieldName).AsString;
end;

function TminiQuery.I(FieldName: string): integer;
begin
  Result := FieldByName(FieldName).AsInteger;
end;

function TminiQuery.F(FieldName: string): TField;
begin
  Result := FieldByName(FieldName);
end;

function TminiQuery.DataToStrs(FieldName: string): string;
begin
  Result := '';
  TminiQuery(Self).First;
  while not TminiQuery(Self).Eof do
  begin
    Result := Result + #13#10 + TminiQuery(Self).FieldByName(FieldName).AsString;
    TminiQuery(Self).Next;
  end;
  Result := trim(Result);
end;

{ TminiConnection }

procedure TminiConnection.ConnBeforeConnect(Sender: TObject);
begin
  {$ifdef mswindows}
  if SameText(ProviderName,'SQL Server') then
    CoInitialize(nil);
  {$endif}
end;

procedure TminiConnection.ConnConnAfterDisconnect(Sender: TObject);
begin
  {$ifdef mswindows}
  if SameText(ProviderName,'SQL Server') then
    CoUninitialize;
  {$endif}
end;

function TminiConnection.O(ConnStr: string; var ErrStr: string): boolean;
begin
  Result := false;

  Self.close;
  Self.ConnectString := ConnStr;
  Self.SpecificOptions.Clear;
  Self.SpecificOptions.Add('SQL Server.Provider=prDirect'); //解决乱码
  try
    Self.Open;
  except
    on e: exception do
    begin
      ErrStr := e.Message;
      exit;
    end;
  end;
  Result := true;
end;

function TminiConnection.RepOpen(var ErrStr: string): boolean;
begin
  Result := true;
  if Self.Connected then exit;
  try
    Self.Open;
  except
    on e: exception do
    begin
      Result := false;
      ErrStr := e.Message;
      exit;
    end;
  end;
end;

procedure TminiConnection.SetDbType(const Value: string);
begin
  FDbType := Value;
end;

function TminiConnection.StartTrans(var ErrStr: string): boolean;
begin
  Result := false;
  try
    inherited StartTransaction;
  except
    on e: exception do
    begin
      ErrStr := e.Message;
      exit;
    end;
  end;
  Result := true;
end;

function TminiConnection.Rollback(var ErrStr: string): boolean;
begin
  Result := false;
  try
    inherited Rollback();
  except
    on e: exception do
    begin
      ErrStr := e.Message;
      exit;
    end;
  end;
  Result := true;
end;

function TminiConnection.Commit(var ErrStr: string): boolean;
begin
  Result := false;
  try
    inherited Commit;
  except
    on e: exception do
    begin
      ErrStr := e.Message;
      exit;
    end;
  end;
  Result := true;
end;

function TminiConnection.DriverName: string;
begin
  Result := Self.ProviderName;
end;

function TminiConnection.GetDbType: string;
begin
  Result := FDbType;
  if Result = '' then
    Result := Self.ProviderName;
end;

{ TminiMemTable }

function TminiMemTable.CopyDataSet(Ds: TminiQuery): string;
begin
  try
    AssignDataSet(Ds);
    inherited Open;
  except
    on e: exception do
      Result := e.Message;
  end;
end;

function TminiMemTable.LoadFromFile(FileName: string;
  var ErrStr: string): boolean;
begin
  Result := false;
  try
    inherited LoadFromFile(FileName);
  except
    on e: exception do
    begin
      ErrStr := e.Message;
      exit;
    end;
  end;
  if not Open(ErrStr) then exit;

  Result := true;
end;

function TminiMemTable.LoadFromStream(Stream: TStream;
  var ErrStr: string): boolean;
begin
  Result := false;
  try
    Stream.Position := 0;
    inherited LoadFromStream(Stream);
  except
    on e: exception do
    begin
      ErrStr := e.Message;
      exit;
    end;
  end;
  if not Open(ErrStr) then exit;
  Result := true;
end;

function TminiMemTable.Open(var ErrStr: string): boolean;
begin
  Result := false;
  try
    inherited Open;
  except
    on e: exception do
    begin
      ErrStr := e.Message;
      exit;
    end;
  end;
  Result := true;
end;

function TminiMemTable.SaveToFile(FileName: string;
  var ErrStr: string): boolean;
begin
  Result := false;
  try
    inherited SaveToFile(FileName);
  except
    on e: exception do
    begin
      ErrStr := e.Message;
      exit;
    end;
  end;
  Result := true;
end;

function TminiMemTable.SaveToStream(Stream: TStream;
  var ErrStr: string): boolean;
begin
  Result := false;
  try
    inherited SaveToStream(Stream);
  except
    on e: exception do
    begin
      ErrStr := e.Message;
      exit;
    end;
  end;
  Result := true;
end;

end.

