unit uHandlerAds;

interface

uses  System.Generics.Collections;

type
  THandlerAds = class( TObject )
    private
      type
        TAdInfo = record
          RawText: String;
          Telephone: String;
        end;

    private
      Ads: TList<TAdInfo>;

    public
      constructor Create();
      destructor Destroy(); override;

      function Load( const FileName: String ): Boolean;
  end;

implementation

uses  System.Variants, System.Win.ComObj, Vcl.Dialogs, System.SysUtils;

constructor THandlerAds.Create();
begin
  inherited Create();
  Ads := TList<TAdInfo>.Create();
end;

destructor THandlerAds.Destroy();
begin
  Ads.Free();
  inherited;
end;

function THandlerAds.Load( const FileName: String ): Boolean;
var
  WordApp,
  WordDoc: Variant;
  TableIndex,
  RowIndex,
  RowCount,
  ColIndex,
  ColCount: Integer;
  AdInfo: TAdInfo;
begin
  try
    try
      WordApp := CreateOleObject( 'Word.Application' );
      WordDoc := WordApp.Documents.Open( FileName, False, True );
      for TableIndex := 1 to WordDoc.Tables.Count do
      begin
        RowCount := WordDoc.Tables.Item( TableIndex ).Rows.Count;
        ColCount := WordDoc.Tables.Item( TableIndex ).Columns.Count;
        for RowIndex := 1 to RowCount do
          for ColIndex := 1 to ColCount do
          begin
            AdInfo.RawText := WordDoc.Tables.Item( TableIndex ).Cell( RowIndex,
              ColIndex ).Range.FormattedText;
            AdInfo.RawText := StringReplace( AdInfo.RawText, #$d#$7, '',
              [rfReplaceAll] );
            Ads.Add( AdInfo );
          end;
      end;
    except
      on EOleException do
        MessageDlg( Format( 'Не удалось открыть файл "%s"!', [FileName] ),
          mtError, [mbOK], 0 );
      on EOleSysError do
        MessageDlg( 'Не удалось запустить приложение Microsoft Word!', mtError,
          [mbOK], 0 );
    else
      raise;
    end;
  finally
    WordDoc := Unassigned();
    if not VarIsClear( WordApp ) then
      WordApp.Quit();
    WordApp := Unassigned();
  end;
end;

end.
