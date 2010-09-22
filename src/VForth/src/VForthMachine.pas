unit VForthMachine;
{$IFDEF fpc}{$MODE delphi}{$ENDIF}

interface

{ TODO -oOnni -cGeneral : ��� ������ � "������� ������"
  ����������� ��������� ����� }
{$DEFINE QAthomStack}

uses
  VForth,
  VForthModule,
  Windows,
  SysUtils,
  Classes,
  Contnrs;

type
  EVForthMachineError = class(Exception)
  end;

  // ��������� ������
  PQStruct = ^TQStruct;

  TQStruct = record
    Time: Cardinal; // ���� ��������� ��������� ����� ������
    TkType: Byte; // ��� ������
    case integer of
      0:
        (Index: integer); // ������ �����
      1:
        (Data: Pointer); // ������
      2:
        (PStr: PString); // ������
      3:
        (PInt: PInteger); // �����
      4:
        (PFloat: PDouble); // �����
  end;

  TVForthMachine = class(TVForthModule, IVForthMachine, IVForthModule)
  private
    // ���� ����������
    FDataStack: TInterfaceList;
    FStack: TForthStack;
    FStacks: array [TForthStack] of TInterfaceList;
    // ���� ������� ��������
    FAdressStack: TList;
    // ���� ������
    FAthomStack: TInterfaceList;
    // ���� ��� ��������� ������� � ������
{$IFDEF QAthomStack}
    FQAthomStack: TStringList;
{$ENDIF}
    // ���� ����������
    FVaribleStack: TInterfaceList;
    // ����������
    FCourientTkIndex: integer;
    FCourientTk: TStringList;
    // IO
    FIO: IVForthIO;
    // ����� ���������� ���������� ����� ������
    FLastAthomsUpdateTime: Cardinal;
    function GetAthom(const AAthom: String): IVForthAthom; stdcall;
    function TryGetAthom(Const AAthom: string; var obj: IVForthAthom): Boolean;
      stdcall;
{$IFDEF QAthomStack}
    function TryGetAthomQ(Const AAthom: string; var obj: IVForthAthom): Boolean;
{$ENDIF}
    procedure ClearTkList(l: TStringList);
    function GetDataStack(const index: integer): IVForthVariant; stdcall;
    procedure SetDataStack(const index: integer; const Value: IVForthVariant);
      stdcall;

    procedure ParseString(ACode: string; TkList: TStringList);
    procedure ExecuteTkList(TkList: TStringList);
    function GetCourientTkIndex: integer; stdcall;
    procedure SetCourientTkIndex(const Value: integer); stdcall;
    function GetTkCount: integer; stdcall;
    function GetDataStackSize: integer; stdcall;
    function GetAthomsCount: integer; stdcall;
    function GetAthomByIndex(const AAthom: integer): IVForthAthom; stdcall;
    function GetVarible(AVaribleName: string): IVForthVariant; stdcall;
    function GetStack: TForthStack; stdcall;
    procedure SetStack(const Value: TForthStack); stdcall;
  protected

  public
    constructor Create;
    destructor Destroy; override;

    procedure Register(AMachine: IVForthMachine); stdcall;

    procedure SetIo(AIO: IVForthIO); stdcall;
    function StdIn: string; stdcall;
    procedure StdOut(str: string); stdcall;
    procedure StdErr(str: string); stdcall;

    procedure LoadModule(AModule: IVForthModule); stdcall;
    procedure AddAthom(AAthom: IVForthAthom); stdcall;
    procedure AddCode(ACode: string); stdcall;

    property DataStack[const index: integer]
      : IVForthVariant read GetDataStack write SetDataStack;
    property DataStackSize: integer read GetDataStackSize;
    property Athom[const AAthom: String]: IVForthAthom read GetAthom;
    property AthomByIndex[const AAthom: integer]
      : IVForthAthom read GetAthomByIndex;
    property AthomsCount: integer read GetAthomsCount;
    procedure Forget(AAthom: string); stdcall;

    property Varible[AVaribleName: string]: IVForthVariant read GetVarible;

    property Stack: TForthStack read GetStack write SetStack;

    procedure Push(AVariant: IVForthVariant); stdcall;
    function Pop: IVForthVariant; stdcall;
    procedure PushEx(index: integer; AVariant: IVForthVariant); stdcall;
    function PopEx(index: integer): IVForthVariant; stdcall;
    procedure PushInt(AVariant: integer); stdcall;
    function PopInt: integer; stdcall;
    procedure PushFloat(AVariant: Double); stdcall;
    function PopFloat: Double; stdcall;
    procedure PushString(AVariant: string); stdcall;
    function PopString: string; stdcall;
    procedure PushNatural(AVariant1, AVariant2: integer); stdcall;
    procedure PushComplex(AVariant1, AVariant2: Double); stdcall;
    // ����������

    // ���� �������
    procedure PushAddr(AValue: integer); stdcall;
    function ReturnAddr: integer; stdcall;
    function PopAddr: integer; stdcall;
    property CourientTkIndex: integer read GetCourientTkIndex write
      SetCourientTkIndex;
    property TkCount: integer read GetTkCount;
    function GetTk(index: integer): string; stdcall;
  end;
{$IFDEF fpc}

