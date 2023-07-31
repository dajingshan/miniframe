unit minipub;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  Classes, SysUtils, syncobjs{$IFDEF FPC}, FileUtil{$endif}, VirtualTable,
  mormot.core.base, mormot.core.data, mormot.core.variants, mormot.core.text,
  DataPackageUnit, PubStringUnit, PubPWDUnit, DB, TypInfo, minidb, PubSysUnit,
  minijson2dataset;


type
  TMiniCriticalSection = TCriticalSection;
  function GetDeliBack(Text, Delimite: String; All: Boolean = true): String;
  function GetDeliPri(Text, Delimite: String): String;
  function PathWithoutSlash(const Path: string): string;
  function PathWithSlash(const Path: string): string;
  function FileGetFileTime(FileName: string): TDatetime;
  //所json加载到mds中
  function DBMemory_LoadJson(mds: THjhMemoryDataSet; FromPath: string): string;
  function DBMemory_MxSave(mds: THjhMemoryDataSet; ToPath, Fields_info: string): string;
  function DBMemory_Save(Content, ToPath, Fields_info: string): string;
  function DBMemory_Load(mds: THjhMemoryDataSet; FromPath, Fields_info: string): string;

  //内存表解密
  function Decrypt(mds: THjhMemoryDataSet; Fields_info: string): string;
  //数据库表解密
  function Decrypt_ds(mds: TminiQuery; Fields_info: string): string;

threadvar flastError: string;

implementation

uses minihttp;

function FileGetFileTime(FileName: string): TDatetime;
begin
  Result := FileDateToDateTime(FileAge(FileName));
end;

