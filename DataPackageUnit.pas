{*******************************************************}
{                                                       }
{                  通用内存数据集控件                   }
{                                                       }
{  功能：实现如TDataSet一样的内存数据集控制,支持Blob数据}
{*******************************************************}

//////////////////////////////////////////////////////////////////////////////////
///                                                                            ///
///  miniframe开源Web框架技术群：821855479 如果加不了群，请联系QQ：3123827806  ///
///  网页制作器网址：https://wyeditor.com                                      ///
///  源码及demo下载：https://wyeditor.com/miniframe/                           ///
///                                                                            ///
//////////////////////////////////////////////////////////////////////////////////

{$ifdef fpc}
{$MODE Delphi}
{$endif}
{.$INCLUDE Test.inc}

{$ifdef clientdotnet}
{$else}
unit DataPackageUnit;

interface

uses
  SysUtils, Classes, db,  Generics.Collections, Generics.Defaults, TypInfo{,
    IdGlobalProtocols};

type
  THjhMemoryDataSet = class;

  TMFieldType = TFieldType{(mftUnknown, mftString, mftInteger,
    mftBoolean, mftFloat, mftCurrency, mftDate, mftTime, mftDateTime,
    mftBytes, mftBlob, mftWideString, mftVariant)};

  PInfo = ^TInfo;
  TInfo = packed record
    {$IFDEF MSWINDOWS}
    FieldName: string[100];
    {$else}
    FieldName: string;
    {$ENDIF}
    RecordNo: integer;
    Size: integer;
  end;

  PSQLInfo = ^TSQLInfo;
  TSQLInfo = packed record
    {$IFDEF MSWINDOWS}
    TableName: string[100];
    {$else}
    TableName: string;
    {$endif}
    Size: integer;
  end;

  TMFields = class;

  EIndexOutBands = class(Exception)
  public
    constructor Create;reintroduce;
  end;

  ENotBlobError = class(Exception)
  public
    constructor Create;reintroduce;
  end;

  EBlobError = class(Exception)
  public
    constructor Create;reintroduce;
  end;

  TMField = class(TComponent)
  private
    FFieldName: string;
    FMDataType: TMFieldType;
    FCurPos: Integer;
    FSlList, FTmpSL: TStringList;
    FParentFields: TMFields;
    function GetAsBoolean: Boolean;
    function GetAsCurrency: Currency;
    function GetAsDateTime: TDateTime;
    function GetAsFloat: Double;
    function GetAsInteger: Longint;
    function GetAsString: string;
    function GetAsVariant: Variant;
    function GetFieldNo: Integer;
    function GetIsNull: Boolean;

    function GetStringValue: string;
    procedure SetStringValue(Value: string);

    procedure SetAsBoolean(const Value: Boolean);
    procedure SetAsCurrency(const Value: Currency);
    procedure SetAsDateTime(const Value: TDateTime);
    procedure SetAsFloat(const Value: Double);
    procedure SetAsInteger(const Value: Longint);
    procedure SetAsString(const Value: string);
    procedure SetAsVariant(const Value: Variant);
    function GetAsDate: TDate;
    function GetAsTime: TTime;
    procedure SetAsDate(const Value: TDate);
    procedure SetAsDTime(const Value: TTime);
    function GetCommaText: string;
    procedure SetCommaText(const Value: string);
    function GetText: string;
    procedure SetText(const Value: string);
    function GetStringValueEx(CurPos: integer): string;
    function BlobLoadFromFile_ToBase64(const FileName: string; var ErrStr: string): boolean;
    function BlobLoadFromStream_ToBase64(Stream: TMemoryStream; var ErrStr: string): boolean;
  public
    function GetCommaTextEx: string;
    function IndexOf(Value: string): integer;
    constructor Create(AOwer: TComponent);override;
    destructor Destroy; override;
    procedure Clear;
    function AsStringEx(Row: integer): string; //2020-08-28

    function BlobLoadFromFile(const FileName: string; var ErrStr: string): boolean;
    function BlobLoadFromStream(Stream: TMemoryStream; var ErrStr: string): boolean;
    function BlobSaveToFile(const FileName: string; var ErrStr: string): boolean;
    function BlobSaveToStream(Stream: TStream; var ErrStr: string): boolean;

  published
    property IsNull: Boolean read GetIsNull;

    property DataType: TMFieldType read FMDataType write FMDataType;
    property FieldName: string read FFieldName write FFieldName;
    property ParentFields: TMFields read FParentFields write FParentFields;

    property CurPos: integer read FCurPos write FCurPos default 0;
    property FieldNo: Integer read GetFieldNo;
    property CommaText: string read GetCommaText write SetCommaText;
    property Text: string read GetText write SetText;

    property AsVariant: Variant read GetAsVariant write SetAsVariant;
    property AsBoolean: Boolean read GetAsBoolean write SetAsBoolean;
    property AsCurrency: Currency read GetAsCurrency write SetAsCurrency;
    property AsDateTime: TDateTime read GetAsDateTime write SetAsDateTime;
    property AsDate: TDate read GetAsDate write SetAsDate;
    property AsTime: TTime read GetAsTime write SetAsDTime;
    property AsFloat: Double read GetAsFloat write SetAsFloat;
    property AsInteger: Longint read GetAsInteger write SetAsInteger;
    property AsString: string read GetAsString write SetAsString;

  end;

  TMFields = class(TObject)
  private
    FList: TList<TMField>;
    FOwer: TComponent;
    FParentMds: THjhMemoryDataSet;
    function GetFieldList: string;
    procedure SetFieldList(const Value: string);
  protected
    function GetCount: Integer;
    function GetField(Index: Integer): TMField;
    procedure SetField(Index: Integer; Value: TMField);
  public
    constructor Create(AOwer: TComponent);
    destructor Destroy; override;
    procedure Add(const FieldName: string; DataType: TMFieldType = ftString);
    procedure Clear;
    function FindField(const FieldName: string): TMField;
    function FieldByName(const FieldName: string): TMField;
    function FieldByNumber(FieldNo: Integer): TMField;
    function IndexOf(Field: TMField): Integer;
    procedure Remove(Field: TMField);
    procedure Delete(FieldName: string);
  {$ifdef fpc}
  published
  {$else}
  public
  {$endif}
    property Fields[Index: Integer]: TMField read GetField write SetField; default;
    //通过字段列表（以逗号分隔）传入，自动增加表头, 对于字段类型为数值型的要在名称后面加'*'标识
    //如：CORP_ID, WZ_ID, MEAS_ID, WZM_CONVRATE*, WZM_TS //在WZM_CONVRATE后加*表示WZM_CONVRATE为数值型
  published
    property Count: Integer read GetCount;
    property FieldList: string read GetFieldList write SetFieldList;
  end;

  THjhMemoryDataSet = class(TComponent)
  private
    FFields: TMFields;
    FBof, FEof, FNeedProcessBlob, FNeedSQLScript: boolean;
    FAbout: string;
    FSl, SQLScriptSl: TStringList;
    FTmpSL: TStringList;
    FDataSet: TDataSet;
    FTableName, FAliasName: string;
    FHint, FDataString: string;
    FBlobToBase64: boolean;
    function GetRecordCount: integer;
    function GetItems(index: integer): TMFields;
    function GetCurRecordPos: integer;
    procedure SetCurRecordPos(const Value: integer);
    procedure Save;
    procedure SaveSQLScript(Stream: TStream);
    procedure SaveBlob(Stream: TStream);
    procedure Load;
    procedure LoadBlob(Stream: TStream);
    procedure LoadSQLScript(Stream: TStream);
    function GetRecords(index: integer; FieldName: string): Variant;
    function GetCommaText: string;
    function GetCommaTextEx: string;
    procedure SetCommaText(const Value: string);
    function GetData: OleVariant;
    procedure SetData(const Value: OleVariant);
    procedure MyAddField;
    procedure OpenDataEx;
    procedure SetBlobToBase64(const Value: boolean);
  public
    NeedSingleQuotes: boolean; //2018-02-26 数据添加单引号

    constructor Create(AOwer: TComponent); override;
    destructor Destroy; override;

    procedure Clear; //清空数据和字段
    procedure ClearData;//清空数据
    function FieldByName(const FieldName: string): TMField; //通过字段名获取字段对象
    function FindField(const FieldName: string): TMField;  //通过字段名查找字段对象
    function V(const FieldName: string): string;           //通过字段名读取一项值，返回串
    procedure S(const FieldName, Value: string);           //通过字段名设置对应的值
    procedure Append;                                      //添加一行
    procedure Insert;overload;                             //在当前位置插入一行
    procedure Insert(Pos: integer);overload;               //在指定位置插入一行
    procedure Delete;overload;                             //删除当前行
    procedure Delete(Pos: integer);overload;               //删除指定下标的行
    procedure First;                                       //移到最前记录
    procedure Prior;                                       //移到前一记录
    procedure Next;                                        //移到下一记录
    procedure Last;                                        //移到最后记录
    procedure Go(const Pos: integer);                      //移到指定行
    function SaveToFile(const FileName: string; var ErrStr: string): boolean;   //保存到文件
    function SaveToStream(Stream: TStream; var ErrStr: string): boolean;        //保存到流
    function LoadFromFile(const FileName: string; var ErrStr: string): boolean; //从文件中加载
    function LoadFromStream(Stream: TStream; var ErrStr: string): boolean;      //从流中加载

    procedure Open; //取字段名和数据
    procedure OpenFields; //只读取字段，建表头
    procedure OpenData; //只从数据集中取数据
    procedure AddCurRow(MemoryStream: TMemoryStream); //添加一到mds中
    procedure Post;
    function IsEmpty: boolean;  //判断数据集是不是空

    procedure CopyOneRecord(SourMds: THjhMemoryDataset; NeedAppend: boolean = true); overload; //从SourMds复制数据集
    procedure CopyOneRecord(SourCds: TDataset); overload;                                      //从SourCds复制数据集
    procedure CopyToOneRecord(TargetCds: TDataset);                                            //把当前数据集复制到
    procedure SetCommaTextEx(const Value: string);

    //2022-05-12 add 通过文件后缀取适合base64的文件类型头信息
    //class function GetFileMIMEType(FileName: string): string;
    //class function GetFileMIMEType_Base64Head(FileName: string): string;
  {$ifdef fpc}
  published
  {$else}
  public
  {$endif}
    property Items[index: integer]: TMFields read GetItems;  //获取指定下标的列
    property Records[index: integer; FieldName: string]: Variant read GetRecords; //获取指定下标行指定的字段的值，这种方法获取多线程安全
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  published
    property Bof: boolean read FBof;                                              //是否最前面
    property Eof: boolean read FEof;                                              //是否最后面
    property CurRecordPos: integer read GetCurRecordPos write SetCurRecordPos;    //当前行的位置
    property Fields: TMFields read FFields write FFields;                         //字段对象集合
    property RecordCount: integer read GetRecordCount;                            //数据集记录数
    property CommaText: string read GetCommaText write SetCommaText;              //将数据集转为字符串
    property CommaTextEx: string read GetCommaTextEx write SetCommaText;
    property Data: Olevariant read GetData write SetData;                         //将数据集转为Olevariant

    property About: string read FAbout write FAbout;
    property NeedProcessBlob: boolean read FNeedProcessBlob write FNeedProcessBlob default true; //是否需要处理Blob字段
    property DataSet: TDataSet read FDataSet write FDataSet default nil;                         //绑定DataSet
    property NeedSQLScript: boolean read FNeedSQLScript write FNeedSQLScript default false;
    property AliasName: string read FAliasName write FAliasName;
    property TableName: string read FTableName write FTableName;
    property Hint: string read FHint write FHint;
    property DataString: string read FDataString write FDataString;
    property BlobToBase64: boolean read FBlobToBase64 write SetBlobToBase64; //2022-05-12 add   //是否把Blob数据转Base64存贮
  end;
