
//////////////////////////////////////////////////////////////////////////////////
///                                                                            ///
///  miniframe��ԴWeb��ܼ���Ⱥ��821855479 ����Ӳ���Ⱥ������ϵQQ��3123827806  ///
///  ��ҳ��������ַ��https://wyeditor.com                                      ///
///  Դ�뼰demo���أ�https://wyeditor.com/miniframe/                           ///
///                                                                            ///
//////////////////////////////////////////////////////////////////////////////////

unit clientpub;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, mormot.net.client, mormot.core.os, PubStringUnit,
  mormot.net.sock, mormot.core.buffers, mormot.core.text, PubSysUnit;

type
  TClientPubinfo =  record
    IsTls: boolean;
    URI, Port: string;
    LoginZtCode, LoginZtName: string;
    userid, usercode, username: string;
    Ztinfo: string;
    Sessionid: string;
  end;


  TminiInParams = record  //���ڴ�Ŵ���Ĳ���
    P1, p2, p3, p4, p5, p6, p7, p8, p9, p10: string;
    obj1, obj2, obj3: TObject;
  end;

  TThreadRetInfo = record
    ErrStr, HTML: string;
    OutStream: TMemoryStream;
    Note1, Note2, Note3, Note4, Note5: string;
    Self: TThread;
    Ok: boolean;

    InParams: TminiInParams; //���ڴ��䴫��Ĳ���
  end;

  TMinithreadevent = procedure(var ThreadRetInfo: TThreadRetInfo);
  TMinithreadevent_obj = procedure(var ThreadRetInfo: TThreadRetInfo) of Object;

  TMiniRun_AsyncThread = class(TThread)
  private
    procedure RunResult;
  protected
    FThreadRetInfo: TThreadRetInfo;
    procedure Execute; override;
  public
    //���̵��� 
    FRunevent: TMinithreadevent; //��������
    FResultevent: TMinithreadevent; //�ý�����������߳�ͬ����

    //�෽������ 
    FRunevent_obj: TMinithreadevent_obj; //��������
    FResultevent_obj: TMinithreadevent_obj; //�ý�����������߳�ͬ����
    constructor Create();
    destructor Destroy; override;
  end;

  function HttpPost(ClientPubinfo: TClientPubinfo; URL, PostData: string; var ErrStr, HTML, OutContentType: string; isCheck: boolean = false;
    Head: string = ''; timeOut: integer=15000; InContentType: string = TEXT_CONTENT_TYPE): boolean; overload;

  //���µ�¼��ĵ���
  //ֱ���ύ���ݣ�Post�����ݿ�����Json, �����json������InContentType=JSON_CONTENT_TYPE
  function HttpPost(URL: string; PostData: string; var ErrStr, HTML: string; Head: string = ''; timeOut: integer=15000; InContentType: string = TEXT_CONTENT_TYPE): boolean; overload;
  //�ύ�����ݴ�� ��  PostSL.Values[name] = value;
  function HttpPost(URL: string; PostSL: TStringlist; var ErrStr, HTML: string; Head: string = ''; timeOut: integer=15000): boolean; overload;

  //ֱ���ύ���ݣ�Post�����ݿ�����Json, �����json������InContentType=JSON_CONTENT_TYPE, ���OutStream <> nil �򷵻ص���Stream�����򷵻ص����ݷ���HTML��
  function HttpPost(URL: string; PostData: RawByteString; var ErrStr, HTML: string; var OutStream: TMemoryStream; Head: string = ''; timeOut: integer=15000; InContentType: string = TEXT_CONTENT_TYPE): boolean; overload;
  //�ύ�����ݴ�� ��  PostSL.Values[name] = value; ���OutStream <> nil �򷵻ص���Stream�����򷵻ص����ݷ���HTML��
  function HttpPost(URL: string; PostSL: TStringlist; var ErrStr, HTML: string; var OutStream: TMemoryStream; Head: string = ''; timeOut: integer=15000; InContentType: string = TEXT_CONTENT_TYPE): boolean; overload;

  //ֱ���ϴ���stream
  function HttpPost(URL: string; PostStream: TStream; var ErrStr, HTML: string; var OutStream: TMemoryStream; Head: string = ''; timeOut: integer=15000; InContentType: string = BINARY_CONTENT_TYPE): boolean; overload;
  function HttpPost(URL: string; PostStream: TStream; var ErrStr, HTML: string; Head: string = ''; timeOut: integer=15000; InContentType: string = BINARY_CONTENT_TYPE): boolean; overload;


  //�첽����
  procedure Run_Async(Runevent, Resultevent: TMinithreadevent); overload;
  procedure Run_Async(Runevent, Resultevent: TMinithreadevent_obj); overload;
  procedure Run_Async(InParams: TminiInParams; Runevent, Resultevent: TMinithreadevent); overload;
  procedure Run_Async(InParams: TminiInParams; Runevent, Resultevent: TMinithreadevent_obj); overload;

  function UrlEncode(Url: string): string;
  function UrlDecode(Url: string): string;
