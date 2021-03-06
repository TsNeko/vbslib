'***********************************************************************
'* VBScript ShortHand Library (vbslib)
'* vbslib is provided under 3-clause BSD license.
'* Copyright (C) Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.
'*
'* - $Version: vbslib 5.93 $
'* - $ModuleRevision: {vbslib}\Public\593 $
'* - $Date: 2017-03-20T20:00:00+09:00 $
'***********************************************************************

If WScript.Arguments.Unnamed.Count <= 1 Then
	Err.Raise  1,, "CopyWithProcessDialog.vbs  source_file_path  destination_folder_path"
End If

Set g_sh = WScript.CreateObject( "WScript.Shell" )
Set g_fs = CreateObject( "Scripting.FileSystemObject" )

source_path      = WScript.Arguments.Unnamed(0)
destination_path = WScript.Arguments.Unnamed(1)


Const FOF_CREATEPROGRESSDLG = &h00
Const FOF_NOCONFIRMATION = &H10
Set sh_app = CreateObject( "Shell.Application" )
source_full_path = g_fs.GetAbsolutePathName( source_path )  '// For "CopyHere"
mkdir  destination_path
Set destination_folder = sh_app.NameSpace( destination_path )  '// TODO: \

destination_folder.CopyHere  source_full_path,  FOF_CREATEPROGRESSDLG + FOF_NOCONFIRMATION

WScript.Quit  21


'*************************************************************************
'* Function: GetParentFullPath
'*************************************************************************
Function  GetParentFullPath( in_Path )
    GetParentFullPath = g_fs.GetAbsolutePathName( in_Path + "\.." )
End Function


 
'***********************************************************************
'* Function: mkdir
'***********************************************************************
Function  mkdir( in_Path )
	If g_fs.FolderExists( in_Path ) Then _
		mkdir = 0 : Exit Function
	folder_names = Array()

	n = 0
	fo2 = g_fs.GetAbsolutePathName( in_Path )
	Do
		If g_fs.FolderExists( fo2 ) Then Exit Do

		n = n + 1
		Redim Preserve  folder_names(n)
		folder_names(n) = g_fs.GetFileName( fo2 )
		fo2 = g_fs.GetParentFolderName( fo2 )
	Loop

	mkdir = n

	For n=n To 1 Step -1
		If Right( fo2, 1 ) <> "\" Then _
			fo2 = fo2 +"\"
		fo2 = fo2 + folder_names(n)

		n_retry = 0
		g_fs.CreateFolder  fo2
		If en <> 0 Then
			If g_fs.FileExists( fo2 ) Then
				Err.Raise  58, "<ERROR msg=""It is not able to make folder at file exists"+ _
					""" path="""+ fo2 +"""/>"
			End If
			Err.Raise en,,ed
		End If
	Next
End Function


 
