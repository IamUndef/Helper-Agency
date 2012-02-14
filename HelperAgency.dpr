program HelperAgency;

uses
  Vcl.Forms,
  uMainForm in 'uMainForm.pas' {MainForm},
  uInputForm in 'uInputForm.pas' {InputForm},
  uHandlerAds in 'uHandlerAds.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
