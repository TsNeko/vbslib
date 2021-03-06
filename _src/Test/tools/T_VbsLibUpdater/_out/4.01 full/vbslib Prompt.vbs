'// vbslib - Short Hand Library  ver4.01  Feb.14, 2013
'// vbslib is provided under 3-clause BSD license.
'// Copyright (C) 2007-2013 Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.


Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		o.Lead = "vbslib Prompt"

		Set o.MenuCaption = Dict(Array(_
			"1","ヘルプ(SVG形式)の表示 (Google Chrome や Snap Note で見えます)",_
			"2","ヘルプ(Internet Explorer 9 以前 - VML形式)の表示",_
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
			"ConvertToNewVbsLib", "ConvertToNewVbsLib_sth",_
			"CopyOnlyExist", "CopyOnlyExist_sth",_
			"CutLineFeedAtRightEnd", "CutLineFeedAtRightEnd_sth",_
			"fc",            "fc_sth",_
			"fdiv",          "fdiv_sth",_
			"feq",           "feq_sth",_
			"FindFile",      "FindFile_sth",_
			"GetStepPath",   "GetStepPath_sth",_
			"GetShortPath",  "GetShortPath_sth",_
			"grep",          "grep_sth",_
			"mkdir",         "mkdir_sth",_
			"OpenSendTo",    "OpenSendTo_sth",_
			"ren",           "Rename_sth",_
			"Rename",        "Rename_sth",_
			"SendTo",        "OpenSendTo_sth",_
			"shutdown",      "shutdown_sth",_
			"sh",            "shutdown_sth",_
			"SpaceToTab",    "SpaceToTab_sth",_
			"test",          "OpenTestTemplate",_
			"Translate",     "Translate_sth",_
			"TranslateTest", "TranslateTest_sth",_
			"TabToSpace",    "SpaceToTab_sth" ))

	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [BashSyntax] >>> 
'********************************************************************************
Sub  BashSyntax( Opt, AppKey )
	echo  "bash シェル・スクリプト・ファイルの "" "", ' ', ` ` の対応関係が"+_
	      "複数行にまたがっている場所を探します。"
	path = InputPath( "シェル・スクリプト・ファイルのパス >", F_ChkFileExists )

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


 
'********************************************************************************
'  <<< [CheckEnglishOnly] >>> 
'********************************************************************************
Sub  CheckEnglishOnly( Opt, AppKey )
	echo  "テキスト・ファイルの中に、英文字以外の文字が含まれるファイルを一覧します。"
	search_path = InputPath( "調べるフォルダーのパス>", F_ChkFolderExists )

	echo  ""
	echo  "Enter のみ：デフォルト設定を使う"
	set_path = InputPath( "除外ファイルなどの設定ファイル>", F_ChkFileExists or F_AllowEnterOnly )
	If set_path = "." Then  set_path = ""
	If set_path = "" Then  set_path = "samples\TranslateSrcsToEnglish\SettingForCheckEnglish.ini"

	Set founds = new_CheckEnglishOnly( search_path, set_path )

	For Each file  In founds.Items
		For Each found  In file.NotEnglishItems.Items
			echo  file.Path +"("& found.LineNum  &"): "+ found.NotEnglishText
		Next
	Next
End Sub


 
'********************************************************************************
'  <<< [ConvertToNewVbsLib_sth] >>> 
'********************************************************************************
Sub  ConvertToNewVbsLib_sth( Opt, AppKey )
	echo "古い vbslib を使ったスクリプトを、最新の vbslib が使えるようにします。"
	echo "  ver 1,2,3 → ver4"
	echo "事前に変換を行うフォルダーのバックアップをとっておいてください。"
	path = InputPath( "変換を行うフォルダーのパス >", F_ChkFolderExists )
	echo_line

	Set w_=AppKey.NewWritable( path ).Enable()
	ConvertToVbsLib4  path
