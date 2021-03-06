Sub  Main( Opt, AppKey )
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array( _
			"1","T_Grep1", _
			"2","T_GrepClass1", _
			"3","T_grep_sth", _
			"4","T_grep_stdout", _
			"5","T_GrepKeyword" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_Grep1] >>> 
'********************************************************************************
Sub  T_Grep1( Opt, AppKey )
	Set ds_= new CurDirStack
	Set section = new SectionTree
'//SetStartSectionTree  "T_Grep_I_Option"


	For Each  t  In DicTable( Array( _
		"CaseName",  "Option",  "Suffix",   Empty, _
		"ShiftJIS",  "",        "", _
		"Unicode",   "-u ",     "_U" ) )

	pushd  "grep_target"


	'//=== -r option
	If section.Start( "T_Grep_R_Option"+ t("Suffix") ) Then
		founds = grep( t("Option")+ "-r define *", Empty )
		Assert  UBound( founds ) = 4-1
		ShakerSort  founds, 0, UBound(founds), GetRef("T_Grep1_compare"), Empty

		Assert  founds(0).Path     = "grep_target1.txt"
		Assert  founds(0).LineNum  = 2
		Assert  founds(0).LineText = "  define string"

		Assert  founds(1).Path     = "grep_target3.txt"
		Assert  founds(1).LineNum  = 2
		Assert  founds(1).LineText = "  define string"

		Assert  founds(2).Path     = "grep_target3.txt"
		Assert  founds(2).LineNum  = 4
		Assert  founds(2).LineText = "  define C:\File.txt"

		Assert  founds(3).Path     = "sub\grep_target1.txt"
		Assert  founds(3).LineNum  = 2
		Assert  founds(3).LineText = "  define string"
	End If : section.End_


	'//=== not -r option
	If section.Start( "T_Grep_Not_R_Option"+ t("Suffix") ) Then
		founds = grep( t("Option")+ "string *", Empty )
		Assert  UBound( founds ) = 2-1
		ShakerSort  founds, 0, UBound(founds), GetRef("T_Grep1_compare"), Empty

		Assert  founds(0).Path     = "grep_target1.txt"
		Assert  founds(0).LineNum  = 2
		Assert  founds(0).LineText = "  define string"

		Assert  founds(1).Path     = "grep_target3.txt"
		Assert  founds(1).LineNum  = 2
		Assert  founds(1).LineText = "  define string"
	End If : section.End_


	If section.Start( "T_Grep_Include"+ t("Suffix") ) Then

		'//=== -r, --include option (1)
		founds = grep( t("Option")+ "-r --include=""*.txt"" define *", Empty )
		Assert  UBound( founds ) = 4-1
		ShakerSort  founds, 0, UBound(founds), GetRef("T_Grep1_compare"), Empty

		'//=== -r, --include option (2)
		founds = grep( t("Option")+ "-r --include=""*.txt"" define sub\*", Empty )
		Assert  UBound( founds ) = 1-1
		ShakerSort  founds, 0, UBound(founds), GetRef("T_Grep1_compare"), Empty

		Assert  founds(0).Path     = "sub\grep_target1.txt"
		Assert  founds(0).LineNum  = 2
		Assert  founds(0).LineText = "  define string"
	End If : section.End_


	If section.Start( "T_Grep_I_Option"+ t("Suffix") ) Then

		'//==== -i option
		founds = grep( t("Option")+ "-i -r File\.txt *", Empty )
		Assert  UBound( founds ) = 1-1
		ShakerSort  founds, 0, UBound(founds), GetRef("T_Grep1_compare"), Empty

		Assert  founds(0).Path     = "grep_target3.txt"
		Assert  founds(0).LineNum  = 4
		Assert  founds(0).LineText = "  define C:\File.txt"

		'//==== not -i option
		founds = grep( t("Option")+ "-r Text *", Empty )
		Assert  UBound( founds ) = 0-1
		ShakerSort  founds, 0, UBound(founds), GetRef("T_Grep1_compare"), Empty
	End If : section.End_


	'//=== -l option
	If section.Start( "T_Grep_l_Option"+ t("Suffix") ) Then
		founds = grep( t("Option")+ "-r -l define *", Empty )
		Assert  UBound( founds ) = 3-1
		Assert  IsSameArrayOutOfOrder( _
			Array( founds(0).Path, founds(1).Path, founds(2).Path ), _
			Array( "grep_target1.txt", "grep_target3.txt", "sub\grep_target1.txt" ), _
			Empty )
	End If : section.End_


	'//=== -L option
	'//=== sub folder (1)
	If section.Start( "T_Grep_L_Option"+ t("Suffix") ) Then
		founds = grep( t("Option")+ "-r -L define ..\grep_target_not", Empty )
		Assert  UBound( founds ) = 4-1
		Assert  IsSameArrayOutOfOrder( _
			Array( founds(0).Path, founds(1).Path, founds(2).Path, founds(3).Path ), _
			Array( _
				"..\grep_target_not\grep_target2.txt", _
				"..\grep_target_not\grep_target2same.txt", _
				"..\grep_target_not\sub\grep_target2.txt", _
				"..\grep_target_not\sub\grep_target2same.txt" ), _
			Empty )


		founds = grep( t("Option")+ "-r -L define ..\grep_target_not\*same.txt", Empty )
		Assert  UBound( founds ) = 2-1
		Assert  IsSameArrayOutOfOrder( _
			Array( founds(0).Path, founds(1).Path ), _
			Array( _
				"..\grep_target_not\grep_target2same.txt", _
				"..\grep_target_not\sub\grep_target2same.txt" ), _
			Empty )
	End If : section.End_


	'//=== -c option
	If section.Start( "T_Grep_c_Option"+ t("Suffix") ) Then
		founds = grep( t("Option")+ "-r -c define ..\grep_target_not", Empty )
		Assert  UBound( founds ) = 6-1
		Assert  IsSameArrayOutOfOrder( _
			Array( founds(0).Path, founds(1).Path, founds(2).Path, founds(3).Path, _
				founds(4).Path, founds(5).Path ), _
			Array( _
				"..\grep_target_not\grep_target1.txt", _
				"..\grep_target_not\grep_target2.txt", _
				"..\grep_target_not\grep_target2same.txt", _
				"..\grep_target_not\sub\grep_target1.txt", _
				"..\grep_target_not\sub\grep_target2.txt", _
				"..\grep_target_not\sub\grep_target2same.txt" ), _
			Empty )
	End If : section.End_


	'//=== Single file path
	If section.Start( "T_Grep_SingleFilePath"+ t("Suffix") ) Then
		For Each  sub_option  In Array( "", "-r " )

			founds = grep( t("Option")+ sub_option +"define grep_target3.txt", Empty )
			Assert  UBound( founds ) = 2-1

			Assert  founds(0).Path = "grep_target3.txt"
			Assert  founds(0).LineNum  = 2
			Assert  founds(0).LineText = "  define string"

			Assert  founds(1).Path = "grep_target3.txt"
			Assert  founds(1).LineNum  = 4
			Assert  founds(1).LineText = "  define C:\File.txt"
		Next

		pushd  ".."
		For Each  sub_option  In Array( "", "-r " )

			founds = grep( t("Option")+ sub_option +"define grep_target\grep_target3.txt", Empty )
			Assert  UBound( founds ) = 2-1

			Assert  founds(0).Path = "grep_target\grep_target3.txt"
			Assert  founds(0).LineNum  = 2
			Assert  founds(0).LineText = "  define string"

			Assert  founds(1).Path = "grep_target\grep_target3.txt"
			Assert  founds(1).LineNum  = 4
			Assert  founds(1).LineText = "  define C:\File.txt"
		Next
		popd
	End If : section.End_


	'//=== Multi file path
	If section.Start( "T_Grep_MultiFilePath"+ t("Suffix") ) Then
		founds = grep( t("Option")+ "-r -l define *t1.txt *t3.txt", Empty )
		Assert  UBound( founds ) = 3-1
		Assert  IsSameArrayOutOfOrder( _
			Array( founds(0).Path, founds(1).Path, founds(2).Path ), _
			Array( "grep_target1.txt", "grep_target3.txt", "sub\grep_target1.txt" ), _
			Empty )

		founds = grep( t("Option")+ "-r -l define *t3.txt", Empty )
		Assert  UBound( founds ) = 1-1
		Assert  founds(0).Path = "grep_target3.txt"

		founds = grep( t("Option")+ "-l define *t1.txt *t3.txt", Empty )
		Assert  UBound( founds ) = 2-1
		Assert  IsSameArrayOutOfOrder( _
			Array( founds(0).Path, founds(1).Path ), _
			Array( "grep_target1.txt", "grep_target3.txt" ), _
			Empty )
	End If : section.End_


	popd


	'//=== sub folder (2)
	If section.Start( "T_Grep_SubFolder"+ t("Suffix") ) Then

		founds = grep( t("Option")+ "-r define grep_target\*", Empty )
		Assert  UBound( founds ) = 4-1
		ShakerSort  founds, 0, UBound(founds), GetRef("T_Grep1_compare"), Empty

		Assert  founds(0).Path     = "grep_target\grep_target1.txt"
		Assert  founds(0).LineNum  = 2
		Assert  founds(0).LineText = "  define string"


		founds = grep( t("Option")+ "-r define grep_target", Empty )
		Assert  UBound( founds ) = 4-1
		ShakerSort  founds, 0, UBound(founds), GetRef("T_Grep1_compare"), Empty

		Assert  founds(0).Path     = "grep_target\grep_target1.txt"
		Assert  founds(0).LineNum  = 2
		Assert  founds(0).LineText = "  define string"


		pushd  "grep_target"

		founds = grep( t("Option")+ "-r define ..\grep_target\*", Empty )
		Assert  UBound( founds ) = 4-1
		ShakerSort  founds, 0, UBound(founds), GetRef("T_Grep1_compare"), Empty

		Assert  founds(0).Path     = "..\grep_target\grep_target1.txt"
		Assert  founds(0).LineNum  = 2
		Assert  founds(0).LineText = "  define string"

		popd
	End If : section.End_


	'//=== full path
	If section.Start( "T_Grep_FullPath"+ t("Suffix") ) Then

		current = g_sh.CurrentDirectory
		founds = grep( t("Option")+ "-r define """+ current +"\grep_target\*""", Empty )
		Assert  UBound( founds ) = 4-1
		ShakerSort  founds, 0, UBound(founds), GetRef("T_Grep1_compare"), Empty

		Assert  founds(0).Path     = current +"\grep_target\grep_target1.txt"
		Assert  founds(0).LineNum  = 2
		Assert  founds(0).LineText = "  define string"
	End If : section.End_


	'//=== not found folder/file
	If section.Start( "T_Grep_NotFoundFolderFile"+ t("Suffix") ) Then
		founds = grep( t("Option")+ "-r define not_found\*", Empty )
		Assert  UBound( founds ) = 0-1

		founds = grep( t("Option")+ "define not_found_file", Empty )
		Assert  UBound( founds ) = 0-1

		founds = grep( t("Option")+ "NotFound  grep_target\grep_target1.txt", Empty )
		Assert  UBound( founds ) = 0-1
	End If : section.End_


	'//=== '|' expression is not pipe
	If section.Start( "T_Grep_Or"+ t("Suffix") ) Then
		founds = grep( t("Option")+ "-r ""define|string"" grep_target\grep_target3.txt", Empty )
		Assert  UBound( founds ) = 2-1
		Assert  founds(0).LineNum = 2
		Assert  founds(1).LineNum = 4

		founds = grep( t("Option")+ "-r ""define|\||string"" grep_target\grep_target3.txt", Empty )
		Assert  UBound( founds ) = 3-1
		Assert  founds(0).LineNum = 2
		Assert  founds(1).LineNum = 4
		Assert  founds(2).LineNum = 5
	End If : section.End_


	'//=== space
	If section.Start( "T_Grep_Space"+ t("Suffix") ) Then
		founds = grep( t("Option")+ "-r ""define string"" grep_target\grep_target3.txt", Empty )
		Assert  UBound( founds ) = 1-1

		founds = grep( t("Option")+ "-r ""\""quot and space\"""" grep_target\grep_target4.txt", Empty )
		Assert  UBound( founds ) = 1-1
	End If : section.End_


	'//=== Line feed in keyword for grep without unicode option
	If t("CaseName") <> "Unicode" Then
	If section.Start( "T_Grep_LF" ) Then
		echo  vbCRLF+"Next is Error Test"
		If TryStart(e) Then  On Error Resume Next

			founds = grep( t("Option")+ "-r ""string"+ vbCRLF +"middle"" grep_target\grep_target3.txt", Empty )

		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '//[out] e2
		echo    e2.desc
		Assert  e2.num <> 0


		echo  vbCRLF+"Next is Error Test"
		If TryStart(e) Then  On Error Resume Next

			founds = grep( t("Option")+ "-r string"+ vbCRLF +"middle grep_target\grep_target3.txt", Empty )

		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '//[out] e2
		echo    e2.desc
		Assert  e2.num <> 0


		echo  vbCRLF+"Next is Error Test"
		If TryStart(e) Then  On Error Resume Next

			founds = grep( t("Option")+ "-r """" grep_target\grep_target3.txt", Empty )

		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '//[out] e2
		echo    e2.desc
		Assert  e2.num <> 0
	End If : section.End_
	End If


	'//=== Line feed in keyword for grep with unicode option
	If t("CaseName") = "Unicode" Then
	If section.Start( "T_Grep_LF_U" ) Then
		founds = grep( t("Option")+ "-r ""string"+ vbCRLF +"middle"" grep_target\grep_target3.txt", Empty )
		Assert  UBound( founds ) = 1-1

		founds = grep( t("Option")+ "-r string"+ vbCRLF +"middle grep_target\grep_target3.txt", Empty )
		Assert  UBound( founds ) = 1-1


		echo  vbCRLF+"Next is Error Test"
		If TryStart(e) Then  On Error Resume Next

			founds = grep( t("Option")+ "-r """" grep_target\grep_target3.txt", Empty )

		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '//[out] e2
		echo    e2.desc
		Assert  e2.num <> 0
	End If : section.End_
	End If


	'//=== +
	If section.Start( "T_Grep_Plus"+ t("Suffix") ) Then
		founds = grep( t("Option")+ "-r ""ax+"" grep_target\grep_target6.txt", Empty )
		Set founds = MakeFoundsDictionary( founds )
		Assert  not founds.Exists( "a" )
		Assert      founds.Exists( "ax" )

		founds = grep( t("Option")+ "-r ""a[a-z]+"" grep_target\grep_target6.txt", Empty )
		Set founds = MakeFoundsDictionary( founds )
		Assert  not founds.Exists( "a" )
		Assert      founds.Exists( "ax" )

		founds = grep( t("Option")+ "-r ""b\]+"" grep_target\grep_target6.txt", Empty )
		Set founds = MakeFoundsDictionary( founds )
		Assert  not founds.Exists( "b" )
		Assert      founds.Exists( "b]" )
	End If : section.End_


	'//=== search option start characters "/", "-"
	If section.Start( "T_Grep_OptionCharacters"+ t("Suffix") ) Then
		founds = grep( t("Option")+ "-r ""\-a"" grep_target\grep_target5.txt", Empty ) '// search "-a"
		Assert  UBound( founds ) = 2-1

		founds = grep( t("Option")+ "-r ""\\-a"" grep_target\grep_target5.txt", Empty ) '// search "-a"
		Assert  UBound( founds ) = 2-1

		founds = grep( t("Option")+ "-r ""\\\-a"" grep_target\grep_target5.txt", Empty ) '// search "\-a"
		Assert  UBound( founds ) = 1-1

		founds = grep( t("Option")+ "-r ""\\\\-a"" grep_target\grep_target5.txt", Empty ) '// search "\-a"
		Assert  UBound( founds ) = 1-1

		founds = grep( t("Option")+ "-r ""/a"" grep_target\grep_target5.txt", Empty ) '// search "/a"
		Assert  UBound( founds ) = 2-1

		founds = grep( t("Option")+ "-r ""\/a"" grep_target\grep_target5.txt", Empty ) '// search "/a"
		Assert  UBound( founds ) = 2-1

		founds = grep( t("Option")+ "-r ""\\/a"" grep_target\grep_target5.txt", Empty ) '// search "/a"
		Assert  UBound( founds ) = 2-1

		founds = grep( t("Option")+ "-r ""\\\/a"" grep_target\grep_target5.txt", Empty ) '// search "\/a"
		Assert  UBound( founds ) = 1-1

		founds = grep( t("Option")+ "-r ""\\\\/a"" grep_target\grep_target5.txt", Empty ) '// search "\/a"
		Assert  UBound( founds ) = 1-1
	End If : section.End_


	'//=== Few parameters
	If section.Start( "T_Grep_FewParameters"+ t("Suffix") ) Then

		echo  vbCRLF+"Next is Error Test"
		If TryStart(e) Then  On Error Resume Next

			founds = grep( t("Option")+ "-r grep_target\grep_target5.txt", Empty )

		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '//[out] e2
		echo    e2.desc
		Assert  InStr( e2.desc, "パラメーターが少ない" ) > 0
		Assert  e2.num <> 0

	End If : section.End_


	Next  '// DicTable


	Pass
End Sub


Function  T_Grep1_compare( Left, Right, Param )
	If Left.Path > Right.Path Then
		T_Grep1_compare = +1
	Else
		T_Grep1_compare = -1
	End If
End Function


 
'********************************************************************************
'  <<< [MakeFoundsDictionary] >>> 
'********************************************************************************
Function  MakeFoundsDictionary( Founds )
	Set dic = CreateObject( "Scripting.Dictionary" )
	For Each  found  In  Founds
		dic( found.LineText ) = True
	Next
	Set MakeFoundsDictionary = dic
End Function


 
'********************************************************************************
'  <<< [T_GrepClass1] >>> 
'********************************************************************************
Sub  T_GrepClass1( Opt, AppKey )
	Set section = new SectionTree
'//SetStartSectionTree  "T_GrepClass_MultiFilePath"

	g_Vers("ExpandWildcard_Sort") = True

	pushd  "grep_target"


	'//=== Multi file path
	If section.Start( "T_GrepClass_MultiFilePath" ) Then
	For Each  is_no_pattern  In  Array( False, True )
		Set a_grep = new GrepClass
		a_grep.IsRecurseSubFolders = True
		a_grep.IsOutFileNameOnly = True
		If is_no_pattern Then
			a_grep.Pattern = ""
		Else
			a_grep.Pattern = "define"
		End If
		founds = a_grep.Execute( Array( "*1.txt", "*3.txt" ) )
		Assert  UBound( founds ) = 3-1
		Assert  IsSameArrayOutOfOrder( _
			Array( founds(0).Path, founds(1).Path, founds(2).Path ), _
			Array( "grep_target1.txt", "grep_target3.txt", "sub\grep_target1.txt" ), _
			Empty )

		Set a_grep = new GrepClass
		a_grep.IsRecurseSubFolders = True
		a_grep.IsOutFileNameOnly = True
		If is_no_pattern Then
			a_grep.Pattern = ""
		Else
			a_grep.Pattern = "define"
		End If
		founds = a_grep.Execute( "*3.txt" )
		Assert  UBound( founds ) = 1-1
		Assert  founds(0).Path = "grep_target3.txt"

		Set a_grep = new GrepClass
		a_grep.IsOutFileNameOnly = True
		If is_no_pattern Then
			a_grep.Pattern = ""
		Else
			a_grep.Pattern = "define"
		End If
		founds = a_grep.Execute( Array( "*1.txt", "*3.txt" ) )
		Assert  UBound( founds ) = 2-1
		Assert  IsSameArrayOutOfOrder( _
			Array( founds(0).Path, founds(1).Path ), _
			Array( "grep_target1.txt", "grep_target3.txt" ), _
			Empty )

		Set a_grep = new GrepClass
		a_grep.IsOutFileNameOnly = True
		If is_no_pattern Then
			a_grep.Pattern = ""
		Else
			a_grep.Pattern = "define"
		End If
		founds = a_grep.Execute( ArrayFromWildcard( Array( "*1.txt", "*3.txt" ) ) )
		Assert  UBound( founds ) = 3-1
		Assert  IsSameArrayOutOfOrder( _
			Array( founds(0).Path, founds(1).Path, founds(2).Path ), _
			Array( "grep_target1.txt", "grep_target3.txt", "sub\grep_target1.txt" ), _
			Empty )

		Set a_grep = new GrepClass
		a_grep.IsOutFileNameOnly = True
		If is_no_pattern Then
			a_grep.Pattern = ""
		Else
			a_grep.Pattern = "define"
		End If
		Set paths = ArrayFromWildcard( Array( "*1.txt", "*3.txt" ) )
		paths.AddRemove  "grep_target1.txt"
		founds = a_grep.Execute( paths )
		Assert  UBound( founds ) = 2-1
		Assert  IsSameArrayOutOfOrder( _
			Array( founds(0).Path, founds(1).Path ), _
			Array( "grep_target3.txt", "sub\grep_target1.txt" ), _
			Empty )
	Next
	End If : section.End_


	popd

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_grep_sth] >>> 
'********************************************************************************
Sub  T_grep_sth( Opt, AppKey )
	Set w_= AppKey.NewWritable( Array(_
		"out.txt", "out_sorted.txt", "_T_grep_sth_ans_sorted.txt" ) ).Enable()

	For Each  unicode_option  In Array( """""", "-u" )
	For Each  is_redirect  In Array( True, False )
		If is_redirect Then
			out_path = " """""
			redirect_path = "out.txt"
		Else
			out_path = " out.txt"
			redirect_path = ""
		End If


		'// Test Main
		r = RunProg( "cscript.exe  //nologo """+ SearchParent( "vbslib Prompt.vbs" )+_
			""" /silent grep grep_target define "+ unicode_option + out_path +" n",_
			redirect_path )


		'// Check
		CheckTestErrLevel  r
		OpenForReplace( "out.txt", Empty ).Replace  g_sh.CurrentDirectory, "FullPath(.)"
		RunProg  "cmd /c SORT out.txt /o out_sorted.txt", ""
		If is_redirect Then
			If unicode_option = """""" Then

				AssertFC  "out_sorted.txt", "T_grep_sth_ans.txt"
			Else
				AssertFC  "out_sorted.txt", "T_grep_u_sth_ans.txt"
			End If
		Else
			AssertFC  "out_sorted.txt", "T_grep_out_ans.txt"
		End If
		del  "out.txt"
		del  "out_sorted.txt"


		'//=== '|' expression is not pipe
		r = RunProg( "cscript.exe  //nologo """+ SearchParent( "vbslib Prompt.vbs" )+_
			""" /silent grep grep_target ""middle | text"" "+ unicode_option + out_path +" n",_
			redirect_path )
		CheckTestErrLevel  r
		Assert  exist( "out.txt" )
		del  "out.txt"
	Next
	Next

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_grep_stdout] >>> 
'********************************************************************************
Sub  T_grep_stdout( Opt, AppKey )
	Set w_= AppKey.NewWritable( Array( "_out.txt" ) ).Enable()

	RunProg  "cscript //nologo "+ WScript.ScriptName +" T_grep_stdout_Sub", "_out.txt"

	If IsSameTextFile( "_out.txt", "T_grep_stdout_ans_typeA.txt", Empty ) Then
		'// Pass
	ElseIf IsSameTextFile( "_out.txt", "T_grep_stdout_ans_typeB.txt", Empty ) Then
		'// Pass
	Else
		Fail
	End If
	del  "_out.txt"

	Pass
End Sub


Sub  T_grep_stdout_Sub( Opt, AppKey )
	Set w_= AppKey.NewWritable( Array( "_out2.txt" ) ).Enable()
	g_Vers("ExpandWildcard_Sort") = True

	For Each  out  In Array( Empty, "" )
		echo  "----"
		grep  "-r define grep_target\sub\*", out
		grep  "-r -l define grep_target\sub\*", out
		grep  "-u -r define grep_target\sub\*", out
		grep  "-u -r -l define grep_target\sub\*", out
	Next


	For Each  out  In Array( Empty, "" )
		echo  "----2"
		echo  "If not -u option, any file list order is OK."
			'// -u オプションがないときは、見つかったパスの順番は問わない。
			'// なぜなら、findstr で表示しながら検索するため。
		grep  "-r ""define"" grep_target", out
		grep  "-r -l ""define"" grep_target", out
		grep  "-r -L ""define"" grep_target_not", out
		grep  "-r -c ""define"" grep_target_not", out
		grep  "-u -r ""define"" grep_target", out
		grep  "-u -r -l ""define"" grep_target", out
		grep  "-u -r -L ""define"" grep_target_not", out
		grep  "-u -r -c ""define"" grep_target_not", out
	Next


	'// ...
	For Each  is_echo_off  In Array( False, True )

		echo  "---- start"
		If is_echo_off Then  Set ec = new EchoOff

		grep  "-r define grep_target\sub\*", "_out2.txt"
		Assert  ReadFile( "_out2.txt" ) = _
			"grep_target\sub\grep_target1.txt:2:  define string"+ vbCRLF

		grep  "-r -l define grep_target\sub\*", "_out2.txt"
		Assert  ReadFile( "_out2.txt" ) = _
			"grep_target\sub\grep_target1.txt"+ vbCRLF

		grep  "-u -r define grep_target\sub\*", "_out2.txt"
		Assert  ReadFile( "_out2.txt" ) = _
			"grep_target\sub\grep_target1.txt:2:  define string"+ vbCRLF

		grep  "-u -r -l define grep_target\sub\*", "_out2.txt"
		Assert  ReadFile( "_out2.txt" ) = _
			"grep_target\sub\grep_target1.txt"+ vbCRLF

		If is_echo_off Then  ec = Empty
		echo  "---- end"
	Next


	del  "_out2.txt"
End Sub


 
'********************************************************************************
'  <<< [T_GrepKeyword] >>> 
'********************************************************************************
Sub  T_GrepKeyword( Opt, AppKey )
	same_patterns = Array( _
		"/c",   "/c",       "/c", _
		"-a",   "\-a",      "\-a", _
		"-",    "-",        "-", _
		"--",   "\--",      "\--", _
		"c-",   "c-",       "c-", _
		"\",    "\\\\",     "\\\\", _
		"\\",   "\\\\\\\\", "\\\\\\\\", _
		". $ ^ ( ) { } [ ] * + ? | \", _
			"\\. \\$ \\^ ( ) { } \\[ \\] \\* + ? | \\\\", _
			"\\. \\$ \\^ \\( \\) \\{ \\} \\[ \\] \\* \\+ \\? \\| \\\\", _
		"abc[0]\def", _
			"abc\\[0\\]\\\\def", _
			"abc\\[0\\]\\\\def" )

	For i=0 To UBound( same_patterns ) Step 3
		Assert  GrepKeyword(  same_patterns(i) ) = same_patterns(i+1)
		Assert  EGrepKeyword( same_patterns(i) ) = same_patterns(i+2)
	Next


	same_patterns = Array( _
		"---\(", "\---\\(", _
		"abc[A-Z]\def", "abc[A-Z]\\def" )

	For i=0 To UBound( same_patterns ) Step 2
		Assert  GrepExpression( same_patterns(i) ) = same_patterns(i+1)
	Next

	Pass
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
	g_Vers("vbslib") = 99.99
	'// g_Vers("OldMain") = 1
	g_vbslib_path = "scriptlib\vbs_inc.vbs"
	g_CommandPrompt = 1
	g_debug = 0
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------

 
