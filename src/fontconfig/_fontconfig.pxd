cdef extern from "fontconfig/fontconfig.h":

    ctypedef unsigned char FcChar8

    ctypedef unsigned short FcChar16

    ctypedef unsigned int FcChar32

    ctypedef int FcBool

    cpdef enum _FcType:
        FcTypeUnknown
        FcTypeVoid
        FcTypeInteger
        FcTypeDouble
        FcTypeString
        FcTypeBool
        FcTypeMatrix
        FcTypeCharSet
        FcTypeFTFace
        FcTypeLangSet
        FcTypeRange

    ctypedef _FcType FcType

    cdef struct _FcMatrix:
        double xx
        double xy
        double yx
        double yy

    ctypedef _FcMatrix FcMatrix

    cdef struct _FcCharSet:
        pass

    ctypedef _FcCharSet FcCharSet

    cdef struct _FcObjectType:
        char* object
        FcType type

    ctypedef _FcObjectType FcObjectType

    cdef struct _FcConstant:
        const FcChar8* name
        const char* object
        int value

    ctypedef _FcConstant FcConstant

    cpdef enum _FcResult:
        FcResultMatch
        FcResultNoMatch
        FcResultTypeMismatch
        FcResultNoId
        FcResultOutOfMemory

    ctypedef _FcResult FcResult

    cpdef enum _FcValueBinding:
        FcValueBindingWeak
        FcValueBindingStrong
        FcValueBindingSame
        FcValueBindingEnd

    ctypedef _FcValueBinding FcValueBinding

    cdef struct _FcPattern:
        pass

    ctypedef _FcPattern FcPattern

    cdef struct _FcPatternIter:
        void* dummy1
        void* dummy2

    ctypedef _FcPatternIter FcPatternIter

    cdef struct _FcLangSet:
        pass

    ctypedef _FcLangSet FcLangSet

    cdef struct _FcRange:
        pass

    ctypedef _FcRange FcRange

    cdef union _FcValue_FcValue__FcValue_u_u:
        const FcChar8* s
        int i
        FcBool b
        double d
        const FcMatrix* m
        const FcCharSet* c
        void* f
        const FcLangSet* l
        const FcRange* r

    cdef struct _FcValue:
        FcType type
        _FcValue_FcValue__FcValue_u_u u

    ctypedef _FcValue FcValue

    cdef struct _FcFontSet:
        int nfont
        int sfont
        FcPattern** fonts

    ctypedef _FcFontSet FcFontSet

    cdef struct _FcObjectSet:
        int nobject
        int sobject
        const char** objects

    ctypedef _FcObjectSet FcObjectSet

    cpdef enum _FcMatchKind:
        FcMatchPattern
        FcMatchFont
        FcMatchScan
        FcMatchKindEnd
        FcMatchKindBegin

    ctypedef _FcMatchKind FcMatchKind

    cpdef enum _FcLangResult:
        FcLangEqual
        FcLangDifferentCountry
        FcLangDifferentTerritory
        FcLangDifferentLang

    ctypedef _FcLangResult FcLangResult

    cpdef enum _FcSetName:
        FcSetSystem
        FcSetApplication

    ctypedef _FcSetName FcSetName

    cdef struct _FcConfigFileInfoIter:
        void* dummy1
        void* dummy2
        void* dummy3

    ctypedef _FcConfigFileInfoIter FcConfigFileInfoIter

    cdef struct _FcAtomic:
        pass

    ctypedef _FcAtomic FcAtomic

    ctypedef enum FcEndian:
        FcEndianBig
        FcEndianLittle

    cdef struct _FcConfig:
        pass

    ctypedef _FcConfig FcConfig

    cdef struct _FcGlobalCache:
        pass

    ctypedef _FcGlobalCache FcFileCache

    cdef struct _FcBlanks:
        pass

    ctypedef _FcBlanks FcBlanks

    cdef struct _FcStrList:
        pass

    ctypedef _FcStrList FcStrList

    cdef struct _FcStrSet:
        pass

    ctypedef _FcStrSet FcStrSet

    cdef struct _FcCache:
        pass

    ctypedef _FcCache FcCache

    FcBlanks* FcBlanksCreate()

    void FcBlanksDestroy(FcBlanks* b)

    FcBool FcBlanksAdd(FcBlanks* b, FcChar32 ucs4)

    FcBool FcBlanksIsMember(FcBlanks* b, FcChar32 ucs4)

    const FcChar8* FcCacheDir(const FcCache* c)

    FcFontSet* FcCacheCopySet(const FcCache* c)

    const FcChar8* FcCacheSubdir(const FcCache* c, int i)

    int FcCacheNumSubdir(const FcCache* c)

    int FcCacheNumFont(const FcCache* c)

    FcBool FcDirCacheUnlink(const FcChar8* dir, FcConfig* config)

    FcBool FcDirCacheValid(const FcChar8* cache_file)

    FcBool FcDirCacheClean(const FcChar8* cache_dir, FcBool verbose)

    void FcCacheCreateTagFile(FcConfig* config)

    FcBool FcDirCacheCreateUUID(FcChar8* dir, FcBool force, FcConfig* config)

    FcBool FcDirCacheDeleteUUID(const FcChar8* dir, FcConfig* config)

    FcChar8* FcConfigHome()

    FcBool FcConfigEnableHome(FcBool enable)

    FcChar8* FcConfigGetFilename(FcConfig* config, const FcChar8* url)

    FcChar8* FcConfigFilename(const FcChar8* url)

    FcConfig* FcConfigCreate()

    FcConfig* FcConfigReference(FcConfig* config)

    void FcConfigDestroy(FcConfig* config)

    FcBool FcConfigSetCurrent(FcConfig* config)

    FcConfig* FcConfigGetCurrent()

    FcBool FcConfigUptoDate(FcConfig* config)

    FcBool FcConfigBuildFonts(FcConfig* config)

    FcStrList* FcConfigGetFontDirs(FcConfig* config)

    FcStrList* FcConfigGetConfigDirs(FcConfig* config)

    FcStrList* FcConfigGetConfigFiles(FcConfig* config)

    FcChar8* FcConfigGetCache(FcConfig* config)

    FcBlanks* FcConfigGetBlanks(FcConfig* config)

    FcStrList* FcConfigGetCacheDirs(FcConfig* config)

    int FcConfigGetRescanInterval(FcConfig* config)

    FcBool FcConfigSetRescanInterval(FcConfig* config, int rescanInterval)

    FcFontSet* FcConfigGetFonts(FcConfig* config, FcSetName set)

    FcBool FcConfigAppFontAddFile(FcConfig* config, const FcChar8* file)

    FcBool FcConfigAppFontAddDir(FcConfig* config, const FcChar8* dir)

    void FcConfigAppFontClear(FcConfig* config)

    FcBool FcConfigSubstituteWithPat(FcConfig* config, FcPattern* p, FcPattern* p_pat, FcMatchKind kind)

    FcBool FcConfigSubstitute(FcConfig* config, FcPattern* p, FcMatchKind kind)

    const FcChar8* FcConfigGetSysRoot(const FcConfig* config)

    void FcConfigSetSysRoot(FcConfig* config, const FcChar8* sysroot)

    void FcConfigFileInfoIterInit(FcConfig* config, FcConfigFileInfoIter* iter)

    FcBool FcConfigFileInfoIterNext(FcConfig* config, FcConfigFileInfoIter* iter)

    FcBool FcConfigFileInfoIterGet(FcConfig* config, FcConfigFileInfoIter* iter, FcChar8** name, FcChar8** description, FcBool* enabled)

    FcCharSet* FcCharSetCreate()

    FcCharSet* FcCharSetNew()

    void FcCharSetDestroy(FcCharSet* fcs)

    FcBool FcCharSetAddChar(FcCharSet* fcs, FcChar32 ucs4)

    FcBool FcCharSetDelChar(FcCharSet* fcs, FcChar32 ucs4)

    FcCharSet* FcCharSetCopy(FcCharSet* src)

    FcBool FcCharSetEqual(const FcCharSet* a, const FcCharSet* b)

    FcCharSet* FcCharSetIntersect(const FcCharSet* a, const FcCharSet* b)

    FcCharSet* FcCharSetUnion(const FcCharSet* a, const FcCharSet* b)

    FcCharSet* FcCharSetSubtract(const FcCharSet* a, const FcCharSet* b)

    FcBool FcCharSetMerge(FcCharSet* a, const FcCharSet* b, FcBool* changed)

    FcBool FcCharSetHasChar(const FcCharSet* fcs, FcChar32 ucs4)

    FcChar32 FcCharSetCount(const FcCharSet* a)

    FcChar32 FcCharSetIntersectCount(const FcCharSet* a, const FcCharSet* b)

    FcChar32 FcCharSetSubtractCount(const FcCharSet* a, const FcCharSet* b)

    FcBool FcCharSetIsSubset(const FcCharSet* a, const FcCharSet* b)

    FcChar32 FcCharSetFirstPage(const FcCharSet* a, FcChar32 map[], FcChar32* next)

    FcChar32 FcCharSetNextPage(const FcCharSet* a, FcChar32 map[], FcChar32* next)

    FcChar32 FcCharSetCoverage(const FcCharSet* a, FcChar32 page, FcChar32* result)

    void FcValuePrint(const FcValue v)

    void FcPatternPrint(const FcPattern* p)

    void FcFontSetPrint(const FcFontSet* s)

    FcStrSet* FcGetDefaultLangs()

    void FcDefaultSubstitute(FcPattern* pattern)

    FcBool FcFileIsDir(const FcChar8* file)

    FcBool FcFileScan(FcFontSet* set, FcStrSet* dirs, FcFileCache* cache, FcBlanks* blanks, const FcChar8* file, FcBool force)

    FcBool FcDirScan(FcFontSet* set, FcStrSet* dirs, FcFileCache* cache, FcBlanks* blanks, const FcChar8* dir, FcBool force)

    FcBool FcDirSave(FcFontSet* set, FcStrSet* dirs, const FcChar8* dir)

    FcCache* FcDirCacheLoad(const FcChar8* dir, FcConfig* config, FcChar8** cache_file)

    FcCache* FcDirCacheRescan(const FcChar8* dir, FcConfig* config)

    FcCache* FcDirCacheRead(const FcChar8* dir, FcBool force, FcConfig* config)

    cdef struct stat:
        pass

    FcCache* FcDirCacheLoadFile(const FcChar8* cache_file, stat* file_stat)

    void FcDirCacheUnload(FcCache* cache)

    FcPattern* FcFreeTypeQuery(const FcChar8* file, unsigned int id, FcBlanks* blanks, int* count)

    unsigned int FcFreeTypeQueryAll(const FcChar8* file, unsigned int id, FcBlanks* blanks, int* count, FcFontSet* set)

    FcFontSet* FcFontSetCreate()

    void FcFontSetDestroy(FcFontSet* s)

    FcBool FcFontSetAdd(FcFontSet* s, FcPattern* font)

    FcConfig* FcInitLoadConfig()

    FcConfig* FcInitLoadConfigAndFonts()

    FcBool FcInit()

    void FcFini()

    int FcGetVersion()

    FcBool FcInitReinitialize()

    FcBool FcInitBringUptoDate()

    FcStrSet* FcGetLangs()

    FcChar8* FcLangNormalize(const FcChar8* lang)

    const FcCharSet* FcLangGetCharSet(const FcChar8* lang)

    FcLangSet* FcLangSetCreate()

    void FcLangSetDestroy(FcLangSet* ls)

    FcLangSet* FcLangSetCopy(const FcLangSet* ls)

    FcBool FcLangSetAdd(FcLangSet* ls, const FcChar8* lang)

    FcBool FcLangSetDel(FcLangSet* ls, const FcChar8* lang)

    FcLangResult FcLangSetHasLang(const FcLangSet* ls, const FcChar8* lang)

    FcLangResult FcLangSetCompare(const FcLangSet* lsa, const FcLangSet* lsb)

    FcBool FcLangSetContains(const FcLangSet* lsa, const FcLangSet* lsb)

    FcBool FcLangSetEqual(const FcLangSet* lsa, const FcLangSet* lsb)

    FcChar32 FcLangSetHash(const FcLangSet* ls)

    FcStrSet* FcLangSetGetLangs(const FcLangSet* ls)

    FcLangSet* FcLangSetUnion(const FcLangSet* a, const FcLangSet* b)

    FcLangSet* FcLangSetSubtract(const FcLangSet* a, const FcLangSet* b)

    FcObjectSet* FcObjectSetCreate()

    FcBool FcObjectSetAdd(FcObjectSet* os, const char* object)

    void FcObjectSetDestroy(FcObjectSet* os)

    ctypedef struct va_list:
        pass

    FcObjectSet* FcObjectSetVaBuild(const char* first, va_list va)

    FcObjectSet* FcObjectSetBuild(const char* first, ...)

    FcFontSet* FcFontSetList(FcConfig* config, FcFontSet** sets, int nsets, FcPattern* p, FcObjectSet* os)

    FcFontSet* FcFontList(FcConfig* config, FcPattern* p, FcObjectSet* os)

    FcAtomic* FcAtomicCreate(const FcChar8* file)

    FcBool FcAtomicLock(FcAtomic* atomic)

    FcChar8* FcAtomicNewFile(FcAtomic* atomic)

    FcChar8* FcAtomicOrigFile(FcAtomic* atomic)

    FcBool FcAtomicReplaceOrig(FcAtomic* atomic)

    void FcAtomicDeleteNew(FcAtomic* atomic)

    void FcAtomicUnlock(FcAtomic* atomic)

    void FcAtomicDestroy(FcAtomic* atomic)

    FcPattern* FcFontSetMatch(FcConfig* config, FcFontSet** sets, int nsets, FcPattern* p, FcResult* result)

    FcPattern* FcFontMatch(FcConfig* config, FcPattern* p, FcResult* result)

    FcPattern* FcFontRenderPrepare(FcConfig* config, FcPattern* pat, FcPattern* font)

    FcFontSet* FcFontSetSort(FcConfig* config, FcFontSet** sets, int nsets, FcPattern* p, FcBool trim, FcCharSet** csp, FcResult* result)

    FcFontSet* FcFontSort(FcConfig* config, FcPattern* p, FcBool trim, FcCharSet** csp, FcResult* result)

    void FcFontSetSortDestroy(FcFontSet* fs)

    FcMatrix* FcMatrixCopy(const FcMatrix* mat)

    FcBool FcMatrixEqual(const FcMatrix* mat1, const FcMatrix* mat2)

    void FcMatrixMultiply(FcMatrix* result, const FcMatrix* a, const FcMatrix* b)

    void FcMatrixRotate(FcMatrix* m, double c, double s)

    void FcMatrixScale(FcMatrix* m, double sx, double sy)

    void FcMatrixShear(FcMatrix* m, double sh, double sv)

    FcBool FcNameRegisterObjectTypes(const FcObjectType* types, int ntype)

    FcBool FcNameUnregisterObjectTypes(const FcObjectType* types, int ntype)

    const FcObjectType* FcNameGetObjectType(const char* object)

    FcBool FcNameRegisterConstants(const FcConstant* consts, int nconsts)

    FcBool FcNameUnregisterConstants(const FcConstant* consts, int nconsts)

    const FcConstant* FcNameGetConstant(const FcChar8* string)

    const FcConstant* FcNameGetConstantFor(const FcChar8* string, const char* object)

    FcBool FcNameConstant(const FcChar8* string, int* result)

    FcPattern* FcNameParse(const FcChar8* name)

    FcChar8* FcNameUnparse(FcPattern* pat)

    FcPattern* FcPatternCreate()

    FcPattern* FcPatternDuplicate(const FcPattern* p)

    void FcPatternReference(FcPattern* p)

    FcPattern* FcPatternFilter(FcPattern* p, const FcObjectSet* os)

    void FcValueDestroy(FcValue v)

    FcBool FcValueEqual(FcValue va, FcValue vb)

    FcValue FcValueSave(FcValue v)

    void FcPatternDestroy(FcPattern* p)

    int FcPatternObjectCount(const FcPattern* pat)

    FcBool FcPatternEqual(const FcPattern* pa, const FcPattern* pb)

    FcBool FcPatternEqualSubset(const FcPattern* pa, const FcPattern* pb, const FcObjectSet* os)

    FcChar32 FcPatternHash(const FcPattern* p)

    FcBool FcPatternAdd(FcPattern* p, const char* object, FcValue value, FcBool append)

    FcBool FcPatternAddWeak(FcPattern* p, const char* object, FcValue value, FcBool append)

    FcResult FcPatternGet(const FcPattern* p, const char* object, int id, FcValue* v)

    FcResult FcPatternGetWithBinding(const FcPattern* p, const char* object, int id, FcValue* v, FcValueBinding* b)

    FcBool FcPatternDel(FcPattern* p, const char* object)

    FcBool FcPatternRemove(FcPattern* p, const char* object, int id)

    FcBool FcPatternAddInteger(FcPattern* p, const char* object, int i)

    FcBool FcPatternAddDouble(FcPattern* p, const char* object, double d)

    FcBool FcPatternAddString(FcPattern* p, const char* object, const FcChar8* s)

    FcBool FcPatternAddMatrix(FcPattern* p, const char* object, const FcMatrix* s)

    FcBool FcPatternAddCharSet(FcPattern* p, const char* object, const FcCharSet* c)

    FcBool FcPatternAddBool(FcPattern* p, const char* object, FcBool b)

    FcBool FcPatternAddLangSet(FcPattern* p, const char* object, const FcLangSet* ls)

    FcBool FcPatternAddRange(FcPattern* p, const char* object, const FcRange* r)

    FcResult FcPatternGetInteger(const FcPattern* p, const char* object, int n, int* i)

    FcResult FcPatternGetDouble(const FcPattern* p, const char* object, int n, double* d)

    FcResult FcPatternGetString(const FcPattern* p, const char* object, int n, FcChar8** s)

    FcResult FcPatternGetMatrix(const FcPattern* p, const char* object, int n, FcMatrix** s)

    FcResult FcPatternGetCharSet(const FcPattern* p, const char* object, int n, FcCharSet** c)

    FcResult FcPatternGetBool(const FcPattern* p, const char* object, int n, FcBool* b)

    FcResult FcPatternGetLangSet(const FcPattern* p, const char* object, int n, FcLangSet** ls)

    FcResult FcPatternGetRange(const FcPattern* p, const char* object, int id, FcRange** r)

    FcPattern* FcPatternVaBuild(FcPattern* p, va_list va)

    FcPattern* FcPatternBuild(FcPattern* p)

    FcChar8* FcPatternFormat(FcPattern* pat, const FcChar8* format)

    FcRange* FcRangeCreateDouble(double begin, double end)

    FcRange* FcRangeCreateInteger(FcChar32 begin, FcChar32 end)

    void FcRangeDestroy(FcRange* range)

    FcRange* FcRangeCopy(const FcRange* r)

    FcBool FcRangeGetDouble(const FcRange* range, double* begin, double* end)

    void FcPatternIterStart(const FcPattern* pat, FcPatternIter* iter)

    FcBool FcPatternIterNext(const FcPattern* pat, FcPatternIter* iter)

    FcBool FcPatternIterEqual(const FcPattern* p1, FcPatternIter* i1, const FcPattern* p2, FcPatternIter* i2)

    FcBool FcPatternFindIter(const FcPattern* pat, FcPatternIter* iter, const char* object)

    FcBool FcPatternIterIsValid(const FcPattern* pat, FcPatternIter* iter)

    const char* FcPatternIterGetObject(const FcPattern* pat, FcPatternIter* iter)

    int FcPatternIterValueCount(const FcPattern* pat, FcPatternIter* iter)

    FcResult FcPatternIterGetValue(const FcPattern* pat, FcPatternIter* iter, int id, FcValue* v, FcValueBinding* b)

    int FcWeightFromOpenType(int ot_weight)

    double FcWeightFromOpenTypeDouble(double ot_weight)

    int FcWeightToOpenType(int fc_weight)

    double FcWeightToOpenTypeDouble(double fc_weight)

    FcChar8* FcStrCopy(const FcChar8* s)

    FcChar8* FcStrCopyFilename(const FcChar8* s)

    FcChar8* FcStrPlus(const FcChar8* s1, const FcChar8* s2)

    void FcStrFree(FcChar8* s)

    FcChar8* FcStrDowncase(const FcChar8* s)

    int FcStrCmpIgnoreCase(const FcChar8* s1, const FcChar8* s2)

    int FcStrCmp(const FcChar8* s1, const FcChar8* s2)

    const FcChar8* FcStrStrIgnoreCase(const FcChar8* s1, const FcChar8* s2)

    const FcChar8* FcStrStr(const FcChar8* s1, const FcChar8* s2)

    int FcUtf8ToUcs4(const FcChar8* src_orig, FcChar32* dst, int len)

    FcBool FcUtf8Len(const FcChar8* string, int len, int* nchar, int* wchar)

    int FcUcs4ToUtf8(FcChar32 ucs4, FcChar8 dest[6])

    int FcUtf16ToUcs4(const FcChar8* src_orig, FcEndian endian, FcChar32* dst, int len)

    FcBool FcUtf16Len(const FcChar8* string, FcEndian endian, int len, int* nchar, int* wchar)

    FcChar8* FcStrBuildFilename(const FcChar8* path)

    FcChar8* FcStrDirname(const FcChar8* file)

    FcChar8* FcStrBasename(const FcChar8* file)

    FcStrSet* FcStrSetCreate()

    FcBool FcStrSetMember(FcStrSet* set, const FcChar8* s)

    FcBool FcStrSetEqual(FcStrSet* sa, FcStrSet* sb)

    FcBool FcStrSetAdd(FcStrSet* set, const FcChar8* s)

    FcBool FcStrSetAddFilename(FcStrSet* set, const FcChar8* s)

    FcBool FcStrSetDel(FcStrSet* set, const FcChar8* s)

    void FcStrSetDestroy(FcStrSet* set)

    FcStrList* FcStrListCreate(FcStrSet* set)

    void FcStrListFirst(FcStrList* list)

    FcChar8* FcStrListNext(FcStrList* list)

    void FcStrListDone(FcStrList* list)

    FcBool FcConfigParseAndLoad(FcConfig* config, const FcChar8* file, FcBool complain)

    FcBool FcConfigParseAndLoadFromMemory(FcConfig* config, const FcChar8* buffer, FcBool complain)
