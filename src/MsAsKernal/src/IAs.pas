unit IAs;

interface

uses
  Windows,
  Classes,
  SysUtils,
  ActiveX,
  ComObj;

type
  IActiveScriptSite = interface(IUnknown)
  function GetLCID( // ������ ����� ��������
    out plcid: LCID
  ): HResult; stdcall;
  function GetItemInfo(  // ������ ����������� �������
    pstrName: LPCOLESTR;      // ��� �������
    dwReturnMask: DWORD;      // ������������� ����������
    out ppiunkItem: IUnknown; // ��������� �������
    out ppti: ITypeInfo       // ��������� � ���� �������
  ): HResult; stdcall;
  function GetDocVersionString(  // ������ ������ ��������
    out pbstrVersion: WideString
  ): HResult; stdcall;
  function OnScriptTerminate(  // ����������� � ����������
    var pvarResult: OleVariant;  // ������������ ��������
    var pexcepinfo: EXCEPINFO    // ���������� �� ������
  ): HResult; stdcall;
  function OnStateChange(  // ����������� �� ��������� ���������
    ssScriptState: SCRIPTSTATE // ����� ���������
  ): HResult; stdcall;
  function OnScriptError(  // ����������� �� ������
    const pscripterror: IActiveScriptError
  ): HResult; stdcall;
    // ������ ����������
  function OnEnterScript: HResult; stdcall;
    // ��������� ����������
  function OnLeaveScript: HResult; stdcall;
end;





implementation

end.