//var
  //MIMEMap: TIdMIMETable;

implementation

uses  {dbtables,}PubSysUnit, Variants;
{ THjhMemoryDataSet }

function GetTableSQLScript(aTableName, aAliasName:string;
  SQLIncludeIndexes: boolean = true;SQLAutoWrap:Boolean = true;
  SQLSeparator:string = ''): string;
var
  //Query1: TQuery ;
  i:Integer ;
  S,S1,DTn : String ;
  Enterkey : string ;
begin
  if SQLAutoWrap then Enterkey := #13#10
  else Enterkey := '' ;
  result := '';
  {Query1:= TQuery.Create(nil);
  try
    Query1.Close;
    Query1.SQl.Clear;
    Query1.DatabaseName := aAliasName;
    Query1.SQL.text := 'select FieldName=left(a.name,255) ,'
      +'       DataTypeName=left(b.name,255),'
      +'       DataLen=a.length,'
      +'       CanNull=columnproperty(object_id("'+aTableName+'"),a.name,"AllowsNull"),'
      +'       DefaultValue=(select left(text,20) from syscomments where  id= a.cdefault) '
      +'    from syscolumns a,systypes b '
      +'    where a.id=object_id("'+aTableName+'") '
      +'      and a.xtype=b.xtype'
      +'    order by a.colid';
    Query1.Open ;
    s := 'Create Table [dbo].['+aTableName+'](' ;
    While not Query1.Eof do
    begin
      if Pos(' ['+trim(Query1 .FieldByName('FieldName').AsString)+'] ',s) > 0 then
      begin
        Query1.Next;
        Continue;
      end;
      DTn := trim(Query1.FieldByName('DataTypeName').AsString) ;
      S := s +EnterKey+'      ['+trim(Query1 .FieldByName('FieldName').AsString)+'] ['
             +DTn+'] ';
      if (Pos('char',LowerCase(DTn))>0)or(Pos('binary',LowerCase(DTn))>0) then
        S := S+'('+Trim(Query1.FieldByName('DataLen').AsString)+') ';
      if (pos('numeric',LowerCase(DTn))>0) then
        S := S+'(5,0) ';
      if Query1.FieldByName('CanNull').AsInteger = 0 then
        S := S+' Not Null '
      else S := S + ' Null ';
      S1 := Query1.FieldByName('DefaultValue').AsString ;
      i  := Pos('(',s1) ;
      if i>0 then
        S := S + ' Default '+ S1;//Copy(s1,i+1,pos(')',s1)-i-1);hjh改为这句
      S := S +' ,';
      Query1.next ;
    end;
    S[Length(S)] := ')' ;
    if SQLSeparator<>'' then S := S+Enterkey+SQLSeparator+' '+EnterKey
    else S := S+EnterKey;

    if SQLIncludeIndexes then
    //包含索引
    begin
      Query1.Close;
      Query1.SQL.Text :='select IndexName=left(a.name,255), '
        +'       ColName=left(Col_name(object_id("'+aTableName+'"),b.colid),255),'
        +'       IndexOrder=b.keyno,'
        +'       IsUnique=indexproperty(object_id("'+aTableName+'"),a.name,"IsUnique")'
        +'   from sysindexes a,sysindexkeys b '
        +'  where a.id=object_id("'+aTableName+'") and a.id=b.id '
        +'    and left(a.name,1)<>''_'' '
        +'    and a.indid=b.indid and a.used>0 '
        +'  order by a.name,b.colid ';
      Query1.Open ;
      S1 := '';
      while not Query1.Eof do
      begin
        i := Query1.FieldByName('IsUnique').AsInteger ;
        if S1<>Query1.FieldByName('IndexName').AsString  then
        begin
          S1 := Query1.FieldByName('IndexName').AsString ;
          if i=1 then
            S := S +EnterKey+' Alter table '+aTableName+' add constraint '+
              Query1.FieldByName('IndexName').AsString+' UNIQUE CLUSTERED ('
          else
            S := S +EnterKey+' Create Index '+
              Query1.FieldByName('IndexName').AsString+' On '+ATableName+'(';
        end;
        S := S+Query1.FieldByName('ColName').AsString+',';

        Query1.next ;
        if Query1.Eof or(S1<>Query1.FieldByName('IndexName').AsString)  then
        begin
          S[length(S)] := ')';
          if SQLSeparator<>'' then S := S+Enterkey+SQLSeparator+' '+EnterKey
          else S := S+EnterKey;
        end;
      end;
    end;
  finally
    Query1.free;
  end; }
  Result := s;
end;

procedure THjhMemoryDataSet.Append;
var
  lp: integer;
begin
  for lp := 0 to Fields.Count - 1 do
  begin
    Fields.Fields[lp].FSlList.Add('');
    Fields.Fields[lp].CurPos := Fields.Fields[lp].FSlList.Count - 1;
  end;
  FBof := false;
  FEof := false;
end;

procedure THjhMemoryDataSet.Insert;
var
  lp: integer;
begin
  for lp := 0 to Fields.Count - 1 do
  begin
    if Fields.Fields[lp].FSlList.Count < 1 then
    begin
      Fields.Fields[lp].FSlList.Add('');
      Fields.Fields[lp].CurPos := 0;
    end else
      Fields.Fields[lp].FSlList.Insert(Fields.Fields[lp].CurPos, '');
  end;
  FBof := false;
  FEof := false;
end;

procedure THjhMemoryDataSet.Delete;
var
  lp: integer;
begin
  if RecordCount < 1 then exit;
  for lp := 0 to Fields.Count - 1 do
  begin
    Fields.Fields[lp].FSlList.Delete(Fields.Fields[lp].CurPos);
    if Fields.Fields[lp].CurPos > Fields.Fields[lp].FSlList.Count - 1 then
      Fields.Fields[lp].CurPos := Fields.Fields[lp].CurPos - 1;
    if Fields.Fields[lp].FSlList.Count = 0 then Fields.Fields[lp].CurPos := -1;
  end;

  if Fields.Count > 0 then
  if Fields.Fields[0].CurPos < 1 then
    FBof := true;
  if (Fields.Fields[0].CurPos < 1)and(RecordCount < 1) then
    FEof := true;
  if Fields.Count > 0 then
  if Fields.Fields[0].CurPos >= Fields.Count - 1 then
    FEof := true;
