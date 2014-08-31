#include  <windows.h> 
#include  <tchar.h>
#include  <stdio.h>
#include  <signal.h>

#if ! NDEBUG
  int  g_DisableDebugBreak;
  #define  IF(x)   if((x)&&(!g_DisableDebugBreak)&&(DebugBreak(),1))
#else
  #define  IF(x)   if(x)
#endif
enum { E_Others       = 1 };
enum { E_GetLastError = 0x401 };
enum { E_Errno        = 0x403 };
enum { E_FewMemory    = 0x410 };
enum { E_Help         = 4 };

typedef void (*signal_F)(int);
void  OnSignal( int Code );
typedef struct _SafeTee  SafeTee;
int   OutputFromChildPorcess( SafeTee* m );
DWORD WINAPI  OutputStdOutThread( void* mm );
DWORD WINAPI  OutputStdErrThread( void* mm );
DWORD WINAPI  OutputThread( void* mm, HANDLE PipeReader, FILE* StdStream, FILE* FileStream1, FILE* FileStream2,
  BOOL* pbReading, BOOL* pbOtherReading );
int  Thread_waitForFinish( HANDLE Thread, DWORD* pExitCode, int e );


struct _SafeTee {
  TCHAR*  m_StdOutPath;  // refer to argv
  TCHAR*  m_StdErrPath;
  TCHAR*  m_StdOutErrPath;
  TCHAR*  m_StdOutMode;  // "wt", "at", "wb", "ab"
  TCHAR*  m_StdErrMode;
  TCHAR*  m_StdOutErrMode;
  FILE*   m_StdOutFile;
  FILE*   m_StdErrFile;
  FILE*   m_StdOutErrFile;
  HANDLE  m_StdOutReader;
  HANDLE  m_StdOutWriter;
  HANDLE  m_StdErrReader;
  HANDLE  m_StdErrWriter;
  BOOL    m_bStdOutReading;
  BOOL    m_bStdErrReading;

  TCHAR*  m_CommandLine;  // refer to heap memory
  int     m_ExitCode;

  BOOL              m_bSection;
  CRITICAL_SECTION  m_Section;
  signal_F          m_PrevOnSignal;
};

void  SafeTee_init_const( SafeTee* m );
int  SafeTee_init( SafeTee* m );
int  SafeTee_finish( SafeTee* m, int e );
int  SafeTee_parse( SafeTee* m, int argc, TCHAR* argv[] );


