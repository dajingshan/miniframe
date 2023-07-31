
////////////////////////////////////////////////////////////////////////////
//1.此单元专门供使用者注册所需要的系统没提供的类、过程或函数到script中 。 //
//2.不建议使用者修改其他单元，这样作者更新源码时直接覆盖即可。            //
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
    //在此增加创建系统管理的对象的方法，即脚本中创建后不需要自己释放的，由系统管理
    //请参考CreateStringlist的实现，实现需要以下三步：

    //1.定义调用方法
    //function CreateStringlist: TStringlist;
    //。。。。
    //在此增加创建系统管理的对象的方法 end

    //2.注册前面自己方法——定义方法头部
    class procedure SIRegister_Head(PSCompileTimeClass: TPSCompileTimeClass);
    //3.注册前面自己方法——实现
    class procedure RIRegister_Body(PSRuntimeClass: TPSRuntimeClass);
  end;

//注册使用者自己的函数或过程
procedure Register_functionOrProcedure_SelfDefine(Sender: TPSScript);

//注册所需要的类或类型——定义类或方法头部
procedure SIRegister_Head_SelfDefine(Cl: TPSPascalCompiler);
//注册所需要的类或类型——方法的实现
procedure RIRegister_Body_SelfDefine(Cl: TPSRuntimeClassImporter);

implementation

procedure Register_functionOrProcedure_SelfDefine(Sender: TPSScript);
  procedure AddFunction(const Decl: tbtstring; Ptr: Pointer);
  begin
    Sender.AddFunction(Ptr, Decl);
  end;
begin
  {参考miniregister单元中对应的
  //注册系统的函数
  AddFunction('Function CreateDir(Const NewDir : String) : Boolean;', @CreateDir);
  //注册自定义函数
  AddFunction('function ProgramPath: string', @ProgramPath);
  }
end;

procedure SIRegister_Head_SelfDefine(Cl: TPSPascalCompiler);
begin
  {参考miniregister单元中对应的
  with Cl.AddClassN(cl.FindClass('TObject'), 'TminiJsonArray') do
  begin
    //注册读写类属性
    RegisterProperty('O', 'TminiJson integer', iptrw);
    SetDefaultPropery('O'); //设置为类默认属性
    RegisterProperty('S', 'string integer', iptrw);

    //注册类方法
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
  {参考miniregister单元中对应的
  with Cl.Add(TminiJsonArray) do
  begin
    RegisterPropertyHelper(@TminiJsonArrayOR, @TminiJsonArrayOW, 'O');
    RegisterMethod(@TminiJsonArray.Delete, 'Delete');
    RegisterMethod(@TminiJsonArray.Insert, 'Insert');

    //注册一个属性，读与写分别自定义函数
    RegisterPropertyHelper(@TminiJsonArraySR, @TminiJsonArraySW, 'S');
  end;}

end;

{ TPub }

{function TPub.CreateStringlist: TStringlist;
begin
  Result := TStringList.Create;
  FList.Add(Result); //一定要将创建的对象加入到Flist中才能自动释放
end;}

class procedure TPub.RIRegister_Body(PSRuntimeClass: TPSRuntimeClass);
begin
  {with PSRuntimeClass do
  begin
    //注册创建系统管理的对象，Create开头的原始调用，Get开头的快捷调用，都一样的----实现
    RegisterMethod(@TPub.CreateStringlist, 'CreateStringlist');
    RegisterMethod(@TPub.CreateStringlist, 'GetSL');
  end;}
end;

class procedure TPub.SIRegister_Head(PSCompileTimeClass: TPSCompileTimeClass);
begin
  {with PSCompileTimeClass do
  begin
    //注册创建系统管理的对象，Create开头的原始调用，Get开头的快捷调用，都一样的--定义头部
    RegisterMethod('function CreateStringlist: TStringlist');
    RegisterMethod('function GetSL: TStringlist');
  end;}
end;

end.
