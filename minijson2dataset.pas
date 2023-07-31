
//////////////////////////////////////////////////////////////////////////////////
///                                                                            ///
///  miniframe开源Web框架技术群：821855479 如果加不了群，请联系QQ：3123827806  ///
///  网页制作器网址：https://wyeditor.com                                      ///
///  源码及demo下载：https://wyeditor.com/miniframe/                           ///
///                                                                            ///
//////////////////////////////////////////////////////////////////////////////////

unit minijson2dataset;
{$ifdef fpc}
{$MODE Delphi}
{$endif}
interface

uses
  Classes, SysUtils, syncobjs{$IFDEF FPC}, FileUtil{$endif}, VirtualTable,
  mormot.core.base, mormot.core.data, mormot.core.variants, mormot.core.text,
  DataPackageUnit, DB, TypInfo, PubSysUnit, PubStringUnit;

  //dataset与Json互转
  function DataSet2Json(ds: TDataSet): string;
  function Json2DataSet(ds: TDataSet; Json: string): string;

  //THjhMemoryDataset与Json 互转
  function mds2Json(mds: THjhMemoryDataSet): string;
  function Json2mds(Json: string; mds: THjhMemoryDataSet): string;

  procedure LoadTomds(Doc: PDocVariantData; mds: THjhMemoryDataSet);

implementation


function mds2Json(mds: THjhMemoryDataSet): string;
var
  lp: Integer;
  Doc, dataArray: TDocVariantData;
  Data: variant;
begin
  Doc.Init;
  Doc.I['recordcount'] := mds.RecordCount;
  try

    dataArray.Init;
    mds.First;
    while not mds.Eof do
    begin
      for lp := 0 to mds.Fields.Count - 1 do
      if mds.Fields[lp].FieldName <> 'fnew_data' then
        dataArray.S[mds.Fields[lp].FieldName] := mds.Fields[lp].AsString;
      TDocVariantData(Data).InitJSON(dataArray.ToJSON());
      doc.A_['data']^.AddItem(Data);
      mds.Next;
    end;

    //类型
    VarClear(data);
    dataArray.Clear;
    for lp := 0 to mds.Fields.Count - 1 do
    if mds.Fields[lp].FieldName <> 'fnew_data' then
      dataArray.S[mds.Fields[lp].FieldName] := GetEnumName(TypeInfo(TFieldType), Ord(mds.Fields[lp].DataType));

    TDocVariantData(Data).InitJSON(dataArray.ToJSON());
    doc.Value['types'] := data;
    Result := doc.ToJSON('', '', jsonEscapeUnicode);
  finally
    dataArray.Clear;
    doc.Clear;
    VarClear(data);
    //FreeAndNil(doc);
    //FreeAndNil(doc);
  end;
end;

function Json2DataSet(ds: TDataSet; Json: string): string;
var
  lp, I: Integer;
  Doc: TDocVariantData;
  Vt: TVirtualTable;
  F, S, R, P, Tmp: string;
  Ft: TFieldType;
  MS: TMemoryStream;
begin
  if not(ds is TVirtualTable) then
  begin
    Result := '[error]数据集不是TVirtualTable，不能继续！';
    exit;
  end;
  try
    Vt := TVirtualTable(ds);
    Vt.Close;
    Vt.FieldDefs.Clear;
    doc.InitJson(Json);
    try

      //类型
      for lp := 0 to Doc._[2].Count - 1 do
      begin
        Tmp := Doc._[2].Values[lp];
        F := PubString.GetDeliPri(Tmp, ',');
        Tmp := PubString.GetDeliBack(Tmp, ',');

        if Pos(',', Tmp) > 0 then
        begin
          S := PubString.GetDeliPri(Tmp, ',');
          Tmp := PubString.GetDeliBack(Tmp, ',');

          R := PubString.GetDeliPri(Tmp, ',');
          Tmp := PubString.GetDeliBack(Tmp, ',');

          P := PubString.GetDeliPri(Tmp, ',');
          Tmp := PubString.GetDeliBack(Tmp, ',');

          if trim(S) = '' then S := '0';
        end else
        begin
          S := '0';
          R := '0';
          P := '0';
        end;
        Ft := TFieldType(GetEnumValue(TypeInfo(TFieldType), F));
        vt.FieldDefs.Add(Doc._[2].Names[lp], Ft, StrToInt(S), R = '1');
      end;

      vt.Open;
      //数据
      for lp := 0 to Doc._[1].Count - 1 do
      begin
        vt.Append;
        for I := 0 to vt.Fields.Count - 1 do
        begin
          Tmp := Doc._[1]._[lp].Values[I];
          if ((ds.Fields[I].DataType = ftBlob) or (ds.Fields[I].DataType = ftGraphic)) then
          begin
            if length(Tmp) < 10 then Continue; //blob小于10认为空

            MS := TMemoryStream.Create;
            try
              PubSys.Base64ToStream(Tmp, MS);
              MS.Position := 0;
              TBlobField(ds.Fields[I]).LoadFromStream(MS);
            finally
              Ms.Free;
            end;
          end else
            vt.FieldByName(vt.Fields[I].FieldName).AsString := Tmp;
        end;
      end;
      vt.Post;
      vt.First;
    finally
      doc.Clear;
    end;
  except
    on e: exception do
      Result := '[error]' + e.Message;
  end;
