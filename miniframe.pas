
program miniframe;

//{.$mode objfpc}{$H+}
{$I components\mORMot2\src\mormot.defines.inc}

{$ifdef OSWINDOWS}
  {$apptype console}
  {$R components\mORMot2\src\mormot.win.default.manifest.res}
{$endif OSWINDOWS}

uses
  {$ifdef mswidows}
  ShareMem,
  {$endif}
  mormot.core.os,
  mormot.core.base,
  mormot.core.zip,
  mormot.net.http,
  mormot.net.server,
  mormot.net.async,
  Classes, SysUtils, mormothttps,
  miniscriptcontroller,
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  //Forms,testmain,
  pascalscript, FileUtil
  { you can add units after this };

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$R *.res}
var
  fSaveToFile: System.Text;
  http: THttpAsyncServer;
begin
  //控制台应用
  AllocConsole;
  System.Assign(fSaveToFile, '');
  Rewrite(fSaveToFile);
  {$ifdef OSPOSIX}
  TTextRec(fSaveToFile).LineEnd := #13#10;
  {$endif OSPOSIX}

  TKing_HttpApiServer.StartService;
end.

