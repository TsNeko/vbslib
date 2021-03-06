Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_CrossFind_1", _
			"2","T_CrossFind_2" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'***********************************************************************
'* Function: T_CrossFind_1
'*    Simple example code of "A1.xml" in "T_CrossFind_2".
'***********************************************************************
Sub  T_CrossFind_1( Opt, AppKey )
	Set find_ = new CrossFindClass

	Set project = find_.AddProject( "p1" )
	project.AddModule  "t11", Array( "a1", "a2" )
	project.AddModule  "t12", Array( "b1", "b2" )

	Set project = find_.AddProject( "p2" )
	project.AddModule  "t21", Array( "a1", "a2" )
	project.AddModule  "t22", Array( "b1", "b2" )

	Set project = find_.AddProject( "p3" )
	project.AddModule  "t31", Array( "a1", "b1" )
	project.AddModule  "t32", Array( "a2" )
	project.AddModule  "t33", Array( "b2" )

	For Each  element_name  In  find_.OutElements.Keys
		echo  "element_name = "+ element_name
		Set element = find_.OutElements.Item( element_name )
		For  k=0  To  element.OutModuleTypes.Count - 1
			Set module_type = element.OutModuleTypes.Item(k)
			echo  vbTab +"module_type.Names = "+ module_type.Name
			echo  vbTab +"Elements = "+ new_ArrayClass( module_type.Delegate.Elements ).CSV
			echo  ""
		Next
	Next

	Pass
End Sub


 
'***********************************************************************
'* Function: T_CrossFind_2
'***********************************************************************
Sub  T_CrossFind_2( Opt, AppKey )
	Set w_=AppKey.NewWritable( "." ).Enable()
	Set section = new SectionTree
'// SetStartSectionTree  "T_CrossFind_A3"

	For Each  file_name  In  Array( "A1.xml", "A2.xml", "A3.xml", "A4.xml", "B1.xml", "B2.xml", "B3.xml", "C.xml" )
	If section.Start( "T_CrossFind_"+ g_fs.GetBaseName( file_name ) ) Then

		'// Set up
		text = ReadVBS_Comment( Empty, "["+""+ file_name +"]", "[/"+""+ file_name +"]", Empty )
		Set root = LoadXML( text, g_VBS_Lib.StringData )


		'// Test Main
		Set find_ = new CrossFindClass
		For Each  project_tag  In  root.selectNodes( "./Project" )
			Set project = find_.AddProject( project_tag.getAttribute( "name" ) )
			For Each  module_tag  In  project_tag.selectNodes( "./Module" )
				project.AddModule  module_tag.getAttribute( "name" ), _
					ArrayFromCSV( module_tag.selectSingleNode( "./text()" ).nodeValue )
			Next
		Next


		'// Check
		Set answer_tag = root.selectSingleNode( "./Answer" )
		Assert  find_.OutElements.Count = answer_tag.selectNodes( "./Element" ).length
		For Each  element_name  In  find_.OutElements.Keys
			Set element = find_.OutElements.Item( element_name )
			Set element_tag = answer_tag.selectSingleNode( "./Element[@name='"+ element.Name +"']" )

			pass_count = 0
			Set module_tags = element_tag.selectNodes( "./ModuleType" )
			Assert  element.OutModuleTypes.Count = module_tags.length

			For  k=0  To  element.OutModuleTypes.Count - 1
				Set module = element.OutModuleTypes.Item(k)
				For Each  module_tag  In  module_tags
					If IsSameArrayOutOfOrder(  _
							ArrayFromCSV( module.Name ), _
							ArrayFromCSV( module_tag.getAttribute( "names" ) ), _
							Empty ) Then

						elements_answer = ArrayFromCSV( module_tag.selectSingleNode( _
							"./text()" ).nodeValue )

						Assert  IsSameArrayOutOfOrder( module.Delegate.Elements, _
							elements_answer,  Empty )

						pass_count = pass_count + 1
						Exit For
					End If
				Next
			Next
			Assert  pass_count = module_tags.length
		Next


		'// Clean
	End If : section.End_
	Next

	Pass
