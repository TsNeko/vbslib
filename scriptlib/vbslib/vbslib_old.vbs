Option Explicit 

'// vbslib old interface

'// vbslib - VBScript ShortHand Library  ver4.91  Oct.13, 2014
'// vbslib is provided under 3-clause BSD license.
'// Copyright (C) 2007-2014 Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.

Dim  g_SrcPath
Dim  g_vbslib_old_Path
     g_vbslib_old_Path = g_SrcPath


 
'********************************************************************************
'  <<< [ChgToCommandPrompt] >>> 
'********************************************************************************
Sub  ChgToCommandPrompt()
	'// この関数を呼び出す必要はなくなりました。
End Sub


 
'********************************************************************************
'  <<< old I/F [echo_c] >>> 
'********************************************************************************
Function  echo_c( ByVal msg )
	ThisIsOldSpec  '// echo_v を使ってください
	echo_c = echo( msg )
End Function


 
'*************************************************************************
'  <<< [grep_old] >>> 
'*************************************************************************
Sub  grep_old( Keyword, FolderPath, OutFName, Opt )
	Dim  ds_:Set ds_= New CurDirStack : ErrCheck
	del  "_grep_out.txt"
	cd  FolderPath
	del  "_grep_out.txt"
	RunProg  "cmd /C for /R %i in (*) do find """ + Keyword + """ ""%i"" >> _grep_out.txt", ""
	ds_= Empty
	move   FolderPath + "\_grep_out.txt", "."
	If OutFName <> "_grep_out.txt" Then  ren "_grep_out.txt", OutFName
End Sub


 
'*************************************************************************
'  <<< [GetParentAbsPath] >>> 
'*************************************************************************
Function  GetParentAbsPath( Path )
	ThisIsOldSpec  '// GetParentFullPath を使ってください
	GetParentAbsPath = GetParentFullPath( Path )
End Function


 
'*************************************************************************
'  <<< [IsAbsPath] >>> 
'*************************************************************************
Function  IsAbsPath( Path )
	ThisIsOldSpec  '// IsFullPath を使ってください
	IsAbsPath = IsFullPath( Path )
End Function


 
'*************************************************************************
'  <<< [GetAbsPath] >>> 
'*************************************************************************
Function  GetAbsPath( StepPath, BasePath )
	ThisIsOldSpec  '// GetFullPath を使ってください
	GetAbsPath = GetFullPath( StepPath, BasePath )
End Function


 
'*************************************************************************
'  <<< [ConvertToAbsPath] >>> 
'*************************************************************************
Sub  ConvertToAbsPath( SrcFilePath, DstFilePath )
	ThisIsOldSpec  '// ConvertToFullPath を使ってください
	ConvertToFullPath  SrcFilePath, DstFilePath
End Sub


 
