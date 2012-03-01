unit uInputForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ActnList, Vcl.ActnMan, Vcl.ExtCtrls, Vcl.ImgList, Vcl.ToolWin,
  Vcl.ActnCtrls, Vcl.StdCtrls, Vcl.StdStyleActnCtrls, VirtualTrees,
  Vcl.Buttons, uHandlerAds;

type
  TInputForm = class(TForm)
    amMain: TActionManager;
    ilMain: TImageList;
    pTop: TPanel;
    atbTopLeft: TActionToolBar;
    atbTopRight: TActionToolBar;
    atbBottom: TActionToolBar;
    aOk: TAction;
    aCancel: TAction;
    aDelete: TAction;
    aOwner: TAction;
    aAgency: TAction;
    gbMain: TGroupBox;
    vstAdsList: TVirtualStringTree;
    pAdKinds: TPanel;
    sbAdKindsTitle: TSpeedButton;
    cbNone: TCheckBox;
    cbOwner: TCheckBox;
    cbAgency: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure aOkExecute(Sender: TObject);
    procedure aCancelExecute(Sender: TObject);
    procedure aOwnerExecute(Sender: TObject);
    procedure aAgencyExecute(Sender: TObject);
    procedure aDeleteExecute(Sender: TObject);
    procedure vstAdsListGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstAdsListCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure vstAdsListHeaderClick(Sender: TVTHeader;
      HitInfo: TVTHeaderHitInfo);
    procedure vstAdsListHeaderDblClick(Sender: TVTHeader;
      HitInfo: TVTHeaderHitInfo);
    procedure vstAdsListChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstAdsListNodeDblClick(Sender: TBaseVirtualTree;
      const HitInfo: THitInfo);
    procedure vstAdsListKeyPress(Sender: TObject; var Key: Char);
    procedure vstAdsListPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType);
    procedure sbAdKindsTitleClick(Sender: TObject);
    procedure CheckBoxClick(Sender: TObject);
  private
    type
      TColumnType = ( ctRoomsCount = 1, ctStreet, ctTelephones, ctAdText );
  private
    { Private declarations }
    HandlerAds: THandlerAds;
  public
    { Public declarations }
    function ShowModal( const FileName: String ): TModalResult; reintroduce;
    procedure SyncAdKinds( Ad: THandlerAds.TAd );
  end;

implementation

{$R *.dfm}

uses Data.DB, uMainDM, uEditForm;

procedure TInputForm.FormCreate(Sender: TObject);
begin
  vstAdsList.NodeDataSize := SizeOf( THandlerAds.TAd );
  HandlerAds := THandlerAds.Create();
  pAdKinds.Tag := pAdKinds.Height;
  pAdKinds.Height := sbAdKindsTitle.Height;
  sbAdKindsTitle.Caption := cbNone.Caption + cbOwner.Caption + cbAgency.Caption;
end;

procedure TInputForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if ( ( ModalResult <> mrOk ) and ( IDNO = MessageBox( Handle,
      'Вы действительно хотите выйти без сохранения?', 'Helper Agency',
      MB_ICONQUESTION or MB_YESNO or MB_DEFBUTTON2 ) ) ) then
    ModalResult := mrNone;
end;

procedure TInputForm.FormDestroy(Sender: TObject);
begin
  if Assigned( HandlerAds ) then
    HandlerAds.Free();
end;

procedure TInputForm.aOkExecute(Sender: TObject);
var
  Ad: THandlerAds.TAd;

procedure InsertNoneAndOnwerAds();
var
  AdIndex,
  TelephoneIndex: Integer;
