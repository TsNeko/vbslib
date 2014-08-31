#include  "include_c.h" 


 
#define  FEQ_MAX_PATH  ( MAX_PATH * 4 )
enum { E_EXIT_FIND = 0x601 };

typedef struct _FeqWorkClass  FeqWorkClass;
struct _FeqWorkClass {
	TCHAR  Path[ 2 ][ FEQ_MAX_PATH ];
	int    FindingIndex;
	int    OtherIndex;
	bool   IsCompared;
	bool   IsSame;
	bool   IsOtherExists;
	TCHAR  NotSameStepPath[ FEQ_MAX_PATH ];
};
FeqWorkClass  g_FeqWork;
errnum_t  Feq_onNestFindFolder( void* Param );
errnum_t  Feq_onNestFindFileForCompare( void* Param );
errnum_t  Feq_onNestFindFileForExists( void* Param );
void      Feq_onCompared( FeqWorkClass* work );


 
int  _tmain()
{
	errnum_t  e;
	int       i;
	FeqWorkClass*  work = &g_FeqWork;

//SetBreakErrorID( 1 );

	work->IsCompared = false;
	work->NotSameStepPath[0] = _T('\0');

	Globals_initConst();
	e= Globals_initialize(); IF(e)goto fin;

	e= GetCommandLineUnnamed( 1, work->Path[0], sizeof(work->Path[0]) ); IF(e)goto fin;
	IF( work->Path[0] == _T('\0') ) goto help;

	e= GetCommandLineUnnamed( 2, work->Path[1], sizeof(work->Path[1]) ); IF(e)goto fin;

	e= StrT_cutLastOf( work->Path[0], _T('\\') ); IF(e)goto fin;
	e= StrT_cutLastOf( work->Path[1], _T('\\') ); IF(e)goto fin;


	/* Compare files */
	if ( FileT_isFile( work->Path[0] ) && FileT_isFile( work->Path[1] ) ) {
		e= FileT_isSameBinaryFile( work->Path[0], work->Path[1], 0, &work->IsSame ); IF(e)goto fin;
		work->IsCompared = true;
		Feq_onCompared( work );
	}


	/* Compare folders */
	else if ( FileT_isDir( work->Path[0] ) && FileT_isDir( work->Path[1] ) ) {

		/* Compare folder exists */
		for ( i = 0; i < 2; i+=1 ) {
			work->FindingIndex = i;
			work->OtherIndex = 1 - i;
			e= FileT_callByNestFind( work->Path[i], FileT_FolderBeforeFiles,
				work, Feq_onNestFindFolder );

			if ( ( e == E_EXIT_FIND ) && ( work->IsCompared ) ) {
				ClearError();
				e=0;
				_tprintf( _T("Not found \"%s\" in \"%s\"\n"), work->NotSameStepPath,
					work->Path[ work->OtherIndex ] );
				break;
			}
			IF(e)goto fin;
		}

		/* Compare file contents and exists [0]->[1] */
		if ( ! work->IsCompared ) {
			work->FindingIndex = 0;
			work->OtherIndex = 1;
			e= FileT_callByNestFind( work->Path[ work->FindingIndex ], 0,
				work, Feq_onNestFindFileForCompare );

			if ( ( e == E_EXIT_FIND ) && ( work->IsCompared ) ) {
				ClearError();
				e=0;
				if ( work->IsOtherExists ) {
					_tprintf( _T("Not same \"%s\"\n"), work->NotSameStepPath );
				}
				else {
					_tprintf( _T("Not found \"%s\" in \"%s\"\n"), work->NotSameStepPath,
						work->Path[ work->OtherIndex ] );
				}
			}
			IF(e)goto fin;
		}

		/* Compare file exists [1]->[0] */
		if ( ! work->IsCompared ) {
			work->FindingIndex = 1;
			work->OtherIndex = 0;
			e= FileT_callByNestFind( work->Path[ work->FindingIndex ], 0,
				work, Feq_onNestFindFileForExists );

			if ( ( e == E_EXIT_FIND ) && ( work->IsCompared ) ) {
				ClearError();
				e=0;
				_tprintf( _T("Not found \"%s\" in \"%s\"\n"), work->NotSameStepPath,
					work->Path[ work->OtherIndex ] );
			}
			IF(e)goto fin;
		}
		if ( ! work->IsCompared ) {
			work->IsSame = true;
			work->IsCompared = true;
			Feq_onCompared( work );
		}
	}
	else {
		for ( i = 0; i < 2; i+=1 ) {
			if ( ! FileT_isExist( work->Path[i] ) ) {
				_tprintf( _T("Not found %s\n"), work->Path[i] );
				work->IsSame = false;
				work->IsCompared = true;
			}
		}
		ASSERT_R( work->IsCompared, goto err );
	}

	if ( work->IsCompared ) {
		if ( work->IsSame )
			{ _tprintf( _T("same.\n") ); }
		else
			{ _tprintf( _T("different.\n") ); }
	}

	e=0;
fin:
	e= Globals_finalize( e );
	if ( work->IsCompared ) {
		if ( work->IsSame )
			{ e = 0; }
		else
			{ e = 1; }
	}
	else {
		if ( e == 1 )
			{ e = 2; }
		Error4_showToStdErr( e );
	}
	return  e;

help:
	_tprintf( _T("help: feq (path1) (path2)") );
	e = 2;
	goto fin;

err:  e = E_OTHERS;  goto fin;
}


 
/***********************************************************************
  <<< [Feq_onNestFindFolder] >>> 
************************************************************************/
errnum_t  Feq_onNestFindFolder( void* Param )
{
	errnum_t  e;
	FileT_CallByNestFindData*  find = (FileT_CallByNestFindData*) Param;
	FeqWorkClass*  work = (FeqWorkClass*) find->CallerArgument;
	TCHAR  other_path[ FEQ_MAX_PATH ];

	if ( ! ( find->FileAttributes & FILE_ATTRIBUTE_DIRECTORY ) )  { return 0; }

	e= StrT_getFullPath( other_path,  sizeof(other_path),
		find->StepPath, work->Path[ work->OtherIndex ] ); IF(e)goto fin;

	if ( ! FileT_isDir( other_path ) ) {
		e= StrT_cpy( work->NotSameStepPath, sizeof( work->NotSameStepPath ), find->StepPath );
			IF(e)goto fin;
		work->IsSame = false;
		work->IsOtherExists = false;
		work->IsCompared = true;
		Feq_onCompared( work );
		e = E_EXIT_FIND;
		goto fin;
	}

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [Feq_onNestFindFileForCompare] >>> 
************************************************************************/
errnum_t  Feq_onNestFindFileForCompare( void* Param )
{
	errnum_t  e;
	FileT_CallByNestFindData*  find = (FileT_CallByNestFindData*) Param;
	FeqWorkClass*  work = (FeqWorkClass*) find->CallerArgument;
	TCHAR  other_path[ FEQ_MAX_PATH ];

	e= StrT_getFullPath( other_path,  sizeof(other_path),
		find->StepPath, work->Path[ work->OtherIndex ] ); IF(e)goto fin;

	if ( ! FileT_isFile( other_path ) ) {
		e= StrT_cpy( work->NotSameStepPath, sizeof( work->NotSameStepPath ), find->StepPath );
			IF(e)goto fin;
		work->IsSame = false;
		work->IsOtherExists = false;
		work->IsCompared = true;
		Feq_onCompared( work );
		e = E_EXIT_FIND;
		goto fin;
	}

	e= FileT_isSameBinaryFile( find->FullPath, other_path, 0, &work->IsSame ); IF(e)goto fin;
	if ( ! work->IsSame ) {
		e= StrT_cpy( work->NotSameStepPath, sizeof( work->NotSameStepPath ), find->StepPath );
			IF(e)goto fin;
		work->IsOtherExists = true;
		work->IsCompared = true;
		Feq_onCompared( work );
		e = E_EXIT_FIND;
		goto fin;
	}

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [Feq_onNestFindFileForExists] >>> 
************************************************************************/
errnum_t  Feq_onNestFindFileForExists( void* Param )
{
	errnum_t  e;
	FileT_CallByNestFindData*  find = (FileT_CallByNestFindData*) Param;
	FeqWorkClass*  work = (FeqWorkClass*) find->CallerArgument;
	TCHAR  other_path[ FEQ_MAX_PATH ];

	e= StrT_getFullPath( other_path,  sizeof(other_path),
		find->StepPath, work->Path[ work->OtherIndex ] ); IF(e)goto fin;

	if ( ! FileT_isFile( other_path ) ) {
		e= StrT_cpy( work->NotSameStepPath, sizeof( work->NotSameStepPath ), find->StepPath );
			IF(e)goto fin;
		work->IsSame = false;
		work->IsOtherExists = false;
		work->IsCompared = true;
		Feq_onCompared( work );
		e = E_EXIT_FIND;
		goto fin;
	}

	e=0;
fin:
	return  e;
}


 
void  Feq_onCompared( FeqWorkClass* work )
{
	UNREFERENCED_VARIABLE( work );
}


 
