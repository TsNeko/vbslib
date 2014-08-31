 ((( PartCmp/PartRep )))

PartCmp : テキストファイルの一部が同じかどうか比較します。
PartRep : テキストファイルの一部を置き換えます。

詳しくは、..\RepliCmp\RepliCmp.svg#PartCmp を参照してください。
テスト： ..\..\_src\Test\tools\PartRep\T_PartRep\T_PartRepSample


 ((( サンプルを試す )))

まず、PartRepSampleTarget.zip を解凍して、
PartRepSampleTarget フォルダーの内容を戻してください。

_PartRep\PartCmp.vbs をダブルクリックすると、"." フォルダー（Readme.txt があるフォルダー）
の中の、すべての *.vbs ファイルの中の、"-- start of vbslib include --" がある行から
始まる複数行が、_PartRep\_To.txt の内容と一致しているかどうかをチェックします。
（これらの設定値は、_PartRep\Setting.vbs に記述されています。）
チェックすると、一致していない部分があるため、エラーになります。

_PartRep\PartRep.vbs をダブルクリックすると、"." フォルダー（Readme.txt があるフォルダー）
の中の、すべての *.vbs ファイルの中の、_PartRep\_From.txt の内容と一致している部分を、
_PartRep\_To.txt の内容に置き換えます。

もう一度、_PartRep\PartCmp.vbs をダブルクリックして、すべてのファイルの一部が、
_PartRep\_To.txt の内容に一致していることを確認します。

PartRepSampleTarget.zip を解凍して、
PartRepSampleTarget フォルダーの内容を戻してください。


 ((( 使い方 )))

_PartRep フォルダーを、処理を行うフォルダーにコピーします。

Setting.vbs をテキスト・エディターで開いて、
比較する複数行の先頭の行の一部にある文字列を、g("StartTag") の値に設定します。

複数行の正しい内容（置き換えた後の内容）を g("ToFile") の値のファイルに記述します。

PartCmp.vbs をダブルクリックすると、g("ToFile") の値のファイルの内容にマッチしない
ファイルのパスが、「違いあり: 」の後に表示されます。
すべてマッチしたら、Pass と表示されます。

置き換える前の内容（マッチしなかったファイルの内容）を g("FromFile") の値に記述し、
PartRep.vbs をダブルクリックすると、g("FromFile") のファイルの内容に一致したファイル
のパスが一覧されます。
そのまま [Y] を押すと、g("FromFile") に一致する部分が g("ToFile") に置き換わります。