begin
  for AdIndex := 0 to HandlerAds.AdsCount - 1 do
    if ( HandlerAds.Ads[AdIndex].Kind in [akNone, akOwner] ) then
    begin
      Ad := HandlerAds.Ads[AdIndex];
      MainDM.ibStreetsDS.Close();
      MainDM.ibStreetsDS.ParamByName( 'STREET' ).AsString := Ad.Street;
      MainDM.ibStreetsDS.Open();
      if MainDM.ibStreetsDS.IsEmpty then
      begin
        MainDM.ibStreetsDS.Insert();
        try
          MainDM.ibStreetsDS.FieldByName( 'STREET' ).AsString := Ad.Street;
          MainDM.ibStreetsDS.Post();
        except
          MainDM.ibStreetsDS.Cancel();
          raise;
        end;
      end;
      MainDM.ibAdsDS.Open();
      MainDM.ibAdsDS.Insert();
      try
        MainDM.ibAdsDS.FieldByName( 'STREETS_ID' ).AsInteger :=
          MainDM.ibStreetsDS.FieldByName( 'STREETS_ID' ).AsInteger;
        MainDM.ibAdsDS.FieldByName( 'ADDDATE' ).AsDateTime := 0;
        MainDM.ibAdsDS.FieldByName( 'ROOMSCOUNT' ).AsInteger := Ad.RoomsCount;
        MainDM.ibAdsDS.FieldByName( 'TEXT' ).AsString := Ad.Text;
        MainDM.ibAdsDS.Post();
      except
        MainDM.ibAdsDS.Cancel();
        raise;
      end;
      for TelephoneIndex := 0 to Ad.TelephonesCount - 1 do
      begin
        MainDM.ibTelephonesDS.Close();
        MainDM.ibTelephonesDS.ParamByName( 'TELEPHONE' ).AsString :=
          Ad.Telephones[TelephoneIndex];
        MainDM.ibTelephonesDS.Open();
        try
          if not MainDM.ibTelephonesDS.IsEmpty then
            MainDM.ibTelephonesDS.Edit()
          else
          begin
            MainDM.ibTelephonesDS.Insert();
            MainDM.ibTelephonesDS.FieldByName( 'TELEPHONE' ).AsString :=
              Ad.Telephones[TelephoneIndex];
          end;
          MainDM.ibTelephonesDS.FieldByName( 'KIND' ).AsInteger :=
            Integer( Ad.Kind );
          MainDM.ibTelephonesDS.Post();
        except
          if ( MainDM.ibTelephonesDS.State in [dsInsert, dsEdit] ) then
            MainDM.ibTelephonesDS.Cancel();
          raise;
        end;
        MainDM.ibInsertAdsTelephonesSQL.Close();
        MainDM.ibInsertAdsTelephonesSQL.ParamByName( 'ADS_ID' ).AsInteger :=
          MainDM.ibAdsDS.FieldByName( 'ADS_ID' ).AsInteger;
        MainDM.ibInsertAdsTelephonesSQL.ParamByName( 'TELEPHONES_ID' ).AsInteger :=
          MainDM.ibTelephonesDS.FieldByName( 'TELEPHONES_ID' ).AsInteger;
        MainDM.ibInsertAdsTelephonesSQL.ExecQuery();
      end;
    end;
end;

procedure InsertAgencyTelephones();
var
  AdIndex,
  TelephoneIndex: Integer;
begin
  for AdIndex := 0 to HandlerAds.AdsCount - 1 do
    if ( HandlerAds.Ads[AdIndex].Kind = akAgency ) then
    begin
      Ad := HandlerAds.Ads[AdIndex];
      for TelephoneIndex := 0 to Ad.TelephonesCount - 1 do
      begin
        MainDM.ibTelephonesDS.Close();
        MainDM.ibTelephonesDS.ParamByName( 'TELEPHONE' ).AsString :=
          Ad.Telephones[TelephoneIndex];
        MainDM.ibTelephonesDS.Open();
        try
          if not MainDM.ibTelephonesDS.IsEmpty then
            MainDM.ibTelephonesDS.Edit()
          else
          begin
            MainDM.ibTelephonesDS.Insert();
            MainDM.ibTelephonesDS.FieldByName( 'TELEPHONE' ).AsString :=
              Ad.Telephones[TelephoneIndex];
          end;
          MainDM.ibTelephonesDS.FieldByName( 'KIND' ).AsInteger :=
            Integer( akAgency );
          MainDM.ibTelephonesDS.Post();
        except
          if ( MainDM.ibTelephonesDS.State in [dsInsert, dsEdit] ) then
            MainDM.ibTelephonesDS.Cancel();
          raise;
        end;
      end;
    end;
end;

begin
  if MainDM.ibTransaction.InTransaction then
    MainDM.ibTransaction.Commit();
  MainDM.ibTransaction.StartTransaction();
  try
    try
      InsertNoneAndOnwerAds();
      InsertAgencyTelephones();
      MainDM.ibTransaction.Commit();
      ModalResult := mrOk;
    except
      MainDM.ibTransaction.Rollback();
      MessageBox( Handle, 'Не удалось сохранить данные!', 'Helper Agency',
        MB_ICONERROR or MB_OK );
    end;
  finally
    MainDM.ibTelephonesDS.Close();
    MainDM.ibStreetsDS.Close();
    MainDM.ibAdsDS.Close();
    MainDM.ibInsertAdsTelephonesSQL.Close();
  end;
