program miniFrame_d;
{$APPTYPE CONSOLE}
uses
  SysUtils,
  mormothttps in 'mormothttps.pas',
  minicomponents in 'minicomponents.pas',
  SelfDefine in 'SelfDefine.pas',
  minijson2dataset in 'minijson2dataset.pas',
  miniregister in 'miniregister.pas',
  miniscriptcontroller in 'miniscriptcontroller.pas';

begin
  {$ifdef debug}
  ReportMemoryLeaksOnShutdown := True;
  {$endif}
  TKing_HttpApiServer.StartService;
end.

