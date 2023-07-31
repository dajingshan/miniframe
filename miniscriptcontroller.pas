
//////////////////////////////////////////////////////////////////////////////////
///                                                                            ///
///  miniframe开源Web框架技术群：821855479 如果加不了群，请联系QQ：3123827806  ///
///  网页制作器网址：https://wyeditor.com                                      ///
///  源码及demo下载：https://wyeditor.com/miniframe/                           ///
///                                                                            ///
//////////////////////////////////////////////////////////////////////////////////

unit miniscriptcontroller;

//{$mode objfpc}{$H+}
{$IFDEF FPC}{$MODE DELPHI}{$H+}{$ENDIF}

{.$define nonecachescript} {nonecachescript 不允许缓存脚本}

{$define nonedmmaxcount} {nonedmmaxcount 不控制对象池总数}
interface

uses
  Classes, SysUtils, IdGlobal, Controls, DataPackageUnit,

  minidb, miniPub, db, MyDataTypeMapUni,
  Uni, UniScript, Generics.Collections, uPSRuntime,

  uPSComponent_DB,
  uPSCompiler, uPSC_std, uPSC_classes,
  uPSC_Controls,  uPSComponent, IdGlobalProtocols, DateUtils,
  uPSC_graphics, uPSR_graphics,
  uPSR_std,
  //这种方法fpc不能用，另外注册 uPSR_dateutils, uPSC_dateutils,
  uPSR_controls,
  uPSR_stdctrls,
  uPSR_classes,
  ///uPSC_forms, //服务端不需要
  ///uPSR_forms,
  uPSR_DB,
  uPSC_DB, uPSUtils,

  minihttp, miniregister,
  IdHttp, {$IFDEF FPC}FileUtil,Process,{$else}{$endif}PubPWDUnit{,
  uPSDisassembly}, {$ifdef MSWINDOWS}ShellApi, Windows,{$endif}MSDataTypeMapUni,
  SQLServerUniProvider, minicomponents;

type
  TminiPooler = class;

  TMiniPSScript = class;

  TPubbase = class;

  TDMInfo = class
    HadUsed: boolean;
    Start: TDateTime;
    PSScript1: TMiniPSScript;
    LastHtml: string;
    TmpSl: TStringList;
    Request: TminiHTTPRequest;
    Response: TminiHTTPResponse;

    Pub: TPubbase;
  end;

    { TMiniPSScript }

  TMiniPSScript = class(TPSScriptDebugger) //class(TPSScript)
    DMInfo: TDMInfo;
  private
    FMyIsComiled: boolean;
    procedure SetMyIsComiled(AValue: boolean);
  public
    constructor Create(AOwner: TComponent); override;
    property MyIsComiled: boolean read FMyIsComiled write SetMyIsComiled;
  end;

  TLogInfo = record
    FRunLog_File, FServiceLog_File: string;
    FIsLog: boolean;

    FTF, FTF_Run: TextFile;
    FTF_IsIni, FTF_IsIni_Run: boolean;
    MaxCount, AllCount, AllCount_Run: integer;
  end;

  TSSLFileInfo = record
    SSL_Domain: TStringlist;
    SSL_Key: TStringlist;
    SSL_Cer: TStringlist;
    //SSL_Obj: TList<TSslContext>;
  end;
  TScriptInfo = class
    FileName: string;
    MS: tbtstring;
    Used: boolean;
    Start: TDateTime;
    noparent: string; //2022-07-12 add
    AllFileNameList: TStringlist;
    AllFileTimeList: TList<TDatetime>;
  end;

  { TPubbase }

  TPubbase = class
  private
    FAZTCode: string;
    FConnPooler: TminiPooler;
    FZTCode: string;
    procedure SetZTCode(AValue: string);
  protected
    FList, FPoolerList: TList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Last;

    function TestConnect(dbhost, DbType, DBName, User, Pwd: string): string;
    class procedure SetConnParam(Conn: TminiConnection; dbhost, DbType, DBName, User, Pwd: string); static;

    //这样获取连接池实例，将不受是否停用影响
    function GetConnPooler(AZTCode: string): TminiPooler;
    //这样获取连接池实例，将受是否停用影响
    function GetConnPoolerEx(AZTCode: string; var ErrStr: string): TminiPooler;
    //数据库操作 start
    //连接到数据源
    function DB_C(AZTCode: string; var ErrStr: string): boolean;
    //执行一条SQL
    function DB_E(SQLText: string; var ErrStr: string; AZTCode: string=''): boolean;
    //执行一条SQL，打开数据集，数据返回到Query中
    function DB_O(SQLText: string; var ErrStr: string; AZTCode: string=''): boolean;
    function O(ZTCode: string; var PooledInfo: TminiPooler; var Query: TminiQuery; var ErrStr: string): boolean;
    //执行一条SQL，打开数据集，数据返回到MemTable中
    function DB_OMT(SQLText: string; var ErrStr: string; Mt1: TminiMemTable; AZTCode: string=''): boolean;
    //执行一条SQL，打开数据集，数据返回到THJHMemoryDataSet中
    function DB_ODS(SQLText: string; var ErrStr: string; ds: THjhMemoryDataSet; AZTCode: string=''): boolean;
    //执行一条SQL，把SQL语句返回的数据集生成到临时或固定表中，考虑了兼容不同的数据库问题
    function DB_ETEx(TableName, SQLText: string; IsTmpTBL: boolean; var ErrStr: string; Query1: TminiQuery): boolean;
    function DB_OT(SQLText, TableName: string; IsTmpTBL: boolean; var ErrStr: string; AZTCode: string=''): boolean;
    //数据库操作 end;

    property ZTCode: string read FZTCode write SetZTCode; //数据源

    function TmpSl: TStringList;
    function Conn: TminiConnection;
    function Query: TminiQuery;
    function mds: THjhMemoryDataSet;

    function DBName: string;
    function DBType: string;
    function Pooler: TminiPooler;
    procedure SetStartTime;

    //以下这些创建的对象，脚本中调用后不需要使用者释放，系统自动释放
    function CreateConn: TminiConnection;
    function CreateQuery: TminiQuery;
    function CreateStringlist: TStringlist;
    function CreateMemTable: TminiMemTable;
    function CreateMemoryDataSet: THjhMemoryDataSet;
    function CreateJson: TminiJson;
    function CreateMemoryStream: TMemoryStream;
    function CreateStoredProc: TminiStoredProc;
    function CreateFileStream(FileName: string; Mode: Integer; Var ErrStr: String): TFileStream;
  published

  end;

  { TConnPooledInfo }

  { TminiPooler }

  TminiPooler = class
    AZTCode, FDBName, FDBType: string;
    Start: TDateTime;
    aConnection1: TminiConnection;
    aQuery1: TminiQuery;
    aTmpSl: TStringList;
    aHJHMemodataset: THjhMemoryDataSet;
  private
    FHadUsed: boolean;
    Fztstop: boolean;
    procedure SetHadUsed(AValue: boolean);
    procedure Setztstop(const Value: boolean);
  public
    constructor Create();
    function GetTminiConnection: TminiConnection;
    function Conn: TminiConnection;
    function Query: TminiQuery;
    //function MemTable: TminiMemTable;
    function TmpSl: TStringList;
    function mds: THjhMemoryDataSet;
    function DBName: string;
    function DBType: string;
  published
    property HadUsed: boolean read FHadUsed write SetHadUsed;
    property ztstop: boolean read Fztstop write Setztstop;
    //property FDConnection1: TFDConnection read GetTminiConnection;
  end;
  TConnPooledInfo = class(TminiPooler)
  end;

  { TRunner }

  TRunner = class
  private

  public
    class procedure PPSScriptExecute(Sender: TPSScript);
    class procedure PPSScript1ExecImport(Sender: TObject; se: TPSExec;
      x: TPSRuntimeClassImporter);

    class procedure PPSScript1CompImport(Sender: TObject; x: TPSPascalCompiler);
    class procedure RunOnePspFile(DMInfo: TDMInfo; Session: TObject; Service_Path, FileName: string; Port: integer;
      Request: TminiHTTPRequest; Response: TminiHTTPResponse);
    class procedure PSScript1Compile(Sender: TPSScript);
    class procedure GoToErrPage(DMInfo: TDMInfo; Session: TObject; Service_Path, FileName: string;
      Port: integer; Request: TminiHTTPRequest; Response: TminiHTTPResponse; addstr: string = '');
    class procedure LoadYSFile(Port: integer; //Host, RemoteIP, RemotePort, Document, RawHTTPCommand: string;
      YsHost, FileName: string; ARequestInfo: TminiHTTPRequest; Response: TminiHTTPResponse);
    class procedure LoadOtherFile(OldLDoc, FileName: string; Port: integer; Request: TminiHTTPRequest; Response: TminiHTTPResponse);
  end;

  TServerInfo = record
    serviceext, YsHost, clientcachefile, hosttodir, oldhosttodir, ApachePath, mainservicepath,
      errorpage, autopcandmobileext: string;
    ProgramPath: string;
    crossdomain, NeedStartSession, AutoZip, autopcandmobile, servernocachefile: boolean;
    Poolermaxcount, poolermincount, poolertimeout, threadcount, quequelength: integer;
    DirSL, hosttodirSL, CacheName, exttoserver, CacheText: TStringList;
    sessiontimeout, maxsessioncount: integer;

    httpport, httpsport: string;
    starthttps: boolean;
    rootcert, cert, secretkey, secretkeypwd: string;
    openby127_0_0_1: boolean; //2023-05-22 add
    Starttime: TDateTime;

    blacklist, whitelist: TStringlist;
    Usedblacklist, Usedwhitelist: TStringlist;
  end;
  TGarbageCollector = class(TThread)
  private
    procedure RefInfo;
  protected
    procedure Execute; override;
  public
    constructor Create();
    destructor Destroy; override;
  end;


  //写日志start
  //访问日志，开启记录选项才记录
  procedure WriteServiceLogToFile(Port: integer; Request: TminiHTTPRequest; ClientIP: string = ''; Document: string = ''; UserAgent: string = ''; Host: string = '');
  //运行日志, 必须记录（如意外出错情况，服务器运行信息）
  procedure WriteRunLogToFile(Text: string);
  //内部用，定时线程日志
  procedure WriteInnerLog(Text: string);
  //写日志end

  function FindNoUseConn(AZTCode: string; ConnList: Classes.Tlist): integer;
  function FindNoUseDm(DMList: Classes.Tlist): integer;

  function GetService_Path(Host, Document: string; var IsSetting: boolean): string;
  function GetYs_From_EXT(Ext: string; var Host: string): boolean;
  function GetFileContentType(FileName: string): string;
  function MyRedirect(Headers, OldLDoc: string): string;
  function GetOthInfo(Port: integer; Request: TminiHTTPRequest): string;
  function GetDMInfo(Request: TObject): TDMInfo;


var
  FLogInfo: TLogInfo;
  ServerInfo: TServerInfo;
  DMList, ScriptList, ConnList: Classes.TList;

implementation

uses mormothttps, PubFileUnit, SelfDefine;

var
  GarbageCollector: TGarbageCollector;
  QueList: TList<TObject>;
  FIsFreeAllObj: boolean = false;
  MIMEMap: TIdMIMETable;
  CriticalSection, CriticalSection_Log, CriticalSection_RunLog, CriticalSection_Conn, CriticalSection_Script, CriticalSection_Sqe: TMiniCriticalSection;


function MyRedirect(Headers, OldLDoc: string): string;
var
  SS: TStringStream;
  cache, Contentext: string;
begin
  //MeCriticalSection2.Enter; //2022-04-08 add
  try
    cache :=
      'Location: ' + OldLDoc + #13#10 +

      'Date: ' + LocalDateTimeToHttpStr(Now) + #13#10 +
      'Expires: '+ LocalDateTimeToHttpStr(IncDay(Now, -30));

    //Headers := 'Location: "http://huo"';
    Headers := cache + #13#10 + Headers;

    //Headers := Headers + #13#10'Location: ' + OldLDoc + #13#10;

    //2022-11-21 Client.AnswerString(Flags, '302', '', Headers, Contentext);
    Result := Headers;
  finally
    //MeCriticalSection2.Leave; //2022-04-08 add
  end;
end;

function GetFileContentType(FileName: string): string;
var
  Ext: string;
begin
  Ext := LowerCase(ExtractFileExt(FileName));

  if Ext = '.css' then
    Result := 'text/css'
  else
  if Ext = '.js' then
    Result := 'text/javascript'
  else
  if Ext = '.jpg' then
    Result := 'image/jpeg'
  else
  if Ext = '.jpeg' then
    Result := 'image/jpeg'
  else
  if Ext = '.png' then
    Result := 'image/x-png'
  else
  if Ext = '.gif' then
    Result := 'image/gif'
  else
  if Ext = '.svg' then
    Result := 'image/svg+xml'
  else
  if Ext = '.rar' then
    Result := 'application/rar'
  else
  if Ext = '.dll' then
    Result := 'application/dll'
  else
  if Ext = '.exe' then
    Result := 'application/x-msdos-program'
  else
  if Ext = '.pdf' then
    Result := 'application/pdf'
  else
  if Ext = '.apk' then
    Result := 'application/vnd.android'
  else
  if (Ext = '.doc') or (Ext = '.dot') or (Ext = '.docx') then
    Result := 'application/msword'
  else
  if (Ext = '.xls') or (Ext = '.xlsx') then
    Result := 'application/x-msexcel'
  else
  if Ext = '.ico' then
    Result := 'image/x-icon'
  else
  if Ext = '.bmp' then
    Result := 'image/bmp'
  else
  if Ext = '.txt' then
    Result := 'text/plain'
  else
  if Ext = '.mp2' then
    Result := 'video/mpeg'
  else
  if Ext = '.mp3' then
    Result := 'video/mpeg'
  else
  if Ext = '.mp4' then
    Result := 'video/mpeg'
  else
  if Ext = '.mpeg' then
    Result := 'video/x-mpeg2a'
  else
  if Ext = '.ico' then
    Result := 'image/x-icon'
  else
  if Ext = '.7z' then
    Result := 'application/x-7z-compressed'
  else
    Result := MIMEMap.GetFileMIMEType(FileName);

end;

