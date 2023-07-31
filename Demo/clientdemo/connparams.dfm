inherited connparam: Tconnparam
  Caption = #36830#25509#21442#25968
  ClientHeight = 323
  ClientWidth = 452
  OnCreate = FormCreate
  ExplicitWidth = 452
  ExplicitHeight = 323
  PixelsPerInch = 96
  TextHeight = 15
  inherited plMain: TPanel
    Width = 452
    Height = 323
    ExplicitWidth = 452
    ExplicitHeight = 323
    object lblMsg: TLabel [0]
      Left = 48
      Top = 158
      Width = 249
      Height = 121
      AutoSize = False
      Caption = 'msg'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -14
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
      WordWrap = True
    end
    object Label1: TLabel [1]
      Left = 48
      Top = 80
      Width = 48
      Height = 15
      Caption = #26381#21153#22320#22336
    end
    inherited plTopBar: TPanel
      Width = 450
      ExplicitWidth = 450
      inherited lbtitle: TLabel
        Caption = #36830#25509#21442#25968
      end
    end
    object edtUrl: TEdit
      Left = 104
      Top = 77
      Width = 241
      Height = 23
      TabOrder = 1
      Text = '127.0.0.1:899'
    end
    object Panel1: TPanel
      Left = 336
      Top = 229
      Width = 105
      Height = 35
      Color = 16745481
      ParentBackground = False
      TabOrder = 2
      object Label4: TLabel
        Left = 1
        Top = 1
        Width = 103
        Height = 33
        Cursor = crHandPoint
        Align = alClient
        Alignment = taCenter
        Caption = #30830#23450
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindow
        Font.Height = -15
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
        OnClick = Label4Click
        ExplicitWidth = 30
        ExplicitHeight = 20
      end
    end
  end
end
