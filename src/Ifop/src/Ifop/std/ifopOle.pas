unit ifopOle;

interface

procedure RegisterDictionary(AKernel: TObject);

implementation

uses
  ComObj,
  ActiveX,
  IfopVariant,
  IfopKernel;

//������� Ole ������ �� ������ ������ �� �����
procedure ifopNewOleObj(Kernel : TIfopKernel);
var
  v : TifopInterfaceVariant;
begin
  v := TifopInterfaceVariant.Create(Kernel.PopStr);
  Kernel.Push(v);
end;

procedure ifopCallOleMethod(Kernel : TIfopKernel);
var
  tinfo: ITypeInfo;
begin
  //DispInvoke();
end;

procedure RegisterDictionary(AKernel: TObject);
var
  Kernel: TIfopKernel;
  i: Integer;
begin
  Kernel := TIfopKernel(AKernel);
  // ����������� �������
  Kernel.AddKeyword('NewOleObj', @ifopNewOleObj);
  Kernel.AddKeyword('CallOleMethod', @ifopCallOleMethod);
end;

initialization
  CoInitialize(0)
finalization
  CoUninitialize;

end.