SafeTee  g_SafeTee;


 
/***********************************************************************
  <<< [_tmain] >>> 
************************************************************************/
int  _tmain( int argc, TCHAR* argv[] )
{
  int        e;
  errno_t    en;
  SafeTee*   m = &g_SafeTee;

  SafeTee_init_const( m );

  e= SafeTee_init( m ); IF(e)goto fin;
  e= SafeTee_parse( m, argc, argv ); IF(e)goto fin;

  m->m_PrevOnSignal = signal( SIGINT, OnSignal );


  //=== output from standard input to file.
  if ( m->m_CommandLine == NULL ) {
    DWORD      out_time = 0;
    DWORD      t;
    int        ch;

    if ( m->m_StdOutPath != NULL ) {
      en = _tfopen_s( &m->m_StdOutFile, m->m_StdOutPath, m->m_StdOutMode );
      IF(m->m_StdOutFile==NULL)goto err_no;
    }

    for (;;) {
      ch = _fgettc( stdin );
      if ( ch == (_TINT)EOF )  break;
      EnterCriticalSection( &m->m_Section );
      _fputtc( ch, stdout );
      _fputtc( ch, m->m_StdOutFile );
      t = GetTickCount();
      if ( t - out_time >= 1000 ) {
        fflush( m->m_StdOutFile );
        out_time = t;
      }
      LeaveCriticalSection( &m->m_Section );
    }
  }

  //=== output from child process.
  else {
    e= OutputFromChildPorcess( m ); IF(e)goto err;
  }

  e=0;
fin:
  e= SafeTee_finish( m, e );
  if ( e && e != E_Help )  printf( "<ERROR num=\"0x%08X\"/>\n", e );
  if ( e ) Sleep( 2000 );
  return  m->m_ExitCode;

err:  e = E_Others;  goto fin;
err_no:  e= 2;  goto fin;
}


 
/***********************************************************************
  <<< [OutputFromChildPorcess] >>> 
************************************************************************/
int  OutputFromChildPorcess( SafeTee* m )
{
  int     e;
  errno_t en;
  DWORD   r;
  BOOL    b;
  HANDLE  stdout_th = NULL;
  HANDLE  stderr_th = NULL;
  PROCESS_INFORMATION  pi;

  pi.hThread  = INVALID_HANDLE_VALUE;
  pi.hProcess = INVALID_HANDLE_VALUE;


  if ( m->m_StdOutPath != NULL ) {
    if ( _tcscmp( m->m_StdOutMode, _T("wt") ) == 0 )
      m->m_StdOutMode = _T("wb");
    else { IF( _tcscmp( m->m_StdOutMode, _T("at") ) != 0 )goto err;
      m->m_StdOutMode = _T("ab");
    }
    en = _tfopen_s( &m->m_StdOutFile, m->m_StdOutPath, m->m_StdOutMode );
    IF(en)goto err_no;
  }
  if ( m->m_StdErrPath != NULL ) {
    if ( _tcscmp( m->m_StdErrMode, _T("wt") ) == 0 )
      m->m_StdErrMode = _T("wb");
    else { IF( _tcscmp( m->m_StdErrMode, _T("at") ) != 0 )goto err;
      m->m_StdErrMode = _T("ab");
    }
    en = _tfopen_s( &m->m_StdErrFile, m->m_StdErrPath, m->m_StdErrMode );
    IF(en)goto err_no;
  }
  if ( m->m_StdOutErrPath != NULL ) {
    if ( _tcscmp( m->m_StdOutErrMode, _T("wt") ) == 0 )
      m->m_StdOutErrMode = _T("wb");
    else { IF( _tcscmp( m->m_StdOutErrMode, _T("at") ) != 0 )goto err;
      m->m_StdOutErrMode = _T("ab");
    }
    en = _tfopen_s( &m->m_StdOutErrFile, m->m_StdOutErrPath, m->m_StdOutErrMode );
    IF(en)goto err_no;
  }


  //=== create pipe for connect to standard output of child process
  {
    SECURITY_ATTRIBUTES  sa;

    sa.nLength = sizeof(sa);
    sa.lpSecurityDescriptor = NULL;
    sa.bInheritHandle = TRUE;

    if ( m->m_StdOutPath != NULL || m->m_StdOutErrPath != NULL ) {
      b= CreatePipe( &m->m_StdOutReader, &m->m_StdOutWriter, &sa, 0 ); IF(!b)goto err_gt;
      b= SetHandleInformation( m->m_StdOutReader, HANDLE_FLAG_INHERIT, 0 ); IF(!b)goto err_gt;
        // m->m_StdOutWriter inherits security attributes but m_StdOutReader does not inherit.
    }
    if ( m->m_StdErrPath != NULL || m->m_StdOutErrPath != NULL ) {
      b= CreatePipe( &m->m_StdErrReader, &m->m_StdErrWriter, &sa, 0 ); IF(!b)goto err_gt;
      b= SetHandleInformation( m->m_StdErrReader, HANDLE_FLAG_INHERIT, 0 ); IF(!b)goto err_gt;
    }
  }


  //=== create threads reading from each pipe. (Current thread waits for child process.)
  if ( m->m_StdOutPath != NULL || m->m_StdOutErrPath != NULL ) {
    stdout_th = CreateThread( NULL, 0, OutputStdOutThread, m, 0, NULL ); IF(stdout_th==NULL)goto err;
  }
  if ( m->m_StdErrPath != NULL || m->m_StdOutErrPath != NULL ) {
    stderr_th = CreateThread( NULL, 0, OutputStdErrThread, m, 0, NULL ); IF(stderr_th==NULL)goto err;
  }


  //=== CreateProcess
  {
    STARTUPINFO  st;

    memset( &st, 0, sizeof(st) );
    st.cb = sizeof(st);
    st.dwFlags = STARTF_USESTDHANDLES;
    st.hStdOutput = ( m->m_StdOutWriter == INVALID_HANDLE_VALUE ) ?
                      GetStdHandle( STD_OUTPUT_HANDLE ) : m->m_StdOutWriter;
    st.hStdError = ( m->m_StdErrWriter == INVALID_HANDLE_VALUE ) ?
                     GetStdHandle( STD_ERROR_HANDLE ) : m->m_StdErrWriter;
    st.hStdInput = GetStdHandle( STD_INPUT_HANDLE );

    b= CreateProcess( NULL, m->m_CommandLine, NULL, NULL, TRUE, 0, NULL, NULL, &st, &pi );
    IF(!b) goto err_gt;
  }


  //=== wait for finish the process
  WaitForSingleObject( pi.hProcess, INFINITE );
  GetExitCodeProcess( pi.hProcess, &m->m_ExitCode );


  e=0;
fin:
  //=== finish pipe for return from ReadFile in threads.
  if ( m->m_StdOutWriter != INVALID_HANDLE_VALUE ) {
    b= CloseHandle( m->m_StdOutWriter ); IF(!b)goto err_gt;
    m->m_StdOutWriter = INVALID_HANDLE_VALUE;
  }
  if ( m->m_StdErrWriter != INVALID_HANDLE_VALUE ) {
    b= CloseHandle( m->m_StdErrWriter ); IF(!b)goto err_gt;
    m->m_StdErrWriter = INVALID_HANDLE_VALUE;
  }

  e= Thread_waitForFinish( stdout_th, &r, e ); IF(r&&!e)e=r;
  e= Thread_waitForFinish( stderr_th, &r, e ); IF(r&&!e)e=r;
  if ( pi.hThread  != INVALID_HANDLE_VALUE ) { b= CloseHandle( pi.hThread  ); IF(!b&&!e)e=E_GetLastError; }
  if ( pi.hProcess != INVALID_HANDLE_VALUE ) { b= CloseHandle( pi.hProcess ); IF(!b&&!e)e=E_GetLastError; }
  return  e;

err_gt:  e= E_GetLastError;  goto fin;
err_no:  e= E_Errno;   goto fin;
err:     e= E_Others;  goto fin;
}


 
/***********************************************************************
  <<< [OutputThread] >>> 
************************************************************************/
DWORD WINAPI  OutputStdOutThread( void* mm )
{
  SafeTee*  m = (SafeTee*) mm;
  return  OutputThread( mm, m->m_StdOutReader, stdout, m->m_StdOutFile, m->m_StdOutErrFile,
    &m->m_bStdOutReading, &m->m_bStdErrReading );
}

