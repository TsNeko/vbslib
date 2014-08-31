#!/bin/bash -eEx

"ls" "."
'ls' '.'
var=`ls`

var="a
b"

var='a
b'

var=`a
b`

 echo  "ファイルまたはフォルダーが見つかりません。" >&2
