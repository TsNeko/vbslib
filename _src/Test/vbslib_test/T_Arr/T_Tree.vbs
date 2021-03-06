Sub  Main( Opt, AppKey )
	Set o = new InputCommandOpt
		Set o.CommandReplace = Dict(Array(_
			"1","T_TreeA_1", _
			"2","T_BreadthFirstSearch", _
			"3","T_DepthFirstSearch", _
			"4","T_GraphVertexClass", _
			"5","T_SearchSubGraphs" ))
	InputCommand  o, Empty, Opt, AppKey
End Sub


 
'*************************************************************************
'  <<< [T_TreeA_1] >>> 
'*************************************************************************
Sub  T_TreeA_1( Opt, AppKey )
	g_DestroyCount = 0

	Set tree = new TreeA_Class
	echo_str = GetEchoStr( tree ) : echo  "" : echo  echo_str
	Assert  echo_str = _
		"  <TreeA_NodeClass>Nothing</TreeA_NodeClass>"

	Set tree_item = new_NameOnlyClass( "Root", new DestroyCountClass )
	Set tree.Item = tree_item
	Assert  tree.Item  is  tree_item  '// Test of get property
	tree_item = Empty
	echo_str = GetEchoStr( tree ) : echo  "" : echo  echo_str
	Assert  echo_str = _
		"  <TreeA_NodeClass><NameOnlyClass Name='Root'/></TreeA_NodeClass>"


	'// Add first node
	Set node1 = tree.AddNewNode( Nothing )
	echo_str = GetEchoStr( tree ) : echo  "" : echo  echo_str
	Assert  echo_str = _
		"  <TreeA_NodeClass><NameOnlyClass Name='Root'/>"+ vbCRLF +_
		"    <TreeA_NodeClass>Nothing</TreeA_NodeClass>"+ vbCRLF +_
		"  </TreeA_NodeClass>"

	Set node1.Item = new_NameOnlyClass( "1", new DestroyCountClass )
	echo_str = GetEchoStr( tree ) : echo  "" : echo  echo_str
	Assert  echo_str = _
		"  <TreeA_NodeClass><NameOnlyClass Name='Root'/>"+ vbCRLF +_
		"    <TreeA_NodeClass><NameOnlyClass Name='1'/></TreeA_NodeClass>"+ vbCRLF +_
		"  </TreeA_NodeClass>"


	'// Add nodes
	Set node2 = tree.AddNewNode( new_NameOnlyClass( "2", new DestroyCountClass ) )
	Set node11 = node1.AddNewNode( new_NameOnlyClass( "11", new DestroyCountClass ) )
	Set node12 = node1.AddNewNode( new_NameOnlyClass( "12", new DestroyCountClass ) )
	Set node3 = tree.AddNewNode( new_NameOnlyClass( "3", new DestroyCountClass ) )
	Set node31 = node3.AddNewNode( new_NameOnlyClass( "31", new DestroyCountClass ) )
	echo_str = GetEchoStr( tree ) : echo  "" : echo  echo_str
	Assert  echo_str = _
		"  <TreeA_NodeClass><NameOnlyClass Name='Root'/>"+ vbCRLF +_
		"    <TreeA_NodeClass><NameOnlyClass Name='1'/>"+ vbCRLF +_
		"      <TreeA_NodeClass><NameOnlyClass Name='11'/></TreeA_NodeClass>"+ vbCRLF +_
		"      <TreeA_NodeClass><NameOnlyClass Name='12'/></TreeA_NodeClass>"+ vbCRLF +_
		"    </TreeA_NodeClass>"+ vbCRLF +_
		"    <TreeA_NodeClass><NameOnlyClass Name='2'/></TreeA_NodeClass>"+ vbCRLF +_
		"    <TreeA_NodeClass><NameOnlyClass Name='3'/>"+ vbCRLF +_
		"      <TreeA_NodeClass><NameOnlyClass Name='31'/></TreeA_NodeClass>"+ vbCRLF +_
		"    </TreeA_NodeClass>"+ vbCRLF +_
		"  </TreeA_NodeClass>"


	'// Check "ParentItems"
	items = node31.ParentItems
	echo_str = GetEchoStr( items ) : echo  "" : echo  echo_str
	items = Empty
	Assert  echo_str = _
		"<Array ubound=""1"">"+ vbCRLF +_
		"  <Item id=""0""><NameOnlyClass Name='3'/></Item>"+ vbCRLF +_
		"  <Item id=""1""><NameOnlyClass Name='Root'/></Item>"+ vbCRLF +_
		"</Array>"


	'// Check "ChildItems"
	items = tree.ChildItems
	echo_str = GetEchoStr( items ) : echo  "" : echo  echo_str
	items = Empty
	Assert  echo_str = _
		"<Array ubound=""6"">"+ vbCRLF +_
		"  <Item id=""0""><NameOnlyClass Name='11'/></Item>"+ vbCRLF +_
		"  <Item id=""1""><NameOnlyClass Name='12'/></Item>"+ vbCRLF +_
		"  <Item id=""2""><NameOnlyClass Name='1'/></Item>"+ vbCRLF +_
		"  <Item id=""3""><NameOnlyClass Name='2'/></Item>"+ vbCRLF +_
		"  <Item id=""4""><NameOnlyClass Name='31'/></Item>"+ vbCRLF +_
		"  <Item id=""5""><NameOnlyClass Name='3'/></Item>"+ vbCRLF +_
		"  <Item id=""6""><NameOnlyClass Name='Root'/></Item>"+ vbCRLF +_
		"</Array>"


	'// Check "g_DestroyCount"
	echo  "g_DestroyCount = " & g_DestroyCount
	Assert  g_DestroyCount = 0

	tree = Empty

	echo  "g_DestroyCount = " & g_DestroyCount
	Assert  g_DestroyCount = 7


	'// Add mutual linked nodes
	g_DestroyCount = 0

	Set tree = new_TreeA_Class( new TreeA_TestItemClass )
	Set tree.Item.TreeNode = tree.TreeNode  '// Don't set "tree"
	tree.Item.LoadNested  2

	echo_str = GetEchoStr( tree ) : echo  "" : echo  echo_str
	Assert  echo_str = _
		"  <TreeA_NodeClass>2"+ vbCRLF +_
		"    <TreeA_NodeClass>1"+ vbCRLF +_
		"      <TreeA_NodeClass>0</TreeA_NodeClass>"+ vbCRLF +_
		"    </TreeA_NodeClass>"+ vbCRLF +_
		"  </TreeA_NodeClass>"

	tree = Empty

	echo  "g_DestroyCount = " & g_DestroyCount
	Assert  g_DestroyCount = 3


	Pass
