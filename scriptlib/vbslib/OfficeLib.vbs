Dim  g_is_MS_office_message


 
'***********************************************************************
'* Function: Show_MS_OfficeMessage
'***********************************************************************
Sub  Show_MS_OfficeMessage()
	If not g_is_MS_office_message Then
		echo  "コントロールパネルの「プログラムのアンインストール」から、起動したいバージョンの"+_
			"MS-Office を修復すると、そのバージョンが起動します。"
		echo_line

		g_is_MS_office_message = True
	End If
End Sub


 
'***********************************************************************
'* Function: OpenWordFile
'***********************************************************************
Function  OpenWordFile( in_Path, in_IsShow )
	Const wdWindowStateNormal = 0
	Const wdWindowStateMinimize = 2

	AssertExist  in_Path
	Set word = GetMicrosoftWord()
	If in_IsShow Then
		word.WindowState = wdWindowStateNormal
	Else
		word.WindowState = wdWindowStateMinimize
	End If
	Set OpenWordFile = word.Documents.Open( g_fs.GetAbsolutePathName( in_Path ) )
End Function


 
'***********************************************************************
'* Function: GetMicrosoftWord
'***********************************************************************
Function  GetMicrosoftWord()
	If IsEmpty( g_w ) Then
		Show_MS_OfficeMessage
		Set g_w = WScript.CreateObject("Word.Application")
		g_w.Visible = True
	End If

	Set GetMicrosoftWord = g_w
End Function

Dim  g_w


 
'***********************************************************************
'* Function: ReleaseMicrosoftWord
'***********************************************************************
Sub  ReleaseMicrosoftWord( in_out_LastFile, in_IsClose )
	If IsEmpty( in_out_LastFile ) Then
		Set app = GetMicrosoftWord()
	Else
		Set doc = in_out_LastFile
		in_out_LastFile = Empty

		Set app = doc.Application
		If in_IsClose Then _
			doc.Close
		doc = Empty
	End If

	g_w = Empty
	If in_IsClose Then _
		app.Quit
End Sub


 
'***********************************************************************
'* Function: OpenExcelFile
'***********************************************************************
Function  OpenExcelFile( in_Path,  out_RenamedPath,  in_IsShow )
	Const xlNormal = -4143
	Const xlMinimized = -4140

	AssertExist  in_Path
	full_path = g_fs.GetAbsolutePathName( in_Path )
	out_RenamedPath = Empty
	Set xl = GetMicrosoftExcel()
	If in_IsShow Then
		xl.WindowState = xlNormal
		update_links = 3
	Else
		xl.WindowState = xlMinimized
		update_links = 0
	End If


	Set OpenExcelFile = xl.Workbooks.Open( full_path,  update_links )


	'// If same file name exists, ...
	If OpenExcelFile is Nothing  and  not in_IsShow Then
		ReDim  opened_names( xl.Workbooks.Count - 1 )
		For i=0 To  UBound( opened_names )
			opened_names(i) = g_fs.GetBaseName( xl.Workbooks(i+1).Name )
		Next


		'// Set "new_full_path"
		For  new_index = 1  To  99
			new_name = g_fs.GetBaseName( in_Path ) +"_"+ CStr( new_index )

			is_opened = False
			For Each  opened_name  In  opened_names
				If StrComp( opened_name, new_name, 1 ) = 0 Then
					is_opened = True
					Exit For
				End If
			Next

			If not is_opened Then _
				Exit For
		Next
		Assert  not is_opened
		new_file_name = new_name +"."+ g_fs.GetExtensionName( full_path )
		new_full_path = GetTempPath( new_file_name )
		g_xl_renamed( full_path ) = new_full_path


		'// Open
		If not IsSameBinaryFile( full_path,  new_full_path,  Empty ) Then _
			copy_ren  full_path,  new_full_path

		Set OpenExcelFile = xl.Workbooks.Open( new_full_path,  update_links )
		Assert  not OpenExcelFile is Nothing
	End If
End Function


 
'***********************************************************************
'* Function: GetMicrosoftExcel
'***********************************************************************
Function  GetMicrosoftExcel()
	If IsEmpty( g_xl ) Then
		Show_MS_OfficeMessage
		Set g_xl = WScript.CreateObject("Excel.Application")
		g_xl.Visible = True

		Set g_xl_renamed = CreateObject( "Scripting.Dictionary" )
	End If

	Set GetMicrosoftExcel = g_xl
End Function

