unit PubMathUnit;

interface

uses SysUtils, Classes, FMTBcd{, FMTBcdEx};

const
  ChangeDecimals = 28;

type
  PubMath = class
  private
    class function _IsValidValueEx(Value: string; DigCount: integer): string; //DigCount为保留的小数位数
  public
    //两数相加Add
    class function Ad(const Value1, Value2: string): string; overload;
    class function Ad(const Bcd1, Bcd2: TBcd): TBcd; overload;
    //两数相减 Subtract
    class function Su(Value1, Value2: string): string; overload;
    class function Su(const Bcd1, Bcd2: TBcd): TBcd; overload;
    //两数相乘 Multiply
    class function Mu(const Value1, Value2: string): string; overload;
    class function Mu(const Bcd1, Bcd2: TBcd): TBcd; overload;
    //两数相除 Divide
    class function Di(const Value1, Value2: string): string; overload;
    class function Di(const Bcd1, Bcd2: TBcd): TBcd; overload;
    //取绝对值
    class function Abs(Value: string): string; overload;
    class function Abs(Bcd: TBcd): TBcd; overload;
    //保留小数位
    class function Decimal(Value: string; DigCount: integer = 2): string; overload;
    class function Decimal(Value: string; DigCount: string = ''): string; overload;
    //保留小数位，为整数或不足小数位自动补0  2014-07-30 add
    class function DecimalEx(Value: string; DigCount: integer = 2): string;
    //截断取整, 不舍入
    class function Trunc(Value: string): string; overload;
    class function Trunc(Bcd: TBcd): TBcd; overload;
    //四舍五入取整
    class function Round(Bcd: TBcd): TBcd; overload;
    class function Round(Value: string): string; overload;
    //取整, 只要有小数，则整数加1
    class function TruncEx(Value: string): string; overload;
    //取余数, 模
    class function ModBcd(Bcd1, Bcd2: TBcd): TBcd; overload;
    class function ModBcd(Value1, Value2: string): string; overload;

    //取整数位数
    class function Precision(const Value: string): integer; overload;
    class function Precision(const Bcd: TBcd): integer; overload;
    //取小数位数
    class function DecimalDig(const Value: string): integer; overload;
    class function DecimalDig(const Bcd: TBcd): integer; overload;

    class function BToStr(Bcd: TBcd): string;
    //字符串到TBcd的转换
    class function TryStrToBcd(Value: string): TBcd; overload;
    class function TryStrToBcd(Value: string; var Bcd: TBcd): boolean; overload;

    //两数大小比较, 返回值为 -1	Value1< Value2; 0	Value1= Value2; 1	Value1 > Value2
    //class function Compare(const Bcd1, Bcd2: TBcd): integer; overload;
    //class function Compare(const Value1, Value2: string): integer; overload;
    //Value1 < Value2 返回true
    class function IsLess(const Value1, Value2: string): boolean; overload;
    class function IsLess(const Bcd1, Bcd2: TBcd): boolean; overload;
    //Value1 <= Value2 返回true
    class function IsLessEqual(const Value1, Value2: string): boolean; overload;
    //Value1 > Value2 返回true
    class function IsGreater(const Value1, Value2: string): boolean; overload;
    class function IsGreater(const Bcd1, Bcd2: TBcd): boolean; overload;
    //Value1 >= Value2 返回true
    class function IsGreaterEqual(const Value1, Value2: string): boolean; overload;
    //判断一个数是否小于等于零
    class function IsNegOrZero(const Value: string): boolean; overload;
    class function IsNegOrZero(const Bcd: TBcd): boolean; overload;
    //判断一个数是否大于等于零                                               大于
    class function IsPosOrZero(const Value: string): boolean; overload;
    class function IsPosOrZero(const Bcd: TBcd): boolean; overload;
    //判断两个数是否相等
    class function IsEqual(Value1, Value2: string): boolean; overload;
    class function IsEqual(const Bcd1, Bcd2: TBcd): boolean; overload;
    //判断是否是负数，小于零返回true
    class function IsNegative(const Bcd: TBcd): boolean; overload;
    class function IsNegative(const Value: string): boolean; overload;
    //判断是否是正数，大于零返回true
    class function IsPositive(const Bcd: TBcd): boolean; overload;
    class function IsPositive(const Value: string): boolean; overload;

    //判断一个数值是否为空，可能为0或''
    class function IsValNull(Bcd: TBcd): boolean; overload;
    class function IsValNull(Value: string): boolean; overload;
    //判断一个数值是否不为空，可能为0或''
    class function IsValNNull(Bcd: TBcd): boolean; overload;
    class function IsValNNull(Value: string): boolean; overload;
    //判断一个数据是否是合法的数值型, 注意为空认为是合法的
    //主要适用最大精度是28位，最大整型是12位，最大小数位是16位，否则不要调用该方法
    //      注意： 判断存在的问题，整数小于12，小数位大于16位时出认为是不合法的，
    //所以在赋值时都要调用IsValidValueEx直接完成判断并截断小数位为16位
    class function IsValidValue(Bcd: TBcd): boolean; overload;
    class function IsValidValue(Value: string): boolean; overload;
    //判断数值型是否合法，主要用在DBgridEh中判断列是否是合法的数值型用, 不合法返空，否则返原数
    class function IsValidValueEx(Value: string): string;

    //日期
    //判断一个字符串是否是合法的日期
    class function IsValidDate(Value: string): boolean;
    //判断一个字符串是否是合法的日期时间型
    class function IsValidDateTime(Value: string): boolean;
    //判断一个字符串是否是合法的时间型
    class function IsValidTime(Value: string): boolean;
    //判断合法的日期时间，同时返回正确的日期时间
    class function IsValidValueDate(Value: string): string;
    class function IsValidValueTime(Value: string): string;
    //格式化串
    class function BcdToStrF(const Bcd: TBcd; Format: TFloatFormat;
      const Precision1, Digits: Integer): string;
    class function FormatBcd(const Format: string; Bcd: TBcd): string;
    class function FormatBcdEx(const Value: string): string;
    //设置运算结果小数位，适用中间运算时, 注意，使用完要还原如
    //Set_DefaultDecimals(ChangeDecimals); 
    //try
    //finally
    //  Set_DefaultDecimals
    //end;
    class procedure Set_DefaultDecimals(DefaultDecimals: integer = 16);
    class function ChangeFloat(Text: string): string;

    class function Format(const FormatStr: string; Value: string): string; overload; //2013-10-12 add
  end;

