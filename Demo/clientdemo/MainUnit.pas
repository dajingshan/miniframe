unit MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, baseformUnit, Vcl.StdCtrls, clientpub,
  Vcl.ExtCtrls, HuoPubFuncUnit, DataPackageUnit, Data.DB, Vcl.Grids, Shellapi,
  Vcl.DBGrids, MemDS, VirtualTable, minicomponents, math, minijson2dataset, loginUnit,
  acPNG, PubFileUnit, dxGDIPlusClasses, PubPWDUnit;

type
  TPageInfo = record
    pn, recordcount, pagecount, maxpagecount: string;
    readtype: string;
  end;
  TMainForm = class(Tbaseform)
    DBGrid1: TDBGrid;
    Panel2: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    DataSource1: TDataSource;
    VirtualTable1: TVirtualTable;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    lblinfo: TLabel;
    lblMsg: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    plleft: TPanel;
    Label1: TLabel;
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
    plMore: TPanel;
    Label26: TLabel;
    Panel16: TPanel;
    Panel10: TPanel;
    Label25: TLabel;
    Panel11: TPanel;
    Panel14: TPanel;
    Image10: TImage;
    Label28: TLabel;
    Panel17: TPanel;
    Panel12: TPanel;
    Image8: TImage;
    Label27: TLabel;
    Label32: TLabel;
    Image9: TImage;
    Panel13: TPanel;
    Image11: TImage;
    Label30: TLabel;
    Label29: TLabel;
    Panel15: TPanel;
    Image12: TImage;
    Label31: TLabel;
    procedure FormCreate(Sender: TObject);
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
    procedure Label27Click(Sender: TObject);
    procedure Image9Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Image10Click(Sender: TObject);
    procedure Image11Click(Sender: TObject);
    procedure Image12Click(Sender: TObject);
  private
    //FMsdata: TMemoryStream;
    //FJsondata, FUpFileName: string;
    FMyMsg: string;
    FHadExit: boolean;
    FPageInfo: TPageInfo;
    procedure ReadOnePage();
    procedure ReaOnePage_Run(var ThreadRetInfo: TThreadRetInfo);
    procedure ReaOnePage_Result(var ThreadRetInfo: TThreadRetInfo);
    procedure SaveOnePage_Json_Result(var ThreadRetInfo: TThreadRetInfo);
    procedure SaveOnePage_Json_Run(var ThreadRetInfo: TThreadRetInfo);
    procedure SaveOnePage_Stream_Result(var ThreadRetInfo: TThreadRetInfo);
    procedure SaveOnePage_Stream_Run(var ThreadRetInfo: TThreadRetInfo);
    procedure Upfile_Result(var ThreadRetInfo: TThreadRetInfo);
    procedure Upfile_Run(var ThreadRetInfo: TThreadRetInfo);
    procedure IniData;
    procedure LoginOut(NeedLogin: string = '');
    procedure LoginOut_Result(var ThreadRetInfo: TThreadRetInfo);
    procedure LoginOut_Run(var ThreadRetInfo: TThreadRetInfo);
    procedure Downfile_Result(var ThreadRetInfo: TThreadRetInfo);
    procedure Downfile_Run(var ThreadRetInfo: TThreadRetInfo);
    procedure Upgrade_Run(var ThreadRetInfo: TThreadRetInfo);
    procedure Upgrade_Result(var ThreadRetInfo: TThreadRetInfo);
    procedure MyUpdateface;
    procedure AppMsg(var Msg: TMsg; var Handled: Boolean);
    procedure CloseMore;
    procedure Syncfile_Result(var ThreadRetInfo: TThreadRetInfo);
    procedure Syncfile_Run(var ThreadRetInfo: TThreadRetInfo);
    procedure SyncBlockfile_Result(var ThreadRetInfo: TThreadRetInfo);
    procedure SyncBlockfile_Run(var ThreadRetInfo: TThreadRetInfo);
    procedure UpgradeBlock_Result(var ThreadRetInfo: TThreadRetInfo);
    procedure UpgradeBlock_Run(var ThreadRetInfo: TThreadRetInfo);
    { Private declarations }
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
begin //����������,�ύ��������
  inherited;

  //�첽��ʽ��Ϊʲô���������������أ���laz��֧�֣�Ϊ��ͨ��
  lblMsg.Caption := '���ڱ����' + FPageInfo.pn + 'ҳ���ݡ�����';

  InParams.obj1 := TMemoryStream.Create;
  VirtualTable1.SaveToStream(TStream(InParams.obj1));
  Run_Async(InParams, SaveOnePage_Stream_Run, SaveOnePage_Stream_Result);

  {
  Ms := TMemoryStream.Create;
  Json := TminiJson.Create;
  try
    //ע�⣬������������ laz,�ͻ�����VirtualTable1.SaveToStream�ᱨ��Ӧ����unidac�����⣬�������ͻ��˶���delphiû�������
    VirtualTable1.SaveToStream(Ms);
    if not HttpPost('/�ӿ�/�����û�����.html', Ms, ErrStr, HTML) then
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
begin //�ϴ��ļ�
  inherited;
  if not OpenDialog1.Execute(Handle) then exit;
  InParams.P1 := OpenDialog1.FileName;
  //�첽��ʽ��Ϊʲô���������������أ���laz��֧�֣�Ϊ��ͨ��, ���ֻ��delphi���ã������������Ƚϼ�
  lblMsg.Caption := '�����ϴ��ļ�' + InParams.P1 + '������';

  Run_Async(InParams, Upfile_Run, Upfile_Result);
end;

procedure TMainForm.Image7Click(Sender: TObject);
begin //�����ļ�
  inherited;
  lblMsg.Caption := '���������ļ������Ժ򡣡���';
  Run_Async(Downfile_Run, Downfile_Result);
end;

procedure TMainForm.Image9Click(Sender: TObject);
begin
  inherited;
  CloseMore;
end;

procedure TMainForm.IniData;
begin
  FPageInfo.pn := '1';
  lblinfo.Caption := '��ã���ӭ ' + FClientPubinfo.username;
  FPageInfo.readtype := '2';
  ReadOnePage();
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  if not FHadExit then
    LoginOut();
end;

procedure TMainForm.AppMsg(var Msg: TMsg; var Handled: Boolean);
var
  Flag: boolean;
  procedure FindHandle(Win: TWinControl);
  var
    i:integer;
  begin
    if Win.Handle = msg.hwnd then
    begin
      Flag := true;
      exit;
    end;
    for I := 0 to Win.ControlCount - 1 do
    begin
      if Win.Controls[I] is TWinControl then
        FindHandle(TWinControl(Win.Controls[I]));
    end;
  end;
begin
  case Msg.message of
    WM_LBUTTONDOWN:
    begin
      Flag := false;
      FindHandle(plMore);
      if not Flag then
        CloseMore;
    end;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Application.OnMessage:=AppMsg;
  FHadExit := false;
  IniData;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  inherited;
  plMore.Left := (Width - plMore.Width) div 2;
  plMore.Height := (Height - plMore.Height) div 2;
end;

procedure TMainForm.ReaOnePage_Run(var ThreadRetInfo: TThreadRetInfo);
var
  PostSL: TStringList;
begin
  ThreadRetInfo.Ok := false;
  //�ύ�����ݴ�� ��  PostSL.Values[name] = value;
  PostSL := TStringList.Create;
  try
    PostSL.Values['readtype'] := FPageInfo.readtype;
    PostSL.Values['pn'] := FPageInfo.pn;
    PostSL.Values['pagecount'] := '20';

    if not HttpPost('/�ӿ�/��ҳ��ȡ�û�.html', PostSL, ThreadRetInfo.ErrStr, ThreadRetInfo.HTML, ThreadRetInfo.OutStream) then exit;
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
  begin //��Json����
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
  end else //�Զ�����������
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

  //�첽��ʽ��Ϊʲô���������������أ���laz��֧�֣�Ϊ��ͨ��
  lblMsg.Caption := '���ڶ�ȡ��' + FPageInfo.pn + 'ҳ���ݡ�����';
  Run_Async(ReaOnePage_Run, ReaOnePage_Result);

  {������ʽ
  //�ύ�����ݴ�� ��  PostSL.Values[name] = value;
  PostSL := TStringList.Create;
  try
    PostSL.Values['readtype'] := readtype;
    PostSL.Values['pn'] := pn;
    PostSL.Values['pagecount'] := '20';

    if not HttpPost('/�ӿ�/��ҳ��ȡ�û�.html', PostSL, ErrStr, HTML, MS) then
    begin
      Pub.MsgBox(ErrStr);
      exit;
    end;
  finally
    PostSL.Free;
  end;

  if readtype = '2' then
  begin //��Json����
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
  end else //�Զ�����������
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
  if not HttpPost('/�ӿ�/�˳���¼.html', '', ThreadRetInfo.ErrStr, ThreadRetInfo.HTML, ThreadRetInfo.OutStream) then exit;
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
  lblMsg.Caption := '�����˳���¼�����Ժ�...';
  InParam.P1 := NeedLogin;
  Run_Async(InParam, LoginOut_Run, LoginOut_Result);

  if NeedLogin <> '1' then
  begin
    //����3��ֱ���˳�;
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
begin //����������-�ύJson���ݼ�
  inherited;

  //�첽��ʽ��Ϊʲô���������������أ���laz��֧�֣�Ϊ��ͨ��
  lblMsg.Caption := '���ڱ����' + FPageInfo.pn + 'ҳ���ݡ�����';

  //��ȡJson����
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

  {������ʽ
  Json := TminiJson.Create;
  VirtualTable1.DisableControls;
  bk := VirtualTable1.GetBookmark;
  try

    if not HttpPost('/�ӿ�/�����û�����.html?savetype=2', DataSet2Json(VirtualTable1), ErrStr, HTML) then
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

procedure TMainForm.CloseMore;
begin
  plMore.Visible := false;
end;

procedure TMainForm.Label27Click(Sender: TObject);
begin
  inherited;
  plMore.Visible := true;
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
  //�������� FJsondata := DataSet2Json(VirtualTable1); //�߳��ﲻ��ֱ�ӷ������̵߳�����
  ThreadRetInfo.Ok := false;
  if not HttpPost('/�ӿ�/�����û�����.html', TStream(ThreadRetInfo.InParams.obj1), ThreadRetInfo.ErrStr, ThreadRetInfo.HTML) then exit;
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
  //�������� FJsondata := DataSet2Json(VirtualTable1); //�߳��ﲻ��ֱ�ӷ������̵߳�����
  ThreadRetInfo.Ok := false;
  if not HttpPost('/�ӿ�/�����û�����.html?savetype=2', ThreadRetInfo.InParams.P1, ThreadRetInfo.ErrStr, ThreadRetInfo.HTML) then exit;
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
    if not HttpPost('/�ӿ�/�ϴ��������ļ�.html?opr=1&fn=' + UrlEncode(ExtractFileName(ThreadRetInfo.InParams.p1)),
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
  if not HttpPost('/�ӿ�/�ϴ��������ļ�.html?opr=2&fn=',
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
    if not SaveDialog1.Execute(Handle) then exit;
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
    FMyMsg := Msg; // '���ڻ�ȡ�ļ��б�����';
    ThreadRetInfo.Self.Synchronize(ThreadRetInfo.Self, MyUpdateface); //Ϊʲô��ֱ������������Ϊlaz��֧��
  end;
begin
  ToPath := 'D:\superhtml'; //����ǵ�ǰ�������  ExtractFilePath(ParamStr(0))

  ThreadRetInfo.Ok := false;

  HintMsg('���ڻ�ȡ�ļ��б�����');
  if not HttpPost('/�ӿ�/�������������ļ�.html?opr=1',
      '', ThreadRetInfo.ErrStr, ThreadRetInfo.HTML) then exit;
  if Pos('{', ThreadRetInfo.HTML) <> 1 then
  begin
    ThreadRetInfo.ErrStr :='���ȼ��ű�Դ���Ƿ�������ȷ��';
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
        HintMsg(lp.ToString + '/' + TmpJson.length.ToString + '���ڼ���ļ�:' + RelativePath);
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
        if not Flag then //���ļ���Ҫ����
        begin
          SL.Add(RelativePath);
          SLDate.Add(TmpJson[lp].S['FileTime']);
        end;
      end;

      //��ʼ����
      FailFiles := '';
      SuccFiles := '';
      HintMsg('��Ҫ���µ��ļ�����' + IntToStr(SL.Count) + '��������');
      for lp := 0 to SL.Count - 1 do
      begin
        RelativePath := SL[lp];
        if RelativePath[1] = '\' then RelativePath := Copy(RelativePath, 2, MaxInt);
        //MS := TMemoryStream.Create;
        try
          HintMsg(IntToStr(lp + 1) + '/' + IntToStr(SL.Count) + ', ��������[' + RelativePath + ']' + '������');
          if not HttpPost('/�ӿ�/�������������ļ�.html?opr=2',
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

            //��ѹ��ָ��Ŀ¼
            ForceDirectories(ExtractFilePath(FN));
            if FileExists(FN) then
              DeleteFile(FN);
            if FileExists(FN) then //ɾ������ֻ�ܸ���
            begin
              Tmp := ExtractFilePath(FN) + '_Old@_' + ExtractFileName(FN);
              DeleteFile(Tmp);
              RenameFile(FN, Tmp);
            end;
            if FileExists(FN) then //ɾ���������ָ������ɹ������ܸ��£�������
              FailFiles := FailFiles + #13#10 + RelativePath
            else
            begin
              UnZipFileToFolder(TmpFileName, ExtractFilePath(FN));
              if FileExists(FN) then
              begin
                SuccFiles := SuccFiles + #13#10 + RelativePath;
                //��Ȼ�ǽ�ѹ�����ļ����޸ı���Ҫ���ã�������ܻ�������
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
        ThreadRetInfo.HTML := '���θ����������ļ���'#13#10 + SuccFiles;
      if trim(FailFiles) <> '' then
        ThreadRetInfo.HTML := trim(ThreadRetInfo.HTML + #13#10'�����ļ�����ʧ�ܣ�'#13#10 + FailFiles);
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
    Pub.MsgBox('����û�и��£�');
end;

procedure TMainForm.Image6Click(Sender: TObject);
begin //�������������ļ�
  inherited;
  lblMsg.Caption := '�������������Ժ򡣡���';
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
    FMyMsg := Msg; // '���ڻ�ȡ�ļ��б�����';
    ThreadRetInfo.Self.Synchronize(ThreadRetInfo.Self, MyUpdateface); //Ϊʲô��ֱ������������Ϊlaz��֧��
  end;
  procedure GetNewFiles(sDir: string);
  var
    SearchRec: System.SysUtils.TSearchRec;
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
            HintMsg(lp.ToString + '/' + TmpJson.length.ToString + '���ڼ���ļ�:' + RelativePath);
            if (TmpJson[lp].S['isdir'] <> '1') and (LowerCase(RelativePath) = LowerCase(TmpJson[lp].S['RelativePath'])) then
            begin
              Flag := true;
              break;
            end;
          end;
          if not Flag then
          begin //��Ҫ�ڷ���������
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
  FromPath := 'D:\ͬ������\����'; //�������ļ�ͬ����������

  ThreadRetInfo.Ok := false;

  HintMsg('���ڻ�ȡ�ļ��б�����');
  if not HttpPost('/�ӿ�/ͬ���ļ���������.html?opr=1',
      '', ThreadRetInfo.ErrStr, ThreadRetInfo.HTML) then exit;

  if Pos('{', ThreadRetInfo.HTML) <> 1 then
  begin
    ThreadRetInfo.ErrStr :='���ȼ��ű�Դ���Ƿ�������ȷ��';
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

      //��ȡҪ�ϴ���ɾ�����ļ�
      SL.Clear;
      SLdate.Clear;
      for lp := 0 to TmpJson.length - 1 do
      begin
        RelativePath := TmpJson[lp].S['RelativePath'];
        HintMsg(lp.ToString + '/' + TmpJson.length.ToString + '���ڼ���ļ�:' + RelativePath);
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
            begin //��Ҫ���µ�
              SL.Add('@udp@@' + RelativePath);
              SLDate.Add(TmpJson[lp].S['FileTime']);
            end;
          end;
          if not Flag then //��Ҫ�ӷ�������ɾ����
          begin
            SL.Add('@del@@' + RelativePath);
            SLDate.Add('');
          end;
        end;
      end;
      //��ȡҪ�������ļ�
      GetNewFiles(FromPath);

      //ThreadRetInfo.Self.Synchronize(ThreadRetInfo.Self, procedure begin
      //  ShowMessage(SL.Text);
      //end);

      //��ʼ�ϴ�
      FailFiles := '';
      SuccFiles := '';
      DelFiles := '';
      HintMsg('��Ҫ���µ��ļ�����' + IntToStr(SL.Count) + '��������');
      for lp := 0 to SL.Count - 1 do
      begin
        RelativePath := SL[lp];

        HintMsg(IntToStr(lp + 1) + '/' + IntToStr(SL.Count) + ', ���ڴ���[' + Pub.GetDeliBack(RelativePath, '@@') + ']' + '������');
        if Pos('@del@@', RelativePath) = 1 then
        begin //ɾ��
          RelativePath := Pub.GetDeliBack(RelativePath, '@@');
          if not HttpPost('/�ӿ�/ͬ���ļ���������.html?opr=2&fn=' + UrlEncode(RelativePath),
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
        begin //ɾ��Ŀ¼���ں���ɾ��
        end else
        begin //�ϴ�
          RelativePath := Pub.GetDeliBack(RelativePath, '@@');
          if RelativePath[1] = '\' then RelativePath := Copy(RelativePath, 2, MaxInt);
          Fs := TFileStream.Create(FromPath + RelativePath, fmShareDenyWrite);
          try
            if not HttpPost('/�ӿ�/ͬ���ļ���������.html?opr=3&fn=' + UrlEncode(RelativePath) + '&filetime=' + UrlEncode(SLDate[lp]),
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
      //�ļ���Ҫ���ɾ������Ȼɾ��������
      for lp := 0 to SL.Count - 1 do
      begin
        RelativePath := SL[lp];
        HintMsg(IntToStr(lp + 1) + '/' + IntToStr(SL.Count) + ', ���ڴ���[' + Pub.GetDeliBack(RelativePath, '@@') + ']' + '������');
        if Pos('@deldir@@', RelativePath) = 1 then
        begin //ɾ��Ŀ¼
          RelativePath := Pub.GetDeliBack(RelativePath, '@@');
          if not HttpPost('/�ӿ�/ͬ���ļ���������.html?opr=4&fn=' + UrlEncode(RelativePath),
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
        ThreadRetInfo.HTML := '�����ϴ��������ļ���'#13#10 + SuccFiles;
      if trim(DelFiles) <> '' then
        ThreadRetInfo.HTML := '����ɾ���������ļ����ļ��У�'#13#10 + DelFiles;
      if trim(FailFiles) <> '' then
        ThreadRetInfo.HTML := trim(ThreadRetInfo.HTML + #13#10'�����ļ�����ʧ�ܣ�'#13#10 + FailFiles);
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
    Pub.MsgBox('����û�и��£�');
end;

procedure TMainForm.Image10Click(Sender: TObject);
begin //ͬ����������
  inherited;
  CloseMore;
  lblMsg.Caption := '����ͬ�������Ժ򡣡���';
  Run_Async(Syncfile_Run, Syncfile_Result);
end;

procedure TMainForm.SyncBlockfile_Run(var ThreadRetInfo: TThreadRetInfo);
const
  BlockSize = 1024*1024; //1M
var
  HTML, FromPath, RelativePath, FN, Newfn, isend, TmpFileName, FailFiles, SuccFiles, DelFiles, s, d: string;
  Json, TmpJson: TminiJson;
  lp,  I, Number, HadUpSize, AllSize, MySize, AllBlockCount, MyNumber: int64;
  Flag: boolean;
  SL, SLDate, SLSize, SLOldDateSize: TStringlist;
  MS: TMemoryStream;
  Fs: TFileStream;
  procedure HintMsg(Msg: string);
  begin
    FMyMsg := Msg; // '���ڻ�ȡ�ļ��б�����';
    ThreadRetInfo.Self.Synchronize(ThreadRetInfo.Self, MyUpdateface); //Ϊʲô��ֱ������������Ϊlaz��֧��
  end;
  procedure GetNewFiles(sDir: string);
  var
    SearchRec: System.SysUtils.TSearchRec;
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
            HintMsg(lp.ToString + '/' + TmpJson.length.ToString + '���ڼ���ļ�:' + RelativePath);
            if (TmpJson[lp].S['isdir'] <> '1') and (LowerCase(RelativePath) = LowerCase(TmpJson[lp].S['RelativePath'])) then
            begin
              Flag := true;
              break;
            end;
          end;
          if not Flag then
          begin //��Ҫ�ڷ���������
            SL.Add('@add@@' + RelativePath);
            D := PubFile.FileGetFileTimeA(FromPath + RelativePath);
            S := PubFile.FileGetFileSize(FromPath + RelativePath).ToString;
            SLDate.Add(D);
            SLSize.Add(S);
            SLOldDateSize.Add(D + S);
          end;
        end;
        Status := FindNext(SearchRec);
      end;
    finally
      FindClose(SearchRec);
    end;
  end;
begin
  FromPath := 'D:\ͬ������\����'; //�������ļ�ͬ����������

  ThreadRetInfo.Ok := false;

  HintMsg('���ڻ�ȡ�ļ��б�����');
  if not HttpPost('/�ӿ�/ͬ���ļ���������.html?opr=1',
      '', ThreadRetInfo.ErrStr, ThreadRetInfo.HTML) then exit;

  if Pos('{', ThreadRetInfo.HTML) <> 1 then
  begin
    ThreadRetInfo.ErrStr :='���ȼ��ű�Դ���Ƿ�������ȷ��';
    exit;
  end;
  FromPath := Pub.PathWithSlash(FromPath);

  Json := TminiJson.Create;
  SL := TStringlist.Create;
  SLDate := TStringlist.Create;
  SLSize := TStringlist.Create;
  SLOldDateSize := TStringlist.Create;
  try
    { html := ThreadRetInfo.html;
     ThreadRetInfo.Self.Synchronize(ThreadRetInfo.Self, procedure begin
        ShowMessage(Copy(HTML, 1, 2000));
      end);
    exit;}
    Json.LoadFromString(ThreadRetInfo.HTML);

    if json.S['retcode'] = '200' then
    begin
      TmpJson := json.A['list'];

      //��ȡҪ�ϴ���ɾ�����ļ�
      SL.Clear;
      SLdate.Clear;
      SLSize.Clear;
      SLOldDateSize.Clear;
      for lp := 0 to TmpJson.length - 1 do
      begin
        RelativePath := TmpJson[lp].S['RelativePath'];
        HintMsg(lp.ToString + '/' + TmpJson.length.ToString + '���ڼ���ļ�:' + RelativePath);
        if (TmpJson[lp].S['isdir'] = '1') then
        begin
          if not DirectoryExists(FromPath + RelativePath) then
          begin
            SL.Add('@deldir@@' + RelativePath);
            SLDate.Add('');
            SLSize.Add('');
            SLOldDateSize.Add('');
          end;
        end else
        begin
          if trim(RelativePath) = '' then Continue;
          Flag := FileExists(FromPath + RelativePath);
          if Flag then
          begin
            D := PubFile.FileGetFileTimeA(FromPath + RelativePath);
            S := PubFile.FileGetFileSize(FromPath + RelativePath).ToString;
            if (D = TmpJson[lp].S['FileTime']) and
               (StrToInt64(S) = TmpJson[lp].I['Size']) then
            else
            begin //��Ҫ���µ�
              SL.Add('@udp@@' + RelativePath);
              //SLDate.Add(TmpJson[lp].S['FileTime']);
              //SLSize.Add(TmpJson[lp].S['Size']);
              SLDate.Add(D);
              SLSize.Add(S);
              SLOldDateSize.Add(D + S);
            end;
          end;
          if not Flag then //��Ҫ�ӷ�������ɾ����
          begin
            SL.Add('@del@@' + RelativePath);
            SLDate.Add('');
            SLSize.Add('');
          end;
        end;
      end;
      //��ȡҪ�������ļ�
      GetNewFiles(FromPath);

      //ThreadRetInfo.Self.Synchronize(ThreadRetInfo.Self, procedure begin
      //  ShowMessage(SL.Text);
      //end);

      //��ʼ�ϴ�
      FailFiles := '';
      SuccFiles := '';
      DelFiles := '';
      HintMsg('��Ҫ���µ��ļ�����' + IntToStr(SL.Count) + '��������');
      for lp := 0 to SL.Count - 1 do
      begin
        RelativePath := SL[lp];

        HintMsg(IntToStr(lp + 1) + '/' + IntToStr(SL.Count) + ', ���ڴ���[' + Pub.GetDeliBack(RelativePath, '@@') + ']' + '������');
        if Pos('@del@@', RelativePath) = 1 then
        begin //ɾ��
          RelativePath := Pub.GetDeliBack(RelativePath, '@@');
          if not HttpPost('/�ӿ�/ͬ���ļ���������.html?opr=2&fn=' + UrlEncode(RelativePath),
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
        begin //ɾ��Ŀ¼���ں���ɾ��
        end else
        begin //�ϴ�
          RelativePath := Pub.GetDeliBack(RelativePath, '@@');
          if RelativePath[1] = '\' then RelativePath := Copy(RelativePath, 2, MaxInt);

          Fs := TFileStream.Create(FromPath + RelativePath, fmShareDenyWrite);
          MS := TMemoryStream.Create;
          try
            //�ȼ���Ҫ�ּ��������Դ������
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

            //��ʼ�ְ��ϴ�
            Number := 0;
            HadUpSize := 0;
            AllSize := Fs.Size;
            Fs.Position := 0;
            Newfn := '@_' + PubPWD.GetMd5(SLOldDateSize[lp]) + ExtractFileName(RelativePath);

            //�Ҷϵ�
            if not HttpPost('/�ӿ�/ͬ���ļ���������.html?opr=6' + '&newfn=' + UrlEncode(Newfn) ,
               '', ThreadRetInfo.ErrStr, ThreadRetInfo.HTML) then
            begin
              FailFiles := FailFiles + #13#10 + RelativePath;
              exit;
            end;
            MyNumber := 0;
            Json.LoadFromString(ThreadRetInfo.HTML);
            if json.S['retcode'] = '210' then
              MyNumber := StrToInt64(json.S['pos']);

            while true do
            begin
              HintMsg('�����ϴ��ļ�[' + Pub.GetDeliBack(RelativePath, '@@') + ']��[' + IntToStr(Number + 1) + '/' + IntToStr(AllBlockCount) + ']����������');
              if AllSize - HadUpSize >= BlockSize then
                 MySize := BlockSize
              else
                 MySize := AllSize - HadUpSize;
              HadUpSize := HadUpSize + MySize;
              Number := Number + 1;
              if HadUpSize >= AllSize then
                isend := '1'
              else
                isend := '0';


              if (MyNumber = 0) or (isend = '1') or (Number >= MyNumber) then
              begin
                for I := 1 to 2 do //Ҳ������һ��
                begin
                  MS.Clear;
                  MS.CopyFrom(Fs, MySize);
                  Ms.Position := 0;

                  if not HttpPost('/�ӿ�/ͬ���ļ���������.html?opr=5&fn=' + UrlEncode(Newfn + IntToStr(Number)) + '&newfn=' + UrlEncode(Newfn) +
                    '&filetime=' + UrlEncode(SLDate[lp]) + '&oldfn=' + UrlEncode(RelativePath) + '&Num=' + IntToStr(Number) +
                    '&pos=' + IntToStr(HadUpSize - MySize) +'&size=' + IntToStr(AllSize) +
                    '&isend=' + isend + '&i',
                     Ms, ThreadRetInfo.ErrStr, ThreadRetInfo.HTML) then
                  begin
                    if I = 2 then
                    begin
                      ThreadRetInfo.ErrStr := Json.S['retmsg'];
                      exit;
                    end else
                      Continue;
                  end;
                  if Pos('{', ThreadRetInfo.HTML) < 1 then
                  begin
                    if I = 2 then
                    begin
                      ThreadRetInfo.ErrStr := Json.S['retmsg'];
                      exit;
                    end else
                      Continue;
                  end;

                  Json.LoadFromString(ThreadRetInfo.HTML);
                  if json.S['retcode'] <> '200' then
                  begin
                    if I = 2 then
                    begin
                      ThreadRetInfo.ErrStr := Json.S['retmsg'];
                      exit;
                    end else
                      Continue;
                  end;
                  break;
                end;
              end else
                Fs.Position := FS.Position + MySize;
              if isend = '1' then
              begin
                break;
              end;
            end;
          finally
            MS.Free;
            Fs.Free;
          end;
          SuccFiles := SuccFiles + #13#10 + RelativePath;
        end;
      end;
      //�ļ���Ҫ���ɾ������Ȼɾ��������
      for lp := 0 to SL.Count - 1 do
      begin
        RelativePath := SL[lp];
        HintMsg(IntToStr(lp + 1) + '/' + IntToStr(SL.Count) + ', ���ڴ���[' + Pub.GetDeliBack(RelativePath, '@@') + ']' + '������');
        if Pos('@deldir@@', RelativePath) = 1 then
        begin //ɾ��Ŀ¼
          RelativePath := Pub.GetDeliBack(RelativePath, '@@');
          if not HttpPost('/�ӿ�/ͬ���ļ���������.html?opr=4&fn=' + UrlEncode(RelativePath),
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
        ThreadRetInfo.HTML := '�����ϴ��������ļ���'#13#10 + SuccFiles;
      if trim(DelFiles) <> '' then
        ThreadRetInfo.HTML := '����ɾ���������ļ����ļ��У�'#13#10 + DelFiles;
      //if trim(FailFiles) <> '' then
        //ThreadRetInfo.HTML := trim(ThreadRetInfo.HTML + #13#10'�����ļ�����ʧ�ܣ�'#13#10 + FailFiles);
    end;
  finally
    SLOldDateSize.Free;
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
    Pub.MsgBox('����û�и��£�');
end;

procedure TMainForm.Image11Click(Sender: TObject);
begin
  //ͬ����������-�ֿ�
  inherited;
  CloseMore;
  lblMsg.Caption := '����ͬ��-�ֿ飬���Ժ򡣡���';
  Run_Async(SyncBlockfile_Run, SyncBlockfile_Result);
end;

procedure TMainForm.UpgradeBlock_Run(var ThreadRetInfo: TThreadRetInfo);
const
  BlockSize = 1024*1024; //1M
var
  HTML, ToPath, RelativePath, FN, Tmp, TmpFileName, FailFiles, SuccFiles, Newfn, TmpToPath: string;
  Json, TmpJson: TminiJson;
  lp, I, Number, HadUpSize, AllSize, AllBlockCount, MySize, MyNumber: Int64;
  Flag: boolean;
  SL, SLDate, SLSize, SLTmp: TStringlist;
  MS: TMemoryStream;
  Fs: TFileStream;
  procedure HintMsg(Msg: string);
  begin
    FMyMsg := Msg; // '���ڻ�ȡ�ļ��б�����';
    ThreadRetInfo.Self.Synchronize(ThreadRetInfo.Self, MyUpdateface); //Ϊʲô��ֱ������������Ϊlaz��֧��
  end;
begin
  ToPath := 'D:\superhtml'; //����ǵ�ǰ�������  ExtractFilePath(ParamStr(0))

  ThreadRetInfo.Ok := false;

  HintMsg('���ڻ�ȡ�ļ��б�����');
  if not HttpPost('/�ӿ�/ͬ���ļ����ͻ���.html?opr=1',
      '', ThreadRetInfo.ErrStr, ThreadRetInfo.HTML) then exit;
  if Pos('{', ThreadRetInfo.HTML) <> 1 then
  begin
    ThreadRetInfo.ErrStr :='���ȼ��ű�Դ���Ƿ�������ȷ��';
    exit;
  end;
  ToPath := Pub.PathWithSlash(ToPath);

  Json := TminiJson.Create;
  SL := TStringlist.Create;
  SLDate := TStringlist.Create;
  SLSize := TStringlist.Create;
  SLTmp := TStringlist.Create;
  try
    Json.LoadFromString(ThreadRetInfo.HTML);
    if json.S['retcode'] = '200' then
    begin
      TmpJson := json.A['list'];
      for lp := 0 to TmpJson.length - 1 do
      begin
        HintMsg(lp.ToString + '/' + TmpJson.length.ToString + '���ڼ���ļ�:' + RelativePath);
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
        if not Flag then //���ļ���Ҫ����
        begin
          SL.Add(RelativePath);
          SLDate.Add(TmpJson[lp].S['FileTime']);
          SLSize.Add(TmpJson[lp].S['Size']);
        end;
      end;

      //��ʼ����
      FailFiles := '';
      SuccFiles := '';
      HintMsg('��Ҫ���µ��ļ�����' + IntToStr(SL.Count) + '��������');
      for lp := 0 to SL.Count - 1 do
      begin
        RelativePath := SL[lp];
        if RelativePath[1] = '\' then RelativePath := Copy(RelativePath, 2, MaxInt);
        FN := ToPath + RelativePath;

        //�ȼ���Ҫ�ּ��������Դ������
        Number := 0;
        HadUpSize := 0;
        AllSize := StrToInt64(SLSize[lp]);
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

        //��ʼ�ְ�����
        Number := 0;
        HadUpSize := 0;
        //AllSize := Fs.Size;
        //TmpToPath := PubFile.FileGetTemporaryPath;
        Newfn := '@_' + PubPWD.GetMd5(SLDate[lp] + SLSize[lp]) + ExtractFileName(FN);  //Pub.GetClientUniqueCode;

        if FileExists(ToPath + Newfn) and (FileExists(FN)) then
        begin
          SLTmp.LoadFromFile(ToPath + Newfn);
          MyNumber := StrToInt64(trim(SLTmp.Text));
          Fs := TFileStream.Create(FN, fmOpenWrite);
        end else
        begin
          MyNumber := 0;
          Fs := TFileStream.Create(FN, fmCreate);
        end;
        try
          while true do
          begin
            HintMsg('���������ļ�[' + Pub.GetDeliBack(RelativePath, '@@') + ']��[' + IntToStr(Number + 1) + '/' + IntToStr(AllBlockCount) + ']����������');

            if AllSize - HadUpSize >= BlockSize then
               MySize := BlockSize
            else
               MySize := AllSize - HadUpSize;
            Number := Number + 1;
            if (MyNumber = 0) or (Number >= MyNumber) or (HadUpSize + MySize >= AllSize) then
            begin
              for I := 1 to 2 do //�����������һ��
              begin
                if not HttpPost('/�ӿ�/ͬ���ļ����ͻ���.html?opr=2&fn=' + UrlEncode(RelativePath) +
                  '&pos=' + UrlEncode(IntToStr(HadUpSize)) + '&size=' + UrlEncode(IntToStr(MySize)),
                  '', ThreadRetInfo.ErrStr, ThreadRetInfo.HTML, MS) then
                begin
                  if I = 2 then
                  begin
                    ThreadRetInfo.ErrStr := Json.S['retmsg'];
                    exit;
                  end else
                    Continue;
                end;
                if Pos('{', ThreadRetInfo.HTML) < 1 then
                begin
                  if I = 2 then
                  begin
                    ThreadRetInfo.ErrStr := Json.S['retmsg'];
                    exit;
                  end else
                    Continue;
                end;

                Json.LoadFromString(ThreadRetInfo.HTML);
                if json.S['retcode'] <> '200' then
                begin
                  if I = 2 then
                  begin
                    ThreadRetInfo.ErrStr := Json.S['retmsg'];
                    exit;
                  end else
                    Continue;
                end;
                break;
              end;

              if MS = nil then
              begin
                ThreadRetInfo.ErrStr := 'û�����ص��ļ�[' + RelativePath + ']��' + json.S['retmsg'];
                exit;
              end else
              begin
                Fs.Position := HadUpSize;
                MS.Position := 0;
                Fs.CopyFrom(MS, MS.Size);
                MS.Free;
                MS := nil;
                SLTmp.Text := Number.ToString;
                try
                  SLTmp.SaveToFile(ToPath + Newfn);
                except
                end;
              end;
            end;
            HadUpSize := HadUpSize + MySize;

            if HadUpSize >= AllSize then
            begin //ȫ���������
              Fs.Free;
              Fs := nil;
              Sleep(10);
              PubFile.FileChangeFileDate(Fn, SLDate[lp]);
              DeleteFile(ToPath + Newfn);
              SuccFiles := SuccFiles + #13#10 + RelativePath;
              break;
            end;
          end;
        finally
          if Fs <> nil then
            Fs.Free;
        end;
      end;
      ThreadRetInfo.HTML := '';
      if trim(SuccFiles) <> '' then
        ThreadRetInfo.HTML := '���θ����������ļ���'#13#10 + SuccFiles;
      //if trim(FailFiles) <> '' then
        //ThreadRetInfo.HTML := trim(ThreadRetInfo.HTML + #13#10'�����ļ�����ʧ�ܣ�'#13#10 + FailFiles);
    end;
  finally
    SLTmp.Free;
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
    Pub.MsgBox('error:' + ThreadRetInfo.ErrStr + Copy(ThreadRetInfo.HTML, 1, 500));
    exit;
  end;
  if trim(ThreadRetInfo.HTML) <> '' then
    Pub.MsgBox(ThreadRetInfo.HTML)
  else
    Pub.MsgBox('����û�и��£�');
end;
procedure TMainForm.Image12Click(Sender: TObject);
begin //ͬ������-�ֿ�
  inherited;
  CloseMore;
  lblMsg.Caption := '�������������Ժ򡣡���';
  Run_Async(UpgradeBlock_Run, UpgradeBlock_Result);
end;

end.