function GetService_Path(Host, Document: string; var IsSetting: boolean): string;
var
  index: integer;
begin

  if (Pos('/$/', Document) = 1) or SameText('/$', Document) then
  begin
    Result := ServerInfo.ProgramPath;
    IsSetting := true;
  end else
  begin
    IsSetting := false;
    //if Request.Session <> nil then
    //  Result := Request.Session.Values['ServicePath'];
    if trim(Result) = '' then
    begin //host: '127.0.0.1:899'
      Host := LowerCase(GetDeliPri(Host, ':'));
      Host := GetDeliBack(Host, 'www.');
      Index := ServerInfo.hosttodirSL.IndexOf(Host);
      if Index > -1 then
        Result := ServerInfo.DirSL[Index]
      else
        Result := ServerInfo.mainservicepath;
      Result := PathWithSlash(Result);
      //if Request.Session <> nil then
        //Request.Session.Values['ServicePath'] := Result;
    end;
  end;
end;
function FindNoUseConn(AZTCode: string; ConnList: Classes.Tlist): integer;
var
  lp: integer;
begin
  //Result := Connlist.IndexOf(Key);      HadUsed
  Result := -1;
  for lp := 0 to ConnList.Count - 1  do
  begin
    if (not TminiPooler(ConnList[lp]).HadUsed) and (LowerCase(TminiPooler(ConnList[lp]).AZTCode) = LowerCase(AZTCode)) then
    begin
      Result := lp;
      break;
    end;
  end;
end;

function FindNoUseDm(DMList: Classes.Tlist): integer;
var
  lp: integer;
begin
  Result := -1;
  for lp := 0 to DMList.Count - 1  do
  if (not TDMInfo(DMList[lp]).HadUsed) then
  begin
    Result := lp;
    break;
  end;
end;

{ TminiPooler }

procedure TminiPooler.SetHadUsed(AValue: boolean);
begin
  if FHadUsed=AValue then Exit;
  FHadUsed:=AValue;
end;

procedure TminiPooler.Setztstop(const Value: boolean);
begin
  Fztstop := Value;
end;

constructor TminiPooler.Create;
begin
  aHJHMemodataset := nil;
end;

function TminiPooler.DBName: string;
begin
  Result := FDBName;
end;

function TminiPooler.DBType: string;
begin
  Result := FDBType;
end;

function TminiPooler.GetTminiConnection: TminiConnection;
begin
  Result := Conn;
end;

function TminiPooler.mds: THjhMemoryDataSet;
begin
  if aHJHMemodataset = nil then
    aHJHMemodataset := THjhMemoryDataSet.Create(nil);
  Result := aHJHMemodataset;
end;

function TminiPooler.Conn: TminiConnection;
begin
  Result := aConnection1;
end;

function TminiPooler.Query: TminiQuery;
begin
  Result := aQuery1;
end;

function TminiPooler.TmpSl: TStringList;
begin
  Result := aTmpSl;
end;

{ TMiniPSScript }

procedure TMiniPSScript.SetMyIsComiled(AValue: boolean);
begin
  if FMyIsComiled=AValue then Exit;
  FMyIsComiled:=AValue;
end;

constructor TMiniPSScript.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMyIsComiled := false;
end;

{ TPubbase }

procedure TPubbase.SetZTCode(AValue: string);
begin
  if FZTCode=AValue then Exit;
  FZTCode:=AValue;
end;

procedure TPubbase.SetStartTime;
begin
  if FConnPooler <> nil then
    FConnPooler.Start := Now;
end;

constructor TPubbase.Create;
begin
  FConnPooler := nil;
  FList := TList.Create;
  FList.Clear;
  FPoolerList := TList.Create;
end;

procedure TPubbase.Last;
var
  lp: integer;
begin
  try
    if FConnPooler <> nil then
      FConnPooler.HadUsed := false;
  except
  end;
  for lp := 0 to FPoolerList.Count - 1 do
  try
    TminiPooler(FPoolerList.Items[lp]).HadUsed := false;
  except
  end;
  for lp := 0 to FList.Count - 1 do
  begin
    try
      if Assigned(FList.Items[lp]) and (TObject(FList.Items[lp]) is TObject) then
        TObject(FList.Items[lp]).Free;
    except
    end;
  end;
  FList.Clear;
end;

destructor TPubbase.Destroy;
begin
  Last;
  FList.Free;
  FPoolerList.Free;
  inherited;
end;

function TPubbase.GetConnPoolerEx(AZTCode: string; var ErrStr: string): TminiPooler;
begin
  ErrStr := '';
  if trim(AZTCode) = '' then AZTCode := FAZTCode;

  if AZTCode = '' then
  begin
    ErrStr := '数据源名称为空，不能继续(67999123)！';
    exit;
  end;
  try
    if (FConnPooler <> nil) and (AZTCode = FConnPooler.AZTCode) and (FConnPooler.HadUsed) then
    begin
      FConnPooler.Start := Now;
      Result := FConnPooler;
      exit;
    end;
  except
  end;

  try
    if (FConnPooler <> nil) then
      FConnPooler.HadUsed := false;

    Result := GetConnPooler(AZTCode);
    FConnPooler := Result;
    FAZTCode := AZTCode;
  except
    on e: exception do
    begin
      ErrStr := e.Message;
      exit;
    end;
  end;

  if FConnPooler.ztstop then
  begin
    ErrStr := '该账套已被停用，不能访问！';
    exit;
  end;


end;

function TPubbase.CreateMemoryStream: TMemoryStream;
begin
  Result := TMemoryStream.Create;
  FList.Add(Result);
end;

class procedure TPubbase.SetConnParam(Conn: TminiConnection; dbhost, DbType, DBName, User, Pwd: string);
var
  TmpStr, Port: string;
begin
  Port := '';
  //dbhost := ConnInfo.TmpSl[2];
  if Pos(':', dbhost) > 0 then
  begin
    Port := GetDeliBack(dbhost, ':');
    dbhost := GetDeliPri(dbhost, ':');
  end;
  if Pos(',', dbhost) > 0 then
  begin
    Port := GetDeliBack(dbhost, ':');
    dbhost := GetDeliPri(dbhost, ':');
  end;

  if SameText(DbType, 'MySQL') then
  begin
    Conn.DbType := 'mysql';
    Conn.DataTypeMap.AddDBTypeRule(myDecimal, ftFMTBCD);
    if trim(Port) = '' then Port := '3306';

    TmpStr := 'Provider Name=MySQL;Data Source=' +
      dbhost + ';database=' + DBName +
      ';User ID=' + User + ';Password=' +
      pwd + ';Login Prompt=False' + ';port=' + Port + ';CharacterSet=UTF8';

    Conn.ConnectString := TmpStr;
    Conn.SpecificOptions.Clear;
    Conn.SpecificOptions.Add('SQL Server.Provider=prDirect'); //解决乱码
  end else
  if SameText(DbType, 'SQLite') then
  begin
    Conn.DbType := 'sqlite';
    Conn.ConnectString := 'Provider Name=SQLite;Database=' + DBName;
  end else
  if SameText(DbType, 'Oracle') then
  begin
    Conn.DbType := 'oracle';
    Conn.ConnectString := 'Provider Name=Oracle;Data Source=' + dbhost + ';User ID=' + user + ';Password=' + Pwd;
    //Conn.DataTypeMap.AddDBTypeRule(oraVarchar2, ftString);
    //Conn.DataTypeMap.AddDBTypeRule(oraNVarchar2, ftWideString);
    //Conn.SpecificOptions.Values['Unicode'] := 'True';
  end else
  if SameText(DbType, 'ODBC') then
  begin
    Conn.DbType := DbType;
    Conn.ConnectString := 'Provider Name=ODBC;Server=' + dbhost + ';User ID=' + User + ';Password=' + Pwd;
  end else
  if SameText(DbType, 'MSSQL_OS') then
  begin
    Conn.BeforeConnect := Conn.ConnBeforeConnect;
    Conn.AfterConnect := Conn.COnnConnAfterDisconnect;
    Conn.DbType := 'mssql';
    Conn.DataTypeMap.AddDBTypeRule(msDecimal, ftFMTBCD);
    Conn.ConnectString :=
      'Provider Name=SQL Server;Data Source=' +
      dbhost + ';Initial Catalog=' + DBName +
      ';Authentication=Windows;Login Prompt=False'
      //2023-07-03
       + ';CharacterSet=UTF8';
      ;
    Conn.SpecificOptions.Clear;
    Conn.SpecificOptions.Add('SQL Server.Provider=prDirect'); //解决乱码
  end else
  begin
    Conn.DbType := DbType;
    Conn.DataTypeMap.AddDBTypeRule(msDecimal, ftFMTBCD);
    Conn.ConnectString := 'Provider Name=SQL Server;Data Source=' +
      dbhost + ';Initial Catalog=' + DBName +
      ';User ID=' + User + ';Password=' +
      pwd + ';Login Prompt=False';

    Conn.SpecificOptions.Clear;
    Conn.SpecificOptions.Add('SQL Server.Provider=prDirect'); //解决乱码
  end;
end;

function TPubbase.CreateStoredProc: TminiStoredProc;
begin
  Result := TminiStoredProc.Create(nil);
  Result.Connection := TUniConnection(TminiConnection);
  FList.Add(Result);
end;

function TPubbase.CreateFileStream(FileName: string; Mode: Integer;
  var ErrStr: String): TFileStream;
begin
  try
    ErrStr := '';
    Result := TFileStream.Create(FileName, Mode);
    FList.Add(Result);
  except
    on e: Exception do
      ErrStr := e.Message;
  end;
end;

function TPubbase.GetConnPooler(AZTCode: string): TminiPooler;
var
  Index, lp: integer;
  ConnInfo: TminiPooler;
  Flag: boolean;
  TmpStr, dbhost, DbType, DBName, User, Pwd: string;
  mds: THjhMemoryDataSet;
  procedure CreatePooler;
  begin
    ConnInfo := TminiPooler.Create;
    ConnInfo.aTmpSl := TStringList.Create;
    ConnInfo.AZTCode := AZTCode;
    ConnInfo.HadUsed := true;
    ConnInfo.Start := Now;
    ConnList.Add(TObject(ConnInfo));
  end;
  procedure CreateObj;
  begin
    ConnInfo.aConnection1 := TminiConnection.Create(nil);
    ConnInfo.aQuery1 := TminiQuery.Create(nil);
    ConnInfo.aQuery1.Connection := ConnInfo.aConnection1;
    ConnInfo.aHJHMemodataset := nil;
  end;
  procedure nilObj;
  begin
    ConnInfo.aConnection1 := nil;
    ConnInfo.aQuery1 := nil;
  end;
begin
  ConnInfo := nil;
  CriticalSection_Conn.Enter;
  try
    Index := FindNoUseConn(AZTCode, ConnList);
    if Index > -1 then
    begin
      ConnInfo := TminiPooler(ConnList[Index]);
      ConnInfo.HadUsed := true;
      ConnInfo.Start := Now;
    end else
    if SameText('confmx', AZTCode) or SameText('conf', AZTCode) or SameText('syslogin', AZTCode) then  //内置账套
    begin
      CreatePooler;
      nilObj;
      ConnInfo.FDBName := ExtractFilePath(ParamStr(0)) + 'setting\' + AZTCode + '.json';
      ConnInfo.FDBType := 'memorytable';
    end else
    begin
      TmpStr := ExtractFilePath(ParamStr(0)) + 'setting\confmx.json';
      if FileExists(TmpStr) then
      begin
        CreatePooler;
        mds := THjhMemoryDataSet.Create(nil);
        try
          DBMemory_LoadJson(mds, TmpStr);
          Decrypt(mds, 'dbpwd=ftString@0#数据库密码@1#@2#0@3#0@4#1@5#@6#0@7#0@8#0@9#1@10#');
          Flag := false;
          mds.First;
          while not mds.Eof do
          begin
            if SameText(mds.V('ztcode'), Trim(AZTCode)) then
            begin
              Flag := true;
              break;
            end;
            mds.Next;
          end;

          if Flag then
          begin
            DbType := mds.V('dbclass');
            if (trim(DbType) = '') or (trim(DbType) = '自动') then
              DbType := mds.V('drivername');
            DBName := mds.V('dbname');
            ConnInfo.ztstop := mds.V('ztstop') = 'on';//2023-05-19 add
            ConnInfo.FDBName := DBName;
            ConnInfo.FDBType := DbType;
            if DbType = 'memorytable' then
            begin
              nilObj;
            end else
            begin
              CreateObj;

              dbhost := mds.V('dbhost');
              User := mds.V('dbuser');
              Pwd := mds.V('dbpwd');

              SetConnParam(ConnInfo.Conn, dbhost, ConnInfo.FDBType, DBName,
                User, Pwd);
            end;
          end else //创建是为了不报nil错误
            CreateObj;
        finally
          mds.Free;
        end;
      end;
    end;
    Result := ConnInfo;
    FPoolerList.Add(Result);
  finally
    CriticalSection_Conn.Leave;
  end;
end;

function TPubbase.CreateMemoryDataSet: THjhMemoryDataSet;
begin
  Result := THjhMemoryDataSet.Create(nil);
  FList.Add(Result);
end;

function TPubbase.CreateJson: TminiJson;
begin
  Result := TminiJson.Create;
  FList.Add(Result);
end;

function TPubbase.mds: THjhMemoryDataSet;
begin
  if FConnPooler = nil then
    Result := nil
  else
    Result := FConnPooler.mds;
end;

function TPubbase.DBName: string;
begin
  if FConnPooler = nil then
    Result := ''
  else
    Result := FConnPooler.DBName;
end;

function TPubbase.DBType: string;
begin
  if FConnPooler = nil then
    Result := ''
  else
    Result := FConnPooler.DBType;
end;