End Sub


 
'********************************************************************************
'  <<< [CopyOnlyExist_sth] >>> 
'********************************************************************************
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


 
'********************************************************************************
'  <<< [CreateTask] >>> 
'********************************************************************************
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


 
'********************************************************************************
'  <<< [CutLineFeedAtRightEnd_sth] >>> 
'********************************************************************************
Sub  CutLineFeedAtRightEnd_sth( Opt, AppKey )
	echo  "コマンドプロンプトの右端からあふれた文字列を１行にまとめます。"

	path = InputPath( "ファイルのパス>", F_ChkFileExists )
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

	CreateFile  path, CutLineFeedAtRightEnd( ReadFile( path ), width )

	ec = Empty
	echo  "ファイルを変更しました。"
End Sub


 
'********************************************************************************
'  <<< [DelTemp] >>> 
'********************************************************************************
Sub  DelTemp( Opt, AppKey )
	path = GetTempPath( "." )
	echo "下記のフォルダを削除します。"
	echo  path
	Pause
	Set w_=AppKey.NewWritable( path ).Enable()
	del  path
End Sub


 
'********************************************************************************
'  <<< [Diff] >>> 
'********************************************************************************
Sub  Diff( Opt, AppKey )
	echo "[Diff] テキストファイルの比較"

	path1 = InputPath( "path1>", F_ChkFileExists )
	path2 = InputPath( "path2>", F_ChkFileExists )

	echo  ""
	echo  "Enter のみ ： 2つのファイルの比較"
	path3 = InputPath( "path3>", F_ChkFileExists or F_AllowEnterOnly )
	echo ""

	If path3 = "" Then
		start  GetDiffCmdLine( path1, path2 )
	Else
		start  GetDiffCmdLine3( path1, path2, path3 )
	End If
End Sub


 
'********************************************************************************
'  <<< [DiffClip] >>> 
'********************************************************************************
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


 
'********************************************************************************
'  <<< [fc_sth] >>> 
'********************************************************************************
Sub  fc_sth( Opt, AppKey )
	Do
		echo "[fc] Compare text file"

		path1 = InputPath( "path1>", F_ChkFileExists or F_ChkFolderExists or F_AllowEnterOnly )
		If path1 = "" Then  Exit Do

		echo  ""
		echo  "入力例： Shift_JIS, EUC-JP, Unicode, UTF-8, UTF-8-No-BOM, ISO-8859-1"
		echo  "Enter のみ ： 自動判定"
		cs1 = input( "文字コードセット >" )
		If cs1 = "" Then  cs1 = Empty

		echo  ""
		path2 = InputPath( "path2>", F_ChkFileExists or F_ChkFolderExists )
		echo  ""
		cs2 = input( "文字コードセット >" )
		If cs2 = "" Then  cs2 = Empty
		echo  ""

		If IsSameTextFile( path1, cs1, path2, cs2, Empty ) Then
			If IsSameBinaryFile( path1, path2, Empty ) Then
				echo  "same text, same binary."
			Else
				echo  "same text, different binary."
			End IF
		Else
			echo  "different."
		End If

		echo ""
		key = input( "もう一度検索しますか。[Y/N]" )
		If key<>"y" and key<>"Y" Then   Exit Do
	Loop
End Sub


 
'********************************************************************************
'  <<< [fc_patch] >>> 
'********************************************************************************
Sub  fc_patch( Opt, AppKey )
	Set section = new SkipSection

	echo_line
	echo  "パッチ・フォルダーにあるファイルと同じ内容のファイルが全体のフォルダーにあるかチェックします。"
	patch_path = InputPath( "パッチ・フォルダー>", F_ChkFolderExists )
	whole_path = InputPath( "全体のフォルダー>", F_ChkFolderExists )
	echo_line

	equal_count = 0 : diff_count = 0
	ExpandWildcard  GetAbsPath( "*", patch_path ), F_File or F_SubFolder, folder, fnames
	For Each fname  In fnames
		If section.Start() Then
			echo_line
			b = fc( GetAbsPath( fname, folder ), GetAbsPath( fname, whole_path ) )
			echo  b
			If b Then  equal_count = equal_count + 1  Else  diff_count = diff_count + 1
			echo  "equal_count = "& equal_count & ",  diff_count  = "& diff_count
			section.End_
		End If
	Next
