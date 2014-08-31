<<< _replica フォルダ >>>

_replica フォルダは、同じ内容であるべきファイルの同期をとる作業のフォルダです。


<<< 同期を取って全部テストを行う手順 >>>

・1 RunRepliCmp.vbs を実行して、レプリカを同期します。
  （参考：RepliCmp）
・2 Sync vbslib フォルダーの中で、テンプレートを同期します。
・3.Translate\Translate vbslib.vbs を実行して、英語版を作成します。
・ファイル構成が同じかチェックします。
  _src\TestByFCBatAuto\TestPrompt\Sample → sample\TestPrompt
     ただし、ルートの Test.vbs は削除、T_Sample_ans.txt の内容は異なる
  _src\TestByFCBatAuto\vbs_inc\sample → sample\vbs_inc
・..\TestALL.bat を実行します。
・ManualTest のテストシンボルを検索して、ドキュメントを参考に、手動テストをします。
・9 CleanBackup.vbs を実行します。
    ・Test_logs.txt ファイルと backup フォルダ _not_merged フォルダを削除します。
    ・Test_debugger.bat, Test_diff.bat ファイルも削除します。
・バージョン番号を更新します。vbslib_readme.txt, vbslib\!readme.txt, vbslib_manual.html
・Stop, g_debug=1, echo on を全文検索して削除します。debugger.bat を１箇所を除き削除します。

[DEBUGGING]