implementation

uses PubStringUnit;

{ PubMath }

class function PubMath.Di(const Bcd1, Bcd2: TBcd): TBcd;
begin
  BcdDivide(Bcd1, Bcd2, Result);
end;

class function PubMath.Di(const Value1, Value2: string): string;
var
  Bcd1, Bcd2, Bcd3: TBcd;
begin
  TryStrToBcd(Value1, Bcd1);
  TryStrToBcd(Value2, Bcd2);
  BcdDivide(Bcd1, Bcd2, Bcd3);
  //Bcd3 := Di(Bcd1, Bcd2);
  Result := BcdToStr(Bcd3);
end;

class function PubMath.Abs(Bcd: TBcd): TBcd;
begin
  if IsBcdNegative(Bcd) then
    Result := StrToBcd(Abs(BcdToStr(Bcd)))
  else
    Result := Bcd;
end;

class function PubMath.Abs(Value: string): string;
begin
  if IsNegative(Value) then
    Result := Copy(Trim(Value), 2, MaxInt)
  else
    Result := Value;
end;


function Ad(const Value1, Value2: string): string;
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

function AdEx(const Bcd1, Bcd2: TBcd): TBcd;
begin
  {$ifdef dotnet}
  FMTBcd.BcdAdd(Bcd1, Bcd2, Result);
  {$else}
  FMTBcd.BcdAdd(Bcd1, Bcd2, Result);
  {$endif}
end;

class function PubMath.Ad(const Bcd1, Bcd2: TBcd): TBcd;
begin
  Result := StrToBcd(Ad(BcdToStr(Bcd1), BcdToStr(Bcd2)));
  //Result := PubSys.AdEx(Bcd1, Bcd2);
end;