const
  CSTR_EQUAL = 2;
{$ENDIF}

implementation

uses
  VForthAthom,
  VForthVariants;

type
  TVForthAthom = class(TInterfacedObject, IVForthAthom)
  private
    FTk: TStringList;
    FMachine: TVForthMachine;
    FName: string;
    FModule: IVForthModule;
    function GetName: String; stdcall;
    function GetModule: IVForthModule; stdcall;
  public
    destructor Destroy; override;
    property Name: string read GetName;
    property Module: IVForthModule read GetModule;
    procedure Execute(AMachine: IVForthMachine; PAthomStr: PWideChar); stdcall;
  end;

resourcestring
  StrStackIsEmpty = 'Stack is empty';
  StrAthomSNotFound = 'Athom "%s" not found.';
  StrStackItemDOutOf = 'Stack item (%d) out of range.';

  { TVForthMachine }

const
  // ����� �� ���������
  TK_NULL = 0;
  // ����������
  TK_INTEGER = 1;
  TK_FLOAT = 2;
  TK_NATURAL = 3;
  TK_COMPLEX = 4;
  TK_STRING = 5;
  // ����
  TK_ATHOM = 6;
  // ���������� ������ �����
  TK_NEWATHOM = 7;
  // ����������
  TK_VARIABLE = 8;
  TK_VARIABLECLONE = 9;

