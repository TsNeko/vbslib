#include  "include_c.h" 
#include  "vbslib_helper.h" 
#include  <malloc.h>

/* Main function is "_tWinMain" */


errnum_t  GetTextFromClipboard( AppKey** ref_AppKey );
errnum_t  SetTextToClipboard(void);
errnum_t  touch(void);
errnum_t  SetDateLastModified(void);
errnum_t  CutSharpIf( AppKey** ref_AppKey );
errnum_t  CutFFFE( bool  in_IsAppend );
errnum_t  MakeTextSectionIndexFile( AppKey** ref_AppKey );
errnum_t  ConvertDocumentCommentFormat( AppKey** ref_AppKey );
errnum_t  CutCommentC_Command( AppKey** ref_AppKey );
errnum_t  ListUpUsingTxMxKeywords( AppKey** ref_AppKey );
errnum_t  ListUpUsingTxMxKeywords_Main( TCHAR* in_SettingPath, TCHAR* in_OutKeywordsPath );
errnum_t  CutCommentC_1( const TCHAR*  in_InputPath,  const TCHAR*  in_OutputPath );
errnum_t  ReadCharacterEncodingCharacterCommand( CharacterCodeSetEnum*  out_CharacterCode );
errnum_t  ReadCharacterEncodingCharacter( const TCHAR*  in_InputPath,  size_t  in_ReadSize,
	CharacterCodeSetEnum*  out_CharacterCode );


 
/***********************************************************************
  <<< [_tWinMain] >>> 
************************************************************************/
int APIENTRY  _tWinMain( HINSTANCE hInstance, HINSTANCE hPrevInstance,
                         LPTSTR    lpCmdLine, int       nCmdShow )
{
	errnum_t  e;
	TCHAR     command_name[40];
	AppKey*   app_key = NULL;
	int       return_value = 0;

	CharacterCodeSetEnum  character_code_set;

	Globals_initConst();
	e= Globals_initialize(); IF(e){goto fin;}

	#if  USE_printf_to == USE_printf_to_file
		e= AppKey_newWritable( &app_key, NULL, GetLogOptionPath(), NULL ); IF(e)goto fin;
		printf_file_start( true, 0 );
	#endif
SetBreakErrorID( 1 );
//_CrtSetBreakAlloc( 2285 );/* [TODO] */

	UNREFERENCED_VARIABLE_4( hInstance, hPrevInstance, lpCmdLine, nCmdShow );

	e= OpenConsole( false,  NULL ); IF(e){goto fin;}

	e= GetCommandLineUnnamed( 1, command_name, sizeof( command_name ) ); IF(e){goto fin;}
	if ( _tcscmp( command_name, _T("GetTextFromClipboard") ) == 0 )
		{ e= GetTextFromClipboard( &app_key ); IF(e){goto fin;} }
	else if ( _tcscmp( command_name, _T("SetTextToClipboard") ) == 0 )
		{ e= SetTextToClipboard(); IF(e){goto fin;} }
	else if ( _tcscmp( command_name, _T("touch") ) == 0 )
		{ e= touch(); IF(e){goto fin;} }
	else if ( _tcscmp( command_name, _T("SetDateLastModified") ) == 0 )
		{ e= SetDateLastModified(); IF(e){goto fin;} }
	else if ( _tcscmp( command_name, _T("CutSharpIf") ) == 0 )
		{ e= CutSharpIf( &app_key ); IF(e){goto fin;} }
	else if ( _tcscmp( command_name, _T("CutFFFE") ) == 0 )
		{ e= CutFFFE( false ); IF(e){goto fin;} }
	else if ( _tcscmp( command_name, _T("AppendCutFFFE") ) == 0 )
		{ e= CutFFFE( true ); IF(e){goto fin;} }
	else if ( _tcscmp( command_name, _T("MakeTextSectionIndexFile") ) == 0 )
		{ e= MakeTextSectionIndexFile( &app_key ); IF(e){goto fin;} }
	else if ( _tcscmp( command_name, _T("ListUpUsingTxMxKeywords") ) == 0 )
		{ e= ListUpUsingTxMxKeywords( &app_key ); IF(e){goto fin;} }
	else if ( _tcscmp( command_name, _T("ConvertDocumentCommentFormat") ) == 0 )
		{ e= ConvertDocumentCommentFormat( &app_key ); IF(e){goto fin;} }
	else if ( _tcscmp( command_name, _T("CutCommentC") ) == 0 )
		{ e= CutCommentC_Command( &app_key ); IF(e){goto fin;} }
	else if ( _tcscmp( command_name, _T("ReadCharacterEncodingCharacter") ) == 0 ) {
		e= ReadCharacterEncodingCharacterCommand( &character_code_set ); IF(e){goto fin;}
		return_value = (int) character_code_set;
	}
	else
		{ ASSERT_R( false, goto err ); }

	e=0;
fin:
	e= Globals_finalize( e );
	Error4_showToPrintf( e );
	IfErrThenBreak();
	#ifndef  NDEBUG
	if ( _CrtDumpMemoryLeaks() )  DebugBreak();
	#endif
	if ( e == 0 )
		{ e = return_value; }
	return  e;

err:  e = E_OTHERS;  goto fin;
}


 
/***********************************************************************
  <<< [GetTextFromClipboard] >>> 
************************************************************************/
errnum_t  GetTextFromClipboard( AppKey** ref_AppKey )
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


	e= GetCommandLineNamed( _T("Out"), false, out_path, sizeof(out_path) ); IF(e){goto fin;}
	e= AppKey_newWritable( ref_AppKey, NULL, out_path, NULL ); IF(e){goto fin;}

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
	e= FileT_closeAndNULL( &file, e );
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

	e= GetCommandLineNamed( _T("In"), false, in_path, sizeof(in_path) ); IF(e){goto fin;}


	/* Allocate "str" */
	e= FileT_getSize( in_path, &max_size ); IF(e){goto fin;}
	max_size *= sizeof(TCHAR) * 2;  /* 2 is \n -> \r\n */
	size = 0;
	str = (TCHAR*) malloc( max_size ); IF(str==NULL)goto err_fm;
	str_next = str;


	/* Read from "in_path" to "str" */
	e= FileT_openForRead( &file, in_path ); IF(e){goto fin;}
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
	e= FileT_closeAndNULL( &file, e );
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
	e= FileT_closeAndNULL( &file, e );
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
	HANDLE      file = NULL;
	TCHAR       path[MAX_PATH];

	e= GetCommandLineUnnamed( 2, path, sizeof( path ) ); IF(e){goto fin;}
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
  <<< [SetDateLastModified] >>> 
************************************************************************/
errnum_t  SetDateLastModified()
{
	errnum_t    e;
	BOOL        b;
	HANDLE      file = INVALID_HANDLE_VALUE;
	FILE*       csv_file = NULL;
	TCHAR       csv_path[ MAX_PATH ];
	TCHAR       line[ MAX_PATH + W3CDTF_MAX_LENGTH + 2 ];

	e= GetCommandLineUnnamed( 2, csv_path, sizeof( csv_path ) ); IF(e){goto fin;}

	e= FileT_openForRead( &csv_file, csv_path ); IF(e){goto fin;}
	for (;;) {
		line[0] = _T('\0');
		_fgetts( line, _countof(line), csv_file );
		if ( line[0] != _T('\0') ) {
			TCHAR*  p;
			TCHAR   path[ MAX_PATH ];
			TCHAR   time_stamp_string[ W3CDTF_MAX_LENGTH + 1 ];
			int     bias_minute;
			bool    is_read_only = false;
			DWORD   attributes = 0;  /* 0 is for warning C4701 */

			SYSTEMTIME  file_time_for_system;
			FILETIME    file_time;


			p = line;
			e= StrT_meltCSV( path, sizeof( path ), &p ); IF(e){goto fin;}
			e= StrT_meltCSV( time_stamp_string, sizeof( time_stamp_string ), &p ); IF(e){goto fin;}
			e= W3CDTF_toSYSTEMTIME( time_stamp_string, &file_time_for_system, &bias_minute );
				IF(e){goto fin;}
			b= SystemTimeToFileTime( &file_time_for_system, &file_time ); IF(e){goto fin;}
			FILETIME_addMinutes( &file_time, &file_time, -bias_minute );

			file = CreateFile( path, GENERIC_WRITE, 0, NULL, OPEN_EXISTING,
				FILE_ATTRIBUTE_NORMAL , 0 );
			if ( file == INVALID_HANDLE_VALUE ) {
				attributes = GetFileAttributes( path );

				IF ( attributes == INVALID_FILE_ATTRIBUTES ) {
					Error4_printf( _T("<ERROR msg=\"Not found\" path=\"%s\"/>"),  path );
					e=E_ORIGINAL; goto fin;
				}
				else if ( attributes & FILE_ATTRIBUTE_READONLY ) {
					SetFileAttributes( path,  attributes & ~FILE_ATTRIBUTE_READONLY );
					is_read_only = true;
					file = CreateFile( path, GENERIC_WRITE, 0, NULL, OPEN_EXISTING,
						FILE_ATTRIBUTE_NORMAL , 0 );
				}
				IF ( file == INVALID_HANDLE_VALUE ) { e=SaveWindowsLastError(); goto fin; }
			}


			b= SetFileTime( file, NULL, NULL, &file_time );
				IF(!b){ e=SaveWindowsLastError(); goto fin; }


			if ( is_read_only ) {
				SetFileAttributes( path,  attributes );
			}

			e= CloseHandleInFin( file, e );
			file = INVALID_HANDLE_VALUE;
		}
		if ( feof( csv_file ) ) { break; }
	}
	e=0;
fin:
	e= CloseHandleInFin( file, e );
	e= FileT_closeAndNULL( &csv_file, e );
	return  e;
}


 
/***********************************************************************
  <<< [CutSharpIf] >>> 
************************************************************************/
#define  SYMBOL_MAX_SIZE  256

errnum_t  CutSharpIf( AppKey** ref_AppKey )
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

	e= AppKey_newWritable( ref_AppKey, NULL, out_path, NULL ); IF(e){goto fin;}
	e= FileT_openForWrite( &w_file, out_path, 0 ); IF(e){goto fin;}


	e= Parse_PP_Directive( text, &directives ); IF(e){goto fin;}
	e= ParsedRanges_getCut_by_PP_Directive( &cuts, &directives, symbol, is_cut_true );
		IF(e){goto fin;}
	e= ParsedRanges_write_by_Cut( &cuts, text, w_file ); IF(e){goto fin;}
	e= FileT_closeAndNULL( &w_file, e );  w_file = NULL;
	e= FreeMemory( &text, e );


	e=0;
