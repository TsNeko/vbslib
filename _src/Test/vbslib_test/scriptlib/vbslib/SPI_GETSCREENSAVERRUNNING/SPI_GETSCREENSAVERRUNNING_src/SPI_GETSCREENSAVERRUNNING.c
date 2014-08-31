#include  <windows.h> 
#include  <tchar.h>


int  _tmain( int argc, TCHAR* argv[] )
{
  BOOL  is_running;

  SystemParametersInfo( SPI_GETSCREENSAVERRUNNING, 0, &is_running, 0 );

  return  is_running;
}

 
