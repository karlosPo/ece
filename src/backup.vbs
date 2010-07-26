'������ ������������ ��� �������� backup �������
'����� � ���������.
'���� �������� � ������� ������ �� ���������
'�� �� ���, ������� ���������
'================================================
'	�������������� ��������� ����������
'	��� ���� �����
'
'�������� �������. ����������� � ����� ������
ProjectName = "Ece"

'����� ������������ �������
ProjectFolder = ".\"

'�����, ���� ������� �������� �����
BackUpFolder = ".\__backup\"

'����� ������� ������� �� �������� � �����
ExceptFiles = ".*\.(vbs|zip|rar|exe|dll|dcu|local|identcache|tvsconfig|~*~|qpf|qsf)"

'������������� ������ ����
IgnoreCase = true

'================================================


function GetFileName
'������� ������������ ����� ������ ����
'���������������_src_������������_����������.zip
'����� ���� ���� � vb � �������������� �����, � �� ����
'���� ������ ��� ���������
	y = Year(now)
	m = month(now)
	if m < 10 then m = "0" & m
	d = Day(now)
	if d < 10 then d = "0" & d
	hrs = Hour(now)
	if hrs < 10 then hrs = "0" & hrs
	mts = Minute(now)
	if mts < 10 then mts = "0" & mts	
	GetFileName = ProjectName & "_src_" & y & m & d & "_" & hrs & mts
end function

set RegExpObj = CreateObject("VBScript.RegExp")
RegExpObj.IgnoreCase = IgnoreCase
RegExpObj.Pattern = ExceptFiles

function CheckFileName(FileName)
'���������� ��� ����� ����� ������� � 
	CheckFileName = not RegExpObj.Test(FileName)
end function

'������� ������ ��� ������ � cab-��������
set CabObj = CreateObject("MakeCab.MakeCab")
'�������� �������
set Fs = CreateObject("Scripting.FileSystemObject")

filescount = 0

'������� cab-���� � ��������� �����
CabObj.CreateCab BackUpFolder & GetFileName & ".zip", False, False, False
'�������� ����������� ������� ���������� ����� � ������ � �����
InserDir Fs.GetFolder(ProjectFolder), ""

	sub InserDir(Folder, FolderName)
		'������������� ��� ����� � �����
		for each ObjFile in Folder.Files
			if CheckFileName(ObjFile.Name) then
				'���� ���� ��������, ��������� � �����
				CabObj.AddFile ObjFile.Path, FolderName & ObjFile.Name
				filescount = filescount + 1
			end if
		next
		'��������� ��� �����
		for each ObjFolder in Folder.SubFolders
			'����������� ����� ��� ���� ��������� �����
			InserDir ObjFolder, FolderName & ObjFolder.Name & "\"
		next
	end sub	
'��������� � ��������� 
CabObj.CloseCab

if msgbox("�������� ������������� ���������!" & chr(13) & _
	"������ � ������:" & chr(9) & filescount & chr(13) & _
	"�������� ���� � ����������?", _
	vbYesNo or vbDefaultButton2, _
	"123") = vbYes then

end if

'��� ���� �� ��������� ���������� ��� �������
'�� ��� ���� ������ ���������. ��� ����� ���
'������ �������� � ������� ����������� ����