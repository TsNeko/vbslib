Set  g_sh = WScript.CreateObject( "WScript.Shell" )

Do

msg = " にファイアウォールがネットワークアクセスの許可を与えているかどうかチェックします。"+vbCRLF+_
	"続行するには "
msg2 = " を押してください . . ."

If LCase( Right( WScript.FullName, 11 ) ) = "wscript.exe" Then
	enter = "OK"
	script = "wscript.exe"
	other_script = "cscript.exe"
	If MsgBox( "Microsoft (R) Windows Based Script ("+ script +")"+ msg + enter + msg2, vbOKCancel ) = vbCancel Then  WScript.Quit  0
Else
	enter = "Enter キー"
	script = "cscript.exe"
	other_script = "wscript.exe"
	WScript.Echo  "Microsoft (R) Console Based Script ("+ script +")"+ msg + enter + msg2
	Wscript.StdIn.ReadLine
End If

Set http = WScript.CreateObject( "MSXML2.XMLHTTP" )  '// from Internet Explorer 6
http.Open  "GET", "http://www.yahoo.co.jp/index.html", False

On Error Resume Next
en = Err.Number : ed = Err.Description : On Error GoTo 0
If en = &h800C0005 Then
	msg = script +" のネットワークアクセスは  『禁止』 されています。"
ElseIf en = 0 Then
	msg = script +" のネットワークアクセスは  『許可』 されています。"
Else
	msg = "エラー ("& en &") "& ed
End If

msg = msg +vbCRLF+vbCRLF+ "1) もう一度設定を確認する"+vbCRLF+_
		"2) "+ other_script +" の設定も確認する"+vbCRLF+_
		"3) 終了する"+vbCRLF

Do
	If LCase( Right( WScript.FullName, 11 ) ) = "wscript.exe" Then
		in_data = InputBox( msg )
	Else
		Wscript.StdOut.Write  msg +"番号を入力してください >"
		in_data = Wscript.StdIn.ReadLine()
		Wscript.StdOut.Write  vbCRLF
	End If

	If IsNumeric( in_data ) Then
		Select Case  in_data
		 Case 1
			Exit Do
		 Case 2
			g_sh.Run  other_script +" """+ WScript.ScriptFullName +""""
		 WScript.Quit  0
		 Case 3
			WScript.Quit  0
		End Select
	End If
Loop

Loop

 
