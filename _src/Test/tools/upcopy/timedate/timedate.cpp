#include  <windows.h>
#include  <stdio.h>
#include  <time.h>
#include  <stdlib.h>
#include  <tchar.h>

enum { Err_FewArray = 0x411 };
int  strcpy_r( char* dst, size_t dst_size, const char* src );
int  strncpy_r( char* dst, size_t dst_size, const char* src, int n );
int  stprintf_r( TCHAR* s, size_t s_size, TCHAR* format, ... );

#ifdef _UNICODE
  #error
#endif


/***********************************************************************
  <<< [main] >>> 
************************************************************************/
int  main( int argc, char* argv[] )
{
  int   r = 0;
  int   e;
  char  str[256];
  char  left[128];
  char  right[128];
  char* l_SetSentence;
  char* l_Path;
  char* p;
  time_t     t;
  struct tm  t2;
  size_t     len;
  BOOL  b;

  e = 1;

  // Get main parameters
  l_SetSentence = ( argc > 1 ? argv[1] : "now=now" );
  l_Path = ( argc > 2 ? argv[2] : "" );


  // Get left and right from l_SetSentence
  p = strchr( l_SetSentence, '=' );  if ( p == NULL )  strchr( l_SetSentence, '\0' );
  strncpy_r( left, sizeof(left), l_SetSentence, (int)(p - l_SetSentence) );
  #pragma warning(push)
  #pragma warning(disable: 4996)
    if ( *p == '\0' )  strcpy( right, "now" );  else  strcpy_r( right, sizeof(right), p + 1 );
  #pragma warning(pop)


  // if ( right == "now" )  str = now time
  if ( _stricmp( right, "now" ) == 0 ) {
    time( &t );
    localtime_s( &t2, &t );
  #pragma warning(push)
  #pragma warning(disable: 4996)
    strcpy( str, "Set " );
  #pragma warning(pop)
    strcpy_r( str+4, sizeof(str)-4, left );
    len = strlen( str );
    strftime( str + len, sizeof(str) - len, "=%Y%m%d_%H%M", &t2 );
    e = 0;
  }

  // if ( right == "update" )  str = update time stamp of l_Path
  else if ( _stricmp( right, "update" ) == 0 ) {
    HANDLE  f;
    FILETIME    ft;
    SYSTEMTIME  st;

    e = 0;
    f = CreateFile( l_Path, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING,
         FILE_ATTRIBUTE_NORMAL , 0 );
    if ( f == NULL || f == INVALID_HANDLE_VALUE )  { e = 1;  f = NULL; }

    if(!e){  b= GetFileTime( f, NULL, NULL, &ft ); if(!b)e=1; }
    if(!e){  b= FileTimeToLocalFileTime( &ft, &ft ); if(!b)e=1; }
    if(!e){  b= FileTimeToSystemTime( &ft, &st ); if(!b)e=1; }
    if ( f != NULL )  CloseHandle( f );
    if(!e)  stprintf_r( str, sizeof(str), _T("Set %s=%04d%02d%02d_%02d%02d"),
              left, st.wYear, st.wMonth, st.wDay, st.wHour, st.wMinute );
  }

  // error output
  if(e) {
    stprintf_r( str, sizeof(str), _T("Set %s="), left );
  }

  printf( "%s", str );

  return  r;
}


/***********************************************************************
  <<< [strcpy_r] >>> 
************************************************************************/
int  strcpy_r( char* dst, size_t dst_size, const char* src )
{
  int  e = 0;
  const char*  p = strchr( (char*) src, '\0' );

  #ifndef NDEBUG
    memset( dst, 0xDF, dst_size );
  #endif
  if ( p - src >= (int) dst_size )  { e = Err_FewArray;  p = src + dst_size - 1; }
  memcpy( dst, src, p - src );
  *( dst + (p - src) ) = '\0';
  return  e;
}
 
/***********************************************************************
  <<< [strncpy_r] >>> 
************************************************************************/
int  strncpy_r( char* dst, size_t dst_size, const char* src, int n )
{
  int  e = 0;
  const char*  p = strchr( (char*) src, '\0' );

  #ifndef NDEBUG
    memset( dst, 0xDF, dst_size );
  #endif
  if ( p - src > n )  p = src + n;
  if ( p - src >= (int) dst_size )  { e = Err_FewArray;  p = src + dst_size - 1; }
  memcpy( dst, src, p - src );
  *( dst + (p - src) ) = '\0';
  return  e;
}
 

/***********************************************************************
  <<< [stprintf_r] >>> 
************************************************************************/
int  vstprintf_r( TCHAR* s, size_t s_size, TCHAR* format, va_list va )
{
  size_t  tsize = s_size / sizeof(TCHAR);
 #pragma warning(push)
 #pragma warning(disable: 4996)
  int  r = _vsntprintf( s, tsize, format, va );
 #pragma warning(pop)
  if ( r == tsize || r == -1 ) { s[tsize-1] = '\0';  return Err_FewArray; }
  else  return  0;
}
int  stprintf_r( TCHAR* s, size_t s_size, TCHAR* format, ... )
  { int e;  va_list  va;  va_start( va, format );
    e = vstprintf_r( s, s_size, format, va ); va_end( va );  return e; }


