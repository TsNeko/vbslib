/* The header file was composed by module mixer */ 
#ifdef _MSC_VER
 #if  showIncludes
  #pragma message( "start of #include  \"" __FILE__ "\"" )
 #endif
#endif

#ifndef  __CLIB_H
#define  __CLIB_H


 
/*=================================================================*/
/* <<< [Error4_Type/Error4_Type.h] >>> */ 
/*=================================================================*/
 
/***********************************************************************
* Type: errnum_t
*    エラーコード、エラー番号
************************************************************************/
typedef  int  errnum_t;  /* [errnum_t] 0=no error */

#ifndef  NO_ERROR  /* same as windows.h */
	enum { NO_ERROR = 0 };  /* NO_ERROR symbol is for magic code warning only */
#endif

enum { E_CATEGORY_MASK = 0xFFFFFF00 };  /* E_CATEGORY_* */
enum { E_OFFSET_MASK   = 0x000000FF };

#ifndef  E_CATEGORY_COMMON  /* If not duplicated */
	#define  E_CATEGORY_COMMON  E_CATEGORY_COMMON
	enum { E_CATEGORY_COMMON = 0x00000400 };  /* 0x001, 0x400 .. 0x4FF : Reseved meaning by clib */
#endif

#ifndef  E_OTHERS
	#define  E_OTHERS  E_OTHERS
	enum { E_OTHERS = 1 };
#endif

enum { E_GET_LAST_ERROR     = E_CATEGORY_COMMON | 0x01 }; /* 1025 */
enum { E_HRESULT            = E_CATEGORY_COMMON | 0x02 }; /* 1026 */
enum { E_ERRNO              = E_CATEGORY_COMMON | 0x03 }; /* 1027 */
enum { E_UNKNOWN            = E_CATEGORY_COMMON | 0x04 }; /* 1028 */
enum { E_IN_ERROR           = E_CATEGORY_COMMON | 0x05 }; /* 1029 */
enum { E_IN_FINALLY         = E_CATEGORY_COMMON | 0x06 }; /* 1030 */
enum { E_INVALID_VALUE      = E_CATEGORY_COMMON | 0x07 }; /* 1031 */
enum { E_NOT_IMPLEMENT_YET  = E_CATEGORY_COMMON | 0x09 }; /* 1033 */
enum { E_ORIGINAL           = E_CATEGORY_COMMON | 0x0A }; /* 1034 */
enum { E_LIMITATION         = E_CATEGORY_COMMON | 0x0F }; /* 1039 */
enum { E_FEW_MEMORY         = E_CATEGORY_COMMON | 0x10 }; /* 1040 */
enum { E_FEW_ARRAY          = E_CATEGORY_COMMON | 0x11 }; /* 1041 */
enum { E_CANNOT_OPEN_FILE   = E_CATEGORY_COMMON | 0x12 }; /* 1042 */
enum { E_NOT_FOUND_DLL_FUNC = E_CATEGORY_COMMON | 0x13 }; /* 1043 */
enum { E_BAD_COMMAND_ID     = E_CATEGORY_COMMON | 0x14 }; /* 1044 */
enum { E_NOT_FOUND_SYMBOL   = E_CATEGORY_COMMON | 0x15 }; /* 1045 */
enum { E_NO_NEXT            = E_CATEGORY_COMMON | 0x16 }; /* 1046 */
enum { E_ACCESS_DENIED      = E_CATEGORY_COMMON | 0x17 }; /* 1047 */
enum { E_PATH_NOT_FOUND     = E_CATEGORY_COMMON | 0x18 }; /* 1048 */
enum { E_OUT_OF_WRITABLE    = E_CATEGORY_COMMON | 0x25 }; /* 1061 */
enum { E_NOT_INIT_GLOBAL    = E_CATEGORY_COMMON | 0x6B }; /* 1131 */
enum { E_TIME_OUT           = E_CATEGORY_COMMON | 0x70 }; /* 1136 */
enum { E_BINARY_FILE        = E_CATEGORY_COMMON | 0xBF }; /* 1215 */
enum { E_DEBUG_BREAK        = E_CATEGORY_COMMON | 0xDB }; /* 1243 */
enum { E_EXIT_TEST          = E_CATEGORY_COMMON | 0xE7 }; /* 1255 */
enum { E_FIFO_OVER          = E_CATEGORY_COMMON | 0xF0 }; /* 1264 */


 
/*=================================================================*/
/* <<< [CRT/CRT.h] >>> */ 
/*=================================================================*/
 
#include  <stdio.h> 
#ifdef  __linux__
	#define  _tfopen_s( out_File, Path, Mode ) \
		( *(out_File) = fopen( Path, Mode ),  (*(out_File) == NULL) ? (1) : (0) )
#endif
 
#include  <stdlib.h> 
 
#include  <string.h> 
 
#include  <stdarg.h> 
#ifdef  __linux__
	#define  _vsnprintf  vsnprintf
#endif
 
#ifndef  __linux__
	#include  <tchar.h> 
#else
	#define  _T(x)  x
	typedef  char  TCHAR;
	#define  _tcschr   strchr
	#define  _tprintf  printf
#endif
 
#include  <locale.h> 

#if UNDER_CE
  #define  setlocale( x, y )
#endif
 
#include  <errno.h> 
#ifdef  __linux__
	typedef  int  errno_t;  // CERT DCL09-C
#endif
 
#include  <assert.h> 
 
#include  <direct.h> 
 
/*=================================================================*/
/* <<< [CRT_plus_1/CRT_plus_1.h] >>> */ 
/*=================================================================*/
 
/***********************************************************************
  <<< [C99Type] >>> 
************************************************************************/
typedef  int             int_t;      /* MISRA-C:1998 No.13 */
typedef  signed int      int32_t;    /* For 32bit compiler */
typedef  signed short    int16_t;
typedef  signed char     int8_t;
typedef  unsigned int    uint_t;     /* MISRA-C:1998 No.13 */  /* This is not C99 */
typedef  unsigned int    uint32_t;   /* For 32bit compiler */
typedef  unsigned short  uint16_t;
typedef  unsigned char   uint8_t;
typedef  float           float32_t;  /* This is not C99 */
typedef  double          float64_t;  /* This is not C99 */
typedef  unsigned int    bool_t;     /* MISRA-C:1998 No.13 */  /* This is not C99 */
typedef  unsigned int    bool32_t;   /* For 32bit compiler */
typedef  unsigned short  bool16_t;
typedef  unsigned char   bool8_t;
typedef  int             int_fast32_t;
typedef  int             int_fast16_t;
typedef  int             int_fast8_t;
typedef  unsigned int    uint_fast32_t;
typedef  unsigned int    uint_fast16_t;
typedef  unsigned int    uint_fast8_t;

