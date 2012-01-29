unit uHandlerAds;

interface

type
  THandlerAds = class( TObject )
    public
      function Load( const FileName: String ): Boolean;
  end;

implementation

uses System.Variants, System.Win.ComObj, WordXP;

function THandlerAds.Load( const FileName: String ): Boolean;
var
  WordApp: Variant;
begin
  try
    try
      WordApp := CreateOleObject( 'Word.Application' );
      WordApp.Documents.Open( FileName );
    except
      raise;
    end;
  finally
    if not VarIsClear( WordApp ) then
      WordApp.Disconnect();
  end;
end;

end.
