Option Explicit 

'***********************************************************************
'* VBScript ShortHand Library (vbslib)
'* vbslib is provided under 3-clause BSD license.
'* Copyright (C) Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.
'*
'* - $Version: vbslib 5.93 $
'* - $ModuleRevision: {vbslib}\Public\593 $
'* - $Date: 2017-03-20T20:00:00+09:00 $
'***********************************************************************

Dim  g_SrcPath
Dim  g_ACLLib_Path
     g_ACLLib_Path = g_SrcPath


 
'********************************************************************************
'  <<< [Cacls] >>> 
'********************************************************************************
Sub  Cacls( Path, Param )
	Dim ex

	echo  ">cacls """ & GetStepPath( Path, GetFullPath(".",Empty) ) & """ " & Param
	Set ex = g_sh.Exec( "cacls """ & Path & """ " & Param )
	ex.StdIn.Write  "Y"+vbCRLF
	WaitForFinishAndRedirect  ex, Empty
End Sub



 
'********************************************************************************
'  <<< [CaclsToInherit] >>> 
'********************************************************************************
Sub  CaclsToInherit( Path )
	Dim ex

	If not exist( g_vbslib_ver_folder + "XCACLS.vbs" ) Then
		Raise 1, g_vbslib_ver_folder + "XCACLS.vbs が見つかりません。マイクロソフトからダウンロードしてください。"
	End If

	echo  ">CaclsToInherit """ & GetStepPath( Path, GetFullPath(".",Empty) ) & """"
	g_sh.Run  "cscript  """ + g_vbslib_ver_folder + "XCACLS.vbs"" """+ path +""" /I ENABLE /T /S",, True
End Sub



 
'-------------------------------------------------------------------------
' ### <<<< [FolderLock] Class >>>> 
'-------------------------------------------------------------------------
Class  FolderLock

	Public  m_ReadOnlyBasePath      ' as string
	Public  m_FullAccessStepPathes  ' as ArrayClass of string
	Public  m_OutPath               ' as string
	Public  m_CaclsParamsReadOnly_SubFo   ' as string
	Public  m_CaclsParamsFullAccess       ' as string
	Public  m_CaclsParamsFullAccess_SubFo ' as string

 
'********************************************************************************
'  <<< [FolderLock::Class_Initialize] >>> 
'********************************************************************************
Private Sub  Class_Initialize()
	Set m_FullAccessStepPathes = new ArrayClass
	m_OutPath = g_sh.SpecialFolders( "Desktop" ) + "\Out_FolderLock"
	m_CaclsParamsReadOnly_SubFo   = "/T /P Everyone:R"
	m_CaclsParamsFullAccess       = "/P Everyone:F"
	m_CaclsParamsFullAccess_SubFo = "/T /P Everyone:F"
End Sub
 
'********************************************************************************
'  <<< [FolderLock::Start] >>> 
'********************************************************************************
Public Sub  Start()

	If not exist( m_ReadOnlyBasePath ) Then _
		Raise 1, "not found m_ReadOnlyBasePath = """ + m_ReadOnlyBasePath + """"

	m_ReadOnlyBasePath = GetFullPath( m_ReadOnlyBasePath, Empty )

	If ArgumentExist( "Lock" ) Then
		Me.Lock
		If Err.Number = 0 Then  WScript.Quit 0
	ElseIf ArgumentExist( "Unlock" ) Then
		Me.Unlock
		If Err.Number = 0 Then  WScript.Quit 0
	ElseIf ArgumentExist( "Pickup" ) Then
		Me.Pickup
		If Err.Number = 0 Then  WScript.Quit 0
	Else
		Dim  op

		Do
			echo "--------------------------------------------------------"
			echo "1. Lock"
			echo "2. Unlock"
			echo "3. Pickup"
			echo "9. Quit"
			op = CInt2( input( "Select number>" ) )
			echo "--------------------------------------------------------"

			Select Case op
				Case 1:  Me.Lock
				Case 2:  Me.Unlock
				Case 3:  Me.Pickup
				Case 9:  Exit Do
			End Select
		Loop
	End If
End Sub



 
'********************************************************************************
'  <<< [FolderLock::Lock] >>> 
'********************************************************************************
Public Sub  Lock()
	Dim  step_path
	Dim  folder_paths : Set folder_paths = CreateObject( "Scripting.Dictionary" )
	Dim  folder_path

	'//=== フォルダ全体を読み込み専用にする。
	Cacls  m_ReadOnlyBasePath, m_CaclsParamsReadOnly_SubFo

	'//=== 個々のファイルをフルアクセスにする。
	For Each  step_path  In m_FullAccessStepPathes.Items
		Cacls  GetFullPath( step_path, m_ReadOnlyBasePath ), m_CaclsParamsFullAccess
		folder_paths.Item( g_fs.GetParentFolderName( GetFullPath( step_path, m_ReadOnlyBasePath ) ) ) = 1
	Next

	'//=== フォルダもフルアクセスにする。Visual Studio がファイルを保存できなくなるため。
	For Each folder_path  In folder_paths.Keys()
		Cacls  folder_path, m_CaclsParamsFullAccess
	Next
End Sub


 
'********************************************************************************
'  <<< [FolderLock::Unlock] >>> 
'********************************************************************************
Public Sub  Unlock()
	Cacls  m_ReadOnlyBasePath, m_CaclsParamsFullAccess_SubFo
	'// CaclsToInherit  m_ReadOnlyBasePath  '// 遅すぎる
End Sub

 
'********************************************************************************
'  <<< [FolderLock::Pickup] >>> 
'********************************************************************************
Public Sub  Pickup()
	Dim  step_path, abs_path

	If exist( m_OutPath ) Then
		echo  "上書きします : " + m_OutPath
		pause
		del  m_OutPath + "\*"
	End If

	For Each  step_path  In m_FullAccessStepPathes.Items
		abs_path = GetFullPath( step_path, m_ReadOnlyBasePath )
		If g_fs.FolderExists( abs_path ) Then
			copy  abs_path + "\*", GetFullPath( step_path, m_OutPath )
		ElseIf g_fs.FileExists( abs_path ) Then
			copy  abs_path, GetFullPath( step_path, m_OutPath )
		End If
	Next

	OpenFolder  m_OutPath
End Sub

 
End Class 


 