#define  INT_FAST32_MAX  INT_MAX


 
/*********************************************************************************************
  <<< [bit_flags32_t] [bit_flags_fast32_t] >>> 
  <<< [BitField] [BIT_FIELD_ENDIAN] [BIT_FIELD_LITTLE_ENDIAN] [BIT_FIELD_BIG_ENDIAN] >>> 
**********************************************************************************************/
typedef  uint32_t      bit_flags32_t; 
typedef  uint_fast32_t bit_flags_fast32_t;
typedef  unsigned int  BitField; 
typedef  uint32_t      BitField32;
#define  BIT_FIELD_ENDIAN           BIT_FIELD_LITTLE_ENDIAN
#define  BIT_FIELD_LITTLE_ENDIAN    1
#define  BIT_FIELD_BIG_ENDIAN       2


 
/***********************************************************************
  <<< [IsBitSet]        Check 1 bit >>> 
  <<< [IsAnyBitsSet]    Check multiple bits >>> 
  <<< [IsAllBitsSet]    Check multiple bits >>> 
  <<< [IsBitNotSet]     Check 1 bit >>> 
  <<< [IsAnyBitsNotSet] Check multiple bits >>> 
  <<< [IsAllBitsNotSet] Check multiple bits >>> 
************************************************************************/
#define  IsBitSet( variable, const_value ) \
	( ( (variable) & (const_value) ) != 0 )

#define  IsAnyBitsSet( variable, or_const_value ) \
	( ( (variable) & (or_const_value) ) != 0 )

#define  IsAllBitsSet( variable, or_const_value ) \
	( ( (variable) & (or_const_value) ) == (or_const_value) )

#define  IsBitNotSet( variable, const_value ) \
	( ( (variable) & (const_value) ) == 0 )

#define  IsAnyBitsNotSet( variable, or_const_value ) \
	( ( (variable) & (or_const_value) ) != (or_const_value) )

#define  IsAllBitsNotSet( variable, or_const_value ) \
	( ( (variable) & (or_const_value) ) == 0 )


 
/***********************************************************************
  <<< [bool type] >>> 
************************************************************************/
#ifndef  __cplusplus
 #ifndef  BOOL_DEFINED
  typedef unsigned char   bool;
  enum  { true = 1, false = 0 };
 #define  BOOL_DEFINED
 #endif
#endif


 
/***********************************************************************
  <<< [FuncType] >>> 
************************************************************************/
typedef  int (*FuncType)( void* Param ); 
typedef  errnum_t (* InitializeFuncType )( void* self, void* Parameter );
//typedef  int (*FinishFuncType)( void* m, int e );  /*[FinishFuncType]*/
typedef  errnum_t (*FinalizeFuncType)( void* self, errnum_t e );  /*[FinalizeFuncType]*/


 
/***********************************************************************
  <<< [fopen_ccs] >>> 
************************************************************************/
#if defined(_UNICODE) 
  #define  fopen_ccs  ",ccs=UNICODE"
#else
  #define  fopen_ccs  "t"
#endif


 
/***********************************************************************
  <<< [inline] [SUPPORT_INLINE_C_FUNC] [NOT_USE_INLINE_MACRO] >>> 
************************************************************************/
#ifndef  SUPPORT_INLINE_C_FUNC
  #define  SUPPORT_INLINE_C_FUNC  1
#endif
#ifndef  INLINE
  #if ! __cplusplus
    #if SUPPORT_INLINE_C_FUNC
      #define  inline  _inline     /* inline is specified under C99 */
    #endif
  #endif
#endif

#ifndef  NOT_USE_INLINE_MACRO
  #define  NOT_USE_INLINE_MACRO  0
#endif


 
/**************************************************************************
 <<< [ttoi_ex] >>> 
***************************************************************************/
int  ttoi_ex( const TCHAR* string,  bit_flags_fast32_t options );


 
/*=================================================================*/
/* <<< [Error4_Inline/Error4_Inline.h] >>> */ 
/*=================================================================*/
 
/***********************************************************************
  <<< [UNREFERENCED_VARIABLE] >>> 
  <<< [UNREFERENCED_VARIABLE_2] >>>
  <<< [UNREFERENCED_VARIABLE_3] >>>
  <<< [UNREFERENCED_VARIABLE_4] >>>
************************************************************************/
#ifdef  __linux__
	#define  UNREFERENCED_VARIABLE( x )
	#define  UNREFERENCED_VARIABLES( x )
#else

#define  UNREFERENCED_VARIABLE( a1 )       UNREFERENCED_VARIABLE_Sub( &(a1) )
#define  UNREFERENCED_VARIABLE_2( a1,a2 )  UNREFERENCED_VARIABLE_2_Sub( &(a1), &(a2) )
#define  UNREFERENCED_VARIABLE_3( a1,a2,a3 )     UNREFERENCED_VARIABLE_3_Sub( &(a1), &(a2), &(a3) )
#define  UNREFERENCED_VARIABLE_4( a1,a2,a3,a4 )  UNREFERENCED_VARIABLE_4_Sub( &(a1), &(a2), &(a3), &(a4) )

inline void  UNREFERENCED_VARIABLE_Sub( const void* a1 ) { a1; }
inline void  UNREFERENCED_VARIABLE_2_Sub( const void* a1, const void* a2 ) { a1,a2; }
inline void  UNREFERENCED_VARIABLE_3_Sub( const void* a1, const void* a2, const void* a3 ) { a1,a2,a3; }
inline void  UNREFERENCED_VARIABLE_4_Sub( const void* a1, const void* a2, const void* a3, const void* a4 ) { a1,a2,a3,a4; }

#endif


 
/*=================================================================*/
/* <<< [Lock_1/Lock_1.h] >>> */ 
/*=================================================================*/
 
/***********************************************************************
  <<< [SingletonInitializerClass] >>> 
************************************************************************/
typedef struct {
	volatile LONG  InitializeStep;
} SingletonInitializerClass;

#ifndef  SingletonInitializerClass_FailSleepTime
	#ifndef NDEBUG
		#define  SingletonInitializerClass_FailSleepTime  60000
	#else
		#define  SingletonInitializerClass_FailSleepTime  0
	#endif
#endif

bool  SingletonInitializerClass_isFirst( SingletonInitializerClass* self );
void  SingletonInitializerClass_onFinishedInitialize( SingletonInitializerClass* self, int e );
bool  SingletonInitializerClass_isInitialized( SingletonInitializerClass* self );


 
/*=================================================================*/
/* <<< [Print/Print2.h] >>> */ 
/*=================================================================*/
 
#if  __cplusplus
 extern "C" {  /* Start of C Symbol */ 
#endif
 
errnum_t  vsprintf_r( char* s, size_t s_size, const char* format, va_list va ); 
 
errnum_t  vswprintf_r( wchar_t* s, size_t s_size, const wchar_t* format, va_list va ); 
 
/*[vstprintf_r]*/
#if defined(_UNICODE) 
  #define  vstprintf_r  vswprintf_r
#else
  #define  vstprintf_r  vsprintf_r
#endif
 
errnum_t  stprintf_r( TCHAR* s, size_t s_size, const TCHAR* format, ... ); 
 
errnum_t  stcpy_part_r( TCHAR* s, size_t s_size, TCHAR* s_start, TCHAR** p_s_last, 
                   const TCHAR* src, const TCHAR* src_over );
errnum_t  stprintf_part_r( TCHAR* s, size_t s_size, TCHAR* s_start, TCHAR** p_s_last,
                      const TCHAR* format, ... );
 
#if  __cplusplus
 }    /* End of C Symbol */ 
