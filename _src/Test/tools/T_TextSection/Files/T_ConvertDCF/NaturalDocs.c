/***********************************************************************
* File: Docs.c
*    1st document.
*
* - $version: 1.00 $
* - $Author: Tom $
* - Description: This is a description.
************************************************************************/

/***********************************************************************
* Function: SampleFunction
*    This is a brief.
*
* Arguments:
*    Source      - Input
*    Destination - Output
*
* Return Value:
*    Error Code. 0=No Error.
*
* Description:
*    The output from <SampleFunction>.
*
* Example:
*    > void  main()
*    >     {}
************************************************************************/
errnum_t  SampleFunction( int Source, int Destination )
{
	return  Source + Destination;
}


/***********************************************************************
* Structure: SampleClass
*    SampleClassBrief.
************************************************************************/
typedef struct _SampleClass  SampleClass;
struct _SampleClass {

    /* Variable: duration_msec
        See "TimerClass". */
    uint16_t  duration_msec;

    /* Variable: reserved */
    uint16_t  reserved;

    /*-------------------------------------------------------*/
    /* Group: Colors */

    /* Variable: color */
    uint32_t  color;
};


/***********************************************************************
* Structure: Sample2_Class
************************************************************************/
typedef struct _Sample2_Class  Sample2_Class;
struct _Sample2_Class {
    uint32_t  color;
};


/***********************************************************************
* Function: SampleFunction1
*    This is a brief.
*
* Arguments:
*    Source      - Input
*    Destination - Output
*
* Return Value:
*    Error Code. 0=No Error.
*
* Example:
*    >SampleFunction( 0, 0 );
************************************************************************/
errnum_t  SampleFunction( int Source, int Destination )
{
	return  Source + Destination;
}


/***********************************************************************
* Function: SampleFunction2
*    This is a brief 2.
*
* Arguments:
*    None
*
* Return Value:
*    None
*
* Example:
*    > void  main()
*    >     {}
*
* Description:
*    The output from <SampleFunction>.
************************************************************************/
errnum_t  SampleFunction2( int Source, int Destination )
{
	return  Source + Destination;
}


/***********************************************************************
* Function: SampleFunction3
*    This is a brief 3.
*
* Arguments:
*    None
*
* Return Value:
*    None
************************************************************************/
errnum_t  SampleFunction3( int Source, int Destination )
{
	return  Source + Destination;
}


/***********************************************************************
* Function: SampleFunction0
************************************************************************/
errnum_t  SampleFunction0( int Source, int Destination )
{
	return  Source + Destination;
}


/***********************************************************************
* Enumeration: SampleEnum
*    Sample Enum
*
*    : SymbolA - 0, NULL
*    : SymbolB - 1
*
*    - Normal List 1
*    - Normal List 2
************************************************************************/
typedef enum _SampleEnum  SampleEnum;
enum _SampleEnum {
	SymbolA,
	SymbolB,
};


/***********************************************************************
* Type: ARGB8888Type
*    Color fomat
************************************************************************/
typedef uint32_t  ARGB8888Type;


/***********************************************************************
* Macro: N_MACRO
*    No parameter macro
*
* Arguments:
*    None.
*
* Return Value:
*    None.
************************************************************************/
#define  N_MACRO()  (1)


/***********************************************************************
* Macro: A_MACRO
*    With parameter macro
*
* Arguments:
*    x - Input
*
* Return Value:
*    Error Code. 0=No Err.
************************************************************************/
#define  A_MACRO( x )  ((x)+1)


/***********************************************************************
* Constant: VALUE_CONSTANT
*    No parameter macro
************************************************************************/
#define  VALUE_CONSTANT  1


/***********************************************************************
* Constants: BYTE_ENDIAN
*
*    BYTE_LITTLE_ENDIAN - Little endian
*    BYTE_BIG_ENDIAN    - Big endian
************************************************************************/
#define  BYTE_LITTLE_ENDIAN  1
#define  BYTE_BIG_ENDIAN     2