const
  SpaceChars = [#9, #10, #13, #32];

type
  TTokenType = (tkNull = integer(TK_NULL), tkInteger = integer(TK_INTEGER),
    tkFloat = integer(TK_FLOAT), tkNatural = integer(TK_NATURAL),
    tkComplex = integer(TK_COMPLEX), tkString = integer(TK_STRING),
    tkAthom = integer(TK_ATHOM), tkNewAthom = integer(TK_NEWATHOM),
    tkVariable = integer(TK_VARIABLE), tkVariableClone = TK_VARIABLECLONE);

procedure TVForthMachine.ParseString(ACode: string; TkList: TStringList);

var
  SChar, CChar, EChar: PChar;
  TempTk: TStringList;
  StackPos: integer;
  v: IVForthVariant;
  IIndex: integer;
{$REGION '��������� ��� ��������'}
{$REGION 'ScanForSpaces'}
  procedure ScanForSpaces;
  begin
    repeat
      inc(CChar)
    until (not(CChar^ in SpaceChars)) or (CChar = EChar);
  end;
{$ENDREGION}
{$REGION 'ScanForString'}
  function ScanForString: string;
  begin
    SChar := CChar;
    repeat
      inc(CChar);
      { TODO -oOnni -cGeneral : ��������� ::;; }
    until (CChar^ = '"') or (CChar = EChar);
    // ������ � ��������� ������� �� ������ � ������
    Result := Copy(SChar, 2, CChar - SChar - 1);
    inc(CChar);
  end;
{$ENDREGION}
{$REGION 'ScanForNewAthom'}
  function ScanForNewAthom: string;
  begin
    SChar := CChar;
    repeat
      inc(CChar);
      { TODO -oOnni -cGeneral : ��������� ::;; }
    until (CChar^ = ';') or (CChar = EChar);
    // ������ � ��������� ������� �� ������ � ������
    Result := Copy(SChar, 2, CChar - SChar - 1);
    inc(CChar);
  end;
{$ENDREGION}
{$REGION 'ScanForComments'}
  function ScanForComments: string;
  begin
    SChar := CChar;
    repeat
      inc(CChar);
      // ��������� ������������� �� #32')'
    until ((CChar^ = ')') and ((CChar - 1)^ in SpaceChars)) or (CChar = EChar);
    // ������ � ��������� ������� �� ������ � ������
    // Result := Copy(SChar, 2, CChar - SChar - 1);
    inc(CChar);
  end;
{$ENDREGION}
{$REGION 'ScanForCmpMode'}
  function ScanForCmpMode: string;
  begin
    SChar := CChar;
    repeat
      inc(CChar);
      // ������������� �� #32']'
    until ((CChar^ = ']') and ((CChar - 1)^ in SpaceChars)) or (CChar = EChar);
    // ������ � ��������� ������� �� ������ � ������
    Result := Copy(SChar, 2, CChar - SChar - 1);
    inc(CChar);
  end;
{$ENDREGION}
{$REGION 'ScanForAthom'}
  function ScanForAthom: string;
  begin
    SChar := CChar;
    repeat
      inc(CChar)
    until (CChar^ in SpaceChars) or (CChar = EChar);
    Result := Copy(SChar, 1, CChar - SChar);
    inc(CChar); // ���������� ������ �� ����
  end;
{$ENDREGION}
{$REGION 'ScanForAthomAndAdd'}
  procedure ScanForAthomAndAdd;
  var
    Tk: String;
    n: integer;
    f: Double;
    a: IVForthAthom;
    index: integer;
  var
    pQtk: PQStruct;
  begin
    Tk := ScanForAthom;
    // �������� �� �����
    if TryStrToInt(Tk, n) then
    begin
      new(pQtk);
      pQtk^.TkType := TK_INTEGER;
      new(pQtk^.PInt);
      pQtk^.PInt^ := n;
      TkList.AddObject(Tk, TObject(pQtk))
    end
    else
    // �������� �� ������������
      if TryStrToFloat(Tk, f) then
    begin
      new(pQtk);
      pQtk^.TkType := TK_FLOAT;
      new(pQtk^.PFloat);
      pQtk^.PFloat^ := f;
      TkList.AddObject(Tk, TObject(pQtk))
    end
    else
    begin
      // �� ���� �� �������? ������ ������ ���� ��� ����������
      new(pQtk);
      // ����� ���������� ���������� ����� ������
      pQtk^.Time := FLastAthomsUpdateTime;
      index := FQAthomStack.IndexOf(Tk);

      if index <> -1 then
      begin
        pQtk^.TkType := TK_ATHOM;
        pQtk^.Index := index;
      end
      else
      begin
        pQtk^.TkType := TK_VARIABLE;
      end;

      TkList.AddObject(Tk, TObject(pQtk))
    end;
  end;
{$ENDREGION}
{$ENDREGION}

var
  pQtk: PQStruct;
  pI: ^IInterface;
begin
  SChar := PChar(ACode);
  CChar := SChar;
  EChar := SChar + Length(ACode);
  while (CChar < EChar) do
  begin
    case CChar^ of
      #9, #10, #13, #32:
{$REGION '���������� �������'}
        begin
          ScanForSpaces;
          continue;
        end;
{$ENDREGION}
      '"':
{$REGION '���� ������'}
        begin
          new(pQtk);
          pQtk.TkType := TK_STRING;
          TkList.AddObject(ScanForString, TObject(pQtk));
          continue;
        end;
{$ENDREGION}
      ':':
{$REGION '���� ���������� ������'}
        begin
          new(pQtk);
          pQtk.TkType := TK_NEWATHOM;
          TkList.AddObject(ScanForNewAthom, TObject(pQtk));
          continue;
        end;
{$ENDREGION}
      '(':
{$REGION '���� �����������'}
        begin
          // ��������� ���������� � '('#32
          if (CChar < EChar - 1) and ((CChar + 1)^ in SpaceChars) then
            ScanForComments
          else
            // ���� ���, �� ���� �����
            ScanForAthomAndAdd;
          continue;
        end;
{$ENDREGION}
      '[':
{$REGION '��������� � ����� ����������'}
        // �� ��� ��������� ����� ����������� �������� - ������������� �� ����
        // ����� ����� ������� ����� ����� ������� ���������� ����������� � ����
        // � �������� ����
        // 0 10 do@ [ 3,14 2 sqr *  ] * . space loop
        // �������� � ���� ���� ��������� "[ 3,14 2 sqr *  ]" ���������
        // ��� �� ������ �����, � ������ ���� �����  25,12
        // 0 10 do@ 25,12 * . space loop
        begin
          // ��������� ���������� � '('#32
          if (CChar < EChar - 1) and ((CChar + 1)^ in SpaceChars) then
          begin
            try
              TempTk := TStringList.Create;
              ParseString(ScanForCmpMode, TempTk);

              StackPos := DataStackSize;
              ExecuteTkList(TempTk);

              if DataStackSize < StackPos then
                raise EVForthMachineError.Create('Stack must grow');

              IIndex := 0;
              while DataStackSize > StackPos do
              begin
                new(pQtk);
                pQtk.TkType := TK_VARIABLECLONE;
                new(pI);
                pI^ := Pop;
                pQtk.Data := pI;
                TkList.InsertObject(TkList.Count - IIndex, '', TObject(pQtk));
                inc(IIndex);
              end;
            finally
              TempTk.Free;
            end;
          end
          else
            // ���� ���, �� ���� �����
            ScanForAthomAndAdd;
          continue;
        end;
{$ENDREGION}
    else
{$REGION '���� �� ���� �� ����� - ���� ����� (��� ��, ��� ����� �������� � ����)'}
      begin
        ScanForAthomAndAdd
        // continue
      end;
{$ENDREGION}
    end;
  end
end;

procedure TVForthMachine.AddAthom(AAthom: IVForthAthom);
var
  index: integer;
  pI: ^IInterface;
begin
  FAthomStack.Insert(0, AAthom);
  // ������ � "������� ������"
{$IFDEF QAthomStack}
  index := FQAthomStack.IndexOf(AAthom.Name);
  if index = -1 then
  begin
    new(pI);
    pI^ := AAthom;
    FQAthomStack.AddObject(AAthom.Name, TObject(pI));
    FQAthomStack.Sort;
    FQAthomStack.Sorted := true;
    // ���������
    inc(FLastAthomsUpdateTime);
  end
  else
  begin
    pI := Pointer(FQAthomStack.Objects[index]);
    pI^ := AAthom;
  end;
{$ENDIF}
end;

procedure TVForthMachine.AddCode(ACode: string);
var
  TkList: TStringList;
begin
  try
    TkList := TStringList.Create;
    ParseString(ACode, TkList);
    ExecuteTkList(TkList);
  finally
    ClearTkList(TkList);
    TkList.Free;
  end;
end;

procedure TVForthMachine.ExecuteTkList(TkList: TStringList);
var
  i: integer;
  TkLine: string;
  NewAthom: TVForthAthom;
  NewTkName: String;
  NewTkCode: String;
  SpPos: integer;
  FLastTkIndex: integer;
  a: IVForthAthom;
  pQtk: PQStruct;
  index: integer;
  pI: ^IInterface;
  v: IVForthVariant;
  AWideStr: WideString;
begin
  FLastTkIndex := FCourientTkIndex;
  i := -1;
  while i < TkList.Count - 1 do
  begin
    inc(i);
    FCourientTkIndex := i; // ��������� � �����
    FCourientTk := TkList;
    TkLine := TkList[i];
    pQtk := Pointer(TkList.Objects[i]);
    case TTokenType(pQtk^.TkType) of
      tkNull:
        raise EVForthMachineError.Create('Unknown token');
      tkInteger:
        PushInt(pQtk^.PInt^);
      tkFloat:
        PushFloat(pQtk^.PFloat^);
      tkNatural:
        ;
      tkComplex:
        ;
      tkString:
        PushString(TkLine);
      tkAthom, tkVariable:
        begin
{$IFDEF QAthomStack}
          if (pQtk^.Time <> FLastAthomsUpdateTime) then
          begin
{$REGION '������� �����'}
            index := FQAthomStack.IndexOf(TkLine);
            if index <> -1 then
            begin
              pQtk^.Index := index;
              pQtk^.TkType := TK_ATHOM;
              pI := Pointer(FQAthomStack.Objects[index]);
              a := IVForthAthom(pI^);
            end
            else
            begin
              pQtk^.TkType := TK_VARIABLE;
            end;
            pQtk^.Time := FLastAthomsUpdateTime;
{$ENDREGION}
          end
          else
          begin
{$REGION '������ ������� ����'}
            if pQtk^.TkType = TK_ATHOM then
            begin
              index := pQtk^.Index;
              pI := Pointer(FQAthomStack.Objects[index]);
              a := IVForthAthom(pI^);
            end
            else
            begin
              index := -1;
            end;
{$ENDREGION}
          end;
          if index <> -1 then
{$ELSE}
            if TryGetAthom(TkLine, a) then
{$ENDIF}
            begin
{$IFDEF fpc}
              {TODO -oOnni -cGeneral : ����� ��� FPC ���������}
              AWideStr := TkLine;
              a.Execute(Self, PWideChar(AWideStr));
{$ELSE}
              a.Execute(Self, PWideChar(TkLine));
{$ENDIF}
            end
            else
            begin
              Push(Varible[TkLine]);
            end;
          i := FCourientTkIndex; // ��������� � �����
        end;
      tkVariableClone:
        begin
          pQtk := Pointer(TkList.Objects[i]);
          pI := pQtk^.Data;
          v := IVForthVariant(pI^);
          // ������� ����
          Push(v.Convert(v.VariantType));
        end;
      tkNewAthom:
        begin
{$REGION '������������ ����� �����'}
          // ��� �� ��������� ����� � ����� TStringList, ������ ��� ����������
          // �� ����������� �� ������� �������
          SpPos := 0;
          repeat
            inc(SpPos)
          until (TkLine[SpPos] in SpaceChars) or (SpPos = Length(TkLine) + 1);
          NewTkName := Copy(TkLine, 1, SpPos - 1);
          Delete(TkLine, 1, SpPos);
          NewTkCode := TkLine;

          NewAthom := TVForthAthom.Create;
          NewAthom.FMachine := Self;
          NewAthom.FTk := TStringList.Create;
          ParseString(TkLine, NewAthom.FTk);
          NewAthom.FName := NewTkName;
          AddAthom(NewAthom);
{$ENDREGION}
        end;
    else
      { TODO -oOnni -cGeneral : NewAthom }
      begin
      end;
    end;
  end;
  FCourientTkIndex := FLastTkIndex;
end;

procedure TVForthMachine.Forget(AAthom: string);
var
  i: integer;
  a: IVForthAthom;
  AName: string;
  j: integer;
  index: integer;
  pI: ^IInterface;
begin
  for i := 0 to FAthomStack.Count - 1 do
  begin
    a := GetAthomByIndex(i);
    AName := a.Name;
    if Windows.CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, PChar(AAthom)
        , Length(AAthom), PChar(AName), Length(AName)) = CSTR_EQUAL then
    begin
      // �������� ��� ��� ���� �����
      for j := 0 to i do
      begin
{$IFDEF QAthomStack}
        // ������� �� "��������" �����
        index := FQAthomStack.IndexOf(AthomByIndex[0].Name);
        if index <> -1 then
        begin
          pI := Pointer(FQAthomStack.Objects[index]);
          pI^ := nil;
          // FQAthomStack.Delete(index);
        end;
{$ENDIF}
        // ������� �� �������
        FAthomStack.Delete(0);
{$IFDEF QAthomStack}
        // ���� ������ ���������� ����
        if index <> -1 then
        begin
          if TryGetAthom(AAthom, IVForthAthom(pI^)) then
          begin
            FQAthomStack.Objects[index] := TObject(pI);
          end
          else
          begin
            Dispose(pI);
            FQAthomStack.Delete(index);
            // ���������
            inc(FLastAthomsUpdateTime);
          end;
        end;
{$ENDIF}
      end;
      // ���������
{$IFDEF QAthomStack}
      FQAthomStack.Sort;
      FQAthomStack.Sorted := true;
{$ENDIF}
      // �������
      exit;
    end;
  end;
  // ������ ��
  raise EVForthMachineError.CreateFmt('Can''t forget athom "%s"', [AAthom]);
