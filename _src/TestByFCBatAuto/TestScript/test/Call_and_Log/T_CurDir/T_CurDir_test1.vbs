Sub  Test_main( param ) 
	Dim  f, line

	Set  f = g_fs.OpenTextFile( "data.txt" )

	line = f.ReadLine
	If line <> "hello" Then  Err.Raise &h80040001
	Pass
End Sub


 