function TPubbase.DB_C(AZTCode: string; var ErrStr: string): boolean;
begin
  Result := false;
  FConnPooler := GetConnPoolerEx(AZTCode, ErrStr);
  if trim(ErrStr) <> '' then exit;
  if FConnPooler = nil then
  begin
    ErrStr := '没能从连接池中取到实例(Pool=nil)！';
    exit;
  end;
  //连接数据库 start
  try
    if not Conn.Connected then
      Conn.Connected := true;
  except
    on e: exception do
    begin
      FConnPooler.HadUsed := false;
      ErrStr := e.Message + '-2>' + AZTCode {+ ' ->DriverName:' + FDConnection1.DriverName + ' DriverID:' + FDConnection1.Params.DriverID +
        ' ConnectionString:' + FDConnection1.ConnectionString};
      exit;
    end;
  end;
  //连接数据库 end;
  Result := true;
end;

function TPubbase.DB_E(SQLText: string; var ErrStr: string; AZTCode: string
  ): boolean;
begin
  Result := false;
  try
    //连接数据库 start
    if not DB_C(AZTCode, ErrStr) then exit;
    //连接数据库 end;

    //开始执行
    if not Query.ExecSQL(SQLText, ErrStr) then exit;
  finally
    //FConnPooler.HadUsed := false; //注意: 一定要有这行，把实例还回连接池, 现在不需要
  end;

  Result := true;
end;

function TPubbase.DB_O(SQLText: string; var ErrStr: string; AZTCode: string
  ): boolean;
begin
  Result := false;

  try
    //连接数据库 start
    if not DB_C(AZTCode, ErrStr) then exit;
    //连接数据库 end;

    //开始执行
    if not Query.Open(SQLText, ErrStr) then exit;
  finally
    //FConnPooler.HadUsed := false; //注意: 一定要有这行，把实例还回连接池, 现在不需要
  end;

  Result := true;
end;

function TPubbase.O(ZTCode: string; var PooledInfo: TminiPooler;
  var Query: TminiQuery; var ErrStr: string): boolean;
var
  aHJHMemodataset: THjhMemoryDataSet;