End Sub


 
'********************************************************************************
'  <<< [fdiv_sth] >>> 
'********************************************************************************
Sub  fdiv_sth( Opt, AppKey )
	If WScript.Arguments.Unnamed.Count >= 1 Then
		input_path = WScript.Arguments.Unnamed(0)
	Else
		input_path = InputPath( "分割するファイル >", F_ChkFileExists )
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

	out_base_path = GetAbsPath( g_fs.GetBaseName( input_path ) +"\"+ g_fs.GetFileName( input_path ), _
		GetParentAbsPath( input_path ) )

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


 
'********************************************************************************
'  <<< [feq_sth] >>> 
'********************************************************************************
Sub  feq_sth( Opt, AppKey )
	Do
		echo "[feq] ２つのバイナリファイル、またはフォルダーが同じかどうかを調べます。"

		path1 = InputPath( "path1>", F_ChkFileExists or F_ChkFolderExists )
		path2 = InputPath( "path2>", F_ChkFileExists or F_ChkFolderExists )
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


 
'********************************************************************************
'  <<< [FindFile_sth] >>>
'********************************************************************************
Sub  FindFile_sth( Opt, AppKey )
	folder_path = InputPath( "探す場所（フォルダのパス）>", F_ChkFolderExists )
	keyword = LCase( input( "ファイル名のすべてまたは一部>" ) )
	echo  ""

	EnumFolderObject  folder_path, folders  '// [out] folders
	For Each fo  In folders
		If InStr( LCase( fo.Name ), keyword ) > 0 Then  echo  fo.Path
		For Each fi  In fo.Files
			If InStr( LCase( fi.Name ), keyword ) > 0 Then  echo  fi.Path
		Next
	Next
	echo  ""
End Sub


 
'********************************************************************************
'  <<< [GetStepPath_sth] >>>
'********************************************************************************
Sub  GetStepPath_sth( Opt, AppKey )
  echo  "絶対パスから相対パスに変換します。"
  abs_path  = input( "絶対パス>" )
  base_path = input( "基準フォルダの絶対パス>" )

  step_path = GetStepPath( abs_path, base_path )
  echo  step_path
End Sub


 
'********************************************************************************
'  <<< [GetShortPath_sth] >>>
'********************************************************************************
Sub  GetShortPath_sth( Opt, AppKey )
  Set c = g_VBS_Lib
  echo  "短いパス（ファイルやフォルダーの 8.3形式パス）に変換します。"
  long_path  = InputPath( "（長い）パス>", c.CheckFileExists or c.CheckFolderExists )
  echo  g_fs.GetFile( long_path ).ShortPath
