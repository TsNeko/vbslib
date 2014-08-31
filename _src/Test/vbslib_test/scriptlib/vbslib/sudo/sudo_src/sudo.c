#include  <windows.h>
#include  <tchar.h>
#pragma hdrstop

// Linker option /MANIFESTUAC:uiAccess=requireAdministrator

int APIENTRY  _tWinMain( HINSTANCE hInstance, HINSTANCE hPrevInstance,
                         LPTSTR    lpCmdLine, int       nCmdShow )
{
  STARTUPINFO  st;
  PROCESS_INFORMATION  pi;
  int    e;
  BOOL   b_pi = FALSE;
  BOOL   b;
  DWORD  r;
  TCHAR  param[4096];

  _tcscpy_s( param, _countof(param), lpCmdLine );
  memset( &st, 0, sizeof(st) );
  b_pi= CreateProcess( NULL, param, NULL, NULL, FALSE, 0, NULL, NULL, &st, &pi );
  if(b_pi==0)goto err_gt;

  WaitForSingleObject( pi.hProcess, INFINITE );
  GetExitCodeProcess( pi.hProcess, &r );

  #if 0
  {
    TCHAR  s[10];
    _stprintf_s( s, _countof(s), _T("%d"), r );
    MessageBox( NULL, s, _T(""), MB_OK );  // Windows ライブラリを使用する
  }
  #endif

  e=0;
fin:
  if ( b_pi ) {
    b= CloseHandle(pi.hThread);  if(!b&&!e)e=1;
    b= CloseHandle(pi.hProcess); if(!b&&!e)e=1;
  }
  return  r;
err_gt: e= 1;  r=2;  goto fin;
}

 
