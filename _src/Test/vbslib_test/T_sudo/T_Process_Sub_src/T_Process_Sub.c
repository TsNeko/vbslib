#include  <windows.h> 
#include  <tchar.h>
#include  <stdio.h>

#define  IF  if

int  SleepedFinish( int argc, TCHAR* argv[] );


int  _tmain( int argc, TCHAR* argv[] )
{
  int  e;
  TCHAR*  lpCmdLine = ( argc == 1 ) ? _T("") : argv[1];

  #if USE_GLOBALS
    Globals_init_const();
    e= Globals_init(); IF(e)goto fin;
  #endif

  if (      _tcscmp( lpCmdLine, _T("SleepedFinish") ) == 0 )  e= SleepedFinish( argc, argv );
  else if ( _tcscmp( lpCmdLine, _T("") ) == 0 )
    e= SleepedFinish( argc, argv ); // for debugging now
  else  e=1;

  #if USE_GLOBALS
fin:
    e= Globals_finish( e );
  #endif
  return  e;
}

 
/***********************************************************************
  <<< [SleepedFinish] >>> 
************************************************************************/
int  SleepedFinish( int argc, TCHAR* argv[] )
{
  int     e,ee;
  FILE*   f = NULL;
  errno_t en;
  int     sleep_msec  = _ttoi( argc > 2 ? argv[2] : _T("0") );
  TCHAR*  out_path = ( argc > 3 ? argv[3] : _T("") );
  TCHAR*  message  = ( argc > 4 ? argv[4] : _T("") );

  if ( message[0] == _T('\0') ) goto err;

  Sleep( sleep_msec );

  en = _tfopen_s( &f, out_path, _T("at") );  IF(f==NULL)goto err;
  _fputts( message, f );
  _fputts( _T("\n"), f );

  e=0;
fin:
  if(f!=NULL){ee= fclose( f ); IF(ee&&!e)e=1;}
  return  e;

err: e= 1; goto fin;
}

 
