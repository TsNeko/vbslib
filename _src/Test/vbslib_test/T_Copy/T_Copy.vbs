Sub  Main( Opt, AppKey )
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_Exist",_
			"2","T_FC",_
			"3","T_Copy",_
			"4","T_Move",_
			"5","T_Del",_
			"6","T_CopyLocked",_
			"7","T_Move2",_
			"8","T_del_empty_folder",_
			"9","T_del_byPathDictionary" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_Exist] >>> 
'********************************************************************************
Sub  T_Exist( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( "work" ).Enable()

	If exist( "work\data\text1.txt" ) Then  Fail
	CreateFile  "work\data\text1.txt", "text1"
	If not exist( "work\data\text1.txt" ) Then  Fail
	If not exist( "work\data\*.txt" ) Then  Fail
	If not exist( "work\data\*" ) Then  Fail
	If exist( "work\data\*.jpg" ) Then  Fail
	del "work\data"
	If exist( "work\data" ) Then  Fail

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_FC] >>> 
'********************************************************************************
Sub  T_FC( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( "work" ).Enable()

	EchoTestStart  "T_FC_File"

	'// set up
	CreateFile  "work\data\text1.txt", "text1"
	CreateFile  "work\data\text2.txt", "text2"
	CreateFile  "work\data\text1B.txt", "text1"

	'// Test Main
	If fc( "work\data\text1.txt", "work\data\text0.txt" ) Then  Fail
	If fc( "work\data\text1.txt", "work\data\text2.txt" ) Then  Fail
	If not fc( "work\data\text1.txt", "work\data\text1B.txt" ) Then  Fail

	'// clean
	del "work\data"


	EchoTestStart  "T_FC_Folder"

	'// set up
	CreateFile  "work\data\text1.txt", "text1"
	CreateFile  "work\data\k\text2.txt", "text2"
	CreateFile  "work\data\k\text1B.txt", "text1"
	CreateFile  "work\data2\text1.txt", "text1"
	CreateFile  "work\data2\k\text2.txt", "text2"
	CreateFile  "work\data2\k\text1B.txt", "text1"

	'// Test Main
	If not fc( "work\data", "work\data2" ) Then  Fail
	CreateFile  "work\data2\k\text1B.txt", "text2"
	If fc( "work\data", "work\data2" ) Then  Fail

	'// clean
	del "work\data"
	del "work\data2"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_Copy] >>> 
