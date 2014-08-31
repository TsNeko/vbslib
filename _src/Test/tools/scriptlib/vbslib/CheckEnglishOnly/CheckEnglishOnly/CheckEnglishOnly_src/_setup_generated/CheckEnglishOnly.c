#include  "include_c.h" 
#include  <crtdbg.h>


int  _tmain( int argc, TCHAR* argv[] )
{
	errnum_t  e;
	TCHAR     str[256];

	//Err2_setBreakErrID( 1 );

	Globals_initConst();
	e= Globals_initialize(); IF(e)goto fin;

	e= GetCommandLineUnnamed( 1, str, sizeof(str) ); IF(e)goto fin;
	IF( str[0] == _T('\0') ) goto help;






	_tprintf( _T("%s\n"), str );  // �����ɃR�[�h���L�q���Ă��������B






	e=0;
fin:
	Error4_showToStdErr( e );
	e= Globals_finalize( e );
	if ( ! GetCommandLineExist( _T("silent"), false ) ) {
		_tprintf( _T("\n�I�����܂����B�E�B���h����邱�Ƃ��ł��܂��B\n") );
		_fgettc( stdin );
	}
	if ( _CrtDumpMemoryLeaks() ) { DebugBreak(); }
	return  e;

help:
	Error4_printf( _T("help: ...") );
	e = E_Original;
	goto fin;
}


 
