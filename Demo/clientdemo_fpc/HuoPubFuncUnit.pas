{ *********************************************************************** }
{    HuoPubFuncUnit Unit                                                  }
{                         Delphi ���ú�����                               }
{                                                                         }
{                                                                         }
{                                                                         }
{                                                     2002��11��XX��      }
{ *********************************************************************** }

//�Ի�������ʾ���ģ���Ҫ�޸� FMX.Consts

{$DEFINE Delphi6}
unit HuoPubFuncUnit;

interface

uses SysUtils, Classes, StrUtils, //IOUtils,
     Dialogs, Forms, UITypes, //DialogService
     {$IFDEF Delphi6}{$EndIf}{$ifdef mswindows}Windows{$endif};
const
  DEFAULT_DELIMITERS = [' ', #9, #10, #13];//�ո�ָ�
type
  TMyClass = class
  private
    procedure CleanDirectoryProc(sFileName: string; var bContinue: Boolean);
  end;
  TEnumDirectoryFileProc = procedure (Filename: string; var bContinue: Boolean) of object;
type
  TPub = class
  private
    procedure ProcessTimer1Timer(Sender: TObject);
  public
    class function GetClientUniqueCode: string; static;
    function NetGetCopmuterName(var AName: string): Boolean;
    class procedure FileDeleteDirectoryEx(sDir: string);
    //class procedure EnableControl(Win: TWincontrol; Flag: boolean);
    class function FillCharEx(Text, Sub: String; Len: integer): String;
    class function GetDeliBack(Text, Delimite: String; All: Boolean = true): String;
    class function GetDeliBackEx(Text, Delimite: string): string;
    class function GetDeliPri(Text, Delimite: String): String;
    class function GetDeliPriEx(Text, Delimite: string): string;
    //��װAPI ShellExecute// 0:�������ڣ�1:��ʾ����....�����ο�����
    function MyShellExecute(const sFileName: string; sPara: string= ''; sAction :string = 'Open';
       flag: integer = 1): LongInt;
    //�ڽ���������//�磺Pub.Execute('C:\WINNT\system32\net.exe send huo aa',true,true,nil);
    //function MyExecute(const Command: string; bWaitExecute: Boolean;
    //   bShowWindow: Boolean; PI: PProcessInformation): Boolean;

    //�ļ�����������
    //����һ���ļ�����װCopyFile
    procedure FileCopyFile(const sSrcFile, sDstFile: string);
    //����·�������ļ���ͬһĿ¼�� bRecursive:true����
    procedure FileCopyDirectory(sDir, tDir: string; bRecursive: Boolean);overload;
    //����·��ԭ�������ļ� ,�Ա�
    procedure FileCopyDirectory(sDir, tDir: string);overload;
    //����·��ԭ�������ļ� ����WinAPI ,��ԭĿ¼������ͬ�ļ���������һ��
    procedure FileCopyDirectory(sDir, tDir:string;AHandle:Thandle);overload;
    //�ƶ��ļ���
    procedure FileMoveDirectory(sDir, tDir:string;AHandle:Thandle);
    //ɾ������·�������µ�����·�����ļ�
    procedure FileDeleteDirectory(sDir: string);overload;
    //ɾ������·�������µ�����·�����ļ� ��WinApi
    procedure FileDeleteDirectory(AHandle: THandle;const ADirName: string);overload;
    //ɾ������·�������µ�����·�����ļ� ������վ
    procedure FileDeleteDirectoryToCycle(AHandle: THandle;const ADirName: string);
    //ȡ��ָ���ļ��Ĵ�С
    //function  FileGetFileSize(const Filename: string): NativeInt;
    //��Path��ȡ��ΨһFilenameX�ļ�
    function  FileGetUniqueFileName(const Path: string; Filename: string): string;
    //ȡ����ʱ�ļ�
    function  FileGetTemporaryFileName: string;

    //ȡ��ϵͳ·��
    function PathGetSystemPath: string;
    //ȡ��Windows·��
    function PathGetWindowsPath: string;
    //�����ļ���ȡ����ϵͳĿ¼�µ�·��������ʱ��
    function PathSystemDirFile(const Filename: string): string;
    //�����ļ���ȡ����WindowsĿ¼�µ�·��������ʱ��
    function PathWindowsDirFile(const Filename: string): string;
    //�����ļ���ȡ����ϵͳ���µ�·��������ʱ��
    function PathSystemDriveFile(const Filename: string): string;
    //·�������'/'��ȥ'/'
    function PathWithoutSlash(const Path: string): string;
    //·�����û��'/'���'/'
    class function PathWithSlash(const Path: string): string;
    //ȡ����·���Ĳ�ͬ���֣�������ǰ�벿����ͬ
    function PathRelativePath(BaseDir, FilePath: string): string;
    //ȡ��ȥ�����Ե�·�����ļ���Ҳ��ΪDIR
    function PathExtractFileNameNoExt(Filename: string): string;
    //�ж���·���Ƿ����
    function PathComparePath(const Path1, Path2: string): Boolean;
    //ȡ�ø���·���ĸ�·��
    function PathParentDirectory(Path: string): string;
    //�ָ�·����Result=��(��d:)sPath = ���������������
    function PathGetRootDir(var sPath: string): string;
    //ȡ��·����󲿷ֺ��������� ��d:\aa\aa result:=aa  sPath:=d:\aa\
    function PathGetLeafDir(var sPath: string): string;
    //ȡ�õ�ǰӦ�ó����·��
    function PathExeDir(FileName: string = ''): string;
    //�ļ���������ֹ

    //ϵͳ������
    //��ʾ����
    procedure MsgBox(const Msg: string);
    //������ʾ����
    procedure MsgErrBox(const Msg: string);
    //ѯ�ʴ��� ��'��','��'��ť
    function  MsgYesNoBox(const Msg: string): Boolean;
    //ѯ�ʴ��� ��'��','��,'ȡ��'��ť//����ֵsmbYes,smbNo,smbCancel
    function  MsgYesNoCancelBox(const Msg: string): Integer;
    //ʹ����æ�ͻָ�����
    procedure DoBusy(Busy: Boolean);
    //��ʾ������Ϣ
    procedure ShowLastError(const Msg: string = 'API Error');
    //����������Ϣ
    procedure RaiseLastError(const Msg: string = 'API Error');
    //�ͷ�Strings���ӵ������Դ
    procedure FreeStringsObjects(SL: TStrings);
    //ϵͳ����ֹ

    //ʱ�䴦����
    //������ʱ��
    function  TimeT_To_DateTime(TimeT: Longint): TDateTime;
    //ת��Ϊ��
    function  TimeToSecond(const H, M, S: Integer): Integer;
    //��ת��
    procedure TimeSecondToTime(const secs: Integer; var H, M, S: Word);
    //��ת��
    function  TimeSecondToTimeStr(secs: Integer): string;
    //ʱ�䴦��ֹ

    //�ؼ�������
    //���ÿؼ��Ƿ���ʹ��
    //procedure ConEnableControl(AControl: TControl; Enable: Boolean);
    //���ÿؼ��Ƿ���ʹ�ã����ӿؼ�
    //procedure ConEnableChildControls(AControl: TControl; Enable: Boolean);
    //procedure ConEnableClassControl(AControl: TControl; Enable: Boolean;
    //  ControlClass: TControlClass);
    //procedure ConFree(aCon: TWinControl);//�ͷ�aCon�ϵĿؼ�
    //���ļ����е���,����LoadfromFile
    //procedure ConLoadTreeViewFromTextFile(Nodes: TTreeNodes; Filename: string);
    //��Ϊ�ı�,����SaveToFile
    //procedure ConSaveTreeViewToTextFile(Nodes: TTreeNodes; Filename: string);
    //�ڿؼ���д�ı�
    //procedure ConWriteText(aContr: TControl;sText: string);
    //�ؼ�����ֹ

    //�ַ���������
    //ȡ��Delimiters�ָ����ַ��� bTrail���ΪTrue��ѵ�index�����Ҳȡ����
    function  StrGetToken(const S: string; index: Integer;
       bTrail: Boolean = False;
       Delimiters: TSysCharSet = DEFAULT_DELIMITERS): string;
    //ȡ��Delimiters�ָ����ַ����ĸ���
    function  StrCountWords(S: string; Delimiters: TSysCharSet =
       DEFAULT_DELIMITERS): Integer;
    //��NewToken�滻S������Token bCaseSensitive:=true��Сд����
    function  StrReplaceString(var S: string; const Token,
       NewToken: string; bCaseSensitive: Boolean): Boolean;
    //�ӵ�Index������Substr�滻Count���ַ�
    procedure StrSimple_ReplaceString(var S: string;
       const  Substr: string; index, Count: Integer);
    //ȥ��S�еĻس����з�
    function StrTruncateCRLF(const S: String): String;
    //�ж�S�Ƿ��Իس����з�����
    function  StrIsContainingCRLF(const S: string): Boolean;
    //��SL�еĸ�������ת��Ϊ��Delimiter�ָ���Str
    function  StrCompositeStrings(SL: TStrings; const Delimiter: string): string;
    //��װTStrings��LoadFromFile
    function  StrSafeLoadStrings(SL: TStrings; const Filename: string): Boolean;
    //��װTStrings��SaveToFile
    procedure StrSafeSaveStrings(SL: TStrings; const Filename: string);
    //�ַ�������ֹ

    //���崦����
    //procedure StringToFont(sFont: string; Font: TFont; bIncludeColor: Boolean = True);
    //function FontToString(Font: TFont; bIncludeColor: Boolean = True): string;
    //���崦��ֹ

    //������
    //�ж��Ƿ�����
    function NetJudgeOnline:boolean;
    //�õ������ľ�����Ip��ַ
    Function NetGetLocalIp(var LocalIp:string): Boolean;
    //ͨ��Ip���ػ�����
    Function NetGetNameByIPAddr(IPAddr: string; var MacName: string): Boolean ;
    //��ȡ������SQLServer�б�
    Function NetGetSQLServerList(var List: Tstringlist): Boolean;
    //��ȡ�����е�������������
    Function NetGetNetList(var List: Tstringlist): Boolean;
    //��ȡ�����еĹ�����
    Function NetGetGroupList(var List: TStringList): Boolean;
    //��ȡ�����������м����
    Function NetGetUsers(GroupName: string; var List: TStringList): Boolean;
    //��ȡ�����е���Դ
    Function NetGetUserResource(IpAddr: string; var List: TStringList): Boolean;
    //ӳ������������
    Function NetAddConnection(NetPath: Pchar; PassWord: Pchar;LocalPath: Pchar): Boolean;
    //�������״̬
    Function NetCheckNet(IpAddr:string): Boolean;
    //�������Ƿ��������
    Function NetCheckMacAttachNet: Boolean;
    //�ж�IpЭ����û�а�װ   �������������
    Function NetIsIPInstalled : boolean;
    //�������Ƿ�����
    Function NetInternetConnected: Boolean;
    //����ֹ

    //������
    //function FormCreateProcessFrm(MsgTitle: string):TForm;
    //����ֹ

    //EMail��
    function CheckMailAddress(Text: string): boolean;
    //EMailֹ
    //function GetSocksVersion(Text: string): TSocksVersion;
    procedure FreeAndNil(var Obj: TObject);
    procedure FreeAndNilEx(Obj: TObject);
  end;

  var
    Pub: TPub;
    FClientUniqueCode: integer; //2008-03-12

implementation
uses TypInfo{, TFlatProgressBarUnit};
{ TMyClass }

const
  csfsBold      = '|Bold';
  csfsItalic    = '|Italic';
  csfsUnderline = '|Underline';
  csfsStrikeout = '|Strikeout';
  C_Err_GetLocalIp       = '��ȡ����ipʧ��';
  C_Err_GetNameByIpAddr  = '��ȡ������ʧ��';
  C_Err_GetSQLServerList = '��ȡSQLServer������ʧ��';
  C_Err_GetUserResource  = '��ȡ������ʧ��';
  C_Err_GetGroupList     = '��ȡ���й�����ʧ��';
  C_Err_GetGroupUsers    = '��ȡ�����������м����ʧ��';
  C_Err_GetNetList       = '��ȡ������������ʧ��';
  C_Err_CheckNet         = '���粻ͨ';
  C_Err_CheckAttachNet   = 'δ��������';
  C_Err_InternetConnected ='û������';
  C_Txt_CheckNetSuccess  = '���糩ͨ';
  C_Txt_CheckAttachNetSuccess = '�ѵ�������';
  C_Txt_InternetConnected ='������';

procedure TMyClass.CleanDirectoryProc(sFileName: string; var bContinue: Boolean);
var
  Attr: Integer;
begin
  Attr := FileGetAttr(sFileName);
  Attr := (not faReadOnly) and Attr; // Turn off ReadOnly attribute
  Attr := (not faHidden) and Attr;   // Turn off Hidden attribute
  //FileSetAttr(sFileName, Attr);

  if Attr and faDirectory <> 0 then
    RMDir(sFileName)
  else
    SysUtils.DeleteFile(sFileName);
end;

{ TPub }

function TPub.PathWithoutSlash(const Path: string): string;
begin
  if (Length(Path) > 0) and (Path[Length(Path)] = '\') then Result := Copy(Path, 1, Length(Path) - 1)
  else Result := Path;
end;

class function TPub.PathWithSlash(const Path: string): string;
begin
  Result := Path;
  if (Length(Result) > 0) and (Result[Length(Result)] <> '\') then Result := Result + '\';
end;

function TPub.PathRelativePath(BaseDir, FilePath: string): string;
begin
  Result := FilePath;
  BaseDir := AnsiUpperCaseFileName(PathWithSlash(BaseDir));
  FilePath := AnsiUpperCaseFileName(FilePath);
  if Copy(FilePath, 1, Length(BaseDir)) = BaseDir then
    Delete(Result, 1, Length(BaseDir));
end;

function TPub.MyShellExecute(const sFileName: string; sPara: string= ''; sAction :string = 'Open';
       flag: integer = 1): LongInt;
begin
  //Result := ShellExecute(Application.Handle, PChar(sAction), PChar(sFileName), PChar(sPara), nil, flag);// > 32;
  if Result < 33 then RaiseLastError('');
end;

function TPub.PathExtractFileNameNoExt(Filename: string): string;
begin
  Result := Copy(Filename, 1, Length(Filename) - Length(ExtractFileExt(Filename)));
end;

procedure TPub.FileCopyFile(const sSrcFile, sDstFile: string);
begin
  //if AnsiCompareFileName(sSrcFile, sDstFile) <> 0 then
    //2020-07-13 mod SysUtils.CopyFile(PChar(sSrcFile), PChar(sDstFile), False);
    CopyFile(PChar(sSrcFile), PChar(sDstFile), true);
  //CopyFile(P)
end;


function TPub.FileGetTemporaryFileName: string;
var
  Buf, Buf1: array[0..255] of Char;
begin
  {$ifdef mswindows}
  GetTempPath(255, @Buf);
  GetTempFileName(@Buf, 'sdfxpd', 0, @Buf1);
  Result := string(Buf1);
  {$endif}
end;

function TruncateTrailNumber(var S: string): Integer;//ȡ�ö��ŷֿ��������������ݱ�Ϊ�Ϸ�����222,333 s := 222 result := 333
var
  I: Integer;
begin
  Result := -1;

  I := Pos(',', S);
  if I <> 0 then
  begin
    Result := StrToIntDef(Copy(S, I + 1, Length(S)), - 1);
    Delete(S, I, Length(S));
  end;
end;

function TruncateTrailIfNotDLL(S: string): string;
begin
  Result := S;
  TruncateTrailNumber(S);

  if (CompareText(ExtractFileExt(S), '.DLL') <> 0) and
    (CompareText(ExtractFileExt(S), '.ICL') <> 0) and
    (CompareText(ExtractFileExt(S), '.EXE') <> 0) then Result := S;
end;

function TPub.PathParentDirectory(Path: string): string;
begin
{var
  iLastAntiSlash: Integer;

  function CountAntiSlash: Integer;
  var
    I: Integer;
  begin
    Result := 0;
    I := 1;
    repeat
      if IsDBCSLeadByte(Ord(Path[I])) then
        Inc(I, 2)
      else
      begin
        if Path[I] = '\' then
        begin
          iLastAntiSlash := I;
          Inc(Result);
        end;
        Inc(I);
      end;
    until I > Length(Path);
  end;

  function UpOneDirectory: string;
  begin
    Result := Copy(Path, 1, iLastAntiSlash); // with slash
  end;

begin
  // 'c:\windows\system\' => 'c:\window\'
  // 'f:\' => 'f:\'
  // '\\xshadow\f\fonts' => '\\xshadow\f\'
  // '\\xshadow\f\' => '\\xshadow\f\'
  Path := PathWithoutSlash(Path);

  if Length(Path) > 3 then
  begin
    if (Path[1] = '\') and (Path[2] = '\') then
    begin
      if CountAntiSlash > 3 then
        Result := UpOneDirectory;
    end else
    begin
      if CountAntiSlash > 1 then
        Result := UpOneDirectory;
    end;
  end else Result := Path;}
end;

function TPub.PathSystemDirFile(const Filename: string): string;
var
  Buf: array[0..255] of Char;
begin
  //GetSystemDirectory(@Buf, 255);
  //Result := PathWithSlash(String(Buf)) + Filename;
end;

function TPub.PathWindowsDirFile(const Filename: string): string;
var
  Buf: array[0..255] of Char;
begin
  //GetWindowsDirectory(@Buf, 255);
  //Result := PathWithSlash(String(Buf)) + Filename;
end;

function TPub.PathSystemDriveFile(const Filename: string): string;
var
  Buf: array[0..255] of Char;
begin
  //GetSystemDirectory(@Buf, 255);
  //Result := PathWithSlash(ExtractFileDrive(String(Buf))) + Filename;
end;

function TPub.PathComparePath(const Path1, Path2: string): Boolean;
begin
  Result := AnsiCompareFileName(PathWithoutSlash(Path1), PathWithoutSlash(Path2)) = 0;
end;
procedure EnumDirectoryFiles(sDir, SMASK: string; Attr: Integer; EnumDirectoryFileProc: TEnumDirectoryFileProc);
var
  SearchRec: TSearchRec;
  Status   : Integer;
  bContinue: Boolean;
begin
  sDir := Pub.PathWithSlash(sDir);

  // traverse child directories
  Status := FindFirst(sDir + '*.*', faDirectory, SearchRec);
  try
    while Status = 0 do
    begin
      if (SearchRec.name <> '.') and (SearchRec.name <> '..') then
        EnumDirectoryFiles(sDir + SearchRec.name, SMASK, Attr, EnumDirectoryFileProc);

      Status := FindNext(SearchRec);
    end;
  finally
    SysUtils.FindClose(SearchRec);
  end;

  // exam each valid file and invoke the callback func
  Status := FindFirst(sDir + SMASK, faAnyFile, SearchRec);
  try
    while Status = 0 do
    begin
      if (SearchRec.Attr and Attr <> 0) and (FileExists(sDir + SearchRec.name) or DirectoryExists(sDir + SearchRec.name)) and
        not ((SearchRec.Attr and faDirectory <> 0) and ((SearchRec.name = '.') or (SearchRec.name = '..'))) then
      begin
        bContinue := True;
        EnumDirectoryFileProc(sDir + SearchRec.name, bContinue);
        if not bContinue then Break;
      end;

      Status := FindNext(SearchRec);
    end;
  finally
    SysUtils.FindClose(SearchRec);
  end;
end;

class procedure TPub.FileDeleteDirectoryEx(sDir: string);
var
  SearchRec: TSearchRec;
  Status   : Integer;
  Sl: TStringlist;
  lp: integer;
begin
  sDir := PathWithSlash(sDir);
  {//tDir := PathWithSlash(tDir);

  Status := FindFirst(sDir + '*.*', faAnyFile, SearchRec);
  Sl := TStringlist.Create;
  try
    while Status = 0 do
    begin
      if (SearchRec.Attr and faDirectory = faDirectory) then
      begin
        if (SearchRec.name <> '.') and (SearchRec.name <> '..') then
          FileDeleteDirectoryEx(sDir + SearchRec.name);
      end else
        Sl.Add(sDir + SearchRec.name);
        //DeleteFile(sDir + SearchRec.name, tDir + SearchRec.name);

      Status := FindNext(SearchRec);
    end;
    for lp := 0 to Sl.Count - 1 do
      SysUtils.DeleteFile(Sl[lp]);
  finally
    Sl.Free;
    SysUtils.FindClose(SearchRec);
  end;}
    Status := FindFirst(sDir + '*.*', faAnyFile, SearchRec);
    Sl := TStringlist.Create;
    try
      while Status = 0 do
      begin
        if (SearchRec.Attr and faDirectory = faDirectory) then
        begin
          if (SearchRec.name <> '.') and (SearchRec.name <> '..') then
            FileDeleteDirectoryEx(sDir + SearchRec.name);
        end else
        begin
          Sl.Add(sDir + SearchRec.name);
          SysUtils.DeleteFile(sDir + SearchRec.name);
        end;
          //DeleteFile(sDir + SearchRec.name, tDir + SearchRec.name);

        Status := FindNext(SearchRec);
      end;
      for lp := 0 to Sl.Count - 1 do
        SysUtils.DeleteFile(Sl[lp]);
      {try
        RmDir(sDir);
      except
      end;}
    finally
      Sl.Free;
      SysUtils.FindClose(SearchRec);
    end;
  {//if not MsgYesNoBox('ȷ��Ҫɾ����Ŀ¼�����������ļ��к��ļ���') then exit;
  with TMyClass.Create do
    try
      EnumDirectoryFiles(sDir, '*.*', faAnyFile, CleanDirectoryProc);
    finally
      Free;
    end;
  RMDir(sDir);}
  try
    Pub.FileDeleteDirectory(sDir); //2022-04-27 add
  except
  end;
end;

procedure TPub.FileDeleteDirectory(sDir: string);
begin
  //if not MsgYesNoBox('ȷ��Ҫɾ����Ŀ¼�����������ļ��к��ļ���') then exit;
  if DirectoryExists(sDir) then
  begin
    with TMyClass.Create do
      try
        EnumDirectoryFiles(sDir, '*.*', faAnyFile, CleanDirectoryProc);
      finally
        Free;
      end;
    try
      RMDir(sDir);
    except
    end;
  end;
end;

procedure TPub.FileDeleteDirectory(AHandle: THandle;const ADirName: string);
var
  //SHFileOpStruct:TSHFileOpStruct;
  DirName: PChar;
  BufferSize: Cardinal;
begin
  {// ����shFileOperation��������ʵ�ֶ�Ŀ¼�Ŀ������ƶ�����������ɾ������
  BufferSize := length(ADirName) + 2;
  GetMem(DirName,BufferSize);
  try
    FIllChar(DirName^, BufferSize, 0);
    StrCopy(DirName,PChar(ADirName));
    with SHFileOpStruct  do
    begin
      Wnd := AHandle;
      WFunc := FO_DELETE;
      pFrom := DirName;
      pTO := nil;
      fFlags := FOF_ALLOWUNDO;

      fAnyOperationsAborted := false;
      hNameMappings := nil;
      lpszProgressTitle := nil;
    end;
    if SHFileOperation(SHFileOpStruct) <> 0 then
      Raiselastwin32Error;
  finally
    FreeMem(DirName,BufferSize);
  end; }
end;

procedure TPub.FileDeleteDirectoryToCycle(AHandle: THandle;const ADirName: string);
var
  //SHFileOpStruct:TSHFileOpStruct;
  DirName: PChar;
  BufferSize: Cardinal;
  aa: string;
begin
  {// ����shFileOperation��������ʵ�ֶ�Ŀ¼�Ŀ������ƶ�����������ɾ������
  if not DirectoryExists(ADirName) then
  begin
    aa := ADirName;
    MsgBox('�������ļ��С�' + PathGetLeafDir(aa) + '��,ɾ��ʧ�ܣ�');
    exit;
  end;
  BufferSize := length(ADirName) + 2;
  GetMem(DirName,BufferSize);
  try
    FIllChar(DirName^, BufferSize, 0);
    StrCopy(DirName,PChar(ADirName));
    with SHFileOpStruct  do
    begin
      Wnd := AHandle;
      WFunc := FO_DELETE;
      pFrom := DirName;
      pTO := nil;
      fFlags := FOF_ALLOWUNDO;

      fAnyOperationsAborted:=false;
      hNameMappings:=nil;
      lpszProgressTitle:=nil;
    end;
    if SHFileOperation(SHFileOpStruct) <> 0 then
      Raiselastwin32Error;
  finally
    FreeMem(DirName,BufferSize);
  end;}
end;

procedure TPub.FileCopyDirectory(sDir, tDir: string; bRecursive: Boolean);
var
  SearchRec: TSearchRec;
  Status   : Integer;
begin
  sDir := PathWithSlash(sDir);
  tDir := PathWithSlash(tDir);

  Status := FindFirst(sDir + '*.*', faAnyFile, SearchRec);
  try
    while Status = 0 do
    begin
      if bRecursive and (SearchRec.Attr and faDirectory = faDirectory) then
      begin
        if (SearchRec.name <> '.') and (SearchRec.name <> '..') then
          FileCopyDirectory(sDir + SearchRec.name, tDir, bRecursive);
      end else FileCopyFile(sDir + SearchRec.name, tDir + SearchRec.name);

      Status := FindNext(SearchRec);
    end;
  finally
    SysUtils.FindClose(SearchRec);
  end;
end;

function TPub.FileGetUniqueFileName(const Path: string; Filename: string): string;
var
  I   : Integer;
  sExt: string;
begin
  Result := Filename;
  sExt := ExtractFileExt(Filename);
  Filename := PathExtractFileNameNoExt(Filename);

  I := 1;
  repeat
    if not FileExists(PathWithSlash(Path) + Result) then Break;

    Result := Filename + IntToStr(I) + sExt;
    Inc(I);
  until False;
  Result := PathWithSlash(Path) + Filename + sExt;
end;


function TPub.PathGetSystemPath: string;
var
  Buf: array[0..255] of Char;
begin   
  {try
    GetSystemDirectory(@Buf, 255);
    Result := PathWithSlash(String(Buf));
  except
  end; }
end;

function TPub.PathGetWindowsPath: string;
var
  Buf: array[0..255] of Char;
begin
  {GetWindowsDirectory(@Buf, 255);
  Result := PathWithSlash(String(Buf));}
end;

function TPub.PathGetRootDir(var sPath: string): string;
var
  I: Integer;
begin
  I := AnsiPos('\', sPath);
  if I <> 0 then
    Result := Copy(sPath, 1, I)
  else
    Result := sPath;

  Delete(sPath, 1, Length(Result));
  Result := PathWithoutSlash(Result);
end;

function TPub.PathGetLeafDir(var sPath: string): string;
begin
  sPath := PathWithoutSlash(sPath);
  Result := ExtractFileName(sPath);
  sPath := ExtractFilePath(sPath);
end;

//ϵͳ����
procedure TPub.MsgBox(const Msg: string);
begin
  //2022-10-19 Showmessage(Msg);
  {$ifdef mswindows}
  //MessageBox(0, PChar(Msg), '��ʾ��Ϣ', 1);
  Forms.Application.MessageBox(PChar(Msg), PChar(Application.Title), MB_ICONINFORMATION);
  {$else}
  //MessageDlgPosHelp(Msg, TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbOK],0, -1, -1, '');
  TDialogService.ShowMessage(Msg);
  {$endif}

  //Application.MessageBox(PChar(Msg), PChar(Application.Title), MB_ICONINFORMATION);
end;

procedure TPub.MsgErrBox(const Msg: string);
begin
  //Application.MessageBox(PChar(Msg), PChar(Application.Title), MB_ICONERROR);
end;

function TPub.MsgYesNoBox(const Msg: string): Boolean;
var
  I: integer;
begin
  {Result := Application.MessageBox(PChar(Msg), PChar(Application.Title), MB_ICONQUESTION or
    MB_YESNO or MB_DEFBUTTON1) = IDYES; }
  //I := MessageDlg(Msg, TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbNo, TMsgDlgBtn.mbYes],0);
  I := MessageDlgPosHelp(Msg, TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbNo, TMsgDlgBtn.mbYes],0, -1, -1, '');
  Result := I = 6;
end;

function TPub.MsgYesNoCancelBox(const Msg: string): Integer;
begin
  {Result := Application.MessageBox(PChar(Msg),
    PChar(Application.Title), MB_ICONQUESTION or MB_YESNOCANCEL or MB_DEFBUTTON1)}
  Result := MessageDlg(Msg, TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbNo, TMsgDlgBtn.mbYes,
     TMsgDlgBtn.mbCancel],0);
end;

procedure TPub.DoBusy(Busy: Boolean);
var
  Times: Integer;
begin
  {Times := 0;
  if Busy then
  begin
    Inc(Times);
    if Times = 1 then Screen.Cursor := crHourGlass;
  end else
  begin
    dec(Times);
    if Times = 0 then Screen.Cursor := crDefault;
  end;}
end;

function GetLastErrorStr: string;
var
  Buf: PChar;
begin
  {FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER or FORMAT_MESSAGE_FROM_SYSTEM,
    nil, GetLastError, LANG_USER_DEFAULT, @Buf, 0, nil);
  try
    Result := String(Buf);
  finally
    LocalFree(HLOCAL(Buf));
  end;}
end;

procedure TPub.ShowLastError(const Msg: string = 'API Error');
begin
  MsgBox(Msg + ': ' + GetLastErrorStr);
end;

procedure TPub.RaiseLastError(const Msg: string = 'API Error');
begin
  if trim(Msg) = '' then
    raise Exception.Create(GetLastErrorStr)
  else
    raise Exception.Create(Msg + ': ' + GetLastErrorStr);
end;

procedure TPub.FreeAndNil(var Obj: TObject);
begin
  try
    {$IFDEF MSWINDOWS}
    Obj.Free;
    {$else}
    Obj.DisposeOf;
    {$endif}
    Obj := nil;
  except
  end;
end;

procedure TPub.FreeAndNilEx(Obj: TObject);
begin
  FreeAndNil(Obj);
end;

procedure TPub.FreeStringsObjects(SL: TStrings);
var
  I: Integer;
begin
  for I := 0 to SL.count - 1 do
    if assigned(SL.objects[I]) then
    begin
      Dispose(pointer(SL.objects[I]));
      SL.objects[I] := nil;
    end;
end;
//����ʱ��
function TPub.TimeT_To_DateTime(TimeT: Longint): TDateTime;
var
  ts: TTimeStamp;
begin
  Dec(TimeT, 3600 * 8);    // still unprecise
  ts.Time := (TimeT mod 86400) * 1000;
  ts.Date := TimeT div 86400 + 719163;
  Result := TimeStampToDateTime(ts);
end;

function TPub.TimeToSecond(const H, M, S: Integer): Integer;
begin
  Result := H * 3600 + M * 60 + S;
end;

procedure TPub.TimeSecondToTime(const secs: Integer; var H, M, S: Word);
begin
  H := secs div 3600;
  M := (secs mod 3600) div 60;
  S := secs mod 60;
end;

function TPub.TimeSecondToTimeStr(secs: Integer): string;
var
  H, M, S: Word;
begin
 TimeSecondtotime(secs, h, m, s);

 result := '';
 if h <> 0 then Result := result + format('%-.2d �s�� ', [h]);
 if m <> 0 then Result := result + format('%-.2d �� ', [m]);
 if s <> 0 then Result := result + format('%-.2d �� ', [s]);
end;

//���¿ؼ�
class function TPub.GetDeliBack(Text, Delimite: String; All: Boolean): String;
var
  Index: integer;
begin
  Result := Text;
  Index := Pos(Delimite, Text);
  if Index > 0 then
    Result := Copy(Text, Index + Length(Delimite), MaxInt);
end;

class function TPub.GetDeliBackEx(Text, Delimite: string): string;
begin
  Result := Text;
  if Pos(Delimite, Text) > 0 then
  begin
    Text := ReverseString(Text);
    Delimite := ReverseString(Delimite);
    Result :=  ReverseString(GetDeliPri(Text, Delimite));
  end;
end;

class function TPub.GetDeliPriEx(Text, Delimite: string): string;
begin
  Result := Text;
  if Pos(Delimite, Text) > 0 then
  begin
    Text := StrUtils.ReverseString(Text);
    Delimite := StrUtils.ReverseString(Delimite);
    Result :=  StrUtils.ReverseString(GetDeliBack(Text, Delimite));
  end;
end;

class function TPub.GetDeliPri(Text, Delimite: String): String;
begin
  Result := Text;
  if Pos(Delimite, Text) > 0 then
    Result := Copy(Text, 1, Pos(Delimite, Text) - 1);
end;

//�����ַ���
function TPub.StrGetToken(const S: string; index: Integer; bTrail: Boolean = False;
  Delimiters: TSysCharSet = DEFAULT_DELIMITERS): string;
var
  I, W, head, tail: Integer;
  bInWord         : Boolean;
begin
  I := 1;
  W := 0;
  bInWord := False;
  head := 1;
  tail := Length(S);
  while (I <= Length(S)) and (W <= index) do
  begin
    if S[I] in Delimiters then
    begin
      if (W = index) and bInWord then tail := I - 1;
      bInWord := False;
    end else
    begin
      if not bInWord then
      begin
        bInWord := True;
        Inc(W);
        if W = index then head := I;
      end;
    end;

    Inc(I);
  end;

  if bTrail then tail := Length(S);
  if W >= index then Result := Copy(S, head, tail - head + 1)
  else Result := '';
end;

function TPub.StrCountWords(S: string; Delimiters: TSysCharSet = DEFAULT_DELIMITERS): Integer;
var
  bInWord: Boolean;
  I      : Integer;
begin
  Result := 0;
  I := 1;
  bInWord := False;
  while I <= Length(S) do
  begin
    if S[I] in Delimiters then bInWord := False
    else
    begin
      if not bInWord then
      begin
        bInWord := True;
        Inc(Result);
      end;
    end;

    Inc(I);
  end;
end;

function TPub.StrIsContainingCRLF(const S: string): Boolean;
var
  len: Integer;
begin
  len := Length(S);
  Result := (len >= 2) and (S[len - 1] = #13) and (S[len] = #10);
end;

function TPub.StrTruncateCRLF(const S: String): String;
var
  I: Integer;
begin
  Result := S;
  I := 1;
  while I <= Length(Result) do
    if (Result[I] = #13) or (Result[I] = #10) then Delete(Result, I, 1)
    else Inc(I);
end;

function TPub.StrReplaceString(var S: string; const Token, NewToken: string; bCaseSensitive: Boolean): Boolean;
var
  I         : Integer;
  sFirstPart: string;
begin
  if bCaseSensitive then
    I := AnsiPos(Token, S)
  else
    I := AnsiPos(AnsiUpperCase(Token), AnsiUpperCase(S));

  if I <> 0 then
  begin
    sFirstPart := Copy(S, 1, I - 1) + NewToken;
    S := Copy(S, I + Length(Token), Maxint);
  end;

  Result := I <> 0;
  if Result then
  begin
    StrReplaceString(S, Token, NewToken, bCaseSensitive);
    S := sFirstPart + S;
  end;
end;

procedure TPub.StrSimple_ReplaceString(var S: string; const Substr: string; index, Count: Integer);
begin
  S := Format('%s%s%s',[Copy(S, 1, index - 1), Substr, Copy(S, index + Count, Maxint)]);
end;

function TPub.StrCompositeStrings(SL: TStrings; const Delimiter: string): string;
var
  I: Integer;
begin
  Result := '';

  with SL do
  begin
    for I := 0 to Count - 2 do
      Result := Result + Strings[I] + Delimiter;
    if Count > 0 then
      Result := Result + Strings[Count - 1];
  end;
end;

function TPub.StrSafeLoadStrings(SL: TStrings; const Filename: string): Boolean;
begin
  Result := False;
  repeat
    try
      if not FileExists(Filename) then Exit;
      SL.LoadFromFile(Filename);
      Result := True;
      Break;
    except
      Sleep(500);
    end;
  until False;
end;

procedure TPub.StrSafeSaveStrings(SL: TStrings; const Filename: string);
begin
  ForceDirectories(ExtractFilePath(Filename));
  repeat
    try
      SL.SaveToFile(Filename);
      Break;
    except
      Sleep(500);
    end;
  until False;
end;
//��������
procedure TPub.FileCopyDirectory(sDir, tDir: string);
begin

end;
{var
  aWaitForm: TForm;
  RetValue: integer;
  procedure MyCopy(aDir, sDir: string);
  var
    sr: TSearchRec;
  begin
    aDir := PathWithSlash(aDir);
    sDir := PathWithSlash(sDir);
    if FindFirst(aDir+'*.*', faAnyFile, sr) = 0 then
    begin
      repeat
        if sr.Attr and faDirectory = faDirectory then
        begin
          if not DirectoryExists(aDir + sr.Name) then exit;
          if (sr.Name <> '.') and (sr.Name <> '..') then
            MyCopy(aDir + sr.Name,sDir + sr.Name);
        end else
        begin
          if (sr.Name <> '.') and (sr.Name <> '..') then
          begin
            ForceDirectories(sDir);
            Application.ProcessMessages;
            aWaitForm.Caption := '���ڸ���' + aDir + sr.Name;
            Application.ProcessMessages;
            FileCopyFile(aDir + sr.Name,sDir + sr.Name);//���߳���ִ��
            //MyThread1.sPath := aDir + sr.Name;
            //MyThread1.tPath := sDir + sr.Name;
            //MyThread1.flag := true;
            Application.ProcessMessages;
          end;
        end;
      until FindNext(sr) <> 0;
      FindClose(sr);
    end;
  end;
begin
  if DirectoryExists(tDir) then
  begin
    if  Pub.MsgYesNoBox('�Ѵ��ڸ��ļ���ȷ��Ҫ������') then
      FileDeleteDirectory(tDir)
    else exit;
  end;
  aWaitForm := FormCreateProcessFrm('���ڸ����ļ������Ժ�...');
  try
    aWaitForm.Show;
    Application.ProcessMessages;
    MyCopy(sDir, tDir);
  finally
    ConFree(aWaitForm);//���ͷ�Form�ϵĿؼ�
    aWaitForm.Free;
    aWaitForm := nil;
  end;
end;
}
procedure MyFileCopyDirectory(sDir, tDir:string;AHandle:Thandle;Flag: integer = 0);
begin

end;
(*
var
  fromdir,todir{,dirname}:pchar;
  SHFileOpStruct:TSHFileOpStruct;
begin
  GetMem(fromdir,length(sDir)+2);
  try
    GetMem(todir,length(tdir)+2);
    try
      FIllchar(fromdir^,length(sDir)+2,0);
      FIllchar(todir^,length(tDir)+2,0);
      strcopy(fromdir,pchar(sDir));
      strcopy(todir,pchar(tDir));
      with SHFileOpStruct  do
      begin
        wnd := AHandle;
        if Flag = 1 then
          WFunc := FO_MOVE
        else
          WFunc := FO_COPY;
        //�ò���ָ��shFileOperation������ִ��Ŀ¼�Ŀ���
        pFrom:=fromdir;
        pTO:=todir;
        fFlags:=FOF_NOCONFIRMATION OR FOF_RENAMEONCOLLISION;
        fAnyOperationsAborted:=false;
        hnamemappings:=nil;
        lpszprogresstitle:=nil;
      end;
      if shFileOperation(SHFileOpStruct)<>0 then
        Raiselastwin32Error;
    finally
      FreeMem(todir,length(tDir)+2);
    end;
  finally
    FreeMem(fromdir,length(sDir)+2);
  end;
end;  *)
procedure TPub.FileMoveDirectory(sDir, tDir:string;AHandle:Thandle);
var
  fromdir,todir{,dirname}:pchar;
  //SHFileOpStruct:TSHFileOpStruct;
begin
  // ����shFileOperation��������ʵ�ֶ�Ŀ¼�Ŀ������ƶ�����������ɾ������
  if not DirectoryExists(sDir) then
  begin
    MsgBox('������Դ·����' + sDir + '�����ƶ�����ʧ�ܣ�');
    exit;
  end;
  if DirectoryExists(tDir) then
  begin
    if  Pub.MsgYesNoBox('�Ѵ��ڸ��ļ���ȷ��Ҫ������') then
      FileDeleteDirectory(tDir)
    else exit;
  end else
  if not MsgYesNoBox('������Ŀ��·����' + tDir + '����Ҫ������') then exit;

  ForceDirectories(tDir);
  MyFileCopyDirectory(sDir, tDir, AHandle, 1);
end;

procedure TPub.FileCopyDirectory(sDir, tDir:string;AHandle:Thandle);
begin
  // ����shFileOperation��������ʵ�ֶ�Ŀ¼�Ŀ������ƶ�����������ɾ������
  if not DirectoryExists(sDir) then
  begin
    MsgBox('������Դ·����' + sDir + '��������ʧ�ܣ�');
    exit;
  end;
  if DirectoryExists(tDir) then
  begin
    if  Pub.MsgYesNoBox('�Ѵ��ڸ��ļ���ȷ��Ҫ������') then
      FileDeleteDirectory(tDir)
    else exit;
  end else
  if not MsgYesNoBox('������Ŀ��·����' + tDir + '����Ҫ������') then exit;
  ForceDirectories(tDir);
  MyFileCopyDirectory(sDir, tDir, AHandle);
end;
//��������

function TPub.NetJudgeOnline: boolean;
var
  b: array[0..4] of Byte;
begin

end;

{=================================================================
  ��  ��: �������Ƿ��������
  ��  ��: ��
  ����ֵ: �ɹ�:  True  ʧ��:  False
  �� ע:
  �� ��:
     1.0  2002/10/03 09:55:00
=================================================================}
Function TPub.NetCheckMacAttachNet: Boolean;
begin
  Result := False;
  //if GetSystemMetrics(SM_NETWORK) <> 0 then  //������������
    Result := True;
end;

{=================================================================
  ��  ��: ���ر����ľ�����Ip��ַ
  ��  ��: ��
  ����ֵ: �ɹ�:  True, �����LocalIp   ʧ��:  False
  �� ע:
  �� ��:
     1.0  2002/10/02 21:05:00
=================================================================}
function TPub.NetGetLocalIP(var LocalIp: string): Boolean;

begin

end;

function TPub.NetGetCopmuterName(var AName: string): Boolean;

begin

end;

{=================================================================
  ��  ��: ͨ��Ip���ػ�����
  ��  ��:
          IpAddr: ��Ҫ�õ����ֵ�Ip
  ����ֵ: �ɹ�:  ������   ʧ��:  ''
  �� ע:
    inet_addr function converts a string containing an Internet
    Protocol dotted address into an in_addr.
  �� ��:
    1.0  2002/10/02 22:09:00
=================================================================}
function TPub.NetGetNameByIPAddr(IPAddr : String;var MacName:String): Boolean;

begin

end;

{=================================================================
  ��  ��: ����������SQLServer�б�
  ��  ��:
          List: ��Ҫ����List
  ����ֵ: �ɹ�:  True,�����List  ʧ�� False
  �� ע:
  �� ��:
    1.0  2002/10/02 22:44:00
=================================================================}
Function TPub.NetGetSQLServerList(var List: Tstringlist): boolean;

begin

end;

{=================================================================
  ��  ��: �ж�IpЭ����û�а�װ
  ��  ��: ��
  ����ֵ: �ɹ�:  True ʧ��: False;
  �� ע:   �ú�����������
  �� ��:
     1.0  2002/10/02 21:05:00
=================================================================}
Function TPub.NetIsIPInstalled : boolean;

begin

end;
{=================================================================
  ��  ��: ���������еĹ�����Դ
  ��  ��:
          IpAddr: ����Ip
          List: ��Ҫ����List
  ����ֵ: �ɹ�:  True,�����List ʧ��: False;
  �� ע:
     WNetOpenEnum function starts an enumeration of network
     resources or existing connections.
     WNetEnumResource function continues a network-resource
     enumeration started by the WNetOpenEnum function.
  �� ��:
     1.0  2002/10/03 07:30:00
=================================================================}
Function TPub.NetGetUserResource(IpAddr: string; var List: TStringList): Boolean;
begin

end;

{=================================================================
  ��  ��: ���������еĹ�����
  ��  ��:
          List: ��Ҫ����List
  ����ֵ: �ɹ�:  True,�����List ʧ��: False;
  ��  ע:
  ��  ��:
     1.0  2002/10/03 08:00:00
=================================================================}
Function TPub.NetGetGroupList( var List : TStringList ) : Boolean;
begin

end;
{=================================================================
  ��  ��: �оٹ����������еļ����
  ��  ��:
          List: ��Ҫ����List
  ����ֵ: �ɹ�:  True,�����List ʧ��: False;
  ��  ע:
  ��  ��:
     1.0  2002/10/03 08:00:00
=================================================================}
Function TPub.NetGetUsers(GroupName: string; var List: TStringList): Boolean;
begin

end;
{=================================================================
  ��  ��: �о�������������
  ��  ��:
          List: ��Ҫ����List
  ����ֵ: �ɹ�:  True,�����List ʧ��: False;
  �� ע:
  �� ��:
     1.0  2002/10/03 08:54:00
=================================================================}
Function TPub.NetGetNetList(var List: Tstringlist): Boolean;
begin

end;
{=================================================================
  ��  ��: ӳ������������
  ��  ��:
          NetPath: ��Ҫӳ�������·��
          Password: ��������
          Localpath ����·��
  ����ֵ: �ɹ�:  True  ʧ��: False;
  �� ע:
  �� ��:
     1.0  2002/10/03 09:24:00
=================================================================}
Function TPub.NetAddConnection(NetPath: Pchar; PassWord: Pchar
                          ;LocalPath: Pchar): Boolean;
begin

end;
{=================================================================
  ��  ��:  �������״̬
  ��  ��:
          IpAddr: ������������������IP��ַ�����ƣ�����ʹ��Ip
  ����ֵ: �ɹ�:  True  ʧ��: False;
  �� ע:
  �� ��:
     1.0  2002/10/03 09:40:00
=================================================================}
Function TPub.NetCheckNet(IpAddr: string): Boolean;
begin

end;


{=================================================================
  ��  ��:  ��������Ƿ�����
  ��  ��:  ��
  ����ֵ:  �ɹ�:  True  ʧ��: False;
  �� ע:   uses Wininet
  �� ��:
     1.0  2002/10/07 13:33:00
=================================================================}
function TPub.NetInternetConnected: Boolean;
begin

end;

{�ȴ�������}
procedure TPub.ProcessTimer1Timer(Sender: TObject);
begin
{var
  aForm: TForm;
  pr: TFlatProgressBar;
  lb: TLabel;
  aStr: String;
begin
  aForm := TForm(TControl(Sender).Owner);
  TLabel(aForm.FindComponent('Label3')).Caption := TimeToStr(Now);
  lb := TLabel(aForm.FindComponent('Label2'));
  lb.Caption := aForm.Caption;
  aStr := lb.Caption;
  if length(aStr) > 50 then
    lb.Caption := Copy(aStr, 1, 20) + '...' + Copy(aStr, Length(aStr) - 30, 31);
  lb.Left := aForm.Width div 2 - lb.Width div 2;
  pr := TFlatProgressBar(aForm.FindComponent('FlatProgressBar1'));
  if pr = nil then exit;
  pr.StepIt;
  if pr.Position = 100 then
  pr.Position := 0;
}end;

function TPub.CheckMailAddress(Text: string): boolean;
var
  Index: integer;
  lp: integer;
begin
  Result := false;
  if ((length(trim(Text)) > 50) or (Pos('.', Text) < 4))
    or (Pos('.HTM', UpperCase(Text)) > 0) or (Pos('.HTML', UpperCase(Text)) > 0)
    or (Pos('.ASP', UpperCase(Text)) > 0) or (Pos('.JSP', UpperCase(Text)) > 0) then exit;
  for lp := 1 to length(Text) do
    if (Ord(Text[lp]) > $80) and (Text[lp] <> '@') then exit;
  if (Pos('.', Text) < Pos('@', Text) + 1) then exit;
  Index := Pos('@', Text);
  if (Index < 2) or (Index >= Length(Text))  then exit;
  Result := true;
end;

function TPub.PathExeDir(FileName: string): string;
begin
  Result := ExtractFilePath(ParamStr(0)) + FileName;
end;

{function TPub.GetSocksVersion(Text: string): TSocksVersion;
begin
  Result := svSocks5;
  if UpperCase(trim(Text)) = 'SOCKS5' then
    Result := svSocks5
  else
  if UpperCase(trim(Text)) = 'SOCKS4' then
    Result := svSocks4
  else
    Result := svSocks4A;
end;}

class function TPub.FillCharEx(Text, Sub: String; Len: integer): String;
var
  lp: integer;
begin
  Result := Text;
  for lp := 1 to Len - Length(Result) do
    Result := Sub + Result;
end;

class function TPub.GetClientUniqueCode: string;
var
  Param1: string;
  Param2: integer;
begin
  FClientUniqueCode := FClientUniqueCode + 1;
  if FClientUniqueCode > 999 then
    FClientUniqueCode := 1;
  Param1 := FillCharEx(IntToStr(FClientUniqueCode), '0', 3);
  Sleep(10);
  Randomize;
  Param2 := Random(99);
  //{$ifdef eYoueSvr} //2014-01-14 add
  Result := FormatDateTime('YYMMDDHHNNSSZZZ', Now) +
    FillCharEx(IntToStr(Param2), '0', 2) + Param1;
  //{$else}
  //Result := FormatDateTime('YYMMDDHHNNSSZZZ', TDllParam(PubSystem.GetDllParam(false)).PubeParam.CurNow) +
  //  IntToStr(Param2) + Param1;
  //{$endif}
end;

initialization
  Pub := TPub.Create;
  Randomize;
  FClientUniqueCode := Random(500);//RandomRange(0, 500); //��������(�ط�)��Ҫ����, ֻ�ʺϸõ�Ԫ

finalization
  Pub.Free;

end.