end;

procedure TInputForm.aCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TInputForm.aOwnerExecute(Sender: TObject);
var
  NodeEmularator: TVTVirtualNodeEnumerator;
begin
  NodeEmularator := vstAdsList.CheckedNodes().GetEnumerator();
  while NodeEmularator.MoveNext() do
  begin
    vstAdsList.CheckState[NodeEmularator.Current] := csUncheckedNormal;
    THandlerAds.TAd( vstAdsList.GetNodeData(
      NodeEmularator.Current )^ ).Kind := akOwner;
    SyncAdKinds( THandlerAds.TAd( vstAdsList.GetNodeData(
      NodeEmularator.Current )^ ) );
  end;
  vstAdsList.Invalidate();
end;

procedure TInputForm.aAgencyExecute(Sender: TObject);
var
  NodeEmularator: TVTVirtualNodeEnumerator;
begin
  NodeEmularator := vstAdsList.CheckedNodes().GetEnumerator();
  while NodeEmularator.MoveNext() do
  begin
    vstAdsList.CheckState[NodeEmularator.Current] := csUncheckedNormal;
    THandlerAds.TAd( vstAdsList.GetNodeData(
      NodeEmularator.Current )^ ).Kind := akAgency;
    SyncAdKinds( THandlerAds.TAd( vstAdsList.GetNodeData(
      NodeEmularator.Current )^ ) );
  end;
  vstAdsList.Invalidate();
end;

procedure TInputForm.aDeleteExecute(Sender: TObject);
var
  NodeEmularator: TVTVirtualNodeEnumerator;
begin
  if ( ( vstAdsList.CheckedCount <> 0 ) and ( IDYES = MessageBox( Handle,
      'Вы действительно хотите удалить выбранные объявления?', 'Helper Agency',
      MB_ICONWARNING or MB_YESNO or MB_DEFBUTTON2 ) ) ) then
  begin
    NodeEmularator := vstAdsList.CheckedNodes().GetEnumerator();
    vstAdsList.BeginUpdate();
    try
      while NodeEmularator.MoveNext() do
      begin
        vstAdsList.CheckState[NodeEmularator.Current] := csUncheckedNormal;
        HandlerAds.DeleteAd( THandlerAds.TAd( vstAdsList.GetNodeData(
          NodeEmularator.Current )^ ) );
        vstAdsList.DeleteNode( NodeEmularator.Current );
      end;
    finally
      vstAdsList.EndUpdate();
    end;
  end;
end;

procedure TInputForm.vstAdsListGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  Ad: THandlerAds.TAd;
  TelephoneIndex: Integer;
  KindChecked: Boolean;
begin
  Ad := THandlerAds.TAd( vstAdsList.GetNodeData( Node )^ );
  KindChecked := true;
  case Ad.Kind of
    akNone: KindChecked := cbNone.Checked;
    akOwner: KindChecked := cbOwner.Checked;
    akAgency: KindChecked := cbAgency.Checked;
  end;
  if not KindChecked then
  begin
    vstAdsList.CheckState[Node] := csUncheckedNormal;
    vstAdsList.FullyVisible[Node] := false;
    vstAdsList.Selected[Node] := false;
  end;
  if vstAdsList.FullyVisible[Node] then
  begin
    CellText := '';
    case TColumnType( Column ) of
      ctRoomsCount:
        CellText := IntToStr( Ad.RoomsCount );
      ctStreet:
        CellText := Ad.Street;
      ctTelephones:
        for TelephoneIndex := 0 to Ad.TelephonesCount - 1 do
        begin
          if ( CellText <> '' ) then
            CellText := CellText + ', ';
          CellText := CellText + Ad.Telephones[TelephoneIndex];
        end;
      ctAdText:
        CellText := Ad.Text;
    end;
  end;
end;

