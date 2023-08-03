
//////////////////////////////////////////////////////////////////////////////////
///                                                                            ///
///  miniframe开源Web框架技术群：821855479 如果加不了群，请联系QQ：3123827806  ///
///  网页制作器网址：https://wyeditor.com                                      ///
///  源码及demo下载：https://wyeditor.com/miniframe/                           ///
///                                                                            ///
//////////////////////////////////////////////////////////////////////////////////

//注意：delphi 属性只能发布 published RegisterProperty('SessionName', 'string', iptR); 而laz public 就可以了
unit miniregister;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  Classes, SysUtils, uPSCompiler, uPSUtils, uPSRuntime, uPSC_classes, Math,
  Uni, UniScript, minidb, minihttp, IdCustomHTTPServer, DataPackageUnit, DateUtils, DB,
  MySQLUniProvider, OracleUniProvider, SQLServerUniProvider, SQLiteUniProvider, ODBCUniProvider,
  {$ifndef FPC}ActiveX,  Windows, Vcl.Graphics,System.NetEncoding,
   System.Zip, VCL.Imaging.Jpeg, VCL.Imaging.PngImage, VCL.Imaging.GIFImg
  {$else}streamex, zipper, Graphics, FPCanvas, IntfGraphics, lazcanvas{$endif}, PubSysUnit,
  Snowflake, PubFileUnit, uPSComponent_DB, uPSComponent, PubStringUnit, PubPWDUnit,
  PubMathUnit, minicomponents, TypInfo, minijson2dataset, mormot.core.base;
{$if defined(unix) or defined(msdos) or defined(hasamiga) or defined(atari) or defined(win16)}
    {$define FINDHANDLE_IS_POINTER}
{$endif}
{type
   TFDConnection = class(TminiConnection)
   end;
   TFDQuery = class(TminiQuery)
   end;
   TFDMemTable = class(TminiMemTable)
   end;}

procedure SIRegister_TUniConnection(Cl: TPSPascalCompiler);
procedure RIRegisterTUniConnection(Cl: TPSRuntimeClassImporter);

procedure SIRegisterTminiQuery(Cl: TPSPascalCompiler);
procedure RIRegisterTminiQuery(Cl: TPSRuntimeClassImporter);

procedure SIRegisterTminiTHTTP(Cl: TPSPascalCompiler);
procedure RIRegisterTminiTHTTP(Cl: TPSRuntimeClassImporter);

procedure SIRegister_THjhMemoryDataSet(Cl: TPSPascalCompiler);
procedure RIRegister_THjhMemoryDataSet(Cl: TPSRuntimeClassImporter);

procedure SIRegister_Json(Cl: TPSPascalCompiler);
procedure RIRegister_Json(Cl: TPSRuntimeClassImporter);

procedure SIRegister_Others(Cl: TPSPascalCompiler);
procedure RIRegister_Others(Cl: TPSRuntimeClassImporter);

procedure Register_functionOrProcedure(Sender: TPSScript);

implementation

uses miniscriptcontroller, mormothttps, miniPub, SelfDefine;


(*function TminiQuery_DataToStrs(Self: TminiQuery; FieldName: string): string;
begin                   e
  Result := '';
  TminiQuery(Self).First;
  while not TminiQuery(Self).Eof do
  begin
    Result := Result + #13#10 + TminiQuery(Self).FieldByName(FieldName).AsString;
    TminiQuery(Self).Next;
  end;
  Result := trim(Result);
end;*)


procedure TFieldDefsItemsR(Self: TFieldDefs; var T: TFieldDef; I: integer);
begin
  T := Self.Items[I];
end;
procedure TFieldDefsItemsW(Self: TFieldDefs; var T: TFieldDef; I: integer);
begin
  Self.Items[I]:= T;
end;

procedure TFieldDefsClear(Self: TFieldDefs);
begin
  Self.Clear;
end;

procedure TFieldDefsAdd(Self: TFieldDefs; const AName: string; ADataType: TFieldType; ASize: Word; ARequired: Boolean);
begin
  Self.Add(AName, ADataType, ASize, ARequired);
end;

procedure RIRegisterTminiQuery(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TFieldDefs) do
  begin
    RegisterMethod(@TFieldDefsClear, 'Clear');
    RegisterMethod(@TFieldDefs.AddFieldDef, 'AddFieldDef');
    RegisterMethod(@TFieldDefs.Find, 'Find');
    RegisterMethod(@TFieldDefsAdd, 'Add');
    RegisterPropertyHelper(@TFieldDefsItemsR, @TFieldDefsItemsW, 'Items');
  end;

  with Cl.Add(TminiMemTable) do
  begin
    RegisterMethod(@TminiMemTable.CopyDataSet, 'CopyDataSet');
    RegisterMethod(@TminiMemTable.Open, 'Open');

    RegisterMethod(@TminiMemTable.SaveToFile, 'SaveToFile');
    RegisterMethod(@TminiMemTable.LoadFromFile, 'LoadFromFile');
    RegisterMethod(@TminiMemTable.SaveToStream, 'SaveToStream');
    RegisterMethod(@TminiMemTable.LoadFromStream, 'LoadFromStream');
    {

        RegisterMethod('function SaveToFile(FileName: string; var ErrStr: string): boolean');
    RegisterMethod('function LoadFromFile(FileName: string; var ErrStr: string): boolean');
    RegisterMethod('function SaveToStream(Stream: TStream; var ErrStr: string): boolean');
    RegisterMethod('function LoadFromStream(Stream: TStream; var ErrStr: string): boolean');
    }
  end;
  {with Cl.Add(TFDMemTable) do
  begin
  end;}

  with Cl.Add(TminiQuery) do
  begin
    {$IFDEF DELPHI4UP}
    RegisterVirtualConstructor(@TminiQuery.CREATENEW, 'CreateNew');  l
    {$ELSE}
    RegisterConstructor(@TminiQuery.Create, 'Create');
    {$ENDIF}
    RegisterMethod(@TminiQuery.Open, 'Open');
    RegisterMethod(@TminiQuery.Open, 'O');
    RegisterMethod(@TminiQuery.ExecSQL, 'ExecSQL');
    RegisterMethod(@TminiQuery.ExecSQL, 'E');

    RegisterMethod(@TminiQuery.S, 'S'); //读取字符串
    RegisterMethod(@TminiQuery.V, 'V'); //设置值
    RegisterMethod(@TminiQuery.I, 'I'); //读取整形数
    RegisterMethod(@TminiQuery.F, 'F'); //获取字段，相应于fieldbyname

    RegisterMethod(@TminiQuery.DataToStrs, 'DataToStrs');
        {

    procedure S(FieldName, Value: string);
    function V(FieldName: string): string;
    function I(FieldName: string): integer;

    function F(FieldName: string): TField;
    }

    //RegisterPropertyHelperName(@TminiQueryConnection_R, @TminiQueryConnection_W, 'Connection');
  end;
end;

procedure SIRegisterTminiQuery(Cl: TPSPascalCompiler);
begin
  {with Cl.FindClass('TField') do
  begin
    RegisterProperty('AsDateTime', 'TDateTime', iptrw);
  end;}
  with Cl.AddClassN(cl.FindClass('TDATASET'), 'TminiQuery') do
  begin
    {$IFDEF DELPHI4UP}
    RegisterMethod('constructor Create(AOwner: TComponent; Dummy: Integer)');
    {$ELSE}
    RegisterMethod('constructor Create(AOwner: TComponent)');
    {$ENDIF}

    RegisterMethod('function Open(SQLText: string; var ErrStr: string): boolean');
    RegisterMethod('function O(SQLText: string; var ErrStr: string): boolean');
    RegisterMethod('function ExecSQL(SQLText: string; var ErrStr: string): boolean');
    RegisterMethod('function E(SQLText: string; var ErrStr: string): boolean');

    RegisterMethod('procedure S(FieldName, Value: string)');
    RegisterMethod('function V(FieldName: string): string');
    RegisterMethod('function I(FieldName: string): integer');
    RegisterMethod('function F(FieldName: string): TField');

    RegisterProperty('Connection', 'TminiConnection', iptrw);
    //property SQL: TStrings read GetSQL write SetSQL;
    RegisterProperty('SQL', 'TStrings', iptr);
    RegisterProperty('RowsAffected', 'integer', iptr);
    RegisterMethod('function DataToStrs(FieldName: string): string');
  end;

  with Cl.AddClassN(cl.FindClass('TCollection'), 'TFieldDefs') do
  begin
    RegisterMethod('procedure Clear');
    RegisterMethod('function AddFieldDef: TFieldDef');
    RegisterMethod('function Find(const Name: string): TFieldDef');
    //RegisterMethod('procedure Add(const Name: string; DataType: TFieldType; Size: Integer = 0;Required: Boolean = False)');
    RegisterMethod('procedure Add(const Name: string; DataType: TFieldType; Size: Integer;Required: Boolean)');
    RegisterProperty('Items', 'TFieldDef integer', iptRW);
    SetDefaultPropery('Items');
  end;

  with Cl.AddClassN(cl.FindClass('TminiQuery'), 'TminiMemTable') do
  begin
    RegisterMethod('function CopyDataSet(Ds: TminiQuery): string');
    RegisterMethod('function Open(var ErrStr: string): boolean');

    RegisterMethod('function SaveToFile(FileName: string; var ErrStr: string): boolean');
    RegisterMethod('function LoadFromFile(FileName: string; var ErrStr: string): boolean');
    RegisterMethod('function SaveToStream(Stream: TStream; var ErrStr: string): boolean');
    RegisterMethod('function LoadFromStream(Stream: TStream; var ErrStr: string): boolean');

    RegisterProperty('FieldDefs', 'TFieldDefs', iptRW);
  end;
end;

procedure TminiSessionValuesR(Self: TminiSession; var T: string; const I: string);
begin
  T := Self.Values[I];
end;
procedure TminiSessionValuesW(Self: TminiSession; Const T, I: String);
begin
  Self.Values[I]:= T;
end;

procedure TPubZTCodeR(Self: TPub; var T: string);
begin
  T := Self.ZTCode;
end;
procedure TPubZTCodeW(Self: TPub; Const T: String);
begin
  Self.ZTCode:= T;
end;

procedure TminiHTTPRequest_NewSession(Self: TminiHTTPRequest);
begin
  if Self = nil then exit;
  TKing_HttpApiServer.CreateSession(Self.Response, Self.Response.SessionTimeout);
end;

procedure SaveSession;
begin
  {//2022-06-24 add
  WSessions.SessionList.LockList;
  try
    try
      WSessions.SaveToFile(ExtractFilePath(ParamStr(0)) + 'sessions.ini');
    except
    end;
  finally
    WSessions.SessionList.UnlockList;
  end;}
end;

procedure TminiHTTPRequest_SaveSession(Self: TminiHTTPRequest);
begin
  if Self = nil then exit;
  SaveSession;
end;

procedure TminiHTTPRequest_Login(Self: TminiHTTPRequest; Logined: string);
begin
  if Self.Session = nil then exit;
  Self.Session.Values[Logined] := '1';
  Self.Session.Values[Logined + 'Time'] := DateTimeToStr(Now);
end;

procedure TminiHTTPRequest_Logout(Self: TminiHTTPRequest; Logined: string);
begin
  if Self.Session = nil then exit;
  Self.Session.Values[Logined] := '0';
end;

function TminiHTTPRequest_IsLogin(Self: TminiHTTPRequest; Logined: string): boolean;
begin
  Result := false;
  if Self.Session = nil then exit;
  Result := Self.Session.Values[Logined] = '1';
end;

function TminiHTTPRequest_LoginTime(Self: TminiHTTPRequest; Logined: string): string;
begin
  Result := '';
  if Self.Session = nil then exit;
  Result := Self.Session.Values[Logined + 'Time'];
end;


procedure RIRegisterTminiTHTTP(Cl: TPSRuntimeClassImporter);
var
  PSRuntimeClass: TPSRuntimeClass;
