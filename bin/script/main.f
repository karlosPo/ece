 ( -------������� ����------ )   
 ( MenuName/Location ExecuteAction EnableTest VisibleTest ImagaFile )
"Images\Std\" var TBSkin

:MenuSaparator ( MenuName -- ) "" 1 1 "" ( MenuFile ) 4 pick  "-" +
AddEceMenuItem drop;

"File/" var MenuFile
TBSkin "filenew.bmp" + 1 1 "" MenuFile "New" + AddEceMenuItem
TBSkin "fileopen.bmp" + 1 1 "FileOpenDlg" MenuFile "Open..." +  AddEceMenuItem
MenuFile MenuSaparator
:emFileSave 
	GetDocFileName "" = if 
		"��� ����� ����� ��� ����������" msgbox
		else
        "<��� ������ ���� ����������>" msgbox
		then
;
TBSkin "filesave.bmp" + 1 1 "emFileSave" MenuFile "Save" + AddEceMenuItem
TBSkin "filesaveas.bmp" + 1 1 "emFileSaveAs" MenuFile "Save as..." + AddEceMenuItem
TBSkin "fileclose.bmp" + 1 1 "emFileClose" MenuFile "Close" + AddEceMenuItem
MenuFile MenuSaparator
TBSkin "fileexit.bmp" + 1 1 "AppClose" MenuFile "Exit" + AddEceMenuItem
drop ( MenuFile )

"Edit/" var MenuEdit
TBSkin "editundo.bmp" + 1 1 "" MenuEdit "Undo" +  AddEceMenuItem
TBSkin "editredo.bmp" + 1 1 "" MenuEdit "Redo" + AddEceMenuItem
MenuEdit MenuSaparator
TBSkin "editcut.bmp" + 1 1 "" MenuEdit "Cut" + AddEceMenuItem
TBSkin "editcopy.bmp" + 1 1 "" MenuEdit "Copy" + AddEceMenuItem
TBSkin "editpaste.bmp" + 1 1 "" MenuEdit "Paste" + AddEceMenuItem
TBSkin "editdelete.bmp" + 1 1 "" MenuEdit "Delete" + AddEceMenuItem
MenuEdit MenuSaparator
TBSkin "editselectall.bmp" + 1 1 "" MenuEdit "Select all" + AddEceMenuItem
drop ( MenuEdit )

"View/" var MenuView
    MenuView "Codepage/" + var MenuCodepage
    TBSkin "viewcodepageutf8.bmp" + 1 1 "" MenuCodepage "UTF-8" + AddEceMenuItem
    TBSkin "viewcodepagecp1251.bmp" + 1 1 "" MenuCodepage "CP1251" + AddEceMenuItem
    TBSkin "viewcodepagekoi8-r.bmp" + 1 1 "" MenuCodepage "KOI8-R" + AddEceMenuItem
    TBSkin "viewcodepagecp866.bmp" + 1 1 "" MenuCodepage "CP866" + AddEceMenuItem
    drop ( MenuCodepage )
drop ( MenuView )

"Tools/" var MenuTools
TBSkin "execute.bmp" + 1 1 "" MenuTools "Make\tF9" + AddEceMenuItem
TBSkin "" + 1 1 "" MenuTools "Make config..." + AddEceMenuItem
(
"script\japman.f" import
TBSkin "" + 1 1 "1 Japs" MenuTools "Japs/Less 1 ������� A � � � �" + AddEceMenuItem
TBSkin "" + 1 1 "2 Japs" MenuTools "Japs/Less 2 �*" + AddEceMenuItem
TBSkin "" + 1 1 "3 Japs" MenuTools "Japs/Less 3 �*" + AddEceMenuItem
TBSkin "" + 1 1 "4 Japs" MenuTools "Japs/Less 4 �*" + AddEceMenuItem
TBSkin "" + 1 1 "5 Japs" MenuTools "Japs/Less 5 �*" + AddEceMenuItem
TBSkin "" + 1 1 "6 Japs" MenuTools "Japs/Less 6 �*" + AddEceMenuItem
TBSkin "" + 1 1 "7 Japs" MenuTools "Japs/Less 7 �*" + AddEceMenuItem

TBSkin "" + 1 1 "8 Japs" MenuTools "Japs/Less 8 �*" + AddEceMenuItem
TBSkin "" + 1 1 "9 Japs" MenuTools "Japs/Less 9 �*" + AddEceMenuItem
)
drop ( MenuTools )

"Help/" var MenuHelp
:helpabout "OkInformation" "About" "Easy Code Editor v1.0" MsgBoxEx  drop;
TBSkin "helpabout.bmp" + 1 1 "helpabout" MenuHelp "About" + AddEceMenuItem
drop ( MenuHelp )

( forget MenuSaparator )
drop ( TSSkin )
  ( /------������� ����-----/ )  

 ( ������� "�������" ������� )
:clr ( -- )
	GetEditorLinesCount 1 -  var i i 0 do
		i GetEditorLine

		i SetEditorLine
	loop
	drop		
;


:cls ( ������� ������ )
( -- )
	"" GetEditorCaretLine SetEditorLine
;

( ������� �������� )
:da ( -- )
	GetEditorLinesCount 1 - 0 do
		0 DeleteEditorLine
	loop
	InvaLidateEditor
	drop
;

:du ( ������� n ����� �����, ������� � ������� )
    ( n -- )

;

:dd ( ������� n ����� ����, ������� � ������� )
    dup 0 <> if
	GetEditorCaretLine + 1 -  var i
    i GetEditorCaretLine do
        i DeleteEditorLine
    loop
    drop
else
    drop
    then
;

:gg ( LineNumber -- ) 1 - SetEditorCaretY;

:ETime Now Time EditorInsert;
:EDate Now Date EditorInsert;
:EDTime Now DateTime EditorInsert;

