
program miniclient_fpc;
/// {$MODE Delphi}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Forms, Interfaces, //MainUnit
  MainUnit in 'MainUnit.pas' {MainForm},
  connparams, LoginUnit//,
  //minidelphimain in 'minidelphimain.pas' {Form7},
  //,miniscriptcontroller in 'miniscriptcontroller.pas'//,
  //mormothttps in 'mormothttps.pas'
  ;

//{.$R minidelphiFrame.res}

var
  URL: string;

{$R *.res}

begin
  {$if declared(UseHeapTrace)}
  GlobalSkipIfNoLeaks := true; // supported as of debugger version 3.2.0
  {$endIf}
  Application.Initialize;
  Application.MainFormOnTaskbar := true;

  Tconnparam.LoadFromFile(URL);
  if URL = '' then
  begin
    connparam := Tconnparam.Create(Application);
    try
      if connparam.ShowModal <> 1 then exit;
    finally
      connparam.free;
    end;
    Tconnparam.LoadFromFile(URL);
  end;

  Tconnparam.URLToClientParam(URL);
  login := Tlogin.Create(Application);
  try
    if login.ShowModal <> 1 then exit;
  finally
    login.Free;
  end;     //}
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
