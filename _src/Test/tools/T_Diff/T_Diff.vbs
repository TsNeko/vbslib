Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_ThreeWayMerge", _
			"2","T_ThreeWayMerge_Cached", _
			"3","T_ThreeWayMerge_AutoMergeEx", _
			"4","T_ThreeWayMerge_autoMergeExSub", _
			"5","T_ThreeWayMergeBatch", _
			"6","T_ThreeWayMerge_sth", _
			"7","T_Diff", _
			"8","T_Patch", _
			"9","T_PatchAndBackUp_Conflict", _
			"10","T_DiffWithoutKS" ))
			'// "6","T_FourWayMerge"
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'***********************************************************************
'* Function: T_ThreeWayMerge
'***********************************************************************
Sub  T_ThreeWayMerge( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( _
		"_Merged.txt", "_UTF-8", "_Unicode", "_LF", "_NoBase", "_NoBaseEmpty" ) ).Enable()
	Set c = g_VBS_Lib
	Set section = new SectionTree
'//SetStartSectionTree  "T_ThreeWayMerge__NoBaseEmpty_1"

	Set merge = new ThreeWayMergeOptionClass
	merge.IsAutoMergeEx = False

	For Each  base  In  Array( "Files\1", "Files\Conflict", _
			"_UTF-8\1", "_UTF-8\Conflict", "_Unicode\1", "_Unicode\Conflict", "_LF\1", "_LF\Conflict", _
			"_NoBase\Conflict", "_NoBaseEmpty\Conflict" )