end;

procedure TVForthMachine.ClearTkList(l: TStringList);
var
  i: integer;
  pQtk: PQStruct;
  pI: ^IInterface;
begin
  for i := 0 to l.Count - 1 do
  begin
    pQtk := Pointer(l.Objects[i]);
    case TTokenType(pQtk^.TkType) of
      tkInteger:
        Dispose(pQtk^.PInt);
      tkFloat:
        Dispose(pQtk^.PFloat);
      tkNatural, tkComplex:
        raise Exception.Create('����������');
      tkVariableClone:
        begin
          pI := pQtk^.Data;
          pI^ := nil;
          Dispose(pI);
        end;
    end;
  end;
  l.Clear;
end;

constructor TVForthMachine.Create;
var
  s: TForthStack;
begin
  inherited;
  for s := low(s) to high(s) do
    FStacks[s] := TInterfaceList.Create;

  Stack := fsUser; // FDataStack := FStacks[fsUser]
  FAdressStack := TList.Create;
  FAthomStack := TInterfaceList.Create;
{$IFDEF QAthomStack}
  FQAthomStack := TStringList.Create;
{$ENDIF}
  FVaribleStack := TInterfaceList.Create;
end;

destructor TVForthMachine.Destroy;
var
  s: TForthStack;
  i: integer;
  pI: ^IInterface;