class function PubMath.Ad(const Value1, Value2: string): string;
begin
  Result := Ad(Value1, Value2);
end;

{class function PubMath.Ad(const Value1, Value2: TBcd): TBcd;
begin
  Result := PubSys.Ad(Value1, Value2);
end;}


{var
  Bcd1, Bcd2, Bcd3: TBcd;
begin
  TryStrToBcd(Value1, Bcd1);
  TryStrToBcd(Value2, Bcd2);
  BcdAdd(Bcd1, Bcd2, Bcd3);
  Result := PubSys.Ad(Value1, Value2);
  Result := BcdToStr(Bcd3);
end;}

class function PubMath.Mu(const Bcd1, Bcd2: TBcd): TBcd;
begin
  BcdMultiply(Bcd1, Bcd2, Result);
end;

class function PubMath.Mu(const Value1, Value2: string): string;
var
  Bcd1, Bcd2, Bcd3: TBcd;
begin
  TryStrToBcd(Value1, Bcd1);
  TryStrToBcd(Value2, Bcd2);
  BcdMultiply(Bcd1, Bcd2, Bcd3);
  Result := BcdToStr(Bcd3);
end;

class function PubMath.Su(const Bcd1, Bcd2: TBcd): TBcd;
begin
  //BcdSubtract(Bcd1, Bcd2, Result);
  if (Bcd1.Precision = 0) or (Bcd1.Precision > MaxFMTBcdFractionSize) or
     (Bcd2.Precision = 0) or (Bcd2.Precision > MaxFMTBcdFractionSize) then
    Result := StrToBcd('0')
  else
    Result := StrToBcd(Su(BcdToStr(Bcd1), BcdToStr(Bcd2)));
end;

class function PubMath.Su(Value1, Value2: string): string;
//var
//  Bcd1, Bcd2, Bcd3: TBcd;
begin
  {TryStrToBcd(Value1, Bcd1);
  TryStrToBcd(Value2, Bcd2);
  BcdSubtract(Bcd1, Bcd2, Bcd3);
  Result := BcdToStr(Bcd3);}
  if IsNegative(Value2) then
    Value2 := Abs(Value2)
  else
    Value2 := '-' + Value2;
  Result := Ad(Value1, Value2);
end;

class function PubMath.BToStr(Bcd: TBcd): string;
begin
  Result := BcdToStr(Bcd);
end;

class function PubMath.TryStrToBcd(Value: string): TBcd;
begin
  TryStrToBcd(Value, Result);
end;

class function PubMath.TryStrToBcd(Value: string; var Bcd: TBcd): boolean;
begin
  //if Pos('.', Value) < 1 then Value := Value + '.0000000000000000000001';
  //if not TryStrToBcd(Value, Bcd) then
  //  raise Exception.Create('不是合法的数值型数据(Invalid String)！');
  Result := false;
  try
    Bcd := StrToBcd(Value);
  except
    exit;
  end;
  Result := true;
end;

class function PubMath.Precision(const Bcd: TBcd): integer;
begin
  Result := BcdPrecision(Bcd);
end;

class function PubMath.Precision(const Value: string): integer;
var
  Bcd: TBcd;
begin
  TryStrToBcd(Value, Bcd);
  Result := BcdPrecision(Bcd);
end;

class function PubMath.DecimalDig(const Bcd: TBcd): integer;
begin
  Result := BcdScale(Bcd);
end;

class function PubMath.DecimalDig(const Value: string): integer;
var
  Bcd: TBcd;
begin
  TryStrToBcd(Value, Bcd);
  Result := BcdScale(Bcd);
end;

class function PubMath.IsNegative(const Bcd: TBcd): boolean;
begin  //判断是否是负数，小于零返回true
  Result := IsBcdNegative(Bcd);
end;

class function PubMath.IsNegative(const Value: string): boolean;
var
  Bcd: TBcd;
begin
  Result := false;
  if not TryStrToBcd(Value, Bcd) then exit;
  Result := IsBcdNegative(Bcd);
end;

class function PubMath.IsValNull(Bcd: TBcd): boolean;
begin                                      
  Result := IsValNull(BToStr(Bcd));
end;

