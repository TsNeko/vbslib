Dim g_fs : Set  g_fs = CreateObject( "Scripting.FileSystemObject" )
Dim g_sh : Set  g_sh = WScript.CreateObject( "WScript.Shell" )

g_sh.CurrentDirectory = g_fs.GetParentFolderName( WScript.ScriptFullName )

Dim r : r = g_sh.Popup( WScript.Arguments.Unnamed(0) + vbCRLF +"[OK]=すぐに行います、[キャンセル]=中止します", CInt( WScript.Arguments.Unnamed(2) ), WScript.Arguments.Unnamed(1), vbOKCancel or vbSystemModal )
Dim f : Set f = g_fs.CreateTextFile( g_fs.GetBaseName( WScript.ScriptName ) + "_out.txt", True, False )
f.WriteLine  r
 