end;

procedure THjhMemoryDataSet.Clear;
begin
  FBof := true;
  FEof := true;
  CurRecordPos := -1;
  Fields.Clear;
  ClearData;
end;

constructor THjhMemoryDataSet.Create(AOwer: TComponent);
begin

  inherited Create(AOwer);
  FBlobToBase64 :=  false;
  //{$ifdef XE10}
  //NeedSingleQuotes := true; //2018-02-26 add
  //{$ELSE}
  NeedSingleQuotes := false; //2018-02-26 add
  //{$ENDIF}
  FFields := TMFields.Create(AOwer);
  FFields.FParentMds := Self;
  FHint := '';
  FDataString := '';
  FBof := true;
  FEof := true;
  FNeedProcessBlob := true;
  FNeedSQLScript := false;
  FDataSet := nil;
  FTmpSL := TStringList.Create;
end;

destructor THjhMemoryDataSet.Destroy;
begin
  if not Assigned(Self) then exit;
  FFields.Clear;
  FFields.Free;
  if Assigned(FSl) then
    FSl.Free;
  if Assigned(SQLScriptSl) then
    SQLScriptSl.Free;
  FTmpSL.Free;
  inherited;
end;

function THjhMemoryDataSet.FieldByName(const FieldName: string): TMField;
begin
  Result := FindField(FieldName);
  if Result = nil then raise Exception.Create(Name + '不存在的字段名['+FieldName+']');
end;

function THjhMemoryDataSet.FindField(const FieldName: string): TMField;
begin
  Result := FFields.FindField(FieldName);
end;

function THjhMemoryDataSet.GetRecordCount: integer;
begin
  Result := -1;
  if FFields.Count < 1 then exit;
  //hjh mod Result := TMField(FFields.FList.Items[0]).FSlList.Count;
  Result := TMField(FFields.FList[0]).FSlList.Count;
end;

procedure THjhMemoryDataSet.First;
var
  lp: integer;
begin
  if RecordCount < 1 then
  begin
    FBof := true;
    FEof := true;
    exit;
  end;
  for lp := 0 to FFields.Count - 1 do
    FFields.Fields[lp].CurPos := 0;

  if RecordCount < 1 then
  begin
    FBof := true;
    FEof := true;
  end else
  begin
    FBof := false;
    FEof := false;
  end;
end;

procedure THjhMemoryDataSet.Last;
var
  lp: integer;
begin
  if RecordCount < 1 then exit;
  for lp := 0 to FFields.Count - 1 do
    FFields.Fields[lp].CurPos := FFields.Fields[lp].FSlList.Count - 1;

  if RecordCount < 1 then
  begin
    FBof := true;
    FEof := true;
  end else
  begin
    FBof := false;
    FEof := false;
  end;  
end;

procedure THjhMemoryDataSet.Next;
var
  lp: integer;
begin
  if RecordCount < 1 then
  begin
    FEof := true;
    exit;
  end;

  FBof := false;
  if Fields.Fields[0].CurPos = FFields.Fields[0].FSlList.Count - 1 then
    FEof := true;

  for lp := 0 to FFields.Count - 1 do
  begin
    FFields.Fields[lp].CurPos := FFields.Fields[lp].CurPos + 1;
    if FFields.Fields[lp].CurPos > FFields.Fields[lp].FSlList.Count - 1 then
      FFields.Fields[lp].CurPos := FFields.Fields[lp].FSlList.Count - 1;
  end;
end;

procedure THjhMemoryDataSet.Prior;
var
  lp: integer;
begin
  if RecordCount < 1 then exit;
  if Fields.Count > 0 then
  FEof := false;
  if Fields.Fields[0].CurPos = 0 then
    FBof := true;

  for lp := 0 to FFields.Count - 1 do
  begin
    FFields.Fields[lp].CurPos := FFields.Fields[lp].CurPos - 1;
    if FFields.Fields[lp].CurPos < 0 then FFields.Fields[lp].CurPos := 0;
  end;
end;

function THjhMemoryDataSet.GetItems(index: integer): TMFields;
var
  lp: integer;
begin
  Result := FFields;
  for lp := 0 to Result.Count - 1 do
    TMField(Result.Fields[lp]).CurPos := index;
end;

function THjhMemoryDataSet.GetCurRecordPos: integer;
begin
  Result := -1;
  if FFields.Count < 1 then exit;
  Result := FFields.Fields[0].CurPos;
end;

procedure THjhMemoryDataSet.SetCurRecordPos(const Value: integer);
var
  lp: integer;
begin
  for lp := 0 to FFields.Count - 1 do
    FFields.Fields[lp].CurPos := Value;
end;

procedure THjhMemoryDataSet.Delete(Pos: integer);
begin
  CurRecordPos := Pos;
  Delete;
end;

procedure THjhMemoryDataSet.Insert(Pos: integer);
begin
  CurRecordPos := Pos;
  Insert;
end;

procedure THjhMemoryDataSet.Go(const Pos: integer);
begin
  CurRecordPos := Pos;
end;

procedure THjhMemoryDataSet.S(const FieldName, Value: string);
var
  Field: TMField;
begin
  Field := FindField(FieldName);
  if Field <> nil then Field.AsString := Value;
end;

procedure THjhMemoryDataSet.Save;
var
  pt: PTypeInfo;
  function RepaceType(FieldType: TMFieldType):string;
  begin
    Result := '';
    pt := TypeInfo(TMFieldType);
    Result := GetEnumName(pt, Ord(FieldType));
    {case FieldType of
      mftUnknown:    Result := 'mftUnknown';
      mftString:     Result := 'mftString';
      mftInteger:    Result := 'mftInteger';
      mftBoolean:    Result := 'mftBoolean';
      mftFloat:      Result := 'mftFloat';
      mftCurrency:   Result := 'mftCurrency';
      mftDate:       Result := 'mftDate';
      mftTime:       Result := 'mftTime';
      mftDateTime:   Result := 'mftDateTime';
      mftBytes:      Result := 'mftBytes';
      mftBlob:       Result := 'mftBlob';
      mftWideString: Result := 'mftWideString';
      mftVariant:    Result := 'mftVariant';
    end;}
  end;
  procedure MySaveField;
  var
    i: integer;
    tmpStr: string;
  begin
    tmpStr := '';
    for i := 0 to FFields.Count - 1 do
      tmpStr := tmpStr + #2 + FFields.Fields[i].FieldName + #2 +
         RepaceType(FFields.Fields[i].DataType);
    if Length(tmpStr) > 1 then
    System.Delete(tmpStr,1,1);
    FSl.Add(tmpStr);
  end;
  procedure MySaveData;
  var
    i, k: integer;
    SL, SL2: TStringList;
  begin
    SL := TStringList.Create;
    try
      SL2 := TStringList.Create;
      try
        for i := 0 to RecordCount - 1 do
        begin
          SL.Clear;
          for k := 0 to FFields.Count - 1 do
          begin
            SL2.Text := Items[i].Fields[k].AsString;
            SL.Add(SL2.CommaText);
          end;
          FSl.Add(SL.CommaText);
        end;
      finally
        SL2.Free;
      end;                    
    finally
      SL.Free;
    end;
  end;
begin
  if not Assigned(FSl) then FSl := TStringList.Create
  else FSl.Clear;
  MySaveField;
  MySaveData;
end;

