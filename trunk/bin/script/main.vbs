'==============================================================================
'����������� ����-�����
'==============================================================================

'����� ��������� � �������
sub print (str)
	Application.stdout str
end sub

'����� ��������� �� ������ � �������
sub debug (str)
	Application.stderr str
end sub

'��������� ������� ������ � �������� ��������� �� ����� �������
'� ������� ������
sub Write (str)
	set doc = Application.ActiveDocument
	set Caret = doc.Caret
	doc.Lines(Caret.y).Insert str, Caret.x + 1
	caret.x = caret.x + len(str)
end sub

'==============================================================================
'��������� �� ������
'==============================================================================

public CourientDir
CourientDir = "."

sub ls
	set Fs = CreateObject("Scripting.FileSystemObject")
	set FOlder =  Fs.GetFolder(CourientDir)
	for each ObjFolder in Folder.SubFolders
		Print "[" & ObjFolder.Name & "]"
	next
	for each ObjFile in Folder.Files
		Print ObjFile.Name
	next
	set Folder=nothing
	set Fs = nothing
end sub

sub cd(newDir)
	CourientDir = NewDir	
end sub

function dir
	dir = CourientDir
end function

'==============================================================================
'������� ������ � ����������
'==============================================================================
'������� ������� ���������� � ���������
sub DocInfo
	set Doc = Application.ActiveDocument
	print "��������: " & Doc.FileName
	print "�����: " & Doc.LinesCount
    '������� �������� � ���� (��������)
    dim CharsCount
    dim WordsCount
    CharsCount = 0
    WordsCount = 0
    for i = 0 to Doc.LinesCount - 1
        CharsCount = CharsCount + Doc.Lines(i).Length
    next

	print "����: " & WordsCount
	print "��������: " & CharsCount
	set Doc = nothing
end sub

'������� ������� � ����� ������
sub ClearR
    set Doc = Application.ActiveDocument
    for i = 0 to Doc.LinesCount - 1
        Doc.Lines(i).Text = RTrim(Doc.Lines(i))
    next
    Doc.Invalidate
    set Doc = nothing
end sub
'==============================================================================
'����� � ��������
'==============================================================================
Class ProjectClass
	public function GetName
		GetName = "Noname"
	end function
	
	public Sub InsertDocument
		Print """" & Application.ActiveDocument.FileName & """ �������� � �������."
	end sub
end class

dim Project 
set Project = new ProjectClass
