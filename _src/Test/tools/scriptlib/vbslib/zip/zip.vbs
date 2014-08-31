'********************************************************************************
'  <<< [unzip2] >>> 
'********************************************************************************
Sub  unzip2( ZipPath, ExpandFolderPath )
	Dim  r
	Dim  ex

	echo  ">unzip2 """ + ZipPath + """, """ + ExpandFolderPath + """"

	If not g_fs.FileExists( ZipPath ) Then  Raise E_FileNotExist, "<ERROR msg=""ファイルが見つかりません"" path="""+ ZipPath +"""/>"

	Set ex = g_sh.Exec( """" + g_vbslib_ver_folder + "zip\unzip2.exe"" """ + ZipPath + """ """ + _
		ExpandFolderPath + """" )

	Do While ex.Status = 0 : WScript.Sleep 100 : Loop
	Do Until ex.StdOut.AtEndOfStream : WScript.Echo ex.StdOut.ReadLine : Loop
	Do Until ex.StdErr.AtEndOfStream : WScript.Echo ex.StdErr.ReadLine : Loop
	r = ex.ExitCode

	If r <> 0 Then  Raise  r, "unzip2.exe: ERROR"
End Sub

 
'********************************************************************************
'  <<< [unzip] >>> 
'********************************************************************************
Dim  F_IfNotExist  : F_IfNotExist = 1
Dim  F_IfExistsErr : F_IfExistsErr = 2
Dim  F_AfterDelete : F_AfterDelete = 4

Sub  unzip( FolderZipPath, NewFolderPath, Flags )
	Dim  f, s

	If not exist( FolderZipPath ) Then  Err.Raise  E_FileNotExist,, "ファイルが見つかりません。: " + FolderZipPath
	If Flags and F_IfNotExist Then If exist( NewFolderPath) Then  Exit Sub
	If Flags and F_IfExistsErr Then If exist( NewFolderPath ) Then _
		Err.Raise  E_Others,, "フォルダーが存在するため展開できません。: " + NewFolderPath
	If Flags and F_AfterDelete Then  del NewFolderPath

	echo  ">unzip """ + FolderZipPath + """, """ + NewFolderPath + """"
	s = g_fs.GetParentFolderName( NewFolderPath )
	If s = "" Then s = "."

	Dim ec : Set ec = new EchoOff
	unzip2  FolderZipPath, s
	ec = Empty

	If not exist( NewFolderPath ) Then  Err.Raise  E_FileNotExist,, "展開しても次のフォルダができませんでした。: " + NewFolderPath
End Sub


 
'********************************************************************************
'  <<< [zip2] >>> 
'********************************************************************************
Sub  zip2( ZipPath, SourceFolderPath, IsFolderName )
	echo  ">zip2  """+ ZipPath +""""
	If not g_is_debug Then  Set ec = new EchoOff

	zip_helper_exe = g_vbslib_ver_folder +"zip\zlib_helper.exe"
	AssertExist  zip_helper_exe

	g_AppKey.CheckWritable  ZipPath, Empty

	del  ZipPath

	option_ = ""
	If IsFolderName Then _
		option_ = option_ + " /f"

	r= RunProg( """"+ zip_helper_exe +""" /silent zip """+ ZipPath +""" """+ SourceFolderPath +""""+ _
		option_ , "" )
		Assert  r = 0
End Sub


 
