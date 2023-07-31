unit PubSysUnit;

interface
  uses {$ifdef MSWINDOWS} Windows, {$endif}SysUtils, Classes, DB, //DBClient,
  Variants, PubStringUnit, Math, {EncdDecd, }//IdHashMessageDigest, idGlobal,
  {$ifdef dotnet}
  FMTBcd, System.Text
  {$else}
  FMTBcd
  {$endif};

type
  {PProcessWindowInfo=^TProcessWindowInfo;
  TProcessWindowInfo=record
    ProcessID:DWORD;
    Handle:THandle;
  end;}

  PeeMenuInfo = ^TeeMenuInfo;
  TeeMenuInfo = record
    MENU_ID,
    MENU_NAME,
    MENU_CODE,
    MENU_BPRI,
    MENU_PPTY,
    MENU_IFGROUP,
    MENU_IFLCL,
    MENU_LZ,
    MENU_PARAMDISP,
    MENU_CODERULE,
    MENU_ITFTMPT,
    MENU_JZ,
    MENU_COMM,
    MENU_QRTMPT,
    MENU_RPTMPT,
    MENU_PTMPT,
    Tmp: string;     //权限设置中用
    BtnFlag: boolean;//权限设置中用,表示是按钮数据
  end;

  PubSys = class
  private
  public
    //初始化系统变量
    class procedure InitSysVar;
    //封装API ShellExecute// 0:隐含窗口，1:显示窗口....其他参考帮助
    {$ifdef MSWINDOWS}
    class function ShellExecute(const sFileName: string; sPara: string= ''; sAction :string = 'Open';
       flag: integer = 1): boolean;
    //在进程中运行exe程序，可以实现等待过程

    class function ProcessExecute(const Command: string;
    {$ifdef dotnet}
      bWaitExecute: Boolean = false; bShowWindow: Boolean = true): Boolean;
    {$else}
       bWaitExecute: Boolean = false; bShowWindow: Boolean = true; PI: PProcessInformation = nil): Boolean;
    {$endif}
    {$endif}
    //大变量值到流
    class procedure VariantToStream(const Data: OleVariant;
      Stream: TStream);
    //流到大变量值
    class function StreamToVariant(Stream: TStream): OleVariant;
    //在进程中查找程序
    class function FindProcInProcess(ProcName: string): boolean;
    //从进程列表中强行杀程序
    class procedure KillProcFromProcess(ProcName: string);
    //从注表中取Socket端口
    class function GetSocketPortFromReg: integer;
    //转换数值型为空时为null
    class function NNull(Value: string): string;
    //如果值为空，则返回'0'
    class function NZero(Value: string; RepValue: string = '0'): string;
    class function NSpace(Value: string): string;
    class function Ad(const Value1, Value2: string): string; overload;
    class function AdEx(const Bcd1, Bcd2: TBcd): TBcd; overload;
    //过滤掉以豆号分隔的重复项
    class function FilterItem(Str1, Str2: string): string;
    class function GetTimeStamp(DateTime: TDateTime): string;
    //不能直接调用该Set_DefaultDecimals, 应调用PubMath的, 如果要改大，应为28合适
    class procedure Set_Decimals(DefaultDecimals: integer = 16);
    //去掉分类中不是底层的分类
    class procedure TruncCL(var OutID, OutCode: string);

    //清空Variant变量
    class procedure VarClear(var Data: OleVariant);
    class procedure VarClearEx(var Data: OleVariant);
    //所有给Variant变量赋值都要调用该方法
    //class procedure VarSetValue(var OutData: Variant; const InData: Variant);
    //取本月的第一天
    class function GetMonthFirstDay(Dt: string): string;
    ///class procedure ClearCdsIndex(cds: TClientDataSet);
    class function GeteYoueBuildVerCode: string;

    //2010-10-22
    //class function DataToXMLData(cds: TClientDataSet; Data: OleVariant): OleVariant;
    class function GetClientUniqueCode: string;

    //2012-11-19 网页颜色转到Delphi颜色
    //class function HtmlToTColor(sColor: string): TColor;
    //2012-11-19 Delphi颜色转到网页颜色
    //class function ColorToHtml(mColor: TColor): string;
    class procedure Base64ToFile(AStr, FileName: string); static; //Base64内容转为文件
    class procedure Base64ToStream(Base64Str: string; MemoryStream: TStream); static;
    class function FileToBase64(FileName: string): string; static;
    class function StreamToBase64(Stream: TMemoryStream): string; static;
    class function Base64Encode(Text: string;NoReturn: boolean = true): String; static;
    class function Base64Decode(Text: string): String; static;

    class function GetMd5(Value: string; NeedUpperCase: boolean = false): string; static;
    class function StreamToMD5(S: TStream; NeedUpperCase: boolean = false): String; static;
    class procedure WinRar_UnZip(FromFile, TOPath: string; NeedPwd: string = ''; Show: boolean = false);
    class procedure WinRar_Zip(FromDir, TOFile: string; NeedPwd: string = ''; Show: boolean = false);
    //2022-06-17 add
    class procedure Terminate_Thread;
  end;
  
  const //bbbbbbbbbbbbbbbbbbbbbbbb  //'130311'; //'130306'; //'130228'; // '120419';//'120328';//2011-11-03 //'100506';//'100415';//'100505';
    eYoueBuildVerCode = '140321';//2015-02-05 '140320';//2015-01-14 // '140307'; //'130715'; // '130619'; 

