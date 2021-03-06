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
Dim  g_ToolsLib_Path
	 g_ToolsLib_Path = g_SrcPath


 
'***********************************************************************
'* Function: get_ToolsLibConsts
'***********************************************************************
Function  get_ToolsLibConsts()
	If IsEmpty( g_ToolsLibConsts ) Then _
		Set g_ToolsLibConsts = new ToolsLibConsts
	Set get_ToolsLibConsts =   g_ToolsLibConsts
End Function

Dim  g_ToolsLibConsts

Class  ToolsLibConsts
	Public  E_NotEnglishChar, E_ManyConmaCSV, DeleteIfNoSection
	Public  Attachable, CannotAttachBoth, MustAttachAfterFriend, MustMergeWithFriend
	Public  Size, TimeStamp, LineCount, DiffForPatch, Part, EmptyFolderMD5, EmptyFolderTimeStamp
	Public  FasterButNotSorted, IncludeFullSet, BasePathIsList

	Private Sub  Class_Initialize()
		E_NotEnglishChar = &h80045001
		E_ManyConmaCSV   = &h80045002
		DeleteIfNoSection = 1

		Attachable = 0
		MustAttachAfterFriend = &h80045014
		MustMergeWithFriend   = &h80045013
		CannotAttachBoth      = &h80045012

		Size = 1
		TimeStamp = &h10
		LineCount = 2
		DiffForPatch = 4
		Part = 8
		FasterButNotSorted = &h20
		IncludeFullSet = &h200
		BasePathIsList = &h80

		EmptyFolderMD5 = String( 32, "0" )
		EmptyFolderTimeStamp = "2001-01-01T00:00:00+00:00"
	End Sub
End Class


 
'***********************************************************************
'* Constants: Error Code
'*
'*    : E_NotExpectedBackUp - 50
'*    : E_Conflict - 51
'***********************************************************************
Dim E_NotExpectedBackUp : E_NotExpectedBackUp = 50
Dim E_Conflict : E_Conflict = 51
Dim E_SwitchesNotReversible : E_SwitchesNotReversible = 6521
Dim E_NotFoundMakeRuleTag : E_NotFoundMakeRuleTag = 6522


 
'***********************************************************************
'* Class: ReplaceSymbolsClass
'***********************************************************************
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
		echo  Path
		Set ec = new EchoOff
'// 2016-12-05		Set cs = new_TextFileCharSetStack( ReadUnicodeFileBOM( Path ) )
		Set cs = new_TextFileCharSetStack( AnalyzeCharacterCodeSet( Path ) )
		CreateFile  Path, text
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


 
'***********************************************************************
'* Function: ConvSymbol
'***********************************************************************
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


 
'***********************************************************************
'* Function: new_SymbolDefine
'***********************************************************************
Function  new_SymbolDefine()
	Set new_SymbolDefine = new SymbolDefine
End Function


 
'***********************************************************************
'* Class: SymbolDefine
'***********************************************************************
Class  SymbolDefine
	Public  Name
	Public  DefinedValue

 
End Class 


 
'***********************************************************************
'* Function: ConvertToNewVbsLib
'***********************************************************************
Sub  ConvertToNewVbsLib( in_FolderPath )
	ConvertToNewVbsLib_MainFile  in_FolderPath
	ConvertToNewVbsLib_Library   in_FolderPath

	echo  ""
	echo  """"+ in_FolderPath +""" フォルダーを最新の vbslib で使えるようにしました。"
End Sub


'//[ConvertToNewVbsLib_MainFile]
Sub  ConvertToNewVbsLib_MainFile( in_FolderPath )
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


	echo  ">ConvertToNewVbsLib  """+ in_FolderPath +""""


	Assert  ver5_vbslib_inc <> ""

	'// Set "ver5_vbslib_inc_1st_half"
	pos = InStr( ver5_vbslib_inc,  ver4_parameter_start )
	pos = InStr( pos, ver5_vbslib_inc,  vbLF )
	ver5_vbslib_inc_1st_half = Left( ver5_vbslib_inc,  pos )

	'// Set "ver5_vbslib_inc_2nd_half"
	pos = InStr( pos, ver5_vbslib_inc,  ver4_parameter_end )
	pos = InStr( pos, ver5_vbslib_inc,  vbLF ) + 1
	ver5_vbslib_inc_2nd_half = Mid( ver5_vbslib_inc,  pos )

	'// Set "founds"
	Set ec = new EchoOff
	founds  = grep( "-u -r --include=""*.vbs"" """+ GrepKeyword( ver1_vbslib_inc_start ) +_
		""" """+ in_FolderPath +"""", Empty )
	founds2 = grep( "-u -r --include=""*.vbs"" """+ GrepKeyword( ver2_vbslib_inc_start ) +_
		""" """+ in_FolderPath +"""", Empty )
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

			rep.w.WriteLine  ConvertToNewVbsLib_sub( _
				ver5_vbslib_inc, _
				"""scriptlib\vbs_inc.vbs""", "2", "0" )

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

				rep.w.WriteLine  ConvertToNewVbsLib_sub( _
					ver5_vbslib_inc, _
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
			Set cs = new_TextFileCharSetStack( AnalyzeCharacterCodeSet( found.Path ) )
			CreateFile  found.Path, text
			cs = Empty
			del  temporary_path
		End If
	Next

	ec = Empty
End Sub

Function  ConvertToNewVbsLib_sub( in_TemplateStr,  in_vbslibPath,  in_CommandPrompt,  in_Debug )
	s = in_TemplateStr
	s = Replace( s, "%g_vbslib_path%", in_vbslibPath )
	s = Replace( s, "%g_CommandPrompt%", in_CommandPrompt )
	s = Replace( s, "%g_debug%", in_Debug )
	ConvertToNewVbsLib_sub = s
End Function


'//[ConvertToNewVbsLib_Library]
Sub  ConvertToNewVbsLib_Library( ByVal in_FolderPath )
	Set c = g_VBS_Lib

	If g_fs.GetFileName( in_FolderPath ) <> "scriptlib" Then
		in_FolderPath = in_FolderPath +"\*\scriptlib\"
		flags = c.Folder or c.SubFolderIfWildcard
	Else
		flags = c.Folder
	End If
	ExpandWildcard  in_FolderPath,  flags or c.FullPath or c.NoError, Empty, full_paths
	For Each  scriptlib_path In full_paths

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

		ren  scriptlib_path +"\vbslib400\vbs_inc_400.vbs",  "vbs_inc_sub.vbs"
		ren  scriptlib_path +"\vbslib400",  "vbslib"
	End If

	'// ...
	If g_fs.FileExists( scriptlib_path +"\vbslib\vbslib.vbs" ) Then
		echo  scriptlib_path

		If exist( scriptlib_path +"\_vbslib_setting_back_up" ) Then
			Raise  E_WriteAccessDenied, "<ERROR msg=""フォルダーを別名に変えてください。"" path="""+_
				scriptlib_path +"\_vbslib_setting_back_up""/>"
		End If

		copy  g_vbslib_folder +"vbs_inc.vbs",  scriptlib_path

		'// Back up "setting" folder
		move_ren  scriptlib_path +"\vbslib\setting", scriptlib_path +"\_vbslib_setting_back_up"

		'// Update vbslib
		copy_ex  g_vbslib_folder +"vbslib\*", scriptlib_path +"\vbslib", c.ExistOnly
		If exist( g_vbslib_folder +"vbslib\vbslib_old.vbs" ) Then
			copy  g_vbslib_folder +"vbslib\vbslib_old.vbs", scriptlib_path +"\vbslib"
		Else
			del  scriptlib_path +"\vbslib\vbslib_old.vbs"
		End If

		If exist( g_vbslib_folder +"vbslib\vbslib_old.trans" ) Then
			copy  g_vbslib_folder +"vbslib\vbslib_old.trans", scriptlib_path +"\vbslib"
		Else
			del  scriptlib_path +"\vbslib\vbslib_old.trans"
		End If


		'// Restore "setting" folder
		move_ren  scriptlib_path +"\_vbslib_setting_back_up", scriptlib_path +"\vbslib\setting"

		'// Add "vbslib_old.vbs" in "vbs_inc_setting.vbs"
		path = scriptlib_path +"\vbslib\setting\vbs_inc_setting.vbs"
		text = ReadFile( path )
		If exist( g_vbslib_folder +"vbslib\vbslib_old.vbs" ) Then
			If InStr( text, """vbslib_old.vbs""" ) = 0 Then
				text = Replace( text, """vbslib.vbs""", _
					"""vbslib_old.vbs"",_"+ vbCRLF +_
					"    ""vbslib.vbs""" )
				Set cs = new_TextFileCharSetStack( AnalyzeCharacterCodeSet( path ) )
				CreateFile  path, text
				cs = Empty
			End If
		Else
			If InStr( text, """vbslib_old.vbs""" ) >= 1 Then
				text = Replace( text,  """vbslib_old.vbs"",_"+ vbCRLF,  "" )
				Set cs = new_TextFileCharSetStack( AnalyzeCharacterCodeSet( path ) )
				CreateFile  path, text
				cs = Empty
			End If
		End If
	End If
	Next
End Sub


 
'***********************************************************************
'* Function: Translate
'***********************************************************************
Sub  Translate( in_TranslatorPath, in_FromLanguage, in_ToLanguage )
	echo  ">Translate  """+ in_TranslatorPath +""". """+ in_FromLanguage +""", """+ in_ToLanguage +""""

	Set config = new TranslateConfigClass
	config.IsTestOnly = False
	config.OutFolderPath = ""

	TranslateEx  in_TranslatorPath, in_FromLanguage, in_ToLanguage, config
End Sub


 
'***********************************************************************
'* Function: TranslateTest
'***********************************************************************
Sub  TranslateTest( in_TranslatorPath, in_FromLanguage, in_ToLanguage, in_OutFolderPath )
	echo  ">TranslateTest  """+ in_TranslatorPath +""". """+ in_FromLanguage +""", """+ in_ToLanguage +""""

	Set config = new TranslateConfigClass
	config.IsTestOnly = True
	config.OutFolderPath = in_OutFolderPath

	TranslateEx  in_TranslatorPath, in_FromLanguage, in_ToLanguage, config
End Sub


 
'***********************************************************************
'* Function: TranslateEx
'***********************************************************************
Sub  TranslateEx( in_TranslatorPath, in_FromLanguage, in_ToLanguage, in_out_Config )
	Set fin = new FinObj : fin.SetFunc "TranslateEx_Finally"
	Set ec = new EchoOff
	Set c = g_VBS_Lib


	'// Set "in_out_Config"
	If IsEmpty( in_out_Config ) Then _
		Set in_out_Config = new TranslateConfigClass
	If IsEmpty( in_out_Config.IsTestOnly ) Then _
		in_out_Config.IsTestOnly = True


	'// Block: ExpandWildcard
	If g_fs.FolderExists( in_TranslatorPath ) Then
		ExpandWildcard  GetFullPath( "*.trans", GetFullPath( in_TranslatorPath, Empty ) ), _
			c.File or c.SubFolder, folder, step_paths

		error_number = Empty
		error_description = Empty
		If in_out_Config.OutFolderPath <> "" Then
			out_folder_path_back_up = in_out_Config.OutFolderPath
			out_root_path = GetFullPath( in_out_Config.OutFolderPath, Empty )
		End If
		translator_full_path = GetFullPath( in_TranslatorPath, Empty )

		For Each  step_path  In  step_paths
			path = GetFullPath( step_path, folder )
			If not IsEmpty( out_folder_path_back_up ) Then
				in_out_Config.OutFolderPath = GetParentFullPath( ReplaceRootPath( step_path, _
					translator_full_path, out_root_path, True ) )
			End If

			If TryStart(e) Then  On Error Resume Next

				TranslateEx  path, in_FromLanguage, in_ToLanguage, in_out_Config

			If TryEnd Then  On Error GoTo 0
			If e.num = get_ToolsLibConsts().E_NotEnglishChar  or _
					e.num = E_PathNotFound  Then
				If IsEmpty( error_description ) Then
					error_number = e.num
					error_description = e.Description
				End If
				echo_v  e.Description
				echo_v  ""
				e.Clear
			End If
			If e.num <> 0 Then  e.Raise
		Next

		If not IsEmpty( out_folder_path_back_up ) Then _
			in_out_Config.OutFolderPath = out_folder_path_back_up

		If not IsEmpty( error_description ) Then _
			Raise  error_number,  error_description

		Exit Sub
	End If


	'// Block: LoadXML
	Set root = LoadXML( in_TranslatorPath, Empty )
	temp_path = GetTempPath( "Translate_*.txt" )


	'// Set "base_folder"
	Set base_tag = root.selectSingleNode( "./BaseFolder" )
	base_folder = GetParentFullPath( in_TranslatorPath )
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
		Set  word_pair = new TranslateWordClass
		Set  from_tag = t_tag.selectSingleNode( in_FromLanguage )
		Set  to_tag   = t_tag.selectSingleNode( in_ToLanguage )
		If not from_tag.firstChild is Nothing Then
			word_pair.Name = from_tag.firstChild.nodeValue
			If to_tag.firstChild is Nothing Then
				word_pair.ToWord = ""
			Else
				word_pair.ToWord = to_tag.firstChild.nodeValue
			End If

			If from_tag.getAttribute( "cut_indent" ) = "yes" Then
				word_pair.Name = CutIndentOfMultiLineText( word_pair.Name, _
					from_tag.getAttribute( "indent" ), _
					from_tag.getAttribute( "new_line" ),  Empty )
			End If
			If to_tag.getAttribute( "cut_indent" ) = "yes" Then
				word_pair.ToWord = CutIndentOfMultiLineText( word_pair.ToWord, _
					from_tag.getAttribute( "indent" ), _
					from_tag.getAttribute( "new_line" ),  Empty )
			End If

			Set word_pair.T_Tag = t_tag
			word_pair.IsUpdated = False

			Set word_pair_array( i ) = word_pair
			i = i + 1
		End If
	Next
	ReDim Preserve  word_pair_array( i - 1 )
	ShakerSort  word_pair_array, 0, UBound( word_pair_array ), _
		GetRef("CompareByNameLength"), -1


	'// Block: Translate
	not_found_count = 0
	warning_count = 0
	Set counter = new LineNumFromTextPositionClass
	For Each  path_node  In  root.selectNodes( "./File" )
		do_it = True

		ec = Empty
		echo  path_node.text
		Set ec = new EchoOff

		input_path = GetFullPath( path_node.text, base_folder )
		If not g_fs.FileExists( input_path ) Then
			not_found_count = not_found_count + 1

			echo_v  "<WARNING msg=""翻訳ファイルに書かれたパスのファイルまたはフォルダーが見つかりません。"+_
				""" path="""+ input_path +"""/>"
			do_it = False
		End If

		If do_it Then

		charset = path_node.getAttribute( "charset" )
		If IsNull( charset ) Then  charset = Empty
		If LCase( charset ) = "utf-8" Then _
			If ReadUnicodeFileBOM( input_path ) = c.No_BOM Then _
				charset = c.UTF_8_No_BOM
		If IsEmpty( charset ) Then _
			charset = AnalyzeCharacterCodeSet( input_path )
		cs = Empty
		Set cs = new_TextFileCharSetStack( charset )


		counter.Text = ReadFile( input_path )
		For i=0 To  UBound( word_pair_array )
			Set word_pair = word_pair_array(i)
			position = InStr( counter.Text, word_pair.Name )
			If position > 0 Then
				line_num = counter.GetLineNum( position )



				'// Main
				counter.ReplaceTextAtHere _
					Replace( Mid( counter.Text, position ), _
						word_pair.Name, _
						word_pair.ToWord )



				'// ...
				If not word_pair.IsUpdated Then
					word_pair.IsUpdated = True
					XmlWrite  word_pair.T_Tag, "./Line", _
						line_num
					XmlWrite  word_pair.T_Tag, "./File", _
						GetStepPath( input_path, base_folder )
				End If
			End If
		Next
		CreateFile  temp_path, counter.Text


		If in_out_Config.IsTestOnly = False Then
			out_path = input_path
			SafeFileUpdate  temp_path, out_path
		ElseIf in_out_Config.OutFolderPath = "" Then
			out_path = temp_path
			fin.SetVar "Path", out_path
		Else
			out_path = ReplaceRootPath( input_path,  base_folder, _
				GetFullPath( in_out_Config.OutFolderPath, Empty ), True )
			move_ren  temp_path, out_path
		End If


		'//=== 英語に翻訳するときは、英語だけかどうかチェックする
		is_english_only = path_node.getAttribute( "english_only" )
		If IsNull( is_english_only ) Then
			is_english_only = True
		Else
			is_english_only = ( StrComp( is_english_only, "yes", 1 ) = 0 )
		End If

		If UCase( in_ToLanguage ) = "EN"  and  is_english_only Then
			GetLineNumsExistNotEnglighChar  out_path, line_nums  '//[out] line_nums
			s = ""
			pos = 1
			line_num = 1
			For Each i  In line_nums
				While line_num <> i
					pos = InStr( pos, counter.Text, vbLF ) + 1
					line_num = line_num + 1
				WEnd
				pos2 = InStr( pos, counter.Text, vbLF ) + 1
				If pos2 = 1 Then  pos2 = Len( counter.Text ) + 1
				line_num = line_num + 1

				s = s + "<WARNING msg=""Not English character exists"" line_num="""& i &""">"+ vbCRLF +_
					XmlText( Mid( counter.Text, pos, pos2 - pos ) ) + "</WARNING>"+ vbCRLF

				pos = pos2
			Next
			If UBound( line_nums ) >= 0 Then
				warning_count = warning_count + UBound( line_nums ) + 1
				echo_v  "<File warning_count="""& ( UBound( line_nums ) + 1 ) &""" path="""+ _
					input_path +""">"+ vbCRLF + s +"</File>"
			Else
				s = s + "Not English character count is "& ( UBound( line_nums ) + 1 ) & _
					" in "+ input_path
				echo  s
			End If
		End If

		End If  '// do_it
	Next


	'// Block: Update tag of not found word
	For i=0 To  UBound( word_pair_array )
		Set word_pair = word_pair_array(i)
		If not word_pair.IsUpdated Then
			word_pair.IsUpdated = True
			XmlWrite  word_pair.T_Tag, "./Line", 0
			XmlWrite  word_pair.T_Tag, "./File", "(NotFoundFile)"
		End If
	Next


	XmlSort  root, "T", GetRef( "CompareTranslateFileLine" ), Empty
	g_AppKey.CheckWritable  in_TranslatorPath, Empty
	root.ownerDocument.save  in_TranslatorPath

	If not_found_count + warning_count >= 1 Then
		If warning_count >= 1 Then
			error_code = get_ToolsLibConsts().E_NotEnglishChar
		Else
			error_code = E_PathNotFound
		End If

		message = "<ERROR msg=""警告がありました。"" translator_path="""+ _
			in_TranslatorPath +"""/>"

		is_skip = root.getAttribute( "skip_not_english_error" )
		If IsNull( is_skip ) Then
			is_skip = False
		Else
			is_skip = ( is_skip = "yes" )
		End If

		If is_skip Then
			echo  message
		Else
			Raise  error_code,  message
		End If
	End If

	ec = Empty
	If not_found_count + warning_count = 0 Then _
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


'//[TranslateWordClass]
Class  TranslateWordClass
	Public  Name  '// FromWord
	Public  ToWord
	Public  T_Tag
	Public  IsUpdated
End Class


'//[CompareTranslateFileLine]
Function  CompareTranslateFileLine( in_LeftTag, in_RightTag, in_Parameter )
	Set left_path = in_LeftTag.selectSingleNode(  "./File/text()" )
	If not  left_path  is Nothing Then
		left_path = left_path.nodeValue
	Else
		left_path = ""
	End If

	Set right_path = in_RightTag.selectSingleNode( "./File/text()" )
	If not  right_path  is Nothing Then
		right_path = right_path.nodeValue
	Else
		right_path = ""
	End If

	CompareTranslateFileLine = StrComp( left_path, right_path, 1 )
	If CompareTranslateFileLine = 0 Then
		Set left_line = in_LeftTag.selectSingleNode( "./Line/text()" )
		If not  left_line  is Nothing Then
			left_line = CLng( left_line.nodeValue )
		Else
			left_line = 0
		End If

		Set right_line = in_RightTag.selectSingleNode( "./Line/text()" )
		If not  right_line  is Nothing Then
			right_line = CLng( right_line.nodeValue )
		Else
			right_line = 0
		End If

		CompareTranslateFileLine = left_line - right_line
		If CompareTranslateFileLine = 0 Then
			Set left_words = in_LeftTag.selectSingleNode( "./JP/text()" )
			If not  left_words  is Nothing Then
				left_words = left_words.nodeValue
			Else
				left_words = ""
			End If

			Set right_words = in_RightTag.selectSingleNode( "./JP/text()" )
			If not  right_words  is Nothing Then
				right_words = right_words.nodeValue
			Else
				right_words = ""
			End If

			CompareTranslateFileLine = StrComp( left_words, right_words, 1 )
			If CompareTranslateFileLine = 0 Then
				If not in_LeftTag.selectSingleNode(  "./EN/text()" ) is Nothing  and _
						not in_RightTag.selectSingleNode(  "./EN/text()" ) is Nothing Then

					left_words  = in_LeftTag.selectSingleNode(  "./EN/text()" ).nodeValue
					right_words = in_RightTag.selectSingleNode( "./EN/text()" ).nodeValue

					CompareTranslateFileLine = StrComp( left_words, right_words, 1 )
				End If
			End If
		End If
	End If
End Function


 
'***********************************************************************
'* Function: CompareByNameLength
'***********************************************************************
Function  CompareByNameLength( Left, Right, ByVal Param )
	If IsEmpty( Param ) Then  Param = +1
	CompareByNameLength = ( Len( Left.Name ) - Len( Right.Name ) ) * Param
End Function


 
'***********************************************************************
'* Function: Translate_getOverwritePaths
'***********************************************************************
Function  Translate_getOverwritePaths( TranslatorPath )
	If g_fs.FolderExists( TranslatorPath ) Then
		Set arr = new ArrayClass
		Set c = g_VBS_Lib

		ExpandWildcard  GetFullPath( "*.trans", GetFullPath( TranslatorPath, Empty ) ), _
			c.File or c.SubFolder or c.FullPath, Empty, paths

		For Each  path  In paths
			arr.AddElems  Translate_getOverwritePaths( path )
		Next

		Translate_getOverwritePaths = arr.Items
		Exit Function
	End If


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


 
'***********************************************************************
'* Function: Translate_getWritable
'***********************************************************************
Function  Translate_getWritable( TranslatorPath )
	paths = Translate_getOverwritePaths( TranslatorPath )
	Set dic = CreateObject( "Scripting.Dictionary" )

	For Each path  In paths
		dic( g_fs.GetParentFolderName( GetFullPath( path, GetParentFullPath( _
				 TranslatorPath ) ) ) ) = True
	Next
	Translate_getWritable = dic.Keys
End Function


 
'***********************************************************************
'* Function: GetLineNumsExistNotEnglighChar
'***********************************************************************
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


 
'***********************************************************************
'* Function: RunSwitchesCUI
'***********************************************************************
Sub  RunSwitchesCUI( AppKey,  in_IsShowFirstLabel,  in_ReadyLabel,  in_SettingPath,  in_EmptyOption )
	Set c = g_VBS_Lib
	If IsEmpty( in_IsShowFirstLabel ) Then
		echo  "環境に合わせて複数のテキスト ファイルを自動編集します。"
	End If
	If IsEmpty( in_SettingPath ) Then
		setting_path = InputPath( "設定ファイルのパス >", c.CheckFileExists )
	Else
		setting_path = in_SettingPath
	End If

	Do
		Set switches = new SwitchesClass
		switches.Load  setting_path

		echo_line
		If not IsEmpty( switches.Message ) Then
			echo  switches.Message
			echo  ""
		End If

		echo  "target_set_names: "+ switches.TargetSetNamesCSV
		switches = Empty

		echo  "1. Switches の設定ファイルを編集する [Edit]"
		echo  "2. Switches を使って自動的にファイルを編集する [Do]"
		echo  "9. [Exit]"
		key = Trim( Input( "番号またはコマンド名>" ) )
		Select Case  key
			Case "1": key = "Edit"
			Case "2": key = "Do"
			Case "9": key = "Exit"
		End Select
		If StrComp( key, "Edit", 1 ) = 0 Then
			start  GetEditorCmdLine( setting_path )

		ElseIf StrComp( key, "Do", 1 ) = 0 Then
			Set switches = new SwitchesClass
			switches.IsEnabledReversibleError = False
			switches.Load  setting_path
			paths = switches.GetWritableFolders()

			echo_line
			For Each  path  In  paths
				echo  path
			Next
			echo  ""
			echo  "以上のファイルを編集します。"
			If not IsEmpty( in_ReadyLabel ) Then
				echo  in_ReadyLabel
			End If
			echo  "target_set_names: "+ switches.TargetSetNamesCSV
			key = Input( "開始します。（n=キャンセル）" )
			If key <> "n"  and  key <> "N" Then
				echo_line

				Set w_=AppKey.NewWritable( paths ).Enable()
				switches.Run  Empty

				echo  ""
				echo  "編集しました。"
				Exit Do
			End If
		ElseIf StrComp( key, "Exit", 1 ) = 0 Then
			Exit Do
		End If
	Loop
End Sub


 
'***********************************************************************
'* Function: ChangeSwitches
'***********************************************************************
Sub  ChangeSwitches( in_SettingFilePath, in_EmptyOptions )
	Set Me_ = new SwitchesClass
	Me_.IsEnabledReversibleError = False
	Me_.Run  in_SettingFilePath, in_EmptyOptions
End Sub


 
'***********************************************************************
'* Class: SwitchesClass
'*********************************************************************** 
Class  SwitchesClass

	'// Var: IsVerbose
		Public  IsVerbose

	'// Var: SettingFolderPath
		Public  SettingFolderPath

	'// Var: TargetSetNamesCSV
		Public  TargetSetNamesCSV

	'// Var: RootXML
		Public  RootXML

	'// Var: TargetSetNames
		'// target "set_name" dictionary as dictionary of string.
		'// Key is target or not target "set_name".
		Public  TargetSetNames

	'// Var: SetNames
		'// "set_names" dictionary as dictionary of ArrayClass of string.
		'// Key is target or not target "set_name".
		Public  SetNames

	'// Var: VariablesBefore
		'// as LazyDictionaryClass
		Public  VariablesBefore

	'// Var: VariablesAfter
		'// as LazyDictionaryClass
		Public  VariablesAfter

	'// Var: ReplacingFilePath
		Public  ReplacingFilePath

	'// Var: CurrentFile
		'// return value of <OpenForReplace>.
		Public  CurrentFile

	'// Var: Current_T_Tag
		Public  Current_T_Tag

	'// Var: IsEnabledReversibleError
		Public  IsEnabledReversibleError

	'// Var: Message
		Public  Message


Private Sub  Class_Initialize()
	Me.IsVerbose = False
	Me.IsEnabledReversibleError = True
End Sub


 
'***********************************************************************
'* Method: Load
'*
'* Name Space:
'*    SwitchesClass::Load
'***********************************************************************
Public Sub  Load( in_SettingFilePath )
	Set  root = LoadXML( in_SettingFilePath, Empty )
	setting_file_path = GetFilePathString( in_SettingFilePath )
	Me.SettingFolderPath = GetParentFullPath( setting_file_path )
	Me.Message = Trim2( CutIndentOfMultiLineText( XmlRead( root, "./Message" ), Empty, Empty, Empty ) )


	'// Set "target_set_names"
	Me.TargetSetNamesCSV = root.selectSingleNode( "./SwitchNow" ) _
		.getAttribute( "target_set_names" )
	target_set_names = ArrayFromCSV( Me.TargetSetNamesCSV )

	Me.IsVerbose = ( root.selectSingleNode( "./SwitchNow" ).getAttribute( "verbose" ) = "yes" )


	'// Set "SetNames"
	Set  Me.SetNames = CreateObject( "Scripting.Dictionary" )
	For Each  switch_tag  In  root.selectNodes( "./Switch" )
		Set set_names = new ArrayClass
		set_names.AddCSV  switch_tag.getAttribute( "set_names" ), vbString

		For Each  set_name  In  set_names.Items
			Me.SetNames.Add  set_name,  set_names
		Next
	Next


	'// Set "TargetSetNames"
	Set  Me.TargetSetNames = CreateObject( "Scripting.Dictionary" )
	For Each  target_set_name  In  target_set_names
		If not Me.SetNames.Exists( target_set_name ) Then
			Raise  1, "<ERROR msg=""Target set_name is not defined.""  target="""+ target_set_name + _
				"""  set_names="""+ new_ArrayClass( Me.SetNames.Keys ).CSV +"""/>"
		End If

		Set  set_names = Me.SetNames( target_set_name )
		For Each  set_name  In  set_names.Items
			Me.TargetSetNames.Add  set_name,  target_set_name
		Next
	Next


	'// Load <Variable> tag and <T_Variable> tag for "text_after"
	Set  Me.VariablesAfter  = LoadVariableInXML( root,  setting_file_path )
	For Each  variable_tag  In  root.selectNodes( ".//T_Variable" )
		Set  set_items = Me.LoadSubXML_AsSetItems( variable_tag )
		a_set_name = GetFirst( set_items )
		target_set_name = Me.TargetSetNames( a_set_name )
		Me.VariablesAfter( variable_tag.getAttribute( "name" ) ) = set_items( target_set_name ).Text
	Next

	Set Me.RootXML = root
End Sub


 
'***********************************************************************
'* Method: GetWritableFolders
'*
'* Name Space:
'*    SwitchesClass::GetWritableFolders
'***********************************************************************
Public Function  GetWritableFolders()
	Set root = Me.RootXML

	Set paths = new ArrayClass
	For Each  file_tag  In  root.selectNodes( "./File" )
		path = file_tag.getAttribute( "path" )
		path = Me.VariablesAfter( path )
		path = GetFullPath( path,  Me.SettingFolderPath )

		paths.Add  path
	Next

	GetWritableFolders = paths.Items
End Function


 
'***********************************************************************
'* Method: Run
'*
'* Name Space:
'*    SwitchesClass::Run
'***********************************************************************
Public Sub  Run( in_EmptyOptions )
	Set root = Me.RootXML
	Set ec = new EchoOff

	'// Load <File> tag and Replace
	For Each  file_tag  In  root.selectNodes( "./File" )
		Me.ReplacingFilePath = file_tag.getAttribute( "path" )
		Me.ReplacingFilePath = Me.VariablesAfter( Me.ReplacingFilePath )
		Me.ReplacingFilePath = GetFullPath( Me.ReplacingFilePath,  Me.SettingFolderPath )

		ec = Empty
		echo  Me.ReplacingFilePath
		Set ec = new EchoOff


		For Each  t_tag  In  file_tag.selectNodes( "./T" )
			Set Me.Current_T_Tag = t_tag

			text_type = t_tag.getAttribute( "text_type" )
			If IsNull( text_type ) Then _
				text_type = "text"

			If text_type = "text" Then
				Me_SwitchInFile
			Else
				Assert  text_type = "path"

				Me_SwitchFile
			End If
		Next
		Me.CurrentFile = Empty
		Me.ReplacingFilePath = Empty
	Next
End Sub


 
'***********************************************************************
'* Method: Me_SwitchInFile
'*    Replace text in "Me.CurrentFile" by "Me.Current_T_Tag".
'*
'* Name Space:
'*    SwitchesClass::Me_SwitchInFile
'***********************************************************************
Public Sub  Me_SwitchInFile()
	Set  set_items = Me.LoadSubXML_AsSetItems( Me.Current_T_Tag )


	'// Check
	If set_items.Exists( ">LinesStart" ) <> set_items.Exists( ">LinesEnd" ) Then
		Raise  1, "<ERROR msg=""LinesStart と LinesEnd が片方しか指定されていません。""/>"
	End If


	'// Set "Me.CurrentFile"
	If IsEmpty( Me.CurrentFile ) Then
		If not g_fs.FileExists( Me.ReplacingFilePath ) Then _
			CreateFile  Me.ReplacingFilePath,  ""
		Set  Me.CurrentFile = OpenForReplace( Me.ReplacingFilePath, Empty )
	End If


	'// Set "text_before", "text_after"
	text_after = Empty
	line_attribute = Me.Current_T_Tag.getAttribute( "line" )
	For Each  set_name_before  In  set_items.Keys
		Set  a_item = set_items( set_name_before )
		text_before_template = a_item.Text

		If a_item.IsLazyEvaluation  and  InStr( text_before_template, "${" ) > 0 Then
			variables_befores = Me_ExpandToVariablesBefores( text_before_template )
		Else
			variables_befores = Array( Empty )
		End If


		is_found = False

		For Each  variables_before  In  variables_befores

			If not IsEmpty( variables_before ) Then
				text_before = variables_before( text_before_template )
			Else
				text_before = text_before_template
			End If


			If Me.IsVerbose Then
				echo_v  ""
				echo_v  "text_before:"
				echo_v  Replace( Replace( text_before, "&", "&amp;" ), vbTab, "&#9;" )

				If set_items.Exists( ">LinesStart" ) Then
					Set counter = new LineNumFromTextPositionClass
					counter.Text = Me.CurrentFile.Text
				End If
			End If


			If line_attribute = "head" Then
				re_text_before = "^"+ ToRegExpPattern( text_before )
			ElseIf line_attribute = "whole" Then
				re_text_before = "^"+ ToRegExpPattern( text_before ) +"$"
			Else
				re_text_before = Empty
			End If


			If not set_items.Exists( ">LinesStart" ) Then
				If IsEmpty( re_text_before ) Then
					is_found = ( InStr( Me.CurrentFile.Text, text_before ) > 0 )
				Else
					Set re_text_before = new_RegExp( re_text_before, True )
					is_found = re_text_before.Test( Me.CurrentFile.Text )
				End If
			Else
				next_position = 1
				Do
					keyword = set_items( ">LinesStart" ).Text
					position = InStr( next_position,  Me.CurrentFile.Text,  keyword )
					If position = 0 Then _
						Exit Do
					start_position = GetNextLinePosition( Me.CurrentFile.Text, position )

					keyword = set_items( ">LinesEnd" ).Text
					position = InStr( start_position,  Me.CurrentFile.Text,  keyword )
					If position = 0 Then _
						Raise  1, "<ERROR msg=""LinesEnd のキーワードが見つかりません。""/>"
					end_position = GetLeftEndOfLinePosition( Me.CurrentFile.Text, position )


					If Me.IsVerbose Then
						start_line_num = CStr( counter.GetNextLineNum( start_position ) )
						end_line_num   = CStr( counter.GetNextLineNum( end_position ) )
						echo_v  ">LineStart .. LineEnd : "+ start_line_num +" .. "+ end_line_num
					End If


					part_text = _
						Mid( Me.CurrentFile.Text,  start_position,  end_position - start_position )

					next_position = GetNextLinePosition( Me.CurrentFile.Text, position )

					If IsEmpty( re_text_before ) Then
						is_found = ( InStr( part_text, text_before ) > 0 )
					Else
						Set re_text_before = new_RegExp( re_text_before, True )
						is_found = re_text_before.Test( part_text )
					End If

					If is_found Then _
						Exit Do
				Loop
			End If


			If is_found Then
				target_set_name = Me.GetTargetMultiSetNames( set_name_before )
				If not IsEmpty( target_set_name ) Then
					Set  a_item = set_items( target_set_name )
					text_after = a_item.Text
					If a_item.IsLazyEvaluation Then _
						text_after = Me.VariablesAfter( text_after )
					Exit For
				End If
			End If
		Next

		If is_found Then _
			Exit For
	Next
	If not is_found Then
		text = ""
		For Each  a_item  In  set_items.Items
			text = text + a_item.Text + vbCRLF
		Next
		xpath = XmlAttr( GetXPath( Me.Current_T_Tag,  "path" ) )
		If InStr( xpath, "${" ) >= 1 Then
			xpath_expanded = vbCRLF +"    xpath_expanded="""+ Me.VariablesAfter( xpath ) +""""
		Else
			xpath_expanded = ""
		End If

		Raise  E_SwitchesNotReversible, "<ERROR msg="""+ _
			"指定されたスイッチのテキストが見つかりません。"""+ vbCRLF + _
			"    xpath="""+ xpath +""""+ xpath_expanded +">"+ vbCRLF + _
			text +"</ERROR>"
	End If
	If Me.IsVerbose Then _
		echo_v  ""
	If IsEmpty( text_after ) Then _
		Exit Sub
	If text_after = text_before Then _
		Exit Sub


	'// Set "re_text_after" : Regular Expression of "text_after"
	If line_attribute = "head" Then
		re_text_after = "^"+ ToRegExpPattern( text_after )
	ElseIf line_attribute = "whole" Then
		re_text_after = "^"+ ToRegExpPattern( text_after ) +"$"
	Else
		re_text_after = Empty
	End If
	If not IsEmpty( re_text_after ) Then
		Set re_text_after = new_RegExp( re_text_after, True )
	End If


	'// Check reversible
	is_reversible = True
	If not set_items.Exists( ">LinesStart" ) Then
		If IsEmpty( re_text_before ) Then
			If InStr( Me.CurrentFile.Text,  text_after ) Then
				If InStr( Me.CurrentFile.Text,  text_before ) Then _
					is_reversible = False
			End If
		Else
			'// Check reversible
			If re_text_after.Test( Me.CurrentFile.Text ) Then
				If re_text_before.Test( Me.CurrentFile.Text ) Then _
					is_reversible = False
			End If
		End If
	ElseIf text_after <> "" Then
		next_position = 1
		is_found = False
		Do
			keyword = set_items( ">LinesStart" ).Text
			position = InStr( next_position,  Me.CurrentFile.Text,  keyword )
			If position = 0 Then _
				Exit Do
			start_position = GetNextLinePosition( Me.CurrentFile.Text, position )

			keyword = set_items( ">LinesEnd" ).Text
			position = InStr( start_position,  Me.CurrentFile.Text,  keyword )
			If position = 0 Then _
				Raise  1, "<ERROR msg=""LinesEnd のキーワードが見つかりません。""/>"
			end_position = GetLeftEndOfLinePosition( Me.CurrentFile.Text, position )

			part_text = _
				Mid( Me.CurrentFile.Text,  start_position,  end_position - start_position )

			next_position = GetNextLinePosition( Me.CurrentFile.Text, position )

			If IsEmpty( re_text_before ) Then
				If InStr( part_text,  text_after ) > 0 Then
					If InStr( part_text, text_before ) > 0 Then
						is_reversible = False
						Exit Do
					End If
				End If
			Else
				If re_text_after.Test( part_text ) Then
					If re_text_before.Test( part_text ) Then
						is_reversible = False
						Exit Do
					End If
				End If
			End If
		Loop
	End If
	If not is_reversible Then
		message = "指定されたスイッチを変更すると、戻すことができなくなります。"""+ _
			"  before="""+ text_before +"""  after="""+ text_after +"""/>"

		If Me.IsEnabledReversibleError Then
			Raise  E_SwitchesNotReversible, "<ERROR msg="""+ message
		Else
			echo_v  "<WARNING msg="""+ message
			Exit Sub
		End If
	End If


	'// Call "Replace"
	If not set_items.Exists( ">LinesStart" ) Then
		If IsEmpty( re_text_before ) Then
			Me.CurrentFile.Text = Replace( Me.CurrentFile.Text,  text_before,  text_after )
		Else
			Me.CurrentFile.Text = re_text_before.Replace( Me.CurrentFile.Text,  text_after )
		End If
	Else
		next_position = 1
		whole_text = ""

		If text_after = "" Then _
			text_before = text_before + vbCRLF  '// For cutting a line

		Do
			keyword = set_items( ">LinesStart" ).Text
			position = InStr( next_position,  Me.CurrentFile.Text,  keyword )
			If position = 0 Then _
				Exit Do
			start_position = GetNextLinePosition( Me.CurrentFile.Text, position )

			keyword = set_items( ">LinesEnd" ).Text
			position = InStr( start_position,  Me.CurrentFile.Text,  keyword )
			If position = 0 Then _
				Raise  1, "<ERROR msg=""LinesEnd のキーワードが見つかりません。""/>"
			end_position = GetLeftEndOfLinePosition( Me.CurrentFile.Text, position )

			whole_text = whole_text + _
				Mid( Me.CurrentFile.Text,  next_position,  start_position - next_position )
			part_text = _
				Mid( Me.CurrentFile.Text,  start_position,  end_position - start_position )

			next_position = GetNextLinePosition( Me.CurrentFile.Text, position )


			If text_before <> "" Then
				If IsEmpty( re_text_before ) Then
					part_text = Replace( part_text,  text_before,  text_after )
				Else
					part_text = re_text_before.Replace( part_text,  text_after )
				End If
			Else
				part_text = part_text + text_after + vbCRLF
			End If


			whole_text = whole_text + _
				part_text + _
				Mid( Me.CurrentFile.Text,  end_position,  next_position - end_position )
		Loop
		Me.CurrentFile.Text = whole_text + Mid( Me.CurrentFile.Text,  next_position )
	End If
End Sub


 
'***********************************************************************
'* Method: Me_SwitchFile
'*
'* Name Space:
'*    SwitchesClass::Me_SwitchFile
'***********************************************************************
Public Sub  Me_SwitchFile()
	Set  set_items = Me.LoadSubXML_AsSetItems( Me.Current_T_Tag )
	Me.CurrentFile = Empty  '// Close


	'// Set "source_path_after"
	source_path_after = Empty
	For Each  set_name_before  In  set_items.Keys
		path_before = set_items( set_name_before ).Text
		If InStr( path_before, "${" ) > 0 Then
			path_before = Me.VariablesAfter( path_before )
			'// TODO:
		End If

		If path_before <> "" Then
			path_before = GetFullPath( path_before,  Me.SettingFolderPath )

			is_same = IsSameFolder( path_before,  Me.ReplacingFilePath,  Empty )
		Else
			is_same = not exist( Me.ReplacingFilePath )
		End If

		If is_same Then
			target_set_name = Me.GetTargetMultiSetNames( set_name_before )
			If not IsEmpty( target_set_name ) Then
				source_path_after = set_items( target_set_name ).Text
				If source_path_after <> "" Then
					source_path_after = Me.VariablesAfter( source_path_after )
					source_path_after = GetFullPath( _
						source_path_after,  Me.SettingFolderPath )
				End If
				Exit For
			End If
		End If
	Next


	'// Call "copy_ren"
	If not IsEmpty( source_path_after ) Then
		del  Me.ReplacingFilePath
		If source_path_after <> "" Then
			copy_ren  source_path_after,  Me.ReplacingFilePath
		End If
	End If
End Sub


 
'***********************************************************************
'* Method: GetTargetMultiSetNames
'*
'* Return Value:
'*    Tatget expression, Empty=Not found target
'*
'* Example:
'*    Assert  Me.GetTargetMultiSetNames( "SetA && SetX" ) = "SetB && SetY"
'*
'* Name Space:
'*    SwitchesClass::GetTargetMultiSetNames
'***********************************************************************
Public Function  GetTargetMultiSetNames( in_Expression )
	words = Split( in_Expression, " " )
	For i=0 To UBound( words )
		word = words(i)
		If Me.TargetSetNames.Exists( word ) Then
			words(i) = Me.TargetSetNames( word )
		ElseIf word = "&&" Then
		Else
			Exit Function
		End If
	Next
	GetTargetMultiSetNames = Join( words, " " )
End Function


 
'***********************************************************************
'* Method: LoadSubXML_AsSetItems
'*
'* Return Value:
'*    as dictionary of <SwitchesSetItemClass>. Key is set name.
'*
'* Example: 1
'*    > <T>
'*    >     <SetA>ValueA</SetA>
'*    >     <SetB>ValueB</SetB>
'*    > </T>
'*
'*    > ret = Me.LoadSubXML_AsSetItems( ... )
'*    > ret( "SetA" ).Text = "ValueA"
'*    > ret( "SetB" ).Text = "ValueB"
'*
'* Example: 2
'*    > <T>
'*    >     <SetA>
'*    >         <SetX>A and X</SetX>
'*    >         <SetY>A and Y</SetY>
'*    >     </SetA>
'*    >     <SetB>
'*    >         <SetX>B and X</SetX>
'*    >         <SetY>B and Y</SetY>
'*    >     </SetB>
'*    > </T>
'*
'*    > ret = Me.LoadSubXML_AsSetItems( ... )
'*    > ret( "SetA && SetX" ).Text = "A and X"
'*    > ret( "SetA && SetY" ).Text = "A and Y"
'*    > ret( "SetB && SetX" ).Text = "B and X"
'*    > ret( "SetB && SetY" ).Text = "B and Y"
'*
'* Example: 3
'*    > <T>
'*    >     <LinesStart  attribute_of="T">StartLine</LinesStart>
'*    > </T>
'*
'*    > ret = Me.LoadSubXML_AsSetItems( ... )
'*    > ret( ">LinesStart" ).Text = "StartLine"
'*
'* Name Space:
'*    SwitchesClass::LoadSubXML_AsSetItems
'***********************************************************************
Public Function  LoadSubXML_AsSetItems( in_Parent_XML_Tag )
	Set LoadSubXML_AsSetItems = Me.LoadSubXML_AsSetItems_Sub( in_Parent_XML_Tag,  "" )
End Function

Public Function  LoadSubXML_AsSetItems_Sub( in_Parent_XML_Tag,  in_ParentKeys )
	Const  c_I_XMLDOMElement = 1

	Set return_value = CreateObject( "Scripting.Dictionary" )

	For Each  set_item  In  in_Parent_XML_Tag.childNodes
		do_it = True


		'// Parse 'attribute_of="T"'
		If  do_it  Then
			If set_item.nodeType = c_I_XMLDOMElement Then
				attr = set_item.getAttribute( "attribute_of" )
				If not IsNull( attr ) Then
					If attr <> "T" Then
						Raise  1, "<ERROR msg=""Invalid 'attribute_of''s value""  attribute_of="""+ attr +"""/>"
					End If

					If set_item.tagName = "LinesStart" Then
					ElseIf set_item.tagName = "LinesEnd" Then
					Else
						Raise  1, "<ERROR msg=""Invalid tagName of 'attribute_of=T'""  tagName="""+ _
							set_item.tagName +"""/>"
					End If


					Set  a_item = new SwitchesSetItemClass
					Set  return_value( ">"+ set_item.tagName ) = a_item
					a_item.Text = set_item.selectSingleNode( "text()" ).nodeValue
					a_item.IsLazyEvaluation = ( set_item.getAttribute( "variable" ) = "yes" )


					do_it = False  '// continue
				End If
			Else
				do_it = False  '// continue
			End If
		End If


		'// Parse nested XML tags
		If  do_it  Then
			set_name = set_item.tagName

			Set text_node = set_item.selectSingleNode( "text()" )
			If  text_node  is Nothing Then

				child_tag = Empty
				If not set_item.firstChild is Nothing Then _
					If set_item.firstChild.nodeType = c_I_XMLDOMElement Then _
						Set child_tag = set_item.firstChild
				If not IsEmpty( child_tag ) Then


					next_parent_keys = in_ParentKeys + set_name +" && "


					Set  child_items = Me.LoadSubXML_AsSetItems_Sub( set_item,  next_parent_keys )


					For Each  child_set_name  In  child_items.Keys
						Set  return_value( next_parent_keys + child_set_name ) = child_items( child_set_name )
					Next

					do_it = False  '// continue
				End If
			End If
		End If


		'// Parse a tag
		If  do_it  Then
			Set  a_item = new SwitchesSetItemClass
			Set  return_value( set_name ) = a_item

			If not  text_node  is Nothing Then
				a_item.Text = text_node.nodeValue
			Else
				a_item.Text = ""
			End If
			a_item.IsLazyEvaluation = ( set_item.getAttribute( "variable" ) = "yes" )

			If set_item.getAttribute( "cut_indent" ) = "yes" Then
				a_item.Text = CutIndentOfMultiLineText( a_item.Text,  set_item.getAttribute( "indent" ), _
					set_item.getAttribute( "new_line" ), g_VBS_Lib.CutLastLineSeparator )
			End If
			If set_item.getAttribute( "dump" ) = "yes" Then
				echo_v  new_BinaryArrayAsText( a_item.Text, Empty ).xml
			End If


			'// Check "set_name" is not in other "set_names".
			If IsEmpty( set_names ) Then
				If not Me.SetNames.Exists( set_name ) Then
					Raise  1,  "<ERROR msg=""'SwitchNow/@target_set_names' に書かれた名前が Tタグに見つかりません。"""+ _
						"  target_set_names="""+ Me.TargetSetNamesCSV +""">"+ vbCRLF + _
						in_Parent_XML_Tag.xml+ vbCRLF + "</ERROR>"
				End If

				Set  set_names = Me.SetNames( set_name )
			Else
				If not Me.SetNames.Exists( set_name ) Then
					Raise  1,  "<ERROR msg=""Tタグの子タグの名前が、'Switch/@set_names' に見つかりません。"""+ _
						"  set_names="""+ new_ArrayClass( Me.SetNames.Keys ).CSV +""">"+ vbCRLF + _
						in_Parent_XML_Tag.xml+ vbCRLF + "</ERROR>"
				End If

				If not Me.SetNames( set_name )  is  set_names Then
					Raise  1,  "<ERROR msg=""Conflicted 'set_names'"">"+ vbCRLF + _
						in_Parent_XML_Tag.xml+ vbCRLF + "</ERROR>"
				End If
			End If
		End If
	Next


	Set LoadSubXML_AsSetItems_Sub = return_value
End Function


 
'***********************************************************************
'* Method: Me_ExpandToVariablesBefores
'*
'* Name Space:
'*    SwitchesClass::Me_ExpandToVariablesBefores
'***********************************************************************
Function  Me_ExpandToVariablesBefores( text_before_template )
	Set  root = Me.RootXML
	Set  variables = CreateObject( "Scripting.Dictionary" )
	For Each  variable_tag  In  root.selectNodes( ".//T_Variable" )
		variable_name = variable_tag.getAttribute( "name" )
		If InStr( text_before_template, variable_name ) > 0 Then
			Set variables( variable_name ) = Me.LoadSubXML_AsSetItems( variable_tag )
		End If
	Next


	If variables.Count >= 2 Then _
		Error  'TODO: Not Supported Nested

	Set variables_befores = new ArrayClass
	For Each  variable_name  In  variables.Keys
		Set set_items_of_one_var = variables( variable_name )
		For Each  set_name  In  variables( variable_name ).Keys
			Set  variables_before = new_LazyDictionaryClass( root )
			variables_before( variable_name ) = set_items_of_one_var( set_name ).Text

			variables_befores.Add  variables_before
		Next
	Next
	Me_ExpandToVariablesBefores = variables_befores.Items
End Function


 
End Class
'* Section: Global


 
'***********************************************************************
'* Class: SwitchesSetItemClass
'*********************************************************************** 
Class  SwitchesSetItemClass
	Public  Text  '// as string
	Public  IsLazyEvaluation  '// as boolean
End Class
'* Section: Global


 
'***********************************************************************
'* Class: CrossFindClass
'*
'* Data structure:
'* - <CrossFindClass>
'* - | <CrossFind_ProjectClass> .Projects
'* - | | <CrossFind_ModuleClass> .Modules
'* - | | | array of string        .Elements
'* - | <CrossFind_OutElementClass> .m_OutElements
'* - | | <CrossFind_OutModuleTypeClass> .m_OutModuleTypes
'***********************************************************************
Class  CrossFindClass

	'* Var: Projects
		'// as ArrayClass of <CrossFind_ProjectClass>
		Public  Projects

	'* Var: m_OutElements
		'// as dictionary of <CrossFind_OutElementClass>. Key=ElementName
		Private  m_OutElements

	'* Var: m_IsModifing
		Private  m_IsModifing

	'* Var: MaxModuleNumber
		Public  MaxModuleNumber

	'* Var: ModuleTypesByElement
		'// as dictionary of array of <NameOnlyClass> of <CrossFind_ModuleClass>.
		'// Key = ElementName.  Name = module_types(i).Name +", "+ module.Name.
		Public  ModuleTypesByElement

	'* Var: ObjectID
		Public  ObjectID


	Private Sub  Class_Initialize()
		Set Me.Projects = new ArrayClass
		Set m_OutElements = CreateObject( "Scripting.Dictionary" )
		m_IsModifing = False
		Me.MaxModuleNumber = 0
		Set Me.ModuleTypesByElement = CreateObject( "Scripting.Dictionary" )
		Me.ObjectID = g_ObjectIDs.Add( Me )
	End Sub

	Private Sub  Class_Terminate()
		g_ObjectIDs.Remove  Me.ObjectID
	End Sub


 
'***********************************************************************
'* Method: AddProject
'*
'* Name Space:
'*    CrossFindClass::AddProject
'***********************************************************************
Public Function  AddProject( in_ProjectName )
	Set project = new CrossFind_ProjectClass
	project.Name = in_ProjectName
	project.RootObjectID = Me.ObjectID
	Me.Projects.Add  project
	m_IsModifing = True
	Set AddProject = project
End Function


 
'***********************************************************************
'* Method: AddToOutElements
'*
'* Name Space:
'*    CrossFindClass::AddToOutElements
'***********************************************************************
Public Sub  AddToOutElements( in_ElementName )
	Set element = new CrossFind_OutElementClass
	element.Name = in_ElementName
	element.RootObjectID = Me.ObjectID
	Set m_OutElements( in_ElementName ) = element
End SUb


 
'***********************************************************************
'* Property: OutElements
'*
'* Name Space:
'*    CrossFindClass::OutElements
'***********************************************************************
Public Property Get  OutElements()
	is_debug = False

	Set OutElements = m_OutElements
	If not m_IsModifing Then _
		Exit Property

	m_IsModifing = False

	Set find_ = Me

	For Each  project  In  Me.Projects.Items
		For Each  module  In  project.Modules.Items

			If is_debug Then
				echo_v  "991=> project.Name = "+ GetEchoStr( project.Name )
				echo_v  "992=> module.Name = "+ GetEchoStr( module.Name )
			End If


			'// Set "candidate_modules" : same as "module"
			candidate_modules = Array( )  '// as array of "CrossFind_ModuleClass"
			Set new_element_names = new ArrayClass
			is_first_element = True
			For Each  element_name  In  module.Elements
				If is_first_element Then
					If find_.ModuleTypesByElement.Exists( element_name ) Then
						candidate_modules = find_.ModuleTypesByElement( element_name ).Items
						is_first_element = False
					Else
						new_element_names.Add  element_name
					End If
				ElseIf find_.ModuleTypesByElement.Exists( element_name ) Then
					modules_A = candidate_modules
					modules_B = find_.ModuleTypesByElement( element_name ).Items

					m=0
					For i=0  To  UBound( modules_A )
						For k=0  To  UBound( modules_B )
							If modules_A(i).Delegate  is  modules_B(k).Delegate Then
								Set candidate_modules(m) = modules_A(i)
								m=m+1
							End If
						Next
					Next
					ReDim Preserve  candidate_modules(m-1)
				Else
					new_element_names.Add  element_name
				End If
			Next


			If UBound( candidate_modules ) = -1  or  new_element_names.Count >= 1 Then
				is_added = False


				If not is_first_element  and  UBound( candidate_modules ) + 1 >= 1  and _
						new_element_names.Count >= 1 Then

					'// Change module in "find_.ModuleTypesByElement"
					old_elements = ArrayToNameOnlyClassArray( module.Elements )
					RemoveObjectsByNames  old_elements,  new_element_names.Items
					old_elements = NameOnlyClassArrayToArray( old_elements )

					Me_MergeModules_Sub  module,  old_elements,  new_element_names,  is_added
				End If


				If not  is_added Then

					'// Add to "find_.ModuleTypesByElement"
					For Each  element_name  In  module.Elements
						Dic_addInArrayItem  find_.ModuleTypesByElement,  element_name, _
							new_NameOnlyClass( module.Name, module )
					Next


					'// Set "module.ModuleNumber"
					find_.MaxModuleNumber = find_.MaxModuleNumber + 1
					module.ModuleNumber = find_.MaxModuleNumber
				End If
			Else
				'// Add to "module.Name" only
				For Each  element_name  In  module.Elements
					For Each  a_module  In  find_.ModuleTypesByElement( element_name ).Items
						If a_module.Delegate  is  candidate_modules(0).Delegate Then
							a_module.Name = a_module.Name +", "+ module.Name
						End If
					Next
				Next
			End If


			If is_debug Then
				echo_v  "997=> find_.ModuleTypesByElement = "+ GetEchoStr( find_.ModuleTypesByElement )
			End If
		Next
	Next
End Property


 
'***********************************************************************
'* Method: Me_MergeModules_Sub
'*
'* Name Space:
'*    CrossFindClass::Me_MergeModules_Sub
'***********************************************************************
Private Sub  Me_MergeModules_Sub( module,  old_elements,  new_element_names,  is_added )
	Set find_ = Me


	merging_old_module = Empty
	merging_element_name = Empty
	For Each  element_name  In  find_.ModuleTypesByElement.Keys
		For Each  old_module  In  find_.ModuleTypesByElement( element_name ).Items


			'// 新要素を除いた要素から構成される既存のモジュールを探す
			If IsEmpty( merging_old_module ) Then

				is_merge = True
				Assert  UBound( old_elements ) + 1 >= 1
				For Each  old_element  In  old_elements
					is_found = False
					For Each  d_element  In  old_module.Delegate.Elements
						If d_element = old_element Then
							is_found = True
							Exit For
						End If
					Next
					If not  is_found Then
						is_merge = False
						Exit For
					End If
				Next

				If is_merge Then

					'// Set "new_module"
					Set new_module = new CrossFind_ModuleClass
					new_module.Name = "_merged_"+ old_module.Delegate.Name +"_"+ module.Name

					Set new_elements = new_ArrayClass( old_module.Delegate.Elements )
					new_elements.AddElems  new_element_names

					new_module.Elements = new_elements.Items

					find_.MaxModuleNumber = find_.MaxModuleNumber + 1
					new_module.ModuleNumber = find_.MaxModuleNumber


					'// ...
					Set  merging_old_module = old_module
					merging_element_name = element_name
					is_merge = False
				End If
			Else
				is_merge = ( old_module.Delegate  is  merging_old_module.Delegate )
			End If


			'// Merge in <ModuleType> tag
			If is_merge Then
				Me_MergeModules_Sub2  module,  element_name,  merging_old_module,  new_module,  is_added
			End If
		Next
	Next


	'// Merge in first <ModuleType> tag
	If not IsEmpty( merging_old_module ) Then
		Me_MergeModules_Sub2  module,  merging_element_name,  merging_old_module,  new_module,  is_added
	End If


	'// Add "new_element_name" to "find_.ModuleTypesByElement"
	If not IsEmpty( new_module ) Then
		For Each  new_element_name  In  new_element_names.Items
			If not  find_.ModuleTypesByElement.Exists( new_element_name ) Then
				Dic_addInArrayItem _
					find_.ModuleTypesByElement,  new_element_name, _
					new_NameOnlyClass( module.Name, new_module )
			End If
		Next
	End If
End Sub


 
'***********************************************************************
'* Method: Me_MergeModules_Sub2
'*
'* Name Space:
'*    CrossFindClass::Me_MergeModules_Sub2
'***********************************************************************
Private Sub  Me_MergeModules_Sub2( module,  element_name,  merging_old_module,  new_module,  is_added )
	Set find_ = Me

	indexes = Dic_searchInArrayItem( _
		find_.ModuleTypesByElement,  element_name, _
		merging_old_module,  GetRef( "DelegateCompare" ),  Empty )
	Set module_types = find_.ModuleTypesByElement( element_name )
	For Each  i  In  indexes

		is_match = False
		For Each  a_element_name  In  module.Elements
			If a_element_name = element_name Then
				is_match = True
				Exit For
			End If
		Next

		If is_match Then
			module_types(i).Name = module_types(i).Name +", "+ module.Name
		End If
		Set  module_types(i).Delegate = new_module
		is_added = True
	Next
End Sub


 
'***********************************************************************
'* Property: xml
'*
'* Name Space:
'*    CrossFindClass::xml
'***********************************************************************
Public Property Get  xml() : xml=xml_sub(0) : CutLastOf xml,vbCRLF,Empty : End Property
Public Function  xml_sub( Level )
	xml_sub = GetTab(Level)+ "<"+TypeName(Me)+">"+ vbCRLF + _
		Me.Projects.xml_sub( Level + 1 ) + _
		GetTab(Level)+ "</"+TypeName(Me)+">"+ vbCRLF
End Function


 
End Class

'* Section: Global


 
'***********************************************************************
'* Class: CrossFind_ProjectClass
'***********************************************************************
Class  CrossFind_ProjectClass

	'* Var: Name
		Public  Name

	'* Var: Modules
		'// as ArrayClasss of <CrossFind_ModuleClass>
		Public  Modules

	'* Var: RootObjectID
		'// as ID of <CrossFindClass>
		Public  RootObjectID


	Private Sub  Class_Initialize()
		Set Me.Modules = new ArrayClass
	End Sub


'***********************************************************************
'* Method: AddModule
'*
'* Arguments:
'*    in_ModuleName - as string.
'*    in_Elements   - as array of string.
'*
'* Name Space:
'*    CrossFind_ProjectClass::AddModule
'***********************************************************************
Public Sub  AddModule( in_ModuleName,  in_Elements )
	Assert  UBound( in_Elements ) + 1 >= 1

	Set module = new CrossFind_ModuleClass
	module.Name = in_ModuleName
	module.Elements = in_Elements
	Me.Modules.Add  module

	Set find_ = g_ObjectIDs( Me.RootObjectID )
	For Each  element_name  In  in_Elements
		find_.AddToOutElements  element_name
	Next
End Sub


 
'***********************************************************************
'* Property: xml
'*
'* Name Space:
'*    CrossFind_ProjectClass::xml
'***********************************************************************
Public Property Get  xml() : xml=xml_sub(0) : CutLastOf xml,vbCRLF,Empty : End Property
Public Function  xml_sub( Level )
	xml_sub = GetTab(Level)+ "<"+TypeName(Me)+">"+ vbCRLF + _
		Me.Modules.xml_sub( Level + 1 ) + _
		GetTab(Level)+ "</"+TypeName(Me)+">"+ vbCRLF
End Function


 
End Class

'* Section: Global


 
'***********************************************************************
'* Class: CrossFind_ModuleClass
'***********************************************************************
Class  CrossFind_ModuleClass

	'* Var: Name
		Public  Name

	'* Var: Elements
		'// as array of string
		Public  Elements

	'* Var: ModuleNumber
		Public  ModuleNumber


 
'***********************************************************************
'* Property: xml
'*
'* Name Space:
'*    CrossFind_ModuleClass::xml
'***********************************************************************
Public Property Get  xml() : xml=xml_sub(0) : CutLastOf xml,vbCRLF,Empty : End Property
Public Function  xml_sub( Level )
	xml_sub = GetTab(Level)+ "<"+TypeName(Me)+" ModuleNumber="""+ CStr( Me.ModuleNumber ) + _
		""" Name="""+ XmlAttrA( Me.Name ) +""">"+ vbCRLF + _
		new_ArrayClass( Me.Elements ).CSV + vbCRLF + _
		GetTab(Level)+ "</"+TypeName(Me)+">" + vbCRLF
End Function


 
End Class

'* Section: Global


 
'***********************************************************************
'* Class: CrossFind_OutElementClass
'***********************************************************************
Class  CrossFind_OutElementClass

	'* Var: Name
		Public  Name

	'* Var: m_OutModuleTypes  '// TODO: need it?
		'// as ArrayClass of <CrossFind_OutModuleTypeClass>
		Private  m_OutModuleTypes

	'* Var: RootObjectID
		'// as ID of <CrossFindClass>
		Public  RootObjectID


	Private Sub  Class_Initialize()
		Set m_OutModuleTypes = new ArrayClass
	End Sub


 
'***********************************************************************
'* Property: OutModuleTypes
'*
'* Return Value:
'*    as dictionary of array of <NameOnlyClass> of <CrossFind_ModuleClass>.
'*    Key = ElementName.  Name = module_types(i).Name +", "+ module.Name.
'*
'* Name Space:
'*    CrossFind_OutElementClass::OutModuleTypes
'***********************************************************************
Public Property Get  OutModuleTypes()
	Set find_ = g_ObjectIDs( Me.RootObjectID )
	Set OutModuleTypes = find_.ModuleTypesByElement( Me.Name )
End Property

 
End Class

'* Section: Global


 
'***********************************************************************
'* Class: CrossFind_OutModuleTypeClass
'***********************************************************************
Class  CrossFind_OutModuleTypeClass

	'* Var: Names
		'// as ArrayClass of string
		Private  Names

	'* Var: Elements
		'// as ArrayClass of string
		Private  Elements


	Private Sub  Class_Initialize()
		Set Me.Names = new ArrayClass
		Set Me.Elements = new ArrayClass
	End Sub

End Class

'* Section: Global


 
'***********************************************************************
'* Function: CutLineFeedAtRightEnd
'***********************************************************************
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


 
'***********************************************************************
'* Function: MakeSettingForCheckEnglish
'***********************************************************************
Sub  MakeSettingForCheckEnglish( CheckEnglishOnlyFilePath,  in_CheckingRootPathOrTranslateFilePaths )
	Set out_file = OpenForWrite( CheckEnglishOnlyFilePath, Empty )
	out_parnet_folder = GetParentFullPath( CheckEnglishOnlyFilePath )
	out_file.WriteLine  "[CheckEnglishOnlyExe]"

	If IsArray( in_CheckingRootPathOrTranslateFilePaths ) Then
		For Each translate_path  In  in_CheckingRootPathOrTranslateFilePaths
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
	Else
		Set c = g_VBS_Lib
		root_path = GetFullPath( in_CheckingRootPathOrTranslateFilePaths, Empty )

		ExpandWildcard  root_path +"\*.trans", c.File or c.SubFolder or c.AbsPath, dummy, paths
		For Each translate_path  In  paths

			out_file.WriteLine  ""
			out_file.WriteLine  ";// From """+ _
				GetStepPath( translate_path,  out_parnet_folder ) +""" file"

			Set root = LoadXML( translate_path, Empty )
			in_parent_folder = GetParentFullPath( translate_path )
			For Each elem  In root.selectNodes( "./File/text()" )

				out_file.WriteLine  "ExceptFile = "+_
					GetStepPath( GetFullPath( elem.text, in_parent_folder ),  out_parnet_folder )
			Next
		Next
	End If
End Sub


 
'***********************************************************************
'* Function: SynchronizeFolder
'***********************************************************************
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
						'//     DateLastModified( m_Indexes.FileB )
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


 
'***********************************************************************
'* Class: CopyNotOverwriteFileClass
'***********************************************************************
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


 
'***********************************************************************
'* Class: DeleteSameFileClass
'***********************************************************************
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


 
'***********************************************************************
'* Function: CheckEnglishOnly
'***********************************************************************
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

	out_text = ReadFile( out )
	If  r < 0  or  r > 1  or  InStr( out_text, "<ERROR" ) > 0  Then

		If IsEmpty( SettingPath ) Then
			is_raise_error = True
		Else
			is_raise_error = GetIniFileTextValue( ReadFile( SettingPath ), _
				"CheckEnglishOnlyVbs", "IsRaiseError", Empty )
		End If
		If IsEmpty( is_raise_error )  or  is_raise_error Then
			ec = Empty
			echo_v  out_text
			Raise  r, "<ERROR msg=""CheckEnglishOnly.exe でエラーが発生しました""/>"
		End If
	End If


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

	If en <> 0  and  g_EchoObj.m_bEchoOff  Then _
		echo_v  g_fs.OpenTextFile( out, 1, False, False ).ReadAll()
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


 
'***********************************************************************
'* Function: ChangeHeadSpaceToTab
'***********************************************************************
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


 
'***********************************************************************
'* Function: ChangeHeadTabToSpace
'***********************************************************************
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


 
'***********************************************************************
'* Function: ChangeMiddleSpaceToTab
'***********************************************************************
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


 
'***********************************************************************
'* Function: ChangeMiddleTabToSpace
'***********************************************************************
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


 
'***********************************************************************
'* Function: OpenForWriteTextSection
'***********************************************************************
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
		Me.BOM = AnalyzeCharacterCodeSet( SourcePath )
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


 
'***********************************************************************
'* Function: CreateFromTextSections
'***********************************************************************
Sub  CreateFromTextSections( in_XML_Path, ByVal in_XML_Root, in_CreateFilePath, in_MixedTextXPath, in_out_Options )
	Set linker = new LinkedXMLs
	linker.XmlTagNamesHavingIdName = Array( "MixedText" )
	If IsEmpty( in_XML_Root ) Then _
		Set in_XML_Root = LoadXML( in_XML_Path, Empty )

	If IsEmpty( in_CreateFilePath ) Then
		xml_folder_path = GetParentFullPath( in_XML_Path )
		For Each  create_file_tag  In  in_XML_Root.selectNodes( "./CreateFile" )
			out_path = GetFullPath( create_file_tag.getAttribute( "path" ), xml_folder_path )

			linker.StartNavigation  in_XML_Path, in_XML_Root
			mixed_text_href = create_file_tag.getAttribute( "mixed_text_href" )
			Set mixed_text_tag = linker.GetLinkTargetNode( mixed_text_href )
			text = ReadTextSections( mixed_text_tag, ".", linker.TargetXmlPath, Empty, Empty )
			linker.EndNavigation

			CreateFile  out_path, text

			If text = ""  and  IsBitSet( in_out_Options, get_ToolsLibConsts().DeleteIfNoSection ) Then
				del  out_path
			End If
		Next
	Else
		Assert  not IsEmpty( in_MixedTextXPath )

		out_path = in_CreateFilePath
		If InStr( in_MixedTextXPath, "#" ) > 0 Then
			linker.StartNavigation  in_XML_Path, in_XML_Root
			Set mixed_text_tag = linker.GetLinkTargetNode( in_MixedTextXPath )
			text = ReadTextSections( mixed_text_tag, ".", linker.TargetXmlPath, Empty, Empty )
			linker.EndNavigation
		Else
			text = ReadTextSections( in_XML_Root, in_MixedTextXPath, in_XML_Path, Empty, Empty )
		End If

		CreateFile  out_path, text
	End If
End Sub


 
'***********************************************************************
'* Function: ReadTextSections
'***********************************************************************
Function  ReadTextSections( in_XML_Root, in_MixedTextXPath, in_XML_FilePath, _
		in_VariablesForPath, in_Empty )

	base_path = GetParentFullPath( in_XML_FilePath )
	text = ""

	Set variables = new_LazyDictionaryClass( in_XML_Root )
	If not IsEmpty( in_VariablesForPath ) Then _
		Dic_add  variables, in_VariablesForPath

	Set  setting_tag = in_XML_Root.selectSingleNode( in_MixedTextXPath )
	For Each  elem  In  setting_tag.selectNodes( "./TextSection" )
		Set jumps = GetTagJumpParams( elem.getAttribute( "path" ) )
		jumps.Path = variables( jumps.Path )
		next_full_path = GetFullPath( jumps.Path, base_path )


		'// Set "whole_text", "file"
		If next_full_path <> reading_full_path Then
			reading_full_path = next_full_path
			If g_VBS_Lib.TextReadCache.Exists( reading_full_path ) Then
				whole_text = g_VBS_Lib.TextReadCache( reading_full_path )
			Else
				If not g_fs.FileExists( reading_full_path ) Then
					Raise  E_FileNotExist, "<ERROR msg=""Not found"" URL="""+_
						reading_full_path +"""/>"
				End If
				whole_text = ReadFile( reading_full_path )
				g_VBS_Lib.TextReadCache( reading_full_path ) = whole_text
			End If

			Set file = new StringStream
			file.SetString  whole_text
		End If


		'// Case of without "#" in URL
		If IsEmpty( jumps.Keyword ) Then
			start_line = elem.getAttribute( "start_line" )
			end_line   = elem.getAttribute( "end_line" )
			If IsNull( start_line )  or  IsNull( end_line ) Then
				text = text + whole_text
				If Right( whole_text, 1 ) <> vbLF Then
					text = text + vbCRLF
				End If
			Else
				If next_full_path = reading_full_path Then _
					file.SetString  whole_text
				start_line = CLng( start_line )
				end_line   = CLng( end_line )
				is_hit = False
				Do Until  file.AtEndOfStream()
					file_line = file.Line
					If file_line = start_line Then _
						is_hit = True

					line = file.ReadLine()

					If is_hit Then _
						text = text + line + vbCRLF

					If file_line = end_line Then _
						Exit Do
				Loop
			End If


		'// Case of with "#" in URL
		Else
			keyword = jumps.Keyword
			part_text = ""
			is_hit = False

			Do
				If not file.AtEndOfStream() Then
					line = file.ReadLine()
					part_text = part_text + line + vbCRLF
				End If

				If InStr( line, keyword ) > 0 Then
					is_hit = True
				End If

				If line = " "  or  file.AtEndOfStream() Then
					If is_hit Then
						If file.AtEndOfStream() Then
							If Right( part_text, 5 ) <> vbCRLF +" "+ vbCRLF Then
								part_text = part_text +" "+ vbCRLF
							End If
						End If

						text = text + part_text
						Exit Do
					End If

					part_text = ""

					If file.AtEndOfStream() Then
						If InStr( whole_text, keyword ) = 0 Then
							Raise  E_FileNotExist, "<ERROR msg=""Not found"" URL="""+ _
								full_path +"#"+ keyword +"""/>"
						End If
						file.SetString  whole_text
					End If
				End If
			Loop
		End If
	Next
	ReadTextSections = text
End Function


 
'***********************************************************************
'* Function: ConnectInTextSectionIndexFile
'***********************************************************************
Sub  ConnectInTextSectionIndexFile( in_IndexFilePath, in_KeywordAndName, in_Empty )
	If g_fs.FolderExists( in_IndexFilePath ) Then
		For Each  path  In  ArrayFromWildcard2( in_IndexFilePath ).FullPaths
			ConnectInTextSectionIndexFile  path, in_KeywordAndName, in_Empty
		Next
	Else
		Set root = LoadXML( in_IndexFilePath, Empty )
		For Each  tag  In  root.selectNodes( "./TextSection" )
			For i=0 To UBound( in_KeywordAndName )
				keyword = in_KeywordAndName(i)(0)
				name    = in_KeywordAndName(i)(1)

				If tag.getAttribute( "keyword" ) = keyword  and _
						tag.getAttribute( "name" ) = name  and _
						not IsEmpty( previous_tag ) Then
					previous_tag.setAttribute  "end_line",  tag.getAttribute( "end_line" )
					tag.parentNode.removeChild  tag
					is_modified = True
					Exit For
				End If
			Next
			Set previous_tag = tag
		Next
		If is_modified Then _
			root.ownerDocument.save  in_IndexFilePath
	End If
End Sub


 
'***********************************************************************
'* Function: CreateFileNameDictionary
'***********************************************************************
Function  CreateFileNameDictionary( in_PathDictionary )
	Const  c_NotCaseSensitive = 1

	Set dic = CreateObject( "Scripting.Dictionary" )
	dic.CompareMode = c_NotCaseSensitive

	For Each  path  In  ArrayFromWildcard( in_PathDictionary ).FullPaths
		Dic_addInArrayItem  dic,  g_fs.GetFileName( path ),  path
	Next

	Set CreateFileNameDictionary = dic
End Function


 
'***********************************************************************
'* Function: MakeCrossedOldSections
'***********************************************************************
Sub  MakeCrossedOldSections( in_OutFolderPath, in_NewFolderPath, in_OldFolderPath, _
		in_NewTxscPath, in_OldTxscPath, in_Option )

	Set c = g_VBS_Lib
	If IsObject( in_Option ) Then _
		Set renames_tag = in_Option
	Set ec = new EchoOff

	new_folder_path = GetFullPath( GetBasePath( in_NewFolderPath ), Empty )
	old_folder_path = GetFullPath( in_OldFolderPath, Empty )
	out_folder_path = GetFullPath( in_OutFolderPath, Empty )
	g_AppKey.CheckWritable  in_OutFolderPath,  Empty

	Set moved_list   = CreateObject( "Scripting.Dictionary" )
	Set renamed_list = CreateObject( "Scripting.Dictionary" )

	MakeTextSectionIndexFile  in_NewFolderPath, "NaturalDocs", "",  new_folder_path,   in_NewTxscPath
	MakeTextSectionIndexFile  in_OldFolderPath, "NaturalDocs", "",  in_OldFolderPath,  in_OldTxscPath
	connecting = Array( Array( "Section", "Global" ), Array( "End of File", "" ), Array( "Macros", "" ), _
		Array( "Constants", "" ) )
	ConnectInTextSectionIndexFile  in_NewTxscPath,  connecting,  Empty
	ConnectInTextSectionIndexFile  in_OldTxscPath,  connecting,  Empty
	Set old_file_names = CreateFileNameDictionary( in_OldFolderPath )


	'// Set "new_sections". Key = path
	Set new_sections = CreateObject( "Scripting.Dictionary" )

	ExpandWildcard  in_NewTxscPath +"\*",  c.File or c.SubFolder,  folder,  step_paths
	For Each  step_path  In  step_paths
		txsc_path = GetFullPath( step_path, folder )
		Set root = LoadXML( txsc_path, Empty )
		source_path = GetFullPath( root.getAttribute( "path" ), g_fs.GetParentFolderName( txsc_path ) )
		Set new_sections( source_path ) = root
	Next


	'// Set "old_sections". Key = identifier
	Set old_sections = CreateObject( "Scripting.Dictionary" )
	Set old_XML_roots = CreateObject( "Scripting.Dictionary" )

	ExpandWildcard  in_OldTxscPath +"\*",  c.File or c.SubFolder,  folder,  step_paths
	For Each  step_path  In  step_paths
		txsc_path = GetFullPath( step_path, folder )
		Set root = LoadXML( txsc_path, Empty )
		source_path = GetFullPath( root.getAttribute( "path" ), g_fs.GetParentFolderName( txsc_path ) )
		root.setAttribute  "_full_path",  source_path
		Set old_XML_roots( source_path ) = root
		For Each  tag  In  root.selectNodes( "./TextSection" )
			name = tag.getAttribute( "name" )
			If not IsNull( name )  and  name <> "" Then
				key = tag.getAttribute( "keyword" ) +": "+ name
				Dic_addInArrayItem  old_sections,  key,  tag


				'// Add to "moved_list" : Reset value
				names = key
				If IsObject( rename_tag ) Then
					For Each  rename_tag  In  renames_tag.selectNodes( _
							"./Rename[@old='"+ name +"']" )
						names = names +"  or  "+ rename_tag.getAttribute( "new" )
					Next
					For Each  rename_tag  In  renames_tag.selectNodes( _
							"./Rename[@new='"+ name +"']" )
						names = names +"  or  "+ rename_tag.getAttribute( "old" )
					Next
				End If

				Set moved_list( source_path + _
					"("+ tag.getAttribute( "start_line" ) +")-("+ _
					tag.getAttribute( "end_line" ) +")" ) = _
					new_NameOnlyClass( "(ERROR NotRequestedFromNewOrAlreadyMatched """+ _
					names +""")::"+ names,  Empty )
			End If
		Next
	Next


	'// Make crossed old sections files in "out_folder_path"
	writing_path = GetTempPath( "MakeCross_*.txt" )
	For Each  new_full_path  In ArrayFromWildcard( in_NewFolderPath ).FullPaths
		step_path = GetStepPath( new_full_path,  new_folder_path )
		path_in_new = GetFullPath( step_path,  new_folder_path )
		Set new_XML_root = new_sections( path_in_new )
		out_path = GetFullPath( step_path,  out_folder_path )
		ec = Empty
		echo  "Writing """+ out_path +""""
		Set ec = new EchoOff
		Set writing_file = OpenForWrite( writing_path, Empty )


		'// Write header
		old_same_path = Empty
		file_name = g_fs.GetFileName( out_path )
		If old_file_names.Exists( file_name ) Then
			If old_file_names( file_name ).Count = 1 Then
				old_same_path = old_file_names( file_name )(0)
			End If
		End If
		If not IsEmpty( old_same_path ) Then
			Set old_XML_root = old_XML_roots( old_same_path )
			Set section_tag = old_XML_root.selectSingleNode( "./TextSection" )
			If section_tag  is Nothing Then
				writing_file = Empty
				copy_ren  old_same_path,  writing_path
				Set writing_file = OpenForWrite( writing_path, c.Append )
			Else
				over_line_num = CInt2( section_tag.getAttribute( "start_line" ) )
				Set reading_file = OpenForRead( old_same_path )
				Do Until  reading_file.AtEndOfStream
					If reading_file.Line >= over_line_num Then _
						Exit Do
					writing_file.WriteLine  reading_file.ReadLine()
				Loop
				reading_file = Empty
			End If
			old_XML_roots.Remove  old_same_path
		End If


		'// Write sections
		For Each  tag_in_new  In  new_XML_root.selectNodes( "./TextSection" )
			name = tag_in_new.getAttribute( "name" )
			If not IsNull( name )  and  name <> "" Then
				key = tag_in_new.getAttribute( "keyword" ) +": "+ name
			Else
				key = Empty
			End If
			renamed_key = Empty

			If not IsEmpty( key ) Then
			If not old_sections.Exists( key ) Then
				If not IsEmpty( renames_tag ) Then
					If not renames_tag.selectSingleNode( "./Rename[@new='"+ name +"']" ) is Nothing Then
						Set old_name_tags = renames_tag.selectNodes( "./Rename[@new='"+ name +"']/@old" )
						For Each  old_name_tag  In  old_name_tags
							old_name = old_name_tag.nodeValue
							renamed_key = tag_in_new.getAttribute( "keyword" ) +": "+ old_name
							If old_sections.Exists( renamed_key ) Then
								renamed_list( old_name ) = name
								key = renamed_key
								Exit For
							End If
						Next
					End If
				End If
			End If
			If old_sections.Exists( key ) Then
				Set tag_in_old = old_sections( key )(0)
				start_line = CInt2( tag_in_old.getAttribute( "start_line" ) )
				end_line   = CInt2( tag_in_old.getAttribute( "end_line" ) )
				writing_line_num = Empty

				Set file_tag = tag_in_old.parentNode
				Set reading_file = OpenForRead( file_tag.getAttribute( "_full_path" ) )
				Do Until  reading_file.AtEndOfStream
					line = reading_file.ReadLine()
					If reading_file.Line - 1 >= start_line Then
						If reading_file.Line - 1 = start_line Then _
							writing_line_num = writing_file.Line

						writing_file.WriteLine  line
					End If

					If reading_file.Line - 1 >= end_line Then _
						Exit Do
				Loop
				reading_file = Empty

				out_step_path = GetStepPath( file_tag.getAttribute( "_full_path" ), old_folder_path )


				old_key = file_tag.getAttribute( "_full_path" ) + _
					"("+ CStr( start_line ) +")-("+ CStr( end_line ) +")"
				If step_path <> out_step_path Then
					Set moved_list( old_key ) = new_NameOnlyClass( _
						out_path + "("+ CStr( writing_line_num ) +")::"+ key,  Empty )
				Else
					If moved_list.Exists( old_key ) Then _
						moved_list.Remove  old_key
				End If
			Else
				key2 = "(ERROR NotFoundInBefore """+ key +""")"
				If moved_list.Exists( key2 ) Then _
					Raise  1, "<ERROR msg=""シンボルが重複しています。"" symbol="""+ key +"""/>"
				moved_list.Add  key2,  new_NameOnlyClass( out_path +"::"+ key,  Empty )
			End If
			End If
		Next
		writing_file = Empty
		If IsEmpty( old_same_path ) Then
			copy_ren  writing_path,  out_path
		Else
			If not IsSameBinaryFile( writing_path,  old_same_path,  Empty ) Then
				copy_ren  writing_path,  out_path
			Else
				copy_ren  old_same_path,  out_path
			End If
		End If
		del  writing_path
	Next


	'// Write  "moved_list"
	Set file = OpenForWrite( GetFullPath( "__Moved_Sections.txt",  out_folder_path ), Empty )

	file.WriteLine  "<MakeCrossedOldSections>"
	file.WriteLine  "<NewFolderPath>"+ new_folder_path +"</NewFolderPath>"
	file.WriteLine  "<OldFolderPath>"+ old_folder_path +"</OldFolderPath>"
	file.WriteLine  ""

	If IsObject( rename_tag ) Then
		file.WriteLine  Replace( Replace( _
			renames_tag.xml, _
			"old=", " old=" ), "new=", " new=" )
		file.WriteLine  ""
	End If


	For Each  old_path  In  old_XML_roots.Keys
		Set moved_list( old_path +"(1)-" ) = new_NameOnlyClass( _
			"(ERROR NotRequestedFromNewOrAlreadyMatched ""(Header of same name file)"")::(Header of same name file)",  Empty )
	Next


	QuickSortDicByKey  moved_list
	current_old_path = Empty
	For Each  key  In  moved_list.Keys

		item = moved_list( key ).Name
		position = InStr( item, "::" )
		new_key = Mid( item,  position + 2 )
		names = new_key


		'// Set "new_tag", "renamed_name"
		new_tag = Empty
		renamed_name = Empty
		If StrCompHeadOf( key, "(ERROR NotFoundInBefore ", Empty ) = 0 Then
			path_in_new = ReplaceRootPath( Left( item,  position - 1 ), _
				out_folder_path,  new_folder_path,  True )
			Set new_XML_root = new_sections( path_in_new )

			position = InStr( new_key, ":" )
			a_keyword = Left( new_key, position - 1 )
			a_name = Trim( Mid( new_key, position + 1 ) )

			Set new_tag = new_XML_root.selectSingleNode( "./TextSection[@keyword='"+ a_keyword + _
				"' and @name='"+ a_name +"']" )
			If IsObject( rename_tag ) Then
				If new_tag is Nothing Then
					For Each  rename_tag  In  renames_tag.selectNodes( _
							"./Rename[@new='"+ a_name +"']" )
						renamed_name = rename_tag.getAttribute( "old" )
						Set new_tag = new_XML_root.selectSingleNode( _
							"./TextSection[@keyword='"+ a_keyword + _
							"' and @name='"+ renamed_name +"']" )
						If not new_tag is Nothing Then _
							Exit For

						names = names +"  or  "+ renamed_name
					Next
				End If
				If new_tag is Nothing Then
					For Each  rename_tag  In  renames_tag.selectNodes( _
							"./Rename[@old='"+ a_name +"']" )
						renamed_name = rename_tag.getAttribute( "new" )
						Set new_tag = new_XML_root.selectSingleNode( _
							"./TextSection[@keyword='"+ a_keyword + _
							"' and @name='"+ renamed_name +"']" )
						If not new_tag is Nothing Then _
							Exit For

						names = names +"  or  "+ renamed_name
					Next
				End If
			End If
			If new_tag is Nothing Then
				new_tag = Empty

				If not IsEmpty( renamed_name ) Then _
					names = new_key +"  or  "+ renamed_name
			End If
		End If


		position = InStr( item, "::" )
		file.WriteLine  "Keyword = "+ names
		file.WriteLine  "Before      = "+ key
		file.WriteLine  "CrossBefore = "+ Left( item,  position - 1 )
		If not IsEmpty( new_tag ) Then
			file.WriteLine  "New         = "+ path_in_new +"("+ _
				new_tag.getAttribute( "start_line" ) +")-("+ _
				new_tag.getAttribute( "end_line" ) +")"

			name = Trim( Mid( names, InStr( names, ":" ) + 1 ) )
			founds = grep( "-r """+ GrepKeyword( name ) +""" """+ old_folder_path +"""", Empty )
				'// as array of GrepFound
			If UBound( founds ) + 1 = 0 Then
				file.WriteLine  vbTab +"There is not the keyword in before."
			Else
				file.WriteLine  vbTab +"WARNING: There may be no Natural Docs tag in : "+ _
					founds(0).Path +"("+ CStr( founds(0).LineNum ) +")"
				file.WriteLine  vbTab + vbTab + founds(0).LineText
			End If
		End If

		file.WriteLine  ""
	Next
	file.WriteLine  "</MakeCrossedOldSections>"
	file = Empty

	del  GetFullPath( "__Moved_Sections.txt",  out_folder_path )
End Sub


 
'***********************************************************************
'* Function: MakeTextSectionIndexFile
'***********************************************************************
Sub  MakeTextSectionIndexFile( in_Path, in_TagTypeName, in_SectionTypeName, _
	ByVal in_BeforeRootFullPath, ByVal in_AfterRootFullPath )

	echo  ">MakeTextSectionIndexFile  """+ GetBasePath( in_Path ) +""",, """+ in_SectionTypeName +""""
	Set ec = new EchoOff

	If IsEmpty( in_BeforeRootFullPath ) Then  in_BeforeRootFullPath = g_sh.CurrentDirectory
	If IsEmpty( in_AfterRootFullPath  ) Then  in_AfterRootFullPath  = g_sh.CurrentDirectory
	in_BeforeRootFullPath = GetFullPath( in_BeforeRootFullPath, Empty )
	in_AfterRootFullPath  = GetFullPath( in_AfterRootFullPath,  Empty )


	setting_path = GetTempPath( "TXSC_*.ini" )
	Set setting_file = OpenForWrite( setting_path, g_VBS_Lib.Unicode )
	setting_file.WriteLine  "TagType = "+ in_TagTypeName
	setting_file.WriteLine  "SectionType = "+ in_SectionTypeName
	For Each  input_path  In ArrayFromWildcard( in_Path ).FullPaths
		output_path = ReplaceRootPath( input_path, in_BeforeRootFullPath, in_AfterRootFullPath, True ) + _
			".txsc"
		setting_file.WriteLine  "Path = "+ GetFullPath( input_path, Empty ) +", "+ output_path
		g_AppKey.CheckWritable  output_path, Empty
	Next
	setting_file = Empty

	r= RunProg( """"+ g_vbslib_ver_folder +"vbslib_helper.exe"" MakeTextSectionIndexFile """+ _
		setting_path +"""", "" )
	Assert  r = 0

	del  setting_path
End Sub


 
'***********************************************************************
'* Function: ListUpUsingTxMxKeywords
'***********************************************************************
Sub  ListUpUsingTxMxKeywords( in_TxScPaths, in_UseSymbols, in_CallerPaths, out_UsedSymbols )
	echo  ">ListUpUsingTxMxKeywords"
	Set ec = new EchoOff

	setting_path = GetTempPath( "TxMx_*.ini" )
	Set setting_file = OpenForWrite( setting_path, g_VBS_Lib.Unicode )
	For Each  use_symbol  In  in_UseSymbols
		setting_file.WriteLine  "use = "+ use_symbol
	Next
	For Each  caller_path  In  in_CallerPaths.FilePaths
		setting_file.WriteLine  "caller_path = "+ caller_path
	Next
	For Each  path  In  in_TxScPaths.FilePaths
		setting_file.WriteLine  "txsc_path = "+ path
	Next
	setting_file = Empty

	r= RunProg( """"+ g_vbslib_ver_folder +"vbslib_helper.exe"" ListUpUsingTxMxKeywords """+ _
		setting_path +"""", "" )
	Assert  r = 0


	out_path = AddLastOfFileName( setting_path, "_out" )
	Set file = OpenForRead( out_path )
	Set out_UsedSymbols = CreateObject( "Scripting.Dictionary" )
	a_used = Empty
	Do Until  file.AtEndOfStream
		Set line = ParseIniFileLine( file.ReadLine() )
		Select Case  line.Name 
			Case  "name"
				Set a_used = new TxMx_UsedNameClass
				a_used.Name = line.Value
				out_UsedSymbols.Add  line.Value,  a_used

			Case  "is_used_from_project"
				a_used.IsUsedFromProject = ( line.Value = "1" )

			Case  "caller_file_path"
				a_used.OneCallerFilePath = line.Value

			Case  "caller_name"
				a_used.OneCallerName = line.Value
		End Select
	Loop
	file = Empty
	del  setting_path
	del  out_path
End Sub


 
'***********************************************************************
'* Function: DoTextShrink
'***********************************************************************
Sub  DoTextShrink( in_TxMxFilePath, in_Option )
	echo  ">DoTextShrink  """+ in_TxMxFilePath +""""

	Set txmx = new TxMxClass
	txmx.ReadSettingTree  in_TxMxFilePath


	'// "MakeTextSectionIndexFile"
	For Each  source  In  txmx.AllSources.Items
		MakeTextSectionIndexFile  source.FilePath, "NaturalDocs", source.FileType, _
			source.BasePath, source.CachePath
	Next


	'// "ListUpUsingTxMxKeywords"
	Set txsc_paths = new PathDictionaryClass
	For Each  source  In  txmx.AllSources.Items
		Set txsc_paths( source.CachePath ) = txmx
	Next

	Set caller_paths = new PathDictionaryClass
	For Each  caller_path  In  txmx.Project.CallerFile.Items
		Set caller_paths( caller_path ) = txmx
	Next
	For Each  source  In  txmx.AllSources.Items
		caller_paths.AddRemove  source.FilePath
	Next

	ListUpUsingTxMxKeywords  txsc_paths,  txmx.Project.UseSymbols.Items,  caller_paths,  used_symbols
	Set  txmx.Project.UsedSymbols = used_symbols


	'// "MakeShrinkedSectionsFile"
	txmx.ReadTxScFile  txsc_paths
	txmx.Project.MakeShrinkedSectionsFile  txmx


	'// ...
	CreateFromTextSections  txmx.Project.SectionsXML_Path,  Empty, Empty, Empty, _
		get_ToolsLibConsts().DeleteIfNoSection
End Sub


 
'***********************************************************************
'* Function: GetTextShrinkWritables
'***********************************************************************
Function  GetTextShrinkWritables( in_TxMxFilePath, in_Option )
	Set writables_ = new ArrayClass
	Set txmx = new TxMxClass
	txmx.ReadSettingTree  in_TxMxFilePath
	For Each  a_txmx  In  txmx.AllSources.Items
		writables_.Add  a_txmx.ShrinkedPath
		writables_.Add  a_txmx.CachePath
	Next
	writables_.Add  txmx.Project.SectionsXML_Path
	GetTextShrinkWritables = writables_.Items
End Function


 
'*************************************************************************
'* Class: TxMxClass
'*
'* - .SettingTree as TreeA_Class of TxMx_SettingClass
'* - .AllSources as ArrayClass of TxMx_SourceClass
'* - .Project as TxMx_ProjectClass
'*   - .ProjectSources as ArrayClass of TxMx_SourceClass // A part of TxMxClass.AllSources
'*   - .CreateFiles as ArrayClass of TxMx_CreateFileClass
'* - .TextSectionsFromName as dictionary (name) of ArrayClass of TxSc_TextSectionClass
'* - .TextSectionsFromTxSc as dictionary (txsc_path) of ArrayClass of TxSc_TextSectionClass
'*   - .ParentFile as TxSc_FileClass
'* - .UsedNames as dictionary (name) of TxMx_UsedNameClass
'*************************************************************************
Class  TxMxClass
	Public  SettingTree   '// as TreeA_Class of TxMx_SettingClass
	Public  AllSources    '// as ArrayClass of TxMx_SourceClass
	Public  Project       '// as TxMx_ProjectClass
	Public  TextSectionsFromName  '// as dictionary (name) of ArrayClass of TxSc_TextSectionClass
	Public  TextSectionsFromTxSc  '// as dictionary (txsc_path) of ArrayClass of TxSc_TextSectionClass

	Private Sub  Class_Initialize()
		Set Me.SettingTree = new_TreeA_Class( new TxMx_SettingClass )
		Set Me.SettingTree.Item.TreeNode = Me.SettingTree.TreeNode
		Set Me.AllSources = new ArrayClass
	End Sub


 
'***********************************************************************
'* Function: TxMxClass::ReadSettingTree
'***********************************************************************
Sub  ReadSettingTree( in_TxMxFilePath )
	Set txmx = Me
	txmx.SettingTree.Item.EnumerateSettings  in_TxMxFilePath

	setting_folder_path = GetParentFullPath( in_TxMxFilePath )

	For Each  setting  In  txmx.SettingTree.ChildItems()

		base_folder = setting.BaseFolderPath
		Set variables = setting.GetVariables()
		ns = setting.NameSpace

		Set project_tag = setting.XML_Root.selectSingleNode( ".//"+ ns +":Project" )
		project = Empty
		If not project_tag is Nothing Then
			Set project = new TxMx_ProjectClass
			project.SettingPath = in_TxMxFilePath
			For Each  create_file  In project_tag.selectNodes( "./"+ ns +":CreateFile" )
				Set file = new TxMx_CreateFileClass
				file.FilePath = GetFullPath( variables( create_file.getAttribute( _
					"path" ) ), base_folder )
				file.FileType = variables( create_file.getAttribute( _
					"type" ) )
				project.CreateFiles.Add  file
			Next
			For Each  use_symbol  In project_tag.selectNodes( "./"+ ns +":UseSymbol" )
				project.UseSymbols.Add  use_symbol.selectSingleNode( "text()" ).NodeValue
			Next
			For Each  caller_file  In project_tag.selectNodes( "./"+ ns +":CallerFile" )
				project.CallerFile.Add  GetFullPath( variables( _
					caller_file.selectSingleNode( "text()" ).NodeValue ), _
					setting_folder_path )
			Next
			project.EnumerateSettings
			Set txmx.Project = project
		End If

		For Each  source_tag  In  setting.XML_Root.selectNodes( ".//"+ ns +":SourceFile" )
			Set source = new TxMx_SourceClass
			source.FilePath = GetFullPath( variables( source_tag.getAttribute( _
				"path" ) ), base_folder )
			source.FileType = variables( source_tag.getAttribute( _
				"type" ) )

			source.Priority = variables( source_tag.getAttribute( _
				"priority" ) )
			If IsEmpty( source.Priority ) Then _
				source.Priority = "1000"

			source.BasePath = GetFullPath( variables( source_tag.getAttribute( _
				"base_path" ) ), base_folder )
			If IsEmpty( source.BasePath ) Then _
				source.BasePath = setting_folder_path

			source.CachePath = GetFullPath( variables( source_tag.getAttribute( _
				"cache_path" ) ), base_folder )
			If IsEmpty( source.CachePath ) Then _
				source.CachePath = source.BasePath +"\_txsc"

			source.ShrinkedPath = GetFullPath( variables( source_tag.getAttribute( _
				"shrinked_path" ) ), base_folder )
			If IsEmpty( source.ShrinkedPath ) Then _
				source.ShrinkedPath = source.BasePath

			source.SettingPath = setting.SettingPath
			txmx.AllSources.Add  source
			If not IsEmpty( project ) Then
				project.ProjectSources.Add  source
			End If
		Next
	Next
End Sub


 
'***********************************************************************
'* Function: TxMxClass::ReadTxScFile
'***********************************************************************
Sub  ReadTxScFile( in_TxScPaths )
	Const  NotCaseSensitive = 1

	Set Me.TextSectionsFromName = CreateObject( "Scripting.Dictionary" )

	Set Me.TextSectionsFromTxSc = CreateObject( "Scripting.Dictionary" )
	Me.TextSectionsFromTxSc.CompareMode = NotCaseSensitive

	For Each  txsc_path  In in_TxScPaths.FullPaths
		Set root = LoadXML( txsc_path, Empty )
		txsc_base_path = GetParentFullPath( txsc_path )
		Set file_tag = root
		Set file = new TxSc_FileClass
		file.FilePath = GetFullPath( file_tag.getAttribute( "path" ), txsc_base_path )
		file.FileType = file_tag.getAttribute( "type" )

		If not Me.TextSectionsFromTxSc.Exists( txsc_path ) Then
			Set Me.TextSectionsFromTxSc( txsc_path ) = new ArrayClass
		End If

		For Each  section_tag  In file_tag.SelectNodes( "TextSection" )
			name = section_tag.getAttribute( "name" )
			Set section = new TxSc_TextSectionClass
			section.Keyword   = section_tag.getAttribute( "keyword" )
			section.Name      = name
			section.StartLine = section_tag.getAttribute( "start_line" )
			section.EndLine   = section_tag.getAttribute( "end_line" )
			Set section.ParentFile = file

			If name <> "" Then
				period_index = InStr( name, "." )
				If period_index = 0 Then
					name2 = name
				Else
					name2 = Left( name, period_index - 1 )
				End If

				If not Me.TextSectionsFromName.Exists( name2 ) Then
					Set Me.TextSectionsFromName( name2 ) = new ArrayClass
				End If
				Me.TextSectionsFromName( name2 ).Add  section
			End If
			Me.TextSectionsFromTxSc( txsc_path ).Add  section
		Next
	Next
End Sub


 
End Class


 
'***********************************************************************
'* Class: TxMx_SettingClass
'***********************************************************************
Class  TxMx_SettingClass
	Public  SettingPath
	Public  XML_Root
	Public  BaseFolderPath
	Public  Variables
	Public  NameSpace

	Public  TreeNode

	Sub  EnumerateSettings( in_TxMxFilePath )  '// Load "*.txmx.xml" file
		Me.SettingPath = in_TxMxFilePath
		Set Me.XML_Root = LoadXML( Me.SettingPath, g_VBS_Lib.InheritSuperClass )
		Me.BaseFolderPath = GetParentFullPath( Me.SettingPath )
		Set Me.Variables = new_LazyDictionaryClass( Me.XML_Root )
		Set name_space_tag = Me.XML_Root.selectSingleNode( _
			"..//*[@xmlns:*='http://sage-p.com/TextSectionMixer/2015']" )
		Me.NameSpace = name_space_tag.prefix

		For Each  library_tag  In  Me.XML_Root.selectNodes( ".//"+ Me.NameSpace +":Library" )
			Set vars = Me.GetVariables()

			Set child_setting = new TxMx_SettingClass
			Set child_setting.TreeNode = Me.TreeNode.AddNewNode( child_setting )

			child_path = GetFullPath( vars( _
				library_tag.getAttribute( "path" ) ), Me.BaseFolderPath )
			child_setting.EnumerateSettings  child_path
		Next
	End Sub

	Function  GetVariables()
		Set vars = new LazyDictionaryClass
		items = Me.TreeNode.ChildItems()
		For Each  a_item  In  items
			vars.AddDictionary  a_item.Variables
		Next
		Set GetVariables = vars
	End Function
End Class


 
'***********************************************************************
'* Class: TxMx_SourceClass
'***********************************************************************
Class  TxMx_SourceClass
	Public  FilePath  '// as string with "SubFolderSign"
	Public  FileType
	Public  Priority
	Public  BasePath
	Public  CachePath
	Public  ShrinkedPath
	Public  SettingPath

	Function  GetShrinkedPath( in_FilePath )
		GetShrinkedPath = ReplaceRootPath( in_FilePath,  Me.BasePath,  Me.ShrinkedPath, True )
	End Function
	Function  GetTxScPath( in_FilePath )
		GetTxScPath = ReplaceRootPath( in_FilePath,  Me.BasePath,  Me.CachePath, True ) +".txsc"
	End Function
End Class


 
'***********************************************************************
'* Class: TxMx_UsedNameClass
'***********************************************************************
Class  TxMx_UsedNameClass
	Public  Name
	Public  IsUsedFromProject
	Public  OneCallerFilePath
	Public  OneCallerName


	Function  Get_XML_Attributes()
		attributes = ""
		If not IsEmpty( Me.IsUsedFromProject ) Then
			attributes = attributes +"""  is_used_from_project="""
			If Me.IsUsedFromProject Then
				attributes = attributes +"yes"
			Else
				attributes = attributes +"no"
			End If
		End If
		If not IsEmpty( Me.OneCallerFilePath ) Then
			attributes = attributes +"""  one_caller_file_path="""+ _
				Me.OneCallerFilePath
		End If
		If not IsEmpty( Me.OneCallerName ) Then
			attributes = attributes +"""  one_caller_name="""+ _
				Me.OneCallerName
		End If
		Get_XML_Attributes = attributes
	End Function
End Class


 
'***********************************************************************
'* Class: TxMx_ProjectClass
'***********************************************************************
Class  TxMx_ProjectClass
	Public  SettingPath
	Public  ProjectSources  '// as ArrayClass of TxMx_SourceClass
	Public  CreateFiles     '// as ArrayClass of TxMx_CreateFileClass
	Public  UseSymbols      '// as ArrayClass of string
	Public  UsedSymbols     '// as ArrayClass of string
	Public  CallerFile      '// as ArrayClass of string
	Public  SectionsXML_Path

	Private Sub  Class_Initialize()
		Set Me.ProjectSources = new ArrayClass
		Set Me.CreateFiles = new ArrayClass
		Set Me.UseSymbols = new ArrayClass
		Set Me.CallerFile = new ArrayClass
	End Sub

	Sub  EnumerateSettings()
		Me.SectionsXML_Path = GetFullPath( "_setup_generating\Sections.xml", _
			GetParentFullPath( Me.SettingPath ) )
	End Sub


 
'***********************************************************************
'* Function: TxMx_ProjectClass::MakeMixedSectionsFile
'***********************************************************************
Sub  MakeMixedSectionsFile( txmx )
	Set project = Me

	'// Make "Sections.xml" file
	sections_base_path = GetParentFullPath( project.SectionsXML_Path )
	Set file = OpenForWrite( project.SectionsXML_Path, Empty )
	file.WriteLine  "<MixedTexts>"
	file.WriteLine  ""
	For Each  create_file  In project.CreateFiles.Items
		file.WriteLine  "<CreateFile  path="""+ create_file.FilePath + _
			"""  mixed_text_href="""+ create_file.FileType +"""/>"
	Next

	For Each  create_file  In project.CreateFiles.Items
		file.WriteLine  ""
		file.WriteLine  "<!-- ============================================================= -->"
		file.WriteLine  "<MixedText  id="""+ create_file.FileType +""">"

		For Each  a_used  In  project.UsedSymbols.Items
			Set sections = txmx.TextSectionsFromName( a_used.Name )

			For Each  section  In  sections.Items
				If section.ParentFile.FileType = create_file.FileType Then

					file.WriteLine  "<TextSection  path="""+ _
						GetStepPath( section.ParentFile.FilePath, sections_base_path ) + _
						"""  name="""+ section.Name + _
						"""  start_line="""+ section.StartLine + _
						"""  end_line="""+ section.EndLine + _
						a_used.Get_XML_Attributes() + _
						"""/>"
				End If
			Next
		Next

		file.WriteLine  "</MixedText>"
	Next
	file.WriteLine  ""
	file.WriteLine  "</MixedTexts>"
End Sub


 
'***********************************************************************
'* Function: TxMx_ProjectClass::MakeShrinkedSectionsFile
'***********************************************************************
Sub  MakeShrinkedSectionsFile( txmx )
	Set project = Me

	'// Make "Sections.xml" file
	project.SectionsXML_Path = GetFullPath( "_setup_generating\Sections.xml", _
		GetParentFullPath( project.SettingPath ) )
	sections_base_path = GetParentFullPath( project.SectionsXML_Path )
	Set file = OpenForWrite( project.SectionsXML_Path, Empty )
	file.WriteLine  "<MixedTexts>"
	file.WriteLine  ""

	Set source_paths = new PathDictionaryClass
	For Each  source  In  project.ProjectSources.Items
		Set source_paths( source.FilePath ) = source
	Next

	file_num = 1
	For Each  source_path  In source_paths.FullPaths
		Set source = source_paths( source_path )

		file.WriteLine  "<CreateFile  path="""+ source.GetShrinkedPath( source_path ) + _
			"""  mixed_text_href=""#"+ CStr( file_num ) +"""/>"
		file_num = file_num + 1
	Next

	file_num = 1
	For Each  source_path  In source_paths.FullPaths
		Set source = source_paths( source_path )

		file.WriteLine  ""
		file.WriteLine  "<!-- ============================================================= -->"
		file.WriteLine  "<MixedText  id="""+ CStr( file_num ) +""">"

		Set sections = txmx.TextSectionsFromTxSc( source.GetTxScPath( source_path ) )

		is_used = False
		For Each  section  In  sections.Items
			If project.UsedSymbols.Exists( section.Name ) Then
				is_used = True
				Exit For
			End If
		Next

		If is_used Then
			section_num = 0
			For Each  section  In  sections.Items
				section_num = section_num + 1

				If section_num = 1  and  CLng( section.StartLine ) >= 2 Then
					file.WriteLine  "<TextSection  path="""+ _
						GetStepPath( section.ParentFile.FilePath, sections_base_path ) + _
						"""  top_of_file=""yes"+ _
						"""  start_line=""1"+ _
						"""  end_line="""+ CStr( CLng( section.StartLine ) - 1 ) + _
						"""/>"
				End If

				period_index = InStr( section.Name, "." )
				If period_index = 0 Then
					name2 = section.Name
				Else
					name2 = Left( section.Name, period_index - 1 )
				End If


				If project.UsedSymbols.Exists( name2 ) Then
					is_output = True
					is_used = True
				ElseIf _
						StrComp( section.Keyword, "File", 1 ) = 0  or _
						StrComp( section.Keyword, "Section", 1 ) = 0  or _
						StrComp( section.Keyword, "End of File", 1 ) = 0 Then

					is_output = True
					is_used = False
				Else
					is_output = False
					is_used = False
				End If

				If is_output Then
					If is_used Then
						Set a_used = project.UsedSymbols( name2 )
						attributes = a_used.Get_XML_Attributes()
					Else
						attributes = ""
					End If

					file.WriteLine  "<TextSection  path="""+ _
						GetStepPath( section.ParentFile.FilePath, sections_base_path ) + _
						"""  keyword="""+ section.Keyword + _
						"""  name="""+ section.Name + _
						"""  start_line="""+ section.StartLine + _
						"""  end_line="""+ section.EndLine + _
						attributes + _
						"""/>"
				End If
			Next
		End If

		file.WriteLine  "</MixedText>"
		file_num = file_num + 1
	Next
	file.WriteLine  ""
	file.WriteLine  "</MixedTexts>"
End Sub


 
End Class


 
'***********************************************************************
'* Class: TxMx_CreateFileClass
'***********************************************************************
Class  TxMx_CreateFileClass
	Public  FilePath  '// as string
	Public  FileType  '// as string
End Class


 
'***********************************************************************
'* Class: TxMx_KeywordClass
'***********************************************************************
Class  TxMx_KeywordClass
	Public  Keyword  '// as string
	Public  Paths    '// as ArrayClass of string
End Class


 
'***********************************************************************
'* Class: TxSc_FileClass
'***********************************************************************
Class  TxSc_FileClass
	Public  FilePath
	Public  FileType
End Class


 
'***********************************************************************
'* Class: TxSc_TextSectionClass
'***********************************************************************
Class  TxSc_TextSectionClass
	Public  Keyword
	Public  Name
	Public  StartLine
	Public  EndLine

	Public  ParentFile  '// as TxSc_FileClass
End Class


 
'***********************************************************************
'* Function: CheckFolderMD5List
'***********************************************************************
Sub  CheckFolderMD5List( in_TargetFolderPath,  in_CorrectMD5ListFilePath,  in_Flags )
	scaned_MD5_list_path = GetTempPath( "NowCheckingFolder_*.txt" )
	Set tc = get_ToolsLibConsts()
	Set c = g_VBS_Lib


	MakeFolderMD5List_Sub  "CheckFolderMD5List", _
		in_TargetFolderPath,  scaned_MD5_list_path,  in_CorrectMD5ListFilePath,  Empty,  in_Flags


	'// Call "IsSameMD5List"
	Set ec = new EchoOff
'//	OpenForReplace( scaned_MD5_list_path, Empty ).Replace  "%", "%%"
	If not IsSameMD5List( in_CorrectMD5ListFilePath,  scaned_MD5_list_path,  c.EchoV_NotSame ) Then _
		AssertFC  scaned_MD5_list_path,  in_CorrectMD5ListFilePath
	del  scaned_MD5_list_path


	'// Call "SetDateLastModified"
	If IsBitSet( in_Flags,  c.TimeStamp ) Then

		Set file = OpenForRead( in_CorrectMD5ListFilePath )
		line = file.ReadLine()

		If Mid( line, 5, 1 ) = "-" Then
			length_of_time_stamp = InStr( line, " " ) - 1
			file = Empty
			column_of_path = GetColumnOfPathInFolderMD5List( in_CorrectMD5ListFilePath )
			Const  hash_length = 32
			column_of_hash = column_of_path - ( hash_length + 1 )
			Set files = CreateObject( "Scripting.Dictionary" )

			Set file = OpenForRead( in_CorrectMD5ListFilePath )
			Do Until  file.AtEndOfStream
				line = file.ReadLine()
				path = Mid( line,  column_of_path )
				time_stamp = Left( line,  length_of_time_stamp )
				hash_value = Mid( line,  column_of_hash,  hash_length )

				If hash_value <> tc.EmptyFolderMD5 Then _
					files( path ) = W3CDTF( time_stamp )
			Loop
			Set ds = new CurDirStack
			cd  in_TargetFolderPath

			SetDateLastModified  files
		End If
	End If
End Sub


 
'***********************************************************************
'* Function: MakeFolderMD5List
'***********************************************************************
Sub  MakeFolderMD5List( in_TargetFolderPath,  in_MD5ListFilePath,  in_Flags )
	MakeFolderMD5List_Sub  "MakeFolderMD5List ", _
		in_TargetFolderPath,  in_MD5ListFilePath,  in_MD5ListFilePath,  Empty,  in_Flags
End Sub


 
'***********************************************************************
'* Function: MakeFolderMD5List_Sub
'***********************************************************************
Sub  MakeFolderMD5List_Sub( in_FunctionName, _
		ByVal in_TargetFolderPath,  in_MD5ListFilePath,  in_MD5ListFileLabel, _
		in_OldMD5ListFilePath,  in_Flags )

	Set c = g_VBS_Lib
	Set tc = get_ToolsLibConsts()
	Set ds = new CurDirStack
	is_sorted = IsBitNotSet( in_Flags,  tc.FasterButNotSorted )
	is_time_stamp = IsBitSet( in_Flags,  tc.TimeStamp )
	is_full_set = IsBitSet( in_Flags,  tc.IncludeFullSet )
	Set fin = new FinObj : fin.SetFunc "MakeFolderMD5List_Sub_Finally"
	fin.SetVar  "in_MD5ListFilePath",  GetFullPath( in_MD5ListFilePath, Empty ) 
	time_stamp = ""
	sort_setting_back_up = g_Vers("ExpandWildcard_Sort")
	g_Vers("ExpandWildcard_Sort") = is_sorted
	is_multi_folder = IsObject( in_TargetFolderPath )  '// Is dictionary
	Const  hash_length = 32
	Const  time_stamp_length = 25
	If IsEmpty( in_TargetFolderPath ) Then _
		in_TargetFolderPath = GetParentFullPath( in_MD5ListFileLabel )
	If not IsEmpty( in_OldMD5ListFilePath ) Then
		column = GetColumnOfPathInFolderMD5List( in_OldMD5ListFilePath )
		is_exist_time_stamp = ( column > hash_length + 2 )
		If is_exist_time_stamp Then
			Set old_files = ReadPathsInMD5List( in_OldMD5ListFilePath,  column )
		End If
	End If


	'// Set "base_step_path"
	If IsBitSet( in_Flags,  tc.BasePathIsList ) Then
		base_step_path = GetStepPath( GetFullPath( in_TargetFolderPath,  Empty ), _
			GetParentFullPath( in_MD5ListFileLabel ) )
		base_step_path = GetPathWithSeparator( base_step_path )
	Else
		base_step_path = ""
	End If


	'// Set "target_folders"
	If not  is_multi_folder Then
		echo  ">"+ in_FunctionName +" """+ in_TargetFolderPath +""", """+ in_MD5ListFileLabel +""""
		Set ec = new EchoOff
		Set target_folders = Dict(Array( "",  in_TargetFolderPath ))
	Else
		echo  ">"+ in_FunctionName +" """+ in_MD5ListFileLabel +""""
		Set target_folders = in_TargetFolderPath
	End If


	'// Example:
	'//    C:\xxxxxxxxxxxxxxx\TargetFolder\Folder\File.txt
	'//    ^target_full_path  ^target_path ^step_path_position

	path_of_MD5List = GetFullPath( in_MD5ListFileLabel, Empty )

	Set out_file = OpenForWrite( in_MD5ListFilePath, c.Unicode )

	For Each  key  In  target_folders.Keys
		target_path = target_folders( key )

		If is_multi_folder Then
			ec = Empty
			echo  "  """+ key +""" : """+ target_path +""""
			Set ec = new EchoOff
			key = GetPathWithSeparator( key )
		Else
			key = base_step_path
		End If
		target_full_path = GetPathWithSeparator( GetFullPath( target_path,  Empty ) )
		step_path_position = Len( target_full_path ) + 1


		pushd  target_path


		'// Call "WriteLine"
		If is_sorted Then
			Assert  not is_full_set
			For Each  full_path  In  EnumerateToLeafPathDictionary( "." ).Keys
				If full_path <> path_of_MD5List Then
					step_path = Mid( full_path,  step_path_position )
					If g_fs.FileExists( step_path ) Then
						If is_time_stamp Then _
							time_stamp = W3CDTF( g_fs.GetFile( step_path ).DateLastModified ) +" "

						If not IsEmpty( old_files ) Then
							If old_files.Exists( step_path ) Then
								line = old_files( step_path )
								old_time_stamp = Left( line,  time_stamp_length )
								If time_stamp = old_time_stamp Then
									out_file.WriteLine  line
								Else
									line = Empty
								End If
							End If
						End If
						If IsEmpty( line ) Then

							out_file.WriteLine  time_stamp + GetHashOfFile( step_path, "MD5" ) +" "+ _
								key + step_path
						End If
					Else
						If is_time_stamp Then _
							time_stamp = tc.EmptyFolderTimeStamp +" "

						out_file.WriteLine  time_stamp + tc.EmptyFolderMD5 +" "+ _
							key + step_path
					End If
				End If
			Next
		Else
			If not is_full_set Then

				EnumFolderObjectDic   ".",  Empty,  folders  '// Set "folders"

			Else
				Set full_sets = CreateObject( "Scripting.Dictionary" )
				ReDim  folders_(0)
				Set folders_(0) = g_fs.GetFolder( "." )
				i_set = 1 : i_get = 0
				While  i_get <= UBound( folders_ )

					full_set_folder_path = folders_( i_get ).Path
					If g_fs.FileExists( full_set_folder_path +"\_FullSet.txt" ) Then

						full_sets( full_set_folder_path ) = Empty
						folders_( i_get ) = Empty
					Else
						n = folders_( i_get ).SubFolders.Count
						ReDim Preserve  folders_( UBound( folders_ ) + n )

						For Each f  In  folders_( i_get ).SubFolders
							Set folders_( i_set ) = f
							i_set = i_set + 1
						Next
					End If
					i_get = i_get + 1
				WEnd
				Set folders = new_ArrayClass( folders_ )
				folders.RemoveEmpty


				For Each  full_set_folder_path  In  full_sets.Keys
					path_position = GetColumnOfPathInFolderMD5List( full_set_folder_path +"\_FullSet.txt" )
					hash_position = path_position - ( hash_length + 1 )
					If is_time_stamp Then
						Assert  hash_position >= 2
						is_cut = False
					Else
						is_cut = ( hash_position >= 2 )
					End If
					If is_cut Then
						hash_position = time_stamp_length + 2
					Else
						hash_position = 1
					End If

					Set file = OpenForRead( full_set_folder_path +"\_FullSet.txt" )
					Do Until  file.AtEndOfStream
						line = file.ReadLine()

						out_file.WriteLine  Mid( line,  hash_position,  hash_length ) +" "+ _
							key + GetPathWithSeparator( Mid( full_set_folder_path,  step_path_position ) ) + _
								Mid( line,  path_position )
					Loop
					line = Empty
					file = Empty
				Next
			End If


			For Each  folder  In  folders.Items  '// folder as Folder Object
				For Each  file  In  folder.Files '// file as File Object
					full_path = file.Path
					If full_path <> path_of_MD5List Then
						step_path = Mid( full_path,  step_path_position )
						If is_time_stamp Then _
							time_stamp = W3CDTF( g_fs.GetFile( step_path ).DateLastModified ) +" "

						If not IsEmpty( old_files ) Then
							If old_files.Exists( step_path ) Then
								line = old_files( step_path )
								old_time_stamp = Left( line,  time_stamp_length + 1 )
								If time_stamp = old_time_stamp Then
									out_file.WriteLine  line
								Else
									line = Empty
								End If
							End If
						End If
						If IsEmpty( line ) Then

							out_file.WriteLine  time_stamp + GetHashOfFile( step_path, "MD5" ) +" "+ _
								key + step_path
						End If
					End If
				Next
				If folder.Files.Count = 0 Then
					If folder.SubFolders.Count = 0 Then
						step_path = Mid( folder.Path,  step_path_position )
						If is_time_stamp Then _
							time_stamp = tc.EmptyFolderTimeStamp +" "

						out_file.WriteLine  time_stamp + tc.EmptyFolderMD5 +" "+ _
							key + step_path
					End If
				End If
			Next
		End If
		popd
	Next

	out_file = Empty


	'// Change to ascii file, if ascii
	If GetLineNumsExistNotEnglighChar( in_MD5ListFilePath, Empty ) = 0 Then
		text = ReadFile( in_MD5ListFilePath )
		CreateFile  in_MD5ListFilePath, text
	End If

	g_Vers("ExpandWildcard_Sort") = sort_setting_back_up
	fin.SetVar  "in_MD5ListFilePath",  Empty
End Sub
 Sub  MakeFolderMD5List_Sub_Finally( in_Vars )
	en = Err.Number : ed = Err.Description : On Error Resume Next  '// This clears error

	in_MD5ListFilePath = in_Vars.Item("in_MD5ListFilePath")
	If not IsEmpty( in_MD5ListFilePath ) Then
		del  in_MD5ListFilePath
	End If

	ErrorCheckInTerminate  en : On Error GoTo 0 : If en <> 0 Then  Err.Raise en,,ed  '// This sets en again
End Sub


 
'***********************************************************************
'* Function: UpdateFolderMD5List_VBS
'***********************************************************************
Sub  UpdateFolderMD5List_VBS( in_TargetFolderPath,  in_InputMD5ListFilePath,  in_OutputMD5ListFilePath,  in_Flags )
	Confirm_VBS_Lib_ForFastUser

	MakeFolderMD5List_Sub  "UpdateFolderMD5List ", _
		in_TargetFolderPath,  in_OutputMD5ListFilePath,  in_OutputMD5ListFilePath,  in_InputMD5ListFilePath, _
		in_Flags + get_ToolsLibConsts().TimeStamp
End Sub


 
'***********************************************************************
'* Function: UpdateFolderMD5List
'***********************************************************************
Sub  UpdateFolderMD5List( in_TargetFolderPath,  in_InputMD5ListFilePath,  ByVal  in_OutputMD5ListFilePath,  in_Flags )
	If IsThereTimeStampInFolderMD5List( in_InputMD5ListFilePath ) Then
		Confirm_VBS_Lib_ForFastUser

		If in_OutputMD5ListFilePath = "" Then
			in_OutputMD5ListFilePath = in_InputMD5ListFilePath +".updating"
			copy_ren  in_InputMD5ListFilePath,  in_OutputMD5ListFilePath
		End If

		If IsEmpty( g_UpdateFolderMD5List_exe ) Then
			Set g_UpdateFolderMD5List_exe = CompileCSharp( g_vbslib_folder +"cslib\UpdateFolderMD5List.cs" )
		End If

		r= g_UpdateFolderMD5List_exe.Run( """"+ in_TargetFolderPath +""" """+ _
			in_InputMD5ListFilePath +""" """+ in_OutputMD5ListFilePath +"""",  "" )
		Assert  r= 0
	Else
		UpdateFolderMD5List_VBS  _
			in_TargetFolderPath,  in_InputMD5ListFilePath,  in_OutputMD5ListFilePath,  in_Flags
	End If
End Sub

Dim  g_UpdateFolderMD5List_exe

 
'***********************************************************************
'* Function: IsSameMD5List
'***********************************************************************
Function  IsSameMD5List( in_MD5ListFilePathA,  in_MD5ListFilePathB,  in_Option )
	Const  hash_length = 32
	Set c = g_VBS_Lib
	Assert2Exist  in_MD5ListFilePathA,  in_MD5ListFilePathB
	column_A = GetColumnOfPathInFolderMD5List( in_MD5ListFilePathA ) - hash_length - 1
	column_B = GetColumnOfPathInFolderMD5List( in_MD5ListFilePathB ) - hash_length - 1
	Set file_A = OpenForRead( in_MD5ListFilePathA )
	Set file_B = OpenForRead( in_MD5ListFilePathB )
	Do Until  file_A.AtEndOfStream
		If file_B.AtEndOfStream Then
			IsSameMD5List = False
			If IsBitSet( in_Option,  c.EchoV_NotSame ) Then _
				echo_v  "Few file_B"
			Exit Function
		End If

		line_A = Mid( file_A.ReadLine(),  column_A )
		line_B = Mid( file_B.ReadLine(),  column_B )

		If line_A <> line_B Then
			If NOT IsBitSet( in_Option, 2 ) Then
				path_A = GetTempPath( "IsSameMD5ListA.txt" )
				SortFolderMD5List  in_MD5ListFilePathA,  path_A,  Empty
				path_B = GetTempPath( "IsSameMD5ListB.txt" )
				SortFolderMD5List  in_MD5ListFilePathB,  path_B,  Empty

				IsSameMD5List = IsSameMD5List( path_A,  path_B,  2 )
				If not IsSameMD5List Then
					If IsBitSet( in_Option,  c.EchoV_NotSame ) Then
						echo_v  ""
						echo_v  path_A
						echo_v  "    "+ line_A
						echo_v  path_B
						echo_v  "    "+ line_B
					End If
				End If
			Else
				IsSameMD5List = False
			End If
			Exit Function
		End If
	Loop
	IsSameMD5List = file_B.AtEndOfStream
	If not IsSameMD5List Then _
		If IsBitSet( in_Option,  c.EchoV_NotSame ) Then _
			echo_v  "Few file_A"
End Function


 
'***********************************************************************
'* Function: SortFolderMD5List
'***********************************************************************
Sub  SortFolderMD5List( in_InputMD5ListFilePath,  in_OutputMD5ListFilePath,  in_EmptyOption )
	Assert  not IsEmpty( in_OutputMD5ListFilePath )

	column = GetColumnOfPathInFolderMD5List( in_InputMD5ListFilePath )
	Set paths = new ArrayClass

	Set file = OpenForRead( in_InputMD5ListFilePath )
	Do Until file.AtEndOfStream
		SplitLineAndCRLF  file.ReadLine(), line, cr_lf  '// Set "line", "cr_lf"
		If Trim( line ) <> "" Then

			Set element = new NameOnlyClass
			element.Name = Mid( line, column )
			element.Delegate = line
			paths.Add  element
		End If
	Loop
	file = Empty


	QuickSort  paths,  0,  paths.UBound_,  GetRef("PathNameCompare"),  Empty


	Set file = OpenForWrite( in_OutputMD5ListFilePath,  AnalyzeCharacterCodeSet( in_InputMD5ListFilePath ) )
	For Each  element  In  paths.Items
		file.WriteLine  element.Delegate
	Next
	file = Empty
End Sub


 
'***********************************************************************
'* Function: CopyDiffByMD5List
'***********************************************************************
Sub  CopyDiffByMD5List( in_SourceFolderPath,  in_DestinationFolderPath, _
		in_SourceMD5ListFilePath,  in_DestinationMD5ListFilePath,  in_Option )

	Confirm_VBS_Lib_ForFastUser

	echo  ">CopyDiffByMD5List  """+ in_SourceFolderPath +""", """+ in_DestinationFolderPath +""""
	Set ec = new EchoOff
	Set c = g_VBS_Lib
	Set tc = get_ToolsLibConsts()

	If not exist( in_SourceMD5ListFilePath ) Then
		Set tc = get_ToolsLibConsts()
		is_sort_back_up = g_Vers("ExpandWildcard_Sort")
		If IsBitSet( in_Option,  tc.FasterButNotSorted ) Then _
			g_Vers("ExpandWildcard_Sort") = False

		UpdateFolderMD5List  in_SourceFolderPath, _
			in_DestinationMD5ListFilePath,  in_SourceMD5ListFilePath,  in_Option
		g_Vers("ExpandWildcard_Sort") = is_sort_back_up
	End If

	Const  hash_length = 32
	source_column_of_path      = GetColumnOfPathInFolderMD5List( in_SourceMD5ListFilePath )
	destination_column_of_path = GetColumnOfPathInFolderMD5List( in_DestinationMD5ListFilePath )
	source_column_of_hash_value      = source_column_of_path      - ( hash_length + 1 )
	destination_column_of_hash_value = destination_column_of_path - ( hash_length + 1 )
	Set source_paths      = ReadPathsInMD5List( in_SourceMD5ListFilePath,  source_column_of_path )
	Set destination_paths = ReadPathsInMD5List( in_DestinationMD5ListFilePath,  destination_column_of_path )
	source_folder_path      = GetPathWithSeparator( in_SourceFolderPath )
	destination_folder_path = GetPathWithSeparator( in_DestinationFolderPath )
	destination_root_index = Len( GetPathWithSeparator( GetFullPath( in_DestinationFolderPath, Empty ) ) ) + 1
	Set c = g_VBS_Lib
	Set tc = get_ToolsLibConsts()

	If IsBitSet( in_Option,  c.AfterDelete )  and _
			exist( in_DestinationFolderPath ) Then

		For Each  relative_path  In  destination_paths.Keys
			If not source_paths.Exists( relative_path ) Then

				del  destination_folder_path + relative_path
			End If
		Next

		'// Delete empty folder
		EnumFolderObject  in_DestinationFolderPath,  destination_folders  '// Set "destination_folders"
		Set parents = CreateObject( "Scripting.Dictionary" )
		index = 0
		Do While  index <= UBound( destination_folders )
			Set a_folder = destination_folders( index )

			If a_folder.Files.Count + a_folder.SubFolders.Count = 0 Then
				a_folder_full_path = a_folder.Path
				relative_path = Mid( a_folder_full_path,  destination_root_index )
				If not destination_paths.Exists( relative_path ) Then

					del  a_folder_full_path

					parent_full_path = g_fs.GetParentFolderName( a_folder_full_path )
					If not parents.Exists( parent_full_path ) Then
						ReDim Preserve  destination_folders( UBound( destination_folders ) + 1 )
						Set destination_folders( UBound( destination_folders ) ) = _
							g_fs.GetFolder( parent_full_path )
					End If
				End If
			End If
			index = index + 1
		Loop
	End If

	For Each  relative_path  In  source_paths.Keys
		If destination_paths.Exists( relative_path ) Then
			source_hash_value = Mid( _
				source_paths( relative_path ), _
				source_column_of_hash_value, _
				hash_length )
			destination_hash_value = Mid( _
				destination_paths( relative_path ), _
				destination_column_of_hash_value, _
				hash_length )

			If source_hash_value <> destination_hash_value Then

				copy_ren  source_folder_path + relative_path,  destination_folder_path + relative_path
			End If
		Else
			copy_ren  source_folder_path + relative_path,  destination_folder_path + relative_path
		End If
	Next
End Sub


 
'***********************************************************************
'* Function: CopyDiffByMD5Lists
'***********************************************************************
Sub  CopyDiffByMD5Lists( in_PathOfSettingXML )
	Set folders = new ArrayClass
	parent_path = GetParentFullPath( in_PathOfSettingXML )
	Set c = g_VBS_Lib

	'// "LoadXML". Set "folders".
	Set root = LoadXML( in_PathOfSettingXML,  Empty )
	path = in_PathOfSettingXML
	For Each  tag  In  root.selectNodes( "./Folder" )
		Set folder = new CopyDiffByMD5Lists_FolderClass
		folder.SourceFolderFullPath        = XmlReadOrError( tag, "./@source_folder",         path )
		folder.DestinationFolderFullPath   = XmlReadOrError( tag, "./@destination_folder",    path )
		folder.SourceHashFileFullPath      = XmlReadOrError( tag, "./@source_hash_file",      path )
		folder.DestinationHashFileFullPath = XmlReadOrError( tag, "./@destination_hash_file", path )
		folder.SourceFolderFullPath        = GetFullPath( folder.SourceFolderFullPath,        parent_path )
		folder.DestinationFolderFullPath   = GetFullPath( folder.DestinationFolderFullPath,   parent_path )
		folder.SourceHashFileFullPath      = GetFullPath( folder.SourceHashFileFullPath,      parent_path )
		folder.DestinationHashFileFullPath = GetFullPath( folder.DestinationHashFileFullPath, parent_path )
		folders.Add  folder
	Next
	root = Empty


	'// Set "DateLastChecked".
	For Each  folder  In  folders.Items
		If g_fs.FileExists( folder.SourceHashFileFullPath ) Then
			checking_path = folder.SourceHashFileFullPath
		Else
			checking_path = folder.DestinationHashFileFullPath
		End If

		folder.DateLastChecked = g_fs.GetFile( checking_path ).DateLastModified
	Next


	For  folder_index = 0  To  folders.UBound_

		'// Set target "folder".
		folder = Empty
		oldest_date = GetNewestDate()
		For Each  a_folder  In  folders.Items
			If a_folder.DateLastChecked < oldest_date Then

				Set folder = a_folder  '// Target folder
				oldest_date = a_folder.DateLastChecked
			End If
		Next


		'// ...
		CopyDiffByMD5List  folder.SourceFolderFullPath,  folder.DestinationFolderFullPath, _
			folder.SourceHashFileFullPath,  folder.DestinationHashFileFullPath,  c.AfterDelete

		folder.DateLastChecked = g_fs.GetFile( folder.SourceHashFileFullPath ).DateLastModified
	Next
End Sub


 
'***********************************************************************
'* Class: CopyDiffByMD5Lists_FolderClass
'***********************************************************************
Class  CopyDiffByMD5Lists_FolderClass
	Public  SourceFolderFullPath
	Public  DestinationFolderFullPath
	Public  SourceHashFileFullPath
	Public  DestinationHashFileFullPath
	Public  DateLastChecked

'* Section: End_of_Class
End Class


 
'***********************************************************************
'* Function: GetNewestDate
'***********************************************************************
Function  GetNewestDate()
	GetNewestDate = #9999/1/1#
End Function


 
'***********************************************************************
'* Function: IsExistFullSetFolderMD5List
'***********************************************************************
Function  IsExistFullSetFolderMD5List( in_FolderPath,  in_MD5ListFilePath,  in_Empty )
	If g_fs.FolderExists( in_FolderPath ) Then
		If exist( in_MD5ListFilePath ) Then
			column_of_path = GetColumnOfPathInFolderMD5List( in_MD5ListFilePath )


			'// cd (Change current directory)
			Set ds = new CurDirStack
			If not IsEmpty( in_FolderPath ) Then
				cd  in_FolderPath
			Else
				cd  GetParentFullPath( in_MD5ListFilePath )
			End If


			'// Check existing
			is_full = True
			Set file = OpenForRead( in_MD5ListFilePath )
			Do Until  file.AtEndOfStream
				line = file.ReadLine()
				step_path = Mid( line,  column_of_path )
				If not g_fs.FileExists( step_path ) Then
					is_full = False
					Exit Do
				End If
			Loop
			file = Empty
		Else
			is_full = True
		End If
	Else
		is_full = False
	End If

	IsExistFullSetFolderMD5List = is_full
End Function


 
'***********************************************************************
'* Function: IsThereTimeStampInFolderMD5List
'***********************************************************************
Function  IsThereTimeStampInFolderMD5List( in_MD5ListFilePath )
	Const  column_of_path_with_time_stamp = 60
	IsThereTimeStampInFolderMD5List = ( _
		GetColumnOfPathInFolderMD5List( in_MD5ListFilePath ) = column_of_path_with_time_stamp )
End  Function


 
'***********************************************************************
'* Function: GetColumnOfPathInFolderMD5List
'***********************************************************************
Function  GetColumnOfPathInFolderMD5List( in_MD5ListFilePath )
	Const  time_stamp_length = 25
	Const  hash_length = 32
	column_of_path_with_time_stamp = time_stamp_length + 1 + hash_length + 2
	column_of_path_without_time_stamp = hash_length + 2

	Set file = OpenForRead( in_MD5ListFilePath )
	If file.AtEndOfStream Then
		column_of_path = 0
	Else
		line = file.ReadLine()
		is_with_time_stamp = ( Mid( line, 5, 1 ) = "-" )
		If is_with_time_stamp Then
			column_of_path = column_of_path_with_time_stamp
		Else
			column_of_path = column_of_path_without_time_stamp
		End If
	End If
	file = Empty

	GetColumnOfPathInFolderMD5List = column_of_path
End Function



'***********************************************************************
'* Class: MD5ListClass
'***********************************************************************
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


 
'***********************************************************************
'* Function: new_MD5ListItemClass
'***********************************************************************
Function  new_MD5ListItemClass( StepPath, FullPath )
	Set item = new MD5ListItemClass
	item.StepPath = StepPath
	item.MD5 = GetHashOfFile( FullPath, "MD5" )
	Set new_MD5ListItemClass = item
End Function


 
'***********************************************************************
'* Function: new_MD5ListItemClass_fromText
'***********************************************************************
Function  new_MD5ListItemClass_fromText( Text, BaseFolderPath )
	Assert  IsValidMD5ListItemText( Text )
	Set c = get_HashConsts()

	Set item = new MD5ListItemClass
	item.StepPath = Trim2( Mid( Text, c.Num_32_LengthOfMD5 + 1 ) )
	item.MD5 = ReadBinaryFile( GetFullPath( item.StepPath, BaseFolderPath ) ).MD5
	Set new_MD5ListItemClass_fromText = item
End Function


 
'***********************************************************************
'* Function: IsValidMD5ListItemText
'***********************************************************************
Sub  IsValidMD5ListItemText( Text )
	pos = InStr( Text, " " )
	Assert  pos = get_HashConsts().Num_32_LengthOfMD5 + 1
End Sub


 
'***********************************************************************
'* Class: MD5ListItemClass
'***********************************************************************
Class  MD5ListItemClass
	Public  StepPath
	Public  MD5 
	Public  IsChecked

	Function  GetItemText()
		GetItemText = Me.MD5 +" "+ Me.StepPath
	End Function

	Function  GetItemTextWithBase( BasePath )
		GetItemTextWithBase = Me.MD5 +" "+ BasePath + Me.StepPath
	End Function
End Class


'***********************************************************************
'* Function: LoadMD5List
'***********************************************************************
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


 
'***********************************************************************
'* Function: OpenForDefragment
'***********************************************************************
Function  OpenForDefragment( in_MD5ListFilePath,  in_OptionFlag )
	Set Me_ = new OpenForDefragmentClass
	Me_.Open  in_MD5ListFilePath,  in_OptionFlag
	Set OpenForDefragment = Me_
End Function


 
'***********************************************************************
'* Class: OpenForDefragmentClass
'***********************************************************************
Class  OpenForDefragmentClass
	Public  File
	Public  FileFullPath
	Public  StepPathsFromHash  '// as dictionary of string or array of string. Key=Hash value
	Public  Downloader  '// as DownloadAndExtractFileIn7zClass
	Public  AppendingFile
	Public  AppendingFileFullPath
	Public  AppendingHashes
	Public  ColumnOfHash
	Public  ColumnOfPath
	Public  FullSetFileName
	Public  ExistenceCache


 
'***********************************************************************
'* Method: Open
'*
'* Name Space:
'*    OpenForDefragmentClass::Open
'***********************************************************************
Public Sub  Open( in_MD5ListFilePath,  in_OptionFlag )
	Const  hash_length = 32
	Me.FileFullPath = GetFullPath( in_MD5ListFilePath, Empty )
	Me.ColumnOfPath = GetColumnOfPathInFolderMD5List( in_MD5ListFilePath )
	If Me.ColumnOfPath = 0 Then
		If in_OptionFlag  and  get_ToolsLibConsts().TimeStamp Then
			Const  time_stamp_length = 25
			column_of_path_with_time_stamp = time_stamp_length + 1 + hash_length + 2
			Me.ColumnOfPath = column_of_path_with_time_stamp
		End If
	End If
	Me.ColumnOfHash = Me.ColumnOfPath - hash_length - 1
	Me.FullSetFileName = "_FullSet.txt"
	is_fast_back_up = g_is_vbslib_for_fast_user
	g_is_vbslib_for_fast_user = True
	Set Me.ExistenceCache = new ExistenceCacheClass

	Set Me.File = OpenForRead( in_MD5ListFilePath )
	Set Me.StepPathsFromHash = CreateObject( "Scripting.Dictionary" )
	Set Me.Downloader = new DownloadAndExtractFileIn7zClass
	Set Me.Downloader.ExistenceCache = Me.ExistenceCache
	Set Me.AppendingHashes = new ArrayClass
	g_is_vbslib_for_fast_user = is_fast_back_up
End Sub


 
'***********************************************************************
'* Method: GetRelativePath
'*
'* Return Value:
'*    A step path or Empty(= There is not hash value in the list)
'*
'* Name Space:
'*    OpenForDefragmentClass::GetStepPath
'***********************************************************************
'***********************************************************************
'* Method: GetStepPath
'***********************************************************************
Public Function  GetStepPath( in_HashValueOfMD5,  in_BaseFullPathInMD5List )
	GetStepPath = Me.GetRelativePath( in_HashValueOfMD5,  in_BaseFullPathInMD5List )
End Function

Public Function  GetRelativePath( in_HashValueOfMD5,  in_BaseFullPathInMD5List )
	Set ec = new EchoOff

	Set step_paths_from_hash = Me.StepPathsFromHash
	If step_paths_from_hash.Exists( in_HashValueOfMD5 ) Then

		LetSet  step_path_or_array,  step_paths_from_hash( in_HashValueOfMD5 )  '// Set "step_path_or_array"

		If VarType( step_path_or_array ) = vbString Then
			GetRelativePath = step_path_or_array
			g_Coverage_GetRelativePath(0) = True
			Exit Function
		End If
	End If

	Do
		If not IsEmpty( Me.File ) Then
			If IsEmpty( step_path_or_array ) Then
				If IsEmpty( column_of_path ) Then  '// For avoid error, when loop
					Const  hash_length = 32
					column_of_path = Me.ColumnOfPath
					column_of_hash = Me.ColumnOfHash
				End If

				Set file_ = Me.File
				Do Until  file_.AtEndOfStream
					line = file_.ReadLine()
					step_path = Mid( line,  column_of_path )
					hash = Mid( line,  column_of_hash,  hash_length )

					or_ = ( not step_paths_from_hash.Exists( hash ) )
					If not or_ Then  or_ = ( IsObject( step_paths_from_hash( hash ) ) )
					If or_ Then

						Dic_addInArrayItem  step_paths_from_hash,  hash,  step_path

					End If
					If hash = in_HashValueOfMD5 Then
						Set step_path_or_array = step_paths_from_hash( hash )
						Exit Do
					End If
				Loop
				If IsEmpty( step_path_or_array ) Then _
					Me.File = Empty
			End If
		End If

		If  NOT  IsObject( step_path_or_array ) Then

			GetRelativePath = step_path_or_array
			g_Coverage_GetRelativePath(1) = True
			Exit Function
		Else

			'// Set "step_path" : Check Exists
			If IsEmpty( in_BaseFullPathInMD5List ) Then
				is_exist = True

				step_path = step_path_or_array(0)
				g_Coverage_GetRelativePath(2) = True
			Else
				If IsEmpty( ds ) Then
					Set ds = new CurDirStack
					c_EmptyFolderMD5 = get_ToolsLibConsts().EmptyFolderMD5
				End If
				If Me.ExistenceCache.FolderExists( in_BaseFullPathInMD5List ) Then
					cd  in_BaseFullPathInMD5List
					If in_HashValueOfMD5 = c_EmptyFolderMD5 Then
						g_Coverage_GetRelativePath(3) = True
						For Each  step_path  In  step_path_or_array.Items

							If Me.ExistenceCache.FolderExists( step_path ) Then _
								Exit For  '// Set "step_path"
						Next
					Else
						g_Coverage_GetRelativePath(4) = True
						For Each  step_path  In  step_path_or_array.Items

							If Me.ExistenceCache.FileExists( step_path ) Then _
								Exit For  '// Set "step_path"
						Next
						g_Coverage_GetRelativePath(5) = True
					End If
				End If
			End If

			'// ...
			If not IsEmpty( step_path ) Then
				step_paths_from_hash( in_HashValueOfMD5 ) = step_path

				GetRelativePath = step_path
				g_Coverage_GetRelativePath(6) = True
				Exit Function
			Else
				If IsEmpty( Me.File ) Then _
					Exit Function
			End If

			step_path_or_array = Empty
			g_Coverage_GetRelativePath(7) = True
		End If
	Loop
End Function


 
'***********************************************************************
'* Method: CopyFolder
'*
'* Name Space:
'*    OpenForDefragmentClass::CopyFolder
'***********************************************************************
Public Sub  CopyFolder( in_BasePathInMD5List,  in_SourceFolderPath,  in_DestinationFolderPath,  in_out_Options )
	echo  ">CopyFolder  """+ in_DestinationFolderPath +""""
	Set ec = new EchoOff
	Set c = g_VBS_Lib
	ParseOptionArguments  in_out_Options
	If in_out_Options.Exists( "integer" ) Then
		flags = in_out_Options( "integer" )
	End If
	If in_out_Options.Exists( "OpenForDefragmentOptionClass" ) Then
		Set option_ = in_out_Options( "OpenForDefragmentOptionClass" )
		flags = option_.Flags
		LetSet  copy_function,  option_.CopyOneFileFunction
	Else
		Set option_ = new OpenForDefragmentOptionClass
		option_.Flags = flags
		Set in_out_Options( "OpenForDefragmentOptionClass" ) = option_
	End If
	If IsBitSet( flags,  c.ToNotReadOnly ) Then _
		Set to_not_read_onlys = new ArrayClass


	If IsBitSet( flags, c.SubFolder ) Then
		EnumFolderObjectDic  in_SourceFolderPath,  Empty,  folders  '// Set "folders"
		flags = flags and not c.SubFolder
		For Each  step_path  In  folders.Keys
			If Me.ExistenceCache.FileExists( in_SourceFolderPath +"\"+ step_path +"\"+ Me.FullSetFileName ) Then

				Me.CopyFolder  in_BasePathInMD5List,  in_SourceFolderPath +"\"+ step_path, _
					in_DestinationFolderPath +"\"+ step_path,  flags
			End If
		Next

		Exit Sub
	End If
	Set tc = get_ToolsLibConsts()


	full_set_path = GetPathWithSeparator( in_SourceFolderPath ) + Me.FullSetFileName
	If not exist( full_set_path ) Then
		If IsEmpty( copy_function ) Then

			copy_ren  in_SourceFolderPath,  in_DestinationFolderPath

			If not IsEmpty( to_not_read_onlys ) Then _
				SetFilesToNotReadOnly  in_DestinationFolderPath
		Else
			length_of_source_folder = Len( GetFullPath( in_SourceFolderPath, Empty ) )
			Set ds = new CurDirStack
			mkdir  in_DestinationFolderPath
			option_.CurrentTimeStampInFullSetFile = Empty

			cd  in_DestinationFolderPath
			EnumFolderObject  in_SourceFolderPath,  folders  '// Set "folders"
			For Each  folder  In  folders
				is_file_exist = False
				For Each  file_  In  folder.Files '// file_ as File Object
					source_file_path = file_.Path
					step_path = Mid( source_file_path,  length_of_source_folder + 2 )

					copy_function  source_file_path,  step_path,  option_
					is_file_exist = True
					If not IsEmpty( to_not_read_onlys ) Then _
						to_not_read_onlys.Add  file_
				Next
				If not is_file_exist Then
					step_path = Mid( folder.Path,  length_of_source_folder + 2 )
					If step_path <> "" Then

						mkdir  step_path
					End If
				End If
			Next
		End If
	Else
		Const  hash_length = 32
		Const  time_stamp_length = 25
		column_of_path = GetColumnOfPathInFolderMD5List( full_set_path )
		column_of_hash = column_of_path - hash_length - 1
		base_full_path_in_list = GetFullPath( in_BasePathInMD5List, Empty )
		destination_full_path = GetFullPath( in_DestinationFolderPath, Empty )
		Set c = g_VBS_Lib
		If column_of_hash >= 2 Then _
			Set time_stamps = CreateObject( "Scripting.Dictionary" )

		Set full_set_file = OpenForRead( full_set_path )
		Set ds = new CurDirStack

		cd  in_SourceFolderPath

		Do Until  full_set_file.AtEndOfStream
			line = full_set_file.ReadLine()
			step_path = Mid( line,  column_of_path )
		If step_path <> "_Fragment.7z" Then
			destination_file_full_path = GetFullPath( step_path,  destination_full_path )
			If not IsEmpty( time_stamps )  and  not IsEmpty( step_path ) Then
				option_.CurrentTimeStampInFullSetFile = Left( line,  time_stamp_length )
				time_stamp = W3CDTF( option_.CurrentTimeStampInFullSetFile )
			Else
				time_stamp = Empty
			End If

			If IsBitNotSet( flags,  c.NotExistOnly )  or _
					not g_fs.FileExists( destination_file_full_path ) Then
					'// The cache is not used in local (destination).
				If Me.ExistenceCache.FileExists( step_path ) Then
					If IsEmpty( copy_function ) Then

						copy_ren  step_path,  destination_file_full_path
					Else
						copy_function  step_path,  destination_file_full_path,  option_
					End If
					If not IsEmpty( time_stamp ) Then _
						time_stamps( step_path ) = time_stamp
					If not IsEmpty( to_not_read_onlys ) Then _
						to_not_read_onlys.Add  g_fs.GetFile( destination_file_full_path )
				Else
					hash = Mid( line,  column_of_hash,  hash_length )
					step_path_in_list = Me.GetRelativePath( hash, Empty )
					If hash = tc.EmptyFolderMD5 Then
						mkdir  destination_file_full_path
						source_full_path = Empty

					ElseIf not IsEmpty( step_path_in_list ) Then
						full_path_in_list = GetFullPath( step_path_in_list,  base_full_path_in_list )
						If Me.ExistenceCache.FileExists( full_path_in_list ) Then
							source_full_path = full_path_in_list
						Else
							ec = Empty

							source_full_path = Me.Downloader.GetLocalPath( full_path_in_list )
							Set ec = new EchoOff
							If not IsEmpty( source_full_path ) Then _
								If not g_fs.FileExists( source_full_path ) Then _
									source_full_path = Empty
						End If
						If not IsEmpty( source_full_path ) Then
							If IsEmpty( copy_function ) Then

								copy_ren  source_full_path,  destination_file_full_path
							Else
								copy_function  source_full_path,  destination_file_full_path,  option_
							End If
							If not IsEmpty( time_stamp ) Then _
								time_stamps( step_path ) = time_stamp
							If not IsEmpty( to_not_read_onlys ) Then _
								to_not_read_onlys.Add  g_fs.GetFile( destination_file_full_path )
						Else
							If IsBitNotSet( flags, c.ExistOnly ) Then
								Raise  E_PathNotFound,  "<ERROR msg="""+ _
									"Not found the file written in the hash list."""+ vbCRLF + _
									"  jp=""存在するファイルの一覧に書かれたパスに、ファイルが見つかりません。"""+ _
									vbCRLF + _
									"           not_found="""+ step_path_in_list +""""+ vbCRLF + _
									" not_found_full_path="""+ full_path_in_list +""""+ vbCRLF + _
									"    destination_path="""+ destination_file_full_path +""""+ vbCRLF + _
									"          hash_value="""+ hash +""""+ vbCRLF + _
									"         copy_source="""+ in_SourceFolderPath +""""+ vbCRLF + _
									"    copy_destination="""+ in_DestinationFolderPath +""""+ vbCRLF + _
									"       fragment_list="""+ Me.FileFullPath +""""+ vbCRLF + _
									"    destination_list="""+ full_set_path +"""/>"
							End If
						End If
					Else
						If IsBitNotSet( flags, c.ExistOnly ) Then
							Raise  E_PathNotFound,  "<ERROR msg="""+ _
								"Not found hash value in a list in order to defragment a file"""+ vbCRLF + _
								"  jp=""存在するファイルの一覧に、該当するハッシュ値が見つかりません。"""+ vbCRLF + _
								"  hash_value="""+ hash +""""+ vbCRLF + _
								"         copy_source="""+ in_SourceFolderPath +""""+ vbCRLF + _
								"    copy_destination="""+ in_DestinationFolderPath +""""+ vbCRLF + _
								"  defragmenting_path="""+ GetFullPath( step_path, Empty ) +""""+ vbCRLF + _
								"        not_found_in="""+ Me.FileFullPath +""""+ vbCRLF + _
								"            found_in="""+ full_set_path +"""/>"
						End If
					End If
				End If
			End If
		End If
		Loop
		If not IsEmpty( to_not_read_onlys ) Then
			For Each  file_  In  to_not_read_onlys.Items
				file_.Attributes = file_.Attributes  and  not ReadOnly
					'// 次の SetDateLastModified は、リードオンリーではないほうが速いため
			Next
			to_not_read_onlys.ToEmpty
		End If

		If not IsEmpty( time_stamps ) Then
			cd  destination_full_path
			SetDateLastModified  time_stamps
		End If
	End If

	If not IsEmpty( to_not_read_onlys ) Then
		For Each  file_  In  to_not_read_onlys.Items
			file_.Attributes = file_.Attributes  and  not ReadOnly
		Next
	End If
End Sub


 
'***********************************************************************
'* Method: DownloadStart
'*
'* Name Space:
'*    OpenForDefragmentClass::DownloadStart
'*
'* Description:
'*    実装は、CopyFolder の一部です。
'***********************************************************************
Public Sub  DownloadStart( in_BasePathInMD5List,  in_SourceFolderPath,  in_DestinationFolderPath,  in_out_Options )
	Confirm_VBS_Lib_ForFastUser

	Set c = g_VBS_Lib
	ParseOptionArguments  in_out_Options
	If in_out_Options.Exists( "integer" ) Then
		flags = in_out_Options( "integer" )
	End If
	If in_out_Options.Exists( "OpenForDefragmentOptionClass" ) Then
		Set option_ = in_out_Options( "OpenForDefragmentOptionClass" )
		flags = option_.Flags
	Else
		Set option_ = new OpenForDefragmentOptionClass
		option_.Flags = flags
		Set in_out_Options( "OpenForDefragmentOptionClass" ) = option_
	End If
	Set tc = get_ToolsLibConsts()


	full_set_path = GetPathWithSeparator( in_SourceFolderPath ) + Me.FullSetFileName
	If not exist( full_set_path ) Then
	Else
		Const  hash_length = 32
		column_of_path = GetColumnOfPathInFolderMD5List( full_set_path )
		column_of_hash = column_of_path - hash_length - 1
		base_full_path_in_list = GetFullPath( in_BasePathInMD5List, Empty )
		destination_full_path = GetFullPath( in_DestinationFolderPath, Empty )
		Set full_set_file = OpenForRead( full_set_path )
		Set ds = new CurDirStack
		Set ec = new EchoOff

		cd  in_SourceFolderPath
		ec = Empty

		Do Until  full_set_file.AtEndOfStream
			line = full_set_file.ReadLine()
			step_path = Mid( line,  column_of_path )
		If step_path <> "_Fragment.7z" Then
			destination_file_full_path = GetFullPath( step_path,  destination_full_path )
			If IsBitNotSet( flags,  c.NotExistOnly )  or _
					not g_fs.FileExists( destination_file_full_path ) Then
					'// The cache is not used in local (destination).
				If Me.ExistenceCache.FileExists( step_path ) Then
				Else
					hash = Mid( line,  column_of_hash,  hash_length )
					step_path_in_list = Me.GetRelativePath( hash, Empty )
					If hash = tc.EmptyFolderMD5 Then
					ElseIf not IsEmpty( step_path_in_list ) Then
						full_path_in_list = GetFullPath( step_path_in_list,  base_full_path_in_list )
						If Me.ExistenceCache.FileExists( full_path_in_list ) Then
						Else
							Me.Downloader.DownloadStart  full_path_in_list
						End If
					End If
				End If
			End If
		End If
		Loop
	End If
End Sub


 
'***********************************************************************
'* Method: Append
'*
'* Arguments:
'*    in_OutputMD5ListFilePath - string or Empty(No writing)
'*
'* Description:
'*    in_FragmentFolderPath に、_FullSet.txt があれば、ハッシュの計算は行いません。
'*
'* Name Space:
'*    OpenForDefragmentClass::Append
'***********************************************************************
Public Sub  Append( in_OutputMD5ListFilePath,  in_BasePathInMD5List,  in_FragmentFolderPath,  in_Empty )
	echo  ">Append  """+ in_FragmentFolderPath +""""
	Set ec = new EchoOff
	full_set_path = GetPathWithSeparator( in_FragmentFolderPath ) + Me.FullSetFileName
	list_full_path = GetFullPath( in_OutputMD5ListFilePath, Empty )
	base_full_path_in_list = GetFullPath( in_BasePathInMD5List, Empty )
	fragment_folder_full_path = GetFullPath( in_FragmentFolderPath, Empty )
	Me.AppendingFile = Empty
	Set ds = new CurDirStack

	If Me.ExistenceCache.FileExists( full_set_path ) Then
		Const  hash_length = 32
		Const  time_stamp_length = 25
		column_of_path = GetColumnOfPathInFolderMD5List( full_set_path )
		column_of_hash = column_of_path - hash_length - 1

		Set file_ = OpenForRead( full_set_path )

		cd  in_FragmentFolderPath

		Do Until  file_.AtEndOfStream
			line = file_.ReadLine()
			step_path = Mid( line,  column_of_path )
			If Me.ExistenceCache.FileExists( step_path ) Then
				hash = Mid( line,  column_of_hash,  hash_length )

				Me_Append_Sub  list_full_path,  base_full_path_in_list,  fragment_folder_full_path, _
					step_path,  hash
			End If
		Loop
	Else
		cd  in_FragmentFolderPath

		EnumFolderObject  ".", folders  '// [out] folders
		For Each  folder  In  folders  '// folder as Folder Object
			For Each  file_  In  folder.Files '// file_ as File Object
				step_path = g_GetRelativePath( file_.Path,  fragment_folder_full_path )
				hash = ReadBinaryFile( step_path ).MD5

				Me_Append_Sub  list_full_path,  base_full_path_in_list,  fragment_folder_full_path, _
					step_path,  hash
			Next
		Next
	End If

	If not IsEmpty( Me.AppendingFile ) Then
		Me_SaveEnd_Sub  list_full_path
	End If
End Sub


 
'***********************************************************************
'* Method: Me_Append_Sub
'*
'* Name Space:
'*    OpenForDefragmentClass::Me_Append_Sub
'***********************************************************************
Sub  Me_Append_Sub( in_OutputMD5ListFileFullPath,  in_BaseFullPathInMD5List,  in_FragmentFolderFullPath, _
		in_FileStepPathInFragment,  in_Hash )

	step_path_in_list = Me.GetRelativePath( in_Hash,  Empty )
	If not IsEmpty( step_path_in_list ) Then _
		Exit Sub  '// Exist in MD5 list

	file_full_path = GetFullPath( in_FileStepPathInFragment,  in_FragmentFolderFullPath )
	step_path_in_list = g_GetRelativePath( file_full_path,  in_BaseFullPathInMD5List )

	Me.StepPathsFromHash( in_Hash ) = step_path_in_list

	If not IsEmpty( in_OutputMD5ListFileFullPath ) Then
		If IsEmpty( Me.AppendingFile ) Then

			Me_SaveStart_Sub  in_OutputMD5ListFileFullPath
		End If
		If Me.ColumnOfHash >= 3 Then  '// If "Me" has time stamp
			line = W3CDTF( g_fs.GetFile( file_full_path ).DateLastModified ) +" "
		Else
			line = ""
		End If
		line = line + in_Hash +" "+ step_path_in_list

		Me.AppendingFile.WriteLine  line
	Else
		Me.AppendingHashes.Add  in_Hash
	End If
End Sub


 
'***********************************************************************
'* Method: Save
'*
'* Name Space:
'*    OpenForDefragmentClass::Save
'***********************************************************************
Sub  Save( in_OutputMD5ListFilePath )
	If Me.AppendingHashes.Count = 0 Then _
		Exit Sub

	echo  ">Save  """+ in_OutputMD5ListFilePath +""""
	Set ec = new EchoOff
	list_full_path = GetFullPath( in_OutputMD5ListFilePath, Empty )
	If IsEmpty( Me.AppendingFile ) Then _
		Me_SaveStart_Sub  list_full_path
	base_path = g_fs.GetParentFolderName( Me.FileFullPath )

	For Each  hash  In  Me.AppendingHashes.Items
		step_path_in_list = Me.StepPathsFromHash( hash )
		file_full_path = GetFullPath( step_path_in_list,  base_path )
		If Me.ColumnOfHash >= 3 Then  '// If "Me" has time stamp
			line = W3CDTF( g_fs.GetFile( file_full_path ).DateLastModified ) +" "
		Else
			line = ""
		End If
		line = line + hash +" "+ step_path_in_list

		Me.AppendingFile.WriteLine  line
	Next

	Me_SaveEnd_Sub  list_full_path
End Sub


 
'***********************************************************************
'* Method: Me_SaveStart_Sub
'*
'* Name Space:
'*    OpenForDefragmentClass::Me_SaveStart_Sub
'***********************************************************************
Private Sub  Me_SaveStart_Sub( in_OutputMD5ListFileFullPath )
	Assert  IsEmpty( Me.AppendingFile )

	Me.AppendingFileFullPath = in_OutputMD5ListFileFullPath +".updating"
	Set Me.AppendingFile = OpenForWrite( Me.AppendingFileFullPath,  g_VBS_Lib.Unicode )
End Sub


 
'***********************************************************************
'* Method: Me_SaveEnd_Sub
'*
'* Name Space:
'*    OpenForDefragmentClass::Me_SaveEnd_Sub
'***********************************************************************
Private Sub  Me_SaveEnd_Sub( in_OutputMD5ListFileFullPath )
	Assert  not IsEmpty( Me.AppendingFile )
	Set c = g_VBS_Lib


	'// Close the file
	Me.AppendingFile = Empty


	'// Change to Ascii file
'// 2016-12-05	previous_BOM = ReadUnicodeFileBOM( Me.FileFullPath )
	previous_BOM = AnalyzeCharacterCodeSet( Me.FileFullPath )
	If GetLineNumsExistNotEnglighChar( Me.AppendingFileFullPath, Empty ) = 0 Then
		appending_BOM = c.No_BOM
	Else
		appending_BOM = c.Unicode
	End If
	If appending_BOM = c.No_BOM  and  previous_BOM <> c.Unicode Then
		text = ReadFile( Me.AppendingFileFullPath )

		CreateFile  Me.AppendingFileFullPath,  text  '// Not unicode
	End If


	'// Sort
	SortFolderMD5List  Me.AppendingFileFullPath,  Me.AppendingFileFullPath,  Empty


	'// Append
	If previous_BOM = c.Unicode Then
		vbslib_helper_exe = g_vbslib_ver_folder +"vbslib_helper.exe"
		r= RunProg( """"+ vbslib_helper_exe +"""  AppendCutFFFE  """+ _
			Me.FileFullPath +""" """+ Me.AppendingFileFullPath +"""",  "" )
		If r <> 0 Then Error
	Else
		If appending_BOM = c.Unicode Then
			Set file_ = OpenForWrite( Me.AppendingFileFullPath,  c.Append )
			file_.Write  ReadFile( Me.FileFullPath )
			file_ = Empty
		Else
			RunBat  "copy /B  """+ Me.AppendingFileFullPath +"""+"""+ Me.FileFullPath +""" """+ _
				Me.AppendingFileFullPath +"""",  ""
		End If
	End If


	'// Update
	SafeFileUpdateEx  Me.AppendingFileFullPath,  in_OutputMD5ListFileFullPath,  Empty
End Sub


 
'***********************************************************************
'* Method: Fragment
'*
'* Name Space:
'*    OpenForDefragmentClass::Fragment
'***********************************************************************
Public Sub  Fragment( in_BasePathInMD5List,  in_FragmentingFolderPath,  in_Flags )
	echo  ">Fragment  """+ in_FragmentingFolderPath +""""
	Set ec = new EchoOff
	Set c = g_VBS_Lib

	If IsBitSet( in_Flags, c.SubFolder ) Then
		EnumFolderObjectDic  in_FragmentingFolderPath,  Empty,  folders  '// Set "folders"
		flags = in_Flags and not c.SubFolder
		For Each  step_path  In  folders.Keys
			If Me.ExistenceCache.FileExists( in_FragmentingFolderPath +"\"+ step_path +"\"+ Me.FullSetFileName ) Then

				Me.Fragment  in_BasePathInMD5List,  in_FragmentingFolderPath +"\"+ step_path,  flags
			End If
		Next

		Exit Sub
	End If

	Const  hash_length = 32
	Const  time_stamp_length = 25
	full_set_path = GetPathWithSeparator( in_FragmentingFolderPath ) + Me.FullSetFileName
	column_of_path = GetColumnOfPathInFolderMD5List( full_set_path )
	column_of_hash = column_of_path - hash_length - 1
	base_full_path_in_list = GetFullPath( in_BasePathInMD5List, Empty )
	fragmenting_base_full_path = GetFullPath( in_FragmentingFolderPath, Empty )

	Set file_ = OpenForRead( full_set_path )
	Set ds = new CurDirStack

	cd  in_FragmentingFolderPath

	Do Until  file_.AtEndOfStream
		line = file_.ReadLine()
		step_path = Mid( line,  column_of_path )

		If Me.ExistenceCache.FileExists( step_path ) Then
			hash = Mid( line,  column_of_hash,  hash_length )
			step_path_in_list = Me.GetRelativePath( hash,  base_full_path_in_list )
			If not IsEmpty( step_path_in_list ) Then  '// In MD5 list
				fragmenting_full_path = GetFullPath( step_path,  fragmenting_base_full_path )
				full_path_in_list = GetFullPath( step_path_in_list,  base_full_path_in_list )
				If StrComp( fragmenting_full_path,  full_path_in_list,  1 ) <> 0 Then

					If ReadBinaryFile( step_path ).MD5 = hash Then
						If ReadBinaryFile( full_path_in_list ).MD5 = hash Then

							del  step_path

						End If
					End If
				End If
			End If
		End If
	Loop

	del_empty_folder  fragmenting_base_full_path
End Sub


 
'* Section: End_of_Class
End Class
ReDim  g_Coverage_GetRelativePath(7)


 
'***********************************************************************
'* Function: g_GetRelativePath
'***********************************************************************
Function  g_GetRelativePath( a, b )
	g_GetRelativePath = GetRelativePath( a, b )
End Function


 
'***********************************************************************
'* Function: get_HashConsts
'***********************************************************************
Function  get_HashConsts()
	If IsEmpty( g_HashConsts ) Then _
		Set g_HashConsts = new HashConsts
	Set get_HashConsts = g_HashConsts
End Function

Dim  g_HashConsts

Class  HashConsts
	Public  Num_32_LengthOfMD5

	Private Sub  Class_Initialize()
		Num_32_LengthOfMD5 = 32
	End Sub
End Class


 
'***********************************************************************
'* Function: get_MD5CacheConst
'***********************************************************************
Dim  g_MD5CacheConst

Function  get_MD5CacheConst()
	If IsEmpty( g_MD5CacheConst ) Then _
		Set g_MD5CacheConst = new MD5CacheConstClass
	Set get_MD5CacheConst = g_MD5CacheConst
End Function

Class  MD5CacheConstClass
	Public  TimeStamp,  HashValue,  StepPath,  All

	Private Sub  Class_Initialize()
		TimeStamp = 1
		HashValue = 2
		StepPath  = 4
		All       = 7
	End Sub
End Class


 
'***********************************************************************
'* Function: new_MD5CacheClass
'***********************************************************************
Function  new_MD5CacheClass( in_Parameter )
	Set object = new MD5CacheClass

	If IsNumeric( in_Parameter ) Then
		object.Initialize  in_Parameter
	End If

	Set new_MD5CacheClass = object
End Function


 
'***********************************************************************
'* Class: OpenForDefragmentOptionClass
'***********************************************************************
Class  OpenForDefragmentOptionClass

	'* Var: Flags
		'* as integer. This is set by user.
		Public  Flags

	'* Var: CopyOneFileFunction
		'* as CopyFunction. This is set by user.
		Public  CopyOneFileFunction

	'* Var: Delegate
		'* as variant. This is set by user.
		Public  Delegate

	'* Var: CurrentTimeStampInFullSetFile
		'* as string of W3CDTF. This is set by caller. Empty = No "_FullSet.txt" file.
		Public  CurrentTimeStampInFullSetFile

End Class


 
'***********************************************************************
'* Function: ReadPathsInMD5List
'***********************************************************************
Function  ReadPathsInMD5List( in_MD5ListFilePath,  in_ColumnOfPath )

	Const  c_NotCaseSensitive = 1
	Set paths = CreateObject( "Scripting.Dictionary" )
	paths.CompareMode = c_NotCaseSensitive

	Set file = OpenForRead( in_MD5ListFilePath )
	Do Until file.AtEndOfStream
		SplitLineAndCRLF  file.ReadLine(), line, cr_lf  '// Set "line", "cr_lf"
		If Trim( line ) <> "" Then

			paths.Add  Mid( line,  in_ColumnOfPath ),  line
		End If
	Loop
	file = Empty

	Set ReadPathsInMD5List = paths
End Function


 
'***********************************************************************
'* Class: MD5CacheClass
'***********************************************************************
Class  MD5CacheClass

	'* Var: c
		'* as MD5CacheConstClass.
		Public  c

	'* Var: HashFilePath
		'* as string
		Public  HashFilePath

	'* Var: TargetPaths
		'* as string or <PathDictionaryClass>. This is set by user.
		Public  TargetPaths

	'* Var: DictionaryFromStepPath
		'* as dictionary of <MD5CacheFileClass>. Key is step path.
		Public  DictionaryFromStepPath

	'* Var: DictionaryFromHash
		'* as dictionary of ArrayClass of leaf path. See <LeafPathDictionary>. Key is hash value.
		Public  DictionaryFromHash

	'* Var: DefaultHashFileName
		'* as string or Empty
		Public  DefaultHashFileName

	'* Var: Enabled
		'* as integer. 0 or Me.c.LineCount or Me.c.Size.
		Private  m_Enabled
		Public Property Get  Enabled() : Enabled = m_Enabled : End Property

	'* Var: IsParsedAllSomethings
		Public  IsParsedAllSomethings

	'* Var: TimeStampLength
		Public  TimeStampLength

	'* Var: HashValueColumn
		Public  HashValueColumn

	'* Var: HashValueLength
		Public  HashValueLength

	'* Var: StepPathColumn
		Public  StepPathColumn

	'* Var: OldestDate
		Public  OldestDate

	'* Var: OldestW3CDTF
		Public  OldestW3CDTF


Private Sub  Class_Initialize()
	Const  c_NotCaseSensitive = 1

	Set Me.c = get_MD5CacheConst()
	Set Me.DictionaryFromStepPath = CreateObject( "Scripting.Dictionary" )
	Me.DictionaryFromStepPath.CompareMode = c_NotCaseSensitive

	Set Me.DictionaryFromHash = CreateObject( "Scripting.Dictionary" )
	Me.DictionaryFromHash.CompareMode = c_NotCaseSensitive

	Me.DefaultHashFileName = "_HashCache.txt"
	Me.IsParsedAllSomethings = ( Me.c.TimeStamp  or  Me.c.HashValue  or  Me.c.StepPath )
	Me.HashValueLength = 32  '// MD5
	Me.OldestDate = GetOldestDate()
	Me.OldestW3CDTF = W3CDTF( Me.OldestDate )
End Sub


Public Sub  Initialize( ref_Parameter )
	m_Enabled = ref_Parameter
End Sub


 
'***********************************************************************
'* Method: GetHashFromStepPath
'*
'* Name Space:
'*    MD5CacheClass::GetHashFromStepPath
'***********************************************************************
Public Function  GetHashFromStepPath( in_StepPath )
	Me.ParseAllLines  Me.c.StepPath
	If Me.DictionaryFromStepPath.Exists( in_StepPath ) Then
		GetHashFromStepPath = Me.DictionaryFromStepPath( in_StepPath ).HashValue
	End If
End Function


 
'***********************************************************************
'* Method: GetFirstStepPathFromHash
'*
'* Name Space:
'*    MD5CacheClass::GetFirstStepPathFromHash
'***********************************************************************
Public Function  GetFirstStepPathFromHash( in_HashValue )
	Me.ParseAllLines  Me.c.HashValue
	If Me.DictionaryFromHash.Exists( in_HashValue ) Then
		GetFirstStepPathFromHash = Me.DictionaryFromHash( in_HashValue )( 0 ).StepPath
	End If
End Function


 
'***********************************************************************
'* Method: SetHashValue
'*
'* Name Space:
'*    MD5CacheClass::SetHashValue
'***********************************************************************
Public Sub  SetHashValue( in_StepPath, in_HashValue )
	If not IsEmpty( in_HashValue ) Then
		Set file = new MD5CacheFileClass
		file.HashValue = in_HashValue
		file.StepPath = in_StepPath
		file.TimeStamp = Me.OldestDate
		file.TimeStampString = Me.OldestW3CDTF

		Dic_removeInArrayItem  Me.DictionaryFromHash,  in_HashValue,  file, _
			GetRef("CompareByStepPathMember"), Empty, False, False
		Set Me.DictionaryFromStepPath( in_StepPath ) = file
		Dic_addInArrayItem  Me.DictionaryFromHash, in_HashValue, in_StepPath
	Else
		If Me.DictionaryFromStepPath.Exists( in_StepPath ) Then
			Set file = Me.DictionaryFromStepPath( in_StepPath )
			Dic_removeInArrayItem  Me.DictionaryFromHash,  file.HashValue,  file, _
				GetRef("CompareByStepPathMember"), Empty, False, False
			Me.DictionaryFromStepPath.Remove  in_StepPath
		End If
	End If
End Sub


 
'***********************************************************************
'* Method: Load
'*    Loads hash values from "in_HashFilePath".
'*
'* Arguments:
'*    in_HashFilePath - as string.
'*    in_TargetPaths  - as Empty, string or <PathDictionaryClass>.
'*
'* Description:
'*    If "in_TargetPaths" was Empty, parent of "in_HashFilePath" is used.
'*
'* Name Space:
'*    MD5CacheClass::Load
'***********************************************************************
Public Sub  Load( in_HashFilePath, in_TargetPaths )
	echo  ">MD5CacheClass::Load  """+ in_HashFilePath +""""
	Set c_ = g_VBS_Lib
	Set ec = new EchoOff

	Me.HashFilePath = GetFullPath( in_HashFilePath, Empty )
	If not IsEmpty( in_TargetPaths ) Then
		If IsObject( in_TargetPaths ) Then
			Set Me.TargetPaths = in_TargetPaths
		Else
			Me.TargetPaths = in_TargetPaths
		End If
	Else
		Me.TargetPaths = GetParentFullPath( in_HashFilePath )
	End If

	'// Set "Me.DictionaryFromStepPath" as dictionary
	Const  c_NotCaseSensitive = 1
	Set dic = CreateObject( "Scripting.Dictionary" )
	dic.CompareMode = c_NotCaseSensitive
	Set Me.DictionaryFromStepPath = dic

	'// Set "Me.DictionaryFromHash" as dictionary
	Set dic = CreateObject( "Scripting.Dictionary" )
	dic.CompareMode = c_NotCaseSensitive
	Set Me.DictionaryFromHash = dic

	'// ...
	Set reading_file = OpenForRead( in_HashFilePath )
	is_header = True
	Do Until  reading_file.AtEndOfStream
		line = reading_file.ReadLine()

		If is_header Then
			is_header = False

			If Mid( line, 5, 1 ) = "-" Then
				m_Enabled = Me.c.TimeStamp
				Me.HashValueColumn = InStr( line, " " ) + 1
				Me.TimeStampLength = Me.HashValueColumn - 2
				Me.StepPathColumn = Me.HashValueColumn + Me.HashValueLength + 1

				Assert  Me.HashValueColumn >= 2  '// space exists
				Assert  Mid( line,  Me.StepPathColumn - 1,  1 ) = " "
			Else
				m_Enabled = 0
				Me.TimeStampLength = 0
				Me.HashValueColumn = 1
				Me.StepPathColumn = Me.HashValueColumn + Me.HashValueLength + 1
			End If
		End If
	Loop

	Me.IsParsedAllSomethings = Me.IsParsedAllSomethings  and _
		not ( Me.c.TimeStamp  or  Me.c.HashValue  or  Me.c.StepPath )
End Sub


 
'***********************************************************************
'* Method: Save
'*    Saves hash values in "in_OutHashFilePath".
'*
'* Name Space:
'*    MD5CacheClass::Save
'***********************************************************************
Public Sub  Save( in_OutHashFilePath )
	If IsEmpty( in_OutHashFilePath ) Then
		Set target_paths = Me_ArrayFromWildcard( Me.TargetPaths )
		out_path = GetFullPath( Me.DefaultHashFileName, target_paths.BasePath )
	Else
		out_path = in_OutHashFilePath
	End If

	echo  ">MD5CacheClass::Save  """+ out_path +""""
	Set ec = new EchoOff
	Set c_ = g_VBS_Lib

	Me.ParseAllLines  Me.c.HashValue

	Set out_file = OpenForWrite( out_path, c_.Unicode )

	Set dic_from_hash = Me.DictionaryFromHash
	For Each  hash_value  In  dic_from_hash.Keys
		'// hash_value でループする理由は、
		'// Load したときに、Me.DictionaryFromHash の要素である配列の要素が
		'// 同じ順番で復帰できるようにするため

		Set step_path_array = dic_from_hash( hash_value )
		For i=0 To  step_path_array.UBound_
			Set  file_property = step_path_array(i)
				AssertD_TypeName  file_property, "MD5CacheFileClass"

			If IsBitSet( m_Enabled, Me.c.TimeStamp ) Then
				If IsEmpty( file_property.TimeStamp ) Then
					out_file.WriteLine  file_property.LineInCacheFile
				Else
					out_file.WriteLine  file_property.TimeStampString +" "+ _
						hash_value +" "+ file_property.StepPath
				End If
			Else
				out_file.WriteLine  hash_value +" "+ file_property.StepPath
			End If
		Next
	Next
	out_file = Empty


	'// Change to ascii file, if ascii
	If GetLineNumsExistNotEnglighChar( out_path, Empty ) = 0 Then
		text = ReadFile( out_path )
		CreateFile  out_path, text
	End If
End Sub


 
'***********************************************************************
'* Method: ParseAllLines
'*
'* Argumemt:
'*    in_IsParsingFlags - Me.c.HashValue or Me.c.StepPath or Me.c.TimeStamp
'*
'* Name Space:
'*    MD5CacheClass::ParseAllLines
'***********************************************************************
Public Sub  ParseAllLines( in_IsParsingFlags )
	is_parsing_step_path = IsBitSet( in_IsParsingFlags,  Me.c.StepPath )
	Set c_ = g_VBS_Lib

	If IsBitNotSet( Me.IsParsedAllSomethings,  Me.c.HashValue ) Then

		Set reading_file = OpenForRead( Me.HashFilePath )
		is_header = True
		hash_value_column = Me.HashValueColumn
		hash_value_length = Me.HashValueLength
		step_path_column  = Me.StepPathColumn
		Do Until  reading_file.AtEndOfStream

			line = reading_file.ReadLine()

			If line <> "" Then
				hash_value = Mid( line,  hash_value_column,  hash_value_length )
				step_path = Mid( line,  step_path_column )

				Set file_property = new MD5CacheFileClass
				file_property.LineInCacheFile = line
				file_property.HashValue = hash_value
				file_property.StepPath = step_path

				If Me.DictionaryFromStepPath.Exists( step_path ) Then
					Set old = Me.DictionaryFromStepPath( step_path )
						AssertD_TypeName  old, "MD5CacheFileClass"
					If old.HashValue <> hash_value Then
						Dic_removeInArrayItem  Me.DictionaryFromHash,  old.HashValue,  old, _
							GetRef("CompareByStepPathMember"),  Empty,  False,  False
					End If
				End If

				Dic_addExInArrayItem  Me.DictionaryFromHash,  hash_value,  file_property, _
					GetRef("CompareByStepPathMember"),  Empty,  c_.IgnoreIfExist

				If is_parsing_step_path Then
					Set Me.DictionaryFromStepPath( step_path ) = file_property
				End If
			End If
		Loop

	ElseIf is_parsing_step_path  and  IsBitNotSet( Me.IsParsedAllSomethings,  Me.c.StepPath ) Then
		step_path_column  = Me.StepPathColumn

		For Each  file_property_array  In  Me.DictionaryFromHash.Items
			For i=0 To  file_property_array.UBound_
				Set file_property = file_property_array(i)
				step_path = Mid( file_property.LineInCacheFile,  step_path_column )

				Set Me.DictionaryFromStepPath( step_path ) = file_property
			Next
		Next
	End If

	If IsBitSet( in_IsParsingFlags,  Me.c.TimeStamp )  and  IsBitNotSet( Me.IsParsedAllSomethings,  Me.c.StepPath ) Then

		For Each  file_property_array  In  Me.DictionaryFromHash.Items
			For i=0 To  file_property_array.UBound_

				Me_ParseLineInCacheFile  file_property_array(i)
			Next
		Next
	End If

	Me.IsParsedAllSomethings = Me.IsParsedAllSomethings  or _
		( in_IsParsingFlags  or  Me.c.HashValue )
End Sub


 
'***********************************************************************
'* Method: Me_ParseLineInCacheFile
'*
'* Name Space:
'*    MD5CacheClass::Me_ParseLineInCacheFile
'***********************************************************************
Public Sub  Me_ParseLineInCacheFile( ref_FileProperty )
	Set file_property = ref_FileProperty
	AssertD_TypeName  file_property, "MD5CacheFileClass"
	line = file_property.LineInCacheFile

	If IsEmpty( file_property.TimeStampString ) Then
		If m_Enabled and Me.c.TimeStamp Then
			file_property.TimeStampString = Left( line,  Me.TimeStampLength )
			file_property.TimeStamp = W3CDTF( file_property.TimeStampString )
		End If
	End If
End Sub


 
'***********************************************************************
'* Method: Scan
'*    Scan hash values of files in "in_TargetPaths" and "in_ScanFilterPaths".
'*
'* Arguments:
'*    in_TargetPaths        - as Empty, string or <PathDictionaryClass>.
'*    in_ScanFilterPaths    - as Empty, string or <PathDictionaryClass>.
'*    in_IsCompareTimeStamp - as boolean. True=Faster.
'*
'* Name Space:
'*    MD5CacheClass::Scan
'***********************************************************************
Public Sub  Scan( in_TargetPaths, in_ScanFilterPaths, in_IsCompareTimeStamp )
	If not IsEmpty( in_TargetPaths ) Then
		If IsObject( in_TargetPaths ) Then
			Set Me.TargetPaths = in_TargetPaths
		Else
			Me.TargetPaths = in_TargetPaths
		End If
	End If
	Assert  not IsEmpty( Me.TargetPaths )
	Set target_paths = Me_ArrayFromWildcard( Me.TargetPaths )

	echo  ">MD5CacheClass::Scan  """+ target_paths.BasePath +""""
	Set ec = new EchoOff

	If IsEmpty( in_ScanFilterPaths ) Then
		is_scan = True
	Else
		Set filter_paths = Me_ArrayFromWildcard( in_ScanFilterPaths )
		base_step = GetStepPath( filter_paths.BasePath,  target_paths.BasePath )
		Assert  InStr( base_step, "..\" ) = 0
		If base_step = "." Then
			base_step = ""
		Else
			base_step = base_step +"\"
		End If
	End If

	Set old_from_step_path = Me.DictionaryFromStepPath

	'// ...
	If IsEmpty( filter_paths ) Then

		'// Set "new_from_step_path" as dictionary
		Const  c_NotCaseSensitive = 1
		Set dic = CreateObject( "Scripting.Dictionary" )
		dic.CompareMode = c_NotCaseSensitive
		Set new_from_step_path = dic

		'// Set "new_from_hash" as dictionary
		Set dic = CreateObject( "Scripting.Dictionary" )
		dic.CompareMode = c_NotCaseSensitive
		Set new_from_hash = dic

		'// ...
		For Each  step_path  In  target_paths.FilePaths

			Me_ScanSub  step_path,  old_from_step_path,  in_IsCompareTimeStamp, _
				new_from_step_path,  target_paths,  new_from_hash

		Next

		Set Me.DictionaryFromStepPath = new_from_step_path
		Set Me.DictionaryFromHash     = new_from_hash
	Else
		For Each  step_path  In  Me.DictionaryFromStepPath.Keys
			If StrCompHeadOf( step_path,  base_step,  Empty ) = 0 Then
				Me.SetHashValue  step_path, Empty
			End If
		Next
		For Each  step_path  In  filter_paths.FilePaths

			Me_ScanSub  base_step + step_path,  old_from_step_path,  in_IsCompareTimeStamp, _
				old_from_step_path,  target_paths,  Me.DictionaryFromHash

		Next
	End If
End Sub


 
'***********************************************************************
'* Method: Me_ScanSub
'*
'* Name Space:
'*    MD5CacheClass::Me_ScanSub
'***********************************************************************
Private Sub  Me_ScanSub( step_path,  old_from_step_path,  in_IsCompareTimeStamp, _
		new_from_step_path,  target_paths,  new_from_hash )

	If old_from_step_path.Exists( step_path ) Then
		Set file_property = old_from_step_path( step_path )
	Else
		Set file_property = new MD5CacheFileClass
	End If

	full_path = GetFullPath( step_path, target_paths.BasePath )


	'// Set new "file_property.HashValue" in "MD5CacheFileClass"
	Set file_object = g_fs.GetFile( full_path )
	new_time_stamp = file_object.DateLastModified
	If new_time_stamp <> file_property.TimeStamp  or  not  in_IsCompareTimeStamp Then
		file_property.HashValue = g_FileHashCache( full_path )
		file_property.StepPath = step_path
		file_property.TimeStamp = new_time_stamp
		file_property.TimeStampString = W3CDTF( new_time_stamp )
	End If


	Dic_removeInArrayItem  new_from_hash,  file_property.HashValue,  file_property, _
		GetRef("CompareByStepPathMember"),  Empty,  False,  True


	Set new_from_step_path( step_path ) = file_property
	Dic_addInArrayItem  new_from_hash,  file_property.HashValue,  file_property
End Sub


 
'***********************************************************************
'* Method: Fragment
'*    Deletes files having same hash value as "Me.DictionaryFromHash( hash )( 0 )".
'*
'* Arguments:
'*    in_ScanFilterPaths - as Empty, string or <PathDictionaryClass>.
'*    ref_CopiedCache    - Comparing files as <MD5CacheClass>.
'*    in_IsCheckFileHash - as boolean.
'*
'* Name Space:
'*    MD5CacheClass::Fragment
'***********************************************************************
Public Sub  Fragment( in_ScanFilterPaths, ref_CopiedCache, in_IsCheckFileHash )

	Set target_paths = Me_ArrayFromWildcard( Me.TargetPaths )
	Set copied_target_paths = Me_ArrayFromWildcard( ref_CopiedCache.TargetPaths )

	echo  ">MD5CacheClass::Fragment  """+ target_paths.BasePath +""""
	Set ec = new EchoOff

	If IsEmpty( in_ScanFilterPaths ) Then
		is_scan = True
	Else
		Set filter_paths = ArrayFromWildcard( in_ScanFilterPaths )
	End If

	Me.ParseAllLines  Me.c.All
	ref_CopiedCache.ParseAllLines  Me.c.All

	'// Set "step_paths" as dictionary
	Const  c_NotCaseSensitive = 1
	Set dic = CreateObject( "Scripting.Dictionary" )
	dic.CompareMode = c_NotCaseSensitive
	Set step_paths = dic
	For Each  step_path  In  target_paths.FilePaths
		If not IsEmpty( filter_paths ) Then _
			is_scan = filter_paths.FileExists( step_path )
		If is_scan Then _
			step_paths( step_path ) = True
	Next


	'// Move "step_path" to last in "path_array".
	If StrCompHeadOf( target_paths.BasePath,  copied_target_paths.BasePath,  Empty ) = 0 Then
		diff_step_path = GetStepPath( target_paths.BasePath,  copied_target_paths.BasePath )
		For Each  step_path  In  step_paths.Keys
			full_path = GetFullPath( step_path,  target_paths.BasePath )

			If not Me.DictionaryFromStepPath.Exists( step_path ) Then
				If Me.DefaultHashFileName = "_FullSet.txt" Then
					message_1 = "もしくは、Defragment してから _FullSet.txt ファイルを削除し、"+ _
						"Fragment して、_FullSet.txt を作り直してください。"
				Else
					message_1 = ""
				End If
				Raise  1, "<ERROR  msg=""ハッシュ値がないファイルが存在します。"+ _
					"ファイルを削除するか、"+ _
					"ハッシュ ファイルの中のハッシュ値を追加してください。"+ _
					message_1 + _
					""""+ vbCRLF +"  step_path="""+ step_path + _
					""""+ vbCRLF +"  full_path="""+ full_path + _
					""""+ vbCRLF +"  current_hash="""+ g_FileHashCache( full_path ) + _
					""""+ vbCRLF +"  hash_file_path="""+ _
						target_paths.BasePath +"\"+ Me.DefaultHashFileName +"""/>"
			End If

			hash_value = Me.DictionaryFromStepPath( step_path ).HashValue

			If ref_CopiedCache.DictionaryFromHash.Exists( hash_value ) Then
				Set path_array = ref_CopiedCache.DictionaryFromHash( hash_value )
				is_moved = False
				step_path_from_copy = diff_step_path +"\"+ step_path
				For i=0 To path_array.UBound_
					If path_array(i) = step_path_from_copy Then
						path_array.Remove  i, 1
						path_array.Add  step_path_from_copy  '// Move "step_path" to last
						is_moved = True
						Exit For
					End If
				Next
				If not  is_moved Then
					If not Me.DictionaryFromStepPath.Exists( step_path ) Then
						If Me.DefaultHashFileName = "_FullSet.txt" Then
							message_1 = "もしくは、Defragment してから _FullSet.txt ファイルを削除し、"+ _
								"Fragment して、_FullSet.txt を作り直してください。"
						Else
							message_1 = ""
						End If
						Raise  1, "<ERROR  msg=""ハッシュ値がないファイルが存在します。"+ _
							"ファイルを削除するか、"+ _
							"ハッシュ ファイルの中のハッシュ値を追加してください。"+ _
							message_1 + _
							""""+ vbCRLF +"  step_path="""+ step_path + _
							""""+ vbCRLF +"  full_path="""+ full_path + _
							""""+ vbCRLF +"  current_hash="""+ g_FileHashCache( full_path ) + _
							""""+ vbCRLF +"  hash_file_path="""+ _
								target_paths.BasePath +"\"+ Me.DefaultHashFileName +"""/>"
					End If
				End If

				For i=0 To path_array.UBound_
					If g_FileHashCache( path_array(i) ) <> "" Then
						If i>= 1 Then
							path_i = path_array(i)
							path_array(i) = path_array(0)
							path_array(0) = path_i  '// Move exists file to first
						End If
						Exit For
					End If
				Next
			End If
		Next
	End If


	'// ...
	For Each  step_path  In  step_paths.Keys
		full_path = GetFullPath( step_path,  target_paths.BasePath )
		hash_value = Me.DictionaryFromStepPath( step_path ).HashValue

		If ref_CopiedCache.DictionaryFromHash.Exists( hash_value ) Then
			copied_0_full_path = ref_CopiedCache.DictionaryFromHash( hash_value )(0).StepPath
			copied_0_full_path = GetFullPath( copied_0_full_path, copied_target_paths.BasePath )
		Else
			copied_0_full_path = Empty
		End If

		If in_IsCheckFileHash Then

			'// Check "hash_value" of "full_path".
			If hash_value <> g_FileHashCache( full_path ) Then
				If Me.DefaultHashFileName = "_FullSet.txt" Then
					message_1 = "もしくは、Defragment してから _FullSet.txt ファイルを削除し、"+ _
						"Fragment して、_FullSet.txt を作り直してください。"
				Else
					message_1 = ""
				End If
				Raise  1, "<ERROR  msg=""ハッシュ値と内容が異なります。"+ _
					"ファイルを同じハッシュ値のファイルに置き換えるか、"+ _
					"ハッシュ ファイルの中のハッシュ値を変更してください。"+ _
					message_1 + _
					""""+ vbCRLF +"  step_path="""+ step_path + _
					""""+ vbCRLF +"  full_path="""+ full_path + _
					""""+ vbCRLF +"  current_hash="""+ g_FileHashCache( full_path ) + _
					""""+ vbCRLF +"  hash_in_file="""+ hash_value + _
					""""+ vbCRLF +"  hash_file_path="""+ _
						target_paths.BasePath +"\"+ Me.DefaultHashFileName +"""/>"
			End If

			If not IsEmpty( copied_0_full_path ) Then
			If full_path <> copied_0_full_path Then

				'// Check "hash_value" of "copied_0_full_path".
				If hash_value <> g_FileHashCache( copied_0_full_path ) Then
					Raise  1, "<ERROR  msg=""ハッシュ値と内容が異なります""  path="""+ _
						copied_0_full_path + _
						"""  hash="""+ g_FileHashCache( copied_0_full_path ) + _
						"""  expected_hash="""+ hash_value +"""/>"
				End If

				'// Check binary data in files
				If not IsSameBinaryFile( full_path,  copied_0_full_path,  Empty ) Then
					Raise  1, "<ERROR  msg=""ハッシュ値は同じですが内容が異なります""  path="""+ _
						copied_0_full_path + _
						"""  hash="""+ g_FileHashCache( copied_0_full_path ) + _
						"""  expected_hash="""+ hash_value +"""/>"
				End If
			End If
			End If
		End If


		'// ...
		If not IsEmpty( copied_0_full_path ) Then
			If full_path <> copied_0_full_path Then
				Set file = g_fs.GetFile( full_path )
				file.Attributes = file.Attributes  and  not ReadOnly

				del  full_path
			End If
		End If
	Next
End Sub


 
'***********************************************************************
'* Method: Defragment
'*    Copied files having same hash value from "Me.DictionaryFromHash( hash )( 0 )".
'*
'* Arguments:
'*    in_ScanFilterPaths - as Empty, string or <PathDictionaryClass>.
'*    in_CopiedCache     - Comparing files as <MD5CacheClass>.
'*
'* Description:
'*    See <MD5CacheClass.Fragment>.
'*
'* Name Space:
'*    MD5CacheClass::Defragment
'***********************************************************************
Public Sub  Defragment( in_ScanFilterPaths, in_CopiedCache )
	Set target_paths = Me_ArrayFromWildcard( Me.TargetPaths )
	Set copied_target_paths = Me_ArrayFromWildcard( in_CopiedCache.TargetPaths )
	Set deleting_files = CreateObject( "Scripting.Dictionary" )

	echo  ">MD5CacheClass::Defragment  """+ target_paths.BasePath +""""
	Set ec = new EchoOff

	If IsEmpty( in_ScanFilterPaths ) Then
		is_scan = True
	Else
		Set filter_paths = Me_ArrayFromWildcard( in_ScanFilterPaths )
	End If

	Me.ParseAllLines  Me.c.All
	in_CopiedCache.ParseAllLines  Me.c.All

	For Each  step_path  In  Me.DictionaryFromStepPath.Keys
		If not IsEmpty( filter_paths ) Then _
			is_scan = filter_paths.FileExists( step_path )
		If is_scan Then
			full_path = GetFullPath( step_path,  target_paths.BasePath )
			hash_value = Me.DictionaryFromStepPath( step_path ).HashValue
			If in_CopiedCache.DictionaryFromHash.Exists( hash_value ) Then
				Set path_array = in_CopiedCache.DictionaryFromHash( hash_value )

				For i=0 To  path_array.UBound_
					copied_full_path = GetFullPath( path_array(i).StepPath,  copied_target_paths.BasePath )
					If g_fs.FileExists( copied_full_path ) Then _
						Exit For
				Next

				If g_fs.FileExists( full_path ) Then
					Set file = g_fs.GetFile( full_path )
					file.Attributes = file.Attributes and not ReadOnly
					file = Empty
				End If
				copy_ren  copied_full_path, full_path
			Else
				AssertExist  full_path
			End If
		End If
	Next
End Sub


 
'***********************************************************************
'* Method: Delete
'*    Deletes a folder. Move fragment files to not deleting folder.
'*
'* Name Space:
'*    MD5CacheClass::Delete
'***********************************************************************
Public Sub  Delete( in_DeletingFolderPath,  in_MoveTargets )
	my_base_path = GetFullPath( GetBasePath( Me.TargetPaths ), Empty )
	deleting_full_path = GetFullPath( in_DeletingFolderPath, Empty )
	deleting_step_path = GetPathWithSeparator( GetStepPath( deleting_full_path,  my_base_path ) )

	For Each  source_step_path  In  Me.DictionaryFromStepPath.Keys
		If StrCompHeadOf( source_step_path,  deleting_step_path,  Empty ) = 0 Then
			source_full_path = GetFullPath( source_step_path,  my_base_path )
			If g_fs.FileExists( source_full_path ) Then

				destination_step_path = Empty
				is_exist_file = False
				For Each  cache  In  in_MoveTargets
					cache_base_path = GetFullPath( GetBasePath( cache.TargetPaths ), Empty )
					cache_step_path = GetStepPath( source_full_path,  my_base_path )

					For Each  file_attribute  In  cache.DictionaryFromHash( Me.DictionaryFromStepPath( _
							source_step_path ).HashValue ).Items
						step_path = file_attribute.StepPath

						If StrCompHeadOf( step_path,  deleting_step_path, Empty ) <> 0 Then
							destination_step_path = step_path
							destination_full_path = GetFullPath( destination_step_path, _
								cache_base_path )

							If g_fs.FileExists( destination_full_path ) Then
								is_exist_file = True
								Exit For
							End If
						End If
					Next
				Next

				If not is_exist_file Then
					If not IsEmpty( destination_step_path ) Then
						move_ren  source_full_path,  destination_full_path
					End If
				End If

				Me.SetHashValue  source_step_path, Empty
			End If
		End If
	Next
	del  in_DeletingFolderPath
End Sub


 
'***********************************************************************
'* Method: Verify
'*    Check hash value and file exists.
'*
'* Arguments:
'*    in_ScanFilterPaths - as Empty, string or <PathDictionaryClass>.
'*    in_CopiedCache     - Comparing files as <MD5CacheClass>.
'*
'* Name Space:
'*    MD5CacheClass::Verify
'***********************************************************************
Public Sub  Verify( in_ScanFilterPaths )
	Set target_paths = Me_ArrayFromWildcard( Me.TargetPaths )

	If IsEmpty( in_ScanFilterPaths ) Then
		is_scan = True
	Else
		Set filter_paths = Me_ArrayFromWildcard( in_ScanFilterPaths )
	End If

	Set failed_paths = CreateObject( "Scripting.Dictionary" )
	failed_paths.CompareMode = c_NotCaseSensitive

	For Each  my_step_path  In  Me.DictionaryFromStepPath.Keys
		If not IsEmpty( filter_paths ) Then
			is_scan = filter_paths.FileExists( my_step_path )
		End If
		If is_scan Then
			my_full_path = GetFullPath( my_step_path,  target_paths.BasePath )
			my_hash_value = Me.DictionaryFromStepPath( my_step_path ).HashValue


			'// Check "my_hash_value" of "my_full_path".
			If exist( my_full_path ) Then
				new_hash_value = ReadBinaryFile( my_full_path ).MD5
				If my_hash_value <> new_hash_value Then
					failed_paths( my_step_path ) = my_hash_value +" "+ new_hash_value
				End If
			End If
		End If
	Next

	If failed_paths.Count >= 1 Then
		list_path = GetTempPath( "MD5CacheClass_FatiledToVerifyFiles_*.txt" )
		Set list_file = OpenForWrite( list_path, Empty )
		list_file.WriteLine  "From Cache                       From File"
		For Each  failed_path  In  failed_paths.Keys
			hashs = failed_paths( failed_path )
			list_file.WriteLine  hashs +" "+ failed_path
		Next
		list_file = Empty

		Raise  E_AlreadyExist, "<ERROR msg=""ファイルのハッシュ値が異なります。""  file_list="""+ _
			list_path +"""/>"+ vbCRLF
	End If
End Sub


 
'***********************************************************************
'* Method: CheckFileExistsAnywhereInFileList
'*
'* Name Space:
'*    MD5CacheClass::CheckFileExistsAnywhereInFileList
'***********************************************************************
Sub  CheckFileExistsAnywhereInFileList( in_HashFilePath )
	Const  c_NotCaseSensitive = 1
	Set hash_file_paths = ArrayFromWildcard2( in_HashFilePath )
	Set checking_cache = new MD5CacheClass

	checking_cache.DefaultHashFileName = g_fs.GetFileName( GetFirst( hash_file_paths.Keys ) )
	my_base_path = GetBasePath( Me.TargetPaths )

	Set not_found_paths = CreateObject( "Scripting.Dictionary" )
	not_found_paths.CompareMode = c_NotCaseSensitive

	Me.ParseAllLines  Me.c.All

	For Each  hash_file_path  In  hash_file_paths.FullPaths
		checking_cache.Load  hash_file_path, Empty
		checking_base_path = GetBasePath( checking_cache.TargetPaths )
		checking_cache.ParseAllLines  Me.c.All
		For Each  hash  In  checking_cache.DictionaryFromHash.Keys
			If not Me.DictionaryFromHash.Exists( hash ) Then
				is_exist = False
			Else
				Me.MoveExistFileToFirstInArray  hash
				Set hash_with = Me.DictionaryFromHash( hash )( 0 )  '// hash_with_body_file
				is_exist = g_fs.FileExists( my_base_path +"\"+ hash_with.StepPath )
			End If

			If not is_exist Then
				For Each  checking_path  In  checking_cache.DictionaryFromHash( hash ).Items
					not_found_paths( checking_base_path +"\"+ checking_path.StepPath ) = _
						hash +", "+ hash_file_path
				Next
			End If
		Next
	Next

	If not_found_paths.Count >= 1 Then
		list_path = GetTempPath( "MD5CacheClass_NotExistFiles_*.txt" )
		Set list_file = OpenForWrite( list_path, Empty )
		list_file.WriteLine  "Not Found Following Files."
		previous_hash_file_path = ""
		For Each  checking_path  In  not_found_paths.Keys
			items = Split( not_found_paths( checking_path ), "," )
			hash = items(0)
			hash_file_path = items(1)

			If hash_file_path <> previous_hash_file_path Then
				list_file.WriteLine  ""
				list_file.WriteLine  "HashFile: "+ hash_file_path
				list_file.WriteLine  ""
				previous_hash_file_path = hash_file_path
			End If

			list_file.WriteLine  hash +" "+ checking_path
		Next
		list_file = Empty

		Raise  E_FileNotExist, _
			"<ERROR msg=""次に一覧したファイルが、MD5リストに書かれたハッシュ値と異なるか、"+ _
			"ハッシュ値が同じファイルがありません。"+ _
			"""  file_list="""+ list_path +"""/>"+ vbCRLF
	End If
End Sub


 
'***********************************************************************
'* Method: MoveExistFileToFirstInArray
'*
'* Name Space:
'*    MD5CacheClass::MoveExistFileToFirstInArray
'***********************************************************************
Sub  MoveExistFileToFirstInArray( in_HashValue )
	Set an_array = Me.DictionaryFromHash( in_HashValue )
	base_path = GetBasePath( Me.TargetPaths )
	For i=0 To  an_array.UBound_
		Set hash_with = an_array( i )  '// hash_with_body_file
		If g_fs.FileExists( base_path +"\"+ hash_with.StepPath ) Then
			For k=i-1 To 0 Step -1
				Set an_array(k+1) = an_array(k)
			Next
			Set an_array(0) = hash_with
			Exit For
		End If
	Next
End Sub


 
'***********************************************************************
'* Method: IsSameHashValuesOfLeafPathDictionary
'*
'* Name Space:
'*    MD5CacheClass::IsSameHashValuesOfLeafPathDictionary
'***********************************************************************
Function  IsSameHashValuesOfLeafPathDictionary( arg_2ndLeafPathDictionary,  in_2ndBasePath )
	Set target_paths = ArrayFromWildcard2( Me.TargetPaths )

	If IsEmpty( arg_2ndLeafPathDictionary ) Then
		Set arg_2ndLeafPathDictionary = EnumerateToLeafPathDictionary( in_2ndBasePath )
	End If

	Me.ParseAllLines  Me.c.All

	If Me.DictionaryFromStepPath.Count <> arg_2ndLeafPathDictionary.Count Then
		IsSameHashValuesOfLeafPathDictionary = False
	Else
		base_of_1st = GetPathWithSeparator( target_paths.BasePath )
		base_of_2nd = GetPathWithSeparator( GetFullPath( in_2ndBasePath, Empty ) )
		offset_of_2nd_base = Len( base_of_2nd ) + 1

		For Each  step_path  In  Me.DictionaryFromStepPath.Keys
			key_of_2nd = base_of_2nd + step_path
			If not arg_2ndLeafPathDictionary.Exists( key_of_2nd ) Then
				IsSameHashValuesOfLeafPathDictionary = False
				Exit Function
			End If

			Set file = Me.DictionaryFromStepPath( step_path )
			Set path_of_2nd = arg_2ndLeafPathDictionary( key_of_2nd )
			If file.HashValue <> g_FileHashCache( path_of_2nd.Name ) Then
				IsSameHashValuesOfLeafPathDictionary = False
				Exit Function
			End If
		Next
		IsSameHashValuesOfLeafPathDictionary = True
	End If
End Function


 
'***********************************************************************
'* Method: Me_ArrayFromWildcard
'*
'* Name Space:
'*    MD5CacheClass::Me_ArrayFromWildcard
'***********************************************************************
Private Function  Me_ArrayFromWildcard( in_TargetPaths )
	If VarType( in_TargetPaths ) = vbString Then _
		If not exist( in_TargetPaths ) Then _
			mkdir  in_TargetPaths

	Set Me_ArrayFromWildcard = ArrayFromWildcard2( in_TargetPaths )
	If not IsEmpty( Me.DefaultHashFileName ) Then
		Me_ArrayFromWildcard.AddRemove  Me.DefaultHashFileName
	End If
End Function


 

End Class


 
'***********************************************************************
'* Class: MD5CacheFileClass
'***********************************************************************
Class  MD5CacheFileClass

	'* Var: LineInCacheFile
		'* as string.
		Public  LineInCacheFile

	'* Var: HashValue
		'* MD5 Hash Value.
		Public  HashValue

	'* Var: StepPath
		Public  StepPath

	'* Var: TimeStamp
		'* as Date. See "File::DateLastModified".
		Public  TimeStamp

	'* Var: TimeStampString
		'* as string. W3CDTF.
		Public  TimeStampString


	Public Property Get  xml() : xml=xml_sub(0) : CutLastOf xml,vbCRLF,Empty : End Property
	Public Function  xml_sub( Level )
		xml_sub = GetTab(Level)+ "<MD5CacheFileClass  HashValue='"+ XmlAttrA( HashValue ) + _
			"' StepPath='"+ XmlAttrA( StepPath ) +"'/>"+ vbCRLF
	End Function
End Class

'* Section: Global


 
'***********************************************************************
'* Function: CompareByStepPathMember
'***********************************************************************
Function  CompareByStepPathMember( in_Left, in_Right, in_Parameter )
	CompareByStepPathMember = StrComp( in_Left.StepPath,  in_Right.StepPath,  1 )
End Function


 
'***********************************************************************
'* Function: BinarySearch
'***********************************************************************
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


 
'***********************************************************************
'* Function: IntCompare
'***********************************************************************
Function  IntCompare( Left, Right, Param )
	IntCompare = Left - Right
End Function


 
'***********************************************************************
'* Function: OpenForReadCRLF
'***********************************************************************
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


 
'***********************************************************************
'* Function: CutSharpIf
'***********************************************************************
Sub  CutSharpIf( InputPath, OutputPath, Symbol, IsCutTrue )

	echo  ">CutSharpIf  """& GetEchoStr( InputPath ) &""", "& Symbol &", "& IsCutTrue
	Set ec = new EchoOff

	exe = g_vbslib_ver_folder +"vbslib_helper.exe"

	If IsCutTrue Then
		is_cut_true_string = "1"
	Else
		is_cut_true_string = "0"
	End If


	For Each  a_set  In  GetInputOutputFilePaths( InputPath, OutputPath, "CutSharpIf_out_*.txt" )

		g_AppKey.CheckWritable  a_set.OutputPath, Empty
		ec = Empty
		r= RunProg( """"+ exe +""" CutSharpIf """+ a_set.InputPath +""" """+ a_set.OutputPath +_
			""" """+ Symbol +""" "+ is_cut_true_string, "" )
		Assert  r = 0
		Set ec = new EchoOff


		If a_set.IsOutputPathTemporary Then
			move_ren  a_set.OutputPath, a_set.InputPath
		End If
	Next
End Sub


 
'***********************************************************************
'* Function: CutCommentC
'***********************************************************************
Sub  CutCommentC( in_Path,  in_Empty )
	echo  ">CutCommentC  "+ GetEchoStr( in_path )
	Set ec = new EchoOff

	Set paths = ArrayFromWildcard2( in_Path )

	'// Make a file at "setting_path"
	setting_path = GetTempPath( "_CutCommentC_Setting.ini" )
	Set setting_file = OpenForWrite( setting_path, Empty )

	For Each  path  In  paths.FullPaths
		setting_file.WriteLine  "src = "+ path
		setting_file.WriteLine  "dst = "+ path
		g_AppKey.CheckWritable  path, Empty
	Next
	setting_file = Empty

	'// Call vbslib_helper.exe
	ec = Empty
	AssertExist  g_vbslib_ver_folder +"vbslib_helper.exe"
	r= RunProg( """"+ g_vbslib_ver_folder +"vbslib_helper.exe"" CutCommentC /Setting:"""+_
		setting_path +"""", _
		g_VBS_Lib.NotEchoStartCommand )
	Assert  r = 0
End Sub


 
'***********************************************************************
'* Function: GetLineCount
'***********************************************************************
Function  GetLineCount( in_Text,  in_RoundWay )
	Set re = CreateObject("VBScript.RegExp")

	re.Global = True
	re.MultiLine = True
	re.Pattern = vbLF
	Set matches = re.Execute( in_Text )

	count = matches.Count
	Select Case  Right( in_Text, 1 )
		Case  vbLF, ""
			If in_RoundWay = g_VBS_Lib.NoRound Then
				count = count + 0.5
			End If
		Case Else
			count = count + 1
	End Select
	GetLineCount = count
End Function


 
'***********************************************************************
'* Class: LineNumFromTextPositionClass
'***********************************************************************
Class  LineNumFromTextPositionClass

	Public  m_Text
	Public  m_Position
	Public  m_LineNum

	Private Sub  Class_Initialize()
		m_Text = ""
		m_Position = 1
		m_LineNum  = 1
	End Sub

	Property Get  Text() : Text = m_Text : End Property
	Property Let  Text( x )
		m_Text = x
		m_Position = 1
		m_LineNum  = 1
	End Property

	Property Get  Position() : Position = m_Position : End Property
	Property Get  LineNum()  : LineNum = m_LineNum : End Property

	Function  GetNextLineNum( in_NextPosition )
		Assert  in_NextPosition >= m_Position
			'// "in_NextPosition" が前後するときは、"GetLineNum" を呼んでください

		count = GetLineCount( Mid( m_Text, m_Position, in_NextPosition - m_Position + 1 ), Empty ) 
		If in_NextPosition = Len( m_Text ) + 1 Then
			If Right( m_Text, 1 ) = vbLF Then
				count = count + 1
			End If
		End If

		m_Position = in_NextPosition
		m_LineNum = m_LineNum + count - 1
		GetNextLineNum = m_LineNum
	End Function

	Function  GetLineNum( in_Position )
		If in_NextPosition < m_Position Then
			m_Position = 1
			m_LineNum  = 1
		End If
		GetLineNum = Me.GetNextLineNum( in_Position )
	End Function

	Sub  ReplaceTextAtHere( in_NewText )
		m_Text = Left( m_Text, m_Position - 1 ) + in_NewText
	End Sub
End Class


 
'***********************************************************************
'* Function: SearchStringTemplate
'***********************************************************************
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


 
'***********************************************************************
'* Function: GetLineNumOfTemplateDifference
'***********************************************************************
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


 
'***********************************************************************
'* Function: ReplaceStringTemplate
'***********************************************************************
Sub  ReplaceStringTemplate( FolderPath, RegularExpressionPart, BeforeTemplate, AfterTemplate, Opt )
	echo  ">ReplaceStringTemplate  """+ GetEchoStr( FolderPath ) +""", """+ RegularExpressionPart +""""
	Set ec = new EchoOff

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

		'// Set "before_sub_text"
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
'// 2016-12-05		Set cs = new_TextFileCharSetStack( ReadUnicodeFileBOM( path_string ) )
		Set cs = new_TextFileCharSetStack( AnalyzeCharacterCodeSet( path_string ) )

		CreateFile  path_string, after_text

		ec = Empty
	End If
End Sub


 
'***********************************************************************
'* Function: ReplaceStringTemplates
'***********************************************************************
Function  ReplaceStringTemplates( in_FileOrFolderPath,  in_Replaces,  in_Empty )
	echo  ">ReplaceStringTemplates  """+ GetEchoStr( in_FileOrFolderPath ) +""""
	Set ec = new EchoOff


	'// Set "replaces_in"
	ReDim  replaces_in( UBound( in_Replaces ) )  '// in = internal
	For i=0 To  UBound( in_Replaces )
		Set replace_ = in_Replaces(i)
		AssertD_TypeName  replace_, "StringTemplateReplaceClass"

		Set replace_in = new StringTemplateReplaceInternalClass  '// in = internal
		Set replace_in.Parent = replace_
		Set replaces_in(i) = replace_in

		ParseDollarVariableString  replace_.TemplateBefore,  sub_strings_before,  variables_before
		replace_in.SubStringsBefore = sub_strings_before
		replace_in.VariablesBefore = variables_before
		Set replace_in.RegularExpressionBefore = new_RegExp( replace_.KeywordBefore, True )
	Next


	'// Call "ReplaceStringTemplates_Sub"
	If TypeName( in_FileOrFolderPath ) = "FilePathClass" Then
		ec = Empty
		file_path = in_FileOrFolderPath

		ReplaceStringTemplates_Sub  file_path,  replaces_in
	Else
		Set a_grep = new GrepClass
		a_grep.IsRecurseSubFolders = True
		a_grep.IsOutFileNameOnly = True
		a_grep.Pattern = RegularExpressionPart
		founds = a_grep.Execute( in_FileOrFolderPath )
		ec = Empty
		For Each  found  In  founds

			ReplaceStringTemplates_Sub  found.Path,  replaces_in
		Next
	End If
End Function


 
'***********************************************************************
'* Function: ReplaceStringTemplates_Sub
'***********************************************************************
Sub  ReplaceStringTemplates_Sub( in_FilePath,  in_InternalReplaces )
	before_text = ReadFile( in_FilePath )
	file_name = g_fs.GetFileName( GetFilePathString( in_FilePath ) )
	after_text = ""
	is_replaced = False
	Const  integer_max = &h7FFFFFFF
	Const  debug_level = 0

'// If InStr( in_FilePath, "test.h" ) > 0 Then  Stop


	For Each  replace_in  In  in_InternalReplaces  '// in = internal
		AssertD_TypeName  replace_in, "StringTemplateReplaceInternalClass"

		replace_in.NextStart = 0
	Next


	previous_pos = 1  '// pos = position
	found_count = UBound( in_InternalReplaces ) + 1
	If found_count = 0 Then _
		Exit Sub
	Do
		'// Set "replace_in.NextStart"
		For Each  replace_in  In  in_InternalReplaces  '// in = internal

			If replace_in.NextStart < previous_pos Then

				If debug_level >= 2 Then
					echo_v  "222=> replace_in.SubStringsBefore = "+ _
						GetEchoStr( replace_in.SubStringsBefore )
				End If


				'// Set "pos" : Search by all "sub_string"
				next_pos = 0  '// pos = position
				pos = previous_pos
				For Each  sub_string  In  replace_in.SubStringsBefore
					next_pos = InStr( pos,  before_text,  sub_string )
					If next_pos = 0 Then _
						Exit For
					pos = next_pos + Len( sub_string )
				Next
				If next_pos = 0 Then
					replace_in.NextStart = integer_max
					found_count = found_count - 1
				Else
					'// Set "start_" : 前方検索する。 最も短いマッチをスキャンするため
					start_ = pos
					over   = pos
					For sub_num = UBound( replace_in.SubStringsBefore )  To 0  Step -1
						sub_string = replace_in.SubStringsBefore( sub_num )
						start_ = InStrRev( before_text,  sub_string,  start_ - 1 )
					Next

					replace_in.NextStart = start_
					replace_in.NextOver  = over
				End If


				If debug_level >= 2 Then
					echo_v  "222=> start_ = "+ GetEchoStr( start_ )
					echo_v  "222=> over   = "+ GetEchoStr( over )
				End If
			End If
		Next
		If found_count <= 0 Then _
			Exit Do


		'// Set "replace_in"
		start_ = integer_max
		over   = integer_max
		replace_in = Empty  '// in = internal
		For Each  rep  In  in_InternalReplaces  '// rep = replace_in
			If rep.NextStart < start_ Then
				start_ = rep.NextStart
				over   = rep.NextOver
				Set replace_in = rep
			ElseIf rep.NextStart = start_ Then
				If rep.NextOver < over Then
					over = rep.NextOver
					Set replace_in = rep
				End If
			End If
		Next


		'// Set "before_sub_text"
		before_sub_text = Mid( before_text,  start_,  over - start_ )


		'// Set "after_sub_text"
		Set variables = CreateObject( "Scripting.Dictionary" )
		Dic_add  variables,  replace_in.Parent.DefaultValues
		Set variables = ScanFromTemplate_Sub( variables, _
			before_sub_text,_
			replace_in.Parent.TemplateBefore,_
			replace_in.VariablesBefore,  1, False, True )
		If variables Is Nothing Then
			Set variables = CreateObject( "Scripting.Dictionary" )
		End If
		variables( "${FileName}" ) = file_name

		after_sub_text = replace_in.Parent.TemplateAfter
		For Each  key  In variables.Keys
			after_sub_text = Replace( after_sub_text, key, variables( key ) )
		Next
		after_sub_text = Replace( after_sub_text, "$\{", "${" )
		after_sub_text = Replace( after_sub_text, "$\\", "$\" )


		'// Add to "after_text"
		If after_sub_text <> before_sub_text Then
			left_of_replaced = Mid( before_text, previous_pos, start_ - previous_pos )
			after_text = after_text + left_of_replaced + after_sub_text
			is_replaced = True

			If debug_level >= 1 Then
				echo_v  "111=> left_of_replaced = "+ GetEchoStr( left_of_replaced )
				echo_v  "111=> before_sub_text = "+ GetEchoStr( before_sub_text )
				echo_v  "111=> after_text = "+ GetEchoStr( after_text )
			End If
		End If

		'// Next in the loop
		previous_pos = over
	Loop

	after_text = after_text + Mid( before_text,  previous_pos )


	'// Write "after_text" to the file
	If is_replaced Then
		path_string = GetFilePathString( in_FilePath )
		echo  path_string
		Set ec = new EchoOff
'// 2016-12-05		Set cs = new_TextFileCharSetStack( ReadUnicodeFileBOM( path_string ) )
		Set cs = new_TextFileCharSetStack( AnalyzeCharacterCodeSet( path_string ) )

		CreateFile  path_string, after_text

		ec = Empty
	End If
End Sub


 
'***********************************************************************
'* Class: StringTemplateReplaceClass
'***********************************************************************
Class  StringTemplateReplaceClass
	Public  KeywordBefore
	Public  TemplateBefore
	Public  TemplateAfter
	Public  DefaultValues  '// as dictionary. e.g. Key="${K}"

	Private Sub  Class_Initialize()
		Set Me.DefaultValues = CreateObject( "Scripting.Dictionary" )
	End Sub
End Class


'* Section: Global
 
'***********************************************************************
'* Class: StringTemplateReplaceInternalClass
'***********************************************************************
Class  StringTemplateReplaceInternalClass

	'// In "ReplaceStringTemplates"
	Public  Parent  '// as StringTemplateReplaceClass
	Public  RegularExpressionBefore
	Public  SubStringsBefore
	Public  VariablesBefore

	'// In "ReplaceStringTemplates_Sub"
	Public  NextStart  '// Position as integer
	Public  NextOver   '// Position as integer
End Class


'* Section: Global
 
'***********************************************************************
'* Function: ParsePercentVariableString
'***********************************************************************
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


 
'***********************************************************************
'* Function: ParseDollarVariableString
'***********************************************************************
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


 
'***********************************************************************
'* Function: ExpandGitIgnorePattern
'***********************************************************************
Function  ExpandGitIgnorePattern( in_Pattern )
	Set folder = g_fs.GetFolder( "." )
	Set work = new ExpandGitIgnorePatternWorkClass
	Set work.OutPaths = new ArrayClass
	work.ParentPath = ""
	work.LeftSeparator = ""
	Set work.WildcardRegularExpression = new_WildcardRegularExpressionOf_glob()
	work.NestLevel = 0

	If IsArray( in_Pattern ) Then
		patterns = in_Pattern
	Else
		patterns = Array( in_Pattern )
	End If
	For pattern_index = 0  To  UBound( patterns )
		pattern_string = patterns( pattern_index )
		Set pat = new ExpandGitIgnorePattern_PatternClass

		pat.PatternString = pattern_string
		Set pat.Names = get_PathNameRegularExpression().Execute( _
			pat.PatternString +"/" )

		pat.RegExps = new_EmptyArray( pat.Names.Count - 1 )
		pat.LeftSeparator = new_EmptyArray( pat.Names.Count - 1 )
		work.NestLevel = 0
		For name_index = 0  To  pat.Names.Count - 1
			sub_pattern = pat.Names( name_index ).Value
			sub_pattern = Left( sub_pattern, Len( sub_pattern ) - 1 )
			Set pat.RegExps( name_index ) = GetRegularExpressionFrom_glob( sub_pattern )
			pat.LeftSeparator( name_index ) = work.GetSeparator( sub_pattern )

			work.LeftSeparator = Right( pat.Names( name_index ).Value, 1 )
			work.NestLevel = work.NestLevel + 1
		Next
		work.LeftSeparator = ""
		work.NestLevel = 0
		Set patterns( pattern_index ) = pat
	Next


	ExpandGitIgnorePattern_Sub  work, folder, patterns


	ExpandGitIgnorePattern = work.OutPaths.Items
End Function


Sub  ExpandGitIgnorePattern_Sub( work, folder, patterns )
	Const  num_1_ignore_case = 1

	Set file_patterns = new ArrayClass
	Set folder_patterns = new ArrayClass
	For Each  pattern  In  patterns
		If pattern.Names.Count = work.NestLevel + 1 Then
			file_patterns.Add  pattern
		Else
			folder_patterns.Add  pattern
		End If
	Next


	'// Set "objects" : File or folder
	Set files = folder.Files
	ReDim  objects( files.Count )
	For Each  file  In  files
		file_name = file.Name
		Set item = new NameOnlyClass
		item.Name = file_name
		Set item.Delegate = file
		Set objects(i) = item
		i = i + 1
	Next
	files = Empty

	Set folders = folder.SubFolders
	ReDim Preserve  objects( i + folders.Count )
	For Each  sub_folder  In  folders
		folder_name = sub_folder.Name
		Set item = new NameOnlyClass
		item.Name = folder_name
		Set item.Delegate = sub_folder
		Set objects(i) = item
		i = i + 1
	Next
	folders = Empty
	ReDim Preserve  objects( i - 1 )

	QuickSort  objects, 0, UBound( objects ), _
		GetRef("NameCompare"), num_1_ignore_case


	'// Loop of "objects"
	For Each  object  In  objects

		If TypeName( object.Delegate ) = "File" Then
			For Each  pat  In  file_patterns.Items
				If pat.RegExps( work.NestLevel ).Test( object.Name ) Then _
					Exit For
			Next
			If not IsEmpty( pat ) Then

				work.OutPaths.Add  work.ParentPath + pat.LeftSeparator( work.NestLevel ) + object.Name

			End If

		Else  '// "Folder"
			For Each  pat  In  folder_patterns.Items
				If pat.RegExps( work.NestLevel ).Test( object.Name ) Then _
					Exit For
			Next
			If not IsEmpty( pat ) Then
				folder_path = work.ParentPath
				work.ParentPath = folder_path + pat.LeftSeparator( work.NestLevel ) + object.Name
				work.NestLevel = work.NestLevel + 1


				ExpandGitIgnorePattern_Sub  work,  object.Delegate,  folder_patterns.Items


				work.ParentPath = folder_path
				work.NestLevel = work.NestLevel - 1
			End If
		End If
	Next

End Sub


 
Class  ExpandGitIgnorePatternWorkClass
	Public  OutPaths
	Public  ParentPath
	Public  LeftSeparator
	Public  WildcardRegularExpression
	Public  NestLevel

	Function  GetSeparator( in_Pattern )
		Set work = Me
		If work.NestLevel = 0 Then
			GetSeparator = ""
		ElseIf work.WildcardRegularExpression.Test( in_Pattern ) Then
			GetSeparator = "\"
		Else
			GetSeparator = work.LeftSeparator
		End If
	End Function
End Class

Class  ExpandGitIgnorePattern_PatternClass
	Public  PatternString
	Public  Names
	Public  RegExps  '// array of RegularExpression
	Public  LeftSeparator
End Class


 
'***********************************************************************
'* Function: Expand_glob_Pattern
'***********************************************************************
Function  Expand_glob_Pattern( in_Pattern )
	Set folder = g_fs.GetFolder( "." )
	Set work = new Expand_glob_PatternWorkClass
	work.Pattern = in_Pattern
	Set work.OutPaths = new ArrayClass
	work.ParentPath = ""
	work.LeftSeparator = ""
	Set work.WildcardRegularExpression = new_WildcardRegularExpressionOf_glob()
	Set work.PathNames = get_PathNameRegularExpression().Execute( in_Pattern +"/" )
	work.NestLevel = 0

	Expand_glob_Pattern_Sub  work, folder
	Expand_glob_Pattern = work.OutPaths.Items
End Function


Sub  Expand_glob_Pattern_Sub( work, folder )
	Const  num_1_ignore_case = 1

	sub_pattern = work.PathNames( work.NestLevel ).Value
	sub_pattern = Left( sub_pattern, Len( sub_pattern ) - 1 )
	Set re = GetRegularExpressionFrom_glob( sub_pattern )
	separator = work.GetSeparator( sub_pattern )

	If work.PathNames.Count = work.NestLevel + 1 Then  '// File or Folder
		i = 0  '// Index of "sort_box"

		Set files = folder.Files
		ReDim  sort_box( files.Count )
		For Each  file  In  files
			file_name = file.Name
			If re.Test( file_name ) Then
				Set item = new NameOnlyClass
				item.Name = file_name
				Set sort_box(i) = item
				i = i + 1
			End If
		Next
		files = Empty

		Set folders = folder.SubFolders
		ReDim Preserve  sort_box( i + folders.Count )
		For Each  sub_folder  In  folders
			folder_name = sub_folder.Name
			If re.Test( folder_name ) Then
				Set item = new NameOnlyClass
				item.Name = folder_name
				Set sort_box(i) = item
				i = i + 1
			End If
		Next
		folders = Empty
		ReDim Preserve  sort_box( i - 1 )

		QuickSort  sort_box, 0, UBound( sort_box ), _
			GetRef("NameCompare"), num_1_ignore_case

		For Each  item  In  sort_box
			work.OutPaths.Add  work.ParentPath + separator + item.Name
		Next

	Else  '// Folder
		Set folders = folder.SubFolders
		ReDim  sort_box( folders.Count )
		i = 0  '// Index of "sort_box"

		For Each  sub_folder  In  folders
			folder_name = sub_folder.Name
			If re.Test( folder_name ) Then
				Set item = new NameOnlyClass
				item.Name = folder_name
				Set item.Delegate = sub_folder
				Set sort_box(i) = item
				i = i + 1
			End If
		Next
		folders = Empty
		ReDim Preserve  sort_box( i - 1 )

		QuickSort  sort_box, 0, UBound( sort_box ), _
			GetRef("NameCompare"), num_1_ignore_case

		work.NestLevel = work.NestLevel + 1
		folder_path = work.ParentPath
		left_separator_stack = work.LeftSeparator
		work.LeftSeparator = Mid( work.Pattern, work.PathNames( work.NestLevel ).FirstIndex, 1 )
		For Each  item  In  sort_box
				work.ParentPath = folder_path + separator + item.Name

				Expand_glob_Pattern_Sub  work, item.Delegate
		Next
		work.ParentPath = folder_path
		work.LeftSeparator = left_separator_stack
		work.NestLevel = work.NestLevel - 1
	End If
End Sub


Class  Expand_glob_PatternWorkClass
	Public  Pattern
	Public  OutPaths
	Public  ParentPath
	Public  LeftSeparator
	Public  WildcardRegularExpression
	Public  PathNames
	Public  NestLevel

	Function  GetSeparator( in_Pattern )
		Set work = Me
		If work.NestLevel = 0 Then
			GetSeparator = ""
		ElseIf work.WildcardRegularExpression.Test( in_Pattern ) Then
			GetSeparator = "\"
		Else
			GetSeparator = work.LeftSeparator
		End If
	End Function
End Class


 
'***********************************************************************
'* Function: GetRegularExpressionFrom_glob
'***********************************************************************
Function  GetRegularExpressionFrom_glob( in_glob_Pattern )
	ss = Replace( in_glob_Pattern, "\", "\\" )
	ss = Replace( ss, "$", "\$" )
	ss = Replace( ss, "^", "\^" )
	ss = Replace( ss, "{", "\{" )
	ss = Replace( ss, "}", "\}" )
	ss = Replace( ss, "(", "\(" )
	ss = Replace( ss, ")", "\)" )
	ss = Replace( ss, "|", "\|" )
	ss = Replace( ss, "+", "\+" )
	ss = Replace( ss, ".", "\." )
	ss = Replace( ss, "*", ".*" )
	ss = Replace( ss, "?", "." )
	ss = Replace( ss, "[^", "[\^" )
	ss = Replace( ss, "[!", "[^" )
	Set re = CreateObject( "VBScript.RegExp" )
	re.IgnoreCase = True
	re.Pattern = "^"+ ss +"$"
	Set GetRegularExpressionFrom_glob = re
End Function


 
'***********************************************************************
'* Function: new_WildcardRegularExpressionOf_glob
'***********************************************************************
Function  new_WildcardRegularExpressionOf_glob()
	Set re = CreateObject( "VBScript.RegExp" )
	For Each  wildcard  In  Array( "*", "?", "[", "]" )
		pattern = pattern + "|[^\\]?\"+ wildcard
	Next
	re.Pattern = Mid( pattern, 2 )
	Set new_WildcardRegularExpressionOf_glob = re
End Function


 
'***********************************************************************
'* Function: get_PathNameRegularExpression
'***********************************************************************
Function  get_PathNameRegularExpression()
	If IsEmpty( g_PathNameRegularExpression ) Then
		Set g_PathNameRegularExpression = CreateObject( "VBScript.RegExp" )
		g_PathNameRegularExpression.Pattern = "([^\\/]*(\\|/))|([^\\/]+$)"
		g_PathNameRegularExpression.Global = True
	End If
	Set get_PathNameRegularExpression = g_PathNameRegularExpression
End Function
Dim  g_PathNameRegularExpression


 
'***********************************************************************
'* Function: GetReadOnlyList
'***********************************************************************
Function  GetReadOnlyList( TargetPath, out_ReadOnlyDictionary, Opt )
	Set ro_dic = CreateObject( "Scripting.Dictionary" )  '// Read only dictionary

	If g_fs.FolderExists( TargetPath ) Then
		read_only_count = 0

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


 
'***********************************************************************
'* Function: OpenForMakeRuleOfRevisionFolder
'***********************************************************************
Function  OpenForMakeRuleOfRevisionFolder( in_RuleFilePath )
	Set Me_ = new MakeRuleSetOfRevisionFolderClass
	Me_.Load  in_RuleFilePath
	Set  OpenForMakeRuleOfRevisionFolder= Me_
End Function


 
'***********************************************************************
'* Class: MakeRuleSetOfRevisionFolderClass
'*    This instance must be created in <OpenForMakeRuleOfRevisionFolder>.
'***********************************************************************
Class  MakeRuleSetOfRevisionFolderClass
	Public  XML_Root   '// as IXMLDOMElement
	Public  Variables  '// as LazyDictionaryClass
	Public  MakeRules  '// as ArrayClass of MakeRule_OfRevisionFolder_Class

	'// Constants
	Public  c_GetString
	Public  c_Make

	Private Sub  Class_Initialize()
		Set Me.MakeRules = new ArrayClass

		Me.c_GetString = 1
		Me.c_Make = 2
	End Sub

	Public Property Get  xml() : xml=xml_sub(0) : End Property
	Public Function  xml_sub( Level )
		xml_sub = GetTab(Level)+ "<"+TypeName(Me)+">"+ vbCRLF
		For Each  a_rule  In  MakeRules.Items
			xml_sub = xml_sub + GetTab(Level+1)+ "<MakeRule>"+ vbCRLF
			For Each  output_index  In  a_rule.Outputs.Items
				xml_sub = xml_sub + GetTab(Level+2)+ "<Output  path="""+ a_rule.Paths( output_index ) +"""/>"+ vbCRLF
			Next
			For Each  input_index  In  a_rule.Inputs.Items
				xml_sub = xml_sub + GetTab(Level+2)+ "<Input  path="""+ a_rule.Paths( input_index ) +"""/>"+ vbCRLF
			Next
			xml_sub = xml_sub + GetTab(Level+2)+ "<Command>"+ a_rule.Command +"</Command>"+ vbCRLF
			xml_sub = xml_sub + GetTab(Level+1)+ "</MakeRule>"+ vbCRLF
		Next
		xml_sub = xml_sub + GetTab(Level) + "</"+TypeName(Me)+">"
	End Function


 
'***********************************************************************
'* Method: GetMakeTreeString
'*
'* Name Space:
'*    MakeRuleSetOfRevisionFolderClass::GetMakeTreeString
'***********************************************************************
Public Function  GetMakeTreeString( in_TargetWithRevisionPath )
	If VarType( in_TargetWithRevisionPath ) = vbString Then
		Set relations = Me.GetMakeRelations( in_TargetWithRevisionPath )
	Else
		Set relations = in_TargetWithRevisionPath
	End If
	Set stream = new StringStream

	For Each  relation  In  relations.Items

		stream.WriteLine  relation.TargetLabel
	Next

	GetMakeTreeString = stream.ReadAll()
End Function


 
'***********************************************************************
'* Method: GetAllCommandsString
'*
'* Name Space:
'*    MakeRuleSetOfRevisionFolderClass::GetAllCommandsString
'***********************************************************************
Public Function  GetAllCommandsString( in_TargetWithRevisionPath )
	GetAllCommandsString = Me.IterateCommands_Sub( in_TargetWithRevisionPath,  Me.c_GetString,  Empty )
End Function


 
'***********************************************************************
'* Method: Load
'*
'* Name Space:
'*    MakeRuleSetOfRevisionFolderClass::Load
'***********************************************************************
Public Sub  Load( in_RuleFilePath )
	If not IsEmpty( in_RuleFilePath ) Then
		Set Me.XML_Root = LoadXML( in_RuleFilePath,  Empty )
		Set Me.Variables = LoadVariableInXML( Me.XML_Root,  in_RuleFilePath )
		Me.MakeRules.ToEmpty

		Me_LoadAdditionally_Sub  in_RuleFilePath,  Me.XML_Root
	Else
		Set Me.Variables = new LazyDictionaryClass
		Me.MakeRules.ToEmpty
	End If
End Sub


 
'***********************************************************************
'* Method: LoadAdditionally
'*
'* Name Space:
'*    MakeRuleSetOfRevisionFolderClass::LoadAdditionally
'***********************************************************************
Public Sub  LoadAdditionally( in_RuleFilePath )
	If IsEmpty( in_RuleFilePath ) Then _
		Exit Sub

	Set a_XML_root = LoadXML( in_RuleFilePath,  Empty )
	Set variables_ = LoadVariableInXML( a_XML_root,  in_RuleFilePath )

	Me.Variables.AddDictionary  variables_
	Me_LoadAdditionally_Sub  in_RuleFilePath,  a_XML_root
End Sub


 
'***********************************************************************
'* Method: Me_LoadAdditionally_Sub
'*
'* Name Space:
'*    MakeRuleSetOfRevisionFolderClass::Me_LoadAdditionally_Sub
'***********************************************************************
Private Sub  Me_LoadAdditionally_Sub( in_RuleFilePath,  in_XML_Root )
	rule_file_path = GetFilePathString ( in_RuleFilePath )
	parent_path = GetParentFullPath( rule_file_path )

	For Each  rule_tag  In  in_XML_Root.selectNodes( "//MakeRule" )
		Set rule = new MakeRule_OfRevisionFolder_Class
		Me.MakeRules.Add  rule

		For Each  a_tag  In  rule_tag.selectNodes( "./Output | ./Input | ./Input_" )
			path = XmlReadOrError( a_tag,  "./@path",  rule_file_path )
			full_path = Me.Variables( path )
			path_index = rule.Paths.UBound_ + 1
			AssertFullPath  full_path,  rule_file_path +"//"+ a_tag.tagName +"/@path"

			rule.Paths.Add  full_path  '// Index of "Paths" is "PathID".
			If a_tag.tagName = "Output" Then
				rule.Outputs( path ) = path_index
			Else
				rule.Inputs( path ) = path_index
			End If

			If Right( path, 2 ) <> "\*" Then
				Raise  E_Others, "<ERROR msg="""+ _
					"パスの最後は、\* にしてください。"+ _
					"""  path="""+ rule.Label +"""/>"
			End If
		Next

		rule.Command            = XmlRead( rule_tag,  "./Command" )
		rule.CurrentFolder      = XmlRead( rule_tag,  "./Command/@current_folder" )
		rule.ExpectedErrorLevel = XmlRead( rule_tag,  "./Command/@expected_error_level" )
		If IsEmpty( rule.CurrentFolder ) Then _
			rule.CurrentFolder = "."
		rule.CurrentFolder = GetFullPath( Me.Variables( rule.CurrentFolder ),  parent_path )
		If IsEmpty( rule.ExpectedErrorLevel ) Then _
			rule.ExpectedErrorLevel = "0"

		rule.Revisions = XmlRead( rule_tag,  "./Revisions" )
		If not IsEmpty( rule.Revisions ) Then _
			rule.Revisions = ArrayFromCSV( rule.Revisions )

		For Each  revision_tag  In  rule_tag.selectNodes( "./RevisionSet" )
			revision_set = ArrayFromCSV( revision_tag.selectSingleNode( "./text()" ).nodeValue )
			rule.RevisionSets.Add  revision_set

			If UBound( revision_set ) <> rule.Paths.UBound_ Then
				Raise  E_Others, "<ERROR msg="""+ _
					"RevisionSet タグの中の要素数が入出力の数と合っていません。"+ _
					"""  MakeRule="""+ rule.Label +"""/>"
			End If
		Next
	Next

	For Each  include_tag  In  in_XML_Root.selectNodes( "//Include" )
		path = XmlReadOrError( include_tag,  "./@path",  rule_file_path )
		Me.LoadAdditionally  GetFullPath( path,  parent_path )
	Next
End Sub


 
'***********************************************************************
'* Method: Make
'*
'* Name Space:
'*    MakeRuleSetOfRevisionFolderClass::Make
'***********************************************************************
Public Sub  Make( in_TargetWithRevisionPath,  ref_AppKey )
	Me.IterateCommands_Sub in_TargetWithRevisionPath,  Me.c_Make,  ref_AppKey
End Sub


 
'***********************************************************************
'* Method: IterateCommands_Sub
'*
'* Argumets:
'*    in_Mode - Me.c_GetString,  Me.c_Make
'*
'* Name Space:
'*    MakeRuleSetOfRevisionFolderClass::IterateCommands_Sub
'***********************************************************************
Public Function  IterateCommands_Sub( in_TargetWithRevisionPath,  in_Mode,  ref_AppKey )
	Set ds = new CurDirStack
	If VarType( in_TargetWithRevisionPath ) = vbString Then
		Set relations = Me.GetMakeRelations( in_TargetWithRevisionPath )
	Else
		Set relations = in_TargetWithRevisionPath
	End If
	ReverseObjectArray  relations.Items,  relations
	Set stream = new StringStream

	step_num = 0
	For Each  relation  In  relations
		If not IsEmpty( relation.Command ) Then
			AssertD_TypeName  relation, "MakeRelation_OfRevisionFolder_Class"
			step_num = step_num + 1

			stream.WriteLine  "-------------------------------------------------------------------------------"
			stream.WriteLine  "Section: Step"+ CStr( step_num )

			output_index = 0
			input_index = 0
			path_index = 0
			DicKeyToArr  relation.MakeRule.Outputs,  outputs
			DicKeyToArr  relation.MakeRule.Inputs,   inputs
			ReDim  output_paths( UBound( outputs ) )
			ReDim  input_paths( UBound( inputs ) )
			output_path_index = relation.MakeRule.Outputs( outputs( output_index ) )
			If input_index <= UBound( inputs ) Then
				input_path_index = relation.MakeRule.Inputs( inputs( input_index ) )
			Else
				input_path_index = -1
			End If
			Do While  output_path_index <> -1  or  input_path_index <> -1
				If not IsEmpty( relation.Revision ) Then
					revision = relation.Revision
				Else
					revision = relation.RevisionSet( path_index )
				End If
				If output_path_index = path_index Then
					path = outputs( output_index )
					CutLastOf  path, "*", Empty
					path = path + revision

					stream.WriteLine  "Output: "+ path +" <= Work"

					output_paths( output_index ) = Me.Variables( path )
					output_index = output_index + 1
					If output_index <= UBound( outputs ) Then
						output_path_index = relation.MakeRule.Outputs( outputs( output_index ) )
					Else
						output_path_index = -1
					End If
				Else
					path = inputs( input_index )
					CutLastOf  path, "*", Empty
					path = path + revision

					stream.WriteLine  "Input:  "+ path +" => Work"

					input_paths( input_index ) = Me.Variables( path )
					input_index = input_index + 1
					If input_index <= UBound( inputs ) Then
						input_path_index = relation.MakeRule.Inputs( inputs( input_index ) )
					Else
						input_path_index = -1
					End If
				End If
				path_index = path_index + 1
			Loop
			stream.WriteLine  "Current Directory: "+ relation.MakeRule.CurrentFolder
			stream.WriteLine  "Command: "+ relation.Command


			If in_Mode = Me.c_Make Then
				echo  stream.ReadAll()


				'// Make input work folder
				Set ec = new EchoOff
				For Each  input_path  In  input_paths
					work_path = GetFullPath( "..\Work",  input_path )
					Assert  g_fs.GetFileName( work_path ) = "Work"
					Set w_=ref_AppKey.NewWritable( work_path ).Enable()

					copy_ren  input_path,  work_path
					SetFilesToNotReadOnly  work_path
					w_=Empty
					Set w_=ref_AppKey.NewWritable( input_path ).Enable()
					SetFilesToReadOnly  input_path
					w_=Empty
				Next
				ec = Empty


				'// Make empty output work folder
				Set ec = new EchoOff
				For Each  output_path  In  output_paths
					work_path = GetFullPath( "..\Work",  output_path )
					Assert  g_fs.GetFileName( work_path ) = "Work"
					Set w_=ref_AppKey.NewWritable( work_path ).Enable()

					del    work_path
					mkdir  work_path
					w_=Empty
				Next
				ec = Empty


				'// Run a command
				Set ec = new EchoOff
				Set stream = new StringStream
				cd  relation.MakeRule.CurrentFolder
				ec = Empty

				'// RunBat  "@echo off"+ vbCRLF + relation.Command,  g_VBS_Lib.NotEchoStartCommand
				RunProg  relation.Command,  g_VBS_Lib.NotEchoStartCommand


				'// Delete input work folder
				Set ec = new EchoOff
				For Each  input_path  In  input_paths
					work_path = GetFullPath( "..\Work",  input_path )
					Assert  g_fs.GetFileName( work_path ) = "Work"
					Set w_=ref_AppKey.NewWritable( work_path ).Enable()

					del  work_path
					w_=Empty
				Next
				ec = Empty


				'// Make output folder from work
				Set ec = new EchoOff
				For Each  output_path  In  output_paths
					work_path = GetFullPath( "..\Work",  output_path )

					If not exist( output_path ) Then
						Set w_=ref_AppKey.NewWritable( Array( output_path,  work_path ) ).Enable()

						move  work_path,  output_path
						SetFilesToReadOnly  output_path
						w_=Empty

					ElseIf IsSameFolder( work_path,  output_path,  Empty ) Then
						Assert  g_fs.GetFileName( work_path ) = "Work"
						Set w_=ref_AppKey.NewWritable( work_path ).Enable()

						del  work_path
						w_=Empty
					Else
						Raise  1, "<ERROR msg=""出力した Work フォルダーがリビジョンと異なります。"""+ vbCRLF + _
							"  revision="""+ output_path +""""+ vbCRLF + _
							"  work=    """+ work_path +"""/>"
					End If
				Next
				ec = Empty
			End If

			stream.WriteLine  ""
		End If
	Next

	If in_Mode = Me.c_GetString Then _
		IterateCommands_Sub = stream.ReadAll()
End Function


 
'***********************************************************************
'* Method: IsFoundMakeRelations
'*
'* Name Space:
'*    MakeRuleSetOfRevisionFolderClass::IsFoundMakeRelations
'***********************************************************************
Public Function  IsFoundMakeRelations( in_TargetWithRevisionPath )
	IsFoundMakeRelations = Me_GetMakeRelations_Sub( in_TargetWithRevisionPath,  True )
End Function


 
'***********************************************************************
'* Method: GetMakeRelations
'*
'* Return Value:
'*    ArrayClass of string. Tab + path with revision and variale.
'*
'* Description:
'*    See <MakeRuleSetOfRevisionFolderClass.GetMakeTreeString>.
'*
'* Name Space:
'*    MakeRuleSetOfRevisionFolderClass::GetMakeRelations
'***********************************************************************
Public Function  GetMakeRelations( in_TargetWithRevisionPath )
	Set GetMakeRelations = Me_GetMakeRelations_Sub( in_TargetWithRevisionPath,  False )
End Function


 
'***********************************************************************
'* Method: Me_GetMakeRelations_Sub
'*
'* Name Space:
'*    MakeRuleSetOfRevisionFolderClass::Me_GetMakeRelations_Sub
'***********************************************************************
Private Function  Me_GetMakeRelations_Sub( in_TargetWithRevisionPath,  in_IsFoundOnly )
	Assert  Trim2( in_TargetWithRevisionPath ) = in_TargetWithRevisionPath
	Set expanded = Dict(Array( ))
	Set temporary_relation = new MakeRelation_OfRevisionFolder_Class
	temporary_relation.TargetLabel = in_TargetWithRevisionPath
	no_relation_count = 0

	Set queue = new ArrayClass
	queue.Add  temporary_relation
	queue_index = 0

	Do While  queue_index >= 0
		expanding_label = queue( queue_index ).TargetLabel
		expanding_path_with_tab = expanding_label
		If Left( expanding_path_with_tab, 2 ) = "+ " Then _
			expanding_path_with_tab = Mid( expanding_path_with_tab, 3 )

		expanding_path = Trim2( expanding_path_with_tab )
		nest_level = Len( expanding_path_with_tab ) - Len( expanding_path )
			'// Count of spaces at the left of the string
		expanding_full_path = Me.Variables.GetFullPath( expanding_path,  Empty )
		If not expanded( expanding_full_path ) Then
			Set relations = new ArrayClass  '// Relation is matched rule and revision number
			expanded( expanding_full_path ) = True


			'// echo  "Expanding: "+ expanding_path


			For Each  rule  In  Me.MakeRules.Items

				Me_AddMatchedRelationFromMakeRule  relations, _
					expanding_label,  expanding_full_path,  rule
					'// Set "relations"
			Next


			If in_IsFoundOnly Then
				Me_GetMakeRelations_Sub = ( relations.Count >= 1 )
				Exit Function
			End If


			'// Select the best rule, if there were many matched rules
			If relations.Count >= 2 Then


				'// Set "rules" from "relations".
				Set rules = new ArrayClass
				For Each  relation  In  relations.Items
					is_exist = False
					For Each  rule  In  rules.Items
						If relation.MakeRule is rule Then _
							is_exist = True
					Next
					If not is_exist Then _
						rules.Add  relation.MakeRule
				Next


				'// Set "best_relation" that has "max_matched_revision_count" in "queue".
				Set best_relation = new ArrayClass
				max_matched_revision_count = 0  '// Max count of matched <Output> tag in <RevisionSets>
				For Each  rule  In  rules.Items
					Set matched_relation_array = new ArrayClass
					Set matched_relations_ = new ArrayDictionary

					For Each  item_in_queue  In  queue.Items
						full_path_in_queue = Me.Variables.GetFullPath( Trim2( item_in_queue.TargetLabel ),  Empty )

						Me_AddMatchedRelationFromMakeRule  matched_relation_array, _
							item_in_queue.TargetLabel,  full_path_in_queue,  rule
							'// Set "matched_relation_array"
					Next
					For Each  matched_relation  In  matched_relation_array.Items
						index_of_revision_set = matched_relation.RevisionSetIndex

						matched_relations_.Add  index_of_revision_set,  matched_relation
						If matched_relations_.Dic( index_of_revision_set ).Count >= 2 Then _
							matched_relations_.Dic( index_of_revision_set )( 0 ).MatchedIndexes.AddElems _
								matched_relation.MatchedIndexes
					Next
					For Each  index_of_revision_set  In  matched_relations_.Dic.Keys
						matched_revision_count = matched_relations_.Dic( index_of_revision_set ).Count
						If matched_revision_count > max_matched_revision_count Then

							best_relation.ToEmpty
							max_matched_revision_count = matched_revision_count
						End If
						If matched_revision_count >= max_matched_revision_count Then
							Set matched_relation = matched_relations_.Dic( index_of_revision_set )( 0 )

							best_relation.Add  matched_relation
						End If
					Next
				Next
				If best_relation.Count >= 2 Then
					message = ""
					For Each  relation  In  best_relation.Items
						If IsEmpty( relation.MatchedIndexes ) Then
							matching_message = "matched_revision="""+ relation.Revision
						Else
							matching_message = "revision_set="""+ Replace( new_ArrayClass( _
								relation.RevisionSet ).CSV,  ",",  ", " ) + _
								"""  matched_indexes="""+ Replace( _
								relation.MatchedIndexes.CSV,  ",",  ", " )
						End If
						message = message +"    <MakeRule  first_path="""+ relation.MakeRule.Label + _
							"""  "+ matching_message +"""/>"+ vbCRLF
					Next

					Raise  1, "<ERROR msg="""+ _
						"複数の MakeRule でマッチした Output（の数）が同じなので、MakeRule を選べません。"""+ _
						vbCRLF +"  matched_count="""+ CStr( max_matched_revision_count ) + _
						"""  expanding="""+ expanding_path +""">"+ vbCRLF + message +"</ERROR>"
				End If

				Set relations(0) = best_relation(0)
				relations(0).TargetLabel = expanding_label
				relations.ReDim_  0
			End If


			'// Expand
			If relations.Count = 1 Then
				sub_index = 1
				Set relation = GetFirst( relations.Items )
				Set rule = relation.MakeRule
				Set queue( queue_index ) = relation  '// Full relation

				If False Then  '// For debug
					echo_v  ""
					For Each  relation_  In  queue.Items
						echo_v  relation_.TargetLabel
					Next
				End If


				'// Add from "rule.Inputs"
				For Each  input_path  In  rule.Inputs.Keys
					If not IsEmpty( relation.Revision ) Then
						CutLastOf  input_path,  "\*",  Empty
						input_path = input_path +"\"+ relation.Revision
					ElseIf not IsEmpty( relation.RevisionSet ) Then
						path_index = rule.Inputs( input_path )
						CutLastOf  input_path,  "\*",  Empty
						input_path = input_path +"\"+ relation.RevisionSet( path_index )
					Else
						Error
					End If
					input_full_path = Me.Variables( input_path )

					If expanded( input_full_path ) Then _
						input_path = "+ "+ input_path
					Set temporary_relation = new MakeRelation_OfRevisionFolder_Class
					temporary_relation.TargetLabel = String( nest_level + 1, vbTab ) + input_path

					queue.Insert  queue_index + sub_index,  temporary_relation
					sub_index = sub_index + 1
				Next

				queue_index = queue_index + sub_index


			'// Cannot Expand
			Else  '// If relations.Count = 0 Then
				Set temporary_relation = new MakeRelation_OfRevisionFolder_Class
				temporary_relation.TargetLabel = expanding_label

				Set queue( queue_index ) = temporary_relation

				no_relation_count = no_relation_count + 1
			End If
		End If

		queue_index = queue_index - 1
	Loop

	If queue.Count = 1  and  no_relation_count = 1 Then
		Raise  E_NotFoundMakeRuleTag,  "<ERROR msg=""Not found MakeRule tag for target output""  target="""+ _
			in_TargetWithRevisionPath +"""/>"
	End If

	Set Me_GetMakeRelations_Sub = queue
End Function


 
'***********************************************************************
'* Method: Me_AddMatchedRelationFromMakeRule
'*
'* Name Space:
'*    MakeRuleSetOfRevisionFolderClass::Me_AddMatchedRelationFromMakeRule
'***********************************************************************
Private Sub  Me_AddMatchedRelationFromMakeRule( in_out_Relations, _
		in_TargetPathWithTab,  in_TargetFullPath,  in_MakeRule )

	'// Search matched revision in "in_MakeRule.Outputs" by <Revisions> tag
	If not IsEmpty( in_MakeRule.Revisions ) Then

		For Each  output_path  In  in_MakeRule.Outputs.Keys
			output_full_path = Me.Variables( output_path )
			CutLastOf  output_full_path,  "\*",  Empty

			For Each  revision  In  in_MakeRule.Revisions

				If StrComp( output_full_path +"\"+ revision,  in_TargetFullPath,  1 ) = 0 Then
					Set relation = new MakeRelation_OfRevisionFolder_Class
					relation.TargetLabel = in_TargetPathWithTab
					Set relation.MakeRule = in_MakeRule
					relation.Revision = revision
					relation.UpdateCommand  Me.Variables

					in_out_Relations.Add  relation
					Exit For
				End If
			Next
		Next
	End If


	'// Search matched revision in "in_MakeRule.Outputs" by <RevisionSets> tag
	If in_MakeRule.RevisionSets.Count >= 1 Then
		index_of_set = 0

		For Each  revision_set  In  in_MakeRule.RevisionSets.Items

			For Each  output_path  In  in_MakeRule.Outputs.Keys
				output_full_path = Me.Variables( output_path )
				CutLastOf  output_full_path,  "\*",  Empty
				path_index = in_MakeRule.Outputs( output_path )
				revision = revision_set( path_index )

				If StrComp( output_full_path +"\"+ revision,  in_TargetFullPath,  1 ) = 0 Then
					Set relation = new MakeRelation_OfRevisionFolder_Class
					relation.TargetLabel = in_TargetPathWithTab
					Set relation.MakeRule = in_MakeRule
					relation.RevisionSet = revision_set
					relation.RevisionSetIndex = index_of_set
					Set relation.MatchedIndexes = new_ArrayClass( path_index )
					relation.UpdateCommand  Me.Variables

					in_out_Relations.Add  relation
					Exit For
				End If
			Next
			index_of_set = index_of_set + 1
		Next
	End If
End Sub


 
'* Section: End_of_Class
End Class


 
'***********************************************************************
'* Class: MakeRule_OfRevisionFolder_Class
'*    This instance must be created in <OpenForMakeRuleOfRevisionFolder>.
'***********************************************************************
Class  MakeRule_OfRevisionFolder_Class
	Public  Paths      '// as ArrayClass of string. Full paths.  Outputs and Inputs
	Public  Outputs    '// as dictionary of Index, key = path of target/destination in make tool
	Public  Inputs     '// as dictionary of Index, key = path of source in make tool
	Public  Command             '// as string or Empty
	Public  CurrentFolder       '// as string or Empty
	Public  ExpectedErrorLevel  '// as string or Empty
	Public  Revisions     '// as array of string
	Public  RevisionSets  '// as ArrayClass of array of string

	Private Sub  Class_Initialize()
		Set Me.Paths = new ArrayClass
		Set Me.Outputs = CreateObject( "Scripting.Dictionary" )
		Set Me.Inputs  = CreateObject( "Scripting.Dictionary" )
		Set Me.RevisionSets = new ArrayClass
	End Sub

	Public Property Get  Label() '// as string
		Label = GetFirst( Me.Outputs )
	End Property


 
'* Section: End_of_Class
End Class


 
'***********************************************************************
'* Class: MakeRelation_OfRevisionFolder_Class
'*    This instance must be created in <OpenForMakeRuleOfRevisionFolder>.
'***********************************************************************
Class  MakeRelation_OfRevisionFolder_Class
	Public  TargetLabel       '// as string. With tab and variable.
	Public  MakeRule          '// as MakeRule_OfRevisionFolder_Class
	Public  Revision          '// as Empty or string
	Public  RevisionSet       '// as Empty or array of string
	Public  RevisionSetIndex  '// as Empty or integer
	Public  MatchedIndexes    '// as ArrayClass of integer
	Public  Command           '// as string. See "Me.UpdateCommand"


'***********************************************************************
'* Method: UpdateCommand
'*    Update "Me.Command" line that is expanded variables in it.
'*
'* Name Space:
'*    MakeRelation_OfRevisionFolder_Class::UpdateCommand
'***********************************************************************
Public Sub  UpdateCommand( in_GlobalVariables )
	Set local_variables = new LazyDictionaryClass

	For Each  path  In  Me.MakeRule.Outputs.Keys
		full_path = in_GlobalVariables( path )  '// TODO: Is it slow than MakeRule.Path ?
		CutLastOf  full_path,  "\*",  Empty
		path_index = Me.MakeRule.Outputs( path )
		If not IsEmpty( Me.Revision ) Then
			revision_ = Me.Revision
		Else
			revision_ = Me.RevisionSet( path_index )
		End If

		local_variables( "${Revision["+ CStr( path_index ) +"]}" ) = revision_
		local_variables( "${Output["+ CStr( path_index ) +"]}" ) = GetStepPath( _
			full_path +"\Work",  Me.MakeRule.CurrentFolder )
	Next

	For Each  path  In  Me.MakeRule.Inputs.Keys
		full_path = in_GlobalVariables( path )  '// TODO: Is it slow than MakeRule.Path ?
		CutLastOf  full_path,  "\*",  Empty
		path_index = Me.MakeRule.Inputs( path )
		If not IsEmpty( Me.Revision ) Then
			revision_ = Me.Revision
		Else
			revision_ = Me.RevisionSet( path_index )
		End If

		local_variables( "${Revision["+ CStr( path_index ) +"]}" ) = revision_
		local_variables( "${Input["+ CStr( path_index ) +"]}" ) = GetStepPath( _
			full_path +"\Work",  Me.MakeRule.CurrentFolder )
	Next

	Set total_variables = new LazyDictionaryClass
	total_variables.AddDictionary  in_GlobalVariables
	total_variables.AddDictionary  local_variables

	Me.Command = Trim2( total_variables( Me.MakeRule.Command ) )
End Sub


 
'* Section: End_of_Class
End Class


 
'***********************************************************************
'* Function: MakeDocumentByNaturalDocs
'***********************************************************************
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
	Set cs = new_TextFileCharSetStack( c.UTF_8_No_BOM )  '// Change character code
	CreateFile  Rule.Target, text
End Sub


 
'***********************************************************************
'* Function: MakeDocumentBy_doxygen
'***********************************************************************
Sub  MakeDocumentBy_doxygen( SourceRootPath, DocumentRootPath, Options )
	echo  ">MakeDocumentBy_doxygen  """+ SourceRootPath +""", """+ _
		DocumentRootPath +""""
	Set ec = new EchoOff

	AssertExist  SourceRootPath
	g_AppKey.CheckWritable  DocumentRootPath, Empty

	CheckSettingFunctionExists  "Setting_getDoxygenPath"
	doxygen_exe = Setting_getDoxygenPath()

	temporary_project_path = GetTempPath( "doxygenProject_"+ _
		new_BinaryArrayAsText( SourceRootPath, "Unicode" ).MD5 )

	If not exist( DocumentRootPath ) Then
		del  temporary_project_path
	End If

	mkdir  temporary_project_path
	mkdir  DocumentRootPath
	document_full_path = GetFullPath( DocumentRootPath, Empty )

	ec = Empty


	echo  "Copy and changing to UTF-8 character set ..."
	Set mk = new MakeFileClass
	mk.AddRule  new_MakeDocumentBy_doxygen_SourceCopyRules( SourceRootPath, _
		temporary_project_path +"\src" )
	mk.Make

	Set ds = new CurDirStack
	pushd  temporary_project_path

	If not g_fs.FileExists( temporary_project_path +"\Doxyfile" ) Then
		RunProg  """"+ doxygen_exe +""" -g",  g_VBS_Lib.NotEchoStartCommand

		Set  file = OpenForReplace( temporary_project_path +"\Doxyfile", Empty )
		file.Replace  "EXTRACT_ALL            = NO",   "EXTRACT_ALL = YES"
		file.Replace  "GENERATE_LATEX         = YES",  "GENERATE_LATEX = NO"
		file.Replace  "RECURSIVE              = NO",   "RECURSIVE = YES"
		file.Replace  "OPTIMIZE_OUTPUT_FOR_C  = NO",   "OPTIMIZE_OUTPUT_FOR_C = YES"
		file.Replace  "HTML_OUTPUT            = html", "HTML_OUTPUT = """+ document_full_path +""""
		file = Empty
	End If

	RunProg  """"+ doxygen_exe +"""",  G_VBS_Lib.NotEchoStartCommand
End Sub


Function  new_MakeDocumentBy_doxygen_SourceCopyRules( SourceRootPath, UTF_8_SourceRootPath )
	If IsEmpty( g_Vers("doxygenExtension") ) Then
		Set g_Vers("doxygenExtension") = Dic_addFromArray( Empty, Array( _
			"h", "c", "hpp", "cpp", "java", "php", "py", _
			"f", "F90", "F95", "for", "d" ), True )
	End If

	ReDim  rules( g_Vers("doxygenExtension").Count - 1 )
	rule_num = 0
	For Each  extension  In g_Vers("doxygenExtension").Keys
		Set o = new MakeRule
			o.Sources = Array( GetPathWithSeparator( SourceRootPath ) +"*."+ extension )
			o.Target = GetPathWithSeparator( UTF_8_SourceRootPath ) +"*."+ extension
			Set o.Command = GetRef("MakeDocumentBy_doxygen_SourceCopyRules_Command")
		Set rules( rule_num ) = o
		rule_num = rule_num + 1
	Next
	new_MakeDocumentBy_doxygen_SourceCopyRules = rules
End Function
Sub  MakeDocumentBy_doxygen_SourceCopyRules_Command( Param, Rule )
	Set c = g_VBS_Lib
	source_path = Rule.Sources(0)
	text = ReadFile( source_path )
	Set cs = new_TextFileCharSetStack( c.UTF_8_No_BOM )  '// Change character code
	CreateFile  Rule.Target, text
End Sub


 
'***********************************************************************
'* Function: ConvertDocumetCommentFormat
'***********************************************************************
Sub  ConvertDocumetCommentFormat( InputPath, OutputPath, InputFormat, OutputFormatFilePath )
	echo  ">ConvertDocumetCommentFormat"
	Set ec = new EchoOff

	Assert  InputFormat = "NaturalDocs"

	Set xml = new StringStream
	For Each  a_pair  In  GetInputOutputFilePaths( InputPath, OutputPath, "ConvertingDCF_*.txt" )
		If g_Vers("NaturalDocsExtension").Exists( g_fs.GetExtensionName( a_pair.InputPath ) ) Then
			xml.WriteLine  "<File"
			xml.WriteLine  "    input ="""+ a_pair.InputPath +""""
			If not a_pair.IsOutputPathTemporary Then
				xml.WriteLine  "    output="""+ a_pair.OutputPath +""""
			End If
			xml.WriteLine  "/>"
		End If
	Next

	setting_path = GetTempPath( "DCFormatSetting_*.xml" )
	AssertExist  OutputFormatFilePath
	text = ReadFile( OutputFormatFilePath )
	text = Replace( text, "encoding=""Shift-JIS""", "encoding=""UTF-16""" )
	text = Replace( text, "<DocumetCommentFormat>", "<ConvertDocumetCommentFormat>" + vbCRLF + xml.ReadAll() )
	text = Replace( text, "</DocumetCommentFormat>", "</ConvertDocumetCommentFormat>" )
	OpenForWrite( setting_path, g_VBS_Lib.Unicode ).Write  text

	ec = Empty

	r= RunProg( """"+ g_vbslib_ver_folder +"vbslib_helper.exe"" ConvertDocumentCommentFormat """+ _
		setting_path +"""",  g_VBS_Lib.NotEchoStartCommand )
	Assert  r = 0

	Set ec = new EchoOff

	del  setting_path
End Sub


 
'***********************************************************************
'* Function: diff
'***********************************************************************
Function  diff( in_LeftPath,  in_RightPath,  in_OutputPath,  in_out_Option )
	echo  ">diff"
	echo  "    Left="""+ in_LeftPath +""""
	echo  "   Right="""+ in_RightPath +""""
	echo  "  Output="""+ in_OutputPath +""""
	Set ec = new EchoOff
	Set c = g_VBS_Lib
	Set tc = get_ToolsLibConsts()
	If not IsEmpty( in_OutputPath ) Then
		g_AppKey.CheckWritable  in_OutputPath, Empty
		out_path = GetFullPath( in_OutputPath, Empty )
	End If

	Set ds = new CurDirStack
	diff_exe = Setting_getDiffPath()

	left_path         = GetFullPath( in_LeftPath, Empty )
	right_path        = GetFullPath( in_RightPath, Empty )
	work_folder_path  = GetTempPath( "diff_*" )
	mkdir  work_folder_path


	'// For short command line and no space parameters
	'// Convert character code set
	pushd  work_folder_path
	left_text  = ReadFile( left_path )
	right_text = ReadFile( right_path )
	Set cs = new_TextFileCharSetStack( "UTF-7" )

	CreateFile  "Left.txt", left_text
	CreateFile  "Right.txt", right_text
	cs = Empty


	'// Convert return code
	Set cs = new_TextFileCharSetStack( "ISO-8859-1" )
	a_UTF_7_CR = "+AA0-"
	left_text  = ReadFile( "Left.txt" )
	right_text = ReadFile( "Right.txt" )
	left_text  = Replace( left_text,  vbCR, a_UTF_7_CR + vbCR )
	right_text = Replace( right_text, vbCR, a_UTF_7_CR + vbCR )
	If Right( left_text,  1 ) <> vbLF Then  left_text  = left_text  + vbCRLF
	If Right( right_text, 1 ) <> vbLF Then  right_text = right_text + vbCRLF

	CreateFile  "Left.txt",  left_text
	CreateFile  "Right.txt", right_text


	'// ...
	If IsBitNotSet( in_out_Option,  tc.DiffForPatch ) Then

		r= RunProg( """"+ diff_exe +""" -u  Left.txt  Right.txt",  "DiffOut.txt" )

		'// ...
		Set diffs = ParseUnifiedDiff( ReadFile( "DiffOut.txt" ), c.UTF_7 )
		diffs.MinusStepPath = in_LeftPath
		diffs.PlusStepPath  = in_RightPath
		diffs.MakeTaggedDiffText  "Left.txt",  "Right.txt",  "DiffOut.txt"
	Else
		r= RunProg( """"+ diff_exe +""" -u2prN  Left.txt  Right.txt",  "DiffOut.txt" )
	End If


	'// Convert character code set
	'// Convert return code
	'// Call "ThreeWayMerge_autoMergeExSub"
	text = ReadFile( "DiffOut.txt" )

	If ReadLineSeparator( right_path ) = vbCRLF Then
		text = Replace( text, "="+ vbCRLF, "="+ vbCR + vbCRLF )
		text = Replace( text, "t"+ vbCRLF, "t"+ vbCR + vbCRLF )
	End If
	text = Replace( text, vbCRLF, vbLF )
	text = Replace( text, a_UTF_7_CR, vbCR )

	If IsBitNotSet( in_out_Option,  tc.DiffForPatch ) Then
		text = Replace( text,       "<<<<<<< ",       "+ADwAPAA8ADwAPAA8ADw- " )
		text = Replace( text, vbLF+ "||||||| ", vbLF+ "+AHwAfAB8AHwAfAB8AHw- " )
		text = Replace( text, vbLF+ "=======",  vbLF+ "+AD0APQA9AD0APQA9AD0-" )
		text = Replace( text, vbLF+ ">>>>>>> ", vbLF+ "+AD4APgA+AD4APgA+AD4- " )
	Else
		cs = Empty

		Set matches = new_RegExp( "^(---|\+\+\+) .*", True ).Execute( text )
		For Each  match  In  matches
			sub_texts = sub_texts + match.Value + vbCRLF
		Next
		Set cs = new_TextFileCharSetStack( "UTF-7" )
		CreateFile  "DiffOutSub.txt",  sub_texts
		cs = Empty

		Set cs = new_TextFileCharSetStack( "ISO-8859-1" )
		Set file = OpenForRead( "DiffOutSub.txt" )
		For Each  match  In  matches
			text_UTF7 = file.ReadLine()
			If Left( text_UTF7, 2 ) = "+-" Then _
				text_UTF7 = "+"+ Mid( text_UTF7, 3 )
			text = Replace( text,  match.Value + vbLF,  text_UTF7 + vbLF )
		Next
		file = Empty

		text = new_RegExp( "^\+(.*)", True ).Replace( text, "+-$1" )
		text = new_RegExp( "^@@ (.*)\+(.*) @@$", True ).Replace( text, "+AEAAQA- $1+-$2 +AEAAQA-" )
	End If

	CreateFile  "DiffOut.txt", text
	cs = Empty

	Set cs = new_TextFileCharSetStack( "UTF-7" )
	text = ReadFile( "DiffOut.txt" )
	cs = Empty

	If text = "" Then  '// If left file is same as right file.
		text = ReadFile( left_path )
	End If

	If IsEmpty( in_OutputPath ) Then
		diff = text
	Else
'// 2016-12-05		Set cs = new_TextFileCharSetStack( ReadUnicodeFileBOM( "Left.txt" ) )
		Set cs = new_TextFileCharSetStack( AnalyzeCharacterCodeSet( "Left.txt" ) )
		CreateFile  out_path, text
		cs = Empty
	End If

	popd
	del  work_folder_path
End Function


 
'***********************************************************************
'* Function: patch
'***********************************************************************
Sub  patch( in_OldPath,  in_DiffFilePath,  in_OutputPath,  in_out_Option )
	echo  ">patch"
	echo  "     Old="""+ in_OldPath +""""
	echo  "    Diff="""+ in_DiffFilePath +""""
	echo  "  Output="""+ in_OutputPath +""""
	Set ec = new EchoOff
	Set c = g_VBS_Lib
	Set tc = get_ToolsLibConsts()
	If not IsEmpty( in_OutputPath ) Then
		g_AppKey.CheckWritable  in_OutputPath, Empty
		out_path = GetFullPath( in_OutputPath, Empty )
	End If

	Set ds = new CurDirStack
	patch_exe = Setting_getPatchPath()

	old_path         = GetFullPath( in_OldPath, Empty )
	diff_file_path   = GetFullPath( in_DiffFilePath, Empty )
	work_folder_path = GetTempPath( "diff_*" )
	mkdir  work_folder_path


	'// For short command line and no space parameters
	'// Convert character code set
	pushd  work_folder_path
	old_text  = ReadFile( old_path )
	diff_text = ReadFile( diff_file_path )
	Set cs = new_TextFileCharSetStack( "UTF-7" )

	CreateFile  "Old.txt", old_text
	CreateFile  "Diff.txt", diff_text
	cs = Empty


	'// Convert return code
	Set cs = new_TextFileCharSetStack( "ISO-8859-1" )
	a_UTF_7_CR = "+AA0-"
	old_text  = ReadFile( "Old.txt" )
	diff_text = ReadFile( "Diff.txt" )
	old_text  = Replace( old_text,  vbCR, a_UTF_7_CR + vbCR )
	diff_text = Replace( diff_text, vbCR, a_UTF_7_CR + vbCR )
	If Right( old_text,  1 ) <> vbLF Then  old_text  = old_text  + vbCRLF
	If Right( diff_text, 1 ) <> vbLF Then  diff_text = diff_text + vbCRLF

	CreateFile  "Replacing.txt",  old_text


	'// Return diff tags to Ascii code
	text = diff_text
	text = new_RegExp( "^--- (.*)\+-([0-9]+)$", True ).Replace( text, "--- $1+$2"+ vbCR )
	text = new_RegExp( "^\+-\+-\+- (.*)\+-([0-9]+)$", True ).Replace( text, "+++ $1+$2"+ vbCR )
	text = new_RegExp( "^(\+-\+-\+-) (.*)", True ).Replace( text, "+++ $2"+ vbCR )
	text = new_RegExp( "^\+-", True ).Replace( text, "+" )
	text = new_RegExp( "^\+AEAAQA- (.*)\+-(.*) \+AEAAQA-$", True ).Replace( text, "@@ $1+$2 @@"+ vbCR )

	CreateFile  "Diff.txt", text


	'// ...
	r= RunProg( """"+ patch_exe +""" -u  Replacing.txt  Diff.txt",  "Log.txt" )


	'// Convert character code set
	'// Convert return code
	'// Call "ThreeWayMerge_autoMergeExSub"
	text = ReadFile( "Replacing.txt" )

	If ReadLineSeparator( diff_file_path ) = vbCRLF Then
		text = Replace( text, "="+ vbCRLF, "="+ vbCR + vbCRLF )
		text = Replace( text, "t"+ vbCRLF, "t"+ vbCR + vbCRLF )
	End If
	text = Replace( text, vbCRLF, vbLF )
	text = Replace( text, a_UTF_7_CR, vbCR )

	text = Replace( text,       "<<<<<<< ",       "+ADwAPAA8ADwAPAA8ADw- " )
	text = Replace( text, vbLF+ "||||||| ", vbLF+ "+AHwAfAB8AHwAfAB8AHw- " )
	text = Replace( text, vbLF+ "=======",  vbLF+ "+AD0APQA9AD0APQA9AD0-" )
	text = Replace( text, vbLF+ ">>>>>>> ", vbLF+ "+AD4APgA+AD4APgA+AD4- " )

	CreateFile  "NewOut.txt", text
	cs = Empty

	Set cs = new_TextFileCharSetStack( "UTF-7" )
	text = ReadFile( "NewOut.txt" )
	cs = Empty

	If text = "" Then  '// If left file is same as right file.
		text = ReadFile( old_path )
	End If

	If IsEmpty( in_OutputPath ) Then
		diff = text
	Else
'// 2016-12-05		Set cs = new_TextFileCharSetStack( ReadUnicodeFileBOM( "Old.txt" ) )
		Set cs = new_TextFileCharSetStack( AnalyzeCharacterCodeSet( "Old.txt" ) )
		CreateFile  out_path, text
		cs = Empty
	End If

	popd
	del  work_folder_path
End Sub


 
'***********************************************************************
'* Function: ParseUnifiedDiff
'*
'* Arguments:
'*    in_CharSet - Empty or g_VBS_Lib.UTF_7.
'*
'* Return Value:
'*    <UnifiedDiffClass>.
'***********************************************************************
Function  ParseUnifiedDiff( ByVal in_DiffText, in_CharSet )
	Set out = new UnifiedDiffClass
	Set out.Differences = new ArrayClass
	If in_DiffText <> "" Then
		If in_CharSet = g_VBS_Lib.UTF_7 Then
			position = InStr( in_DiffText,  vbLF )
			position = InStr( position + 1,  in_DiffText,  vbLF )
			header = Left( in_DiffText, position )
			not_header = Mid( in_DiffText, position )

			header = Replace( header, "+", "+-" )

			If IsEmpty( g_ParseUnifiedDiff_RegExp_AtAt ) Then
				Set re = new_RegExp( "^@@ -([0-9,]+) \+([0-9,]+) @@", True )
				Set g_ParseUnifiedDiff_RegExp_AtAt = re
			Else
				Set re = g_ParseUnifiedDiff_RegExp_AtAt
			End If

			not_header = Replace( not_header,  vbLF +"+",  vbLF +"+-" )
			not_header = re.Replace( not_header, "+AEAAQA- -$1 +-$2 +AEAAQA-" )

			in_DiffText = header + not_header

			temporary_path = GetTempPath( "ParseUnifiedDiff_*.txt" )
			Set cs = new_TextFileCharSetStack( "ISO-8859-1" )
			CreateFile  temporary_path,  in_DiffText
			cs = Empty

			Set cs = new_TextFileCharSetStack( "UTF-7" )
			in_DiffText = ReadFile( temporary_path )
			cs = Empty

			del  temporary_path
		End If

		pos = 1  '// pos = position
		If Left( in_DiffText, 4 ) = "--- " Then
			pos = pos + 4
			out.MinusStepPath = Mid( in_DiffText,  pos,  InStr( pos, in_DiffText, vbTab ) - pos )

			pos = InStr( in_DiffText,  vbLF +"+++ " )
			pos = pos + 5
			out.PlusStepPath = Mid( in_DiffText,  pos,  InStr( pos, in_DiffText, vbTab ) - pos )
		End If

		Do
			'// Parse "@@ -1,2 +3,4 @@"
			nums_start = InStr( pos, in_DiffText, vbLF +"@" )
			nums_over  = InStr( nums_start + 3, in_DiffText, "@" )

			Set nums = ScanFromTemplate(_
				Mid( in_DiffText, nums_start, nums_over - nums_start ),_
				"@@ -${Minus} +${Plus} ",_
				Array( "${Minus}", "${Plus}" ), Empty )

			range = nums("${Minus}")
			comma = InStr( range, "," )
			If comma >= 1 Then
				minus_num  = CInt2( Left( range, comma - 1 ) )
			Else
				minus_num  = CInt2( range )
			End If

			range = nums("${Plus}")
			comma = InStr( range, "," )
			If comma >= 1 Then
				plus_num  = CInt2( Left( range, comma - 1 ) )
			Else
				plus_num  = CInt2( range )
			End If

			pos = nums_over

			Do
				pos = InStr( pos, in_DiffText, vbLF )
				If pos = 0 Then  Exit Do

				sign = Mid( in_DiffText, pos + 1, 1 )

				If sign = "@" Then
					Exit Do
				ElseIf sign <> " "  and  sign <> "" Then
					If IsEmpty( one ) Then
						Set one = new UnifiedOneDifferenceClass
						one.MinusStart = minus_num
						one.PlusStart = plus_num
					End If
				Else
					If not IsEmpty( one ) Then
						one.MinusOver = minus_num
						one.PlusOver = plus_num
						out.Differences.Add  one
						one = Empty
					End If
				End If

				Select Case  sign
					Case " "
						minus_num = minus_num + 1
						plus_num = plus_num + 1
					Case "+"
						plus_num = plus_num + 1
					Case "-"
						minus_num = minus_num + 1
				End Select

				pos = pos + 1
			Loop
			If pos = 0 Then  Exit Do
		Loop
	End If
	out.Differences = out.Differences.Items
	Set ParseUnifiedDiff = out
End Function


 
'***********************************************************************
'* Variable: g_ParseUnifiedDiff_RegExp_AtAt
'***********************************************************************
Dim  g_ParseUnifiedDiff_RegExp_AtAt


 
'***********************************************************************
'* Class: UnifiedDiffClass
'***********************************************************************
Class  UnifiedDiffClass
	Public  MinusStepPath
	Public  PlusStepPath
	Public  Differences  '// as array of UnifiedOneDifferenceClass


 
'***********************************************************************
'* Method: MakeTaggedDiffText
'*
'* Name Space:
'*    UnifiedDiffClass::MakeTaggedDiffText
'***********************************************************************
Public Function  MakeTaggedDiffText( in_MinusPath,  in_PlusPath,  in_OutPath )
	If UBound( Me.Differences ) = -1 Then
		MakeTaggedDiffText = ReadFile( in_MinusPath )
		Exit Function
	End If


	Set ls = new_TextFileLineSeparatorStack( g_VBS_Lib.KeepLineSeparators )

	Set minus_file = OpenForRead( in_MinusPath )
	Set plus_file  = OpenForRead( in_PlusPath )
	If IsEmpty( in_OutPath ) Then
		Set writing_file = new StringStream
	Else
'// 2016-12-05		Set writing_file = OpenForWrite( in_OutPath, ReadUnicodeFileBOM( in_MinusPath ) )
		Set writing_file = OpenForWrite( in_OutPath, AnalyzeCharacterCodeSet( in_MinusPath ) )
	End If

	difference_num = 0
	tag_line_num = Me.Differences( difference_num ).MinusStart

	line_num = 1
	Do Until  minus_file.AtEndOfStream  and  plus_file.AtEndOfStream
		If line_num = tag_line_num Then
			over_line_num = Me.Differences( difference_num ).MinusOver
			If tag_line_num = over_line_num Then
				writing_file.Write  "<<<<<<< "+ Me.MinusStepPath + vbCRLF
			Else  '// tag_line_num < over_line_num

				minus_line = minus_file.ReadLine()
				line_feed = Right( minus_line, 2 )
				If line_feed <> vbCRLF Then _
					line_feed = vbLF

				writing_file.Write  "<<<<<<< "+ Me.MinusStepPath + line_feed
				Do
					writing_file.Write  minus_line
					line_num = line_num + 1
					If line_num >= over_line_num Then _
						Exit Do
					minus_line = minus_file.ReadLine()
				Loop
			End If

			line_count = Me.Differences( difference_num ).PlusOver - _
				Me.Differences( difference_num ).PlusStart
			If line_count = 0 Then
				writing_file.Write  "======="+ vbCRLF
			Else
				plus_line  = plus_file.ReadLine()
				line_feed = Right( plus_line, 2 )
				If line_feed <> vbCRLF Then _
					line_feed = vbLF

				writing_file.Write  "======="+ line_feed
				Do
					writing_file.Write  plus_line
					line_count = line_count - 1
					If line_count = 0 Then _
						Exit Do
					plus_line = plus_file.ReadLine()
				Loop
			End If

			writing_file.Write  ">>>>>>> "+ Me.PlusStepPath + line_feed
			difference_num = difference_num + 1
			If difference_num > UBound( Me.Differences ) Then _
				Exit Do
			tag_line_num = Me.Differences( difference_num ).MinusStart
		Else
			minus_line = minus_file.ReadLine()
			plus_line  = plus_file.ReadLine()

			writing_file.Write  minus_line
			line_num = line_num + 1
		End If
	Loop
	Do Until  minus_file.AtEndOfStream
		minus_line = minus_file.ReadLine()
		writing_file.Write  minus_line
	Loop

	If IsEmpty( in_OutPath ) Then _
		MakeTaggedDiffText = writing_file.ReadAll()
End Function


 
End Class
'* Section: Global


 
'***********************************************************************
'* Class: UnifiedOneDifferenceClass
'***********************************************************************
Class  UnifiedOneDifferenceClass
	Public  MinusStart
	Public  MinusOver
	Public  PlusStart
	Public  PlusOver
End Class


 
'* Section: Global


 
'***********************************************************************
'* Function: DiffWithoutKS
'*    Show difference without keyword substitution.
'***********************************************************************
Sub  DiffWithoutKS( in_PathA,  in_PathB,  in_PathC,  in_Option )
	echo  ">DiffWithoutKS  """+ in_PathA +""" """+ in_PathB +""""
	work_path = g_sh.SpecialFolders( "Desktop" ) +"\_DiffWithoutKS"
	Set ks_re = CreateObject( "VBScript.RegExp" )  '// ks_re = Keyword Substitution's Regular Expression
	ks_re.Pattern = "(\$[A-Za-z0-9]+::?)([^\$]*)\$"
	ks_re.Global = True
	ks_re.MultiLine = True
	Set ds = new CurDirStack

	If exist( work_path ) Then
		echo  work_path
		key = Input( "上記の古い作業用フォルダーを削除します。[Y/N]" )
		If key <> "y"  and  key <> "Y" Then _
			Error
		del  work_path
	End If
	Set ec = new EchoOff


	'// Set "paths_array"
	is_C_comparing = True
	If IsEmpty( in_PathC ) Then
		is_C_comparing = False
	ElseIf TypeName( in_Option ) = "DiffCmdLineOptionClass" Then
		If not in_Option.IsComparing(2) Then
			is_C_comparing = False
		End If
	End If
	If not is_C_comparing Then
		paths_array = Array( _
			Array( in_PathA,  work_path +"\A" ), _
			Array( in_PathB,  work_path +"\B" ) )
	Else
		paths_array = Array( _
			Array( in_PathA,  work_path +"\A" ), _
			Array( in_PathB,  work_path +"\B" ), _
			Array( in_PathC,  work_path +"\C" ) )
	End If


	'// ...
	For Each  paths  In  paths_array
		one_source_path = paths(0)
		one_work_path   = paths(1)

		pushd  one_source_path


		'// Set "paths"
		Set paths = CreateObject( "Scripting.Dictionary" )
		EnumFolderObjectDic  ".",  Empty,  folders  '// Set "folders"
		For Each  step_path  In  folders.Keys
			For Each  file  In  folders.Item( step_path ).Files
				If step_path = "." Then
					Set paths( file.Name ) = Nothing
				Else

					Set paths( step_path +"\"+ file.Name ) = Nothing
				End If
			Next
		Next

		founds = grep( "-r ""\$[A-Za-z0-9]+:[^\$]*\$"" ""*""", Empty )
		For Each  found  In  founds
			AssertD_TypeName  found, "GrepFound"
			If g_Vers("TextFileExtension").Exists( g_fs.GetExtensionName( found.Path ) ) Then

				Set paths( found.Path ) = found  '// Overwrite
			End If
		Next


		'// Copy or Replace files
		For Each  file_step_path  In  paths.Keys
			If paths( file_step_path ) is Nothing Then

				copy_ren  file_step_path,  one_work_path +"\"+ file_step_path
			Else
				Set file = OpenForReplace( file_step_path,  one_work_path +"\"+ file_step_path )
				Set matches = ks_re.Execute( file.Text )
				Reverse_COM_ObjectArray  matches,  matches_reverse
				For Each  match  In  matches_reverse
					If InStr( match.Value,  vbLF ) = 0 Then
						If Right( match.SubMatches(0),  2 ) <> "::" Then  '// "$KeywordSubstitution:"

							'// Replace to empty keyword substitution
							file.Text = Left( file.Text,  match.FirstIndex ) + _
								match.SubMatches(0) +" $" + _
								Mid( file.Text,  match.FirstIndex + 1 + match.Length )

						Else  '// "$KeywordSubstitution::"
							file.Text = Left( file.Text,  match.FirstIndex ) + _
								match.SubMatches(0) + String( Len( match.SubMatches(1) ), " " ) +"$" + _
								Mid( file.Text,  match.FirstIndex + 1 + match.Length )
						End If
					End If
				Next
				file = Empty
			End If
		Next
		popd
	Next
	If not IsEmpty( in_PathC )  and  not is_C_comparing Then
		copy  in_PathC +"\*",  work_path +"\C"
	End If

	text = ">DiffWithoutKS"+ vbCRLF + _
		"Path A = """+ GetFullPath( in_PathA,  Empty ) +""""+ vbCRLF + _
		"Path B = """+ GetFullPath( in_PathB,  Empty ) +""""+ vbCRLF
	If not IsEmpty( in_PathC ) Then _
		text = text + "Path C = """+ GetFullPath( in_PathC,  Empty ) +""""+ vbCRLF

	CreateFile  work_path +"\README.txt",  text


	'// Show a difference
	If IsEmpty( in_PathC ) Then
		start  GetDiffCmdLine( work_path +"\A",  work_path +"\B" )
	Else
		start  GetDiffCmdLine3Ex( work_path +"\A",  work_path +"\B",  work_path +"\C",  in_Option )
	End If
End Sub


 
'***********************************************************************
'* Function: ThreeWayMerge
'***********************************************************************
Sub  ThreeWayMerge( in_BasePath, in_LeftPath, in_RightPath, in_MergedOutputPath, in_out_Option )

	echo  ">ThreeWayMerge"
	echo  "    Base="""+ in_BasePath +""""
	echo  "    Left="""+ in_LeftPath +""""
	echo  "   Right="""+ in_RightPath +""""
	echo  "  Output="""+ in_MergedOutputPath +""""


	If exist( in_BasePath ) Then
		If exist( in_LeftPath ) Then
			If exist( in_RightPath ) Then

				ThreeWayMerge_Sub  in_BasePath, in_LeftPath, in_RightPath, _
					in_MergedOutputPath, in_out_Option

			Else
				copy_ren  in_LeftPath,  in_MergedOutputPath
			End If
		Else
			If exist( in_RightPath ) Then
				copy_ren  in_RightPath,  in_MergedOutputPath
			Else
				del  in_MergedOutputPath
			End If
		End If

	Else
		If not exist( in_LeftPath ) Then
			If not exist( in_RightPath ) Then
			Else
				copy_ren  in_RightPath,  in_MergedOutputPath
			End If
		Else
			If not exist( in_RightPath ) Then
				copy_ren  in_LeftPath,  in_MergedOutputPath
			Else


		'// TwoWayMerge
		Set ec = new EchoOff
		base_path = GetParentFullPath( in_MergedOutputPath )
		Set ds = new CurDirStack
		mkdir  base_path
		cd  base_path

		left_step_path   = GetStepPath( in_LeftPath,  base_path )
		right_step_path  = GetStepPath( in_RightPath,  base_path )
		output_step_path = GetStepPath( in_MergedOutputPath,  base_path )


		diff  left_step_path,  right_step_path,  output_step_path,  Empty
		text = ReadFile( in_MergedOutputPath )


		left_label = "Left."+ g_fs.GetExtensionName( in_LeftPath )
		base_label = "Base."+ g_fs.GetExtensionName( in_BasePath )
		right_label = "Right."+ g_fs.GetExtensionName( in_RightPath )


		For Each  c_LF  In Array( vbCRLF, vbLF )  '// c_LF = character_LF
			text = Replace( text, _
				"<<<<<<< "+ left_step_path + c_LF, _
				_
				"<<<<<<< "+ left_label + c_LF )
			text = Replace( text, _
				vbLF +"======="+ c_LF, _
				_
				vbLF +"||||||| "+ base_label + c_LF+ _
				"======="+ c_LF )
			text = Replace( text, _
				vbLF +">>>>>>> "+ right_step_path + c_LF, _
				_
				vbLF +">>>>>>> "+ right_label + c_LF )
		Next


		'// Call "ThreeWayMerge_autoMergeExSub"
		If in_out_Option.IsAutoMergeEx Then

			If not IsEmpty( in_out_Option.BreakStepNum ) Then
				in_out_Option.StepNum = in_out_Option.StepNum + 1
				If in_out_Option.StepNum >= in_out_Option.BreakStepNum Then
					echo_v  "StepNum = "+ CStr( in_out_Option.StepNum ) + _
					" : diff でマージしました。 続いて次のファイルの置き換えを開始します。"+ vbCRLF + _
						in_MergedOutputPath

					PauseForDebug
				End If
			End If


			Set merge = new ThreeWayMerge_AutoMergeExClass
			Set merge.Option_ = in_out_Option


			ThreeWayMerge_autoMergeExSub  text,  base_label,  left_label,  right_label,  merge


		End If

		Set file = OpenForReplace( in_MergedOutputPath, Empty )
		file.Text = text
		file = Empty


		'// Error
		If in_out_Option.IsEnableToRaiseConflictError Then
			If InStr( text, "<<<<<<< " ) >= 1 Then
				Raise  E_Conflict, "<ERROR msg=""Conflict"" path="""+ _
					GetFullPath( in_MergedOutputPath, Empty ) +"""/>"
			End If
		End If


			End If
		End If
	End If
End Sub


 
'***********************************************************************
'* Function: ThreeWayMerge_Sub
'***********************************************************************
Sub  ThreeWayMerge_Sub( in_BasePath, in_LeftPath, in_RightPath, in_MergedOutputPath, in_out_Option )

	AssertExist  in_BasePath  '// 2way merge is not supported
	AssertExist  in_LeftPath
	AssertExist  in_RightPath

	Set ec = new EchoOff
	g_AppKey.CheckWritable  in_MergedOutputPath, Empty
	If IsEmpty( in_out_Option ) Then  Set in_out_Option = new ThreeWayMergeOptionClass

	Set ds = new CurDirStack
	diff3_exe = Setting_getDiff3Path()

	base_path = GetFullPath( in_BasePath, Empty )
	left_path = GetFullPath( in_LeftPath, Empty )
	right_path = GetFullPath( in_RightPath, Empty )
	out_path = GetFullPath( in_MergedOutputPath, Empty )
	work_folder_path = GetTempPath( "ThreeWayMerge_*" )
	mkdir  work_folder_path


	'// "PauseForDebug"
	If not IsEmpty( in_out_Option.BreakStepNum ) Then
		in_out_Option.StepNum = in_out_Option.StepNum + 1
		If in_out_Option.StepNum >= in_out_Option.BreakStepNum Then
			echo_v  "StepNum = "+ CStr( in_out_Option.StepNum ) + _
				" : diff でマージを開始します。"+ vbCRLF + _
				"    ベースファイル = """+ base_path +""""

			PauseForDebug
		End If
	End If


	'// For short command line and no space parameters
	'// Convert character code set
	pushd  work_folder_path
	If base_path <> "" Then
		base_text = ReadFile( base_path )
	Else
		base_text = ""
	End If
	left_text = ReadFile( left_path )
	right_text = ReadFile( right_path )
	Set cs = new_TextFileCharSetStack( "UTF-7" )
	CreateFile  "Base.txt", base_text
	CreateFile  "Left.txt", left_text
	CreateFile  "Right.txt", right_text
	cs = Empty


	'// Convert return code
	Set cs = new_TextFileCharSetStack( "ISO-8859-1" )
	a_UTF_7_CR = "+AA0-"
	base_text  = ReadFile( "Base.txt" )
	left_text  = ReadFile( "Left.txt" )
	right_text = ReadFile( "Right.txt" )
	base_text  = Replace( base_text,  vbCR, a_UTF_7_CR + vbCR )
	left_text  = Replace( left_text,  vbCR, a_UTF_7_CR + vbCR )
	right_text = Replace( right_text, vbCR, a_UTF_7_CR + vbCR )
	If Right( base_text,  1 ) <> vbLF Then  base_text  = base_text  + vbCRLF
	If Right( left_text,  1 ) <> vbLF Then  left_text  = left_text  + vbCRLF
	If Right( right_text, 1 ) <> vbLF Then  right_text = right_text + vbCRLF
	CreateFile  "Base.txt", base_text
	CreateFile  "Left.txt", left_text
	CreateFile  "Right.txt", right_text


	'// Run execute file
	If not in_out_Option.IsAutoMergeEx Then
		r= RunProg( """"+ diff3_exe +""" -E -m  Left.txt  Base.txt  Right.txt", out_path )
	Else
		r= RunProg( """"+ diff3_exe +""" -A -m  Left.txt  Base.txt  Right.txt", out_path )
	End If


	'// Convert character code set
	'// Convert return code
	text = ReadFile( out_path )

	If ReadLineSeparator( right_path ) = vbCRLF Then
		text = Replace( text, "="+ vbCRLF, "="+ vbCR + vbCRLF )
		text = Replace( text, "t"+ vbCRLF, "t"+ vbCR + vbCRLF )
	End If
	text = Replace( text, vbCRLF, vbLF )
	text = Replace( text, a_UTF_7_CR, vbCR )

	text = Replace( text,       "<<<<<<< ",       "+ADwAPAA8ADwAPAA8ADw- " )
	text = Replace( text, vbLF+ "||||||| ", vbLF+ "+AHwAfAB8AHwAfAB8AHw- " )
	text = Replace( text, vbLF+ "=======",  vbLF+ "+AD0APQA9AD0APQA9AD0-" )
	text = Replace( text, vbLF+ ">>>>>>> ", vbLF+ "+AD4APgA+AD4APgA+AD4- " )

	CreateFile  out_path, text
	cs = Empty

	Set cs = new_TextFileCharSetStack( "UTF-7" )
	text = ReadFile( out_path )
	cs = Empty


	'// Call "ThreeWayMerge_autoMergeExSub"
	If in_out_Option.IsAutoMergeEx Then

		'// "PauseForDebug"
		If not IsEmpty( in_out_Option.BreakStepNum ) Then
			in_out_Option.StepNum = in_out_Option.StepNum + 1
			If in_out_Option.StepNum >= in_out_Option.BreakStepNum Then
				CreateFile  out_path, text
				FileWatcher_setNewFile
				FileWatcher_copyAFileToTheLog  out_path

				echo_v  "StepNum = "+ CStr( in_out_Option.StepNum ) + _
					" : diff でマージしました。 "+ _
					"続いて次のファイルのコンフリクトのタグを改良します。"+ vbCRLF + _
					"    ファイル = """+ out_path +""""

				PauseForDebug
			End If
		End If


		'// "ThreeWayMerge_autoMergeExSub"
		Set merge = new ThreeWayMerge_AutoMergeExClass
		Set merge.Option_ = in_out_Option
		ThreeWayMerge_autoMergeExSub  text, "Base.txt", "Left.txt", "Right.txt", merge

		If not merge.IsConflicted Then
			r = 0
		End If
	End If

'// 2016-12-05	Set cs = new_TextFileCharSetStack( ReadUnicodeFileBOM( right_path ) )
	Set cs = new_TextFileCharSetStack( AnalyzeCharacterCodeSet( right_path ) )
	CreateFile  out_path, text
	cs = Empty


	'// "PauseForDebug"
	If not IsEmpty( in_out_Option.BreakStepNum ) Then
		in_out_Option.StepNum = in_out_Option.StepNum + 1
		If in_out_Option.StepNum >= in_out_Option.BreakStepNum Then
			FileWatcher_copyAFileToTheLog  out_path

			echo_v  "StepNum = "+ CStr( in_out_Option.StepNum ) + _
				" : マージしました。"+ vbCRLF + _
				"    ファイル = """+ out_path +""""

			PauseForDebug
		End If
	End If


	'// Clean
	del  "Base.txt"
	del  "Left.txt"
	del  "Right.txt"
	popd


	'// Error
	If r <> 0 Then
		in_out_Option.IsConflictError = True
		If in_out_Option.IsEnableToRaiseConflictError Then
			Raise  E_Conflict, "<ERROR msg=""Conflict"" path="""+ out_path +"""/>"
		End If
	End If
End Sub


 
'***********************************************************************
'* Function: ThreeWayMerge_autoMergeExSub
'***********************************************************************
Sub  ThreeWayMerge_autoMergeExSub( in_out_Text, in_BaseFileName, in_LeftFileName, in_RightFileName, Me_ )
	If IsEmpty( Me_ ) Then  Set Me_ = new ThreeWayMerge_AutoMergeExClass

	left_bracket   = "<<<<<<< "

	If InStr( in_out_Text, left_bracket ) = 0 Then
		Exit Sub
	End If
	Me_.IsChanged = True


	'// Set conflict brackets
	base_bracket   = "||||||| "
	middle_bracket = "======="
	right_bracket  = ">>>>>>> "

	ReDim  bracket_A(3)
	ReDim  length_of_A(3)
	bracket_A(0) = left_bracket + in_LeftFileName
	bracket_A(1) = base_bracket + in_BaseFileName
	bracket_A(2) = middle_bracket
	bracket_A(3) = right_bracket + in_RightFileName
	For  i = 0  To  UBound( bracket_A )
		length_of_A(i) = Len( bracket_A(i) )
	Next

	ReDim  bracket_B(2)
	ReDim  length_of_B(2)
	bracket_B(0) = left_bracket + in_BaseFileName
	bracket_B(1) = middle_bracket
	bracket_B(2) = right_bracket + in_RightFileName
	For  i = 0  To  UBound( bracket_B )
		length_of_B(i) = Len( bracket_B(i) )
	Next


	If Me_.Option_.IsAutoMergeEx Then
		unique_line_keywords = Me_.Option_.UniqueLineKeywords
		For  i = 0  To  UBound( unique_line_keywords )
			Set unique_line_keywords(i) = new_RegExp( unique_line_keywords(i), False )
		Next

		singleton_keywords = Me_.Option_.SingletonKeywords
		For  i = 0  To  UBound( singleton_keywords )
			Set singleton_keywords(i) = new_RegExp( singleton_keywords(i), False )
		Next
	Else
		unique_line_keywords = Array( )
		singleton_keywords = Array( )
	End If


	'// AutoMerge for "bracket_A" set
	ReDim  start_positions(3)
	ReDim  over_positions(3)
	position = 1
	text = in_out_Text
	out_text = ""
	Do  '// Loop of bracket
		before_position = position

		'// Set "start_positions(n)", "over_positions(n)"
		For  bracket_index = 0  To  3
			ThreeWayMerge_SearchBracketSub  text, position, start_pos, _
				bracket_A( bracket_index ), length_of_A( bracket_index )
				'//(in_out) position
			If start_pos = 0 Then
				If bracket_index = 0 Then
					out_text = out_text + Mid( text, before_position )
					Exit Do
				Else
					Raise  E_Others, "diff が出力したコンフリクトの括弧の対応関係が正しくない"
				End If
			End If
			start_positions( bracket_index ) = start_pos
			over_positions( bracket_index ) = position
		Next


		'// Go to "start_positions(0)"
		out_text = out_text + Mid( text,  before_position,  start_positions(0) - before_position )


		'// <<<<<<< Left.txt
		'// (left_text)
		'// ||||||| Base.txt
		'// (base_text)
		'// =======
		'// (right_text)
		'// >>>>>>> Right.txt

		left_text  = Mid( text,  over_positions(0),  start_positions(1) - over_positions(0) )
		base_text  = Mid( text,  over_positions(1),  start_positions(2) - over_positions(1) )
		right_text = Mid( text,  over_positions(2),  start_positions(3) - over_positions(2) )


		'// Set "unique_keyword" : <UniqueLineKeywords>
		unique_keyword = Empty
		is_unique_keyword = False
		For Each  keyword  In unique_line_keywords
			If keyword.Test( left_text ) Then
				Set unique_keyword = keyword
				Exit For
			End If
			If keyword.Test( right_text ) Then
				Set unique_keyword = keyword
				Exit For
			End If
		Next


		'// Set "left_text", "right_text" for <UniqueLineKeywords>
		If not IsEmpty( unique_keyword ) Then
			For  i = 1  To  2
				If i = 1 Then
					adding_text = left_text
				Else
					adding_text = right_text
				End If


				over_position = start_positions(0)
				Do
					start_position = GetPreviousLinePosition( text, over_position )
					If start_position = 0 Then _
						Exit Do
					line = Mid( text, start_position, over_position - start_position )
					If not unique_keyword.Test( line ) Then _
						Exit Do

					adding_text = Replace( adding_text, line, "" )

					over_position = start_position
				Loop

				start_position = over_positions(3)
				Do
					over_position = InStr( start_position, text, vbLF ) + 1
					If over_position = 1 Then _
						Exit Do
					line = Mid( text, start_position, over_position - start_position )
					If not unique_keyword.Test( line ) Then _
						Exit Do

					adding_text = Replace( adding_text, line, "" )

					start_position = over_position
				Loop


				If i = 1 Then
					left_text = adding_text
				Else
					right_text = adding_text
				End If
			Next

			start_position = 1
			Do
				over_position = InStr( start_position, left_text, vbLF ) + 1
				If over_position = 1 Then _
					Exit Do
				line = Mid( left_text, start_position, over_position - start_position )
				If not unique_keyword.Test( line ) Then _
					Exit Do

				right_text = Replace( right_text, line, "" )

				start_position = over_position
			Loop
			is_unique_keyword = True
		End If


		'// Set "sigleton_keyword" : <SingletonKeywords>
		sigleton_keyword = Empty
		For Each  keyword  In  singleton_keywords
			If keyword.Test( left_text ) Then
				Set sigleton_keyword = keyword
				Exit For
			End If
			If keyword.Test( right_text ) > 0 Then
				Set sigleton_keyword = keyword
				Exit For
			End If
		Next


		'// Set "out_text" : "right_text"
		If not IsEmpty( sigleton_keyword ) Then
			out_text = out_text + right_text


		'// Set "out_text" : "left_text", "right_text"
		ElseIf Me_.Option_.IsOutEach  or  is_unique_keyword Then
			'// Set "return_code"
			If not IsEmpty( unique_keyword ) Then
				return_code = ""
			ElseIf Mid( text,  start_positions(1) - 2,  1 ) = vbCR Then
				return_code = vbCRLF
			Else
				return_code = vbLF
			End If


			'// Set "out_text"
			If left_text = "" Then
				out_text = out_text + right_text
			ElseIf right_text = "" Then
				out_text = out_text + left_text
			Else
				out_text = out_text + left_text + return_code + right_text
			End If


		Else
			'// Not change
			out_text = out_text + _
				Mid( text,  start_positions(0),  over_positions(3) - start_positions(0) )
		End If
	Loop


	'// AutoMerge for "bracket_B" set
	ReDim  start_positions(2)
	ReDim  over_positions(2)
	position = 1
	text = out_text
	out_text = ""
	Do
		do_it = True
		before_position = position


		'// <<<<<<< Left.txt   ... start_positions(0)
		'// (left_text)        ... over_positions(0)
		'// =======            ... start_positions(1)
		'// (right_text)       ... over_positions(1)
		'// >>>>>>> Right.txt  ... start_positions(2)
		'//                    ... over_positions(2)

		'// Set "start_positionss(n)", "over_positions(n)"
		For  bracket_index = 0  To  2
			ThreeWayMerge_SearchBracketSub  text, position, start_pos, _
				bracket_B( bracket_index ), length_of_B( bracket_index )
				'//(in_out) position
			If start_pos = 0 Then
				If bracket_index = 0 Then
					out_text = out_text + Mid( text, before_position )
					Exit Do
				Else
					do_it = False '// diff が出力したコンフリクトの括弧の対応関係が正しくない
					Exit For
				End If
			End If
			start_positions( bracket_index ) = start_pos
			over_positions( bracket_index ) = position
		Next
		If do_it Then

			'// ...
			out_text = out_text + Mid( text,  before_position,  start_positions(0) - before_position )


			'// AutoMerge for "Add1". Copy right text only.
			out_text = out_text + _
				Mid( text,  over_positions(1),  start_positions(2) - over_positions(1) )
		End If
	Loop


	'// ...
	ThreeWayMerge_replaceByMergeTmplateSub  Me_, out_Text


	in_out_Text = out_text
End Sub


 
'***********************************************************************
'* Function: ThreeWayMerge_replaceByMergeTmplateSub
'***********************************************************************
Sub  ThreeWayMerge_replaceByMergeTmplateSub( Me_, in_out_Text )
	left_bracket   = "<<<<<<< "

	'// Replace by "MergeTemplate" : <ReplaceTemplate> tag
	If not IsEmpty( Me_.Option_.MergeTemplate ) Then
		Set cs = new_TextFileCharSetStack( "Unicode" )
		temporary_path = GetTempPath( "*.txt" )
		CreateFile  temporary_path,  in_out_Text

		Set replace_ = Me_.Option_.MergeTemplate
			AssertD_TypeName  replace_, "ReplaceTemplateClass"
		replace_.SetTargetPath  temporary_path

		step_num_back_up = replace_.StepNum
		break_step_num_back_up = replace_.BreakStepNum
		replace_.StepNum = Me_.Option_.StepNum
		replace_.BreakStepNum = Me_.Option_.BreakStepNum


		replace_.RunReplace


		Me_.Option_.StepNum = replace_.StepNum
		Me_.Option_.BreakStepNum = replace_.BreakStepNum
		replace_.StepNum = step_num_back_up
		replace_.BreakStepNum = break_step_num_back_up


		in_out_Text = ReadFile( temporary_path )
		cs = Empty
		del  temporary_path

		replace_.RemoveTargetPath  temporary_path
	End If


	'// ...
	If InStr( in_out_Text, left_bracket ) >= 1 Then
		Me_.IsConflicted = True
	End If

End Sub


 
'***********************************************************************
'* Class: ThreeWayMergeOptionClass
'***********************************************************************
Class  ThreeWayMergeOptionClass
	Public  IsConflictError
	Public  IsEnableToRaiseConflictError

	Public  IsAutoMergeEx
	Public  StepNum
	Public  BreakStepNum  '// Empty = Not debug,  0 = Break all
	Public  IsOutEach  '// False = Raises conflict

	Public  MergeTemplate  '// as ReplaceTemplateClass

	Public  SingletonKeywords  '// as array of string
	Public  UniqueLineKeywords  '// as array of string

	Private Sub  Class_Initialize()
		Me.IsConflictError = False
		Me.IsEnableToRaiseConflictError = True
		Me.IsAutoMergeEx = True
		Me.StepNum = 0
		Me.IsOutEach = False
		Me.SingletonKeywords = Array( )
		Me.UniqueLineKeywords = Array( )
	End Sub
End Class


 
'***********************************************************************
'* Function: LoadThreeWayMergeOptionClass
'***********************************************************************
Function  LoadThreeWayMergeOptionClass( in_SettingPath )
	Set merge = new ThreeWayMergeOptionClass

	Set root = LoadXML( in_SettingPath, Empty )
	parent_path = GetParentFullPath( in_SettingPath )

	merge.IsAutoMergeEx = XmlReadBoolean( root,  "./IsAutoMergeEx",  merge.IsAutoMergeEx,  in_SettingPath )
	merge.IsOutEach = XmlReadBoolean( root,  "./IsOutEach",  merge.IsOutEach,  in_SettingPath )

	merge.BreakStepNum = XmlRead( root, "./BreakStepNum" )
	If merge.BreakStepNum = "" Then
		merge.BreakStepNum = Empty
	Else
		merge.BreakStepNum = CInt2( merge.BreakStepNum )
	End If

	Set nodes = root.selectNodes( "./SingletonKeywords" )
	ReDim  values( nodes.length - 1 )
	For i=0 To UBound( values )
		values(i) = nodes(i).text
	Next
	merge.SingletonKeywords = values


	Set nodes = root.selectNodes( "./UniqueLineKeywords" )
	ReDim  values( nodes.length - 1 )
	For i=0 To UBound( values )
		values(i) = nodes(i).text
	Next
	merge.UniqueLineKeywords = values


	Set node = root.selectSingleNode( "./MergeTemplatePath/text()" )
	If not node is Nothing Then
		Set merge.MergeTemplate = new_ReplaceTemplateClass( GetFullPath( node.nodeValue, parent_path ) )
	End If


	Set LoadThreeWayMergeOptionClass = merge
End Function


 
'***********************************************************************
'* Class: ThreeWayMerge_AutoMergeExClass
'***********************************************************************
Class  ThreeWayMerge_AutoMergeExClass
	Public  Option_  '// as ThreeWayMergeOptionClass
	Public  IsConflicted
	Public  IsChanged

	Private Sub  Class_Initialize()
		Set Me.Option_ = new ThreeWayMergeOptionClass
		Me.IsConflicted = False
		Me.IsChanged = False
	End Sub
End Class


 
'***********************************************************************
'* Function: ThreeWayMerge_SearchBracketSub
'***********************************************************************
Sub  ThreeWayMerge_SearchBracketSub( in_Text, in_out_Position, out_FoundPosition, in_Bracket, in_BracketLength )
	out_FoundPosition = InStr( in_out_Position, in_Text, in_Bracket )
	If out_FoundPosition = 0 Then  Exit Sub

	c1 = Mid( in_Text,  out_FoundPosition + in_BracketLength,  1 )

	If c1 = vbCR Then
		c2 = Mid( in_Text,  out_FoundPosition + in_BracketLength + 1,  1 )
		If c2 = vbLF Then
			in_out_Position = out_FoundPosition + in_BracketLength + 2
		Else
			out_FoundPosition = 0
		End If
	ElseIf c1 = vbLF Then
		in_out_Position = out_FoundPosition + in_BracketLength + 1
	Else
		out_FoundPosition = 0
	End If
End Sub


 
'***********************************************************************
'* Function: FourWayMerge
'***********************************************************************
Sub  FourWayMerge( in_LeftBasePath,  in_LeftPath,  in_LeftMergedOutputPath, _
		in_RightBasePath,  in_RightPath,  in_RightMergedOutputPath,  in_out_Option )

	Set c = g_VBS_Lib
	echo  ">FourWayMerge"
	echo  "     LeftBase="""+ in_LeftBasePath +""""
	echo  "         Left="""+ in_LeftPath +""""
	echo  "    RightBase="""+ in_RightBasePath +""""
	echo  "        Right="""+ in_RightPath +""""
	echo  "   LeftMerged="""+ in_LeftMergedOutputPath +""""
	echo  "  RightMerged="""+ in_RightMergedOutputPath +""""
	Set ec = new EchoOff
	g_AppKey.CheckWritable  in_LeftMergedOutputPath, Empty
	g_AppKey.CheckWritable  in_RightMergedOutputPath, Empty
	If IsEmpty( in_out_Option ) Then  Set in_out_Option = new ThreeWayMergeOptionClass
in_out_Option.IsEnableToRaiseConflictError = False '// TODO:

	Set ds = new CurDirStack
	diff_exe  = Setting_getDiffPath()
	diff3_exe = Setting_getDiff3Path()

	left_base_path    = GetFullPath( in_LeftBasePath, Empty )
	left_path         = GetFullPath( in_LeftPath, Empty )
	right_base_path   = GetFullPath( in_RightBasePath, Empty )
	right_path        = GetFullPath( in_RightPath, Empty )
	left_merged_path  = GetFullPath( in_LeftMergedOutputPath, Empty )
	right_merged_path = GetFullPath( in_RightMergedOutputPath, Empty )
	work_folder_path  = GetTempPath( "ThreeWayMerge_*" )
	mkdir  work_folder_path


	'// For short command line and no space parameters
	'// Convert character code set
	pushd  work_folder_path
	If left_base_path <> "" Then
		left_base_text = ReadFile( left_base_path )
	Else
		left_base_text = ""
	End If
	If right_base_path <> "" Then
		right_base_text = ReadFile( right_base_path )
	Else
		right_base_text = ""
	End If
	left_base_text = ReadFile( left_base_path )
	left_text = ReadFile( left_path )
	right_base_text = ReadFile( right_base_path )
	right_text = ReadFile( right_path )
	Set cs = new_TextFileCharSetStack( "UTF-7" )
	CreateFile  "LeftBase.txt", left_base_text
	CreateFile  "Left.txt", left_text
	CreateFile  "RightBase.txt", right_base_text
	CreateFile  "Right.txt", right_text
	cs = Empty


	'// Convert return code
	Set cs = new_TextFileCharSetStack( "ISO-8859-1" )
	a_UTF_7_CR = "+AA0-"
	left_base_text  = ReadFile( "LeftBase.txt" )
	left_text       = ReadFile( "Left.txt" )
	right_base_text = ReadFile( "RightBase.txt" )
	right_text      = ReadFile( "Right.txt" )
	left_base_text  = Replace( left_base_text,  vbCR, a_UTF_7_CR + vbCR )
	left_text       = Replace( left_text,       vbCR, a_UTF_7_CR + vbCR )
	right_base_text = Replace( right_base_text, vbCR, a_UTF_7_CR + vbCR )
	right_text      = Replace( right_text,      vbCR, a_UTF_7_CR + vbCR )
	If Right( left_base_text,  1 ) <> vbLF Then  left_base_text  = left_base_text  + vbCRLF
	If Right( left_text,       1 ) <> vbLF Then  left_text       = left_text       + vbCRLF
	If Right( right_base_text, 1 ) <> vbLF Then  right_base_text = right_base_text + vbCRLF
	If Right( right_text,      1 ) <> vbLF Then  right_text      = right_text      + vbCRLF
	CreateFile  "LeftBase.txt",  left_base_text
	CreateFile  "Left.txt",  left_text
	CreateFile  "RightBase.txt",  right_base_text
	CreateFile  "Right.txt",  right_text


	'// Run diff
	r= RunProg( """"+ diff_exe +""" -u  LeftBase.txt  RightBase.txt",  "CommonBaseDiff.txt" )
	Set diffs = ParseUnifiedDiff( ReadFile( "CommonBaseDiff.txt" ), c.UTF_7 )

	If UBound( diffs.Differences ) = -1 Then
		copy_ren  "LeftBase.txt", "CommonBase.txt"
	Else
		Set file = OpenForRead( "RightBase.txt" )
		common_text = ""
		line_num = 1
		diff_num = 0
		Set a_diff = diffs.Differences( diff_num )
		Do Until  file.AtEndOfStream
			line = file.ReadLine()

			If line_num < a_diff.PlusStart Then
				common_text = common_text + line + vbCRLF
			ElseIf line_num < a_diff.PlusOver Then
			Else
				common_text = common_text + line + vbCRLF

				diff_num = diff_num + 1
				If diff_num > UBound( diffs.Differences ) Then _
					Exit Do
				Set a_diff = diffs.Differences( diff_num )
			End If

			line_num = line_num + 1
		Loop
		Do Until  file.AtEndOfStream
			line = file.ReadLine()
			common_text = common_text + line + vbCRLF
		Loop
		file = Empty
		CreateFile  "CommonBase.txt",  common_text
	End If


	'// Run diff3
	r= RunProg( """"+ diff3_exe +""" -A -m  Left.txt  CommonBase.txt  Right.txt", "CommonMerged.txt" )
	r= RunProg( """"+ diff3_exe +""" -A -m  Left.txt  RightBase.txt   Right.txt", "LeftMerged3A.txt" )
	r= RunProg( """"+ diff3_exe +""" -A -m  Left.txt  LeftBase.txt    Right.txt", "RightMerged3A.txt" )


	'// Convert character code set
	'// Convert return code
	'// Call "ThreeWayMerge_autoMergeExSub"
	For Each  out_path  In  Array( "CommonMerged.txt", "LeftMerged3A.txt", "RightMerged3A.txt" )
		text = ReadFile( out_path )

		If ReadLineSeparator( right_path ) = vbCRLF Then
			text = Replace( text, "="+ vbCRLF, "="+ vbCR + vbCRLF )
			text = Replace( text, "t"+ vbCRLF, "t"+ vbCR + vbCRLF )
		End If
		text = Replace( text, vbCRLF, vbLF )
		text = Replace( text, a_UTF_7_CR, vbCR )

		text = Replace( text,       "<<<<<<< ",       "+ADwAPAA8ADwAPAA8ADw- " )
		text = Replace( text, vbLF+ "||||||| ", vbLF+ "+AHwAfAB8AHwAfAB8AHw- " )
		text = Replace( text, vbLF+ "=======",  vbLF+ "+AD0APQA9AD0APQA9AD0-" )
		text = Replace( text, vbLF+ ">>>>>>> ", vbLF+ "+AD4APgA+AD4APgA+AD4- " )

		CreateFile  out_path, text
		cs = Empty

		Set cs = new_TextFileCharSetStack( "UTF-7" )
		text = ReadFile( out_path )
		cs = Empty

'// 2016-12-05		Set cs = new_TextFileCharSetStack( ReadUnicodeFileBOM( left_path ) )
		Set cs = new_TextFileCharSetStack( AnalyzeCharacterCodeSet( left_path ) )
		CreateFile  out_path, text
		cs = Empty

		If out_path = "CommonMerged.txt" Then
'// 2016-12-05			Set cs = new_TextFileCharSetStack( ReadUnicodeFileBOM( left_path ) )
			Set cs = new_TextFileCharSetStack( AnalyzeCharacterCodeSet( left_path ) )
			CreateFile  left_merged_path, text
			cs = Empty

'// 2016-12-05			Set cs = new_TextFileCharSetStack( ReadUnicodeFileBOM( right_path ) )
			Set cs = new_TextFileCharSetStack( AnalyzeCharacterCodeSet( right_path ) )
			CreateFile  right_merged_path, text
			cs = Empty
		End If
	Next


	For Each  left_right  In  Array( "Left", "Right" )

		'// Make "LeftMerged3A_CutBothTag.txt" file
		Set rep = StartReplace( left_right +"Merged3A.txt", left_right +"Merged3A_CutBothTag.txt", True )
		state = 0
		Do Until rep.r.AtEndOfStream
			line = rep.r.ReadLine()  '// "line" is with (CR+)LF.
			If StrCompHeadOf( line, "<<<<<<< RightBase.txt", c.CaseSensitive ) = 0 Then
				state = 1
			ElseIf  StrCompHeadOf( line, "=======", c.CaseSensitive ) = 0 Then
				If state = 1 Then
					state = 2
				Else
					rep.w.WriteLine  line
				End If
			ElseIf  StrCompHeadOf( line, ">>>>>>> Right.txt", c.CaseSensitive ) = 0 Then
				If state = 0 Then
					rep.w.WriteLine  line
				Else
					state = 0
				End If
			Else
				If state = 0  or  state = 2 Then _
					rep.w.WriteLine  line
			End If
		Loop
		rep.Finish


		'// Make "LeftMerged3A_CutAllTag.txt" file
		Set rep = StartReplace( left_right +"Merged3A.txt", left_right +"Merged3A_CutAllTag.txt", True )
		state = 0
		Do Until rep.r.AtEndOfStream
			line = rep.r.ReadLine()  '// "line" is with (CR+)LF.
			If StrCompHeadOf( line, "<<<<<<< RightBase.txt", c.CaseSensitive ) = 0 Then
				state = 1
			ElseIf  StrCompHeadOf( line, "=======", c.CaseSensitive ) = 0 Then
				If state = 1 Then
					state = 2
				End If
			ElseIf  StrCompHeadOf( line, ">>>>>>> Right.txt", c.CaseSensitive ) = 0 Then
				state = 0
			ElseIf  StrCompHeadOf( line, "<<<<<<< Left.txt", c.CaseSensitive ) = 0 Then
				state = 2
			ElseIf  StrCompHeadOf( line, "||||||| RightBase.txt", c.CaseSensitive ) = 0 Then
				state = 3
			Else
				If state = 0  or  state = 2 Then _
					rep.w.WriteLine  line
			End If
		Loop
		rep.Finish
		rep = Empty


		'// Make "LeftMerged3A_CutAllAndAddTag.txt" file
		copy_ren  left_path, left_right +"\Left.txt"
		copy_ren  left_right +"Merged3A_CutAllTag.txt", left_right +"\Right.txt"
		cd  left_right
		diff  "Left.txt", "Right.txt", left_right +"Merged3A_CutAllAndAddTag.txt", Empty
		cd  ".."


		'// Make "LeftMerged.txt" file
		Set rep1 = StartReplace( left_right +"Merged3A_CutBothTag.txt", left_right +"Merged.txt", True )
		Set rep2 = StartReplace( left_right +"\"+ left_right +"Merged3A_CutAllAndAddTag.txt", left_right +"\dummy.txt", True )
		is_skip2 = False
		Do Until rep1.r.AtEndOfStream
			If not is_skip2 Then
				line2 = rep2.r.ReadLine()
			Else
				is_skip2 = False
			End If

			If StrCompHeadOf( line2, "<<<<<<< Left.txt", c.CaseSensitive ) = 0 Then
				rep1.w.WriteLine  line2
				Do
					line2 = rep2.r.ReadLine()
					rep1.w.WriteLine  line2
					If StrCompHeadOf( line2, "=======", c.CaseSensitive ) = 0 Then _
						Exit Do
				Loop
				Do Until rep1.r.AtEndOfStream
					line2 = rep2.r.ReadLine()
					rep1.w.WriteLine  line2
					If StrCompHeadOf( line2, ">>>>>>> Right.txt", c.CaseSensitive ) = 0 Then _
						Exit Do
					line1 = rep1.r.ReadLine()
				Loop
			Else
				line1 = rep1.r.ReadLine()
				rep1.w.WriteLine  line1

				If StrCompHeadOf( line1, "<<<<<<< Left.txt", c.CaseSensitive ) = 0 Then
					is_skip2 = True
					Do Until rep1.r.AtEndOfStream
						line1 = rep1.r.ReadLine()
						rep1.w.WriteLine  line1
						If StrCompHeadOf( line1, "||||||| RightBase.txt", c.CaseSensitive ) = 0 Then _
							Exit Do
						If not is_skip2 Then
							line2 = rep2.r.ReadLine()
						Else
							is_skip2 = False
						End If
					Loop
					Do Until rep1.r.AtEndOfStream
						line1 = rep1.r.ReadLine()
						rep1.w.WriteLine  line1
						If StrCompHeadOf( line1, ">>>>>>> Right.txt", c.CaseSensitive ) = 0 Then _
							Exit Do
					Loop
				End If
			End If
		Loop
		rep1.Finish
		rep1 = Empty
		rep2.Finish
		rep2 = Empty

		If left_right = "Left" Then
			copy_ren  left_right +"Merged.txt", left_merged_path
		Else
			copy_ren  left_right +"Merged.txt", right_merged_path
		End If
	Next

	'// Clean
	del  "LeftBase.txt"
	del  "Left.txt"
	del  "RightBase.txt"
	del  "Right.txt"
	del  "CommonBaseDiff.txt"
	del  "CommonMerged.txt"
	popd

	If r <> 0 Then
		in_out_Option.IsConflictError = True
		If in_out_Option.IsEnableToRaiseConflictError Then
			Raise  E_Conflict, "<ERROR msg=""Conflict"" path="""+ in_LeftMergedOutputPath +"""/>"
		End If
	End If
End Sub


 
'***********************************************************************
'* Variable: g_FileHashCache
'*
'* Example:
'*     hash_value = g_FileHashCache( "C:\File.txt" )
'*
'* Description:
'*     ファイルが存在しないときは、"" が返ります。
'***********************************************************************
Dim  g_FileHashCache
Set  g_FileHashCache = new FileHashCacheClass


 
'***********************************************************************
'* Class: FileHashCacheClass
'***********************************************************************
Class  FileHashCacheClass

	'* Var: HashValues
		'* MD5 hash value as dictionary of string. Key is full path
		Public  HashValues


	Private Sub  Class_Initialize()
		Const  NotCaseSensitive = 1

		Set  Me.HashValues = CreateObject( "Scripting.Dictionary" )
		Me.HashValues.CompareMode = NotCaseSensitive
	End Sub


	'***********************************************************************
	'* Property: Item
	'***********************************************************************
	Public Default Property Get  Item( in_Path )
		Item = Me_Item_Sub( in_Path, Empty )
	End Property


	'***********************************************************************
	'* Method: Me_Item_Sub
	'***********************************************************************
	Private Function  Me_Item_Sub( in_Path, out_Binary )
		path = GetCaseSensitiveFullPath( in_Path )

		If Me.HashValues.Exists( path ) Then
			Me_Item_Sub = Me.HashValues( path )
		Else
			If g_fs.FileExists( path ) Then
				Set out_Binary = ReadBinaryFile( path )
				Me_Item_Sub = out_Binary.MD5
			ElseIf g_fs.FolderExists( path ) Then
				Me_Item_Sub = "Folder"
				Set folder = g_fs.GetFolder( path )
				If folder.Files.Count = 0 Then
					If folder.SubFolders.Count = 0 Then
						Me_Item_Sub = "EmptyFolder"
					End If
				End If
			Else
				Me_Item_Sub = ""
			End If
			Me.HashValues( path ) = Me_Item_Sub
		End If
	End Function


	'***********************************************************************
	'* Method: CopyRenFile
	'***********************************************************************
	Public Sub  CopyRenFile( in_SourcePath, in_DestinationPath )
		If IsEmpty( in_SourcePath ) Then
			Me.DeleteFile  in_SourcePath
			Exit Sub
		End If

		'// Set time_stamps = CreateObject( "Scripting.Dictionary" )

		src_path = GetCaseSensitiveFullPath( in_SourcePath )
		dst_path = GetCaseSensitiveFullPath( in_DestinationPath )

		src_hash = Me_Item_Sub( src_path, src_bin )  '//(out) src_bin
		If src_hash = "" Then _
			Raise  E_PathNotFound, "<ERROR msg=""ファイルまたはフォルダーが見つかりません。"" path="""+ _
				src_path +"""/>"

		dst_hash = Me_Item_Sub( dst_path, Empty )
		If src_hash = "EmptyFolder" Then
			If dst_hash = "EmptyFolder"  or  dst_hash = "Folder" Then
				'// Do Nothing
			ElseIf  dst_hash = "" Then
				mkdir  dst_path
				Me.HashValues( dst_path ) = "EmptyFolder"
			Else
				Error  '// Not supported
			End If
		ElseIf src_hash = "Folder" Then
			Error  '// Not supported
		Else  '// File
			If src_hash <> dst_hash Then
				'// If IsEmpty( src_bin ) Then
					copy_ren  src_path, dst_path
				'// Else
				'//     src_bin.Save  dst_path
				'//     time_stamps( dst_path ) = g_fs.GetFile( src_path ).DateLastModified
				'// End If
				Me.HashValues( dst_path ) = src_hash
			End If
		End If

		'// SetDateLastModified  time_stamps  '// slow operation
	End Sub


	'***********************************************************************
	'* Method: DeleteFile
	'***********************************************************************
	Public Sub  DeleteFile( in_Path )
		src_hash = Me_Item_Sub( in_Path, Empty )
		If src_hash = "" Then
			'// Do Nothing
		ElseIf src_hash = "Folder" Then
			Error  '// Not supported
		ElseIf src_hash = "EmptyFolder" Then
			g_AppKey.CheckWritable  in_Path, Empty
			g_fs.DeleteFolder  in_Path
			Me.HashValues( in_Path ) = ""
		Else
			g_AppKey.CheckWritable  in_Path, Empty
			g_fs.DeleteFile  in_Path
			Me.HashValues( in_Path ) = ""
		End If
	End Sub


	'***********************************************************************
	'* Method: Remove
	'***********************************************************************
	Public Sub  Remove( in_Path )
		path = GetCaseSensitiveFullPath( in_Path )
		If Me.HashValues.Exists( path ) Then _
			Me.HashValues.Remove  path
	End Sub


	'***********************************************************************
	'* Method: RemoveAll
	'***********************************************************************
	Public Sub  RemoveAll()
		Me.HashValues.RemoveAll
	End Sub
End Class


 
'***********************************************************************
'* Class: PatchAndBackUpDictionaryClass
'***********************************************************************
Class  PatchAndBackUpDictionaryClass

	'* Var: PatchRootPath
		Public  PatchRootPath

	'* Var: BackUpRootPath
		Public  BackUpRootPath

	'* Var: PatchPaths
		'* File paths and empty folder paths in "patch" folder
		'* as dictionary of path of exist file or folder. Key is full path
		Public  PatchPaths

	'* Var: BackUpPaths
		'* File paths and empty folder paths in "back_up" folder
		'* as dictionary of path of exist file or folder. Key is full path
		Public  BackUpPaths


	Private Sub  Class_Initialize()
		Const  NotCaseSensitive = 1

		Set  Me.PatchPaths = CreateObject( "Scripting.Dictionary" )
		Me.PatchPaths.CompareMode = NotCaseSensitive

		Set  Me.BackUpPaths = CreateObject( "Scripting.Dictionary" )
		Me.BackUpPaths.CompareMode = NotCaseSensitive
	End Sub


	Public Function  Copy()
		Set new_ = new PatchAndBackUpDictionaryClass
		new_.PatchRootPath  = Me.PatchRootPath
		new_.BackUpRootPath = Me.BackUpRootPath
		Dic_add  new_.PatchPaths,  Me.PatchPaths
		Dic_add  new_.BackUpPaths, Me.BackUpPaths
		Set Copy = new_
	End Function
End Class


 
'* Section: LeafPathDictionary
 
'***********************************************************************
'* Function: EnumerateToLeafPathDictionary
'*
'* Return Value:
'*     Dictionary of path of exist file or folder.
'***********************************************************************
Function  EnumerateToLeafPathDictionary( in_Path )
	Const  NotCaseSensitive = 1

	Set paths = CreateObject( "Scripting.Dictionary" )  '// LeafPathDictionary
	paths.CompareMode = NotCaseSensitive
	Set EnumerateToLeafPathDictionary = paths  '// Return value

	EnumFolderObjectDic  in_Path,  Empty,  folders  '// Set "folders"
	base_full_path = GetPathWithSeparator( GetFullPath( in_Path, Empty ) )

	For Each  folder_step_path  In  folders.Keys
		If folder_step_path = "." Then
			folder_path = Left( base_full_path,  Len( base_full_path ) - 1 )
		Else
			folder_path = base_full_path + folder_step_path
		End If


		EnumFileObjectDic  folder_path,  files  '// Set "files"


		is_empty_folder = False
		If files.Count = 0 Then
			If folders( folder_step_path ).SubFolders.Count = 0 Then _
				is_empty_folder = True
		End If

		If is_empty_folder Then
			Set paths( folder_path ) = new_NameOnlyClass( folder_path, Empty )
		Else
			For Each  file_name  In  files.Keys
				path = folder_path +"\"+ file_name
				Set paths( path ) = new_NameOnlyClass( path, Empty )
			Next
		End If
	Next

	If g_Vers("ExpandWildcard_Sort") Then
		QuickSortDicByKey  paths
	End If
End Function


 
'***********************************************************************
'* Function: EnumerateToLeafPathDictionaryByFullSetFile
'***********************************************************************
Function  EnumerateToLeafPathDictionaryByFullSetFile( _
		in_FolderPath,  in_MD5ListFilePath,  in_EmptyOption )

	Confirm_VBS_Lib_ForFastUser

	Set tc = get_ToolsLibConsts()
	Const  NotCaseSensitive = 1
	Set ds = new CurDirStack
	Set ec = new EchoOff

	Set paths = CreateObject( "Scripting.Dictionary" )  '// LeafPathDictionary
	paths.CompareMode = NotCaseSensitive
	Set EnumerateToLeafPathDictionaryByFullSetFile = paths  '// Return value
	If not IsEmpty( in_MD5ListFilePath ) Then
		If VarType( in_MD5ListFilePath ) = vbString Then
			Set a_MD5_list = OpenForDefragment( in_MD5ListFilePath,  Empty )
			base_path_of_MD5_list = GetParentFullPath( in_MD5ListFilePath )
		ElseIf TypeName( in_MD5ListFilePath ) = "OpenForDefragmentClass" Then
			Set a_MD5_list = in_MD5ListFilePath
			base_path_of_MD5_list = g_fs.GetParentFolderName( a_MD5_list.FileFullPath )
		End If
	End If


	cd  in_FolderPath


	'// Read from "_FullSet.txt" file.
	full_set_path = "_FullSet.txt"
	If g_fs.FileExists( full_set_path ) Then
		Const  length_of_hash = 32  '// MD5
		column_of_path = GetColumnOfPathInFolderMD5List( full_set_path )
		column_of_hash = column_of_path - length_of_hash - 1
		is_time_stamp_in_MD5_list = ( column_of_hash >= 2 )

		Set file = OpenForRead( full_set_path )
		Do Until  file.AtEndOfStream
			line = file.ReadLine()

			Set leaf = new MD5ListLeafClass
			leaf.Name = Mid( line,  column_of_path )
			leaf.HashValue = Mid( line,  column_of_hash,  length_of_hash )
			If is_time_stamp_in_MD5_list Then _
				leaf.TimeStamp = Left( line,  column_of_hash - 2 )

			If not IsEmpty( a_MD5_list ) Then
				If leaf.HashValue <> tc.EmptyFolderMD5 Then
					leaf.BodyFullPath = a_MD5_list.GetStepPath( leaf.HashValue,  base_path_of_MD5_list )
					If not IsEmpty( leaf.BodyFullPath ) Then _
						leaf.BodyFullPath = base_path_of_MD5_list +"\"+ leaf.BodyFullPath
				End If
			End If

			Set paths( leaf.Name ) = leaf
		Loop
	End If


	'// Read from file system.
	EnumFolderObjectDic  ".",  Empty,  folders  '// Set "folders"
	base_full_path = GetPathWithSeparator( GetFullPath( ".", Empty ) )
	For Each  folder_step_path  In  folders.Keys

		EnumFileObjectDic  folder_step_path,  files  '// Set "files"
		is_empty_folder = False
		If files.Count = 0 Then
			If folders( folder_step_path ).SubFolders.Count = 0 Then _
				is_empty_folder = True
		End If

		If is_empty_folder Then
			Set leaf = new MD5ListLeafClass
			leaf.Name = folder_step_path
			leaf.HashValue = tc.EmptyFolderMD5
			leaf.TimeStamp = tc.EmptyFolderTimeStamp
			leaf.BodyFullPath = base_full_path + folder_step_path

			Set paths( folder_step_path ) = leaf
		Else
			folder_path = GetPathWithSeparator( folder_step_path )
	
			For Each  file_name  In  files.Keys
				file_step_path = folder_path + file_name
				If file_step_path <> "_FullSet.txt" Then
					Set leaf = new MD5ListLeafClass
					leaf.Name = file_step_path
					leaf.HashValue = GetHashOfFile( file_step_path, "MD5" )
					leaf.BodyFullPath = base_full_path + file_step_path

					'// Set "leaf.TimeStamp"
					LetSet  leaf_in_full_set,  paths( file_step_path )  '// Set "leaf_in_full_set"
					If IsObject( leaf_in_full_set ) Then
						If leaf.HashValue = leaf_in_full_set.HashValue Then _
							leaf.TimeStamp = leaf_in_full_set.TimeStamp
					End If
					If IsEmpty( leaf.TimeStamp ) Then _
						leaf.TimeStamp = W3CDTF( g_fs.GetFile( file_step_path ).DateLastModified )

					'// ...
					Set paths( file_step_path ) = leaf
				End If
			Next
		End If
	Next

	If g_Vers("ExpandWildcard_Sort") Then
		QuickSortDicByKey  paths
	End If
End Function


 
'***********************************************************************
'* Function: MD5ListLeafClass
'***********************************************************************
Class  MD5ListLeafClass
	Public  Name  '// StepPath. Name is specification of LeafPathDictionary
	Public  HashValue
	Public  TimeStamp  '// as string of W3CDTF
	Public  BodyFullPath
End Class


 
'***********************************************************************
'* Function: IsSameHashValuesOfLeafPathDictionary
'***********************************************************************
Function  IsSameHashValuesOfLeafPathDictionary( _
		arg_1stLeafPathDictionary, in_1stBasePath, _
		arg_2ndLeafPathDictionary, in_2ndBasePath )

	If IsEmpty( arg_1stLeafPathDictionary ) Then
		Set arg_1stLeafPathDictionary = EnumerateToLeafPathDictionary( in_1stBasePath )
	End If
	If IsEmpty( arg_2ndLeafPathDictionary ) Then
		Set arg_2ndLeafPathDictionary = EnumerateToLeafPathDictionary( in_2ndBasePath )
	End If


	If arg_1stLeafPathDictionary.Count <> arg_2ndLeafPathDictionary.Count Then
		IsSameHashValuesOfLeafPathDictionary = False
	Else
		base_of_1st = GetPathWithSeparator( GetFullPath( in_1stBasePath, Empty ) )
		base_of_2nd = GetPathWithSeparator( GetFullPath( in_2ndBasePath, Empty ) )
		offset_of_1st_base = Len( base_of_1st ) + 1
		offset_of_2nd_base = Len( base_of_2nd ) + 1

		For Each  key_of_1st  In  arg_1stLeafPathDictionary.Keys
			key_of_2nd = base_of_2nd + Mid( key_of_1st,  offset_of_1st_base )
			If not arg_2ndLeafPathDictionary.Exists( key_of_2nd ) Then
				IsSameHashValuesOfLeafPathDictionary = False
				Exit Function
			End If

			Set path_of_1st = arg_1stLeafPathDictionary( key_of_1st )
			Set path_of_2nd = arg_2ndLeafPathDictionary( key_of_2nd )
			If g_FileHashCache( path_of_1st.Name ) <> g_FileHashCache( path_of_2nd.Name ) Then
				IsSameHashValuesOfLeafPathDictionary = False
				Exit Function
			End If
		Next
		IsSameHashValuesOfLeafPathDictionary = True
	End If
End Function


 
'***********************************************************************
'* Function: IsSameFileNamesOfLeafPathDictionary
'***********************************************************************
Function  IsSameFileNamesOfLeafPathDictionary( _
		arg_1stLeafPathDictionary, in_1stBasePath, _
		arg_2ndLeafPathDictionary, in_2ndBasePath )

	If IsEmpty( arg_1stLeafPathDictionary ) Then
		Set arg_1stLeafPathDictionary = EnumerateToLeafPathDictionary( in_1stBasePath )
	End If
	If IsEmpty( arg_2ndLeafPathDictionary ) Then
		Set arg_2ndLeafPathDictionary = EnumerateToLeafPathDictionary( in_2ndBasePath )
	End If


	If arg_1stLeafPathDictionary.Count <> arg_2ndLeafPathDictionary.Count Then
		IsSameFileNamesOfLeafPathDictionary = False
	Else
		base_of_1st = GetPathWithSeparator( GetFullPath( in_1stBasePath, Empty ) )
		base_of_2nd = GetPathWithSeparator( GetFullPath( in_2ndBasePath, Empty ) )
		offset_of_1st_base = Len( base_of_1st ) + 1
		offset_of_2nd_base = Len( base_of_2nd ) + 1

		For Each  key_of_1st  In  arg_1stLeafPathDictionary.Keys
			key_of_2nd = base_of_2nd + Mid( key_of_1st,  offset_of_1st_base )
			If not arg_2ndLeafPathDictionary.Exists( key_of_2nd ) Then
				IsSameFileNamesOfLeafPathDictionary = False
				Exit Function
			End If
		Next
		IsSameFileNamesOfLeafPathDictionary = True
	End If
End Function


 
'***********************************************************************
'* Function: ChangeKeyOfLeafPathDictionary
'***********************************************************************
Sub  ChangeKeyOfLeafPathDictionary( in_out_LeafPathDictionary, in_SourcePath, in_DestinationPath )
	Set dic = in_out_LeafPathDictionary
	source_path_s = GetPathWithSeparator( GetFullPath( in_SourcePath, Empty ) )
	source_path_offset = Len( source_path_s ) + 1
	source_path_n = Left( source_path_s, source_path_offset - 2 )
	destination_s = GetPathWithSeparator( GetFullPath( in_DestinationPath, Empty ) )
	destination_n = Left( destination_s, Len( destination_s ) - 1 )

	Assert  not IsWildcard( in_SourcePath )

	paths = dic.Keys
	For Each  path  In  paths
		If path = source_path_n Then
			Set dic( destination_n ) = dic( source_path_n )
			dic.Remove  source_path_n
		ElseIf StrCompHeadOf( path, source_path_s, Empty ) = 0 Then
			destination_path = destination_s + Mid( path, source_path_offset )
			Set dic( destination_path ) = dic( path )
			dic.Remove  path
		End If
	Next

	If g_Vers("ExpandWildcard_Sort") Then
		QuickSortDicByKey  dic
	End If
End Sub


 
'***********************************************************************
'* Function: CopyFilesToLeafPathDictionary
'***********************************************************************
Sub  CopyFilesToLeafPathDictionary( in_LeafPathDictionary, in_IsSetItemDestination )
	echo  ">CopyFilesToLeafPathDictionary"
	Set ec = new EchoOff


	is_echo = g_Vers("EchoFileCopy")
		'// For verbose mode or debug


	If TypeName( in_LeafPathDictionary ) = "PatchAndBackUpDictionaryClass" Then

		'// Make patch and back up folders
		mkdir  in_LeafPathDictionary.PatchRootPath
		mkdir  in_LeafPathDictionary.BackUpRootPath
		CopyFilesToLeafPathDictionary  in_LeafPathDictionary.PatchPaths,  in_IsSetItemDestination
		CopyFilesToLeafPathDictionary  in_LeafPathDictionary.BackUpPaths, in_IsSetItemDestination
	Else
		conflicted_paths = ""

		For Each  destination_path  In  in_LeafPathDictionary.Keys
			source_path = in_LeafPathDictionary( destination_path ).Name
			If IsEmpty( source_path ) Then

				If is_echo Then _
					echo_v  "del  """+ destination_path +""""

				g_FileHashCache.DeleteFile  destination_path
				If in_IsSetItemDestination Then _
					in_LeafPathDictionary.Remove  destination_path
			ElseIf not IsArray( source_path ) Then
				If source_path <> destination_path Then

					If is_echo Then _
						echo_v  "copy_ren  """+ source_path +""", """+ destination_path +""""

					g_FileHashCache.CopyRenFile  source_path, destination_path
					If in_IsSetItemDestination Then _
						in_LeafPathDictionary( destination_path ) = destination_path
				End If
			Else
				Assert  UBound( source_path ) = 4 - 1
				g_FileHashCache.Remove  destination_path

				If is_echo  or  g_is_debug Then
					echo_v  ""
					echo_v  ">ThreeWayMerge"
					echo_v  "    Base="""+ source_path(0) +""""
					echo_v  "    Left="""+ source_path(1) +""""
					echo_v  "   Right="""+ source_path(2) +""""
					echo_v  "  Output="""+ destination_path +""""
					echo_v  ""
				End If

				If TryStart(e) Then  On Error Resume Next


					ThreeWayMerge  source_path(0), source_path(1), source_path(2), _
						destination_path,  source_path(3)
						'// If "source_path(0) = Empty",
						'//  See "E_Conflict" in "AttachPatchAndBackUpDictionary".


				If TryEnd Then  On Error GoTo 0
				If e.num = E_Conflict Then
					conflicted_paths = conflicted_paths + destination_path + vbCRLF
					e.Clear
				ElseIf e.num <> 0 Then
					e.Raise
				End If

				If in_IsSetItemDestination Then _
					in_LeafPathDictionary.Remove  destination_path
			End If
		Next

		If conflicted_paths <> "" Then
			Raise  E_Conflict, "<ERROR  msg=""Conflicted"">"+ vbCRLF + conflicted_paths +"</ERROR>"
		End If
	End If
End Sub


 
'***********************************************************************
'* Function: RemoveKeyOfEmptyItemInLeafPathDictionary
'***********************************************************************
Sub  RemoveKeyOfEmptyItemInLeafPathDictionary( in_out_LeafPathDictionary, in_IsDeleteFile )
	For Each  destination_path  In  in_out_LeafPathDictionary.Keys
		source_path = in_out_LeafPathDictionary( destination_path ).Name
		If IsEmpty( source_path ) Then
			in_out_LeafPathDictionary.Remove  destination_path
			If in_IsDeleteFile Then
				g_FileHashCache.DeleteFile  destination_path
			End If
		End If
	Next
End Sub


 
'***********************************************************************
'* Function: GetNotSameFileKeysAsItemsOfLeafPathDictionary
'***********************************************************************
Function  GetNotSameFileKeysAsItemsOfLeafPathDictionary( in_LeafPathDictionary )
	Set not_same_keys = new ArrayClass
	For Each  key  In  in_LeafPathDictionary.Keys
		item = in_LeafPathDictionary( key ).Name
		If g_FileHashCache( key ) <> g_FileHashCache( item ) Then _
			not_same_keys.Add  key
	Next
	GetNotSameFileKeysAsItemsOfLeafPathDictionary = not_same_keys.Items
End Function


 
'***********************************************************************
'* Function: NormalizeLeafPathDictionary
'***********************************************************************
Sub  NormalizeLeafPathDictionary( in_out_Dictionary )
	keys = in_out_Dictionary.Keys
	For Each  key1  In  keys
		If in_out_Dictionary.Exists( key1 ) Then
			For Each  key2  In  keys
				If StrCompHeadOf( key1,  key2 +"\",  Empty ) = 0 Then
					If in_out_Dictionary.Exists( key2 ) Then
						in_out_Dictionary.Remove  key2
					End If
				End If
			Next
		End If
	Next

	If in_out_Dictionary.Exists( "" ) Then _
		in_out_Dictionary.Remove  ""
End Sub


 
'***********************************************************************
'* Function: AttachPatchAndCheckBackUp
'***********************************************************************
Sub  AttachPatchAndCheckBackUp( in_PatchTargetPath,  ByVal in_BackUpTargetPath,  in_PatchPath,  in_BackUpPath )
	If IsEmpty( in_BackUpTargetPath ) Then _
		in_BackUpTargetPath = in_PatchTargetPath

	echo  ">AttachPatchAndCheckBackUp  """+ in_PatchTargetPath +""", """+ in_BackUpTargetPath + _
		""", """+ in_PatchPath +""", """+ in_BackUpPath +""""

	Set  patch_ = new PatchAndBackUpDictionaryClass
	patch_.PatchRootPath = GetFullPath( in_PatchPath, Empty )
	Set patch_.PatchPaths = EnumerateToLeafPathDictionary( patch_.PatchRootPath )
	patch_.BackUpRootPath = GetFullPath( in_BackUpPath, Empty )
	Set patch_.BackUpPaths = EnumerateToLeafPathDictionary( patch_.BackUpRootPath )

	ChangeKeyOfPatchAndBackUpDictionaryToTarget  patch_,  Array( in_PatchTargetPath, in_BackUpTargetPath )

	target_path = patch_.PatchRootPath
	AttachPatchAndBackUpDictionary  files, patch_, target_path, True
	CopyFilesToLeafPathDictionary  files, False
End Sub


 
'***********************************************************************
'* Function: EnumerateToPatchAndBackUpDictionary
'*
'* Return Value:
'*     <PatchAndBackUpDictionaryClass>.
'***********************************************************************
Function  EnumerateToPatchAndBackUpDictionary( in_Path )
	Set dic = new PatchAndBackUpDictionaryClass
	base_path = GetPathWithSeparator( GetFullPath( in_Path, Empty ) )
	AssertExist  base_path +"patch"
	AssertExist  base_path +"back_up"

	dic.PatchRootPath  = base_path +"patch"
	dic.BackUpRootPath = base_path +"back_up"
	Set dic.PatchPaths  = EnumerateToLeafPathDictionary( dic.PatchRootPath )
	Set dic.BackUpPaths = EnumerateToLeafPathDictionary( dic.BackUpRootPath )

	If g_Vers("ExpandWildcard_Sort") Then
		QuickSortDicByKey  dic.PatchPaths
		QuickSortDicByKey  dic.BackUpPaths
	End If

	Set EnumerateToPatchAndBackUpDictionary = dic
End Function


 
'***********************************************************************
'* Function: MakePatchAndBackUpDictionary
'*
'* Return Value:
'*     <PatchAndBackUpDictionaryClass>.
'***********************************************************************
Function  MakePatchAndBackUpDictionary( _
		in_AttachedLeafPathDictionary, in_RootPathInAttachedLeafPath, _
		in_BaseLeafPathDictionary,     in_RootPathInBaseLeafPath, _
		in_PathOfPatchAndBackUp )

	attach_base_path = GetPathWithSeparator( GetFullPath( in_RootPathInAttachedLeafPath, Empty ) )
	base_base_path   = GetPathWithSeparator( GetFullPath( in_RootPathInBaseLeafPath,     Empty ) )
	attach_offset = Len( attach_base_path ) + 1
	base_offset   = Len( base_base_path ) + 1

	If IsEmpty( in_AttachedLeafPathDictionary ) Then
		Set in_AttachedLeafPathDictionary = EnumerateToLeafPathDictionary( in_RootPathInAttachedLeafPath )
	End If
	If IsEmpty( in_BaseLeafPathDictionary ) Then
		Set in_BaseLeafPathDictionary = EnumerateToLeafPathDictionary( in_RootPathInBaseLeafPath )
	End If

	Set dic = new PatchAndBackUpDictionaryClass
	If not IsEmpty( in_PathOfPatchAndBackUp ) Then
		patch_base_path  = GetPathWithSeparator( GetFullPath( in_PathOfPatchAndBackUp, Empty ) )
		dic.PatchRootPath  = patch_base_path +"patch"
		dic.BackUpRootPath = patch_base_path +"back_up"
	Else
		dic.PatchRootPath  = Left( attach_base_path, Len( attach_base_path ) - 1 )
		dic.BackUpRootPath = Left( base_base_path, Len( base_base_path ) - 1 )
	End If

	For Each  attach_path  In  in_AttachedLeafPathDictionary.Keys
		step_path = Mid( attach_path, attach_offset )
		base_path = base_base_path + step_path
		If in_BaseLeafPathDictionary.Exists( base_path ) Then
			If g_FileHashCache( in_AttachedLeafPathDictionary( attach_path ).Name ) <>_
					 g_FileHashCache( in_BaseLeafPathDictionary( base_path ).Name ) Then
				Set dic.PatchPaths( dic.PatchRootPath +"\"+ step_path ) = _
					in_AttachedLeafPathDictionary( attach_path )
				Set dic.BackUpPaths( dic.BackUpRootPath +"\"+ step_path ) = _
					in_BaseLeafPathDictionary( base_path )
			End If
		Else
			Set dic.PatchPaths( dic.PatchRootPath +"\"+ step_path ) = _
				in_AttachedLeafPathDictionary( attach_path )
		End If
	Next

	For Each  base_path  In  in_BaseLeafPathDictionary.Keys
		step_path = Mid( base_path, base_offset )
		attach_path = attach_base_path + step_path
		If not in_AttachedLeafPathDictionary.Exists( attach_path ) Then
			Set dic.BackUpPaths( dic.BackUpRootPath +"\"+ step_path ) = _
				in_BaseLeafPathDictionary( base_path )
		End If
	Next

	If g_Vers("ExpandWildcard_Sort") Then
		QuickSortDicByKey  dic.PatchPaths
		QuickSortDicByKey  dic.BackUpPaths
	End If

	Set MakePatchAndBackUpDictionary = dic
End Function


 
'***********************************************************************
'* Function: ChangeKeyOfPatchAndBackUpDictionaryToTarget
'***********************************************************************
Sub  ChangeKeyOfPatchAndBackUpDictionaryToTarget( arg_PatchAndBackUpDictionary, in_TargetPath )
	Const  c_NotCaseSensitive = 1
	Set patch_ = arg_PatchAndBackUpDictionary

	If not IsArray( in_TargetPath ) Then
		target_full_path = GetFullPath( in_TargetPath, Empty )
	Else
		target_full_path = GetFullPath( in_TargetPath( 1 ), Empty )
	End If

	Set new_paths = CreateObject( "Scripting.Dictionary" )
	new_paths.CompareMode = c_NotCaseSensitive
	For Each  path  In  patch_.BackUpPaths.Keys  '// Change destination path of copy
		new_path = ReplaceRootPath( path,  patch_.BackUpRootPath,  target_full_path, False )
		Set new_paths( new_path ) = patch_.BackUpPaths( path )  '// Not change source path
	Next
	Set patch_.BackUpPaths = new_paths
	patch_.BackUpRootPath = target_full_path


	'// ...
	If IsArray( in_TargetPath ) Then
		target_full_path = GetFullPath( in_TargetPath( 0 ), Empty )
	End If

	Set new_paths = CreateObject( "Scripting.Dictionary" )
	new_paths.CompareMode = c_NotCaseSensitive
	For Each  path  In  patch_.PatchPaths.Keys  '// Change destination path of copy
		new_path = ReplaceRootPath( path,  patch_.PatchRootPath,  target_full_path, False )
		Set new_paths( new_path ) = patch_.PatchPaths( path )  '// Not change source path
	Next
	Set patch_.PatchPaths = new_paths
	patch_.PatchRootPath = target_full_path


	'// ...
	patch_.BackUpRootPath = NormalizePath( GetCommonParentFolderPath( _
		patch_.BackUpRootPath +"\file",  patch_.PatchRootPath +"\file" ) )
	patch_.PatchRootPath = patch_.BackUpRootPath
End Sub


 
'***********************************************************************
'* Function: MergePatchAndBackUpDictionary
'***********************************************************************
Sub  MergePatchAndBackUpDictionary( arg_Destination, in_TargetRootPathOfDestination, _
		in_Source, in_TargetRootPathOfSource )

	'// debug_path = "MoveAndModifyFromPrimaryToA.txt"

	ChangeKeyOf2PatchAndBackUpDictionaryToTarget _
		arg_Destination,  arg_Destination,  in_TargetRootPathOfDestination, _
		source_patch,  in_Source,  in_TargetRootPathOfSource


	'// Add "in_Source.BackUpPaths" to "arg_Destination.BackUpPaths"
	'// Add "in_Source.PatchPaths" of modifing file to "arg_Destination.PatchPaths"
	For Each  src_back_up_path  In  source_patch.BackUpPaths.Keys
		step_path = GetStepPath( src_back_up_path, source_patch.BackUpRootPath )

		If not IsEmpty( debug_path ) Then  If InStr( step_path, debug_path ) >= 1 Then  Stop

		dst_back_up_path = GetFullPath( step_path, arg_Destination.BackUpRootPath )
		dst_patch_path   = GetFullPath( step_path, arg_Destination.PatchRootPath )
		src_patch_path   = GetFullPath( step_path, source_patch.PatchRootPath )

		If arg_Destination.BackUpPaths.Exists( dst_back_up_path ) Then
			dst_real_path = arg_Destination.BackUpPaths( dst_back_up_path ).Name
			src_real_path = source_patch.BackUpPaths( src_back_up_path ).Name
			If g_FileHashCache( dst_real_path ) <> g_FileHashCache( src_real_path ) Then _
				MergePatchAndBackUpDictionary_error  dst_real_path,  src_real_path
		Else
			Set arg_Destination.BackUpPaths( dst_back_up_path ) = _
				source_patch.BackUpPaths( src_back_up_path )
		End If

		If arg_Destination.PatchPaths.Exists( dst_patch_path ) Then
			If source_patch.PatchPaths.Exists( src_patch_path ) Then
				dst_real_path = arg_Destination.PatchPaths( dst_patch_path ).Name
				src_real_path = source_patch.PatchPaths( src_patch_path ).Name
				If g_FileHashCache( dst_real_path ) <> g_FileHashCache( src_real_path ) Then _
					MergePatchAndBackUpDictionary_error  dst_real_path,  src_real_path
			End If
		Else
			If source_patch.PatchPaths.Exists( src_patch_path ) Then
				Set arg_Destination.PatchPaths( dst_patch_path ) = _
					source_patch.PatchPaths( src_patch_path )
			End If
		End If
	Next


	'// Add "in_Source.PatchPaths" of new file to "arg_Destination.PatchPaths"
	For Each  src_patch_path  In  source_patch.PatchPaths.Keys
		step_path = GetStepPath( src_patch_path, source_patch.PatchRootPath )

		If not IsEmpty( debug_path ) Then  If InStr( step_path, debug_path ) >= 1 Then  Stop

		src_back_up_path = GetFullPath( step_path, source_patch.BackUpRootPath )
		If not source_patch.BackUpPaths.Exists( src_back_up_path ) Then
			dst_patch_path   = GetFullPath( step_path, arg_Destination.PatchRootPath )
			dst_back_up_path = GetFullPath( step_path, arg_Destination.BackUpRootPath )

			If arg_Destination.PatchPaths.Exists( dst_patch_path ) Then
				dst_real_path = arg_Destination.PatchPaths( dst_patch_path ).Name
				src_real_path = source_patch.PatchPaths( src_patch_path ).Name
				If g_FileHashCache( dst_real_path ) <> g_FileHashCache( src_real_path ) Then _
					MergePatchAndBackUpDictionary_error  dst_real_path,  src_real_path
			Else
				Set arg_Destination.PatchPaths( dst_patch_path ) = _
					source_patch.PatchPaths( src_patch_path )
			End If
		End If
	Next
End Sub


 
'***********************************************************************
'* Function: ChangeKeyOf2PatchAndBackUpDictionaryToTarget
'***********************************************************************
Sub  ChangeKeyOf2PatchAndBackUpDictionaryToTarget( _
		out_Destination,  in_Destination,  in_TargetRootPathOfDestination, _
		out_Source,       in_Source,       in_TargetRootPathOfSource )

	If not IsEmpty( in_TargetRootPathOfDestination ) Then
		Assert  not IsEmpty( in_TargetRootPathOfSource )

		If not IsArray( in_TargetRootPathOfDestination ) Then
			dst_back_up_root_path = in_TargetRootPathOfDestination
			dst_patch_root_path   = in_TargetRootPathOfDestination
		Else
			dst_back_up_root_path = in_TargetRootPathOfDestination( 1 )
			dst_patch_root_path   = in_TargetRootPathOfDestination( 0 )
		End If

		If not IsArray( in_TargetRootPathOfSource ) Then
			src_back_up_root_path = in_TargetRootPathOfSource
			src_patch_root_path   = in_TargetRootPathOfSource
		Else
			src_back_up_root_path = in_TargetRootPathOfSource( 1 )
			src_patch_root_path   = in_TargetRootPathOfSource( 0 )
		End If

		dst_back_up_root_path = GetFullPath( dst_back_up_root_path, Empty )
		dst_patch_root_path   = GetFullPath( dst_patch_root_path,   Empty )
		src_back_up_root_path = GetFullPath( src_back_up_root_path, Empty )
		src_patch_root_path   = GetFullPath( src_patch_root_path,   Empty )

		root_path = GetCommonParentFolderPath( dst_back_up_root_path +"\file",  dst_patch_root_path +"\file" )
		root_path = GetCommonParentFolderPath( root_path +"file",  src_back_up_root_path +"\file" )
		root_path = GetCommonParentFolderPath( root_path +"file",  src_patch_root_path +"\file" )
		root_path = NormalizePath( root_path )

		If in_Destination.BackUpRootPath <> root_path  or  in_Destination.PatchRootPath <> root_path Then
			If IsEmpty( out_Destination ) Then  Set out_Destination = Nothing
			If  not  out_Destination  is  in_Destination Then
				Set out_Destination = new PatchAndBackUpDictionaryClass
				out_Destination.BackUpRootPath = in_Destination.BackUpRootPath
				out_Destination.PatchRootPath  = in_Destination.PatchRootPath
				Set out_Destination.BackUpPaths = in_Destination.BackUpPaths
				Set out_Destination.PatchPaths  = in_Destination.PatchPaths
			Else
				Set out_Destination = in_Destination
			End If
			ChangeKeyOfPatchAndBackUpDictionaryToTarget  out_Destination,  in_TargetRootPathOfDestination
			out_Destination.BackUpRootPath = root_path
			out_Destination.PatchRootPath  = root_path
		Else
			Set out_Destination = in_Destination
		End If

		If in_Source.BackUpRootPath <> root_path  or  in_Source.PatchRootPath <> root_path Then
			If IsEmpty( out_Source ) Then  Set out_Source = Nothing
			If  not  out_Source  is  in_Source Then
				Set out_Source = new PatchAndBackUpDictionaryClass
				out_Source.BackUpRootPath = in_Source.BackUpRootPath
				out_Source.PatchRootPath  = in_Source.PatchRootPath
				Set out_Source.BackUpPaths = in_Source.BackUpPaths
				Set out_Source.PatchPaths  = in_Source.PatchPaths
			Else
				Set out_Source = in_Source
			End If
			ChangeKeyOfPatchAndBackUpDictionaryToTarget  out_Source,  in_TargetRootPathOfSource
			out_Source.BackUpRootPath = root_path
			out_Source.PatchRootPath  = root_path
		Else
			Set out_Source = in_Source
		End If
	Else
		Assert  IsEmpty( in_TargetRootPathOfSource )
		Set out_Destination = in_Destination
		Set out_Source = in_Source
	End If
End Sub


 
'***********************************************************************
'* Function: CanAttachFriendPatchAndBackUpDictionary
'***********************************************************************
Function  CanAttachFriendPatchAndBackUpDictionary( in_AttachingPatch, in_TargetRootPathOfAttaching, _
		in_FriendPatch, in_TargetRootPathOfFriend )

	'// debug_path = "MoveAndModifyFromPrimaryToA.txt"

	Set c = get_ToolsLibConsts()
	state = c.Attachable
	friend_state = c.Attachable

	ChangeKeyOf2PatchAndBackUpDictionaryToTarget _
		dst_patch,  in_AttachingPatch,  in_TargetRootPathOfAttaching, _
		src_patch,  in_FriendPatch,     in_TargetRootPathOfFriend
		'// dst_patch = destination patch. See "MergePatchAndBackUpDictionary".
		'// src_patch = source patch


	'// Check "in_FriendPatch.BackUpPaths"
	'// Check "in_FriendPatch.PatchPaths" of modifing file
	For Each  src_back_up_path  In  src_patch.BackUpPaths.Keys
		step_path = GetStepPath( src_back_up_path, src_patch.BackUpRootPath )

		If not IsEmpty( debug_path ) Then  If InStr( step_path, debug_path ) >= 1 Then  Stop

		dst_back_up_path = GetFullPath( step_path, dst_patch.BackUpRootPath )
		dst_patch_path   = GetFullPath( step_path, dst_patch.PatchRootPath )
		src_patch_path   = GetFullPath( step_path, src_patch.PatchRootPath )

		If dst_patch.BackUpPaths.Exists( dst_back_up_path ) Then
			dst_real_path = dst_patch.BackUpPaths( dst_back_up_path ).Name
			src_real_path = src_patch.BackUpPaths( src_back_up_path ).Name
			If g_FileHashCache( dst_real_path ) <> g_FileHashCache( src_real_path ) Then _
				state = c.CannotAttachBoth : echo_v  "CannotAttachBoth: "+ dst_real_path
		ElseIf dst_patch.PatchPaths.Exists( dst_patch_path ) Then
			state = c.MustAttachAfterFriend : echo_v  "MustAttachAfterFriend: "+ dst_patch_path
		End If

		If dst_patch.PatchPaths.Exists( dst_patch_path ) Then
			If src_patch.PatchPaths.Exists( src_patch_path ) Then
				dst_real_path = dst_patch.PatchPaths( dst_patch_path ).Name
				src_real_path = src_patch.PatchPaths( src_patch_path ).Name
				If g_FileHashCache( dst_real_path ) <> g_FileHashCache( src_real_path ) Then _
					state = c.CannotAttachBoth : echo_v  "CannotAttachBoth: "+ dst_real_path
			End If
		End If
	Next


	'// Check "in_FriendPatch.PatchPaths" of new file
	For Each  src_patch_path  In  src_patch.PatchPaths.Keys
		step_path = GetStepPath( src_patch_path, src_patch.PatchRootPath )

		If not IsEmpty( debug_path ) Then  If InStr( step_path, debug_path ) >= 1 Then  Stop

		src_back_up_path = GetFullPath( step_path, src_patch.BackUpRootPath )
		If not src_patch.BackUpPaths.Exists( src_back_up_path ) Then
			dst_patch_path   = GetFullPath( step_path, dst_patch.PatchRootPath )
			dst_back_up_path = GetFullPath( step_path, dst_patch.BackUpRootPath )

			If dst_patch.PatchPaths.Exists( dst_patch_path ) Then
				dst_real_path = dst_patch.PatchPaths( dst_patch_path ).Name
				src_real_path = src_patch.PatchPaths( src_patch_path ).Name
				If g_FileHashCache( dst_real_path ) <> g_FileHashCache( src_real_path ) Then _
					state = c.CannotAttachBoth : echo_v  "CannotAttachBoth: "+ dst_real_path
			Else
				If dst_patch.BackUpPaths.Exists( dst_back_up_path ) Then _
					friend_state = c.MustAttachAfterFriend : echo_v  "MustAttachAfterFriend: "+ dst_back_up_path
			End If
		End If
	Next

	If state = c.MustAttachAfterFriend Then _
		If friend_state = c.MustAttachAfterFriend Then _
			state = c.MustMergeWithFriend

	CanAttachFriendPatchAndBackUpDictionary = state
End Function


 
'***********************************************************************
'* Function: MergePatchAndBackUpDictionary_error
'***********************************************************************
Sub  MergePatchAndBackUpDictionary_error( in_Path1, in_Path2 )
	Raise  E_AlreadyExist,  "<ERROR msg=""マージするパッチが衝突しています。"""+ vbCRLF +"  path_1="""+ _
		in_Path1 +""""+ vbCRLF +"  path_2="""+ in_Path2 +"""/>"
End Sub


 
'***********************************************************************
'* Function: AttachPatchAndBackUpDictionary
'*
'* Argument:
'*     in_out_Options - ThreeWayMergeOptionClass or IsCheckBackUpContexts
'*
'* Description:
'*     "in_out_LeafPathDictionary" is as dictionary of path of exist file or folder.
'***********************************************************************
Sub  AttachPatchAndBackUpDictionary( in_out_LeafPathDictionary, _
		in_PatchAndBackUpDictionary,  in_RootPathInLeafPath,  in_out_Options )

	'// debug_path = "MoveAndModifyFromPrimaryToA.txt"

	Const  c_NotCaseSensitive = 1

	Set attached = CreateObject( "Scripting.Dictionary" )
	attached.CompareMode = c_NotCaseSensitive

	If IsEmpty( in_out_LeafPathDictionary ) Then
		Set in_out_LeafPathDictionary = EnumerateToLeafPathDictionary( in_RootPathInLeafPath )
	End If
	Set leafs = in_out_LeafPathDictionary
	If VarType( in_PatchAndBackUpDictionary ) = vbString Then
		Set patch_ = EnumerateToPatchAndBackUpDictionary( in_PatchAndBackUpDictionary )
	Else
		Set patch_ = in_PatchAndBackUpDictionary
	End If
	ParseOptionArguments  in_out_Options
	If not in_out_Options.Exists("Boolean") Then _
		in_out_Options("Boolean") = False

	leaf_root = GetPathWithSeparator( GetFullPath( in_RootPathInLeafPath, Empty ) )

	Assert  IsFullPath( patch_.BackUpRootPath )
	Assert  IsFullPath( patch_.PatchRootPath )


	'// Add "patch_.BackUpPaths.Key" to "leafs".
	'// Add "patch_.PatchPaths.Key" of modifing file to "leafs".
	step_path_offset = Len( GetPathWithSeparator( patch_.BackUpRootPath ) ) + 1
	For Each  back_up_path  In  patch_.BackUpPaths.Keys

		If not IsEmpty( debug_path ) Then  If InStr( back_up_path, debug_path ) >= 1 Then  Stop

		step_path = Mid( back_up_path,  step_path_offset )
		path_in_leafs = leaf_root + step_path
		If leafs.Exists( path_in_leafs ) Then
			real_path_in_leafs = leafs( path_in_leafs ).Name
			back_up_real_path = patch_.BackUpPaths( back_up_path ).Name
			Assert  not IsArray( real_path_in_leafs )
				'// マージが済んでいないファイルにパッチをあてることはできません
			in_leafs_hash = g_FileHashCache( real_path_in_leafs )
			back_up_hash = g_FileHashCache( back_up_real_path )
			patch_path = patch_.PatchRootPath +"\"+ step_path
			If patch_.PatchPaths.Exists( patch_path ) Then
				patch_real_path = patch_.PatchPaths( patch_path ).Name
			Else
				patch_real_path = Empty
			End If
			patch_hash = g_FileHashCache( patch_real_path )

			If in_leafs_hash = back_up_hash  or  IsEmpty( real_path_in_leafs ) Then
				If patch_hash <> back_up_hash Then
					leafs( path_in_leafs ).Name = patch_real_path
				Else
					leafs( path_in_leafs ).Name = real_path_in_leafs
				End If
			ElseIf patch_real_path = ""  and  in_leafs_hash = ""  and  back_up_hash <> "" Then
				leafs( path_in_leafs ).Name = Empty
			ElseIf IsEmpty( back_up_real_path )  and  IsEmpty( patch_real_path ) Then
			Else
				If in_out_Options("Boolean") Then
					string_ = ""
					If back_up_path <> path_in_leafs Then _
						string_ = string_ + """ back_up="""+ back_up_path
					If back_up_real_path <> back_up_path Then _
						string_ = string_ + """ back_up_real="""+ back_up_real_path

					Raise  E_NotExpectedBackUp, _
						"<ERROR msg=""バックアップの内容が期待した内容と異なります。"""+_
						" target="""+ path_in_leafs + string_ +"""/>"
				Else

					leafs( path_in_leafs ).Name = Array( _
						back_up_real_path, _
						real_path_in_leafs, _
						patch_real_path, _
						in_out_Options("ThreeWayMergeOptionClass") )
				End If
			End If

			attached( path_in_leafs ) = True
		ElseIf back_up_path <> patch_.BackUpRootPath Then  '// If not empty folder
			If in_out_Options("Boolean") Then
				Raise  E_NotExpectedBackUp, _
					"<ERROR msg=""バックアップにあるファイルが存在しません。"""+_
					" target="""+ path_in_leafs +""" back_up="""+ back_up_path +"""/>"
			End If
		End If
	Next

	Const  error_message_1 = "バックアップ（想定ファイル）がないパッチで、ファイルを変更しようとしています。"


	'// Add "patch_.PatchPaths.Key" of new file to "leafs".
	step_path_offset = Len( GetPathWithSeparator( patch_.PatchRootPath ) ) + 1
	For Each  patch_path  In  patch_.PatchPaths.Keys

		If not IsEmpty( debug_path ) Then  If InStr( patch_path, debug_path ) >= 1 Then  Stop

		path_in_leafs = leaf_root + Mid( patch_path,  step_path_offset )
		If not attached.Exists( path_in_leafs ) Then
			If leafs.Exists( path_in_leafs ) Then
				real_path_in_leafs = leafs( path_in_leafs ).Name
				patch_real_path = patch_.PatchPaths( patch_path ).Name
				If IsEmpty( real_path_in_leafs ) Then
					leafs( path_in_leafs ).Name = patch_real_path
				ElseIf IsEmpty( patch_real_path ) Then
				ElseIf not IsArray( real_path_in_leafs ) Then  '// Array was set at BackUpPaths
					If in_out_Options("Boolean") Then
						Raise  E_Conflict, _
							"<ERROR msg="""+ error_message_1 +""""+_
							" target="""+ path_in_leafs +""" patch_="""+ patch_real_path +"""/>"
					Else
						leafs( path_in_leafs ).Name = Array( _
							Empty, _
							real_path_in_leafs, _
							patch_real_path, _
							in_out_Options("ThreeWayMergeOptionClass") )
					End If
				End If
			Else
				Set leafs( path_in_leafs ) = new_NameOnlyClass( _
					patch_.PatchPaths( patch_path ).Name,  Empty )
			End If

			attached( path_in_leafs ) = True
		End If
	Next

	If g_Vers("ExpandWildcard_Sort") Then
		QuickSortDicByKey  leafs
	End If
End Sub


 
'* Section: Global
 