begin

  with Cl.Add(TminiHTTPRequest) do
  begin
    //RegisterConstructor(@TminiHTTPRequest.Create, 'Create');
    RegisterMethod(@TminiHTTPRequest_NewSession, 'NewSession');
    RegisterMethod(@TminiHTTPRequest_SaveSession, 'SaveSession');

    RegisterMethod(@TminiHTTPRequest_Login, 'Login');
    RegisterMethod(@TminiHTTPRequest_Logout, 'Logout');
    RegisterMethod(@TminiHTTPRequest_IsLogin, 'IsLogin');
    RegisterMethod(@TminiHTTPRequest_LoginTime, 'LoginTime');
    RegisterMethod(@TminiHTTPRequest.V, 'V');

    RegisterMethod(@TminiHTTPRequest.DecodeFJ, 'DecodeFJ');
    RegisterMethod(@TminiHTTPRequest.DecodeFJ2, 'DecodeFJ2');
    RegisterMethod(@TminiHTTPRequest.ParamsToURL, 'ParamsToURL');
  end;

  with Cl.Add(TminiHTTPResponse) do
  begin
    RegisterMethod(@TminiHTTPResponse.Redirect, 'Redirect');
    RegisterMethod(@TminiHTTPResponse.Clear, 'Clear');
    RegisterMethod(@TminiHTTPResponse.SendFileToClient, 'SendFileToClient'); //发送文件到客户端
  end;

  with Cl.Add(TminiSession) do
  begin
    RegisterPropertyHelper(@TminiSessionValuesR, @TminiSessionValuesW, 'Values');
  end;

  with Cl.Add(TminiPooler) do
  begin
    RegisterMethod(@TminiPooler.TmpSl, 'TmpSl');

    RegisterMethod(@TminiPooler.Conn, 'Conn');
    RegisterMethod(@TminiPooler.Query, 'Query');
    RegisterMethod(@TminiPooler.DBName, 'DBName');
    RegisterMethod(@TminiPooler.DBType, 'DBType');
    RegisterMethod(@TminiPooler.mds, 'mds');
  end;

  PSRuntimeClass := Cl.Add(TPub);
  with PSRuntimeClass do
  begin
    //注册创建系统管理的对象，Create开头的原始调用，Get开头的快捷调用，都一样的----实现
    RegisterMethod(@TPub.CreateStringlist, 'CreateStringlist');
    RegisterMethod(@TPub.CreateStringlist, 'GetSL');
    RegisterMethod(@TPub.CreateConn, 'CreateConn');
    RegisterMethod(@TPub.CreateConn, 'GetConn');
    RegisterMethod(@TPub.CreateQuery, 'CreateQuery');
    RegisterMethod(@TPub.CreateQuery, 'GetQuery');
    RegisterMethod(@TPub.CreateMemTable, 'CreateMemTable');
    RegisterMethod(@TPub.CreateMemTable, 'GetMT');
    RegisterMethod(@TPub.CreateMemoryDataSet, 'CreateMemoryDataSet');
    RegisterMethod(@TPub.CreateMemoryDataSet, 'GetDS');
    RegisterMethod(@TPub.CreateJson, 'GetJson');
    RegisterMethod(@TPub.CreateJson, 'CreateJson');
    RegisterMethod(@TPub.CreateMemoryStream, 'CreateMemoryStream');
    RegisterMethod(@TPub.CreateMemoryStream, 'GetMs');
    RegisterMethod(@TPub.CreateStoredProc, 'CreateStoredProc');
    RegisterMethod(@TPub.CreateStoredProc, 'GetSP');
    RegisterMethod(@TPub.CreateFileStream, 'CreateFileStream');
    RegisterMethod(@TPub.CreateFileStream, 'GetFS');

    //注册系统缓冲池中的对象----实现
    RegisterMethod(@TPub.TmpSl, 'TmpSl');
    RegisterMethod(@TPub.Conn, 'Conn');
    RegisterMethod(@TPub.Query, 'Query');
    RegisterMethod(@TPub.mds, 'mds');


    RegisterMethod(@TPub.DBName, 'DBName');
    RegisterMethod(@TPub.DBType, 'DBType');
    RegisterPropertyHelper(@TPubZTCodeR, @TPubZTCodeW, 'ZTCode');

    //这样获取连接池实例，将不受是否停用影响
    RegisterMethod(@TPub.GetConnPooler, 'GetConnPooler');
    RegisterMethod(@TPub.GetConnPoolerEx, 'GetConnPoolerEx');
    RegisterMethod(@TPub.DB_C, 'DB_C');
    RegisterMethod(@TPub.DB_E, 'DB_E');
    RegisterMethod(@TPub.DB_E, 'DB_Exec');
    RegisterMethod(@TPub.DB_O, 'DB_O');
    RegisterMethod(@TPub.DB_O, 'DB_Open');
    RegisterMethod(@TPub.O, 'O');
    RegisterMethod(@TPub.DB_OMT, 'DB_OMT');
    RegisterMethod(@TPub.DB_OMT, 'DB_OpenMT');
    RegisterMethod(@TPub.DB_ODS, 'DB_ODS');
    RegisterMethod(@TPub.DB_ODS, 'DB_OpenDS');
    //RegisterMethod(@TPub.DB_ETEx, 'DB_ETEx');
    RegisterMethod(@TPub.DB_OT, 'DB_OT');
    RegisterMethod(@TPub.DB_OT, 'DB_OpenTo');
    RegisterMethod(@TPub.SetStartTime, 'SetStartTime');
    RegisterMethod(@TPub.TestConnect, 'TestConnect');
  end;
  TPub.RIRegister_Body(PSRuntimeClass);
end;

procedure SIRegister_THjhMemoryDataSet(Cl: TPSPascalCompiler);
begin
  with Cl.AddClassN(cl.FindClass('TObject'), 'TMField') do
  begin
    RegisterProperty('DataType', 'TFieldType', iptRW);
    RegisterProperty('FieldName', 'string', iptRW);
    RegisterProperty('ParentFields', 'TMFields', iptRW);
    RegisterProperty('CurPos', 'integer', iptRW);
    RegisterProperty('FieldNo', 'integer', iptRW);
    RegisterProperty('CommaText', 'string', iptRW);
    RegisterProperty('Text', 'string', iptRW);
    RegisterProperty('AsCurrency', 'Currency', iptRW);
    RegisterProperty('AsDateTime', 'TDateTime', iptRW);
    RegisterProperty('AsDate', 'TDate', iptRW);
    RegisterProperty('AsTime', 'TTime', iptRW);
    RegisterProperty('AsFloat', 'double', iptRW);
    RegisterProperty('AsInteger', 'Longint', iptRW);
    RegisterProperty('AsString', 'string', iptRW);

    RegisterMethod('function BlobLoadFromFile(const FileName: string; var ErrStr: string): boolean');
    RegisterMethod('function BlobLoadFromStream(Stream: TMemoryStream; var ErrStr: string): boolean');
    RegisterMethod('function BlobSaveToFile(const FileName: string; var ErrStr: string): boolean');
    RegisterMethod('function BlobSaveToStream(Stream: TStream; var ErrStr: string): boolean');

  end;

  with Cl.AddClassN(cl.FindClass('TObject'), 'TMFields') do
  begin
    RegisterProperty('integer', 'integer', iptR);
    RegisterProperty('Count', 'integer', iptR);
    RegisterProperty('FieldList', 'string', iptRW);
    RegisterProperty('Fields', 'TMField integer', iptRW);
    SetDefaultPropery('Fields');

    RegisterMethod('function IndexOf(Field: TMField): Integer');
    RegisterMethod('procedure Remove(Field: TMField)');
    RegisterMethod('procedure Delete(FieldName: string)');
    RegisterMethod('procedure Add(const FieldName: string; DataType: TFieldType)');
    RegisterMethod('procedure Clear;');
    RegisterMethod('function FieldByNumber(FieldNo: Integer): TMField');
    RegisterMethod('function FieldByName(const FieldName: string): TMField');
    RegisterMethod('function FindField(const FieldName: string): TMField');
  end;
  {
  property Count: Integer read GetCount;
    property FieldList: string read GetFieldList write SetFieldList;
  }
  with Cl.AddClassN(cl.FindClass('TObject'), 'THjhMemoryDataSet') do
  begin
    RegisterMethod('constructor Create(AOwner: TComponent)');
    RegisterProperty('DataSet', 'TDataSet', iptRW);

    ////////////////////////////////////////////////////////////
    RegisterProperty('CurRecordPos', 'integer', iptRW);
    RegisterProperty('CurPos', 'integer', iptRW);
    RegisterProperty('Items', 'TMFields integer', iptRW);
    RegisterProperty('CommaText', 'string', iptRW);
    RegisterProperty('Records', 'Variant integer string', iptRW);
    RegisterProperty('Eof', 'boolean', iptR);
    RegisterProperty('Bof', 'boolean', iptR);
    RegisterProperty('RecordCount', 'integer', iptR);
    RegisterProperty('Fields', 'TMFields', iptR);
    RegisterProperty('BlobToBase64', 'boolean', iptRW);

    //RegisterHeader(G, 'constructor Create(AOwner: TComponent);', @THjhMemoryDataSet.Create);
    RegisterMethod('function FieldByName(const FieldName: string): TMField;');
    RegisterMethod('function FindField(const FieldName: string): TMField;');
    RegisterMethod('function V(const FieldName: string): string;');
    //RegisterMethod('procedure Open;');
    RegisterMethod('function RecNo: integer;');

    RegisterMethod('procedure S(const FieldName, Value: string);');
    RegisterMethod('procedure Append;');
    RegisterMethod('procedure First;');
    RegisterMethod('procedure Next;');
    RegisterMethod('procedure Prior;');
    RegisterMethod('procedure Last;');
    RegisterMethod('procedure Delete;');
    RegisterMethod('procedure Go(index: integer);');
    RegisterMethod('procedure Insert(index: integer);');

    //RegisterMethod('procedure _WriteCurRecordPos(const Value: integer);');
    //RegisterMethod('function _GetCurRecordPos: integer;');

    RegisterMethod('procedure Clear;');
    RegisterMethod('procedure ClearData;');

    RegisterMethod('procedure Open;');
    RegisterMethod('procedure OpenData;');
    RegisterMethod('procedure OpenFields;');

    RegisterMethod('procedure CopyOneRecord(SourMds: THjhMemoryDataset);');
    RegisterMethod('procedure CopyOneRecord_Ds(SourCds: TDataset);');
    RegisterMethod('procedure CopyToOneRecord(SourCds: TDataset);');

    RegisterMethod('function SaveToFile(const FileName: string; var ErrStr: string): boolean');
    RegisterMethod('function SaveToStream(Stream: TStream; var ErrStr: string): boolean');

    RegisterMethod('function LoadFromFile(const FileName: string; var ErrStr: string): boolean');
    RegisterMethod('function LoadFromStream(Stream: TStream; var ErrStr: string): boolean');

  end;
end;
procedure THjhMemoryDataSet_CopyOneRecord_Ds(Self: THjhMemoryDataSet; SourCds: TDataset);
begin
  Self.CopyOneRecord(SourCds);
end;

function THjhMemoryDataSet_RecNo(Self: THjhMemoryDataSet): integer;
begin
  if Self = nil then exit;
  Result := Self.CurRecordPos;
end;

procedure THjhMemoryDataSetItemsR(Self: THjhMemoryDataSet; var T: TMFields; I: integer);
begin
  T := Self.Items[I];
end;
                                                                    //Variant integer string
procedure THjhMemoryDataSetRecordsR(Self: THjhMemoryDataSet; var T: Variant; I: integer; FieldName: string);
begin
  T := Self.Records[I, Fieldname];
end;

procedure TMFieldsFieldsR(Self: TMFields; var T: TMField; const I: integer);
begin
  T := Self[I];
end;
procedure TMFieldsFieldsW(Self: TMFields; Const T: TMField; I: integer);
begin
  Self[I]:= T;
end;

{//THjhMemoryDataSet_DatasetR, @THjhMemoryDataSet_DatasetW
procedure THjhMemoryDataSet_DatasetR(Self: THjhMemoryDataSet; var T: TDataset);
begin
  T := Self.DataSet;
end;

procedure THjhMemoryDataSet_DatasetW(Self: THjhMemoryDataSet; T: TDataset);
begin
  Self.DataSet := T;
end;}

procedure RIRegister_THjhMemoryDataSet(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TMField) do
  begin
    RegisterMethod(@TMField.BlobLoadFromFile, 'BlobLoadFromFile');
    RegisterMethod(@TMField.BlobLoadFromStream, 'BlobLoadFromStream');
    RegisterMethod(@TMField.BlobSaveToFile, 'BlobSaveToFile');
    RegisterMethod(@TMField.BlobSaveToStream, 'BlobSaveToStream');
  end;

  with Cl.Add(TMFields) do
  begin //property Fields[Index: Integer]: TMField read GetField write SetField; default;
    RegisterPropertyHelper(@TMFieldsFieldsR, @TMFieldsFieldsW, 'Fields');

    RegisterMethod(@TMFields.IndexOf, 'IndexOf');
    RegisterMethod(@TMFields.Remove, 'Remove');
    RegisterMethod(@TMFields.Delete, 'Delete');
    RegisterMethod(@TMFields.Add, 'Add');
    RegisterMethod(@TMFields.Clear, 'Clear');
    RegisterMethod(@TMFields.FieldByNumber, 'FieldByNumber');
    RegisterMethod(@TMFields.FieldByName, 'FieldByName');
    RegisterMethod(@TMFields.FindField, 'FindField');


  end;
  {

      RegisterMethod('function (Field: TMField): Integer');
    RegisterMethod('procedure (Field: TMField)');
    RegisterMethod('procedure (FieldName: string)');
    RegisterMethod('procedure (const FieldName: string; DataType: TFieldType)');
    RegisterMethod('procedure ;');
    RegisterMethod('function (FieldNo: Integer): TMField');
    RegisterMethod('function (const FieldName: string): TMField');
    RegisterMethod('function (const FieldName: string): TMField');

  }

  with Cl.Add(THjhMemoryDataSet) do
  begin
    RegisterConstructor(@THjhMemoryDataSet.Create, 'Create');
    RegisterMethod(@THjhMemoryDataSet.FieldByName, 'FieldByName');
    RegisterMethod(@THjhMemoryDataSet.FindField, 'FindField');

    //RegisterPropertyHelper(@THjhMemoryDataSet_DatasetR, @THjhMemoryDataSet_DatasetW, 'Dataset');
    RegisterPropertyHelper(@THjhMemoryDataSetItemsR, nil, 'Items');
    RegisterPropertyHelper(@THjhMemoryDataSetRecordsR, nil, 'Records');
    RegisterMethod(@THjhMemoryDataSet.V, 'V');
    RegisterMethod(@THjhMemoryDataSet_RecNo, 'RecNo');
    RegisterMethod(@THjhMemoryDataSet.S, 'S');
    RegisterMethod(@THjhMemoryDataSet.Append, 'Append');
    RegisterMethod(@THjhMemoryDataSet.First, 'First');
    RegisterMethod(@THjhMemoryDataSet.Next, 'Next');
    RegisterMethod(@THjhMemoryDataSet.Prior, 'Prior');
    RegisterMethod(@THjhMemoryDataSet.Last, 'Last');
    RegisterMethod(@THjhMemoryDataSet.Delete, 'Delete');
    RegisterMethod(@THjhMemoryDataSet.Go, 'Go');
    RegisterMethod(@THjhMemoryDataSet.Insert, 'Insert');

    RegisterMethod(@THjhMemoryDataSet.Clear, 'Clear');
    RegisterMethod(@THjhMemoryDataSet.ClearData, 'ClearData');
    RegisterMethod(@THjhMemoryDataSet.Open, 'Open');
    RegisterMethod(@THjhMemoryDataSet.OpenData, 'OpenData');
    RegisterMethod(@THjhMemoryDataSet.OpenFields, 'OpenFields');

    RegisterMethod(@THjhMemoryDataSet.CopyOneRecord, 'CopyOneRecord');
    RegisterMethod(@THjhMemoryDataSet_CopyOneRecord_Ds, 'CopyOneRecord_Ds');
    RegisterMethod(@THjhMemoryDataSet.CopyToOneRecord, 'CopyToOneRecord');
    RegisterMethod(@THjhMemoryDataSet.SaveToFile, 'SaveToFile');
    RegisterMethod(@THjhMemoryDataSet.LoadFromFile, 'LoadFromFile');
    RegisterMethod(@THjhMemoryDataSet.SaveToStream, 'SaveToStream');
    RegisterMethod(@THjhMemoryDataSet.LoadFromStream, 'LoadFromStream');
  end;

  {with Cl.Add(TFDConnection) do
  begin
  end;}
