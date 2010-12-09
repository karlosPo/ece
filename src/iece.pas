unit iece;
{$IFDEF fpc}{$MODE delphi}{$ENDIF}

interface

uses
  Windows;

const
  DISPATCH_SUB = 1;
  DISPATCH_FUNCTION = 2;
  DISPATCH_GET = 3;
  DISPATCH_SET = 4;

  IIdEceEditor : TGUID =   '{AE254231-D4EE-405D-B402-9354A5CD340C}';

type
  IEceDocument = interface;
  IEceDocumentLoader = interface;

  IEceAction = interface;
  IEceUiConteiner = Interface;
  IEceUiItem = Interface;

  IEceApplication = interface
    function _GetHandle: HWND; safecall;
    function _GetDocumentsCount: integer; safecall;
    function _GetDocuments(AIndex: integer; var ADocument: IEceDocument)
      : integer; safecall;
    procedure _UpdateCaption; safecall;
    procedure _FocusToActiveDocument; safecall;
    procedure _About; safecall;
    // ��� ������ � ���������
    // ����������� ������ "������������" ����������
    procedure RegisterDocument(Doc: IEceDocumentLoader); safecall;
    procedure RegisterDocumentEx(Doc: IEceDocumentLoader; ext:string); safecall;
  end;

  IEceAction = interface
    procedure AddLink(Ui : IEceUiItem); safecall;
    procedure RemoveLink(Ui : IEceUiItem); safecall;
  end;

  IEceUiConteiner = Interface

  end;

  IEceUiItem = Interface
    function GetAction: IEceAction; safecall;
    procedure SetAction(const Value: IEceAction); safecall;
    procedure UpdateState; safecall;
  end;

  IEceDocument = interface
    function UseHotkey(ctrl, shift, alt: BOOL; key: Word): BOOL; safecall;
    function _GetHandle: HWND; safecall;
    procedure _BeginUpdate; safecall;
    procedure _EndUpdate; safecall;
    procedure _SetFocus; safecall;
    procedure _KillFocus; safecall;
    function GetFileName : string; safecall;
    procedure _LoadFromFile(Const filename : string); safecall;
    procedure _Show; safecall;
    procedure _Hide; safecall;
    procedure _SetViewRect(left, top, right, bottom : Integer); safecall;
    procedure _SetParent(Parent : HWND); safecall;
  end;

  IEceDocumentLoader = interface
    function GetName: string; safecall;
    function GetTitle: string; safecall;
    function CheckDocument(AApp : IEceApplication; AFileName : string) : Boolean; safecall;
    function CreateDocument(AApp : IEceApplication; AFileName: string; var IDoc: IEceDocument;
      var ErrResult: string): Boolean; safecall;
  end;

  IEceLine = interface;
  IGutter = interface;
  ICaret = interface;

  IEceEditor = interface
  ['{AE254231-D4EE-405D-B402-9354A5CD340C}']
    function _GetHandle: HWND; safecall;
    function _GetLinesCount: integer; safecall;
    function _GetLines(AIndex: integer): IEceLine; safecall;
    function _GetGutter: IGutter; safecall;
    function _GetCaret: ICaret; safecall;
    function _AddLine: IEceLine; safecall;
    function _InsertLine(Index: integer): IEceLine; safecall;
    procedure _DeleteLine(Index: integer); safecall;
    procedure _Invalidate(); safecall;
    procedure _InvalidateLine(ALineIndex : Integer); safecall;
  end;

  IEceLine = interface
    function _GetText: string; safecall;
    function _SetText(Text: string): integer; safecall;
    function _GetIndex: integer; safecall;
    procedure _Insert(AValue : string; AChar : integer); safecall;
  end;

  IGutter = interface

  end;

  ICaret = interface
    function _GetX: integer; safecall;
    function _GetY: integer; safecall;
    function _GetLine: integer; safecall;
    function _SetX(value: integer): integer; safecall;
    function _SetY(value: integer): integer; safecall;
  end;

  IEcePlugin = interface
    function Load(App: IEceApplication): Boolean; safecall;
    procedure UnLoad(App: IEceApplication); safecall;
  end;

  IEceEditorPlugin = interface
    function Load(Editor: IEceEditor): Boolean; safecall;
  end;

implementation

initialization

{ InitializeCriticalSection(SyncObject); }
finalization

end.
