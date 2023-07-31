
//////////////////////////////////////////////////////////////////////////////////
///                                                                            ///
///  miniframe开源Web框架技术群：821855479 如果加不了群，请联系QQ：3123827806  ///
///  网页制作器网址：https://wyeditor.com                                      ///
///  源码及demo下载：https://wyeditor.com/miniframe/                           ///
///                                                                            ///
//////////////////////////////////////////////////////////////////////////////////

//(*
{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}
//*)
unit mormothttps;

//{$ mode objfpc}
//{$ h+}

interface

uses
  Classes, SysUtils, {$IFDEF FPC}FileUtil,{$endif}
  mormot.net.http,
  mormot.net.server,
  mormot.core.os,
  mormot.core.base,
  mormot.core.threads,
  mormot.core.zip,
  mormot.net.async,
  mormot.core.buffers,
  mormot.core.unicode,
  mormot.core.text,
  mormot.core.data,
  mormot.core.variants,
  PubStringUnit,
  IdGlobal,
  dateutils,
  minihttp,
  IdCustomHTTPServer,
  miniscriptcontroller,
  miniPub, Generics.Collections {$ifdef mswindows}, ShellApi {$endif};

const
  cSesssionName = 'miniframe';
type
  { TKing_HttpApiServer }

  TKing_HttpApiServer = class
  private
    class function GetCookie_head(SessionID: string; SessionTimeOut: integer; IsCookie: boolean): string;
    class function GetSessionName(): string;
    class function Info(Request: TminiHTTPRequest): boolean;
    class function MyCreateSession(var AddHead: string; SessionTimeOut: integer = 0; IsCookie: boolean = true): TminiSession;
    class procedure GetProc_Port_(FullURL: string; var Protocol, Host, Port: string); static;
    class function GetSessionID(Cookie: string): string; static;
  public
    class function CreateSession(Response: TminiHTTPResponse;
      SessionTimeOut: integer; IsCookie: boolean = true): TminiSession;

    {constructor Create(QueueName: SynUnicode = '';
      const OnStart: TOnNotifyThread = nil; const OnStop: TOnNotifyThread = nil;
      const ProcessName: RawUtf8 = ''; ProcessOptions: THttpServerOptions = []); reintroduce;   }
    /// release all associated memory and handles
    class function mORMot_Request(Ctxt: THttpServerRequestAbstract): cardinal;
    class procedure StartService;
  end;     /// *)

  TToInfo = class(TThread)
  protected
    procedure Execute; override;
  public
    constructor Create();
  end;

  function ReadParams: string;


var WSessions: TIdHTTPDefaultSessionList;
    FRequest_AllCount: integer;
    FWorking_thread_Count: integer;

implementation

var
  CriticalSection: TMiniCriticalSection;

  function FillDuan(Ip: string): string;
var
  a1, a2, a3, a4: string;
begin
  a1 := PubString.GetDeliPri(Ip, '.');
  Ip := PubString.GetDeliBack(Ip, '.');
  a1 := PubString.FillChar(a1, '0',3);

  a2 := PubString.GetDeliPri(Ip, '.');
  Ip := PubString.GetDeliBack(Ip, '.');
  a2 := PubString.FillChar(a2, '0',3);

  a3 := PubString.GetDeliPri(Ip, '.');
  Ip := PubString.GetDeliBack(Ip, '.');
  a3 := PubString.FillChar(a3, '0',3);

  a4 := PubString.GetDeliPri(Ip, '.');
  Ip := PubString.GetDeliBack(Ip, '.');
  a4 := PubString.FillChar(a4, '0',3);
  Result := a1 + '.' + a2 + '.' + a3 + '.' + a4;
end;

function ReadParams: string;
var
  lp, J: integer;
  I: Integer;
  SL, SL2: TStringList;
  TmpStr, MaxSessionCount, MaximumConnections, SSLPort, Port: string;
  Doc: TDocVariantData;
  function GetValue(Key: string): string;
  begin
    try
      Result := Doc._[1]._[lp].Value[Key];
    except
      Result := '';
    end;
  end;