Dim  g_xl
Dim  g_xl_renamed  '// Key = original path, Item = renamed path


 
'***********************************************************************
'* Function: ReleaseMicrosoftExcel
'***********************************************************************
Sub  ReleaseMicrosoftExcel( in_out_LastFile, in_IsClose )
	If IsEmpty( in_out_LastFile ) Then
		Set app = GetMicrosoftExcel()
	Else
		Set book = in_out_LastFile
		in_out_LastFile = Empty

		Set app = book.Application
		If in_IsClose Then _
			book.Close
		book = Empty
	End If

	g_xl = Empty
	If in_IsClose Then _
		app.Quit

	For Each  original_path  In  g_xl_renamed.Keys
		renamed_path = g_xl_renamed( original_path )
		If not exist( original_path )  and  exist( renamed_path ) Then
			If not IsSameBinaryFile( renamed_path,  original_path,  Empty ) Then _
				copy_ren  renamed_path,  original_path
		End If
	Next
End Sub


 
'***********************************************************************
'* Function: OpenPowerPointFile
'***********************************************************************
Function  OpenPowerPointFile( in_Path, in_IsShow )
	Const ppWindowNormal = 1
	Const ppWindowMinimized = 2

	AssertExist  in_Path
	Set ppt = GetMicrosoftPowerPoint()
	If in_IsShow Then
		ppt.WindowState = ppWindowNormal
	Else
		ppt.WindowState = ppWindowMinimized
	End If
	Set OpenPowerPointFile = ppt.Presentations.Open( g_fs.GetAbsolutePathName( in_Path ), , , True )

	If not in_IsShow Then
		ppt.WindowState = ppWindowMinimized
	End If
End Function


 
'***********************************************************************
'* Function: GetMicrosoftPowerPoint
'***********************************************************************
Function  GetMicrosoftPowerPoint()
	If IsEmpty( g_ppt ) Then
		Show_MS_OfficeMessage
		Set g_ppt = WScript.CreateObject("PowerPoint.Application")
		'// g_ppt.Visible = True '// This code shows empty power point window.
	End If

	Set GetMicrosoftPowerPoint = g_ppt
End Function

Dim  g_ppt


 
'***********************************************************************
'* Function: ReleaseMicrosoftPowerPoint
'***********************************************************************
Sub  ReleaseMicrosoftPowerPoint( in_out_LastFile, in_IsClose )
	If IsEmpty( in_out_LastFile ) Then
		Set app = GetMicrosoftPowerPoint()
	Else
		Set presentation = in_out_LastFile
		in_out_LastFile = Empty

		Set app = presentation.Application
		If in_IsClose Then _
			presentation.Close
		presentation = Empty
	End If

	g_ppt = Empty
	If in_IsClose Then _
		app.Quit
End Sub


 
'***********************************************************************
'* Function: JumpExcelHyperlinkToThePage
'***********************************************************************
Private Sub  JumpExcelHyperlinkToThePage( in_FilePath,  in_PageNum )
	'// Constant of MS Office objects
	Const wdGoToPage = 1
	Const wdGoToAbsolute = 1
	Set fs = CreateObject("Scripting.FileSystemObject")

	'// ...
	extension = fs.GetExtensionName( in_FilePath )
	If Left( extension, 3 ) = "doc" Then
		Set word = GetWordFile( in_FilePath )
		If word.Parent.ActiveWindow.View.ReadingLayout Then
			word.Parent.ActiveWindow.View.ReadingLayout = False
		End If
		word.Parent.Selection.Goto  wdGoToPage,  wdGoToAbsolute,  in_PageNum
		If word.ReadOnly Then
			sub_string = " [読み取り専用]"
		Else
			sub_string = ""
		End If
		VBA.AppActivate  fs.GetFileName( in_FilePath ) + sub_string +" - "+ word.Application.Caption  '// Word 2013
		word = Empty
	ElseIf Left( extension, 3 ) = "ppt" Then
		Set ppt = GetPowerPointFile( in_FilePath )
		ppt.Application.ActiveWindow.View.GotoSlide  in_PageNum
		VBA.AppActivate  ppt.Application.Caption +" - PowerPoint"  '// PowerPoint 2013
		ppt = Empty
	ElseIf Left( extension, 3 ) = "xls" Then
		Set excel_ = GetExcelFile( in_FilePath )
		pos = InStr( in_PageNum, "!" )  '// pos = exclamation position
		If pos = 0 Then
			sheet_name = in_PageNum
		Else
			sheet_name   = Left( in_PageNum,  pos - 1 )
			cell_position = Mid( in_PageNum,  pos + 1 )
		End If
		Set sheet_ = excel_.Sheets( sheet_name )
		sheet_.Activate
		If not IsEmpty( cell_position ) Then _
			sheet_.Range( cell_position ).Select
		VBA.AppActivate  excel_.Application.Caption  '// Excel 2013
		excel_ = Empty
	Else
		Set sh = CreateObject("Wscript.Shell")
		sh.Run """"+ in_FilePath +"""", 3
		sh = Empty
	End If
End Sub


 
