unit eceConsoleWindow;

interface

{$I def.inc}

uses
  Windows,
  SysUtils,
  Classes,
  Messages,
  EditorWindow,
  IEce,
{$IFDEF forth}
  VForth,
  VForthMachine,
  VForthVariants,
  VForthVariantInteger,
  VForthVariantFloat,
  VForthVariantNatural,
  VForthVariantComplex,
  VForthVariantString,
  VForthModuleSystem,
  VForthAthom,
  VForthModuleIo,
  VForthModuleMath,
  VForthModuleLogic,
  VForthModule,
  VForthModuleDateTime,
  VForthVariantArray,
  VForthModuleWin32;
{$ELSE}
MsAsKernel;
{$ENDIF}

type
  TEceConsoleCaret = class;

  TEceConsoleWindow = class(TEceEditorWindow {$ifdef forth},IVForthIO{$endif})
  private
{$IFDEF forth}
    FVForthMachine: IVForthMachine;
{$ELSE}
    FIfopKernel: TKernel;
{$ENDIF}
    FScriptSource: string;
    FHistory: TStringList;
    FHistoryIndex: Integer;
  protected
    {$ifdef forth}
    function StdIn: string; stdcall;
    procedure StdOut(str: string); stdcall;
    procedure StdErr(str: string); stdcall;
    {$endif}
    function CreateCaret: TCaret; override;
    function CreateLine: TLine; override;
    procedure wmChar(var msg: TWmChar);
    message WM_CHAR;
    procedure wmKeyDown(var msg: TWMKeyDown);
    message WM_KEYDOWN;
  protected
    procedure LoadStdScript;
  public
    Constructor Create(Parent: Cardinal; AApplication: IEceApplication);
    Destructor Destroy; override;
{$IFDEF forth}
    property Machine: IVForthMachine read FVForthMachine;
{$ELSE}
    property Kernal: TKernel read FIfopKernel;
{$ENDIF}
  end;

  TEceConsoleCaret = class(TCaret)
  private
    procedure SetXY(const Ax, Ay: Integer); override;
    Procedure SetX(Const value: Integer); override;
    Procedure SetY(Const value: Integer); override;
  end;

  TLineType = (ltIn, ltOut, ltErr);

  TConsoleLine = class(TLine)
  private
    FLineType: TLineType;
    procedure SetLineType(const value: TLineType);

  protected
    procedure UpdateSyn; override;
  public
    property LineType: TLineType read FLineType write SetLineType;
  end;

  // procedure StdInProc(con: TEceConsoleWindow; AText: string; AReturn: Boolean);
procedure StdOutProc(con: TEceConsoleWindow; AText: string; AReturn: Boolean);
procedure StdErrProc(con: TEceConsoleWindow; AText: string; AReturn: Boolean);

implementation

{ TEceConsoleWindow }

procedure StdOutProc(con: TEceConsoleWindow; AText: string; AReturn: Boolean);
var
  l: TConsoleLine;
  lns: TStringList;
  i: Integer;