'********************************************************************************
Sub  T_Copy( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( "work" ).Enable()
	Dim  e, e2
	Dim  src_fo : src_fo = "work\from\data"
	Dim  copy_or_move : Set copy_or_move = GetRef( "copy" )  '// for diff tool to compare to T_Move
	Dim  copy_ren_or_move_ren : Set copy_ren_or_move_ren = GetRef( "copy_ren" )
	Const  is_move = False
	Dim section : Set section = new SectionTree
'//SetStartSectionTree  "38"

	Dim  prev_old_spec : prev_old_spec = g_bNotCheckOldSpec : g_bNotCheckOldSpec = True

	del  "work"
	If exist("work") Then Fail
	mkdir  "work"
	If not exist("work") Then Fail


	'// List up:

	'// 11) copy_or_move  file, folder
	'// 12) (old spec.) copy_or_move  file, file
	'// 13) (new spec.) copy_or_move  file, folder
	'// 14) copy_or_move  file, folder (overwrite file)

	'// 21) copy_ren_or_move_ren  file, file
	'// 22) copy_ren_or_move_ren  file, file (overwrite)
	'// 23) copy_ren_or_move_ren  file, file (with making new folder)
	'// 24) copy_ren_or_move_ren  file, file (overwrite in current dir)
	'// 25) copy_ren_or_move_ren  file, folder (Error)

	'// 31) copy_or_move  folder, folder
	'// 32) copy_or_move  folder, folder (in same name folder)
	'// 33) copy_or_move  folder, folder (with making new folder)
	'// 34) copy_or_move  folder+"\*", making new folder
	'// 35) copy_or_move  folder+"\"+folder+"\*" (file), making new folder 
	'// 36) copy_or_move  folder+"\"+folder+"\*" (folder\file), folder 
	'// 37) copy_or_move  folder, folder (overwrite files)
	'// 38) copy_or_move  folder, folder (read only file)

	'// 41) copy_ren_or_move_ren  folder, folder
	'// 42) copy_ren_or_move_ren  folder, folder (merge)

	'// 51) copy_or_move  not_found_folder, folder
	'// 52) copy_or_move  not_found_file, folder



	'// 11) copy_or_move  file, folder
	If section.Start( "11" ) Then
	del  "work\from\*" : copy "data\*", src_fo

		copy_or_move  src_fo+"\src1.txt", "work"

	Assert  fc( "data\src1.txt", "work\src1.txt" )
	del "work\src1.txt"
	If is_move Then  Assert  not exist( src_fo+"\src1.txt" )
	End If : section.End_



	'// 12) (old spec.) copy_or_move  file, file
	If section.Start( "12" ) Then
	del  "work\from\*" : copy "data\*", src_fo
	Dim  v_:Set v_= new VarStack
	g_Vers("CopyTargetIsFileOrFolder") = 1
	del "work\sub"

		copy_or_move  src_fo+"\src1.txt", "work\src1.txt"

	Assert  fc( "data\src1.txt", "work\src1.txt" )
	del "work\sub"
	v_ = Empty
	If is_move Then  Assert  not exist( src_fo+"\src1.txt" )
	End If : section.End_



	'// 13) (new spec.) copy_or_move  file, folder
	If section.Start( "13" ) Then
	del  "work\from\*" : copy "data\*", src_fo
	del  "work\sub"

		copy_or_move  src_fo+"\src1.txt", "work\sub"

	Assert  fc( "data\src1.txt", "work\sub\src1.txt" )
	del  "work\sub"
	If is_move Then  Assert  not exist( src_fo+"\src1.txt" )
	End If : section.End_



	'// 13) copy_or_move  file, folder (overwrite file)
	If section.Start( "13" ) Then
	del  "work\from\*" : copy "data\*", src_fo
	del  "work\sub"
	copy_ren  src_fo+"\src1.txt", "work\sub\src2.txt"

		copy_or_move  src_fo+"\src2.txt", "work\sub"

	Assert  fc( "data\src2.txt", "work\sub\src2.txt" )
	del  "work\sub"
	If is_move Then  Assert  not exist( src_fo+"\src2.txt" )
	End If : section.End_



	'// 21) copy_ren_or_move_ren  file, file
	If section.Start( "21" ) Then
	del  "work\from\*" : copy "data\*", src_fo

		copy_ren_or_move_ren  src_fo+"\src1.txt", "work\src2.txt"

	Assert  fc( "data\src1.txt", "work\src2.txt" )
	del "work\src2.txt"
	If is_move Then  Assert  not exist( src_fo+"\src1.txt" )
	End If : section.End_



	'// 22) copy_ren_or_move_ren  file, file (overwrite)
	If section.Start( "22" ) Then
	del  "work\from\*" : copy "data\*", src_fo
	del  "work\sub"
	copy_ren  src_fo+"\src1.txt", "work\sub\src1.txt"

		copy_ren_or_move_ren  src_fo+"\src2.txt", "work\sub\src1.txt"

	Assert  fc( "data\src2.txt", "work\sub\src1.txt" )
	del  "work\sub"
	If is_move Then  Assert  not exist( src_fo+"\src2.txt" )
	End If : section.End_



	'// 23) copy_ren_or_move_ren  file, file (with making new folder)
	If section.Start( "23" ) Then
	del  "work\from\*" : copy "data\*", src_fo

		copy_ren_or_move_ren  src_fo+"\src1.txt", "work\k\src2.txt"

	Assert  fc( "data\src1.txt", "work\k\src2.txt" )
	del "work\k"
	If is_move Then  Assert  not exist( src_fo+"\src1.txt" )
	End If : section.End_



	'// 24) copy_ren_or_move_ren  file, file (overwrite in current dir)
	If section.Start( "24" ) Then
	copy_ren  "data\src1.txt", "work\src1_src.txt"
	Dim  ds_:Set ds_= new CurDirStack
	cd "work"

		copy_ren_or_move_ren  "src1_src.txt", "src1.txt"

	ds_ = Empty
	Assert  fc( "data\src1.txt", "work\src1.txt" )
	If is_move Then  Assert  not exist( "work\src1_src.txt" )
	End If : section.End_



	'// 25) copy_ren_or_move_ren  file, folder (Error)
	If section.Start( "25" ) Then
	del  "work\from\*" : copy "data\*", src_fo
	mkdir  "work\k"
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		copy_ren_or_move_ren  src_fo+"\src1.txt", "work\k"

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num <> 0
	End If : section.End_



	del "work\*"



	'// 31) copy_or_move  folder, folder
	If section.Start( "31" ) Then
	del  "work\from\*" : copy "data\*", src_fo

		copy_or_move  src_fo, "work"

	Assert  fc( "data", "work\data" )
	del "work\data"
	If is_move Then  Assert  not exist( src_fo )
	End If : section.End_



	'// 32) copy_or_move  folder, folder (in same name folder)
	If section.Start( "32" ) Then
	del  "work\from\*" : copy "data\*", src_fo

		copy_or_move  src_fo, "work\data"

	Assert  fc( "data", "work\data\data" )
	del "work\data"
	If is_move Then  Assert  not exist( src_fo )
	End If : section.End_



	'// 33) copy_or_move  folder, folder (with making new folder)
	If section.Start( "33" ) Then
	del  "work\from\*" : copy "data\*", src_fo

		copy_or_move  src_fo, "work\kk"

	Assert  fc( "data", "work\kk\data" )
	del "work\kk"
	If is_move Then  Assert  not exist( src_fo )
	End If : section.End_



	'// 34) copy_or_move  folder+"\*", making new folder
	If section.Start( "34" ) Then
	del  "work\from\*" : copy "data\*", src_fo
	del  "work\bb"

		copy_or_move  src_fo+"\*", "work\bb"

	Assert  fc( "data", "work\bb" )
	If is_move Then  Assert  not exist( src_fo+"\*" )
	End If : section.End_



	'// 35) copy_or_move  folder+"\"+folder+"\*" (file), making new folder 
	If section.Start( "35" ) Then
	del  "work\from\*" : copy "data\*", src_fo
	del    "work\bb"
	mkdir  "work\bb"

		copy_or_move  src_fo+"\src3\*", "work\bb"

	Assert  fc( "data\src3", "work\bb" )
	del  "work\bb"
	If is_move Then  Assert  not exist( src_fo+"\src3\*" )
	End If : section.End_



	'// 36) copy_or_move  folder+"\"+folder+"\*" (folder\file), folder 
	If section.Start( "36" ) Then
	del  "work\from\*" : copy "data\*", src_fo
	del    "work\bb"
	mkdir  "work\bb"

		copy_or_move  src_fo+"\src4\*", "work\bb" 'exist bb

	Assert  fc( "data\src4", "work\bb" )
	del  "work\bb"
	If is_move Then  Assert  notexist( src_fo+"\src4\*" )
	End If : section.End_



	'// 37) copy_or_move  folder, folder (overwrite files)
	If section.Start( "37" ) Then
	del  "work\from\*" : copy "data\*", src_fo
	del  "work\bb" : copy  src_fo+"\*", "work\bb"
	CreateFile  "work\bb\add.txt", "add"  '// this file will stay
	CreateFile  "work\bb\src1.txt", "---"  '// this file will overwrite
	CreateFile  "work\bb\src2\src2.txt", "---"  '// this file will overwrite

		copy_or_move  src_fo+"\*", "work\bb"

	Assert  exist( "work\bb\add.txt" )
	del  "work\bb\add.txt"
	Assert  fc( "data", "work\bb" )
	del  "work\bb"
	If is_move Then  Assert  not exist( src_fo+"\*" )
	End If : section.End_


	'// 38) copy_or_move  folder, folder (read only file)
	If section.Start( "38" ) Then
	'// Set up
	del  "work"
	copy_or_move  "Files\T_CopyDenied\Destination", "work"
	'// Test Main
	If TryStart(e) Then  On Error Resume Next

		copy_or_move  "Files\T_CopyDenied\Source", "work\Destination"

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '// Set "e2"
	echo    e2.desc
	If e2.num <> E_WriteAccessDenied  Then  Fail
	If InStr( e2.desc, "リードオンリー" ) = 0 Then  Fail
	If InStr( e2.desc, "work\Destination" ) = 0 Then  Fail
	'// Clean
	del  "work"
	End If : section.End_


	'// 41) copy_ren_or_move_ren  folder, folder
	If section.Start( "41" ) Then
	del  "work\from\*" : copy "data\*", src_fo

		copy_ren_or_move_ren  src_fo, "work\data_ren"

	Assert  fc( "data", "work\data_ren" )
	del "work\data_ren"
	If is_move Then  Assert  not exist( src_fo )
	End If : section.End_



	'// 42) copy_ren_or_move_ren  folder, folder (merge)
	If section.Start( "42" ) Then
	del  "work\from\*" : copy "data\*", src_fo
	del  "work\bb" : copy  src_fo+"\*", "work\bb"
	CreateFile  "work\bb\add.txt", "add"  '// this file will be remained
	CreateFile  "work\bb\src1.txt", "---"  '// this file will overwrite
	CreateFile  "work\bb\src2\src2.txt", "---"  '// this file will overwrite

		copy_ren_or_move_ren  src_fo, "work\bb"

	Assert  ReadFile( "work\bb\add.txt" ) = "add"  '// merged file
	del  "work\bb\add.txt"
	Assert  fc( "data", "work\bb" )
	del  "work\bb"
	If is_move Then  Assert  not exist( src_fo )
	End If : section.End_



	'// 51) copy_or_move  not_found_folder, folder
	If section.Start( "51" ) Then
	del  "work\from\*" : copy "data\*", src_fo
	del    "work\bb"
	mkdir  "work\bb"
	If TryStart(e) Then  On Error Resume Next

		copy_or_move  src_fo+"\srcNotFound\*", "work\bb"

	If TryEnd Then  On Error GoTo 0
	If e.num <> E_PathNotFound  Then  Fail
	If InStr( e.desc, "見つかりません" ) = 0 Then  Fail
	If InStr( e.desc, "path="""+ src_fo+"\srcNotFound\*""" ) = 0 Then  Fail
	e.Clear
	End If : section.End_



	'// 52) copy_or_move  not_found_file, folder
	If section.Start( "52" ) Then
	del    "work\bb"
	mkdir  "work\bb"
	If TryStart(e) Then  On Error Resume Next

		copy_or_move  src_fo+"\srcNotFound.txt", "work\bb"

	If TryEnd Then  On Error GoTo 0
	If e.num <> E_PathNotFound  Then  Fail
	If InStr( e.desc, "見つかりません" ) = 0 Then  Fail
	If InStr( e.desc, "path="""+ src_fo+"\srcNotFound.txt""" ) = 0 Then  Fail
	e.Clear
	End If : section.End_


	del  "work"

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_Move] >>> 
'********************************************************************************
Sub  T_Move( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( Array( "work", "work_" ) ).Enable()
	Dim  e, e2
	Dim  src_fo : src_fo = "work\from\data"
	Dim  copy_or_move : Set copy_or_move = GetRef( "move" )  '// for diff tool to compare to T_Copy
	Dim  copy_ren_or_move_ren : Set copy_ren_or_move_ren = GetRef( "move_ren" )
	Const  is_move = True
	Dim section : Set section = new SectionTree
'//SetStartSectionTree  "38"


	Dim  prev_old_spec : prev_old_spec = g_bNotCheckOldSpec : g_bNotCheckOldSpec = True

	del  "work"
	If exist("work") Then Fail
	mkdir  "work\from"
	If not exist("work\from") Then Fail


	'// List up:

	'// 11) copy_or_move  file, folder
	'// 12) (old spec.) copy_or_move  file, file
	'// 13) (new spec.) copy_or_move  file, folder
	'// 14) copy_or_move  file, folder (overwrite file)

	'// 21) copy_ren_or_move_ren  file, file
	'// 22) copy_ren_or_move_ren  file, file (overwrite)
	'// 23) copy_ren_or_move_ren  file, file (with making new folder)
	'// 24) copy_ren_or_move_ren  file, file (overwrite in current dir)
	'// 25) copy_ren_or_move_ren  file, folder (Error)

	'// 31) copy_or_move  folder, folder
	'// 32) copy_or_move  folder, folder (in same name folder)
	'// 33) copy_or_move  folder, folder (with making new folder)
	'// 34) copy_or_move  folder+"\*", making new folder
	'// 35) copy_or_move  folder+"\"+folder+"\*" (file), making new folder 
	'// 36) copy_or_move  folder+"\"+folder+"\*" (folder\file), folder 
	'// 37) copy_or_move  folder, folder (overwrite files)
	'// 38-B) move  folder+"\"+folder+"\*", parent same name folder

	'// 41) copy_ren_or_move_ren  folder, folder
	'// 42) copy_ren_or_move_ren  folder, folder (merge)

	'// 51) copy_or_move  not_found_folder, folder
	'// 52) copy_or_move  not_found_file, folder



	'// 11) copy_or_move  file, folder
	If section.Start( "11" ) Then
	del  "work\from\*" : copy "data\*", src_fo

		copy_or_move  src_fo+"\src1.txt", "work"

	Assert  fc( "data\src1.txt", "work\src1.txt" )
	del "work\src1.txt"
	If is_move Then  Assert  not exist( src_fo+"\src1.txt" )
	End If : section.End_



	'// 12) (old spec.) copy_or_move  file, file
	If section.Start( "12" ) Then
	del  "work\from\*" : copy "data\*", src_fo
	Dim  v_:Set v_= new VarStack
	g_Vers("CopyTargetIsFileOrFolder") = 1
	del "work\sub"

		copy_or_move  src_fo+"\src1.txt", "work\src1.txt"

	Assert  fc( "data\src1.txt", "work\src1.txt" )
	del "work\sub"
	v_ = Empty
	If is_move Then  Assert  not exist( src_fo+"\src1.txt" )
	End If : section.End_



	'// 13) (new spec.) copy_or_move  file, folder
	If section.Start( "13" ) Then
	del  "work\from\*" : copy "data\*", src_fo
	del  "work\sub"

		copy_or_move  src_fo+"\src1.txt", "work\sub"

	Assert  fc( "data\src1.txt", "work\sub\src1.txt" )
	del  "work\sub"
	If is_move Then  Assert  not exist( src_fo+"\src1.txt" )
	End If : section.End_



	'// 13) copy_or_move  file, folder (overwrite file)
	If section.Start( "13" ) Then
	del  "work\from\*" : copy "data\*", src_fo
	del  "work\sub"
	copy_ren  src_fo+"\src1.txt", "work\sub\src2.txt"

		copy_or_move  src_fo+"\src2.txt", "work\sub"

	Assert  fc( "data\src2.txt", "work\sub\src2.txt" )
	del  "work\sub"
	If is_move Then  Assert  not exist( src_fo+"\src2.txt" )
	End If : section.End_



	'// 21) copy_ren_or_move_ren  file, file
	If section.Start( "21" ) Then
	del  "work\from\*" : copy "data\*", src_fo

		copy_ren_or_move_ren  src_fo+"\src1.txt", "work\src2.txt"

	Assert  fc( "data\src1.txt", "work\src2.txt" )
	del "work\src2.txt"
	If is_move Then  Assert  not exist( src_fo+"\src1.txt" )
	End If : section.End_



	'// 22) copy_ren_or_move_ren  file, file (overwrite)
	If section.Start( "22" ) Then
	del  "work\from\*" : copy "data\*", src_fo
	del  "work\sub"
	copy_ren  src_fo+"\src1.txt", "work\sub\src1.txt"

		copy_ren_or_move_ren  src_fo+"\src2.txt", "work\sub\src1.txt"

	Assert  fc( "data\src2.txt", "work\sub\src1.txt" )
	del  "work\sub"
	If is_move Then  Assert  not exist( src_fo+"\src2.txt" )
	End If : section.End_



	'// 23) copy_ren_or_move_ren  file, file (with making new folder)
	If section.Start( "23" ) Then
	del  "work\from\*" : copy "data\*", src_fo

		copy_ren_or_move_ren  src_fo+"\src1.txt", "work\k\src2.txt"

	Assert  fc( "data\src1.txt", "work\k\src2.txt" )
	del "work\k"
	If is_move Then  Assert  not exist( src_fo+"\src1.txt" )
	End If : section.End_



	'// 24) copy_ren_or_move_ren  file, file (overwrite in current dir)
	If section.Start( "24" ) Then
	copy_ren  "data\src1.txt", "work\src1_src.txt"
	Dim  ds_:Set ds_= new CurDirStack
	cd "work"

		copy_ren_or_move_ren  "src1_src.txt", "src1.txt"

	ds_ = Empty
	Assert  fc( "data\src1.txt", "work\src1.txt" )
	If is_move Then  Assert  not exist( "work\src1_src.txt" )
	End If : section.End_



	'// 25) copy_ren_or_move_ren  file, folder (Error)
	If section.Start( "25" ) Then
	del  "work\from\*" : copy "data\*", src_fo
	mkdir  "work\k"
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		copy_ren_or_move_ren  src_fo+"\src1.txt", "work\k"

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	Assert  e2.num <> 0
	End If : section.End_



	del "work\*"



	'// 31) copy_or_move  folder, folder
	If section.Start( "31" ) Then
	del  "work\from\*" : copy "data\*", src_fo

		copy_or_move  src_fo, "work"

	Assert  fc( "data", "work\data" )
	del "work\data"
	If is_move Then  Assert  not exist( src_fo )
	End If : section.End_



	'// 32) copy_or_move  folder, folder (in same name folder)
	If section.Start( "32" ) Then
	del  "work\from\*" : copy "data\*", src_fo

		copy_or_move  src_fo, "work\data"

	Assert  fc( "data", "work\data\data" )
	del "work\data"
	If is_move Then  Assert  not exist( src_fo )
	End If : section.End_



	'// 33) copy_or_move  folder, folder (with making new folder)
	If section.Start( "33" ) Then
	del  "work\from\*" : copy "data\*", src_fo

		copy_or_move  src_fo, "work\kk"

	Assert  fc( "data", "work\kk\data" )
	del "work\kk"
	If is_move Then  Assert  not exist( src_fo )
	End If : section.End_



	'// 34) copy_or_move  folder+"\*", making new folder
	If section.Start( "34" ) Then
	del  "work\from\*" : copy "data\*", src_fo
	del  "work\bb"

		copy_or_move  src_fo+"\*", "work\bb"

	Assert  fc( "data", "work\bb" )
	If is_move Then  Assert  not exist( src_fo+"\*" )
	End If : section.End_



	'// 35) copy_or_move  folder+"\"+folder+"\*" (file), making new folder 
	If section.Start( "35" ) Then
	del  "work\from\*" : copy "data\*", src_fo
	del    "work\bb"
	mkdir  "work\bb"

		copy_or_move  src_fo+"\src3\*", "work\bb"

	Assert  fc( "data\src3", "work\bb" )
	del  "work\bb"
	If is_move Then  Assert  not exist( src_fo+"\src3\*" )
	End If : section.End_



	'// 36) copy_or_move  folder+"\"+folder+"\*" (folder\file), folder 
	If section.Start( "36" ) Then
	del  "work\from\*" : copy "data\*", src_fo
	del    "work\bb"
	mkdir  "work\bb"

		copy_or_move  src_fo+"\src4\*", "work\bb" 'exist bb

	Assert  fc( "data\src4", "work\bb" )
	del  "work\bb"
	If is_move Then  Assert  not exist( src_fo+"\src4\*" )
	End If : section.End_



	'// 37) copy_or_move  folder, folder (overwrite files)
	If section.Start( "37" ) Then
	del  "work\from\*" : copy "data\*", src_fo
	del  "work\bb" : copy  src_fo+"\*", "work\bb"
	CreateFile  "work\bb\add.txt", "add"  '// this file will stay
	CreateFile  "work\bb\src1.txt", "---"  '// this file will overwrite
	CreateFile  "work\bb\src2\src2.txt", "---"  '// this file will overwrite

		copy_or_move  src_fo+"\*", "work\bb"

	Assert  exist( "work\bb\add.txt" )
	del  "work\bb\add.txt"
	Assert  fc( "data", "work\bb" )
	del  "work\bb"
	If is_move Then  Assert  not exist( src_fo+"\*" )
	End If : section.End_



	'// 38-A) Not parent of Test 38
	If section.Start( "38-A" ) Then
	del  "work"
	del  "work_"
	mkdir  "work\sub"
	copy_ren  "data\src1.txt",  "work\sub\src1.txt"
	mkdir  "work\sub\sub"
	copy_ren  "data\src2.txt",  "work\sub\sub\src2.txt"
	mkdir  "work\sub\sub\sub"
	copy_ren  "data\src1.txt",  "work\sub\sub\sub\src2.txt"
	mkdir  "work\sub_"

		move  "work\sub\*", "work_"

	Assert  fc( "work_\src1.txt", "data\src1.txt" )
	Assert  fc( "work_\sub\src2.txt", "data\src2.txt" )
	Assert  fc( "work_\sub\sub\src2.txt", "data\src1.txt" )
	Assert  not exist( "work\sub\src1.txt" )
	Assert  not exist( "work\sub\sub\src2.txt" )
	Assert  not exist( "work\sub\sub\sub\src2.txt" )
	del  "work"
	del  "work_"
	End If : section.End_


	'// 38-B) Copy of Test 38
	If section.Start( "38-B" ) Then
	del  "work"
	mkdir  "work\sub"
	copy_ren  "data\src1.txt",  "work\sub\src1.txt"
	mkdir  "work\sub\sub"
	copy_ren  "data\src2.txt",  "work\sub\sub\src2.txt"
	mkdir  "work\sub\sub\sub"
	copy_ren  "data\src1.txt",  "work\sub\sub\sub\src2.txt"
	mkdir  "work\sub_"

		copy  "work\sub\*", "work"

	Assert  fc( "work\src1.txt", "data\src1.txt" )
	Assert  fc( "work\sub\src1.txt", "data\src1.txt" )
	Assert  fc( "work\sub\src2.txt", "data\src2.txt" )
	Assert  fc( "work\sub\sub\src2.txt", "data\src1.txt" )
	Assert  fc( "work\sub\sub\sub\src2.txt", "data\src1.txt" )
	del  "work"
	End If : section.End_


	'// 38) move  folder+"\"+folder+"\*", parent same name folder
	If section.Start( "38" ) Then
	del  "work"
	mkdir  "work\sub"
	copy_ren  "data\src1.txt",  "work\sub\src1.txt"  '// (1)
	mkdir  "work\sub\sub"
	copy_ren  "data\src2.txt",  "work\sub\sub\src2.txt"  '// (2)
	mkdir  "work\sub\sub\sub"
	copy_ren  "data\src1.txt",  "work\sub\sub\sub\src2.txt"  '// (3)
	mkdir  "work\sub_"

		move  "work\sub\*", "work"

	Assert  fc( "work\src1.txt", "data\src1.txt" )  '// (1)
	Assert  not exist( "work\sub\src1.txt" )  '// (1)
	Assert  fc( "work\sub\src2.txt", "data\src2.txt" )  '// (2)
	Assert  fc( "work\sub\sub\src2.txt", "data\src1.txt" )  '// (3)
	Assert  not exist( "work\sub\sub\sub\src2.txt" )  '// (3)
	del  "work"
	End If : section.End_


	'// 41) copy_ren_or_move_ren  folder, folder
	If section.Start( "41" ) Then
	del  "work\from\*" : copy "data\*", src_fo

		copy_ren_or_move_ren  src_fo, "work\data_ren"

	Assert  fc( "data", "work\data_ren" )
	del "work\data_ren"
	If is_move Then  Assert  not exist( src_fo )
	End If : section.End_



	'// 42) copy_ren_or_move_ren  folder, folder (merge)
	If section.Start( "42" ) Then
	del  "work\from\*" : copy "data\*", src_fo
	del  "work\bb" : copy  src_fo+"\*", "work\bb"
	CreateFile  "work\bb\add.txt", "add"  '// // this file will be remained
	CreateFile  "work\bb\src1.txt", "---"  '// this file will overwrite
	CreateFile  "work\bb\src2\src2.txt", "---"  '// this file will overwrite

		copy_ren_or_move_ren  src_fo, "work\bb"

	Assert  ReadFile( "work\bb\add.txt" ) = "add"  '// merged file
	del  "work\bb\add.txt"
	Assert  fc( "data", "work\bb" )
	del  "work\bb"
	If is_move Then  Assert  not exist( src_fo )
	End If : section.End_



	'// 51) copy_or_move  not_found_folder, folder
	If section.Start( "51" ) Then
	del  "work\from\*" : copy "data\*", src_fo
	del    "work\bb"
	mkdir  "work\bb"
	If TryStart(e) Then  On Error Resume Next

		copy_or_move  src_fo+"\srcNotFound\*", "work\bb"

	If TryEnd Then  On Error GoTo 0
	If e.num <> E_PathNotFound  Then  Fail
	If InStr( e.desc, "見つかりません" ) = 0 Then  Fail
	If InStr( e.desc, "path="""+ src_fo+"\srcNotFound\*""" ) = 0 Then  Fail
	e.Clear
	End If : section.End_



	'// 52) copy_or_move  not_found_file, folder
	If section.Start( "52" ) Then
	del    "work\bb"
	mkdir  "work\bb"
	If TryStart(e) Then  On Error Resume Next

		copy_or_move  src_fo+"\srcNotFound.txt", "work\bb"

	If TryEnd Then  On Error GoTo 0
	If e.num <> E_PathNotFound  Then  Fail
	If InStr( e.desc, "見つかりません" ) = 0 Then  Fail
	If InStr( e.desc, "path="""+ src_fo+"\srcNotFound.txt""" ) = 0 Then  Fail
	e.Clear
	End If : section.End_


	del  "work"
	Pass
End Sub


 
'********************************************************************************
'  <<< [T_Del] >>> 
'********************************************************************************
Sub  T_Del( Opt, AppKey )
	Set w_=AppKey.NewWritable( "work" ).Enable()
	Set ds = new CurDirStack


	'//===
	'// Set up
	del "work\data"
	If exist( "work\data" ) Then  Fail
	copy "data", "work"
	If not exist( "work\data" ) Then  Fail

	'// Test Main
	del "work\data"

	'// Check
	If exist( "work\data" ) Then  Fail


	'//===
	'// set up
	copy "data", "work"
	del "work\data\*"
	Set fo = g_fs.GetFolder( "work\data" )
	If fo.Files.Count <> 0 Then  Fail
	If fo.SubFolders.Count <> 0 Then  Fail

	'// Test Main
	del "work\data"


	'//===
	'// set up
	del  "work"
	copy "data\*", "work"

	'// Test Main
	pushd  "work"
	del  ""
	popd

	'// Check
	Assert  fc( "work", "data" )

	'// Clean
	del  "work"



	'//=== del_subfolder

	'// set up
	copy "data", "work"
	If not exist( "work\data" ) Then  Fail
	del "work\data\src1.txt"
	If exist( "work\data\src1.txt" ) Then  Fail
	If not exist( "work\data\src3\src1.txt" ) Then  Fail

	'// Test Main
	del_subfolder "work\data\c1.txt"  '// part of file name

	'// check
	If not exist( "work\data\src3\src1.txt" ) Then  Fail


	'// Test Main
	del_subfolder "work\data\src1.txt"  '// file in sub folder

	'// check
	If exist( "work\data\src1.txt" ) Then  Fail
	If exist( "work\data\src3\src1.txt" ) Then  Fail


	'//=== del_subfolder : folder in sub folder (1)

	'// set up
	copy "data", "work"
	If not exist( "work\data\src1.txt" ) Then  Fail
	del "work\data\sub"
	If not exist( "work\data\src2\sub" ) Then  Fail

	'// Test Main
	del_subfolder "work\data\sub"

	'// check
	If exist( "work\data\src2\sub" ) Then  Fail


	'//=== del_subfolder : folder in sub folder (2)

	'// set up
	copy "data", "work"
	If not exist( "work\data\src1.txt" ) Then  Fail
	del "work\data\sub"
	If not exist( "work\data\src2\sub" ) Then  Fail

	'// Test Main
	pushd  "work"
	del_subfolder "*\sub\*"
	popd

	'// check
	If exist( "work\data\src2\sub" ) Then  Fail


	'//=== del_subfolder : multi path

	'// set up
	copy "data", "work"
	If not exist( "work\data\src1.txt" ) Then  Fail
	del "work\data\sub"
	If not exist( "work\data\src2\sub" ) Then  Fail

	'// Test Main
	del_subfolder  Array( "work\data\src1.txt", "work\data\sub" )

	'// check
	If exist( "work\data\src1.txt" ) Then  Fail
	If exist( "work\data\src3\src1.txt" ) Then  Fail
	If exist( "work\data\src2\sub" ) Then  Fail


	'//=== del_subfolder : multi wildcard

	'// set up
	del  "work"
	copy "data\*", "work"

	'// Test Main
	del_subfolder  Array( "work\*1.txt", "work\*2.txt" )

	'// Check
	Set c = g_VBS_Lib
	ExpandWildcard  "work\*", c.File or c.SubFolder, folder, step_paths
	Assert  UBound( step_paths ) = 1

	'// Clean
	del "work"


	'======================================================
	TestOfDel2


	'======================================================
	' finish

	del "work"
	If exist("work") Then  Fail
	g_bNotCheckOldSpec = prev_old_spec
	Pass
End Sub

 
'********************************************************************************
'  <<< [TestOfDel2] called from T_Del >>> 
'********************************************************************************
Sub  TestOfDel2()
	TestOfDel2_Setup
	del "work\data_del\*.svg"

	ChkExistForDel  &h7707  '//  b111-b111  :  b000-b111
				'// sub1        : .
				'// *.svg-*.txt : *.svg-*.txt
				'// *1, *2a, *3a

	TestOfDel2_Setup
	del_subfolder "work\data_del\*.svg"
	ChkExistForDel  &h0707  '//  b000-b111  :  b000-b111


	TestOfDel2_Setup
	del "work\data_del\svg*.svg"
	ChkExistForDel  &h7707  '//  b111-b111  :  b000-b111


	TestOfDel2_Setup
	del_subfolder "work\data_del\svg*.svg"
	ChkExistForDel  &h0707  '//  b000-b111  :  b000-b111
End Sub


Sub  TestOfDel2_Setup()
	del "work\data_del"
	copy "data_del", "work"
End Sub

 
'********************************************************************************
'  <<< [ChkExistForDel] called from TestOfDel2 >>> 
'- ExistFlags is bit field. 1=Exist, 0=not
'   [0] = text1.txt,  [1] = text2a.txt,  [2] = text3a.txt
'   [4] = svg1.svg,   [5] = svg2a.svg,   [6] = svg3a.svg
'   [8] = sub1\text1.txt,  [9] = sub1\text2a.txt,  [10]= sub1\text3a.txt
'   [12] = sub1\svg1.svg,   [13] = sub1\svg2a.svg,   [14] = sub1\svg3a.svg
'********************************************************************************
Sub  ChkExistForDel( ExistFlags )
	Dim  ex

	ex = g_fs.FileExists( "work\data_del\text1.txt" )
	If ( ( ExistFlags and &h0001 ) <> 0 ) <> ex Then  Fail

	ex = g_fs.FileExists( "work\data_del\text2a.txt" )
	If ( ( ExistFlags and &h0002 ) <> 0 ) <> ex Then  Fail

	ex = g_fs.FileExists( "work\data_del\text3a.txt" )
	If ( ( ExistFlags and &h0004 ) <> 0 ) <> ex Then  Fail

	ex = g_fs.FileExists( "work\data_del\svg1.svg" )
	If ( ( ExistFlags and &h0010 ) <> 0 ) <> ex Then  Fail

	ex = g_fs.FileExists( "work\data_del\svg2a.svg" )
	If ( ( ExistFlags and &h0020 ) <> 0 ) <> ex Then  Fail

	ex = g_fs.FileExists( "work\data_del\svg3a.svg" )
	If ( ( ExistFlags and &h0040 ) <> 0 ) <> ex Then  Fail

	'//

	ex = g_fs.FileExists( "work\data_del\sub1\text1.txt" )
	If ( ( ExistFlags and &h0100 ) <> 0 ) <> ex Then  Fail

	ex = g_fs.FileExists( "work\data_del\sub1\text2a.txt" )
	If ( ( ExistFlags and &h0200 ) <> 0 ) <> ex Then  Fail

	ex = g_fs.FileExists( "work\data_del\sub1\text3a.txt" )
	If ( ( ExistFlags and &h0400 ) <> 0 ) <> ex Then  Fail

	ex = g_fs.FileExists( "work\data_del\sub1\svg1.svg" )
	If ( ( ExistFlags and &h1000 ) <> 0 ) <> ex Then  Fail

	ex = g_fs.FileExists( "work\data_del\sub1\svg2a.svg" )
	If ( ( ExistFlags and &h2000 ) <> 0 ) <> ex Then  Fail

	ex = g_fs.FileExists( "work\data_del\sub1\svg3a.svg" )
	If ( ( ExistFlags and &h4000 ) <> 0 ) <> ex Then  Fail
End Sub


 
'********************************************************************************
'  <<< [T_CopyLocked] >>> 
'********************************************************************************
Sub  T_CopyLocked( Opt, AppKey )
	Dim w_:Set w_=AppKey.NewWritable( "." ).Enable()
	Dim  f, retry_msec
	Dim en,ed


	'//=== normal copy
	T_CopyLocked_del
	CreateFile  "test_src.txt", "src"
	CreateFile  "test_dst.txt", "dst"
	copy_ren  "test_src.txt", "test_dst.txt"
	If ReadFile( "test_dst.txt" ) <> "src" Then  Fail


	'//=== dst locked copy type1
	retry_msec = g_FileSystemMaxRetryMSec
	g_FileSystemMaxRetryMSec = 8*1000
	T_CopyLocked_del
	CreateFile  "test_src.txt", "src"
	CreateFile  "test_dst.txt", "dst"
	Set f = OpenForWrite( "test_dst.txt", Empty )
	f.Write  "dst2"
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		copy_ren  "test_src.txt", "test_dst.txt"

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	If e2.num <> E_WriteAccessDenied Then  Fail
	f = Empty
	If ReadFile( "test_dst.txt" ) <> "dst2" Then  Fail
	g_FileSystemMaxRetryMSec = retry_msec


	'//=== dst locked copy type2
	T_CopyLocked_del
	CreateFile  "test_src.txt", "src"
	CreateFile  "test_out\test_src.txt", "dst"
	Set f = OpenForWrite( "test_out\test_src.txt", Empty )
	f.Write  "dst2"
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next
		copy  "test_s*.txt", "test_out"
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	If e2.num <> E_WriteAccessDenied Then  Fail
	f = Empty
	If ReadFile( "test_out\test_src.txt" ) <> "dst2" Then  Fail


	'//=== src locked copy type1
	T_CopyLocked_del
	CreateFile  "test_src.txt", "src"
	CreateFile  "test_dst.txt", "dst"
	Set f = OpenForWrite( "test_src.txt", Empty )
	f.Write  "src2"
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next
		copy_ren  "test_src.txt", "test_dst.txt"
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	f.Write  "src3"
	If e2.num <> 0 Then  Fail
	f = Empty
	If ReadFile( "test_src.txt" ) <> "src2src3" Then  Fail
	If ReadFile( "test_dst.txt" ) <> "src2" Then  Fail


	'//=== src locked copy type2
	T_CopyLocked_del
	CreateFile  "test_src.txt", "src"
	CreateFile  "test_out\test_src.txt", "dst"
	Set f = OpenForWrite( "test_src.txt", Empty )
	f.Write  "src2"
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next
		copy  "test_s*.txt", "test_out"
	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	echo    e2.desc
	f.Write  "src3"
	If e2.num <> 0 Then  Fail
	f = Empty
	If ReadFile( "test_src.txt" ) <> "src2src3" Then  Fail
	If ReadFile( "test_out\test_src.txt" ) <> "src2" Then  Fail

	T_CopyLocked_del
	Pass
End Sub


Sub  T_CopyLocked_del()
	del  "test_out"
	del  "test_src.txt"
	del  "test_dst.txt"
End Sub


 
'********************************************************************************
'  <<< [T_Move2] >>> 
'********************************************************************************
Sub  T_Move2( Opt, AppKey )
	Dim  e, w_
	cd  g_fs.GetParentFolderName( WScript.ScriptFullName )


	'//=== 同じフォルダーへ移動・コピーする
	For Each  operation  In  Array( "move", "copy" )
		Set copy_or_move = GetRef( operation )
		Set copy_ren_or_move_ren = GetRef( operation +"_ren" )


		Set w_=AppKey.NewWritable( "work" ).Enable()
		del    "work"
		mkdir  "work"
		copy  "data\src1.txt", "work\a"

		Set w_=AppKey.NewWritable( "work\a" ).Enable()

		Assert  g_fs.FileExists( "work\a\src1.txt" )

			copy_ren_or_move_ren  "work\a", "work\a"

		Assert  g_fs.FileExists( "work\a\src1.txt" )

			copy_ren_or_move_ren  "work\a\src1.txt", "work\a\src1.txt"

		Assert  g_fs.FileExists( "work\a\src1.txt" )

			copy_or_move  "work\a", "work"

		Assert  g_fs.FileExists( "work\a\src1.txt" )

			copy_or_move  "work\a\src1.txt", "work\a"

		Assert  g_fs.FileExists( "work\a\src1.txt" )

		Set w_=AppKey.NewWritable( "work" ).Enable()
		del    "work"
	Next


	SetErrorOfOldSpec


	'//=== move で改名しようとしたときは廃止予告にかける (vbslib4のみ)

	Set w_=AppKey.NewWritable( "work" ).Enable()
	del    "work"
	mkdir  "work"
	copy  "data\src1.txt", "work"

	g_Vers("CopyTargetIsFileOrFolder") = 1
	If TryStart(e) Then  On Error Resume Next
		move  "work\src1.txt", "work\to"
	If TryEnd Then  On Error GoTo 0
	Assert  e.num = 1
	e.Clear
	del  "work"


	'//=== 作成されていないフォルダへ移動する

	Set w_=AppKey.NewWritable( "work" ).Enable()
	del    "work"
	mkdir  "work"
	copy  "data\src1.txt", "work"

	Set w_=AppKey.NewWritable( Array( "work\src1.txt", "work\to\src1.txt" ) ).Enable()
	move_ren  "work\src1.txt", "work\to\src1.txt"
	Assert  g_fs.FileExists( "work\to\src1.txt" )
	Set w_=AppKey.NewWritable( "work" ).Enable()
	del  "work"


	g_Vers("CopyTargetIsFileOrFolder") = Empty
	SetNotErrorOfOldSpec

	Pass
End Sub


 
'********************************************************************************
'  <<< [T_del_empty_folder] >>> 
'********************************************************************************
Sub  T_del_empty_folder( Opt, AppKey )
	Set w_=AppKey.NewWritable( "_work" ).Enable()

	For Each  t  In DicTable( Array( _
		"TestName",     "BeforePath",   "Parameter", "AnswerPath",   Empty, _
		"WithSubFolder",     "Case1",   "_work",     "Case1_ans", _
		"WithoutSubFolder",  "Case1",   "_work\.",   "Case1_ans2", _
		"WithoutSubFolder0", "Case1\0", "_work\.",   Empty ) )

		T_del_empty_folder_Sub  t("TestName"), t("BeforePath"), t("Parameter"), t("AnswerPath")
	Next

	Pass
End Sub


 
Sub  T_del_empty_folder_Sub( TestName, BeforePath, Parameter, AnswerPath )
	Set section = new SectionTree

	If section.Start( "T_del_empty_folder_"+ TestName ) Then

	'// Set up
	del  "_work"
	copy  "T_del_empty_folder_data\"+ BeforePath +"\*", "_work"


	'// Test Main
	del_empty_folder  Parameter


	'// Test Main
	If not IsEmpty( AnswerPath ) Then
		Assert  fc( "_work", "T_del_empty_folder_data\"+ AnswerPath )
	Else
		Assert  not exist( "_work" )
	End If


	'// Clean
	del  "_work"

	End If : section.End_
End Sub


 
'********************************************************************************
'  <<< [T_del_byPathDictionary] >>> 
'********************************************************************************
Sub  T_del_byPathDictionary( Opt, AppKey )
	Set w_=AppKey.NewWritable( "_work" ).Enable()

	'// Set up
	del  "_work"
	unzip  "Files\T_del_byPathDictionary.zip", "_work\T_del_byPathDictionary", Empty
	target_root = "_work\T_del_byPathDictionary\1_Before"

	'// Test Main
	Set dic = new_PathDictionaryClass_withRemove( target_root, Array( _
		"Out of Target", _
		"Out of Target.txt", _
		"Sub\Out of Target", _
		"Sub\Out of Target.txt" ), _
		new NameOnlyClass )

	del  dic


	'// Check
	Assert  fc( target_root, "_work\T_del_byPathDictionary\2_Answer" )


	'// Clean
	del  "_work"

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

 
