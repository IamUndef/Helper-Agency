unit uEditForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ActnList, Vcl.ActnMan, Vcl.ExtCtrls, Vcl.ImgList, Vcl.ToolWin,
  Vcl.ActnCtrls, Vcl.StdCtrls, Vcl.StdStyleActnCtrls, Vcl.ComCtrls, Vcl.Buttons,
  PngSpeedButton, PngImageList;

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
    lvTelephones: TListView;
    editTelephone: TEdit;
    psbAdd: TPngSpeedButton;
    psbDel: TPngSpeedButton;
    psbChange: TPngSpeedButton;
    procedure aOkExecute(Sender: TObject);
    procedure aCancelExecute(Sender: TObject);
    procedure aDelExecute(Sender: TObject);
    procedure aAddExecute(Sender: TObject);
    procedure aChangeExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TEditForm.aAddExecute(Sender: TObject);
begin
//
end;

procedure TEditForm.aCancelExecute(Sender: TObject);
begin
//
end;

procedure TEditForm.aChangeExecute(Sender: TObject);
begin
//
end;

procedure TEditForm.aDelExecute(Sender: TObject);
begin
//
end;

procedure TEditForm.aOkExecute(Sender: TObject);
begin
//
end;

end.
