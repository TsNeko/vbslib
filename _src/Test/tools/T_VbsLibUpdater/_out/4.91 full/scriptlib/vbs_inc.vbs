'// g_SrcPath="vbs_inc.vbs"


'***********************************************************************
'* VBScript ShortHand Library (vbslib)
'* vbslib is provided under 3-clause BSD license.
'* Copyright (C) Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.
'*
'* - $Version: vbslib 5.93 $
'* - $ModuleRevision: {vbslib}\Public\593 $
'* - $Date: 2017-03-20T20:00:00+09:00 $
'***********************************************************************


'// Set g_vbslib_path=(this script full path)  before including this script.

Dim  g_vbslib_path, g_vbslib_folder
Dim  g_sh :If IsEmpty(g_sh) Then Set g_sh=WScript.CreateObject("WScript.Shell")
Dim  g_fs :If IsEmpty(g_fs) Then Set g_fs=CreateObject( "Scripting.FileSystemObject" )


If IsEmpty(g_vbslib_path) Then _
	Err.Raise  1,,"vbs_inc needs other script using vbslib header"
g_vbslib_folder = g_fs.GetParentFolderName( g_vbslib_path ) + "\"


Dim  g_Vers

If IsEmpty( g_Vers ) Then  Set g_Vers = CreateObject("Scripting.Dictionary")
If IsEmpty( g_Vers("vbslib") ) Then  g_Vers("vbslib") = 2.0


Dim  g_f
g_f = g_Vers.Item("vbslib")
If g_f >= 4.9 Then
	g_Vers.Item("vbslib") = 4.9
	g_vbslib_path = g_vbslib_folder + "vbslib\vbs_inc_sub.vbs"
ElseIf g_f >= 4.0 Then
	g_vbslib_path = g_vbslib_folder + "vbslib400\vbs_inc_400.vbs"
ElseIf g_f >= 3.0 Then
	g_vbslib_path = g_vbslib_folder + "vbslib300\vbs_inc_300.vbs"
ElseIf g_f >= 2.0 Then
	g_vbslib_path = g_vbslib_folder + "vbs_inc_200.vbs"
Else
	g_vbslib_path = g_vbslib_folder + "vbslib000\vbs_inc_000.vbs"
End If
If not g_fs.FileExists( g_vbslib_path ) Then  Err.Raise  1,,"[ERROR] Not found " + g_vbslib_path


Set g_f = g_fs.OpenTextFile( g_vbslib_path,,,-2 )
vbs_inc_Code = g_f.ReadAll()
g_f = Empty
Execute  vbs_inc_Code
 
