/**
* @file  NaturalDocs.c
* @brief  1st document.
*
* $version: 1.00 $
* $Author: Tom $
* - Description: This is a description.
*/

/**
* @brief   This is a brief.
*
* @param   Source Input
* @param   Destination Output
* @return  Error Code. 0=No Error.
*
* @par Description
*    The output from @ref SampleFunction.
*
* @par Example
*    @code
*    void  main()
*        {}
*    @endcode
*/
errnum_t  SampleFunction( int Source, int Destination )
{
	return  Source + Destination;
}


/**
* @struct  SampleClass
* @brief  SampleClassBrief.
*/
typedef struct _SampleClass  SampleClass;
struct _SampleClass {

    /** See "TimerClass". */
    uint16_t  duration_msec;

    /** reserved */
    uint16_t  reserved;

    /*-------------------------------------------------------*/
    /* Group: Colors */

    /** color */
    uint32_t  color;
};


/**
* @struct  Sample2_Class
* @brief  Sample2_Class
*/
typedef struct _Sample2_Class  Sample2_Class;
struct _Sample2_Class {
    uint32_t  color;
};


/**
* @brief   This is a brief.
*
* @param   Source Input
* @param   Destination Output
* @return  Error Code. 0=No Error.
*
* @par Example
*    @code
*    SampleFunction( 0, 0 );
*    @endcode
*/
errnum_t  SampleFunction( int Source, int Destination )
{
	return  Source + Destination;
}


/**
* @brief   This is a brief 2.
*
* @par Parameters
*    None
* @return  None
*
* @par Example
*    @code
*    void  main()
*        {}
*    @endcode
*
* @par Description
*    The output from @ref SampleFunction.
*/
errnum_t  SampleFunction2( int Source, int Destination )
{
	return  Source + Destination;
}


/**
* @brief   This is a brief 3.
*
* @par Parameters
*    None
* @return  None
*/
errnum_t  SampleFunction3( int Source, int Destination )
{
	return  Source + Destination;
}


/**
* @brief   SampleFunction0
*
* @par Parameters
*    None
* @return  None.
*/
errnum_t  SampleFunction0( int Source, int Destination )
{
	return  Source + Destination;
}


/**
* @enum   SampleEnum
* @brief  Sample Enum
*
*    - SymbolA - 0, NULL
*    - SymbolB - 1
*
*    - Normal List 1
*    - Normal List 2
*/
typedef enum _SampleEnum  SampleEnum;
enum _SampleEnum {
	SymbolA,
	SymbolB,
};


/**
* @typedef  ARGB8888Type
* @brief  Color fomat
*/
typedef uint32_t  ARGB8888Type;


/**
* @def  N_MACRO
* @brief  No parameter macro
* @par Parameters
*    None
* @return  None.
*/
#define  N_MACRO()  (1)


/**
* @def  A_MACRO
* @brief  With parameter macro
* @param   x Input
* @return  Error Code. 0=No Err.
*/
#define  A_MACRO( x )  ((x)+1)


/**
* @def  VALUE_CONSTANT
* @brief  No parameter macro
*/
#define  VALUE_CONSTANT  1


/**
* @def  BYTE_ENDIAN
* @brief  BYTE_ENDIAN
*    - BYTE_LITTLE_ENDIAN - Little endian
*    - BYTE_BIG_ENDIAN - Big endian
*/
#define  BYTE_LITTLE_ENDIAN  1
#define  BYTE_BIG_ENDIAN     2


