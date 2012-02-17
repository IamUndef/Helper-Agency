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
  end;

implementation

{$R *.dfm}

uses uMainDM, uEditForm;

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
begin
  ModalResult := mrOk;
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
    if not cbOwner.Checked then
    begin
      vstAdsList.FullyVisible[NodeEmularator.Current] := false;
      vstAdsList.Selected[NodeEmularator.Current] := false;
    end;
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
    if not cbAgency.Checked then
    begin
      vstAdsList.FullyVisible[NodeEmularator.Current] := false;
      vstAdsList.Selected[NodeEmularator.Current] := false;
    end;
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
    while NodeEmularator.MoveNext() do
    begin
      vstAdsList.CheckState[NodeEmularator.Current] := csUncheckedNormal;
      HandlerAds.DeleteAd( THandlerAds.TAd( vstAdsList.GetNodeData(
        NodeEmularator.Current )^ ) );
      vstAdsList.DeleteNode( NodeEmularator.Current );
    end;
    vstAdsList.Invalidate();
  end;
end;

procedure TInputForm.vstAdsListGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  Ad: THandlerAds.TAd;
  TelephoneIndex: Integer;
begin
  CellText := '';
  Ad := THandlerAds.TAd( vstAdsList.GetNodeData( Node )^ );
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
    EditForm := TEditForm.Create( NIL );
    try
      EditForm.ShowModal( {THandlerAds.TAd( vstAdsList.GetNodeData( Node )^} );
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
        MainDM.ibCheckTelephonesSQL.ParamByName( 'TELEPHONE' ).AsString :=
          Telephones[TelephoneIndex];
        MainDM.ibCheckTelephonesSQL.Close();
        MainDM.ibCheckTelephonesSQL.ExecQuery();
        if not MainDM.ibCheckTelephonesSQL.Eof then
          Exit( THandlerAds.TAdKind(
            MainDM.ibCheckTelephonesSQL.FieldByName( 'KIND' ).AsInteger ) )
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
    for AdIndex := 0 to HandlerAds.AdsCount - 1 do
      vstAdsList.AddChild( NIL,
        Pointer( HandlerAds.Ads[AdIndex] ) ).CheckType := ctCheckBox;
    vstAdsList.EndUpdate();
    Result := inherited ShowModal();
  end;
end;

end.