End Sub


 
'*************************************************************************
'  <<< [TreeA_TestItemClass] >>> 
'*************************************************************************
Class  TreeA_TestItemClass
	Public  TreeNode
	Public  Level

	Sub Class_Terminate()
		g_DestroyCount = g_DestroyCount + 1
	End Sub

	Sub  LoadNested( in_Level )
		Me.Level = in_Level

		If in_Level = 0 Then  Exit Sub
		in_Level = in_Level - 1

		Set child_item = new TreeA_TestItemClass
		Set child_item.TreeNode = Me.TreeNode.AddNewNode( child_item )
		child_item.LoadNested  in_Level
	End Sub

	Public Function  xml_sub( in_Level )
		xml_sub = Me.Level & vbCRLF
	End Function
End Class


 
'***********************************************************************
'* Function: T_BreadthFirstSearch
'***********************************************************************
Sub  T_BreadthFirstSearch( Opt, AppKey )

	For Each  is_mutual  In  Array( False, True )

		'// Set up
		ReDim  an_array( 11 )
		ReDim  parent_indexes( 11 )
		For Each  t  In DicTable( Array( _
			"VertexID",  "AdjacentIndexes",  "ParentIndex",  Empty, _
			100,  Array( 1, 2, 3 ),  Null, _
			101,  Array( 4, 5 ),  0, _
			102,  Array( ),  0, _
			103,  Array( 6, 7 ),  0, _
			104,  Array( 8, 9 ),  1, _
			105,  Array( ),  1, _
			106,  Array( 10, 11 ),  3, _
			107,  Array( ),  3, _
			108,  Array( ),  4, _
			109,  Array( ),  4, _
			110,  Array( ),  6, _
			111,  Array( ),  6 ) )

			i = t("VertexID") - 100
			Set an_array(i) = new GraphVertexClass
			an_array(i).Item = t("VertexID")
			an_array(i).AdjacentIndexes = t("AdjacentIndexes")
			parent_indexes(i) = t("ParentIndex")
		Next

		If is_mutual Then
			an_array(4).AdjacentIndexes = Array( 8, 9, 6 )
			an_array(11).AdjacentIndexes = Array( 0, 1 )
		End If


		'// Test Main
		BreadthFirstSearch  an_array, 0, queued, Empty, Empty, Empty


		'// Check
		Assert  UBound( queued ) = 11
		For i=0 To 11
			Assert  queued(i) = i
			Assert  an_array( queued(i) ).Item - 100 = i

			If IsNull( parent_indexes(i) ) Then
				Assert  IsNull( an_array( queued(i) ).ParentIndex )
			Else
				Assert  an_array( queued(i) ).ParentIndex = parent_indexes( queued(i) )
			End If
		Next
	Next


	For Each  is_mutual  In  Array( False, True )

		'// Set up
		ReDim  an_array( 11 )
		ReDim  parent_indexes( 11 )
		For Each  t  In DicTable( Array( _
			"VertexID",  "AdjacentIndexes",  "ParentIndex",  Empty, _
			100,  Array( 1, 6, 7 ),  Null, _
			101,  Array( 2, 5 ),  0, _
			102,  Array( 3, 4 ),  1, _
			103,  Array( ),  2, _
			104,  Array( ),  2, _
			105,  Array( ),  1, _
			106,  Array( ),  0, _
			107,  Array( 8, 11 ),  0, _
			108,  Array( 9, 10 ),  7, _
			109,  Array( ),  8, _
			110,  Array( ),  8, _
			111,  Array( ),  7 ) )

			i = t("VertexID") - 100
			Set an_array(i) = new GraphVertexClass
			an_array(i).Item = t("VertexID")
			an_array(i).AdjacentIndexes = t("AdjacentIndexes")
			parent_indexes(i) = t("ParentIndex")
		Next

		If is_mutual Then
			an_array(4).AdjacentIndexes = Array( 2, 3 )
			an_array(11).AdjacentIndexes = Array( 0 )
		End If


		'// Test Main
		BreadthFirstSearch  an_array, 0, queued, Empty, Empty, Empty


		'// Check
		Assert  UBound( queued ) = 11
		answer_indexes = Array( 0, 1, 6, 7, 2, 5, 8, 11, 3, 4, 9, 10 )
		For i=0 To 11
			Assert  queued(i) = answer_indexes(i)
			Assert  an_array( queued(i) ).Item - 100 = answer_indexes(i)

			If i = 0 Then
				Assert  IsNull( an_array( queued(i) ).ParentIndex )
			Else
				Assert  an_array( queued(i) ).ParentIndex = parent_indexes( queued(i) )
			End If
		Next


		'// Test Main : First index was changed
		BreadthFirstSearch  an_array, 1, queued, Empty, Empty, Empty


		'// Check
		Assert  UBound( queued ) = 4
		answer_indexes = Array( 1, 2, 5, 3, 4 )
		For i=0 To 4
			Assert  queued(i) = answer_indexes(i)
			Assert  an_array( queued(i) ).Item - 100 = answer_indexes(i)

			If i = 0 Then
				Assert  IsNull( an_array( queued(i) ).ParentIndex )
			Else
				Assert  an_array( queued(i) ).ParentIndex = parent_indexes( queued(i) )
			End If
		Next


		'// Test Main : Compare function was changed
		BreadthFirstSearch  an_array, 0, queued, GetRef("T_BreadthFirstSearch_Compare"), 201, Empty


		'// Check
		Assert  UBound( queued ) = 7
		answer_indexes = Array( 0, 1, 6, 7, 2, 5, 8, 11 )
		For i=0 To 7
			Assert  queued(i) = answer_indexes(i)
			Assert  an_array( queued(i) ).Item - 100 = answer_indexes(i)

			If i = 0 Then
				Assert  IsNull( an_array( queued(i) ).ParentIndex )
			Else
				Assert  an_array( queued(i) ).ParentIndex = parent_indexes( queued(i) )
			End If
		Next
	Next

	Pass
