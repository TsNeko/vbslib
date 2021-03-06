Option Explicit 

'***********************************************************************
'* VBScript ShortHand Library (vbslib)
'* vbslib is provided under 3-clause BSD license.
'* Copyright (C) Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.
'*
'* - $Version: vbslib 5.93 $
'* - $ModuleRevision: {vbslib}\Public\593 $
'* - $Date: 2017-03-20T20:00:00+09:00 $
'***********************************************************************

Dim  g_SrcPath
Dim  g_MergeLibPath
     g_MergeLibPath = g_SrcPath




 
'********************************************************************************
'  <<< [RunMergePrompt] >>> 
'********************************************************************************
Sub  RunMergePrompt( Pathes, Opt )
	Dim  status : Set status = new Merge_Status : ErrCheck
	Dim  i, src_path, dst_path
	Dim  base, ext, new_path

	For i=0 To UBound( Pathes )
		If IsEmpty( Pathes(i) ) Then  Err.Raise 1,,"Pathes("&i&") が設定されていません。"
		If not exist( Pathes(i) ) Then  Err.Raise 1,,"Pathes("&i&") = " + Pathes(i) + " が見つかりません。"
	Next

	base = g_fs.GetBaseName( Pathes(0) )
	ext = g_fs.GetExtensionName( Pathes(0) )
	If IsEmpty( Opt.m_NewPath ) Then  new_path = "New\" + base + "." + ext _
	Else  new_path = Opt.m_NewPath

	Do

		'//== 1 files
		If UBound( Pathes ) = 0 Then
			Redim  sub_pathes(0)

			If exist( new_path ) Then
				Do
					echo "-------------------------------------------"
					echo  base + "." + ext + " のコピーは完了しました。"
					echo  "5. コピー済みを開く"
					echo  "6. コピー済みフォルダを開く"
					echo  "8. 前のステップへ"
					echo  "9. 終了"
					i = CInt2( input("番号を入力してください。>") )
					echo "-------------------------------------------"
					If i = 9 Then  Exit Sub
					If i = 8 Then
						i = input( "前ステップに戻るため、" + new_path + " を削除します。[Y/N]" )
						If i = "y" or i = "Y" Then  del new_path : Exit Do
					End If
					If i = 5 Then  OpenMergePath  Opt.m_EditorPath, new_path
					If i = 6 Then  OpenMergePath  Opt.m_EditorPath, g_fs.GetParentFolderName( new_path )
				Loop
			Else
				sub_pathes(0) = Pathes(0)
				status.m_EditingNum = -1
				status.m_StepIDFilePath = Empty
				RunMergePromptSub  sub_pathes, status, Opt
				If status.m_bExit Then  Exit Sub
				If status.m_CopyNum = 1 Then
					src_path = Pathes(0) : dst_path = new_path
					copy_ren  src_path, dst_path
				End If
			End If


		'//== 2 files
		ElseIf UBound( Pathes ) = 1 Then

			status.m_CurrentStep = 1
			status.m_LastStep = 1

			Do

				'//== 2 files Step A
				If not exist( new_path ) and _
					 not exist( "Editing\" + base + "(1)M." + ext ) Then
					Redim  sub_pathes(1)
					sub_pathes(0) = Pathes(0)
					sub_pathes(1) = Pathes(1)
					status.m_EditingNum = 0
					status.m_StepIDFilePath = Empty


					RunMergePromptSub  sub_pathes, status, Opt
					If status.m_bExit Then  Exit Sub


					Select Case  status.m_CopyNum
						Case 1
							src_path = Pathes(0) : dst_path = "Editing\" + base + "(1)M." + ext
							copy_ren  src_path, dst_path
						Case 2
							src_path = Pathes(1) : dst_path = "Editing\" + base + "(1)M." + ext
							copy_ren  src_path, dst_path
					End Select


				'//== 2 files Step B
				ElseIf not exist( new_path ) Then
					Redim  sub_pathes(2)
					sub_pathes(0) = Pathes(0)
					sub_pathes(1) = "Editing\" + base + "(1)M." + ext
					sub_pathes(2) = Pathes(1)
					status.m_EditingNum = 2
					status.m_StepIDFilePath = sub_pathes(1)


					RunMergePromptSub  sub_pathes, status, Opt
					If status.m_bExit Then  Exit Sub


					If exist( sub_pathes(1) ) Then
						src_path = sub_pathes(1) : dst_path = new_path
						copy_ren  src_path, dst_path
						Exit Do
					End If


				'//== 2 files complated
				Else
					Do
						echo "-------------------------------------------"
						echo  base + "." + ext + " のマージは完了しました。"
						echo  "5. マージ済みを開く"
						echo  "6. マージ済みフォルダを開く"
						If not IsEmpty( Opt.m_SyncPathes ) Then _
							echo  "7. 同じ名前のファイルをすべてマージ済みに更新する"
						echo  "8. 前のステップへ"
						echo  "9. 終了"
						i = CInt2( input("番号を入力してください。>") )
						echo "-------------------------------------------"
						If i = 9 Then  Exit Sub
						If i = 8 Then
							i = input( "前ステップに戻るため、" + new_path + " を削除します。[Y/N]" )
							If i = "y" or i = "Y" Then  del new_path : Exit Do
						End If
						If i = 5 Then  OpenMergePath  Opt.m_EditorPath, new_path
						If i = 6 Then  OpenMergePath  Opt.m_EditorPath, g_fs.GetParentFolderName( new_path )
						If i = 7 and (not IsEmpty(Opt.m_SyncPathes)) Then  RunMergeUpdate  new_path, Pathes, Opt
					Loop
				End If
			Loop


		'//== N files
		Else

			status.m_LastStep = UBound( Pathes ) - 1


			'//== N files merged
			If exist( new_path ) Then
				Do
					echo "-------------------------------------------"
					echo  base + "." + ext + " のマージは完了しました。"
					echo  "5. マージ済みを開く"
					echo  "6. マージ済みフォルダを開く"
					If not IsEmpty( Opt.m_SyncPathes ) Then _
						echo  "7. すべてのファイルをマージ済みに更新する"
					echo  "8. 前のステップへ"
					echo  "9. 終了"
					i = CInt2( input("番号を入力してください。>") )
					echo "-------------------------------------------"
					If i = 9 Then  Exit Sub
					If i = 8 Then
						i = input( "前ステップに戻るため、" + new_path + " を削除します。[Y/N]" )
						If i = "y" or i = "Y" Then  del new_path : Exit Do
					End If
					If i = 5 Then  OpenMergePath  Opt.m_EditorPath, new_path
					If i = 6 Then  OpenMergePath  Opt.m_EditorPath, g_fs.GetParentFolderName( new_path )
					If i = 7 and (not IsEmpty(Opt.m_SyncPathes)) Then  RunMergeUpdate  new_path, Pathes, Opt
				Loop
				del  new_path
			End If


			'//== Count step by counting file exists
			status.m_StepIDFilePath = Empty
			status.m_EditingNum = 0
			For i = UBound( Pathes ) To 1 Step -1
				If exist( "Editing\" + base + "(" & i & ")L." + ext ) Then
					status.m_StepIDFilePath = "Editing\" + base + "(" & i & ")L." + ext
					status.m_EditingNum = 1 : Exit For
				ElseIf exist( "Editing\" + base + "(" & i & ")M." + ext ) Then
					status.m_StepIDFilePath = "Editing\" + base + "(" & i & ")M." + ext
					status.m_EditingNum = 2 : Exit For
				ElseIf exist( "Editing\" + base + "(" & i & ")R." + ext ) Then
					status.m_StepIDFilePath = "Editing\" + base + "(" & i & ")R." + ext
					status.m_EditingNum = 3 : Exit For
				ElseIf exist( "Editing\" + base + "(" & i & ")." + ext ) Then
					status.m_StepIDFilePath = "Editing\" + base + "(" & i & ")." + ext
					status.m_EditingNum = 0 : Exit For
			 End If
			Next
			If i = 0 Then  status.m_CurrentStep = 1 _
			Else           status.m_CurrentStep = i


			'//== N files Step A
			Redim  sub_pathes(2)
			If status.m_EditingNum = 0 Then
				If status.m_CurrentStep = 1 Then
					sub_pathes(0) = Pathes(1)
					sub_pathes(1) = Pathes(0)
					sub_pathes(2) = Pathes(2)
				Else
					sub_pathes(0) = "Editing\" + base + _
						"(" & status.m_CurrentStep & ")." + ext
					sub_pathes(1) = Pathes(0)
					sub_pathes(2) = Pathes( status.m_CurrentStep + 1 )
				End If


				RunMergePromptSub  sub_pathes, status, Opt
				If status.m_bExit Then  Exit Sub


				Select Case  status.m_CopyNum
					Case 1
						src_path = sub_pathes(0) : dst_path = "Editing\" + base + "(" & status.m_CurrentStep & ")L." + ext
						copy_ren  src_path, dst_path
					Case 2
						src_path = sub_pathes(1) : dst_path = "Editing\" + base + "(" & status.m_CurrentStep & ")M." + ext
						copy_ren  src_path, dst_path
					Case 3
						src_path = sub_pathes(2) : dst_path = "Editing\" + base + "(" & status.m_CurrentStep & ")R." + ext
						copy_ren  src_path, dst_path
				End Select


			'//== N files Step B
			Else
				If status.m_EditingNum = 1 Then
					sub_pathes(0) = "Editing\" + base + "(" & status.m_CurrentStep & ")L." + ext
				ElseIf status.m_CurrentStep = 1 Then
					sub_pathes(0) = Pathes(1)
				Else
					sub_pathes(0) = "Editing\" + base + "(" & status.m_CurrentStep & ")." + ext
				End If
				If status.m_EditingNum = 2 Then
					sub_pathes(1) = "Editing\" + base + "(" & status.m_CurrentStep & ")M." + ext
				Else
					sub_pathes(1) = Pathes(0)
				End If
				If status.m_EditingNum = 3 Then
					sub_pathes(2) = "Editing\" + base + "(" & status.m_CurrentStep & ")R." + ext
				Else
					sub_pathes(2) = Pathes( status.m_CurrentStep + 1 )
				End If


				RunMergePromptSub  sub_pathes, status, Opt
				If status.m_bExit Then  Exit Sub


				If status.m_CopyNum <> 0 Then
					If status.m_CurrentStep = status.m_LastStep Then
						Select Case  status.m_EditingNum
							Case 1
								src_path = "Editing\" + base + "(" & status.m_CurrentStep & ")L." + ext : dst_path = new_path
								copy_ren  src_path, dst_path
							Case 2
								src_path = "Editing\" + base + "(" & status.m_CurrentStep & ")M." + ext : dst_path = new_path
								copy_ren  src_path, dst_path
							Case 3
								src_path = "Editing\" + base + "(" & status.m_CurrentStep & ")R." + ext : dst_path = new_path
								copy_ren  src_path, dst_path
						End Select
					Else
						Select Case  status.m_EditingNum
							Case 1
								src_path = "Editing\" + base + "(" & status.m_CurrentStep & ")L." + ext
								dst_path = "Editing\" + base + "(" & (status.m_CurrentStep+1) & ")." + ext
								copy_ren  src_path, dst_path
							Case 2
								src_path = "Editing\" + base + "(" & status.m_CurrentStep & ")M." + ext
								dst_path = "Editing\" + base + "(" & (status.m_CurrentStep+1) & ")." + ext
								copy_ren  src_path, dst_path
							Case 3
								src_path = "Editing\" + base + "(" & status.m_CurrentStep & ")R." + ext
								dst_path = "Editing\" + base + "(" & (status.m_CurrentStep+1) & ")." + ext
								copy_ren  src_path, dst_path
						End Select
					End If
				End If
			End IF
		End IF
	Loop
End Sub


 
'********************************************************************************
'  <<< [RunMergePromptSub] >>> 
'********************************************************************************
Sub  RunMergePromptSub( SubPathes, Status, Opt )
	Dim  i, s, i0,i1,i2

	Status.m_CopyNum = 0

	If UBound( SubPathes ) > 1 Then
		Select Case  Status.m_EditingNum
			Case 1    : i0=0 : i1=2 : i2=1
			Case 3    : i0=1 : i1=0 : i2=2
			Case Else : i0=0 : i1=1 : i2=2
		End Select
	Else
		i0=0 : i1=1
	End If

 Do
	echo "-------------------------------------------"
	Select Case  Status.m_EditingNum
		Case -1: echo "ファイルをコピーしてください"
		Case 0 : echo "編集が開始できるようにコピーするファイルを選択してください"
		Case 1 : echo "左と中の差分を、右のファイルに反映させてください"
		Case 2 : echo "中央のファイルを編集してください"
		Case 3 : echo "右と中の差分を、左のファイルに反映させてください"
	End Select
	If Status.m_EditingNum <> -1 Then
		If Status.m_EditingNum = 0 Then  i = "A"  Else  i = "B"
		echo "マージ・ステップ " & Status.m_CurrentStep & i & "/" & Status.m_LastStep & "B"
	End IF

	If UBound( SubPathes ) = 0 Then
		echo "4. 開く: "+SubPathes(0)
	ElseIf UBound( SubPathes ) = 1 Then
		echo "1. Diff ツール起動"
		echo "4. 左を開く: "+SubPathes(0)
		echo "6. 右を開く: "+SubPathes(1)
	Else
		echo "1. Diff ツール起動"

		If i0=1 Then  s="(old)"  Else  s=""
		If Status.m_EditingNum=1 Then s="(edit)"
		echo "4. 左を開く"+s+": "+SubPathes(i0)

		If i1=1 Then  s="(old)"  Else  s=""
		If Status.m_EditingNum=2 Then s="(edit)"
		echo "5. 中を開く"+s+": "+SubPathes(i1)

		If i2=1 Then  s="(old)"  Else  s=""
		If Status.m_EditingNum=3 Then s="(edit)"
		echo "6. 右を開く"+s+": "+SubPathes(i2)
	End If
	Select Case  Status.m_EditingNum
		Case -1: echo "7. New フォルダへコピー"
		Case 0 : echo "7. Editing フォルダへコピー（次のステップへ）"
		Case 1 : echo "7. 左の編集を完了して、次のステップへ"
		Case 2 : echo "7. 中央の編集を完了して、次のステップへ"
		Case 3 : echo "7. 右の編集を完了して、次のステップへ"
	End Select
	If not IsEmpty( Status.m_StepIDFilePath ) Then _
		echo  "8. 前のステップへ"
	echo "9. 終了"

	i = CInt2( input("番号を入力してください。>") )
	echo "-------------------------------------------"

	Select Case  i
	 Case 1
		If UBound( SubPathes ) > 0 Then
			echo "Starting Diff tool : " + Opt.m_DiffPath
			If UBound( SubPathes ) = 1 Then
				g_sh.Run  GetDiffCmdLine( SubPathes(i0), SubPathes(i1) )
			Else
				g_sh.Run  GetDiffCmdLine3( SubPathes(i0), SubPathes(i1), SubPathes(i2) )
			End If
			echo "-------------------------------------------"
		End If
	 Case 4
		g_sh.Run  GetEditorCmdLine( SubPathes(i0) )
	 Case 5
		If UBound( SubPathes ) >= 2 Then _
			g_sh.Run """"+Opt.m_EditorPath+""" """+SubPathes(i1)+""""
	 Case 6
		If UBound( SubPathes ) = 1 Then
			g_sh.Run """"+Opt.m_EditorPath+""" """+SubPathes(i1)+""""
		ElseIf UBound( SubPathes ) = 2 Then
			g_sh.Run """"+Opt.m_EditorPath+""" """+SubPathes(i2)+""""
		End If
	 Case 7
		If Status.m_EditingNum <> 0 Then  Status.m_CopyNum = 1 : Exit Sub
		Do
			echo "Editing フォルダへコピー（次のステップへ）"
			If UBound( SubPathes ) >= 2 Then
				echo "4. 左をコピーして、中と右の表示を入れ替える"
				echo "5. 中をコピー"
				echo "6. 右をコピーして、左と中の表示を入れ替える"
			Else
				echo "4. 左をコピーして、中央に追加する"
				echo "6. 右をコピーして、中央に追加する"
			End If
			echo "8. 戻る"
			i = CInt2( input("番号を入力してください。>") )
			echo "-------------------------------------------"
			Select Case  i
			 Case 4 : Status.m_CopyNum = 1 : Exit Sub
			 Case 5 : If UBound( SubPathes ) >= 2 Then  Status.m_CopyNum = 2 : Exit Sub
			 Case 6 : If UBound( SubPathes ) >= 2 Then  Status.m_CopyNum = 3 : Exit Sub _
								Else                              Status.m_CopyNum = 2 : Exit Sub
			 Case 8 : Exit Do
			End Select
		Loop
	 Case 8
		If not IsEmpty( Status.m_StepIDFilePath ) Then
			i = input( "前ステップに戻るため、" + Status.m_StepIDFilePath + " を削除します。[Y/N]" )
			If i = "y" or i = "Y" Then  del Status.m_StepIDFilePath : Status.m_CopyNum = 0 : Exit Sub
		End If
	 Case 9
		Status.m_bExit = True : Exit Sub
	End Select
 Loop
End Sub


 
'********************************************************************************
'  <<< [GetMergeStep] >>> 
'********************************************************************************
Function  GetMergeStep( Pathes, Opt )
	Dim  i
	Dim  base, ext, new_path

	If UBound( Pathes ) = -1 Then  GetMergeStep = "Empty" : Exit Function
	base = g_fs.GetBaseName( Pathes(0) )
	ext = g_fs.GetExtensionName( Pathes(0) )
	If IsEmpty( Opt.m_NewPath ) Then  new_path = "New\" + base + "." + ext _
	Else  new_path = Opt.m_NewPath


	If exist( new_path ) Then  GetMergeStep = "Fin" : Exit Function


	'//== 2 files
	If UBound( Pathes ) = 1 Then

		If exist( "Editing\" + base + "(1)M." + ext ) Then  GetMergeStep = "1B" : Exit Function
		GetMergeStep = "1A"


	'//== N files
	Else
		For i = UBound( Pathes ) To 1 Step -1
			If exist( "Editing\" + base + "(" & i & ")L." + ext ) Then
				GetMergeStep = i & "B" : Exit Function
			ElseIf exist( "Editing\" + base + "(" & i & ")M." + ext ) Then
				GetMergeStep = i & "B" : Exit Function
			ElseIf exist( "Editing\" + base + "(" & i & ")R." + ext ) Then
				GetMergeStep = i & "B" : Exit Function
			ElseIf exist( "Editing\" + base + "(" & i & ")." + ext ) Then
				GetMergeStep = i & "A" : Exit Function
			End If
		Next
		GetMergeStep = "1A"
	End If

End Function



 
'********************************************************************************
'  <<< [OpenMergePath] >>> 
'********************************************************************************
Sub  OpenMergePath( EditorPath, OpenPath )
	echo  "Open """ + OpenPath + """"
	If g_fs.FileExists( OpenPath ) Then
		g_sh.Run """"+EditorPath+""" """+OpenPath+""""
	ElseIf g_fs.FolderExists( OpenPath ) Then
		g_sh.Run """"+OpenPath+""""
	Else
		Dim  path

		echo """" + OpenPath + """ が見つかりません"
		path = OpenPath
		Do
			path = g_fs.GetParentFolderName( path )
			If path = "" Then  Exit Sub
			If g_fs.FolderExists( path ) Then
				 echo """" + path + """ を代わりに開きます"
				g_sh.Run """"+path+""""
				Exit Sub
			End If
		Loop
	End If
End Sub

 
'********************************************************************************
'  <<< [RunMergeUpdate] >>> 
'********************************************************************************
Sub  RunMergeUpdate( NewPath, Pathes, Opt )
	Dim  i,n

	n = 0
	If not IsEmpty( Opt ) Then
		If not IsEmpty( Opt.m_SyncPathes ) Then  n = UBound( Opt.m_SyncPathes )
	End If

	ReDim  pathes2( UBound( Pathes ) + 1 + n )

	For i=0 To UBound( Pathes )
		pathes2( i ) = Pathes( i )
	Next
	For i=0 To n
		pathes2( UBound( Pathes ) + 1 + i ) = Opt.m_SyncPathes( i )
	Next

	RunMergeUpdateSub  NewPath, pathes2, Opt
End Sub


Sub  RunMergeUpdateSub( NewPath, Pathes, Opt )
	Dim  i, ec
	ReDim  b_equal( UBound( Pathes ) )


	echo "[MergeUpdate]"

	'//=== Compare file with New file
	For i = 0 To UBound( Pathes )
		Set ec = new EchoOff
		b_equal( i ) = fc_r( NewPath, Pathes( i ), Empty )
		ec = Empty
		If not b_equal( i ) Then  echo Pathes(i)
	Next


	'//=== Run confirm prompt
	i = input( "以上のファイルを更新しますか [Y/N]" )
	If i <> "Y" and i <> "y" Then Exit Sub


	'//=== Do merge update
	Dim  backup_base, path, j

	For i = 0 To UBound( Pathes )
		If not b_equal( i ) Then
			backup_base = g_fs.GetParentFolderName( Pathes(i) )
			backup_base = backup_base + "\backup\" + _
										g_fs.GetBaseName( Pathes(i) ) + " ("
			For j=1 To 9999
				path = backup_base & j & ")." & g_fs.GetExtensionName( Pathes(i) )
				If not exist( path ) Then
					copy_ren  Pathes(i), path
					copy_ren  NewPath, Pathes(i)
					j=0 : Exit For
				End If
			Next
			If j<>0 Then  Err.Raise 1,,"Cannot write """ + path + """"
		End If
	Next

End Sub

 
'*-------------------------------------------------------------------------*
'* ◆<<<< [Merge_Option] Class >>>> */ 
'*-------------------------------------------------------------------------*


Class  Merge_Option
	Public  m_EditorPath
	Public  m_DiffPath
	Public  m_NewPath
	Public  m_SyncPathes  ' as array of string, or Empty
End Class



 
'*-------------------------------------------------------------------------*
'* ◆<<<< [Merge_Status] Class >>>> */ 
'*-------------------------------------------------------------------------*


Class  Merge_Status
	Public  m_CurrentStep
	Public  m_LastStep
	Public  m_CopyNum
	Public  m_bExit
	Public  m_EditingNum
	Public  m_StepIDFilePath
End Class



 
'********************************************************************************
'  <<< [RunMergeRepPrompt] >>> 
'********************************************************************************
Sub  RunMergeRepPrompt( OldPath, NewPath, PatchFolderPath, OldPatchStepPath, NewPatchStepPath, Opt )
	Dim  src_path, dst_path
	Dim  status : Set status = new MergeRep_Status : ErrCheck

	If OldPatchStepPath = g_fs.GetAbsolutePathName( OldPatchStepPath ) or _
		 Left( OldPatchStepPath, 2 ) = ".." Then
		Err.Raise 1,,"OldPatchStepPath needs step path and not parent path : " + OldPatchStepPath
	End If
	If NewPatchStepPath = g_fs.GetAbsolutePathName( NewPatchStepPath ) or _
		 Left( NewPatchStepPath, 2 ) = ".." Then
		Err.Raise 1,,"NewPatchStepPath needs step path and not parent path : " + NewPatchStepPath
	End If

	status.m_PatchFolderPath = PatchFolderPath
	status.m_OldPatchStepPath = OldPatchStepPath
	status.m_NewPatchStepPath = NewPatchStepPath
	status.m_OldPatchPath = PatchFolderPath + "\" + OldPatchStepPath

 Do
	GetMergeRepStep  status

	If status.m_CurrentStep = "Fin" Then
		Do
			echo "-------------------------------------------"
			echo  status.m_OldPatchStepPath + " のマージは完了しました。"
			echo  "5. マージ済みを開く"
			echo  "6. マージ済みフォルダを開く"
			echo  "8. 前のステップへ"
			echo  "9. 終了"
			i = CInt2( input("番号を入力してください。>") )
			echo "-------------------------------------------"
			If i=9 Then Exit Sub
			If i=8 Then
				i = input( "前ステップに戻るため、" + status.m_NewPatchPath + " を削除します。[Y/N]" )
				If i = "y" or i = "Y" Then  del status.m_NewPatchPath : Exit Do
			End If
			If i=5 Then  OpenMergePath  Opt.m_EditorPath, status.m_NewPatchPath
			If i=6 Then  OpenMergePath  Opt.m_EditorPath, g_fs.GetParentFolderName( status.m_NewPatchPath )
		Loop
		GetMergeRepStep  status
	End If

	echo "-------------------------------------------"
	echo "マージ・ステップ " & status.m_CurrentStep & "/2"
	If g_fs.FileExists( NewPath ) Then  echo "1. Diff  OldPatch, OldOrg, NewOrg"
	echo "2. OldPatch を開く: " + status.m_OldPatchPath
	If status.m_CurrentStep <> "1" Then
		echo "3. NewPatch を開く: " + status.m_NewPatchPath
	End If
	If status.m_CurrentStep <> "1" Then
		If g_fs.FileExists( status.m_NewPatchPath ) Then
			echo "4. Diff  OldPatch, NewPatch, NewOrg"
		End If
	End If
	If exist( OldPath ) Then  echo "5. OldOrg を開く: " + OldPath _
	Else                      echo "5. OldOrg は存在しません: " + OldPath
	If exist( NewPath ) Then  echo "6. NewOrg を開く: " + NewPath _
	Else                      echo "6. NewOrg は存在しません: " + NewPath
	Select Case  status.m_CurrentStep
		Case "1" : echo "7. OldPatch を Editing フォルダへコピーして編集開始（次のステップへ）"
		Case "2" : echo "7. NewPatch を New フォルダへコピーして完了"
	End Select
	If status.m_CurrentStep <> "1" Then _
		echo  "8. 前のステップへ"
	echo "9. 終了"

	i = CInt2( input("番号を入力してください。>") )
	echo "-------------------------------------------"

	Select Case  i
	 Case 1 :
		If g_fs.FileExists( NewPath ) Then
			echo "Starting Diff tool : " + Opt.m_DiffPath
			g_sh.Run """"+Opt.m_DiffPath+""" """+status.m_OldPatchPath+""" """+OldPath+""" """+NewPath+""""
		End If
	 Case 2 : OpenMergePath  Opt.m_EditorPath, status.m_OldPatchPath
	 Case 3 : If status.m_CurrentStep <> "1" Then _
						OpenMergePath  Opt.m_EditorPath, status.m_NewPatchPath

	 Case 4:
		If status.m_CurrentStep <> "1" Then
			If g_fs.FileExists( status.m_NewPatchPath ) Then
				echo "Starting Diff tool : " + Opt.m_DiffPath
				g_sh.Run """"+Opt.m_DiffPath+""" """+status.m_OldPatchPath+""" """+status.m_NewPatchPath+""" """+NewPath+""""
			End If
		End If
	 Case 5 : OpenMergePath  Opt.m_EditorPath, OldPath
	 Case 6 : OpenMergePath  Opt.m_EditorPath, NewPath

	 Case 7
		Select Case  status.m_CurrentStep
		 Case "1"
			src_path = status.m_OldPatchPath : dst_path = "Editing\" + status.m_NewPatchStepPath
			If g_fs.FolderExists( src_path ) Then  src_path = src_path + "\*"
			copy_ren  src_path, dst_path
		 Case "2"
			src_path = status.m_NewPatchPath : dst_path = "New\" + status.m_NewPatchStepPath
			If g_fs.FolderExists( src_path ) Then  src_path = src_path + "\*"
			copy_ren  src_path, dst_path
		End Select

	 Case 8
		If not IsEmpty( status.m_NewPatchPath ) Then
			i = input( "前ステップに戻るため、" + status.m_NewPatchPath + " を削除します。[Y/N]" )
			If i = "y" or i = "Y" Then  del status.m_NewPatchPath
		End If
	 Case 9 : Exit Sub
	End Select
 Loop
End Sub


 
'********************************************************************************
'  <<< [GetMergeRepStep] >>> 
'[argument]
'- Status as MergeRep_Status
'- (In)  Status.m_PatchFolderPath, Status.m_NewPatchStepPath
'- (Out) Status.m_CurrentStep and Status.m_NewPatchPath
'********************************************************************************
Sub  GetMergeRepStep( Status )
	Dim  path

	path = "New\" + Status.m_NewPatchStepPath
	If exist( path ) Then
		Status.m_NewPatchPath = path : Status.m_CurrentStep = "Fin" : Exit Sub
	End If

	path = "Editing\" + Status.m_NewPatchStepPath
	If exist( path ) Then
		Status.m_NewPatchPath = path : Status.m_CurrentStep = CStr( 2 ) : Exit Sub
	End If

	Status.m_NewPatchPath = Empty : Status.m_CurrentStep = CStr( 1 )
End Sub




 
'*-------------------------------------------------------------------------*
'* ◆<<<< [MergeRep_Status] Class >>>> */ 
'*-------------------------------------------------------------------------*


Class  MergeRep_Status
	Public  m_PatchFolderPath
	Public  m_OldPatchStepPath
	Public  m_NewPatchStepPath

	Public  m_OldPatchPath
	Public  m_NewPatchPath

	Public  m_CurrentStep
End Class



 
'*-------------------------------------------------------------------------*
'* ◆<<<< [PatchFiles] Class >>>> */ 
'*-------------------------------------------------------------------------*

Class  PatchFiles
	Public  m_MergeOption     ' as Merge_Option
	Public  m_OldFolderPath   ' as string
	Public  m_OldFolderPath2  ' as string
	Public  m_PatchFolderPath ' as string
	Public  m_NewFolderPath   ' as string
	Public  m_Items()        ' as array of PatchFile
	Public  m_RenamedFrom()  ' as array of string. step path
	Public  m_RenamedTo()    ' as array of string. step path
	Public  m_IDefault

	Public  m_PatchFileType  '//Const
	Public  m_ReplaceType    '//Const

	Private Sub Class_Initialize
		Me.m_PatchFileType = 1
		Me.m_ReplaceType = 2
		ReDim  m_Items(-1)
		ReDim  m_RenamedFrom(-1)
		ReDim  m_RenamedTo(-1)
		g_sh.CurrentDirectory = g_fs.GetParentFolderName( WScript.ScriptFullName )
	End Sub

	Public Sub  AddPatchFile( StepPath )
		Dim item : Set item = new PatchFile : ErrCheck

		With  item
			Set .m_Parent = Me
			.m_Type = Me.m_PatchFileType
			.m_StepPath = StepPath
		End With

		ReDim Preserve  m_Items( UBound( m_Items ) + 1 )
		Set  m_Items( UBound( m_Items ) ) = item
	End Sub

	Public Sub  AddReplace( OldStepPath, NewStepPath, PatchStepPath )
		Dim item : Set item = New ReplaceFile

		With  item
			Set .m_Parent = Me
			.m_Type = Me.m_ReplaceType
			.m_OldStepPath = OldStepPath
			.m_NewStepPath = NewStepPath
			.m_StepPath = PatchStepPath
		End With

		ReDim Preserve  m_Items( UBound( m_Items ) + 1 )
		Set  m_Items( UBound( m_Items ) ) = item
	End Sub

	Public Sub  AddRenamed( OldStepPath, NewStepPath )
		ReDim Preserve  m_RenamedFrom( UBound( m_RenamedFrom ) + 1 )
		m_RenamedFrom( UBound( m_RenamedFrom ) ) = OldStepPath

		ReDim Preserve  m_RenamedTo( UBound( m_RenamedTo ) + 1 )
		m_RenamedTo( UBound( m_RenamedTo ) ) = NewStepPath
	End Sub

	Public Function  GetRenamedPath( ByVal path )
		Dim  i

		For i = 0 To  UBound( Me.m_RenamedFrom )
			If Me.m_RenamedFrom(i) = Left( path, Len(Me.m_RenamedFrom(i)) ) Then
				path = Me.m_RenamedTo(i) + Mid( path, Len(Me.m_RenamedFrom(i)) + 1 )
				Exit For
			End If
		Next
		GetRenamedPath = path
	End Function

	Public Sub  EchoSteps()
		Dim  step_, i
		echo  "[Update_Merge_Steps]"
		Me.m_IDefault = Empty
		For i=0 To UBound( Me.m_Items )
			step_ = Me.m_Items(i).GetStep() : If step_<>"Fin" and IsEmpty(Me.m_IDefault) Then  Me.m_IDefault = i
			echo  (i+1) & ") Step=" & step_ & " : " + Me.m_Items(i).m_StepPath
		Next
		If IsEmpty( Me.m_IDefault ) Then
			echo  "All items are Finished."
		Else
			If UBound( Me.m_Items ) > 10 Then
				i = Me.m_IDefault
				step_ = Me.m_Items(i).GetStep()
				echo  "0) Step=" & step_ & " : " + Me.m_Items(i).m_StepPath
			End If
		End If
	End Sub

	Public Sub  RunMergePrompt()
		Dim  i
		g_CUI.SetAutoKeysFromMainArg
		Do
			Me.EchoSteps
			echo "-1) exit"
			i = CInt2( input( "マージするファイルの番号を入力してください>" ) )
			If i = -1 Then Exit Sub
			echo "-------------------------------------------"
			If i = 0 and ( not IsEmpty( Me.m_IDefault ) )  Then  i = Me.m_IDefault + 1
			If i <= UBound( Me.m_Items )+1 Then  Me.m_Items(i-1).RunMergePromptMe
		Loop
	End Sub
End Class


 
'*-------------------------------------------------------------------------*
'* ◆<<<< [PatchFile] Class >>>> */ 
'*-------------------------------------------------------------------------*

Class  PatchFile
	Public  m_Parent ' as PatchFiles
	Public  m_Type  '// PatchFiles::m_PatchFileType

	Public  m_StepPath

	Public Sub  RunMergePromptMe()
		Dim  pathes()
		Me_SetupParams  pathes
		RunMergePrompt  pathes, m_Parent.m_MergeOption
	End Sub

	Public  Function  GetStep()
		Dim  pathes()
		Me_SetupParams  pathes
		GetStep = GetMergeStep( pathes, m_Parent.m_MergeOption )
	End Function

	Private Sub  Me_SetupParams( pathes )
		Dim    i, path
		Redim  pathes(2)

		i = 0

		'//=== Old
		path = Me.m_Parent.m_OldFolderPath   + "\" + Me.m_StepPath
		If exist( path ) Then
			pathes(i) = path : i=i+1
		ElseIf not IsEmpty( Me.m_Parent.m_OldFolderPath2 ) Then
			path = Me.m_Parent.m_OldFolderPath2+ "\" + Me.m_StepPath
			If exist( path ) Then  pathes(i) = path : i=i+1
		End If

		'//=== Patch
		path = Me.m_Parent.m_PatchFolderPath + "\" + Me.m_StepPath
		If exist( path ) Then  pathes(i) = path : i=i+1


		'//=== New
		path = Me.m_Parent.m_NewFolderPath   + "\" + Me.m_StepPath
		path = Me.m_Parent.GetRenamedPath( path )
		If exist( path ) Then  pathes(i) = path : i=i+1
		Redim Preserve  pathes(i-1)


		'//=== Fin
		Me.m_Parent.m_MergeOption.m_NewPath = "New\" + Me.m_StepPath
	End Sub

End Class


 
'*-------------------------------------------------------------------------*
'* ◆<<<< [ReplaceFile] Class >>>> */ 
'*-------------------------------------------------------------------------*

Class  ReplaceFile
	Public  m_Parent ' as PatchFiles
	Public  m_Type  '// PatchFiles::m_ReplaceType

	Public  m_StepPath  '// PatchPath
	Public  m_OldStepPath
	Public  m_NewStepPath

	Public Sub  RunMergePromptMe()
		RunMergeRepPrompt _
			Me.m_Parent.m_OldFolderPath + "\" + m_OldStepPath, _
			Me.m_Parent.m_NewFolderPath + "\" + Me.m_Parent.GetRenamedPath( m_NewStepPath ), _
			Me.m_Parent.m_PatchFolderPath, _
			m_StepPath, _
			Me.m_Parent.GetRenamedPath( m_StepPath ), _
			Me.m_Parent.m_MergeOption
	End Sub

	Public  Function  GetStep()
		Dim status : Set status = new MergeRep_Status : ErrCheck
		status.m_PatchFolderPath = Me.m_Parent.m_PatchFolderPath
		status.m_NewPatchStepPath = Me.m_Parent.GetRenamedPath( m_StepPath )
		GetMergeRepStep  status
		GetStep = status.m_CurrentStep
	End Function

End Class

 
'*-------------------------------------------------------------------------*
'* ◆<<<< [SyncFiles] Class >>>> */ 
'*-------------------------------------------------------------------------*

Class  SyncFiles
	Public  m_MergeOption  ' as Merge_Option
	Public  m_Items()   ' as array of SyncFile
	Public  m_SubCount  ' as integer
	Public  m_IDefault

	Private Sub Class_Initialize
		ReDim  m_Items(-1)
		Me.m_SubCount = 0
		g_sh.CurrentDirectory = g_fs.GetParentFolderName( WScript.ScriptFullName )
	End Sub

	Public Sub  NextSyncFile()
		Me.m_SubCount = 0
	End Sub

	Public Sub  AddRepliFile( Path )
		Dim item : Set item = AddFileSub( Path )
		item.AddFile  Path
	End Sub

	Public Sub  AddSameFile( Path )
		Dim item : Set item = AddFileSub( Path )
		item.AddSameFile  Path
	End Sub

	Private Function  AddFileSub( Path )
		Dim  item

		If Me.m_SubCount = 0 Then
			Set item = new SyncFile : ErrCheck
			ReDim Preserve  m_Items( UBound( m_Items ) + 1 )
			Set  m_Items( UBound( m_Items ) ) = item

			Set item.m_Parent = Me
			item.m_Name = g_fs.GetFileName( Path )
		Else
			Set item = m_Items( UBound( m_Items ) )
		End If
		Me.m_SubCount = Me.m_SubCount + 1

		Set AddFileSub = item
	End Function

	Public Sub  EchoSteps()
		Dim  step_,  i
		echo  "[Sync_Merge_Steps]"
		Me.m_IDefault = Empty
		For i=0 To UBound( Me.m_Items )
			step_ = Me.m_Items(i).GetStep() : If step_<>"Fin" and IsEmpty(Me.m_IDefault) Then  Me.m_IDefault = i
			echo  (i+1) & ") Step=" & step_ + " : " + Me.m_Items(i).m_Name
		Next
		If IsEmpty( Me.m_IDefault ) Then
			echo  "All items are Finished."
		Else
			If UBound( Me.m_Items ) > 10 Then
				i = Me.m_IDefault
				step_ = Me.m_Items(i).GetStep()
				echo  "0) Step=" & step_ + " : " + Me.m_Items(i).m_Name
			End If
		End If
	End Sub

	Public Sub  RunMergePrompt()
		Dim  i

		g_CUI.SetAutoKeysFromMainArg
		Do
			echo "-------------------------------------------"
			Me.EchoSteps
			echo "-1) exit"
			i = CInt2( input( "マージするファイルの番号を入力してください>" ) )
			If i = -1 Then Exit Sub
			If i = 0 and ( not IsEmpty( Me.m_IDefault ) )  Then  i = Me.m_IDefault + 1
			If i <= UBound( Me.m_Items )+1 Then  Me.m_Items(i-1).RunMergePromptMe
		Loop
	End Sub
End Class



 
'*-------------------------------------------------------------------------*
'* ◆<<<< [SyncFile] Class >>>> */ 
'*-------------------------------------------------------------------------*

Class  SyncFile
	Public  m_Parent  ' as SyncFiles
	Public  m_Name    ' as string
	Public  m_FilePathes()  ' as array of string
	Public  m_SameFilePathes()  ' as array of string

	Private Sub Class_Initialize
		ReDim  m_FilePathes(-1)
		ReDim  m_SameFilePathes(-1)
	End Sub

	Public Sub  AddFile( Path )
		ReDim Preserve  m_FilePathes( UBound( m_FilePathes ) + 1 )
		m_FilePathes( UBound( m_FilePathes ) ) = Path
	End Sub

	Public Sub  AddSameFile( Path )
		ReDim Preserve  m_SameFilePathes( UBound( m_SameFilePathes ) + 1 )
		m_SameFilePathes( UBound( m_SameFilePathes ) ) = Path
	End Sub

	Public Sub  RunMergePromptMe()
		Me.m_Parent.m_MergeOption.m_NewPath = Empty
		Me.m_Parent.m_MergeOption.m_SyncPathes = m_SameFilePathes
		RunMergePrompt  m_FilePathes, Me.m_Parent.m_MergeOption
	End Sub

	Public  Function  GetStep()
		Me.m_Parent.m_MergeOption.m_NewPath = Empty
		GetStep = GetMergeStep( Me.m_FilePathes, Me.m_Parent.m_MergeOption )
	End Function
End Class


 