begin
  if Assigned(FVaribleStack) then
    FVaribleStack.Free;
  if Assigned(FAthomStack) then
    FAthomStack.Free;
{$IFDEF QAthomStack}
  if Assigned(FQAthomStack) then
  begin
    { DONE -oOnni -cGeneral : FQAthomStack.Clear }
    for i := 0 to FQAthomStack.Count - 1 do
    begin
      pI := Pointer(FQAthomStack[i]);
      pI^ := nil;
      Dispose(pI);
    end;
    FQAthomStack.Clear;
    FQAthomStack.Free;
  end;
{$ENDIF}
  if Assigned(FAdressStack) then
    FAdressStack.Free;
  FDataStack := nil;
  for s := low(s) to high(s) do
    if Assigned(FStacks[s]) then
      FStacks[s].Free;
  inherited;
end;

function TVForthMachine.GetAthom(const AAthom: String): IVForthAthom;
var
  Athom: IVForthAthom;
  i: integer;
  len: integer;
  AName: String;
begin
  if not TryGetAthom(AAthom, Result) then

    raise EVForthMachineError.CreateFmt(StrAthomSNotFound, [AAthom]);
end;

function TVForthMachine.TryGetAthom(const AAthom: string; var obj: IVForthAthom)
  : Boolean;