var
  FClientPubinfo: TClientPubinfo;

implementation

function UrlEncode(Url: string): string;
begin
  Result := mormot.core.buffers.UrlEncode(URL);
end;
function UrlDecode(Url: string): string;
begin
  Result := mormot.core.buffers.UrlDecode(URL);
end;
procedure Run_Async(Runevent, Resultevent: TMinithreadevent);
var
  InParams: TminiInParams;
begin
  Run_Async(InParams, Runevent, Resultevent);
end;

procedure Run_Async(Runevent, Resultevent: TMinithreadevent_obj);
var
  InParams: TminiInParams;
begin
  Run_Async(InParams, Runevent, Resultevent);
end;

procedure Run_Async(InParams: TminiInParams; Runevent, Resultevent: TMinithreadevent);
var
  MiniRun_AsyncThread: TMiniRun_AsyncThread;
begin
  MiniRun_AsyncThread := TMiniRun_AsyncThread.Create;
  MiniRun_AsyncThread.FRunevent := Runevent;
  MiniRun_AsyncThread.FResultevent := Resultevent;
  MiniRun_AsyncThread.FThreadRetInfo.InParams :=  InParams;
  MiniRun_AsyncThread.Start;
end;

procedure Run_Async(InParams: TminiInParams; Runevent, Resultevent: TMinithreadevent_obj);
var
  MiniRun_AsyncThread: TMiniRun_AsyncThread;
begin
  MiniRun_AsyncThread := TMiniRun_AsyncThread.Create;
  MiniRun_AsyncThread.FRunevent_obj := Runevent;
  MiniRun_AsyncThread.FResultevent_obj := Resultevent;
  MiniRun_AsyncThread.FThreadRetInfo.InParams :=  InParams;
  MiniRun_AsyncThread.Start;
end;

function HttpPost(ClientPubinfo: TClientPubinfo; URL, PostData: string; var ErrStr, HTML,
  OutContentType: string; isCheck: boolean; Head: string; timeOut: integer; InContentType: string): boolean;
var
  Http: THttpClientSocket;
  Status: integer;
begin
  Result := false;
  Http := nil;
  try
    try
      Http := THttpClientSocket.Open(ClientPubinfo.URI, ClientPubinfo.Port, nltcp, timeOut, ClientPubinfo.IsTls);
      if not isCheck then
      begin
        Status := Http.Post(URL, PostData, InContentType, 0, Head);
        if Status = 302 then
        begin
          HTML := 'ҳ�淢������ת������[' + Status.ToString + ']';
        end else
        if Status = 404 then
        begin
          HTML := '�������Դ�����ã�����[' + Status.ToString + ']��������ַ�Ƿ���ȷ���������ַ��Ƿ������URLEncode��';
        end else
        if Status <> 200 then
        begin
          HTML := '�����˳�������[' + Status.ToString + ']';
        end else
        begin
          HTML := UTF8ToString(Http.Content);
          OutContentType := Http.ContentType;
        end;
      end;
    except
      on e: exception do
      begin
        ErrStr := e.Message;
        exit;
      end;
    end;
  finally
    if Http <> nil then
      Http.Free;
  end;
  Result := true;
end;

function GetPostData(PostSL: TStringlist): string;
var
  lp: integer;
  PostData, One: string;
begin
  PostData := '';
  for lp := 0 to PostSL.Count - 1 do
  begin
    One := PostSL.Names[lp] + '=' + UrlEncode(PostSL.Values[PostSL.Names[lp]]);
    if PostData = '' then
      PostData := One
    else
      PostData := PostData + '&' + One;
  end;
  Result := PostData;
end;

function HttpPost(URL: string; PostSL: TStringlist; var ErrStr, HTML: string; Head: string; timeOut: integer): boolean;
begin
  Result := HttpPost(URL, GetPostData(PostSL), ErrStr, HTML, Head, timeOut);
end;

function HttpPost(URL: string; PostData: string; var ErrStr, HTML: string; Head: string; timeOut: integer; InContentType: string): boolean;
var
  lp: integer;
  OutContentType: string;
begin
  if FClientPubinfo.Sessionid <> '' then
  begin
    if Head = '' then
      Head := 'Authorization: Bearer ' + FClientPubinfo.Sessionid
    else
      Head := trim(Head) + #13#10'Authorization: Bearer ' + FClientPubinfo.Sessionid;
  end;

  Result := HttpPost(FClientPubinfo, URL, PostData, ErrStr, HTML, OutContentType, false, Head, timeOut, InContentType);
end;

function HttpPost(URL: string; PostSL: TStringlist; var ErrStr, HTML: string; var OutStream: TMemoryStream; Head: string; timeOut: integer; InContentType: string): boolean; overload;
begin
  Result := HttpPost(URL, GetPostData(PostSL), ErrStr, HTML, OutStream, Head, timeOut, InContentType);
