unit MainUnit;
{$MODE Delphi}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, baseformUnit, StdCtrls, clientpub,
  ExtCtrls, HuoPubFuncUnit, DataPackageUnit, DB, Grids, Shellapi,
  DBGrids, VirtualTable, minicomponents, math, minijson2dataset, loginUnit,
  PubFileUnit, PubPWDUnit;

type
  TPageInfo = record
    pn, recordcount, pagecount, maxpagecount: string;
    readtype: string;
  end;

  { TMainForm }

  TMainForm = class(Tbaseform)
    DBGrid1: TDBGrid;
    Image10: TImage;
    Image11: TImage;
    Image12: TImage;
    Image8: TImage;
    Image9: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel12: TPanel;
    Panel13: TPanel;
    Panel14: TPanel;
    Panel15: TPanel;
    Panel16: TPanel;
    Panel17: TPanel;
    Panel2: TPanel;
    lblsp1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    DataSource1: TDataSource;
    plMore: TPanel;
    VirtualTable1: TVirtualTable;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    lblinfo: TLabel;
    lblMsg: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    plleft: TPanel;
    lblsp2: TLabel;
    Panel3: TPanel;
    Panel4: TPanel;
    Image2: TImage;
    Panel6: TPanel;
    Image4: TImage;
    Label17: TLabel;
    Label18: TLabel;
    Panel1: TPanel;
    Image1: TImage;
    Label13: TLabel;
    Label14: TLabel;
    Panel5: TPanel;
    Image3: TImage;
    Label15: TLabel;
    Label16: TLabel;
    Panel7: TPanel;
    Image5: TImage;
    Label19: TLabel;
    Label20: TLabel;
    Panel8: TPanel;
    Image6: TImage;
    Label21: TLabel;
    Label22: TLabel;
    Panel9: TPanel;
    Image7: TImage;
    Label23: TLabel;
    Label24: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Image10Click(Sender: TObject);
    procedure Image11Click(Sender: TObject);
    procedure Image12Click(Sender: TObject);
    procedure Image8Click(Sender: TObject);
    procedure Image9Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure Label5Click(Sender: TObject);
    procedure Label7Click(Sender: TObject);
    procedure Label8Click(Sender: TObject);
    procedure Label9Click(Sender: TObject);
    procedure Label10Click(Sender: TObject);
    procedure Label11Click(Sender: TObject);
    procedure Label12Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Label15Click(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image5Click(Sender: TObject);
    procedure Image7Click(Sender: TObject);
    procedure Image6Click(Sender: TObject);
    procedure Image4Click(Sender: TObject);
  private
    //FMsdata: TMemoryStream;
    //FJsondata, FUpFileName: string;
    FMyMsg: string;
    FHadExit: boolean;
    FPageInfo: TPageInfo;
    FHandle: HWND;
    procedure CloseMore;
    procedure ReadOnePage();
    procedure ReaOnePage_Run(var ThreadRetInfo: TThreadRetInfo);
    procedure ReaOnePage_Result(var ThreadRetInfo: TThreadRetInfo);
    procedure SaveOnePage_Json_Result(var ThreadRetInfo: TThreadRetInfo);
    procedure SaveOnePage_Json_Run(var ThreadRetInfo: TThreadRetInfo);
    procedure SaveOnePage_Stream_Result(var ThreadRetInfo: TThreadRetInfo);
    procedure SaveOnePage_Stream_Run(var ThreadRetInfo: TThreadRetInfo);
    procedure SyncBlockfile_Result(var ThreadRetInfo: TThreadRetInfo);
    procedure SyncBlockfile_Run(var ThreadRetInfo: TThreadRetInfo);
    procedure Upfile_Result(var ThreadRetInfo: TThreadRetInfo);
    procedure Upfile_Run(var ThreadRetInfo: TThreadRetInfo);
    procedure IniData;
    procedure LoginOut(NeedLogin: string = '');
    procedure LoginOut_Result(var ThreadRetInfo: TThreadRetInfo);
    procedure LoginOut_Run(var ThreadRetInfo: TThreadRetInfo);
    procedure Downfile_Result(var ThreadRetInfo: TThreadRetInfo);
    procedure Downfile_Run(var ThreadRetInfo: TThreadRetInfo);
    procedure UpgradeBlock_Result(var ThreadRetInfo: TThreadRetInfo);
    procedure UpgradeBlock_Run(var ThreadRetInfo: TThreadRetInfo);
    procedure Upgrade_Run(var ThreadRetInfo: TThreadRetInfo);
    procedure Upgrade_Result(var ThreadRetInfo: TThreadRetInfo);
    procedure MyUpdateface;
    procedure Syncfile_Run(var ThreadRetInfo: TThreadRetInfo);
    procedure Syncfile_Result(var ThreadRetInfo: TThreadRetInfo);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.Image1Click(Sender: TObject);
{var
  ErrStr, HTML: string;
  Ms: TMemoryStream;
  Json: TminiJson;}
var
  InParams: TminiInParams;
begin //保存表格数据,提交二进制流
  inherited;

  //异步方式，为什么不采用匿名函数呢，因laz不支持，为了通用
  lblMsg.Caption := '正在保存第' + FPageInfo.pn + '页数据。。。';

  InParams.obj1 := TMemoryStream.Create;
  VirtualTable1.SaveToStream(TStream(InParams.obj1));
  Run_Async(InParams, SaveOnePage_Stream_Run, SaveOnePage_Stream_Result);

  {
  Ms := TMemoryStream.Create;
  Json := TminiJson.Create;
  try
    //注意，如果服务端器是 laz,客户端用VirtualTable1.SaveToStream会报错，应该是unidac的问题，服务端与客户端都是delphi没这个问题
    VirtualTable1.SaveToStream(Ms);
    if not HttpPost('/接口/保存用户数据.html', Ms, ErrStr, HTML) then
    begin
      Pub.MsgBox(ErrStr);
      exit;
    end;

    Json.LoadFromString(HTML);
    if Json.S['retcode'] = '200' then
      Pub.MsgBox(Json.S['retmsg'])
    else
      Pub.MsgBox(Json.S['retmsg']);
  finally
    Json.Free;
    Ms.Free;
  end; }
end;

procedure TMainForm.Image4Click(Sender: TObject);
begin
  inherited;
  ShellExecute(0, 'Open', PChar('https://www.wyeditor.com/miniframe/'), '', '', 1);
end;

procedure TMainForm.Image5Click(Sender: TObject);
var
  InParams: TminiInParams;
begin //上传文件
  inherited;
  if not OpenDialog1.Execute() then exit;
  InParams.P1 := OpenDialog1.FileName;
  //异步方式，为什么不采用匿名函数呢，因laz不支持，为了通用, 如果只是delphi下用，用匿名函数比较简单
  lblMsg.Caption := '正在上传文件' + InParams.P1 + '。。。';

  Run_Async(InParams, Upfile_Run, Upfile_Result);
end;

procedure TMainForm.Image7Click(Sender: TObject);
begin //下载文件
  inherited;
  lblMsg.Caption := '正在下载文件，请稍候。。。';
  Run_Async(Downfile_Run, Downfile_Result);
end;

procedure TMainForm.IniData;
begin
  FPageInfo.pn := '1';
  lblinfo.Caption := '你好，欢迎 ' + FClientPubinfo.username;
  FPageInfo.readtype := '2';
  ReadOnePage();
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  if not FHadExit then
    LoginOut();
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FHadExit := false;
  IniData;
end;


procedure TMainForm.CloseMore;
begin
  plMore.Visible := false;
end;

procedure TMainForm.Image8Click(Sender: TObject);
begin
  plMore.Visible := true;
end;

procedure TMainForm.Image9Click(Sender: TObject);
begin
  CloseMore;
end;

procedure TMainForm.ReaOnePage_Run(var ThreadRetInfo: TThreadRetInfo);
var
  PostSL: TStringList;
  MyURL: string;
begin
  MyURL := ('/接口/分页读取用户.html');
  ThreadRetInfo.Ok := false;
  //提交的内容存放 用  PostSL.Values[name] = value;
  PostSL := TStringList.Create;
  try
    PostSL.Values['readtype'] := FPageInfo.readtype;
    PostSL.Values['pn'] := FPageInfo.pn;
    PostSL.Values['pagecount'] := '20';
    if not HttpPost(MyURL, PostSL, ThreadRetInfo.ErrStr, ThreadRetInfo.HTML, ThreadRetInfo.OutStream) then exit;
  finally
    PostSL.Free;
  end;
  ThreadRetInfo.Ok := true;
end;

procedure TMainForm.ReaOnePage_Result(var ThreadRetInfo: TThreadRetInfo);
var
  Json: TminiJson;
  mds: THjhMemoryDataSet;
  lp: integer;
begin
  lblMsg.Caption := '';
  if not ThreadRetInfo.Ok then
  begin
    Pub.MsgBox(ThreadRetInfo.ErrStr);
    exit;
  end;
  if FPageInfo.readtype = '2' then
  begin //以Json返回
    Json := TminiJson.Create;
    try
      Json.LoadFromString(ThreadRetInfo.HTML);

      if Json.S['retcode'] <> '200' then
        Pub.MsgBox(Json.S['retmsg'])
      else
      begin
        FPageInfo.pn := Json.S['pn'];
        FPageInfo.pagecount := Json.S['pagecount'];
        FPageInfo.recordcount := Json.S['recordcount'];
        FPageInfo.maxpagecount := IntToStr(Ceil(StrToInt(FPageInfo.recordcount)/StrToInt(FPageInfo.pagecount)));
        Label6.Caption := FPageInfo.pn + '/' + FPageInfo.maxpagecount;
        Json2DataSet(VirtualTable1, Json.S['data']);
      end;
    finally
      Json.Free;
    end;
  end else //以二进制流返回
  if ThreadRetInfo.OutStream <> nil then
  begin
    mds := THjhMemoryDataSet.Create(Self);
    try
      ThreadRetInfo.OutStream.Position := 0;
      if not mds.LoadFromStream(ThreadRetInfo.OutStream, ThreadRetInfo.ErrStr) then
      begin
        Pub.MsgBox(ThreadRetInfo.ErrStr);
        exit;
      end;

      ThreadRetInfo.OutStream.Clear;
      if not mds.FieldByName('data').BlobSaveToStream(ThreadRetInfo.OutStream, ThreadRetInfo.ErrStr) then
      begin
        Pub.MsgBox(ThreadRetInfo.ErrStr);
        exit;
      end;

      FPageInfo.pn := mds.FieldByName('pn').AsString;
      FPageInfo.pagecount := mds.FieldByName('pagecount').AsString;
      FPageInfo.recordcount := mds.FieldByName('recordcount').AsString;
      FPageInfo.maxpagecount := IntToStr(Ceil(StrToInt(FPageInfo.recordcount)/StrToInt(FPageInfo.pagecount)));
      Label6.Caption := FPageInfo.pn + '/' + FPageInfo.maxpagecount;


      ThreadRetInfo.OutStream.Position := 0;
      VirtualTable1.LoadFromStream(ThreadRetInfo.OutStream);
      VirtualTable1.Open;
    finally
      //ThreadRetInfo.OutStream.Free;
      mds.Free;
    end;

  end else
  begin
    Json := TminiJson.Create;
    try
      Json.LoadFromString(ThreadRetInfo.HTML);
      Pub.MsgBox(Json.S['retmsg']);
      exit;
    finally
      Json.Free;
    end;
  end;

  for lp := 0 to DBGrid1.Columns.Count - 1 do
    DBGrid1.Columns[lp].Width := 50;
end;


procedure TMainForm.ReadOnePage();
var
  MS: TMemoryStream;
  PostSL: TStringList;
  ErrStr, HTML: string;
  mds: THjhMemoryDataSet;
  Json: TminiJson;
  lp: integer;
begin
  inherited;

  //异步方式，为什么不采用匿名函数呢，因laz不支持，为了通用
  lblMsg.Caption := '正在读取第' + FPageInfo.pn + '页数据。。。';
  Run_Async(ReaOnePage_Run, ReaOnePage_Result);

  {阻塞方式
  //提交的内容存放 用  PostSL.Values[name] = value;
  PostSL := TStringList.Create;
  try
    PostSL.Values['readtype'] := readtype;
    PostSL.Values['pn'] := pn;
    PostSL.Values['pagecount'] := '20';

    if not HttpPost('/接口/分页读取用户.html', PostSL, ErrStr, HTML, MS) then
    begin
      Pub.MsgBox(ErrStr);
      exit;
    end;
  finally
    PostSL.Free;
  end;

  if readtype = '2' then
  begin //以Json返回
    Json := TminiJson.Create;
    try
      Json.LoadFromString(HTML);
      if Json.S['retcode'] <> '200' then
        Pub.MsgBox(Json.S['retmsg'] + '=' + Json.S['retcode'])
      else
      begin
        FPageInfo.pn := Json.S['pn'];
        FPageInfo.pagecount := Json.S['pagecount'];
        FPageInfo.recordcount := Json.S['recordcount'];
        FPageInfo.maxpagecount := IntToStr(Ceil(StrToInt(FPageInfo.recordcount)/StrToInt(FPageInfo.pagecount)));
        Label6.Caption := FPageInfo.pn + '/' + FPageInfo.maxpagecount;
        Json2DataSet(VirtualTable1, Json.S['data']);
      end;
    finally
      Json.Free;
    end;
  end else //以二进制流返回
  if MS <> nil then
  begin
    mds := THjhMemoryDataSet.Create(Self);
    try
      MS.Position := 0;
      if not mds.LoadFromStream(MS, ErrStr) then
      begin
        Pub.MsgBox(ErrStr);
        exit;
      end;

      ms.Clear;
      if not mds.FieldByName('data').BlobSaveToStream(MS, ErrStr) then
      begin
        Pub.MsgBox(ErrStr);
        exit;
      end;

      FPageInfo.pn := mds.FieldByName('pn').AsString;
      FPageInfo.pagecount := mds.FieldByName('pagecount').AsString;
      FPageInfo.recordcount := mds.FieldByName('recordcount').AsString;
      FPageInfo.maxpagecount := IntToStr(Ceil(StrToInt(FPageInfo.recordcount)/StrToInt(FPageInfo.pagecount)));
      Label6.Caption := FPageInfo.pn + '/' + FPageInfo.maxpagecount;


      MS.Position := 0;
      VirtualTable1.LoadFromStream(MS);
      VirtualTable1.Open;
    finally
      Ms.Free;
      mds.Free;
    end;

  end else
  begin
    Json := TminiJson.Create;
    try
      Json.LoadFromString(HTML);
      Pub.MsgBox(Json.S['retmsg']);
      exit;
    finally
      Json.Free;
    end;
  end;

  for lp := 0 to DBGrid1.Columns.Count - 1 do
    DBGrid1.Columns[lp].Width := 50;  }
end;

procedure TMainForm.Label10Click(Sender: TObject);
begin
  inherited;
  FPageInfo.pn := FPageInfo.maxpagecount;
  FPageInfo.readtype := '2';
  ReadOnePage();
end;

procedure TMainForm.Label11Click(Sender: TObject);
begin
  inherited;
  ShellExecute(0, 'open', PChar('https://wyeditor.com/miniframe/'), nil, nil, 1);
end;

procedure TMainForm.LoginOut_Run(var ThreadRetInfo: TThreadRetInfo);
begin
  ThreadRetInfo.Ok := false;
  if not HttpPost('/接口/退出登录.html', '', ThreadRetInfo.ErrStr, ThreadRetInfo.HTML, ThreadRetInfo.OutStream) then exit;
  ThreadRetInfo.Ok := true;
end;

procedure TMainForm.LoginOut_Result(var ThreadRetInfo: TThreadRetInfo);
var
  Json: TminiJson;
  mds: THjhMemoryDataSet;
  lp: integer;
begin
  lblMsg.Caption := '';
  if not ThreadRetInfo.Ok then
  begin
    if ThreadRetInfo.InParams.P1 = '1' then
      Pub.MsgBox(ThreadRetInfo.ErrStr)
    else
      FHadExit := true;
    exit;
  end;

  if ThreadRetInfo.InParams.P1 = '1' then
  begin
    login := Tlogin.Create(nil);
    try
      if login.ShowModal <> 1 then exit;
      IniData;
    finally
      login.Free;
    end;
  end else
  begin
    FHadExit := true;
    CLose;
  end;
end;

procedure TMainForm.LoginOut(NeedLogin: string);
var
  InParam: TminiInParams;
  Count: integer;
begin
  lblMsg.Caption := '正在退出登录，请稍候...';
  InParam.P1 := NeedLogin;
  Run_Async(InParam, LoginOut_Run, LoginOut_Result);

  if NeedLogin <> '1' then
  begin
    //最多等3秒直接退出;
    Count := 0;
    while not FHadExit do
    begin
      Application.ProcessMessages;
      Inc(Count);
      Sleep(100);
      if Count > 3 * 10 then
        break;
    end;
  end;
end;

procedure TMainForm.Label12Click(Sender: TObject);
begin
  inherited;
  LoginOut('1');
end;

procedure TMainForm.Label15Click(Sender: TObject);
var
  bk: TBookmark;
  InParams: TminiInParams;
begin //保存表格数据-提交Json数据集
  inherited;

  //异步方式，为什么不采用匿名函数呢，因laz不支持，为了通用
  lblMsg.Caption := '正在保存第' + FPageInfo.pn + '页数据。。。';

  //获取Json数据
  VirtualTable1.DisableControls;
  bk := VirtualTable1.GetBookmark;
  try
    InParams.P1 := DataSet2Json(VirtualTable1);
  finally
    VirtualTable1.GotoBookmark(bk);
    VirtualTable1.FreeBookmark(bk);
    VirtualTable1.EnableControls;
  end;

  Run_Async(InParams, SaveOnePage_Json_Run, SaveOnePage_Json_Result);

  {阻塞方式
  Json := TminiJson.Create;
  VirtualTable1.DisableControls;
  bk := VirtualTable1.GetBookmark;
  try

    if not HttpPost('/接口/保存用户数据.html?savetype=2', DataSet2Json(VirtualTable1), ErrStr, HTML) then
    begin
      Pub.MsgBox(ErrStr);
      exit;
    end;

    Json.LoadFromString(HTML);
    if Json.S['retcode'] = '200' then
      Pub.MsgBox(Json.S['retmsg'])
    else
      Pub.MsgBox(Json.S['retmsg']);
  finally
    Json.Free;
    VirtualTable1.GotoBookmark(bk);
    VirtualTable1.FreeBookmark(bk);
    VirtualTable1.EnableControls;
  end;
  }
end;

procedure TMainForm.Label1Click(Sender: TObject);
begin
  inherited;
  {FHadExit := false;
  LoginOut();
  Close; }
end;

procedure TMainForm.Label2Click(Sender: TObject);
begin
  inherited;
  FPageInfo.pn := '1';
  FPageInfo.readtype := '1';
  ReadOnePage();
end;

procedure TMainForm.Label3Click(Sender: TObject);
begin
  inherited;
  FPageInfo.pn := IntToStr(StrToInt(FPageInfo.pn) - 1);
  if StrToInt(FPageInfo.pn) < 1 then
    FPageInfo.pn := '1';
  FPageInfo.readtype := '1';
  ReadOnePage();
end;

procedure TMainForm.Label4Click(Sender: TObject);
begin
  inherited;
  FPageInfo.pn := IntToStr(StrToInt(FPageInfo.pn) + 1);
  if StrToInt(FPageInfo.pn) > StrToInt(FPageInfo.maxpagecount) then
     FPageInfo.pn := FPageInfo.maxpagecount;
  FPageInfo.readtype := '1';
  ReadOnePage();
end;

procedure TMainForm.Label5Click(Sender: TObject);
begin
  inherited;
  FPageInfo.pn := FPageInfo.maxpagecount;
  FPageInfo.readtype := '1';
  ReadOnePage();
end;

procedure TMainForm.Label7Click(Sender: TObject);
begin
  inherited;
  FPageInfo.pn := '1';
  FPageInfo.readtype := '2';
  ReadOnePage();
end;

procedure TMainForm.Label8Click(Sender: TObject);
begin
  inherited;
  FPageInfo.pn := IntToStr(StrToInt(FPageInfo.pn) - 1);
  if StrToInt(FPageInfo.pn) < 1 then
    FPageInfo.pn := '1';
  FPageInfo.readtype := '2';
  ReadOnePage();
end;

procedure TMainForm.Label9Click(Sender: TObject);
begin
  inherited;
  FPageInfo.pn := IntToStr(StrToInt(FPageInfo.pn) + 1);
  if StrToInt(FPageInfo.pn) > StrToInt(FPageInfo.maxpagecount) then
     FPageInfo.pn := FPageInfo.maxpagecount;
  FPageInfo.readtype := '2';
  ReadOnePage();
end;

procedure TMainForm.SaveOnePage_Stream_Run(var ThreadRetInfo: TThreadRetInfo);
begin
  //不能这样 FJsondata := DataSet2Json(VirtualTable1); //线程里不能直接访问主线程的数据
  ThreadRetInfo.Ok := false;
  if not HttpPost('/接口/保存用户数据.html', TStream(ThreadRetInfo.InParams.obj1), ThreadRetInfo.ErrStr, ThreadRetInfo.HTML) then exit;
  ThreadRetInfo.Ok := true;
end;

procedure TMainForm.SaveOnePage_Stream_Result(var ThreadRetInfo: TThreadRetInfo);
var
  Json: TminiJson;
begin
  ThreadRetInfo.InParams.obj1.Free;
  lblMsg.Caption := '';
  if not ThreadRetInfo.Ok then
  begin
    Pub.MsgBox(ThreadRetInfo.ErrStr);
    exit;
  end;
  Json := TminiJson.Create;
  try
    Json.LoadFromString(ThreadRetInfo.HTML);
    if Json.S['retcode'] = '200' then
      Pub.MsgBox(Json.S['retmsg'])
    else
      Pub.MsgBox(Json.S['retmsg']);
  finally
    Json.Free;
  end;
end;


procedure TMainForm.SaveOnePage_Json_Run(var ThreadRetInfo: TThreadRetInfo);
begin
  //不能这样 FJsondata := DataSet2Json(VirtualTable1); //线程里不能直接访问主线程的数据
  ThreadRetInfo.Ok := false;
  if not HttpPost('/接口/保存用户数据.html?savetype=2', ThreadRetInfo.InParams.P1, ThreadRetInfo.ErrStr, ThreadRetInfo.HTML) then exit;
  ThreadRetInfo.Ok := true;
end;

procedure TMainForm.SaveOnePage_Json_Result(var ThreadRetInfo: TThreadRetInfo);
var
  Json: TminiJson;
begin
  lblMsg.Caption := '';
  if not ThreadRetInfo.Ok then
  begin
    Pub.MsgBox(ThreadRetInfo.ErrStr);
    exit;
  end;
  Json := TminiJson.Create;
  try
    Json.LoadFromString(ThreadRetInfo.HTML);
    if Json.S['retcode'] = '200' then
      Pub.MsgBox(Json.S['retmsg'])
    else
      Pub.MsgBox(Json.S['retmsg']);
  finally
    Json.Free;
  end;
end;

procedure TMainForm.Upfile_Run(var ThreadRetInfo: TThreadRetInfo);
var
  Fs: TFileStream;
begin
  ThreadRetInfo.Ok := false;
  Fs := TFileStream.Create(ThreadRetInfo.InParams.p1, fmShareDenyWrite);
  try
    if not HttpPost('/接口/上传和下载文件.html?opr=1&fn=' + UrlEncode(ExtractFileName(ThreadRetInfo.InParams.p1)),
      fs, ThreadRetInfo.ErrStr, ThreadRetInfo.HTML) then exit;
  finally
    Fs.Free;
  end;
  ThreadRetInfo.Ok := true;
end;

procedure TMainForm.Upfile_Result(var ThreadRetInfo: TThreadRetInfo);
var
  Json: TminiJson;
begin
  lblMsg.Caption := '';
  if not ThreadRetInfo.Ok then
  begin
    Pub.MsgBox(ThreadRetInfo.ErrStr);
    exit;
  end;
  try
    Json := TminiJson.Create;
    try
      Json.LoadFromString(ThreadRetInfo.HTML);
      if Json.S['retcode'] = '200' then
        Pub.MsgBox(Json.S['retmsg'])
      else
        Pub.MsgBox(Json.S['retmsg']);
    finally
      Json.Free;
    end;
  except
    on e: exception do
      Pub.MsgBox(e.Message);
  end;

end;

procedure TMainForm.Downfile_Run(var ThreadRetInfo: TThreadRetInfo);
begin
  ThreadRetInfo.Ok := false;
  if not HttpPost('/接口/上传和下载文件.html?opr=2&fn=',
      '', ThreadRetInfo.ErrStr, ThreadRetInfo.HTML, ThreadRetInfo.OutStream) then exit;
  //if ThreadRetInfo.OutStream <> nil then
    //TMemoryStream(ThreadRetInfo.OutStream).SaveToFile('d:\a.exe');
  ThreadRetInfo.Ok := true;
end;

procedure TMainForm.Downfile_Result(var ThreadRetInfo: TThreadRetInfo);
var
  Json: TminiJson;
begin
  lblMsg.Caption := '';
  if not ThreadRetInfo.Ok then
  begin
    Pub.MsgBox(ThreadRetInfo.ErrStr);
    exit;
  end;
  if ThreadRetInfo.OutStream = nil then
  begin
    Json := TminiJson.Create;
    try
      Json.LoadFromString(ThreadRetInfo.HTML);
      if Json.S['retcode'] = '200' then
        Pub.MsgBox(Json.S['retmsg'])
      else
        Pub.MsgBox(Json.S['retmsg']);
    finally
      Json.Free;
    end;
  end else
  begin
    SaveDialog1.FileName := ThreadRetInfo.HTML;
    if not SaveDialog1.Execute() then exit;
    ThreadRetInfo.OutStream.SaveToFile(SaveDialog1.FileName);
  end;
end;

procedure TMainForm.MyUpdateface;
begin
  lblMsg.Caption := FMyMsg;
end;

procedure TMainForm.Upgrade_Run(var ThreadRetInfo: TThreadRetInfo);
var
  HTML, ToPath, RelativePath, FN, Tmp, TmpFileName, FailFiles, SuccFiles: string;
  Json, TmpJson: TminiJson;
  lp: integer;
  Flag: boolean;
  SL, SLDate: TStringlist;
  MS: TMemoryStream;
  procedure HintMsg(Msg: string);
  begin
    FMyMsg := Msg; // '正在获取文件列表。。。';
    ThreadRetInfo.Self.Synchronize(ThreadRetInfo.Self, MyUpdateface); //为什么不直接用匿名，因为laz不支持
  end;
begin
  ToPath := 'D:\superhtml'; //如果是当前程序更新  ExtractFilePath(ParamStr(0))

  ThreadRetInfo.Ok := false;

  HintMsg('正在获取文件列表。。。');
  if not HttpPost('/接口/程序升级更新文件.html?opr=1',
      '', ThreadRetInfo.ErrStr, ThreadRetInfo.HTML) then exit;
  if Pos('{', ThreadRetInfo.HTML) <> 1 then
  begin
    ThreadRetInfo.ErrStr :='请先检查脚本源码是否配置正确！';
    exit;
  end;
  ToPath := Pub.PathWithSlash(ToPath);

  Json := TminiJson.Create;
  SL := TStringlist.Create;
  SLDate := TStringlist.Create;
  try
    Json.LoadFromString(ThreadRetInfo.HTML);
    if json.S['retcode'] = '200' then
    begin
      TmpJson := json.A['list'];
      for lp := 0 to TmpJson.length - 1 do
      begin
        HintMsg(lp.ToString + '/' + TmpJson.length.ToString + '正在检查文件:' + RelativePath);
        RelativePath := TmpJson[lp].S['RelativePath'];
        if trim(RelativePath) = '' then Continue;
        Flag := FileExists(ToPath + RelativePath);
        if Flag then
        begin
          if (PubFile.FileGetFileTimeA(ToPath + RelativePath) = TmpJson[lp].S['FileTime']) and
             (PubFile.FileGetFileSize(ToPath + RelativePath)=TmpJson[lp].I['Size']) then
          else
            Flag := false;
        end;
        if not Flag then //此文件需要更新
        begin
          SL.Add(RelativePath);
          SLDate.Add(TmpJson[lp].S['FileTime']);
        end;
      end;

      //开始下载
      FailFiles := '';
      SuccFiles := '';
      HintMsg('需要更新的文件共有' + IntToStr(SL.Count) + '个。。。');
      for lp := 0 to SL.Count - 1 do
      begin
        RelativePath := SL[lp];
        if RelativePath[1] = '\' then RelativePath := Copy(RelativePath, 2, MaxInt);
        //MS := TMemoryStream.Create;
        try
          HintMsg(IntToStr(lp + 1) + '/' + IntToStr(SL.Count) + ', 正在下载[' + RelativePath + ']' + '。。。');
          if not HttpPost('/接口/程序升级更新文件.html?opr=2',
            'RelativePath=' + UrlEncode(RelativePath), ThreadRetInfo.ErrStr, ThreadRetInfo.HTML, MS) then exit;
          if json.S['retcode'] <> '200' then
          begin
            ThreadRetInfo.ErrStr := Json.S['retmsg'];
            exit;
          end;
          if MS = nil then
          begin
            ThreadRetInfo.ErrStr := json.S['retmsg'];
            exit;
          end else
          begin
            FN := ToPath + RelativePath;
            TmpFileName := PubFile.FileGetTemporaryFileName();
            MS.Position := 0;
            MS.SaveToFile(TmpFileName);
            MS.Free;
            MS := nil;

            //解压到指定目录
            ForceDirectories(ExtractFilePath(FN));
            if FileExists(FN) then
              DeleteFile(FN);
            if FileExists(FN) then //删除不掉只能改名
            begin
              Tmp := ExtractFilePath(FN) + '_Old@_' + ExtractFileName(FN);
              DeleteFile(Tmp);
              RenameFile(FN, Tmp);
            end;
            if FileExists(FN) then //删除不掉，又改名不成功，不能更新！！！！
              FailFiles := FailFiles + #13#10 + RelativePath
            else
            begin
              UnZipFileToFolder(TmpFileName, ExtractFilePath(FN));
              if FileExists(FN) then
              begin
                SuccFiles := SuccFiles + #13#10 + RelativePath;
                //虽然是解压，但文件的修改必须要重置，否则可能会有问题
                PubFile.FileChangeFileDate(Fn, SLDate[lp]);
              end else
                FailFiles := FailFiles + #13#10 + RelativePath;
            end;
          end;
        finally
          //MS.Free;
        end;
      end;
      ThreadRetInfo.HTML := '';
      if trim(SuccFiles) <> '' then
        ThreadRetInfo.HTML := '本次更新了以下文件：'#13#10 + SuccFiles;
      if trim(FailFiles) <> '' then
        ThreadRetInfo.HTML := trim(ThreadRetInfo.HTML + #13#10'以下文件更新失败：'#13#10 + FailFiles);
    end;
  finally
    SL.Free;
    Json.Free;
    SLDate.Free;
  end;
  ThreadRetInfo.Ok := true;
end;

procedure TMainForm.Upgrade_Result(var ThreadRetInfo: TThreadRetInfo);
var
  Json: TminiJson;
begin
  lblMsg.Caption := '';
  if not ThreadRetInfo.Ok then
  begin
    Pub.MsgBox('error:' + ThreadRetInfo.ErrStr);
    exit;
  end;
  if trim(ThreadRetInfo.HTML) <> '' then
    Pub.MsgBox(ThreadRetInfo.HTML)
  else
    Pub.MsgBox('本次没有更新！');
end;

procedure TMainForm.Image6Click(Sender: TObject);
begin //程序升级更新文件
  inherited;
  lblMsg.Caption := '正在升级，请稍候。。。';
  Run_Async(Upgrade_Run, Upgrade_Result);
end;

procedure TMainForm.Syncfile_Run(var ThreadRetInfo: TThreadRetInfo);
var
  HTML, FromPath, RelativePath, FN, Tmp, TmpFileName, FailFiles, SuccFiles, DelFiles: string;
  Json, TmpJson: TminiJson;
  lp: integer;
  Flag: boolean;
  SL, SLDate: TStringlist;
  MS: TMemoryStream;
  Fs: TFileStream;
  procedure HintMsg(Msg: string);
  begin
    FMyMsg := Msg; // '正在获取文件列表。。。';
    ThreadRetInfo.Self.Synchronize(ThreadRetInfo.Self, MyUpdateface); //为什么不直接用匿名，因为laz不支持
  end;
  procedure GetNewFiles(sDir: string);
  var
    SearchRec: SysUtils.TSearchRec;
    Status, lp: Integer;
  begin
    sDir := PubFile.PathWithSlash(sDir);
    Status := FindFirst(sDir + '*.*', faAnyFile, SearchRec);
    try
      while Status = 0 do
      begin
        if SearchRec.Attr and faDirectory = faDirectory then
        begin
          if (SearchRec.name <> '.') and (SearchRec.name <> '..') then
            GetNewFiles(sDir + SearchRec.name);
        end else
        begin
          RelativePath := Pub.GetDeliBack(sDir + SearchRec.name, FromPath);
          Flag := false;
          for lp := 0 to TmpJson.length - 1 do
          begin
            HintMsg(lp.ToString + '/' + TmpJson.length.ToString + '正在检查文件:' + RelativePath);
            if (TmpJson[lp].S['isdir'] <> '1') and (LowerCase(RelativePath) = LowerCase(TmpJson[lp].S['RelativePath'])) then
            begin
              Flag := true;
              break;
            end;
          end;
          if not Flag then
          begin //需要在服务新增加
            SL.Add('@add@@' + RelativePath);
            SLDate.Add(PubFile.FileGetFileTimeA(FromPath + RelativePath));
          end;
        end;
        Status := FindNext(SearchRec);
      end;
    finally
      FindClose(SearchRec);
    end;
  end;
begin
  FromPath := 'D:\同步测试\本地'; //将本地文件同步到服务器

  ThreadRetInfo.Ok := false;

  HintMsg('正在获取文件列表。。。');
  if not HttpPost('/接口/同步文件到服务器.html?opr=1',
      '', ThreadRetInfo.ErrStr, ThreadRetInfo.HTML) then exit;

  if Pos('{', ThreadRetInfo.HTML) <> 1 then
  begin
    ThreadRetInfo.ErrStr :='请先检查脚本源码是否配置正确！';
    exit;
  end;
  FromPath := Pub.PathWithSlash(FromPath);

  Json := TminiJson.Create;
  SL := TStringlist.Create;
  SLDate := TStringlist.Create;
  try

    Json.LoadFromString(ThreadRetInfo.HTML);
    if json.S['retcode'] = '200' then
    begin
      TmpJson := json.A['list'];

      //获取要上传或删除的文件
      SL.Clear;
      SLdate.Clear;
      for lp := 0 to TmpJson.length - 1 do
      begin
        RelativePath := TmpJson[lp].S['RelativePath'];
        HintMsg(lp.ToString + '/' + TmpJson.length.ToString + '正在检查文件:' + RelativePath);
        if (TmpJson[lp].S['isdir'] = '1') then
        begin
          if not DirectoryExists(FromPath + RelativePath) then
          begin
            SL.Add('@deldir@@' + RelativePath);
            SLDate.Add('');
          end;
        end else
        begin
          if trim(RelativePath) = '' then Continue;
          Flag := FileExists(FromPath + RelativePath);
          if Flag then
          begin
            if (PubFile.FileGetFileTimeA(FromPath + RelativePath) = TmpJson[lp].S['FileTime']) and
               (PubFile.FileGetFileSize(FromPath + RelativePath) = TmpJson[lp].I['Size']) then
            else
            begin //需要更新的
              SL.Add('@udp@@' + RelativePath);
              SLDate.Add(TmpJson[lp].S['FileTime']);
            end;
          end;
          if not Flag then //需要从服务器上删除的
          begin
            SL.Add('@del@@' + RelativePath);
            SLDate.Add('');
          end;
        end;
      end;
      //获取要新增加文件
      GetNewFiles(FromPath);

      //ThreadRetInfo.Self.Synchronize(ThreadRetInfo.Self, procedure begin
      //  ShowMessage(SL.Text);
      //end);

      //开始上传
      FailFiles := '';
      SuccFiles := '';
      DelFiles := '';
      HintMsg('需要更新的文件共有' + IntToStr(SL.Count) + '个。。。');
      for lp := 0 to SL.Count - 1 do
      begin
        RelativePath := SL[lp];

        HintMsg(IntToStr(lp + 1) + '/' + IntToStr(SL.Count) + ', 正在处理[' + Pub.GetDeliBack(RelativePath, '@@') + ']' + '。。。');
        if Pos('@del@@', RelativePath) = 1 then
        begin //删除
          RelativePath := Pub.GetDeliBack(RelativePath, '@@');
          if not HttpPost('/接口/同步文件到服务器.html?opr=2&fn=' + UrlEncode(RelativePath),
            '', ThreadRetInfo.ErrStr, ThreadRetInfo.HTML) then
          begin
            FailFiles := FailFiles + #13#10 + RelativePath;
            exit;
          end;
          Json.LoadFromString(ThreadRetInfo.HTML);
          if json.S['retcode'] <> '200' then
          begin
            ThreadRetInfo.ErrStr := Json.S['retmsg'];
            exit;
          end;
          DelFiles := DelFiles + #13#10 + RelativePath;
        end else
        if Pos('@deldir@@', RelativePath) = 1 then
        begin //删除目录，在后面删除
        end else
        begin //上传
          RelativePath := Pub.GetDeliBack(RelativePath, '@@');
          if RelativePath[1] = '\' then RelativePath := Copy(RelativePath, 2, MaxInt);
          Fs := TFileStream.Create(FromPath + RelativePath, fmShareDenyWrite);
          try
            if not HttpPost('/接口/同步文件到服务器.html?opr=3&fn=' + UrlEncode(RelativePath) + '&filetime=' + UrlEncode(SLDate[lp]),
              fs, ThreadRetInfo.ErrStr, ThreadRetInfo.HTML) then
            begin
              FailFiles := FailFiles + #13#10 + RelativePath;
              exit;
            end;
            Json.LoadFromString(ThreadRetInfo.HTML);
            if json.S['retcode'] <> '200' then
            begin
              ThreadRetInfo.ErrStr := Json.S['retmsg'];
              exit;
            end;
          finally
            Fs.Free;
          end;
          SuccFiles := SuccFiles + #13#10 + RelativePath;
        end;
      end;
      //文件夹要最后删除，不然删除不掉的
      for lp := 0 to SL.Count - 1 do
      begin
        RelativePath := SL[lp];
        HintMsg(IntToStr(lp + 1) + '/' + IntToStr(SL.Count) + ', 正在处理[' + Pub.GetDeliBack(RelativePath, '@@') + ']' + '。。。');
        if Pos('@deldir@@', RelativePath) = 1 then
        begin //删除目录
          RelativePath := Pub.GetDeliBack(RelativePath, '@@');
          if not HttpPost('/接口/同步文件到服务器.html?opr=4&fn=' + UrlEncode(RelativePath),
            '', ThreadRetInfo.ErrStr, ThreadRetInfo.HTML) then
          begin
            FailFiles := FailFiles + #13#10 + RelativePath;
            exit;
          end;
          Json.LoadFromString(ThreadRetInfo.HTML);
          if json.S['retcode'] <> '200' then
          begin
            ThreadRetInfo.ErrStr := Json.S['retmsg'];
            exit;
          end;
          DelFiles := DelFiles + #13#10 + RelativePath;
        end;
      end;
      ThreadRetInfo.HTML := '';
      if trim(SuccFiles) <> '' then
        ThreadRetInfo.HTML := '本次上传了以下文件：'#13#10 + SuccFiles;
      if trim(DelFiles) <> '' then
        ThreadRetInfo.HTML := '本次删除了以下文件或文件夹：'#13#10 + DelFiles;
      if trim(FailFiles) <> '' then
        ThreadRetInfo.HTML := trim(ThreadRetInfo.HTML + #13#10'以下文件更新失败：'#13#10 + FailFiles);
    end;
  finally
    SL.Free;
    Json.Free;
    SLDate.Free;
  end;
  ThreadRetInfo.Ok := true;
end;

procedure TMainForm.Syncfile_Result(var ThreadRetInfo: TThreadRetInfo);
var
  Json: TminiJson;
begin
  lblMsg.Caption := '';
  if not ThreadRetInfo.Ok then
  begin
    Pub.MsgBox('error:' + ThreadRetInfo.ErrStr);
    exit;
  end;
  if trim(ThreadRetInfo.HTML) <> '' then
    Pub.MsgBox(ThreadRetInfo.HTML)
  else
    Pub.MsgBox('本次没有更新！');
end;

procedure TMainForm.Image10Click(Sender: TObject);
begin //同步到服务器
  inherited;
  CloseMore;
  lblMsg.Caption := '正在同步，请稍候。。。';
  Run_Async(Syncfile_Run, Syncfile_Result);
end;

procedure TMainForm.SyncBlockfile_Run(var ThreadRetInfo: TThreadRetInfo);
const
  BlockSize = 1024*1024; //1M
var
  HTML, FromPath, RelativePath, FN, Newfn, isend, TmpFileName, FailFiles, SuccFiles, DelFiles: string;
  Json, TmpJson: TminiJson;
  lp, Number, HadUpSize, AllSize, MySize, AllBlockCount: integer;
  Flag: boolean;
  SL, SLDate, SLSize: TStringlist;
  MS: TMemoryStream;
  Fs: TFileStream;
  procedure HintMsg(Msg: string);
  begin
    FMyMsg := Msg; // '正在获取文件列表。。。';
    ThreadRetInfo.Self.Synchronize(ThreadRetInfo.Self, MyUpdateface); //为什么不直接用匿名，因为laz不支持
  end;
  procedure GetNewFiles(sDir: string);
  var
    SearchRec: SysUtils.TSearchRec;
    Status, lp: Integer;
  begin
    sDir := PubFile.PathWithSlash(sDir);
    Status := FindFirst(sDir + '*.*', faAnyFile, SearchRec);
    try
      while Status = 0 do
      begin
        if SearchRec.Attr and faDirectory = faDirectory then
        begin
          if (SearchRec.name <> '.') and (SearchRec.name <> '..') then
            GetNewFiles(sDir + SearchRec.name);
        end else
        begin
          RelativePath := Pub.GetDeliBack(sDir + SearchRec.name, FromPath);
          Flag := false;
          for lp := 0 to TmpJson.length - 1 do
          begin
            HintMsg(lp.ToString + '/' + TmpJson.length.ToString + '正在检查文件:' + RelativePath);
            if (TmpJson[lp].S['isdir'] <> '1') and (LowerCase(RelativePath) = LowerCase(TmpJson[lp].S['RelativePath'])) then
            begin
              Flag := true;
              break;
            end;
          end;
          if not Flag then
          begin //需要在服务新增加
            SL.Add('@add@@' + RelativePath);
            SLDate.Add(PubFile.FileGetFileTimeA(FromPath + RelativePath));
            SLSize.Add(PubFile.FileGetFileSize(FromPath + RelativePath).ToString);
          end;
        end;
        Status := FindNext(SearchRec);
      end;
    finally
      FindClose(SearchRec);
    end;
  end;
begin
  FromPath := 'D:\同步测试\本地'; //将本地文件同步到服务器

  ThreadRetInfo.Ok := false;

  HintMsg('正在获取文件列表。。。');
  if not HttpPost('/接口/同步文件到服务器.html?opr=1',
      '', ThreadRetInfo.ErrStr, ThreadRetInfo.HTML) then exit;

  if Pos('{', ThreadRetInfo.HTML) <> 1 then
  begin
    ThreadRetInfo.ErrStr :='请先检查脚本源码是否配置正确！';
    exit;
  end;
  FromPath := Pub.PathWithSlash(FromPath);

  Json := TminiJson.Create;
  SL := TStringlist.Create;
  SLDate := TStringlist.Create;
  SLSize := TStringlist.Create;
  try

    Json.LoadFromString(ThreadRetInfo.HTML);
    if json.S['retcode'] = '200' then
    begin
      TmpJson := json.A['list'];

      //获取要上传或删除的文件
      SL.Clear;
      SLdate.Clear;
      SLSize.Clear;
      for lp := 0 to TmpJson.length - 1 do
      begin
        RelativePath := TmpJson[lp].S['RelativePath'];
        HintMsg(lp.ToString + '/' + TmpJson.length.ToString + '正在检查文件:' + RelativePath);
        if (TmpJson[lp].S['isdir'] = '1') then
        begin
          if not DirectoryExists(FromPath + RelativePath) then
          begin
            SL.Add('@deldir@@' + RelativePath);
            SLDate.Add('');
            SLSize.Add('');
          end;
        end else
        begin
          if trim(RelativePath) = '' then Continue;
          Flag := FileExists(FromPath + RelativePath);
          if Flag then
          begin
            if (PubFile.FileGetFileTimeA(FromPath + RelativePath) = TmpJson[lp].S['FileTime']) and
               (PubFile.FileGetFileSize(FromPath + RelativePath) = TmpJson[lp].I['Size']) then
            else
            begin //需要更新的
              SL.Add('@udp@@' + RelativePath);
              SLDate.Add(TmpJson[lp].S['FileTime']);
              SLSize.Add(TmpJson[lp].S['Size']);
            end;
          end;
          if not Flag then //需要从服务器上删除的
          begin
            SL.Add('@del@@' + RelativePath);
            SLDate.Add('');
            SLSize.Add('');
          end;
        end;
      end;
      //获取要新增加文件
      GetNewFiles(FromPath);

      //ThreadRetInfo.Self.Synchronize(ThreadRetInfo.Self, procedure begin
      //  ShowMessage(SL.Text);
      //end);

      //开始上传
      FailFiles := '';
      SuccFiles := '';
      DelFiles := '';
      HintMsg('需要更新的文件共有' + IntToStr(SL.Count) + '个。。。');
      for lp := 0 to SL.Count - 1 do
      begin
        RelativePath := SL[lp];

        HintMsg(IntToStr(lp + 1) + '/' + IntToStr(SL.Count) + ', 正在处理[' + Pub.GetDeliBack(RelativePath, '@@') + ']' + '。。。');
        if Pos('@del@@', RelativePath) = 1 then
        begin //删除
          RelativePath := Pub.GetDeliBack(RelativePath, '@@');
          if not HttpPost('/接口/同步文件到服务器.html?opr=2&fn=' + UrlEncode(RelativePath),
            '', ThreadRetInfo.ErrStr, ThreadRetInfo.HTML) then
          begin
            FailFiles := FailFiles + #13#10 + RelativePath;
            exit;
          end;
          Json.LoadFromString(ThreadRetInfo.HTML);
          if json.S['retcode'] <> '200' then
          begin
            ThreadRetInfo.ErrStr := Json.S['retmsg'];
            exit;
          end;
          DelFiles := DelFiles + #13#10 + RelativePath;
        end else
        if Pos('@deldir@@', RelativePath) = 1 then
        begin //删除目录，在后面删除
        end else
        begin //上传
          RelativePath := Pub.GetDeliBack(RelativePath, '@@');
          if RelativePath[1] = '\' then RelativePath := Copy(RelativePath, 2, MaxInt);

          Fs := TFileStream.Create(FromPath + RelativePath, fmShareDenyWrite);
          MS := TMemoryStream.Create;
          try
            //先计算要分几个包，以处理进度
            Number := 0;
            HadUpSize := 0;
            AllSize := Fs.Size;
            Fs.Position := 0;
            AllBlockCount := 0;
            while true do
            begin
              AllBlockCount := AllBlockCount + 1;
              if AllSize - HadUpSize >= BlockSize then
                 MySize := BlockSize
              else
                 MySize := AllSize - HadUpSize;
              HadUpSize := HadUpSize + MySize;
              if HadUpSize >= AllSize then
                break;
            end;

            //开始分包上传
            Number := 0;
            HadUpSize := 0;
            AllSize := Fs.Size;
            Fs.Position := 0;
            ///Newfn := '@_' + ExtractFileName(RelativePath);
            Newfn := '@_' + PubPWD.GetMd5(SLDate[lp] + SLSize[lp]) + ExtractFileName(RelativePath);
            while true do
            begin
              HintMsg('正在上传文件[' + Pub.GetDeliBack(RelativePath, '@@') + ']第[' + IntToStr(Number + 1) + '/' + IntToStr(AllBlockCount) + ']个包。。。');
              MS.Clear;
              if AllSize - HadUpSize >= BlockSize then
                 MySize := BlockSize
              else
                 MySize := AllSize - HadUpSize;
              HadUpSize := HadUpSize + MySize;
              MS.CopyFrom(Fs, MySize);
              Ms.Position := 0;
              Number := Number + 1;
              if HadUpSize >= AllSize then
                isend := '1'
              else
                isend := '0';

              if isend <> '1' then
              begin //最一后个必须上传
                //先判断服务上已否已存在，存在则不上传，已支持续点
                if not HttpPost('/接口/同步文件到服务器.html?opr=6&fn=' + UrlEncode(Newfn + IntToStr(Number)),
                   '', ThreadRetInfo.ErrStr, ThreadRetInfo.HTML) then
                begin
                  FailFiles := FailFiles + #13#10 + RelativePath;
                  exit;
                end;
                Json.LoadFromString(ThreadRetInfo.HTML);
                if json.S['retcode'] = '210' then
                begin //文件存存在
                  HintMsg(Json.S['retmsg']);
                  ///Sleep(100);
                  Continue;
                end;
              end;

              if not HttpPost('/接口/同步文件到服务器.html?opr=5&fn=' + UrlEncode(Newfn + IntToStr(Number)) + '&newfn=' + UrlEncode(Newfn) +
                '&filetime=' + UrlEncode(SLDate[lp]) + '&oldfn=' + UrlEncode(RelativePath) + '&Num=' + IntToStr(Number) + '&isend=' + isend + '&i',
                 Ms, ThreadRetInfo.ErrStr, ThreadRetInfo.HTML) then
              begin
                FailFiles := FailFiles + #13#10 + RelativePath;
                exit;
              end;
              Json.LoadFromString(ThreadRetInfo.HTML);
              if json.S['retcode'] <> '200' then
              begin
                ThreadRetInfo.ErrStr := Json.S['retmsg'];
                exit;
              end;
              if isend = '1' then
                break;
            end;
          finally
            MS.Free;
            Fs.Free;
          end;
          SuccFiles := SuccFiles + #13#10 + RelativePath;
        end;
      end;
      //文件夹要最后删除，不然删除不掉的
      for lp := 0 to SL.Count - 1 do
      begin
        RelativePath := SL[lp];
        HintMsg(IntToStr(lp + 1) + '/' + IntToStr(SL.Count) + ', 正在处理[' + Pub.GetDeliBack(RelativePath, '@@') + ']' + '。。。');
        if Pos('@deldir@@', RelativePath) = 1 then
        begin //删除目录
          RelativePath := Pub.GetDeliBack(RelativePath, '@@');
          if not HttpPost('/接口/同步文件到服务器.html?opr=4&fn=' + UrlEncode(RelativePath),
            '', ThreadRetInfo.ErrStr, ThreadRetInfo.HTML) then
          begin
            FailFiles := FailFiles + #13#10 + RelativePath;
            exit;
          end;
          Json.LoadFromString(ThreadRetInfo.HTML);
          if json.S['retcode'] <> '200' then
          begin
            ThreadRetInfo.ErrStr := Json.S['retmsg'];
            exit;
          end;
          DelFiles := DelFiles + #13#10 + RelativePath;
        end;
      end;
      ThreadRetInfo.HTML := '';
      if trim(SuccFiles) <> '' then
        ThreadRetInfo.HTML := '本次上传了以下文件：'#13#10 + SuccFiles;
      if trim(DelFiles) <> '' then
        ThreadRetInfo.HTML := '本次删除了以下文件或文件夹：'#13#10 + DelFiles;
      if trim(FailFiles) <> '' then
        ThreadRetInfo.HTML := trim(ThreadRetInfo.HTML + #13#10'以下文件更新失败：'#13#10 + FailFiles);
    end;
  finally
    SLSize.Free;
    SL.Free;
    Json.Free;
    SLDate.Free;
  end;
  ThreadRetInfo.Ok := true;
end;

procedure TMainForm.SyncBlockfile_Result(var ThreadRetInfo: TThreadRetInfo);
var
  Json: TminiJson;
begin
  lblMsg.Caption := '';
  if not ThreadRetInfo.Ok then
  begin
    Pub.MsgBox('error:' + ThreadRetInfo.ErrStr + Copy(ThreadRetInfo.HTML, 1, 500));
    exit;
  end;

  if trim(ThreadRetInfo.ErrStr) <> '' then
    Pub.MsgBox(ThreadRetInfo.ErrStr)
  else
  if trim(ThreadRetInfo.HTML) <> '' then
    Pub.MsgBox(ThreadRetInfo.HTML)
  else
    Pub.MsgBox('本次没有更新！');
end;

procedure TMainForm.Image11Click(Sender: TObject);
begin
  //同步到服务器-分块
  inherited;
  CloseMore;
  lblMsg.Caption := '正在同步-分块，请稍候。。。';
  Run_Async(SyncBlockfile_Run, SyncBlockfile_Result);
end;

procedure TMainForm.UpgradeBlock_Run(var ThreadRetInfo: TThreadRetInfo);
const
  BlockSize = 1024*1024; //1M
var
  HTML, ToPath, RelativePath, FN, Tmp, TmpFileName, FailFiles, SuccFiles, Newfn, TmpToPath: string;
  Json, TmpJson: TminiJson;
  lp, I, Number, HadUpSize, AllSize, AllBlockCount, MySize: integer;
  Flag: boolean;
  SL, SLDate, SLSize: TStringlist;
  MS: TMemoryStream;
  Fs: TFileStream;
  procedure HintMsg(Msg: string);
  begin
    FMyMsg := Msg; // '正在获取文件列表。。。';
    ThreadRetInfo.Self.Synchronize(ThreadRetInfo.Self, MyUpdateface); //为什么不直接用匿名，因为laz不支持
  end;
begin
  ToPath := 'D:\superhtml'; //如果是当前程序更新  ExtractFilePath(ParamStr(0))

  ThreadRetInfo.Ok := false;

  HintMsg('正在获取文件列表。。。');
  if not HttpPost('/接口/同步文件到客户端.html?opr=1',
      '', ThreadRetInfo.ErrStr, ThreadRetInfo.HTML) then exit;
  if Pos('{', ThreadRetInfo.HTML) <> 1 then
  begin
    ThreadRetInfo.ErrStr :='请先检查脚本源码是否配置正确！';
    exit;
  end;
  ToPath := Pub.PathWithSlash(ToPath);

  Json := TminiJson.Create;
  SL := TStringlist.Create;
  SLDate := TStringlist.Create;
  SLSize := TStringlist.Create;
  try
    Json.LoadFromString(ThreadRetInfo.HTML);
    if json.S['retcode'] = '200' then
    begin
      TmpJson := json.A['list'];
      for lp := 0 to TmpJson.length - 1 do
      begin
        HintMsg(lp.ToString + '/' + TmpJson.length.ToString + '正在检查文件:' + RelativePath);
        RelativePath := TmpJson[lp].S['RelativePath'];
        if trim(RelativePath) = '' then Continue;
        Flag := FileExists(ToPath + RelativePath);
        if Flag then
        begin
          if (PubFile.FileGetFileTimeA(ToPath + RelativePath) = TmpJson[lp].S['FileTime']) and
             (PubFile.FileGetFileSize(ToPath + RelativePath) = TmpJson[lp].I['Size']) then
          else
            Flag := false;
        end;
        if not Flag then //此文件需要更新
        begin
          SL.Add(RelativePath);
          SLDate.Add(TmpJson[lp].S['FileTime']);
          SLSize.Add(TmpJson[lp].S['Size']);
        end;
      end;

      //开始下载
      FailFiles := '';
      SuccFiles := '';
      HintMsg('需要更新的文件共有' + IntToStr(SL.Count) + '个。。。');
      for lp := 0 to SL.Count - 1 do
      begin
        RelativePath := SL[lp];
        if RelativePath[1] = '\' then RelativePath := Copy(RelativePath, 2, MaxInt);
        FN := ToPath + RelativePath;
        if FileExists(FN) then
          DeleteFile(FN);
        if FileExists(FN) then //删除不掉只能改名
        begin
          Tmp := ExtractFilePath(FN) + '_Old@_' + ExtractFileName(FN);
          DeleteFile(Tmp);
          RenameFile(FN, Tmp);
        end;
        if FileExists(FN) then //删除不掉，又改名不成功，不能更新！！！！
          FailFiles := FailFiles + #13#10 + RelativePath
        else //可以下载
        begin
          //先计算要分几个包，以处理进度
          Number := 0;
          HadUpSize := 0;
          AllSize := StrToInt(SLSize[lp]);
          AllBlockCount := 0;
          while true do
          begin
            AllBlockCount := AllBlockCount + 1;
            if AllSize - HadUpSize >= BlockSize then
               MySize := BlockSize
            else
               MySize := AllSize - HadUpSize;
            HadUpSize := HadUpSize + MySize;
            if HadUpSize >= AllSize then
              break;
          end;

          //开始分包下载
          Number := 0;
          HadUpSize := 0;
          //AllSize := Fs.Size;
          TmpToPath := PubFile.FileGetTemporaryPath;
          Newfn := '@_' + PubPWD.GetMd5(SLDate[lp] + SLSize[lp]) + ExtractFileName(FN);  //Pub.GetClientUniqueCode;
          while true do
          begin
            HintMsg('正在下载文件[' + Pub.GetDeliBack(RelativePath, '@@') + ']第[' + IntToStr(Number + 1) + '/' + IntToStr(AllBlockCount) + ']个包。。。');

            if AllSize - HadUpSize >= BlockSize then
               MySize := BlockSize
            else
               MySize := AllSize - HadUpSize;
            Number := Number + 1;
            Tmp := TmpToPath + Newfn + IntToStr(Number);

            if not FileExists(Tmp) then //支持断点
            begin
              if not HttpPost('/接口/同步文件到客户端.html?opr=2&fn=' + UrlEncode(RelativePath) +
                '&pos=' + UrlEncode(IntToStr(HadUpSize)) + '&size=' + UrlEncode(IntToStr(MySize)),
                '', ThreadRetInfo.ErrStr, ThreadRetInfo.HTML, MS) then
              begin
                FailFiles := FailFiles + #13#10 + RelativePath;
                exit;
              end;
              Json.LoadFromString(ThreadRetInfo.HTML);
              if json.S['retcode'] <> '200' then
              begin
                ThreadRetInfo.ErrStr := Json.S['retmsg'];
                exit;
              end;

              if MS = nil then
              begin
                ThreadRetInfo.ErrStr := '没能下载到文件[' + RelativePath + ']！' + json.S['retmsg'];
                exit;
              end else
              begin
                MS.Position := 0;
                ForceDirectories(ExtractFilePath(Tmp));
                MS.SaveToFile(Tmp);
                MS.Free;
                MS := nil;
              end;
            end;
            HadUpSize := HadUpSize + MySize;
            if HadUpSize >= AllSize then
            begin //全部下载完成
              HintMsg('正在合并文件。。。');
              Fs := TFileStream.Create(FN, fmCreate);
              Ms := TMemoryStream.Create;
              try
                for I := 1 to AllBlockCount do
                begin
                  Tmp := TmpToPath + Newfn + IntToStr(I);
                  Ms.Clear;
                  Ms.LoadFromFile(Tmp);
                  Ms.Position := 0;
                  Fs.CopyFrom(Ms, Ms.Size);
                  DeleteFile(Tmp);
                end;
              finally
                Ms.Free;
                FS.Free;
              end;
              PubFile.FileChangeFileDate(Fn, SLDate[lp]);
              SuccFiles := SuccFiles + #13#10 + RelativePath;
              break;
            end;
          end;
        end;
      end;
      ThreadRetInfo.HTML := '';
      if trim(SuccFiles) <> '' then
        ThreadRetInfo.HTML := '本次更新了以下文件：'#13#10 + SuccFiles;
      if trim(FailFiles) <> '' then
        ThreadRetInfo.HTML := trim(ThreadRetInfo.HTML + #13#10'以下文件更新失败：'#13#10 + FailFiles);
    end;
  finally
    SLSize.Free;
    SL.Free;
    Json.Free;
    SLDate.Free;
  end;
  ThreadRetInfo.Ok := true;
end;

procedure TMainForm.UpgradeBlock_Result(var ThreadRetInfo: TThreadRetInfo);
var
  Json: TminiJson;
begin
  lblMsg.Caption := '';
  if not ThreadRetInfo.Ok then
  begin
    Pub.MsgBox('error:' + ThreadRetInfo.ErrStr);
    exit;
  end;
  if trim(ThreadRetInfo.HTML) <> '' then
    Pub.MsgBox(ThreadRetInfo.HTML)
  else
    Pub.MsgBox('本次没有更新！');
end;
procedure TMainForm.Image12Click(Sender: TObject);
begin //同步下载-分块
  inherited;
  CloseMore;
  lblMsg.Caption := '正在升级，请稍候。。。';
  Run_Async(UpgradeBlock_Run, UpgradeBlock_Result);
end;

end.
