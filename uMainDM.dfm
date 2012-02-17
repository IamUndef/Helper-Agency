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
    Top = 8
  end
  object ibTelephonesQ: TIBQuery
    Database = ibDatabase
    Transaction = ibTransaction
    SQL.Strings = (
      'SELECT'
      '  TELEPHONES.TELEPHONES_ID,'
      '  TELEPHONES.KIND,'
      '  TELEPHONES.TELEPHONE'
      'FROM TELEPHONES'
      'WHERE TELEPHONES.TELEPHONE STARTING WITH TRIM( :TELEPHONE )'
      'ORDER BY TELEPHONES.TELEPHONE')
    Left = 216
    Top = 8
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'TELEPHONE'
        ParamType = ptUnknown
      end>
  end
  object dsTelephones: TDataSource
    DataSet = ibTelephonesQ
    Left = 216
    Top = 56
  end
end