begin
  Result := false;
  PooledInfo := GetConnPoolerEx(ZTCode, ErrStr);
  if trim(ErrStr) <> '' then exit;
  if PooledInfo = nil then
  begin
    ErrStr := '没能从连接池中取到实例(Pool=nil)！';
    exit;
  end;
  if PooledInfo.DBType = 'memorytable' then
  begin
    aHJHMemodataset := PooledInfo.mds;
    {try
      if FileExists(PooledInfo.DBName) then
        aHJHMemodataset.LoadFromFile(PooledInfo.DBName);
    except
      on e: exception do
      begin
        PooledInfo.HadUsed := false;
        ErrStr := e.Message + '-1>' + 'ZTCode ->DBType:' + PooledInfo.DbType + ' DBName: ' + PooledInfo.DBName;//' DriverID:' + PooledInfo.FDConnection1.Params.DriverID +
        exit;
      end;
    end;//}
  end else
  begin
    Query := PooledInfo.Query;
    Query.Connection := PooledInfo.Conn;
    //连接数据库 start
    try
      if not PooledInfo.Conn.Connected then
        PooledInfo.Conn.Connected := true;
    except
      on e: exception do
      begin
        PooledInfo.HadUsed := false;
        {$ifdef debug}
        ErrStr := e.Message + '-1>' + 'ZTCode ->DriverName:' + PooledInfo.Conn.DriverName + //' DriverID:' + PooledInfo.FDConnection1.Params.DriverID +
          ' ConnectionString:' + PooledInfo.Conn.ConnectString;
        {$else}
        ErrStr := e.Message + '-1>' + 'ZTCode ->DriverName:' + PooledInfo.Conn.DriverName {//+ ' DriverID:' + PooledInfo.FDConnection1.Params.DriverID +
          ' ConnectionString:' + PooledInfo.FDConnection1.ConnectionString};
        {$endif}
        exit;
      end;
    end;
    //连接数据库 end;
  end;
  Result := true;
end;

function TPubbase.DB_OMT(SQLText: string; var ErrStr: string; Mt1: TminiMemTable;
  AZTCode: string): boolean;
begin
  Result := false;

  if not DB_O(SQLText, ErrStr, AZTCode) then exit;

  Mt1.Close;
  Mt1.Assign(Query);
  if not Mt1.Open(ErrStr) then exit;

  Result := true;
end;

function TPubbase.DB_ODS(SQLText: string; var ErrStr: string;
  ds: THjhMemoryDataSet; AZTCode: string): boolean;
begin
  Result := false;

  if not DB_O(SQLText, ErrStr, AZTCode) then exit;

  ds.DataSet := Query;
  ds.Open;

  Result := true;
end;

{function GetDbType(Self: TminiQuery): string;
begin
  if Self = nil then exit;
  Result := LowerCase(Self.Connection.ProviderName);
end;}

function TPubbase.DB_ETEx(TableName, SQLText: string; IsTmpTBL: boolean;
  var ErrStr: string; Query1: TminiQuery): boolean;
  var
    DbType, ALLSQL, TEMPORARY: string;
  begin
    Result := false;

    DbType := Self.DbType; //2023-04-24 mod GetDbType(Query);
    //删除临时表
    try
      Query.Close;
      Query.SQL.Text := ' drop table ' + TableName;
      Query.ExecSQL(Query.SQL.Text, ErrStr);
    except
    end;

    if SameText(DbType, 'mssql') or SameText(DbType, 'db2') then
    begin
      ALLSQL := StringReplace(SQLText, ' from ', ' into ' + TableName + ' from ', [rfIgnoreCase]);
    end else
    begin
      if IsTmpTBL then
        TEMPORARY := ' TEMPORARY'
      else
        TEMPORARY := '';
      ALLSQL := ' CREATE' + TEMPORARY + ' TABLE ' + TableName + '( '#13#10 +
        SQLText +
        '  ) ';
    end;

    //开始执行

    Query.Close;
    if not Query.ExecSQL(ALLSQL, ErrStr) then exit;

    Result := true;
  end;

function TPubbase.DB_OT(SQLText, TableName: string; IsTmpTBL: boolean;
  var ErrStr: string; AZTCode: string): boolean;
  begin
    Result := false;

    //连接数据库 start
    if not DB_C(AZTCode, ErrStr) then exit;
    //连接数据库 end;

    //开始执行
    if not DB_ETEx(TableName, SQLText, IsTmpTBL, ErrStr, Query) then exit;
    Result := true;
  end;

function TPubbase.CreateStringlist: TStringlist;
begin
  Result := TStringList.Create;
  FList.Add(Result);
end;

function TPubbase.CreateMemTable: TminiMemTable;
begin
  Result := TminiMemTable.Create(nil);
  FList.Add(Result);
end;

function TPubbase.TestConnect(dbhost, DbType, DBName, User, Pwd: string): string;
var
  Conn: TminiConnection;
begin
  if SameText(DbType, 'memorytable') then exit;

  try
    Conn := TminiConnection.Create(nil);
    try
      SetConnParam(Conn, dbhost, DbType, DBName, User, Pwd);
      Conn.Connected := true;
    finally
      Conn.Free;
    end;
  except
    on e: exception do
    begin
      Result := e.Message + '[' + dbhost + ' ' + user + ':' + Pwd + ']';
      exit;
    end;
  end;
end;

function TPubbase.TmpSl: TStringList;
begin
  if FConnPooler = nil then
    Result := nil
  else
    Result := FConnPooler.TmpSl;
end;

function TPubbase.Conn: TminiConnection;
begin
  if FConnPooler = nil then
    Result := nil
  else
    Result := FConnPooler.aConnection1;
end;

function TPubbase.Query: TminiQuery;
begin
  if FConnPooler = nil then
    Result := nil
  else
    Result := FConnPooler.aQuery1;
end;

function TPubbase.Pooler: TminiPooler;
begin
  Result := FConnPooler;
end;

function TPubbase.CreateConn: TminiConnection;
begin
  Result := TminiConnection.Create(nil);
  FList.Add(Result);
end;

function TPubbase.CreateQuery: TminiQuery;
begin
  Result := TminiQuery.Create(nil);
  Result.Connection := Conn;
  FList.Add(Result);
end;

              {
function TPub.Getds: THjhMemoryDataSet;
begin

end;          }

function GetOthInfo(Port: integer; Request: TminiHTTPRequest): string;
begin
  Result := ' 被访问网址:' + Request.Document  + ' 被访问主机:' + GetDeliPri(Request.Host, ':') +
    ' 被访问端口:' + Port.ToString +
    ' 访问客户:' + Request.RemoteIP + ' ' + Request.UserAgent + ' 来源:' + Request.Referer;
end;

function GetYs_From_EXT(Ext: string; var Host: string): boolean;
var
  lp: integer;
begin
  Result := false;
  Ext := LowerCase(Ext);
  for lp := 0 to ServerInfo.exttoserver.Count - 1 do
  begin
    if Pos(Ext, trim(ServerInfo.exttoserver[lp])) = 1 then
    begin
      Result := true;
      Host := trim(GetDeliBack(ServerInfo.exttoserver[lp], '='));
      if Host[length(Host)] <> '/' then
        Host := Host + '/';
      break;
    end;
  end;
end;

procedure WriteRunLogToFile(Text: string);
var
  //Text: string;
  SL: TStringlist;
  procedure IniFile(IsIni: boolean = false);
  begin
    FLogInfo.FTF_IsIni_Run := true;
    AssignFile(FLogInfo.FTF_Run, FLogInfo.FRunLog_File);
    if (not IsIni) and FileExists(FLogInfo.FRunLog_File) then
    begin
      try
        SL := TStringlist.Create;
        try
          try
            SL.LoadFromFile(FLogInfo.FRunLog_File);
          except
          end;
          FLogInfo.AllCount_Run := SL.Count;
        finally
          SL.Free;
        end;
      except
        FLogInfo.AllCount_Run := 0;
      end;
      Append(FLogInfo.FTF_Run);
    end else
    begin
      FLogInfo.AllCount_Run := 0;
      Rewrite(FLogInfo.FTF_Run);
    end;
  end;
begin
  //if not FLogInfo.FIsLog then exit;
  if trim(Text) <> '' then
    Text := FormatDateTime('yyyy-mm-dd hh:nn:ss"."zzz', Now) + ' ' + Text
  else
    //Text := '----------------------------------------------------------'
    ;

  try
    //Text := FormatDateTime('yyyy-mm-dd hh:nn:ss"."zzz', Now) + ' 被访问网址:' + Request.Document  + ' 被访问主机:' + Request.Host +
    //  ' 访问客户IP:' + Request.RemoteIP;

    CriticalSection_RunLog.Enter;
    try
      if not FLogInfo.FTF_IsIni_Run then
      begin
        IniFile;
      end;
      FLogInfo.AllCount_Run := FLogInfo.AllCount_Run + 1;
      Writeln(FLogInfo.FTF_Run, Text);

      if FLogInfo.AllCount_Run >= FLogInfo.MaxCount then
      begin
        Closefile(FLogInfo.FTF_Run);
        Text := ExtractFilePath(FLogInfo.FRunLog_File) + 'Run_' + FormatDateTime('yyyymmddhhnnsszzz', Now) + '.txt';
        RenameFile(FLogInfo.FRunLog_File, Text);
        IniFile(true);
      end;

    finally
      CriticalSection_RunLog.Leave;
    end;
  except
    //on e: exception do
      //ShowMessage(e.Message);
  end;
end;

procedure WriteServiceLogToFile(Port: integer; Request: TminiHTTPRequest; ClientIP, Document, UserAgent, Host: string);
var
  Text: string;
  SL: TStringlist;
  procedure IniFile(IsIni: boolean = false);
  begin
    FLogInfo.FTF_IsIni := true;
    AssignFile(FLogInfo.Ftf, FLogInfo.FServiceLog_File);
    if (not IsIni) and FileExists(FLogInfo.FServiceLog_File) then
    begin
      try
        SL := TStringlist.Create;
        try
          SL.LoadFromFile(FLogInfo.FServiceLog_File);
          FLogInfo.AllCount := SL.Count;
        finally
          SL.Free;
        end;
      except
        FLogInfo.AllCount := 0;
      end;
      Append(FLogInfo.Ftf);
    end else
    begin
      FLogInfo.AllCount := 0;
      Rewrite(FLogInfo.Ftf);
    end;
  end;
begin ///exit;
  // 这里不需要了，调用时已判断  if not FLogInfo.FIsLog then exit;
  try
    if Request = nil then
    begin
      Text := FormatDateTime('yyyy-mm-dd hh:nn:ss"."zzz', Now) + ' 被访问网址:' + Document  + ' 被访问主机:' + Host +
        ' 访问客户IP:' + ClientIP + ' ' + UserAgent
    end else
    begin
      Text := FormatDateTime('yyyy-mm-dd hh:nn:ss"."zzz', Now) + ' 被访问网址:' + Request.Document  + ' 被访问主机:' + Host +
        ' 访问客户IP:' + Request.RemoteIP + ' ' + Request.UserAgent;
    end;

    CriticalSection_Log.Enter;
    try
      if not FLogInfo.FTF_IsIni then
      begin
        IniFile;
      end;
      FLogInfo.AllCount := FLogInfo.AllCount + 1;
      //Writeln(FLogInfo.FTF, UTF8toansi(Text));
      Writeln(FLogInfo.FTF, Text);

      if FLogInfo.AllCount >= FLogInfo.MaxCount then
      begin
        Closefile(FLogInfo.FTF);
        Text := ExtractFilePath(FLogInfo.FServiceLog_File) + 'Service_' + FormatDateTime('yyyymmddhhnnsszzz', Now) + '.txt';
        RenameFile(FLogInfo.FServiceLog_File, Text);
        IniFile(true);
      end;

    finally
      CriticalSection_Log.Leave;
    end;
  except
    //on e: exception do
      //ShowMessage(e.Message);
  end;
end;

function ChangeToMobileFileName(FileName: string; AdddExt: string = '_m'): string;
var
  Tmp, Tmp2: string;
begin //2020-05-08 add 电脑网页中自动加上移动网页 在原电脑中的名称中 加上“_m”
  if trim(AdddExt) = '' then
    AdddExt := '_m';
  Tmp := ExtractFileExt(FileName);//FMb_FileName);
  Tmp2 := GetDeliPri(ExtractFileName(FileName), Tmp);
  Tmp2 := Tmp2 + AdddExt + Tmp;
  Result := Tmp2;
end;

procedure FreeOneDM_Obj(DMInfo: TDMInfo);
begin
  try
    if DMInfo.PSScript1 <> nil then
      DMInfo.PSScript1.Free;
    if DMInfo.TmpSl <> nil then
      DMInfo.TmpSl.Free;
    if DMInfo.Request <> nil then
      DMInfo.Request.Free;
    if DMInfo.Response <> nil then
      DMInfo.Response.Free;
    //if DMInfo.Pub <> nil then
      //DMInfo.Pub.Free;
  except
  end;
end;

procedure FreeDM(Need: boolean = true);
var
  lp: Integer;
  //SL: TStringlist;
begin
  //SL := TStringlist.Create;
  if Need then CriticalSection.Enter;
  try
    for lp := DMList.Count - 1 downto 0 do
    begin
      try
        FreeOneDM_Obj(DMList[lp]);
        TDMInfo(DMList[lp]).Free;
        DMList.Delete(lp);
      except
      end;
    end;
    DMList.Clear;
  finally
    if Need then CriticalSection.Leave;
    //SL.Savetofile('e:\aaaaaaaaaa.txt');
    //SL.Free;
  end;
end;
function IsMobile(Request: TminiHTTPRequest): boolean;
begin   //mobile : (!!u.match(/AppleWebKit.*Mobile/) || !!u.match(/Windows Phone/) || !!u.match(/Android/) || !!u.match(/MQQBrowser/)) && !u.match(/iPad/)
  Result := (Pos('Android', Request.UserAgent) > 0) or
    (Pos('AppleWebKit.', Request.UserAgent) > 0) and (Pos('Mobile', Request.UserAgent) > 0) or
    (Pos('iPad', Request.UserAgent) > 0) or
    (Pos('MQQBrowser', Request.UserAgent) > 0) or
    (Pos('Windows Phone', Request.UserAgent) > 0);
end;
class procedure TRunner.LoadOtherFile(OldLDoc, FileName: string; Port: integer; Request: TminiHTTPRequest; Response: TminiHTTPResponse);
begin
  FileName := StringReplace(FileName, '\', '/', [rfReplaceAll]);
  Response.ContentType := MIMEMap.GetFileMIMEType(FileName);//GetMIMETypeFromFile(ldoc); //'text/css/html';


  Response.ContentType := Response.ContentType + ';charset=UTF-8';
  try
    Response.ContentStream := TFileStream.create(FileName, fmOpenRead	or fmShareDenyWrite);
  except
    on e: exception do
    begin
      Response.ContentStream := nil;
      WriteRunLogToFile(e.Message + GetOthInfo(Port, Request)); //2019-10-25 add
    end;
  end;
end;
function ReplacExt(F: string): string;
begin
  Result := ChangeFileExt(F, GetDeliBack(string(ServerInfo.serviceext), ','));
end;
class procedure TRunner.GoToErrPage(DMInfo: TDMInfo; Session: TObject; Service_Path, FileName: string;
   Port: integer; Request: TminiHTTPRequest; Response: TminiHTTPResponse; addstr: string);
begin
  WriteRunLogToFile('无法找到文件[' + (FileName) + ']！(Error code: 404 - Not Found)' + addstr + GetOthInfo(Port, Request) +
     '-->' + Request.Params.CommaText + '-Document:' + Request.Document + '-QueryParams:' + Request.QueryParams +
     '-URI:' + Request.URI + '-PostedData:' + Request.PostedData_mORMot);
  if FileExists(Service_Path + ServerInfo.errorpage) and (Pos(ExtractFileExt(LowerCase(ServerInfo.errorpage)), LowerCase(ServerInfo.serviceext)) > 0) then
  begin
    //TRunner.RunOnePspFile(DMInfo, Session, Service_Path, NewDoc, Port, Request, Response)
    Response.Redirect('/' + ServerInfo.errorpage + '?errorfilename=' + StringReplace(FileName, '\', '/', [rfReplaceAll]) +
    '&errorcode=404&errormsg=访问的网页不存在'); //可以通过Request.V('errorfilename');获取出的文件名
  end else
  if FileExists(Service_Path + ServerInfo.errorpage) then
    TRunner.LoadOtherFile('', Service_Path + ServerInfo.errorpage, Port, Request, Response)
  else
  begin
    //HTTP 错误 404.0 - Not Found
    Response.ContentType := 'text/html;charset=UTF-8';
    Response.ContentText := '无法找到文件[' + (ExtractFileName(FileName)) + ']！(Error code: 404 - Not Found)!';// + addstr;
  end;
end;

function GetDMInfo(Request: TObject): TDMInfo;
var
  //C: string;
  Index, Count, lp, I, T: integer;
  DMInfo: TDMInfo;
  IsWaint: boolean;
  OldTime: TDateTime;
  procedure DeleteMe();
  var
    lp: integer;
  begin
    CriticalSection_Sqe.Enter;
    try
      if IsWaint then
      begin
        for lp := QueList.Count - 1 downto 0 do
        if QueList[lp] = Request then
        begin
          QueList.Delete(lp);
          break;
        end;
      end;
    finally
      CriticalSection_Sqe.Leave;
    end;
  end;
begin
  //Request.Session.Values[]
  Result := nil;

  {$ifndef nonedmmaxcount}
  OldTime := Now;
  IsWaint := false;
  Count := 0;
  //加入QueList，是为了等待时有优先级，原则：先到先得
  while True do
  begin
    if (not IsWaint) or (IsWaint and (QueList[0] = Request)) then
    begin
  {$endif}
      CriticalSection.Enter;
      try
        Index := FindNoUseDm(DMList);
        if Index > -1 then
        begin
          DMInfo := TDMInfo(DMList[Index]);
          DMInfo.HadUsed := true;
          DMInfo.Start := Now;
        end else
        begin
          {$ifndef nonedmmaxcount}
          if DMList.Count >= ServerInfo.PooredMaxCount then
          begin
            DMInfo := nil;
            if not IsWaint then
            begin
              IsWaint := true;
              CriticalSection_Sqe.Enter;
              try
                QueList.Add(Request);
              finally
                CriticalSection_Sqe.Leave;
              end;
            end;
          end else
          {$endif}
          begin
            DMInfo := TDMInfo.Create;
            DMInfo.HadUsed := true;
            DMInfo.Start := Now;
            DMInfo.PSScript1 := nil;
            DMInfo.TmpSl := TStringList.Create;
            DMInfo.Request := TminiHTTPRequest.Create();
            DMInfo.Response := TminiHTTPResponse.Create(DMInfo.Request);
            DMInfo.Request.Response := DMInfo.Response;
            DMList.Add(TObject(DMInfo));
          end;
        end;
        Result := DMInfo;
      finally
        CriticalSection.Leave;
      end;
  {$ifndef nonedmmaxcount}
    end;
    if Result <> nil then
    begin
      if IsWaint then
      begin
        CriticalSection_Sqe.Enter;
        try
          if Request = QueList[0] then
            QueList.Delete(0);
        finally
          CriticalSection_Sqe.Leave;
        end;
      end;
      break;
    end else
      Sleep(100);
    Count := Count + 1;
    //if Count > 2500 * 10 then //最多等25秒
    if (Count > 10 * 25) or (abs(SecondsBetween(Now, OldTime)) > 30) then //最多等25秒
    //test if Count > 20 * 10 then //最多等20秒
    begin
      DeleteMe();
      break;
    end;
  end;
  {$endif}
end;

function GetScriptInfo(FileName: string; var ScriptIndex: integer; noparent: string): TScriptInfo;
{var
  //C: string;
  DMInfo: TDMInfo;}
var
  lp: integer;
begin
  CriticalSection_Script.Enter;
  try
    Result := nil;
    ScriptIndex := -1;
    for lp := 0 to ScriptList.Count - 1  do
    if (not TScriptInfo(ScriptList[lp]).Used) and (TScriptInfo(ScriptList[lp]).FileName = FileName) and
      //2022-07-12 add
      (TScriptInfo(ScriptList[lp]).noparent = noparent)
       then
    begin
      ScriptIndex := lp;
      Result := TScriptInfo(ScriptList[lp]);
      Result.Used := true;
      Result.Start := Now;
      break;
    end;
  finally
    CriticalSection_Script.Leave;
  end;

  //Request.Session.Values[]
  {Count := 0;
  while true do
  begin
    CriticalSection.Enter;
    try
      //C := 'a';
      Index := FindNoUseDm(DMList); //Index := DMList.IndexOf(GetKey('0', C));
      if Index > -1 then
      begin
        //DMList[Index] := GetKey('1', C);
        DMInfo := TDMInfo(DMList[Index]);
        DMInfo.HadUsed := true;
        DMInfo.Start := Now;
      end else
      begin
        if DMList.Count >= FPooredCount then
          DMInfo := nil
        else
        begin
          DMInfo := TDMInfo.Create;
          DMInfo.HadUsed := true;
          DMInfo.Start := Now;
          DMInfo.PaxCompiler1 := nil;
          DMInfo.PaxPascalLanguage1 := nil;
          DMInfo.PaxProgram1 := nil;
          DMInfo.TmpSl := TStringList.Create;
          DMList.Add(TObject(DMInfo));
        end;
      end;
      Result := DMInfo;
    finally
      CriticalSection.Leave;
    end;
    if Result <> nil then
      break
    else
      Sleep(100);
    Count := Count + 1;
    if Count > 20 * 10 then //最多等20秒
      break;
  end;}
end;

function Pro_include_file(var IncFileSL: TStringlist; SL: TStringlist; Cur_Path, FileName, HTML: string): string;
var
  Index, Index2: integer;
  TmpStr, NewHTML, LowerHTML, Path: string;
  OldTime: TDateTime;
begin //<!--#include file="count.inc" -->
  LowerHTML := LowerCase(HTML);
  Index := Pos('<!--#include', LowerHTML);
  if Index < 1 then
    Result := HTML
  else
  begin
    OldTime := Now;
    while Index > 0 do
    begin
      Result := Result + Copy(HTML, 1, Index - 1);

      HTML := Copy(HTML, Index, MaxInt);
      LowerHTML := Copy(LowerHTML, Index, MaxInt);

      Index2 := Pos('>', HTML);
      //这里开始处理 start <!--#include file="head.asp" --> FileName
      SL.Clear;
      TmpStr := Copy(HTML, 1, Index2);
      TmpStr := GetDeliBack(TmpStr, '"');
      TmpStr := GetDeliPri(TmpStr, '"');
      //2020-03-13 mod Path := ExtractFilePath(FileName) + TmpStr;
      Path := Cur_Path + TmpStr;
      if not FileExists(Path) then
        Result := Result + '<br><font color = red>不存在文件[' + ReplacExt(Path) + ']!</font><br>'
      else
      try
        //AddFileTimeToList(ScriptInfo, Path);
        if IncFileSL = nil then IncFileSL := TStringlist.Create;
        IncFileSL.Add(Path);
        SL.LoadFromFile(Path);
      except
        on e: exception do
          Result := Result + '<br><font color = red>加载文件[' + ReplacExt(Path) + ']时出错!' + e.Message + '</font><br>';
      end;
      Result := Result + (SL.Text);
      //这里开始处理end;

      HTML := Copy(HTML, Index2 + 1, MaxInt);
      LowerHTML := Copy(LowerHTML, Index2 + 1, MaxInt);

      Index := Pos('<!--#include', LowerHTML);
      if SecondsBetween(Now, OldTime) > 10 then
      begin
        WriteRunLogToFile('执行超时，100');
        break; //2020-03-21 add
      end;
    end;
    Result := Result + HTML;
  end;

end;
type
  TOutScript = record
    UsesCodes, VarCodes, ExeCode, AllHtml: string;
  end;
function HtmlScriptToPasCode(SL: TStringlist; Codes: string; var Doing: boolean): string;
var
  OutScript: TOutScript;
  Tmp, HTML, NewCode, OldCodes: string;
  OldTime: TDateTime;
  function QuotedStrEx(v: string): string;
  var
    lp: integer;
    Sa: TArray<string>;
  begin
    if trim(V)  = '' then
      Result := QuotedStr('')
    else
    begin
      Sa := v.Split([#13#10]);
      Result := '';
      for lp := 0 to length(Sa) - 1 do
      if Result = '' then
        Result := QuotedStr(Sa[lp])
      else
        Result := Result + '#13#10+' + #13#10 + QuotedStr(Sa[lp]);
    end;
  end;
  procedure ToAllHtml(HTML: string);
  begin
    if trim(HTML) <> '' then
    begin
      OutScript.AllHtml := OutScript.AllHtml + 'print(' + QuotedStrEx(trim(HTML)) + ');';
    end;
  end;
begin
  Doing := false;
  OldTime := Now;
  OutScript.UsesCodes := '';
  OutScript.VarCodes := '';
  //OutScript.ExeCode := '';
  OutScript.AllHtml := '';

  NewCode := Codes;
  OldCodes := Codes;
  Codes := '';
  try
    //1.uses
    while Pos('<%@', NewCode) > 0 do
    begin
      Codes := Codes + trim(GetDeliPri(NewCode, '<%@'));
      NewCode:= GetDeliBack(NewCode, '<%@');

      OutScript.UsesCodes := OutScript.UsesCodes + GetDeliPri(NewCode, '%>');
      Codes := Codes + GetDeliBack(NewCode, '%>');;

      NewCode:= GetDeliBack(NewCode, '%>');
      if SecondsBetween(Now, OldTime) > 10 then
      begin
        WriteRunLogToFile('执行超时，100');
        break; //2020-03-21 add
      end;
    end;

    //2.var
    NewCode := Codes;
    Codes := '';
    while Pos('<%!', NewCode) > 0 do
    begin
      Codes := Codes + trim(GetDeliPri(NewCode, '<%!'));
      NewCode:= GetDeliBack(NewCode, '<%!');

      OutScript.VarCodes := OutScript.VarCodes + GetDeliPri(NewCode, '%>');
      Codes := Codes + GetDeliBack(NewCode, '%>');

      NewCode:= GetDeliBack(NewCode, '%>');
      if SecondsBetween(Now, OldTime) > 10 then
      begin
        WriteRunLogToFile('执行超时，102');
        break; //2020-03-21 add
      end;
    end;

    //3.exeCode
    NewCode := Codes;
    Codes := '';
    while Pos('<%', NewCode) > 0 do
    begin
      Doing := true;
      HTML := GetDeliPri(NewCode, '<%');
      ToAllHtml(HTML);

      NewCode:= GetDeliBack(NewCode, '<%');

      OutScript.AllHtml := OutScript.AllHtml + GetDeliPri(NewCode, '%>');
      NewCode := GetDeliBack(NewCode, '%>');
      if SecondsBetween(Now, OldTime) > 10 then
      begin
        WriteRunLogToFile('执行超时，1039');
        break; //2020-03-21 add
      end;
    end;
    HTML := NewCode;
    ToAllHtml(HTML);

    if not Doing then
      Result := OldCodes
    else
      Result := trim(OutScript.UsesCodes) + #13#10 +
        trim(OutScript.VarCodes) + #13#10 +
        'begin' + #13#10 +
        trim(OutScript.AllHtml) + #13#10 +
        'end.';
  finally
  end;
end;

function Pro_ParentMb(SL: TStringlist; Service_Path, Cur_Path, FileName, HTML: string; var ErrStr: string): string;
var
  MyFN, Tmp, SelFileName, MbPath, Head, Content, OldFn, One, Tmp1, Tmp2, Tmp3, ta, AftJsFile, SubPah: string;
  lp, DotCount: integer;
  Flag, F, IsTest: boolean;
  function GetPath: string;
  begin
    SelFileName := MyFN;
    MbPath := Cur_Path;
    MbPath := PathWithoutSlash(MbPath);
    SelFileName := StringReplace(SelFileName, '/', '\', [rfReplaceAll]);
    //<!parent content="..\docmb.html"/>
    while Pos('..\', SelFileName) > 0 do
    begin
      MbPath := ExtractFilePath(MbPath);
      MbPath := PathWithoutSlash(MbPath);
      SelFileName := GetDeliBack(SelFileName, '..\');
      DotCount := DotCount + 1;
    end;
    Result := PathWithSlash(MbPath) + SelFileName;
  end;
  function ProPath(Tmp2: string): string;
  var
    i: integer;
  begin
    if (trim(SubPah) <> '') and (Pos('/', Tmp2) <> 1) then //2022-08-04 add
    begin
      Tmp2 := SubPah + Tmp2;
      Tmp2 := StringReplace(Tmp2, '\', '/', [rfReplaceAll]);
    end else
    begin
      if (Pos('http://', Tmp2) < 1) and (Pos('https://', Tmp2) < 1) and (Pos('/', Tmp2) <> 1) and (Pos('\', Tmp2) <> 1) then
      for I := 1 to DotCount do
        Tmp2 := '../' + Tmp2;
    end;
    Result := Tmp2;
  end;
  function ProOnePic(One: string): string;
  begin
    Tmp1 := GetDeliBack(One, ta);
    One := GetDeliPri(One, ta) + ta;

    Tmp2 := GetDeliPri(Tmp1, '"');
    Tmp1 := GetDeliBack(Tmp1, '"') + '"';
    if (Pos('javascript:', Tmp2) < 1) and (Tmp2 <> '#') then
    begin
      {if (Pos('http://', Tmp2) < 1) and (Pos('https://', Tmp2) < 1) then
      for I := 1 to DotCount do
        Tmp2 := '../' + Tmp2;}

      Tmp2 := ProPath(Tmp2);
    end;

    One := One + Tmp2 + '"' + Tmp1;
    Result := One;
  end;
  function ProOne_(Content, sTag, src: string): string;
  var
    TmpStr1, TmpStr2, ImageHtml_Old, ImageHtml_New, Path: string;
    Index, OldIndex: integer;
  begin
    TmpStr1 := Content;
    Index := AnsiPos('<' + UpperCase(sTag), TmpStr1);
    if Index < 1 then Index := AnsiPos('<' + LowerCase(sTag), TmpStr1);
    if Index < 1 then
      Result := TmpStr1
    else
    begin
      Content := '';
      while Index > 0 do
      begin
        //1.取得图片标记前的内容
        Content := Content + Copy(TmpStr1, 1, Index - 1);

        //2.取图片标记
        TmpStr1 := Copy(TmpStr1, Index, MaxInt);
        Index := Pos('>', TmpStr1);
        TmpStr2 := Copy(TmpStr1, 1, Index);
        ImageHtml_Old := TmpStr2;

        //3.取得图片标记后的内容
        TmpStr1 := Copy(TmpStr1, Index + 1, MaxInt);

        //4.处理图片标记
        ImageHtml_New := '';
        Index := Pos(src + '="', TmpStr2);
        if Index < 1 then
        begin
          Content := Content + ImageHtml_Old;
        end else
        begin
          OldIndex := Index;

          TmpStr2 := Copy(TmpStr2, Index + length(src + '="'), MaxInt);
          Index := Pos('"', TmpStr2);
          Path := Copy(TmpStr2, 1, Index - 1);

          //CID := APath + Path;// GetCID;
          //CID := GetCID; //Path;// GetCID;
          //ImageHtml_New := ImageHtml_New + Copy(TmpStr2, 1, Index - 1) + 'src="' + CID + '"';

          //2013-01-07 移后 ImageHtml_New := 'src="cid:' + CID + '"';
          //2013-01-07 移后 ImageHtml_New := ImageHtml_New + Copy(TmpStr2, Index + 1, MaxInt);

          {if FileExists(Path) then
          begin
            CID := GetCID; //Path;// GetCID;
            //2013-01-07
            ////2013-08-25 mod ImageHtml_New := 'src="cid:' + CID + '"';
            ImageHtml_New := src + '="' + CID;// + '"';
            //2013-01-07
            //2013-08-25 mod ImageHtml_New := ImageHtml_New + Copy(TmpStr2, Index + 1, MaxInt);
            ImageHtml_New := ImageHtml_New + GetDeliBack(TmpStr2, Path);

            Content := Content + Copy(ImageHtml_Old, 1, OldIndex - 1) + ImageHtml_New;
            //Content := Content + Copy(ImageHtml_Old, OldIndex + 1, MaxInt);
          end else}
          begin //GetPart_Path();
            //Content := Content + ImageHtml_Old;
            ImageHtml_New := src + '="' + ProPath(Path);// + '"';
            ImageHtml_New := ImageHtml_New + GetDeliBack(TmpStr2, Path);
            Content := Content + Copy(ImageHtml_Old, 1, OldIndex - 1) + ImageHtml_New;
          end;
        end;

        Index := Pos('<' + UpperCase(sTag), TmpStr1);
        if Index < 1 then Index := AnsiPos('<' + LowerCase(sTag), TmpStr1);
      end;

      Content := Content + TmpStr1;
      Result := Content;
    end;
  end;
begin
  ErrStr := '';
  Tmp := Copy(HTML, 1, 50); //<!parent content="index.html"/>
  if Pos('<!parent content="', Tmp) <> 1 then
  begin
    Result := HTML;
    exit;
  end;
    //先分离出 aft.js"></script>
  SL.Text := HTML;
  AftJsFile := '';
  for lp := SL.Count - 1 downto 0 do
  begin
    if Pos('aft.js"></script>', SL[lp]) > 0 then
    begin
      AftJsFile := SL[lp];
      SL.Delete(lp);
      break;
    end;
  end;
  HTML := SL.Text;//}

  DotCount := 0;
  MyFN := GetDeliBack(HTML, '<!parent content="');
  MyFN := GetDeliPri(MyFn, '"');
  SubPah := '';
  if (Pos('..', MyFN) < 1) and (FileExists(Cur_Path + MyFN)) then
  begin
    MyFN := Cur_Path + MyFN;
    MyFN := StringReplace(MyFN, '/', '\', [rfReplaceAll]);
    SubPah := ExtractFilePath(MyFN);
    SubPah := GetDeliBack(SubPah, Cur_Path);
  end else//}
  begin
    MyFN := GetPath;
    Tmp := ExtractFilePath(MyFN);
    Tmp1 := GetDeliBack(Tmp, Service_Path);
    Tmp2 := GetDeliBack(Cur_Path, Service_Path);
    if (length(Tmp1) > 1) and (length(Tmp2) > 1) then
    begin
      while true do
      begin
        Tmp := GetDeliPri(Tmp1, '\');
        Tmp3 := GetDeliPri(Tmp2, '\');
        if Tmp <> Tmp3 then
        begin
          SubPah := Tmp1;
          for lp := 1 to DotCount do
            SubPah := '..\' + SubPah;
          break;
        end;
        Tmp1 := GetDeliBack(Tmp1, '\');
        Tmp2 := GetDeliBack(Tmp2, '\');
        if (length(Tmp1) < 2) or (length(Tmp2) < 2) or (Pos('\', Tmp1) < 1) or (Pos('\', Tmp2) < 1) then
          break;
      end;
    end;
  end;
  //e:\eyoue\2006-02-18\new emaidemon_china\superhtml\win32\debug\host\vedio\  Cur_Path
  //e:\eyoue\2006-02-18\new emaidemon_china\superhtml\win32\debug\host\doc\文档模板.htm MyFN

  OldFn := MyFN;
  IsTest := false;
  if not FileExists(MyFN) then
  begin
    IsTest := true;
    MyFN := Service_Path + ExtractFileName(OldFn);
  end;

  if not FileExists(MyFN) then
  begin
    ErrStr := '父模板文件[' + OldFN + ']不存在，不能继续(k902)!';
    exit;
  end;
  SL.LoadFromFile(MyFN);
  Tmp := SL.Text;

  //取当前模板的head
  Head := GetDeliPri(HTML, '<body>');

  //将父Head中没有信息加入到当前模板的头中
  Head := GetDeliPri(Head, '</head>');
  Flag := false;
  for lp := 1 to SL.Count - 1 do
  begin
    One := SL[lp];
    if
       (Pos('content="text/html; charset=UTF-8"', One) > 0) or
       (Pos('content="IE=edge"', One) > 0) or
       (Pos('content="IE=EmulateIE8"', One) > 0) or
       (Pos('content="IE=edge"', One) > 0) or

       (Pos('<meta name="viewport"', One) > 0) or
       (Pos('<meta name="Keywords"', One) > 0) or
       (Pos('<meta name="Description"', One) > 0) or
       (Pos('<title>', One) > 0) or
       (Pos('<!--[if lt IE 9]>', One) > 0) or
       (Pos('<script src="https://cdn.staticfile.org/', One) > 0) or
       (Pos('<![endif]-->', One) > 0)

    (*   <link href="
<script type="
<link rel="stylesheet"
 <!--[if lt IE 9]>
   <script src="https://cdn.staticfile.org/html5shiv/r29/html5.min.js"></script>
   <script src="https://cdn.staticfile.org/respond.js/1.4.2/respond.min.js"></script>
 <![endif]-->
<script src="layui/layui.js" charset="utf-8"></script>
<link rel="stylesheet" href="css/animate.css">
<link rel="stylesheet" href="layui/css/Global.css" media="all"> *)

       then Continue;

    if trim(One) = '<head>' then
    begin
      Flag := true;
      Continue;
    end;
    if trim(One) = '</head>' then break;

    if Flag then
    begin                                                         //<script type="text/javascript" src="js/docmb.js"></script>
      F := (Pos('<link ', One) > 0) and (Pos(' href="', One) > 0) or (Pos('<script ', One) > 0) and (Pos(' src="', One) > 0);
      //if (Pos(One, Head) < 1) then
      if F and (Pos(One, Head) < 1)  or (not F) then
      begin
        if F and (not IsTest) and ((DotCount > 0) or (trim(SubPah) <> '')) then //not IsTest
        begin //要处理相对路径
          if (Pos(' href="', One) > 0) then
            ta := ' href="'
          else
            ta := ' src="';
          One := ProOnePic(One);
        end;
        Head := trim(Head) + #13#10 + One;
      end;
    end;
  end;

  Head := trim(Head) + #13#10 + '</head>';

  //取当前模板的Content
  Content := GetDeliBack(HTML, '<body>');
  Content := GetDeliPri(Content, '</body>');

  //去掉父模板的head
  Tmp := GetDeliBack(Tmp, '<body>');
  if ((DotCount > 0) or (trim(SubPah) <> ''))and (not IsTest) then //如果是相对目录且不在父模板与当前模板不在同一目录下，要处理父模板中的如图片的相对目录
  begin
    Tmp := ProOne_(Tmp, 'img', 'src');
    Tmp := ProOne_(Tmp, 'embed', 'src');
    Tmp := ProOne_(Tmp, 'svg', 'src');
    Tmp := ProOne_(Tmp, 'a ', 'href');
    //<script type="text/javascript" src="js/docmbaft.js"></script>
    Tmp := ProOne_(Tmp, 'script ', 'src');
    //<link rel="stylesheet" href="css/animate.css">
    Tmp := ProOne_(Tmp, 'link ', 'href');
  end;
  SL.Text := Tmp;
  for lp := 0 to SL.Count - 1 do
  begin
    if Pos('<!-----mb start:', SL[lp]) = 1 then
      SL[lp] := '@_chieldred@';
    if Pos('<!-----mb end:', SL[lp]) = 1 then
    begin
      SL.Delete(lp);
      break;
    end;
  end;
  Result := SL.Text; //取得父模板内容
  SL.Clear;

  //去年第一行
  Head := GetDeliBack(Head, #13#10);
  Result := trim(Head) + #13#10 + Result;
  Result := StringReplace(Result, '@_chieldred@', Content, []);

  //2022-08-04 mod
  //if IsTest then
    Result := StringReplace(Result, '</body>', AftJsFile + #13#10 + '</body>', []);
  //else
    //Result := StringReplace(Result, '</body>', ProOnePic(AftJsFile) + #13#10 + '</body>', []);
  {<!-----mb start:Con_344864 ----->
  <!-----mb end:Con_344864 ----->}

end;

function DefProc(Caller: TPSExec; p: TPSExternalProcRec; {%H-}Global, Stack: TPSStack): Boolean;
var
  Text: string;
  PSScript: TMiniPSScript;
begin

  { The following needs to be in synch in these 3 functions:
    -UPSCompiler.TPSPascalCompiler.DefineStandardProcedures
    -UPSRuntime.DefProc
    -UPSRuntime.TPSExec.RegisterStandardProcs
  }

  case {+}NativeUInt{+.}(p.Ext1) of
    0: // print get
      begin
        {PSScript := TMiniPSScript(Caller.Id);
        Text := Stack.GetAnsiString(-1);
        //Text := Stack.GetUnicodeString(-1); //GetString(-1);
        if Text = '[%@clear@%]' then
          PSScript.DMInfo.LastHtml := ''
        else
        if trim(PSScript.DMInfo.LastHtml) = '' then
          PSScript.DMInfo.LastHtml := Text
        else
          //PSScript.DMInfo.LastHtml := trim(PSScript.DMInfo.LastHtml) + #13#10 + Stack.GetAnsiString(-1);
          //PSScript.DMInfo.LastHtml := trim(PSScript.DMInfo.LastHtml) + Text;
          PSScript.DMInfo.LastHtml := PSScript.DMInfo.LastHtml + Text;
         }

        Result := true;
      end;
    1: // print get
      begin
        PSScript := TMiniPSScript(Caller.Id);
        Text := Stack.GetAnsiString(-1);
        //Text := Stack.GetUnicodeString(-1); //GetString(-1);
        if Text = '[%@clear@%]' then
          PSScript.DMInfo.LastHtml := ''
        else
        if trim(PSScript.DMInfo.LastHtml) = '' then
          PSScript.DMInfo.LastHtml := Text
        else
          //PSScript.DMInfo.LastHtml := trim(PSScript.DMInfo.LastHtml) + #13#10 + Stack.GetAnsiString(-1);
          //PSScript.DMInfo.LastHtml := trim(PSScript.DMInfo.LastHtml) + Text;
          PSScript.DMInfo.LastHtml := PSScript.DMInfo.LastHtml + Text;
        Result := true;
      end;
  end;
end;

function TPub_GetDeliBack(Text, Delimite: String): String;
begin
  Result := GetDeliBack(Text, Delimite);
end;

const
  //PSClassType = '!ROClass';
  MyGuid: TGuid = '{4B86A9E3-E094-4E5A-954A-69048B7B6327}';

class procedure TRunner.PSScript1Compile(Sender: TPSScript);
begin
  Sender.Comp.AddType('TDateTime', btDouble).ExportName := True;
  Register_functionOrProcedure(Sender); //注册函数或过程
  Register_functionOrProcedure_SelfDefine(Sender); //注册用户的函数或过程

  //Sender.AddFunction(@TPub_GetDeliBack, 'function GetDeliBack(Text, Delimite: String): String;');
  Sender.AddRegisteredVariable('Request', 'TminiHTTPRequest');
  Sender.AddRegisteredVariable('Response', 'TminiHTTPResponse');
  Sender.AddRegisteredVariable('Pub', 'TPub');
end;

class procedure TRunner.PPSScriptExecute(Sender: TPSScript);
begin
  Sender.SetVarToInstance('Request', TMiniPSScript(Sender).DMInfo.Request);
  Sender.SetVarToInstance('Response', TMiniPSScript(Sender).DMInfo.Response);
  Sender.SetVarToInstance('Pub', TMiniPSScript(Sender).DMInfo.Pub);
end;

class procedure TRunner.PPSScript1CompImport(Sender: TObject; x: TPSPascalCompiler);
begin
  x.AddType('TDateTime', btDouble).ExportName := True;
  //这种方法fpc不能用 RegisterDatetimeLibrary_C(x);
  uPSC_std.SIRegister_Std(X);
  uPSC_classes.SIRegister_Classes(X, true);
  SIRegister_Controls(x);//}
  ///SIRegister_Forms(x);
  SIRegister_DB(x);
  SIRegister_Graphics(x, true);
  SIRegister_THjhMemoryDataSet(x);
  SIRegister_Json(x);

  SIRegister_TUniConnection(x);
  SIRegisterTminiQuery(x);
  SIRegisterTminiTHTTP(x);
  SIRegister_Others(x);
  SIRegister_Head_SelfDefine(x);

  with x.AddFunction('procedure print;').Decl do begin
    with AddParam do
    begin
      OrgName := 'm';
      Mode := pmIn;
    end;
  end;
end;

class procedure TRunner.PPSScript1ExecImport(Sender: TObject; se: TPSExec;
  x: TPSRuntimeClassImporter);
begin
  //这种方法fpc不能用 RegisterDateTimeLibrary_R(Se);
  RIRegister_Std(x);

  RIRegister_Classes(x,true);
  ///RIRegister_Forms(x);
  RIRegister_Controls(x);
  RIRegister_DB(x);
  RIRegister_Graphics(x, true);
  RIRegister_THjhMemoryDataSet(x);
  RIRegister_Json(x);

  RIRegisterTminiTHTTP(x);
  RIRegisterTminiQuery(x);
  RIRegisterTminiTHTTP(x);
  RIRegister_Others(x);

  Se.RegisterFunctionName('Print', DefProc, Pointer(1), nil);

  RIRegisterTUniConnection(x);
  RIRegister_Body_SelfDefine(x);
end;

procedure AddFileTimeToList(ScriptInfo: TScriptInfo; FileName: string);
begin
  if FileExists(FileName) then
  begin
    if ScriptInfo.AllFileNameList.IndexOf(FileName) < 0 then
    begin
      ScriptInfo.AllFileNameList.Add(FileName);
      ScriptInfo.AllFileTimeList.Add(FileGetFileTime(FileName));
    end;
  end;
end;

function RunScript(Pub: TPubbase; Port: integer; IncFileSL: TStringlist; FileName: string;
  ScriptInfo: TScriptInfo; Request: TminiHTTPRequest; Response: TminiHTTPResponse; DMInfo: TDMInfo; Codes: string): boolean;
var
  I, lp: integer;
  Tmp: string;
  sData: TbtString;
  procedure CreateObj;
  begin
    if DMInfo.PSScript1 = nil then
    begin
      try
        CriticalSection_Script.Enter;
        try
          DMInfo.PSScript1 := TMiniPSScript.Create(nil);

          DMInfo.PSScript1.UsePreProcessor := false;
          DMInfo.PSScript1.UseDebugInfo := false;


          DMInfo.PSScript1.OnCompile := TRunner.PSScript1Compile;
          DMInfo.PSScript1.OnCompImport := TRunner.PPSScript1CompImport;
          DMInfo.PSScript1.OnExecute := TRunner.PPSScriptExecute;
          DMInfo.PSScript1.OnExecImport := TRunner.PPSScript1ExecImport; //}
          //DMInfo.TmpSl := TStringList.Create; 前面已处理
        finally
          CriticalSection_Script.Leave;
        end;
      except //2022-07-06 add
        on e: exception do
          raise Exception.Create(e.Message + '{run201}');
      end;
    end;
    DMInfo.LastHtml := '';     //exit;
    DMInfo.PSScript1.DMInfo := DMInfo;
  end;
begin
  Result := false;

  CreateObj;
  {$ifndef nonecachescript}
  if (ScriptInfo <> nil) and (ScriptInfo.MS <> '') and (DMInfo.PSScript1 <> nil) and (DMInfo.PSScript1.Exec <> nil) and
    (DMInfo.PSScript1.Exec.GetTypeCount > 0) and (DMInfo.PSScript1.Exec.GetProcCount > 0) then
  begin

    //DMInfo.PSScript1.Exec.Clear;

    Result := DMInfo.PSScript1.Exec.LoadData(ScriptInfo.MS);
    TRunner.PPSScriptExecute(DMInfo.PSScript1);
    Result := Result and DMInfo.PSScript1.Exec.RunScript and (DMInfo.PSScript1.Exec.ExceptionCode = erNoError);
    if not Result then
      DMInfo.LastHtml := DMInfo.LastHtml + '运行时出错2:' + PSErrorToString(DMInfo.PSScript1.Exec.ExceptionCode,'')
  end else //}
  {$endif}
  begin
    if Codes = '' then
      DMInfo.LastHtml := '执行的代码为空！'
    else
    begin
      DMInfo.PSScript1.Script.Text := Codes;

      //DMInfo.PSScript1.Script.SaveToFile(ServerInfo.ProgramPath + 'look.html'); //}

      //编译
      if DMInfo.Psscript1.Compile() then
      //if true then
      begin
        {$ifndef nonecachescript}
        DMInfo.PSScript1.GetCompiled(sData);
        {$endif}
        if not DMInfo.PSScript1.Execute then
          DMInfo.LastHtml := DMInfo.LastHtml + '运行时出错1:' + DMInfo.PSScript1.ExecErrorToString
        else //}
        if not ServerInfo.servernocachefile then
        begin
          try
            {$ifndef nonecachescript}
            if ScriptInfo <> nil then
              {$ifdef mswindows}
              ScriptInfo.MS := sData //sData
              {$else}
              ScriptInfo.MS := sData
              {$endif}
            else
            begin
              ScriptInfo := TScriptInfo.Create;
              ScriptInfo.FileName := FileName;
              {$ifdef mswindows}
              ScriptInfo.MS := sData;
              {$else}
              ScriptInfo.MS := sData;
              {$endif}
              ScriptInfo.Used := true;
              ScriptInfo.Start := Now;
              ScriptInfo.noparent := Request.Params.Values['noparent']; //2022-07-12 add
              ScriptInfo.AllFileNameList := TStringList.Create;
              ScriptInfo.AllFileTimeList := TList<TDatetime>.Create;

              AddFileTimeToList(ScriptInfo, FileName);
              if IncFileSL <> nil then
              begin
                for lp := 0 to IncFileSL.Count - 1 do
                  AddFileTimeToList(ScriptInfo, IncFileSL[lp]);

              end;
              CriticalSection_Script.Enter;
              try
               ScriptList.Add(ScriptInfo);
              finally
                ScriptInfo.Used := false;
                CriticalSection_Script.Leave;
              end;
            end;
            {$endif}
          except
            on e: exception do
              raise Exception.Create(e.Message + '{run205}');
          end;
        end;
      end else
      begin
        Tmp := '';
        if DMInfo.Psscript1.CompilerMessageCount > 0 then
          for i:= 0 to DMInfo.Psscript1.CompilerMessageCount-1 do
            Tmp := Tmp + #13#10 + (DMInfo.Psscript1.CompilerErrorToStr(i));
        Tmp := trim(Tmp);
        WriteRunLogToFile(Tmp + '{run02}');
        DMInfo.LastHtml := DMInfo.LastHtml + Tmp + '{run02}';
        WriteRunLogToFile(DMInfo.LastHtml + '[' + FileName + ']' + GetOthInfo(Port, Request));
      end;
    end;
  end;
  Result := true;
end;

class procedure TRunner.RunOnePspFile(DMInfo: TDMInfo; Session: TObject; Service_Path, FileName: string; Port: integer;
  Request: TminiHTTPRequest; Response: TminiHTTPResponse);
var
  TmpStr, ErrStr, ContentText: string;
  ScriptInfo: TScriptInfo;
  IsDoing: boolean;
  IncFileSL: TStringlist;
  ScriptIndex, I, lp, Index, tryCount: integer;
  Pub: TPubbase;
  procedure FreeOneObj(o: TScriptInfo);
  begin
    try
      O.MS := '';
      O.AllFileNameList.Free;
      O.AllFileTimeList.Free;
      O.Free;
    except
    end;
  end;
  procedure Free_AllOBJ;
  var
    lp: integer;
  begin
    try
      CriticalSection.Enter;
      try
        FreeDM(false);
        DMInfo := nil;
        CriticalSection_Script.Enter;
        try
          for lp := 0 to ScriptList.Count - 1 do
          begin
            try
              FreeOneObj(TScriptInfo(ScriptList[lp]));
            except
            end;
          end;
          ScriptList.Clear;
          ScriptInfo := nil;
        finally
          CriticalSection_Script.Leave;
        end;
      finally
        CriticalSection.Leave;
      end;
    except
    end;
  end;
  procedure FreeOne_except;
  begin
    WriteRunLogToFile('begin freeOneOBJ ***** #####:' + ContentText); //2019-10-25 add
    CriticalSection.Enter;
    try
      CriticalSection_Script.Enter;
      try
        try
          if ScriptInfo <> nil then
          begin
            Index := ScriptList.IndexOf(ScriptInfo);
            if Index > -1 then
              ScriptList.Delete(Index);
            FreeOneObj(ScriptInfo);
            ScriptInfo := nil;
            WriteRunLogToFile('freeOBJ ScriptInfo...');
          end;
        except
        end;
      finally
        CriticalSection_Script.Leave;
      end;
      try
        FreeOneDM_Obj(DMInfo);
        Index := DMList.IndexOf(DMInfo);
        DMInfo.Free;
        if Index > -1 then
          DMList.Delete(Index);
        DMInfo := nil;
        WriteRunLogToFile('freeOBJ DMInfo...');
      except
      end;
    finally
      CriticalSection.Leave;
    end;
    WriteRunLogToFile('end freeOneOBJ ***** #####'); //2019-10-25 add
  end;
begin

  Response.ContentText := '';
  Response.ContentType := 'text/html;charset=UTF-8';
  Request.Service_Path := Service_Path;
  Request.Service_FileName := FileName;

  //2020-05-13 add
  if ServerInfo.AutoPCAndMobile and IsMobile(Request) and (Pos('_m.', FileName) < 1) then
  begin
    TmpStr := ExtractFilePath(FileName) + ChangeToMobileFileName(FileName, ServerInfo.AutoPCAndMobileExt);
    if FileExists(TmpStr) then
      FileName := TmpStr;
  end;

  if not FileExists(FileName) then
  begin
    TRunner.GoToErrPage(DMInfo, Session, Service_Path, ReplacExt(FileName), Port, Request, Response); //'无法找到文件[' + ReplacExt(ExtractFileName(FileName)) + ']！(Error code: 3000)'
    exit;
  end else
  begin
    tryCount := 3;
    for I := 1 to tryCount do
    begin
      if FIsFreeAllObj then
      begin //2022-08-01 add
        Sleep(1000);
        Continue;
      end;

      (*DMInfo := GetDMInfo(Request);
      {$ifndef nonedmmaxcount}
      if DMInfo = nil then
      begin
        //ContentText := '服务太忙，请稍候再试(Error code: 5000)!';
        GoToBusyPage(1, Service_Path, ReplacExt(FileName), Port, Request, Response);
        exit;
      end else
      {$endif}//*)
      begin
        IncFileSL := nil;
        Pub := DMInfo.Pub; //
        Pub := TPubbase.Create;
        try
          DMInfo.Pub := Pub;
          DMInfo.LastHtml := '';
          DMInfo.Request := Request;
          DMInfo.Response := Response;
          IsDoing := false;
          try
            Request.DMInfo := DMInfo;
            ScriptInfo := GetScriptInfo(FileName, ScriptIndex, Request.Params.Values['noparent']);
            try
              {$ifndef nonecachescript}
              //if (ScriptInfo <> nil) and (ScriptInfo.MS <> '') and (DMInfo.PSScript1.Exec <> nil) and
              //(DMInfo.PSScript1.Exec.GetTypeCount > 0) and (DMInfo.PSScript1.Exec.GetProcCount > 0) then
              //if ScriptInfo <> nil then
              if (ScriptInfo <> nil) and (ScriptInfo.MS <> '') and (DMInfo.PSScript1 <> nil) and (DMInfo.PSScript1.Exec <> nil) and
                 (DMInfo.PSScript1.Exec.GetTypeCount > 0) and (DMInfo.PSScript1.Exec.GetProcCount > 0) then
                IsDoing := true
              else
              {$endif}
              begin
                for lp := 1 to 3 do
                begin
                  try
                    ErrStr := '';
                    DMInfo.TmpSl.LoadFromFile(FileName, TEncoding.UTF8);
                    break;
                  except
                    on e: exception do
                    begin
                      {$ifndef fpc}
                      if Pos('Unicode character exists', e.Message) > 0 then
                      begin
                        DMInfo.TmpSl.LoadFromFile(FileName);
                        break;
                      end else
                      {$endif}
                      ErrStr := e.Message;
                      Sleep(100);
                    end;
                  end;
                end;

                //处理导入文件 <!--#include file="count.inc" -->
                TmpStr := Pro_include_file(IncFileSL, DMInfo.TmpSl, ExtractFilePath(FileName), FileName, DMInfo.TmpSl.Text);

                //2022-07-12 add 处理父模板
                if Request.Params.Values['noparent'] = '1' then
                  ContentText := HtmlScriptToPasCode(DMInfo.TmpSl, TmpStr, IsDoing)
                else
                begin
                  TmpStr := Pro_ParentMb(DMInfo.TmpSl, Service_Path, ExtractFilePath(FileName), FileName, TmpStr, ErrStr);
                  if ErrStr <> '' then
                    ContentText := ErrStr
                  else
                    ContentText := HtmlScriptToPasCode(DMInfo.TmpSl, TmpStr, IsDoing);
                end;
                DMInfo.TmpSl.Clear;
              end;

              //开始解释执行
              try
                if IsDoing then
                begin
                  RunScript(Pub, Port, IncFileSL, FileName, ScriptInfo, Request, Response, DMInfo, ContentText);
                  ContentText := DMInfo.LastHtml;
                  DMInfo.LastHtml := '';
                  //Run-time error ## UnhandledException(运行时错误) (Access violation at address 00E67997 in module 'shserver.exe'. Read of address 00000000) raised at line 156
                  //Access violation at address 0040A67E in module 'shserver.exe'. Read of address 00000028{run02}
                  {if (Pos('Access violation at address', ContentText) > 0) then
                  begin
                    if (Pos('Run-time error ##', ContentText) = 1) or (Pos('{run02', ContentText) > 0) or (Pos('shserver.exe', ContentText) > 0)  then
                    begin //2022-06-18 add\
                      if FIsFreeAllObj then Continue;
                      FreeOne_except;
                      Continue;
                    end;
                  end else
                  if Pos('Out of memory', ContentText) > 0 then
                  begin //2022-08-01 add\
                    if FIsFreeAllObj then Continue;
                    FIsFreeAllObj := true;
                    try
                      WriteRunLogToFile('Out of memory freeAllOBJ %%%%%'); //2019-10-25 add
                      Free_AllOBJ;
                    finally
                      FIsFreeAllObj := false;
                    end;
                    Continue;
                  end;}
                end;
              except
                on e: exception do
                begin //2022-02-25 19:23:00.858 Access violation at address 00021278. Execution of address 00021278 被访问网址:/test/coolsite/check_2020.asp 被访问主机:www.168318.com 被访问端口:80 访问客户IP:124.71.164.98@54622  Mozilla/3.0 (compatible; Indy Library) 来源:
                  DMInfo.LastHtml := '';
                  ContentText := '执行文件[' + ReplacExt(ExtractFileName(FileName)) + ']时意外出错！(Error code: 6000)' + e.Message;
                  WriteRunLogToFile(ContentText + GetOthInfo(Port, Request)); //2019-10-25 add
                  //if (Pos('violation at address', e.Message) > 0) or
                     //2022-03-03
                  //   (Pos('nvalid pointer', e.Message) > 0)  then
                  begin //2022-02-25 add
                    if FIsFreeAllObj then Continue;
                    FIsFreeAllObj := true;
                    try
                      //WriteRunLogToFile('begin freeAllOBJ ***** @@@1@@'); //2019-10-25 add
                      Free_AllOBJ;
                      //WriteRunLogToFile('end freeAllOBJ ***** @@@1@@'); //2019-10-25 add
                    finally
                      FIsFreeAllObj := false;
                    end;
                    Continue;
                  end;
                end;
              end;
            finally
              if ScriptInfo <> nil then ScriptInfo.Used := false;
            end;
          except
            on e: exception do
            begin
              if FIsFreeAllObj then Continue;
              FIsFreeAllObj := true;
              try
                //WriteRunLogToFile('begin freeAllOBJ ***** @@@2@@'); //2019-10-25 add
                Free_AllOBJ;
                //WriteRunLogToFile('end freeAllOBJ ***** @@@2@@'); //2019-10-25 add
              finally
                FIsFreeAllObj := false;
              end;
              Continue;
              ContentText := '读取文件[' + ReplacExt(ExtractFileName(FileName)) + ']时出错！(Error code: 7000)' + e.Message;
              WriteRunLogToFile(ContentText + GetOthInfo(Port, Request)); //2019-10-25 add
            end;
          end;
        finally
          if IncFileSL <> nil then IncFileSL.Free;
          IncFileSL := nil;
          Pub.Free;
          if Request.PostStream <> nil then Request.PostStream.Clear;
          Request.ContentText := '';
          Request.PostedData_mORMot := '';
        end;
      end;
      break;
    end;
  end;  //@ContentType=application/json@                     //application/json
  {if Pos('@ContentType=application/json@', ContentText) = 1 then
  begin
    Response.ContentType := 'application/json';
    Response.ContentText := GetDeliBack(ContentText, '@application/json@');
  end else
  begin
    Response.ContentType := 'text/html;charset=UTF-8';
    Response.ContentText := ContentText;
  end;}
  if trim(Response.ContentType) = '' then
    Response.ContentType := 'text/html;charset=UTF-8';
  if ('[%Redirect_302%]' <> Response.ContentText) and (Response.ContentText = '') then
    //2023-06-08 Response.ContentText := ContentText; //'[%Redirect_302%]'
  begin
    Response.ContentText := ContentText;
    {$ifndef fpc}
    Response.ContentText := AnsiToUtf8(ContentText)
    {$else}
    Response.ContentText := string(ContentText)
    {$endif}
  end;
end;

class procedure TRunner.LoadYSFile(Port: integer; //Host, RemoteIP, RemotePort, Document, RawHTTPCommand: string;
  YsHost, FileName: string; ARequestInfo: TminiHTTPRequest; Response: TminiHTTPResponse);
var
  //TextFormat: TTextFormat;
  IdHttp: TIdHTTP;
  Url: string;
begin    //YsHost = 'http://www.168318.com'   FileName = 'bbs/Default.asp'
  //if Pos() then
  //if not FileExists(YsHost + FileName) then
  begin
    Response.ContentType := 'text/html;charset=UTF-8';// MIMEMap.GetFileMIMEType(FileName);//GetMIMETypeFromFile(ldoc); //'text/css/html';
    Response.ContentText := '';
    try
      IdHttp := TIdHTTP.Create(nil);
      try                                     //ARequestInfo.QueryParams
        Url := YsHost + FileName;
        if trim(ARequestInfo.QueryParams) <> '' then
          Url := Url + '?' + ARequestInfo.QueryParams;
        Url := StringReplace(Url, '\', '/', [rfReplaceAll, rfIgnoreCase]);
        Response.ContentText := IdHttp.Get(URL);
      finally
        IdHttp.Free;
      end;
    except
      on e: exception do
        Response.ContentText := e.Message + '  ' + Url;
    end;
  end {else
  begin
    Response.ContentType := MIMEMap.GetFileMIMEType(FileName);//GetMIMETypeFromFile(ldoc); //'text/css/html';
    try
      ReadTextFile(FileName, TextFormat);
    except
    end;

    if TextFormat = tfANSI then
      Response.ContentType := Response.ContentType + ';Charset=gb2312'
    else
      Response.ContentType := Response.ContentType + ';charset=UTF-8';
    Response.FreeContentStream := true;
    try
      Response.ContentStream := TFileStream.create(FileName, fmOpenRead	or fmShareDenyWrite);
    except
      on e: exception do
        WriteRunLogToFile(e.Message + GetOthInfo(Port, ARequestInfo)); //2019-10-25 add
    end;
  end};
end;

{ TGarbageCollector }

constructor TGarbageCollector.Create();
begin
  FreeOnTerminate := true;
  inherited Create(False);
  FreeOnTerminate := true;
end;

destructor TGarbageCollector.Destroy;
begin
  inherited Destroy;
end;

procedure TGarbageCollector.RefInfo;
begin
  //THttpServerFrm(FForm).UpdateStatus();
end;

procedure WriteInnerLog(Text: string);
begin
  PubFile.FileWriteLog(ExtractFilePath(ParamStr(0)) + 'Log\Inner.txt', Text, 2500);
end;

procedure FreeOneConn_Obj(ConnInfo: TminiPooler);
begin
  try
    if ConnInfo.Query <> nil then
    begin
      try
        ConnInfo.Query.Close;
        ConnInfo.Query.Free;
      except
      end;
    end;

    if ConnInfo.aHJHMemodataset <> nil then
      ConnInfo.aHJHMemodataset.Free;

    if ConnInfo.aConnection1 <> nil then
    begin
      try
        ConnInfo.aConnection1.Connected := false;
        ConnInfo.aConnection1.Free;
      except
      end;
    end;

    if ConnInfo.aTmpSl <> nil then
      ConnInfo.aTmpSl.Free;
  except
  end;
end;

procedure FreeOneScript_Obj(ScriptInfo: TScriptInfo);
begin
  try
    if ScriptInfo.AllFileNameList <> nil then
    begin
      try
        ScriptInfo.AllFileNameList.Free;
      except
      end;
      try
        ScriptInfo.AllFileTimeList.Free;
      except
      end;
    end;
  except
  end;
end;

procedure FreeConn;
var
  lp: Integer;
begin
  CriticalSection_Conn.Enter;
  try
    for lp := ConnList.Count - 1 downto 0 do
    begin
      try
        FreeOneConn_Obj(ConnList[lp]);
        TminiPooler(ConnList[lp]).Free;
        ConnList.Delete(lp);
      except
      end;
    end;
  finally
    CriticalSection_Conn.Leave;
  end;
end;

procedure FreeScript;
var
  lp: Integer;
begin
  CriticalSection_Script.Enter;
  try
    for lp := ScriptList.Count - 1 downto 0 do
    begin
      try
        FreeOneScript_Obj(ScriptList[lp]);
        TScriptInfo(ScriptList[lp]).Free;
        ScriptList.Delete(lp);
      except
      end;
    end;
  finally
    CriticalSection_Script.Leave;
  end;
end;

procedure TGarbageCollector.Execute;
var
  DMInfo: TDMInfo;
  //MyRunThread: TMyRunThread;
  ConnInfo: TminiPooler;
  ScriptInfo: TScriptInfo;
  aFileNameList, TmpSL: TStringlist;
  //aFileTimeList: TList<TDatetime>;
  aFileTimeList: TList<TDatetime>;
  AllCount, AllCount2, lp: int64;
  TmpStr: string;
  mds: THjhMemoryDataSet;
  {$ifdef fpc}
  Proc: TProcess;
  {$endif}
  procedure FreeOneIns(i: integer);
  begin
    try
      try
        WriteInnerLog('[Free no used Web Obj!]');
        //TDataModule(DMLt.Items[i]).Free;
        FreeOneDM_Obj(DMInfo);

        DMInfo.Free;
      except
        on e: exception do
          WriteInnerLog('[DMInfo.Free]' + e.Message);
      end;
      DMList.Delete(i);
      //DMLt.Delete(i);
      //Synchronize(RefInfo);
    except
    end;
  end;

  procedure CheckObjectList;
  var
    i, RdmCount: Integer;
    HadUsed: boolean;
  begin
    //for i := PoolManager.FRDMList.Count - 1 downto 0 do
    i := 0; // 删除要从最先创建的开始删除
    RdmCount := DMList.Count;
    while i < RdmCount do
    begin
      HadUsed := TDMInfo(DMList[i]).HadUsed;
      if HadUsed and (
        //2022-06-29 add  一个实例大于3小时无论如何也要释放
        (HoursBetween(Now, TDMInfo(DMList[i]).Start) < 3)) then
      begin
        Inc(i);
        Continue;
      end;

      DMInfo := TDMInfo(DMList[i]);
      //24*60*60 = 86400 = 1秒
      if (RdmCount > ServerInfo.poolermincount) and (Abs(Round((Now - DMInfo.Start) * 86400)) > ServerInfo.poolertimeout) then // * 60
      //if Abs(Round((Now - DMInfo.Start) * 86400)) > 60 then //test
      begin
        try
          //FreeTrans;
          FreeOneIns(i);
          WriteInnerLog('[Free Web Obj!] ');
        except
        end;
      end else
        Inc(i);
      RdmCount := DMList.Count; //2008-02-01
    end;
  end;
  //////////conninfo start
  procedure FreeOneIns_Conn(i: integer);
  begin
    try
      try
        WriteInnerLog('[Free no used Conn Obj!]');
        //TDataModule(DMLt.Items[i]).Free;
        FreeOneConn_Obj(ConnInfo);

        ConnInfo.Free;
      except
        on e: exception do
          WriteInnerLog('[ConnInfo.Free]' + e.Message);
      end;
      ConnList.Delete(i);
      //DMLt.Delete(i);
      //Synchronize(RefInfo);
    except
    end;
  end;

  procedure CheckObjectList_Conn;
  var
    i, RdmCount: Integer;
  begin
    //for i := PoolManager.FRDMList.Count - 1 downto 0 do
    i := 0; // 删除要从最先创建的开始删除
    RdmCount := ConnList.Count;
    while i < RdmCount do
    begin
      ConnInfo := TminiPooler(ConnList[i]);
      //201-05-29 mod if (Pos('1/', Connlist[i]) > 0) then
      if ConnInfo.HadUsed then
      begin
        if MinutesBetween(Now, ConnInfo.Start) > 30 then  //2022-06-29 add  一个实例大于30分钟无论如何也要释放
        begin
          try
            FreeOneIns_Conn(i);
            WriteInnerLog('[Free Conn Obj——timeout!] ');
          except
          end;
        end else
          Inc(i);
        Continue;
      end;
      //2008-01-21改为5分钟 300 = 5 * 60 ---- 十分钟 600 = 10 * 60 事务提交最长10分钟
      if (Abs(Round((Now - ConnInfo.Start) * 86400)) > ServerInfo.poolertimeout) then // * 60
      //if Abs(Round((Now - DMInfo.Start) * 86400)) > 60 then //test
      begin
        if (RdmCount > ServerInfo.poolermincount) then
        begin
          try
            //FreeTrans;
            FreeOneIns_Conn(i);
            WriteInnerLog('[Free Conn Obj!] ');
          except
          end;
        end else
        begin
          Inc(i);
          try
            if ConnInfo.Query <> nil then
              ConnInfo.Query.Close;
          except
          end;
          try
            if ConnInfo.Conn <> nil then
              ConnInfo.Conn.Connected := false;
          except
          end;
        end;
      end else
        Inc(i);
      RdmCount := ConnList.Count;
    end;
  end;

  procedure FreeOneIns_Scrpit(i: integer);
  begin
    try
      try
        WriteInnerLog('[Free no used Script Obj!]');
        //TDataModule(DMLt.Items[i]).Free;
        FreeOneScript_Obj(ScriptInfo);

        ScriptInfo.Free;
      except
        on e: exception do
          WriteInnerLog('[ScriptInfo.Free]' + e.Message);
      end;
      ScriptList.Delete(i);
      //DMLt.Delete(i);
      //Synchronize(RefInfo);
    except
    end;
  end;

  procedure CheckObjectList_Script;
  var
    i, RdmCount, Index, lp: Integer;
    Flag: boolean;
    FileName: string;
  begin
    //for i := PoolManager.FRDMList.Count - 1 downto 0 do
    aFileNameList.Clear;
    aFileTimeList.Clear;
    i := 0; // 删除要从最先创建的开始删除
    RdmCount := ScriptList.Count;
    while i < RdmCount do
    begin
      //201-05-29 mod if (Pos('1/', Connlist[i]) > 0) then
      if TScriptInfo(ScriptList[i]).Used then
      begin
        Inc(i);
        Continue;
      end;

      ScriptInfo := TScriptInfo(ScriptList[i]);
      //2008-01-21改为5分钟 300 = 5 * 60 ---- 十分钟 600 = 10 * 60 事务提交最长10分钟
      //if Abs(Round((Now - RDM.StartTransTime) * 86400)) > 300 then

      //2008-08-08改为3分钟 180 = 3 * 60

      //2016-09-27 mod if Abs(Round((Now - RDM.StartTransTime) * 86400)) > 180 then
      //if Fpoolertimeout < 3 then Fpoolertimeout := 3;

      //先检查是否超时
      Flag := Abs(Round((Now - ScriptInfo.Start) * 86400)) > ServerInfo.poolertimeout;
      //再检查文件是否已修改
      if not Flag then
      begin
        for lp := 0 to ScriptInfo.AllFileNameList.Count - 1 do
        begin
          FileName := ScriptInfo.AllFileNameList[lp];
          Index := aFileNameList.IndexOf(FileName);
          if Index < 0 then
          begin
            aFileNameList.Add(FileName);
            aFileTimeList.Add(FileGetFileTime(FileName));
            Index := aFileTimeList.Count - 1;
          end;
          Flag := aFileTimeList[Index] <> ScriptInfo.AllFileTimeList[lp];
          if Flag then break;
        end;
      end;

      if Flag then
      begin
        try
          FreeOneIns_Scrpit(i);
          WriteInnerLog('[Free Script Obj!] ');
        except
        end;
      end else
        Inc(i);
      RdmCount := ScriptList.Count;
    end;
  end;
begin
  AllCount := 0;
  AllCount2 := 0;
  aFileNameList := TStringlist.Create;
  aFileTimeList := TList<TDatetime>.Create;
  TmpSL := TStringlist.Create;
  try
    while not Terminated do
    begin
      Sleep(3000);

      if (FileExists(ServerInfo.ProgramPath + 'setting\start__.f')) then
      begin //完全重启exe
        (*{$ifdef fpc}
        Proc := TProcess.Create(nil);
        try
          Proc.CommandLine := ParamStr(0);
          //PRoc.Options := Proc.Options + [poWaitOnExit];
          PRoc.Execute;
        finally
          Proc.free;
        end;
        {$else}*)
        {$ifdef mswindows}
        ShellExecute(0, 'Open', PChar(ParamStr(0)), nil, nil, 1);
        {$endif};
        //{$endif}
        {$ifdef MSWINDOWS}
        ExitProcess(0);
        {$else}
        {$endif}
        exit;
      end;

      AllCount := AllCount + 1;
      AllCount2 := AllCount2 + 1;
      try
        //if AllCount mod 60 = 0 then
        begin
          ///TmpSL.Clear;
          //TmpSL.Add('检查线程 start ');
          CriticalSection.Enter;
          try
            //TmpSL.Add('检查线程 a ');
            //if DMList.Count > Fpoolermincount then
              CheckObjectList;
          finally
            CriticalSection.Leave;
          end;

          CriticalSection_Conn.Enter;
          try //2019-09-14 add
            //TmpSL.Add('检查线程 b ');
            //if ConnList.Count > Fpoolermincount then
              CheckObjectList_Conn;
          finally
            CriticalSection_Conn.Leave;
          end;

          CriticalSection_Script.Enter;
          try //2019-09-14 add
            //TmpSL.Add('检查线程 c ');
            CheckObjectList_Script;
          finally
            CriticalSection_Script.Leave;
          end;

          //2022-11-21 add //删除过期的session
          if (AllCount > 50) and (WSessions <> nil) then
          try
            AllCount := 0;
            WSessions.PurgeStaleSessions();
          except
          end;
        end;
      except
        on e: exception do
          WriteInnerLog('[WEB_CheckObjectList]' + e.Message);
      end;

      //每15秒读取一次看账套是否已禁用
      try
        TmpStr := ExtractFilePath(ParamStr(0)) + 'setting\confmx.json';
        if (AllCount2 mod 15 = 0) and FileExists(TmpStr) then
        begin
          mds := THjhMemoryDataSet.Create(nil);
          try
            DBMemory_LoadJson(mds, TmpStr);
            Decrypt(mds, 'dbpwd=ftString@0#数据库密码@1#@2#0@3#0@4#1@5#@6#0@7#0@8#0@9#1@10#');
            //CriticalSection_Conn.Enter; //不需要
            try
              for lp := ConnList.Count - 1 downto 0 do
              begin
                ConnInfo := TminiPooler(ConnList[lp]);
                mds.First;
                while not mds.Eof do
                begin
                  if SameText(mds.V('ztcode'), Trim(ConnInfo.AZTCode)) then
                  begin
                    ConnInfo.ztstop := mds.V('ztstop') = 'on';
                    break;
                  end;
                  mds.Next;
                end;
              end;

            finally
              //CriticalSection_Conn.Leave;
            end;
          finally
            mds.Free;
          end;
        end;
      except
        on e: exception do
          WriteInnerLog('[Zt_CheckObjectList]' + e.Message);
      end;

      //每30秒读取一次配置信息，即修改参数后要30秒后生效
      if (AllCount2 mod 30 = 0) and FileExists(TmpStr) then
      begin
        TmpStr := ReadParams;
        if trim(TmpStr) <> '' then
          WriteInnerLog('[ReadParams_CheckObjectList]' + TmpStr);
      end;
    end;
  finally
    TmpSL.Free;
    aFileNameList.Free;
    aFileTimeList.Free;
  end;
end;

procedure IniAll;
begin
  {$IFDEF FPC}
  ServerInfo.ProgramPath := ProgramDirectory;
  {$else}
  ServerInfo.ProgramPath := ExtractFilePath(ParamStr(0));
  {$endif}
  ServerInfo.mainservicepath := ServerInfo.ProgramPath + 'host\';
  ServerInfo.httpport := '899';
  ServerInfo.serviceext := '.html';
  ServerInfo.starthttps := false;
  ServerInfo.poolertimeout := 60;
  ServerInfo.Poolermaxcount := 100;
  ServerInfo.poolermincount := 0;
  ServerInfo.threadcount := 50;
  ServerInfo.quequelength := 10000;
  ServerInfo.servernocachefile := false;
  ServerInfo.crossdomain := false;
  ServerInfo.AutoZip := false;
  ServerInfo.autopcandmobile := false; //2020-05-13 add
  ServerInfo.AutoPCAndMobileExt := '_m';
  FLogInfo.FIsLog := true;//默认记录日志


  DMList := TList.Create;
  CriticalSection := TMiniCriticalSection.Create;
  ConnList := TList.Create;
  CriticalSection_Conn := TMiniCriticalSection.Create;
  ScriptList := TList.Create;
  CriticalSection_Script := TMiniCriticalSection.Create;
  QueList := TList<TObject>.Create;
  CriticalSection_Log := TMiniCriticalSection.Create;
  CriticalSection_RunLog := TMiniCriticalSection.Create;
  CriticalSection_Sqe := TMiniCriticalSection.Create;
  ServerInfo.hosttodirSL := TStringList.Create;
  ServerInfo.DirSL := TStringList.Create;
  ServerInfo.CacheName := TStringList.Create;
  ServerInfo.CacheText := TStringList.Create;
  ServerInfo.exttoserver := TStringList.Create;

  ServerInfo.blacklist := TStringList.Create;
  ServerInfo.whitelist := TStringList.Create;
  ServerInfo.Usedblacklist := TStringList.Create;
  ServerInfo.Usedwhitelist := TStringList.Create;
  ServerInfo.Usedblacklist.Sorted := true;
  ServerInfo.Usedwhitelist.Sorted := true;
  //MyRegister;
  MIMEMap := TIdMIMETable.Create;
  FLogInfo.FTF_IsIni := false;
  FLogInfo.FTF_IsIni_Run := false;
  GarbageCollector := TGarbageCollector.Create();
  try
    FLogInfo.FServiceLog_File := ServerInfo.ProgramPath + 'log\Service.txt';
    ForceDirectories(ExtractFilePath(FLogInfo.FServiceLog_File));
  except
  end;
  FLogInfo.FRunLog_File := ServerInfo.ProgramPath + 'log\Run.txt';
end;
procedure LastAll;
begin
  GarbageCollector.Free;

  FreeDM;  //FullDebugMode LogMemoryLeakDetailToFile EnableMemoryLeakReporting
  DMList.Free;
  CriticalSection.Free;

  FreeConn;
  ConnList.Free;
  CriticalSection_Conn.Free;
  CriticalSection_Log.Free;
  CriticalSection_RunLog.Free;

  FreeScript;
  ScriptList.Free;
  CriticalSection_Script.Free;
  QueList.Free;
  CriticalSection_Sqe.Free;
  MIMEMap.Free;

  ServerInfo.DirSL.Free;
  ServerInfo.hosttodirSL.Free;
  ServerInfo.CacheName.Free;
  ServerInfo.exttoserver.Free;
  ServerInfo.CacheText.Free;

  ServerInfo.blacklist.Free;
  ServerInfo.whitelist.Free;
  ServerInfo.Usedblacklist.Free;
  ServerInfo.Usedwhitelist.Free;

end;

initialization
  IniAll;

finalization
  LastAll;
end.

end.
(*
  fpc版修改了uPSRuntime的，原因：内存泄漏
procedure TPSStack.SetCapacity(const Value: Longint);
var
  p: Pointer;
  OOFS: IPointer;
  I: Longint;
begin
  if Value < FLength then raise Exception.Create(RPS_CapacityLength);
  if Value = 0 then
  begin
    if FDataPtr <> nil then
    begin
      FreeMem(FDataPtr, FCapacity);
      FDataPtr := nil;
    end;
    FCapacity := 0;
  end;


  //hjh add
  if Value = 0 then
  begin
    p := nil;
  end else
  //hjh add end
  begin
    GetMem(p, Value);


    if FDataPtr <> nil then
    begin
      if FLength > FCapacity then
        OOFS := FCapacity
      else
        OOFS := FLength;
      Move(FDataPtr^, p^, OOFS);
      OOFS := IPointer(P) - IPointer(FDataPtr);

      for i := Count -1 downto 0 do begin
        Data[i] := Pointer(IPointer(Data[i]) + OOFS);
        if Items[i].FType.FBaseType = btPointer then begin // check if pointer points to moved stack data
          if (IPointer(PPSVariantPointer(Data[i]).DataDest) >= IPointer(FDataPtr)) and
             (IPointer(PPSVariantPointer(Data[i]).DataDest) <  IPointer(FDataPtr)+IPointer(FLength)) then
            PPSVariantPointer(Data[i]).DataDest := Pointer(IPointer(PPSVariantPointer(Data[i]).DataDest) + OOFS);
        end;
      end;

      FreeMem(FDataPtr, FCapacity);
    end;
  end;
  FDataPtr := p;
  FCapacity := Value;
end;

*)