End Sub


 
'***********************************************************************
'* Function: T_BreadthFirstSearch_Compare
'***********************************************************************
Function  T_BreadthFirstSearch_Compare( in_ParentVertex, in_CurrentVertex, in_Parameter )
	Assert  in_Parameter = 201

	If in_CurrentVertex.Item - 100 = 2 Then
		T_BreadthFirstSearch_Compare = 0
	Else
		T_BreadthFirstSearch_Compare = 1
	End If
End Function


 
'***********************************************************************
'* Function: T_DepthFirstSearch
'***********************************************************************
Sub  T_DepthFirstSearch( Opt, AppKey )
	Set self = new T_DepthFirstSearchClass

	For Each  is_mutual  In  Array( False, True )

		'// Set up
		ReDim  an_array( 11 )
		ReDim  parent_indexes( 11 )
		ReDim  dictances( 11 )
		For Each  t  In DicTable( Array( _
			"VertexID",  "AdjacentIndexes",  "ParentIndex",  "ParentIndex2",  "Distance",  "Distance2",  Empty, _
			100,  Array( 1, 2, 3 ),  Null, Null, 0, 0, _
			101,  Array( 4, 5 ),     0,    0,    1, 1, _
			102,  Array( ),          0,    0,    1, 1, _
			103,  Array( 6, 7 ),     0,    0,    1, 1, _
			104,  Array( 8, 9 ),     1,    1,    2, 2, _
			105,  Array( ),          1,    1,    2, 2, _
			106,  Array( 10, 11 ),   3,    4,    2, 3, _
			107,  Array( ),          3,    3,    2, 2, _
			108,  Array( ),          4,    4,    3, 3, _
			109,  Array( ),          4,    4,    3, 3, _
			110,  Array( ),          6,    6,    3, 4, _
			111,  Array( ),          6,    6,    3, 4 ) )

			i = t("VertexID") - 100
			Set an_array(i) = new GraphVertexClass
			an_array(i).Index = i
			an_array(i).Item = t("VertexID")
			an_array(i).AdjacentIndexes = t("AdjacentIndexes")
			If not  is_mutual Then
				parent_indexes(i) = t("ParentIndex")
				dictances(i) = t("Distance")
			Else
				parent_indexes(i) = t("ParentIndex2")
				dictances(i) = t("Distance2")
			End If
		Next

		If is_mutual Then
			an_array(4).AdjacentIndexes = Array( 8, 9, 6 )
			an_array(11).AdjacentIndexes = Array( 0, 1 )
		End If


		'// Test Main
		self.Graph = an_array
		Set self.Order = new ArrayClass
		Set self.Distance = new ArrayClass
		DepthFirstSearch  an_array, 0, GetRef( "T_DepthFirstSearch_Callback" ), self, Empty


		'// Check
		If not  is_mutual Then
			Assert  IsSameArray( self.Order.Items,  Array( _
				0, 1, 4, 8, 9, 5, 2, 3, 6, 10, 11, 7 ) )
		Else
			Assert  IsSameArray( self.Order.Items,  Array( _
				0, 1, 4, 8, 9, 6, 10, 11, 5, 2, 3, 7 ) )
		End If
		For i=0 To 11
			If IsNull( parent_indexes(i) ) Then
				Assert  IsNull( an_array( self.Order(i) ).ParentIndex )
			Else
				Assert  an_array( self.Order(i) ).ParentIndex = parent_indexes( self.Order(i) )
			End If

			Assert  self.Distance(i) = dictances( self.Order(i) )
		Next
	Next

	Pass
