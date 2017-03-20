=== Example of Download Start ===

HelloWorld.bat バッチ ファイル をダブルクリックすることで、
ダウンロード＆実行のサンプルが動作します。

sclirptlib フォルダーに入っているような圧縮したスクリプトが共有フォルダーに
入っているとき、ローカルのテンポラリ フォルダーにコピー＆解凍＆実行することで、
実行が遅くならないようになります。

内部処理は以下の通りです。
・Main バッチは、scriptlib\Main.vbs と scriptlib\scriptlib.zip を 
	テンポラリ フォルダー\script-(vbsのタイムスタンプ) 
	にコピーして Main.vbs を起動します。
・Main.vbs の最後に書かれている最初に実行するコードは、
	scriptlib フォルダーがなければ scriptlib.zip を解凍し、
	vbslib include のコードは、通常どうり vbslib を include して、Main 関数を呼び出します。
・カレント フォルダーは、テンポラリ フォルダー\script-(vbsのタイムスタンプ) 、
	g_start_in_path の値は、Main バッチがあるフォルダー、
	g_vbslib_folder の値は、テンポラリ フォルダー\script-(vbsのタイムスタンプ) \scriptlib\
	になります。

共有フォルダーに配置するときは、バッチ ファイルの中の current 変数を
共有フォルダーのアドレス（UNC）に置き換えてください。
また、アドレスの最後に \ を付けてください。
