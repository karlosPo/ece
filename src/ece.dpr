// ************************************************************
//
// Easy Code editor
// Copyright (c) 2010  zeDevel
//
// �����������: ���������� �������  ze0nni@gmail.com
//
// ************************************************************

Program Ece;
{$APPTYPE GUI}
{$IFDEF fpc}{$MODE delphi}{$ENDIF}
// {$R _source\ece.res}
// {$R _source\Dialogs.res}
{$R *.dres}

uses
  Windows,
  Messages,
  SysUtils,
  zeWndControls in 'zeWndControls.pas',
  AppWindow in 'AppWindow.pas',
  EditorWindow in 'EditorWindow.pas',
  eceCmdMenu in 'eceCmdMenu.pas',
  iece in 'iece.pas',
  Classes,
  ConExec in 'ConExec.pas',
  eceFindDialog in 'eceFindDialog.pas',
  eceSynParser in 'eceSynParser.pas',
  eceConsoleWindow in 'eceConsoleWindow.pas',
  IeceObj in 'IeceObj.pas';

var
  App: TEceAppWindow;
  m : HMENU;
  msg: tmsg;

  begin
{$IFNDEF FPC}
  //ReportMemoryLeaksOnShutdown := true;
{$ENDIF}
  try
    App := TEceAppWindow.Create(0);
    // todo: ������ ������
    SendMessage(App.Handle, WM_SETICON, ICON_SMALL, LoadIcon
        (HInstance, 'appicon'));

    //������ ������
    //App.LoadPlugin('modules\startpage.dll');  //��������� ��������
    App.RegisterDocument(TEceEditorLoader.Create); //���� ���������
    App.LoadPlugin('modules\hexview.dll');  //������ ��������� HEX

    App.NewDocument('');
    App.ActiveDocument := 0;

    App.Documents[0]._SetFocus;
    // TEceEditorWindow(App.Documents[0]).Caret.Style := csClassic;
    // TEceEditorWindow(App.Documents[0]).LoadPlugin
    // ('EditorModules\autospace.dll');
//    with TEceEditorWindow(App.Documents[0]) do
//    begin
//      // SetFont('Lucida console', 17);
//      SetFont('Consolas', 22);
//      LoadColorTheme('color\default.txt');
//      Caret.Style := csClassic;
//    end;

    if ParamCount <> 0 then
      App.Documents[0]._LoadFromFile(ParamStr(1));
    App.ActiveDocument := 0;


    { TODO -oOnni -c����� ������ : ������ ������ }
    // ShowFindDialog(app, TEceEditorWindow(App.Documents[0]));

    m := GetMenu(App.Handle);
    SetMenu(App.Handle, 0);
    SetMenu(App.Handle, m);

    while GetMessage(msg, 0, 0, 0) do
    begin
      if (msg.message = WM_KEYDOWN) and (msg.wParam = VK_RETURN) and
        (GetKeyState(VK_CONTROL) and 128 <> 0) then
      begin
        App.Console.SetFocus;
      end
      else
      begin
        TranslateMessage(msg);
        DispatchMessage(msg);
      end;
    end;
  except
    on E: Exception do
      MessageBox(App.Handle, Pchar(E.ClassName + ': ' + E.Message), nil,
        MB_ICONERROR);
  end;
end.
