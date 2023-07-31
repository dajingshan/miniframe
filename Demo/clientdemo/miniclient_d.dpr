program miniclient_d;

uses
  Vcl.Forms,
  LoginUnit in 'LoginUnit.pas' {login},
  connparams in 'connparams.pas' {connparam},
  baseformUnit in 'baseformUnit.pas' {baseform},
  clientpub in 'clientpub.pas',
  MainUnit in 'MainUnit.pas' {MainForm};

{$R *.res}
var
  URL: string;
begin
  Application.Initialize;
  Application.MainFormOnTaskbar := false;

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
  login := Tlogin.Create(nil);
  try
    if login.ShowModal <> 1 then exit;
  finally
    login.Free;
  end;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;

end.
