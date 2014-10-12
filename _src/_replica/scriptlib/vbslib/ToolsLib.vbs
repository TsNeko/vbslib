'// vbslib - VBScript ShortHand Library  ver4.91  Oct.13, 2014
'// vbslib is provided under 3-clause BSD license.
'// Copyright (C) 2007-2014 Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.

Dim  g_SrcPath
Dim  g_ToolsLib_Path
     g_ToolsLib_Path = g_SrcPath


 
'********************************************************************************
'  <<< [get_ToolsLibConsts] >>> 
'********************************************************************************
Dim  g_ToolsLibConsts

Function    get_ToolsLibConsts()
	If IsEmpty( g_ToolsLibConsts ) Then _
		Set g_ToolsLibConsts = new ToolsLibConsts
	Set get_ToolsLibConsts =   g_ToolsLibConsts
End Function


Class  ToolsLibConsts
	Public  E_NotEnglishChar, E_ManyConmaCSV

	Private Sub  Class_Initialize()
		E_NotEnglishChar = &h80045001
		E_ManyConmaCSV   = &h80045002
	End Sub
End Class


 
'-------------------------------------------------------------------------
' ### <<<< [ReplaceSymbolsClass] >>>> 
'-------------------------------------------------------------------------

Class  ReplaceSymbolsClass
	Public  IsSubmit        '// as boolean
	Public  XML_Path        '// as string
	Public  TargetPaths     '// as ArrayClass of string
	Public  ExceptPaths     '// as ArrayClass of string
	Public  ReplaceSymbols  '// as dictionary. key is from, item is ReplaceSymbolsElementClass
	Public  RegExp          '// as VBScript.RegExp : for setting only
	Public  m_RegExps       '// as dictionary. key is from, item is VBScript.RegExp
	Public  CheckExists     '// as ArrayClass of VBScript.RegExp


Private Sub  Class_Initialize()
	Me.IsSubmit = True
	Set Me.TargetPaths = new ArrayClass
	Set Me.ExceptPaths = new ArrayClass
	Set Me.ReplaceSymbols = CreateObject( "Scripting.Dictionary" )
	Set Me.RegExp = CreateObject("VBScript.RegExp")
	Me.RegExp.Global = True
	Me.RegExp.IgnoreCase = False
	Set Me.CheckExists = new ArrayClass
End Sub


'//[ReplaceSymbolsClass::Load]
Public Sub  Load( XML_Path, in_out_ReplaceSymbolsLoadConfig )

	If IsEmpty( in_out_ReplaceSymbolsLoadConfig ) Then _
		Set in_out_ReplaceSymbolsLoadConfig = new ReplaceSymbolsLoadConfigClass
	Set config = in_out_ReplaceSymbolsLoadConfig
	If IsEmpty( config.IsReverse ) Then _
		config.IsReverse = False

	Me.XML_Path = GetFullPath( XML_Path, Empty )

	Set root = LoadXML( XML_Path, Empty )

	Me.TargetPaths.ToEmpty
	Me.ExceptPaths.ToEmpty
	Me.ReplaceSymbols.RemoveAll

	For Each elem  In root.selectNodes( "./Target" )
		Me.TargetPaths.Add  elem.getAttribute( "path" )
	Next

	For Each elem  In root.selectNodes( "./Except" )
		Raise  1, "Not supported"
		Me.ExceptPaths.Add  elem.getAttribute( "path" )
	Next

	'// Add to "Me.ReplaceSymbols"
	For Each elem  In root.selectNodes( "./Replace" )
		Set element = new ReplaceSymbolsElementClass

		If not config.IsReverse Then
			element.ToWord = Me.GetToSymbol( elem )
		Else
			element.ToWord = Me.GetFromSymbol( elem )
		End If

		whole_word = elem.getAttribute( "whole_word" )
		If IsNull( whole_word ) Then
			element.IsWholeWord = True
		Else
			If whole_word = "yes" Then
				element.IsWholeWord = True
			Else
				element.IsWholeWord = False
			End If
		End If

		If not config.IsReverse Then
			Me.ReplaceSymbols.Add  Me.GetFromSymbol( elem ), element
		Else
			Me.ReplaceSymbols.Add  Me.GetToSymbol( elem ), element
		End If
	Next

	'// Add to "Me.CheckExists"
	For Each elem  In root.selectNodes( "./CheckExist" )
		Set element = new ReplaceSymbolsCheckExistClass
		Set element.RegExp = CreateObject("VBScript.RegExp")

		whole_word = elem.getAttribute( "whole_word" )
		keyword = elem.getAttribute( "keyword" )
		element.Keyword = keyword

		If IsNull( whole_word ) Then
			is_whole_word = True
		Else
			If whole_word = "yes" Then
				is_whole_word = True
			Else
				is_whole_word = False
			End If
		End If

		If is_whole_word Then
			If Left( keyword, 1 ) = "#" Then
				element.RegExp.Pattern = ToRegExpPattern( keyword ) +"\b"
			Else
				element.RegExp.Pattern = "\b"+ ToRegExpPattern( keyword ) +"\b"
			End If
		Else
			element.RegExp.Pattern = ToRegExpPattern( keyword )
		End If

		Me.CheckExists.Add  element
	Next
End Sub


'//[ReplaceSymbolsClass::GetToSymbol]
Function  GetToSymbol( XML_Element )
	GetToSymbol = XML_Element.getAttribute( "to" )
	Set to_tag = XML_Element.selectSingleNode("To")
	If IsNull( GetToSymbol ) Then
		If to_tag is Nothing Then
			Raise 1, "<ERROR msg=""Not exist 'to' attribute or 'To' tag""/>"
		Else
			GetToSymbol = to_tag.text
		End If
	Else
		If not to_tag is Nothing Then
			Raise 1, "<ERROR msg=""Both exist 'to' attribute and 'To' tag""/>"
		End If
	End If
	GetToSymbol = Replace( GetToSymbol, vbLF, vbCRLF )
End Function


'//[ReplaceSymbolsClass::GetFromSymbol]
Function  GetFromSymbol( XML_Element )
	GetFromSymbol = XML_Element.getAttribute( "from" )
	Set from_tag = XML_Element.selectSingleNode("From")
	If IsNull( GetFromSymbol ) Then
		If from_tag is Nothing Then
			Raise 1, "<ERROR msg=""Not exist 'from' attribute or 'From' tag""/>"
		Else
			GetFromSymbol = from_tag.text
		End If
	Else
		If not from_tag is Nothing Then
			Raise 1, "<ERROR msg=""Both exist 'from' attribute and 'From' tag""/>"
		End If
	End If
	GetFromSymbol = Replace( GetFromSymbol, vbLF, vbCRLF )
End Function


'//[ReplaceSymbolsClass::ReplaceFiles]
Public Sub  ReplaceFiles()
	Set c = g_VBS_Lib
	Set ds = new CurDirStack
	cd  g_fs.GetParentFolderName( Me.XML_Path )

	echo  g_sh.CurrentDirectory +">ReplaceSymbols "+ g_fs.GetFileName( Me.XML_Path )
	echo  "シンボルを置き換えます。"
	echo  g_fs.GetFileName( Me.XML_Path ) + " ファイルの内容を確認してください。"

	If Me.IsSubmit Then  Pause

	'// Set "Me.m_RegExps"
	Set Me.m_RegExps = CreateObject( "Scripting.Dictionary" )
	For Each from_word  In Me.ReplaceSymbols.Keys
		Set element = Me.ReplaceSymbols.Item( from_word )
		Set reg_exp = CreateObject("VBScript.RegExp")
		If element.IsWholeWord Then
			If Left( from_word, 1 ) = "#" Then
				reg_exp.Pattern = ToRegExpPattern( from_word ) +"\b"
			Else
				reg_exp.Pattern = "\b"+ ToRegExpPattern( from_word ) +"\b"
			End If
		Else
			reg_exp.Pattern = ToRegExpPattern( from_word )
		End If
		reg_exp.Global = Me.RegExp.Global
		reg_exp.IgnoreCase = Me.RegExp.IgnoreCase
		Set Me.m_RegExps.Item( from_word ) = reg_exp
	Next

	For Each target_path  In Me.TargetPaths.Items

		'// Set target "paths"
		If g_fs.FileExists( target_path ) Then
			paths = Array( target_path )
		ElseIf g_fs.FolderExists( target_path ) Then
			ExpandWildcard  target_path +"\*", c.File or c.SubFolder or c.AbsPath, dummy, paths
		ElseIf IsWildcard( target_path ) Then
			ExpandWildcard  target_path, c.File or c.SubFolder or c.AbsPath, dummy, paths
		Else  '// not found
			echo  "<WARNING msg=""見つかりません"" path="""+ target_path +"""/>"
			paths = Array( )
		End If


		'// Call
		For Each path  In paths
			ReplaceFile  path  '// Me.ReplaceFile
		Next
	Next

	Me.m_RegExps = Empty
End Sub


'//[ReplaceSymbolsClass::ReplaceFile]
Private Sub  ReplaceFile( Path )
	text = ReadFile( Path )
	is_overwrite = False
	For Each from_word  In Me.ReplaceSymbols.Keys
		Set reg_exp = Me.m_RegExps.Item( from_word )
		If reg_exp.Test( text ) Then
			Set element = Me.ReplaceSymbols.Item( from_word )
			to_word = element.ToWord
			text = reg_exp.Replace( text, to_word )
			is_overwrite = True
		End If
	Next
	If is_overwrite Then
		echo  path
		Set ec = new EchoOff
		Set cs = new_TextFileCharSetStack( ReadUnicodeFileBOM( Path ) )
		CreateFile  path, text
		ec = Empty
	End If
	For Each element  In Me.CheckExists.Items
		If not element.RegExp.Test( text ) Then
			Raise 1, "<ERROR msg=""Not found keyword"" keyword="""+ element.Keyword +"""/>"
		End If
	Next
End Sub


End Class


Class  ReplaceSymbolsLoadConfigClass
	Public  IsReverse  '// as boolean
End Class

Class  ReplaceSymbolsElementClass
	Public  ToWord       '// as string
	Public  IsWholeWord  '// as boolean
End Class

Class  ReplaceSymbolsCheckExistClass
	Public  Keyword   '// as string
	Public  RegExp    '// as VBScript.RegExp
End Class


 
'********************************************************************************
'  <<< [ConvSymbol] >>> 
'********************************************************************************
Sub  ConvSymbol( InPath, OutPath, Opt )
	Dim  rf, wf, line, columns, o
	Dim  defines : Set defines = new ArrayClass
	Const  s_define = "#define"

	echo  ">ConvSymbol  """+ InPath +""", """+ OutPath +""""
	Dim ec : Set ec = new EchoOff

	g_Vers("CutPropertyM") = True

	If Opt.InType <> "CDefine" Then _
		Raise  1, "<ERROR msg=""not supported"" in_type="""+ Opt.InType +"""/>"

	If Opt.OutType <> "CLang" Then _
		Raise  1, "<ERROR msg=""not supported"" out_type="""+ Opt.OutType +"""/>"

	If IsEmpty( Opt.StrsFuncName ) Then  Opt.StrsFuncName = "g_Symbols_strs"
	If IsEmpty( Opt.IDsFuncName )  Then  Opt.IDsFuncName  = "g_Symbols_ids"


	'//=== input
	Set rf = OpenForRead( InPath )
	Do Until  rf.AtEndOfStream
		line = rf.ReadLine()

		If InStr( line, s_define ) > 0 Then
			columns = ArrayFromCmdLine( line )
			Set o = defines.AddNewObject( "SymbolDefine", columns(1) )
			o.DefinedValue = columns(2)
		End If
	Loop
	rf = Empty


	'//=== output
	Set wf = OpenForWrite( OutPath, Empty )
	wf.WriteLine  "#include  <tchar.h>"
	wf.WriteLine  ""
	wf.WriteLine  "const TCHAR*  "+ Opt.StrsFuncName +"["& defines.Count &"] = {"
	For Each o  In defines.Items
		wf.WriteLine  "  _T("""+ o.Name +"""),"
	Next
	wf.WriteLine  "};"
	wf.WriteLine  "int  "+ Opt.IDsFuncName +"["& defines.Count &"] = {"
	For Each o  In defines.Items
		wf.WriteLine  "  "+ o.DefinedValue +","
	Next
	wf.WriteLine  "};"
	wf = Empty
End Sub


Class  ConvSymbolOption
	Public  InType
	Public  OutType
	Public  StrsFuncName
	Public  IDsFuncName
End Class


 
'-------------------------------------------------------------------------
' ### <<<< [SymbolDefine] Class >>>> 
'-------------------------------------------------------------------------
Function  new_SymbolDefine()
	Set new_SymbolDefine = new SymbolDefine
End Function

Class  SymbolDefine
	Public  Name
	Public  DefinedValue

 
End Class 


 
'********************************************************************************
'  <<< [ConvertToNewVbsLib] >>> 
'********************************************************************************
Sub  ConvertToNewVbsLib( FolderPath )
	ConvertToNewVbsLib_MainFile  FolderPath
	ConvertToNewVbsLib_Library   FolderPath

	echo  ""
	echo  """"+ FolderPath +""" フォルダーを最新の vbslib で使えるようにしました。"