class function PubMath.IsValNull(Value: string): boolean;
begin
  Result := (trim(Value) = '0') or (trim(Value) = '') or
    IsEqual(Value, '0');
end;

class function PubMath.IsValidValue(Bcd: TBcd): boolean;
begin
  Result := IsValidValue(BToStr(Bcd));
end;

class function PubMath.IsValidValue(Value: string): boolean;
var
  Bcd: TBcd;
begin
  Result := trim(Value) = '';
  if Result then exit;
  try
    if not FMTBcd.TryStrToBcd(Value, Bcd) then exit;
  except
    exit;
  end;
  if BcdPrecision(Bcd) > 12 then exit; //整数位
  if BcdScale(Bcd) > 16 then exit;
  Result := true;
end;

class function PubMath.IsValidValueEx(Value: string): string;
var
  Bcd: TBcd;
  Len: integer;
begin
  Result := Value;
  if not IsValidValue(Value) then
  begin
    try
      TryStrToBcd(Value, Bcd);
    except
      Result := '';
      exit;
    end;
    Len := BcdScale(Bcd);
    if Len > 16 then
    begin
      if IsNegative(Value) then
        Result := Ad(Value, '-0.00000000000000005')
      else
        Result := Ad(Value, '0.00000000000000005'); //2005-11-27 mod
      Len := DecimalDig(Result);
      if Len > 16 then
        Result := Copy(Result, 1, Length(Result) - (Len - 16));
    end else
      Result := '';
    {TryStrToBcd(Value, Bcd1);
    Value := BcdToStr(Bcd1);
    if not NormalizeBcd(Bcd1, Bcd2, 28, 16) then
      Result := ''
    else
    begin
      if IsValidValue(Bcd2) then
        Result := BcdToStr(Bcd2)
      else
        Result := '';
      TryStrToBcd(Result, Bcd1);
    end;}
  end;
end;

class function PubMath.IsEqual(const Bcd1, Bcd2: TBcd): boolean;
var
  Bcd3, Bcd4: TBcd;
  Ret: integer;
begin
  BcdSubtract(Bcd1, Bcd2, Bcd3);
  if IsBcdNegative(Bcd3) then
    TryStrToBcd(Copy(BToStr(Bcd3), 2, MaxInt), Bcd3);
  //TryStrToBcd('0.0000000000000082', Bcd4);
  TryStrToBcd('0.00000000000000001', Bcd4); //2009-04-22
  //TryStrToBcd('0.0000000001', Bcd4);
  Ret := BcdCompare(Bcd4, Bcd3);
  Result := Ret >= 0;
end;

class function PubMath.IsEqual(Value1, Value2: string): boolean;
var
  Bcd1, Bcd2: TBcd;
begin
  if trim(Value1) = '' then Value1 := '0';
  if trim(Value2) = '' then Value2 := '0';
  TryStrToBcd(Value1, Bcd1);
  TryStrToBcd(Value2, Bcd2);
  Result := IsEqual(Bcd1, Bcd2);
end;

class function PubMath.IsValidDate(Value: string): boolean;
var
  d: TDateTime;
begin
  Result := TryStrToDate(Value, d);
end;

class function PubMath.IsValidDateTime(Value: string): boolean;
var
  d: TDateTime;
begin
  Result := TryStrToDateTime(Value, d);
end;

class function PubMath.IsValidTime(Value: string): boolean;
var
  d: TDateTime;
begin
  Result := TryStrToTime(Value, d);
end;

class function PubMath.IsValidValueDate(Value: string): string;
begin
  Result := Value;
  if not IsValidDate(Value) then
    Result := ''
  else
  Result := DateToStr(StrToDate(Value));
end;

class function PubMath.IsValidValueTime(Value: string): string;
begin
  Result := Value;
  if not IsValidTime(Value) then
    Result := ''
  else
  Result := TimeToStr(StrToDateTime(Value));
end;

class function PubMath.IsNegOrZero(const Value: string): boolean;
begin
  Result := IsNegative(Value) or IsValNull(Value);
end;

class function PubMath.IsNegOrZero(const Bcd: TBcd): boolean;
begin
  Result := IsNegative(Bcd) or IsValNull(Bcd);
