#include  <windows.h> 
#include  <tchar.h>
#include  <stdio.h>


int  _tmain( int argc, TCHAR* argv[] )
{
  int  i;

  _fputts( _T("1 to stdout\n"), stdout );
  _fputts( _T("2 to stderr\n"), stderr );
  _fputts( _T("3 to stdout\n"), stdout );
  _fputts( _T("4 to stderr\n"), stderr );
  for ( i = 1; i < argc; i++ )  { _fputts( argv[i], stdout ); _fputts( _T(" to stdout\n"), stdout ); }
  Sleep( 1000 );
  _fputts( _T("5 to stdout\n"), stdout );
  _fputts( _T("6 to stderr\n"), stderr );
  _fputts( _T("7 to stdout\n"), stdout );
  _fputts( _T("8 to stderr\n"), stderr );
  for ( i = 1; i < argc; i++ )  { _fputts( argv[i], stderr ); _fputts( _T(" to stderr\n"), stderr ); }
  fflush( stdout );
  fflush( stderr );
  Sleep( 1000 );
  _fputts( _T("9 to stdout\n"), stdout );
  _fputts( _T("10 to stderr\n"), stderr );
  _fputts( _T("11 to stdout\n"), stdout );
  _fputts( _T("12 to stderr\n"), stderr );
  Sleep( 1000 );

  return 0;
}

 
