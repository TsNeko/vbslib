'// vbslib - VBScript ShortHand Library  ver4.91  Oct.13, 2014
'// vbslib is provided under 3-clause BSD license.
'// Copyright (C) 2007-2014 Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.


Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		o.Lead = "vbslib Prompt"

		Set o.MenuCaption = Dict(Array(_
			"1","ヘルプ(SVG形式)の表示 (Google Chrome や Snap Note で見えます)",_
			"2","ヘルプ(Internet Explorer - VML形式)の表示",_
			"3","■ vbs ファイルを新規作成する [%name%]",_
			"4","ショートハンド・プロンプトを新規作成する [%name%]", _
			"5","タブ文字と空白文字を変更する [%name%]", _
			"6","Test テンプレート・フォルダーを開く [test]", _
			"7","最新の vbslib に変換する [ConvertToNewVbsLib]", _
			"8","このプロンプトのソースを開く", _
			"9","vbslib フォルダーを開く" ))

		Set o.CommandReplace = Dict(Array(_
			"1","OpenShorHandLibHelpSVG",_
			"2","OpenShorHandLibHelpHtml",_
			"3","MakeNewScript",_
			"4","MakeNewPrompt",_
			"5","SpaceToTab",_
			"6","OpenTestTemplate",_
			"7","ConvertToNewVbsLib_sth",_
			"8","OpenShorHandPromptSrc",_
			"9","OpenVbsLib",_
			_
			"Base64",        "Base64_sth",_
			"CheckEnglishOnly",      "CheckEnglishOnly_sth",_
			"ConvertToNewVbsLib",    "ConvertToNewVbsLib_sth",_
			"CopyOnlyExist",         "CopyOnlyExist_sth",_
			"CutLineFeedAtRightEnd", "CutLineFeedAtRightEnd_sth",_
			"lf",                    "CutLineFeedAtRightEnd_sth",_
			"CutSharpIf",    "CutSharpIf_sth",_
			"DownloadByHttp","DownloadByHttp_sth",_
			"fc",            "fc_sth",_
			"fdiv",          "fdiv_sth",_
			"feq",           "feq_sth",_
			"find",          "FindFile_sth",_
			"FindFile",      "FindFile_sth",_
			"GetHash",       "GetHash_sth",_
			"GetStepPath",   "GetStepPath_sth",_
			"GetShortPath",  "GetShortPath_sth",_
			"grep",          "grep_sth",_
			"grep_u",        "grep_u_sth",_
			"mkdir",         "mkdir_sth",_
			"OpenSendTo",    "OpenSendTo_sth",_
			"OpenStartUp",   "OpenStartUp_sth",_
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
			"st",            "SpaceToTabShort_sth",_
			"test",          "OpenTestTemplate",_
			"TabToSpace",    "SpaceToTab_sth",_
			"Translate",     "Translate_sth",_
			"TranslateTest", "TranslateTest_sth",_
			"ts",            "TabToSpaceShort_sth" ))

	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'*************************************************************************
'  <<< [Base64_sth] >>>
'*************************************************************************
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


 
'*************************************************************************
'  <<< [BashSyntax] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [CheckEnglishOnly_sth] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [ConvertToNewVbsLib_sth] >>> 
'*************************************************************************
Sub  ConvertToNewVbsLib_sth( Opt, AppKey )
	Set c = g_VBS_Lib
	echo "スクリプトが使っている古い vbslib を最新の vbslib に置き換えます。"
	echo "  ver4 → ver5"
	echo "事前に変換を行うフォルダーの ★バックアップ をとっておいてください。"
	path = InputPath( "変換を行うフォルダーのパス >", c.CheckFolderExists )
	echo_line

	Set w_=AppKey.NewWritable( path ).Enable()
	ConvertToNewVbsLib  path
End Sub


 
'*************************************************************************
'  <<< [CopyOnlyExist_sth] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [CreateTask] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [CutLineFeedAtRightEnd_sth] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [DelTemp] >>> 
'*************************************************************************
Sub  DelTemp( Opt, AppKey )
	path = GetTempPath( "." )
	echo "下記のフォルダを削除します。"
	echo  path
	Pause
	Set w_=AppKey.NewWritable( path ).Enable()
	del  path
