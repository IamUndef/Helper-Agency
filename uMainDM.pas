unit uMainDM;

interface

uses
  System.SysUtils, System.Classes, IBDatabase, Data.DB, IBSQL, IBCustomDataSet,
  IBQuery;

type
  TMainDM = class(TDataModule)
    ibDatabase: TIBDatabase;
    ibTransaction: TIBTransaction;
    ibCheckTelephonesSQL: TIBSQL;
    ibTelephonesQ: TIBQuery;
    dsTelephones: TDataSource;
    ibStreetsQ: TIBQuery;
    dsStreets: TDataSource;
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
