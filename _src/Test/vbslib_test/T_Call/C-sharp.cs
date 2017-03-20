// Debug=off
using  s = System;  // Alias "s::"

class MainClass
{
	static void  Main()
	{
		s::Console.WriteLine( "Hello, world!" );

		// Show a parameter of exe.
		if ( s::Environment.GetCommandLineArgs().Length >= 2 ) {
			s::Console.WriteLine( s::Environment.GetCommandLineArgs()[1] );
		}
	}
}


