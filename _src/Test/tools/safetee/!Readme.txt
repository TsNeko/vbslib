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

safetee �R�}���h�́Atee �R�}���h���g���������̂ł��B
safetee �́A�W���G���[�o�͂����_�C���N�g�ł��܂��B
safetee �փt�@�C�����h���b�O���h���b�v���Ă��A���̃t�@�C�����󂵂܂���B�itee �͉󂵂܂��j
safetee �́AWindows XP ���� Windows 7 �܂Ŏg���܂��B


((( �T���v�� )))

�W���o�͂��A�W���o�͂� file.txt �t�@�C���ɏo�͂��܂��B
  >program parameters | safetee -o file.txt

�W���o�͂��A�W���o�͂� file.txt �t�@�C���ɒǋL�o�͂��܂��B
  >program parameters | safetee -a file.txt

�W���o�͂ƕW���G���[�o�͂��A�W���o�͂� file.txt �t�@�C���ɏo�͂��܂��B
  >program parameters 2>&1 | safetee -o file.txt

�W���o�͂ƕW���G���[�o�͂��A�W���o�͂� file.txt �t�@�C���ɏo�͂��܂��B
�W���G���[�o�͂��A�W���G���[�o�͂� err.txt �t�@�C���ɏo�͂��܂��B
  >safetee -oe file.txt -e err.txt -cmd program parameters


((( �p�����[�^�[ )))

-o   : �W���o�͂��t�@�C���ɏo�͂��܂��B
-a   : �W���o�͂��t�@�C���ɒǋL�o�͂��܂��B
-e   : �W���G���[�o�͂��t�@�C���ɏo�͂��܂��B (-cmd �p�����[�^�[���K�v�ł�)
-ea  : �W���G���[�o�͂��t�@�C���ɒǋL�o�͂��܂��B (-cmd �p�����[�^�[���K�v�ł�)
-oe  : �W���o�͂ƕW���G���[�o�͂��t�@�C���ɏo�͂��܂��B (-cmd �p�����[�^�[���K�v�ł�)
-oea : �W���o�͂ƕW���G���[�o�͂��t�@�C���ɒǋL�o�͂��܂��B (-cmd �p�����[�^�[���K�v�ł�)
-cmd : �W���o�͂ƕW���G���[�o�͂����_�C���N�g�����R�}���h���C��
-h   : �w���v��\�����܂��B


safetee  ver1.00  Feb.28, 2010
Copyright (c) 2010, T's-Neko at Sage Plaisir 21 (Japan)
All rights reserved. Based on 3-clause BSD license.


���C�Z���X�F
�����ł��g�����������܂����A���ۏ؂ł��B
�ĔЕz�����쌠�\�����폜���Ȃ���Ύ��R�ɂł��܂��B

�T�|�[�g��F
�\�t�g�E�F�A�f�U�C���� Sage Plaisir 21  http://www.sage-p.com/

