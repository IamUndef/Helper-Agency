unit uHandlerAds;

interface

uses  System.Classes, System.Generics.Collections;

type
  THandlerAds = class( TObject )
    public
      type
        TAd = class
          private
            Text_: String;
            Telephones_: TStringList;

            function GetTelephones( Index : Integer ): String;
            function GetTelephonesCount(): Integer;

          public
            constructor Create();
            destructor Destroy(); override;

            property Text: String read Text_;
            property Telephones[ Index: Integer ]: String read GetTelephones;
            property TelephonesCount: Integer read GetTelephonesCount;
        end;
    private
      const
        TELEPHONE_PATTERN : String =
          '(?:(?:8|\+\d{1,4})[\- ]?)?(?:\([\d]{3,6}\)[\- ]?)?(?:[\d]{1,})(?:[\- ]?[\d]{2,}){2,}';
    private
      Ads: TList<TAd>;

      procedure DetectTelephones( Ad: TAd );
    public
      constructor Create();
      destructor Destroy(); override;

      function Load( const FileName: String ): Boolean;
  end;

implementation

uses  System.Variants, System.Win.ComObj, Vcl.Dialogs, System.SysUtils,
      System.RegularExpressions;

constructor THandlerAds.Create();
begin
  inherited Create();
  Ads := TList<TAd>.Create();
end;

destructor THandlerAds.Destroy();
var
  AdIndex: Integer;
begin
  if Assigned( Ads ) then
  begin
    for AdIndex := 0 to Ads.Count - 1 do
      Ads[AdIndex].Free();
    Ads.Free();
  end;
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
begin
  Result := false;
  try
    try
      WordApp := CreateOleObject( 'Word.Application' );
      WordDoc := WordApp.Documents.Open( FileName, false, true );
      for TableIndex := 1 to WordDoc.Tables.Count do
      begin
        RowCount := WordDoc.Tables.Item( TableIndex ).Rows.Count;
        ColCount := WordDoc.Tables.Item( TableIndex ).Columns.Count;
        for RowIndex := 1 to RowCount do
          for ColIndex := 1 to ColCount do
          begin
            Ads.Add( TAd.Create() );
            Ads.Last().Text_ := WordDoc.Tables.Item( TableIndex ).Cell(
              RowIndex, ColIndex ).Range.FormattedText;
            Ads.Last().Text_ := TRegEx.Replace( Ads.Last().Text_, #$d#$7, '',
              [ roIgnoreCase, roMultiLine ] );
            DetectTelephones( Ads.Last() );
          end;
      end;
      Result := true;
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

procedure THandlerAds.DetectTelephones( Ad: TAd );
var
  Matchs: TMatchCollection;
  MatchIndex: Integer;
begin
  Ad.Telephones_.Clear();
  Matchs := TRegEx.Matches( Ad.Text_, TELEPHONE_PATTERN,
    [roIgnoreCase, roMultiLine] );
  for MatchIndex := 0 to Matchs.Count - 1 do
    Ad.Telephones_.Add( Matchs.Item[MatchIndex].Value );
end;

constructor THandlerAds.TAd.Create();
begin
  inherited Create();
  Telephones_ := TStringList.Create();
end;

destructor THandlerAds.TAd.Destroy();
begin
  if Assigned( Telephones_ ) then
    Telephones_.Free();
  inherited;
end;

function THandlerAds.TAd.GetTelephones( Index: Integer ): String;
begin
  Result := '';
  if ( ( Index >= 0 ) and ( Index < Telephones_.Count ) ) then
    Result := Telephones_[Index];
end;

function THandlerAds.TAd.GetTelephonesCount(): Integer;
begin
  Result := Telephones_.Count;
end;

end.
