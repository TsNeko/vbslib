'***********************************************************************
'* File: vbslib Prompt.vbs
'*    vbslib を使ったコマンド集。
'*
'* vbslib is provided under 3-clause BSD license.
'* Copyright (C) Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.
'*
'* - $Version: vbslib 5.93 $
'* - $ModuleRevision: {vbslib}\Public\593 $
'* - $Date: 2017-03-20T20:00:00+09:00 $
'***********************************************************************

Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		o.Lead = "vbslib Prompt - vbslib version 5.93"

		Set o.MenuCaption = Dict(Array(_
			"1","ヘルプ(SVG形式)の表示 (Google Chrome や Snap Note で見えます)",_
			"2","ヘルプ(Internet Explorer - VML形式)の表示",_
			"3","■ vbs ファイルを新規作成する [%name%]",_
			"4","エディターなど外部プログラム設定 [%name%]", _
			"5","タブ文字と空白文字を変更する [%name%]", _
			"6","Test テンプレート・フォルダーを開く [test]", _
			"7","最新の vbslib に変換する [ConvertToNewVbsLib]", _
			"8","このプロンプトのソースを開く", _
			"9","vbslib フォルダーを開く",_
			"10","vbslib の関数が使えるプロンプトに切り替える [Prompt]" ))

		Set o.CommandReplace = Dict(Array(_
			"1","OpenShorHandLibHelpSVG",_
			"2","OpenShorHandLibHelpHtml",_
			"3","MakeNewScript",_
			"4","Setting",_
			"5","SpaceToTab",_
			"6","OpenTestTemplate",_
			"7","ConvertToNewVbsLib_sth",_
			"8","OpenShorHandPromptSrc",_
			"9","OpenVbsLib",_
			"10","Prompt",_
			_
			"Base64",        "Base64_sth",_
			"CheckEnglishOnly",      "CheckEnglishOnly_sth",_
			"ConvertDocumetCommentFormat", "ConvertDocumetCommentFormat_sth",_
			"ConvertToNewVbsLib",    "ConvertToNewVbsLib_sth",_
			"CopyDiffByMD5List",     "CopyDiffByMD5List_sth",_
			"CopyOnlyExist",         "CopyOnlyExist_sth",_
			"CreateFromTextSections", "CreateFromTextSections_sth",_
			"CutLineFeedAtRightEnd", "CutLineFeedAtRightEnd_sth",_
			"lf",                    "CutLineFeedAtRightEnd_sth",_
			"CutComment",    "CutComment_sth",_
			"CutSharpIf",    "CutSharpIf_sth",_
			"Diff",          "Diff_sth",_
			"DiffKS",        "DiffWithoutKS_sth",_
			"DiffWithoutKS", "DiffWithoutKS_sth",_
			"DoTextShrink",  "DoTextShrink_sth",_
			"DownloadByHttp","DownloadByHttp_sth",_
			"dox",           "doxygen_sth",_
			"doxygen",       "doxygen_sth",_
			"EvaluateByVariableXML", "EvaluateByVariableXML_sth",_
			"fc",            "fc_sth",_
			"fdiv",          "fdiv_sth",_
			"feq",           "feq_sth",_
			"find",          "FindFile_sth",_
			"FindFile",      "FindFile_sth",_
			"gh",            "GetHash_sth",_
			"GetHash",       "GetHash_sth",_
			"GetHashPS",     "GetHashPS_sth",_
			"GetStepPath",   "GetStepPath_sth",_
			"GetShortPath",  "GetShortPath_sth",_
			"grep",          "grep_sth",_
			"grep_u",        "grep_u_sth",_
			"mkdir",         "mkdir_sth",_
			"list",          "MakeFileList_sth",_
			"MakeFileList",  "MakeFileList_sth",_
			"md",            "MD5List",_
			"md5",           "MD5List",_
			"moas",          "ModuleAssort",_
			"ModuleAssort2", "ModuleAssort2_sth",_
			"nd",            "NaturalDocs_sth",_
			"NaturalDocs",   "NaturalDocs_sth",_
			"OpenSendTo",    "OpenSendTo_sth",_
			"OpenStartUp",   "OpenStartUp_sth",_
			"ov",            "OpenVBSLibSource",_
			"PickUpCopy",    "PickUpCopy_sth",_
			"Prompt",        "Prompt_sth",_
			"py",            "Python_sth",_
			"Python",        "Python_sth",_
			"ReadOnlyList",  "ReadOnlyList_sth", _
			"ren",           "Rename_sth",_
			"Rename",        "Rename_sth",_
			"RenIni",              "RenumberIniFileDataInClipboard_sth",_
			"RenumberIniFileData", "RenumberIniFileDataInClipboard_sth",_
			"ReplaceShortcutFilesToFiles", "ReplaceShortcutFilesToFiles_sth",_
			"SendTo",        "OpenSendTo_sth",_
			"shutdown",      "shutdown_sth",_
			"sh",            "shutdown_sth",_
			"SortLines",     "SortLines_sth",_
			"SpaceToTab",    "SpaceToTab_sth",_
			"synct",         "SyncFilesT_sth",_
			"SyncFilesT",    "SyncFilesT_sth",_
			"SyncFilesX",    "SyncFilesX_sth",_
			"sl",            "ReplaceSlash",_
			"ss",            "StopScreenSaver",_
			"st",            "SpaceToTabShort_sth",_
			"sw",            "Switches_sth",_
			"Switches",      "Switches_sth",_
			"Setting",       "Start_VBS_Lib_Settings_sth",_
			"test",          "OpenTestTemplate",_
			"TabToSpace",    "SpaceToTab_sth",_
			"ThreeWayMerge", "ThreeWayMerge_sth",_
			"Translate",     "Translate_sth",_
			"TranslateTest", "TranslateTest_sth",_
			"TwoWayMerge",   "TwoWayMerge_sth",_
			"ts",            "TabToSpaceShort_sth",_
			"unzip",         "unzip_sth",_
			"UpdateModule",  "UpdateModule_sth",_
			"XmlText",       "XmlText_sth",_
			"MakeSyncModuleX",   "MakeSyncModuleX_sth",_
			"MakeDiffProjectForSyncModuleX", "MakeDiffProjectForSyncModuleX_sth" ))

	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'***********************************************************************
'* Function: Base64_sth
'***********************************************************************
Sub  Base64_sth( Opt, AppKey )
	Set c = g_VBS_Lib

	echo  "1) Base64形式に変換する [Encode]"
	echo  "2) バイナリー・ファイルに戻す [Decode]"
	key = LCase( Trim( Input( "番号またはコマンド名>" ) ) )
	Select Case  key
		Case "1": key = "encode"
		Case "2": key = "decode"
	End Select

	Select Case  key
		Case "encode"
			in_path  = InputPath( "入力ファイル（バイナリ形式）のパス>", c.CheckFileExists )
			out_path = InputPath( "出力ファイルのパス（上書きします）>", Empty )

			Set w_=AppKey.NewWritable( out_path ).Enable()
			CreateFile  out_path,  new_BinaryArrayFromFile( in_path ).Base64

		Case "decode"
			in_path  = InputPath( "入力ファイル（テキスト形式）のパス>", c.CheckFileExists )
			out_path = InputPath( "出力ファイルのパス（上書きします）>", Empty )

			Set w_=AppKey.NewWritable( out_path ).Enable()
			new_BinaryArrayFromBase64( ReadFile( in_path ) ).Save  out_path

		Case Else
			Error
	End Select
	echo  "出力しました。"
