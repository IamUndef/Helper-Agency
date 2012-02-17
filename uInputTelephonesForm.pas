unit uInputTelephonesForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB;

type
  TInputTelephonesForm = class(TForm)
    editTelephone: TEdit;
    dbgTelephones: TDBGrid;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure editTelephoneChange(Sender: TObject);
    procedure dbgTelephonesDblClick(Sender: TObject);
    procedure dbgTelephonesKeyPress(Sender: TObject; var Key: Char);
    procedure editTelephoneKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure dbgTelephonesDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
  private
    { Private declarations }
    Telephone_: String;
  public
    { Public declarations }
    function ShowModal( Telephone: String ): TModalResult; reintroduce;

    property Telephone: String read Telephone_;
  end;

implementation

{$R *.dfm}

uses uMainDM, uHandlerAds;

procedure TInputTelephonesForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  editTelephone.SetFocus();
  if ( ModalResult <> mrOk ) then
    ModalResult := mrCancel;
  MainDM.ibTelephonesQ.Close();
end;

procedure TInputTelephonesForm.editTelephoneChange(Sender: TObject);
begin
  MainDM.ibTelephonesQ.Close();
  if ( editTelephone.Text <> '' ) then
    MainDM.ibTelephonesQ.ParamByName( 'TELEPHONE' ).AsString :=
      editTelephone.Text
  else
    MainDM.ibTelephonesQ.ParamByName( 'TELEPHONE' ).Value := NULL;
  MainDM.ibTelephonesQ.Open();
end;

procedure TInputTelephonesForm.editTelephoneKeyPress(Sender: TObject;
  var Key: Char);
begin
  if ( ( Key = Char( VK_RETURN ) ) and
      ( Length( editTelephone.Text ) > 4 ) ) then
  begin
    Telephone_ := editTelephone.Text;
    ModalResult := mrOk
  end else
  if ( editTelephone.SelStart = 0 ) then
  begin
    if ( ( Key = '+' ) and ( ( editTelephone.Text = '' ) or
        ( editTelephone.Text[1] <> '+' ) ) ) then
    begin
      Key := #0;
      editTelephone.Text := '+' + editTelephone.Text;
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
    ModalResult := mrOk;
  end;
end;

procedure TInputTelephonesForm.dbgTelephonesKeyPress(Sender: TObject;
  var Key: Char);
begin
  if ( Key = Char( VK_RETURN ) ) then
    dbgTelephones.OnDblClick( dbgTelephones );
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
begin
  dbgTelephones.Canvas.Font.Color := AdKindColors[THandlerAds.TAdKind(
    MainDM.ibTelephonesQ.FieldByName( 'KIND' ).AsInteger )];
  if ( gdSelected in State ) then
    dbgTelephones.Canvas.Brush.Color := clHighlight;
  dbgTelephones.DefaultDrawColumnCell( Rect, DataCol, Column, State );
end;

function TInputTelephonesForm.ShowModal( Telephone: String ): TModalResult;
begin
  ModalResult := mrNone;
  Telephone_ := Telephone;
  editTelephone.Text := Telephone;
  editTelephone.OnChange( editTelephone );
  Result := inherited ShowModal();
end;

end.