End Sub


 
'********************************************************************************
'  <<< [grep_sth] >>> 
'********************************************************************************
Sub  grep_sth( Opt, AppKey )
	Do
		echo "[grep] ファイルの中のテキストを検索します"

		If not IsEmpty( target ) Then  echo  "Enter のみ ： "+ target
		key = InputPath( "検索対象フォルダー、またはファイル >", _
			F_ChkFileExists or F_ChkFolderExists or F_AllowEnterOnly )
		If key <> "" Then  target = key
		If g_fs.FolderExists( target ) Then  target = target + "\*"

		echo  ""
		echo  "正規表現の メタ文字 一覧：. $ ^ { } [ ] ( ) | * + ? \"
		If not IsEmpty( keyword ) Then  echo  "Enter のみ ： "+ keyword
		key = input( "キーワード（正規表現）>" )
		If key <> "" Then  keyword = key

		echo  ""
		echo  "Enter のみ ： 表示のみ"
		out = InputPath( "結果の出力先ファイル（上書きします）>", F_AllowEnterOnly )
		If out = "" Then  out = Empty

		echo ""
		If not IsEmpty( out ) Then  Set w_=AppKey.NewWritable( out ).Enable()
		grep  "-r """+ keyword +""" """+ target +"""", out
		w_ = Empty
		echo ""

		key = input( "もう一度検索しますか。[Y/N]" )
		If key<>"y" and key<>"Y" Then   Exit Do
	Loop
End Sub


 
'********************************************************************************
'  <<< [LAN_Path] >>> 
'********************************************************************************
Sub  LAN_Path( Opt, AppKey )
	Set w_= AppKey.NewWritable( "." ).Enable()

	echo  "\\ から始まる LAN のアドレスを file:// 形式に変換します。"

	lan_path = InputPath( "LAN のアドレスが書かれたファイルのパス>", F_ChkFileExists )
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


 
'********************************************************************************
'  <<< [MakeNewScript] >>> 
'********************************************************************************
Sub  MakeNewScript( Opt, AppKey )
	MakeNewScriptSub  AppKey, "Sample.vbs", "samples\sample.vbs"
	WScript.Quit  E_TestPass
End Sub


Sub  MakeNewScriptSub( AppKey, DefaultNewVBS_Path, TemplatePath )

	'// 作成するファイル名をユーザーに要求します
	echo  "Enter のみ : デスクトップに "+ DefaultNewVBS_Path +" を作成します。"
	start_in_path_backup = g_start_in_path
	g_start_in_path = g_sh.SpecialFolders( "Desktop" )
	new_vbs_path = InputPath( "作成するファイルの名前>", F_AllowEnterOnly )
	g_start_in_path = start_in_path_backup


	'// ファイル名を調整します
	If new_vbs_path = "" Then _
		new_vbs_path = GetAbsPath( DefaultNewVBS_Path, g_sh.SpecialFolders( "Desktop" ) )
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


 
'********************************************************************************
'  <<< [MakeNewPrompt] >>> 
'********************************************************************************
Sub  MakeNewPrompt( Opt, AppKey )
	MakeNewScriptSub  AppKey, "Prompt.vbs", "samples\sample_short_hand_prompt.vbs"

	echo_line
	echo  "vbs ファイルを作成しました。"
	echo  "テキスト・エディターで、vbs ファイルの最後にある NewScript 関数を編集してください。"
	echo  "vbs ファイルをダブルクリックすると編集した内容を実行します。"
End Sub


 
'********************************************************************************
'  <<< [mkdir_sth] >>>
'********************************************************************************
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


 
'********************************************************************************
'  <<< [OpenFolder] >>> 
'********************************************************************************
Sub  OpenFolder( Opt, AppKey )
	echo  "ファイルのパスを入力すると、そのファイルを含むフォルダーを開きます。"
	path = InputPath( "ファイルのパス >", F_ChkFileExists or F_ChkFolderExists )
	Setting_openFolder  path
End Sub


 
'********************************************************************************
'  <<< [OpenSendTo_sth] >>> 
'********************************************************************************
Sub  OpenSendTo_sth( Opt, AppKey )
	Setting_openFolder  g_sh.SpecialFolders( "SendTo" )
End Sub


 
'********************************************************************************
'  <<< [OpenShorHandLibHelpSVG] >>> 
'********************************************************************************
Sub  OpenShorHandLibHelpSVG( Opt, AppKey )
	start  "_src\vbslib.svg"
End Sub


 
'********************************************************************************
'  <<< [OpenShorHandLibHelpHtml] >>> 
'********************************************************************************
Sub  OpenShorHandLibHelpHtml( Opt, AppKey )
	start  g_sh.ExpandEnvironmentStrings( _
	 """%ProgramFiles%\Internet Explorer\iexplore.exe"" """+ g_sh.CurrentDirectory +_
	 "\_src\_vbslib manual.files\vbslib.html""" )
End Sub


 
'********************************************************************************
'  <<< [OpenShorHandPromptSrc] >>> 
'********************************************************************************
Sub  OpenShorHandPromptSrc( Opt, AppKey )
	start  GetEditorCmdLine( WScript.ScriptFullName )
