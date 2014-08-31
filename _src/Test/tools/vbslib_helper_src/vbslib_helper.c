#include  "include_c.h" 

/* Main function is "_tWinMain" */


errnum_t  GetTextFromClipboard(void);
errnum_t  SetTextToClipboard(void);
errnum_t  touch(void);
errnum_t  CutSharpIf(void);


 
/***********************************************************************
  <<< [_tWinMain] >>> 
************************************************************************/
int APIENTRY  _tWinMain( HINSTANCE hInstance, HINSTANCE hPrevInstance,
                         LPTSTR    lpCmdLine, int       nCmdShow )
{
	errnum_t  e;
	TCHAR     command_name[40];

SetBreakErrorID( 1 );
	Globals_initConst();
	e= Globals_initialize(); IF(e)goto fin;

	e= GetCommandLineUnnamed( 1, command_name, sizeof( command_name ) ); IF(e)goto fin;
	if ( _tcscmp( command_name, _T("GetTextFromClipboard") ) == 0 )
		{ e= GetTextFromClipboard(); IF(e)goto fin; }
	else if ( _tcscmp( command_name, _T("SetTextToClipboard") ) == 0 )
		{ e= SetTextToClipboard(); IF(e)goto fin; }
	else if ( _tcscmp( command_name, _T("touch") ) == 0 )
		{ e= touch(); IF(e)goto fin; }
	else if ( _tcscmp( command_name, _T("CutSharpIf") ) == 0 )
		{ e= CutSharpIf(); IF(e)goto fin; }
	else
		{ ASSERT_R( false, goto err ); }

	e=0;
fin:
	e= Globals_finalize( e );
	IfErrThenBreak();
	if ( _CrtDumpMemoryLeaks() )  DebugBreak();
	return  e;

err:  e = E_OTHERS;  goto fin;
}


 
/***********************************************************************
  <<< [GetTextFromClipboard] >>> 
************************************************************************/
errnum_t  GetTextFromClipboard()
{
	errnum_t  e;
	BOOL      b;
	HGLOBAL   data = NULL;
	DWORD     size;
	DWORD     nz_size;  /* without '\0' */
	DWORD     n;
	TCHAR*    str = NULL;
	TCHAR*    z_str;
	FILE*     file = NULL;
	TCHAR     out_path[MAX_PATH*2];
	errno_t   en;
	TCHAR     byte_order_mark = _T('\xFEFF');


	e= GetCommandLineNamed( _T("Out"), false, out_path, sizeof(out_path) ); IF(e)goto fin;
	e= AppKey_newWritable( NULL, NULL, out_path, NULL ); IF(e)goto fin;

	b= OpenClipboard( NULL ); IF(!b)goto err;
	data = GetClipboardData( CF_UNICODETEXT ); IF(data==NULL)goto err_nf;
	size = GlobalSize( data );
	str = (TCHAR*)GlobalLock( data ); IF(str==NULL)goto err;

	// Sometimes size > _tcslen( str )
	z_str = _tcschr( str, _T('\0') );
	if ( (char*) z_str + sizeof(TCHAR) - (char*) str < (int) size ) {
		size = (char*) z_str + sizeof(TCHAR) - (char*) str;
	}

	nz_size = size - sizeof(TCHAR);

	en = _tfopen_s( &file, out_path, _T("wb") );  IF(en) goto err_no;
	n = fwrite( &byte_order_mark, 1,sizeof(TCHAR), file ); IF(ferror(file))goto err_no;
		IF( n != sizeof(TCHAR) )goto err_no;
	n = fwrite( str, 1,nz_size, file ); IF(ferror(file))goto err_no;
		IF( n != nz_size )goto err_no;

	e=0;
fin:
	e= FileT_close( file, e );
	e= AppKey_finishGlobal( e );
	if ( data != NULL )  GlobalUnlock( data );
	CloseClipboard();
	return  e;

err:     e = E_OTHERS;  goto fin;
err_no:  e = E_ERRNO;  goto fin;
err_nf:  e = E_NOT_FOUND_SYMBOL;  goto fin;
}


 
/***********************************************************************
  <<< [FileT_getSize] >>> 
************************************************************************/
errnum_t  FileT_getSize( const TCHAR* Path, size_t* out_Size )
{
	errnum_t  e;
	DWORD     size;
	DWORD     size_high;
	HANDLE    file = INVALID_HANDLE_VALUE;

	file = CreateFile( Path, GENERIC_READ, FILE_SHARE_READ,
	                   NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL );
		IF(file == INVALID_HANDLE_VALUE) goto err;

	size = GetFileSize( file, &size_high ); IF(size==-1)goto err;
	IF( size_high != 0 )goto err_fa;
	*out_Size = size;

	e=0;
fin:
	CloseHandle( file );
	return  e;

err:     e = E_OTHERS;    goto fin;
err_fa:  e = E_FEW_ARRAY;  goto fin;
}


 
/***********************************************************************
  <<< [SetTextToClipboard] >>> 
************************************************************************/
errnum_t  SetTextToClipboard()
{
	errnum_t  e;
	FILE*     file = NULL;
	HGLOBAL   data = NULL;
	bool      is_data_lock = false;
	bool      is_set = false;
	size_t    size;
	size_t    max_size;
	TCHAR*    str = NULL;
	TCHAR*    str_next;
	TCHAR*    str2;
	TCHAR     in_path[MAX_PATH*2];

	e= GetCommandLineNamed( _T("In"), false, in_path, sizeof(in_path) ); IF(e)goto fin;


	/* Allocate "str" */
	e= FileT_getSize( in_path, &max_size ); IF(e)goto fin;
	max_size *= sizeof(TCHAR) * 2;  /* 2 is \n -> \r\n */
	size = 0;
	str = (TCHAR*) malloc( max_size ); IF(str==NULL)goto err_fm;
	str_next = str;


	/* Read from "in_path" to "str" */
	e= FileT_openForRead( &file, in_path ); IF(e)goto fin;
	for (;;) {
		_fgetts( str_next, ( max_size - size ) / sizeof(TCHAR),  file );
		if ( str_next[0] == _T('\0') )  break;  /* EOF (because no '\n') */
		str_next = _tcschr( str_next, _T('\0') );
		if ( *( str_next - 1 ) == _T('\n') ) {
			*( str_next - 1 ) = _T('\r');
			*( str_next     ) = _T('\n');
			*( str_next + 1 ) = _T('\0');
			str_next += 1;
		}
		size = (int8_t*) str_next - (int8_t*) str;
		if ( feof( file ) )  break;
	}
	e= FileT_close( file, e );  file = NULL;
	size += sizeof(TCHAR);  /* for '\0' */


	/* Set "data" from "str" */
	data = GlobalAlloc( GMEM_DDESHARE, size ); IF(data==NULL)goto err_fm;
	is_data_lock = true;
	str2 = (TCHAR*) GlobalLock( data );
	memcpy( str2, str, size );
	GlobalUnlock( data );
	is_data_lock = false;


	/* Set to clipboard */
	if ( OpenClipboard( NULL ) ) {
		EmptyClipboard();
		SetClipboardData( CF_UNICODETEXT, data );
		CloseClipboard();
		is_set = true;
	}

	e=0;
fin:
	if ( str != NULL )  free( str );
	if ( is_data_lock )  IF( ! GlobalUnlock( data ) &&!e) e=E_OTHERS;
	if ( data != NULL && ! is_set )  IF( GlobalFree( data ) != NULL &&!e) e=E_OTHERS;
	e= FileT_close( file, e );
	return  e;

err_fm:  e = E_FEW_MEMORY;  goto fin;
}


 
/***********************************************************************
  <<< [touch] >>> 
************************************************************************/
errnum_t  touch()
{
	errnum_t    e;
	BOOL        b;
	SYSTEMTIME  now_system;
	FILETIME    now_file;
	HANDLE      file;
	TCHAR       path[MAX_PATH];

	e= GetCommandLineUnnamed( 2, path, sizeof( path ) ); IF(e)goto fin;
	GetSystemTime( &now_system );
	b= SystemTimeToFileTime( &now_system, &now_file );
		IF(!b){ e=SaveWindowsLastError(); goto fin; }
	file = CreateFile( path, GENERIC_WRITE, 0, NULL, OPEN_EXISTING,
		FILE_ATTRIBUTE_NORMAL , 0 );
		IF( file == INVALID_HANDLE_VALUE ) { e=SaveWindowsLastError(); goto fin; }

	b= SetFileTime( file, NULL, NULL, &now_file );
		IF(!b){ e=SaveWindowsLastError(); goto fin; }
fin:
	e= CloseHandleInFin( file, e );
	return  e;
}


 
/***********************************************************************
  <<< [CutSharpIf] >>> 
************************************************************************/
#define  SYMBOL_MAX_SIZE  256