implementation

uses {$ifdef MSWINDOWS}ShellAPI, Registry, {$ifndef dotnet} {$endif}
  ActiveX, {$ENDIF}Forms;

{ PubSys }

var
 FClientUniqueCode: integer;


//2022-06-17 add start
type
  TKill = class(TThread)
  protected
    procedure Execute; override;
  public
    constructor Create();
  end;

procedure TKill.Execute;
begin
  //sleep(1000);
  {$ifdef MSWINDOWS}
  ExitProcess(0);
  {$else}
   Application.Terminate;
  {$endif}
end;
constructor TKill.Create();
begin
  FreeOnTerminate := true;
  inherited Create(False);
  FreeOnTerminate := true;
end;
//2022-06-17 add end;

class procedure PubSys.Terminate_Thread;
begin
  TKill.Create();
end;

class function PubSys.Ad(const Value1, Value2: string): string;
var
  Bcd1, Bcd2, Bcd3: TBcd;
begin
  TryStrToBcd(Value1, Bcd1);
  TryStrToBcd(Value2, Bcd2);
  {$ifdef dotnet}
  FMTBcd.BcdAdd(Bcd1, Bcd2, Bcd3);
  {$else}
  FMTBcd.BcdAdd(Bcd1, Bcd2, Bcd3);
  {$endif}
  Result := BcdToStr(Bcd3);
end;

class function PubSys.AdEx(const Bcd1, Bcd2: TBcd): TBcd;
begin
  {$ifdef dotnet}
  FMTBcd.BcdAdd(Bcd1, Bcd2, Result);
  {$else}
  FMTBcd.BcdAdd(Bcd1, Bcd2, Result);
  {$endif}
end;

class function PubSys.GetSocketPortFromReg: integer;
{$ifdef MSWINDOWS}
Const
  FPath = '\Software\Borland\Socket Server';
Var
  Reg : TRegistry;
  SL: TStringlist;
  lp: integer;