End Sub


 
'***********************************************************************
'* Variable: A1.xml
'***********************************************************************
'-------------------------------------------------------------------[A1.xml]
'<Root>
'	<Project  name="p1">
'		<Module  name="t11">a1, a2</Module> <Module  name="t12">b1, b2</Module>
'	</Project>
'	<Project  name="p2">
'		<Module  name="t21">a1, a2</Module> <Module  name="t22">b1, b2</Module>
'	</Project>
'	<Project  name="p3">
'		<Module  name="t31">a1, b1</Module> <Module  name="t32">a2</Module> <Module  name="t33">b2</Module>
'	</Project>
'
'	<Answer>
'		<Element  name="a1">
'			<ModuleType  names="t11, t21">a1, a2</ModuleType>
'			<ModuleType  names="t31">a1, b1</ModuleType>
'		</Element>
'		<Element  name="a2">
'			<ModuleType  names="t11, t21, t32">a1, a2</ModuleType>
'		</Element>
'		<Element  name="b1">
'			<ModuleType  names="t12, t22">b1, b2</ModuleType>
'			<ModuleType  names="t31">a1, b1</ModuleType>
'		</Element>
'		<Element  name="b2">
'			<ModuleType  names="t12, t22, t33">b1, b2</ModuleType>
'		</Element>
'	</Answer>
'</Root>
'------------------------------------------------------------------[/A1.xml]


 
'***********************************************************************
'* Variable: A2.xml
'***********************************************************************
'-------------------------------------------------------------------[A2.xml]
'<Root>
'	<Project  name="p1">
'		<Module  name="t11">a1, a2</Module> <Module  name="t12">b1, b2</Module>
'	</Project>
'	<Project  name="p2">
'		<Module  name="t21">a1, b1</Module> <Module  name="t22">a2, b2</Module>
'	</Project>
'
'	<Answer>
'		<Element  name="a1">
'			<ModuleType  names="t11">a1, a2</ModuleType>
'			<ModuleType  names="t21">a1, b1</ModuleType>
'		</Element>
'		<Element  name="a2">
'			<ModuleType  names="t11">a1, a2</ModuleType>
'			<ModuleType  names="t22">a2, b2</ModuleType>
'		</Element>
'		<Element  name="b1">
'			<ModuleType  names="t12">b1, b2</ModuleType>
'			<ModuleType  names="t21">a1, b1</ModuleType>
'		</Element>
'		<Element  name="b2">
'			<ModuleType  names="t12">b1, b2</ModuleType>
'			<ModuleType  names="t22">a2, b2</ModuleType>
'		</Element>
'	</Answer>
'</Root>
'------------------------------------------------------------------[/A2.xml]


 
'***********************************************************************
'* Variable: A3.xml
'***********************************************************************
'-------------------------------------------------------------------[A3.xml]
'<Root>
'	<Project  name="p1">
'		<Module  name="t11">a1, a2</Module> <Module  name="t12">b1, b2, b3</Module>
'	</Project>
'	<Project  name="p2">
'		<Module  name="t21">a5, a1, a2, a3, a4</Module> <Module  name="t22">b1, b4</Module>
'	</Project>
'
'	<Answer>
'		<Element  name="a1">
'			<ModuleType  names="t11, t21">a1, a2, a3, a4, a5</ModuleType>
'		</Element>
'		<Element  name="a2">
'			<ModuleType  names="t11, t21">a1, a2, a3, a4, a5</ModuleType>
'		</Element>
'		<Element  name="a3">
'			<ModuleType  names="t21">a1, a2, a3, a4, a5</ModuleType>
'		</Element>
'		<Element  name="a4">
'			<ModuleType  names="t21">a1, a2, a3, a4, a5</ModuleType>
'		</Element>
'		<Element  name="a5">
'			<ModuleType  names="t21">a1, a2, a3, a4, a5</ModuleType>
'		</Element>
'		<Element  name="b1">
'			<ModuleType  names="t12, t22">b1, b2, b3, b4</ModuleType>
'		</Element>
'		<Element  name="b2">
'			<ModuleType  names="t12">b1, b2, b3, b4</ModuleType>
'		</Element>
'		<Element  name="b3">
'			<ModuleType  names="t12">b1, b2, b3, b4</ModuleType>
'		</Element>
'		<Element  name="b4">
'			<ModuleType  names="t22">b1, b2, b3, b4</ModuleType>
'		</Element>
'	</Answer>
'</Root>
'------------------------------------------------------------------[/A3.xml]


 
'***********************************************************************
'* Variable: A4.xml
'***********************************************************************
'-------------------------------------------------------------------[A4.xml]
'<Root>
'	<Project  name="p1">
'		<Module  name="t11">a1</Module>
'	</Project>
'	<Project  name="p2">
'		<Module  name="t21">a2, a1</Module>
'	</Project>
'
'	<Answer>
'		<Element  name="a1">
'			<ModuleType  names="t11, t21">a2, a1</ModuleType>
'		</Element>
'		<Element  name="a2">
'			<ModuleType  names="t21">a2, a1</ModuleType>
'		</Element>
'	</Answer>
'</Root>
'------------------------------------------------------------------[/A4.xml]


 
'***********************************************************************
'* Variable: B1.xml
'***********************************************************************
'-------------------------------------------------------------------[B1.xml]
'<Root>
'	<Project  name="modules">
'		<Module  name="sc">script</Module>
'		<Module  name="sa">sample_forA, sample_forB</Module>
'		<Module  name="te">test</Module>
'	</Project>
'
'	<Project  name="targetA">
'		<Module  name="m1">script, sample_forA</Module>
'	</Project>
'	<Project  name="targetB">
'		<Module  name="m2">script, sample_forB</Module>
'	</Project>
'	<Project  name="targetT">
'		<Module  name="m3">script, test</Module>
'	</Project>
'	<Project  name="single">
'		<Module  name="m4">script</Module>
'	</Project>
'
'	<Answer>
'		<Element  name="script">
'			<ModuleType  names="sc, m4">script</ModuleType>
'			<ModuleType  names="sa, m1, m2">script, sample_forA, sample_forB</ModuleType>
'			<ModuleType  names="te, m3">script, test</ModuleType>
'		</Element>
'		<Element  name="sample_forA">
'			<ModuleType  names="sa">sample_forA, sample_forB</ModuleType>
'			<ModuleType  names="m1">script, sample_forA</ModuleType>
'		</Element>
'		<Element  name="sample_forB">
'			<ModuleType  names="sa">sample_forA, sample_forB</ModuleType>
'			<ModuleType  names="m2">script, sample_forB</ModuleType>
'		</Element>
'		<Element  name="test">
'			<ModuleType  names="te">test</ModuleType>
'			<ModuleType  names="m3">script, test</ModuleType>
'		</Element>
'	</Answer>
'</Root>
'------------------------------------------------------------------[/B1.xml]


 
'***********************************************************************
'* Variable: B2.xml
'***********************************************************************
'-------------------------------------------------------------------[B2.xml]
'<Root>
'	<Project  name="modules">
'		<Module  name="sa">script, sample_forA, sample_forB</Module>
'		<Module  name="te">test</Module>
'	</Project>
'
'	<Project  name="targetA">
'		<Module  name="m1">script, sample_forA</Module>
'	</Project>
'	<Project  name="targetB">
'		<Module  name="m2">script, sample_forB</Module>
'	</Project>
'	<Project  name="targetT">
'		<Module  name="m3">script, test</Module>
'	</Project>
'	<Project  name="single">
'		<Module  name="m4">script</Module>
'	</Project>
'
'	<Answer>
'		<Element  name="script">
'			<ModuleType  names="sa, m1, m2, m4">script, sample_forA, sample_forB</ModuleType>
'			<ModuleType  names="te, m3">script, test</ModuleType>
'		</Element>
'	</Answer>
'</Root>
'------------------------------------------------------------------[/B2.xml]


 
'***********************************************************************
'* Variable: B3.xml
'***********************************************************************
'-------------------------------------------------------------------[B3.xml]
'<Root>
'	<Project  name="modules">
'		<Module  name="sa">sample_forA, sample_forB</Module>
'		<Module  name="te">script, test</Module>
'	</Project>
'
'	<Project  name="targetA">
'		<Module  name="m1">script, sample_forA</Module>
'	</Project>
'	<Project  name="targetB">
'		<Module  name="m2">script, sample_forB</Module>
'	</Project>
'	<Project  name="targetT">
'		<Module  name="m3">script, test</Module>
'	</Project>
'	<Project  name="single">
'		<Module  name="m4">script</Module>
'	</Project>
'
'	<Answer>
'		<Element  name="script">
'			<ModuleType  names="sa, m1, m2">script, sample_forA, sample_forB</ModuleType>
'			<ModuleType  names="te, m3, m4">script, test</ModuleType>
'		</Element>
'	</Answer>
'</Root>
'------------------------------------------------------------------[/B3.xml]


 
'***********************************************************************
'* Variable: C.xml
'***********************************************************************
'-------------------------------------------------------------------[C.xml]
'<Root>
'	<Project  name="modules">
'		<Module  name="sc">script_1, script_2</Module>
'		<Module  name="sa">sample_1, sample_2</Module>
'		<Module  name="te">test</Module>
'	</Project>
'
'	<Project  name="targetA">
'		<Module  name="m1">script_1, sample_1</Module>
'	</Project>
'	<Project  name="targetB">
'		<Module  name="m2">script_2, test</Module>
'	</Project>
'	<Project  name="targetC">
'		<Module  name="m3">script_1, sample_2, test</Module>
'	</Project>
'
'	<Answer>
'		<Element  name="script_1">
'			<ModuleType  names="sc">script_1, script_2</ModuleType>
'			<ModuleType  names="sa, m1">script_1, script_2, sample_1, sample_2</ModuleType>
'			<ModuleType  names="te, m2">script_1, script_2, test</ModuleType>
'			<ModuleType  names="m3">script_1, script_2, sample_1, sample_2, test</ModuleType>
'		</Element>
'	</Answer>
'</Root>
'------------------------------------------------------------------[/C.xml]


 







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


 
