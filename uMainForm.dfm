object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Helper Agency'
  ClientHeight = 216
  ClientWidth = 426
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = [fsBold]
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object bTest: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'bTest'
    TabOrder = 0
    OnClick = bTestClick
  end
end
