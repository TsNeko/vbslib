/* Character Code Encoding: "WHITE SQUARE" is □ */
#ifdef  __cplusplus
 extern "C" {  /* Start of C Symbol */ 
#endif


 
/***********************************************************************
* Type: ARGB8888Type
*    ARGB8888 ピクセル フォーマット
*
* メンバー変数:
*    Value   - Blue + Green + Red + Alpha
*    u.Blue  - Blue
*    u.Green - Green
*    u.Red   - Red
*    u.Alpha - Alpha
************************************************************************/
/*[ARGB8888Type]*/
#define        ARGB8888Type  ARGB8888Type
typedef union _ARGB8888Type  ARGB8888Type;
union _ARGB8888Type {
	uint32_t  Value;  /* CPU Endian. Not frame buffer endian */
	struct {
		#if BYTE_ENDIAN == BYTE_LITTLE_ENDIAN
			uint8_t  Blue;   /* Blue is Value & 0x000000FF */
			uint8_t  Green;
			uint8_t  Red;
			uint8_t  Alpha;
		#else
			uint8_t  Alpha;
			uint8_t  Red;
			uint8_t  Green;
			uint8_t  Blue;   /* Blue is Value & 0x000000FF */
		#endif
	} u;
};


 
/***********************************************************************
* Type: XRGB8888Type
*    XRGB8888 ピクセル フォーマット
*
* メンバー変数:
*    Value   - Blue + Green + Red + Alpha
*    u.Blue  - Blue
*    u.Green - Green
*    u.Red   - Red
*    u.X     - Not used
************************************************************************/
/*[XRGB8888Type]*/
#define        XRGB8888Type  XRGB8888Type
typedef union _XRGB8888Type  XRGB8888Type;
union _XRGB8888Type {
	uint32_t  Value;  /* CPU Endian[X8|R8|G8|B8]. Not frame buffer endian */
	struct {
		#if BYTE_ENDIAN == BYTE_LITTLE_ENDIAN
			uint8_t  Blue;   /* offsetof == 0, Blue is Value & 0x000000FF */
			uint8_t  Green;  /* offsetof == 1 */
			uint8_t  Red;    /* offsetof == 2 */
			uint8_t  X;      /* offsetof == 3, zero */
		#elif BYTE_ENDIAN == BYTE_BIG_ENDIAN
			uint8_t  X;      /* offsetof == 0, zero */
			uint8_t  Red;    /* offsetof == 1 */ 
			uint8_t  Green;  /* offsetof == 2 */ 
			uint8_t  Blue;   /* offsetof == 3, Blue is Value & 0x000000FF */
		#else
			#error
		#endif
	} u;
};


 
/***********************************************************************
  <<< [ARGB8888Type_to_XRGB8888Type] >>> 
************************************************************************/
inline XRGB8888Type  ARGB8888Type_to_XRGB8888Type( ARGB8888Type color )
{
	XRGB8888Type  ret;

	ret.Value = color.Value;

	return  ret;
}


 
/***********************************************************************
* Type: BmpFile2Class
*    ビットマップ ファイル
************************************************************************/
/*[BmpFile2Class]*/
typedef struct _BmpFile2Class  BmpFile2Class;
struct _BmpFile2Class {
	BITMAPINFOHEADER  Info;

	// start of enabled if Info.biCompression == BI_BITFIELDS
	uint32_t  RedMask;  // These must be just after Info member variable
	uint32_t  GreenMask;
	uint32_t  BlueMask;
	uint32_t  AlphaMask;
	// end

	uint8_t*  Pixels;
	unsigned  Stride;
	unsigned  Alignment_bfOffBits;

	uint32_t*     Palette;
	int_fast32_t  PaletteColorCount;
};

typedef struct _RGB888Type  RGB888Type;
struct _RGB888Type {
	uint8_t  Blue;
	uint8_t  Green;
	uint8_t  Red;
};

void      BmpFile2Class_initConst( BmpFile2Class* self );
errnum_t  BmpFile2Class_init( BmpFile2Class* self );
errnum_t  BmpFile2Class_loadBMP( BmpFile2Class* self, const TCHAR* Path );
errnum_t  BmpFile2Class_saveBMP( BmpFile2Class* self, const TCHAR* Path );
errnum_t  BmpFile2Class_finish( BmpFile2Class* self, int e );


/*[BmpFile2Class_initConst]*/
inline void  BmpFile2Class_initConst( BmpFile2Class* self )
{
	self->Pixels = NULL;
	self->Palette = NULL;
}

/*[BmpFile2Class_init]*/
inline errnum_t  BmpFile2Class_init( BmpFile2Class* self )
{
	self->Pixels = NULL;
	self->Alignment_bfOffBits = 1;
	self->Palette = NULL;
	return  0;
}


 
errnum_t  BmpFile2Class_loadRawRGB565( BmpFile2Class* self, TCHAR* Path, int Stride );
errnum_t  BmpFile2Class_loadRawARGB8888( BmpFile2Class* self, TCHAR* Path, int Stride );
errnum_t  BmpFile2Class_loadRawARGB1555( BmpFile2Class* self, TCHAR* Path, int Stride );
errnum_t  BmpFile2Class_loadRawARGB4444( BmpFile2Class* self, TCHAR* Path, int Stride );

 
errnum_t  BmpFile2Class_loadPNG( BmpFile2Class* self, const TCHAR* Path ); 
 
errnum_t  BmpFile2Class_loadJPEG( BmpFile2Class* self, const TCHAR* Path ); 
 
errnum_t  BmpFile2Class_addAlphaChannel( BmpFile2Class* self, uint8_t AlphaValue ); 
 
inline errnum_t  BmpFile2Class_setAlignmentBMP_bfOffBits( BmpFile2Class* self, int AlignSize ) 
	{ self->Alignment_bfOffBits = AlignSize;  return  0; }
 
errnum_t  BmpFile2Class_convertToRGB565Format( BmpFile2Class* self );
 
errnum_t  BmpFile2Class_convertToARGB1555Format( BmpFile2Class* self );
 
errnum_t  BmpFile2Class_convertToARGB4444Format( BmpFile2Class* self );
 
errnum_t  BmpFile2Class_convertToA4Format( BmpFile2Class* self );
 
errnum_t  BmpFile2Class_convertToA1Format( BmpFile2Class* self ); 
 
errnum_t  BmpFile2Class_trimming( BmpFile2Class* self, int LeftX, int TopY, int Width, int Height );
 
#if  __cplusplus
 }  /* End of C Symbol */ 
#endif

 
