unit connparams;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, baseformUnit, clientpub, HuoPubFuncUnit,
  LoginUnit, PubstringUnit, Vcl.ExtCtrls, acPNG;

type
  Tconnparam = class(Tbaseform)
    edtUrl: TEdit;
    lblMsg: TLabel;
    Label1: TLabel;
    Panel1: TPanel;
    Label4: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Label4Click(Sender: TObject);
  private
    procedure Conn_Result(var ThreadRetInfo: TThreadRetInfo);
    procedure Conn_Run(var ThreadRetInfo: TThreadRetInfo);
    procedure SaveToFile;
    { Private declarations }
  public
    { Public declarations }
    class function LoadFromFile(var URL: string): string; static;
    class procedure URLToClientParam(URL: string); static;
  end;

var
  connparam: Tconnparam;

implementation

{$R *.dfm}

procedure Tconnparam.Conn_Run(var ThreadRetInfo: TThreadRetInfo);
var
  Head, PostData, ContentType: string;
begin
  //�������� FJsondata := DataSet2Json(VirtualTable1); //�߳��ﲻ��ֱ�ӷ������̵߳�����
  ThreadRetInfo.Ok := false;

  if not HttpPost(FClientPubinfo, '', '', ThreadRetInfo.ErrStr, ThreadRetInfo.HTML, ContentType, true) then exit;

  ThreadRetInfo.Ok := true;
end;

procedure Tconnparam.Label4Click(Sender: TObject);
begin
  inherited;
  URLToClientParam(edtUrl.Text);
  //�첽��ʽ
  lblmsg.Caption := '�������ӷ����������Ժ�...';
  Run_Async(Conn_Run, Conn_Result);
  SaveToFile();
  {//���߳�������ʽ
  if not HttpPost(FClientPubinfo, '', '', ErrStr, HTML, ContentType, true) then exit;
  begin
    Pub.MsgBox('���ӳ���' + ErrStr);
    exit;
  end;
  ModalResult := mrOk;}
end;

class function Tconnparam.LoadFromFile(var URL: string): string;
var
  SL: TStringlist;
begin
  Result := '';
  if FileExists(ExtractFilePath(ParamStr(0)) + 'setting\params.ini') then
  begin
    try
      SL := TStringlist.Create;
      try
        SL.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'setting\params.ini');
        URL := SL.Values['URL'];
      finally
        SL.Free;
      end;
    except
      on e: exception do
        Result := e.Message;
    end;
  end;
end;

procedure Tconnparam.FormCreate(Sender: TObject);
var
  URL: string;
begin
  inherited;
  if LoadFromFile(URL) = '' then
    edtUrl.Text := URL;
  lblmsg.Caption := '';
end;

procedure Tconnparam.Conn_Result(var ThreadRetInfo: TThreadRetInfo);
begin
  lblmsg.Caption := ThreadRetInfo.ErrStr;
  if not ThreadRetInfo.Ok then
  begin
    Pub.MsgBox(ThreadRetInfo.ErrStr);
    exit;
  end;
  ModalResult := mrOk;
end;

class procedure Tconnparam.URLToClientParam(URL: string);
begin
  FClientPubinfo.IsTls := UpperCase(Pubstring.GetDeliPri(URL, ':')) = 'HTTPS';
  FClientPubinfo.URI := Pubstring.GetDeliBack(URL, '//');
  if Pos('/', FClientPubinfo.URI) > 0 then
  begin
    FClientPubinfo.URI := Pubstring.GetDeliPri(FClientPubinfo.URI, '/');
  end else
  begin
    if Pos('?', FClientPubinfo.URI) > 0 then
    begin
      FClientPubinfo.URI := Pubstring.GetDeliPri(FClientPubinfo.URI, '?');
    end;
  end;
  if Pos(':', FClientPubinfo.URI) > 0 then
  begin
    FClientPubinfo.Port := Pubstring.GetDeliBack(FClientPubinfo.URI, ':');
    FClientPubinfo.URI := Pubstring.GetDeliPri(FClientPubinfo.URI, ':');
  end else
    FClientPubinfo.Port := '80';
end;

procedure Tconnparam.SaveToFile();
var
  SL: TStringlist;
begin
  ForceDirectories(ExtractFilePath(ParamStr(0)) + 'setting');
  try
    SL := TStringlist.Create;
    try
      SL.Values['URL'] := edtUrl.Text;
      SL.SaveToFile(ExtractFilePath(ParamStr(0)) + 'setting\params.ini');
    finally
      SL.Free;
    end;
  except
  end;
end;

end.
