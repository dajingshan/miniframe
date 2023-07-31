unit Snowflake;

interface

uses
  SysUtils, SyncObjs, DateUtils;

type
  TSnowflake = class
  private
    FOrgID: Integer;      //������
    FMachineID: integer;   //������
    FLocker: TCriticalSection;
    fTime: Int64;      //ʱ���
    fsn: int64;        //����
  public
    constructor Create;
    destructor Destroy; override;
    property MachineID: Integer read FMachineID write FMachineID;
    property OrgID: Integer read FOrgID write FOrgID;
    function Generate: Int64;
  end;

implementation

const
  Epoch: int64 = 1539615188000; //����ʱ��2018-10-15�� curtime := DateTimeToUnix(Now) * 1000;
  OrgBits: Byte = 5;            //������   0..31
  MachineBits: Byte = 5;       //������    0..31
  snBits: Byte = 12;          //���к�12λ
  timeShift: Byte = 22;     //ʱ�������λ��=���к�λ��+������λ��+������λ��
  orgShift: Byte = 17;      //����������λ��=���к�λ��+������λ��
  machineShift: Byte = 12;   //����վ����λ��=���к�λ��
  snMask: Word = 4095;       //12λ�ļ������к�֧��ÿ���ڵ�ÿ�������4096��ID���

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
    FMachineID: integer;   //������
    FLocker: TCriticalSection;
    fTime: Int64;      //ʱ���
    fsn: int64;        //����
  public
    constructor Create;
    destructor Destroy; override;
    property MachineID: Integer read FMachineID write FMachineID;
    function Generate: Int64;
  end;

implementation

const
  Epoch: int64 = 1539615188000; //����ʱ��2018-10-15��
  MachineBits: Byte = 10;       //������10λ  0..1023
  snBits: Byte = 12;          //���к�12λ
  timeShift: Byte = 22;     //ʱ�������λ��=���к�12λ+������10λ
  machineShift: Byte = 12;   //����վ����λ��
  snMask: Word = 4095;       //12λ�ļ������к�֧��ÿ���ڵ�ÿ�������4096��ID���

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
{ ������ʾ
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
