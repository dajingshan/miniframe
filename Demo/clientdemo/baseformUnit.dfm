object baseform: Tbaseform
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'baseform'
  ClientHeight = 427
  ClientWidth = 546
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object plMain: TPanel
    Left = 0
    Top = 0
    Width = 546
    Height = 427
    Align = alClient
    Color = clWindow
    ParentBackground = False
    TabOrder = 0
    object plTopBar: TPanel
      Left = 1
      Top = 1
      Width = 544
      Height = 40
      Align = alTop
      BevelOuter = bvNone
      Color = 16745481
      ParentBackground = False
      TabOrder = 0
      OnMouseDown = plTopBarMouseDown
      object lbtitle: TLabel
        Left = 16
        Top = 7
        Width = 64
        Height = 21
        Caption = #31383#21475#26631#39064
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        OnMouseDown = plTopBarMouseDown
      end
      object btnRightBtns: TPanel
        Left = 456
        Top = 10
        Width = 73
        Height = 19
        BevelOuter = bvNone
        ParentColor = True
        TabOrder = 0
        OnMouseDown = plTopBarMouseDown
        object imMin: TImage
          AlignWithMargins = True
          Left = 12
          Top = 3
          Width = 14
          Height = 13
          Cursor = crHandPoint
          Margins.Left = 5
          Align = alRight
          Picture.Data = {
            0D546478536D617274496D61676547494638396120002000910000000000FFFF
            FFFAAE22FFFFFF21F90401000003002C000000002000200000022B9C8FA9CBED
            0FA39CB4DA8BB3DEBCFB0F86E2489626279C59C0B6EE0BC7484CD7EE6CE7B0CA
            F7FE0FEC1400003B}
          Stretch = True
          OnClick = imMinClick
          ExplicitLeft = 33
          ExplicitHeight = 17
        end
        object imMax: TImage
          AlignWithMargins = True
          Left = 34
          Top = 3
          Width = 14
          Height = 13
          Cursor = crHandPoint
          Margins.Left = 5
          Align = alRight
          Picture.Data = {
            0D546478536D617274496D61676547494638396120002000910000000000FFFF
            FFFAAE22FFFFFF21F90401000003002C00000000200020000002589C8FA9CBED
            1FA29CB4DA68AEDE32F35F79C1437622096127DA9883CB2A2E1C23B35A27F798
            EB38DDDBF57CBC176E682C027342E42AE97C2E6B4D8480FA3B0EAB48EE365BEC
            82A3D0A758A90D82416C111BE47E73C8F45C01003B}
          Stretch = True
          OnClick = imMaxClick
          ExplicitLeft = 56
          ExplicitHeight = 17
        end
        object imClose: TImage
          AlignWithMargins = True
          Left = 56
          Top = 3
          Width = 14
          Height = 13
          Cursor = crHandPoint
          Margins.Left = 5
          Align = alRight
          Picture.Data = {
            0D546478536D617274496D61676547494638396120002000910000000000FFFF
            FFFFFFFF00000021F90401000002002C000000002000200000025D948FA9CBED
            2F820C704D3565451967BA7D96087DA0D739A64A8E29FB72EDB3CA7139CF21A9
            6F9179F319801AA12B683CF492C31A53497C362FCB4AAB0A2B422FBE253681FD
            4EB58CAF787C0223CBC1B39A8B66C6D6B8F4CF2ECDEB9F05003B}
          Stretch = True
          OnClick = imCloseClick
          ExplicitLeft = 79
          ExplicitHeight = 17
        end
      end
    end
  end
end
