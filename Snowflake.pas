unit Snowflake;

interface

uses
  SysUtils, SyncObjs, DateUtils;

type
  TSnowflake = class
  private
    FOrgID: Integer;      //机构号
    FMachineID: integer;   //机器号
    FLocker: TCriticalSection;
    fTime: Int64;      //时间戳
    fsn: int64;        //序列
  public
    constructor Create;
    destructor Destroy; override;
    property MachineID: Integer read FMachineID write FMachineID;
    property OrgID: Integer read FOrgID write FOrgID;
    function Generate: Int64;
  end;

implementation

const
  Epoch: int64 = 1539615188000; //北京时间2018-10-15号 curtime := DateTimeToUnix(Now) * 1000;
  OrgBits: Byte = 5;            //机构号   0..31
  MachineBits: Byte = 5;       //机器号    0..31
  snBits: Byte = 12;          //序列号12位
  timeShift: Byte = 22;     //时间戳左移位数=序列号位数+机器号位数+机构号位数
  orgShift: Byte = 17;      //机构号左移位数=序列号位数+机器号位数
  machineShift: Byte = 12;   //工作站左移位数=序列号位数
  snMask: Word = 4095;       //12位的计数序列号支持每个节点每毫秒产生4096个ID序号

{ TSnowflake }

constructor TSnowflake.Create;
begin
  FLocker := TCriticalSection.Create;
end;

destructor TSnowflake.Destroy;
begin
  FLocker.Free;
  inherited;
end;

function TSnowflake.Generate: Int64;
var
  curtime: Int64;
begin
  FLocker.Acquire;
  try
    curtime := DateTimeToUnix(Now) * 1000;
    if curtime = fTime then
    begin
      fsn := (fsn + 1) and snMask;
      if fsn = 0 then
      begin
        while curtime <= fTime do
          curtime := DateTimeToUnix(Now) * 1000;
      end;
    end
    else
      fsn := 0;
    fTime := curtime;
    Result := (curtime - Epoch) shl timeShift
      or FOrgID shl orgShift
      or FMachineID shl machineShift
      or fsn;
  finally
    FLocker.Release;
  end;
end;

initialization

end.



interface

uses
  SysUtils, SyncObjs, DateUtils;

type
  TSnowflake = class
  private
    FMachineID: integer;   //机器号
    FLocker: TCriticalSection;
    fTime: Int64;      //时间戳
    fsn: int64;        //序列
  public
    constructor Create;
    destructor Destroy; override;
    property MachineID: Integer read FMachineID write FMachineID;
    function Generate: Int64;
  end;

implementation

const
  Epoch: int64 = 1539615188000; //北京时间2018-10-15号
  MachineBits: Byte = 10;       //机器号10位  0..1023
  snBits: Byte = 12;          //序列号12位
  timeShift: Byte = 22;     //时间戳左移位数=序列号12位+机器号10位
  machineShift: Byte = 12;   //工作站左移位数
  snMask: Word = 4095;       //12位的计数序列号支持每个节点每毫秒产生4096个ID序号

{ TSnowflake }

constructor TSnowflake.Create;
begin
  FLocker := TCriticalSection.Create;
end;

destructor TSnowflake.Destroy;
begin
  FLocker.Free;
  inherited;
end;

function TSnowflake.Generate: Int64;
var
  curtime: Int64;
begin
  FLocker.Acquire;
  try
    curtime := DateTimeToUnix(Now) * 1000;
    if curtime = fTime then
    begin
      fsn := (fsn + 1) and snMask;
      if fsn = 0 then
      begin
        while curtime <= fTime do
          curtime := DateTimeToUnix(Now) * 1000;
      end;
    end
    else
      fsn := 0;
    fTime := curtime;
    Result := (curtime - Epoch) shl timeShift or FMachineID shl machineShift or fsn;
  finally
    FLocker.Release;
  end;
end;

initialization

end.

unit Snowflake;
{ 调用演示
procedure TForm1.Button1Click(Sender: TObject);
var s: TSnowflake;
i: Integer;
begin
  s := TSnowflake.Create;
  s.OrgID := 8;
  s.MachineID :=10;
  for i:=1 to 30 do
  begin
    Memo1.Lines.Add(IntToStr(s.Generate));
  end;
  s.Free;
end;
}
