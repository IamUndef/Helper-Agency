program HelperAgency;

uses
  Vcl.Forms,
  uMainForm in 'uMainForm.pas' {MainForm},
  uInputForm in 'uInputForm.pas' {InputForm},
  uEditForm in 'uEditForm.pas' {EditForm},
  uInputTelephonesForm in 'uInputTelephonesForm.pas' {InputTelephonesForm},
  uMainDM in 'uMainDM.pas' {MainDM: TDataModule},
  uHandlerAds in 'uHandlerAds.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TMainDM, MainDM);
  Application.Run;
end.
