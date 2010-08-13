unit ifopSystem;

interface

procedure RegisterDictionary(AKernel: TObject);

implementation

uses
  IfopKernel;

//���������� ���������� ������� ������ � ������� ���������� �� ��������.
procedure ifopQuit(Kernel: TIfopKernel);
begin
  Kernel.isScriptEnd  := true;
end;

procedure RegisterDictionary(AKernel: TObject);
var
  Kernel: TIfopKernel;
  i: Integer;
begin
  Kernel := TIfopKernel(AKernel);
  // ����������� �������
  Kernel.AddKeyword('quit', @ifopQuit);
end;

end.
