Sub  Setting_getTemp( out_FolderPath, out_LimitDate ) 
	out_FolderPath = env( "%Temp%\Report\sub" )
	out_LimitDate = DateAdd( "s", -1, Now() )  '// "s" = second
End Sub


 
