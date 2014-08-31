#include  <windows.h> 
#include  <tchar.h>
#include  <stdio.h>
#include  <direct.h>


int  _tmain( int argc, TCHAR* argv[] )
{
  int      arg_num;
  int      e,ee;
  FILE*    f = NULL;
  errno_t  en;
  TCHAR    cwd[4096];

  en = _tfopen_s( &f, _T("ArgsLog.txt"), _T("at") );  if(f==NULL)goto err_no;
  _tgetcwd( cwd, _countof(cwd) );
  e= _ftprintf_s( f, _T("cwd = \"%s\"\n"), cwd ); if(e<0)goto err;
  for ( arg_num = 0;  arg_num < argc;  arg_num ++ ) {
    e= _ftprintf_s( f, _T("args[%d] = \"%s\"\n"), arg_num, argv[ arg_num ] ); if(e<0)goto err;
  }
  e=0;
fin:
  if(f!=NULL){ee= fclose( f ); if(ee&&!e)e=2;}
  return  e;
err_no: e= 2; goto fin;
err: e= 1; goto fin;
}

 
