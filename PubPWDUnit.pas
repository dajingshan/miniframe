unit PubPWDUnit;

interface
uses
  SysUtils{$ifdef fpc},md5{$else}, System.Hash{$endif};

///const XorKey: array[0..7] of Byte = ($B2, $09, $AA, $55, $93, $6D, $84, $47);

type

  PubPWD = class
  private
    class function GetOneChar(T: string; i: integer): Char; static;
    //加密串, 不转为16进制字符串, Key 为加密子串，加密码和解密必需一至
    class function MaskText(Text: string; Key: string = ''): string;
    //解密串
    class function UnMaskText(Text: string; Key: string = ''): string;
  public
    //加密后转为16进制
    class function SetPWD(Text: string; Key: string = ''): string;
    //解密串
    class function GetPWD(Text: string; Key: string = ''): string;
    class function GetMd5(text: string): string;
  end;

implementation

uses PubStringUnit;

(*
function EncryptString(Source, Key: string): string;
var
  KeyLen,KeyPos,Offset,SrcPos,SrcAsc,Range: integer;
  Dest: string;
begin
  KeyLen := Length(Key);
  if KeyLen = 0 then
    Key := 'delphi';
  KeyPos := 0;
  Range := 256;
  randomize;
  Offset := random(Range);
  Dest := format('%1.2x', [Offset]);
  for SrcPos := 1 to Length(Source) do
  begin
    SrcAsc := (Ord(Source[SrcPos]) + Offset) mod 255;
    if KeyPos < KeyLen then
      KeyPos := KeyPos + 1
    else
      KeyPos := 1;
    SrcAsc := SrcAsc xor Ord(Key[KeyPos]);
    Dest := Dest + format('%1.2x', [SrcAsc]);
    Offset := SrcAsc;
  end;
  result := Dest;
end;

function UnEncryptString(Source, Key: string): string;
var
  KeyLen,KeyPos,Offset,SrcPos,SrcAsc,TmpSrcAsc: integer;
  Dest: string;
begin
  KeyLen := Length(Key);
  if KeyLen = 0 then
    Key := 'delphi';
  KeyPos := 0;
  Offset := strtoint('$' + copy(Source, 1, 2));
  SrcPos := 3;
  repeat
    SrcAsc := strtoint('$' + copy(Source, SrcPos, 2));
    if KeyPos < KeyLen then
      KeyPos := KeyPos + 1
    else
      KeyPos := 1;
    TmpSrcAsc := SrcAsc xor Ord(Key[KeyPos]);
    if TmpSrcAsc <= Offset then
      TmpSrcAsc := 255 + TmpSrcAsc - Offset
    else
      TmpSrcAsc := TmpSrcAsc - Offset;
    Dest := Dest + chr(TmpSrcAsc);
    Offset := SrcAsc;
    SrcPos := SrcPos + 2;
  until
    SrcPos >= Length(Source);
  result := Dest;
end;

function Enc(str: string): string;
var
  i, j: Integer;
begin
  Result := '';
  j := 0;
  for i := 1 to Length(str) do
  begin
    Result := Result + IntToHex(Byte(str[i]) xor XorKey[j], 2);
    j := (j + 1) mod 8;
  end;
end;

function Dec(str: string): string;
var
  i, j: Integer;
begin
  Result := '';
  j := 0;
  for i := 1 to Length(str) div 2 do
  begin
    Result := Result + Char(StrToInt('$' + Copy(str, i * 2 - 1, 2)) xor
    XorKey[j]);
    j := (j + 1) mod 8;
  end;
end;   *)

(*
Function JiaMi(Src:String; Key:String):String;

var

  KeyLen :Integer;

  KeyPos :Integer;

  offset :Integer;

  dest :String;

  SrcPos :Integer;

  SrcAsc :Integer;

  Range :Integer;

  IntTemp:integer;

  SrcAnsi:PAnsiChar;

begin

  KeyLen:=Length(Key);

  KeyPos:=0;

  Range:=1;

  Randomize;

  offset:=Random(Range);

  dest:=format('%1.2x',[offset]);

  SrcAnsi:=PAnsiChar(AnsiString(Src));

  IntTemp:= Length(SrcAnsi);

  for SrcPos := 1 to IntTemp do

  begin

    SrcAsc:=(Ord(SrcAnsi[SrcPos-1]) + offset) MOD 255;

    if KeyPos < KeyLen then KeyPos:= KeyPos + 1 else KeyPos:=1;

    SrcAsc:= SrcAsc xor Ord(Key[KeyPos]);

    dest:=dest + format('%1.2x',[SrcAsc]);

    offset:=SrcAsc;

  end;

  Result:=Dest;

end;

//解密函数

Function JieMi (Src:String; Key:String):String;

var

  KeyLen :Integer;

  KeyPos :Integer;

  offset :Integer;

  dest :String;

  SrcPos :Integer;

  SrcAsc :Integer;

  TmpSrcAsc :Integer;

  Range :Integer;

  SrcAnsi:PAnsiChar;

  IntTemp,i:Integer;

  ByteArray: array of Byte;

begin

  KeyLen:=Length(Key);

  if KeyLen = 0 then key:='starlin';

  KeyPos:=0;

  SrcPos:=0;

  SrcAsc:=0;

  Range:=1;

  offset:=StrToInt('$'+ copy(src,1,2));

  SrcPos:=3;

  IntTemp:=Length(Src) div 2;

  setlength(ByteArray,IntTemp);

  i:=0;

  repeat

    try

      SrcAsc:=StrToInt('$'+ copy(src,SrcPos,2));

    except

      SrcAsc:=StrToInt('$00');

    end;



    if KeyPos < KeyLen Then KeyPos := KeyPos + 1 else KeyPos := 1;



    TmpSrcAsc := SrcAsc xor Ord(Key[KeyPos]);



    if TmpSrcAsc <= offset then

      TmpSrcAsc := 255 + TmpSrcAsc - offset

    else

      TmpSrcAsc := TmpSrcAsc - offset;

    ByteArray[i]:=TmpSrcAsc;

    i:=i+1;

    offset:=srcAsc;

    SrcPos:=SrcPos + 2;

  until SrcPos >= Length(Src);

  //CopyMemory(@SrcAnsi[0],@ByteArray[0],IntTemp);
  copymemory(SrcAnsi,ByteArray);

  dest:=string(AnsiStrings.strpas(SrcAnsi));

  Result:=Dest;



end;  *)

