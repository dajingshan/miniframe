unit PubStringUnit;

interface
  uses  SysUtils, Classes;

const
  DEFAULT_DELIMITERS = [' ', #9, #10, #13];//�ո�ָ�

type
  PubString = class
  private

  public
    //�ַ���������
    //ȡText����delmite�ָ�ǰ������
    class function GetDeliPri(Text: string; Delimite: string; All: boolean = true): string;
    //ȡText����delmite�ָ��������
    class function GetDeliBack(Text: string; Delimite: string; All: boolean = true): string;

    //���ұ�ʼȡDelimite�ָ�
    class function GetDeliPriEx(Text: string; Delimite: string): string;
    //ȡText����delmite�ָ��������
    class function GetDeliBackEx(Text: string; Delimite: string): string;
    class function GetDeliBack2(Text, Delimite: string): string;

    //ȡ�Ե�Index���ָ�Delimiteǰ�Ĵ�
    class function GetDeliPriEx2(Text: string; Delimite: Char; Index: integer): string;

    //ȡ��Delimiters�ָ����ַ��� bTrail���ΪTrue��ѵ�index�����Ҳȡ����
    {$ifdef dotnet}
    class function  StrGetToken(const S: string; index: Integer;
       bTrail: Boolean; Delimiters: TSysCharSet): string;
    {$else}
    class function  StrGetToken(const S: string; index: Integer;
       bTrail: Boolean = False; Delimiters: TSysCharSet = DEFAULT_DELIMITERS): string;
    {$endif}
    //ȡ��Delimiters�ָ����ַ����ĸ���
    {$ifdef dotnet}
    class function  StrCountWords(S: string; Delimiters: TSysCharSet): Integer;
    {$else}
    class function  StrCountWords(S: string; Delimiters: TSysCharSet =
       DEFAULT_DELIMITERS): Integer;
    {$endif}
    //��NewToken�滻S������Token bCaseSensitive:=true��Сд����
    class function  StrReplaceString(var S: string; const Token,
       NewToken: string; bCaseSensitive: Boolean): Boolean;
    //�ӵ�Index������Substr�滻Count���ַ�
    class procedure StrSimple_ReplaceString(var S: string;
       const  Substr: string; index, Count: Integer);
    //ȥ��S�еĻس����з�
    class function StrTruncateCRLF(const S: string): string;
    //�ж�S�Ƿ��Իس����з�����
    class function  StrIsContainingCRLF(const S: string): Boolean;
    //��SL�еĸ�������ת��Ϊ��Delimiter�ָ���Str
    class function  StrCompositeStrings(SL: TStrings; const Delimiter: string): string;
    //CommandTextתΪTStringlist����
    class function CommandTextToSl(Text: string): TStringlist;
    //�ϳ�Comma��
    class procedure AddComma(var AddToStr: string; OneItem: string; Deli: string = ',');
    //����߿�
    class function FillChar(Text, Sub: string; Len: integer): string; overload;
    class function FillChar(Text: integer; Sub: string; Len: integer): string; overload;
    //���ұ߿�
    class function FillCharRight(Text, Sub: string; Len: integer): string;
    //��ʮ�����ִ���ʵ���ַ���
    class function HexStrToStr(Text: string): string;
    //��ʵ���ַ���ʮ�����ִ�
    class function StrToHexStr(Text: String): String;
    //�ַ�������ֹ

    //ʱ��תΪʱ����ַ���
    class function DateTimeToStamp(Datetime: TDateTime): string;
    //�滻string;
    class function StrPlace(S, Old, New: string): string;

    //��ʽ��AM_ID
    class function FormAM_ID(AM_ID: string): string;

    //����ȫ�������š������š����ţ�һ�ɸ�Ϊ��� 2008-09-30 add
    class function StrTruncateCNChar(S: string): string;

    //�����ظ�������Ӱ��SL�е�˳��
    class procedure FilterRep(SL: TStringList);

    class function GetOneItemValue(const Name, S: string; Deli: Char = ';'): string;

  end;

implementation

uses StrUtils;

{ PubString }

class procedure PubString.AddComma(var AddToStr: string; OneItem, Deli: string);
begin
  if trim(AddToStr) = '' then
    AddToStr := OneItem
  else
    AddToStr := AddToStr + Deli + OneItem;
end;

class function PubString.CommandTextToSl(Text: string): TStringlist;
begin
  Result := TStringList.Create;
  Result.CommaText := Text;
end;

class function PubString.DateTimeToStamp(Datetime: TDateTime): string;
begin
  Result := FormatDateTime('YYYY"-"MM"-"DD HH":"NN":"SS"."ZZZ', Datetime);
end;

class function PubString.FillChar(Text, Sub: string; Len: integer): string;
var
  lp: integer;
begin
  Result := Text;
  for lp := 1 to Len - Length(Result) do
    Result := Sub + Result;
end;

class function PubString.FillChar(Text: integer; Sub: string; Len: integer): string;
begin
  Result := FillChar(IntToStr(Text), Sub, Len);   
end;

class function PubString.FillCharRight(Text, Sub: string;
  Len: integer): string;
var
  lp: integer;
begin
  Result := Text;
  for lp := 1 to Len - Length(Result) do
    Result := Result + Sub;
end;

class procedure PubString.FilterRep(SL: TStringList);
var
  lp, i: integer;
begin
  for lp := SL.Count - 1 downto 0 do
  begin
    for i := lp - 1 downto 0 do
    if trim(SL[lp]) = trim(SL[i]) then
    begin
      SL.Delete(lp);
      break;
    end; 
  end;
end;

class function PubString.FormAM_ID(AM_ID: string): string;
begin
  Result := GetDeliPri(AM_ID, '-') + '-' + FillChar(GetDeliBack(AM_ID, '-'), '0', 2);
end;

class function PubString.GetDeliBack(Text, Delimite: string; All: boolean): string;
var
  Index: integer;
begin
  if All then //2013-08-21 add
    Result := Text
  else
    Result := '';
  Index := Pos(Delimite, Text);  
  if Index > 0 then
    Result := Copy(Text, Index + Length(Delimite), MaxInt);
end;

class function PubString.GetDeliBackEx(Text, Delimite: string): string;
begin
  Result := Text;
  if Pos(Delimite, Text) > 0 then
  begin
    Text := ReverseString(Text);
    Delimite := ReverseString(Delimite);
    Result :=  ReverseString(GetDeliPri(Text, Delimite));
  end;
end;

class function PubString.GetDeliBack2(Text, Delimite: string): string;
begin
  Result := '';
  if Pos(Delimite, Text) > 0 then
  begin
    Text := ReverseString(Text);
    Delimite := ReverseString(Delimite);
    Result :=  ReverseString(GetDeliPri(Text, Delimite));
  end;
end;

class function PubString.GetDeliPri(Text, Delimite: string; All: boolean): string;
begin
  if All then
    Result := Text
  else
    Result := '';
  if Pos(Delimite, Text) > 0 then
    Result := Copy(Text, 1, Pos(Delimite, Text) - 1);
end;

class function PubString.GetDeliPriEx(Text, Delimite: string): string;
begin
  Result := Text;
  if Pos(Delimite, Text) > 0 then
  begin
    Text := ReverseString(Text);
    Delimite := ReverseString(Delimite);
    Result :=  ReverseString(GetDeliBack(Text, Delimite));
  end;
end;

class function PubString.GetDeliPriEx2(Text: string; Delimite: Char;
  Index: integer): string;
var
  Count, lp, MyCount: integer;
begin
  Result := Text;
  MyCount := 0;
  Count := length(Text);
  for lp := 1 to Count do
  if Delimite = Text[lp] then
  begin
    Inc(MyCount);
    if Index = MyCount then
    begin
      Result := Copy(Text, 1, lp - 1);
      Break;
    end;
  end;
end;

class function PubString.GetOneItemValue(const Name, S: string;
  Deli: Char): string;
var
  lp, Count, P: integer;
  TmpStr: string;
begin //2009-03-11
  Count := StrCountWords(S, [Deli]);
  for lp := 1 to Count do
  begin
    TmpStr := StrGetToken(S, lp, false, [Deli]);
    P := AnsiPos('=', TmpStr);
    if (P <> 0) and (AnsiCompareText(Copy(TmpStr, 1, P - 1), Name) = 0) then
    begin
      Result := Copy(TmpStr, P + 1, MaxInt);
      Exit;
    end;
  end;
end;

class function PubString.HexStrToStr(Text: string): string;
var
  i, Count: integer;
  StrTmp: string;
begin
  Count := length(Text);
  Count := Count div 2;
  SetLength(Result, Count);
  for i:= 0 to Count - 1 do
  begin
    StrTmp := Text[2 * i + 1];
    StrTmp := '$' + StrTmp + Text[2 * i + 2];
    Result[i + 1] := Char(StrToInt(StrTmp));
  end;
end;

class function PubString.StrCompositeStrings(SL: TStrings;
  const Delimiter: string): string;
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

class function PubString.StrCountWords(S: string;
  Delimiters: TSysCharSet): Integer;
var
  bInWord: Boolean;
  I, Count: Integer;
begin
  Result := 0;
  Count := Length(S);
  I := 1;
  bInWord := False;
  while I <= Count do
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

class function PubString.StrGetToken(const S: string; index: Integer;
  bTrail: Boolean; Delimiters: TSysCharSet): string;
var
  I, W, head, tail, Count: Integer;
  bInWord: Boolean;
begin
  I := 1;
  W := 0;
  bInWord := False;
  head := 1;
  tail := Length(S);
  Count := tail;
  while (I <= Count) and (W <= index) do //Length(S)
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

  if bTrail then tail := Count; //Length(S);
  if W >= index then Result := Copy(S, head, tail - head + 1)
  else Result := '';
end;

class function PubString.StrIsContainingCRLF(const S: string): Boolean;
var
  len: Integer;
begin
  len := Length(S);
  Result := (len >= 2) and (S[len - 1] = #13) and (S[len] = #10);
end;

class function PubString.StrPlace(S, Old, New: string): string;
begin
  Result := StringReplace(s, Old, New, [rfReplaceAll, rfIgnoreCase]);
end;

class function PubString.StrReplaceString(var S: string; const Token,
  NewToken: string; bCaseSensitive: Boolean): Boolean;
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

class procedure PubString.StrSimple_ReplaceString(var S: string;
  const Substr: string; index, Count: Integer);
begin
  S := Format('%s%s%s',[Copy(S, 1, index - 1), Substr, Copy(S, index + Count, Maxint)]);
end;


class function PubString.StrToHexStr(Text: String): String;
var
  i, Count: integer;
begin
  Result := '';
  Count := length(Text);
  for i := 1 to Count do
    Result := Result + IntToHex(Byte(Text[i]), 2);
end;

class function PubString.StrTruncateCNChar(S: string): string;
var
  W: WideString;
  lp: integer;
begin //����ȫ�������š������š����ţ�һ�ɸ�Ϊ���
  W := S;
  
  for lp := Length(W) downto 1 do
  begin
    if W[lp] = '��' then
      W[lp] := ','
    else
    if W[lp] = '��' then
      W[lp] := '('
    else
    if W[lp] = '��' then
      W[lp] := ')'
    else
    if W[lp] = '?' then //2008-10-07
      Delete(W, lp, 1);
  end;
  
  Result := W;
end;

class function PubString.StrTruncateCRLF(const S: string): string;
begin
  Result := trim(S);
  Result := StrPlace(Result, #13, '');
  Result := StrPlace(Result, #10, '');
end;

end.
