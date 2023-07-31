{ *********************************************************************** }
{    HuoPubFuncUnit Unit                                                  }
{                         Delphi 公用函数集                               }
{                                                                         }
{                                                                         }
{                                                                         }
{                                                     2002年11月XX日      }
{ *********************************************************************** }

//对话标题显示中文，需要修改 FMX.Consts

{$DEFINE Delphi6}
unit HuoPubFuncUnit;

interface

uses SysUtils, Classes, StrUtils, //IOUtils,
     Dialogs, Forms, UITypes, //DialogService
     {$IFDEF Delphi6}{$EndIf}{$ifdef mswindows}Windows{$endif};
const
  DEFAULT_DELIMITERS = [' ', #9, #10, #13];//空格分隔
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
    //封装API ShellExecute// 0:隐含窗口，1:显示窗口....其他参考帮助
    function MyShellExecute(const sFileName: string; sPara: string= ''; sAction :string = 'Open';
       flag: integer = 1): LongInt;
    //在进程中运行//如：Pub.Execute('C:\WINNT\system32\net.exe send huo aa',true,true,nil);
    //function MyExecute(const Command: string; bWaitExecute: Boolean;
    //   bShowWindow: Boolean; PI: PProcessInformation): Boolean;

    //文件操作部分起
    //拷贝一个文件，封装CopyFile
    procedure FileCopyFile(const sSrcFile, sDstFile: string);
    //给定路径复制文件到同一目录下 bRecursive:true所有
    procedure FileCopyDirectory(sDir, tDir: string; bRecursive: Boolean);overload;
    //给定路径原样复制文件 ,自编
    procedure FileCopyDirectory(sDir, tDir: string);overload;
    //给定路径原样复制文件 ，用WinAPI ,若原目录下有相同文件则再生成一个
    procedure FileCopyDirectory(sDir, tDir:string;AHandle:Thandle);overload;
    //移动文件夹
    procedure FileMoveDirectory(sDir, tDir:string;AHandle:Thandle);
    //删除给定路径及以下的所有路径和文件
    procedure FileDeleteDirectory(sDir: string);overload;
    //删除给定路径及以下的所有路径和文件 用WinApi
    procedure FileDeleteDirectory(AHandle: THandle;const ADirName: string);overload;
    //删除给定路径及以下的所有路径和文件 到回收站
    procedure FileDeleteDirectoryToCycle(AHandle: THandle;const ADirName: string);
    //取得指定文件的大小
    //function  FileGetFileSize(const Filename: string): NativeInt;
    //在Path下取得唯一FilenameX文件
    function  FileGetUniqueFileName(const Path: string; Filename: string): string;
    //取得临时文件
    function  FileGetTemporaryFileName: string;

    //取得系统路径
    function PathGetSystemPath: string;
    //取得Windows路径
    function PathGetWindowsPath: string;
    //给定文件名取得在系统目录下的路径，复制时用
    function PathSystemDirFile(const Filename: string): string;
    //给定文件名取得在Windows目录下的路径，复制时用
    function PathWindowsDirFile(const Filename: string): string;
    //给定文件名取得在系统盘下的路径，复制时用
    function PathSystemDriveFile(const Filename: string): string;
    //路径最后有'/'则去'/'
    function PathWithoutSlash(const Path: string): string;
    //路径最后没有'/'则加'/'
    class function PathWithSlash(const Path: string): string;
    //取得两路径的不同部分，条件是前半部分相同
    function PathRelativePath(BaseDir, FilePath: string): string;
    //取得去掉属性的路径，文件名也作为DIR
    function PathExtractFileNameNoExt(Filename: string): string;
    //判断两路径是否相等
    function PathComparePath(const Path1, Path2: string): Boolean;
    //取得给定路径的父路径
    function PathParentDirectory(Path: string): string;
    //分割路径，Result=根(如d:)sPath = 除根外的其他部分
    function PathGetRootDir(var sPath: string): string;
    //取得路径最后部分和其他部分 如d:\aa\aa result:=aa  sPath:=d:\aa\
    function PathGetLeafDir(var sPath: string): string;
    //取得当前应用程序的路径
    function PathExeDir(FileName: string = ''): string;
    //文件操作部分止

    //系统处理起
    //提示窗口
    procedure MsgBox(const Msg: string);
    //错误显示窗口
    procedure MsgErrBox(const Msg: string);
    //询问窗口 带'是','否'按钮
    function  MsgYesNoBox(const Msg: string): Boolean;
    //询问窗口 带'是','否,'取消'按钮//返回值smbYes,smbNo,smbCancel
    function  MsgYesNoCancelBox(const Msg: string): Integer;
    //使鼠标变忙和恢复正常
    procedure DoBusy(Busy: Boolean);
    //显示错误信息
    procedure ShowLastError(const Msg: string = 'API Error');
    //发出错误信息
    procedure RaiseLastError(const Msg: string = 'API Error');
    //释放Strings连接的相关资源
    procedure FreeStringsObjects(SL: TStrings);
    //系统处理止

    //时间处理起
    //整数到时间
    function  TimeT_To_DateTime(TimeT: Longint): TDateTime;
    //转化为秒
    function  TimeToSecond(const H, M, S: Integer): Integer;
    //秒转化
    procedure TimeSecondToTime(const secs: Integer; var H, M, S: Word);
    //秒转化
    function  TimeSecondToTimeStr(secs: Integer): string;
    //时间处理止

    //控件处理起
    //设置控件是否能使用
    //procedure ConEnableControl(AControl: TControl; Enable: Boolean);
    //设置控件是否能使用，包子控件
    //procedure ConEnableChildControls(AControl: TControl; Enable: Boolean);
    //procedure ConEnableClassControl(AControl: TControl; Enable: Boolean;
    //  ControlClass: TControlClass);
    //procedure ConFree(aCon: TWinControl);//释放aCon上的控件
    //从文件本中导入,类似LoadfromFile
    //procedure ConLoadTreeViewFromTextFile(Nodes: TTreeNodes; Filename: string);
    //存为文本,类似SaveToFile
    //procedure ConSaveTreeViewToTextFile(Nodes: TTreeNodes; Filename: string);
    //在控件上写文本
    //procedure ConWriteText(aContr: TControl;sText: string);
    //控件处理止

    //字符串处理起
    //取以Delimiters分隔的字符串 bTrail如果为True则把第index个后的也取出来
    function  StrGetToken(const S: string; index: Integer;
       bTrail: Boolean = False;
       Delimiters: TSysCharSet = DEFAULT_DELIMITERS): string;
    //取以Delimiters分隔的字符串的个数
    function  StrCountWords(S: string; Delimiters: TSysCharSet =
       DEFAULT_DELIMITERS): Integer;
    //用NewToken替换S中所有Token bCaseSensitive:=true大小写敏感
    function  StrReplaceString(var S: string; const Token,
       NewToken: string; bCaseSensitive: Boolean): Boolean;
    //从第Index个起以Substr替换Count个字符
    procedure StrSimple_ReplaceString(var S: string;
       const  Substr: string; index, Count: Integer);
    //去掉S中的回车返行符
    function StrTruncateCRLF(const S: String): String;
    //判定S是否以回车返行符结束
    function  StrIsContainingCRLF(const S: string): Boolean;
    //把SL中的各项数据转化为以Delimiter分隔的Str
    function  StrCompositeStrings(SL: TStrings; const Delimiter: string): string;
    //封装TStrings的LoadFromFile
    function  StrSafeLoadStrings(SL: TStrings; const Filename: string): Boolean;
    //封装TStrings的SaveToFile
    procedure StrSafeSaveStrings(SL: TStrings; const Filename: string);
    //字符串处理止

    //字体处理起
    //procedure StringToFont(sFont: string; Font: TFont; bIncludeColor: Boolean = True);
    //function FontToString(Font: TFont; bIncludeColor: Boolean = True): string;
    //字体处理止

    //网络起
    //判定是否在线
    function NetJudgeOnline:boolean;
    //得到本机的局域网Ip地址
    Function NetGetLocalIp(var LocalIp:string): Boolean;
    //通过Ip返回机器名
    Function NetGetNameByIPAddr(IPAddr: string; var MacName: string): Boolean ;
    //获取网络中SQLServer列表
    Function NetGetSQLServerList(var List: Tstringlist): Boolean;
    //获取网络中的所有网络类型
    Function NetGetNetList(var List: Tstringlist): Boolean;
    //获取网络中的工作组
    Function NetGetGroupList(var List: TStringList): Boolean;
    //获取工作组中所有计算机
    Function NetGetUsers(GroupName: string; var List: TStringList): Boolean;
    //获取网络中的资源
    Function NetGetUserResource(IpAddr: string; var List: TStringList): Boolean;
    //映射网络驱动器
    Function NetAddConnection(NetPath: Pchar; PassWord: Pchar;LocalPath: Pchar): Boolean;
    //检测网络状态
    Function NetCheckNet(IpAddr:string): Boolean;
    //检测机器是否登入网络
    Function NetCheckMacAttachNet: Boolean;
    //判断Ip协议有没有安装   这个函数有问题
    Function NetIsIPInstalled : boolean;
    //检测机器是否上网
    Function NetInternetConnected: Boolean;
    //网络止

    //窗口起
    //function FormCreateProcessFrm(MsgTitle: string):TForm;
    //窗口止

    //EMail起
    function CheckMailAddress(Text: string): boolean;
    //EMail止
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
  C_Err_GetLocalIp       = '获取本地ip失败';
  C_Err_GetNameByIpAddr  = '获取主机名失败';
  C_Err_GetSQLServerList = '获取SQLServer服务器失败';
  C_Err_GetUserResource  = '获取共享资失败';
  C_Err_GetGroupList     = '获取所有工作组失败';
  C_Err_GetGroupUsers    = '获取工作组中所有计算机失败';
  C_Err_GetNetList       = '获取所有网络类型失败';
  C_Err_CheckNet         = '网络不通';
  C_Err_CheckAttachNet   = '未登入网络';
  C_Err_InternetConnected ='没有上网';
  C_Txt_CheckNetSuccess  = '网络畅通';
  C_Txt_CheckAttachNetSuccess = '已登入网络';
  C_Txt_InternetConnected ='上网了';

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

function TruncateTrailNumber(var S: string): Integer;//取得逗号分开的两数，后数据必为合法整数222,333 s := 222 result := 333
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
  {//if not MsgYesNoBox('确信要删除该目录及以下所有文件夹和文件吗？') then exit;
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
  //if not MsgYesNoBox('确信要删除该目录及以下所有文件夹和文件吗？') then exit;
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
  {// 调用shFileOperation函数可以实现对目录的拷贝、移动、重命名或删除操作
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
  {// 调用shFileOperation函数可以实现对目录的拷贝、移动、重命名或删除操作
  if not DirectoryExists(ADirName) then
  begin
    aa := ADirName;
    MsgBox('不存在文件夹“' + PathGetLeafDir(aa) + '”,删除失败！');
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

//系统部分
procedure TPub.MsgBox(const Msg: string);
begin
  //2022-10-19 Showmessage(Msg);
  {$ifdef mswindows}
  //MessageBox(0, PChar(Msg), '提示信息', 1);
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
//以下时间
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
 if h <> 0 then Result := result + format('%-.2d  ', [h]);
 if m <> 0 then Result := result + format('%-.2d だ ', [m]);
 if s <> 0 then Result := result + format('%-.2d  ', [s]);
end;

//以下控件
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

//以下字符串
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
//以下字体
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
            aWaitForm.Caption := '正在复制' + aDir + sr.Name;
            Application.ProcessMessages;
            FileCopyFile(aDir + sr.Name,sDir + sr.Name);//在线程中执行
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
    if  Pub.MsgYesNoBox('已存在该文件夹确信要覆盖吗？') then
      FileDeleteDirectory(tDir)
    else exit;
  end;
  aWaitForm := FormCreateProcessFrm('正在复制文件，请稍候...');
  try
    aWaitForm.Show;
    Application.ProcessMessages;
    MyCopy(sDir, tDir);
  finally
    ConFree(aWaitForm);//先释放Form上的控件
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
        //该参数指明shFileOperation函数将执行目录的拷贝
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
  // 调用shFileOperation函数可以实现对目录的拷贝、移动、重命名或删除操作
  if not DirectoryExists(sDir) then
  begin
    MsgBox('不存在源路径“' + sDir + '”，移动数据失败！');
    exit;
  end;
  if DirectoryExists(tDir) then
  begin
    if  Pub.MsgYesNoBox('已存在该文件夹确信要覆盖吗？') then
      FileDeleteDirectory(tDir)
    else exit;
  end else
  if not MsgYesNoBox('不存在目标路径“' + tDir + '”，要创建吗？') then exit;

  ForceDirectories(tDir);
  MyFileCopyDirectory(sDir, tDir, AHandle, 1);
end;

procedure TPub.FileCopyDirectory(sDir, tDir:string;AHandle:Thandle);
begin
  // 调用shFileOperation函数可以实现对目录的拷贝、移动、重命名或删除操作
  if not DirectoryExists(sDir) then
  begin
    MsgBox('不存在源路径“' + sDir + '”，复制失败！');
    exit;
  end;
  if DirectoryExists(tDir) then
  begin
    if  Pub.MsgYesNoBox('已存在该文件夹确信要覆盖吗？') then
      FileDeleteDirectory(tDir)
    else exit;
  end else
  if not MsgYesNoBox('不存在目标路径“' + tDir + '”，要创建吗？') then exit;
  ForceDirectories(tDir);
  MyFileCopyDirectory(sDir, tDir, AHandle);
end;
//以下网络

function TPub.NetJudgeOnline: boolean;
var
  b: array[0..4] of Byte;
begin

end;

{=================================================================
  功  能: 检测机器是否登入网络
  参  数: 无
  返回值: 成功:  True  失败:  False
  备 注:
  版 本:
     1.0  2002/10/03 09:55:00
=================================================================}
Function TPub.NetCheckMacAttachNet: Boolean;
begin
  Result := False;
  //if GetSystemMetrics(SM_NETWORK) <> 0 then  //所有连入网的
    Result := True;
end;

{=================================================================
  功  能: 返回本机的局域网Ip地址
  参  数: 无
  返回值: 成功:  True, 并填充LocalIp   失败:  False
  备 注:
  版 本:
     1.0  2002/10/02 21:05:00
=================================================================}
function TPub.NetGetLocalIP(var LocalIp: string): Boolean;

begin

end;

function TPub.NetGetCopmuterName(var AName: string): Boolean;

begin

end;

{=================================================================
  功  能: 通过Ip返回机器名
  参  数:
          IpAddr: 想要得到名字的Ip
  返回值: 成功:  机器名   失败:  ''
  备 注:
    inet_addr function converts a string containing an Internet
    Protocol dotted address into an in_addr.
  版 本:
    1.0  2002/10/02 22:09:00
=================================================================}
function TPub.NetGetNameByIPAddr(IPAddr : String;var MacName:String): Boolean;

begin

end;

{=================================================================
  功  能: 返回网络中SQLServer列表
  参  数:
          List: 需要填充的List
  返回值: 成功:  True,并填充List  失败 False
  备 注:
  版 本:
    1.0  2002/10/02 22:44:00
=================================================================}
Function TPub.NetGetSQLServerList(var List: Tstringlist): boolean;

begin

end;

{=================================================================
  功  能: 判断Ip协议有没有安装
  参  数: 无
  返回值: 成功:  True 失败: False;
  备 注:   该函数还有问题
  版 本:
     1.0  2002/10/02 21:05:00
=================================================================}
Function TPub.NetIsIPInstalled : boolean;

begin

end;
{=================================================================
  功  能: 返回网络中的共享资源
  参  数:
          IpAddr: 机器Ip
          List: 需要填充的List
  返回值: 成功:  True,并填充List 失败: False;
  备 注:
     WNetOpenEnum function starts an enumeration of network
     resources or existing connections.
     WNetEnumResource function continues a network-resource
     enumeration started by the WNetOpenEnum function.
  版 本:
     1.0  2002/10/03 07:30:00
=================================================================}
Function TPub.NetGetUserResource(IpAddr: string; var List: TStringList): Boolean;
begin

end;

{=================================================================
  功  能: 返回网络中的工作组
  参  数:
          List: 需要填充的List
  返回值: 成功:  True,并填充List 失败: False;
  备  注:
  版  本:
     1.0  2002/10/03 08:00:00
=================================================================}
Function TPub.NetGetGroupList( var List : TStringList ) : Boolean;
begin

end;
{=================================================================
  功  能: 列举工作组中所有的计算机
  参  数:
          List: 需要填充的List
  返回值: 成功:  True,并填充List 失败: False;
  备  注:
  版  本:
     1.0  2002/10/03 08:00:00
=================================================================}
Function TPub.NetGetUsers(GroupName: string; var List: TStringList): Boolean;
begin

end;
{=================================================================
  功  能: 列举所有网络类型
  参  数:
          List: 需要填充的List
  返回值: 成功:  True,并填充List 失败: False;
  备 注:
  版 本:
     1.0  2002/10/03 08:54:00
=================================================================}
Function TPub.NetGetNetList(var List: Tstringlist): Boolean;
begin

end;
{=================================================================
  功  能: 映射网络驱动器
  参  数:
          NetPath: 想要映射的网络路径
          Password: 访问密码
          Localpath 本地路径
  返回值: 成功:  True  失败: False;
  备 注:
  版 本:
     1.0  2002/10/03 09:24:00
=================================================================}
Function TPub.NetAddConnection(NetPath: Pchar; PassWord: Pchar
                          ;LocalPath: Pchar): Boolean;
begin

end;
{=================================================================
  功  能:  检测网络状态
  参  数:
          IpAddr: 被测试网络上主机的IP地址或名称，建议使用Ip
  返回值: 成功:  True  失败: False;
  备 注:
  版 本:
     1.0  2002/10/03 09:40:00
=================================================================}
Function TPub.NetCheckNet(IpAddr: string): Boolean;
begin

end;


{=================================================================
  功  能:  检测计算机是否上网
  参  数:  无
  返回值:  成功:  True  失败: False;
  备 注:   uses Wininet
  版 本:
     1.0  2002/10/07 13:33:00
=================================================================}
function TPub.NetInternetConnected: Boolean;
begin

end;

{等待窗口起}
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
  FClientUniqueCode := Random(500);//RandomRange(0, 500); //其他程序(地方)不要调用, 只适合该单元

finalization
  Pub.Free;

end.