{ PubPWD }

class function PubPWD.GetPWD(Text, Key: string): string;
begin
  Text := PubString.HexStrToStr(Text);
  Result := UnMaskText(Text, Key);
end;

class function PubPWD.SetPWD(Text, Key: string): string;
begin
  Result := PubString.StrToHexStr(MaskText(Text, Key));
end;

class function PubPWD.GetMd5(text: string): string;
begin
  {$ifdef fpc}
  Result := MD5Print(MD5String(text));
  {$else}
  Result := THashMD5.GetHashString(Text);
  {$endif}
end;

class function PubPWD.GetOneChar(T: string; i: integer): Char;
begin
  {$IFDEF MSWINDOWS}
  Result := T[i];
  {$else}
  Result := T[i - 1];
  {$endif}
end;

{
class function PubPWD.MaskText(Text, Key: string): string;
var
  i: integer;
  StrOrd, KeyOrd: Integer;
  OrdStr, TmpStr, KeyStr:string;
begin
  KeyStr := '@+T$D=' + Key + 'C/@?N**';
  OrdStr := '';
  for i := 1 to Length(Text) do
  begin
    StrOrd := Ord(GetOneChar(Text,i));
    if i <= Length(KeyStr) then
      KeyOrd := Ord(GetOneChar(KeyStr, i))
    else
      KeyOrd := 0;
    TmpStr := Chr(((KeyOrd+i) Mod 256) xor StrOrd);
    OrdStr := OrdStr+TmpStr;
  end;
  if Length(Text) < Length(KeyStr) then
  begin
    for i := Length(Text) + 1 to Length(KeyStr) do
    begin
      KeyOrd := Ord(GetOneChar(KeyStr, i));
      TmpStr := Chr(((KeyOrd + i) Mod 256) xor 0);
      OrdStr := OrdStr + TmpStr;
    end;
  end;
  Result := OrdStr;
end;

class function PubPWD.UnMaskText(Text, Key: string): string;
var
  i, KeyOrd: integer;
  TmpStr, KeyStr: string;
begin
  KeyStr := '@+T$D=' + Key + 'C/@?N**';
  Result := '';
  for i := 1 to Length(Text) do
  begin
    if i <= Length(KeyStr) then
      KeyOrd := Ord(GetOneChar(KeyStr, i))
    else
      KeyOrd := 0;
    TmpStr := Chr(((KeyOrd+i) Mod 256) xor Ord(GetOneChar(Text, i)));
    Result := Result + TmpStr;
  end;
  Result := Trim(Result);
end;}


class function PubPWD.MaskText(Text, Key: string): string;
var
  i: integer;
  StrOrd, KeyOrd: Integer;
  OrdStr, TmpStr, KeyStr:string;
begin
  KeyStr := '@+T$D=' + Key + 'C/@?N**';
  OrdStr := '';
  for i := 1 to Length(Text) do
  begin
    StrOrd := Ord(GetOneChar(Text, i));
    if i <= Length(KeyStr) then
      KeyOrd := Ord(GetOneChar(KeyStr, i))
    else
      KeyOrd := 0;
    TmpStr := Chr(((KeyOrd+i) Mod 256) xor StrOrd);
    OrdStr := OrdStr+TmpStr;
  end;
  if Length(Text) < Length(KeyStr) then
  begin
    for i := Length(Text) + 1 to Length(KeyStr) do
    begin
      KeyOrd := Ord(GetOneChar(KeyStr, i));
      TmpStr := Chr(((KeyOrd + i) Mod 256) xor 0);
      OrdStr := OrdStr + TmpStr;
    end;
  end;
  Result := OrdStr;
end;

class function PubPWD.UnMaskText(Text, Key: string): string;
var
  i, KeyOrd: integer;
  TmpStr, KeyStr: string;
begin
  KeyStr := '@+T$D=' + Key + 'C/@?N**';
  Result := '';
  for i := 1 to Length(Text) do
  begin
    if i <= Length(KeyStr) then
      KeyOrd := Ord(GetOneChar(KeyStr, i))
    else
      KeyOrd := 0;
    TmpStr := Chr(((KeyOrd+i) Mod 256) xor Ord(GetOneChar(Text, i)));
    Result := Result + TmpStr;
  end;
  Result := Trim(Result);
end;

end.