end;

function HttpPost(URL: string; PostData: RawByteString; var ErrStr, HTML: string; var OutStream: TMemoryStream; Head: string; timeOut: integer; InContentType: string): boolean;
var
  OutContentType: string;
  MyStrem: TStream;
  Http: THttpClientSocket;
  Status: integer;
begin
  Result := false;

  OutStream := nil;
  if FClientPubinfo.Sessionid <> '' then
  begin
    if Head = '' then
      Head := 'Authorization: Bearer ' + FClientPubinfo.Sessionid
    else
      Head := trim(Head) + #13#10'Authorization: Bearer ' + FClientPubinfo.Sessionid;
  end;

  Http := nil;
  try
    try
      Http := THttpClientSocket.Open(FClientPubinfo.URI, FClientPubinfo.Port, nltcp, timeOut, FClientPubinfo.IsTls);
      Status := Http.Post(URL, PostData, InContentType, 0, Head);
      OutContentType := Http.ContentType;
      if Status = 302 then
      begin
        HTML := 'ҳ�淢������ת������[' + Status.ToString + ']';
      end else
      if Status = 404 then
      begin
        HTML := '�������Դ�����ã�����[' + Status.ToString + ']��������ַ�Ƿ���ȷ���������ַ��Ƿ������URLEncode��';
      end else
      if Status <> 200 then
      begin
        HTML := '�����˳�������[' + Status.ToString + ']';
      end else
      //if LowerCase(OutContentType) = BINARY_CONTENT_TYPE then
      if (Pos('/octet-stream', LowerCase(OutContentType)) > 0) or (Pos('miniContentType: staticfile', Http.Headers) > 0) then
      begin
        ///ErrStr := Http.Headers; miniFileName:
        OutStream := TMemoryStream.Create;
        MyStrem := RawByteStringToStream(Http.Content);
        MyStrem.Seek(0, 0);
        OutStream.CopyFrom(MyStrem, MyStrem.Size);
        MyStrem.Free;
        if Pos('miniFileName:', Http.Headers) > 0 then
          HTML := PubSys.Base64Decode(Http.HeaderGetValue('MINIFILENAME'));
      end else
        HTML := Utf8ToAnsi(Http.Content);
    except
      on e: exception do
      begin
        ErrStr := e.Message;
        exit;
      end;
    end;
  finally
    if Http <> nil then
      Http.Free;
  end;
  Result := true;
end;

function HttpPost(URL: string; PostStream: TStream; var ErrStr, HTML: string; var OutStream: TMemoryStream; Head: string; timeOut: integer; InContentType: string): boolean;
begin
  PostStream.Position := 0;
  Result := HttpPost(URL, StreamToRawByteString(PostStream), ErrStr, HTML, OutStream, Head, timeOut, InContentType);
end;

function HttpPost(URL: string; PostStream: TStream; var ErrStr, HTML: string; Head: string; timeOut: integer; InContentType: string): boolean;
var
  OutStream: TMemoryStream;
begin
  Result := HttpPost(URL, PostStream, ErrStr, HTML, OutStream, Head, timeOut, InContentType);
end;

{ TMiniRun_AsyncThread }

constructor TMiniRun_AsyncThread.Create;
begin
  FRunevent := nil; //��������
  FResultevent := nil; //�ý�����������߳�ͬ����

  FRunevent_obj := nil; //��������
  FResultevent_obj := nil; //�ý�����������߳�ͬ����

  FThreadRetInfo.OutStream := nil;
  FThreadRetInfo.ErrStr := '';
  FThreadRetInfo.HTML := '';
  FreeOnTerminate := true;
  inherited Create(true);
  FreeOnTerminate := true;
end;

destructor TMiniRun_AsyncThread.Destroy;
begin

  inherited;
end;

procedure TMiniRun_AsyncThread.RunResult;
begin
  if Assigned(FResultevent) then
    FResultevent(FThreadRetInfo)
  else
    FResultevent_obj(FThreadRetInfo);
end;

procedure TMiniRun_AsyncThread.Execute;
begin
  inherited;
  try
    try
      FThreadRetInfo.OutStream := nil;
      FThreadRetInfo.Self := Self;
      if Assigned(FRunevent) then
        FRunevent(FThreadRetInfo)
      else
        FRunevent_obj(FThreadRetInfo);
    except
      on e: exception do
      begin
        FThreadRetInfo.Ok := false;
        FThreadRetInfo.ErrStr := e.Message;
      end;
    end;
  finally
    Synchronize(RunResult);
    if FThreadRetInfo.OutStream <> nil then
    begin
      FThreadRetInfo.OutStream.Free;
      FThreadRetInfo.OutStream := nil;
    end;
  end;
end;

end.
