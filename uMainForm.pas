unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ActnList, Vcl.ToolWin, Vcl.ActnMan, Vcl.ActnCtrls,
  Vcl.ImgList, Vcl.StdStyleActnCtrls, VirtualTrees;

type
  TMainForm = class( TForm )
    amMain: TActionManager;
    ilMain: TImageList;
    atbTop: TActionToolBar;
    aClose: TAction;
    aAdd: TAction;
    odMain: TOpenDialog;
    gbMain: TGroupBox;
    vstAdsList: TVirtualStringTree;
    procedure FormCreate( Sender: TObject );
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure aCloseExecute(Sender: TObject);
    procedure aAddExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses uMainDM, uInputForm;

procedure TMainForm.FormCreate( Sender: TObject );
begin
//
end;

procedure TMainForm.FormShow(Sender: TObject);
const
  UserNameDB : String = 'user_name=GUEST';
  PasswordDB : String = 'password=GUEST';
begin
  MainDM.ibDatabase.Params.Add( UserNameDB );
  MainDM.ibDatabase.Params.Add( PasswordDB );
  MainDM.ibDatabase.Connected := true;
  MainDM.ibTransaction.Active := true;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  MainDM.ibDatabase.Connected := false;
end;

procedure TMainForm.aCloseExecute(Sender: TObject);
begin
  Close();
end;

procedure TMainForm.aAddExecute(Sender: TObject);
var
  InputForm: TInputForm;
begin
  InputForm := NIL;
  if MainDM.ibDatabase.Connected and odMain.Execute() then
    try
      InputForm := TInputForm.Create( NIL );
      InputForm.ShowModal( odMain.FileName );
    finally
      if Assigned( InputForm ) then
        InputForm.Free();
    end;
end;



end.