procedure THjhMemoryDataSet.Load;
var
  TmpSl: TStringList;
  function RepaceType(FieldType: string): TMFieldType;
  var
    pt: PTypeInfo;
    p: PTypeData;
    I: integer;
  begin
    Result := ftString;
    pt := TypeInfo(TMFieldType);
    FieldType := trim(FieldType);
    Result := ftString;
    p := GetTypeData(TypeInfo(TMFieldType));
    for I := p.MinValue to p.MaxValue do
    if LowerCase(GetEnumName(pt,I)) = LowerCase(trim(FieldType)) then
    begin
      Result := TMFieldType(I);
      break;
    end;
    { //2022-05-11 add
    if FieldType = 'mftUnknown' then   Result := mftUnknown else
    if FieldType = 'mftString'  then   Result := mftString else
    if FieldType = 'mftInteger' then   Result := mftInteger else
    if FieldType = 'mftBoolean' then   Result := mftBoolean else
    if FieldType = 'mftFloat'   then   Result := mftFloat else
    if FieldType = 'mftCurrency'then   Result := mftCurrency else
    if FieldType = 'mftDate'    then   Result := mftDate else
    if FieldType = 'mftTime'    then   Result := mftTime else
    if FieldType = 'mftDateTime'then   Result := mftDateTime else
    if FieldType = 'mftBytes'   then   Result := mftBytes else
    if FieldType = 'mftBlob'    then   Result := mftBlob else
    if FieldType = 'mftWideString' then Result := mftWideString else
    if FieldType = 'mftVariant'    then Result := mftVariant else
    Result := mftString;}
  end;
  procedure MyLoadField;
  var
    TmpStr, Oth: string;
    i: integer;
  begin
    TmpStr := FSl[0];
    TmpStr := trim(TmpStr);
    if TmpStr = '' then exit;
    for i := 1 to length(TmpStr) do
      if TmpStr[i] = #2 then TmpStr[i] := #13;
    TmpSl.Text := TmpStr;
    FFields.Clear;

    for i := 0 to TmpSl.Count div 2 - 1 do
    begin
      if Pos(',' + TmpSl[2*i] + ',', Oth) < 1 then //2022-05-07 add  过滤
        FFields.Add(TmpSl[2*i], RepaceType(TmpSl[2*i + 1]));

      Oth := Oth + ',' + TmpSl[2*i] + ','; //2022-05-07 add  过滤
    end;
  end;
  procedure MyLoadData;
  var
    i, j: integer;
    TmpSl2: TStringlist;
  begin
    TmpSl2 := TStringlist.Create;
    try
      for i := 1 to FSl.Count - 1 do
      begin
        TmpSl.Clear;
        TmpSl.CommaText := FSl[i];
        Append;
        //2022-05-17 mod for j := 0 to TmpSl.Count - 1 do
        for j := 0 to FFields.Count - 1 do
        begin
          try
            TmpSl2.CommaText := TmpSl[j];
            //2017-11-09 mod FieldByName(FFields.Fields[j].FieldName).SetStringValue(TmpSl2.Text);
            FieldByName(FFields.Fields[j].FieldName).SetStringValue(trim(TmpSl2.Text));

          except
          end;
        end;
      end;
    finally
      TmpSl2.Free;
    end;
  end;
begin
  //{$ifdef XE10}
  //NeedSingleQuotes := true; //2018-02-26 add
  //{$ELSE}
  NeedSingleQuotes := false; //2018-02-26 add
  //{$ENDIF}
  if (not Assigned(FSl)) or (FSl.Count < 1) then exit;
  TmpSl := TStringList.Create;
  try
    MyLoadField;
    MyLoadData;
  finally
    TmpSl.Free;
  end;
end;

procedure THjhMemoryDataSet.SaveBlob(Stream: TStream);
var
  Info: PInfo;
  lp, Size: integer;
  procedure SaveOneColBlob;
  var
    i: integer;
    Ms: TMemoryStream;
  begin
    Size := SizeOf(TInfo);
    Info^.FieldName := FFields.Fields[lp].FieldName;
    for i := 0 to RecordCount - 1 do
    begin
      if trim(Items[i].FieldByName(Info^.FieldName).AsString) <> '' then
      begin
        Info^.RecordNo := i;
        Ms := TMemoryStream(Items[i].FieldByName(Info^.FieldName).AsInteger);
        Info^.Size := Ms.Size;
        Stream.WriteBuffer(Info^, Size);
        Ms.Position := 0;
        
        //2010-02-02 mod Stream.CopyFrom(Ms, Info^.Size);
        Stream.WriteBuffer(Ms.Memory^, Info^.Size);
      end;
    end;
  end;
begin
  New(Info);
  try
    for lp := 0 to FFields.Count - 1 do
    begin
      if FFields.Fields[lp].DataType = ftBlob then
      begin
        SaveOneColBlob;
      end;
    end;
  finally
    Dispose(PInfo(Info));
  end;
end;

procedure THjhMemoryDataSet.SaveSQLScript(Stream: TStream);
var
  SQLInfo: PSQLInfo;
  Size: integer;
  MemoryStream: TMemoryStream;
begin
  New(SQLInfo);
  try
    Size := SizeOf(TSQLInfo);
    SQLInfo^.TableName := '';
    SQLInfo^.Size := 0;
    if not (FNeedSQLScript and Assigned(SQLScriptSl)) then
    begin
      Stream.WriteBuffer(SQLInfo^, Size);
    end else
    begin
      SQLInfo^.TableName := FTableName;
      MemoryStream := TMemoryStream.Create;
      try
        SQLScriptSl.SaveToStream(MemoryStream);
        SQLInfo^.Size := MemoryStream.Size;
        SQLInfo^.TableName := FTableName;
        Stream.WriteBuffer(SQLInfo^, Size);
        MemoryStream.Position := 0;
        Stream.CopyFrom(MemoryStream, SQLInfo^.Size);
      finally
        MemoryStream.Free;
      end;
    end;
  finally
    Dispose(PSQLInfo(SQLInfo));
  end;
end;

function THjhMemoryDataSet.SaveToFile(const FileName: string; var ErrStr: string): boolean;
var
  FileStream: TFileStream;
  MemoryStream: TMemoryStream;
  aSize: integer;
begin
  //if Encoding = nil then Encoding := TEncoding.UTF8; //2020-08-23 add
  Result := false;
  try
    Save;
    if not FNeedProcessBlob then
      FSl.SaveToFile(FileName, TEncoding.UTF8)
    else begin
      FileStream := TFileStream.Create(FileName, fmCreate);
      try
        MemoryStream := TMemoryStream.Create;
        try
          FSl.SaveToStream(MemoryStream, TEncoding.UTF8);
          aSize := MemoryStream.Size;
          FileStream.Write(aSize, SizeOf(aSize));
          MemoryStream.Position := 0;
          FileStream.CopyFrom(MemoryStream, aSize);
          SaveSQLScript(FileStream);
          if not BlobToBase64 then
            SaveBlob(FileStream);
        finally
          MemoryStream.Free;
        end;
      finally
        FileStream.Free;
      end;
    end;
  except
    on e: exception do
    begin
      ErrStr := e.Message;
      exit;
    end;
  end;
  Result := true;
end;

function THjhMemoryDataSet.SaveToStream(Stream: TStream; var ErrStr: string): boolean;
var
  MemoryStream: TMemoryStream;
  aSize: integer;
begin
  Result := false;
  try
    Save;
    if not FNeedProcessBlob then
      FSl.SaveToStream(Stream)
    else
    begin
      MemoryStream := TMemoryStream.Create;
      try
        FSl.SaveToStream(MemoryStream);
        aSize := MemoryStream.Size;
        Stream.Write(aSize, SizeOf(aSize));
        MemoryStream.Position := 0;

        //2010-02-02 mod Stream.CopyFrom(MemoryStream, aSize);
        Stream.WriteBuffer(MemoryStream.Memory^, aSize);

        SaveSQLScript(Stream);
        SaveBlob(Stream);
      finally
        MemoryStream.Free;
      end;
    end;
  except
    on e: exception do
    begin
      ErrStr := e.Message;
      exit;
    end;
  end;
  Result := true;
end;

procedure THjhMemoryDataSet.LoadBlob(Stream: TStream);
var
  Info: PInfo;
  Size: integer;
  MemoryStream: TMemoryStream;
begin
  if Stream.Position >= Stream.Size then exit;
  New(Info);
  try
    Size := SizeOf(TInfo);
    while Stream.Position < Stream.Size do
    begin
      FillChar(Info^, Size, 0);
      Stream.ReadBuffer(Info^, Size);
      MemoryStream := TMemoryStream.Create;
      if Info^.Size > 0 then
      begin
        //2010-02-02 mod
        //MemoryStream.CopyFrom(Stream, Info^.Size);

        MemoryStream.Size := Info^.Size;
        Stream.ReadBuffer(MemoryStream.Memory^, Info^.Size);

        Items[Info^.RecordNo].FieldByName(Info^.FieldName).
           SetStringValue(IntToStr(LongInt(MemoryStream)));
      end;
    end;
  finally
    Dispose(PInfo(Info));
  end;
end;

procedure THjhMemoryDataSet.LoadSQLScript(Stream: TStream);
var
  SQLInfo: PSQLInfo;
  Size: integer;
  MemoryStream: TMemoryStream;
begin
  New(SQLInfo);
  try
    Size := SizeOf(TSQLInfo);
    FillChar(SQLInfo^, Size, 0);
    Stream.ReadBuffer(SQLInfo^, Size);
    FTableName := SQLInfo^.TableName;
    if SQLInfo^.Size > 0 then
    begin
      MemoryStream := TMemoryStream.Create;
      try
        MemoryStream.CopyFrom(Stream, SQLInfo^.Size);
        MemoryStream.Position := 0;
        if Assigned(SQLScriptSl) then SQLScriptSl.Clear
        else SQLScriptSl := TStringList.Create;
        SQLScriptSl.LoadFromStream(MemoryStream);
      finally
        MemoryStream.Free;
      end;
    end;  
  finally
    Dispose(PSQLInfo(SQLInfo));
  end;
end;

function THjhMemoryDataSet.LoadFromFile(const FileName: string; var ErrStr: string): boolean;
var
  FileStream: TFileStream;
  MemoryStream: TMemoryStream;
  aSize: integer;
