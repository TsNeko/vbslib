/* Character Code Encoding: "WHITE SQUARE" is □ */
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
    AppKey_initGlobal_const(); 
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
    HeapLogClass_finalize();
    e= AppKey_finishGlobal( e ); 

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


 
/***********************************************************************
* Function: GetProcessInformation
************************************************************************/
errnum_t  GetProcessInformation( DWORD  in_ProcessID,  PROCESSENTRY32*  out_Info )
{
	errnum_t  e;
	BOOL      b;
	HANDLE    snapshot = (HANDLE) -1;

	snapshot = CreateToolhelp32Snapshot( TH32CS_SNAPPROCESS, 0 );
		IF ( snapshot == (HANDLE) -1 ) { e=E_OTHERS; goto fin; }
	b= Process32First( snapshot,  /*Set*/ out_Info );
		IF (!b) { e=E_OTHERS; goto fin; }
	for (;;) {
		if ( out_Info->th32ProcessID == in_ProcessID ) {
			break;
		}
		b= Process32Next( snapshot,  /*Set*/ out_Info );
		IF (!b) { e=E_OTHERS; goto fin; }
	}

	e=0;
fin:
	if ( snapshot != (HANDLE) -1 )  { CloseHandle( snapshot ); }
	return  0;
}


 
/***********************************************************************
  <<< [env_part] >>> 
************************************************************************/
int  env_part( TCHAR* Str,  unsigned StrSize,  TCHAR* StrStart, TCHAR** out_StrLast,
	 const TCHAR* Input )
{
	int  e;
	const TCHAR*  p;
	const TCHAR*  p2;
	TCHAR*  o;
	TCHAR*  o_last;
	TCHAR   c;
	DWORD   r;
	DWORD   count;
	TCHAR   name[128];

	p = Input;  o = StrStart;  o_last = (TCHAR*)( (char*)Str + StrSize - sizeof(TCHAR) );
	IF_D( StrStart < Str || StrStart >= o_last ) goto err;

	c = *p;
	IF_D( StrSize <= 2 ) return  E_FEW_ARRAY;

	while ( c != _T('\0') ) {
		if ( c == _T('%') ) {
			p++;
			if ( *p == _T('%') ) {

				//=== % 文字をコピーする
				IF( o == o_last )goto err_fa;
				*o = c;
				p++;  o++;
			}
			else {

				//=== 環境変数名を name に取得する
				p2 = _tcschr( p, _T('%') ); IF( p2 == NULL )goto err_ns;
				e= StrT_cpy( name, sizeof(name), _T("abc") ); IF(e)goto fin;
				e= stcpy_part_r( name, sizeof(name), name, NULL, p, p2 ); IF(e)goto fin;

				//=== 環境変数の値を o に取得する
				count = ( o_last + sizeof(TCHAR) - o ) / sizeof(TCHAR);
				r= GetEnvironmentVariable( name, o, count );
				IF( r==0 ) goto err_ns;  // 環境変数が見つからない
				IF( r > count ) goto err_fa;

				//=== p, o を更新する
				p = p2 + 1;
				o = StrT_chr( o, _T('\0') );
			}
		}
		else {

			//=== 環境変数ではない部分をコピーする
			IF( o == o_last )goto err_fa;
			*o = c;
			p++;  o++;
		}
		c = *p;
	}

	e=0;
fin:
	*o = _T('\0');
	if ( out_StrLast != NULL )  *out_StrLast = o;
	return  e;

err_fa:  e = E_FEW_ARRAY;  goto fin;
err_ns:  e = E_NOT_FOUND_SYMBOL; goto fin;
err:  e = E_OTHERS;  goto fin;
}


 
/***********************************************************************
  <<< [env_malloc] >>> 
************************************************************************/
int  env_malloc( TCHAR** out_Value, size_t* out_ValueLen, const TCHAR* Name )
{
	int     e;
	DWORD   r;
	TCHAR*  value = NULL;

	r= GetEnvironmentVariable( Name, NULL, 0 );
	if ( r == 0 ) {
		*out_Value = NULL;
		return  0;  // 環境変数が定義されていないときでも、エラーにしない
	}

	value = (TCHAR*) malloc( r * sizeof(TCHAR) );
	IF( value == NULL ) goto err_fm;
	GetEnvironmentVariable( Name, value, r );

	*out_Value = value;
	if ( out_ValueLen != NULL )  *out_ValueLen = r - 1;

	e=0;
fin:
	return  e;

err_fm:  e = E_FEW_MEMORY;  goto fin;
}


 
/*=================================================================*/
/* <<< [Parse2/Parse2.c] >>> */ 
/*=================================================================*/
 
/***********************************************************************
  <<< [g_NaturalDocsKeywords] >>> 
************************************************************************/
TCHAR*  g_NaturalDocsKeywords[] = {

	/*===========================================================*/
	/* General Topics */
	/* Generic */
	_T("topic"), _T("topics"), _T("about"), _T("list"),

	/* Section (Ends Scope) */
	_T("section"), _T("title"),

	/* Group */
	_T("group"),

	/* File (Always Global) */
	_T("file"), _T("files"), _T("program"), _T("programs"), _T("script"), _T("scripts"),
	_T("document"), _T("documents"), _T("doc"), _T("docs"), _T("header"), _T("headers"),

	/*===========================================================*/
	/* Code Topics */
	/* Class (Starts Scope) */
	_T("class"), _T("classes"), _T("structure"), _T("structures"), _T("struct"), _T("structs"),
	_T("package"), _T("packages"), _T("namespace"), _T("namespaces"),

	/* Interface (Starts Scope) */
	_T("interface"), _T("interfaces"),

	/* Type */
	_T("type"), _T("types"), _T("typedef"), _T("typedefs"),

	/* Constant */
	_T("constant"), _T("constants"), _T("const"), _T("consts"),

	/* Enumeration (Topic indexed under Types Members indexed under Constants) */
	_T("enumeration"), _T("enumerations"), _T("enum"), _T("enums"),

	/* Function (List topics break apart) */
	_T("function"), _T("functions"), _T("func"), _T("funcs"),
	_T("procedure"), _T("procedures"), _T("proc"), _T("procs"),
	_T("routine"), _T("routines"), _T("subroutine"), _T("subroutines"),
	_T("sub"), _T("subs"), _T("method"), _T("methods"),
	_T("callback"), _T("callbacks"), _T("constructor"), _T("constructors"),
	_T("destructor"), _T("destructors"), _T("operator"), _T("operators"),

	/* Property */
	_T("property"), _T("properties"), _T("prop"), _T("props"),

	/* Event */
	_T("event"), _T("events"),

	/* Delegate */
	_T("delegate"), _T("delegates"),

	/* Macro */
	_T("macro"), _T("macros"),
	_T("define"), _T("defines"), _T("def"), _T("defs"),

	/* Variable */
	_T("variable"), _T("variables"), _T("var"), _T("vars"),
	_T("integer"), _T("integers"), _T("int"), _T("ints"),
	_T("uint"), _T("uints"), _T("long"), _T("longs"),
	_T("ulong"), _T("ulongs"), _T("short"), _T("shorts"),
	_T("ushort"), _T("ushorts"), _T("byte"), _T("bytes"),
	_T("ubyte"), _T("ubytes"), _T("sbyte"), _T("sbytes"),
	_T("float"), _T("floats"), _T("double"), _T("doubles"),
	_T("real"), _T("reals"), _T("decimal"), _T("decimals"),
	_T("scalar"), _T("scalars"), _T("array"), _T("arrays"),
	_T("arrayref"), _T("arrayrefs"), _T("hash"), _T("hashes"),
	_T("hashref"), _T("hashrefs"), _T("bool"), _T("bools"),
	_T("boolean"), _T("booleans"), _T("flag"), _T("flags"),
	_T("bit"), _T("bits"), _T("bitfield"), _T("bitfields"),
	_T("field"), _T("fields"), _T("pointer"), _T("pointers"),
	_T("ptr"), _T("ptrs"), _T("reference"), _T("references"),
	_T("ref"), _T("refs"), _T("object"), _T("objects"),
	_T("obj"), _T("objs"), _T("character"), _T("characters"),
	_T("wcharacter"), _T("wcharacters"), _T("char"), _T("chars"),
	_T("wchar"), _T("wchars"), _T("string"), _T("strings"),
	_T("wstring"), _T("wstrings"), _T("str"), _T("strs"),
	_T("wstr"), _T("wstrs"), _T("handle"), _T("handles"),

	/*===========================================================*/
	/* Database Topics */
	/* Database */
	_T("database"), _T("databases"), _T("db"), _T("dbs"),

	/* Database Table (Starts Scope) */
	_T("table"), _T("tables"),
	_T("database table"), _T("database tables"), _T("db table"), _T("db tables"),

	/* Database View (Starts Scope) */
	_T("view"), _T("views"),
	_T("database view"), _T("database views"), _T("db view"), _T("db views"),

	/* Database Cursor */
	_T("cursor"), _T("cursors"),
	_T("database cursor"), _T("database cursors"), _T("db cursor"), _T("db cursors"),

	/* Database Index */
	_T("index"), _T("indexes"), _T("indices"),
	_T("database index"), _T("database indexes"), _T("database indices"),
	_T("db index"), _T("db indexes"), _T("db indices"),
	_T("key"), _T("keys"),
	_T("database key"), _T("database keys"), _T("db key"), _T("db keys"),
	_T("primary key"), _T("primary keys"),
	_T("database primary key"), _T("database primary keys"),
	_T("db primary key"), _T("db primary keys"),

	/* Database Trigger */
	_T("trigger"), _T("triggers"),
	_T("database trigger"), _T("database triggers"), _T("db trigger"), _T("db triggers"),

	/*===========================================================*/
	/* Miscellaneous Topics */
	/* Cookie (Always global) */
	_T("cookie"), _T("cookies"),

	/* Build Target */
	_T("target"), _T("targets"),
	_T("build target"), _T("build targets"),
};


 
/***********************************************************************
  <<< [NaturalDocsHeaderClass_initConst] >>> 
************************************************************************/
void  NaturalDocsHeaderClass_initConst( NaturalDocsHeaderClass* self )
{
	self->Keyword = NULL;
	self->Name = NULL;
	self->Brief = NULL;
	Set2_initConst( &self->Arguments );
	self->ReturnValue = NULL;
	self->Descriptions = NULL;
	Set2_initConst( &self->DescriptionItems );
}


 
/***********************************************************************
  <<< [NaturalDocsHeaderClass_finalize] >>> 
************************************************************************/
errnum_t  NaturalDocsHeaderClass_finalize( NaturalDocsHeaderClass* self,  errnum_t e )
{
	Set2_IteratorClass            iterator;
	NaturalDocsDefinitionClass*   p1;
	NaturalDocsDescriptionClass*  p2;


	e= HeapMemory_free( &self->Keyword, e );
	e= HeapMemory_free( &self->Name, e );
	e= HeapMemory_free( &self->Brief, e );

	for ( Set2_forEach2( &self->Arguments, &iterator, &p1 ) ) {
		e= NaturalDocsDefinitionClass_finalize( p1, e );
	}
	e= Set2_finish( &self->Arguments, e );

	e= HeapMemory_free( &self->ReturnValue, e );
	e= HeapMemory_free( &self->Descriptions, e );

	for ( Set2_forEach2( &self->DescriptionItems, &iterator, &p2 ) ) {
		e= NaturalDocsDescriptionClass_finalize( p2, e );
	}
	e= Set2_finish( &self->DescriptionItems, e );

	return  e;
}


 
/***********************************************************************
  <<< [NaturalDocsDefinitionClass_initConst] >>> 
************************************************************************/
void  NaturalDocsDefinitionClass_initConst( NaturalDocsDefinitionClass* self )
{
	self->Name = NULL;
	self->Brief = NULL;
}


 
/***********************************************************************
  <<< [NaturalDocsDefinitionClass_finalize] >>> 
************************************************************************/
errnum_t  NaturalDocsDefinitionClass_finalize( NaturalDocsDefinitionClass* self,  errnum_t e )
{
	e= HeapMemory_free( &self->Name, e );
	e= HeapMemory_free( &self->Brief, e );
	return  e;
}


 
/***********************************************************************
  <<< [NaturalDocsDescriptionTypeEnum_to_String] >>> 
************************************************************************/

static const TCHAR*  gs_NaturalDocsDescriptionTypeEnum_to_String[ NaturalDocsDescriptionType_Count ] = {
	_T("Unknown"), _T("SubTitle"), _T("Paragraph"), _T("Code")
};
static_assert_global( NaturalDocsDescriptionType_Unknown   == 0, "" );
static_assert_global( NaturalDocsDescriptionType_SubTitle  == 1, "" );
static_assert_global( NaturalDocsDescriptionType_Paragraph == 2, "" );
static_assert_global( NaturalDocsDescriptionType_Code      == 3, "" );

const TCHAR*  NaturalDocsDescriptionTypeEnum_to_String( int in,  const TCHAR* in_OutOfRange )
{
	const TCHAR*  ret;

	if ( in >= NaturalDocsDescriptionType_Unknown  &&  in < NaturalDocsDescriptionType_Count )
		{ ret = gs_NaturalDocsDescriptionTypeEnum_to_String[ in - NaturalDocsDescriptionType_Unknown ]; }
	else
		{ ret = in_OutOfRange; }

	return  ret;
}


 
/***********************************************************************
  <<< [NaturalDocsDescriptionClass_initConst] >>> 
************************************************************************/
void  NaturalDocsDescriptionClass_initConst( NaturalDocsDescriptionClass* self )
{
	self->Type  = NaturalDocsDescriptionType_Unknown;
	self->Start = NULL;
	self->Over  = NULL;
	self->u.Unknown = NULL;
}


 
/***********************************************************************
  <<< [NaturalDocsDescriptionClass_finalize] >>> 
************************************************************************/
errnum_t  NaturalDocsDescriptionClass_finalize( NaturalDocsDescriptionClass* self,  errnum_t e )
{
	if ( self->Type == NaturalDocsDescriptionType_DefinitionList ) {
		if ( self->u.Definition != NULL )
			{ e= NaturalDocsDefinitionClass_finalize( self->u.Definition, e ); }
		e= HeapMemory_free( &self->u.Definition, e );
	}
	self->Type = NaturalDocsDescriptionType_Unknown;

	return  e;
}


 
/***********************************************************************
  <<< [ParseNaturalDocsComment] >>> 
- HeapMemory_free( out_NaturalDocsHeader );
************************************************************************/

void  ParseNaturalDocsLine( const TCHAR*  in_SourceStart,  const TCHAR*  in_SourceOver,
	const TCHAR**  out_LineStart,  const TCHAR**  out_LineOver );
void  ParseNaturalDocsDefinitionList( const TCHAR*  in_SourceStart,  const TCHAR*  in_SourceOver,
	const TCHAR**  out_NameStart,   const TCHAR**  out_NameOver,
	const TCHAR**  out_BriefStart,  const TCHAR**  out_BriefOver,  bool  in_IsSkipFirstLine );


errnum_t  ParseNaturalDocsComment( const TCHAR* in_SourceStart, const TCHAR* in_SourceOver,
	NaturalDocsHeaderClass** out_NaturalDocsHeader,  NaturalDocsParserConfigClass* config )
{
	errnum_t      e;
	const TCHAR*  p;
	const TCHAR*  p_over;
	int           step_num;
	bool          is_found = false;
	const TCHAR*  descriptions = NULL;

	NaturalDocsHeaderClass*       header = NULL;
	NaturalDocsDefinitionClass*   definition_a = NULL;  /* a = for Argument */
	NaturalDocsDefinitionClass*   definition_p = NULL;  /* p = for in Paragraph */
	NaturalDocsDescriptionClass*  description = NULL;

	e= HeapMemory_allocate( &header );  IF(e){goto fin;}
	NaturalDocsHeaderClass_initConst( header );
	e= Set2_init( &header->Arguments, 0x10 );  IF(e){goto fin;}
	e= Set2_init( &header->DescriptionItems, 0x40 );  IF(e){goto fin;}


	/* Parse keyword */
	step_num = 0;
	for ( p = in_SourceStart;  p < in_SourceOver;  p += 1 ) {
		if ( ! StrT_isCIdentifier( *p ) ) { continue; }

		if ( step_num == 0 ) {
			p_over = StrT_searchOverOfIdiom( p );

			if ( *p_over != _T(':') ) {
				break;  /* This comment is not parsed */
			}
			if ( StrT_searchPartStringIndexI( p,  p_over,
				g_NaturalDocsKeywords, _countof(g_NaturalDocsKeywords),
				NOT_FOUND_INDEX )
				== NOT_FOUND_INDEX )
			{
				if ( StrT_searchPartStringIndexI( p,  p_over,
					config->AdditionalKeywords, config->AdditionalKeywordsLength,
					NOT_FOUND_INDEX )
					== NOT_FOUND_INDEX )
				{
					break;  /* This comment is not parsed */
				}
			}

			e= MallocAndCopyStringByLength( &header->Keyword,  p,  p_over - p );
				IF(e){goto fin;}
			header->KeywordStart = p;
			header->KeywordOver = p_over;
			p = p_over;
		}
		else if ( step_num == 1 ) {
			TCHAR*  name = NULL;

			p_over = StrT_chrs( p, _T("\r\n") );
			ASSERT_R( p_over != NULL,  e=E_OTHERS; goto fin );
			if ( p_over >= p + 2 ) {
				if ( p_over[-2] == _T('*')  &&  p_over[-1] == _T('/') )
					{ p_over -= 2; }
			}
			p_over = StrT_rskip( p, p_over - 1, _T(" \t"), NULL );
			ASSERT_R( p_over != NULL,  e=E_OTHERS; goto fin );
			p_over += 1;

			e= MallocAndCopyStringByLength( &name,  p,  p_over - p );
				IF(e){goto fin;}
			e= StrT_trim( name,  sizeof(TCHAR) * ( _tcslen( name ) + 1 ),  name );
				IF(e){goto fin;}
			header->Name = name;
			header->NameStart = p;
			header->NameOver = p_over;
			is_found = true;
			break;
		}
		step_num += 1;
	}

	if ( header->Keyword != NULL  &&  header->Name == NULL ) {
		e= MallocAndCopyString( &header->Name, _T("") );
			IF(e){goto fin;}
		is_found = true;
	}


	/* Parse 2nd line */
	ParseNaturalDocsLine( p,  in_SourceOver,  &p,  &p_over );
	if ( p_over >= in_SourceOver ) {
		p = in_SourceOver;
	}
	else if ( p == NULL ) {
		p = p_over;
		descriptions = p_over;
	}
	else {
		e= MallocAndCopyStringByLength( &header->Brief,  p,  p_over - p );
			IF(e){goto fin;}
		header->BriefStart = p;
		header->BriefOver = p_over;

		p = StrT_rskip( in_SourceStart,  p - 1,  _T(" \t"), NULL );
			IF ( p == NULL ) { e=E_OTHERS; goto fin; }
		header->BriefNoIndent = p + 2;

		p = p_over;

		descriptions = p;
	}


	/* ... */
	for ( /* p */;  p < in_SourceOver;  p += 1 ) {
		if ( ! StrT_isCIdentifier( *p ) ) { continue; }

		p_over = StrT_searchOverOfIdiom( p );

		if ( *p_over != _T(':') ) { continue; }

		/* Parse Argument Label */
		if ( StrT_cmp_i_part( p,  p_over, _T("Arguments") ) == 0 ) {
			const TCHAR*  p1;
			const TCHAR*  p1_over;
			const TCHAR*  p2;
			const TCHAR*  p2_over;

			header->ArgumentsLabel = p;

			for (;;) {
				ParseNaturalDocsDefinitionList( p,  in_SourceOver,
					&p1,  &p1_over,  &p2,  &p2_over,  true );
				if ( p2 == NULL )
					{ break; }

				e= Set2_allocate( &header->Arguments, &definition_a );
					IF(e){goto fin;}
				NaturalDocsDefinitionClass_initConst( definition_a );

				e= MallocAndCopyStringByLength( &definition_a->Name,  p1,  p1_over - p1 );
					IF(e){goto fin;}
				definition_a->NameStart = p1;
				definition_a->NameOver = p1_over;

				e= MallocAndCopyStringByLength( &definition_a->Brief,  p2,  p2_over - p2 );
					IF(e){goto fin;}
				definition_a->BriefStart = p2;
				definition_a->BriefOver = p2_over;

				definition_a = NULL;

				descriptions = p2_over;

				p = p2_over;
			}
		}

		/* Parse Return Value Label */
		else if ( StrT_cmp_i_part( p,  p_over, _T("Return Value") ) == 0 ) {

			header->ReturnValueLabel = p;

			ParseNaturalDocsLine( p,  in_SourceOver,  &p,  &p_over );
			if ( p == NULL ) {
				p = in_SourceOver;
				ASSERT_D( p_over != NULL, __noop() );
			}
			else {
				e= MallocAndCopyStringByLength( &header->ReturnValue,  p,  p_over - p );
					IF(e){goto fin;}
				header->ReturnValueStart = p;
				header->ReturnValueOver = p_over;

				p = p_over;
			}
			descriptions = p_over;
		}
	}


	/* Set "header->Descriptions" */
	if ( descriptions != NULL ) {
		const TCHAR*  descriptions_over;

		descriptions_over = StrT_rstr( in_SourceStart,  in_SourceOver,  _T("\n"),  NULL );
		if ( descriptions_over != NULL ) {
			const TCHAR*  over2 = StrT_rstr( in_SourceStart,  descriptions_over - 1,  _T("\n"),  NULL );
			const TCHAR*  p2;

			/* If last line was only "*******" Then "descriptions_over = over2". */
			if ( over2 != NULL ) {
				p2 = StrT_skip( over2 + 1, _T("* /\t") );
					IF ( p2 == NULL ) { e=E_OTHERS; goto fin; }
				if ( p2 >= descriptions_over ) {
					descriptions_over = over2;
				}
			}
		}
		if ( descriptions_over != NULL ) {
			const TCHAR*  p2;

			if ( *( descriptions_over - 1 ) == _T('\r') )
				{ descriptions_over -= 1; }

			/* Set "descriptions_over" to before end of comment */
			p2 = StrT_rskip( descriptions,  descriptions_over - 1,  _T(" \t"),  NULL );
			if ( p2 != NULL ) {
				if ( *p2 == _T('/')  &&  *( p2 - 1 ) == _T('*') ) {
					p2 = StrT_rskip( descriptions,  p2 - 2,  _T(" \t"),  NULL );
					if ( p2 == NULL ) {
						descriptions_over = descriptions;
					} else {
						descriptions_over = p2 + 1;
					}
				}
			}

			/* Set "header" */
			header->DescriptionsStart = descriptions;
			header->DescriptionsOver = descriptions_over;
			e= MallocAndCopyStringByLength( &header->Descriptions,
				descriptions,  descriptions_over - descriptions );
				IF(e){goto fin;}
		}
	}


	/* Set "header->DescriptionItems" */
	if ( descriptions != NULL  &&  header->DescriptionsOver != NULL ) {
		const TCHAR*  line;
		const TCHAR*  p_last;
		const TCHAR*  p_line_feed;
		const TCHAR*  descriptions_over = header->DescriptionsOver;
		bool          is_definition_list;

		for (
			line = _tcschr( descriptions, _T('\n') ) + 1;
			line < descriptions_over;
			line = p_line_feed + 1 )
		{
			p_line_feed = _tcschr( line, _T('\n') );


			/* Set "p" : Skip space or "*" */
			for ( p = line;  p < p_line_feed;  p += 1 ) {
				TCHAR  a_char = *p;

				if ( a_char == ' '  ||  a_char == '\t'  ||  a_char == '*' )
					{ continue; }
				else
					{ break; }
			}

			/* Set "p_last" */
			for ( p_last = p_line_feed - 1;  p_last > p;  p_last -= 1 ) {
				TCHAR  a_char = *p_last;

				if ( a_char == ' '  ||  a_char == '\t'  ||  a_char == '\n' )
					{ continue; }
				else
					{ break; }
			}


			/* Set "is_definition_list", "definition_p" */
			{
				const TCHAR*  p1;
				const TCHAR*  p1_over;
				const TCHAR*  p2;
				const TCHAR*  p2_over;

				is_definition_list = false;
				p1 = _tcschr( p, _T('-') );
				p2 = _tcschr( p, _T('\n') );


				if ( p1 != NULL  &&  p1 < p2 ) {

					for ( p1_over = p2 - 1;  p1_over > p1;  p1_over -= 1 ) {
						if ( ! _istspace( *p1_over ) )
							{ break;}
					}
					if ( p1_over == p1 ) {
						p1 = NULL;  /* For next if */
						p2_over = NULL;  /* For warning C4701 */
					} else {
						ParseNaturalDocsDefinitionList( p,  in_SourceOver,
							&p1,  &p1_over,  &p2,  &p2_over,  false );
					}
					if ( p1 != NULL  &&  p2 != NULL ) {
						e= HeapMemory_allocate( &definition_p ); IF(e){goto fin;}
						NaturalDocsDefinitionClass_initConst( definition_p );

						e= MallocAndCopyStringByLength( &definition_p->Name,
							p1,  p1_over - p1 );
							IF(e){goto fin;}
						definition_p->NameStart = p1;
						definition_p->NameOver = p1_over;

						e= MallocAndCopyStringByLength( &definition_p->Brief,
							p2,  p2_over - p2 );
							IF(e){goto fin;}
						definition_p->BriefStart = p2;
						definition_p->BriefOver = p2_over;
						is_definition_list = true;
					}
				}
			}


			/* End of Paragraph */
			if ( description != NULL  &&
					description->Type == NaturalDocsDescriptionType_Paragraph  &&
					p == p_last )
			{
				description = NULL;
			}

			/* End of Code */
			if ( description != NULL  &&
					description->Type == NaturalDocsDescriptionType_Code  &&
					*p != _T('>') )
			{
				description = NULL;
			}


			/* Add Code */
			if ( *p == _T('>') ) {
				if ( description == NULL  ||
					description->Type != NaturalDocsDescriptionType_Code )
				{
					e= Set2_allocate( &header->DescriptionItems, &description );
						IF(e){goto fin;}
					NaturalDocsDescriptionClass_initConst( description );

					description->Type = NaturalDocsDescriptionType_Code;
					description->Start = line;
				}
				description->Over = p_line_feed + 1;
			}

			/* Add SubTitle */
			else if ( *p_last == _T(':') ) {
				e= Set2_allocate( &header->DescriptionItems, &description );
					IF(e){goto fin;}
				NaturalDocsDescriptionClass_initConst( description );

				description->Type = NaturalDocsDescriptionType_SubTitle;
				description->Start = p;
				description->Over  = p_last;

				description = NULL;
			}

			/* Add DefinitionList */
			else if ( is_definition_list ) {
				e= Set2_allocate( &header->DescriptionItems, &description );
					IF(e){goto fin;}
				NaturalDocsDescriptionClass_initConst( description );

				description->Type = NaturalDocsDescriptionType_DefinitionList;
				description->Start = line;
				description->Over = p_line_feed + 1;
				description->u.Definition = definition_p;

				description = NULL;
				definition_p = NULL;
			}

			/* Add Paragraph */
			else {
				bool  is_exist_content = false;

				if ( description == NULL  ||
					description->Type != NaturalDocsDescriptionType_Paragraph )
				{
					const TCHAR*  p;

					for ( p = line;  p < p_line_feed;  p += 1 ) {
						switch ( *p ) {
							case ' ':  case '\t':  case '*':
								break;
							default:
								is_exist_content = true;
								goto  exit_for_1;
						}
					}
exit_for_1:;
				}
				if ( is_exist_content ) {

					e= Set2_allocate( &header->DescriptionItems, &description );
						IF(e){goto fin;}
					NaturalDocsDescriptionClass_initConst( description );

					description->Type = NaturalDocsDescriptionType_Paragraph;
					description->Start = line;
				}
				if ( description != NULL ) {
					description->Over = p_line_feed + 1;
				}
			}


			/* Delete not used data */
			e=0;
			if ( definition_p != NULL )
				{ e= NaturalDocsDefinitionClass_finalize( definition_p, e ); }
			e= HeapMemory_free( &definition_p, e );
			IF(e){goto fin;}
		}
	}


	*out_NaturalDocsHeader = header;
	header = NULL;

	e=0;
fin:
	if ( header != NULL ) {
		e= Set2_free( &header->Arguments, &definition_a, e );
		if ( definition_p != NULL )
			{ e= NaturalDocsDefinitionClass_finalize( definition_p, e ); }
		e= HeapMemory_free( &definition_p, e );
		e= Set2_free( &header->DescriptionItems, &description, e );
	}
	if ( ! is_found  ||  e != 0 ) {
		if ( header == NULL )
			{ header = *out_NaturalDocsHeader; }
		e= NaturalDocsHeaderClass_finalize( header, e );
		e= HeapMemory_free( &header, e );
		*out_NaturalDocsHeader = NULL;
	}
	return  e;
}


 
/***********************************************************************
  <<< [ParseNaturalDocsLine] >>> 
************************************************************************/
void  ParseNaturalDocsLine( const TCHAR*  in_SourceStart,  const TCHAR*  in_SourceOver,
	const TCHAR**  out_LineStart,  const TCHAR**  out_LineOver )
{
	const TCHAR*  p;
	const TCHAR*  p_over;  /* position of over */
	TCHAR         a_char;  /* char = charcter */


	*out_LineStart = NULL;
	*out_LineOver  = NULL;


	/* Move to next line */
	for ( p = in_SourceStart;  p < in_SourceOver;  p += 1 ) {
		if ( *p == '\n' ) {
			p += 1;
			break;
		}
	}

	/* Skip space or "*" */
	for ( /* p */ ;  p < in_SourceOver;  p += 1 ) {
		a_char = *p;

		if ( a_char == ' '  ||  a_char == '\t'  ||  a_char == '*' )
			{ continue; }
		else
			{ break; }
	}

	/* Move to right of line */
	for ( p_over = p;  p_over < in_SourceOver;  p_over += 1 ) {
		a_char = *p_over;

		if ( a_char == '\n' ) {
			for ( p_over -= 1;  /* p_over >= p */;  p_over -= 1 ) {
				if ( p_over <= p ) {
					p_over = p;
					break;
				}

				a_char = *p_over;

				if ( a_char == ' '  ||  a_char == '\t' ) {
					continue;
				} else {
					p_over += 1;
					break;
				}
			}

			if ( p != p_over ) {
				*out_LineStart = p;
			}
			break;
		}
	}
	*out_LineOver = p_over;

	if ( p_over > p + 2  &&  *( p_over - 2 ) == _T('*')  &&  *( p_over - 1 ) == _T('/')  &&  *out_LineStart == NULL ) {
		for ( p_over -= 3;  p_over > p;  p_over -= 1 ) {
			a_char = *p_over;

			if ( a_char == ' '  ||  a_char == '\t' )
				{ continue; }
			else
				{ break; }
		}
		
		*out_LineStart = p;
		*out_LineOver = p_over + 1;
	}
}


 
/***********************************************************************
  <<< [ParseNaturalDocsDefinitionList] >>> 
************************************************************************/
void  ParseNaturalDocsDefinitionList( const TCHAR*  in_SourceStart,  const TCHAR*  in_SourceOver,
	const TCHAR**  out_NameStart,   const TCHAR**  out_NameOver,
	const TCHAR**  out_BriefStart,  const TCHAR**  out_BriefOver,  bool  in_IsSkipFirstLine )
{
	const TCHAR*  p;
	const TCHAR*  p_over;
	TCHAR         a_char;  /* char = charcter */


	*out_NameStart = NULL;
	*out_BriefStart = NULL;

	if ( in_IsSkipFirstLine ) {
		for ( p = in_SourceStart;  p < in_SourceOver;  p += 1 ) {
			if ( *p == '\n' ) {
				p += 1;
				break;
			}
		}
	}
	else {
		p = in_SourceStart;
	}

	for ( /* p */ ;  p < in_SourceOver;  p += 1 ) {
		a_char = *p;

		if ( a_char == ' '  ||  a_char == '\t'  ||  a_char == '*' )
			{ continue; }
		else
			{ break; }
	}
	for ( p_over = p;  p_over < in_SourceOver;  p_over += 1 ) {
		a_char = *p_over;

		if ( a_char == '-' ) {
			if ( p_over == p ) {
				break;  /* Not definition list but normal list */
			}
			else {
				const TCHAR*  p2_over;

				for ( p2_over = p_over - 1;  /* p2_over >= p */;  p2_over -= 1 ) {
					a_char = *p2_over;
					if ( a_char == ' '  ||  a_char == '\t' ) {
						continue;
					} else {
						p2_over += 1;
						break;
					}
				}

				*out_NameStart = p;
				*out_NameOver = p2_over;
			}
			break;
		}
		else if ( a_char == '\n' ) {
			goto fin;
		}
	}
	for ( p = p_over + 1;  p < in_SourceOver;  p += 1 ) {
		a_char = *p;

		if ( a_char == ' '  ||  a_char == '\t'  ||  a_char == '*' )
			{ continue; }
		else
			{ break; }
	}
	for ( p_over = p;  p_over < in_SourceOver;  p_over += 1 ) {
		a_char = *p_over;

		if ( a_char == '\n' ) {
			for ( p_over -= 1;  /* p_over >= p */;  p_over -= 1 ) {
				a_char = *p_over;
				if ( a_char == ' '  ||  a_char == '\t' ) {
					continue;
				} else {
					p_over += 1;
					break;
				}
			}

			*out_BriefStart = p;
			*out_BriefOver = p_over;
			break;
		}
	}

fin:
	return;
}


 
/***********************************************************************
  <<< (NaturalCommentClass) >>> 
************************************************************************/

static const FinalizerVTableClass  gs_NaturalCommentClass_FinalizerVTable = {
	offsetof( NaturalCommentClass, FinalizerVTable ),
	NaturalCommentClass_finalize,
};
static const PrintXML_VTableClass  gs_NaturalCommentClass_PrintXML_VTable = {
	offsetof( NaturalCommentClass, PrintXML_VTable ),
	NaturalCommentClass_printXML,
};
static const InterfaceToVTableClass  gs_NaturalCommentClass_InterfaceToVTables[] = {
	{ &g_FinalizerInterface_ID, &gs_NaturalCommentClass_FinalizerVTable },
	{ &g_PrintXML_Interface_ID, &gs_NaturalCommentClass_PrintXML_VTable },
};
static const ClassID_Class*  gs_NaturalCommentClass_SuperClassIDs[] = {
	&g_ClassID_SuperClass_ID, &g_ParsedRangeClass_ID, &g_SyntaxSubNodeClass_ID,
	&g_SyntaxNodeClass_ID, &g_NaturalCommentClass_ID,
};

