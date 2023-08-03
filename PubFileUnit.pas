
{$ifdef fpc}
{$MODE Delphi}
{$endif}

unit PubFileUnit;

interface
  uses {$ifdef mswindows}Windows, ShellAPI, {$endif}SysUtils, Messages, Classes, Dialogs, SyncObjs;

type
  TMyClass = class
  private
    procedure CleanDirectoryProc(sFileName: string; var bContinue: Boolean; NeedDelDir: boolean);
  end;

  TEnumDirectoryFileProc = procedure (Filename: string; var bContinue: Boolean; NeedDelDir: boolean) of object;

  PubFile = class
  private
    class procedure MyFileCopyDirectory(sDir, tDir: string;
      AHandle: Thandle; Flag: integer = 0);
  public
    //文件操作部分起
    //拷贝一个文件，封装CopyFile
    class function FileCopyFile(const sSrcFile, sDstFile: string): boolean;
    //给定路径复制文件到同一目录下
    class procedure FileCopyDirectory(sDir, tDir: string);overload;
    //给定路径原样复制文件 ，用WinAPI ,若原目录下有相同文件则再生成一个
    class procedure FileCopyDirectory(AHandle:Thandle; sDir, tDir:string);overload;
    //移动文件夹
    class procedure FileMoveDirectory(AHandle:Thandle; sDir, tDir:string);
    //删除给定路径及以下的所有路径和文件
    class procedure FileDeleteDirectory(sDir: string; NeedDelDir: boolean = true);overload;
    //删除给定路径及以下的所有路径和文件 用WinApi
    class procedure FileDeleteDirectory(AHandle: THandle;ADirName: string);overload;
    //删除给定路径及以下的所有路径和文件 到回收站
    class procedure FileDeleteDirectoryToCycle(AHandle: THandle; ADirName: string);
    //取得指定文件的大小
    class function  FileGetFileSize(const Filename: string): int64;
    class function  FileGetFileSizeA(const Filename: string): int64;
    //在Path下取得唯一FilenameX文件
    class function  FileGetUniqueFileName(const Path: string; Filename: string): string;
    //取得临时文件
    class function  FileGetTemporaryFileName(ext: string = ''): string;
    //取得临时路径
    class function  FileGetTemporaryPath: string;
    //取唯一临时路径, 不重复, 不PartPath不能为空
    class function FileGetTemporaryPathEx(PartPath: string): string;
    //取文件修改时间
    class function FileGetFileTime(FileName: string): TDatetime;
    //取文件修改时间
    class function FileGetFileTimeA(FileName: string): string;
    //改变文件修改时间
    class Procedure FileChangeFileDate(FileName, NewDate:String);
    class function FileChangeFileDateA(FileName: string; NewDate: TDateTime): boolean;
    //写文件
    class procedure FileWriteLog(FileName, Text: string; Count: integer = 2000; EURecordBegin: string = 'EURecordBegin'; IsZZZ: boolean = false);

    //取得系统路径
    class function PathGetSystemPath: string;
    //取得Windows路径
    class function PathGetWindowsPath: string;
    //取Program files路径
    class function PathGetPragramFiles: string;
    //给定文件名取得在系统目录下的路径，复制时用
    class function PathSystemDirFile(const Filename: string): string;
    //给定文件名取得在Windows目录下的路径，复制时用
    class function PathWindowsDirFile(const Filename: string): string;
    //给定文件名取得在系统盘下的路径，复制时用
    class function PathSystemDriveFile(const Filename: string): string;
    //路径最后有'/'则去'/'
    class function PathWithoutSlash(const Path: string): string;
    //路径最后没有'/'则加'/'
    class function PathWithSlash(const Path: string): string;
    //取得两路径的不同部分，条件是前半部分相同
    class function PathRelativePath(BaseDir, FilePath: string): string;
    //取得去掉属性的路径，文件名也作为DIR
    class function PathExtractFileNameNoExt(Filename: string): string;
    //判断两路径是否相等
    class function PathComparePath(const Path1, Path2: string): Boolean;
    //取得给定路径的父路径
    class function PathParentDirectory(Path: string): string;
    //分割路径，Result=根(如d:)sPath = 除根外的其他部分
    class function PathGetRootDir(var sPath: string): string;
    //取得路径最后部分和其他部分 如d:\aa\aa result:=aa  sPath:=d:\aa\
    class function PathGetLeafDir(var sPath: string): string;
    //取得当前应用程序的路径
    class function PathExePath: string;
    //给路径加扩展名 Ext 带点 如 .txt、.xls
    class function PathWithExt(Path, Ext: string): string;
    class function PathGetDownloadedProgramFiles: string;
    //文件操作部分止
    class function GetUser_Path: string;
  end;

