' Module Mixer  ver3.00  Sep.22, 2009
' Copyright (c) 2009, T's-Neko at Sage Plaisir 21 (Japan)
' All rights reserved. Based on 3-clause BSD license.


Dim  g_SrcPath

Class  mxp3_vbs : Public FullPath : End Class
Dim  g_mxp3_vbs
Set  g_mxp3_vbs =_
	 new mxp3_vbs
With g_mxp3_vbs
	.FullPath = g_SrcPath
End With

Dim  mxp
Dim  Mxp_CHead_Type,  Mxp_C_Type


Const g_Msg_MakeProj_NoWrite = "ファイルが存在するので更新しませんでした"
Const g_Msg_NoSetting = "Mixer_Setting 関数が見つかりません。setting か setting_default に Mixer_Setting.vbs があるかチェックしてください。"
Const NotCaseSensitive = 1
Dim  E_NoReposit : E_NoReposit = &h80043001


 
'********************************************************************************
'  <<< [InitializeModule] >>> 
'********************************************************************************
Function  InitializeModule( ThisPath )
End Function
Dim g_InitializeModule: Set g_InitializeModule = GetRef( "InitializeModule" )


 
'********************************************************************************
'  <<< Const >>> 
'********************************************************************************

Dim  Sect_FileSeparator : Sect_FileSeparator = 1
Dim  Sect_NoInRep       : Sect_NoInRep = 2

Dim  FileSymbol_Var : FileSymbol_Var = "%file_id%"

Dim  RepToWork : RepToWork = 1
Dim  WorkToRep : WorkToRep = -1


'// Mxp_WorkFile::OptionFlags, Mxp_Proj::SetWorkFileOption
Dim  F_AddIfDef            : F_AddIfDef = 1
Dim  F_ReplaceToDefineOnly : F_ReplaceToDefineOnly = 2
Dim  F_CommonIsNoText      : F_CommonIsNoText = 4

 
'********************************************************************************
'  <<< [ShowHelpOfMakeRepository] >>> 
'********************************************************************************
Sub  ShowHelpOfMakeRepository( LibName, ZipPaths, ModuleSymbols )
	Dim  s

	echo  " ((( MakeRepository.vbs for "+ LibName +" )))"
	echo  ""
	echo  LibName +" を Module Mixer のリポジトリにインストールします。"
	echo  ""
	If not IsEmpty( ModuleSymbols ) Then
		echo  "インストールしたら、次のモジュール・シンボルが使えるようになります。"
		echo  ModuleSymbols
		echo  ""
	End If
	If not IsEmpty( ZipPaths ) Then
		echo  "まず、入手したライブラリ・パッケージを下記にコピーしてください。"
		For Each s  In ZipPaths
			echo  GetAbsPath( s, Empty )
		Next
		echo  ""
		s = "コピーしたら、"
	Else
		s = ""
	End If
	echo  s + "次に表示されるメニューで、3 (Test_build) を選択してください。"
	echo  "処理が成功（Pass）して、失敗が無い（Fail=0）なら、インストールは成功です。"
	echo  ""

	If not ArgumentExist( "silent" )  and _
		 not ArgumentExist( "Case" )  and _
		 not ArgumentExist( "All" )  and _
		 not ArgumentExist( "Build" )  and _
		 not ArgumentExist( "Setup" )  and _
		 not ArgumentExist( "Start" )  and _
		 not ArgumentExist( "Check" )  and _
		 not ArgumentExist( "Clean" )  Then  pause

	echo_line
End Sub

 
'-------------------------------------------------------------------------
' ### <<<< [ModuleMixer] Class >>>> 
'-------------------------------------------------------------------------
Function  get_ModuleMixer_file( SetupPath )
	Set get_ModuleMixer_file = new ModuleMixer
	get_ModuleMixer_file.m_SetupPath = SetupPath
End Function


