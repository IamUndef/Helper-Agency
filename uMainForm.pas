unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus,
  Vcl.ActnList, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnMan, Vcl.ExtDlgs;

type
  TForm1 = class( TForm )
    amMain: TActionManager;
    reAds: TRichEdit;
    aExit: TAction;
    aLoad: TAction;
    mmMain: TMainMenu;
    miFile: TMenuItem;
    miLoad: TMenuItem;
    miExit: TMenuItem;
    odMain: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure aLoadExecute(Sender: TObject);
    procedure aExitExecute(Sender: TObject);
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

procedure TForm1.FormCreate(Sender: TObject);
begin
//
end;

procedure TForm1.aLoadExecute(Sender: TObject);
var
  HandlerAds: THandlerAds;
  AdIndex,
  TelIndex,
  OldSelStart: Integer;
begin
  if odMain.Execute() then
  begin
    HandlerAds := NIL;
    try
      HandlerAds := THandlerAds.Create();
      OldSelStart := 0;
      if HandlerAds.Load( odMain.FileName ) then
      begin
        for AdIndex := 0 to HandlerAds.AdsCount - 1 do
          reAds.Lines.Add( Format( '%d. %s',
            [AdIndex + 1, HandlerAds.Ads[AdIndex].Text + sLineBreak] ) );
        for AdIndex := 0 to HandlerAds.AdsCount - 1 do
          for TelIndex := 0 to HandlerAds.Ads[AdIndex].TelephonesCount - 1 do
          begin
            reAds.SelStart := reAds.FindText(
              HandlerAds.Ads[AdIndex].Telephones[TelIndex], OldSelStart,
              Length( reAds.Text ), [] );
            reAds.SelLength :=
              Length( HandlerAds.Ads[AdIndex].Telephones[TelIndex] );
            reAds.SelAttributes.Color := clRed;
            reAds.SelAttributes.Style := [fsBold];
            OldSelStart := reAds.SelStart + reAds.SelLength;
          end;
      end;
      reAds.SelLength := 0;
    finally
      if Assigned( HandlerAds ) then
        HandlerAds.Free();
    end;
  end;
end;

procedure TForm1.aExitExecute(Sender: TObject);
begin
  Close();
end;

end.