DWORD WINAPI  OutputStdErrThread( void* mm )
{
  SafeTee*  m = (SafeTee*) mm;
  return  OutputThread( mm, m->m_StdErrReader, stderr, m->m_StdErrFile, m->m_StdOutErrFile,
    &m->m_bStdErrReading, &m->m_bStdOutReading );
}

DWORD WINAPI  OutputThread( void* mm, HANDLE PipeReader, FILE* StdStream, FILE* FileStream1, FILE* FileStream2,
  BOOL* pbReading, BOOL* pbOtherReading )
{
  SafeTee*  m = (SafeTee*) mm;
  int       e;
  BOOL      b;
  DWORD     size;
  char      buffer[4096];
  unsigned  offset;  // of buffer
  char*     p_ret;

  SetThreadPriority( GetCurrentThread(), THREAD_PRIORITY_ABOVE_NORMAL );

  buffer[ sizeof(buffer) - 1 ] = '\0';
  offset = 0;

  for (;;) {

    //=== read output from child process
    *pbReading = FALSE;
    b= ReadFile( PipeReader, buffer + offset, sizeof(buffer) - 1 - offset, &size, NULL );
    *pbReading = TRUE;
    if ( !b ) {
      e = GetLastError();
      IF( e != ERROR_BROKEN_PIPE ) goto err_gt;
      size = 0;
    }


    //=== switch other thread at the end of line
    buffer[ offset + size ] = '\0';
    p_ret = strrchr( buffer + offset, _T('\n') );
    if ( p_ret == NULL && offset + size < sizeof(buffer) - 1 && b ) {
      offset += size;
    }
    else {
      offset = offset + size;
      size = ( p_ret == NULL ) ? ( offset ) : ( p_ret + 1 - buffer );


      //=== output stdout prior to stderr
      do {
        Sleep( 1 );
      } while ( *pbOtherReading && pbReading == &m->m_bStdErrReading );


      //=== output lines
      EnterCriticalSection( &m->m_Section );
      fwrite( buffer, 1, size, StdStream );
      if ( FileStream1 != NULL )  fwrite( buffer, 1, size, FileStream1 );
      if ( FileStream2 != NULL )  fwrite( buffer, 1, size, FileStream2 );
      LeaveCriticalSection( &m->m_Section );

      memcpy( buffer, p_ret + 1, offset - size );
      offset = 0;
    }
    if ( !b )  break;
  }

  e=0;
fin:
  *pbReading = FALSE;
  return  e;

err_gt: e= E_GetLastError;  goto fin;
}