end;

function DataSet2Json(ds: TDataSet): string;
var
  lp: Integer;
  Doc, dataArray: TDocVariantData;
  Data: variant;
  MS: TMemoryStream;
begin
  try
    Doc.Init;
    Doc.I['recordcount'] := ds.RecordCount;
    try
      dataArray.Init;
      ds.First;
      while not ds.Eof do
      begin
        for lp := 0 to ds.Fields.Count - 1 do
        //if ds.Fields[lp].FieldName <> 'fnew_data' then
        begin
          if ((ds.Fields[lp].DataType = ftBlob) or (ds.Fields[lp].DataType = ftGraphic)) and (not ds.Fields[lp].IsNull) then
          begin
            MS := TMemoryStream.Create;
            try
              TBlobField(ds.Fields[lp]).SaveToStream(MS);
              dataArray.S[ds.Fields[lp].FieldName] := PubSys.StreamToBase64(MS);
            finally
              Ms.Free;
            end;
          end else
            dataArray.S[ds.Fields[lp].FieldName] := ds.Fields[lp].AsString;
        end;
        TDocVariantData(Data).InitJSON(dataArray.ToJSON());
        doc.A_['data']^.AddItem(Data);
        TDocVariantData(Data).Clear;
        dataArray.Clear;
        ds.Next;
      end;
      VarClear(data);
      for lp := 0 to ds.Fields.Count - 1 do
      //if ds.Fields[lp].FieldName <> 'fnew_data' then
      begin
        if ds.Fields[lp] is TFMTBCDField then
          dataArray.S[ds.Fields[lp].FieldName] := GetEnumName(TypeInfo(TFieldType), Ord(ds.Fields[lp].DataType)) + ',' + ds.Fields[lp].Size.toString +
            ',' + ds.Fields[lp].Required.ToInteger.ToString+ ',' + TFMTBCDField(ds.Fields[lp]).Precision.ToString
        else
          dataArray.S[ds.Fields[lp].FieldName] := GetEnumName(TypeInfo(TFieldType), Ord(ds.Fields[lp].DataType)) + ',' + ds.Fields[lp].Size.toString +
            ',' + ds.Fields[lp].Required.ToInteger.ToString+ ',0';
      end;
      TDocVariantData(Data).InitJSON(dataArray.ToJSON());
      doc.Value['types'] := data;
      TDocVariantData(Data).Clear;

      //Result := doc.ToJSON('', '', jsonEscapeUnicode);//jsonHumanReadable);
      Result := doc.ToJSON('', '', jsonEscapeUnicode);
    finally
      doc.Clear;
      //dataArray.Clear;
      VarClear(data);
      //FreeAndNil(doc);
      //FreeAndNil(doc);
    end;
  except
    on e: Exception do
      Result := '[error]' + e.Message;
  end;
end;

procedure LoadTomds(Doc: PDocVariantData; mds: THjhMemoryDataSet);
var
  lp, I: Integer;
  Tmp: string;
begin
  mds.Clear;
  //类型
  for lp := 0 to Doc._[2].Count - 1 do
    mds.Fields.Add(Doc^._[2].Names[lp], TFieldType(GetEnumValue(TypeInfo(TFieldType), PubString.GetDeliPri(Doc^._[2].Values[lp], ','))));

  //数据
  for lp := 0 to Doc._[1].Count - 1 do
  begin
    mds.Append;
    for I := 0 to mds.Fields.Count - 1 do
    begin
      ///Tmp := VariantToString(Doc^._[1]._[lp].Values[I]);
      Tmp := doc.A['data']._[lp].S[mds.Fields[I].FieldName];
      mds.S(mds.Fields[I].FieldName, Tmp);
    end;
  end;
end;

function Json2mds(Json: string; mds: THjhMemoryDataSet): string;
var
  lp, I: Integer;
  Doc: TDocVariantData;
begin
  try
    doc.InitJson(Json);
    try
      LoadTomds(@Doc, mds);
    finally
      doc.Clear;
    end;
  except
    on e: exception do
      Result := '[error]' + e.Message;
  end;
end;

end.
