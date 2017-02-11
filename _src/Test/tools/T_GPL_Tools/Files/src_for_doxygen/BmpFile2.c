/* Character Code Encoding: "WHITE SQUARE" is □ */
#include  "include_c.h" 
#pragma hdrstop

 
/**
* @brief   BMP 形式のファイルを読み込みます。
*
* @par Parameters
*    None
* @return  None.
*
* @par 引数
*    - Path - BMP file path
*
* @par 返り値
*    エラーコード、0=エラーなし
*/
/*[BmpFile2Class_loadBMP]*/
errnum_t  BmpFile2Class_loadBMP( BmpFile2Class* self, const TCHAR* Path )
{
	BITMAPFILEHEADER  bmp_header;
	errnum_t  e;
	errno_t   en;
	FILE*     file = NULL;
	int       height_abs;


	en= _tfopen_s( &file, Path, _T("rb") ); IF(en){e=E_ERRNO;goto fin;}

	fread( &bmp_header, 1, sizeof(bmp_header), file ); IF(ferror(file)){e=E_ERRNO;goto fin;}
	ASSERT_R( bmp_header.bfType == ('B' | ( 'M' << 8 )),  e=E_OTHERS; goto fin );

	fread( &self->Info, 1, sizeof(self->Info), file ); IF(ferror(file)){e=E_ERRNO;goto fin;}
	if ( self->Info.biBitCount >= 8 ) {
		self->Stride = self->Info.biWidth * ( ( self->Info.biBitCount + 7 ) / 8 );
	} else {
		self->Stride = ( self->Info.biWidth * self->Info.biBitCount + 7 ) / 8;
	}
	self->Stride = ceil_4( self->Stride );

	if ( self->Info.biBitCount == 16 ) {
		fread( &self->RedMask,   1, sizeof(self->RedMask),   file ); IF(ferror(file)){e=E_ERRNO;goto fin;}
		fread( &self->GreenMask, 1, sizeof(self->GreenMask), file ); IF(ferror(file)){e=E_ERRNO;goto fin;}
		fread( &self->BlueMask,  1, sizeof(self->BlueMask),  file ); IF(ferror(file)){e=E_ERRNO;goto fin;}
		fread( &self->AlphaMask, 1, sizeof(self->AlphaMask), file ); IF(ferror(file)){e=E_ERRNO;goto fin;}
	}
	else if ( self->Info.biBitCount <= 8 ) {
		int  color_count = 1 << self->Info.biBitCount;

		if ( self->Info.biClrUsed != 0 )
			{ color_count = self->Info.biClrUsed; }

		e= MallocMemory( &self->Palette, color_count * sizeof(RGBQUAD) ); IF(e){goto fin;}

		fread( self->Palette, 1,  color_count * sizeof(RGBQUAD), file );
			IF(ferror(file)){e=E_ERRNO;goto fin;}

		self->PaletteColorCount = color_count;
	}

	height_abs = self->Info.biHeight;
	if ( height_abs < 0 ) { height_abs = -height_abs; }

	ASSERT_R( self->Info.biSizeImage == 0  ||
		self->Info.biSizeImage == self->Stride * height_abs, goto err_og );

	if ( self->Info.biSizeImage == 0 )
		{ self->Info.biSizeImage = self->Stride * height_abs; }

	e= FreeMemory( &self->Pixels, 0 ); IF(e){goto fin;}
	e= MallocMemory( &self->Pixels, self->Info.biSizeImage ); IF(e){goto fin;}

	fseek( file, bmp_header.bfOffBits, SEEK_SET ); IF(ferror(file)){e=E_ERRNO;goto fin;}
	fread( self->Pixels, self->Info.biSizeImage, 1, file ); IF(ferror(file)){e=E_ERRNO;goto fin;}

	e=0;
fin:
	e= FileT_closeAndNULL( &file, e );
	if ( e ) {
		e= FreeMemory( &self->Pixels, e );
	}
	return  e;

err_og:
	Error4_printf( _T("<ERROR msg=\"BITMAPINFOHEADER::biSizeImage is invalid\"/>") );
	e = E_ORIGINAL;
	goto fin;
}


 
/**
* @brief   BMP 形式のファイルを書き込みます。
*
* @par Parameters
*    None
* @return  None.
*
* @par 引数
*    - Path - BMP file path
*
* @par 返り値
*    エラーコード、0=エラーなし
*/
/*[BmpFile2Class_saveBMP]*/
errnum_t  BmpFile2Class_saveBMP( BmpFile2Class* self, const TCHAR* Path )
{
	BITMAPFILEHEADER  bmp_header;
	errnum_t  e;
	errno_t   en;
	FILE*     file = NULL;
	int       mod;
	int       plus;
	int       height_abs;
	int       palette_index;
	int       offset;
	uint32_t  palette[16];  // RGBQUAD type


	height_abs = self->Info.biHeight;
	if ( height_abs < 0 ) { height_abs = -height_abs; }

	memset( &bmp_header, 0, sizeof(bmp_header) );
	bmp_header.bfType = 'B' | ( 'M' << 8 );
	bmp_header.bfSize = sizeof(bmp_header) + sizeof(self->Info) +
		height_abs * self->Stride;

	bmp_header.bfOffBits = 0x36;
	switch ( self->Info.biBitCount ) {
		case 1:
			bmp_header.bfSize    +=  2 * sizeof(RGBQUAD);
			bmp_header.bfOffBits +=  2 * sizeof(RGBQUAD);
			break;

		case 4:
			bmp_header.bfSize    += 16 * sizeof(RGBQUAD);
			bmp_header.bfOffBits += 16 * sizeof(RGBQUAD);
			break;

		case 8:
			bmp_header.bfSize    += 256 * sizeof(RGBQUAD);
			bmp_header.bfOffBits += 256 * sizeof(RGBQUAD);
			break;

		case 16:
			bmp_header.bfSize    += 4 * sizeof(RGBQUAD);
			bmp_header.bfOffBits += 4 * sizeof(RGBQUAD);
			break;

		case 24:  break;
		case 32:  break;

		default: ASSERT_R( false,  e=E_OTHERS; goto fin );  break;
	}
	mod = bmp_header.bfOffBits % self->Alignment_bfOffBits;
	if ( mod != 0 ) {
		plus = - mod + self->Alignment_bfOffBits;
		bmp_header.bfSize    += plus;
		bmp_header.bfOffBits += plus;
	}

	en= _tfopen_s( &file, Path, _T("wb") ); IF(en){e=E_ERRNO;goto fin;}
		ASSERT_R( file != NULL,  e=E_OTHERS; goto fin );
	fwrite( &bmp_header, 1, sizeof(bmp_header), file ); IF(ferror(file)){e=E_ERRNO;goto fin;}
	fwrite( &self->Info, 1, sizeof(self->Info), file ); IF(ferror(file)){e=E_ERRNO;goto fin;}

	switch ( self->Info.biBitCount ) {
	 case 1:
		palette[0] = 0x00000000;  palette[1] = 0x00FFFFFF;
		fwrite( palette, 2, sizeof(*palette), file ); IF(ferror(file)){e=E_ERRNO;goto fin;}
		break;
	 case 4:
		palette[0] = 0x00000000;  palette[1] = 0x00111111;  palette[2] = 0x00222222;  palette[3] = 0x00333333;
		palette[4] = 0x00444444;  palette[5] = 0x00555555;  palette[6] = 0x00666666;  palette[7] = 0x00777777;
		palette[8] = 0x00888888;  palette[9] = 0x00999999;  palette[10]= 0x00AAAAAA;  palette[11]= 0x00BBBBBB;
		palette[12]= 0x00CCCCCC;  palette[13]= 0x00DDDDDD;  palette[14]= 0x00EEEEEE;  palette[15]= 0x00FFFFFF;
		fwrite( palette, 16, sizeof(*palette), file ); IF(ferror(file)){e=E_ERRNO;goto fin;}
		break;
	 case 8:
		for ( palette_index = 0;  palette_index < 256;  palette_index += 0x10 ) {
			palette[ 0 ] = 0x00010101 * palette_index;
			for ( offset = 1;  offset < 0x10;  offset += 1 ) {
				palette[ offset ] = palette[ 0 ] + 0x00010101 * offset;
			}
			fwrite( palette, 16, sizeof(*palette), file ); IF(ferror(file)){e=E_ERRNO;goto fin;}
		}
		break;
	 case 16:
		palette[0] = self->RedMask;   palette[1] = self->GreenMask;
		palette[2] = self->BlueMask;  palette[3] = self->AlphaMask;
		fwrite( palette, 4, sizeof(*palette), file ); IF(ferror(file)){e=E_ERRNO;goto fin;}
		break;
	}

	fseek( file, bmp_header.bfOffBits, SEEK_SET ); IF(ferror(file)){e=E_ERRNO;goto fin;}
	fwrite( self->Pixels, 1, height_abs * self->Stride, file );
		IF(ferror(file)){e=E_ERRNO;goto fin;}

	e=0;
fin:
	if ( file != NULL )  fclose( file );
	return  e;
}


 
/***********************************************************************
  <<< [BmpFile2Class_finish] >>> 
************************************************************************/
errnum_t  BmpFile2Class_finish( BmpFile2Class* self, errnum_t e )
{
	e= FreeMemory( &self->Pixels, e );
	e= FreeMemory( &self->Palette, e );
	return  e;
}

 
/***********************************************************************
  <<< [BmpFile2Class_loadRaw16bit_Sub] >>> 
************************************************************************/
errnum_t  BmpFile2Class_loadRaw16bit_Sub( BmpFile2Class* self, TCHAR* Path, int Stride )
{
	FILE*     file = NULL;
	errno_t   en;
	errnum_t  e;
	size_t    raw_size;

	ASSERT_R( Stride % 4 == 0,  e=E_OTHERS; goto fin );

	en= _tfopen_s( &file, Path, _T("rb") ); IF(en){ e=E_ERRNO; goto fin; }

	fseek( file, 0, SEEK_END );
	raw_size = ftell( file );
	fseek( file, 0, SEEK_SET );

	if ( self->Pixels != NULL )  free( self->Pixels );
	self->Pixels = (uint8_t*) malloc( raw_size );
		ASSERT_R( self->Pixels != NULL,  e=E_OTHERS; goto fin );

	fread( self->Pixels, 1, raw_size, file );

	self->Info.biSize = sizeof(BITMAPINFOHEADER) + 4 * sizeof(uint32_t);
	self->Info.biWidth  = Stride / 2;
	self->Info.biHeight = - (LONG)( raw_size / Stride );
	self->Info.biPlanes = 1;
	self->Info.biBitCount = 16;
	self->Info.biCompression = BI_BITFIELDS;
	self->Info.biSizeImage = raw_size;
	self->Info.biXPelsPerMeter = 0;
	self->Info.biYPelsPerMeter = 0;
	self->Info.biClrUsed = 0;
	self->Info.biClrImportant = 0;
	self->RedMask   = 0xF800;
	self->GreenMask = 0x07E0;
	self->BlueMask  = 0x001F;
	self->AlphaMask = 0x0000;
	self->Stride = Stride;

	e=0;
fin:
	if ( file != NULL )  fclose( file );
	if ( e ) {
		if ( self->Pixels != NULL )  free( self->Pixels );
		self->Pixels = NULL;
	}
	return  e;
}


 
/***********************************************************************
  <<< [BmpFile2Class_loadRawRGB565] >>> 
************************************************************************/
errnum_t  BmpFile2Class_loadRawRGB565( BmpFile2Class* self, TCHAR* Path, int Stride )
{
	errnum_t  e;

	e= BmpFile2Class_loadRaw16bit_Sub( self, Path, Stride );
	self->RedMask   = 0xF800;
	self->GreenMask = 0x07E0;
	self->BlueMask  = 0x001F;
	self->AlphaMask = 0x0000;

	return  e;
}


 
/***********************************************************************
  <<< [BmpFile2Class_loadRawARGB8888] >>> 
************************************************************************/
errnum_t  BmpFile2Class_loadRawARGB8888( BmpFile2Class* self, TCHAR* Path, int Stride )
{
	FILE*     file = NULL;
	errno_t   en;
	errnum_t  e;
	size_t    raw_size;

	ASSERT_R( Stride % 4 == 0,  e=E_OTHERS; goto fin );

	en= _tfopen_s( &file, Path, _T("rb") ); IF(en){ e=E_ERRNO; goto fin; }

	fseek( file, 0, SEEK_END );
	raw_size = ftell( file );
	fseek( file, 0, SEEK_SET );

	if ( self->Pixels != NULL )  free( self->Pixels );
	self->Pixels = (uint8_t*) malloc( raw_size );
		ASSERT_R( self->Pixels != NULL,  e=E_OTHERS; goto fin );

	fread( self->Pixels, 1, raw_size, file );

	self->Info.biSize = sizeof(BITMAPINFOHEADER);
	self->Info.biWidth  = Stride / 4;
	self->Info.biHeight = - (LONG)( raw_size / Stride );
	self->Info.biPlanes = 1;
	self->Info.biBitCount = 32;
	self->Info.biCompression = 0;
	self->Info.biSizeImage = raw_size;
	self->Info.biXPelsPerMeter = 0;
	self->Info.biYPelsPerMeter = 0;
	self->Info.biClrUsed = 0;
	self->Info.biClrImportant = 0;
	self->RedMask   = 0;
	self->GreenMask = 0;
	self->BlueMask  = 0;
	self->AlphaMask = 0;
	self->Stride = Stride;

	e=0;
fin:
	if ( file != NULL )  fclose( file );
	if ( e ) {
		if ( self->Pixels != NULL )  free( self->Pixels );
		self->Pixels = NULL;
	}
	return  e;
}


 
/***********************************************************************
  <<< [BmpFile2Class_loadRawARGB1555] >>> 
************************************************************************/
errnum_t  BmpFile2Class_loadRawARGB1555( BmpFile2Class* self, TCHAR* Path, int Stride )
{
	errnum_t  e;

	e= BmpFile2Class_loadRaw16bit_Sub( self, Path, Stride );
	self->RedMask   = 0x7C00;
	self->GreenMask = 0x03E0;
	self->BlueMask  = 0x001F;
	self->AlphaMask = 0x8000;

	return  e;
}


 
/***********************************************************************
  <<< [BmpFile2Class_loadRawARGB4444] >>> 
************************************************************************/
errnum_t  BmpFile2Class_loadRawARGB4444( BmpFile2Class* self, TCHAR* Path, int Stride )
{
	errnum_t  e;

	e= BmpFile2Class_loadRaw16bit_Sub( self, Path, Stride );
	self->RedMask   = 0x0F00;
	self->GreenMask = 0x00F0;
	self->BlueMask  = 0x000F;
	self->AlphaMask = 0xF000;

	return  e;
}


 
/***********************************************************************
  <<< [BmpFile2Class_loadPNG] >>> 
************************************************************************/
errnum_t  BmpFile2Class_loadPNG( BmpFile2Class* self, const TCHAR* Path )
{
	FILE*        f = NULL;
	png_struct*  png = NULL;
	png_info*    info = NULL;
	png_info*    end_info = NULL;
	uint8_t**    lines = NULL;
	int          ret = 0;
	errno_t      en;
	errnum_t     e;


	/* Open file and Create work */
	en= _tfopen_s( &f, Path, _T("rb") ); IF(en)goto err_no;
	IF( f == NULL ){goto err;}

	png = png_create_read_struct( PNG_LIBPNG_VER_STRING, NULL, NULL, NULL );
		IF( png == NULL ){goto err;}
	info = png_create_info_struct( png ); IF( info == NULL ){goto err;}
	end_info = png_create_info_struct( png ); IF( end_info == NULL ){goto err;}

	png_init_io( png, f );


	/* Read Information */
	{
		png_read_info( png, info );

		self->Stride = png_get_rowbytes( png, info );
		self->Stride = ceil_4( self->Stride );

		ASSERT_R( info->num_palette == 0, goto err );
		ASSERT_R( info->bit_depth == 8, goto err );
		ASSERT_R( info->color_type == PNG_COLOR_TYPE_RGB ||
		          info->color_type == PNG_COLOR_TYPE_RGB_ALPHA, goto err );

		self->Info.biSize = sizeof(BITMAPINFOHEADER);
		self->Info.biWidth = info->width;
		self->Info.biHeight = info->height;
		self->Info.biPlanes = 1;
		switch ( info->color_type ) {
			case  PNG_COLOR_TYPE_RGB:        self->Info.biBitCount = 24;  break;
			case  PNG_COLOR_TYPE_RGB_ALPHA:  self->Info.biBitCount = 32;  break;
			default:  ASSERT_R( false, goto err );
		}
		self->Info.biCompression = BI_RGB;
		self->Info.biSizeImage = self->Info.biHeight * self->Stride;
		self->Info.biXPelsPerMeter = 0;
		self->Info.biYPelsPerMeter = 0;
		self->Info.biClrUsed = 0;
		self->Info.biClrImportant = 0;
	}

	/* Read Pixels */
	{
		int  i;
		uint8_t*       left_of_line;
		uint_fast32_t  stride = self->Stride;

		e= HeapMemory_free( &self->Pixels, 0 ); IF(e){goto fin;}
		e= HeapMemory_allocateArray( &lines, self->Info.biHeight ); IF(e){goto fin;}
		e= HeapMemory_allocateArray( &self->Pixels, stride * self->Info.biHeight ); IF(e){goto fin;}

		left_of_line = self->Pixels;

		for ( i = self->Info.biHeight - 1;  i >= 0;  i -= 1 ) {
			lines[ i ] = left_of_line;

			left_of_line[ stride - 3 ] = 0x00;  /* Padding */
			left_of_line[ stride - 2 ] = 0x00;
			left_of_line[ stride - 1 ] = 0x00;

			left_of_line += stride;
		}

		png_set_bgr( png );
		png_read_image( png, lines );  /* Set to "self->Pixels" */
		png_read_end( png, end_info );
	}

fin:
	e= HeapMemory_free( &lines, e );
	if ( info != NULL )  { png_destroy_info_struct( png, &info ); }
	if ( end_info != NULL )  { png_destroy_info_struct( png, &end_info ); }
	if ( png != NULL )  { png_destroy_read_struct( &png, NULL, NULL ); }
	if ( f != NULL )  { fclose( f ); }

	if ( e ) {
		self->Info.biWidth  = 0;
		self->Info.biHeight = 0;
		e= HeapMemory_free( &self->Pixels, e );
	}

	return  ret;

err:     e = E_OTHERS;  goto fin;
err_no:  e = E_ERRNO;   goto fin;
}


 
/***********************************************************************
  <<< [BmpFile2Class_loadJPEG] >>> 
************************************************************************/
#ifndef  LibJPEG_is
#define  LibJPEG_is  LibJPEG_is_DLL
#endif
#define  LibJPEG_is_Lib  1
#define  LibJPEG_is_DLL  2

