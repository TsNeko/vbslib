Dim  g_SrcPath 
Dim  g_TestPrompt_Setting_Path
     g_TestPrompt_Setting_Path = g_SrcPath


Sub  Setting_buildTestPrompt( prompt ) '// prompt as TestPrompt
	Dim t
	Dim tests
	Dim fo

	Set tests = prompt.m_Tests

	prompt.ReDimMenu  11
	prompt.m_Menu(1).m_Caption = "1. テスト内容を選ぶ"
	prompt.m_Menu(2).m_Caption = "2. テストを開始する（3～7を実行する）"
	prompt.m_Menu(3).m_Caption = "3. | サブ・フォルダーを含めて、Test_build 関数を呼び出す"
	prompt.m_Menu(4).m_Caption = "4. | サブ・フォルダーを含めて、Test_setup 関数を呼び出す"
	prompt.m_Menu(5).m_Caption = "5. | サブ・フォルダーを含めて、Test_start 関数を呼び出す"
	prompt.m_Menu(6).m_Caption = "6. | サブ・フォルダーを含めて、Test_check 関数を呼び出す"
	prompt.m_Menu(7).m_Caption = "7. | サブ・フォルダーを含めて、Test_clean 関数を呼び出す"
	prompt.m_Menu(8).m_Caption = "8. デバッグ・モードを変更する"
	prompt.m_Menu(9).m_Caption = "88.Fail したフォルダーを開く"
	prompt.m_Menu(10).m_Caption= "89.次に Fail したフォルダーを開く"
	prompt.m_Menu(11).m_Caption= "9. 終了"

	prompt.m_Menu(9).m_Number = 88
	prompt.m_Menu(10).m_Number = 89
	prompt.m_Menu(11).m_Number = 9

	prompt.m_Menu(1).m_OpType = prompt.Op_SelectTest
	prompt.m_Menu(2).m_OpType = prompt.Op_AllTest
	prompt.m_Menu(3).m_OpType = prompt.Op_EachTest
	prompt.m_Menu(3).m_OpParam = "Test_build"
	prompt.m_Menu(4).m_OpType = prompt.Op_EachTest
	prompt.m_Menu(4).m_OpParam = "Test_setup"
	prompt.m_Menu(5).m_OpType = prompt.Op_EachTest
	prompt.m_Menu(5).m_OpParam = "Test_start"
	prompt.m_Menu(6).m_OpType = prompt.Op_EachTestR
	prompt.m_Menu(6).m_OpParam = "Test_check"
	prompt.m_Menu(7).m_OpType = prompt.Op_EachTestR
	prompt.m_Menu(7).m_OpParam = "Test_clean"
	prompt.m_Menu(8).m_OpType = prompt.Op_Debug
	prompt.m_Menu(9).m_OpType = prompt.Op_OpenFail
	prompt.m_Menu(10).m_OpType = prompt.Op_NextFail
	prompt.m_Menu(11).m_OpType = prompt.Op_Exit

	tests.AddTestScriptAuto  tests.BaseFolderPath, prompt.TestScriptFileName
End Sub


 
