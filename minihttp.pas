unit minihttp;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  Classes, SysUtils,
  mormot.net.http,
  mormot.net.server,
  mormot.core.os,
  mormot.core.base,
  mormot.core.threads,
  mormot.core.zip,
  mormot.net.async,
  mormot.core.buffers,
  mormot.core.text,
  PubStringUnit,
  IdGlobal,
  dateutils,
  IdCustomHTTPServer,
  IdGlobalProtocols,
  IdMessageCoderMIME
  {$ifndef FPC},System.NetEncoding{$else}{$endif};

const
  cSesssionName = 'miniframe_';

type
  TminiSession = class(TIdHTTPSession)

  end;

  TmORMotHeadInfo = record
      Host, User_Agent, Referer, Content_Type, Transfer_Encoding, Pragma, Cookie, X_Real_IP: string;
    end;

  { TminiHTTPRequest }
  TminiHTTPResponse = class;

  TminiHTTPRequest = class
  private
    FAccept: String;
    FAcceptCharSet: String;
    FAcceptEncoding: String;
    FAcceptLanguage: String;
    FAuthBearer: string;
    FAuthenticatedUser: string;
    FAuthenticationStatus: THttpServerRequestAuthentication;
    //FAuthorization: string;
    FContentText: string;
    FContentType: string;
    FCookie: string;
    FDocument: string;
    FFrom: String;
    FHost: String;
    FHeaders: TStrings;
    FInHeaders: string;
    FMethod: string;
    FParams: TStrings;
    FPort: String;
    FPostedData_mORMot: RawByteString;
    //FPostStream: TStream;
    FQueryParams: string;
    FReferer: String;
    FRemoteIP: String;
    FResponse: TminiHTTPResponse;
    FService_FileName: string;
    FService_Path: string;
    FSession: TminiSession;
    FURI: string;
    FUserAgent: String;
    FPostStream: TMemoryStream;
    FDMInfo: TObject;
    function GetURI: string;
    procedure SetAuthBearer(AValue: string);
    procedure SetAuthenticatedUser(AValue: string);
    procedure SetAuthenticationStatus(AValue: THttpServerRequestAuthentication);
    procedure SetContentText(AValue: string);
    procedure SetContentType(AValue: string);
    procedure SetCookie(AValue: string);
    procedure SetInHeaders(AValue: string);
    procedure SetMethod(AValue: string);
    procedure SetService_FileName(AValue: string);
    procedure SetService_Path(AValue: string);
    function GetPostedData: string;
    procedure SetDMInfo(const Value: TObject);
    function GetSessionid: string;
    function GetRemoteIP: String;
  public
    constructor Create();// override;
    destructor Destroy;override;

    //取一项URL或Post的值，返回值为string
    function V(const FieldName: string): string;
    //把multipart/form-data上传的附件保存到Path下
    function DecodeFJ(Path: string): boolean;   //default：true    //default false
    //把multipart/form-data上传的附件保存到Path下, NeedRandomFileName为true随机文件名，NeedFileMd5为true把文件md5后作为文件名
    function DecodeFJ2(Path: string; NeedRandomFileName: boolean; NeedFileMd5: boolean): boolean;
    //把URL或post上传的data保存到URL中
    function ParamsToURL: string;
    property DMInfo: TObject read FDMInfo write SetDMInfo;
  published
    property RemoteIP: String read GetRemoteIP write FRemoteIP;
    property Host: String read FHost write FHost;
    property Port: String read FPort write FPort;
    property Document: string read FDocument write FDocument;
    property URI: string read FURI write FURI;
    property URL: string read GetURI;
    property Params: TStrings read FParams;
    property ContentType: string read FContentType write SetContentType;
    property ContentText: string read FContentText write SetContentText;
    property Method: string read FMethod write SetMethod;
    property Accept: String read FAccept write FAccept;
    property AcceptCharSet: String read FAcceptCharSet write FAcceptCharSet;
    property AcceptEncoding: String read FAcceptEncoding write FAcceptEncoding;
    property AcceptLanguage: String read FAcceptLanguage write FAcceptLanguage;
    property From: String read FFrom write FFrom;
    property Referer: String read FReferer write FReferer;
    property UserAgent: String read FUserAgent write FUserAgent;
    property Session: TminiSession read FSession write FSession;
    property PostedData_mORMot: RawByteString read FPostedData_mORMot write FPostedData_mORMot;
    property PostedData: String read GetPostedData;
    property Response: TminiHTTPResponse read FResponse write FResponse;
    property PostStream: TMemoryStream read FPostStream write FPostStream;
    property QueryParams: string read FQueryParams write FQueryParams;
    property InHeaders: string read FInHeaders write SetInHeaders;
    property Headers: TStrings read FHeaders;
    property Cookie: string read FCookie write SetCookie;
    property AuthBearer: string read FAuthBearer write SetAuthBearer;
    property AuthenticatedUser: string read FAuthenticatedUser write SetAuthenticatedUser;
    property AuthenticationStatus: THttpServerRequestAuthentication read FAuthenticationStatus write SetAuthenticationStatus;
    property Service_Path: string read FService_Path write SetService_Path;
    property Service_FileName: string read FService_FileName write SetService_FileName;
    property Remote_FileName: string read FService_FileName write SetService_Path;
    property SessionID: string read GetSessionid;
  end;

  { TminiHTTPResponse }

  TminiHTTPResponse = class
  private
    FContentStream: TStream;
    FContentText: RawByteString; //{$ifdef fpc}RawByteString{$else}string{$endif};
    FContentType: string;
    FOutCustomHeaders: string;
    FOutURL: string;
    FRequest: TminiHTTPRequest;
    FSessionTimeout: integer;
    function GetSession: TminiSession;
    procedure SetContentType(AValue: string);
    procedure SetOutURL(AValue: string);
    procedure SetSessionTimeout(AValue: integer);
  public
    constructor Create(aResquest: TminiHTTPRequest);
    destructor Destroy;override;

    //跳转，同OutURL
    procedure Redirect(const Url: string);
    //清空当前输出的内容
    procedure Clear;
    //返回一个文件
    procedure SendFileToClient(FileName: string);
  published
    property Request: TminiHTTPRequest read FRequest;
    //输出HTTP头
    property OutCustomHeaders: string read FOutCustomHeaders write FOutCustomHeaders;
    //输出的ContentType
    property ContentType: string read FContentType write SetContentType;
    //输出流
    property ContentStream: TStream read FContentStream write FContentStream;
    //输出内容，输出流优先于输出内容
    property ContentText: RawByteString (*{$ifdef fpc}RawByteString{$else}string{$endif}*) read FContentText write FContentText;
    //当前会话
    property Session: TminiSession read GetSession;


    //会话超时时间，内部调用，不向脚本引擎器开放
    property SessionTimeout: integer read FSessionTimeout write SetSessionTimeout;
    //跳转网址
    property OutURL: string read FOutURL write SetOutURL;
  end;

  function UrlEncode(URL: string): string;
  function UrlDecode(URL: string): string;