implementation

uses Registry;

const
  DEFAULT_DELIMITERS = [' ', #9, #10, #13];//空格分隔
var
  F_CriticalSection: TCriticalSection;
{ PubFile }

class procedure PubFile.MyFileCopyDirectory(sDir, tDir:string;AHandle:Thandle;Flag: integer = 0);
{$ifdef dotnet}
var
  //fromdir,todir{,dirname}: TStringBuilder;//pchar;
  //fromdir,todir{,dirname}: AnsiString;
  SHFileOpStruct: TSHFileOpStruct; //TSHFileOpStruct;
  //a, b: widestring;
begin
  //GetMem(fromdir,length(sDir)+2);
  //fromdir := TStringBuilder.Create;
  //todir := TStringBuilder.Create;
  try
    //GetMem(todir,length(tdir)+2);
    try

      with SHFileOpStruct  do
      begin
        wnd := AHandle;
        if Flag = 1 then
          WFunc := FO_MOVE
        else
          WFunc := FO_COPY;
        //该参数指明shFileOperation函数将执行目录的拷贝
        pFrom := sDir; //fromdir;
        pTO := tDir;
        fFlags:=FOF_NOCONFIRMATION OR FOF_RENAMEONCOLLISION;
        fAnyOperationsAborted:=false;
        hnamemappings:=nil;
        lpszprogresstitle:='';
      end;
      if SHFileOperation(SHFileOpStruct)<>0 then
      //if shFileOperation(SHFileOpStruct)<>0 then
        Raiselastwin32Error;
    finally
      //FreeMem(todir,length(tDir)+2);
    end;
  finally
    //FreeMem(fromdir,length(sDir)+2);
  end;
end;
{$else}
var
  fromdir,todir{,dirname}:pchar;
  {$ifdef mswindows}
  SHFileOpStruct: TSHFileOpStruct;
  {$endif}
begin
  {$ifdef mswindows}
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
  {$endif}
end;
{$endif}

class procedure PubFile.FileCopyDirectory(AHandle: Thandle; sDir,
  tDir: string);
begin
  ForceDirectories(tDir);
  sDir := PathWithoutSlash(sDir);
  tDir := PathWithoutSlash(tDir);
  MyFileCopyDirectory(sDir, tDir, AHandle);
end;

class procedure PubFile.FileCopyDirectory(sDir, tDir: string);
var
  SearchRec: TSearchRec;
  Status   : Integer;
  fname: string;
begin
  sDir := PathWithSlash(sDir);
  tDir := PathWithSlash(tDir);
  ForceDirectories(tDir);
  Status := FindFirst(sDir + '*.*', faAnyFile, SearchRec);
  try
    while Status = 0 do
    begin
      fname := SearchRec.name;
      if SearchRec.Attr and faDirectory = faDirectory then
      begin
        if (fname <> '.') and (fname <> '..') then
          FileCopyDirectory(sDir + fname, tDir + fname);
      end else
        FileCopyFile(sDir + fname, tDir + fname);

      Status := FindNext(SearchRec);
    end;
  finally
    SysUtils.FindClose(SearchRec);
  end;
end;

class function PubFile.FileCopyFile(const sSrcFile, sDstFile: string): boolean;
var
  Ms: TMemoryStream;
begin
  Result := false;
  if AnsiCompareFileName(sSrcFile, sDstFile) <> 0 then
  {$ifdef dotnet}
    Result := CopyFile(sSrcFile, sDstFile, False);
  {$else}
    {$ifdef fpc} //fpc遇中文CopyFile不了
    try
      Ms := TMemoryStream.Create;
      try
        Ms.LoadFromFile(sSrcFile);
        Ms.SaveToFile(sDstFile);
      finally
        Ms.Free;
      end;
    except
    end;
    {$else}
    Result := CopyFile(PChar(sSrcFile), PChar(sDstFile), False);
    {$endif}
  {$endif}
end;

procedure EnumDirectoryFiles(sDir, SMASK: string; Attr: Integer; EnumDirectoryFileProc: TEnumDirectoryFileProc; NeedDelDir: boolean);
var
  SearchRec: TSearchRec;
  Status   : Integer;
  bContinue: Boolean;
begin
  sDir := PubFile.PathWithSlash(sDir);

  // traverse child directories
  Status := FindFirst(sDir + '*.*', faDirectory, SearchRec);
  try
    while Status = 0 do
    begin
      if (SearchRec.name <> '.') and (SearchRec.name <> '..') then
        EnumDirectoryFiles(sDir + SearchRec.name, SMASK, Attr, EnumDirectoryFileProc, NeedDelDir);

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
        EnumDirectoryFileProc(sDir + SearchRec.name, bContinue, NeedDelDir);
        if not bContinue then Break;
      end;

      Status := FindNext(SearchRec);
    end;
  finally
    SysUtils.FindClose(SearchRec);
  end;
end;

class procedure PubFile.FileDeleteDirectory(sDir: string; NeedDelDir: boolean);
begin
  try
    sDir := PathWithoutSlash(sDir);
    if not DirectoryExists(sDir) then exit;
    with TMyClass.Create do                                
    try
      EnumDirectoryFiles(sDir, '*.*', faAnyFile, CleanDirectoryProc, NeedDelDir);
    finally
      Free;
    end;
    if NeedDelDir then //2013-09-04 add
      RMDir(sDir);
  except
  end;
end;

class procedure PubFile.FileDeleteDirectory(AHandle: THandle;
  ADirName: string);
{$ifdef dotnet}
var
  SHFileOpStruct:TSHFileOpStruct;
  //DirName: PChar;
  BufferSize: Cardinal;
begin
  ADirName := PathWithoutSlash(ADirName);
  if not DirectoryExists(ADirName) then exit;
  // 调用shFileOperation函数可以实现对目录的拷贝、移动、重命名或删除操作
  BufferSize := length(ADirName) + 2;
  //GetMem(DirName,BufferSize);
  try
    //FIllChar(DirName^, BufferSize, 0);
    //StrCopy(DirName,PChar(ADirName));
    with SHFileOpStruct  do
    begin
      Wnd := AHandle;
      WFunc := FO_DELETE;
      pFrom := ADirName; //DirName;
      pTO := nil;
      fFlags := FOF_FILESONLY;//FOF_ALLOWUNDO;

      fAnyOperationsAborted := false;
      hNameMappings := nil;
      lpszProgressTitle := nil;
    end;
    if SHFileOperation(SHFileOpStruct) <> 0 then
      Raiselastwin32Error;
  finally
    //FreeMem(DirName,BufferSize);
  end;
end;
{$else}
var
  {$ifdef mswindows}
  SHFileOpStruct:TSHFileOpStruct;
  {$endif}
  DirName: PChar;
  BufferSize: Cardinal;
begin
  {$ifdef mswindows}
  ADirName := PathWithoutSlash(ADirName);
  if not DirectoryExists(ADirName) then exit;
  // 调用shFileOperation函数可以实现对目录的拷贝、移动、重命名或删除操作
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
      fFlags := FOF_FILESONLY;//FOF_ALLOWUNDO;

      fAnyOperationsAborted := false;
      hNameMappings := nil;
      lpszProgressTitle := nil;
    end;
    if SHFileOperation(SHFileOpStruct) <> 0 then
      Raiselastwin32Error;
  finally
    FreeMem(DirName,BufferSize);
  end;
  {$endif}
end;
{$endif}

class procedure PubFile.FileDeleteDirectoryToCycle(AHandle: THandle;
  ADirName: string);
{$ifdef dotnet}
var
  SHFileOpStruct:TSHFileOpStruct;
  //DirName: PChar;
  BufferSize: Cardinal;
begin
  ADirName := PathWithoutSlash(ADirName);
  if not DirectoryExists(ADirName) then exit;
  // 调用shFileOperation函数可以实现对目录的拷贝、移动、重命名或删除操作
  BufferSize := length(ADirName) + 2;
  //GetMem(DirName,BufferSize);
  try
    //FIllChar(DirName^, BufferSize, 0);
    //StrCopy(DirName,PChar(ADirName));
    with SHFileOpStruct  do
    begin
      Wnd := AHandle;
      WFunc := FO_DELETE;
      pFrom := ADirName;
      pTO := nil;
      fFlags := FOF_ALLOWUNDO;

      fAnyOperationsAborted:=false;
      hNameMappings:=nil;
      lpszProgressTitle:=nil;
    end;
    if SHFileOperation(SHFileOpStruct) <> 0 then
      Raiselastwin32Error;
  finally
    //FreeMem(DirName,BufferSize);
  end;
end;
{$else}
var
  {$ifdef mswindows}
  SHFileOpStruct:TSHFileOpStruct;
  {$endif}
  DirName: PChar;
  BufferSize: Cardinal;
begin
  {$ifdef mswindows}
  ADirName := PathWithoutSlash(ADirName);
  if not DirectoryExists(ADirName) then exit;
  // 调用shFileOperation函数可以实现对目录的拷贝、移动、重命名或删除操作
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
  end;
  {$endif}
end;
{$endif}

class function PubFile.FileGetFileSize(const Filename: string): int64;
var
  HFILE: THandle;
  FS: TFileStream;
begin
  try
    (*{$ifdef mswindows}
      {$ifdef dotnet}
      HFILE := CreateFile(Filename, GENERIC_READ, FILE_SHARE_READ, nil,
        OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
      {$else}
      HFILE := CreateFile(PChar(Filename), GENERIC_READ, FILE_SHARE_READ, nil,
        OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
      {$endif}
      if HFILE <> INVALID_HANDLE_VALUE then
      begin
        Result := GetFileSize(HFILE, nil);
        CloseHandle(HFILE);
      end else
        Result := 0;
    {$else}
       Result := FileGetFileSizeA(Filename);
    {$endif} *)
    Fs := TFileStream.Create(Filename, fmShareDenyNone);
    try
      Result := FS.Size;
    finally
      FS.Free;
    end;
  except
    Result := 0;
  end;
end;

class function PubFile.FileGetTemporaryFileName(ext: string): string;
{$ifdef dotnet}
var
  //: string; //array[0..255] of Char;
  Buf, Buffer: TStringBuilder;
begin
  Buffer := TStringBuilder.Create;
  Buf := TStringBuilder.Create;
  try
    Buf.Capacity := 255;
    GetTempPath(Buf.Capacity, Buf);
    Buffer.Capacity := 255;
    GetTempFileName(Buf.ToString, 'xpd', 0, Buffer);
    Result := Buffer.ToString;
  finally
    Buf.Free;
    Buffer.Free;
  end;
  //Result := StrPas(@Buf1);
end;
{$else}
var
  Buf, Buf1: array[0..255] of Char;
begin
  {$ifdef mswindows}
  GetTempPath(255, @Buf);
  GetTempFileName(@Buf, 'xpd', 0, @Buf1);
  //Result := string(@Buf1);
  Result := string(Buf1);
  if trim(ext) <> '' then
  begin
    DeleteFile(Result);
    Result := ChangeFileExt(Result, ext);
  end;
  {$endif}
end;
{$endif}

class function PubFile.FileGetUniqueFileName(const Path: string;
  Filename: string): string;
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

class procedure PubFile.FileMoveDirectory(AHandle: Thandle; sDir,
  tDir: string);
begin
  ForceDirectories(tDir);
  MyFileCopyDirectory(sDir, tDir, AHandle, 1);
end;

class function PubFile.PathComparePath(const Path1,
  Path2: string): Boolean;
begin
  Result := AnsiCompareFileName(PathWithoutSlash(Path1), PathWithoutSlash(Path2)) = 0;
end;

class function PubFile.PathExePath: string;
begin
  Result := ExtractFilePath(ParamStr(0))
end;

class function PubFile.PathExtractFileNameNoExt(Filename: string): string;
begin
  Result := Copy(Filename, 1, Length(Filename) - Length(ExtractFileExt(Filename)));
end;

class function PubFile.PathGetLeafDir(var sPath: string): string;
begin
  sPath := PathWithoutSlash(sPath);
  Result := ExtractFileName(sPath);
  sPath := ExtractFilePath(sPath);
end;

class function PubFile.PathGetRootDir(var sPath: string): string;
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

class function PubFile.PathGetSystemPath: string;
{$ifdef dotnet}
var
  Buffer: TStringBuilder; //array[0..255] of Char;
begin
  Buffer := TStringBuilder.Create;
  try
    GetSystemDirectory(Buffer, 255);
    Result := PathWithSlash(Buffer.ToString);
  finally
    Buffer.Free;
  end;
  //Result := PathWithSlash(string(@Buf));
end;
{$else}
var
  Buf: array[0..255] of Char;
begin
  {$ifdef mswindows}
  GetSystemDirectory(@Buf, 255);
  Result := PathWithSlash(string(@Buf));
  {$endif}
end;
{$endif}

class function PubFile.PathGetWindowsPath: string;
{$ifdef dotnet}
var
  Buf: TStringBuilder;//array[0..255] of Char;
begin
  Buf := TStringBuilder.Create;
  try
    GetWindowsDirectory(Buf, 255);
    Result := PathWithSlash(Buf.ToString);
  finally
    Buf.Free;
  end;
  //Result := PathWithSlash(string(@Buf));
end;
{$else}
var
  Buf: array[0..255] of Char;
begin
  {$ifdef mswindows}
  GetWindowsDirectory(@Buf, 255);
  Result := PathWithSlash(string(@Buf));
  {$endif}
end;
{$endif}

class function PubFile.PathGetDownloadedProgramFiles: string;
begin
  Result := PubFile.PathGetWindowsPath + 'Downloaded Program Files\';
end;

class function PubFile.PathParentDirectory(Path: string): string;
var
  iLastAntiSlash: Integer;

  function CountAntiSlash: Integer;
  var
    I: Integer;
  begin
    {$ifdef mswindows}
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
    {$endif}
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
  end else Result := Path;
end;

class function PubFile.PathRelativePath(BaseDir, FilePath: string): string;
begin
  Result := FilePath;
  BaseDir := AnsiUpperCaseFileName(PathWithSlash(BaseDir));
  FilePath := AnsiUpperCaseFileName(FilePath);
  if Copy(FilePath, 1, Length(BaseDir)) = BaseDir then
    Delete(Result, 1, Length(BaseDir));
end;

class function PubFile.PathSystemDirFile(const Filename: string): string;
{$ifdef dotnet}
var
  Buf: TStringBuilder;//array[0..255] of Char;
begin
  Buf := TStringBuilder.Create;
  try
    GetSystemDirectory(Buf, 255);
    Result := PathWithSlash(Buf.ToString) + Filename;
  finally
    Buf.Free;
  end;
  //Result := PathWithSlash(string(@Buf)) + Filename;
end;
{$else}
var
  Buf: array[0..255] of Char;
begin
  {$ifdef mswindows}
  GetSystemDirectory(@Buf, 255);
  Result := PathWithSlash(string(@Buf)) + Filename;
  {$endif}
end;
{$endif}

class function PubFile.PathSystemDriveFile(const Filename: string): string;
{$ifdef dotnet}
var
  Buf: TStringBuilder;//array[0..255] of Char;
begin
  Buf := TStringBuilder.Create;
  try
    Buf.Capacity := 255;
    GetSystemDirectory(Buf, 255);
    Result := PathWithSlash(ExtractFileDrive(Buf.ToString)) + Filename;
  finally
    Buf.Free;
  end;
end;
{$else}
var
  Buf: array[0..255] of Char;
begin
  {$ifdef mswindows}
  GetSystemDirectory(@Buf, 255);
  Result := PathWithSlash(ExtractFileDrive(string(@Buf))) + Filename;
  {$endif}
end;
{$endif}

class function PubFile.PathWindowsDirFile(const Filename: string): string;
{$ifdef dotnet}
var
  Buf: TStringBuilder;//array[0..255] of Char;
begin
  Buf := TStringBuilder.Create;
  try
    GetWindowsDirectory(Buf, 255);
    Result := PathWithSlash(Buf.ToString) + Filename;
  finally
    Buf.Free;
  end;
end;
{$else}
var
  Buf: array[0..255] of Char;
begin
  {$ifdef mswindows}
  //Buf := TStringBuilder.Create;
  try
    GetWindowsDirectory(@Buf, 255);
    Result := string(@Buf);
    Result := PathWithSlash(Result) + Filename;
  finally
    //Buf.Free;
  end;
  {$endif}
end;
{$endif}

class function PubFile.PathWithoutSlash(const Path: string): string;
begin
  if (Length(Path) > 0) and (Path[Length(Path)] = '\') then Result := Copy(Path, 1, Length(Path) - 1)
  else Result := Path;
end;

class function PubFile.PathWithSlash(const Path: string): string;
begin
  Result := Path;
  if (Length(Result) > 0) and (Result[Length(Result)] <> '\') then Result := Result + '\';
end;

class function PubFile.FileGetTemporaryPath: string;
{$ifdef dotnet}
var
  Buf: TStringBuilder;//array[0..255] of Char;
begin
  Buf := TStringBuilder.Create;
  try
    GetTempPath(255, Buf);
    //Result := string(@Buf);
    Result := PathWithSlash(Buf.ToString);
  finally
    Buf.Free;
  end;
end;
{$else}
var
  Buf: array[0..255] of Char;
begin
  {$ifdef mswindows}
  GetTempPath(255, @Buf);
  //Result := string(@Buf);
  Result := string(Buf);
  Result := PathWithSlash(Result);
  {$endif}
end;
{$endif}

class function PubFile.FileGetTemporaryPathEx(PartPath: string): string;
var
  Count: integer;
  Path: string;
begin
  Result := FileGetTemporaryPath + PartPath;
  Result := PathWithoutSlash(Result);
  Path := Result;
  Count := 0;
  while true do
  begin
    Inc(Count);
    if not DirectoryExists(Result) then break;
    Result := Path + IntToStr(Count);
  end;
  Result := PathWithSlash(Result);
end;

class function PubFile.PathWithExt(Path, Ext: string): string;
begin
  Result := Path;
  if trim(Result) = '' then exit;
  Result := ChangeFileExt(Path, Ext);
end;

class function PubFile.FileGetFileTime(FileName: string): TDatetime;
begin
  Result := FileDateToDateTime(FileAge(FileName));
end;

class procedure PubFile.FileChangeFileDate(FileName, NewDate: String);
{$ifdef dotnet}
var
  FHandle: TOpenedFile;
  FmtStr,TimeStr: String;
begin
  try
    FHandle := FileOpen(FileName,fmOpenReadWrite);
    try
      if FHandle <> nil then
      begin
        FmtStr := LongDateFormat;
        TimeStr := LongTimeFormat;
        LongDateFormat := 'YYYY-MM-DD';
        LongTimeFormat := 'HH:MM:SS';
        FileSetDate(FHandle,DateTimeToFileDate(StrToDateTime(NewDate)));
        LongDateFormat := FmtStr;
        LongTimeFormat := TimeStr;
      end;
    finally
      FileClose(FHandle);
    end;
  except
  end;
end;
{$else}
var
  FHandle: Integer;
  FmtStr,TimeStr: String;
begin
  try
    FHandle:=FileOpen(FileName,fmOpenReadWrite);
    try
      if FHandle<>-1 then
      begin
        FmtStr := FormatSettings.LongDateFormat;
        TimeStr := FormatSettings.LongTimeFormat;
        FormatSettings.LongDateFormat := 'YYYY-MM-DD';
        FormatSettings.LongTimeFormat := 'HH:MM:SS';
        FileSetDate(FHandle,DateTimeToFileDate(StrToDateTime(NewDate)));
        FormatSettings.LongDateFormat := FmtStr;
        FormatSettings.LongTimeFormat := TimeStr;
      end;
    finally
      FileClose(FHandle);
    end;
  except
  end;
end;
{$endif}

class function PubFile.PathGetPragramFiles: string;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('\Software\Microsoft\Windows\CurrentVersion',False) then
    begin
      Result := Reg.ReadString('ProgramFilesDir');
      Reg.CloseKey;
    end;
    Result := PathWithSlash(Result);
  finally
    Reg.Free;
  end;
end;

class function PubFile.FileGetFileTimeA(FileName: string): string;
begin
  Result := FormatDatetime('yyyy-mm-dd hh:nn:ss', FileGetFileTime(FileName));
end;

class function PubFile.FileChangeFileDateA(FileName: string;
  NewDate: TDateTime): boolean;
{$ifdef dotnet}
var
  FHandle: TOpenedFile;
  FmtStr,TimeStr: String;
begin
  Result := false;
  try
    FHandle:=FileOpen(FileName,fmOpenReadWrite);
    try
      if FHandle <> nil then
      begin
        FmtStr := LongDateFormat;
        TimeStr := LongTimeFormat;
        LongDateFormat := 'YYYY-MM-DD';
        LongTimeFormat := 'HH:MM:SS';
        FileSetDate(FHandle,DateTimeToFileDate(NewDate));
        LongDateFormat := FmtStr;
        LongTimeFormat := TimeStr;
        Result := true;
      end;
    finally
      FileClose(FHandle);
    end;
  except
  end;
end;
{$else}
var
  FHandle: Integer;
  FmtStr,TimeStr: String;
begin
  Result := false;
  try
    FHandle:=FileOpen(FileName,fmOpenReadWrite);
    try
      if FHandle<>-1 then
      begin
        {FmtStr := LongDateFormat;
        TimeStr := LongTimeFormat;
        LongDateFormat := 'YYYY-MM-DD';
        LongTimeFormat := 'HH:MM:SS';
        FileSetDate(FHandle,DateTimeToFileDate(NewDate));
        LongDateFormat := FmtStr;
        LongTimeFormat := TimeStr;
        Result := true;}
      end;
    finally
      FileClose(FHandle);
    end;
  except
  end;
end;
{$endif}

class function PubFile.FileGetFileSizeA(const Filename: string): int64;
var
  Sr: TSearchRec;
begin
  try
    try
      if FindFirst(Filename, faAnyFile, Sr) = 0 then
        Result := Sr.Size
      else
        Result := 0;
    finally
      FindClose(Sr);
    end;
  except
    Result := 0;
  end;
end;
class procedure PubFile.FileWriteLog(FileName, Text: string; Count: integer; EURecordBegin: string; IsZZZ: boolean);
var
  SL: TStringlist;
  AFieldName, Time: string;
  lp: integer;
begin
  try
    SL := TStringList.Create;
    try
      if FileExists(FileName) then
      try
        SL.LoadFromFile(FileName);
      except
      end;
      //2017-03-16 mod if SL.Count > Count then
      if SL.Count > 4000 then
      begin
        try
          AFieldName := ExtractFileName(FileName);
          AFieldName := StringReplace(AFieldName, ExtractFileExt(FileName), '', [rfReplaceAll]);
          AFieldName := AFieldName + FormatDateTime('YYYYMMDDHHNNSS', Now) + ExtractFileExt(FileName);
          AFieldName := ExtractFilePath(FileName) + AFieldName;
          //SL.SaveToFile(AFieldName);
          for lp := 1 to 50 do
          begin
            try
              SL.SaveToFile(AFieldName);
              if FileExists(AFieldName) then
              begin
                SL.Clear; //2017-02-08 add
                break;
              end;
            except
              Sleep(100);
            end;
          end;
        except
        end;
      end;
      ForceDirectories(ExtractFilePath(FileName));

      if IsZZZ then //2017-07-07 add
        Time := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now)
      else
        Time := DateTimeToStr(Now);

      if trim(Text) = '' then
        SL.Add('%' + EURecordBegin + ': ' + Time + ' ** Error but no msg.' + ' Recordend.')
      else
        SL.Add('%' + EURecordBegin + ': ' + Time + ' ** ' + Text + ' Recordend.');
      //SL.SaveToFile('d:\dsss.txt');
      //SL.SaveToFile('c:\dsss.txt');

      for lp := 1 to 5 do
      begin
        try
          SL.SaveToFile(FileName);
          break;
        except
          Sleep(100);
        end;
      end;
    finally
      SL.Free;
    end;
  except
  end;
end;
function GetShellFolders(strDir: string): string;
const
  regPath = '\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders';
var
  Reg: TRegistry;
  strFolders: string;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(regPath, false) then begin
      strFolders := Reg.ReadString(strDir);
    end;
  finally
    Reg.Free;
  end;
  result := strFolders;
end;

class function PubFile.GetUser_Path: string;
begin
  Result := GetShellFolders('Personal'); //我的文档
  Result := PathWithSlash(Result);
  Result := Result + 'eyoue\';
  if not DirectoryExists(Result) then
    ForceDirectories(Result);
end;

{class procedure PubFile.FileWriteLog(FileName, Text: string; Count: integer; EURecordBegin: string);
var
  SL: TStringlist;
  AFieldName: string;
begin
  try
    F_CriticalSection.Enter;
    SL := TStringList.Create;
    try
      if FileExists(FileName) then
      try
        SL.LoadFromFile(FileName);
        if SL.Count > Count then
        begin
          try
            AFieldName := ExtractFileName(FileName);
            AFieldName := StringReplace(AFieldName, ExtractFileExt(FileName), '', [rfReplaceAll]);
            AFieldName := AFieldName + FormatDateTime('YYYYMMDDHHNNSS', Now) + ExtractFileExt(FileName);
            AFieldName := ExtractFilePath(FileName) + AFieldName;
            SL.SaveToFile(AFieldName);
          except
          end;
          SL.Clear;
        end;
      except
      end;
      ForceDirectories(ExtractFilePath(FileName));
      if trim(Text) = '' then
        SL.Add('%' + EURecordBegin + ': ' + DateTimeToStr(Now) + ' ** Error but no msg.' + ' Recordend.')
      else
        SL.Add('%' + EURecordBegin + ': ' + DateTimeToStr(Now) + ' ** ' + Text + ' Recordend.');
      //SL.SaveToFile('d:\dsss.txt');
      //SL.SaveToFile('c:\dsss.txt');

      SL.SaveToFile(FileName);

    finally
      F_CriticalSection.Leave;
      SL.Free;
    end;
  except
  end;
end; }

{ TMyClass }

procedure TMyClass.CleanDirectoryProc(sFileName: string;
  var bContinue: Boolean; NeedDelDir: boolean);
var
  Attr: Integer;
begin
  Attr := FileGetAttr(sFileName);
  Attr := (not faReadOnly) and Attr; // Turn off ReadOnly attribute
  Attr := (not faHidden) and Attr;   // Turn off Hidden attribute
  FileSetAttr(sFileName, Attr);
  if Attr and faDirectory <> 0 then
  begin
    if NeedDelDir then //2014-10-08 add
    RMDir(sFileName)
  end else
    SysUtils.DeleteFile(sFileName);
end;

initialization
  F_CriticalSection := TCriticalSection.Create;

finalization
  F_CriticalSection.Free;
end.