begin
  Result := false;
  try
    if not Assigned(FSl) then FSl := TStringList.Create
      else FSl.Clear;

    if not FNeedProcessBlob then
    begin
      FSl.LoadFromFile(FileName, TEncoding.UTF8);
      Load;
    end else
    begin
      FileStream := TFileStream.Create(FileName, fmOpenRead);
      try
        FileStream.Read(aSize, SizeOf(integer));
        MemoryStream := TMemoryStream.Create;
        try
          MemoryStream.CopyFrom(FileStream, aSize);
          MemoryStream.Position := 0;
          FSl.LoadFromStream(MemoryStream);
          Load;
          LoadSQLScript(FileStream);
          LoadBlob(FileStream);
        finally
          MemoryStream.Free;
        end;
      finally
        FileStream.Free;
      end;
    end;
    First;
  except
    on e: exception do
    begin
      ErrStr := e.Message;
      exit;
    end;
  end;
  Result := true;
end;

function THjhMemoryDataSet.LoadFromStream(Stream: TStream; var ErrStr: string): boolean;
var
  MemoryStream: TMemoryStream;
  aSize: integer;
begin
  Result := false;
  try
    if not Assigned(FSl) then FSl := TStringList.Create
      else FSl.Clear;

    if not FNeedProcessBlob then
    begin
      FSl.LoadFromStream(Stream);
      Load;
    end else
    begin
      Stream.Read(aSize, SizeOf(aSize));
      MemoryStream := TMemoryStream.Create;
      try

        //2010-02-02 mod MemoryStream.CopyFrom(Stream, aSize);

        MemoryStream.Size := aSize;
        Stream.ReadBuffer(MemoryStream.Memory^, aSize);


        MemoryStream.Position := 0;
        FSl.LoadFromStream(MemoryStream);
        Load;
        LoadSQLScript(Stream);
        LoadBlob(Stream);
      finally
        MemoryStream.Free;
      end;
    end;
    First;
  except
    on e: exception do
    begin
      ErrStr := e.Message;
      exit;
    end;
  end;
  Result := true;
end;

procedure THjhMemoryDataSet.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) then
  begin
    if (AComponent = FDataSet) then
    begin
      FDataSet := nil;
    end;
  end;
end;

procedure THjhMemoryDataSet.MyAddField;
var
  i: integer;
begin
  for i := 0 to FDataSet.Fields.Count - 1 do
    FFields.Add(FDataSet.Fields.Fields[i].FieldName, FDataSet.Fields.Fields[i].DataType);
  { //2022-05-11 add
  case FDataSet.Fields.Fields[i].DataType of
    ftBlob, ftGraphic, ftBytes, ftMemo, ftOraBlob, ftOraClob: FFields.Add(
      FDataSet.Fields.Fields[i].FieldName, ftBlob);
    ftSmallint, ftInteger, ftWord: FFields.Add(FDataSet.Fields.Fields[i].FieldName,
      mftInteger);
    ftBoolean: FFields.Add(FDataSet.Fields.Fields[i].FieldName, mftBoolean);
    ftFloat, ftFMTBcd, ftLargeint, ftBCD, ftADT: FFields.Add(FDataSet.Fields.Fields[i].FieldName, mftFloat);
    ftCurrency: FFields.Add(FDataSet.Fields.Fields[i].FieldName, mftCurrency);
    ftTime: FFields.Add(FDataSet.Fields.Fields[i].FieldName, mftTime);
    ftDate: FFields.Add(FDataSet.Fields.Fields[i].FieldName, mftDate);
    ftDateTime: FFields.Add(FDataSet.Fields.Fields[i].FieldName, mftDateTime);
    else FFields.Add(FDataSet.Fields.Fields[i].FieldName);
  end;}
end;

procedure THjhMemoryDataSet.AddCurRow(MemoryStream: TMemoryStream);
var
  i: integer;
  ErrStr: string;
begin
  Append;
  for i := 0 to FFields.Count - 1 do
  begin
    case FFields.Fields[i].DataType of
      ftBoolean: FieldByName(FFields.Fields[i].FieldName).AsBoolean :=
                  FDataSet.FieldByName(FFields.Fields[i].FieldName).AsBoolean;
      ftTime: FieldByName(FFields.Fields[i].FieldName).AsTime :=
               FDataSet.FieldByName(FFields.Fields[i].FieldName).AsDateTime;
      ftDate: FieldByName(FFields.Fields[i].FieldName).AsDate :=
               FDataSet.FieldByName(FFields.Fields[i].FieldName).AsDateTime;
      ftDateTime: FieldByName(FFields.Fields[i].FieldName).AsDateTime :=
                   FDataSet.FieldByName(FFields.Fields[i].FieldName).AsDateTime;
      ftBlob:
        begin
          MemoryStream.Clear;
          TBlobField(FDataSet.FieldByName(FFields.Fields[i].FieldName)).
            SaveToStream(MemoryStream);
          if MemoryStream.Size > 0 then
            FieldByName(FFields.Fields[i].FieldName).BlobLoadFromStream(MemoryStream, ErrStr);
        end;
      else
        FieldByName(FFields.Fields[i].FieldName).AsString :=
          FDataSet.FieldByName(FFields.Fields[i].FieldName).AsString;
    end;
  end;
end;

procedure THjhMemoryDataSet.Open;
  procedure MyAddData;
  var
    MemoryStream: TMemoryStream;
  begin
    MemoryStream := TMemoryStream.Create;
    try
      FDataSet.First;
      while not FDataSet.Eof do
      begin
        AddCurRow(MemoryStream);
        FDataSet.Next;
      end;
    finally
      MemoryStream.Free;
    end;
  end;
begin
  if not Assigned(FDataSet) then raise Exception.Create('数据集不能为空');
  //if not FDataSet.Active then FDataSet.Active := true;
  FFields.Clear;
  MyAddField;
  OpenDataEx; //2008-04-09 add
end;

procedure THjhMemoryDataSet.Post;
var
  lp, i: integer;
  ErrStr: string;
  MemoryStream: TMemoryStream;
  {procedure ProcessScript;
  var
    Query1: TQuery;
  begin
    Query1 := TQuery.Create(Self);
    try
      Query1.DatabaseName := FAliasName;
      Query1.SQL.Text := 'Drop Table ' + FTableName;
      Query1.ExecSQL;
      Query1.SQL.Text := SQLScriptSl.Text;
      Query1.ExecSQL;
    finally
      Query1.Free;
    end;
  end;}
begin
  if not Assigned(FDataSet) then raise Exception.Create('数据集不能为空');
  if not FDataSet.Active then FDataSet.Active := true;
  if RecordCount < 1 then exit;
  //if NeedSQLScript then
    //ProcessScript;
  FDataSet.Close;
  FDataSet.Open;
  FDataSet.First;
  MemoryStream := TMemoryStream.Create;
  try
    while not FDataSet.Eof do
      FDataSet.Delete;
    for lp := 0 to RecordCount - 1 do
    begin
      FDataSet.Append;
      for i := 0 to FFields.Count - 1 do
      begin
        case FFields.Fields[i].DataType of
          ftBlob:
            begin
              MemoryStream.Clear;
              if (trim(Items[lp].FieldByName(FFields.Fields[i].FieldName).AsString)
                 <> '') and FNeedProcessBlob then
              begin
                Items[lp].FieldByName(FFields.Fields[i].FieldName).BlobSaveToStream(MemoryStream, ErrStr);
                TBlobField(FDataSet.FieldByName(FFields.Fields[i].FieldName)).
                   LoadFromStream(MemoryStream);
              end;
            end;
          ftBoolean: FDataSet.FieldByName(FFields.Fields[i].AsString).AsBoolean :=
                      Items[lp].FieldByName(FFields.Fields[i].AsString).AsBoolean;
          else FDataSet.FieldByName(FFields.Fields[i].FieldName).AsString :=
               Items[lp].FieldByName(FFields.Fields[i].FieldName).AsString;
        end;
      end;
      FDataSet.Post;
    end;
  finally
    MemoryStream.Free;
  end;
end;

function THjhMemoryDataSet.IsEmpty: boolean;
begin
  Result := RecordCount < 1;
end;

function THjhMemoryDataSet.GetRecords(index: integer;
  FieldName: string): Variant;
var
  aMField: TMField;
begin
  aMField := FieldByName(FieldName);
  if not Assigned(aMField) then raise Exception.Create('不存在的字段名['+FieldName+']');
  if (index < 0)or(index > aMField.FSlList.Count - 1) then raise EIndexOutBands.Create;
  Result := aMField.FSlList[index];
end;

procedure THjhMemoryDataSet.ClearData;
var
  lp: integer;
begin
  FBof := true;
  FEof := true;
  CurRecordPos := -1;
  for lp := 0 to Fields.Count - 1 do
    Fields[lp].FSlList.Text := '';
end;

procedure THjhMemoryDataSet.OpenData;
var
  i: integer;
  ErrStr: string;
  MemoryStream: TMemoryStream;
