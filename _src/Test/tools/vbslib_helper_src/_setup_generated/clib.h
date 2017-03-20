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
enum { E_UNKNOWN_DATA_TYPE  = E_CATEGORY_COMMON | 0x08 }; /* 1032 */
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

enum { NOT_FOUND_INDEX = -1 };

 
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
 
#include  <stddef.h> 
 
#include  <crtdbg.h> 
 
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
 
#include  <malloc.h> 
 
#include  <io.h> 
 
#include  <fcntl.h> 
 
#include  <tlhelp32.h> 
 
/*=================================================================*/
/* <<< [CRT_plus_1/CRT_plus_1.h] >>> */ 
/*=================================================================*/
 
#if  __cplusplus
 extern "C" {  /* Start of C Symbol */ 
#endif


 
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
typedef  unsigned char   byte_t;     /* This is not C99 */
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


 
/***********************************************************************
  <<< [INT_DECIMAL_LENGTH_MAX] >>> 
************************************************************************/
#define  INT_DECIMAL_LENGTH_MAX  12


 
/***********************************************************************
  <<< [INVALID_ARRAY_INDEX] >>> 
************************************************************************/
enum { INVALID_ARRAY_INDEX = -1 };


 
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
  <<< (malloc_redirected) >>> 
************************************************************************/
#define  malloc   malloc_redirected
#define  realloc  realloc_redirected
#define  calloc   calloc_redirected
void*  malloc_redirected( size_t  in_Size );
void*  realloc_redirected( void*  in_Address,  size_t  in_Size );
void*  calloc_redirected( size_t  in_Count,  size_t  in_Size );
void*  malloc_no_redirected( size_t  in_Size );
void*  realloc_no_redirected( void*  in_Address,  size_t  in_Size );
void*  calloc_no_redirected( size_t  in_Count,  size_t  in_Size );


 
/***********************************************************************
  <<< [FuncType] >>> 
************************************************************************/
typedef  int (*FuncType)( void* Param ); 
typedef  errnum_t (* InitializeFuncType )( void* self, void* Parameter );
//typedef  int (*FinishFuncType)( void* m, int e );  /*[FinishFuncType]*/
typedef  errnum_t (*FinalizeFuncType)( void* self, errnum_t e );  /*[FinalizeFuncType]*/


 
/***********************************************************************
  <<< [InterfaceID_Class] >>> 
  <<< [InterfaceToVTableClass] >>> 
- const InterfaceID_Class  g_SampleInterface_ID;
************************************************************************/
typedef struct _InterfaceID_Class  InterfaceID_Class;
struct _InterfaceID_Class {
	char*  InterfaceName;
};

typedef struct _InterfaceToVTableClass  InterfaceToVTableClass;
struct _InterfaceToVTableClass {
	const InterfaceID_Class*  InterfaceID;
	const void*               VTable;
};


 
/***********************************************************************
  <<< [ClassID_Class] >>> 
- const ClassID_Class  g_SampleClass_ID;
************************************************************************/
typedef struct _ClassID_Class  ClassID_Class;
struct _ClassID_Class {
	char*                          ClassName;
	const ClassID_Class**          SuperClassID_Array;
	int                            SuperClassID_Array_Count;
	size_t                         Size;
	InitializeFuncType             InitializeFunction;
	const InterfaceToVTableClass*  InterfaceToVTable_Array;
	int                            InterfaceToVTable_Array_Conut;
};

bool      ClassID_Class_isSuperClass( const ClassID_Class* ClassID, const ClassID_Class* SuperClassID );
errnum_t  ClassID_Class_createObject( const ClassID_Class* ClassID, void* out_Object, void* Parameter );
void*     ClassID_Class_getVTable( const ClassID_Class* ClassID, const InterfaceID_Class* InterfaceID );


 
/***********************************************************************
  <<< [ClassID_SuperClass] >>> 
************************************************************************/
typedef struct _ClassID_SuperClass  ClassID_SuperClass;
struct _ClassID_SuperClass {
	const ClassID_Class*  ClassID;  /* &g_(ClassName)_ID */
};
extern const ClassID_Class  g_ClassID_SuperClass_ID;


 
/***********************************************************************
  <<< [g_FinalizerInterface_ID] >>> 
************************************************************************/

extern const InterfaceID_Class  g_FinalizerInterface_ID;

/*[FinalizerVTableClass]*/
typedef struct _FinalizerVTableClass  FinalizerVTableClass;
struct _FinalizerVTableClass {
	int               OffsetToSelf;
	FinalizeFuncType  Finalize;
};


 
/***********************************************************************
  <<< [g_PrintXML_Interface_ID] >>> 
************************************************************************/

extern const InterfaceID_Class  g_PrintXML_Interface_ID;

typedef errnum_t (* PrintXML_FuncType )( void* self, FILE* OutputStream );


/*[PrintXML_VTableClass]*/
typedef struct _PrintXML_VTableClass  PrintXML_VTableClass;
struct _PrintXML_VTableClass {
	int                OffsetToSelf;
	PrintXML_FuncType  PrintXML;
};


 
/***********************************************************************
  <<< [fopen_ccs] >>> 
************************************************************************/
#if defined(_UNICODE) 
  #define  fopen_ccs  ",ccs=UNICODE"
#else
  #define  fopen_ccs  "t"
#endif


 
/***********************************************************************
  <<< [SizedStruct] >>> 
************************************************************************/
typedef struct _SizedStruct  SizedStruct;
struct _SizedStruct {
	size_t  ThisStructSize;
	int     OthersData;
};


 
/***********************************************************************
  <<< [NameOnlyClass] >>> 
************************************************************************/
typedef struct _NameOnlyClass  NameOnlyClass;
struct _NameOnlyClass {
	const TCHAR*  Name;
	const void*   Delegate;
};

 
/***********************************************************************
  <<< [NameAndNumClass] >>> 
************************************************************************/
typedef struct _NameAndNumClass  NameAndNumClass;  /* Like NameOnlyClass */
struct _NameAndNumClass {
	TCHAR*  Name;
	int     Number;
};


 
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


 
/***********************************************************************
  <<< [PointerType_plus] >>> 
************************************************************************/
inline void  PointerType_plus( const void* in_out_Element, int PlusMinusByte )
{
	*(int8_t**) in_out_Element = *(int8_t**) in_out_Element + PlusMinusByte;
}


 
/***********************************************************************
  <<< [PointerType_diff] >>> 
************************************************************************/
inline ptrdiff_t  PointerType_diff( const void* PointerA, const void* PointerB )
{
	return  (uintptr_t) PointerA - (uintptr_t) PointerB;
}


 
/**************************************************************************
 <<< [JOIN_SYMBOL] >>> 
***************************************************************************/
#define JOIN_SYMBOL(x, y)  JOIN_SYMBOL_AGAIN(x, y)
#define JOIN_SYMBOL_AGAIN(x, y) x##y
	/* CERT secure coding standard PRE05-C */


 
/**************************************************************************
 <<< [static_assert] >>> 
***************************************************************************/
#define  static_assert( ConstantExpression, StringLiteral ) \
	__pragma(warning(push)) \
	__pragma(warning(disable:4127)) \
	do { typedef char JOIN_SYMBOL( AssertionFailed_, __LINE__ )[(ConstantExpression) ? 1 : -1]; } while(0) \
	__pragma(warning(pop))

#define  static_assert_global( ConstantExpression, StringLiteral ) \
	__pragma(warning(push)) \
	__pragma(warning(disable:4127)) \
	typedef char JOIN_SYMBOL( AssertionFailed_, __LINE__ )[(ConstantExpression) ? 1 : -1] \
	__pragma(warning(pop))

	/* CERT secure coding standard DCL03-C */
	/* If "ConstantExpression" is false, illegal array size error will be raised. */


 
#if  __cplusplus
 }  /* End of C Symbol */ 
#endif
 
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
 
/***********************************************************************
  <<< [USE_printf_to] >>> 
************************************************************************/
#define  USE_printf_to_stdout    1
#define  USE_printf_to_debugger  2
#define  USE_printf_to_file      3


 
/***********************************************************************
  <<< [PrintfCounterClass] >>> 
************************************************************************/
#if USE_PRINTF_COUNTER

typedef struct _PrintfCounterClass  PrintfCounterClass;
struct _PrintfCounterClass {
	int  Count;
	int  BreakCount;
	int  BreakIndent;
};
extern PrintfCounterClass  g_PrintfCounter;

#endif


 
/***********************************************************************
  <<< [printf_to_file] >>> 
************************************************************************/

#ifndef USE_PRINTF_MULTI_PROCESS
	#define  USE_PRINTF_MULTI_PROCESS  0
#endif

#if USE_PRINTF_MULTI_PROCESS
	#undef   USE_PRINTF_MULTI_THREAD
	#define  USE_PRINTF_MULTI_THREAD  1
#else
	#ifndef USE_PRINTF_MULTI_THREAD
		#define  USE_PRINTF_MULTI_THREAD  1
	#endif
#endif

TCHAR*  GetLogOptionPath(void);
void  printf_to_file( const char* fmt, ... );
void  printf_file_start( bool IsDelete, int IndentWidth );
int   printf_get_path( TCHAR** out_Path );
int   printf_set_path( const TCHAR* Path );

#ifndef   USE_printf_to
 #define  USE_printf_to  USE_printf_to_file
#endif

#if  USE_printf_to == USE_printf_to_file
 #define  printf  printf_to_file
#endif

#if  USE_printf_to == USE_printf_to_file
typedef struct _PrintfFileWorkClass  PrintfFileWorkClass;
struct _PrintfFileWorkClass {
	FILE*   File;
#if USE_PRINTF_MULTI_THREAD
	HANDLE  Mutex;
	int     ThreadIndex;
#endif
};
void      printf_lock_init_const( PrintfFileWorkClass* out_Work );
errnum_t  printf_lock( PrintfFileWorkClass* out_Work );
errnum_t  printf_unlock( PrintfFileWorkClass* work,  errnum_t e );
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
 
errnum_t  ftcopy_part_r( FILE* OutputStream, const TCHAR* Str, const TCHAR* StrOver );
 
errnum_t  OpenConsole( bool  in_OpenIfNoConsole,  bool*  out_IsExistOrNewConsole );

 
#if  __cplusplus
 }    /* End of C Symbol */ 
#endif

 
/*=================================================================*/
/* <<< [StrT_typedef/StrT_typedef.h] >>> */ 
/*=================================================================*/
 
/***********************************************************************
  <<< [NewStringsEnum] >>> 
************************************************************************/
typedef enum  _NewStringsEnum  NewStringsEnum;
enum  _NewStringsEnum {
	NewStringsEnum_NewPointersAndLinkCharacters = 0x06,
	NewStringsEnum_NewPointersAndNewCharacters  = 0x03,
	NewStringsEnum_LinkCharacters               = 0x04,
	NewStringsEnum_NewPointers                  = 0x02,
	NewStringsEnum_NewCharacters                = 0x01,
	NewStringsEnum_NoAllocate                   = 0x00
};


 
/*=================================================================*/
/* <<< [SetX/SetX.h] >>> */ 
/*=================================================================*/
 
#ifndef  __SETX_H 
#define  __SETX_H

