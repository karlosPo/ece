unit VForthVariantComplex;
{$IFDEF fpc}{$MODE delphi}{$ENDIF}
interface

uses
  VForth,
  SysUtils,
  Classes,
  Contnrs,
  VForthVariants;

type
  //������������ ��� "x+iy" ��� �������
  //������ "4,2+6i"
  TComplexVariant = class(TCustomVForthVariant, IVForthVariant)

  end;

implementation

end.
