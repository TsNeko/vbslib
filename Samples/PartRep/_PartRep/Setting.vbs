'********************************************************************************
'  <<< [Setting_getMainSetting] >>>
'********************************************************************************
Sub  Setting_getMainSetting( g )

	'[Setting]
	'==============================================================================
	g("TargetFolderPath") = "..\PartRepSampleTarget"
	g("FileNameMask")     = "*.vbs"
	g("StartTag")         = "-- start of " + "OLD vbslib include --"
	g("FromFile")         = "_From.txt"
	g("ToFile")           = "_To.txt"
	g("ExceptFolder")     = Array( "." )
	'==============================================================================

End Sub