fin:
	e= Delete_PP_Directive( &directives, e );
	e= Set2_finish( &cuts, e );
	e= FreeMemory( &text, e );
	e= FileT_closeAndNULL( &r_file, e );
	e= FileT_closeAndNULL( &w_file, e );
	return  e;
}


 
/***********************************************************************
  <<< [CutFFFE] >>> 
************************************************************************/
errnum_t  CutFFFE( bool  in_IsAppend )
{
	errnum_t  e;
	TCHAR     input_path[ MAX_PATH ];
	TCHAR     output_path[ MAX_PATH ];


	/* Set parameters */
	e= GetCommandLineUnnamed( 2,  input_path,  sizeof(input_path) ); IF(e){goto fin;}
	e= GetCommandLineUnnamed( 3,  output_path,  sizeof(output_path) ); IF(e){goto fin;}


	/* Main */
	e= FileT_cutFFFE( input_path,  output_path,  in_IsAppend ); IF(e){goto fin;}

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [MakeTextSectionIndexFileClass] >>> 
************************************************************************/
typedef struct _MakeTextSectionIndexFileClass  MakeTextSectionIndexFileClass;
struct _MakeTextSectionIndexFileClass {
	StrArr  InputOutputPaths;  /* [0]:InputPath, [1]:OutputPath, [2]:InputPath, ... */
	TCHAR   SectionTypeName[ 80 ];
};

errnum_t  MakeTextSectionIndexFile_readSetting( MakeTextSectionIndexFileClass* work );


 
/***********************************************************************
  <<< [MakeTextSectionIndexFile] >>> 
************************************************************************/
errnum_t  MakeTextSectionIndexFile( AppKey** ref_AppKey )
{
	errnum_t   e;
	FILE*      read_file = NULL;
	FILE*      write_file = NULL;
	TCHAR*     text = NULL;
	ListClass  tokens;
	ListClass  comments;
	TCHAR**    paths;
	int        index_of_path;
	int        input_output_path_count;
	int        r;
	
	LineNumberIndexClass            line_nums;
	MakeTextSectionIndexFileClass   work_body;
	MakeTextSectionIndexFileClass*  work = &work_body;


	ListClass_initConst( &tokens );
	ListClass_initConst( &comments );
	LineNumberIndexClass_initConst( &line_nums );
	StrArr_initConst( &work->InputOutputPaths );
	work->SectionTypeName[0] = _T('\0');

	e= MakeTextSectionIndexFile_readSetting( work ); IF(e){goto fin;}

	input_output_path_count = StrArr_getCount( &work->InputOutputPaths );
	paths = StrArr_getArray( &work->InputOutputPaths );
	for ( index_of_path = 0;  index_of_path < input_output_path_count;  index_of_path += 2 ) {
		TCHAR*                input_path  = paths[ index_of_path + 0 ];
		TCHAR*                output_path = paths[ index_of_path + 1 ];
		TCHAR                 step_path[ MAX_PATH ];
		TCHAR                 output_folder_path[ MAX_PATH ];
		ListIteratorClass     iterator;
		NaturalCommentClass*  comment;
		ListElementClass*     next_element;
		int32_t               end_line;

		NaturalDocsParserConfigClass  config;
		TCHAR*  keywords[] = { _T("Implement"), _T("Class Implement"), _T("End of File") };


		config.Flags =
			NaturalDocsParserConfig_AdditionalKeywords |
			NaturalDocsParserConfig_AdditionalKeywordsLength |
			NaturalDocsParserConfig_AdditionalKeywordsEndsScopesFirstIndex;
		config.AdditionalKeywords = keywords;
		config.AdditionalKeywordsLength = _countof( keywords );
		config.AdditionalKeywordsEndsScopesFirstIndex = 2;
		ASSERT_D( _tcscmp( keywords[ config.AdditionalKeywordsEndsScopesFirstIndex ],
			_T("End of File") ) == 0,  e=E_OTHERS; goto fin );


		e= FileT_openForRead( &read_file, input_path ); IF(e){goto fin;}
		e= FileT_readAll( read_file, &text, NULL ); IF(e){goto fin;}
		e= FileT_closeAndNULL( &read_file, 0 ); IF(e){goto fin;}

		e= LineNumberIndexClass_initialize( &line_nums, text ); IF(e){goto fin;}
		e= LexicalAnalize_C_Language( text, &tokens ); IF(e){goto fin;}
		e= MakeNaturalComments_C_Language( &tokens, &line_nums, &comments, &config ); IF(e){goto fin;}

		e= AppKey_newWritable( ref_AppKey, NULL, output_path, NULL ); IF(e){goto fin;}
		
		e= FileT_openForWrite( &write_file, output_path, F_Unicode ); IF(e){goto fin;}
		r= _ftprintf_s( write_file, _T("<?xml version=\"1.0\" encoding=\"UTF-16\"?>\n") );
			IF(r<0){ e=E_ERRNO; goto fin; }
		e= StrT_getParentFullPath( output_folder_path, sizeof( output_folder_path ),
			output_path, NULL ); IF(e){goto fin;}
		e= StrT_getStepPath( step_path, sizeof(step_path), input_path, output_folder_path );
			IF(e){goto fin;}
		r= _ftprintf_s( write_file, _T("<File  path=\"%s\"  type=\"%s\">\n"),
			step_path, work->SectionTypeName );
			IF(r<0){ e=E_ERRNO; goto fin; }

		for ( ListClass_forEach( &comments, &iterator, &comment ) ) {
			const TCHAR*  class_name;
			TCHAR         period[2];

			next_element =  comment->ListElement.Next;
			if ( next_element == &comments.Terminator ) {
				end_line = LineNumberIndexClass_getCountOfLines( &line_nums );
			} else {
				end_line = ( (NaturalCommentClass*) next_element->Data )->StartLineNum - 1;
			}

			if ( comment->ParentComment == NULL ) {
				class_name = _T("");
				period[0] = _T('\0');
			} else {
				class_name = comment->ParentComment->NaturalDocsHeader->Name;
				period[0] = _T('.');
				period[1] = _T('\0');
			}

			r= _ftprintf_s( write_file,
				_T("<TextSection  keyword=\"%s\"  name=\"%s%s%s\"  start_line=\"%d\"  end_line=\"%d\"")
					_T("  next_to_comment_line=\"%d\"/>\n"),
				comment->NaturalDocsHeader->Keyword,
				class_name,
				period,
				comment->NaturalDocsHeader->Name,
				comment->StartLineNum,
				end_line,
				comment->LastLineNum + 1 );  IF(r<0){ e=E_ERRNO; goto fin; }
		}
		r= _ftprintf_s( write_file, _T("</File>\n") );
			IF(r<0){ e=E_ERRNO; goto fin; }

		e= LineNumberIndexClass_finalize( &line_nums, e );
		e= Delete_SyntaxNodeList( &comments, e );
		e= Delete_C_LanguageToken( &tokens, e );
		e= HeapMemory_free( &text, e );
		e= FileT_closeAndNULL( &read_file, e );
		e= FileT_closeAndNULL( &write_file, e );
		IF(e){goto fin;}
	}


	e=0;
fin:
	e= LineNumberIndexClass_finalize( &line_nums, e );
	e= Delete_SyntaxNodeList( &comments, e );
	e= Delete_C_LanguageToken( &tokens, e );
	e= HeapMemory_free( &text, e );
	e= FileT_closeAndNULL( &read_file, e );
	e= FileT_closeAndNULL( &write_file, e );
	e= StrArr_finish( &work->InputOutputPaths, e );
	return  e;
}


 
/***********************************************************************
  <<< [MakeTextSectionIndexFile_readSetting] >>> 
************************************************************************/
errnum_t  MakeTextSectionIndexFile_readSetting( MakeTextSectionIndexFileClass* work )
{
	errnum_t  e;

	FILE*  setting_file = NULL;
	TCHAR  setting_path[ MAX_PATH ];
	TCHAR  input_path[ MAX_PATH ];
	TCHAR  output_path[ MAX_PATH ];
	TCHAR* right;
	TCHAR  line[ MAX_PATH * 2 ];

	e= GetCommandLineUnnamed( 2, setting_path, sizeof(setting_path) ); IF(e){goto fin;}
		ASSERT_R( setting_path[0] != _T('\0'),  e=E_OTHERS; goto fin );

	e= StrArr_init( &work->InputOutputPaths ); IF(e){goto fin;}

	e= FileT_openForRead( &setting_file, setting_path ); IF(e){goto fin;}
	for (;;) {
		_fgetts( line, _countof(line), setting_file );

		right = IniStr_refRight( line, true );
		if ( IniStr_isLeft( line, _T("SectionType") ) ) {
			e= StrT_cpy( work->SectionTypeName, sizeof(work->SectionTypeName), right );
				IF(e){goto fin;}
		}
		else if ( IniStr_isLeft( line, _T("Path") ) ) {
			e= StrT_parseCSV_f( right, NULL, _T("ss"),
				input_path, sizeof(input_path),
				output_path, sizeof(output_path) ); IF(e){goto fin;}

			e= StrArr_add( &work->InputOutputPaths, input_path,  NULL ); IF(e){goto fin;}
			e= StrArr_add( &work->InputOutputPaths, output_path, NULL ); IF(e){goto fin;}
		}
		if ( feof( setting_file ) ) { break; }
	}
	e=0;
fin:
	e= FileT_closeAndNULL( &setting_file, e );
	return  e;
}


 
/***********************************************************************
  <<< [ListUpUsingTxMxKeywords::_prototypes] >>> 
************************************************************************/
#if  IsListUpUsingTxMxKeywords
errnum_t  TxMxListUp_readSetting( TxMxListUpClass*  work,  TCHAR* in_SettingPath );
errnum_t  TxMxListUp_readTxSc( TxMxListUpClass* work );
errnum_t  TxMxListUp_onXML_Element( ParseXML2_StatusClass* in_Status );
errnum_t  TxMxListUp_compareSectionLineNum( const void* ppLeft, const void* ppRight,
	const void* Param, int* out_Result );
errnum_t  TxMxListUp_listUpUsedNames( TxMxListUpClass* work );
errnum_t  TxMxListUp_addUseNamesSub( TxMxListUpClass* work, TCHAR* in_CallerFilePath, TxScSectionClass* in_Section );
errnum_t  TxMxListUp_readSourceFile( TxScFileClass* in_File );
errnum_t  TxMxListUp_outputUsedNames( TxMxListUpClass* work,  TCHAR* in_OutKeywordsPath );


 
/***********************************************************************
  <<< [ListUpUsingTxMxKeywords] >>> 
************************************************************************/
errnum_t  ListUpUsingTxMxKeywords( AppKey** ref_AppKey )
{
	errnum_t  e;
	TCHAR     setting_path[_MAX_PATH];
	TCHAR     out_keywords_path[_MAX_PATH];

	e= GetCommandLineUnnamed( 2, setting_path, sizeof(setting_path) ); IF(e){goto fin;}
		ASSERT_R( setting_path[0] != _T('\0'),  e=E_OTHERS; goto fin );

	e= StrT_addLastOfFileName( out_keywords_path, sizeof(out_keywords_path),
		setting_path, _T("_out") ); IF(e){goto fin;}

	e= AppKey_newWritable( ref_AppKey, NULL, out_keywords_path, NULL ); IF(e){goto fin;}

	e= ListUpUsingTxMxKeywords_Main( setting_path, out_keywords_path );
		IF(e){goto fin;}

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [ListUpUsingTxMxKeywords_Main] >>> 
************************************************************************/
errnum_t  ListUpUsingTxMxKeywords_Main( TCHAR* in_SettingPath, TCHAR* in_OutKeywordsPath )
{
	errnum_t          e;
	TxMxListUpClass   work_body;
	TxMxListUpClass*  work = &work_body;


	Set4_initConst( &work->TxScFiles );
	Set4_initConst( &work->Sections );
	Strs_initConst( &work->CallerFiles );
	DictionaryAA_Class_initConst( &work->NameDictionary );
	work->Keywords = NULL;
	work->KeywordsLength = 0;
	Set2_initConst( &work->UseNames );
	work->NotSearchedNameIndex = 0;
	SearchStringByAC_Class_initConst( &work->NameSearcher );

	e= Set4_init( &work->TxScFiles, TxScFileClass, 0x1000 ); IF(e){goto fin;}
	e= Set4_init( &work->Sections, TxScSectionClass, 0x1000 ); IF(e){goto fin;}
	e= Strs_init( &work->CallerFiles ); IF(e){goto fin;}
	e= Set2_init( &work->UseNames, 0x1000 ); IF(e){goto fin;}

	e= TxMxListUp_readSetting( work, in_SettingPath ); IF(e){goto fin;}
	e= TxMxListUp_readTxSc( work ); IF(e){goto fin;}
	e= TxMxListUp_listUpUsedNames( work ); IF(e){goto fin;}
	e= TxMxListUp_outputUsedNames( work, in_OutKeywordsPath ); IF(e){goto fin;}

	e=0;
fin:
	e= SearchStringByAC_Class_finalize( &work->NameSearcher, e );
	e= Set2_finish( &work->UseNames, e );
	e= HeapMemory_free( &work->Keywords, e );
	e= DictionaryAA_Class_finalize2( &work->NameDictionary, e, true, TxScKeywordClass_finalize );
	e= Strs_finish( &work->CallerFiles, e );
	e= Set4_finish( &work->Sections, e, TxScSectionClass, TxScSectionClass_finalize );
	e= Set4_finish( &work->TxScFiles, e, TxScFileClass, TxScFileClass_finalize );
	return  e;
}


 
/***********************************************************************
  <<< [TxMxListUp_readSetting] >>> 
- Keywords in setting file
  use         - Using symbols
  txsc_path   - Path of .txsc file
  caller_path - Source file path having using symbols
************************************************************************/
errnum_t  TxMxListUp_readSetting( TxMxListUpClass*  work,  TCHAR* in_SettingPath )
{
	errnum_t  e;
	FILE*     setting_file = NULL;
	TCHAR*    right;
	TCHAR     line[ MAX_PATH * 2 ];

	const TCHAR**            use_name_pointer;
	TxScKeywordClass*        new_keyword = NULL;
	TxScFileClass*           new_file = NULL;
	DictionaryAA_NodeClass*  new_dic_node = NULL;


	e= FileT_openForRead( &setting_file, in_SettingPath ); IF(e){goto fin;}
	for (;;) {
		_fgetts( line, _countof(line), setting_file );

		right = IniStr_refRight( line, true );
		if ( IniStr_isLeft( line, _T("use") ) ) {
			e= DictionaryAA_Class_insert( &work->NameDictionary, right, &new_dic_node );
				IF(e){goto fin;}
			if ( new_dic_node->Item == NULL ) {
				e= HeapMemory_allocate( &new_keyword ); IF(e){goto fin;}
				e= TxScKeywordClass_initialize( new_keyword ); IF(e){goto fin;}
				new_keyword->State = TxMxState_UsedButNotSearched;
				new_keyword->IsUsedFromProject = true;
				new_keyword->CallerFilePath = NULL;
				new_keyword->CallerSection = NULL;
				new_dic_node->Item = new_keyword;
				new_keyword = NULL;
			}

			e= Set2_allocate( &work->UseNames, &use_name_pointer ); IF(e){goto fin;}
			*use_name_pointer = new_dic_node->Key;

			new_dic_node = NULL;
		}
		else if ( IniStr_isLeft( line, _T("txsc_path") ) ) {
			e= Set4_allocate( &work->TxScFiles, &new_file ); IF(e){goto fin;}
			TxScFileClass_initConst( new_file );
			e= MallocAndCopyString( &new_file->TxScPath, right ); IF(e){goto fin;}
			e= Set2_init( &new_file->Sections, 0x1000 ); IF(e){goto fin;}
			new_file = NULL;
		}
		else if ( IniStr_isLeft( line, _T("caller_path") ) ) {
			e= Strs_add( &work->CallerFiles, right, NULL ); IF(e){goto fin;}
		}

		if ( feof( setting_file ) ) { break; }
	}

	e=0;
fin:
	if ( new_keyword != NULL ) {
		e= TxScKeywordClass_finalize( new_keyword, e );
		e= HeapMemory_free( &new_keyword, e );
	}
	if ( new_dic_node != NULL ) {
		if ( new_dic_node->Item != NULL ) {
			e= Set2_finish( new_dic_node->Item, e );
			e= HeapMemory_free( &new_dic_node->Item, e );
		}
		DictionaryAA_Class_remove( &work->NameDictionary, new_dic_node->Key );
	}
	e= Set4_free( &work->TxScFiles, &new_file, e );
	e= FileT_closeAndNULL( &setting_file, e );
	return  e;
}


 
/***********************************************************************
  <<< [TxMxListUp_readTxSc] >>> 
************************************************************************/
errnum_t  TxMxListUp_readTxSc( TxMxListUpClass* work )
{
	errnum_t               e;
	Set4Iter               iterator;
	TxScFileClass*         file;
	ParseXML2_ConfigClass  config;
	TxMxCallbackClass      context;


	/* Read ".txsc" XML file */
	context.Work = work;

	config.Flags = F_ParseXML2_Delegate | F_ParseXML2_OnStartElement;
	config.Delegate = &context;
	config.OnStartElement = TxMxListUp_onXML_Element;

	for ( Set4_forEach( &work->TxScFiles, &iterator, &file ) ) {
		context.File = file;


		e= ParseXML2( file->TxScPath, &config ); IF(e){goto fin;}


		e= PArray_doShakerSort( file->Sections.First,
			PointerType_diff( file->Sections.Next, file->Sections.First ),
			NULL, NULL, TxMxListUp_compareSectionLineNum, NULL ); IF(e){goto fin;}
	}


	/* Call "SearchStringByAC_Class_initialize" */
	e= DictionaryAA_Class_getArray(
		&work->NameDictionary,
		&work->Keywords,  &work->KeywordsLength,  NewStringsEnum_NewPointersAndLinkCharacters );
		IF(e){goto fin;}

	e= SearchStringByAC_Class_initialize(
		&work->NameSearcher,
		_T("") /* TextString will set after here */,
		work->Keywords,  work->KeywordsLength );
		IF(e){goto fin;}

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [TxMxListUp_onXML_Element] >>> 
************************************************************************/
errnum_t  TxMxListUp_onXML_Element( ParseXML2_StatusClass* in_Status )
{
	static const TCHAR*  gs_ScopeStartKeywords[] = {
		_T("class"), _T("structure"), _T("struct")
	};

	errnum_t  e;
	TCHAR*    value;

	TxMxCallbackClass*  context = (TxMxCallbackClass*)in_Status->Delegate;
	TxMxListUpClass*    work = context->Work;
	TxScFileClass*      file = context->File;
	TxScSectionClass*   new_section = NULL;

	DictionaryAA_NodeClass*  new_dic_node = NULL;
	TxScKeywordClass*        new_keyword = NULL;


	if ( _tcsicmp( in_Status->TagName, _T("File") ) == 0 ) {
		TCHAR  base[ _MAX_PATH * 2 ];
		TCHAR  full_path[ _MAX_PATH * 2 ];

		e= StrT_getParentFullPath( base,  sizeof(base),  file->TxScPath, NULL ); IF(e){goto fin;}

		e= ParseXML2_StatusClass_getAttribute( in_Status, _T("path"), &value ); IF(e){goto fin;}
		e= StrT_getFullPath( full_path, sizeof( full_path ), value, base ); IF(e){goto fin;}
		e= MallocAndCopyString( &file->SourcePath, full_path ); IF(e){goto fin;}

		e= ParseXML2_StatusClass_getAttribute( in_Status, _T("type"), &value ); IF(e){goto fin;}
		e= MallocAndCopyString( &file->Type, value ); IF(e){goto fin;}
	}
	else if ( _tcsicmp( in_Status->TagName, _T("TextSection") ) == 0 ) {
		TxScKeywordClass*   txsc_keyword;
		TxScSectionClass**  section_pointer;

		e= ParseXML2_StatusClass_getAttribute( in_Status, _T("name"), &value ); IF(e){goto fin;}
		if ( value[0] != _T('\0') ) {
			TCHAR*  period;

#if 0
			e= ParseXML2_StatusClass_getAttribute( in_Status, _T("keyword"), &keyword ); IF(e){goto fin;}
			if ( StrT_searchStringIndexI( keyword,
				gs_ScopeStartKeywords, _countof( gs_ScopeStartKeywords ),
				NOT_FOUND_INDEX )
				!= NOT_FOUND_INDEX )
			{
			}
#endif

			/* Add "new_section" to "work->Sections" */
			e= Set4_allocate( &work->Sections, &new_section ); IF(e){goto fin;}
			TxScSectionClass_initConst( new_section );
			period = _tcschr( value, _T('.') );
			if ( period == NULL ) {
				e= MallocAndCopyString( &new_section->Name, value ); IF(e){goto fin;}
			} else {
				e= MallocAndCopyStringByLength( &new_section->Name, value,
					period - value ); IF(e){goto fin;}
			}

			e= ParseXML2_StatusClass_getAttribute( in_Status, _T("start_line"), &value ); IF(e){goto fin;}
			new_section->StartLineNum = _ttoi( value );

			e= ParseXML2_StatusClass_getAttribute( in_Status, _T("next_to_comment_line"), &value ); IF(e){goto fin;}
			if ( value == NULL ) {
				new_section->NextToHeaderLineNum = 0;
			} else {
				new_section->NextToHeaderLineNum = _ttoi( value );
			}

			e= ParseXML2_StatusClass_getAttribute( in_Status, _T("end_line"), &value ); IF(e){goto fin;}
			new_section->EndLineNum = _ttoi( value );
			new_section->File = file;
			new_section->TextStart = NULL;
			new_section->TextOver = NULL;
			new_section->NextToHeader = NULL;
			e= Set2_allocate( &file->Sections, &section_pointer ); IF(e){goto fin;}
			*section_pointer = new_section;

			if ( new_section->NextToHeaderLineNum > new_section->EndLineNum ) {
				new_section->NextToHeaderLineNum = new_section->EndLineNum;
			}


			/* Add "new_dic_node" to "work->NameDictionary" */
			e= DictionaryAA_Class_insert( &work->NameDictionary, new_section->Name, &new_dic_node );
				IF(e){goto fin;}
			if ( new_dic_node->Item == NULL ) {
				e= HeapMemory_allocate( &new_keyword ); IF(e){goto fin;}
				e= TxScKeywordClass_initialize( new_keyword ); IF(e){goto fin;}
				new_keyword->State = TxMxState_NotUsed;
				new_keyword->IsUsedFromProject = false;
				new_keyword->CallerFilePath = NULL;
				new_keyword->CallerSection = NULL;
				new_dic_node->Item = new_keyword;
				txsc_keyword = new_keyword;
				new_keyword = NULL;
			} else {
				txsc_keyword = (TxScKeywordClass*) new_dic_node->Item;
			}
			new_dic_node = NULL;

			e= Set2_allocate( &txsc_keyword->Sections, &section_pointer ); IF(e){goto fin;}
			*section_pointer = new_section;

			new_section = NULL;
		}
	}

	e=0;
fin:
	if ( new_keyword != NULL ) {
		e= TxScKeywordClass_finalize( new_keyword, e );
		e= HeapMemory_free( &new_keyword, e );
	}
	if ( new_dic_node != NULL ) {
		if ( new_dic_node->Item != NULL ) {
			e= Set2_finish( new_dic_node->Item, e );
			e= HeapMemory_free( &new_dic_node->Item, e );
		}
		DictionaryAA_Class_remove( &work->NameDictionary, new_dic_node->Key );
	}
	e= Set4_free( &work->Sections, &new_section, e );
	return  e;
}


 
/***********************************************************************
  <<< [TxMxListUp_compareSectionLineNum] >>> 
************************************************************************/
errnum_t  TxMxListUp_compareSectionLineNum( const void* ppLeft, const void* ppRight,
	const void* Param, int* out_Result )
{
	TxScSectionClass*  left  = *(TxScSectionClass**) ppLeft;
	TxScSectionClass*  right = *(TxScSectionClass**) ppRight;

	UNREFERENCED_VARIABLE( Param );

	*out_Result = left->StartLineNum - right->StartLineNum;
	return  0;
}


 
/***********************************************************************
  <<< [TxMxListUp_listUpUsedNames] >>> 
************************************************************************/
errnum_t  TxMxListUp_listUpUsedNames( TxMxListUpClass* work )
{
	errnum_t  e;
	TCHAR*    path = NULL;
	TCHAR**   name_pp;
	FILE*     caller_file = NULL;
	TCHAR*    caller_text = NULL;
	TxScKeywordClass*        txsc_keyword;
	DictionaryAA_NodeClass*  node;
	Set2_IteratorClass       iterator;
	TxScSectionClass**       section_pp;


	/* Set "work->UseNames" from "work->CallerFiles" */
	for ( Strs_forEach( &work->CallerFiles, &path ) ) {

		e= FileT_openForRead( &caller_file, path ); IF(e){goto fin;}
		e= FileT_readAll( caller_file, &caller_text, NULL ); IF(e){goto fin;}
		e= FileT_closeAndNULL( &caller_file, 0 ); IF(e){goto fin;}

		e= SearchStringByAC_Class_setTextString( &work->NameSearcher, caller_text ); IF(e){goto fin;}
		e= TxMxListUp_addUseNamesSub( work, path, NULL ); IF(e){goto fin;}

		e= HeapMemory_free( &caller_text, 0 ); IF(e){goto fin;}
	}
	path = NULL;


	/* Set "work->UseNames" from text section "txsc_keyword->Sections" of "UseNames" */
	for (
		work->NotSearchedNameIndex = 0;
		work->NotSearchedNameIndex < (int) Set2_getCount( &work->UseNames, TCHAR* );
		work->NotSearchedNameIndex += 1 )
	{
		e= Set2_refer( &work->UseNames, work->NotSearchedNameIndex, &name_pp ); IF(e){goto fin;}
		e= DictionaryAA_Class_search( &work->NameDictionary, *name_pp, &node ); IF(e){goto fin;}
		txsc_keyword = (TxScKeywordClass*) node->Item;

		if ( txsc_keyword->State != TxMxState_UsedButNotSearched )
			{ continue; }

		for ( Set2_forEach2( &txsc_keyword->Sections, &iterator, &section_pp ) ) {
			TxScSectionClass*  section = *section_pp;
			TxScFileClass*     file    = section->File;

			if ( file->Text == NULL ) {
				e= TxMxListUp_readSourceFile( file ); IF(e){goto fin;}
			}

			if ( section->NextToHeader == NULL ) {
				e= SearchStringByAC_Class_setTextStringFromPart( &work->NameSearcher,
					section->TextStart,  section->TextOver - section->TextStart );
					IF(e){goto fin;}
			} else {
				e= SearchStringByAC_Class_setTextStringFromPart( &work->NameSearcher,
					section->NextToHeader,  section->TextOver - section->NextToHeader );
					IF(e){goto fin;}
			}

			e= TxMxListUp_addUseNamesSub( work, NULL, section ); IF(e){goto fin;}
		}
	}

	e=0;
fin:
	e= FileT_closeAndNULL( &caller_file, e );
	e= HeapMemory_free( &caller_text, e );
	if ( e != 0  &&  path != NULL ) {
		Error4_printf( _T("<Error num=\"%d\" path=\"%s\"/>"),  e,  path );
	}
	return  e;
}


 
/***********************************************************************
  <<< [TxMxListUp_addUseNamesSub] >>> 
.txsc ファイルにある識別子が、ファイルまたはセクションにあれば、
UseNames に追加する
************************************************************************/
errnum_t  TxMxListUp_addUseNamesSub( TxMxListUpClass* work, TCHAR* in_CallerFilePath, TxScSectionClass* in_Section )
{
	errnum_t  e;
	int       index;
	TCHAR*    keyword;
	TCHAR**   keyword_pp;

	const TCHAR*  text = SearchStringByAC_Class_getTextString( &work->NameSearcher );


	for (;;) {
		bool  is_word;
		int   keyword_length;

		DictionaryAA_NodeClass*  node;
		TxScKeywordClass*        txsc_keyword2;


		e= SearchStringByAC_Class_search( &work->NameSearcher, &index, &keyword );
			IF(e){goto fin;}

		if ( index == SearchString_NotFound )
			{ break; }


		/* Check "is_word" */
		keyword_length = _tcslen( keyword );

		is_word = true;
		if ( index == 0 ) {
		} else if ( StrT_isCIdentifier( text[ index - 1 ] ) ) {
			is_word = false;
		}
		if ( StrT_isCIdentifier( text[ index + keyword_length ] ) ) {
			is_word = false;
		}

		if ( is_word ) {

			/* Set found "txsc_keyword2" */
			e= DictionaryAA_Class_search( &work->NameDictionary, keyword, &node );
				IF(e){goto fin;}

			txsc_keyword2 = (TxScKeywordClass*) node->Item;
			if ( txsc_keyword2->State == TxMxState_NotUsed ) {
				txsc_keyword2->State = TxMxState_UsedButNotSearched;

				e= Set2_allocate( &work->UseNames, &keyword_pp );
					IF(e){goto fin;}
				*keyword_pp = keyword;
			}
			if ( txsc_keyword2->CallerFilePath == NULL ) {
				txsc_keyword2->CallerFilePath = in_CallerFilePath;
			}
			if ( txsc_keyword2->CallerSection == NULL ) {
				txsc_keyword2->CallerSection = in_Section;
			}
		}
	}

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [TxMxListUp_outputUsedNames] >>> 
************************************************************************/
errnum_t  TxMxListUp_outputUsedNames( TxMxListUpClass* work,  TCHAR* in_OutKeywordsPath )
{
	errnum_t            e;
	int                 r;
	FILE*               setting_file = NULL;
	TCHAR**             name_pp;
	Set2_IteratorClass  iterator;


	e= FileT_openForWrite( &setting_file, in_OutKeywordsPath, 0 ); IF(e){goto fin;}
	r= _ftprintf_s( setting_file, _T("[Used]\n") ); IF(r<0){ e=E_ERRNO; goto fin; }

	for ( Set2_forEach2( &work->UseNames, &iterator, &name_pp ) ) {
		TCHAR*  name = *name_pp;
		DictionaryAA_NodeClass*  node;
		TxScKeywordClass*        txsc_keyword;


		r= _ftprintf_s( setting_file, _T("\nname = %s\n"), name );
			IF(r<0){ e=E_ERRNO; goto fin; }


		/* Write caller informations */
		e= DictionaryAA_Class_search( &work->NameDictionary, name, &node );
			IF(e){goto fin;}
		txsc_keyword = (TxScKeywordClass*) node->Item;

		if ( txsc_keyword->IsUsedFromProject ) {
			r= _ftprintf_s( setting_file, _T("is_used_from_project = %d\n"),
				txsc_keyword->IsUsedFromProject );
				IF(r<0){ e=E_ERRNO; goto fin; }
		}
		if ( txsc_keyword->CallerFilePath != NULL ) {
			r= _ftprintf_s( setting_file, _T("caller_file_path = %s\n"),
				txsc_keyword->CallerFilePath );
				IF(r<0){ e=E_ERRNO; goto fin; }
		}
		if ( txsc_keyword->CallerSection != NULL ) {
			r= _ftprintf_s( setting_file, _T("caller_name = %s\n"),
				txsc_keyword->CallerSection->Name );
				IF(r<0){ e=E_ERRNO; goto fin; }
		}
	}

	e=0;
fin:
	e= FileT_closeAndNULL( &setting_file, e );
	return  e;
}


 
/***********************************************************************
  <<< [TxMxListUp_readSourceFile] >>> 
************************************************************************/
errnum_t  TxMxListUp_readSourceFile( TxScFileClass* in_File )
{
	errnum_t  e;
	int       line_num;
	TCHAR*    text_p;  /* text_pointer */
	int       start_line_num;
	int       end_line_num;
	int       next_to_comment_line_num;
	FILE*     reading_file = NULL;

	TxScSectionClass**  section_p_array;  /* section_pointer_array */
	int                 section_p_index;
	int                 section_p_count;


	e= FileT_openForRead( &reading_file, in_File->SourcePath ); IF(e){goto fin;}
	e= FileT_readAll( reading_file, &in_File->Text, NULL ); IF(e){goto fin;}
	e= FileT_closeAndNULL( &reading_file, 0 ); IF(e){goto fin;}

	e= Set2_getArray( &in_File->Sections, &section_p_array, &section_p_count ); IF(e){goto fin;}
	start_line_num = section_p_array[ 0 ]->StartLineNum;
	end_line_num = section_p_array[ 0 ]->EndLineNum;
	ASSERT_R( start_line_num <= end_line_num,  e=E_OTHERS; goto fin );
	next_to_comment_line_num = section_p_array[ 0 ]->NextToHeaderLineNum;
	if ( next_to_comment_line_num != 0 ) {
		ASSERT_R( start_line_num <= next_to_comment_line_num,  e=E_OTHERS; goto fin );
		ASSERT_R( next_to_comment_line_num <= end_line_num,  e=E_OTHERS; goto fin );
	}
	section_p_index = 0;

	for (
		text_p = in_File->Text,  line_num = 1;
		text_p != NULL;
		text_p = StrT_chrNext( text_p, '\n' ),  line_num += 1 )
	{
		if ( line_num == start_line_num ) {
			section_p_array[ section_p_index ]->TextStart = text_p;
		}
		if ( line_num == next_to_comment_line_num ) {
			section_p_array[ section_p_index ]->NextToHeader = text_p;
		}
		if ( line_num == end_line_num + 1 ) {
			section_p_array[ section_p_index ]->TextOver = text_p;

			section_p_index += 1;
			if ( section_p_index >= section_p_count )
				{ break; }
			start_line_num = section_p_array[ section_p_index ]->StartLineNum;
			end_line_num = section_p_array[ section_p_index ]->EndLineNum;
			ASSERT_R( start_line_num <= end_line_num,  e=E_OTHERS; goto fin );
			ASSERT_R( start_line_num >= line_num,  e=E_OTHERS; goto fin );

			next_to_comment_line_num = section_p_array[ section_p_index ]->NextToHeaderLineNum;
			if ( next_to_comment_line_num != 0 ) {
				ASSERT_R( start_line_num <= next_to_comment_line_num,  e=E_OTHERS; goto fin );
				ASSERT_R( next_to_comment_line_num <= end_line_num,  e=E_OTHERS; goto fin );
			}

			if ( line_num == start_line_num ) {
				section_p_array[ section_p_index ]->TextStart = text_p;
			}
		}
	}

	e=0;
fin:
	e= FileT_closeAndNULL( &reading_file, e );
	return  e;
}


 
/***********************************************************************
  <<< [TxScFileClass_initConst] >>> 
************************************************************************/
void  TxScFileClass_initConst( TxScFileClass* self )
{
	self->TxScPath = NULL;
	self->SourcePath = NULL;
	self->Type = NULL;
	self->Text = NULL;
	Set2_initConst( &self->Sections );
}


 
/***********************************************************************
  <<< [TxScFileClass_finalize] >>> 
************************************************************************/
errnum_t  TxScFileClass_finalize( TxScFileClass* self, errnum_t e )
{
	e= HeapMemory_free( &self->TxScPath, e );
	e= HeapMemory_free( &self->SourcePath, e );
	e= HeapMemory_free( &self->Type, e );
	e= HeapMemory_free( &self->Text, e );
	e= Set2_finish( &self->Sections, e );
	return  e;
}


 
/***********************************************************************
  <<< [TxScSectionClass_initConst] >>> 
************************************************************************/
void  TxScSectionClass_initConst( TxScSectionClass* self )
{
	self->Name = NULL;
}


 
/***********************************************************************
  <<< [TxScSectionClass_finalize] >>> 
************************************************************************/
errnum_t  TxScSectionClass_finalize( TxScSectionClass* self, errnum_t e )
{
	e= HeapMemory_free( &self->Name, e );
	return  e;
}


 
/***********************************************************************
  <<< [TxScKeywordClass_initialize] >>> 
************************************************************************/
errnum_t  TxScKeywordClass_initialize( TxScKeywordClass* self )
{
	errnum_t  e;

	Set2_initConst( &self->Sections );

	e= Set2_init( &self->Sections, 0x1000 ); IF(e){goto fin;}

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [TxScKeywordClass_finalize] >>> 
************************************************************************/
errnum_t  TxScKeywordClass_finalize( TxScKeywordClass* self, errnum_t e )
{
	e= Set2_finish( &self->Sections, e );
	return  e;
}
#endif  // IsListUpUsingTxMxKeywords


 
/***********************************************************************
  <<< [ConvertDCF_FileClass] ConvertDocumentCommentFormat FileClass >>> 
************************************************************************/
typedef struct _ConvertDCF_FileClass  ConvertDCF_FileClass;
struct _ConvertDCF_FileClass {
	TCHAR*  InputPath;   /* has */
	TCHAR*  OutputPath;  /* has */
};
void      ConvertDCF_FileClass_initConst( ConvertDCF_FileClass* self );
errnum_t  ConvertDCF_FileClass_finalize( ConvertDCF_FileClass* self,  errnum_t e );

 
/***********************************************************************
  <<< [ConvertDCF_CommentClass] ConvertDocumentCommentFormat CommentClass >>> 
************************************************************************/

typedef struct _ConvertDCF_Class  ConvertDCF_Class;

typedef struct _ConvertDCF_CommentClass  ConvertDCF_CommentClass;
struct _ConvertDCF_CommentClass {
	TCHAR*  ID;   /* has */
	TCHAR*  CommentTemplate;  /* has */
	size_t  CommentTemplateLength;

	const TCHAR*  AtParamLabel;
	TCHAR*        AtParam_Start;
	TCHAR*        AtParam_Over;
};
void      ConvertDCF_CommentClass_initConst( ConvertDCF_CommentClass* self );
errnum_t  ConvertDCF_CommentClass_finalize( ConvertDCF_CommentClass* self,  errnum_t e );
errnum_t  ConvertDCF_CommentClass_parse( ConvertDCF_CommentClass* self );
errnum_t  ConvertDCF_CommentClass_parseAtParam( ConvertDCF_CommentClass* self,
	TCHAR* in_CommentTemplate,  TCHAR** out_StartOfLine,  TCHAR** out_OverOfLine );
errnum_t  ConvertDCF_CommentClass_getReplaced( ConvertDCF_CommentClass* self,
	NaturalCommentClass*  in_A_CommentParsed,  ConvertDCF_Class*  in_ConvertDCF,
	ConvertDCF_FileClass*  in_File,
	TCHAR*  out_A_Comment,  size_t  in_Size_of_A_Comment );


 
/***********************************************************************
  <<< [ConvertDCF_Class] ConvertDocumentCommentFormat Class >>> 
************************************************************************/
typedef struct _ConvertDCF_Class  ConvertDCF_Class;
struct _ConvertDCF_Class {
	Set2  /*<ConvertDCF_FileClass>*/     Files;
	Set2  /*<ConvertDCF_CommentClass>*/  Comments;
	ConvertDCF_CommentClass*             PreviousComment;

	TCHAR*  NoParameter;    /* has */
	TCHAR*  SubTitleStart;  /* has */
	TCHAR*  SubTitleOver;   /* has */
	TCHAR*  LinkStart;      /* has */
	TCHAR*  LinkOver;       /* has */
	TCHAR*  CodeStart;      /* has */
	TCHAR*  CodeOver;       /* has */
	TCHAR*  DefinitionList; /* has */
	TCHAR** PreviousStringPointer;

	FILE*   OutputStream;
	int     WarningCount;
};

errnum_t  ConvertDCF_Class_readSetting(
	ConvertDCF_Class*  work,
	const TCHAR*  in_SettingPath );
errnum_t  ConvertDCF_onXML_Element( ParseXML2_StatusClass* in_Status );
errnum_t  ConvertDCF_onXML_Text( ParseXML2_StatusClass* in_Status );
errnum_t  ConvertDCF_Class_getWritable(
	ConvertDCF_Class*  work,
	TCHAR***  out_Paths,  int*  out_PathCount,  NewStringsEnum  in_HowToAllocate );
errnum_t  ConvertDCF_Class_convert( ConvertDCF_Class*  work );


 
/***********************************************************************
  <<< [ConvertDocumentCommentFormat] >>> 
************************************************************************/
errnum_t  ConvertDocumentCommentFormat( AppKey** ref_AppKey )
{
	errnum_t  e;
	TCHAR     setting_path[_MAX_PATH];
	TCHAR**   paths = NULL;

	ConvertDCF_Class   work_body;
	ConvertDCF_Class*  work = &work_body;


	Set2_initConst( &work->Files );
	Set2_initConst( &work->Comments );
	work->PreviousComment = NULL;

	work->NoParameter    = NULL;
	work->SubTitleStart  = NULL;
	work->SubTitleOver   = NULL;
	work->LinkStart      = NULL;
	work->LinkOver       = NULL;
	work->CodeStart      = NULL;
	work->CodeOver       = NULL;
	work->DefinitionList = NULL;
	work->PreviousStringPointer = NULL;


	e= GetCommandLineUnnamed( 2, setting_path, sizeof(setting_path) ); IF(e){goto fin;}
		ASSERT_R( setting_path[0] != _T('\0'),  e=E_OTHERS; goto fin );

	e= ConvertDCF_Class_readSetting( work, setting_path ); IF(e){goto fin;}


	{ /* Call "AppKey_newWritable_byArray" */
		int  path_count;

		e= ConvertDCF_Class_getWritable( work, &paths, &path_count,
			NewStringsEnum_NewPointersAndLinkCharacters ); IF(e){goto fin;}

		#if  USE_printf_to == USE_printf_to_file
			paths = realloc( paths, ( path_count + 1 ) * sizeof(TCHAR*) );
			paths[ path_count ] = GetLogOptionPath();
			path_count += 1;
		#endif

		e= AppKey_newWritable_byArray( ref_AppKey, NULL, paths, path_count ); IF(e){goto fin;}
	}


	e= ConvertDCF_Class_convert( work );
		IF(e){goto fin;}


	if ( work->WarningCount >= 1 ) {
		_ftprintf( work->OutputStream,
			_T("警告 %d個。 \"<Warning\" を検索してください。"),
			work->WarningCount );
	}

	e=0;
fin:
	e= HeapMemory_free( &paths, e );
	e= HeapMemory_free( &work->NoParameter, e );
	e= HeapMemory_free( &work->SubTitleStart, e );
	e= HeapMemory_free( &work->SubTitleOver, e );
	e= HeapMemory_free( &work->LinkStart, e );
	e= HeapMemory_free( &work->LinkOver, e );
	e= HeapMemory_free( &work->CodeStart, e );
	e= HeapMemory_free( &work->CodeOver, e );
	e= HeapMemory_free( &work->DefinitionList, e );

	/* Clean "work" */
	{
		Set2_IteratorClass        iterator;
		ConvertDCF_FileClass*     file;
		ConvertDCF_CommentClass*  comment;

		for ( Set2_forEach2( &work->Files, &iterator, &file ) ) {
			e= ConvertDCF_FileClass_finalize( file, e );
		}
		e= Set2_finish( &work->Files, e );

		for ( Set2_forEach2( &work->Comments, &iterator, &comment ) ) {
			e= ConvertDCF_CommentClass_finalize( comment, e );
		}
		e= Set2_finish( &work->Comments, e );
	}
	return  e;
}


 
/***********************************************************************
  <<< [ConvertDCF_Class_readSetting] >>> 
************************************************************************/
errnum_t  ConvertDCF_Class_readSetting(
	ConvertDCF_Class*  work,
	const TCHAR*  in_SettingPath )
{
	errnum_t  e;
	ParseXML2_ConfigClass  config;


	e= Set2_init( &work->Files, 0x100 ); IF(e){goto fin;}
	e= Set2_init( &work->Comments, 0x100 ); IF(e){goto fin;}
	work->OutputStream = stdout;
	work->WarningCount = 0;


	config.Flags = F_ParseXML2_Delegate | F_ParseXML2_OnStartElement | F_ParseXML2_OnText;
	config.Delegate = work;
	config.OnStartElement = ConvertDCF_onXML_Element;
	config.OnText         = ConvertDCF_onXML_Text;

	e= ParseXML2( in_SettingPath, &config ); IF(e){goto fin;}

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [ConvertDCF_onXML_Element] >>> 
************************************************************************/
errnum_t  ConvertDCF_onXML_Element( ParseXML2_StatusClass* in_Status )
{
	errnum_t  e;
	TCHAR*    value;
	ConvertDCF_Class*         work = (ConvertDCF_Class*) in_Status->Delegate;
	ConvertDCF_FileClass*     file = NULL;
	ConvertDCF_CommentClass*  comment = NULL;


	if ( _tcsicmp( in_Status->TagName, _T("File") ) == 0 ) {
		e= Set2_allocate( &work->Files, &file ); IF(e){goto fin;}
		ConvertDCF_FileClass_initConst( file );

		e= ParseXML2_StatusClass_getAttribute( in_Status, _T("input"), &value ); IF(e){goto fin;}
		e= MallocAndCopyString( &file->InputPath, value ); IF(e){goto fin;}

		e= ParseXML2_StatusClass_getAttribute( in_Status, _T("output"), &value ); IF(e){goto fin;}
		if ( value == NULL ) {
			e= MallocAndCopyString( &file->OutputPath, file->InputPath ); IF(e){goto fin;}
		} else {
			e= MallocAndCopyString( &file->OutputPath, value ); IF(e){goto fin;}
		}

		file = NULL;
	}
	if ( _tcsicmp( in_Status->TagName, _T("Text") ) == 0 ) {
		e= ParseXML2_StatusClass_getAttribute( in_Status, _T("id"), &value ); IF(e){goto fin;}
		if ( _tcsicmp( value, _T("NoParameter") ) == 0 ) {
			work->PreviousStringPointer = &work->NoParameter;
		} else if ( _tcsicmp( value, _T("SubTitle") ) == 0 ) {
			work->PreviousStringPointer = &work->SubTitleStart;
		} else if ( _tcsicmp( value, _T("Link") ) == 0 ) {
			work->PreviousStringPointer = &work->LinkStart;
		} else if ( _tcsicmp( value, _T("CodeStart") ) == 0 ) {
			work->PreviousStringPointer = &work->CodeStart;
		} else if ( _tcsicmp( value, _T("CodeOver") ) == 0 ) {
			work->PreviousStringPointer = &work->CodeOver;
		} else if ( _tcsicmp( value, _T("DefinitionList") ) == 0 ) {
			work->PreviousStringPointer = &work->DefinitionList;
		} else {
			e= Set2_allocate( &work->Comments, &comment ); IF(e){goto fin;}
			ConvertDCF_CommentClass_initConst( comment );

			e= MallocAndCopyString( &comment->ID, value ); IF(e){goto fin;}

			work->PreviousComment = comment;

			comment = NULL;
		}
	}

	e=0;
fin:
	if ( file != NULL ) {
		e= ConvertDCF_FileClass_finalize( file, e );
		e= Set2_free( &work->Files, &file, e );
	}
	if ( comment != NULL ) {
		e= ConvertDCF_CommentClass_finalize( comment, e );
		e= Set2_free( &work->Comments, &comment, e );
	}
	return  e;
}


 
/***********************************************************************
  <<< [ConvertDCF_onXML_Text] >>> 
************************************************************************/
errnum_t  ConvertDCF_onXML_Text( ParseXML2_StatusClass* in_Status )
{
	errnum_t  e;
	ConvertDCF_Class*  work = (ConvertDCF_Class*) in_Status->Delegate;

	if ( work->PreviousComment != NULL ) {
		TCHAR*  template_text;

		/* Set "work->PreviousComment->CommentTemplate" */
		e= ParseXML2_StatusClass_mallocCopyText( in_Status,
			&work->PreviousComment->CommentTemplate ); IF(e){goto fin;}
		work->PreviousComment->CommentTemplateLength = in_Status->u.OnText.TextLength;
		template_text = work->PreviousComment->CommentTemplate;

		/* Cut first and last "\n" in "template_text" */
		if ( template_text[0] == _T('\n') ) {
			e= StrT_cutPart( template_text,  template_text,  template_text + 1 );
				IF(e){goto fin;}
			work->PreviousComment->CommentTemplateLength -= 1;
		}
		e= StrT_cutLastOf( template_text, _T('\n') ); IF(e){goto fin;}

		/* ... */
		e= ConvertDCF_CommentClass_parse( work->PreviousComment ); IF(e){goto fin;}

		work->PreviousComment = NULL;
	}
	else if ( work->PreviousStringPointer == &work->NoParameter ) {
		TCHAR*  template_text;

		e= ParseXML2_StatusClass_mallocCopyText( in_Status,
			&work->NoParameter ); IF(e){goto fin;}
		template_text = work->NoParameter;

		/* Cut first "\n" in "template_text" */
		if ( template_text[0] == _T('\n') ) {
			e= StrT_cutPart( template_text,  template_text,  template_text + 1 );
				IF(e){goto fin;}
		}

		work->PreviousStringPointer = NULL;
	}
	else if ( work->PreviousStringPointer == &work->SubTitleStart ) {
		const static TCHAR*  sub_title_variable = _T("${SubTitle}");
		const size_t         sub_title_length = 11;

		TCHAR*        p1 = _tcsstr( in_Status->u.OnText.Text, sub_title_variable );
		const TCHAR*  p1_over = in_Status->u.OnText.Text + in_Status->u.OnText.TextLength;

		ASSERT_D( _tcslen( sub_title_variable ) == sub_title_length,  e=E_OTHERS; goto fin );

		if ( p1 == NULL  ||  p1 >= p1_over ) {
			e= ParseXML2_StatusClass_mallocCopyText( in_Status,
				&work->SubTitleStart ); IF(e){goto fin;}
			e= MallocAndCopyString( &work->SubTitleOver, _T("") ); IF(e){goto fin;}
		} else {
			e= MallocAndCopyStringByLength( &work->SubTitleStart,
				in_Status->u.OnText.Text,  p1 - in_Status->u.OnText.Text );
				IF(e){goto fin;}
			p1 += sub_title_length;
			e= MallocAndCopyStringByLength( &work->SubTitleOver,  p1,  p1_over - p1 );
				IF(e){goto fin;}
		}
		work->PreviousStringPointer = NULL;
	}
	else if ( work->PreviousStringPointer == &work->LinkStart ) {
		const static TCHAR*  sub_title_variable = _T("${Keyword}");
		const size_t         sub_title_length = 10;

		TCHAR*        p1 = _tcsstr( in_Status->u.OnText.Text, sub_title_variable );
		const TCHAR*  p1_over = in_Status->u.OnText.Text + in_Status->u.OnText.TextLength;

		ASSERT_D( _tcslen( sub_title_variable ) == sub_title_length,  e=E_OTHERS; goto fin );

		if ( p1 == NULL  ||  p1 >= p1_over ) {
			e= ParseXML2_StatusClass_mallocCopyText( in_Status,
				&work->LinkStart ); IF(e){goto fin;}
			e= MallocAndCopyString( &work->LinkOver, _T("") ); IF(e){goto fin;}
		} else {
			e= MallocAndCopyStringByLength( &work->LinkStart,
				in_Status->u.OnText.Text,  p1 - in_Status->u.OnText.Text );
				IF(e){goto fin;}
			p1 += sub_title_length;
			e= MallocAndCopyStringByLength( &work->LinkOver,  p1,  p1_over - p1 );
				IF(e){goto fin;}
		}
		work->PreviousStringPointer = NULL;
	}
	else if ( work->PreviousStringPointer == &work->CodeStart ) {
		e= ParseXML2_StatusClass_mallocCopyText( in_Status,
			&work->CodeStart ); IF(e){goto fin;}
		work->PreviousStringPointer = NULL;
	}
	else if ( work->PreviousStringPointer == &work->CodeOver ) {
		e= ParseXML2_StatusClass_mallocCopyText( in_Status,
			&work->CodeOver ); IF(e){goto fin;}
		work->PreviousStringPointer = NULL;
	}
	else if ( work->PreviousStringPointer == &work->DefinitionList ) {
		e= ParseXML2_StatusClass_mallocCopyText( in_Status,
			&work->DefinitionList ); IF(e){goto fin;}
		work->PreviousStringPointer = NULL;
	}

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [ConvertDCF_Class_getWritable] >>> 
************************************************************************/
errnum_t  ConvertDCF_Class_getWritable(
	ConvertDCF_Class*  work,
	TCHAR***  out_Paths,  int*  out_PathCount,  NewStringsEnum  in_HowToAllocate )
{
	errnum_t  e;
	int       index_of_paths;
	TCHAR**   paths = NULL;
	int       path_count;

	Set2_IteratorClass     iterator;
	ConvertDCF_FileClass*  file;


	ASSERT_D( in_HowToAllocate == NewStringsEnum_NewPointersAndLinkCharacters,  e=E_OTHERS; goto fin );
	#ifdef  NDEBUG
		UNREFERENCED_VARIABLE( in_HowToAllocate );
	#endif

	path_count = Set2_getCount( &work->Files, ConvertDCF_FileClass );
	*out_PathCount = path_count;

	e= HeapMemory_allocateArray( &paths, path_count ); IF(e){goto fin;}
	index_of_paths = 0;
	for ( Set2_forEach2( &work->Files, &iterator, &file ) ) {
		paths[ index_of_paths ] = file->OutputPath;
		index_of_paths += 1;
	}

	e=0;
fin:
	if ( e != 0 )
		{ e= HeapMemory_free( &paths, e ); }
	*out_Paths = paths;
	return  e;
}


 
/***********************************************************************
  <<< [ConvertDCF_Class_convert] >>> 
************************************************************************/
errnum_t  ConvertDCF_Class_convert( ConvertDCF_Class*  work )
{
	errnum_t   e;
	FILE*      read_file = NULL;
	FILE*      write_file = NULL;
	TCHAR*     source_text = NULL;
	ListClass  tokens;
	ListClass  comments;
	Set2       comment_text;

	const TCHAR*           p_source_text;  /* Pointer to character in "source_text" */
	LineNumberIndexClass   line_nums;
	ConvertDCF_FileClass*  file;
	Set2_IteratorClass     iterator_of_file;


	ListClass_initConst( &tokens );
	ListClass_initConst( &comments );
	LineNumberIndexClass_initConst( &line_nums );
	Set2_initConst( &comment_text );

	e= Set2_init( &comment_text, 0x1000 ); IF(e){goto fin;}

	for ( Set2_forEach2( &work->Files, &iterator_of_file, &file ) ) {
		NaturalCommentClass*      comment;
		ListIteratorClass         iterator;
		Set2_IteratorClass        iterator_of_template;
		ConvertDCF_CommentClass*  template_;
		size_t                    text_length;


		e= FileT_openForRead( &read_file, file->InputPath ); IF(e){goto fin;}
		e= FileT_readAll( read_file, &source_text, &text_length ); IF(e){goto fin;}
		e= FileT_closeAndNULL( &read_file, 0 ); IF(e){goto fin;}
		p_source_text = source_text;

		e= LineNumberIndexClass_initialize( &line_nums, source_text ); IF(e){goto fin;}
		e= LexicalAnalize_C_Language( source_text, &tokens ); IF(e){goto fin;}
		e= MakeNaturalComments_C_Language( &tokens, &line_nums, &comments, NULL ); IF(e){goto fin;}


#if 0
printf("<Output  path=\"%S\"/>\n", file->OutputPath );
#endif

		e= FileT_openForWrite( &write_file, file->OutputPath, 0 ); IF(e){goto fin;}

		for ( ListClass_forEach( &comments, &iterator, &comment ) ) {
			bool  is_output = false;

			e= FileT_writePart( write_file,  p_source_text,  (TCHAR*) comment->Start );
				IF(e){goto fin;}

			for ( Set2_forEach2( &work->Comments, &iterator_of_template, &template_ ) ) {
				if ( _tcsicmp( template_->ID, comment->NaturalDocsHeader->Keyword ) != 0 )
					{ continue; }

				e= Set2_expandIfOverByOffset( &comment_text,
					( text_length + template_->CommentTemplateLength + 1 ) * sizeof(TCHAR) );
					IF(e){goto fin;}

#if 0
printf("<InputComment  name=\"%S\"/>\n", comment->NaturalDocsHeader->Name );
#endif

				e= ConvertDCF_CommentClass_getReplaced( template_,  comment,  work,  file,
					comment_text.First,
					PointerType_diff( comment_text.Over, comment_text.First ) );
					IF(e){goto fin;}


				_fputts( comment_text.First, write_file );
					IF(ferror(write_file)){e=E_ERRNO; goto fin;}

				is_output = true;
			}
			if ( is_output ) {
				p_source_text = comment->Over;
			} else {
				p_source_text = comment->Start;
			}
		}
		_fputts( p_source_text, write_file ); IF(ferror(write_file)){e=E_ERRNO; goto fin;}

		e= LineNumberIndexClass_finalize( &line_nums, e );
		e= Delete_SyntaxNodeList( &comments, e );
		e= Delete_C_LanguageToken( &tokens, e );
		e= HeapMemory_free( &source_text, e );
		e= FileT_closeAndNULL( &read_file, e );
		e= FileT_closeAndNULL( &write_file, e );
		IF(e){goto fin;}
	}

	e=0;
fin:
	e= Set2_finish( &comment_text, e );
	e= LineNumberIndexClass_finalize( &line_nums, e );
	e= Delete_SyntaxNodeList( &comments, e );
	e= Delete_C_LanguageToken( &tokens, e );
	e= HeapMemory_free( &source_text, e );
	e= FileT_closeAndNULL( &read_file, e );
	e= FileT_closeAndNULL( &write_file, e );
	return  e;
}


 
/***********************************************************************
  <<< [ConvertDCF_FileClass_initConst] >>> 
************************************************************************/
void  ConvertDCF_FileClass_initConst( ConvertDCF_FileClass* self )
{
	self->InputPath = NULL;
	self->OutputPath = NULL;
}


 
/***********************************************************************
  <<< [ConvertDCF_FileClass_finalize] >>> 
************************************************************************/
errnum_t  ConvertDCF_FileClass_finalize( ConvertDCF_FileClass* self,  errnum_t e )
{
	e= HeapMemory_free( &self->InputPath, e );
	e= HeapMemory_free( &self->OutputPath, e );
	return  e;
}


 
/***********************************************************************
  <<< [ConvertDCF_CommentClass_initConst] >>> 
************************************************************************/
void  ConvertDCF_CommentClass_initConst( ConvertDCF_CommentClass* self )
{
	self->ID = NULL;
	self->CommentTemplate = NULL;
}


 
/***********************************************************************
  <<< [ConvertDCF_CommentClass_finalize] >>> 
************************************************************************/
errnum_t  ConvertDCF_CommentClass_finalize( ConvertDCF_CommentClass* self,  errnum_t e )
{
	e= HeapMemory_free( &self->ID, e );
	e= HeapMemory_free( &self->CommentTemplate, e );
	return  e;
}


 
/***********************************************************************
  <<< [ConvertDCF_CommentClass_parse] >>> 
************************************************************************/
errnum_t  ConvertDCF_CommentClass_parse( ConvertDCF_CommentClass* self )
{
	errnum_t  e;

	self->AtParamLabel = _T("@param");
	e= ConvertDCF_CommentClass_parseAtParam( self,
		self->CommentTemplate,  &self->AtParam_Start,  &self->AtParam_Over );
		IF(e){goto fin;}

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [ConvertDCF_CommentClass_parseAtParam] >>> 
************************************************************************/
errnum_t  ConvertDCF_CommentClass_parseAtParam( ConvertDCF_CommentClass* self,
	TCHAR* in_CommentTemplate,  TCHAR** out_StartOfLine,  TCHAR** out_OverOfLine )
{
	errnum_t  e;
	TCHAR*    pos_of_param;


	pos_of_param = _tcsstr( in_CommentTemplate,  self->AtParamLabel );


	/* Set "*out_StartOfLine" and ... */
	if ( pos_of_param == NULL ) {
		*out_StartOfLine = NULL;
		*out_OverOfLine  = NULL;
	}
	else {
		*out_StartOfLine = StrT_rstr( in_CommentTemplate,  pos_of_param,
			_T("\n"), NULL );
		ASSERT_R( *out_StartOfLine != NULL,  e=E_OTHERS; goto fin );
		*out_StartOfLine += 1;

		*out_OverOfLine = _tcschr( pos_of_param, _T('\n') );
		ASSERT_R( *out_OverOfLine != NULL,  e=E_OTHERS; goto fin );
		*out_OverOfLine += 1;
	}

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [ConvertDCF_CommentClass_getReplaced] >>> 
************************************************************************/
errnum_t  ConvertDCF_CommentClass_getReplaced( ConvertDCF_CommentClass* self,
	NaturalCommentClass*  in_A_CommentParsed,  ConvertDCF_Class*  in_ConvertDCF,
	ConvertDCF_FileClass*  in_File,
	TCHAR*  out_A_Comment,  size_t  in_Size_of_A_Comment )
{
	enum { at_param_length_max = 1024 };

	errnum_t  e;
	int       index_in_tags;
	int       length_of_tags;
	TCHAR*    descriptions = NULL;

	NameOnlyClass   tags[4];
	NameOnlyClass*  tag;

	ConvertDCF_CommentClass*  template_ = self;


	/* Set "out_A_Comment" : "template_->CommentTemplate" : <Text> tag */
	{
		size_t  size_of_comment_template =
			( template_->CommentTemplateLength + 1 ) * sizeof(TCHAR);

		ASSERT_R( in_Size_of_A_Comment >= size_of_comment_template,  e=E_FEW_ARRAY; goto fin );

		memcpy( out_A_Comment,  template_->CommentTemplate,  size_of_comment_template );
	}


	/* Replace "out_A_Comment" : from the line of "@param" to lines of "@param" */
	{
		Set2_IteratorClass           iterator;
		NaturalDocsDefinitionClass*  a_argument;

		TCHAR*        line_start_in_comment;
		TCHAR*        line_over_in_comment;
		const TCHAR*  after;
		TCHAR         line[ at_param_length_max ];
		ptrdiff_t     size_of_line;
		size_t        length_of_line;


		/* Set "line_start_in_comment" and ... */
		e= ConvertDCF_CommentClass_parseAtParam( template_,
			out_A_Comment,  &line_start_in_comment,  &line_over_in_comment );
			IF(e){goto fin;}
		if ( line_start_in_comment != NULL ) {
			e= StrT_cutPart( out_A_Comment,  line_start_in_comment,  line_over_in_comment );
				IF(e){goto fin;}
		}


		/* ... */
		for ( Set2_forEach2( &in_A_CommentParsed->NaturalDocsHeader->Arguments,  &iterator,
			&a_argument ) )
		{
			/* Set "line" : template_->AtParam_Start */
			size_of_line = PointerType_diff( template_->AtParam_Over, template_->AtParam_Start );
			length_of_line = size_of_line / sizeof(TCHAR);
			size_of_line += sizeof(TCHAR);
			ASSERT_R( size_of_line <= sizeof(line),  e=E_FEW_ARRAY; goto fin );
			memcpy( line,  template_->AtParam_Start,  size_of_line - sizeof(TCHAR) );
			line[ length_of_line ] = _T('\0');


			/* Set "tags" */
			index_in_tags = 0;
			ASSERT_D( index_in_tags < _countof( tags ),  e=E_OTHERS; goto fin );
			tags[ index_in_tags ].Name = _T("${Name}");
			after = a_argument->Name;
			if ( after == NULL )  { tags[ index_in_tags ].Delegate = _T("?"); }
			else                  { tags[ index_in_tags ].Delegate = after; }
			index_in_tags += 1;

			ASSERT_D( index_in_tags < _countof( tags ),  e=E_OTHERS; goto fin );
			tags[ index_in_tags ].Name = _T("${Brief}");
			after = a_argument->Brief;
			if ( after == NULL )  { tags[ index_in_tags ].Delegate = _T(""); }
			else                  { tags[ index_in_tags ].Delegate = after; }
			index_in_tags += 1;
			length_of_tags = index_in_tags;


			/* Replace "line" */
			for ( index_in_tags = 0;  index_in_tags < length_of_tags;  index_in_tags += 1 ) {
				tag = &tags[ index_in_tags ];

				e= StrT_replace( line,  sizeof( line ),  line,
					tag->Name,  tag->Delegate,  0 ); IF(e){goto fin;}
			}


			/* ... */
			e= StrT_insert( out_A_Comment,  in_Size_of_A_Comment,
				line_start_in_comment,  &line_start_in_comment,
				line ); IF(e){goto fin;}
		}

		if ( Set2_getCount( &in_A_CommentParsed->NaturalDocsHeader->Arguments,
			NaturalDocsDefinitionClass ) == 0  &&
			in_ConvertDCF->NoParameter != NULL  &&
			line_start_in_comment != NULL )
		{
			e= StrT_insert( out_A_Comment,  in_Size_of_A_Comment,
				line_start_in_comment,  &line_start_in_comment,
				in_ConvertDCF->NoParameter ); IF(e){goto fin;}
		}
	}


	/* Set "descriptions" : Replaced from "${Descriptions}" */
	if ( in_A_CommentParsed->NaturalDocsHeader->Descriptions != NULL ) {
		const TCHAR*  p_source;
		const TCHAR*  p_source_over;
		TCHAR*        p_out;  /* Pointer to "descriptions" */
		size_t        descriptions_length;
		size_t        descriptions_size;

		NaturalDocsDescriptionClass*  a_description;
		Set2_IteratorClass            iterator;


		descriptions_length =
			( in_A_CommentParsed->NaturalDocsHeader->DescriptionsOver -
			in_A_CommentParsed->NaturalDocsHeader->DescriptionsStart )
			* 2 + 1;
		descriptions_size = descriptions_length * sizeof(TCHAR);
		e= HeapMemory_allocateArray( &descriptions, descriptions_length ); IF(e){goto fin;}

		p_out = descriptions;
		p_source = in_A_CommentParsed->NaturalDocsHeader->DescriptionsStart;
		for ( Set2_forEach2( &in_A_CommentParsed->NaturalDocsHeader->DescriptionItems,  &iterator,
			&a_description ) )
		{
			p_source_over = a_description->Start;
			e= stcpy_part_r( descriptions,  descriptions_size,  p_out,  &p_out,
				p_source,  p_source_over ); IF(e){goto fin;}
			p_source = p_source_over;


			p_source_over = a_description->Over;

			switch ( a_description->Type ) {
				case  NaturalDocsDescriptionType_SubTitle:
					e= stcpy_part_r( descriptions,  descriptions_size,  p_out,  &p_out,
						in_ConvertDCF->SubTitleStart,  NULL ); IF(e){goto fin;}
					e= stcpy_part_r( descriptions,  descriptions_size,  p_out,  &p_out,
						p_source,  p_source_over ); IF(e){goto fin;}
					e= stcpy_part_r( descriptions,  descriptions_size,  p_out,  &p_out,
						in_ConvertDCF->SubTitleOver,  NULL ); IF(e){goto fin;}
					p_source_over = a_description->Over + 1;
					break;

				case  NaturalDocsDescriptionType_Paragraph: {
					const TCHAR*  start;
					const TCHAR*  over;
					const TCHAR*  p_out_start;


					if ( *( p_source_over - 1 ) == _T('\n') )
						{ p_source_over -= 1; }

					if ( a_description->Over >
						in_A_CommentParsed->NaturalDocsHeader->DescriptionsOver )
					{
						p_source_over =
							in_A_CommentParsed->NaturalDocsHeader->DescriptionsOver;
					}


					/* Replace <keyword> to @ref keyword (LinkStart) */
					p_out_start = p_out;
					over = p_source;
					for (;;) {
						start = _tcschr( over, _T('<') );
						if ( start > p_source_over )
							{ start = NULL; }
						if ( start == NULL ) {
							e= stcpy_part_r( descriptions,  descriptions_size,
								p_out,  &p_out,
								over,  p_source_over ); IF(e){goto fin;}
							break;
						} else {
							e= stcpy_part_r( descriptions,  descriptions_size,
								p_out,  &p_out,
								over,  start ); IF(e){goto fin;}

							over = _tcschr( start, _T('>') );
							if ( over > p_source_over )
								{ over = NULL; }
							if ( over == NULL ) {
								e= stcpy_part_r( descriptions,  descriptions_size,
									p_out,  &p_out,
									start + 1,  p_source_over ); IF(e){goto fin;}
								break;
							}
							else {
								e= stcpy_part_r( descriptions,  descriptions_size,
									p_out,  &p_out,
									in_ConvertDCF->LinkStart,  NULL );
									IF(e){goto fin;}
								e= stcpy_part_r( descriptions,  descriptions_size,
									p_out,  &p_out,
									start + 1,  over ); IF(e){goto fin;}
								e= stcpy_part_r( descriptions,  descriptions_size,
									p_out,  &p_out,
									in_ConvertDCF->LinkOver,  NULL );
									IF(e){goto fin;}
								over += 1;
							}
						}
					}


					/* Replace "* - $" to "* $" */
					over = p_out_start- 1;
					for (;;) {
						TCHAR*  pointer = _tcsstr( over, _T("* - $") );
						if ( pointer == NULL )
							{ break; }

						e= StrT_cutPart( descriptions,  pointer + 2,  pointer + 4 );
							IF(e){goto fin;}
					}

					break;
				}

				case  NaturalDocsDescriptionType_Code: {
					TCHAR*  marker = _tcschr( p_source, _T('>') );
					TCHAR*  left;
					TCHAR*  p1;
					TCHAR*  output_code;
					TCHAR   margin_from[16];
					TCHAR   margin_to[16];


					/* "@code" */
					e= stcpy_part_r( descriptions,  descriptions_size,  p_out,  &p_out,
						p_source,  marker ); IF(e){goto fin;}
					e= stcpy_part_r( descriptions,  descriptions_size,  p_out,  &p_out,
						in_ConvertDCF->CodeStart,  NULL ); IF(e){goto fin;}
					e= stcpy_part_r( descriptions,  descriptions_size,  p_out,  &p_out,
						_T("\n"),  NULL ); IF(e){goto fin;}
					output_code = p_out;


					/* Code */
					e= stcpy_part_r( descriptions,  descriptions_size,  p_out,  &p_out,
						p_source,  marker ); IF(e){goto fin;}
					left = marker + 1;  /* Skip '>' */
					if ( *left == _T(' ') )
						{ left += 1; }
					e= stcpy_part_r( descriptions,  descriptions_size,  p_out,  &p_out,
						left,  p_source_over ); IF(e){goto fin;}

					p1 = margin_to;
					e= stcpy_part_r( margin_to,  sizeof( margin_to ),  p1,  &p1,
						_T("\n"),  NULL ); IF(e){goto fin;}
					e= stcpy_part_r( margin_to,  sizeof( margin_to ),  p1,  &p1,
						p_source,  marker ); IF(e){goto fin;}
					e= stprintf_r( margin_from,  sizeof( margin_from ),  _T("%s> "),
						margin_to ); IF(e){goto fin;}
					e= StrT_replace( output_code,
						descriptions_size - PointerType_diff( output_code, descriptions ),
						output_code,  margin_from,  margin_to,  0 ); IF(e){goto fin;}

					e= StrT_cutLastOf( margin_from, _T(' ') ); IF(e){goto fin;}
					e= StrT_replace( output_code,
						descriptions_size - PointerType_diff( output_code, descriptions ),
						output_code,  margin_from,  margin_to,  0 ); IF(e){goto fin;}
					p_out = StrT_chr( output_code, _T('\0') );


					/* "@endcode" */
					e= stcpy_part_r( descriptions,  descriptions_size,  p_out,  &p_out,
						p_source,  marker ); IF(e){goto fin;}
					e= stcpy_part_r( descriptions,  descriptions_size,  p_out,  &p_out,
						in_ConvertDCF->CodeOver,  NULL ); IF(e){goto fin;}

					if ( a_description->Over <=
						in_A_CommentParsed->NaturalDocsHeader->DescriptionsOver )
					{
						e= stcpy_part_r( descriptions,  descriptions_size,  p_out,  &p_out,
							_T("\n"),  NULL ); IF(e){goto fin;}
					}
					else {
						p_source_over =
							in_A_CommentParsed->NaturalDocsHeader->DescriptionsOver;
					}
					break;
				}

				case  NaturalDocsDescriptionType_DefinitionList: {
					const TCHAR*  over = p_source;
					const TCHAR*  p_in_template;
					const TCHAR*  over_in_template;
					const TCHAR*  name_variable = _T("${Name}");
					static size_t name_variable_length = 0;
					const TCHAR*  name_start;
					const TCHAR*  brief_variable = _T("${Brief}");
					static size_t brief_variable_length = 0;

					NaturalDocsDefinitionClass*  def = a_description->u.Definition;

					if ( name_variable_length  == 0 )  { name_variable_length  = _tcslen( name_variable ); }
					if ( brief_variable_length == 0 )  { brief_variable_length = _tcslen( brief_variable ); }
					ASSERT_R( in_ConvertDCF->DefinitionList != NULL,  e=E_OTHERS; goto fin );


					/* Output before DefinitionList */
					e= stcpy_part_r( descriptions,  descriptions_size,  p_out,  &p_out,
						over,  def->NameStart ); IF(e){goto fin;}


					/* Output before ${Name} */
					p_in_template = _tcsstr( in_ConvertDCF->DefinitionList,  name_variable );
						ASSERT_R( p_in_template != NULL,  e=E_OTHERS; goto fin );
					e= stcpy_part_r( descriptions,  descriptions_size,  p_out,  &p_out,
						in_ConvertDCF->DefinitionList,  p_in_template ); IF(e){goto fin;}
					over_in_template = p_in_template + name_variable_length;


					/* Output ${Name} */
					name_start = def->NameStart;
					if ( *name_start == _T(':') ) {
						name_start = StrT_skip( name_start + 1, _T(" \t") );
					}
					e= stcpy_part_r( descriptions,  descriptions_size,  p_out,  &p_out,
						name_start,  def->NameOver ); IF(e){goto fin;}


					/* Output between ${Name} and ${Brief} */
					p_in_template = _tcsstr( over_in_template,  brief_variable );
						ASSERT_R( p_in_template != NULL,  e=E_OTHERS; goto fin );
					e= stcpy_part_r( descriptions,  descriptions_size,  p_out,  &p_out,
						over_in_template,  p_in_template ); IF(e){goto fin;}
					over_in_template = p_in_template + brief_variable_length;


					/* Output ${Brief} */
					e= stcpy_part_r( descriptions,  descriptions_size,  p_out,  &p_out,
						def->BriefStart,  def->BriefOver ); IF(e){goto fin;}


					/* Output after ${Brief} */
					e= stcpy_part_r( descriptions,  descriptions_size,  p_out,  &p_out,
						over_in_template,  NULL ); IF(e){goto fin;}


					/* Output after DefinitionList */
					if ( a_description->Over <=
						in_A_CommentParsed->NaturalDocsHeader->DescriptionsOver )
					{
						e= stcpy_part_r( descriptions,  descriptions_size,  p_out,  &p_out,
							def->BriefOver,  p_source_over ); IF(e){goto fin;}
					}
					else {
						p_source_over =
							in_A_CommentParsed->NaturalDocsHeader->DescriptionsOver;
					}
					break;
				}
				default:
					e= stcpy_part_r( descriptions,  descriptions_size,  p_out,  &p_out,
						p_source,  p_source_over ); IF(e){goto fin;}
					break;
			}
			p_source = p_source_over;
		}

		p_source_over = in_A_CommentParsed->NaturalDocsHeader->DescriptionsOver;
		e= stcpy_part_r( descriptions,  descriptions_size,  p_out,  &p_out,
			p_source,  p_source_over ); IF(e){goto fin;}
		p_source = p_source_over;
	}
	else {
		e= MallocAndCopyString( &descriptions, _T("") ); IF(e){goto fin;}
	}


	/* Set "tags" : For replacing other tags : "${Name}", ... */
	{
		const TCHAR*  after;

		/* "${Name}" */
		index_in_tags = 0;
		ASSERT_D( index_in_tags < _countof( tags ),  e=E_OTHERS; goto fin );
		tags[ index_in_tags ].Name = _T("${Name}");
		after = in_A_CommentParsed->NaturalDocsHeader->Name;
		if ( after == NULL )  { tags[ index_in_tags ].Delegate = _T(""); }
		else                  { tags[ index_in_tags ].Delegate = after; }
		if ( _tcsicmp( in_A_CommentParsed->NaturalDocsHeader->Keyword, _T("file") ) == 0 ) {
			tags[ index_in_tags ].Delegate = StrT_refFName( in_File->InputPath );
			if ( _tcsicmp( in_A_CommentParsed->NaturalDocsHeader->Name,
				in_File->InputPath ) != 0 )
			{
				_ftprintf( in_ConvertDCF->OutputStream,
				_T("<Warning  msg=\"NotSameFileNameTag\"  path=\"%s\"/>\n"),
				in_File->InputPath );
				in_ConvertDCF->WarningCount += 1;
			}
		}
		index_in_tags += 1;

		/* ... */
		ASSERT_D( index_in_tags < _countof( tags ),  e=E_OTHERS; goto fin );
		tags[ index_in_tags ].Name = _T("${Brief}");
		after = in_A_CommentParsed->NaturalDocsHeader->Brief;
		if ( after == NULL )  {
			after = in_A_CommentParsed->NaturalDocsHeader->Name;
			if ( after == NULL )  { tags[ index_in_tags ].Delegate = _T(""); }
			else                  { tags[ index_in_tags ].Delegate = after; }
		}
		else {
			if ( _tcsncmp( after, _T("- $"), 3 ) == 0 )
				{ after += 2; }

			tags[ index_in_tags ].Delegate = after;
		}
		index_in_tags += 1;

		/* ... */
		ASSERT_D( index_in_tags < _countof( tags ),  e=E_OTHERS; goto fin );
		tags[ index_in_tags ].Name = _T("${ReturnValue}");
		after = in_A_CommentParsed->NaturalDocsHeader->ReturnValue;
		if ( after == NULL )  { tags[ index_in_tags ].Delegate = _T("None."); }
		else                  { tags[ index_in_tags ].Delegate = after; }
		index_in_tags += 1;

		/* ... */
		ASSERT_D( index_in_tags < _countof( tags ),  e=E_OTHERS; goto fin );
		tags[ index_in_tags ].Name = _T("${Descriptions}");
		if ( _tcsstr( template_->CommentTemplate, _T("${Brief}") ) == NULL  &&
			in_A_CommentParsed->NaturalDocsHeader->Brief != NULL )
		{
			after = in_A_CommentParsed->NaturalDocsHeader->Brief;
			if ( _tcsncmp( after, _T("- $"), 3 ) == 0 )
				{ after += 2; }

			e= StrHS_insert( &descriptions,  0,  NULL,
				after ); IF(e){goto fin;}
			e= StrHS_insert( &descriptions,  0,  NULL,
				_T("\n* ") ); IF(e){goto fin;}
		}
		after = descriptions;
		if ( after == NULL )  { tags[ index_in_tags ].Delegate = _T(""); }
		else                  { tags[ index_in_tags ].Delegate = after; }
		index_in_tags += 1;
		length_of_tags = index_in_tags;
	}


	/* Replace "out_A_Comment" : Other tags : "${Name}", ... */
	for ( index_in_tags = 0;  index_in_tags < length_of_tags;  index_in_tags += 1 ) {
		tag = &tags[ index_in_tags ];

		e= StrT_replace( out_A_Comment,  in_Size_of_A_Comment,  out_A_Comment,
			tag->Name,  tag->Delegate,  0 ); IF(e){goto fin;}
	}

	e=0;
fin:
	e= HeapMemory_free( &descriptions, e );
	return  e;
}


 
/***********************************************************************
  <<< [CutCommentC_Command] >>> 
************************************************************************/
errnum_t  CutCommentC_Command( AppKey** ref_AppKey )
{
	errnum_t  e;
	TCHAR     setting_path[MAX_PATH*2];
	Strs      paths;  /* source path, destination path, source path, ... */
	TCHAR     line[MAX_PATH*2];
	TCHAR*    right;
	TCHAR*    path;
	TCHAR*    src_path;  /* source path */
	TCHAR*    dst_path;  /* destination path */
	FILE*     file = NULL;
	int       line_num;
	int       error_count = 0;

	enum { waiting_src, waiting_dst }  mode;

	const TCHAR*  bad_src_or_dst_error = _T("Bad order of src and dst in %s(%d)");


	Strs_initConst( &paths );

	e= GetCommandLineNamed( _T("Setting"),  false,  /*Set*/ setting_path,  sizeof(setting_path) );
		IF(e){goto fin;}


	/* Set "paths" */
	e= FileT_openForRead( /*Set*/ &file,  setting_path ); IF(e){goto fin;}
	line_num = 1;
	mode = waiting_src;
	e= Strs_init( &paths ); IF(e){goto fin;}
	for (;;) {
		line[0] = _T('\0');
		_fgetts( line, _countof(line), file );
		right = IniStr_refRight( line, true );

		if ( IniStr_isLeft( line, _T("src") ) ) {  /* src = source file path */
			IF ( mode != waiting_src ) {
				Error4_printf( bad_src_or_dst_error,  line_num,  setting_path );
				e= E_ORIGINAL; goto fin;
			}

			e= Strs_add( &paths, right, NULL ); IF(e){goto fin;}

			mode = waiting_dst;
		}
		if ( IniStr_isLeft( line, _T("dst") ) ) {  /* dst = destination file path */
			IF ( mode != waiting_dst ) {
				Error4_printf( bad_src_or_dst_error,  setting_path,  line_num );
				e= E_ORIGINAL; goto fin;
			}

			e= Strs_add( &paths, right, NULL ); IF(e){goto fin;}

			mode = waiting_src;
		}

		if ( feof( file ) ) { break; }

		line_num += 1;
	}
	IF ( mode != waiting_src ) {
		Error4_printf( bad_src_or_dst_error,  setting_path,  line_num );
		e= E_ORIGINAL; goto fin;
	}
	e= FileT_closeAndNULL( &file, 0 ); IF(e){goto fin;}


	/* ... */
	mode = waiting_src;
	src_path = (TCHAR*) DUMMY_INITIAL_VALUE;
	for ( Strs_forEach( &paths, &path ) ) {
		if ( mode == waiting_src ) {
			src_path = path;
			mode = waiting_dst;

			_tprintf( _T("%s\n"), src_path );
		}
		else {
			ASSERT_D( mode == waiting_dst,  e=E_OTHERS; goto fin );

			dst_path = path;

			e= AppKey_newWritable( ref_AppKey, NULL, dst_path, NULL ); IF(e){goto fin;}

			e= CutCommentC_1( src_path,  dst_path );
				IF ( e ) {
					_tprintf( _T("Error in %s\n"), path );
					error_count += 1;
					ClearError();
				}

			mode = waiting_src;
		}
	}

	IF ( error_count >= 1 ) { e=E_OTHERS; goto fin; }

	e=0;
fin:
	e= FileT_closeAndNULL( &file, e );
	e= Strs_finish( &paths, e );
	return  e;
}


 
/***********************************************************************
  <<< [ReadCharacterEncodingCharacterCommand] >>> 
************************************************************************/
errnum_t  ReadCharacterEncodingCharacterCommand( CharacterCodeSetEnum*  out_CharacterCode )
{
	errnum_t  e;
	TCHAR     path[MAX_PATH*2];
	int       read_size = 8000;  // default

	e= GetCommandLineUnnamed( 2, path, sizeof( path ) ); IF(e){goto fin;}
	e= GetCommandLineNamedI( _T("ReadSize"), false, &read_size );
		if ( e != E_NOT_FOUND_SYMBOL ) { IF(e)goto fin; }
		ClearError();

	e= ReadCharacterEncodingCharacter( path,  read_size,  out_CharacterCode ); IF(e){goto fin;}

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [ReadCharacterEncodingCharacter] >>> 
************************************************************************/
errnum_t  ReadCharacterEncodingCharacter( const TCHAR*  in_InputPath,  size_t  in_ReadSize,
	CharacterCodeSetEnum*  out_CharacterCode )
{
	errnum_t  e;
	HANDLE    file = INVALID_HANDLE_VALUE;
	char*     data = NULL;
	DWORD     read_size;
	BOOL      b;

	CharacterCodeSetEnum  character_code_set = gc_CharacterCodeSetEnum_Unknown;


	e= HeapMemory_allocateArray( &data, in_ReadSize ); IF(e){goto fin;}

	file = CreateFile( in_InputPath,  GENERIC_READ,  FILE_SHARE_READ,  NULL,  OPEN_EXISTING,
		FILE_ATTRIBUTE_NORMAL, 0 );
		IF( file == INVALID_HANDLE_VALUE ) { e=E_GET_LAST_ERROR; goto fin; }

	b= ReadFile( file,  data,  in_ReadSize,  &read_size,  NULL );
		IF(!b){ e=SaveWindowsLastError(); goto fin; }
	data[ in_ReadSize - 1 ] = '\0';


	if ( (int) data[0] == 0xEF  &&  (int) data[1] == 0xBB  &&  (int) data[2] == 0xBF ) {
		character_code_set = gc_CharacterCodeSetEnum_UTF_8;
	}
	else if ( (int) data[0] == 0xFF  &&  (int) data[1] == 0xFE ) {
		character_code_set = gc_CharacterCodeSetEnum_UTF_16;
	}
	else if ( data[0] == '<'  &&  data[1] == '?'  &&
			data[2] == 'x'  &&  data[3] == 'm'  &&  data[4] == 'l' ) {
		character_code_set = gc_CharacterCodeSetEnum_XML;
	}
	else {
		/* Example:  Character Encoding: "WHITE SQUARE" U+25A1 is □. */
		char*     p;
		char*     p2 = NULL;
		char*     a_character;
		wchar_t   code[2];
		char      code_MBS[4];  // MBS = Multi Byte String
		char      code_UTF_8[4];
		int       r;

		p = strstr( data,  "Character Encoding: " );
		if ( p != NULL ) {
			p = strstr( p,  "U+" );
		}
		if ( p != NULL ) {
			p += 2;
			p2 = strchr( p,  ' ' );
		}
		if ( p2 != NULL ) {
			*p2 = '\0';

			code[0] = (uint16_t) strtoul( p, NULL, 16 );
			code[1] = L'\0';

			r= WideCharToMultiByte( CP_OEMCP, 0, code, -1, code_MBS,   sizeof(code_MBS),   NULL, NULL );
				IF(r==0){ e=E_OTHERS; goto fin; }
			r= WideCharToMultiByte( CP_UTF8,  0, code, -1, code_UTF_8, sizeof(code_UTF_8), NULL, NULL );
				IF(r==0){ e=E_OTHERS; goto fin; }
			p = strchr( p2 + 1,  ' ' );
		}
		if ( p != NULL ) {
			a_character = p + 1;

			if ( memcmp( a_character,  code_MBS,  strlen( code_MBS ) ) == 0 ) {
				character_code_set = gc_CharacterCodeSetEnum_OEM;
			}
			else if ( memcmp( a_character,  code_UTF_8,  strlen( code_UTF_8 ) ) == 0 ) {
				character_code_set = gc_CharacterCodeSetEnum_UTF_8_NoBOM;
			}
		}
	}

	e=0;
fin:
	*out_CharacterCode = character_code_set;
	e= CloseHandleInFin( file, e );
	e= HeapMemory_free( &data, e );
	return  e;
}


 

