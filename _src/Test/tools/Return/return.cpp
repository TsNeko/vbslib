#include <tchar.h> 
#include <stdlib.h>

int _tmain(int argc, _TCHAR* argv[])
{
  if ( argc == 1 )  *(char*)0 = 1;  /* exception */
	return  _ttoi( argv[1] );
}

 
