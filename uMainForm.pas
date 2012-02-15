unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls;

type
  TMainForm = class( TForm )
    bTest: TButton;
    procedure FormCreate( Sender: TObject );
    procedure bTestClick(Sender: TObject);
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

procedure TMainForm.bTestClick(Sender: TObject);
const
  UserNameDB : String = 'user_name=GUEST';
  PasswordDB : String = 'password=GUEST';
var
  InputForm: TInputForm;
begin
  InputForm := NIL;
  MainDM.ibDatabase.Params.Add( UserNameDB );
  MainDM.ibDatabase.Params.Add( PasswordDB );
  MainDM.ibDatabase.Connected := true;
  if MainDM.ibDatabase.Connected then
    try
      MainDM.ibTransaction.Active := true;
      InputForm := TInputForm.Create( NIL );
      InputForm.ShowModal( 'C:\Temp\Doc1.docx' );
    finally
      if Assigned( InputForm ) then
        InputForm.Free();
      MainDM.ibDatabase.Connected := false;
    end;
end;

procedure TMainForm.FormCreate( Sender: TObject );
begin
//
end;

end.
