unit uEditForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ActnList, Vcl.ActnMan, Vcl.ExtCtrls, Vcl.ImgList, Vcl.ToolWin,
  Vcl.ActnCtrls, Vcl.StdCtrls, Vcl.StdStyleActnCtrls, Vcl.ComCtrls, Vcl.Buttons,
  PngSpeedButton, PngImageList, uInputStreetsForm, uInputTelephonesForm;

type
  TEditForm = class(TForm)
    amMain: TActionManager;
    ilMain: TImageList;
    aOk: TAction;
    aCancel: TAction;
    alButton: TActionList;
    pilButton: TPngImageList;
    aAdd: TAction;
    aDel: TAction;
    aChange: TAction;
    pRight: TPanel;
    atbRightTop: TActionToolBar;
    atbRightBottom: TActionToolBar;
    pMain: TPanel;
    gbText: TGroupBox;
    mText: TMemo;
    gbData: TGroupBox;
    lRoomsCount: TLabel;
    editRoomsCount: TEdit;
    lStreet: TLabel;
    editStreet: TEdit;
    lTelephones: TLabel;
    lbTelephones: TListBox;
    psbAdd: TPngSpeedButton;
    psbDel: TPngSpeedButton;
    psbChange: TPngSpeedButton;
    procedure FormDestroy(Sender: TObject);
    procedure aOkExecute(Sender: TObject);
    procedure aCancelExecute(Sender: TObject);
    procedure aAddExecute(Sender: TObject);
    procedure aDelExecute(Sender: TObject);
    procedure aChangeExecute(Sender: TObject);
    procedure editStreetEnter(Sender: TObject);
    procedure editStreetExit(Sender: TObject);
    procedure editStreetKeyPress(Sender: TObject; var Key: Char);
    procedure lbTelephonesDblClick(Sender: TObject);
    procedure lbTelephonesKeyPress(Sender: TObject; var Key: Char);
    procedure lbTelephonesDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  private
    { Private declarations }
    InputStreetsForm: TInputStreetsForm;
    InputTelephonesForm: TInputTelephonesForm;
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TEditForm.FormDestroy(Sender: TObject);
begin
  if Assigned( InputStreetsForm ) then
    InputStreetsForm.Free();
  if Assigned( InputTelephonesForm ) then
    InputTelephonesForm.Free();
end;

procedure TEditForm.aOkExecute(Sender: TObject);
begin
//
end;

procedure TEditForm.aCancelExecute(Sender: TObject);
begin
//
end;

procedure TEditForm.aAddExecute(Sender: TObject);
begin
  if not Assigned( InputTelephonesForm ) then
    InputTelephonesForm := TInputTelephonesForm.Create( Self );
  if ( ( InputTelephonesForm.ShowModal( '' ) = mrOk ) and
      ( lbTelephones.Items.IndexOf(
          InputTelephonesForm.Telephone ) = -1 ) ) then
  begin
    lbTelephones.ItemIndex :=
      lbTelephones.Items.Add( InputTelephonesForm.Telephone );
    lbTelephones.SetFocus();
  end;
end;

procedure TEditForm.aDelExecute(Sender: TObject);
begin
  if ( lbTelephones.Count = 1 ) then
    MessageBox( Handle, 'Список телефон не должен быть пустым!',
      'Helper Agency', MB_ICONINFORMATION )
  else if ( ( lbTelephones.ItemIndex <> -1 ) and ( IDYES = MessageBox( Handle,
      'Вы действительно хотите удалить выбранный телефон?', 'Helper Agency',
      MB_ICONWARNING or MB_YESNO or MB_DEFBUTTON2 ) ) ) then
    lbTelephones.Items.Delete( lbTelephones.ItemIndex );
end;

procedure TEditForm.aChangeExecute(Sender: TObject);
begin
  if ( lbTelephones.ItemIndex <> -1 ) then
  begin
    if not Assigned( InputTelephonesForm ) then
      InputTelephonesForm := TInputTelephonesForm.Create( Self );
    if ( ( InputTelephonesForm.ShowModal(
            lbTelephones.Items[lbTelephones.ItemIndex] ) = mrOk ) and
        ( lbTelephones.Items.IndexOf(
            InputTelephonesForm.Telephone ) = -1 ) ) then
      lbTelephones.Items[lbTelephones.ItemIndex] :=
        InputTelephonesForm.Telephone;
  end;
end;

procedure TEditForm.editStreetEnter(Sender: TObject);
begin
  editStreet.Color := clFuchsia;
end;

procedure TEditForm.editStreetExit(Sender: TObject);
begin
  editStreet.Color := clWhite;
end;

procedure TEditForm.editStreetKeyPress(Sender: TObject; var Key: Char);
begin
  if ( Key = Char( VK_RETURN ) ) then
  begin
    if not Assigned( InputStreetsForm ) then
      InputStreetsForm := TInputStreetsForm.Create( Self );
    if ( InputStreetsForm.ShowModal( editStreet.Text ) = mrOk ) then
      editStreet.Text := InputStreetsForm.Street;
  end;
end;

procedure TEditForm.lbTelephonesDblClick(Sender: TObject);
begin
  aChange.Execute();
end;

procedure TEditForm.lbTelephonesKeyPress(Sender: TObject; var Key: Char);
begin
  if ( Key = Char( VK_RETURN ) ) then
    aChange.Execute();
end;

procedure TEditForm.lbTelephonesDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
  lbTelephones.Canvas.FillRect( Rect );
  DrawText( lbTelephones.Canvas.Handle, lbTelephones.Items[Index],
    Length( lbTelephones.Items[Index] ), Rect, DT_END_ELLIPSIS or DT_RIGHT or
    DT_SINGLELINE or DT_VCENTER );
end;

end.
