Option Explicit 
'--- start of OLD vbslib include ------------------------------------------------------
'// vbslib は、3-clause BSD ライセンスで提供されています。
'// ここは、修正しないでください。下記メイン関数からスクリプトを記述してください。
'// ＭＳオフィスやコンパイラがあれば、下記のｇ＿ｄｅｂｕｇ を９９などにすれば、デバッガが使えます。
'// Ｓｔｏｐ命令を記述すれば、デバッガはブレークします。詳しくは vbslib の説明書の最後の「困ったときは」。
Dim  g_debug, g_debug_params, g_admin, g_vbslib_path, g_CommandPrompt, g_fs, g_sh, g_AppKey, g_Vers
If IsEmpty( g_fs ) Then
  Dim  g_MainPath, g_SrcPath : g_SrcPath = WScript.ScriptFullName : g_MainPath = g_SrcPath
  Set g_Vers = CreateObject("Scripting.Dictionary") : g_Vers.Add "vbslib", 99.99

  '--- start of parameters for vbslib include -------------------------------
  g_debug = 0          '// release:0, debug:99, -1:call SetupDebugTools
  Sub SetupDebugTools() : set_input "" : SkipToSection Empty : SetBreakByFName Empty : End Sub
  g_vbslib_path = "scriptlib\vbs_inc.vbs"
  g_CommandPrompt = 2
  '--- end of parameters for vbslib include ---------------------------------

  Dim  g_f, g_include_path, i : Set  g_fs = CreateObject( "Scripting.FileSystemObject" )
  Set  g_sh = WScript.CreateObject("WScript.Shell") : g_f = g_sh.CurrentDirectory
  g_sh.CurrentDirectory = g_fs.GetParentFolderName( WScript.ScriptFullName )
  For i = 20 To 1 Step -1 : If g_fs.FileExists(g_vbslib_path) Then  Exit For
  g_vbslib_path = "..\" + g_vbslib_path  : Next
  If g_fs.FileExists(g_vbslib_path) Then  g_vbslib_path = g_fs.GetAbsolutePathName( g_vbslib_path )
  g_sh.CurrentDirectory = g_f
  If i=0 Then WScript.Echo "Not found " + g_fs.GetFileName( g_vbslib_path ) +vbCR+vbLF+_
    "Let's download vbslib "&g_Vers.Item("vbslib")&" and Copy vbslib folder." : Stop : WScript.Quit 1
  Set g_f = g_fs.OpenTextFile( g_vbslib_path,,,-2 ): Execute g_f.ReadAll() : g_f = Empty
  If ResumePush Then  On Error Resume Next
    If IsDefined("main2") Then  Set g_f=CreateObject("Scripting.Dictionary") :_
      Set g_AppKey = new AppKeyClass : main2  g_f, g_AppKey.SetKey( new AppKeyClass )  Else _
      Set g_AppKey = new AppKeyClass : g_AppKey.SetKey( new AppKeyClass ) : main
  g_f = Empty : ResumePop : On Error GoTo 0
End If
'--- end of vbslib include --------------------------------------------------------


Sub main2( Opt, AppKey )
	Dim w_:Set w_= AppKey.NewWritable( Array( "out.vbs", "out.txt" ) ).Enable()

	'// Test Main
	Dim file : Set file = OpenForWrite( "out.vbs", Empty )
	WriteVBSLibHeader  file, Empty
	file.WriteLine  "Sub main2( Opt, AppKey )"
	file.WriteLine  "	echo ""OK"""
	file.WriteLine  "End Sub"
	WriteVBSLibFooter  file, Empty
	file = Empty

	'// Check
	RunProg  "cscript //nologo  out.vbs", "out.txt"
	Assert  ReadFile( "out.txt" ) = "OK"+ vbCRLF

	'// Clean
	del  "out.vbs"
	del  "out.txt"

	Pass
End Sub


 
