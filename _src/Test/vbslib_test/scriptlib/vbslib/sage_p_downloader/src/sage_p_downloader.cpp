#include  <windows.h> 
#include  <tchar.h>
#include  <stdio.h>

typedef int  errnum_t;

#if ! NDEBUG
	int  g_DisableDebugBreak;
	#define  IF(x)   if((x)&&(!g_DisableDebugBreak)&&(DebugBreak(),1))
#else
	#define  IF(x)   if(x)
#endif


char*  g_ApplicationName = "sage_p_downloader";
HWND   g_MainWindow = NULL;

int  DownloadByHttp( char* url, char* out_path );


errnum_t  main( int argc, char* argv[] )
{
	errnum_t  e;
	bool   b_pass;
	char*  domain;
	char*  download_URL;
	char*  save_path;

	if ( argc != 3 ) {
		printf( "ERROR: parameter count\n" );
		printf( "sage_p_downloader.exe (url) (path)\n" );
		fflush( stdout );
		Sleep( 3000 );
		return  1;
	}

	download_URL = argv[1];
	save_path =  argv[2];

	b_pass = false;
	domain = "http://www5a.biglobe.ne.jp/~sage-p/";
	if ( strncmp( download_URL, domain, strlen( domain ) ) == 0 )  b_pass = true;
	domain = "http://www.sage-p.com/";
	if ( strncmp( download_URL, domain, strlen( domain ) ) == 0 )  b_pass = true;

	printf( "Download from  %s\n", download_URL );
	printf( "Saving to \"%s\"\n",  save_path );
	if ( ! b_pass ) {
		char  message[0x100];

		_stprintf_s( message, _countof( message ),
			_T("%s\nこのダウンロードに心当たりが無ければ、直ちに閉じてください。\n")
			_T("続行しますか。"),
			download_URL );
		if ( MessageBox( g_MainWindow, message, g_ApplicationName, MB_YESNO ) == IDNO ) {
			return  1;
		}
	}

	e= DownloadByHttp( download_URL, save_path );

	Sleep( 2000 );
	return  e;
}

 
#import  "msxml3.dll"
#import  "C:\Program Files\Common Files\System\ado\msado15.dll"  no_namespace rename("EOF", "EndOfFile")
_variant_t  vtEmpty( DISP_E_PARAMNOTFOUND, VT_ERROR );
using namespace MSXML2;


errnum_t  DownloadByHttp( char* url, char* out_path )
{
	errnum_t  e;
	HRESULT   hr;

	CoInitialize( NULL );

	for (;;) {
		try {
			IXMLHTTPRequestPtr  req;  // http://msdn.microsoft.com/en-us/library/ms759148(VS.85).aspx
			_StreamPtr          st;   // http://msdn.microsoft.com/en-us/library/ms675032(VS.85).aspx

			hr= req.CreateInstance( "Msxml2.XMLHTTP" );  IF(hr)goto err;
			hr= req->open( "GET", url, false );  IF(hr)goto err;
			hr= req->send();  IF(hr)goto err;
			IF ( req->status != 200 ) goto err;

			hr= st.CreateInstance( __uuidof(Stream) );  IF(hr)goto err;
			st->Type = adTypeBinary;
			hr= st->Open( vtEmpty, adModeUnknown, adOpenStreamUnspecified, _bstr_t(""), _bstr_t("") );  IF(hr)goto err;
			hr= st->Write( req->responseBody );  IF(hr)goto err;
			hr= st->SaveToFile( _bstr_t( out_path ), adSaveCreateOverWrite );  IF(hr)goto err;
			hr= st->Close();  IF(hr)goto err;

			e=0;
		}
		catch ( _com_error err ) {
			if ( err.Error() == 0x800C0005 ) {
				char  in[4];

				e = 2;
				printf( "ネットワークの接続に失敗したか、ウィルス対策ソフトによって拒否されました。\n" );
				printf( "再試行しますか。[Y/N]" );
				fflush( stdout );
				fgets( in, sizeof(in), stdin );
				if ( in[0] != 'Y' && in[0] != 'y' )
					e = 1;
			}
			else {
				_tprintf( _T("%s\n"), err.ErrorMessage() );
				e=1;
			}
		}
		if ( e != 2 ) break;
	}
fin:
	CoUninitialize();
	return  e;

err:  e=1;  goto fin;
}