'//[TODO]			"_NoBase\1", "_NoBase\Conflict", "_NoBaseEmpty\1", "_NoBaseEmpty\Conflict" )
		If section.Start( "T_ThreeWayMerge_"+ Replace( base, "\", "_" ) ) Then


		'// Set up : Copy "Files" to "${CharacterCodeSetName}"
		Set ec = new EchoOff
		If InStr( base, "_UTF-8" ) > 0 Then
			del  base
			ExpandWildcard  Replace( base, "_UTF-8", "Files" ) + "\*", _
				c.File, folder, step_paths
			For Each step_path  In step_paths
				text = ReadFile( GetFullPath( step_path, folder ) )
				Set cs = new_TextFileCharSetStack( "UTF-8" )
				CreateFile  GetFullPath( step_path, GetFullPath( base, Empty ) ), text
				cs = Empty
			Next
		ElseIf InStr( base, "_Unicode" ) > 0 Then
			del  base
			ExpandWildcard  Replace( base, "_Unicode", "Files" ) + "\*", _
				c.File, folder, step_paths
			For Each step_path  In step_paths
				text = ReadFile( GetFullPath( step_path, folder ) )
				Set cs = new_TextFileCharSetStack( "Unicode" )
				CreateFile  GetFullPath( step_path, GetFullPath( base, Empty ) ), text
				cs = Empty
			Next
		ElseIf InStr( base, "_LF" ) > 0 Then
			del  base
			ExpandWildcard  Replace( base, "_LF", "Files" ) + "\*", _
				c.File, folder, step_paths
			For Each step_path  In step_paths
				text = ReadFile( GetFullPath( step_path, folder ) )
				text = Replace( text, vbCRLF, vbLF )
				CreateFile  GetFullPath( step_path, GetFullPath( base, Empty ) ), text
			Next
		ElseIf InStr( base, "_NoBase" ) > 0 Then
			del  base
			copy  "Files\1\*", base
			del  base +"\Base.txt"
			copy_ren  "Files\MergedAnswer"+ g_fs.GetParentFolderName( base ) +".txt", _
				base +"\MergedAnswer.txt"
		End If
		ec = Empty


		'// Test Main
		If InStr( base, "Conflict" ) = 0 Then
			If InStr( base, "_NoBaseEmpty" ) = 0 Then
				ThreeWayMerge  base +"\Base.txt", base +"\Left.txt", base +"\Right.txt", _
					"_Merged.txt", merge
			Else
				ThreeWayMerge  Empty, base +"\Left.txt", base +"\Right.txt", _
					"_Merged.txt", merge
			End If
		Else
			echo  vbCRLF+"Next is Error Test"
			If TryStart(e) Then  On Error Resume Next

				If InStr( base, "_NoBaseEmpty" ) = 0 Then
					ThreeWayMerge  base +"\Base.txt", base +"\Left.txt", base +"\Right.txt", _
						"_Merged.txt", merge
				Else
					ThreeWayMerge  Empty, base +"\Left.txt", base +"\Right.txt", _
						"_Merged.txt", merge
				End If

			If TryEnd Then  On Error GoTo 0
			e.CopyAndClear  e2  '//[out] e2
			echo    e2.desc
			Assert  InStr( e2.desc, "Conflict" ) > 0
			Assert  e2.num = E_Conflict
		End If


		'// Check
		AssertFC  "_Merged.txt", base +"\MergedAnswer.txt"
		Assert  IsSameBinaryFile( "_Merged.txt", base +"\MergedAnswer.txt", Empty )

		If base = "Files\Conflict" Then
			SetFilesToReadOnly  g_fs.GetFolder( "Files\Conflict" )
		End If


		'// Clean
		del  "_Merged.txt"

		If InStr( base, "_UTF-8" ) > 0 Then
			del  "_UTF-8"
		End If
		If InStr( base, "_Unicode" ) > 0 Then
			del  "_Unicode"
		End If
		If InStr( base, "_LF" ) > 0 Then
			del  "_LF"
		ElseIf InStr( base, "_NoBase" ) > 0 Then
			del  "_NoBase"
			del  "_NoBaseEmpty"
		End If

		End If : section.End_
	Next

	Pass
End Sub


 
'***********************************************************************
'* Function: T_ThreeWayMerge_Cached
'***********************************************************************
Sub  T_ThreeWayMerge_Cached( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "_work" ) ).Enable()
	Set section = new SectionTree
'//SetStartSectionTree  "T_Make"


	'//===========================================================
	If section.Start( "T_MergeOfAdd" ) Then

	'// Set up
	del  "_work"
	copy  "Files\Patch\*", "_work"
	copy  "_work\02\*", "_work\MergedAnswer"
	CreateFile  "_work\01\Merge1.txt",                     Replace( "1/L/2/3/B/4/", "/", vbCRLF )
	CreateFile  "_work\02-Patch-of-01\back_up\Merge1.txt", Replace( "1/2/3/4/", "/", vbCRLF )
	CreateFile  "_work\02-Patch-of-01\patch\Merge1.txt",   Replace( "1/2/R/3/B/4/", "/", vbCRLF )
	CreateFile  "_work\MergedAnswer\Merge1.txt",           Replace( "1/L/2/R/3/B/4/", "/", vbCRLF )
	g_FileHashCache.RemoveAll

	'// Test Main
	patch_path = "_work\02-Patch-of-01"
	target_path = "_work\01"
	echo  ">AttachPatchAndBackUp  """+ target_path +""""
	Set ec = new EchoOff
	target = Empty
	Set patch_ = EnumerateToPatchAndBackUpDictionary( patch_path )
	AttachPatchAndBackUpDictionary  target, patch_, target_path, False
	CopyFilesToLeafPathDictionary  target, False
	ec = Empty

	'// Check
	Assert  fc( target_path, "_work\MergedAnswer" )

	'// Clean
	del  "_work"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_DoubleAdd" ) Then

	'// Set up
	del  "_work"
	copy  "Files\Patch\*", "_work"
	copy  "_work\02\*", "_work\MergedAnswer"
	CreateFile  "_work\01\Merge1.txt",                     Replace( "1/L/2/3/B/4/", "/", vbCRLF )
	CreateFile  "_work\02-Patch-of-01\patch\Merge1.txt",   Replace( "1/2/R/3/B/4/", "/", vbCRLF )
	CreateFile  "_work\MergedAnswer\Merge1.txt",           Replace( "1/L/2/R/3/B/4/", "/", vbCRLF )
	g_FileHashCache.RemoveAll

	'// Test Main
	patch_path = "_work\02-Patch-of-01"
	target_path = "_work\01"
	echo  ">AttachPatchAndBackUp  """+ target_path +""""
	target = Empty
	Set patch_ = EnumerateToPatchAndBackUpDictionary( patch_path )

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		AttachPatchAndBackUpDictionary  target, patch_, target_path, True

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  InStr( e2.desc, "Merge1.txt" ) > 0
	Assert  e2.num = E_Conflict

	'// Clean
	del  "_work"

	End If : section.End_

	Pass
End Sub


 
'***********************************************************************
'* Function: T_ThreeWayMerge_AutoMergeEx
'***********************************************************************
Sub  T_ThreeWayMerge_AutoMergeEx( Opt, AppKey )
	Set w_=AppKey.NewWritable( Array( "_Merged.txt" ) ).Enable()
	Set section = new SectionTree
'//SetStartSectionTree  "T_AutoMergeEx2_MergeTemplate_False_False"


	'//===========================================================
	For Each  is_setting_file  In Array( False, True )
	For Each  is_regular_expression  In Array( False, True )
	If section.Start( "T_AutoMergeEx_NotIsOutEach_" & is_setting_file & "_" & is_regular_expression ) Then

		If not is_setting_file Then
			Set merge = new ThreeWayMergeOptionClass
			If not is_regular_expression Then
				merge.SingletonKeywords = Array( "Single" )
				merge.UniqueLineKeywords = Array( "Unique" )
			Else
				merge.SingletonKeywords = Array( "S.ngle" )
				merge.UniqueLineKeywords = Array( "U.ique" )
			End If
		Else
			If not is_regular_expression Then
				Set merge = LoadThreeWayMergeOptionClass( "Files\MergeSetting.xml" )
			Else
				Set merge = LoadThreeWayMergeOptionClass( "Files\MergeSettingRegExp.xml" )
			End If
		End If
		base = "Files\Conflict"

		echo  vbCRLF+"Next is Error Test"
		If TryStart(e) Then  On Error Resume Next

			ThreeWayMerge  base +"\Base.txt", base +"\Left.txt", base +"\Right.txt", "_Merged.txt", merge

		If TryEnd Then  On Error GoTo 0
		e.CopyAndClear  e2  '//[out] e2
		echo    e2.desc
		Assert  InStr( e2.desc, "Conflict" ) > 0
		Assert  e2.num = E_Conflict

		AssertFC  "_Merged.txt", base +"\MergedAnswerEx.txt"
		del  "_Merged.txt"
	End If : section.End_
	Next
	Next


	'//===========================================================
	For Each  is_out_each  In Array( False, True )
	For Each  is_setting_file  In Array( False, True )
	If section.Start( "T_AutoMergeEx2_MergeTemplate_" & is_out_each & "_" & is_setting_file ) Then

		If not is_setting_file Then
			Set merge = new ThreeWayMergeOptionClass
			If is_out_each Then
				Set merge.MergeTemplate = new_ReplaceTemplateClass( "Files\Merge.E.replace.xml" )
			Else
				Set merge.MergeTemplate = new_ReplaceTemplateClass( "Files\Merge.C.replace.xml" )
			End If
			merge.IsOutEach = is_out_each
		Else
			If is_out_each Then
				Set merge = LoadThreeWayMergeOptionClass( "Files\MergeSetting2E.xml" )
			Else
				Set merge = LoadThreeWayMergeOptionClass( "Files\MergeSetting2C.xml" )
			End If
		End If

		base = "Files\Conflict"
		ThreeWayMerge  base +"\Base.txt", base +"\Left.txt", base +"\Right.txt", "_Merged.txt", merge

		AssertFC  "_Merged.txt", base +"\MergedAnswerEx2.txt"
		del  "_Merged.txt"

	End If : section.End_
	Next
	Next

	Pass
End Sub


 
'***********************************************************************
'* Function: T_ThreeWayMerge_autoMergeExSub
'***********************************************************************
Sub  T_ThreeWayMerge_autoMergeExSub( Opt, AppKey )
	Set w_=AppKey.NewWritable( "." ).Enable()
	infinite_count = 9999
	Set section = new SectionTree
'//SetStartSectionTree  "T_ThreeWayMerge_Modify5"


	'// Set up
	Set files = new MultiTextXML_Class
	For Each  test_prefix  In  Array( "Add", "Modify", "Delete", "Error" )
		For  test_num = 1  To  infinite_count
			test_ID = test_prefix + CStr( test_num )
			If not files.IsExist( "Files\AutoMergeEx.xml#"+ test_ID +"_Before" ) Then _
				Exit For


			If section.Start( "T_ThreeWayMerge_"+ test_ID ) Then


			'// Read a test case
			option_text   = files.GetText( "Files\AutoMergeEx.xml#"+ test_ID +"_MergeOption" )
			before_text   = files.GetText( "Files\AutoMergeEx.xml#"+ test_ID +"_Before" )
			expected_text = files.GetText( "Files\AutoMergeEx.xml#"+ test_ID +"_After" )
			is_conflicted = files.GetText( "Files\AutoMergeEx.xml#"+ test_ID +"_IsConflicted" )


			'// Set a test case
			If option_text = "Default" Then
				option1 = Empty
			ElseIf option_text = "OutEach" Then
				Set option1 = new ThreeWayMergeOptionClass
				option1.IsOutEach = True
			ElseIf option_text = "SingletonKeyword" Then
				Set option1 = new ThreeWayMergeOptionClass
				option1.SingletonKeywords = Array( "SingletonKeyword" )
			Else
				Assert  option_text = "UniqueLineKeyword"
				Set option1 = new ThreeWayMergeOptionClass
				option1.UniqueLineKeywords = Array( "UniqueLineKeyword" )
			End If
			If not IsEmpty( option1 ) Then
				Set merge = new ThreeWayMerge_AutoMergeExClass
				Set merge.Option_ = option1
			Else
				merge = Empty
			End If
			is_conflicted = ( StrComp( is_conflicted, "yes", 1 ) = 0 )


			If StrCompHeadOf( expected_text, "(BracketError)", Empty ) = 0 Then

				'// Error Handling Test
				echo  vbCRLF+"Next is Error Test"
				If TryStart(e) Then  On Error Resume Next

					ThreeWayMerge_autoMergeExSub  before_text, "Base.txt", "Left.txt", "Right.txt", _
						merge

				If TryEnd Then  On Error GoTo 0
				e.CopyAndClear  e2  '//[out] e2
				echo    e2.desc
				Assert  e2.num <> 0
			Else

				'// Test Main
				text = before_text
				ThreeWayMerge_autoMergeExSub  text, "Base.txt", "Left.txt", "Right.txt", _
					merge
					'//(out) merge


				'// Check
				If StrCompHeadOf( expected_text, "(ConflictError)", Empty ) = 0 Then
					Assert  text = before_text
					Assert  merge.IsConflicted
				Else
					Assert  text = expected_text
					Assert  merge.IsConflicted = is_conflicted
				End If
			End If

			End If : section.End_
		Next
	Next

	Pass
End Sub


 
'***********************************************************************
'* Function: T_ThreeWayMergeBatch
'***********************************************************************
Sub  T_ThreeWayMergeBatch( Opt, AppKey )

	'// Set up
	merged_path = "Files\Merge\03_Merged"
	Set w_= AppKey.NewWritable( Array( merged_path, "_out.txt" ) ).Enable()
	del  merged_path
	CreateFile  merged_path +"\dummy.txt", "x"  '// Not specified in setting file


	'// Test Main
	Set merge = new_ThreeWayMergeClass( "Files\Merge\MergeSetting.xml" )

	Set w_=AppKey.NewWritable( merge.Sync.GetWritableFolders() ).Enable()
	out_path = merge.Sync.Sets(0).NewWorkRootFullPath

	merge.Merge


	'// Check
	del  merged_path +"\dummy.txt"
	Assert  IsSameFolder( merged_path, "Files\Merge\OutAnswer", Empty )
	Assert  out_path = GetFullPath( "Files\Merge\03_Merged", Empty )


	'// Clean
	del  merged_path
	del  "_out.txt"


	Pass
End Sub


 
'***********************************************************************
'* Function: new_ThreeWayMergeClass
'***********************************************************************
Function  new_ThreeWayMergeClass( in_SettingFilePath )
    Set merge = LoadThreeWayMergeOptionClass( in_SettingFilePath )
    Set merge.MergeTemplate = new_ReplaceTemplateClass( in_SettingFilePath )
    Set sync = new SyncFilesX_Class
    sync.IsNoCUI = True

	sync.LoadScanListUpAll  in_SettingFilePath,  ReadFile( in_SettingFilePath )

	Set Me_ = new ThreeWayMergeClass
	Set Me_.Sync = sync
	Set Me_.MergeOption = merge
	Set new_ThreeWayMergeClass = Me_
End Function


 
'*************************************************************************
'* Class: ThreeWayMergeClass
'*************************************************************************
Class  ThreeWayMergeClass
	Public  Sync
	Public  MergeOption

Sub  Merge()
	Me.Sync.Merge  Me.MergeOption
	Me.Sync.OpenCUI
End Sub


'* Section: End_of_Class
End Class


 
'***********************************************************************
'* Function: T_ThreeWayMerge_sth
'***********************************************************************
Sub  T_ThreeWayMerge_sth( Opt, AppKey )
	Set section = new SectionTree
'//SetStartSectionTree  "T_ThreeWayMerge_sth_SettingFile"
	vbs_path = SearchParent( "vbslib Prompt.vbs" )


	'//===========================================================
	If section.Start( "T_ThreeWayMerge_sth_Setting" ) Then

	'// Set up
	Set w_= AppKey.NewWritable( "_Merged.txt" ).Enable()
	del  "_Merged.txt"

	'// Test Main
	RunProg  "cscript //nologo """+ vbs_path +""" ThreeWayMerge  "+ _
		"Files\Conflict\Base.txt  Files\Conflict\Left.txt  "+ _
		"Files\Conflict\Right.txt  _Merged.txt  "+ _
		"Files\MergeSetting.xml", ""

	'// Check
	AssertFC  "_Merged.txt", "Files\Conflict\MergedAnswerEx.txt"

	'// Set up
	del  "_Merged.txt"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ThreeWayMerge_sth_SettingFile" ) Then

	'// Set up
	merged_path = "Files\Merge\03_Merged"
	Set w_= AppKey.NewWritable( Array( merged_path, "_out.txt" ) ).Enable()
	del  merged_path
	CreateFile  merged_path +"\dummy.txt", "x"  '// Not specified in setting file

	'// Test Main
	RunProg  "cscript //nologo """+ vbs_path +""" ThreeWayMerge  "+ _
		"\'/Setting:Files\Merge\MergeSetting.xml\'  "+ _
		"99",  "_out.txt"

	'// Check
	del  merged_path +"\dummy.txt"
	Assert  IsSameFolder( merged_path, "Files\Merge\OutAnswer", Empty )
	AssertFC  "_out.txt", "Files\Merge\OutLogAnswer.txt"

	'// Clean
	del  merged_path
	del  "_out.txt"

	End If : section.End_

	Pass
End Sub


 
'***********************************************************************
'* Function: T_Diff
'***********************************************************************
Sub  T_Diff( Opt, AppKey )
	Set section = new SectionTree
'//SetStartSectionTree  "T_ParseTaggedDiff_T2"

	'//===========================================================
	If section.Start( "T_ParseUnifiedDiff" ) Then

	'// Test Main
	Set parsed = ParseUnifiedDiff( ReadFile( "Files\UnifiedDiff.txt" ), Empty )

	'// Check : PlusStart, PlusOver, MinusStart, MinusOver, PlusLine, MinusLine
	answers = Array( _
		Array( 3, 4,  3, 3, "LLL/", "" ), _
		Array( 6, 7,  5, 5, "Both/", "" ), _
		Array( 8, 9,  6, 6, "LLL/", "" ), _
		Array( 10, 12,  7, 7, "Both/LLL/", "" ), _
		Array( 13, 15,  8, 8, "Unique B/Unique C/", "" ), _
		Array( 18, 19,  11, 12, "LLL/", "2/" ), _
		Array( 22, 23,  15, 16, "Both/", "6/" ), _
		Array( 24, 26,  17, 19, "Both/LLL", "8/9/" ), _
		Array( 27, 28,  20, 21, "Single B/", "Single A/" ), _
		Array( 31, 31,  24, 25, "", "LLL/" ), _
		Array( 34, 34,  28, 29, "", "Both/" ), _
		Array( 35, 35,  30, 32, "", "Both/LLL/" ), _
		Array( 36, 36,  33, 34, "", "Both/" ), _
		Array( 40, 41,  38, 38, "左に追加/", "" ), _
		Array( 43, 44,  40, 40, "両方追加/", "" ), _
		Array( 45, 46,  41, 42, "両方変更（左）/", "５/" ), _
		Array( 47, 47,  43, 44, "", "７/" ) )

	For i=0 To UBound( answers )
		Assert  parsed.Differences(i).PlusStart  = answers(i)(0)
		Assert  parsed.Differences(i).PlusOver   = answers(i)(1)
		Assert  parsed.Differences(i).MinusStart = answers(i)(2)
		Assert  parsed.Differences(i).MinusOver  = answers(i)(3)
	Next
	Assert  UBound( parsed.Differences ) = UBound( answers )

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ParseTaggedDiff" ) Then

	'// Set up
	Set w_=AppKey.NewWritable( "_out" ).Enable()
	del  "_out"

	Set parsed = ParseUnifiedDiff( ReadFile( "Files\UnifiedDiff.txt" ), Empty )

	'// Test Main
	parsed.MakeTaggedDiffText _
		GetFullPath( parsed.MinusStepPath, GetFullPath( "Files", Empty ) ), _
		GetFullPath( parsed.PlusStepPath,  GetFullPath( "Files", Empty ) ), _
		"_out\diff.txt"

	'// Check
	AssertFC  "_out\diff.txt", "Files\Conflict\DiffOfBaseLeft.txt"

	'// Test Main
	text = parsed.MakeTaggedDiffText( _
		GetFullPath( parsed.MinusStepPath, GetFullPath( "Files", Empty ) ), _
		GetFullPath( parsed.PlusStepPath,  GetFullPath( "Files", Empty ) ), _
		Empty )

	'// Check
	Assert  text = ReadFile( "Files\Conflict\DiffOfBaseLeft.txt" )

	'// Clean
	del  "_out"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ParseTaggedDiff_T2" ) Then

	'// Set up
	Set w_=AppKey.NewWritable( "_out" ).Enable()
	del  "_out"

	Set parsed = ParseUnifiedDiff( ReadFile( "Files\UnifiedDiff_T2.txt" ), Empty )

	'// Test Main
	parsed.MakeTaggedDiffText _
		GetFullPath( parsed.MinusStepPath, GetFullPath( "Files", Empty ) ), _
		GetFullPath( parsed.PlusStepPath,  GetFullPath( "Files", Empty ) ), _
		"_out\diff.txt"

	'// Check
	AssertFC  "_out\diff.txt", "Files\Conflict\T2_DiffOfBaseLeft.txt"

	'// Clean
	del  "_out"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ParseTaggedDiff2" ) Then

	Set w_=AppKey.NewWritable( "_out" ).Enable()
	del  "_out"
	Set ds = new CurDirStack

	'// Test Main
	cd  "Files"
	diff  "Conflict\Base.txt",  "Conflict\Left.txt",  "..\_out\diff.txt",  Empty
	cd  ".."

	'// Check
	AssertFC  "_out\diff.txt", "Files\Conflict\DiffOfBaseLeft.txt"

	'// Test Main
	cd  "Files"
	text = diff( "Conflict\Base.txt",  "Conflict\Left.txt",  Empty,  Empty )
	cd  ".."

	'// Check
	Assert  text = ReadFile( "Files\Conflict\DiffOfBaseLeft.txt" )

	'// Clean
	del  "_out"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_ParseTaggedDiff_sth" ) Then

	Set w_=AppKey.NewWritable( "_out" ).Enable()
	del  "_out"
	Set ds = new CurDirStack
	vbs_path = SearchParent( "vbslib Prompt.vbs" )

	'// Test Main
	cd  "Files"
	RunProg  "cscript  """+ vbs_path +"""  TwoWayMerge  ""Conflict\Base.txt""  ""Conflict\Left.txt""  ""..\_out\diff.txt""  """"", ""
	cd  ".."

	'// Check
	AssertFC  "_out\diff.txt", "Files\Conflict\DiffOfBaseLeft.txt"


	'// Case: Same file
	'// Test Main
	cd  "Files"
	RunProg  "cscript  """+ vbs_path +"""  TwoWayMerge  ""Conflict\Base.txt""  ""Conflict\Base.txt""  ""..\_out\diff.txt""  """"", ""
	cd  ".."

	'// Check
	AssertFC  "_out\diff.txt", "Files\Conflict\Base.txt"

	End If : section.End_

	Pass
End Sub


 
'***********************************************************************
'* Function: T_Patch
'***********************************************************************
Sub  T_Patch( Opt, AppKey )
	Set tc = get_ToolsLibConsts()

	'// Set up
	Set w_=AppKey.NewWritable( "_out" ).Enable()
	del  "_out"

	cd  "Files"
	diff  "Conflict\Base.txt",  "Conflict\Left.txt",  "..\_out\diff.txt",  tc.DiffForPatch
	cd  ".."

	'// Test Main
	cd  "Files"
	patch  "Conflict\Base.txt",  "..\_out\diff.txt",  "..\_out\new_out.txt",  Empty
	cd  ".."

	'// Check
	Assert  IsSameBinaryFile( "_out\new_out.txt", "Files\Conflict\Left.txt", Empty )

	'// Clean
	del  "_out"

	Pass
End Sub


 
'***********************************************************************
'* Function: T_PatchAndBackUp_Conflict
'***********************************************************************
Sub  T_PatchAndBackUp_Conflict( Opt, AppKey )
	Set w_= AppKey.NewWritable( "_work" ).Enable()
	Set section = new SectionTree
'//SetStartSectionTree  "T_Attach_Conflict"


	'//===========================================================
	If section.Start( "T_PatchAndBackUp_Conflict_Attach" ) Then

	'// Set up
	del  "_work"
	copy  "Files\PatchConflicted\01-left\*", "_work"
	SetFilesToNotReadOnly  g_fs.GetFolder( "_work" )
	g_FileHashCache.RemoveAll

	'// Test Main
	Set patch_ = EnumerateToPatchAndBackUpDictionary( "Files\PatchConflicted\02-Patch-of-01" )
	Set merge = new ThreeWayMergeOptionClass
	merge.IsOutEach = False
	merge.IsEnableToRaiseConflictError = False
	merge.SingletonKeywords = Array( "Single" )
	merge.UniqueLineKeywords = Array( "Unique" )

	target = Empty
	AttachPatchAndBackUpDictionary  target, patch_, "_work", merge
	CopyFilesToLeafPathDictionary  target, False

	'// Check
	Assert  fc( "_work", "Files\PatchConflicted\02-merged" )

	'// Clean
	del  "_work"

	End If : section.End_

	Pass
End Sub


 
'***********************************************************************
'* Function: T_DiffWithoutKS
'***********************************************************************
Sub  T_DiffWithoutKS( Opt, AppKey )
    include  SearchParent( "_src\Test\tools\T_SyncFiles\SettingForTest_pre.vbs" )
    include  SearchParent( "_src\Test\tools\T_SyncFiles\SettingForTest.vbs" )
    SetVar  "Setting_getFolderDiffCmdLine", "ArgsLog"  '// ログへの記録に変更する

    work_path = g_sh.SpecialFolders( "Desktop" ) +"\_DiffWithoutKS"
	prompt_vbs = SearchParent( "vbslib Prompt.vbs" )
	log_at_prompt_vbs = GetFullPath( "..\ArgsLog.txt",  prompt_vbs )
	Set w_= AppKey.NewWritable( Array( work_path,  "ArgsLog.txt",  log_at_prompt_vbs ) ).Enable()
	Set section = new SectionTree
'//SetStartSectionTree  "T_DiffWithoutKS_AB_sth"


	'//===========================================================
	If section.Start( "T_DiffWithoutKS_AB" ) Then

	'// Set up
	del  work_path
	del  "ArgsLog.txt"

	'// Test Main
	DiffWithoutKS  "Files\KS\A", "Files\KS\B", Empty, Empty

	'// Check
	AssertFC  work_path +"\A\Same.txt",  "Files\KS\Cut\Same.txt"
	AssertFC  work_path +"\B\Same.txt",  "Files\KS\Cut\Same.txt"
	AssertFC  "ArgsLog.txt",  "Files\KS\ArgsLog2.txt"

	'// Clean
	del  work_path
	del  "ArgsLog.txt"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_DiffWithoutKS_ABc" ) Then

	'// Set up
	del  work_path
	del  "ArgsLog.txt"
	Set option_ = new DiffCmdLineOptionClass
	option_.IsComparing(2) = False

	'// Test Main
	DiffWithoutKS  "Files\KS\A", "Files\KS\B", "Files\KS\C", option_

	'// Check
	AssertFC  work_path +"\A\Same.txt",  "Files\KS\Cut\Same.txt"
	AssertFC  work_path +"\B\Same.txt",  "Files\KS\Cut\Same.txt"
	AssertFC  work_path +"\C\Same.txt",  "Files\KS\C\Same.txt"
	AssertFC  "ArgsLog.txt",  "Files\KS\ArgsLog3.txt"

	'// Clean
	del  work_path
	del  "ArgsLog.txt"

	End If : section.End_


	'//===========================================================
	If section.Start( "T_DiffWithoutKS_AB_sth" ) Then

	'// Set up
	del  work_path

	'// Test Main
	RunProg  "cscript  """+ prompt_vbs +"""  /ArgsLog  DiffWithoutKS_sth  ""Files\KS\A""  ""Files\KS\B""  """"",  ""

	'// Check
	AssertFC  work_path +"\A\Same.txt",  "Files\KS\Cut\Same.txt"
	AssertFC  work_path +"\B\Same.txt",  "Files\KS\Cut\Same.txt"

	'// Clean
	del  work_path
	del  log_at_prompt_vbs

	End If : section.End_


	'//===========================================================
	If section.Start( "T_DiffWithoutKS_ABC_sth" ) Then

	'// Set up
	del  work_path

	'// Test Main
	RunProg  "cscript  """+ prompt_vbs +"""  /ArgsLog  DiffWithoutKS  ""Files\KS\A""  ""Files\KS\B""  ""Files\KS\C""",  ""

	'// Check
	AssertFC  work_path +"\A\Same.txt",  "Files\KS\Cut\Same.txt"
	AssertFC  work_path +"\B\Same.txt",  "Files\KS\Cut\Same.txt"
	AssertFC  work_path +"\C\Same.txt",  "Files\KS\Cut\Same.txt"

	'// Clean
	del  work_path
	del  log_at_prompt_vbs

	End If : section.End_

	Pass
End Sub


 
'***********************************************************************
'* Function: T_FourWayMerge
'***********************************************************************
Sub  T_FourWayMerge( Opt, AppKey )
	Set w_= AppKey.NewWritable( Array( "_LeftOut.txt", "_RightOut.txt" ) ).Enable()

	FourWayMerge  "Files\4way\LeftBase.txt", "Files\4way\Left.txt", "_LeftOut.txt", _
		"Files\4way\RightBase.txt", "Files\4way\Right.txt", "_RightOut.txt", Empty
'// start  GetEditorCmdLine( "_LeftOut.txt" )
Setting_openFolder  g_debug_var(3)

	Skipped
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


 
