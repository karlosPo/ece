( ������� "�������" ������� )
:clearr ( -- )
	GetEditorLinesCount 1 - var i
	i 0 do
		i GetEditorLine
		( todo: �������� ��� ��� "��������" �������� ������ )
		i Swap SetEditorLine
	loop
	drop
	InvalidateEditor
;

( ������� �������� )
:cleara ( -- )
	GetEditorLinesCount 1 - 0 do
		0 DeleteEditorLine
	loop
	AddEditorLine
	InvaLidateEditor drop
;
