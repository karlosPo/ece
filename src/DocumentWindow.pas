unit DocumentWindow;
{$IFDEF fpc}{$MODE delphi}{$ENDIF}

interface

uses
  Windows,
  Messages,
  IEce,
  Classes,
  zeWndControls;

type
  TEceDocumentState = (dsReady, dsLoading, dsSaving);

  TEceDocumentWindow = class(TzeWndControl, IEceDocument, IDispatch)
  private
    FCsChangeState: TRTLCriticalSection;
    FState: TEceDocumentState;
    FFileName: string;
    FApplication: IEceApplication;
    procedure SetDocumentState(const value: TEceDocumentState);
    function GetDocumentState: TEceDocumentState;
  protected
    function _GetHandle: HWND; safecall;
  protected
    procedure _BeginUpdate; virtual; safecall;
    procedure _EndUpdate; virtual; safecall;
    function GetDocumentFileName: string; virtual;
    function GetDocumentTitle: string; virtual;
  public
    Constructor Create(Parent: Cardinal; AApplication: IEceApplication);
    Destructor Destroy; override;

    function UseHotkey(ctrl, shift, alt: BOOL; key: Word): BOOL; virtual;
      stdcall;
    property DocumentTitle: string read GetDocumentTitle;
    property DocumentFileName: string read GetDocumentFileName;
    procedure LoadFromFile(AFileName: String); virtual;
    procedure SaveToFile(AFileName: string); virtual;
    function Close: boolean; virtual;
    property DocumentState: TEceDocumentState read GetDocumentState write
      SetDocumentState;
    property Vscroll;
    property HScroll;
    property Application: IEceApplication read FApplication;
    property FileName: string read FFileName;
  end;

implementation

Constructor TEceDocumentWindow.Create(Parent: Cardinal;
  AApplication: IEceApplication);
begin
  inherited Create(Parent);
  FApplication := AApplication;
  InitializeCriticalSection(FCsChangeState);
end;

Destructor TEceDocumentWindow.Destroy;
begin
  DeleteCriticalSection(FCsChangeState);
  inherited;
end;

function TEceDocumentWindow.Close: boolean;
begin
  result := true;
end;

procedure TEceDocumentWindow.LoadFromFile(AFileName: String);
begin
  FFileName := AFileName;
end;

procedure TEceDocumentWindow.SaveToFile(AFileName: string);
begin
  FFileName := AFileName;
end;

function TEceDocumentWindow.GetDocumentFileName: string;
begin

end;

function TEceDocumentWindow.GetDocumentState: TEceDocumentState;
begin
  EnterCriticalSection(FCsChangeState);
  result := FState;
  LeaveCriticalSection(FCsChangeState)
end;

function TEceDocumentWindow.GetDocumentTitle: string;
begin

end;

procedure TEceDocumentWindow.SetDocumentState(const value: TEceDocumentState);
begin
  EnterCriticalSection(FCsChangeState);
  FState := value;
  LeaveCriticalSection(FCsChangeState)
end;

function TEceDocumentWindow.UseHotkey(ctrl, shift, alt: BOOL; key: Word): BOOL;
begin
  result := False;
end;

procedure TEceDocumentWindow._BeginUpdate;
begin

end;

procedure TEceDocumentWindow._EndUpdate;
begin

end;

function TEceDocumentWindow._GetHandle: HWND;
begin
  result := Handle;
end;

end.
