g_Global = 2
g_ButtingLocal = 2
g_ButtingArgument = 2

Sub  TestSub( Argument_1, g_ButtingArgument )
	local_variable = 1
	local_variable_sub = 1

	g_ButtingLocal = 1  '// overwrite global

	echo  " ((( In library no Option Explicit )))"
	echo  "Argument_1 = "& Argument_1
	echo  "g_GlobalInMain = "& g_GlobalInMain
	echo  "g_Global = "& g_Global
	echo  "local_variable = "& local_variable
	echo  "local_variable_sub = "& local_variable_sub
	echo  "not_defined = "& not_defined
	echo  "g_ButtingLocal = "& g_ButtingLocal
	echo  "g_ButtingArgument = "& g_ButtingArgument
	echo  ""
End Sub