function PathWithoutSlash(const Path: string): string;
begin
  if (Length(Path) > 0) and (Path[Length(Path)] = '\') then Result := Copy(Path, 1, Length(Path) - 1)
  else Result := Path;
end;

function PathWithSlash(const Path: string): string;
begin
  Result := Path;
  if (Length(Result) > 0) and (Result[Length(Result)] <> '\') then Result := Result + '\';
end;

function GetDeliBack(Text, Delimite: String; All: Boolean = true): String;
var
  Index: integer;
begin
  Result := Text;
  Index := Pos(Delimite, Text);
  if Index > 0 then
    Result := Copy(Text, Index + Length(Delimite), MaxInt);
end;

function GetDeliPri(Text, Delimite: String): String;
begin
  Result := Text;
  if Pos(Delimite, Text) > 0 then
    Result := Copy(Text, 1, Pos(Delimite, Text) - 1);
end;

function IsToEncrypt(F: string): boolean;
begin
  F := PubString.GetDeliBack(F, '@9#');
  F := PubString.GetDeliPri(F, '@10#');
  Result := '1' = F;
end;

function GetRField(F: string): string;
begin
  Result := PubString.GetDeliPri(F, '=');
  Result := PubString.GetDeliBack(Result, '*');
end;

function DBMemory_SaveJson(SL: TStringList; Content, ToPath, Fields_info: string): string;
var
  lp: Integer;
  Doc, dataArray: TDocVariantData;
  v1, Data: variant;
  SLFields: TStringlist;
begin
  Doc.Init;
  Doc.I['recordcount'] := 1;
  SLFields := TStringlist.Create;
  try
    SLFields.CommaText := Fields_info;
    for lp := SLFields.Count - 1 downto 0 do
    if not IsToEncrypt(SLFields[lp]) then
      SLFields.Delete(lp)
    else
      SLFields[lp] := GetRField(SLFields[lp]);

    //mds.S(SL[lp], PubPWD.GetPWD(s, '#'));

    dataArray.Init;
    for lp := 0 to SL.Count - 1 do
    if SL.Names[lp] <> 'fnew_data' then
    begin
      if SLFields.IndexOf(SL.Names[lp]) > -1 then
        dataArray.S[SL.Names[lp]] := PubPWD.SetPWD(SL.Values[SL.Names[lp]], '#')
      else
        dataArray.S[SL.Names[lp]] := SL.Values[SL.Names[lp]];
    end;

    TDocVariantData(Data).InitJSON(dataArray.ToJSON());
    doc.A_['data']^.AddItem(Data);

    //类型
    VarClear(data);
    dataArray.Clear;
    for lp := 0 to SL.Count - 1 do
    if SL.Names[lp] <> 'fnew_data' then
      dataArray.S[SL.Names[lp]] := 'ftstring';
    TDocVariantData(Data).InitJSON(dataArray.ToJSON());
    doc.Value['types'] := data;

    SL.Clear;
    //SL.Text := UTF8ToWideString(doc.ToJSON);
    SL.Text := doc.ToJson('', '', jsonHumanReadable);//jsonEscapeUnicode); //jsonHumanReadable
    {ToJSON('', '', jsonEscapeUnicode)}
    try
      //SL.SaveToFile(ToPath, TEncoding.UTF8);
      ForceDirectories(ExtractFilePath(ToPath));
      SL.SaveToFile(ToPath, TEncoding.UTF8);
    except
      on e: exception do
        Result := e.Message;
    end;
  finally
    dataArray.Clear;
    doc.Clear;
    VarClear(data);
    SLFields.Free;
    //FreeAndNil(doc);
    //FreeAndNil(doc);
  end;
end;

(*  dataset to json

SynCommons, SynDB, SynOleDB;

procedure TForm1.DataToJsonClick(Sender: TObject);
var
  Conn: TOleDBMSSQLConnectionProperties;
  strSql: string;
  rows: ISQLDBRows;
  strStream: TStringStream;
begin
  Conn := TOleDBMSSQLConnectionProperties.Create('127.0.0.1', 'Northwind', 'sa', 'Sa123');
  strSql := 'SELECT EmployeeID,LastName,FirstName,Title FROM Employees';
  strStream:=TStringStream.Create('',TEncoding.UTF8);
  try
    rows := Conn.ExecuteInlined(strSql, True);
    rows.FetchAllToJSON(strStream, True);
    Memo1.Text := strStream.DataString;
  finally
    strStream.Free;
  end;
end;
*)
function DBMemory_Save(Content, ToPath, Fields_info: string): string;
var
  SL: TStringList;
  mds: THjhMemoryDataSet;
  lp: integer;
begin
  Result := '';
  SL := TStringList.Create;
  try
    SL.CommaText := Content;
    if SameText(ExtractFileExt(ToPath), '.json') then
      Result := DBMemory_SaveJson(SL, Content, ToPath, Fields_info)
    else
    begin
      mds := THjhMemoryDataSet.Create(nil);
      try
        for lp := 0 to SL.Count - 1 do
          mds.Fields.Add(SL.Names[lp]);
        mds.Append;
        for lp := 0 to SL.Count - 1 do
        try
          mds.FieldByName(SL.Names[lp]).AsString := SL.Values[SL.Names[lp]];
        except
        end;
        try
          ForceDirectories(ExtractFilePath(ToPath));
          Decrypt(mds, Fields_info);
          if not mds.SaveToFile(ToPath, Result) then exit;
        except
          on e: exception do
          begin
            Result := e.Message;
            exit;
          end;
        end;
      finally
        mds.Free;
      end;
    end;
  finally
    SL.Free;
  end;
end;

function Decrypt(mds: THjhMemoryDataSet; Fields_info: string): string;
var
  SL: TStringlist;
  lp: Integer;
  s: string;
begin //解密由系统加密的数据
  SL := TStringlist.Create;
  try
    SL.CommaText := Fields_info;
    for lp := SL.Count - 1 downto 0 do
    if not IsToEncrypt(SL[lp]) then
      SL.Delete(lp)
    else
      SL[lp] := GetRField(SL[lp]);

    if SL.Count < 1 then exit;

    mds.First;
    while not mds.Eof do
    begin
      for lp := 0 to SL.Count - 1 do
      try
        s := mds.V(SL[lp]);
        if s <> '' then
          mds.S(SL[lp], PubPWD.GetPWD(s, '#'));
      except
      end;
      mds.Next;
    end;
  finally
    SL.Free;
  end;
end;

function Decrypt_ds(mds: TminiQuery; Fields_info: string): string;
var
  SL: TStringlist;
  lp: Integer;
  s: string;
begin //解密由系统加密的数据
  Result := '';
  try
    SL := TStringlist.Create;
    try
      SL.CommaText := Fields_info;
      for lp := SL.Count - 1 downto 0 do
      if not IsToEncrypt(SL[lp]) then
        SL.Delete(lp)
      else
        SL[lp] := GetRField(SL[lp]);

      if SL.Count < 1 then exit;

      mds.First;
      while not mds.Eof do
      begin
        mds.Edit;
        for lp := 0 to SL.Count - 1 do
        try
          s := mds.V(SL[lp]);
          if s <> '' then
            mds.S(SL[lp], PubPWD.GetPWD(s, '#'));
        except
        end;
        mds.Post;
        mds.Next;
      end;
    finally
      SL.Free;
    end;
  except
    on e: exception do
      Result := e.Message;
  end;
end;

function DBMemory_LoadJson(mds: THjhMemoryDataSet; FromPath: string): string;
var
  Doc: TDocVariantData;
  SL: TStringlist;
begin
  try
    SL := TStringlist.Create;
    try
      Result := '';
      try
        SL.LoadFromFile(FromPath, TEncoding.UTF8);
      except
        SL.LoadFromFile(FromPath);
      end;

      //2023-07-07 doc.initjsonfromfile(frompath);
      doc.InitJson(trim(Sl.Text));
      try
        loadtomds(@doc, mds);
      finally
        doc.clear;
      end;
    finally
      SL.Free;
    end;
  except
    on e: exception do
      Result := '[error]' + e.Message;
  end;
end;

function DBMemory_Load(mds: THjhMemoryDataSet; FromPath, Fields_info: string): string;
begin
  try
    if FileExists(FromPath) then
    begin
      if SameText(ExtractFileExt(FromPath), '.json') then
        Result := DBMemory_LoadJson(mds, FromPath)
      else
        if not mds.LoadFromFile(FromPath, Result) then exit;
      Decrypt(mds, Fields_info);
    end else
      mds.Clear;
  except
    on e: exception do
      Result := e.Message;
  end;
end;

function DBMemory_MxSaveJson(mds: THjhMemoryDataSet; ToPath, Fields_info: string): string;
var
  SL: TStringlist;
begin
  SL := TStringlist.Create;
  try
    SL.Text := mds2Json(mds);
    try
      SL.SaveToFile(ToPath, TEncoding.UTF8);
    except
      on e: exception do
        Result := e.Message;
    end;
  finally
    SL.Free;
  end;
end;

function DBMemory_MxSave(mds: THjhMemoryDataSet; ToPath, Fields_info: string): string;
begin
  try
    ForceDirectories(ExtractFilePath(ToPath));
    if SameText(ExtractFileExt(ToPath), '.json')  then
      Result := DBMemory_MxSaveJson(mds, ToPath, Fields_info)
    else
      if not mds.SaveToFile(ToPath, Result) then exit;
  except
    on e: exception do
      Result := e.Message;
  end;
end;

end.

