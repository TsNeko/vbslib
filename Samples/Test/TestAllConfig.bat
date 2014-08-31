@echo off

cscript Test.vbs /set_input:2.9. /Config:Debug   /CharCode:Unicode  /log:Test_logs_unicode_debug.txt
cscript Test.vbs /set_input:2.9. /Config:Release /CharCode:Unicode  /log:Test_logs_unicode_release.txt
cscript Test.vbs /set_input:2.9. /Config:Debug   /CharCode:ShiftJIS /log:Test_logs_shiftjis_debug.txt
cscript Test.vbs /set_input:2.9. /Config:Release /CharCode:ShiftJIS /log:Test_logs_shiftjis_release.txt
 
