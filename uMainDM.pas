unit uMainDM;

interface

uses
  System.SysUtils, System.Classes, IBDatabase, Data.DB, IBSQL;

type
  TMainDM = class(TDataModule)
    ibDatabase: TIBDatabase;
    ibTransaction: TIBTransaction;
    ibCheckTelephonesSQL: TIBSQL;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainDM: TMainDM;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

end.