errnum_t  CutSharpIf()
{
	errnum_t  e;
	Set2      directives;
	Set2      cuts;
	FILE*     r_file = NULL;  /* read */
	FILE*     w_file = NULL;  /* write */
	TCHAR*    text = NULL;
	TCHAR     source_path[ MAX_PATH ];
	TCHAR     out_path[ MAX_PATH ];
	TCHAR     symbol[ SYMBOL_MAX_SIZE ];
	TCHAR     str_value[ SYMBOL_MAX_SIZE ];
	bool      is_cut_true;


	Set2_initConst( &directives );
	Set2_initConst( &cuts );


	/* Set parameters */
	e= GetCommandLineUnnamed( 2, source_path, sizeof(source_path) ); IF(e){goto fin;}
	e= GetCommandLineUnnamed( 3, out_path, sizeof(out_path) ); IF(e){goto fin;}
	e= GetCommandLineUnnamed( 4, symbol, sizeof(symbol) ); IF(e){goto fin;}
	e= GetCommandLineUnnamed( 5, str_value, sizeof(str_value) ); IF(e){goto fin;}
	is_cut_true = ( _tcscmp( str_value, _T("1") ) == 0 );


	/* Main */
	e= Set2_init( &directives, 0x1000 ); IF(e){goto fin;}
	e= Set2_init( &cuts, 0x1000 ); IF(e){goto fin;}

	e= FileT_openForRead( &r_file, source_path ); IF(e){goto fin;}
	e= FileT_readAll( r_file, &text, NULL ); IF(e){goto fin;}

	e= AppKey_newWritable( NULL, NULL, out_path, NULL ); IF(e){goto fin;}
	e= FileT_openForWrite( &w_file, out_path, 0 ); IF(e){goto fin;}


	e= Parse_PP_Directive( text, &directives ); IF(e){goto fin;}
	e= ParsedRanges_getCut_by_PP_Directive( &cuts, &directives, symbol, is_cut_true );
		IF(e){goto fin;}
	e= ParsedRanges_write_by_Cut( &cuts, text, w_file ); IF(e){goto fin;}
	e= FileT_close( w_file, e );  w_file = NULL;
	e= FreeMemory( &text, e );


	e=0;
fin:
	e= Delete_PP_Directive( &directives, e );
	e= Set2_finish( &cuts, e );
	e= FreeMemory( &text, e );
	e= FileT_close( r_file, e );
	e= FileT_close( w_file, e );
	return  e;
}


 