var
  Athom: IVForthAthom;
  i: integer;
  len: integer;
  AName: String;
begin
  len := Length(AAthom);
  for i := 0 to FAthomStack.Count - 1 do
  begin
    Athom := IVForthAthom(FAthomStack[i]);
    AName := Athom.Name;
    if Windows.CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, PChar(AAthom)
        , len, PChar(AName), Length(AName)) = CSTR_EQUAL then
    begin
      obj := Athom;
      exit(true);
    end;
  end;
  exit(false);
end;
{$IFDEF QAthomStack}

function TVForthMachine.TryGetAthomQ(const AAthom: string;
  var obj: IVForthAthom): Boolean;
var
  Athom: IVForthAthom;
  index: integer;
  pI: ^IInterface;
begin
  index := FQAthomStack.IndexOf(AAthom);
  if index = -1 then
    exit(false)
  else
  begin
    pI := Pointer(FQAthomStack.Objects[index]);
    obj := IVForthAthom(pI^);
    Result := true;
  end;
end;
{$ENDIF}

function TVForthMachine.GetAthomByIndex(const AAthom: integer): IVForthAthom;
begin
  Result := IVForthAthom(FAthomStack[AAthom]);
end;

function TVForthMachine.GetAthomsCount: integer;
begin
  Result := FAthomStack.Count;
