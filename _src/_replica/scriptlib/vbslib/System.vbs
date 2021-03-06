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
Dim  g_System_Path
     g_System_Path = g_SrcPath


 
'********************************************************************************
'  <<< [Prompt] >>> 
'********************************************************************************
Sub  Prompt()
	If MsgBox( "vbslib プロンプトに切り替えますか。"+ vbCRLF +_
		""+ vbCRLF +_
		"この操作に覚えがないときは、いいえを押してください。", _
		vbYesNo + vbDefaultButton2, _
		"セキュリティ警告 - vbslib プロンプト" ) = vbNo Then

		If g_CommandPrompt <> 0 Then
			echo  "終了しました。 このウィンドウは閉じることができます。"
			While True : Sleep  10000 : WEnd
		End If
		WScript.Quit  1
	End If

	command_line = ""
	Do
		If command_line = "" Then
			echo  " ((( vbslib プロンプト )))"
			echo  "? は、このプロンプトに結果を表示するコマンドです。"
			echo  "高機能な電卓として使うこともできます。 "
			echo  "VBScript の関数や定義した関数も使えます。"
			echo  "グローバル変数を定義することもできます。"
			echo  ""
			echo  "サンプル："
			echo  "-------------------------------------------------------------"
			echo  "> ?1+2"
			echo  "3"
			echo  "> ?2+3*4"
			echo  "14"
			echo  "> ?""0x""+Hex( 0x14+0x38 )"
			echo  "0x4C"
			echo  "> a=2"
			echo  "> ?a+3"
			echo  "5"
			echo  "> quit"
			echo  "-------------------------------------------------------------"
			echo  ""
			echo  "コマンドを入力してください。"
		End If

		command_line = Trim2( input( "> " ) )
		If LCase( command_line ) = "quit"  or  LCase( command_line ) = "exit" Then  Exit Do

		is_zerox = ( InStr( command_line, "0x" ) > 0 )
		If is_zerox Then _
			command_line = Replace( command_line, "0x", "&h" )

		If Left( command_line, 1 ) = "?" Then
			command_line = Mid( command_line, 2 )
			If command_line <> "" Then

				If TryStart(e) Then  On Error Resume Next
					Execute  "command_line = GetEchoStr( "+ command_line +" )"
				If TryEnd Then  On Error GoTo 0
				If e.num <> 0 Then
					echo  e.desc : e.Clear
				Else
					If is_zerox Then _
						command_line = Replace( command_line, "&h", "0x" )
					echo  command_line
					If command_line = "" Then  command_line = "Empty"
				End If
			End If
		Else

			If TryStart(e) Then  On Error Resume Next
				ExecuteGlobal  command_line
			If TryEnd Then  On Error GoTo 0
			If e.num <> 0 Then  echo  e.desc : e.Clear

		End If
	Loop
End Sub


 
'*************************************************************************
'  <<< [g_VBS_Lib_System] >>> 
'*************************************************************************
Dim  g_VBS_Lib_System : Set g_VBS_Lib_System = new STH_VbsLibSystemClass : ErrCheck

Class  STH_VbsLibSystemClass
	Public  NotExistFileMD5

	Private Sub  Class_Initialize()
		NotExistFileMD5 = "00000000000000000000000000000000"
	End Sub
End Class


 
'********************************************************************************
'  <<< [RegExport] >>> 
'********************************************************************************
Sub  RegExport( ByVal RegPath, OutFilePath, Opt )
	If Right( RegPath, 1 ) = "\" Then  RegPath = Left( RegPath, Len( RegPath ) - 1 )

	RegEnumKeys  RegPath, keys, Opt

	Set f = g_fs.CreateTextFile( OutFilePath, True, True )
	f.WriteLine  "Windows Registry Editor Version 5.00"

	RegExport_sub  RegPath, f
	For Each  key  In keys
		RegExport_sub  key, f
	Next
End Sub


Sub  RegExport_sub( RegPath, f )
	f.WriteLine  ""
	f.WriteLine  "[" + RegPath + "]"

	RegEnumValues  RegPath, values

	For Each  value  In values
		Select Case  value.Type_

		 Case "REG_SZ"
			f.WriteLine  """" + value.Name + """=""" + _
				g_sh.RegRead( RegPath +"\"+ value.Name ) + """"

		 Case Else  Err.Raise  E_Unexpected
		End Select
	Next
	f.WriteLine ""
