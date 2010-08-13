unit ifopRegExp;

interface

procedure RegisterDictionary(AKernel: TObject);

implementation

uses
  ActiveX,
  ComObj,
  IfopKernel;

var
  RegExt : OleVariant;

//������������� ������� ��� ��������
procedure ifopRePattern(Kernel : TIfopKernel);
begin
  RegExt.Pattern := Kernel.PopStr;
end;

//������� test ��� ��������
procedure ifopReTest(Kernel : TIfopKernel);
begin
  if RegExt.Test(Kernel.PopStr) then
  Kernel.PushInt(1)
  else
  Kernel.PushInt(0)
end;

procedure RegisterDictionary(AKernel: TObject);
var
  Kernel: TIfopKernel;
  i: Integer;
begin
  Kernel := TIfopKernel(AKernel);
  // ����������� �������
  Kernel.AddKeyword('rePattern', @ifopRePattern);
  Kernel.AddKeyword('reTest', @ifopReTest);
end;

initialization
  CoInitialize(0);
  RegExt := CreateOleObject('VBScript.RegExp')
finalization
  CoUninitialize;
end.
