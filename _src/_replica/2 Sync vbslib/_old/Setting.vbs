'********************************************************************************
'  <<< [Setting_getMainSetting] >>>
'********************************************************************************
Sub  Setting_getMainSetting( g )

	'[Setting]
	'==============================================================================
	g("TargetFolderPath") = "..\..\.."
	g("FileNameMask")     = "*.vbs"
	g("StartTag")         = "vbslib - VBScript"
	g("FromFile")         = "_From.txt"
	g("ToFile")           = "_To.txt"
	g("ExceptFolder")     = Array(_
		".",_
		g("TargetFolderPath") +"\Samples\PartRep\PartRepSampleTarget",_
		g("TargetFolderPath") +"\_src\Test\vbslib_test\T_File\T_WriteVBSLibHeader" )
	'==============================================================================

End Sub