begin
  Result := 218;
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    SL := TStringlist.Create;
    try
      if Reg.OpenKey(FPath, False) then
        Reg.GetKeyNames(SL);
      for lp := 0 to SL.Count - 1 do
      begin
        if UpperCase(SL[lp]) <> 'SETTINGS' then
        begin
          if Reg.OpenKey(FPath + '\' + SL[lp], False) then
          begin
            if trim(Reg.ReadString('Port')) <> '' then
            begin
              Result := StrToInt(Reg.ReadString('Port'));
              break;
            end;
          end;
        end;
      end;
      Reg.CloseKey;
    finally
      SL.Free;
    end;
  finally
    Reg.Free;
  end;
end;
{$else}
begin

end;
{$endif}

{$ifdef MSWINDOWS}
class function PubSys.ProcessExecute(const Command: string;
  {$ifdef dotnet}
  bWaitExecute, bShowWindow: Boolean
  {$else}
  bWaitExecute, bShowWindow: Boolean; PI: PProcessInformation
  {$endif}): Boolean;
var
  StartupInfo       : TStartupInfo;
  ProcessInformation: TProcessInformation;
  {$ifdef dotnet}
  Buffer: StringBuilder;
  {$endif}
begin
  {$ifndef dotnet}
  FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
  //Buffer := Command;
  {$else}
  Buffer := StringBuilder.Create(1024);
  {$endif}
  with StartupInfo do
  begin
    cb := SizeOf(TStartupInfo);
    dwFlags := STARTF_USESHOWWINDOW;
    if bShowWindow then
      wShowWindow := SW_NORMAL
    else
      wShowWindow := SW_HIDE;
  end;

  {$ifndef dotnet}
  Result := CreateProcess(nil, PChar(Command),
    nil, nil, True, NORMAL_PRIORITY_CLASS, nil, nil,
    StartupInfo, ProcessInformation);
  {$else}
  Result := CreateProcess(nil, Buffer,
    nil, nil, True, NORMAL_PRIORITY_CLASS, nil, nil,
    StartupInfo, ProcessInformation);
  {$endif}

  if not Result then Exit;

  if bWaitExecute then
    WaitForSingleObject(ProcessInformation.hProcess, INFINITE);

  {$ifndef dotnet}
  if Assigned(PI) then
    Move(ProcessInformation, PI^, SizeOf(ProcessInformation));
  {$endif}
end;

class function PubSys.ShellExecute(const sFileName: string; sPara,
  sAction: string; flag: integer): boolean;
begin
  {$ifdef dotnet}
  Result := ShellAPI.ShellExecute(Application.Handle, sAction,
    sFileName, sPara, nil, flag) >  32;
  {$else}
  //Result := ShellAPI.ShellExecute(Application.Handle, PChar(sAction),
    //PChar(sFileName), PChar(sPara), nil, flag) >  32;
  {$endif}
end;{$ENDIF}

class procedure PubSys.VariantToStream(const Data: OleVariant; Stream: TStream);
{$ifdef dotnet}
var
  p: TBytes;//Pointer;
begin
  if VarIsArray(Data) then
  try
    p := Data; //VarArrayLock(Data);
    try
      Stream.Write(p, VarArrayHighBound(Data,1) + 1);
    finally
      //VarArrayUnlock(Data);
    end;
  except
  end;
end;
{$else}
var
  p: Pointer;
begin
  try
    p := VarArrayLock(Data);
    try
      Stream.Write(p^, VarArrayHighBound(Data,1) + 1);
    finally
      VarArrayUnlock(Data);
    end;
  except
  end;
end;
{$endif}

class function PubSys.StreamToVariant(Stream: TStream): OleVariant;
{$ifdef dotnet}
var
  p: TBytes;// Pointer;
begin
  try
    Result := VarArrayCreate([0, Stream.Size - 1], varByte);
    p := Result; //VarArrayLock(Result);
    try
      Stream.Position := 0;
      Stream.Read(p, Stream.Size);
    finally
      //VarArrayUnlock(Result);
    end;
  except
  end;
end;
{$else}
var
  p: Pointer;
begin
  try
    Result := VarArrayCreate([0, Stream.Size - 1], varByte);
    p := VarArrayLock(Result);
    try
      Stream.Position := 0;
      Stream.Read(p^, Stream.Size);
    finally
      VarArrayUnlock(Result);
    end;
  except
  end;
end;
{$endif}

{procedure TForm1.Button1Click(Sender: TObject);
var
  FSnapshotHandle:THandle;
  FProcessEntry32:TProcessEntry32;
  Ret : BOOL;
  ProcessID : integer;
  ProcessHndle : THandle;
  lpBuffer:pByte;
  nSize: DWORD;
  lpNumberOfBytesRead: DWORD;
  i:integer;
  s:string;
begin
  FSnapshotHandle:=CreateToolhelp32Snapshot(
TH32CS_SNAPPROCESS,0);
    //创建系统快照
  FProcessEntry32.dwSize:=Sizeof(FProcessEntry32);
    //先初始化 FProcessEntry32 的大小
  Ret:=Process32First(FSnapshotHandle,FProcessEntry32);
  while Ret do
  begin
    s:=ExtractFileName(FProcessEntry32.szExeFile);
    if s='KERNEL32.DLL' then
    begin
      ProcessID:=FProcessEntry32.th32ProcessID;
      s:='';
      break;
    end;
    Ret:=Process32Next(FSnapshotHandle,FProcessEntry32);
  end;
   //循环枚举出系统开启的所有进程，找出“Kernel32.dll”
  CloseHandle(FSnapshotHandle);
  Memo1.Lines.Clear ;
  memo1.lines.add('Process ID '+IntToHex(
  FProcessEntry32.th32ProcessID,8));
  memo1.lines.Add('File name '+FProcessEntry32.szExeFile);
    ////输出进程的一些信息 
  nSize:=4;
  lpBuffer:=AllocMem(nSize);
  ProcessHndle:=OpenProcess(PROCESS_VM_READ,false,ProcessID);
  memo1.Lines.Add ('Process Handle '+intTohex(ProcessHndle,8));
  for i:=$00800001 to $0080005f do
  begin
    ReadProcessMemory(
                     ProcessHndle,
                     Pointer(i),
                     lpBuffer,
                     nSize,
                     lpNumberOfBytesRead
                     );
    s:=s+intTohex(lpBuffer^,2)+' ';
      //读取内容
    if (i mod 16) =0 then
    begin
      Memo1.Lines.Add(s);
      s:='';
    end;
      //格式化输出
  end;
  FreeMem(lpBuffer,nSize);
  CloseHandle(ProcessHndle);
   //关闭句柄，释放内存
end; }

class function PubSys.FindProcInProcess(ProcName: string): boolean;
{$ifdef MSWINDOWS}
{$ifdef dotnet}
begin
end;
{$else}
var
  ExeFile: string;
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  //FProcessEntry32: TProcessEntry32;
begin
  Result := false;
  {if trim(ProcName) = '' then exit;
  ProcName := UpperCase(ProcName);
  ProcName := ExtractFileName(ProcName);
  if Pos('.EXE', ProcName) < 1 then ProcName := ProcName + '.EXE';
  try
    FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    try
      FProcessEntry32.dwSize := Sizeof(FProcessEntry32);
      ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
      while integer(ContinueLoop) <> 0 do
      begin
        ExeFile := FProcessEntry32.szExeFile;
        if Pos(UpperCase(ExtractFileName(ExeFile)), ProcName) = 1 then
        begin
          Result := true;
          break;
        end;
        ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
      end;
    finally
      if FSnapshotHandle > 0 then //2007-11-03
        CloseHandle(FSnapshotHandle);
    end;
  except
  end;}
end;
{$endif}
{$ELSE}
begin

end;
{$endif}


class procedure PubSys.KillProcFromProcess(ProcName: string);
{$ifdef MSWINDOWS}
{$ifdef dotnet}
begin
end;

{$else}
(*
var
  ExeFile: string;
  ContinueLoop: BOOL;
  FSnapshotHandle, hProcess{, hCurrentWindow, Processid}: THandle;
  //FProcessEntry32: TProcessEntry32;
  Flag: boolean;
  lp: integer;

  function SetPrivilege(privilegeName: string; enable: boolean): boolean;
  var tpPrev,
      tp         : TTokenPrivileges;
      token      : THandle;
      dwRetLen   : DWord;
  begin
    Result := False;
    OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, token);
    try
      tp.PrivilegeCount := 1;
      if LookupPrivilegeValue(nil, pchar(privilegeName), tp.Privileges[0].LUID) then
      begin
        if enable then
          tp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED
        else
          tp.Privileges[0].Attributes := 0;
        dwRetLen := 0;
        result := AdjustTokenPrivileges(token, False, tp, SizeOf(tpPrev), tpPrev, dwRetLen);
      end;
    finally
      CloseHandle(token);
    end;
  end;
  {hCurrentWindow := GetWindow(Handle, GW_HWNDFIRST);
  while hCurrentWindow <> 0 do
  begin
    GetWindowThreadProcessId(hCurrentWindow, Processid);
    if processid = lppe.th32ProcessID then
    begin
      做你想做的事就行了
    end;
    hCurrentWindow := GetWindow(hCurrentWindow, GW_HWNDNEXT);
  end;}

  {/////////////////////////////////////////////////////
  function CheckProcessWindow(Handle: HWND; Info: Pointer): BOOL; stdcall;
  var
    ProcessID:DWORD;
  begin
    GetWindowThreadProcessId(Handle,ProcessID);
    Result := ProcessID=PProcessWindowInfo(Info)^.ProcessID;
    if Result then
      PProcessWindowInfo(Info)^.Handle:=Handle;
  end;

  function FindProcessWindow(ProcessID:DWORD):THandle;
  //查找进程当前窗口，若成功，返回窗口Handle，否则返回0
  var
    Info:TProcessWindowInfo;
  begin
    Info.ProcessID:=ProcessID;
    Info.Handle:=0;
    EnumWindows(@CheckProcessWindow, Longint(@Info));
    Result:=Info.Handle;
  end;} *)