End Sub


'//[ConvertToNewVbsLib_MainFile]
Sub  ConvertToNewVbsLib_MainFile( FolderPath )
	Const  ver3 = 3  '// Version has ver1_vbslib_inc_end
	Const  ver4 = 4  '// Version has ver4_parameter_start
	Const  ver5 = 5
	ver1_vbslib_inc_start = "--- start of"+" lib include ---"   '// "+" is for avoid hit
	ver1_vbslib_inc_end   = "--- end of"+" lib include ---"
	ver2_vbslib_inc_start = "--- start of"+" vbslib include ---"
	ver2_vbslib_inc_end   = "--- end of"+" vbslib include ---"
	ver4_parameter_start  = "--- start of"+" parameters for vbslib include ---"
	ver4_parameter_end    = "--- end of"+" parameters for vbslib include ---"
	ver5_vbslib_inc = ReadFile( g_vbslib_ver_folder +"tools\VbsLib5_Include.txt" )
	in_header1     = "g_vbslib_"+"path = ""..\"" + g_vbslib_path"
	Set re = CreateObject("VBScript.RegExp")
	Set c = g_VBS_Lib


	echo  ">ConvertToNewVbsLib  """+ FolderPath +""""


	Assert  ver5_vbslib_inc <> ""

	'// Set "ver5_vbslib_inc_1st_half"
	pos = InStr( ver5_vbslib_inc, ver4_parameter_start )
	pos = InStr( pos, ver5_vbslib_inc, vbLF )
	ver5_vbslib_inc_1st_half = Left( ver5_vbslib_inc, pos )

	'// Set "ver5_vbslib_inc_2nd_half"
	pos = InStr( pos, ver5_vbslib_inc, ver4_parameter_end )
	pos = InStr( pos, ver5_vbslib_inc, vbLF ) + 1
	ver5_vbslib_inc_2nd_half = Mid( ver5_vbslib_inc, pos )

	'// Set "founds"
	Set ec = new EchoOff
	founds  = grep( "-u -r --include=""*.vbs"" """+ GrepKeyword( ver1_vbslib_inc_start ) +_
		""" """+ FolderPath +"""", Empty )
	founds2 = grep( "-u -r --include=""*.vbs"" """+ GrepKeyword( ver2_vbslib_inc_start ) +_
		""" """+ FolderPath +"""", Empty )
	AddArrElem  founds, founds2

	For Each found  In founds
		ec = Empty
		echo  found.Path
		Set ec = new EchoOff

		text = ReadFile( found.Path )
		old_text = text

		'//=== make back up file
		temporary_path = GetTempPath( "ConvertToNewVbsLib_BackUp_*.vbs" )
		copy_ren  found.Path, temporary_path


		'//=== vbslib include ver 1
		If InStr( text, ver1_vbslib_inc_start ) Then
			is_out = True
			Set rep = StartReplace( temporary_path, found.Path, True )
			line = rep.r.ReadLine()
			If InStr( line, "Option Explicit" ) > 0 Then  rep.w.WriteLine  line
			Do Until rep.r.AtEndOfStream
				line = rep.r.ReadLine()
				If InStr( line, ver1_vbslib_inc_start ) > 0 Then  is_out = False
				If rep.r.AtEndOfStream Then  is_out = False
				If is_out Then  rep.w.WriteLine  line
				If InStr( line, ver1_vbslib_inc_end ) > 0 Then  is_out = True
			Loop

			For i=1 To 8 : rep.w.WriteLine  "" :Next
			rep.w.WriteLine  " "

			rep.w.WriteLine  ConvertToNewVbsLib_sub( ver5_vbslib_inc, """scriptlib\vbs_inc.vbs""", "2", "0" )

			rep.w.WriteLine  ""
			rep.w.WriteLine  " "
			rep.Finish

		'//=== vbslib include ver 2..
		ElseIf InStr( text, ver2_vbslib_inc_start )  and  InStr( text, in_header1 ) > 0  and _
			InStr( text, "start"+"_vbslib" ) = 0 Then

			a_debug = 0 : a_vbslib_path = "scriptlib\vbs_inc.vbs" : a_IncludeType = ""
			a_CommandPrompt = 2

			pos1 = InStr( text, "'--- start of parameters"+" for vbslib include ---" )
			pos2 = InStr( text, "'--- end of parameters" + " for vbslib include ---" )
			If pos1 > 0  and  pos2 > 0 Then
				params = Mid( text, pos1, pos2 - pos1 + 1 )
				params = Replace( params, "g_debug",         "a_debug" )
				params = Replace( params, "g_vbslib_path",   "a_vbslib_path" )
				params = Replace( params, "g_IncludeType",   "a_IncludeType" )
				params = Replace( params, "g_CommandPrompt", "a_CommandPrompt" )

				On Error Resume Next  '// Ignore error
					Execute  params
				On Error GoTo 0

				a_vbslib_path = Replace( a_vbslib_path, "vbslib\", "scriptlib\" )
			End If

			old_vbslib_ver = ver3
			If InStr( text, "SetupVbslibParameters" ) > 0 Then _
				old_vbslib_ver = ver4
			If InStr( text, "g_Vers(""vbslib"") = 99.99" ) > 0 Then _
				old_vbslib_ver = ver5


			'// Start output
			'//If InStr( found.Path, "VbsLibHeader4.vbs" ) > 0 Then  Stop:OrError

			is_out = True : state = "Copy"
			Set rep = StartReplace( temporary_path, found.Path, True )

			Do Until rep.r.AtEndOfStream
				line = rep.r.ReadLine()

				If InStr( line, ver2_vbslib_inc_start ) > 0 Then
					is_out = False : state = "vbslib include"

					If old_vbslib_ver >= ver4 Then
						rep.w.Write  ver5_vbslib_inc_1st_half
					End If
				End If

				If old_vbslib_ver <= ver3 Then
					If rep.r.AtEndOfStream Then
						is_out = False : state = "insert footer"
					End If
				End If


				If is_out Then  rep.w.WriteLine  line   '//###############


				If InStr( line, ver4_parameter_start ) > 0 Then
					If old_vbslib_ver >= ver4 Then
						is_out = True : state = "parameter"
					End If
				End If
				If InStr( line, ver4_parameter_end ) > 0 Then
					is_out = False : state = "vbslib include"

					If old_vbslib_ver >= ver4 Then
						rep.w.Write  ver5_vbslib_inc_2nd_half
					End If
				End If

				If InStr( line, ver2_vbslib_inc_end ) > 0 Then
					is_out = True : state = "after vbslib include"
				End If
			Loop

			'// Move vbslib include to footer
			If old_vbslib_ver <= ver3 Then
				For i=1 To 8 : rep.w.WriteLine  "" :Next
				rep.w.WriteLine  " "

				rep.w.WriteLine  ConvertToNewVbsLib_sub( ver5_vbslib_inc, _
					""""+ a_vbslib_path +"""",  CStr( a_CommandPrompt ),  CStr( a_debug ) )

				rep.w.WriteLine  ""
				rep.w.WriteLine  " "
			End If

			rep.Finish
		End If
		rep = Empty


		text = ReadFile( found.Path )

		'//=== cut main function comment
		re.MultiLine = True
		re.IgnoreCase = True
		re.Pattern = "'\**"+ vbCR+"?"+vbLF +"^' *<<< *\[main(2)?] *>>> *"+ vbCR+"?"+vbLF +"'\**"+ vbCR+"?"+vbLF
		text = re.Replace( text, "" )

		'//=== rename main(2) function to Main function
		re.MultiLine = True
		re.IgnoreCase = True
		re.Pattern = "Sub *main(2)?(\(.*\))? *(:.*)?$"
		Set matches = re.Execute( text )
		If matches.Count > 0 Then
			Set match = matches(0)
			kakko_pos = InStr( match.Value, "(" )
			If kakko_pos = 0 Then  kakko_pos = Len( match.Value )
			text = re.Replace( text, "Sub  Main"+ Mid( match.Value, kakko_pos ) )
		End If

		If text = old_text Then
			move_ren  temporary_path, found.Path
		Else
			Set cs = new_TextFileCharSetStack( ReadUnicodeFileBOM( found.Path ) )
			CreateFile  found.Path, text
			cs = Empty
			del  temporary_path
		End If
	Next

	ec = Empty
End Sub

Function  ConvertToNewVbsLib_sub( TemplateStr, vbslib_path, CommandPrompt, debug )
	s = TemplateStr
	s = Replace( s, "%g_vbslib_path%", vbslib_path )
	s = Replace( s, "%g_CommandPrompt%", CommandPrompt )
	s = Replace( s, "%g_debug%", debug )
	ConvertToNewVbsLib_sub = s
End Function


'//[ConvertToNewVbsLib_Library]
Sub  ConvertToNewVbsLib_Library( ByVal FolderPath )
	Set c = g_VBS_Lib

	If g_fs.GetFileName( FolderPath ) <> "scriptlib" Then
		FolderPath = FolderPath +"\*\scriptlib\"
		flags = c.Folder or c.SubFolderIfWildcard
	Else
		flags = c.Folder
	End If
	ExpandWildcard  FolderPath,  flags or c.FullPath or c.NoError, Empty, full_paths
	For Each  scriptlib_path In full_paths
		echo  scriptlib_path

		If exist( scriptlib_path +"\_vbslib_setting_back_up" ) Then
			Raise  E_WriteAccessDenied, "<ERROR msg=""フォルダーを別名に変えてください。"" path="""+_
				scriptlib_path +"\_vbslib_setting_back_up""/>"
		End If

		copy  g_vbslib_folder +"vbs_inc.vbs",  scriptlib_path

		'// Change the folder to no version number
		If g_fs.FolderExists( scriptlib_path +"\vbslib400" ) Then

			source_path      = scriptlib_path +"\vbslib400\vbs_inc_400.trans"
			destination_path = scriptlib_path +"\vbslib400\vbs_inc_sub.trans"
			If exist( source_path ) Then
				OpenForReplace( source_path, destination_path ).Replace _
					"<File>"+ g_fs.GetBaseName( source_path ) +".vbs</File>", _
					"<File>"+ g_fs.GetBaseName( destination_path ) +".vbs</File>"
				del  source_path
			End If

			ren  scriptlib_path +"\vbslib400\vbs_inc_400.vbs",   "vbs_inc_sub.vbs"
			ren  scriptlib_path +"\vbslib400", "vbslib"
		End If

		'// Back up "setting" folder
		move_ren  scriptlib_path +"\vbslib\setting", scriptlib_path +"\_vbslib_setting_back_up"

		'// Update vbslib
		Set c = g_VBS_Lib
		copy_ex  g_vbslib_folder +"vbslib\*", scriptlib_path +"\vbslib", c.ExistOnly
		copy     g_vbslib_folder +"vbslib\vbslib_old.vbs", scriptlib_path +"\vbslib"

		'// Restore "setting" folder
		move_ren  scriptlib_path +"\_vbslib_setting_back_up", scriptlib_path +"\vbslib\setting"

		'// Add "vbslib_old.vbs" in "vbs_inc_setting.vbs"
		path = scriptlib_path +"\vbslib\setting\vbs_inc_setting.vbs"
		text = ReadFile( path )
		If InStr( text, """vbslib_old.vbs""" ) = 0 Then
			text = Replace( text, """vbslib.vbs""", _
				"""vbslib_old.vbs"",_"+ vbCRLF +_
				"    ""vbslib.vbs""" )
    			Set cs = new_TextFileCharSetStack( ReadUnicodeFileBOM( path ) )
			CreateFile  path, text
			cs = Empty
		End If
	Next