end;

class function PubMath.IsPosOrZero(const Value: string): boolean;
begin
  Result := not IsNegative(Value);
end;

class function PubMath.IsPosOrZero(const Bcd: TBcd): boolean;
begin
  Result := not IsNegative(Bcd);
end;

class function PubMath.IsPositive(const Bcd: TBcd): boolean;
begin
  Result := (not IsNegative(Bcd)) and (not IsValNull(Bcd));
end;

class function PubMath.IsPositive(const Value: string): boolean;
begin
  Result := (not IsNegative(Value)) and (not IsValNull(Value));
end;

class function PubMath.Round(Bcd: TBcd): TBcd;
var
  Value: string;
begin
  Value := FormatBcd('0', Bcd);
  Result := StrToBcd(Value);
end;

class function PubMath.Round(Value: string): string;
var
  Bcd1: TBcd;
begin
  TryStrToBcd(Value, Bcd1);
  Result := FormatBcd('0', Bcd1);
end;

class function PubMath.Trunc(Bcd: TBcd): TBcd;
var
  Value: string;
begin
  Value := BcdToStr(Bcd);
  Value := Trunc(Value);
  Result := StrToBcd(Value);
end;

class function PubMath.Trunc(Value: string): string;
var
  Index: integer;
begin
  Index := Pos('.', Value);
  if Index > 0 then
    Result := Copy(Value, 1, Index - 1)
  else
    Result := Value;
end;

class function PubMath.ModBcd(Bcd1, Bcd2: TBcd): TBcd;
begin
  Result := StrToBcd(ModBcd(BcdToStr(Bcd1), BcdToStr(Bcd2)));
end;

class function PubMath.ModBcd(Value1, Value2: string): string;
var
  TmpValue: string;
begin // x - (x div y) * y.
  TmpValue := Trunc(PubMath.Di(Value1, Value2));
  TmpValue := Mu(TmpValue, Value2);
  Result := Su(Value1, TmpValue);
end;

class function PubMath.IsGreater(const Value1, Value2: string): boolean;
begin
  Result := IsPositive(PubMath.Su(Value1, Value2));
end;

class function PubMath.IsGreater(const Bcd1, Bcd2: TBcd): boolean;
begin
  Result := IsPositive(PubMath.Su(Bcd1, Bcd2));
end;

class function PubMath.IsLess(const Value1, Value2: string): boolean;
begin
  Result := IsNegative(PubMath.Su(Value1, Value2));
end;

class function PubMath.IsLess(const Bcd1, Bcd2: TBcd): boolean;
begin
  Result := IsNegative(PubMath.Su(Bcd1, Bcd2));
end;

class function PubMath.TruncEx(Value: string): string;
begin //考虑了负数
  Result := Trunc(Value);
  if not IsValNull(Su(Value, Result)) then
  begin
    if IsPositive(Value) then
      Result := Ad(Result, '1')
    else
      Result := Su(Result, '1');
  end;
end;

class function PubMath.IsValNNull(Bcd: TBcd): boolean;
begin
  Result := not IsValNull(Bcd);
end;

class function PubMath.IsValNNull(Value: string): boolean;
begin
  Result := not IsValNull(Value);
end;

class function PubMath.BcdToStrF(const Bcd: TBcd; Format: TFloatFormat;
  const Precision1, Digits: Integer): string;
begin
  Result := FmtBcd.BcdToStrF(Bcd, Format, Precision1, Digits);
end;

class function PubMath.FormatBcd(const Format: string; Bcd: TBcd): string;
begin
  Result := FmtBcd.FormatBcd(Format, Bcd);
end;

class function PubMath.Format(const FormatStr: string; Value: string): string;
var
  Bcd1: TBcd;
begin //2013-10-12 add
  TryStrToBcd(Value, Bcd1);
  Result := FormatBcd(FormatStr, Bcd1);
end;

class procedure PubMath.Set_DefaultDecimals(DefaultDecimals: integer);
begin
  {$ifndef dotnet}
  {$ifndef WebWap}
  {$ifndef AutoBuild}
  {$ifndef Zhc}
  //FmtBcd._DefaultDecimals := DefaultDecimals;
  //PubSys.Set_Decimals(DefaultDecimals);
  {$endif}
  {$endif}
  {$endif}
  {$endif}
