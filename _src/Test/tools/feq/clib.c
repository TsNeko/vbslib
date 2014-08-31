/* The source file was composed by module mixer */ 

#include  "include_c.h"


 
/*=================================================================*/
/* <<< [Global0/Global0.c] >>> */ 
/*=================================================================*/
 
/***********************************************************************
  <<< [Globals_initConst] >>> 
************************************************************************/

void  Globals_initConst()
{
}


 
/***********************************************************************
  <<< [Globals_initialize] >>> 
************************************************************************/
int  Globals_initialize()
{
  int  e;

    e= Locale_init(); IF(e)goto fin;

  e=0;
  goto fin;  // for avoid warning of no goto fin
fin:
  return  e;
}


 
/***********************************************************************
  <<< [Globals_finalize] >>> 
************************************************************************/
int  Globals_finalize( int e )
{

  return  e;
}


 
/*=================================================================*/
/* <<< [PlatformSDK_plus/PlatformSDK_plus.c] >>> */ 
/*=================================================================*/
 
/***********************************************************************
  <<< [GetCommandLineUnnamed] >>> 
************************************************************************/
int  GetCommandLineUnnamed( int Index1, TCHAR* out_AParam, size_t AParamSize )
{
	TCHAR*  line = GetCommandLine();
	int     index;
	TCHAR*  p;
	TCHAR*  p2;
	TCHAR   c;

	#if UNDER_CE
		Index1 --;
	#endif
	IF( Index1 < 0 ) goto err_nf;
	index = Index1;

	p = line;

	for (;;) {
		while ( *p == _T(' ') )  p++;

		c = *p;

		if ( c == _T('\0') )  goto err_nf;  // Here is not decided to error or not


		//=== Skip named option
		else if ( c == _T('/') ) {
			p++;
			for (;;) {
				c = *p;
				if ( c == _T('"') || c == _T(' ') || c == _T('\0') )  break;
				p++;
			}

			if ( c == _T('"') ) {
				p++;
				while ( *p != _T('"') && *p != _T('\0') )  p++;
				if ( *p == _T('"') )  p++;
			}
		}

		//=== Skip or Get unnamed parameter
		else {
			while ( *p == _T(' ') )  p++;

			c = *p;
			p2 = p + 1;

			if ( c == _T('"') ) {
				p ++;
				while ( *p2 != _T('"') && *p2 != _T('\0') )  p2++;
			}
			else {
				while ( *p2 != _T(' ') && *p2 != _T('\0') )  p2++;
			}

			if ( index == 0 ) {
				int  e;

				e= stcpy_part_r( out_AParam, AParamSize, out_AParam, NULL, p, p2 );
					ASSERT_D( !e, __noop() );
				return  e;
			}
			else {
				p = ( *p2 == _T('"') ) ? p2+1 : p2;
				index --;
			}
		}
	}

err_nf:
	if ( AParamSize >= sizeof(TCHAR) )  *out_AParam = _T('\0');
	IF ( Index1 >= 2 )  return  E_NOT_FOUND_SYMBOL;
	return  0;
}


 
/***********************************************************************
  <<< [GetCommandLineNamed] >>> 
************************************************************************/
int  GetCommandLineNamed_sub( const TCHAR* Name, bool bCase, bool* out_IsExist, TCHAR* out_Value, size_t ValueSize );

int  GetCommandLineNamed( const TCHAR* Name, bool bCase, TCHAR* out_Value, size_t ValueSize )
{
	bool  is_exist;
	return  GetCommandLineNamed_sub( Name, bCase, &is_exist, out_Value, ValueSize );
}


