object MainDM: TMainDM
  OldCreateOrder = False
  Height = 287
  Width = 340
  object ibDatabase: TIBDatabase
    DatabaseName = 'localhost:helperagency'
    Params.Strings = (
      'lc_ctype=WIN1251')
    LoginPrompt = False
    DefaultTransaction = ibTransaction
    ServerType = 'IBServer'
    Left = 24
    Top = 8
  end
  object ibTransaction: TIBTransaction
    DefaultDatabase = ibDatabase
    Left = 24
    Top = 56
  end
  object ibCheckTelephonesSQL: TIBSQL
    Database = ibDatabase
    SQL.Strings = (
      'SELECT'
      '  TELEPHONES.KIND,'
      '  TELEPHONES.TELEPHONE'
      'FROM TELEPHONES'
      'WHERE TELEPHONES.TELEPHONE = TRIM( :TELEPHONE )')
    Transaction = ibTransaction
    Left = 120
    Top = 56
  end
end