End Sub


 
'********************************************************************************
'  <<< [OpenTask] >>> 
'********************************************************************************
Sub  OpenTask( Opt, AppKey )
	echo  ">OpenTask"
	Dim  ec : Set ec = new EchoOff
	If GetOSVersion() <= 5.1 Then
		start  "explorer  ::{D6277990-4C6A-11CF-8D87-00AA0060F5BF}"
	Else
		start  "taskschd.msc /s"
	End If
End Sub


 
'********************************************************************************
'  <<< [OpenTestTemplate] >>> 
'********************************************************************************
Sub  OpenTestTemplate( Opt, AppKey )
	Setting_openFolder  "samples\Test"
	WScript.Quit  E_TestPass
End Sub


 
'********************************************************************************
'  <<< [OpenTemp] >>> 
'********************************************************************************
Sub  OpenTemp( Opt, AppKey )
	path = GetTempPath( "." )
	Setting_openFolder  path
	WScript.Quit  E_TestPass
End Sub


 
'********************************************************************************
'  <<< [OpenVbsLib] >>> 
'********************************************************************************
Sub  OpenVbsLib( Opt, AppKey )
	Setting_openFolder  "."
	WScript.Quit  E_TestPass
End Sub


 
'********************************************************************************
'  <<< [Prompt] >>> 
'********************************************************************************
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


 
'********************************************************************************
'  <<< [Rename_sth] >>> 
'********************************************************************************
Sub  Rename_sth( Opt, AppKey )
	Dim  m : Set m = new RenamerClass
	m.DoMode  AppKey
End Sub


 
'********************************************************************************
'  <<< [ReplaceSymbols] >>> 
'********************************************************************************
Sub  ReplaceSymbols( Opt, AppKey )
	Set ds = new CurDirStack
	Set c = g_VBS_Lib

	path = InputPath( "ReplaceSymbols の設定ファイルのパス>", c.CheckFileExists )

	Set rep = new ReplaceSymbolsClass
	rep.Load  path, Empty

	pushd  GetParentAbsPath( path )
	Set w_= AppKey.NewWritable( rep.TargetPaths.Items ).Enable()
	rep.ReplaceFiles
	popd
End Sub


 
'********************************************************************************
'  <<< [RenamerClass] >>> 
'********************************************************************************
Class  RenamerClass
	Public  OperationHistory
	Public  FolderPathHistory
	Public  AddNameHistory

 
'********************************************************************************
'  <<< [RenamerClass::DoMode] >>> 
'********************************************************************************
Public Sub  DoMode( AppKey )
	Dim  op, path, w_

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
			path = InputPath( "処理を行うフォルダのパス>", F_ChkFolderExists or F_AllowEnterOnly )
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

 
'********************************************************************************
'  <<< [RenamerClass::AddHeadOfFName] >>> 
'********************************************************************************
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



 
'********************************************************************************
'  <<< [RenamerClass::RenameHeadOfFName] >>> 
'********************************************************************************
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

 
'********************************************************************************
'  <<< [RenamerClass::DeleteHeadOfFName] >>> 
'********************************************************************************
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

 
'********************************************************************************
'  <<< [RenamerClass::DeleteTailOfFName] >>> 
'********************************************************************************
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


 
'********************************************************************************
'  <<< [SearchNewFile] >>> 
'********************************************************************************
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
		out2_path = GetAbsPath( WScript.Arguments.Named.Item("out"), g_start_in_path )
		Set w_=AppKey.NewWritable( out2_path ).Enable()
		copy_ren  out_path,  out2_path
	Else
		start  """" + out_path + """"
	End If
End Sub


 
'********************************************************************************
'  <<< [SearchOpen] >>> 
'********************************************************************************
Sub  SearchOpen( Opt, AppKey )
	echo "[SearchOpen]"
	echo "指定のパスのテキストファイルを開いて、指定の行番号またはキーワードを検索します。"
	path = InputPath( "path>", F_ChkFileExists )

	start  GetEditorCmdLine( path )