#endif

 
/*=================================================================*/
/* <<< [SetX/SetX.h] >>> */ 
/*=================================================================*/
 
#ifndef  __SETX_H 
#define  __SETX_H

#ifdef  __cplusplus
 extern "C" {  /* Start of C Symbol */
#endif

 
/***********************************************************************
  <<< [Set2] >>> 
************************************************************************/
typedef  struct _Set2  Set2;
struct _Set2 {
	void*  First;
	void*  Next;
	void*  Over;

	#ifdef _DEBUG
	void**   PointerOfDebugArray;  /* void<type> */
	#endif
};

//[Set2_IteratorClass]
typedef struct _Set2_IteratorClass  Set2_IteratorClass;
struct _Set2_IteratorClass {
	Set2*     Parent;
	int       ElementSize;
	uint8_t*  Current;
};

#define  Set2_initConst( m )  ( (m)->First = NULL, (m)->Next = NULL )
int  Set2_init( Set2* m, int FirstSize );
int  Set2_finish( Set2* m, int e );
#define  Set2_isInited( m )  ( (m)->First != NULL )

#define  Set2_alloc( m, pp, type ) \
	Set2_alloc_imp( m, (void*)(pp), sizeof(type) )

int  Set2_alloc_imp( Set2* m, void* pm, size_t size );

#define  Set2_push( m, pp, type ) \
	Set2_alloc_imp( m, (void*)(pp), sizeof(type) )

#define  Set2_pop( m, pp, type ) \
	Set2_pop_imp( m, (void*)(pp), sizeof(type) )

int  Set2_pop_imp( Set2* m, void* pp, size_t size );

#define  Set2_freeLast( m, p, type, e ) \
	( ((char*)(m)->Next - sizeof(type) == (char*)(p)) ? \
		(m)->Next = (p), (e) : \
		((e)?(e):E_OTHERS) )

#define  Set2_toEmpty( m ) \
	( (m)->Next = (m)->First, 0 )

#define  Set2_expandIfOverByAddr( m, OverAddrBasedOnNowFirst ) \
	( (void*)(OverAddrBasedOnNowFirst) <= (m)->Over ? 0 : \
		Set2_expandIfOverByAddr_imp( m, OverAddrBasedOnNowFirst ) )

#define  Set2_expandIfOverByOffset( m, Size ) \
	Set2_expandIfOverByAddr( m, (char*)(m)->First + (Size) )
int  Set2_expandIfOverByAddr_imp( Set2* m, void* OverAddrBasedOnNowFirst );

#define  Set2_allocMulti( m, out_pElem, ElemType, nElem ) \
	Set2_allocMulti_sub( m, (void*)(out_pElem), sizeof(ElemType) * (nElem) )
int  Set2_allocMulti_sub( Set2* m, void* out_pElem, size_t ElemsSize );

#define  Set2_forEach( self, Item, Item_Over, Type ) \
	*(Item) = (Type*)( (self)->First ),  *(Item_Over) = (Type*)( (self)->Next ); \
	*(Item) < *(Item_Over); \
	*(Item) += 1

errnum_t  Set2_getIterator( Set2* self, Set2_IteratorClass* out_Iterator, int ElementSize );
errnum_t  Set2_getDescendingIterator( Set2* self, Set2_IteratorClass* out_Iterator, int ElementSize );
void*  Set2_IteratorClass_getNext( Set2_IteratorClass* self );
void*  Set2_IteratorClass_getPrevious( Set2_IteratorClass* self );


//[Set2_forEach2]
#define  Set2_forEach2( self, Iterator, out_Element ) \
	Set2_forEach2_1( self, Iterator, out_Element, sizeof(**(out_Element)) ); \
	Set2_forEach2_2( self, Iterator, out_Element ); \
	Set2_forEach2_3( self, Iterator, out_Element )

inline void  Set2_forEach2_1( Set2* self, Set2_IteratorClass* Iterator,  void* out_Element,
	size_t ElementSize )
{
	Set2_getIterator( self, Iterator, ElementSize );
	*(void**) out_Element = Set2_IteratorClass_getNext( Iterator );
}

inline bool  Set2_forEach2_2( Set2* self,  Set2_IteratorClass* Iterator,  void* out_Element )
{
	UNREFERENCED_VARIABLE_2( self, Iterator );
	return  ( *(void**) out_Element != NULL );
}

inline void  Set2_forEach2_3( Set2* self, Set2_IteratorClass* Iterator,  void* out_Element )
{
	UNREFERENCED_VARIABLE( self );
	*(void**) out_Element = Set2_IteratorClass_getNext( Iterator );
}


#define  Set2_ref( m, iElem, out_pElem, ElemType ) \
	Set2_ref_imp( m, iElem, out_pElem, sizeof(ElemType) )

int  Set2_ref_imp( Set2* m, int iElem, void* out_pElem, size_t ElemSize );

#define  Set2_getCount( m, Type ) \
	( (Type*)(m)->Next - (Type*)(m)->First )

#define  Set2_checkPtrInArr( m, p ) \
	( (m)->First <= (p) && (p) < (m)->Over ? 0 : E_NOT_FOUND_SYMBOL )

int  Set2_separate( Set2* m, int NextSize, void** allocate_Array );

#ifdef _DEBUG
void  Set2_setDebug( Set2* m, void* PointerOfDebugArray );
#endif

 
/***********************************************************************
  <<< [Set2a] >>> 
************************************************************************/
typedef  struct _Set2  Set2a;

void  Set2a_initConst( Set2a* m, void* ArrInStack );
int   Set2a_init( Set2a* m, void* ArrInStack, size_t ArrInStack_Size );
int   Set2a_finish( Set2a* m, void* ArrInStack, int e );
int   Set2a_toEmpty( Set2a* m );
//int Set2a_alloc( Set2a* m, void* ArrInStack, ClassA** out_p, Type ClassA );
int   Set2a_expandIfOverByAddr( Set2a* m, void* OverAddrBasedOnNowFirst );



// for inside

#define  Set2a_initConst( m, ArrInStack ) \
	( (m)->First = (ArrInStack) )

#define  Set2a_finish( m, ArrInStack, e ) \
	( (m)->First == (ArrInStack) ? (e) : ( free( (m)->First ), (e) ) )

#define  Set2a_toEmpty( m ) \
	Set2_toEmpty( m )

#define  Set2a_alloc( m, ArrInStack, out_Pointer, ClassA ) \
	( (void*)( (ClassA*)((m)->Next) + 1 ) <= (m)->Over ? \
		( *(out_Pointer) = (ClassA*)(m)->Next,  (m)->Next = (ClassA*)((m)->Next) + 1, 0 ) : \
		Set2a_alloc_imp( m, ArrInStack, out_Pointer, sizeof(ClassA) ) )

int  Set2a_alloc_imp( Set2a* m, void* ArrInStack, void* out_Pointer, size_t ElemSize );

#define  Set2a_expandIfOverByAddr( m, ArrInStack, OverAddrBasedOnNowFirst ) \
	( (void*)(OverAddrBasedOnNowFirst) <= (m)->Over ? 0 : \
		Set2a_expandIfOverByAddr_imp( m, ArrInStack, OverAddrBasedOnNowFirst ) )

int  Set2a_expandIfOverByAddr_imp( Set2a* m, void* ArrInStack, void* OverAddrBasedOnNowFirst );


 
#ifdef  __cplusplus
 }  /* End of C Symbol */ 
