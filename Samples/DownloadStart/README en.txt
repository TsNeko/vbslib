=== Example of Download Start ===

By double clicking the "HelloWorld.bat" batch file,
this sample will download & execute.

When the compressed script that is in the sclirptlib folder is in the shared folder,
copying & decompressing & executing it to the local temporary folder will not make
the execution slow.

Internal processing is as follows.
- The Main batch copies "scriptlib\Main.vbs" and "scriptlib\scriptlib.zip" to
	"(temporary folder)\script-(time stamp of vbs)" and starts "Main.vbs".
- The first code to be executed at the end of Main.vbs decompresses
	"scriptlib.zip" if there is no "scriptlib" folder, vbslib include code
	normally includes vbslib and calls the "Main" function.
- The current folder is a "(temporary folder)\script-(timestamp of vbs)",
	the value of "g_start_in_path" is the folder with the "Main" batch,
	the value of "g_vbslib_folder" is "(temporary folder)\script-(time stamp of vbs)\scriptlib\".

To place it in a shared folder, replace the current variable in the batch file
with the address (UNC) of the shared folder.
Also, please add \ at the end of the address.