End Sub


 
'********************************************************************************
'  <<< [SetTask] >>> 
'********************************************************************************
Sub  SetTask( Opt, AppKey )
	echo  "タスクの開始時間を再設定します。"
	Dim  name : name = input( "タスク名（登録済みのもの）>" )
	echo  "例： 13:00 ... 今が午前10時なら、今日の午後1時に実行する"
	echo  "例：  1:00 ... 今が午前10時なら、明日の午前1時に実行する"
	echo  "例： +1:00 ... 今から1時間後に実行する"
	Dim  after : after = input( "いつ実行を開始しますか>" )
	SetTaskStartTime  name, after
End Sub


 
'********************************************************************************
'  <<< [shutdown_sth] >>> 
'********************************************************************************
Sub  shutdown_sth( Opt, AppKey )
	echo  "1) PowerOff : 電源を切る"
	echo  "2) Reboot : 再起動"
	echo  "3) Hibernate"
	echo  "4) Sleep : スリープ"
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


 
'********************************************************************************
'  <<< [SpaceToTab_sth] >>> 
'********************************************************************************
Sub  SpaceToTab_sth( Opt, AppKey )
	Set g = g_VBS_Lib

	echo  "テキストファイルのタブ文字と空白文字を変換します。"
	echo  "1) 行頭のタブ文字→空白文字 [TabToSpace]"
	echo  "2) 行頭の空白文字→タブ文字 [SpaceToTab]"
	echo  "0) 行頭の文字は変換しない [NoChange]"
	head_operation = Input( "番号またはコマンド名を入力してください >" )
	If head_operation = "1" Then  head_operation = "TabToSpace"
	If head_operation = "2" Then  head_operation = "SpaceToTab"
	If head_operation = "0" Then  head_operation = "NoChange"
	Assert  head_operation = "TabToSpace"  or _
	        head_operation = "SpaceToTab"  or _
	        head_operation = "NoChange"

	echo  "1) 行頭以外のタブ文字→空白文字 [TabToSpace]"
	echo  "2) 行頭以外の空白文字→タブ文字 [SpaceToTab]"
	echo  "0) 行頭以外の文字は変換しない [NoChange]"
	mid_operation = Input( "番号またはコマンド名を入力してください >" )
	If mid_operation = "1" Then  mid_operation = "TabToSpace"
	If mid_operation = "2" Then  mid_operation = "SpaceToTab"
	If mid_operation = "0" Then  mid_operation = "NoChange"
	Assert  mid_operation = "TabToSpace"  or _
	        mid_operation = "SpaceToTab"  or _
	        mid_operation = "NoChange"

	tab_size = CInt2( Input( "タブ文字のサイズ >" ) )
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
		Else
			Exit Do
		End If
	Loop