Class  ModuleMixer

	Public  m_SetupPath

	Sub  MakeProj()
		Dim  r, e

		If TryStart(e) Then  On Error Resume Next
			r= RunProg( "cscript """+m_SetupPath+""" /MakeProj", "" )
		If TryEnd Then  On Error GoTo 0
		If e.num = E_NoReposit  Then  echo e.desc : Sleep 2000 : e.Clear
		If e.num <> 0 Then  e.Raise
	End Sub

End Class


 
'-------------------------------------------------------------------------
' ### <<<< [Mxp_Proj] Class >>>> 
'-------------------------------------------------------------------------

Class  Mxp_Proj

	Public  ProjectName    ' as array of string. (0) is for making work file and first project file
	Public  ProjTypeName   ' as array of string. Element number is same as ProjectName
	Public  ProjectFolderAbsPath  '// as string
	Public  WorkFiles      ' as Scripting.Dictionary, Key is file type name, Item is Mxp_WorkFile
	Public  WorkFolders    ' as Scripting.Dictionary, Key is folder type name, Item is Mxp_WorkFolder
	Public  UseFolderPaths ' as Scripting.Dictionary, Key is Mxp_WorkFolder::FolderTypeName, Item is as ArrayClass of string
	Public  DontOverwriteStepPaths()  ' as array of string

	Public  AllRepositories  ' as Scripting.Dictionary, Key is RepositoryName, Item is Mxp_Rep
	Public  AllModules       ' as Scripting.Dictionary, Key is ModuleName, Item is Mxp_Module
	Public  AllSymbols       ' as Scripting.Dictionary, Item is Mxp_Symbol
	Public  AllSourceFiles   ' as Scripting.Dictionary, Key is abs path +"/"+ file type name, Item is Mxp_RepFile

	Public  FileTypes   ' as Scripting.Dictionary, Item is Mxp_FileType
	Public  ProjTypes   ' as Scripting.Dictionary, Item is Mxp_ProjType
	Public  Envs        ' as Scripting.Dictionary, Item is string

	Public  CurrentModuleName ' as String
	Public  CurrentModule     ' as Mxp_Module
	Public  nLocalTextModule  ' as integer
	Public  TransformVariables ' as Scripting.Dictionary, Item is variant

	Public  IsCommonUsesMode  ' as boolean
	Public  OtherModulesOwnerProjectName  ' as string or Empty

	Public  CurrentConfigName    ' as array of string
	Public  DefaultConfigArray   ' as ArrayClass of string
	Public  DefaultConfigsArray  ' as ArrayClass of ArrayClass of string

	Public  DebugMode ' as integer. Me.F_BreakAtSetting or ...
	Public  DebugMode_DependedSymbol ' as string
	Public  DebugMode_Param1
	Public  DebugMode_Param2
	Public  DebugMode_Param3

	Public  F_BreakAtSetting        ' as const integer
	Public  F_BreakAtAddRepository  ' as const integer
	Public  F_BreakAtAddProjectType ' as const integer
	Public  F_BreakAtAddFileType    ' as const integer
	Public  F_BreakAtMakeProj       ' as const integer
	Public  F_BreakAtMakeWorkFile   ' as const integer
	Public  ParentFolderProxyName   ' as const string
	Public  OutConfigIf    ' as const integer
	Public  OutConfigEndIf ' as const integer

	Public  Property Get  Version() : Version = 400 : End Property


 
'********************************************************************************
'  <<< [Mxp_Proj::Class_Initialize] >>> 
'********************************************************************************
Private Sub  Class_Initialize
	Redim  ProjectName(-1)
	Redim  ProjTypeName(-1)
	Set    Me.WorkFiles = CreateObject("Scripting.Dictionary")
	       Me.WorkFiles.CompareMode = NotCaseSensitive
	Set    Me.WorkFolders = CreateObject("Scripting.Dictionary")
	       Me.WorkFolders.CompareMode = NotCaseSensitive
	Redim  DontOverwriteStepPaths(-1)  ' Me.DontOverwriteStepPaths

	Set Me.AllRepositories = CreateObject("Scripting.Dictionary")
	    Me.AllRepositories.CompareMode = NotCaseSensitive
	Set Me.AllModules = CreateObject("Scripting.Dictionary")
	    Me.AllModules.CompareMode = NotCaseSensitive
	Set Me.AllSymbols = CreateObject("Scripting.Dictionary")
	    Me.AllSymbols.CompareMode = NotCaseSensitive
	Set Me.AllSourceFiles = CreateObject("Scripting.Dictionary")
	    Me.AllSourceFiles.CompareMode = NotCaseSensitive

	Set Me.FileTypes  = CreateObject("Scripting.Dictionary")
	    Me.FileTypes.CompareMode = NotCaseSensitive
	Set Me.ProjTypes  = CreateObject("Scripting.Dictionary")
	    Me.ProjTypes.CompareMode = NotCaseSensitive
	Set Me.Envs       = CreateObject("Scripting.Dictionary")
	    Me.Envs.CompareMode = NotCaseSensitive

	Me.CurrentModuleName = ""
	Me.ProjectFolderAbsPath = g_sh.CurrentDirectory
	Me.nLocalTextModule = 0
	Set Me.TransformVariables = CreateObject("Scripting.Dictionary")
	    Me.TransformVariables.CompareMode = NotCaseSensitive
	Me.IsCommonUsesMode = False

	Redim  CurrentConfigName(-1)
	Set Me.DefaultConfigArray = new ArrayClass
	Set Me.DefaultConfigsArray = new ArrayClass

	Me.F_BreakAtSetting = 1
	Me.F_BreakAtAddRepository  = 2
	Me.F_BreakAtAddProjectType = 4
	Me.F_BreakAtAddFileType = 8
	Me.F_BreakAtMakeProj = &h10
	Me.F_BreakAtMakeWorkFile = &h20
	Me.ParentFolderProxyName = "__parent"
	Me.OutConfigIf = 1
	Me.OutConfigEndIf = 2


	Dim  en, ed

	'//=== call Mxp3_DebugSetting
	On Error Resume Next
		GetRef( "Mxp3_DebugSetting" )
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	If en <> 0 and en <> 5 Then  Err.Raise en,,ed
	If en = 0 Then  Mxp3_DebugSetting Me

	'//=== call Mxp3_Setting
	If Me.DebugMode and Me.F_BreakAtSetting Then  Stop
	On Error Resume Next
		GetRef( "Mxp3_Setting" )
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	If en <> 0 and en <> 5 Then  Err.Raise en,,ed
	If en = 0 Then  Mxp3_Setting  Me

	Set mxp = Me

	Mxp_CHead_Type = 1
	Mxp_C_Type = 2
End Sub


 
'// <<< for Mxp3_Setting >>> 


 
'// <<< for Project VBS >>> 


 
'********************************************************************************
'  <<< [Mxp_Proj::AddRepository] >>> 
'********************************************************************************
Public Sub  AddRepository( RepositoryName, FolderPath )
	Dim  rep, folder, fnames(), fname, objs, obj, path
	Dim  create_funcs

	Set rep = new Mxp_Rep
	rep.Name = RepositoryName
	rep.Path = g_fs.GetAbsolutePathName( FolderPath )

	echo  "Add Repository  """ + RepositoryName + """ "+ rep.Path

	If Me.AllRepositories.Exists( RepositoryName ) Then
		Set rep = Me.AllRepositories.Item( RepositoryName )
		path = g_fs.GetAbsolutePathName( FolderPath )
		If StrComp( path, rep.Path, 1 ) = 0 Then
			Exit Sub
		Else
			Raise  1, "<ERROR msg=""リポジトリ名が重複しています"" name="""+_
				RepositoryName +""" folder_1="""+ rep.Path +""" folder_2="""+_
				path +"""/>"
		End If
	End If

	Me.AllRepositories.Add  RepositoryName, rep

	If Me.DebugMode and Me.F_BreakAtAddRepository Then  Stop

If g_Vers( "include_objs" ) Then
  	include_objs  Array( FolderPath + "\*_repository.vbs", _
	                     FolderPath + "\*_type.vbs", _
	                     FolderPath + "\*_module.vbs" ), Empty, create_funcs  '//[out]create_funcs
	get_ObjectsFromFile  create_funcs, "Mxp_FileType", objs  '//[out]objs
	AddArrElem  FileTypes, objs
	get_ObjectsFromFile  create_funcs, "Mxp_ProjType", objs  '//[out]objs
	AddArrElem  ProjTypes, objs
Else

	Set g = g_VBS_Lib
	ExpandWildcard  Array(_
		FolderPath + "\*_repository.vbs", _
		FolderPath + "\*_type.vbs", _
		FolderPath + "\*_module.vbs" ),_
		g.File or g.SubFolder or g.AbsPath or g.ArrayOfArray, Empty,_
		paths_array  '//[out] paths_array as array of ArrayClass

	If UBound( paths_array ) = -1 Then
		echo_v  "Not found any module mixer items in """ + FolderPath + """" +_
				" (Doc:7189)."
		Sleep  200
		Err.Raise  E_TestPass
	End If

	include_objs  paths_array(0).Items, Empty, create_funcs  '//[out]create_funcs

	include_objs  paths_array(1).Items, Empty, create_funcs  '//[out]create_funcs
	get_ObjectsFromFile  create_funcs, "Mxp_FileType", objs  '//[out]objs
	AddArrElem  FileTypes, objs

	get_ObjectsFromFile  create_funcs, "Mxp_ProjType", objs  '//[out]objs
	AddArrElem  ProjTypes, objs

	include_objs  paths_array(2).Items, Empty, create_funcs  '//[out]create_funcs
End If

	echo  "finish to include"
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::AddProjectType] >>> 
'********************************************************************************
Public Sub  AddProjectType( ProjType )
	If Me.DebugMode and Me.F_BreakAtAddProjectType Then  Stop

	Me.ProjTypes.Add  ProjType.Name, ProjType
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::RaiseRepSymbolError] >>> 
'********************************************************************************
Public Sub  RaiseRepSymbolError( RepositoryName )
	Warning  "Repository Symbol """ + RepositoryName + """ is not registered in this PC." +_
		"(Doc:7189)."
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::AddWorkFile] >>> 
'********************************************************************************
Public Sub  AddWorkFile( Path, FileTypeName )
	Set work = AddWorkFileSub( Path, FileTypeName, Empty )

	If IsEmpty( work.FileType.FirstWorkFile ) Then
		Set work.FileType.FirstWorkFile = work
	ElseIf IsEmpty( work.FileType.FirstWorkFile.ModuleTypeName ) Then
		'// 同じファイルタイプでも、SetWorkFileOption が異なる場合があります
	Else
		Set work.FileType.FirstWorkFile = work
		work.ModuleTypeName = ""
	End If
End Sub


Public Function  AddWorkFileSub( Path, FileTypeName, ModuleTypeName )
	Set work = new Mxp_WorkFile
	Set Me.WorkFiles.Item( Path ) = work
	work.StepPath = Path
	work.FileTypeName = FileTypeName
	work.ModuleTypeName = ModuleTypeName

	If TryStart(e) Then  On Error Resume Next
		Set work.FileType = Me.GetFileType_fromName( FileTypeName )
	If TryEnd Then  On Error GoTo 0
	If e.num <> 0 Then  raise e.num, e.desc + " at AddWorkFile( "+Path+" )"+_
		" in " + WScript.ScriptName
	Set AddWorkFileSub = work
End Function


 
'********************************************************************************
'  <<< [Mxp_Proj::AddSubWorkFile] >>> 
'********************************************************************************
Public Sub  AddSubWorkFile( Path, FileTypeName, ModuleTypeName )
	Set work = AddWorkFileSub( Path, FileTypeName, ModuleTypeName )

	If IsEmpty( work.FileType.FirstWorkFile ) Then
		Set work.FileType.FirstWorkFile = work
	ElseIf IsEmpty( work.FileType.FirstWorkFile.ModuleTypeName ) Then
		work.FileType.FirstWorkFile.ModuleTypeName = ""
	End If
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::SetWorkHeadFootReplace] >>> 
'********************************************************************************
Public Sub  SetWorkHeadFootReplace( WorkFilePath, FromString, ToString )
	Dim  path,  work

	For Each work  In Me.WorkFiles.Items
		If StrComp( work.StepPath, WorkFilePath, 1 ) = 0 Then
			work.HeadFootReplaces.Item( FromString ) = ToString
			Exit Sub
		End If
	Next
	Raise 1,"<ERROR msg=""ワークファイルとして設定されていません"" path="""+ WorkFilePath +"""/>"
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::SetWorkFileOption] >>> 
'********************************************************************************
Public Sub  SetWorkFileOption( WorkFilePath, Option_ )
	Dim  path,  work

	For Each work  In Me.WorkFiles.Items
		If StrComp( work.StepPath, WorkFilePath, 1 ) = 0 Then
			work.OptionFlags = Option_
			Exit Sub
		End If
	Next

	Raise 1,"<ERROR msg=""ワークファイルとして設定されていません"" path="""+ WorkFilePath +"""/>"
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::AddWorkFolder] >>> 
'********************************************************************************
Public Sub  AddWorkFolder( Path, FolderTypeName )
	Dim  work

	Set work = new Mxp_WorkFolder
	Set Me.WorkFolders.Item( FolderTypeName ) = work
	work.Path = g_fs.GetAbsolutePathName( Path )
	work.StepPath = Path
	work.FolderTypeName = FolderTypeName
	work.Owner = I_OwnerIsProject
	work.bUses = True
	work.bCollector = True
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::AddDontOverwriteFiles] >>> 
'********************************************************************************
Public Sub  AddDontOverwriteFiles( StepPaths )
	Dim  prev_ubound_plus1, i, last

	If IsArray( StepPaths ) Then
		prev_ubound_plus1 = UBound( DontOverwriteStepPaths ) + 1
		last = prev_ubound_plus1 + UBound( StepPaths )

		ReDim Preserve  DontOverwriteStepPaths( last )

		For i=0 To UBound( StepPaths )
			DontOverwriteStepPaths( prev_ubound_plus1 + i ) = StepPaths( i )
		Next
	Else
		ReDim Preserve  DontOverwriteStepPaths( UBound(DontOverwriteStepPaths) + 1 )
		DontOverwriteStepPaths( UBound(DontOverwriteStepPaths) ) = StepPaths
	End If
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::IsDontOverwriteFile] >>> 
'********************************************************************************
Public Function  IsDontOverwriteFile( StepPath )
	Dim  path

	IsDontOverwriteFile = False
	For Each path  In Me.DontOverwriteStepPaths
		If StrComp( path, StepPath, 1 ) = 0 Then  IsDontOverwriteFile = True : Exit For
	Next
End Function


 
'********************************************************************************
'  <<< [Mxp_Proj::AddTextInWorkFile] >>> 
'********************************************************************************
Public Sub  AddTextInWorkFile( WorkFilePath_or_FileTypeName, EmbedText, Priority )
	Dim  path, work, work_path, file_type_name

	If Me.FileTypes.Exists( WorkFilePath_or_FileTypeName ) Then
		work_path = "Empty"
		file_type_name = WorkFilePath_or_FileTypeName
	Else
		path = WorkFilePath_or_FileTypeName
		For Each work  In Me.WorkFiles.Items
			If StrComp( work.StepPath, path, 1 ) = 0 Then  Exit For
		Next
		If IsEmpty( work ) Then
			Raise 1,"<ERROR msg=""ワークファイルとして設定されていないか、ファイルタイプ名ではありません"" path="""+ _
				WorkFilePath_or_FileTypeName +"""/>"
		End If
		work_path = """"+ path +""""
		file_type_name = work.FileTypeName
	End If


	Me.nLocalTextModule = Me.nLocalTextModule + 1

	'// make a module named module_name
	'// make a symbol named symbol_name
	Dim  file_name   : file_name   = "MemoryMappedFile__"& Me.nLocalTextModule
	Dim  module_name : module_name = "LocalTextModule__" & Me.nLocalTextModule
	Dim  symbol_name : symbol_name = "LocalTextSymbol__" & Me.nLocalTextModule

	'// source of calling Mxp_Symbol::UsesText
	Dim  source : source =_
		"Dim  g_"+ file_name +"_vbs : get_DefineInfoObject  g_"+ file_name +"_vbs, """+ file_name +".vbs""" +vbCRLF+_
		"If mxp.StartModule( """+ module_name +""", g_"+ file_name +"_vbs ) Then" +vbCRLF+_
		+vbCRLF+_
		"Dim "+ symbol_name +" : Set "+ symbol_name +" = mxp.AddNewSymbol( """+ symbol_name +""" )" +vbCRLF+_
		"Function "+ symbol_name +"_setDepend()" +vbCRLF+_
		"  "+ symbol_name +".UsesText  "+ work_path +", """+ file_type_name +""", """+ _
			Replace( Replace( EmbedText, """", """""" ), vbCRLF, """ +vbCRLF+_"+vbCRLF+"      """ ) +_
			"""" +vbCRLF+_
		"End Function : Set "+ symbol_name +".SetDepend = GetRef( """+ symbol_name +"_setDepend"" )" +vbCRLF+_
		+vbCRLF+_
		"End If"+vbCRLF

	ExecuteGlobal  source

	Dim  symbol  ' as Mxp_Symbol
	Set symbol = mxp.AllSymbols.Item( symbol_name )
	symbol.Uses
	symbol.ParentModule.Priority = Priority
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::SetProj] >>> 
'********************************************************************************
Public Sub  SetProj( a_ProjectName, a_ProjTypeName )
	Dim  proj_type  ' as Mxp_ProjType

	Set proj_type = get_Object( a_ProjTypeName )
	proj_type.SetEnvs  Me

	'// Add to Me.ProjectName, Me.ProjTypeName
	ReDim Preserve  ProjectName( UBound( ProjectName ) + 1 )
	ProjectName( UBound( ProjectName ) ) = a_ProjectName
	ReDim Preserve  ProjTypeName( UBound( ProjTypeName ) + 1 )
	ProjTypeName( UBound( ProjTypeName ) ) = a_ProjTypeName

End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::SetCurrentConfig] >>> 
'********************************************************************************
Public Sub  SetCurrentConfig( ConfigName )
	If IsEmpty( ConfigName ) Then
		Redim  CurrentConfigName(-1)
	ElseIf VarType( ConfigName ) = vbString Then
		Redim  CurrentConfigName(0)
		Me.CurrentConfigName(0) = ConfigName
	ElseIf IsArray( ConfigName ) Then
		Me.CurrentConfigName = ConfigName
	ElseIf TypeName( ConfigName ) = "Dictionary" Then
		Redim  CurrentConfigName( ConfigName.Count - 1 )
		Dim  name
		Dim  i : i=0
		For Each name  In ConfigName.Keys
			Me.CurrentConfigName(i) = name
			i=i+1
		Next
	Else
		Err.Raise 1
	End If
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::SetDefaultConfig] >>> 
'********************************************************************************
Public Sub  SetDefaultConfig( ConfigNames )
	If IsArray( ConfigNames ) Then
		Set config_names = new ArrayClass
		config_names.Items = ConfigNames
		Me.DefaultConfigsArray.Add  config_names
	Else
		Me.DefaultConfigArray.Add  ConfigNames
	End If
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::SetModuleOwner] >>> 
'********************************************************************************
Public Sub  SetModuleOwner( ModuleName, ProjectName )
	Dim  module

	If ModuleName = "*" Then
		Me.OtherModulesOwnerProjectName = ProjectName
	Else
		If not Me.AllModules.Exists( ModuleName ) Then _
			Raise  1, "<ERROR msg=""モジュールが見つかりません"" name="""+ ModuleName +"""/>"

		Set module = Me.AllModules.Item( ModuleName )  '// as Mxp_Module
		module.OwnerProjectName = ProjectName
	End If
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::Run] >>> 
'********************************************************************************
Public Sub  Run()
	g_CUI.SetAutoKeysFromMainArg
	Me.IsCommonUsesMode = False

	echo  g_sh.CurrentDirectory +">run Module Mixer"

	If ArgumentExist( "MakeProj" ) Then
		Me.MakeProj2
	ElseIf ArgumentExist( "Clean" ) Then
		Me.Clean2
	ElseIf ArgumentExist( "DeepClean" ) Then
		Me.DeepClean2
	ElseIf ArgumentExist( "RemakeProj" ) Then
		Me.RemakeProj2
	ElseIf ArgumentExist( "Open" ) Then
		Me.OpenOption
	ElseIf ArgumentExist( "GetSymbol" ) Then
		Me.GetSymbol  WScript.Arguments.Named.Item("GetSymbol")
	Else
		Me.DoPrompt
	End If

End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::DoPrompt] >>> 
'********************************************************************************
Public Sub  DoPrompt()
	Dim  op, en,ed

	Do
		echo "--------------------------------------------------------"
		echo "[" + Me.ProjectName(0) + "]"
		echo "3. Make Compiler Project or Synchronize to repository"
		echo "4. Open Repository"
		echo "5. GetSymbol"
		echo "7. Clean"
		echo "77. DeepClean"
		If 0 Then
			echo "6. Out Diff"
			echo "71. Echo loaded modules"
			echo "72. Echo loaded symbols"
			echo "73. Echo using  symbols"
			echo "99: Clean and Quit"
			echo "8: Reload"
		End If
		echo "9. Quit"
		op = input( "Select number>" )
		op = CInt2( op )
		echo "--------------------------------------------------------"
		Select Case op
			Case 3:
				Me.MakeProj2
				Exit Do
			Case 4:  Me.OpenMenu
			Case 5:  Me.GetSymbol  Empty
			Case 7:  Me.Clean2
			Case 77: Me.DeepClean2
			'// Case 6:  Me.OutDiff "out"
			'// Case 71:  Me.EchoAllModules
			'// Case 72:  Me.EchoAllSymbols
			'// Case 73:  Me.EchoUsedSymbols
			'// Case 8:  Me.Reload
			Case 9:  Exit Do
			Case 99: If Me.Clean Then Exit Do
		End Select
	Loop

End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::ResolveDepends] >>> 
'********************************************************************************
Public Sub  ResolveDepends()
	Dim sym, e
	Dim b_do_resolve
	Dim confs_back

	confs_back = Me.CurrentConfigName


	'//=== Resolve symbol depends
	Me.IsCommonUsesMode = False
	Do
		b_do_resolve = False
		For Each sym in  Me.AllSymbols.Items  ' as Mxp_Symbol
			If Not sym.IsResolved() Then  '// If uses and not used
				Me.SetCurrentConfig  sym.UseConfigs
				If TryStart(e) Then  On Error Resume Next
					sym.SetDepend
				If TryEnd Then  On Error GoTo 0
				If e.num <> 0 Then  raise e.num, e.desc + vbCRLF + "Error is in " + sym.Name + ".SetDepend"
				sym.Used = True
				b_do_resolve = True
			End If
		Next
		If Not b_do_resolve Then Exit Do
	Loop


	'//=== Resolve common symbol depends
	Me.IsCommonUsesMode = True
	Do
		b_do_resolve = False
		For Each sym in  Me.AllSymbols.Items  ' as Mxp_Symbol
			If Not sym.IsResolvedCommon() Then  '// If uses and not used
				If TryStart(e) Then  On Error Resume Next
					sym.SetDepend
				If TryEnd Then  On Error GoTo 0
				If e.num <> 0 Then  raise e.num, e.desc + vbCRLF + "Error is in " + sym.Name + ".SetDepend"
				sym.CommonUsed = True
				b_do_resolve = True
			End If
		Next
		If Not b_do_resolve Then Exit Do
	Loop
	Me.IsCommonUsesMode = False


	'//=== Make UseFolderPaths
	Dim  module, arr, work

	Set Me.UseFolderPaths = CreateObject("Scripting.Dictionary")
	    Me.UseFolderPaths.CompareMode = NotCaseSensitive
	For Each work  In Me.WorkFolders.Items ' as Mxp_WorkFolder
		If Me.UseFolderPaths.Exists( work.FolderTypeName ) Then
			Set arr = Me.UseFolderPaths.Item( work.FolderTypeName )
		Else
			Set arr = new ArrayClass
			Set Me.UseFolderPaths.Item( work.FolderTypeName ) = arr
		End If
		arr.Add  work.Path
	Next
	For Each module  In Me.AllModules.Items ' as Mxp_Module
		For Each work  In module.RepFolders.Items ' as Mxp_WorkFolder
			If work.bUses Then
				If Me.UseFolderPaths.Exists( work.FolderTypeName ) Then
					Set arr = Me.UseFolderPaths.Item( work.FolderTypeName )
				Else
					Set arr = new ArrayClass
					Set Me.UseFolderPaths.Item( work.FolderTypeName ) = arr
				End If
				arr.Add  work.Path
			End If
		Next
	Next


	Me.CurrentConfigName = confs_back
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::OutDepends] >>> 
'********************************************************************************
Public Sub  OutDepends
	Me.ResolveDepends
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::EchoAllModules] >>> 
'********************************************************************************
Public Sub  EchoAllModules
	Dim mods, mod1

	echo  "Resolving Depends ..."
	Me.ResolveDepends

	mods = Me.AllModules.Keys
	For Each mod1 in mods
		echo mod1
	Next
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::EchoUsedModules] >>> 
'********************************************************************************
Public Sub  EchoUsedModules
	Dim  mod1

	echo  "Resolving Depends ..."
	Me.ResolveDepends

	For Each mod1 in Me.AllModules.Items  ' as Mxp_Module
		If mod1.Used Then  echo mod1.Name
	Next
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::EchoAllSymbols] >>> 
'********************************************************************************
Public Sub  EchoAllSymbols
	Dim  sym

	echo  "Resolving Depends ..."
	Me.ResolveDepends

	For Each sym in Me.AllSymbols.Keys  ' as Mxp_Symbol
		echo sym
	Next
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::EchoUsedSymbols] >>> 
'********************************************************************************
Public Sub  EchoUsedSymbols
	Dim syms, sym

	echo  "Resolving Depends ..."
	Me.ResolveDepends

	syms = Me.AllSymbols.Items
	For Each sym in syms
	 If sym.Used Then  echo sym.Name
	Next
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::GetRepFile_fromSymbol] >>> 
'********************************************************************************
Public Function  GetRepFile_fromSymbol( FileSymbol )
	Dim  mod_

	For Each mod_ In Me.AllModules.Items
		If mod_.RepFiles.Exists( FileSymbol ) Then _
			Set GetRepFile_fromSymbol = mod_.RepFiles.Item( FileSymbol ) : Exit Function
	Next
	Set GetRepFile_fromSymbol = Nothing
End Function


 
'********************************************************************************
'  <<< [Mxp_Proj::GetFileType_fromName] >>> 
'********************************************************************************
Public Function  GetFileType_fromName( FileTypeName )
	If Me.DebugMode and Me.F_BreakAtAddFileType Then  Stop
	Set  GetFileType_fromName = get_Object( FileTypeName )
End Function


 
'********************************************************************************
'  <<< [Mxp_Proj::GetWorkFilesFromTypeName] >>> 
'********************************************************************************
Public Function  GetWorkFilesFromTypeName( FileTypeName )
	Dim  file_type_name,  work_file,  file_count
	GetWorkFilesFromTypeName = Array( )

	'// file_type as Mxp_FileType
	For Each  file_type_name  In Me.FileTypes.Keys
		If file_type_name = FileTypeName Then  Exit For
	Next
	If IsEmpty( file_type_name ) Then  Exit Function

	'// work_file as Mxp_WorkFile
	file_count = 0 : ReDim  ret( Me.WorkFiles.Count - 1 )
	For Each  work_file  In Me.WorkFiles.Items
		If work_file.FileTypeName = file_type_name Then
			Set ret( file_count ) = work_file
			file_count = file_count + 1
		End If
	Next
	ReDim Preserve  ret( file_count - 1 )

	GetWorkFilesFromTypeName = ret
End Function


 
'********************************************************************************
'  <<< [Mxp_Proj::GetProjectFolderStepPath] >>> 
'********************************************************************************
Public Function  GetProjectFolderStepPath()
	Assert  not IsEmpty( Me.TransformVariables( "OutputPath" ) )
	output_folder = g_fs.GetParentFolderName( Me.TransformVariables( "OutputPath" ) )
	GetProjectFolderStepPath = GetStepPath( Me.ProjectFolderAbsPath, output_folder )
End Function


 
'********************************************************************************
'  <<< [Mxp_Proj::OutSectionsXML] >>> 
'********************************************************************************
Public Sub  OutSectionsXML()
	Dim  f, work, sym, sect, mod_, b_out, rep_file

	Set f = g_fs.CreateTextFile( "sections.xml", True, False )
	f.WriteLine  "<ModuleMixer3_Sections>"
	f.WriteLine  vbTab+"<UsedSections>"
	For Each mod_  In Me.AllModules.Items
		b_out = True
		For Each sym  In mod_.Symbols
			If sym.Used Then
				If b_out Then  f.WriteLine  vbTab+vbTab+"<"+mod_.Name+">" : b_out = False
				f.WriteLine  vbTab+vbTab+vbTab+"<" + sym.Name + ">"
				For Each sect  In sym.UsesSections
					f.WriteLine  vbTab+vbTab+vbTab+vbTab+ _
						"<Section file_id="""+sect.RepFile.Symbol+""" key="""+sect.Key+""" />"
				Next
				f.WriteLine  vbTab+vbTab+vbTab+"</" + sym.Name + ">"
			End If
		Next
		If not b_out Then  f.WriteLine  vbTab+vbTab+"</"+mod_.Name+">"
	Next
	f.WriteLine  vbTab+"</UsedSections>"
	f.WriteLine  vbTab+"<Files>"
	For Each mod_  In Me.AllModules.Items
		For Each rep_file  In mod_.RepFiles.Items
			If UBound( rep_file.UsesKeys ) >= 0 Then
				For Each work  In Me.WorkFiles.Items
					If rep_file.FileTypeName = work.FileTypeName  Then
						f.WriteLine  vbTab+vbTab+"<File id="""+rep_file.Symbol+""" repository="""+_
							rep_file.Path +""" "+ "work="""+work.Path+""" />"
					End If
				Next
			End If
		Next
	Next
	f.WriteLine  vbTab+"</Files>"
	f.WriteLine  "</ModuleMixer3_Sections>"

End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::First_AutoBuild] >>> 
'********************************************************************************
Public Function  First_AutoBuild()
	Dim  work
	First_AutoBuild = False

	'//=== Check all work files
	For Each work in  Me.WorkFiles.Items
		If g_fs.FileExists( work.Path ) Then  Exit Function
	Next

	Me.MakeProj2
	First_AutoBuild = True
End Function


 
'********************************************************************************
'  <<< [Mxp_Proj::MakeProj2] >>> 
'********************************************************************************
Public Sub  MakeProj2()
	Dim  folder, gen_fnames(), step_path,  is_remake,  sorted_modules,  make_proj_context
	Dim  now_path,  gen_path,  old_path,  key


	'//=== proj_type as Mxp_ProjType
	Dim  proj_type : Set proj_type = get_Object( Me.ProjTypeName(0) )

	'//=== ResolveDepends
	Me.ResolveDepends

	'//=== sorted_modules as array of Mxp_Module
	QuickSort_fromDic  Me.AllModules, sorted_modules, GetRef("Mxp_SortCmp_byModule"), Empty

	Do
		is_remake = False

		Me.MakeProj2Sub  proj_type, sorted_modules, make_proj_context, True
			'//[out] make_proj_context as Mxp_MakeProjContext


		'//=== ファイルの有無や、ファイルの内容に違いがあるかどうかによって、ファイルをコピーする
		ExpandWildcard  GetAbsPath( "*", make_proj_context.GeneratingFolderAbsPath ), F_File or F_SubFolder, folder, gen_fnames
		Dim  is_show_status : is_show_status = False
		For Each step_path  In gen_fnames
			now_path = GetAbsPath( Replace( step_path, Me.ParentFolderProxyName, ".." ), make_proj_context.ProjectFolderAbsPath )

			If make_proj_context.MakingFilesOverwriteAction.Item( step_path ) = _
				 make_proj_context.c.RecommendOverwriteCopy Then  '// see the document of RecommendOverwriteCopy

				gen_path = GetAbsPath( step_path, make_proj_context.GeneratingFolderAbsPath )
				old_path = GetAbsPath( step_path, make_proj_context.GeneratedFolderAbsPath )

				If g_fs.FileExists( now_path ) Then
					If g_fs.FileExists( old_path ) Then
						If ReadFile( now_path ) = ReadFile( old_path ) Then
							If ReadFile( gen_path ) = ReadFile( now_path ) Then
							Else
								copy_ren  gen_path,  now_path
								copy_ren  gen_path,  old_path
							End If
						Else
							If ReadFile( gen_path ) = ReadFile( now_path ) Then
								copy_ren  now_path,  old_path
							Else
								If not Me.IsDontOverwriteFile( step_path ) Then _
									is_show_status = True
							End If
						End If
					Else
						If ReadFile( gen_path ) = ReadFile( now_path ) Then
							copy_ren  now_path,  old_path
						Else
							If not Me.IsDontOverwriteFile( step_path ) Then _
								is_show_status = True
						End If
					End If
				Else
					If g_fs.FileExists( old_path ) Then
						If ReadFile( gen_path ) = ReadFile( old_path ) Then
							move_ren  gen_path,  now_path
						Else
							If not Me.IsDontOverwriteFile( step_path ) Then _
								is_show_status = True
						End If
					Else
						move_ren  gen_path,  now_path
						copy_ren  now_path,  old_path
					End If
				End If
			Else  '// see the document of MakeProjContext.c.DontOverwrite
				gen_path = GetAbsPath( step_path, make_proj_context.GeneratingFolderAbsPath )
				old_path = GetAbsPath( step_path, make_proj_context.GeneratedFolderAbsPath )
				copy_ren  gen_path,  old_path

				If not g_fs.FileExists( now_path ) Then
					copy_ren  old_path,  now_path
				End If
			End If
		Next


		'//=== 自動生成したファイルと既存のファイルを比較します
		If is_show_status Then
			Dim  root
			Dim  menu : Set menu = new SyncFilesMenu
			menu.IsCompareTimeStamp = False
			menu.Lead = "自動生成したファイル(gen=_setup_generating フォルダー)と"+_
			            "既存のファイル(now=プロジェクト・フォルダー)と"+_
			            "前回生成時(old=_setup_generated フォルダー)を比較します"

			Set root = menu.AddRootFolder( 0, make_proj_context.ProjectFolderAbsPath )  '// as SyncFilesRoot
			root.Label = "now"
			Set root = menu.AddRootFolder( 1, make_proj_context.GeneratingFolderAbsPath )
			menu.SetParentFolderProxyName  1, "__parent"
			root.Label = "gen"
			Set root = menu.AddRootFolder( 2, GetAbsPath( "_setup_generated", Me.ProjectFolderAbsPath ) )
			menu.SetParentFolderProxyName  2, "__parent"
			root.Label = "old"

			For Each step_path  In gen_fnames
				If not Me.IsDontOverwriteFile( step_path ) Then
					menu.AddFile  Replace( step_path, Me.ParentFolderProxyName, ".." )
				End If
			Next
			menu.Compare
			echo_line
			menu.OpenSyncMenu

			menu.Compare
			If not menu.IsSameFolder( 0, 1 ) Then
				echo  "自動生成したファイル(gen)と既存のファイル(now)に、まだ違いがあります。"
				key = input( "もう一度、自動生成しますか。[Y=自動生成する / N=中断する]" )
				If key<>"y" and key<>"Y" Then   Exit Sub  ' ... Cancel
				is_remake = True
			End If
		End If

		If not is_remake Then  Exit Do
	Loop


	'//=== SyncFilesMenu で修正した内容を、old へコピーする
	For Each step_path  In gen_fnames
		If make_proj_context.MakingFilesOverwriteAction.Item( step_path ) = _
			 make_proj_context.c.RecommendOverwriteCopy Then

			old_path = GetAbsPath( step_path, make_proj_context.GeneratedFolderAbsPath )
			If not g_fs.FileExists( old_path ) Then
				now_path = GetAbsPath( step_path, make_proj_context.ProjectFolderAbsPath )
				copy_ren  now_path,  old_path
			End If
		End If
	Next


	'//=== gen フォルダーを削除する
	del  make_proj_context.GeneratingFolderAbsPath
End Sub


'//[Mxp_Proj::MakeProj2Sub]
Public Sub  MakeProj2Sub( proj_type, sorted_modules, make_proj_context, IsDeleteGeneratingWorkFolder )
	Dim  o,  rev_sorted_modules

	'//=== load_proj_context = new Mxp_LoadProjContext class
	Dim  load_proj_context : Set load_proj_context = new Mxp_LoadProjContext
	Set o = load_proj_context
		o.ProjectName = Me.ProjectName(0)
		Set o.OldProjParams = CreateObject( "Scripting.Dictionary" )
		    o.OldProjParams.CompareMode = NotCaseSensitive
		o.ProjectFolderAbsPath = Me.ProjectFolderAbsPath
	o = Empty

	'//=== load_proj_context.OldProjParams = get current project
	proj_type.LoadProj2  load_proj_context  '//[in/out] load_proj_context


	'//=== rev_sorted_modules
	ReverseObjectArray  sorted_modules, rev_sorted_modules  '//[out] rev_sorted_modules


	'//=== make_proj_context = new Mxp_MakeProjContext class
	Set make_proj_context = new Mxp_MakeProjContext
	Set o = make_proj_context
		o.ProjectName = Me.ProjectName(0)
		o.ProjectFolderAbsPath = Me.ProjectFolderAbsPath
		o.GeneratingFolderAbsPath = GetAbsPath( "_setup_generating", Me.ProjectFolderAbsPath )
		o.GeneratedFolderAbsPath  = GetAbsPath( "_setup_generated",  Me.ProjectFolderAbsPath )
		o.TemporaryXmlAbsPath = Empty
		o.SortedModules = sorted_modules
		o.ReverseSortedModules = rev_sorted_modules
		Set o.OldProjParams = load_proj_context.OldProjParams  '// a_GUID, ...
		Set o.UseFolderPaths = Me.UseFolderPaths
		o.SetPrivateMxpProj  Me
		o.IsDeleteGeneratingWorkFolder = IsDeleteGeneratingWorkFolder
	o = Empty


	'//=== create a file of o.TemporaryXmlAbsPath
	make_proj_context.TemporaryXmlAbsPath = GetTempPath( "Mixer_TemporaryXml_*.txt" )
	Dim  cs : Set cs = new_TextFileCharSetStack( "UTF-16" )
	Set ec = new EchoOff
	CreateFile  make_proj_context.TemporaryXmlAbsPath, _
		"<?xml version=""1.0"" encoding=""UTF-16""?>"+vbCRLF+_
		"<XML>"+vbCRLF+"</XML>"+vbCRLF
	ec = Empty
	cs = Empty


	'//=== make project in make_proj_context::GeneratingFolderAbsPath folder
	Assert  UBound( Me.ProjTypeName ) = 0
	Set ec = new EchoOff
	del  make_proj_context.GeneratingFolderAbsPath
	ec = Empty
	proj_type.MakeProj2  make_proj_context


	'//=== delete a file of o.TemporaryXmlAbsPath
	Set ec = new EchoOff
	del  make_proj_context.TemporaryXmlAbsPath
	ec = Empty
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::MakeProj] >>> 
'********************************************************************************
Public Sub  MakeProj()
	Dim  work,  is_old_work_file_exist,  is_diff,  work_file_not_modify_count
	Dim  proj_type


	'// work.GenPath file : リポジトリからワークファイルを生成する
	Me.MakeWork  Empty, Empty

	Dim  ec : Set ec = new EchoOff


	'// is_old_work_file_exist : 古いワークがあるときは、生成中のファイルと比較して、異なればメニューへ
	is_old_work_file_exist = False
	For Each work in  Me.WorkFiles.Items
		If exist( work.Path ) Then  is_old_work_file_exist = True
	Next
	If is_old_work_file_exist Then

		is_diff = False
		For Each work in  Me.WorkFiles.Items
			If fc_r( work.GenPath, work.Path, Empty ) Then
				If not fc_r( work.Path, work.OrgPath, Empty ) Then _
					copy_ren  work.Path, work.OrgPath
			Else
				is_diff = True
			End If
		Next

		ec = Empty

		If is_diff Then

			'// work_file_not_modify_count : ユーザーによって修正されていないワークファイルの数
			work_file_not_modify_count = 0
			For Each work in  Me.WorkFiles.Items
				If not g_fs.FileExists( work.Path )  and  not g_fs.FileExists( work.OrgPath ) Then
						work_file_not_modify_count = work_file_not_modify_count + 1
				Else
					If fc_r( work.Path, work.OrgPath, Empty ) Then
						work_file_not_modify_count = work_file_not_modify_count + 1
					End If
				End If
			Next

			If work_file_not_modify_count = Me.WorkFiles.Count Then
				echo  "ワークとリポジトリの間に、違いがありますが、"
				echo  "ワークが変更されていないので、ワークを新しいリポジトリの内容にします。"

				For Each work in  Me.WorkFiles.Items

					'// work.Path : rename from work.GenPath
					If not fc_r( work.GenPath, work.Path, Empty ) Then
						If g_fs.FileExists( work.GenPath ) Then
							copy_ren  work.GenPath, work.Path
						Else
							del  work.Path
						End If
					End If
					del  work.GenPath

					'// work.OrgPath : copy of new work.Path
					If g_fs.FileExists( work.Path ) Then
						copy_ren  work.Path, work.OrgPath
					Else
						del  work.OrgPath
					End If
				Next
			Else
				DoMergeMenu
			End If
		Else
			echo "変更はありません。"
		End If


	'// work.Path, work.OrgPath file : 古いワークが無いときは、オリジナルも作成する
	Else
		For Each work in  Me.WorkFiles.Items
			If g_fs.FileExists( work.GenPath ) Then
				move_ren  work.GenPath, work.Path
				copy_ren  work.Path, work.OrgPath
			End If
		Next
	End If

	Me.MakeWorkStep2  Empty, Empty
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::MakeWorkFiles] >>> 
'********************************************************************************
Public Sub  MakeWorkFiles( FileTypeName, MakeProjContext, OverwriteAction )
	Dim  file_type,  work_files,  work_file,  is_break,  work_gen_path,  work_f
	Dim  is_header_in_work_file,  module,  rep_file,  o, e,  is_temporary_work,  modules
	Dim  work_gen_step_path
	Dim  section : Set section = new SectionTree

	work_files = Me.GetWorkFilesFromTypeName( FileTypeName )
	If UBound( work_files ) = -1 Then
		LetSet  file_type, Me.FileTypes.Item( FileTypeName )
		If not IsEmpty( file_type ) Then
			If file_type.IsExistOnlyMaking Then
				ReDim  work_files(0)
				Set work_files(0) = new Mxp_WorkFile : Set o = work_files(0)
					o.StepPath = "_Temporary_"+ FileTypeName +".txt"
					o.FileTypeName = FileTypeName
			Set o.FileType = file_type
				o = Empty
				is_temporary_work = True
			Else
				For Each module in  MakeProjContext.SortedModules
				 For Each rep_file in  module.RepFiles.Items
					If rep_file.FileTypeName = FileTypeName  Then
					 If ( UBound( rep_file.UsesSections ) >= 0 ) and _
					    ( rep_file.FileType.IsMustMake ) Then
						 Raise  E_Others, "<ERROR msg=""ワークファイルのパスを mxp.AddWorkFile に指定してください"""+_
							 " file_type="""+ FileTypeName +""" requested_module="""+ module.Name +"""/>"
					 End If
					End If
				 Next
				Next
			End If
		End If
	End If
	If UBound( work_files ) >= 0 Then  Set file_type = work_files(0).FileType


	If section.Start( "MakeWorkFiles_"+ FileTypeName ) Then


	For Each work_file  In work_files  '// work_file as Mxp_WorkFile
		If g_b_debug Then  echo  vbCRLF+ "WorkFile: " + work_file.StepPath

		'// work_gen_path
		work_gen_step_path = Replace( work_file.StepPath, "..", Me.ParentFolderProxyName )
		work_gen_path = GetAbsPath( work_gen_step_path, MakeProjContext.GeneratingFolderAbsPath )

		'// is_break
		is_break = False
		If Me.DebugMode and Me.F_BreakAtMakeWorkFile Then _
			If IsEmpty( Me.DebugMode_Param1 ) or InStr( work_gen_path, Me.DebugMode_Param1 ) > 0 Then _
				If IsEmpty( Me.DebugMode_Param2 ) and IsEmpty( Me.DebugMode_Param3 ) Then  Stop  Else  is_break = True

		'// work_f
		Set ec = new EchoOff
		Set work_f = OpenForWrite( work_gen_path, Empty )
		ec = Empty

		is_header_in_work_file = False

		If work_file.FileType.IsBottomToTop Then
			modules = MakeProjContext.ReverseSortedModules
		Else
			modules = MakeProjContext.SortedModules
		End If

		For Each module in  modules
		 If IsEmpty( work_file.ModuleTypeName )  or _
		   work_file.ModuleTypeName = module.ModuleTypeName Then
			If g_b_debug Then  echo  "Module: " + module.Name
			If is_break and  module.Name = Me.DebugMode_Param2  Then  Stop

			For Each rep_file in  module.RepFiles.Items
			 If rep_file.FileTypeName = work_file.FileTypeName  Then
				If TryStart(e) Then  On Error Resume Next

					If rep_file.MakeText( work_f, work_file, is_header_in_work_file, MakeProjContext ) Then _
						is_header_in_work_file = True

				If TryEnd Then  On Error GoTo 0
				If e.num <> 0 Then
					e.desc = e.desc + vbCRLF +" in "+ rep_file.path
					e.Raise
				End If
			 End If
			Next
		 End If
		Next

		If is_header_in_work_file Then
			work_file.WriteFooter  work_f
		Else  '// if not out any text
			If IsEmpty( work_file.FileType.EmptyContents ) Then
				work_f = Empty
				Set ec = new EchoOff
				del  work_gen_path
				ec = Empty
			Else
				text = work_file.FileType.EmptyContents

				For Each key  In work_file.HeadFootReplaces.Keys
					If not IsEmpty( work_file.HeadFootReplaces.Item( key ) ) Then _
						text = Replace( text, key, work_file.HeadFootReplaces.Item( key ) )
				Next
				For Each key  In work_file.FileType.HeadFootReplaces.Keys
					If not IsEmpty( work_file.FileType.HeadFootReplaces.Item( key ) ) Then _
						text = Replace( text, key, work_file.FileType.HeadFootReplaces.Item( key ) )
				Next

				work_f.WriteLine  text
			End If
		End If

		work_f = Empty

		MakeProjContext.SetMakingFilesOverwriteAction  work_gen_step_path, OverwriteAction

		'// ワークファイルに対する追加的な処理をする
		If not IsEmpty( file_type.PostProcessOfMakeProj ) Then _
			file_type.PostProcessOfMakeProj  work_file, MakeProjContext, OverwriteAction

		If is_temporary_work Then
			Set ec = new EchoOff
			del  work_gen_path
			ec = Empty
		End If
	Next

	End If : section.End_
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::DeleteWorkFiles] >>> 
'********************************************************************************
Public Sub  DeleteWorkFiles( FileTypeName, MakeProjContext )
	Dim  work_file,  work_gen_path,  work_gen_step_path

	For Each work_file  In Me.GetWorkFilesFromTypeName( FileTypeName )  '// work_file as Mxp_WorkFile
		work_gen_step_path = Replace( work_file.StepPath, "..", Me.ParentFolderProxyName )
		work_gen_path = GetAbsPath( work_file.StepPath, MakeProjContext.GeneratingFolderAbsPath )
		del  work_gen_path
	Next
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::MakeWorkFolder] >>> 
'********************************************************************************
Public Sub  MakeWorkFolder( FolderTypeName, MakeProjContext )
	For Each work_folder  In Me.WorkFolders.Items  '// work_folder as Mxp_WorkFolder
		If StrComp( work_folder.FolderTypeName, FolderTypeName, 1 ) = 0 Then  Exit For
	Next
	If IsEmpty( work_folder ) Then  Exit Sub

	generating_path = GetAbsPath( "__"+ FolderTypeName, MakeProjContext.GeneratingFolderAbsPath )
	generated_path  = GetAbsPath( "__"+ FolderTypeName, MakeProjContext.GeneratedFolderAbsPath )


	'// Make "rep_files"
	Set rep_files = CreateObject( "Scripting.Dictionary" )  '// as dictionary. Key is abs path. Item is Mxp_RepCopyFile
	rep_files.CompareMode = NotCaseSensitive
	For Each module in  Me.AllModules.Items()  ' as Mxp_Module
		For Each rep_file  In  module.RepCopyFiles.Items()  ' as Mxp_RepCopyFile
			If not IsEmpty( rep_file.UsesFile ) Then
				If rep_file.FolderTypeName = work_folder.FolderTypeName Then
					If not exist( rep_file.Path ) Then
						Raise  1, "<ERROR msg=""モジュールが使うファイルが"+_
							"見つかりません"""+vbCRLF+" NotFoundPath="""+ rep_file.Path +_
							""""+vbCRLF+" ModulePath="""+ rep_file.ParentModule.DefineInfo.FullPath +_
							""""+vbCRLF+" FolderTypeName="""+ rep_file.FolderTypeName +"""/>"
					End If
					rep_files.Add  rep_file.Path,  rep_file
				End If
			End If
		Next
	Next


	'// Copy folders to "generating_path"
	For Each rep_file  In rep_files.Items
		If g_fs.FolderExists( rep_file.Path ) Then
			copy  rep_file.Path+"\*",  GetAbsPath( rep_file.StepPathInProj, generating_path )
		End If
	Next


	'// Copy files or Make transformed files to "generating_path"
	For Each rep_file  In rep_files.Items
		If rep_file.IsTransform Then
			text = ReadFile( rep_file.Path )
			text = mxp.TransformText( text, GetAbsPath( rep_file.StepPathInProj, work_folder.Path ) )
			CreateFile  GetAbsPath( rep_file.StepPathInProj, generating_path ), text
		Else
			copy_ren  rep_file.Path,  GetAbsPath( rep_file.StepPathInProj, generating_path )
		End If
	Next


	'// Set "action"
	Set o = new CopyNotOverwriteFileClass
	o.SourcePath       = generating_path
	o.DestinationPath  = work_folder.Path
	o.SynchronizedPath = generated_path
	o.Copy

	If MakeProjContext.IsDeleteGeneratingWorkFolder Then _
		del  generating_path
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::MakeWorkStep2] >>> 
'********************************************************************************
Public Sub  MakeWorkStep2( OutPath, a_GUID )
	Dim  work, module, rep_file, proj_type, path, b

	'//=== UsesFile で追加されたファイルをコピーする
	For Each work in  Me.WorkFolders.Items  ' as Mxp_WorkFolder
		For Each module in  Me.AllModules.Items()  ' as Mxp_Module
			For Each rep_file in  module.RepCopyFiles.Items()  ' as Mxp_RepCopyFile
				If not IsEmpty( rep_file.UsesFile ) Then
					If rep_file.FolderTypeName = work.FolderTypeName Then
						path = GetAbsPath( rep_file.StepPathInProj, work.Path )
						b= (  not exist( path )  )
						If not b  and  g_fs.FileExists( path ) Then  '// C-language's ||
							b= (  g_fs.GetFile( rep_file.Path ).DateLastModified <> g_fs.GetFile( path ).DateLastModified  )  '// C-language's &&
						End If
						If b Then  copy_ren  rep_file.Path, path
					End If
				End If
			Next
		Next
	Next

	'//=== ワークファイルの種類ごとに追加される処理をする
	For Each work in  Me.WorkFiles.Items  ' as Mxp_WorkFile
		If not IsEmpty( work.FileType.PostProcessOfMakeProj ) Then
			If IsEmpty( OutPath ) Then
				work.FileType.PostProcessOfMakeProj  work, Empty
			Else
				path = work.Path : work.Path = OutPath +"\"+ g_fs.GetFileName( work.Path )
				work.FileType.PostProcessOfMakeProj  work, Empty
				work.Path = path
			End If
		End If
	Next

	'//=== プロジェクトファイルを作成する
	Dim  param : Set param = new Mxp_MakeProjParam
	If IsEmpty( OutPath ) Then  path = g_sh.CurrentDirectory  Else  path = OutPath
	For i=0 To UBound( Me.ProjTypeName )
		Set proj_type = get_Object( Me.ProjTypeName(i) )
		If Me.DebugMode and Me.F_BreakAtMakeProj Then  Stop

		param.ProjectName = Me.ProjectName(i)
		param.OutFolderPath = path
		param.OutFolderBasePathForStepPath = g_sh.CurrentDirectory
		param.GUID = a_GUID
		Set param.UseFolderPaths = Me.UseFolderPaths
		proj_type.MakeProj  param
	Next
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::CheckAllOut] >>> 
'********************************************************************************
Public Sub  CheckAllOut( MakeProjContext )
	Dim  root,  node,  snippet_targets,  keys

	Set root = LoadXML( MakeProjContext.TemporaryXmlAbsPath, Empty )

	Set snippet_targets = CreateObject( "Scripting.Dictionary" )
	    snippet_targets.CompareMode = NotCaseSensitive
	For Each node  In root.selectNodes( "./Snippet" )
		snippet_targets.Item( node.getAttribute( "target" ) ) = True
	Next

	For Each node  In root.selectNodes( "./SnippetResult" )
		If snippet_targets.Exists( node.getAttribute( "target" ) ) Then _
			snippet_targets.Remove  node.getAttribute( "target" )
	Next

	root = Empty

	keys = DicKeyToCSV( snippet_targets )
	If keys <> "" Then
		Raise  E_NotFoundSymbol, _
			"<ERROR msg=""SnippetTarget タグが無いか、モジュール_module.vbs で UsesSectionSnippetTarget が呼ばれていません"" target="""+_
			keys + """ snippet="""+ MakeProjContext.TemporaryXmlAbsPath +""" hint=""Doc:4201""/>"
	End If

End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::DoMergeMenu] >>> 
'********************************************************************************
Public Sub  DoMergeMenu()
	Dim  in_data, work, b, ec

	echo "--------------------------------------------------------"

	Do
		'//=== 生成中の一部が無いときはエラー、全部無いときはメニューから抜ける
''    b = 0
''    For Each work in  Me.WorkFiles.Items
''      If not g_fs.FileExists( work.GenPath ) Then  b=b+1
''    Next
''    If b = Me.WorkFiles.Count Then
''      Exit Do
''    ElseIf b > 0 Then
''      For Each work in  Me.WorkFiles.Items
''        If not g_fs.FileExists( work.GenPath ) Then _
''          echo  "<ERROR msg=""生成中(*_gen)が一部存在しません。"" path="""+ work.GenPath +"""/>"
'' 再利用するコードが無いときは、ファイルが無いため、このチェックはしないようにした
''      Next
''      pause
''    End If

		'//=== ワークとリポジトリの間に違いがあるかどうかを表示する
		Set ec = new EchoOff
		b = False : i = 1
		For Each work in  Me.WorkFiles.Items
			If not g_fs.FileExists( work.GenPath )  and  not g_fs.FileExists( work.Path ) Then
			Else
				If not fc_r( work.GenPath, work.Path, Empty ) Then
					b = True
				End If
			End If
			i=i+1
		Next
		ec = Empty
		If b Then
			echo  "ワークとリポジトリの間に、違いがあります。"
		Else
			echo  "ワークとリポジトリの間に、違いはありません。"
		End If

		'//=== メニューを表示する
		echo "--------------------------------------------------------"
		echo "1. diff ツールで比較する"
		echo "2. 生成中（リポジトリ）の内容に、ワークを更新して、終了する"
		echo "3. 生成中（リポジトリ）の内容を最新に更新する"
		echo "4. Open"
		If ArgumentExist( "SyncSendFile" ) Then  echo "80. CallViaFile"
		echo "9. 終了"
		in_data = CInt2( input( "番号を選んでください >" ) )
		echo "--------------------------------------------------------"

		Select Case in_data
			Case 1:  Me.StartDiffTool
			Case 2:  Me.UpdateWorkUI
			Case 3:  Me.UpdateGen
			Case 4:  Me.OpenMenu
			Case 80: CallViaFile  Empty
			Case 9:  Exit Do
		End Select
	Loop


	'//=== ワークと生成中が同じなら、オリジナルも同じにする。
	For Each work in  Me.WorkFiles.Items
		Set ec = new EchoOff
		If fc_r( work.GenPath, work.Path, Empty ) Then
			If not fc_r( work.Path, work.OrgPath, Empty ) Then
			 ec = Empty
			 copy_ren  work.Path, work.OrgPath
			End If
		End If
	Next
	ec = Empty


	'//=== 生成中ファイルを削除する
	For Each work in  Me.WorkFiles.Items
		del  work.GenPath
	Next
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::StartDiffTool] >>> 
'********************************************************************************
Public Sub  StartDiffTool()
	Dim  work, i, b, ec, s
	ReDim  work_files_array( Me.WorkFiles.Count - 1 )

	i = 0
	For Each work in  Me.WorkFiles.Items
		Set work_files_array( i ) = work
		i=i+1
	Next

	Do
		'//=== ワークとリポジトリの間に違いがあるかどうかを一覧表示する
		b = False : i = 1
		For Each work in  Me.WorkFiles.Items
			Set ec = new EchoOff
			s = i & ". " & g_fs.GetFileName( work.Path ) + " : "
			If fc_r( work.GenPath, work.Path, Empty ) Then
				s = s + "同じ"
			Else
				s = s + "異なる"
				b = True
			End If
			ec = Empty
			echo  s
			i=i+1
		Next
		echo "--------------------------------------------------------"

		echo "Enter のみのとき：戻る"
		i = CInt2( input( "ファイルの番号を選んでください >" ) )

		echo "--------------------------------------------------------"

		If i < 0  or  i > Me.WorkFiles.Count Then
			echo  "1 ～ " & ( Me.WorkFiles.Count ) & " の間を入力してください。"
		ElseIf i = 0 Then
			Exit Do
		Else

			'//=== Diff ツールを開く
			Set work = work_files_array(i-1)
			echo "左: ワーク = コンパイルするファイル"
			echo "中: オリジナル(*_org) = リポジトリから前回生成したワークのコピー"
			echo "右: 生成中(*_gen) = 現在のリポジトリから生成できる一時的なもの"
			start  GetDiffCmdLine3( work.Path, work.OrgPath, work.GenPath )

			Exit Do
		End If
	Loop

	echo "--------------------------------------------------------"
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::UpdateWorkUI] >>> 
'********************************************************************************
Public Sub  UpdateWorkUI()
	Dim  work

	echo  "ワーク・ファイルを更新します。"
	For Each work in  Me.WorkFiles.Items
		echo  "  " + GetStepPath( work.Path, Empty )
	Next
	echo  "ワークとリポジトリの間の違いを確認しましたか？"
	echo  "必要ならバックアップをとってください。"
	Dim key : key = input( "更新してよろしいですか？ [Y/N]" )
	If key="y" or key="Y" Then
		Me.UpdateWork
	End If
	echo "--------------------------------------------------------"
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::UpdateWork] >>> 
'********************************************************************************
Public Sub  UpdateWork()
	Dim  work

	For Each work in  Me.WorkFiles.Items
		If g_fs.FileExists( work.GenPath ) Then
			copy_ren  work.GenPath, work.Path
			copy_ren  work.GenPath, work.OrgPath
			del   work.GenPath
		Else
			del  work.Path
			del  work.OrgPath
		End If
	Next
	echo "--------------------------------------------------------"
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::UpdateGen] >>> 
'********************************************************************************
Public Sub  UpdateGen()
	Me.MakeWork  Empty, Empty
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::OutDiff] >>> 
'********************************************************************************
Public Sub  OutDiff( ByVal OutFolderPath )
	Dim  work_f, work, work_sect, work_linenum
	Dim  work_sects : Set work_sects = CreateObject("Scripting.Dictionary")
	                      work_sects.CompareMode = NotCaseSensitive
		' key = Mxp_LinkToSection::Key, Item=Mxp_SectionText
	Dim  rep_file ' as Mxp_RepFile
	Dim  rep_files : Set rep_files = CreateObject("Scripting.Dictionary")
	                     rep_files.CompareMode = NotCaseSensitive
		' key = Path, Item=Empty
	Dim  key, sym, use_sec
	Dim  params : Set params = new Mxp_OutDiff_Param
	Dim  nWarn : nWarn = 0

	If Right( OutFolderPath, 1 ) = "\" Then _
		OutFolderPath = Left( OutFolderPath, Len( OutFolderPath ) - 1 )


	'//=== Delete out folder
	If exist(OutFolderPath) Then
		key = input( "古い差分が格納されている " + g_fs.GetFileName(OutFolderPath) +_
								 " フォルダを削除します。[Y/N]" )
		If key<>"y" and key<>"Y" Then  echo "キャンセルしました。" : Exit Sub
		del  OutFolderPath
		echo "古い "+OutFolderPath+" フォルダを削除しました。"
	End If


	echo  "Resolving Depends ..."
	Me.ResolveDepends


	'//=== Set parameters
	params.OutFolderPath = g_fs.GetAbsolutePathName(OutFolderPath)
	params.DiffID = 0
	Set params.Repositories = Me.AllRepositories


	'//=== Set rep_files
	For Each sym In Me.AllSymbols.Items()
		If sym.m_Uses Then
			For Each use_sec In sym.UsesSections
				key = rep_files.Item( use_sec.RepFile.Path )  '// Add to rep_files if not exists. key is dummy.
			Next
		End If
	Next


	'//=== Check Priority
'  Redim  sorted_mods(-1)
'  QuickSort_fromDic  Me.AllModules, sorted_mods, GetRef("Mxp_SortCmp_byModule"), Empty


	'//=== Compare files
	For Each work in  Me.WorkFiles.Items

		echo "======[Work:" + work.Path + "]=============================="

		Set work_f = g_fs.OpenTextFile( work.Path )
		work_linenum = 1
		params.WorkPath = g_fs.GetAbsolutePathName(work.Path)
		Set params.FileType = work.FileType

		Do

'//=== for Debug
'echo ">" & work.Path & "(" & work_linenum & ")"
'If g_fs.GetFileName( work.Path ) = "clib.c" And work_linenum = 22  Then Stop

			'//=== Read a sections from WorkFile to work_sects
			Set work_sect = new Mxp_SectionText
			If not work_sect.ReadSection( work_f, work_linenum, work.FileType, rep_file ) Then  Exit Do
			If not IsEmpty( rep_file ) Then
				If not IsEmpty( work_sect.key ) Then
					work_sects.Add  work_sect.key, work_sect
				ElseIf work_sect.Status <> Sect_FileSeparator Then
					nWarn = nWarn + 1
					echo "[Warning]("&nWarn&") not found section's key in " & work.Path & "(" & work_sect.linenum & ")"
				End If
			End If


			'//=== Compare a previous file and Go to next file, if file separator read.
			If work_sect.Status = Sect_FileSeparator Then
				If not IsEmpty( rep_file ) Then
					rep_file.OutDiff  work_sects, params, nWarn  '// Mxp_RepFile::OutDiff
				End If
				work_sects.RemoveAll

				Set rep_file = Me.GetRepFile_fromSymbol( work_sect.FileSymbol )
				If rep_file is Nothing Then
					Raise 1, work.Path + " の中のファイル区切りセクションに書かれている " +_
						"ソースファイル識別子 """ + work_sect.FileSymbol + """ が、" +_
						"リポジトリに見つかりません。"
				End If

				echo  "Check to : " + rep_file.Path

				If rep_files.Exists( rep_file.Path ) Then  rep_files.Remove  rep_file.Path
			End If

		Loop

		'//=== Compare a file
		If not IsEmpty( rep_file ) Then
			rep_file.OutDiff  work_sects, params, nWarn  '// Mxp_RepFile::OutDiff
		End If
		work_sects.RemoveAll
		rep_file = Empty
	Next


	'//=== Warn not referenced repository files
	For Each rep_file In rep_files.Keys()
		nWarn = nWarn + 1
		echo "[Warning]("&nWarn&") not found in work files. Check file separator section : " & rep_file
	Next


	If not exist( OutFolderPath ) Then
		Err.raise 1,,"違いはありませんでした。(warning count = " & nWarn & ")"
	End If
	echo  "違いを "+OutFolderPath+" フォルダに出力しました"
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::UpdateSection] >>> 
' Direction as RepToWork or WorkToRep
'********************************************************************************
Public Sub  UpdateSection( Direction, FileSymbol, SectionKey )
	Dim  rep_file, rep_f
	Dim  work_file, work_f
	Dim  tmp_f
	Dim  sect, linenum, t, b, e
	Const  tmp_name = "tmp.txt"

	Me.ResolveDepends

	Set rep_file = Me.GetRepFile_fromSymbol( FileSymbol ) 'as Mxp_RepFile
	Set rep_f = OpenTextFile( rep_file.Path )

	Set work_file = rep_file.FileType.FirstWorkFile
	Set work_f = OpenTextFile( work_file.Path )

	Set tmp_f = g_fs.CreateTextFile( tmp_name, True, False )

	Set sect = new Mxp_SectionText


	'//=== Copy the section in work to repository
	If Direction = WorkToRep Then


		'//=== Copy repository sections to tmp.txt until SectionKey
		Do
			b= sect.ReadSection( rep_f, linenum, rep_file.FileType, Empty ) : If not b Then  Err.raise 1
			sect.Key = rep_file.GetMatchedKey( sect.Lines )
			If sect.Key = SectionKey Then  Exit Do
			tmp_f.Write  sect.GetLines()
		Loop


		'//=== Copy one work section to tmp.txt
		work_file.SkipToFileSeparator  work_f, FileSymbol
		Do
			b= sect.ReadSection( work_f, linenum, rep_file.FileType, Empty ) : If not b Then  Err.raise 1
			sect.Key = rep_file.GetMatchedKey( sect.Lines )
			If sect.Key = SectionKey Then  Exit Do
		Loop
		tmp_f.Write  sect.GetLines()


		'//=== Copy repository sections to tmp.txt
		tmp_f.Write  ReadAll( rep_f )


		'//=== Update repository file
		rep_f.Close
		work_f.Close
		tmp_f.Close
		SafeFileUpdate  tmp_name, rep_file.Path


	'//=== Copy the section in repository to work
	Else


		'//=== Copy work sections to tmp.txt until SectionKey
		tmp_f.Write  work_file.ReadToFileSeparator( work_f, FileSymbol )
		Do
			b= sect.ReadSection( work_f, linenum, rep_file.FileType, Empty ) : If not b Then  Err.raise 1
			sect.Key = rep_file.GetMatchedKey( sect.Lines )
			If sect.Key = SectionKey Then  Exit Do
			tmp_f.Write  sect.GetLines()
		Loop


		'//=== Copy one repository section to tmp.txt
		Do
			b= sect.ReadSection( rep_f, linenum, rep_file.FileType, Empty ) : If not b Then  Err.raise 1
			sect.Key = rep_file.GetMatchedKey( sect.Lines )
			If sect.Key = SectionKey Then  Exit Do
		Loop
		tmp_f.Write  sect.GetLines()


		'//=== Copy work sections to tmp.txt
		tmp_f.Write  ReadAll( work_f )


		'//=== Update work file
		rep_f.Close
		work_f.Close
		tmp_f.Close
		SafeFileUpdate  tmp_name, work_file.Path

	End If

End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::TransformText] >>> 
'********************************************************************************
Public Function  TransformText( Text, OutputPath )
	Dim  head_pos,  tail_pos,  xml,  root,  select_value,  e,  evaled_text

	Me.TransformVariables( "OutputPath" ) = OutputPath
	head_pos = 1
	TransformText = Text
	Do
		head_pos = InStr( head_pos, TransformText, "<mixer:value-of" )
		If head_pos = 0 Then Exit Function
		tail_pos = InStr( head_pos, TransformText, "/>" )
		xml = Mid( TransformText,  head_pos,  tail_pos - head_pos )
		xml = xml + " xmlns:mixer=""http://www.sage-p.com/name_space/mixer/""/>"

		Set root = LoadXML( xml, F_Str )
		select_value = root.getAttribute( "select" )
		If TryStart(e) Then  On Error Resume Next

			evaled_text = Eval( select_value )

		If TryEnd Then  On Error GoTo 0
		If e.num <> 0 Then
			e.desc = "<ERROR msg=""mixer:value-of タグの解析中にエラー"" desc="""+_
				e.desc +""" VBScript="""+ select_value +""" hint=""Doc:3192""/>"
			e.Raise
		End If

		TransformText = Left( TransformText, head_pos - 1 ) + evaled_text +_
			Mid( TransformText,  tail_pos + 2 )
		head_pos = Len( evaled_text )
	Loop
	Me.TransformVariables.Remove  "OutputPath"
End Function


 
'********************************************************************************
'  <<< [Mxp_Proj::Reload] >>> 
'********************************************************************************
Public Sub  Reload()
	g_sh.Run  "wscript """ + WScript.ScriptFullName + """"
	WScript.Quit  9
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::Clean2] >>> 
'********************************************************************************
Public Sub  Clean2()
	Me.Clean2Sub  False, True
End Sub

Public Sub  DeepClean2()
	Me.Clean2Sub  True, True
End Sub

Public Function  Clean2Sub( IsDeepClean, IsDeleteGenerating )
	Dim  o, sorted_modules,  make_proj_context

	If Me.DebugMode and Me.F_BreakAtMakeProj Then  Stop

	'// proj_type as Mxp_ProjType
	Dim  proj_type : Set proj_type = get_Object( Me.ProjTypeName(0) )

	Dim  clean_proj_context : Set clean_proj_context = new Mxp_CleanProjContext
	Set o = clean_proj_context
		o.ProjectName = Me.ProjectName(0)
		o.ProjectFolderAbsPath = Me.ProjectFolderAbsPath
		o.GeneratingFolderAbsPath = GetAbsPath( "_setup_generating", Me.ProjectFolderAbsPath )
		o.IsDeepClean = IsDeepClean
		o.IsDeleteGenerating = IsDeleteGenerating
		o.SetPrivate  Me,  proj_type
	o = Empty
	proj_type.CleanProj2  clean_proj_context

	Set Clean2Sub = clean_proj_context
End Function


 
'********************************************************************************
'  <<< [Mxp_Proj::Clean] >>> 
'********************************************************************************
Public Sub  Clean()
	Dim  proj_type, work, b
	Dim  clean_params : Set clean_params = new Mxp_CleanProjParam

	'//=== リポジトリと同期を取る
	Me.MakeWork  Empty, Empty

	b = False
	For Each work in  Me.WorkFiles.Items
		If exist( work.Path ) and not fc( work.Path, work.GenPath ) Then _
			b = True : Exit For
	Next
	If b Then  '// If work file is not same as generating file, ...
		Raise  1,"ワークとリポジトリの内容が異なります。/MakeProj をして差分を確認してください。"
	End If
		o.IsDeepClean = IsDeepClean

	del  "_setup_sync"


	'//=== 中間ファイルを削除する
	With clean_params
		.OutFolderPath = g_sh.CurrentDirectory
		.GenFolderPath = Empty
	End With
	For i=0 To UBound( Me.ProjTypeName )
		clean_params.ProjectName = Me.ProjectName(i)
		Set proj_type = get_Object( Me.ProjTypeName(i) )
		If Me.DebugMode and Me.F_BreakAtMakeProj Then  Stop
		proj_type.Clean  clean_params
	Next

End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::DeepClean] >>> 
'********************************************************************************
Public Sub  DeepClean()
	Dim  i, b, proj_type, root, guid, work
	Dim  clean_params : Set clean_params = new Mxp_CleanProjParam

	For i=0 To UBound( Me.ProjTypeName )

		Me.MakeWork       "_setup_sync\clean_gen", "%guid%"
		Me.MakeWorkStep2  "_setup_sync\clean_gen", "%guid%"


		'//=== 生成されるワークファイルが、現在のワークファイルと同じかどうかチェックする
		b = False
		For Each work in  Me.WorkFiles.Items
			If exist( work.Path ) and not fc( work.Path, "_setup_sync\clean_gen\" + g_fs.GetFileName( work.Path ) ) Then _
				b = True : Exit For
		Next
		If b Then  '// If work file is not same as generating file, ...
			Raise  1,"ワークとリポジトリの内容が異なります。/MakeProj をして差分を確認してください。"
		End If


		'//=== プロジェクト・タイプが生成するファイルを削除する
		With clean_params
			.ProjectName = Me.ProjectName(i)
			.OutFolderPath = g_sh.CurrentDirectory
			.GenFolderPath = "_setup_sync\clean_gen"
		End With
		Set proj_type = get_Object( Me.ProjTypeName(i) )
		If Me.DebugMode and Me.F_BreakAtMakeProj Then  Stop
		proj_type.Clean  clean_params


		'//=== リポジトリから生成されるワークファイルを削除する
		For Each work in  Me.WorkFiles.Items
			del  work.Path
		Next
	Next

	'//=== 一時的に生成したファイルを削除する
	del  "_setup_sync"
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::RemakeProj2] >>> 
'********************************************************************************
Public Sub  RemakeProj2()
	Dim  clean_proj_context,  gen_file_path,  work_path,  folder, fnames(), fname

	'// DeepClean
	Set clean_proj_context = Me.Clean2Sub( True, False )  '// as Mxp_CleanProjContext

	'// AddDontOverwriteFiles のファイル以外が残っていたらエラーにする
	ExpandWildcard  clean_proj_context.GeneratingFolderAbsPath +"\*", F_File or F_SubFolder, folder, fnames
	For Each fname  In fnames
		'// gen_file_path = GetAbsPath( fname, folder )
		work_path = GetAbsPath( fname, Me.ProjectFolderAbsPath )
		If exist( work_path ) Then
			If not Me.IsDontOverwriteFile( fname ) Then
				Raise  1, "<ERROR msg=""生成されるファイルと内容が異なります"" path="""+_
					fname +"""/>"
			End If
		End If
	Next

	del  clean_proj_context.GeneratingFolderAbsPath


	'// MakeProj
	Me.MakeProj2
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::RemakeProj] >>> 
'********************************************************************************
Public Sub  RemakeProj()
	Dim  i, work, proj_type
	Dim  clean_params : Set clean_params = new Mxp_CleanProjParam


	'//=== Clean
	With clean_params
		.OutFolderPath = g_sh.CurrentDirectory
		.GenFolderPath = Empty
	End With
	For i=0 To UBound( Me.ProjTypeName )
		clean_params.ProjectName = Me.ProjectName(i)
		Set proj_type = get_Object( Me.ProjTypeName(i) )
		If Me.DebugMode and Me.F_BreakAtMakeProj Then  Stop
		proj_type.Clean  clean_params
	Next


	'//=== Update work files
	For Each work in  Me.WorkFiles.Items
		del  work.Path
	Next

	Me.MakeWork  Empty, Empty

	For Each work in  Me.WorkFiles.Items
		move_ren  work.GenPath, work.Path
		copy_ren  work.Path, work.OrgPath
	Next

	Me.MakeWorkStep2  Empty, Empty
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::OpenOption] >>> 
'********************************************************************************
Public Sub  OpenOption()
	Me.Open  WScript.Arguments.Named.Item("Open")
End Sub

Public Sub  OpenMenu()
	Dim  sym
	Dim  e  ' as Err2

	echo  "Loaded repositories ..."
	For Each sym  In Me.AllRepositories.Items
		echo  "["+ sym.Symbol +"] """+ sym.Path +""""
	Next
	echo  ""

	Do
		sym = input( "module symbol or file name>" )
		If sym = "" Then  Exit Do
		If TryStart(e) Then  On Error Resume Next
			Me.Open  sym
		If TryEnd Then  On Error GoTo 0
		If e.num <> 0 Then  echo e.desc : e.Clear
	Loop
End Sub


Public Sub  Open( ByVal NameOfOpen )
	Dim  b_module

	NameOfOpen = Trim( NameOfOpen )


	'//=== Open *_module.vbs or the folder
	If LCase( Right( NameOfOpen, 7  ) ) = "_module" Then _
		b_module = True : NameOfOpen = Left( NameOfOpen, Len( NameOfOpen ) - 7 )
	If LCase( Right( NameOfOpen, 11 ) ) = "_module.vbs" Then _
		b_module = True : NameOfOpen = Left( NameOfOpen, Len( NameOfOpen ) - 11 )

	If Me.AllModules.Exists( NameOfOpen ) Then
		If b_module Then
			start  Setting_getEditorCmdLine( _
				Me.AllModules.Item( NameOfOpen ).DefineInfo.FullPath )
		Else
			Setting_openFolder  g_fs.GetParentFolderName( _
				Me.AllModules.Item( NameOfOpen ).DefineInfo.FullPath )
		End If
	Else

		'//=== Open source file
		Dim  module, file_sym, path

		For Each module  In Me.AllModules.Items()
			For Each file_sym  In module.RepFiles.Keys()
				path = module.RepFiles.Item( file_sym ).Path
				If StrComp( file_sym, NameOfOpen, 1 ) = 0  or _
					 StrComp( g_fs.GetFileName( path ), NameOfOpen, 1 ) = 0 Then
					Exit For
				End If
				path = Empty
			Next
			If not IsEmpty( path ) Then  Exit For
			If StrComp( module.Name, NameOfOpen, 1 ) = 0 Then
				path = module.DefineInfo.FullPath
				Exit For
			End If
		Next

		If not IsEmpty( path ) Then
			If g_fs.FolderExists( path ) Then
				Setting_openFolder  path
			Else
				start  Setting_getEditorCmdLine( path )
			End If
		Else
			Raise  1, "<ERROR msg='指定したシンボルに対応するものがありません' "+_
				"symbol='" + NameOfOpen + "'/>"
		End If
	End If
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::CanWriteOpen] >>> 
'********************************************************************************
Function  CanWriteOpen( path )
	Dim  b, f, en,ed
	Const  ForAppending = 8

	b = True
	On Error Resume Next
		Set f = g_fs.OpenTextFile( Me.ProjectName(0) + ".ncb", ForAppending, True, False )
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	f = Empty
	If en = E_WriteAccessDenied Then  b = False : en = 0
	If en <> 0 Then  Err.Raise en,,ed
	CanWriteOpen = b
End Function


 
'********************************************************************************
'  <<< [Mxp_Proj::GetSymbol] >>> 
'********************************************************************************
Sub  GetSymbol( ByVal Path_and_Line )
	Dim  jumps, module, rep, symbol, info, b
	Do

	'//=== input path and line
	echo  "Get symbol from file path and line..."
	If IsEmpty( Path_and_Line ) Then
		Path_and_Line = input( "Path and Line (ex. file.c(14))>" )
		If Path_and_Line = "" Then  Exit Sub
	Else
		echo  Path_and_Line
	End If

	Set jumps = GetTagJumpParams( Path_and_Line )
	jumps.Path = GetAbsPath( jumps.Path, Empty )


	'//=== search
	info = Empty
	For Each module  In Me.AllModules.Items
		For Each rep  In module.RepFiles.Items
			If LCase( rep.Path ) = LCase( jumps.Path ) Then

				'//=== make rep.UsesKeys
				For Each symbol  In module.Symbols
					symbol.Uses
				Next
				Me.ResolveDepends

				'//=== search in file
				rep.GetLineInfo  jumps.LineNum, info  '//[out] info
				Exit For
			End If
		Next
		If not IsEmpty( info ) Then  Exit For
	Next


	'//=== print
	b=( IsEmpty( info ) )  'or
	If not b Then  b=( IsEmpty( info.Symbol ) )
	If b Then
		echo  "該当するモジュール・シンボルが見つかりません。"
	Else
		echo  "モジュール・シンボル ＝ """+ info.Symbol.Name +""""
	End If

	If ArgumentExist( "silent" ) Then  Exit Sub
	echo  ""
	Path_and_Line = Empty
	Loop
End Sub


 
'// <<< for Module VBS >>> 


 
'********************************************************************************
'  <<< [Mxp_Proj::StartRepository] >>> 
'********************************************************************************
Public Function  StartRepository( RepositoryName, DefineInfo )
	If not Me.AllRepositories.Exists( RepositoryName ) Then
		Raise  1, "<ERROR msg=""StartRepository に指定されているリポジトリ名が、AddRepository "+_
			"に指定されていません"" name="""+ RepositoryName +"""/>"
	End If

	Dim  rep : Set rep = Me.AllRepositories.Item( RepositoryName )
	If IsEmpty( rep.DefineInfo ) Then
		StartRepository = True
	Else
		StartRepository = False
	End If
End Function


 
'********************************************************************************
'  <<< [Mxp_Proj::StartModule] >>> 
'********************************************************************************
Public Function  StartModule( ModuleName, DefineInfo )
	If Me.AllModules.Exists( ModuleName ) Then
		Dim module : Set module = Me.AllModules.Item( ModuleName )
		If module.DefineInfo Is DefineInfo Then
			StartModule = False
		Else
			Dim  symbol
			For Each symbol  In module.Symbols
				Me.AllSymbols.Remove  symbol.Name
				symbol.Remove  "Removed by StartModule in "+ module.DefineInfo.FullPath
			Next
			Me.AllModules.Remove  ModuleName
			StartModule = True
		End If
	Else
		StartModule = True
	End IF

	If StartModule Then
		Set Me.CurrentModule = new Mxp_Module
		Set Me.CurrentModule.DefineInfo = DefineInfo
		Me.CurrentModuleName = ModuleName
		Me.AllModules.Add  ModuleName, Me.CurrentModule
		Me.CurrentModule.Name = ModuleName
	End If
End Function


 
'********************************************************************************
'  <<< [Mxp_Proj::SetModulePriority] >>> 
'********************************************************************************
Public Sub  SetModulePriority( Priority )
	Me.CurrentModule.Priority = Priority
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::SetModuleType] >>> 
'********************************************************************************
Public Sub  SetModuleType( ModuleTypeName )
	Me.CurrentModule.ModuleTypeName = ModuleTypeName
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::AddFile] >>> 
'********************************************************************************
Public Sub  AddFile( FileSymbol, StepPath, FileTypeName )
	Dim  e,  abs_path,  rep_file
	abs_path = GetAbsPath( StepPath, Empty )

	If Me.CurrentModuleName = "" Then  Exit Sub

	If not g_fs.FileExists( abs_path ) Then
		Raise 1,"<ERROR msg=""AddFile に指定したファイルが見つかりません"" "+_
			"path="""+ abs_path +""" file_type_name="""+ FileTypeName +_
			""" module_file="""+ g_SrcPath +""" module="""+ Me.CurrentModuleName +"""/>"
	End If

	If Me.AllSourceFiles.Exists( abs_path +"/"+ FileTypeName ) Then
		Set rep_file = Me.AllSourceFiles.Item( abs_path +"/"+ FileTypeName )
		Raise 1,"<ERROR msg=""AddFile に指定したファイルは、すでに登録されています"""+vbCRLF+_
			" path="""+ abs_path +""""+vbCRLF+" module1_path="""+ Me.CurrentModule.DefineInfo.FullPath +_
			""""+vbCRLF+" module2_path="""+ rep_file.ParentModule.DefineInfo.FullPath +"""/>"
	End If


	Set rep_file = new Mxp_RepFile
	rep_file.Symbol = FileSymbol
	rep_file.Path = abs_path
	rep_file.FileTypeName = FileTypeName
	If TryStart(e) Then  On Error Resume Next
		Set rep_file.FileType = Me.GetFileType_fromName( FileTypeName )
	If TryEnd Then  On Error GoTo 0
	If e.num <> 0 Then
		Err.raise e.num,,"<ERROR msg='" + XmlAttrA( e.desc ) + "' func='mxp.AddFile'"+_
			" FileSymbol='"+FileSymbol+"' module='" + Me.CurrentModule.Name + "'"+_
			" include_path='" +vbCRLF + "'" + XmlAttrA( g_SrcPath ) + "'/>"
	End If
	Me.CurrentModule.RepFiles.Add  FileSymbol, rep_file
	Set rep_file.ParentModule = Me.CurrentModule
	Set Me.AllSourceFiles.Item( abs_path +"/"+ FileTypeName ) = rep_file
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::AddCopyFile] >>> 
'********************************************************************************
Public Sub  AddCopyFile( FileSymbol, RepositoryStepPath, ProjectStepPath, FolderTypeName )
	Dim  e

	If Me.CurrentModuleName = "" Then  Exit Sub

	Dim  rep_file : Set rep_file = new Mxp_RepCopyFile
	rep_file.Symbol = FileSymbol
	rep_file.Path = g_fs.GetAbsolutePathName( RepositoryStepPath )
	rep_file.StepPathInProj = ProjectStepPath
	rep_file.FolderTypeName = FolderTypeName

	Me.CurrentModule.RepCopyFiles.Add  FileSymbol, rep_file
	Set rep_file.ParentModule = Me.CurrentModule
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::AddFolder] >>> 
'********************************************************************************
Public Sub  AddFolder( FolderSymbol, RepositoryStepPath, FolderTypeName )
	Dim  e, work

	If Me.CurrentModuleName = "" Then  Exit Sub

	Set work = new Mxp_WorkFolder
	work.Path = g_fs.GetAbsolutePathName( RepositoryStepPath )
	work.FolderTypeName = FolderTypeName
	work.Owner = I_OwnerIsModule

	Me.CurrentModule.RepFolders.Add  FolderSymbol, work
End Sub


 
'********************************************************************************
'  <<< [Mxp_Proj::AddNewSymbol] >>> 
'********************************************************************************
Public Function  AddNewSymbol( Symbol )
	Dim  e, o
	Dim  symbol_instance

	Set symbol_instance = new Mxp_Symbol
	If TryStart(e) Then  On Error Resume Next
		Me.AllSymbols.Add  Symbol, symbol_instance
	If TryEnd Then  On Error GoTo 0
	If e.num = &h1C9  Then  Raise e.num,"<ERROR msg=""シンボルが重複しています。"" symbol="""+ Symbol +_
		""""+ vbCRLF +" module1="""+ Me.AllSymbols.Item( Symbol ).ParentModule.Name +_
		""""+ vbCRLF +" module2="""+ Me.CurrentModule.Name +_
		""""+ vbCRLF +" path1="""+ Me.AllSymbols.Item( Symbol ).DefineInfo.FullPath +_
		""""+ vbCRLF +" path2="""+ Me.CurrentModule.DefineInfo.FullPath +"""/>"
	If e.num <> 0 Then  e.Raise

	Set o = symbol_instance
		o.Name = Symbol
		Set o.ParentModule = Me.CurrentModule
		Set o.DefineInfo = o.ParentModule.DefineInfo
	o = Empty
	Set AddNewSymbol = symbol_instance

	Me.CurrentModule.AddSymbol  symbol_instance
End Function


 
'********************************************************************************
'  <<< [Mxp_Proj::xml] >>> 
'********************************************************************************
Public Property Get  xml()
	Dim  x, s
	Dim  f : Set f = new StringStream

	f.WriteLine  "<Mxp_Proj>"

	f.WriteLine  "<Project_set>"
	For i=0 To UBound( Me.ProjectName )
		f.WriteLine  "  <Project ProjectName=""" + Me.ProjectName(i) + """ ProjTypeName=""" + Me.ProjTypeName(i) + """/>"
	Next
	f.WriteLine  "</Project_set>"

	f.WriteLine  "<Mxp_Module_set>"
	For Each x in Me.AllModules.Items
		f.WriteLine  "<Mxp_Module Name=""" + x.Name + """ Priority=""" & x.Priority & """ DefinePath=""" & x.DefineInfo.FullPath & """>"
		For Each s in x.Symbols
			f.WriteLine  "  <Symbol Name=""" + s.Name + """ />"
		Next
		f.WriteLine  "</Mxp_Module>"
	Next
	f.WriteLine  "</Mxp_Module_set>"

	f.WriteLine  "<Mxp_Symbol_set>"
	For Each x in Me.AllSymbols.Items
		f.WriteLine  "<Mxp_Symbol Name=""" + x.Name + """ m_Uses=""" & x.m_Uses & """ Used=""" & x.Used & """" + vbCRLF +_
								 "            ParentModule=""" + x.ParentModule.Name + """" + vbCRLF +_
								 "            DefinePath=""" + XmlAttr( x.DefineInfo.FullPath ) + """" + vbCRLF +_
								 "/>"
	Next
	f.WriteLine  "</Mxp_Symbol_set>"

	f.WriteLine  "<Mxp_FileType_set>"
	For Each x in Me.FileTypes.Items
		f.WriteLine  "<Mxp_FileType Name=""" + x.Name + """ ConfigIf=""" + XmlAttr( x.ConfigIf ) + """ ConfigEndIf=""" + XmlAttr( x.ConfigEndIf ) + """" + vbCRLF +_
								 "              DefinePath=""" + XmlAttr( x.DefineInfo.FullPath ) + """" + vbCRLF +_
								 "/>"
	Next
	f.WriteLine  "</Mxp_FileType_set>"

	f.WriteLine  "<Mxp_ProjType_set>"
	For Each x in Me.ProjTypes.Items
		f.WriteLine  "<Mxp_ProjType Name=""" + x.Name + """" + vbCRLF +_
								 "              DefinePath=""" + XmlAttr( x.DefineInfo.FullPath ) + """" + vbCRLF +_
								 "/>"
	Next
	f.WriteLine  "</Mxp_ProjType_set>"

	f.WriteLine  "</Mxp_Proj>"

	xml = f.ReadAll()
End Property


 
End Class 


 
'********************************************************************************
'  <<< [Mxp_SortCmp_byModule] >>> 
'Left, Right as Mxp_Module
'********************************************************************************
Function  Mxp_SortCmp_byModule( Left, Right, param )
	Mxp_SortCmp_byModule = Left.Priority - Right.Priority
	If Mxp_SortCmp_byModule = 0 Then _
		Mxp_SortCmp_byModule = StrComp( Left.Name, Right.Name, 1 )
End Function


 
'-------------------------------------------------------------------------
' ### <<<< [Mxp_WorkFolder] Class >>>> 
'-------------------------------------------------------------------------

Class  Mxp_WorkFolder
	Public  Path            ' as string. Abs path
	Public  StepPath        ' as string
	Public  FolderTypeName  ' as string
	Public  Owner           ' as I_OwnerIsProject or I_OwnerIsModule
	Public  bUses           ' as boolean
	Public  bCollector      ' as boolean
End Class

Const  I_OwnerIsProject = 1
Const  I_OwnerIsModule = 2


 
'-------------------------------------------------------------------------
' ### <<<< [Mxp_WorkFile] Class >>>> 
'-------------------------------------------------------------------------

Class  Mxp_WorkFile
	Public  StepPath  ' as string

	Public  FileTypeName  ' as string
	Public  FileType  ' as Mxp_FileType
	Public  Limit

	Public  ModuleTypeName  ' as string or Empty
	Public  OptionFlags     ' as 0 or F_AddIfDef or F_ReplaceToDefineOnly
	Public  HeadFootReplaces  ' as Dictionary. Key=from string, Item=to string

	Private Sub  Class_Initialize()
		Me.OptionFlags = 0
		Set Me.HeadFootReplaces = CreateObject( "Scripting.Dictionary" )
		    Me.HeadFootReplaces.CompareMode = NotCaseSensitive
	End Sub

 
'********************************************************************************
'  <<< [Mxp_WorkFile::WriteHeader] >>> 
'********************************************************************************
Public Sub  WriteHeader( WorkFileStream )
	Dim  f, t, en, ed, key

	If IsEmpty( Me.FileType.Head_Path ) Then  Exit Sub

	Set f = OpenForRead( Me.FileType.Head_Path )

	t = ""
	On Error Resume Next
		t = f.ReadAll
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	If en = E_EndOfFile Then  en = 0
	If en <> 0 Then  Err.Raise en,,ed

	For Each key  In Me.HeadFootReplaces.Keys
		If not IsEmpty( Me.HeadFootReplaces.Item( key ) ) Then _
			t = Replace( t, key, Me.HeadFootReplaces.Item( key ) )
	Next
	For Each key  In Me.FileType.HeadFootReplaces.Keys
		If not IsEmpty( Me.FileType.HeadFootReplaces.Item( key ) ) Then _
			t = Replace( t, key, Me.FileType.HeadFootReplaces.Item( key ) )
	Next

	WorkFileStream.Write  t
End Sub


 
'********************************************************************************
'  <<< [Mxp_WorkFile::WriteFooter] >>> 
'********************************************************************************
Public Sub  WriteFooter( WorkFileStream )
	Dim  f, t, en, ed, key

	If IsEmpty( Me.FileType.Foot_Path ) Then  Exit Sub

	Set f = OpenForRead( Me.FileType.Foot_Path )

	t = ""
	On Error Resume Next
		t = f.ReadAll
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	If en = E_EndOfFile Then  en = 0
	If en <> 0 Then  Err.Raise en,,ed

	For Each key  In Me.HeadFootReplaces.Keys
		If not IsEmpty( Me.HeadFootReplaces.Item( key ) ) Then _
			t = Replace( t, key, Me.HeadFootReplaces.Item( key ) )
	Next
	For Each key  In Me.FileType.HeadFootReplaces.Keys
		If not IsEmpty( Me.FileType.HeadFootReplaces.Item( key ) ) Then _
			t = Replace( t, key, Me.FileType.HeadFootReplaces.Item( key ) )
	Next

	WorkFileStream.Write  t
End Sub


 
'********************************************************************************
'  <<< [Mxp_WorkFile::WriteFileSeparator] >>> 
'********************************************************************************
Public Sub  WriteFileSeparator( WorkFileStream, ModuleName, RepFileSymbol )
	Dim  rf, line, en, ed


	'//=== Open the separator file for reading
	On Error Resume Next
		Set rf = g_fs.OpenTextFile( Me.FileType.FileSep_Path )
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	If en = E_FileNotExist Then  Exit Sub
	If en <> 0 Then  Err.Raise en,,ed


	'//=== Copy the separator
	Do Until rf.AtEndOfStream
		line = rf.ReadLine
		line = Replace( line, FileSymbol_Var, ModuleName +"/"+ RepFileSymbol )

		'//=== Break by output line text
		If ( mxp.DebugMode and mxp.F_BreakAtMakeWorkFile ) <> 0  and  not IsEmpty( mxp.DebugMode_Param3 ) Then
			If Trim( line ) = Trim( mxp.DebugMode_Param3 ) Then  Stop
		End If

		WorkFileStream.WriteLine  line
	Loop

	'//=== Break by file symbol
	If ( mxp.DebugMode and mxp.F_BreakAtMakeWorkFile ) <> 0  and  not IsEmpty( mxp.DebugMode_Param2 ) Then
		If InStr( RepFileSymbol, mxp.DebugMode_Param2 ) > 0 Then  Stop
	End If
End Sub


 
'********************************************************************************
'  <<< [Mxp_WorkFile::SkipToFileSeparator] >>> 
'********************************************************************************
Public Sub  SkipToFileSeparator( WorkFileStream, RepFileSymbol )
	Dim  sect, linenum, b

	Set sect = new Mxp_SectionText
	Do
		b= sect.ReadSection( WorkFileStream, linenum, Me.FileType, Empty )
		If not b Then  Err.raise 1,,"ファイルシンボル "+RepFileSymbol+" が、"+Me.Path+" の中のファイル区切りセクションから見つかりません。"

		If sect.Status = Sect_FileSeparator Then
			If sect.FileSymbol = RepFileSymbol Then  Exit Sub
		End If
	Loop
End Sub


 
'********************************************************************************
'  <<< [Mxp_WorkFile::ReadToFileSeparator] >>> 
'********************************************************************************
Public Function  ReadToFileSeparator( WorkFileStream, RepFileSymbol )
	Dim  sect, linenum, b, i, t

	Set sect = new Mxp_SectionText
	ReadToFileSeparator = ""
	Do
		b= sect.ReadSection( WorkFileStream, linenum, Me.FileType, Empty )
		If not b Then  Err.raise 1,,"ファイルシンボル "+RepFileSymbol+" が、"+_
			Me.Path+" の中のファイル区切りセクションから見つかりません。"

		ReadToFileSeparator = ReadToFileSeparator + sect.GetLines()

		If sect.Status = Sect_FileSeparator Then
			If sect.FileSymbol = RepFileSymbol Then  Exit Function
		End If
	Loop
End Function


 
End Class 


 
'-------------------------------------------------------------------------
' ### <<<< [Mxp_FileType] Class >>>> 
'-------------------------------------------------------------------------

'// Mxp_FileType::ContentsIfCommon
Dim  I_CommonIsNoText : I_CommonIsNoText = 1
Dim  I_CommonIsDefine : I_CommonIsDefine = 2
Dim  I_CommonIsStay   : I_CommonIsStay   = 3


Class  Mxp_FileType
	Public  Name          ' as string
	Public  DefineInfo    ' as DefineInfoClass
	Public  IsExistOnlyMaking  ' as boolean
	Public  IsMustMake    ' as boolean
	Public  Head_Path     ' as string. Abs path
	Public  Foot_Path     ' as string. Abs path
	Public  EmptyContents ' as string or Empty(= no file)
	Public  FileSep_Path  ' as string. Abs path
	Public  HeadFootReplaces  ' as Dictionary. Key=from string, Item=to string
	Public  IsBottomToTop     ' as boolean
	Public  Separators()      ' as array of string
	Public  ContentsIfCommon  ' as I_CommonIsNoText or ...

	Public  FirstWorkFile ' as Mxp_WorkFile

	Public  PostProcessOfMakeProj  ' as Empty or Sub
	Public  PreProcessOfClean      ' as Empty or Sub
	Public  ConfigIf      ' as string. %symbol% is replaced
	Public  ConfigEndIf   ' as string. %symbol% is replaced
	Public  CommonDefineTemplate   ' as string. %symbol% is replaced. ex) "#define  %symbol%  1 "
	Public  CommonIfTemplate       ' as string. %symbol% is replaced. ex) "#if  %symbol%"+vbCRLF
	Public  CommonEndIfTemplate    ' as string. %symbol% is replaced. ex) vbCRLF+"#endif  // %symbol%"

 
'********************************************************************************
'  <<< [Mxp_FileType::Class_Initialize] >>> 
'********************************************************************************
Private Sub  Class_Initialize
	Me.IsExistOnlyMaking = False
	Me.IsMustMake = True
	Set Me.HeadFootReplaces = CreateObject( "Scripting.Dictionary" )
	    Me.HeadFootReplaces.CompareMode = NotCaseSensitive
	Me.IsBottomToTop = False
	ReDim  Separators(-1)
	Me.ContentsIfCommon = I_CommonIsNoText
End Sub


 
'********************************************************************************
'  <<< [Mxp_FileType::AddSeparator] >>> 
'********************************************************************************
Public Sub  AddSeparator( sep )
	ReDim Preserve  Separators( UBound( Separators ) + 1 )
	Me.Separators( UBound( Separators ) ) = sep
End Sub


 
'********************************************************************************
'  <<< [Mxp_FileType::OutConfig] >>> 
' WorkFileStream as TextStream of work file
' Operatoin as integer
' Confs as ArrayClass of string
'********************************************************************************
Public Sub  OutConfig( WorkFileStream, Operation, Confs )

	'// Not output, if "Confs" = "mxp.DefaultConfigsArray"
	Set confs_dic = CreateObject( "Scripting.Dictionary" )
	For Each default_confs  In mxp.DefaultConfigsArray.Items
		If Confs.Count = default_confs.Count Then
			Dic_addFromArray  confs_dic, Confs.Items, True
			For Each conf  In default_confs.Items
				If not confs_dic.Exists( conf ) Then  Exit For
				confs_dic.Remove  conf
			Next
			If confs_dic.Count = 0 Then  Exit Sub
		End If
	Next


	'// Cut or not output #if condition
	Set if_confs = CreateObject( "Scripting.Dictionary" )
	Dic_addFromArray  if_confs, Confs.Items, True
	For Each default_conf  In mxp.DefaultConfigArray.Items
		If if_confs.Exists( default_conf ) Then _
			if_confs.Remove  default_conf
	Next
	If if_confs.Count = 0 Then  Exit Sub


	'// Set "line" : code template
	If Operation = mxp.OutConfigIf Then
		If IsEmpty( Me.ConfigIf ) Then  line = "#if  %symbol%" _
		Else  line = Me.ConfigIf
	ElseIf Operation = mxp.OutConfigEndIf Then
		If IsEmpty( Me.ConfigEndIf ) Then  line = "#endif // %symbol%" _
		Else  line = Me.ConfigEndIf
	Else
		Err.Raise 1
	End If


	'// Output
	s = ""
	For Each conf  In if_confs.Keys
		If s<>"" Then  s = s + " || "
		s = s + conf
	Next
	line = Replace( line, "%symbol%", s )

	WorkFileStream.WriteLine  line + " "
	WorkFileStream.WriteLine  " "
End Sub


 
End Class 


 
'-------------------------------------------------------------------------
' ### <<<< [Mxp_Module] Class >>>> 
'-------------------------------------------------------------------------

Class  Mxp_Module
	Public  Name         ' as string
	Public  DefineInfo   ' as DefineInfoClass
	Public  RepFiles     ' as Scripting.Dictionary, Key is FileSymbol, Item is Mxp_RepFile
	Public  RepFolders   ' as Scripting.Dictionary, Key is FolderSymbol, Item is Mxp_WorkFolder
	Public  RepCopyFiles ' as Scripting.Dictionary, Key is FileSymbol, Item is Mxp_RepCopyFile
	Public  Symbols()    ' as Mxp_Symbol
	Public  Priority     ' as integer or float
	Public  ModuleTypeName    ' as string
	Public  OwnerProjectName  ' as string or Empty


 
'********************************************************************************
'  <<< [Mxp_Module::Class_Initialize] >>> 
'********************************************************************************
Private Sub  Class_Initialize
	Set Me.RepFiles = CreateObject("Scripting.Dictionary")
	    Me.RepFiles.CompareMode = NotCaseSensitive
	Set Me.RepFolders = CreateObject("Scripting.Dictionary")
	    Me.RepFolders.CompareMode = NotCaseSensitive
	Set Me.RepCopyFiles = CreateObject("Scripting.Dictionary")
	    Me.RepCopyFiles.CompareMode = NotCaseSensitive
	Redim Symbols(-1)
	Me.Priority = 1000
	Me.ModuleTypeName = ""
End Sub


 
'********************************************************************************
'  <<< [Mxp_Module::AddSymbol] >>> 
'********************************************************************************
Public Sub  AddSymbol( Symbol )
	ReDim Preserve  Symbols( UBound( Symbols ) + 1 )
	Set Symbols( UBound( Symbols ) ) = Symbol
End Sub


 
'********************************************************************************
'  <<< [Mxp_Module::Print] >>> 
'********************************************************************************
Public Sub  Print()
	Dim  rep_file, key
	For Each rep_file in  Me.RepFiles.Items
		echo  " File: " + rep_file.Path
		For Each key in  rep_file.UsesKeys
			echo  "    " + key
		Next
	Next
End Sub


 
End Class 


 
'-------------------------------------------------------------------------
' ### <<<< [Mxp_Rep] Class >>>> 
' - The repository
'-------------------------------------------------------------------------

Class  Mxp_Rep
	Public  Name    ' as string
	Public  DefineInfo   ' as DefineInfoClass
	Public  Path    ' as string
End Class


 
'-------------------------------------------------------------------------
' ### <<<< [Mxp_RepFile] Class >>>> 
' - The master file in repository
'-------------------------------------------------------------------------

Class  Mxp_RepFile
	Public  Symbol  ' as string
	Public  Path    ' as string. In repository.
	Public  ParentModule  ' as Mxp_Module
	Public  FileTypeName  ' as string
	Public  FileType      ' as Mxp_FileType
	Public  UsesSections2 ' as Dictionary of Mxp_LinkToSection
	Public  UsesSections()  ' as array of Mxp_LinkToSection. index is same as UsesKeys and UsesKeysConfigs
	Public  UsesKeys()      ' as array of string
	Public  UsesKeysConfigs() ' as Empty or ArrayClass of string. Index is same as UsesKeys


 
'********************************************************************************
'  <<< [Mxp_RepFile::Class_Initialize] >>> 
'********************************************************************************
Private Sub  Class_Initialize
	Set UsesSections2 = CreateObject( "Scripting.Dictionary" )
	    UsesSections2.CompareMode = NotCaseSensitive
	ReDim  UsesSections(-1)
	ReDim  UsesKeys(-1)
End Sub


 
'********************************************************************************
'  <<< [Mxp_RepFile::AddToUseSection] >>> 
' LinkToSection as Mxp_LinkToSection
' Configs as Dictionary of string
'********************************************************************************
Public Sub AddToUseSection( LinkToSection, Configs )
	If Me.UsesSections2.Exists( LinkToSection.Key ) Then
		is_exist_uses_section = True

		'//=== Update "Me.UsesSections2( LinkToSection.Key ).IsCommon"
		If LinkToSection.IsCommon Then
			Set o = Me.UsesSections2.Item( LinkToSection.Key )
				o.IsCommon = LinkToSection.IsCommon
			o = Empty
		End If
	Else
		is_exist_uses_section = False

		'//=== Set "Me.UsesSections2"
		Set UsesSections2.Item( LinkToSection.Key ) = LinkToSection


		'//=== Set "Me.UsesSections"
		ReDim Preserve  UsesSections( UBound( UsesSections ) + 1 )
		Set UsesSections( UBound( UsesSections ) ) = LinkToSection

		ReDim Preserve  UsesKeys( UBound( UsesKeys ) + 1 )
		UsesKeys( UBound( UsesKeys ) ) = LinkToSection.Key


		'//=== Add "Empty" to "Me.UsesKeysConfigs"
		ReDim Preserve  UsesKeysConfigs( UBound( UsesKeys ) )  '// Me.UsesKeysConfigs, Me.UsesKeys
		UsesKeysConfigs( UBound( UsesKeys ) ) = Empty
		key_num = UBound( UsesKeys )
	End If


	'//=== Set "Me.UsesKeysConfigs"
	For Each conf  In Configs.Keys
		If conf = "." Then  Exit For
	Next
	If IsEmpty( conf ) and  Configs.Count > 0 Then
		If is_exist_uses_section Then
			For key_num = 0  To UBound( UsesKeys )  '//Me.UsesKeys
				If UsesKeys( key_num ) = LinkToSection.Key Then _
					Exit For
			Next
			Assert  key_num <= UBound( UsesKeys )
			LetSet  uses_keys_configs, UsesKeysConfigs( key_num )  '//[out]uses_keys_configs
		End If

		If IsEmpty( uses_keys_configs ) Then
			Set uses_keys_configs = new ArrayClass
			Set UsesKeysConfigs( key_num ) = uses_keys_configs
		Else
			uses_keys_configs.ToEmpty
		End If
		uses_keys_configs.Items = Configs.Keys
	End If
End Sub


 
'********************************************************************************
'  <<< [Mxp_RepFile::MakeText] >>> 
' WorkFileStream as TextStream of work file
' Work as Mxp_WorkFile
' Return is is_out_header of work file
'********************************************************************************
Public Function  MakeText( WorkFileStream, Work, bHeaderIsInWorkFile, MakeProjContext )
	Dim  f, line, i
	Dim  key, i_section, is_owner
	Dim  text, is_out_header, i_key_section, b_line_is_sep, sep
	Dim  confs  '// current configs as Empty or ArrayClass of string
	Dim  me_symbol : me_symbol = Replace( Me.Symbol, ".", "_" )

	'//echo  " File: " + Me.Path
	Set f = OpenForRead( Me.Path )

	Dim  ec : Set ec = new EchoOff


	'//=== set is_owner
	If Me.ParentModule.OwnerProjectName = mxp.ProjectName(0) Then
		is_owner = True
	Else
		If IsEmpty( Me.ParentModule.OwnerProjectName ) Then
			If IsEmpty( mxp.OtherModulesOwnerProjectName ) Then
				is_owner = True
			Else
				is_owner = False
			End If
		Else
			is_owner = False
		End If
	End If


	'//=== Read line
	text = "" : is_out_header = False : i_key_section = -1 : i_section = 1
	Do Until f.AtEndOfStream
		line = f.ReadLine


		'//=== Break by output line text
		If ( mxp.DebugMode and mxp.F_BreakAtMakeWorkFile ) <> 0  and  not IsEmpty( mxp.DebugMode_Param3 ) Then
			If Trim( line ) = Trim( mxp.DebugMode_Param3 ) Then  Stop
				'// If i_key_section = -1 Then
				'//   Set break point at next of following "If InStr( line, Me.UsesKeys(i) ) > 0"
				'// Else
				'//   Look at "Me.UsesKeys(i_key_section)"
		End If


		'//=== b_line_is_sep : this line is separate of section
		b_line_is_sep = False
		For Each sep  In Work.FileType.Separators
			If line = sep Then  b_line_is_sep = True : Exit For
		Next


		'//=== Pool the section and Judge of output section
		If not b_line_is_sep Then

			'//=== Judge of output section
			For i=0 To UBound( Me.UsesKeys )

				If InStr( line, Me.UsesKeys(i) ) > 0 Then

					If Me.UsesSections(i).IsCommon  or  not is_owner Then
						If (Work.OptionFlags and F_CommonIsNoText) = F_CommonIsNoText Then
							'// not set i_key_section
						Else
							Select Case  Me.FileType.ContentsIfCommon
								Case  I_CommonIsNoText  '// not set i_key_section
								Case  I_CommonIsDefine : i_key_section = i
								Case  I_CommonIsStay   : i_key_section = i
							End Select
						End If
					Else
						i_key_section = i
					End If
				End If
			Next

			'//=== pool section
			text = text + line + vbCR+vbLF


		'//=== Output 1 section
		Else

			If i_key_section >= 0 Then
				Me.MakeText_OutSection  WorkFileStream, Work, bHeaderIsInWorkFile, MakeProjContext, _
					text, line, is_out_header, confs, i_section, i_key_section, me_symbol, is_owner
			End If
			text = "" : i_key_section = -1 : i_section = i_section + 1

		End If
	Loop

	If i_key_section >= 0 Then
		Me.MakeText_OutSection  WorkFileStream, Work, bHeaderIsInWorkFile, MakeProjContext, _
			text, Work.FileType.Separators(0), is_out_header, confs, i_section, i_key_section, me_symbol, is_owner
	End If

	If not IsEmpty( confs ) Then
		Work.FileType.OutConfig  WorkFileStream, mxp.OutConfigEndIf, confs
	End If

	MakeText = is_out_header
End Function


'//[Mxp_RepFile::MakeText_OutSection]  output one section
Public Sub  MakeText_OutSection( WorkFileStream, Work, bHeaderIsInWorkFile, MakeProjContext, _
	text, line, is_out_header, confs, i_section, i_key_section, me_symbol, is_owner )

	'//=== Out header and file separator
	If not is_out_header Then
		If not bHeaderIsInWorkFile Then  Work.WriteHeader  WorkFileStream
		Work.WriteFileSeparator  WorkFileStream, Me.ParentModule.Name, Me.Symbol
		is_out_header = True
	End If


	'//=== Out #if-#endif by config
	If not IsSameArray( confs, Me.UsesKeysConfigs( i_key_section ) ) Then
		If not IsEmpty( confs ) Then
			Work.FileType.OutConfig  WorkFileStream, mxp.OutConfigEndIf, confs
			confs = Empty
		End If
		If not IsEmpty( Me.UsesKeysConfigs( i_key_section ) ) Then
			Set confs = Me.UsesKeysConfigs( i_key_section )
			Work.FileType.OutConfig  WorkFileStream, mxp.OutConfigIf, confs
		End If
	End If


	'//=== Out #if by F_AddIfDef
	If Work.OptionFlags and F_AddIfDef Then
		WorkFileStream.WriteLineDefault  Replace( Me.FileType.CommonIfTemplate, _
			"%symbol%", "UseSection_"+ me_symbol +"_"& i_section )
	End If


	'//=== Out lines of this section
	If (Work.OptionFlags and F_ReplaceToDefineOnly) = F_ReplaceToDefineOnly  or _
		 ( ( Me.UsesSections(i_key_section).IsCommon  or  not is_owner ) and  Me.FileType.ContentsIfCommon = I_CommonIsDefine ) Then
		WorkFileStream.WriteLine  Replace( Me.FileType.CommonDefineTemplate, "%symbol%", "UseSection_"+ me_symbol +"_"& i_section )
	Else
		If Me.UsesSections(i_key_section).IsSnippetTarget Then
			Me.EmbedSnippet  WorkFileStream, text, MakeProjContext
		Else
			text = Me.UsesSections(i_key_section).ParentSymbol.DoReplaceSource( text )
			If Me.UsesSections(i_key_section).IsTransform Then _
				text = mxp.TransformText( text, GetAbsPath( Work.StepPath, MakeProjContext.ProjectFolderAbsPath ) )

			WorkFileStream.Write  text
		End If
	End If


	'//=== Out #endif by F_AddIfDef
	If Work.OptionFlags and F_AddIfDef Then
		WorkFileStream.WriteLine  Replace( Me.FileType.CommonEndIfTemplate, "%symbol%", "UseSection_"+ me_symbol +"_"& i_section )
	End If


	'//=== Out separator
	WorkFileStream.WriteLine  line
End Sub


 
'********************************************************************************
'  <<< [Mxp_RepFile::EmbedSnippet] >>> 
'********************************************************************************
Public Sub  EmbedSnippet( WorkFileStream, SectionText, MakeProjContext )
	Dim  line,  pos1,  pos2,  target_name,  tmp_file,  root,  node,  indent,  file2
	Dim  is_crlf : is_crlf = ( InStr( SectionText, vbCRLF ) > 0 )
	Dim  file  : Set file  = new StringStream : file.SetString  SectionText

	Do Until file.AtEndOfStream
		line = file.ReadLine()
		pos1 = InStr( line, "[SnippetTarget:" )
		If pos1 > 0 Then

			'// target_name
			pos1 = InStr( pos1, line, ":" ) + 1
			pos2 = InStr( pos1, line, "]" )
			target_name = Mid( line, pos1, pos2-pos1 )

			pos1 = 1
			Do
				Select Case  Mid( line, pos1, 1 )
				Case  " ", vbTab
				Case Else : Exit Do
				End Select
				pos1 = pos1 + 1
			Loop
			indent = Left( line, pos1 - 1 )

			Set root = LoadXML( MakeProjContext.TemporaryXmlAbsPath, Empty )
			For Each node  In root.selectNodes( "./Snippet[@target='"+ target_name +"']" )
				Set file2 = new StringStream
				If is_crlf Then
					file2.SetString  Replace( node.text, vbLF, vbCRLF )
				Else
					file2.SetString  node.text
				End If

				'// skip 1st CR+LF
				Do Until file2.AtEndOfStream
					line = file2.ReadLine()
					If Trim2( line ) <> "" Then
						WorkFileStream.WriteLine  indent + line
						Exit Do
					End If
				Loop

				If not file2.AtEndOfStream Then
					Do Until file2.AtEndOfStream
						line = file2.ReadLine()
						WorkFileStream.WriteLine  indent + line
					Loop
				End If
				file2 = Empty
			Next
			root = Empty

			Set tmp_file = OpenForAppendXml( MakeProjContext.TemporaryXmlAbsPath, Empty )
			tmp_file.WriteLine  "<SnippetResult target="""+ target_name +"""/>"
			tmp_file = Empty
		Else
			WorkFileStream.WriteLine  line
		End If
	Loop
End Sub


 
'********************************************************************************
'  <<< [Mxp_RepFile::GetMatchedKey] >>> 
' Lines as string array
'********************************************************************************
Public Function  GetMatchedKey( Lines )
	Dim  line, key

	For Each line  In Lines
		For Each key in  Me.UsesKeys
			If InStr( line, key ) > 0 Then  GetMatchedKey = key : Exit Function
		Next
	Next
End Function


 
'********************************************************************************
'  <<< [Mxp_RepFile::GetLinkToSection] >>> 
' Lines as string array
'********************************************************************************
Public Function  GetLinkToSection( SectionKey )
	Dim  sect

	For Each sect  In Me.UsesSections
		If sect.Key = SectionKey Then  Set GetLinkToSection = sect : Exit Function
	Next
End Function


 
'********************************************************************************
'  <<< [Mxp_RepFile::GetLineInfo] >>> 
' If not found Then  out_Mxp_LineInfo.Symbol = Empty
'********************************************************************************
Public Sub  GetLineInfo( iLine, out_Mxp_LineInfo )
	Dim  f, line, i, sep
	Dim  i_key_section, b_line_is_sep

	Set out_Mxp_LineInfo = new Mxp_LineInfo : With out_Mxp_LineInfo
		Set .RepFile = Me
				.RepFile_iLine = iLine
	End With


	Set f = OpenForRead( Me.Path )

	Do Until f.AtEndOfStream
		line = f.ReadLine


		'//=== b_line_is_sep : this line is separate of section
		b_line_is_sep = False
		For Each sep  In Me.FileType.Separators
			If line = sep Then  b_line_is_sep = True : Exit For
		Next


		If not b_line_is_sep Then

			'//=== Judge of section
			For i=0 To UBound( Me.UsesKeys )
				If InStr( line, Me.UsesKeys(i) ) > 0 Then
					i_key_section = i
				End If
			Next


		'//=== if iLine is in this section then  Exit Do
		Else
			If iLine < f.Line Then  Exit Do
			i_key_section = -1
		End If
	Loop


	'//=== get information
	If iLine < f.Line Then
		If i_key_section >= 0 Then
			Set out_Mxp_LineInfo.Symbol = Me.UsesSections( i_key_section ).ParentSymbol
		End If
	End If
End Sub


 
'********************************************************************************
'  <<< [Mxp_RepFile::OutDiff] >>> 
' work_sects as Dictionary of Mxp_SectionText
' params as Mxp_OutDiff_Param
' nWarn as Integer [in/out]
'********************************************************************************
Public Sub  OutDiff( work_sects, params, nWarn )
	Dim  f, i, i_last, linenum, rep_sect, work_sect, key, path, cmdline, link
	Dim  rep_sects : Set rep_sects = CreateObject("Scripting.Dictionary")
	                     rep_sects.CompareMode = NotCaseSensitive
		' key = Mxp_LinkToSection::Key, Item=Mxp_SectionText


	'//=== Read sections from file in repository
	Set f = g_fs.OpenTextFile( Me.Path )
	linenum = 1
	Do
		Set rep_sect = new Mxp_SectionText
		If not rep_sect.ReadSection( f, linenum, params.FileType, Me ) Then  Exit Do
		If not IsEmpty( rep_sect.Key ) Then  rep_sects.Add  rep_sect.Key, rep_sect
	Loop
	f = Empty


	For Each work_sect  In work_sects.Items  'work_sect as Mxp_SectionText


'//=== for Debug
'If g_fs.GetFileName( params.WorkPath ) = "clib.c" Then  echo  ">>" & params.WorkPath & "(" & work_sect.LineNum & ")"
'If g_fs.GetFileName( params.WorkPath ) = "clib.c" And work_sect.LineNum = 22 Then Stop


		'//=== Compare section
		If not rep_sects.Exists( work_sect.Key ) Then
			nWarn = nWarn + 1
			echo "[Warning]("&nWarn&") not found section's key """ & work_sect.Key & """ in " & Me.Path
			i = 1 : i_last = 0  '// set as not different
		Else
			Set rep_sect = rep_sects.Item( work_sect.Key )
			i=0 : i_last = UBound( rep_sect.Lines )
			If i_last = UBound( work_sect.Lines ) Then
				For i=0 To i_last
					If rep_sect.Lines(i) <> work_sect.Lines(i) Then  Exit For
				Next
			End If
		End If


		'//=== Out both section, if different
		If i <> i_last + 1 Then
			mkdir  params.OutFolderPath
			params.DiffID = params.DiffID + 1

			path = params.OutFolderPath & "\" & Right("00" & params.DiffID, 3) & " " & _
				Me.Symbol & " " & GetKeyAlphabet( work_sect.Key )

			'//=== Text-Rep.txt
			Set f = g_fs.CreateTextFile( path & " [Text-Rep].txt", True, False )
			f.Write  rep_sect.GetLines()

			'//=== Text-Work.txt
			Set f = g_fs.CreateTextFile( path & " [Text-Work].txt", True, False )
			f.Write  work_sect.GetLines()

			'//=== Open-Rep.bat
			cmdline = "start """" " + Setting_getEditorCmdLine(3)
			cmdline = Replace( cmdline, "%1", Me.Path )
			cmdline = Replace( cmdline, "%2", work_sect.Key )
			cmdline = Replace( cmdline, "%d", rep_sect.LineNum )
			Set f = g_fs.CreateTextFile( path & " [Open-Rep].bat", True, False )
			f.WriteLine  cmdline

			'//=== Open-Work.bat
			cmdline = "start """" " + Setting_getEditorCmdLine(3)
			cmdline = Replace( cmdline, "%1", params.WorkPath )
			cmdline = Replace( cmdline, "%2", work_sect.Key )
			cmdline = Replace( cmdline, "%d", work_sect.LineNum )
			Set f = g_fs.CreateTextFile( path & " [Open-Work].bat", True, False )
			f.WriteLine  cmdline

			'//=== Diff.bat
			cmdline = "start """" " + Setting_getDiffCmdLine(2)
			cmdline = Replace( cmdline, "%1", path & " [Text-Rep].txt" )
			cmdline = Replace( cmdline, "%2", path & " [Text-Work].txt" )
			Set f = g_fs.CreateTextFile( path & " [Diff].bat", True, False )
			f.WriteLine  cmdline

			'//=== Update-Rep.vbs
			Set link = Me.GetLinkToSection(work_sect.Key)
			Set f = g_fs.CreateTextFile( path & " [Update].vbs", True, False )
			Me.WriteVbsHeader  f, params
			f.WriteLine "  "+ link.ParentSymbol.Name +".Uses"
			f.WriteLine "  mxp.AddWorkFile  """+_
				GetStepPath( g_fs.GetAbsolutePathName(params.FileType.FirstWorkFile.Path), _
					params.OutFolderPath ) + """, """+ params.FileType.Name +""""
			f.WriteLine "  ec = Empty"
			f.WriteLine ""
			f.WriteLine "  Dim op, msg1, msg2"
			f.WriteLine "  Do"
			f.WriteLine "    op = InputBox( """+g_fs.GetFileName(path)+" のセクションをコピーします。 どちらの内容を採用しますか？""+vbCR+vbLF+vbCR+vbLF+_"
			f.WriteLine "             ""1. リポジトリを採用（ワークは更新）""+vbCR+vbLF+""3. ワークを採用（リポジトリは更新）"", _"
			f.WriteLine "             """+g_fs.GetFileName(path)+""" )"
			f.WriteLine "    op = CInt2( op )"
			f.WriteLine "    If op = 0 Then  Exit Sub"
			f.WriteLine "    If op = 1 Then  op = RepToWork : msg1 = ""リポジトリ"" : msg2 = ""ワーク"" : Exit Do"
			f.WriteLine "    If op = 3 Then  op = WorkToRep : msg1 = ""ワーク"" : msg2 = ""リポジトリ"" : Exit Do"
			f.WriteLine "  Loop"
			f.WriteLine ""
			f.WriteLine "  Dim  rep, s"
			f.WriteLine "  Dim  wr : Set wr = new ArrayClass"
			f.WriteLine "  If op = WorkToRep Then"
			f.WriteLine "    s = ""次のフォルダの内容を更新します。"""
			f.WriteLine "    For Each rep  In mxp.AllRepositories.Items"
			f.WriteLine "      wr.Push rep.Path"
			f.WriteLine "      s = s + vbCRLF + rep.Path"
			f.WriteLine "    Next"
			f.WriteLine "    If MsgBox( s, vbOKCancel, """" ) <> vbOK Then  Exit Sub"
			f.WriteLine "  Else"
			f.WriteLine "    wr.Push  "".."""
			f.WriteLine "  End If"
			f.WriteLine ""
			f.WriteLine "  Set w_=AppKey.NewWritable( wr.Items ).Enable()"
			f.WriteLine ""
			f.WriteLine "  Set ec = new EchoOff"
			f.WriteLine "  mxp.UpdateSection  op, """+Me.Symbol+""", """+work_sect.Key+""""
			f.WriteLine "  ec = Empty"
			f.WriteLine ""
			f.WriteLine "  MsgBox  msg1 + ""の内容を "" + msg2 + ""にコピーしました。"", vbOKOnly, """+g_fs.GetFileName(path)+""""
			f.WriteLine ""
			f.WriteLine "  Set w_=AppKey.NewWritable( ""."" ).Enable()"
			f.WriteLine "  Set ec = new EchoOff"
			f.WriteLine "  del """+ g_fs.GetFileName( path & " [Update].vbs" ) + """"
			f.WriteLine "End Sub"

			f = Empty
		End If
	Next
End Sub


 
'********************************************************************************
'  <<< [Mxp_RepFile::WriteVbsHeader] >>> 
'********************************************************************************
Public Sub  WriteVbsHeader( VbsStream, params )
	Dim  rf, i, line

	Set rf = g_fs.OpenTextFile( WScript.ScriptFullName )
	Do Until rf.AtEndOfStream
		line = rf.ReadLine
		If InStr( line, "  g_CommandPrompt =" ) = 1 Then _
			line = "  g_CommandPrompt = 0"
		VbsStream.WriteLine  line
		If InStr( line, "-- end of vbslib include --" ) > 0 Then Exit Do
	Loop
	VbsStream.WriteLine ""
	VbsStream.WriteLine ""
	VbsStream.WriteLine "'**************************************************************"
	VbsStream.WriteLine "'  <<< [main] >>>"
	VbsStream.WriteLine "'**************************************************************"
	VbsStream.WriteLine "Sub  main2( Opt, AppKey ):Dim w_:Set w_=AppKey.NewWritable( ""."" ).Enable()"
	VbsStream.WriteLine "  Dim  ec"
	VbsStream.WriteLine "  Set ec = new EchoOff"
	VbsStream.WriteLine "  Set mxp = new Mxp_Proj"

	For i=0 To UBound( params.Repositories.Items )
		VbsStream.WriteLine "  Setting_addRepository  mxp, """ + params.Repositories(i).Symbol + """"
	Next
End Sub


 
End Class 


 
'-------------------------------------------------------------------------
' ### <<<< [Mxp_RepFileText] Class >>>> 
'-------------------------------------------------------------------------

Class  Mxp_RepFileText
	Public  Symbol        '// as string
	Public  TargetWorkStepPath  '// as string
	Public  FileTypeName  '// as string
	Public  FileType      '// as Mxp_FileType
	Public  EmbedText     '// as string

	Public Function  MakeText( WorkFileStream, Work, bHeaderIsInWorkFile, MakeProjContext )
		Dim  b_out_header

		If not IsEmpty( Me.TargetWorkStepPath )  and  Work.StepPath <> Me.TargetWorkStepPath Then _
			MakeText = False : Exit Function

		b_out_header = False

		'//=== Out header and file separator
		If not b_out_header Then
			If not bHeaderIsInWorkFile Then  Work.WriteHeader  WorkFileStream
			b_out_header = True
		End If

		'//=== Out header and file separator
		WorkFileStream.WriteLine  Me.EmbedText
		WorkFileStream.WriteLine  FileType.Separators(0)
		MakeText = b_out_header
	End Function
End Class



 
'-------------------------------------------------------------------------
' ### <<<< [Mxp_LineInfo] Class >>>> 
'-------------------------------------------------------------------------

Class  Mxp_LineInfo
	Public  RepFile        ' as Mxp_RepFile
	Public  RepFile_iLine  ' as integer
	Public  Symbol         ' as Mxp_Symbol
End Class


 
'-------------------------------------------------------------------------
' ### <<<< [Mxp_RepCopyFile] Class >>>> 
' - The file in repository
'-------------------------------------------------------------------------

Class  Mxp_RepCopyFile
	Public  Symbol  ' as string
	Public  Path    ' as string. In repository.
	Public  StepPathInProj  ' as string
	Public  ParentModule    ' as Mxp_Module
	Public  FolderTypeName  ' as string
	Public  UsesFile        ' as Empty(=NotUse) or Mxp_Symbol(=Use)
	Public  IsTransform     ' as boolean

	Private Sub  Class_Initialize()
		Me.IsTransform = False
	End Sub


 
'********************************************************************************
'  <<< [Mxp_RepFile::AddToUseFile] >>> 
' Symbol as Mxp_Symbol
'********************************************************************************
Public Sub AddToUseFile( Symbol )
	Set Me.UsesFile = Symbol
End Sub


 
End Class 


 
'-------------------------------------------------------------------------
' ### <<<< [Mxp_OutDiff_Param] Class >>>> 
'-------------------------------------------------------------------------

Class  Mxp_OutDiff_Param
	Public  OutFolderPath  ' As string
	Public  WorkPath       ' As string
	Public  DiffID         ' As integer
	Public  FileType       ' As Mxp_FileType
	Public  Repositories   ' As ArrayClass of Mxp_Rep
End Class


 
'-------------------------------------------------------------------------
' ### <<<< [Mxp_Symbol] Class >>>> 
'-------------------------------------------------------------------------

Class  Mxp_Symbol
	Public  Name      ' as String, Symbol Name
	Public  DefineName 'as String
	Public  DefineInfo 'as DefineInfoClass
	Public  m_Uses    ' as Boolean, Set True by "Uses" Sub
	Public  Used      ' as Boolean
	Public  m_CommonUses   ' as Boolean, Set True by "CommonUses" Sub
	Public  CommonUsed     ' as Boolean
	Public  IsDisableCommonUses  ' as Boolean
	Public  m_ReplaceSource      ' as Scripting.Dictionary
	Public  UseConfigs     ' as Scripting.Dictionary, "." is for all config
	Public  Versions       ' as Scripting.Dictionary, Item is string
	Public  SetDepend      ' as Function Reference
	Public  ParentModule   ' as Mxp_Module
	Public  UsesSections() ' as Mxp_LinkToSection
	Public  UsesFiles()    ' as Mxp_RepFile
	Public  UsesFolders()  ' as Mxp_WorkFolder
	Public  RemovedReason  ' as Empty or string


 
'********************************************************************************
'  <<< [Mxp_Symbol::Class_Initialize] >>> 
'********************************************************************************
Private Sub  Class_Initialize()
	Me.m_Uses = False
	Me.Used = False
	Me.m_CommonUses = False
	Me.CommonUsed = False
	Me.IsDisableCommonUses = False
	Set Me.m_ReplaceSource = CreateObject("Scripting.Dictionary")
	    Me.m_ReplaceSource.CompareMode = NotCaseSensitive
	Set Me.UseConfigs = CreateObject("Scripting.Dictionary")
	    Me.UseConfigs.CompareMode = NotCaseSensitive
	Set Me.Versions = CreateObject("Scripting.Dictionary")
	    Me.Versions.CompareMode = NotCaseSensitive
	Redim  UsesSections(-1)
	Redim  UsesFiles(-1)
	Redim  UsesFolders(-1)
End Sub


 
'********************************************************************************
'  <<< [Mxp_Symbol::Uses] >>> 
'********************************************************************************
Public Function  Uses()
	If mxp.IsCommonUsesMode Then  Uses = Me.CommonUses() : Exit Function

	If Me.m_Uses Then
		Uses = False
	Else
		Me.m_Uses = True
		Uses = True
	End If


	'//=== Check removed
	If not IsEmpty( Me.RemovedReason ) Then
		Raise  1,"<ERROR msg=""オブジェクトがありません。"" name="""+ Me.Name +""" reason="""+_
			Me.RemovedReason +"""/>"
	End If


	'//=== Inherit configs
	If UBound( mxp.CurrentConfigName ) = -1 Then
		Me.UseConfigs.Item( "." ) = 1
	Else
		Dim  conf
		For Each conf  In mxp.CurrentConfigName
			If not Me.UseConfigs.Exists( conf ) Then  Me.Used = False
			Me.UseConfigs.Item( conf ) = 1
		Next
	End If


	'//=== Debug
	If mxp.DebugMode_DependedSymbol = Me.Name Then
		If UBound( mxp.CurrentConfigName ) = -1 Then
			echo  Me.Name + ".Uses : config = ."
		Else
			Dim  s
			For Each conf  In mxp.CurrentConfigName
				s = s + conf + ", "
			Next
			echo  Me.Name + ".Uses : config = " + Left( s, Len( s ) - 2 )
		End If
		Stop  '// Look at caller function
	End If
End Function


 
'********************************************************************************
'  <<< [Mxp_Symbol::CommonUses] >>> 
'********************************************************************************
Public Function  CommonUses()
	If Me.m_CommonUses Then
		CommonUses = False
	Else
		Me.m_CommonUses = True
		CommonUses = True
	End If

	'//=== Debug
	If mxp.DebugMode_DependedSymbol = Me.Name Then
		If UBound( mxp.CurrentConfigName ) = -1 Then
			echo  Me.Name + ".CommonUses : config = ."
		Else
			Dim  s
			For Each conf  In mxp.CurrentConfigName
				s = s + conf + ", "
			Next
			echo  Me.Name + ".CommonUses : config = " + Left( s, Len( s ) - 2 )
		End If
		Stop
	End If
End Function


 
'********************************************************************************
'  <<< [Mxp_Symbol::IsResolved] >>> 
'********************************************************************************
Public Function  IsResolved()
	IsResolved = Not ( Me.m_Uses And Not Me.Used )
End Function


 
'********************************************************************************
'  <<< [Mxp_Symbol::IsResolvedCommon] >>> 
'********************************************************************************
Public Function  IsResolvedCommon()
	IsResolvedCommon = Not ( Me.m_CommonUses And Not Me.CommonUsed )
End Function


 
'********************************************************************************
'  <<< [Mxp_Symbol::ReplaceSource] >>> 
'********************************************************************************
Public Sub  ReplaceSource( Tag, Value )
	Me.m_ReplaceSource.Item( Tag ) = Value
End Sub


 
'********************************************************************************
'  <<< [Mxp_Symbol::DoReplaceSource] >>> 
'********************************************************************************
Public Function  DoReplaceSource( Text )
	Dim  tag

	DoReplaceSource = Text
	For Each tag  In Me.m_ReplaceSource.Keys
		DoReplaceSource = Replace( DoReplaceSource, tag, Me.m_ReplaceSource.Item( tag ) )
	Next
End Function


 
'********************************************************************************
'  <<< [Mxp_Symbol::UsesSection] >>> 
'********************************************************************************
Public Sub  UsesSection( FileSymbol, Key )
	Me.UsesSection_sub  FileSymbol, Key, Empty
End Sub


Public Sub  UsesSection_sub( FileSymbol, Key, Opt )
	Dim  rep_file, o

	If not Me.ParentModule.RepFiles.Exists( FileSymbol ) Then _
		Raise 1, "モジュール """+ Me.ParentModule.Name + """ の機能シンボル """ + Me.Name +_
		""" には、ファイルシンボル """ + FileSymbol + """ がありません。"+_
		" もしくは、ファイルシンボルが衝突していないかチェックしてください。"

	Set rep_file = Me.ParentModule.RepFiles.Item( FileSymbol )

	Dim  sect : Set sect = new Mxp_LinkToSection : Set o = sect
		Set  o.ParentSymbol = Me
		Set  o.RepFile = rep_file
		     o.Key = Key
		If Me.IsDisableCommonUses Then
		     o.IsCommon = False
		Else
		     o.IsCommon = mxp.IsCommonUsesMode
		End If
		If Opt = "Snip"  Then  o.IsSnippetTarget = True
		If Opt = "Trans" Then  o.IsTransform = True
	o = Empty
	ReDim Preserve  UsesSections( UBound( UsesSections ) + 1 )
	Set UsesSections( UBound( UsesSections ) ) = sect

	rep_file.AddToUseSection  sect, Me.UseConfigs
End Sub


 
'********************************************************************************
'  <<< [Mxp_Symbol::UsesSectionWithTransform] >>> 
'********************************************************************************
Public Sub  UsesSectionWithTransform( FileSymbol, Key )
	Me.UsesSection_sub  FileSymbol, Key, "Trans"
End Sub


 
'********************************************************************************
'  <<< [Mxp_Symbol::UsesSectionSnippetTarget] >>> 
'********************************************************************************
Public Sub  UsesSectionSnippetTarget( FileSymbol, Key )
	Me.UsesSection_sub  FileSymbol, Key, "Snip"
End Sub


 
'********************************************************************************
'  <<< [Mxp_Symbol::UsesFile] >>> 
'********************************************************************************
Public Sub  UsesFile( FileSymbol )
	Dim  o : Set o = Me.UsesFileSub( FileSymbol )
	o.IsTransform = False
End Sub


Public Function  UsesFileSub( FileSymbol )
	Dim  rep_file

	If not Me.ParentModule.RepCopyFiles.Exists( FileSymbol ) Then _
		Raise 1, "モジュール """+ Me.ParentModule.Name + """ の機能シンボル """ + Me.Name +_
		""" には、ファイルシンボル """ + FileSymbol + """ がありません。"

	Set rep_file = Me.ParentModule.RepCopyFiles.Item( FileSymbol ) ' as Mxp_RepCopyFile

	ReDim Preserve  UsesFiles( UBound( UsesFiles ) + 1 )
	Set UsesFiles( UBound( UsesFiles ) ) = rep_file

	rep_file.AddToUseFile  Me

	Set UsesFileSub = rep_file
End Function


 
'********************************************************************************
'  <<< [Mxp_Symbol::UsesFileWithTransform] >>> 
'********************************************************************************
Public Sub  UsesFileWithTransform( FileSymbol )
	Dim  o : Set o = Me.UsesFileSub( FileSymbol )
	o.IsTransform = True
End Sub


 
'********************************************************************************
'  <<< [Mxp_Symbol::UsesFolder] >>> 
'********************************************************************************
Public Sub  UsesFolder( FolderSymbol )
	Dim  work

	If not Me.ParentModule.RepCopyFiles.Exists( FolderSymbol ) Then _
		Raise 1, "モジュール """+ Me.ParentModule.Name + """ の機能シンボル """ + Me.Name +_
		""" には、フォルダシンボル """ + FolderSymbol + """ がありません。"

	Set work = Me.ParentModule.RepFolders.Item( FolderSymbol ) ' as Mxp_WorkFolder

	ReDim Preserve  UsesFolders( UBound( UsesFolders ) + 1 )
	Set UsesFolders( UBound( UsesFolders ) ) = work

	work.bUses = True

End Sub


 
'********************************************************************************
'  <<< [Mxp_Symbol::UsesText] >>> 
'********************************************************************************
Public Sub  UsesText( TargetWorkPath, FileTypeName, EmbedText )
	Dim  name : name = Me.ParentModule.Name +"_"& (Me.ParentModule.RepFiles.Count + 1)

	Dim rep_file : Set rep_file = new Mxp_RepFileText
	Dim o : Set o = rep_file
		o.Symbol             = name
		o.TargetWorkStepPath = TargetWorkPath
		o.FileTypeName       = FileTypeName
Set o.FileType           = mxp.FileTypes.Item( FileTypeName )
		o.EmbedText          = EmbedText
	o = Empty

	Set Me.ParentModule.RepFiles.Item( name ) = rep_file
End Sub


 
'********************************************************************************
'  <<< [Mxp_Symbol::Remove] >>> 
'********************************************************************************
Public Sub  Remove( Reason )
	Me.RemovedReason = Reason
End Sub


 
End Class 


 
'-------------------------------------------------------------------------
' ### <<<< [Mxp_LinkToSection] Class >>>> 
'-------------------------------------------------------------------------

Class  Mxp_LinkToSection
	Public  ParentSymbol      ' as Mxp_Symbol
	Public  RepFile           ' as Mxp_RepFile
	Public  Key               ' as string
	Public  IsCommon          ' as boolean
	Public  IsTransform       ' as boolean
	Public  IsSnippetTarget   ' as boolean

	Private Sub  Class_Initialize()
		Me.IsCommon = False
		Me.IsTransform = False
		Me.IsSnippetTarget = False
	End Sub

 
End Class 


 
'********************************************************************************
'  <<< [GetKeyAlphabet] >>> 
'********************************************************************************
Public Function  GetKeyAlphabet( key )
	Dim  c, i, n

	GetKeyAlphabet = ""
	n = Len( key )
	For i=1 To n
		c = Mid( key, i, 1 )
		If (c >= "0" and c <= "9") or (c >= "a" and c <= "z") or _
			 (c >= "A" and c <= "Z") or c = "." Then
			GetKeyAlphabet = GetKeyAlphabet + c
		End If
	Next

End Function


 
'-------------------------------------------------------------------------
' ### <<<< [Mxp_SectionText] Class >>>> 
'-------------------------------------------------------------------------

Class  Mxp_SectionText
	Public  Lines()  ' as string array. The data in File
	Public  LineNum  ' as integer
	Public  FileSymbol   ' as string. It is got from file separator in source file
	Public  Key      ' as string. Look at Mxp_RepFile::GetMatchedKey
	Public  Status   ' as integer. Sect_FileSeparator, Sect_NoInRep, ...


 
'********************************************************************************
'  <<< [Mxp_SectionText::ReadSection] >>> 
' f as File Stream
' linenum as integer [in/out]
' FileType as Mxp_FileType
' CurRepFile as Mxp_RepFile
'********************************************************************************
Public Function  ReadSection( f, linenum, FileType, CurRepFile )
	Dim  line, b_sep, sep, n_line
	Dim  sep_f, line2, i, j, en, ed

	Redim  Lines(-1)  'Me.Lines


	'//=== Open file separator
	On Error Resume Next
		Set sep_f = g_fs.OpenTextFile( FileType.FileSep_Path )
	en = Err.Number : ed = Err.Description : On Error GoTo 0
	If en = E_FileNotExist Then  sep_f = Empty : en = 0
	If en <> 0 Then  Err.Raise en,,ed


	'//=== Read section to Me.Lines
	n_line = 0
	Do Until f.AtEndOfStream

		'//=== Read line
		line = f.ReadLine
		Redim Preserve  Lines(n_line)  'Me.Lines
		Me.Lines(n_line) = line
		n_line = n_line + 1


		'//=== Is this file separator section ?
		If not IsEmpty( sep_f ) Then
			If sep_f.AtEndOfStream Then
				sep_f = Empty
			Else
				line2 = sep_f.ReadLine
				i = InStr( line2, FileSymbol_Var )
				If i > 0 Then
					j = Len( line2 ) - Len( FileSymbol_Var ) - (i - 1)
					If Left( line, i-1 ) = Left( line2, i-1 ) And _
						 Right( line, j ) = Right( line2, j ) Then
						Me.FileSymbol = Mid( line, i, Len( line ) - (i - 1) - j )
					Else
						sep_f = Empty
					End If
				Else
					If line2 <> line Then  sep_f = Empty
				End If
			End If
		End If


		'//=== If separate line then exit
		b_sep = False
		For Each sep  In FileType.Separators
			If line = sep Then  b_sep = True : Exit For
		Next
		If b_sep Then  Exit Do

	Loop


	'//=== If file separator section then
	If not IsEmpty( sep_f ) Then
		Me.Status = Sect_FileSeparator
	Else
		Me.FileSymbol = Empty
	End If


	'//=== Copy file attributes
	Me.LineNum = linenum : linenum = linenum + n_line
	If not IsEmpty( CurRepFile ) And IsEmpty( sep_f ) Then
		Me.FileSymbol = CurRepFile.Symbol
		Me.Key = CurRepFile.GetMatchedKey( Me.Lines )
	End If

	ReadSection = Not( f.AtEndOfStream And n_line=0 )
End Function


 
'********************************************************************************
'  <<< [Mxp_SectionText::GetLines] >>> 
'********************************************************************************
Public Function  GetLines()
	Dim  i, i_last

	GetLines = ""
	i_last = UBound( Me.Lines )
	For i=0 To i_last
		GetLines = GetLines + Me.Lines( i ) + vbCR+vbLF
	Next
End Function


 
End Class 


 
'-------------------------------------------------------------------------
' ### <<<< [Mxp_ProjType] Class >>>> 
'-------------------------------------------------------------------------

Class  Mxp_ProjType  '// defined_as_interface
	Public  Name
	Public  DefineInfo ' As DefineInfoClass

	Public  Sub  SetEnvs( MxpProj ) : End Sub

	Public  Sub  MakeProj2( Context_as_Mxp_MakeProjContext ) : End Sub
	Public  Sub  LoadProj2( Context_as_Mxp_LoadProjContext ) : End Sub
	Public  Sub  CleanProj2( Context_as_Mxp_CleanProjContext ) : End Sub
End Class


 
'-------------------------------------------------------------------------
' ### <<<< [Mxp_ProjType_Delegator] Class >>>> 
'-------------------------------------------------------------------------

Class  Mxp_ProjType_Delegator  '// has_interface_of Mxp_ProjType
	Public  Name
	Public Property Get  TrueName() : TrueName = NameDelegator_getTrueName( Me ) : End Property
	Public  m_Delegate ' as ClassA or ClassB or string(before validated)
	'--- Name is factory pattern.

	Public Sub  Validate( Flags ) : NameDelegator_validate  Me, Flags : End Sub
	Public Property Get  DefineInfo() : Set DefineInfo = m_Delegate.DefineInfo : End Property

	Public  Sub  SetEnvs( MxpProj ) : m_Delegate.SetEnvs( MxpProj ) : End Sub

	Public  Sub  MakeProj2( Context )  : m_Delegate.MakeProj2   Context : End Sub
	Public  Sub  LoadProj2( Context )  : m_Delegate.LoadProj2   Context : End Sub
	Public  Sub  CleanProj2( Context ) : m_Delegate.CleanProj2  Context : End Sub
End Class


Function  new_Mxp_ProjType_Delegator()
	Set  new_Mxp_ProjType_Delegator = new Mxp_ProjType_Delegator
End Function


 
'-------------------------------------------------------------------------
' ### <<<< [Mxp_LoadProjContext] Class >>>> 
'-------------------------------------------------------------------------
Class  Mxp_LoadProjContext
	Public  ProjectName              '// as string
	Public  ProjectFolderAbsPath     '// as string
	Public  OldProjParams            '// as dictionary. item は、Mxp_ProjType が決める
End Class


 
'-------------------------------------------------------------------------
' ### <<<< [Mxp_MakeProjContext] Class >>>> 
'-------------------------------------------------------------------------
Class  Mxp_MakeProjContext
	Public  ProjectName              '// as string
	Public  ProjectFolderAbsPath     '// as string
	Public  GeneratingFolderAbsPath  '// as string. Mxp_ProjType::MakeProj2 は、ここにファイルを出力する
	Public  GeneratedFolderAbsPath   '// as string
	Public  TemporaryXmlAbsPath      '// as string
	Public  SortedModules            '// as array of Mxp_Module
	Public  ReverseSortedModules     '// as array of Mxp_Module
	Public  OldProjParams            '// as dictionary. item は、Mxp_ProjType が決める
	Public  UseFolderPaths           '// as dictionary. Mxp_Proj::UseFolderPaths
	Public  MakingFilesOverwriteAction  '// as dictionary.  ex) Me.c.RecommendOverwriteCopy
	Public  IsDeleteGeneratingWorkFolder '// as boolean
	Public  c                        '// as Mxp_MakeProjContextConsts

	Private Sub  Class_Initialize()
		Set Me.c = get_Mxp_MakeProjContextConsts()
		Set Me.MakingFilesOverwriteAction = CreateObject( "Scripting.Dictionary" )
		    Me.MakingFilesOverwriteAction.CompareMode = NotCaseSensitive
	End Sub

	'//[Mxp_MakeProjContext::MakeWorkFiles]
	Public Sub  MakeWorkFiles( FileTypeName, OverwriteAction )
		m_Mxp_Proj.MakeWorkFiles  FileTypeName, Me, OverwriteAction
	End Sub

	'//[Mxp_MakeProjContext::DeleteWorkFiles]
	Public Sub  DeleteWorkFiles( FileTypeName )
		m_Mxp_Proj.DeleteWorkFiles  FileTypeName, Me
	End Sub

	'//[Mxp_MakeProjContext::SetMakingFilesOverwriteAction]
	Public Sub  SetMakingFilesOverwriteAction( FileStepPath, OverwriteAction )
		Assert  not IsFullPath( FileStepPath )
		Me.MakingFilesOverwriteAction.Item( FileStepPath ) = OverwriteAction
	End Sub

	'//[Mxp_MakeProjContext::MakeWorkFolder]
	Public Sub  MakeWorkFolder( FolderTypeName )
		m_Mxp_Proj.MakeWorkFolder  FolderTypeName, Me
	End Sub

	'//[Mxp_MakeProjContext::CheckAllOut]
	Public Sub  CheckAllOut()
		m_Mxp_Proj.CheckAllOut  Me
	End Sub


	'// for Mxp_Proj inside
	Public Sub  SetPrivateMxpProj( x ) : Set m_Mxp_Proj = x : End Sub
	Private  m_Mxp_Proj  '// as Mxp_Proj
End Class


 
'********************************************************************************
'  <<< [Mxp_MakeProjContextConsts] >>>
'********************************************************************************
Dim  g_Mxp_MakeProjContextConsts

Function    get_Mxp_MakeProjContextConsts()
	If IsEmpty( g_Mxp_MakeProjContextConsts ) Then _
		Set g_Mxp_MakeProjContextConsts = new Mxp_MakeProjContextConsts
	Set get_Mxp_MakeProjContextConsts =   g_Mxp_MakeProjContextConsts
End Function


Class  Mxp_MakeProjContextConsts
	Public  RecommendOverwriteCopy, MakeProjContext_DontOverwrite

	Private Sub  Class_Initialize()
		RecommendOverwriteCopy = 1
		MakeProjContext_DontOverwrite = 0  '// default ("If this = Empty" is True)
	End Sub
End Class


 
'-------------------------------------------------------------------------
' ### <<<< [Mxp_CleanProjContext] Class >>>> 
'-------------------------------------------------------------------------
Class  Mxp_CleanProjContext
	Public  ProjectName              '// as string
	Public  GeneratingFolderAbsPath  '// as string. Mxp_ProjType::MakeProj2 は、ここにファイルを出力する
	Public  ProjectFolderAbsPath     '// as string
	Public  IsDeepClean              '// as boolean
	Public  IsDeleteGenerating       '// as boolean

	Private Sub  Class_Initialize()
		Me.IsDeepClean = False
		Me.IsDeleteGenerating = True
	End Sub

	'//[Mxp_CleanProjContext::CleanWorkFilesIfSame]
	Public  Sub  CleanWorkFilesIfSame( ProjectFolderAbsPath )
		generating_folder_path = GetAbsPath( "_setup_generating", ProjectFolderAbsPath )
		generated_folder_path  = GetAbsPath( "_setup_generated",  ProjectFolderAbsPath )
		Set c = g_VBS_Lib


		'//=== 比較のため、リポジトリからプロジェクトを generating フォルダーに作成します
		Me.MakeProjForClean  generating_folder_path,  make_proj_context  '//[out]make_proj_context


		'//=== ワーク・ファイルが _setup_generating フォルダーにあるものと同じときは削除します
		g_Vers("CutPropertyM") = True

		For Each work_folder  In mxp.WorkFolders.Items
			Set o = new DeleteSameFileClass
			o.SourcePath       = GetAbsPath( "__"+ work_folder.FolderTypeName,_
				generating_folder_path )
			o.DestinationPath  = work_folder.Path
			o.SynchronizedPath = GetAbsPath( "__"+ work_folder.FolderTypeName,_
				generated_folder_path )
			o.Delete

			del  o.SourcePath
		Next
		For Each work_folder  In mxp.WorkFolders.Items
			del_empty_folder  work_folder.Path
		Next


		'//=== "MakeProjContext_DontOverwrite" のワークファイルは、generating と同じなら、
		'// 削除し、違ったらそのまま残す。 どちらでも generating と generated からは削除する。
		ExpandWildcard  GetAbsPath( "*", generating_folder_path ),_
			c.File or c.SubFolder,  folder,  step_paths
		For Each  step_path  In step_paths
			If make_proj_context.MakingFilesOverwriteAction.Item( step_path ) = _
				make_proj_context.c.MakeProjContext_DontOverwrite Then

				src = GetAbsPath( step_path, generating_folder_path )
				dst = GetAbsPath( step_path, ProjectFolderAbsPath )
				syn = GetAbsPath( step_path, generated_folder_path )

				If g_fs.FileExists( dst ) Then
					If IsSameBinaryFile( src, dst, Empty ) Then _
						del  dst
				End If

				If g_fs.FileExists( src ) Then  del  src
				If g_fs.FileExists( syn ) Then  del  syn
			End If
		Next


		'//=== ワークファイルの相対パスに、".."（親フォルダー）のパスがあるものをクリーンします
		ExpandWildcard  GetAbsPath( mxp.ParentFolderProxyName, generating_folder_path ),_
			c.Folder or c.SubFolder,  folder,  step_paths
		step_paths = ArrayToNameOnlyClassArray( step_paths )
		ShakerSort  step_paths, 0, UBound( step_paths ), GetRef("LengthNameCompare"), -1
		For Each  step_path  In step_paths
			Set o = new DeleteSameFileClass
			o.SourcePath       = GetAbsPath( step_path.Name, generating_folder_path )
			o.DestinationPath  = GetAbsPath( Replace( step_path.Name, _
				mxp.ParentFolderProxyName, ".." ), ProjectFolderAbsPath )
			o.SynchronizedPath = GetAbsPath( step_path.Name, generated_folder_path )
			If Me.IsDeepClean Then
				o.DeleteSameOnly
			Else
				o.Delete
			End If
		Next


		'// ワークファイルの相対パスに、".."（親フォルダー）のパスがないものをクリーンします
		Set o = new DeleteSameFileClass
		o.SourcePath       = generating_folder_path
		o.DestinationPath  = ProjectFolderAbsPath
		o.SynchronizedPath = generated_folder_path
		If Me.IsDeepClean Then
			o.DeleteSameOnly
		Else
			o.Delete
		End If


		If Me.IsDeleteGenerating Then  del  generating_folder_path
		del  generated_folder_path
	End Sub


	'//[Mxp_CleanProjContext::MakeProjForClean]
	Public  Sub  MakeProjForClean( GeneratingFolderAbsPath, out_MakeProjContext )
		m_Mxp_Proj.ResolveDepends

		'// sorted_modules as array of Mxp_Module
		QuickSort_fromDic  m_Mxp_Proj.AllModules, m_SortedModules, GetRef("Mxp_SortCmp_byModule"), Empty

		'//=== プロジェクトを作成する
		m_Mxp_Proj.MakeProj2Sub  m_ProjType, m_SortedModules, out_MakeProjContext, False
			'//[out] out_MakeProjContext as Mxp_MakeProjContext
	End Sub

	'// for Mxp_Proj inside
	Public Sub  SetPrivate( Proj, ProjType ) : Set m_Mxp_Proj = Proj : Set m_ProjType = ProjType : End Sub
	Private  m_Mxp_Proj  '// as Mxp_Proj
	Private  m_ProjType  '// as Mxp_ProjType
	Private  m_SortedModules  '// as array of Mxp_Module
End Class


 
'-------------------------------------------------------------------------
' ### <<<< [Mxp_MakeProjParam] Class >>>> 
'-------------------------------------------------------------------------

Class  Mxp_MakeProjParam
	Public  ProjectName    ' as string
	Public  OutFolderPath  ' as string
	Public  OutFolderBasePathForStepPath  ' as string
	Public  GUID           ' as string
	Public  UseFolderPaths ' as Scripting.Dictionary, Key is Mxp_WorkFolder::FolderTypeName, Item is as ArrayClass of string
End Class


 
'-------------------------------------------------------------------------
' ### <<<< [Mxp_CleanProjParam] Class >>>> 
'-------------------------------------------------------------------------

Class  Mxp_CleanProjParam
	Public  ProjectName    ' as string
	Public  OutFolderPath  ' as string
	Public  GenFolderPath  ' as string
End Class
 
