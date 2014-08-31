#include  "include_c.h" 
#pragma hdrstop

typedef struct _MainWorkClass  MainWorkClass;
struct _MainWorkClass {
	TCHAR*  ReadingPath;
	int     NotEnglishCount_InReading;
	bool    IsTry_ForCRT;   /* CRT = C language runtime library */
	bool    IsError_InCRT;  /* CRT = C language runtime library */
	_invalid_parameter_handler  old_invalid_parameter_handler;
};
MainWorkClass  g_MainWorkClass;

int   Main_getFilePathFromNestFind( FileT_CallByNestFindData* m );
void  Main_atExit( const wchar_t * expression, const wchar_t * function, 
	const wchar_t* file,  unsigned int line,  uintptr_t pReserved );


 
/***********************************************************************
  <<< [_tmain] >>> 
************************************************************************/
int  _tmain( int argc, TCHAR* argv[] )
{
	errnum_t        e;
	MainWorkClass*  work = &g_MainWorkClass;
	FILE*           f = NULL;
	StrT_Mul        paths;
	TCHAR*          path;
	Set2            except_names;
	StrMatchKey*    except_name;
	StrMatchKey*    except_name_over;
	int             line_num;
	bool            is_eng;
	TCHAR           line[512];
	TCHAR           check_folder_path[256];
	TCHAR           setting_path[256];

	StrT_Mul_initConst( &paths );
	Set2_initConst( &except_names );
	work->ReadingPath = NULL;
	work->IsTry_ForCRT = false;
	work->IsError_InCRT = false;

	#if USE_GLOBALS
		Globals_initConst();
		e= Globals_initialize(); IF(e)goto fin;
	#endif

	SetBreakErrorID( 0 );

	_tprintf( _T(" ((( CheckEnglishOnly )))\n") );
	_tprintf( _T("テキストファイルが英語だけになっているかチェックします。\n") );


	work->old_invalid_parameter_handler = _set_invalid_parameter_handler( Main_atExit );


	//=== チェックするファイルまたはフォルダーのパスを check_folder_path へ
	_tcscpy_s( check_folder_path, _countof(check_folder_path), _T("") );  // default
	e= GetCommandLineNamed( _T("Folder"), false, check_folder_path, sizeof(check_folder_path) );
	if ( e != E_NOT_FOUND_SYMBOL ) { IF(e)goto fin; }

	_tprintf( _T("チェックするファイルまたはフォルダーのパス: %s\n"), check_folder_path );
	IF( ! FileT_isDir( check_folder_path ) ) goto err_fo;


	//=== 設定ファイルのパスを setting_path へ
	_tcscpy_s( setting_path, _countof(setting_path), _T("") );  // default
	e= GetCommandLineNamed( _T("Setting"), false, setting_path, sizeof(setting_path) );
	if ( e != E_NOT_FOUND_SYMBOL ) { IF(e)goto fin; }

	_tprintf( _T("設定ファイルのパス: %s\n"), setting_path );
	IF( setting_path[0] != _T('\0')  &&  ! FileT_isFile( setting_path ) ) goto err_st;


	//=== 設定ファイルの内容を except_names へ
	e= Set2_init( &except_names, 0x20 ); IF(e)goto fin;
	if ( setting_path[0] != _T('\0') ) {
		TCHAR* right;

		e= FileT_openForRead( &f, setting_path ); IF(e)goto fin;
		for (;;) {
			_fgetts( line, _countof(line), f );

			right = IniStr_refRight( line, true );
			if ( IniStr_isLeft( line, _T("ExceptFile") ) ) {

				e= Set2_alloc( &except_names, &except_name, StrMatchKey ); IF(e)goto fin;
				StrMatchKey_initConst( except_name );
				e= StrMatchKey_init( except_name, right ); IF(e)goto fin;
			}
			if ( feof( f ) )  break;
		}
		fclose( f );  f = NULL;
	}


	//=== チェックするファイルのパスの集合を paths へ
	e= StrT_Mul_init( &paths ); IF(e)goto fin;
	e= FileT_callByNestFind( check_folder_path, 0, &paths, (FuncType) Main_getFilePathFromNestFind );
	IF(e)goto fin;


	//=== チェックするファイルのループ
	is_eng = false;
	for ( StrT_Mul_forEach( &paths, &path ) ) {

		//=== チェックをしないファイルをスキップする
		except_name_over = (StrMatchKey*) except_names.Next;
		for ( except_name = (StrMatchKey*) except_names.First;  except_name < except_name_over;  except_name++ ) {
			if ( StrMatchKey_isMatch( except_name, path ) )  break;
		}
		if ( except_name < except_name_over )  continue;


		//=== ファイルを開く
		e= FileT_openForRead( &f, path ); IF(e)goto fin;
		work->ReadingPath = path;
		work->NotEnglishCount_InReading = 0;
		line_num = 0;


		//=== チェックするファイルの行のループ
		for (;;) {
			line[0] = _T('\0');
			work->IsTry_ForCRT = true;
			_fgetts( line, _countof(line), f );
			work->IsTry_ForCRT = false;
			IF( ferror( f ) ) goto err;
			IF( work->IsError_InCRT ) { e=E_BINARY_FILE; goto fin; }
			line_num ++;
			if ( line[0] != _T('\0') ) {
				TCHAR*  p;

				//=== 1行分のテキストが、すべて英語でなければ、エラーメッセージと内容を表示する
				for ( p = &line[0];  *p != _T('\0');  p++ ) {
					if ( *p > 127 ) {
						work->NotEnglishCount_InReading += 1;
						if ( work->NotEnglishCount_InReading == 1 ) {
							_tprintf( _T("\n<FILE path=\"%s\">\n"), path );
						}
						e= StrT_trim( line, sizeof(line), line ); IF(e)goto fin;
						e= StrT_changeToXML_Attribute( line, sizeof(line), line ); IF(e)goto fin;
						_tprintf( _T("  <LINE num=\"%d\" text=\"%s\"/>\n"), line_num, line );
						break;
					}
				}
			}
			if ( feof( f ) )  break;
		}
		if ( work->NotEnglishCount_InReading > 0 ) {
			_tprintf( _T("  <SUMMARY count=\"%d\"/>\n"), work->NotEnglishCount_InReading );
			_tprintf( _T("</FILE>\n") );
			is_eng = true;
		}
		e= FileT_closeAndNULL( &f, 0 ); IF(e){goto fin;}
		work->ReadingPath = NULL;
	}
	if ( is_eng ) goto err;

	e=0;
fin:
	e= FileT_closeAndNULL( &f, e );
	e= StrT_Mul_finish( &paths, e );

	except_name_over = (StrMatchKey*) except_names.Next;
	for ( except_name = (StrMatchKey*) except_names.First;  except_name < except_name_over;  except_name++ ) {
		e= StrMatchKey_finish( except_name, e );
	}
	e= Set2_finish( &except_names, e );

	e= Globals_finalize( e );
	Error4_showToStdErr( e );
	IfErrThenBreak();
	return  e;

err:
	e=1;  goto fin;

err_fo:
	Error4_printf( _T("<ERROR msg=\"フォルダーが見つかりません\"/>") );
	e=1;  goto fin;

err_st:
	Error4_printf( _T("<ERROR msg=\"設定ファイルが見つかりません\"/>") );
	e=1;  goto fin;
}


 
/***********************************************************************
  <<< [Main_getFilePathFromNestFind] >>> 
************************************************************************/
int  Main_getFilePathFromNestFind( FileT_CallByNestFindData* m )
{
	int        e;
	StrT_Mul*  paths;
	TCHAR      abs_path[MAX_PATH];
	TCHAR      step_path[MAX_PATH];

	paths = (StrT_Mul*) m->CallerArgument;
	e= StrT_getFullPath( abs_path, sizeof(abs_path), m->FullPath, NULL ); IF(e){goto fin;}
	e= StrT_getStepPath( step_path, sizeof(step_path), abs_path, NULL ); IF(e){goto fin;}
	e= StrT_Mul_add( paths, step_path, NULL ); IF(e){goto fin;}

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [Main_atExit] >>> 
************************************************************************/
void  Main_atExit( const wchar_t * expression, const wchar_t * function, 
	const wchar_t* file,  unsigned int line,  uintptr_t pReserved )
{
	MainWorkClass*  work = &g_MainWorkClass;

	if ( work->IsTry_ForCRT ) {

		if ( work->NotEnglishCount_InReading == 0 ) {
			_tprintf( _T("<FILE path=\"%s\">\n"), work->ReadingPath );
		}
		_tprintf( _T("  <LINE num=\"0\" text=\"(This is binary file)\"/>\n") );
		_tprintf( _T("</FILE>\n") );
		work->IsError_InCRT = true;
	}
	else {
		work->old_invalid_parameter_handler( expression, function, file, line, pReserved );
	}
}


 