end;

function TVForthMachine.GetCourientTkIndex: integer;
begin
  Result := FCourientTkIndex;
end;

function TVForthMachine.GetDataStack(const index: integer): IVForthVariant;
begin
  if (index >= FDataStack.Count) or (index < 0) then
    raise EVForthMachineError.CreateFmt(StrStackItemDOutOf, [index]);
  Result := IVForthVariant(FDataStack[index]);
end;

function TVForthMachine.GetDataStackSize: integer;
begin
  Result := FDataStack.Count;
end;

function TVForthMachine.GetStack: TForthStack;
begin
  Result := FStack;
end;

function TVForthMachine.GetTk(index: integer): string;
begin
  Result := FCourientTk[index];
end;

function TVForthMachine.GetTkCount: integer;
begin
  Result := FCourientTk.Count;
end;

function TVForthMachine.GetVarible(AVaribleName: string): IVForthVariant;
var
  i: integer;
  v: IVForthVariant;
  Ln: integer;
  Vname: string;
  VLen: integer;
begin
  Ln := Length(AVaribleName);
  for i := 0 to FDataStack.Count - 1 do
  begin
    v := DataStack[i];
    Vname := v.Name;
    VLen := Length(Vname);
    if VLen = 0 then
      continue;
    if Windows.CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, PChar
        (AVaribleName), Ln, PChar(Vname), VLen) = CSTR_EQUAL then
    begin
      exit(v);
    end;
  end;
  raise EVForthMachineError.CreateFmt
    ('Variable "%s" not found', [AVaribleName]);
end;

procedure TVForthMachine.LoadModule(AModule: IVForthModule);
begin
  AModule.Register(Self);
end;

function TVForthMachine.Pop: IVForthVariant;
begin
  if FDataStack.Count = 0 then
    raise EVForthMachineError.Create(StrStackIsEmpty);
  Result := IVForthVariant(FDataStack[0]);
  FDataStack.Delete(0);
end;

function TVForthMachine.PopAddr: integer;
begin
  Result := ReturnAddr;
  FAdressStack.Delete(0);
end;

function TVForthMachine.PopEx(index: integer): IVForthVariant;
begin
  Result := DataStack[index];
  FDataStack.Delete(index);
end;

function TVForthMachine.PopFloat: Double;
begin
  Result := Pop.FloatValue;
end;

function TVForthMachine.PopInt: integer;
begin
  Result := Pop.IntValue;
end;

function TVForthMachine.PopString: string;
begin
  Result := Pop.StringValue;
end;

