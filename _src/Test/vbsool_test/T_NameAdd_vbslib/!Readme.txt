 ((( 名前参照を追加するサンプル )))


 ((( プログラムの説明 )))

ClassI class : インターフェイス
ClassN class : 一般名。オブジェクトA か B かは状況による
ClassA class : 正式名を持つオブジェクトA （ModuleAB.vbs にある）
ClassB class : 正式名を持つオブジェクトB （ModuleAB.vbs にある）
ClassC class : 正式名を持つオブジェクトC （後から追加する ModuleC.vbs にある）

確認内容
・後から追加したモジュールが、デフォルトを変更できること。
・後からモジュールを追加しても、追加する前のオブジェクトを取得できること。
・後からモジュールを追加しても、追加する前のデフォルトを取得できること。


後から、関数リダイレクトを含むモジュールを追加するときは、２つ include が必要です。
  include  "ModuleC_Pre.vbs"
  include  "ModuleC.vbs"


