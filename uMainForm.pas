unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TMainForm = class( TForm )
    procedure FormCreate( Sender: TObject );
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses uInputForm;

procedure TMainForm.FormCreate( Sender: TObject );
var
  InputForm: TInputForm;
begin
  InputForm := TInputForm.Create( NIL );
  try
    InputForm.ShowModal( 'C:\Temp\Doc1.docx' );
  finally
    InputForm.Free();
  end;
end;

end.