begin
  (*
  if trim(ProcName) = '' then exit;
  ProcName := UpperCase(ProcName);
  ProcName := ExtractFileName(ProcName);
  if Pos('.EXE', ProcName) < 1 then ProcName := ProcName + '.EXE';
  try
    for lp := 1 to 50 do
    begin
      Flag := false;
      FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
      try
        FProcessEntry32.dwSize := Sizeof(FProcessEntry32);
        ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
        while integer(ContinueLoop) <> 0 do
        begin
          ExeFile := FProcessEntry32.szExeFile;
          if Pos(UpperCase(ExtractFileName(ExeFile)), ProcName) = 1 then
          begin
            SetPrivilege('SeDebugPrivilege', true); //2008-09-13 add
            hProcess := OpenProcess(PROCESS_ALL_ACCESS{ or PROCESS_TERMINATE}, false, FProcessEntry32.th32ProcessID);

            ///////////////////  add
            //Application.MessageBox(Pchar(IntToStr(hProcess) + ' iii ' +  IntToStr(FindProcessWindow(hProcess))), '', 1);
            //////////////////////////////////////////////  end

            SetPrivilege('SeDebugPrivilege', false);
            TerminateProcess(hProcess, 0);
            Flag := true;
            {hCurrentWindow := GetWindow(Handle, GW_HWNDFIRST);
            while hCurrentWindow <> 0 do
            begin
              GetWindowThreadProcessId(hCurrentWindow, Processid);
              if processid = FProcessEntry32.th32ProcessID then
              begin
                ShowMessage('find !' );
              end;
              hCurrentWindow := GetWindow(hCurrentWindow, GW_HWNDNEXT);
            end;
            hCurrentWindow := GetWindow(Handle, GW_HWNDFIRST);
            while hCurrentWindow <> 0 do
            begin
              GetWindowThreadProcessId(hCurrentWindow, Processid);
              if processid = FProcessEntry32.th32ProcessID then
              begin
                ShowMessage('find e !' );
              end;
              hCurrentWindow := GetWindow(hCurrentWindow, GW_HWNDPREV);
            end;}

          end;
          ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
        end;
      finally
        if FSnapshotHandle > 0 then //2007-11-03 add
          CloseHandle(FSnapshotHandle);
      end;
      if not Flag then break;
      Sleep(500); //2023-02-10  add
    end;
  except
  end; *)
