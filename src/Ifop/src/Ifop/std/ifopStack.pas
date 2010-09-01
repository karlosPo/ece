unit ifopStack;

interface

procedure RegisterDictionary(AKernel: TObject);

implementation

uses
  SysUtils,
  IfopKernel,
  IfopVariant;

// ������������ ���� ������� ��������� �����.
procedure ifopSwap(Kernel: TIfopKernel);
var
  v1, v2: TIfopVariant;
begin
  v1 := Kernel.Pop;
  v2 := Kernel.Pop;
  Kernel.Push(v1);
  Kernel.Push(v2);
end;

// ������������ �������� �������� �����.
procedure ifopDup(Kernel: TIfopKernel);
begin
  Kernel.Push(Kernel.Stack[0].GetClone);
end;

// ����������� ������� �������� � ���������� ����� � ������� �����.
procedure ifopOver(Kernel: TIfopKernel);
begin
  Kernel.Push(Kernel.Stack[1].GetClone);
end;

// ���������� �������� �������� � ������� �����.
procedure ifopRot(Kernel: TIfopKernel);
var
  v1, v2, v3: TIfopVariant;
begin
  v1 := Kernel.Pop;
  v2 := Kernel.Pop;
  v3 := Kernel.Pop;
  Kernel.Push(v2);
  Kernel.Push(v1);
  Kernel.Push(v3);
end;

// �������� �� ����� �������� ��������.
procedure ifopDrop(Kernel: TIfopKernel);
begin
  Kernel.Pop.Free;
end;

//������������ ���� ������� ��� �����.
procedure ifop2Swap(Kernel: TIfopKernel);
var
  v1, v2, v3, v4: TIfopVariant;
begin
  v1 := Kernel.Pop;
  v2 := Kernel.Pop;
  v3 := Kernel.Pop;
  v4 := Kernel.Pop;
  Kernel.Push(v2);
  Kernel.Push(v1);
  Kernel.Push(v4);
  Kernel.Push(v3);
end;
//������������ ���� �����, ����������� � ������� �����.
procedure ifop2Dup(Kernel: TIfopKernel);
begin
  Kernel.Push(Kernel.Stack[1].GetClone);
  Kernel.Push(Kernel.Stack[1].GetClone);
end;

//����������� ������ ���� ����� � ���������� ����� � ������� �����.
procedure ifop2Over(Kernel: TIfopKernel);
begin
  Kernel.Push(Kernel.Stack[3].GetClone);
  Kernel.Push(Kernel.Stack[3].GetClone);
end;

procedure ifop2Drop(Kernel: TIfopKernel);
begin
  Kernel.Pop.Free;
  Kernel.Pop.Free;
end;

// ��������� n-� ������� �����
procedure ifopPick(Kernel: TIfopKernel);
var
  v1 : TIfopVariant;
begin
  v1 := Kernel.Pop;
  try
    Kernel.Push(Kernel.Stack[v1.IntValue].GetClone);
  finally
    v1.Free;
  end;
end;

procedure ifop2ViewStack(Kernel: TIfopKernel);
var
  i: Integer;
begin
  for i := 0 to Kernel.StackSize - 1 do
    Kernel.stdout(IntToStr(i) + ':'#9 + Kernel.Stack[i].StrValue);
end;

procedure RegisterDictionary(AKernel: TObject);
var
  Kernel: TIfopKernel;
  i: Integer;
begin
  Kernel := TIfopKernel(AKernel);
  // ����������� �������
  Kernel.AddKeyword('swap', @ifopSwap);
  Kernel.AddKeyword('dup', @ifopDup);
  Kernel.AddKeyword('over', @ifopOver);
  Kernel.AddKeyword('rot', @ifopRot);
  Kernel.AddKeyword('drop', @ifopDrop);
  Kernel.AddKeyword('2swap', @ifop2Swap);
  Kernel.AddKeyword('2over', @ifop2Over);
  Kernel.AddKeyword('2drop', @ifop2Drop);
  Kernel.AddKeyword('Pick', @ifopPick);
  Kernel.AddKeyword('.s', @ifop2ViewStack);
end;

end.
