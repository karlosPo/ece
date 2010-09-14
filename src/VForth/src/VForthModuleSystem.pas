unit VForthModuleSystem;

interface

uses
  SysUtils,
  VForthModule,
  VForth;

type
  EVForthModuleSystemError = class(Exception)

  end;

  TVForthModuleSystem = class(TVForthModule, IVForthModule)
  private

  protected

  public
    procedure Register(AMachine: IVForthMachine); stdcall;
  end;

implementation

uses
  VForthAthom,
  VForthVariants,
  VForthVariantArray;

// ������������ ����� �������
//������������ ���� ����� ������������ ������ ����� ������� 7-�
//� 0-�� �� 7-�
procedure VfStack(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
begin
  AMachine.Stack := TForthStack(AMachine.PopInt);
end;

procedure VfGetStack(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
begin
  AMachine.PushInt(Integer(AMachine.Stack));
end;

// ������������ ���� ������� ��������� �����
procedure VfSwap(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
var
  v: IVForthVariant;
begin
  v := AMachine.DataStack[0];
  AMachine.DataStack[0] := AMachine.DataStack[1];
  AMachine.DataStack[1] := v;
end;

// ������������ �������� �������� �����
procedure VfDup(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
var
  v: IVForthVariant;
begin
  v := AMachine.DataStack[0];
  AMachine.Push(v.Convert(v.VariantType));
end;

// ������������ ������ �������� �������� �����
procedure VfDupVar(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
var
  v: IVForthVariant;
begin
  v := AMachine.DataStack[0];
  AMachine.Push(v);
end;

// ����������� ������� �������� � ���������� ����� � ������� �����.
procedure VfOver(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
var
  v: IVForthVariant;
begin
  v := AMachine.DataStack[1];
  AMachine.Push(v.Convert(v.VariantType));
end;

// ���������� �������� �������� � ������� �����.
procedure VfRot(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
begin
  AMachine.Push(AMachine.PopEx(2));
end;

// �������� �� ����� �������� ��������.
procedure VfDrop(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
begin
  AMachine.Pop;
end;

// �������� n-� ������� ����� � �������
procedure VfPick(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
var
  v: IVForthVariant;
begin
  v := AMachine.DataStack[AMachine.PopInt];
  AMachine.Push(v.Convert(v.VariantType));
end;

//������� �� ����� ������ ������ �����, ������� ������� �� ��� �����
procedure VfNip(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
begin
  AMachine.PopEx(1)
end;

//������� N ������� ����� �����. 1 ROLL ���������� SWAP
procedure VfRoll(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
begin
  AMachine.Push(AMachine.PopEx(AMachine.PopInt));
end;

procedure VfPickVar(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
var
  v: IVForthVariant;
begin
  v := AMachine.DataStack[AMachine.PopInt];
  AMachine.Push(v);
end;


// ������� ���� �� �����
procedure VfViewStack(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
var
  i: Integer;
  v: IVForthVariant;
begin
  for i := 0 to AMachine.DataStackSize - 1 do
  begin
    v := AMachine.DataStack[i];
    if v.Name = '' then
      AMachine.StdOut(VariantTypeToString(v.VariantType)
          + '=' + v.StringValue + #13#10)
    else
      AMachine.StdOut(VariantTypeToString(v.VariantType)
          + '(' + v.Name + ')=' + v.StringValue + #13#10);
  end;
end;

// ������� ����
procedure VfClearStack(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
var
  i: Integer;
begin
  for i := 0 to AMachine.DataStackSize - 1 do
    AMachine.Pop;
end;

procedure VfViewDictionary(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
var
  i: Integer;
  A: IVForthAthom;
begin
  AMachine.StdOut('Dictionary size: ' + IntToStr(AMachine.AthomsCount)
      + #13#10);
  for i := 0 to AMachine.AthomsCount - 1 do
  begin
    A := AMachine.AthomByIndex[i];
    AMachine.StdOut(A.Name + #9);
  end;
end;

procedure VfForget(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
var
  AAthomStr: string;
begin
  AAthomStr := AMachine.GetTk(AMachine.CourientTkIndex + 1);
  AMachine.CourientTkIndex := AMachine.CourientTkIndex + 1;
  AMachine.Forget(AAthomStr);
end;

procedure VfHelp(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
var
  AAthomStr: string;
  i: Integer;
begin
  AAthomStr := '';
  i := AMachine.CourientTkIndex;
  while i < AMachine.TkCount - 1 do
  begin
    inc(i);
    if AAthomStr = '' then
      AAthomStr := AMachine.GetTk(i)
    else
      AAthomStr := AAthomStr + #32 + AMachine.GetTk(i);
  end;
  AMachine.CourientTkIndex := AMachine.TkCount - 1;
  { TODO -oOnno -cGeneral : ����� ������� }
  // ������ ������ �� ����� ������ ���
  // help ������������ �����
  if AAthomStr <> '' then
    AMachine.StdErr('Topic "' + AAthomStr + '" not found.')
  else
  begin
    AMachine.StdOut('VForth machine v0.0'#13#10);
    AMachine.StdOut('Input "help <keywords line>" for get help.'#13#10);
    AMachine.StdOut('Input ".d" to view dictionary');
  end;
end;

// ��������� ���������� � ������� ����� ���
procedure VfCreate(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
var
  AVariableName: string;
begin
  AVariableName := AMachine.GetTk(AMachine.CourientTkIndex + 1);
  AMachine.CourientTkIndex := AMachine.CourientTkIndex + 1;
  AMachine.DataStack[0].Name := AVariableName;
end;

// ������������ ��� ���������� �� ������� �����
procedure VfSetVariable(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
var
  AVariableName: string;
  v0, v1: IVForthVariant;
begin
  v0 := AMachine.Pop;
  v1 := AMachine.Pop;
  case v0.VariantType of
    vtInteger:
      v0.IntValue := v1.IntValue;
    vtFloat:
      v0.FloatValue := v1.FloatValue;
    vtString:
      v0.StringValue := v1.StringValue
    else
      raise EVForthModuleSystemError.Create('Can''t set varible');
  end;
end;

// ������ ����� �������� ���������� �� �����
procedure VfGetVariable(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
var
  v0: IVForthVariant;
begin
  v0 := AMachine.Pop;
  AMachine.Push(v0.Convert(v0.VariantType));
end;

// ������� ������ ����������
procedure VfVector(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
var
  AVariableName: string;
  arr: TArrayVariant;
begin
  // ������ Array
  arr := TArrayVariant.Create;
  arr.Size := AMachine.PopInt;
  AMachine.Push(arr);
end;

// ������������ ��� ���������� �� ������� �����
// �������� ������ ������ v!
procedure VfVectorSetVariable(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
var
  v0, v1, v2: IVForthVariant;
begin
  v0 := AMachine.Pop;
  v1 := AMachine.Pop;
  v2 := AMachine.Pop;
  v0.Items[v1.IntValue] := v2;
end;

// ������ ����� �������� ���������� �� �����
// ������ ������ v@
procedure VfVectorGetVariable(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
var
  v0, v1: IVForthVariant;
begin
  v0 := AMachine.Pop;
  v1 := AMachine.Pop;
  AMachine.Push(v0.Items[v1.IntValue]);
end;

procedure VfGetVectorSize(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
begin
  AMachine.PushInt(AMachine.Pop.Size);
end;

procedure VfSetVectorSize(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
var
  v0, v1: IVForthVariant;
begin
  v0 := AMachine.Pop;
  v1 := AMachine.Pop;
  v0.Size := v1.IntValue;
end;

// ���������

procedure VfRecord(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
begin
  //������ � ���� �� ����� ��������, � ������� �����������
  AMachine.PushAddr(AMachine.DataStackSize);
end;

procedure VfEnd(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
var
  NewSize : Integer;
  A : TArrayVariant;
  i: Integer;
begin
  //������� ����� ���������� ���������� � ��� ���� ����������� ����
  NewSize := AMachine.DataStackSize - AMachine.PopAddr;
  if NewSize <= 0 then
    raise EVForthModuleSystemError.Create('Can''t create record. Stack must grow.');
  A :=TArrayVariant.Create;
  a.Size := NewSize;
  for i := 0 to NewSize - 1 do
  begin
    a.Items[i] := AMachine.Pop;
  end;
  AMachine.Push(a);
end;

// ���������� � ����

procedure VfCInt(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
begin
  AMachine.Push(AMachine.Pop.Convert(vtInteger));
end;

procedure VfCFloat(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
begin
  AMachine.Push(AMachine.Pop.Convert(vtFloat));
end;

procedure VfCNatural(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
begin
  AMachine.Push(AMachine.Pop.Convert(vtNatural));
end;

procedure VfCComplex(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
begin
  AMachine.Push(AMachine.Pop.Convert(vtComplex));
end;

procedure VfCStr(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
begin
  AMachine.Push(AMachine.Pop.Convert(vtString));
end;

procedure VfWin32Type(AMachine: IVForthMachine; AAthom: IVForthAthom;
  PAthomStr: PWideChar); stdcall;
var
  str: string;
  wt: TWin32Type;
begin
  str := LowerCase(PAthomStr);
  if str = 'w32bool' then
    wt := wtBool
  else if str = 'w32byte' then
    wt := wtByte
  else if str = 'w32word' then
    wt := wtWord
  else if str = 'w32int' then
    wt := wtInt
  else if str = 'w32chara' then
    wt := wtCharA
  else if str = 'w32charw' then
    wt := wtCharW
  else if str = 'w32pchara' then
    wt := wtPCharA
  else if str = 'w32pcharw' then
    wt := wtPCharW
  else if str = 'w32pointer' then
    wt := wtPointer;
  AMachine.DataStack[0].Win32Type := wt;
end;

{ TVForthModuleSystem }

procedure TVForthModuleSystem.Register(AMachine: IVForthMachine);
begin
  AMachine.AddAthom(CreateVForthSystemAthom('stack', Self, vfStack));
  AMachine.AddAthom(CreateVForthSystemAthom('stack@', Self, vfGetStack));

  AMachine.AddAthom(CreateVForthSystemAthom('swap', Self, VfSwap));
  AMachine.AddAthom(CreateVForthSystemAthom('dup', Self, VfDup));
  AMachine.AddAthom(CreateVForthSystemAthom('dup*', Self, VfDupVar));
  AMachine.AddAthom(CreateVForthSystemAthom('over', Self, VfOver));
  AMachine.AddAthom(CreateVForthSystemAthom('rot', Self, VfRot));
  AMachine.AddAthom(CreateVForthSystemAthom('drop', Self, VfDrop));

  AMachine.AddAthom(CreateVForthSystemAthom('pick', Self, VfPick));
  AMachine.AddAthom(CreateVForthSystemAthom('pick*', Self, VfPickVar));

  AMachine.AddAthom(CreateVForthSystemAthom('nip', Self, VfNip));
  AMachine.AddAthom(CreateVForthSystemAthom('roll', Self, VfRoll));

  AMachine.AddAthom(CreateVForthSystemAthom('.s', Self, VfViewStack));
  AMachine.AddAthom(CreateVForthSystemAthom('.c', Self, VfClearStack));
  AMachine.AddAthom(CreateVForthSystemAthom('.d', Self, VfViewDictionary));
  AMachine.AddAthom(CreateVForthSystemAthom('forget', Self, VfForget));
  AMachine.AddAthom(CreateVForthSystemAthom('help', Self, VfHelp));

  AMachine.AddAthom(CreateVForthSystemAthom('var', Self, VfCreate));
  AMachine.AddAthom(CreateVForthSystemAthom('!', Self, VfSetVariable));
  AMachine.AddAthom(CreateVForthSystemAthom('@', Self, VfGetVariable));
  AMachine.AddAthom(CreateVForthSystemAthom('vector', Self, VfVector));
  AMachine.AddAthom(CreateVForthSystemAthom('v!', Self, VfVectorSetVariable));
  AMachine.AddAthom(CreateVForthSystemAthom('v@', Self, VfVectorGetVariable));
  AMachine.AddAthom(CreateVForthSystemAthom('vs!', Self, VfSetVectorSize));
  AMachine.AddAthom(CreateVForthSystemAthom('vs@', Self, VfGetVectorSize));

  AMachine.AddAthom(CreateVForthSystemAthom('record', Self, VfRecord));
  AMachine.AddAthom(CreateVForthSystemAthom('end', Self, VfEnd));

  AMachine.AddAthom(CreateVForthSystemAthom('cint', Self, VfCInt));
  AMachine.AddAthom(CreateVForthSystemAthom('cfloat', Self, VfCFloat));
  AMachine.AddAthom(CreateVForthSystemAthom('cnatural', Self, VfCNatural));
  AMachine.AddAthom(CreateVForthSystemAthom('ccomplex', Self, VfCComplex));
  AMachine.AddAthom(CreateVForthSystemAthom('cstr', Self, VfCStr));

  AMachine.AddAthom(CreateVForthSystemAthom('w32Bool', Self, VfWin32Type));
  AMachine.AddAthom(CreateVForthSystemAthom('w32Byte', Self, VfWin32Type));
  AMachine.AddAthom(CreateVForthSystemAthom('w32Word', Self, VfWin32Type));
  AMachine.AddAthom(CreateVForthSystemAthom('w32Int', Self, VfWin32Type));
  AMachine.AddAthom(CreateVForthSystemAthom('w32CharA', Self, VfWin32Type));
  AMachine.AddAthom(CreateVForthSystemAthom('w32CharW', Self, VfWin32Type));
  AMachine.AddAthom(CreateVForthSystemAthom('w32PCharA', Self, VfWin32Type));
  AMachine.AddAthom(CreateVForthSystemAthom('w32PCharW', Self, VfWin32Type));
  AMachine.AddAthom(CreateVForthSystemAthom('w32Pointer', Self, VfWin32Type));
end;

end.