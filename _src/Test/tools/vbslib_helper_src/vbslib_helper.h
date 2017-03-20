#define  IsListUpUsingTxMxKeywords   1
#define  IsListUpTextShrinkKeywords  1

#if  IsListUpUsingTxMxKeywords


/***********************************************************************
  <<< [TxMxStateEnum] >>> 
************************************************************************/
typedef enum _TxMxStateEnum  TxMxStateEnum;
enum _TxMxStateEnum {
	TxMxState_NotUsed,
	TxMxState_UsedButNotSearched,
	TxMxState_UsedAndSearched
};


 
/***********************************************************************
* Constants: CharacterCodeSetEnum
*
*    : gc_CharacterCodeSetEnum_OEM          - 1
*    : gc_CharacterCodeSetEnum_UTF_8        - 2
*    : gc_CharacterCodeSetEnum_UTF_8_NoBOM  - 3
*    : gc_CharacterCodeSetEnum_UTF_16       - 4
*    : gc_CharacterCodeSetEnum_XML          - 5
*    : gc_CharacterCodeSetEnum_Unknown      - 9
*****************************************************************************/
typedef enum _CharacterCodeSetEnum {
	gc_CharacterCodeSetEnum_OEM         = 1,
	gc_CharacterCodeSetEnum_UTF_8       = 2,
	gc_CharacterCodeSetEnum_UTF_8_NoBOM = 3,
	gc_CharacterCodeSetEnum_UTF_16      = 4,
	gc_CharacterCodeSetEnum_XML         = 5,
	gc_CharacterCodeSetEnum_Unknown     = 9
} CharacterCodeSetEnum;


 
/***********************************************************************
  <<< [TxScFileClass] >>> 
************************************************************************/
typedef struct _TxScFileClass  TxScFileClass;
struct _TxScFileClass {
	TCHAR*  TxScPath;    /* Has */
	TCHAR*  SourcePath;  /* Has */
	TCHAR*  Type;        /* Has */

	TCHAR*  Text;  /* File content */  /* Has */

	Set2    Sections;  /* <TxScSectionClass*> */
};

void      TxScFileClass_initConst( TxScFileClass* self );
errnum_t  TxScFileClass_finalize( TxScFileClass* self, errnum_t e );


 
/***********************************************************************
  <<< [TxScSectionClass] >>> 
************************************************************************/
typedef struct _TxScSectionClass  TxScSectionClass;
struct _TxScSectionClass {
	TCHAR*  Name;  /* Has */
	int     StartLineNum;
	int     EndLineNum;
	int     NextToHeaderLineNum;

	TxScFileClass*  File;
	TCHAR*  TextStart;     /* in ".File->Text" */
	TCHAR*  TextOver;      /* in ".File->Text" */
	TCHAR*  NextToHeader;  /* in ".File->Text" */
};

void      TxScSectionClass_initConst( TxScSectionClass* self );
errnum_t  TxScSectionClass_finalize( TxScSectionClass* self, errnum_t e );


 
/***********************************************************************
  <<< [TxScKeywordClass] >>> 
************************************************************************/
typedef struct _TxScKeywordClass  TxScKeywordClass;
struct _TxScKeywordClass {
	TxMxStateEnum                 State;
	Set2 /*<TxScSectionClass*>*/  Sections;

	bool               IsUsedFromProject;
	TCHAR*             CallerFilePath;
	TxScSectionClass*  CallerSection;
};

errnum_t  TxScKeywordClass_initialize( TxScKeywordClass* self );
errnum_t  TxScKeywordClass_finalize( TxScKeywordClass* self, errnum_t e );


 
/***********************************************************************
  <<< [TxMxListUpClass] Work of ListUpUsingTxMxKeywords >>> 
- TxMxListUpClass
  - TxScKeywordClass
    - TxScSectionClass
  - TxScFileClass
************************************************************************/
typedef struct _TxMxListUpClass  TxMxListUpClass;
struct _TxMxListUpClass {
	Set4  /*<TxScFileClass>*/     TxScFiles;
	Set4  /*<TxScSectionClass>*/  Sections;
	Strs                          CallerFiles;
	DictionaryAA_Class            NameDictionary; /*<TxScKeywordClass*>*/
	TCHAR**                       Keywords;  /* TCHAR* points in ".NameDictionary" */
	int                           KeywordsLength;
	Set2  /*<TCHAR*>*/            UseNames;  /* TCHAR* points in ".NameDictionary" */
	int                           NotSearchedNameIndex;  /* Index of ".UseNames" */
	SearchStringByAC_Class        NameSearcher;
};

/* Private */
errnum_t  TxMxListUpClass_getFileFromPath( TxMxListUpClass* self,
	TCHAR*  Path,  TxScFileClass*  out_File );
errnum_t  TxMxListUpClass_getSectionsFromName( TxMxListUpClass* self,
	TCHAR*  Name,  Set2*  out_Sections );


 
/***********************************************************************
  <<< [TxMxCallbackClass] >>> 
************************************************************************/
typedef struct _TxMxCallbackClass  TxMxCallbackClass;
struct _TxMxCallbackClass {
	TxMxListUpClass*  Work;
	TxScFileClass*    File;
};


 
#endif  // IsListUpUsingTxMxKeywords
