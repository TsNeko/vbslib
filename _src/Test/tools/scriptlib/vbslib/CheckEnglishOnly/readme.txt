 ((( CheckEnglishOnly )))

�e�L�X�g�t�@�C�����p�ꂾ���ɂȂ��Ă��邩�`�F�b�N���܂��B
�R�}���h�E�v�����v�g������s���Ă��������B

CheckEnglishOnly.exe /Folder:FolderA /Setting:Setting.ini

- Folder �I�v�V����
  ���ׂ�t�H���_�̃p�X

- Setting �I�v�V����
  �ݒ�t�@�C���̃p�X


�ݒ�t�@�C���̗�F Setting.ini
------------------------------------------------
[CheckEnglishOnlyExe]
ExceptFile = *.exe
ExceptFile = *.lib
ExceptFile = *.dll
------------------------------------------------
���΃p�X�̊�́A�ݒ�t�@�C��������t�H���_�[�ł��B


�o�̗͂�F
-------------------------------------------------------------
�e�L�X�g�t�@�C�����p�ꂾ���ɂȂ��Ă��邩�`�F�b�N���܂��B
�`�F�b�N����t�@�C���܂��̓t�H���_�[�̃p�X: TestData
�ݒ�t�@�C���̃p�X: TestData\SettingForCheckEnglish.ini

<FILE path="KanjiInUnicode.txt">
  <LINE num="2" text="����"/>
  <LINE num="4" text="�ł��B"/>
  <SUMMARY count="2"/>
</FILE>

<FILE path="SJisInAscii.txt">
  <LINE num="2" text="�V�t�gJIS"/>
  <LINE num="4" text="�ł��B"/>
  <SUMMARY count="2"/>
</FILE>
-------------------------------------------------------------
���΃p�X�̊�́A�ݒ�t�@�C��������t�H���_�[�ł��B
�������A/Setting �I�v�V�������Ȃ��Ƃ��́A�`�F�b�N����t�H���_�[�ł��B