End Sub


 
'********************************************************************************
'  <<< [Translate] >>> 
'********************************************************************************
Sub  Translate( TranslatorPath, FromLanguage, ToLanguage )
	echo  ">Translate  """+ TranslatorPath +""". """+ FromLanguage +""", """+ ToLanguage +""""

	Set config = new TranslateConfigClass
	config.IsTestOnly = False

	TranslateEx  TranslatorPath, FromLanguage, ToLanguage, config
End Sub


 
'********************************************************************************
'  <<< [TranslateTest] >>> 
'********************************************************************************
Sub  TranslateTest( TranslatorPath, FromLanguage, ToLanguage, OutFolderPath )
	echo  ">TranslateTest  """+ TranslatorPath +""". """+ FromLanguage +""", """+ ToLanguage +""""

	Set config = new TranslateConfigClass
	config.IsTestOnly = True
	config.OutFolderPath = OutFolderPath

	TranslateEx  TranslatorPath, FromLanguage, ToLanguage, config
End Sub


 
'********************************************************************************
'  <<< [TranslateEx] >>> 
'********************************************************************************
Sub  TranslateEx( TranslatorPath, FromLanguage, ToLanguage, in_out_Config )
	Set fin = new FinObj : fin.SetFunc "TranslateEx_Finally"
	Set ec = new EchoOff
	Set c = g_VBS_Lib

	Set root = LoadXML( TranslatorPath, Empty )
	temp_path = GetTempPath( "Translate_*.txt" )


	'// Set "in_out_Config"
	If IsEmpty( in_out_Config ) Then _
		Set in_out_Config = new TranslateConfigClass
	If IsEmpty( in_out_Config.IsTestOnly ) Then _
		in_out_Config.IsTestOnly = True


	'// Set "base_folder"
	Set base_tag = root.selectSingleNode( "./BaseFolder" )
	base_folder = GetParentFullPath( TranslatorPath )
	If not IsEmpty( in_out_Config.BaseFolderPath ) Then
		base_folder = GetFullPath( in_out_Config.BaseFolderPath, base_folder )
	ElseIf not base_tag is Nothing Then
		base_folder = GetFullPath( base_tag.text, base_folder )
	End If


	'// Set "word_pair_array"
	Set t_tags = root.selectNodes( "./T" )
	Redim  word_pair_array( t_tags.Length - 1 )
	i = 0
	For Each  t_tag  In t_tags
		Set word_pair = new NameOnlyClass
		word_pair.Name = t_tag.selectSingleNode( FromLanguage ).text
		word_pair.Delegate = t_tag.selectSingleNode( ToLanguage ).text

		Set word_pair_array( i ) = word_pair
		i = i + 1
	Next
	ShakerSort  word_pair_array, 0, UBound( word_pair_array ), _
		GetRef("CompareByNameLength"), -1


	'// Translate
	For Each path_node  In root.selectNodes( "./File" )

		ec = Empty
		echo  path_node.text
		Set ec = new EchoOff

		input_path = GetFullPath( path_node.text, base_folder )
		If not g_fs.FileExists( input_path ) Then
			Raise  E_PathNotFound, _
				"<ERROR msg=""翻訳ファイルに書かれたパスのファイルまたはフォルダが見つかりません。"" path="""+_
				input_path +""" translator="""+ TranslatorPath +"""/>"
		End If

		charset = path_node.getAttribute( "charset" )
		If IsNull( charset ) Then  charset = Empty
		If LCase( charset ) = "utf-8" Then
			If ReadUnicodeFileBOM( input_path ) = c.No_BOM Then  charset = c.UTF_8_No_BOM
		End If
		cs = Empty
		Set cs = new_TextFileCharSetStack( charset )

		text = ReadFile( input_path )
		For i=0 To  UBound( word_pair_array )
			text = Replace( text, _
				word_pair_array(i).Name, _
				word_pair_array(i).Delegate )
		Next
		CreateFile  temp_path, text


		If in_out_Config.IsTestOnly = False Then
			out_path = input_path
			SafeFileUpdate  temp_path, out_path
		ElseIf in_out_Config.OutFolderPath = "" Then
			out_path = temp_path
			fin.SetVar "Path", out_path
		Else
			out_path = GetFullPath( g_fs.GetFileName( input_path ), _
				GetFullPath( in_out_Config.OutFolderPath, Empty ) )
			move_ren  temp_path, out_path
		End If


		'//=== 英語に翻訳するときは、英語だけかどうかチェックする
		If UCase( ToLanguage ) = "EN" Then
			GetLineNumsExistNotEnglighChar  out_path, line_nums  '//[out] line_nums
			s = ""
			pos = 1
			line_num = 1
			For Each i  In line_nums
				While line_num <> i
					pos = InStr( pos, text, vbLF ) + 1
					line_num = line_num + 1
				WEnd
				pos2 = InStr( pos, text, vbLF ) + 1
				If pos2 = 1 Then  pos2 = Len( text ) + 1
				line_num = line_num + 1

				s = s + "<WARNING msg=""Not English character exists"" line_num="""& i &""">"+ vbCRLF +_
					XmlText( Mid( text, pos, pos2 - pos ) ) + "</WARNING>"+ vbCRLF

				pos = pos2
			Next
			s = s + "Not English character count is "& ( UBound( line_nums ) + 1 ) &" in "+ input_path
			If UBound( line_nums ) >= 0 Then  Raise  get_ToolsLibConsts().E_NotEnglishChar, s
			echo  s
		End If
	Next
	ec = Empty
	echo  "All texts are English."
End Sub
 Sub  TranslateEx_Finally( Vars )
	Dim  en,ed : en = Err.Number : ed = Err.Description : On Error Resume Next  '// This clears error

	Dim  ec : Set ec = new EchoOff
	Dim  path : path = Vars.Item("Path")
	If not IsEmpty( path ) Then  del  path
	ec = Empty

	ErrorCheckInTerminate  en : On Error GoTo 0 : If en <> 0 Then  Err.Raise en,,ed  '// This sets en again
End Sub


'//[TranslateConfigClass]
Class  TranslateConfigClass
	Public  IsTestOnly
	Public  OutFolderPath
	Public  BaseFolderPath
End Class


 
'********************************************************************************
'  <<< [CompareByNameLength] >>> 
'********************************************************************************
Function  CompareByNameLength( Left, Right, ByVal Param )
	If IsEmpty( Param ) Then  Param = +1
	CompareByNameLength = ( Len( Left.Name ) - Len( Right.Name ) ) * Param
End Function


 
'********************************************************************************
'  <<< [Translate_getOverwritePaths] >>> 
'********************************************************************************
Function  Translate_getOverwritePaths( TranslatorPath )
	Dim  root,  file_tags,  path_node,  i

	Set root = LoadXML( TranslatorPath, Empty )
	Set file_tags = root.selectNodes( "./File" )
	ReDim  arr( file_tags.Length - 1 )

	i = 0
	For Each path_node  In file_tags
		arr( i ) = GetFullPath( path_node.text, GetParentFullPath( TranslatorPath ) )
		i = i + 1
	Next
	Translate_getOverwritePaths = arr
End Function


 
'********************************************************************************
'  <<< [Translate_getWritable] >>> 
'********************************************************************************
Function  Translate_getWritable( TranslatorPath )
	Dim  root,  file_tags,  path_node,  i,  dic

	Set root = LoadXML( TranslatorPath, Empty )
	Set file_tags = root.selectNodes( "./File" )
	Set dic = CreateObject( "Scripting.Dictionary" )

	For Each path_node  In file_tags
		dic( g_fs.GetParentFolderName( GetFullPath( path_node.text, GetParentFullPath( _
				 TranslatorPath ) ) ) ) = True
	Next
	Translate_getWritable = dic.Keys
End Function


 
'//'********************************************************************************
'//'  <<< [new_TranslateToEnglish] >>> 
'//'********************************************************************************
'//Function  new_TranslateToEnglish( DictionaryCsvPath )
'//  Dim  Me_ : Set Me_ = new TranslateToEnglish
'//
'//  If not IsEmpty( DictionaryCsvPath ) Then
'//
'//    Me_.DictionaryCsvPath = DictionaryCsvPath
'//
'//    Dim  f : Set f = OpenForRead( DictionaryCsvPath )
'//    Dim  paths : paths = ArrayFromCSV( f.ReadLine() )
'//
'//    If UBound( paths ) = 0 Then  ReDim Preserve  paths(1)
'//    If IsEmpty( paths(1) ) Then  paths(1) = paths(0)
'//
'//    Me_.NotEnglishTextPath = env( paths(0) )
'//    Me_.EnglishTextPath    = env( paths(1) )
'//  End If
'//  Set new_TranslateToEnglish = Me_
'//End Function
'//
'//
'//
'//'-------------------------------------------------------------------------
'//' ### <<<< [TranslateToEnglish] Class >>>>
'//'-------------------------------------------------------------------------
'//
'//Class  TranslateToEnglish
'//  Public  c  '// as get_ToolsLibConsts()
'//  Public  DictionaryCsvPath   '// as string of abs path
'//  Public  IsReverseTranslate  '// as boolean
'//  Public  NotEnglishTextPath  '// as string of abs path
'//  Public  EnglishTextPath     '// as string of abs path
'//
'//  Private Sub  Class_Initialize()
'//    Set Me.c = get_ToolsLibConsts()
'//    Me.IsReverseTranslate = False
'//  End Sub
'//
'//  Public Property Get  Writable()
'//    If IsReverseTranslate Then
'//      Writable = Me.NotEnglishTextPath
'//    Else
'//      Writable = Me.EnglishTextPath
'//    End If
'//  End Property
'//
'//
'//'********************************************************************************
'//'  <<< [TranslateToEnglish::Translate] >>>
'//'********************************************************************************
'//Public Sub  Translate()
'//  Dim  texts, f, wf, rf, line, cols, i, from_words, to_words, is_replace
'//  Dim  in_path, out_path, s, line_nums, is_err
'//
'//  Set from_words = new ArrayClass
'//  Set to_words   = new ArrayClass
'//
'//  is_replace = ( LCase( Me.NotEnglishTextPath ) = LCase( Me.EnglishTextPath ) )
'//
'//  If Me.IsReverseTranslate Then
'//    in_path = Me.EnglishTextPath : out_path = Me.NotEnglishTextPath
'//  Else
'//    in_path = Me.NotEnglishTextPath : out_path = Me.EnglishTextPath
'//  End If
'//
'//
'//  '//=== Echo the operation
'//  echo  ">TranslateToEnglish """+ DictionaryCsvPath +""""
'//  If is_replace Then
'//    echo  in_path
'//  Else
'//    echo  "From: "+ in_path
'//    echo  "To  : "+ out_path
'//  ENd If
'//  Dim ec : Set ec = new EchoOff
'//
'//
'//  '//=== Read transrate words
'//  is_err = False
'//  Set f = OpenForRead( Me.DictionaryCsvPath )
'//  f.ReadLine  '// skip 1st line (==path, !=translate words)
'//  Do Until  f.AtEndOfStream
'//    line = f.ReadLine()
'//    cols = ArrayFromCSV( line )
'//    If UBound( cols ) = 1 Then
'//      from_words.Add  cols(0)
'//      to_words.Add    cols(1)
'//    ElseIf UBound( cols ) <> -1 Then
'//      echo_r  "<ERROR msg=""コンマの数が１つになっていません。"" line="""& (f.Line - 1) &"""/>", ""
'//      is_err = True
'//    End If
'//  Loop
'//  f = Empty
'//  If is_err Then  Raise  Me.c.E_ManyConmaCSV, "<ERROR msg=""コンマの数が１つになっていません。"" file="""+ Me.DictionaryCsvPath +"""/>"
'//
'//  If Me.IsReverseTranslate Then
'//    Set i = from_words : Set from_words = to_words : Set to_words = i
'//  End If
'//
'//
'//  '//=== Transrate words
'//  texts = ReadFile( in_path )
'//  For i=0 To from_words.UBound_
'//    texts = Replace( texts, from_words(i), to_words(i) )
'//  Next
'//  CreateFile  out_path, texts
'//
'//
'//  '//=== Check to exist not english
'//  If not Me.IsReverseTranslate Then
'//    GetLineNumsExistNotEnglighChar  Me.EnglishTextPath, line_nums  '//[out] line_nums
'//    For Each i  In line_nums
'//      echo_r  "<WARNING msg=""Not English character exists"" line_num="""& i &"""/>", ""
'//    Next
'//    s = "Not English character count is "& ( UBound( line_nums ) + 1 ) &" in "+ Me.EnglishTextPath
'//    If UBound( line_nums ) >= 0 Then  Raise  Me.c.E_NotEnglishChar, s
'//    echo  s
'//  End If
'//End Sub
'//
'//
'//
'//End Class
 
'********************************************************************************
'  <<< [GetLineNumsExistNotEnglighChar] >>> 
'********************************************************************************
Function  GetLineNumsExistNotEnglighChar( Path, out_LineNums )
	Dim  f, line
	Dim  ec : Set ec = new EchoOff

	ReDim  out_LineNums(-1)
	Set f = OpenForRead( Path )
	Do Until  f.AtEndOfStream
		line = f.ReadLine()
		If Len( line ) <> LenK( line ) Then
			ReDim Preserve  out_LineNums( UBound( out_LineNums ) + 1 )
			out_LineNums( UBound( out_LineNums ) ) = f.Line - 1
		End If
	Loop
	GetLineNumsExistNotEnglighChar = UBound( out_LineNums ) + 1
End Function


 
'********************************************************************************
'  <<< [CutLineFeedAtRightEnd] >>> 
'********************************************************************************
Function  CutLineFeedAtRightEnd( Text, Width )
	Dim  file : Set file = new StringStream
	Dim  line

	file.SetString  Text
	CutLineFeedAtRightEnd = ""

	Do Until  file.AtEndOfStream()
		line =  file.ReadLine()
		If LenK( line ) < Width Then  line = line + vbCRLF
		CutLineFeedAtRightEnd = CutLineFeedAtRightEnd + line
	Loop
End Function


 
'********************************************************************************
'  <<< [MakeSettingForCheckEnglish] >>> 
'********************************************************************************
Sub  MakeSettingForCheckEnglish( CheckEnglishOnlyFilePath, TranslateFilePaths )
	Set out_file = OpenForWrite( CheckEnglishOnlyFilePath, Empty )
	out_parnet_folder = GetParentFullPath( CheckEnglishOnlyFilePath )
	out_file.WriteLine  "[CheckEnglishOnlyExe]"

	For Each translate_path  In TranslateFilePaths
		out_file.WriteLine  ""
		out_file.WriteLine  ";// From """+ _
			GetStepPath( translate_path, out_parnet_folder ) +""" file"
		Set root = LoadXML( translate_path, Empty )
		in_parent_folder = GetParentFullPath( translate_path )
		For Each elem  In root.selectNodes( "./File/text()" )
			out_file.WriteLine  "ExceptFile = "+_
				GetStepPath( GetFullPath( elem.text, in_parent_folder ), out_parnet_folder )
		Next
	Next
End Sub


 
'********************************************************************************
'  <<< [SynchronizeFolder] >>> 
'********************************************************************************
Sub  SynchronizeFolder( FolderA_Path, FolderB_Path, SynchronizedPath, Mask, in_out_Options )
	Set c = g_VBS_Lib
	Const  NotCaseSensitive = 1
	Set indexes = new SynchronizeFolder_FileIndexClass
	Set work = new SynchronizeFolder_WorkClass

	ParseOptionArguments  in_out_Options
	If in_out_Options.Exists( "StringReplaceSetClass" ) Then
		Set string_replace_set = in_out_Options( "StringReplaceSetClass" )
	End If

	work.SynchronizedPath = GetFullPath( SynchronizedPath, Empty )
	work.FolderA_Path = GetFullPath( FolderA_Path, Empty )
	work.FolderB_Path = GetFullPath( FolderB_Path, Empty )
	work.Mask = Mask


	echo  ">SynchronizeFolder"
	echo  "    A: """+ work.FolderA_Path +""""
	echo  "    B: """+ work.FolderB_Path +""""
	Set ec = new EchoOff


	AssertExist  FolderA_Path
	AssertExist  FolderB_Path


	Do
		work.Reset


		'// Scan in folders
		If g_fs.FolderExists( SynchronizedPath ) Then
			work.Scan  work.SynchronizedPath, indexes.BaseFile
		End If
		work.Scan  work.FolderA_Path, indexes.FileA
		work.Scan  work.FolderB_Path, indexes.FileB


		'// Compare
		For Each  file  In work.files.Items


			file.Compare  work


			If file.Operation = indexes.UpdateBoth Then
				If not IsEmpty( file.DateLastModified( indexes.FileA ) ) Then
				If not IsEmpty( file.DateLastModified( indexes.FileB ) ) Then
					path_A = GetFullPath( file.StepPath, work.FolderA_Path )
					path_B = GetFullPath( file.StepPath, work.FolderB_Path )
					If not IsEmpty( string_replace_set ) Then
						If IsSameTextFile( path_A, path_B, in_out_Options ) Then
							file.Operation = indexes.UpdateSameBoth
							work.ManualCount = work.ManualCount - 1
						End If
					Else
						If IsSameBinaryFile( path_A, path_B, Empty ) Then
							difference = _
								file.DateLastModified( indexes.FileA ) - _
								file.DateLastModified( indexes.FileB )
							If difference = 0 Then
								file.Operation = indexes.NewSameBoth
							ElseIf difference > 0 Then
								file.Operation = indexes.UpdateA
							Else
								file.Operation = indexes.UpdateB
							End If
							work.ManualCount = work.ManualCount - 1
						End If
					End If
				End If
				End If
			End If
		Next


		'// Synchronize both updated files
		If work.ManualCount > 0 Then
			work.ShowDifference
		Else
			Exit Do
		End If
	Loop


	'// Auto synchronize
	For Each  file  In work.files.Items
		Select Case  file.Operation
			Case  indexes.AllSame
			Case  indexes.UpdateA, indexes.NewA, indexes.NewSameBoth, indexes.UpdateSameBoth
			Case  indexes.UpdateB, indexes.NewB
			Case  indexes.DeleteBoth
			Case Else
				Error
		End Select
	Next
	For Each  file  In work.files.Items
		Select Case  file.Operation

			Case  indexes.AllSame
				'// Do nothing

			Case  indexes.UpdateA, indexes.NewA, indexes.NewSameBoth, indexes.UpdateSameBoth

				If file.Operation = indexes.UpdateA  or _
					file.Operation = indexes.NewA Then

					ec = Empty
					echo  "  A => B  """+ file.StepPath + """"
					Set ec = new EchoOff
				End If

				copy_ren  GetFullPath( file.StepPath, work.FolderA_Path ),_
					GetFullPath( file.StepPath, work.FolderB_Path )
				copy_ren  GetFullPath( file.StepPath, work.FolderA_Path ),_
					GetFullPath( file.StepPath, work.SynchronizedPath )
				file.Operation = indexes.AllSame


			Case  indexes.UpdateB, indexes.NewB
				ec = Empty
				echo  "  A <= B  """+ file.StepPath + """"
				Set ec = new EchoOff

				copy_ren  GetFullPath( file.StepPath, work.FolderB_Path ),_
					GetFullPath( file.StepPath, work.FolderA_Path )
				copy_ren  GetFullPath( file.StepPath, work.FolderB_Path ),_
					GetFullPath( file.StepPath, work.SynchronizedPath )
				file.Operation = indexes.AllSame

			Case  indexes.DeleteBoth
				del  GetFullPath( file.StepPath, work.SynchronizedPath )

			Case Else
				Error
		End Select
	Next


	ec = Empty
	echo  "Synchronized."
End Sub


'//[SynchronizeFolder_WorkClass]
Class  SynchronizeFolder_WorkClass
	Public  Files  '// dictionary of SynchronizeFolder_FileClass
	Public  ManualCount

	Public  SynchronizedPath
	Public  FolderA_Path
	Public  FolderB_Path
	Public  Mask

	Private m_Indexes

	Private Sub  Class_Initialize()
		Set Me.Files = CreateObject( "Scripting.Dictionary" )
		Me.Files.CompareMode = NotCaseSensitive
		Set m_Indexes = new SynchronizeFolder_FileIndexClass
	End Sub

	Sub  Reset()
		Me.Files.RemoveAll
		Me.ManualCount = 0
	End Sub

	Sub  Scan( FolderPath, Index )
		Set c = g_VBS_Lib
		ExpandWildcard  GetFullPath( Me.Mask, FolderPath ), c.File or c.SubFolder, folder, step_paths
		For Each  step_path  In step_paths
			If Files.Exists( step_path ) Then
				Set o = Files( step_path )
			Else
				Set o = new SynchronizeFolder_FileClass
				o.StepPath = step_path
			End If
			o.DateLastModified( Index ) = g_fs.GetFile( GetFullPath( _
				step_path, folder ) ).DateLastModified
			Set Files( step_path ) = o
		Next
	End Sub


	Sub  ShowDifference()
		path = GetTempPath( "SynchronizeFolderReport\*.txt" )
		Set out = OpenForWrite( path, Empty )

		out.WriteLine  ">SynchronizeFolder"
		out.WriteLine  "    A: """+ Me.FolderA_Path +""""
		out.WriteLine  "    B: """+ Me.FolderB_Path +""""

		out.WriteLine  "以下のファイルは、手動で同期してください。"
		For Each  file  In  Me.Files.Items
		If m_Indexes.IsManualSynchronize( file.Operation ) Then

			out.WriteLine  ""
			out.WriteLine  """" + file.StepPath + """"

			If IsEmpty( file.DateLastModified( m_Indexes.FileA ) ) Then
				s = "Deleted: """
			ElseIf file.DateLastModified( m_Indexes.FileA ) = _
					file.DateLastModified( m_Indexes.BaseFile ) Then
				s = "NoChange:"""
			Else
				s = "Updated: """
			End If
			out.WriteLine  s + GetFullPath( file.StepPath, FolderA_Path ) + """"


			If IsEmpty( file.DateLastModified( m_Indexes.FileB ) ) Then
				s = "Deleted: """
			ElseIf file.DateLastModified( m_Indexes.FileB ) = _
					file.DateLastModified( m_Indexes.BaseFile ) Then
				s = "NoChange:"""
			Else
				s = "Updated: """
			End If
			out.WriteLine  s + GetFullPath( file.StepPath, FolderB_Path ) + """"
		End If
		Next
		out = Empty

		Raise  1, "<ERROR msg=""自動で同期できないファイルがあります"" "+ vbCRLF +_
			"hint=""hint_path に書かれたファイルを開いてください。"" "+ vbCRLF +_
			"hint_path="""+ path +"""/>"
	End Sub


	Sub  DoMenuMode()

		Error

		item_count_max = 16

		If Me.MenualCount > item_count_max Then
			ReDim  items( item_count_max - 1 )
			is_over_max = True
		Else
			ReDim  items( Me.MenualCount - 1 )
			is_over_max = False
		End If


		item_count = 0
		For Each  file  In  Me.Files.Items
			Set items( item_count ) = file
		Next
	End Sub
End Class


'//[SynchronizeFolder_FileIndexClass]
Class  SynchronizeFolder_FileIndexClass
	Public  BaseFile, FileA, FileB
	Public  AllSame, UpdateA, UpdateB, UpdateBoth, UpdateSameBoth
	Public  DeleteA, DeleteB, DeleteBoth, NewA, NewB, NewSameBoth

	Private Sub  Class_Initialize()

		'// Index of SynchronizeFolder_FileClass::DateLastModified
		BaseFile = 0
		FileA = 1
		FileB = 2

		'// Value of SynchronizeFolder_FileClass::Operation
		AllSame        = 0
		UpdateA        = 1
		UpdateB        = 2
		UpdateBoth     = 3
		UpdateSameBoth = 4
		DeleteA    = -1
		DeleteB    = -2
		DeleteBoth = -3
		NewA        = 11
		NewB        = 12
		NewSameBoth = 13
	End Sub

	Public Function  IsManualSynchronize( Operation )
		IsManualSynchronize = False
		Select Case  Operation
			Case  UpdateBoth, DeleteA, DeleteB : IsManualSynchronize = True
		End Select
	End Function
End Class


'//[SynchronizeFolder_FileClass]
Class  SynchronizeFolder_FileClass
	Public  StepPath
	Public  DateLastModified  '// as array of DateLastModified
	Public  Operation  '// UpdateA, UpdateB, UpdateBoth, Delete

	Private  m_Indexes

	Private Sub  Class_Initialize()
		ReDim  DateLastModified( 2 )
		Set m_Indexes = new SynchronizeFolder_FileIndexClass
	End Sub

'//[SynchronizeFolder_FileClass::Compare]
Public Sub  Compare( work )

	'// If StepPath = "2.ini" Then  Stop

	If DateLastModified( m_Indexes.FileA ) = DateLastModified( m_Indexes.FileB ) Then

		'// Same FileA as FileB
		If DateLastModified( m_Indexes.BaseFile ) = DateLastModified( m_Indexes.FileA ) Then
			Operation = m_Indexes.AllSame  '//:CV(1)
		ElseIf IsEmpty( DateLastModified( m_Indexes.BaseFile ) ) Then
			Operation = m_Indexes.NewSameBoth  '//:CV(2)
		ElseIf IsEmpty( DateLastModified( m_Indexes.FileA ) ) Then
			Operation = m_Indexes.DeleteBoth  '//:CV(3)
		Else
			Operation = m_Indexes.UpdateSameBoth  '//:CV(4)
		End If
		Exit Sub
	End If

	If IsEmpty( DateLastModified( m_Indexes.BaseFile ) ) Then
		If IsEmpty( DateLastModified( m_Indexes.FileA ) ) Then

			'// Exist FileB
			Operation = m_Indexes.NewB  '//:CV(5)
		Else
			If IsEmpty( DateLastModified( m_Indexes.FileB ) ) Then

				'// Exist FileA
				Operation = m_Indexes.NewA  '//:CV(6)
			Else
				'// Exist FileA, FileB
				Operation = m_Indexes.UpdateBoth  '//:CV(7)
			End If
		End If
	Else
		If IsEmpty( DateLastModified( m_Indexes.FileA ) ) Then
			'// Exist BaseFile is not here


			'// If IsEmpty( DateLastModified( m_Indexes.FileB ) ) Then
			'//  is not here

			'// Exist BaseFile, FileB
			difference = DateLastModified( m_Indexes.BaseFile ) - _
				DateLastModified( m_Indexes.FileB )
			If difference = 0 Then
				Operation = m_Indexes.DeleteA  '//:CV(8)
			Else
				Operation = m_Indexes.UpdateBoth  '//:CV(9)
			End If
		Else
			If IsEmpty( DateLastModified( m_Indexes.FileB ) ) Then

				'// Exist BaseFile, FileA
				difference = DateLastModified( m_Indexes.BaseFile ) - _
					DateLastModified( m_Indexes.FileA )
				If difference = 0 Then
					Operation = m_Indexes.DeleteB  '//:CV(10)
				Else
					Operation = m_Indexes.UpdateBoth  '//:CV(11)
				End If
			Else
				'// Exist BaseFile, FileA, FileB
				difference = DateLastModified( m_Indexes.BaseFile ) - _
					DateLastModified( m_Indexes.FileA )
				If difference = 0 Then
					Operation = m_Indexes.UpdateB  '//:CV(12)
				Else
					difference = DateLastModified( m_Indexes.BaseFile ) - _
						DateLastModified( m_Indexes.FileB )
					If difference = 0 Then
						Operation = m_Indexes.UpdateA  '//:CV(13)
					Else
						'// difference = DateLastModified( m_Indexes.FileA ) - _
						'// 	DateLastModified( m_Indexes.FileB )
						'// If difference = 0 Then
						'//   is not here

						Operation = m_Indexes.UpdateBoth  '//:CV(14)
					End If
				End If
			End If
		End If
	End If

	If m_Indexes.IsManualSynchronize( Operation ) Then _
		work.ManualCount = work.ManualCount + 1
End Sub

End Class


 
'-------------------------------------------------------------------------
' ### <<<< [CopyNotOverwriteFileClass] >>>> 
'-------------------------------------------------------------------------
Class  CopyNotOverwriteFileClass
	Public  SourcePath
	Public  DestinationPath
	Public  SynchronizedPath

Public Sub  Copy()
	Assert  not IsEmpty( Me.SourcePath )
	Assert  not IsEmpty( Me.DestinationPath )
	Assert  not IsEmpty( Me.SynchronizedPath )

	Set  diff_step_paths = new ArrayClass

	ExpandWildcard  Me.SourcePath +"\*", F_File or F_SubFolder, src_fo, step_paths
	dst_fo = GetFullPath( Me.DestinationPath, Empty )
	syn_fo = GetFullPath( Me.SynchronizedPath, Empty )
	For Each step_path  In step_paths
		src = GetFullPath( step_path, src_fo )
		dst = GetFullPath( step_path, dst_fo )
		syn = GetFullPath( step_path, syn_fo )
		If g_fs.FileExists( dst ) Then
			If g_fs.FileExists( syn ) Then
				If IsSameBinaryFile( src, dst, Empty ) Then
					If IsSameBinaryFile( src, syn, Empty ) Then
						'// Do nothing
					Else
						copy_ren  src, syn
					End If
				Else
					If IsSameBinaryFile( dst, syn, Empty ) Then
						copy_ren  src, dst
						copy_ren  src, syn
					Else
						diff_step_paths.Add  step_path
					End If
				End If
			Else
				If IsSameBinaryFile( src, dst, Empty ) Then
					copy_ren  src, syn
				Else
					diff_step_paths.Add  step_path
				End If
			End If
		Else
			If g_fs.FileExists( syn ) Then
				diff_step_paths.Add  step_path
			Else
				copy_ren  src, dst
				copy_ren  src, syn
			End If
		End If
	Next

	If diff_step_paths.Count > 0 Then
		Set menu = new SyncFilesMenu
		menu.IsCompareTimeStamp = False
		menu.Lead = "-------------------------------------------------"+vbCRLF+_
			"ファイルの内容に違いがあります。"+vbCRLF+_
			"src : "+ src_fo +vbCRLF+_
			"dst : "+ dst_fo +vbCRLF+_
			"syn : "+ syn_fo
		menu.AddRootFolder  0, src_fo
		menu.AddRootFolder  1, dst_fo
		menu.AddRootFolder  2, syn_fo
		menu.RootFolders(0).Label = "src"
		menu.RootFolders(1).Label = "dst"
		menu.RootFolders(2).Label = "syn"
		For Each step_path  In diff_step_paths.Items
			menu.AddFile  step_path
		Next
		menu.Compare
		menu.OpenSyncMenu
	End If
End Sub

Public Sub  CopyForce()
	Assert  not IsEmpty( Me.SourcePath )
	Assert  not IsEmpty( Me.DestinationPath )
	Assert  not IsEmpty( Me.SynchronizedPath )

	ExpandWildcard  Me.SourcePath +"\*", F_File or F_SubFolder, src_fo, step_paths
	dst_fo = GetFullPath( Me.DestinationPath, Empty )
	syn_fo = GetFullPath( Me.SynchronizedPath, Empty )
	For Each step_path  In step_paths
		src = GetFullPath( step_path, src_fo )
		dst = GetFullPath( step_path, dst_fo )
		syn = GetFullPath( step_path, syn_fo )
		If not g_fs.FileExists( dst ) Then
			copy_ren  src, dst
		ElseIf not IsSameBinaryFile( src, dst, Empty ) Then
			copy_ren  src, dst
		End If
		If not g_fs.FileExists( syn ) Then
			copy_ren  src, syn
		ElseIf not IsSameBinaryFile( src, syn, Empty ) Then
			copy_ren  src, syn
		End If
	Next
End Sub

End Class


 
'-------------------------------------------------------------------------
' ### <<<< [DeleteSameFileClass] >>>> 
'-------------------------------------------------------------------------
Class  DeleteSameFileClass
	Public  SourcePath
	Public  DestinationPath
	Public  SynchronizedPath

Public Sub  Delete()
	DeleteSub  True  '// Me.DeleteSub
End Sub

Public Sub  DeleteSameOnly()
	DeleteSub  False  '// Me.DeleteSub
End Sub

Private Sub  DeleteSub( IsMenu )
	Assert  not IsEmpty( Me.SourcePath )
	Assert  not IsEmpty( Me.DestinationPath )
	Assert  not IsEmpty( Me.SynchronizedPath )

	Set  diff_step_paths = new ArrayClass

	Const  NotCaseSensitive = 1
	Set  folder_paths = CreateObject( "Scripting.Dictionary" )
	folder_paths.CompareMode = NotCaseSensitive

	ExpandWildcard  Me.SourcePath +"\*", F_File or F_SubFolder, src_fo, step_paths
	dst_fo = GetFullPath( Me.DestinationPath, Empty )
	syn_fo = GetFullPath( Me.SynchronizedPath, Empty )
	For Each step_path  In step_paths
		src = GetFullPath( step_path, src_fo )
		dst = GetFullPath( step_path, dst_fo )
		syn = GetFullPath( step_path, syn_fo )

		If g_fs.FileExists( dst ) Then
			If IsSameBinaryFile( src, dst, Empty ) Then
				del  dst
				If g_fs.FileExists( syn ) Then _
					del  syn
			Else
				diff_step_paths.Add  step_path
			End If
		Else
			If g_fs.FileExists( syn ) Then
				diff_step_paths.Add  step_path
			End If
		End If
	Next

	If diff_step_paths.Count > 0  and  IsMenu Then
		Set menu = new SyncFilesMenu
		menu.IsCompareTimeStamp = False
		menu.Lead = "-------------------------------------------------"+vbCRLF+_
			"ファイルの内容に違いがあります。"+vbCRLF+_
			"src : "+ src_fo +vbCRLF+_
			"dst : "+ dst_fo +vbCRLF+_
			"syn : "+ syn_fo
		menu.AddRootFolder  0, src_fo
		menu.AddRootFolder  1, dst_fo
		menu.AddRootFolder  2, syn_fo
		menu.RootFolders(0).Label = "src"
		menu.RootFolders(1).Label = "dst"
		menu.RootFolders(2).Label = "syn"
		For Each step_path  In diff_step_paths.Items
			menu.AddFile  step_path
		Next
		menu.Compare
		menu.OpenSyncMenu
	End If

	del_empty_folder  Me.DestinationPath
	del_empty_folder  Me.SynchronizedPath
End Sub

Public Sub  DeleteForce()
	Assert  not IsEmpty( Me.SourcePath )
	Assert  not IsEmpty( Me.DestinationPath )
	Assert  not IsEmpty( Me.SynchronizedPath )

	ExpandWildcard  Me.SourcePath +"\*", F_File or F_SubFolder, src_fo, step_paths
	dst_fo = GetFullPath( Me.DestinationPath, Empty )
	syn_fo = GetFullPath( Me.SynchronizedPath, Empty )
	For Each step_path  In step_paths
		src = GetFullPath( step_path, src_fo )
		dst = GetFullPath( step_path, dst_fo )
		syn = GetFullPath( step_path, syn_fo )

		If g_fs.FileExists( dst ) Then _
			del  dst
		If g_fs.FileExists( syn ) Then _
			del  syn
	Next

	del_empty_folder  Me.DestinationPath
	del_empty_folder  Me.SynchronizedPath
End Sub

End Class


 
'********************************************************************************
'  <<< [CheckEnglishOnly] >>> 
'********************************************************************************
Function  CheckEnglishOnly( CheckFolderPath, SettingPath )
	exe = g_vbslib_ver_folder +"CheckEnglishOnly\CheckEnglishOnly.exe"
	out = GetTempPath( "CheckEnglishOnly_*.xml" )
	Set c = g_VBS_Lib
	Set fin = new FinObj : fin.SetFunc "CheckEnglishOnly_Finally"

	echo  ">CheckEnglishOnly  """+ CheckFolderPath +""", """+ SettingPath +""""

	AssertExist  exe

	If not g_is_debug Then  Set ec = new EchoOff

	fin.SetVar "out", out
	If IsEmpty( SettingPath ) Then
		r= RunProg( """"+ exe +""" /Folder:"""+ CheckFolderPath +"""", out )
	Else
		r= RunProg( """"+ exe +""" /Folder:"""+ CheckFolderPath +""" /Setting:"""+ SettingPath +"""", out )
	End If

	binary_file_error = 1215
	If r = binary_file_error  Then
		binary_path = "(unknown)"

		Set root = LoadXML( out, Empty )
		Set nodes = root.selectNodes( "./FILE" )
		Set last_node = nodes( nodes.length - 1 )
		Set line_nodes = last_node.selectNodes( "./LINE" )
		Set line_node = line_nodes( line_nodes.length - 1 )
		text = line_node.getAttribute( "text" )
		If not IsNull( text ) Then
			If text = "(This is binary file)" Then
				str = last_node.getAttribute( "path" )
				If not IsNull( str ) Then
					binary_path = str
				End If
			End If
		End If
		Raise  r, "<ERROR msg=""バイナリーファイルは処理できません"" path="""+ binary_path +"""/>"
	End If

	If ( r < 0 ) or ( r > 1 ) Then _
		Raise  r, "<ERROR msg=""CheckEnglishOnly.exe でエラーが発生しました""/>"


	ec = Empty


	Set founds = new ArrayClass
	If r <> 0 Then
		Set rcc = new_TextFileCharSetStack( c.Shift_JIS )

		fin.SetVar "out", Empty
			Set root = LoadXML( out, Empty )
		fin.SetVar "out", out

		For Each file  In root.selectNodes( "./FILE" )
			Set found = new CheckEnglishOnlyFound
			found.Path = file.getAttribute( "path" )

			Set found.NotEnglishItems = new ArrayClass
			For Each line_xml  In file.selectNodes( "./LINE" )
				Set line = new CheckEnglishOnlyLine
				line.LineNum = line_xml.getAttribute( "num" )
				line.NotEnglishText = line_xml.getAttribute( "text" )
				found.NotEnglishItems.Add  line
			Next
			founds.Add  found
		Next
	End If

	Set CheckEnglishOnly = founds
End Function
 Sub  CheckEnglishOnly_Finally( Vars )
	Dim  en,ed : en = Err.Number : ed = Err.Description : On Error Resume Next  '// This clears error

	Dim  out : out = Vars.Item("out")

	Set ec = new EchoOff
	del  out
	ec = Empty

	ErrorCheckInTerminate  en : On Error GoTo 0 : If en <> 0 Then  Err.Raise en,,ed  '// This sets en again
End Sub


Class  CheckEnglishOnlyFound
	Public  Path  '// as string
	Public  NotEnglishItems  '// as ArrayClass
End Class


Class  CheckEnglishOnlyLine
	Public  LineNum  '// as integer
	Public  NotEnglishText  '// as string
End Class


 
'********************************************************************************
'  <<< [ChangeHeadSpaceToTab] >>> 
'********************************************************************************
Sub  ChangeHeadSpaceToTab( ReadStream, WriteStream, TabSize )
	Dim  line,  space_count,  tab_count

	Do Until  ReadStream.AtEndOfStream
		line = ReadStream.ReadLine()

		space_count = 0
		While  Mid( line, space_count + 1, 1 ) = " "
			space_count = space_count + 1
		WEnd
		tab_count = Int( space_count / TabSize )
		line = String( tab_count, vbTab ) + Mid( line, tab_count * TabSize + 1 )

		WriteStream.WriteLine  line
	Loop
End Sub


 
'********************************************************************************
'  <<< [ChangeHeadTabToSpace] >>> 
'********************************************************************************
Sub  ChangeHeadTabToSpace( ReadStream, WriteStream, TabSize )
	Dim  line,  tab_count

	Do Until  ReadStream.AtEndOfStream
		line = ReadStream.ReadLine()

		tab_count = 0
		While  Mid( line, tab_count + 1, 1 ) = vbTab
			tab_count = tab_count + 1
		WEnd
		line = String( tab_count * TabSize, " " ) + Mid( line, tab_count + 1 )

		WriteStream.WriteLine  line
	Loop
End Sub


 
'********************************************************************************
'  <<< [ChangeMiddleSpaceToTab] >>> 
'********************************************************************************
Sub  ChangeMiddleSpaceToTab( ReadStream, WriteStream, TabSize )
	Dim  line,  space_tab_count,  space_count,  x,  pos,  next_pos

	Do Until  ReadStream.AtEndOfStream
		line = ReadStream.ReadLine()

		GetStrHeadSpaceTabCount  line, TabSize, x, space_tab_count  '//[out] x, space_tab_count

		pos = space_tab_count + 1
		Do
			next_pos = InStrEx( line, Array( "  ", vbTab ), pos, Empty )
			If next_pos = 0 Then  Exit Do

			x = x + ( next_pos - pos )
			pos = next_pos
			space_count = 4 - ( x Mod TabSize )
			Select Case  Mid( line, pos, 1 )

				Case  " "
					If String( space_count, " " ) = Mid( line, pos, space_count ) Then
						line = Left( line, pos-1 ) + vbTab + Mid( line, pos+space_count )
						pos = pos + 1
						x = x + space_count
					Else
						pos = pos + 1
						x = x + 1
					End If

				Case  vbTab
					pos = pos + 1
					x = x + space_count

			End Select
		Loop

		WriteStream.WriteLine  line
	Loop
End Sub


Sub  GetStrHeadSpaceTabCount( Str, TabSize, out_X, out_SpaceTabCount )
		out_X = 0
		out_SpaceTabCount = 0
		Do
			Select Case  Mid( Str, out_SpaceTabCount + 1, 1 )
				Case  " "
					out_X = out_X + 1
				Case  vbTab
					out_X = out_X - ( out_X Mod TabSize ) + TabSize
				Case Else  Exit Do
			End Select
			out_SpaceTabCount = out_SpaceTabCount + 1
		Loop
End Sub


 
'********************************************************************************
'  <<< [ChangeMiddleTabToSpace] >>> 
'********************************************************************************
Sub  ChangeMiddleTabToSpace( ReadStream, WriteStream, TabSize )
	Dim  line,  space_tab_count,  space_count,  x,  pos,  next_pos

	Do Until  ReadStream.AtEndOfStream
		line = ReadStream.ReadLine()

		GetStrHeadSpaceTabCount  line, TabSize, x, space_tab_count  '//[out] x, space_tab_count

		pos = space_tab_count + 1
		Do
			next_pos = InStr( pos, line, vbTab )
			If next_pos = 0 Then  Exit Do

			x = x + ( next_pos - pos )
			pos = next_pos
			space_count = TabSize - ( x Mod TabSize )
			line = Left( line, pos - 1 ) + String( space_count, " " ) +_
						 Mid( line, pos + 1 )

			pos = pos + space_count
			x = x + space_count
		Loop

		WriteStream.WriteLine  line
	Loop
End Sub


 
'********************************************************************************
'  <<< [OpenForWriteTextSection] >>> 
'********************************************************************************
Function  OpenForWriteTextSection( SourcePath, DestinationPath, in_out_Options )
	Set OpenForWriteTextSection = new WriteTextSectionClass
	OpenForWriteTextSection.Open_Sub  SourcePath, DestinationPath
End Function


'//[WriteTextSectionClass]
Class  WriteTextSectionClass
	Public  Text
	Public  SeparatorArray

	Public  SourcePath
	Public  DestinationPath
	Public  BOM

	Public  PickUpPositionArray  '// as ArrayClass of integer

	Private Sub  Class_Initialize()
		Me.SeparatorArray = Array( " ", "  ", vbTab )
		Set Me.PickUpPositionArray = new ArrayClass
	End Sub

	Public Sub  Open_Sub( SourcePath, DestinationPath )
		echo  ">OpenForWriteTextSection  """& SourcePath &""", """& DestinationPath &""""
		AssertExist  SourcePath
		Me.SourcePath = SourcePath
		Me.DestinationPath = DestinationPath
			If IsEmpty( DestinationPath ) Then  Me.DestinationPath = SourcePath
		Me.Text = ReadFile( SourcePath )
		Me.BOM = ReadUnicodeFileBOM( SourcePath )
	End Sub

	Private Sub  Class_Terminate()
		If Err.Number = 0 Then
			Me.DoPickUp_sub
			Set ec = new EchoOff
			Set cs = new_TextFileCharSetStack( Me.BOM )
			CreateFile  Me.DestinationPath,  Me.Text
		End If
	End Sub

	'//[WriteTextSectionClass::Cut]
	Public Sub  Cut( Key )
		Set c = g_VBS_Lib

		key_position = InStr( Me.Text, Key )
		If key_position = 0 Then  Exit Sub


		'// Loop
		section_start_position = 1
		section_over_position  = Len( Me.Text ) + 1
		CR_LF_length_x2 = Len( vbCRLF ) * 2
		For i = 0  To  UBound( Me.SeparatorArray )
			separator = Me.SeparatorArray( i )
			separator_lf =  vbCRLF + separator + vbCRLF


			'// Set "section_start_position"
			p = InStrEx( Me.Text, separator_lf, key_position, c.Rev )
			If p > 0 Then
				p = p + Len( separator ) + CR_LF_length_x2
				If p > section_start_position Then _
					section_start_position = p
			End If


			'// Set "section_over_position"
			p = InStr( key_position, Me.Text, separator_lf )
			If p > 0 Then
				p = p + Len( separator ) + CR_LF_length_x2
				If p < section_over_position Then _
					section_over_position = p
			End If
		Next


		'// Cut the section in "Me.Text"
		Me.Text = Left( Me.Text, section_start_position - 1 ) + _
			Mid( Me.Text, section_over_position )
	End Sub


	'//[WriteTextSectionClass::PickUp]
	Public Sub  PickUp( Key )
		key_position = InStr( Me.Text, Key )
		If key_position = 0 Then
			Raise  1, "<ERROR msg=""Not found"" keyword="""+ Key +""" path="""+_
				Me.SourcePath +"""/>"
		End If
		Me.PickUpPositionArray.Add  key_position
	End Sub

	Public Sub DoPickUp_sub()
		If Me.PickUpPositionArray.Count = 0 Then  Exit Sub

		Set section_positions = new ArrayClass
		CR_LF_length_x2 = Len( vbCRLF ) * 2
		section_over_position  = Len( Me.Text ) + 1
		ReDim  section_start_positions( UBound( Me.SeparatorArray ) )


		'// Check start of file
		section_positions.Add  1
		For i = 0  To  UBound( Me.SeparatorArray )
			separator_lf = Me.SeparatorArray( i ) + vbCRLF
			separator_lf_length = Len( separator_lf )

			If Left( Me.Text, separator_lf_length ) = separator_lf Then
				section_positions.Add  separator_lf_length + 1
				Exit For
			End If
		Next


		'// Set "section_start_positions"
		For i = 0  To  UBound( Me.SeparatorArray )
			separator_lf = vbCRLF + Me.SeparatorArray( i ) + vbCRLF
			separator_lf_length = Len( separator_lf )

			p = InStr( Me.Text, separator_lf )
			If p = 0 Then
				p = section_over_position
			Else
				p = p + separator_lf_length
			End If
			section_start_positions(i) = p
		Next


		'// Add to "section_positions"
		Do
			'// Set "next_section_start" : Minimum of section_start_positions(i)
			next_section_start = section_over_position
			For i = 0  To  UBound( Me.SeparatorArray )
				If section_start_positions(i) < next_section_start Then
					next_section_start = section_start_positions(i)
					separator_num = i
				End If
			Next


			'// Add
			section_positions.Add  next_section_start

			If next_section_start = section_over_position Then
				Exit Do
			End If


			'// Update "section_start_positions( separator_num )"
			separator_lf = vbCRLF + Me.SeparatorArray( separator_num ) + vbCRLF
			separator_lf_length = Len( separator_lf )

			p = InStr( next_section_start, Me.Text, separator_lf )
			If p = 0 Then
				p = section_over_position
			Else
				p = p + separator_lf_length
			End If
			section_start_positions( separator_num ) = p
		Loop


		'// Set "is_used_array"
		ReDim  is_used_array( section_positions.UBound_ - 1 )
		For Each  pick_up_position  In Me.PickUpPositionArray.Items
			section_num = BinarySearch( section_positions, _
				0, section_positions.UBound_, _
				pick_up_position, GetRef( "IntCompare" ), 1 )
			is_used_array( section_num ) = True
		Next


		'// Set "Me.Text"
		pick_up_text = ""
		For i = 0  To  section_positions.UBound_ - 1
			If is_used_array( i ) Then
				pick_up_text = pick_up_text + Mid( Me.Text, _
					section_positions( i ), _
					section_positions( i+1 ) - section_positions( i ) )
			End If
		Next
		Me.Text = pick_up_text
	End Sub
End Class


 
'*************************************************************************
'  <<< [CheckFolderMD5List] >>>
'*************************************************************************
Sub  CheckFolderMD5List( FolderPath, MD5ListFilePath, Opt )
	echo  ">CheckFolderMD5List  """+ FolderPath +""", """+ MD5ListFilePath +""""
	Set ec = new EchoOff

	current_MD5_list_path = GetTempPath( "MD5List_*.txt" )
	MakeFolderMD5List  FolderPath, current_MD5_list_path
	AssertFC  current_MD5_list_path, MD5ListFilePath
	del  current_MD5_list_path
End Sub


 
'*************************************************************************
'  <<< [MakeFolderMD5List] >>> 
'*************************************************************************
Sub  MakeFolderMD5List( FolderPath, MD5ListFilePath )
	Set c = g_VBS_Lib
	g_AppKey.CheckWritable  MD5ListFilePath, Empty

	echo  ">MakeFolderMD5List  """+ FolderPath +""", """+ MD5ListFilePath +""""
	Set ec = new EchoOff


	'// List up
	Set list_of_MD5 = new MD5ListClass
	list_of_MD5.BaseFullPath = GetFullPath( FolderPath, Empty )
	EnumFolderObject  FolderPath, folders  '// [out] folders
	For Each folder  In folders  '// folder as Folder Object
		For Each file  In folder.Files '// file as File Object
			list_of_MD5.Add  file.Path
		Next
	Next


	'// Write to the file
	Set file = OpenForWrite( MD5ListFilePath, c.Unicode )
	For Each  path  In list_of_MD5.Files.FilePaths
		file.WriteLine  list_of_MD5.Files( path ).GetItemText()
	Next
	file = Empty


	'// Change to ascii file, if ascii
	If GetLineNumsExistNotEnglighChar( MD5ListFilePath, Empty ) = 0 Then
		text = ReadFile( MD5ListFilePath )
		CreateFile  MD5ListFilePath, text
	End If
End Sub


 
'*************************************************************************
'  <<< [MD5ListClass] >>> 
'*************************************************************************
Class  MD5ListClass
	Public  Files  '// as PathDictionaryClass of MD5ListItemClass

	Private Sub  Class_Initialize()
		Set Me.Files = new PathDictionaryClass
	End Sub

	Property Let  BaseFullPath( x ) : Me.Files.BasePath = x : End Property
	Property Get  BaseFullPath() : BaseFullPath = Me.Files.BasePath : End Property

	Sub  Add( Path )   '// Step path base is .BaseFullPath
		Set item = new_MD5ListItemClass( _
			GetStepPath( Path, Me.BaseFullPath ), _
			GetFullPath( Path, Me.BaseFullPath ) )
		Set Me.Files( item.StepPath ) = item
	End Sub
End Class


 
'*************************************************************************
'  <<< [new_MD5ListItemClass] >>> 
'*************************************************************************
Function  new_MD5ListItemClass( StepPath, FullPath )
	Set item = new MD5ListItemClass
	item.StepPath = StepPath
	item.MD5 = ReadBinaryFile( FullPath ).MD5
	Set new_MD5ListItemClass = item
End Function


 
'*************************************************************************
'  <<< [new_MD5ListItemClass_fromText] >>> 
'*************************************************************************
Function  new_MD5ListItemClass_fromText( Text, BaseFolderPath )
	Assert  IsValidMD5ListItemText( Text )
	Set c = get_HashConsts()

	Set item = new MD5ListItemClass
	item.StepPath = Trim2( Mid( Text, c.Num_32_LengthOfMD5 + 1 ) )
	item.MD5 = ReadBinaryFile( GetFullPath( item.StepPath, BaseFolderPath ) ).MD5
	Set new_MD5ListItemClass_fromText = item
End Function


 
'*************************************************************************
'  <<< [IsValidMD5ListItemText] >>> 
'*************************************************************************
Sub  IsValidMD5ListItemText( Text )
	pos = InStr( Text, " " )
	Assert  pos = get_HashConsts().Num_32_LengthOfMD5 + 1
End Sub


 
'*************************************************************************
'  <<< [MD5ListItemClass] >>> 
'*************************************************************************
Class  MD5ListItemClass
	Public  StepPath
	Public  MD5 
	Public  IsChecked

	Function  GetItemText()
		GetItemText = Me.MD5 +" "+ Me.StepPath
	End Function
End Class


'*************************************************************************
'  <<< [LoadMD5List] >>>
'*************************************************************************
Function  LoadMD5List( MD5ListFilePath )
	Set list_of_MD5 = new MD5ListClass

	Set file = OpenForRead( MD5ListFilePath )
	Do Until  file.AtEndOfStream
		line = file.ReadLine()
		Set item = new_MD5ListItemClass_fromText( line )
		Set list_of_MD5.Files( item.StepPath ) = item
	Loop
	file = Empty
	Set LoadMD5List = list_of_MD5
End Function


 
'*************************************************************************
'  <<< [get_HashConsts] >>>
'*************************************************************************
Dim  g_HashConsts

Function  get_HashConsts()
    If IsEmpty( g_HashConsts ) Then _
        Set g_HashConsts = new HashConsts
    Set get_HashConsts = g_HashConsts
End Function


Class  HashConsts
    Public  Num_32_LengthOfMD5

    Private Sub  Class_Initialize()
        Num_32_LengthOfMD5 = 32
    End Sub
End Class


 
'********************************************************************************
'  <<< [BinarySearch] >>> 
'********************************************************************************
Function  BinarySearch( SortedArray, MinNum, MaxNum, Key, CompareFunc, CompareFuncParam )
	min_num = MinNum
	max_num = MaxNum

	While  max_num - min_num >= 2
		middle_num = CInt( ( min_num + max_num ) / 2 )
		If CompareFunc( Key, SortedArray( middle_num ), CompareFuncParam ) < 0 Then
			max_num = middle_num
		Else
			min_num = middle_num
		End If
	WEnd

	If CompareFunc( Key, SortedArray( min_num ), CompareFuncParam ) < 0 Then
		BinarySearch = min_num - 1
	ElseIf min_num = max_num Then
		BinarySearch = max_num
	Else
		If CompareFunc( Key, SortedArray( max_num ), CompareFuncParam ) < 0 Then
			BinarySearch = min_num
		Else
			BinarySearch = max_num
		End If
	End If
End Function


 
'********************************************************************************
'  <<< [IntCompare] >>> 
'********************************************************************************
Function  IntCompare( Left, Right, Param )
	IntCompare = Left - Right
End Function


 
'********************************************************************************
'  <<< [OpenForReadCRLF] >>> 
'********************************************************************************
Function  OpenForReadCRLF( Path )
	Set self = new ReadCRLF_TextStreamClass
	Set file = OpenForRead( Path )
	self.Text = ReadAll( file )
	self.NextPosition = 1
	self.IsEnd = False
	Set OpenForReadCRLF = self
End Function

'//[ReadCRLF_TextStreamClass]
Class  ReadCRLF_TextStreamClass
	Public  Text
	Public  NextPosition
	Public  IsEnd

	Function  ReadLine()
		p = InStr( Me.NextPosition, Me.Text, vbCRLF )
		If p > 0 Then
			ReadLine = Mid( Me.Text, Me.NextPosition, ( p - Me.NextPosition ) )
			Me.NextPosition = p + 2  '// 2 = Len( vbCRLF )
		Else
			ReadLine = Mid( Me.Text, Me.NextPosition )
			Me.NextPosition = Len( Text )
			Me.IsEnd = True
		End If
	End Function

	Property Get  AtEndOfStream()
		AtEndOfStream = Me.IsEnd
	End Property
End Class


 
'********************************************************************************
'  <<< [CutSharpIf] >>> 
'********************************************************************************
Sub  CutSharpIf( InputPath, OutputPath, Symbol, IsCutTrue )

	echo  ">CutSharpIf  """& InputPath &""", "& Symbol &", "& IsCutTrue
	Set ec = new EchoOff

	exe = g_vbslib_ver_folder +"vbslib_helper.exe"

	b=( IsEmpty( OutputPath ) )  'or
	If not b Then  b=( GetFullPath( InputPath, Empty ) = GetFullPath( OutputPath, Empty ) )
	If b Then
		is_temporary_output = True
		output_path = GetTempPath( "CutSharpIf_out_*.txt" )
		CreateFile  output_path, ""
		g_AppKey.CheckWritable  InputPath, Empty
	Else
		is_temporary_output = False
		output_path = OutputPath
		g_AppKey.CheckWritable  OutputPath, Empty
	End If


	If IsCutTrue Then
		is_cut_true_string = "1"
	Else
		is_cut_true_string = "0"
	End If


	ec = Empty
	r= RunProg( """"+ exe +""" CutSharpIf """+ InputPath +""" """+ output_path +_
		""" "+ Symbol +" "+ is_cut_true_string, "" )
	Assert  r = 0
	Set ec = new EchoOff


	If is_temporary_output Then
		move_ren  output_path, InputPath
	End If
End Sub


 
'********************************************************************************
'  <<< [GetLineCount] >>> 
'********************************************************************************
Function  GetLineCount( Text, RoundWay )
	Set re = CreateObject("VBScript.RegExp")

	re.Pattern = ".*"
	re.Global = True
	Set matches = re.Execute( Text )

	GetLineCount = matches.Count / 2

	If IsEmpty( RoundWay ) Then _
		GetLineCount = Int( GetLineCount )
End Function


 
'*************************************************************************
'  <<< [SearchStringTemplate] >>> 
'*************************************************************************
Function  SearchStringTemplate( FolderPath, RegularExpressionPart, TemplateStrings, Opt )
	echo  ">SearchStringTemplate  """+ GetEchoStr( FolderPath ) +""", """+ RegularExpressionPart +""""
	Set ec = new EchoOff

	If IsArray( TemplateStrings ) Then
		SearchStringTemplate_Sub1  out, FolderPath, RegularExpressionPart, TemplateStrings
	Else
		SearchStringTemplate_Sub1  out, FolderPath, RegularExpressionPart, Array( TemplateStrings )
	End If
	SearchStringTemplate = out
End Function


Sub  SearchStringTemplate_Sub1( out, FolderPath, RegularExpressionPart, TemplateStrings )
	Set c = g_VBS_Lib
	ReDim  out( UBound( TemplateStrings ) + 1 )
	Set re = new_RegExp( RegularExpressionPart, True )

	For index = 0  To UBound( out )
		Set out( index ) = new ArrayClass
	Next

	'// Set "template_sub_strings", "template_variables"
	ReDim  template_sub_strings( UBound( TemplateStrings ) )
	For index = 0  To  UBound( TemplateStrings )
		ParseDollarVariableString  TemplateStrings( index ), _
			template_sub_strings( index ), Empty
	Next

	'// Call "SearchStringTemplate_Sub2"
	If TypeName( FolderPath ) = "FilePathClass" Then
		SearchStringTemplate_Sub2  out, re, FolderPath, template_sub_strings
	Else
		Set a_grep = new GrepClass
		a_grep.IsRecurseSubFolders = True
		a_grep.IsOutFileNameOnly = True
		a_grep.Pattern = RegularExpressionPart
		founds = a_grep.Execute( FolderPath )
		For Each  found  In  founds
			SearchStringTemplate_Sub2  out, re, found.Path, template_sub_strings
		Next
	End If

	'// ...
	For index = 0  To UBound( out )
		out( index ) = out( index ).Items
	Next
End Sub


Sub  SearchStringTemplate_Sub2( out, re, Path, template_sub_strings )
	text = ReadFile( Path )

	'// Set "matches_not_in_template"
	Set matches = re.Execute( text )
	Set matches_not_in_template = new ArrayClass
	matches_not_in_template.ReDim_  matches.Count - 1
	For index = 0  To matches.Count - 1
		Set matches_not_in_template( index ) = matches( index )
	Next

'// If InStr( Path, "test.h" ) > 0 Then  Stop

	For template_num = 0  To UBound( template_sub_strings )
		sub_strings = template_sub_strings( template_num )
		over = 1
		next_over = 0
		Do
			'// Set "over" : Search "template_sub_strings"
			For Each sub_string  In sub_strings
				next_over = InStr( over, text, sub_string )
				If next_over = 0 Then  Exit For
				over = next_over + Len( sub_string )
			Next
			If next_over = 0 Then  Exit Do

			'// Set "start_" : 前方検索する。 最も短いマッチをスキャンするため
			start_ = over
			For sub_num = UBound( sub_strings )  To 0  Step -1
				sub_string = sub_strings( sub_num )
				start_ = InStrRev( text, sub_string, start_ - 1 )
			Next

			'// Add to "out"
			Set found = new GrepFound
			found.Path = Path
			found.LineText = Array( start_, over )
			out( template_num ).Add  found

			'// Rmove from "matches_not_in_template"
			For Each match  In matches_not_in_template.Items
				If start_ <= match.FirstIndex Then
				If match.FirstIndex < over Then
					matches_not_in_template.RemoveObject  match
				End If
				End If
			Next
		Loop
	Next

	'// Add to "out" : Not in template
	For Each match  In matches_not_in_template.Items
		Set found = new GrepFound
		found.Path = Path
		found.LineText = Array( match.FirstIndex + 1, _
			match.FirstIndex + match.Length + 1 )
		out( template_num ).Add  found
	Next
End Sub


 
'*************************************************************************
'  <<< [GetLineNumOfTemplateDifference] >>> 
'*************************************************************************
Function  GetLineNumOfTemplateDifference( TargetString, RegularExpressionPart, TemplateString )
	GetLineNumOfTemplateDifference = 0

	Set re = new_RegExp( RegularExpressionPart, True )
	ParseDollarVariableString  TemplateString, template_sub_strings, Empty
		'//[out] template_sub_strings


	'// Set "index_of_temp_sub" : Index of "template_sub_strings" array
	'// Set "match_in_template"
	index_of_temp_sub = 0
	For Each temp_sub  In template_sub_strings
		Set matches = re.Execute( temp_sub )
		If matches.Count >= 1 Then
			Set match_in_template = matches(0)
			Exit For
		End If
		index_of_temp_sub = index_of_temp_sub + 1
	Next
	If IsEmpty( match_in_template ) Then
		Raise  1, "<ERROR msg=""テンプレートの中に指定したキーワードがありません。"""+ _
			" keyword="""+ RegularExpressionPart +""">"+ TemplateString +"</ERROR>"
	End If


	'// Split "template_sub_strings( index_of_temp_sub )"
	ReDim Preserve  template_sub_strings( UBound( template_sub_strings ) + 1 )
	For index = UBound( template_sub_strings ) - 1  To index_of_temp_sub + 1  Step -1
		template_sub_strings( index + 1 ) = template_sub_strings( index )
	Next
	template_sub_strings( index_of_temp_sub + 1 ) = _
		Mid( template_sub_strings( index_of_temp_sub ), _
			match_in_template.FirstIndex + 1 + Len( match_in_template.Value ) )
	template_sub_strings( index_of_temp_sub ) = _
		Left( template_sub_strings( index_of_temp_sub ), _
			match_in_template.FirstIndex )


	'// Search "RegularExpressionPart"
	passed_target = 1
	match_num = 0
	Set matches = re.Execute( TargetString )
	For Each  match  In matches  '// Loop of templates
		variable_position = match.FirstIndex + 1

		'// Search different to backward
		For index = index_of_temp_sub  To 0  Step -1
			temp_sub = template_sub_strings( index )
			target_position = InStrRev( TargetString, temp_sub, variable_position )
			If target_position < passed_target Then
				'// ここで、template_sub_strings( index ) の中に違いがあることが確定する

				'// 最後の行を減らしていき、最後にマッチしなかった複数行の最後の行を、
				'// 違いがある行とする

				temp_sub_position = 1  '// 1 = -1 at next "InStrRev"
				Do
					temp_sub_position = InStrRev( temp_sub, vbLF, temp_sub_position - 2 ) + 1
					temp_sub = Left( temp_sub, temp_sub_position - 1 )
					If temp_sub_position = 1 Then  Exit Do  '// target_position = 0

					target_position = InStrRev( TargetString, temp_sub, variable_position )
					If target_position >= passed_target Then  Exit Do
				Loop

				'// Return
				If target_position < passed_target Then
						'// Not match any lines in "template_sub_strings( index )"
					GetLineNumOfTemplateDifference = _
						GetLineCount( Left( TargetString, variable_position ), Empty ) - _
						GetLineCount( template_sub_strings( index ), Empty ) + 1
				Else
					GetLineNumOfTemplateDifference = _
						GetLineCount( Left( TargetString, _
						target_position + Len( temp_sub ) ), _
						Empty )
				End If
				Exit Function

			ElseIf index = index_of_temp_sub  and _
					target_position + Len( temp_sub ) <> variable_position Then

				'// 最後の行から増やしていき、変数の前と一致しなかった複数行の先頭の行を、
				'// 違いがある行とする

				GetLineNumOfTemplateDifference = _
					GetLineCount( Left( TargetString, variable_position ), Empty )
				Exit Function
			End If

			variable_position = target_position - 1
		Next


		'// At next to "match"
		'// Set "variable_position" : RegularExpressionPart を含む temp_sub の次
		variable_position = match.FirstIndex + match.Length
		temp_sub = template_sub_strings( index_of_temp_sub + 1 )
		target_sub = Mid( TargetString, variable_position + 1, Len( temp_sub ) )
		If target_sub <> temp_sub Then

			'// RegularExpressionPart の直後の複数行を増やしていき、
			'// 最初にマッチしなかった複数行の最後の行を、違いがある行とする

			temp_sub_position = 1
			target_position = 1
			target_sub2 = ""
			Do
				temp_sub_position = InStr( temp_sub_position, temp_sub, vbLF )
				target_position = InStr( target_position, target_sub, vbLF )

				If temp_sub_position = 0 Then  Exit Do
				If target_position   = 0 Then  Exit Do

				temp_sub2   = Left( temp_sub,   temp_sub_position )
				target_sub2 = Left( target_sub, target_position )

				If temp_sub2 <> target_sub2 Then  Exit Do

				temp_sub_position = temp_sub_position + 1
				target_position   = target_position   + 1
			Loop

			GetLineNumOfTemplateDifference = _
				GetLineCount( Left( TargetString, variable_position ), Empty ) + _
				GetLineCount( target_sub2, Empty )
			Exit Function
		End If


		'// Set "next_re_pos" : Next "RegularExpressionPart" position
		If match_num < matches.Count - 1 Then
			next_re_pos = matches( match_num + 1 ).FirstIndex + 1
		Else
			next_re_pos = Len( TargetString )
		End If


		'// Search different to forward
		For index = index_of_temp_sub + 1  To UBound( template_sub_strings )
			temp_sub = template_sub_strings( index )
			target_position = InStr( variable_position, TargetString, temp_sub )
			If target_position = 0  or  target_position > next_re_pos Then

				'// 変数より後の複数行を増やしていき、検索して、
				'// 最初にヒットしなかった複数行の最後の行を、違いがある行とする

				temp_sub_position = 1
				temp_sub2_line_count = 0
				Do
					temp_sub_position = InStr( temp_sub_position, temp_sub, vbLF )
					If temp_sub_position = 0 Then  Exit Do
					temp_sub2 = Left( temp_sub, temp_sub_position )

					pos = InStr( variable_position, TargetString, temp_sub2 )
					If pos = 0  or  pos > next_re_pos Then _
						Exit Do

					temp_sub_position = temp_sub_position + 1
					temp_sub2_line_count = temp_sub2_line_count + 1
				Loop

				GetLineNumOfTemplateDifference = _
					GetLineCount( Left( TargetString, variable_position ), Empty ) + _
					temp_sub2_line_count
				Exit Function
			End If
			variable_position = target_position + Len( temp_sub )
		Next

		passed_target = target_position - 1
		match_num = match_num + 1
	Next
End Function


 
'*************************************************************************
'  <<< [ReplaceStringTemplate] >>> 
'*************************************************************************
Sub  ReplaceStringTemplate( FolderPath, RegularExpressionPart, BeforeTemplate, AfterTemplate, Opt )
	echo  ">ReplaceStringTemplate  """+ GetEchoStr( FolderPath ) +""", """+ RegularExpressionPart +""""
	Set ec = new EchoOff

	Set c = g_VBS_Lib
	Set re = new_RegExp( RegularExpressionPart, True )

	If IsEmpty( Opt ) Then
		Set default_values = CreateObject( "Scripting.Dictionary" )
	Else
		Set default_values = Opt
	End If


	'// Set "before_sub_strings"
	ParseDollarVariableString  BeforeTemplate, before_sub_strings, before_variables

	'// Call "ReplaceStringTemplate_Sub"
	If TypeName( FolderPath ) = "FilePathClass" Then
		ec = Empty
		ReplaceStringTemplate_Sub  re, FolderPath, before_sub_strings, _
			before_variables, BeforeTemplate, AfterTemplate, default_values
	Else
		Set a_grep = new GrepClass
		a_grep.IsRecurseSubFolders = True
		a_grep.IsOutFileNameOnly = True
		a_grep.Pattern = RegularExpressionPart
		founds = a_grep.Execute( FolderPath )
		ec = Empty
		For Each  found  In  founds
			ReplaceStringTemplate_Sub  re, found.Path, before_sub_strings, _
				before_variables, BeforeTemplate, AfterTemplate, default_values
		Next
	End If
End Sub


Sub  ReplaceStringTemplate_Sub( re, Path, sub_strings, before_variables, BeforeTemplate, AfterTemplate, default_values )
	before_text = ReadFile( Path )
	file_name = g_fs.GetFileName( GetFilePathString( Path ) )
	after_text = ""
	is_replaced = False

'// If InStr( Path, "test.h" ) > 0 Then  Stop

	next_over = 0
	previous_over = 1
	Do
		'// Set "over" : Search "template_sub_strings"
		over = previous_over
		For Each sub_string  In sub_strings
			next_over = InStr( over, before_text, sub_string )
			If next_over = 0 Then  Exit For
			over = next_over + Len( sub_string )
		Next
		If next_over = 0 Then
			Exit Do
		End If

		'// Set "start_" : 前方検索する。 最も短いマッチをスキャンするため
		start_ = over
		For sub_num = UBound( sub_strings )  To 0  Step -1
			sub_string = sub_strings( sub_num )
			start_ = InStrRev( before_text, sub_string, start_ - 1 )
		Next

		'// ...
 		before_sub_text = Mid( before_text, start_, over - start_ )

		'// Set "after_sub_text"
		Set variables = CreateObject( "Scripting.Dictionary" )
		Dic_add  variables, default_values
		Set variables = ScanFromTemplate_Sub( variables, _
			before_sub_text,_
			BeforeTemplate,_
			before_variables, 1, False, True )
		If variables Is Nothing Then
			Set variables = CreateObject( "Scripting.Dictionary" )
		End If
		variables( "${FileName}" ) = file_name
		after_sub_text = AfterTemplate
		For Each  key  In variables.Keys
			after_sub_text = Replace( after_sub_text, key, variables( key ) )
		Next
		after_sub_text = Replace( after_sub_text, "$\{", "${" )
		after_sub_text = Replace( after_sub_text, "$\\", "$\" )

		'// Add to "after_text"
		If after_sub_text <> before_sub_text Then
			after_text = after_text + _
				Mid( before_text, previous_over, start_ - previous_over ) + _
				after_sub_text
			is_replaced = True
		End If

		'// Next in the loop
		previous_over = over
	Loop

	after_text = after_text + Mid( before_text, previous_over )


	'// Write "after_text" to the file
	If is_replaced Then
		path_string = GetFilePathString( Path )
		echo  path_string
		Set ec = new EchoOff
		Set cs = new_TextFileCharSetStack( ReadUnicodeFileBOM( path_string ) )

		CreateFile  path_string, after_text

		ec = Empty
	End If
End Sub


 
'*************************************************************************
'  <<< [ParsePercentVariableString] >>> 
'*************************************************************************
Sub  ParsePercentVariableString( the_String, out_SubStringArray, out_VariableArray )
	out_SubStringArray = Array( Empty )
	out_VariableArray = Array( )
	index = 0
	position = 1
	Do
		start_ = InStr( position, the_String, "%" )
		If start_ = 0 Then
			out_SubStringArray( index ) = Mid( the_String, position )
			Exit Sub
		End If

		end_  = InStr( start_ + 1, the_String, "%" )
		If end_ = 0 Then  Raise  1, "<ERROR msg=""閉じる % が見つかりません""/>"

		a_sub_string = a_sub_string + Mid( the_String, position, start_ - position )

		If start_ + 1 = end_ Then
			a_sub_string = a_sub_string +"%"
		Else
			ReDim Preserve  out_VariableArray( index )

			out_SubStringArray( index ) = a_sub_string
			out_VariableArray( index ) = Mid( the_String, start_, end_ - start_ + 1 )
			a_sub_string = ""

			index = index + 1
			ReDim Preserve  out_SubStringArray( index )
		End If
		position = end_ + 1
	Loop
End Sub


 
'*************************************************************************
'  <<< [ParseDollarVariableString] >>> 
'*************************************************************************
Sub  ParseDollarVariableString( the_String, out_SubStringArray, out_VariableArray )
	out_SubStringArray = Array( Empty )
	out_VariableArray = Array( )
	index = 0
	position = 1
	Do
		start_ = InStr( position, the_String, "${" )
		If start_ = 0 Then
			a_sub_string = Mid( the_String, position )
			a_sub_string = Replace( a_sub_string, "$\{", "${" )
			a_sub_string = Replace( a_sub_string, "$\\", "$\" )
			out_SubStringArray( index ) = a_sub_string
			Exit Sub
		End If

		end_  = InStr( start_ + 1, the_String, "}" )
		If end_ = 0 Then  Raise  1, "<ERROR msg=""${ に対する } が見つかりません""/>"

		a_sub_string = a_sub_string + Mid( the_String, position, start_ - position )

		ReDim Preserve  out_VariableArray( index )

		a_sub_string = Replace( a_sub_string, "$\{", "${" )
		a_sub_string = Replace( a_sub_string, "$\\", "$\" )
		out_SubStringArray( index ) = a_sub_string
		out_VariableArray( index ) = Mid( the_String, start_, end_ - start_ + 1 )
		a_sub_string = ""

		index = index + 1
		ReDim Preserve  out_SubStringArray( index )

		position = end_ + 1
	Loop
End Sub


 
'*************************************************************************
'  <<< [GetReadOnlyList] >>> 
'*************************************************************************
Function  GetReadOnlyList( TargetPath, out_ReadOnlyDictionary, Opt )
	Set ro_dic = CreateObject( "Scripting.Dictionary" )  '// Read only dictionary

	If g_fs.FolderExists( TargetPath ) Then

		'// Set "step_path_pos"
		full_path = GetFullPath( TargetPath, Empty )
		step_path_pos = Len( full_path ) + 2
		If Right( full_path, 1 ) = "\" Then _
			step_path_pos = step_path_pos - 1

		'// ...
		EnumFolderObject  TargetPath, folders  '// [out] folders
		For Each folder  In folders
			For Each file  In folder.Files
				If file.Attributes and ReadOnly Then
					read_only_count = read_only_count + 1
					is_read_only = True
				Else
					is_read_only = False
				End If
				ro_dic( Mid( file.Path, step_path_pos ) ) = is_read_only
			Next
		Next

		GetReadOnlyList = read_only_count
	Else
		AssertExist  TargetPath

		Set file = g_fs.GetFile( TargetPath )
		If file.Attributes and ReadOnly Then
			GetReadOnlyList = 1
			ro_dic( "." ) = True
		Else
			GetReadOnlyList = 0
			ro_dic( "." ) = False
		End If
	End If
	Set out_ReadOnlyDictionary = ro_dic
End Function


 
'*************************************************************************
'  <<< [MakeDocumentByNaturalDocs] >>> 
'*************************************************************************
Sub  MakeDocumentByNaturalDocs( SourceRootPath, DocumentRootPath, Options )
	echo  ">MakeDocumentByNaturalDocs  """+ SourceRootPath +""", """+ _
		DocumentRootPath +""""
	Set ec = new EchoOff

	AssertExist  SourceRootPath
	g_AppKey.CheckWritable  DocumentRootPath, Empty

	CheckSettingFunctionExists  "Setting_getNaturalDocsPerlPath"
	natural_docs_path = Setting_getNaturalDocsPerlPath()
	GetPerlVersion  Empty

	temporary_project_path = GetTempPath( "NatualDocsProject_"+ _
		new_BinaryArrayAsText( SourceRootPath, "Unicode" ).MD5 )

	If not exist( DocumentRootPath ) Then
		del  temporary_project_path
	End If

	mkdir  temporary_project_path
	mkdir  DocumentRootPath

	ec = Empty


	echo  "Copy and changing to UTF-8 character set ..."
	Set mk = new MakeFileClass
	mk.AddRule  new_MakeDocumentByNaturalDocs_SourceCopyRules( SourceRootPath, _
		temporary_project_path +"\src" )
	mk.Make


	RunProg  "perl """+ natural_docs_path +""" -i """+ temporary_project_path +"\src" +_
		""" -o FramedHTML """+ DocumentRootPath +""" -p """+ temporary_project_path, _
		g_VBS_Lib.NotEchoStartCommand
End Sub


Function  new_MakeDocumentByNaturalDocs_SourceCopyRules( SourceRootPath, UTF_8_SourceRootPath )
	If IsEmpty( g_Vers("NaturalDocsExtension") ) Then
		Set g_Vers("NaturalDocsExtension") = Dic_addFromArray( Empty, Array( _
			"h", "c", "hpp", "cpp", "java", "php", "py", "vb", "vbs", _
			"pas", "ada", "js", "rb", "tcl", _
			"sfl", "cfm", "asr", "cfc", "ddd", "did", "ufl", _
			"asm", "s", "f", "F90", "F95", "for", "r", _
			"txt" ), True )
	End If

	ReDim  rules( g_Vers("NaturalDocsExtension").Count - 1 )
	rule_num = 0
	For Each  extension  In g_Vers("NaturalDocsExtension").Keys
		Set o = new MakeRule
			o.Sources = Array( GetPathWithSeparator( SourceRootPath ) +"*."+ extension )
			o.Target = GetPathWithSeparator( UTF_8_SourceRootPath ) +"*."+ extension
			Set o.Command = GetRef("MakeDocumentByNaturalDocs_SourceCopyRules_Command")
		Set rules( rule_num ) = o
		rule_num = rule_num + 1
	Next
	new_MakeDocumentByNaturalDocs_SourceCopyRules = rules
End Function
Sub  MakeDocumentByNaturalDocs_SourceCopyRules_Command( Param, Rule )
	Set c = g_VBS_Lib
	source_path = Rule.Sources(0)
	text = ReadFile( source_path )
	Set cs = new_TextFileCharSetStack( c.UTF_8_No_BOM )
	CreateFile  Rule.Target, text
End Sub


 