errnum_t  BmpFile2Class_loadJPEG( BmpFile2Class* self, const TCHAR* Path )
{
	struct jpeg_decompress_struct  jpeg_decompress;
	struct jpeg_error_mgr          jpeg_error;
	errnum_t  e;
	FILE*     file = NULL;
	errno_t   en;
	char*     pixels = NULL;
	char**    pixel_line_pointers = NULL;
	unsigned  width_stride;
	unsigned  width_byte;
	bool      is_jpeg_decompress = false;
	bool      is_started_jpeg_decompress = false;
#if  LibJPEG_is == LibJPEG_is_DLL
	void*     data_of_JPEG = NULL;
	int       jpeg_size;
	int       read_size;
#endif

	en = _tfopen_s( &file, Path, _T("rb") ); IF(en){ e=E_ERRNO; goto fin; }

	// set up JPEG library  and  read JPEG header in the file
	jpeg_decompress.err = jpeg_std_error( &jpeg_error );
	jpeg_create_decompress( &jpeg_decompress );  is_jpeg_decompress = true;
	#if  LibJPEG_is == LibJPEG_is_DLL
		fseek( file, 0, SEEK_END );
		jpeg_size = ftell( file );
		fseek( file, 0, SEEK_SET );
		data_of_JPEG = (char*) malloc( jpeg_size );
			IF( data_of_JPEG == NULL ){ e=E_FEW_MEMORY; goto fin; }
		read_size = fread( data_of_JPEG, 1, jpeg_size, file );
		ASSERT_R( read_size == jpeg_size,  e=E_OTHERS; goto fin );
		jpeg_mem_src( &jpeg_decompress, (unsigned char*) data_of_JPEG, jpeg_size );
	#else
		jpeg_stdio_src( &jpeg_decompress, file );
	#endif
	jpeg_read_header( &jpeg_decompress, TRUE );

	ASSERT_R( jpeg_decompress.num_components == 3, e=E_OTHERS; goto fin );

	width_byte = jpeg_decompress.image_width * jpeg_decompress.num_components;
	width_stride = ceil_4( width_byte );

	pixels = (char*) malloc(
		width_stride * jpeg_decompress.image_height * sizeof(char) );
		IF(pixels == NULL){ e=E_FEW_MEMORY; goto fin; }


	// set pixel_line_pointers
	{
		char*   p;
		char**  pp;
		char**  pp_over;

		pixel_line_pointers = (char**) malloc(
			jpeg_decompress.image_height * sizeof(char*) );
			IF(pixel_line_pointers == NULL){ e=E_FEW_MEMORY; goto fin; };

		p = pixels;
		pp_over = pixel_line_pointers + jpeg_decompress.image_height;

		for ( pp = pp_over - 1;  pp >= pixel_line_pointers;  pp -- ) {
			*pp = p;
			p += width_stride;
			*(int*)( p - 4 ) = 0;  // fill zero to padding area at right of line
		}
	}


	// read pixels
	jpeg_start_decompress( &jpeg_decompress );
	is_started_jpeg_decompress = true;
	while ( jpeg_decompress.output_scanline < jpeg_decompress.output_height ) {
		char**  pp = pixel_line_pointers + jpeg_decompress.output_scanline;
		char**  pp_over;

		jpeg_read_scanlines( &jpeg_decompress,
			(JSAMPARRAY)( pixel_line_pointers + jpeg_decompress.output_scanline ),
			jpeg_decompress.output_height - jpeg_decompress.output_scanline );

		// change from RGB to BGR
		pp_over = pixel_line_pointers + jpeg_decompress.output_scanline;
		for ( ;  pp < pp_over;  pp ++ ) {
			char*   p = *pp;
			char*   p_over = p + width_byte;

			for ( ;  p < p_over;  p += jpeg_decompress.num_components ) {
				char  value;

				value = *( p + 0 );
				*( p + 0 ) = *( p + 2 );
				*( p + 2 ) = value;
			}
		}
	}


	/* set self attributes */
	{
		self->Stride = width_stride;

		self->Info.biSize = sizeof(BITMAPINFOHEADER);
		self->Info.biWidth  = jpeg_decompress.image_width;
		self->Info.biHeight = jpeg_decompress.image_height;
		self->Info.biPlanes = 1;
		self->Info.biBitCount = 24;
		self->Info.biCompression = BI_RGB;
		self->Info.biSizeImage = self->Info.biHeight * self->Stride;
		self->Info.biXPelsPerMeter = 0;
		self->Info.biYPelsPerMeter = 0;
		self->Info.biClrUsed = 0;
		self->Info.biClrImportant = 0;
		self->Pixels = (uint8_t*) pixels;
	}

	e=0;
fin:
	if ( e ) {
		if ( pixels != NULL )  free( pixels );
	}
	if ( is_started_jpeg_decompress )  jpeg_finish_decompress( &jpeg_decompress );
	if ( is_jpeg_decompress )  jpeg_destroy_decompress( &jpeg_decompress );
	if ( pixel_line_pointers != NULL )  free( pixel_line_pointers );
	if ( file != NULL )  fclose( file );
	#if  LibJPEG_is == LibJPEG_is_DLL
		if ( data_of_JPEG != NULL ) { free( data_of_JPEG ); }
	#endif
	return  e;
}


 
/***********************************************************************
  <<< [BmpFile2Class_addAlphaChannel] >>> 
************************************************************************/
errnum_t  BmpFile2Class_addAlphaChannel( BmpFile2Class* self, uint8_t AlphaValue )
{
	errnum_t  e;
	uint32_t  image_size;
	uint8_t*  new_pixels;
	unsigned  stride24;
	unsigned  stride32;
	uint8_t*  src;  // source
	uint8_t*  dst;  // destination
	uint8_t*  src_line_head;
	uint8_t*  dst_line_head;
	int       src_line_tail_offset;
	int       dst_line_tail_offset;

	if ( self->Info.biBitCount == 32 )  return  0;

	ASSERT_R( self->Info.biBitCount == 24, goto err );
	ASSERT_R( self->Stride * self->Info.biHeight == self->Info.biSizeImage, goto err );

	stride24 = self->Stride;
	stride32 = self->Info.biWidth * 4;

	image_size = stride32 * self->Info.biHeight;
	new_pixels = (uint8_t*) realloc( self->Pixels, image_size );
		ASSERT_R( new_pixels != NULL, goto err_fm );

	self->Pixels = new_pixels;
	self->Info.biBitCount = 32;
	self->Stride = stride32;
	self->Info.biSizeImage = image_size;

	src_line_head = new_pixels + stride24 * (self->Info.biHeight - 1);
	dst_line_head = new_pixels + stride32 * (self->Info.biHeight - 1);
	src_line_tail_offset = (self->Info.biWidth - 1) * (24/8);
	dst_line_tail_offset = (self->Info.biWidth - 1) * (32/8);
	do {
		src = src_line_head + src_line_tail_offset;
		dst = dst_line_head + dst_line_tail_offset;
		do {
			*( dst + 3 ) = AlphaValue;
			*( dst + 2 ) = *( src + 2 );  // Red
			*( dst + 1 ) = *( src + 1 );  // Green
			*( dst )     = *( src );      // Blue
			src -= (24/8);
			dst -= (32/8);
		} while ( src >= src_line_head );

		src_line_head -= stride24;
		dst_line_head -= stride32;
	} while ( src_line_head >= new_pixels );

	e=0;
fin:
	return  e;

err:     e = E_OTHERS;     goto fin;
err_fm:  e = E_FEW_MEMORY;  goto fin;
}


 
/***********************************************************************
  <<< [BmpFile2Class_convertToRGB565Format] >>> 
************************************************************************/
errnum_t  BmpFile2Class_convertToRGB565Format( BmpFile2Class* self )
{
	errnum_t  e;
	uint32_t  image_size;
	uint8_t*  new_pixels = NULL;
	unsigned  src_stride;
	unsigned  stride16;
	uint16_t  red, green, blue;
	uint8_t*  src;  // source
	uint8_t*  dst;  // destination
	uint8_t*  src_line_head;
	uint8_t*  dst_line_head;
	int       src_line_tail_offset;
	int       dst_line_tail_offset;
	int       src_byte_per_pixel;

	ASSERT_R( self->Info.biBitCount == 24 || self->Info.biBitCount == 32, goto err );
	ASSERT_R( self->Stride * self->Info.biHeight == self->Info.biSizeImage, goto err );

	src_stride = self->Stride;
	stride16 = self->Info.biWidth * 2;
	stride16 = ( stride16 + 3 ) & ~0x3;  // 4byte alignment

	image_size = stride16 * self->Info.biHeight;
	new_pixels = (uint8_t*) malloc( image_size );  IF(new_pixels==NULL)goto err_fm;

	src_line_head = self->Pixels + src_stride * (self->Info.biHeight - 1);
	dst_line_head = new_pixels   + stride16   * (self->Info.biHeight - 1);
	src_line_tail_offset = (self->Info.biWidth - 1) * ( self->Info.biBitCount / 8 );
	dst_line_tail_offset = (self->Info.biWidth - 1) * (16/8);
	src_byte_per_pixel = self->Info.biBitCount / 8;
	do {
		src = src_line_head + src_line_tail_offset;
		dst = dst_line_head + dst_line_tail_offset;

		*(uint32_t*)( dst_line_head + stride16 - sizeof(uint32_t) ) = 0;  // padding

		while ( src >= src_line_head ) {
			red   = *( src + 2 );
			green = *( src + 1 );
			blue  = *( src );

			*(uint16_t*) dst =
				( ( red   & 0xF8 ) << 8 ) |
				( ( green & 0xFC ) << 3 ) |
				( ( blue  & 0xF8 ) >> 3 );

			src -= src_byte_per_pixel;
			dst -= 2;
		}
		src_line_head -= src_stride;
		dst_line_head -= stride16;
	} while ( dst_line_head >= new_pixels );

	self->Pixels = new_pixels;
	self->Info.biBitCount = 16;
	self->Stride = stride16;
	self->Info.biSizeImage = image_size;
	self->Info.biCompression = BI_BITFIELDS;
	self->Info.biSize = sizeof(BITMAPINFOHEADER) + 4 * sizeof(uint32_t);
	self->RedMask   = 0xF800;
	self->GreenMask = 0x07E0;
	self->BlueMask  = 0x001F;
	self->AlphaMask = 0x0000;

	new_pixels = NULL;

	e=0;
fin:
	if ( new_pixels != NULL )  free( new_pixels );
	return  e;

err:     e = E_OTHERS;     goto fin;
err_fm:  e = E_FEW_MEMORY;  goto fin;
}


 
/***********************************************************************
  <<< [BmpFile2Class_convertToARGB1555Format] >>> 
************************************************************************/
errnum_t  BmpFile2Class_convertTo16bitARGBFormat( BmpFile2Class* self, uint16_t AlphaMask );