End Sub


 
'********************************************************************************
'  <<< [RegWrite] >>> 
'********************************************************************************
Sub  RegWrite( ByVal Path, Value, Type_ )
	clss = "HKEY_CLASSES_ROOT\"
	clss_len = Len( clss )

	If IsEmpty( Type_ ) Then
		Select Case  VarType( Value )
			Case  vbString :          Type_ = "REG_SZ"
			Case  vbLong, vbInteger : Type_ = "REG_DWORD"
		End Select
	End If

	If Left( Path, clss_len ) = clss Then
		Path = "HKEY_CURRENT_USER\Software\Classes\" + Mid( Path, clss_len + 1 )
			'// Path の途中のキーの生成に失敗するため
	End If

	If TryStart(e) Then  On Error Resume Next
		If IsEmpty( Value ) Then
			g_sh.RegDelete  Path
		Else
			g_sh.RegWrite  Path, Value, Type_
		End If
	If TryEnd Then  On Error GoTo 0

	If e.num = &h80070005  or  e.num = 70 Then
		e.OverRaise 70, "<ERROR msg=""レジストリへのアクセスが拒否されました。"" path=""" & Path &"""/>"
	End If
	If e.num <> 0 Then  e.Raise
End Sub


 
'********************************************************************************
'  <<< [RegDelete] >>> 
'********************************************************************************
Sub  RegDelete( ByVal Path )
	If Right( Path, 1 ) <> "\" Then

		g_sh.RegDelete  Path

	Else
		clss = "HKEY_CLASSES_ROOT\"
		clss_len = Len( clss )

		If IsEmpty( g_StdRegProv ) Then _
			Set g_StdRegProv = GetObject("winmgmts:{impersonationLevel=impersonate}!root/default:StdRegProv")

		If Left( Path, clss_len ) = clss Then
			Path = "HKEY_CURRENT_USER\Software\Classes\" + Mid( Path, clss_len + 1 )
				'// Path の途中のキーの生成に失敗するため
		End If

		Path = Left( Path, Len( Path ) - 1 )
		RegEnumKeys  Path, keys, F_SubFolder

		keys2 = ArrayToNameOnlyClassArray( keys )
		QuickSort  keys2, 0, UBound( keys2 ), GetRef("LengthNameCompare"), -1

		For Each key  In keys2
			RegEnumValues  key.Name, values
			For Each value  In values
				'// g_sh.RegDelete  key.Name +"\"+ value.Name  '// このコードでは "\" を含む名前の値を削除できない
				GetRegRootKeyAndStepPath  key.Name, root_key, step_path  '//[out] root_key, step_path
				g_StdRegProv.DeleteValue  root_key, step_path, value.Name
			Next
			g_sh.RegDelete  key.Name +"\"
		Next

		If RegExists( Path +"\" ) Then _
			g_sh.RegDelete  Path +"\"
	End If
End Sub


 
'********************************************************************************
'  <<< [RegWriteAsterExt] >>> 
'********************************************************************************
Sub  RegWriteAsterExt( KeyName, Caption, Command, Opt )
	ThisIsOldSpec
	RegWrite  "HKEY_CLASSES_ROOT\*\shell\"+KeyName+"\", Caption, "REG_SZ"
	RegWrite  "HKEY_CLASSES_ROOT\*\shell\"+KeyName+"\command\", Command, "REG_SZ"
End Sub


 
'********************************************************************************
'  <<< [OpenForRegFile] >>> 
'********************************************************************************
Function  OpenForRegFile( RegFilePath )
	Set OpenForRegFile = new EditRegFile
	OpenForRegFile.Path = RegFilePath
End Function


 
'********************************************************************************
'  <<< [get_FileAssocConsts] >>> 
'********************************************************************************
Dim  g_FileAssocConsts

Function    get_FileAssocConsts()
	If IsEmpty( g_FileAssocConsts ) Then _
		Set g_FileAssocConsts = new FileAssocConsts
	Set get_FileAssocConsts =   g_FileAssocConsts
End Function


Class  FileAssocConsts
	Public  FileExts, Classes

	Private Sub  Class_Initialize()
		FileExts  = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts"
		FileExtsR = "HKEY_CURRENT_USER\Software\Microsoft\Windows\Roaming\OpenWith\FileExts"
		Classes   = "HKEY_CURRENT_USER\Software\Classes"
	End Sub
End Class


 
'********************************************************************************
'  <<< [InstallRegistryFileOpen] >>> 
'********************************************************************************
Sub  InstallRegistryFileOpen( ByVal Extension, ExePath, IsDefault )
	sub_prog_ID = g_fs.GetFileName( ExePath )
	Set c = get_FileAssocConsts()

	exe_abs_path = GetFullPath( env( ExePath ), Empty )
	If Left( Extension, 1 ) <> "." Then  Extension = "."+ Extension

	If IsDefault Then
		RegWrite  c.Classes  +"\"+ Extension +"\", "Applications\"+ sub_prog_ID, Empty
		RegDelete c.FileExts +"\"+ Extension +"\UserChoice\"
		RegWrite  c.FileExts +"\"+ Extension +"\UserChoice\Progid",_
			"Applications\"+ sub_prog_ID, Empty
	End If
	RegWrite  c.Classes +"\Applications\"+ sub_prog_ID +"\shell\open\command\",_
		""""+ exe_abs_path +""" ""%1""", Empty


	'//=== OpenWithList を作る
	If RegExists( c.FileExts +"\"+ Extension +"\OpenWithList\MRUList" ) Then
		mru_list = RegRead( c.FileExts +"\"+ Extension +"\OpenWithList\MRUList" )
		For i=0 To 25
			ch = Chr( Asc( "a" ) + i )
			exe = RegRead( c.FileExts +"\"+ Extension +"\OpenWithList\"+ ch )
			If IsEmpty( exe ) Then
				RegWrite  c.FileExts +"\"+ Extension +"\OpenWithList\MRUList", ch + mru_list, Empty
				RegWrite  c.FileExts +"\"+ Extension +"\OpenWithList\"+ ch, sub_prog_ID, Empty
				Exit For
			ElseIf StrComp( exe, sub_prog_ID, 1 ) = 0 Then
				Exit For
			End If
		Next
	End If
End Sub


 
'********************************************************************************
'  <<< [UninstallRegistryFileOpen] >>> 
'********************************************************************************
Sub  UninstallRegistryFileOpen( Extension, ExePath )
	UninstallRegistryFileOpenCommand  Extension, g_fs.GetFileName( ExePath )
End Sub


 
'********************************************************************************
'  <<< [InstallRegistryFileOpenCommand] >>> 
'********************************************************************************
Sub  InstallRegistryFileOpenCommand( ByVal Extension, SubProgID, CommandLine, IsDefault )
	Set c = get_FileAssocConsts()

	If Left( Extension, 1 ) <> "." Then  Extension = "."+ Extension

	If IsDefault Then
		RegWrite  c.Classes  +"\"+ Extension +"\", "Applications\"+ SubProgID, Empty
		RegDelete c.FileExts +"\"+ Extension +"\UserChoice\"
		RegWrite  c.FileExts +"\"+ Extension +"\UserChoice\Progid",_
			"Applications\"+ SubProgID, Empty
	End If
	RegWrite  c.Classes +"\Applications\"+ SubProgID +"\shell\open\command\",_
		env( CommandLine ), Empty


	'//=== OpenWithList を作る
	mru_list = RegRead( c.FileExts +"\"+ Extension +"\OpenWithList\MRUList" )
	For i=0 To 25
		ch = Chr( Asc( "a" ) + i )
		exe = RegRead( c.FileExts +"\"+ Extension +"\OpenWithList\"+ ch )
		If IsEmpty( exe ) Then
			RegWrite  c.FileExts +"\"+ Extension +"\OpenWithList\MRUList", ch + mru_list, Empty
			RegWrite  c.FileExts +"\"+ Extension +"\OpenWithList\"+ ch, SubProgID, Empty
			Exit For
		ElseIf StrComp( exe, SubProgID, 1 ) = 0 Then
			Exit For
		End If
	Next
End Sub


 
'********************************************************************************
'  <<< [UninstallRegistryFileOpenCommand] >>> 
'********************************************************************************
Sub  UninstallRegistryFileOpenCommand( ByVal Extension, SubProgID )
	Set c = get_FileAssocConsts()

	If Left( Extension, 1 ) <> "." Then  Extension = "."+ Extension

	If RegRead( c.FileExts +"\"+ Extension +"\UserChoice\Progid" ) = "Applications\"+ SubProgID Then _
		RegDelete  c.FileExts +"\"+ Extension +"\UserChoice\"

	'//=== 拡張子に関する設定を削除する
	mru_list = RegRead( c.FileExts +"\"+ Extension +"\OpenWithList\MRUList" )
	If mru_list = "a" Then
		RegDelete  c.FileExts +"\"+ Extension +"\"
		RegDelete  c.Classes  +"\"+ Extension +"\"

	'//=== OpenWithList を詰める
	ElseIf Len( mru_list ) < 26 Then
		For i=0 To 25
			ch1 = Chr( Asc( "a" ) + i )
			exe1 = RegRead( c.FileExts +"\"+ Extension +"\OpenWithList\"+ ch1 )
			If exe1 = SubProgID Then

				'//=== OpenWithList\MRUList を詰める
				For j=1 To Len( mru_list )
					ch2 = Mid( mru_list, j, 1 )
					If ch2 = ch1 Then
						mru_list = Left( mru_list, j-1 ) + Mid( mru_list, j+1 )
					ElseIf ch2 > ch1 Then
						mru_list = Left( mru_list, j-1 ) + Chr( Asc( ch2 ) - 1 ) + Mid( mru_list, j+1 )
					End If
				Next


				'//=== OpenWithList\a-z を詰める
				Do
					i=i+1 : If i = 26 Then  Exit Do
					ch2 = Chr( Asc( "a" ) + i )
					exe2 = RegRead( c.FileExts +"\"+ Extension +"\OpenWithList\"+ ch2 )
					If IsEmpty( exe2 ) Then
						RegDelete  c.FileExts +"\"+ Extension +"\OpenWithList\"+ ch1
						Exit Do
					End If

					RegWrite  c.FileExts +"\"+ Extension +"\OpenWithList\"+ ch1, exe2, Empty
					ch1 = ch2
				Loop

				RegWrite  c.FileExts +"\"+ Extension +"\OpenWithList\MRUList", mru_list, Empty

				Exit For
			End If
			If IsEmpty( exe1 ) Then  Exit For
		Next
	End If

	RegDelete  c.Classes +"\Applications\"+ SubProgID +"\"
End Sub


 
'********************************************************************************
'  <<< [InstallRegistryFileVerb] >>> 
'********************************************************************************
Sub  InstallRegistryFileVerb( ProgID, Verb, Caption, CommandLine )
	If ProgID = "" Then  Raise  E_PathNotFound, "<ERROR msg=""ProgID を指定してください""/>"
	RegWrite  "HKEY_CLASSES_ROOT\"+ ProgID +"\shell\"+ Verb +"\", Caption, "REG_SZ"
	RegWrite  "HKEY_CLASSES_ROOT\"+ ProgID +"\shell\"+ Verb +"\command\", CommandLine, "REG_SZ"
End Sub


 
'********************************************************************************
'  <<< [UninstallRegistryFileVerb] >>> 
'********************************************************************************
Sub  UninstallRegistryFileVerb( ProgID, Verb )
	If ProgID = "" Then  Raise  E_PathNotFound, "<ERROR msg=""ProgID を指定してください""/>"
	RegDelete  "HKEY_CLASSES_ROOT\"+ ProgID +"\shell\"+ Verb +"\"
End Sub


 
'********************************************************************************
'  <<< [RegReadExtProgID] >>> 
'********************************************************************************
Function  RegReadExtProgID( ByVal Extension )
	Set c = get_FileAssocConsts()
	If Left( Extension, 1 ) <> "." Then  Extension = "."+ Extension
	RegReadExtProgID = RegRead( c.FileExts +"\"+ Extension +"\UserChoice\Progid" )
	If IsEmpty( RegReadExtProgID ) Then _
		RegReadExtProgID = RegRead( "HKEY_CLASSES_ROOT\"+ Extension +"\" )
End Function


 
'-------------------------------------------------------------------------
' ### <<<< [EditRegFile] Class >>>> 
'-------------------------------------------------------------------------
Class  EditRegFile

	Private m__Path      ' as string
	Public  m_WriteKeys  ' as Dictionary
	Public  m_ReadKeys   ' as Dictionary
	Public  m_bRead      ' as boolean
	Public  m_bWrite     ' as boolean

	Public Property Get  Path() : Path = m__Path: End Property
	Private Sub  Class_Terminate() : Close : End Sub


 
'********************************************************************************
'  <<< [EditRegFile::Path] >>> 
'********************************************************************************
Public Property Let  Path( RegFilePath )
	If not IsEmpty( m__Path ) Then  Error

	m__Path = RegFilePath
	Set m_WriteKeys = CreateObject( "Scripting.Dictionary" )
	Set m_ReadKeys  = CreateObject( "Scripting.Dictionary" )
End Property


 
'********************************************************************************
'  <<< [EditRegFile::RegRead] >>> 
'********************************************************************************
Public Function  RegRead( Path )
	If not m_bRead Then
		If g_fs.FileExists( m__Path ) Then
			Set f = OpenForRead( m__Path )
			Do Until  f.AtEndOfStream
				line = f.ReadLine()
				i = InStr( line, ";" ) : If i > 0 Then  line = Left( line, i-1 )
				line = Trim( line )
				Select Case  Left( line, 1 )
				 Case "["
					i = InStr( 2, line, "]" )
					folder = Mid( line, 2, i - 2 )

				 Case """"
					i = InStr( 2, line, """" )
					name = Mid( line, 2, i - 2 )
					If name = "@" Then  name = ""

					path2 = folder +"\"+ name
					If not m_WriteKeys.Exists( path2 ) Then

						i = InStr( i, line, "=" )
						Do
							i=i+1 : value = Mid( line, i, 1 )
							If value<>" " and value<>vbTab Then  Exit Do
						Loop
						If Mid( line, i, 1 ) = """" Then
							If i+1 > Len(line)  or  InStr( i+1, line, """" ) = 0 Then
								value = Empty
							Else
								value = Mid( line, i+1, InStr( i+1, line, """" ) - i - 1 )
							End If
						ElseIf Mid( line, i, 6 ) = "dword:" Then
							value = CLng( "&h" & Trim2( Mid( line, i+6 ) ) )
						ElseIf Mid( line, i, 4 ) = "hex:" Then
							value = Empty
						ElseIf Mid( line, i, 9 ) = "multi_sz:" Then
							value = Empty
						ElseIf Mid( line, i, 7 ) = "mui_sz:" Then
							value = Empty
						Else
							value = Empty
						End IF

						m_ReadKeys.Item( path2 ) = value
					End If
				End Select
			Loop
			f = Empty
		End If
		m_bRead = True
	End If

	If m_WriteKeys.Exists( Path ) Then
		RegRead = m_WriteKeys.Item( Path )
	Else
		RegRead = m_ReadKeys.Item( Path )
	End If
End Function


 
'********************************************************************************
'  <<< [EditRegFile::RegWrite] >>> 
'********************************************************************************
Public Sub  RegWrite( Path, Value, Type_ )
	m_WriteKeys.Item( Path ) = Value
	m_bWrite = True
End Sub


 
'********************************************************************************
'  <<< [EditRegFile::Close] >>> 
'********************************************************************************
Public Sub  Close()
	If Err.Number <> 0 Then  Exit Sub
	If not m_bWrite Then  Exit Sub

	Dim path : path = GetTempPath( "EditRegFile_*.txt" )
	Set c = g_VBS_Lib


	'//=== Modify in the file
	If g_fs.FileExists( m__Path ) Then
		Set f = OpenForRead( m__Path )
		Set wf = OpenForWrite( path, c.Unicode )
		Do Until  f.AtEndOfStream
			line0 = f.ReadLine()

			line = Trim( line0 )
			Select Case  Left( line, 1 )
			 Case "["
				Me.AppendNewValue  wf, folder
				i = InStr( 2, line, "]" )
				folder = Mid( line, 2, i - 2 )

			 Case """"
				i = InStr( 2, line, """" )
				name = Mid( line, 2, i - 2 )
				If name = "@" Then  name = ""

				path2 = folder +"\"+ name
				If m_WriteKeys.Exists( path2 ) Then
					If name = "" Then  name = "@"
					line0 = String( InStr( line0, """" ) - 1, " " ) + """" + name + """="
					value = m_WriteKeys.Item( path2 )
					If IsEmpty( value ) Then
						line0 = Empty
					Else
						line0 = line0 + EditRegFile_getRightValue( value )
					End If
					m_WriteKeys.Remove  path2
				End If

			 Case ""
				Me.AppendNewValue  wf, folder
			End Select

			If not IsEmpty( line0 ) Then  wf.WriteLine  line0
		Loop
		f = Empty
	End If
	If IsEmpty( wf ) Then
		path = m__Path
		Set wf = OpenForWrite( path, c.Unicode )
		wf.WriteLine  "Windows Registry Editor Version 5.00"
	End If


	'//=== Append in the file
	folder0 = Empty
	ShakerSort_fromDicKey  m_WriteKeys, writekeys_arr, Empty  '//[out] writekeys_arr
	For Each i  In writekeys_arr
		If Right( i.m_Key, 1 ) = "\" Then
			folder = Left( i.m_Key, Len( i.m_Key ) - 1 )
			name = "@"
		Else
			folder = g_fs.GetParentFolderName( i.m_Key )
			name = g_fs.GetFileName( i.m_Key )
		End If
		If folder <> folder0 Then  wf.WriteLine  "" : wf.WriteLine  "["+ folder +"]" : folder0 = folder
		wf.WriteLine  "  """ + name +"""=" + EditRegFile_getRightValue( i.m_Item )
	Next
	If not IsEmpty( folder0 ) Then  wf.WriteLine  ""
	wf = Empty


	SafeFileUpdate  path, m__Path
	m_bWrite = False
End Sub


 
'********************************************************************************
'  <<< [EditRegFile::AppendNewValue] >>> 
'********************************************************************************
Public Sub  AppendNewValue( WriteFileStream, FolderPath )
	path_len = Len( FolderPath )
	ReDim  del_keys(-1)

	For Each key  In m_WriteKeys.Keys()
		If Left( key, path_len ) = FolderPath  and  InStr( path_len+2, key, "\" ) = 0 Then
			name = Mid( key, path_len+2 ) : If name = "" Then  name = "@"
			WriteFileStream.WriteLine  "  """+ name +"""=" +_
				EditRegFile_getRightValue( m_WriteKeys.Item( key ) )

			ReDim Preserve  del_keys( UBound( del_keys ) + 1 )
			del_keys( UBound( del_keys ) ) = key
		End If
	Next

	For Each key  In del_keys
		m_WriteKeys.Remove  key
	Next
End Sub


 
End Class 


 
'********************************************************************************
'  <<< [EditRegFile_getRightValue] >>> 
'********************************************************************************
Function  EditRegFile_getRightValue( Value )
	Select Case  VarType( value )
		Case vbString : EditRegFile_getRightValue = """" + value + """"
		Case vbInteger: EditRegFile_getRightValue = "dword:" + Hex( value )
		Case Else  Error
	End Select
End Function


 
'********************************************************************************
'  <<< [OpenForEnvVarsFile] >>> 
'********************************************************************************
Function  OpenForEnvVarsFile( EnvVarsFilePath )
	Set OpenForEnvVarsFile = new EditEnvVarsFile
	OpenForEnvVarsFile.Path = EnvVarsFilePath
End Function


 
'-------------------------------------------------------------------------
' ### <<<< [EditEnvVarsFile] Class >>>> 
'-------------------------------------------------------------------------
Class  EditEnvVarsFile

	Private  m__Path      ' as string
	Public   m_WriteKeys  ' as Dictionary
	Public   m_ReadKeys   ' as Dictionary
	Public   m_bRead      ' as boolean
	Public   m_bWrite     ' as boolean

	Public Property Get  Path() : Path = m__Path : End Property
	Private Sub  Class_Terminate() : Close : End Sub


 
'********************************************************************************
'  <<< [EditEnvVarsFile::Path] >>> 
'********************************************************************************
Public Property Let  Path(x)
	Const  NotCaseSensitive = 1

	If not IsEmpty( m__Path ) Then Error

	m__Path = x

	Set m_WriteKeys = CreateObject( "Scripting.Dictionary" )
			m_WriteKeys.CompareMode = NotCaseSensitive

	Set m_ReadKeys = CreateObject( "Scripting.Dictionary" )
			m_ReadKeys.CompareMode = NotCaseSensitive
End Property


 
'********************************************************************************
'  <<< [EditEnvVarsFile::get_] >>> 
'********************************************************************************
Public Function  get_( Name )
	If not m_bRead Then  Me.Read

	If m_WriteKeys.Exists( Name ) Then
		get_ = m_WriteKeys.Item( Name )
	Else
		get_ = m_ReadKeys.Item( Name )
	End If
End Function


 
'********************************************************************************
'  <<< [EditEnvVarsFile::set_] >>> 
'********************************************************************************
Public Sub  set_( Name, Value )
	m_WriteKeys.Item( Name ) = Value
	m_bWrite = True
End Sub


 
'********************************************************************************
'  <<< [EditEnvVarsFile::select_] >>> 
'********************************************************************************
Public Sub  select_( Name, Value, OtherNames, OtherValue )
	For Each name1  In OtherNames
		m_WriteKeys.Item( name1 ) = OtherValue
	Next

	m_WriteKeys.Item( Name ) = Value
	m_bWrite = True
End Sub


 
'********************************************************************************
'  <<< [EditEnvVarsFile::Read] >>> 
'********************************************************************************
Public Function  Read()
	m_ReadKeys.RemoveAll
	If g_fs.FileExists( m__Path ) Then
		Set f = OpenForRead( m__Path )
		Do Until  f.AtEndOfStream
			line = f.ReadLine()
			i = InStr( line, "=" )
			If i > 0 Then
				name1 = Trim( Left( line, i-1 ) )
				value1 = Mid( line, i+1 )
				m_ReadKeys.Item( name1 ) = value1
			End If
		Loop
		f = Empty
	End If
	m_bRead = True
End Function


 
'********************************************************************************
'  <<< [EditEnvVarsFile::Close] >>> 
'********************************************************************************
Public Sub  Close()
	If Err.Number <> 0 Then  Exit Sub
	If not m_bWrite Then  Exit Sub

	If not m_bRead Then  Me.Read
	For Each name  In m_WriteKeys
		m_ReadKeys.Item( name ) = m_WriteKeys.Item( name )
	Next
	m_WriteKeys.RemoveAll

	ShakerSort_fromDicKey  m_ReadKeys, lines, Empty  '//[out] lines

	new_path = GetTempPath( "EditEnvVarsFile.txt" )
	Set f = OpenForWrite( new_path, Empty )
	For Each line  In lines
		If not IsEmpty( line.Item ) Then _
			f.WriteLine  line.Key +"="& line.Item
	Next
	f = Empty

	SafeFileUpdate  new_path, m__Path
	m_bWrite = False
End Sub


 
End Class 


 
'********************************************************************************
'  <<< [GetCScriptGUI_CommandLine] >>> 
'********************************************************************************
Function  GetCScriptGUI_CommandLine( Parameters )
	If g_is64bitWindows Then
		system_path = "%windir%\SysWOW64"
	Else
		system_path = "%windir%\System32"
	End If

	GetCScriptGUI_CommandLine = _
		"""%windir%\System32\cmd.exe"" /K ("""+ system_path +"\cscript.exe"" "+ Parameters + ")"
End Function


 
'********************************************************************************
'  <<< [IsScreenSaverRunning] >>> 
'********************************************************************************
Function  IsScreenSaverRunning()
	Set ec = new EchoOff
	IsScreenSaverRunning = RunProg( g_vbslib_ver_folder +"SPI_GETSCREENSAVERRUNNING\SPI_GETSCREENSAVERRUNNING.exe", "" )
End Function


 
'********************************************************************************
'  <<< [SaveEnvVars] >>> 
'********************************************************************************
Sub  SaveEnvVars( Path_ofSetCommandLog, Option_ )
	Set envs = g_sh.Environment( "Process" )

	If VarType( Path_ofSetCommandLog ) = vbString Then
		echo  ">SaveEnvVars """+ Path_ofSetCommandLog +""""

		Set f = OpenForWrite( Path_ofSetCommandLog, Empty )
		For Each line  In envs
			i = InStr( line, "=" )
			If i >= 2 Then
				f.WriteLine  line
			End If
		Next

	Else

		If IsEmpty( Path_ofSetCommandLog ) Then
			Set Path_ofSetCommandLog = CreateObject( "Scripting.Dictionary" )
		Else
			Path_ofSetCommandLog.RemoveAll
		End If

		For Each line  In envs
			i = InStr( line, "=" )
			If i >= 2 Then
				Path_ofSetCommandLog.Item( Left( line, i-1 ) ) = Mid( line, i+1 )
			End If
		Next

	End If
End Sub


 
'********************************************************************************
'  <<< [MsiModify] >>> 
'********************************************************************************
Sub  MsiModify( MsiPath, TableName, KeyColumnName, ValueColumnNum, Key, NewValue )
	Const const_OpenDatabaseModeTransact = 1
	Const const_ModifyUpdate = 2

	AssertExist  MsiPath
	Set installer = Wscript.CreateObject( "WindowsInstaller.Installer" )
	Set database = installer.OpenDatabase( MsiPath, const_OpenDatabaseModeTransact )

	Set view = database.OpenView( "Select * FROM "+ TableName +_
		" WHERE "+ KeyColumnName +"='"+ Key +"'" )
	view.Execute
	Set record = view.Fetch
	record.StringData( ValueColumnNum ) = NewValue
	view.Modify  const_ModifyUpdate, record
	database.Commit
End Sub


 
'*************************************************************************
'  <<< [SetTaskStartTime] >>> 
'*************************************************************************
Sub  SetTaskStartTime( ByVal TaskName, StartTime )
	echo  ">SetTaskStartTime  """+ TaskName +""", """+ StartTime +""""
	Set ec = new EchoOff

	Set tasks = GetTaskList( Empty )
	Set c = get_SystemConsts()

	If tasks.Exists( TaskName ) Then
		task_fullname = TaskName  '// for XP
	ElseIf tasks.Exists( "\"+ TaskName ) Then
		task_fullname = "\"+ TaskName  '// for Win7
	Else
		Raise  E_NotFoundSymbol, "<ERROR msg=""タスク名が見つかりません"" name="""+ TaskName +"""/>"
	End If

	Select Case  Left( StartTime, 1 )
		Case "+", "-" :  t = DateAddStr( Now(), StartTime )
		Case Else
			t = CDate( StartTime )
			If IsTimeOnlyDate( t ) Then  t = CDate( CStr( Date() ) +" "+ CStr( t ) )
			If t < Now() Then  t = DateAddStr( t, "1day" )
	End Select

	Set task = tasks.Item( task_fullname )

	RunProg "schtasks /Delete /F /TN "+ TaskName, "nul"

	RunProg  "schtasks /Create /Sc once /SD "+ FormatDateTime( t, vbShortDate ) +_
		" /ST "+ FormatDateTime( t, vbShortTime ) +":00 /TN "+ TaskName +_
		" /TR " + task.Item( c.TaskCommand ), "nul"

	ec = Empty
	echo  "実行する時刻： " & DateAddStr( t, "-"& Second(t) &"sec" )
End Sub


 
'*************************************************************************
'  <<< [GetTaskList] >>> 
'*************************************************************************
Function  GetTaskList( EmptyParam )
	Set c = get_SystemConsts()

	tmp = GetTempPath( "TaskList.csv" )
	RunProg  "schtasks /Query /FO CSV /V", tmp

	Set GetTaskList = CreateObject( "Scripting.Dictionary" )

	Set f = OpenForRead( tmp )


	'//=== get column names
	line = f.ReadLine()
	If line = "" Then  line = f.ReadLine()  '// for XP

	Set first_task = CreateObject( "Scripting.Dictionary" )
	i = 1
	Do
		s = MeltCSV( line, i )
		If not IsEmpty( s ) Then  first_task.Item( s ) = Empty
		If i = 0 Then Exit Do
	Loop


	Do Until  f.AtEndOfStream
		line = f.ReadLine()


		'//=== get column values
		If GetTaskList.Count = 0 Then
			Set task = first_task
		Else
			Set task = CreateObject( "Scripting.Dictionary" )
		End If

		i = 1
		For Each name  In first_task.Keys
			s = MeltCSV( line, i )
			If not IsEmpty( s ) Then  task.Item( name ) = s
			If i = 0 Then Exit For
		Next


		'//=== add to tasks
		If task.Item( c.TaskName ) <> c.TaskName Then
			Set GetTaskList.Item( task.Item( c.TaskName ) ) = task
		End If
	Loop
	f = Empty
	del  tmp
End Function


 
'*************************************************************************
'  <<< [get_SystemConsts] >>> 
'*************************************************************************
Dim  g_SystemConsts

Function    get_SystemConsts()
	If IsEmpty( g_SystemConsts ) Then _
		Set g_SystemConsts = new SystemConsts
	Set get_SystemConsts =   g_SystemConsts
End Function


Class  SystemConsts
	Public  TaskName, TaskCommand

	Private Sub  Class_Initialize()
		TaskName    = "タスク名"
		TaskCommand = "実行するタスク"
	End Sub
End Class


 
'********************************************************************************
'  <<< [new_BinaryArray] >>> 
'********************************************************************************
Function  new_BinaryArray( IntegerArray )
	Set bin = new BinaryArray
	If UBound( IntegerArray ) >= 0 Then _
		bin.Write  0, Empty, IntegerArray
	Set new_BinaryArray = bin
End Function


 
'********************************************************************************
'  <<< [new_BinaryArrayFromFile] >>> 
'********************************************************************************
Function  new_BinaryArrayFromFile( Path )
	Set new_BinaryArrayFromFile = ReadBinaryFile( Path )
End Function


 
'********************************************************************************
'  <<< [new_BinaryArrayFromBase64] >>> 
'********************************************************************************
Function  new_BinaryArrayFromBase64( Base64_Text )
	Set bin = new BinaryArray
	Set xml_base64 = g_VBS_Lib.XML_ElementBase64
	xml_base64.text = Base64_Text
	bin.aADODBStream.Write  xml_base64.nodeTypedValue
	Set new_BinaryArrayFromBase64 = bin
End Function


 
'********************************************************************************
'  <<< [ReadBinaryFile] >>> 
'********************************************************************************
Function  ReadBinaryFile( Path )
	Set bin = new BinaryArray
	bin.Load  Path
	Set ReadBinaryFile = bin
End Function


 
'********************************************************************************
'  <<< [new_BinaryArrayAsText] >>> 
'********************************************************************************
Function  new_BinaryArrayAsText( Text, CharacterSet )
	Set bin = new BinaryArray
	Set f = bin.aADODBStream
	f.Type = bin.c.adTypeText
	If IsEmpty( CharacterSet ) Then
		f.Charset = "Unicode"
	Else
		f.Charset = CharacterSet
	End If
	f.WriteText  Text
	f.Position = 0
	f.Type = bin.c.adTypeBinary
	Set new_BinaryArrayAsText = bin
End Function


 
'********************************************************************************
'  <<< [BinaryArray] >>> 
'********************************************************************************
Class  BinaryArray
	Public  aADODBStream
	Public  c

	Private Sub  Class_Initialize()
		Set  Me.c = get_ADODBConsts()

		Set f = CreateObject( "ADODB.Stream" )
		f.Type = Me.c.adTypeBinary
		f.Open
		Set Me.aADODBStream = f
	End Sub

	Private Sub  Class_Terminate()
		Me.aADODBStream.Close
	End Sub


	Public Sub  Load( Path ) : AssertExist  Path : Me.aADODBStream.LoadFromFile  Path : End Sub

	Public Sub  Save( Path )
		g_AppKey.CheckWritable  Path, Empty
		mkdir_for  Path
		Me.aADODBStream.SaveToFile  Path, Me.c.adSaveCreateOverWrite
	End Sub

	Public Property Get  Size() : Size = Me.aADODBStream.Size : End Property
	Public Property Get  Count() : Count = Me.aADODBStream.Size : End Property
	Public Property Get  Length() : Length = Me.aADODBStream.Size : End Property
	Public Property Get  UBound_() : UBound_ = Me.aADODBStream.Size - 1 : End Property

	Public Property Let  Size(x)   : Me.ReDim_ x-1 : End Property
	Public Property Let  Count(x)  : Me.ReDim_ x-1 : End Property
	Public Property Let  Length(x) : Me.ReDim_ x-1 : End Property
	Public Sub  ToEmpty() : Me.ReDim_ -1 : End Sub


	Public Default Property Get  Item( IndexNum )  '// [BinaryArray::Item]
		Set f = Me.aADODBStream
		f.Position = IndexNum
		Item = CByte( AscB( f.Read( 1 ) ) )
	End Property


	Public Property Let  Item( IndexNum, Value )
		Set f  = Me.aADODBStream
		Set f2 = Me.c.ByteValueTable
		If IndexNum >= f.Size Then  Err.Raise  9
		f2.Position = CByte( Value ) + 2
		f.Position = IndexNum
		f2.CopyTo  f, 1
	End Property


	Public Sub  ReDim_( UBound_ )  '// [BinaryArray::ReDim_]
		Set f  = Me.aADODBStream

		'//=== expand
		If UBound_ >= f.Size Then
			f.Position = f.Size
			f.Write  Me.c.ConvertToByteArray( Empty, Empty, UBound_ - f.Size + 1 )

		'//=== reduce
		ElseIf UBound_ < f.Size - 1 Then
			f.Position = UBound_ + 1
			f.SetEOS
		End If
	End Sub


	Public Function  Read( ByVal Offset, ByVal Length )  '// [BinaryArray::Read]
		If IsEmpty( Offset ) Then  Offset = 0
		If IsEmpty( Length ) Then  Length = -1
		Set f = Me.aADODBStream
		f.Position = Offset
		Read = f.Read( Length )
	End Function


	Public Sub  Write( in_Offset,  ByVal in_Length,  in_ByteArray )  '// [BinaryArray::Write]
		If IsArray( in_ByteArray ) Then
			If in_Length = -1       Then  in_Length = UBound( in_ByteArray ) + 1
			If IsEmpty( in_Length ) Then  in_Length = UBound( in_ByteArray ) + 1
		End If

		binary = Me.c.ConvertToByteArray( in_ByteArray, Empty, in_Length )
		Me.WriteFromStandardBinaryArray  in_Offset,  binary
	End Sub


	Public Function  ReadStruct( ByVal Offset, out_Dic, FormatArray )  '// [BinaryArray::ReadStruct]
		If IsEmpty( Offset ) Then  Offset = 0
		Set f = Me.aADODBStream
		f.Position = Offset
		ReadStruct = Me.c.ConvertToStructuredDictionary( f, out_Dic, FormatArray )
	End Function


	Public Sub  WriteStruct( in_Offset, FormatAndDataArray )  '// [BinaryArray::WriteStruct]
		binary = Me.c.ConvertToStructuredByteArray( FormatAndDataArray )
		Me.WriteFromStandardBinaryArray  in_Offset,  binary
	End Sub


	Public Sub  WriteFromDump( in_Offset, in_Dump )  '// [BinaryArray::WriteFromDump]
		binary = Me.c.ConvertToByteArrayFromDump( in_Dump )
		Me.WriteFromStandardBinaryArray  in_Offset,  binary
	End Sub


	Public Sub  WriteFromBinaryArray( ByVal in_OutputOffset,  in_InputBinaryArray,  in_InputOffset,  in_Size )  '// [BinaryArray::WriteFromBinaryArray]
		If IsEmpty( in_OutputOffset ) Then  in_OutputOffset = 0
		If Me.Length < in_OutputOffset Then  Me.Length = in_OutputOffset  '// expand aADODBStream
		Me.aADODBStream.Position = in_OutputOffset
		in_InputBinaryArray.aADODBStream.Position = in_InputOffset
		in_InputBinaryArray.aADODBStream.CopyTo  Me.aADODBStream,  in_Size
	End Sub


	Public Sub  WriteFromStandardBinaryArray( ByVal  in_Offset,  in_BinaryArray ) 
		If IsEmpty( in_Offset ) Then  in_Offset = 0
		If IsNull( in_BinaryArray ) Then  Exit Sub
		If Me.Length < in_Offset Then  Me.Length = in_Offset  '// expand aADODBStream
		Me.aADODBStream.Position = in_Offset
		Me.aADODBStream.Write  in_BinaryArray
	End Sub


	Public Function  Text( CharacterSet )  '// [BinaryArray::Text]
		Set f = Me.aADODBStream
		f.Position = 0
		f.Type = Me.c.adTypeText
		f.Charset = CharacterSet
		Text = f.ReadText( -1 )
	End Function


	Public Function Compare( ThanBinary )  '// [BinaryArray::Compare]
		Me.aADODBStream.Position = 0
		ThanBinary.aADODBStream.Position = 0
		bin1 = Me.aADODBStream.Read( -1 )
		bin2 = ThanBinary.aADODBStream.Read( -1 )
		If IsNull( bin1 ) and IsNull( bin2 ) Then
			Compare = 0
		Else
			Compare = StrComp( bin1, bin2, 0 )
		End If
	End Function


	Public Sub SwapEndian( Offset, Size, SwapUnitSize )  '// [BinaryArray::SwapEndian]
		If Size = 2  and  SwapUnitSize = 2 Then
			value = Item( Offset )
			Item( Offset ) = Item( Offset + 1 )
			Item( Offset + 1 ) = value
		ElseIf Size = 4  and  SwapUnitSize = 4 Then
			value = Item( Offset )
			Item( Offset ) = Item( Offset + 3 )
			Item( Offset + 3 ) = value
			value = Item( Offset + 1 )
			Item( Offset + 1 ) = Item( Offset + 2 )
			Item( Offset + 2 ) = value
		Else
			If SwapUnitSize = 1 Then  Exit Sub
			If SwapUnitSize mod 2 <> 0 Then  Error
			If Size mod SwapUnitSize <> 0 Then  Error

			i_max = SwapUnitSize / 2 - 1
			offset_ = Offset
			over_offset = Offset + Size
			While  offset_ < over_offset
				For i = 0 To i_max
					value = Item( offset_ + i )
					Item( offset_ + i ) = Item( offset_ + SwapUnitSize - 1 - i )
					Item( offset_ + i + SwapUnitSize - 1 - i ) = value
				Next
				offset_ = offset_ + SwapUnitSize
			WEnd
		End If
	End Sub


	Public Property Get  MD5()  '// [BinaryArray::MD5]
		MD5 = GetHash( "System.Security.Cryptography.MD5CryptoServiceProvider" )
	End Property

	Public Property Get  SHA1()  '// [BinaryArray::SHA1]
		SHA1 = GetHash( "System.Security.Cryptography.SHA1CryptoServiceProvider" )
	End Property

	Public Property Get  SHA256()  '// [BinaryArray::SHA256]
		SHA256 = GetHash( "System.Security.Cryptography.SHA256Managed" )
	End Property

	Public Property Get  SHA384()  '// [BinaryArray::SHA384]
		SHA384 = GetHash( "System.Security.Cryptography.SHA384Managed" )
	End Property

	Public Property Get  SHA512()  '// [BinaryArray::SHA512]
		SHA512 = GetHash( "System.Security.Cryptography.SHA512Managed" )
	End Property

	Public Property Get  RIPEMD160()  '// [BinaryArray::RIPEMD160]
		RIPEMD160 = GetHash( "System.Security.Cryptography.RIPEMD160Managed" )
	End Property

	Private Function  GetHash( ClassName )
		Set hash_computer = CreateObject( ClassName )
		Set xml_element = CreateObject( "MSXML2.DOMDocument" ).createElement( "tmp" )
		Set f = Me.aADODBStream
		f.Position = 0
		If f.Size = 0 Then  '// "f.Read()" can not be called
			Assert  ClassName = "System.Security.Cryptography.MD5CryptoServiceProvider"
			GetHash = "d41d8cd98f00b204e9800998ecf8427e"  '// From Wikipedia
		Else
			hash_computer.ComputeHash_2  f.Read()
			xml_element.DataType = "bin.hex"
			xml_element.NodeTypedValue = hash_computer.Hash
			GetHash = xml_element.Text
		End If
	End Function


	Public Property Get  Base64()  '// [BinaryArray::Base64]
		Set xml_base64 = g_VBS_Lib.XML_ElementBase64
		xml_base64.nodeTypedValue = Me.Read( 0, -1 )
		Base64 = xml_base64.text
	End Property


	Public Property Get  xml() : xml=xml_sub(0) : CutLastOf xml,vbCRLF,Empty : End Property
	Public Function  xml_sub( Level )  '// [BinaryArray::xml]
		Set f  = Me.aADODBStream

		xml_sub = GetTab(Level)+ "<BinaryArray size=""0x"& Hex( f.Size ) &""">"

		f.Position = 0
		binary = f.Read()

		offset = 0
		For i=1 To UBound( binary ) + 1
			If offset = 0 Then
				xml_sub = xml_sub + vbCRLF + GetTab(Level)
			Else
				xml_sub = xml_sub + " "
			End If

			xml_sub = xml_sub + Right( "0" + Hex( AscB( MidB( binary, i, 1 ) ) ), 2 )

			offset = offset + 1
			If offset = &h10 Then  offset = 0
		Next

		xml_sub = xml_sub + vbCRLF + GetTab(Level) + "</BinaryArray>"
	End Function

End  Class


 
'********************************************************************************
'  <<< [get_ADODBConsts] >>> 
'********************************************************************************
Dim  g_ADODBConsts

Function    get_ADODBConsts()
	If IsEmpty( g_ADODBConsts ) Then _
		Set g_ADODBConsts = new ADODBConsts
	Set get_ADODBConsts =   g_ADODBConsts
End Function


Class  ADODBConsts
	Public  adReadAll, adReadLine, adTypeBinary, adTypeText
	Public  adModeRead, adModeWrite, adModeReadWrite
	Public  adSaveCreateOverWrite

	Public  Unsigned

	Public  adCRLF, adLF, Keep

	Public  ByteValueTable     '// as ADODB.Stream
	Public  BinaryMakerStream  '// as ADODB.Stream
	Public  DumpRegExp
	Public  NumFF00

	Private Sub  Class_Initialize()
		adReadAll = -1
		adReadLine = -2
		adTypeBinary = 1
		adTypeText = 2
		adModeRead = 1
		adModeWrite = 2
		adModeReadWrite = 3
		adSaveCreateOverWrite = 2

		Unsigned = 4096

		adCRLF = -1
		adLF   = 10
		Keep   = 32


		'//=== Me.ByteValueTable
		Set f = CreateObject( "ADODB.Stream" )
		f.Charset = "unicode"
		f.Open
		For i=0 To 255 Step 2 : f.WriteText  ChrW( i + (i+1)*&h100 ) : Next
		f.Position = 0
		f.Type = Me.adTypeBinary
		Set Me.ByteValueTable = f  '// FE FF 00 01 02 ... FD FE FF

		'//=== Me.BinaryMakerStream
		Set f = CreateObject( "ADODB.Stream" )
		f.Type = Me.adTypeBinary
		f.Open
		Set Me.BinaryMakerStream = f
	End Sub

	Private Sub  Class_Terminate()
		Me.ByteValueTable.Close
		Me.BinaryMakerStream.Close
	End Sub


	'// [ADODBConsts::ConvertToByteArray]
	Public Function  ConvertToByteArray( in_Values,  ByVal  in_Offset,  ByVal  in_Length )
		If IsEmpty( in_Values ) Then

				'// return { 00 00 00 00 ... }
				Set f = Me.BinaryMakerStream
				f.Position = 0
				f.Type = Me.adTypeText
				f.Charset = "iso-8859-1"
				f.WriteText  String( in_Length,  0 )
				f.SetEOS
				f.Position = 0
				f.Type = Me.adTypeBinary
				ConvertToByteArray = f.Read( Me.adReadAll )
				Exit Function

		End If
		Select Case  VarType( in_Values )

			Case  vbInteger
				Me.ByteValueTable.Position = in_Values + 2
				ConvertToByteArray = Me.ByteValueTable.Read( 1 )


			Case  vbArray + vbByte  '// return value from ADODB.Stream.Read
				If IsEmpty( in_Offset ) Then  in_Offset = 0
				If in_Length = -1 Then  in_Length = Empty
				If in_Length = UBound( in_Values ) + 1 Then  in_Length = Empty

				If in_Offset = 0  and  IsEmpty( in_Length ) Then
					ConvertToByteArray = in_Values
				Else
					ConvertToByteArray = Me.ConvertToByteArray( MidB( in_Values, 1 ), in_Offset, in_Length )  '// goto Case vbString
				End If


			Case Else
				If IsEmpty( in_Offset ) Then  in_Offset = 0
				If in_Length = -1 Then  in_Length = Empty
				If IsEmpty( in_Length ) Then  in_Length = LenB( in_Values )

				Set f  = Me.BinaryMakerStream
				Set f2 = Me.ByteValueTable

				If VarType( in_Values ) = vbString Then  '// return value from MidB( ByteArray ) ...

					If in_Length > LenB( in_Values ) Then
						last_i = in_Offset + LenB( in_Values )
						last_padding_len = in_Length - LenB( in_Values )
					Else
						last_i = in_Offset + in_Length
					End If

					f.Position = 0
					For i = in_Offset + 1  To last_i
						f2.Position = AscB( MidB( in_Values, i, 1 ) ) + 2
						f2.CopyTo  f, 1
					Next

				Elseif IsArray( in_Values ) Then  '// user made Array

					If in_Length > UBound( in_Values ) Then  '// in_Length >= UBound( in_Values ) + 1
						last_i = in_Offset + UBound( in_Values )
						last_padding_len = ( in_Length - 1 ) - UBound( in_Values )
					Else
						last_i = in_Offset + in_Length - 1
					End If

					f.Position = 0
					For i = in_Offset  To last_i
						f2.Position = CByte( in_Values(i) ) + 2
						f2.CopyTo  f, 1
					Next

				Else
					Err.Error E_BadType
				End If

				If last_padding_len > 0 Then
					in_Offset = f.Position
					f.Position = 0
					f.Type = Me.adTypeText
					f.Charset = "iso-8859-1"
					f.Position = in_Offset
					f.WriteText  String( last_padding_len,  0 )
					f.SetEOS
					f.Position = 0
					f.Type = Me.adTypeBinary
				Else
					f.SetEOS
					f.Position = 0
				End If

				ConvertToByteArray = f.Read( Me.adReadAll )

		End Select
	End Function


	Public Function  ConvertToStructuredByteArray( FormatAndDataArray )  '// [ADODBConsts::ConvertToStructuredByteArray]
		Set f  = Me.BinaryMakerStream
		Set f2 = Me.ByteValueTable

		f.Position = 0
		i = 0
		While i <= UBound( FormatAndDataArray )
			Dim type_ : type_ = FormatAndDataArray(i) and &h1FFF

			If IsArray( FormatAndDataArray(i+1) ) Then
				is_array = True
				n_last = UBound( FormatAndDataArray(i+1) )
			Else
				is_array = False
				n_last = 0
			End If

			For n=0 To n_last

				If is_array Then
					value = FormatAndDataArray(i+1)(n)
				Else
					value = FormatAndDataArray(i+1)
				End If

				Select Case  type_

					Case  vbByte,  vbByte + Me.Unsigned
						f2.Position = ( value and &hFF ) + 2
						f2.CopyTo  f, 1

					Case  vbInteger
						b = ShortIntToBytes( value )
						f2.Position = b(0) + 2
						f2.CopyTo  f, 1
						f2.Position = b(1) + 2
						f2.CopyTo  f, 1

					Case  vbInteger + Me.Unsigned
						b = LongIntToUShortIntToBytes( value )
						f2.Position = b(0) + 2
						f2.CopyTo  f, 1
						f2.Position = b(1) + 2
						f2.CopyTo  f, 1

					Case  vbLong
						b = LongIntToBytes( value )
						f2.Position = b(0) + 2
						f2.CopyTo  f, 1
						f2.Position = b(1) + 2
						f2.CopyTo  f, 1
						f2.Position = b(2) + 2
						f2.CopyTo  f, 1
						f2.Position = b(3) + 2
						f2.CopyTo  f, 1

					Case Else
						Err.Raise  E_BadType

				End Select
			Next
			i=i+2
		WEnd

		f.SetEOS
		f.Position = 0
		ConvertToStructuredByteArray = f.Read( Me.adReadAll )
	End Function


	Function  ConvertToStructuredDictionary( f, out_Dic, FormatArray )
		Set out_Dic = CreateObject( "Scripting.Dictionary" )
		Dim out_array  '// This code can out_array = Empty

		read_size = 0
		i=0
		While i <= UBound( FormatArray )
			name  = FormatArray(i) : If VarType( name ) <> vbString Then  Err.Raise E_BadType
			Dim type_ : type_ = FormatArray(i+1) and &h1FFF
			If FormatArray(i+1) and vbArray Then
				n_last = FormatArray(i+2) - 1
				If n_last = -2 Then
					n_last = f.Size - f.Position
					Select Case  type_ and &h0FFF
						Case  vbInteger : n_last = n_last / 2
						Case  vbLong    : n_last = n_last / 4
					End Select
					n_last = n_last - 1
				End If
				ReDim  out_array( n_last )
				i=i+3
			Else
				n_last = 0
				out_array = Empty
				i=i+2
			End If

			For n=0 To n_last
				Select Case  type_

					Case  vbByte,  vbByte + Me.Unsigned
						binary = f.Read( 1 ) : read_size = read_size + 1
						value = AscB( binary )

					Case  vbInteger
						binary = f.Read( 2 ) : read_size = read_size + 2
						value = Me.BytesToShortInt( AscB( MidB( binary, 1, 1 ) ), _
							AscB( MidB( binary, 2, 1 ) ) )

					Case  vbInteger + Me.Unsigned
						binary = f.Read( 2 ) : read_size = read_size + 2
						value = Me.BytesToUShortIntToLongInt( AscB( MidB( binary, 1, 1 ) ), _
							AscB( MidB( binary, 2, 1 ) ) )

					Case  vbLong
						binary = f.Read( 4 ) : read_size = read_size + 4
						value = Me.BytesToLongInt( _
							AscB( MidB( binary, 1, 1 ) ), AscB( MidB( binary, 2, 1 ) ), _
							AscB( MidB( binary, 3, 1 ) ), AscB( MidB( binary, 4, 1 ) ) )
					Case Else
						Err.Raise  E_BadType

				End Select

				If IsEmpty( out_array ) Then
					out_Dic( name ) = value
				Else
					out_array(n) = value
				End If
			Next
			If not IsEmpty( out_array ) Then  out_Dic( name ) = out_array
		WEnd
		ConvertToStructuredDictionary = read_size
	End Function


	Public Function  ConvertToByteArrayFromDump( in_Dump )  '// [ADODBConsts::ConvertToByteArrayFromDump]
		Set f  = Me.BinaryMakerStream

		f.Position = 0
		value = 0
		value_bit_count = 0
		operator = ""

		If IsEmpty( Me.DumpRegExp ) Then
			Set Me.DumpRegExp = new_RegExp( "\b(0x)?([0-9A-Fa-f]+)\b|\|", True )
			Me.NumFF00 = CLng("&hFF00")
		End If

		Set matches = Me.DumpRegExp.Execute( in_Dump )
		For Each  match  In  matches
			If match.Value = "|" Then
				operator = "|"
			Else
				If operator = "" Then
					Me_ConvertToByteArrayFromDump_Flush  value,  value_bit_count
				End If


				num_string = match.SubMatches(1)
				local_value = CLng( "&h"+ num_string )
				local_value_bit_count = Len( num_string ) * 4


				If operator = "" Then
					value           = local_value
					value_bit_count = local_value_bit_count
				Else
					value = value  or  local_value
					If local_value_bit_count > value_bit_count Then _
						value_bit_count = local_value_bit_count
					operator = ""
				End If
			End If
		Next
		Me_ConvertToByteArrayFromDump_Flush  value,  value_bit_count

		f.SetEOS
		f.Position = 0
		ConvertToByteArrayFromDump = f.Read( Me.adReadAll )
	End Function


	Private Sub  Me_ConvertToByteArrayFromDump_Flush( value,  value_bit_count )
		Set f  = Me.BinaryMakerStream
		Set f2 = Me.ByteValueTable

		Select Case  value_bit_count
			Case 8
				f2.Position = ( value and &hFF ) + 2
				f2.CopyTo  f, 1
			Case 16
				f2.Position = ( value and &hFF ) + 2
				f2.CopyTo  f, 1
				f2.Position = ( value and Me.NumFF00 ) \ &h100 + 2
				f2.CopyTo  f, 1
			Case 32
				f2.Position = ( value and &hFF ) + 2
				f2.CopyTo  f, 1
				f2.Position = ( value and Me.NumFF00 ) \ &h100 + 2
				f2.CopyTo  f, 1
				f2.Position = ( value and &hFF0000 ) \ &h10000 + 2
				f2.CopyTo  f, 1
				f2.Position = ( ( value and &hFF000000 ) \ &h1000000 and &hFF ) + 2
				f2.CopyTo  f, 1
		End Select
	End Sub


	Public Function  BytesToShortInt( b0, b1 )  '// [ADODBConsts::BytesToShortInt]
		If b1 < &h80 Then
			BytesToShortInt = ( b0 and &hFF ) + ( b1 and &hFF ) * &h100
		Else
			BytesToShortInt = ( b0 and &hFF ) + ( b1 and &hFF or &hFF00 ) * &h100
		End If
	End Function


	Public Function  BytesToUShortIntToLongInt( b0, b1 )  '// [ADODBConsts::BytesToUShortIntToLongInt]
		If b1 < &h80 Then
			BytesToUShortIntToLongInt = CLng( ( b0 and &hFF ) + ( b1 and &hFF ) * &h100 )
		Else
			BytesToUShortIntToLongInt = ( b0 and &hFF ) + ( b1 and &hFF ) * &h100
		End If
	End Function


	Public Function  BytesToLongInt( b0, b1, b2, b3 )  '// [ADODBConsts::BytesToLongInt]
		If b3 < &h80 Then
			BytesToLongInt = ( b0 and &hFF )           + ( b1 and &hFF ) * &h100 +_
			               + ( b2 and &hFF ) * &h10000 + ( b3 and &hFF ) * &h1000000
		Else
			BytesToLongInt = ( b0 and &hFF )           + ( b1 and &hFF ) * &h100 +_
			               + ( b2 and &hFF ) * &h10000 + ( b3 and &hFF or &hFFFFFF00 ) * &h1000000
		End If
	End Function


	Public Function  ShortIntToBytes( Value )  '// [ADODBConsts::ShortIntToBytes]
		ReDim  a(1)
		a(0) = Value and &hFF
		a(1) = ( Value and &hFF00 ) \ &h100 and &hFF
		ShortIntToBytes = a
	End Function


	Public Function  LongIntToUShortIntToBytes( Value )  '// [ADODBConsts::LongIntToUShortIntToBytes]
		ReDim  a(1)
		a(0) = Value and &hFF
		a(1) = ( CLng( Value ) and CLng( &hFF00 ) ) \ &h100 and &hFF
		LongIntToUShortIntToBytes = a
	End Function


	Public Function  LongIntToBytes( Value )  '// [ADODBConsts::LongIntToBytes]
		ReDim  a(3)

		a(0) = Value and &hFF
		If Value < 0  and  VarType( Value ) = vbInteger Then
			a(1) = ( Value and &hFF00 ) \ &h100 and &hFF
			a(2) = 0
			a(3) = 0
		Else
			a(1) = ( Value and     &hFF00 ) \     &h100 and &hFF
			a(2) = ( Value and   &hFF0000 ) \   &h10000 and &hFF
			a(3) = ( Value and &hFF000000 ) \ &h1000000 and &hFF
		End If
		LongIntToBytes = a
	End Function
End Class


 
'***********************************************************************
'* Function: GetHashOfFile
'***********************************************************************
Function  GetHashOfFile( in_Path,  in_HashType )
	If in_HashType = "MD5" Then
		If TryStart(e) Then  On Error Resume Next

			GetHashOfFile = ReadBinaryFile( in_Path ).MD5

		If TryEnd Then  On Error GoTo 0

	ElseIf in_HashType = "SHA1" Then
		If TryStart(e) Then  On Error Resume Next
			GetHashOfFile = ReadBinaryFile( in_Path ).SHA1
		If TryEnd Then  On Error GoTo 0

	ElseIf in_HashType = "SHA256" Then
		If TryStart(e) Then  On Error Resume Next
			GetHashOfFile = ReadBinaryFile( in_Path ).SHA256
		If TryEnd Then  On Error GoTo 0

	ElseIf in_HashType = "SHA384" Then
		If TryStart(e) Then  On Error Resume Next
			GetHashOfFile = ReadBinaryFile( in_Path ).SHA384
		If TryEnd Then  On Error GoTo 0

	ElseIf in_HashType = "SHA512" Then
		If TryStart(e) Then  On Error Resume Next
			GetHashOfFile = ReadBinaryFile( in_Path ).SHA512
		If TryEnd Then  On Error GoTo 0

	ElseIf in_HashType = "RIPEMD160" Then
		If TryStart(e) Then  On Error Resume Next
			GetHashOfFile = ReadBinaryFile( in_Path ).RIPEMD160
		If TryEnd Then  On Error GoTo 0
	Else
		Error
	End If


	If e.num <> 0 Then
		If e.num <> &h8007000E Then  '// Few Memory
			e.Raise
		End If
		e.Clear

		GetHashOfFile = GetHashPS( in_Path, in_HashType )
	End If
End Function


 
'***********************************************************************
'* Function: GetHashPS
'***********************************************************************
Function  GetHashPS( in_Path, in_HashType )

	Select Case  in_HashType
		Case  "MD5":       crypto = "MD5CryptoServiceProvider"
		Case  "SHA1":      crypto = "SHA1CryptoServiceProvider"
		Case  "SHA256":    crypto = "SHA256CryptoServiceProvider"
		Case  "SHA384":    crypto = "SHA384CryptoServiceProvider"
		Case  "SHA512":    crypto = "SHA512CryptoServiceProvider"
		Case Else  Error
	End Select

	command = "Write-Host  ( [System.BitConverter]::ToString( "+_
		"( New-Object System.Security.Cryptography."+ crypto +" )"+_
		".ComputeHash( "+_
		"( New-Object System.IO.StreamReader( '"+ in_Path +"' ) )"+_
		".BaseStream ) ).Replace( '-', '' ) )"

	Set ex = g_sh.Exec( "powershell -nologo  -command "+ command )
	ex.StdIn.Close  '// for Windows7 or PowerShell v1.0
	hash_value = LCase( Trim2( ex.StdOut.ReadAll() ) )

	GetHashPS = hash_value
End Function


 
'********************************************************************************
'  <<< [Decode_MIME_HeaderLine] >>> 
'********************************************************************************
Function  Decode_MIME_HeaderLine( Line )
	start_pos = InStr( Line, "=?" )  '// start position
	If start_pos = 0 Then
		Decode_MIME_HeaderLine = Line
	Else
		'// "=?charset?encoding?encoded_text?="
		pos = start_pos + 2
		over = InStr( pos, Line, "?" )
		charset = UCase( Mid( Line, pos, over - pos ) )

		pos = over + 1
		over = InStr( pos, Line, "?" )
		encoding = UCase( Mid( Line, pos, over - pos ) )

		pos = over + 1
		over = InStr( Line, "?=" )
		encoded_text = Mid( Line, pos, over - pos )

		Assert  encoding = "B"
		Set charset_text = new_BinaryArrayFromBase64( encoded_text )

		text = charset_text.Text( charset )

		Decode_MIME_HeaderLine = Left( Line, start_pos - 1 ) + text + Mid( Line, over + 2 )
	End If
End Function


 
'*************************************************************************
'  <<< [OpenForReadRIFF] >>> 
'*************************************************************************
Function  OpenForReadRIFF( in_Path )
	Set bin = new RIFF_Reader
	AssertExist  in_Path
	bin.aADODBStream.LoadFromFile  in_Path

	bin.ReadRootChunk
	Set OpenForReadRIFF = bin
End Function

Class  RIFF_Reader
	Public  aADODBStream
	Public  c
	Public  Stack

	Private Sub  Class_Initialize()
		Set  Me.c = get_ADODBConsts()

		Set f = CreateObject( "ADODB.Stream" )
		f.Type = Me.c.adTypeBinary
		f.Open
		Set Me.aADODBStream = f
	End Sub

	Function  ReadRootChunk()
		Me.aADODBStream.Position = 0

		list_fourCC = Me.ReadFourCC()
		If list_fourCC <> "RIFF" Then
			Raise  13, "<ERROR msg=""データの先頭が RIFF になっていません。"" path="""+ _
				in_Path +"""/>"
		End If

		Set chunk = new RIFF_ChunkClass
		chunk.Offset = 0
		chunk.Size = Me.ReadLong()
		chunk.FourCC = Me.ReadFourCC()
		chunk.IsExistChild = True
		chunk.IsExistNextSibling = False
		Me.Stack = Array( chunk )

		Set ReadRootChunk = chunk
	End Function

	Function  ReadFirstChild()
		Set chunk = Me.Stack( UBound( Me.Stack ) )
		If not chunk.IsExistChild Then _
			Raise  9, "<ERROR msg=""子チャンクがありません。""/>"
		Set ReadFirstChild = Me.ReadChunkAt( chunk.Offset + 12 )
	End Function

	Function  ReadNextSibling()
		Set chunk = Me.Stack( UBound( Me.Stack ) )
		If not chunk.IsExistNextSibling Then _
			Raise  9, "<ERROR msg=""次の兄弟チャンクがありません。""/>"
		ReDim Preserve  Stack( UBound( Me.Stack ) - 1 )

		If chunk.Size Mod 2 = 0 Then
			plus = 8
		Else
			plus = 9
		End If
		Set ReadNextSibling = Me.ReadChunkAt( chunk.Offset + plus + chunk.Size )
	End Function

	Function  ReadChunkAt( in_NewOffset )
		Me.aADODBStream.Position = in_NewOffset
		fourCC = Me.ReadFourCC()

		Set chunk = new RIFF_ChunkClass
		chunk.Offset = in_NewOffset
		chunk.Size = Me.ReadLong()
		If fourCC = "LIST" Then
			chunk.FourCC = Me.ReadFourCC()
			chunk.IsExistChild = ( chunk.Size >= 12 )
		Else
			chunk.FourCC = fourCC
			chunk.IsExistChild = False
		End If

		Set parent = Me.Stack( UBound( Me.Stack ) )
		chunk.IsExistNextSibling = _
			( chunk.Offset + chunk.Size + 1 < parent.Offset + parent.Size )
			'// = next sibling - 8
			'// +1 is by alignment

		new_ubound = UBound( Me.Stack ) + 1
		ReDim Preserve  Stack( new_ubound )
		Set Me.Stack( new_ubound ) = chunk
		Set ReadChunkAt = chunk
	End Function

	Function  ReadStruct( out_Dic, FormatArray )
		ReadStruct = Me.c.ConvertToStructuredDictionary( Me.aADODBStream, out_Dic, FormatArray )
	End Function

	Function  ReturnToParent()
		new_ubound = UBound( Me.Stack ) - 1
		ReDim Preserve  Stack( new_ubound )
		Set ReturnToParent = Me.Stack( new_ubound )
	End Function

	Function  SeekChunkByIndexes( in_Empty, in_Indexes0_Array )
		Assert  IsEmpty( in_Empty )
		Set chunk = Me.ReadRootChunk()
		For i=0 To UBound( in_Indexes0_Array )
			If not chunk.IsExistChild Then _
				Raise  9, "<ERROR msg=""子チャンクがありません。""/>"
			index = in_Indexes0_Array(i)
			Assert  index >= 0

			Set chunk = Me.ReadFirstChild()
			For k=1 To index
				Set chunk = Me.ReadNextSibling()
			Next
		Next
		Set SeekChunkByIndexes = chunk
	End Function

	Public Function  ReadFourCC()
		b = Me.aADODBStream.Read( 4 )
		ReadFourCC = LeftB( b, 1 ) + ChrB( 0 ) + MidB( b, 2, 1 ) + ChrB( 0 ) + _
			MidB( b, 3, 1 ) + ChrB( 0 ) + RightB( b, 1 ) + ChrB( 0 )
	End Function

	Public Function  ReadLong()
		b = Me.aADODBStream.Read( 4 )
		ReadLong = Me.c.BytesToLongInt( AscB( b ), AscB( MidB( b, 2, 1 ) ), _
			AscB( MidB( b, 3, 1 ) ), AscB( RightB( b, 1 ) ) )
	End Function
End Class


Class  RIFF_ChunkClass
	Public  Offset
	Public  FourCC
	Public  Size
	Public  IsExistChild
	Public  IsExistNextSibling
End Class


 
'*************************************************************************
'  <<< [OpenForWriteRIFF] >>> 
'*************************************************************************
Function  OpenForWriteRIFF( in_Path, in_RootFourCC )
	Assert  Len( in_RootFourCC ) = 4
	g_AppKey.CheckWritable  in_Path, Empty
	Set bin = new RIFF_Writer
	bin.Path = in_Path
	bin.WriteAscii  "RIFF"+ String( 4, Chr(0) ) + in_RootFourCC
	bin.IsNextChunk = True
	Set OpenForWriteRIFF = bin
End Function

Class  RIFF_Writer
	Public  aADODBStream
	Public  c
	Public  Stack
	Public  Path
	Public  IsNextChunk

	Private Sub  Class_Initialize()
		Set  Me.c = get_ADODBConsts()

		Set f = CreateObject( "ADODB.Stream" )
		f.Type = Me.c.adTypeBinary
		f.Open
		Set Me.aADODBStream = f

		Stack = Array( 0 )
	End Sub

	Private Sub  Class_Terminate()
		While  UBound( Stack ) >= 0
			Me.WriteEnd
		WEnd
		mkdir_for  Me.Path
		Me.aADODBStream.SaveToFile  Me.Path, Me.c.adSaveCreateOverWrite
		Me.aADODBStream.Close
	End Sub

	Property Get  Position() : Position = Me.aADODBStream.Position : End Property
	Property Let  Position(x) : Me.aADODBStream.Position = x : End Property

	Sub  WriteLIST( in_FourCC )
		Assert  Len( in_FourCC ) = 4
		Assert  Me.IsNextChunk

		ReDim Preserve  Stack( UBound( Stack ) + 1 )
		Stack( UBound( Stack ) ) = Me.aADODBStream.Position
		Me.WriteAscii  "LIST"+ String( 4, Chr(0) ) + in_FourCC

		Me.IsNextChunk = True
	End Sub

	Sub  WriteChunk( in_FourCC )
		Assert  Len( in_FourCC ) = 4
		Assert  Me.IsNextChunk

		ReDim Preserve  Stack( UBound( Stack ) + 1 )
		Stack( UBound( Stack ) ) = Me.aADODBStream.Position
		Me.WriteAscii  in_FourCC + String( 4, Chr(0) )

		Me.IsNextChunk = False
	End Sub

	Sub  WriteStruct( in_FormatAndDataArray )
		Assert  not Me.IsNextChunk

		byte_array = Me.c.ConvertToStructuredByteArray( in_FormatAndDataArray )
		If not IsNull( byte_array ) Then
			Me.aADODBStream.Write  byte_array
		End If
	End Sub

	Sub  WriteStructAt( in_Offset, in_FormatAndDataArray )
		position_back_up = Me.aADODBStream.Position
		Me.aADODBStream.Position = in_Offset

		byte_array = Me.c.ConvertToStructuredByteArray( in_FormatAndDataArray )
		If not IsNull( byte_array ) Then
			Me.aADODBStream.Write  byte_array
		End If

		Me.aADODBStream.Position = position_back_up
	End Sub

	Sub  Write( in_ByteArray )
		Assert  not Me.IsNextChunk

		If not IsNull( byte_array ) Then
			Me.aADODBStream.Write  in_ByteArray
		End If
	End Sub

	Sub  WritePadding( in_FourCC, in_Alignment )
		Assert  Me.IsNextChunk

		position_ = Me.aADODBStream.Position

		If ( (position_ + 8)  mod  in_Alignment ) <> 0 Then
			Me.WriteChunk  in_FourCC

			position_ = Me.aADODBStream.Position
			If ( (position_ + 8)  mod  in_Alignment ) <> 0 Then
				padding_size = in_Alignment - _
					( (position_ + 8 )  mod  in_Alignment )

				ReDim  padding( padding_size - 1 )
				For i=0 To UBound( padding )
					padding(i) = 0
				Next
				Me.WriteStruct  Array( vbByte, padding )
			End If
			Me.WriteEnd
		End If
	End Sub

	Sub  WriteEnd()
		Set in_ = Me.c.ByteValueTable
		Set out = Me.aADODBStream
		current_position = out.Position
		begin_position = Stack( UBound( Stack ) )
		ReDim Preserve  Stack( UBound( Stack ) - 1 )
		out.Position = begin_position + 4
		b = Me.c.LongIntToBytes( current_position - ( begin_position + 8 ) )
		in_.Position = b(0) + 2
		in_.CopyTo  out, 1
		in_.Position = b(1) + 2
		in_.CopyTo  out, 1
		in_.Position = b(2) + 2
		in_.CopyTo  out, 1
		in_.Position = b(3) + 2
		in_.CopyTo  out, 1
		out.Position = current_position
		If current_position  Mod 2 = 1 Then
			in_.Position = 2
			in_.CopyTo  out, 1
		End If
		Me.IsNextChunk = True
	End Sub

	Sub  WriteAscii( in_String )
		Set in_ = Me.c.ByteValueTable
		Set out = Me.aADODBStream

		For i=1 To Len( in_String )
			in_.Position = Asc( Mid( in_String, i ) ) + 2
			in_.CopyTo  out, 1
		Next
	End Sub
End Class


 
'********************************************************************************
'  <<< [WaitForProcess] >>> 
'********************************************************************************
Sub  WaitForProcess( ProcessName )
	Do
		Sleep  300
		Set ps = EnumProcesses()
		If not ps.Exists( ProcessName ) Then  Exit Sub
	Loop
End Sub


 
'********************************************************************************
'  <<< [EnumProcesses] >>> 
'********************************************************************************
Function  EnumProcesses()
	Set ec = new EchoOff

	cmd = "tasklist /fo CSV /nh"
	tmp = GetTempPath( "EnumProcesses_*.txt" )
	r= RunBat( cmd, tmp )
	If r <> 0 Then  Error

	Set r = CreateObject( "Scripting.Dictionary" )
	Set f = OpenForRead( tmp )
	is_read = False
	Do Until  f.AtEndOfStream
		line = f.ReadLine()

		If not is_read Then
			If InStr( line, cmd ) > 0 Then  is_read = True
		Else
			i = 1
			name = MeltCSV( line, i )
			num  = CLng( MeltCSV( line, i ) )

			If not r.Exists( name ) Then
				Set nums = new ArrayClass
				Set r.Item( name ) = nums
			Else
				Set nums = r.Item( name )
			End If

			nums.Add  num
		End If
	Loop
	f = Empty
	del  tmp

	Set EnumProcesses = r
End Function


 
'********************************************************************************
'  <<< [KillProcess] >>> 
'********************************************************************************
Sub  KillProcess( Process )
	echo  ">KillProcess  "& Process
	Set ec = new EchoOff

	If IsNumeric( Process ) Then

		r= RunBat( "taskkill /pid " & Process, Empty )

	Else

		Set ps = EnumProcesses()

		If not ps.Exists( Process ) Then  Exit Sub

		For Each  pid  In ps.Item( Process ).Items
			r= RunBat( "taskkill /pid " & pid, Empty )
		Next

		For i=1 To 4
			Sleep  1000

			Set ps = EnumProcesses()
			If not ps.Exists( Process ) Then  Exit Sub
		Next

		Set ps = EnumProcesses()
		For Each  pid  In ps.Item( Process ).Items
			r= RunBat( "taskkill /f /pid " & pid, Empty )
		Next

		Do
			For i=1 To 5
				Sleep  1000

				Set ps = EnumProcesses()
				If not ps.Exists( Process ) Then  Exit Sub
			Next
			echo_v  "強制終了されるのを待っています……"
		Loop
	End If
End Sub


 
'***********************************************************************
'* Function: CompileCSharp
'***********************************************************************
Function  CompileCSharp( in_SourceFilePath )
	Set exe = new CompileCSharpClass
	Set ds = new CurDirStack
	csc = env("%windir%\Microsoft.NET\Framework\v4.0.30319\csc")
	exe.SourcePath = GetFullPath( in_SourceFilePath,  Empty )
	exe.ProgramFolderPath = GetTempPath( "cs_script_*" )
	exe.BuildLogPath = exe.ProgramFolderPath +"\build.log"
	exe.ExePath = exe.ProgramFolderPath +"\"+ g_fs.GetBaseName( in_SourceFilePath ) +".exe"
	If not g_is_debug Then _
		Set ec = new EchoOff

	mkdir  exe.ProgramFolderPath
	cd     exe.ProgramFolderPath
	r= RunProg( """"+ csc +"""  /nologo  """+ exe.SourcePath +"""",  exe.BuildLogPath )
	If r <> 0 Then
		start  GetEditorCmdLine( exe.BuildLogPath )
		ec = Empty
		Raise  1,  "<ERROR source="""+ in_SourceFilePath +""" build_log="""+ exe.BuildLogPath +"""/>"
	End If

	Set CompileCSharp = exe
End Function


 
'***********************************************************************
'* Class: CompileCSharpClass
'***********************************************************************
Class  CompileCSharpClass
	Public  SourcePath
	Public  ExePath
	Public  ProgramFolderPath
	Public  BuildLogPath

	Public Function  Run( in_Parameter,  in_StdoutStderrRedirect )
		echo  ""
		echo  ">"""+ Me.SourcePath +"""  "+ in_Parameter

		Run = RunProg( """"+ Me.ExePath +"""  "+ in_Parameter,  in_StdoutStderrRedirect )
	End Function

	Public Function  Start( in_Parameter )
		echo  ">current dir = """+ g_sh.CurrentDirectory +""""
		echo  ">"""+ Me.SourcePath +"""  "+ in_Parameter

		Set ec = new EchoOff
		start  """"+ Me.ExePath +"""  "+ in_Parameter
	End Function

	Public Sub  Delete()
		Set ec = new EchoOff
		del  Me.ProgramFolderPath
	End Sub

	Private Sub  Class_Terminate()
		Me.Delete
	End Sub
End Class

'* Section: Global


 