begin
  FDataSet.First;
  MemoryStream := TMemoryStream.Create;
  try
    while not FDataSet.Eof do
    begin
      Append;
      for i := 0 to FFields.Count - 1 do
      begin
        case FFields.Fields[i].DataType of
          ftBoolean: FieldByName(FFields.Fields[i].FieldName).AsBoolean :=
                      FDataSet.FieldByName(FFields.Fields[i].FieldName).AsBoolean;
          ftTime: FieldByName(FFields.Fields[i].FieldName).AsTime :=
                   FDataSet.FieldByName(FFields.Fields[i].FieldName).AsDateTime;
          ftDate: FieldByName(FFields.Fields[i].FieldName).AsDate :=
                   FDataSet.FieldByName(FFields.Fields[i].FieldName).AsDateTime;
          ftDateTime: FieldByName(FFields.Fields[i].FieldName).AsDateTime :=
                       FDataSet.FieldByName(FFields.Fields[i].FieldName).AsDateTime;
          ftBlob:
            begin
              //ShowMessage('MemoryStream');
              MemoryStream.Clear;
              TBlobField(FDataSet.FieldByName(FFields.Fields[i].FieldName)).
                SaveToStream(MemoryStream);
              if MemoryStream.Size > 0 then
                FieldByName(FFields.Fields[i].FieldName).BlobLoadFromStream(MemoryStream, ErrStr);
            end;
          else  FieldByName(FFields.Fields[i].FieldName).AsString :=
                FDataSet.FieldByName(FFields.Fields[i].FieldName).AsString;
        end;
      end;
      FDataSet.Next;
    end;
  finally
    MemoryStream.Free;
  end;
  if NeedSQLScript then
  begin
    if Assigned(SQLScriptSl) then SQLScriptSl.Clear
    else SQLScriptSl := TStringList.Create;
    SQLScriptSl.Text := GetTableSQLScript(FTableName, FAliasName);
  end;
end;

procedure THjhMemoryDataSet.OpenDataEx;
var
  ErrStr: string;
  i: integer;
  MemoryStream: TMemoryStream;
begin //2008-04-09 add
  FDataSet.First;
  MemoryStream := TMemoryStream.Create;
  try
    while not FDataSet.Eof do
    begin
      Append;
      for i := 0 to FFields.Count - 1 do
      begin
        case FFields.Fields[i].DataType of
          ftBoolean: FFields.Fields[i].AsBoolean := FDataSet.Fields[i].AsBoolean;
          ftTime: FFields.Fields[i].AsTime := FDataSet.Fields[i].AsDateTime;
          ftDate: FFields.Fields[i].AsDate := FDataSet.Fields[i].AsDateTime;
          ftDateTime: FFields.Fields[i].AsDateTime := FDataSet.Fields[i].AsDateTime;
          ftBlob:
            begin
              if FBlobToBase64 then
              begin
                MemoryStream.Clear;
                TBlobField(FDataSet.Fields[i]).SaveToStream(MemoryStream);
                if MemoryStream.Size > 0 then
                  FFields.Fields[i].AsString := PubSys.StreamToBase64(MemoryStream);
              end else
              begin
                //ShowMessage('MemoryStream');
                MemoryStream.Clear;
                TBlobField(FDataSet.Fields[i]).SaveToStream(MemoryStream);
                if MemoryStream.Size > 0 then
                  FFields.Fields[i].BlobLoadFromStream(MemoryStream, ErrStr);
              end;
            end;
          else
            FFields.Fields[i].AsString := FDataSet.Fields[i].AsString;
        end;
      end;
      FDataSet.Next;
    end;
  finally
    MemoryStream.Free;
  end;
  if NeedSQLScript then
  begin
    if Assigned(SQLScriptSl) then SQLScriptSl.Clear
    else SQLScriptSl := TStringList.Create;
    SQLScriptSl.Text := GetTableSQLScript(FTableName, FAliasName);
  end;
end;

function THjhMemoryDataSet.GetCommaText: string;
var
  lp: integer;
  pt: PTypeInfo;
begin
  Result := '';
  pt := TypeInfo(TMFieldType);
  FTmpSL.Clear;
  for lp := 0 to FFields.Count - 1 do
  begin
    //2022-05-11 mod
    //FTmpSL.Add(FFields[lp].FieldName);
    FTmpSL.Add(GetEnumName(pt, Ord(FFields[lp].DataType)) + '*' + FFields[lp].FieldName);

    //test FTmpSL.Add(FFields[lp].CommaText);
    FTmpSL.Add(FFields[lp].CommaText);
  end;
  {$ifdef XE10}
  Result := 'NeedSingleQuotes@' + FTmpSL.CommaText;
  {$ELSE}
  if NeedSingleQuotes then //2018-02-26 add
    Result := 'NeedSingleQuotes@' + FTmpSL.CommaText
  else
    Result := FTmpSL.CommaText;
  {$endif}
  FTmpSL.Clear;
end;

function THjhMemoryDataSet.GetCommaTextEx: string;
var
  lp: integer;
begin
  Result := '';
  FTmpSL.Clear;
  for lp := 0 to FFields.Count - 1 do
  begin
    FTmpSL.Add(FFields[lp].FieldName);
    //test FTmpSL.Add(FFields[lp].CommaText);
    FTmpSL.Add(FFields[lp].GetCommaTextEx);
  end;
  Result := FTmpSL.CommaText;

  FTmpSL.Clear;
end;


function GetDeliBack(Text, Delimite: string; All: boolean = true): string;
var
  Index: integer;
begin
  if All then //2013-08-21 add
    Result := Text
  else
    Result := '';
  Index := Pos(Delimite, Text);
  if Index > 0 then
    Result := Copy(Text, Index + Length(Delimite), MaxInt);
end;

function GetDeliPri(Text, Delimite: string; All: boolean = true): string;
begin
  if All then
    Result := Text
  else
    Result := '';
  if Pos(Delimite, Text) > 0 then
    Result := Copy(Text, 1, Pos(Delimite, Text) - 1);
end;

procedure THjhMemoryDataSet.SetBlobToBase64(const Value: boolean);
begin
  FBlobToBase64 := Value;
end;

procedure THjhMemoryDataSet.SetCommaText(const Value: string);
var
  lp: integer;
  FieldName, dt: string;
  pt: PTypeInfo;
  p: PTypeData;
  I: integer;
  ft: TFieldType;
begin

  Clear; //2014-01-15 add
  Fields.Clear;
  FTmpSL.Clear;
  //'NeedSingleQuotes@' + 2018-02-26 add
  if Pos('NeedSingleQuotes@', Value) = 1 then
  begin
    NeedSingleQuotes := true;
    FTmpSL.CommaText := Copy(Value, 18, MaxInt);
  end else
  begin
    NeedSingleQuotes := false; //2018-02-26 add
    FTmpSL.CommaText := Value;
  end;

  pt := TypeInfo(TMFieldType);
  p := GetTypeData(TypeInfo(TMFieldType));
  for lp := 0 to FTmpSL.Count div 2 - 1 do
  begin
    dt := GetDeliPri(FTmpSL[2 * lp], '*');
    FieldName := GetDeliBack(trim(FTmpSL[2 * lp]), '*');

    ft := ftString;
    for I := p.MinValue to p.MaxValue do
    if LowerCase(GetEnumName(pt,I)) = LowerCase(trim(dt)) then
    begin
      ft := TMFieldType(I);
      break;
    end;
    Fields.Add(FieldName, ft);
    FieldByName(FieldName)
    //Fields[Fields.Count - 1]
    .CommaText := FTmpSL[2 * lp + 1];
  end;
  First; //2014-01-16 add
end;

function THjhMemoryDataSet.GetData: OleVariant;
var
  Ms: TMemoryStream;
  ErrStr: string;
begin
  Result := EmptyParam;
  Ms := TMemoryStream.Create;
  try
    SaveToStream(Ms, ErrStr);
    Ms.Position := 0;
    Result := PubSys.StreamToVariant(Ms);
  finally
    Ms.Free;
  end;
end;

procedure THjhMemoryDataSet.SetData(const Value: OleVariant);
var
  Ms: TMemoryStream;
  ErrStr: string;
begin
  Ms := TMemoryStream.Create;
  try
    PubSys.VariantToStream(Value, Ms);
    Ms.Position := 0;
    LoadFromStream(Ms, ErrStr);
  finally
    Ms.Free;
  end;
end;

function THjhMemoryDataSet.V(const FieldName: string): string;
var
  Field: TMField;
begin
  if RecordCount = 0 then
    Result := ''
  else
  begin
    Field := FindField(FieldName);
    if Field = nil then
      Result := ''
    else
      Result := Field.AsString;
  end;
end;

procedure THjhMemoryDataSet.OpenFields;
begin
  FFields.Clear;
  MyAddField;
end;

procedure THjhMemoryDataSet.CopyOneRecord(SourMds: THjhMemoryDataset; NeedAppend: boolean);
var
  lp: integer;
  FieldName: string;
  MField: TMField;
begin
  if NeedAppend then //2023-03-17 add
    Append;
  for lp := 0 to Fields.Count - 1 do
  begin
    FieldName := Fields[lp].FieldName;
    MField := SourMds.FindField(FieldName);
    if MField <> nil then
    Fields[lp].AsString := MField.AsString;
  end;
end;