end;

procedure SIRegisterTminiTHTTP(Cl: TPSPascalCompiler);
var
  PSCompileTimeClass: TPSCompileTimeClass;
begin

  with Cl.AddClassN(cl.FindClass('TObject'), 'TminiSession') do
  begin
    RegisterProperty('SessionID', 'string', iptR);
    RegisterProperty('SessionName', 'string', iptR);
    RegisterProperty('Content', 'TStrings', iptR);
    RegisterProperty('Values', 'string string', iptRW);
    SetDefaultPropery('Values');
  end;

  with Cl.AddClassN(cl.FindClass('TObject'), 'TminiHTTPRequest') do
  begin
    RegisterProperty('RemoteIP', 'string', iptR);
    RegisterProperty('Host', 'string', iptR);
    RegisterProperty('Port', 'string', iptR);
    RegisterProperty('Document', 'string', iptR);
    RegisterProperty('URI', 'string', iptR);
    RegisterProperty('URL', 'string', iptR);
    RegisterProperty('Params', 'TStrings', iptR);

    RegisterProperty('ContentType', 'string', iptR);
    RegisterProperty('ContentText', 'string', iptR);
    RegisterProperty('Method', 'string', iptR);
    RegisterProperty('Accept', 'string', iptR);
    RegisterProperty('AcceptCharSet', 'string', iptR);

    RegisterProperty('AcceptEncoding', 'string', iptR);
    RegisterProperty('AcceptLanguage', 'string', iptR);
    RegisterProperty('From', 'string', iptR);
    RegisterProperty('Referer', 'string', iptR);
    RegisterProperty('UserAgent', 'string', iptR);
    RegisterProperty('Session', 'TminiSession', iptR);
    RegisterProperty('PostedData_mORMot', 'string', iptR);
    RegisterProperty('PostedData', 'string', iptR);
    RegisterProperty('PostStream', 'TMemoryStream', iptR);
    RegisterProperty('Response', 'TminiHTTPResponse', iptR);
    RegisterProperty('QueryParams', 'string', iptR);
    RegisterProperty('InHeaders', 'string', iptR);
    RegisterProperty('Headers', 'TStrings', iptR);
    RegisterProperty('Cookie', 'string', iptR);
    RegisterProperty('AuthBearer', 'string', iptR);
    RegisterProperty('AuthenticatedUser', 'string', iptR);
    //RegisterProperty('AuthenticationStatus', 'THttpServerRequestAuthentication', iptR);
    RegisterProperty('Service_Path', 'string', iptR);
    RegisterProperty('Service_FileName', 'string', iptR);
    RegisterProperty('Remote_FileName', 'string', iptR);
    RegisterProperty('SessionID', 'string', iptR);

    RegisterMethod('function V(const FieldName: string): string;');
    RegisterMethod('procedure NewSession;');
    RegisterMethod('procedure SaveSession;');
    RegisterMethod('procedure Login(Logined: string);');
    RegisterMethod('procedure Logout(Logined: string);');
    RegisterMethod('function IsLogin(Logined: string): boolean;');
    RegisterMethod('function LoginTime(Logined: string): string;');

    RegisterMethod('function DecodeFJ(Path: string): boolean;');
    RegisterMethod('function DecodeFJ2(Path: string; NeedRandomFileName: boolean; NeedFileMd5: boolean): boolean;');
    RegisterMethod('function ParamsToURL: string;');
  end;

  with Cl.AddClassN(cl.FindClass('TminiHTTPResponse'), 'TminiHTTPResponse') do
  begin
    RegisterProperty('Request', 'TminiHTTPRequest', iptr);
    RegisterProperty('ContentStream', 'TStream', iptRW);
    RegisterProperty('FreeContentStream', 'boolean', iptRW);
    RegisterProperty('ContentType', 'string', iptRW);
    RegisterMethod('procedure Redirect(const Url: string);');
    RegisterMethod('procedure Clear();');
    RegisterMethod('procedure SendFileToClient(FileName: string);');
  end; //}
  //{
  with Cl.AddClassN(cl.FindClass('TObject'), 'TminiPooler') do
  begin
    RegisterMethod('function function TmpSl: TStringList');
    RegisterMethod('function Conn: TminiConnection');
    RegisterMethod('function Query: TminiQuery');
    RegisterMethod('function MemTable: TminiMemTable');
    RegisterMethod('function StoredProc: TminiStoredProc');
    RegisterMethod('function DBName: string');
    RegisterMethod('function DBType: string');
    RegisterMethod('function mds: THjhMemoryDataSet');
    RegisterProperty('HadUsed', 'boolean', iptRW);
  end;
  with Cl.AddClassN(cl.FindClass('TminiPooler'), 'TConnPooledInfo') do
  begin

  end;
  {with Cl.AddClassN(cl.FindClass('TObject'), 'TConnPooledInfo') do
  begin
    ///RegisterProperty('FDConnection1', 'TFDConnection', iptR);
    RegisterMethod('function FDConnection1: TFDConnection');
  end;}
  PSCompileTimeClass := Cl.AddClassN(cl.FindClass('TObject'), 'TPub');
  with PSCompileTimeClass do
  begin
    //注册创建系统管理的对象，Create开头的原始调用，Get开头的快捷调用，都一样的--定义头部
    RegisterMethod('function CreateStringlist: TStringlist');
    RegisterMethod('function GetSL: TStringlist');

    RegisterMethod('function CreateMemTable: TminiMemTable');
    RegisterMethod('function GetMT: TminiMemTable');

    RegisterMethod('function CreateMemoryStream: TMemoryStream');
    RegisterMethod('function GetMs: TMemoryStream');

    RegisterMethod('function CreateFileStream(FileName: string; Mode: Integer; Var ErrStr: String): TFileStream');
    RegisterMethod('function GetFS(FileName: string; Mode: Integer; Var ErrStr: String): TFileStream');

    RegisterMethod('function CreateMemoryDataSet: THjhMemoryDataSet');
    RegisterMethod('function GetDS: THjhMemoryDataSet');

    RegisterMethod('function CreateJson: TminiJson');
    RegisterMethod('function GetJson: TminiJson');

    RegisterMethod('function CreateConn: TminiConnection');
    RegisterMethod('function GetConn: TminiConnection');

    RegisterMethod('function CreateQuery: TminiQuery');
    RegisterMethod('function GetQuery: TminiQuery');

    RegisterMethod('function CreateStoredProc: TminiStoredProc');
    RegisterMethod('function GetSp: TminiStoredProc');

    //注册系统缓冲池中的对象----定义头部
    RegisterMethod('function TmpSl: TStringList');
    RegisterMethod('function Conn: TminiConnection');
    RegisterMethod('function Query: TminiQuery');
    RegisterMethod('function mds: THjhMemoryDataSet');

    RegisterMethod('function DBName: string'); //数据库名
    RegisterMethod('function DBType: string'); //数据类型


    //账套编码, 用账套编码进行数据连接
    RegisterProperty('ZTCode', 'string', iptRW);

    //这样获取连接池实例，将受是否停用影响
    RegisterMethod('function GetConnPooler(AZTCode: string): TminiPooler');
    //这样获取连接池实例，将受是否停用影响
    RegisterMethod('function GetConnPoolerEx(AZTCode: string; var ErrStr: string): TminiPooler');

    //连接到数据库
    RegisterMethod('function DB_C(AZTCode: string; var ErrStr: string): boolean');
    //执行一条SQL
    RegisterMethod('function DB_E(SQLText: string; var ErrStr: string; AZTCode: string): boolean');
    RegisterMethod('function DB_Exec(SQLText: string; var ErrStr: string; AZTCode: string): boolean');
    //打开数据集，数据返回到Query中
    RegisterMethod('function DB_O(SQLText: string; var ErrStr: string; AZTCode: string): boolean');
    RegisterMethod('function DB_Open(SQLText: string; var ErrStr: string; AZTCode: string): boolean');
    RegisterMethod('function O(AZTCode: string; var PooledInfo: TminiPooler; var Query: TminiQuery; var ErrStr: string): boolean');
    //打开数据集，数据返回到miniMemTable中
    RegisterMethod('function DB_OMT(SQLText: string; var ErrStr: string; Mt1: TminiMemTable; AZTCode: string): boolean');
    RegisterMethod('function DB_OpenMT(SQLText: string; var ErrStr: string; Mt1: TminiMemTable; AZTCode: string): boolean');
    //执行一条SQL，把SQL语句返回的数据集生成到临时或固定表中，考虑了兼容不同的数据库问题
    //RegisterMethod('function DB_ETEx(TableName, SQLText: string; IsTmpTBL: boolean; var ErrStr: string; Query1: TminiQuery): boolean');
    RegisterMethod('function DB_OT(SQLText, TableName: string; IsTmpTBL: boolean; var ErrStr: string; AZTCode: string): boolean');
    RegisterMethod('function DB_OpenTo(SQLText, TableName: string; IsTmpTBL: boolean; var ErrStr: string; AZTCode: string): boolean');

    //执行一条SQL，打开数据集，数据返回到THJHMemoryDataSet中
    RegisterMethod('function DB_ODS(SQLText: string; var ErrStr: string; ds: THjhMemoryDataSet; AZTCode: string): boolean');
    RegisterMethod('function DB_OpenDS(SQLText: string; var ErrStr: string; ds: THjhMemoryDataSet; AZTCode: string): boolean');
    RegisterMethod('procedure SetStartTime');
    //测试连接
    RegisterMethod('function TestConnect(IP, DbType, DBName, User, Pwd: string): string');

  end; //}
  TPub.SIRegister_Head(PSCompileTimeClass);
end;

function CreateTUniConnection: TminiConnection;
begin
  Result := TminiConnection.Create(nil);
end;

//procedure TStringsSQL_W(Self: TminiConnection; T: TUniSQL); begin {Self.SQL := T}; end;
//procedure TStringsSQL_R(Self: TminiConnection; var T: TUniSQL); begin T := Self.SQL; end;

procedure RIRegisterTUniConnection(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TminiConnection) do
  begin
    {$IFDEF DELPHI4UP}
    RegisterVirtualConstructor(@TminiConnection.CREATENEW, 'CreateNew');
    {$ELSE}
    RegisterConstructor(@TminiConnection.Create, 'Create');
    {$ENDIF}
    RegisterMethod(@TminiConnection.Close, 'Close');
    //RegisterMethod(@TUniConnection_O, 'Open');
    RegisterMethod(@TminiConnection.O, 'O');
    RegisterMethod(@TminiConnection.RepOpen, 'RepOpen');
    RegisterMethod(@TminiConnection.StartTrans, 'StartTrans');
    RegisterMethod(@TminiConnection.Rollback, 'Rollback');
    RegisterMethod(@TminiConnection.Commit, 'Commit');
    RegisterMethod(@TminiConnection.GetDbType, 'DbType');
    RegisterMethod(@TminiConnection.DriverName, 'DriverName');
  end;
end;

procedure SIRegisterTUniConnection(Cl: TPSPascalCompiler);
begin
  {with Cl.AddClassN(cl.FindClass('TUniSQL'), 'TUniSQL') do
  begin

  end; }

  with Cl.AddClassN(cl.FindClass('TminiConnection'), 'TminiConnection') do
  begin
    {$IFDEF DELPHI4UP}
    RegisterMethod('constructor Create(AOwner: TComponent; Dummy: Integer)');
    {$ELSE}
    RegisterMethod('constructor Create(AOwner: TComponent)');
    {$ENDIF}

    RegisterMethod('procedure Close');
    RegisterMethod('function O(ConnStr: string; var ErrStr: string): boolean');
    RegisterMethod('function RepOpen(var ErrStr: string): boolean');
    RegisterMethod('function StartTrans(var ErrStr: string): boolean');
    RegisterMethod('function Rollback(var ErrStr: string): boolean');
    RegisterMethod('function Commit(var ErrStr: string): boolean');
    RegisterMethod('function DbType: string');
    RegisterMethod('function DriverName: string');

    RegisterProperty('InTransaction', 'boolean', iptr);
    RegisterProperty('Connected', 'boolean', iptrw);
    RegisterProperty('ConnectString', 'string', iptRW);
  end;
end;

procedure SIRegister_TUniConnection(Cl: TPSPascalCompiler);
begin
  //SIRegister_Forms_TypesAndConsts(cl);

  {$IFNDEF PS_MINIVCL}
  //SIRegisterTCONTROLSCROLLBAR(cl);
  {$ENDIF}
  //SIRegisterTScrollingWinControl(cl);
  {$IFNDEF PS_MINIVCL}
  //SIRegisterTSCROLLBOX(cl);
  {$ENDIF}
  SIRegisterTUniConnection(Cl);
  {$IFNDEF PS_MINIVCL}
  //SIRegisterTApplication(Cl);
  {$ENDIF}
end;

