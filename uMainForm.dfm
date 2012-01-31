object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 412
  ClientWidth = 550
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = mmMain
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object reAds: TRichEdit
    Left = 0
    Top = 0
    Width = 550
    Height = 412
    Align = alClient
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object amMain: TActionManager
    Left = 512
    Top = 40
    StyleName = 'Platform Default'
    object aExit: TAction
      Caption = #1042#1099#1093#1086#1076
      ShortCut = 27
      OnExecute = aExitExecute
    end
    object aLoad: TAction
      Caption = #1047#1072#1075#1088#1091#1079#1082#1072
      OnExecute = aLoadExecute
    end
  end
  object mmMain: TMainMenu
    Left = 472
    Top = 40
    object miFile: TMenuItem
      Caption = #1060#1072#1081#1083
      object miLoad: TMenuItem
        Action = aLoad
      end
      object miExit: TMenuItem
        Action = aExit
      end
    end
  end
  object odMain: TOpenDialog
    Filter = #1044#1086#1082#1091#1084#1077#1085#1090' Microsoft Word|*.doc;*.docx'
    Left = 512
    Top = 88
  end
end
