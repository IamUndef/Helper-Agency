object MainDM: TMainDM
  OldCreateOrder = False
  Height = 287
  Width = 415
  object ibDatabase: TIBDatabase
    DatabaseName = 'localhost:helperagency'
    Params.Strings = (
      'lc_ctype=WIN1251')
    LoginPrompt = False
    DefaultTransaction = ibTransaction
    ServerType = 'IBServer'
    Left = 32
    Top = 8
  end
  object ibTransaction: TIBTransaction
    DefaultDatabase = ibDatabase
    Left = 32
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
    Left = 328
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
    Left = 104
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
    Left = 104
    Top = 56
  end
  object ibStreetsQ: TIBQuery
    Database = ibDatabase
    Transaction = ibTransaction
    SQL.Strings = (
      'SELECT'
      '  STREETS.STREETS_ID,'
      '  STREETS.STREET'
      'FROM STREETS'
      'WHERE STREETS.STREET STARTING WITH TRIM( :STREET )'
      'ORDER BY STREETS.STREET')
    Left = 176
    Top = 8
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'STREET'
        ParamType = ptUnknown
      end>
  end
  object dsStreets: TDataSource
    DataSet = ibStreetsQ
    Left = 176
    Top = 56
  end
  object ibInsertAdsTelephonesSQL: TIBSQL
    Database = ibDatabase
    SQL.Strings = (
      'INSERT INTO ADS_TELEPHONES'
      '  ( ADS_ID, TELEPHONES_ID )'
      'VALUES'
      '  ( :ADS_ID, :TELEPHONES_ID )')
    Transaction = ibTransaction
    Left = 328
    Top = 56
  end
  object ibTelephonesDS: TIBDataSet
    Database = ibDatabase
    Transaction = ibTransaction
    DeleteSQL.Strings = (
      'DELETE FROM TELEPHONES'
      'WHERE'
      '  TELEPHONES_ID = :OLD_TELEPHONES_ID')
    InsertSQL.Strings = (
      'INSERT INTO TELEPHONES'
      '  ( TELEPHONES_ID, KIND, TELEPHONE )'
      'values'
      '  ( :TELEPHONES_ID, :KIND, :TELEPHONE )')
    SelectSQL.Strings = (
      'SELECT'
      '  TELEPHONES.TELEPHONES_ID,'
      '  TELEPHONES.KIND,'
      '  TELEPHONES.TELEPHONE'
      'FROM TELEPHONES'
      'WHERE TELEPHONES.TELEPHONE = :TELEPHONE')
    ModifySQL.Strings = (
      'UPDATE TELEPHONES'
      'SET'
      '  KIND = :KIND,'
      '  TELEPHONE = :TELEPHONE'
      'WHERE'
      '  TELEPHONES_ID = :OLD_TELEPHONES_ID')
    GeneratorField.Field = 'TELEPHONES_ID'
    GeneratorField.Generator = 'TELEPHONES_ID_GEN'
    Left = 32
    Top = 224
  end
  object ibStreetsDS: TIBDataSet
    Database = ibDatabase
    Transaction = ibTransaction
    DeleteSQL.Strings = (
      'DELETE FROM STREETS'
      'WHERE'
      '  STREETS_ID = :OLD_STREETS_ID')
    InsertSQL.Strings = (
      'INSERT INTO STREETS'
      '  ( STREETS_ID, STREET )'
      'VALUES'
      '  ( :STREETS_ID, :STREET )')
    SelectSQL.Strings = (
      'SELECT'
      '  STREETS.STREETS_ID,'
      '  STREETS.STREET'
      'FROM STREETS'
      'WHERE STREETS.STREET = :STREET')
    ModifySQL.Strings = (
      'UPDATE STREETS'
      'SET'
      '  STREET = :STREET'
      'WHERE'
      '  STREETS_ID = :OLD_STREETS_ID')
    GeneratorField.Field = 'STREETS_ID'
    GeneratorField.Generator = 'STREETS_ID_GEN'
    Left = 104
    Top = 224
  end
  object ibAdsDS: TIBDataSet
    Database = ibDatabase
    Transaction = ibTransaction
    DeleteSQL.Strings = (
      'DELETE FROM ADS'
      'WHERE'
      '  ADS_ID = :OLD_ADS_ID')
    InsertSQL.Strings = (
      'INSERT INTO ADS'
      '  ( ADS_ID, STREETS_ID, ROOMSCOUNT, TEXT )'
      'VALUES'
      '  ( :ADS_ID, :STREETS_ID, :ROOMSCOUNT, :TEXT )')
    SelectSQL.Strings = (
      'SELECT *'
      'FROM ADS')
    ModifySQL.Strings = (
      'UPDATE ADS'
      'SET'
      '  STREETS_ID = :STREETS_ID,'
      '  ROOMSCOUNT = :ROOMSCOUNT'
      'WHERE'
      '  ADS_ID = :OLD_ADS_ID')
    GeneratorField.Field = 'ADS_ID'
    GeneratorField.Generator = 'ADS_ID_GEN'
    Left = 168
    Top = 224
  end
end
