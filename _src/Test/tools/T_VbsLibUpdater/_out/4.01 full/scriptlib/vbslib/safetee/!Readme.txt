((( safetee )))

safetee command is extended from tee command.
safetee can redirect stderr.
safetee does not break the drag & dropped file. (tee breaks the drag & dropped file.)
safetee can use on Windows XP - Windows 7.


((( sample )))

Output stdout to stdout and file.txt
  >program parameters | safetee -o file.txt

Output stdout to stdout and appand to file.txt
  >program parameters | safetee -a file.txt

Output stdout and stderr to stdout and appand to file.txt
  >program parameters 2>&1 | safetee -o file.txt

Output stdout and stderr to stdout and stderr and file.txt and stderr to err.txt
  >safetee -oe file.txt -e err.txt -cmd program parameters


((( parameters )))

-o   : output stdout to file
-a   : append stdout to file
-e   : output stderr to file (need -cmd)
-ea  : append stderr to file (need -cmd)
-oe  : output stdout and stderr to file (need -cmd)
-oea : append stdout and stderr to file (need -cmd)
-cmd : command line redirected stdout and stderr
-h   : display help


safetee  ver1.00  Feb.28, 2010
Copyright (c) 2010, T's-Neko at Sage Plaisir 21 (Japan)
All rights reserved. Based on 3-clause BSD license.

Sofrware Design Gallery "Sage Plaisir 21"  http://www.sage-p.com/



----------------------------------------------------------------


((( safetee )))

safetee コマンドは、tee コマンドを拡張したものです。
safetee は、標準エラー出力もリダイレクトできます。
safetee へファイルをドラッグ＆ドロップしても、そのファイルを壊しません。（tee は壊します）
safetee は、Windows XP から Windows 7 まで使えます。


((( サンプル )))

標準出力を、標準出力と file.txt ファイルに出力します。
  >program parameters | safetee -o file.txt

標準出力を、標準出力と file.txt ファイルに追記出力します。
  >program parameters | safetee -a file.txt

標準出力と標準エラー出力を、標準出力と file.txt ファイルに出力します。
  >program parameters 2>&1 | safetee -o file.txt

標準出力と標準エラー出力を、標準出力と file.txt ファイルに出力します。
標準エラー出力を、標準エラー出力と err.txt ファイルに出力します。
  >safetee -oe file.txt -e err.txt -cmd program parameters


((( パラメーター )))

-o   : 標準出力をファイルに出力します。
-a   : 標準出力をファイルに追記出力します。
-e   : 標準エラー出力をファイルに出力します。 (-cmd パラメーターも必要です)
-ea  : 標準エラー出力をファイルに追記出力します。 (-cmd パラメーターも必要です)
-oe  : 標準出力と標準エラー出力をファイルに出力します。 (-cmd パラメーターも必要です)
-oea : 標準出力と標準エラー出力をファイルに追記出力します。 (-cmd パラメーターも必要です)
-cmd : 標準出力と標準エラー出力がリダイレクトされるコマンドライン
-h   : ヘルプを表示します。


safetee  ver1.00  Feb.28, 2010
Copyright (c) 2010, T's-Neko at Sage Plaisir 21 (Japan)
All rights reserved. Based on 3-clause BSD license.


ライセンス：
無料でお使いいただけますが、無保証です。
再頒布も著作権表示を削除しなければ自由にできます。

サポート先：
ソフトウェアデザイン館 Sage Plaisir 21  http://www.sage-p.com/