errnum_t  BmpFile2Class_convertToARGB1555Format( BmpFile2Class* self )
{
	return  BmpFile2Class_convertTo16bitARGBFormat( self, 0x8000 );
}

errnum_t  BmpFile2Class_convertTo16bitARGBFormat( BmpFile2Class* self, uint16_t AlphaMask )
{
	errnum_t  e;
	uint32_t  image_size;
	uint8_t*  new_pixels = NULL;
	unsigned  stride32;
	unsigned  stride16;
	uint16_t  red, green, blue, alpha;
	uint8_t*  src;  // source
	uint8_t*  dst;  // destination
	uint8_t*  src_line_head;
	uint8_t*  dst_line_head;
	int       src_line_tail_offset;
	int       dst_line_tail_offset;

	ASSERT_R( self->Info.biBitCount == 32, goto err );  // need alpha channel
	ASSERT_R( self->Stride * self->Info.biHeight == self->Info.biSizeImage, goto err );
	ASSERT_R( AlphaMask == 0x8000 || AlphaMask == 0xF000, goto err );
		// 0x8000 = ARGB1555, 0xF000 = ARGB4444

	stride32 = self->Stride;
	stride16 = self->Info.biWidth * 2;
	stride16 = ( stride16 + 3 ) & ~0x3;  // 4byte alignment

	image_size = stride16 * self->Info.biHeight;
	new_pixels = (uint8_t*) malloc( image_size );  IF(new_pixels==NULL)goto err_fm;

	src_line_head = self->Pixels + stride32 * (self->Info.biHeight - 1);
	dst_line_head = new_pixels   + stride16 * (self->Info.biHeight - 1);
	src_line_tail_offset = (self->Info.biWidth - 1) * (32/8);
	dst_line_tail_offset = (self->Info.biWidth - 1) * (16/8);
	do {
		src = src_line_head + src_line_tail_offset;
		dst = dst_line_head + dst_line_tail_offset;

		*(uint32_t*)( dst_line_head + stride16 - sizeof(uint32_t) ) = 0;  // padding

		if ( AlphaMask == 0x8000 ) {  // ARGB1555
			while ( src >= src_line_head ) {
				alpha = *( src + 3 );
				red   = *( src + 2 );
				green = *( src + 1 );
				blue  = *( src );

				*(uint16_t*) dst =
					( ( alpha & 0x80 ) << 8 ) |
					( ( red   & 0xF8 ) << 7 ) |
					( ( green & 0xF8 ) << 2 ) |
					( ( blue  & 0xF8 ) >> 3 );

				src -= 4;
				dst -= 2;
			}
		}
		else {  // ARGB4444
			while ( src >= src_line_head ) {
				alpha = *( src + 3 );
				red   = *( src + 2 );
				green = *( src + 1 );
				blue  = *( src );

				*(uint16_t*) dst =
					( ( alpha & 0xF0 ) << 8 ) |
					( ( red   & 0xF0 ) << 4 ) |
					( ( green & 0xF0 ) ) |
					( ( blue  & 0xF0 ) >> 4 );

				src -= 4;
				dst -= 2;
			}
		}
		src_line_head -= stride32;
		dst_line_head -= stride16;
	} while ( dst_line_head >= new_pixels );

	self->Pixels = new_pixels;
	self->Info.biBitCount = 16;
	self->Stride = stride16;
	self->Info.biSizeImage = image_size;
	self->Info.biCompression = BI_BITFIELDS;
	self->Info.biSize = sizeof(BITMAPINFOHEADER) + 4 * sizeof(uint32_t);
	if ( AlphaMask == 0x8000 ) {
		self->RedMask   = 0x7C00;
		self->GreenMask = 0x03E0;
		self->BlueMask  = 0x001F;
		self->AlphaMask = 0x8000;
	}
	else {
		self->RedMask   = 0x0F00;
		self->GreenMask = 0x00F0;
		self->BlueMask  = 0x000F;
		self->AlphaMask = 0xF000;
	}

	new_pixels = NULL;

	e=0;
fin:
	if ( new_pixels != NULL )  free( new_pixels );
	return  e;

err:     e = E_OTHERS;     goto fin;
err_fm:  e = E_FEW_MEMORY;  goto fin;
}


 
/***********************************************************************
  <<< [BmpFile2Class_convertToARGB4444Format] >>> 
************************************************************************/
errnum_t  BmpFile2Class_convertToARGB4444Format( BmpFile2Class* self )
{
	return  BmpFile2Class_convertTo16bitARGBFormat( self, 0xF000 );
}


 
/***********************************************************************
  <<< [BmpFile2Class_convertToA4Format] >>> 
************************************************************************/
errnum_t  BmpFile2Class_convertToA4Format( BmpFile2Class* self )
{
	errnum_t  e;
	uint32_t  image_size;
	uint8_t*  new_pixels = NULL;
	unsigned  stride24;
	unsigned  stride4;
	uint8_t*  src;  // source
	uint8_t*  dst;  // destination
	uint8_t*  src_line_head;
	uint8_t*  dst_line_head;
	int       src_line_tail_offset;
	int       dst_line_tail_offset;
	const bool  is_width_odd = ( self->Info.biWidth % 2 == 1 );

	ASSERT_R( self->Info.biBitCount == 24, goto err );
	ASSERT_R( self->Stride * self->Info.biHeight == self->Info.biSizeImage, goto err );

	stride24 = self->Stride;
	stride4  = ( self->Info.biWidth + 1 ) / 2;
	stride4  = ( stride4 + 3 ) & ~0x3;  // 4byte alignment

	image_size = stride4 * self->Info.biHeight;
	new_pixels = (uint8_t*) malloc( image_size );  IF(new_pixels==NULL)goto err_fm;

	src_line_head = self->Pixels + stride24 * (self->Info.biHeight - 1);
	dst_line_head = new_pixels   + stride4  * (self->Info.biHeight - 1);
	src_line_tail_offset = (self->Info.biWidth - 1) * (24/8);
	dst_line_tail_offset = (self->Info.biWidth - 1) * 4 / 8;
	do {
		src = src_line_head + src_line_tail_offset;
		dst = dst_line_head + dst_line_tail_offset;

		*(uint32_t*)( dst_line_head + stride4 - sizeof(uint32_t) ) = 0;  // padding

		if ( is_width_odd ) {
			*dst = *( src + 1 ) & 0xF0;  // Green
			src -= (24/8);
			dst -= 1;
		}
		while ( src >= src_line_head ) {
			*dst = ( *( src - 2 ) & 0xF0 ) | ( *( src + 1 ) >> 4 );  // Green
			src -= 2*(24/8);
			dst -= 1;
		}

		src_line_head -= stride24;
		dst_line_head -= stride4;
	} while ( dst_line_head >= new_pixels );

	self->Pixels = new_pixels;
	self->Info.biBitCount = 4;
	self->Stride = stride4;
	self->Info.biSizeImage = image_size;
	new_pixels = NULL;

	e=0;
fin:
	if ( new_pixels != NULL )  free( new_pixels );
	return  e;

err:     e = E_OTHERS;     goto fin;
err_fm:  e = E_FEW_MEMORY;  goto fin;
}


 
/***********************************************************************
  <<< [BmpFile2Class_convertToA1Format] >>> 
************************************************************************/
errnum_t  BmpFile2Class_convertToA1Format( BmpFile2Class* self )
{
	errnum_t  e;
	uint32_t  image_size;
	uint8_t*  new_pixels = NULL;
	unsigned  stride24;
	unsigned  stride1;
	uint8_t*  src;  // source
	uint8_t*  dst;  // destination
	uint8_t*  src_line_head;
	uint8_t*  dst_line_head;
	int       src_line_tail_offset;
	int       dst_line_tail_offset;
	const int width_mod = self->Info.biWidth % 8;
	int       x_mod;
	uint8_t   bits;

	ASSERT_R( self->Info.biBitCount == 24, goto err );
	ASSERT_R( self->Stride * self->Info.biHeight == self->Info.biSizeImage, goto err );

	stride24 = self->Stride;
	stride1  = ( self->Info.biWidth + 7 ) / 8;
	stride1  = ( stride1 + 3 ) & ~0x3;  // 4byte alignment

	image_size = stride1 * self->Info.biHeight;
	new_pixels = (uint8_t*) malloc( image_size );  IF(new_pixels==NULL)goto err_fm;

	src_line_head = self->Pixels + stride24 * (self->Info.biHeight - 1);
	dst_line_head = new_pixels   + stride1  * (self->Info.biHeight - 1);
	src_line_tail_offset = (self->Info.biWidth - 1) * (24/8);
	dst_line_tail_offset = (self->Info.biWidth - 1) / 8;
	do {
		src = src_line_head + src_line_tail_offset;
		dst = dst_line_head + dst_line_tail_offset;

		*(uint32_t*)( dst_line_head + stride1 - sizeof(uint32_t) ) = 0;  // padding

		if ( width_mod > 0 ) {
			bits = 0;
			for ( x_mod = width_mod - 1;  x_mod >= 0;  x_mod -= 1 ) {
				bits |= ( *( src + 1 ) & 0x80 ) >> x_mod;  // Green
				src -= (24/8);
			}
			*dst = bits;
			dst -= 1;
		}
		while ( src >= src_line_head ) {
			*dst =
				( *( src + 1 ) & 0x80 ) >> 7 |  // Green
				( *( src - 2 ) & 0x80 ) >> 6 |
				( *( src - 5 ) & 0x80 ) >> 5 |
				( *( src - 8 ) & 0x80 ) >> 4 |
				( *( src -11 ) & 0x80 ) >> 3 |
				( *( src -14 ) & 0x80 ) >> 2 |
				( *( src -17 ) & 0x80 ) >> 1 |
				( *( src -20 ) & 0x80 );

			src -= 8*(24/8);
			dst -= 1;
		}
		src_line_head -= stride24;
		dst_line_head -= stride1;
	} while ( dst_line_head >= new_pixels );

	self->Pixels = new_pixels;
	self->Info.biBitCount = 1;
	self->Stride = stride1;
	self->Info.biSizeImage = image_size;
	new_pixels = NULL;

	e=0;
fin:
	if ( new_pixels != NULL )  free( new_pixels );
	return  e;

err:     e = E_OTHERS;     goto fin;
err_fm:  e = E_FEW_MEMORY;  goto fin;
}


 
/***********************************************************************
  <<< [BmpFile2Class_trimming] >>> 
************************************************************************/
errnum_t  BmpFile2Class_trimming( BmpFile2Class* self, int LeftX, int TopY, int Width, int Height )
{
	errnum_t  e;
	uint8_t*  source_left;
	uint8_t*  source_left_over;
	uint8_t*  destination_left;
	int       new_stride;
	int       padding_size;
	int       height_abs;


	if ( self->Info.biHeight > 0 ) {
		TopY = self->Info.biHeight - ( TopY + Height );
		height_abs = self->Info.biHeight;
	} else {
		height_abs = - self->Info.biHeight;
	}

	ASSERT_R( Width >= 0  &&  Height >= 0,  e=E_OTHERS; goto fin );
	ASSERT_R( LeftX >= 0  &&  LeftX + Width  <= self->Info.biWidth,  e=E_OTHERS; goto fin );
	ASSERT_R( TopY  >= 0  &&  TopY  + Height <= height_abs,  e=E_OTHERS; goto fin );

	source_left = self->Pixels + self->Stride * TopY + LeftX * self->Info.biBitCount / 8;
	source_left_over = source_left + self->Stride * height_abs;
	destination_left = self->Pixels;

	if ( self->Info.biBitCount == 16 ) {
		new_stride = ceil_4( Width * 2 );
		padding_size = mod_2( Width ) * 2;
	} else {
		IF ( self->Info.biBitCount != 32 ) { e=E_OTHERS; goto fin; }
		new_stride = Width * 4;
		padding_size = 0;
	}

	while ( source_left < source_left_over ) {
		memcpy( destination_left, source_left, new_stride );
		source_left      += self->Stride;
		destination_left += new_stride;
		memset( destination_left - padding_size,  0x00,  padding_size );
	}

	self->Info.biWidth = Width;
	if ( self->Info.biHeight >= 0 )
		{ self->Info.biHeight = Height; }
	else
		{ self->Info.biHeight = - Height; }
	self->Stride = new_stride;

	e=0;
fin:
	return  e;
}


 