implementation

uses IdMessageCoder, PubSysUnit, miniscriptcontroller;

{ TminiHTTPRequest }


function MyEncodeUrl(url: string): string;
var
  x: integer;
  sBuff: string;
const
  SafeMask = ['A'..'Z', '0'..'9', 'a'..'z', '*', '@', '.', '_', '-'];
begin
  //Init
  sBuff := '';

  for x := 1 to Length(url) do
  begin
    //Check if we have a safe char
    if url[x] in SafeMask then
    begin
      //Append all other chars
      sBuff := sBuff + url[x];
    end
    else if url[x] = ' ' then
    begin
      //Append space
      sBuff := sBuff + '+';
    end
    else
    begin
      //Convert to hex
      sBuff := sBuff + '%' + IntToHex(Ord(url[x]), 2);
    end;
  end;

  Result := sBuff;
end;

function MyDecodeUrl(url: string): string;
var
  x: integer;
  ch: string;
  sVal: string;
  Buff: string;
begin
  //Init
  Buff := '';
  x := 1;
  while x <= Length(url) do
  begin
    //Get single char
    ch := url[x];

    if ch = '+' then
    begin
      //Append space
      Buff := Buff + ' ';
    end
    else if ch <> '%' then
    begin
      //Append other chars
      Buff := Buff + ch;
    end
    else
    begin
      //Get value
      sVal := Copy(url, x + 1, 2);
      //Convert sval to int then to char
      Buff := Buff + char(StrToInt('$' + sVal));
      //Inc counter by 2
      Inc(x, 2);
    end;
    //Inc counter
    Inc(x);
  end;
  //Return result
  Result := Buff;