int  Thread_waitForFinish( HANDLE Thread, DWORD* pExitCode, int e )
{
  DWORD  r;
  BOOL   b;

  if ( Thread == NULL ) { *pExitCode = 0;  return  0; }

  r = WaitForSingleObject( Thread, INFINITE );
  IF ( ( r==WAIT_ABANDONED || r==WAIT_FAILED ) && !e ) e=E_GetLastError;
  if ( pExitCode != NULL )
    { b = GetExitCodeThread( Thread, pExitCode );  IF(!b&&!e) e=E_GetLastError; }
  b = CloseHandle( Thread );  IF(!b&&!e) e=E_GetLastError;
  return  e;
}



 
/***********************************************************************
  <<< [OnSignal] >>> 
************************************************************************/
void  OnSignal( int Code )
{
  SafeTee*  m = &g_SafeTee;

  EnterCriticalSection( &m->m_Section );
  if ( m->m_StdOutFile != NULL )  fflush( m->m_StdOutFile );
  if ( m->m_StdErrFile != NULL )  fflush( m->m_StdErrFile );
  LeaveCriticalSection( &m->m_Section );
}


 
/***********************************************************************
  <<< [SafeTee_init_const] >>> 
************************************************************************/
void  SafeTee_init_const( SafeTee* m )
{
  m->m_StdOutPath = NULL;
  m->m_StdErrPath = NULL;
  m->m_StdOutErrPath = NULL;
  m->m_StdOutMode = NULL;
  m->m_StdErrMode = NULL;
  m->m_StdOutErrMode = NULL;
  m->m_StdOutFile = NULL;
  m->m_StdErrFile = NULL;
  m->m_StdOutErrFile = NULL;
  m->m_StdOutReader = INVALID_HANDLE_VALUE;
  m->m_StdOutWriter = INVALID_HANDLE_VALUE;
  m->m_StdErrReader = INVALID_HANDLE_VALUE;
  m->m_StdErrWriter = INVALID_HANDLE_VALUE;
  m->m_bStdOutReading = FALSE;
  m->m_bStdErrReading = FALSE;

  m->m_CommandLine = NULL;
  m->m_ExitCode = 0;

  m->m_bSection = FALSE;
  m->m_PrevOnSignal = NULL;
}

int  SafeTee_init( SafeTee* m )
{
  InitializeCriticalSection( &m->m_Section );
  m->m_bSection = TRUE;
  return  0;
}