#endif
#endif
 
/*=================================================================*/
/* <<< [DebugTools/DebugTools.h] >>> */ 
/*=================================================================*/
 
#if  __cplusplus
 extern "C" {  /* Start of C Symbol */ 
#endif


#ifndef NDEBUG
	#define  NDEBUG_ERROR
#else
	#define  NDEBUG_ERROR  ___cut_NDEBUG_ERROR
#endif

 
/*[dll_global_g_DebugBreakCount]*/
#ifndef  dll_global_g_DebugBreakCount
	#define  dll_global_g_DebugBreakCount
#endif
 
/***********************************************************************
  <<< [TestableDebugBreak] >>> 
************************************************************************/
#define  TestableDebugBreak()  ( TestableDebugBreak_Sub() ? (DebugBreakR(),0) : 0 )
int      TestableDebugBreak_Sub(void);

void     SetTestableDebugBreak( bool IsEnableBreak );
int      GetDebugBreakCount(void);


 
#if  __cplusplus
 }  /* End of C Symbol */ 
#endif


 
/*=================================================================*/
/* <<< [StrT/StrT.h] >>> */ 
/*=================================================================*/
 
#if  __cplusplus
 extern "C" {  /* Start of C Symbol */ 
#endif

errnum_t  StrT_cpy( TCHAR* Dst, size_t DstSize, const TCHAR* Src );
errnum_t  StrT_cat( TCHAR* Dst, size_t DstSize, const TCHAR* Src );
TCHAR*  StrT_chrs( const TCHAR* s, const TCHAR* keys );
TCHAR*  StrT_rstr( const TCHAR* String, const TCHAR* SearchStart, const TCHAR* Keyword,
	void* NullConfig );
TCHAR*  StrT_skip( const TCHAR* s, const TCHAR* keys );
TCHAR*  StrT_rskip( const TCHAR* String, const TCHAR* SearchStart, const TCHAR* Keys,
	void* NullConfig );
bool    StrT_isCIdentifier( TCHAR Character );
TCHAR*  StrT_searchOverOfCIdentifier( const TCHAR* Text );
int  StrT_cmp_part( const TCHAR* StringA_Start, const TCHAR* StringA_Over,
	const TCHAR* StringB );
int  StrT_cmp_part2( const TCHAR* StringA_Start, const TCHAR* StringA_Over,
	const TCHAR* StringB_Start, const TCHAR* StringB_Over );
#define  TwoChar8( Character1, Character2 ) \
	( (Character1) + ( (Character2) << 8 ) )
#define  FourChar8( Character1, Character2, Character3, Character4 ) \
	( (Character1) + ( (Character2) << 8 ) + ( (Character3) << 16 ) + ( (Character4) << 24 ) )

inline errnum_t  StrT_cat( TCHAR* Dst, size_t DstSize, const TCHAR* Src )
{
	return  stcpy_part_r( Dst, DstSize, _tcschr( Dst, _T('\0') ), NULL, Src, NULL );
}


 
//[GetStringSizeFromPointer]
inline size_t  GetStringSizeFromPointer( void* String, size_t StringSize, void* Pointer )
{
	return  (uintptr_t) String + StringSize - (uintptr_t) Pointer;
}

 
/***********************************************************************
  <<< [StrT_Malloc] >>> 
************************************************************************/
errnum_t  MallocAndCopyString( const TCHAR** out_NewString, const TCHAR* SourceString );
errnum_t  MallocAndCopyString_char( const TCHAR** out_NewString, const char* SourceString );
errnum_t  MallocAndCopyStringByLength( const TCHAR** out_NewString, const TCHAR* SourceString,
	unsigned CountOfCharacter );

#ifndef _UNICODE
	#define  MallocAndCopyString_char  MallocAndCopyString
#endif

 
/***********************************************************************
  <<< [StrT_Edit] >>> 
************************************************************************/
errnum_t  StrT_trim( TCHAR* out_Str, size_t out_Str_Size, const TCHAR* in_Str );
errnum_t  StrT_cutLastOf( TCHAR* in_out_Str, TCHAR Charactor );
errnum_t  StrT_cutLineComment( TCHAR* out_Str, size_t out_Str_Size, const TCHAR* in_Str, const TCHAR* CommentSign );
errnum_t  StrT_meltCmdLine( TCHAR* out_Str, size_t out_Str_Size, const TCHAR** pLine );
errnum_t  StrT_getExistSymbols( unsigned* out, bool bCase, const TCHAR* Str, const TCHAR* Symbols, ... );
errnum_t  StrT_replace1( TCHAR* in_out_String, TCHAR FromCharacter, TCHAR ToCharacter,
	unsigned Opt );


 
/***********************************************************************
  <<< [StrT_Edit2] >>> 
************************************************************************/
errnum_t  StrT_replace( TCHAR* Out, size_t OutSize, const TCHAR* In,
                   const TCHAR* FromStr, const TCHAR* ToStr, unsigned Opt );
errnum_t  StrT_changeToXML_Attribute( TCHAR* out_Str, size_t StrSize, const TCHAR* InputStr );
errnum_t  StrT_resumeFromXML_Attribute( TCHAR* out_Str, size_t out_Str_Size, const TCHAR* XML_Attr );
errnum_t  StrT_changeToXML_Text( TCHAR* out_Str, size_t StrSize, const TCHAR* InputStr );

enum { STR_1TIME = 1 };


 
/***********************************************************************
  <<< [W3CDTF] >>> 
************************************************************************/
enum { W3CDTF_MAX_LENGTH = 27+3 };  /* 小数3桁 */
enum { W3CDTF_CURRENT_TIME_ZONE = 9999 };

errnum_t  W3CDTF_fromSYSTEMTIME( TCHAR* out_W3CDTF, size_t W3CDTF_ByteSize,
	const SYSTEMTIME* Time, int TimeZoneMinute );
errnum_t  W3CDTF_toSYSTEMTIME( const TCHAR* String, SYSTEMTIME* out_Time, int* out_BiasMinute );
errnum_t  W3CDTF_getTimeZoneDesignator( TCHAR* out_TZD, size_t TZD_ByteSize,
	int  BiasMinute );


 
/***********************************************************************
  <<< [StrT_Path] >>> 
************************************************************************/
enum { StrT_LocalPathMaxSize = 4096 };
enum { MAX_LOCAL_PATH = 4096 };
TCHAR*  StrT_refFName( const TCHAR* s );
TCHAR*  StrT_refExt( const TCHAR* s );
bool  StrT_isFullPath( const TCHAR* s );

errnum_t  StrT_getFullPath_part( TCHAR* Str, size_t StrSize, TCHAR* StrStart,
	TCHAR** out_StrLast, const TCHAR* StepPath, const TCHAR* BasePath );
errnum_t  StrT_allocateFullPath( TCHAR** out_FullPath, const TCHAR* StepPath, TCHAR* BasePath );
errnum_t  StrT_getStepPath( TCHAR* out_StepPath, size_t StepPathSize,
	const TCHAR* FullPath, const TCHAR* BasePath );
errnum_t  StrT_getParentFullPath_part( TCHAR* Str, size_t StrSize, TCHAR* StrStart,
	TCHAR** out_StrLast, const TCHAR* StepPath, const TCHAR* BasePath );
errnum_t  StrT_getBaseName_part( TCHAR* Str, size_t StrSize, TCHAR* StrStart,
	TCHAR** out_StrLast, const TCHAR* SrcPath );
errnum_t  StrT_addLastOfFileName( TCHAR* out_Path, size_t PathSize,
                             const TCHAR* BasePath, const TCHAR* AddName );

inline errnum_t  StrT_getFullPath( TCHAR* out_FullPath, size_t FullPathSize,
	const TCHAR* StepPath, const TCHAR* BasePath )
{
	return  StrT_getFullPath_part( out_FullPath, FullPathSize, out_FullPath,
		NULL, StepPath, BasePath );
}

inline errnum_t  StrT_getParentFullPath( TCHAR* Str, size_t StrSize,
	const TCHAR* SrcPath, const TCHAR* BasePath )
{
	return StrT_getParentFullPath_part( Str, StrSize, Str, NULL, SrcPath, BasePath );
}

inline errnum_t  StrT_getBaseName( TCHAR* Str, size_t StrSize, const TCHAR* SrcPath )
{
	return  StrT_getBaseName_part( Str, StrSize, Str, NULL, SrcPath );
}


 
/**************************************************************************
  <<< [StrT_Mul] >>> 
***************************************************************************/
typedef  struct _StrT_Mul  StrT_Mul;
struct _StrT_Mul {
	TCHAR*  First;
	size_t  Size;  /* byte */
	TCHAR*  Next;

	#if ! NDEBUG
		int  BreakOffset;
	#endif
};

#define  StrT_Mul_initConst( m )  ( (m)->First = NULL )
errnum_t  StrT_Mul_init( StrT_Mul* m );
#define  StrT_Mul_finish( m, e )  ( (m)->First != NULL ? free( (m)->First ), (e) : (e) )
#define  StrT_Mul_isInited( m )  ( (m)->First != NULL )
errnum_t  StrT_Mul_add( StrT_Mul* m, const TCHAR* Str, unsigned* out_Offset );
errnum_t  StrT_Mul_toEmpty( StrT_Mul* m );
#define  StrT_Mul_forEach( m, pStr ) \
	*(pStr) = StrT_Mul_getFirst( m ); \
	*(pStr) != NULL; \
	*(pStr) = StrT_Mul_getNext( m, *(pStr) )
#define  StrT_Mul_getFirst( m )  ((m)->First == (m)->Next ? NULL : (m)->First )
#define  StrT_Mul_getNext( m, p ) \
	 ( (p) = _tcschr( p, _T('\0') ) + 1, (p) == (m)->Next ? NULL : (p) )
errnum_t  StrT_Mul_freeLast( StrT_Mul* m, TCHAR* AllocStr );
inline errnum_t  StrT_Mul_getFromOffset( StrT_Mul* m, unsigned Offset, TCHAR** out_Str );

#define  StrT_Mul_getFreeAddr( m )  ((m)->Next)
#define  StrT_Mul_getFreeSize( m )  ( (m)->Size - ((char*)(m)->Next - (char*)(m)->First) - sizeof(TCHAR) )
#define  StrT_Mul_getFreeCount( m ) ( StrT_Mul_getFreeSize( m ) / sizeof(TCHAR) )
#define  StrT_Mul_expandCount( m, c )  ( StrT_Mul_expandSize( (m), (c) * sizeof(TCHAR) ) )
errnum_t  StrT_Mul_expandSize( StrT_Mul* m, size_t FreeSize );
errnum_t  StrT_Mul_commit( StrT_Mul* m );



// implements

//[StrT_Mul_getFromOffset]
inline errnum_t  StrT_Mul_getFromOffset( StrT_Mul* m, unsigned Offset, TCHAR** out_Str )
{
	TCHAR*  str = (TCHAR*)( (char*)m->First + Offset );

	if ( (int)Offset < 0 )  return  E_NOT_FOUND_SYMBOL;
	if ( str > m->Next )    return  E_NOT_FOUND_SYMBOL;

	*out_Str = str;
	return  0;
}


 
/**************************************************************************
  <<< [Strs] >>> 
***************************************************************************/
typedef  struct _Strs  Strs;
struct _Strs {
	char*   MemoryAddress;   /* first memory = [ TCHAR* FirstStr | elem[] ],  other memory = [ elem[] ] */
	char*   MemoryOver;
	char*   NextElem;        /* elem = [ TCHAR* NextStr | TCHAR[] ] */
	TCHAR** PointerToNextStrInPrevElem;  /* first = &FirstStr,  other = &NextStr */
	TCHAR** Prev_PointerToNextStrInPrevElem;

	Strs*   FirstOfStrs;
	Strs*   NextStrs;
};

void Strs_initConst( Strs* m );
errnum_t  Strs_init( Strs* m );
errnum_t  Strs_finish( Strs* m, errnum_t e );
errnum_t  Strs_toEmpty( Strs* m );
bool Strs_isInited( Strs* m );
errnum_t  Strs_add( Strs* m, const TCHAR* Str, const TCHAR** out_pAlloc );
errnum_t  Strs_addBinary( Strs* m, const TCHAR* Str, const TCHAR* StrOver, const TCHAR** out_AllocStr );
errnum_t  Strs_freeLast( Strs* m, TCHAR* AllocStr );
errnum_t  Strs_toEmpty( Strs* m );
/* for ( Strs_forEach( Strs* m, TCHAR** in_out_Str ) ); */
TCHAR*  Strx_getFirst( Strs* m );
TCHAR*  Strx_getNext( Strs* m, TCHAR* Str );


#define  Strs_initConst( m )  ( (m)->MemoryAddress =  NULL )
#define  Strs_isInited( m )    ( (m)->MemoryAddress != NULL )

#define  Strs_forEach( m, pStr ) \
	*(pStr) = Strs_getFirst( m ); \
	*(pStr) != NULL; \
	*(pStr) = Strs_getNext( m, *(pStr) )

#define  Strs_getFirst( m ) \
	( *(TCHAR**) (m)->FirstOfStrs->MemoryAddress )

#define  Strs_getNext( m, p ) \
	( *( (TCHAR**)(p) - 1 ) )

#define  Strs_getFreeAddr( m )  ( (TCHAR*)( (m)->NextElem + sizeof(TCHAR*) ) )
#define  Strs_getFreeSize( m )  ( (m)->MemoryOver - (char*)(m)->NextElem - sizeof(TCHAR*) )
#define  Strs_getFreeCount( m ) ( Strs_getFreeSize( m ) / sizeof(TCHAR) )
#define  Strs_expandCount( m, c )  ( Strs_expandSize( (m), (c) * sizeof(TCHAR) ) )
errnum_t  Strs_expandSize( Strs* m, size_t FreeSize );
errnum_t  Strs_commit( Strs* m, TCHAR* StrOver );

 
/***********************************************************************
  <<< [StrArr] >>> 
************************************************************************/
typedef struct _StrArr  StrArr;
struct _StrArr {
	Set2  Array;  // array of TCHAR*
	Strs  Chars;
};

errnum_t  StrArr_init( StrArr* m );
errnum_t  StrArr_finish( StrArr* m, errnum_t e );

errnum_t  StrArr_add( StrArr* m, const TCHAR* Str, int* out_I );
errnum_t  StrArr_commit( StrArr* m );
errnum_t  StrArr_fillTo( StrArr* m, int n, const TCHAR* Str );
errnum_t  StrArr_toEmpty( StrArr* m );

#define  StrArr_initConst( m )   Set2_initConst( &(m)->Array )
#define  StrArr_getFreeAddr( m )  Strs_getFreeAddr( &(m)->Chars )
#define  StrArr_getFreeSize( m )  Strs_getFreeSize( &(m)->Chars )
#define  StrArr_getFreeCount( m ) Strs_getFreeCount( &(m)->Chars )
#define  StrArr_expandSize( m, sz )  Strs_expandSize( &(m)->Chars, sz )
#define  StrArr_expandCount( m, c )  Strs_expandCount( &(m)->Chars, c )
#define  StrArr_getArray( m )     ((TCHAR**)(m)->Array.First)
//#define  StrArr_getN( m )          Set2_getCount( &(m)->Array, TCHAR* )
#define  StrArr_getCount( m )        Set2_getCount( &(m)->Array, TCHAR* )


 
/***********************************************************************
  <<< [StrArr_forEach] >>> 
************************************************************************/
#define  StrArr_forEach( self, Iterator, out_String ) \
	StrArr_forEach_1( self, Iterator, out_String ); \
	StrArr_forEach_2( Iterator ); \
	StrArr_forEach_3( Iterator, out_String )

/*[StrArrIterator]*/
typedef struct _StrArrIterator  StrArrIterator;
struct _StrArrIterator {
	const TCHAR**  Pointer;
	const TCHAR**  PointerOver;
};

inline void  StrArr_forEach_1( StrArr* self, StrArrIterator* Iterator, const TCHAR** out_String )
{
	Iterator->Pointer = (const TCHAR**) self->Array.First;
	Iterator->PointerOver = (const TCHAR**) self->Array.Next;
	*out_String = *Iterator->Pointer;
}

inline bool  StrArr_forEach_2( StrArrIterator* Iterator )
{
	return  Iterator->Pointer < Iterator->PointerOver;
}

inline void  StrArr_forEach_3( StrArrIterator* Iterator, const TCHAR** out_String )
{
	Iterator->Pointer += 1;
	*out_String = *Iterator->Pointer;
}


 
/***********************************************************************
  <<< [CSV] >>> 
************************************************************************/
errnum_t  StrT_meltCSV( TCHAR* out_Str, size_t out_Str_Size, const TCHAR** pCSV );
errnum_t  StrArr_parseCSV( StrArr* m, const TCHAR* CSVLine );
errnum_t  StrT_parseCSV_f( const TCHAR* StringOfCSV, bit_flags32_t* out_ReadFlags, const TCHAR* Types, ... );


 
/***********************************************************************
  <<< [StrMatchKey] >>> 
************************************************************************/
typedef struct _StrMatchKey  StrMatchKey;
struct _StrMatchKey {
	TCHAR*  Keyword;
	TCHAR*  WildcardLeftStr;
	size_t  WildcardLeftLength;
	TCHAR*  WildcardRightStr;
	size_t  WildcardRightLength;
};
void      StrMatchKey_initConst( StrMatchKey* m );
errnum_t  StrMatchKey_init( StrMatchKey* m, const TCHAR* Keyword );
errnum_t  StrMatchKey_finish( StrMatchKey* m, errnum_t e );
bool      StrMatchKey_isMatch( StrMatchKey* m, const TCHAR* String );


 
#if  __cplusplus
 }  /* End of C Symbol */ 
