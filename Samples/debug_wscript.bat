REM === Attach to Just In Time debugger
REM   ���̃o�b�`�E�t�@�C�����_�u���N���b�N����ƁA�����̃t�H���_�[�ɂ��� .vbs �t�@�C���� wscript.exe �Ńf�o�b�O���܂��B
REM   .vbs �t�@�C�������̃o�b�`�t�@�C���Ƀh���b�O���h���b�v����ƁA���� .vbs �t�@�C���� wscript.exe �Ńf�o�b�O���܂��B

for %%i in (*.vbs) do set debug_script_path=%%i
if not "%~1"=="" for %%i in ("%~1") do cd "%%~di%%~pi" & set debug_script_path=%%~ni%%~xi

start "" wscript //x "%debug_script_path%"