function TZipFile_ExtractZipFile(Self: TObject; const ZipFileName: string; const Path: string): string;
begin
  //if Self = nil then exit;
  //Result := TZipFile.ExtractZipFile(ZipFileName, Path);
end;

procedure TZipFile_ZipDirectoryContents(Self: TObject; const ZipFileName: string; const Path: string);
begin
  //if Self = nil then exit;
  //TZipFile.ZipDirectoryContents(ZipFileName, Path);
end;

procedure DeleteFile_From_Dir(const Path: string; const DelFileName: string);
  procedure pSearchFile(mPath: TFileName);
  var
    vSearchRec: SysUtils.TSearchRec;
    K: Integer;
  begin
    K := FindFirst(mPath + '\*.*', faAnyFile, vSearchRec);
    try
      while K = 0 do
      begin
        if (vSearchRec.Attr and faDirectory > 0) and (Pos(vSearchRec.Name, '..') = 0) then
          pSearchFile(mPath + '\' + vSearchRec.Name)
        else
        if Pos(vSearchRec.Name, '..') = 0 then
        begin
          if LowerCase(trim(DelFileName)) = LowerCase(vSearchRec.Name) then
            DeleteFile(PChar(mPath + '\' + vSearchRec.Name));
        end;
        K := FindNext(vSearchRec);
      end;
    finally
      SysUtils.FindClose(vSearchRec);
    end;
  end;
begin
  pSearchFile(Path);
end;

function TPub_FillCharEx(Text, Sub: String; Len: integer): String;
begin
  Result := PubString.FillChar(Text, Sub, Len);
end;

function TPub_GetDeliBack(Text, Delimite: String): String;
begin
  Result := PubString.GetDeliBack(Text, Delimite);
end;

function TPub_GetDeliPri(Text, Delimite: String): String;
begin
  Result := PubString.GetDeliPri(Text, Delimite);
end;

function TPub_ReplaceBaiFendHao(Text: String): String;
begin
  Result := Text;
  //Result := StringReplace(Result, '<%', '&lt;%', [rfReplaceAll, rfIgnoreCase]);
  //Result := StringReplace(Result, '%>', '%&gt;', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '<%', '&lt;&#37', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '%>', '&#37&gt;', [rfReplaceAll, rfIgnoreCase]);
  //Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll, rfIgnoreCase]);
  //Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll, rfIgnoreCase]);
end;

function TPub_ReplaceHTML(Text: string): string;
begin //把语句的 <%  %>转义 //<	= &lt;  >	= &gt;
  Result := Text;
  //Result := StringReplace(Result, '<%', '&lt;%', [rfReplaceAll, rfIgnoreCase]);
  //Result := StringReplace(Result, '%>', '%&gt;', [rfReplaceAll, rfIgnoreCase]);
  //Result := StringReplace(Result, '<%', '&lt;&#37', [rfReplaceAll, rfIgnoreCase]);
  //Result := StringReplace(Result, '%>', '&#37&gt;', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll, rfIgnoreCase]);
end;

function TPub_ReplaceAll(Text: String): String;
begin
  Result := Text;
  Result := TPub_ReplaceBaiFendHao(Result);
  Result := TPub_ReplaceHTML(Result);
end;

function Alipay_trade_recreate(AppId, Ali_URL_PAY, PrivaeKeyPath_Pem, OrdNum, Memo, PayAmt, timeout_express: string; var qr_code: string): String;
begin

  //Result := TWxALiPay.ALiPay_当面付获取付款连接(AppId, Ali_URL_PAY, PrivaeKeyPath_Pem, OrdNum, Memo, PayAmt, timeout_express, qr_code);
  //Result := TWxALiPay.ALiPay_当面付获取付款连接(AppId, 'E:\eYoue\2006-02-18\New EMaiDemon_China\SuperHtml\SuperHttpSvr\微信支付宝分离代码 - xe10.2\config\app_private_key_pkcs8.pem',
      //Format('XR%S',[FormatDateTime('YYYYMMDDHHNNSS', Now)]), '购买软件', '0.01', '30', qr_code);
end;
function Alipay_trade_query(AppId, Ali_URL_PAY, PrivaeKeyPath_Pem, OrdNum: string): String;
begin
  //Result := TWxALiPay.ALiPay_当面付获取付款状态(AppId, Ali_URL_PAY, PrivaeKeyPath_Pem, OrdNum);
end;

function SetPWD(Text: string; Key: string): String;
begin
  Result := PubPWD.SetPWD(Text, Key);
end;
{function SetPWDEx(Text: string; Key: string): String;
begin
  Result := PubPWD.SetPWDEx(Text, Key);
end;}
function GetPWD(Text: string; Key: string): String;
begin
  Result := PubPWD.GetPWD(Text, Key);
end;

procedure MySleep(time: integer);
begin
  Sleep(time);
end;

function IsValNull(value: string): boolean;
begin
  try
    Result := PubMath.IsValNull(Value);
  except
    Result := false;
  end;
end;
function IsNum(value: string): boolean;
begin
  Result := false;
  if trim(Value) = '' then exit;
  try
    StrToFloat(Value);
    Result := true;
  except
    Result := false;
  end;
end;
function Ad(V1,V2: string): string;
begin
  try  Result := PubMath.Ad(V1, V2); except end;
end;
function Su(V1,V2: string): string;
begin
  try  Result := PubMath.Su(V1, V2); except end;
end;
function Mu(V1,V2: string): string;
begin
  try  Result := PubMath.Mu(V1, V2); except end;
end;
function Di(V1,V2: string): string;
begin
  try  Result := PubMath.Di(V1, V2); except end;
end;
function MyDecimal(V1: string; digcount: integer): string;
begin
  try  Result := PubMath.Decimal(V1, digcount); except end;
end;
function DecimalEx(V1: string; digcount: integer): string;
begin
  try  Result := PubMath.DecimalEx(V1, digcount); except end;
end;
function DecimalDig(V1: string): integer;
begin
  try  Result := PubMath.DecimalDig(V1); except end;
end;
function MyTrunc(V1: string): string;
begin
  try  Result := PubMath.Trunc(V1); except end;
end;
function TruncEx(V1: string): string;
begin
  try  Result := PubMath.TruncEx(V1); except end;
end;
function Precision(V1: string): integer;
begin
  try  Result := PubMath.Precision(V1); except end;
end;
function MyAbs(V1: string): string;
begin
  try  Result := PubMath.Abs(V1); except end;
end;
function MyRound(V1: string): string;
begin
  try  Result := PubMath.Round(V1); except end;
end;

function Math_IsLess(V1,V2: string): boolean;
begin
  try  Result := PubMath.IsLess(V1, V2); except end;
end;
function Math_IsLessEqual(V1,V2: string): boolean;
begin
  try  Result := PubMath.IsLessEqual(V1, V2); except end;
end;
function Math_IsGreater(V1,V2: string): boolean;
begin
  try  Result := PubMath.IsGreater(V1, V2); except end;
end;
function Math_IsGreaterEqual(V1,V2: string): boolean;
begin
  try  Result := PubMath.IsGreaterEqual(V1, V2); except end;
end;
function Math_IsEqual(V1,V2: string): boolean;
begin
  try  Result := PubMath.IsEqual(V1, V2); except end;
end;
function Math_IsNegOrZero(V1: string): boolean;
begin
  try  Result := PubMath.IsNegOrZero(V1); except end;
end;
function Math_IsPosOrZero(V1: string): boolean;
begin
  try  Result := PubMath.IsPosOrZero(V1); except end;
end;
function Math_IsPositive(V1: string): boolean;
begin
  try  Result := PubMath.IsPositive(V1); except end;
end;
function Math_IsNegative(V1: string): boolean;
begin
  try  Result := PubMath.IsNegative(V1); except end;
end;
function Math_IsValidValue(V1: string): boolean;
begin
  try  Result := PubMath.IsValidValue(V1); except end;
end;
function Math_IsValidValueEx(V1: string): string;
begin
  try  Result := PubMath.IsValidValueEx(V1); except end;
end;
function Math_IsValidDate(V1: string): boolean;
begin
  try  Result := PubMath.IsValidDate(V1); except end;
end;
function Math_IsValidDateTime(V1: string): boolean;
begin
  try  Result := PubMath.IsValidDateTime(V1); except end;
end;
function Math_IsValidTime(V1: string): boolean;
begin
  try  Result := PubMath.IsValidTime(V1); except end;
end;
function Math_ChangeFloat(V1: string): string;
begin
  try  Result := PubMath.ChangeFloat(V1); except end;
end;
function Math_Format(F, V1: string): string;
begin
  try  Result := PubMath.Format(F, V1); except end;
end;
{$ifdef FPC}
{procedure StretchDrawBitmapToBitmap(SourceBitmap, DestBitmap: TBitmap;
  DestWidth, DestHeight: integer);
var
  DestIntfImage, SourceIntfImage: TLazIntfImage;
  DestCanvas: TLazCanvas;
begin

  // Prepare the destination
  DestIntfImage := TLazIntfImage.Create(0, 0);
  DestIntfImage.LoadFromBitmap(DestBitmap.Handle, 0);

  DestCanvas := TLazCanvas.Create(DestIntfImage);

  //Prepare the source
  SourceIntfImage := TLazIntfImage.Create(0, 0);
  SourceIntfImage.LoadFromBitmap(SourceBitmap.Handle, 0);

  // Execute the stretch draw via TFPSharpInterpolation
  DestCanvas.Interpolation := TFPSharpInterpolation.Create;
  DestCanvas.StretchDraw(0, 0, DestWidth, DestHeight, SourceIntfImage);

  // Reload the image into the TBitmap
  DestBitmap.LoadFromIntfImage(DestIntfImage);

  SourceIntfImage.Free;
  DestCanvas.Interpolation.Free;
  DestCanvas.Free;
  DestIntfImage.Free;
end; }
{$endif}

(*
begin
  try
    DescFileName := ChangeFileExt(SourceFileName, AddStr + ExtractFileExt(SourceFileName));
    DescFileName := ChangeFileExt(DescFileName, 'jpg');

    bmpSour := TBitmap.Create;
    bmp := TBitmap.Create;
    jpg := TJPEGImage.Create;
    try

      //读取源文件
      if LowerCase(ExtractFileExt(SourceFileName)) = '.gif' then
        //LoadGif
      else
      if LowerCase(ExtractFileExt(SourceFileName)) = '.png' then
        LoadPng
      else
      if (LowerCase(ExtractFileExt(SourceFileName)) = '.jpg') or (LowerCase(ExtractFileExt(SourceFileName)) = '.jpeg') then
        LoadJpg
      else
        bmpSour.LoadFromFile(SourceFileName);


      //计算缩小比例
      if bmpSour.Width >= bmpSour.Height then
        tmpInt := (bmpSour.Width / MaxWidth)
      else
        tmpInt := (bmpSour.Height / MaxHigth);
      Width := Round(bmpSour.Width / tmpInt);
      Height := Round(bmpSour.Height / tmpInt);

      bmp.Width := Width;
      bmp.Height := Height;

      StretchDrawBitmapToBitmap(bmpSour, bmp, Width, Height);
      Png.Assign(DestBitmap);
      Png.SaveToFile(DescFileName);
    finally
      jpg.Free;
      bmpSour.Free;
      bmp.Free;

    end;// }
  except
  end;
end;
*)

function StretchImage(SourceFileName, AddStr:String; MaxWidth, MaxHigth: integer): boolean;
var
  targetFileName: string;
  jpg: TJPEGImage;
  bmp, bmpSour: TBitmap;
  Width,Height: integer;
  tmpInt: double;
  procedure LoadJpg();
  var
    Png: TJPEGImage;
  begin
    Png := TJPEGImage.Create;
    try
      Png.LoadFromFile(SourceFileName);
      bmpSour.Assign(Png);
    finally
      Png.Free;
    end;
  end;
  procedure LoadGif();
  var
    Gif: TGIFImage;
  begin
    Gif := TGIFImage.Create;
    try
      Gif.LoadFromFile(SourceFileName);
      bmpSour.Assign(Gif);
    finally
      Gif.Free;
    end;
  end;
  {$ifdef FPC}
  procedure LoadPng;
  var
    Png: TPortableNetworkGraphic;
  begin
    Png := TPortableNetworkGraphic.Create;
    try
      Png.LoadFromFile(SourceFileName);
      bmpSour.Assign(png);
    finally
      Png.Free;
    end;
  end;
  {$else}
  procedure LoadPng();
  var
    Png: TPngImage;
  begin
    Png := TPngImage.Create;
    try
      Png.LoadFromFile(SourceFileName);
      bmpSour.Assign(Png);
    finally
      Png.Free;
    end;
  end;
  {$endif}
begin
  try
    targetFileName := ChangeFileExt(SourceFileName, AddStr + ExtractFileExt(SourceFileName));
    targetFileName := ChangeFileExt(targetFileName, '.jpg');

    bmp := TBitmap.Create;
    bmpSour := TBitmap.Create;
    Jpg := TJPEGImage.Create;
    try

      //读取源文件
      if LowerCase(ExtractFileExt(SourceFileName)) = '.gif' then
        LoadGif
      else
      if LowerCase(ExtractFileExt(SourceFileName)) = '.png' then
        LoadPng
      else
      if (LowerCase(ExtractFileExt(SourceFileName)) = '.jpg') or (LowerCase(ExtractFileExt(SourceFileName)) = '.jpeg') then
        LoadJpg
      else
        bmpSour.LoadFromFile(SourceFileName);
      if (bmpSour.Width <= MaxWidth) and (bmpSour.Height <= MaxHigth) then
      begin
        jpg.Assign(bmpSour);
      end else
      begin
        //计算缩小比例
        if bmpSour.Width >= bmpSour.Height then
          tmpInt := (bmpSour.Width / MaxWidth)
        else
          tmpInt := (bmpSour.Height / MaxHigth);

        Width := Round(bmpSour.Width / tmpInt);
        Height := Round(bmpSour.Height / tmpInt);

        //缩小
        bmp.Width := Width;
        bmp.Height := Height;
        bmp.PixelFormat := pf24bit;
        bmp.Canvas.StretchDraw(Rect(0,0,Width,Height),bmpSour);
        //保存
        jpg.Assign(bmp);
      end;
      jpg.SaveToFile(targetFileName);
    finally
      bmpSour.Free;
      bmp.Free;
      jpg.Free;
    end;
  except
    PubFile.FileCopyFile(SourceFileName, targetFileName);
  end;
  Result := FileExists(targetFileName);
end;

function FileNameAddStr(FileName, AddStr: String): string;
var
  Flag: boolean;
begin
  Result := ChangeFileExt(FileName, AddStr + ExtractFileExt(FileName));
  exit;
  {Flag := Pos(':', FileName) < 1;
  if Flag then
    FileName := 'D:\' + FileName; }
  Flag := Pos('/', FileName) > 0;
  if Flag then
    FileName := StringReplace(FileName, '/', '\', [rfReplaceAll]);
  Result := ExtractFilePath(FileName) + AddStr + ExtractFileName(FileName);
  //if Flag then
    //Result := Copy(Result, 4, MaxInt);
  if Flag then
    Result := StringReplace(Result, '\', '/', [rfReplaceAll]);
end;

function StreamToMD5(S: TStream): String;
begin
  Result := PubSys.StreamToMD5(S);
end;

function GetMd5(Value: string; NeedUpperCase: boolean): string;
begin
  Result := PubSys.GetMD5(Value);
end;

function GetClientUniqueCode: string;
begin
  Result := PubSys.GetClientUniqueCode;
end;

function ReplaceBaiFendHao(Text: string): string;
begin //把语句的 <%  %>转义 //<	= &lt;  >	= &gt;
  Result := Text;
  //Result := StringReplace(Result, '<%', '&lt;%', [rfReplaceAll, rfIgnoreCase]);
  //Result := StringReplace(Result, '%>', '%&gt;', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '<%', '&lt;&#37', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '%>', '&#37&gt;', [rfReplaceAll, rfIgnoreCase]);
  //Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll, rfIgnoreCase]);
  //Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll, rfIgnoreCase]);
end;

function NoParseHTML(Text: String): string;
begin //把语句的 <%  %>转义 //<	= &lt;  >	= &gt;
  Result := Text;
  //Result := StringReplace(Result, '<%', '&lt;%', [rfReplaceAll, rfIgnoreCase]);
  //Result := StringReplace(Result, '%>', '%&gt;', [rfReplaceAll, rfIgnoreCase]);
  //Result := StringReplace(Result, '<%', '&lt;&#37', [rfReplaceAll, rfIgnoreCase]);
  //Result := StringReplace(Result, '%>', '&#37&gt;', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll, rfIgnoreCase]);
end;
function ReplaceText_ReturnToHtml_BR(Value: string): string;
begin
  Result := Value;
  if Pos('<%', trim(Value)) = 1 then exit; //2020-02-27 add

  Result := StringReplace(Result, #13#10, '<br>', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, #13, '<br>', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, #10, '<br>', [rfReplaceAll, rfIgnoreCase]);

  Result := StringReplace(Result, #13#10, '<br>', [rfReplaceAll, rfIgnoreCase]);
  //Result := PubString.StrPlace(Result, ' ', '&nbsp;');
end;

function GetSnowID(): string;
var
  s: TSnowflake;
begin
  s := TSnowflake.Create;
  try
    s.OrgID := 8;
    s.MachineID :=10;
    Randomize;
    Result := IntToStr(RandomRange(10,99));
    Result := IntToStr(s.Generate) + Result;
  finally
    s.Free;
  end;
end;

procedure Base64ToFile(Base64Str, FileName: string);
begin
  PubSys.Base64ToFile(Base64Str, FileName);
end;

procedure Base64ToStream(Base64Str: string; MemoryStream: TStream);
begin
  PubSys.Base64ToStream(Base64Str, MemoryStream);
end;

function FileToBase64(FileName: string): string;
begin
  Result := PubSys.FileToBase64(FileName);
end;

function Base64Encode(Text: string): String;
begin
  Result := PubSys.Base64Encode(Text);
end;

function Base64Decode(Text: string): String;
begin
  Result := PubSys.Base64Decode(Text);
end;

function StreamToBase64(Stream: TMemoryStream): string;
begin
  Result := PubSys.StreamToBase64(Stream);
end;

function MyEncode_DZ(Text: string): string;
var
  Tmpstr: string;
begin
  Tmpstr := Utf8Encode(Text);
  Tmpstr := PubSys.Base64Encode(Tmpstr); // IdEncoder1_Base64.EncodeString(PwdStr);
  Tmpstr := PubPWD.SetPWD(Tmpstr, '@*$$'); //'@*$$'
  Result := Tmpstr;
end;

procedure WinRar_UnZip(FromFile, ToFile: string; NeedPwd: string = '');
begin
  PubSys.WinRar_UnZip(FromFile, ToFile, NeedPwd);
end;

procedure WinRar_Zip(FromDir, ToFile: string; NeedPwd: string = '');

begin
  PubSys.WinRar_Zip(FromDir, ToFile, NeedPwd);
end;

function GetDir_AllFile(Directory: string; RetList: TStringList): Boolean;
var
  SearchRec: SysUtils.TSearchRec;
  sTemp: string;
  function IsSubDir(SearchRec: SysUtils.TSearchRec): Boolean;
  begin
      if (SearchRec.Attr = faDirectory) and (SearchRec.Name <> '.') and
        (SearchRec.Name <> '..') then
        Result := True
      else
        Result := False;
  end;
begin
  if FindFirst(Directory + '*.*', faAnyFile, SearchRec) = 0 then
  begin
    try
      repeat //循环直到Until为真
        if IsSubDir(SearchRec) then
        begin
          sTemp := Directory + SearchRec.Name + '\';
          RetList.Add(sTemp);
          GetDir_AllFile(sTemp, RetList); //这是递归部分，查找各子目录。
        end;
      until (FindNext(SearchRec) <> 0);
    finally
      SysUtils.FindClose(SearchRec);
    end;
  end;
  Result := True;
end;

function GetAllDirFile(Directory: string; var RetList: TStringList): Boolean;
var
  i: Integer;
  DirList: TStringList;
  SearchRec: SysUtils.TSearchRec;
begin
  Result := False;
  DirList := TStringList.Create;
  try
    DirList.Add(Directory + '\');
    if not GetDir_AllFile(Directory + '\', DirList) then exit;

    for i := 0 to DirList.Count - 1 do
    begin
      if FindFirst(DirList.Strings[i] + '*.*', faAnyFile, SearchRec) = 0 then
      begin
        try
          repeat //循环直到Until为真
            if SearchRec.Attr <> faDirectory then
              RetList.Add(DirList.Strings[i] + SearchRec.Name);
          until (FindNext(SearchRec) <> 0);
        finally
          SysUtils.FindClose(SearchRec);
        end;
      end;
    end;
    if DirList.Count <= 0 then
      RetList.Add(Directory);
  finally
    DirList.Free;
  end;
  Result := True;
end;

procedure Dll_UnZip(FromFile, ToFile: string; NeedPwd: string = '');
var
  Handle: THandle;
  UnZip: procedure(FromFile, ToFile, NeedPwd: PChar); stdcall;
begin
  Handle := LoadLibrary(PChar(ExtractFilePath(ParamStr(0)) + 'szip.dll'));
  if Handle <> 0 then
  begin
    try
      @UnZip := GetProcAddress(Handle, 'UnZip');
      if @UnZip <> nil then
      begin
        UnZip(PChar(FromFile), PChar(ToFile), PChar(NeedPwd));
      end;
    finally
      FreeLibrary(Handle);
    end;
  end;
end;

function MyIncHour(AValue: TDateTime; ANumberOfHours: Integer): TDateTime;
begin
  Result := IncHour(AValue, ANumberOfHours);
end;

function StringReplaceEx(const S, OldPattern, NewPattern: string;  Flags: TReplaceFlags): string;
begin
  Result := StringReplace(S, OldPattern, NewPattern, Flags);
end;

function myExtractFilePath(const FileName: string): string;
begin
  Result := ExtractFilePath(FileName);
end;

function MyFileExists(const FileName: string): Boolean;
begin
  Result := FileExists(FileName);
end;

function myDirectoryExists(const FileName: string): Boolean;
begin
  Result := DirectoryExists(FileName);
end;

function MyGetTickCount64: int64;
begin
  Result := GetTickCount64;
end;

function MyRandom(const ARange: Integer): Integer;
begin
  Result := Random(ARange);
end;

function MyRandomRange(const AFrom, ATo: Integer): Integer;
begin
  Result := RandomRange(AFrom, ATo);
end;

{function MyDateTimeToStr(DateTime: TDateTime): string;
begin
  Result := DateTimeToStr(DateTime);
end;}

///////////////////datetime start
function TryEncodeDate(Year, Month, Day: Word; var Date: TDateTime): Boolean;
begin
  try
    Date := EncodeDate(Year, Month, Day);
    Result := true;
  except
    Result := false;
  end;
end;

function TryEncodeTime(Hour, Min, Sec, MSec: Word; var Time: TDateTime): Boolean;
begin
  try
    Time := EncodeTime(hour, Min, Sec, MSec);
    Result := true;
  except
    Result := false;
  end;
end;

function DateTimeToUnix(D: TDateTime): Int64;
begin
  Result := Round((D - 25569) * 86400);
end;

function UnixToDateTime(U: Int64): TDateTime;
begin
  Result := U / 86400 + 25569;
end;

function DateToStr_(D: TDateTime): string;
begin
  Result := DateToStr(D);
end;

function StrToDate_(const S: string): TDateTime;
begin
  Result := StrToDate(S);
end;

function DateTimeToStr_(D: TDateTime): string;
begin
  Result := DateTimeToStr(D);
end;

function FormatDateTime_(const Format: string; DateTime: TDateTime): string;
begin
  Result := FormatDateTime(Format, DateTime);
end;

function ProgramPath: string;
begin
  Result := ServerInfo.ProgramPath;
end;

function IncSecond_(Value: TDateTime; AddSecond: integer): TDateTime;
begin
  Result := IncSecond(Value, AddSecond);
end;

procedure RegisterDateTimeLibrary(Sender: TPSScript);
begin
  Sender.AddFunction(@EncodeDate, 'function EncodeDate(Year, Month, Day: Word): TDateTime;');
  Sender.AddFunction(@EncodeTime, 'function EncodeTime(Hour, Min, Sec, MSec: Word): TDateTime;');
  Sender.AddFunction(@TryEncodeDate, 'function TryEncodeDate(Year, Month, Day: Word; var Date: TDateTime): Boolean;');
  Sender.AddFunction(@TryEncodeTime, 'function TryEncodeTime(Hour, Min, Sec, MSec: Word; var Time: TDateTime): Boolean;');
  Sender.AddFunction(@DecodeDate, 'procedure DecodeDate(const DateTime: TDateTime; var Year, Month, Day: Word);');
  Sender.AddFunction(@DecodeTime, 'procedure DecodeTime(const DateTime: TDateTime; var Hour, Min, Sec, MSec: Word);');
  Sender.AddFunction(@DayOfWeek, 'function DayOfWeek(const DateTime: TDateTime): Word;');
  Sender.AddFunction(@Date, 'function Date: TDateTime;');
  Sender.AddFunction(@Time, 'function Time: TDateTime;');
  Sender.AddFunction(@Now, 'function Now: TDateTime;');
  Sender.AddFunction(@DateTimeToUnix, 'function DateTimeToUnix(D: TDateTime): Int64;');
  Sender.AddFunction(@UnixToDateTime, 'function UnixToDateTime(U: Int64): TDateTime;');
  Sender.AddFunction(@DateToStr_, 'function DateToStr(D: TDateTime): string;');
  Sender.AddFunction(@DateTimeToStr_, 'function DateTimeToStr(D: TDateTime): string;');
  Sender.AddFunction(@FormatDateTime_, 'function FormatDateTime(const Format: string; DateTime: TDateTime): string;');
  Sender.AddFunction(@StrToDate_, 'function StrToDate(const S: string): TDateTime;');

  Sender.AddFunction(@IncDay, 'function IncDay(Value: TDateTime; AddDate: integer): TDateTime;');
  Sender.AddFunction(@IncYear, 'function IncYear(Value: TDateTime; AddYear: integer): TDateTime;');
  Sender.AddFunction(@IncMonth, 'function IncMonth(Value: TDateTime; AddMonth: integer): TDateTime;');
  Sender.AddFunction(@IncWeek, 'function IncWeek(Value: TDateTime; AddIncWeek: integer): TDateTime;');
  Sender.AddFunction(@IncHour, 'function IncHour(Value: TDateTime; AddHour: integer): TDateTime;');
  Sender.AddFunction(@IncMinute, 'function IncMinute(Value: TDateTime; AddMinute: integer): TDateTime;');
  Sender.AddFunction(@IncSecond_, 'function IncSecond(Value: TDateTime; AddSecond: integer): TDateTime;');
  Sender.AddFunction(@IncMilliSecond, 'function IncMilliSecond(Value: TDateTime; AddMilliSecond: integer): TDateTime;');
  Sender.AddFunction(@YearsBetween, 'function YearsBetween(const ANow, AThen: TDateTime): Integer;');
  Sender.AddFunction(@MonthsBetween, 'function MonthsBetween(const ANow, AThen: TDateTime): Integer;');
  Sender.AddFunction(@WeeksBetween, 'function WeeksBetween(const ANow, AThen: TDateTime): Integer;');
  Sender.AddFunction(@DaysBetween, 'function DaysBetween(const ANow, AThen: TDateTime): Integer;');
  Sender.AddFunction(@HoursBetween, 'function HoursBetween(const ANow, AThen: TDateTime): Int64;');
  Sender.AddFunction(@MinutesBetween, 'function MinutesBetween(const ANow, AThen: TDateTime): Int64;');
  Sender.AddFunction(@MilliSecondsBetween, 'function MilliSecondsBetween(const ANow, AThen: TDateTime): Int64;');

  Sender.AddFunction(@StartOfTheMonth, 'function StartOfTheMonth(const AValue: TDateTime): TDateTime;');
  Sender.AddFunction(@EndOfTheMonth, 'function EndOfTheMonth(const AValue: TDateTime): TDateTime;');
  Sender.AddFunction(@StartOfTheWeek, 'function StartOfTheWeek(const AValue: TDateTime): TDateTime;');
  Sender.AddFunction(@EndOfTheWeek, 'function EndOfTheWeek(const AValue: TDateTime): TDateTime;');

  Sender.AddFunction(@DayOfTheYear, 'function DayOfTheYear(const AValue: TDateTime): Word;');
  Sender.AddFunction(@HourOfTheYear, 'function HourOfTheYear(const AValue: TDateTime): Word;');

  Sender.AddFunction(@DayOfTheMonth, 'function DayOfTheMonth(const AValue: TDateTime): Word;');
  Sender.AddFunction(@HourOfTheMonth, 'function HourOfTheMonth(const AValue: TDateTime): Word;');
end;

{

function YearsBetween(const ANow, AThen: TDateTime): Integer;
;
;
;
function HoursBetween(const ANow, AThen: TDateTime): Int64;
function (const ANow, AThen: TDateTime): Int64;
function SecondsBetween(const ANow, AThen: TDateTime): Int64;
function (const ANow, AThen: TDateTime): Int64;


}

///////////////////datetime end

function ReadTxtFileContent(FileName: string; LastCount: integer): string;
var
  SL, SL2: TStringList;
  index, lp, NewIndex: integer;
  Reader: TStreamReader;
  s: ansistring;
  Encoding: TEncoding;
begin //读取TXT文件的最后的lastCount条记录,按从最到前排序
  try
    LastCount := LastCount + 1;
    SL := TStringList.Create;
    SL2 := TStringList.Create;
    try
      //LastCount := 10000;
      for lp := 1 to LastCount do
      begin
        SL.Add('');
        SL2.Add('');
      end;

      Encoding := TEncoding.UTF8;
      for lp := 0 to 1 do
      try
        Index := 0;
        Reader := TStreamReader.Create(TFileStream.Create(FileName, fmShareDenyNone){$IFNDEF FPC}, Encoding{$endif});
        try
          while not reader.{$IFDEF FPC}Eof{$else}EndOfStream{$endif} do
          begin
            try
              s := reader.ReadLine;
            except
            end;
            {$IFDEF FPC}
            if Encoding = TEncoding.UTF8 then
              SL[Index] := Utf8ToAnsi(s)
            else
              SL[Index] := s;
            {$else}
            SL[Index] := s;
            {$endif}
            Index := Index + 1;
            if Index = LastCount then
              Index := 0;
          end;
        finally
          reader.Free;
        end;
        break;
      except //mapping for the Unicode
        Encoding := TEncoding.ANSI;
      end;
      NewIndex := index - 1;
      for lp := 1 to LastCount do
      begin
        if NewIndex = - 1 then
          NewIndex := LastCount - 1;

        SL2[lp - 1] := SL[NewIndex];
        NewIndex := NewIndex - 1;
        if NewIndex = index then  break;

      end;
      Result := trim(SL2.Text);
    finally
      SL2.Free;
      SL.Free;
    end;
  except
    on e: exception do
      Result := '读取文件出错：' + e.Message;
  end;
end;

function MyChangeFileExt(FileName, ext: string): string;
begin
  Result := string(ChangeFileExt(FileName, ext));
end;
function myExtractFileExt(FileName: string): string;
begin
  Result := string(ExtractFileExt(FileName));
end;
function myExtractFileName(FileName: string): string;
begin
  Result := string(ExtractFileName(FileName));
end;
function MyDeleteFile(FileName: string): boolean;
begin
  Result := DeleteFile(PChar(FileName));
end;

function lastError: string;
begin
  Result := flastError;
end;

procedure SetSearchRec(F: minicomponents.TSearchRec; MF: SysUtils.TSearchRec);
begin
  F.Time := MF.Time;
  F.Size := MF.Size;
  F.Attr := MF.Attr;
  F.Name := MF.Name;
  F.ExcludeAttr := MF.ExcludeAttr;
  F.FindHandle := MF.FindHandle;
  {$IFDEF mswindows}
  F.FindData.dwFileAttributes := MF.FindData.dwFileAttributes;
  F.FindData.ftCreationTime.dwLowDateTime := MF.FindData.ftCreationTime.dwLowDateTime;
  F.FindData.ftCreationTime.dwHighDateTime := MF.FindData.ftCreationTime.dwHighDateTime;
  F.FindData.ftLastAccessTime.dwLowDateTime := MF.FindData.ftLastAccessTime.dwLowDateTime;
  F.FindData.ftLastAccessTime.dwHighDateTime := MF.FindData.ftLastAccessTime.dwHighDateTime;
  F.FindData.ftLastWriteTime.dwLowDateTime := MF.FindData.ftLastWriteTime.dwLowDateTime;
  F.FindData.ftLastWriteTime.dwHighDateTime := MF.FindData.ftLastWriteTime.dwHighDateTime;
  F.FindData.nFileSizeHigh := MF.FindData.nFileSizeHigh;
  F.FindData.nFileSizeLow := MF.FindData.nFileSizeLow;
  F.FindData.dwReserved0 := MF.FindData.dwReserved0;
  F.FindData.dwReserved1 := MF.FindData.dwReserved1;
  F.FindData.cFileName := MF.FindData.cFileName;
  F.FindData.cAlternateFileName := MF.FindData.cAlternateFileName;
  {$else}
  F.Mode := MF.Mode;
  {$endif}
end;

procedure SetSearchRec_To(F: minicomponents.TSearchRec; var MF: SysUtils.TSearchRec);
var
  lp: integer;
begin
  MF.Time := F.Time;
  MF.Size := F.Size;
  MF.Attr := F.Attr;
  MF.Name := F.Name;
  MF.ExcludeAttr := F.ExcludeAttr;
  MF.FindHandle := F.FindHandle;
  {$IFDEF mswindows}
  MF.FindData.dwFileAttributes := F.FindData.dwFileAttributes;
  MF.FindData.ftCreationTime.dwLowDateTime := F.FindData.ftCreationTime.dwLowDateTime;
  MF.FindData.ftCreationTime.dwHighDateTime := F.FindData.ftCreationTime.dwHighDateTime;
  MF.FindData.ftLastAccessTime.dwLowDateTime := F.FindData.ftLastAccessTime.dwLowDateTime;
  MF.FindData.ftLastAccessTime.dwHighDateTime := F.FindData.ftLastAccessTime.dwHighDateTime;
  MF.FindData.ftLastWriteTime.dwLowDateTime := F.FindData.ftLastWriteTime.dwLowDateTime;
  MF.FindData.ftLastWriteTime.dwHighDateTime := F.FindData.ftLastWriteTime.dwHighDateTime;
  MF.FindData.nFileSizeHigh := F.FindData.nFileSizeHigh;
  MF.FindData.nFileSizeLow := F.FindData.nFileSizeLow;
  MF.FindData.dwReserved0 := F.FindData.dwReserved0;
  MF.FindData.dwReserved1 := F.FindData.dwReserved1;
  for lp := 0 to length(F.FindData.cFileName) - 1 do
    MF.FindData.cFileName[lp] := F.FindData.cFileName[lp + 1];
  MF.FindData.cFileName[lp + 1] := #0;
  for lp := 0 to length(F.FindData.cAlternateFileName) - 1 do
    MF.FindData.cAlternateFileName[0] := F.FindData.cAlternateFileName[lp + 1];
  MF.FindData.cAlternateFileName[lp + 1] := #0;
  {$else}
  MF.Mode := F.Mode;
  {$endif}
end;

function MyFindFirst(const Path: string; Attr: Integer; F: minicomponents.TSearchRec): Integer;
var
  MF: SysUtils.TSearchRec;
begin
  Result := FindFirst(Path, Attr, MF);
  SetSearchRec(F, MF);
end;

function MyFindClose(F: minicomponents.TSearchRec): boolean;
var
  MF: SysUtils.TSearchRec;
begin
  MF.FindHandle := F.FindHandle;
  SysUtils.FindClose(MF);
  Result := true;
end;

function MyFindNext(F:minicomponents. TSearchRec): Integer;
var
  MF: SysUtils.TSearchRec;
begin
  SetSearchRec_To(F, MF);
  Result := FindNext(MF);
  SetSearchRec(F, MF);
end;

function MyFileGetFileTimeA(F: string): string;
begin
  Result := PubFile.FileGetFileTimeA(F);
end;
function MyFileChangeFileDate(FileName, FileTime: string): boolean;
begin
  PubFile.FileChangeFileDate(FileName, FileTime);
  Result := true;
end;
function MyFileGetTemporaryFileName: string;
begin
  Result := PubFile.FileGetTemporaryFileName();
end;
function MyFileGetTemporaryPath: string;
begin
  Result := PubFile.FileGetTemporaryPath;
end;
function PathWithoutSlash(const Path: string): string;
begin
  Result := PubFile.PathWithoutSlash(Path);
end;

function PathWithSlash(const Path: string): string;
begin
  Result := PubFile.PathWithSlash(Path);
end;


procedure Register_functionOrProcedure(Sender: TPSScript);
  procedure AddFunction(const Decl: tbtstring; Ptr: Pointer);
  begin
    Sender.AddFunction(Ptr, Decl);
  end;
begin
  //系统函数
  RegisterDateTimeLibrary(Sender);
  {$ifdef fpc}
  AddFunction('Function CreateDir(Const NewDir : String) : Boolean;', @CreateDir);
  AddFunction('Function GetDriveIDFromLetter(Const ADrive: UnicodeString): Byte', @GetDriveIDFromLetter);
  AddFunction('Function ForceDirectories(Const Dir: string): Boolean;', @ForceDirectories);
  //AddFunction('Function ForceDirectories(Const Dir: string): Boolean;', @ForceDirectories);
  AddFunction('function ExtractFileName(const FileName: string): string;', @myExtractFileName);
  AddFunction('function ExtractFileExt(const FileName: string): string;', @myExtractFileExt);
  AddFunction('function DirectoryExists(const FileName: string): boolean;', @myDirectoryExists);
  AddFunction('function ChangeFileExt(FileName, Extension: string): string;', @MyChangeFileExt);
  AddFunction('function ExtractFilePath(const FileName: string): string;', @myExtractFilePath);
  AddFunction('function FileExists(const FileName: string): Boolean;', @MyFileExists);
  AddFunction('function DeleteFile(lpFileName: string): boolean;', @MyDeleteFile);
  AddFunction('function Format(Format: string; const Args: array of const) : string;', @Format);
  //AddFunction('function MyEncode_DZ(Text: string): string;', @MyEncode_DZ);
  {$endif}
  AddFunction('function FindFirst(const Path: string; Attr: Integer; F: TSearchRec): Integer', @MyFindFirst);
  AddFunction('function FindNext(F: TSearchRec): Integer', @MyFindNext);
  AddFunction('function FindClose(F: TSearchRec): boolean;', @MyFindClose);
  //删除文件夹
  AddFunction('Function RemoveDir(Const Dir: String) : Boolean', @RemoveDir);
  //取文件修改时间
  AddFunction('function FileGetFileTimeA(FileName: string): string;', @MyFileGetFileTimeA);
  //修改文件修改时间
  AddFunction('function FileChangeFileDate(FileName, FileTime: string): boolean;', @MyFileChangeFileDate);
  //修改文件修改时间
  AddFunction('function FileChangeFileDate(FileName, FileTime: string): boolean;', @MyFileChangeFileDate);
  //取得临时文件
  AddFunction('function FileGetTemporaryFileName: string;', @MyFileGetTemporaryFileName);
  //取得临时路径
  AddFunction('function  FileGetTemporaryPath: string;', @MyFileGetTemporaryPath);

  //路径最后有/ 去掉/
  AddFunction('function PathWithoutSlash(const Path: string): string;', @PathWithoutSlash);
  //路径最后没有/ 加/
  AddFunction('function PathWithSlash(const Path: string): string;', @PathWithSlash);

  //获取最后执行错误
  AddFunction('function lastError: string', @lastError);
  //数据集转json
  AddFunction('function DataSet2Json(ds: TDataSet): string', @DataSet2Json);
  //json转数据集（TVirtualTable），
  AddFunction('function Json2DataSet(ds: TDataSet; Json: string): string', @Json2DataSet);
  //把json加载到mds中
  AddFunction('function DBMemory_LoadJson(mds: THjhMemoryDataSet; FromPath: string): string', @DBMemory_LoadJson);

  //读取TXT文件的最后的lastCount条记录,按从最到前排序
  AddFunction('function ReadTxtFileContent(FileName: string; LastCount: integer): string', @ReadTxtFileContent);
  //取服务exe所在的path
  AddFunction('function ProgramPath: string', @ProgramPath);
  AddFunction('function ParamCount: integer', @ParamCount);
  AddFunction('function ParamStr(Index: Integer): string', @ParamStr);
  AddFunction('function GetTickCount: LongWord;', @GetTickCount);
  AddFunction('function GetTickCount64: int64;', @MyGetTickCount64);
  //取指定范围的整数随机数
  AddFunction('function Random(const ARange: Integer): Integer;', @MyRandom);
  //取指定范围的整数随机数
  AddFunction('function RandomRange(const AFrom, ATo: Integer): Integer;', @MyRandomRange);
  AddFunction('procedure Randomize;', @Randomize);

  AddFunction('function AnsiDequotedStr(const S: string; AQuote: Char): string;', @AnsiDequotedStr);
  AddFunction('function QuotedStr(const S: string): string;', @SysUtils.QuotedStr);
  AddFunction('function AnsiQuotedStr(const S: string; Quote: char): string;', @AnsiQuotedStr);
  AddFunction('function StringReplace(const S, OldPattern, NewPattern: string;  Flags: TReplaceFlags): string;', @StringReplaceEx);

  //注册过程或函数   AddFunction('procedure Dll_UnZip(FromFile, TOPath: string; NeedPwd: string);', @Dll_UnZip);
  AddFunction('procedure Dll_UnZip(FromFile, TOPath: string; NeedPwd: string);', @Dll_UnZip);
  AddFunction('procedure WinRar_UnZip(FromFile, TOPath: string; NeedPwd: string);', @WinRar_UnZip);
  AddFunction('procedure WinRar_Zip(FromDir, TOFile: string; NeedPwd: string);', @WinRar_Zip);
  //压缩一个文件
  AddFunction('function ZipOneFile(SourceFile, ToFile: string): string;', @ZipOneFile);
  //解压文件到一个文件夹
  AddFunction('function UnZipFileToFolder(ZipFile, ToPath: string): string;', @UnZipFileToFolder);
  //Base64转文件
  AddFunction('procedure Base64ToFile(Base64Str, FileName: string);', @Base64ToFile);
  //Base64转流
  AddFunction('procedure Base64ToStream(Base64Str: string; MemoryStream: TStream);', @Base64ToStream);
  //文件转Base64
  AddFunction('function FileToBase64(FileName: string): string;', @FileToBase64);
  //流转Base64
  AddFunction('function StreamToBase64(Stream: TMemoryStream): string;', @StreamToBase64);
  //Base64转字符串
  AddFunction('function DecodeString(Text: string): string;', @Base64Decode);
  AddFunction('function Base64Decode(Text: string): string;', @Base64Decode);
  //字符串转Base64
  AddFunction('function Base64Encode(Text: string): string;', @Base64Encode);
  AddFunction('function EncodeString(Text: string): string;', @Base64Encode);

  AddFunction('function MyEncode_DZ(Text: string): string;', @MyEncode_DZ);
  AddFunction('function Utf8Encode(Text: string): string;', @Utf8Encode);
  AddFunction('function GetSnowID(): string;', @GetSnowID); //获取雪花ID
  AddFunction('function ReplaceBaiFendHao(Text: string): string;', @ReplaceBaiFendHao);
  AddFunction('function NoParseHTML(Text: String): string;', @NoParseHTML);
  AddFunction('function ReplaceText_ReturnToHtml_BR(Value: string): string;', @ReplaceText_ReturnToHtml_BR);

  //取2位ID值
  AddFunction('function GetClientUniqueCode: string;', @GetClientUniqueCode);
  //取了符串的MD5
  AddFunction('function GetMd5(Value: string; NeedUpperCase: boolean): string;', @GetMd5);
  AddFunction('function StreamToMD5(S: TStream): String;', @StreamToMD5);
  //压缩图片
  AddFunction('function StretchImage(SourceFileName, AddStr:String; MaxWidth, MaxHigth: integer): boolean;', @StretchImage);
  //文件名前加前缀
  AddFunction('function FileNameAddStr(FileName, AddStrs: String): string;', @FileNameAddStr);
  //DeleteOneFile_From_Dir(const Path: string; const DelFileName: string)
  //删除给定目录下存在的文件
  AddFunction('procedure DeleteFile_From_Dir(const Path: string; const DelFileName: string);', @DeleteFile_From_Dir);
  AddFunction('function UrlEncode(URL: String): String;', @UrlEncode);
  AddFunction('function UrlDecode(URL: String): String;', @UrlDecode);
  //class function FillCharEx(Text, Sub: String; Len: integer): String;
  AddFunction('function FillCharEx(Text, Sub: String; Len: integer): String;', @TPub_FillCharEx);
  AddFunction('function GetDeliBack(Text, Delimite: String): String;', @TPub_GetDeliBack);
  AddFunction('function GetDeliPri(Text, Delimite: String): String;', @TPub_GetDeliPri);
  AddFunction('function ReplaceBaiFendHao(Text: String): String;', @TPub_ReplaceBaiFendHao);
  AddFunction('function ReplaceHTML(Text: String): String;', @TPub_ReplaceHTML);
  AddFunction('function ReplaceAll(Text: String): String;', @TPub_ReplaceAll);

  //数学运算 start
  AddFunction('function IsValNull(value: String): boolean;', @IsValNull);
  AddFunction('function IsNum(value: String): boolean;', @IsNum);
  AddFunction('function Math_Ad(v1, v2: String): string;', @Ad);
  AddFunction('function Math_Su(v1, v2: String): string;', @Su);
  AddFunction('function Math_Di(v1, v2: String): string;', @Di);
  AddFunction('function Math_Mu(v1, v2: String): string;', @Mu);
  AddFunction('function Math_Abs(v1: String): string;', @MyAbs);
  AddFunction('function Math_Decimal(V1: string; digcount: integer): string;', @MyDecimal);
  AddFunction('function Math_DecimalEx(V1: string; digcount: integer): string;', @DecimalEx);//保留小数位，为整数或不足小数位自动补0  2014-07-30 add
  AddFunction('function Math_Trunc(v1: String): string;', @MyTrunc);//截断取整, 不舍入
  AddFunction('function Math_TruncEx(v1: String): string;', @TruncEx); //取整, 只要有小数，则整数加1
  AddFunction('function Math_Precision(v1: String): integer;', @Precision); //取整数位数
  AddFunction('function Math_DecimalDig(v1: String): integer;', @DecimalDig);//取小数位数
  AddFunction('function Math_Round(v1: String): string;', @MyRound);
  AddFunction('function Math_IsLess(v1, v2: String): boolean;', @Math_IsLess);
  AddFunction('function Math_IsLessEqual(v1, v2: String): boolean;', @Math_IsLessEqual);
  AddFunction('function Math_IsEqual(v1, v2: String): boolean;', @Math_IsEqual);

  AddFunction('function Math_IsGreaterEqual(v1, v2: String): boolean;', @Math_IsGreaterEqual);
  AddFunction('function Math_IsPosOrZero(v1: String): boolean;', @Math_IsPosOrZero);
  AddFunction('function Math_IsPositive(v1: String): boolean;', @Math_IsPositive);
  AddFunction('function Math_IsNegOrZero(v1: String): boolean;', @Math_IsNegOrZero);
  AddFunction('function Math_IsNegative(v1: String): boolean;', @Math_IsNegative);
  AddFunction('function Math_IsValidValue(v1: String): boolean;', @Math_IsValidValue); //判断是否是一个合法的数值型
  AddFunction('function Math_IsValidValueEx(v1: String): string;', @Math_IsValidValueEx);//判断数值型是否合法，主要用在DBgridEh中判断列是否是合法的数值型用, 不合法返空，否则返原数
  AddFunction('function Math_IsValidDate(v1: String): boolean;', @Math_IsValidDate);
  AddFunction('function Math_IsValidDateTime(v1: String): boolean;', @Math_IsValidDateTime);
  AddFunction('function Math_IsValidTime(v1: String): boolean;', @Math_IsValidTime);
  AddFunction('function Math_ChangeFloat(v1: String): string;', @Math_ChangeFloat);//如把7.58671769249862E-5 转为0.0000758671769250
  AddFunction('function Math_Format(FormatStr, v1: String): string;', @Math_Format);
  AddFunction('function Math_IsValNull(v1: String): boolean;', @IsValNull);    //  }
  AddFunction('function SetPWD(Text: string; Key: string): string;', @SetPWD);
  AddFunction('function GetPWD(Text: string; Key: string): string;', @GetPWD);
  //数学运算 end

  AddFunction('function DBMemory_Save(Content, ToPath, Fields_info: string): string;', @DBMemory_Save);
  AddFunction('function DBMemory_Load(mds: THjhMemoryDataSet; ToPath, Fields_info: string): string;', @DBMemory_Load);
  AddFunction('function DBMemory_MxSave(mds: THjhMemoryDataSet; ToPath, Fields_info: string): string;', @DBMemory_MxSave);
  //不需要，调用DBMemory_Load AddFunction('function DBMemory_MxLoad(mds: THjhMemoryDataSet; FromPath: string): string;', @DBMemory_MxLoad);
  AddFunction('function Decrypt_ds(mds: TminiQuery; Fields_info: string): string;', @Decrypt_ds);

  //写日志
  //访问日志，开启记录选项才记录
  AddFunction('procedure WriteServiceLogToFile(Port: integer; Request: TminiHTTPRequest)', @WriteServiceLogToFile);
  //运行日志, 必须记录（如意外出错情况，服务器运行信息）
  AddFunction('procedure WriteRunLogToFile(Text: string);', @WriteRunLogToFile);
  AddFunction('procedure Sleep(dwMilliseconds: integer)', @Sleep); //获取最后执行错误


  (*
  function DBMemory_MxSave(mds: THjhMemoryDataSet; ToPath: string): string;
  function DBMemory_MxLoad(mds: THjhMemoryDataSet; FromPath: string): string;

  //2022-02-16 add 支付宝当面付接口
  //class function ALiPay_当面付获取付款连接(AppId, URL_PAY, PrivaeKeyPath_Pem, OrdNum, Memo, PayAmt, timeout_express: string; var qr_code: string): string;
  RegisterFakeHeader(0, 'function Alipay_trade_recreate(AppId, URL_PAY, PrivaeKeyPath_Pem, OrdNum, Memo, PayAmt, timeout_express: string; var qr_code: string): string;', @Alipay_trade_recreate);
  //class function ALiPay_当面付获取付款状态(AppId, URL_PAY, PrivaeKeyPath_Pem, OrdNum: string): string;
  RegisterFakeHeader(0, 'function Alipay_trade_query(AppId, URL_PAY, PrivaeKeyPath_Pem, OrdNum: string): string;', @Alipay_trade_query);
  *)
end;

procedure SIRegister_Others(Cl: TPSPascalCompiler);
var
  PSRuntimeClass: TPSCompileTimeClass;
begin
  {PSRuntimeClass := cl.FindClass('TStream');
  with PSRuntimeClass do
  begin
    RegisterProperty('Position', 'Integer', iptrw);
    RegisterProperty('Size', 'Integer', iptrw);
  end;}

  with Cl.AddClassN(cl.FindClass('TObject'), 'TSearchRec') do
  begin

    RegisterMethod('constructor Create');

    RegisterProperty('Time', 'integer', iptRW);
    RegisterProperty('Size', 'Integer', iptRW);
    RegisterProperty('Size', 'Int64', iptR);
    RegisterProperty('Attr', 'integer', iptRW);
    RegisterProperty('Name', 'string', iptRW);
    RegisterProperty('ExcludeAttr', 'integer', iptRW);
    RegisterProperty('FindHandle', 'Thandle', iptRW);
  end;
  {

    property Time: Integer read FTime write SetTime;
    property Size: Int64 read FSize write SetSize;
    property Attr: Integer read FAttr write SetAttr;
    property Name: string read FName write SetName;
    property ExcludeAttr: Integer read FExcludeAttr write SetExcludeAttr;
    property FindHandle: THandle read FFindHandle write SetFindHandle;

  }


  //faAnyFile     = $000001FF;
  cl.AddConstantN('faAnyFile', 'Integer').Value.tS32 := $000001FF;
  cl.AddConstantN('faDirectory', 'Integer').Value.tS32 := $00000010;
  cl.AddConstantN('MaxInt', 'Integer').Value.ts32 := MaxInt;
  cl.addTypeS('TReplaceFlag','(rfReplaceAll, rfIgnoreCase)');
  cl.addTypeS('TReplaceFlags','set of TReplaceFlag');
  {这个脚本控件对 record 支持有bug, 要绕开
  // TSearchRec
  cl.AddTypeS('TSearchRec', 'record ' +

  ' Time: Integer; ' +
  ' Size: Int64; ' +
  ' Attr: Integer; ' +
  ' Name: string; ' +
  ' ExcludeAttr: Integer; ' +
  ' FindHandle: THandle; ' +
  //' FindData: TWin32FindData; '
  ' end;');}
end;

procedure TStrings_LoadFromFile(Self: TStrings; FileName: string);
begin
  flastError := '';
  try
    try
      Self.LoadFromFile(FileName, TEncoding.UTF8);
    except
      Self.LoadFromFile(FileName, TEncoding.ANSI);
    end;
  except
    on e: exception do
      flastError := e.Message;
  end;
end;

procedure TStrings_SaveToFile(Self: TStrings; FileName: string);
begin
  flastError := '';
  try
    try
      Self.SaveToFile(FileName, TEncoding.UTF8);
    except
      Self.SaveToFile(FileName);
    end;
  except
    on e: exception do
      flastError := e.Message;
  end;
end;

procedure TSearchRecSize_R(Self: minicomponents.TSearchRec; var Size: Int64);
begin
  flastError := '';
  try
    Size := Self.Size;
  except
    on e: exception do
      flastError := e.Message;
  end;
end;

procedure TSearchRecSize_W(Self: minicomponents.TSearchRec; Size: Int64);
begin
  flastError := '';
  try
    Self.Size := Size;
  except
    on e: exception do
      flastError := e.Message;
  end;
end;

procedure TStreamSize_R(Self: TStream; var Size: Int64);
begin
  flastError := '';
  try
    Size := Self.Size;
  except
    on e: exception do
      flastError := e.Message;
  end;
end;

procedure TStreamSize_W(Self: TStream; Size: Int64);
begin
  flastError := '';
  try
    Self.Size := Size;
  except
    on e: exception do
      flastError := e.Message;
  end;
end;
procedure TStreamPosition_R(Self: TStream; var P: Int64);
begin
  flastError := '';
  try
    P := Self.Position;
  except
    on e: exception do
      flastError := e.Message;
  end;
end;

procedure TStreamPosition_W(Self: TStream; P: Int64);
begin
  flastError := '';
  try
    Self.Position := P;
  except
    on e: exception do
      flastError := e.Message;
  end;
end;

procedure TMemoryStream_LoadFromFile(Self: TMemoryStream; FileName: string);
begin
  flastError := '';
  try
    Self.LoadFromFile(FileName);
  except
    on e: exception do
      flastError := e.Message;
  end;
end;

procedure TMemoryStream_LoadFromStream(Self: TMemoryStream; Stream: TStream);
begin
  flastError := '';
  try
    Self.LoadFromStream(Stream);
  except
    on e: exception do
      flastError := e.Message;
  end;
end;

procedure TCustomMemoryStream_SaveToFile(Self: TMemoryStream; FileName: string);
begin
  flastError := '';
  try
    Self.SaveToFile(FileName);
  except
    on e: exception do
      flastError := e.Message;
  end;
end;
procedure TCustomMemoryStream_SaveToStream(Self: TMemoryStream; Stream: TMemoryStream);
begin
  flastError := '';
  try
    Self.SaveToStream(Stream);
  except
    on e: exception do
      flastError := e.Message;
  end;
end;

procedure RIRegister_Others(Cl: TPSRuntimeClassImporter);
var
  PSRuntimeClass: TPSRuntimeClass;
begin
  with Cl.Add(minicomponents.TSearchRec) do
  begin
    RegisterConstructor(@minicomponents.TSearchRec.Create, 'Create');
    RegisterPropertyHelperName(@TSearchRecSize_R, nil{@TSearchRecSize_W}, 'Size');
  end;

    {PSRuntimeClass := cl.FindClass('TStream');
  with PSRuntimeClass do
  begin
    RegisterPropertyHelperName(@TStreamPosition_R, @TStreamPosition_W, 'Position');
    RegisterPropertyHelperName(@TStreamSize_R, @TStreamSize_W, 'Size');
  end; }

  PSRuntimeClass := cl.FindClass('TStrings');
  with PSRuntimeClass do
  begin
    //注意：需要重写LoadFromFile，用原来的在laz下会有报错，并且改为保存utf-8
    RegisterMethod(@TStrings_LoadFromFile, 'LoadFromFile');
    RegisterMethod(@TStrings_SaveToFile, 'SaveToFile');
  end;

  {$ifdef fpc}
  PSRuntimeClass := cl.FindClass('TCustomMemoryStream');
  with PSRuntimeClass do
  begin
    //注意：需要重写LoadFromFile，是为了laz不出错
    RegisterMethod(@TCustomMemoryStream_SaveToFile, 'SaveToFile');
    RegisterMethod(@TCustomMemoryStream_SaveToStream, 'TMemoryStream_SaveToStream');
  end;
  PSRuntimeClass := cl.FindClass('TMemoryStream');
  with PSRuntimeClass do
  begin
    //注意：需要重写LoadFromFile，是为了laz不出错
    RegisterMethod(@TMemoryStream_LoadFromFile, 'LoadFromFile');
    RegisterMethod(@TMemoryStream_LoadFromStream, 'LoadFromStream');
  end;

  PSRuntimeClass := cl.FindClass('TFileStream');
  with PSRuntimeClass do
  begin
    RegisterConstructor(@TFileStream.Create, 'Create');
  end;

  {$endif}
end;

//const
  //PSClassType = '!ROClass';
  //MyGuid: TGuid = '{4B86A9E3-E094-4E5A-954A-69048B7B6327}';

procedure TminiJsonOR(Self: TminiJson; var T: TminiJson; I: string);
begin
  T := Self.O[I];
end;
procedure TminiJsonOW(Self: TminiJson; const T: TminiJson; I: string);
begin
  Self.O[I]:= T;
end;
procedure TminiJsonSR(Self: TminiJson; var T: string; I: string);
begin
  T := Self.S[I];
end;
procedure TminiJsonSW(Self: TminiJson; const T: string; I: string);
begin
  Self.S[I]:= T;
end;

{procedure TminiJsonArrayOR(Self: TminiJsonArray; var T: TminiJson; I: integer);
begin
  T := Self.O[I];
end;
procedure TminiJsonArrayOW(Self: TminiJsonArray; const T: TminiJson; I: integer);
begin
  Self.O[I].mainI := TminiJson(T).mainI;
end;

procedure TminiJsonNR(Self: TminiJson; var T: TminiJson; path: string);
begin
  T := Self.N[path];
end;
procedure TminiJsonNW(Self: TminiJson; const T: TminiJson; path: string);
begin
  Self.N[path] := T;
end;}

procedure TminiJsonBR(Self: TminiJson; var T: boolean; path: string);
begin
  T := Self.B[path];
end;
procedure TminiJsonBW(Self: TminiJson; const T: boolean; path: string);
begin
  Self.B[path] := T;
end;

procedure TminiJsonIR(Self: TminiJson; var T: int64; path: string);
begin
  T := Self.I[path];
end;
procedure TminiJsonIW(Self: TminiJson; const T: int64; path: string);
begin
  Self.I[path] := T;
end;

procedure TminiJsonAR(Self: TminiJson; var T: TminiJson; path: string);
begin
  T := Self.A[path];
  {T := TminiJson.Create;
  Self.AddObject(T);
  T.mainI := Self.mainI.A[Path]^;
  //T := Self.A[path];    }
end;

procedure TminiJsonItemsR(Self: TminiJson; var T: TminiJson; index: integer);
begin //TminiJsonItemsR, @TminiJsonItemsW
  T := Self.Items[index];
end;

procedure TminiJsonNamesR(Self: TminiJson; var T: string; index: integer);
begin
  T := Self.Names[index];
end;

procedure TminiJsonValuesR(Self: TminiJson; var T: Variant; index: integer);
begin
  T := Self.Values[index];
end;

procedure TminiJsonAW(Self: TminiJson; T: TminiJson; path: string);
begin
  Self.A[path] := T;
end;

procedure TminiJsonA_SW(Self: TminiJson; T: string; path: string);
begin
  Self.A_S[path] := T;
end;

procedure TminiJsonA_GSW(Self: TminiJson; var T: string; index: integer);
begin
  T := Self.A_GS[index];
end;

procedure TminiJsonA_IW(Self: TminiJson; T: int64; path: string);
begin
  Self.A_I[path] := T;
end;

procedure TminiJsonA_GIW(Self: TminiJson; var T: int64; index: integer);
begin
  T := Self.A_GI[index];
end;

procedure TminiJsonA_BW(Self: TminiJson; T: boolean; path: string);
begin
  Self.A_B[path] := T;
end;

procedure TminiJsonA_GBW(Self: TminiJson; var T: boolean; index: integer);
begin
  T := Self.A_GB[index];
end;

procedure TminiJsonA_DW(Self: TminiJson; T: double; path: string);
begin
  Self.A_D[path] := T;
end;

procedure TminiJsonA_GDW(Self: TminiJson; var T: double; index: integer);
begin
  T := Self.A_GD[index];
end;


procedure TminiJsonDR(Self: TminiJson; var T: double; path: string);
begin
  T := Self.D[path];
end;
procedure TminiJsonDW(Self: TminiJson; const T: double; path: string);
begin
  Self.D[path] := T;
end;

procedure RIRegister_Json(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TminiJson) do
  begin
    //RegisterConstructor(@TminiJson.Create, 'Create'); //需要创建，用Pub.GetJson ，无需要释放，自动管理
    RegisterMethod(@TminiJson.AsJSon, 'AsJSon');
    RegisterMethod(@TminiJson.IsType, 'IsType');
    RegisterMethod(@TminiJson.SO, 'SO');
    RegisterMethod(@TminiJson.SOS, 'SOS');
    RegisterMethod(@TminiJson.SOA, 'SOA');

    RegisterMethod(@TminiJson.SO, 'Init');
    RegisterMethod(@TminiJson.SOS, 'InitS');
    RegisterMethod(@TminiJson.SOA, 'InitA');
    RegisterMethod(@TminiJson.Clear, 'Clear');

    RegisterMethod(@TminiJson.DeleteByIndex, 'DeleteByIndex');
    RegisterMethod(@TminiJson.DeleteByName, 'DeleteByName');
    RegisterMethod(@TminiJson.DeleteByPath, 'DeleteByPath');

    RegisterMethod(@TminiJson.SaveToStream, 'SaveToStream');
    RegisterMethod(@TminiJson.SaveToFile, 'SaveToFile');
    RegisterMethod(@TminiJson.LoadFromFile, 'LoadFromFile');
    RegisterMethod(@TminiJson.LoadFromStream, 'LoadFromStream');
    RegisterMethod(@TminiJson.LoadFromString, 'LoadFromString');

    RegisterPropertyHelper(@TminiJsonOR, @TminiJsonOW, 'O');
    RegisterPropertyHelper(@TminiJsonBR, @TminiJsonBW, 'B');
    RegisterPropertyHelper(@TminiJsonIR, @TminiJsonIW, 'I');
    RegisterPropertyHelper(@TminiJsonDR, @TminiJsonDW, 'D');
    RegisterPropertyHelper(@TminiJsonSR, @TminiJsonSW, 'S');
   
    RegisterPropertyHelper(@TminiJsonAR, @TminiJsonAW, 'A');
    RegisterPropertyHelper(nil, @TminiJsonA_SW, 'A_S');
    RegisterPropertyHelper(@TminiJsonA_GSW, nil, 'A_GS');

    RegisterPropertyHelper(nil, @TminiJsonA_IW, 'A_I');
    RegisterPropertyHelper(@TminiJsonA_GIW, nil, 'A_GI');

    RegisterPropertyHelper(nil, @TminiJsonA_BW, 'A_B');
    RegisterPropertyHelper(@TminiJsonA_GBW, nil, 'A_GB');
    RegisterPropertyHelper(nil, @TminiJsonA_DW, 'A_D');
    RegisterPropertyHelper(@TminiJsonA_GDW, nil, 'A_GD');

    RegisterPropertyHelper(@TminiJsonItemsR, nil, 'Items');

    RegisterPropertyHelper(@TminiJsonNamesR, nil, 'Names');
    RegisterPropertyHelper(@TminiJsonValuesR, nil, 'Values');
  end;

end;

procedure SIRegister_Json(Cl: TPSPascalCompiler);
begin
  //cl.addTypeS('TSuperType','(stNull,stBoolean,stDouble,stCurrency,stInt,stObject,stArray,stString,stMethod)');
  cl.addTypeS('SOString','String');
  //cl.addTypeS('RawUtf8','UTF8String');
  //cl.addTypeS('TDataType','(dtNil, dtNull, dtObject, dtArray, dtString, dtInteger, dtFloat, dtBoolean, dtDateTime, dtDate, dtTime)');
  cl.addTypeS('TDocVariantKind','(dvUndefined,dvObject,dvArray)');
  //cl.addTypeS('TRawUtf8DynArray','array of RawUtf8');
  //cl.addTypeS('TVariantDynArray','array of variant'); //TVariantDynArray = array of variant

  //TminiJson
  with Cl.AddClassN(cl.FindClass('TObject'), 'TminiJson') do
  begin
    ///RegisterMethod('constructor Create'); //需要创建，用Pub.GetJson ，无需要释放，自动管理
    RegisterMethod('function IsType(AType: TDocVariantKind): boolean');
    RegisterMethod('procedure SO');
    RegisterMethod('procedure SOS(const s: string)');
    RegisterMethod('procedure SOA(const Args: array of const)');

    RegisterMethod('procedure Init');
    RegisterMethod('procedure InitS(const s: string)');
    RegisterMethod('procedure InitA(const Args: array of const)');
    RegisterMethod('procedure Clear');

    RegisterMethod('function DeleteByIndex(Index: integer): boolean');
    RegisterMethod('function DeleteByName(const aName: string): boolean');
    RegisterMethod('function DeleteByPath(const aPath: string): boolean');

    RegisterMethod('function AsJSon(indent: boolean): string');

    RegisterMethod('function SaveToStream(stream: TStream): string');
    RegisterMethod('function SaveToFile(const FileName: string): string');
    RegisterMethod('function LoadFromFile(FileName: string): string');
    RegisterMethod('function LoadFromStream(stream: TStream): string');
    RegisterMethod('function LoadFromString(s: string): string');

    RegisterProperty('mainI', 'ISuperObject', iptrw);
    RegisterProperty('O', 'TminiJson string', iptRW);
    //SetDefaultPropery('O');

    RegisterProperty('S', 'string string', iptrw);
    //RegisterProperty('N', 'TminiJson string', iptrw);
    RegisterProperty('B', 'boolean string', iptrw);
    RegisterProperty('I', 'int64 string', iptrw);
    RegisterProperty('D', 'double string', iptrw);
    //RegisterProperty('C', 'Currency string', iptrw);

    RegisterProperty('Count', 'integer', iptr);
    RegisterProperty('Length', 'integer', iptr);

    RegisterProperty('A', 'TminiJson string', iptRW);
    RegisterProperty('A_S', 'string string', iptW);
    RegisterProperty('A_GS', 'string integer', iptR);
    RegisterProperty('A_I', 'int64 string', iptW);
    RegisterProperty('A_GI', 'int64 integer', iptR);
    RegisterProperty('A_B', 'boolean string', iptW);
    RegisterProperty('A_GB', 'boolean integer', iptR);
    RegisterProperty('A_D', 'double string', iptW);
    RegisterProperty('A_GD', 'double integer', iptR);

    RegisterProperty('Items', 'TminiJson integer', iptR);
    SetDefaultPropery('Items');
    RegisterProperty('Names', 'string integer', iptR);
    RegisterProperty('Values', 'Variant integer', iptR);
  end;
end;

end.