procedure TVForthMachine.Push(AVariant: IVForthVariant);
begin
  FDataStack.Insert(0, AVariant);
end;

procedure TVForthMachine.PushAddr(AValue: integer);
begin
  FAdressStack.Insert(0, Pointer(AValue));
end;

procedure TVForthMachine.PushComplex(AVariant1, AVariant2: Double);
begin
  Push(CreateComplexVariant(AVariant1, AVariant2));
end;

procedure TVForthMachine.PushEx(index: integer; AVariant: IVForthVariant);
begin
  if (index > FDataStack.Count) or (index < 0) then
    raise EVForthMachineError.CreateFmt(StrStackItemDOutOf, [index]);
  FDataStack.Insert(index, AVariant);
end;

procedure TVForthMachine.PushFloat(AVariant: Double);
begin
  Push(CreateFloatVariant(AVariant));
end;

procedure TVForthMachine.PushInt(AVariant: integer);
begin
  Push(CreateIntegerVariant(AVariant));
end;

procedure TVForthMachine.PushNatural(AVariant1, AVariant2: integer);
begin
  Push(CreateNaturalVariant(AVariant1, AVariant2));
end;

procedure TVForthMachine.PushString(AVariant: string);
begin
  Push(CreateStringVariant(AVariant));
end;

procedure TVForthMachine.Register(AMachine: IVForthMachine);
begin

end;

function TVForthMachine.ReturnAddr: integer;
begin
  if FAdressStack.Count = 0 then
    raise EVForthMachineError.Create('Address stack is empty.');
  Result := integer(FAdressStack[0]);
end;

procedure TVForthMachine.SetCourientTkIndex(const Value: integer);
begin
  FCourientTkIndex := Value;
end;

procedure TVForthMachine.SetDataStack(const index: integer;
  const Value: IVForthVariant);
begin
  if (index >= FDataStack.Count) or (index < 0) then
    raise EVForthMachineError.CreateFmt(StrStackItemDOutOf, [index]);
  FDataStack[index] := Value;
end;

procedure TVForthMachine.SetIo(AIO: IVForthIO);
begin
  FIO := AIO;
end;

procedure TVForthMachine.SetStack(const Value: TForthStack);
begin
  if Value in [ low(TForthStack) .. High(TForthStack)] then
  begin
    FDataStack := FStacks[Value];
    FStack := Value;
  end
  else
    raise EVForthMachineError.CreateFmt
      ('Bad stack index (%d)', [integer(Value)]);
end;

procedure TVForthMachine.StdErr(str: string);
begin
  try
    FIO.StdErr(str);
  except
    AllocConsole;
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),
      FOREGROUND_RED or FOREGROUND_INTENSITY);
    Write(str);
  end;
end;

function TVForthMachine.StdIn: string;
var
  s: string;
begin
  try
    Result := FIO.StdIn;
  except
    AllocConsole;
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),
      FOREGROUND_BLUE or FOREGROUND_GREEN or FOREGROUND_RED or
        FOREGROUND_INTENSITY);
    write('> ');
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),
      FOREGROUND_BLUE or FOREGROUND_GREEN or FOREGROUND_RED);
    Readln(s);
    Result := s;
  end;
end;

procedure TVForthMachine.StdOut(str: string);
begin
  try
    FIO.StdOut(str);
  except
    AllocConsole;
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),
      FOREGROUND_GREEN or FOREGROUND_INTENSITY);
    Write(str);
  end;
end;

{ TVForthAthom }

destructor TVForthAthom.Destroy;
begin
  if Assigned(FTk) then
  begin
    FMachine.ClearTkList(FTk);
    FTk.Free;
  end;
  inherited;
end;

procedure TVForthAthom.Execute(AMachine: IVForthMachine; PAthomStr: PWideChar);
begin
  FMachine.ExecuteTkList(FTk);
end;

function TVForthAthom.GetModule: IVForthModule;
begin
  Result := FModule;
end;

function TVForthAthom.GetName: String;
begin
  Result := FName;
end;

end.
