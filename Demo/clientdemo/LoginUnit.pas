unit LoginUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, baseformUnit, clientpub, Vcl.StdCtrls, minicomponents,
  HuoPubFuncUnit, Vcl.ExtCtrls, dxGDIPlusClasses, acPNG, Shellapi;

type
  Tlogin = class(Tbaseform)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lblMsg: TLabel;
    cbZt: TComboBox;
    edtUser: TEdit;
    edtPwd: TEdit;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Panel1: TPanel;
    Label4: TLabel;
    CheckBox1: TCheckBox;
    Label5: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure imMinClick(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure Label5Click(Sender: TObject);
  private
    FUser, Fpwd: string;
    procedure Login_Result(var ThreadRetInfo: TThreadRetInfo);
    procedure Login_Run(var ThreadRetInfo: TThreadRetInfo);
    procedure GetZt_Result(var ThreadRetInfo: TThreadRetInfo);
    procedure GetZt_Run(var ThreadRetInfo: TThreadRetInfo);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  login: Tlogin;

implementation

uses connparams;

{$R *.dfm}

procedure Tlogin.GetZt_Run(var ThreadRetInfo: TThreadRetInfo);
var
  ContentType: string;
begin
  //不能这样 FJsondata := DataSet2Json(VirtualTable1); //线程里不能直接访问主线程的数据
  ThreadRetInfo.Ok := false;

  if not HttpPost('/接口/获取账套.html', '', ThreadRetInfo.ErrStr, ThreadRetInfo.HTML) then exit;

  ThreadRetInfo.Ok := true;
end;

procedure Tlogin.Image3Click(Sender: TObject);
begin
  inherited;
  Close;
end;

procedure Tlogin.GetZt_Result(var ThreadRetInfo: TThreadRetInfo);
var
  Json: TminiJson;
  SL: TStringlist;
  lp: integer;
begin
  lblMsg.Caption := ThreadRetInfo.ErrStr;
  if not ThreadRetInfo.Ok then
  begin
    Pub.MsgBox('出错了!' + ThreadRetInfo.ErrStr);
    exit;
  end;
  Json := TminiJson.Create;
  try
    Json.LoadFromString(ThreadRetInfo.HTML);
    if Json.S['retcode'] <> '200' then
    begin
      Pub.MsgBox('出错了!' + Json.S['retmsg']);
      exit;
    end;
    SL := TStringlist.Create;
    try
      SL.CommaText := Json.S['data'];
      FClientPubinfo.Ztinfo := Json.S['data'];
      cbZt.Items.Clear;
      for lp := 0 to SL.Count - 1 do
        cbZt.Items.Add(Pub.GetDeliBack(SL[lp], '--'));
      if Json.S['ztdefault'] <> '' then
      begin
        cbZt.ItemIndex := cbZt.Items.IndexOf(Json.S['ztdefault']);
      end else
      if cbZt.Items.Count > 0 then
        cbZt.ItemIndex := 0;
    finally
      SL.Free;
    end;
  finally
    Json.Free;
  end;

end;

procedure Tlogin.imMinClick(Sender: TObject);
begin
  //inherited;
  connparam := Tconnparam.Create(nil);
  try
    if connparam.ShowModal <> 1 then exit;
  finally
    connparam.Free;
  end;
end;

procedure Tlogin.FormCreate(Sender: TObject);
var
  ErrStr, HTML, ContentType: string;
  Json: TminiJson;
  SL: TStringlist;
  lp: integer;
begin
  inherited;
  lblMsg.Caption := '正在获取账套数据，请稍候...';
  //异步方式
  Run_Async(GetZt_Run, GetZt_Result);

  {主线程阻塞方式
  if not HttpPost(FClientPubinfo, 'Client/获取账套.html', '', ErrStr, HTML, ContentType) then
  begin
    Pub.MsgBox('出错了!' + ErrStr);
    exit;
  end;
  Json := TminiJson.Create;
  try
    Json.LoadFromString(HTML);
    if Json.S['retcode'] <> '200' then
    begin
      Pub.MsgBox('出错了!' + Json.S['retmsg']);
      exit;
    end;
    SL := TStringlist.Create;
    try
      SL.CommaText := Json.S['data'];
      FClientPubinfo.Ztinfo := Json.S['data'];
      //ShowMessage(SL.Text);
      cbZt.Items.Clear;
      for lp := 0 to SL.Count - 1 do
        cbZt.Items.Add(Pub.GetDeliBack(SL[lp], '--'));
      if cbZt.Items.Count > 0 then
        cbZt.ItemIndex := 0;
    finally
      SL.Free;
    end;
  finally
    Json.Free;
  end;}
end;

procedure Tlogin.Login_Run(var ThreadRetInfo: TThreadRetInfo);
var
  Head, PostData, ContentType: string;
begin
  //不能这样 FJsondata := DataSet2Json(VirtualTable1); //线程里不能直接访问主线程的数据
  ThreadRetInfo.Ok := false;

  PostData := 'ztcode=' + FClientPubinfo.LoginZtCode + '&' +
    'usercode=' + FUser + '&' +
    'pwd=' + Fpwd;

  if FClientPubinfo.Sessionid <> '' then
    Head := 'Authorization: Bearer ' + FClientPubinfo.Sessionid
  else
    Head := '';

  if not HttpPost(FClientPubinfo, '接口/登录.html', PostData, ThreadRetInfo.ErrStr, ThreadRetInfo.HTML, ContentType, false, Head) then exit;

  ThreadRetInfo.Ok := true;
end;

procedure Tlogin.Label4Click(Sender: TObject);
var
  SL: TStringlist;
  InParam: TminiInParams;
begin //登录
  inherited;
  //主是异步方式
  lblMsg.Caption := '正在登录，请稍候...';
  FUser := edtUser.Text;
  Fpwd := edtPwd.Text;
  SL := TStringlist.Create;
  try
    SL.CommaText := FClientPubinfo.Ztinfo;
    FClientPubinfo.LoginZtCode := TPub.GetDeliPri(SL[cbZt.ItemIndex], '--');
  finally
    SL.Free;
  end;

  Run_Async(Login_Run, Login_Result);

  { 这是阻塞方式

  PostData := 'ztcode=' + FClientPubinfo.LoginZtCode + '&' +
    'usercode=' + edtUser.Text + '&' +
    'pwd=' + edtPwd.Text;

  if FClientPubinfo.Sessionid <> '' then
    Head := 'Authorization: Bearer ' + FClientPubinfo.Sessionid
  else
    Head := '';

  if not HttpPost(FClientPubinfo, '接口/登录.html', PostData, ErrStr, HTML, ContentType, false, Head) then
  begin
    Pub.MsgBox('出错了!' + ErrStr);
    exit;
  end;

  Json := TminiJson.Create;
  try
    Json.LoadFromString(HTML);
    if Json.S['retcode'] = '100' then
    begin
      Pub.MsgBox('出错了!' + Json.S['retmsg']);
      exit;
    end else
    if Json.S['retcode'] = '150' then
    begin
      Pub.MsgBox(Json.S['retmsg']);
      exit;
    end else
    if Json.S['retcode'] = '160' then
    begin //已登录
      Pub.MsgBox(Json.S['retmsg']);
      exit;
    end else
    if Json.S['retcode'] = '200' then
    begin
      //登录成功，获取得sessionid, 存于客户端内存中，以后每次访问都要带上 Sessionid，加入到头Authorization: Beare中
      FClientPubinfo.Sessionid := Json.S['sessionid'];
      FClientPubinfo.userid := Json.S['userid'];
      FClientPubinfo.usercode := edtUser.Text;
      FClientPubinfo.username := Json.S['username'];
      //Pub.MsgBox(Json.S['retmsg'] + FClientPubinfo.Sessionid);
      ModalResult := mrOk;
    end;
  finally
    Json.Free;
  end; }
end;


procedure Tlogin.Label5Click(Sender: TObject);
begin
  inherited;
  ShellExecute(0, 'Open', PChar('https://www.wyeditor.com/miniframe/'), '', '', 1);
end;

procedure Tlogin.Login_Result(var ThreadRetInfo: TThreadRetInfo);
var
  Json: TminiJson;
begin
  if not ThreadRetInfo.Ok then
  begin
    Pub.MsgBox(ThreadRetInfo.ErrStr);
    exit;
  end;
  lblMsg.Caption := '';
  Json := TminiJson.Create;
  try
    Json.LoadFromString(ThreadRetInfo.HTML);
    if Json.S['retcode'] = '100' then
    begin
      Pub.MsgBox('出错了!' + Json.S['retmsg']);
    end else
    if Json.S['retcode'] = '150' then
    begin
      Pub.MsgBox(Json.S['retmsg']);
    end else
    if Json.S['retcode'] = '160' then
    begin //已登录
      Pub.MsgBox(Json.S['retmsg']);
    end else
    if Json.S['retcode'] = '200' then
    begin
      //登录成功，获取得sessionid, 存于客户端内存中，以后每次访问都要带上 Sessionid，加入到头Authorization: Beare中
      FClientPubinfo.Sessionid := Json.S['sessionid'];
      FClientPubinfo.userid := Json.S['userid'];
      FClientPubinfo.usercode := edtUser.Text;
      FClientPubinfo.username := Json.S['username'];
      //Pub.MsgBox(Json.S['retmsg'] + FClientPubinfo.Sessionid);
      ModalResult := mrOk;
    end else
    begin
      Pub.MsgBox(Json.S['retmsg']);
    end;
  finally
    Json.Free;
  end;
end;


end.