begin

  try
    {$IFDEF FPC}
    ServerInfo.ProgramPath := ProgramDirectory;
    {$esle}
    ServerInfo.ProgramPath := ExtractFilePath(ParamStr(0));
    {$endif}

    TmpStr := ServerInfo.ProgramPath + '\setting\conf.json';
    if FileExists(TmpStr) then
    begin
      doc.InitJSONFromFile(TmpStr);
      try
        lp := 0;
        ServerInfo.httpport := GetValue('httpport');
        if trim(ServerInfo.httpport) = '' then
          ServerInfo.HttpPort := '899';
        ServerInfo.crossdomain := GetValue('crossdomain') = 'on';
        ServerInfo.AutoZip := GetValue('autozip') = 'on';
        try
          ServerInfo.poolertimeout := StrToInt(GetValue('poolertimeout'));
        except
          ServerInfo.poolertimeout := 120;
        end;
        {$ifdef IsPublic}
        ServerInfo.PooredMaxCount := 2;
        ServerInfo.poolermincount := 1;
        {$else}
        try
          ServerInfo.threadcount := StrToInt(GetValue('threadcount'));
        except
          ServerInfo.threadcount := 50;
        end;
        try
          ServerInfo.quequelength := StrToInt(GetValue('quequelength'));
        except
          ServerInfo.quequelength := 10000;
        end;
        try
          ServerInfo.poolermaxcount := StrToInt(GetValue('poolermaxcount'));
        except
          ServerInfo.poolermaxcount := 100;
        end;
        try
          ServerInfo.poolermincount := StrToInt(GetValue('poolermincount'));
        except
          ServerInfo.poolermincount := 10;
        end;
        {$endif}
        ServerInfo.autopcandmobile := trim(GetValue('autopcandmobile')) = 'on';
        ServerInfo.autopcandmobileext := trim(GetValue('autopcandmobileext'));
        ServerInfo.servernocachefile := trim(GetValue('servernocachefile')) = 'on';
        try
          FLogInfo.FIsLog := trim(GetValue('startlog')) = 'on';
          FLogInfo.MaxCount := StrToInt(trim(GetValue('maxlogcount')));
        except
          FLogInfo.MaxCount := 50000;
        end;
        SL := TStringList.Create;
        SL2 := TStringList.Create;
        try
          try
            ServerInfo.clientcachefile := GetValue('clientcachefile');
            if trim(GetValue('mainservicepath')) = '' then
              ServerInfo.mainservicepath := ExtractFilePath(ParamStr(0)) + 'host\'
            else
              ServerInfo.mainservicepath := trim(GetValue('mainservicepath'));
            if trim(trim(GetValue('serviceext'))) <> '' then
              ServerInfo.serviceext := LowerCase(trim(GetValue('serviceext')));

            TmpStr := StringReplace(LowerCase(trim(GetValue('exttoserver'))), ';', #13#10, [rfReplaceAll, rfIgnoreCase]);
            if ServerInfo.exttoserver.Text <> TmpStr then
              ServerInfo.exttoserver.Text := TmpStr;

            ServerInfo.errorpage := LowerCase(trim(GetValue('errorpage')));
            ServerInfo.hosttodir := LowerCase(trim(GetValue('hosttodir')));
            ServerInfo.oldhosttodir := ServerInfo.hosttodir;

            SL.Text := StringReplace(LowerCase(ServerInfo.hosttodir), ';', #13#10, [rfReplaceAll]);
            for I := SL.Count - 1 downto 0 do
            if (trim(SL[I]) = '') or (not DirectoryExists(trim(GetDeliBack(SL[I], '=')))) then
            begin
              SL.Delete(I);
            end;
            SL2.Clear;
            for I := 0 to SL.Count - 1 do
            begin
              SL2.Add(trim(PubString.GetDeliBack(SL[I], '=')));
              SL[I] := trim(PubString.GetDeliPri(SL[I], '='));
            end;

            if ServerInfo.hosttodirSL.Text <> SL.Text then
            begin
              ServerInfo.hosttodirSL.Text := SL.Text;
              ServerInfo.DirSL.Text := SL2.Text;
            end;
          except
          end;
          ServerInfo.mainservicepath := PathWithSlash(ServerInfo.mainservicepath);

          try
            if SysUtils.trim(GetValue('sessiontimeout')) = '' then
              ServerInfo.sessiontimeout := 300
            else
               ServerInfo.sessiontimeout := StrToint(SysUtils.trim(GetValue('sessiontimeout')));
          except
            ServerInfo.sessiontimeout := 300;
          end;
          try
            if SysUtils.trim(GetValue('maxsessioncount')) = '' then
              ServerInfo.maxsessioncount := 10000
            else
              ServerInfo.maxsessioncount := StrToint(SysUtils.trim(GetValue('maxsessioncount')));
          except
            ServerInfo.maxsessioncount := 100000
          end;

          ServerInfo.starthttps := trim(GetValue('starthttps')) = 'on';

          if trim(GetValue('httpsport')) <> '' then
            ServerInfo.httpsport := trim(GetValue('httpsport'))
          else
            ServerInfo.httpsport := '443';

          ServerInfo.cert := trim(GetValue('cert'));
          ServerInfo.secretkey := trim(GetValue('secretkey'));
          ServerInfo.rootcert := trim(GetValue('rootcert'));
          ServerInfo.openby127_0_0_1 := trim(GetValue('openby127_0_0_1')) = 'on';


          //加载黑名单
          SL.Sorted := false;
          SL.Text := trim(GetValue('blacklist'));
          for J := 0 to SL.Count - 1 do
          begin //去掉blacklist中的空格
            TmpStr := trim(SL[J]);
            for I := length(TmpStr) downto 1 do
            if TmpStr[I] = ' ' then
              Delete(TmpStr, I, 1);
            //填充IP, 方便查找
            if Pos('-', TmpStr) < 1 then
              TmpStr := FillDuan(TmpStr)
            else
              TmpStr := FillDuan(GetDeliPri(TmpStr, '-')) + '-' + FillDuan(GetDeliBack(TmpStr, '-'));
            SL[J] := TmpStr;
          end;
          SL.Sorted := true;
          SL.Text := SL.Text;
          if SL.Text <> ServerInfo.blacklist.Text then
          begin
            ServerInfo.blacklist.Sorted := true;
            ServerInfo.blacklist.Text := SL.Text;
            ServerInfo.Usedblacklist.Clear;
            ServerInfo.Usedwhitelist.Clear;
          end;

          //加载白名单
          SL.Sorted := false;
          SL.Text := trim(GetValue('whitelist'));
          for J := 0 to SL.Count - 1 do
          begin //去掉whitelist中的空格
            TmpStr := trim(SL[J]);
            for I := length(TmpStr) downto 1 do
            if TmpStr[I] = ' ' then
              Delete(TmpStr, I, 1);
            //填充IP, 方便查找
            if Pos('-', TmpStr) < 1 then
              TmpStr := FillDuan(TmpStr)
            else
              TmpStr := FillDuan(GetDeliPri(TmpStr, '-')) + '-' + FillDuan(GetDeliBack(TmpStr, '-'));
            SL[J] := TmpStr;
          end;
          SL.Sorted := true;
          SL.Text := SL.Text;
          if SL.Text <> ServerInfo.whitelist.Text then
          begin
            ServerInfo.whitelist.Sorted := true;
            ServerInfo.whitelist.Text := SL.Text;
            ServerInfo.Usedblacklist.Clear;
            ServerInfo.Usedwhitelist.Clear;
          end;
        finally
          SL2.Free;
          SL.Free;
        end;
      finally
        doc.Clear;
      end;
    end;
  except
    on e: exception  do
      Result := e.Message;
  end;
end;

function FindSession(Sessionid: string): TminiSession;
var
  i: integer;
  List: Tlist;
begin
  Result := nil;
  List := WSessions.SessionList.LockList;
  try
    for i := 0 to List.Count - 1 do
    begin
      if TminiSession(List.Items[i]).SessionID = Sessionid then
      begin
        Result := TminiSession(List.Items[i]);
        Result.LastTimeStamp := Now;
        break;
      end;
    end;
  finally
    WSessions.SessionList.UnlockList;;
  end;
end;
function MyRedirect(Headers, URL: string): string;
var
  cache: string;
begin
  cache :=
    'Location: ' + URL + #13#10 +

    'Date: ' + LocalDateTimeToHttpStr(Now) + #13#10 +
    'Expires: '+ LocalDateTimeToHttpStr(IncDay(Now, -30));

  Headers := cache + #13#10 + Headers;
  Result := Headers;
end;

function MakeCookie(
    const Name, Value : String;
    Expires           : TDateTime;
    const Path        : String;
    const Domain      : String = '';
    const Secure      : Boolean = false) : String;
begin
    Result := 'Set-Cookie: ' + Name + '=' + UrlEncode(Value);
    if Length(Value) = 0 then
        Result := Result + '_NONE_; EXPIRES=' + LocalDateTimeToHttpStr(Date - 7)
    else if Expires <> 0 then
        Result := Result + '; EXPIRES=' + LocalDateTimeToHttpStr(Expires);
    if Domain <> '' then Result := Result + '; DOMAIN=' + Domain;
    Result := Result + '; PATH=' + Path;
    if Secure then Result := Result + '; Secure; HttpOnly';
    Result := Result + #13#10;
end;

function MyFindSession(var Session: TminiSession; Ctxt: THttpServerRequestAbstract; Sessionid, Referer: string;
  SessionTimeout: integer; IsCookie: boolean = true): boolean;
var
  URL: string;
begin
  Result := false;
  if trim(SessionID) = '' then
    Session := nil
  else
  begin
    Session := FindSession(SessionID);
    if Session = nil then
    begin
      {URL := Referer;
      if trim(URL) = '' then URL := Ctxt.Url;

      Ctxt.OutCustomHeaders := MyRedirect('', URL) +
        MakeCookie(TKing_HttpApiServer.GetSessionName(), '', SessionTimeout, '/');
      Ctxt.OutContent := '';
      //Result := 302;
      exit;}
    end else
    begin
      Session.LastTimeStamp := Now;
      Ctxt.OutCustomHeaders := TKing_HttpApiServer.GetCookie_head(SessionID, SessionTimeout, IsCookie);
    end;
  end;

  Result := true;
end;

{ TKing_HttpApiServer }

class procedure TKing_HttpApiServer.GetProc_Port_(FullURL: string;var Protocol, Host, Port: string);
begin //FullURL:http://127.0.0.1:808   {FullURL:http://127.0.0.1:808/info
  Protocol := LowerCase(PubString.GetDeliPri(FullURL, ':'));
  Port := LowerCase(PubString.GetDeliBack(FullURL, '//'));
  Port := LowerCase(PubString.GetDeliPri(Port, '/'));
  Host := LowerCase(PubString.GetDeliPri(Port, ':'));
  if Pos(':', Port) > 0 then
    Port := LowerCase(PubString.GetDeliBack(Port, ':'))
  else
    Port := '';
  if Port = '' then
  begin
    if Protocol= 'https' then
      Port := '443'
    else
      Port := '80';
  end;
end;

class function TKing_HttpApiServer.GetSessionID(Cookie: string): string;
var
  SL: TStringlist;
  SessionName: string;
  lp: integer;
begin //GSessionIDCookie Host, User_Agent, Referer, Content_Type, Transfer_Encoding, Pragma, Cookie
  Result := '';
  SessionName := GetSessionName();
  SL := TStringlist.Create;
  try //
    SL.LineBreak := ';';
    SL.Text := Cookie;
    for lp := 0 to SL.Count - 1 do
    begin
      if LowerCase (SessionName) = LowerCase(trim(PubString.GetDeliPri(SL[lp], '='))) then
      begin
        Result := trim(PubString.GetDeliBack(SL[lp], '='));
        break;
      end;
    end;
  finally
    SL.Free;
  end;
end;
//*)

class function TKing_HttpApiServer.GetSessionName(): string;
begin
  Result := cSesssionName;
end;

class function TKing_HttpApiServer.GetCookie_head(SessionID: string; SessionTimeOut: integer; IsCookie: boolean): string; //SessionTimeOut-秒 默认7天超时
var
  dt: TDateTime;
begin
  if IsCookie then
  begin
    if SessionTimeOut = 0 then
      dt := Date + 7
    else
      dt := IncSecond(Now, SessionTimeOut);

    Result := MakeCookie(GetSessionName(), SessionID, dt, '/')
  end else
    Result := 'Authorization: ' + SessionID;
end;

function GetRemoteIP(SL: TStringlist; Ctxt: THttpServerRequestAbstract): string;
begin
  Result  := SL.Values['X-Real-IP'];
  if (Result = '') then
  begin
    if trim(Ctxt.RemoteIP) = '' then
      Result := '127.0.0.1'
    else
      Result := Ctxt.RemoteIP;
  end;
end;

function ToRequest(Document: string; SL: TStringlist; Ctxt: THttpServerRequestAbstract; mORMotHeadInfo: TmORMotHeadInfo; Request: TminiHTTPRequest): boolean;
var
  TmpStr, ContentText, Protocol: string;
  lp, i, j: integer;
  MyStrem: TStream;
begin
  Result := false;
  Request.InHeaders := Ctxt.InHeaders;
  Request.Headers.CommaText := SL.CommaText;

  Request.RemoteIP := GetRemoteIP(SL, Ctxt);

  Request.Host := SL.Values['Host'];
  if Request.Host = '' then
    Request.Host := Ctxt.Host;
  if Pos(':', Request.Host) > 0 then
    Request.Port := LowerCase(PubString.GetDeliBack(Request.Host, ':'));
  Request.Host := LowerCase(PubString.GetDeliPri(Request.Host, ':'));
  if Pos(':', Request.Port) > 0 then
    Request.Port := LowerCase(PubString.GetDeliBack(Request.Port, ':'));
  if Request.Port = '' then
  begin
    if Protocol = 'https' then
      Request.Port := '443'
    else
      Request.Port := '80';
  end;
  Request.URI := Copy(Document, 2, MaxInt);
  Request.Document := Document; //TmpStr;
  if Request.Document <> '' then
  begin
    if (Request.Document <> '/') and (Request.Document[1] = '/') then
    begin
      Request.Document := PubString.GetDeliPri(Request.Document, '?');
      //Request.Document := Copy(Request.Document, 2, MaxInt);
    end;
  end;

  Request.ContentType := Ctxt.InContentType;
  //Request.ContentText := ContentText;
  Request.Method := Ctxt.Method;
  //Request.PostedData_mORMot := ctxt.InContent;


  Request.UserAgent := Ctxt.UserAgent;
  Request.Accept := Request.Headers.Values['Accept'];
  Request.AcceptCharSet := Request.Headers.Values['AcceptCharSet'];
  Request.AcceptEncoding := Request.Headers.Values['AcceptEncoding'];
  Request.AcceptLanguage := Request.Headers.Values['AcceptLanguage'];
  Request.From := Request.Headers.Values['From'];
  Request.Referer := Request.Headers.Values['Referer'];
  Request.Cookie := Request.Headers.Values['Cookie'];
  Request.QueryParams := Ctxt.URL; //url中的参数部分
  //if Pos('%3F', Request.QueryParams) > 0 then
    //Request.QueryParams := mormot.core.buffers.UrlDecode(Request.QueryParams);
  if Pos('?', Request.QueryParams) > 0 then
  begin
    Request.QueryParams := PubString.GetDeliBack(Request.QueryParams, '?');
  end else
    Request.QueryParams := '';
  Request.AuthBearer := Ctxt.AuthBearer;
  Request.AuthenticatedUser := Ctxt.AuthenticatedUser;
  Request.AuthenticationStatus := Ctxt.AuthenticationStatus;

  
  //加入URL
  Request.Params.Clear;
  if trim(Request.QueryParams) <> '' then
  begin
    SL.LineBreak := '&';
    if Pos('=', Request.QueryParams) > 0 then
      SL.Text := Request.QueryParams
    else
      SL.Text := UrlDecode(Request.QueryParams);
    for lp := 0 to SL.Count - 1 do //mormot.core.buffers.UrlDecode(Ctxt.URL);
      Request.Params.Add(UrlDecode(SL[lp]));
  end;

  //加入Post内容
  if Request.ContentType = BINARY_CONTENT_TYPE then
  begin
    Request.ContentText := '';
    Request.PostedData_mORMot := '';
    if Request.PostStream = nil then
      Request.PostStream := TMemoryStream.Create
    else
      Request.PostStream.Clear;
    MyStrem := RawByteStringToStream(ctxt.InContent);
    try
      MyStrem.Seek(0, 0);
      Request.PostStream.CopyFrom(MyStrem, MyStrem.Size);
    finally
      MyStrem.Free;
      ctxt.InContent := '';
    end;
  end else
  //if Pos('multipart', LowerCase(Request.ContentType)) < 1 then
  begin
    //Request.ContentText := ContentText;
    Request.PostedData_mORMot := ctxt.InContent;
    ContentText := Utf8ToAnsi(ctxt.InContent);
    Request.ContentText := ContentText;
    if trim(ContentText) <> '' then
    begin
      i := 1;
      while i <= Length(ContentText) do
      begin
        j := i;
        while (j <= Length(ContentText)) and (ContentText[j] <> '&') do
        begin
          Inc(j);
        end;
        TmpStr := Copy(ContentText, i, j-i);
        TmpStr := StringReplace(TmpStr, '+', ' ', [rfReplaceAll]);
        try
          Request.Params.Add(UrlDecode(TmpStr));
          ////Request.Params.Add((TmpStr));
        except
        end;
        i := j + 1;
      end;
    end;
  end;

  Result := true;
end;

class function TKing_HttpApiServer.MyCreateSession(var AddHead: string; SessionTimeOut: integer; IsCookie: boolean): TminiSession; //SessionTimeOut-秒 默认7天超时
begin

  Result := TminiSession(WSessions.CreateUniqueSession(''));
  Result.SessionName := GetSessionName();
  if SessionTimeOut = 0 then
    WSessions.SessionTimeout := 7 * 24 * 60 * 60 * 1000
  else
    WSessions.SessionTimeout := SessionTimeOut * 1000;
  AddHead := GetCookie_head(Result.SessionID, SessionTimeOut, IsCookie);
end;

class function TKing_HttpApiServer.CreateSession(Response: TminiHTTPResponse; SessionTimeOut: integer; IsCookie: boolean): TminiSession; //SessionTimeOut-秒 默认7天超时
var
  AddHead: string;
begin;
  Result := Response.Session;
  if Result = nil then
  begin
    Result := MyCreateSession(AddHead, SessionTimeOut, IsCookie);
    //Result.Values['tt'] := '测试cook' + DateTimeToStr(Now);
    Response.OutCustomHeaders := trim(trim(Response.OutCustomHeaders) + #13#10 + AddHead);
    Response.Request.Session := Result;
  end;
end;

class function TKing_HttpApiServer.Info(Request: TminiHTTPRequest): boolean;
begin
  if ('/info' = Request.Document) or ('/info/' = Request.Document) then
  begin
    {$ifndef corp}
    Request.Response.ContentText := '网页制作器网址：https://wyeditor.com';
    Request.Response.ContentText := Request.Response.ContentText + '<br>' + '源码及demo下载：https://wyeditor.com/miniframe/';
    Request.Response.ContentText := Request.Response.ContentText + '<br><br>' + '============================================================';
    {$endif}
    Request.Response.ContentText := Request.Response.ContentText + '<br><br>' + 'RemoteIP:' + Request.RemoteIP;
    Request.Response.ContentText := Request.Response.ContentText + '<br>' + 'ProgramDirectory: ' + ServerInfo.ProgramPath;
    Request.Response.ContentText := Request.Response.ContentText + '<br>' + '请求总数: ' + IntToStr(FRequest_AllCount);
    Request.Response.ContentText := Request.Response.ContentText + '<br>' + 'URI: ' + Request.URI;
    Request.Response.ContentText := Request.Response.ContentText + '<br>' + 'Method: ' + Request.Method;
    Request.Response.ContentText := Request.Response.ContentText + '<br>' + 'RequestHost: ' + Request.Host;
    Request.Response.ContentText := Request.Response.ContentText + '<br>' + 'RequestPort: ' + Request.Port;
    Request.Response.ContentText := Request.Response.ContentText + '<br>' + 'Accept: ' + Request.Accept;
    Request.Response.ContentText := Request.Response.ContentText + '<br>' + 'AcceptCharSet: ' + Request.AcceptCharSet;
    Request.Response.ContentText := Request.Response.ContentText + '<br>' + 'AcceptEncoding: ' + Request.AcceptEncoding;
    Request.Response.ContentText := Request.Response.ContentText + '<br>' + 'AcceptLanguage: ' + Request.AcceptLanguage;
    Request.Response.ContentText := Request.Response.ContentText + '<br>' + 'ContentType: ' + Request.ContentType;
    Request.Response.ContentText := Request.Response.ContentText + '<br>' + 'Document: ' + Request.Document;
    Request.Response.ContentText := Request.Response.ContentText + '<br>' + 'QueryParams: ' + Request.QueryParams;
    Request.Response.ContentText := Request.Response.ContentText + '<br>' + 'Referer: ' + Request.Referer;
    Request.Response.ContentText := Request.Response.ContentText + '<br>' + 'UserAgent: ' + Request.UserAgent;
    Request.Response.ContentText := Request.Response.ContentText + '<br>' + 'Params: ' + Request.Params.CommaText;
    if Request.Session <> nil then
    begin
      Request.Response.ContentText := Request.Response.ContentText + '<br>' + 'SessionID: ' + Request.Session.SessionID;
      //{$ifdef debug}
      Request.Response.ContentText := Request.Response.ContentText + '<br>' + 'Sessiondata: ' + Request.Session.Content.CommaText;
      //{$endif}
    end;
    Request.Response.ContentText := Request.Response.ContentText + '<br>' + 'AuthBearer: ' + Request.AuthBearer;
    Request.Response.ContentText := Request.Response.ContentText + '<br>' + 'AuthenticatedUser: ' + Request.AuthenticatedUser;
    Request.Response.ContentText := Request.Response.ContentText + '<br>' + 'AuthenticationStatus: ' + IntToStr(Ord(Request.AuthenticationStatus));

    Request.Response.ContentText := Request.Response.ContentText + '<br>' + 'Cookies: ' + Request.Cookie;
    Request.Response.ContentText := Request.Response.ContentText + '<br><br>' + '原始头部：  <br>' +
      StringReplace(trim(Request.InHeaders), #13#10, '<br>', [rfReplaceAll]);
    Request.Response.ContentText := Request.Response.ContentText + '<br><br>' + 'PostData：  <br>' +
      StringReplace(Request.PostedData_mORMot, #13#10, '<br>', [rfReplaceAll]);

    Request.Response.ContentType := HTML_CONTENT_TYPE;
    Result := true;
    exit;
  end else
    Result := false;
end;

function ProLbackandwiteList(ClientIP: string): boolean;
var
  lp: integer;
  NeedwhiteUsed, NeedblackUsed: boolean;
begin //白名单优先
  Result := false;

  if ClientIP = '127.0.0.1' then exit; //不禁127.0.0.1

  ClientIP := FillDuan(ClientIP);

  NeedwhiteUsed := ServerInfo.whitelist.Count > 100; //超过100，是为了优化
  NeedblackUsed := ServerInfo.blacklist.Count > 100; //超过100，是为了优化

  if NeedwhiteUsed then
    if ServerInfo.Usedwhitelist.IndexOf(ClientIP) > -1 then exit; //在缓存白名单里
  if NeedblackUsed then
  if ServerInfo.Usedblacklist.IndexOf(ClientIP) > -1 then  //在缓存黑名单里
  begin
    Result := true;
    exit;
  end;
  try
    //白名单
    for lp := ServerInfo.whitelist.Count - 1 downto 0 do
    begin
      if Pos('-', ServerInfo.whitelist[lp]) > 0 then
      begin
        if (ClientIP >= PubString.GetDeliPri(ServerInfo.whitelist[lp], '-')) and (ClientIP <= PubString.GetDeliBack(ServerInfo.whitelist[lp], '-')) then
        begin
          if NeedwhiteUsed then
          begin
            if ServerInfo.usedwhitelist.Count > 30000 then
            begin
              CriticalSection.Enter;
              try
                ServerInfo.usedwhitelist.Clear;
              finally
                CriticalSection.Leave;
              end;
            end;
            ServerInfo.usedwhitelist.Add(ClientIP);
          end;
          exit;
        end;
      end else
      begin
        if ServerInfo.whitelist[lp] = ClientIP then
        begin
          if NeedwhiteUsed then
            ServerInfo.usedwhitelist.Add(ClientIP);
          exit;
        end;
      end;
    end;

    //黑名单
    for lp := ServerInfo.blacklist.Count - 1 downto 0 do
    begin
      if Pos('-', ServerInfo.blacklist[lp]) > 0 then
      begin
        if (ClientIP >= PubString.GetDeliPri(ServerInfo.blacklist[lp], '-')) and (ClientIP <= PubString.GetDeliBack(ServerInfo.blacklist[lp], '-')) then
        begin
          if NeedblackUsed then
          begin
            if ServerInfo.usedblacklist.Count > 30000 then
            begin
              CriticalSection.Enter;
              try
                ServerInfo.usedblacklist.Clear;
              finally
                CriticalSection.Leave;
              end;
            end;
            ServerInfo.usedblacklist.Add(ClientIP);
          end;
          Result := true;
          exit;
        end;
      end else
      begin
        if ServerInfo.blacklist[lp] = ClientIP then
        begin
          if NeedblackUsed then
            ServerInfo.usedblacklist.Add(ClientIP);
          Result := true;
          exit;
        end;
      end;
    end;

  except
  end;
end;

class function TKing_HttpApiServer.mORMot_Request(Ctxt: THttpServerRequestAbstract): cardinal;
var
  SL: TStringList;
  mORMotHeadInfo: TmORMotHeadInfo;
  Request: TminiHTTPRequest;
  Response: TminiHTTPResponse;
  Session: TminiSession;
  Contentext, NewLDoc, OldLDoc1, Ext, OldLDoc, HTMLName, Document, Service_Path, id, TmpStr,
    ExecName, FileName, Code, OutHead, cache, Cookiehead, ClientIP: string;
  Sa: TArray<string>;
  OFlag, Flag, NFlag: boolean;
  tmpSS: TStream;
  lp: integer;
  DMInfo: TDMInfo;
  IsSetting: boolean;
  function GetHTMLName_executeOther: boolean;
  var
    lp: integer;
  begin
    Result := false;
    HTMLName := '';
    //2023-06-11 mod OldLDoc := Document; // Client.Path;
    OldLDoc := PubString.GetDeliPri(Document, '?');
    OldLDoc1 := OldLDoc;
    if (Pos('.', OldLDoc) < 1) and (DirectoryExists(Service_Path + OldLDoc))then
    begin
      TmpStr := copy(OldLDoc,length(OldLDoc),1);
      if (TmpStr ='/') or (TmpStr = '\') then
      else
        exit; //这里执行网页302跳转
    end;
    if copy(OldLDoc,length(OldLDoc),1)='/' then
    begin
      TmpStr := Service_Path + OldLDoc +'index.html';
      TmpStr := StringReplace(TmpStr, '/', '\', [rfReplaceAll]);
      TmpStr := StringReplace(TmpStr, '\\', '\', [rfReplaceAll]);
      if FileExists(TmpStr) then
        OldLDoc := OldLDoc + 'index.html'
      else
        OldLDoc := OldLDoc + 'index.htm';
    end;
    if copy(OldLDoc,1,1)='/' then delete(OldLDoc,1,1);

    OldLDoc := StringReplace(OldLDoc, '/', '\', [rfReplaceAll, rfIgnoreCase]); //2020-03-13 add

    NewLDoc := OldLDoc;
    OFlag := FileExists(Service_Path + OldLDoc);
    Ext := LowerCase(ExtractFileExt(OldLDoc));

    //if SameText(ext, '.asp') and SameText('bbs', LowerCase(NewLDoc)) then //自用
    if SameText(ext, '.asp') and (Pos('bbs\', LowerCase(NewLDoc)) = 1) then //自用
    begin
      Flag := false;
    end else
      Flag := (Pos(LowerCase(Ext), ServerInfo.serviceext) > 0) or ((Pos('/$/', Document) = 1) and SameText(Ext, '.html'));
    NFlag := false;
    if not OFlag then
    begin
      NewLDoc := ChangeFileExt(OldLDoc, '.psp');
      NFlag := FileExists(Service_Path + NewLDoc);
    end;

    if NFlag or OFlag then
    begin
      ExecName := NewLDoc;
      if Flag then
      begin

      end else
      if GetYs_From_EXT(Ext, ServerInfo.YsHost) then
      begin //2020-02-17 add

      end else
      begin //其他文件，如exe,js,png,bmp,gif,jpg,css,txt.....
        FileName := Service_Path + OldLDoc;
        {Ctxt.OutContentType := string(GetFileContentType(FileName));
        Ctxt.OutContent := AnyTextFileToRawUTF8(FileName, true); }

        Ctxt.OutContentType := STATICFILE_CONTENT_TYPE;
        Ctxt.OutContent := UTF8Encode(FileName);
        Ctxt.OutCustomHeaders := GetMimeContentTypeHeader('', FileName);

        Result := true;
      end;
    end else
    if AnsiSameText(OldLDoc, 'index.htm') then
    begin
    end else
    //2022-10-06 add 'doc\999999999999999999'
    //为了支持 http://127.0.0.1/doc/search/999999999999999999， 999999999999999999为文章ID，search文夹下必须有 search.html作为调用的模板
    begin
      OldLDoc1 := StringReplace(OldLDoc1, '/', '\', [rfReplaceAll]);
      TmpStr := OldLDoc1;
      if TmpStr[length(TmpStr)] = '\' then TmpStr := Copy(TmpStr, 1, length(TmpStr) - 1);
      Sa := TmpStr.Split(['\']);
      if length(Sa) > 1 then
      begin
        Code := Sa[length(Sa) - 1];
      end;
      TmpStr := '';
      for lp := 0 to length(Sa) - 2 do
      begin
        if lp = 0 then
          TmpStr := Sa[lp]
        else
          TmpStr := TmpStr + '\' + Sa[lp];
        if lp = length(Sa) - 2 then
          TmpStr := TmpStr + '\' + Sa[lp];
      end;
      if FileExists(Service_Path + TmpStr + '.html') then
      begin
        HTMLName := TmpStr + '.html';
        //Result := false;
        exit;
      end else
    end;
  end;
  function Getclientcachefile(): boolean;
  var
    Ext: string;
  begin //true=不缓存
    Ext := LowerCase(ExtractFileExt(ExecName));
    if Pos('1-', ServerInfo.clientcachefile) > 0 then
      Result := false
    else
    if Pos('2-', ServerInfo.clientcachefile) > 0 then
      Result := (Ext = '.psp') or (Ext = '.htm') or (Ext = '.html')
    else
    if Pos('3-', ServerInfo.clientcachefile) > 0 then
      Result := (Ext = '.psp') or (Ext = '.htm') or (Ext = '.html') or (Ext = '.css')
    else
    if Pos('4-', ServerInfo.clientcachefile) > 0 then
      Result := (Ext = '.psp') or (Ext = '.htm') or (Ext = '.html') or (Ext = '.css') or (Ext = '.js')
    else
    if Pos('5-', ServerInfo.clientcachefile) > 0 then
      Result := (Ext = '.rar') or (Ext = '.zip') or (Ext = '.exe') or (Ext = '.apk') or (Ext = '.app')
    else
    if Pos('6-', ServerInfo.clientcachefile) > 0 then
      Result := (Ext = '.rar') or (Ext = '.zip') or (Ext = '.exe') or (Ext = '.apk') or (Ext = '.app') or
        (Ext = '.psp') or (Ext = '.htm') or (Ext = '.html')
    else
    if Pos('7-', ServerInfo.clientcachefile) > 0 then //所有
      Result := true
    else
      Result := true;
  end;
begin

  ///////////////////////////////////////////////////////////////////////////////////////////
  Result := 200;

  CriticalSection.Enter;
  FRequest_AllCount := FRequest_AllCount + 1;
  FWorking_thread_Count := FWorking_thread_Count + 1;
  CriticalSection.Leave;
  try
    Document := mormot.core.buffers.UrlDecode(Ctxt.URL);
    Service_Path := GetService_Path(Ctxt.Host, Document, IsSetting); //FService_Main;
    Ctxt.OutContentType := HTML_CONTENT_TYPE;
    Ctxt.OutCustomHeaders := '';
    SL := TStringList.Create;
    try
      SL.LineBreak := sLineBreak;
      SL.Text := Ctxt.InHeaders;
      for lp := 0 to SL.Count - 1 do
        SL[lp] := StringReplace(SL[lp], ': ', '=', [rfIgnoreCase]);
      ClientIP := GetRemoteIP(SL, Ctxt);
      ////其他文件，如exe,js,png,bmp,gif,jpg,css,txt.....
      if GetHTMLName_executeOther then
      begin //记录图片静态文件
        if FLogInfo.FIsLog and ('/' + ServerInfo.errorpage <> Document) then
          WriteServiceLogToFile(0, nil, ClientIP, Document, Ctxt.UserAgent, Ctxt.Host);
        exit;
      end;

      //服务器配置IP限制处理, IP黑的名单
      if ProLbackandwiteList(ClientIP) or IsSetting and ServerInfo.openby127_0_0_1 and (ClientIP <> '127.0.0.1') then
      begin
        Result := 403;
        TmpStr := '[' + ClientIP + ']被禁止访问(Error code: 403)!';
        Ctxt.OutContentType := 'text/html;charset=UTF-8';
        {$ifndef fpc}
        Ctxt.OutContent := AnsiToUtf8(TmpStr);
        {$else}
        Ctxt.OutContent := string(TmpStr);
        {$endif}
        exit;
      end;

      //处理session
      id := Ctxt.AuthBearer;
      if id = '' then id := GetSessionID(SL.Values['Cookie']);
      if not MyFindSession(Session, Ctxt, id, SL.Values['Referer'], ServerInfo.SessionTimeout, Ctxt.AuthBearer = '') then
      begin
        Result := 302;
        exit;
      end;
      Cookiehead := Ctxt.OutCustomHeaders;

      DMInfo := GetDMInfo(Ctxt);
      {$ifndef nonedmmaxcount}
      if DMInfo = nil then
      begin
        Ctxt.OutContentType := 'text/html;charset=UTF-8';
        Ctxt.OutContent := '服务太忙，请稍候再试(Error code: 5000)!';
        exit;
      end else
      {$endif}
      begin
        try
          Response := DMInfo.Response;
          Request := DMInfo.Request;
          Request.Session := Session;

          Response.OutCustomHeaders := '';
          Response.ContentType := '';
          Response.SessionTimeout := ServerInfo.SessionTimeout;
          //注意：请求的信息已存放于 Request 中，响应的信息要存于 Response.OutCustomHeaders、Response.OutContentType和 Response.OutContent中
          //Requst.Headers中取请求的头部值，从 Request.Params取请求的Post内容或URL中的值
          if not ToRequest(Document, SL, Ctxt, mORMotHeadInfo, Request) then exit;

          //主处理 始
          //创建session测试, session是需要时(一般是登录成功后)再创建 , 如果是跨域采用 AuthBearer，则IsCookie要设置为 false
          //CreateSession(Response, SessionTimeout);
          //主处理 结束

          try
            //查看请求信息
            if not Info(Request) then
            begin
              if FLogInfo.FIsLog and ('/' + ServerInfo.errorpage <> Document) then
              begin
                TmpStr := Request.Port;
                if trim(TmpStr) = '' then TmpStr := '0';
                WriteServiceLogToFile(StrToInt(TmpStr), Request);
              end;
              ExecName := '';
              Response.ContentType := 'text/html;charset=UTF-8';
              if HTMLName <> '' then
              begin //2022-10-06
                OldLDoc := HTMLName;
                Request.Params.Add('code=' + Code);
              end else
                OldLDoc := Request.Document; // Client.Path;
              OldLDoc1 := OldLDoc;
              if (Pos('.', OldLDoc) < 1) and (DirectoryExists(Service_Path + OldLDoc))then
              begin
                TmpStr := copy(OldLDoc,length(OldLDoc),1);
                if (TmpStr ='/') or (TmpStr = '\') then
                else
                begin //这里执行网页302跳转
                  OldLDoc := StringReplace(UrlEncode(OldLDoc + '/'), '%2F', '/', [rfReplaceAll, rfIgnoreCase]);
                  OutHead := MyRedirect(Response.OutCustomHeaders, OldLDoc);
                  Result := 302;
                  Ctxt.OutContent := '';
                  Ctxt.OutCustomHeaders := OutHead;
                  exit;
                end;
              end;
              if copy(OldLDoc,length(OldLDoc),1)='/' then
              begin
                TmpStr := Service_Path + OldLDoc +'index.html';
                TmpStr := StringReplace(TmpStr, '/', '\', [rfReplaceAll]);
                TmpStr := StringReplace(TmpStr, '\\', '\', [rfReplaceAll]);
                if FileExists(TmpStr) then
                  OldLDoc := OldLDoc + 'index.html'
                else
                  OldLDoc := OldLDoc + 'index.htm';
              end;
              if copy(OldLDoc,1,1)='/' then delete(OldLDoc,1,1);

              OldLDoc := StringReplace(OldLDoc, '/', '\', [rfReplaceAll, rfIgnoreCase]); //2020-03-13 add

              NewLDoc := OldLDoc;
              OFlag := FileExists(Service_Path + OldLDoc);
              Ext := LowerCase(ExtractFileExt(OldLDoc));

              //if SameText(ext, '.asp') and SameText('bbs', LowerCase(NewLDoc)) then
              if SameText(ext, '.asp') and (Pos('bbs\', LowerCase(NewLDoc)) = 1) then //自用
              begin
                Flag := false;
              end else
                Flag := (Pos(LowerCase(Ext), ServerInfo.serviceext) > 0) or ((Pos('/$/', Document) = 1) and SameText(Ext, '.html'));
              NFlag := false;
              if not OFlag then
              begin
                NewLDoc := ChangeFileExt(OldLDoc, '.psp');
                NFlag := FileExists(Service_Path + NewLDoc);
              end;

              if NFlag or OFlag then
              begin
                ExecName := NewLDoc;
                if Flag then
                begin
                  TmpStr := Request.Port; // Client.RequestHostPort;
                  if trim(TmpStr) = '' then TmpStr := '0';
                  TRunner.RunOnePspFile(DMInfo, Request.Session, Service_Path, Service_Path + NewLDoc, StrToInt(TmpStr), Request, Response);
                end else
                if GetYs_From_EXT(Ext, ServerInfo.YsHost) then
                begin //2020-02-17 add
                  TmpStr := Request.Port; // Client.RequestHostPort;
                  if trim(TmpStr) = '' then TmpStr := '0';
                  TRunner.LoadYsFile(StrToInt(TmpStr), ServerInfo.YsHost, OldLDoc, Request, Response);
                end else
                //FService_YS
                begin
                  TmpStr := Request.Port; // Client.RequestHostPort;
                  if trim(TmpStr) = '' then TmpStr := '0';
                  TRunner.LoadOtherFile(OldLDoc, Service_Path + OldLDoc, StrToInt(TmpStr), Request, Response);
                end;
              end else
              if SameText(OldLDoc, 'index.htm') then
              begin
                ExecName := 'index.htm';
                TmpStr := Request.Port; // Client.RequestHostPort;
                if trim(TmpStr) = '' then TmpStr := '0';
                TRunner.RunOnePspFile(DMInfo, Request.Session, Service_Path, Service_Path + 'index.psp', StrToInt(TmpStr), Request, Response);
              end else
              begin
                Result := 404;
                TmpStr := Request.Port; // Client.RequestHostPort;
                if trim(TmpStr) = '' then TmpStr := '0';
                TRunner.GoToErrPage(DMInfo, Request.Session, Service_Path, OldLDoc, StrToInt(TmpStr), Request, Response,
                  ' !'); //'无法找到文件[' + ReplacExt(ExtractFileName(OldLDoc)) + ']！Error code: 8000)';
              end;
            end;
          except
            on e: exception do
            begin
              TmpStr := Request.Port; // Client.RequestHostPort;
              if trim(TmpStr) = '' then TmpStr := '0';
              WriteRunLogToFile(e.Message + GetOthInfo(StrToInt(TmpStr), Request)); //2019-10-25 add
            end;
          end;

          if '[%Redirect_302%]' = Response.ContentText then
          begin
            TmpStr := trim(Response.OutURL);
            //if (trim(TmpStr) <> '') and (TmpStr[1] = '/') then TmpStr := Copy(TmpStr, 2, MaxInt);
            ///if {$ifdef fpc}true or {$endif}(Pos('%26', TmpStr) > 0) or (Pos('%2F', TmpStr) > 0) or (Pos('%3F', TmpStr) > 0) then
              Response.ContentText := string('<script>var intervalId = setInterval(function(){ clearInterval(intervalId); window.location.href=''' + TmpStr + ''';},200);</script>')
            (*else
            begin
              if Pos('?', TmpStr) > 0 then
                TmpStr := GetDeliPri(TmpStr, '?') + '?' + UrlEncode(GetDeliBack(TmpStr, '?'))
              else
                TmpStr := UrlEncode(TmpStr);

              Response.ContentText := string('<script>var intervalId = setInterval(function(){ clearInterval(intervalId); window.location.href=''' + TmpStr + ''';},200);</script>');
              //Response.ContentText := string('<script>var intervalId = setInterval(function(){ clearInterval(intervalId); window.location.href=''' + trim(TmpStr) + ''';},200);</script>');
            end; *)
          end;
          if Cookiehead <> '' then
            Cookiehead := #13#10 + Cookiehead;
          if Getclientcachefile then
          begin
            cache :=
              'Date: ' + LocalDateTimeToHttpStr(Now) + #13#10 +
              'Expires: '+ LocalDateTimeToHttpStr(IncDay(Now, -30)) + Cookiehead;
          end else
            cache :=
              'Date: ' + LocalDateTimeToHttpStr(Now) + #13#10 +
              'Expires: '+ LocalDateTimeToHttpStr(IncDay(Now, 1)) + Cookiehead;
          if Response.OutCustomHeaders = '' then
            Response.OutCustomHeaders := cache
          else
            Response.OutCustomHeaders := cache + #13#10 + Response.OutCustomHeaders;

          //头部输出处理，如果不是使用Cookie，而是Authorization
          //add 2023-01-04 解决跨域问题
          if ServerInfo.crossdomain then
          begin
            Response.OutCustomHeaders := Response.OutCustomHeaders + #13#10 + 'Access-Control-Allow-Origin: *' +
              #13#10 + 'Access-Control-Allow-Credentials: true' +
              #13#10 + 'Access-Control-Allow-Headers: DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization';
          end;

          cache := '';
          if Response.ContentStream <> nil then
          begin
            tmpSS := Response.ContentStream;
            try
              Ctxt.OutContentType := Response.ContentType;
              Ctxt.OutCustomHeaders := Response.OutCustomHeaders;
              tmpSS.Position := 0;
              Ctxt.OutContent := StreamToRawByteString(tmpSS);
              Response.ContentStream := nil;
            finally
              tmpSS.Free;
            end;
          end else
          begin
            Contentext := Response.ContentText;
            if Response.ContentType = 'text/html' then
            begin
              Ctxt.OutCustomHeaders := Response.OutCustomHeaders;
              Ctxt.OutContentType := 'text/html;charset=UTF-8';
              (*{$ifndef fpc}
              Ctxt.OutContent := AnsiToUtf8(string(Contentext));
              {$else}
              Ctxt.OutContent := string(Contentext)
              {$endif} *)
              Ctxt.OutContent := Contentext;
            end else
            begin
              Ctxt.OutCustomHeaders := Response.OutCustomHeaders;
              Ctxt.OutContentType := Response.ContentType;
              (*if Pos('UTF-8', UpperCase(Response.ContentType)) > 0 then
                {$ifndef fpc}
                Ctxt.OutContent := AnsiToUtf8(Response.ContentText)
                {$else}
                Ctxt.OutContent := string(Response.ContentText)
                {$endif}
              else
                Ctxt.OutContent := string(Response.ContentText);*)
              Ctxt.OutContent := Response.ContentText;
            end;
            {$ifdef mswindows}
            if Pos('UTF-8', UpperCase(Response.ContentType)) > 0 then
              Ctxt.OutContent := AnsiToUtf8(Response.ContentText);
            {$endif}
            Result := 200;
          end;
        finally
          DMInfo.HadUsed := false;
        end;
      end;
    finally
      SL.Free;
    end;

  finally
    CriticalSection.Enter;
    FWorking_thread_Count := FWorking_thread_Count - 1;
    CriticalSection.Leave;
  end;
end;
{ TToInfo }

constructor TToInfo.Create;
begin
  FreeOnTerminate := true;
  inherited Create(False);
  FreeOnTerminate := true;
end;

procedure TToInfo.Execute;
var
  SL: TStringlist;
  Count: integer;
begin
  inherited;
  SL := TStringlist.Create;
  try
    while not Terminated do
    begin
      Sleep(1500);
      try
        SL.Values['Time'] := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now);
        SL.Values['程序路径'] := ServerInfo.ProgramPath;// ExtractFilePath(ParamStr(0));
        SL.Values['服务开始时间'] := FormatDateTime('yyyy-mm-dd hh:nn:ss', ServerInfo.Starttime);
        SL.Values['服务运行总时间(秒)'] := Round((Now - ServerInfo.Starttime)*86400).ToString;
        SL.Values['服务运行总时间(小时)'] := FormatFloat('0.00', (Now - ServerInfo.Starttime)*86400/3600);
        SL.Values['总访问量'] := IntToStr(FRequest_AllCount);
        if ((Now - ServerInfo.Starttime)*86400/60) = 0 then
          SL.Values['访问量/分钟'] := SL.Values['总访问量']
        else
          SL.Values['访问量/分钟'] := IntToStr(Round(FRequest_AllCount/((Now - ServerInfo.Starttime)*86400/60)));
        SL.Values['正在工作的线程数'] := IntToStr(FWorking_thread_Count);
        SL.Values['当前数据库池总数'] := IntToStr(ConnList.Count); //'数据库池: ' + IntToStr(ConnList.Count);
        SL.Values['当前运算池总数'] := IntToStr(DMList.Count);
        SL.Values['当前中间代码池总数'] := IntToStr(ScriptList.Count);

        if WSessions = nil then
          Count := 0
        else
        begin
          Count := WSessions.SessionList.LockList.Count;
          WSessions.SessionList.UnlockList;
        end;

        SL.Values['当前会话数总数'] := IntToStr(Count);

        SL.SaveToFile(ExtractFilePath(ParamStr(0)) + '运行信息.txt', TEncoding.UTF8);
      except
      end;
    end;
  finally
    SL.Free;
  end;
end;

class procedure TKing_HttpApiServer.StartService;
var
  RInfo, ErrStr, Port: string;
  http: THttpAsyncServer;
  https: THttpAsyncServer;
  procedure MyWriteln(Text: string);
  begin
    WriteRunLogToFile(Text);
    Writeln(trim(Text));
  end;
  function MyStart: boolean;
  begin
    Result := false;
    ErrStr := ReadParams;
    if trim(ErrStr) <> '' then
    begin
      MyWriteln(' 读取配置出错，请检查（setting\conf.json）！' + ErrStr);
      ReadLn;
      exit;
    end;

    MyWriteln(#13#10 + FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ' >############服务正在运行############...');
    Port := ServerInfo.httpport; // '899';
    try
      MyWriteln('>正在开启HTTP服务...');
      {$ifdef htmleditor}
      http := THttpAsyncServer.Create('899', nil, nil,
          'miniframe', 2);
      http.HttpQueueLength := 100;
      {$else}
      http := THttpAsyncServer.Create(Port, nil, nil,
          'miniframe', ServerInfo.threadcount);
      http.HttpQueueLength := ServerInfo.quequelength;
      {$endif}
      http.OnRequest := TKing_HttpApiServer.mORMot_Request;

      if ServerInfo.AutoZip then
      begin
        MyWriteln('>已启用压缩传输...');
        http.RegisterCompress(CompressDeflate);
        http.RegisterCompress(CompressGZip);
        http.RegisterCompress(CompressZLib);
        http.RegisterCompress(CompressSynLZ);
      end;
      if ServerInfo.crossdomain then
      begin
        MyWriteln('>已启用允许跨域访问...');
      end;
      http.WaitStarted();
    except
      on e: exception do
      begin
        Writeln(#13#10);
        MyWriteln('*****开启HTTP服务出错，请自行修改“setting\conf.json->httpport的值为其他值再试”！' + e.Message);
        MyWriteln('8秒后将自动退出！');
        Writeln(#13#10);
        Sleep(8000);
        exit;
      end;
    end;
    MyWriteln('>HTTP服务已成功开启！');
    MyWriteln('>HTTP服务端口：' + ServerInfo.httpport + '...');
    MyWriteln('>服务域名与目录：' + ServerInfo.oldhosttodir + '...');
    https := nil;
    if ServerInfo.starthttps then
    begin  // 启动https
      MyWriteln('>正在开启HTTPS服务...');
      try
        {$ifdef htmleditor}
        https := THttpAsyncServer.Create(ServerInfo.httpsport, nil, nil, 'miniframe',
          2, 100, [hsoNoXPoweredHeader, hsoEnableTls]);
        {$else}
        https := THttpAsyncServer.Create(ServerInfo.httpsport, nil, nil, 'miniframe',
          ServerInfo.threadcount, 30000, [hsoNoXPoweredHeader, hsoEnableTls]);
        {$endif}
        https.HttpQueueLength := ServerInfo.quequelength;
        https.OnRequest := TKing_HttpApiServer.mORMot_Request;
        if ServerInfo.AutoZip then
        begin
          https.RegisterCompress(CompressDeflate);
          https.RegisterCompress(CompressGZip);
          https.RegisterCompress(CompressZLib);
          https.RegisterCompress(CompressSynLZ);
        end;
        https.WaitStarted(30,  ServerInfo.cert, ServerInfo.secretkey, ServerInfo.secretkeypwd, ServerInfo.rootcert);
        MyWriteln('>HTTPS服务已成功开启！');
      except
        on e: exception do
        begin
          Writeln(#13#10);
          MyWriteln('*****开启HTTPS服务出错，请登录服务器配置页面修改“HTTPS->服务端口”或自行修改“setting\conf.json->httpsport的值为其他值再试”！' + e.Message);
          Writeln(#13#10);
        end;
      end;
    end;

    //http://127.0.0.1:899/%24/
    Writeln('');
    Writeln('--------------------------------------------------------------------');
    MyWriteln('1.可通过 http://127.0.0.1:' + ServerInfo.httpport + '/$/ 进入服务器配置页面进行服务器配置，默认登录用户和密码都是admin');
    MyWriteln('2.可通过 http://127.0.0.1:' + ServerInfo.httpport + '/info 查相关的访问信息');
    {$ifndef corp}
    MyWriteln('3.miniframe开源Web框架技术群：821855479 如果加不了群，请联系QQ：3123827806');
    MyWriteln('4.网页制作器网址：https://wyeditor.com');
    MyWriteln('5.源码及demo下载：https://wyeditor.com/miniframe/');
    {$endif}
    Writeln('--------------------------------------------------------------------');

    Writeln('');
    Result := true;
  end;
begin
  FormatSettings.ShortDateFormat := 'YYYY-MM-DD';
  FormatSettings.ShortTimeFormat := 'HH:MM:SS';
  FormatSettings.LongDateFormat := 'YYYY-MM-DD';
  FormatSettings.LongTimeFormat := 'HH:MM:SS';
  FormatSettings.TimeSeparator := ':';
  FormatSettings.dateSeparator := '-';

  try
    if FileExists(ServerInfo.ProgramPath + 'setting\start__.f') then
       DeleteFile(ServerInfo.ProgramPath + 'setting\start__.f');
    Sleep(1500);
    if ParamCount > 1 then
      Writeln(ParamStr(1));
    if not MyStart then exit;
    try
      while True do
      begin
        Sleep(1000);
        Writeln('>如需要结束当前运行，请输入“Y”!需要重启程序请按“r”，只需重启服务请按“R”！');
        Readln(RInfo);
        if UpperCase(RInfo) = 'Y' then
        begin
          Writeln('>3秒后将结束当前运行...');
          Sleep(3000);
          break;
        end else
        if (RInfo = 'r') or (FileExists(ServerInfo.ProgramPath + 'setting\start__.f')) then
        begin //完全重启exe
          Writeln('>3秒后将结束当前服务并重启程序...');
          Sleep(3000);
          http.Free;
          http := nil;
          if https <> nil then
          begin
            https.Free;
            https := nil;
          end;
          Sleep(1000);
          {$ifdef mswindows}
          ShellExecute(0, 'Open', PChar(ParamStr(0)), nil, nil, 1)
          {$endif};
          exit;
        end else
        if RInfo = 'R' then
        begin //只重启服务
          Writeln('>3秒后将结束当前服务并重启服务...');
          Sleep(3000);
          http.Free;
          http := nil;
          if https <> nil then
          begin
            https.Free;
            https := nil;
          end;
          Sleep(1000);
          MyStart;
        end;
      end;
    finally
      http.Free;
      if https <> nil then
        https.Free;
    end;
  except
    on E: Exception do
    begin
      MyWriteln(E.ClassName + ': ' + E.Message);
      MyWriteln('*****开启HTTP服务出错，请自行修改“setting\conf.jsont的相关值后再试”！');
      Sleep(5000);
    end;
  end;
end;

initialization
  ServerInfo.Starttime := Now;
  FRequest_AllCount := 0;
  WSessions := TIdHTTPDefaultSessionList.Create(nil);
  TToInfo.Create;
  CriticalSection := TMiniCriticalSection.Create;

finalization
  CriticalSection.Free;
  FreeAndNil(WSessions);

end.