end;

class function PubMath.FormatBcdEx(const Value: string): string;
var
  lp, Index: integer;
  TmpStr: string;
begin
  Index := Pos('.', Value);
  if Index < 1 then
    Result := Value + '.0000000000000000'
  else
  begin
    TmpStr := trim(Copy(Value, Index + 1, MaxInt));
    for lp := 1 to 16 - length(TmpStr) do
      TmpStr := TmpStr + '0';
    Result := Copy(Value, 1, Index) + TmpStr;
  end;
end;

class function PubMath.IsGreaterEqual(const Value1,
  Value2: string): boolean;
begin
  Result := IsGreater(Value1, Value2) or IsEqual(Value1, Value2);
end;

class function PubMath.IsLessEqual(const Value1, Value2: string): boolean;
begin
  Result := IsLess(Value1, Value2) or IsEqual(Value1, Value2);
end;

class function PubMath.ChangeFloat(Text: string): string;
var
  Index: integer;
  TmpStr, MuOne, MuTow: string;
begin //7.58671769249862E-5   2009-04-14 add
      //0.0000758671769250
  Result := IsValidValueEx(Text);
  Index := Pos('E', Text);
  if Index > 0 then
  begin
    MuOne := PubString.GetDeliPri(Text, 'E');
    TmpStr := PubString.GetDeliBack(Text, 'E');
    if IsNegative(TmpStr) then
      MuTow := '0.' + PubString.FillChar('1', '0', StrToInt(Abs(TmpStr)))
    else
      MuTow := '1' + PubString.FillCharRight('0', '0', StrToInt(Abs(TmpStr)));
    Result := IsValidValueEx(Mu(MuOne, MuTow));
  end;
end;

class function PubMath._IsValidValueEx(Value: string; DigCount: integer): string;
var
  Bcd: TBcd;
  Len: integer;
  function GetF: string;
  var
    lp: integer;
  begin
    {if IsNegative(Value) then
        Result := Ad(Value, '-0.00000000000000005')
      else
        Result := Ad(Value, '0.00000000000000005');}
    Result := '';
    for lp := 1 to DigCount do
      Result := Result + '0';
    Result := '0.' + Result + '5';
  end;
begin //2013-10-14 add
  Result := Value;
  try
    TryStrToBcd(Value, Bcd);
  except
    Result := '';
    exit;
  end;
  Len := BcdScale(Bcd);
  if Len > DigCount then
  begin
    if IsNegative(Value) then
      Result := Ad(Value, GetF)
    else
      Result := Ad(Value, GetF);

    Len := DecimalDig(Result);
    if Len > DigCount then
      Result := Copy(Result, 1, Length(Result) - (Len - DigCount));
  end;
end;

class function PubMath.Decimal(Value: string; DigCount: integer): string;
var
  lp: integer;
  Format1: string;
begin
  {if DigCount < 1 then
    Format1 := '0'
  else
  begin
    Format1 := '0.';
    for lp := 1 to DigCount do
      Format1 := Format1 + '0'
  end;}

  //Result := FormatBcd(Format, StrToBcd(Value));
  Result := _IsValidValueEx(Value, DigCount);


  if Result = '-0' then Result := '0'; //2009-08-24 add
end;

class function PubMath.Decimal(Value, DigCount: string): string;
begin //2013-10-12 add
  if (trim(DigCount) = '') or (IsLess(DigCount, '0')) then
    Result := Value
  else
    Result := Decimal(Value, StrToInt(DigCount));
end;

class function PubMath.DecimalEx(Value: string; DigCount: integer): string;
var
  I, lp: integer;
  Flag: boolean;
begin
  Result := Decimal(Value, DigCount);
  I := DecimalDig(Result);

  Flag := Pos('.', Result) < 1;
  if (I <> DigCount) or Flag then
  begin
    if Flag then
    begin
      I := 0;
      Result := Result + '.';
    end;
    for lp := 1 to DigCount - I do
      Result := Result + '0';
  end else

end;

end.

