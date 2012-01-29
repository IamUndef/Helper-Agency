unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TForm1 = class( TForm )
    procedure FormCreate( Sender: TObject );
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses uHandlerAds;

procedure TForm1.FormCreate( Sender: TObject );
var
  Test: THandlerAds;
begin
  Test := NIL;
  try
    Test := THandlerAds.Create();
    Test.Load( 'c:\temp\doc1.docx' );
  finally
    if Assigned( Test ) then
      Test.Free();
  end;
end;

end.
