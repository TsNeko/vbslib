 ((( sudo.exe Application )))

Call CreateProcess Win32 API with requireAdministrator.
sudo.exe waits for finish a child process in batch file.
IShellDispatch2::ShellExecute Verb="RunAs" is not waiting for.

This is free soft for Windows Vista/7.

If sudo.exe itself is not reliable, delete sudo.exe.


>echo test > C:\echo_out.txt
Access denied (fail)


>sudo.exe cmd /c "echo test > C:\echo_out.txt"
(success, if you accepted UAC prompt)


*WARNING*
Accept UAC prompt only after starting install or update by the reliable program.
Select "refuse" once, if UAC prompt was appeared SUDDENLY.



sudo.exe �́A�o�b�`�t�@�C���Ȃǂ��w�Ǘ��҂Ƃ��Ď��s����x�Ƃ��Ɏg���܂��B

�����Asudo.exe ���̂��M���ł��Ȃ��Ȃ�Asudo.exe ���폜���Ă��������B

*�x��*
���[�U�[�A�J�E���g����(UAC)�̃E�B���h�E�ŋ����Ă����̂́A�M���̂�����
�v���O��������C���X�g�[����A�b�v�f�[�g���J�n�������ゾ���ł��B
���[�U�[�A�J�E���g����̃E�B���h�E���ˑR�A���ꂽ��A��x�͋��ۂ��܂��傤�B

------------------------------------------------------------------
T's-Neko    http://www.sage-p.com/

