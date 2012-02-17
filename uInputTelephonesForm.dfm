object InputTelephonesForm: TInputTelephonesForm
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = #1042#1074#1086#1076' '#1090#1077#1083#1077#1092#1086#1085#1072
  ClientHeight = 216
  ClientWidth = 214
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = [fsBold]
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object editTelephone: TEdit
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 208
    Height = 21
    Align = alTop
    MaxLength = 20
    NumbersOnly = True
    TabOrder = 0
    OnChange = editTelephoneChange
    OnKeyPress = editTelephoneKeyPress
  end
  object dbgTelephones: TDBGrid
    AlignWithMargins = True
    Left = 3
    Top = 30
    Width = 208
    Height = 183
    Align = alClient
    DataSource = MainDM.dsTelephones
    DefaultDrawing = False
    Options = [dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ReadOnly = True
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = [fsBold]
    OnDrawColumnCell = dbgTelephonesDrawColumnCell
    OnDblClick = dbgTelephonesDblClick
    OnKeyPress = dbgTelephonesKeyPress
    Columns = <
      item
        Expanded = False
        FieldName = 'TELEPHONE'
        Title.Alignment = taCenter
        Title.Caption = #1058#1077#1083#1077#1092#1086#1085#1099
        Width = 192
        Visible = True
      end>
  end
end
