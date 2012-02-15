unit uInputForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ActnList, Vcl.ActnMan, Vcl.ExtCtrls, Vcl.ImgList, Vcl.ToolWin,
  Vcl.ActnCtrls, Vcl.StdCtrls, Vcl.StdStyleActnCtrls, VirtualTrees,
  uHandlerAds;

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
    procedure vstAdsListBeforeCellPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);
    procedure vstAdsListNodeDblClick(Sender: TBaseVirtualTree;
      const HitInfo: THitInfo);
    procedure vstAdsListKeyPress(Sender: TObject; var Key: Char);
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
end;

procedure TInputForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if ( ( ModalResult <> mrOk ) and ( IDNO = MessageBox( Handle,
      '�� ������������� ������ ����� ��� ����������?', 'Helper Agency',
      MB_ICONQUESTION or MB_YESNO ) ) ) then
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
  end;
  vstAdsList.Invalidate();
end;

procedure TInputForm.aDeleteExecute(Sender: TObject);
var
  NodeEmularator: TVTVirtualNodeEnumerator;
begin
  if ( ( vstAdsList.CheckedCount <> 0 ) and ( IDYES = MessageBox( Handle,
      '�� ������������� ������ ������� ��������� ����������?', 'Helper Agency',
      MB_ICONWARNING or MB_YESNO ) ) ) then
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

procedure TInputForm.vstAdsListBeforeCellPaint(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);
const
  AdKindColors: array[THandlerAds.TAdKind] of TColor =
    ( clWhite, $0023C880, $002364FA );
var
  Ad: THandlerAds.TAd;
begin
  Ad := THandlerAds.TAd( vstAdsList.GetNodeData( Node )^ );
  if ( Assigned( Ad ) and ( Ad.Kind <> akNone ) ) then
  begin
    if ( vstAdsList.Selected[Node] ) then
      vstAdsList.SelectionBlendFactor := 0;
    TargetCanvas.Brush.Color := AdKindColors[Ad.Kind];
    TargetCanvas.FillRect( CellRect );
  end else
  if ( vstAdsList.Selected[Node] ) then
    vstAdsList.SelectionBlendFactor := 255;
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
  NodeEmularator: TVTVirtualNodeEnumerator;
  EditForm: TEditForm;
begin
  if ( Key = Char( VK_RETURN ) ) then
  begin
    NodeEmularator := vstAdsList.SelectedNodes().GetEnumerator();
    if ( NodeEmularator.MoveNext() ) then
    begin
      EditForm := TEditForm.Create( NIL );
      try
        EditForm.ShowModal( { THandlerAds.TAd( vstAdsList.GetNodeData(
        NodeEmularator.Current )^ } );
      finally
        EditForm.Free();
      end;
    end;
  end;
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
