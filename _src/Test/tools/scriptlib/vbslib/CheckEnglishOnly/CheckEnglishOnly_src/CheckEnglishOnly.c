#include  "include_c.h" 

enum { gs_PathLengthMax = 1024 };

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
	TCHAR           check_folder_path[ gs_PathLengthMax ];
	TCHAR           base_path[ gs_PathLengthMax ];
	TCHAR           setting_path[ gs_PathLengthMax ];

	StrT_Mul_initConst( &paths );
	Set2_initConst( &except_names );
	work->ReadingPath = NULL;
	work->IsTry_ForCRT = false;
	work->IsError_InCRT = false;

	#if USE_GLOBALS
		Globals_initConst();
		e= Globals_initialize(); IF(e){goto fin;}
	#endif

	SetBreakErrorID( 1 );

	_tprintf( _T(" ((( CheckEnglishOnly )))\n") );
	_tprintf( _T("�e�L�X�g�t�@�C�����p�ꂾ���ɂȂ��Ă��邩�`�F�b�N���܂��B\n") );


	work->old_invalid_parameter_handler = _set_invalid_parameter_handler( Main_atExit );


	/* Set "check_folder_path" : �p�ꂾ�������`�F�b�N����t�H���_�[�̃p�X�A�܂��́A�t�@�C���̃p�X */
	_tcscpy_s( check_folder_path, _countof(check_folder_path), _T("") );  // default
	e= GetCommandLineNamed( _T("Folder"), false, check_folder_path, sizeof(check_folder_path) );
	if ( e != E_NOT_FOUND_SYMBOL ) { IF(e){goto fin;} }

	_tprintf( _T("�`�F�b�N����t�@�C���܂��̓t�H���_�[�̃p�X: %s\n"), check_folder_path );
	IF( ! FileT_isDir( check_folder_path ) ) goto err_fo;


	/* Set "setting_path" : �ݒ�t�@�C���̃p�X */
	_tcscpy_s( setting_path, _countof(setting_path), _T("") );  // default
	e= GetCommandLineNamed( _T("Setting"), false, setting_path, sizeof(setting_path) );
	if ( e != E_NOT_FOUND_SYMBOL ) { IF(e){goto fin;} }

	_tprintf( _T("�ݒ�t�@�C���̃p�X: %s\n"), setting_path );
	IF( setting_path[0] != _T('\0')  &&  ! FileT_isFile( setting_path ) ) {goto err_st;}

	if ( setting_path[0] != _T('\0') ) {
		e= StrT_getParentFullPath( base_path,  sizeof( base_path ),  setting_path,  NULL );
			IF(e){goto fin;}
	} else {
		e= StrT_getFullPath( base_path,  sizeof( base_path ),  check_folder_path,  NULL );
			IF(e){goto fin;}
	}


	/* Set "except_names" : �ݒ�t�@�C���Ɏw�肵�� "ExceptFile" */
	e= Set2_init( &except_names, 0x20 ); IF(e){goto fin;}
	if ( setting_path[0] != _T('\0') ) {
		TCHAR* right;
		TCHAR  full_path[ gs_PathLengthMax ];

		e= FileT_openForRead( &f, setting_path ); IF(e){goto fin;}
		for (;;) {
			_fgetts( line, _countof(line), f );

			right = IniStr_refRight( line, true );
			if ( IniStr_isLeft( line, _T("ExceptFile") ) ) {

				if ( right[0] == _T('*') ) {
					e= StrT_cpy( full_path, sizeof( full_path ), right ); IF(e){goto fin;}
				} else {
					e= StrT_getFullPath( full_path, sizeof( full_path ),
						right,  base_path );
						IF(e){goto fin;}
				}

				e= Set2_alloc( &except_names, &except_name, StrMatchKey ); IF(e){goto fin;}
				StrMatchKey_initConst( except_name );
				e= StrMatchKey_init( except_name, full_path ); IF(e){goto fin;}
			}
			if ( feof( f ) )  break;
		}
		fclose( f );  f = NULL;
	}


	/* Set "paths" : �`�F�b�N����t�@�C���̃p�X�̏W���B"path" �̓t�� �p�X */
	e= StrT_Mul_init( &paths ); IF(e){goto fin;}
	e= FileT_callByNestFind( check_folder_path, 0, &paths, (FuncType) Main_getFilePathFromNestFind );
		IF(e){goto fin;}
	is_eng = false;
	for ( StrT_Mul_forEach( &paths, &path ) ) {

		/* "path" ���A�`�F�b�N�����Ȃ��t�@�C�� "except_names" �Ɋ܂܂��Ȃ�X�L�b�v���� */
		except_name_over = (StrMatchKey*) except_names.Next;
		for ( except_name = (StrMatchKey*) except_names.First;  except_name < except_name_over;  except_name++ ) {
			if ( StrMatchKey_isMatch( except_name, path ) ) { break; }
		}
		if ( except_name < except_name_over ) { continue; }


		/* "path" �t�@�C�����J�� */
		e= FileT_openForRead( &f, path ); IF(e){goto fin;}
		work->ReadingPath = path;
		work->NotEnglishCount_InReading = 0;
		line_num = 0;


		/* �`�F�b�N����t�@�C���̍s�̃��[�v */
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
				TCHAR   step_path[ gs_PathLengthMax ];

				/* 1�s���̃e�L�X�g���A���ׂĉp��łȂ���΁A�G���[���b�Z�[�W�Ɠ��e��\������ */
				for ( p = &line[0];  *p != _T('\0');  p++ ) {
					if ( *p > 127 ) {
						work->NotEnglishCount_InReading += 1;
						if ( work->NotEnglishCount_InReading == 1 ) {
							e= StrT_getStepPath( step_path, sizeof( step_path ),
								path,  base_path );
								IF(e){goto fin;}

							_tprintf( _T("\n<FILE path=\"%s\">\n"), step_path );
						}
						e= StrT_trim( line, sizeof(line), line ); IF(e){goto fin;}
						e= StrT_changeToXML_Attribute( line, sizeof(line), line ); IF(e){goto fin;}
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
	Error4_printf( _T("<ERROR msg=\"�t�H���_�[��������܂���\"/>") );
	e=1;  goto fin;

err_st:
	Error4_printf( _T("<ERROR msg=\"�ݒ�t�@�C����������܂���\"/>") );
	e=1;  goto fin;
}


 
/***********************************************************************
  <<< [Main_getFilePathFromNestFind] >>> 
************************************************************************/
int  Main_getFilePathFromNestFind( FileT_CallByNestFindData* m )
{
	int        e;
	StrT_Mul*  paths;
	TCHAR      full_path[ gs_PathLengthMax ];

	paths = (StrT_Mul*) m->CallerArgument;
	e= StrT_getFullPath( full_path, sizeof(full_path), m->FullPath, NULL ); IF(e){goto fin;}
	e= StrT_Mul_add( paths, full_path, NULL ); IF(e){goto fin;}

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


 