End Sub


 
'***********************************************************************
'* Function: BashSyntax
'***********************************************************************
Sub  BashSyntax( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  "bash シェル・スクリプト・ファイルの "" "", ' ', ` ` の対応関係が"+_
	      "複数行にまたがっている場所を探します。"
	path = InputPath( "シェル・スクリプト・ファイルのパス >", c.CheckFileExists )

	count = 0

	Set cs = new_TextFileCharSetStack( "UTF-8" )
	Set file = OpenForRead( path )
	Do Until  file.AtEndOfStream
		line = file.ReadLine()
		result = BashSyntaxSub( file, line, """") : If not result Then  count = count + 1
		result = BashSyntaxSub( file, line, "'" ) : If not result Then  count = count + 1
		result = BashSyntaxSub( file, line, "`" ) : If not result Then  count = count + 1
	Loop
	file = Empty

	If count = 0 Then  echo  "複数行にまたがっている箇所はありません。"
End Sub

Function  BashSyntaxSub( File, Line, Quot )
	pos = 1 : count = 0
	Do
		pos = InStr( pos, line, Quot )
		If pos = 0 Then  Exit Do
		count = count + 1
		pos = pos + 1
	Loop

	BashSyntaxSub = ( count mod 2 = 0 )

	If not BashSyntaxSub Then
		echo  "<WARNING msg=""複数行にまたがっています"" line=""" & File.Line - 1 & """>"+ Quot +"</WARNING>"
	End If
End Function


 
'***********************************************************************
'* Function: CheckEnglishOnly_sth
'***********************************************************************
Sub  CheckEnglishOnly_sth( Opt, AppKey )
	exe = g_vbslib_ver_folder +"CheckEnglishOnly\CheckEnglishOnly.exe"
	default_set_path = GetFullPath( "..\Samples\Translate\SettingForCheckEnglish.ini", _
		g_vbslib_folder )

	Set c = g_VBS_Lib
	echo  "テキスト・ファイルの中に、英文字以外の文字が含まれるファイルを一覧します。"
	echo  "サブフォルダーも含めてチェックします。"
	echo  ""
	search_path = InputPath( "調べるフォルダーのパス>", c.CheckFolderExists )

	echo  ""
	echo  "Enter のみ："""+ default_set_path +""""
	set_path = InputPath( "除外ファイルなどの設定ファイル>", c.CheckFileExists or c.AllowEnterOnly )
	If set_path = "" Then  set_path = default_set_path
	echo_line

	Set ec = new EchoOff
	cd  g_start_in_path
	ec = Empty

	If set_path = "" Then
		r= RunProg( """"+ exe +""" /Folder:"""+ search_path +"""", _
			c.NotEchoStartCommand )
	Else
		r= RunProg( """"+ exe +""" /Folder:"""+ search_path +""" /Setting:"""+ set_path +"""", _
			c.NotEchoStartCommand )
	End If
End Sub


 
'***********************************************************************
'* Function: ConvertDocumetCommentFormat_sth
'***********************************************************************
Sub  ConvertDocumetCommentFormat_sth( Opt, AppKey )

	default_template = "${vbslib}\Samples\DocComment\doxygen.xml"

	Set c = g_VBS_Lib
	echo  "プログラムのソースファイルの中にある、ドキュメントに変換できるコメントの"+_
		"形式を変換します。"
	input_path = InputPath( "変換する前のソース、または、ソースが入ったフォルダー >", _
		c.CheckFileExists or c.CheckFolderExists )
	output_path = InputPath( "変換後のソース、または、ソースを入れるフォルダー（★上書きします）>", _
		Empty )
	echo  ""
	echo  "Enter のみ: NaturalDocs"
	echo  "1. C言語の NaturalDocs [NaturalDocs]"
	input_format = Input( "変換前のコメント形式 >" )
	If input_format ="1"  or  input_format ="" Then  input_format ="NaturalDocs"
	echo  ""
	echo  "Enter のみ: "+ default_template
	template_path = InputPath( "出力するコメントのテンプレートが書かれたファイルのパス >", _
		c.CheckFileExists or c.AllowEnterOnly )
	If template_path = "" Then  template_path = default_template
	template_path = GetPathLazyDictionary()( template_path )

	Set w_=AppKey.NewWritable( output_path ).Enable()
	ConvertDocumetCommentFormat  input_path, output_path, input_format, template_path
End Sub


 
'***********************************************************************
'* Function: ConvertToNewVbsLib_sth
'***********************************************************************
Sub  ConvertToNewVbsLib_sth( Opt, AppKey )
	Set c = g_VBS_Lib
	echo "スクリプトが使っている古い vbslib を最新の vbslib に置き換えます。"
	echo "  Old version → ver.6"
	echo "事前に変換を行うフォルダーの ★バックアップ をとっておいてください。"
	path = InputPath( "変換を行うフォルダーのパス >", c.CheckFolderExists )
	echo_line

	Set w_=AppKey.NewWritable( path ).Enable()
	ConvertToNewVbsLib  path
End Sub


 
'***********************************************************************
'* Function: CopyOnlyExist_sth
'***********************************************************************
Sub  CopyOnlyExist_sth( Opt, AppKey )
	echo  "コピー先に存在するファイルだけコピーします"
	echo  "コピー先に存在するファイルがコピー元に無いときはエラーになります。"
	Dim  from_path : from_path = InputPath( "コピー元フォルダのパス>", F_Folder )
	Dim  to_path   : to_path   = InputPath( "コピー先フォルダのパス>", F_Folder )

	Dim w_:Set w_=AppKey.NewWritable( to_path ).Enable()

	Dim  folder, fnames(), fname

	ExpandWildcard  to_path +"\*", F_File or F_SubFolder, folder, fnames
	CallForEach2  GetRef("CallForEach_copy"), fnames, from_path, to_path
End Sub


 
'***********************************************************************
'* Function: CreateTask
'***********************************************************************
Sub  CreateTask( Opt, AppKey )
	echo  "指定時間に１回だけ実行するタスクを新規に登録します。"
	Dim  name : name = input( "タスク名（任意）>" )
	Dim  cmd  : cmd  = input( "実行するコマンド>" )
	echo  "例： 13:00 ... 今が午前10時なら、今日の午後1時に実行する"
	echo  "例：  1:00 ... 今が午前10時なら、明日の午前1時に実行する"
	echo  "例： +1:00 ... 今から1時間後に実行する"
	Dim  after : after = input( "いつ実行を開始しますか>" )

	Dim  t
	If Left( after, 1 ) = "+" Then
		t = DateAddStr( Now(), after )
	Else
		t = CDate( after )
		If IsTimeOnlyDate( t ) Then  t = DateAddStr( Date(), "+"+ after )
	End If

	start  "schtasks /Create /Sc once /SD "+ FormatDateTime( t, vbShortDate ) + _
		 " /ST "+ FormatDateTime( t, vbShortTime ) +":00 /TN "+ name +" /TR "+ cmd
End Sub


 
'***********************************************************************
'* Function: CutComment_sth
'***********************************************************************
Sub  CutComment_sth( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  "C言語のコメント（/* */ と // ）を削除します。"
	echo  ""
	echo  "以下にフォルダーのパスを入力すると、*.c, *.h, *.cpp に対して処理します。"
	path = InputPath( "ファイルまたはフォルダーのパス（★上書きします）>", c.CheckFileExists or c.CheckFolderExists )

	Set w_=AppKey.NewWritable( path ).Enable()

	If g_fs.FolderExists( path ) Then
		path = Array( GetFullPath( "*.c", path ), GetFullPath( "*.h", path ), _
			GetFullPath( "*.cpp", path ) )
	End If

	CutCommentC  path, Empty
End Sub


 
'***********************************************************************
'* Function: CutLineFeedAtRightEnd_sth
'***********************************************************************
Sub  CutLineFeedAtRightEnd_sth( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  "コマンドプロンプトの右端からあふれた文字列を１行にまとめます。"

	path = InputPath( "ファイルのパス>", c.CheckFileExists )
	Set w_=AppKey.NewWritable( path ).Enable()

	echo  ""
	echo  "Enter のみ：80"
	width = Input( "１行の幅>" )
	If width = "" Then  width = "80"
	width = CInt( width )

	temporary = GetTempPath( "CutLineFeedAtRightEnd_*.txt" )
	echo  "変更前のバックアップ： "+ temporary

	Set ec = new EchoOff
	copy_ren  path, temporary

	Set cs = new_TextFileCharSetStack( ReadUnicodeFileBOM( path ) )
	CreateFile  path, CutLineFeedAtRightEnd( ReadFile( path ), width )
	cs = Empty

	ec = Empty
	echo  "ファイルを変更しました。"
End Sub


 
'***********************************************************************
'* Function: CutSharpIf_sth
'***********************************************************************
Sub  CutSharpIf_sth( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  "#ifdef ～ #endif をカットします。"
	path = InputPath( "変換するソースファイル、または、フォルダーのパス（★上書きします）>", _
		c.CheckFileExists  or   c.CheckFolderExists )
	symbol = Input( "#define シンボル >" )
	echo  ""
	echo  "1) 定義されているときのコードを削除する"
	echo  "0) 定義されていないときのコードを削除する"
	is_cut_true = Input( "番号を入力してください >" )
	Assert  is_cut_true = "1"  or  is_cut_true = "0"
	is_cut_true = ( is_cut_true = "1" )

	Set w_=AppKey.NewWritable( g_fs.GetParentFolderName( path ) ).Enable()
	CutSharpIf  path, Empty, symbol, is_cut_true
	echo  "変換しました。"
End Sub


 
'***********************************************************************
'* Function: DelTemp
'***********************************************************************
Sub  DelTemp( Opt, AppKey )
	path = GetTempPath( "." )
	echo "下記のフォルダを削除します。"
	echo  path
	Pause
	Set w_=AppKey.NewWritable( path ).Enable()
	del  path
End Sub


 
'***********************************************************************
'* Function: Diff_sth
'***********************************************************************
Sub  Diff_sth( Opt, AppKey )
	Set c = g_VBS_Lib
	echo "[Diff] テキストファイルの比較"
	echo "フォルダーのパスを指定すると、ファイルへの相対パスのベースフォルダーとして処理します。"

	path1 = InputPath( "path1>", c.CheckFileExists  or  c.CheckFolderExists )
	path2 = InputPath( "path2>", c.CheckFileExists  or  c.CheckFolderExists )

	echo  ""
	echo  "Enter のみ ： 2つのファイルの比較"
	path3 = InputPath( "path3>", c.CheckFileExists  or  c.CheckFolderExists  or  c.AllowEnterOnly )
	echo  ""


	If g_fs.FolderExists( path1 ) Then
		Assert  g_fs.FolderExists( path2 )
		If path3 <> "" Then
			Assert  g_fs.FolderExists( path3 )
		End If

		echo  "入力したベースフォルダーの中のファイルを指定してください。"

		Do
			echo  ""
			echo  "Enter のみ：終了"
			full_path = InputPath( "path>", c.CheckFileExists  or  c.AllowEnterOnly )
			If full_path = "" Then  Exit Do

			step_path = Empty
			If StrCompHeadOf( full_path, path1, Empty ) = 0 Then
				step_path = GetStepPath( full_path, path1 )
			ElseIf StrCompHeadOf( full_path, path2, Empty ) = 0 Then
				step_path = GetStepPath( full_path, path2 )
			ElseIf path3 <> "" Then
				If StrCompHeadOf( full_path, path3, Empty ) = 0 Then
					step_path = GetStepPath( full_path, path3 )
				End If
			End If

			If not IsEmpty( step_path ) Then
				full_path_1 = GetFullPath( step_path, path1 )
				full_path_2 = GetFullPath( step_path, path2 )
				If path3 = "" Then
					full_path_3 = ""
				Else
					full_path_3 = GetFullPath( step_path, path3 )
				End If

				Diff_Sub  full_path_1, full_path_2, full_path_3
			Else
				echo_v  "ベースフォルダーの中のファイルを指定してください。"
			End If
		Loop
	Else
		Diff_Sub  path1, path2, path3
	End If
End Sub


Sub  Diff_Sub( path1, path2, path3 )
	If LCase( g_fs.GetExtensionName( path1 ) ) = "svg" Then
		path_of_SnapNote = Setting_getSnapNotePath()

		path1_svg = path1
		path1 = GetTempPath( "SnapNoteDiff_*.txt" )
		RunProg  """"+ path_of_SnapNote +""" -cd """+ path1_svg +""" """+ path1 +"""", ""

		Assert  LCase( g_fs.GetExtensionName( path2 ) ) = "svg"

		path2_svg = path2
		path2 = GetTempPath( "SnapNoteDiff_*.txt" )
		RunProg  """"+ path_of_SnapNote +""" -cd """+ path2_svg +""" """+ path2 +"""", ""

		If path3 <> "" Then
			Assert  LCase( g_fs.GetExtensionName( path3 ) ) = "svg"

			path3_svg = path3
			path3 = GetTempPath( "SnapNoteDiff_*.txt" )
			RunProg  """"+ path_of_SnapNote +""" -cd """+ path3_svg +""" """+ path3 +"""", ""
		End If
	End If


	If path3 = "" Then
		start  GetDiffCmdLine( path1, path2 )
	Else
		start  GetDiffCmdLine3( path1, path2, path3 )
	End If
End Sub


 
'***********************************************************************
'* Function: DiffWithoutKS_sth
'***********************************************************************
Sub  DiffWithoutKS_sth( Opt, AppKey )
	Set c = g_VBS_Lib
	If ArgumentExist( "ArgsLog" ) Then
		include  SearchParent( "_src\Test\tools\scriptlib\vbslib\ArgsLog\SettingForTest_pre.vbs" )
		include  SearchParent( "_src\Test\tools\scriptlib\vbslib\ArgsLog\SettingForTest.vbs" )
		SetVar  "Setting_getFolderDiffCmdLine", "ArgsLog"
	End If
	echo "[DiffWithoutKS] テキストファイルの比較、Keyword Substitution の値を削除してから。"

	path1 = InputPath( "path1>", c.CheckFileExists  or  c.CheckFolderExists )
	path2 = InputPath( "path2>", c.CheckFileExists  or  c.CheckFolderExists )

	echo  ""
	echo  "Enter のみ ： 2つのファイルの比較"
	path3 = InputPath( "path3>", c.CheckFileExists  or  c.CheckFolderExists  or  c.AllowEnterOnly )
	If path3 = "" Then _
		path3 = Empty
	echo  ""
	Set w_= AppKey.NewWritable( g_sh.SpecialFolders( "Desktop" ) +"\_DiffWithoutKS" ).Enable()

	DiffWithoutKS  path1,  path2,  path3,  Empty
End Sub


 
'***********************************************************************
'* Function: DiffClip
'***********************************************************************
Sub  DiffClip( Opt, AppKey )
	echo  "[DiffClip] テキストの比較"

	echo  "次に表示されるファイルに、比較するテキストの１つ目を保存してください。"
	pause
	path1 = GetTempPath( "DiffClip_1_*.txt" )
	CreateFile  path1,  "（ここに比較するテキストの１つ目を貼り付けて保存してください。）"
	start  GetEditorCmdLine( path1 )


	echo  ""
	echo  "次に表示されるファイルに、比較するテキストの２つ目を保存してください。"
	pause
	path2 = GetTempPath( "DiffClip_2_*.txt" )
	CreateFile  path2,  "（ここに比較するテキストの２つ目を貼り付けて保存してください。）"
	start  GetEditorCmdLine( path2 )

	echo  ""
	key = input( "２つのファイルの比較ですか[Y/N]" )
	If key="y" or key="Y" Then
		path3 = ""
	Else
		echo  ""
		echo  "次に表示されるファイルに、比較するテキストの３つ目を保存してください。"
		pause
		path3 = GetTempPath( "DiffClip_3_*.txt" )
		CreateFile  path3,  "（ここに比較するテキストの３つ目を貼り付けて保存してください。）"
		start  GetEditorCmdLine( path3 )
	End If

	echo  "比較ツールを起動しています。"
	If path3 = "" Then
		start  GetDiffCmdLine( path1, path2 )
	Else
		start  GetDiffCmdLine3( path1, path2, path3 )
	End If

	key = input( "一時的に保存したファイルを削除しますか[Y/N]" )
	If key="y" or key="Y" Then
		del  path1 : del path2 : del path3
	End If
End Sub


 
'***********************************************************************
'* Function: Diff1
'***********************************************************************
Sub  Diff1( Opt, AppKey )
	ReDim  paths(1)
	ReDim  line_nums(1)
	ReDim  texts(1)  '// in clipboard
	ReDim  parameters(1)
	Set c = g_VBS_Lib

	echo  "テキスト ファイルの 1行を 1文字ずつ比較します。"
	echo  ""

	Do
		echo  "Enter のみ: クリップボードにある2行のテキストを比較する"
		echo  "\ のみ: 終了"

		For i=0 To 1
			path = InputPath( "ファイル "+ CStr( i + 1 ) +" > ", _
				c.CheckFileExists  or  c.CheckFolderExists  or  c.AllowEnterOnly )
			If path = "" Then
				Set file = new StringStream

				file.SetString  GetTextFromClipboard()
				If not file.AtEndOfStream() Then _
					texts_0 = file.ReadLine()
				If not file.AtEndOfStream() Then
					texts(0) = texts_0
					texts(1) = file.ReadLine()
					Exit For
				Else
					If IsEmpty( texts(0) ) Then
						texts(0) = texts_0
					Else
						texts(1) = texts_0
						Exit For
					End If
				End If
				file = Empty
			ElseIf path = "\"  or  path = Left( g_start_in_path,  3 ) Then
				Exit Sub
			Else
				paths(i) = path
				texts(i) = Empty

				line_nums(i) = CInt2( Input( "行番号   "+ CStr( i + 1 ) +" > " ) )
			End If
		Next


		For  i = 0  To  1
			If IsEmpty( texts(i) ) Then
				parameters(i) = paths(i) +"("+ CStr( line_nums(i) ) +")"
			Else
				parameters(i) = Array( texts(i) )
			End If
		Next


		Set diff_ = GetDiffOneLineCmdLine( parameters(0), parameters(1) )
		Sleep  100
		RunProg  diff_, ""


		If g_InputCommand_Args.Count >= 1 Then _
			If not IsArray( parameters(0) )  and  not IsArray( parameters(1) ) Then _
				Exit Do


		texts(0) = Replace( ReadFile( diff_.PathA ), vbCRLF, "" )

		echo  ""
	Loop
End Sub


 
'***********************************************************************
'* Function: DiffTag
'***********************************************************************
Sub  DiffTag( Opt, AppKey )
	If ArgumentExist( "ArgsLog" ) Then
		include  SearchParent( "_src\Test\tools\scriptlib\vbslib\ArgsLog\SettingForTest_pre.vbs" )
		include  SearchParent( "_src\Test\tools\scriptlib\vbslib\ArgsLog\SettingForTest.vbs" )
		SetVar  "Setting_getDiffCmdLine", "DiffCUI"
	End If

	echo  "diff ツールなどがコンフリクトして出力したタグ付きテキストから、GUI の diff ツールを開きます。"
	echo  ""
	echo  "タグ付きテキストの例："
	echo  "<<<<<<< Left.txt"
	echo  "Left"
	echo  "||||||| Base.txt"
	echo  "Base"
	echo  "======="
	echo  "Right"
	echo  ">>>>>>> Right.txt"
	echo  ""
	echo  "終了するときは、Exit と入力してください。"
	Do
		key = Input( "クリップボードにタグ付きテキストをコピーしたら、Enter を押してください。" )
		If StrComp( key, "exit", 1 ) = 0 Then _
			Exit Do


		'// Parse "text".
		text = GetTextFromClipboard()
		s1 = InStr( text, "<<<<<<< " )
		s1 = InStr( s1, text, vbLF ) + 1
		e1a = InStr( s1 - 1,  text,  vbLF +"||||||| " )
		e1b = InStr( s1 - 1,  text,  vbLF +"=======" )
		If e1a >= 1  and  e1a < e1b Then  '// 3way diff
			e1 = e1a + 1
			s2 = InStr( e1a + 1, text, vbLF ) + 1
			e2 = e1b + 1
			s3 = InStr( e1b + 1, text, vbLF ) + 1
			e3 = InStr( s3 - 1, text, vbLF +">>>>>>> " ) + 1
		Else  '// 2way diff
			e1 = e1b + 1
			s2 = InStr( e1b + 1, text, vbLF ) + 1
			e2 = InStr( s2 - 1, text, vbLF +">>>>>>> " ) + 1
			s3 = Empty
			'// e3 = Empty
		End If


		'// Create temporary files.
		Set ec = new EchoOff
		folder_path = GetTempPath( "DiffTag\*" )
		mkdir  folder_path

		path_1 = folder_path +"\Left.txt"
		comparing_text = Mid( text,  s1,  e1 - s1 )
		CreateFile  path_1,  comparing_text

		If not IsEmpty( s3 ) Then  '// 3way diff
			path_2 = folder_path +"\Base.txt"
			comparing_text = Mid( text,  s2,  e2 - s2 )
			CreateFile  path_2,  comparing_text

			path_3 = folder_path +"\Right.txt"
			comparing_text = Mid( text,  s3,  e3 - s3 )
			CreateFile  path_3,  comparing_text
		Else  '// 2way diff
			path_2 = folder_path +"\Right.txt"
			comparing_text = Mid( text,  s2,  e2 - s2 )
			CreateFile  path_2,  comparing_text
		End If
		ec = Empty


		'// Run diff tool.
		echo_line
		If not IsEmpty( s3 ) Then  '// 3way diff
			start  GetDiffCmdLine3( path_1,  path_2,  path_3 )
		Else  '// 2way diff
			start  GetDiffCmdLine( path_1,  path_2 )
		End If
		echo_line

	Loop
End Sub


 
'***********************************************************************
'* Function: DoTextShrink_sth
'***********************************************************************
Sub  DoTextShrink_sth( Opt, AppKey )
	Set c = g_VBS_Lib

	echo  "セクション（NaturalDocs で区切ったソース ファイル）のうち、使用していないセクションを削除します。"
	txmx_path = InputPath( ".txmx ファイルのパス >", c.CheckFileExists )

	Set w_=AppKey.NewWritable( GetTextShrinkWritables( txmx_path, Empty ) ).Enable()
	DoTextShrink  txmx_path, Empty
End Sub


 
'***********************************************************************
'* Function: DownloadByHttp_sth
'***********************************************************************
Sub  DownloadByHttp_sth( Opt, AppKey )
	Set c = g_VBS_Lib

	echo  "ファイルをダウンロードします。"
	a_URL = Input( "ダウンロードするファイルの URL >" )

	default_new_path = g_sh.SpecialFolders( "Desktop" ) +"\"+ g_fs.GetFileName( a_URL )
	If exist( default_new_path ) Then
		max_num = 9999
		For i = 2 To max_num
			a_path = AddLastOfFileName( default_new_path, " ("& i &")" )
			If not exist( a_path ) Then
				default_new_path = a_path
				Exit For
			End If
		Next
		If i > max_num Then  Error
	End If

	echo  ""
	echo  "[Enter]のみ： """+ default_new_path +""""
	new_path = InputPath( "ダウロードしてできるファイルのパス（★上書きします）>", _
		c.AllowEnterOnly )
	If new_path = "" Then  new_path = default_new_path

	Set w_=AppKey.NewWritable( new_path ).Enable()

	DownloadByHttp  a_URL, new_path
End Sub


 
'***********************************************************************
'* Function: doxygen_sth
'***********************************************************************
Sub  doxygen_sth( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  "ソースファイルにある doxygen 形式コメントを HTML に変換します。"
	source_path = InputPath( "ソースファイルがあるフォルダーのパス>", c.CheckFolderExists )
	destination_path = InputPath( "HTML を格納するフォルダーのパス（★上書きします）>", 0 )

	Set w_=AppKey.NewWritable( destination_path ).Enable()
	MakeDocumentBy_doxygen  source_path, destination_path, Empty
	If not ArgumentExist( "silent" ) Then
		start  """"+ GetPathWithSeparator( destination_path ) +"index.html"""
	End If
End Sub


 
'***********************************************************************
'* Function: EvaluateByVariableXML_sth
'***********************************************************************
Sub  EvaluateByVariableXML_sth( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  "${ } 形式の変数が定義された XML を参考に、テキスト ファイルの中の変数を値に置き換えます。"
	echo  ""
	variable_path = InputPath( "変数が定義された XML ファイルのパス>", c.CheckFileExists )
	base_path = g_fs.GetParentFolderName( variable_path )
	echo  ""


	'// Replacing file mode
	Do
		echo  "Enter のみ：クリップボードを展開する。"
		replacing_path = InputPath( "置き換えるテキスト ファイルのパス>", c.CheckFileExists  or  c.AllowEnterOnly )
		If replacing_path = "" Then _
			Exit Do

		w_= Empty : Set w_=AppKey.NewWritable( replacing_path ).Enable()

		Set root = LoadXML( variable_path, Empty )
		pushd  base_path
		Set variables = LoadVariableInXML( root,  variable_path )
		popd
		Set file = OpenForReplace( replacing_path, Empty )
		file.Text = variables( file.Text )
		file = Empty
		echo  "置き換えました。"
		echo  ""
	Loop


	'// Replacing clipboard mode
	Set root = LoadXML( variable_path, Empty )
	Set variables = LoadVariableInXML( root,  variable_path )
	Do
		If TryStart(e) Then  On Error Resume Next

			text = GetTextFromClipboard()

		If TryEnd Then  On Error GoTo 0
		If e.num <> 0 Then
			echo_v  "Error 0x"+ Hex( e.num ) +": "+ e.Description
			e.Clear
		Else
			variables.DebugMode = True

			text = variables( text )
			variables.DebugMode = False

			echo  text

			SetTextToClipboard  text
		End If

		echo  ""
		echo  "Enter のみ：クリップボードを展開する。"
		echo  "それ以外：終了する。"
		key = Input( ">" )
		If key <> "" Then _
			Exit Do
	Loop
End Sub


 
'***********************************************************************
'* Function: fc_sth
'***********************************************************************
Sub  fc_sth( Opt, AppKey )
	Set c = g_VBS_Lib
	Do
		echo "[fc] Compare text file"

		path1 = InputPath( "path1>", c.CheckFileExists or c.CheckFolderExists or c.AllowEnterOnly )
		If path1 = "" Then  Exit Do

		echo  ""
		echo  "入力例： Shift_JIS, EUC-JP, Unicode, UTF-8, UTF-8-No-BOM, ISO-8859-1"
		echo  "Enter のみ ： 自動判定"
		cs1 = input( "文字コードセット >" )
		If cs1 = "" Then  cs1 = Empty

		echo  ""
		path2 = InputPath( "path2>", c.CheckFileExists or c.CheckFolderExists )
		echo  ""
		cs2 = input( "文字コードセット >" )
		If cs2 = "" Then  cs2 = Empty
		echo  ""

		Set ec = new EchoOff
		If IsSameTextFile_Old( path1, cs1, path2, cs2, Empty ) Then
			If IsSameBinaryFile( path1, path2, Empty ) Then
				ec = Empty

				echo  "same text, same binary."
			Else
				ec = Empty

				echo  "same text, different binary."
			End IF
		Else
			ec = Empty

			echo  "different."
		End If

		echo ""
		key = input( "もう一度検索しますか。[Y/N]" )
		If key<>"y" and key<>"Y" Then   Exit Do
	Loop
End Sub


 
'***********************************************************************
'* Function: fc_patch
'***********************************************************************
Sub  fc_patch( Opt, AppKey )
	Set c = g_VBS_Lib
	Set section = new SkipSection

	echo_line
	echo  "パッチ・フォルダーにあるファイルと同じ内容のファイルが全体のフォルダーにあるかチェックします。"
	patch_path = InputPath( "パッチ・フォルダー>", c.CheckFolderExists )
	whole_path = InputPath( "全体のフォルダー>", c.CheckFolderExists )
	echo_line

	equal_count = 0 : diff_count = 0
	ExpandWildcard  GetFullPath( "*", patch_path ), F_File or F_SubFolder, folder, fnames
	For Each fname  In fnames
		If section.Start() Then
			echo_line
			b = fc( GetFullPath( fname, folder ), GetFullPath( fname, whole_path ) )
			echo  b
			If b Then  equal_count = equal_count + 1  Else  diff_count = diff_count + 1
			echo  "equal_count = "& equal_count & ",  diff_count  = "& diff_count
			section.End_
		End If
	Next
End Sub


 
'***********************************************************************
'* Function: fdiv_sth
'***********************************************************************
Sub  fdiv_sth( Opt, AppKey )
	Set c = g_VBS_Lib
	If WScript.Arguments.Unnamed.Count >= 1 Then
		input_path = WScript.Arguments.Unnamed(0)
	Else
		input_path = InputPath( "分割するファイル >", c.CheckFileExists )
	End If

	If WScript.Arguments.Unnamed.Count >= 2 Then
		div1_size =  WScript.Arguments.Unnamed(1)
	Else
		Do
			div1_size = Input( "分割後の１つのファイル・サイズ(MB) >" )
			If div1_size <> "" Then  Exit Do
		Loop
	End If
	div1_size = Eval( div1_size ) * 1024 * 1024

	out_base_path = GetFullPath( g_fs.GetBaseName( input_path ) +"\"+ g_fs.GetFileName( input_path ), _
		GetParentFullPath( input_path ) )

	Set w_=AppKey.NewWritable( g_fs.GetParentFolderName( out_base_path ) ).Enable()

	mkdir_for  out_base_path

	batch = "copy /B  "


	'//=== split binary file
	Set input_bin  = new BinaryArray
	echo  "Reading "+ g_fs.GetFileName( input_path ) +" ..."
	input_bin.Load  input_path
	all_size = input_bin.Size

	count = 0
	offset = 0
	Set output_bin = new BinaryArray
	Do
		count = count + 1
		Assert  count <= 999
		out_path = out_base_path +"."+ Right( "00" & count, 3 )

		output_bin.ToEmpty
		echo  "Writing "+ g_fs.GetFileName( out_path ) +" ..."
		output_bin.WriteFromBinaryArray  0, input_bin, offset, div1_size

		echo  "Saving  "+ g_fs.GetFileName( out_path ) +" ..."
		output_bin.Save  out_path

		batch = batch +""""+ g_fs.GetFileName( out_path ) +"""+"

		offset = offset + div1_size
		If offset >= all_size Then  Exit Do
	Loop

	input_bin = Empty
	output_bin = Empty


	'//=== make batch file
	batch = Left( batch, Len( batch ) - 1 ) +"  """+ g_fs.GetFileName( input_path ) +""""
	batch = batch +vbCRLF+ "@echo off" +vbCRLF+ "echo OK." +vbCRLF+ "pause" + vbCRLF
	CreateFile  g_fs.GetParentFolderName( out_base_path ) +"\"+_
		g_fs.GetBaseName( input_path ) +"_resume.bat", batch


	echo  "OK."
End Sub


 
'***********************************************************************
'* Function: feq_sth
'***********************************************************************
Sub  feq_sth( Opt, AppKey )
	Set c = g_VBS_Lib
	Do
		echo "[feq] ２つのバイナリファイル、またはフォルダーが同じかどうかを調べます。"

		path1 = InputPath( "path1>", c.CheckFileExists or c.CheckFolderExists )
		path2 = InputPath( "path2>", c.CheckFileExists or c.CheckFolderExists )
		echo ""

		If g_fs.FileExists( path1 )  and  g_fs.FileExists( path2 ) Then
			If IsSameBinaryFile( path1, path2, Empty ) Then
				echo  "same."
			Else
				echo  "different."
			End If
		Else
			fc  path1, path2
			echo ""
		End If
	Loop
End Sub


 
'***********************************************************************
'* Function: FindFile_sth
'***********************************************************************
Sub  FindFile_sth( Opt, AppKey )
	Set c = g_VBS_Lib
	folder_path = InputPath( "探す場所（フォルダのパス）>", c.CheckFolderExists )

	Do
		keyword = LCase( input( "ファイル名のすべてまたは一部>" ) )
		echo  ""
		If keyword = "" Then Exit Do

		EnumFolderObject  folder_path, folders  '// [out] folders
		For Each fo  In folders
			If InStr( LCase( fo.Name ), keyword ) > 0 Then  echo  fo.Path
			For Each fi  In fo.Files
				If InStr( LCase( fi.Name ), keyword ) > 0 Then  echo  fi.Path
			Next
		Next
		echo  ""
	Loop
End Sub


 
'***********************************************************************
'* Function: FindFile_Install
'***********************************************************************
Sub  FindFile_Install( Opt, AppKey )
	menu_caption = "ファイル名から検索"
	echo  "フォルダーの右クリック・メニューに、[ "+ menu_caption +" ] を追加します。"
	Pause

	prompt_vbs = SearchParent( "vbslib Prompt.vbs" )
	command_line = env( GetCScriptGUI_CommandLine( "//nologo """+_
		prompt_vbs +""" FindFile ""%1""" ) )
	InstallRegistryFileVerb  "Folder", "find_sth", menu_caption, command_line

	echo  "追加しました。"
End Sub


 
'***********************************************************************
'* Function: FindFile_Uninstall
'***********************************************************************
Sub  FindFile_Uninstall( Opt, AppKey )
	menu_caption = "ファイル名から検索"
	echo  "フォルダーの右クリック・メニューから、[ "+ menu_caption +" ] を削除します。"
	Pause

	UninstallRegistryFileVerb  "Folder", "find_sth"
End Sub


 
'***********************************************************************
'* Function: GetHash_sth
'***********************************************************************
Sub  GetHash_sth( Opt, AppKey )
	Set c = g_VBS_Lib

	echo  "ファイルのハッシュ値（MD5など）を表示し、クリップボードに入っているハッシュ値と比較します。"
	echo  "メモリー不足になったときは、GetHashPS コマンドを使ってください。"
	path = InputPath( "ファイルのパス>", c.CheckFileExists )

	Set bin = ReadBinaryFile( path )
	value_of_MD5       = bin.MD5
	value_of_SHA1      = bin.SHA1
	value_of_SHA256    = bin.SHA256
	value_of_SHA384    = bin.SHA384
	value_of_SHA512    = bin.SHA512
	value_of_RIPEMD160 = bin.RIPEMD160

	echo  "MD5: "+       value_of_MD5
	echo  "SHA1: "+      value_of_SHA1
	echo  "SHA256: "+    value_of_SHA256
	echo  "SHA384: "+    value_of_SHA384
	echo  "SHA512: "+    value_of_SHA512
	echo  "RIPEMD160: "+ value_of_RIPEMD160

	clip = GetTextFromClipboard()
	If StrComp( clip, value_of_MD5          , 1 ) = 0 Then
		s = "MD5"
	ElseIf StrComp( clip, value_of_SHA1     , 1 ) = 0 Then
		s = "SHA1"
	ElseIf StrComp( clip, value_of_SHA256   , 1 ) = 0 Then
		s = "SHA256"
	ElseIf StrComp( clip, value_of_SHA384   , 1 ) = 0 Then
		s = "SHA384"
	ElseIf StrComp( clip, value_of_SHA512   , 1 ) = 0 Then
		s = "SHA512"
	ElseIf StrComp( clip, value_of_RIPEMD160, 1 ) = 0 Then
		s = "RIPEMD160"
	Else
		s = Empty
	End If

	echo  ""
	s0 = "クリップボードの内容と一致するハッシュ値は、"
	If IsEmpty( s ) Then
		echo  s0 + "ありません。"

		SetTextToClipboard  value_of_MD5
		echo  "MD5 の値をクリップボードに格納しました。"
	Else
		echo  s0 + s + " です。"
	End If
	If ArgumentExist( "pause" ) Then _
		Pause
End Sub


 
'***********************************************************************
'* Function: GetHashPS_sth
'***********************************************************************
Sub  GetHashPS_sth( Opt, AppKey )
	Set c = g_VBS_Lib

	echo  "ファイルのハッシュ値（MD5など）を表示し、クリップボードに入っている"+ _
		"ハッシュ値と比較します。（大容量ファイル対応版）"
	path = InputPath( "ファイルのパス>", c.CheckFileExists )

	echo  "1. MD5"
	echo  "2. SHA1"
	echo  "3. SHA256"
	echo  "4. SHA384"
	echo  "5. SHA512"
	key = Input( "番号またはコマンド >" )
	Select Case  key
		Case  "1":  key = "MD5"
		Case  "2":  key = "SHA1"
		Case  "3":  key = "SHA256"
		Case  "4":  key = "SHA384"
		Case  "5":  key = "SHA512"
	End Select

	hash_value = GetHashPS( path, key )

	echo  hash_value

	clip = GetTextFromClipboard()
	s0 = "クリップボードの内容と一致"
	If StrComp( clip, hash_value, 1 ) = 0 Then
		echo  s0 + "しました。"
	Else
		echo  s0 + "していません。"
	End If
End Sub


 
'***********************************************************************
'* Function: GetStepPath_sth
'***********************************************************************
Sub  GetStepPath_sth( Opt, AppKey )
	echo  "フル・パスから相対パスに変換します。"
	abs_path  = InputPath( "フル・パス>", 0 )
	base_path = InputPath( "基準フォルダのフル・パス>", 0 )

	step_path = GetStepPath( abs_path, base_path )
	echo  step_path
End Sub


 
'***********************************************************************
'* Function: GetShortPath_sth
'***********************************************************************
Sub  GetShortPath_sth( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  "短いパス（ファイルやフォルダーの 8.3形式パス）に変換します。"
	long_path  = InputPath( "（長い）パス>", c.CheckFileExists or c.CheckFolderExists )
	echo  g_fs.GetFile( long_path ).ShortPath
End Sub


 
'***********************************************************************
'* Function: grep_sth
'***********************************************************************
Sub  grep_sth( Opt, AppKey )
	echo "[grep] ファイルの中のテキストを検索します"
	Set c = g_VBS_Lib
	out = "."
	Do
		If not IsEmpty( target ) Then  echo  "Enter のみ ： "+ target
		key = InputPath( "検索対象フォルダー、またはファイル >", c.AllowEnterOnly )
		If key <> "" Then  target = key
		If g_fs.FileExists( target ) Then
			grep_option_2 = ""
		Else
			grep_option_2 = " -r"
		End If

		echo  ""
		echo  "正規表現の メタ文字 一覧：. $ ^ { } [ ] ( ) | * + ? \"
		If not IsEmpty( keyword ) Then  echo  "Enter のみ ： "+ keyword
		key = Input( "キーワード（正規表現）>" )
		If key <> "" Then  keyword = key

		echo  ""
		echo  "使えるオプション ： -u, -i, -l, -L"
		If not IsEmpty( grep_option ) Then  echo  "Enter のみ ： "+ grep_option
		key = Input( "オプション >" )
		If key <> "" Then  grep_option = key

		echo  ""
		echo  """."" ： 表示のみ"
		If out = "." Then
			echo  "Enter のみ ： 表示のみ"
		Else
			echo  "Enter のみ ： """+ out +""""
		End If
		key = InputPath( "結果の出力先ファイル（上書きします）>", c.AllowEnterOnly )
		If key <> "" Then  out = key

		echo ""
		If out = "." Then
			out2 = ""
		Else
			Set w_=AppKey.NewWritable( out ).Enable()
			out2 = out
		End If

		grep  grep_option + grep_option_2 +" """+ keyword +""" """+ target +"""", out2

		If out <> "." Then
			ec = Empty
			echo  "出力しました。"
			If not ArgumentExist( "silent" ) Then _
				start  GetEditorCmdLine( out )
		End If
		w_ = Empty

		key = input( "もう一度検索しますか。[Y/N]" )
		If key<>"y" and key<>"Y" Then   Exit Do
	Loop
End Sub


 
'***********************************************************************
'* Function: InfiniteLoop
'***********************************************************************
Sub  InfiniteLoop( Opt, AppKey )
	echo  "Infinite Loop ..."
	Do
	Loop
End Sub


 
'***********************************************************************
'* Function: LAN_Path
'***********************************************************************
Sub  LAN_Path( Opt, AppKey )
	Set c = g_VBS_Lib
	Set w_= AppKey.NewWritable( "." ).Enable()

	echo  "\\ から始まる LAN のアドレスを file:// 形式に変換します。"

	lan_path = InputPath( "LAN のアドレスが書かれたファイルのパス>", c.CheckFileExists )
	tmp_path = GetTempPath( "*.txt" )
	Set read_file = OpenForRead( lan_path )
	Set write_file = OpenForWrite( tmp_path, Empty )
	Do Until  read_file.AtEndOfStream
		lan_addr = read_file.ReadLine()

		url = lan_addr
		If Left( url, 2 ) = "\\" Then  url = "file://"+ Mid( url, 3 )
		url = Replace( url, "\", "/" )

		write_file.WriteLine  url
	Loop
	read_file = Empty
	write_file = Empty

	start  Setting_getEditorCmdLine( tmp_path )
End Sub


 
'***********************************************************************
'* Function: MakeDiffFile
'***********************************************************************
Sub  MakeDiffFile( Opt, AppKey )
	Set c = g_VBS_Lib
	Set tc = get_ToolsLibConsts()
	echo "[Diff] テキストファイルの比較"
	old_path = InputPath( "old_path>", c.CheckFileExists )
	new_path = InputPath( "new_path>", c.CheckFileExists )
	diff_path = InputPath( "diff_path>", 0 )
	Set w_=AppKey.NewWritable( diff_path ).Enable()

	diff  old_path,  new_path,  diff_path,  tc.DiffForPatch
End Sub


 
'***********************************************************************
'* Function: MakeSyncModuleX_sth
'***********************************************************************
Sub  MakeSyncModuleX_sth( Opt, AppKey )
	MakeDiffProjectForSyncModuleX_sth  Opt, AppKey
End Sub


 
'***********************************************************************
'* Function: MakeDiffProjectForSyncModuleX_sth
'***********************************************************************
Sub  MakeDiffProjectForSyncModuleX_sth( Opt, AppKey )
	Set c = g_VBS_Lib

	echo  "SyncModuleX で更新する設定ファイルを、ベースにしたフォルダーと"+_
		"作成したフォルダーの差分から作成します。"

	attached_path = InputPath( "作成したフォルダーのパス>", c.CheckFolderExists )

	base_path = InputPath( "ベースにしたフォルダーのパス>", c.CheckFolderExists )


	'// Set "new_setting_path"
	new_setting_default_path = g_sh.SpecialFolders( "Desktop" ) +"\SyncModuleX.syncmx"
	echo  ""
	echo  "Enter のみ： (デスクトップ)\"+ GetStepPath( new_setting_default_path, _
		g_sh.SpecialFolders( "Desktop" ) )
	new_setting_path = InputPath( "新規作成する設定ファイルのパス（★上書きします）>", c.AllowEnterOnly )
	If new_setting_path = "" Then  new_setting_path = new_setting_default_path

	Set w_= AppKey.NewWritable( new_setting_path ).Enable()


	'// ...
	MakeDiffProjectForSyncModuleX _
		NewDiffFilePaths( Array( _
			attached_path, _
			base_path ), Empty ), _
		Empty, _
		new_setting_path, _
		Empty
End Sub


 
'***********************************************************************
'* Function: MakeNewScript
'***********************************************************************
Sub  MakeNewScript( Opt, AppKey )
	MakeNewScriptSub  AppKey, "Sample.vbs", "samples\sample.vbs"
	WScript.Quit  E_TestPass
End Sub


Sub  MakeNewScriptSub( AppKey, DefaultNewVBS_Path, TemplatePath )
	Set c = g_VBS_Lib

	'// 作成するファイル名をユーザーに要求します
	echo  "Enter のみ : デスクトップに "+ DefaultNewVBS_Path +" を作成します。"
	echo  "フォルダーのパスを入力することもできます。"
	start_in_path_backup = g_start_in_path
	g_start_in_path = g_sh.SpecialFolders( "Desktop" )
	new_vbs_path = InputPath( "作成するスクリプト・ファイルの名前>", c.AllowEnterOnly )
	g_start_in_path = start_in_path_backup


	'// ファイル名を調整します
	If new_vbs_path = "" Then _
		new_vbs_path = GetFullPath( DefaultNewVBS_Path, g_sh.SpecialFolders( "Desktop" ) )
	If LCase( g_fs.GetExtensionName( new_vbs_path ) ) <> "vbs" Then _
		new_vbs_path = new_vbs_path +".vbs"
	If exist( new_vbs_path ) Then _
		Raise  1, "ファイルまたはフォルダーが存在しないパスを指定してください"


	'// scriptlib が（親フォルダーにも）存在するかどうかを調べます
	vbslib_parent_path = g_fs.GetParentFolderName( new_vbs_path )
	Do
		If vbslib_parent_path = "" Then  Exit Do
		If exist( vbslib_parent_path +"\scriptlib" ) Then  Exit Do
		vbslib_parent_path = g_fs.GetParentFolderName( vbslib_parent_path )
	Loop
	If vbslib_parent_path = "" Then
		vbslib_parent_path = g_fs.GetParentFolderName( new_vbs_path )

		'// scriptlib を作成するかどうかをユーザーに要求します
		is_make_vbslib = True
		echo  ""
		echo  "Enter のみ: 作成する"
		key = Input( "vbslib が使えるように scriptlib フォルダーも作成しますか。[Y/N]" )
		If key="n" or key="N" Then  is_make_vbslib = False
	Else
		is_make_vbslib = False
	End If

	echo  ""


	'// scriptlib フォルダーを作成します
	If is_make_vbslib Then
		Set w_= AppKey.NewWritable( vbslib_parent_path +"\scriptlib" ).Enable()
		copy  "scriptlib", vbslib_parent_path
	End If


	'// スクリプト・ファイルを作成します
	Set w_= AppKey.NewWritable( new_vbs_path ).Enable()
	copy_ren  TemplatePath,  new_vbs_path


	'// スクリプト・ファイルを作成するフォルダーを開きます
	OpenFolder  new_vbs_path


	'// スクリプト・ファイルを開きます
	Sleep  1000
	start  GetEditorCmdLine( new_vbs_path )
End Sub


 
'***********************************************************************
'* Function: MakeNewPrompt
'***********************************************************************
Sub  MakeNewPrompt( Opt, AppKey )
	MakeNewScriptSub  AppKey, "Prompt.vbs", "samples\sample_short_hand_prompt.vbs"

	echo_line
	echo  "vbs ファイルを作成しました。"
	echo  "テキスト・エディターで、vbs ファイルの最後にある NewScript 関数を編集してください。"
	echo  "vbs ファイルをダブルクリックすると編集した内容を実行します。"
End Sub


 
'***********************************************************************
'* Function: MakeCrossedOldSections_sth
'***********************************************************************
Sub  MakeCrossedOldSections_sth( Opt, AppKey )
	Set c = g_VBS_Lib

	out_path = InputPath( "1xA(out) >", c.CheckFolderExists )
	new_path = InputPath( "1A (new) >", c.CheckFolderExists )
	old_path = InputPath( "2A (old) >", c.CheckFolderExists )
	new_txsc_path = InputPath( "new_txsc >", Empty )
	old_txsc_path = InputPath( "old_txsc >", Empty )

	Set w_=AppKey.NewWritable( Array( out_path, new_txsc_path, old_txsc_path ) ).Enable()

	MakeCrossedOldSections  out_path,  new_path,  old_path,  new_txsc_path,  old_txsc_path,  Empty

	If ArgumentExist( "pause" ) Then _
		Pause
End Sub


 
'***********************************************************************
'* Function: ModuleAssort2_sth
'***********************************************************************
Sub  ModuleAssort2_sth( Opt, AppKey )
	include  "_src\Test\tools\T_ModuleAssort2\T_ModuleAssort2.vbs"
	ModuleAssort2  Opt, AppKey
End Sub


 
'***********************************************************************
'* Function: mkdir_sth
'***********************************************************************
Sub  mkdir_sth( Opt, AppKey )
	echo  "[MkDir] make directory"
	echo  "深いフォルダーを作ります。または、相対パスを使ってフォルダーを作ります。"
	Set c = g_VBS_Lib

	base_path = InputPath( "作成するフォルダーのパス、または、相対パスの基準フォルダー >", 0 )

	Set w_=AppKey.NewWritable( base_path ).Enable()

	If not exist( base_path ) Then
		mkdir  base_path
		OpenFolder  base_path
	End If

	step_path = Input( "作成するフォルダーの相対パス >" )
	mkdir  base_path +"\"+ step_path
	OpenFolder  base_path +"\"+ step_path
End Sub


 
'***********************************************************************
'* Function: MD5List
'***********************************************************************
Sub  MD5List( Opt, AppKey )
	Set c = g_VBS_Lib
	Set tc = get_ToolsLibConsts()
	echo  "1) [Make]   MD5リストを作成します"
	echo  "2) [Check]  MD5リストをチェックします"
	echo  "3) [Stamp]  MD5リストをチェックしてタイムスタンプを合わせます"
	echo  "4) [Append] MD5リストに追加します"
	echo  "5) [Search] MD5リストの中を検索します"
	echo  "6) [Fragment]   _FullSet.txt があるフォルダーから同じ内容のファイルを削除します"
	echo  "7) [Defragment] _FullSet.txt があるフォルダーを完全形に復帰します"
	echo  "8) [CopyDiff] MD5 リストを使って差分コピーします"
	echo  "9) [CutTimeStamp] タイムスタンプ付き MD5リストからタイムスタンプを除きます"
	echo  "10)[Sort] パスでソートします"
	key = Input( "番号またはコマンド >" )

	Select Case  key
		Case "1" : key = "make"
		Case "2" : key = "check"
		Case "3" : key = "stamp"
		Case "4" : key = "append"
		Case "5" : key = "search"
		Case "6" : key = "fragment"
		Case "7" : key = "defragment"
		Case "8" : key = "copydiff"
		Case "9" : key = "cuttimestamp"
		Case "10": key = "sort"
	End Select
	operation = LCase( key )

	Select Case  operation

		Case "make"
			folder_path = InputPath( "調べるフォルダーのパス >", c.CheckFolderExists )
			path_of_MD5 = InputPath( "MD5 リストのファイル パス（出力先）>", 0 )
			echo  ""
			echo  "Enterのみ: y"
			time_stamp_key = Input( "タイムスタンプを含めますか[Y/N]" )
			If time_stamp_key = "N"  or  time_stamp_key = "n" Then
				option_flags = 0
			Else
				option_flags = get_ToolsLibConsts().TimeStamp
			End If
			Set w_=AppKey.NewWritable( path_of_MD5 ).Enable()

			MakeFolderMD5List  folder_path,  path_of_MD5,  option_flags
			echo  "作成しました。"

		Case "check"
			folder_path = InputPath( "調べるフォルダーのパス >", c.CheckFolderExists )
			path_of_MD5 = InputPath( "MD5 リストのファイル パス（入力元）>", c.CheckFileExists )

			CheckFolderMD5List  folder_path, path_of_MD5, Empty
			echo  "問題ありません。"

		Case "stamp"
			folder_path = InputPath( "タイムスタンプを変更するファイルがあるフォルダーのパス >", c.CheckFolderExists )
			path_of_MD5 = InputPath( "MD5 リストのファイル パス（入力元）>", c.CheckFileExists )
			Set w_=AppKey.NewWritable( folder_path ).Enable()

			CheckFolderMD5List  folder_path, path_of_MD5, c.TimeStamp
			echo  "問題ありません。"
			echo  "タイムスタンプを修正しました。"

		Case "append"
			folder_path = InputPath( "追加するフォルダーのパス >", c.CheckFolderExists )
			path_of_MD5 = InputPath( "更新する MD5 リストのファイル パス（★上書きします）>", c.CheckFileExists )
			base_of_MD5 = InputPath( "MD5 リストの中の相対パスの基準パス >", c.CheckFolderExists )
			Set w_=AppKey.NewWritable( path_of_MD5 ).Enable()
			Set defrag = OpenForDefragment( path_of_MD5, Empty )

			defrag.Append  path_of_MD5,  base_of_MD5,  folder_path,  Empty
			echo  "更新しました。"

		Case "search"
			path_of_MD5 = InputPath( "MD5 リストのファイル パス >", c.CheckFileExists )
			Do
				echo  "Enter のみ: 終了"
				key = Input( "検索キーとする MD5 または MD5 を計算するファイルのパス >" )
				If key = "" Then _
					Exit Do
				file_path = GetFullPath( key,  g_start_in_path )
				If g_fs.FileExists( file_path ) Then

					key = GetHashOfFile( file_path, "MD5" )
				End If

				grep  """"+ key +""" """+ path_of_MD5 +"""", ""
			Loop

		Case "fragment"
			Do
				echo  ""
				echo  "Enter のみ：終了"

				folder_path = InputPath( "_FullSet.txt がある（を作る）フォルダー >", _
					c.CheckFolderExists  or  c.AllowEnterOnly )
				If folder_path = "" Then _
					Exit Do
				full_set_path = GetFullPath( "_FullSet.txt", folder_path )
				If exist( full_set_path ) Then
					flags = Empty
				Else
					echo  ""
					echo  "1. _FullSet.txt を作る [Make]"
					echo  "2. サブ フォルダーにある _FullSet.txt があるフォルダーを処理する [Nest]"
					key = Input( "番号またはコマンド >" )

					Select Case  key
						Case "1" : key = "make"
						Case "2" : key = "nest"
					End Select
					operation = LCase( key )

					Select Case  operation
						Case "make"
							Set w_=AppKey.NewWritable( full_set_path ).Enable()
							MakeFolderMD5List  folder_path,  full_set_path,  get_ToolsLibConsts().TimeStamp
							flags = Empty
						Case "nest"
							flags = c.SubFolder
						Case Else
							Exit Sub
					End Select
				End If

				If IsEmpty( defrag ) Then
					path_of_MD5 = InputPath( "MD5 リストのファイル パス >", c.CheckFileExists )

					Set defrag = OpenForDefragment( path_of_MD5, Empty )
				End If
				Set w_=AppKey.NewWritable( folder_path ).Enable()

				defrag.Fragment  g_fs.GetParentFolderName( path_of_MD5 ),  folder_path,  flags
				echo  "Fragment しました。"
			Loop
			defrag = Empty


		Case "defragment"
			folder_path = InputPath( "_FullSet.txt があるフォルダー >", c.CheckFolderExists )
			full_set_path = GetFullPath( "_FullSet.txt", folder_path )
			If exist( full_set_path ) Then
				flags = Empty
			Else
				echo  ""
				echo  "2. サブ フォルダーにある _FullSet.txt があるフォルダーを処理する [Nest]"
				key = Input( "番号またはコマンド >" )

				Select Case  key
					Case "2" : key = "nest"
				End Select
				operation = LCase( key )

				Select Case  operation
					Case "nest"
						flags = c.SubFolder
					Case Else
						Exit Sub
				End Select
			End If
			path_of_MD5 = InputPath( "MD5 リストのファイル パス >", c.CheckFileExists )
			Set w_=AppKey.NewWritable( folder_path ).Enable()

			Set defrag = OpenForDefragment( path_of_MD5, Empty )
			defrag.CopyFolder  g_fs.GetParentFolderName( path_of_MD5 ),  folder_path,  folder_path,  flags
			defrag = Empty


		Case "copydiff"
			echo  "コピー元とコピー先の MD5リストを使って、ファイルやフォルダーの差分をコピーします。"
			echo  "コピー元の MD5リストとして指定したパスにファイルがないときは、MD5リストを作ります。"
			source_folder_path      = InputPath( "コピー元のフォルダーのパス >",  c.CheckFolderExists )
			destination_folder_path = InputPath( "コピー先のフォルダーのパス >",  Empty )
			source_MD5_list_file_path      = InputPath( "コピー元の MD5リストのパス >",  c.AllowEnterOnly )
			destination_MD5_list_file_path = InputPath( "コピー先の MD5リストのパス >",  c.CheckFileExists )
			Set w_=AppKey.NewWritable( Array( destination_folder_path,  source_MD5_list_file_path ) ).Enable()

			CopyDiffByMD5List  source_folder_path,  destination_folder_path, _
				source_MD5_list_file_path,  destination_MD5_list_file_path, _
				c.AfterDelete  or  tc.FasterButNotSorted


		Case "cuttimestamp"
			input_path  = InputPath( "タイムスタンプがある入力ファイルのパス（上書きしません）>",  c.CheckFileExists )
			output_path = InputPath( "出力ファイルのパス >",  Empty )
			Assert  StrComp( GetFullPath( input_path,  Empty ),  GetFullPath( output_path,  Empty ),  1 ) <> 0
			Set w_=AppKey.NewWritable( output_path ).Enable()
			Set rep = StartReplace( input_path,  output_path,  True )
			Do Until rep.r.AtEndOfStream
				SplitLineAndCRLF  rep.r.ReadLine(), line, cr_lf  '// Set "line", "cr_lf"

				If Mid( line, 5, 1 ) = "-" Then _
					line = Mid( line,  27 )
				rep.w.WriteLine  line + cr_lf
			Loop
			rep.Finish
			rep = Empty


		Case "sort"
			input_path  = InputPath( "ソートする入力ファイルのパス（上書きしません）>",  c.CheckFileExists )
			output_path = InputPath( "出力ファイルのパス >",  Empty )
			Assert  StrComp( GetFullPath( input_path,  Empty ),  GetFullPath( output_path,  Empty ),  1 ) <> 0
			Set w_=AppKey.NewWritable( output_path ).Enable()
			SortFolderMD5List  input_path,  output_path,  Empty

	End Select
End Sub


 
'***********************************************************************
'* Function: MakeFileList_sth
'***********************************************************************
Sub  MakeFileList_sth( Opt, AppKey )
	Set c = g_VBS_Lib

	echo  "ファイル名を一覧します。"
	folder_path = InputPath( "調べるフォルダーのパス >", c.CheckFolderExists )
	path_of_list = InputPath( "ファイル リストのファイル パス（出力先）>", 0 )

	echo  "1. 相対パスの一覧 [Step]"
	echo  "2. ツリー形式・ファイルなし [DirTree]"
	echo  "3. ツリー形式・ファイルあり [Tree]"
	key = Trim( Input( "番号またはコマンド名>" ) )
	Select Case  key
		Case "1": key = "Step"
		Case "2": key = "DirTree"
		Case "3": key = "Tree"
	End Select

	Set w_=AppKey.NewWritable( path_of_list ).Enable()
	cd  folder_path
	If StrComp( key, "Step", 1 ) = 0 Then
		RunBat  "dir /S /B * > """+ path_of_list +"""", ""
		OpenForReplace( path_of_list,  Empty ).Replace  folder_path +"\",  ""
	ElseIf StrComp( key, "DirTree", 1 ) = 0 Then
		RunBat  "tree /A . > """+ path_of_list +"""", ""
	ElseIf StrComp( key, "Tree", 1 ) = 0 Then
		RunBat  "tree /F /A . > """+ path_of_list +"""", ""
	End If
End Sub


 
'***********************************************************************
'* Function: ModuleAssort
'***********************************************************************
Sub  ModuleAssort( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  ">ModuleAssort"
	echo  "プログラム ソースのマスターをモジュール／ターゲット／リビジョンに分類します。"
	setting_path = InputPath( "ModuleAssort.moas か Projects.xml ファイルのパス>", c.CheckFileExists )
	echo_line
	messaging_time_msec = 600
	include  g_vbslib_ver_folder +"SyncFilesMenuLib_old.vbs"

	If ArgumentExist( "ArgsLog" ) Then
		For Each  path  In  Array( "_src\Test\tools\T_SyncFiles", "..\T_SyncFiles" )
			If exist( path +"\SettingForTest_pre.vbs" ) Then
				include  path +"\SettingForTest_pre.vbs"
				include  path +"\SettingForTest.vbs"
				SetVar  "Setting_getDiffCmdLine", "ArgsLog"
				Exit For
			End If
		Next
		Assert  not IsEmpty( path )
	End If
	If ArgumentExist( "ExpandWildcard_Sort" ) Then _
		g_Vers("ExpandWildcard_Sort") = True


	g_FileHashCache.RemoveAll
	Set sync = new ModuleAssortClass
	key = ""
	If g_fs.GetExtensionName( setting_path ) = "moas" Then
		w_=Empty : Set w_=AppKey.NewWritable( setting_path ).Enable()
		sync.OpenSetting  setting_path

		echo_line
		echo  "1. [CheckOut] a Project"
		echo  "2. [Assort] Modules from Project in workspace"
		echo  "3. [Commit] a Project"
		echo  "4. [Make]"
		echo  "5. [CheckOutAndUpdate] a Project"
		echo  "7. Revert, 8. DeleteProjectCommit"
		echo  "11. ExportNewestModule, 12. ImportNewestModule"
		echo  "13. Defragment, 14. Fragment, 15. FragmentProject"
		echo  "16. [Delete] a module safely"
		echo  "17. [Verify] all fragments"
		echo  "18. ExpandPatch, 19. MakePatch"
		echo  "21. [Sync]hronize Modules Table"
		echo  "22. [CheckSync]hronized Modules Table"
		echo  "23. [Synchronize] Modules Pair"
		echo  "31. FindSameFile, 32. ListFiles, 33. RefreshHashCache"
		echo  "34. FindProject, 35. FindCross, 36. FindCrossSymbol"
		echo  "37.Rename"
		key = Input( "番号または [] 内のコマンド名>" )
		Select Case  key
			Case  "1" : key = "CheckOut"
			Case  "2" : key = "Assort"
			Case  "3" : key = "Commit"
			Case  "4" : key = "Make"
			Case  "5" : key = "CheckOutAndUpdate"
			Case  "7" : key = "Revert"
			Case  "8" : key = "DeleteProjectCommit"
			Case  "11" : key = "ExportNewestModule"
			Case  "12" : key = "ImportNewestModule"
			Case  "13" : key = "Defragment"
			Case  "14" : key = "Fragment"
			Case  "15" : key = "FragmentProject"
			Case  "16" : key = "Delete"
			Case  "17" : key = "Verify"
			Case  "18" : key = "ExpandPatch"
			Case  "19" : key = "MakePatch"
			Case  "21" : key = "Sync"
			Case  "22" : key = "CheckSync"
			Case  "23" : key = "Synchronize"
			Case  "31" : key = "FindSameFile"
			Case  "32" : key = "ListFiles"
			Case  "33" : key = "RefreshHashCache"
			Case  "34" : key = "FindProject"
			Case  "35" : key = "FindCross"
			Case  "36" : key = "FindCrossSymbol"
			Case  "37" : key = "Rename"
		End Select
		echo_line

		w_=Empty : Set w_=AppKey.NewWritable( sync.MastersPath ).Enable()
		If StrComp( key, "CheckOut", 1 ) = 0  or  StrComp( key, "CheckOutAndUpdate", 1 ) = 0  or _
				StrComp( key, "Make", 1 ) = 0  or _
				StrComp( key, "FindProject", 1 ) = 0  or  StrComp( key, "ListFiles", 1 ) = 0  or _
				StrComp( key, "FindCross", 1 ) = 0  or  StrComp( key, "FindCrossSymbol", 1 ) = 0 Then
			setting_path = sync.MastersPath +"\Projects.xml"
			If not exist( setting_path ) Then
				setting_path = InputPath( "Projects.xml ファイルのパス>", c.CheckFileExists )
			End If

		ElseIf StrComp( key, "Assort", 1 ) = 0 Then
			sync.Assort
			If not ArgumentExist( "silent" ) Then
				Sleep  300
				start  GetEditorCmdLine( sync.ModuleListPath )
			End If
			echo  ""
			echo  "アソートしました。"
			Sleep  messaging_time_msec

		ElseIf StrComp( key, "Commit", 1 ) = 0 Then
			sync.LoadProjectList  sync.ProjectListPath
			echo_line
			project_name = sync.InputProject( "コミットするプロジェクトの番号または名前>", Empty )
			echo  ""
			recent_revision_name = sync.GetRecentProjectRevisionName( project_name )
			If recent_revision_name <> "" Then
				echo  "最近のリビジョン："+ recent_revision_name
			Else
				echo  "最初のリビジョンです。"
			End If
			revision_name = Input( "このコミットで作成するリビジョン名>" )
			echo  ""
			comment = Input( "作成するリビジョンのコメント>" )
			echo_line
			sync.Commit  project_name, revision_name, comment
			If not ArgumentExist( "silent" ) Then
				Sleep  300
				start  GetEditorCmdLine( sync.ProjectListPath +"#name="""+ project_name +"""" )
			End If
			echo  ""
			echo  "コミットしました。"
			Sleep  messaging_time_msec

		ElseIf StrComp( key, "DeleteProjectCommit", 1 ) = 0 Then
			echo_line
			project_name = sync.InputProject( "削除するリビジョンを持つプロジェクトの番号または名前>", Empty )
			revision_name = Input( "削除するリビジョン名>" )
			key = Input( "削除しますか [Y/N]" )
			If key = "y"  or  key = "Y" Then
				echo_line
				sync.DeleteProjectCommit  project_name, revision_name
				echo_line
				echo  "プロジェクトのリビジョンを１つ削除しました。"
				Sleep  messaging_time_msec
			End If

		ElseIf StrComp( key, "Revert", 1 ) = 0 Then
			Do
				echo  "Enter のみ：終了"
				revision_tag = Input( "以前のコミットに戻す現在の _Modules.xml 内の Revision タグ>" )
				If revision_tag = "" Then _
					Exit Do

				sync.LoadModuleList   sync.ModuleListPath
				sync.LoadProjectList  sync.ProjectListPath
				w_=Empty : Set w_=AppKey.NewWritable( sync.GetWritablesForRevertByXML( revision_tag ) ).Enable()
				sync.RevertByXML  revision_tag
				echo  "指定したリビジョンをコミットに戻しました。"
				echo  "戻した内容でのアソートは、まだ行われていません。"
				echo  ""
			Loop


		ElseIf StrComp( key, "Defragment", 1 ) = 0 Then
			echo  ""
			echo  "断片化しているリビジョンのフォルダーを、完全なフォルダーに戻します。"
			echo  "断片化とは、同じ内容のファイルを一時的に削除することです。"
			echo  "_FullSet.txt ファイルがあるフォルダーは、断片化している可能性があります。"
			echo  "なお、CheckOut, Assort, Commit は、断片化していても正しく動作します。"
			Do
				echo  ""
				echo  "Enter のみ：終了"
				echo  "マスターズ フォルダーのパス：すべての断片化しているモジュール"
				fragmented_path = InputPath( "断片化しているフォルダーのパス >", _
					c.CheckFolderExists  or  c.AllowEnterOnly )
				If fragmented_path = "" Then _
					Exit Do

				If fragmented_path = sync.MastersPath Then
					sync.Defragment  sync.c.All
				Else
					sync.Defragment  fragmented_path
				End If

				echo  ""
				echo  "戻しました。"
			Loop

		ElseIf StrComp( key, "Fragment", 1 ) = 0 Then
			echo  ""
			echo  "リビジョンのフォルダーを断片化して、フォルダーのサイズを減らします。"
			echo  "断片化とは、同じ内容のファイルを一時的に削除することです。"
			echo  "断片化したフォルダーは、Defragmemt で元に戻ります。"
			echo  "なお、CheckOut, Assort, Commit は、断片化していても正しく動作します。"
			Do
				echo  ""
				echo  "Enter のみ：終了"
				echo  "マスターズ フォルダーのパス：すべてのモジュールを断片化"
				fragmenting_path = InputPath( "断片化するフォルダーのパス >", _
					c.CheckFolderExists  or  c.AllowEnterOnly )
				If fragmenting_path = "" Then _
					Exit Do

				If fragmenting_path = sync.MastersPath Then
					sync.Fragment  sync.c.All
				Else
					sync.Fragment  fragmenting_path
				End If

				echo  ""
				echo  "断片化しました。"
			Loop

		ElseIf StrComp( key, "Delete", 1 ) = 0 Then
			echo  ""
			echo  "マスターズの中のフォルダーを安全に削除します。"
			echo  "安全にとは、Defragment に必要なファイルが削減しようとしているフォルダーの中にあるときは、"+ _
				"そのファイルを Fragment で以前 削除された場所に戻すことで、Defragment が失敗しないようにすることです。"
			Do
				echo  ""
				echo  "Enter のみ：終了"
				deleting_path = InputPath( "削除するフォルダーのパス >", _
					c.CheckFolderExists  or  c.AllowEnterOnly )
				If deleting_path = "" Then _
					Exit Do

				echo  ""
				key = Input( "削除しますか [Y/N]" )
				If key = "y"  or  key = "Y" Then
					sync.DeleteInMasters  deleting_path
					echo  ""
					echo  "削除しました。"
				End If
			Loop

		ElseIf StrComp( key, "Verify", 1 ) = 0 Then
			echo  ""
			echo  "断片化したモジュールが完全な形に戻ることができるかどうかについて、"+ _
				"必要なファイルがあるかどうかのみチェックを行います。"
			echo  ""
			Do
				echo  "1. 必要なファイルの存在チェック [FindOut]"
				echo  "2. ファイルの内容のチェック [Verify]"
				echo  "8. すべて [VerifyAll]"
				echo  "9 or Enter のみ：終了"
				key = Trim( Input( "番号またはコマンド名>" ) )
				Select Case  key
					Case "1": key = "FindOut"
					Case "2": key = "Verify"
					Case "8": key = "VerifyAll"
					Case "9": key = "Exit"
					Case "":  key = "Exit"
				End Select
				echo_line

				option_ = Empty
				If StrComp( key, "FindOut", 1 ) = 0 Then
					option_ = sync.c.FindOut
				ElseIf StrComp( key, "Verify", 1 ) = 0 Then
					option_ = sync.c.Verify
				ElseIf StrComp( key, "VerifyAll", 1 ) = 0 Then
					option_ = sync.c.VerifyAll
				ElseIf StrComp( key, "Exit", 1 ) = 0 Then
					Exit Do
				End If

				If not IsEmpty( option_ ) Then
					If TryStart(e) Then  On Error Resume Next

						sync.VerifyAllFragments  option_

					If TryEnd Then  On Error GoTo 0
					If e.num = 0 Then
						echo  "チェックしました。"
					Else
						echo  ""
						echo_v  e.Description
						e.Clear
					End If
				End If

				echo_line
			Loop

		ElseIf StrComp( key, "ExportNewestModule", 1 ) = 0 Then
			echo  ""
			echo  "Masters フォルダーから、指定のモジュールの最新リビジョンをエクスポートします。"
			echo  ""
			echo  "ALL  : すべてのモジュールをエクスポート"
			echo  "List : モジュールとファイルの一覧のみ出力"
			module_path = Input( "モジュールのパス >" )
			If StrComp( module_path, "ALL", 1 ) = 0 Then
				echo  ""
				default_path = "_NewestModules"
				echo  "Enter のみ：マスターフォルダーの "+ default_path

				output_path = InputPath( "出力先のフォルダーのパス（★上書きします） >", _
					c.AllowEnterOnly )
				If output_path = "" Then _
					output_path = GetFullPath( default_path, sync.MastersPath )

				w_=Empty : Set w_=AppKey.NewWritable( Array( output_path, sync.MastersPath ) ).Enable()
				sync.ExportNewestModules  output_path, Empty

			ElseIf  NOT  StrComp( module_path, "List", 1 ) = 0 Then
				module_path = GetFullPath( module_path, sync.MastersPath )
				AssertExist  module_path
				echo  ""

				default_path = "_Newest_"+ GetStepPath( module_path, sync.MastersPath )
				echo  "Enter のみ：マスターフォルダーの "+ default_path

				output_path = InputPath( "出力先のフォルダーのパス（★上書きします） >", _
					c.AllowEnterOnly )
				If output_path = "" Then _
					output_path = GetFullPath( default_path, sync.MastersPath )

				w_=Empty : Set w_=AppKey.NewWritable( Array( output_path, sync.MastersPath ) ).Enable()
				sync.ExportNewestModule  module_path,  output_path,  Empty

			Else
				sync.SaveNewestModulesList  sync.MastersPath +"\Newest_Modules.xml"
				sync.SaveNewestFilesList    sync.MastersPath +"\Newest_Files.xml"
			End If
			echo  ""
			echo  "エクスポートしました。"
			Sleep  messaging_time_msec

		ElseIf StrComp( key, "ImportNewestModule", 1 ) = 0 Then
			echo  ""
			echo  "指定のモジュールの各リビジョンをインポートします。"
			echo  ""
			module_path = InputPath( "各リビジョンのフォルダーが入ったモジュールのパス（コピー元）>", _
				c.CheckFolderExists )
			sync.ImportNewestModule  Empty,  module_path,  Empty
			echo  ""
			echo  "インポートしました。"
			Sleep  messaging_time_msec

		ElseIf StrComp( key, "ExpandPatch", 1 ) = 0 Then
			echo  "パッチ形式になっているマスターを、完全な形にします。"
			echo  ""
			echo  "例： C:\Masters\Module\Target\02-Patch-of-01"
			patch_path = InputPath( "パッチ形式になっているマスター フォルダーのパス >", _
				c.CheckFolderExists )
			echo_line
			sync.ExpandPatch  patch_path
			echo  ""
			echo  "変換しました。"
			Sleep  messaging_time_msec

		ElseIf StrComp( key, "MakePatch", 1 ) = 0 Then
			echo  "マスターにあるモジュールをパッチ形式に変換します。"
			full_set_path = InputPath( "パッチ形式に変えるマスター フォルダーのパス >", _
				c.CheckFolderExists )
			echo  ""
			echo  "リビジョンをベースにするときの例： 01"
			echo  "別のターゲットをベースにするときの例： Target\01"
			echo  "ベースにするフォルダーのパスも指定可能"
			base_name = Input( "ベース >" )
			base_name = MeltCmdLine( base_name, 1 )
			echo_line
			sync.MakePatch  full_set_path,  base_name
			echo  ""
			echo  "変換しました。"
			Sleep  messaging_time_msec

		ElseIf StrComp( key, "Sync", 1 ) = 0 Then
			echo  ""
			echo  "指定のモジュールの中の各ターゲットを同期します。"
			echo  ""
			module_path = Input( "モジュールのパス >" )


			module_path = GetFullPath( module_path, sync.MastersPath )
			AssertExist  module_path
			echo  ""
			work_path = "_Newest_"+ GetStepPath( module_path, sync.MastersPath )
			If not exist( work_path ) Then
				w_=Empty : Set w_=AppKey.NewWritable( work_path ).Enable()
				sync.ExportNewestModule  module_path,  work_path,  Empty
			Else
				echo  "作業フォルダーが存在するので、"+ _
					"マスターズからモジュールをコピーする処理をスキップしました。"
			End If

			Skip

			setting_path = module_path +"\SyncFilesT_"+ g_fs.GetFileName( module_path ) +".xml"
			If not exist( setting_path ) Then
				w_=Empty : Set w_=AppKey.NewWritable( setting_path ).Enable()
				SyncFilesT_Class_createFirstSetting  module_path,  setting_path
			End If

		ElseIf StrComp( key, "CheckSync", 1 ) = 0 Then
			sync.CheckSync  Empty

		ElseIf StrComp( key, "Synchronize", 1 ) = 0 Then
			work_path = g_sh.SpecialFolders( "Desktop" ) +"\_ModuleAssortSynchronize"
			Set w_=AppKey.NewWritable( Array( work_path,  sync.MastersPath ) ).Enable()
			ModuleAssort_doSynchronize_Sub  AppKey, sync, work_path

		ElseIf StrComp( key, "FindSameFile", 1 ) = 0 Then
			echo  "次に入力するファイルと同じ内容のファイルを探します。"
			path = InputPath( "ファイルのパス>", c.CheckFileExists )
			echo  "MD5: "+ ReadBinaryFile( path ).MD5
			same_file_paths = sync.FindSameFile( path )
			echo_line
			Do
				For i=0 To UBound( same_file_paths )
					echo  CStr( i + 1 ) +". "+ GetStepPath( same_file_paths(i), sync.MastersPath )
				Next
				If UBound( same_file_paths ) = -1 Then
					echo  ""
					echo  "同じ内容のファイルは、ありませんでした。"
					echo  ""
					Exit Do
				End If
				key = CInt2( Input( "注目するファイルの番号>" ) )
				If key = 0 Then _
					Exit Do
				same_file_path = same_file_paths( key - 1 )

				Do
					echo_line
					echo  same_file_path
					echo  "1. ファイルがあるフォルダーを開く"
					echo  "2. 新しいリビジョンがあるフォルダーを開く"
					echo  "3. 新しいリビジョンと比較する"
					echo  "9. 戻る"
					key = CInt2( Input( "コマンドの番号>" ) )
					echo_line

					If key = 9 Then _
						Exit Do

					If key = 2  or  key = 3 Then
						new_file_path = sync.InputRevisionAndGetPath( same_file_path, Empty )
						echo_line
					End If

					If TryStart(e) Then  On Error Resume Next

						If key = 1 Then
							OpenFolder  same_file_path
						ElseIf key = 2 Then
							OpenFolder  new_file_path
						ElseIf key = 3 Then
							start  GetDiffCmdLine( same_file_path, new_file_path )
						End If

					If TryEnd Then  On Error GoTo 0
					If e.num <> 0 Then
						echo_v  e.Description
						e.Clear
					End If
				Loop
			Loop

		ElseIf StrComp( key, "RefreshHashCache", 1 ) = 0 Then
			echo  "_HashCache.txt ファイルを最新に更新します。"
			echo  ""
			echo  "Enterのみ：マスターズ フォルダーのすべてのモジュールのフォルダー"
			path = InputPath( "更新対象のフォルダーのパス>",  c.CheckFolderExists  or  c.AllowEnterOnly )
			sync.RefreshHashCache  path
			echo  ""
			echo  "更新しました。"
			Sleep  messaging_time_msec

		ElseIf StrComp( key, "Rename", 1 ) = 0 Then
			echo  "モジュール名、ターゲット名、リビジョン名のいずれかを変更します。"
			echo  "設定やコミットしたデータ ファイルの中の名前も変更します。"
			echo  ""
			echo  "変更前後のフォルダーのパスを入力してください。"
			echo  "マスターズ フォルダーからの相対パスでも入力できます。"

			old_path = Input( "変更前のパス >" )
			AssertExist  GetFullPath( old_path, g_start_in_path )

			new_path = Input( "変更後のパス >" )

			sync.Rename  old_path,  new_path,  not ArgumentExist( "silent" )
			echo  ""
			echo  "変更しました。"
			Sleep  messaging_time_msec
		End If
	End If
	If g_fs.GetFileName( setting_path ) = "Projects.xml" Then
		sync.LoadProjectList  setting_path
		If key = "" Then
			echo  ""
			echo  "1. [CheckOut] Project"
			echo  "2. [Make] Project"
			echo  "3. [CheckOutAndUpdate] Project"
			echo  "4. [FragmentProject]"
			echo  "5. [FindProject] by a module revision"
			echo  "6. [FindCross]"
			echo  "7. [FindCrossSymbol]"
			echo  "8. [ListFiles]"
			key = Input( "番号またはコマンド名>" )
			Select Case  key
				Case  "1" : key = "CheckOut"
				Case  "2" : key = "Make"
				Case  "3" : key = "CheckOutAndUpdate"
				Case  "4" : key = "FragmentProject"
				Case  "5" : key = "FindProject"
				Case  "6" : key = "FindCross"
				Case  "7" : key = "FindCrossSymbol"
				Case  "8" : key = "ListFiles"
			End Select
		End If
		echo_line

		If StrComp( key, "CheckOut", 1 ) = 0 Then
			project_name = sync.InputProject( "取り出すプロジェクトの番号または名前またはALL>", sync.c.RegularCommit )
			If StrComp( project_name, "ALL", 1 ) <> 0 Then
				recent_revision_name = sync.GetRecentProjectRevisionName( project_name )
				If recent_revision_name <> "" Then
					echo  ""
					echo  "Enter のみ：最新のリビジョン："+ recent_revision_name
				Else
					Raise  1, "１つもコミットがありません。"
				End If
				revision_name = Input( "取り出すリビジョン名>" )
				If revision_name = "" Then _
					revision_name = recent_revision_name

				out_path = sync.InputProjectOutput( project_name, revision_name, "CheckOut" )
				echo  ""
				w_=Empty : Set w_=AppKey.NewWritable( Array( sync.MastersPath, out_path ) ).Enable()
				echo_line
				sync.CheckOut  project_name, revision_name, out_path
			Else
				out_path = sync.InputProjectOutput( "ALL_Projects", "", "CheckOut" )
				echo  ""
				w_=Empty : Set w_=AppKey.NewWritable( Array( sync.MastersPath, out_path ) ).Enable()
				echo_line
				sync.CheckOut  "ALL", "Newest", out_path
			End If
			If not ArgumentExist( "silent" ) Then
				Sleep  300
				OpenFolder  out_path
			End If

			echo  ""
			echo  "チェックアウトしました。"
			Sleep  messaging_time_msec

		ElseIf StrComp( key, "Make", 1 ) = 0 Then
			echo  "★メイク ツリーの表示は一部不完全です。コマンドの実行には不具合があります。"
			Pause
			project_name = sync.InputProject( "メイクするプロジェクトの番号または名前またはALL>", sync.c.RegularCommit )
			revision_name = sync.InputProjectRevisionName( project_name, "メイクするリビジョン名>", c.AllowEnterOnly )
			If revision_name = "" Then
				target_path = sync.ProjectCachePath +"\"+ project_name
			Else
				target_path = sync.ProjectCachePath +"\"+ project_name +"\"+ revision_name
			End If
			w_=Empty : Set w_=AppKey.NewWritable( Array( sync.MastersPath ) ).Enable()
			echo  ""
			sync.RunMakeCUI  target_path

		ElseIf StrComp( key, "CheckOutAndUpdate", 1 ) = 0 Then
			echo  ""
			echo  "チェックアウトしてから最新モジュールに更新します。"
			echo  "ただし、ここで最新にしても、別途 Synchronize コマンドで"
			echo  "関連するモジュールを参考に最新にする必要があります。"
			echo  ""
			project_name = sync.InputProject( "取り出すプロジェクトの番号または名前>", Empty )
			out_path = sync.InputProjectOutput( project_name, "", "CheckOutAndUpdate" )
			echo_line
			w_=Empty : Set w_=AppKey.NewWritable( Array( sync.MastersPath, out_path ) ).Enable()
			Set updater = sync.GetUpdatingProject( project_name, out_path )

			sync.CheckOutAndUpdateUI  updater

			If not ArgumentExist( "silent" ) Then
				Sleep  300
				OpenFolder  out_path
			End If

			echo  ""
			echo  "チェックアウトとアップデートをしました。"
			Sleep  messaging_time_msec

		ElseIf StrComp( key, "FragmentProject", 1 ) = 0 Then
			echo_line
			project_name = sync.InputProject( "断片化するモジュールを持つプロジェクトの番号または名前>", Empty )
			echo  ""
			recent_revision_name = sync.GetRecentProjectRevisionName( project_name )
			If recent_revision_name = "" Then
				echo  "リビジョンがありません。"
			Else
				echo  "最近のリビジョン："+ recent_revision_name
				revision_name = Input( "断片化するリビジョン名>" )
				echo_line
				w_=Empty : Set w_=AppKey.NewWritable( sync.MastersPath ).Enable()
				sync.FragmentProject  project_name, revision_name
				echo  ""
				echo  "断片化しました。"
				Sleep  messaging_time_msec
			End If

		ElseIf StrComp( key, "FindProject", 1 ) = 0 Then
			echo_line
			echo  "モジュールを使っているプロジェクトを列挙します。"
			echo  ""
			echo  "例：ModuleA\TargetA\01"

			start_in_path_back_up = g_start_in_path
			g_start_in_path = sync.MastersPath
			revision_path = InputPath( "モジュールのリビジョンのパス>", c.CheckFolderExists )
			revision_path = GetStepPath( revision_path, sync.MastersPath )
			g_start_in_path = start_in_path_back_up

			project_revision_names = sync.FindProject( revision_path,  False,  found_path ) '//[out]found_path

			If found_path <> revision_path Then
				If IsEmpty( found_path ) Then
					echo  revision_path +" を使っているプロジェクトはありません。"
				Else
					echo  revision_path +" を使っているプロジェクトはありません。 しかし、"
					echo  found_path +" を使っているプロジェクトが見つかりました。"
				End If
			End If

			For Each  name  In  project_revision_names
				project_name = g_fs.GetParentFolderName( name )
				revision = g_fs.GetFileName( name )
				newest_revision = sync.Projects( project_name ).RecentRevisionName

				If revision = newest_revision Then
					echo  name
				Else
					echo  name +" -> "+ newest_revision
				End If
			Next
			echo  ""

		ElseIf StrComp( key, "ListFiles", 1 ) = 0 Then
			echo_line
			echo  "ファイルの一覧をファイルに出力します。"
			echo  ""
			project_name = sync.InputProject( "プロジェクトの番号または名前またはALL>", Empty )
			echo  ""
			echo  "Enter のみ： Newest"
			revision_name = Input( "リビジョン名>" )
			echo  ""

			If exist( GetFullPath( "Projects_Files.xml", sync.MastersPath ) ) Then
				str = "（★上書きします）"
			Else
				str = ""
			End If

			echo  "Enter のみ： マスターズ フォルダーの Projects_Files.xml"+ str

			out_path = InputPath( "出力ファイル（★上書きします）>",  c.AllowEnterOnly )
			If out_path = "" Then _
				out_path = Empty

			w_=Empty : Set w_=AppKey.NewWritable( Array( sync.MastersPath,  out_path ) ).Enable()
			sync.ListFiles  project_name,  revision_name,  out_path
			echo  ""
			echo  "出力しました。"
			Sleep  messaging_time_msec

		ElseIf StrComp( key, "FindCross", 1 ) = 0 Then

			out_path = sync.MastersPath +"\_Cross.txt"
			w_=Empty : Set w_=AppKey.NewWritable( Array( out_path ) ).Enable()

			sync.FindCross  Empty
			If not ArgumentExist( "silent" ) Then _
				start  GetEditorCmdLine( out_path )
			echo  ""
			echo  "出力しました。"
			Sleep  messaging_time_msec

		ElseIf StrComp( key, "FindCrossSymbol", 1 ) = 0 Then

			out_path = sync.MastersPath +"\_CrossSymbol.txt"
			w_=Empty : Set w_=AppKey.NewWritable( Array( out_path,  sync.MastersPath +"\_txsc" ) ).Enable()

			sync.FindCrossSymbol  Array( "Global" ),  Empty
			If not ArgumentExist( "silent" ) Then _
				start  GetEditorCmdLine( out_path )
			echo  ""
			echo  "出力しました。"
			Sleep  messaging_time_msec

		End If
	End If

	If ArgumentExist( "pause" ) Then _
		Pause
End Sub


Sub  ModuleAssort_doSynchronize_Sub( AppKey, sync, work_path )
	Set c = g_VBS_Lib

	echo  ""
	echo  "２つのターゲット モジュールを、関係を維持しつつ、新しいリビジョンに更新します。"
	echo  "ただし、ここで更新しても、別途 CheckOutAndUpdate コマンドで最新にする必要があります。"
	echo  "以下は、.moas ファイルに記述された <Synchronized> タグ（a属性と b属性付き）で一度に入力することもできます。"

	g_start_in_path = sync.MastersPath

	Do
		path_2A = Trim( Input( "2A ：新規に同期する/前回同期済みの片方のリビジョンのフォルダーのパス >" ) )
		If Left( path_2A, 1 ) = "<" Then
			If Right( path_2A, 1 ) <> ">" Then
				echo  "> で閉じるまで入力してください。"
			Else
				If Right( path_2A, 2 ) <> "/>" Then _
					path_2A = Left( path_2A, Len( path_2A ) - 1 ) + "/>"

				Set root = LoadXML( path_2A, c.StringData )
				path_2A = GetFullPath( root.getAttribute( "a" ),  g_start_in_path )
				path_2B = GetFullPath( root.getAttribute( "b" ),  g_start_in_path )
				Exit Do
			End If
		Else
			path_2A = GetFullPath( path_2A,  g_start_in_path )
			If g_fs.FolderExists( path_2A ) Then
				Exit Do
			End If
			echo  "見つかりません"
		End If
	Loop

	If IsEmpty( path_2B ) Then
		path_2B = InputPath( "2B ：新規に同期する/前回同期済みのもう片方のリビジョンのフォルダーのパス >", _
			c.CheckFolderExists )
		echo  ""
		echo  "Enter のみ：最新リビジョン"
		name_1A = Input( "1A ：2A の最新リビジョン名 >" )
		echo  ""
		echo  "Enter のみ：最新リビジョン"
		name_1B = Input( "1B ：2B の最新リビジョン名 >" )
	End If


	'// ...
	setting_xml = sync.GetSyncFilesX_SubSetting( path_2A, path_2B, name_1A, name_1B )

	echo_line
	echo  setting_xml

	Set root = LoadXML( setting_xml, c.StringData )
	path_1A = root.selectSingleNode( "./SynchronizingSet/@path" ).nodeValue
	path_1B = root.selectSingleNode( "./SynchronizingSet/@base" ).nodeValue
	path_1A = GetFullPath( path_1A, sync.MastersPath )
	path_1B = GetFullPath( path_1B, sync.MastersPath )

	base_name = root.selectSingleNode( "./SynchronizingSet/@base_name" ).nodeValue
	work_name = root.selectSingleNode( "./SynchronizingSet/@work_name" ).nodeValue
	base_name = Replace( base_name, "\", "_" )
	work_name = Replace( work_name, "\", "_" )
If path_1A <> path_1B Then
	name_of_1A = "1A_New_"+ work_name
	name_of_1B = "1B_New_"+ base_name
	name_of_2A = "2A_Synchronized_"+ work_name
	name_of_2B = "2B_Synchronized_"+ base_name
Else
	name_of_1A = "1_New_"+ work_name
	name_of_1B = name_of_1A
	name_of_2A = "2_Synchronized_"+ work_name
	name_of_2B = name_of_2A
End If

	XmlWrite  root, "./SynchronizingSet/@path", GetStepPath( work_path +"\"+ name_of_1A,  work_path )
	XmlWrite  root, "./SynchronizingSet/@base", GetStepPath( work_path +"\"+ name_of_1B,  work_path )
	XmlWrite  root, "./SynchronizingSet/@synced_path", GetStepPath( work_path +"\"+ name_of_2A,  work_path )
	XmlWrite  root, "./SynchronizingSet/@synced_base", GetStepPath( work_path +"\"+ name_of_2B,  work_path )

	setting_xml = root.xml


	echo_line
	echo  "1A_New:"
	echo  "    """+ path_1A +""""
	echo  ""
	echo  "1B_New:"
	echo  "    """+ path_1B +""""
	echo  ""
	echo  "2A_Synchronized:"
	echo  "    """+ path_2A +""""
	echo  ""
	echo  "2B_Synchronized:"
	echo  "    """+ path_2B +""""
	echo_line


	'// Delete "work_path" folder
	If exist( work_path ) Then
		echo  ""
		key = Input( "前回の作業フォルダー (desktop\"+ g_fs.GetFileName( work_path ) +") を削除します。 "+ _
			"よろしいですか (y/n)" )
		If key <> "y"  and  key <> "Y" Then  Error
	End If

	del  work_path


	'// Set "line_num_in_setting" folder
	If sync.SynchronizeRevisionGraphDictionary.Exists( GetStepPath( path_2A, sync.MastersPath ) )  and _
			sync.SynchronizeRevisionGraphDictionary.Exists( GetStepPath( path_2B, sync.MastersPath ) ) Then
		Set vertex_0 = sync.SynchronizeRevisionGraphDictionary( GetStepPath( path_2A, sync.MastersPath ) )
		Set vertex_1 = sync.SynchronizeRevisionGraphDictionary( GetStepPath( path_2B, sync.MastersPath ) )
		Set edge = GetNDEdgeInGraph( sync.SynchronizeRevisionGraph,  vertex_0.Index,  vertex_1.Index,  Nothing )
		line_num_in_setting = edge.LineNumInXML
	Else
		line_num_in_setting = "Unknown"
	End If


	'// Make "work_path" folder
If path_1A <> path_1B Then
	sync.LoadAndScanHashCache
	sync.CheckOutOneModule  path_1A,  work_path +"\"+ name_of_1A
	sync.CheckOutOneModule  path_1B,  work_path +"\"+ name_of_1B
	If path_1A <> path_2A  or  path_1B <> path_2B Then
		is_new = False
	ElseIf  sync.GetRecentRevisionName( g_fs.GetParentFolderName( path_1A ) ) <> g_fs.GetFileName( path_1A )  or _
			sync.GetRecentRevisionName( g_fs.GetParentFolderName( path_2A ) ) <> g_fs.GetFileName( path_2A ) Then
		is_new = False
	Else
		is_new = True
	End If

	If is_new Then
		mkdir  work_path +"\"+ name_of_2A
		mkdir  work_path +"\"+ name_of_2B
	Else
		sync.CheckOutOneModule  path_2A,  work_path +"\"+ name_of_2A
		sync.CheckOutOneModule  path_2B,  work_path +"\"+ name_of_2B
	End If

	copy  work_path +"\"+ name_of_1A +"\*", work_path +"\Before\"+ name_of_1A
	copy  work_path +"\"+ name_of_1B +"\*", work_path +"\Before\"+ name_of_1B
	copy  work_path +"\"+ name_of_2A +"\*", work_path +"\Before\"+ name_of_2A
	copy  work_path +"\"+ name_of_2B +"\*", work_path +"\Before\"+ name_of_2B

	CreateFile  work_path +"\README.txt", _
		" == Synchronizing Files by ModuleAssort =="+ vbCRLF + _
		""+ vbCRLF + _
		"- 1A_New          : """+ path_1A + """"+ vbCRLF + _
		"- 1B_New          : """+ path_1B + """"+ vbCRLF + _
		"- 2A_Synchronized : """+ path_2A + """"+ vbCRLF + _
		"- 2B_Synchronized : """+ path_2B + """"+ vbCRLF + _
		""+ vbCRLF + _
		"Synchronized folder has old synchronized files and new synchronized files."+ vbCRLF + _
		"Line number of .moas file: "+ line_num_in_setting + vbCRLF

	SetFilesToNotReadOnly  g_fs.GetFolder( work_path +"\"+ name_of_1A )
	SetFilesToNotReadOnly  g_fs.GetFolder( work_path +"\"+ name_of_1B )
	SetFilesToNotReadOnly  g_fs.GetFolder( work_path +"\"+ name_of_2A )
	SetFilesToNotReadOnly  g_fs.GetFolder( work_path +"\"+ name_of_2B )
Else
	sync.LoadAndScanHashCache
	sync.CheckOutOneModule  path_1A,  work_path +"\"+ name_of_1A
	If path_1A <> path_2A Then
		is_new = False
	ElseIf  sync.GetRecentRevisionName( g_fs.GetParentFolderName( path_1A ) ) <> g_fs.GetFileName( path_1A ) Then
		is_new = False
	Else
		is_new = True
	End If

	If is_new Then
		mkdir  work_path +"\"+ name_of_2A
	Else
		sync.CheckOutOneModule  path_2A,  work_path +"\"+ name_of_2A
	End If

	copy  work_path +"\"+ name_of_1A +"\*", work_path +"\Before\"+ name_of_1A
	copy  work_path +"\"+ name_of_2A +"\*", work_path +"\Before\"+ name_of_2A

	CreateFile  work_path +"\README.txt", _
		" == Synchronizing Files by ModuleAssort =="+ vbCRLF + _
		""+ vbCRLF + _
		"- 1A_New          : """+ path_1A + """"+ vbCRLF + _
		"- 2A_Synchronized : """+ path_2A + """"+ vbCRLF + _
		""+ vbCRLF + _
		"Synchronized folder has old synchronized files and new synchronized files."+ vbCRLF + _
		"Line number of .moas file: "+ line_num_in_setting + vbCRLF

	SetFilesToNotReadOnly  g_fs.GetFolder( work_path +"\"+ name_of_1A )
	SetFilesToNotReadOnly  g_fs.GetFolder( work_path +"\"+ name_of_2A )
End If


	'// Call "SyncFilesX"
	path = work_path +"\SyncFilesX_Setting.vbs"
	Set file = OpenForWrite( path, c.Unicode )
	file.WriteLine  "'------------------------------------------------------------[FileInScript.xml]"
	file.Write  "'"+ Replace( setting_xml, vbCRLF, vbCRLF +"'" ) + vbCRLF
	file.WriteLine  "'-----------------------------------------------------------[/FileInScript.xml]"
	file.WriteLine  ""
	file.WriteLine  "Sub  Main( Opt, AppKey )"
	file.WriteLine  vbTab +"SyncFilesX_App  AppKey, new_FilePathForFileInScript( Empty )"
	file.WriteLine  "End Sub"
	file.WriteLine  ""
	file.WriteLine  ""
	file.WriteLine  " "
	WriteVBSLibFooter  file, Empty
	file = Empty

	copy  g_vbslib_folder +"*", work_path +"\scriptlib"

	Set sync_x = new SyncFilesX_Class
	Do
		sync_x.LoadScanListUpAll  GetFilePathString( path ), ReadFile( new_FilePathForFileInScript( _
			path +"#FileInScript.xml") )
		w_ = Empty : Set w_=AppKey.NewWritable( sync_x.GetWritableFolders() ).Enable()
		result = sync_x.OpenCUI()

		If result = "Exit" Then  Exit Do
	Loop


	'// ...
	If IsSameFolder( work_path +"\"+ name_of_1A,  work_path +"\Before\"+ name_of_1A,  Empty ) Then
		If path_1A = path_2A Then
			state_of_1A = "（変更なし）"
		Else
			state_of_1A = "（最新リビジョンで確認完了）"
		End If
	Else
		state_of_1A = "（★変更あり）"
	End If

If path_1A <> path_1B Then
	If IsSameFolder( work_path +"\"+ name_of_1B,  work_path +"\Before\"+ name_of_1B,  Empty ) Then
		If path_1B = path_2B Then
			state_of_1B = "（変更なし）"
		Else
			state_of_1B = "（最新リビジョンで確認完了）"
		End If
	Else
		state_of_1B = "（★変更あり）"
	End If
End If


	echo  ""
	echo  "同期が完了したら、その内容をマスターに反映させてください。"
	echo  "1A_New："+ state_of_1A
If path_1A <> path_1B Then
	echo  "1B_New："+ state_of_1B
End If


	'// Copy to return
If path_1A <> path_1B Then
	revision_table = DicTable( Array( _
		"name",      "state",     "source",   Empty, _
		name_of_1A,  state_of_1A,  path_1A, _
		name_of_1B,  state_of_1B,  path_1B ) )
Else
	revision_table = DicTable( Array( _
		"name",      "state",     "source",   Empty, _
		name_of_1A,  state_of_1A,  path_1A ) )
End If
	For Each  t  In  revision_table
		newest_revision_name = sync.GetRecentRevisionName2( g_fs.GetParentFolderName( t("source") ) )
		If t("state") = "（★変更あり）" Then
			t("next_source_path") = g_fs.GetParentFolderName( t("source") ) +"\"+ _
				sync.GetNextRevisionFolderName( newest_revision_name, "_Tmp" )
		Else
			t("next_source_path") = g_fs.GetParentFolderName( t("source") ) +"\"+ _
				newest_revision_name
		End If
	Next
	If not ArgumentExist( "no_return" ) Then
		For Each  t  In  revision_table
			If t("state") = "（★変更あり）" Then
				echo  ""
				echo  t("name") +" のコピー先："""+ t("next_source_path") +""""
				key = Input( "更新したフォルダーを上記のフォルダーにコピーしますか。[Y/N]" )
				If key = "y"  or  key = "Y" Then
					Assert  not exist( t("next_source_path") )
					w_ = Empty : Set w_=AppKey.NewWritable( t("next_source_path") ).Enable()
					copy  work_path +"\"+ t("name") +"\*",  t("next_source_path")
				End If
			End If
		Next
	End If


	'// Echo updated <Synchronized>
If path_1A = path_1B Then
	next_source_path = revision_table(0)("next_source_path")  '// For avoiding locked error

	revision_table = DicTable( Array( _
		"name",      "state",     "source",  "next_source_path",  Empty, _
		name_of_1A,  state_of_1A,  path_1A,  next_source_path, _
		name_of_1B,  state_of_1B,  path_1B,  next_source_path ) )
End If
	If revision_table(0)("state") <> "（変更なし）"  or  revision_table(1)("state") <> "（変更なし）" Then
		revision_step_path_0 = GetStepPath( revision_table(0)("next_source_path"), sync.MastersPath )
		revision_step_path_1 = GetStepPath( revision_table(1)("next_source_path"), sync.MastersPath )

		Set vertex_0 = sync.SynchronizeRevisionGraphDictionary( GetStepPath( path_2A, sync.MastersPath ) )
		Set vertex_1 = sync.SynchronizeRevisionGraphDictionary( GetStepPath( path_2B, sync.MastersPath ) )
		Set edge = GetNDEdgeInGraph( sync.SynchronizeRevisionGraph,  vertex_0.Index,  vertex_1.Index,  Nothing )

		echo  ""
		text = "次のような XML タグ（子ノードや一部の属性は省略されています）を、"+ _
			"ModuleAssort の設定ファイル(.moas)に追加してください。"+ vbCRLF + _
			"<Synchronized  line_num="""+ edge.LineNumInXML + _
			"""  a="""+ revision_step_path_0 + _
			"""  b="""+ revision_step_path_1 +"""/>" + vbCRLF
		echo  text

		Set ec = new EchoOff
		path = work_path +"\NextXML.txt"
		w_ = Empty : Set w_=AppKey.NewWritable( path ).Enable()
		CreateFile  path, text
		ec = Empty
	End If


	If ArgumentExist( "pause" ) Then _
		Pause
End Sub


 
'***********************************************************************
'* Function: NaturalDocs_sth
'***********************************************************************
Sub  NaturalDocs_sth( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  "ソースファイルにある NaturalDocs 形式コメントを HTML に変換します。"
	source_path = InputPath( "ソースファイルがあるフォルダーのパス>", c.CheckFolderExists )
	destination_path = InputPath( "HTML を格納するフォルダーのパス（★上書きします）>", 0 )

	Set w_=AppKey.NewWritable( destination_path ).Enable()
	MakeDocumentByNaturalDocs  source_path, destination_path, Empty
	If not ArgumentExist( "silent" ) Then
		start  """"+ GetPathWithSeparator( destination_path ) +"index.html"""
	End If
End Sub


 
'***********************************************************************
'* Function: OpenByStepPath
'***********************************************************************
Sub  OpenByStepPath( Opt, AppKey )
	Set c = g_VBS_Lib
	Set fin = new FinObj : fin.SetFunc "OpenByStepPath_Finally"
	fin.SetVar "g_start_in_path", g_start_in_path

	echo  "相対パスを指定して、ファイルやフォルダーを開きます。（絶対パスも可）"

	Do
		base_path = InputPath( "基準パス >",  c.AllowEnterOnly )
		If base_path = "" Then _
			Exit Do
		Assert  IsFullPath( base_path )
		g_start_in_path = base_path
		echo  ""
		echo  "Enterのみ: 基準パスの入力へ"

		Do
			full_path = InputPath( "ファイルのパス >", _
				c.CheckFileExists or c.CheckFolderExists or c.AllowEnterOnly )
			If full_path = "" Then _
				Exit Do

			Set jumps = GetTagJumpParams( full_path )
			If IsEmpty( jumps.Keyword ) and IsEmpty( jumps.LineNum ) Then
				start  """"+ full_path +""""
			Else
				start  GetEditorCmdLine( full_path )
			End If
		Loop
		echo  ""
	Loop
End Sub
 Sub  OpenByStepPath_Finally( Vars )
	en = Err.Number : ed = Err.Description : On Error Resume Next
	g_start_in_path = Vars.Item("g_start_in_path")
	ErrorCheckInTerminate  en : On Error GoTo 0 : If en <> 0 Then  Err.Raise en,,ed
End Sub


 
'***********************************************************************
'* Function: OpenFolder
'***********************************************************************
Sub  OpenFolder( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  "ファイルのパスを入力すると、そのファイルを含むフォルダーを開きます。"
	path = InputPath( "ファイルのパス >", c.CheckFileExists or c.CheckFolderExists )
	OpenFolder  path
End Sub


 
'***********************************************************************
'* Function: OpenSendTo_sth
'***********************************************************************
Sub  OpenSendTo_sth( Opt, AppKey )
	OpenFolder  g_sh.SpecialFolders( "SendTo" )
End Sub


 
'***********************************************************************
'* Function: OpenStartUp_sth
'***********************************************************************
Sub  OpenStartUp_sth( Opt, AppKey )
	echo  "1) CurrentUser"
	echo  "2) AllUsers"
	key = input( "Input number>" )
	If key = "2" Then
		OpenFolder  g_sh.SpecialFolders( "AllUsersStartup" )
	Else
		OpenFolder  g_sh.SpecialFolders( "Startup" )
	End If
End Sub


 
'***********************************************************************
'* Function: OpenShorHandLibHelpSVG
'***********************************************************************
Sub  OpenShorHandLibHelpSVG( Opt, AppKey )
	start  "_src\vbslib.svg"
End Sub


 
'***********************************************************************
'* Function: OpenShorHandLibHelpHtml
'***********************************************************************
Sub  OpenShorHandLibHelpHtml( Opt, AppKey )
	start  g_sh.ExpandEnvironmentStrings( _
	 """%ProgramFiles%\Internet Explorer\iexplore.exe"" """+ g_sh.CurrentDirectory +_
	 "\_src\_vbslib manual.files\vbslib.html""" )
End Sub


 
'***********************************************************************
'* Function: OpenShorHandPromptSrc
'***********************************************************************
Sub  OpenShorHandPromptSrc( Opt, AppKey )
	start  GetEditorCmdLine( WScript.ScriptFullName )
End Sub


 
'***********************************************************************
'* Function: OpenTask
'***********************************************************************
Sub  OpenTask( Opt, AppKey )
	echo  ">OpenTask"
	Dim  ec : Set ec = new EchoOff
	If GetOSVersion() <= 5.1 Then
		start  "explorer  ::{D6277990-4C6A-11CF-8D87-00AA0060F5BF}"
	Else
		start  "taskschd.msc /s"
	End If
End Sub


 
'***********************************************************************
'* Function: OpenTestTemplate
'***********************************************************************
Sub  OpenTestTemplate( Opt, AppKey )
	OpenFolder  "samples\Test"
	WScript.Quit  E_TestPass
End Sub


 
'***********************************************************************
'* Function: OpenTemp
'***********************************************************************
Sub  OpenTemp( Opt, AppKey )
	path = GetTempPath( "." )
	OpenFolder  path
	WScript.Quit  E_TestPass
End Sub


 
'***********************************************************************
'* Function: OpenVbsLib
'***********************************************************************
Sub  OpenVbsLib( Opt, AppKey )
	OpenFolder  "."
	WScript.Quit  E_TestPass
End Sub


 
'***********************************************************************
'* Function: OpenVBSLibSource
'***********************************************************************
Sub  OpenVBSLibSource( Opt, AppKey )
	echo  "Visual Studio で表示されている WSH (VBScript) のソースを"+ _
		"テキスト エディターで開きます。"
	echo  ""
	echo  "Visual Studio で表示されている行番号を記憶してください。"
	echo  ""
	key = Input( "Visual Studio で表示されているソース ファイルの内容を"+_
		"すべて選択してクリップボードにコピーしたら、"+_
		"Enter を押してください。 " )
	echo  ""
	source_code = GetTextFromClipboard()
	line_count = GetLineCount( source_code, Empty )

	Do
	    do_it = True

		target_line_num = CInt2( Input( "記憶した行番号 (1.."+ CStr( line_count ) +") >" ) )
		If target_line_num = 0 Then _
			Exit Do

		Set re = new_RegExp( "^'// g_SrcPath=""([^"")]+)", False )
		Set matches = re.Execute( source_code )
		Set counter = new LineNumFromTextPositionClass
		counter.Text = source_code
		previous_line_num = 0
		For Each  match  In  matches

			current_line_num = counter.GetNextLineNum( match.FirstIndex + 1 )
			If target_line_num <= current_line_num Then _
				Exit For

			previous_path = match.SubMatches(0)
			previous_line_num = current_line_num
		Next
		If target_line_num > line_count Then _
			do_it = False

		If do_it Then
			If previous_line_num = 1 Then
				opening_line_num = target_line_num
			Else
				opening_line_num = target_line_num - previous_line_num
			End If
			opening_path = GetFullPath( previous_path,  g_vbslib_folder )


			start  GetEditorCmdLine( opening_path +"("+ CStr( opening_line_num ) +")" )
		End If
	Loop
End Sub


 
'***********************************************************************
'* Function: PickUpCopy_sth
'***********************************************************************
Sub  PickUpCopy_sth( Opt, AppKey )
	Set c = g_VBS_Lib

	echo  "フォルダーの一部をコピーします。"
	echo  ""
	xml_path = InputPath( "PickUpCopy タグがある XML ファイルのパス >", c.CheckFileExists )

	Set copy_ = OpenPickUpCopy( xml_path )
	If IsEmpty( copy_.GetDefaultSourcePath() ) Then
		source_path = InputPath( "コピー元フォルダーのパス >", c.CheckFolderExists )
	Else
		source_path = Empty
	End If
	destination_path = copy_.GetDefaultDestinationPath( source_path )

	If exist( destination_path ) Then
		message2 = "（★上書きします）"
	Else
		message2 = ""
	End If

	echo  ""
	echo  destination_path
	echo  "上記のフォルダーに出力します。"+ message2
	Pause

	Set w_= AppKey.NewWritable( destination_path ).Enable()

	If exist( destination_path ) Then
		echo  "削除中..."
		Set ec = new EchoOff
		del  destination_path
		ec = Empty
	End If

	echo  "抽出コピー中..."
	Set ec = new EchoOff
	copy_.Copy  source_path,  Empty,  Empty
	ec = Empty

	echo  "抽出コピーをしました。"
End Sub


 
'***********************************************************************
'* Function: Prompt_sth
'***********************************************************************
Sub  Prompt_sth( Opt, AppKey )
	Prompt
End Sub


 
'***********************************************************************
'* Function: CreateFromTextSections_sth
'***********************************************************************
Sub  CreateFromTextSections_sth( Opt, AppKey )
	Set c = g_VBS_Lib

	echo  "セクション化されたテキストを集めます。"
	echo  ""
	xml_path = InputPath( "MixedText タグがある XML ファイルのパス >", c.CheckFileExists )

	echo  ""
	echo  "Enter のみ：CreateFile タグに記述されたすべてのファイル"
	attribute = Input( "MixedText の id 属性 >" )

	If attribute = "" Then
		Set xml_root = LoadXML( xml_path, Empty )
		xml_folder_path = GetParentFullPath( xml_path )
		Set out_paths = new ArrayClass

		echo  ""
		For Each  create_file_tag  In  xml_root.selectNodes( "./CreateFile" )
			out_path = GetFullPath( create_file_tag.getAttribute( "path" ), xml_folder_path )
			If exist( out_path ) Then _
				echo  out_path
			out_paths.Add  out_path
		Next
		echo  "以上のファイルを上書きします。"
		Set w_= AppKey.NewWritable( out_paths ).Enable()
		echo  "セクション化されたテキストを集めます。"
		Pause

		CreateFromTextSections  xml_path, xml_root, Empty, Empty, Empty
	Else
		out_path  = Input( "集めたテキストの出力ファイルのパス（★上書きします）>" )
		Set w_= AppKey.NewWritable( out_path ).Enable()

		CreateFromTextSections  xml_path, Empty, out_path, xml_path +"#"+ attribute, Empty
	End If

	echo  "集めました。"
End Sub


 
'***********************************************************************
'* Function: RegExpTest
'***********************************************************************
Sub  RegExpTest( Opt, AppKey )

	echo  "正規表現でマッチするかどうかをテストします。"
	echo  "正規表現の メタ文字 一覧：. $ ^ { } [ ] ( ) | * + ? \"
	echo  "Enterのみ: 正規表現と対象文字列との入力を切り替え"
	echo  ""

	current_input = "expression"

	Do
		If current_input = "expression" Then
			key = Input( "正規表現>" )
			If key <> "" Then  expression = key
		Else
			key = Input( "対象文字列>" )
			If key <> "" Then  target = key
		End If

		If key = ""  or  expression = ""  or  target = "" Then
			If current_input = "expression" Then
				current_input = "target"
			Else
				current_input = "expression"
			End If
		Else
			Set re = CreateObject("VBScript.RegExp")
			re.Pattern = expression
			re.MultiLine = True
			Set matches = re.Execute( target )

			If matches.Count = 0 Then
				echo  "マッチしませんでした"
			Else
				For Each match  In matches
					echo  "マッチした位置 = "& match.FirstIndex
					echo  "マッチした文字数 = "& match.Length
					echo  "マッチした文字列 = "& match.Value
				Next
			End If
		End If
	Loop
End Sub


 
'***********************************************************************
'* Function: Python_sth
'***********************************************************************
Sub  Python_sth( Opt, AppKey )
	Set c = g_VBS_Lib
	python_exe = GetPythonInstallPath() +"\python.exe"
	script_path = InputPath( "実行する .py ファイルのパス >", c.CheckFileExists )
	RunProg  """"+ python_exe +""" """+ script_path +"""", ""
End Sub


 
'***********************************************************************
'* Function: ReadOnlyList_sth
'***********************************************************************
Sub  ReadOnlyList_sth( Opt, AppKey )
	Set c = g_VBS_Lib

	echo  "ファイルが読み取り専用かどうかを一覧します。"
	folder_path = InputPath( "調べるフォルダーのパス >", c.CheckFolderExists )

	read_only_count = GetReadOnlyList( folder_path,  read_onlys,  Empty )  '// Set "read_onlys"
	file_count = read_onlys.Count

	a_message = "読み取り専用のファイルの数＝"+ CStr( read_only_count ) +" / "+ CStr( file_count )
	file_path = GetTempPath( "ReadOnlyList.txt" )
	Set file = OpenForWrite( file_path,  c.UTF_8 )
	echo  a_message
	file.WriteLine  a_message

	For Each  step_path  In  read_onlys.Keys
		is_read_only = read_onlys( step_path )
		If is_read_only Then
			head_ = "R "
		Else
			head_ = "  "
		End If
		file.WriteLine  head_ + GetFullPath( step_path,  folder_path )
	Next
	file = Empty

	start  GetEditorCmdLine( file_path )
End Sub


 
'***********************************************************************
'* Function: Rename_sth
'***********************************************************************
Sub  Rename_sth( Opt, AppKey )
	Dim  m : Set m = new RenamerClass
	m.DoMode  AppKey
End Sub


 
'***********************************************************************
'* Function: ReplaceShortcutFilesToFiles_sth
'***********************************************************************
Sub  ReplaceShortcutFilesToFiles_sth( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  "ショートカット・ファイルを通常のファイルに変換します。"
	echo  "サブ フォルダーを含めて変換します。"
	path = InputPath( "変換するフォルダーのパス>", c.CheckFolderExists )
	Set w_= AppKey.NewWritable( path ).Enable()
	ReplaceShortcutFilesToFiles  path, Empty
End Sub


 
'***********************************************************************
'* Function: ReplaceSlash
'***********************************************************************
Sub  ReplaceSlash( Opt, AppKey )
	path = GetTextFromClipboard()
	If InStr( path, "\" ) >= 1 Then
		If Mid( path, 2, 2 ) = ":\" Then _
			path = "/mnt/"+ LCase( Left( path, 1 ) ) + Mid( path, 3 )

		path = Replace( path, "\", "/" )
	Else
		If Left( path, 5 ) = "/mnt/" Then _
			path = UCase( Mid( path, 6, 1 ) ) +":"+ Mid( path, 7 )

		path = Replace( path, "/", "\" )
	End If
	SetTextToClipboard  path

	echo  "クリップボードにあるテキストの / と \ を置き換えました。"
End Sub


 
'***********************************************************************
'* Function: ReplaceSymbols
'***********************************************************************
Sub  ReplaceSymbols( Opt, AppKey )
	Set ds = new CurDirStack
	Set c = g_VBS_Lib

	path = InputPath( "ReplaceSymbols の設定ファイルのパス>", c.CheckFileExists )

	Set rep = new ReplaceSymbolsClass
	rep.Load  path, Empty

	pushd  GetParentFullPath( path )
	Set w_= AppKey.NewWritable( rep.TargetPaths.Items ).Enable()
	rep.ReplaceFiles
	popd
End Sub


 
'***********************************************************************
'* Class: RenamerClass
'***********************************************************************
Class  RenamerClass
	Public  OperationHistory
	Public  FolderPathHistory
	Public  AddNameHistory

 
'***********************************************************************
'* Function: RenamerClass::DoMode
'***********************************************************************
Public Sub  DoMode( AppKey )
	Set c = g_VBS_Lib

	Do
		echo "--------------------------------------------------------"
		echo "1. ファイル名の先頭に追加する"
		echo "2. ファイル名の先頭を変更する"
		echo "3. ファイル名の先頭数文字を削除する"
		echo "4. ファイル名の末尾数文字を削除する"
		echo "9. 終了する"
		If not IsEmpty( Me.OperationHistory ) Then  echo "if Enter only: " & Me.OperationHistory
		op = CInt2( input( "番号を入力してください>" ) )
		echo "--------------------------------------------------------"
		If op = 0 Then  op = Me.OperationHistory : echo op  Else  Me.OperationHistory = op

		If op <= 7 Then
			If not IsEmpty( Me.FolderPathHistory ) Then  echo "if Enter only: " & Me.FolderPathHistory
			path = InputPath( "処理を行うフォルダーのパス>", c.CheckFolderExists or c.AllowEnterOnly )
			If path = "" Then  path = Me.FolderPathHistory : echo path  Else  Me.FolderPathHistory = path
			Set w_=AppKey.NewWritable( path ).Enable()
		End If

		Select Case op
			Case 1:  Me.AddHeadOfFName  path, Empty
			Case 2:  Me.RenameHeadOfFName  path, Empty, Empty
			Case 3:  Me.DeleteHeadOfFName  path, Empty
			Case 4:  Me.DeleteTailOfFName  path, Empty
			Case 9:  Exit Do
		End Select
		w_ = Empty
	Loop
End Sub

 
'***********************************************************************
'* Function: RenamerClass::AddHeadOfFName
'***********************************************************************
Public Sub  AddHeadOfFName( FolderPath, ByVal AddName )
	Dim  b
 Do
	echo  ">AddHeadOfFName"
	If not g_fs.FolderExists( FolderPath ) Then  Err.Raise 1,,"フォルダがありません："+ FolderPath

	If IsEmpty( AddName ) Then
		If not IsEmpty( Me.AddNameHistory ) Then  echo "if Enter only: " & Me.AddNameHistory
		AddName = input( "最初に追加する名前>" )
		If AddName = "" Then  AddName = Me.AddNameHistory : echo AddName  Else  Me.AddNameHistory = AddName
	End If

	echo  "下記のフォルダにあるファイルのすべてのファイルの先頭に """ + AddName +_
		""" を追加します。"
	echo  FolderPath
	Dim key : key = input( "よろしいですか？[Y/N]" )
	If key<>"y" and key<>"Y" and key<>"" Then   Exit Sub  ' ... Cancel


	Dim  i, n_file, fo, f
	b = True

	'// src, dst を取得する。（fo.Files の For ループの中で改名するとおかしくなるため）
	Set fo = g_fs.GetFolder( FolderPath )
	n_file = fo.Files.Count
	Redim  src(n_file-1), dst(n_file-1)
	i = 0
	For Each f in fo.Files
		src(i) = f.Name
		dst(i) = AddName & f.Name
		If exist( FolderPath + "\" + dst(i) ) Then
			AddName = Empty
			b = False
			echo "重複しています: "+dst(i)
			Exit For
		End If
		i = i + 1
	Next
	If b Then Exit Do
 Loop

	'// 改名する
	For i=0 To n_file-1
		Set f = fo.Files.Item( CStr( src(i) ) )
		f.Name = dst(i)
	Next
End Sub



 
'***********************************************************************
'* Function: RenamerClass::RenameHeadOfFName
'***********************************************************************
Public Sub  RenameHeadOfFName( FolderPath, BeforeHeadName, AfterHeadName )
	Dim  b
 Do
	echo  ">RenameHeadOfFName"
	If not g_fs.FolderExists( FolderPath ) Then  Err.Raise 1,,"フォルダがありません："+FolderPath

	If IsEmpty( BeforeHeadName ) Then  BeforeHeadName = input( "置き換えるファイルの先頭の名前>" )
	If IsEmpty( AfterHeadName )  Then  AfterHeadName  = input( "置き換えた後のファイルの先頭の名前>" )
	echo  "下記のフォルダにある、名前の先頭が """ + BeforeHeadName + """ のファイルを、""" +_
				AfterHeadName + """ から始まる名前に変えます。"
	echo  FolderPath
	Dim key : key = input( "よろしいですか？[Y/N]" )
	If key<>"y" and key<>"Y" Then   Exit Sub  ' ... Cancel


	Dim  i, n_file, fo, f
	b = True

	'// src, dst を取得する。（fo.Files の For ループの中で改名するとおかしくなるため）
	Set fo = g_fs.GetFolder( FolderPath )
	n_file = fo.Files.Count
	Redim  src(n_file-1), dst(n_file-1)
	i = 0
	For Each f in fo.Files
		If Left( f.Name, Len(BeforeHeadName) ) = BeforeHeadName Then
			src(i) = f.Name
			dst(i) = AfterHeadName & Mid( f.Name, Len(BeforeHeadName) + 1 )
			If exist( FolderPath + "\" + dst(i) ) Then
				BeforeHeadName = Empty
				AfterHeadName = Empty
				b = False
				echo  "重複しています: "+dst(i)
				Exit For
			End If
			i = i + 1
		End If
	Next
	If b Then Exit Do
 Loop

	n_file = i


	'// 改名する
	For i=0 To n_file-1
		Set f = fo.Files.Item( CStr( src(i) ) )
		f.Name = dst(i)
	Next
End Sub

 
'***********************************************************************
'* Function: RenamerClass::DeleteHeadOfFName
'***********************************************************************
Public Sub  DeleteHeadOfFName( FolderPath, FirstDelCount )
	Dim  b,  file_names
	Set file_names = CreateObject( "Scripting.Dictionary" )
 Do
	echo  ">DeleteHeadOfFName"
	If not g_fs.FolderExists( FolderPath ) Then  Err.Raise 1,,"フォルダがありません："+FolderPath

	If IsEmpty( FirstDelCount ) Then  FirstDelCount = CInt2( input( "削除する先頭からの文字数>" ) )
	echo  "下記のフォルダにあるファイルの、先頭 " & FirstDelCount & " 文字を削除します。"
	echo  FolderPath
	Dim key : key = input( "よろしいですか？[Y/N]" )
	If key<>"y" and key<>"Y" Then   Exit Sub  ' ... Cancel


	Dim  i, n_file, fo, f
	b = True

	'// src, dst を取得する。（fo.Files の For ループの中で改名するとおかしくなるため）
	Set fo = g_fs.GetFolder( FolderPath )
	n_file = fo.Files.Count
	Redim  src(n_file-1), dst(n_file-1)
	file_names.RemoveAll
	i = 0
	For Each f in fo.Files
		src(i) = f.Name
		dst(i) = Mid( f.Name, FirstDelCount + 1 )

		If exist( FolderPath + "\" + dst(i) )  or _
		   file_names.Exists( dst(i) ) Then
			FirstDelCount = Empty
			b = False
			echo  "重複しています: "+dst(i)
			Exit For
		End If

		file_names( dst(i) ) = True
		i = i + 1
	Next
	If b Then Exit Do
 Loop

	'// 改名する
	For i=0 To n_file-1
		Set f = fo.Files.Item( CStr( src(i) ) )
		f.Name = dst(i)
	Next
End Sub

 
'***********************************************************************
'* Function: RenamerClass::DeleteTailOfFName
'***********************************************************************
Public Sub  DeleteTailOfFName( FolderPath, LastDelCount )
	Dim  b
	Set file_names = CreateObject( "Scripting.Dictionary" )
 Do
	echo  ">DeleteHeadOfFName"
	If not g_fs.FolderExists( FolderPath ) Then  Err.Raise 1,,"フォルダがありません："+FolderPath

	If IsEmpty( LastDelCount ) Then  LastDelCount = CInt2( input( "削除する末尾からの文字数>" ) )
	echo  "下記のフォルダにあるファイルの、末尾 " & LastDelCount & " 文字を削除します。"
	echo  FolderPath
	Dim key : key = input( "よろしいですか？[Y/N]" )
	If key<>"y" and key<>"Y" Then   Exit Sub  ' ... Cancel


	Dim  i, n_file, fo, f
	b = True

	'// src, dst を取得する。（fo.Files の For ループの中で改名するとおかしくなるため）
	Set fo = g_fs.GetFolder( FolderPath )
	n_file = fo.Files.Count
	Redim  src(n_file-1), dst(n_file-1)
	file_names.RemoveAll
	i = 0
	For Each f in fo.Files
		src(i) = f.Name

		If Len( g_fs.GetBaseName( f.Name ) ) <= LastDelCount Then
			echo "文字数が多すぎます: "+f.Name
			b = False
		End If

		If b Then
			dst(i) = Left( f.Name, Len( g_fs.GetBaseName( f.Name ) ) - LastDelCount ) + _
				"." + g_fs.GetExtensionName( f.Name )
		End If

		If exist( FolderPath + "\" + dst(i) )  or _
		   file_names.Exists( dst(i) ) Then
			echo "重複しています: "+dst(i)
			b = False
		End If
		If not b Then
			LastDelCount = Empty
			Exit For
		End If

		file_names( dst(i) ) = True
		i = i + 1
	Next
	If b Then Exit Do
 Loop

	'// 改名する
	For i=0 To n_file-1
		Set f = fo.Files.Item( CStr( src(i) ) )
		f.Name = dst(i)
	Next
End Sub

 
End Class 


 
'***********************************************************************
'* Function: RenumberIniFileDataInClipboard_sth
'***********************************************************************
Sub  RenumberIniFileDataInClipboard_sth( Opt, AppKey )
	Do
		RenumberIniFileDataInClipboard  Opt, AppKey
	Loop
End Sub


Sub  RenumberIniFileDataInClipboard( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  "クリップボードに入った、.ini ファイルの内容のうち、= より左にある ( ) の中の"+_
		"番号を振り直します。"

	echo  ""
	echo  "Enter のみ：1"
	key = Input( "開始番号>" )
	If key = "" Then  key = "1"
	number = CInt2( key )

	echo  ""
	echo  "Enter のみ：Y"
	key = Input( "空行があるときだけ番号を＋１しますか。[Y/N]" )
	is_plus_space_line_only = (key<>"n" and key<>"Y")

	Set read_file = new StringStream
	Set write_file = new StringStream

	read_file.SetString  GetTextFromClipboard()


	RenumberIniFileData  read_file, write_file, number, is_plus_space_line_only


	text = write_file.ReadAll()
	SetTextToClipboard  text

	echo_line
	echo  text
	echo_line
	echo  "上記の内容にクリップボードの内容を書き換えました。"
End Sub


 
'***********************************************************************
'* Function: SearchNewFile
'***********************************************************************
Sub  SearchNewFile( Opt, AppKey )
	Set c = g_VBS_Lib


	'[DefaultSetting]
	'==============================================================================
	limit_str_default = "-1day"
	except_path_default = "Samples\ExceptExtension.txt"
	'==============================================================================


	'//=== Input
	echo  "フォルダーの中から、指定した日時以降のファイルを検索します。"
	echo  ""

	echo  "日時の例：2008/06/11, 14:28:01, -1day, -2hours"
	echo  "Enter のみ："+ limit_str_default
	limit_str = Input( "日時 >" )
	If limit_str = "" Then  limit_str = limit_str_default
	Select Case  Left( limit_str, 1 )
		Case "+", "-" :  limit = DateAddStr( Now(), limit_str )
		Case Else : limit = CDate( limit_str )
	End Select
	echo  ""

	echo  "Enter のみ："+ except_path_default
	except_path = InputPath( "除外するファイルの拡張子が並べてあるファイル >",_
		c.CheckFileExists or c.AllowEnterOnly )
	If except_path = "" Then  except_path = except_path_default
	except_ext = ArrayFromCSV( ReadFile( except_path ) )
	echo  ""

	search_path = InputPath( "検索するフォルダー >", c.CheckFolderExists )
	echo  ""


	'//=== Write output header
	out_path = GetTempPath( "SearchNewFile_out.txt" )
	Set out = OpenForWrite( out_path, Empty )

	out.WriteLine  echo( "<SearchNewFile after='" & limit & "'"+ vbCRLF +" path='" & search_path & "'>" )
	For Each ext  In except_ext
		out.WriteLine  echo( "  <ExceptExt ext='" & ext & "'/>" )
	Next
	out.WriteLine  echo( "</SearchNewFile>" )

	EnumFolderObject  search_path, folders  '// [out] folders

	out.WriteLine  "<SearchNewFile_Out>"


	'//=== Search
	For Each fo  In folders
		For Each f  In fo.Files
			If f.DateLastModified >= limit Then
				For Each ext  In except_ext
					If Right( f.Name, Len( ext ) ) = ext Then  Exit For
				Next
				If IsEmpty( ext ) Then _
					out.WriteLine  "<File update='" & f.DateLastModified & "' path='" & f.Path & "'/>"
			End If
			n=n+1
		Next
	Next
	out.WriteLine  echo( "Checked " & n & " files" )
	out.WriteLine  "</SearchNewFile_Out>"
	out = Empty


	'//=== Open result
	If ArgumentExist( "out" ) Then
		out2_path = GetFullPath( WScript.Arguments.Named.Item("out"), g_start_in_path )
		Set w_=AppKey.NewWritable( out2_path ).Enable()
		copy_ren  out_path,  out2_path
	Else
		start  """" + out_path + """"
	End If
End Sub


 
'***********************************************************************
'* Function: SearchOpen
'***********************************************************************
Sub  SearchOpen( Opt, AppKey )
	Set c = g_VBS_Lib
	echo "[SearchOpen]"
	echo "指定のパスのテキストファイルを開いて、指定の行番号またはキーワードを検索します。"
	path = Input( "path>" )

	If LCase( Left( g_fs.GetExtensionName( path ), 3 ) ) = "pdf" Then
		start  """"+ env("%ProgramFiles%") +"\Internet Explorer\iexplore.exe"" """+ path +""""
	Else
		start  GetEditorCmdLine( path )
	End If
End Sub


 
'***********************************************************************
'* Function: SetTask
'***********************************************************************
Sub  SetTask( Opt, AppKey )
	echo  "タスクの開始時間を再設定します。"
	Dim  name : name = input( "タスク名（登録済みのもの）>" )
	echo  "例： 13:00 ... 今が午前10時なら、今日の午後1時に実行する"
	echo  "例：  1:00 ... 今が午前10時なら、明日の午前1時に実行する"
	echo  "例： +1:00 ... 今から1時間後に実行する"
	Dim  after : after = input( "いつ実行を開始しますか>" )
	SetTaskStartTime  name, after
End Sub


 
'***********************************************************************
'* Function: shutdown_sth
'***********************************************************************
Sub  shutdown_sth( Opt, AppKey )
	echo  "1) PowerOff : 電源を切る"
	echo  "2) Reboot : 再起動"
	echo  "3) Hibernate"
	echo  "4) Sleep : スリープ（コネクテッド・スタンバイは未対応）"
	echo  "5) Standby"
	key = input( "番号を入力してください >" )
	Select Case CInt( key )
		Case  1 : key = "PowerOff"
		Case  2 : key = "Reboot"
		Case  3 : key = "Hibernate"
		Case  4 : key = "Sleep"
		Case  5 : key = "Standby"
	End Select
	command = key

	echo  ""
	echo  "Enter のみ: すぐに実行する"
	key = input( "残り分数>" )
	If key = "" Then
		left_time = 0
	Else
		left_time = Eval( key ) * 60
	End If
	Shutdown  command, left_time
End Sub


 
'***********************************************************************
'* Function: SortLines_sth
'***********************************************************************
Sub  SortLines_sth( Opt, AppKey )
	Set c = g_VBS_Lib

	echo  "テキストファイルの内容を行単位でソート（整列）します。"
	input_path  = InputPath( "入力ファイルのパス >", c.CheckFileExists )
	output_path = InputPath( "出力ファイルのパス（★上書きします）>", Empty )

	echo  ""
	echo  "Enter のみ：残さない"
	is_duplicated = Input( "同じ内容の行をそのまま残しますか [Y/N]" )
	is_duplicated = ( is_duplicated = "Y"  or  is_duplicated = "y" )
	Set w_=AppKey.NewWritable( output_path ).Enable()

	lines = ReadFile( input_path )
	lines = SortStringLines( lines, is_duplicated )
	CreateFile  output_path, lines

	echo  "出力しました。"
End Sub


 
'***********************************************************************
'* Function: SpaceToTab_sth
'***********************************************************************
Sub  SpaceToTab_sth( Opt, AppKey )
	Set g = g_VBS_Lib

	SpaceToTabSub_sth  Opt, AppKey, Empty
End Sub


Sub  SpaceToTabSub_sth( Opt, AppKey, head_operation )
	Set g = g_VBS_Lib

	echo  "テキストファイルのタブ文字と空白文字を変換します。"
	If head_operation = "TabToSpace" Then
		echo  "1) 行頭のタブ文字→空白文字 [TabToSpace]"
		echo  ""
		enter_guide_t2s = "（←Enterのみのとき）"
		enter_guide_s2t = ""
	ElseIf head_operation = "SpaceToTab" Then
		echo  "2) 行頭の空白文字→タブ文字 [SpaceToTab]"
		echo  ""
		enter_guide_t2s = ""
		enter_guide_s2t = "（←Enterのみのとき）"
	Else
		echo  "1) 行頭のタブ文字→空白文字 [TabToSpace]"
		echo  "2) 行頭の空白文字→タブ文字 [SpaceToTab]"
		echo  "0) 行頭の文字は変換しない [NoChange]"
		head_operation = Input( "番号またはコマンド名を入力してください >" )
		If head_operation = "1" Then  head_operation = "TabToSpace"
		If head_operation = "2" Then  head_operation = "SpaceToTab"
		If head_operation = "0" Then  head_operation = "NoChange"
		enter_guide_t2s = ""
		enter_guide_s2t = ""
	End If
	Assert  head_operation = "TabToSpace"  or _
	        head_operation = "SpaceToTab"  or _
	        head_operation = "NoChange"

	echo  "1) 行頭以外のタブ文字→空白文字 [TabToSpace]"+ enter_guide_t2s
	echo  "2) 行頭以外の空白文字→タブ文字 [SpaceToTab]"+ enter_guide_s2t
	echo  "0) 行頭以外の文字は変換しない [NoChange]"
	mid_operation = Input( "番号またはコマンド名を入力してください >" )
	If mid_operation = ""  Then  mid_operation = "TabToSpace"
	If mid_operation = "1" Then  mid_operation = "TabToSpace"
	If mid_operation = "2" Then  mid_operation = "SpaceToTab"
	If mid_operation = "0" Then  mid_operation = "NoChange"
	Assert  mid_operation = "TabToSpace"  or _
	        mid_operation = "SpaceToTab"  or _
	        mid_operation = "NoChange"

	tab_size = CInt2( Input( "タブ文字のサイズ（Enterのみ=4）>" ) )
	If tab_size = 0 Then  tab_size = 4
	Assert  tab_size >= 1  and  tab_size <= 20

	echo  "Enter のみ：クリップボードの内容を入力とします。"

	Do
		src_path = InputPath( "変換前のテキストが書かれたファイルのパス >",_
			g.CheckFileExists or g.AllowEnterOnly )

		Set ec = new EchoOff

		is_clipboard = False
		If src_path = "" Then  src_path = GetPathOfClipboardText() : is_clipboard = True

		If ArgumentExist( "Out" ) Then
			out1_path = GetTempPath( "SpaceToTab1_*.txt" )
			out2_path = WScript.Arguments.Named.Item("Out")
			Set w_=AppKey.NewWritable( out2_path ).Enable()
		Else
			out2_path = src_path
			src_path  = GetTempPath( "SpaceToTab_*.txt" )
			out1_path = GetTempPath( "SpaceToTab1_*.txt" )
			Set w_=AppKey.NewWritable( src_path ).Enable()
			copy_ren  out2_path, src_path
			Set w_=AppKey.NewWritable( out2_path ).Enable()
		End If

		Select Case  head_operation
			Case  "TabToSpace"
				Set rep = StartReplace( src_path, out1_path, True )
				ChangeHeadTabToSpace  rep.r,  rep.w,  tab_size
				rep.Finish
			Case  "SpaceToTab"
				Set rep = StartReplace( src_path, out1_path, True )
				ChangeHeadSpaceToTab  rep.r,  rep.w,  tab_size
				rep.Finish
			Case  "NoChange" : copy_ren  src_path, out1_path
		End Select
		Select Case  mid_operation
			Case  "TabToSpace"
				Set rep = StartReplace( out1_path, out2_path, True )
				ChangeMiddleTabToSpace  rep.r,  rep.w,  tab_size
				rep.Finish
			Case  "SpaceToTab"
				Set rep = StartReplace( out1_path, out2_path, True )
				ChangeMiddleSpaceToTab  rep.r,  rep.w,  tab_size
				rep.Finish
			Case  "NoChange" : copy_ren  out1_path, out2_path
		End Select

		del  out1_path

		If is_clipboard Then
			SetTextToClipboard( ReadFile( out2_path ) )
			del  out2_path
		End If

		ec = Empty

		If not ArgumentExist( "Out" ) Then
			echo  "変換しました。"
			echo  "変換する前のバックアップ： "+ src_path
			If is_clipboard Then
				echo  "変換した内容を、クリップボードに入れました。"
			Else
				start  GetEditorCmdLine( out2_path )
			End If

			If ArgumentExist( "AutoExit" ) Then
				sleep_msec = WScript.Arguments.Named.Item("AutoExit")
				If not IsEmpty( sleep_msec ) Then  Sleep  sleep_msec
				Exit Do
			End If
		Else
			Exit Do
		End If
	Loop
End Sub


 
'***********************************************************************
'* Function: SpaceToTabShort_sth
'***********************************************************************
Sub  SpaceToTabShort_sth( Opt, AppKey )
	Set g = g_VBS_Lib

	SpaceToTabSub_sth  Opt, AppKey, "SpaceToTab"
End Sub


'***********************************************************************
'* Function: TabToSpaceShort_sth
'***********************************************************************
Sub  TabToSpaceShort_sth( Opt, AppKey )
	Set g = g_VBS_Lib

	SpaceToTabSub_sth  Opt, AppKey, "TabToSpace"
End Sub


 
'***********************************************************************
'* Function: Start_VBS_Lib_Settings_sth
'***********************************************************************
Sub  Start_VBS_Lib_Settings_sth( Opt, AppKey )
	Set w_=AppKey.NewWritable( g_vbslib_ver_folder +"setting" ).Enable()
	Start_VBS_Lib_Settings
End Sub


 
'***********************************************************************
'* Function: StopScreenSaver
'***********************************************************************
Sub  StopScreenSaver( Opt, AppKey )
	ini_path = g_sh.SpecialFolders( "Desktop" ) +"\_StopScreenSaver.ini"
	Set w_=AppKey.NewWritable( ini_path ).Enable()

	del  ini_path

	echo  "30秒ごとに自動的にシフトキーを押すことで、スクリーンセーバーを起動しないようにします。"
	last = Eval( input( "スクリーンセーバーを停止する時間（分）> " ) )

	CreateFile  ini_path, "Stop"

	Do
		WScript.StdOut.Write  vbCR +"残り "& last &"分 "

		g_sh.SendKeys  "+"
		Sleep  30*1000

		last = last - 1
		WScript.StdOut.Write  vbCR +"残り "& last &"分半 "

		g_sh.SendKeys  "+"
		Sleep  30*1000

		If last <= 0 Then  Exit Do
	Loop

	del  ini_path
End Sub


 
'***********************************************************************
'* Function: Switches_sth
'***********************************************************************
Sub  Switches_sth( Opt, AppKey )
	RunSwitchesCUI  AppKey, False, Empty, Empty, Empty
End Sub


 
'***********************************************************************
'* Function: SyncByShortcut
'***********************************************************************
Sub  SyncByShortcut( Opt, AppKey )
	Set c = g_VBS_Lib

	echo  "ショートカットが指すファイルを２つのフォルダー間で同期コピーします。"
	setting_path = InputPath( "設定ファイルのパス >", c.CheckFileExists )
	setting_base_path = GetParentFullPath( setting_path )

	'// Set "shortcut_folder_path"
	Set root = LoadXML( setting_path, Empty )
	shortcut_folder_path = root.selectSingleNode( "./ShortcutFolder/@base" ).nodeValue
	shortcut_folder_path = GetFullPath( shortcut_folder_path, setting_base_path )

	'// Set "sync_path"
	ReDim  sync_path(3-1)
	index = 0
	For Each elem  In root.selectNodes( "./SyncFolder" )
		sync_path( index ) = GetFullPath( elem.getAttribute( "base" ), setting_base_path )
		echo  "フォルダー ("& ( index + 1 ) &"): """+ sync_path( index ) +""""
		sync_path( index ) = GetPathWithSeparator( sync_path( index ) )
		index = index + 1
	Next
	max_index = index - 1
	ReDim Preserve  sync_path( max_index )

	'// ...
	ReDim  path( max_index )
	Set copy_files = CreateObject( "Scripting.Dictionary" )  '// Key=destination
	For Each  full_path  In ArrayFromWildcard( shortcut_folder_path +"\*.lnk" ).FullPaths
		Set shortcut = g_sh.CreateShortcut( full_path )
		target_path = shortcut.TargetPath

		'// Set "step_path" and "path"
		step_path = Empty
		For  index = 0  To  max_index
			If StrCompHeadOf( target_path, sync_path( index ), Empty ) = 0 Then
				step_path = GetStepPath( target_path, sync_path( index ) )
				Exit For
			End If
		Next
		If not IsEmpty( step_path ) Then
			For i=0 To max_index
				path(i) = GetFullPath( step_path, sync_path( i ) )
			Next


			'// Synchronize 2 files
			If max_index = 1 Then
				If MakeRule_compare( path(1), path(0) ) Then
					copy_files( path(1) ) = path(0)
				ElseIf MakeRule_compare( path(0), path(1) ) Then
					copy_files( path(0) ) = path(1)
				End If

			'// Synchronize 3 files
			Else
				If MakeRule_compare( path(1), path(0) ) Then
					If MakeRule_compare( path(0), path(2) ) Then
						copy_files( path(0) ) = path(2)
						copy_files( path(1) ) = path(0)
					ElseIf MakeRule_compare( path(2), path(0) ) Then
						copy_files( path(2) ) = path(0)
						copy_files( path(1) ) = path(0)
					Else
						copy_files( path(1) ) = path(0)
					End If
				ElseIf MakeRule_compare( path(0), path(1) ) Then
					If MakeRule_compare( path(1), path(2) ) Then
						copy_files( path(1) ) = path(2)
						copy_files( path(0) ) = path(1)
					ElseIf MakeRule_compare( path(2), path(1) ) Then
						copy_files( path(2) ) = path(1)
						copy_files( path(0) ) = path(1)
					Else
						copy_files( path(0) ) = path(1)
					End If
				Else
					If MakeRule_compare( path(1), path(2) ) Then
						copy_files( path(1) ) = path(2)
						copy_files( path(0) ) = path(2)
					ElseIf MakeRule_compare( path(2), path(1) ) Then
						copy_files( path(2) ) = path(1)
					Else
					End If
				End If
			End If
		End If
	Next

	echo  ""
	For Each  source  In  copy_files.Items
		echo  source
	Next
	echo  "以上のファイルを、対応するフォルダーにコピーします。"
	Pause

	For Each  destination  In  copy_files.Keys
		w_= Empty
		Set w_=AppKey.NewWritable( destination ).Enable()
		copy_ren  copy_files( destination ), destination
	Next
End Sub


 
'***********************************************************************
'* Function: SyncFilesT_new
'***********************************************************************
Sub  SyncFilesT_new( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  ">SyncFilesT"
	echo  "SyncFilesT で使う設定ファイルのテンプレートを生成します。"
	module_path = InputPath( "各ターゲットのフォルダーが入ったフォルダーのパス >", c.CheckFolderExists )
	setting_path = g_fs.GetParentFolderName( module_path ) + _
		"\_SyncFilesT_"+ g_fs.GetFileName( module_path ) +".xml"
	w_=Empty : Set w_=AppKey.NewWritable( setting_path ).Enable()


	SyncFilesT_Class_createFirstSetting  module_path,  Empty


	echo  ""
	echo  "生成した上記の設定ファイルでよければ、上書きされないためにファイル名を変えてください。"
	echo  ""
	Sleep  300
	Set ec = new EchoOff
	If not ArgumentExist( "silent" ) Then
		start  GetEditorCmdLine( setting_path )
	End If
	ec = Empty
End Sub


 
'***********************************************************************
'* Function: SyncFilesT_sth
'***********************************************************************
Sub  SyncFilesT_sth( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  ">SyncFilesT"
	echo  "行がファイル、列がモジュールのターゲット、という表を表示して、"+ _
		"すべてのターゲット間でファイルの内容を同期（マージ）することを"+ _
		"支援します。"
	echo  ""

	setting_path = InputPath( "設定ファイルのパス >", c.CheckFileExists or c.AllowWildcard )
	If not IsWildcard( setting_path ) Then
		SyncFilesT_diff_Sub  AppKey, setting_path
	Else
		echo  "すべて同期されているかをチェックします。"
		echo  ""
		SyncFilesT_scanModified_Sub  AppKey, setting_path
	End If
End Sub


 
'***********************************************************************
'* Function: SyncFilesT_scanModified_Sub
'***********************************************************************
Sub  SyncFilesT_scanModified_Sub( AppKey, setting_path )
	Set ec = new EchoOff

	Set  syncs = new_SyncFilesT_Class_Array( setting_path )
	ec = Empty

	For Each  sync  In  syncs.Items
		If sync.ModifiedCount >= 1 Then
			echo  sync.SettingPath
			echo  "変更があったファイルの数 = "+ CStr( sync.ModifiedCount )
			echo  ""
		End If
	Next
	echo  "調べた設定ファイルの数 = "+ CStr( syncs.Count )
End Sub


 
'***********************************************************************
'* Function: SyncFilesT_diff_Sub
'***********************************************************************
Sub  SyncFilesT_diff_Sub( AppKey, setting_path )
	Set c = g_VBS_Lib
	out_xml_path = GetTempPath( "SyncFilesT_*.xml" )
	out_html_path = GetTempPath( "SyncFilesT_*.html" )

	Do
		w_=Empty : Set w_=AppKey.NewWritable( setting_path ).Enable()

		Set  sync = new SyncFilesT_Class
		sync.Run  setting_path,  out_xml_path,  Empty
		sync.SaveHTML  out_html_path,  g_vbslib_ver_folder +"tools\SyncFilesT_Template.html"

		If not ArgumentExist( "silent" ) Then _
			start  """"+ out_html_path +""""

		Do
			echo_line
			echo  "ターゲット間で比較するファイルの kind 値を入力してください。"
			echo  "1.  kind 値 1 のファイルを比較する"
			echo  "2.  kind 値 2 のファイルを比較する"
			echo  " :"
			echo  "97. 再スキャンして、一覧を表示する [Reload]"
			echo  "98. 詳細を表示する [ShowDetail]"
			echo  "96. HTML ファイルを保存する [SaveHTML]"
			echo  "99. 終了 [Exit]"
			key = Trim( Input( "kind 値または上記の番号またはコマンド名>" ) )
			key = ChangeNumToCommandOrNot( key, _
				Dict( Array( "97", "Reload", "98", "ShowDetail", "99", "Exit", "96", "SaveHTML" ) ), _
				"ファイル",  sync.KindValues.Exists( key ) )
			echo_line

			If StrComp( key, "Reload", 1 ) = 0 Then
				Exit Do
			ElseIf StrComp( key, "Exit", 1 ) = 0 Then
				Exit Do
			ElseIf StrComp( key, "ShowDetail", 1 ) = 0 Then
				start  GetEditorCmdLine( out_xml_path )

			ElseIf StrComp( key, "SaveHTML", 1 ) = 0 Then
				echo  "HTML ファイルを保存します。"
				echo  ""
				echo  "Enter のみ： 設定ファイルがあるフォルダー"
				new_HTML_path = InputPath( "HTML ファイルの保存先パス（★上書きします）>",  c.AllowEnterOnly )
				If new_HTML_path = "" Then _
					new_HTML_path = AddLastOfFileName( setting_path, ".html" )

				w_=Empty : Set w_=AppKey.NewWritable( new_HTML_path ).Enable()
				copy_ren  out_html_path,  new_HTML_path

			ElseIf IsNumeric( key )  and  sync.Targets.Count <= 2 Then
				kind_name  = key
				DicItemToArr  sync.Targets,  targets  '// Set "targets"

				echo  ""
				echo  kind_name +")"
				echo  ""

				sync.StartDiffTool  kind_name,  targets(0).Name,  targets(1).Name,  Empty

			ElseIf IsNumeric( key )  and  sync.Targets.Count >= 3 Then
				kind_name  = key
				left_file  = Empty
				right_file = Empty
				Do
				Do
					echo  ""
					echo  kind_name +")"
					echo  ""
					echo  "Enter のみ：終了"
					If not IsEmpty( right_file ) Then
						echo  ". (ピリオド) のみ：前回 Diff したファイルをコミットするタグを表示"
					End If
					echo  "c+番号：ターゲット間でコピーする"


					left_target_name = Trim( Input( "Target Number (Left or c+Source) >" ) )


					If left_target_name = "" Then _
						Exit Do
					If Left( left_target_name, 1 ) = "c" Then
						is_copy = True
						left_target_name = Mid( left_target_name, 2 )
					Else
						is_copy = False
					End If
					If IsNumeric( left_target_name ) Then _
						left_target_name = CInt( left_target_name )

					If left_target_name <> "." Then _
						Exit Do


					echo_line
					echo  "Left:"
					sync.ScanAFile  left_file
					echo  left_file.FullPath
					echo  sync.GetCommitTag( left_file )
					echo  ""
					echo  "Right:"
					sync.ScanAFile  right_file
					echo  right_file.FullPath
					echo  sync.GetCommitTag( right_file )
					echo_line
				Loop
					If left_target_name = "" Then _
						Exit Do
				Do
					If not  is_copy Then
						right_target_name = Trim( Input( "Target Number (Right) >" ) )
					Else
						echo  ""
						echo  "Enter のみ：コピー終了"
						right_target_name = Trim( Input( "Target Number (Destination) >" ) )
					End If


					If right_target_name = "" Then _
						Exit Do
					If IsNumeric( right_target_name ) Then _
						right_target_name = CInt( right_target_name )

					If TryStart(e) Then  On Error Resume Next

						If not  is_copy Then
							sync.StartDiffTool  kind_name,  left_target_name,  right_target_name,  Empty
						Else
							Set left_file = sync.GetFileFromTable( kind_name, left_target_name )
							Set right_file = sync.GetFileFromTable( kind_name, right_target_name )
						End If

					If TryEnd Then  On Error GoTo 0
					If e.num = 0 Then
						If is_copy Then
							source_path = left_file.FullPath
							destination_path = right_file.FullPath
							echo  "source_path      = """+ source_path +""""
							echo  "destination_path = """+ destination_path +""""
							key = Input( "コピーします。[Y/N]" )
							If key = "y"  or  key = "Y" Then
								w_=Empty : Set w_=AppKey.NewWritable( _
									destination_path ).Enable()
								copy_ren  source_path,  destination_path
								echo  "コピーしました。"
							End If
						End If
					Else
						echo_v  e.Description
						e.Clear
					End If

					If not  is_copy Then _
						Exit Do
				Loop
				Loop

			ElseIf StrComp( key, "SaveForTest", 1 ) = 0 Then
				save_path = InputPath( "パス >", Empty )
				w_=Empty : Set w_=AppKey.NewWritable( save_path ).Enable()
				Set file = OpenForWrite( save_path, Empty )
				file.WriteLine  "<T_SyncFilesT"
				file.WriteLine  vbTab +"out_xml_path="""+ out_xml_path +""""
				file.WriteLine  vbTab +"out_html_path="""+ out_html_path +""""
				file.WriteLine  "/>"
				file = Empty
			End If
		Loop
		If StrComp( key, "Exit", 1 ) = 0 Then _
			Exit Do
	Loop
End Sub


 
'***********************************************************************
'* Function: SyncFilesX_sth
'***********************************************************************
Sub  SyncFilesX_sth( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  ">SyncFilesX"
	echo  "同じ、または、ほぼ同じ２つのフォルダー（またはファイル）があって、"+ _
		"その両方または片方の内容を更新したときに、"+ _
		"その２つを同期（マージ）することを支援します。 "+ _
		"ただし、この作業では、前回同期したときの２つのバックアップが必要です。 "
	echo  ""
	echo  "４つのパス（NewWork, NewBase, SynchronizedWork, SynchronizedBase）を入力してください。"

	new_work = InputPath( "NewWork：新しいワークのフォルダーまたはファイルのパス>", _
		c.CheckFileExists or c.CheckFolderExists )
	If g_fs.FileExists( new_work ) Then
		check_flag = c.CheckFileExists
		label = "ファイル"
	Else
		check_flag = c.CheckFolderExists
		label = "フォルダー"
	End If
	new_base = InputPath( "NewBase：新しいベースの"+ label +"のパス>", _
		check_flag )

	synced_work = InputPath( "SynchronizedWork：前回同期したときのワークの"+ label +"のパス>", _
		check_flag )
	If g_fs.FileExists( synced_work ) Then
		If g_fs.GetFileName( synced_work ) <> g_fs.GetFileName( new_work ) Then
			Raise  "新旧ファイル名が異なるようにはできません。"
		End If
	End If

	synced_base = InputPath( "SynchronizedBase：前回同期したときのベースの"+ label +"のパス>", _
		check_flag )
	If g_fs.FileExists( synced_base ) Then
		If g_fs.GetFileName( synced_base ) <> g_fs.GetFileName( new_base ) Then
			Raise  "新旧ファイル名が異なるようにはできません。"
		End If
	End If


	Set sync = new SyncFilesX_Class : ErrCheck

	If label = "ファイル" Then
		work_file_name = g_fs.GetFileName( new_work )
		base_file_name = g_fs.GetFileName( new_base )
		new_work = g_fs.GetParentFolderName( new_work )
		new_base = g_fs.GetParentFolderName( new_base )
		synced_work = g_fs.GetParentFolderName( synced_work )
		synced_base = g_fs.GetParentFolderName( synced_base )
		main_tag = "<File path="""+ work_file_name +""" base="""+ base_file_name +"""/>"
	Else
		work_file_name = Empty
		base_file_name = Empty
		main_tag = "<Folder path="".""/>"
	End If

	setting = _
		"<SyncFilesX>" +vbCRLF+ _
		"<SynchronizingSet" +vbCRLF+ _
		"    base_name=""""" +vbCRLF+ _
		"    work_name=""""" +vbCRLF+ _
		"    base="""+ new_base +"""" +vbCRLF+ _
		"    path="""+ new_work +"""" +vbCRLF+ _
		"    synced_base="""+ synced_base +"""" +vbCRLF+ _
		"    synced_path="""+ synced_work +""">" +vbCRLF+ _
		"" +vbCRLF+ _
		main_tag +vbCRLF+ _
		"</SynchronizingSet>" +vbCRLF+ _
		"</SyncFilesX>" +vbCRLF
	Do
			sync.LoadScanListUpAll  g_sh.SpecialFolders( "Desktop" ) +"\_work", setting
			w_ = Empty
			local_writables = sync.GetWritableFolders()
			AddArrElem   local_writables, g_sh.SpecialFolders( "Desktop" )
			Set w_=AppKey.NewWritable( local_writables ).Enable()
			result = sync.OpenCUI()

			If result = "Exit" Then  Exit Do
	Loop

	If ArgumentExist( "pause" ) Then _
		Pause
End Sub


 
'***********************************************************************
'* Function: SyncFilesX_xml
'***********************************************************************
Sub  SyncFilesX_xml( Opt, AppKey )
	Set c = g_VBS_Lib
	setting_path = InputPath( "SyncFilesX の設定ファイルのパス>", c.CheckFileExists )

	SyncFilesX_App  AppKey, setting_path
End Sub


 
'***********************************************************************
'* Function: SyncModuleX
'***********************************************************************
Sub  SyncModuleX( Opt, AppKey )
	Set c = g_VBS_Lib

	path = InputPath( "SyncModuleX の設定ファイル(*.syncmx)のパス>", c.CheckFileExists )
	SyncModuleX_App  AppKey, path
	If ArgumentExist( "pause" ) Then _
		Pause
End Sub


 
'***********************************************************************
'* Function: ThreeWayMerge_sth
'***********************************************************************
Sub  ThreeWayMerge_sth( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  "3ウェイ マージ（3方向マージ）をします。"
	echo  ""
	echo  "Setting オプションで、設定ファイルを入力します。 例：/Setting:C:\Merge.xml"
	
	Do
		base_path  = Input( "ベースにするファイル >" )
		If StrCompHeadOf( base_path, "/Setting:", Empty ) = 0 Then
			setting_path = GetFullPath( Mid( base_path, Len( "/Setting:" ) + 1 ), g_start_in_path )
			echo  "使用する設定ファイル："""+ setting_path +""""
			base_path = Empty
			Exit Do
		Else
			base_path = GetFullPath( base_path, g_start_in_path )
			If g_fs.FileExists( base_path ) Then _
				Exit Do

			echo  "見つかりません : "+ base_path
		End If
	Loop

	If not IsEmpty( base_path ) Then
		left_path  = InputPath( "更新したベースにするファイル（左側） >", c.CheckFileExists )
		right_path = InputPath( "更新したベースにするファイル（右側） >", c.CheckFileExists )
		out_path   = InputPath( "マージした結果の出力先ファイル（★上書きします） >", 0 )

		echo  ""
		echo  "Enter のみ：マージの設定ファイルを使わない。"
		setting_path = InputPath( "マージの設定ファイル >", c.CheckFileExists or c.AllowEnterOnly )
	End If

	If setting_path = "" Then
		merge = Empty
	Else
		Set merge = LoadThreeWayMergeOptionClass( setting_path )
		If IsEmpty( merge.MergeTemplate ) Then _
			Set merge.MergeTemplate = new_ReplaceTemplateClass( setting_path )
	End If

	If setting_path = "" Then
		is_sync_files_x = False
	Else
		Set root = LoadXML( setting_path, Empty )
		If root.selectSingleNode( "./ThreeWayMergeSet" ) is Nothing Then
			is_sync_files_x = False
		Else
			is_sync_files_x = True
		End If
	End If

	If not is_sync_files_x Then
		If not IsEmpty( out_path ) Then
			Set w_= AppKey.NewWritable( out_path ).Enable()
		End If

		If TryStart(e) Then  On Error Resume Next

			ThreeWayMerge  base_path, left_path, right_path, out_path, merge

		If TryEnd Then  On Error GoTo 0
		If e.num = E_Conflict  Then  e.Clear
		If e.num <> 0 Then  e.Raise
	Else
		Set sync = new SyncFilesX_Class
		Do
			sync.LoadScanListUpAll  setting_path, ReadFile( setting_path )
			Set w_=AppKey.NewWritable( sync.GetWritableFolders() ).Enable()
			sync.Merge  merge
			result = sync.OpenCUI()

			If result = "Exit" Then  Exit Do
		Loop
	End If

	If ArgumentExist( "pause" ) Then _
		Pause
End Sub


 
'***********************************************************************
'* Function: TimeStampIfSame
'***********************************************************************
Sub  TimeStampIfSame( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  "２つのフォルダーを比較して、同じ内容であれば、タイムスタンプをそろえます"

	folder1 = InputPath( "フォルダー１ >", c.CheckFolderExists )
	echo  "フォルダー２は、タイムスタンプを変更します。"
	folder2 = InputPath( "フォルダー２ >", c.CheckFolderExists )

	file_count = 0
	echo  "フォルダーを調べています…"
	ExpandWildcard  folder2 +"\*", F_File or F_SubFolder, folder, fnames

	Set w_=AppKey.NewWritable( folder2 ).Enable()

	For Each fname  In fnames
		path1 = GetFullPath( fname, folder1 )
		path2 = GetFullPath( fname, folder )
		file_count = file_count + 1
		echo  file_count &"/"& (UBound(fnames)+1)

		If fc_r( path1, path2, "nul" ) Then
			Set ec = new EchoOff
			copy_ren  path1, path2
			ec = Empty
		End If
	Next
	echo  "完了しました。"
End Sub


 
'***********************************************************************
'* Function: ToRegularXML
'***********************************************************************
Sub  ToRegularXML( Opt, AppKey )
	Set c = g_VBS_Lib

	path = InputPath( "整形する XML ファイルのパス >", c.CheckFileExists )

	temp_path = GetTempPath( "ToRegularXML_*.xml" )
	copy_ren  path, temp_path
	echo  "バックアップ： """+ temp_path +""""

	Set w_=AppKey.NewWritable( path ).Enable()
	Set cs = new_TextFileCharSetStack( ReadUnicodeFileBOM( path ) )
	CreateFile  path, Replace( ReadFile( path ),  "><",  ">"+ vbCRLF +"<" )

	Set root = LoadXML( path, Empty )
	root.ownerDocument.save  path

	echo  "整形しました。"
End Sub


 
'***********************************************************************
'* Function: Translate_sth
'***********************************************************************
Sub  Translate_sth( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  "英訳します。"
	translator = InputPath( "翻訳ファイル (*.trans) のパス、または、フォルダーのパス >", _
		c.CheckFileExists or c.CheckFolderExists )
	out_paths = Translate_getOverwritePaths( translator )
	echo  "次のファイルを上書きします。"
	For Each  path  In  out_paths : echo  path : Next
	pause
	Set w_=AppKey.NewWritable( Translate_getWritable( translator ) ).Enable()

	If IsEmpty( WScript.Arguments.Named.Item("BaseFolder") ) Then
		Translate  translator, "JP", "EN"
	Else
		Set config = new TranslateConfigClass
		config.IsTestOnly = False
		config.BaseFolderPath = WScript.Arguments.Named.Item("BaseFolder")

		TranslateEx  translator, "JP", "EN", config
	End If

End Sub


 
'***********************************************************************
'* Function: TranslateTest_sth
'***********************************************************************
Sub  TranslateTest_sth( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  "英訳のテストをします。"
	echo  "★翻訳ファイル (*.trans) は上書きされます。"
	translator = InputPath( "翻訳ファイル (*.trans) のパス、または、フォルダーのパス >", _
		c.CheckFileExists or c.CheckFolderExists )

	Set writable_paths = new ArrayClass
	If g_fs.FolderExists( translator ) Then
		writable_paths.Add  ArrayFromWildcard( translator +"\*.trans" ).FullPaths
	Else
		writable_paths.Add  translator
	End If


	echo  ""
	echo  "Enter のみ ： 出力しませんが、翻訳後に日本語が残っていないことをチェックします"
	out_path   = InputPath( "出力フォルダーのパス（★上書きされます）>", c.AllowEnterOnly )
	echo  ""

	If out_path <> "" Then _
		writable_paths.Add  out_path

	Set w_=AppKey.NewWritable( writable_paths ).Enable()

	If TryStart(e) Then  On Error Resume Next
		TranslateTest  translator, "JP", "EN", out_path
	If TryEnd Then  On Error GoTo 0
	If e.num = get_ToolsLibConsts().E_NotEnglishChar  Then  echo e.desc : e.Clear
	If e.num <> 0 Then  e.Raise
End Sub


 
'***********************************************************************
'* Function: TranslateTest_Install
'***********************************************************************
Sub  TranslateTest_Install( Opt, AppKey )
	echo  "*.lines ファイルをダブルクリックすると、TranslateTestが起動するようにします。"
	Pause

	prompt_vbs = SearchParent( "vbslib Prompt.vbs" )
	command_line = GetCScriptGUI_CommandLine( "//nologo """+_
		prompt_vbs +""" TranslateTest ""%1"" """"" )
	InstallRegistryFileOpenCommand  "trans", "TranslateTest", command_line, True
End Sub


 
'***********************************************************************
'* Function: TranslateTest_Uninstall
'***********************************************************************
Sub  TranslateTest_Uninstall( Opt, AppKey )
	echo  "*.lines ファイルをダブルクリックしても、TranslateTestが起動しないようにします。"
	Pause

	UninstallRegistryFileOpenCommand  "trans", "TranslateTest"
End Sub


 
'***********************************************************************
'* Function: TranslateToEnglishOld
'***********************************************************************
Sub  TranslateToEnglishOld( Opt, AppKey )
	cd  g_fs.GetParentFolderName( WScript.ScriptFullName )

	Set args = WScript.Arguments.Unnamed

	If args.Count = 0 Then  Err.Raise 1,,"翻訳 CSV ファイルをドロップしてください"

	Set tr = new_TranslateToEnglish( args(0) )
	If ArgumentExist( "Reverse" ) Then  tr.IsReverseTranslate = True
	Set w_=AppKey.NewWritable( tr.Writable ).Enable()
	tr.Translate
End Sub


 
'***********************************************************************
'* Function: TwoWayMerge_sth
'***********************************************************************
Sub  TwoWayMerge_sth( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  "2ウェイ マージ（2方向マージ）をします。"
	echo  ""

	left_path  = InputPath( "比較するするファイル（左側） >", c.CheckFileExists )
	right_path = InputPath( "比較するファイル（右側） >", c.CheckFileExists )
	out_path   = InputPath( "マージした結果の出力先ファイル（★上書きします） >", 0 )

	echo  ""
	Pause  '// LoadThreeWayMergeOptionClass for future

	Set w_=AppKey.NewWritable( out_path ).Enable()

	left_path  = GetStepPath( left_path,  g_start_in_path )
	right_path = GetStepPath( right_path, g_start_in_path )

	Set ds = new CurDirStack
	cd  g_start_in_path
	diff  left_path,  right_path,  out_path,  Empty
End Sub


 
'***********************************************************************
'* Function: unzip_sth
'***********************************************************************
Sub  unzip_sth( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  "zip ファイルを展開します。"
	echo  "zip ファイルと同じ名前のフォルダーを作成し、その中に展開します。"

	zip_path = InputPath( "zip ファイルのパス >", c.CheckFileExists )

	Set ec = new EchoOff

	out_path = AddLastOfFileName( zip_path, "." )
	If exist( out_path ) Then
		next_old_path = out_path +"_old"
		index = 2
		While  exist( next_old_path )
			next_old_path = out_path +"_old" & index
			index = index + 1
			If index >= 999 Then Error
		WEnd

		echo_v  """"+ g_fs.GetFileName( next_old_path ) +""" に改名しました。: """+ _
			out_path +""""

		Set w_=AppKey.NewWritable( Array( out_path, next_old_path ) ).Enable()
		ren  out_path,  next_old_path
		w_= Empty
	End If

	Set w_=AppKey.NewWritable( out_path ).Enable()

	unzip  zip_path,  out_path,  Empty
	ec = Empty

	echo  "展開しました。"
End Sub


 
'***********************************************************************
'* Function: UpdateModule_sth
'***********************************************************************
Sub  UpdateModule_sth( Opt, AppKey )
	Dim  patch
	work_path = g_sh.SpecialFolders( "Desktop" ) +"\_UpdateModule"
	Set w_=AppKey.NewWritable( work_path ).Enable()

	Set c = g_VBS_Lib
	echo  "プロジェクト フォルダーの中にある、古いリビジョンのモジュールを、新しいリビジョンに"+ _
		"置き換えます。 作業フォルダーをデスクトップの _UpdateModule に作成します。"

	old_path = InputPath( "Old ：旧モジュールが入ったフォルダー、または、ファイルのパス >", _
		c.CheckFolderExists or c.CheckFileExists )
	If g_fs.FolderExists( old_path ) Then
		label = "が入ったフォルダー"
		flag = c.CheckFolderExists
	Else
		label = "のファイル"
		flag = c.CheckFileExists
	End If

	new_path = InputPath( "New ：新モジュール"+ label +"のパス >", _
		flag )
	target_path = InputPath( "Target：プロジェクト フォルダーの（中の Old に対応する）パス >", _
		flag )
	echo  ""
	echo  "Enter のみ：マージの設定ファイルを使わない。"
	setting_path = InputPath( "マージの設定ファイル >", c.CheckFileExists or c.AllowEnterOnly )


	If setting_path = "" Then
		Set merge = new ThreeWayMergeOptionClass
	Else
		Set merge = LoadThreeWayMergeOptionClass( setting_path )
	End If
	merge.IsEnableToRaiseConflictError = False


	'// Delete "work_path" folder
	If exist( work_path ) Then
		key = Input( "前回の作業フォルダー (desktop\_UpdateModule) を削除します。 よろしいですか(y/n)" )
		If key <> "y"  and  key <> "Y" Then  Error
	End If

	del  work_path


	'// Make "work_path" folder
	If flag = c.CheckFolderExists Then
		wildcard = "\*"
	Else
		wildcard = ""
	End If
	copy  target_path + wildcard, work_path +"\1A_TargetMerged"
	copy  target_path + wildcard, work_path +"\1B_TargetSynchronized"
	copy  target_path + wildcard, work_path +"\1C_TargetOld"
	copy  new_path + wildcard, work_path +"\2A_ModuleNew"
	copy  old_path + wildcard, work_path +"\2B_ModuleSynchronized"
	copy  old_path + wildcard, work_path +"\2C_ModuleOld"

	CreateFile  work_path +"\README.txt", _
		" == Merging Folder by UpdateModule =="+ vbCRLF + _
		""+ vbCRLF + _
		"- Target : """+ target_path + """"+ vbCRLF + _
		"- ModuleNew          : """+ new_path + """"+ vbCRLF + _
		"- ModuleSynchronized : """+ old_path + """"+ vbCRLF + _
		""+ vbCRLF + _
		"Synchronized folder has old synchronized files and new synchronized files."+ vbCRLF


	'// Remove read only attribute
	SetFilesToNotReadOnly  g_fs.GetFolder( work_path +"\1A_TargetMerged" )
	SetFilesToNotReadOnly  g_fs.GetFolder( work_path +"\1B_TargetSynchronized" )
	SetFilesToNotReadOnly  g_fs.GetFolder( work_path +"\2A_ModuleNew" )
	SetFilesToNotReadOnly  g_fs.GetFolder( work_path +"\2B_ModuleSynchronized" )


	'// Merge automatically
	files = Empty
	g_FileHashCache.RemoveAll
	Set patch = MakePatchAndBackUpDictionary( _
		Empty, work_path +"\2A_ModuleNew", Empty, work_path +"\2B_ModuleSynchronized", Empty )
	AttachPatchAndBackUpDictionary  files, patch, work_path +"\1A_TargetMerged", merge
	CopyFilesToLeafPathDictionary  files, True


	'// Call "SyncFilesX"
	path = work_path +"\SyncFilesX_Setting.vbs"
	Set file = OpenForWrite( path, c.Unicode )
	file.WriteLine  "'------------------------------------------------------------[FileInScript.xml]"
	file.WriteLine  "'<SyncFilesX>"
	file.WriteLine  "'<SynchronizingSet"
	file.WriteLine  "'    base_name=""Module"""
	file.WriteLine  "'    work_name=""Target"""
	file.WriteLine  "'    base="""+ work_path +"\2A_ModuleNew" +""""
	file.WriteLine  "'    path="""+ work_path +"\1A_TargetMerged" +""""
	file.WriteLine  "'    synced_base="""+ work_path +"\2B_ModuleSynchronized" +""""
	file.WriteLine  "'    synced_path="""+ work_path +"\1B_TargetSynchronized" +""">"
	file.WriteLine  "'"
	If flag = c.CheckFolderExists Then
		file.WriteLine  "'<Folder path="".""/>"
	Else
		file.WriteLine  "'<File path="""+ g_fs.GetFileName( target_path ) + _
			""" base="""+ g_fs.GetFileName( new_path ) + _
			""" synced_path="""+ g_fs.GetFileName( target_path ) + _
			""" synced_base="""+ g_fs.GetFileName( old_path ) +"""/>"
	End If
	file.WriteLine  "'"
	file.WriteLine  "'</SynchronizingSet>"
	file.WriteLine  "'</SyncFilesX>"
	file.WriteLine  "'-----------------------------------------------------------[/FileInScript.xml]"
	file.WriteLine  ""
	file.WriteLine  "Sub  Main( Opt, AppKey )"
	file.WriteLine  vbTab +"SyncFilesX_App  AppKey, new_FilePathForFileInScript( Empty )"
	file.WriteLine  "End Sub"
	file.WriteLine  ""
	file.WriteLine  ""
	file.WriteLine  " "
	WriteVBSLibFooter  file, Empty
	file = Empty

	copy  g_vbslib_folder +"*", work_path +"\scriptlib"

	Set sync = new SyncFilesX_Class
	sync.IsNextAutoCommit = True
	sync.IsNextAutoMergeFromBase = True
	Do
		sync.LoadScanListUpAll  GetFilePathString( path ), ReadFile( new_FilePathForFileInScript( _
			path +"#FileInScript.xml") )
		w_ = Empty : Set w_=AppKey.NewWritable( sync.GetWritableFolders() ).Enable()
		result = sync.OpenCUI()

		If result = "Exit" Then  Exit Do
	Loop

	echo  ""
	echo  "同期が完了したら、その内容をプロジェクトに反映させてください。"
	echo  "同期済み："""+ work_path +"\1A_TargetMerged"""
	echo  "Targetプロジェクト："""+ target_path +""""

	If ArgumentExist( "pause" ) Then _
		Pause
End Sub


 
'***********************************************************************
'* Function: XmlText_sth
'***********************************************************************
Sub  XmlText_sth( Opt, AppKey )
	Set g = g_VBS_Lib

	echo  "テキストを XML/HTML の実体参照に変換します。"
	echo  "1) テキスト → XML/HTML テキストの実体参照 [ToRef]"
	'// echo  "2) XML/HTML テキストの実体参照 → テキスト [FromRef]"
	operation = Input( "番号またはコマンド名を入力してください >" )
	If operation = "1" Then  operation = "ToRef"
	'// If operation = "2" Then  operation = "FromRef"
	echo  ""
	echo  "Enter のみ：クリップボードの内容を入力とします。"

	Do
		src_path = InputPath( "変換前のテキストが書かれたファイルのパス >",_
			g.CheckFileExists or g.AllowEnterOnly )

		Set ec = new EchoOff

		is_clipboard = False
		If src_path = "" Then  src_path = GetPathOfClipboardText() : is_clipboard = True

		text = ReadFile( src_path )
		If operation = "ToRef" Then
			text = XmlText( text )
		End If

		If is_clipboard Then
			SetTextToClipboard  text
		Else
			CreateFile  out_path, text
		End If

		ec = Empty

		If not ArgumentExist( "Out" ) Then
			echo  "変換しました。"
			echo  "変換する前のバックアップ： "+ src_path
			If is_clipboard Then
				echo  "変換した内容を、クリップボードに入れました。"
			Else
				start  GetEditorCmdLine( out_path )
			End If

			If ArgumentExist( "AutoExit" ) Then
				sleep_msec = WScript.Arguments.Named.Item("AutoExit")
				If not IsEmpty( sleep_msec ) Then  Sleep  sleep_msec
				Exit Do
			End If
		Else
			Exit Do
		End If
	Loop
End Sub


 






'--- start of vbslib include ------------------------------------------------------ 

'// ここの内部から Main 関数を呼び出しています。
'// また、scriptlib フォルダーを探して、vbslib をインクルードしています

'// vbslib include is provided under 3-clause BSD license.
'// Copyright (C) Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.

Dim  g_Vers : If IsEmpty( g_Vers ) Then
Set  g_Vers = CreateObject("Scripting.Dictionary") : g_Vers("vbslib") = 99.99
Dim  g_debug, g_debug_params, g_admin, g_vbslib_path, g_CommandPrompt, g_fs, g_sh, g_AppKey
Dim  g_MainPath, g_SrcPath, g_f, g_include_path, g_i, g_debug_tree, g_debug_process, g_is_compile_debug
Dim  g_is64bitWSH
g_SrcPath = WScript.ScriptFullName : g_MainPath = g_SrcPath
SetupVbslibParameters
Set  g_fs = CreateObject( "Scripting.FileSystemObject" )
Set  g_sh = WScript.CreateObject("WScript.Shell") : g_f = g_sh.CurrentDirectory
g_sh.CurrentDirectory = g_fs.GetParentFolderName( WScript.ScriptFullName )
For g_i = 20 To 1 Step -1 : If g_fs.FileExists(g_vbslib_path) Then  Exit For
g_vbslib_path = "..\" + g_vbslib_path  : Next
If g_fs.FileExists(g_vbslib_path) Then  g_vbslib_path = g_fs.GetAbsolutePathName( g_vbslib_path )
g_sh.CurrentDirectory = g_f
If g_i=0 Then WScript.Echo "Not found " + g_fs.GetFileName( g_vbslib_path ) +vbCR+vbLF+_
	"Let's download vbslib and Copy scriptlib folder." : Stop : WScript.Quit 1
Set g_f = g_fs.OpenTextFile( g_vbslib_path,,,-2 ): Execute g_f.ReadAll() : g_f = Empty
If ResumePush Then  On Error Resume Next
	CallMainFromVbsLib
ResumePop : On Error GoTo 0
End If
'---------------------------------------------------------------------------------

Sub  SetupDebugTools()
	set_input  ""
	SetBreakByFName  Empty
	SetStartSectionTree  ""
End Sub

Sub  SetupVbslibParameters()
	'--- start of parameters for vbslib include -------------------------------
	'// g_Vers("OldMain") = 1
	g_vbslib_path = "scriptlib\vbs_inc.vbs"
	g_CommandPrompt = 1
	g_debug = 0
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------


 
