unit uHandlerAds;

interface

uses  System.Classes, System.Generics.Collections;

type
  THandlerAds = class( TObject )
    public
      type
        TAdKind = ( akNone, akOwner, akAgency );
        TCheckTelephonesFunc =
          reference to function( Telephones: TStringList ): TAdKind;
        TAd = class
          private
            const
              STREET_PATTERN : String =
                '[а-яА-ЯёЁ\d\s\.\-]+(?=,)';
              ROOMS_COUNT_PATTERN : String =
                '\d+\s*(?=-к.)';
              TELEPHONE_PATTERN : String =
                '(?:(?:8|\+\d{1,4})\-?\s*)?(?:\(?\d{3,6}\)?\-?\s*)?(?:\d{1,})(?:\-?\s*\d{2,}){2,}';
          private
            Text_: String;
            Kind_: TAdKind;
            Street_: String;
            RoomsCount_: Integer;
            Telephones_: TStringList;

            procedure Init( const AdText: String );

            function GetTelephone( Index: Integer ): String;
            procedure SetTelephone( Index: Integer; const Telephone: String );
            function GetTelephonesCount(): Integer;
          public
            constructor Create( const AdText: String );
            destructor Destroy(); override;

            procedure AddTelephone( const Telephone: String );
            procedure DeleteTelephone( Index: Integer );
            function IsAdTelephone( const Telephone: String ): Boolean;

            property Text: String read Text_;
            property Kind: TAdKind read Kind_ write Kind_;
            property Street: String read Street_ write Street_;
            property RoomsCount: Integer read RoomsCount_ write RoomsCount_;
            property Telephones[ Index: Integer ]: String read GetTelephone
              write SetTelephone;
            property TelephonesCount: Integer read GetTelephonesCount;
        end;
    private
      Ads_: TList<TAd>;

      procedure Clear( IsDestroy: Boolean = false );

      function GetAd( Index: Integer ): TAd;
      function GetAdsCount(): Integer;
    public
      constructor Create();
      destructor Destroy(); override;

      function Load( const FileName: String;
        CheckTelephonesFunc: TCheckTelephonesFunc ): Boolean;
      procedure DeleteAd( var Ad: TAd );

      property Ads[ Index: Integer ]: TAd read GetAd;
      property AdsCount: Integer read GetAdsCount;
  end;

implementation

uses  System.Variants, System.Win.ComObj, Vcl.Dialogs, System.SysUtils,
      System.RegularExpressions, System.Character;

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

function THandlerAds.Load( const FileName: String;
  CheckTelephonesFunc: TCheckTelephonesFunc ): Boolean;
var
  WordApp,
  WordDoc: Variant;
  TableIndex,
  RowIndex,
  RowCount,
  ColIndex,
  ColCount: Integer;
  AdText: String;
begin
  Result := false;
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
            AdText := WordDoc.Tables.Item( TableIndex ).Cell( RowIndex,
              ColIndex ).Range.FormattedText;
            AdText := AnsiUpperCase( Trim( TRegEx.Replace( AdText, #$d#$7,
              sLineBreak, [roIgnoreCase, roMultiLine] ) ) );
            Ads_.Add( TAd.Create( AdText ) );
            if Assigned( CheckTelephonesFunc ) then
              Ads_.Last().Kind_ :=
                CheckTelephonesFunc( Ads_.Last().Telephones_ );
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

procedure THandlerAds.DeleteAd( var Ad: TAd );
begin
  if ( Ads_.Remove( Ad ) <> -1 ) then
    FreeAndNil( Ad );
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

constructor THandlerAds.TAd.Create( const AdText: String );
begin
  inherited Create();
  Init( AdText );
end;

destructor THandlerAds.TAd.Destroy();
begin
  if Assigned( Telephones_ ) then
    Telephones_.Free();
  inherited;
end;

procedure THandlerAds.TAd.AddTelephone( const Telephone: String );
begin
  if ( Telephones_.IndexOf( Trim( Telephone ) ) = -1 ) then
    Telephones_.Add( Trim( Telephone ) );
end;

procedure THandlerAds.TAd.DeleteTelephone( Index: Integer );
begin
  Assert( ( Index >= 0 ) and ( Index < Telephones_.Count ) );
  if ( ( Index >= 0 ) and ( Index < Telephones_.Count ) ) then
    Telephones_.Delete( Index );
end;

function THandlerAds.TAd.IsAdTelephone( const Telephone: String ): Boolean;
var
  TelephoneIndex: Integer;
begin
  Result := false;
  for TelephoneIndex := 0 to Telephones_.Count - 1 do
    if ( Telephones_[TelephoneIndex] = Telephone ) then
      Exit( true );
end;

procedure THandlerAds.TAd.Init( const AdText: String );

procedure InitStreet();
begin
  Street_ := AnsiUpperCase( Trim( TRegEx.Match( AdText, STREET_PATTERN,
    [roIgnoreCase, roMultiLine] ).Value ) );
end;

procedure InitRoomsCount();
var
  RoomsCountStr: String;
begin
  RoomsCountStr := TRegEx.Match( AdText, ROOMS_COUNT_PATTERN,
    [roIgnoreCase, roMultiLine] ).Value;
  TryStrToInt( RoomsCountStr, RoomsCount_ );
end;

function LeaveOnlyDitits( const Telephone: String ): String;
var
  Index: Integer;
begin
  Result := '';
  if ( Telephone <> '' ) then
  begin
    if ( Telephone[1] = '+' ) then
      Result := '+';
    for Index := 1 to Length( Telephone ) do
      if IsDigit( Telephone[Index] ) then
        Result := Result + Telephone[Index];
  end;
end;

procedure InitTelephones();
var
  MatchIndex: Integer;
begin
  Telephones_ := TStringList.Create();
  with TRegEx.Matches( Text_, TELEPHONE_PATTERN,
      [roIgnoreCase, roMultiLine] ) do
    for MatchIndex := 0 to Count - 1 do
      Telephones_.Add( LeaveOnlyDitits( Trim( Item[MatchIndex].Value ) ) );
end;

begin
  Text_ := AdText;
  InitStreet();
  InitRoomsCount();
  InitTelephones();
end;

function THandlerAds.TAd.GetTelephone( Index: Integer ): String;
begin
  Result := '';
  Assert( ( Index >= 0 ) and ( Index < Telephones_.Count ) );
  if ( ( Index >= 0 ) and ( Index < Telephones_.Count ) ) then
    Result := Telephones_[Index]
end;

procedure THandlerAds.TAd.SetTelephone( Index: Integer;
  const Telephone: String );
begin
  Assert( ( Index >= 0 ) and ( Index < Telephones_.Count ) );
  if ( ( Index >= 0 ) and ( Index < Telephones_.Count ) ) then
    Telephones_[Index] := Trim( Telephone );
end;

function THandlerAds.TAd.GetTelephonesCount(): Integer;
begin
  Result := Telephones_.Count;
end;

end.