#endif

 
/*=================================================================*/
/* <<< [CRT_plus_2/CRT_plus_2.h] >>> */ 
/*=================================================================*/
 
/***********************************************************************
  <<< [HeapMemory_allocate] >>> 
  <<< [HeapMemory_allocateArray] >>> 
************************************************************************/

#define  HeapMemory_allocate( out_Pointer ) \
    HeapMemory_allocateBytes( out_Pointer, sizeof( **(out_Pointer) ) )

#define  HeapMemory_allocateArray( out_Pointer, Count ) \
    HeapMemory_allocateBytes( out_Pointer, sizeof( **(out_Pointer) ) * (Count) )

inline errnum_t  HeapMemory_allocateBytes( void* out_Pointer, size_t MemorySize )
{
	void**  out = (void**) out_Pointer;

	*out = malloc( MemorySize );

	if ( *out == NULL )
		{ return  E_FEW_MEMORY; }
	else
		{ return  0; }
}


/*[MallocMemory]*/
inline errnum_t  MallocMemory( void* out_MemoryAddress, size_t MemorySize )
{
	return  HeapMemory_allocateBytes( out_MemoryAddress, MemorySize );
}


 
/***********************************************************************
  <<< [HeapMemory_free] >>> 
************************************************************************/
inline errnum_t  HeapMemory_free( const void* in_out_MemoryAddress, errnum_t e )
{
	void*  address = *(void**) in_out_MemoryAddress;

	if ( address != NULL )
		{ free( address ); }

	*(void**) in_out_MemoryAddress = NULL;

	return  e;
}


