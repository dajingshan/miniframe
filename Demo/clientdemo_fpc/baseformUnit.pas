unit baseformUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, mormot.net.client, ExtCtrls,
  Buttons, StdCtrls;

type

  { Tbaseform }

  Tbaseform = class(TForm)
    plMain: TPanel;
    plTopBar: TPanel;
    lbtitle: TLabel;
    btnRightBtns: TPanel;
    imMin: TImage;
    imMax: TImage;
    imClose: TImage;
    procedure plTopBarMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imMinClick(Sender: TObject);
    procedure imMaxClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure imCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    ///Procedure CreateParams(var Params :TCreateParams);override;
  end;

var
  baseform: Tbaseform;

implementation

{$R *.dfm}
           {
procedure Tbaseform.CreateParams(var Params: TCreateParams);
begin
  inherited  CreateParams(Params);
  if BorderStyle = bsNone then
  with Params do
    Style := Style;// or WS_EX_CLIENTEDGE or WS_BORDER;// WS_THICKFRAME;
end;       }

procedure Tbaseform.FormResize(Sender: TObject);
begin
  btnRightBtns.Left := plTopBar.Width - btnRightBtns.Width - 5;
end;

procedure Tbaseform.FormShow(Sender: TObject);
begin
  FormResize(Sender);
end;

procedure Tbaseform.imCloseClick(Sender: TObject);
begin
  Close;
end;

procedure Tbaseform.imMaxClick(Sender: TObject);
begin
  if windowstate = wsmaximized then
    windowstate := TWindowState.wsNormal
  else
    windowstate := TWindowState.wsmaximized;
end;

procedure Tbaseform.imMinClick(Sender: TObject);
begin
  ShowWindow(Handle, SW_MINIMIZE);
end;

procedure Tbaseform.plTopBarMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if button= TMouseButton.mbLeft then
  begin
    ReleaseCapture;
    SendMessage(Handle, WM_syscommand, $f012,0);
  end;
end;

end.