procedure THjhMemoryDataSet.SetCommaTextEx(const Value: string);
var
  lp, i: integer;
  SL: TStringlist;
begin
  Fields.Clear;
  FTmpSL.Clear;
  FTmpSL.CommaText := Value;
  SL := TStringlist.Create;
  try
    for lp := 0 to FTmpSL.Count - 1 do
    begin
      SL.CommaText := FTmpSL[lp];
      if lp = 0 then
      begin
        for i := 0 to SL.Count - 1 do
          Fields.Add(IntToStr(i));
      end;
      Append;
      for i := 0 to SL.Count - 1 do 
        FieldByName(IntToStr(i)).AsString := SL[i];
    end;
  finally
    SL.Free;
  end;
end;
 {
class function THjhMemoryDataSet.GetFileMIMEType(FileName: string): string;
begin
  if MIMEMap = nil then
    MIMEMap := TIdMimeTable.Create(True);
  Result := MIMEMap.GetFileMIMEType(FileName);
end;  }
          {
class function THjhMemoryDataSet.GetFileMIMEType_Base64Head(FileName: string): string;
begin //ImageHtml_New := 'src="data:image/' + GetPicType(LowerCase(FPicDataInfo.TmpPicType)) + ';base64,'#13#10 + FPicData;
 // Result := GetFileMIMEType(FileName) + ';base64,';
end;     }

procedure THjhMemoryDataSet.CopyOneRecord(SourCds: TDataset);
var
  lp: integer;
  FieldName: string;
  Field: TField;
begin
  Append;
  for lp := 0 to Fields.Count - 1 do
  begin
    FieldName := Fields[lp].FieldName;
    Field := SourCds.FindField(FieldName);
    if Field <> nil then
    Fields[lp].AsString := Field.AsString;
  end;
end;

procedure THjhMemoryDataSet.CopyToOneRecord(TargetCds: TDataset);
var
  lp: integer;
  FieldName: string;
  Field: TField;
begin
  if not (TargetCds.State in [dsEdit, dsInsert]) then TargetCds.Edit;
  for lp := 0 to Fields.Count - 1 do
  begin
    FieldName := Fields[lp].FieldName;
    Field := TargetCds.FindField(FieldName);
    if Field <> nil then
      Field.AsString := Fields[lp].AsString;
  end;
  //应在调用的程序中Post, 否则会有关键字唯一冲突的可能，所以不能在此Post
end;

{ TMFields }

procedure TMFields.Add(const FieldName: string; DataType: TMFieldType);
var
  aMField: TMField;
begin
  aMField := TMField.Create(FOwer);
  aMField.FieldName := FieldName;
  aMField.DataType := DataType;
  aMField.ParentFields := Self;

  FList.Add(aMField);
end;

procedure TMFields.Clear;
var
  lp: integer;
begin
  //if FParentMds.BlobToBase64 then exit;
  for lp := FList.Count - 1 downto 0 do
  begin
    if Assigned(FList.Items[lp]) then
      TMField(FList.Items[lp]).Free;
    FList.Items[lp] := nil;
  end;
  FList.Clear;
end;

constructor TMFields.Create(AOwer: TComponent);
begin
  inherited Create;
  FOwer := AOwer;
  FList := TList<TMField>.Create;
end;

destructor TMFields.Destroy;
begin
  Clear;
  FreeAndNil(FList);
  inherited;
end;

function TMFields.FieldByName(const FieldName: string): TMField;
begin
  Result := FindField(FieldName);
  if Result = nil then raise Exception.Create('不存在的字段名['+FieldName+']');
end;

function TMFields.FieldByNumber(FieldNo: Integer): TMField;
begin
  Result := FList.Items[FieldNo];
end;

function TMFields.FindField(const FieldName: string): TMField;
var
  lp: integer;
begin
  for lp := 0 to FList.Count - 1 do
  begin
    Result := TMField(FList.Items[lp]);
    if trim(UpperCase(Result.FieldName)) = Trim(UpperCase(FieldName)) then Exit;
  end;
  Result := nil;
end;

function TMFields.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TMFields.GetField(Index: Integer): TMField;
begin
  Result := nil;
  if (Index < 0)or(Index > FList.Count - 1) then exit;
  Result := Flist.Items[Index];
end;

function TMFields.GetFieldList: string;
var
  SL: TStringlist;
  lp: integer;
begin
  SL := TStringlist.Create;
  try
    SL.Clear;
    for lp := 0 to Count - 1 do
      SL.Add(Fields[lp].FieldName);
    Result := SL.CommaText;
  finally
    SL.Free;
  end;
end;

function TMFields.IndexOf(Field: TMField): Integer;
var
  lp: integer;
begin
  Result := -1;
  for lp := 0 to FList.Count - 1 do
  begin
    if TMField(FList.Items[lp]) = Field then
    begin
      Result := lp;
      break;
    end;
  end;
end;

procedure TMFields.Remove(Field: TMField);
var
  lp: integer;
begin
  for lp := 0 to FList.Count - 1 do
  begin
    if TMField(FList.Items[lp]) = Field then
    begin
      TMField(FList.Items[lp]).Free;
      FList.Delete(lp);
      break;
    end;
  end;
end;

procedure TMFields.SetField(Index: Integer; Value: TMField);
begin
  TMField(FList.Items[Index]).Free;
  FList.Items[Index] := Value;
end;

procedure TMFields.SetFieldList(const Value: string);
var
  SL: TStringlist;
  lp: integer;
  FieldName: string;
begin
  SL := TStringlist.Create;
  try
    SL.CommaText := Value;
    Clear;
    for lp := 0 to SL.Count - 1 do
    begin
      FieldName := SL[lp];
      if Pos('*', FieldName) < 1 then
        Add(FieldName)
      else
      begin
        FieldName := Copy(FieldName, 1, Pos('*', FieldName) - 1);
        Add(FieldName, ftFloat);
      end;
    end;
  finally
    SL.Free;
  end;
end;

procedure TMFields.Delete(FieldName: string);
var
  MField: TMField;
begin
  MField := FindField(FieldName);
  Remove(MField);
  //FList.Delete(FList.IndexOf(MField));
  //MField.Free;
end;

{ TMField }

procedure TMField.Clear;
var
  lp: integer;
  MemoryStream: TMemoryStream;
begin
  if not Assigned(FSlList) then exit;
  for lp := FSlList.Count - 1 downto 0 do
  begin
    if (DataType = ftBlob) and (Trim(FSlList[lp]) <> '') then
    begin
      try
        MemoryStream := TMemoryStream(StrToInt(Trim(FSlList[lp])));
        if Assigned(MemoryStream) then
        begin
          MemoryStream.Free;
        end;
      except
      end;
    end;
    FSlList.Delete(lp);
  end;
  FSlList.Clear;
end;

constructor TMField.Create(AOwer: TComponent);
begin
  inherited Create(nil);
  FSlList := TStringList.Create;
  FTmpSL := TStringList.Create; //2018-03-30 add
  FCurPos := 0;
  //2008-03-31 ADD
  Tag := Longint(FSlList);
end;

destructor TMField.Destroy;
begin
  Clear;
  try
    FTmpSL.Free;
    if Assigned(FSlList) then
      FreeAndNil(FSlList);
  except
  end;
  inherited;
end;

function TMField.GetAsBoolean: Boolean;
begin
  Result := GetStringValue = '1';
end;

function TMField.GetAsCurrency: Currency;
begin
  Result := StrToFloat(GetStringValue);
end;

function TMField.GetAsDateTime: TDateTime;
begin
  Result := StrToDateTime(GetStringValue);
end;

function TMField.GetAsFloat: Double;
begin
  Result := StrToFloat(GetStringValue);
end;

function TMField.GetAsInteger: Longint;
begin
  Result := StrToInt(GetStringValue);
end;

function TMField.GetAsString: string;
begin
  Result := GetStringValue;
end;

function TMField.AsStringEx(Row: integer): string;
begin
  Result := GetStringValueEx(Row);
end;

function TMField.GetAsVariant: Variant;
begin
  Result := GetStringValue;
end;

function TMField.GetFieldNo: Integer;
var
  lp: integer;
begin
  Result := -1;
  for lp := 0 to ParentFields.Count - 1 do
  begin
    if ParentFields.Fields[lp] = Self then
    begin
      Result := lp;
      break;
    end;
  end;
end;

function TMField.GetIsNull: Boolean;
begin
  Result := false;
  if FMDataType in [ftString, ftWideString, ftUnknown] then exit;
  if (CurPos < 0)or(CurPos > FSlList.Count - 1) then raise EIndexOutBands.Create;
  Result := FSlList[CurPos] = '';
end;

