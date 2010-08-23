'==============================================================================
'����������� ����-�����
'==============================================================================
sub print (str)
	Application.stdout str
end sub

sub debug (str)
	Application.stderr str
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
sub DocInfo
	set Doc = Application.Documents(0)
	print "��������: " & Doc.FileName
	print "�����: " & Doc.LinesCount
	print "����: "
	print "��������: "
	set Doc = nothing
end sub