/*[FreeMemory]*/
inline errnum_t  FreeMemory( const void* in_out_MemoryAddress, errnum_t e )
{
	return  HeapMemory_free( in_out_MemoryAddress, e );
}


 
/*=================================================================*/
/* <<< [Error4/Error4.h] >>> */ 
/*=================================================================*/
 
#if  __cplusplus
 extern "C" {  /* Start of C Symbol */ 
#endif


 
/***********************************************************************
  <<< [SetBreakErrorID] >>> 
************************************************************************/
#ifndef  ENABLE_ERROR_BREAK_IN_ERROR_CLASS
	#if ! NDEBUG
		#define  ENABLE_ERROR_BREAK_IN_ERROR_CLASS  1
	#else
		#define  ENABLE_ERROR_BREAK_IN_ERROR_CLASS  0
	#endif
#endif

#ifndef  ENABLE_DEBUG_ERROR_BREAK_IN_ERROR_CLASS
	#if ! NDEBUG
		#define  ENABLE_DEBUG_ERROR_BREAK_IN_ERROR_CLASS  1
	#else
		#define  ENABLE_DEBUG_ERROR_BREAK_IN_ERROR_CLASS  0
	#endif
#endif

#ifndef  IS_MULTI_THREAD_ERROR_CLASS
 
	#define  IS_MULTI_THREAD_ERROR_CLASS  0  /*[IS_MULTI_THREAD_ERROR_CLASS]:single*/
 
#endif

/*[dll_global_g_Error]*/
#ifndef  dll_global_g_Error
	#define  dll_global_g_Error
#endif


#if ENABLE_ERROR_BREAK_IN_ERROR_CLASS
	/*[IF][IF_D][ASSERT_R][ASSERT_D]*/
	/* "IF" is able to break at nearest code raising error */
	#define  IF_D(x)  IF(x)
	#define  IF(x) \
		if( (x) && ( OnRaisingError_Sub((const char*)__FILE__,__LINE__) ? (DebugBreakR(),1) : (1) ) )

	#define  ASSERT_R( x, goto_err_or_Statement ) \
		__pragma(warning(push)) \
		__pragma(warning(disable:4127)) \
			do{  IF(!(x)) { goto_err_or_Statement; } }  while(0)   /* do-while is CERT standard PRE10-C */ \
		__pragma(warning(pop))

	#define  ASSERT_D( x, goto_err_or_Statement )  ASSERT_R( x, goto_err_or_Statement )
#else
	#define  IF(x)  if(x)
	#define  IF_D(x) \
		__pragma(warning(push)) \
		__pragma(warning(disable:4127)) \
			if(0) \
		__pragma(warning(pop))

	#define  ASSERT_R( x, goto_err_or_Statement ) \
		__pragma(warning(push)) \
		__pragma(warning(disable:4127)) \
			do{  if(!(x)) { goto_err_or_Statement; } }while(0)   /* do-while is CERT standard PRE10-C */ \
		__pragma(warning(pop))

	#define  ASSERT_D( x, goto_err_or_Statement )
#endif


void  DebugBreakR(void);
#if ! ENABLE_ERROR_BREAK_IN_ERROR_CLASS
	inline void  SetBreakErrorID( int ID ) { ID=ID; /* avoid warning */ }
	inline void  ClearError() {}
	inline void  IfErrThenBreak() {}
	typedef  int  ErrStackAreaClass;  // dummy type
	inline void  PushErr( ErrStackAreaClass* ErrStackArea )  { UNREFERENCED_VARIABLE( ErrStackArea ); }
	inline void  PopErr(  ErrStackAreaClass* ErrStackArea )  { UNREFERENCED_VARIABLE( ErrStackArea ); }
#else
	void  SetBreakErrorID( int ID );
	void  ClearError(void);
	void  IfErrThenBreak(void);
	typedef  struct _ErrorClass  ErrStackAreaClass;
	void  PushErr( ErrStackAreaClass* ErrStackArea );
	void  PopErr(  ErrStackAreaClass* ErrStackArea );

	bool  OnRaisingError_Sub( const char* FilePath, int LineNum );

	typedef  struct _ErrorClass  ErrorClass;  /*[ErrorClass]*/
	struct _ErrorClass {
		bool         IsError;
		#if  ENABLE_DEBUG_ERROR_BREAK_IN_ERROR_CLASS
			int     ErrorID;
		#endif
		int          BreakErrorID;
		const char*  FilePath;
		int          LineNum;

		#if IS_MULTI_THREAD_ERROR_CLASS
			FinalizerClass  Finalizer;
			#if  ENABLE_DEBUG_ERROR_BREAK_IN_ERROR_CLASS
				DWORD  ThreadID;
				int    GlobalErrorID;
			#endif
		#endif
	};
	errnum_t  ErrorClass_finalize( ErrorClass* self, errnum_t e );

	#if ! IS_MULTI_THREAD_ERROR_CLASS
		dll_global_g_Error extern  ErrorClass  g_Error;
	#endif
#endif

errnum_t  MergeError( errnum_t e, errnum_t ee );
void  ErrorLog_add( errnum_t e );


 
/***********************************************************************
  <<< [ErrorMessage] >>> 
************************************************************************/
void  Error4_printf( const TCHAR* format, ... );
void  Error4_getErrStr( int ErrNum, TCHAR* out_ErrStr, size_t ErrStrSize );
void  Error4_clear( int err_num );
errnum_t  SaveWindowsLastError(void);


 
/***********************************************************************
  <<< [stdio] >>> 
************************************************************************/
void  Error4_showToStdErr( int err_num );


 
/***********************************************************************
  <<< [DEBUG_TRUE, DEBUG_FALSE] >>> 
************************************************************************/
#if ! NDEBUG
 #define  DEBUG_TRUE   1
 #define  DEBUG_FALSE  0
#else
 #define  DEBUG_TRUE   __cut_on_debug =
 #define  DEBUG_FALSE  0
#endif


 
/***********************************************************************
  <<< [DEBUG_CODE] >>> 
************************************************************************/
#if ! NDEBUG
	#define  DEBUG_CODE( expression ) \
		__pragma(warning(push)) \
		__pragma(warning(disable:4127)) \
			do { expression; } while(0)   /* do-while is CERT standard PRE10-C */ \
		__pragma(warning(pop))
#else
	#define  DEBUG_CODE( expression )  /* no execute */
#endif


 
/***********************************************************************
  <<< [CHECK_ARG] >>> 
************************************************************************/
#ifndef  CHECK_ARG
  #define  CHECK_ARG  1
#endif

/*[GetIsCheckArg][SetIsCheckArg]*/
#if CHECK_ARG
extern bool  g_IsCheckArg;
inline bool  GetIsCheckArg(void)  { return  g_IsCheckArg; }
inline void  SetIsCheckArg( bool IsCheckArg )  { g_IsCheckArg = IsCheckArg; }
#endif


 
/***********************************************************************
  <<< [INVALID_VALUE] >>> 
************************************************************************/
enum { INVALID_VALUE = 0xDEDEDEDE };


 
/***********************************************************************
  <<< [DUMMY_INITIAL_VALUE] >>> 
************************************************************************/
#ifndef NDEBUG
	enum { DUMMY_INITIAL_VALUE = 0xDEDEDEDE };
	enum { DUMMY_INITIAL_VALUE_8BIT  = 0xDE };
	enum { DUMMY_INITIAL_VALUE_16BIT = 0xDEDE };
	#ifdef _UNICODE
		enum { DUMMY_INITIAL_VALUE_TCHAR = 0xDEDE };
	#else
		enum { DUMMY_INITIAL_VALUE_TCHAR = 0xDE - 0x100 };  /* 0x100 is to change to signed type */
	#endif
	/* Disable VC++ warning C4701 : local variable may be used without having been initialized */
	/* 0xDEDEDEDE means "not initialized" */
#else
	enum { DUMMY_INITIAL_VALUE = 0 };
	enum { DUMMY_INITIAL_VALUE_8BIT  = 0 };
	enum { DUMMY_INITIAL_VALUE_16BIT = 0 };
	enum { DUMMY_INITIAL_VALUE_TCHAR = 0 };
	/* 0 reduces code size */
#endif


 
/***********************************************************************
  <<< [DISCARD_STRUCT] >>> 
  <<< [DISCARD_ARRAY] >>> 
  <<< [DISCARD_BYTES] >>> 
  <<< [MEMSET_TO_NOT_INIT] >>> 
************************************************************************/
#ifndef  ENABLE_DISCARD_STRUCT
 #if ! NDEBUG
  #define  ENABLE_DISCARD_STRUCT  1
 #else
  #define  ENABLE_DISCARD_STRUCT  0
 #endif
#endif

#if  USE_MEMSET_TO_NOT_INIT
	#define  DISCARD_STRUCT( TypedAddress ) \
		memset( TypedAddress, 0xDE, sizeof(*(TypedAddress)) )
	#define  DISCARD_ARRAY( TypedAddress, Count ) \
		memset( TypedAddress, 0xDE, sizeof(*(TypedAddress)) * (Count) )
	#define  DISCARD_BYTES( Address, ByteSize )  memset( Address, 0xDE, ByteSize )
//	#define  MEMSET_TO_NOT_INIT( Address, ByteSize )  memset( Address, 0xDE, ByteSize )
#else
	#define  DISCARD_STRUCT( Address )                __noop()
	#define  DISCARD_ARRAY( Address, Count )          __noop()
	#define  DISCARD_BYTES( Address, ByteSize )       __noop()
//	#define  MEMSET_TO_NOT_INIT( Address, ByteSize )  __noop()
#endif


 
/***********************************************************************
  <<< [NAME_STR] >>> 
************************************************************************/
#ifndef  NAME_STR
 #if ! NDEBUG
  #define  NAME_STR  1
 #else
  #define  NAME_STR  0
 #endif
#endif

 
/***********************************************************************
  <<< [Error4_VariablesClass] >>> 
************************************************************************/
typedef struct _Error4_VariablesClass  Error4_VariablesClass;
struct _Error4_VariablesClass {
	DWORD  WindowsLastError;
};

Error4_VariablesClass*  Get_Error4_Variables(void);

#ifdef _DEBUG
	extern Error4_VariablesClass*  g_Error4_Variables;
#endif


 
#if  __cplusplus
 }  /* End of C Symbol */ 
