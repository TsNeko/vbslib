a
#ifdef  _SYMBOL_A
b
#endif
c
#ifndef  _SYMBOL_A
dddd
ddd
#endif
e
#ifdef  _SYMBOL_A
ff
#else
ggg
#endif
hh
#ifndef  _SYMBOL_A
iiii
#else
j
#endif

#ifdef  SYMBOL3
	#ifdef  _SYMBOL_A
		S1
	#else
		S2
	#endif
#else
	#ifndef  _SYMBOL_A
		S3
		S3
	#else
		S4
		S4
	#endif
#endif