function TMField.GetStringValueEx(CurPos: integer): string;
begin
  Result := '';
  if (CurPos = 0) and (FSlList.Count = 0) then
  begin
    Result := '';
    exit;
  end else
    if (CurPos < 0)or(CurPos > FSlList.Count - 1) then raise EIndexOutBands.Create;

  //{$IFDEF XE10}
  //Result := trim(FSlList[CurPos]);
  //{$else}
  if ParentFields.FParentMds.NeedSingleQuotes then  //2018-02-26 add
    Result := trim(AnsiDequotedStr(trim(FSlList[CurPos]), ''''))
  else
    Result := trim(FSlList[CurPos]);
  //{$endif}
end;

function TMField.GetStringValue: string;
begin
  Result := '';
  if (CurPos = 0) and (FSlList.Count = 0) then
  begin
    Result := '';
    exit;
  end else
    if (CurPos < 0)or(CurPos > FSlList.Count - 1) then raise EIndexOutBands.Create;

  //{$IFDEF XE10}
  //Result := trim(FSlList[CurPos]);
  //{$else}
  if ParentFields.FParentMds.NeedSingleQuotes then  //2018-02-26 add
    Result := trim(AnsiDequotedStr(trim(FSlList[CurPos]), ''''))
  else
    Result := trim(FSlList[CurPos]);
  //{$endif}
end;

function TMField.GetAsDate: TDate;
begin
  if (CurPos < 0)or(CurPos > FSlList.Count - 1) then raise EIndexOutBands.Create;
  Result := StrToDate(FSlList[CurPos]);
end;

function TMField.GetAsTime: TTime;
begin
  if (CurPos < 0)or(CurPos > FSlList.Count - 1) then raise EIndexOutBands.Create;
  Result := StrToTime(FSlList[CurPos]);
end;

procedure TMField.SetStringValue(Value: string);
begin
  if (CurPos < 0)or(CurPos > FSlList.Count - 1) then raise EIndexOutBands.Create;
  {$IFDEF XE10}
  FSlList[CurPos] := Value;
  {$ELSE}
  if ParentFields.FParentMds.NeedSingleQuotes {$IFDEF XE10} or false{$endif} then  //2018-02-26 add
    FSlList[CurPos] := QuotedStr(Value)
  else
    FSlList[CurPos] := Value;
  {$ENDIF}
end;

procedure TMField.SetAsBoolean(const Value: Boolean);
begin
  if DataType = ftBlob then raise EBlobError.Create;
  if Value then
    SetStringValue('1')
  else
    SetStringValue('0');
end;

procedure TMField.SetAsCurrency(const Value: Currency);
begin
  if DataType = ftBlob then raise EBlobError.Create;
  SetStringValue(FloatToStr(Value));
end;

procedure TMField.SetAsDateTime(const Value: TDateTime);
begin
  if DataType = ftBlob then raise EBlobError.Create;
  SetStringValue(DateTimeToStr(Value));
end;

procedure TMField.SetAsFloat(const Value: Double);
begin
  if DataType = ftBlob then raise EBlobError.Create;
  SetStringValue(FloatToStr(Value));
end;

procedure TMField.SetAsInteger(const Value: Longint);
begin
  if DataType = ftBlob then raise EBlobError.Create;
  SetStringValue(IntToStr(Value));
end;

procedure TMField.SetAsString(const Value: string);
begin
  //if DataType = ftBlob then raise EBlobError.Create;
  SetStringValue(Value);
end;

procedure TMField.SetAsVariant(const Value: Variant);
begin
  //if DataType = ftBlob then raise EBlobError.Create;
  SetStringValue(Value);
end;

procedure TMField.SetAsDate(const Value: TDate);
begin
  if DataType = ftBlob then raise EBlobError.Create;
  SetStringValue(DateToStr(Value));
end;

procedure TMField.SetAsDTime(const Value: TTime);
begin
  if DataType = ftBlob then raise EBlobError.Create;
  SetStringValue(TimeToStr(Value));
end;

function TMField.BlobLoadFromFile(const FileName: string; var ErrStr: string): boolean;
var
  Memory: TMemoryStream;
begin
  Result := false;
  try
    if DataType <> ftBlob then raise ENotBlobError.Create;
    if (CurPos < 0)or(CurPos > FSlList.Count - 1) then raise EIndexOutBands.Create;
    if ParentFields.FParentMds.BlobToBase64 then
    begin
      if not BlobLoadFromFile_ToBase64(FileName, ErrStr) then exit;
    end else
    begin
      Memory := TMemoryStream.Create;
      Memory.LoadFromFile(FileName);
      SetStringValue(IntToStr(LongInt(Memory)));
    end;
  except
    on e: exception do
    begin
      ErrStr := e.Message;
      exit;
    end;
  end;
  Result := true;
end;

function TMField.BlobLoadFromFile_ToBase64(const FileName: string; var ErrStr: string): boolean;
var
  Memory: TMemoryStream;
begin //2022-05-12 add
  Result := false;
  try
    if DataType <> ftBlob then raise ENotBlobError.Create;
    if (CurPos < 0)or(CurPos > FSlList.Count - 1) then raise EIndexOutBands.Create;
    SetStringValue(PubSys.FileToBase64(FileName));
  except
    on e: exception do
    begin
      ErrStr := e.Message;
      exit;
    end;
  end;

  Result := true;
end;


function TMField.BlobLoadFromStream(Stream: TMemoryStream; var ErrStr: string): boolean;
var
  Memory: TMemoryStream;
begin
  Result := false;
  try
    if DataType <> ftBlob then raise ENotBlobError.Create;
    if (CurPos < 0)or(CurPos > FSlList.Count - 1) then raise EIndexOutBands.Create;

    if ParentFields.FParentMds.BlobToBase64 then
    begin
      if not BlobLoadFromStream_ToBase64(Stream, ErrStr) then exit;
    end else
    begin
      Memory := TMemoryStream.Create;
      Stream.Position := 0;
      Memory.LoadFromStream(Stream);
      SetStringValue(IntToStr(LongInt(Memory)));
    end;
  except
    on e: exception do
    begin
      ErrStr := e.Message;
      exit;
    end;
  end;
  Result := true;
end;

function TMField.BlobLoadFromStream_ToBase64(Stream: TMemoryStream; var ErrStr: string): boolean;
begin
  Result := false;
  try
    if DataType <> ftBlob then raise ENotBlobError.Create;
    if (CurPos < 0)or(CurPos > FSlList.Count - 1) then raise EIndexOutBands.Create;

    SetStringValue(PubSys.StreamToBase64(Stream));
  except
    on e: exception do
    begin
      ErrStr := e.Message;
      exit;
    end;
  end;
  Result := true;
end;

function TMField.BlobSaveToFile(const FileName: string; var ErrStr: string): boolean;
begin
  Result := false;
  try
    if DataType <> ftBlob then raise ENotBlobError.Create;
    if (CurPos < 0)or(CurPos > FSlList.Count - 1) then raise EIndexOutBands.Create;
    if not ParentFields.FParentMds.BlobToBase64 then
      TMemoryStream(StrToInt(AsString)).SaveToFile(FileName)
    else
    begin //2022-05-12 add
      if trim(AsString) <> '' then
        PubSys.Base64ToFile(AsString, FileName);
    end;
  except
    on e: exception do
    begin
      ErrStr := e.Message;
      exit;
    end;
  end;
  Result := true;
end;

function TMField.BlobSaveToStream(Stream: TStream; var ErrStr: string): boolean;
begin
  if DataType <> ftBlob then raise ENotBlobError.Create;
  if (CurPos < 0)or(CurPos > FSlList.Count - 1) then raise EIndexOutBands.Create;
  if not ParentFields.FParentMds.BlobToBase64 then
    TMemoryStream(StrToInt(AsString)).SaveToStream(Stream)
  else
  begin
    PubSys.Base64ToStream(AsString, Stream);
  end;
  Result := true;
end;

function TMField.GetCommaText: string;
var
  lp: integer;
begin
  {$IFDEF XE10}
  FTmpSL.CommaText := FSlList.CommaText;
  for lp := 0 to FTmpSL.Count - 1 do
  if FTmpSL[lp] = '' then
    FTmpSL[lp] := QuotedStr(' ')
  else
    FTmpSL[lp] := QuotedStr(FTmpSL[lp]);
  Result := FTmpSL.CommaText;
  {$else}
  Result := FSlList.CommaText;
  {$ENDIF}
end;

function TMField.GetCommaTextEx: string;
begin
  Result := FSlList.CommaText;
end;


procedure TMField.SetCommaText(const Value: string);
begin
  FSlList.CommaText := Value;
end;

function TMField.IndexOf(Value: string): integer;
begin
  Result := FSlList.IndexOf(Value);
end;

function TMField.GetText: string;
begin
  Result := FSlList.Text;
end;

procedure TMField.SetText(const Value: string);
begin
  FSlList.Text := Value;
end;

{ EIndexOutBands }

constructor EIndexOutBands.Create();
begin
  inherited Create('下标值越界，请检查');
end;

{ ENotBlobError }

constructor ENotBlobError.Create;
begin
  inherited Create('非Bolob数据类型字段,不能进行该操作');
end;

{ EBlobError }

constructor EBlobError.Create;
begin
  inherited Create('Bolob数据类型字段,不能进行该操作');
end;

initialization
 // MIMEMap := nil;
finalization
 // if MIMEMap <> nil then MIMEMap.Free;

end.
{$endif}