int  SafeTee_finish( SafeTee* m, int e )
{
  int   ee;
  BOOL  b;

  if ( m->m_PrevOnSignal != NULL )  signal( SIGINT, m->m_PrevOnSignal );

  if ( m->m_CommandLine != NULL )  free( m->m_CommandLine );
  if ( m->m_StdOutFile != NULL ) { ee= fclose( m->m_StdOutFile ); if(ee&&!e)e=2; }
  if ( m->m_StdErrFile != NULL ) {
    int  pos = ftell( m->m_StdErrFile );
    ee= fclose( m->m_StdErrFile ); if(ee&&!e)e=2;
    if ( pos == 0 )  DeleteFile( m->m_StdErrPath );
  }
  if ( m->m_StdOutErrFile != NULL ) { ee= fclose( m->m_StdOutErrFile ); if(ee&&!e)e=2; }
  if ( m->m_StdOutReader != INVALID_HANDLE_VALUE ) { b= CloseHandle( m->m_StdOutReader ); IF(!b&&!e)e= E_GetLastError; }
  if ( m->m_StdOutWriter != INVALID_HANDLE_VALUE ) { b= CloseHandle( m->m_StdOutWriter ); IF(!b&&!e)e= E_GetLastError; }
  if ( m->m_StdErrReader != INVALID_HANDLE_VALUE ) { b= CloseHandle( m->m_StdErrReader ); IF(!b&&!e)e= E_GetLastError; }
  if ( m->m_StdErrWriter != INVALID_HANDLE_VALUE ) { b= CloseHandle( m->m_StdErrWriter ); IF(!b&&!e)e= E_GetLastError; }

  if ( m->m_bSection )  DeleteCriticalSection( &m->m_Section );

  return  e;
}

 
/***********************************************************************
  <<< [SafeTee_parse] >>> 
************************************************************************/
int  SafeTee_parse( SafeTee* m, int argc, TCHAR* argv[] )
{
  int  e, i;

  //=== Parse parameters
  for ( i = 1; i < argc; i++ ) {
    if ( _tcscmp( argv[i], _T("-h") ) == 0 ) {
      m->m_StdOutPath = NULL;  m->m_StdErrPath = NULL;  // for print help
      break;
    }
    else if ( _tcscmp( argv[i], _T("-o") ) == 0 ) {
      m->m_StdOutPath = argv[++i];
      m->m_StdOutMode = _T("wt");
    }
    else if ( _tcscmp( argv[i], _T("-a") ) == 0 ) {
      m->m_StdOutPath = argv[++i];
      m->m_StdOutMode = _T("at");
    }
    else if ( _tcscmp( argv[i], _T("-e") ) == 0 ) {
      m->m_StdErrPath = argv[++i];
      m->m_StdErrMode = _T("wt");
    }
    else if ( _tcscmp( argv[i], _T("-ea") ) == 0 ) {
      m->m_StdErrPath = argv[++i];
      m->m_StdErrMode = _T("at");
    }
    else if ( _tcscmp( argv[i], _T("-oe") ) == 0 ) {
      m->m_StdOutErrPath = argv[++i];
      m->m_StdOutErrMode = _T("wt");
    }
    else if ( _tcscmp( argv[i], _T("-oea") ) == 0 ) {
      m->m_StdOutErrPath = argv[++i];
      m->m_StdOutErrMode = _T("at");
    }
    else if ( _tcscmp( argv[i], _T("-cmd") ) == 0 ) {
      int     i_cmd = i + 1;
      size_t  len;

      len = 0;
      for ( i = i_cmd;  i < argc;  i++ ) {
        len += _tcslen( argv[i] ) + 1;
      }
      m->m_CommandLine = malloc( (len + 2)*sizeof(TCHAR) );  IF( m->m_CommandLine == NULL )goto err_fm;
      m->m_CommandLine[0] = _T('\0');
      for ( i = i_cmd;  i < argc;  i++ ) {
        #pragma warning(push)
        #pragma warning(disable: 4996)
          _tcscat( m->m_CommandLine, argv[i] );
          _tcscat( m->m_CommandLine, _T(" ") );
        #pragma warning(pop)
      }
    }
    else {
      printf( "<ERROR msg=\"Can not use No option parameter because drag and droped file breaks\"/>\n" );
      IF(1)goto err;
    }
  }


  //=== Check parameters
  IF ( m->m_StdOutPath == NULL && m->m_StdErrPath == NULL && m->m_StdOutErrPath == NULL ) {
    _tprintf( _T("safetee command\n") );
    _tprintf( _T("(usage1) program parameters | safetee -o file.txt\n") );
    _tprintf( _T("(usage2) safetee -o file.txt -e err.txt -cmd program parameters\n") );
    goto err_hp;
  }

  IF ( m->m_StdErrPath != NULL && m->m_CommandLine == NULL ) {
    printf( "<ERROR msg=\"Use -cmd option when -e or -ea option is used\"/>\n" );
    goto err;
  }

  e=0;
fin:
  return  e;

err:  e = E_Others;  goto fin;
err_fm:  e = E_FewMemory;  goto fin;
err_hp:  e = E_Help;  goto fin;
}


 