End Sub


 
'***********************************************************************
'* Class: T_DepthFirstSearchClass
'***********************************************************************
Class  T_DepthFirstSearchClass
	Public  Graph  '// as array of GraphVertexClass
	Public  Order  '// as ArrayClass of integer
	Public  Distance  '// as ArrayClass of integer
End Class


 
'***********************************************************************
'* Function: T_DepthFirstSearch_Callback
'***********************************************************************
Function  T_DepthFirstSearch_Callback( in_ParentVertex, in_CurrentVertex, in_Parameter )
	in_Parameter.Order.Add  in_CurrentVertex.Item - 100
	in_Parameter.Distance.Add  GetDistanceInGraph( in_Parameter.Graph,  in_CurrentVertex.Index )

	echo  String( 4 * in_Parameter.Distance( in_Parameter.Distance.UBound_ ), " " ) + _
		CStr( in_CurrentVertex.Item )

	T_DepthFirstSearch_Callback = 1  '// Continue to search
End Function


 
'***********************************************************************
'* Function: T_GraphVertexClass
'***********************************************************************
Sub  T_GraphVertexClass( Opt, AppKey )

	'// Test of example of CreateGraphVertex
	graph = Array( )

	Set vertex1 = CreateGraphVertex( graph )
	Set vertex = new UserDefinedVertexClass
	Set vertex1.Item = vertex

	Assert  graph( vertex1.Index ) is vertex1


	'// Test of example of GetNDEdgeInGraph
	graph = Array( )

	Set vertex1 = CreateGraphVertex( graph )
	Set vertex1.Item = new UserDefinedVertexClass

	Set vertex2 = CreateGraphVertex( graph )
	Set vertex2.Item = new UserDefinedVertexClass

	Set new_edge = new UserDefinedEdgeClass
	SetNDEdgeInGraph  graph, vertex1.Index, vertex2.Index, new_edge

	Set edge = GetNDEdgeInGraph( graph, vertex1.Index, vertex2.Index, Empty )
	Assert  edge is new_edge


	'// ...
	Assert  GetDirectionIndex( 1, 2 ) = 0
	Assert  GetDirectionIndex( 1, 3 ) = 0
	Assert  GetDirectionIndex( 3, 2 ) = 1
	Assert  GetDirectionIndex( 2, 1 ) = 1

	graph = Array( )
	Set vertex1 = CreateGraphVertex( graph ) : vertex1.Item = "V1"
	Set vertex2 = CreateGraphVertex( graph ) : vertex2.Item = "V2"
	Set vertex3 = CreateGraphVertex( graph ) : vertex3.Item = "V3"
	Set vertex4 = CreateGraphVertex( graph ) : vertex4.Item = "V4"
	Set vertex5 = CreateGraphVertex( graph ) : vertex5.Item = "V4"

	SetEdgeInGraph    graph, vertex1.Index, vertex2.Index, new_NameOnlyClass( "E12", Array( "A1", "A2" ) )
	SetEdgeInGraph    graph, vertex2.Index, vertex1.Index, new_NameOnlyClass( "E21", Array( "B1", "B2" ) )
	SetNDEdgeInGraph  graph, vertex1.Index, vertex3.Index, new_NameOnlyClass( "E13", Array( "C1", "C3" ) )
	SetNDEdgeInGraph  graph, vertex3.Index, vertex1.Index, new_NameOnlyClass( "E13", Array( "D1", "D3" ) )
	SetNDEdgeInGraph  graph, vertex4.Index, vertex1.Index, new_NameOnlyClass( "E14", Array( "E1", "E4" ) )
	SetEdgeInGraph    graph, vertex5.Index, vertex1.Index, new_NameOnlyClass( "E51", Array( "F1", "F5" ) )

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		SetEdgeInGraph    graph, 99, 0, Nothing

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	Assert  e2.num = 9

	'// ...
	Assert  IsSameArrayOutOfOrder( vertex1.AdjacentIndexes, Array( 1, 2, 3 ), Empty )
	Assert  IsSameArrayOutOfOrder( vertex2.AdjacentIndexes, Array( 0 ), Empty )
	Assert  IsSameArrayOutOfOrder( vertex3.AdjacentIndexes, Array( 0 ), Empty )
	Assert  IsSameArrayOutOfOrder( vertex4.AdjacentIndexes, Array( 0 ), Empty )
	Assert  IsSameArrayOutOfOrder( vertex5.AdjacentIndexes, Array( 0 ), Empty )

	Set edge12 = GetEdgeInGraph( graph, vertex1.Index, vertex2.Index, Empty )
	Set edge21 = GetEdgeInGraph( graph, vertex2.Index, vertex1.Index, Empty )
	Assert  not edge12 is edge21
	Assert  edge12.Name = "E12"
	Assert  edge21.Name = "E21"
	Assert  edge12.Delegate( GetDirectionIndex( vertex1.Index, vertex2.Index ) ) = "A1"
	Assert  edge12.Delegate( GetDirectionIndex( vertex2.Index, vertex1.Index ) ) = "A2"
	Assert  edge21.Delegate( GetDirectionIndex( vertex2.Index, vertex1.Index ) ) = "B2"
	Assert  edge21.Delegate( GetDirectionIndex( vertex1.Index, vertex2.Index ) ) = "B1"

	Set edge13 = GetNDEdgeInGraph( graph, vertex1.Index, vertex3.Index, Empty )
	Set edge31 = GetNDEdgeInGraph( graph, vertex3.Index, vertex1.Index, Empty )
	Assert  edge13 is edge31
	Assert  edge13.Name = "E13"
	Assert  edge13.Delegate( GetDirectionIndex( vertex1.Index, vertex3.Index ) ) = "D1"
	Assert  edge13.Delegate( GetDirectionIndex( vertex3.Index, vertex1.Index ) ) = "D3"

	Set edge14 = GetNDEdgeInGraph( graph, vertex1.Index, vertex4.Index, Empty )
	Set edge41 = GetNDEdgeInGraph( graph, vertex4.Index, vertex1.Index, Empty )
	Assert  edge14 is edge41
	Assert  edge14.Name = "E14"
	Assert  edge14.Delegate( GetDirectionIndex( vertex1.Index, vertex4.Index ) ) = "E1"
	Assert  edge14.Delegate( GetDirectionIndex( vertex4.Index, vertex1.Index ) ) = "E4"

	Set edge51 = GetEdgeInGraph( graph, vertex5.Index, vertex1.Index, Empty )
	Assert  edge51.Name = "E51"
	Assert  edge51.Delegate( GetDirectionIndex( vertex5.Index, vertex1.Index ) ) = "F5"
	Assert  edge51.Delegate( GetDirectionIndex( vertex1.Index, vertex5.Index ) ) = "F1"

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		Set edge15 = GetEdgeInGraph( graph, vertex1.Index, vertex5.Index, Empty )

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	Assert  e2.num <> 0

	Set edge15 = GetEdgeInGraph( graph, vertex1.Index, vertex5.Index, Nothing )
	Assert  edge15 is Nothing

	edge15 = GetEdgeInGraph( graph, vertex1.Index, vertex5.Index, "A" )
	Assert  edge15 = "A"

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		Set edge199 = GetEdgeInGraph( graph, 99, vertex1.Index, Empty )

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	Assert  e2.num = 9

	'// Error Handling Test
	echo  vbCRLF+"Next is Error Test"
	If TryStart(e) Then  On Error Resume Next

		Set edge199 = GetEdgeInGraph( graph, vertex1.Index, 99, Empty )

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	Assert  e2.num = 9


	'// ...
	SetNDEdgeInGraph    graph, vertex1.Index, vertex3.Index, Empty
	Assert  IsEmpty( GetNDEdgeInGraph( graph, vertex3.Index, vertex1.Index, Nothing ) )


	'// Remove edge