#endif
 
/*=================================================================*/
/* <<< [FileT/FileT.h] >>> */ 
/*=================================================================*/
 
#if  __cplusplus
 extern "C" {  /* Start of C Symbol */ 
#endif

#define  FileT_isExistWildcard  1
bool  FileT_isExist( const TCHAR* path );
bool  FileT_isFile( const TCHAR* path );
bool  FileT_isDir( const TCHAR* path );
int   FileT_isDiff( const TCHAR* Path1, const TCHAR* Path2, bool* bDiff );
int   FileT_isSameText( TCHAR* Path1, TCHAR* Path2, int Format1, int Format2, bool* out_bSame );
int   FileT_isSameBinaryFile( const TCHAR* PathA, const TCHAR* PathB, int Flags, bool* out_IsSame );


 
/* FileT_CallByNestFindData */ 
typedef struct {
	void*     CallerArgument;
	TCHAR*    FullPath;  // abstruct path
	TCHAR*    StepPath;
	TCHAR*    FileName;
	DWORD     FileAttributes;
} FileT_CallByNestFindData;

int  FileT_callByNestFind( const TCHAR* Path, BitField Flags, void* Obj, FuncType Callback );

enum { FileT_FolderBeforeFiles = 1 };
enum { FileT_FolderAfterFiles  = 2 };
enum { FileT_Folder = FILE_ATTRIBUTE_DIRECTORY };

 
/***********************************************************************
  <<< [FileT_Read] >>> 
************************************************************************/
int  FileT_openForRead( FILE** out_pFile, const TCHAR* path );
// int  FileT_close( FILE* File, int e );
errnum_t  FileT_closeAndNULL( FILE** in_out_File, errnum_t e );


 
#if  __cplusplus
 }  /* End of C Symbol */ 
