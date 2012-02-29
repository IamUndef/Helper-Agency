program HelperAgency;

uses
  Vcl.Forms,
  uMainForm in 'uMainForm.pas' {MainForm},
  uMainDM in 'uMainDM.pas' {MainDM: TDataModule},
  uInputForm in 'uInputForm.pas' {InputForm},
  uEditForm in 'uEditForm.pas' {EditForm},
  uInputTelephonesForm in 'uInputTelephonesForm.pas' {InputTelephonesForm},
  uInputStreetsForm in 'uInputStreetsForm.pas' {InputStreetsForm},
  uHandlerAds in 'uHandlerAds.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TMainDM, MainDM);
  Application.Run;
end.
