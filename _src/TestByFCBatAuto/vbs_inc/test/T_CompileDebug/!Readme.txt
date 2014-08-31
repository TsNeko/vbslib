 ((( 名前が二重定義されているときのデバッグ支援 )))

*.vbs は、g_b_compile_debug = 1 を追加する前のケース。
*_step2.vbs は、g_b_compile_debug = 1 を追加した後のケース。
*_sub.vbs は、インクルードされるファイル。

T_CompileDebug1.vbs は、vbslib フォルダでインクルードするモジュールでエラーが出たとき。
T_CompileDebug2～6.vbs は、include "T_CompileDebug*_sub.vbs" でエラーが出たとき。
T_CompileDebug0_step2.vbs は、エラーが出なかったとき。