end;

function UrlEncode(URL: string): string;
begin
  Result := mormot.core.buffers.UrlEncode(URL);
  (*{$ifdef FPC}
  Result := MyEncodeUrl(URL);
  {$else}
  Result := TNetEncoding.URL.Encode(URL);//HttpEncode(UTF8Encode(ansistring(URL))); //UrlEncode(UTF8Encode(URL));
  {$endif}   *)
end;

function UrlDecode(URL: string): string;
begin
  Result := mormot.core.buffers.UrlDecode(URL);
  (*{$ifdef FPC}
  Result := MyDecodeUrl(URL);
  {$else}
  Result := TNetEncoding.URL.Decode(URL);//UTF8Decode(HttpDecode(URL));//UTF8Decode(UrlDecode(URL));
  {$endif}*)
end;

procedure TminiHTTPRequest.SetContentType(AValue: string);
begin
  if FContentType=AValue then Exit;
  FContentType:=AValue;
end;

procedure TminiHTTPRequest.SetCookie(AValue: string);
begin
  if FCookie=AValue then Exit;
  FCookie:=AValue;
end;

procedure TminiHTTPRequest.SetDMInfo(const Value: TObject);
begin
  FDMInfo := Value;
end;

procedure TminiHTTPRequest.SetInHeaders(AValue: string);
begin
  if FInHeaders=AValue then Exit;
  FInHeaders:=AValue;
end;

procedure TminiHTTPRequest.SetMethod(AValue: string);
begin
  if FMethod=AValue then Exit;
  FMethod:=AValue;
end;

procedure TminiHTTPRequest.SetService_FileName(AValue: string);
begin
  if FService_FileName=AValue then Exit;
  FService_FileName:=AValue;
end;

procedure TminiHTTPRequest.SetService_Path(AValue: string);
begin
  if FService_Path=AValue then Exit;
  FService_Path:=AValue;
end;

function TminiHTTPRequest.GetPostedData: string;
begin
  Result := Utf8ToAnsi(PostedData_mORMot);
end;

constructor TminiHTTPRequest.Create();
begin
  inherited Create();
  FPostStream := nil;
  FParams := TStringList.Create;
  FHeaders := TStringList.Create;
end;

function TminiHTTPRequest.DecodeFJ(Path: string): boolean;
begin
  //TStartExec.GetFJ(TIdHTTPRequestInfo(Self).Service_Path, Path, TIdHTTPRequestInfo(Self));
  Result := DecodeFJ2(Path, true, false);
end;

function TminiHTTPRequest.DecodeFJ2(Path: string; NeedRandomFileName,
  NeedFileMd5: boolean): boolean;
Var
  Stream, ms: TMemoryStream;
  MyStrem: TStream;
  newdecoder, Decoder: TIdMessageDecoder;
  boundary, startboundary: String;
  msgEnd: Boolean;
  tmp, AttatchFiles, OldAttatchFiles, RelativePaths, AttatchFilesSize: String;
  I: Integer;
  {Path, }fname, OneFName, OldOneFName: String;
  SL: TStringStream;
