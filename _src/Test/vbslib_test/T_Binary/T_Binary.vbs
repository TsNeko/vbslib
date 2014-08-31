Sub  Main( Opt, AppKey )
	g_Vers("CutPropertyM") = True
	Dim  o : Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array( "1","T_Binary1", "2","T_MIME" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'********************************************************************************
'  <<< [T_Binary1] >>> 
'********************************************************************************
Sub  T_Binary1( Opt, AppKey )
	Set section = new SectionTree
	Set w_=AppKey.NewWritable( "." ).Enable()
'//SetStartSectionTree  "T_Binary_SizeZero"


	If section.Start( "T_Binary_ArrayNum" ) Then

		Set bin = new BinaryArray
		bin.Size = 4
		bin(0) = &hFF  '// low  byte of BOM
		bin(1) = &hFE  '// high byte of BOM
		bin(2) = &h80  '// low  byte of hiragana mu
		bin(3) = &h30  '// high byte of hiragana mu
		bin.Save  "unicode_mu.txt"
		echo  bin


		Set bin = new BinaryArray
		bin.Load  "unicode_mu.txt"
		strbin = bin.Read( Empty, Empty )
		strbin = LeftB( strbin, 2 ) + ChrB( &h6F ) + ChrB( &h30 ) + MidB( strbin, 3 )
		bin.Write  0, Empty, strbin
		bin.Save  "unicode_hamu.txt"

		Set bin = ReadBinaryFile( "unicode_hamu.txt" )
		Assert  bin(0) = &hFF  and  bin(1) = &hFE

	End If : section.End_


	If section.Start( "T_Binary_Load" ) Then

		Set bin = new BinaryArray
		bin.Load  "a.bin"  '#########

		Assert  bin.Size = &h10
		For i=0 To &h0F : Assert  bin(i) = i : Next

	End If : section.End_


	If section.Start( "T_Binary_Save" ) Then

		bin.Length = &h100
		For i = &h10 To &hFF
			bin(i) = i
		Next
		bin.Save  "b.bin"  '#########

		Set bin = new BinaryArray
		bin.Load  "b.bin"
		Assert  bin.Size = &h100
		For i=0 To &hFF : Assert  bin(i) = i : Next

	End If : section.End_


	If section.Start( "T_Binary_Hash" ) Then

		hash = ReadBinaryFile( "unicode_hamu.txt" ).MD5
		Assert  hash = "491c36482a2ef25ebbb20f59a47908a7"

		hash = ReadBinaryFile( "unicode_hamu.txt" ).SHA1
		Assert  hash = "14adf46c7b38592f04c30440901f37d5e7f0c52c"

		hash = ReadBinaryFile( "unicode_hamu.txt" ).SHA256
		Assert  hash = "728f6439b3710a2cb6c3aa7f18291aab1402303404216fed2a76145aa27b0430"

		hash = ReadBinaryFile( "unicode_hamu.txt" ).SHA384
		Assert  hash = "afe1add375252807111c70d5ebd7a22f2f5a0d790436a9b426e3e7dcfb253a20b99fbd3b02408d1608d16d8f4e6b8214"

		hash = ReadBinaryFile( "unicode_hamu.txt" ).SHA512
		Assert  hash = "4fa128de053066a3932706dd245f06e5488dd924a4fec73cdbf2e23e8d96456e6b24c1718ec3f7cca8546050402a36f9b8551a90ae22ba126ebfd921187f4534"

		hash = ReadBinaryFile( "unicode_hamu.txt" ).RIPEMD160
		Assert  hash = "563af3f1bd7a1dbf7a14ecd5a19ac77bae8eb860"

	End If : section.End_


	If section.Start( "T_Binary_SkippedBytes" ) Then

		Set bin = new BinaryArray
		bin.ReDim_  255*2
		For i = 0 To 255
			bin(i*2) = i  '#########
		Next
		Assert  bin.Size = &h1FF
		For i=0 To &hFE : Assert  bin(i*2) = i : Assert  bin(i*2+1) = 0 : Next
		Assert  bin(&h1FE) = &hFF

	End If : section.End_


	If section.Start( "T_Binary_SizeExpandedData" ) Then

		Set bin = new BinaryArray
		bin.Size = &h100  '#########
		For i=0 To &hFF : Assert  bin(0) = 0 : Next

	End If : section.End_


	If section.Start( "T_Binary_ChangeSize" ) Then

		Set bin = new BinaryArray
		bin.ReDim_            255  '#########
		Assert  bin.Size    = 256
		bin.Size            = 128
		Assert  bin.Count   = 128
		bin.Count           =  64
		Assert  bin.Length  =  64
		bin.Length          =  32
		Assert  bin.UBound_ =  31
		For i=0 To 31 : Assert  bin(i) = 0 : Next

	End If : section.End_


	If section.Start( "T_Binary_Reduce" ) Then

		Set bin = new BinaryArray
		bin.ReDim_  255
		For i = 0 To 255
			bin(i) = i
		Next
		bin.ReDim_  127  '#########
		bin.Save  "b.bin"

		Set bin = new BinaryArray
		bin.Load  "b.bin"
		Assert  bin.UBound_ = 127
		For i=0 To 127 : Assert  bin(i) = i : Next

	End If : section.End_


	If section.Start( "T_Binary_SizeZero" ) Then

		Set bin = new BinaryArray
		bin.ReDim_  0
		bin.ToEmpty
		bin.Save  "b.bin"
		Assert  g_fs.GetFile("b.bin").Size = 0

		hash = ReadBinaryFile( "b.bin" ).MD5
		Assert  hash = "d41d8cd98f00b204e9800998ecf8427e"

	End If : section.End_


	If section.Start( "T_Binary_Value" ) Then

		Set bin = new BinaryArray
		For Each t  In  DicTable( Array( _
		_
			"ByteSize", "ValueAnswer",                                       "// Comment", Empty, _
			         3, "30 31 32",                                          "// Basic Test", _
			      &h10, "30 31 32 33 34 35 36 37 38 39 3A 3B 3C 3D 3E 3F",   "// Junt One Line", _
			      &h13, "30 31 32 33 34 35 36 37 38 39 3A 3B 3C 3D 3E 3F" +vbCRLF+ _
			            "40 41 42",                                          "// Two Lines" ) )

			bin.Length = t("ByteSize")
			For i = 0 To t("ByteSize") - 1
				bin(i) = &h30 + i
			Next
			Assert  bin.xml = "<BinaryArray size=""0x"& Hex( t("ByteSize") ) &""">"+vbCRLF+_
				 t("ValueAnswer") +vbCRLF+ "</BinaryArray>"
		Next

	End If : section.End_


	If section.Start( "T_Binary_ByteArray" ) Then

		Set bin = new BinaryArray
		bin.Length = 10
		For i = 0 To 9
			bin(i) = i + &h30
		Next

		t = bin.Read( 2, 2 )    '// read part
		Assert  LenB( t ) = 2
		Assert  AscB( MidB( t, 1, 1 ) ) = &h32
		Assert  AscB( MidB( t, 2, 1 ) ) = &h33

		t = bin.Read( Empty, Empty )  '// read whole
		Assert  LenB( t ) = 10

		bin.Write  5, 3, t     '// part of t
		Assert  bin.xml = "<BinaryArray size=""0xA"">" +vbCRLF+_
			"30 31 32 33 34 30 31 32 38 39" +vbCRLF+_
			"</BinaryArray>"

		bin.Write  1, 10, t    '// same size
		Assert  bin.xml = "<BinaryArray size=""0xB"">" +vbCRLF+_
			"30 30 31 32 33 34 35 36 37 38 39" +vbCRLF+_
			"</BinaryArray>"

		bin.Write  16, 16, t   '// expand
		Assert  bin.xml = "<BinaryArray size=""0x20"">" +vbCRLF+_
			"30 30 31 32 33 34 35 36 37 38 39 00 00 00 00 00" +vbCRLF+_
			"30 31 32 33 34 35 36 37 38 39 00 00 00 00 00 00" +vbCRLF+_
			"</BinaryArray>"

	End If : section.End_


	If section.Start( "T_Binary_Write" ) Then

		Set bin = new BinaryArray
		bin.Write  0, Empty, "ABC"
		Assert  bin.xml = "<BinaryArray size=""0x6"">" +vbCRLF+_
			"41 00 42 00 43 00" +vbCRLF+_
			"</BinaryArray>"

		bin.Write  0, Empty, &h42
		Assert  bin.xml = "<BinaryArray size=""0x6"">" +vbCRLF+_
			"42 00 42 00 43 00" +vbCRLF+_
			"</BinaryArray>"

		bin.Write  0, Empty, Array( &h42, &h4D )
		Assert  bin.xml = "<BinaryArray size=""0x6"">" +vbCRLF+_
			"42 4D 42 00 43 00" +vbCRLF+_
			"</BinaryArray>"

		bin.Write  0, 4, "DEF"
		Assert  bin.xml = "<BinaryArray size=""0x6"">" +vbCRLF+_
			"44 00 45 00 43 00" +vbCRLF+_
			"</BinaryArray>"

	End If : section.End_


	If section.Start( "T_Binary_BytesToShortInt_BytesToLong" ) Then

		Set c = get_ADODBConsts()
		Assert  c.BytesToShortInt( &h12, &h34 ) = &h3412
		Assert  c.BytesToShortInt( &hF0, &hF1 ) = &hF1F0
		Assert  c.BytesToUShortIntToLongInt( &hFE, &hFF ) = 65534
		Assert  c.BytesToLongInt( &h12, &h34, &h56, &h78 ) = &h78563412
		Assert  c.BytesToLongInt( &hF0, &hF1, &hF2, &hF3 ) = &hF3F2F1F0
		t = c.ShortIntToBytes( &h3412 ) : Assert  t(0)=&h12 and t(1)=&h34 and UBound(t)=1
		t = c.ShortIntToBytes( &hF1F0 ) : Assert  t(0)=&hF0 and t(1)=&hF1 and UBound(t)=1
		t = c.LongIntToUShortIntToBytes(&h3412 ) : Assert  t(0)=&h12 and t(1)=&h34 and UBound(t)=1
		t = c.LongIntToUShortIntToBytes( 65534 ) : Assert  t(0)=&hFE and t(1)=&hFF and UBound(t)=1
		t = c.LongIntToBytes( &hF1F0 )     : Assert  t(0)=&hF0 and t(1)=&hF1 and t(2)=&h00 and t(3)=&h00 and UBound(t)=3
		t = c.LongIntToBytes(  65534 )     : Assert  t(0)=&hFE and t(1)=&hFF and t(2)=&h00 and t(3)=&h00 and UBound(t)=3
		t = c.LongIntToBytes( &h78563412 ) : Assert  t(0)=&h12 and t(1)=&h34 and t(2)=&h56 and t(3)=&h78 and UBound(t)=3
		t = c.LongIntToBytes( &hF3F2F1F0 ) : Assert  t(0)=&hF0 and t(1)=&hF1 and t(2)=&hF2 and t(3)=&hF3 and UBound(t)=3

	End If : section.End_


	If section.Start( "T_Binary_ReadArray_WriteArray" ) Then

		Set bin = new BinaryArray
		bin.Write  0, Empty, Array( &h80, &h02, &h01, &hFF, &h00, &h03, &h01, &hFE, &h03 )

		size = bin.ReadStruct( 1, out, Array( "a", vbByte,  "b", vbInteger,  "c", vbLong ) )
		Assert  size = 7
		Assert  out("a") = &h02
		Assert  out("b") = &hFF01
		Assert  out("c") = &hFE010300

		size = bin.ReadStruct( 1, out, Array( "arr", vbByte+vbArray, 4 ) )
		Assert  size = 4
		Assert  IsSameArray( out("arr"), Array( &h02, &h01, &hFF, &h00 ) )

		size = bin.ReadStruct( 3, out, Array( "arr2", vbInteger+vbArray, -1 ) )
		Assert  size = 6
		Assert  IsSameArray( out("arr2"), Array( &hFF, &h0103, &h3FE ) )

		size = bin.ReadStruct( 1, out, Array( "arr", vbLong+vbArray, 2 ) )
		Assert  size = 8
		Assert  IsSameArray( out("arr"), Array( &hFF0102, &h03FE0103 ) )

		arr = Array( &h01, &hF0, &h03 )
		bin.WriteStruct  &h40, Array( vbByte+vbArray, arr )
		size = bin.ReadStruct( &h40, out, Array( "arr1", vbByte+vbArray, 3 ) )
		Assert  size = 3
		Assert  IsSameArray( arr, out("arr1") )

		arr = Array( &h0102, &hF0F1, &h03FF )
		bin.WriteStruct  &h40, Array( vbInteger+vbArray, arr )
		size = bin.ReadStruct( &h40, out, Array( "arr2", vbInteger+vbArray, 3 ) )
		Assert  size = 6
		Assert  IsSameArray( arr, out("arr2") )

		arr = Array( &h0102, &hF0F1, &h03FF )
		bin.WriteStruct  &h40, Array( vbInteger+vbArray, arr )
		size = bin.ReadStruct( &h40, out, Array( "arr3", vbInteger+c.Unsigned+vbArray, 3 ) )
		Assert  size = 6
		arr(1) = arr(1) + &h10000  '// +&h10000 because &hF0F1 is minus
		Assert  IsSameArray( arr, out("arr3") )

		arr = Array( &h01020304, &hF0F1F3F4, &h03FF )
		bin.WriteStruct  &h40, Array( vbLong+vbArray, arr )
		size = bin.ReadStruct( &h40, out, Array( "arr", vbLong+vbArray, 3 ) )
		Assert  size = 12
		Assert  IsSameArray( arr, out("arr") )

	End If : section.End_


	If section.Start( "T_Binary_WriteFromBinaryArray" ) Then

		'//=== Test of WriteFromBinaryArray
		T_WriteFromBinaryArray_Sub _
			Array( &h80, &h02, &h01, &hFF, &h00, &h03, &h01, &hFE, &h03 ), _
			Array( Array( 0, 0, 4 ), Array( 2, 0, 4 ), Array( 6, 7, 1 ) ), _
			Array( &h80, &h02, &h80, &h02, &h01, &hFF, &hFE )


		'//=== Test of WriteFromBinaryArray : read all
		T_WriteFromBinaryArray_Sub _
			Array( &h10, &h11 ), _
			Array( Array( 0, 0, -1 ) ), _
			Array( &h10, &h11 )


		'//=== Test of WriteFromBinaryArray : read over
		T_WriteFromBinaryArray_Sub _
			Array( &h10, &h11 ), _
			Array( Array( 0, 0, 3 ) ), _
			Array( &h10, &h11 )


		'//=== Test of WriteFromBinaryArray : write over
		T_WriteFromBinaryArray_Sub _
			Array( &h10, &h11 ), _
			Array( Array( 3, 0, 2 ) ), _
			Array( &h00, &h00, &h00, &h10, &h11 )

	End If : section.End_


	If section.Start( "T_Binary_Compare" ) Then

		Set a = new_BinaryArray( Array( &h12, &h34, &h56, &h78 ) )
		Set b = new_BinaryArray( Array( &h12, &h56, &h34, &h78 ) )
		Assert  a.Compare( b ) < 0

		Set a = new_BinaryArray( Array( &h12 ) )
		Set b = new_BinaryArray( Array( &h12, &h34 ) )
		Assert  a.Compare( b ) < 0

		Set a = new_BinaryArray( Array( &h12, &h34 ) )
		Set b = new_BinaryArray( Array( &h12 ) )
		Assert  a.Compare( b ) > 0

		Set a = new_BinaryArray( Array( &h12, &h34 ) )
		Set b = new_BinaryArray( Array( &h12, &h34 ) )
		Assert  a.Compare( b ) = 0

		Set a = new_BinaryArray( Array( ) )
		Set b = new_BinaryArray( Array( ) )
		Assert  a.Compare( b ) = 0

	End If : section.End_


	If section.Start( "Test_of_SwapEndian" ) Then  '// [Test_of_SwapEndian]

		Set bin = new_BinaryArray( Array( &h12, &h34, &h56, &h78 ) )
		Set ans = new_BinaryArray( Array( &h12, &h56, &h34, &h78 ) )
		bin.SwapEndian  1, 2, 2
		Assert  bin.Compare( ans ) = 0

		Set bin = new_BinaryArray( Array( &h12, &h34, &h56, &h78, &h9A, &hBC ) )
		Set ans = new_BinaryArray( Array( &h12, &h9A, &h78, &h56, &h34, &hBC ) )
		bin.SwapEndian  1, 4, 4
		Assert  bin.Compare( ans ) = 0

		Set bin = new_BinaryArray( Array( &h12, &h34, &h56, &h78, &h9A, &hBC ) )
		Set ans = new_BinaryArray( Array( &h12, &h56, &h34, &h9A, &h78, &hBC ) )
		bin.SwapEndian  1, 4, 2
		Assert  bin.Compare( ans ) = 0

	End If : section.End_


	If section.Start( "Test_of_Base64" ) Then  '// [Test_of_Base64]

		'// Encode
		Set bin = new_BinaryArray( Array( &h12, &h34, &h56, &h78 ) )
		text_base64 = bin.Base64
		Assert  text_base64 = "EjRWeA=="

		'// Decode
		Set bin2 = new_BinaryArrayFromBase64( text_base64 )
		Assert  bin.Compare( bin2 ) = 0

		'// Case of error raised
		text_base64 = new_BinaryArrayAsText( "ジス太郎", "ISO-2022-JP" ).Base64
		Assert  text_base64 = "GyRCJTglOUJATzobKEI="

	End If : section.End_


	If section.Start( "T_Binary_TextCharacterSet" ) Then

		'// From character set
		Set bin = new_BinaryArray( Array( &h8A, &hBF, &h8E, &h9A ) )
		Assert  bin.Text( "Shift-JIS" ) = "漢字"

		Set bin = new_BinaryArray( Array( &hB4, &hC1, &hBB, &hFA ) )
		Assert  bin.Text( "EUC-JP" ) = "漢字"

		'// To character set
		Set bin = new_BinaryArrayAsText( "漢字", "Shift-JIS" )
		Assert  bin.Text( "Shift-JIS" ) = "漢字"

		Set bin = new_BinaryArrayAsText( "漢字", "EUC-JP" )
		Assert  bin.Text( "EUC-JP" ) = "漢字"

	End If : section.End_


	del  "b.bin"
	del  "unicode_mu.txt"
	del  "unicode_hamu.txt"
	Pass
End Sub


 
Sub  T_WriteFromBinaryArray_Sub( InputArray, TestParams, AnswerArray )
	Dim  bin,  bin2,  sub_params

	echo  "T_WriteFromBinaryArray"

	Set bin = new BinaryArray
	bin.Write  0, Empty, InputArray
	bin.Save  "b.bin"
	bin = Empty

	Set bin  = new BinaryArray
	Set bin2 = new BinaryArray  '// Empty array
	bin.Load  "b.bin"  '// "InputArray"
	For Each  sub_params  In TestParams
		'//                        WriteOffset,          ReadOffset,     Size
		bin2.WriteFromBinaryArray  sub_params(0),  bin,  sub_params(1),  sub_params(2)
	Next
	bin2.Save  "c.bin"
	bin  = Empty
	bin2 = Empty

	Set bin = new BinaryArray
	bin.Write  0, Empty, AnswerArray
	bin.Save  "b.bin"
	bin = Empty

	Assert  IsSameBinaryFile( "b.bin", "c.bin", Empty )

	del  "b.bin"
	del  "c.bin"
End Sub


 
'********************************************************************************
'  <<< [T_MIME] >>> 
'********************************************************************************
Sub  T_MIME( Opt, AppKey )
	str = Decode_MIME_HeaderLine( "Subject: =?ISO-2022-JP?B?YWJjGyRCJUYlOSVIGyhCZGVm?=" )
	Assert  str = "Subject: abcテストdef"

	str = Decode_MIME_HeaderLine( "Subject: English only?" )
	Assert  str = "Subject: English only?"

	str = Decode_MIME_HeaderLine( "From: =?ISO-2022-JP?B?GyRCJTglOUJATzobKEI=?= <user.1@example.com>" )
	Assert  str = "From: ジス太郎 <user.1@example.com>"

	Pass
End Sub


 







'--- start of vbslib include ------------------------------------------------------ 

'// ここの内部から Main 関数を呼び出しています。
'// また、scriptlib フォルダーを探して、vbslib をインクルードしています

'// vbslib is provided under 3-clause BSD license.
'// Copyright (C) 2007-2014 Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.

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


  