If False Then
	RemoveEdgeInGraph    graph, vertex1.Index, vertex2.Index
	RemoveNDEdgeInGraph  graph, vertex1.Index, vertex3.Index


	If TryStart(e) Then  On Error Resume Next

		Assert  GetEdgeInGraph(   graph, vertex1.Index, vertex2.Index, Empty ) is Nothing

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	Assert  e2.num <> 0

	If TryStart(e) Then  On Error Resume Next

		Assert  GetNDEdgeInGraph( graph, vertex3.Index, vertex1.Index, Empty ) is Nothing

	If TryEnd Then  On Error GoTo 0
	e.CopyAndClear  e2  '//[out] e2
	Assert  e2.num <> 0
End If

	Pass
End Sub


 
Class  UserDefinedVertexClass
End Class

Class  UserDefinedEdgeClass
End Class


 
'***********************************************************************
'* Function: T_SearchSubGraphs
'***********************************************************************
Sub  T_SearchSubGraphs( Opt, AppKey )

	'// Set up
	ReDim  graph( 9 )
	For Each  t  In DicTable( Array( _
		"VertexID",  "AdjacentIndexes",  Empty, _
		100,  Array( 2, 4 ), _
		102,  Array( 0, 6 ), _
		104,  Array( 0 ), _
		106,  Array( 2 ), _
		_
		101,  Array( 3 ), _
		103,  Array( 1, 5, 9 ), _
		105,  Array( 3 ), _
		109,  Array( 3 ), _
		_
		107,  Array( ), _
		108,  Array( ) ) )

		i = t("VertexID") - 100
		Set graph(i) = new GraphVertexClass
		graph(i).Item = t("VertexID")
		graph(i).AdjacentIndexes = t("AdjacentIndexes")
	Next


	'// Test Main
	sub_graphs = SearchSubGraphs( graph, Empty )


	'// Check
	Assert  UBound( sub_graphs ) = 4 - 1
	Assert  IsSameArrayOutOfOrder( sub_graphs(0), Array( 0, 2, 4, 6 ), Empty )
	Assert  IsSameArrayOutOfOrder( sub_graphs(1), Array( 1, 3, 5, 9 ), Empty )
	Assert  IsSameArrayOutOfOrder( sub_graphs(2), Array( 7 ), Empty )
	Assert  IsSameArrayOutOfOrder( sub_graphs(3), Array( 8 ), Empty )

	Pass