/*[g_NaturalCommentClass_ID]*/
const ClassID_Class  g_NaturalCommentClass_ID = {
	"NaturalCommentClass",
	gs_NaturalCommentClass_SuperClassIDs,
	_countof( gs_NaturalCommentClass_SuperClassIDs ),
	sizeof( NaturalCommentClass ),
	NULL,
	gs_NaturalCommentClass_InterfaceToVTables,
	_countof( gs_NaturalCommentClass_InterfaceToVTables ),
};


 
/***********************************************************************
  <<< [NaturalCommentClass_initConst] >>> 
************************************************************************/
void  NaturalCommentClass_initConst( NaturalCommentClass* self )
{
	SyntaxNodeClass_initConst( (SyntaxNodeClass*) self );
	self->ClassID = &g_NaturalCommentClass_ID;
	self->FinalizerVTable = &gs_NaturalCommentClass_FinalizerVTable;
	self->PrintXML_VTable = &gs_NaturalCommentClass_PrintXML_VTable;
	self->NaturalDocsHeader = NULL;
}


 
/***********************************************************************
  <<< [NaturalCommentClass_finalize] >>> 
************************************************************************/
errnum_t  NaturalCommentClass_finalize( NaturalCommentClass* self, errnum_t e )
{
	if ( self->NaturalDocsHeader != NULL ) {
		e= NaturalDocsHeaderClass_finalize( self->NaturalDocsHeader, e );
		e= HeapMemory_free( &self->NaturalDocsHeader, e );
	}
	return  e;
}


 
/***********************************************************************
  <<< [NaturalCommentClass_printXML] >>> 
************************************************************************/
errnum_t  NaturalCommentClass_printXML( NaturalCommentClass* self, FILE* OutputStream )
{
	errnum_t     e;
	int          r;
	Set2_IteratorClass           iterator;
	NaturalDocsHeaderClass*      header;
	NaturalDocsDefinitionClass*  definition;
	NaturalDocsDescriptionClass* description;


	r= _ftprintf_s( OutputStream, _T("<NaturalCommentClass") );
		IF ( r < 0 ) { e=E_ACCESS_DENIED; goto fin; }

	header = self->NaturalDocsHeader;
	if ( header != NULL ) {
		r= _ftprintf_s( OutputStream, _T("  NaturalDocsKeyword=\"%s\""), header->Keyword );
			IF ( r < 0 ) { e=E_ACCESS_DENIED; goto fin; }

		ASSERT_D( StrT_cmp_part( header->KeywordStart,  header->KeywordOver,  header->Keyword ) == 0,
			e=E_OTHERS; goto fin );


		r= _ftprintf_s( OutputStream, _T("  Name=\"%s\""), header->Name );
			IF ( r < 0 ) { e=E_ACCESS_DENIED; goto fin; }

		ASSERT_D( StrT_cmp_part( header->NameStart,  header->NameOver,  header->Name ) == 0,
			e=E_OTHERS; goto fin );
	}
	r= _ftprintf_s( OutputStream, _T("  StartLineNum=\"%d\""), self->StartLineNum );
		IF ( r < 0 ) { e=E_ACCESS_DENIED; goto fin; }

	r= _ftprintf_s( OutputStream, _T("  LastLineNum=\"%d\""), self->LastLineNum );
		IF ( r < 0 ) { e=E_ACCESS_DENIED; goto fin; }

	if ( self->ParentComment != NULL ) {
		r= _ftprintf_s( OutputStream, _T("  ParentComment=\"%s\""), self->ParentComment->NaturalDocsHeader->Name );
			IF ( r < 0 ) { e=E_ACCESS_DENIED; goto fin; }
	}
	r= _ftprintf_s( OutputStream, _T(">\n") );
		IF ( r < 0 ) { e=E_ACCESS_DENIED; goto fin; }


	if ( header != NULL ) {
		if ( header->Brief != NULL ) {
			r= _ftprintf_s( OutputStream, _T("\t<Brief><![CDATA[%s]]></Brief>\n"), header->Brief );
				IF ( r < 0 ) { e=E_ACCESS_DENIED; goto fin; }

			ASSERT_D( StrT_cmp_part( header->BriefStart,  header->BriefOver,  header->Brief ) == 0,
				e=E_OTHERS; goto fin );
			ASSERT_D( header->BriefNoIndent > header->NameOver  &&
				header->BriefNoIndent < header->BriefStart,
				e=E_OTHERS; goto fin );
		}

		if ( header->Arguments.First < header->Arguments.Next ) {
			ASSERT_D( StrT_cmp_part( header->ArgumentsLabel,  header->ArgumentsLabel + 10,
				_T("Arguments:") ) == 0,  e=E_OTHERS; goto fin );
		}
		for ( Set2_forEach2( &header->Arguments, &iterator, &definition ) ) {
			r= _ftprintf_s( OutputStream, _T("\t<Arguments  Name=\"%s\"><![CDATA[%s]]></Arguments>\n"),
				definition->Name,  definition->Brief );
				IF ( r < 0 ) { e=E_ACCESS_DENIED; goto fin; }

			ASSERT_D( StrT_cmp_part( definition->NameStart,  definition->NameOver,  definition->Name )
				== 0,  e=E_OTHERS; goto fin );
			ASSERT_D( StrT_cmp_part( definition->BriefStart,  definition->BriefOver,  definition->Brief )
				== 0,  e=E_OTHERS; goto fin );
		}

		if ( header->ReturnValue != NULL ) {
			r= _ftprintf_s( OutputStream, _T("\t<ReturnValue><![CDATA[%s]]></ReturnValue>\n"), header->ReturnValue );
				IF ( r < 0 ) { e=E_ACCESS_DENIED; goto fin; }

			ASSERT_D( StrT_cmp_part( header->ReturnValueStart,  header->ReturnValueOver,
				header->ReturnValue ) == 0,  e=E_OTHERS; goto fin );
			ASSERT_D( StrT_cmp_part( header->ReturnValueLabel,  header->ReturnValueLabel + 13,
				_T("Return Value:") ) == 0,  e=E_OTHERS; goto fin );
		}

		if ( ! Set2_isEmpty( &header->DescriptionItems ) ) {
			r= _ftprintf_s( OutputStream, _T("\t<DescriptionItems>\n") );
				IF ( r < 0 ) { e=E_ACCESS_DENIED; goto fin; }
		}
		for ( Set2_forEach2( &header->DescriptionItems, &iterator, &description ) ) {
			r= _ftprintf_s( OutputStream, _T("\t\t<DescriptionItem  type=\"%s\"><![CDATA["),
				NaturalDocsDescriptionTypeEnum_to_String( description->Type, _T("UNKNOWN") ) );
				IF ( r < 0 ) { e=E_ACCESS_DENIED; goto fin; }
			e= ftcopy_part_r( OutputStream, description->Start, description->Over );
			r= _ftprintf_s( OutputStream, _T("]]></DescriptionItem>\n") );
				IF ( r < 0 ) { e=E_ACCESS_DENIED; goto fin; }
		}
		if ( ! Set2_isEmpty( &header->DescriptionItems ) ) {
			r= _ftprintf_s( OutputStream, _T("\t</DescriptionItems>\n") );
				IF ( r < 0 ) { e=E_ACCESS_DENIED; goto fin; }
		}
	}


	r= _ftprintf_s( OutputStream, _T("</NaturalCommentClass>\n") );
		IF ( r < 0 ) { e=E_ACCESS_DENIED; goto fin; }

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [MakeNaturalComments_C_Language] >>> 
************************************************************************/

errnum_t  MakeNaturalComments_C_Language__Sub( C_LanguageTokenClass* StartToken,
	LineNumberIndexClass*  LineNumbers,
	NaturalCommentClass** out_NewComment,
	NaturalDocsParserConfigClass* config );

errnum_t  MakeNaturalComments_C_Language( ListClass* /*<C_LanguageTokenClass*>*/ TokenList,
	LineNumberIndexClass*  LineNumbers,
	ListClass* /*<NaturalCommentClass*>*/ TopSyntaxNodeList,
	NaturalDocsParserConfigClass* config )
{
	errnum_t                      e;
	const ClassID_Class*          class_ID;
	ListIteratorClass             iterator;
	C_LanguageTokenClass*         token;
	NaturalCommentClass*          comment;
	NaturalCommentClass*          new_comment;
	NaturalDocsParserConfigClass  config_body;


	if ( config == NULL ) {
		config = &config_body;
		config->Flags = 0;
	}

	if ( IsBitNotSet( config->Flags, NaturalDocsParserConfig_AdditionalKeywords ) ) {
		config->AdditionalKeywords       = NULL;
		config->AdditionalKeywordsLength = 0;
	}
	else {
		ASSERT_R( IsBitSet( config->Flags, NaturalDocsParserConfig_AdditionalKeywordsLength ),
			e=E_OTHERS; goto fin );
	}

	if ( IsBitSet( config->Flags, NaturalDocsParserConfig_AdditionalKeywordsEndsScopesFirstIndex ) ) {
		if ( IsBitNotSet( config->Flags, NaturalDocsParserConfig_AdditionalKeywordsEndsScopesLength ) ) {
			config->AdditionalKeywordsEndsScopesLength = 1;
		}
	}
	else {
		config->AdditionalKeywordsEndsScopesFirstIndex = 0;
		config->AdditionalKeywordsEndsScopesLength = 0;
	}


	for ( ListClass_forEach( TokenList, &iterator, &token ) ) {
		class_ID = token->ClassID;
		if ( class_ID == &g_C_LanguageTokenClass_ID ) {
			C_LanguageTokenEnum    token_type = token->TokenType;

			if ( token_type == TwoChar8( '/', '*' ) ) {
				e= MakeNaturalComments_C_Language__Sub( token, LineNumbers, &new_comment, config );
					IF(e){goto fin;}
				if ( new_comment != NULL ) {
					e= ListClass_addLast( TopSyntaxNodeList, &new_comment->ListElement );
						IF(e){goto fin;}
				}
			}
		}
	}

	/* Set "comment->ParentComment" */
	{
		enum {
			starts_scope_start = 19,
			starts_scope_end   = 30,
			ends_scope_start   = 4, 
			ends_scope_end     = 5,
		};

		NaturalCommentClass*  parent = NULL;


		ASSERT_D( _tcscmp( g_NaturalDocsKeywords[ starts_scope_start ], _T("class")      ) == 0,  e=E_OTHERS; goto fin );
		ASSERT_D( _tcscmp( g_NaturalDocsKeywords[ starts_scope_end ],   _T("interfaces") ) == 0,  e=E_OTHERS; goto fin );
		ASSERT_D( _tcscmp( g_NaturalDocsKeywords[ ends_scope_start ],   _T("section")    ) == 0,  e=E_OTHERS; goto fin );
		ASSERT_D( _tcscmp( g_NaturalDocsKeywords[ ends_scope_end ],     _T("title")      ) == 0,  e=E_OTHERS; goto fin );


		for ( ListClass_forEach( TopSyntaxNodeList, &iterator, &comment ) ) {
			NaturalDocsHeaderClass*  header = comment->NaturalDocsHeader;
			int  index;

			index = StrT_searchPartStringIndexI( header->KeywordStart,  header->KeywordOver,
				g_NaturalDocsKeywords, _countof(g_NaturalDocsKeywords),
				NOT_FOUND_INDEX );

			if ( index == NOT_FOUND_INDEX ) {
				index = StrT_searchPartStringIndexI( header->KeywordStart,  header->KeywordOver,
					config->AdditionalKeywords, config->AdditionalKeywordsLength,
					NOT_FOUND_INDEX );

				if ( index >= config->AdditionalKeywordsEndsScopesFirstIndex  &&
					index < config->AdditionalKeywordsEndsScopesFirstIndex +
					config->AdditionalKeywordsEndsScopesLength )
				{
					index = ends_scope_start;
				}
				else {
					index = NOT_FOUND_INDEX;
				}
			}

			if ( index >= starts_scope_start  &&  index <= starts_scope_end ) {
				parent = comment;
				comment->ParentComment = NULL;
			}
			else if ( index >= ends_scope_start  &&  index <= ends_scope_end ) {
				parent = NULL;
				comment->ParentComment = NULL;
			}
			else {
				comment->ParentComment = parent;
			}
		}
	}

	e=0;
fin:
	return  e;
}


errnum_t  MakeNaturalComments_C_Language__Sub( C_LanguageTokenClass* StartToken,
	LineNumberIndexClass*  LineNumbers,
	NaturalCommentClass** out_NewComment,
	NaturalDocsParserConfigClass* config )
{
	errnum_t                e;
	C_LanguageTokenClass*   token;
	NaturalCommentClass*    new_comment;
	int                     line_num;

	*out_NewComment = NULL;

	e= HeapMemory_allocate( &new_comment ); IF(e){goto fin;}
	NaturalCommentClass_initConst( new_comment );


	/* Set members of "new_comment" */
	new_comment->Start = StartToken->Start;
	e= LineNumberIndexClass_searchLineNumber( LineNumbers, new_comment->Start, &line_num );
		IF(e){goto fin;}
	new_comment->StartLineNum = line_num;


	token = StartToken;
	for (;;) {
		token = (C_LanguageTokenClass*) token->ListElement.Next->Data;
			IF ( token == NULL ) { e=E_OTHERS; goto fin; }
		if ( token->TokenType == TwoChar8( '*', '/' ) )
			{ break; }
	}

	new_comment->Over = token->Over;
	e= LineNumberIndexClass_searchLineNumber( LineNumbers, new_comment->Over - 1, &line_num );
		IF(e){goto fin;}
	new_comment->LastLineNum = line_num;


	/* ... */
	e= ParseNaturalDocsComment( new_comment->Start, new_comment->Over,
		&new_comment->NaturalDocsHeader, config ); IF(e){goto fin;}


	/* Set "*out_NewComment" */
	if ( new_comment->NaturalDocsHeader != NULL ) {
		*out_NewComment = new_comment;
		new_comment = NULL;
	}
	e=0;
fin:
	if ( new_comment != NULL ) {
		e= NaturalCommentClass_finalize( new_comment, e );
		HeapMemory_free( &new_comment, e );
	}

	return  e;
}


 
/***********************************************************************
  <<< [LexicalAnalize_C_Language] >>> 
************************************************************************/
errnum_t  LexicalAnalize_C_Language( const TCHAR*  in_Text,
	ListClass* /*<C_LanguageTokenClass>*/  in_TokenList )
{
	errnum_t      e;
	const TCHAR*  p;
	TCHAR         c;
	TCHAR         c2;
	int           next_plus;
	bool          is_in_c_comment = false;    /* Slash asterisk */
	bool          is_in_cpp_comment = false;  /* Double slash */

	C_LanguageTokenEnum     token_type;
	C_LanguageTokenClass*   token = NULL;


	p = in_Text;
	c = *p;
	while ( c != '\0' ) {
		next_plus = 1;

		if      ( c >= 'A'  &&  c <= 'Z' ) { token_type = gc_TokenOfCIdentifier; }
		else if ( c >= 'a'  &&  c <= 'z' ) { token_type = gc_TokenOfCIdentifier; }
		else if ( c == '_' )               { token_type = gc_TokenOfCIdentifier; }
		else if ( c >= '0'  &&  c <= '9' ) { token_type = gc_TokenOfNumber; }
		else if ( c == '=' ) {
			c2 = *( p + 1 );
			if      ( c2 == '=' ) { token_type = TwoChar8( '=', '=' );  next_plus = 2; }
			else                  { token_type = '='; }
		}
		else if ( c == '+' ) {
			c2 = *( p + 1 );
			if      ( c2 == '+' ) { token_type = TwoChar8( '+', '+' );  next_plus = 2; }
			else if ( c2 == '=' ) { token_type = TwoChar8( '+', '=' );  next_plus = 2; }
			else                  { token_type = '+'; }
		}
		else if ( c == '-' ) {
			c2 = *( p + 1 );
			if      ( c2 == '>' ) { token_type = TwoChar8( '-', '>' );  next_plus = 2; }
			else if ( c2 == '-' ) { token_type = TwoChar8( '-', '-' );  next_plus = 2; }
			else if ( c2 == '=' ) { token_type = TwoChar8( '-', '=' );  next_plus = 2; }
			else                  { token_type = '-'; }
		}
		else if ( c == '*' ) {
			c2 = *( p + 1 );
			if      ( c2 == '/' ) { token_type = TwoChar8( '*', '/' );  next_plus = 2; }
			else if ( c2 == '=' ) { token_type = TwoChar8( '*', '=' );  next_plus = 2; }
			else                  { token_type = '*'; }

			if ( c2 == '/' ) {
				if ( ! is_in_cpp_comment )
					{ is_in_c_comment = false; }
			}
		}
		else if ( c == '/' ) {
			c2 = *( p + 1 );
			if      ( c2 == '/' ) { token_type = TwoChar8( '/', '/' );  next_plus = 2; }
			else if ( c2 == '*' ) { token_type = TwoChar8( '/', '*' );  next_plus = 2; }
			else if ( c2 == '=' ) { token_type = TwoChar8( '/', '=' );  next_plus = 2; }
			else                  { token_type = '/'; }

			if ( ! is_in_c_comment  &&  ! is_in_cpp_comment ) {
				if ( c2 == '/' )
					{ is_in_cpp_comment = true; }
				else if ( c2 == '*' )
					{ is_in_c_comment = true; }
			}
		}
		else if ( c == '<' ) {
			c2 = *( p + 1 );
			if      ( c2 == '<' ) { token_type = TwoChar8( '<', '<' );  next_plus = 2; }
			else if ( c2 == '=' ) { token_type = TwoChar8( '<', '=' );  next_plus = 2; }
			else                  { token_type = '<'; }
		}
		else if ( c == '>' ) {
			c2 = *( p + 1 );
			if      ( c2 == '>' ) { token_type = TwoChar8( '>', '>' );  next_plus = 2; }
			else if ( c2 == '=' ) { token_type = TwoChar8( '>', '=' );  next_plus = 2; }
			else                  { token_type = '>'; }
		}
		else if ( c == '!' ) {
			c2 = *( p + 1 );
			if      ( c2 == '=' ) { token_type = TwoChar8( '!', '=' );  next_plus = 2; }
			else                  { token_type = '!'; }
		}
		else if ( c == '&' ) {
			c2 = *( p + 1 );
			if      ( c2 == '&' ) { token_type = TwoChar8( '&', '&' );  next_plus = 2; }
			else if ( c2 == '=' ) { token_type = TwoChar8( '&', '=' );  next_plus = 2; }
			else                  { token_type = '&'; }
		}
		else if ( c == '|' ) {
			c2 = *( p + 1 );
			if      ( c2 == '|' ) { token_type = TwoChar8( '|', '|' );  next_plus = 2; }
			else if ( c2 == '=' ) { token_type = TwoChar8( '|', '=' );  next_plus = 2; }
			else                  { token_type = '|'; }
		}
		else if ( c == '%' ) {
			c2 = *( p + 1 );
			if      ( c2 == '=' ) { token_type = TwoChar8( '%', '=' );  next_plus = 2; }
			else                  { token_type = '%'; }
		}
		else if ( c == '^' ) {
			c2 = *( p + 1 );
			if      ( c2 == '=' ) { token_type = TwoChar8( '^', '=' );  next_plus = 2; }
			else                  { token_type = '^'; }
		}
		else {
			switch ( c ) {
				case  '(':  token_type = c;  break;
				case  ')':  token_type = c;  break;
				case  '{':  token_type = c;  break;
				case  '}':  token_type = c;  break;
				case  '[':  token_type = c;  break;
				case  ']':  token_type = c;  break;
				case  '"':  token_type = gc_TokenOfString;  break;
				case  '\'': token_type = gc_TokenOfChar;  break;
				case  '.':  token_type = c;  break;
				case  ',':  token_type = c;  break;
				case  ':':  token_type = c;  break;
				case  ';':  token_type = c;  break;
				case  '\n': token_type = c;  is_in_cpp_comment = false;  break;
				case  '?':  token_type = c;  break;
				case  '~':  token_type = c;  break;
				default:    token_type = gc_TokenOfOther;  break;
			}
		}

		if ( token_type == gc_TokenOfCIdentifier ) {
			bool  is_in_identifier;

			for (;;) {
				c2 = *( p + next_plus );
				if      ( c2 >= 'A'  &&  c2 <= 'Z' ) { is_in_identifier = true; }
				else if ( c2 >= 'a'  &&  c2 <= 'z' ) { is_in_identifier = true; }
				else if ( c2 >= '0'  &&  c2 <= '9' ) { is_in_identifier = true; }
				else if ( c2 == '_' )                { is_in_identifier = true; }
				else                                 { is_in_identifier = false; }

				if ( ! is_in_identifier )
					{ break; }

				next_plus += 1;
			}
		}
		else if ( ( token_type == gc_TokenOfString  ||  token_type == gc_TokenOfChar ) &&
				( ! is_in_c_comment  &&  ! is_in_cpp_comment ) )
		{
			bool  is_escape = false;

			for (;;) {
				c2 = *( p + next_plus );
				if ( ! is_escape ) {
					if ( c2 == c ) {
						next_plus += 1;
						break;
					}
					else if ( c2 == '\\' ) {
						is_escape = true;
					}
				}
				else {
					is_escape = false;
				}

				next_plus += 1;
			}
		}

		if ( token_type != gc_TokenOfOther ) {
			e= HeapMemory_allocate( &token ); IF(e){goto fin;}
			C_LanguageTokenClass_initConst( token );
			token->Start = p;
			token->Over  = p + next_plus;
			token->TokenType = token_type;

			e= ListClass_addLast( in_TokenList, &token->ListElement ); IF(e){goto fin;}
			token = NULL;
		}

		p += next_plus;
		c = *p;
	}

	e=0;
fin:
	e= HeapMemory_free( &token, e );
	return  e;
}


 
/***********************************************************************
  <<< [CutComment_C_LanguageToken] >>> 
************************************************************************/
errnum_t  CutComment_C_LanguageToken( ListClass* /*<C_LanguageTokenClass>*/ TokenList )
{
	errnum_t                e;
	C_LanguageTokenClass*   p;
	C_LanguageTokenEnum     token_type;
	bool                    is_in_c_comment;
	bool                    is_in_cpp_comment;
	bool                    is_cut;
	ListIteratorClass       iterator;


	is_in_c_comment = false;
	is_in_cpp_comment = false;
	e= ListClass_getListIterator( TokenList, &iterator ); IF(e){goto fin;}
	for (;;) {
		p = (C_LanguageTokenClass*) ListIteratorClass_getNext( &iterator );
			if ( p == NULL ) { break; }
		ASSERT_D( p->ClassID == &g_C_LanguageTokenClass_ID,  e=E_OTHERS; goto fin );

		token_type = p->TokenType;
		if ( token_type == TwoChar8( '/', '*' ) ) {
			if ( ! is_in_cpp_comment ) {
				is_in_c_comment = true;
			}
			is_cut = true;
		}
		else if ( token_type == TwoChar8( '*', '/' ) ) {
			if ( ! is_in_cpp_comment ) {
				is_in_c_comment = false;
			}
			is_cut = true;
		}
		else if ( token_type == TwoChar8( '/', '/' ) ) {
			if ( ! is_in_c_comment ) {
				is_in_cpp_comment = true;
			}
			is_cut = true;
		}
		else if ( token_type == '\n' ){
			is_in_cpp_comment = false;
			is_cut = true;
		}
		else {
			is_cut = ( is_in_c_comment || is_in_cpp_comment );
		}

		if ( is_cut ) {
			e= ListIteratorClass_remove( &iterator );
			e= HeapMemory_free( &p, e ); 
		}
	}

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
* Function: CutCommentC_1
************************************************************************/
errnum_t  CutCommentC_1( const TCHAR*  in_InputPath,  const TCHAR*  in_OutputPath )
{
	errnum_t   e;
	FILE*      file = NULL;
	TCHAR*     text = NULL;
	ListClass  tokens;

	ListClass_initConst( &tokens );

	e= FileT_openForRead( &file, in_InputPath ); IF(e){goto fin;}
	e= FileT_readAll( file, &text, NULL ); IF(e){goto fin;}
	e= FileT_closeAndNULL( &file, 0 ); IF(e){goto fin;}

	e= LexicalAnalize_C_Language( text, &tokens ); IF(e){goto fin;}
	e= FileT_openForWrite( &file, in_OutputPath, 0 ); IF(e){goto fin;}
	e= CopyWithoutComment_C_Language( &tokens, text, file ); IF(e){goto fin;}
	e= FileT_closeAndNULL( &file, 0 ); IF(e){goto fin;}

	e=0;
fin:
	e= Delete_C_LanguageToken( &tokens, e );
	e= HeapMemory_free( &text, e );
	e= FileT_closeAndNULL( &file, e );
	return  e;
}


 
/***********************************************************************
* Function: CopyWithoutComment_C_Language
************************************************************************/
errnum_t  CopyWithoutComment_C_Language( ListClass*  in_Tokens,  TCHAR*  in_Text,  FILE*  in_OutStream )
{
	errnum_t      e;
	const TCHAR*  p;
	TCHAR*        source = in_Text;
	TCHAR*        comment_start = NULL;
	TCHAR*        comment_over = NULL;
	bool          is_new_space = false;

	C_LanguageTokenClass* token;
	ListIteratorClass     iterator;
	const ClassID_Class*  class_ID;


	/* BOM なし Unicode、改行=LF で保存したファイルの内容と一致します。 */


	for ( ListClass_forEach( in_Tokens, &iterator, &token ) ) {
		class_ID = token->ClassID;
		if ( class_ID == &g_C_LanguageTokenClass_ID ) {
			C_LanguageTokenEnum    token_type = token->TokenType;

			if ( ( token_type == TwoChar8( '/', '*' )  ||  token_type == TwoChar8( '/', '/' )
					) &&  source <= token->Start  &&  comment_start == NULL ) {
				p = token->Start;
				p = StrT_rskip( in_Text, p - 1, _T(" \t"), NULL );

				if ( p != NULL ) {
					comment_start = (TCHAR*) p + 1;
				} else {
					comment_start = in_Text;
				}
				if ( source > comment_start )
					{ comment_start = source; }


				if ( token_type == TwoChar8( '/', '/' ) ) {
					p = StrT_chr( comment_start, _T('\n') );
					if ( p != NULL ) {
						if ( comment_start == in_Text  ||  *( comment_start - 1 ) == _T('\n') )
							{ p += 1; }  /* This line has comment only */
					} else {
						p = StrT_chr( comment_start,  _T('\0') );
					}

					comment_over = (TCHAR*) p;
				}
			}
			else if ( token_type == TwoChar8( '*', '/' )  &&  comment_start != NULL ) {
				p = token->Over;
				p = StrT_skip( p, _T(" \t") );
				if ( comment_start > in_Text ) {
					if ( *( comment_start - 1 ) == _T('\n') ) {
						if ( *p == _T('\n') )
							{ p += 1; }
					}
					else if ( *p != _T('\n') ) {
						/* Keeps spaces */
						TCHAR*  p2 = _tcschr( comment_start, _T('/') );

						if ( p2 != comment_start ) {
							comment_start = p2;
						} else {
							is_new_space = true;
						}
					}
				}

				comment_over = (TCHAR*) p;
			}


			if ( comment_over != NULL ) {
				e= FileT_writePart( in_OutStream,  source,  comment_start ); IF(e){goto fin;}

				if ( is_new_space ) {
					_TINT  rt= _fputtc( _T(' '), in_OutStream );
					IF(rt==_TEOF){e=E_OTHERS; goto fin;}
					is_new_space = false;
				}

				source = comment_over;
				comment_start = NULL;
				comment_over  = NULL;
			}
		}
	}
	e= FileT_writePart( in_OutStream,  source,  StrT_chr( source, _T('\0') ) ); IF(e){goto fin;}

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [Delete_C_LanguageToken] >>> 
************************************************************************/
errnum_t  Delete_C_LanguageToken( ListClass* /*<C_LanguageTokenClass*>*/ TokenList, errnum_t e )
{
	return  ListClass_finalizeWithVTable( TokenList, true, e );
}


 
/***********************************************************************
  <<< (C_LanguageTokenClass) >>> 
************************************************************************/

static const FinalizerVTableClass  gs_C_LanguageTokenClass_FinalizerVTable = {
	offsetof( C_LanguageTokenClass, FinalizerVTable ),
	DefaultFunction_Finalize,
};
static const PrintXML_VTableClass  gs_C_LanguageTokenClass_PrintXML_VTable = {
	offsetof( C_LanguageTokenClass, PrintXML_VTable ),
	C_LanguageTokenClass_printXML,
};
static const InterfaceToVTableClass  gs_C_LanguageTokenClass_InterfaceToVTables[] = {
	{ &g_FinalizerInterface_ID, &gs_C_LanguageTokenClass_FinalizerVTable },
	{ &g_PrintXML_Interface_ID, &gs_C_LanguageTokenClass_PrintXML_VTable },
};
static const ClassID_Class*  gs_C_LanguageTokenClass_SuperClassIDs[] = {
	&g_ClassID_SuperClass_ID, &g_ParsedRangeClass_ID, &g_SyntaxSubNodeClass_ID,
	&g_C_LanguageTokenClass_ID,
};

/*[g_C_LanguageTokenClass_ID]*/
const ClassID_Class  g_C_LanguageTokenClass_ID = {
	"C_LanguageTokenClass",
	gs_C_LanguageTokenClass_SuperClassIDs,
	_countof( gs_C_LanguageTokenClass_SuperClassIDs ),
	sizeof( C_LanguageTokenClass ),
	NULL,
	gs_C_LanguageTokenClass_InterfaceToVTables,
	_countof( gs_C_LanguageTokenClass_InterfaceToVTables ),
};


 
/***********************************************************************
  <<< [C_LanguageTokenClass_initConst] >>> 
************************************************************************/
void  C_LanguageTokenClass_initConst( C_LanguageTokenClass* self )
{
	self->ClassID = &g_C_LanguageTokenClass_ID;
	self->FinalizerVTable = &gs_C_LanguageTokenClass_FinalizerVTable;
	self->Start = NULL;
	self->Over = NULL;
	self->PrintXML_VTable = &gs_C_LanguageTokenClass_PrintXML_VTable;
	self->Parent = NULL;
	ListElementClass_initConst( &self->SubNodeListElement, self );
	self->TokenType = gc_TokenOfOther;
	ListElementClass_initConst( &self->ListElement, self );
	self->ParentBlock = NULL;
}


 
/***********************************************************************
  <<< [C_LanguageTokenClass_printXML] >>> 
************************************************************************/
errnum_t  C_LanguageTokenClass_printXML( C_LanguageTokenClass* self, FILE* OutputStream )
{
	errnum_t  e;
	int  r;

	r= _ftprintf_s( OutputStream, _T("<C_LanguageTokenClass") );
		IF ( r < 0 ) { e=E_ACCESS_DENIED; goto fin; }

#if 0
	r= _ftprintf_s( OutputStream, _T(" Address=\"0x%08X\""), self );
		IF ( r < 0 ) { e=E_ACCESS_DENIED; goto fin; }
#endif

	r= _ftprintf_s( OutputStream, _T(" TokenType=\"%s\""),
		C_LanguageTokenEnum_convertToStr( self->TokenType ) );
		IF ( r < 0 ) { e=E_ACCESS_DENIED; goto fin; }

	r= _ftprintf_s( OutputStream, _T(" Token=\"") );
		IF ( r < 0 ) { e=E_ACCESS_DENIED; goto fin; }
	e= ftcopy_part_r( OutputStream, self->Start, self->Over ); IF(e){goto fin;}
	r= _ftprintf_s( OutputStream, _T("\"") );
		IF ( r < 0 ) { e=E_ACCESS_DENIED; goto fin; }

	r= _ftprintf_s( OutputStream, _T("/>\n") );
		IF ( r < 0 ) { e=E_ACCESS_DENIED; goto fin; }

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [C_LanguageTokenEnum_convertToStr] >>> 
************************************************************************/

static const NameAndNumClass  C_LanguageTokenEnum_ConvertTable[] = {
	{ _T("Other"), gc_TokenOfOther },
	{ _T("Number"), gc_TokenOfNumber },
	{ _T("CIdentifier"), gc_TokenOfCIdentifier },
	{ _T("("), gc_TokenOf_28 },
	{ _T(")"), gc_TokenOf_29 },
	{ _T("{"), gc_TokenOf_7B },
	{ _T("}"), gc_TokenOf_7D },
	{ _T("["), gc_TokenOf_5B },
	{ _T("]"), gc_TokenOf_5D },
	{ _T(":"), gc_TokenOf_3A },
	{ _T(";"), gc_TokenOf_3B },
	{ _T("*"), gc_TokenOf_2A },
	{ _T("\\n"), gc_TokenOf_0A },
	{ _T("/*"),  gc_TokenOf_2A2F },
	{ _T("*/"),  gc_TokenOf_2F2A },
	{ _T("//"),  gc_TokenOf_2F2F },
};

TCHAR*  C_LanguageTokenEnum_convertToStr( C_LanguageTokenEnum Value )
{
	return  StrT_convertNumToStr( Value, C_LanguageTokenEnum_ConvertTable,
		_countof( C_LanguageTokenEnum_ConvertTable ), _T("Unknown") );
}


 
/***********************************************************************
  <<< [Parse_PP_Directive] >>> 
************************************************************************/

errnum_t  Parse_PP_Directive_Step1( const TCHAR* Text, Set2* DirectivePointerArray );
errnum_t  Parse_PP_Directive_ConnectIf( Set2* DirectivePointerArray );
errnum_t  Parse_PP_Directive_Parameter( Set2* DirectivePointerArray );


errnum_t  Parse_PP_Directive( const TCHAR* Text,
	Set2* /*<PP_DirectiveClass*>*/ DirectivePointerArray )
{
	errnum_t  e;

	e= Parse_PP_Directive_Step1( Text, DirectivePointerArray ); IF(e){goto fin;}
	e= Parse_PP_Directive_ConnectIf( DirectivePointerArray ); IF(e){goto fin;}
	e= Parse_PP_Directive_Parameter( DirectivePointerArray ); IF(e){goto fin;}

	e=0;
fin:
	return  e;
}


/*[Parse_PP_Directive_Step1]*/
errnum_t  Parse_PP_Directive_Step1( const TCHAR* Text, Set2* DirectivePointerArray )
{
	errnum_t      e;
	const TCHAR*  pos;
	const TCHAR*  p;
	PP_DirectiveClass*   directive = NULL;
	PP_DirectiveClass    directive_0;
	PP_DirectiveClass**  directive_pp;
	ClassID_Class*       class_ID;

	pos = Text;
	PP_DirectiveClass_initConst( &directive_0 );

	for (;;) {

		/* Set "DirectiveName_Start" */
		p = _tcschr( pos, _T('#') );
		if ( p == NULL )
			{ break; }
		p = StrT_skip( p + 1, _T(" \t") );
			ASSERT_R( *p != _T('\0'), e=E_OTHERS; goto fin );
		directive_0.DirectiveName_Start = p;


		/* Set "DirectiveName_Over" */
		directive_0.DirectiveName_Over =
			StrT_searchOverOfCIdentifier( directive_0.DirectiveName_Start );


		/* Set "Start" */
		p = StrT_rstr( Text, directive_0.DirectiveName_Start, _T("\n"), NULL );
		if ( p == NULL )  { p = Text; }
		else              { p += 1; }
		directive_0.Start = p;


		/* Set "Over" */
		p = directive_0.DirectiveName_Over;
		for (;;) {
			const TCHAR*  p2 = _tcschr( p, _T('\n') );
			if ( p2 == NULL ) {
				p = _tcschr( p, _T('\0') );
				break;
			} else if ( *( p2 - 1 ) == _T('\\') ) {
				p = p2 + 1;
				continue;
			} else {
				p = p2 + 1;
				break;
			}
		}
		directive_0.Over = p;


		/* Set "directive" */
		{
			static NameOnlyClass  table[] = {
				{ _T("define"), (void*) &g_PP_SharpDefineClass_ID },
				{ _T("include"),(void*) &g_PP_SharpIncludeClass_ID },
				{ _T("if"),     (void*) &g_PP_SharpIfClass_ID },
				{ _T("else"),   (void*) &g_PP_SharpElseClass_ID },
				{ _T("endif"),  (void*) &g_PP_SharpEndifClass_ID },
				{ _T("ifdef"),  (void*) &g_PP_SharpIfdefClass_ID },
				{ _T("ifndef"), (void*) &g_PP_SharpIfndefClass_ID },
			};

			class_ID = StrT_convPartStrToPointer(
				directive_0.DirectiveName_Start,
				directive_0.DirectiveName_Over,
				table, sizeof(table), (void*) &g_PP_DirectiveClass_ID );
		}

		e= ClassID_Class_createObject( class_ID, &directive, NULL ); IF(e){goto fin;}

		directive->DirectiveName_Start = directive_0.DirectiveName_Start;
		directive->DirectiveName_Over  = directive_0.DirectiveName_Over;
		directive->Start = directive_0.Start;
		directive->Over  = directive_0.Over;


		/* Add to "DirectivePointerArray" (1) */
		e= Set2_alloc( DirectivePointerArray, &directive_pp, PP_DirectiveClass* );
			IF(e){goto fin;}


		/* Add to "DirectivePointerArray" (2) */
		*directive_pp = directive;
		directive = NULL;


		/* Next */
		pos = directive_0.Over;
		PP_DirectiveClass_initConst( &directive_0 );
	}

	e=0;
fin:
	if ( directive != NULL )  { e= HeapMemory_free( &directive, e ); }
	return  e;
}


/*[Parse_PP_Directive_ConnectIf]*/
errnum_t  Parse_PP_Directive_ConnectIf( Set2* DirectivePointerArray )
{
	errnum_t             e;
	PP_DirectiveClass**  pp;
	PP_DirectiveClass**  pp_over;
	PP_DirectiveClass*   directive;
	PP_SharpIfClass**    pp_sh_if;  /* pp is pointer of pointer, sh = sharp */
	PP_SharpElseClass**  pp_sh_else;
	Set2                 if_stack;
	Set2                 else_stack;
	PP_SharpIfClass*     sh_if;          /* sh = sharp */
	PP_SharpElseClass*   sh_else;        /* sh = sharp */
	PP_SharpEndifClass*  sh_endif;       /* sh = sharp */
	PP_DirectiveClass*   sh_if_or_else;  /* sh = sharp */


	Set2_initConst( &if_stack );
	Set2_initConst( &else_stack );
	e= Set2_init( &if_stack, 0x10 ); IF(e){goto fin;}
	e= Set2_init( &else_stack, 0x10 ); IF(e){goto fin;}
	sh_if         = NULL;
	sh_else       = NULL;
	sh_endif      = NULL;
	sh_if_or_else = NULL;

	for ( Set2_forEach( DirectivePointerArray, &pp, &pp_over, PP_DirectiveClass* ) ) {
		directive = *pp;

		if ( ClassID_Class_isSuperClass( directive->ClassID, &g_PP_SharpIfClass_ID ) ) {

			/* Start of nest */
			if ( sh_if_or_else != NULL ) {
				e= Set2_alloc( &if_stack, &pp_sh_if, PP_SharpIfClass* );
					IF(e){goto fin;}
				*pp_sh_if = sh_if;

				e= Set2_alloc( &else_stack, &pp_sh_else, PP_SharpElseClass* );
					IF(e){goto fin;}
				*pp_sh_else = sh_else;
			}

			/* Set "sh_if" */
			sh_if = (PP_SharpIfClass*) directive;
			sh_if_or_else = directive;
		}
		else if ( directive->ClassID == &g_PP_SharpElseClass_ID ) {
			sh_else = (PP_SharpElseClass*) directive;

			IF ( sh_if == NULL ) {
				Error4_printf( _T("<ERROR msg=\"Not found #if\"/>") );
				e= E_ORIGINAL; goto fin;
			}

			/* Link #if and #else */
			sh_if->NextDirective = directive;
			sh_else->StartDirective = sh_if;
			sh_if_or_else = directive;
		}
		else if ( directive->ClassID == &g_PP_SharpEndifClass_ID ) {
			sh_endif = (PP_SharpEndifClass*) directive;

			IF ( sh_if_or_else == NULL ) {
				Error4_printf( _T("<ERROR msg=\"Not found #if\"/>") );
				e= E_ORIGINAL; goto fin;
			}

			/* Link ( #if or #else ) and #endif */
			sh_if->EndDirective = sh_endif;
			if ( sh_else == NULL )
				{ sh_if->NextDirective = directive; }
			else
				{ sh_else->EndDirective = sh_endif; }
			sh_endif->StartDirective = sh_if;
			sh_endif->PreviousDirective = sh_if_or_else;

			sh_if         = NULL;
			sh_else       = NULL;
			sh_endif      = NULL;
			sh_if_or_else = NULL;

			/* End of nest */
			if ( if_stack.Next > if_stack.First ) {
				e= Set2_pop( &if_stack, &pp_sh_if, PP_SharpIfClass* );
					IF(e){goto fin;}
				sh_if = *pp_sh_if;

				e= Set2_pop( &else_stack, &pp_sh_else, PP_SharpElseClass* );
					IF(e){goto fin;}
				sh_else = *pp_sh_else;

				if ( sh_else == NULL ) {
					sh_if_or_else = (PP_DirectiveClass*) sh_if;
				} else {
					sh_if_or_else = (PP_DirectiveClass*) sh_else;
				}
			}
		}
	}

	e=0;
fin:
	e= Set2_finish( &if_stack, e );
	e= Set2_finish( &else_stack, e );
	return  e;
}


/*[Parse_PP_Directive_Parameter]*/
errnum_t  Parse_PP_Directive_Parameter( Set2* DirectivePointerArray )
{
	errnum_t             e;
	TCHAR*               p;
	PP_DirectiveClass**  pp;
	PP_DirectiveClass**  pp_over;
	PP_DirectiveClass*   directive;

	for ( Set2_forEach( DirectivePointerArray, &pp, &pp_over, PP_DirectiveClass* ) ) {
		directive = *pp;

		if ( ClassID_Class_isSuperClass( directive->ClassID, &g_PP_SharpDefineClass_ID ) ) {
			PP_SharpDefineClass*  sh_define = (PP_SharpDefineClass*) directive;

			p = StrT_skip( sh_define->DirectiveName_Over, _T(" \t") );
			IF ( p >= sh_define->Over ) { e=E_OTHERS; goto fin; }
			sh_define->Symbol_Start = p;

			p = StrT_searchOverOfCIdentifier( p );
			sh_define->Symbol_Over = p;
		}

		if ( ClassID_Class_isSuperClass( directive->ClassID, &g_PP_SharpIncludeClass_ID ) ) {
			TCHAR*                 p;
			TCHAR*                 closers;
			PP_SharpIncludeClass*  sh_include = (PP_SharpIncludeClass*) directive;

			p = StrT_skip( sh_include->DirectiveName_Over, _T(" \t") );
			IF ( p >= sh_include->Over ) { e=E_OTHERS; goto fin; }
			switch ( *p ) {
				case  '<':
					sh_include->PathBracket = _T('<');
					closers = _T(">");
					break;

				case  '"':
					sh_include->PathBracket = _T('"');
					closers = _T("\"");
					break;

				default:
					sh_include->PathBracket = _T('\0');
					closers = _T(" \t\n");
					break;
			}

			sh_include->Path_Start = p + 1;

			p = StrT_chrs( p + 1, closers );
				IF ( p == NULL ) { e=E_OTHERS; goto fin; }
			sh_include->Path_Over = p;
		}

		if ( ClassID_Class_isSuperClass( directive->ClassID, &g_PP_SharpIfdefClass_ID ) ) {
			TCHAR*  p;
			PP_SharpIfdefClass*  sh_ifdef;    /* sh = sharp */

			sh_ifdef = (PP_SharpIfdefClass*) directive;

			p = StrT_skip( sh_ifdef->DirectiveName_Over, _T(" \t") );
			IF ( p >= sh_ifdef->Over ) { e=E_OTHERS; goto fin; }
			sh_ifdef->Symbol_Start = p;

			p = StrT_searchOverOfCIdentifier( p );
			sh_ifdef->Symbol_Over = p;
		}
	}

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [Delete_PP_Directive] >>> 
************************************************************************/
errnum_t  Delete_PP_Directive( Set2* DirectivePointerArray, errnum_t e )
{
	PP_DirectiveClass**    pp;
	PP_DirectiveClass**    pp_over;
	PP_DirectiveClass*     directive;
	FinalizerVTableClass*  finalizer;

	if ( Set2_isInited( DirectivePointerArray ) ) {
		for ( Set2_forEach( DirectivePointerArray, &pp, &pp_over, PP_DirectiveClass* ) ) {
			directive = *pp;
			finalizer = ClassID_Class_getVTable( directive->ClassID,
				&g_FinalizerInterface_ID );
			e= finalizer->Finalize( directive, e );
			e= HeapMemory_free( &directive, e );
		}

		e= Set2_finish( DirectivePointerArray, e );
	}
	return  e;
}


 
/***********************************************************************
  <<< [CutPreprocessorDirectives_from_C_LanguageToken] >>> 
************************************************************************/
errnum_t  CutPreprocessorDirectives_from_C_LanguageToken(
	ListClass* /*<C_LanguageTokenClass*>*/ TokenList,
	Set2* /*<PP_DirectiveClass*>*/ Directives )
{
	errnum_t                e;
	C_LanguageTokenClass*   token;
	ListIteratorClass       iterator;
	PP_DirectiveClass**     pp_directive = Directives->First;
	PP_DirectiveClass**     pp_directive_over = Directives->Next;
	PP_DirectiveClass*      directive = *pp_directive;


	if ( pp_directive == pp_directive_over )
		{ e=0;  goto fin; }

	e= ListClass_getListIterator( TokenList, &iterator ); IF(e){goto fin;}
	for (;;) {
		token = (C_LanguageTokenClass*) ListIteratorClass_getNext( &iterator );
			if ( token == NULL ) { break; }
		ASSERT_D( token->ClassID == &g_C_LanguageTokenClass_ID,  e=E_OTHERS; goto fin );

		if ( token->Start >= directive->Start ) {
			if ( token->Over <= directive->Over ) {
				e= ListIteratorClass_remove( &iterator );
				e= HeapMemory_free( &token, 0 ); IF(e){goto fin;}
			}
			else {
				while ( token->Start > directive->Over ) {
					pp_directive += 1;
					if ( pp_directive >= pp_directive_over )
						{ break; }
					directive = *pp_directive;
				}
			}
		}
	}

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< (PP_DirectiveClass) >>> 
************************************************************************/

/*[PP_DirectiveClass_initConst]*/
void  PP_DirectiveClass_initConst( PP_DirectiveClass* self )
{
	self->ClassID  = &g_PP_DirectiveClass_ID;
	self->Start    = NULL;
	self->Over     = NULL;
	self->DirectiveName_Start = NULL;
	self->DirectiveName_Over  = NULL;
}

/*[g_PP_DirectiveClass_ID]*/
static const ClassID_Class*  gs_PP_DirectiveClass_SuperClassIDs[] = {
	&g_ClassID_SuperClass_ID, &g_Variant_SuperClass_ID, &g_ParsedRangeClass_ID
};
static const FinalizerVTableClass  gs_PP_DirectiveClass_FinalizerVTable = {
	offsetof( PP_DirectiveClass, FinalizerVTable ),
	DefaultFunction_Finalize
};
static const InterfaceToVTableClass  gs_PP_DirectiveClass_InterfaceToVTables[] = {
	{ &g_FinalizerInterface_ID, &gs_PP_DirectiveClass_FinalizerVTable }
};
const ClassID_Class  g_PP_DirectiveClass_ID = {
	"PP_DirectiveClass",
	gs_PP_DirectiveClass_SuperClassIDs,
	_countof( gs_PP_DirectiveClass_SuperClassIDs ),
	sizeof( PP_DirectiveClass ),
	NULL,
	gs_PP_DirectiveClass_InterfaceToVTables,
	_countof( gs_PP_DirectiveClass_InterfaceToVTables )
};


/*[g_PP_SharpDefineClass_ID]*/
static const ClassID_Class*  gs_PP_SharpDefineClass_SuperClassIDs[] = {
	&g_ClassID_SuperClass_ID, &g_Variant_SuperClass_ID, &g_ParsedRangeClass_ID,
	&g_PP_DirectiveClass_ID
};
static const FinalizerVTableClass  gs_PP_SharpDefineClass_FinalizerVTable = {
	offsetof( PP_SharpDefineClass, FinalizerVTable ),
	DefaultFunction_Finalize
};
static const InterfaceToVTableClass  gs_PP_SharpDefineClass_InterfaceToVTables[] = {
	{ &g_FinalizerInterface_ID, &gs_PP_SharpDefineClass_FinalizerVTable }
};
const ClassID_Class  g_PP_SharpDefineClass_ID = {
	"PP_SharpDefineClass",
	gs_PP_SharpDefineClass_SuperClassIDs,
	_countof( gs_PP_SharpDefineClass_SuperClassIDs ),
	sizeof( PP_SharpDefineClass ),
	NULL,
	gs_PP_SharpDefineClass_InterfaceToVTables,
	_countof( gs_PP_SharpDefineClass_InterfaceToVTables )
};


/*[g_PP_SharpIncludeClass_ID]*/
static const ClassID_Class*  gs_PP_SharpIncludeClass_SuperClassIDs[] = {
	&g_ClassID_SuperClass_ID, &g_Variant_SuperClass_ID, &g_ParsedRangeClass_ID,
	&g_PP_DirectiveClass_ID
};
static const FinalizerVTableClass  gs_PP_SharpIncludeClass_FinalizerVTable = {
	offsetof( PP_SharpIncludeClass, FinalizerVTable ),
	DefaultFunction_Finalize
};
static const InterfaceToVTableClass  gs_PP_SharpIncludeClass_InterfaceToVTables[] = {
	{ &g_FinalizerInterface_ID, &gs_PP_SharpIncludeClass_FinalizerVTable }
};
const ClassID_Class  g_PP_SharpIncludeClass_ID = {
	"PP_SharpIncludeClass",
	gs_PP_SharpIncludeClass_SuperClassIDs,
	_countof( gs_PP_SharpIncludeClass_SuperClassIDs ),
	sizeof( PP_SharpIncludeClass ),
	NULL,
	gs_PP_SharpIncludeClass_InterfaceToVTables,
	_countof( gs_PP_SharpIncludeClass_InterfaceToVTables )
};


/*[g_PP_SharpIfClass_ID]*/
static const ClassID_Class*  gs_PP_SharpIfClass_SuperClassIDs[] = {
	&g_ClassID_SuperClass_ID, &g_Variant_SuperClass_ID, &g_ParsedRangeClass_ID,
	&g_PP_DirectiveClass_ID
};
static const FinalizerVTableClass  gs_PP_SharpIfClass_FinalizerVTable = {
	offsetof( PP_SharpIfClass, FinalizerVTable ),
	DefaultFunction_Finalize
};
static const InterfaceToVTableClass  gs_PP_SharpIfClass_InterfaceToVTables[] = {
	{ &g_FinalizerInterface_ID, &gs_PP_SharpIfClass_FinalizerVTable }
};
const ClassID_Class  g_PP_SharpIfClass_ID = {
	"PP_SharpIfClass",
	gs_PP_SharpIfClass_SuperClassIDs,
	_countof( gs_PP_SharpIfClass_SuperClassIDs ),
	sizeof( PP_SharpIfClass ),
	NULL,
	gs_PP_SharpIfClass_InterfaceToVTables,
	_countof( gs_PP_SharpIfClass_InterfaceToVTables )
};


/*[g_PP_SharpElseClass_ID]*/
static const ClassID_Class*  gs_PP_SharpElseClass_SuperClassIDs[] = {
	&g_ClassID_SuperClass_ID, &g_Variant_SuperClass_ID, &g_ParsedRangeClass_ID,
	&g_PP_DirectiveClass_ID
};
static const FinalizerVTableClass  gs_PP_SharpElseClass_FinalizerVTable = {
	offsetof( PP_SharpElseClass, FinalizerVTable ),
	DefaultFunction_Finalize
};
static const InterfaceToVTableClass  gs_PP_SharpElseClass_InterfaceToVTables[] = {
	{ &g_FinalizerInterface_ID, &gs_PP_SharpElseClass_FinalizerVTable }
};
const ClassID_Class  g_PP_SharpElseClass_ID = {
	"PP_SharpElseClass",
	gs_PP_SharpElseClass_SuperClassIDs,
	_countof( gs_PP_SharpElseClass_SuperClassIDs ),
	sizeof( PP_SharpElseClass ),
	NULL,
	gs_PP_SharpElseClass_InterfaceToVTables,
	_countof( gs_PP_SharpElseClass_InterfaceToVTables )
};


/*[g_PP_SharpEndifClass_ID]*/
static const ClassID_Class*  gs_PP_SharpEndifClass_SuperClassIDs[] = {
	&g_ClassID_SuperClass_ID, &g_Variant_SuperClass_ID, &g_ParsedRangeClass_ID,
	&g_PP_DirectiveClass_ID
};
static const FinalizerVTableClass  gs_PP_SharpEndifClass_FinalizerVTable = {
	offsetof( PP_SharpEndifClass, FinalizerVTable ),
	DefaultFunction_Finalize
};
static const InterfaceToVTableClass  gs_PP_SharpEndifClass_InterfaceToVTables[] = {
	{ &g_FinalizerInterface_ID, &gs_PP_SharpEndifClass_FinalizerVTable }
};
const ClassID_Class  g_PP_SharpEndifClass_ID = {
	"PP_SharpEndifClass",
	gs_PP_SharpEndifClass_SuperClassIDs,
	_countof( gs_PP_SharpEndifClass_SuperClassIDs ),
	sizeof( PP_SharpEndifClass ),
	NULL,
	gs_PP_SharpEndifClass_InterfaceToVTables,
	_countof( gs_PP_SharpEndifClass_InterfaceToVTables )
};


/*[g_PP_SharpIfdefClass_ID]*/
static const ClassID_Class*  gs_PP_SharpIfdefClass_SuperClassIDs[] = {
	&g_ClassID_SuperClass_ID, &g_Variant_SuperClass_ID, &g_ParsedRangeClass_ID,
	&g_PP_DirectiveClass_ID, &g_PP_SharpIfClass_ID
};
static const FinalizerVTableClass  gs_PP_SharpIfdefClass_FinalizerVTable = {
	offsetof( PP_SharpIfdefClass, FinalizerVTable ),
	DefaultFunction_Finalize
};
static const InterfaceToVTableClass  gs_PP_SharpIfdefClass_InterfaceToVTables[] = {
	{ &g_FinalizerInterface_ID, &gs_PP_SharpIfdefClass_FinalizerVTable }
};
const ClassID_Class  g_PP_SharpIfdefClass_ID = {
	"PP_SharpIfdefClass",
	gs_PP_SharpIfdefClass_SuperClassIDs,
	_countof( gs_PP_SharpIfdefClass_SuperClassIDs ),
	sizeof( PP_SharpIfdefClass ),
	NULL,
	gs_PP_SharpIfdefClass_InterfaceToVTables,
	_countof( gs_PP_SharpIfdefClass_InterfaceToVTables )
};


/*[g_PP_SharpIfndefClass_ID]*/
static const ClassID_Class*  gs_PP_SharpIfndefClass_SuperClassIDs[] = {
	&g_ClassID_SuperClass_ID, &g_Variant_SuperClass_ID, &g_ParsedRangeClass_ID,
	&g_PP_DirectiveClass_ID, &g_PP_SharpIfClass_ID, &g_PP_SharpIfdefClass_ID
};
static const FinalizerVTableClass  gs_PP_SharpIfndefClass_FinalizerVTable = {
	offsetof( PP_SharpIfndefClass, FinalizerVTable ),
	DefaultFunction_Finalize
};
static const InterfaceToVTableClass  gs_PP_SharpIfndefClass_InterfaceToVTables[] = {
	{ &g_FinalizerInterface_ID, &gs_PP_SharpIfndefClass_FinalizerVTable }
};

const ClassID_Class  g_PP_SharpIfndefClass_ID = {
	"PP_SharpIfndefClass",
	gs_PP_SharpIfndefClass_SuperClassIDs,
	_countof( gs_PP_SharpIfndefClass_SuperClassIDs ),
	sizeof( PP_SharpIfndefClass ),
	NULL,
	gs_PP_SharpIfndefClass_InterfaceToVTables,
	_countof( gs_PP_SharpIfndefClass_InterfaceToVTables )
};


 
/***********************************************************************
  <<< (SyntaxSubNodeClass) >>> 
************************************************************************/

/*[g_SyntaxSubNodeClass_ID]*/
const ClassID_Class  g_SyntaxSubNodeClass_ID = {
	"SyntaxSubNodeClass",
	NULL,
	0,
	sizeof( SyntaxSubNodeClass ),
	NULL,
	NULL,
	0,
};


 
/***********************************************************************
  <<< [Delete_SyntaxNodeList] >>> 
************************************************************************/
errnum_t  Delete_SyntaxNodeList( ListClass* /*<SyntaxNodeClass*>*/ NodeList, errnum_t e )
{
	return  ListClass_finalizeWithVTable( NodeList, true, e );
}


 
/***********************************************************************
  <<< (SyntaxNodeClass) >>> 
************************************************************************/

static const FinalizerVTableClass  gs_SyntaxNodeClass_FinalizerVTable = {
	offsetof( SyntaxNodeClass, FinalizerVTable ),
	DefaultFunction_Finalize,
};
static const PrintXML_VTableClass  gs_SyntaxNodeClass_PrintXML_VTable = {
	offsetof( SyntaxNodeClass, PrintXML_VTable ),
	SyntaxNodeClass_printXML,
};
static const InterfaceToVTableClass  gs_SyntaxNodeClass_InterfaceToVTables[] = {
	{ &g_FinalizerInterface_ID, &gs_SyntaxNodeClass_FinalizerVTable },
	{ &g_PrintXML_Interface_ID, &gs_SyntaxNodeClass_PrintXML_VTable },
};
static const ClassID_Class*  gs_SyntaxNodeClass_SuperClassIDs[] = {
	&g_ClassID_SuperClass_ID, &g_ParsedRangeClass_ID, &g_SyntaxSubNodeClass_ID,
	&g_SyntaxNodeClass_ID,
};

/*[g_SyntaxNodeClass_ID]*/
const ClassID_Class  g_SyntaxNodeClass_ID = {
	"SyntaxNodeClass",
	gs_SyntaxNodeClass_SuperClassIDs,
	_countof( gs_SyntaxNodeClass_SuperClassIDs ),
	sizeof( SyntaxNodeClass ),
	NULL,
	gs_SyntaxNodeClass_InterfaceToVTables,
	_countof( gs_SyntaxNodeClass_InterfaceToVTables ),
};


 
/***********************************************************************
  <<< [SyntaxNodeClass_initConst] >>> 
************************************************************************/
void  SyntaxNodeClass_initConst( SyntaxNodeClass* self )
{
	self->ClassID = &g_SyntaxNodeClass_ID;
	self->FinalizerVTable = &gs_SyntaxNodeClass_FinalizerVTable;
	self->Start = NULL;
	self->Over = NULL;
	self->PrintXML_VTable = &gs_SyntaxNodeClass_PrintXML_VTable;
	self->Parent = NULL;
	ListElementClass_initConst( &self->SubNodeListElement, self );
	ListClass_initConst( &self->SubNodeList );
	ListElementClass_initConst( &self->ListElement, self );
}


 
/***********************************************************************
  <<< [SyntaxNodeClass_printXML] >>> 
************************************************************************/
errnum_t  SyntaxNodeClass_printXML( SyntaxNodeClass* self, FILE* OutputStream )
{
	errnum_t  e;
	int  r;

	r= _ftprintf_s( OutputStream, _T("<SyntaxNodeClass") );
		IF ( r < 0 ) { e=E_ACCESS_DENIED; goto fin; }

	r= _ftprintf_s( OutputStream, _T(" Address=\"0x%08X\""), self );
		IF ( r < 0 ) { e=E_ACCESS_DENIED; goto fin; }

	r= _ftprintf_s( OutputStream, _T("/>\n") );
		IF ( r < 0 ) { e=E_ACCESS_DENIED; goto fin; }

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [SyntaxNodeClass_addSubNode] >>> 
************************************************************************/
errnum_t  SyntaxNodeClass_addSubNode( SyntaxNodeClass* self, SyntaxSubNodeClass* SubNode )
{
	errnum_t  e;

	ASSERT_D( ClassID_Class_isSuperClass( self->ClassID, &g_SyntaxNodeClass_ID ), e=E_OTHERS; goto fin );
	ASSERT_D( ClassID_Class_isSuperClass( SubNode->ClassID, &g_SyntaxSubNodeClass_ID ), e=E_OTHERS; goto fin );
	ASSERT_R( SubNode->Parent == NULL, e=E_OTHERS; goto fin );

	e= ListClass_addLast( &self->SubNodeList, &SubNode->SubNodeListElement ); IF(e){goto fin;}
	SubNode->Parent = self;

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [LineNumberIndexClass_compare_sub] >>> 
************************************************************************/
int  LineNumberIndexClass_compare_sub( const void* ppLeft, const void* ppRight, const void* Param,
	int* out_Result )
{
	UNREFERENCED_VARIABLE( Param );
	*out_Result = (const uint8_t*) *(TCHAR**) ppLeft - (const uint8_t*) *(TCHAR**) ppRight;
	return  0;
}


 
/***********************************************************************
  <<< (LineNumberIndexClass) >>> 
************************************************************************/

/*[LineNumberIndexClass_initConst]*/
void  LineNumberIndexClass_initConst( LineNumberIndexClass* self )
{
	Set2_initConst( &self->LeftsOfLine );
}


/*[LineNumberIndexClass_finalize]*/
errnum_t  LineNumberIndexClass_finalize( LineNumberIndexClass* self, errnum_t e )
{
	return  Set2_finish( &self->LeftsOfLine, e );
}


/*[LineNumberIndexClass_initialize]*/
errnum_t  LineNumberIndexClass_initialize( LineNumberIndexClass* self, const TCHAR* Text )
{
	errnum_t       e;
	const TCHAR*   p;
	const TCHAR*   line_feed;
	const TCHAR**  pp_left;

	e= Set2_init( &self->LeftsOfLine, 1000 * sizeof(TCHAR*) ); IF(e){goto fin;}

	p = Text;
	for (;;) {
		e= Set2_alloc( &self->LeftsOfLine, &pp_left, const TCHAR* ); IF(e){goto fin;}
		*pp_left = p;

		line_feed = _tcschr( p, _T('\n') );
		if ( line_feed == NULL )
			{ break; }

		p = line_feed + 1;
	}

#if 0 //[TODO]
	p = _tcschr( p, _T('\0') );
	e= Set2_alloc( &self->LeftsOfLine, &pp_left, const TCHAR* ); IF(e){goto fin;}
	*pp_left = p + 1;
#else
	if ( *p != _T('\0') ) {
		p = _tcschr( p, _T('\0') );
		e= Set2_alloc( &self->LeftsOfLine, &pp_left, const TCHAR* ); IF(e){goto fin;}
		*pp_left = p + 1;
#endif
	}

	e=0;
fin:
	return  e;
}


/*[LineNumberIndexClass_searchLineNumber]*/
errnum_t  LineNumberIndexClass_searchLineNumber( LineNumberIndexClass* self, const TCHAR* Position,
	int* out_LineNumber )
{
	errnum_t  e;
	int       found_index;
	int       result;

	e= PArray_doBinarySearch( self->LeftsOfLine.First,
		(uint8_t*) self->LeftsOfLine.Next - (uint8_t*) self->LeftsOfLine.First,
		Position, LineNumberIndexClass_compare_sub, NULL,
		&found_index, &result );
		IF(e){goto fin;}

	*out_LineNumber = found_index + 1;

	e=0;
fin:
	return  e;
}


/*[LineNumberIndexClass_getCountOfLines]*/
int  LineNumberIndexClass_getCountOfLines( LineNumberIndexClass* self )
{
	return  Set2_getCount( &self->LeftsOfLine, const TCHAR* ) - 1;
}


 
/***********************************************************************
  <<< (ParsedRangeClass) >>> 
************************************************************************/

/*[ParsedRangeClass_initConst]*/
void  ParsedRangeClass_initConst( ParsedRangeClass* self )
{
	self->ClassID = &g_ParsedRangeClass_ID;
	self->FinalizerVTable = NULL;
	self->StaticAddress = NULL;
	self->Start = NULL;
	self->Over = NULL;
}


/*[g_ParsedRangeClass_ID]*/
static const ClassID_Class*  gs_ParsedRangeClass_SuperClassIDs[] = {
	&g_ClassID_SuperClass_ID, &g_Variant_SuperClass_ID, &g_ParsedRangeClass_ID
};
const ClassID_Class  g_ParsedRangeClass_ID = {
	"ParsedRangeClass",
	gs_ParsedRangeClass_SuperClassIDs,
	_countof( gs_ParsedRangeClass_SuperClassIDs ),
	sizeof( ParsedRangeClass ),
	NULL,
};


 
/***********************************************************************
  <<< [ParsedRanges_getCut_by_PP_Directive] >>> 
************************************************************************/
errnum_t  ParsedRanges_getCut_by_PP_Directive(
	Set2* /*<ParsedRangeClass>*/    CutRanges,
	Set2* /*<PP_DirectiveClass*>*/  DirectivePointerArray,
	const TCHAR* Symbol,  bool IsCutDefine )
{
	errnum_t             e;
	PP_DirectiveClass**  p;
	PP_DirectiveClass**  p_over;

	for ( Set2_forEach( DirectivePointerArray, &p, &p_over, PP_DirectiveClass* ) ) {
		PP_DirectiveClass*  directive = *p;
		PP_SharpIfClass*    sh_if = NULL;  /* sh = sharp */
		bool                is_not_condition = false;

		if ( ClassID_Class_isSuperClass( directive->ClassID, &g_PP_SharpIfdefClass_ID ) ) {
			PP_SharpIfdefClass*  sh_ifdef = (PP_SharpIfdefClass*) directive;  /* sh = sharp */

			if ( StrT_cmp_part( sh_ifdef->Symbol_Start, sh_ifdef->Symbol_Over, Symbol ) == 0 ) {
				sh_if = (PP_SharpIfClass*) sh_ifdef;
				is_not_condition = ( sh_ifdef->ClassID == &g_PP_SharpIfndefClass_ID );
			}
		}
		else if ( directive->ClassID == &g_PP_SharpIfClass_ID ) {
			const TCHAR*  condition_start;
			const TCHAR*  condition_over;

			sh_if = (PP_SharpIfClass*) directive;  /* sh = sharp */
			condition_start = sh_if->DirectiveName_Over;
			condition_over  = sh_if->Over;

			while ( condition_start < condition_over ) {
				if ( _istspace( *condition_start ) ) {
					condition_start += 1;
				} else {
					break;
				}
			}
			while ( condition_start < condition_over ) {
				if ( _istspace( *( condition_over - 1 ) ) ) {
					condition_over -= 1;
				} else {
					break;
				}
			}
			if ( ! StrT_cmp_part( condition_start, condition_over, Symbol ) == 0 ) {
				sh_if = NULL;
			}
		}

		if ( sh_if != NULL ) {
			PP_SharpElseClass*   sh_else;   /* sh = sharp */
			PP_SharpEndifClass*  sh_endif;  /* sh = sharp */
			ParsedRangeClass*    cut;


			/* Set "sh_else", "sh_endif" */
			if ( ClassID_Class_isSuperClass( sh_if->NextDirective->ClassID,
					&g_PP_SharpElseClass_ID ) ) {
				sh_else = (PP_SharpElseClass*) sh_if->NextDirective;
				sh_endif = sh_if->EndDirective;
			} else {
				sh_else = NULL;
				sh_endif = (PP_SharpEndifClass*) sh_if->NextDirective;
			}


			/* Add to "CutRanges" */
			e= Set2_alloc( CutRanges, &cut, ParsedRangeClass ); IF(e){goto fin;}
			cut->Start = sh_if->Start;
			if ( is_not_condition == ! IsCutDefine ) {
				if ( sh_else != NULL ) {
					cut->Over = sh_else->Over;

					e= Set2_alloc( CutRanges, &cut, ParsedRangeClass );
						IF(e){goto fin;}
					cut->Start = sh_endif->Start;
				}
				cut->Over = sh_endif->Over;
			}
			else {
				cut->Over = sh_if->Over;

				e= Set2_alloc( CutRanges, &cut, ParsedRangeClass );
					IF(e){goto fin;}
				if ( sh_else != NULL ) {
					cut->Start = sh_else->Start;
				} else {
					cut->Start = sh_endif->Start;
				}
				cut->Over = sh_endif->Over;
			}
		}
	}

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [ParsedRangeClass_onInitializedForDebug] >>> 
************************************************************************/
#if ! defined( NDEBUG )
void  ParsedRangeClass_onInitializedForDebug( ParsedRangeClass* self )
{
	/* These code can be modified for Debug. */
	#if 0  // IS_USED_DEBUG_CHECK_CLASS
		TCHAR*     text;
		ptrdiff_t  break_diff = 0x1FA6A;

		START_D( 10 );
		text = GET_D( 1, TCHAR* );
		PointerType_plus( &text, break_diff );
		if ( text == self->Start ) {
			if ( self->ClassID == &g_ParsedRangeClass_ID ) {
				SET_D( 2, self );
			}
		}
		END_D();
	#else
		UNREFERENCED_VARIABLE( self );
	#endif
}
#endif


 
/***********************************************************************
  <<< [ParsedRanges_compareByStart] >>> 
************************************************************************/
int  ParsedRanges_compareByStart( const void* _a1, const void* _a2 )
{
	ParsedRangeClass*  a1 = (ParsedRangeClass*) _a1;
	ParsedRangeClass*  a2 = (ParsedRangeClass*) _a2;

	return  a1->Start - a2->Start;
}


 
/***********************************************************************
  <<< [ParsedRanges_write_by_Cut] >>> 
************************************************************************/
errnum_t  ParsedRanges_write_by_Cut(
	Set2* /*<ParsedRangeClass>*/ CutRanges,
	const TCHAR* Text, FILE* OutFile )
{
	errnum_t           e;
	const TCHAR*       position;
	ParsedRangeClass*  p;
	ParsedRangeClass*  p_over;

	qsort( CutRanges->First, Set2_getCount( CutRanges, ParsedRangeClass ),
		sizeof(ParsedRangeClass), ParsedRanges_compareByStart );

	position = Text;
	for ( Set2_forEach( CutRanges, &p, &p_over, ParsedRangeClass ) ) {
		const TCHAR*  cut_start_position;
		const TCHAR*  cut_over_position;

		cut_start_position = p->Start;
		if ( position < cut_start_position ) {
			e= FileT_writePart( OutFile, (TCHAR*)position, (TCHAR*)cut_start_position );
				IF(e){goto fin;}
		}

		cut_over_position = p->Over;
		if ( position < cut_over_position ) {
			position = cut_over_position;
		}
	}
	_fputts( position, OutFile ); IF(ferror(OutFile)){e=E_ERRNO; goto fin;}

	e=0;
fin:
	return  e;
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
/* <<< [IniFile2/IniFile2.c] >>> */ 
/*=================================================================*/
 
/***********************************************************************
  <<< [IniStr_isLeft] >>> 
************************************************************************/
bool  IniStr_isLeft( const TCHAR* line, const TCHAR* symbol )
{
  const TCHAR*  p;
  size_t  symbol_len = _tcslen( symbol );

  /* Skip spaces at the top of line */
  for ( p = line; *p == _T(' ') || *p == _T('\t'); p++ );

  /* Compare symbol */
  if ( _tcsnicmp( p, symbol, symbol_len ) != 0 )  return false;

  switch ( *(p + symbol_len) ) {
    case _T(' '):  case _T('\t'):  case _T('='):  return  true;
    default:  return  false;
  }
}



 
/***********************************************************************
  <<< [IniStr_refRight] >>> 
************************************************************************/
TCHAR*  IniStr_refRight( const TCHAR* line, bool bTrimRight )
{
  const TCHAR*  p;

  for ( p = line; *p != _T('\0') && *p != _T('='); p++ );
  if ( *p == _T('=') ) {

    //=== Skip spaces at the right of equal. Trim the left of value
    for ( p++ ; *p == _T(' ') || *p == _T('\t'); p++ );

    //=== Trim the right of value
    if ( bTrimRight ) {
      const TCHAR*  t;
      TCHAR  c;

      t = StrT_chr( p, _T('\0') );
      if ( t != p ) {
        for ( t--; ; t-- ) {
          if ( t < p )
            { p = StrT_chr( p, _T('\0') );  break; }

          c = *t;
          if ( c != ' ' && c != '\t' && c != '\n' && c != '\r' )
            { *(TCHAR*)(t+1) = _T('\0');  break; }
        }
      }
    }
  }
  return  (TCHAR*) p;
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
		p = StrT_chr( data.FullPathMem, _T('\0') );
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

			p = StrT_chr( m->FileName, _T('\0') );

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
  <<< [FileT_openForWrite] >>> 
************************************************************************/
int  FileT_openForWrite( FILE** out_pFile, const TCHAR* Path,  bit_flags_fast32_t  Flags )
{
	int      e;
	errno_t  en;
	TCHAR*   open_type;
	BOOL     b;
	int      retry_count;

	IF_D( ! Locale_isInited() )  return  E_NOT_INIT_GLOBAL;

	#if Uses_AppKey
		e= AppKey_addNewWritableFolder( Path ); IF(e)goto fin;
	#endif

	if ( Flags & F_Append )
		open_type = ( Flags & F_Unicode ? _T("a")_T(fopen_ccs) : _T("at") );
	else
		open_type = ( Flags & F_Unicode ? _T("w")_T(fopen_ccs) : _T("wt") );

	#if DEBUGTOOLS_USES
		{ int e= Debug_onOpen( Path ); if(e) return e; }
	#endif

	for ( retry_count = 0;  ;  retry_count ++ ) {
		en = _tfopen_s( out_pFile, Path, open_type );
		if ( en != EACCES )  break;
		IF ( GetFileAttributes( Path ) == FILE_ATTRIBUTE_DIRECTORY ) { goto err_gt; }

		retry_count += 1;
		if ( retry_count == 15 )  break;
		Sleep( 1000 );
	}
	if ( en == 2 ) {  // ENOENT
		e= FileT_mkdir( Path ); IF(e)goto fin;
		b= RemoveDirectory( Path ); IF(!b)goto err_gt;
		en = _tfopen_s( out_pFile, Path, open_type );

		IF ( en == 2 ) {
			_tprintf( _T("cannot open \"%s\"\n"), Path );

			#ifndef UNDER_CE
			{
				TCHAR  cwd[512];

				if ( _tgetcwd( cwd, _countof(cwd) ) != NULL )
					_tprintf( _T("current = \"%s\"\n"), cwd );
			}
			#endif

			e = E_NOT_FOUND_SYMBOL;
			goto fin;
		}
	}
	IF(en)goto err;

	e=0;
fin:
	return  e;

err:  e = E_OTHERS;  goto fin;
err_gt:  e = SaveWindowsLastError();  goto fin;
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



 
/***********************************************************************
  <<< [FileT_readAll] >>> 
************************************************************************/
#ifdef  IsTest_FileT_readAll
	#define _CV(x)  CoverageLogClass_output( x, _T("FileT_readAll") )
#else
	#define _CV(x)
#endif

errnum_t  FileT_readAll( FILE* File, TCHAR** out_Text, size_t* out_TextLength )
{
#ifdef  IsTest_FileT_readAll
	enum { text_max_size_first = 0x10 };
#else
	enum { text_max_size_first = 0xFF00 };
#endif
	errnum_t  e;
	TCHAR*    text = NULL;
	TCHAR*    text_over = (TCHAR*) DUMMY_INITIAL_VALUE;
	size_t    text_max_size = text_max_size_first;
	TCHAR*    text_max_over;


	text = (TCHAR*) malloc( text_max_size ); IF( text == NULL ) { e=E_FEW_MEMORY; goto fin; }
	text_over = text;
	text_max_over = (TCHAR*)( (uint8_t*) text + text_max_size );

	text[0] = _T('\0');  /* for empty file */

	for (;;) {
		_fgetts( text_over, text_max_over - text_over, File );

		if ( *text_over == _T('\0') ) {  /* End of file. If space line, *text_over == _T('\n').  */
			_CV(1);
			ASSERT_R( feof( File ), e=E_OTHERS; goto fin );
			break;
		}
		text_over = StrT_chr( text_over, _T('\0') );
		if ( feof( File ) ) { break; }

		if ( (uint8_t*) text_over - (uint8_t*) text == (int)( text_max_size - sizeof(TCHAR) ) ) {
				/* if full in text */
			TCHAR*  new_text;
			size_t  old_text_max_size = text_max_size;

			#ifdef  IsTest_FileT_readAll
				EmptyHeapMemoryEmulation( _T("T_FileT_readAll_FewMemory"), 1 );
			#endif

			text_max_size *= 4;
			new_text = (TCHAR*) realloc( text, text_max_size );
				IF( new_text == NULL ) { e=E_FEW_MEMORY; _CV(2); goto fin; }
			text = new_text;
			text_over = (TCHAR*)( (uint8_t*) new_text + old_text_max_size - sizeof(TCHAR) );
			text_max_over = (TCHAR*)( (uint8_t*) text + text_max_size );
		}
		else {
			_CV(3);
		}
	}

	e=0;
fin:
	if ( e ) {
		if ( text != NULL ) { _CV(4); free( text ); }
	}
	else {
		*out_Text = text;
		if ( out_TextLength != NULL ) { *out_TextLength = text_over - text; }
	}
	return  e;
}
#undef _CV


 
/***********************************************************************
  <<< [FileT_writePart] >>> 
************************************************************************/
errnum_t  FileT_writePart( FILE* File, const TCHAR* Start, TCHAR* Over )
{
	errnum_t  e;
	TCHAR     back_char;
	int       r;

	back_char = *Over;

	IF ( Start > Over ) { e=E_OTHERS; goto fin; }

	*Over = _T('\0');
	r= _ftprintf_s( File, _T("%s"), Start ); IF(r<0){ e=E_ERRNO; goto fin; }

	e=0;
fin:
	*Over = back_char;
	return  e;
}


 
/***********************************************************************
  <<< [FileT_mkdir] >>> 
************************************************************************/
int  FileT_mkdir( const TCHAR* Path )
{
	int    e;
	DWORD  r;
	TCHAR* p = (TCHAR*) DUMMY_INITIAL_VALUE;
	BOOL   b;
	int    n_folder = 0;
	TCHAR  path2[MAX_PATH];


	e= StrT_getFullPath( path2, sizeof(path2), Path, NULL ); IF(e)goto fin;
	#if Uses_AppKey
		e= AppKey_addNewWritableFolder( path2 ); IF(e)goto fin;
	#endif


	//=== 存在するフォルダを探す
	for (;;) {
		r = GetFileAttributes( path2 );
		if ( r != (DWORD)-1 ) break;  // "C:" もフォルダと判定される

		p = StrT_refFName( path2 ) - 1;  // 絶対パスなので必ず *p=='\\'
		*p = _T('\0');
		n_folder ++;
	}
	IF ( ! (r & FILE_ATTRIBUTE_DIRECTORY) ) goto err;  // ファイルならエラー


	//=== フォルダを作成する
	for ( ;  n_folder > 0;  n_folder -- ) {
		*p = _T('\\');
		b= CreateDirectory( path2, NULL ); IF(!b)goto err;
		p = StrT_chr( p, _T('\0') );
	}

	e=0;
fin:
	return  e;

err:  e = E_OTHERS;  goto fin;
}



 
/***********************************************************************
  <<< [FileT_copy] >>> 
************************************************************************/
int  FileT_copy_sub( FileT_CallByNestFindData* m );

int  FileT_copy( const TCHAR* SrcPath, const TCHAR* DstPath )
{
	const TCHAR*  p_last;
	int    e;
	BOOL   b;
	TCHAR  path[MAX_PATH*4];


	#if Uses_AppKey
		e= AppKey_addNewWritableFolder( DstPath ); IF(e)goto fin;
	#endif

	p_last = StrT_chr( SrcPath, _T('\0') );
	IF_D( p_last <= SrcPath + 1 )goto err_ni;


	//=== フォルダをコピーする
	if ( *(p_last - 1) == _T('*') ) {
		IF_D( *(p_last - 2) != _T('\\') ) goto err_ni;

		e= StrT_getParentFullPath( path, sizeof(path), SrcPath, NULL ); IF(e)goto fin;
		IF_D( ! FileT_isDir( path ) )goto err_nf;

		e= FileT_callByNestFind( path, FileT_FolderBeforeFiles, (void*) DstPath, (FuncType) FileT_copy_sub );
		IF(e)goto fin;
	}


	//=== ファイルをコピーする
	else {
		IF_D( _tcschr( SrcPath, _T('*') ) != NULL )goto err_ni;
		IF_D( ! FileT_isFile( SrcPath ) ) goto err_nf;

		b= CopyFile( SrcPath, DstPath, FALSE );
		if (!b) {
			if ( FileT_isDir( DstPath ) ) {
				e= stprintf_r( path, sizeof(path), _T("%s\\%s"), DstPath, StrT_refFName( SrcPath ) ); IF(e)goto fin;
				b= CopyFile( SrcPath, path, FALSE ); IF(!b)goto err_gt;
			}
			else {
				int  ee;

				p_last = StrT_chr( DstPath, _T('\0') ) - 1;
				IF_D( p_last < DstPath )goto err;
				if ( *p_last == _T('\\') ) {
					ee= FileT_mkdir( DstPath ); IF(ee)goto fin;
					e= stprintf_r( path, sizeof(path), _T("%s%s"), DstPath, StrT_refFName( SrcPath ) ); IF(e)goto fin;
					b= CopyFile( SrcPath, path, FALSE ); IF(!b)goto err_gt;
				}
				else {
					e = E_ACCESS_DENIED;
					ee= StrT_getParentFullPath( path, sizeof(path), DstPath, NULL ); IF(ee)goto fin;
					ee= FileT_mkdir( path ); IF(ee)goto fin;
					b= CopyFile( SrcPath, DstPath, FALSE ); IF(!b)goto err_gt;
				}
			}
		}
	}

	e=0;
fin:
	return  e;

err_ni:  e = E_NOT_IMPLEMENT_YET;  goto fin;
err_nf:  e = E_PATH_NOT_FOUND;  goto fin;
err_gt:  e = SaveWindowsLastError();  goto fin;
err:  e = E_OTHERS;  goto fin;
}


int  FileT_copy_sub( FileT_CallByNestFindData* m )
{
	const  TCHAR*  DstPath = (const TCHAR*) m->CallerArgument;
	int    e;
	BOOL   b;
	TCHAR  path[MAX_PATH*4];

	e= stprintf_r( path, sizeof(path), _T("%s\\%s"), DstPath, m->StepPath ); IF(e)goto fin;

	if ( m->FileAttributes & FILE_ATTRIBUTE_DIRECTORY ) {
		if ( ! FileT_isDir( path ) )
			{ b= CreateDirectory( path, NULL ); IF(!b)goto err_gt; }
	}
	else {
		b= CopyFile( m->FullPath, path, FALSE ); IF(!b)goto err_gt;
	}

	e=0;
fin:
	return  e;

err_gt:  e = SaveWindowsLastError();  goto fin;
}



 
/***********************************************************************
  <<< [FileT_del] >>> 
************************************************************************/
int  FileT_del_sub( FileT_CallByNestFindData* m );

int  FileT_del( const TCHAR* Path )
{
	int    e;
	DWORD  r;
	TCHAR  abs_path[MAX_PATH];

	e= StrT_getFullPath( abs_path, sizeof(abs_path), Path, NULL ); IF(e)goto fin;
	#if Uses_AppKey
		e= AppKey_addNewWritableFolder( abs_path ); IF(e)goto fin;
	#endif

	r= GetFileAttributes( Path );
	if ( r != (DWORD)-1 ) {
		if ( r & FILE_ATTRIBUTE_DIRECTORY ) {
			e= FileT_callByNestFind( Path, FileT_FolderAfterFiles, NULL, (FuncType) FileT_del_sub );
		}
		else {
			BOOL  b= DeleteFile( Path ); IF(!b)goto err_gt;
		}
	}
	IF_D( FileT_isExist( Path ) )goto err_ad;

	e=0;
fin:
	return  e;

err_gt:  e = SaveWindowsLastError();  goto fin;
err_ad:  e = E_ACCESS_DENIED;  goto fin;
}


int  FileT_del_sub( FileT_CallByNestFindData* m )
{
	int   e;
	BOOL  b;

	if ( m->FileAttributes & FILE_ATTRIBUTE_DIRECTORY ) {
		b= RemoveDirectory( m->FullPath ); IF(!b)goto err_gt;
	}
	else {
		b= DeleteFile( m->FullPath ); IF(!b)goto err_gt;
	}

	e=0;
fin:
	return  e;

err_gt:  e = SaveWindowsLastError();  goto fin;
}
 
/***********************************************************************
  <<< [FileT_writeSizedStruct_WinAPI] >>> 
************************************************************************/
int  FileT_writeSizedStruct_WinAPI( HANDLE* Stream, SizedStruct* OutputSizedStruct )
{
	DWORD  wrote_size;
	BOOL   r;
	int    e;

	r= WriteFile( Stream, &OutputSizedStruct->ThisStructSize,
		sizeof(OutputSizedStruct->ThisStructSize), &wrote_size, NULL );
	IF(!r) goto err_gt;

	r= WriteFile( Stream, &OutputSizedStruct->OthersData,
		OutputSizedStruct->ThisStructSize - sizeof(OutputSizedStruct->ThisStructSize),
		&wrote_size, NULL );
	IF(!r) goto err_gt;
	e=0;
fin:
	return  0;

err_gt:  e = SaveWindowsLastError();  goto fin;
}

 
/***********************************************************************
  <<< [FileT_readSizedStruct_WinAPI] >>> 
************************************************************************/
int  FileT_readSizedStruct_WinAPI( HANDLE* Stream, void** out_SizedStruct )
{
	int    e;
	DWORD  read_size;
	DWORD  data_size;
	void*  out = NULL;
	BOOL   b;

	b= ReadFile( Stream, &data_size, sizeof(data_size), &read_size, NULL ); IF(!b) goto err_gt;
	IF( data_size & 0xC0000000 ) goto err_fm;

	out = malloc( data_size ); IF( out == NULL ) goto err_fm;
	*(size_t*) out = data_size;

	b= ReadFile( Stream, (size_t*) out + 1, data_size - sizeof(size_t), &read_size, NULL ); IF(!b) goto err_gt;

	*out_SizedStruct = out;

	e=0;
fin:
	return  e;

err_gt:  e = SaveWindowsLastError();  goto rollback;
err_fm:  e = E_FEW_MEMORY;  goto rollback;
rollback:
	if ( out != NULL )  free( out );
	goto fin;
}


 
/***********************************************************************
* Implement: FileT_readUnicodeFileBOM
************************************************************************/
errnum_t  FileT_readUnicodeFileBOM( const TCHAR* Path, FileFormatEnum* out_Format )
{
	errnum_t  e;
	HANDLE    file = INVALID_HANDLE_VALUE;
	unsigned char  data[4];
	DWORD     read_size;
	BOOL      b;

	if ( ! FileT_isExist( Path ) ) {
		*out_Format = FILE_FORMAT_NOT_EXIST;
	}
	else {
		file = CreateFile( Path, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING,
			FILE_ATTRIBUTE_NORMAL, 0 );
			IF( file == INVALID_HANDLE_VALUE ) goto err_gt;

		data[0] = '\0';
		b= ReadFile( file, data, 3, &read_size, NULL ); IF(!b)goto err;
		if ( read_size < 2 ) {
			*out_Format = FILE_FORMAT_NO_BOM;
		}
		else if ( ( data[0] == 0xFF ) && ( data[1] == 0xFE ) ) {
			*out_Format = FILE_FORMAT_UNICODE;
		}
		else if ( ( read_size >= 3 ) &&
			( data[0] == 0xEF ) && ( data[1] == 0xBB ) && ( data[2] == 0xBF ) ) {

			*out_Format = FILE_FORMAT_UTF_8;
		}
		else {
			*out_Format = FILE_FORMAT_NO_BOM;
		}
	}

	e=0;
fin:
	if ( file != INVALID_HANDLE_VALUE )  { b= CloseHandle( file ); IF(!b&&!e) e = E_OTHERS; }
	return  e;

err_gt:  e = SaveWindowsLastError();  goto fin;
err:     e = E_OTHERS;          goto fin;
}


 
/***********************************************************************
* Implement: FileT_cutFFFE
************************************************************************/
errnum_t  FileT_cutFFFE( const TCHAR*  in_InputPath,  const TCHAR*  in_OutputPath,  bool  in_IsAppend )
{
	errnum_t  e;
	HANDLE    reading_file = INVALID_HANDLE_VALUE;
	HANDLE    writing_file = INVALID_HANDLE_VALUE;
	wchar_t   buffer[4096];
	uint8_t*  buffer8 = (uint8_t*) buffer;
	wchar_t   a_character;
	uint8_t   a_character8;
	int       index_of_BOM;
	DWORD     read_size;
	DWORD     writing_size;
	DWORD     wrote_size;
	DWORD     reading_index;
	DWORD     reading_index_over;
	DWORD     writing_index;
	DWORD     creation;
	BOOL      b;

	FileFormatEnum  format;

	e= FileT_readUnicodeFileBOM( in_InputPath,  /*Set*/ &format ); IF(e){goto fin;}

	if ( ! in_IsAppend ) {
		creation = CREATE_ALWAYS;
	} else {
		creation = OPEN_ALWAYS;
	}

	reading_file = CreateFile( in_InputPath,  GENERIC_READ,  FILE_SHARE_READ,  NULL,  OPEN_EXISTING,
		FILE_ATTRIBUTE_NORMAL, 0 );
		IF( reading_file == INVALID_HANDLE_VALUE ) { e=E_GET_LAST_ERROR; goto fin; }

	writing_file = CreateFile( in_OutputPath,  GENERIC_WRITE,  0,  NULL,  creation,
		FILE_ATTRIBUTE_NORMAL, 0 );
		IF ( writing_file == INVALID_HANDLE_VALUE ) { e=E_GET_LAST_ERROR; goto fin; }

	if ( in_IsAppend ) {
		SetFilePointer( writing_file,  0,  NULL,  FILE_END );
	}


	for (;;) {

		b= ReadFile( reading_file,  buffer,  sizeof( buffer ),  &read_size,  NULL );
			IF(!b){ e=SaveWindowsLastError(); goto fin; }
		if ( read_size == 0 )
			{ break; }

		if ( format == FILE_FORMAT_UNICODE ) {
			writing_index = 0;
			reading_index_over = read_size / sizeof( buffer[0] );
			for ( reading_index = 0;  reading_index < reading_index_over;  reading_index += 1 ) {

				a_character = buffer[ reading_index ];

				if ( a_character != 0xFEFF ) {  /* FEFF = BOM character */

					buffer[ writing_index ] = a_character;
					writing_index += 1;
				}
			}
			writing_size = writing_index * sizeof( buffer[0] );
		}
		else if ( format == FILE_FORMAT_UTF_8 ) {
			writing_index = 0;
			index_of_BOM = 0;
			reading_index_over = read_size / sizeof( buffer8[0] );
			for ( reading_index = 0;  reading_index < reading_index_over;  reading_index += 1 ) {

				a_character8 = buffer8[ reading_index ];

				if ( a_character8 == 0xEF ) {
					if ( index_of_BOM >= 1 ) {
						buffer8[ writing_index ] = 0xEF;
						writing_index += 1;
						if ( index_of_BOM >= 2 ) {
							buffer8[ writing_index ] = 0xBB;
							writing_index += 1;
						}
					}
					index_of_BOM = 1;
				}
				else if ( a_character8 == 0xBB  &&  index_of_BOM == 1 ) {
					index_of_BOM = 2;
				}
				else if ( a_character8 == 0xBF  &&  index_of_BOM == 2 ) {

					/* Skip BOM */
					index_of_BOM = 0;
				}
				else {
					if ( index_of_BOM >= 1 ) {
						buffer8[ writing_index ] = 0xEF;
						writing_index += 1;
						if ( index_of_BOM >= 2 ) {
							buffer8[ writing_index ] = 0xBB;
							writing_index += 1;
						}
					}

					buffer8[ writing_index ] = a_character8;
					writing_index += 1;

					index_of_BOM = 0;
				}
			}
			writing_size = writing_index * sizeof( buffer8[0] );
		}
		else {
			writing_size = read_size;
		}

		b= WriteFile( writing_file,  buffer,  writing_size,  &wrote_size,  NULL );
			IF(!b) { e=E_GET_LAST_ERROR; goto fin; }
	}

	e=0;
fin:
	e= CloseHandleInFin( writing_file, e );
	e= CloseHandleInFin( reading_file, e );
	return  e;
}


 
/***********************************************************************
  <<< [ParseXML2_StatusClass_getAttribute] >>>
************************************************************************/
errnum_t  ParseXML2_StatusClass_getAttribute( ParseXML2_StatusClass* self,
	const TCHAR* AttributeName, TCHAR** out_AttribyteValue )
{
	TCHAR**  attr;

	for ( attr = (TCHAR**) self->u.OnStartElement.Attributes;  *attr != NULL;  attr += 2 ) {
		if ( _tcsicmp( *attr, AttributeName ) == 0 ) {
			*out_AttribyteValue = *( attr + 1 );
			return  0;
		}
	}
	*out_AttribyteValue = NULL;
	return  0;
}


 
/***********************************************************************
  <<< [ParseXML2_StatusClass_mallocCopyText] >>>
************************************************************************/
errnum_t  ParseXML2_StatusClass_mallocCopyText( ParseXML2_StatusClass* self,
	TCHAR** out_Text )
{
	return  MallocAndCopyStringByLength( out_Text,
		self->u.OnText.Text,  self->u.OnText.TextLength );
}


 
/***********************************************************************
  <<< [ParseXML2] >>>
************************************************************************/

/*[ParseXML2_WorkClass]*/
typedef struct _ParseXML2_WorkClass  ParseXML2_WorkClass;
struct _ParseXML2_WorkClass {
	ParseXML2_StatusClass   Status;
	ParseXML2_CallbackType  OnStartElement;
	ParseXML2_CallbackType  OnEndElement;
	ParseXML2_CallbackType  OnText;
	Set2      XPath;         /* Array of TCHAR */
	Set2      XPathLengths;  /* Array of int. Element is TCHAR count. Array count is Status.Depth */
	StrFile   TextBuffer;
	int       TextStartLineNum;  /* 0 = no text */
	errnum_t  e;
};

/*[BOM]*/
enum { BOM = 0xFEFF };


static errnum_t  ParseXML2_makeXML_Declare_Sub( XML_Parser parser, ParseXML2_WorkClass* work,
	const TCHAR* XML_Path, TCHAR* line, bool* is_xml_declare );
static void  Expat_printfToError4( XML_Parser parser, const TCHAR* XML_Path );
static void  ParseXML2_onStartElement( void* UserData, const XML_Char* Name, const XML_Char** Atts );
static void  ParseXML2_onEndElement( void* UserData, const XML_Char* name );
static void  ParseXML2_onText( void* UserData, const XML_Char* Text, int TextLength );
static void  ParseXML2_callOnText( ParseXML2_WorkClass* work );


errnum_t  ParseXML2( const TCHAR* XML_Path, ParseXML2_ConfigClass* in_out_Config )
{
	errnum_t    e;
	FILE*       file = NULL;
	XML_Parser  parser = (XML_Parser) DUMMY_INITIAL_VALUE;
	bool        is_parser = false;
	int         is_EOF;
	wchar_t     bom[1] = { BOM };
	bool        is_xml_declare = false;  /* <?xml ... ?> */
	enum XML_Status  xs;
	ParseXML2_ConfigClass*  config = in_out_Config;
	ParseXML2_ConfigClass   default_config;
	ParseXML2_WorkClass     work_x;
	ParseXML2_WorkClass*    work = &work_x;
	TCHAR    line[4096];

	Set2_initConst( &work->XPath );
	Set2_initConst( &work->XPathLengths );
	StrFile_initConst( &work->TextBuffer );


	/* Set "config" */
	if ( config == NULL )  { config = &default_config; }
	if ( ! ( config->Flags & F_ParseXML2_Delegate ) )        { config->Delegate = NULL; }
	if ( ! ( config->Flags & F_ParseXML2_OnStartElement ) )  { config->OnStartElement = DefaultFunction; }
	if ( ! ( config->Flags & F_ParseXML2_OnEndElement ) )    { config->OnEndElement = DefaultFunction; }
	if ( ! ( config->Flags & F_ParseXML2_OnText ) )          { config->OnText = DefaultFunction; }

	/* Set "work" */
	work->Status.Delegate = config->Delegate;
	work->Status.LineNum = 0;
	work->Status.Depth = -1;
	work->Status.PreviousCallbackType = 0;
	work->Status.TagName = NULL;
	work->Status.u.OnStartElement.Attributes = NULL;
	work->OnStartElement = config->OnStartElement;
	work->OnEndElement   = config->OnEndElement;
	work->OnText         = config->OnText;
	work->e = 0;

	/* Set "work->XPath", "work->XPathLengths" */
	{
		TCHAR*  xpath;

		e= Set2_init( &work->XPath, MAX_PATH * sizeof(TCHAR) ); IF(e)goto fin;
		e= Set2_init( &work->XPathLengths, 10 * sizeof(int) ); IF(e)goto fin;
		xpath = (TCHAR*) work->XPath.First;

		xpath[0] = _T('/');
		xpath[1] = _T('\0');
	}

	/* Set "work->TextBuffer" */
	e= StrFile_init_toHeap( &work->TextBuffer, 0 );
	work->TextStartLineNum = 0;

	/* Set "parser" */
	parser = XML_ParserCreate( NULL );
	is_parser = true;
	XML_SetUserData( parser, work );
	XML_SetElementHandler( parser, ParseXML2_onStartElement, ParseXML2_onEndElement );
	XML_SetCharacterDataHandler( parser, ParseXML2_onText );

	/* Parse BOM */
	xs= XML_Parse( parser, (char*)bom, sizeof(bom), 0 );
		IF( xs == XML_STATUS_ERROR ) goto err_ex;


	/* Loop of lines of XML file */
	e= FileT_openForRead( &file, XML_Path ); IF(e)goto fin;
	for (;;) {
		line[0] = _T('\0');
		_fgetts( line, _countof(line), file );
		is_EOF = feof( file );
		work->Status.LineNum += 1;

		/* _fgetts が UTF-16 に文字列を統一し、それを XML_Parser に渡すため、*/
		/*  <?xml encoding="UTF-16" ?> に変更する */
		if ( ! is_xml_declare ) {
			e= ParseXML2_makeXML_Declare_Sub( parser, work, XML_Path, line, &is_xml_declare );
				IF(e)goto fin;
		}

		/* Parse XML */
		xs= XML_Parse( parser, (char*)line, _tcslen( line ) * sizeof(TCHAR), is_EOF );
			IF( xs == XML_STATUS_ERROR ) goto err_ex;
			IF( work->e != 0 )  { e = work->e;  goto fin; }
		if ( is_EOF )  { break; }
	}
	e=0;
fin:
	if ( is_parser )  { XML_ParserFree( parser ); }
	e= FileT_close( file, e );
	e= StrFile_finish( &work->TextBuffer, e );
	e= Set2_finish( &work->XPath, e );
	e= Set2_finish( &work->XPathLengths, e );
	return  e;

err_ex:  Expat_printfToError4( parser, XML_Path );  e= E_XML_PARSER;  goto fin;
}


/*[ParseXML2_makeXML_Declare_Sub]*/
static errnum_t  ParseXML2_makeXML_Declare_Sub( XML_Parser parser, ParseXML2_WorkClass* work,
	const TCHAR* XML_Path, TCHAR* line, bool* is_xml_declare )
{
	errnum_t  e;
	TCHAR*    p;
	TCHAR*    str = NULL;
	enum XML_Status  xs;

	UNREFERENCED_VARIABLE( work );

	if ( _tcschr( line, _T('<') ) > 0 ) {
		if ( _tcsstr( line, _T("<?") ) > 0 ) {
			bool  is_replaced = false;

			{
				static const TCHAR*  enc_sjis       = _T("encoding=\"Shift_JIS\"");
				static const TCHAR*  enc_sjis_utf16 = _T("encoding=\"UTF-16\"   ");

				p = _tcsstr( line, enc_sjis );
				if ( p != NULL ) {
					memcpy( p, enc_sjis_utf16, _tcslen( enc_sjis_utf16 ) * sizeof(TCHAR) );
					is_replaced = true;
				}
			}
			if ( ! is_replaced ) {
				static const TCHAR*  enc_utf8       = _T("encoding=\"UTF-8\"");
				static const TCHAR*  enc_utf8_utf16 = _T("encoding=\"UTF-16\"");
				size_t  str_size;

				p = _tcsstr( line, enc_utf8 );
				if ( p != NULL ) {
					str_size = ( _tcslen( line ) + 2 ) * sizeof(TCHAR);
					str = (TCHAR*) malloc( str_size ); IF(str==NULL) goto err_fm;

					e= StrT_replace( str,  str_size,  line, enc_utf8,  enc_utf8_utf16, 0 );
						IF(e)goto fin;

					xs= XML_Parse( parser, (char*)str, _tcslen( str ) * sizeof(TCHAR), 0 );
						IF( xs == XML_STATUS_ERROR ) goto err_ex;

					line[0] = _T('\0');
					*is_xml_declare = true;
					e=0;
					goto fin;
				}
			}
		}
		else {
			static const TCHAR*  xml_declare = _T("<?xml version=\"1.0\" encoding=\"UTF-16\"?>\r\n");

			XML_Parse( parser, (char*)xml_declare, _tcslen( xml_declare ) * sizeof(TCHAR), 0 );
			*is_xml_declare = true;
			e=0;
			goto fin;
		}
	}
	if ( _tcsstr( line, _T("?>") ) != NULL ) {
		*is_xml_declare = true;
	}

	e=0;
fin:
	if ( str != NULL )  { free( str ); }
	return  e;

err_fm:  e = E_FEW_MEMORY;  goto fin;
err_ex:  Expat_printfToError4( parser, XML_Path );  e= E_XML_PARSER;  goto fin;
}


/*[Expat_printfToError4]*/
static void  Expat_printfToError4( XML_Parser parser, const TCHAR* XML_Path )
{
	Error4_printf( _T("<ERROR msg=\"%s\" file=\"%s(%lu)\"/>\n"),
		XML_ErrorString( XML_GetErrorCode( parser ) ),
		XML_Path,
		XML_GetCurrentLineNumber(parser) );
}


/*[ParseXML2_onStartElement]*/
static void  ParseXML2_onStartElement( void* UserData, const XML_Char* Name, const XML_Char** Atts )
{
	ParseXML2_WorkClass*  work = (ParseXML2_WorkClass*) UserData;
	TCHAR*    xpath = (TCHAR*) DUMMY_INITIAL_VALUE;
	int*      xpath_lengths;
	int       old_depth = work->Status.Depth;
	int       new_depth = work->Status.Depth + 1;

	if ( work->e != 0 )  return;


	/* Call "work->OnText" */
	if ( work->OnText != DefaultFunction )
		{ ParseXML2_callOnText( work ); }


	/* Set "work->XPath" : Add "Name" */
	{
		errnum_t  e;
		int       old_xpath_length;
		int       name_length = _tcslen( Name );


		/* Set "old_xpath_length" */
		xpath_lengths = (int*) work->XPathLengths.First;
		if ( old_depth >= 0 )
			{ old_xpath_length = xpath_lengths[ old_depth ]; }
		else
			{ old_xpath_length = 0; }  /* Length("/") == 1, But 0 for next operation */

		/* Add "Name" to "work->XPath" */
		e= Set2_expandIfOverByOffset( &work->XPath,
			( old_xpath_length + name_length + 2 ) * sizeof(TCHAR) );
			IF(e)goto fin2;
		xpath = (TCHAR*) work->XPath.First;
		xpath[ old_xpath_length ] = _T('/');
		memcpy( &xpath[ old_xpath_length + 1 ],  Name,  name_length * sizeof(TCHAR) );
		xpath[ old_xpath_length + 1 + name_length ] = _T('\0');

		/* "work->XPathLengths[]" = new XPath length */
		e= Set2_expandIfOverByOffset( &work->XPathLengths, ( new_depth + 1 ) * sizeof(int) );
			IF(e)goto fin2;
		xpath_lengths = (int*) work->XPathLengths.First;
		xpath_lengths[ new_depth ] = old_xpath_length + 1 + name_length;

		e=0;
	fin2:
		if (e) {
			work->e = e;
			return;
		}
	}


	/* Call "work->OnStartElement" */
	work->Status.XPath = xpath;
	if ( old_depth >= 0 )
		{ work->Status.TagName = &xpath[ xpath_lengths[ old_depth ] + 1 ]; }
	else
		{ work->Status.TagName = &xpath[ 1 ]; }
	work->Status.u.OnStartElement.Attributes = Atts;
	work->Status.Depth += 1;

	work->e = work->OnStartElement( &work->Status );

	work->Status.u.OnStartElement.Attributes = NULL;

	work->Status.PreviousCallbackType = F_ParseXML2_OnStartElement;
}


/*[ParseXML2_onEndElement]*/
static void  ParseXML2_onEndElement( void* UserData, const XML_Char* Name )
{
	ParseXML2_WorkClass*  work = (ParseXML2_WorkClass*) UserData;
	TCHAR*  xpath = (TCHAR*) work->XPath.First;
	int*    xpath_lengths = (int*) work->XPathLengths.First;
	int     new_depth = work->Status.Depth - 1;

	UNREFERENCED_VARIABLE( Name );

	if ( work->e != 0 )  return;

	if ( new_depth >= 0 )
		{ work->Status.TagName = &xpath[ xpath_lengths[ new_depth ] + 1 ]; }
	else
		{ work->Status.TagName = &xpath[ 1 ]; }


	/* Call "work->OnText" */
	if ( work->OnText != DefaultFunction )
		{ ParseXML2_callOnText( work ); }


	/* Call "work->OnEndElement" */
	work->e = work->OnEndElement( &work->Status );
	work->Status.Depth -= 1;


	/* Set "work->XPath" : Remove "Name" */
	if ( new_depth >= 0 ) {
		xpath[ xpath_lengths[ new_depth ] ] = _T('\0');
		if ( new_depth - 1 >= 0 )
			{ work->Status.TagName = &xpath[ xpath_lengths[ new_depth - 1 ] + 1 ]; }
		else
			{ work->Status.TagName = &xpath[ 1 ]; }
	}
	else {
		xpath[ 1 ] = _T('\0');  /* xpath = "/" */
		work->Status.TagName = &xpath[ 0 ];
	}

	work->Status.PreviousCallbackType = F_ParseXML2_OnEndElement;
}


/*[ParseXML2_onText]*/
static void  ParseXML2_onText( void* UserData, const XML_Char* Text, int TextLength )
{
	ParseXML2_WorkClass*  work = (ParseXML2_WorkClass*) UserData;

	if ( work->e != 0 )  return;

	if ( work->OnText != DefaultFunction ) {

		#if 1
			work->e = StrFile_writeBinary( &work->TextBuffer, Text, TextLength * sizeof(TCHAR) );

			if ( work->TextStartLineNum == 0 )
				{ work->TextStartLineNum = work->Status.LineNum; }
		#else
			work->Status.u.OnText.Text = Text;
			work->Status.u.OnText.TextLength = TextLength;

			work->e = work->OnText( &work->Status );

			work->Status.u.OnText.Text = NULL;
			work->Status.u.OnText.TextLength = 0;

			work->Status.PreviousCallbackType = F_ParseXML2_OnText;
		#endif
	}
}


/*[ParseXML2_callOnText]*/
static void  ParseXML2_callOnText( ParseXML2_WorkClass* work )
{
	if ( work->TextStartLineNum != 0 ) {
		int  line_num_back_up = work->Status.LineNum;

		work->Status.u.OnText.Text = work->TextBuffer.Buffer;
		work->Status.u.OnText.TextLength = (TCHAR*) work->TextBuffer.Pointer -
			(TCHAR*) work->TextBuffer.Buffer;
		work->Status.LineNum = work->TextStartLineNum;

		work->e = work->OnText( &work->Status );

		if ( work->e == 0 ) {
			work->e = StrFile_setPointer( &work->TextBuffer, 0 );
				IF( work->e ) __noop();
		}
		work->Status.LineNum = line_num_back_up;
		work->TextStartLineNum = 0;
		work->Status.PreviousCallbackType = F_ParseXML2_OnText;
	}
}


 
/***********************************************************************
  <<< [AppKey] >>> 
************************************************************************/
static errnum_t  AppKey_create( AppKey** out_m );
static bool      AppKey_isSame( AppKey* m );
static void      Writables_initConst( Writables* m );
static errnum_t  Writables_init( Writables* m, AppKey* Key );
static errnum_t  Writables_finish( Writables* m, int e );
static bool      Writables_isInited( Writables* m );
static errnum_t  Writables_clearPaths( Writables* m );
static errnum_t  Writables_create( Writables** out_m, AppKey* Key );
static errnum_t  Writables_copyToConst( Writables* To, Writables* From );


typedef struct _CurrentWritables  CurrentWritables;
struct _CurrentWritables {
	Writables  m_CurrentWritables;
	TCHAR*   m_ProgramFiles;  size_t  m_ProgramFiles_Len;
	TCHAR*   m_windir;        size_t  m_windir_Len;
	TCHAR*   m_APPDATA;       size_t  m_APPDATA_Len;
	TCHAR*   m_LOCALAPPDATA;  size_t  m_LOCALAPPDATA_Len;
};
static void      CurrentWritables_initConst( CurrentWritables* m );
static errnum_t  CurrentWritables_init( CurrentWritables* m );
static errnum_t  CurrentWritables_finish( CurrentWritables* m, int e );
static errnum_t  CurrentWritables_askFileAccess( CurrentWritables* m, const TCHAR* FullPath );


//////////////////////////////

static  AppKey   g_AppKey;
static  AppKey*  g_AppKeyPrivate;

// under g_AppKey
Writables  g_DefaultWritables;
Writables  g_CurrentWritables; // public
static CurrentWritables  g_CurrentWritablesPrivate;


static errnum_t  AppKey_create( AppKey** out_m )
{
	errnum_t  e;

	IF( g_AppKeyPrivate != NULL ) { e=1; goto fin; }
		// AppKey_newWritable の in_out_m = NULL のときは、2回呼び出すことはできません。

	Writables_initConst( &g_DefaultWritables );
	CurrentWritables_initConst( &g_CurrentWritablesPrivate );

	e= CurrentWritables_init( &g_CurrentWritablesPrivate ); IF(e)goto fin;
	e= Writables_copyToConst( &g_CurrentWritables, NULL ); IF(e)goto fin;

	*out_m = &g_AppKey;
	g_AppKeyPrivate = &g_AppKey;

	e=0;
fin:
	return  e;
}


static bool  AppKey_isSame( AppKey* m )
{
	return  ( m == g_AppKeyPrivate );
}


void  AppKey_initGlobal_const()
{
	Writables_initConst( &g_DefaultWritables );
}


errnum_t  AppKey_finishGlobal( errnum_t e )
{
	errnum_t  ee;

	e= Writables_finish( &g_DefaultWritables, e );
	e= CurrentWritables_finish( &g_CurrentWritablesPrivate, e );
	ee= Writables_copyToConst( &g_CurrentWritables, NULL ); IF(ee&&!e)e=ee;

	return  e;
}


 
/***********************************************************************
  <<< [AppKey_newWritable_Sub] >>> 
************************************************************************/
errnum_t  AppKey_newWritable_Sub( AppKey** in_out_m,  Writables** out_Writable,
	va_list  va,
	TCHAR**  in_Paths,  int  in_PathCount )
{
	errnum_t    e;
	AppKey*     m = NULL;
	Writables*  wr = NULL;
#if Uses_OutMallocIDTool
	bool  is_prev_out_malloc;

	is_prev_out_malloc = OutMallocID_setEnable( false );
#endif


	//=== AppKey* m を有効にする
	if ( in_out_m == NULL ) {  // 今回の関数の中だけで参照する
		e= AppKey_create( &m ); IF(e)goto resume;
	}
	else if ( *in_out_m == NULL ) {  // １回目に本関数を呼び出したモジュールに渡す
		e= AppKey_create( &m ); IF(e)goto resume;
		*in_out_m = m;
	}
	else {  // 本関数を呼び出したモジュールから渡ったものを使う
		m = *in_out_m;
	}


	//=== 正規の AppKey かチェックする
	IF( ! AppKey_isSame( m ) )goto err;


	//=== Writable を生成する
	if ( out_Writable == NULL ) {
		wr = &g_DefaultWritables;
		e= Writables_finish( wr, 0 ); IF(e)goto resume;
		e= Writables_init( wr, m ); IF(e)goto resume;
	}
	else {
		e= Writables_create( &wr, m ); IF(e)goto resume;
		*out_Writable = wr;
	}


	//=== Writable にパスを登録する
	if ( in_Paths == NULL ) {
		TCHAR*   path;
		int  i;

		for ( i=0; ; i++ ) {
			path = va_arg( va, TCHAR* );
			if ( path == NULL )  break;
			IF( i == 5 ) goto err;  // 最後の NULL 忘れ対策

			e= Writables_add( wr, m, path ); IF(e)goto resume;
		}
	}
	else {
		int  i;

		for ( i = 0;  i < in_PathCount;  i += 1 ) {
			e= Writables_add( wr, m, in_Paths[i] ); IF(e){goto fin;}
		}
	}

	#if defined(TempFile_get)
	{
		TempFile*   temp;

		e= TempFile_get( &temp ); IF(e)goto resume;
		e= Writables_add( wr, m, temp->TempPath ); IF(e)goto resume;
	}
	#endif


	//=== すぐに Writable を有効にする
	if ( out_Writable == NULL ) {
		e= Writables_enable( wr ); IF(e)goto resume;
	}

	e=0;
fin:
	#if Uses_OutMallocIDTool
		OutMallocID_setEnable( is_prev_out_malloc );
	#endif
	return  e;

err:  e = E_OTHERS;  goto resume;
resume:
	if ( wr != NULL ) {
		if ( out_Writable == NULL )
			e= Writables_finish( wr, e );  // g_DefaultWritables
		else
			e= Writables_delete( wr, e );
	}
	goto fin;
}


 
/***********************************************************************
  <<< [AppKey_newWritable] >>> 
************************************************************************/
errnum_t  AppKey_newWritable( AppKey** in_out_m,  Writables** out_Writable,  ... )
{
	errnum_t  e;
	va_list  va;

	va_start( va, out_Writable );
	e = AppKey_newWritable_Sub( in_out_m,  out_Writable,  va,  NULL,  0 );
	va_end( va );

	return  e;
}


 
/***********************************************************************
  <<< [AppKey_newWritable_byArray] >>> 
************************************************************************/
errnum_t  AppKey_newWritable_byArray( AppKey** in_out_m,  Writables** out_Writable,
	TCHAR**  in_Paths,  int  in_PathCount )
{
	IF ( in_Paths == NULL ) {
		return  E_OTHERS;
	} else {
		return  AppKey_newWritable_Sub( in_out_m,  out_Writable,  NULL,
			in_Paths,  in_PathCount );
	}
}


 
/***********************************************************************
  <<< [AppKey_addNewWritableFolder] チェックする、または追加する >>> 
************************************************************************/
errnum_t  AppKey_addNewWritableFolder_Sub( const TCHAR* Path, bool* out_IsWritable );

errnum_t  AppKey_addNewWritableFolder( const TCHAR* Path )
{
	errnum_t  e;
	bool  is_writable;

	e= AppKey_addNewWritableFolder_Sub( Path, &is_writable ); IF(e){goto fin;}
	IF ( ! is_writable ) { e=E_OUT_OF_WRITABLE; goto fin; }
		// Path (abs_path) は、AppKey_newWritable で許可されていません。
		// ウォッチ・ウィンドウに g_CurrentWritables.m_Paths,3 などを入力して
		// 許可されているパスを確認してください。

	e=0;
fin:
	return  e;
}

errnum_t  AppKey_addNewWritableFolder_Sub( const TCHAR* Path, bool* out_IsWritable )
{
	errnum_t    e;
	TCHAR**     pp;
	TCHAR**     pp_over;
	Writables*  wr = &g_CurrentWritablesPrivate.m_CurrentWritables;
	size_t      path_len;
	TCHAR       abs_path[MAX_PATH];

	*out_IsWritable = true;

	if ( g_AppKeyPrivate == NULL ) {
		e= AppKey_newWritable( NULL, NULL, ".", NULL ); IF(e){goto fin;}
	}

	e= StrT_getFullPath( abs_path, sizeof(abs_path), Path, NULL ); IF(e){goto fin;}

	pp_over = wr->m_Paths + wr->m_nPath;
	for ( pp = wr->m_Paths;  ;  pp++ ) {
		if ( pp >= pp_over ) {
			*out_IsWritable = false;
			break;
		}
		path_len = _tcslen( *pp );
		if ( _tcsnicmp( *pp, abs_path, path_len ) == 0 &&
			( abs_path[ path_len ] == _T('\\') || abs_path[ path_len ] == _T('\0') ) )
		{
			break;
		}
	}

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [AppKey_addWritableFolder] チェックしないで、追加する >>> 
************************************************************************/
errnum_t  AppKey_addWritableFolder( AppKey* m, const TCHAR* Path )
{
	errnum_t    e;
	Writables*  wr = &g_CurrentWritablesPrivate.m_CurrentWritables;
	bool        is_writable;

	e= AppKey_addNewWritableFolder_Sub( Path, &is_writable ); IF(e){goto fin;}
	if ( ! is_writable ) {
		e= Writables_add( wr, m, Path ); IF(e){goto fin;}
	}

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [AppKey_checkWritable] >>> 
************************************************************************/
errnum_t  AppKey_checkWritable( const TCHAR* Path )
{
	return  AppKey_addNewWritableFolder( Path );
}


 
/***********************************************************************
  <<< [Writables_init] >>> 
************************************************************************/
static void  Writables_initConst( Writables* m )
{
	m->m_Paths = NULL;
	m->m_nPath = -1;
}


static errnum_t  Writables_init( Writables* m, AppKey* Key )
{
	IF( ! AppKey_isSame( Key ) ) return E_OTHERS;

	m->m_Paths = NULL;
	m->m_nPath = 0;
	return  0;
}


static errnum_t  Writables_finish( Writables* m, int e )
{
	errnum_t  ee;

	ee= Writables_clearPaths( m ); IF(ee&&!e) e=ee;
	m->m_nPath = -1;
	return  e;
}


static bool  Writables_isInited( Writables* m )
{
	return  ( m->m_nPath != -1 );
}


static errnum_t  Writables_clearPaths( Writables* m )
{
	TCHAR**  p;
	TCHAR**  p_over;

	if ( m->m_Paths != NULL ) {
		p_over = m->m_Paths + m->m_nPath;
		for ( p = m->m_Paths;  p < p_over;  p++ ) {
			free( *p );
		}
		free( m->m_Paths );  m->m_Paths = NULL;
	}
	m->m_nPath = 0;
	return  0;
}


static errnum_t  Writables_create( Writables** out_m, AppKey* Key )
{
	errnum_t    e;
	Writables*  m;

	m = (Writables*) malloc( sizeof(*m) ); IF(m==NULL)return E_FEW_MEMORY;
	Writables_initConst( m );
	e= Writables_init( m, Key ); IF(e)goto resume;
	*out_m = m;
	return  0;
resume: Writables_delete( m, 0 ); free(m); return  e;
}


errnum_t  Writables_delete( Writables* m, errnum_t e )
{
	if ( m == NULL ) goto fin;
	e= Writables_finish( m, e );
	free( m );
fin:
	return  e;
}


 
/***********************************************************************
  <<< [Writables_add] >>> 
************************************************************************/
int  Writables_add( Writables* m, AppKey* Key, const TCHAR* Path )
{
	int  e;
	TCHAR**   pp;
	TCHAR*    p  = NULL;
	size_t    path_size;
	TCHAR     abs_path[MAX_PATH];

	IF( ! AppKey_isSame( Key ) )goto err;
	if ( Path[0] == _T('\0') ) return 0;

	e= StrT_getFullPath( abs_path, sizeof(abs_path), Path, NULL ); IF(e)goto resume;

	e= CurrentWritables_askFileAccess( &g_CurrentWritablesPrivate, abs_path ); IF(e)goto resume;

	pp = (TCHAR**) realloc( m->m_Paths, (m->m_nPath + 1) * sizeof(TCHAR*) );
	IF( pp == NULL ) goto err;
	m->m_Paths = pp;

	path_size = (_tcslen( abs_path ) + 1) * sizeof(TCHAR);
	p = (TCHAR*) malloc( path_size );
	m->m_Paths[ m->m_nPath ] = p;
	IF( p == NULL )goto err;

	memcpy( p, abs_path, path_size );
	if ( p[ path_size/sizeof(TCHAR) - 2 ] == _T('\\') )
			 p[ path_size/sizeof(TCHAR) - 2 ] =  _T('\0');
	m->m_nPath ++;

	e=0;
fin:
	return  e;

err:  e = E_OTHERS;  goto resume;
resume:
	if ( p != NULL )  free( p );
	goto fin;
}


int  Writables_remove( Writables* m, const TCHAR* Path )
{
	TCHAR**  pp;
	TCHAR**  pp_over;

	pp_over = m->m_Paths + m->m_nPath;
	for ( pp = m->m_Paths;  ;  pp++ ) {
		if ( pp >= pp_over )  return  0;
		if ( _tcscmp( *pp, Path ) == 0 )  break;
	}
	free( *pp );
	memmove( pp, pp+1, (char*)pp - (char*)pp_over - sizeof(TCHAR) );
	m->m_nPath --;

	#if _DEBUG
		*( pp_over - 1 ) = NULL;
	#endif

	return  0;
}


 
/***********************************************************************
  <<< [Writables_enable] >>> 
************************************************************************/
int  Writables_enable( Writables* m )
{
	int  e;

	e= Writables_copyToConst( &g_CurrentWritablesPrivate.m_CurrentWritables, m ); IF(e)goto fin;
	e= Writables_copyToConst( &g_CurrentWritables, &g_CurrentWritablesPrivate.m_CurrentWritables ); IF(e)goto fin;

	e=0;
fin:
	return  e;
}


int  Writables_disable( Writables* m, int e )
{
	int  ee;

	UNREFERENCED_VARIABLE( m );

	ee= Writables_copyToConst( &g_CurrentWritablesPrivate.m_CurrentWritables, NULL ); IF(ee&&!e)goto fin;
	ee= Writables_copyToConst( &g_CurrentWritables, NULL ); IF(ee&&!e)goto fin;

	e=0;
fin:
	return  e;
}


static int  Writables_copyToConst( Writables* To, Writables* From )
{
	int  e;
	TCHAR**  pp;
	TCHAR**  pp_over;
	TCHAR*   p2;
	TCHAR**  pp2;
	size_t   path_size;

	if ( To->m_Paths != NULL ) {
		free( To->m_Paths );
		To->m_Paths = NULL;
		To->m_nPath = 0;
	}

	if ( From != NULL && From->m_nPath > 0 ) {

		path_size = 0;
		pp_over = From->m_Paths + From->m_nPath;
		for ( pp = From->m_Paths;  pp < pp_over;  pp++ ) {
			path_size += _tcslen( *pp ) + 1;
		}

		path_size = From->m_nPath * sizeof(TCHAR*) + path_size * sizeof(TCHAR);
		To->m_Paths = (TCHAR**) malloc( path_size );
		IF( To->m_Paths == NULL ) goto err;

		p2 = (TCHAR*)( (char*)To->m_Paths + From->m_nPath * sizeof(TCHAR*) );
		pp2 = To->m_Paths;
		for ( pp = From->m_Paths;  pp < pp_over;  pp++ ) {
			*pp2 = p2;
			path_size = (_tcslen( *pp ) + 1) * sizeof(TCHAR);
			memcpy( p2, *pp, path_size );
			p2 = (TCHAR*)( (char*)p2 + path_size );
			pp2 ++;
		}
		To->m_nPath = From->m_nPath;
	}

	e=0;
fin:
	return  e;

err:  e = E_OTHERS;  goto fin;
}

 
/***********************************************************************
  <<< [CurrentWritables] >>> 
************************************************************************/
static void  CurrentWritables_initConst( CurrentWritables* m )
{
	Writables_initConst( &m->m_CurrentWritables );
	m->m_ProgramFiles = NULL;
	m->m_windir = NULL;
	m->m_APPDATA = NULL;
	m->m_LOCALAPPDATA = NULL;
}


static int  CurrentWritables_init( CurrentWritables* m )
{
	int    e;
 #if Uses_OutMallocIDTool
	bool  is_prev_out_malloc;

	is_prev_out_malloc = OutMallocID_setEnable( false );
 #endif

	e= Writables_copyToConst( &m->m_CurrentWritables, NULL ); IF(e)goto fin;

	e= env_malloc( &m->m_ProgramFiles, &m->m_ProgramFiles_Len, _T("ProgramFiles") ); IF(e)goto fin;
	e= env_malloc( &m->m_windir,       &m->m_windir_Len,       _T("windir") ); IF(e)goto fin;
	e= env_malloc( &m->m_APPDATA,      &m->m_APPDATA_Len,      _T("APPDATA") ); IF(e)goto fin;
	// e= env_malloc( &m->m_LOCALAPPDATA, &m->m_LOCALAPPDATA_Len, _T("LOCALAPPDATA") ); IF(e)goto fin;

	e=0;
fin:
 #if Uses_OutMallocIDTool
	OutMallocID_setEnable( is_prev_out_malloc );
 #endif
	return  e;
}


static int  CurrentWritables_finish( CurrentWritables* m, int e )
{
	int  ee;

	ee= Writables_copyToConst( &m->m_CurrentWritables, NULL ); IF(ee&&!e)e=ee;

	if ( m->m_ProgramFiles != NULL )  free( m->m_ProgramFiles );
	if ( m->m_windir != NULL )        free( m->m_windir );
	if ( m->m_APPDATA != NULL )       free( m->m_APPDATA );
	if ( m->m_LOCALAPPDATA != NULL )  free( m->m_LOCALAPPDATA );

	m->m_ProgramFiles = NULL;
	m->m_windir = NULL;
	m->m_APPDATA = NULL;
	m->m_LOCALAPPDATA = NULL;

	return  e;
}


static int  CurrentWritables_askFileAccess_sub(
	const TCHAR* SystemPath,  size_t SystemPath_Len,  const TCHAR* FullPath, size_t FullPath_Len );

static int  CurrentWritables_askFileAccess( CurrentWritables* m, const TCHAR* FullPath )
{
	int  e;
	size_t  abs_len;

	abs_len = _tcslen( FullPath );
	e= CurrentWritables_askFileAccess_sub( m->m_ProgramFiles, m->m_ProgramFiles_Len, FullPath, abs_len ); IF(e)goto fin;
	e= CurrentWritables_askFileAccess_sub( m->m_windir,       m->m_windir_Len,       FullPath, abs_len ); IF(e)goto fin;
	e= CurrentWritables_askFileAccess_sub( m->m_APPDATA,      m->m_APPDATA_Len,      FullPath, abs_len ); IF(e)goto fin;
	e= CurrentWritables_askFileAccess_sub( m->m_LOCALAPPDATA, m->m_LOCALAPPDATA_Len, FullPath, abs_len ); IF(e)goto fin;

	e=0;
fin:
	return  e;
}


static int  CurrentWritables_askFileAccess_sub(
	const TCHAR* SystemPath,  size_t SystemPath_Len,  const TCHAR* FullPath, size_t FullPath_Len )
{
	if ( SystemPath == NULL )  return  0;

	IF ( _tcsncmp( SystemPath, FullPath, SystemPath_Len ) == 0 )
		return  E_OUT_OF_WRITABLE;  // システムフォルダの中を書き込み許可しようとしている

	IF ( _tcsncmp( SystemPath, FullPath, FullPath_Len ) == 0 )
		return  E_OUT_OF_WRITABLE;  // システムフォルダを含めて許可書き込み許可しようとしている

	return  0;
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


//[MergeError]
errnum_t  MergeError( errnum_t e, errnum_t ee )
{
	if ( e == 0 ) { return  ee; }
	else          { /* ErrorLog_add( ee ); */ return  e; }
}


 
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
			str_pointer = StrT_chr( str_pointer, _T('\0') );
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
	Error4_showToStdIO( stderr, err_num );
}


 
/***********************************************************************
  <<< [Error4_showToStdIO] >>> 
************************************************************************/
void  Error4_showToStdIO( FILE* out, int err_num )
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
			fprintf( out, "%s\n", msg2 );  // _ftprintf_s では日本語が出ません
		#else
			fprintf( out, "%s\n", msg );
		#endif

		#if ERR2_ENABLE_ERROR_BREAK
			fprintf( out, "（開発者へ）メイン関数で SetBreakErrorID( %d ); を呼び出してください。\n",
				g_Err2.ErrID );
		#else
#if 0
			if ( err_num == E_FEW_MEMORY  ||  gs.WindowsLastError == ERROR_NOT_ENOUGH_MEMORY ) {
				/* Not show the message for developper */
			}
			else {
				fprintf( out, "（開発者へ）ERR2_ENABLE_ERROR_BREAK を定義して再コンパイルしてください。\n" );
			}
#endif
		#endif
	}
	IfErrThenBreak();
}


 
/*=================================================================*/
/* <<< [CRT_plus_2/CRT_plus_2.c] >>> */ 
/*=================================================================*/
 
/**************************************************************************
 <<< [Interface] >>> 
***************************************************************************/

/*[DefaultFunction]*/
errnum_t  DefaultFunction( void* self )
{
	UNREFERENCED_VARIABLE( self );
	return  0;
}

/*[DefaultFunction_NotImplementYet]*/
errnum_t  DefaultFunction_NotImplementYet( void* self )
{
	UNREFERENCED_VARIABLE( self );
	return  E_NOT_IMPLEMENT_YET;
}

/*[DefaultFunction_Finalize]*/
errnum_t  DefaultFunction_Finalize( void* self, errnum_t e )
{
	UNREFERENCED_VARIABLE( self );
	return  e;
}

/*[VTableDefine_overwrite]*/
errnum_t  VTableDefine_overwrite( VTableDefine* aVTable, size_t aVTable_ByteSize, int iMethod, void* Func )
{
	VTableDefine*  p = aVTable;
	VTableDefine*  p_over = (VTableDefine*)( (char*)aVTable + aVTable_ByteSize );

	for ( ; p < p_over; p++ ) {
		if ( p->m_IMethod == iMethod ) {
			p->m_method = Func;
			return  0;
		}
	}
	return  E_NOT_FOUND_SYMBOL;
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
  <<< [StrT_chr] >>> 
************************************************************************/
TCHAR*  StrT_chr( const TCHAR* String, TCHAR Key )
{
	const TCHAR*  return_value = _tcschr( String, Key );

	if ( return_value == NULL  &&  Key == _T('\0') ) {
		return_value = String + _tcslen( String );
	}

	return  (TCHAR*) return_value;
}

 
/***********************************************************************
  <<< [StrT_chrNext] >>> 
************************************************************************/
TCHAR*  StrT_chrNext( const TCHAR* in_Start, TCHAR in_KeyCharactor )
{
	const TCHAR*  p = _tcschr( in_Start, in_KeyCharactor );

	if ( p != NULL )
		{ p += 1; }

	return  (TCHAR*) p;
}

 
/***********************************************************************
  <<< [CharPointerArray_free] >>> 
************************************************************************/
errnum_t  CharPointerArray_free( TCHAR*** in_out_Strings,  int  in_StringCount,
	bool  in_IsFreePointers,  errnum_t  e )
{
	TCHAR**  strings = *in_out_Strings;
	int      i;

	for ( i = 0;  i < in_StringCount;  i += 1 ) {
		e= HeapMemory_free( &strings[i], e );
	}

	if ( in_IsFreePointers ) {
		e= HeapMemory_free( in_out_Strings, e );
	}

	return  e;
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
	ASSERT_D( CountOfCharacter < 0x7FFFFFFF, __noop() );

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
TCHAR*  StrT_skip( const TCHAR* String, const TCHAR* Keys )
{
	if ( *Keys == _T('\0') ) { return  (TCHAR*) String; }

	for ( ; *String != _T('\0'); String += 1 ) {
		if ( _tcschr( Keys, *String ) == NULL )
			break;
	}
	return  (TCHAR*) String;
}


 
/***********************************************************************
  <<< [StrT_rskip] >>> 
************************************************************************/
TCHAR*  StrT_rskip( const TCHAR* String, const TCHAR* SearchStart, const TCHAR* Keys,
	void* NullConfig )
{
	const TCHAR*  pointer;

	UNREFERENCED_VARIABLE( NullConfig );

	if ( *Keys == _T('\0') ) { return  (TCHAR*) SearchStart; }

	for ( pointer = SearchStart;  pointer >= String;  pointer -= 1 ) {
		if ( _tcschr( Keys, *pointer ) == NULL )
			{ return  (TCHAR*) pointer; }
	}
	return  NULL;
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

	for ( p = Text;
		StrT_isCIdentifier( *p );
		p += 1 )
	{
	}
	return  (TCHAR*) p;
}


 
/***********************************************************************
  <<< [StrT_searchOverOfIdiom] >>> 
************************************************************************/
TCHAR*  StrT_searchOverOfIdiom( const TCHAR* Text )
{
	const TCHAR*  p;

	p = Text;
	for ( p = Text;
		StrT_isCIdentifier( *p )  ||  *p == _T(' ');
		p += 1 )
	{
	}

	for ( p -= 1;
		*p == _T(' ')  &&  p >= Text;
		p -= 1 )
	{
	}

	return  (TCHAR*) p + 1;
}


 
/***********************************************************************
  <<< [StrT_convPartStrToPointer] >>> 
************************************************************************/
void*  StrT_convPartStrToPointer( const TCHAR* StringStart, const TCHAR* StringOver,
	const NameOnlyClass* Table, size_t TableSize, void* Default )
{
	const NameOnlyClass*  p = Table;
	const NameOnlyClass*  p_over = (const NameOnlyClass*)( (uint8_t*) Table + TableSize );

	while ( p < p_over ) {
		if ( StrT_cmp_part( StringStart, StringOver, p->Name ) == 0 ) {
			return  (void*) p->Delegate;
		}
		p += 1;
	}
	return  Default;
}


 
/***********************************************************************
  <<< [StrT_convertNumToStr] >>> 
************************************************************************/
TCHAR*  StrT_convertNumToStr( int Number, const NameAndNumClass* Table, int TableCount,
	const TCHAR* DefaultStr )
{
	const NameAndNumClass*  p;
	const NameAndNumClass*  p_over = Table + TableCount;

	for ( p = Table;  p < p_over;  p += 1 ) {
		if ( p->Number == Number ) {
			return  p->Name;
		}
	}
	return  (TCHAR*) DefaultStr;
}


 
/***********************************************************************
  <<< [StrT_cmp_part] >>> 
************************************************************************/
int  StrT_cmp_part( const TCHAR* in_StringA_Start, const TCHAR* in_StringA_Over,
	const TCHAR* in_StringB )
{
	const TCHAR*  a;
	const TCHAR*  b;
	TCHAR  aa;
	TCHAR  bb;

	a = in_StringA_Start;
	b = in_StringB;

	for (;;) {
		if ( a >= in_StringA_Over ) {
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
  <<< [StrT_cmp_i_part] >>> 
************************************************************************/
int  StrT_cmp_i_part( const TCHAR* in_StringA_Start, const TCHAR* in_StringA_Over,
	const TCHAR* in_StringB )
{
	const TCHAR*  a;
	const TCHAR*  b;
	TCHAR  aa;
	TCHAR  bb;

	a = in_StringA_Start;
	b = in_StringB;

	for (;;) {
		if ( a >= in_StringA_Over ) {
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

		if ( aa != bb ) {
			if ( _totlower( aa ) != _totlower( bb ) )
				{ return  aa - bb; }
		}

		a += 1;
		b += 1;
	}
}


 
/***********************************************************************
  <<< [StrT_cmp_part2] >>> 
************************************************************************/
int  StrT_cmp_part2( const TCHAR* in_StringA_Start, const TCHAR* in_StringA_Over,
	const TCHAR* in_StringB_Start, const TCHAR* in_StringB_Over )
{
	int  length_A = in_StringA_Over - in_StringA_Start;
	int  length_B = in_StringB_Over - in_StringB_Start;

	if ( length_A != length_B ) {
		return  length_A - length_B;
	}
	else {
		return  _tcsncmp( in_StringA_Start, in_StringB_Start, length_A );
	}
}


 
/***********************************************************************
  <<< [StrT_refFName] >>> 
************************************************************************/
TCHAR*  StrT_refFName( const TCHAR* s )
{
	const TCHAR*  p;
	TCHAR  c;

	p = StrT_chr( s, _T('\0') );

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

	p = StrT_chr( s, _T('\0') );

	if ( p == s )  { return  (TCHAR*) s; }

	for ( p--; p>s; p-- ) {
		if ( *p == _T('.') )  return  (TCHAR*) p+1;
		if ( *p == _T('/') || *p == _T('\\') )
			{ return  (TCHAR*) StrT_chr( p, _T('\0') ); }
	}
	if ( *p == _T('.') )  return  (TCHAR*) p+1;

	return  (TCHAR*) StrT_chr( s, _T('\0') );
}


 
/***********************************************************************
* Function: StrT_cutFragmentInPath
************************************************************************/
void  StrT_cutFragmentInPath( TCHAR* in_out_Path )
{
	TCHAR*  p;

	p = _tcschr( in_out_Path, _T('#') );
	if ( p != NULL ) {
		*p = _T('\0');
	}
}


 
/***********************************************************************
  <<< [StrT_searchPartStringIndex] >>> 
************************************************************************/
int  StrT_searchPartStringIndex( const TCHAR* in_String, const TCHAR* in_StringOver,
	const TCHAR** in_StringsArray,  uint_fast32_t in_StringsArrayLength,
	int in_DefaultIndex )
{
	const TCHAR**  p;
	const TCHAR**  p_over = in_StringsArray + in_StringsArrayLength;
	size_t         size = (byte_t*) in_StringOver - (byte_t*) in_String;

	for ( p = in_StringsArray;  p < p_over;  p += 1 ) {
		if ( memcmp( *p, in_String, size ) == 0 ) {
			return  p - in_StringsArray;
		}
	}
	return  in_DefaultIndex;
}

 
/***********************************************************************
  <<< [StrT_searchPartStringIndexI] >>> 
 - This ignores case sensitive.
************************************************************************/
int  StrT_searchPartStringIndexI( const TCHAR* in_String, const TCHAR* in_StringOver,
	const TCHAR** in_StringsArray,  uint_fast32_t in_StringsArrayLength,
	int in_DefaultIndex )
{
	const TCHAR**  p;
	const TCHAR**  p_over = in_StringsArray + in_StringsArrayLength;
	size_t         count = (TCHAR*) in_StringOver - (TCHAR*) in_String;

	for ( p = in_StringsArray;  p < p_over;  p += 1 ) {
		if ( _tcsnicmp( *p, in_String, count ) == 0 ) {
			return  p - in_StringsArray;
		}
	}
	return  in_DefaultIndex;
}

 
/***********************************************************************
  <<< [StrT_convStrToId] >>> 
************************************************************************/
int  StrT_convStrToId( const TCHAR* str, const TCHAR** strs, const int* ids,
	int n, int default_id )
{
	const TCHAR**  p;
	const TCHAR**  p_over = strs + n;

	for ( p = strs;  p < p_over;  p++ ) {
		if ( _tcsicmp( *p, str ) == 0 )  return  ids[p - strs];
	}
	return  default_id;
}

 
/***********************************************************************
  <<< [StrT_convStrLeftToId] >>> 
************************************************************************/
int  StrT_convStrLeftToId( const TCHAR* Str, const TCHAR** Strs, const size_t* Lens, const int* Ids,
                           int CountOfStrs, TCHAR* Separeters, int DefaultId, TCHAR** out_PosOfLastOfStr )
{
	const TCHAR**  pp;
	const TCHAR**  pp_over = Strs + CountOfStrs;
	const size_t*  p_len;
	const int*     p_id;
	const TCHAR*   p_last_of_str;
	TCHAR          c;

	p_len = Lens;
	p_id  = Ids;
	for ( pp = Strs;  pp < pp_over;  pp += 1 ) {

		ASSERT_D( _tcslen( *pp ) == *p_len, goto err );

		if ( _tcsncmp( Str, *pp, *p_len ) == 0 ) {
			p_last_of_str = Str + *p_len;
			c = *p_last_of_str;
			if ( c == _T('\0') || _tcschr( Separeters, c ) != NULL ) {
				*out_PosOfLastOfStr = (TCHAR*) p_last_of_str;
				return  *p_id;
			}
		}
		p_len += 1;
		p_id += 1;
	}
	return  DefaultId;

#if ! NDEBUG
 err:  return  DefaultId;
#endif
}

 
/***********************************************************************
  <<< [StrT_replace] >>> 
************************************************************************/
errnum_t  StrT_replace( TCHAR* Out, size_t OutSize, const TCHAR* In,
                        const TCHAR* FromStr, const TCHAR* ToStr, unsigned Opt )
{
	errnum_t        e;
	unsigned        from_size = _tcslen( FromStr ) * sizeof(TCHAR);
	unsigned        to_size   = _tcslen( ToStr )   * sizeof(TCHAR);
	const TCHAR*    p_in      = In;
	TCHAR*          p_out     = Out;
	const TCHAR*    p_in_from;
	size_t          copy_size;
	int             out_size  = OutSize - 1;


	/* 置換して小さくなるときは、左から右へ走査する */
	if ( to_size <= from_size ) {

		for (;;) {

			/* In の中の FromStr の先頭位置を p_in_from へ */
			p_in_from = _tcsstr( p_in, FromStr );
			if ( p_in_from == NULL ) break;

			/* In の中の FromStr の前まで In から Out へコピーする */
			copy_size = (char*)p_in_from - (char*)p_in;
			out_size -= copy_size + to_size;
			IF( out_size < 0 ) goto err_fa;

			if ( p_out != p_in )
				memcpy( p_out, p_in, copy_size );
			p_in  = (TCHAR*)( (char*)p_in  + copy_size );
			p_out = (TCHAR*)( (char*)p_out + copy_size );

			/* FromStr を ToStr に置き換える */
			memcpy( p_out, ToStr, to_size );
			p_in  = (TCHAR*)( (char*)p_in  + from_size );
			p_out = (TCHAR*)( (char*)p_out + to_size );

			/* "STR_1TIME" */
			if ( Opt & STR_1TIME )
				{ break; }
		}

		/* 残りを In から Out へコピーする */
		#pragma warning(push)
		#pragma warning(disable:4996)
			if ( p_out != p_in )
				_tcscpy( p_out, p_in );
			p_out = NULL;
		#pragma warning(pop)
	}


	/* 置換して大きくなるときは、右から左へ走査する */
	else {

		/* In の中の FromStr が無いときは全部コピーする */
		p_in_from = _tcsstr( p_in, FromStr );
		if ( p_in_from == NULL ) {
			if ( p_out != p_in )
				StrT_cpy( Out, OutSize, In );
			p_out = NULL;
		}
		else {
			Set2a          froms;
			TCHAR*         froms_X[10];
			const TCHAR**  pp_froms;
			size_t         plus_from_to;

			Set2a_initConst( &froms, froms_X );
			e= Set2a_init( &froms, froms_X, sizeof(froms_X) ); IF(e)goto fin2;


			/* In の中の FromStr の前までコピーする */
			copy_size = (char*)p_in_from - (char*)p_in;
			out_size -= copy_size;
			IF( out_size < 0 ) goto err_fa2;

			memcpy( p_out, p_in, copy_size );
			// p_in  = (TCHAR*)( (char*)p_in  + copy_size );  // 後で使われない
			p_out = (TCHAR*)( (char*)p_out + copy_size );


			/* In の中の FromStr の位置を froms へ集める */
			for (;;) {

				e= Set2a_expandIfOverByAddr( &froms, froms_X, (TCHAR**)froms.Next + 1 ); IF(e)goto fin2;
				pp_froms = (const TCHAR**)froms.Next;  froms.Next = (void*)( pp_froms + 1 );

				*pp_froms =  p_in_from;

				if ( Opt & STR_1TIME )
					{ break; }

				p_in = (const TCHAR*)( (char*)p_in_from + from_size );
				p_in_from = _tcsstr( p_in, FromStr );
				if ( p_in_from == NULL )  break;
			}

			plus_from_to = ( (TCHAR**)froms.Next - (TCHAR**)froms.First ) * (to_size - from_size);


			/* In の末尾の '\0' の位置も froms へ */
			e= Set2a_expandIfOverByAddr( &froms, froms_X, (TCHAR**)froms.Next + 1 ); IF(e)goto fin2;
			pp_froms = (const TCHAR**)froms.Next;  froms.Next = (void*)( pp_froms + 1 );
			p_in = StrT_chr( p_in, _T('\0') );
			*pp_froms = p_in;

			copy_size = ( (char*)p_in - (char*)In ) + plus_from_to;
			IF( copy_size >= OutSize ) goto err_fa2;
			p_out = (TCHAR*)( (char*)Out + copy_size );
			plus_from_to -= to_size - from_size;


			/* 右から左へ走査する */
			for ( pp_froms = (TCHAR**)froms.Next - 1;
			      pp_froms > (TCHAR**)froms.First;
			      pp_froms -- ) {

				const TCHAR*  p_in_from       = *(pp_froms - 1);
				const TCHAR*  p_in_other      = (const TCHAR*)( (char*)p_in_from + from_size );
				const TCHAR*  p_in_other_over = *pp_froms;
				      TCHAR*  p_out_to        = (TCHAR*)( (char*)Out + ( (char*)p_in_from - (char*)In ) + plus_from_to );
				      TCHAR*  p_out_other     = (TCHAR*)( (char*)p_out_to + to_size );

				memmove( p_out_other, p_in_other, (char*)p_in_other_over - (char*)p_in_other );
				memcpy( p_out_to, ToStr, to_size );

				plus_from_to -= to_size - from_size;
			}

			goto fin2;
		err_fa2:  e = E_FEW_ARRAY;   goto fin2;
		fin2:
			e= Set2a_finish( &froms, froms_X, e );
			if ( e ) goto fin;
		}
	}

	e=0;
fin:
	if ( p_out != NULL )  *p_out = _T('\0');
	return  e;

err_fa:  e = E_FEW_ARRAY;  goto fin;
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
	for ( p2 = StrT_chr( p1, _T('\0') ) - 1;  p2 >= p1;  p2-- ) {
		c = *p2;
		if ( c != _T(' ') && c != _T('\t') && c != _T('\n') && c != _T('\r') )
			break;
	}
	return  stcpy_part_r( out_Str, out_Str_Size, out_Str, NULL, p1, p2+1 );
}


 
/***********************************************************************
  <<< [StrT_cutPart] >>> 
************************************************************************/
errnum_t  StrT_cutPart( TCHAR*  in_out_String,  TCHAR*  in_StartOfCut,  TCHAR*  in_OverOfCut )
{
	errnum_t  e;
	TCHAR*    over_of_cut = StrT_chr( in_StartOfCut, _T('\0') );

#ifndef  NDEBUG
	TCHAR*    over_of_string = StrT_chr( in_out_String, _T('\0') );

	ASSERT_D( over_of_cut == over_of_string,   e=E_OTHERS; goto fin );
	ASSERT_D( in_StartOfCut >= in_out_String,   e=E_OTHERS; goto fin );
	ASSERT_D( in_StartOfCut <= over_of_string,  e=E_OTHERS; goto fin );
	ASSERT_D( in_OverOfCut  >= in_out_String,   e=E_OTHERS; goto fin );
	ASSERT_D( in_OverOfCut  <= over_of_string,  e=E_OTHERS; goto fin );
	ASSERT_D( in_StartOfCut <= in_OverOfCut,    e=E_OTHERS; goto fin );
#endif
	UNREFERENCED_VARIABLE( in_out_String );

	memmove( in_StartOfCut,  in_OverOfCut,
		PointerType_diff( over_of_cut + 1,  in_OverOfCut ) );

	e=0;
#ifndef  NDEBUG
fin:
#endif
	return  e;
}


 
/***********************************************************************
  <<< [StrT_cutLastOf] >>> 
************************************************************************/
errnum_t  StrT_cutLastOf( TCHAR* in_out_Str, TCHAR Charactor )
{
	TCHAR*  last = StrT_chr( in_out_Str, _T('\0') );

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
	if ( p2 == NULL )  p2 = StrT_chr( p1, _T('\0') );

	for ( p2 = p2 - 1;  p2 >= p1;  p2-- ) {
		c = *p2;
		if ( c != _T(' ') && c != _T('\t') && c != _T('\n') && c != _T('\r') )
			break;
	}
	return  stcpy_part_r( out_Str, out_Str_Size, out_Str, NULL, p1, p2+1 );
}


 
/***********************************************************************
  <<< [StrT_insert] >>> 
************************************************************************/
errnum_t  StrT_insert( TCHAR*  in_out_WholeString,  size_t  in_MaxSize_of_WholeString,
	TCHAR*  in_out_Target_in_WholeString,  TCHAR**  out_NextTarget_in_WholeString,
	const TCHAR*  in_InsertString )
{
	errnum_t  e;
	TCHAR*    over_of_whole_string = StrT_chr( in_out_WholeString, _T('\0') );
	size_t    insert_length = _tcslen( in_InsertString );

	ASSERT_D( in_out_Target_in_WholeString >= in_out_WholeString,   e=E_OTHERS; goto fin );
	ASSERT_D( in_out_Target_in_WholeString <= over_of_whole_string, e=E_OTHERS; goto fin );

	ASSERT_R( PointerType_diff( over_of_whole_string + 1,  in_out_WholeString ) + ( insert_length * sizeof(TCHAR) )
		<= in_MaxSize_of_WholeString,  e=E_FEW_ARRAY; goto fin );

	memmove( in_out_Target_in_WholeString + insert_length,  in_out_Target_in_WholeString,
		PointerType_diff( over_of_whole_string + 1,  in_out_Target_in_WholeString ) );

	memcpy( in_out_Target_in_WholeString,  in_InsertString,  insert_length * sizeof(TCHAR) );

	if ( out_NextTarget_in_WholeString != NULL ) {
		*out_NextTarget_in_WholeString = in_out_Target_in_WholeString + insert_length;
	}

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [StrHS_insert] >>> 
************************************************************************/
errnum_t  StrHS_insert( TCHAR**  in_out_WholeString,
	int  in_TargetIndexInWholeString,  int*  out_NextWholeInWholeString,
	const TCHAR*  in_InsertString )
{
	errnum_t  e;
	TCHAR*    string = *in_out_WholeString;
	size_t    target_length = _tcslen( string );
	size_t    insert_length = _tcslen( in_InsertString );
	size_t    max_size = _msize( string ) / sizeof( TCHAR );
	size_t    new_max_size = target_length + insert_length + 1;
	TCHAR*    next_target;


	if ( max_size < new_max_size ) {
		TCHAR*  new_string = (TCHAR*) realloc( string,  new_max_size * sizeof( TCHAR ) );

		IF ( new_string == NULL ) { e=E_FEW_MEMORY; goto fin; }
		max_size = new_max_size;
		string = new_string;
	}

	e= StrT_insert( string,  max_size * sizeof( TCHAR ),
		string + in_TargetIndexInWholeString,  &next_target,
		in_InsertString ); IF(e){goto fin;}

	if ( out_NextWholeInWholeString != NULL ) {
		*out_NextWholeInWholeString = next_target - string;
	}

	e=0;
fin:
	*in_out_WholeString = string;
	return  e;
}


 
/***********************************************************************
  <<< [StrHS_printfPartV] >>> 
************************************************************************/
errnum_t  StrHS_printfPartV( TCHAR**  in_out_String,
	int  in_IndexInString,  int*  out_NextIndexInString,
	const TCHAR*  in_Format,  va_list  in_VaList )
{
	enum { first_max_size = 40 };
	enum { size_times = 4 };

	errnum_t  e;
	size_t    max_size;
	TCHAR*    string = *in_out_String;


	if ( string == NULL ) {
		max_size = 0;

		ASSERT_R( in_IndexInString == 0,  e=E_OTHERS; goto fin );
	}
	else {
		max_size = _msize( string ) / sizeof( TCHAR );

		ASSERT_R( in_IndexInString >= 0  &&  (size_t) in_IndexInString < max_size,
			e=E_OTHERS; goto fin );
		ASSERT_D( (size_t) in_IndexInString <= _tcslen( string ), __noop() );
	}


	if ( string == NULL ) {
		string = (TCHAR*) malloc( first_max_size * sizeof( TCHAR ) );
		max_size = first_max_size;
	}


	for (;;) {

		#if _MSC_VER
			#pragma warning(push)
			#pragma warning(disable: 4996)
		#endif

		#ifdef  _UNICODE
			int  r = _vsnwprintf( string + in_IndexInString,  max_size - in_IndexInString,
				in_Format,  in_VaList );
		#else
			int  r = _vsnprintf( string + in_IndexInString,  max_size - in_IndexInString,
				in_Format,  in_VaList );
		#endif

		#if _MSC_VER
			#pragma warning(pop)
		#endif

		if ( r >= 0 ) {
			if ( out_NextIndexInString != NULL ) {
				*out_NextIndexInString = in_IndexInString + r;
			}

			break;
		}

		{
			size_t  new_max_size = max_size * size_times + first_max_size;
			TCHAR*  new_string = (TCHAR*) realloc( string,  new_max_size * sizeof( TCHAR ) );

			IF ( new_string == NULL ) { e=E_FEW_MEMORY; goto fin; }
			max_size = new_max_size;
			string = new_string;
		}
	}

	e=0;
fin:
	*in_out_String = string;
	return  e;
}


 
/***********************************************************************
  <<< [StrHS_printfPart] >>> 
************************************************************************/
errnum_t  StrHS_printfPart( TCHAR**  in_out_String,
	int  in_IndexInString,  int*  out_NextIndexInString,
	const TCHAR*  in_Format,  ... )
{
	errnum_t  e;
	va_list   va;
	va_start( va, in_Format );

	e = StrHS_printfPartV( in_out_String,  in_IndexInString,  out_NextIndexInString,  in_Format,  va );

	va_end( va );
	return  e;
}


 
/***********************************************************************
  <<< [StrHS_printfV] >>> 
************************************************************************/
errnum_t  StrHS_printfV( TCHAR**  in_out_String,
	const TCHAR*  in_Format,  va_list  in_VaList )
{
	return  StrHS_printfPartV( in_out_String,  0,  NULL,  in_Format,  in_VaList );
}


 
/***********************************************************************
  <<< [StrHS_printf] >>> 
************************************************************************/
errnum_t  StrHS_printf( TCHAR**  in_out_String,
	const TCHAR*  in_Format,  ... )
{
	errnum_t  e;
	va_list   va;
	va_start( va, in_Format );

	e = StrHS_printfPartV( in_out_String,  0,  NULL,  in_Format,  va );

	va_end( va );
	return  e;
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
	size_t         str_size = SIZE_MAX;  /* SIZE_MAX = Avoid warning */


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


 
/**************************************************************************
  <<< [StrT_changeToXML_Attribute] >>> 
*************************************************************************/
errnum_t  StrT_changeToXML_Attribute( TCHAR* out_Str, size_t Str_Size, const TCHAR* InputStr )
{
	errnum_t  e;

	e= StrT_replace( out_Str, Str_Size, InputStr, _T("&"),  _T("&amp;"),  0 ); IF(e)goto fin;
	e= StrT_replace( out_Str, Str_Size, out_Str,  _T("\""), _T("&quot;"), 0 ); IF(e)goto fin;
	e= StrT_replace( out_Str, Str_Size, out_Str,  _T("<"),  _T("&lt;"),   0 ); IF(e)goto fin;

	e=0;
fin:
	return  e;
}


 
/**************************************************************************
  <<< [StrT_resumeFromXML_Attribute] >>> 
*************************************************************************/
errnum_t  StrT_resumeFromXML_Attribute( TCHAR* out_Str, size_t Str_Size, const TCHAR* XML_Attr )
{
	errnum_t  e;

	e= StrT_replace( out_Str, Str_Size, XML_Attr, _T("&quot;"), _T("\""), 0 ); IF(e)goto fin;
	e= StrT_replace( out_Str, Str_Size, out_Str,  _T("&lt;"),   _T("<"),  0 ); IF(e)goto fin;
	e= StrT_replace( out_Str, Str_Size, out_Str,  _T("&amp;"),  _T("&"),  0 ); IF(e)goto fin;

	e=0;
fin:
	return  e;
}


 
/**************************************************************************
  <<< [StrT_changeToXML_Text] >>> 
*************************************************************************/
errnum_t  StrT_changeToXML_Text( TCHAR* out_Str, size_t Str_Size, const TCHAR* InputStr )
{
	errnum_t  e;

	e= StrT_replace( out_Str, Str_Size, InputStr, _T("&"), _T("&amp;"), 0 ); IF(e)goto fin;
	e= StrT_replace( out_Str, Str_Size, out_Str,  _T("<"), _T("&lt;"),  0 ); IF(e)goto fin;
	e= StrT_replace( out_Str, Str_Size, out_Str,  _T(">"), _T("&gt;"),  0 ); IF(e)goto fin;

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [StrT_getExistSymbols] >>> 
************************************************************************/
errnum_t  StrT_getExistSymbols( unsigned* out, bool bCase, const TCHAR* Str, const TCHAR* Symbols, ... )
{
	errnum_t  e;
	int       i;
	bool*   syms_exists = NULL;
	bool    b_nosym = false;
	TCHAR*  sym = NULL;
	size_t  sym_size = ( _tcslen( Symbols ) + 1 ) * sizeof(TCHAR);
	int     n_sym = 0;
	const TCHAR** syms = NULL;
	const TCHAR*  p;

	UNREFERENCED_VARIABLE( bCase );

	sym = (TCHAR*) malloc( sym_size ); IF(sym==NULL)goto err_fm;


	//=== Get Symbols
	p = Symbols;
	do {
		e= StrT_meltCSV( sym, sym_size, &p ); IF(e)goto fin;
		if ( sym[0] != _T('\0') )  n_sym ++;
	} while ( p != NULL );

	syms = (const TCHAR**) malloc( n_sym * sizeof(TCHAR*) ); IF(syms==NULL)goto err_fm;
	memset( (TCHAR**) syms, 0, n_sym * sizeof(TCHAR*) );
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
			e= HeapMemory_free( &syms[i], e );
		}
		free( (TCHAR**) syms );
	}
	e= HeapMemory_free( &syms_exists, e );
	e= HeapMemory_free( &sym, e );
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

		if ( colon != NULL ) {
			const TCHAR*  p;

			for ( p = path;  p < colon;  p += 1 ) {
				if ( ! _istalnum( *p ) ) {
					colon = NULL;
					break;
				}
			}
		}

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
				IF( p < OutStart ) {goto err;}  /* "../" are too many */
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
				IF( p < OutStart ) {goto err;}  /* "../" are too many */
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
		TCHAR*  over = StrT_chr( OutStart, _T('\0') );

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

	IF_D( StrStart < Str ||  (char*) StrStart >= (char*)Str + StrSize ){goto err;}

	if ( StepPath[0] == _T('\0') ) {
		*StrStart = _T('\0');
		return  0;
	}

	/* 絶対パスにする */
	e= StrT_getFullPath( StrStart,
		StrSize - ( (char*)StrStart - (char*)Str ),
		StepPath, BasePath ); IF(e)goto fin;


	/* Cut last \ */
	p = StrT_chr( StrStart, _T('\0') );
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
		IF( base_pointer == NULL ) {goto err;}
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
	if ( ( ( abs_char == _T('/')  ||  abs_char == _T('\\') )  &&  base_char == _T('\0') ) ||
	     (  base_char == _T('/')  || base_char == _T('\\') )  &&   abs_char == _T('\0') ) {

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
	const TCHAR*    last_pos_in_base = StrT_chr( BasePath, _T('\0') );
	const TCHAR*    term_pos_in_base;
	const TCHAR*     add_pos_in_base;
	const TCHAR*  period_pos_in_base = _tcsrchr( BasePath, _T('.') );  // > term_pos_in_base
	const TCHAR*    last_pos_in_add  = StrT_chr( AddName, _T('\0') );
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
			add_pos_in_base = StrT_chr( BasePath, _T('\0') );
		else
			add_pos_in_base = StrT_chr( term_pos_in_base, _T('\0') );
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
  <<< [StrT_encodeToValidPath] >>> 
************************************************************************/
errnum_t  StrT_encodeToValidPath( TCHAR* out_Path,  size_t in_OutPathSize,  const TCHAR* in_Path,  bool  in_IsName )
{
	errnum_t  e;

	int  i_in;   /* index of "in_Path" */
	int  i_out = 0;  /* index of "out_Path" */
	int  i_out_over = (int)( in_OutPathSize / sizeof(TCHAR) );
	bool is_colon = in_IsName;

	ASSERT_R( in_Path != out_Path,  e=E_OTHERS; goto fin );

	for ( i_in = 0;  ;  i_in += 1 ) {
		bool  is_percent;
		int   chara = in_Path[ i_in ];  /* a character */

		if ( chara == _T('\0') )
			{ break; }


		/* Set "is_percent" */
		switch ( chara ) {
			case _T(','):  case _T(';'):  case _T('*'):  case _T('?'):  case _T('"'):
			case _T('<'):  case _T('>'):  case _T('|'):  case _T('%'):
				is_percent = true;
				break;
			case _T(':'):
				is_percent = is_colon;
				is_colon = true;
				break;
			case _T('\\'):  case _T('/'):
				is_percent = in_IsName;
				is_colon = true;
				break;
			default:
				is_percent = false;
				break;
		}


		/* Set "out_Path[ i_out ]" */
		if ( is_percent ) {
			int  high = chara / 0x10;
			int  low  = chara & 0xF;

			if ( high <= 9 ) {
				high += _T('0');
			} else {
				high = ( high - 0xA ) + _T('a');
			}

			if ( low <= 9 ) {
				low += _T('0');
			} else {
				low = ( low - 0xA ) + _T('a');
			}

			ASSERT_R( i_out + 3 < i_out_over,  e=E_FEW_ARRAY; goto fin );

			out_Path[ i_out + 0 ] = _T('%');
			out_Path[ i_out + 1 ] = (TCHAR) high;
			out_Path[ i_out + 2 ] = (TCHAR) low;
			i_out += 3;
		}
		else {
			ASSERT_R( i_out + 1 < i_out_over,  e=E_FEW_ARRAY; goto fin );

			out_Path[ i_out ] = (TCHAR) chara;
			i_out += 1;
		}
	}

	e=0;
fin:
	out_Path[ i_out ] = _T('\0');

	return  e;
}


 
/***********************************************************************
  <<< [Strs_init] >>> 
************************************************************************/
enum { Strs_FirstSize = 0x0F00 };

errnum_t  Strs_init( Strs* self )
{
	byte_t*  p;

	self->MemoryAddress = NULL;

	p = (byte_t*) malloc( Strs_FirstSize );
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
	return  Strs_addBinary( self, Str, StrT_chr( Str, _T('\0') ) + 1, out_AllocStr );
}


errnum_t  Strs_addBinary( Strs* self, const TCHAR* Str, const TCHAR* StrOver, const TCHAR** out_AllocStr )
{
	errnum_t  e;
	size_t  str_size;
	size_t  elem_size;

	str_size  = ( (byte_t*) StrOver - (byte_t*) Str );
	elem_size = ( sizeof(TCHAR*) + str_size + ( sizeof(void*) - 1 ) ) & ~(sizeof(void*) - 1);

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
	IF( last_str != AllocStr ) {goto err;}

	// [ FirstStr | NULL    | TCHAR[] | ... ]
	if ( prev_of_last_str == NULL ) {
		self->NextElem = self->MemoryAddress + sizeof(TCHAR*);
		self->PointerToNextStrInPrevElem = (TCHAR**) self->MemoryAddress;
	}

	// [ FirstStr | NextStr | TCHAR[] | NULL    | TCHAR[] | ... ]
	else if ( (byte_t*) prev_of_last_str >= self->MemoryAddress  &&
	          (byte_t*) prev_of_last_str <  self->MemoryOver ) {
		self->NextElem = (byte_t*)last_str - sizeof(TCHAR*);
		self->PointerToNextStrInPrevElem = (TCHAR**)( (byte_t*)prev_of_last_str - sizeof(TCHAR*) );
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
	byte_t* new_memory;

	// [ NULL     | ... ]
	// [ FirstStr | NULL    | TCHAR[] | ... ]
	// [ FirstStr | NextStr | TCHAR[] | NULL    | TCHAR[] | ... ]
	// [ FirstStr | NextStr | TCHAR[] | NextStr | TCHAR[] ], [ NULL | TCHAR[] | ... ]

	while ( self->NextElem + elem_size > self->MemoryOver ) {

		//=== alloc
		mp = (Strs*) malloc( sizeof(Strs) ); IF(mp==NULL) goto err_fm;
		memory_size = ( self->MemoryOver - self->MemoryAddress ) * 2;
		new_memory = (byte_t*) malloc( memory_size );
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
		{ StrOver = StrT_chr( (TCHAR*)( self->NextElem + sizeof(TCHAR*) ), _T('\0') ) + 1; }
	elem_size = ( ( (byte_t*)StrOver - self->NextElem ) + sizeof(void*) - 1 ) & ~(sizeof(void*) - 1);

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
  <<< [Strs_allocateArray] >>> 
************************************************************************/
errnum_t  Strs_allocateArray( Strs* self,  TCHAR*** out_PointerArray,  int* out_Count )
{
	errnum_t  e;
	TCHAR*    p;
	TCHAR**   pp;
	int       count;

	count = 0;
	for ( Strs_forEach( self, &p ) ) {
		count += 1;
	}

	e= HeapMemory_allocateArray( &pp, count ); IF(e){goto fin;}

	count = 0;
	for ( Strs_forEach( self, &p ) ) {
		pp[ count ] = p;
		count += 1;
	}

	*out_PointerArray = pp;
	*out_Count = count;

	e=0;
fin:
	return  e;
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


 
/*-------------------------------------------------------------------------*/
/* <<<< ### (StrFile) Read Class implement >>>> */ 
/*-------------------------------------------------------------------------*/

errnum_t  StrFile_init_sub( StrFile* self, void* Buffer, size_t BufferSize, int Flags );

/*[StrFile_init_fromStr]*/
errnum_t  StrFile_init_fromStr( StrFile* self, TCHAR* LinkStr )
{
	self->IsBufferInHeap = false;
	#if _UNICODE
		StrFile_init_sub( self, LinkStr,
			(char*)StrT_chr( LinkStr, _T('\0') ) - (char*)LinkStr,  STR_FILE_WCHAR );
	#else
		StrFile_init_sub( self, LinkStr,
			(char*)StrT_chr( LinkStr, _T('\0') ) - (char*)LinkStr,  0 );
	#endif

	return  0;
}


/*[StrFile_initConst]*/
void  StrFile_initConst( StrFile* self )
{
	self->Buffer = NULL;
}


/*[StrFile_init_withBuf]*/
errnum_t  StrFile_init_withBuf( StrFile* self, void* LinkBuffer, size_t LinkBufferSize, int Flags )
{
	self->IsBufferInHeap = false;
	StrFile_init_sub( self, LinkBuffer, LinkBufferSize, Flags );
	return  0;
}


/*[StrFile_init_sub]*/
errnum_t  StrFile_init_sub( StrFile* self, void* Buffer, size_t BufferSize, int Flags )
{
	unsigned char*  top = (unsigned char*) Buffer;

	if ( Flags & STR_FILE_WCHAR ) {
		self->CharSize = 2;
		self->Pointer = top;
	}
	else {
		// UTF-16 BOM= { FF, FE },  UTF-8 BOM = { EF, BB, BF }
		if ( BufferSize >= 2  &&  top[0] == 0xFF  &&  top[1] == 0xFE ) {
			self->CharSize = 2;
			self->Pointer = top + 2;
			if ( BufferSize % 2 == 1 )  BufferSize --;
		}
		else if ( BufferSize >= 3  &&  top[0] == 0xEF  &&  top[1] == 0xBB  &&  top[2] == 0xBF ) {
			self->CharSize = 1;
			self->Pointer = top + 3;
		}
		else {
			self->CharSize = 1;
			self->Pointer = top;
		}
	}

	self->Buffer = Buffer;
	self->BufferSize = BufferSize;
	// self->IsBufferInHeap // not init in this function

	return  0;
}


/*[StrFile_init_fromSizedStructInStream]*/
errnum_t  StrFile_init_fromSizedStructInStream( StrFile* self, HANDLE* Stream )
{
	errnum_t  e;

	self->IsBufferInHeap = false;

	e= FileT_readSizedStruct_WinAPI( Stream, &self->Buffer ); IF(e)goto rollback;
	self->IsBufferInHeap = true;
	self->OffsetToHeapBlockFirst = - (int) sizeof(size_t);
	e= StrFile_init_sub( self, (size_t*)self->Buffer + 1,
		 *(size_t*)self->Buffer - sizeof(size_t), STR_FILE_READ ); IF(e)goto rollback;
	return  0;

rollback:  StrFile_finish( self, e );  return  e;
}


/*[StrFile_finish]*/
errnum_t  StrFile_finish( StrFile* self, errnum_t e )
{
	if ( self->Buffer == NULL )  return  e;
	if ( self->IsBufferInHeap ) {
		free( (char*) self->Buffer + self->OffsetToHeapBlockFirst );
		self->IsBufferInHeap = false;
	}
	self->Buffer = NULL;
	return  e;
}


/*[StrFile_readLine]*/
errnum_t  StrFile_readLine( StrFile* self, TCHAR* out_Line, size_t LineSize )
{
	errnum_t  e;
	TCHAR*  last_of_line;

	if ( self->CharSize == 1 ) {
		char*  ptr   = (char*) self->Pointer;
		char*  first = ptr;
		char*  over  = (char*) self->Buffer + self->BufferSize;
		size_t size;

		if ( ptr >= over ) goto err_nn;

		for (;;) {
			if ( ptr >= over )  { self->Pointer = (void*)0xFFFFFFFF;  break; }
			if ( *ptr == '\n' )  { ptr++;  self->Pointer = ptr;  break; }
			ptr ++;
		}
		size = ptr - first;

		#if _UNICODE
			if ( ptr < over ) {
				char  ch = *ptr;

				*ptr = '\0';
				e= stprintf_r( out_Line, LineSize, _T("%S"), first );
				*ptr = ch;
				IF(e)goto fin;
			}
			else {  // if cannot access *ptr
				char*  line;

				line = malloc( size + sizeof(char) );
				line[ size ] = '\0';
				memcpy( line, first, size );

				e= stprintf_r( out_Line, LineSize, _T("%S"), line );
				free( line );
				IF(e)goto fin;
			}
			last_of_line = StrT_chr( out_Line, _T('\0') );
		#else
			if ( size > LineSize - sizeof(char) )  goto err_fa;

			last_of_line = out_Line + size;
			*last_of_line = '\0';
			memcpy( out_Line, first, size );
		#endif
	}
	else {
		wchar_t*  ptr   = (wchar_t*) self->Pointer;
		wchar_t*  first = ptr;
		wchar_t*  over  = (wchar_t*)( (char*) self->Buffer + self->BufferSize );
		size_t    size;

		ASSERT_D( self->CharSize == 2, goto err );

		if ( ptr >= over ) goto err_nn;

		for (;;) {
			if ( ptr >= over )  { self->Pointer = (void*)0xFFFFFFFF;  break; }
			if ( *ptr == L'\n' )  { ptr++;  self->Pointer = ptr;  break; }
			ptr ++;
		}
		size = (char*) ptr - (char*) first;

		#if _UNICODE
			IF( size > LineSize - sizeof(TCHAR) ) goto err_fa;

			last_of_line = (TCHAR*)( (char*) out_Line + size );
			*last_of_line = _T('\0');
			memcpy( out_Line, first, size );
		#else
			if ( ptr < over ) {
				wchar_t  ch = *ptr;

				*ptr = L'\0';
				e= stprintf_r( out_Line, LineSize, _T("%S"), first );
				*ptr = ch;
				IF(e)goto fin;
				last_of_line = StrT_chr( out_Line, _T('\0') );
			}
			else {  // if cannot access *ptr
				wchar_t  last_str[2];

				ptr --;

				last_str[0] = *ptr;
				last_str[1] = L'\0';

				*ptr = L'\0';
				e= stprintf_r( out_Line, LineSize, "%S", first );
				*ptr = last_str[0];
				IF(e)goto fin;

				last_of_line = StrT_chr( out_Line, _T('\0') );
				LineSize -= (char*) last_of_line - (char*) out_Line;
				e= stprintf_r( last_of_line, LineSize, "%S", last_str ); IF(e)goto fin;
				last_of_line = StrT_chr( last_of_line, _T('\0') );
			}
		#endif
	}

	// change from CR+LF to LF (text mode)
	if ( last_of_line >= out_Line + 2 ) {
		if ( *(last_of_line - 2) == _T('\r')  &&  *(last_of_line - 1) == _T('\n') ) {
			*(last_of_line - 2) = _T('\n');  *(last_of_line - 1) = _T('\0');
		}
	}

	e=0;
fin:
	return  e;

err_fa:  e = E_FEW_ARRAY;  goto fin;
err_nn:  self->Pointer = (void*)0xFFFFFFFF;  e=0;  goto fin;  // not [e = E_NO_NEXT], because ferror()==0
#if _DEBUG
err:  e = E_OTHERS;  goto fin;
#endif
}


 
/*-------------------------------------------------------------------------*/
/* <<<< ### (StrFile) Write Class implement >>>> */ 
/*-------------------------------------------------------------------------*/

errnum_t  StrFile_expandIfOver_sub( StrFile* self, size_t DataSize );


//[StrFile_init_toHeap]
errnum_t  StrFile_init_toHeap( StrFile* self, int Flags )
{
	void*  mem;
	enum { start_size = 480 };

	mem = malloc( start_size );  IF ( mem == NULL )  return  E_FEW_MEMORY;

	self->Buffer = (char*) mem + sizeof(size_t);
	self->BufferSize = start_size - sizeof(size_t);
	self->IsBufferInHeap = true;
	self->IsTextMode = ( (Flags & STR_FILE_BINARY) == 0 );
	self->OffsetToHeapBlockFirst = - (int) sizeof(size_t);
	if ( Flags & STR_FILE_WCHAR ) {
		wchar_t*  wp = (wchar_t*) self->Buffer;

		wp[0] = 0xFEFF;
		wp[1] = L'\0';

		self->CharSize = 2;
		self->Pointer = (char*) self->Buffer + sizeof(wchar_t);
	}
	else {
		char*  ap = (char*) self->Buffer;

		ap[0] = '\0';

		self->CharSize = 1;
		self->Pointer = (char*) self->Buffer;
	}
	return  0;
}


//[StrFile_write_s]
errnum_t  StrFile_write_s( StrFile* self, const TCHAR* Text )
{
	errnum_t        e;
	const char*     pos1;
	const char*     pos2;
	#if _UNICODE
		char*         str = NULL;
		size_t        str_size;
	#endif

	#if _UNICODE
		str_size = (_tcslen( Text ) + 1) * sizeof(wchar_t); // max is for all 2byte charactors
		str = malloc( str_size ); IF( str == NULL )goto err_fm;
		sprintf_s( str, str_size, "%S", Text ); // conver to multi byte char
		pos1 = str;
	#else
		pos1 = Text;
	#endif

	if ( self->IsTextMode ) {
		for (;;) {
			pos2 = strchr( pos1, '\n' );
			if ( pos2 == NULL )  break;

			// write 1 line and change from \n to CR LF
			e= StrFile_writeBinary( self,  pos1,  (char*) pos2 - (char*) pos1 + 2 * sizeof(char) );
		 		IF(e)goto fin;
			( (char*) self->Pointer )[-2] = '\r';
			( (char*) self->Pointer )[-1] = '\n';

			pos1 = pos2 + 1;
		}
	}

	// if "IsTextMode", write last line
	// if not "IsTextMode", write whole text
	pos2 = strchr( pos1, '\0' );
	e= StrFile_writeBinary( self,  pos1,  (char*) pos2 - (char*) pos1 + sizeof(char) );
		IF(e)goto fin;
	self->Pointer = (char*) self->Pointer - sizeof(char);


	e=0;
fin:
	#if _UNICODE
		if ( str != NULL )  free( str );
	#endif
	return  e;

#if _UNICODE
err_fm:  e = E_FEW_MEMORY;  goto fin;
#endif
}


//[StrFile_write_w]
errnum_t  StrFile_write_w( StrFile* self, const TCHAR* Text )
{
	errnum_t        e;
	const wchar_t*  pos1;
	const wchar_t*  pos2;
	#if ! _UNICODE
		wchar_t*      str = NULL;
		size_t        str_size;
	#endif

	#if _UNICODE
		pos1 = Text;
	#else
		str_size = (_tcslen( Text ) + 1) * sizeof(wchar_t); // max is for all 1byte char to wchar_t
		str = malloc( str_size ); IF( str == NULL )goto err_fm;
		swprintf_s( str, str_size / sizeof(wchar_t), L"%S", Text ); // conver to wide byte char
		pos1 = str;
	#endif

	if ( self->IsTextMode ) {
		for (;;) {
			pos2 = wcschr( pos1, L'\n' );
			if ( pos2 == NULL )  break;

			// write 1 line and change from \n to CR LF
			e= StrFile_writeBinary( self,  pos1,  (char*) pos2 - (char*) pos1 + 2 * sizeof(wchar_t) );
				IF(e)goto fin;
			( (wchar_t*) self->Pointer )[-2] = L'\r';
			( (wchar_t*) self->Pointer )[-1] = L'\n';

			pos1 = pos2 + 1;
		}
	}

	// if "IsTextMode", write last line
	// if not "IsTextMode", write whole text
	pos2 = wcschr( pos1, L'\0' );
	e= StrFile_writeBinary( self,  pos1,  (char*) pos2 - (char*) pos1 + sizeof(wchar_t) );
		IF(e)goto fin;
	self->Pointer = (char*) self->Pointer - sizeof(wchar_t);

	e=0;
fin:
	#if ! _UNICODE
		if ( str != NULL )  free( str );
	#endif
	return  e;

#if ! _UNICODE
err_fm:  e = E_FEW_MEMORY;  goto fin;
#endif
}


//[StrFile_write]
errnum_t  StrFile_write( StrFile* self, const TCHAR* Text )
{
	if ( self->CharSize == 1 )  return  StrFile_write_s( self, Text );
	else                        return  StrFile_write_w( self, Text );
}


//[StrFile_expandIfOver]
errnum_t  StrFile_expandIfOver( StrFile* self, size_t DataSize )
{
	if ( (char*) self->Pointer + DataSize <= (char*) self->Buffer + self->BufferSize )  return  0;
	else  return  StrFile_expandIfOver_sub( self, DataSize );
}


//[StrFile_writeBinary]
errnum_t  StrFile_writeBinary( StrFile* self, const void* Data, size_t DataSize )
{
	errnum_t  e;

	e= StrFile_expandIfOver( self, DataSize ); if(e)return e;
	memcpy( self->Pointer, Data, DataSize );
	self->Pointer = (char*) self->Pointer + DataSize;
	return  0;
}


//[StrFile_expandIfOver_sub]
errnum_t  StrFile_expandIfOver_sub( StrFile* self, size_t DataSize )
{
	errnum_t  e;
	void*   mem;
	size_t  old_size = (char*) self->Pointer - (char*) self->Buffer;
	size_t  new_size = ( self->BufferSize + sizeof(size_t) ) * 2 + DataSize;

	IF( ! self->IsBufferInHeap ) {goto err;}
		// Writing must expand self->Buffer from heap when self->Buffer is small

	mem = realloc( (char*) self->Buffer + self->OffsetToHeapBlockFirst,  new_size );
		IF(mem == NULL) goto err_fa;

	self->Buffer = (char*) mem + sizeof(size_t);
	self->BufferSize = new_size - sizeof(size_t);
	self->OffsetToHeapBlockFirst = - (int) sizeof(size_t);
	self->Pointer = (char*) self->Buffer + old_size;

	e=0;
fin:
	return  e;

err_fa:  e = E_FEW_ARRAY;  goto fin;
err:     e = E_OTHERS;  goto fin;
}


//[StrFile_peekWrittenStringW]
errnum_t  StrFile_peekWrittenStringW( StrFile* self, wchar_t** out_String )
{
	errnum_t  e;

	ASSERT_R( self->CharSize == 2, e=E_OTHERS; goto fin );
	*out_String = (wchar_t*)( (char*) self->Buffer + sizeof(wchar_t) );

	e=0;
fin:
	return  e;
}


//[StrFile_peekWrittenStringA]
errnum_t  StrFile_peekWrittenStringA( StrFile* self, char** out_String )
{
	errnum_t  e;

	ASSERT_R( self->CharSize == 1, e=E_OTHERS; goto fin );
	*out_String = self->Buffer;

	e=0;
fin:
	return  e;
}


//[StrFile_pickupSizedStruct]
errnum_t  StrFile_pickupSizedStruct( StrFile* self, SizedStruct** out_Struct )
{
	*out_Struct = (SizedStruct*)( (char*) self->Buffer - sizeof(size_t) );
	*( (size_t*) self->Buffer - 1 ) = (char*) self->Pointer - (char*) self->Buffer + sizeof(size_t);
	self->IsBufferInHeap = false;
	return  0;
}


//[StrFile_restoreSizedStruct]
errnum_t  StrFile_restoreSizedStruct( StrFile* self, SizedStruct* Struct, errnum_t e )
{
	ASSERT_R( ! self->IsBufferInHeap, goto err );

	self->Buffer = (char*) Struct + sizeof(size_t);
	self->IsBufferInHeap = true;

	e=0;
fin:
	return  e;

err:  e = E_OTHERS;  goto fin;
}


//[StrFile_moveSizedStructToStream]
errnum_t  StrFile_moveSizedStructToStream( StrFile* self, HANDLE Stream )
{
	errnum_t  e;
	SizedStruct*  data = NULL;

	e= StrFile_pickupSizedStruct( self, &data ); IF(e)goto fin;
	e= FileT_writeSizedStruct_WinAPI( Stream, data ); IF(e)goto fin;
	e=0;
fin:
	if ( data != NULL )  { e= StrFile_restoreSizedStruct( self, data, e ); }
	return  e;
}


//[StrFile_setPointer]
errnum_t  StrFile_setPointer( StrFile* self, int OffsetOfPointer )
{
	if ( self->CharSize == 2 )  OffsetOfPointer += sizeof(wchar_t);
	IF( OffsetOfPointer < 0  ||  OffsetOfPointer >= (int) self->BufferSize ) return  E_INVALID_VALUE;
	self->Pointer = (char*) self->Buffer + OffsetOfPointer;
	return  0;
}


/*[StrFile_getPointer]*/
errnum_t  StrFile_getPointer( StrFile* self, int* out_OffsetOfPointer )
{
	if ( (uintptr_t) self->Pointer == 0xFFFFFFFF )
		{ *out_OffsetOfPointer = self->BufferSize; }
	else
		{ *out_OffsetOfPointer = (char*) self->Pointer - (char*) self->Buffer; }
	return  0;
}


//[StrFile_isAtEndOfStream]
bool  StrFile_isAtEndOfStream( StrFile* self )
{
	return  self->Pointer == (void*)0xFFFFFFFF;
}


//[StrFile_isInited]
errnum_t  StrFile_isInited( StrFile* self )
{
	return  self->Buffer != NULL;
}


 
/***********************************************************************
  <<< (SearchStringByBM_Class) >>> 
************************************************************************/
errnum_t  SearchStringByBM_Class_allocateSkipArray_Sub( SearchStringByBM_Class* self );


/*[SearchStringByBM_Class_initConst]*/
void  SearchStringByBM_Class_initConst( SearchStringByBM_Class* self )
{
	self->SkipArray = NULL;
}


/*[SearchStringByBM_Class_initialize]*/
errnum_t  SearchStringByBM_Class_initialize( SearchStringByBM_Class* self,
	const TCHAR* TextString,  const TCHAR* Keyword )
{
	return  SearchStringByBM_Class_initializeFromPart( self,
		TextString,  _tcslen( TextString ),  Keyword );
}


/*[SearchStringByBM_Class_initializeFromPart]*/
errnum_t  SearchStringByBM_Class_initializeFromPart( SearchStringByBM_Class* self,
	const TCHAR* TextString,  size_t TextString_Length,  const TCHAR* Keyword )
{
	self->TextString = TextString;
	self->TextStringLength = TextString_Length;
	self->Keyword = Keyword;

	/* 他のメンバー変数は、次の関数の中で初期化する */
	return  SearchStringByBM_Class_allocateSkipArray_Sub( self );
}


/*[SearchStringByBM_Class_finalize]*/
errnum_t  SearchStringByBM_Class_finalize( SearchStringByBM_Class* self, errnum_t e )
{
	if ( self->SkipArray != NULL ) {
		free( self->SkipArray );
		self->SkipArray = NULL;
	}

	return  e;
}


/***********************************************************************
  <<< [SearchStringByBM_Class_getSkipCount_Sub] >>> 
 - Boyer-Moore法の skip 関数
************************************************************************/
inline int  SearchStringByBM_Class_getSkipCount_Sub(
	TCHAR TextCharacter, int KeywordLastIndex,
	int* SkipArray, int SkipArray_MinCharacter, int SkipArray_MaxCharacter )
{
	if (
			TextCharacter < SkipArray_MinCharacter  ||
			TextCharacter > SkipArray_MaxCharacter ) {
		return  KeywordLastIndex + 1;
	}
	else {
		return  SkipArray[ TextCharacter - SkipArray_MinCharacter ];
	}
}


/***********************************************************************
  <<< [SearchStringByBM_Class_search] >>> 
 - Boyer-Moore法
 - 情報検索アルゴリズム p106 の C言語版
************************************************************************/
errnum_t  SearchStringByBM_Class_search( SearchStringByBM_Class* self, int* out_KeywordIndex )
{
	const TCHAR*  test_string = self->TextString;
	const TCHAR*  keyword = self->Keyword;
	int           text_string_length = self->TextStringLength;        /* m */
	int           keyword_last_index = self->KeywordLastIndex;        /* n - 1 */
	int           keyword_last_position = self->KeywordLastPosition;  /* pos - 1 */
	int           skip_count;
	int*          skip_array = self->SkipArray;
	TCHAR         min_character = self->SkipArray_MinCharacter;
	TCHAR         max_character = self->SkipArray_MaxCharacter;

	*out_KeywordIndex = SearchString_NotFound;


	while ( keyword_last_position < text_string_length ) {

		/* 次の照合位置へ (1) */
		skip_count = SearchStringByBM_Class_getSkipCount_Sub(
			test_string[ keyword_last_position ],
			keyword_last_index,  skip_array,  min_character,  max_character );


		/* 末尾の照合が成功したら */
		if ( test_string[ keyword_last_position ] == keyword[ keyword_last_index ] ) {

			/* 末尾から照合する */
			int  text_string_index = keyword_last_position - 1;  /* k - 1 */
			int  keyword_index = keyword_last_index - 1;         /* j - 1 */

			for (;;) {
				/* キーワード全体の照合に成功したら */
				if ( keyword_index < 0 ) {
					*out_KeywordIndex = text_string_index + 1;
					self->KeywordLastPosition = keyword_last_position + skip_count;
					goto  fin;
				}

				/* 照合が失敗したら */
				if ( test_string[ text_string_index ] != keyword[ keyword_index ] ) {
					break;
				}

				/* １つ前の文字へ */
				text_string_index -= 1;
				keyword_index -= 1;
			}
		}
		/* 次の照合位置へ (2) */
		keyword_last_position += skip_count;
	}

fin:
	return  0;
}


/***********************************************************************
  <<< [SearchStringByBM_Class_allocateSkipArray_Sub] >>> 
 - Boyer-Moore法の skip 関数を作成する関数
 - 情報検索アルゴリズム p107 の C言語版は、下記 Set "self->SkipArray" 以降
************************************************************************/
errnum_t  SearchStringByBM_Class_allocateSkipArray_Sub( SearchStringByBM_Class* self )
{
	const TCHAR*  keyword = self->Keyword;
	const TCHAR*  p;  /* Pointer to "keyword" */
	TCHAR         c;  /* Character in "keyword" */
	TCHAR         min_character;
	TCHAR         max_character;
	int           keyword_length;
	const TCHAR*  keyword_last_pointer;
	int*          skip_array = NULL;
	errnum_t      e;


	/* Set "self->SkipArray_MinCharacter", "self->SkipArray_MaxCharacter" */
	c = *keyword;
	IF ( c == _T('\0') ) { e=E_OTHERS; goto fin; }
	min_character = c;
	max_character = c;
	p = keyword + 1;
	for (;;) {
		c = *p;
		if ( c == _T('\0') ) { break; }

		if ( c < min_character ) { min_character = c; }
		if ( c > max_character ) { max_character = c; }

		p += 1;
	}
	self->SkipArray_MinCharacter = min_character;
	self->SkipArray_MaxCharacter = max_character;


	/* Set ... */
	keyword_length            = p - keyword;
	self->KeywordLastIndex    = keyword_length - 1;
	self->KeywordLastPosition = keyword_length - 1;


	/* Set "self->SkipArray" */
	skip_array = malloc( ( max_character - min_character + 1 ) * sizeof(int) );
		IF ( skip_array == NULL ) { e=E_FEW_ARRAY; goto fin; }

	for ( c = min_character;  c <= max_character;  c += 1 ) {
		/* キーワードに使われていない文字について */
		skip_array[ c - min_character ] = keyword_length;
	}

	keyword_last_pointer = &keyword[ keyword_length - 1 ];
	for (
		p = keyword;
		p < keyword_last_pointer;
		p += 1 ) {

		/* キーワードに使われている文字について */
		/* キーワードの中に同じ文字があるときは、後ろの文字の位置が優先される */
		skip_array[ *p - min_character ] = keyword_last_pointer - p;
	}


	e=0;
fin:
	if (e) {
		if ( skip_array != NULL ) {
			free( skip_array );
			skip_array = NULL;
		}
	}
	self->SkipArray = skip_array;
	return  e;
}


 
/***********************************************************************
  <<< (SearchStringByAC_Class) >>> 
************************************************************************/
errnum_t  SearchStringByAC_Class_makeFunctionsStep1( SearchStringByAC_Class* self,
	const TCHAR** KeywordArray, unsigned KeywordArrayCount );
errnum_t  SearchStringByAC_Class_makeFunctionsStep2( SearchStringByAC_Class* self );
errnum_t  SearchStringByAC_Class_increaseState( SearchStringByAC_Class* self );
errnum_t  SearchStringByAC_Class_addOutputFunction( SearchStringByAC_Class* self,
	int State, const TCHAR* Keyword );
errnum_t  SearchStringByAC_Class_addOutputFunctions( SearchStringByAC_Class* self,
	int TargetState, int SourceState );


/***********************************************************************
  <<< [SearchStringByAC_Class_initConst] >>> 
************************************************************************/
void  SearchStringByAC_Class_initConst( SearchStringByAC_Class* self )
{
	Set2_initConst( &self->GoToFunction );
	self->FailureFunction = NULL;
	self->OutputFunction = NULL;
	self->OutputCount = NULL;
}


/***********************************************************************
  <<< [SearchStringByAC_Class_initialize] >>> 
************************************************************************/
errnum_t  SearchStringByAC_Class_initialize( SearchStringByAC_Class* self,
	const TCHAR* TextString, const TCHAR** KeywordArray, size_t KeywordArrayCount )
{
	return  SearchStringByAC_Class_initializeFromPart(
		self, TextString, _tcslen( TextString ), KeywordArray, KeywordArrayCount );
}


/***********************************************************************
  <<< [SearchStringByAC_Class_initializeFromPart] >>> 
************************************************************************/
errnum_t  SearchStringByAC_Class_initializeFromPart( SearchStringByAC_Class* self,
	const TCHAR* TextString,  size_t TextString_Length,
	const TCHAR** KeywordArray,  size_t KeywordArrayCount )
{
	errnum_t  e;

	self->StateNum = SearchStringByAC_RootState;
	self->TextString = TextString;
	self->TextStringLength = TextString_Length;
	self->TextStringIndex = 0;
	self->FoundKeywords = NULL;

	e= Set2_init( &self->GoToFunction, 0x1000 ); IF(e){goto fin;}
	self->FailureFunction = NULL;
	self->OutputFunction = NULL;
	self->OutputCount = NULL;
	self->StateCount = 0;

	/* Make functions */
	e= SearchStringByAC_Class_makeFunctionsStep1( self, KeywordArray, KeywordArrayCount );
		IF(e){goto fin;}
	e= SearchStringByAC_Class_makeFunctionsStep2( self );
		IF(e){goto fin;}

	e=0;
fin:
	if (e) {
		SearchStringByAC_Class_finalize( self, e );
	}
	return  e;
}


/***********************************************************************
  <<< [SearchStringByAC_Class_finalize] >>> 
************************************************************************/
errnum_t  SearchStringByAC_Class_finalize( SearchStringByAC_Class* self, errnum_t e )
{
	e= Set2_finish( &self->GoToFunction, e );

	if ( self->FailureFunction != NULL ) {
		free( self->FailureFunction );
		self->FailureFunction = NULL;
	}
	if ( self->OutputFunction != NULL ) {
		int  i;

		for ( i = 0;  i < self->StateCount; i += 1 ) {
			const TCHAR**  keywords = self->OutputFunction[i];
				
			if ( keywords != NULL ) {
				free( (void*) keywords );
			}
		}
		free( (void*) self->OutputFunction );
		self->OutputFunction = NULL;
	}
	if ( self->OutputCount != NULL ) {
		free( self->OutputCount );
		self->OutputCount = NULL;
	}
	return  e;
}


/***********************************************************************
  <<< [SearchStringByAC_Class_search] >>> 
 - Aho-Corasick法(AC法)の検索をする関数
 - 情報検索アルゴリズム p112 の C言語版は、本関数の for 文以降
************************************************************************/
errnum_t  SearchStringByAC_Class_search( SearchStringByAC_Class* self,
	int* out_TextStringIndex, TCHAR** out_Keyword )
{
	int                  state_num = self->StateNum;                   /* s */
	const TCHAR*         text_string = self->TextString;               /* text */
	int                  text_string_length = self->TextStringLength;  /* m */
	int                  text_string_index = self->TextStringIndex;    /* i - 1 */
	AC_GotoFunctionType  goto_function = (AC_GotoFunctionType) self->GoToFunction.First;  /* g */
	int*                 failure_function = self->FailureFunction;     /* f */
	const TCHAR***       output_function = self->OutputFunction;       /* output */
	int                  next_state_num;
	const TCHAR**        found_keywords = self->FoundKeywords;
	errnum_t             e;


	/* 前回マッチしたキーワードの続きを出力する */
	if ( found_keywords != NULL ) {
		int           found_keyword_index = self->FoundKeywordIndex + 1;
		const TCHAR*  keyword;

		if ( found_keyword_index < self->FoundKeywordsCount ) {
			keyword = found_keywords[ found_keyword_index ];

			*out_Keyword = (TCHAR*) keyword;
			*out_TextStringIndex = text_string_index + 1 - _tcslen( keyword );
			self->FoundKeywordIndex = found_keyword_index;
			return  0;
		}
		self->FoundKeywords = NULL;
		text_string_index += 1;
	}

	/* テキストの中を１文字ずつ調べる */
	for ( /* "text_string_index" is already set */;
			text_string_index < text_string_length;
			text_string_index += 1 ) {

		for (;;) {
			TCHAR  a_character = text_string[ text_string_index ];

			/* AC法の goto 関数を使って、次の状態に遷移する */
#if 0
			ASSERT_R( text_string[ text_string_index ] <= SearchStringByAC_MaxCharacterCode,
				e=E_OTHERS; goto fin );
#else
if ( a_character > SearchStringByAC_MaxCharacterCode ) {
	a_character = _T('\0');
}
#endif
			next_state_num = goto_function[ state_num ][ a_character ];

			/* AC法の goto 関数が fail したら、failure 関数を使って、 */
			/* 次の状態に遷移して、再び goto 関数を使う */
			if ( next_state_num == SearchStringByAC_Fail ) {
				if ( state_num == SearchStringByAC_RootState ) {
					next_state_num = SearchStringByAC_RootState;
					break;
				}
				state_num = failure_function[ state_num ];
			}
			else
				{ break; }
		}
		state_num = next_state_num;

		/* AC法の output 関数を使って、マッチしたキーワードを出力する */
		found_keywords = output_function[ state_num ];
		if ( found_keywords != NULL ) {
			const int     first_keyword_index = 0;
			const TCHAR*  keyword = found_keywords[ first_keyword_index ];

			*out_Keyword = (TCHAR*) keyword;
			*out_TextStringIndex = text_string_index + 1 - _tcslen( keyword );
			self->FoundKeywords = found_keywords;
			self->FoundKeywordsCount = self->OutputCount[ state_num ];
			self->FoundKeywordIndex = first_keyword_index;
			self->TextStringIndex = text_string_index;
			self->StateNum = state_num;
			e=0; goto fin;
		}
	}

	/* テキストの最後まで調べた後 */
	*out_Keyword = NULL;
	*out_TextStringIndex = SearchString_NotFound;
	self->FoundKeywords = NULL;

	e=0;
fin:
	return  e;
}


/***********************************************************************
  <<< [SearchStringByAC_Class_setTextString] >>> 
************************************************************************/
errnum_t  SearchStringByAC_Class_setTextString( SearchStringByAC_Class* self,
	const TCHAR* TextString )
{
	return  SearchStringByAC_Class_setTextStringFromPart( self,
		TextString, _tcslen( TextString ) );
}


/***********************************************************************
  <<< [SearchStringByAC_Class_setTextStringFromPart] >>> 
************************************************************************/
errnum_t  SearchStringByAC_Class_setTextStringFromPart( SearchStringByAC_Class* self,
	const TCHAR* TextString,  size_t TextString_Length )
{
	self->StateNum = SearchStringByAC_RootState;
	self->TextString = TextString;
	self->TextStringLength = TextString_Length;
	self->TextStringIndex = 0;
	self->FoundKeywords = NULL;

	return  0;
}


/***********************************************************************
  <<< [SearchStringByAC_Class_makeFunctionsStep1] >>> 
 - Aho-Corasick法(AC法)の goto 関数と output 関数を作成する
 - 情報検索アルゴリズム p117 の C言語版
************************************************************************/
errnum_t  SearchStringByAC_Class_makeFunctionsStep1( SearchStringByAC_Class* self,
	const TCHAR** KeywordArray, unsigned KeywordArrayCount )
{
	errnum_t  e;
	unsigned  keyword_num;

	AC_GotoFunctionType  goto_function;  /* g */

	e= SearchStringByAC_Class_increaseState( self ); IF(e){goto fin;}
		/* newstate = 0; */ /* self->StateCount - 1 */
	goto_function = (AC_GotoFunctionType) self->GoToFunction.First;  /* g */

	for ( keyword_num = 0;  keyword_num < KeywordArrayCount;  keyword_num += 1 ) {
		const TCHAR*  keyword = KeywordArray[ keyword_num ];
		int  keyword_length = _tcslen( keyword );  /* n */
		int  keyword_index;  /* j - 1, p - 1 */
		int  state;
		int  next_state;

		state = SearchStringByAC_RootState;
		keyword_index = 0;

		/* 既に登録されている goto 関数は新たに定義しない */
		for (;;) {
			ASSERT_R( keyword[ keyword_index ] <= SearchStringByAC_MaxCharacterCode,
				e=E_OTHERS; goto fin );
			next_state = goto_function[ state ][ keyword[ keyword_index ] ];
			if ( next_state != SearchStringByAC_Fail ) {
				state = next_state;
				keyword_index += 1;
			}
			else
				{ break; }
		}

		/* 新しい状態へ遷移する goto 関数を定義する */
		while ( keyword_index < keyword_length ) {
			int16_t  new_state = self->StateCount;

			e= SearchStringByAC_Class_increaseState( self );
				/* newstate += 1; */
				IF(e){goto fin;}
			goto_function = (AC_GotoFunctionType) self->GoToFunction.First;  /* g */
			ASSERT_R( keyword[ keyword_index ] <= SearchStringByAC_MaxCharacterCode,
				e=E_OTHERS; goto fin );
			goto_function[ state ][ keyword[ keyword_index ] ] = new_state;
			state = new_state;
			keyword_index += 1;
		}
		e= SearchStringByAC_Class_addOutputFunction( self, state, keyword );
			IF(e){goto fin;}
	}

	e=0;
fin:
	return  e;
}


/***********************************************************************
  <<< [SearchStringByAC_Class_makeFunctionsStep2] >>> 
 - Aho-Corasick法(AC法)の failure 関数の作成と output 関数の更新をする
 - 情報検索アルゴリズム p122 の C言語版
************************************************************************/
errnum_t  SearchStringByAC_Class_makeFunctionsStep2( SearchStringByAC_Class* self )
{
	errnum_t  e;
	uint32_t  ch;          /* Character(文字) TCHAR型にしないのは、ループを終了させるため */
	int    state;          /* s */
	int*   queue = NULL;
	int    enqueue_index;
	int    dequeue_index;
	int*   failure_function = NULL;
	AC_GotoFunctionType  goto_function = (AC_GotoFunctionType) self->GoToFunction.First;


	/* キューを初期化する */
	queue = (int*) malloc( sizeof(int) * self->StateCount );
		IF( queue == NULL ) { e=E_FEW_MEMORY; goto fin; }
	enqueue_index = 0;
	dequeue_index = 0;

	/* failure 関数を初期化する */
	failure_function = (int*) malloc( sizeof(int) * self->StateCount );
		IF( failure_function == NULL ) { e=E_FEW_MEMORY; goto fin; }

	/* 深さが１の failure 関数の出力を０にする */
	for ( ch = 0;  ch <= SearchStringByAC_MaxCharacterCode;  ch += 1 ) {
		state = goto_function[ SearchStringByAC_RootState ][ ch ];
		if ( state == SearchStringByAC_Fail ) { continue; }

		
		/* 状態 0(=SearchStringByAC_RootState) の遷移先の状態をキューに追加する */
		queue[ enqueue_index ] = state;
		enqueue_index += 1;

		failure_function[ state ] = SearchStringByAC_RootState;
	}

	while ( enqueue_index > dequeue_index ) {
		int  back_state;      /* r */
		int  back_new_state;  /* state, p */
		int  new_state;       /* q */

		/* キューから取り出した状態を、１つ浅い状態 r とする */
		back_state = queue[ dequeue_index ];
		dequeue_index += 1;

		for ( ch = 0;  ch <= SearchStringByAC_MaxCharacterCode;  ch += 1 ) {
			state = goto_function[ back_state ][ ch ];
			if ( state == SearchStringByAC_Fail ) { continue; }

			/* back_state の遷移先の状態をキューに追加する */
			queue[ enqueue_index ] = state;
			enqueue_index += 1;

			/* 0～state からなる文字列の、最長の接尾辞 0～new_state を探す */
			back_new_state = failure_function[ back_state ];
			for (;;) {
				new_state = goto_function[ back_new_state ][ ch ];
				if ( new_state == SearchStringByAC_Fail ) {
					if ( back_new_state == SearchStringByAC_RootState ) {
						new_state = SearchStringByAC_RootState;
						break;
					}
					back_new_state = failure_function[ back_new_state ];
				}
				else
					{ break; }
			}
			failure_function[ state ] = new_state;

			/* output 関数を更新する */
			e= SearchStringByAC_Class_addOutputFunctions(
				self, state, failure_function[ state ] );
				IF(e){goto fin;}
		}
	}

	self->FailureFunction = failure_function;
	failure_function = NULL;

	e=0;
fin:
	if ( queue != NULL ) { free( queue ); }
	if ( failure_function != NULL ) { free( failure_function ); }
	return  e;
}


/***********************************************************************
  <<< [SearchStringByAC_Class_increaseState] >>> 
************************************************************************/
errnum_t  SearchStringByAC_Class_increaseState( SearchStringByAC_Class* self )
{
	errnum_t  e;
	AC_GotoFunctionType  new_goto_function;
	const TCHAR***       new_output_function;
	int*                 new_output_count;
	int16_t              new_state_count = self->StateCount + 1;


	/* goto 関数に相当するメモリー領域を増やす */
	e= Set2_allocate( &self->GoToFunction, &new_goto_function ); IF(e){goto fin;}
#if 0 //[TODO]
printf( "goto funcion  %d/%d \n",
Set2_getCount(    &self->GoToFunction, *new_goto_function ),
Set2_getCountMax( &self->GoToFunction, *new_goto_function ) );
#endif

	/* 新しい state の goto 関数を 0(=SearchStringByAC_Fail) で初期化する */
	memset( new_goto_function, 0, sizeof(*new_goto_function) );


	/* output 関数に相当するメモリー領域を増やす */
	new_output_function = (const TCHAR***) realloc( (void*) self->OutputFunction,
		sizeof(self->OutputFunction[0]) * new_state_count );
		IF ( new_output_function == NULL ) { e=E_FEW_MEMORY; goto fin; }
	new_output_function[ new_state_count - 1 ] = NULL;

	new_output_count = (int*) realloc( self->OutputCount,
		sizeof(self->OutputCount[0]) * new_state_count );
		IF ( new_output_count == NULL ) { e=E_FEW_MEMORY; goto fin; }
	new_output_count[ new_state_count - 1 ] = 0;


	/* Set "self->..." */
	self->OutputFunction = new_output_function;
	self->OutputCount    = new_output_count;
	self->StateCount     = new_state_count;

	e=0;
fin:
	return  e;
}


/***********************************************************************
  <<< [SearchStringByAC_Class_addOutputFunction] >>> 
************************************************************************/
errnum_t  SearchStringByAC_Class_addOutputFunction( SearchStringByAC_Class* self,
	int State, const TCHAR* Keyword )
{
	errnum_t       e;
	const TCHAR**  new_keywords = NULL;
	int            old_count = self->OutputCount[ State ];

	new_keywords = (const TCHAR**) realloc( (void*) self->OutputFunction[ State ],
		sizeof(const TCHAR*) * (old_count + 1) );
		IF ( new_keywords == NULL ) { e=E_FEW_MEMORY; goto fin; }
	new_keywords[ old_count ] = Keyword;

	self->OutputFunction[ State ] = new_keywords;
	self->OutputCount[ State ] = old_count + 1;

	e=0;
fin:
	return  e;
}


/***********************************************************************
  <<< [SearchStringByAC_Class_addOutputFunctions] >>> 
************************************************************************/
errnum_t  SearchStringByAC_Class_addOutputFunctions( SearchStringByAC_Class* self,
	int TargetState, int SourceState )
{
	errnum_t       e;
	const TCHAR**  keywords = self->OutputFunction[ SourceState ];
	int            i;
	int            count = self->OutputCount[ SourceState ];

	for ( i = 0;  i < count;  i += 1 ) {
		e= SearchStringByAC_Class_addOutputFunction( self,
			TargetState, keywords[ i ] );
			IF(e){goto fin;}
	}

	e=0;
fin:
	return  e;
}


 
/*=================================================================*/
/* <<< [DebugTools/DebugTools.c] >>> */ 
/*=================================================================*/
 
/**************************************************************************
  <<< (g_DebugVar) >>> 
***************************************************************************/
int  g_DebugVar[10];


 
/**************************************************************************
  <<< (DebugTools) >>> 
***************************************************************************/
#if DEBUGTOOLS_USES
#define  DebugTools_get() (&g_DebugTools)
extern  DebugTools  g_DebugTools;


DebugTools  g_DebugTools;


int  Debug_setReturnValueOnBreak( int ID )
{
	DebugTools*  m = DebugTools_get();
	m->m_ReturnValueOnBreak_minus1 = ID - 1;
	return  0;
}

int  Debug_disableBreak( int iExceptID )
{
	DebugTools*  m = DebugTools_get();
	m->m_DisableBreakExceptID_plus1 = iExceptID + 1;
	return  0;
}

int  Debug_setBreakByFName( const TCHAR* Path )
{
	DebugTools*  m = DebugTools_get();
	return  MallocAndCopyString( &m->m_BreakByFName, Path );
}

int  Debug_onBreakCase( DebugTools* m )
{
	m->m_BreakID ++;
	if ( m->m_DisableBreakExceptID_plus1 == 0 || m->m_BreakID == m->m_DisableBreakExceptID_plus1 - 1 ) {
		// DebugBreakR();
		if ( m->m_ReturnValueOnBreak_minus1 == 0 )  return  E_DEBUG_BREAK;
		return  m->m_ReturnValueOnBreak_minus1 + 1;
	}
	else {
		_tprintf( _T("[BREAK]\n") );
		return 0;
	}
}


TCHAR*  StrT_refFName( const TCHAR* s );

int  Debug_onOpen( const TCHAR* Path )
{
	DebugTools*  m = DebugTools_get();

	if ( m->m_BreakByFName != NULL &&
			 _tcsicmp( m->m_BreakByFName, StrT_refFName( Path ) ) == 0 ) {
		return  Debug_onBreakCase( m );
	}
	return  0;
}

#endif

 
/***********************************************************************
  <<< [HeapLogWatchClass] >>> 
************************************************************************/
typedef struct _HeapLogWatchClass  HeapLogWatchClass;
struct _HeapLogWatchClass {
	int        AllocatedID;
	ptrdiff_t  Offset;
	uint32_t   BreakValue;
	bool       IsPrintf;
	bool       IsEnabled;
};
HeapLogWatchClass  g_HeapLogWatch[ 10 ];


/***********************************************************************
  <<< (HeapLogClass) >>> 
************************************************************************/
typedef struct _HeapLogClass  HeapLogClass;
struct _HeapLogClass {
	void**   Addresses;
	size_t*  Sizes;
	int      Count;
	int      CountMax;
};

HeapLogClass  g_HeapLog;


/***********************************************************************
  <<< [HeapLogClass_log] >>> 
************************************************************************/
void  HeapLogClass_log( void*  in_Address,  size_t  in_Size )
{
	errnum_t  e;
	int       i;

	while ( g_HeapLog.Count >= g_HeapLog.CountMax ) {
		void*  new_address;
		int    new_count_max = g_HeapLog.CountMax * 2 + 4;

		new_address = realloc_no_redirected( g_HeapLog.Addresses,  new_count_max * sizeof( *g_HeapLog.Addresses ) );
		if ( new_address == NULL ) { e=E_FEW_MEMORY; goto fin; }
		g_HeapLog.Addresses = (void**) new_address;

		new_address = realloc_no_redirected( g_HeapLog.Sizes,  new_count_max * sizeof( *g_HeapLog.Sizes ) );
		if ( new_address == NULL ) { e=E_FEW_MEMORY; goto fin; }
		g_HeapLog.Sizes = (size_t*) new_address;

		g_HeapLog.CountMax = new_count_max;
	}

	g_HeapLog.Addresses[ g_HeapLog.Count ] = in_Address;
	g_HeapLog.Sizes[     g_HeapLog.Count ] = in_Size;
	g_HeapLog.Count += 1;


	for ( i = 0;  i < _countof( g_HeapLogWatch );  i += 1 ) {
		HeapLogWatchClass*  watch = &g_HeapLogWatch[ i ];

		if ( watch->IsEnabled ) {
			if ( watch->AllocatedID == g_HeapLog.Count ) {
				if ( watch->IsPrintf ) {
					printf( "<HeapLogClass_log  event=\"Allocated\"  index=\"%d\"/>\n",
						i );
				}
			}
		}
	}

fin:
	return;
}


/***********************************************************************
  <<< [HeapLogClass_getID] >>> 
************************************************************************/
int   HeapLogClass_getID( const void*  in_Address )
{
	int  i;

	for ( i = g_HeapLog.Count - 1;  i >= 0;  i -= 1 ) {
		const void*  start = g_HeapLog.Addresses[ i ];
		const void*  over;

		over = g_HeapLog.Addresses[ i ];
		PointerType_plus( &over, g_HeapLog.Sizes[ i ] );

		if ( start <= in_Address  &&  in_Address < over ) {
			break;
		}
	}
	return  i;
}


/***********************************************************************
  <<< [HeapLogClass_printID] >>> 
************************************************************************/
void   HeapLogClass_printID( const void*  in_Address )
{
	int        block_ID = HeapLogClass_getID( in_Address );
	ptrdiff_t  offset;

	if ( block_ID != HeapLogClass_NotAllocatedID ) {
		offset = PointerType_diff( in_Address, g_HeapLog.Addresses[ block_ID ] );
	}
	else {
		offset = 0;
	}

	printf( "<HeapLogClass_printID  allocated_id=\"%d\"  offset=\"0x%04X\"/>\n",
		block_ID,  offset );
}


/***********************************************************************
  <<< [HeapLogClass_addWatch] >>> 
************************************************************************/
void  HeapLogClass_addWatch( int  in_IndexNum,  int  in_AllocatedID,  ptrdiff_t  in_Offset,
	uint32_t  in_BreakValue,  bool  in_IsPrintf )
{
	HeapLogWatchClass*  watch = &g_HeapLogWatch[ in_IndexNum ];

	if ( in_IndexNum >= _countof( g_HeapLogWatch ) ) {
		printf( "HeapLogClass_addWatch: Error of IndexNum (%d)\n", in_IndexNum );
		return;
	}

	if ( in_IsPrintf ) {
		printf( "<HeapLogClass_addWatch  index=\"%d\"  allocated_id=\"%d\"  offset=\"0x%04X\"/>\n",
			in_IndexNum,  in_AllocatedID,  in_Offset );
	}
	watch->AllocatedID = in_AllocatedID;
	watch->Offset = in_Offset;
	watch->BreakValue = in_BreakValue;
	watch->IsPrintf = in_IsPrintf;
	watch->IsEnabled = true;
}


/***********************************************************************
  <<< [HeapLogClass_watch] >>> 
************************************************************************/
void  HeapLogClass_watch( int  in_IndexNum )
{
	HeapLogWatchClass*  watch = &g_HeapLogWatch[ in_IndexNum ];

	uint32_t  value;


	if ( in_IndexNum >= _countof( g_HeapLogWatch ) ) {
		printf( "HeapLogClass_addWatch: Error of IndexNum (%d)\n", in_IndexNum );
		return;
	}

	if ( watch->IsEnabled  &&  g_HeapLog.Count > watch->AllocatedID ) {
		const void*  pointer = g_HeapLog.Addresses[ watch->AllocatedID ];

		PointerType_plus( &pointer,  watch->Offset );
		value = *(uint32_t*) pointer;

		if ( watch->IsPrintf ) {
			printf( "<HeapLogClass_watch  index=\"%d\"  value=\"%d\"  value16=\"0x%08X\"/>\n",
				in_IndexNum,  value,  value );
		}
		if ( value == watch->BreakValue ) { DebugBreakR(); }
	}

}


/***********************************************************************
  <<< [HeapLogClass_getWatchingAddress] >>> 
************************************************************************/
void*  HeapLogClass_getWatchingAddress( int  in_IndexNum )
{
	HeapLogWatchClass*  watch = &g_HeapLogWatch[ in_IndexNum ];
	void*  return_value;


	if ( in_IndexNum >= _countof( g_HeapLogWatch ) ) {
		printf( "HeapLogClass_addWatch: Error of IndexNum (%d)\n", in_IndexNum );
		return  NULL;
	}


	if ( watch->IsEnabled  &&  g_HeapLog.Count > watch->AllocatedID ) {
		return_value = g_HeapLog.Addresses[ watch->AllocatedID ];
		PointerType_plus( &return_value,  watch->Offset );
	} else {
		return_value = NULL;
	}

	return  return_value;
}


/***********************************************************************
  <<< [HeapLogClass_finalize] >>> 
************************************************************************/
void  HeapLogClass_finalize()
{
	if ( g_HeapLog.Addresses != NULL ) {
		free( g_HeapLog.Addresses );
		g_HeapLog.Addresses = NULL;
	}
	if ( g_HeapLog.Sizes != NULL ) {
		free( g_HeapLog.Sizes );
		g_HeapLog.Sizes = NULL;
	}
	g_HeapLog.Count = 0;
	g_HeapLog.CountMax = 0;
}


 
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
errnum_t  Set2_init( Set2* m, int FirstSize )
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
errnum_t  Set2_finish( Set2* m, errnum_t e )
{
	if ( m->First != NULL )  { free( m->First );  m->First = NULL; }
	return  e;
}

 
/***********************************************************************
  <<< [Set2_ref_imp] >>> 
************************************************************************/
errnum_t  Set2_ref_imp( Set2* m, int iElem, void* out_pElem, size_t ElemSize )
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
errnum_t  Set2_alloc_imp( Set2* m, void* pp, size_t size )
{
	errnum_t  e;

	e= Set2_expandIfOverByAddr( m, (char*) m->Next + size ); IF(e)goto fin;
	*(void**)pp = m->Next;
	m->Next = (char*) m->Next + size;

	DISCARD_BYTES( *(void**)pp, size );

	e=0;
fin:
	return  e;
}


/***********************************************************************
  <<< [Set2_allocMulti_sub] >>> 
************************************************************************/
errnum_t  Set2_allocMulti_sub( Set2* m, void* out_pElem, size_t ElemsSize )
{
	errnum_t  e;
	char*     p;

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
	if ( offset_of_over == 0 ) { offset_of_over = 0x100; }
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
  <<< [Set2_free_imp] >>> 
************************************************************************/
errnum_t  Set2_free_imp( Set2* self,  void* in_PointerOfPointer,  size_t  in_Size_ofElement,  errnum_t  e )
{
	void*  element;

	element = *(void**) in_PointerOfPointer;

	if ( element != NULL ) {
		if ( element != ( (byte_t*) self->Next - in_Size_ofElement ) ) {
			if ( e == 0 ) { e=E_OTHERS; }
		}
		else {
			#ifndef NDEBUG
				memset( element, 0xFE, in_Size_ofElement );
			#endif

			self->Next = element;

			*(void**) in_PointerOfPointer = NULL;
		}
	}
	return  e;
}


 
/***********************************************************************
  <<< [Set2_separate] >>> 
************************************************************************/
errnum_t  Set2_separate( Set2* m, int NextSize, void** allocate_Array )
{
	errnum_t  e;
	void*     p = m->First;

	if ( NextSize == 0 ) {
		m->First = NULL;
		m->Next  = NULL;
		m->Over  = NULL;
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
errnum_t  Set2_pop_imp( Set2* m, void* pp, size_t size )
{
	errnum_t  e;
	void*     p;

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
	m->PointerOfDebugArray = (void**) PointerOfDebugArray;
	*m->PointerOfDebugArray = m->First;
}
#endif


 
/***********************************************************************
  <<< [Set2a_init] >>> 
************************************************************************/
int  Set2a_init( Set2a* m, void* ArrInStack, size_t ArrInStack_Size )
{
	int  e;

	/* "m->First" is initialized in "Set2a_initConst" */

	m->Next = m->First;
	m->Over = (char*)m->First + ArrInStack_Size;

	ASSERT_D( m->First == ArrInStack,  e=E_OTHERS; goto fin );

	#ifdef _DEBUG
		m->PointerOfDebugArray = NULL;
	#endif

	e=0;
#ifdef _DEBUG
fin:
#else
	UNREFERENCED_VARIABLE( ArrInStack );
#endif
	return  e;
}


 
/***********************************************************************
  <<< [Set2a_alloc_imp] >>> 
************************************************************************/
int  Set2a_alloc_imp( Set2a* m, void* ArrInStack, void* out_Pointer, size_t ElemSize )
{
	int  e;

	e= Set2a_expandIfOverByAddr_imp( m, ArrInStack, (char*)m->Next + ElemSize ); IF(e)goto fin;
	*(void**)out_Pointer = m->Next;
	m->Next = (char*) m->Next + ElemSize;

	e=0;
fin:
	return  e;
}



 
/***********************************************************************
  <<< [Set2a_expandIfOverByAddr_imp] >>> 
************************************************************************/
int  Set2a_expandIfOverByAddr_imp( Set2a* m, void* ArrInStack, void* OverAddrBasedOnNowFirst )
{
	void*  new_memory;
	unsigned  ofs;

	if ( m->First == ArrInStack ) {
		ofs = (char*)m->Over - (char*)m->First;
		new_memory = malloc( ofs * 2 );
		IF( new_memory == NULL ) return  E_FEW_MEMORY;

		memcpy( new_memory, m->First, ofs * 2 );

		m->First = new_memory;
		m->Over  = (char*)new_memory + ofs * 2;
		m->Next  = (char*)new_memory + ofs;
		return  0;
	}
	else {
		return  Set2_expandIfOverByAddr_imp( (Set2*) m, OverAddrBasedOnNowFirst );
	}
}


 
/*-------------------------------------------------------------------------*/
/* <<<< ### (Set4) Class >>>> */ 
/*-------------------------------------------------------------------------*/


 
/****************************************************************
  <<< [Set4_init_imp] >>> 
*****************************************************************/
errnum_t  Set4_init_imp( Set4* self,  size_t in_ElementSize,  size_t in_FirstHeapSize )
{
	int  element_count;

	self->FirstBlock = NULL;
	self->CurrentBlockFirst = NULL;
	self->u.NextBlock = &self->FirstBlock;
	self->CurrentBlockNext = self->u.CurrentBlockOver;
	element_count = ( in_FirstHeapSize - sizeof(void*) ) / in_ElementSize;
	self->HeapSize = element_count * in_ElementSize + sizeof(void*);
	self->ElementSize = in_ElementSize;

	return  0;
}


 
/****************************************************************
  <<< [Set4_finish2_imp] >>> 
*****************************************************************/
errnum_t  Set4_finish2_imp( Set4* self,  errnum_t  e,  size_t in_ElementSize,  FinalizeFuncType  in_Type_Finalize )
{
	Set4Iter  p;

	ASSERT_D( self->ElementSize == in_ElementSize,  e= MergeError( e, E_OTHERS ); goto fin );

	for ( Set4_forEach_imp( self, &p, in_ElementSize ) ) {
		e= in_Type_Finalize( p.p, e );
	}

#ifndef NDEBUG
fin:
#endif
	return  e;
}


 
/****************************************************************
  <<< [Set4_finish2_imp2] >>> 
*****************************************************************/
errnum_t  Set4_finish2_imp2( Set4* self )
{
	byte_t*  p;
	byte_t*  p2;

	p = self->FirstBlock;
	while ( p != NULL ) {
		p2 = *(void**)( p + self->HeapSize - sizeof(void*) );
		free( p );
		p = p2;
	}

	return  0;
}


 
/****************************************************************
  <<< [Set4_alloc_imp] >>> 
*****************************************************************/
errnum_t  Set4_alloc_imp( Set4* self,  void* out_ElementPointer,  size_t  in_ElementSize )
{
	errnum_t  e;
	byte_t*   new_block;
	byte_t*   element;

	ASSERT_D( in_ElementSize == self->ElementSize,  e=E_OTHERS; goto fin );

	/* Add new element */
	if ( self->CurrentBlockNext == self->u.CurrentBlockOver ) {
		new_block = (byte_t*) malloc( self->HeapSize );
		IF ( new_block == NULL ) { e=E_FEW_MEMORY; goto fin; }
		element = new_block;

		*self->u.NextBlock = new_block;
		self->CurrentBlockNext = new_block + in_ElementSize;

		self->CurrentBlockFirst = new_block;
		self->u.CurrentBlockOver = new_block + self->HeapSize - sizeof(void*);
		*self->u.NextBlock = NULL;
	}

	/* Add existed element */
	else {
		ASSERT_D( self->CurrentBlockNext < self->u.CurrentBlockOver,  e=E_OTHERS; goto fin );
		element = self->CurrentBlockNext;
		self->CurrentBlockNext += in_ElementSize;
	}

	*(void**) out_ElementPointer = element;

	e=0;
fin:
	return  e;
}


 
/****************************************************************
  <<< [Set4_free_imp] >>> 
*****************************************************************/
errnum_t  Set4_free_imp( Set4* self,  void* in_out_ElementPointer,  size_t in_ElementSize,  errnum_t e0 )
{
	errnum_t  e;
	void*     element = *(void**) in_out_ElementPointer;

	ASSERT_D( in_ElementSize == self->ElementSize,  e=E_OTHERS; goto fin );

	if ( element != NULL ) {
		if ( self->CurrentBlockNext == self->CurrentBlockFirst ) {
			byte_t*  block;
			byte_t*  previous_block = NULL;
			byte_t*  previous_element;

			for (
				block = self->FirstBlock;
				block != NULL;
				block = *(byte_t**)( block + self->HeapSize - sizeof(void*) ) )
			{
				if ( block == self->CurrentBlockFirst )
					{ break; }

				previous_block = block;
			}
			ASSERT_R( previous_block != NULL,  e=E_OTHERS; goto fin );

			previous_element = previous_block + self->HeapSize - sizeof(void*) - in_ElementSize;
			ASSERT_R( element == previous_element,  e=E_ACCESS_DENIED; goto fin );

			free( block );
			self->CurrentBlockFirst = previous_block;
			self->CurrentBlockNext = previous_element;
			self->u.CurrentBlockOver = previous_element + in_ElementSize;
			*self->u.NextBlock = NULL;
		}
		else {
			byte_t*  previous_element = self->CurrentBlockNext - in_ElementSize;

			ASSERT_D( element == previous_element,  e=E_ACCESS_DENIED; goto fin );

			self->CurrentBlockNext = previous_element;
		}

		*(void**) in_out_ElementPointer = NULL;
	}

	e=0;
fin:
	if ( e0 == 0 )
		{ e0 = e; }
	return  e0;
}


 
/****************************************************************
  <<< [Set4_ref_imp] >>> 
*****************************************************************/
void*  Set4_ref_imp( Set4* self, int i, int size )
{
	byte_t*  p = self->FirstBlock;
	size_t   offset = i * size;
	size_t   offset_over = self->HeapSize - sizeof(void*);

	if ( i < 0 )  { return  NULL; }

	if ( p == NULL )  { return  NULL; }
	while ( offset >= offset_over ) {
		p = *(void**)( (char*)p + offset_over );
		if ( p == NULL )  { return  NULL; }
		offset -= offset_over;
	}

	p += offset;
	if ( p >= self->CurrentBlockNext )  { return  NULL; }

	return  p;
}


 
/****************************************************************
  <<< [Set4_getCount_imp] >>> 
*****************************************************************/
int  Set4_getCount_imp( Set4* self, int size )
{
	void*  p = self->FirstBlock;
	void*  p2 = NULL;
	int    offset = 0;
	int    offset_over = self->HeapSize - sizeof(void*);

	if ( p == NULL )  { return  0; }

	for (;;) {
		p2 = p;
		p = *(void**)( (char*)p + offset_over );
		if ( p == NULL )  break;
		offset += offset_over;
	}

	offset += (int)( (char*)self->CurrentBlockNext - (char*)p2 );

	return  offset / size;
}


 
/****************************************************************
  <<< [Set4_forEach_imp2] >>> 
*****************************************************************/
void  Set4_forEach_imp2( Set4* self, Set4Iter* p, int size )
{
	if ( p->p == NULL ) {  /* first */
		if ( self->FirstBlock == NULL )  return;  /* elem count = 0 */
		p->Over = &self->FirstBlock;
	}
	else {  /* The next of array */
		p->p = (char*)p->p + size;
		if ( p->p < p->Over )  return;
	}

	/* The last element */
	if ( p->p == self->CurrentBlockNext )  { p->p = NULL;  return; }

	/* The next element */
	p->p = *(void**) p->Over;
	p->Over = (char*)p->p + self->HeapSize - sizeof(void*);
	if ( *(void**)p->Over == NULL )  p->Over = self->CurrentBlockNext;
}


 
/***********************************************************************
  <<< (ListClass) >>> 
************************************************************************/

/*[ListClass_initConst]*/
void  ListClass_initConst( ListClass* self )
{
	self->Terminator.Data     = NULL;
	self->Terminator.List     = self;
	self->Terminator.Next     = &self->Terminator;
	self->Terminator.Previous = &self->Terminator;
	self->Count               = 0;
}


/*[ListClass_addAtIndex]*/
errnum_t  ListClass_addAtIndex( ListClass* self, int Index, ListElementClass* Element )
{
	errnum_t           e;
	ListElementClass*  target;

	if ( Index == self->Count ) {
		e= ListClass_addLast( self, Element ); IF(e){goto fin;}
	}
	else {
		e= ListClass_get( self, Index, &target ); IF(e){goto fin;}
		e= ListClass_addAt_Sub( Element, target ); IF(e){goto fin;}
	}

	e=0;
fin:
	return  e;
}


/*[ListClass_addAt_Sub]*/
errnum_t  ListClass_addAt_Sub( ListElementClass* AddingElement, ListElementClass* Target )
{
	errnum_t           e;
	ListElementClass*  target_previous = Target->Previous;
	ListClass*         self = Target->List;

	ASSERT_R( AddingElement->List == NULL,  e=E_ACCESS_DENIED; goto fin );

	AddingElement->Next = Target;
	AddingElement->Previous = target_previous;
	target_previous->Next = AddingElement;
	Target->Previous = AddingElement;
	AddingElement->List = self;
	self->Count += 1;

	e=0;
fin:
	return  e;
}


/*[ListClass_get]*/
errnum_t  ListClass_get( ListClass* self, int Index, ListElementClass** out_Element )
{
	errnum_t           e;
	ListElementClass*  element = self->Terminator.Next;

	ASSERT_R( Index >= 0  &&  Index < self->Count,  e=E_NOT_FOUND_SYMBOL; goto fin );

	while ( Index != 0 ) {
		element = element->Next;
		Index -= 1;
	}

	*out_Element = element;

	e=0;
fin:
	return  e;
}


/*[ListClass_set]*/
errnum_t  ListClass_set( ListClass* self, int Index, ListElementClass* Element )
{
	errnum_t           e;
	ListElementClass*  target;

	ASSERT_R( Element->List == NULL,  e=E_ACCESS_DENIED; goto fin );

	e= ListClass_get( self, Index, &target ); IF(e){goto fin;}
	e= ListClass_replace( self, target, Element ); IF(e){goto fin;}

	e=0;
fin:
	return  e;
}


/*[ListClass_replace]*/
errnum_t  ListClass_replace( ListClass* self, ListElementClass* RemovingElement,
	ListElementClass* AddingElement )
{
	errnum_t  e;

	ASSERT_R( RemovingElement->List == self,  e=E_NOT_FOUND_SYMBOL; goto fin );
	ASSERT_R( AddingElement->List == NULL,  e=E_ACCESS_DENIED; goto fin );
	ASSERT_R( RemovingElement != &RemovingElement->List->Terminator,
		e=E_NOT_FOUND_SYMBOL; goto fin );

	RemovingElement->Next->Previous  = AddingElement;
	RemovingElement->Previous->Next  = AddingElement;
	AddingElement->Next     = RemovingElement->Next;
	AddingElement->Previous = RemovingElement->Previous;

	AddingElement->List = self;

	RemovingElement->List  = NULL;
	#ifndef NDEBUG
		RemovingElement->Next     = NULL;
		RemovingElement->Previous = NULL;
	#endif

	e=0;
fin:
	return  e;
}


/*[ListClass_getIndexOfData]*/
int  ListClass_getIndexOfData( ListClass* self, void* Data )
{
	int                index;
	ListElementClass*  element    =  self->Terminator.Next;
	ListElementClass*  tarminator = &self->Terminator;

	for ( index = 0; ; index += 1 ) {
		if ( element == tarminator )
			{ return  INVALID_ARRAY_INDEX; }

		if ( element->Data == Data )
			{ return  index; }

		element = element->Next;
	}
}


/*[ListClass_getIndexOf]*/
int  ListClass_getIndexOf( ListClass* self, ListElementClass* Element )
{
	int                index;
	ListElementClass*  elem       =  self->Terminator.Next;
	ListElementClass*  tarminator = &self->Terminator;

	for ( index = 0; ; index += 1 ) {
		if ( elem == Element )
			{ return  index; }

		if ( elem == tarminator )
			{ return  INVALID_ARRAY_INDEX; }

		elem = elem->Next;
	}
}


/*[ListClass_getLastIndexOfData]*/
int  ListClass_getLastIndexOfData( ListClass* self, void* Data )
{
	int                index;
	ListElementClass*  element    =  self->Terminator.Previous;
	ListElementClass*  tarminator = &self->Terminator;

	for ( index = self->Count - 1; ; index -= 1 ) {
		if ( element == tarminator )
			{ return  INVALID_ARRAY_INDEX; }

		if ( element->Data == Data )
			{ return  index; }

		element = element->Previous;
	}
}


/*[ListClass_getArray]*/
errnum_t  ListClass_getArray( ListClass* self, void* DataArray, size_t DataArraySize )
{
	errnum_t           e;
	ListIteratorClass  iterator;
	void*              data;
	void**             data_pointer;

	ASSERT_R( DataArraySize >= self->Count * sizeof(void*),  e=E_FEW_ARRAY; goto fin );

	e= ListClass_getListIterator( self, &iterator ); IF(e){goto fin;}
	for ( data_pointer = (void**) DataArray;  ;  data_pointer += 1 ) {
		data = ListIteratorClass_getNext( &iterator );
			if ( data == NULL ) { break; }

		*data_pointer = data;
	}

	e=0;
fin:
	return  e;
}


/*[ListClass_removeByIndex]*/
errnum_t  ListClass_removeByIndex( ListClass* self, int Index )
{
	errnum_t           e;
	ListElementClass*  target;

	e= ListClass_get( self, Index, &target ); IF(e){goto fin;}
	e= ListClass_remove( self, target ); IF(e){goto fin;}

	e=0;
fin:
	return  e;
}


/*[ListClass_remove]*/
errnum_t  ListClass_remove( ListClass* self, ListElementClass* Element )
{
	if ( Element->List == self ) {
		Element->Previous->Next = Element->Next;
		Element->Next->Previous = Element->Previous;
		Element->List           = NULL;
		#ifndef NDEBUG
			Element->Next     = NULL;
			Element->Previous = NULL;
		#endif
		self->Count -= 1;
	}
	return  0;
}


/*[ListClass_clear]*/
errnum_t  ListClass_clear( ListClass* self )
{
	ListElementClass*  target = self->Terminator.Next;
	ListElementClass*  next;
	ListElementClass*  terminator = &self->Terminator;

	while ( target != terminator ) {
		target->List = NULL;

		next = target->Next;
		#ifndef NDEBUG
			target->Next     = NULL;
			target->Previous = NULL;
		#endif
		target = next;
	}

	self->Terminator.Next     = terminator;
	self->Terminator.Previous = terminator;
	self->Count = 0;

	return  0;
}


/*[ListIteratorClass_getNext]*/
void*  ListIteratorClass_getNext( ListIteratorClass* self )
{
	ListElementClass*  next = self->Element->Next;

	self->Element = next;

	if ( next == &next->List->Terminator )
		{ return  NULL; }
	else
		{ return  next->Data; }
}


/*[ListIteratorClass_getPrevious]*/
void*  ListIteratorClass_getPrevious( ListIteratorClass* self )
{
	ListElementClass*  previous = self->Element->Previous;

	self->Element = previous;

	if ( previous == &previous->List->Terminator )
		{ return  NULL; }
	else
		{ return  previous->Data; }
}


/*[ListIteratorClass_replace]*/
errnum_t  ListIteratorClass_replace( ListIteratorClass* self, ListElementClass* AddingElement )
{
	errnum_t  e;
	ListElementClass*  removing_element = self->Element;

	e= ListClass_replace( removing_element->List, removing_element, AddingElement );
		IF(e){goto fin;}
	self->Element = AddingElement;

	e=0;
fin:
	return  e;
}


/*[ListIteratorClass_remove]*/
errnum_t  ListIteratorClass_remove( ListIteratorClass* self )
{
	errnum_t  e;
	ListElementClass*  removing_element = self->Element;

	ASSERT_R( removing_element->List != NULL,  e=E_NOT_FOUND_SYMBOL; goto fin );
		/* Already removed */
	ASSERT_R( removing_element != &removing_element->List->Terminator,
		e=E_NOT_FOUND_SYMBOL; goto fin );  /* Over next or previous */

	self->ModifiedElement.Next     = removing_element->Next;
	self->ModifiedElement.Previous = removing_element->Previous;
	self->Element = &self->ModifiedElement;

	e= ListClass_remove( removing_element->List, removing_element ); IF(e){goto fin;}

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [ListClass_finalizeWithVTable] >>> 
************************************************************************/
errnum_t  ListClass_finalizeWithVTable( ListClass* self, bool IsFreeElements, errnum_t e )
{
	errnum_t               ee;
	ListIteratorClass      iterator;
	ClassID_SuperClass*    element;
	FinalizerVTableClass*  v_table;

	ee= ListClass_getListIterator( self, &iterator );
	IF ( ee ) {
		if ( e == 0 ) { e = ee; }
		goto fin;
	}

	for (;;) {
		element = (ClassID_SuperClass*) ListIteratorClass_getNext( &iterator );
			if ( element == NULL ) { break; }
		ee= ListIteratorClass_remove( &iterator );

		/* Call "Finalize" */
		v_table = (FinalizerVTableClass*) ClassID_Class_getVTable(
			element->ClassID, &g_FinalizerInterface_ID );
		IF ( v_table == NULL ) {
			if ( e == 0 ) { e=E_OTHERS; }
		}
		else {
			e= v_table->Finalize( element, e );
		}

		/* Call "HeapMemory_free" */
		if ( IsFreeElements ) {
			e= HeapMemory_free( &element, e );
		}
	}

fin:
	return  e;
}


 
/***********************************************************************
  <<< [ListClass_printXML] >>> 
************************************************************************/
errnum_t  ListClass_printXML( ListClass* self, FILE* OutputStream )
{
	errnum_t               e;
	ListIteratorClass      iterator;
	ClassID_SuperClass*    element;
	PrintXML_VTableClass*  v_table;

	e= ListClass_getListIterator( self, &iterator ); IF(e){goto fin;}
	for (;;) {
		element = (ClassID_SuperClass*) ListIteratorClass_getNext( &iterator );
			if ( element == NULL ) { break; }

		/* Call "PrintXML" */
		v_table = (PrintXML_VTableClass*) ClassID_Class_getVTable(
			element->ClassID, &g_PrintXML_Interface_ID );
		if ( v_table == NULL ) {
			_ftprintf_s( OutputStream, _T("<UnknownClass error=\"Not found PrintXML_VTable\"/>\n") );
		}
		else {
			e= v_table->PrintXML( element, OutputStream ); IF(e){goto fin;}
		}
	}

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< (VariantListClass) >>> 
************************************************************************/

/*[VariantListClass_initConst]*/
void  VariantListClass_initConst( VariantListClass* self )
{
	ListClass_initConst( &self->List );
}


/*[VariantListClass_finalize]*/
errnum_t  VariantListClass_finalize( VariantListClass* self, errnum_t e )
{
	errnum_t               ee;
	ListIteratorClass      iterator;
	VariantClass*          variant;

	ee= ListClass_getListIterator( &self->List, &iterator );
		IF (ee) {
			if ( e == 0 )  { e = ee; }
			goto fin;
		}

	for (;;) {
		variant = (VariantClass*) ListIteratorClass_getNext( &iterator );
			if ( variant == NULL ) { break; }
		ee= ListIteratorClass_remove( &iterator );
		if ( ee == 0 ) {
			Variant_SuperClass*    object = variant->Object;
			FinalizerVTableClass*  v_table;

			v_table = ClassID_Class_getVTable( object->ClassID, &g_FinalizerInterface_ID );
			if ( v_table != NULL ) {
				e= v_table->Finalize( object, e );
			}
			e= FreeMemory( &object, e );
			e= FreeMemory( &variant, e );
		}
	}

fin:
	return  e;
}


/*[VariantListClass_createElement]*/
errnum_t  VariantListClass_createElement( VariantListClass* self,
	void* /*<Variant_SuperClass**>*/ out_ElementObject,
	const ClassID_Class* ClassID,  void* Parameter )
{
	errnum_t             e;
	VariantClass*        variant = NULL;
	Variant_SuperClass*  object = NULL;
	InitializeFuncType   initialize;
	bool                 is_initialized = false;

	e= MallocMemory( &variant, sizeof( VariantClass ) );  IF(e){goto fin;}
	ListElementClass_initConst( &variant->ListElement, variant );

	e= MallocMemory( &object, ClassID->Size );  IF(e){goto fin;}
	initialize = ClassID->InitializeFunction;
	if ( initialize != NULL ) {
		e= initialize( object, Parameter );  IF(e){goto fin;}
	}
	is_initialized = true;

	variant->Object = object;
	object->StaticAddress = variant;
	e= ListClass_addLast( &self->List, &variant->ListElement ); IF(e){goto fin;}

	*(Variant_SuperClass**) out_ElementObject = object;

	e=0;
fin:
	if ( e != 0 ) {
		if ( is_initialized ) {
			FinalizerVTableClass*  v_table;

			v_table = ClassID_Class_getVTable( ClassID, &g_FinalizerInterface_ID );
			if ( v_table != NULL ) {
				e= v_table->Finalize( object, e );
			}
		}
		e= FreeMemory( &object, e );
		e= FreeMemory( &variant, e );
	}
	return  e;
}


/*[VariantListClass_destroyElement]*/
errnum_t  VariantListClass_destroyElement( VariantListClass* self,
	void* /*<Variant_SuperClass**>*/  in_out_ElementObject,  errnum_t e )
{
	errnum_t               ee;
	FinalizerVTableClass*  v_table;
	VariantClass*          variant;
	Variant_SuperClass*    object = *(Variant_SuperClass**) in_out_ElementObject;

	if ( object != NULL ) {
		variant = object->StaticAddress;

		ee= ListClass_remove( &self->List, &variant->ListElement );
		UNREFERENCED_VARIABLE( ee );

		v_table = ClassID_Class_getVTable( object->ClassID, &g_FinalizerInterface_ID );
		if ( v_table != NULL ) {
			e= v_table->Finalize( object, e );
		}
		e= FreeMemory( &object, e );
		e= FreeMemory( &variant, e );
	}
	*(Variant_SuperClass**) in_out_ElementObject = NULL;

	return  e;
}


 
/***********************************************************************
  <<< (Variant_SuperClass) >>> 
************************************************************************/
static const ClassID_Class*  gs_Variant_SuperClass_SuperClassIDs[] = {
    &g_ClassID_SuperClass_ID, &g_Variant_SuperClass_ID,
};

/*[g_Variant_SuperClass_ID]*/
const ClassID_Class  g_Variant_SuperClass_ID = {
    "Variant_SuperClass",
    gs_Variant_SuperClass_SuperClassIDs,
    _countof( gs_Variant_SuperClass_SuperClassIDs ),
    sizeof( Variant_SuperClass ),
    Variant_SuperClass_initialize,
    NULL,
    0,
};


/*[Variant_SuperClass_initialize]*/
errnum_t  Variant_SuperClass_initialize( Variant_SuperClass* self, void* Parameter )
{
	self->ClassID = &g_Variant_SuperClass_ID;
	self->FinalizerVTable = NULL;
	self->StaticAddress = NULL;
	UNREFERENCED_VARIABLE( Parameter );
	return  0;
}


 
/***********************************************************************
  <<< (VariantListIteratorClass) >>> 
************************************************************************/

/*[VariantListIteratorClass_getNext]*/
Variant_SuperClass*  VariantListIteratorClass_getNext( VariantListIteratorClass* self )
{
	VariantClass*  variant;

	variant = ListIteratorClass_getNext( &self->Iterator );
	if ( variant == NULL ) {
		return  NULL;
	} else {
		return  variant->Object;
	}
}


 
/***********************************************************************
  <<< [PArray_setFromArray] >>> 
************************************************************************/
int  PArray_setFromArray( void* PointerArray, size_t PointerArraySize, void* out_ppRight,
	void* SrcArray, size_t SrcArraySize, size_t SrcArrayElemSize )
{
	int       e = 0;
	char**    pp;
	char**    pp_over;
	char*     s;
	char*     s_over;

	pp      = (char**) PointerArray;
	pp_over = (char**)( (char*)PointerArray + PointerArraySize );
	s       = (char*)  SrcArray;
	s_over  = (char*)  SrcArray + SrcArraySize;

	IF ( (pp_over - pp) * SrcArraySize  <  SrcArraySize ) {
		s_over  = (char*)SrcArray + (pp_over - pp) * SrcArraySize;
		e = E_FEW_ARRAY;
	}

	while ( s < s_over ) {
		*pp = s;
		pp++;  s += SrcArrayElemSize;
	}

	if ( out_ppRight != NULL )  *(char***)out_ppRight = pp - 1;

	return  e;
}


 
/***********************************************************************
  <<< [PArray_doShakerSort] >>> 
************************************************************************/
errnum_t  PArray_doShakerSort( const void* PointerArray,  size_t PointerArraySize,
	const void* ppLeft,  const void* ppRight,  CompareFuncType Compare,  const void* Param )
{
	errnum_t  e;
	void**    p_left  = (void**)ppLeft;
	void**    p_right = (void**)ppRight;
	void**    p1;
	void**    p2;
	void**    p_swap;
	void*     swap;
	int       cmp;

	if ( PointerArraySize == 0 ) { e=0; goto fin; }

	IF_D( ppLeft  != NULL && ( ppLeft  < PointerArray || (char*)ppLeft  >= (char*)PointerArray + PointerArraySize ) ) goto err;
	IF_D( ppRight != NULL && ( ppRight < PointerArray || (char*)ppRight >= (char*)PointerArray + PointerArraySize ) ) goto err;

	if ( p_left  == NULL )  p_left  = (void**) PointerArray;
	if ( p_right == NULL )  p_right = (void**)( (char*) PointerArray + PointerArraySize - sizeof(void*) );

	for (;;) {

		//=== Run to right
		p1 = p_left;
		p2 = p_left + 1;
		p_swap = p_left;

		while ( p1 < p_right ) {
			e= Compare( p1, p2, Param, &cmp ); IF(e)goto fin;
			if ( cmp > 0 ) {
				swap = *p1;  *p1 = *p2;  *p2 = swap;
				p_swap = p1;
			}
			p1++;  p2++;
		}
		if ( p_swap == p_left )  break;
		p_right = p_swap;


		//=== Run to left
		p1 = p_right - 1;
		p2 = p_right;
		p_swap = p_right;

		while ( p1 >= p_left ) {
			e= Compare( p1, p2, Param, &cmp ); IF(e)goto fin;
			if ( cmp > 0 ) {
				swap = *p1;  *p1 = *p2;  *p2 = swap;
				p_swap = p2;
			}
			p1--;  p2--;
		}
		if ( p_swap == p_right )  break;
		p_left = p_swap;
	}

	e=0;
fin:
	return  e;

err:  e = E_OTHERS;  goto fin;
}


 
/***********************************************************************
  <<< [PArray_isSorted] >>> 
************************************************************************/
errnum_t  PArray_isSorted( const void* PointerArray, size_t PointerArraySize,
	CompareFuncType Compare, const void* Param, bool* out_IsSorted )
{
	errnum_t      e;
	const void**  p;
	const void**  p_over;
	int           result;

	p = PointerArray;
	p_over = (const void**)( (uintptr_t) PointerArray + PointerArraySize - sizeof(void*) );

	while ( p < p_over ) {
		e= Compare( p,  p + 1,  Param,  &result );
			IF(e){goto fin;}

		IF ( result > 0 ) { *out_IsSorted = false;  goto fin; }

		p += 1;
	}

	*out_IsSorted = true;

	e=0;
fin:
	return  e;
}


/***********************************************************************
  <<< [PArray_doBinarySearch] >>> 
************************************************************************/
errnum_t  PArray_doBinarySearch( const void* PointerArray, size_t PointerArraySize,
	const void* Key, CompareFuncType Compare, const void* Param,
	int* out_FoundOrLeftIndex, int* out_CompareResult )
{
	errnum_t   e;
	uintptr_t  base = (uintptr_t) PointerArray;
	uintptr_t  left;  /* index */
	uintptr_t  right;
	uintptr_t  middle;
	int        result;

	left  = 0;
	right = (uintptr_t) PointerArraySize / sizeof(void*);

	#ifndef  NDEBUG
	{
		bool  is_sorted;

		result = 1;

		e= PArray_isSorted( PointerArray, PointerArraySize, Compare, Param, &is_sorted );
			IF(e){goto fin;}
		IF ( ! is_sorted ) { e=E_NO_NEXT; goto fin; }
	}
	#endif


	while ( right - left >= 2 ) {
		middle = ( left + right ) / 2;

		e= Compare( &Key, ( (const void**) base + middle ), Param, &result );
			IF(e){goto fin;}

		if ( result == 0 ) {
			left = middle;
			e = 0;  goto fin;
		} else if ( result < 0 ) {
			right = middle;
		} else {
			left = middle;
		}
	}

	e= Compare( &Key, ( (const void**) base + left ), Param, &result );
		IF(e){goto fin;}

	e=0;
fin:
	*out_FoundOrLeftIndex = left;
	*out_CompareResult = result;
	return  e;
}


 
/***********************************************************************
  <<< (DictionaryAA_NodeClass:Class) >>> 
************************************************************************/

/*[DictionaryAA_SearchWorkClass]*/
typedef struct _DictionaryAA_SearchWorkClass  DictionaryAA_SearchWorkClass;
struct _DictionaryAA_SearchWorkClass {
	const TCHAR*             SearchKey;
	DictionaryAA_NodeClass*  FoundNode;
	bool                     IsErrorIfNotFound;
};

/*[DictionaryAA_TraverseWorkClass]*/
typedef struct _DictionaryAA_TraverseWorkClass  DictionaryAA_TraverseWorkClass;
struct _DictionaryAA_TraverseWorkClass {
	DictionaryAA_TraverseFuncType  Function;
	void*                          UserParameter;
};

errnum_t  DictionaryAA_NodeClass_insert( DictionaryAA_NodeClass* Node,
	DictionaryAA_NodeClass** out_ParentNode, DictionaryAA_SearchWorkClass* work );
errnum_t  DictionaryAA_NodeClass_search( DictionaryAA_NodeClass* Node,
	DictionaryAA_SearchWorkClass* work );
DictionaryAA_NodeClass*  DictionaryAA_NodeClass_remove( DictionaryAA_NodeClass* Node,
	const TCHAR* Key, DictionaryAA_NodeClass** out_RemovingNode );
DictionaryAA_NodeClass*  DictionaryAA_NodeClass_skew( DictionaryAA_NodeClass* Node );
DictionaryAA_NodeClass*  DictionaryAA_NodeClass_split( DictionaryAA_NodeClass* Node );
DictionaryAA_NodeClass*  DictionaryAA_NodeClass_rotateLeft( DictionaryAA_NodeClass* Node );
DictionaryAA_NodeClass*  DictionaryAA_NodeClass_rotateRight( DictionaryAA_NodeClass* Node );
DictionaryAA_NodeClass*  DictionaryAA_NodeClass_searchMin( DictionaryAA_NodeClass* Node );
errnum_t  DictionaryAA_NodeClass_toEmpty( DictionaryAA_NodeClass* Node, errnum_t e );
errnum_t  DictionaryAA_NodeClass_onTraverse( DictionaryAA_NodeClass* Node,
	DictionaryAA_TraverseWorkClass* work );
errnum_t  DictionaryAA_NodeClass_print( DictionaryAA_NodeClass* Node, int RootHeight,
	FILE* OutputStream );


 
/***********************************************************************
  <<< (DictionaryAA_Class) >>> 
************************************************************************/

/*[DictionaryAA_Class_initConst]*/
void  DictionaryAA_Class_initConst( DictionaryAA_Class* self )
{
	self->Root = &g_DictionaryAA_NullNode;
}


/*[DictionaryAA_Class_finalize]*/
errnum_t  DictionaryAA_Class_finalize( DictionaryAA_Class* self, errnum_t e )
{
	return  DictionaryAA_NodeClass_toEmpty( self->Root, e );
}


/*[DictionaryAA_Class_insert]*/
errnum_t  DictionaryAA_Class_insert( DictionaryAA_Class* self, const TCHAR* Key,
	DictionaryAA_NodeClass** out_Node )
{
	errnum_t  e;
	DictionaryAA_SearchWorkClass  work;

	work.SearchKey = Key;

	e= DictionaryAA_NodeClass_insert( self->Root, &self->Root, &work );

	*out_Node = work.FoundNode;

	return  e;
}


/*[DictionaryAA_Class_remove]*/
errnum_t  DictionaryAA_Class_remove( DictionaryAA_Class* self, const TCHAR* Key )
{
	errnum_t                 e;
	DictionaryAA_NodeClass*  removing_node = NULL;

	self->Root = DictionaryAA_NodeClass_remove( self->Root, Key, &removing_node );
	if ( removing_node == NULL ) { e = E_NOT_FOUND_SYMBOL;  goto fin; }

	e=0;
fin:
	if ( removing_node != NULL ) {
		e= HeapMemory_free( &removing_node->Key, e );
		e= HeapMemory_free( &removing_node, e );
	}
	return  e;
}


/*[DictionaryAA_Class_search]*/
errnum_t  DictionaryAA_Class_search( DictionaryAA_Class* self, const TCHAR* Key,
	DictionaryAA_NodeClass** out_Node )
{
	errnum_t  e;
	DictionaryAA_SearchWorkClass  work;

	work.SearchKey = Key;
	work.IsErrorIfNotFound = true;

	e= DictionaryAA_NodeClass_search( self->Root, &work );

	*out_Node = work.FoundNode;

	return  e;
}


/*[DictionaryAA_Class_isExist]*/
bool  DictionaryAA_Class_isExist( DictionaryAA_Class* self, const TCHAR* Key )
{
	DictionaryAA_SearchWorkClass  work;

	work.SearchKey = Key;
	work.IsErrorIfNotFound = false;

	DictionaryAA_NodeClass_search( self->Root, &work );

	return  ( work.FoundNode != NULL );
}


/*[DictionaryAA_Class_freeAllKeysHeap]*/
#if 0
errnum_t  DictionaryAA_Class_freeAllKeysHeap( DictionaryAA_Class* self, errnum_t e )
{
	errnum_t                    ee;
	DictionaryAA_IteratorClass  iterator;
	DictionaryAA_NodeClass*     node;

	DictionaryAA_IteratorClass_initConst( &iterator );

	ee= DictionaryAA_IteratorClass_initialize( &iterator, self );
		IF ( ee != 0  &&  e==0 ) { e = ee;  goto fin; }
	for ( DictionaryAA_Class_forEach( &iterator, &node ) ) {
		e= HeapMemory_free( &node->Key, e );
	}

	e=0;
fin:
	e= DictionaryAA_IteratorClass_finalize( &iterator, e );
	return  e;
}
#endif


/*[DictionaryAA_Class_traverse]*/
errnum_t  DictionaryAA_Class_traverse( DictionaryAA_Class* self,
	DictionaryAA_TraverseFuncType  Function,
	void*  UserParameter )
{
	DictionaryAA_TraverseWorkClass  work;

	work.Function = Function;
	work.UserParameter = UserParameter;

	return  DictionaryAA_NodeClass_onTraverse( self->Root, &work );
}


/*[DictionaryAA_Class_toEmpty]*/
errnum_t  DictionaryAA_Class_toEmpty( DictionaryAA_Class* self )
{
	errnum_t  e;

	e= DictionaryAA_NodeClass_toEmpty( self->Root, 0 ); IF(e){goto fin;}

	e=0;
fin:
	self->Root = &g_DictionaryAA_NullNode;
	return  e;
}


/*[DictionaryAA_Class_print]*/
errnum_t  DictionaryAA_Class_print( DictionaryAA_Class* self, FILE* OutputStream )
{
	errnum_t  e;
	int       r;

	r= _ftprintf_s( OutputStream, _T("DictionaryAA -------------------\n") );
		IF(r<0) { e=E_ACCESS_DENIED; goto fin; }

	e= DictionaryAA_NodeClass_print( self->Root, self->Root->Height, OutputStream );
		IF(e){goto fin;}

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< [DictionaryAA_Class_finalize2] >>> 
************************************************************************/
errnum_t  DictionaryAA_Class_finalize2( DictionaryAA_Class* self,  errnum_t  e,
	bool  in_IsFreeItem,  FinalizeFuncType  in_Type_Finalize )
{
	errnum_t  ee;

	DictionaryAA_NodeClass*     node;
	DictionaryAA_IteratorClass  iterator;

	DictionaryAA_IteratorClass_initConst( &iterator );

	ee= DictionaryAA_IteratorClass_initialize( &iterator, self );
		IF(ee){e=MergeError(e,ee);goto fin;}
	for ( DictionaryAA_Class_forEach( &iterator, &node ) ) {
		if ( in_Type_Finalize != NULL ) {
			e= in_Type_Finalize( node->Item, e );
		}
		if ( in_IsFreeItem ) {
			e= HeapMemory_free( &node->Item, e );
		}
	}

fin:
	e= DictionaryAA_IteratorClass_finalize( &iterator, e );
	e= DictionaryAA_Class_finalize( self, e );
	return  e;
}


 
/***********************************************************************
  <<< [DictionaryAA_Class_getArray] >>> 
************************************************************************/
errnum_t  DictionaryAA_Class_getArray( DictionaryAA_Class* self,
	TCHAR***  in_out_Strings,  int*  in_out_StringCount,  NewStringsEnum  in_HowToAllocate )
{
	errnum_t  e;
	int       string_count = 0;
	int       string_count_max;

	TCHAR**   key_array = NULL;
	TCHAR**   new_key_array = NULL;

	DictionaryAA_NodeClass*     node;
	DictionaryAA_IteratorClass  iterator;

	DictionaryAA_IteratorClass_initConst( &iterator );


	/* Set "string_count_max", "key_array" */
	if ( IsBitSet( in_HowToAllocate, NewStringsEnum_NewPointers ) ) {

		string_count_max = 0;
		e= DictionaryAA_IteratorClass_initialize( &iterator, self );
			IF(e){goto fin;}
		for ( DictionaryAA_Class_forEach( &iterator, &node ) ) {
			string_count_max += 1;
		}
		e= DictionaryAA_IteratorClass_finalize( &iterator, 0 ); IF(e){goto fin;}

		e= HeapMemory_allocateArray( &new_key_array, string_count_max );
			IF(e){goto fin;}
		*in_out_Strings = new_key_array;
		key_array = new_key_array;
	}
	else {
		ASSERT_R( in_out_StringCount != NULL,  e=E_OTHERS; goto fin );
		string_count_max = *in_out_StringCount;
		key_array = *in_out_Strings;
	}
	memset( key_array,  0x00,  string_count_max * sizeof(TCHAR*) );


	/* Set "key_array[ string_count ]" */
	e= DictionaryAA_IteratorClass_initialize( &iterator, self );
		IF(e){goto fin;}
	for ( DictionaryAA_Class_forEach( &iterator, &node ) ) {
		const TCHAR*  value = node->Key;

		if ( IsBitSet( in_HowToAllocate, NewStringsEnum_NewCharacters ) ) {
			ASSERT_R( IsBitNotSet( in_HowToAllocate, NewStringsEnum_LinkCharacters ),
				e=E_OTHERS; goto fin );

			e= MallocAndCopyString( &key_array[ string_count ], value );
				IF(e){goto fin;}
		}
		else if ( IsBitSet( in_HowToAllocate, NewStringsEnum_LinkCharacters ) ) {
			const TCHAR**  key_pp = &key_array[ string_count ];

			ASSERT_R( *key_pp == NULL,  e=E_OTHERS; goto fin );
			*key_pp = value;
		}
		else {
			ASSERT_R( false,  e=E_LIMITATION;  goto fin );
		}
		string_count += 1;
	}

	*in_out_StringCount = string_count;
	new_key_array = NULL;

	e=0;
fin:
	if ( e != 0 ) {
		if ( IsBitSet( in_HowToAllocate, NewStringsEnum_NewCharacters ) ) {
			if ( key_array != NULL ) {
				for ( string_count -= 1;  string_count >= 0;  string_count -= 1 ) {
					e= HeapMemory_free( &key_array[ string_count ], e );
				}
			}
		}
	}
	e= HeapMemory_free( &new_key_array, e );
	e= DictionaryAA_IteratorClass_finalize( &iterator, e );
	return  e;
}


 
/***********************************************************************
  <<< (DictionaryAA_NodeClass) >>> 
************************************************************************/

/*[g_DictionaryAA_NullNode]*/
DictionaryAA_NodeClass  g_DictionaryAA_NullNode = {
	/* Key */     _T("(NullNode)"),
	/* Item */    NULL,
	/* Height */  0,
	/* Left */    &g_DictionaryAA_NullNode,
	/* Right */   &g_DictionaryAA_NullNode,
};


/*[DictionaryAA_NodeClass_insert]*/
errnum_t  DictionaryAA_NodeClass_insert( DictionaryAA_NodeClass* in_Node,
	DictionaryAA_NodeClass** out_ParentNode, DictionaryAA_SearchWorkClass* work )
{
	errnum_t  e;

	if ( in_Node == &g_DictionaryAA_NullNode ) {
		e= HeapMemory_allocate( &in_Node ); IF(e){goto fin;}
		in_Node->Key = NULL;
		e= MallocAndCopyString( &in_Node->Key, work->SearchKey ); IF(e){goto fin;}
		in_Node->Item   = NULL;
		in_Node->Height = 1;
		in_Node->Left   = &g_DictionaryAA_NullNode;
		in_Node->Right  = &g_DictionaryAA_NullNode;
		*out_ParentNode = in_Node;
		work->FoundNode = in_Node;
	}
	else {
		int  compare = _tcscmp( work->SearchKey, in_Node->Key );

		if ( compare == 0 ) {
			*out_ParentNode = in_Node;
			work->FoundNode = in_Node;
		}
		else {
			if ( compare < 0 ) {
				e= DictionaryAA_NodeClass_insert( in_Node->Left, &in_Node->Left, work );
					IF(e){goto fin;}
			}
			else {  /* compare > 0 */
				e= DictionaryAA_NodeClass_insert( in_Node->Right, &in_Node->Right, work );
					IF(e){goto fin;}
			}
			in_Node = DictionaryAA_NodeClass_skew( in_Node );
			in_Node = DictionaryAA_NodeClass_split( in_Node );
			*out_ParentNode = in_Node;
		}
	}

	e=0;
fin:
	return  e;
}


/*[DictionaryAA_NodeClass_search]*/
errnum_t  DictionaryAA_NodeClass_search( DictionaryAA_NodeClass* in_Node,
	DictionaryAA_SearchWorkClass* work )
{
	errnum_t  e;
	int       compare;

	if ( in_Node == &g_DictionaryAA_NullNode ) {
		IF ( work->IsErrorIfNotFound )  { e = E_NOT_FOUND_SYMBOL;  goto fin; }
		work->FoundNode = NULL;
		e = 0;  goto fin;
	}

	compare = _tcscmp( work->SearchKey, in_Node->Key );

	if ( compare == 0 ) {
		work->FoundNode = in_Node;
	}
	else {
		if ( compare < 0 ) {
			e= DictionaryAA_NodeClass_search( in_Node->Left, work );
				IF(e){goto fin;}
		}
		else {  /* compare > 0 */
			e= DictionaryAA_NodeClass_search( in_Node->Right, work );
				IF(e){goto fin;}
		}
	}

	e=0;
fin:
	return  e;
}


/*[DictionaryAA_NodeClass_remove]*/
DictionaryAA_NodeClass*  DictionaryAA_NodeClass_remove( DictionaryAA_NodeClass* in_Node,
	const TCHAR* Key, DictionaryAA_NodeClass** out_RemovingNode )
{
	if ( in_Node != &g_DictionaryAA_NullNode ) {
		int  compare = _tcscmp( Key, in_Node->Key );

		if ( compare == 0 ) {
			if ( in_Node->Left == &g_DictionaryAA_NullNode ) {
				*out_RemovingNode = in_Node;
				in_Node = in_Node->Right;
			} else if ( in_Node->Right == &g_DictionaryAA_NullNode ) {
				*out_RemovingNode = in_Node;
				in_Node = in_Node->Left;
			} else {
				DictionaryAA_NodeClass*  reuse_node = in_Node;
				DictionaryAA_NodeClass*  sacrifice_node;
				DictionaryAA_NodeClass   swap;

				sacrifice_node = DictionaryAA_NodeClass_searchMin( in_Node->Right );
				reuse_node->Right = DictionaryAA_NodeClass_remove(
					in_Node->Right, sacrifice_node->Key, &sacrifice_node );

				swap.Key  = reuse_node->Key;
				swap.Item = reuse_node->Item;
				reuse_node->Key  = sacrifice_node->Key;
				reuse_node->Item = sacrifice_node->Item;
				sacrifice_node->Key  = swap.Key;
				sacrifice_node->Item = swap.Item;
				*out_RemovingNode = sacrifice_node;
			}
		}
		else if ( compare < 0 ) {
			in_Node->Left = DictionaryAA_NodeClass_remove( in_Node->Left, Key, out_RemovingNode );
		}
		else {  /* compare > 0 */
			in_Node->Right = DictionaryAA_NodeClass_remove( in_Node->Right, Key, out_RemovingNode );
		}

		if ( in_Node->Left->Height < in_Node->Height - 1  ||
			in_Node->Right->Height < in_Node->Height - 1 )
		{
			in_Node->Height -= 1;
			if ( in_Node->Right->Height > in_Node->Height )
				{ in_Node->Right->Height = in_Node->Height; }
			in_Node = DictionaryAA_NodeClass_skew( in_Node );
			in_Node->Right = DictionaryAA_NodeClass_skew( in_Node->Right );
			in_Node->Right->Right = DictionaryAA_NodeClass_skew( in_Node->Right->Right );
			in_Node = DictionaryAA_NodeClass_split( in_Node );
			in_Node->Right = DictionaryAA_NodeClass_split( in_Node->Right );
		}
	}
	return  in_Node;
}


/*[DictionaryAA_NodeClass_skew]*/
DictionaryAA_NodeClass*  DictionaryAA_NodeClass_skew( DictionaryAA_NodeClass* in_Node )
{
	if ( in_Node->Left->Height == in_Node->Height ) {
		in_Node = DictionaryAA_NodeClass_rotateRight( in_Node );
	}

	return  in_Node;
}


/*[DictionaryAA_NodeClass_split]*/
DictionaryAA_NodeClass*  DictionaryAA_NodeClass_split( DictionaryAA_NodeClass* in_Node )
{
	if ( in_Node->Height == in_Node->Right->Right->Height ) {
		in_Node = DictionaryAA_NodeClass_rotateLeft( in_Node );
		in_Node->Height += 1;
	}

	return  in_Node;
}


/*[DictionaryAA_NodeClass_rotateLeft]*/
DictionaryAA_NodeClass*  DictionaryAA_NodeClass_rotateLeft( DictionaryAA_NodeClass* in_Node )
{
	DictionaryAA_NodeClass*  swap;

	swap = in_Node->Right;
	in_Node->Right = swap->Left;
	swap->Left = in_Node;

	return  swap;
}


/*[DictionaryAA_NodeClass_rotateRight]*/
DictionaryAA_NodeClass*  DictionaryAA_NodeClass_rotateRight( DictionaryAA_NodeClass* in_Node )
{
	DictionaryAA_NodeClass*  swap;

	swap = in_Node->Left;
	in_Node->Left = swap->Right;
	swap->Right = in_Node;

	return  swap;
}


DictionaryAA_NodeClass*  DictionaryAA_NodeClass_searchMin( DictionaryAA_NodeClass* in_Node )
{
	while ( in_Node->Left != &g_DictionaryAA_NullNode )
		{ in_Node = in_Node->Left; }
	return  in_Node;
}


/*[DictionaryAA_NodeClass_toEmpty]*/
errnum_t  DictionaryAA_NodeClass_toEmpty( DictionaryAA_NodeClass* in_Node, errnum_t e )
{
	if ( in_Node != &g_DictionaryAA_NullNode ) {
		e= DictionaryAA_NodeClass_toEmpty( in_Node->Left, e );
		e= DictionaryAA_NodeClass_toEmpty( in_Node->Right, e );
		e= HeapMemory_free( &in_Node->Key, e );
		e= HeapMemory_free( &in_Node, e );
	}
	return  e;
}


/*[DictionaryAA_NodeClass_onTraverse]*/
errnum_t  DictionaryAA_NodeClass_onTraverse( DictionaryAA_NodeClass* in_Node,
	DictionaryAA_TraverseWorkClass* work )
{
	errnum_t  e;

	if ( in_Node != &g_DictionaryAA_NullNode ) {
		e= DictionaryAA_NodeClass_onTraverse( in_Node->Left, work ); IF(e){goto fin;}
		e= work->Function( in_Node, work->UserParameter ); IF(e){goto fin;}
		e= DictionaryAA_NodeClass_onTraverse( in_Node->Right, work ); IF(e){goto fin;}
	}

	e=0;
fin:
	return  e;
}


/*[DictionaryAA_NodeClass_print]*/
errnum_t  DictionaryAA_NodeClass_print( DictionaryAA_NodeClass* in_Node, int RootHeight,
	FILE* OutputStream )
{
	errnum_t  e;
	int       r;

	if ( in_Node != &g_DictionaryAA_NullNode ) {

		e= DictionaryAA_NodeClass_print( in_Node->Left, RootHeight, OutputStream );
			IF(e){goto fin;}

		r= _ftprintf_s( OutputStream, _T("%*s%s\n"), ( RootHeight - in_Node->Height ) * 4,
			_T(""), in_Node->Key ); IF(r<0) { e=E_ACCESS_DENIED; goto fin; }

		e= DictionaryAA_NodeClass_print( in_Node->Right, RootHeight, OutputStream );
			IF(e){goto fin;}
	}

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
  <<< (DictionaryAA_IteratorClass) >>> 
************************************************************************/

errnum_t  DictionaryAA_IteratorClass_initialize_sub( DictionaryAA_NodeClass* in_Node,
	void*  Array );


/*[DictionaryAA_IteratorClass_initialize]*/
errnum_t  DictionaryAA_IteratorClass_initialize( DictionaryAA_IteratorClass* self,
	DictionaryAA_Class* Collection )
{
	errnum_t  e;

	e= Set2_init( &self->Nodes, 0x100 ); IF(e){goto fin;}

	e= DictionaryAA_Class_traverse( Collection, DictionaryAA_IteratorClass_initialize_sub,
		&self->Nodes ); IF(e){goto fin;}

	self->NextNode = self->Nodes.First;

	e=0;
fin:
	return  e;
}


/*[DictionaryAA_IteratorClass_initialize_sub]*/
errnum_t  DictionaryAA_IteratorClass_initialize_sub( DictionaryAA_NodeClass* in_Node,
	void*  Array )
{
	errnum_t  e;
	Set2*     array = (Set2*) Array;
	DictionaryAA_NodeClass**  pp_node;

	e= Set2_alloc( array, &pp_node, DictionaryAA_NodeClass* ); IF(e){goto fin;}
	*pp_node = in_Node;

	e=0;
fin:
	return  e;
}


/*[DictionaryAA_IteratorClass_getNext]*/
DictionaryAA_NodeClass*  DictionaryAA_IteratorClass_getNext(
	DictionaryAA_IteratorClass* self )
{
	DictionaryAA_NodeClass*  return_value;

	if ( self->NextNode < (DictionaryAA_NodeClass**) self->Nodes.Next ) {
		return_value = *self->NextNode;
		self->NextNode += 1;
	}
	else {
		return_value = NULL;
	}

	return  return_value;
}


 
/*=================================================================*/
/* <<< [Print/Print2.c] >>> */ 
/*=================================================================*/
 
/***********************************************************************
  <<< [PrintfCounterClass] >>> 
************************************************************************/
#if USE_PRINTF_COUNTER
	PrintfCounterClass  g_PrintfCounter;
#endif


 
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

	#if _MSC_VER
		#pragma warning(push)
		#pragma warning(disable: 4996)
	#endif

	int  r = _vsnwprintf( s, tsize, format, va );

	#if _MSC_VER
		#pragma warning(pop)
	#endif

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

	if ( src_over == NULL )  { src_over = StrT_chr( src, _T('\0') ); }
	IF_D( src > src_over )  { return 1; }
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
	va_end( va );  if ( p_s_last != NULL )  *p_s_last = StrT_chr( s_start, '\0' );
	return  e;
}


 
/***********************************************************************
  <<< [ftcopy_part_r] >>> 
************************************************************************/
errnum_t  ftcopy_part_r( FILE* OutputStream, const TCHAR* Str, const TCHAR* StrOver )
{
	errnum_t      e;
	const TCHAR*  p;
	bool          is_last;
	int           size;
	TCHAR         buffer[256];

	ASSERT_R( Str <= StrOver, e=E_OTHERS; goto fin );

	p = Str;
	for (;;) {
		size = (uint8_t*) StrOver - (uint8_t*) p;
		if ( size <= sizeof(buffer) - sizeof(TCHAR) ) {
			is_last = true;
		}
		else {
			size = sizeof(buffer) - sizeof(TCHAR);
			is_last = false;
		}

		memcpy( buffer, p, size );
		*(TCHAR*)( (uint8_t*) buffer + size ) = _T('\0');
		_fputts( buffer, OutputStream ); IF(ferror(OutputStream)){e=E_ERRNO; goto fin;}

		if ( is_last )
			{ break; }

		p = (const TCHAR*)( (uint8_t*) p + size );
	}

	e=0;
fin:
	return  e;
}


 
/***********************************************************************
* Function: OpenConsole
*
* Argument:
*    out_IsExistOrNewConsole - NULL is permitted
************************************************************************/
errnum_t  OpenConsole( bool  in_OpenIfNoConsole,  bool*  out_IsExistOrNewConsole )
{
	errnum_t  e;
	BOOL      b;
	bool      is_console;
	HANDLE    stdout_handle;
	int       stdout_file_descriptor;
	FILE*     stdout_stream;

	PROCESSENTRY32  current_process;

	current_process.dwSize = sizeof( current_process );
	e= GetProcessInformation( GetCurrentProcessId(),  /*Set*/ &current_process ); IF(e){goto fin;}


	is_console = (bool) AttachConsole( current_process.th32ParentProcessID );

	if ( out_IsExistOrNewConsole != NULL ) {
		if ( in_OpenIfNoConsole ) {
			*out_IsExistOrNewConsole = ! is_console;  /* is new console */
		} else {
			*out_IsExistOrNewConsole = is_console;  /* is exist console */
		}
	}

	if ( ! is_console ) {
		if ( in_OpenIfNoConsole ) {

			b= AllocConsole();
		}
		else
			{ e=0; goto fin; }
		IF(!b) { e=E_OTHERS; goto fin; }
	}

	stdout_handle = GetStdHandle( STD_OUTPUT_HANDLE );
		IF ( stdout_handle == NULL ) { e=E_OTHERS; goto fin; }
	stdout_file_descriptor = _open_osfhandle( (intptr_t) stdout_handle, _O_TEXT );
	stdout_stream = _fdopen( stdout_file_descriptor, "w" );
	setvbuf( stdout_stream, NULL, _IONBF, 0 );

	*stdout = *stdout_stream;

	e=0;
fin:
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


 
/***********************************************************************
  <<< (ClassID_Class) >>> 
************************************************************************/

/*[ClassID_Class_isSuperClass]*/
bool  ClassID_Class_isSuperClass( const ClassID_Class* ClassID, const ClassID_Class* SuperClassID )
{
	if ( ClassID == SuperClassID ) {
		return  true;
	}
	else {
		int  i;

		for ( i = ClassID->SuperClassID_Array_Count - 1;  i >= 0;  i -= 1 ) {
			if ( ClassID->SuperClassID_Array[ i ] == SuperClassID ) {
				return  true;
			}
		}
		return  false;
	}
}


/*[ClassID_Class_createObject]*/
errnum_t  ClassID_Class_createObject( const ClassID_Class* ClassID, void* out_Object, void* Parameter )
{
	errnum_t  e;
	ClassID_SuperClass*  object = NULL;

	e= HeapMemory_allocateBytes( &object, ClassID->Size ); IF(e){goto fin;}
	if ( ClassID->InitializeFunction != NULL ) {
		e= ClassID->InitializeFunction( object, Parameter ); IF(e){goto fin;}
	}
	else {
		memset( object, 0, ClassID->Size );
		object->ClassID = ClassID;
	}
	*(void**) out_Object = object;
	object = NULL;

	e=0;
fin:
	if ( object != NULL ) { e= HeapMemory_free( &object, e ); }
	return  e;
}


/*[ClassID_Class_getVTable]*/
void*  ClassID_Class_getVTable( const ClassID_Class* ClassID, const InterfaceID_Class* InterfaceID )
{
	int  i;

	for ( i = ClassID->InterfaceToVTable_Array_Conut - 1;  i >= 0;  i -= 1 ) {
		if ( ClassID->InterfaceToVTable_Array[ i ].InterfaceID == InterfaceID ) {
			return  (void*) ClassID->InterfaceToVTable_Array[ i ].VTable;
		}
	}
	return  NULL;
}


 
/***********************************************************************
  <<< (ClassID_SuperClass) >>> 
************************************************************************/

/*[g_ClassID_SuperClass_ID]*/
const ClassID_Class  g_ClassID_SuperClass_ID = {
	"ClassID_SuperClass",          /* /ClassName */
	NULL,                          /* .SuperClassID_Array */
	0,                             /* .SuperClassID_Array_Count */
	sizeof( ClassID_SuperClass ),  /* .Size */
	NULL,                          /* .InitializeFunction */
	NULL,                          /* .InterfaceToVTable_Array */
	0                              /* .InterfaceToVTable_Array_Conut */
};


 
/***********************************************************************
  <<< (g_FinalizerInterface_ID) >>> 
************************************************************************/

const InterfaceID_Class  g_FinalizerInterface_ID = { "FinalizerInterface" };


 
/***********************************************************************
  <<< (g_PrintXML_Interface_ID) >>> 
************************************************************************/

const InterfaceID_Class  g_PrintXML_Interface_ID = { "PrintXML_Interface" };


 
/***********************************************************************
  <<< [malloc_redirected] >>> 
************************************************************************/
#undef  malloc
void*  malloc_redirected( size_t  in_Size )
{
	void*  address = malloc( in_Size );

 
	HeapLogClass_log( address, in_Size );  /*(HeapLogClass_log in malloc_redirected)*/
		/* 上記 malloc とは別に、ここの内部で realloc することがあります。 */

 
	return  address;
} /*(end_of_malloc_redirected)*/
#define  malloc  malloc_redirected


 
/***********************************************************************
  <<< [realloc_redirected] >>> 
************************************************************************/
#undef  realloc
void*  realloc_redirected( void*  in_Address,  size_t  in_Size )
{
	void*  address = realloc( in_Address, in_Size );

 
	HeapLogClass_log( address, in_Size );  /*(HeapLogClass_log in realloc_redirected)*/
		/* 上記 realloc とは別に、ここの内部で realloc することがあります。 */

 
	return  address;
} /*(end_of_realloc_redirected)*/
#define  realloc  realloc_redirected


 
/***********************************************************************
  <<< [calloc_redirected] >>> 
************************************************************************/
#undef  calloc
void*  calloc_redirected( size_t  in_Count,  size_t  in_Size )
{
	void*  address = calloc( in_Count, in_Size );
 
	HeapLogClass_log( address, in_Size );  /*(HeapLogClass_log in calloc_redirected)*/
 
	return  address;
} /*(end_of_calloc_redirected)*/
#define  calloc  calloc_redirected


 
/***********************************************************************
  <<< [malloc_no_redirected] >>> 
************************************************************************/
#undef  malloc
void*  malloc_no_redirected( size_t  in_Size )
{
	return  malloc( in_Size );
}
#define  malloc  malloc_redirected


 
/***********************************************************************
  <<< [realloc_no_redirected] >>> 
************************************************************************/
#undef  realloc
void*  realloc_no_redirected( void*  in_Address,  size_t  in_Size )
{
	return  realloc( in_Address, in_Size );
}
#define  realloc  realloc_redirected


 
/***********************************************************************
  <<< [calloc_no_redirected] >>> 
************************************************************************/
#undef  calloc
void*  calloc_no_redirected( size_t  in_Count,  size_t  in_Size )
{
	return  calloc( in_Count, in_Size );
}
#define  calloc  calloc_redirected


 
