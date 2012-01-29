program HelperAgency;

uses
  Vcl.Forms,
  uMainForm in 'uMainForm.pas' {Form1},
  uHandlerAds in 'uHandlerAds.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
