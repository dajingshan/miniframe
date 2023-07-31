
////////////////////////////////////////////////////////////////////////////
//1.�˵�Ԫר�Ź�ʹ����ע������Ҫ��ϵͳû�ṩ���ࡢ���̻�����script�� �� //
//2.������ʹ�����޸�������Ԫ���������߸���Դ��ʱֱ�Ӹ��Ǽ��ɡ�            //
////////////////////////////////////////////////////////////////////////////

unit SelfDefine;

interface

uses
  Classes, SysUtils, Math, minidb, minihttp, DataPackageUnit, PubSysUnit,
  PubFileUnit,PubStringUnit, PubPWDUnit, PubMathUnit, uPSCompiler, uPSUtils,
  uPSRuntime, uPSC_classes, uPSComponent, miniscriptcontroller;

type
  TPub = class(TPubbase)
  public
    //�ڴ����Ӵ���ϵͳ����Ķ���ķ��������ű��д�������Ҫ�Լ��ͷŵģ���ϵͳ����
    //��ο�CreateStringlist��ʵ�֣�ʵ����Ҫ����������

    //1.������÷���
    //function CreateStringlist: TStringlist;
    //��������
    //�ڴ����Ӵ���ϵͳ����Ķ���ķ��� end

    //2.ע��ǰ���Լ������������巽��ͷ��
    class procedure SIRegister_Head(PSCompileTimeClass: TPSCompileTimeClass);
    //3.ע��ǰ���Լ���������ʵ��
    class procedure RIRegister_Body(PSRuntimeClass: TPSRuntimeClass);
  end;

//ע��ʹ�����Լ��ĺ��������
procedure Register_functionOrProcedure_SelfDefine(Sender: TPSScript);

//ע������Ҫ��������͡���������򷽷�ͷ��
procedure SIRegister_Head_SelfDefine(Cl: TPSPascalCompiler);
//ע������Ҫ��������͡���������ʵ��
procedure RIRegister_Body_SelfDefine(Cl: TPSRuntimeClassImporter);

implementation

procedure Register_functionOrProcedure_SelfDefine(Sender: TPSScript);
  procedure AddFunction(const Decl: tbtstring; Ptr: Pointer);
  begin
    Sender.AddFunction(Ptr, Decl);
  end;
begin
  {�ο�miniregister��Ԫ�ж�Ӧ��
  //ע��ϵͳ�ĺ���
  AddFunction('Function CreateDir(Const NewDir : String) : Boolean;', @CreateDir);
  //ע���Զ��庯��
  AddFunction('function ProgramPath: string', @ProgramPath);
  }
end;

procedure SIRegister_Head_SelfDefine(Cl: TPSPascalCompiler);
begin
  {�ο�miniregister��Ԫ�ж�Ӧ��
  with Cl.AddClassN(cl.FindClass('TObject'), 'TminiJsonArray') do
  begin
    //ע���д������
    RegisterProperty('O', 'TminiJson integer', iptrw);
    SetDefaultPropery('O'); //����Ϊ��Ĭ������
    RegisterProperty('S', 'string integer', iptrw);

    //ע���෽��
    RegisterMethod('function Delete(index: Integer): TminiJson');
    RegisterMethod('procedure Insert(index: Integer; const value: TminiJson)');
  end;}
end;

{
procedure TminiJsonArraySR(Self: TminiJsonArray; var T: string; path: integer);
begin
  T := Self.S[path];
end;
procedure TminiJsonArraySW(Self: TminiJsonArray; const T: string; path: integer);
begin
  Self.S[path] := T;
end;
}

procedure RIRegister_Body_SelfDefine(Cl: TPSRuntimeClassImporter);
begin
  {�ο�miniregister��Ԫ�ж�Ӧ��
  with Cl.Add(TminiJsonArray) do
  begin
    RegisterPropertyHelper(@TminiJsonArrayOR, @TminiJsonArrayOW, 'O');
    RegisterMethod(@TminiJsonArray.Delete, 'Delete');
    RegisterMethod(@TminiJsonArray.Insert, 'Insert');

    //ע��һ�����ԣ�����д�ֱ��Զ��庯��
    RegisterPropertyHelper(@TminiJsonArraySR, @TminiJsonArraySW, 'S');
  end;}

end;

{ TPub }

{function TPub.CreateStringlist: TStringlist;
begin
  Result := TStringList.Create;
  FList.Add(Result); //һ��Ҫ�������Ķ�����뵽Flist�в����Զ��ͷ�
end;}

class procedure TPub.RIRegister_Body(PSRuntimeClass: TPSRuntimeClass);
begin
  {with PSRuntimeClass do
  begin
    //ע�ᴴ��ϵͳ����Ķ���Create��ͷ��ԭʼ���ã�Get��ͷ�Ŀ�ݵ��ã���һ����----ʵ��
    RegisterMethod(@TPub.CreateStringlist, 'CreateStringlist');
    RegisterMethod(@TPub.CreateStringlist, 'GetSL');
  end;}
end;

class procedure TPub.SIRegister_Head(PSCompileTimeClass: TPSCompileTimeClass);
begin
  {with PSCompileTimeClass do
  begin
    //ע�ᴴ��ϵͳ����Ķ���Create��ͷ��ԭʼ���ã�Get��ͷ�Ŀ�ݵ��ã���һ����--����ͷ��
    RegisterMethod('function CreateStringlist: TStringlist');
    RegisterMethod('function GetSL: TStringlist');
  end;}
end;

end.