begin
  Result := false;
  if (Pos('multipart/form-data', ContentType) > 0) then
  begin
    Stream := TMemoryStream.Create;
    try

      MyStrem := RawByteStringToStream(PostedData_mORMot);
      MyStrem.Seek(0, 0);
      Stream.CopyFrom(MyStrem, MyStrem.Size);
      MyStrem.Free;

      //Stream.Clear;
      //Stream.LoadFromFile('d:\a.ai');

      Stream.Seek(0, 0);
      PostStream := Stream;

      If (PostStream <> nil) then
      begin
        Result := true;
        try
          I := 0;
          AttatchFiles := '';
          RelativePaths := '';
          OldAttatchFiles := '';
          AttatchFilesSize := '';
          PostStream.Position := 0;
          msgEnd := False;
          boundary := ExtractHeaderSubItem(ContentType, 'boundary', QuoteHTTP);

          startboundary := '--' + boundary;
          repeat
            tmp := ReadLnFromStream(PostStream, -1, True);
          until tmp = startboundary;

          Params.Clear;
          Decoder := TIdMessageDecoderMIME.Create(nil);
          TIdMessageDecoderMIME(Decoder).MIMEBoundary := boundary;
          SL := TStringStream.Create('', TEncoding.UTF8);
          try
            repeat
              Decoder.SourceStream := PostStream;
              Decoder.FreeSourceStream := False;
              Decoder.ReadHeader;
              inc(I);
              case Decoder.PartType of
                mcptAttachment, mcptText:
                  begin
                    ms := TMemoryStream.Create;
                    try
                      ms.Position := 0;
                      newdecoder := Decoder.ReadBody(ms, msgEnd);
                      tmp := Decoder.Headers.Text;
                      fname := Decoder.Filename;
                      Decoder.Free;

                      Decoder := newdecoder;
                      if Decoder <> nil then
                        TIdMessageDecoderMIME(Decoder).MIMEBoundary := boundary;
                      if trim(fname) <> '' then
                      begin
                        if not DirectoryExists(Path) then
                          ForceDirectories(Path);
                        ms.Position := 0;

                        OneFName := Path + {Session.SessionID + '@' + }fname;
                        OldOneFName := OneFName;
                        if NeedFileMd5 then
                        begin
                          OneFName := ExtractFilePath(OneFName) + PubSys.StreamToMD5(Ms) + ExtractFileExt(OneFName);
                          ms.Position := 0;
                        end else
                        if NeedRandomFileName then
                          OneFName := ExtractFilePath(OneFName) + PubSys.GetClientUniqueCode + ExtractFileExt(OneFName);
                        ms.SaveToFile(OneFName);
                        if AttatchFiles = '' then
                        begin
                          AttatchFiles := OneFName;
                          RelativePaths := '\' + PubString.GetDeliBack(OneFName, Service_Path);
                          OldAttatchFiles := ExtractFileName(OldOneFName);
                          AttatchFilesSize := ms.Size.ToString;
                        end else
                        begin
                          AttatchFiles := AttatchFiles + ';' + OneFName;
                          OldAttatchFiles := OldAttatchFiles + ';' +  ExtractFileName(OldOneFName);
                          AttatchFilesSize := AttatchFilesSize + ';' + ms.Size.ToString;
                        end;
                        // msgEnd := true;
                      end
                      else
                      begin //boundary := 'Content-Disposition=form-data; name="Input_769316"'#$D#$A
                        tmp := trim(PubString.GetDeliBack(tmp, 'name='));
                        tmp := AnsiDequotedStr(tmp, '"');
                        ms.Position := 0;
                        SL.LoadFromStream(ms);
                        Params.Add(tmp + '=' + trim(SL.DataString));
                      end;
                    finally
                      ms.Free;
                      ms := nil;
                    end;
                  end;
                mcptIgnore:
                  Begin
                    try
                      FreeAndNil(Decoder);
                      Decoder := TIdMessageDecoderMIME.Create(nil);
                      TIdMessageDecoderMIME(Decoder).MIMEBoundary := boundary;
                    finally
                      if ms <> nil then ms.Free;
                    end;
                  End;
                mcptEOF:
                  begin
                    FreeAndNil(Decoder);
                    msgEnd := True
                  end;
              end;
            until (Decoder = nil) or (msgEnd);
          finally
            SL.Free;
            if Decoder <> nil then Decoder.Free;
          end;
          if trim(AttatchFiles) <> '' then
          begin
            Params.Add('AttatchFiles=' + trim(AttatchFiles));
            Params.Add('RelativePaths=' + trim(RelativePaths));
            Params.Add('OldAttatchFiles=' + trim(OldAttatchFiles));
            Params.Add('AttatchFilesSize=' + trim(AttatchFilesSize));
            if (Session <> nil) {and (Client <> nil)} then
            begin
              Session.Values['AttatchFiles'] := trim(AttatchFiles);
              Session.Values['RelativePaths'] := trim(RelativePaths);
              Session.Values['OldAttatchFiles'] := trim(OldAttatchFiles);
              Session.Values['AttatchFilesSize'] := trim(AttatchFilesSize);
            end;
          end;

        except
          on e: exception do
            WriteInnerLog('处理附件时出错：' + e.Message);
        end;
      end;
    finally
      PostStream := nil;
      Stream.Free; // := TMemoryStream.Create;
    end;
  end;
end;