end;
{$endif}
{$else}
begin

end;
{$endif}
class procedure PubSys.InitSysVar;
begin
  {ShortDateFormat := 'YYYY-MM-DD';
  ShortTimeFormat := 'HH:MM:SS';
  LongDateFormat := 'YYYY-MM-DD';
  LongTimeFormat := 'HH:MM:SS';
  TimeSeparator := ':';
  dateSeparator := '-';}
end;

class function PubSys.NNull(Value: string): string;
begin
  if trim(Value) = '' then // or (trim(Value) = '0')
    Result := 'NULL'
  else
    Result := Value;
end;

class function PubSys.FilterItem(Str1, Str2: string): string;
var
  SL, SlTmp: TStringlist;
  lp: integer;
begin
  SL := TStringlist.Create;
  SlTmp := TStringlist.Create;
  try
    SlTmp.Text := StringReplace(Str1, ',', #13#10, [rfReplaceAll, rfIgnoreCase]);
    SL.Text := StringReplace(Str2, ',', #13#10, [rfReplaceAll, rfIgnoreCase]);
    for lp := 0 to SL.Count - 1 do
    begin
      if SlTmp.IndexOf(SL[lp]) < 0 then
        SlTmp.Add(SL[lp]);
    end;
    Result := '';
    for lp := 0 to SlTmp.Count - 1 do
    begin
      if trim(SlTmp[lp]) <> '' then
      begin
        if trim(Result) = '' then
          Result := SlTmp[lp]
        else
          Result := Result + ',' + SlTmp[lp];
        if lp + 1 mod 6 = 0 then Result := Result + #13#10;
      end;
    end;
  finally
    SL.Free;
    SlTmp.Free;
  end;
end;

class function PubSys.GetTimeStamp(DateTime: TDateTime): string;
begin
  Result := FormatDateTime('YYYY"-"MM"-"DD HH":"NN":"SS"."ZZZ', DateTime);
end;

class function PubSys.NSpace(Value: string): string;
begin
  if trim(Value) = '0' then
    Result := ''
  else
    Result := Value;
end;

class function PubSys.NZero(Value, RepValue: string): string;
begin
  if trim(Value) = '' then
    Result := RepValue
  else
    Result := Value;
end;

class procedure PubSys.Set_Decimals(DefaultDecimals: integer);
begin
  {$ifdef dotnet}
  FMTBcd._DefaultDecimals := DefaultDecimals;
  {$else}
  {$ifndef xe10}
  {$ifndef xe10z}
  //FMTBcd._DefaultDecimals := DefaultDecimals;
  {$endif}
  {$endif}
  {$endif}
end;

class procedure PubSys.TruncCL(var OutID, OutCode: string);
var
  SLID, SLCode, SLTmp: TStringlist;
  lp, i: integer;
  TmpStr: string;
begin
  SLID := TStringList.Create;
  SLCode := TStringlist.Create;
  SLTmp := TStringlist.Create;
  try
    SLID.CommaText := OutID;
    //SLCode.CommaText := OutCode;
    for lp := 0 to SLID.Count - 1 do
      SLTmp.AddObject(SLID[lp], TObject(lp));
    //排序
    SLTmp.Sorted := true;
    //倒序
    SLID.Clear;
    for lp := SLTmp.Count - 1 downto 0 do
      SLID.AddObject(SLTmp[lp], SLTmp.Objects[lp]);
    ///////////////////////////////////////////////////////////////
    SLTmp.Sorted := false;
    OutCode := StringReplace(OutCode, #10, '', [rfReplaceAll, rfIgnoreCase]);
    OutCode := StringReplace(OutCode, #13, '', [rfReplaceAll, rfIgnoreCase]);
    SLTmp.Text := StringReplace(OutCode, ',', #13#10, [rfReplaceAll, rfIgnoreCase]);
    for lp := 0 to SLID.Count - 1 do
      SLCode.Add(SLTmp[Longint(SLID.Objects[lp])]);
    ///////////////////////////////////////////////////////////////
    //去掉不是底层的
    for lp := SLID.Count - 1 downto 0 do
    begin
      TmpStr := SLID[lp];
      for i := lp - 1 downto 0 do
      begin
        //if Pos(TmpStr, SLID[i]) = 1 then
        if (Pos(TmpStr, SLID[i]) = 1) or (Length(TmpStr) < 3) then
        begin
          //Index := Longint(SLID.Objects[lp]);
          SLID.Delete(lp);
          SLCode.Delete(lp);
          //SLCode.Delete(Index);
          break;
        end;
      end;
    end;
    if (SLID.Count > 0) and (length(SLID[0]) < 3) then
    begin
      SLID.Delete(0);
      SLCode.Delete(0);
    end;
    OutID := SLID.CommaText;
    OutCode := SLCode.CommaText;
  finally
    SLTmp.Free;
    SLCode.Free;
    SLID.Free;
  end;
end;

class procedure PubSys.VarClear(var Data: OleVariant);
begin //2006-12-22 new
  try
    Data := UnAssigned;
  except
    on e: exception do
      raise Exception.Create('DataSetToOleErr:  two ' + e.Message);
  end;
end;

class procedure PubSys.VarClearEx(var Data: OleVariant);
begin //2006-12-22 new
  try
    Data := UnAssigned;
  except
    on e: exception do
      raise Exception.Create('DataSetToOleErr:  three ' + e.Message);
  end;
end;

{class procedure PubSys.VarSetValue(var OutData: Variant;
  const InData: Variant);
begin
  try
    OutData := UnAssigned;
  except
    on e: exception do
      raise Exception.Create('DataSetToOleErr:  four ' + e.Message);
  end;
  try
    OutData := InData;
  except
    on e: exception do
      raise Exception.Create('DataSetToOleErr:  five ' + e.Message);
  end;
end;}

class function PubSys.GetMonthFirstDay(Dt: string): string;
var
  Year, Month, Day: Word;
begin
  DecodeDate(StrToDate(Dt), Year, Month, Day);
  Result := FormatDateTime('YYYY-MM-DD', EncodeDate(Year, Month, 1));
end;


class function PubSys.GeteYoueBuildVerCode: string;
begin
  Result := eYoueBuildVerCode;
end;

class function PubSys.GetClientUniqueCode: string;
var
  Param1: string;
  Param2: integer;
begin
  FClientUniqueCode := FClientUniqueCode + 1;
  if FClientUniqueCode > 999 then
    FClientUniqueCode := 1;
  Param1 := PubString.FillChar(IntToStr(FClientUniqueCode), '0', 3);
  Sleep(10);
  Randomize;
  Param2 := RandomRange(10, 99);
  Result := FormatDateTime('YYMMDDHHNNSSZZZ', Now) + IntToStr(Param2) + Param1;
end;
      {
class function PubSys.ColorToHtml(mColor: TColor): string;
begin
  mColor := ColorToRGB(mColor);
  Result := Format('#%.2x%.2x%.2x',
    [GetRValue(mColor), GetGValue(mColor), GetBValue(mColor)]);
end;

class function PubSys.HtmlToTColor(sColor: string): TColor;
begin
  if Pos('#', sColor) > 0 then
    sColor := PubString.GetDeliBack(sColor, '#');
  Result :=
  RGB(
    StrToInt(#36 + Copy(sColor,1,2)),
    StrToInt(#36 + Copy(sColor,3,2)),
    StrToInt(#36 + Copy(sColor,5,2)))
end; }


class function PubSys.StreamToBase64(Stream: TMemoryStream): string;
begin
  Result := '';

  Stream.Position := 0;
  //Result := EncodeBase64(Stream.Memory, Stream.Size);
  //base64默认有一个77字符后换行一次，用TCP发送时不方便，就去掉了回车换行。
  Result := StringReplace(Result, #13, '', [rfReplaceAll]);
  Result := StringReplace(Result, #10, '', [rfReplaceAll]);
end;

class function PubSys.FileToBase64(FileName: string): string;
var
  MemoryStream: TMemoryStream;
begin
  Result := '';
  MemoryStream := TMemoryStream.Create;
  try
    MemoryStream.LoadFromFile(FileName);

    Result := StreamToBase64(MemoryStream);
  finally
    MemoryStream.Free;
  end;
end;

class procedure PubSys.WinRar_UnZip(FromFile, TOPath: string; NeedPwd: string; Show: boolean);
{$ifdef MSWINDOWS}
var
   SHExecInfo:   SHELLEXECUTEINFO;
begin   //【码农】[上海](364114175)  15:20:17
  //注意：用rar.exe 只需要这一个文件，放在你自己的程序目录就可以了, 不依赖其他  对了，那个rarkey要的哈，
  //发行需要带 UnRAR.exe，Rar.exe，WinRAR.exe

  SHExecInfo.cbSize   :=   sizeof(SHELLEXECUTEINFO);
  SHExecInfo.fMask   :=   SEE_MASK_NOCLOSEPROCESS;
  SHExecInfo.Wnd   :=   0;//Handle;
  SHExecInfo.lpVerb   :=   nil;
  //SHExecInfo.lpFile   :=  'C:\Program Files\WinRAR\WinRAR.exe ';

  SHExecInfo.lpFile  := PChar(ExtractFilePath(ParamStr(0)) + 'WinRAR.exe');
  //SHExecInfo.lpParameters   :=   'a   e:\qwqw.rar   e:\qwqw ';
  if NeedPwd <> '' then
    SHExecInfo.lpParameters   :=  PChar(' -' + NeedPwd + ' x -o+ ' + FromFile + ' -ep1 ' + TOPath + ' ')
  else                            // ShellExecute(Handle,’open’,’WinRar’,’e -r -y E:\MyCode\C1\升级程序\升级程序.rar f:\’,nil,SW_HIDE)
    SHExecInfo.lpParameters   :=  PChar(' x -o+ ' + FromFile + ' -ep1 ' + TOPath + ' ');
  SHExecInfo.lpDirectory   :=   nil;
  SHExecInfo.nShow   :=  Longint(Show);//0;//SW_SHOW;
  SHExecInfo.hInstApp   :=   0;//Handle;
  //ShellExecuteEx(@SHExecInfo);
  {//ShowMessage('ddd');
  Application.ProcessMessages;
  Application.ProcessMessages;
  Sleep(100);
  Application.ProcessMessages;
  Sleep(100);
  Application.ProcessMessages;
  Sleep(100);
  Application.ProcessMessages;
  Sleep(100);
  Application.ProcessMessages;
  Sleep(100);
  Application.ProcessMessages;
  Sleep(100);
  Application.ProcessMessages;  }

  WaitForSingleObject(SHExecInfo.hProcess,   INFINITE);
  closeHandle(SHExecInfo.hProcess);
  //ShellExecute(application.MainForm.Handle, 'open ', 'winrar.exe ',PChar( 'a   e:\zqzq.rar   e:\zqzq '), ' ',SW_show);
  //ShowMessage( '压缩完毕！ ');
{$else}
begin
{$endif}
end;

class procedure PubSys.WinRar_Zip(FromDir, TOFile: string; NeedPwd: string; Show: boolean);
{$ifdef MSWINDOWS}
var
   SHExecInfo:   SHELLEXECUTEINFO;
begin   //【码农】[上海](364114175)  15:20:17
  //注意：用rar.exe 只需要这一个文件，放在你自己的程序目录就可以了, 不依赖其他  对了，那个rarkey要的哈，
  //发行需要带 UnRAR.exe，Rar.exe，WinRAR.exe

  SHExecInfo.cbSize   :=   sizeof(SHELLEXECUTEINFO);
  SHExecInfo.fMask   :=   SEE_MASK_NOCLOSEPROCESS;
  SHExecInfo.Wnd   :=   0;//Handle;
  SHExecInfo.lpVerb   :=   nil;
  SHExecInfo.lpFile   :=  PChar(ExtractFilePath(ParamStr(0)) + 'WinRAR.exe');
  //SHExecInfo.lpParameters   :=   'a   e:\qwqw.rar   e:\qwqw ';
  if trim(NeedPwd) <> '' then
    SHExecInfo.lpParameters   :=  PChar(' -' + NeedPwd + ' a ' + TOFile + ' -ep1 ' + FromDir + ' ')
  else                            // ShellExecute(Handle,’open’,’WinRar’,’e -r -y E:\MyCode\C1\升级程序\升级程序.rar f:\’,nil,SW_HIDE)
    SHExecInfo.lpParameters   :=  PChar(' a ' + TOFile + ' -ep1 ' + FromDir + ' ');
  SHExecInfo.lpDirectory   :=   nil;
  SHExecInfo.nShow   :=  Longint(Show);// 0;
  SHExecInfo.hInstApp   :=   0;//Handle;
  //ShellExecuteEx(@SHExecInfo);
  //ShowMessage('ddd');
  {Application.ProcessMessages;
  Application.ProcessMessages;
  Sleep(100);
  Application.ProcessMessages;
  Sleep(100);
  Application.ProcessMessages;
  Sleep(100);
  Application.ProcessMessages;
  Sleep(100);
  Application.ProcessMessages;
  Sleep(100);
  Application.ProcessMessages;
  Sleep(100);
  Application.ProcessMessages; }

  WaitForSingleObject(SHExecInfo.hProcess,   INFINITE);
  closeHandle(SHExecInfo.hProcess);
  //ShellExecute(application.MainForm.Handle, 'open ', 'winrar.exe ',PChar( 'a   e:\zqzq.rar   e:\zqzq '), ' ',SW_show);
  //ShowMessage( '压缩完毕！ ');
{$else}
begin
{$endif}
end;

class function PubSys.Base64Decode(Text: string): String;
begin
  //Result := DecodeString(Text);
end;

class function PubSys.Base64Encode(Text: string;NoReturn: boolean): String;
begin
  //Result := EncodeString(Text);
  if NoReturn then
  begin
    Result := StringReplace(Result, #13, '',  [rfReplaceAll]);
    Result := StringReplace(Result, #10, '',  [rfReplaceAll]);
  end;
end;

class procedure PubSys.Base64ToFile(AStr, FileName: string);
var
  MemoryStream: TMemoryStream;
  AftBase: TBytes;
begin
  MemoryStream := TMemoryStream.Create;
  try
    //AftBase := DecodeBase64(AStr);
    MemoryStream.Write(AftBase, Length(AftBase));
    MemoryStream.Position := 0;
    MemoryStream.SaveToFile(FileName);
  finally
    MemoryStream.Free;
  end;
end;


class procedure PubSys.Base64ToStream(Base64Str: string; MemoryStream: TStream);
var
  AftBase: TBytes;
begin
  MemoryStream.Size := 0;
  //AftBase := DecodeBase64(Base64Str);
  MemoryStream.Write(AftBase, Length(AftBase));
  MemoryStream.Position := 0;
end;

class function PubSys.StreamToMD5(S: TStream; NeedUpperCase: boolean): String;
begin
end;

class function PubSys.GetMd5(Value: string; NeedUpperCase: boolean = false): string;
begin
end;

initialization
  Randomize;
  FClientUniqueCode := RandomRange(0, 500); //其他程序(地方)不要调用, 只适合该单元


end.