#endif
 
/*=================================================================*/
/* <<< [IniFile2/IniFile2.h] >>> */ 
/*=================================================================*/
 
#if  __cplusplus
 extern "C" {  /* Start of C Symbol */ 
#endif
 
bool  IniStr_isLeft( const TCHAR* line, const TCHAR* symbol ); 
 
TCHAR*  IniStr_refRight( const TCHAR* line, bool bTrimRight ); 
 
#if  __cplusplus
 }    /* End of C Symbol */ 
#endif

 
/*=================================================================*/
/* <<< [Locale/Locale.h] >>> */ 
/*=================================================================*/
 
#if  __cplusplus
 extern "C" {  /* Start of C Symbol */ 
#endif


 
/***********************************************************************
  <<< [Locale] >>> 
************************************************************************/
extern char*  g_LocaleSymbol;
int  Locale_init(void);
int  Locale_isInited(void);


 
#if  __cplusplus
 }  /* End of C Symbol */ 
#endif


 
/*=================================================================*/
/* <<< [PlatformSDK_plus/PlatformSDK_plus.h] >>> */ 
/*=================================================================*/
 
int  GetCommandLineUnnamed( int Index1, TCHAR* out_AParam, size_t AParamSize ); 
int  GetCommandLineNamed( const TCHAR* Name, bool bCase, TCHAR* out_Value, size_t ValueSize );
int  GetCommandLineNamedC8( const TCHAR* Name, bool bCase, char* out_Value, size_t ValueSize );
int  GetCommandLineNamedI( const TCHAR* Name, bool bCase, int* out_Value );
bool GetCommandLineExist( const TCHAR* Name, bool bCase );

#if ! _UNICODE
	#define  GetCommandLineNamedC8  GetCommandLineNamed
#endif

 
/*=================================================================*/
/* <<< [Global0/Global0.h] >>> */ 
/*=================================================================*/
 
#if  __cplusplus
 extern "C" {  /* Start of C Symbol */ 
#endif


 
/***********************************************************************
  <<< [Globals] >>> 
************************************************************************/
#define  USE_GLOBALS  1

void Globals_initConst(void);
int  Globals_initialize(void);
int  Globals_finalize( int e );

#if NDEBUG
  #define  get_InitedObject( m, isInited )  (m)
#else
  #define  get_InitedObject( m, isInited )  ( isInited( m ) ? (m) : (DebugBreakR(), (m)) )
#endif


 
#if  __cplusplus
 }  /* End of C Symbol */ 
#endif
 
#endif  // __CLIB_H 

#ifdef _MSC_VER
 #if  showIncludes
  #pragma message( "end of #include  \"" __FILE__ "\"" )
 #endif
#endif
 