int  GetCommandLineNamed_sub( const TCHAR* Name, bool bCase, bool* out_IsExist, TCHAR* out_Value, size_t ValueSize )
{
	TCHAR*  line = GetCommandLine();
	TCHAR*  p;
	TCHAR*  p2;
	TCHAR   c;
	const size_t  name_len = _tcslen( Name );
	bool    bMatch;

	*out_IsExist = true;

	p = line;
	for (;;) {
		c = *p;

		//=== Compare option name
		if ( c == _T('/') ) {
			p++;
			p2 = p;
			for (;;) {
				c = *p2;
				if ( c == _T(':') || c == _T(' ') || c == _T('\0') )  break;
				p2++;
			}
			if ( bCase )
				bMatch = ( p2-p == (int)name_len && _tcsncmp( p, Name, p2-p ) == 0 );
			else
				bMatch = ( p2-p == (int)name_len && _tcsnicmp( p, Name, p2-p ) == 0 );


			//=== Get the value
			if ( c == _T(':') ) {
				p = p2 + 1;
				if ( *p == _T('"') ) {
					p++;
					p2 = p;
					while ( *p2 != _T('"') && *p2 != _T('\0') )  p2++;
					if ( bMatch )
						return  stcpy_part_r( out_Value, ValueSize, out_Value, NULL, p, p2 );
					else
						p = p2+1;
				}
				else {
					p2 = p;
					while ( *p2 != _T(' ') && *p2 != _T('\0') )  p2++;
					if ( bMatch )
						return  stcpy_part_r( out_Value, ValueSize, out_Value, NULL, p, p2 );
					else
						p = p2;
				}
			}
			else {
				IF( bMatch ) return  E_NOT_FOUND_SYMBOL;  // no value error
			}
		}

		else if ( c == _T('\0') )  break;

		//=== Skip
		else if ( c == _T('"') ) {
			p++;
			while ( *p != _T('"') && *p != _T('\0') )  p++;
			while ( *p != _T(' ') && *p != _T('\0') )  p++;
		}
		else {
			while ( *p != _T(' ') && *p != _T('\0') )  p++;
		}
		while ( *p == _T(' ') )  p++;
	}

	*out_IsExist = false;
	return  E_NOT_FOUND_SYMBOL;
}


 
/***********************************************************************
  <<< [GetCommandLineNamedI] >>> 
************************************************************************/
int  GetCommandLineNamedI( const TCHAR* Name, bool bCase, int* out_Value )
{
	int    e;
	bool   is_exist;
	TCHAR  s[20];

	e= GetCommandLineNamed_sub( Name, bCase, &is_exist, s, sizeof(s) ); IF(e)goto fin;  //[out] s
	if ( s[0] == _T('0') && s[1] == _T('x') )
		*out_Value = _tcstoul( s, NULL, 16 );
	else
		*out_Value = _ttoi( s );
	//e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [GetCommandLineNamedC8] >>> 
************************************************************************/
#if  _UNICODE
int  GetCommandLineNamedC8( const TCHAR* Name, bool bCase, char* out_Value, size_t ValueSize )
{
	int     e;
	bool    is_exist;
	TCHAR*  s = NULL;

	s = (TCHAR*) malloc( ValueSize * sizeof(TCHAR) );
	e= GetCommandLineNamed_sub( Name, bCase, &is_exist, (TCHAR*) s, ValueSize * sizeof(TCHAR) ); IF(e)goto fin;

	sprintf_s( out_Value, ValueSize, "%S", s );
fin:
	if ( s != NULL )  free( s );
	return  e;
}
#endif


 
/***********************************************************************
  <<< [GetCommandLineExist] >>> 
************************************************************************/
bool  GetCommandLineExist( const TCHAR* Name, bool bCase )
{
	int     e;
	bool    is_exist;
	TCHAR   v[1];

	e = GetCommandLineNamed_sub( Name, bCase, &is_exist, v, sizeof(v) );
	if ( e == E_NOT_FOUND_SYMBOL )  ClearError();
	return  is_exist;
}


 
/*=================================================================*/
/* <<< [Locale/Locale.c] >>> */ 
/*=================================================================*/
 
/***********************************************************************
  <<< [g_LocaleSymbol] >>> 
************************************************************************/
char*  g_LocaleSymbol = "";


 
/***********************************************************************
  <<< [Locale_init] >>> 
************************************************************************/
int  Locale_init()
{
	g_LocaleSymbol = ".OCP";
	setlocale( LC_ALL, ".OCP" );
	return  0;
}


 
/***********************************************************************
  <<< [Locale_isInited] >>> 
************************************************************************/
int  Locale_isInited()
{
	return  ( g_LocaleSymbol[0] != '\0' );
		// ここが false を返すときの対処法は、Locale_isInited のヘルプを参照してください。
}


 
/*=================================================================*/
/* <<< [FileT/FileT.c] >>> */ 
/*=================================================================*/
 
/***********************************************************************
  <<< [FileT_isExist] >>> 
************************************************************************/
bool  FileT_isExist( const TCHAR* path )
{
 #if ! FileT_isExistWildcard

	DWORD  r;

	if ( path[0] == _T('\0') )  return  false;
	r = GetFileAttributes( path );
	return  r != (DWORD)-1;

 #else

	HANDLE  find;
	WIN32_FIND_DATA  data;

	find = FindFirstFileEx( path, FindExInfoStandard, &data,
		FindExSearchNameMatch, NULL, 0 );

	if ( find == INVALID_HANDLE_VALUE ) {
		return  false;
	}
	else {
		FindClose( find );
		return  true;
	}

 #endif
}


 
/***********************************************************************
  <<< [FileT_isFile] >>> 
************************************************************************/
bool  FileT_isFile( const TCHAR* path )
{
	DWORD  r = GetFileAttributes( path );
	return  ( r & (FILE_ATTRIBUTE_DIRECTORY | 0x80000000) ) == 0;
		// 0x80000000 は、ファイルやフォルダが存在しないことを判定するため
}


 
/***********************************************************************
  <<< [FileT_isDir] >>> 
************************************************************************/
bool  FileT_isDir( const TCHAR* path )
{
	DWORD  r = GetFileAttributes( path );
	return  ( r & (FILE_ATTRIBUTE_DIRECTORY | 0x80000000) ) == FILE_ATTRIBUTE_DIRECTORY;
		// 0x80000000 は、ファイルやフォルダが存在しないことを判定するため
}


 
/***********************************************************************
  <<< [FileT_isDiff] >>> 
************************************************************************/
int  FileT_isDiff( const TCHAR* Path1, const TCHAR* Path2, bool* bDiff )
{
	int    e;
	bool   b;
	FILE*  f1 = NULL;
	FILE*  f2 = NULL;
	char*  buf1 = NULL;
	char*  buf2 = NULL;
	errno_t  en;


	//=== Open files
	en= _tfopen_s( &f1, Path1, _T("r") );
	if ( en == ENOENT )  { f1 = NULL; en = 0; }
	IF(en)goto err_no;

	en= _tfopen_s( &f2, Path2, _T("r") );
	if ( en == ENOENT )  { f2 = NULL; en = 0; }
	IF(en)goto err_no;


	//=== Whether exists or not
	if ( f1 == NULL ) {
		if ( f2 == NULL )  { *bDiff = false; e=0; goto fin; }
		else  { *bDiff = true; e=0; goto fin; }
	}
	else {
		if ( f2 == NULL )  { *bDiff = true; e=0; goto fin; }
	}


	//=== Compare the contents in files
	{
		enum { size = 0x100000 };
		size_t  size1, size2;

		buf1 = (char*) malloc( size ); IF(buf1==NULL)goto err_fm;
		buf2 = (char*) malloc( size ); IF(buf2==NULL)goto err_fm;

		b = true;
		for (;;) {
			size1 = fread( buf1, 1, size, f1 );
			size2 = fread( buf2, 1, size, f2 );

			if ( size1 != size2 )  break;
			if ( memcmp( buf1, buf2, size1 ) != 0 )  break;
			if ( size1 != size )  { b = false; break; }
		}
		*bDiff = b;
	}

	e=0;
fin:
	if ( buf1 !=NULL)free(buf1);
	if ( buf2 !=NULL)free(buf2);
	if( f1 !=NULL){en=fclose(f1);IF(en)b=true;}
	if( f2 !=NULL){en=fclose(f2);IF(en)b=true;}
	return  e;
err_no: e = E_ERRNO; goto fin;
err_fm: e = E_FEW_MEMORY; goto fin;
}

 
/***********************************************************************
  <<< [FileT_isSameText] >>> 
************************************************************************/
int  FileT_isSameText( TCHAR* Path1, TCHAR* Path2, int Format1, int Format2, bool* out_bSame )
{
	int    e;
	FILE*  f1 = NULL;
	FILE*  f2 = NULL;
	TCHAR  line1[4096];
	TCHAR  line2[4096];

	ASSERT_R( Format1 == 0, goto err );
	ASSERT_R( Format2 == 0, goto err );

	e= FileT_openForRead( &f1, Path1 ); IF(e)goto fin;
	e= FileT_openForRead( &f2, Path2 ); IF(e)goto fin;
	for (;;) {
		line1[0] = _T('\0');
		line2[0] = _T('\0');
		_fgetts( line1, _countof(line1), f1 );
		_fgetts( line2, _countof(line2), f2 );
		if ( _tcscmp( line1, line2 ) != 0 ) {
			*out_bSame = false;  e=0;  goto fin;
		}
		if ( feof( f1 ) ) {
			if ( feof( f2 ) )  break;
			else {
				*out_bSame = false;  e=0;  goto fin;
			}
		}
	}
	*out_bSame = true;

	e=0;
fin:
	e= FileT_closeAndNULL( &f1, e );
	e= FileT_closeAndNULL( &f2, e );
	return  e;

err:  e = E_OTHERS;  goto fin;
}


 
/***********************************************************************
  <<< [FileT_isSameBinaryFile] >>> 
************************************************************************/
int  FileT_isSameBinaryFile( const TCHAR* PathA, const TCHAR* PathB, int Flags, bool* out_IsSame )
{
	int       e;
	HANDLE    file_a = INVALID_HANDLE_VALUE;
	HANDLE    file_b = INVALID_HANDLE_VALUE;
	HANDLE    mem_a  = INVALID_HANDLE_VALUE;
	HANDLE    mem_b  = INVALID_HANDLE_VALUE;
	void*     ptr_a = NULL;
	void*     ptr_b = NULL;
	size_t    size_a;
	size_t    size_b;
	BOOL      b;
	bool      is_same = false;

	UNREFERENCED_VARIABLE( Flags );


	// file_a,  file_b : open PathA,  PathB
	file_a = CreateFile( PathA, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING,
											 FILE_ATTRIBUTE_NORMAL, 0 );
	IF( file_a == INVALID_HANDLE_VALUE ) goto err_gt;

	file_b = CreateFile( PathB, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING,
											 FILE_ATTRIBUTE_NORMAL, 0 );
	IF( file_b == INVALID_HANDLE_VALUE ) goto err_gt;

	// size_a,  size_b : size of file_a, file_b
	size_a = GetFileSize( file_a, NULL );
	size_b = GetFileSize( file_b, NULL );

	if ( size_a == size_b  &&  size_a == 0 ) {
		is_same = true;
	}
	else if ( size_a == size_b ) {

		// mem_a,  mem_b : map to memory from file_a,  file_b
		mem_a = CreateFileMapping( file_a, NULL, PAGE_READONLY, 0, size_a, NULL );
		IF( mem_a == INVALID_HANDLE_VALUE ) goto err_gt;
		mem_b = CreateFileMapping( file_b, NULL, PAGE_READONLY, 0, size_b, NULL );
		IF( mem_b == INVALID_HANDLE_VALUE ) goto err_gt;

		// ptr_a,  ptr_b : pointer of contents in file_a, file_b
		ptr_a = MapViewOfFile( mem_a, FILE_MAP_READ, 0, 0, 0 ); IF(ptr_a==NULL)goto err_gt;
		ptr_b = MapViewOfFile( mem_b, FILE_MAP_READ, 0, 0, 0 ); IF(ptr_b==NULL)goto err_gt;

		// is_same : is same file_a and file_b
		if ( memcmp( ptr_a, ptr_b, size_a ) == 0 )  is_same = true;
	}
	e=0;
fin:
	if ( ptr_a != NULL )                  { b= UnmapViewOfFile( ptr_a ); IF(!b&&!e) e=SaveWindowsLastError(); }
	if ( mem_a  != INVALID_HANDLE_VALUE ) { b= CloseHandle( mem_a );     IF(!b&&!e) e=SaveWindowsLastError(); }
	if ( file_a != INVALID_HANDLE_VALUE ) { b= CloseHandle( file_a );    IF(!b&&!e) e=SaveWindowsLastError(); }
	if ( ptr_b != NULL )                  { b= UnmapViewOfFile( ptr_b ); IF(!b&&!e) e=SaveWindowsLastError(); }
	if ( mem_b  != INVALID_HANDLE_VALUE ) { b= CloseHandle( mem_b );     IF(!b&&!e) e=SaveWindowsLastError(); }
	if ( file_b != INVALID_HANDLE_VALUE ) { b= CloseHandle( file_b );    IF(!b&&!e) e=SaveWindowsLastError(); }
	*out_IsSame = is_same;
	return  e;

err_gt:  e = SaveWindowsLastError();  goto fin;
}


 
/***********************************************************************
  <<< [FileT_callByNestFind] サブフォルダも含めて各ファイルのパスを渡す >>> 
************************************************************************/
typedef struct {
	/*--- inherit from FileT_CallByNestFindData */
	void*     CallerArgument;
	TCHAR*    FullPath;  // abstruct path
	TCHAR*    StepPath;
	TCHAR*    FileName;
	DWORD     FileAttributes;

	/*---*/
	BitField  Flags;
	FuncType  CallbackFromNestFind;
	TCHAR     FullPathMem[4096];
} FileT_CallByNestFindDataIn;

int  FileT_callByNestFind_sub( FileT_CallByNestFindDataIn* m );


int  FileT_callByNestFind( const TCHAR* Path, BitField Flags, void* Argument, FuncType Callback )
{
	int  e;
	FileT_CallByNestFindDataIn  data;

	{
		TCHAR*  p;

		e= StrT_cpy( data.FullPathMem, sizeof(data.FullPathMem), Path ); IF(e)goto fin;


		/* FullPathMem の最後に \ が無いなら追加する */
		p = _tcschr( data.FullPathMem, _T('\0') );
		p--;
		if ( *p != _T('\\') ) {
			p++;
			IF( p >= data.FullPathMem + (sizeof(data.FullPathMem) / sizeof(TCHAR)) - 1 )goto err_fa;
			*p = _T('\\');
		}


		/* data を初期化する */
		data.CallerArgument = Argument;
		data.FullPath = data.FullPathMem;
		data.StepPath = p + 1;
		data.FileName = p + 1;
		data.Flags = Flags;
		data.CallbackFromNestFind = Callback;
	}

	/* 再起呼び出し関数へ */
	e= FileT_callByNestFind_sub( &data ); IF(e)goto fin;

	e=0;
fin:
	return  e;
err_fa: e= E_FEW_ARRAY; goto fin;
}


int  FileT_callByNestFind_sub( FileT_CallByNestFindDataIn* m )
{
	int  e;
	HANDLE  find;
	WIN32_FIND_DATA  data;
	TCHAR*  p;
	int  done;


	/* Path に指定したフォルダに対してコールバックする */
	if ( m->Flags & FileT_FolderBeforeFiles ) {
		*( m->FileName - 1 ) = _T('\0');  // m->FullPath の最後の \ を一時的にカット
		*( m->FileName ) = _T('\0');  // m->FileName, m->StepPath を "" にする
		m->FileAttributes = FILE_ATTRIBUTE_DIRECTORY;

		if ( m->StepPath[0] == _T('\0') ) {
			TCHAR*  step_path = m->StepPath;
			TCHAR*  fname     = m->FileName;

			m->StepPath = _T(".");
			m->FileName = StrT_refFName( m->FullPath );
			e= m->CallbackFromNestFind( m ); IF(e)goto fin;
			m->StepPath = step_path;
			m->FileName = fname;
		}
		else if ( m->FileName[0] == _T('\0') ) {
			TCHAR*  fname = m->FileName;

			m->FileName = StrT_refFName( m->FullPath );
			e= m->CallbackFromNestFind( m ); IF(e)goto fin;
			m->FileName = fname;
		}
		else {
			e= m->CallbackFromNestFind( m ); IF(e)goto fin;
		}
		*( m->FileName - 1 ) = _T('\\');
	}


	/* * を追加 */
	p = m->FileName;
	IF( p >= m->FullPathMem + (sizeof(m->FullPathMem) / sizeof(TCHAR)) - 2 )goto err_fa;
	*p = _T('*');  *(p+1) = _T('\0');


	/* ファイルかフォルダを列挙します */
	find = FindFirstFileEx( m->FullPathMem, FindExInfoStandard, &data,
		FindExSearchNameMatch, NULL, 0 );
	done = ( find == INVALID_HANDLE_VALUE );

	while (!done)
	{
		if ( _tcscmp( data.cFileName, _T(".") ) == 0 ||
				 _tcscmp( data.cFileName, _T("..") ) == 0 ) {
			done = ! FindNextFile( find, &data );
			continue;
		}

		StrT_cpy( m->FileName,
			sizeof(m->FullPathMem) - ( (char*)m->FileName - (char*)m->FullPathMem ),
			data.cFileName );
		m->FileAttributes = data.dwFileAttributes;

		if ( data.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY ) {
			TCHAR*  prev_fname = m->FileName;

			p = _tcschr( m->FileName, _T('\0') );

			IF( p >= m->FullPathMem + (sizeof(m->FullPathMem) / sizeof(TCHAR)) - 2 )goto err_fa;
			*p = _T('\\');  *(p+1) = _T('\0');
			m->FileName = p + 1;

			e= FileT_callByNestFind_sub( m ); IF(e)goto fin;  /* 再起呼び出し */

			m->FileName = prev_fname;
		}
		else {
			e= m->CallbackFromNestFind( m ); IF(e)goto fin;
		}

		done = ! FindNextFile( find, &data );
	}
	FindClose( find );


	/* Path に指定したフォルダに対してコールバックする */
	if ( m->Flags & FileT_FolderAfterFiles ) {
		TCHAR*  step_path = m->StepPath;
		TCHAR*  fname     = m->FileName;

		*( m->FileName - 1 ) = _T('\0');
		m->FileAttributes = FILE_ATTRIBUTE_DIRECTORY;
		if ( ( *( m->StepPath - 1 ) == _T('\0') ) && ( m->StepPath > m->FullPath ) ) {
			m->StepPath = _T(".");
		}
		m->FileName = StrT_refFName( m->FullPath );

		e= m->CallbackFromNestFind( m ); IF(e)goto fin;

		m->StepPath = step_path;
		m->FileName = fname;
	}

	e=0;
fin:
	return  e;
err_fa: e= E_FEW_ARRAY; goto fin;
}


 
/***********************************************************************
  <<< [FileT_openForRead] >>> 
************************************************************************/
int  FileT_openForRead( FILE** out_pFile, const TCHAR* Path )
{
	errno_t  en;

	assert( Locale_isInited() );

	#if DEBUGTOOLS_USES
		{ int e= Debug_onOpen( Path ); if(e) return e; }
	#endif

	en = _tfopen_s( out_pFile, Path, _T("r")_T(fopen_ccs) );
	if ( en == ENOENT ) {
		#ifndef UNDER_CE
		{
			TCHAR  cwd[512];

			if ( _tgetcwd( cwd, _countof(cwd) ) == NULL ) {
				cwd[0] = _T('\0');
			}
			Error4_printf( _T("<ERROR msg=\"Not found\" path=\"%s\" current=\"%s\"/>"),
				Path, cwd );
		}
		#else
			Error4_printf( _T("<ERROR msg=\"Not found\" path=\"%s\"/>"), Path );
		#endif

		return  E_PATH_NOT_FOUND;
	}
	if ( en == EACCES ) {
		Error4_printf( _T("access denied \"%s\"\n"), Path );
		return  E_ACCESS_DENIED;
	}
	IF(en)return  E_OTHERS;

	return  0;
}


 
/***********************************************************************
  <<< [FileT_close] >>> 
************************************************************************/
int  FileT_close( FILE* File, int e )
{
	if ( File != NULL ) {
		int r = fclose( File );
		IF(r&&!e)e=E_ERRNO;
	}
	return e;
}



 
/***********************************************************************
  <<< [FileT_closeAndNULL] >>> 
************************************************************************/
errnum_t  FileT_closeAndNULL( FILE** in_out_File, errnum_t e )
{
	FILE*  file = *in_out_File;

	if ( file != NULL ) {
		int  r = fclose( file );
		IF ( r && e == 0 ) { e = E_ERRNO; }
		*in_out_File = NULL;
	}

	return  e;
}



 
/*=================================================================*/
/* <<< [Error4/Error4.c] >>> */ 
/*=================================================================*/
 
/***********************************************************************
  <<< [Get_Error4_Variables] >>> 
************************************************************************/
static Error4_VariablesClass  gs;
#ifdef _DEBUG
	extern Error4_VariablesClass*  g_Error4_Variables = &gs;
#endif

Error4_VariablesClass*  Get_Error4_Variables()
{
	return  &gs;
}


 
/***********************************************************************
  <<< (SetBreakErrorID) >>> 
************************************************************************/

/*[DebugBreakR]*/
void  DebugBreakR()
{
	printf( "ブレークします。もしデバッガーが接続されていなければ強制終了します。\n" );
	DebugBreak();
		// Visual Studio 2008 では、ここで [ デバッグ > ステップ アウト ] しないと
		// 呼び出し履歴やウォッチの内容が正しくなりません。
}


#if ENABLE_ERROR_BREAK_IN_ERROR_CLASS


#if ! IS_MULTI_THREAD_ERROR_CLASS
	dll_global_g_DebugBreakCount  ErrorClass  g_Error;  /* 初期値はすべてゼロ */
#else
	dll_global_g_DebugBreakCount  GlobalErrorClass  g_GlobalError;

	static errnum_t  ErrorClass_initializeIfNot_Sub( ErrorClass** out_Error );
	static errnum_t  ErrorClass_initializeIfNot_Sub2(void);
#endif


#define  IF_  if  /* Error check for in "IF" macro */


/*[SetBreakErrorID]*/
void  SetBreakErrorID( int ErrorID )
{
#if ! IS_MULTI_THREAD_ERROR_CLASS

	ErrorClass*  err = &g_Error;
	bool         is_print;

	is_print = ( err->BreakErrorID != ErrorID );

	err->BreakErrorID = ErrorID;
		/* printf の中で発生するエラーで止めるため */

	if ( is_print )
		{ printf( ">SetBreakErrorID( %d );\n", ErrorID ); }

#else

	GlobalErrorClass*  err_global = &g_GlobalError;

	if ( err_global->BreakGlobalErrorID != ErrorID )
		{ printf( ">SetBreakErrorID( %d );\n", ErrorID ); }
	err_global->BreakGlobalErrorID = ErrorID;

#endif
}



bool  OnRaisingError_Sub( const char* FilePath, int LineNum )
 // 本関数は、IF マクロの中から呼ばれます
 // 返り値は、ブレークするかどうか
{
#if ! IS_MULTI_THREAD_ERROR_CLASS

	ErrorClass*  err = &g_Error;
	bool  is_break;

	/* エラー時の中断処理（ジャンプ）をしているとき（高速リターン） */
	if ( err->IsError ) {
		return  false;
	}

	/* エラーが発生した直後のとき */
	err->ErrorID += 1;
	err->IsError = true;
	err->FilePath = FilePath;
	err->LineNum  = LineNum;

	#if ERR2_ENABLE_ERROR_LOG
		printf( "<ERROR_LOG msg=\"raised\" ErrorID=\"%d\" ErrorObject=\"0x%08X\"/>\n",
			err->ErrorID, (int) err );
	#endif

	is_break = ( err->ErrorID == err->BreakErrorID );

	if ( is_break ) {
		printf( "Break in (%d) %s\n", LineNum, FilePath );
	}
	return  ( err->ErrorID == err->BreakErrorID );

#else  /* IS_MULTI_THREAD_ERROR_CLASS */

	errnum_t           e;
	bool               is_break = false;
	ErrorClass*        err;

	e= ErrorClass_initializeIfNot_Sub( &err ); IF_(e){goto fin;}


	/* エラー時の中断処理（ジャンプ）をしているとき（高速リターン） */
	if ( err->IsError ) {
		return  false;
	}

	/* エラーが発生した直後のとき */
	else {
		GlobalErrorClass*  err_global = &g_GlobalError;

		EnterCriticalSection( &err_global->CriticalSection );


		err_global->ErrorThreadCount += 1;
		err_global->RaisedGlobalErrorID += 1;
		err->GlobalErrorID = err_global->RaisedGlobalErrorID;

		err->ErrorID += 1;
		err->IsError = true;
		err->FilePath = FilePath;
		err->LineNum  = LineNum;

		is_break = ( err->ErrorID == err->BreakErrorID ) ||
			( err->GlobalErrorID == err_global->BreakGlobalErrorID );


		/* ここより以降は、IF マクロなどを呼び出し可能（リエントラント可能） */
		/* 上記の if ( err->IsError ) で、すぐ戻るため */


		#if ERR2_ENABLE_ERROR_LOG
			printf( "<ERROR_LOG msg=\"raised\" ErrorID=\"%d\" ErrorObject=\"0x%08X\"/>\n",
				err->GlobalErrorID, (int) err );
		#endif


		if ( err->ErrorID == 1 ) {
			FinalizerClass_initConst( &err->Finalizer, err, ErrorClass_finalize );
			e= AddThreadLocalFinalizer( &err->Finalizer );
		}
		else {
			e = 0;
		}
		LeaveCriticalSection( &err_global->CriticalSection );
		IF(e){goto fin;}
	}

	e=0;
fin:
	if ( is_break ) {
		printf( "Break in (%d) %s\n", LineNum, FilePath );
	}
	return  is_break;

#endif  /* IS_MULTI_THREAD_ERROR_CLASS */
}


//[ClearError]
void  ClearError()
{
#if ! IS_MULTI_THREAD_ERROR_CLASS

	ErrorClass*  err = &g_Error;

	#if ERR2_ENABLE_ERROR_LOG
	if ( err->IsError ) {
		printf( "<ERROR_LOG msg=\"cleared\" ErrorID=\"%d\" ErrorObject=\"0x%08X\"/>\n",
			err->ErrorID, (int) err );
	}
	#endif

	err->IsError = false;

#else  /* IS_MULTI_THREAD_ERROR_CLASS */

	errnum_t     e;
	ErrorClass*  err;

	e= ErrorClass_initializeIfNot_Sub( &err );
	if ( e == 0 ) {
		#if ERR2_ENABLE_ERROR_LOG
		if ( err->IsError )
			printf( "<ERROR_LOG msg=\"cleared\" ErrorID=\"%d\" ErrorObject=\"0x%08X\"/>\n",
				err->GlobalErrorID, (int) err );
		#endif

		if ( err->IsError ) {
			GlobalErrorClass*  err_global = &g_GlobalError;

			EnterCriticalSection( &err_global->CriticalSection );
			err_global->ErrorThreadCount -= 1;
			LeaveCriticalSection( &err_global->CriticalSection );

			err->IsError = false;
		}
	}
	else {
		#if ERR2_ENABLE_ERROR_LOG
			printf( "<ERROR_LOG msg=\"clear_miss\"/>\n" );
		#endif
	}

#endif  /* IS_MULTI_THREAD_ERROR_CLASS */
}


//[IfErrThenBreak]
void  IfErrThenBreak()
{
#if ! IS_MULTI_THREAD_ERROR_CLASS

	ErrorClass*  err = &g_Error;

	if ( err->IsError  &&
		( err->ErrorID != err->BreakErrorID || err->BreakErrorID == 0 )
	) {
		printf( "in IfErrThenBreak\n" );
		DebugBreakR();

		// ウォッチで、err->ErrorID の値(Nとする)を確認して、
		// メイン関数で SetBreakErrorID( N ); を呼び出してください。
		// エラーが発生した場所は、err->FilePath, err->LineNum です。
		// 正常終了しているつもりなのにここでブレークするときは、
		// ClearError() を忘れている可能性があります。
		#if ERR2_ENABLE_ERROR_LOG
			printf( "<ERROR_LOG msg=\"IfErrThenBreak\" ErrorID=\"%d\" BreakErrorID=\"%d\"/>\n",
				err->ErrorID, err->BreakErrorID );
		#endif

		{
			char  str[512];
			sprintf_s( str, _countof(str), "<ERROR file=\"%s(%d)\"/>\n",
				err->FilePath, err->LineNum );
			OutputDebugStringA( str );
		}
	}
	ClearError();

#else  /* IS_MULTI_THREAD_ERROR_CLASS */

	errnum_t           e;
	GlobalErrorClass*  err_global = &g_GlobalError;
	ErrorClass*        err;

	e= ErrorClass_initializeIfNot_Sub( &err );
	if ( e ) { DebugBreakR();  ClearError();  return; }  /* 内部エラー */

	if ( err_global->ErrorThreadCount != 0  &&
		( err->GlobalErrorID != err_global->BreakGlobalErrorID || err_global->BreakGlobalErrorID == 0 )
	) {
		printf( "in IfErrThenBreak\n" );
		DebugBreakR();

		// ウォッチで、err->GlobalErrorID の値(Nとする)を確認して、
		// メイン関数で SetBreakErrorID( N ); を呼び出してください。
		// エラーが発生した場所は、err->FilePath, err->LineNum です。
		// 正常終了しているつもりなのにここでブレークするときは、
		// ClearError() を忘れている可能性があります。
		#if ERR2_ENABLE_ERROR_LOG
			printf( "<ERROR_LOG msg=\"IfErrThenBreak\" ErrorID=\"%d\" BreakErrorID=\"%d\"/>\n",
				err->ErrorID, err->BreakErrorID );
		#endif

		{
			char  str[512];
			sprintf_s( str, _countof(str), "<ERROR file=\"%s(%d)\"/>\n",
				err->FilePath, err->LineNum );
			OutputDebugStringA( str );
		}
	}
	ClearError();

#endif  /* IS_MULTI_THREAD_ERROR_CLASS */
}


//[MergeError]
errnum_t  MergeError( errnum_t e, errnum_t ee )
{
	if ( e == 0 ) { return  ee; }
	else          { /* ErrorLog_add( ee ); */ return  e; }
}


//[PushErr]
void  PushErr( ErrStackAreaClass* ErrStackArea )
{
#if ! IS_MULTI_THREAD_ERROR_CLASS

	ErrorClass*  err = &g_Error;

	ErrStackArea->ErrorID = err->ErrorID;
	ErrStackArea->IsError = err->IsError;
	err->IsError = false;

#else  /* IS_MULTI_THREAD_ERROR_CLASS */

	errnum_t     e;
	ErrorClass*  err;

	e= ErrorClass_initializeIfNot_Sub( &err );
	if ( e == 0 ) {
		ErrStackArea->ErrorID = err->ErrorID;
		ErrStackArea->IsError = err->IsError;
		err->IsError = false;
	}

#endif  /* IS_MULTI_THREAD_ERROR_CLASS */
}

//[PopErr]
void  PopErr(  ErrStackAreaClass* ErrStackArea )
{
#if ! IS_MULTI_THREAD_ERROR_CLASS

	ErrorClass*  err = &g_Error;

	if ( ErrStackArea->IsError )
		{ err->IsError = true; }

#else  /* IS_MULTI_THREAD_ERROR_CLASS */

	errnum_t     e;
	ErrorClass*  err;

	e= ErrorClass_initializeIfNot_Sub( &err );
	if ( e == 0 ) {
		if ( ErrStackArea->IsError )
			{ err->IsError = true; }
	}

#endif  /* IS_MULTI_THREAD_ERROR_CLASS */
}


 
/*[SetBreakErrorID:2]*/
#undef  IF_


#endif // ENABLE_ERROR_BREAK_IN_ERROR_CLASS

 
/***********************************************************************
  <<< [g_Error4_String] >>> 
************************************************************************/
TCHAR  g_Error4_String[4096];


 
/***********************************************************************
  <<< [Error4_printf] >>> 
************************************************************************/
void  Error4_printf( const TCHAR* format, ... )
{
	va_list  va;
	va_start( va, format );
	vstprintf_r( g_Error4_String, sizeof(g_Error4_String), format, va );
	va_end( va );
}


 
/***********************************************************************
  <<< [Error4_getErrStr] >>> 
************************************************************************/
void  Error4_getErrStr( int ErrNum, TCHAR* out_ErrStr, size_t ErrStrSize )
{
	switch ( ErrNum ) {

		case  0:
			stprintf_r( out_ErrStr, ErrStrSize, _T("no error") );
			break;

		case  E_FEW_ARRAY:
			stprintf_r( out_ErrStr, ErrStrSize,
				_T("<ERROR msg=\"プログラム内部の配列メモリーが不足しました。\"/>") );
			break;

		case  E_FEW_MEMORY:
			stprintf_r( out_ErrStr, ErrStrSize,
				_T("<ERROR msg=\"ヒープ・メモリーが不足しました。\"/>") );
			break;

		#ifndef  __linux__
		case  E_GET_LAST_ERROR: {
			DWORD   err_win;
			TCHAR*  str_pointer;

			err_win = gs.WindowsLastError;
			if ( err_win == 0 ) { err_win = GetLastError(); }

			stprintf_part_r( out_ErrStr, ErrStrSize, out_ErrStr, &str_pointer,
				_T("<ERROR GetLastError=\"0x%08X\" GetLastErrorStr=\""), err_win );
			FormatMessage( FORMAT_MESSAGE_IGNORE_INSERTS | FORMAT_MESSAGE_FROM_SYSTEM,
				NULL, err_win, LANG_USER_DEFAULT,
				str_pointer,  (TCHAR*)( (char*)out_ErrStr + ErrStrSize ) - str_pointer, NULL );
			str_pointer = _tcschr( str_pointer, _T('\0') );
			if ( *( str_pointer - 2 ) == _T('\r') && *( str_pointer - 1 ) == _T('\n') )
				str_pointer -= 2;
			stcpy_part_r( out_ErrStr, ErrStrSize, str_pointer, NULL, _T("\"/>"), NULL );
			break;
		}
		#endif

		default:
			if ( g_Error4_String[0] != '\0' )
				stprintf_r( out_ErrStr, ErrStrSize, _T("%s"), g_Error4_String );
			else
				stprintf_r( out_ErrStr, ErrStrSize, _T("<ERROR errnum=\"%d\"/>"), ErrNum );
			break;
	}
}


 
/***********************************************************************
  <<< [SaveWindowsLastError] >>> 
************************************************************************/
errnum_t  SaveWindowsLastError()
{
	gs.WindowsLastError = GetLastError();
	return  E_GET_LAST_ERROR;
}


 
/***********************************************************************
  <<< [Error4_showToStdErr] >>> 
************************************************************************/
void  Error4_showToStdErr( int err_num )
{
	TCHAR  msg[1024];
	#if _UNICODE
		char  msg2[1024];
	#endif

	if ( err_num != 0 ) {
		Error4_getErrStr( err_num, msg, sizeof(msg) );
		#if _UNICODE
			setlocale( LC_ALL, ".OCP" );
			sprintf_s( msg2, sizeof(msg2), "%S", msg );
			fprintf( stderr, "%s\n", msg2 );  // _ftprintf_s では日本語が出ません
		#else
			fprintf( stderr, "%s\n", msg );
		#endif

		#if ERR2_ENABLE_ERROR_BREAK
			fprintf( stderr, "（開発者へ）メイン関数で SetBreakErrorID( %d ); を呼び出してください。\n",
				g_Err2.ErrID );
		#else
#if 0
			if ( err_num == E_FEW_MEMORY  ||  gs.WindowsLastError == ERROR_NOT_ENOUGH_MEMORY ) {
				/* Not show the message for developper */
			}
			else {
				fprintf( stderr, "（開発者へ）ERR2_ENABLE_ERROR_BREAK を定義して再コンパイルしてください。\n" );
			}
#endif
		#endif
	}
	IfErrThenBreak();
}


 
/***********************************************************************
  <<< [Error4_raiseErrno] >>> 
************************************************************************/
#include <errno.h>

int  Error4_raiseErrno()
{
	int   e, e2;
	TCHAR  msg[256];

	e2 = _get_errno( &e );
	if ( e2 != 0 )  { Error4_printf( _T("ERROR in _get_errno") );  return  E_UNKNOWN; }
	e2 = _tcserror_s( msg, sizeof(msg)/sizeof(TCHAR), e );
	if ( e2 != 0 )  { Error4_printf( _T("ERROR in strerror_s") );  return  E_UNKNOWN; }

	Error4_printf( _T("ERROR (%d) %s\n"), e, msg );
	return  E_ERRNO;
}


 
/*=================================================================*/
/* <<< [StrT/StrT.c] >>> */ 
/*=================================================================*/
 
/***********************************************************************
  <<< [StrT_cpy] >>> 
- _tcscpy is raising exception, if E_FEW_ARRAY
************************************************************************/
errnum_t  StrT_cpy( TCHAR* Dst, size_t DstSize, const TCHAR* Src )
{
	size_t  size;

	size = ( _tcslen( Src ) + 1 ) * sizeof(TCHAR);
	if ( size <= DstSize ) {
		memcpy( Dst, Src, size );
		return  0;
	}
	else {
		memcpy( Dst, Src, DstSize - sizeof(TCHAR) );
		*(TCHAR*)( (char*) Dst + DstSize ) = _T('\0');
		return  E_FEW_ARRAY;
	}
}

 
/***********************************************************************
  <<< [MallocAndCopyString] >>> 
************************************************************************/
errnum_t  MallocAndCopyString( const TCHAR** out_NewString, const TCHAR* SourceString )
{
	TCHAR*  str;
	size_t  size = ( _tcslen( SourceString ) + 1 ) * sizeof(TCHAR);

	ASSERT_D( *out_NewString == NULL, __noop() );

	str = (TCHAR*) malloc( size );
	if ( str == NULL ) { return  E_FEW_MEMORY; }

	memcpy( str, SourceString, size );

	*out_NewString = str;
	return  0;
}


 
/***********************************************************************
  <<< [MallocAndCopyString_char] >>> 
************************************************************************/
#ifdef _UNICODE
errnum_t  MallocAndCopyString_char( const TCHAR** out_NewString, const char* SourceString )
{
	TCHAR*  str;
	size_t  size = ( strlen( SourceString ) + 1 ) * sizeof(TCHAR);
	int     r;

	str = (TCHAR*) malloc( size );
	if ( str == NULL ) { return  E_FEW_MEMORY; }

	r = MultiByteToWideChar( CP_OEMCP, MB_PRECOMPOSED, SourceString, -1, str, size / sizeof(TCHAR) );
	IF ( r == 0 ) {
		free( str );
		return  E_GET_LAST_ERROR;
	}
	*out_NewString = str;
	return  0;
}
#endif


 
/***********************************************************************
  <<< [MallocAndCopyStringByLength] >>> 
************************************************************************/
errnum_t  MallocAndCopyStringByLength( const TCHAR** out_NewString, const TCHAR* SourceString,
	unsigned CountOfCharacter )
{
	TCHAR*  str;
	size_t  size = ( CountOfCharacter + 1 ) * sizeof(TCHAR);

	ASSERT_D( *out_NewString == NULL, __noop() );

	str = (TCHAR*) malloc( size );
	if ( str == NULL ) { return  E_FEW_MEMORY; }

	memcpy( str, SourceString, size - sizeof(TCHAR) );
	str[ CountOfCharacter ] = _T('\0');

	*out_NewString = str;
	return  0;
}


 
/***********************************************************************
  <<< [StrT_chrs] >>> 
************************************************************************/
TCHAR*  StrT_chrs( const TCHAR* s, const TCHAR* keys )
{
	if ( *keys == _T('\0') )  return  NULL;

	for ( ; *s != _T('\0'); s++ ) {
		if ( _tcschr( keys, *s ) != NULL )
			return  (TCHAR*) s;
	}
	return  NULL;
}


 
/***********************************************************************
  <<< [StrT_rstr] >>> 
************************************************************************/
TCHAR*  StrT_rstr( const TCHAR* String, const TCHAR* SearchStart, const TCHAR* Keyword,
	void* NullConfig )
{
	const TCHAR*  p;
	int           keyword_length = _tcslen( Keyword );
	TCHAR         keyword_first = Keyword[0];

	UNREFERENCED_VARIABLE( NullConfig );

	p = SearchStart;
	while ( p >= String ) {
		if ( *p == keyword_first ) {
			if ( _tcsncmp( p, Keyword, keyword_length ) == 0 ) {
				return  (TCHAR*) p;
			}
		}
		p -= 1;
	}

	return  NULL;
}


 
/***********************************************************************
  <<< [StrT_skip] >>> 
************************************************************************/
TCHAR*  StrT_skip( const TCHAR* s, const TCHAR* keys )
{
	if ( *keys == _T('\0') )  return  (TCHAR*) s;

	for ( ; *s != _T('\0'); s++ ) {
		if ( _tcschr( keys, *s ) == NULL )
			break;
	}
	return  (TCHAR*) s;
}


 
/***********************************************************************
  <<< [StrT_isCIdentifier] >>> 
************************************************************************/
bool  StrT_isCIdentifier( TCHAR Character )
{
	const TCHAR  c = Character;

	return  (
		( c >= _T('A')  &&  c <= _T('Z') ) ||
		( c >= _T('a')  &&  c <= _T('z') ) ||
		( c >= _T('0')  &&  c <= _T('9') ) ||
		c == _T('_') );
}


 
/***********************************************************************
  <<< [StrT_searchOverOfCIdentifier] >>> 
************************************************************************/
TCHAR*  StrT_searchOverOfCIdentifier( const TCHAR* Text )
{
	const TCHAR*  p;
	TCHAR         c;

	p = Text;
	c = *p;
	for (;;) {
		if ( StrT_isCIdentifier( c ) ) {
			p += 1;
			c = *p;
		}
		else {
			return  (TCHAR*) p;
		}
	}
}


 
/***********************************************************************
  <<< [StrT_cmp_part] >>> 
************************************************************************/
int  StrT_cmp_part( const TCHAR* StringA_Start, const TCHAR* StringA_Over,
	const TCHAR* StringB )
{
	const TCHAR*  a;
	const TCHAR*  b;
	TCHAR  aa;
	TCHAR  bb;

	a = StringA_Start;
	b = StringB;

	for (;;) {
		if ( a >= StringA_Over ) {
			bb = *b;
			if ( bb == _T('\0') )
				{ return  0; }
			else
				{ return  -bb; }
		}

		aa = *a;
		bb = *b;

		if ( bb == _T('\0') )
			{ return  aa; }

		if ( aa != bb )
			{ return  aa - bb; }

		a += 1;
		b += 1;
	}
}


 
/***********************************************************************
  <<< [StrT_cmp_part2] >>> 
************************************************************************/
int  StrT_cmp_part2( const TCHAR* StringA_Start, const TCHAR* StringA_Over,
	const TCHAR* StringB_Start, const TCHAR* StringB_Over )
{
	int  length_A = StringA_Over - StringA_Start;
	int  length_B = StringB_Over - StringB_Start;

	if ( length_A != length_B ) {
		return  length_A - length_B;
	}
	else {
		return  _tcsncmp( StringA_Start, StringB_Start, length_A );
	}
}


 
/***********************************************************************
  <<< [StrT_refFName] >>> 
************************************************************************/
TCHAR*  StrT_refFName( const TCHAR* s )
{
	const TCHAR*  p;
	TCHAR  c;

	p = _tcschr( s, _T('\0') );

	if ( p == s )  return  (TCHAR*) s;

	for ( p--; p>s; p-- ) {
		c = *p;
		if ( c == _T('\\') || c == _T('/') )  return  (TCHAR*) p+1;
	}
	if ( *p == _T('\\') || *p == _T('/') )  return  (TCHAR*) p+1;

	return  (TCHAR*) s;
}
 
/***********************************************************************
  <<< [StrT_refExt] >>> 
************************************************************************/
TCHAR*  StrT_refExt( const TCHAR* s )
{
	const TCHAR*  p;

	p = _tcschr( s, _T('\0') );

	if ( p == s )  return  (TCHAR*) s;

	for ( p--; p>s; p-- ) {
		if ( *p == _T('.') )  return  (TCHAR*) p+1;
		if ( *p == _T('/') || *p == _T('\\') )  return  (TCHAR*) _tcschr( p, _T('\0') );
	}
	if ( *p == _T('.') )  return  (TCHAR*) p+1;

	return  (TCHAR*) _tcschr( s, _T('\0') );
}


 
/***********************************************************************
  <<< [StrT_replace1] >>> 
************************************************************************/
errnum_t  StrT_replace1( TCHAR* in_out_String, TCHAR FromCharacter, TCHAR ToCharacter,
	unsigned Opt )
{
	TCHAR*  p;

	UNREFERENCED_VARIABLE( Opt );

	IF ( FromCharacter == _T('\0') )  { return  E_OTHERS; }

	p = in_out_String;
	for (;;) {
		p = _tcschr( p, FromCharacter );
		if ( p == NULL )  { break; }
		*p = ToCharacter;
		p += 1;
	}

	return  0;
}


 
/***********************************************************************
  <<< [StrT_trim] >>> 
************************************************************************/
errnum_t  StrT_trim( TCHAR* out_Str, size_t out_Str_Size, const TCHAR* in_Str )
{
	const TCHAR*  p1;
	const TCHAR*  p2;
	TCHAR   c;

	p1 = in_Str;  while ( *p1 == _T(' ') || *p1 == _T('\t') )  p1++;
	for ( p2 = _tcschr( p1, _T('\0') ) - 1;  p2 >= p1;  p2-- ) {
		c = *p2;
		if ( c != _T(' ') && c != _T('\t') && c != _T('\n') && c != _T('\r') )
			break;
	}
	return  stcpy_part_r( out_Str, out_Str_Size, out_Str, NULL, p1, p2+1 );
}


 
/***********************************************************************
  <<< [StrT_cutLastOf] >>> 
************************************************************************/
errnum_t  StrT_cutLastOf( TCHAR* in_out_Str, TCHAR Charactor )
{
	TCHAR*  last = _tcschr( in_out_Str, _T('\0') );

	if ( last > in_out_Str ) {
		if ( *( last - 1 ) == Charactor )
			{ *( last - 1 ) = _T('\0'); }
	}
	return  0;
}


 
/***********************************************************************
  <<< [StrT_cutLineComment] >>> 
************************************************************************/
errnum_t  StrT_cutLineComment( TCHAR* out_Str, size_t out_Str_Size, const TCHAR* in_Str, const TCHAR* CommentSign )
{
	const TCHAR*  p1;
	const TCHAR*  p2;
	TCHAR   c;

	p1 = in_Str;  while ( *p1 == _T(' ') || *p1 == _T('\t') )  p1++;

	p2 = _tcsstr( p1, CommentSign );
	if ( p2 == NULL )  p2 = _tcschr( p1, _T('\0') );

	for ( p2 = p2 - 1;  p2 >= p1;  p2-- ) {
		c = *p2;
		if ( c != _T(' ') && c != _T('\t') && c != _T('\n') && c != _T('\r') )
			break;
	}
	return  stcpy_part_r( out_Str, out_Str_Size, out_Str, NULL, p1, p2+1 );
}


 
/**************************************************************************
  <<< [StrT_meltCSV] >>> 
*************************************************************************/
errnum_t  StrT_meltCSV( TCHAR* out_Str, size_t out_Str_Size, const TCHAR** pCSV )
{
	errnum_t  e = 0;
	TCHAR*  t;
	TCHAR*  t_last = (TCHAR*)( (char*)out_Str + out_Str_Size - sizeof(TCHAR) );
	const TCHAR*  s;
	TCHAR  dummy[2];
	TCHAR  c;

	t = out_Str;
	s = *pCSV;
	if ( out_Str_Size <= 1 )  { t = dummy;  t_last = dummy; }

	if ( s == NULL ) { *t = _T('\0');  return 0; }


	/* 頭の空白を除く */
	while ( *s == _T(' ') || *s == _T('\t') )  s++;

	switch ( *s ) {

		/* "" で囲まれている場合 */
		case _T('"'):
			s++;
			c = *s;
			while ( c != _T('"') || *(s+1) == _T('"') ) {  /* " 文字まで */
				if ( t == t_last ) { e = E_FEW_ARRAY;  t = dummy;  t_last = dummy + 1; }
				if ( c == *(s+1) && c == _T('"') )  s++;  /* " 文字自体 */
				if ( c == _T('\0') )  break;
				*t = c;  t++;  s++;  c = *s;
			}
			*t = _T('\0');

			s++;
			for (;;) {
				if ( *s == _T(',') )  { s = s+1;  break; }
				if ( *s == _T('\0') ) { s = NULL;  break; }
				s++;
			}
			*pCSV = s;
			return  e;

		/* 空の項目の場合 */
		case ',':
			*t = _T('\0');
			*pCSV = s+1;
			return  0;

		case '\0':
			*t = _T('\0');
			*pCSV = NULL;
			return  0;

		/* "" で囲まれていない場合 */
		default: {
			TCHAR*  sp = NULL;  /* 最後の連続した空白の先頭 */

			c = *s;
			while ( c != _T(',') && c != _T('\0') && c != _T('\r') && c != _T('\n') ) {  /* , 文字まで */

				/* sp を設定する */
				if ( c == ' ' ) {
					if ( sp == NULL )  sp = t;
				}
				else  sp = NULL;

				if ( t == t_last ) { e = E_FEW_ARRAY;  t = dummy;  t_last = dummy + 1; }

				/* コピーする */
				*t = c;  t++;  s++;  c = *s;
			}

			/* 返り値を決定する */
			if ( c == _T(',') )  s = s + 1;
			else  s = NULL;

			/* 末尾の空白を取り除く */
			if ( sp != NULL )  *sp = '\0';
			else  *t = _T('\0');

			*pCSV = s;
			return  e;
		}
	}
}


 
/***********************************************************************
  <<< [StrT_parseCSV_f] >>> 
************************************************************************/
errnum_t  StrT_parseCSV_f( const TCHAR* StringOfCSV, bit_flags32_t* out_ReadFlags, const TCHAR* Types, ... )
{
	errnum_t       e;
	TCHAR          type;
	int            types_index;
	va_list        va;
	bool           is_next_omittable;
	bool           is_next_omit;
	const TCHAR*   column_pointer;
	TCHAR          a_char;
	TCHAR          column[ 32 ];
	bit_flags32_t  read_flags;
	bit_flags32_t  next_read_flag;
	TCHAR*         out_str;
	size_t         str_size;


	va_start( va, Types );
	types_index = 0;
	is_next_omittable = false;
	column_pointer = StringOfCSV;
	read_flags = 0;
	next_read_flag = 1;
	while ( column_pointer != NULL ) {
		out_str = NULL;

		type = Types[ types_index ];
		switch ( type ) {
			case  _T('\0'):
				goto exit_for;

			case  _T('+'):
				is_next_omittable = true;
				break;

			case  _T('s'):
				out_str = va_arg( va, TCHAR* );
				str_size = va_arg( va, size_t );
				ASSERT_D( str_size >= 1,  e=E_OTHERS; goto fin );
				break;

			default:
				out_str = column;
				str_size = sizeof( column );
				break;
		}

		if ( out_str != NULL ) {

			// Set "out_str" : Column string in CSV
			column_pointer = StrT_skip( column_pointer, _T(" \t") );
			a_char = *column_pointer;
			if ( is_next_omittable  &&  ( a_char == _T('\0')  ||  a_char == _T(',') ) ) {
				column_pointer = StrT_chrs( column_pointer, _T(",") );
				if ( column_pointer != NULL ) { column_pointer += 1; }
				is_next_omit = true;
			} else {
				e= StrT_meltCSV( out_str, str_size, &column_pointer ); IF(e){goto fin;}

				is_next_omit = false;
				read_flags |= next_read_flag;
			}

			switch ( type ) {
				case  _T('s'):
					/* "va_arg" was already called */
					break;

				case  _T('i'): {
					int*  pointer_of_int = va_arg( va, int* );

					if ( ! is_next_omit ) {
						*pointer_of_int = ttoi_ex( column, 0 );
					}
					break;
				}
				case  _T('f'): {
					double*  pointer_of_double = va_arg( va, double* );

					if ( ! is_next_omit ) {
						*pointer_of_double = _tstof( column );
					}
					break;
				}
				case  _T('b'): {
					bool*  pointer_of_bool = va_arg( va, bool* );
					int    strings_index;
					static const TCHAR*  strings[] = {
						_T("1"), _T("true"), _T("yes"),
					};

					if ( ! is_next_omit ) {
						*pointer_of_bool = false;
						for ( strings_index = 0;
							strings_index < _countof( strings );
							strings_index += 1 )
						{
							if ( _tcsicmp( column, strings[ strings_index ] ) == 0 ) {
								*pointer_of_bool = true;
								break;
							}
						}
					}
					break;
				}
				case  _T('t'): {
					SYSTEMTIME*  pointer_of_time = va_arg( va, SYSTEMTIME* );
					int*         pointer_of_bias = va_arg( va, int* );

					if ( ! is_next_omit ) {
						e= W3CDTF_toSYSTEMTIME( column, pointer_of_time, pointer_of_bias );
							IF(e){goto fin;}
					}
					break;
				}

				default:
					ASSERT_R( false, e=E_OTHERS; goto fin );
			}

			is_next_omittable = false;
			next_read_flag <<= 1;
		}

		types_index += 1;
	}
exit_for:
	if ( out_ReadFlags != NULL ) {
		*out_ReadFlags = read_flags;
	}

	e=0;
fin:
	va_end( va );
	return  e;
}


 
/***********************************************************************
  <<< [StrT_getExistSymbols] >>> 
************************************************************************/
errnum_t  StrT_getExistSymbols( unsigned* out, bool bCase, const TCHAR* Str, const TCHAR* Symbols, ... )
{
	errnum_t  e;
	int       i;
	TCHAR** syms = NULL;
	bool*   syms_exists = NULL;
	bool    b_nosym = false;
	TCHAR*  sym = NULL;
	size_t  sym_size = ( _tcslen( Symbols ) + 1 ) * sizeof(TCHAR);
	int     n_sym = 0;
	const TCHAR*  p;

	UNREFERENCED_VARIABLE( bCase );

	sym = (TCHAR*) malloc( sym_size ); IF(sym==NULL)goto err_fm;


	//=== Get Symbols
	p = Symbols;
	do {
		e= StrT_meltCSV( sym, sym_size, &p ); IF(e)goto fin;
		if ( sym[0] != _T('\0') )  n_sym ++;
	} while ( p != NULL );

	syms = (TCHAR**) malloc( n_sym * sizeof(TCHAR*) ); IF(syms==NULL)goto err_fm;
	memset( syms, 0, n_sym * sizeof(TCHAR*) );
	syms_exists = (bool*) malloc( n_sym * sizeof(bool) ); IF(syms_exists==NULL)goto err_fm;
	memset( syms_exists, 0, n_sym * sizeof(bool) );

	p = Symbols;  i = 0;
	do {
		e= StrT_meltCSV( sym, sym_size, &p ); IF(e)goto fin;
		if ( sym[0] != _T('\0') ) {
			e= MallocAndCopyString( &syms[i], sym ); IF(e)goto fin;
			i++;
		}
	} while ( p != NULL );


	//=== Check Str whether having Symbols
	p = Str;
	do {
		e= StrT_meltCSV( sym, sym_size, &p ); IF(e)goto fin;
		if ( sym[0] != _T('\0') ) {
			for ( i = 0; i < n_sym; i++ ) {
				if ( _tcscmp( sym, syms[i] ) == 0 )  { syms_exists[i] = true;  break; }
			}
			if ( i == n_sym )  b_nosym = true;
		}
	} while ( p != NULL );


	//=== Sum numbers
	{
		va_list   va;
		unsigned  num;

		va_start( va, Symbols );
		*out = 0;
		for ( i = 0; i < n_sym; i++ ) {
			num = va_arg( va, unsigned );
			if ( syms_exists[i] )  *out |= num;
		}
		va_end( va );
	}

	e = ( b_nosym ? E_NOT_FOUND_SYMBOL : 0 );
fin:
	if ( syms != NULL ) {
		for ( i = 0; i < n_sym; i++ ) {
			if ( syms[i] != NULL )  free( syms[i] );
		}
		free( syms );
	}
	if ( syms_exists != NULL )  free( syms_exists );
	if ( sym != NULL )  free( sym );
	return  e;
err_fm: e= E_FEW_MEMORY; goto fin;
}

 
/**************************************************************************
  <<< [StrT_meltCmdLine] >>> 
*************************************************************************/
errnum_t  StrT_meltCmdLine( TCHAR* out_Str, size_t out_Str_Size, const TCHAR** pLine )
{
	errnum_t  e = 0;
	TCHAR*  t;
	TCHAR*  t_last = (TCHAR*)( (char*)out_Str + out_Str_Size - sizeof(TCHAR) );
	const TCHAR*  s;
	TCHAR  dummy;
	TCHAR  c;

	t = out_Str;
	s = *pLine;
	if ( out_Str_Size <= 1 )  { t = &dummy;  t_last = &dummy; }

	if ( s == NULL ) { *t = _T('\0');  return 0; }


	/* 頭の空白を除く */
	while ( *s == _T(' ') || *s == _T('\t') )  s++;

	switch ( *s ) {

		/* "" で囲まれている場合 */
		case _T('"'):
			s++;
			c = *s;
			while ( c != _T('"') || *(s+1) == _T('"') ) {  /* " 文字まで */
				if ( t == t_last ) { e = E_FEW_ARRAY;  t = &dummy;  t_last = &dummy + 1; }
				if ( c == *(s+1) && c == _T('"') )  s++;  /* " 文字自体 */
				if ( c == _T('\0') )  break;
				*t = c;  t++;  s++;  c = *s;
			}
			*t = _T('\0');

			s++;
			for (;;) {
				if ( *s == _T(' ') )  { s = s+1;  break; }
				if ( *s == _T('\0') ) { s = NULL;  break; }
				s++;
			}
			*pLine = s;
			return  e;

		case '\0':
			*t = _T('\0');
			*pLine = NULL;
			return  0;

		/* "" で囲まれていない場合 */
		default: {
			c = *s;
			while ( c != _T(' ') && c != _T('\0') && c != _T('\r') && c != _T('\n') ) {  /* 空白文字まで */

				if ( t == t_last ) { e = E_FEW_ARRAY;  t = &dummy;  t_last = &dummy + 1; }

				/* コピーする */
				*t = c;  t++;  s++;  c = *s;
			}

			/* *pLineを決定する */
			while ( *s == _T(' ') )  s = s + 1;
			if ( *s == _T('\0') )  s = NULL;

			/* 末尾 */
			*t = _T('\0');

			*pLine = s;
			return  e;
		}
	}
}


 
/***********************************************************************
  <<< [W3CDTF_fromSYSTEMTIME] >>> 
************************************************************************/
errnum_t  W3CDTF_fromSYSTEMTIME( TCHAR* out_W3CDTF, size_t W3CDTF_ByteSize,
	const SYSTEMTIME* Time, int TimeZoneMinute )
{
	errnum_t  e;
	TCHAR*    char_pointer = out_W3CDTF;

	e= stprintf_part_r( out_W3CDTF, W3CDTF_ByteSize, char_pointer, &char_pointer,
		_T("%04d-%02d-%02dT%02d:%02d:%02d.%03d"),
		Time->wYear, Time->wMonth,  Time->wDay,
		Time->wHour, Time->wMinute, Time->wSecond, Time->wMilliseconds );
		IF(e){goto fin;}

	e= W3CDTF_getTimeZoneDesignator( char_pointer,
		GetStringSizeFromPointer( out_W3CDTF, W3CDTF_ByteSize, char_pointer ),
		TimeZoneMinute ); IF(e){goto fin;}

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [W3CDTF_toSYSTEMTIME] >>> 
************************************************************************/
errnum_t  W3CDTF_toSYSTEMTIME( const TCHAR* String, SYSTEMTIME* out_Time, int* out_BiasMinute )
{
	errnum_t  e;
	size_t    string_length = _tcslen( String );

	/* 01234567890123456789012345678 */
	/*"yyyy-mm-ddThh:mm:ss.sss+00:00"*/
	/*"0000-00-00T00:00+00:00"*/

	IF_D( out_BiasMinute == NULL ) { e=E_OTHERS; goto fin; }

	/* With time */
	if ( string_length >= 11 ) {
		TCHAR         a_char;
		const TCHAR*  time_zone;
		int           number;

		IF ( String[10] != _T('T') ) { e=E_NOT_FOUND_SYMBOL; goto fin; }
		IF ( String[4] != _T('-')  ||  String[7] != _T('-') )
			{ e=E_NOT_FOUND_SYMBOL; goto fin; }

		IF ( string_length < 16 ) { e=E_NOT_FOUND_SYMBOL; goto fin; }
		IF ( String[13] != _T(':') ) { e=E_NOT_FOUND_SYMBOL; goto fin; }

		out_Time->wYear      = (WORD) _ttoi( &String[0] );
		out_Time->wMonth     = (WORD) _ttoi( &String[5] );
		out_Time->wDayOfWeek = 0;
		out_Time->wDay       = (WORD) _ttoi( &String[8] );
		out_Time->wHour      = (WORD) _ttoi( &String[11] );
		out_Time->wMinute    = (WORD) _ttoi( &String[14] );

		a_char = String[16];
		if ( a_char == _T('+')  ||  a_char == _T('-')  ||  a_char == _T('Z') ) {
			time_zone = &String[16];
			out_Time->wSecond = 0;
			out_Time->wMilliseconds = 0;
		} else {
			/* Second */
			IF ( string_length < 19 ) { e=E_NOT_FOUND_SYMBOL; goto fin; }
			IF ( a_char != _T(':') ) { e=E_NOT_FOUND_SYMBOL; goto fin; }
			out_Time->wSecond = (WORD) _ttoi( &String[17] );


			/* 小数点 */
			a_char = String[19];
			if ( a_char == _T('+')  ||  a_char == _T('-')  ||  a_char == _T('Z') ) {
				time_zone = &String[19];
				out_Time->wMilliseconds = 0;
			}
			else {
				IF ( a_char != _T('.') ) { e=E_NOT_FOUND_SYMBOL; goto fin; }

				out_Time->wMilliseconds = 0;

				number = String[20] - _T('0');
				if ( number < 0  ||  number > 9 ) {
					time_zone = &String[20];
				} else {
					out_Time->wMilliseconds += (WORD)( number * 100 );

					number = String[21] - _T('0');
					if ( number < 0  ||  number > 9 ) {
						time_zone = &String[21];
					} else {
						out_Time->wMilliseconds += (WORD)( number * 10 );

						number = String[22] - _T('0');
						if ( number < 0  ||  number > 9 ) {
							time_zone = &String[22];
						} else {
							const TCHAR*  pointer = &String[23];

							out_Time->wMilliseconds += (WORD)( number * 1 );

							for (;;) {
								number = *pointer - _T('0');
								if ( number < 0  ||  number > 9 )
									{ break; }

								pointer += 1;
							}
							time_zone = pointer;
						}
					}
				}

				a_char = *time_zone;
				IF ( ! ( a_char == _T('+')  ||  a_char == _T('-')  ||  a_char == _T('Z') ) )
					{ e=E_NOT_FOUND_SYMBOL; goto fin; }
			}
		}

		/* Time zone */
		if ( a_char == _T('Z') ) {
			*out_BiasMinute = 0;
		}
		else {
			size_t  time_zone_length = string_length - ( time_zone - String );
			int     bias_minute;

			IF ( time_zone_length < 6 ) { e=E_NOT_FOUND_SYMBOL; goto fin; }
			IF ( time_zone[3] != _T(':') ) { e=E_NOT_FOUND_SYMBOL; goto fin; }

			bias_minute = _ttoi( &time_zone[1] ) * 60 + _ttoi( &time_zone[4] );
			if ( a_char == _T('-') ) { bias_minute = -bias_minute; }
			*out_BiasMinute = bias_minute;
		}
	}

	/* Without time */
	else {
		out_Time->wDayOfWeek    = 0;
		out_Time->wHour         = 0;
		out_Time->wMinute       = 0;
		out_Time->wSecond       = 0;
		out_Time->wMilliseconds = 0;
		*out_BiasMinute         = 0;

		IF ( string_length < 4 ) { e=E_NOT_FOUND_SYMBOL; goto fin; }

		/* Year */
		out_Time->wYear = (WORD) _ttoi( &String[0] );

		/* Month */
		if ( string_length > 4 ) {
			IF ( string_length < 7 ) { e=E_NOT_FOUND_SYMBOL; goto fin; }
			IF ( String[4] != _T('-') ) { e=E_NOT_FOUND_SYMBOL; goto fin; }
			out_Time->wMonth = (WORD) _ttoi( &String[5] );
		} else {
			out_Time->wMonth = 1;
		}

		/* Day */
		if ( string_length > 7 ) {
			IF ( string_length < 10 ) { e=E_NOT_FOUND_SYMBOL; goto fin; }
			IF ( String[7] != _T('-') ) { e=E_NOT_FOUND_SYMBOL; goto fin; }
			out_Time->wDay = (WORD) _ttoi( &String[8] );
		} else {
			out_Time->wDay = 1;
		}
	}

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [W3CDTF_getTimeZoneDesignator] >>> 
************************************************************************/
errnum_t  W3CDTF_getTimeZoneDesignator( TCHAR* out_TZD, size_t TZD_ByteSize,
	int  BiasMinute )
{
	errnum_t  e;
	TCHAR     sign;
	TIME_ZONE_INFORMATION  time_zone;


	/* Set "BiasMinute" */
	if ( BiasMinute == W3CDTF_CURRENT_TIME_ZONE ) {
		GetTimeZoneInformation( &time_zone );
		BiasMinute = -time_zone.Bias;
	}
	else {
		enum { minute_1day = 1440 };

		IF_D ( BiasMinute < -minute_1day  ||  BiasMinute > minute_1day )
			{ e=E_OTHERS; goto fin; }
	}


	/* Set "sign" */
	if ( BiasMinute >= 0 ) {
		sign = _T('+');
	} else {
		sign = _T('-');
		BiasMinute = -BiasMinute;
	}


	/* Set "out_TZD" */
	_stprintf_s( out_TZD, TZD_ByteSize / sizeof(TCHAR), _T("%c%02d:%02d"),
		sign,  BiasMinute / 60,  BiasMinute % 60 );

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [StrT_isFullPath] >>> 
************************************************************************/
bool  StrT_isFullPath( const TCHAR* path )
{
	bool  ret;

	if ( path[0] == _T('\\')  &&  path[1] == _T('\\') ) {
		ret = true;
	} else {
		const TCHAR*  back_slash = _tcschr( path, _T('\\') );
		const TCHAR*  slash = _tcschr( path, _T('/') );
		const TCHAR*  colon = _tcschr( path, _T(':') );

		ret = ( colon != NULL ) &&
			( back_slash == colon + 1  ||  slash == colon + 1 );
	}

	return  ret;
}

 
/**************************************************************************
  <<< [StrT_getFullPath_part] >>> 
*************************************************************************/
errnum_t  StrT_getFullPath_part( TCHAR* out_FullPath, size_t FullPathSize, TCHAR* OutStart,
	TCHAR** out_OutLast, const TCHAR* StepPath, const TCHAR* BasePath )
{
	errnum_t      e;
	TCHAR         separator = (TCHAR) DUMMY_INITIAL_VALUE_TCHAR;
	const TCHAR*  separator_path;
	TCHAR*        out_full_path_over = (TCHAR*)( (uint8_t*) out_FullPath + FullPathSize );
	TCHAR*        null_position = NULL;


	#if  CHECK_ARG
		/* "BasePath" must be out of "out_FullPath" */
		ASSERT_R( BasePath < out_FullPath  ||
			(uint8_t*) BasePath >= (uint8_t*) out_FullPath + FullPathSize,
			goto err );
	#endif


	/* If "StepPath" == "", out_FullPath = "" */
	if ( StepPath[0] == _T('\0') ) {
		ASSERT_R( FullPathSize >= sizeof(TCHAR), goto err_fm );
		out_FullPath[0] = _T('\0');
		e=0;  goto fin;
	}


	/* Set "OutStart" */
	if ( OutStart == NULL )
		{ OutStart = out_FullPath; }


	/* Set "separator" : \ or / from "BasePath" */
	if ( StrT_isFullPath( StepPath ) ) {
		separator_path = StepPath;
	}
	else if ( BasePath == NULL ) {
		separator = _T('\\');
		separator_path = NULL;
	}
	else {
		separator_path = BasePath;
	}
	if ( separator_path != NULL ) {
		const TCHAR*    p;
		const TCHAR*    p2;

		p  = _tcschr( separator_path, _T('\\') );
		p2 = _tcschr( separator_path, _T('/') );
		if ( p == NULL ) {
			if ( p2 == NULL )
				{ separator = _T('\\'); }
			else
				{ separator = _T('/'); }
		} else {
			if ( p2 == NULL )
				{ separator = _T('\\'); }
			else {
				if ( p < p2 )
					{ separator = _T('\\'); }
				else
					{ separator = _T('/'); }
			}
		}
	}


	/* Set "OutStart" : "BasePath" + / + "StepPath" */
	if ( StrT_isFullPath( StepPath ) ) {
		size_t  step_path_length = _tcslen( StepPath );

		IF( OutStart + step_path_length >= out_full_path_over ) goto err_fa;
		memmove( OutStart,  StepPath,  ( step_path_length + 1 ) * sizeof(TCHAR) );

		/* Set "null_position" */
		null_position = OutStart + step_path_length;
	}
	else {
		TCHAR   c;
		TCHAR*  p;
		size_t  base_path_length;
		size_t  step_path_length = _tcslen( StepPath );

		if ( BasePath == NULL ) {
			base_path_length = GetCurrentDirectory( 0, NULL ) - 1;
		}
		else {
			base_path_length = _tcslen( BasePath );
			c = BasePath[ base_path_length - 1 ];
			if ( c == _T('\\')  ||  c == _T('/') )
				{ base_path_length -= 1; }
		}

		p = OutStart + base_path_length + 1;
		IF( p + step_path_length >= out_full_path_over ) goto err_fa;
		memmove( p,  StepPath,  ( step_path_length + 1 ) * sizeof(TCHAR) );
			/* memmove is for "out_FullPath" == "StepPath" */

		if ( BasePath == NULL ) {
			GetCurrentDirectory( base_path_length + 1, OutStart );
			if ( OutStart[ base_path_length - 1 ] == _T('\\') )
				{ base_path_length -= 1; }
		} else {
			memcpy( OutStart,  BasePath,  base_path_length * sizeof(TCHAR) );
		}
		OutStart[ base_path_length ] = separator;


		/* Set "null_position" */
		null_position = p + step_path_length;
	}


	/* Replace \ and / to "separator" in "OutStart" */
	{
		TCHAR  other_separator;

		if ( separator == _T('/') )
			{ other_separator = _T('\\'); }
		else
			{ other_separator = _T('/'); }

		e= StrT_replace1( OutStart, other_separator, separator, 0 ); IF(e)goto fin;
	}


	/* Replace \*\..\ to \ */
	{
		enum  { length = 4 };
		TCHAR   parent[ length + 1 ];  /* \..\ or /../ */
		TCHAR*  parent_position;
		TCHAR*  p;

		parent[0] = separator;
		parent[1] = _T('.');
		parent[2] = _T('.');
		parent[3] = separator;
		parent[4] = _T('\0');

		for (;;) {
			parent_position = _tcsstr( OutStart, parent );
			if ( parent_position == NULL )  { break; }

			p = parent_position - 1;
			for (;;) {
				IF( p < OutStart ) goto err;  /* "../" are too many */
				if ( *p == separator )  { break; }
				p -= 1;
			}

			memmove( p + 1,
				parent_position + length,
				( null_position - ( parent_position + length ) + 1 ) * sizeof(TCHAR) );

			null_position -= ( parent_position + length ) - ( p + 1 );
		}
	}


	/* Cut last \*\.. */
	{
		enum  { length = 3 };
		TCHAR*  p;

		while ( null_position - length >= OutStart ) {
			if ( *( null_position - 3 ) != separator  ||
			     *( null_position - 2 ) != _T('.')  ||
			     *( null_position - 1 ) != _T('.') )
				{ break; }

			p = null_position - 4;
			for (;;) {
				IF( p < OutStart ) goto err;  /* "../" are too many */
				if ( *p == separator )  { break; }
				p -= 1;
			}

			*p = _T('\0');

			null_position = p;
		}
	}


	/* Replace \.\ to \ */
	{
		enum  { length = 3 };
		TCHAR   current[ length + 1 ];  /* \.\ or /./ */
		TCHAR*  current_position;

		current[0] = separator;
		current[1] = _T('.');
		current[2] = separator;
		current[3] = _T('\0');

		for (;;) {
			current_position = _tcsstr( OutStart, current );
			if ( current_position == NULL )  { break; }

			memmove( current_position + 1,
				current_position + length,
				( null_position - ( current_position + length ) + 1 ) * sizeof(TCHAR) );

			null_position -= length - 1;
		}
	}


	/* Cut last \. */
	{
		TCHAR*  over = _tcschr( OutStart, _T('\0') );

		while ( over - 2 >= OutStart  &&
				*( over - 1 ) == _T('.')  &&  *( over - 2 ) == separator ) {
			over -= 2;
			*over = _T('\0');
		}
	}


	/* Add root / */
	if ( null_position - 1 >= OutStart ) {
		if ( *( null_position - 1 ) == _T(':') ) {
			IF( null_position + 1 >= out_full_path_over ) goto err_fa;

			*( null_position + 0 ) = separator;
			*( null_position + 1 ) = _T('\0');
			null_position += 1;
		}
	}


	/* Set "*out_OutLast" */
	if ( out_OutLast != NULL )
		{ *out_OutLast = null_position; }

	e=0;
fin:
	return  e;

err:     e = E_OTHERS;      goto fin;
err_fa:  e = E_FEW_ARRAY;   goto fin;
err_fm:  e = E_FEW_MEMORY;  goto fin;
}


 
/***********************************************************************
  <<< [StrT_allocateFullPath] >>> 
************************************************************************/
errnum_t  StrT_allocateFullPath( TCHAR** out_FullPath, const TCHAR* StepPath, TCHAR* BasePath )
{
	errnum_t  e;
	int  step_path_length = _tcslen( StepPath );
	int  base_path_length;
	int  full_path_size;

	if ( BasePath == NULL ) {
		base_path_length = GetCurrentDirectory( 0, NULL ) - 1;
	} else {
		base_path_length = _tcslen( BasePath );
	}

	full_path_size = ( step_path_length + 1 + base_path_length + 1 ) * sizeof(TCHAR);

	e= HeapMemory_allocateBytes( out_FullPath, full_path_size ); IF(e){goto fin;}
	e= StrT_getFullPath( *out_FullPath, full_path_size, StepPath, BasePath ); IF(e){goto fin;}

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [StrT_getParentFullPath_part] >>> 
************************************************************************/
errnum_t  StrT_getParentFullPath_part( TCHAR* Str, size_t StrSize, TCHAR* StrStart,
	TCHAR** out_StrLast, const TCHAR* StepPath, const TCHAR* BasePath )
{
	errnum_t  e;
	TCHAR*  p;

	IF_D( StrStart < Str ||  (char*) StrStart >= (char*)Str + StrSize )goto err;

	if ( StepPath[0] == _T('\0') ) {
		*StrStart = _T('\0');
		return  0;
	}

	/* 絶対パスにする */
	e= StrT_getFullPath( StrStart,
		StrSize - ( (char*)StrStart - (char*)Str ),
		StepPath, BasePath ); IF(e)goto fin;


	/* Cut last \ */
	p = _tcschr( StrStart, _T('\0') );
	if ( p > StrStart ) {
		TCHAR  c = *( p - 1 );
		if ( c == _T('\\')  ||  c == _T('/') )
			{ *( p - 1 ) = _T('\0'); }
	}


	/* 親へ */
	p = StrT_refFName( StrStart );
	if ( p > StrStart )  p--;
	*p = _T('\0');


	/* ルートなら \ を付ける */
	if ( p == StrStart + 2 ) {
		*p = _T('\\');  p++;  *p = _T('\0');
	}

	if ( out_StrLast != NULL )  *out_StrLast = p;

	e=0;
fin:
	return  e;

err:  e = E_OTHERS;  goto fin;
}


 
/***********************************************************************
  <<< [StrT_isOverOfFileName] >>> 
- "" or "\" or "/"
************************************************************************/
inline bool  StrT_isOverOfFileName( const TCHAR* PointerInPath )
{
	return  PointerInPath == NULL  ||
		*PointerInPath == _T('\0')  ||
		( ( *PointerInPath == _T('\\')  ||  *PointerInPath == _T('/') )  &&
			*(PointerInPath + 1) == _T('\0') );
}


 
/***********************************************************************
  <<< [StrT_getStepPath] >>> 
************************************************************************/
errnum_t  StrT_getStepPath( TCHAR* out_StepPath, size_t StepPathSize,
	const TCHAR* FullPath, const TCHAR* BasePath )
{
	errnum_t      e;
	const TCHAR*  abs_pointer;
	const TCHAR*  base_pointer;
	TCHAR         abs_char;
	TCHAR         base_char;
	TCHAR         separator;
	const TCHAR*  abs_separator_pointer  = (const TCHAR*) DUMMY_INITIAL_VALUE;
	const TCHAR*  base_separator_pointer = (const TCHAR*) DUMMY_INITIAL_VALUE;
	TCHAR*        step_pointer;
	TCHAR         parent_symbol[4] = { _T('.'), _T('.'), _T('\\'), _T('\0') };
	TCHAR         base_path_2[ MAX_PATH ];


	ASSERT_D( out_StepPath != FullPath, goto err );

	abs_pointer = FullPath;


	/* Set "base_pointer" */
	if ( BasePath == NULL ) {
		base_pointer = _tgetcwd( base_path_2, _countof(base_path_2) );
		IF( base_pointer == NULL ) goto err;
	}
	else {
		base_pointer = BasePath;
	}


	/* Set "abs_separator_pointer", "base_separator_pointer" : after same parent folder path */
	separator = 0;
	for (;;) {  /* while abs_char == base_char */
		abs_char  = *abs_pointer;
		base_char = *base_pointer;

		abs_char  = (TCHAR) _totlower( abs_char );
		base_char = (TCHAR) _totlower( base_char );

		if ( abs_char == _T('\0') ) {

			/* out_StepPath = ".", if FullPath == BasePath */
			if ( base_char == _T('\0') ) {
				e= StrT_cpy( out_StepPath, StepPathSize, _T(".") ); IF(e)goto fin;
				e=0; goto fin;
			}
			break;
		}
		if ( base_char == _T('\0') )  { break; }

		if ( abs_char != base_char ) {
			if ( ( abs_char  == _T('/')  ||  abs_char  == _T('\\') ) &&
			     ( base_char == _T('/')  ||  base_char == _T('\\') ) )
				{ /* Do nothing */ }
			else
				{ break; }
		}

		/* Set "separator", "abs_separator_pointer", "base_separator_pointer" */
		if (  base_char == _T('/')  ||  base_char == _T('\\')  ) {
			if ( separator == 0 )
				{ separator = base_char; }

			abs_separator_pointer = abs_pointer;
			base_separator_pointer = base_pointer;
		}

		abs_pointer  += 1;
		base_pointer += 1;
	}


	/* FullPath と BasePath の関係が、片方の一部がもう片方の全体であるとき */
	if (  abs_char == _T('/')  ||  abs_char == _T('\\')  ||
	     base_char == _T('/')  || base_char == _T('\\')  ) {
	     /* other character is '\0' */

		if ( separator == 0 )
			{ separator = abs_char; }

		abs_separator_pointer = abs_pointer;
		base_separator_pointer = base_pointer;
	}


	/* out_StepPath = FullPath, if there is not same folder */
	if ( separator == 0 ) {
		e= StrT_cpy( out_StepPath, StepPathSize, FullPath ); IF(e)goto fin;
		e=0; goto fin;
	}


	/* Add "..\" to "out_StepPath" */
	parent_symbol[2] = separator;
	step_pointer = out_StepPath;
	for (;;) {
		const TCHAR*  p1;
		const TCHAR*  p2;

		if ( StrT_isOverOfFileName( base_separator_pointer ) )
			{ break; }


		/* Set "base_separator_pointer" : next separator */
		p1 = _tcschr( base_separator_pointer + 1, _T('/') );
		p2 = _tcschr( base_separator_pointer + 1, _T('\\') );

		if ( p1 == NULL ) {
			if ( p2 == NULL )
				{ base_separator_pointer = NULL; }
			else
				{ base_separator_pointer = p2; }
		}
		else {
			if ( p2 == NULL ) {
				base_separator_pointer = p1;
			} else {
				if ( p1 < p2 )
					{ base_separator_pointer = p1; }
				else
					{ base_separator_pointer = p2; }
			}
		}


		/* Add "..\" to "out_StepPath" */
		e= stcpy_part_r( out_StepPath, StepPathSize, step_pointer, &step_pointer,
			parent_symbol, NULL ); IF(e)goto fin;
	}


	/* Copy a part of "FullPath" to "out_StepPath" */
	if ( StrT_isOverOfFileName( abs_separator_pointer ) ) {
		ASSERT_D( step_pointer > out_StepPath, goto err );
		*( step_pointer - 1 ) = _T('\0');
	}
	else {
		e= stcpy_part_r( out_StepPath, StepPathSize, step_pointer, NULL,
			abs_separator_pointer + 1, NULL ); IF(e)goto fin;
	}

	e=0;
fin:
	return  e;

err:  e = E_OTHERS;  goto fin;
}


 
/***********************************************************************
  <<< [StrT_getBaseName_part] >>> 
************************************************************************/
errnum_t  StrT_getBaseName_part( TCHAR* Str, size_t StrSize, TCHAR* StrStart,
	TCHAR** out_StrLast, const TCHAR* SrcPath )
{
	const TCHAR*  p1;
	const TCHAR*  p2;
	const TCHAR*  p3;
	const TCHAR*  ps;

	p1 = StrT_refFName( SrcPath );


	//=== # が無いとき、最後のピリオドの前までが、BaseName
	ps = _tcschr( p1, _T('#') );
	if ( ps == NULL ) {
		p2 = _tcsrchr( p1, _T('.') );
		if ( p2 == NULL )  p2 = _tcsrchr( p1, _T('\0') );
	}

	//=== # があるとき、# より前で、最後のピリオドの前までが、BaseName
	else {
		p2 = ps;

		p3 = p1;
		for (;;) {
			p3 = _tcschr( p3, _T('.') );
			if ( p3 == NULL || p3 > ps )  break;
			p2 = p3;
			p3 ++;
		}
	}

	return  stcpy_part_r( Str, StrSize, StrStart, out_StrLast, p1, p2 );
}

 
/***********************************************************************
  <<< [StrT_addLastOfFileName] >>> 
************************************************************************/
errnum_t  StrT_addLastOfFileName( TCHAR* out_Path, size_t PathSize,
                             const TCHAR* BasePath, const TCHAR* AddName )
{
	TCHAR           c;
	size_t          copy_size;
	size_t          free_size;
	char*           out_pos;
	const TCHAR*    last_pos_in_base = _tcschr( BasePath, _T('\0') );
	const TCHAR*    term_pos_in_base;
	const TCHAR*     add_pos_in_base;
	const TCHAR*  period_pos_in_base = _tcsrchr( BasePath, _T('.') );  // > term_pos_in_base
	const TCHAR*    last_pos_in_add  = _tcschr( AddName, _T('\0') );
	const TCHAR*    term_pos_in_add;
	const TCHAR*  period_pos_in_add  = _tcsrchr( AddName,  _T('.') );  // > term_pos_in_add


	DISCARD_BYTES( out_Path, PathSize );


	//=== term_pos_in_base
	for ( term_pos_in_base = last_pos_in_base;  term_pos_in_base >= BasePath;  term_pos_in_base -- ) {
		c = *term_pos_in_base;
		if ( c == _T('/') || c == _T('\\') )  break;
	}


	//=== term_pos_in_add
	for ( term_pos_in_add = last_pos_in_add;  term_pos_in_add >= AddName;  term_pos_in_add -- ) {
		c = *term_pos_in_add;
		if ( c == _T('/') || c == _T('\\') )  break;
	}


	//=== add_pos_in_base
	if ( term_pos_in_base < period_pos_in_base ) {
		add_pos_in_base = period_pos_in_base;
	}
	else {
		if ( term_pos_in_base < BasePath )
			add_pos_in_base = _tcschr( BasePath, _T('\0') );
		else
			add_pos_in_base = _tcschr( term_pos_in_base, _T('\0') );
	}


	//=== setup output parameters
	out_pos   = (char*) out_Path;
	free_size = PathSize;


	//=== copy BasePath .. add_pos_in_base
	copy_size = (char*)add_pos_in_base - (char*)BasePath;
	if ( copy_size > free_size ) goto err_fa;
	memcpy( out_pos,  BasePath,  copy_size );
	out_pos   += copy_size;
	free_size -= copy_size;


	//=== copy AddName .. last_pos_in_add
	copy_size = (char*)last_pos_in_add - (char*)AddName;
	if ( copy_size > free_size ) goto err_fa;
	memcpy( out_pos,  AddName,  copy_size );
	out_pos   += copy_size;
	free_size -= copy_size;


	//=== add name and not change extension
	if ( period_pos_in_add == NULL ) {

		//=== copy period_pos_in_base .. last_pos_in_base
		if ( period_pos_in_base > term_pos_in_base ) {
			copy_size = (char*)last_pos_in_base - (char*)period_pos_in_base + sizeof(TCHAR);
			if ( copy_size > free_size ) goto err_fa;
			memcpy( out_pos,  period_pos_in_base,  copy_size );
		}
		else {
			*(TCHAR*)out_pos = _T('\0');
		}
	}


	//=== add name and change extension
	else {

		if ( *(period_pos_in_add + 1) == _T('\0') )
			*( (TCHAR*)out_pos - 1 ) = _T('\0');
		else
			*(TCHAR*)out_pos = _T('\0');
	}

	return  0;

err_fa:
	return  E_FEW_ARRAY;
}


 
/***********************************************************************
  <<< [Strs_init] >>> 
************************************************************************/
enum { Strs_FirstSize = 0x0F00 };

errnum_t  Strs_init( Strs* self )
{
	char*  p;

	self->MemoryAddress = NULL;

	p = (char*) malloc( Strs_FirstSize );
	IF( p == NULL )  return  E_FEW_MEMORY;

	self->MemoryAddress = p;
	self->MemoryOver    = p + Strs_FirstSize;
	self->NextElem      = p + sizeof(TCHAR*);
	self->PointerToNextStrInPrevElem = (TCHAR**) p;
	self->Prev_PointerToNextStrInPrevElem = NULL;
	*(TCHAR**) p = NULL;

	self->FirstOfStrs = self;
	self->NextStrs = NULL;

	return  0;
}


 
/***********************************************************************
  <<< [Strs_finish] >>> 
************************************************************************/
errnum_t  Strs_finish( Strs* self, errnum_t e )
{
	Strs*  mp;
	Strs*  next_mp;

	if ( self->MemoryAddress == NULL )  return 0;

	mp = self->FirstOfStrs;
	for (;;) {
		free( mp->MemoryAddress );
		if ( mp == self )  break;

		next_mp = mp->NextStrs;
		free( mp );
		mp = next_mp;
	}
	self->MemoryAddress = NULL;

	return  e;
}


 
/***********************************************************************
  <<< [Strs_toEmpty] >>> 
************************************************************************/
errnum_t  Strs_toEmpty( Strs* self )
{
	Strs_finish( self, 0 );
	return  Strs_init( self );
}


 
/***********************************************************************
  <<< [Strs_add] >>> 
************************************************************************/
errnum_t  Strs_add( Strs* self, const TCHAR* Str, const TCHAR** out_AllocStr )
{
	return  Strs_addBinary( self, Str, _tcschr( Str, _T('\0') ) + 1, out_AllocStr );
}


errnum_t  Strs_addBinary( Strs* self, const TCHAR* Str, const TCHAR* StrOver, const TCHAR** out_AllocStr )
{
	errnum_t  e;
	size_t  str_size;
	size_t  elem_size;

	str_size  = ( (char*) StrOver - (char*) Str );
	elem_size = ( sizeof(TCHAR*) + str_size + sizeof(void*) - 1 ) & ~(sizeof(void*) - 1);

	if ( self->NextElem + elem_size > self->MemoryOver )
		{ e= Strs_expandSize( self, str_size ); IF(e)goto fin; }


	// [ NULL     | ... ]
	// [ FirstStr | NULL    | TCHAR[] | ... ]
	// [ FirstStr | NextStr | TCHAR[] | NULL    | TCHAR[] | ... ]
	// [ FirstStr | NextStr | TCHAR[] | NextStr | TCHAR[] ], [ NULL | TCHAR[] | ... ]

	if ( out_AllocStr != NULL )  *out_AllocStr = (TCHAR*)( self->NextElem + sizeof(TCHAR*) );

	//=== fill elem
	*(TCHAR**) self->NextElem = NULL;
	memcpy( self->NextElem + sizeof(TCHAR*),  Str,  str_size );

	//=== link to elem from previous elem
	*self->PointerToNextStrInPrevElem = (TCHAR*)( self->NextElem + sizeof(TCHAR*) );

	//=== update self
	self->Prev_PointerToNextStrInPrevElem = self->PointerToNextStrInPrevElem;
	self->PointerToNextStrInPrevElem = (TCHAR**) self->NextElem;
	self->NextElem = self->NextElem + elem_size;

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [Strs_freeLast] >>> 
************************************************************************/
errnum_t  Strs_freeLast( Strs* self, TCHAR* AllocStr )
{
	errnum_t  e;
	TCHAR*  str;
	TCHAR*  last_str;
	TCHAR*  prev_of_last_str;
	Strs*   mp;
	Strs*   prev_of_last_mp;

	if ( self->Prev_PointerToNextStrInPrevElem == NULL ) {
		prev_of_last_str = NULL;
		last_str = NULL;
		for ( Strs_forEach( self, &str ) ) {
			prev_of_last_str = last_str;
			last_str = str;
		}
	}
	else {
		prev_of_last_str = (TCHAR*)( self->Prev_PointerToNextStrInPrevElem + 1 );
		last_str = (TCHAR*)( self->PointerToNextStrInPrevElem + 1 );
	}

	// [ NULL     | ... ]
	IF( last_str != AllocStr ) goto err;

	// [ FirstStr | NULL    | TCHAR[] | ... ]
	if ( prev_of_last_str == NULL ) {
		self->NextElem = self->MemoryAddress + sizeof(TCHAR*);
		self->PointerToNextStrInPrevElem = (TCHAR**) self->MemoryAddress;
	}

	// [ FirstStr | NextStr | TCHAR[] | NULL    | TCHAR[] | ... ]
	else if ( (char*) prev_of_last_str >= self->MemoryAddress  &&
	          (char*) prev_of_last_str <  self->MemoryOver ) {
		self->NextElem = (char*)last_str - sizeof(TCHAR*);
		self->PointerToNextStrInPrevElem = (TCHAR**)( (char*)prev_of_last_str - sizeof(TCHAR*) );
	}

	// [ FirstStr | NextStr | TCHAR[] | NextStr | TCHAR[] ], [ NULL | TCHAR[] | ... ]
	else {
		prev_of_last_mp = NULL;
		for ( mp = self->FirstOfStrs;  mp->NextStrs != self;  mp = mp->NextStrs ) {
			prev_of_last_mp = mp;
		}

		free( self->MemoryAddress );

		*self = *mp;

		if ( prev_of_last_mp == NULL ) {
			self->FirstOfStrs = self;
			self->NextStrs = NULL;
		}
		else {
			prev_of_last_mp->NextStrs = self;
		}

		free( mp );
	}
	*self->PointerToNextStrInPrevElem = NULL;
	self->Prev_PointerToNextStrInPrevElem = NULL;

	e=0;
fin:
	return  e;

err:  e = E_OTHERS;  goto fin;
}


 
/***********************************************************************
  <<< [Strs_expandSize] >>> 
************************************************************************/
errnum_t  Strs_expandSize( Strs* self, size_t FreeSize )
{
	Strs*   mp;
	Strs*   mp2;
	size_t  elem_size = ( sizeof(TCHAR*) + FreeSize + sizeof(void*) - 1 ) & ~(sizeof(void*) - 1);
	size_t  memory_size;
	char*   new_memory;

	// [ NULL     | ... ]
	// [ FirstStr | NULL    | TCHAR[] | ... ]
	// [ FirstStr | NextStr | TCHAR[] | NULL    | TCHAR[] | ... ]
	// [ FirstStr | NextStr | TCHAR[] | NextStr | TCHAR[] ], [ NULL | TCHAR[] | ... ]

	while ( self->NextElem + elem_size > self->MemoryOver ) {

		//=== alloc
		mp = (Strs*) malloc( sizeof(Strs) ); IF(mp==NULL) goto err_fm;
		memory_size = ( self->MemoryOver - self->MemoryAddress ) * 2;
		new_memory = (char*) malloc( memory_size );
		IF( new_memory == NULL )  { free( mp );  goto err_fm; }

		//=== move old memory
		if ( self->FirstOfStrs == self ) {
			self->FirstOfStrs = mp;
		}
		else {
			for ( mp2 = self->FirstOfStrs;  mp2->NextStrs != self;  mp2 = mp2->NextStrs );
			mp2->NextStrs = mp;
		}
		*mp = *self;
		mp->NextStrs = self;

		//=== setup new memory
		self->MemoryAddress = new_memory;
		self->MemoryOver    = new_memory + memory_size;
		self->NextElem      = new_memory;
		// self->PointerToNextStrInPrevElem is same value
		// self->FirstOfStrs is same value
		// self->NextStrs is always NULL
	}
	return  0;

err_fm:  return  E_FEW_ARRAY;
}


/***********************************************************************
  <<< [Strs_commit] >>>
************************************************************************/
errnum_t  Strs_commit( Strs* self, TCHAR* StrOver )
{
	size_t  elem_size;

	if ( StrOver == NULL )
		{ StrOver = _tcschr( (TCHAR*)( self->NextElem + sizeof(TCHAR*) ), _T('\0') ) + 1; }
	elem_size = ( ( (char*)StrOver - self->NextElem ) + sizeof(void*) - 1 ) & ~(sizeof(void*) - 1);

	//=== fill elem
	*(TCHAR**) self->NextElem = NULL;

	//=== link to elem from previous elem
	*self->PointerToNextStrInPrevElem = (TCHAR*)( self->NextElem + sizeof(TCHAR*) );

	//=== update self
	self->PointerToNextStrInPrevElem = (TCHAR**) self->NextElem;
	self->NextElem = self->NextElem + elem_size;

	return  0;
}


 
/***********************************************************************
  <<< [StrArr] >>> 
************************************************************************/

/*[StrArr_init]*/
errnum_t  StrArr_init( StrArr* self )
{
	errnum_t  e;

	Set2_initConst( &self->Array );
	Strs_initConst( &self->Chars );

	e= Set2_init( &self->Array, 0x100 ); IF(e)goto cancel;
	e= Strs_init( &self->Chars ); IF(e)goto cancel;
	return  0;

cancel:  StrArr_finish( self, e );  return  e;
}


/*[StrArr_finish]*/
errnum_t  StrArr_finish( StrArr* self, errnum_t e )
{
	if ( ! Set2_isInited( &self->Array ) )  return  e;

	e= Set2_finish( &self->Array, e );
	e= Strs_finish( &self->Chars, e );
	return  e;
}


/*[StrArr_add]*/
errnum_t  StrArr_add( StrArr* self, const TCHAR* Str, int* out_I )
{
	errnum_t  e;

	e= StrArr_expandCount( self, _tcslen( Str ) ); IF(e)goto fin;
	_tcscpy_s( StrArr_getFreeAddr( self ), StrArr_getFreeCount( self ), Str );
	e= StrArr_commit( self ); IF(e)goto fin;
	if ( out_I != NULL )  *out_I = Set2_getCount( &self->Array, TCHAR* ) - 1;

	e=0;
fin:
	return  e;
}


/*[StrArr_commit]*/
errnum_t  StrArr_commit( StrArr* self )
{
	errnum_t  e;
	TCHAR*   p;
	TCHAR**  pp  = NULL;
	Set2*    arr = &self->Array;
	Strs*    ss  = &self->Chars;

	p = Strs_getFreeAddr( ss );
	e= Set2_alloc( arr, &pp, TCHAR* ); IF(e)goto fin;
	e= Strs_commit( ss, NULL ); IF(e)goto fin;
	*pp = p;

	e=0;
fin:
	if ( e &&  pp != NULL )  e= Set2_freeLast( arr, pp, TCHAR*, e );
	return  e;
}


/*[StrArr_fillTo]*/
errnum_t  StrArr_fillTo( StrArr* self, int n, const TCHAR* Str )
{
	errnum_t  e;
	const TCHAR*   p;
	const TCHAR**  pp;
	const TCHAR**  pp_over;

	n -= Set2_getCount( &self->Array, TCHAR* );
	if ( n <= 0 ) return 0;

	if ( Str == NULL ) {
		p = NULL;
	}
	else {
		e= Strs_add( &self->Chars, Str, &p ); IF(e)goto fin;
	}

	e= Set2_allocMulti( &self->Array, &pp, TCHAR*, n ); IF(e)goto fin;
	pp_over = pp + n;
	for ( ;  pp < pp_over;  pp++ )
		*pp = p;

	e=0;
fin:
	return  e;
}


/*[StrArr_toEmpty]*/
errnum_t  StrArr_toEmpty( StrArr* self )
{
	errnum_t  e, ee;

	e=0;
	ee= Set2_toEmpty( &self->Array ); IF(ee&&!e)e=ee;
	ee= Strs_toEmpty( &self->Chars ); IF(ee&&!e)e=ee;
	return  e;
}


 
/***********************************************************************
  <<< [StrArr_parseCSV] >>> 
************************************************************************/
errnum_t  StrArr_parseCSV( StrArr* self, const TCHAR* CSVLine )
{
	errnum_t      e;
	const TCHAR*  p = CSVLine;

	e= StrArr_toEmpty( self ); IF(e)goto fin;

	do {
		e= StrT_meltCSV( StrArr_getFreeAddr( self ), StrArr_getFreeSize( self ), &p );
		if ( e == E_FEW_ARRAY ) {
			e= StrArr_expandSize( self, StrArr_getFreeSize( self ) * 2 ); IF(e)goto fin;
			continue;
		}
		IF(e)goto fin;

		e = StrArr_commit( self ); IF(e)goto fin;
	} while ( p != NULL );

	e=0;
fin:
	return  e;
}


 
/*=================================================================*/
/* <<< [DebugTools/DebugTools.c] >>> */ 
/*=================================================================*/
 
/***********************************************************************
  <<< [TestableDebugBreak] >>> 
************************************************************************/
typedef struct _TestableDebugBreakClass  TestableDebugBreakClass;
struct _TestableDebugBreakClass {
	bool              IsDisableTestableDebugBreak;
	volatile int      DebugBreakCount;
	CRITICAL_SECTION  Critical;
	SingletonInitializerClass  Initializer;
};
static TestableDebugBreakClass  gs_TestableDebugBreak = { false, 0 };


/*[SetTestableDebugBreak]*/
void  SetTestableDebugBreak( bool IsEnableBreak )
{
	TestableDebugBreakClass*  self = &gs_TestableDebugBreak;
	self->IsDisableTestableDebugBreak = ! IsEnableBreak;
}

/*[TestableDebugBreak_Sub]*/
int  TestableDebugBreak_Sub()
{
	TestableDebugBreakClass*  self = &gs_TestableDebugBreak;

	if ( ! SingletonInitializerClass_isInitialized( &self->Initializer ) ) {
		if ( SingletonInitializerClass_isFirst( &self->Initializer ) ) {

			InitializeCriticalSection( &self->Critical );

			SingletonInitializerClass_onFinishedInitialize( &self->Initializer, 0 );
		}
	}

	EnterCriticalSection( &self->Critical );
	self->DebugBreakCount += 1;
	LeaveCriticalSection( &self->Critical );

	return  ! self->IsDisableTestableDebugBreak;
}

/*[GetDebugBreakCount]*/
int  GetDebugBreakCount()
{
	TestableDebugBreakClass*  self = &gs_TestableDebugBreak;
	return  self->DebugBreakCount;
}


 
/*=================================================================*/
/* <<< [SetX/SetX.c] >>> */ 
/*=================================================================*/
 
/***********************************************************************
  <<< [Set2_init] >>> 
************************************************************************/
int  Set2_init( Set2* m, int FirstSize )
{
	m->First = malloc( FirstSize );
	if ( m->First == NULL )  return  E_FEW_MEMORY;
	m->Next = m->First;
	m->Over = (char*)m->First + FirstSize;

	#ifdef _DEBUG
	m->PointerOfDebugArray = NULL;
	#endif

	return  0;
}
 
/***********************************************************************
  <<< [Set2_finish] >>> 
************************************************************************/
int  Set2_finish( Set2* m, int e )
{
	if ( m->First != NULL )  { free( m->First );  m->First = NULL; }
	return  e;
}

 
/***********************************************************************
  <<< [Set2_ref_imp] >>> 
************************************************************************/
int  Set2_ref_imp( Set2* m, int iElem, void* out_pElem, size_t ElemSize )
{
	int    e;
	char*  p;

	IF( iElem < 0 ) goto err_ns;
	p = (char*) m->First + ( (unsigned)iElem * ElemSize );
	IF( p >= (char*)m->Next ) goto err_ns;
	*(char**)out_pElem = p;

	e=0;
fin:
	return  e;

err_ns:  e = E_NOT_FOUND_SYMBOL;  goto fin;
}


 
/***********************************************************************
  <<< [Set2_getIterator] >>> 
************************************************************************/
errnum_t  Set2_getIterator( Set2* self, Set2_IteratorClass* out_Iterator, int ElementSize )
{
	out_Iterator->Parent = self;
	out_Iterator->ElementSize = ElementSize;
	out_Iterator->Current = (uint8_t*) self->First - ElementSize;
	return  0;
}


 
/***********************************************************************
  <<< [Set2_getDescendingIterator] >>> 
************************************************************************/
errnum_t  Set2_getDescendingIterator( Set2* self, Set2_IteratorClass* out_Iterator, int ElementSize )
{
	out_Iterator->Parent = self;
	out_Iterator->ElementSize = ElementSize;
	out_Iterator->Current = (uint8_t*) self->Next;
	return  0;
}


 
/***********************************************************************
  <<< [Set2_IteratorClass_getNext] >>> 
************************************************************************/
void*  Set2_IteratorClass_getNext( Set2_IteratorClass* self )
{
	uint8_t*  next = self->Current + self->ElementSize;

	if ( next >= (uint8_t*) self->Parent->Next ) {
		return  NULL;
	} else {
		self->Current = next;
		return  next;
	}
}


 
/***********************************************************************
  <<< [Set2_IteratorClass_getPrevious] >>> 
************************************************************************/
void*  Set2_IteratorClass_getPrevious( Set2_IteratorClass* self )
{
	uint8_t*  previous = self->Current - self->ElementSize;

	if ( previous < (uint8_t*) self->Parent->First ) {
		return  NULL;
	} else {
		self->Current = previous;
		return  previous;
	}
}


 
/***********************************************************************
  <<< [Set2_alloc_imp] >>> 
************************************************************************/
int  Set2_alloc_imp( Set2* m, void* pp, size_t size )
{
	int  e;

	e= Set2_expandIfOverByAddr( m, (char*) m->Next + size ); IF(e)goto fin;
	*(void**)pp = m->Next;
	m->Next = (char*) m->Next + size;

	DISCARD_BYTES( *(void**)pp, size );

	e=0;
fin:
	return  e;
}


int  Set2_allocMulti_sub( Set2* m, void* out_pElem, size_t ElemsSize )
{
	int    e;
	char*  p;

	e= Set2_expandIfOverByAddr( m, (char*) m->Next + ElemsSize ); IF(e)goto fin;
	p = (char*) m->Next;
	m->Next = p + ElemsSize;
	*(char**)out_pElem = p;

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [Set2_expandIfOverByAddr_imp] >>> 
************************************************************************/
errnum_t  Set2_expandIfOverByAddr_imp( Set2* m, void* OverAddrBasedOnNowFirst )
{
	errnum_t  e;
	void*     new_first;
	unsigned  offset_of_over;
	unsigned  offset_of_next;

	if ( OverAddrBasedOnNowFirst <= m->Over ) { e=E_OTHERS; goto fin; }

	offset_of_next = (unsigned)( (char*)OverAddrBasedOnNowFirst - (char*)m->First );
	offset_of_over = (unsigned)( ( (char*)m->Over - (char*)m->First ) ) * 2;
	IF_D( offset_of_next >= 0x80000000 ) { e=E_OTHERS; goto fin; }
	IF_D( offset_of_over == 0 ) { e=E_OTHERS; goto fin; }
	while ( offset_of_over < offset_of_next ) { offset_of_over *= 2; }
	IF( offset_of_over >= 0x10000000 ) { e=E_OTHERS; goto fin; }

	new_first = realloc( m->First, offset_of_over * 2 );
		IF( new_first == NULL ) { e=E_FEW_MEMORY; goto fin; }

	m->Next = (char*) new_first + ( (char*)m->Next - (char*)m->First );
	m->Over = (char*) new_first + offset_of_over * 2;
	m->First = new_first;

	#ifdef _DEBUG
	if ( m->PointerOfDebugArray != NULL )
		{ *m->PointerOfDebugArray = m->First; }
	#endif

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [Set2_separate] >>> 
************************************************************************/
int  Set2_separate( Set2* m, int NextSize, void** allocate_Array )
{
	int    e;
	void*  p = m->First;

	if ( NextSize == 0 ) {
		m->First = NULL;
	}
	else {
		e= Set2_init( m, NextSize ); IF(e)goto fin;
	}
	*allocate_Array = p;

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [Set2_pop_imp] >>> 
************************************************************************/
int  Set2_pop_imp( Set2* m, void* pp, size_t size )
{
	int    e;
	void*  p;

	p = (char*) m->Next - size;

	IF ( p < m->First ) { e=E_OTHERS; goto fin; }

	m->Next = p;
	*(void**)pp = p;

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [Set2_setDebug] >>> 
************************************************************************/
#ifdef _DEBUG
void  Set2_setDebug( Set2* m, void* PointerOfDebugArray )
{
	m->PointerOfDebugArray = PointerOfDebugArray;
	*m->PointerOfDebugArray = m->First;
}
#endif


 
/*=================================================================*/
/* <<< [Print/Print2.c] >>> */ 
/*=================================================================*/
 
/***********************************************************************
  <<< [vsprintf_r] >>> 
************************************************************************/
errnum_t  vsprintf_r( char* s, size_t s_size, const char* format, va_list va )
{
	#if _MSC_VER
		#pragma warning(push)
		#pragma warning(disable: 4996)
	#endif

	int  r = _vsnprintf( s, s_size, format, va );

	#if _MSC_VER
		#pragma warning(pop)
	#endif

	IF( r == (int) s_size )
		{ s[s_size-1] = '\0';  return E_FEW_ARRAY; }
	IF( r == -1 )
		{ return E_NOT_FOUND_SYMBOL; }  /* Bad character code */

	return  0;
}


 
/***********************************************************************
  <<< [vswprintf_r] >>> 
************************************************************************/
#ifndef  __linux__
errnum_t  vswprintf_r( wchar_t* s, size_t s_size, const wchar_t* format, va_list va )
{
	size_t  tsize = s_size / sizeof(wchar_t);

	#pragma warning(push)
	#pragma warning(disable: 4996)
		int  r = _vsnwprintf( s, tsize, format, va );
	#pragma warning(pop)

	if ( r == (int) tsize || r == -1 ) { s[tsize-1] = '\0';  return E_FEW_ARRAY; }
	else  return  0;
}
#endif


 
/***********************************************************************
  <<< [stprintf_r] >>> 
************************************************************************/
errnum_t  stprintf_r( TCHAR* s, size_t s_size, const TCHAR* format, ... )
{
	errnum_t  e;
	va_list   va;

	va_start( va, format );
	e = vstprintf_r( s, s_size, format, va );
	va_end( va );
	return  e;
}


 
/***********************************************************************
  <<< [stcpy_part_r] >>> 
************************************************************************/
errnum_t  stcpy_part_r( TCHAR* s, size_t s_size, TCHAR* s_start, TCHAR** p_s_last,
                   const TCHAR* src, const TCHAR* src_over )
{
	size_t  s_space = (char*)s + s_size - (char*)s_start;
	size_t  src_size;

	IF_D( s_start < s || (char*)s_start >= (char*)s + s_size )  { return 1; }

	if ( src_over == NULL )  { src_over = _tcschr( src, _T('\0') ); }
	src_size = (char*)src_over - (char*)src;
	IF ( src_size >= s_space ) {
		s_space -= sizeof(TCHAR);
		memcpy( s, src, s_space );

		s_start = (TCHAR*)((char*)s_start + s_space );
		*s_start = '\0';

		if ( p_s_last != NULL ) { *p_s_last=s_start; }
		return  E_FEW_ARRAY;
	}

	memcpy( s_start, src, src_size + sizeof(TCHAR) );
	s_start = (TCHAR*)((char*)s_start + src_size);  *s_start = _T('\0');
	if ( p_s_last != NULL )  { *p_s_last = s_start; }

	return  0;
}


 
/***********************************************************************
  <<< [stprintf_part_r] >>> 
************************************************************************/
errnum_t  stprintf_part_r( TCHAR* s, size_t s_size, TCHAR* s_start, TCHAR** p_s_last,
                      const TCHAR* format, ... )
{
	errnum_t  e;
	va_list   va;
	va_start( va, format );

	IF_D( s_start < s || (char*)s_start >= (char*)s + s_size ) {return E_OTHERS;}

	e = vstprintf_r( s_start, s_size - ( (char*)s_start - (char*)s), format, va );
	va_end( va );  if ( p_s_last != NULL )  *p_s_last = _tcschr( s_start, '\0' );
	return  e;
}


 
/*=================================================================*/
/* <<< [Lock_1/Lock_1.c] >>> */ 
/*=================================================================*/
 
/*-------------------------------------------------------------------------*/
/* <<<< ### (SingletonInitializerClass) implement >>>> */ 
/*-------------------------------------------------------------------------*/


volatile int  g_SingletonInitializerClass_FailSleepTime = SingletonInitializerClass_FailSleepTime;


/*[SingletonInitializerClass_isFirst]*/
bool  SingletonInitializerClass_isFirst( SingletonInitializerClass* self )
{
	for (;;) {
		if ( InterlockedCompareExchange( &self->InitializeStep, 1, 0 ) == 0 ) {
			return  true;
		}
		else {
			while ( self->InitializeStep == 1 ) {
				Sleep( 0 );  /* Wait for initialized by other thread. */
			}

			if ( self->InitializeStep == 2 ) {
				return  false;
			}

			Sleep( g_SingletonInitializerClass_FailSleepTime );
			g_SingletonInitializerClass_FailSleepTime = 0;
		}
	}
}


/*[SingletonInitializerClass_onFinishedInitialize]*/
void  SingletonInitializerClass_onFinishedInitialize( SingletonInitializerClass* self, errnum_t e )
{
	if ( e == 0 )
		{ self->InitializeStep = 2; }
	else
		{ self->InitializeStep = 0; }
}


/*[SingletonInitializerClass_isInitialized]*/
bool  SingletonInitializerClass_isInitialized( SingletonInitializerClass* self )
{
	return  ( self->InitializeStep == 2 );
}


/*-------------------------------------------------------------------------*/
/* <<< End of Class implement >>> */ 
/*-------------------------------------------------------------------------*/


 
/*=================================================================*/
/* <<< [CRT_plus_1/CRT_plus_1.c] >>> */ 
/*=================================================================*/
 
/***********************************************************************
  <<< [ttoi_ex] >>> 
************************************************************************/
int  ttoi_ex( const TCHAR* string,  bit_flags_fast32_t options )
{
	int  return_value;

	UNREFERENCED_VARIABLE( options);

	if ( string[0] == _T('0')  &&
		( string[1] == _T('x')  ||  string[1] == _T('X') ) )
	{
		return_value = (int) _tcstoul( &string[2], NULL, 16 );
	}
	else {
		return_value = _ttoi( string );
	}

	return  return_value;
}


 
