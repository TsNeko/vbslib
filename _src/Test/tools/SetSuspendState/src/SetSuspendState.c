#include  <windows.h> 
#include  <tchar.h>
#include  <PowrProf.h>


int APIENTRY _tWinMain( HINSTANCE hInstance, HINSTANCE hPrevInstance,
                        LPTSTR    lpCmdLine, int       nCmdShow )
{
  if ( lpCmdLine[0] == _T('\0') || lpCmdLine[0] == _T('0') )
    SetSuspendState( 0, 1, 0 );  // Sleep
  else
    SetSuspendState( 1, 1, 0 );  // Hibernate
  return 0;
}

 
