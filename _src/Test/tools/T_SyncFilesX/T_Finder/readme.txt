<XML_Text>

Section: Test of T_FindMoved

VerX と VerY で同期した状況から始めるテストデータです。


Title: Test Case

- old_base: VerX\01\1_Synced.txt
- old_work: VerY\91\1_Synced.txt
- new_base: VerX\02\1_Synced.txt
- new_work: VerY\92\1_Synced.txt … 内容を変更した

<Answer  id="1_Synced"  cut_indent="yes"><![CDATA[
]]></Answer>


Title: Test Case

- old_base: VerX\01\A\2_Moved.txt
- old_work: VerY\91\A\2_Moved.txt
- new_base: VerX\02\B\2_Moved.txt … 移動した
- new_work: VerY\92\A\2_Moved.txt

<Answer  id="2_Moved"  cut_indent="yes"><![CDATA[
-------------------------------------------------------------------------------
ベースは、"A" から "B" に移動したようです。
追加するタグ：
    <Folder  synced_base="A" synced_path="A"  base="B"  path="A"/>
ワークも移動したら追加するタグ：
    <Folder  synced_base="A" synced_path="A"  base="B"  path="B"/>
-------------------------------------------------------------------------------
]]></Answer>


Title: Test Case

- old_base: VerX\01\E\F\3_NestMoved.txt
- old_work: VerY\91\E\F\3_NestMoved.txt
- new_base: VerX\02\E\F\3_NestMoved.txt
- new_work: VerY\92\G\F\3_NestMoved.txt … 移動した

<Answer  id="3_NestMoved"  cut_indent="yes"><![CDATA[
-------------------------------------------------------------------------------
ワークは、"E" から "G" に移動したようです。
追加するタグ：
    <Folder  synced_base="E" synced_path="E"  base="E"  path="G"/>
ベースも移動したら追加するタグ：
    <Folder  synced_base="E" synced_path="E"  base="G"  path="G"/>
-------------------------------------------------------------------------------
]]></Answer>


Title: Test Case

- old_base: VerX\01\H\A\4_MovedA.txt, 4_MovedB.txt
- old_work: VerY\91\H\B\4_MovedA.txt, 4_MovedB.txt
- new_base: VerX\02\H\C\4_MovedA.txt, 4_MovedB.txt … 移動した
- new_work: VerY\92\H\C\4_MovedA.txt, 4_MovedB.txt … 移動した

<Answer  id="4_MovedAB"  cut_indent="yes"><![CDATA[
-------------------------------------------------------------------------------
ベースは、"H\A" から "H\C" に移動したようです。
ワークは、"H\B" から "H\C" に移動したようです。
追加するタグ：
    <Folder  synced_base="H\A" synced_path="H\B"  base="H\C"  path="H\C"/>
-------------------------------------------------------------------------------
]]></Answer>


</XML_Text>
