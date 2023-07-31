unit connparams;

interface

uses
Windows, Messages, SysUtils, Variants, Classes, Graphics,
Controls, Forms, Dialogs, baseformUnit, clientpub, StdCtrls, minicomponents,
HuoPubFuncUnit, ExtCtrls, Shellapi;
{Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, baseformUnit, clientpub, HuoPubFuncUnit,
  PubstringUnit, ExtCtrls;}
type

  { Tconnparam }

  Tconnparam = class(Tbaseform)
    edtUrl: TEdit;
    lblMsg: TLabel;
    lblsp2: TLabel;
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

{$R *.lfm}

procedure Tconnparam.Conn_Run(var ThreadRetInfo: TThreadRetInfo);
var
  Head, PostData, ContentType: string;
begin
  //不能这样 FJsondata := DataSet2Json(VirtualTable1); //线程里不能直接访问主线程的数据
  ThreadRetInfo.Ok := false;

  if not HttpPost(FClientPubinfo, PostData, '', ThreadRetInfo.ErrStr, ThreadRetInfo.HTML, ContentType, true) then exit;

  ThreadRetInfo.Ok := true;
end;

procedure Tconnparam.Label4Click(Sender: TObject);
begin
  inherited;
  URLToClientParam(edtUrl.Text);
  //异步方式
  lblmsg.Caption := '正在连接服务器，请稍候...';
  Run_Async(Conn_Run, Conn_Result);
  SaveToFile();
  {//主线程阻塞方式
  if not HttpPost(FClientPubinfo, '', '', ErrStr, HTML, ContentType, true) then exit;
  begin
    Pub.MsgBox('连接出错！' + ErrStr);
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
  FClientPubinfo.IsTls := UpperCase(Pub.GetDeliPri(URL, ':')) = 'HTTPS';
  FClientPubinfo.URI := Pub.GetDeliBack(URL, '//');
  if Pos('/', FClientPubinfo.URI) > 0 then
  begin
    FClientPubinfo.URI := Pub.GetDeliPri(FClientPubinfo.URI, '/');
  end else
  begin
    if Pos('?', FClientPubinfo.URI) > 0 then
    begin
      FClientPubinfo.URI := Pub.GetDeliPri(FClientPubinfo.URI, '?');
    end;
  end;
  if Pos(':', FClientPubinfo.URI) > 0 then
  begin
    FClientPubinfo.Port := Pub.GetDeliBack(FClientPubinfo.URI, ':');
    FClientPubinfo.URI := Pub.GetDeliPri(FClientPubinfo.URI, ':');
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
