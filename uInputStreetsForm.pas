unit uInputStreetsForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB;

type
  TInputStreetsForm = class(TForm)
    editStreet: TEdit;
    dbgStreets: TDBGrid;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure editStreetChange(Sender: TObject);
    procedure dbgStreetsDblClick(Sender: TObject);
    procedure dbgStreetsKeyPress(Sender: TObject; var Key: Char);
    procedure editStreetKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure dbgStreetsDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
  private
    type
      TInputStages = ( isNormal, isGridOnly, isNothing );
  private
    { Private declarations }
    InputStage: TInputStages;
    Street_: String;
  public
    { Public declarations }
    function ShowModal( Street: String ): TModalResult; reintroduce;

    property Street: String read Street_;
  end;

implementation

{$R *.dfm}

uses uMainDM;

procedure TInputStreetsForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  editStreet.SetFocus();
  if ( ModalResult <> mrOk ) then
    ModalResult := mrCancel;
  MainDM.ibStreetsQ.Close();
end;

procedure TInputStreetsForm.editStreetChange(Sender: TObject);
var
  TextLength: Integer;
begin
  if ( InputStage < isNothing )then
  begin
    MainDM.ibStreetsQ.Close();
    if ( editStreet.Text <> '' ) then
      MainDM.ibStreetsQ.ParamByName( 'STREET' ).AsString := editStreet.Text
    else
       MainDM.ibStreetsQ.ParamByName( 'STREET' ).Value := NULL;
    MainDM.ibStreetsQ.Open();
    if ( not MainDM.ibStreetsQ.IsEmpty and ( InputStage < isGridOnly ) and
        ( Pos( editStreet.Text,
            MainDM.ibStreetsQ.FieldByName( 'STREET' ).AsString ) <> 0 ) ) then
    begin
      TextLength := Length( editStreet.Text );
      InputStage := isNothing;
      editStreet.Text := MainDM.ibStreetsQ.FieldByName( 'STREET' ).AsString;
      editStreet.SelStart := TextLength;
      editStreet.SelLength := Length( editStreet.Text );
    end;
  end;
  InputStage := isNormal;
end;

procedure TInputStreetsForm.editStreetKeyPress(Sender: TObject;
  var Key: Char);
begin
  if ( ( Key = Char( VK_RETURN ) ) and ( Length( editStreet.Text ) > 4 ) ) then
  begin
    Street_ := Trim( editStreet.Text );
    ModalResult := mrOk
  end;
end;

procedure TInputStreetsForm.dbgStreetsDblClick(Sender: TObject);
begin
  if not MainDM.ibStreetsQ.IsEmpty() then
  begin
    Street_ := MainDM.ibStreetsQ.FieldByName( 'STREET' ).AsString;
    ModalResult := mrOk;
  end;
end;

procedure TInputStreetsForm.dbgStreetsKeyPress(Sender: TObject;
  var Key: Char);
begin
  if ( Key = Char( VK_RETURN ) ) then
    dbgStreets.OnDblClick( dbgStreets );
end;

procedure TInputStreetsForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if editStreet.Focused() then
  begin
    if ( Key = VK_BACK ) then
    begin
      editStreet.SelStart := editStreet.SelStart - 1;
      editStreet.SelLength := Length( editStreet.Text );
      InputStage := isGridOnly;
    end else
    if ( Key = VK_DELETE ) then
      InputStage := isGridOnly;
  end;
end;

procedure TInputStreetsForm.dbgStreetsDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
const
  LEFT_OFFSET = 3;
var
  CellText: String;
  CellRect: TRect;
begin
  if ( ( gdSelected in State ) and  dbgStreets.Focused )then
    dbgStreets.Canvas.Brush.Color := clHighlight
  else
    dbgStreets.Canvas.Brush.Color := clWhite;
  dbgStreets.Canvas.FillRect( Rect );
  CellText := MainDM.ibStreetsQ.FieldByName( 'STREET' ).AsString;
  CellRect := Rect;
  CellRect.Left := CellRect.Left + LEFT_OFFSET;
  if ( MainDM.ibStreetsQ.RecordCount > 1 ) then
    CellRect.Right := CellRect.Right - GetSystemMetrics( SM_CXVSCROLL );
  DrawText( dbgStreets.Canvas.Handle, CellText, Length( CellText ), CellRect,
    DT_END_ELLIPSIS or DT_SINGLELINE or DT_VCENTER );
end;

procedure TInputStreetsForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if ( Key = Char( VK_ESCAPE ) ) then
    Close();
end;

function TInputStreetsForm.ShowModal( Street: String ): TModalResult;
begin
  ModalResult := mrNone;
  Street_ := Street;
  editStreet.Text := Street;
  editStreet.OnChange( editStreet );
  Result := inherited ShowModal();
end;

end.
