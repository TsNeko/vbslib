<XML_Text>

Section: Test of T_FindMoved

VerX �� VerY �œ��������󋵂���n�߂�e�X�g�f�[�^�ł��B


Title: Test Case

- old_base: VerX\01\1_Synced.txt
- old_work: VerY\91\1_Synced.txt
- new_base: VerX\02\1_Synced.txt
- new_work: VerY\92\1_Synced.txt �c ���e��ύX����

<Answer  id="1_Synced"  cut_indent="yes"><![CDATA[
]]></Answer>


Title: Test Case

- old_base: VerX\01\A\2_Moved.txt
- old_work: VerY\91\A\2_Moved.txt
- new_base: VerX\02\B\2_Moved.txt �c �ړ�����
- new_work: VerY\92\A\2_Moved.txt

<Answer  id="2_Moved"  cut_indent="yes"><![CDATA[
-------------------------------------------------------------------------------
�x�[�X�́A"A" ���� "B" �Ɉړ������悤�ł��B
�ǉ�����^�O�F
    <Folder  synced_base="A" synced_path="A"  base="B"  path="A"/>
���[�N���ړ�������ǉ�����^�O�F
    <Folder  synced_base="A" synced_path="A"  base="B"  path="B"/>
-------------------------------------------------------------------------------
]]></Answer>


Title: Test Case

- old_base: VerX\01\E\F\3_NestMoved.txt
- old_work: VerY\91\E\F\3_NestMoved.txt
- new_base: VerX\02\E\F\3_NestMoved.txt
- new_work: VerY\92\G\F\3_NestMoved.txt �c �ړ�����

<Answer  id="3_NestMoved"  cut_indent="yes"><![CDATA[
-------------------------------------------------------------------------------
���[�N�́A"E" ���� "G" �Ɉړ������悤�ł��B
�ǉ�����^�O�F
    <Folder  synced_base="E" synced_path="E"  base="E"  path="G"/>
�x�[�X���ړ�������ǉ�����^�O�F
    <Folder  synced_base="E" synced_path="E"  base="G"  path="G"/>
-------------------------------------------------------------------------------
]]></Answer>


Title: Test Case

- old_base: VerX\01\H\A\4_MovedA.txt, 4_MovedB.txt
- old_work: VerY\91\H\B\4_MovedA.txt, 4_MovedB.txt
- new_base: VerX\02\H\C\4_MovedA.txt, 4_MovedB.txt �c �ړ�����
- new_work: VerY\92\H\C\4_MovedA.txt, 4_MovedB.txt �c �ړ�����

<Answer  id="4_MovedAB"  cut_indent="yes"><![CDATA[
-------------------------------------------------------------------------------
�x�[�X�́A"H\A" ���� "H\C" �Ɉړ������悤�ł��B
���[�N�́A"H\B" ���� "H\C" �Ɉړ������悤�ł��B
�ǉ�����^�O�F
    <Folder  synced_base="H\A" synced_path="H\B"  base="H\C"  path="H\C"/>
-------------------------------------------------------------------------------
]]></Answer>


</XML_Text>
