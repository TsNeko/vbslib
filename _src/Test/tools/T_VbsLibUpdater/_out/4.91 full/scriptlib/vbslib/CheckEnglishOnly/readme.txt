 ((( CheckEnglishOnly )))

テキストファイルが英語だけになっているかチェックします。
コマンド・プロンプトから実行してください。

CheckEnglishOnly.exe /Folder:FolderA /Setting:Setting.ini

- Folder オプション
  調べるフォルダのパス

- Setting オプション
  設定ファイルのパス


設定ファイルの例： Setting.ini
------------------------------------------------
[CheckEnglishOnlyExe]
ExceptFile = *.exe
ExceptFile = *.lib
ExceptFile = *.dll
------------------------------------------------


出力の例：
-------------------------------------------------------------
テキストファイルが英語だけになっているかチェックします。
チェックするファイルまたはフォルダーのパス: TestData
設定ファイルのパス: TestData\SettingForCheckEnglish.ini

<FILE path="TestData\KanjiInUnicode.txt">
  <LINE num="2" text="漢字"/>
  <LINE num="4" text="です。"/>
  <SUMMARY count="2"/>
</FILE>

<FILE path="TestData\SJisInAscii.txt">
  <LINE num="2" text="シフトJIS"/>
  <LINE num="4" text="です。"/>
  <SUMMARY count="2"/>
</FILE>
-------------------------------------------------------------