End Sub


 







'--- start of vbslib include ------------------------------------------------------ 

'// ここの内部から Main 関数を呼び出しています。
'// また、scriptlib フォルダーを探して、vbslib をインクルードしています

'// vbslib include is provided under 3-clause BSD license.
'// Copyright (C) Sofrware Design Gallery "Sage Plaisir 21" All Rights Reserved.

Dim  g_Vers : If IsEmpty( g_Vers ) Then
Set  g_Vers = CreateObject("Scripting.Dictionary") : g_Vers("vbslib") = 99.99
Dim  g_debug, g_debug_params, g_admin, g_vbslib_path, g_CommandPrompt, g_fs, g_sh, g_AppKey
Dim  g_MainPath, g_SrcPath, g_f, g_include_path, g_i, g_debug_tree, g_debug_process, g_is_compile_debug
Dim  g_is64bitWSH
g_SrcPath = WScript.ScriptFullName : g_MainPath = g_SrcPath
SetupVbslibParameters
Set  g_fs = CreateObject( "Scripting.FileSystemObject" )
Set  g_sh = WScript.CreateObject("WScript.Shell") : g_f = g_sh.CurrentDirectory
g_sh.CurrentDirectory = g_fs.GetParentFolderName( WScript.ScriptFullName )
For g_i = 20 To 1 Step -1 : If g_fs.FileExists(g_vbslib_path) Then  Exit For
g_vbslib_path = "..\" + g_vbslib_path  : Next
If g_fs.FileExists(g_vbslib_path) Then  g_vbslib_path = g_fs.GetAbsolutePathName( g_vbslib_path )
g_sh.CurrentDirectory = g_f
If g_i=0 Then WScript.Echo "Not found " + g_fs.GetFileName( g_vbslib_path ) +vbCR+vbLF+_
	"Let's download vbslib and Copy scriptlib folder." : Stop : WScript.Quit 1
Set g_f = g_fs.OpenTextFile( g_vbslib_path,,,-2 ): Execute g_f.ReadAll() : g_f = Empty
If ResumePush Then  On Error Resume Next
	CallMainFromVbsLib
ResumePop : On Error GoTo 0
End If
'---------------------------------------------------------------------------------

Sub  SetupDebugTools()
	set_input  ""
	SetBreakByFName  Empty
	SetStartSectionTree  ""
End Sub

Sub  SetupVbslibParameters()
	'--- start of parameters for vbslib include -------------------------------
	g_Vers("vbslib") = 99.99
	'// g_Vers("OldMain") = 1
	g_vbslib_path = "scriptlib\vbs_inc.vbs"
	g_CommandPrompt = 1
	g_debug = 0
	'--- end of parameters for vbslib include ---------------------------------
End Sub
'--- end of vbslib include --------------------------------------------------------


 