procedure TInputForm.vstAdsListCompareNodes(Sender: TBaseVirtualTree; Node1,
  Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
begin
  Result := CompareText( vstAdsList.Text[Node1, Column],
    vstAdsList.Text[Node2, Column] );
end;

procedure TInputForm.vstAdsListHeaderClick(Sender: TVTHeader;
  HitInfo: TVTHeaderHitInfo);
var
  ColumnCheckState: TCheckState;
  NodeEmularator: TVTVirtualNodeEnumerator;
begin
  if ( HitInfo.Button = mbLeft ) then
  begin
    if ( HitInfo.Column = 0 ) then
    begin
      ColumnCheckState := vstAdsList.Header.Columns[0].CheckState;
      NodeEmularator := vstAdsList.Nodes().GetEnumerator();
      while NodeEmularator.MoveNext() do
        if ( ColumnCheckState = csUncheckedNormal ) then
          vstAdsList.CheckState[NodeEmularator.Current] := csUncheckedNormal
        else
          vstAdsList.CheckState[NodeEmularator.Current] := csCheckedNormal;
    end else
    if ( TColumnType( HitInfo.Column )
        in [ctRoomsCount, ctStreet, ctTelephones] ) then
    begin
      vstAdsList.Header.SortColumn := HitInfo.Column;
      if ( vstAdsList.Header.SortDirection = sdAscending ) then
        vstAdsList.Header.SortDirection := sdDescending
      else
        vstAdsList.Header.SortDirection := sdAscending;
      vstAdsList.SortTree( HitInfo.Column, vstAdsList.Header.SortDirection );
    end;
  end;
end;

procedure TInputForm.vstAdsListHeaderDblClick(Sender: TVTHeader;
  HitInfo: TVTHeaderHitInfo);
begin
  vstAdsList.OnHeaderClick( Sender, HitInfo );
end;

procedure TInputForm.vstAdsListChecked(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  if ( vstAdsList.CheckedCount = 0 ) then
    vstAdsList.Header.Columns[0].CheckState := csUncheckedNormal
  else
  if ( vstAdsList.CheckedCount = Integer( vstAdsList.RootNodeCount ) ) then
    vstAdsList.Header.Columns[0].CheckState := csCheckedNormal
  else
    vstAdsList.Header.Columns[0].CheckState := csMixedNormal;
end;

procedure TInputForm.vstAdsListNodeDblClick(Sender: TBaseVirtualTree;
  const HitInfo: THitInfo);
var
  Key: Char;
begin
  if ( HitInfo.HitColumn <> 0 ) then
  begin
    Key := Char( VK_RETURN );
    vstAdsList.OnKeyPress( vstAdsList, Key );
  end;
end;

procedure TInputForm.vstAdsListKeyPress(Sender: TObject; var Key: Char);
var
  Node: PVirtualNode;
  NodeEmularator: TVTVirtualNodeEnumerator;
  EditForm: TEditForm;
begin
  if ( Key = Char( VK_RETURN ) ) then
  begin
    Node := NIL;
    NodeEmularator := vstAdsList.SelectedNodes().GetEnumerator();
    while ( NodeEmularator.MoveNext() ) do
      if not Assigned( Node ) then
        Node := NodeEmularator.Current
      else
        vstAdsList.Selected[NodeEmularator.Current] := false;
    EditForm := TEditForm.Create( Self );
    try
      if ( EditForm.ShowModal(
          THandlerAds.TAd( vstAdsList.GetNodeData( Node )^ ) ) = mrOk ) then
      begin
        SyncAdKinds( THandlerAds.TAd( vstAdsList.GetNodeData( Node )^ ) );
        vstAdsList.SortTree( vstAdsList.Header.SortColumn,
          vstAdsList.Header.SortDirection );
      end;
    finally
      EditForm.Free();
    end;
  end else
  if ( Key = Char( VK_SPACE ) ) then
  begin
    Key := #0;
    NodeEmularator := vstAdsList.SelectedNodes().GetEnumerator();
    while ( NodeEmularator.MoveNext() ) do
      if ( NodeEmularator.Current.CheckState = csUncheckedNormal ) then
        vstAdsList.CheckState[NodeEmularator.Current] := csCheckedNormal
      else
        vstAdsList.CheckState[NodeEmularator.Current] := csUncheckedNormal;
  end;
end;

procedure TInputForm.vstAdsListPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
const
  AdKindColors: array[THandlerAds.TAdKind] of TColor =
    ( clSilver, clBlack, clRed );
var
  Ad: THandlerAds.TAd;
begin
  Ad := THandlerAds.TAd( vstAdsList.GetNodeData( Node )^ );
  if Assigned( Ad ) then
    TargetCanvas.Font.Color := AdKindColors[Ad.Kind];
end;

procedure TInputForm.sbAdKindsTitleClick(Sender: TObject);
begin
  if ( pAdKinds.Height = pAdKinds.Tag ) then
    pAdKinds.Height := sbAdKindsTitle.Height
  else
    pAdKinds.Height := pAdKinds.Tag;
end;

procedure TInputForm.CheckBoxClick(Sender: TObject);
var
  Checkbox: TCheckBox;
  NodeEmularator: TVTVirtualNodeEnumerator;
  Ad: THandlerAds.TAd;
begin
  Checkbox := TCheckBox( Sender );
  NodeEmularator := vstAdsList.Nodes().GetEnumerator();
  while ( NodeEmularator.MoveNext() ) do
  begin
    Ad := THandlerAds.TAd( vstAdsList.GetNodeData( NodeEmularator.Current )^ );
    if ( Ad.Kind = THandlerAds.TAdKind( Checkbox.Tag ) ) then
    begin
      vstAdsList.FullyVisible[NodeEmularator.Current] := Checkbox.Checked;
      if not Checkbox.Checked then
      begin
        vstAdsList.Selected[NodeEmularator.Current] := false;
        vstAdsList.CheckState[NodeEmularator.Current] := csUncheckedNormal;
      end;
    end;
  end;
  sbAdKindsTitle.Caption := '';
  if cbNone.Checked then
    sbAdKindsTitle.Caption := cbNone.Caption;
  if cbOwner.Checked then
    sbAdKindsTitle.Caption := sbAdKindsTitle.Caption + cbOwner.Caption;
  if cbAgency.Checked then
    sbAdKindsTitle.Caption := sbAdKindsTitle.Caption + cbAgency.Caption;
end;

function TInputForm.ShowModal( const FileName: String ): TModalResult;
var
  AdIndex: Integer;

function CheckTelephones() : THandlerAds.TCheckTelephonesFunc;
begin
  Result := function ( Telephones: TStringList ): THandlerAds.TAdKind
  var
    TelephoneIndex: Integer;
  begin
    Result := akNone;
    for TelephoneIndex := 0 to Telephones.Count - 1 do
      try
        MainDM.ibCheckTelephonesSQL.Close();
        MainDM.ibCheckTelephonesSQL.ParamByName( 'TELEPHONE' ).AsString :=
          Telephones[TelephoneIndex];
        MainDM.ibCheckTelephonesSQL.ExecQuery();
        if not MainDM.ibCheckTelephonesSQL.Eof then
          case THandlerAds.TAdKind(
              MainDM.ibCheckTelephonesSQL.FieldByName( 'KIND' ).AsInteger ) of
            akOwner:
              Result := akOwner;
            akAgency:
              Exit( akAgency );
          end;
      finally
        MainDM.ibCheckTelephonesSQL.Close();
      end;
  end;
end;

begin
  if not HandlerAds.Load( FileName, CheckTelephones() ) then
  begin
    Result := mrCancel;
    ModalResult := mrCancel;
  end else
  begin
    vstAdsList.BeginUpdate();
    try
      for AdIndex := 0 to HandlerAds.AdsCount - 1 do
        vstAdsList.AddChild( NIL,
          Pointer( HandlerAds.Ads[AdIndex] ) ).CheckType := ctCheckBox;
    finally
      vstAdsList.EndUpdate();
    end;
    Result := inherited ShowModal();
  end;
end;

procedure TInputForm.SyncAdKinds( Ad: THandlerAds.TAd );
var
  AdSync: THandlerAds.TAd;
  AdIndex,
  TelephoneIndex: Integer;
begin
  for AdIndex := 0 to HandlerAds.AdsCount - 1 do
    if ( Ad.Kind <> HandlerAds.Ads[AdIndex].Kind ) then
    begin
      AdSync := HandlerAds.Ads[AdIndex];
      for TelephoneIndex := 0 to Ad.TelephonesCount - 1 do
        if AdSync.IsAdTelephone( Ad.Telephones[TelephoneIndex] ) then
        begin
          if ( ( Ad.Kind = akNone ) and ( Ad.Kind < AdSync.Kind ) ) then
          begin
            Ad.Kind := AdSync.Kind;
            Exit();
          end else
          begin
            AdSync.Kind := Ad.Kind;
            if ( AdSync.TelephonesCount > 1 ) then
              SyncAdKinds( AdSync );
            Break;
          end;
        end;
    end;
end;

end.