End Sub


 
'********************************************************************************
'  <<< [StopScreenSaver] >>> 
'********************************************************************************
Sub  StopScreenSaver( Opt, AppKey )
	echo  "30秒ごとに自動的にシフトキーを押すことで、スクリーンセーバーを起動しないようにします。"
	last = Eval( input( "スクリーンセーバーを停止する時間（分）> " ) )

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
End Sub


 
'********************************************************************************
'  <<< [ToRegularXML] >>> 
'********************************************************************************
Sub  ToRegularXML( Opt, AppKey )
	Set c = g_VBS_Lib

	path = InputPath( "整形する XML ファイルのパス >", c.CheckFileExists )

	temp_path = GetTempPath( "ToRegularXML_*.xml" )
	copy_ren  path, temp_path
	echo  "バックアップ： """+ temp_path +""""

	Set root = LoadXML( path, Empty )
	root.ownerDocument.save  path
	echo  "整形しました。"
End Sub


 
'********************************************************************************
'  <<< [Translate_sth] >>> 
'********************************************************************************
Sub  Translate_sth( Opt, AppKey )
	echo  "英訳します。"
	translator = InputPath( "翻訳ファイル (*.trans) のパス >", F_ChkFileExists )
	out_paths = Translate_getOverwritePaths( translator )
	echo  "次のファイルを上書きします。"
	For Each  path  In  out_paths : echo  path : Next
	pause
	Set w_=AppKey.NewWritable( Translate_getWritable( translator ) ).Enable()

	Translate  translator, "JP", "EN"
End Sub


 
'********************************************************************************
'  <<< [TranslateTest_sth] >>> 
'********************************************************************************
Sub  TranslateTest_sth( Opt, AppKey )
	echo  "英訳のテストをします。"
	translator = InputPath( "翻訳ファイル (*.trans) のパス >", F_ChkFileExists )

	echo  ""
	echo  "Enter のみ ： 出力しないで、翻訳後に日本語が残っていることをチェックします"
	out_path   = InputPath( "出力フォルダーのパス（上書きされます）>", F_AllowEnterOnly )
	echo  ""

	If out_path <> "" Then _
		Set w_=AppKey.NewWritable( out_path ).Enable()

	If TryStart(e) Then  On Error Resume Next
		TranslateTest  translator, "JP", "EN", out_path
	If TryEnd Then  On Error GoTo 0
	If e.num = get_ToolsLibConsts().E_NotEnglishChar  Then  echo e.desc : e.Clear
	If e.num <> 0 Then  e.Raise
End Sub


 
'********************************************************************************
'  <<< [TranslateTest_Install] >>> 
'********************************************************************************
Sub  TranslateTest_Install( Opt, AppKey )
	echo  "*.lines ファイルをダブルクリックすると、TranslateTestが起動するようにします。"
	Pause

	prompt_vbs = SearchParent( "vbslib Prompt.vbs" )
	command_line = GetCScriptGUI_CommandLine( "//nologo """+_
		prompt_vbs +""" TranslateTest ""%1"" """"" )
	InstallRegistryFileOpenCommand  "trans", "TranslateTest", command_line, True
End Sub


 
'********************************************************************************
'  <<< [TranslateTest_Uninstall] >>> 
'********************************************************************************
Sub  TranslateTest_Uninstall( Opt, AppKey )
	echo  "*.lines ファイルをダブルクリックしても、TranslateTestが起動しないようにします。"
	Pause

	UninstallRegistryFileOpenCommand  "trans", "TranslateTest"
End Sub


 
'********************************************************************************
'  <<< [TranslateToEnglishOld] >>> 
'********************************************************************************
Sub  TranslateToEnglishOld( Opt, AppKey )
	cd  g_fs.GetParentFolderName( WScript.ScriptFullName )

	Set args = WScript.Arguments.Unnamed

	If args.Count = 0 Then  Err.Raise 1,,"翻訳 CSV ファイルをドロップしてください"

	Set tr = new_TranslateToEnglish( args(0) )
	If ArgumentExist( "Reverse" ) Then  tr.IsReverseTranslate = True
	Set w_=AppKey.NewWritable( tr.Writable ).Enable()
	tr.Translate
End Sub


 
'********************************************************************************
'  <<< [TimeStampIfSame] >>> 
'********************************************************************************
Sub  TimeStampIfSame( Opt, AppKey )
	echo  "２つのフォルダーを比較して、同じ内容であれば、タイムスタンプをそろえます"

	folder1 = InputPath( "フォルダー１ >", F_ChkFolderExists )
	echo  "フォルダー２は、タイムスタンプを変更します。"
	folder2 = InputPath( "フォルダー２ >", F_ChkFolderExists )

	file_count = 0
	echo  "フォルダーを調べています…"
	ExpandWildcard  folder2 +"\*", F_File or F_SubFolder, folder, fnames

	Set w_=AppKey.NewWritable( folder2 ).Enable()

	For Each fname  In fnames
		path1 = GetAbsPath( fname, folder1 )
		path2 = GetAbsPath( fname, folder )
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

	g_debug = 0   '// release:0, debug:99, -1:call SetupDebugTools
	              '// ＭＳオフィスやコンパイラがあれば、g_debug を 1 以上にするとデバッガーが使えます。
	              '// ステップ実行を開始する場所や、変数の値を確認したい場所に、Stop 命令を記述してください。

	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------


 
