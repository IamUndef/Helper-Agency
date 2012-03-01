unit uInputTelephonesForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB, uHandlerAds;

type
  TInputTelephonesForm = class(TForm)
    editTelephone: TEdit;
    dbgTelephones: TDBGrid;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure editTelephoneChange(Sender: TObject);
    procedure editTelephoneKeyPress(Sender: TObject; var Key: Char);
    procedure dbgTelephonesDblClick(Sender: TObject);
    procedure dbgTelephonesKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure dbgTelephonesDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
  private
    type
      TInputStages = ( isNormal, isGridOnly, isNothing );
  private
    { Private declarations }
    Telephone_: String;
    Kind_: THandlerAds.TAdKind;
    InputStage: TInputStages;
  public
    { Public declarations }
    function ShowModal( Telephone: String;
      Kind: THandlerAds.TAdKind ): TModalResult; reintroduce;

    property Telephone: String read Telephone_;
    property Kind: THandlerAds.TAdKind read Kind_;
  end;
implementation

{$R *.dfm}

uses uMainDM;

procedure TInputTelephonesForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  TelephoneInt: Int64;
begin
  editTelephone.SetFocus();
  if ( ( ModalResult = mrOk ) and
      not TryStrToInt64( Telephone_, TelephoneInt ) ) then
  begin
    CanClose := false;
    MessageBox( Handle, 'Неверное значение номера телефона!', 'Helper Agency',
      MB_ICONERROR or MB_OK );
  end else
  begin
    if ( ModalResult <> mrOk ) then
      ModalResult := mrCancel;
    MainDM.ibTelephonesQ.Close();
  end;
end;

procedure TInputTelephonesForm.editTelephoneChange(Sender: TObject);
var
  TextLength: Integer;
begin
  if ( InputStage < isNothing )then
  begin
    MainDM.ibTelephonesQ.Close();
    if ( editTelephone.Text <> '' ) then
      MainDM.ibTelephonesQ.ParamByName( 'TELEPHONE' ).AsString :=
        editTelephone.Text
    else
      MainDM.ibTelephonesQ.ParamByName( 'TELEPHONE' ).Value := NULL;
    MainDM.ibTelephonesQ.Open();
    if ( not MainDM.ibTelephonesQ.IsEmpty and ( InputStage < isGridOnly ) ) then
    begin
      TextLength := Length( editTelephone.Text );
      InputStage := isNothing;
      editTelephone.Text :=
        MainDM.ibTelephonesQ.FieldByName( 'TELEPHONE' ).AsString;
      editTelephone.SelStart := TextLength;
      editTelephone.SelLength := Length( editTelephone.Text );
    end;
  end;
  InputStage := isNormal;
end;

procedure TInputTelephonesForm.editTelephoneKeyPress(Sender: TObject;
  var Key: Char);
begin
  if ( ( Key = Char( VK_RETURN ) ) and
      ( Length( editTelephone.Text ) > 4 ) ) then
  begin
    Telephone_ := editTelephone.Text;
    if ( Telephone_ = MainDM.ibTelephonesQ.FieldByName(
        'TELEPHONE' ).AsString ) then
      Kind_ := THandlerAds.TAdKind(
        MainDM.ibTelephonesQ.FieldByName( 'KIND' ).AsInteger )
    else
      Kind_ := akNone;
    ModalResult := mrOk
  end else
  if ( ( editTelephone.SelStart = 0 ) and ( Key <> Char( VK_BACK ) ) ) then
  begin
    if ( ( Key = '+' ) and ( ( editTelephone.Text = '' ) or
        ( editTelephone.Text[1] <> '+' ) ) ) then
    begin
      Key := #0;
      editTelephone.Text := '+' + editTelephone.Text;
      if MainDM.ibTelephonesQ.IsEmpty() then
        editTelephone.SelStart := 1;
    end else
    if ( ( editTelephone.Text <> '' ) and ( editTelephone.Text[1] = '+' ) ) then
      Key := #0;
  end;
end;

procedure TInputTelephonesForm.dbgTelephonesDblClick(Sender: TObject);
begin
  if not MainDM.ibTelephonesQ.IsEmpty() then
  begin
    Telephone_ := MainDM.ibTelephonesQ.FieldByName( 'TELEPHONE' ).AsString;
    Kind_ := THandlerAds.TAdKind(
      MainDM.ibTelephonesQ.FieldByName( 'KIND' ).AsInteger );
    ModalResult := mrOk;
  end;
end;

procedure TInputTelephonesForm.dbgTelephonesKeyPress(Sender: TObject;
  var Key: Char);
begin
  if ( Key = Char( VK_RETURN ) ) then
    dbgTelephones.OnDblClick( dbgTelephones );
end;

procedure TInputTelephonesForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if editTelephone.Focused() then
  begin
    if ( Key = VK_BACK ) then
    begin
      editTelephone.SelStart := editTelephone.SelStart - 1;
      editTelephone.SelLength := Length( editTelephone.Text );
      InputStage := isGridOnly;
    end else
    if ( Key = VK_DELETE ) then
      InputStage := isGridOnly;
  end;
end;

procedure TInputTelephonesForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if ( Key = Char( VK_ESCAPE ) ) then
    Close();
end;

procedure TInputTelephonesForm.dbgTelephonesDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
const
  AdKindColors: array[THandlerAds.TAdKind] of TColor =
    ( clSilver, clBlack, clRed );
  LEFT_OFFSET = 3;
var
  CellText: String;
  CellRect: TRect;
begin
  dbgTelephones.Canvas.Font.Color := AdKindColors[THandlerAds.TAdKind(
    MainDM.ibTelephonesQ.FieldByName( 'KIND' ).AsInteger )];
  if ( ( gdSelected in State ) and  dbgTelephones.Focused )then
    dbgTelephones.Canvas.Brush.Color := clHighlight
  else
    dbgTelephones.Canvas.Brush.Color := clWhite;
  dbgTelephones.Canvas.FillRect( Rect );
  CellText := MainDM.ibTelephonesQ.FieldByName( 'TELEPHONE' ).AsString;
  CellRect := Rect;
  CellRect.Left := CellRect.Left + LEFT_OFFSET;
  if ( MainDM.ibTelephonesQ.RecordCount > 1 ) then
    CellRect.Right := CellRect.Right - GetSystemMetrics( SM_CXVSCROLL );
  DrawText( dbgTelephones.Canvas.Handle, CellText, Length( CellText ), CellRect,
    DT_END_ELLIPSIS or DT_SINGLELINE or DT_VCENTER );
end;

function TInputTelephonesForm.ShowModal( Telephone: String;
  Kind: THandlerAds.TAdKind ): TModalResult;
begin
  ModalResult := mrNone;
  Telephone_ := Telephone;
  Kind_ := Kind;
  editTelephone.Text := Telephone;
  editTelephone.OnChange( editTelephone );
  Result := inherited ShowModal();
end;

end.
