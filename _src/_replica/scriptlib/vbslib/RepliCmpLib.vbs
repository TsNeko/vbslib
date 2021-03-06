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
Dim  g_RepliCmp_Path
     g_RepliCmp_Path = g_SrcPath


Const  LimitStartLines_Default = 65535
Const  MaxByteOfLine_Default = 4096
Const  LimitReplaceLines_Default = 65535

Const  NotMatchErr = 101
Const  DiffErr = 102
Const  ReplaceErr = 103


 
'********************************************************************************
'  <<< [RepliCmp] >>> 
'********************************************************************************
Sub  RepliCmp( FolderPaths, FileNames, Opt )

	Dim  folders, folder, folder_path, f, path, i_file, i_folder, b, b_skip
	Dim  desktop, fname, is_exist_in_master, s, o
	Dim  diffs_txt_f, merge_vbs_f
	ReDim  repli_files( UBound(FileNames) + 1 )
	ReDim  is_exist_in_master( UBound( FileNames ) )

	echo  "RepliCmp"


	'//=== Check parameters
	For Each folder_path  In FolderPaths
		If not exist( folder_path ) Then  Err.Raise 1,,"[RepliCmp] 同期するフォルダが見つかりません："+folder_path
	Next
	For i_file=0 To UBound(FileNames)
		If IsEmpty( FileNames(i_file) ) Then  Err.Raise 1,,"[RepliCmp] 同期するファイル名が設定されていません：file("&i_file&")"
	Next


	'//=== Delete out folder
	If exist( g_sh.SpecialFolders( "desktop" ) + "\_RepliCmp" ) Then
		Dim  i
		i = input( "出力先フォルダ desktop\_RepliCmp がすでにあります。削除してよろしいですか？[Y/N]" )
		If i <> "y" and i <> "Y" Then Exit Sub

		del  g_sh.SpecialFolders( "desktop" ) + "\_RepliCmp"
	End If


	'//=== Collect replica files
	Set  repli_files(0) = new RepliCmp_Files : ErrCheck
	Set  repli_files(0).m_Option = Opt
	For i_file = 0 To UBound( FileNames )
		Set  repli_files(i_file+1) = new RepliCmp_Files : ErrCheck
		Set  repli_files(i_file+1).m_Option = Opt
	Next
	i_folder = 1
	For Each  folder_path  In FolderPaths
		echo  "Investigating: " + folder_path

		If i_folder = 1 Then
			For i_file = 0 To UBound( FileNames ) : is_exist_in_master( i_file ) = False : Next
		End If

		EnumFolderObject  folder_path, folders  '// [out] folders

		For Each folder  In folders

			b_skip = False
			For Each f  In Opt.m_ExceptFolders
				If InStr( folder, f ) > 0 Then  b_skip = True
			Next

			If not b_skip Then
				For Each f  In folder.Files
					fname = f.Name
					For i_file = 0 To UBound( FileNames )
						If StrComp( FileNames( i_file ), fname, 1 ) = 0 Then
							repli_files( i_file ).AddFile  f.Path
							is_exist_in_master( i_file ) = True
						End If
					Next
				Next
			End If
		Next

		If i_folder = 1 Then
			s = ""
			For i_file = 0 To UBound( FileNames )
				If not is_exist_in_master( i_file ) Then
					s = s + "<FILE path=""" + FileNames( i_file ) + """/>"+vbCRLF
				End If
			Next
			If s <> "" Then
				Err.Raise 1,,"<ERROR msg=""指定のファイルがマスターフォルダに見つかりません"">" + vbCRLF+_
					s + "</ERROR>"
			End If
		End If

		i_folder = i_folder + 1
	Next


	'//=== Read and compare files
	Dim  diff_log, out, n_diff

	n_diff = 0
	Set diff_log = new RepliCmp_DiffLog : ErrCheck

	desktop = g_sh.SpecialFolders( "desktop" )
	mkdir  desktop +"\_RepliCmp"

	Set diffs_txt_f = g_fs.CreateTextFile( desktop +"\_RepliCmp\Diffs.txt", True, True )

	Set merge_vbs_f = g_fs.CreateTextFile( desktop +"\_RepliCmp\Merge.vbs", True, True )
	Set o = merge_vbs_f
		WriteVBSLibHeader  o, Empty
		o.WriteLine  "Sub  Main( Opt, AppKey )"
		o.WriteLine  "	AppKey.SetWritableMode  F_IgnoreIfWarn"
		o.WriteLine  ""
		o.WriteLine  "	Dim  sync_files : Set sync_files = new SyncFiles" : ErrCheck
		o.WriteLine  "	Set opt = new Merge_Option" : ErrCheck
		o.WriteLine  ""
		o.WriteLine  "	opt.m_EditorPath = """ + Opt.m_EditorPath + """"
		o.WriteLine  "	opt.m_DiffPath = """ + Opt.m_DiffPath + """"
		o.WriteLine  ""
		o.WriteLine  "	Set  sync_files.m_MergeOption = opt"
		o.WriteLine  ""
	o = Empty

	For i_file = 0 To UBound(FileNames)
		echo  "Investigating: " + g_fs.GetFileName( repli_files(i_file).m_Files(0).m_Path )
		Set out = diff_log
		repli_files(i_file).OutDiff  out, diffs_txt_f, merge_vbs_f
		If diff_log.m_NSameGroup >= 2 Then  n_diff = n_diff + 1
		repli_files(i_file) = Empty
	Next

	Set o = merge_vbs_f
		o.WriteLine  "	sync_files.RunMergePrompt"
		o.WriteLine  "End Sub"
		o.WriteLine  ""
		o.WriteLine  ""
		o.WriteLine  " "
		WriteVBSLibFooter  o, Empty
	o = Empty
	merge_vbs_f = Empty
	diffs_txt_f = Empty

	'//=== Copy vbslib
	copy  g_vbslib_folder + "*", desktop + "\_RepliCmp\scriptlib"

	If n_diff = 0 Then
		del  desktop + "\_RepliCmp"
		echo  "No different file."
	Else
		Set f = g_fs.CreateTextFile( desktop + "\_RepliCmp\readme.txt", True, False )
		f.WriteLine "差分状況は、Diffs.txt ファイルに書かれています。"
		f.WriteLine "Merge.vbs を実行すると、マージ作業を補助するウィンドウが開きます。"
		f = Empty

		If not Opt.m_bSilent Then
			OpenFolder  g_sh.SpecialFolders( "desktop" ) + "\_RepliCmp"
		End If
		echo "マージ作業を行う _RepliCmp フォルダを、デスクトップに作成しました。"
		echo "つづきは、readme.txt ファイルの内容を参照してください。"
	End If
End Sub


 
'*-------------------------------------------------------------------------*
'* ◆<<<< [RepliCmp_Files] Class >>>> */ 
'*-------------------------------------------------------------------------*


Class  RepliCmp_Files
	Public  m_Files()
	Public  m_Option

	Private Sub Class_Initialize
		Redim  m_Files(-1)
	End Sub

 
'********************************************************************************
'  <<< [RepliCmp_Files::AddFile] >>> 
'********************************************************************************
Public Sub  AddFile( Path )
	Dim  f : Set f = new RepliCmp_File : ErrCheck

	ReDim Preserve  m_Files( UBound( m_Files ) + 1 )
	Set  m_Files( UBound( m_Files ) ) = f

	f.m_Path = Path
End Sub

 
'********************************************************************************
'  <<< [RepliCmp_Files::OutDiff] >>> 
'********************************************************************************
Public Sub  OutDiff( out_DiffLog, DiffsTxtFile, MergeVbsFile )
	Dim  fname

	fname = g_fs.GetFileName( Me.m_Files(0).m_Path )


	'//=== Compare and set same group
	Dim  i, j, i_same_group

	i_same_group = 1
	For i=0 To UBound( Me.m_Files )
		If IsEmpty( Me.m_Files(i).m_ISameGroup ) Then
			Me.m_Files(i).m_ISameGroup = i_same_group
			For j=i+1 To UBound( Me.m_Files )
				If IsEmpty( Me.m_Files(j).m_ISameGroup ) Then
					If fc_r( Me.m_Files(i).m_Path, Me.m_Files(j).m_Path, "nul" ) Then _
						Me.m_Files(j).m_ISameGroup = i_same_group
				End If
			Next
			i_same_group = i_same_group + 1
		End If
	Next
	i_same_group = i_same_group - 1


	'//=== Out different files
	Dim  f, line

	If i_same_group = 1 Then
		'// All files are same
	Else

		'//=== Write fname+" diffs.txt"
		Set f = DiffsTxtFile
		f.WriteLine  "[" + fname + "]"
		f.WriteLine  "FilesCount = " & UBound( Me.m_Files ) + 1
		f.WriteLine  "SameFileGroupsCount = " & i_same_group
		For i=0 To UBound( Me.m_Files )
			f.WriteLine  "File" & Me.m_Files(i).m_ISameGroup & " = " &  Me.m_Files(i).m_Path
		Next
		f = Empty


		'//=== Write "Merge "+fname+".txt"
		Set f = MergeVbsFile
		j = 1
		For i=0 To UBound( Me.m_Files )
			If j = Me.m_Files(i).m_ISameGroup Then
				f.WriteLine "  sync_files.AddRepliFile  """+Me.m_Files(i).m_Path+""""
				j = j + 1
			End If
		Next
		j = 1
		For i=0 To UBound( Me.m_Files )
			If j = Me.m_Files(i).m_ISameGroup Then
				j = j + 1
			Else
				f.WriteLine "  sync_files.AddSameFile  """+Me.m_Files(i).m_Path+""""
			End If
		Next
		f.WriteLine "  sync_files.NextSyncFile"
		f.WriteLine ""
		f = Empty

	End If

	out_DiffLog.m_NSameGroup = i_same_group
End Sub


 
End Class 
 
'*-------------------------------------------------------------------------*
'* ◆<<<< [RepliCmp_File] Class >>>> */ 
'*-------------------------------------------------------------------------*


Class  RepliCmp_File
	Public  m_Path
	Public  m_ISameGroup
End Class


 
'*-------------------------------------------------------------------------*
'* ◆<<<< [RepliCmp_DiffLog] Class >>>> */ 
'*-------------------------------------------------------------------------*


Class  RepliCmp_DiffLog
	Public  m_NSameGroup
End Class



 
'*-------------------------------------------------------------------------*
'* ◆<<<< [RepliCmp_Option] Class >>>> */ 
'*-------------------------------------------------------------------------*


Class  RepliCmp_Option
	Public  m_EditorPath
	Public  m_DiffPath
	Public  m_bSilent
	Public  m_ExceptFolders  ' as array of string

	Private Sub  Class_Initialize()
		m_ExceptFolders = Array()
	End Sub
End Class



 
'*-------------------------------------------------------------------------*
'* ◆<<<< (PartCmp_Option) クラス >>>> * 
'*-------------------------------------------------------------------------*

Class  PartCmp_Option
	Public  ExceptFolder
	Public  bSubFolder
	Public  BatPath
	Public  BatVar

	Public  LimitStartLines
	Public  MaxByteOfLine

	Private Sub Class_Initialize
		LimitStartLines = LimitStartLines_Default
		MaxByteOfLine = MaxByteOfLine_Default
	End Sub

End Class


 
'********************************************************************************
'  <<< [PartCmp_main] >>> 
'********************************************************************************
Sub  PartCmp_main( Opt )

	Dim  PartPath, WholePath, StartTag
	Dim  rep_n
	Dim  en, ed

	If IsEmpty( Opt ) Then  Set Opt = new PartCmp_Option : ErrCheck


	'//=== 引数の取得とチェック
	ErrCheck : On Error Resume Next
		PartPath  = WScript.Arguments.Unnamed(0)
		WholePath = WScript.Arguments.Unnamed(1)
		StartTag  = WScript.Arguments.Unnamed(2)
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	If en <> 0 Then
		If en = 9 Then
			echo "PartCmp  part_file  whole_file  start_tag"
		Else
			echo "[ERROR] (" & en & ") " & ed
		End If
		Stop : WScript.Quit  3
	End If

	Opt.bSubFolder = ArgumentExist( "S" )
	Opt.ExceptFolder = WScript.Arguments.Named.Item("E")
	If Not IsEmpty( Opt.ExceptFolder ) Then  Opt.ExceptFolder = g_fs.GetAbsolutePathName( Opt.ExceptFolder )

	Opt.BatVar = WScript.Arguments.Named.Item("B")
	If Not IsEmpty( Opt.BatVar ) Then
		rep_n = InStr( Opt.BatVar, "=" )
		If rep_n = 0 Then
			echo "[ERROR] /B option: not found ="
			Stop : WScript.Quit  3
		End If
		Opt.BatPath = Mid( Opt.BatVar, rep_n + 1 )
		Opt.BatVar  = Left( Opt.BatVar, rep_n - 1 )
	End IF

	If PartCmp_compareFiles( WholePath, PartPath, StartTag, Opt ) Then
		Stop : WScript.Quit 21
	Else
		Stop : WScript.Quit 2
	End If
End Sub

 
'********************************************************************************
'  <<< [PartCmp_compareFiles] >>> 
'********************************************************************************
Function  PartCmp_compareFiles( WholePath, PartPath, StartTag, Opt )
	Dim  SamePartPath, SameCollection
	Dim  rep_n, b, en, ed, s

	IF IsEmpty( Opt ) Then  Set Opt = new PartCmp_Option : ErrCheck


	'//=== 処理の内容を表示する
	If Opt.bSubFolder Then  s = "with"  Else  s = "without"
	echo "[PartCmp]"
	echo "PartStartTag: """ & StartTag & """"
	echo "MasterPartFile: """ & GetFullPath( PartPath, Empty ) & """"
	echo ""
	echo "Investigating in """ & GetFullPath( WholePath, Empty ) _
		& """ " & s & " sub folder ..."
	echo ""


	'//=== Set "except_folders"
	If IsEmpty( Opt.ExceptFolder ) Then
		except_folders = Array( )
	ElseIf IsArray( Opt.ExceptFolder ) Then
		ReDim  except_folders( UBound( Opt.ExceptFolder ) )
		For i = 0  To UBound( Opt.ExceptFolder )
			except_folders(i) = GetFullPath( Opt.ExceptFolder(i), Empty )
		Next
	Else
		except_folders = Array( GetFullPath( Opt.ExceptFolder, Empty ) )
	End If


	'//=== 比較するファイルを file_names に列挙する
	Dim  folder, file_name, file_names()
	Dim  f

	If Opt.bSubFolder Then
		ExpandWildcard  WholePath, F_File Or F_SubFolder, folder, file_names
	Else
		ExpandWildcard  WholePath, F_File, folder, file_names
	End If

	Set SameCollection = New ArrayDictionary : ErrCheck


	'//=== ファイルを比較する
	rep_n = 0
	For Each file_name in file_names
		path = g_fs.BuildPath( folder, file_name )

		b = True
		For i = 0  To UBound( except_folders )
			If StrCompHeadOf( path, except_folders(i), Empty ) = 0 Then
				b = False
				Exit For
			End If
		Next
		If b Then

			On Error Resume Next

				PartCmp_compareFile  path, PartPath, StartTag, Opt, SamePartPath

			en = Err.Number : ed = Err.Description : On Error GoTo 0
			If en = 0 Then

				If IsWildcard( WholePath ) Then  echo  "Same: " + path
				If IsWildcard( PartPath ) Then
					echo  "  matched part file: " + g_fs.GetFileName( SamePartPath )
					SameCollection.Add  SamePartPath,path
				End If
				rep_n = rep_n + 1

			ElseIf en = NotMatchErr Then
			ElseIf en = DiffErr Then

				If IsWildcard( WholePath ) Then  echo  "違いあり: " + path _
				Else  echo "diff"
				If IsWildcard( PartPath ) Then
					SameCollection.Add  "*", path
				Else
					'//=== /B オプションによるバッチファイル出力(1)
					If Not IsEmpty(Opt.BatVar) Then
						Set  f = g_fs.CreateTextFile( Opt.BatPath, True, False )
						f.WriteLine "set " + Opt.BatVar + "=" + path
						f = Empty
					End If
					PartCmp_compareFiles = False
					Exit Function
				End If
			Else
				Err.Raise en,,ed
			End If
	 End If
	Next


	'//=== /B オプションによるバッチファイル出力(2)
	If Not IsEmpty(Opt.BatVar) Then
		Set  f = g_fs.CreateTextFile( Opt.BatPath, True, False )
		b = False : If IsWildcard( PartPath ) Then  b = (SameCollection.Dic.Exists("*"))
		If b Then
			f.WriteLine "set " + Opt.BatVar + "=" + SameCollection.Dic.Item("*")(0)
		Else
			f.WriteLine "set " + Opt.BatVar + "="
		End If
		f = Empty
	End If


	'//=== １つも start_tag にヒットしなかったときのメッセージを出す
	If rep_n = 0 Then
		If IsWildcard( WholePath ) Then
			Err.Raise 1,, "<ERROR msg=""開始タグを含むファイルが見つかりませんでした。"" search_folder="""+_
				g_sh.CurrentDirectory +""" file="""+ WholePath +""" start_tag="""+ StartTag +"""/>"  '//No file matched StartTag.
		Else
			Err.Raise en,, ed
		End If
	End If


	'//=== 正常終了したときの表示を行う
	If Not IsWildcard  ( PartPath ) Then
		If IsWildcard( WholePath ) Then  echo "All Same." _
		Else  echo "Same."
		PartCmp_compareFiles = True
	Else
		Dim  i,j,a

		WScript.Echo ""
		WScript.Echo "-----------------------------------------------------"
		For Each j in SameCollection.Dic.Keys()
			If j <> "*" Then
				Set a = SameCollection.Dic.Item(j)
				WScript.Echo ""
				WScript.Echo  "Same as " & g_fs.GetFileName(j) & " are " & a.Count & " files"
				For Each i in  a.Items
					WScript.Echo  i
				Next
			End If
		Next
		If SameCollection.Dic.Exists( "*" ) Then
			Set a = SameCollection.Dic.Item("*")
			WScript.Echo ""
			WScript.Echo  "Others are " & a.Count & " files"
			For Each i in  a.Items
				WScript.Echo  i
			Next
		Else
			WScript.Echo ""
			WScript.Echo  "Others are 0 files"
		End If

		WScript.Echo ""
		WScript.Echo  "Total " & SameCollection.Count & " files"
		PartCmp_compareFiles = False
	End If
End Function


 
'********************************************************************************
'  <<< [PartCmp_compareFile] >>> 
'********************************************************************************
Sub  PartCmp_compareFile( WholePath, PartPath, StartTag, Opt, out_SamePartPath )

	Dim  line, i, j, b, part, whole
	Dim  folder, file_name, file_names()

	'//=== WholePath のファイルの中に StartTag が無ければ、エラーレベル 1 で終了する
	'// １行が256文字を超えるときもエラー
	Set whole = g_fs.OpenTextFile( WholePath,,,-2 )
	i = 0 : b = False
	Do Until whole.AtEndOfStream
		line = whole.ReadLine
		If Len(line) > Opt.MaxByteOfLine Then  Exit Do
		i = i + 1
		If InStr( line, StartTag ) <> 0 Then b = True : Exit Do
		If i >= Opt.LimitStartLines Then Exit Do
	Loop

	If Not b Then
		Err.Raise  NotMatchErr,, "Not found """ & StartTag & """ in the start " & Opt.LimitStartLines & _
								 " lines or " & Opt.MaxByteOfLine & " characters in """ & WholePath & """"
	End If


	'//=== PartPath のワイルドカードを展開し、一致する PartPath を探す
	ExpandWildcard  PartPath, F_File, folder, file_names
	For Each file_name in file_names

		'//=== part と while の一部を比較する
		Set part = g_fs.OpenTextFile( g_fs.BuildPath( folder, file_name ),,,-2 )

		If part.ReadLine = line Then
			b = True
			Do Until part.AtEndOfStream
				If whole.AtEndOfStream Then  b = False : Exit Do
				If part.ReadLine <> whole.ReadLine Then  b = False : Exit Do
			Loop
		Else
			b = False
		End If

		If b Then  out_SamePartPath = g_fs.BuildPath( folder, file_name ) : Exit Sub  ' Same

		'//=== whole を比較する先頭に戻す
		Set whole = g_fs.OpenTextFile( WholePath,,,-2 )
		For j=1 To i-1 : whole.ReadLine : Next
		line = whole.ReadLine
	Next

	Err.Raise  DiffErr,,"diff"
End Sub

 
'*-------------------------------------------------------------------------*
'* ◆<<<< (PartRep_Option) クラス >>>> * 
'*-------------------------------------------------------------------------*

Class  PartRep_Option
	Public  ExceptFolder
	Public  bSubFolder
	Public  bNoConfirm

	Public  LimitStartLines
	Public  MaxByteOfLine
	Public  LimitReplaceLines

	Private Sub Class_Initialize
		LimitStartLines = LimitStartLines_Default
		MaxByteOfLine = MaxByteOfLine_Default
		LimitReplaceLines = LimitReplaceLines_Default
	End Sub
End Class



 
'********************************************************************************
'  <<< [PartRep_main] >>> 
'********************************************************************************
Sub  PartRep_main( Opt )

	Dim  FromPath(), ToPath(), DstPath, bReplace, NPair
	Dim  rep_n, b, i
	Dim  en, ed

	If IsEmpty( Opt ) Then  Set Opt = new PartRep_Option : ErrCheck


	'//=== 引数の取得とチェック
	bReplace = ArgumentExist( "G" )
	Opt.bSubFolder = ArgumentExist( "S" )
	Opt.ExceptFolder = WScript.Arguments.Named.Item("E")
	If Not IsEmpty( Opt.ExceptFolder ) Then  Opt.ExceptFolder = g_fs.GetAbsolutePathName( Opt.ExceptFolder )
	NPair = WScript.Arguments.Named.Item("A")
	If IsEmpty( NPair ) Then  NPair = 1  Else  NPair = CInt( NPair )

	Redim  FromPath(NPair-1)
	Redim  ToPath(NPair-1)
	ErrCheck : On Error Resume Next
		For i=0 To NPair-1
			FromPath(i) = WScript.Arguments.Unnamed(i*2)
			ToPath(i)   = WScript.Arguments.Unnamed(i*2+1)
		Next
		DstPath  = WScript.Arguments.Unnamed(NPair*2)
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	If en <> 0 Then
		If en = 9 Then
			echo "PartRep  [/G][/S][/E:path][/A:n]  from_file  to_file  dst_file"
		Else
			echo "[ERROR] (" & en & ") " & ed
		End If
		Stop : WScript.Quit  2
	End If

	For i=0 To NPair-1
		FromPath(i) = g_fs.GetAbsolutePathName( FromPath(i) )
		ToPath(i)   = g_fs.GetAbsolutePathName( ToPath(i) )
	Next
	' DstPath  = g_fs.GetAbsolutePathName( DstPath )

	Opt.bNoConfirm = True

	PartRep_replaceFiles  NPair, FromPath, ToPath, DstPath, bReplace, Opt

End Sub

 
'********************************************************************************
'  <<< [PartRep_replaceFiles] >>> 
' Opt : Emtpy or PartRep_Option
'********************************************************************************
Sub  PartRep_replaceFiles( NPair, FromPath(), ToPath(), DstPath, bReplace, Opt )
	Dim  rep_n, b, en, ed, i

	echo_line
	If bReplace Then
		echo  ">PartRep_replaceFiles  /G """ + GetFullPath( DstPath, Empty ) + """"
	Else
		echo  ">PartRep_replaceFiles  """ + GetFullPath( DstPath, Empty ) + """"
	End If

	If IsEmpty( Opt ) Then  Set Opt = new PartRep_Option : ErrCheck

	If bReplace and (not Opt.bNoConfirm) Then
		echo_line
		echo "必要なら置き換えようとしているファイルのバックアップを取ってください。"
		b = input( "置き換えを実行しますか？ (Y/N)" )
		If b<>"y" and b<>"Y" Then  Err.Raise 1,,"[PartRep] ユーザによる中止"
	End If


	'//=== Set "except_folders"
	If IsEmpty( Opt.ExceptFolder ) Then
		except_folders = Array( )
	ElseIf IsArray( Opt.ExceptFolder ) Then
		ReDim  except_folders( UBound( Opt.ExceptFolder ) )
		For i = 0  To UBound( Opt.ExceptFolder )
			except_folders(i) = GetFullPath( Opt.ExceptFolder(i), Empty )
		Next
	Else
		except_folders = Array( GetFullPath( Opt.ExceptFolder, Empty ) )
	End If


	'//=== 比較するファイルを file_names に列挙する
	Dim  folder, file_name, file_names()

	If Opt.bSubFolder Then
		ExpandWildcard  DstPath, F_File Or F_SubFolder, folder, file_names
	Else
		ExpandWildcard  DstPath, F_File, folder, file_names
	End If


	'//=== ファイルの一部を置き換える
	rep_n = 0
	For Each file_name in file_names
		path = g_fs.BuildPath( folder, file_name )

		b = True
		For i = 0  To UBound( except_folders )
			If StrCompHeadOf( path, except_folders(i), Empty ) = 0 Then
				b = False
				Exit For
			End If
		Next
		If b Then

			ErrCheck : On Error Resume Next

				PartRep_replaceFile  NPair, FromPath, ToPath, path, bReplace, Opt

			en = Err.Number : ed = Err.Description : On Error GoTo 0
			If en = 0 Then

				echo  path
				rep_n = rep_n + 1

			ElseIf en = NotMatchErr Then
				If not IsWildcard( DstPath ) Then
					echo  ed
					Stop : WScript.Quit 1
				End If
			Else

				echo  path
				echo  "[ERROR] Fail to replace."
				echo "[ERROR] (" & en & ") " & ed
				Stop : WScript.Quit 3
			End If
		End If
	Next

	If bReplace Then
		echo  rep_n & " 個のファイルを置き換えました。"
	Else
		echo_line
		echo  rep_n & " 個のファイルが下記の [From] と一致しました。"
		echo  "/G オプションを付けて PartRep を起動すると、[To] の内容に置き換えます。"
		For i=0 To UBound( FromPath )
			echo  "[From] "+ GetFullPath( FromPath(i), Empty )
			echo  "[To]   "+ GetFullPath( ToPath(i), Empty )
		Next
	End If
End Sub


 
'********************************************************************************
'  <<< [PartRep_replaceFile] >>> 
'********************************************************************************
Sub  PartRep_replaceFile( NPair, FromPath(), ToPath(), DstPath, bReplace, Opt )
	Dim  TmpPath
	Dim  line, line2, i, i2, dst_head_n(), from_n(), b, from, to_, dst, tmp
	Dim  i_pair

	Redim  dst_head_n( NPair - 1 ), from_n( NPair - 1 )
	For i_pair=0 To NPair-1 : dst_head_n(i_pair) = 0 : from_n(i_pair) = 0 : Next


	'//=== DstPath のファイルの中に from_file が無ければ、エラーレベル 1 で終了する
	'// １行が256文字を超えるときもエラー
	i_pair = 0
	Set dst  = g_fs.OpenTextFile( DstPath,,,-2 )
	Set from = g_fs.OpenTextFile( FromPath(i_pair),,,-2 )
	line2 = from.ReadLine : i2 = 0
	i = 0 : b = False
	Do Until dst.AtEndOfStream
		line = dst.ReadLine
		If Len(line) > Opt.MaxByteOfLine Then _
			Exit Do
		i = i + 1
		If line = line2 Then
			If i2 = 0 Then  dst_head_n(i_pair) = i - 1
			i2 = i2 + 1
			If from.AtEndOfStream Then
				If i2 > Opt.LimitReplaceLines Then _
					Exit Do
				from_n(i_pair) = i2
				If i_pair = NPair-1 Then _
					b = True : Exit Do

				i_pair = i_pair + 1
				Set from = g_fs.OpenTextFile( FromPath(i_pair),,,-2 )
				i = 0 : i2 = 0
			End If
			line2 = from.ReadLine
		Else
			If i2 > 0 Then
				Set from = g_fs.OpenTextFile( FromPath(i_pair),,,-2 )
				line2 = from.ReadLine : i2 = 0
				If line = line2 Then  i2 = 1 : dst_head_n(i_pair) = i - 1 : line2 = from.ReadLine
			End If
		End If
		If i >= Opt.LimitStartLines And i2=0 Then _
			Exit Do
	Loop

	If Not b Then
		Err.Raise  NotMatchErr,,"Not found """ & FromPath(i_pair) & """ in the start " & Opt.LimitStartLines & _
								 " lines or " & Opt.MaxByteOfLine & " characters in """ & DstPath & """"
	End If


	'//=== 置き換えた後が大きすぎないかチェックする
	For i_pair=0 To NPair-1
		Set to_ = g_fs.OpenTextFile( ToPath(i_pair),,,-2 )
		i = 0 : b = True
		Do Until to_.AtEndOfStream
			line = to_.ReadLine
			If Len(line) > Opt.MaxByteOfLine Then  b = False : Exit Do
			i = i + 1
			If i >= Opt.LimitStartLines Then  b = False : Exit Do
		Loop
		If Not b Then
			Err.Raise  NotMatchErr,,"Too big """ & ToPath(i_pair) & """"
		End If
	Next


	If bReplace Then

		Set ec = new EchoOff
		TmpPath = GetTempPath( "PartRepWork.txt" )
		Set rep = StartReplace( DstPath, TmpPath, False )
		For i_pair=0 To NPair-1
			Set ls = new_TextFileLineSeparatorStack( g_VBS_Lib.KeepLineSeparators )
			Set to_  = OpenForRead( ToPath(i_pair) )
			ls = Empty


			'//=== rep.w ファイルに rep.r ファイルの StartTag を含む行より前をコピーする
			Do Until rep.r.AtEndOfStream
				If dst_head_n(i_pair) = 0 Then  Exit Do
				dst_head_n(i_pair) = dst_head_n(i_pair) - 1
				rep.w.WriteLine  rep.r.ReadLine
			Loop


			'//=== rep.w ファイルに to_ ファイル全体を、追加コピーする
			Do Until to_.AtEndOfStream
				rep.w.WriteLine  to_.ReadLine
			Loop
			For i = 1 To from_n(i_pair)
				rep.r.SkipLine
			Next
		Next


		'//=== tmp ファイルに rep.r ファイルの EndTag を含む行より後を、追加コピーする
		Do Until rep.r.AtEndOfStream
			rep.w.WriteLine  rep.r.ReadLine
		Loop


		'//=== ファイルを閉じる
		rep.Finish : to_ = Empty
		ec = Empty
	End If
End Sub
 
