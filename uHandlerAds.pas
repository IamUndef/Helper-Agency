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

            function GetTelephone( Index : Integer ): String;
            function GetTelephonesCount(): Integer;
          public
            constructor Create();
            destructor Destroy(); override;

            property Text: String read Text_;
            property Telephones[ Index: Integer ]: String read GetTelephone;
            property TelephonesCount: Integer read GetTelephonesCount;
        end;
    private
      const
        TELEPHONE_PATTERN : String =
          '(?:(?:8|\+\d{1,4})[\- ]?)?(?:\([\d]{3,6}\)[\- ]?)?(?:[\d]{1,})(?:[\- ]?[\d]{2,}){2,}';
    private
      Ads_: TList<TAd>;

      procedure Clear( IsDestroy: Boolean = false );

      function GetAd( Index: Integer ): TAd;
      function GetAdsCount(): Integer;
    public
      constructor Create();
      destructor Destroy(); override;

      function Load( const FileName: String ): Boolean;

      property Ads[ Index: Integer ]: TAd read GetAd;
      property AdsCount: Integer read GetAdsCount;
  end;

implementation

uses  System.Variants, System.Win.ComObj, Vcl.Dialogs, System.SysUtils,
      System.RegularExpressions;

constructor THandlerAds.Create();
begin
  inherited Create();
  Ads_ := TList<TAd>.Create();
end;

destructor THandlerAds.Destroy();
begin
  Clear( true );
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
  ColCount,
  MatchIndex: Integer;
  Ad: TAd;
begin
  Result := false;
  Ad := NIL;
  Clear();
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
            Ad := TAd.Create();
            Ad.Text_ := WordDoc.Tables.Item( TableIndex ).Cell( RowIndex,
              ColIndex ).Range.FormattedText;
            Ad.Text_ := Trim( TRegEx.Replace( Ad.Text_, #$d#$7, sLineBreak,
              [roIgnoreCase, roMultiLine] ) );
            with TRegEx.Matches( Ad.Text_, TELEPHONE_PATTERN,
                [roIgnoreCase, roMultiLine] ) do
              for MatchIndex := 0 to Count - 1 do
                Ad.Telephones_.Add( Item[MatchIndex].Value );
            Ads_.Add( Ad );
            Ad := NIL;
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
    if Assigned( Ad ) then
      Ad.Free();
    WordDoc := Unassigned();
    if not VarIsClear( WordApp ) then
      WordApp.Quit();
    WordApp := Unassigned();
  end;
end;

procedure THandlerAds.Clear( IsDestroy: Boolean );
var
  AdIndex: Integer;
begin
  if Assigned( Ads_ ) then
  begin
    for AdIndex := 0 to Ads_.Count - 1 do
      Ads_[AdIndex].Free();
    if not IsDestroy then
      Ads_.Clear()
    else
      Ads_.Free()
  end;
end;

function THandlerAds.GetAd( Index: Integer ): TAd;
begin
  Result := NIL;
  Assert( ( Index >= 0 ) and ( Index < Ads_.Count ) );
  if ( ( Index >= 0 ) and ( Index < Ads_.Count ) ) then
    Result := Ads_[Index]
end;

function THandlerAds.GetAdsCount(): Integer;
begin
  Result := Ads_.Count;
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

function THandlerAds.TAd.GetTelephone( Index: Integer ): String;
begin
  Result := '';
  Assert( ( Index >= 0 ) and ( Index < Telephones_.Count ) );
  if ( ( Index >= 0 ) and ( Index < Telephones_.Count ) ) then
    Result := Telephones_[Index]
end;

function THandlerAds.TAd.GetTelephonesCount(): Integer;
begin
  Result := Telephones_.Count;
end;

end.
