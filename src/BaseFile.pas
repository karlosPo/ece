unit BaseFile;

interface

//!!! � ������� ����������� ������� ���������� ������������ �����

uses
  Windows,
  Classes,
  SysUtils;

type
  TBaseFile = class
  private
    FBaseFile: TStringList;
    FBaseFileName: string;
  public
    constructor Create;
    destructor Destroy; override;

    property FileName: string read FBaseFileName;
    procedure LoadFromFile(AFileName : string);

    function IntValue(AKey: string): Integer; overload;
    function IntValue(AKey: string; DefValue: Integer): Integer; overload;
    function FloatValue(AKey: string): Double; overload;
    function FloatValue(AKey: string; DefValue: Double): Double; overload;
    function StrValue(AKey: String): string; overload;
    function StrValue(AKey: string; DefValue: string): string; overload;
  end;

implementation
{$ifdef fpc}
const
{$else}
resourcestring
{$endif}
  Str������������S���������������������� = '������ � ����� "%s". ����� �������� "%s" �� �������.';
  Str������������S��������������������� = '������ � ����� "%s" ������ "%d". ' +
    '�������� "%s" �� �������� ����� ������.';
  Str������������S����������������������������� =
    '������ � ����� "%s". ������������ �������� "%s" �� �������.';
  Str������������S���������������������������� =
    '������ � ����� "%s" ������ "%d". ' +
    '�������� "%s" �� �������� ������������ ������.';
  Str������������S�������������������������� =
    '������ � ����� "%s". ��������� �������� "%s" �� �������.';
  Str����������S�������� = '���� "%s" �� ������.';
  { TErr }

{ TBaseFile }

constructor TBaseFile.Create;
begin
  inherited Create;
  FBaseFile := TStringList.Create;
end;

destructor TBaseFile.Destroy;
begin
  FBaseFile.Free;
  inherited;
end;

function TBaseFile.FloatValue(AKey: string): Double;
var
  index: Integer;
  n: Double;
begin
  index := FBaseFile.IndexOfName(AKey);
  if index = -1 then
    // �������� �� �������
    raise Exception.Create(Format(Str������������S�����������������������������,
        [FileName, AKey]));
  if TryStrToFloat(StringReplace(FBaseFile.ValueFromIndex[index], '.', DecimalSeparator, []), n) then
  begin
    // ��� ��
    Exit(n)
  end
  else
  begin
    // �������� �� �������� ������
    raise Exception.Create(Format(Str������������S����������������������������,
        [FileName, Index + 1, FBaseFile.ValueFromIndex[index]]));
  end;
end;

function TBaseFile.FloatValue(AKey: string; DefValue: Double): Double;
var
  index: Integer;
  n: Double;
begin
  index := FBaseFile.IndexOfName(AKey);
  if index = -1 then
    // �������� �� ���������
    Exit(DefValue);
  if TryStrToFloat(StringReplace(FBaseFile.ValueFromIndex[index], '.', DecimalSeparator, []), n) then
  begin
    // ��� ��
    Exit(n)
  end
  else
  begin
    // �������� �� �������� ������
    raise Exception.Create(Format(Str������������S���������������������,
        [FileName, Index + 1, FBaseFile.ValueFromIndex[index]]));
  end;
end;

function TBaseFile.IntValue(AKey: string): Integer;
var
  index: Integer;
  n: Integer;
begin
  index := FBaseFile.IndexOfName(AKey);
  if index = -1 then
    // �������� �� �������
    raise Exception.Create(Format(Str������������S����������������������,
        [FileName, AKey]));
  if TryStrToInt(FBaseFile.ValueFromIndex[index], n) then
  begin
    // ��� ��
    Exit(n)
  end
  else
  begin
    // �������� �� �������� ������
    raise Exception.Create(Format(Str������������S���������������������,
        [FileName, Index + 1, FBaseFile.ValueFromIndex[index]]));
  end;
end;

function TBaseFile.IntValue(AKey: string; DefValue: Integer): Integer;
var
  index: Integer;
  n: Integer;
begin
  index := FBaseFile.IndexOfName(AKey);
  if index = -1 then
    // �������� �� ���������
    Exit(DefValue);
  if TryStrToInt(FBaseFile.ValueFromIndex[index], n) then
  begin
    // ��� ��
    Exit(n)
  end
  else
  begin
    // �������� �� �������� ������
    raise Exception.Create(Format(Str������������S���������������������,
        [FileName, Index + 1, FBaseFile.ValueFromIndex[index]]));
  end;
end;

procedure TBaseFile.LoadFromFile(AFileName: string);
begin
  if not FileExists(AFileName) then
    raise Exception.Create(Format(Str����������S��������, [AFileName]));
  FBaseFile.LoadFromFile(AFileName);
  FBaseFileName := AFileName;
end;

function TBaseFile.StrValue(AKey: String): string;
var
  index: Integer;
begin
  index := FBaseFile.IndexOfName(AKey);
  if index = -1 then
    // �������� �� �������
    raise Exception.Create(Format(Str������������S��������������������������,
        [FileName, AKey]));
  Result := FBaseFile[index];
end;

function TBaseFile.StrValue(AKey, DefValue: string): string;
var
  index: Integer;
begin
  index := FBaseFile.IndexOfName(AKey);
  if index = -1 then
    Exit(DefValue);
  Result := FBaseFile[index];
end;

end.
