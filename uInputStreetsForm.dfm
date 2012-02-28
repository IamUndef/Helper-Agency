object InputStreetsForm: TInputStreetsForm
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = #1042#1074#1086#1076' '#1091#1083#1080#1094#1099
  ClientHeight = 216
  ClientWidth = 294
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
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object editStreet: TEdit
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 288
    Height = 21
    Align = alTop
    CharCase = ecUpperCase
    MaxLength = 50
    TabOrder = 0
    OnChange = editStreetChange
    OnKeyPress = editStreetKeyPress
    ExplicitWidth = 208
  end
  object dbgStreets: TDBGrid
    AlignWithMargins = True
    Left = 3
    Top = 30
    Width = 288
    Height = 183
    Align = alClient
    DataSource = MainDM.dsStreets
    DefaultDrawing = False
    Options = [dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ReadOnly = True
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = [fsBold]
    OnDrawColumnCell = dbgStreetsDrawColumnCell
    OnDblClick = dbgStreetsDblClick
    OnKeyPress = dbgStreetsKeyPress
    Columns = <
      item
        Expanded = False
        FieldName = 'STREET'
        Title.Alignment = taCenter
        Title.Caption = #1059#1083#1080#1094#1099
        Width = 272
        Visible = True
      end>
  end
end