End Sub


 
'*************************************************************************
'  <<< [Diff] >>> 
'*************************************************************************
Sub  Diff( Opt, AppKey )
	Set c = g_VBS_Lib
	echo "[Diff] テキストファイルの比較"

	path1 = InputPath( "path1>", c.CheckFileExists )
	path2 = InputPath( "path2>", c.CheckFileExists )

	echo  ""
	echo  "Enter のみ ： 2つのファイルの比較"
	path3 = InputPath( "path3>", c.CheckFileExists or c.AllowEnterOnly )
	echo ""

	If path3 = "" Then
		start  GetDiffCmdLine( path1, path2 )
	Else
		start  GetDiffCmdLine3( path1, path2, path3 )
	End If
End Sub


 
'*************************************************************************
'  <<< [CutSharpIf_sth] >>> 
'*************************************************************************
Sub  CutSharpIf_sth( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  "#ifdef ～ #endif をカットします。"
	path = InputPath( "変換するソースファイルのパス >", c.CheckFileExists )
	symbol = Input( "#define シンボル >" )
	echo  ""
	echo  "1) 定義されていたときのコードを削除する"
	echo  "0) 定義されていないときのコードを削除する"
	is_cut_true = Input( "番号を入力してください >" )
	Assert  is_cut_true = "1"  or  is_cut_true = "0"

	Set w_=AppKey.NewWritable( g_fs.GetParentFolderName( path ) ).Enable()
	CutSharpIf  path, Empty, symbol, is_cut_true
	echo  "変換しました。"
End Sub


 
'*************************************************************************
'  <<< [DownloadByHttp_sth] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [DiffClip] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [fc_sth] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [fc_patch] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [fdiv_sth] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [feq_sth] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [FindFile_sth] >>>
'*************************************************************************
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


 
'*************************************************************************
'  <<< [FindFile_Install] >>>
'*************************************************************************
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


 
'*************************************************************************
'  <<< [FindFile_Uninstall] >>>
'*************************************************************************
Sub  FindFile_Uninstall( Opt, AppKey )
	menu_caption = "ファイル名から検索"
	echo  "フォルダーの右クリック・メニューから、[ "+ menu_caption +" ] を削除します。"
	Pause

	UninstallRegistryFileVerb  "Folder", "find_sth"
End Sub


 
'*************************************************************************
'  <<< [GetHash_sth] >>>
'*************************************************************************
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
	Select Case  clip
		Case  value_of_MD5:        s = "MD5"
		Case  value_of_SHA1:       s = "SHA1"
		Case  value_of_SHA256:     s = "SHA256"
		Case  value_of_SHA384:     s = "SHA384"
		Case  value_of_SHA512:     s = "SHA512"
		Case  value_of_RIPEMD160:  s = "RIPEMD160"
		Case Else  s = Empty
	End Select

	echo  ""
	s0 = "クリップボードの内容と一致するハッシュ値は、"
	If IsEmpty( s ) Then
		echo  s0 + "ありません。"
	Else
		echo  s0 + s + " です。"
	End If
End Sub


 
'*************************************************************************
'  <<< [GetHashPS] >>>
'*************************************************************************
Sub  GetHashPS( Opt, AppKey )
	Set c = g_VBS_Lib

	echo  "ファイルのハッシュ値（MD5など）を表示し、クリップボードに入っている"+ _
		"ハッシュ値と比較します。（大容量ファイル対応版）"
	path = InputPath( "ファイルのパス>", c.CheckFileExists )

	echo  "1. MD5"
	echo  "2. SHA1"
	echo  "3. SHA256"
	echo  "4. SHA384"
	echo  "5. SHA512"
	echo  "6. RIPEMD160"
	key = Input( "番号またはコマンド >" )
	Select Case  key
		Case  "1":  key = "MD5"
		Case  "2":  key = "SHA1"
		Case  "3":  key = "SHA256"
		Case  "4":  key = "SHA384"
		Case  "5":  key = "SHA512"
		Case  "6":  key = "RIPEMD160"
	End Select

	command = "Write-Host  ( [System.BitConverter]::ToString( "+_
		"( New-Object System.Security.Cryptography.SHA1CryptoServiceProvider )"+_
		".ComputeHash( "+_
		"( New-Object System.IO.StreamReader( '"+ path +"' ) )"+_
		".BaseStream ) ).Replace( '-', '' ) )"

	Set ex = g_sh.Exec( "powershell -nologo  -command "+ command )
	ex.StdIn.Close  '// for Windows7 or PowerShell v1.0
	hash_value = Trim2( ex.StdOut.ReadAll() )
	echo  hash_value

	clip = GetTextFromClipboard()
	s0 = "クリップボードの内容と一致"
	If clip = hash_value Then
		echo  s0 + "しました。"
	Else
		echo  s0 + "していません。"
	End If
End Sub


 
'*************************************************************************
'  <<< [GetStepPath_sth] >>>
'*************************************************************************
Sub  GetStepPath_sth( Opt, AppKey )
	echo  "フル・パスから相対パスに変換します。"
	abs_path  = InputPath( "フル・パス>", 0 )
	base_path = InputPath( "基準フォルダのフル・パス>", 0 )

	step_path = GetStepPath( abs_path, base_path )
	echo  step_path
End Sub


 
'*************************************************************************
'  <<< [GetShortPath_sth] >>>
'*************************************************************************
Sub  GetShortPath_sth( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  "短いパス（ファイルやフォルダーの 8.3形式パス）に変換します。"
	long_path  = InputPath( "（長い）パス>", c.CheckFileExists or c.CheckFolderExists )
	echo  g_fs.GetFile( long_path ).ShortPath
End Sub


 
'*************************************************************************
'  <<< [grep_sth] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [InfiniteLoop] >>> 
'*************************************************************************
Sub  InfiniteLoop( Opt, AppKey )
	echo  "Infinite Loop ..."
	Do
	Loop
End Sub


 
'*************************************************************************
'  <<< [LAN_Path] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [MakeNewScript] >>> 
'*************************************************************************
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
	Setting_openFolder  new_vbs_path


	'// スクリプト・ファイルを開きます
	Sleep  1000
	start  GetEditorCmdLine( new_vbs_path )
End Sub


 
'*************************************************************************
'  <<< [MakeNewPrompt] >>> 
'*************************************************************************
Sub  MakeNewPrompt( Opt, AppKey )
	MakeNewScriptSub  AppKey, "Prompt.vbs", "samples\sample_short_hand_prompt.vbs"

	echo_line
	echo  "vbs ファイルを作成しました。"
	echo  "テキスト・エディターで、vbs ファイルの最後にある NewScript 関数を編集してください。"
	echo  "vbs ファイルをダブルクリックすると編集した内容を実行します。"
End Sub


 
'*************************************************************************
'  <<< [mkdir_sth] >>>
'*************************************************************************
Sub  mkdir_sth( Opt, AppKey )
	echo  "[MkDir] make directory"
	echo  "相対パスを使ってフォルダーを作ります。"
	Set c = g_VBS_Lib

	base_path = InputPath( "相対パスの基準フォルダー >", c.CheckFolderExists )
	Set w_=AppKey.NewWritable( base_path ).Enable()

	step_path = Input( "作成するフォルダーの相対パス >" )
	mkdir  base_path +"\"+ step_path
	Setting_openFolder  base_path +"\"+ step_path
End Sub


 
'*************************************************************************
'  <<< [MD5List] >>> 
'*************************************************************************
Sub  MD5List( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  "1) [make] MD5リストを作成します"
	echo  "2) [check] MD5リストをチェックします"
	key = Input( "番号またはコマンド >" )

	Select Case  key
		Case "1" : key = "make"
		Case "2" : key = "check"
	End Select
	operation = LCase( key )

	folder_path = InputPath( "調べるフォルダーのパス >", c.CheckFolderExists )

	Select Case  operation
		Case "make"
			path_of_MD5 = InputPath( "MD5 リストのファイル パス（出力先）>", 0 )
			Set w_=AppKey.NewWritable( path_of_MD5 ).Enable()
			MakeFolderMD5List  folder_path, path_of_MD5
			echo  "作成しました。"

		Case "check"
			path_of_MD5 = InputPath( "MD5 リストのファイル パス（入力元）>", 0 )
			CheckFolderMD5List  folder_path, path_of_MD5, Empty
			echo  "問題ありません。"
	End Select
End Sub


 
'*************************************************************************
'  <<< [NaturalDocs] >>> 
'*************************************************************************
Sub  NaturalDocs( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  "ソースファイルにあるコメントを HTML に変換します。"
	source_path = InputPath( "ソースファイルがあるフォルダーのパス>", c.CheckFolderExists )
	destination_path = InputPath( "HTML を格納するフォルダーのパス（★上書きします）>", 0 )

	Set w_=AppKey.NewWritable( destination_path ).Enable()
	MakeDocumentByNaturalDocs  source_path, destination_path, Empty
	start  """"+ GetPathWithSeparator( destination_path ) +"index.html"""
End Sub


 
'*************************************************************************
'  <<< [OpenByStepPath] >>> 
'*************************************************************************
Sub  OpenByStepPath( Opt, AppKey )
	Set c = g_VBS_Lib
	Set fin = new FinObj : fin.SetFunc "OpenByStepPath_Finally"
	fin.SetVar "g_start_in_path", g_start_in_path

	echo  "相対パスを指定して、ファイルやフォルダーを開きます。（絶対パスも可）"

	Do
		base_path = Input( "基準パス >" )
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

			start  """"+ full_path +""""
		Loop
		echo  ""
	Loop
End Sub
 Sub  OpenByStepPath_Finally( Vars )
	en = Err.Number : ed = Err.Description : On Error Resume Next
	g_start_in_path = Vars.Item("g_start_in_path")
	ErrorCheckInTerminate  en : On Error GoTo 0 : If en <> 0 Then  Err.Raise en,,ed
End Sub


 
'*************************************************************************
'  <<< [OpenFolder] >>> 
'*************************************************************************
Sub  OpenFolder( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  "ファイルのパスを入力すると、そのファイルを含むフォルダーを開きます。"
	path = InputPath( "ファイルのパス >", c.CheckFileExists or c.CheckFolderExists )
	Setting_openFolder  path
End Sub


 
'*************************************************************************
'  <<< [OpenSendTo_sth] >>> 
'*************************************************************************
Sub  OpenSendTo_sth( Opt, AppKey )
	Setting_openFolder  g_sh.SpecialFolders( "SendTo" )
End Sub


 
'*************************************************************************
'  <<< [OpenStartUp_sth] >>> 
'*************************************************************************
Sub  OpenStartUp_sth( Opt, AppKey )
	echo  "1) CurrentUser"
	echo  "2) AllUsers"
	key = input( "Input number>" )
	If key = "2" Then
		Setting_openFolder  g_sh.SpecialFolders( "AllUsersStartup" )
	Else
		Setting_openFolder  g_sh.SpecialFolders( "Startup" )
	End If
End Sub


 
'*************************************************************************
'  <<< [OpenShorHandLibHelpSVG] >>> 
'*************************************************************************
Sub  OpenShorHandLibHelpSVG( Opt, AppKey )
	start  "_src\vbslib.svg"
End Sub


 
'*************************************************************************
'  <<< [OpenShorHandLibHelpHtml] >>> 
'*************************************************************************
Sub  OpenShorHandLibHelpHtml( Opt, AppKey )
	start  g_sh.ExpandEnvironmentStrings( _
	 """%ProgramFiles%\Internet Explorer\iexplore.exe"" """+ g_sh.CurrentDirectory +_
	 "\_src\_vbslib manual.files\vbslib.html""" )
End Sub


 
'*************************************************************************
'  <<< [OpenShorHandPromptSrc] >>> 
'*************************************************************************
Sub  OpenShorHandPromptSrc( Opt, AppKey )
	start  GetEditorCmdLine( WScript.ScriptFullName )
End Sub


 
'*************************************************************************
'  <<< [OpenTask] >>> 
'*************************************************************************
Sub  OpenTask( Opt, AppKey )
	echo  ">OpenTask"
	Dim  ec : Set ec = new EchoOff
	If GetOSVersion() <= 5.1 Then
		start  "explorer  ::{D6277990-4C6A-11CF-8D87-00AA0060F5BF}"
	Else
		start  "taskschd.msc /s"
	End If
End Sub


 
'*************************************************************************
'  <<< [OpenTestTemplate] >>> 
'*************************************************************************
Sub  OpenTestTemplate( Opt, AppKey )
	Setting_openFolder  "samples\Test"
	WScript.Quit  E_TestPass
End Sub


 
'*************************************************************************
'  <<< [OpenTemp] >>> 
'*************************************************************************
Sub  OpenTemp( Opt, AppKey )
	path = GetTempPath( "." )
	Setting_openFolder  path
	WScript.Quit  E_TestPass
End Sub


 
'*************************************************************************
'  <<< [OpenVbsLib] >>> 
'*************************************************************************
Sub  OpenVbsLib( Opt, AppKey )
	Setting_openFolder  "."
	WScript.Quit  E_TestPass
End Sub


 
'*************************************************************************
'  <<< [Prompt] >>> 
'*************************************************************************
Sub  Prompt( Opt, AppKey )
	echo  " ((( VBScript プロンプト )))"
	echo  "? は、このプロンプトに結果を表示するコマンドです。"
	echo  "高機能な電卓として使うことができます。"
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
	echo  "-------------------------------------------------------------"
	echo  ""
	echo  "コマンドを入力してください。"

	Do
		command_line = Trim2( input( "> " ) )
		If command_line = "quit" Then  Exit Do

		is_zerox = ( InStr( command_line, "0x" ) > 0 )
		If is_zerox Then _
			command_line = Replace( command_line, "0x", "&h" )

		If Left( command_line, 1 ) = "?" Then

			If TryStart(e) Then  On Error Resume Next
				Execute  "command_line =  "+ Mid( command_line, 2 )
			If TryEnd Then  On Error GoTo 0
			If e.num <> 0 Then
				echo  e.desc : e.Clear
			Else
				If is_zerox Then _
					command_line = Replace( command_line, "&h", "0x" )
				echo  command_line
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
'  <<< [RegExpTest] >>> 
'*************************************************************************
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


'*************************************************************************
'  <<< [Rename_sth] >>> 
'*************************************************************************
Sub  Rename_sth( Opt, AppKey )
	Dim  m : Set m = new RenamerClass
	m.DoMode  AppKey
End Sub


 
'*************************************************************************
'  <<< [ReplaceShortcutFilesToFiles_sth] >>> 
'*************************************************************************
Sub  ReplaceShortcutFilesToFiles_sth( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  "ショートカット・ファイルを通常のファイルに変換します。"
	path = InputPath( "フォルダーのパス>", c.CheckFolderExists )
	Set w_= AppKey.NewWritable( path ).Enable()
	ReplaceShortcutFilesToFiles  path, Empty
End Sub


 
'*************************************************************************
'  <<< [ReplaceSymbols] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [RenamerClass] >>> 
'*************************************************************************
Class  RenamerClass
	Public  OperationHistory
	Public  FolderPathHistory
	Public  AddNameHistory

 
'*************************************************************************
'  <<< [RenamerClass::DoMode] >>> 
'*************************************************************************
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
			path = InputPath( "処理を行うフォルダのパス>", c.CheckFolderExists or c.AllowEnterOnly )
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

 
'*************************************************************************
'  <<< [RenamerClass::AddHeadOfFName] >>> 
'*************************************************************************
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



 
'*************************************************************************
'  <<< [RenamerClass::RenameHeadOfFName] >>> 
'*************************************************************************
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

 
'*************************************************************************
'  <<< [RenamerClass::DeleteHeadOfFName] >>> 
'*************************************************************************
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

 
'*************************************************************************
'  <<< [RenamerClass::DeleteTailOfFName] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [RenumberIniFileDataInClipboard_sth] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [SearchNewFile] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [SearchOpen] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [SetTask] >>> 
'*************************************************************************
Sub  SetTask( Opt, AppKey )
	echo  "タスクの開始時間を再設定します。"
	Dim  name : name = input( "タスク名（登録済みのもの）>" )
	echo  "例： 13:00 ... 今が午前10時なら、今日の午後1時に実行する"
	echo  "例：  1:00 ... 今が午前10時なら、明日の午前1時に実行する"
	echo  "例： +1:00 ... 今から1時間後に実行する"
	Dim  after : after = input( "いつ実行を開始しますか>" )
	SetTaskStartTime  name, after
End Sub


 
'*************************************************************************
'  <<< [shutdown_sth] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [SortLines_sth] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [SpaceToTab_sth] >>> 
'*************************************************************************
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
	ElseIf head_operation = "SpaceToTab" Then
		echo  "2) 行頭の空白文字→タブ文字 [SpaceToTab]"
		echo  ""
	Else
		echo  "1) 行頭のタブ文字→空白文字 [TabToSpace]"
		echo  "2) 行頭の空白文字→タブ文字 [SpaceToTab]"
		echo  "0) 行頭の文字は変換しない [NoChange]"
		head_operation = Input( "番号またはコマンド名を入力してください >" )
		If head_operation = "1" Then  head_operation = "TabToSpace"
		If head_operation = "2" Then  head_operation = "SpaceToTab"
		If head_operation = "0" Then  head_operation = "NoChange"
	End If
	Assert  head_operation = "TabToSpace"  or _
	        head_operation = "SpaceToTab"  or _
	        head_operation = "NoChange"

	echo  "1) 行頭以外のタブ文字→空白文字 [TabToSpace]（←Enterのみのとき）"
	echo  "2) 行頭以外の空白文字→タブ文字 [SpaceToTab]"
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


 
'*************************************************************************
'  <<< [SpaceToTabShort_sth] >>> 
'*************************************************************************
Sub  SpaceToTabShort_sth( Opt, AppKey )
	Set g = g_VBS_Lib

	SpaceToTabSub_sth  Opt, AppKey, "SpaceToTab"
End Sub


'*************************************************************************
'  <<< [TabToSpaceShort_sth] >>> 
'*************************************************************************
Sub  TabToSpaceShort_sth( Opt, AppKey )
	Set g = g_VBS_Lib

	SpaceToTabSub_sth  Opt, AppKey, "TabToSpace"
End Sub


 
'*************************************************************************
'  <<< [StopScreenSaver] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [ToRegularXML] >>> 
'*************************************************************************
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


 
'*************************************************************************
'  <<< [Translate_sth] >>> 
'*************************************************************************
Sub  Translate_sth( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  "英訳します。"
	translator = InputPath( "翻訳ファイル (*.trans) のパス >", c.CheckFileExists )
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


 
'*************************************************************************
'  <<< [TranslateTest_sth] >>> 
'*************************************************************************
Sub  TranslateTest_sth( Opt, AppKey )
	Set c = g_VBS_Lib
	echo  "英訳のテストをします。"
	translator = InputPath( "翻訳ファイル (*.trans) のパス >", c.CheckFileExists )

	echo  ""
	echo  "Enter のみ ： 出力しないで、翻訳後に日本語が残っていることをチェックします"
	out_path   = InputPath( "出力フォルダーのパス（上書きされます）>", c.AllowEnterOnly )
	echo  ""

	If out_path <> "" Then _
		Set w_=AppKey.NewWritable( out_path ).Enable()

	If TryStart(e) Then  On Error Resume Next
		TranslateTest  translator, "JP", "EN", out_path
	If TryEnd Then  On Error GoTo 0
	If e.num = get_ToolsLibConsts().E_NotEnglishChar  Then  echo e.desc : e.Clear
	If e.num <> 0 Then  e.Raise
End Sub


 
'*************************************************************************
'  <<< [TranslateTest_Install] >>> 
'*************************************************************************
Sub  TranslateTest_Install( Opt, AppKey )
	echo  "*.lines ファイルをダブルクリックすると、TranslateTestが起動するようにします。"
	Pause

	prompt_vbs = SearchParent( "vbslib Prompt.vbs" )
	command_line = GetCScriptGUI_CommandLine( "//nologo """+_
		prompt_vbs +""" TranslateTest ""%1"" """"" )
	InstallRegistryFileOpenCommand  "trans", "TranslateTest", command_line, True
End Sub


 
'*************************************************************************
'  <<< [TranslateTest_Uninstall] >>> 
'*************************************************************************
Sub  TranslateTest_Uninstall( Opt, AppKey )
	echo  "*.lines ファイルをダブルクリックしても、TranslateTestが起動しないようにします。"
	Pause

	UninstallRegistryFileOpenCommand  "trans", "TranslateTest"
End Sub


 
'*************************************************************************
'  <<< [TranslateToEnglishOld] >>> 
'*************************************************************************
Sub  TranslateToEnglishOld( Opt, AppKey )
	cd  g_fs.GetParentFolderName( WScript.ScriptFullName )

	Set args = WScript.Arguments.Unnamed

	If args.Count = 0 Then  Err.Raise 1,,"翻訳 CSV ファイルをドロップしてください"

	Set tr = new_TranslateToEnglish( args(0) )
	If ArgumentExist( "Reverse" ) Then  tr.IsReverseTranslate = True
	Set w_=AppKey.NewWritable( tr.Writable ).Enable()
	tr.Translate
End Sub


 
'*************************************************************************
'  <<< [TimeStampIfSame] >>> 
'*************************************************************************
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


 







'--- start of vbslib include ------------------------------------------------------ 

'// ここの内部から Main 関数を呼び出しています。
'// また、scriptlib フォルダーを探して、vbslib をインクルードしています

'// vbslib is provided under 3-clause BSD license.
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


 
