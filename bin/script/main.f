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
	AddEditorLine
	InvaLidateEditor
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

:ETime Now Time EditorInsert;
:EDate Now Date EditorInsert;
:EDTime Now DateTime EditorInsert;