begin
  lns := TStringList.Create;
  lns.Text := AText;

  for i := 0 to lns.Count - 1 do
  begin
    AText := lns[i];
    AText := StringReplace(AText, #9, #32#32#32#32, [rfReplaceAll]);
    l := TConsoleLine(con.Lines[con.Count - 1]);
    if l.LineType = ltErr then
    begin
      if (not AReturn) and (l.Length + Length(AText) <= l.Editor.CharsInWidth)
        then
      begin
        l.Text := l.Text + AText;
        exit;
      end;
    end;

    with TConsoleLine(con.AddLine) do
    begin
      LineType := ltOut;
      Text := AText;
      Invalidate;
    end;
  end;
  lns.Free;
end;

procedure StdErrProc(con: TEceConsoleWindow; AText: string; AReturn: Boolean);
var
  l: TConsoleLine;
  lns: TStringList;
  i: Integer;
begin
  lns := TStringList.Create;
  lns.Text := AText;

  for i := 0 to lns.Count - 1 do
  begin
    AText := lns[i];
    AText := StringReplace(AText, #9, #32#32#32#32, [rfReplaceAll]);
    l := TConsoleLine(con.Lines[con.Count - 1]);
    if l.LineType = ltErr then
    begin
      if (not AReturn) and (l.Length + Length(AText) <= l.Editor.CharsInWidth)
        then
      begin
        l.Text := l.Text + AText;
        exit;
      end;
    end;

    with TConsoleLine(con.AddLine) do
    begin
      LineType := ltErr;
      Text := AText;
      Invalidate;
    end;
  end;
  lns.Free;
end;

constructor TEceConsoleWindow.Create(Parent: Cardinal;
  AApplication: IEceApplication);
begin
  inherited;
{$IFDEF forth}
  FVForthMachine := CreateVForthMachine;
  FVForthMachine.SetIo(Self);
  FVForthMachine.LoadModule(TVForthModuleSystem.Create);
  FVForthMachine.LoadModule(TVForthModuleIo.Create);
  FVForthMachine.LoadModule(TVForthModuleMath.Create);
  FVForthMachine.LoadModule(TVForthModuleLogic.Create);
  FVForthMachine.LoadModule(TVForthModuleDateTIme.Create);
  FVForthMachine.LoadModule(TVForthModuleWin32.Create);
{$ELSE}
  FIfopKernel := TKernel.Create;
{$ENDIF}
  FHistory := TStringList.Create;
  LoadStdScript;
  // FIfopKernel.SetStdOut(Self, @StdOutProc);
  // FIfopKernel.SetStdErr(Self, @StdErrProc);
end;

function TEceConsoleWindow.CreateCaret: TCaret;
begin
  Result := TEceConsoleCaret.Create(Self);
end;

function TEceConsoleWindow.CreateLine: TLine;
begin
  Result := TConsoleLine.Create(Self);
end;

destructor TEceConsoleWindow.Destroy;
begin
{$IFDEF forth}
  FVForthMachine := nil;
{$ELSE}
  FIfopKernel.Free;
{$ENDIF}
  FHistory.Free;
  inherited;
end;

procedure TEceConsoleWindow.LoadStdScript;
var
  l: TStringList;
begin
  try
    l := TStringList.Create;
    try
{$IFDEF forth}
      FScriptSource := ExtractFilePath(ParamStr(0)) + 'script\main.f';
{$ELSE}
      FScriptSource := ExtractFilePath(ParamStr(0)) + 'script\main.vbs';
{$ENDIF}
      l.LoadFromFile(FScriptSource);
{$IFDEF forth}
      FVForthMachine.AddCode(l.Text);
{$ELSE}
      FIfopKernel.AddCode(l.Text);
{$ENDIF}
    finally
      l.Free;
    end;
  except
    on e: EXception do
      MessageBox(0, Pchar(FScriptSource + #13#10#13#10 + e.Message), nil,
        MB_ICONERROR);
  end;
end;
{$ifdef forth}
procedure TEceConsoleWindow.StdErr(str: string);
begin
  StdErrProc(Self, str, false);
end;

function TEceConsoleWindow.StdIn: string;
begin

end;

procedure TEceConsoleWindow.StdOut(str: string);
begin
  StdOutProc(Self, str, false);
end;
{$endif}
procedure TEceConsoleWindow.wmChar(var msg: TWmChar);
var
  str: String;
  index: Integer;
begin
  FHistoryIndex := -1;
  case msg.CharCode of
    VK_RETURN:
      begin
        try
          try
            BeginUpdate;
            str := Strings[Count - 1];
{$IFDEF forth}
            FVForthMachine.AddCode(str);
{$ELSE}
            FIfopKernel.AddCode(str);
{$ENDIF}
{$REGION '�������'}
            index := FHistory.IndexOf(str);
            if index <> -1 then
              FHistory.Delete(index);
            FHistory.Insert(0, str);
{$ENDREGION}
          finally
            EndUpdate;
          end;
        except
          on e: EXception do
            // FIfopKernel.stderr(e.ClassName + ': ' + e.Message);
            StdErrProc(Self, e.Message, true);
        end;
        AddLine;
        Caret.Y := 0;
        Caret.X := 0;
      end;
    VK_ESCAPE:
      begin
        if (Strings[Count - 1] <> '') or (Caret.X <> 0) then
        begin
          // ������� ������
          Strings[Count - 1] := '';
          Lines[Count - 1].Invalidate;
          Caret.X := 0;
        end
        else
        begin
          // ������������ � ����� �����
          Application._FocusToActiveDocument;
        end;
      end;
    VK_BACK:
      if Caret.X > 0 then
        inherited;
  else
    begin
      inherited;
    end;
  end;
end;

procedure TEceConsoleWindow.wmKeyDown(var msg: TWMKeyDown);
begin
  case msg.CharCode of
    VK_UP:
      begin
        Inc(FHistoryIndex);
        if FHistoryIndex >= FHistory.Count then
          FHistoryIndex := -1;
        with Lines[Count - 1] do
        begin
          if FHistoryIndex <> -1 then
            Text := FHistory[FHistoryIndex]
          else
            Text := '';
          Invalidate;
          Caret.X := Length;
        end;
      end;
    VK_DOWN:
      begin
        Dec(FHistoryIndex);
        if FHistoryIndex < -1 then
          FHistoryIndex := FHistory.Count - 1;
        with Lines[Count - 1] do
        begin
          if FHistoryIndex <> -1 then
            Text := FHistory[FHistoryIndex]
          else
            Text := '';
          Invalidate;
          Caret.X := Length;
        end;
      end;
  else
    begin
      FHistoryIndex := -1;
      inherited;
    end;
  end;
end;

{ TEceConsoleCaret }

procedure TEceConsoleCaret.SetX(const value: Integer);
begin
  inherited;

end;

procedure TEceConsoleCaret.SetXY(const Ax, Ay: Integer);
begin
  inherited SetXY(Ax, Editor.Count - 1);
end;

procedure TEceConsoleCaret.SetY(const value: Integer);
begin
  // ������ �������� ��������� �������
  inherited SetY(Editor.Count - 1);
end;

{ TConsoleLine }

procedure TConsoleLine.SetLineType(const value: TLineType);
begin
  FLineType := value;
end;

procedure TConsoleLine.UpdateSyn;
var
  i: Integer;
  index: Integer;
  tk: TToken;
begin
  for i := 0 to FTokens.Count - 1 do
    TToken(FTokens[i]).Free;
  FTokens.Clear;

  case LineType of
    ltIn:
      tk := TToken.Create(Editor.Tokens['stdin']);
    ltOut:
      tk := TToken.Create(Editor.Tokens['stdout']);
    ltErr:
      tk := TToken.Create(Editor.Tokens['stderr']);
  end;
  begin
    FTokens.Add(tk);
    tk.FirstChar := 0;
    tk.Length := Length;
  end;
end;

end.