destructor TminiHTTPRequest.Destroy;
begin
  if PostStream <> nil then
    PostStream.Free;
  PostedData_mORMot := '';
  FParams.Free;
  FHeaders.Free;
  inherited Destroy;
end;

function TminiHTTPRequest.GetRemoteIP: String;
begin
  Result := FRemoteIP;
  ///if Result = '' then Result := '127.0.0.1';;
end;

function TminiHTTPRequest.GetSessionid: string;
begin
  if Session = nil then
    Result := ''
  else
    Result := Session.SessionID;
end;

function TminiHTTPRequest.V(const FieldName: string): string;
begin
  Result := Params.Values[FieldName];
end;

procedure TminiHTTPRequest.SetContentText(AValue: string);
begin
  if FContentText=AValue then Exit;
  FContentText:=AValue;
end;

procedure TminiHTTPRequest.SetAuthBearer(AValue: string);
begin
  if FAuthBearer=AValue then Exit;
  FAuthBearer:=AValue;
end;

function TminiHTTPRequest.GetURI: string;
begin
  Result := QueryParams;
  if trim(Result) <> '' then
    if Pos('?', Result) <> 1 then Result := '?' + Result;
  Result := Document + Result;
end;

function TminiHTTPRequest.ParamsToURL: string;
var
  lp: integer;
  One: string;
  SL: TStrings;
begin
  if Self = nil then exit;
  Result := '';
  for lp := 0 to Params.Count - 1 do
  begin       //TNetEncoding.URL.Encode
    SL := Params;
    //One := 'changeURLStatic(' + QuotedStr(SL.Names[lp]) + ',' + QuotedStr(TNetEncoding.URL.Encode(SL.Values[SL.Names[lp]])) + ');';
    One := 'changeURLStatic(' + QuotedStr(SL.Names[lp]) + ',' + QuotedStr(URLEncode(SL.Values[SL.Names[lp]])) + ');';
    Result := Result + One;
  end;
  if trim(Result) <> '' then
    Result := '<script>' + Result + '</script>';
end;

procedure TminiHTTPRequest.SetAuthenticatedUser(AValue: string);
begin
  if FAuthenticatedUser=AValue then Exit;
  FAuthenticatedUser:=AValue;
end;

procedure TminiHTTPRequest.SetAuthenticationStatus(
  AValue: THttpServerRequestAuthentication);
begin
  if FAuthenticationStatus=AValue then Exit;
  FAuthenticationStatus:=AValue;
end;

{ TminiHTTPResponse }

function TminiHTTPResponse.GetSession: TminiSession;
begin
  Result := Request.Session;
end;

procedure TminiHTTPResponse.SendFileToClient(FileName: string);
begin
  ContentType := STATICFILE_CONTENT_TYPE;
  ContentText := UTF8Encode(FileName);
  //OutCustomHeaders := STATICFILE_CONTENT_TYPE_HEADER + #13#10 + GetMimeContentTypeHeader('', FileName);
  OutCustomHeaders := 'miniContentType: staticfile' + #13#10 +
    'miniFileName: ' + PubSys.Base64Encode(ExtractFileName(FileName)) + #13#10 + GetMimeContentTypeHeader('', FileName);
end;

procedure TminiHTTPResponse.SetContentType(AValue: string);
begin
  if FContentType=AValue then Exit;
  FContentType:=AValue;
end;

procedure TminiHTTPResponse.SetOutURL(AValue: string);
begin
  if FOutURL=AValue then Exit;
  FOutURL:=AValue;
end;

procedure TminiHTTPResponse.SetSessionTimeout(AValue: integer);
begin
  if FSessionTimeout=AValue then Exit;
  FSessionTimeout:=AValue;
end;

procedure TminiHTTPResponse.Clear;
begin
  TDMInfo(Request.DMInfo).LastHtml := '';
end;

constructor TminiHTTPResponse.Create(aResquest: TminiHTTPRequest);
begin
  inherited Create;
  FRequest := aResquest;
  FContentType := HTML_CONTENT_TYPE;
end;

destructor TminiHTTPResponse.Destroy;
begin
  inherited Destroy;
end;

procedure TminiHTTPResponse.Redirect(const Url: string);
begin
  ContentText := '[%Redirect_302%]';
  //URL := Url;
  OutURL := Url;
  if ContentStream <> nil then
    ContentStream.Free;
end;

end.