#ifdef  __cplusplus
 extern "C" {  /* Start of C Symbol */
#endif

 
/******************************************************************
  <<< Set4_typedef >>> 
*******************************************************************/

typedef struct _Set4      Set4;
typedef struct _Set4Iter  Set4Iter;

typedef  int  (*FuncType_create_in_set4)( void** pm, Set4* Set );
 
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
errnum_t  Set2_init( Set2* m, int FirstSize );
errnum_t  Set2_finish( Set2* m, errnum_t e );
#define  Set2_isInited( m )  ( (m)->First != NULL )

#define  Set2_allocate( m, pp ) \
	Set2_alloc_imp( m, (void*)(pp), sizeof(**(pp)) )

#define  Set2_alloc( m, pp, type ) \
	Set2_alloc_imp( m, (void*)(pp), sizeof(type) )

errnum_t  Set2_alloc_imp( Set2* m, void* pm, size_t size );

#define  Set2_push( m, pp, type ) \
	Set2_alloc_imp( m, (void*)(pp), sizeof(type) )

#define  Set2_pop( m, pp, type ) \
	Set2_pop_imp( m, (void*)(pp), sizeof(type) )

errnum_t  Set2_pop_imp( Set2* m, void* pp, size_t size );

#define  Set2_free( m, pp, e ) \
	Set2_free_imp( m, pp, sizeof(**(pp)), e )
errnum_t  Set2_free_imp( Set2* self,  void* in_PointerOfPointer,  size_t  in_Size_ofElement,  errnum_t  e );

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
errnum_t  Set2_expandIfOverByAddr_imp( Set2* m, void* OverAddrBasedOnNowFirst );

#define  Set2_allocMulti( m, out_pElem, ElemType, nElem ) \
	Set2_allocMulti_sub( m, (void*)(out_pElem), sizeof(ElemType) * (nElem) )
errnum_t  Set2_allocMulti_sub( Set2* m, void* out_pElem, size_t ElemsSize );

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


#define  Set2_getArray( self, out_Array, out_Count ) \
	( ( *(void**)(out_Array) = (self)->First, \
	*(out_Count) = ( (byte_t*) (self)->Next - (byte_t*) (self)->First ) / sizeof(**(out_Array))), 0 )

#define  Set2_refer( m, iElem, out_pElem ) \
	Set2_ref_imp( m, iElem, out_pElem, sizeof(**(out_pElem)) )

#define  Set2_ref( m, iElem, out_pElem, ElemType ) \
	Set2_ref_imp( m, iElem, out_pElem, sizeof(ElemType) )

errnum_t  Set2_ref_imp( Set2* m, int iElem, void* out_pElem, size_t ElemSize );

#define  Set2_isEmpty( m ) \
	( (m)->Next == (m)->First )

#define  Set2_getCount( m, Type ) \
	( ( (byte_t*)(m)->Next - (byte_t*)(m)->First ) / sizeof(Type) )

#define  Set2_getCountMax( m, Type ) \
	( ( (byte_t*)(m)->Over - (byte_t*)(m)->First ) / sizeof(Type) )

#define  Set2_checkPtrInArr( m, p ) \
	( (m)->First <= (p) && (p) < (m)->Over ? 0 : E_NOT_FOUND_SYMBOL )

errnum_t  Set2_separate( Set2* m, int NextSize, void** allocate_Array );

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


 
/******************************************************************
  <<< [Set4] >>> 
*******************************************************************/
struct _Set4 {
	byte_t*   FirstBlock;
	byte_t*   CurrentBlockFirst;
	byte_t*   CurrentBlockNext;
	union {
		byte_t*   CurrentBlockOver;
		byte_t**  NextBlock;
	} u;
	size_t    HeapSize;
	size_t    ElementSize;
};

struct _Set4Iter {
	void*  p;
	void*  Over;
};

/* errnum_t  Set4_init( Set4* self, Type, int FirstHeapSize ); */
/* errnum_t  Set4_allocate( Set4* self, Type** out_ElementPointer ); */
/* errnum_t  Set4_free( Set4* self, Type** in_out_ElementPointer ); */
/* Type*     Set4_ref( Set4* self, int i, Type ); */


/* Private */
errnum_t  Set4_init_imp( Set4* self,  size_t in_ElementSize,  size_t FirstHeapSize );
errnum_t  Set4_finish2_imp2( Set4* self );
errnum_t  Set4_finish2_imp( Set4* self,  errnum_t  e,  size_t in_ElementSize,  FinalizeFuncType  in_Type_Finalize );
errnum_t  Set4_alloc_imp( Set4* self,  void* out_ElementPointer,  size_t in_ElementSize );
errnum_t  Set4_free_imp( Set4* self,  void* in_out_ElementPointer,  size_t in_ElementSize,  errnum_t e );
void*     Set4_ref_imp( Set4* self, int i, int size );
int       Set4_getCount_imp( Set4* self, int size );
void      Set4_forEach_imp2( Set4* self, Set4Iter* p, int size );


 
/**************************************************************************
  <<< [ListClass] Linked List >>> 
***************************************************************************/
typedef struct  _ListClass          ListClass;
typedef struct  _ListElementClass   ListElementClass;
typedef struct  _ListIteratorClass  ListIteratorClass;

/*[ListElementClass]*/
struct  _ListElementClass {  /* This struct can be menbers of Data */
	void*              Data;  /* Element Data */
	ListClass*         List;  /* NULL = Not in a list */
	ListElementClass*  Next;
	ListElementClass*  Previous;
};

struct  _ListClass {
	void*              Data;  /* List owner. ListClass does not set this */
	ListElementClass   Terminator;
	int                Count;
};

/*[ListIteratorClass]*/
struct  _ListIteratorClass {
	ListElementClass*  Element;
	ListElementClass   ModifiedElement;
};

       void      ListClass_initConst( ListClass* self );
inline errnum_t  ListClass_add( ListClass* self, ListElementClass* Element ); /* addFirst */
       errnum_t  ListClass_addAtIndex( ListClass* self, int Index, ListElementClass* Element );
inline errnum_t  ListClass_addFirst( ListClass* self, ListElementClass* Element );
inline errnum_t  ListClass_addLast( ListClass* self, ListElementClass* Element );
inline int       ListClass_getCount( ListClass* self );
inline errnum_t  ListClass_getData( ListClass* self, int Index, void* out_Data );
       errnum_t  ListClass_get( ListClass* self, int Index, ListElementClass** out_Element );
       errnum_t  ListClass_set( ListClass* self, int Index, ListElementClass* Element );
       errnum_t  ListClass_replace( ListClass* self, ListElementClass* RemovingElement, ListElementClass* AddingElement );
inline errnum_t  ListClass_getFirstData( ListClass* self, void* out_Data );
inline errnum_t  ListClass_getLastData( ListClass* self, void* out_Data );
inline errnum_t  ListClass_getFirst( ListClass* self, ListElementClass** out_Element );
inline errnum_t  ListClass_getLast( ListClass* self, ListElementClass** out_Element );
       int       ListClass_getIndexOfData( ListClass* self, void* Data );
       int       ListClass_getIndexOf( ListClass* self, ListElementClass* Element );
       int       ListClass_getLastIndexOfData( ListClass* self, void* Data );
       errnum_t  ListClass_getArray( ListClass* self, void* DataArray, size_t DataArraySize );
       errnum_t  ListClass_removeByIndex( ListClass* self, int Index );
       errnum_t  ListClass_remove( ListClass* self, ListElementClass* Element );
inline errnum_t  ListClass_removeFirst( ListClass* self );
inline errnum_t  ListClass_removeLast( ListClass* self );
       errnum_t  ListClass_clear( ListClass* self );
inline errnum_t  ListClass_push( ListClass* self, ListElementClass* Element );
inline void*     ListClass_popData( ListClass* self );
inline ListElementClass*  ListClass_pop( ListClass* self );
inline errnum_t  ListClass_enqueue( ListClass* self, ListElementClass* Element );
inline void*     ListClass_dequeueData( ListClass* self );
inline ListElementClass*  ListClass_dequeue( ListClass* self );
inline errnum_t  ListClass_getListIterator( ListClass* self, ListIteratorClass* out_Iterator );
inline errnum_t  ListClass_getDescendingListIterator( ListClass* self, ListIteratorClass* out_Iterator );

inline void  ListElementClass_initConst( ListElementClass* self, void* Data );

void*     ListIteratorClass_getNext( ListIteratorClass* self );
void*     ListIteratorClass_getPrevious( ListIteratorClass* self );
errnum_t  ListIteratorClass_replace( ListIteratorClass* self, ListElementClass* AddingElement );
errnum_t  ListIteratorClass_remove( ListIteratorClass* self );



/* Implements of ListClass */
errnum_t  ListClass_addAt_Sub( ListElementClass* AddingElement, ListElementClass* Target );


/*[ListClass_add]*/
inline errnum_t  ListClass_add( ListClass* self, ListElementClass* Element )
{
	return  ListClass_addFirst( self, Element );
}


/*[ListClass_addFirst]*/
inline errnum_t  ListClass_addFirst( ListClass* self, ListElementClass* Element )
{
	return  ListClass_addAt_Sub( Element, self->Terminator.Next );
}


/*[ListClass_addLast]*/
inline errnum_t  ListClass_addLast( ListClass* self, ListElementClass* Element )
{
	return  ListClass_addAt_Sub( Element, &self->Terminator );
}


/*[ListClass_getCount]*/
inline int  ListClass_getCount( ListClass* self )
{
	return  self->Count;
}


/*[ListClass_getData]*/
inline errnum_t  ListClass_getData( ListClass* self, int Index, void* out_Data )
{
	errnum_t  e;
	ListElementClass*  target;

	e= ListClass_get( self, Index, &target );
	if ( e == 0 )
		{ *(void**) out_Data = target->Data; }
	return  e;
}


/*[ListClass_getFirstData]*/
inline errnum_t  ListClass_getFirstData( ListClass* self, void* out_Data )
{
	if ( self->Count == 0 ) {
		return  E_NOT_FOUND_SYMBOL;
	}
	else {
		*(void**) out_Data = self->Terminator.Next->Data;
		return  0;
	}
}


/*[ListClass_getLastData]*/
inline errnum_t  ListClass_getLastData( ListClass* self, void* out_Data )
{
	if ( self->Count == 0 ) {
		return  E_NOT_FOUND_SYMBOL;
	}
	else {
		*(void**) out_Data = self->Terminator.Previous->Data;
		return  0;
	}
}


/*[ListClass_getFirst]*/
inline errnum_t  ListClass_getFirst( ListClass* self, ListElementClass** out_Element )
{
	if ( self->Count == 0 ) {
		return  E_NOT_FOUND_SYMBOL;
	}
	else {
		*out_Element = self->Terminator.Next;
		return  0;
	}
}


/*[ListClass_getLast]*/
inline errnum_t  ListClass_getLast( ListClass* self, ListElementClass** out_Element )
{
	if ( self->Count == 0 ) {
		return  E_NOT_FOUND_SYMBOL;
	}
	else {
		*out_Element = self->Terminator.Previous;
		return  0;
	}
}


/*[ListClass_isExistData]*/
inline bool  ListClass_isExistData( ListClass* self, void* Data )
{
	return  ( ListClass_getIndexOfData( self, Data ) != INVALID_ARRAY_INDEX );
}


/*[ListClass_removeFirst]*/
inline errnum_t  ListClass_removeFirst( ListClass* self )
{
	if ( self->Count == 0 ) {
		return  E_NOT_FOUND_SYMBOL;
	}
	else {
		return  ListClass_remove( self, self->Terminator.Next );
	}
}


/*[ListClass_removeLast]*/
inline errnum_t  ListClass_removeLast( ListClass* self )
{
	if ( self->Count == 0 ) {
		return  E_NOT_FOUND_SYMBOL;
	}
	else {
		return  ListClass_remove( self, self->Terminator.Previous );
	}
}


/*[ListClass_push]*/
inline errnum_t  ListClass_push( ListClass* self, ListElementClass* Element )
{
	return  ListClass_addFirst( self, Element );
}


/*[ListClass_popData]*/
inline void*  ListClass_popData( ListClass* self )
{
	if ( self->Count == 0 ) {
		return  NULL;
	}
	else {
		ListElementClass*  element = self->Terminator.Next;

		ListClass_remove( self, element );
		return  element->Data;
	}
}


/*[ListClass_pop]*/
inline ListElementClass*  ListClass_pop( ListClass* self )
{
	if ( self->Count == 0 ) {
		return  NULL;
	}
	else {
		ListElementClass*  element = self->Terminator.Next;

		ListClass_remove( self, element );
		return  element;
	}
}


/*[ListClass_enqueue]*/
inline errnum_t  ListClass_enqueue( ListClass* self, ListElementClass* Element )
{
	return  ListClass_addLast( self, Element );
}


/*[ListClass_dequeueData]*/
inline void*  ListClass_dequeueData( ListClass* self )
{
	return  ListClass_popData( self );
}


/*[ListClass_dequeue]*/
inline ListElementClass*  ListClass_dequeue( ListClass* self )
{
	return  ListClass_pop( self );
}


/*[ListClass_getListIterator]*/
inline errnum_t  ListClass_getListIterator( ListClass* self, ListIteratorClass* out_Iterator )
{
	out_Iterator->Element = &self->Terminator;
	out_Iterator->ModifiedElement.List = NULL;
	return  0;
}


/*[ListClass_getDescendingListIterator]*/
inline errnum_t  ListClass_getDescendingListIterator( ListClass* self, ListIteratorClass* out_Iterator )
{
	out_Iterator->Element = &self->Terminator;
	out_Iterator->ModifiedElement.List = NULL;
	return  0;
}


/*[ListElementClass_initConst]*/
inline void  ListElementClass_initConst( ListElementClass* self, void* Data )
{
	self->Data = Data;
	self->List = NULL;

	#ifndef NDEBUG
		self->Next     = NULL;
		self->Previous = NULL;
	#endif
}


 
/***********************************************************************
  <<< [ListClass_forEach] >>> 
************************************************************************/
#define  ListClass_forEach( self, iterator, out_Element ) \
	ListClass_forEach_1( self, iterator, out_Element ); \
	ListClass_forEach_2( self, iterator, out_Element ); \
	ListClass_forEach_3( self, iterator, out_Element )


inline void  ListClass_forEach_1( ListClass* self, ListIteratorClass* iterator,  void* out_Element )
{
	ListClass_getListIterator( self, iterator );
	*(void**) out_Element = ListIteratorClass_getNext( iterator );
}


inline bool  ListClass_forEach_2( ListClass* self,  ListIteratorClass* iterator,  void* out_Element )
{
	UNREFERENCED_VARIABLE_2( self, iterator );
	return  ( *(void**) out_Element != NULL );
}


inline void  ListClass_forEach_3( ListClass* self, ListIteratorClass* iterator,  void* out_Element )
{
	UNREFERENCED_VARIABLE( self );
	*(void**) out_Element = ListIteratorClass_getNext( iterator );
}


 
/**************************************************************************
  <<< [ListClass:ClassID] >>> 
***************************************************************************/
errnum_t  ListClass_finalizeWithVTable( ListClass* self, bool IsFreeElements, errnum_t e );
errnum_t  ListClass_printXML( ListClass* self, FILE* OutputStream );


 
/***********************************************************************
  <<< [Variant_SuperClass] >>>
************************************************************************/

typedef struct _VariantClass  VariantClass;

typedef struct _Variant_SuperClass  Variant_SuperClass;
struct _Variant_SuperClass {

	/* <Inherit parent="ClassID_SuperClass"> */
	const ClassID_Class*   ClassID;
	/* </Inherit> */

	FinalizerVTableClass*  FinalizerVTable;
	VariantClass*          StaticAddress;
};

extern const ClassID_Class  g_Variant_SuperClass_ID;
errnum_t  Variant_SuperClass_initialize( Variant_SuperClass* self, void* Parameter );
errnum_t  Variant_SuperClass_overwrite( Variant_SuperClass* self,
	Variant_SuperClass* AddingElement );


 
/***********************************************************************
  <<< [VariantClass] >>>
- VariantClass* == Variant_SuperClass**
************************************************************************/
typedef struct _VariantClass  VariantClass;
 
struct _VariantClass {
	Variant_SuperClass*  Object;
	ListElementClass     ListElement;
};


 
/***********************************************************************
  <<< [VariantListClass] >>>
************************************************************************/
typedef struct _VariantListIteratorClass  VariantListIteratorClass;
typedef struct _Variant_SuperClass        Variant_SuperClass;
typedef struct _VariantListIteratorClass  VariantListIteratorClass;

typedef struct _VariantListClass  VariantListClass;
struct _VariantListClass {
	ListClass /*<VariantClass>*/  List;
};

void      VariantListClass_initConst( VariantListClass* self );
/*        VariantListClass_initialize is not exist */
errnum_t  VariantListClass_finalize( VariantListClass* self, errnum_t e );

errnum_t  VariantListClass_createElement( VariantListClass* self,
	void* /*<Variant_SuperClass**>*/ out_ElementObject,
	const ClassID_Class* ClassID,  void* Parameter );

errnum_t  VariantListClass_destroyElement( VariantListClass* self,
	void* /*<Variant_SuperClass**>*/  in_out_ElementObject,  errnum_t e );

errnum_t  VariantListClass_getListIterator( VariantListClass* self,
	VariantListIteratorClass* out_Iterator );


 
/***********************************************************************
  <<< [VariantListIteratorClass] >>>
************************************************************************/
typedef struct _VariantListIteratorClass  VariantListIteratorClass;
struct _VariantListIteratorClass {
	ListIteratorClass  Iterator;
};
Variant_SuperClass*  VariantListIteratorClass_getNext( VariantListIteratorClass* self );


/*[VariantListClass_getListIterator]*/
inline errnum_t  VariantListClass_getListIterator( VariantListClass* self,
	VariantListIteratorClass* out_Iterator )
{
	return  ListClass_getListIterator( &self->List, &out_Iterator->Iterator );
}


 
/***********************************************************************
  <<< [VariantListClass_forEach] >>>
************************************************************************/
#define  VariantListClass_forEach( self, Iterator, out_Pointer ) \
	VariantListClass_forEach_Sub1( self, Iterator, out_Pointer ); \
	*(out_Pointer) != NULL; \
	VariantListClass_forEach_Sub3( Iterator, out_Pointer )

inline void  VariantListClass_forEach_Sub1( VariantListClass* self,
	VariantListIteratorClass* Iterator, void* out_Pointer )
{
	VariantListClass_getListIterator( self, Iterator );
	*(void**) out_Pointer = VariantListIteratorClass_getNext( Iterator );
}

inline void  VariantListClass_forEach_Sub3( \
	VariantListIteratorClass* Iterator, void* out_Pointer )
{
	*(void**) out_Pointer = VariantListIteratorClass_getNext( Iterator );
}


 
/***********************************************************************
  <<< [PArray] >>> 
************************************************************************/
typedef  errnum_t (* CompareFuncType )( const void* ppLeft, const void* ppRight, const void* Param,
	int* out_Result );

int  PArray_setFromArray( void* PointerArray, size_t PointerArraySize, void* out_ppRight,
	void* SrcArray, size_t SrcArraySize, size_t SrcArrayElemSize );


 
errnum_t  PArray_doShakerSort( const void* PointerArray,  size_t PointerArraySize,
	const void* ppLeft,  const void* ppRight,  CompareFuncType Compare,  const void* Param );


 
errnum_t  PArray_doBinarySearch( const void* PointerArray, size_t PointerArraySize,
	const void* Key, CompareFuncType Compare, const void* Param,
	int* out_FoundOrLeftIndex, int* out_CompareResult );


 
/***********************************************************************
  <<< [DictionaryAA_Class] Dictionary using AA tree >>> 
************************************************************************/
typedef struct _DictionaryAA_Class      DictionaryAA_Class;
typedef struct _DictionaryAA_NodeClass  DictionaryAA_NodeClass;

struct _DictionaryAA_Class {
	DictionaryAA_NodeClass*  Root;
};


/*[DictionaryAA_TraverseFuncType]*/
typedef errnum_t (* DictionaryAA_TraverseFuncType )(
	DictionaryAA_NodeClass* Node, void* UserParameter );

void      DictionaryAA_Class_initConst( DictionaryAA_Class* self );
errnum_t  DictionaryAA_Class_finalize( DictionaryAA_Class* self, errnum_t e );
errnum_t  DictionaryAA_Class_finalize2( DictionaryAA_Class* self,  errnum_t  e,
	bool  in_IsFreeItem,  FinalizeFuncType  in_Type_Finalize );
/*errnum_t  DictionaryAA_Class_freeAllKeysHeap( DictionaryAA_Class* self, errnum_t e );*/

errnum_t  DictionaryAA_Class_insert( DictionaryAA_Class* self, const TCHAR* Key,
	DictionaryAA_NodeClass** out_Node );
errnum_t  DictionaryAA_Class_remove( DictionaryAA_Class* self, const TCHAR* Key );
errnum_t  DictionaryAA_Class_search( DictionaryAA_Class* self, const TCHAR* Key,
	DictionaryAA_NodeClass** out_Node );
bool      DictionaryAA_Class_isExist( DictionaryAA_Class* self, const TCHAR* Key );
errnum_t  DictionaryAA_Class_traverse( DictionaryAA_Class* self,
	DictionaryAA_TraverseFuncType  Function,  void*  UserParameter );
errnum_t  DictionaryAA_Class_toEmpty( DictionaryAA_Class* self );
errnum_t  DictionaryAA_Class_getArray( DictionaryAA_Class* self,
	TCHAR***  in_out_Strings,  int*  in_out_StringCount,  NewStringsEnum  in_HowToAllocate );
errnum_t  DictionaryAA_Class_print( DictionaryAA_Class* self, FILE* OutputStream );


/*[DictionaryAA_Class_forEach]*/
#define  DictionaryAA_Class_forEach( in_out_Iterator, out_Node ) \
	*(out_Node) = DictionaryAA_IteratorClass_getNext( in_out_Iterator ); \
	*(out_Node) != NULL; \
	*(out_Node) = DictionaryAA_IteratorClass_getNext( in_out_Iterator )


 
/***********************************************************************
  <<< [DictionaryAA_NodeClass] >>> 
************************************************************************/
struct _DictionaryAA_NodeClass {
	void*                    Item;  /* User defined */

	const TCHAR*             Key;   /* This is had by DictionaryAA_Class */
	int                      Height;
	DictionaryAA_NodeClass*  Left;
	DictionaryAA_NodeClass*  Right;
};

extern  DictionaryAA_NodeClass  g_DictionaryAA_NullNode;


 
/***********************************************************************
  <<< [DictionaryAA_IteratorClass] >>> 
************************************************************************/
typedef struct _DictionaryAA_IteratorClass  DictionaryAA_IteratorClass;
struct _DictionaryAA_IteratorClass {
	Set2 /*<DictionaryAA_NodeClass*>*/  Nodes;
	DictionaryAA_NodeClass**            NextNode;
};

void      DictionaryAA_IteratorClass_initConst( DictionaryAA_IteratorClass* self );
errnum_t  DictionaryAA_IteratorClass_initialize( DictionaryAA_IteratorClass* self,
	DictionaryAA_Class* Collection );
errnum_t  DictionaryAA_IteratorClass_finalize( DictionaryAA_IteratorClass* self, errnum_t e );

DictionaryAA_NodeClass*  DictionaryAA_IteratorClass_getNext(
	DictionaryAA_IteratorClass* self );


/*[DictionaryAA_IteratorClass_initConst]*/
inline void  DictionaryAA_IteratorClass_initConst( DictionaryAA_IteratorClass* self )
{
	Set2_initConst( &self->Nodes );
}


/*[DictionaryAA_IteratorClass_finalize]*/
inline errnum_t  DictionaryAA_IteratorClass_finalize( DictionaryAA_IteratorClass* self, errnum_t e )
{
	return  Set2_finish( &self->Nodes, e );
}


 
/*-------------------------------------------------------------------------*/
/* <<<< ### (Set4) Class >>>> */ 
/*-------------------------------------------------------------------------*/


 
/****************************************************************
  <<< [Set4_initConst] >>> 
*****************************************************************/
#define  Set4_initConst( self ) \
	( (self)->FirstBlock = NULL )

 
/****************************************************************
  <<< [Set4_init] >>> 
*****************************************************************/
#define  Set4_init( self, type, HeapSize ) \
	Set4_init_imp( self, sizeof(type), HeapSize )


 
/****************************************************************
  <<< [Set4_finish] >>> 
*****************************************************************/
#define  Set4_finish( self, e, type, in_Type_Finalize ) \
	( (in_Type_Finalize) == NULL ?  Set4_finish2_imp2( self ), e : \
		( Set4_finish2_imp( self, e, sizeof(type), in_Type_Finalize ), Set4_finish2_imp2( self ), e ) )


 
/****************************************************************
  <<< [Set4_allocate] >>> 
*****************************************************************/
#define  Set4_allocate( self, out_ElementPointer ) \
	Set4_alloc_imp( self, out_ElementPointer, sizeof(**(out_ElementPointer)) )


 
/****************************************************************
  <<< [Set4_alloc] >>> 
*****************************************************************/
#if 0
#define  Set4_alloc( self, pp, type ) \
	Set4_alloc_imp( self, pp, sizeof(type) )
#endif


 
/****************************************************************
  <<< [Set4_free] >>> 
*****************************************************************/
#define  Set4_free( self, in_out_ElementPointer, e ) \
	Set4_free_imp( self, in_out_ElementPointer, sizeof(**(in_out_ElementPointer)), e )


 
/****************************************************************
  <<< [Set4_toEmpty] >>> 
*****************************************************************/
#define  Set4_toEmpty( self, type, type_finish ) \
	( Set4_finish2( self, type, type_finish ), \
		(self)->FirstBlock = NULL, \
		(self)->Next = (self)->CurrentBlockOver = &(self)->FirstBlock )


 
/****************************************************************
  <<< [Set4_ref] >>> 
*****************************************************************/
#define  Set4_ref( self, i, type ) \
	( (type*) Set4_ref_imp( self, i, sizeof(type) ) )


 
/****************************************************************
  <<< [Set4_getCount] >>> 
*****************************************************************/
#define Set4_getCount( self, type ) \
	 Set4_getCount_imp( self, sizeof(type) )

#if 0
#define Set4_getN( self, type ) \
	 Set4_getCount_imp( self, sizeof(type) )
#endif


 
/****************************************************************
  <<< [Set4_forEach] >>> 
*****************************************************************/
#define  Set4_forEach( self, iter, ptr ) \
	(iter)->p = NULL, Set4_forEach_imp2( self, iter, sizeof(**(ptr)) ); \
	*(void**)(ptr) = (iter)->p, (iter)->p != NULL; \
	Set4_forEach_imp2( self, iter, sizeof(**(ptr)) )

#if 0
#define  Set4_forEach( self, iter, ptr, type ) \
	(iter)->p = NULL, Set4_forEach_imp2( self, iter, sizeof(type) ); \
	*(ptr) = (type*)(iter)->p, (iter)->p != NULL; \
	Set4_forEach_imp2( self, iter, sizeof(type) )
#endif

#define  Set4_forEach_imp( self, ptr, size ) \
	(ptr)->p = NULL, Set4_forEach_imp2( self, ptr, size ); \
	(ptr)->p != NULL; \
	Set4_forEach_imp2( self, ptr, size )


 
/****************************************************************
  <<< [Set4Iter_init] >>> 
*****************************************************************/
#define  Set4Iter_init( self, Set, pptr, type ) \
	( (self)->p = NULL, Set4_forEach_imp2( Set, self, sizeof(type) ), \
		*(pptr) = (type*)((self)->p), ( (self)->p == NULL ? E_NO_NEXT : 0 ) )


 
/****************************************************************
  <<< [Set4Iter_next] >>> 
*****************************************************************/
#define  Set4Iter_next( self, Set, pptr, type ) \
	( Set4_forEach_imp2( Set, self, sizeof(type) ), \
		*(pptr) = (type*)((self)->p), ( (self)->p == NULL ? E_NO_NEXT : 0 ) )


 
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

 
/**************************************************************************
  <<< [DebugTools] >>> 
***************************************************************************/
#ifndef  NDEBUG
	#define  DEBUGTOOLS_USES  1
#else
	#define  DEBUGTOOLS_USES  0
#endif


#if  DEBUGTOOLS_USES
typedef struct _DebugTools  DebugTools;
struct _DebugTools {
	int     m_BreakID;
	int     m_DisableBreakExceptID_plus1;
	int     m_ReturnValueOnBreak_minus1;
	TCHAR*  m_BreakByFName;
};
int  Debug_setReturnValueOnBreak( int ID );
int  Debug_disableBreak( int iExceptID );
int  Debug_setBreakByFName( const TCHAR* Path );
int  Debug_onOpen( const TCHAR* Path );
#endif

 
/***********************************************************************
  <<< [HeapLogClass] >>> 
************************************************************************/
void  HeapLogClass_log( void*  in_Address,  size_t  in_Size );
int   HeapLogClass_getID( const void*  in_Address );
void  HeapLogClass_printID( const void*  in_Address );
void  HeapLogClass_addWatch( int  in_IndexNum,  int  in_AllocatedID,  ptrdiff_t  in_Offset,
	uint32_t  in_BreakValue,  bool  in_IsPrintf );
void  HeapLogClass_watch( int  in_IndexNum );
void* HeapLogClass_getWatchingAddress( int  in_IndexNum );
void  HeapLogClass_finalize(void);

enum { HeapLogClass_NotAllocatedID = -1 };


 
/**************************************************************************
 <<< [g_DebugVar] >>> 
***************************************************************************/
extern int  g_DebugVar[10];


 
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
TCHAR*  StrT_chr( const TCHAR* String, TCHAR Key );
TCHAR*  StrT_chrs( const TCHAR* s, const TCHAR* keys );
TCHAR*  StrT_rstr( const TCHAR* String, const TCHAR* SearchStart, const TCHAR* Keyword,
	void* NullConfig );
TCHAR*  StrT_chrNext( const TCHAR* in_Start, TCHAR in_KeyCharactor );
TCHAR*  StrT_skip( const TCHAR* s, const TCHAR* keys );
TCHAR*  StrT_rskip( const TCHAR* String, const TCHAR* SearchStart, const TCHAR* Keys,
	void* NullConfig );
bool    StrT_isCIdentifier( TCHAR Character );
TCHAR*  StrT_searchOverOfCIdentifier( const TCHAR* Text );
TCHAR*  StrT_searchOverOfIdiom( const TCHAR* Text );
int  StrT_cmp_part( const TCHAR* StringA_Start, const TCHAR* StringA_Over,
	const TCHAR* StringB );
int  StrT_cmp_i_part( const TCHAR* StringA_Start, const TCHAR* StringA_Over,
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


 
int  StrT_searchPartStringIndex( const TCHAR* in_String, const TCHAR* in_StringOver,
	const TCHAR** in_StringsArray,  uint_fast32_t in_StringsArrayLength,
	int in_DefaultIndex );
 
int  StrT_searchPartStringIndexI( const TCHAR* in_String, const TCHAR* in_StringOver,
	const TCHAR** in_StringsArray,  uint_fast32_t in_StringsArrayLength,
	int in_DefaultIndex );
 
errnum_t  StrT_convStrToId( const TCHAR* str, const TCHAR** strs, const int* ids, int n, int default_id ); 
errnum_t  StrT_convStrLeftToId( const TCHAR* Str, const TCHAR** Strs, const size_t* Lens, const int* Ids,
                           int CountOfStrs, TCHAR* Separeters, int DefaultId, TCHAR** out_PosOfLastOfStr );
void*  StrT_convPartStrToPointer( const TCHAR* StringStart, const TCHAR* StringOver,
	const NameOnlyClass* Table, size_t TableSize, void* Default );
TCHAR*  StrT_convertNumToStr( int Number, const NameAndNumClass* Table, int TableCount,
	const TCHAR* DefaultStr );
 
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

errnum_t  StrHS_insert( TCHAR**  in_out_WholeString,
	int  in_TargetIndexInWholeString,  int*  out_NextWholeInWholeString,
	const TCHAR*  in_InsertString );
errnum_t  StrHS_printf( TCHAR**  in_out_String,  const TCHAR*  in_Format,  ... );
errnum_t  StrHS_printfV( TCHAR**  in_out_String,  const TCHAR*  in_Format,  va_list  in_VaList );
errnum_t  StrHS_printfPart( TCHAR**  in_out_String,
	int  in_IndexInString,  int*  out_NextIndexInString,
	const TCHAR*  in_Format,  ... );
errnum_t  StrHS_printfPartV( TCHAR**  in_out_String,
	int  in_IndexInString,  int*  out_NextIndexInString,
	const TCHAR*  in_Format,  va_list  in_VaList );


 
/***********************************************************************
  <<< [StrT_Edit] >>> 
************************************************************************/
errnum_t  StrT_cutPart( TCHAR*  in_out_String,  TCHAR*  in_StartOfCut,  TCHAR*  in_OverOfCut );
errnum_t  StrT_trim( TCHAR* out_Str, size_t out_Str_Size, const TCHAR* in_Str );
errnum_t  StrT_cutLastOf( TCHAR* in_out_Str, TCHAR Charactor );
errnum_t  StrT_cutLineComment( TCHAR* out_Str, size_t out_Str_Size, const TCHAR* in_Str, const TCHAR* CommentSign );
errnum_t  StrT_insert( TCHAR*  in_out_WholeString,  size_t  in_MaxSize_of_WholeString,
	TCHAR*  in_out_Target_in_WholeString,  TCHAR**  out_NextTarget_in_WholeString,
	const TCHAR*  in_InsertString );
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
void  StrT_cutFragmentInPath( TCHAR* in_out_Path );
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
errnum_t  StrT_encodeToValidPath( TCHAR* out_Path,  size_t in_OutPathSize,  const TCHAR* in_Path,  bool  in_IsName );

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
  <<< [Strs] >>> 
***************************************************************************/
typedef  struct _Strs  Strs;
struct _Strs {
	byte_t*  MemoryAddress;   /* first memory = [ TCHAR* FirstStr | elem[] ],  other memory = [ elem[] ] */
	byte_t*  MemoryOver;
	byte_t*  NextElem;        /* elem = [ TCHAR* NextStr | TCHAR[] ] */
	TCHAR**  PointerToNextStrInPrevElem;  /* first = &FirstStr,  other = &NextStr */
	TCHAR**  Prev_PointerToNextStrInPrevElem;

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
#define  Strs_getFreeSize( m )  ( (m)->MemoryOver - (byte_t*)(m)->NextElem - sizeof(TCHAR*) )
#define  Strs_getFreeCount( m ) ( Strs_getFreeSize( m ) / sizeof(TCHAR) )
#define  Strs_expandCount( m, c )  ( Strs_expandSize( (m), (c) * sizeof(TCHAR) ) )
errnum_t  Strs_expandSize( Strs* m, size_t FreeSize );
errnum_t  Strs_commit( Strs* m, TCHAR* StrOver );
errnum_t  Strs_allocateArray( Strs* self,  TCHAR*** out_PointerArray,  int* out_Count );


 
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
  <<< [StrFile] Read Class >>> 
************************************************************************/
 
typedef struct _StrFile  StrFile;
struct _StrFile {
	void*   Buffer;
	size_t  BufferSize;
	bool    IsBufferInHeap;
	bool    IsTextMode;
	int     OffsetToHeapBlockFirst;
	int     CharSize;
	void*   Pointer;  // (void*)0xFFFFFFFF = EOF
};

#define   StrFile   StrFile_BlackBox
 
typedef struct _StrFile_BlackBox  StrFile;
struct _StrFile_BlackBox {
	uint8_t  BlackBox[24];
};
 
#undef   StrFile
static_assert_global( sizeof(StrFile) == sizeof(StrFile_BlackBox), "" );
 
enum {
	STR_FILE_READ = 0,

	STR_FILE_CHAR  = 0x00,
	STR_FILE_WCHAR = 0x10,
#ifdef _UNICODE
	STR_FILE_TCHAR = 0x10,
#else
	STR_FILE_TCHAR = 0x00,
#endif

	STR_FILE_TEXT   = 0x00,
	STR_FILE_BINARY = 0x01,
};

void      StrFile_initConst( StrFile* self );
errnum_t  StrFile_init_fromStr( StrFile* self, TCHAR* LinkStr );
errnum_t  StrFile_init_fromSizedStructInStream( StrFile* self, HANDLE* Stream );
errnum_t  StrFile_init_withBuf( StrFile* self, void* LinkBuffer, size_t LinkBufferSize, int Flags );
errnum_t  StrFile_finish( StrFile* self, errnum_t e );
errnum_t  StrFile_isInited( StrFile* self );

errnum_t  StrFile_readLine( StrFile* self, TCHAR* out_Line, size_t LineSize );
bool      StrFile_isAtEndOfStream( StrFile* self );


 
/***********************************************************************
  <<< [StrFile] Write Class >>> 
************************************************************************/

errnum_t  StrFile_init_toHeap( StrFile* self, int Flags );
errnum_t  StrFile_write( StrFile* self, const TCHAR* Text );
errnum_t  StrFile_writeBinary( StrFile* self, const void* Data, size_t DataSize );
errnum_t  StrFile_expandIfOver( StrFile* self, size_t DataSize );
errnum_t  StrFile_peekWrittenString( StrFile* self, TCHAR** out_String );
errnum_t  StrFile_peekWrittenStringW( StrFile* self, wchar_t** out_String );
errnum_t  StrFile_peekWrittenStringA( StrFile* self, char** out_String );
errnum_t  StrFile_pickupSizedStruct( StrFile* m, SizedStruct** out_Struct );
errnum_t  StrFile_moveSizedStructToStream( StrFile* self, HANDLE Stream );
errnum_t  StrFile_setPointer( StrFile* self, int OffsetOfPointer );
errnum_t  StrFile_getPointer( StrFile* self, int* out_OffsetOfPointer );


#ifdef _UNICODE
#define  StrFile_peekWrittenString  StrFile_peekWrittenStringW
#else
#define  StrFile_peekWrittenString  StrFile_peekWrittenStringA
#endif


 
/***********************************************************************
  <<< [SearchStringByBM_Class] >>> 
************************************************************************/
typedef struct _SearchStringByBM_Class  SearchStringByBM_Class;
struct _SearchStringByBM_Class {
	const TCHAR*  TextString;
	int           TextStringLength;
	const TCHAR*  Keyword;
	int           KeywordLastIndex;
	int           KeywordLastPosition;  /* Index of TextString */
	int*          SkipArray;
	TCHAR         SkipArray_MinCharacter;
	TCHAR         SkipArray_MaxCharacter;
};

void      SearchStringByBM_Class_initConst( SearchStringByBM_Class* self );
errnum_t  SearchStringByBM_Class_initialize( SearchStringByBM_Class* self,
	const TCHAR* TextString,  const TCHAR* Keyword );
errnum_t  SearchStringByBM_Class_initializeFromPart( SearchStringByBM_Class* self,
	const TCHAR* TextString,  size_t TextString_Length,  const TCHAR* Keyword );
errnum_t  SearchStringByBM_Class_finalize( SearchStringByBM_Class* self, errnum_t e );
errnum_t  SearchStringByBM_Class_search( SearchStringByBM_Class* self, int* out_KeywordIndex );


enum { SearchString_NotFound = -1 };  /*[SearchString_NotFound]*/


 
/***********************************************************************
  <<< [SearchStringByAC_Class] >>> 
************************************************************************/
enum { SearchStringByAC_Fail = 0 };                   /*[SearchStringByAC_Fail]*/
enum { SearchStringByAC_RootState = 0 };              /*[SearchStringByAC_RootState]*/
#if 0
enum { SearchStringByAC_MaxCharacterCode = 0xFFFF };  /*[SearchStringByAC_MaxCharacterCode]*/
#else
enum { SearchStringByAC_MaxCharacterCode = 0xFF };  /*[SearchStringByAC_MaxCharacterCode]*/
#endif
typedef int16_t (* AC_GotoFunctionType )[ SearchStringByAC_MaxCharacterCode + 1 ];
	/* Array of next_state[state][character] */

typedef struct _SearchStringByAC_Class  SearchStringByAC_Class;
struct _SearchStringByAC_Class {
	int            StateNum;
	const TCHAR*   TextString;
	unsigned       TextStringLength;
	int            TextStringIndex;
	const TCHAR**  FoundKeywords;
	int            FoundKeywordsCount;
	int            FoundKeywordIndex;

	Set2            GoToFunction;  /* <AC_GotoFunctionType> Next state[ state ][ character ] */
	int*            FailureFunction;    /* Next state[ state ] */
	const TCHAR***  OutputFunction;     /* TCHAR*  OutputFunction.Keyword[ state ][ count ] */
	int*            OutputCount;        /* int     OutputFunction.Count[ state ] */
	int16_t         StateCount;         /* newstate + 1 */
};

void      SearchStringByAC_Class_initConst( SearchStringByAC_Class* self );
errnum_t  SearchStringByAC_Class_initialize( SearchStringByAC_Class* self,
	const TCHAR* TextString, const TCHAR** KeywordArray, size_t KeywordArrayCount );
errnum_t  SearchStringByAC_Class_initializeFromPart( SearchStringByAC_Class* self,
	const TCHAR* TextString,  size_t TextString_Length,
	const TCHAR** KeywordArray,  size_t KeywordArrayCount );
errnum_t  SearchStringByAC_Class_finalize( SearchStringByAC_Class* self, errnum_t e );
errnum_t  SearchStringByAC_Class_search( SearchStringByAC_Class* self,
	int* out_TextStringIndex, TCHAR** out_Keyword );
errnum_t  SearchStringByAC_Class_setTextString( SearchStringByAC_Class* self,
	const TCHAR* TextString );
errnum_t  SearchStringByAC_Class_setTextStringFromPart( SearchStringByAC_Class* self,
	const TCHAR* TextString,  size_t TextString_Length );
inline  const TCHAR*  SearchStringByAC_Class_getTextString( SearchStringByAC_Class* self )
	{ return  self->TextString; }


 
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


 
/**************************************************************************
 <<< [Interface] >>> 
***************************************************************************/
typedef struct _VTableDefine  VTableDefine;  /*[VTableDefine]*/
struct _VTableDefine {
  int    m_IMethod;
  void*  m_method;
};

#define  VTable_Obj( i )  ( (void*) ( (char*)(i) - (*(i))->m_Offset ) )  /*[VTable_Obj]*/
#define  VTable_Method( i, m_method )  (*(i))->m_method  /*[VTable_Method]*/

#ifdef  __cplusplus
extern "C" {
#endif

errnum_t  DefaultFunction( void* a );
errnum_t  DefaultFunction_NotImplementYet( void* a );
//errnum_t  DefaultFunction_Finish( void* a, errnum_t e );
errnum_t  DefaultFunction_Finalize( void* a, errnum_t e );

errnum_t  VTableDefine_overwrite( VTableDefine* aVTable, size_t aVTable_ByteSize, int iMethod, void* Func );

#ifdef  __cplusplus
}
#endif


 
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

#ifndef  NDEBUG
	#define  ERR2_ENABLE_ERROR_LOG  1
#else
	#define  ERR2_ENABLE_ERROR_LOG  0
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
void  Error4_showToStdIO( FILE* out, int err_num );
void  Error4_showToPrintf( int err_num );


 
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
/* <<< [Expat/Expat_incude.h] >>> */ 
/*=================================================================*/
 
#ifndef  __EXPAT_H
#define  __EXPAT_H

#define  XML_STATIC   /* [SETTING] define or not define. if not define, deploy libexpat(w).dll */


// reference: README.txt : * Special note about MS VC++ and runtime libraries
#if _UNICODE
  #define  XML_UNICODE_WCHAR_T
  #if defined(XML_STATIC)
    #if _MT
      #if _DLL  // Visual C++ /MD option, MSVCP**.DLL
        #pragma comment(lib, "libexpatwMD.lib")  // not supplied
      #else  // Visual C++ /MT option

        #pragma comment(lib, "libexpatwMT.lib")

        #ifndef NDEBUG
          #pragma comment(linker,"/NODEFAULTLIB:LIBCMT" )
        #endif
      #endif
    #else
      #pragma comment(lib, "libexpatwML.lib")   // not supplied
    #endif
  #else  // DLL version

    #pragma comment(lib, "libexpatw.lib")  // libexpatw.dll, including multi thread static runtime library

  #endif
#else
  #if defined(XML_STATIC)
    #if _MT
      #if _DLL  // Visual C++ /MD option, MSVCP**.DLL
        #pragma comment(lib, "libexpatMD.lib")  // not supplied
      #else  // Visual C++ /MT option

        #pragma comment(lib, "libexpatMT.lib")

        #ifndef NDEBUG
          # pragma comment(linker,"/NODEFAULTLIB:LIBCMT" )
        #endif
      #endif
    #else
      #pragma comment(lib, "libexpatML.lib")   // not supplied
    #endif
  #else  // DLL version

    #pragma comment(lib, "libexpat.lib")  // libexpat.dll, including multi thread static runtime library

  #endif
#endif

#include  <expat.h> 


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


 
errnum_t  FileT_readAll( FILE* File, TCHAR** out_Text, size_t* out_TextLength );


 
/***********************************************************************
  <<< [FileT_Write] >>> 
************************************************************************/
int  FileT_openForWrite( FILE** out_pFile, const TCHAR* Path,  bit_flags_fast32_t  Flags );

enum { F_Unicode = 1,  F_Append = 2 };

int  FileT_copy( const TCHAR* SrcPath, const TCHAR* DstPath );
int  FileT_mkdir( const TCHAR* Path );
int  FileT_del( const TCHAR* Path );
int  FileT_writePart( FILE* File, const TCHAR* Start, TCHAR* Over );


 
/***********************************************************************
  <<< [FileT_WinAPI] >>> 
************************************************************************/
int  FileT_readSizedStruct_WinAPI( HANDLE* Stream, void** out_SizedStruct );
int  FileT_writeSizedStruct_WinAPI( HANDLE* Stream, SizedStruct* OutputSizedStruct );


 
/***********************************************************************
  <<< [FileFormatEnum] >>> 
************************************************************************/
typedef enum {
	FILE_FORMAT_NOT_EXIST = 0,  /* File does not exist */
	FILE_FORMAT_NO_BOM    = 1,
	FILE_FORMAT_UNICODE   = 2,
	FILE_FORMAT_UTF_8     = 3,
} FileFormatEnum;


 
/***********************************************************************
* Function: FileT_readUnicodeFileBOM
************************************************************************/
errnum_t  FileT_readUnicodeFileBOM( const TCHAR* Path, FileFormatEnum* out_Format );


 
/***********************************************************************
* Function: FileT_cutFFFE
************************************************************************/
errnum_t  FileT_cutFFFE( const TCHAR* in_InputPath,  const TCHAR*  in_OutputPath,  bool  in_IsAppend );


 
/***********************************************************************
  <<< [ParseXML2] >>>
************************************************************************/
typedef struct _ParseXML2_ConfigClass  ParseXML2_ConfigClass;
typedef struct _ParseXML2_StatusClass  ParseXML2_StatusClass;
typedef errnum_t  (* ParseXML2_CallbackType )( ParseXML2_StatusClass* Status );

struct _ParseXML2_ConfigClass {
	BitField                Flags;   /* F_ParseXML2_Delegate | F_ParseXML2_OnStartElement ... */
	void*                   Delegate;       /* Flags|= F_ParseXML2_Delegate,       if enabled */
	ParseXML2_CallbackType  OnStartElement; /* Flags|= F_ParseXML2_OnStartElement, if enabled */
	ParseXML2_CallbackType  OnEndElement;   /* Flags|= F_ParseXML2_OnEndElement,   if enabled */
	ParseXML2_CallbackType  OnText;         /* Flags|= F_ParseXML2_OnText,         if enabled */
};
enum {
	F_ParseXML2_Delegate       = 0x0001,
	F_ParseXML2_OnStartElement = 0x0004,
	F_ParseXML2_OnEndElement   = 0x0008,
	F_ParseXML2_OnText         = 0x0010,
};

struct _ParseXML2_StatusClass {
	void*   Delegate;
	int     LineNum;
	int     Depth;                 /* Root XML element is 0 */
	int     PreviousCallbackType;  /* e.g.) F_ParseXML2_OnStartElement. Initial value is 0 */

	TCHAR*  XPath;
	TCHAR*  TagName;
	union {
		struct {
			const XML_Char**  Attributes;  /* for ParseXML2_StatusClass_getAttribute */
		} OnStartElement;

		struct {  /* for ParseXML2_StatusClass_mallocCopyText */
			const TCHAR*  Text;  /* not NULL terminated */
			int           TextLength;
		} OnText;
	} u;
};

errnum_t  ParseXML2( const TCHAR* XML_Path, ParseXML2_ConfigClass* in_out_Config );
errnum_t  ParseXML2_StatusClass_getAttribute( ParseXML2_StatusClass* self,
	const TCHAR* AttributeName, TCHAR** out_AttribyteValue );
errnum_t  ParseXML2_StatusClass_mallocCopyText( ParseXML2_StatusClass* self,
	TCHAR** out_Text );

enum { E_XML_PARSER = 0x3101 };


 
/***********************************************************************
  <<< [Writables] >>> 
************************************************************************/
#ifndef  Uses_AppKey
#define  Uses_AppKey  1
#endif

typedef void*  AppKey;
typedef struct _Writables  Writables;

errnum_t  AppKey_newWritable( AppKey** in_out_m,  Writables** out_Writable,  ... );
errnum_t  AppKey_newWritable_byArray( AppKey** in_out_m,  Writables** out_Writable,
	TCHAR**  in_Paths,  int  in_PathCount );
void      AppKey_initGlobal_const(void);
errnum_t  AppKey_finishGlobal( errnum_t e );
errnum_t  AppKey_addNewWritableFolder( const TCHAR* Path );
errnum_t  AppKey_addWritableFolder( AppKey* m, const TCHAR* Path );
errnum_t  AppKey_checkWritable( const TCHAR* Path );


struct _Writables {
	TCHAR**   m_Paths;  // array of array of TCHAR
	int       m_nPath;  // -1= not inited
};

errnum_t   Writables_delete( Writables* m, errnum_t e );

errnum_t   Writables_add( Writables* m, AppKey* Key, const TCHAR* Path );
errnum_t   Writables_remove( Writables* m, const TCHAR* Path );

errnum_t   Writables_enable( Writables* m );
errnum_t   Writables_disable( Writables* m, errnum_t e );

extern  Writables  g_CurrentWritables;


 
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


 
/***********************************************************************
  <<< [FileTime] >>> 
************************************************************************/

#define  FILETIME_addDays( pAnsTime, pBaseTime, plus ) \
  ( *(ULONGLONG*)(pAnsTime) = *(ULONGLONG*)(pBaseTime) \
          + (plus) * ((LONGLONG)(24*60*60)*(1000*1000*10)) )

#define  FILETIME_addHours( pAnsTime, pBaseTime, plus ) \
  ( *(ULONGLONG*)(pAnsTime) = *(ULONGLONG*)(pBaseTime) \
          + (plus) * ((LONGLONG)(60*60)*(1000*1000*10)) )

#define  FILETIME_addMinutes( pAnsTime, pBaseTime, plus ) \
  ( *(ULONGLONG*)(pAnsTime) = *(ULONGLONG*)(pBaseTime) \
          + (plus) * ((LONGLONG)(60)*(1000*1000*10)) )

#define  FILETIME_addSeconds( pAnsTime, pBaseTime, plus ) \
  ( *(ULONGLONG*)(pAnsTime) = *(ULONGLONG*)(pBaseTime) \
          + (plus) * ((LONGLONG)(1000*1000*10)) )

#define  FILETIME_sub( pLeftTime, pRightTime ) \
  ( *(ULONGLONG*)(pLeftTime) - *(ULONGLONG*)(pRightTime) )


 
#if  __cplusplus
 }  /* End of C Symbol */ 
#endif


 
/*=================================================================*/
/* <<< [Parse2/Parse2.h] >>> */ 
/*=================================================================*/
 
/***********************************************************************
  <<< [E_CATEGORY_PARSER2] >>> 
************************************************************************/
#ifndef  E_CATEGORY_PARSER2  /* If not duplicated */
	#define  E_CATEGORY_PARSER2  E_CATEGORY_PARSER2
	enum { E_CATEGORY_PARSER2 = 0x00000600 };
#endif

enum { E_NOT_FOUND_PARTNER_BRACKET = E_CATEGORY_PARSER2 | 0x01 };  /*[E_NOT_FOUND_PARTNER_BRACKET]*/


 
/***********************************************************************
  <<< [ParsedRangeClass] >>> 
************************************************************************/
typedef struct _ParsedRangeClass  ParsedRangeClass;
struct _ParsedRangeClass {

	/* <Inherit parent="Variant_SuperClass"> */
	const ClassID_Class*   ClassID;
	FinalizerVTableClass*  FinalizerVTable;
	VariantClass*          StaticAddress;
	/* </Inherit> */

	const TCHAR*  Start;
	const TCHAR*  Over;
};
extern const ClassID_Class  g_ParsedRangeClass_ID;

void  ParsedRangeClass_initConst( ParsedRangeClass* self );

int  ParsedRanges_compareByStart( const void* _a1, const void* _a2 );

#ifndef NDEBUG
void  ParsedRangeClass_onInitializedForDebug( ParsedRangeClass* self );
#else
inline void  ParsedRangeClass_onInitializedForDebug( ParsedRangeClass* self )
{
	UNREFERENCED_VARIABLE( self );
}
#endif


 
errnum_t  ParsedRanges_write_by_Cut(
	Set2* /*<ParsedRangeClass>*/ CutRanges,
	const TCHAR* Text, FILE* OutFile );


 
/***********************************************************************
  <<< [LineNumberIndexClass] >>> 
************************************************************************/
typedef struct _LineNumberIndexClass  LineNumberIndexClass;
struct _LineNumberIndexClass {
	Set2  /*<const TCHAR*>*/  LeftsOfLine;
};

void      LineNumberIndexClass_initConst( LineNumberIndexClass* self );
errnum_t  LineNumberIndexClass_initialize( LineNumberIndexClass* self, const TCHAR* Text );
errnum_t  LineNumberIndexClass_finalize( LineNumberIndexClass* self, errnum_t e );
errnum_t  LineNumberIndexClass_searchLineNumber( LineNumberIndexClass* self, const TCHAR* Position,
	int* out_LineNumber );
int  LineNumberIndexClass_getCountOfLines( LineNumberIndexClass* self );


 
/***********************************************************************
  <<< [SyntaxSubNodeClass] >>> 
************************************************************************/
typedef struct _SyntaxSubNodeClass_IDClass  SyntaxSubNodeClass_IDClass;
typedef struct _SyntaxNodeClass             SyntaxNodeClass;


typedef struct _SyntaxSubNodeClass  SyntaxSubNodeClass;
struct _SyntaxSubNodeClass {

	/* <Inherit parent="ParsedRangeClass"> */
	const ClassID_Class*         ClassID;
	const FinalizerVTableClass*  FinalizerVTable;
	const TCHAR*                 Start;
	const TCHAR*                 Over;
	/* </Inherit> */

	const PrintXML_VTableClass*  PrintXML_VTable;
	SyntaxNodeClass*             Parent;
	ListElementClass             SubNodeListElement;  /* for ".Parent" */
};

extern const ClassID_Class  g_SyntaxSubNodeClass_ID;
errnum_t  SyntaxSubNodeClass_printXML( SyntaxSubNodeClass* self, FILE* OutputStream );


 
/***********************************************************************
  <<< [SyntaxNodeClass] >>> 
************************************************************************/
typedef struct _SyntaxNodeClass_IDClass  SyntaxNodeClass_IDClass;

typedef struct _SyntaxNodeClass  SyntaxNodeClass;
struct _SyntaxNodeClass {

	/* <Inherit parent="SyntaxSubNodeClass"> */
	const ClassID_Class*         ClassID;
	const FinalizerVTableClass*  FinalizerVTable;
	const TCHAR*                 Start;
	const TCHAR*                 Over;
	const PrintXML_VTableClass*  PrintXML_VTable;
	SyntaxNodeClass*             Parent;
	ListElementClass             SubNodeListElement;  /* for ".Parent" */
	/* </Inherit> */

	ListClass                    SubNodeList;
	ListElementClass             ListElement;  /* Next and previous in source file */
};

errnum_t  Delete_SyntaxNodeList( ListClass* /*<SyntaxNodeClass*>*/ NodeList, errnum_t e );

extern const ClassID_Class  g_SyntaxNodeClass_ID;
void      SyntaxNodeClass_initConst( SyntaxNodeClass* self );
errnum_t  SyntaxNodeClass_printXML( SyntaxNodeClass* self, FILE* OutputStream );
errnum_t  SyntaxNodeClass_addSubNode( SyntaxNodeClass* self, SyntaxSubNodeClass* SubNode );


 
/***********************************************************************
  <<< [PP_DirectiveClass] >>> 
************************************************************************/

typedef struct _PP_DirectiveClass  PP_DirectiveClass;
typedef struct _PP_SharpIfClass  PP_SharpIfClass;
typedef struct _PP_SharpElseClass  PP_SharpElseClass;
typedef struct _PP_SharpEndifClass  PP_SharpEndifClass;
typedef struct _PP_SharpIfdefClass  PP_SharpIfdefClass;
typedef struct _PP_SharpIfndefClass  PP_SharpIfndefClass;


typedef struct _PP_DirectiveClass  PP_DirectiveClass;
struct _PP_DirectiveClass {

	/* <Inherit parent="ParsedRangeClass"> */
	const ClassID_Class*   ClassID;
	FinalizerVTableClass*  FinalizerVTable;
	VariantClass*          StaticAddress;
	const TCHAR*           Start;  /* Left of a line having the direvtive */
	const TCHAR*           Over;
	/* </Inherit> */

	const TCHAR*  DirectiveName_Start;
	const TCHAR*  DirectiveName_Over;
};
extern const ClassID_Class  g_PP_DirectiveClass_ID;


errnum_t  Parse_PP_Directive( const TCHAR* Text,
	Set2* /*<PP_DirectiveClass*>*/ DirectivePointerArray );
errnum_t  Delete_PP_Directive( Set2* DirectivePointerArray, errnum_t e );


void  PP_DirectiveClass_initConst( PP_DirectiveClass* self );


 
errnum_t  ParsedRanges_getCut_by_PP_Directive(
	Set2* /*<ParsedRangeClass>*/    CutRanges,
	Set2* /*<PP_DirectiveClass*>*/  DirectivePointerArray,
	const TCHAR* Symbol,  bool IsCutDefine );


 
errnum_t  CutPreprocessorDirectives_from_C_LanguageToken(
	ListClass* /*<C_LanguageTokenClass*>*/ TokenList,
	Set2* /*<PP_DirectiveClass*>*/ Directives );


 
/***********************************************************************
  <<< [PP_SharpDefineClass] >>> 
************************************************************************/
typedef struct _PP_SharpDefineClass_IDClass  PP_SharpDefineClass_IDClass;

typedef struct _PP_SharpDefineClass  PP_SharpDefineClass;
struct _PP_SharpDefineClass {

	/* <Inherit parent="PP_DirectiveClass"> */
	const ClassID_Class*   ClassID;
	FinalizerVTableClass*  FinalizerVTable;
	VariantClass*          StaticAddress;
	const TCHAR*           Start;
	const TCHAR*           Over;
	const TCHAR*           DirectiveName_Start;
	const TCHAR*           DirectiveName_Over;
	/* </Inherit> */

	const TCHAR*  Symbol_Start;
	const TCHAR*  Symbol_Over;
};

extern const ClassID_Class  g_PP_SharpDefineClass_ID;


 
/***********************************************************************
  <<< [PP_SharpIncludeClass] >>> 
************************************************************************/
typedef struct _PP_SharpIncludeClass_IDClass  PP_SharpIncludeClass_IDClass;

typedef struct _PP_SharpIncludeClass  PP_SharpIncludeClass;
struct _PP_SharpIncludeClass {

	/* <Inherit parent="PP_DirectiveClass"> */
	const ClassID_Class*   ClassID;
	FinalizerVTableClass*  FinalizerVTable;
	VariantClass*          StaticAddress;
	const TCHAR*           Start;
	const TCHAR*           Over;
	const TCHAR*           DirectiveName_Start;
	const TCHAR*           DirectiveName_Over;
	/* </Inherit> */

	const TCHAR*  Path_Start;
	const TCHAR*  Path_Over;
	TCHAR         PathBracket;  /* _T('<') or _T('"') */
};

extern const ClassID_Class  g_PP_SharpIncludeClass_ID;


 
/***********************************************************************
  <<< [PP_SharpIfClass] >>> 
************************************************************************/
typedef struct _PP_SharpIfClass_IDClass  PP_SharpIfClass_IDClass;

typedef struct _PP_SharpIfClass  PP_SharpIfClass;
struct _PP_SharpIfClass {

	/* <Inherit parent="PP_DirectiveClass"> */
	const ClassID_Class*   ClassID;
	FinalizerVTableClass*  FinalizerVTable;
	VariantClass*          StaticAddress;
	const TCHAR*           Start;
	const TCHAR*           Over;
	const TCHAR*           DirectiveName_Start;
	const TCHAR*           DirectiveName_Over;
	/* </Inherit> */

	PP_DirectiveClass*   NextDirective;
	PP_SharpEndifClass*  EndDirective;
};

extern const ClassID_Class  g_PP_SharpIfClass_ID;


 
/***********************************************************************
  <<< [PP_SharpElseClass] >>> 
************************************************************************/
typedef struct _PP_SharpElseClass  PP_SharpElseClass;
struct _PP_SharpElseClass {

	/* <Inherit parent="PP_DirectiveClass"> */
	const ClassID_Class*   ClassID;
	FinalizerVTableClass*  FinalizerVTable;
	VariantClass*          StaticAddress;
	const TCHAR*           Start;
	const TCHAR*           Over;
	const TCHAR*           DirectiveName_Start;
	const TCHAR*           DirectiveName_Over;
	/* </Inherit> */

	PP_SharpIfClass*     StartDirective;
	PP_SharpEndifClass*  EndDirective;
};
extern const ClassID_Class  g_PP_SharpElseClass_ID;


 
/***********************************************************************
  <<< [PP_SharpEndifClass] >>> 
************************************************************************/
typedef struct _PP_SharpEndifClass  PP_SharpEndifClass;
struct _PP_SharpEndifClass {

	/* <Inherit parent="PP_DirectiveClass"> */
	const ClassID_Class*   ClassID;
	FinalizerVTableClass*  FinalizerVTable;
	VariantClass*          StaticAddress;
	const TCHAR*           Start;
	const TCHAR*           Over;
	const TCHAR*           DirectiveName_Start;
	const TCHAR*           DirectiveName_Over;
	/* </Inherit> */

	PP_SharpIfClass*    StartDirective;
	PP_DirectiveClass*  PreviousDirective;
};
extern const ClassID_Class  g_PP_SharpEndifClass_ID;


 
/***********************************************************************
  <<< [PP_SharpIfdefClass] >>> 
************************************************************************/
typedef struct _PP_SharpIfdefClass  PP_SharpIfdefClass;
struct _PP_SharpIfdefClass {

	/* <Inherit parent="PP_SharpIfClass"> */
	const ClassID_Class*   ClassID;
	FinalizerVTableClass*  FinalizerVTable;
	VariantClass*          StaticAddress;
	const TCHAR*           Start;
	const TCHAR*           Over;
	const TCHAR*           DirectiveName_Start;
	const TCHAR*           DirectiveName_Over;
	PP_DirectiveClass*     NextDirective;
	PP_SharpEndifClass*    EndDirective;
	/* </Inherit> */

	const TCHAR*  Symbol_Start;
	const TCHAR*  Symbol_Over;
};
extern const ClassID_Class  g_PP_SharpIfdefClass_ID;


 
/***********************************************************************
  <<< [PP_SharpIfndefClass] >>> 
************************************************************************/
typedef struct _PP_SharpIfndefClass  PP_SharpIfndefClass;
struct _PP_SharpIfndefClass {

	/* <Inherit parent="PP_SharpIfdefClass"> */
	const ClassID_Class*   ClassID;
	FinalizerVTableClass*  FinalizerVTable;
	VariantClass*          StaticAddress;
	const TCHAR*           Start;
	const TCHAR*           Over;
	const TCHAR*           DirectiveName_Start;
	const TCHAR*           DirectiveName_Over;
	PP_DirectiveClass*     NextDirective;
	PP_SharpEndifClass*    EndDirective;
	const TCHAR*           Symbol_Start;
	const TCHAR*           Symbol_Over;
	/* </Inherit> */
};
extern const ClassID_Class  g_PP_SharpIfndefClass_ID;


 
/***********************************************************************
  <<< [C_LanguageTokenEnum] >>> 
************************************************************************/
typedef enum _C_LanguageTokenEnum  C_LanguageTokenEnum;
enum _C_LanguageTokenEnum {
	gc_TokenOfOther       = 0,
	gc_TokenOfNumber      = 0xA1,
	gc_TokenOfCIdentifier = 0xA2,
	gc_TokenOfString      = 0xA3,
	gc_TokenOfChar        = 0xA4,

	gc_TokenOf_28         = '(',
	gc_TokenOf_29         = ')',
	gc_TokenOf_7B         = '{',
	gc_TokenOf_7D         = '}',
	gc_TokenOf_5B         = '[',
	gc_TokenOf_5D         = ']',
	gc_TokenOf_3A         = ':',
	gc_TokenOf_3B         = ';',
	gc_TokenOf_2A         = '*',
	gc_TokenOf_0A         = '\n',
	gc_TokenOf_3D         = '=',
	gc_TokenOf_2E         = '.',
	gc_TokenOf_26         = '&',
	gc_TokenOf_2B         = '+',
	gc_TokenOf_2D         = '-',
	gc_TokenOf_7E         = '~',
	gc_TokenOf_21         = '!',
	gc_TokenOf_2F         = '/',
	gc_TokenOf_25         = '%',
	gc_TokenOf_3E         = '>',
	gc_TokenOf_3C         = '<',
	gc_TokenOf_5E         = '^',
	gc_TokenOf_7C         = '|',
	gc_TokenOf_3F         = '?',
	gc_TokenOf_2C         = ',',
	gc_TokenOf_2A2F       = TwoChar8( '/', '*' ),
	gc_TokenOf_2F2A       = TwoChar8( '*', '/' ),
	gc_TokenOf_2F2F       = TwoChar8( '/', '/' ),
	gc_TokenOf_3E2D       = TwoChar8( '-', '>' ),
	gc_TokenOf_2B2B       = TwoChar8( '+', '+' ),
	gc_TokenOf_2D2D       = TwoChar8( '-', '-' ),
	gc_TokenOf_3C3C       = TwoChar8( '<', '<' ),
	gc_TokenOf_3E3E       = TwoChar8( '>', '>' ),
	gc_TokenOf_3D3E       = TwoChar8( '>', '=' ),
	gc_TokenOf_3D3C       = TwoChar8( '<', '=' ),
	gc_TokenOf_3D3D       = TwoChar8( '=', '=' ),
	gc_TokenOf_3D21       = TwoChar8( '!', '=' ),
	gc_TokenOf_2626       = TwoChar8( '&', '&' ),
	gc_TokenOf_7C7C       = TwoChar8( '|', '|' ),
	gc_TokenOf_3D2B       = TwoChar8( '+', '=' ),
	gc_TokenOf_3D2D       = TwoChar8( '-', '=' ),
	gc_TokenOf_3D2A       = TwoChar8( '*', '=' ),
	gc_TokenOf_3D2F       = TwoChar8( '/', '=' ),
	gc_TokenOf_3D25       = TwoChar8( '%', '=' ),
	/* <<= */
	/* >>= */
	gc_TokenOf_3D26       = TwoChar8( '&', '=' ),
	gc_TokenOf_3D7C       = TwoChar8( '|', '=' ),
	gc_TokenOf_3D5E       = TwoChar8( '^', '=' ),
};

TCHAR*  C_LanguageTokenEnum_convertToStr( C_LanguageTokenEnum Value );


 
/***********************************************************************
  <<< [C_LanguageTokenClass] >>> 
************************************************************************/
typedef struct _C_LanguageTokenClass_IDClass  C_LanguageTokenClass_IDClass;

typedef struct _C_LanguageTokenClass  C_LanguageTokenClass;
struct _C_LanguageTokenClass {

	/* <Inherit parent="SyntaxSubNodeClass"> */
	const ClassID_Class*         ClassID;
	const FinalizerVTableClass*  FinalizerVTable;
	const TCHAR*                 Start;
	const TCHAR*                 Over;
	const PrintXML_VTableClass*  PrintXML_VTable;
	SyntaxNodeClass*             Parent;
	ListElementClass             SubNodeListElement;  /* for ".Parent" */
	/* </Inherit> */

	C_LanguageTokenEnum          TokenType;
	ListElementClass             ListElement;  /* Next and previous in source file */
	SyntaxNodeClass*             ParentBlock;
};

extern const ClassID_Class  g_C_LanguageTokenClass_ID;
void      C_LanguageTokenClass_initConst( C_LanguageTokenClass* self );
errnum_t  C_LanguageTokenClass_printXML( C_LanguageTokenClass* self, FILE* OutputStream );


 
/***********************************************************************
  <<< [NaturalDocsDefinitionClass] >>> 
************************************************************************/
typedef struct _NaturalDocsDefinitionClass  NaturalDocsDefinitionClass;
struct _NaturalDocsDefinitionClass {
	const TCHAR*  Name;  /* Has */
	const TCHAR*  NameStart;
	const TCHAR*  NameOver;

	const TCHAR*  Brief;  /* Has */
	const TCHAR*  BriefStart;
	const TCHAR*  BriefOver;
};

void      NaturalDocsDefinitionClass_initConst( NaturalDocsDefinitionClass* self );
errnum_t  NaturalDocsDefinitionClass_finalize( NaturalDocsDefinitionClass* self,  errnum_t e );


 
/***********************************************************************
  <<< [NaturalDocsDescriptionTypeEnum] >>> 
************************************************************************/
typedef enum _NaturalDocsDescriptionTypeEnum  NaturalDocsDescriptionTypeEnum;
enum _NaturalDocsDescriptionTypeEnum {
	NaturalDocsDescriptionType_Unknown,
	NaturalDocsDescriptionType_SubTitle,
	NaturalDocsDescriptionType_Paragraph,
	NaturalDocsDescriptionType_Code,
	NaturalDocsDescriptionType_DefinitionList,

	NaturalDocsDescriptionType_Count
};

const TCHAR*  NaturalDocsDescriptionTypeEnum_to_String( int in,  const TCHAR* in_OutOfRange );


 
/***********************************************************************
  <<< [NaturalDocsDescriptionClass] >>> 
************************************************************************/
typedef struct _NaturalDocsDescriptionClass  NaturalDocsDescriptionClass;
struct _NaturalDocsDescriptionClass {
	NaturalDocsDescriptionTypeEnum  Type;

	const TCHAR*  Start;
	const TCHAR*  Over;

	union {
		void*                        Unknown;
		NaturalDocsDefinitionClass*  Definition;
	} u;
};

void      NaturalDocsDescriptionClass_initConst( NaturalDocsDescriptionClass* self );
errnum_t  NaturalDocsDescriptionClass_finalize( NaturalDocsDescriptionClass* self,  errnum_t e );


 
/***********************************************************************
  <<< [NaturalDocsParserConfigClass] >>> 
************************************************************************/
typedef struct _NaturalDocsParserConfigClass  NaturalDocsParserConfigClass;
struct _NaturalDocsParserConfigClass {
	bit_flags_fast32_t  Flags;  /*<NaturalDocsParserConfigEnum>*/
	TCHAR**             AdditionalKeywords;
	int                 AdditionalKeywordsLength;
	int                 AdditionalKeywordsEndsScopesFirstIndex;
	int                 AdditionalKeywordsEndsScopesLength;
};
typedef enum _NaturalDocsParserConfigEnum  NaturalDocsParserConfigEnum;
enum _NaturalDocsParserConfigEnum {
	NaturalDocsParserConfig_AdditionalKeywords       = 0x0001,
	NaturalDocsParserConfig_AdditionalKeywordsLength = 0x0002,
	NaturalDocsParserConfig_AdditionalKeywordsEndsScopesFirstIndex = 0x0004,
	NaturalDocsParserConfig_AdditionalKeywordsEndsScopesLength     = 0x0008,
};


 
/***********************************************************************
  <<< [NaturalDocsHeaderClass] >>> 
************************************************************************/
typedef struct _NaturalDocsHeaderClass  NaturalDocsHeaderClass;
struct _NaturalDocsHeaderClass {
	const TCHAR*  Keyword;  /* Has */
	const TCHAR*  KeywordStart;
	const TCHAR*  KeywordOver;

	const TCHAR*  Name;     /* Has */
	const TCHAR*  NameStart;
	const TCHAR*  NameOver;

	const TCHAR*  BriefNoIndent;
	const TCHAR*  Brief;    /* Has */
	const TCHAR*  BriefStart;
	const TCHAR*  BriefOver;

	const TCHAR*  ArgumentsLabel;
	Set2          Arguments;  /*<NaturalDocsDefinitionClass>*/ /* Has */

	const TCHAR*  ReturnValueLabel;
	const TCHAR*  ReturnValue; /* Has */
	const TCHAR*  ReturnValueStart;
	const TCHAR*  ReturnValueOver;

	const TCHAR*  Descriptions; /* Has */
	const TCHAR*  DescriptionsStart;
	const TCHAR*  DescriptionsOver;

	Set2          DescriptionItems;  /*<NaturalDocsDescriptionClass>*/ /* Has */
};

void      NaturalDocsHeaderClass_initConst( NaturalDocsHeaderClass* self );
errnum_t  NaturalDocsHeaderClass_finalize( NaturalDocsHeaderClass* self,  errnum_t e );

errnum_t  ParseNaturalDocsComment( const TCHAR* in_SourceStart, const TCHAR* in_SourceOver,
	NaturalDocsHeaderClass** out_NaturalDocsHeader,  NaturalDocsParserConfigClass* config );


 
/***********************************************************************
  <<< [NaturalCommentClass] >>> 
************************************************************************/
typedef struct _NaturalCommentClass  NaturalCommentClass;
struct _NaturalCommentClass {

	/* <Inherit parent="SyntaxNodeClass"> */
	const ClassID_Class*         ClassID;
	const FinalizerVTableClass*  FinalizerVTable;
	const TCHAR*                 Start;
	const TCHAR*                 Over;
	const PrintXML_VTableClass*  PrintXML_VTable;
	SyntaxNodeClass*             Parent;
	ListElementClass             SubNodeListElement;  /* for ".Parent" */
	ListClass                    SubNodeList;
	ListElementClass             ListElement;  /* Next and previous in source file */
	/* </Inherit> */

	int   StartLineNum;
	int   LastLineNum;
	NaturalDocsHeaderClass*  NaturalDocsHeader;
	NaturalCommentClass*     ParentComment;
};

extern const ClassID_Class  g_NaturalCommentClass_ID;
void      NaturalCommentClass_initConst( NaturalCommentClass* self );
errnum_t  NaturalCommentClass_finalize( NaturalCommentClass* self, errnum_t e );
errnum_t  NaturalCommentClass_printXML( NaturalCommentClass* self, FILE* OutputStream );


errnum_t  MakeNaturalComments_C_Language( ListClass* /*<C_LanguageTokenClass*>*/ TokenList,
	LineNumberIndexClass*  LineNumbers,
	ListClass* /*<NaturalCommentClass*>*/ TopSyntaxNodeList,
	NaturalDocsParserConfigClass* config );


 
/***********************************************************************
  <<< [Parse_C_Language] >>> 
************************************************************************/
errnum_t  LexicalAnalize_C_Language( const TCHAR* Text,
	ListClass* /*<C_LanguageTokenClass*>*/ TokenList );
errnum_t  CutComment_C_LanguageToken( ListClass* /*<C_LanguageTokenClass*>*/ TokenList );
errnum_t  Delete_C_LanguageToken( ListClass* /*<C_LanguageTokenClass*>*/ TokenList, errnum_t e );
 
errnum_t  CutCommentC_1( const TCHAR*  in_InputPath,  const TCHAR*  in_OutputPath );
errnum_t  CopyWithoutComment_C_Language( ListClass*  in_Tokens,  TCHAR*  in_Text,  FILE*  in_OutStream );
 
/*=================================================================*/
/* <<< [PlatformSDK_plus/PlatformSDK_plus.h] >>> */ 
/*=================================================================*/
 
#if  __cplusplus
 extern "C" {  /* Start of C Symbol */ 
#endif


 
#include  <shlobj.h> 
#pragma comment(lib, "shell32.lib")


 
int  GetCommandLineUnnamed( int Index1, TCHAR* out_AParam, size_t AParamSize ); 
int  GetCommandLineNamed( const TCHAR* Name, bool bCase, TCHAR* out_Value, size_t ValueSize );
int  GetCommandLineNamedC8( const TCHAR* Name, bool bCase, char* out_Value, size_t ValueSize );
int  GetCommandLineNamedI( const TCHAR* Name, bool bCase, int* out_Value );
bool GetCommandLineExist( const TCHAR* Name, bool bCase );

#if ! _UNICODE
	#define  GetCommandLineNamedC8  GetCommandLineNamed
#endif

 
errnum_t  GetProcessInformation( DWORD  in_ProcessID,  PROCESSENTRY32*  out_Info );
 
/* [CloseHandleInFin] */ 
#if ENABLE_ERROR_BREAK_IN_ERROR_CLASS
	#define  CloseHandleInFin( h, e ) \
		( \
			( (h) == INVALID_HANDLE_VALUE || (h) == NULL ||  CloseHandle( h ) )  ? \
			(e)  : \
			( \
				( OnRaisingError_Sub((const char*)__FILE__,__LINE__) )  ? \
				(DebugBreakR(), E_OTHERS)  : \
				(E_OTHERS) \
			) \
		)
#else
	#define  CloseHandleInFin( h, e ) \
		( \
			( (h) == INVALID_HANDLE_VALUE || (h) == NULL ||  CloseHandle( h ) )  ? \
			(e)  : \
			(E_OTHERS) \
		)
#endif


 
/* [env] */ 
#define  env( Str, StrSize, Input ) \
	env_part( Str, StrSize, Str, NULL, Input )
int  env_part( TCHAR* Str,  unsigned StrSize,  TCHAR* StrStart, TCHAR** out_StrLast,
	 const TCHAR* Input );
int  env_malloc( TCHAR** out_Value, size_t* out_ValueLen, const TCHAR* Name );


 
#if  __cplusplus
 }  /* End of C Symbol */ 
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
 
