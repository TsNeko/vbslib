#include  "include_c.h" 
#include  <crtdbg.h>

int APIENTRY  WinMain( HINSTANCE hInstance, HINSTANCE hPrevInstance,
                       LPSTR     lpCmdLine, int       nCmdShow )
{
	// IfErrThenBreak();
	if ( _CrtDumpMemoryLeaks() ) { DebugBreak(); }
	return 0;
}

 
