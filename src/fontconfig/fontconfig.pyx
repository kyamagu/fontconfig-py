import atexit
import logging
from typing import Any, Dict, Iterable, Iterator, List, Tuple

cimport fontconfig._fontconfig as c_impl


logger = logging.getLogger(__name__)

ctypedef Py_ssize_t intptr_t


def get_version() -> str:
    """Get fontconfig version."""
    version = c_impl.FcGetVersion()
    major = version / 10000
    minor = (version % 10000) / 100
    revision = version % 100
    return "%d.%d.%d" % (major, minor, revision)


cdef class Blanks:
    """
    A Blanks object holds a list of Unicode chars which are expected to be
    blank when drawn. When scanning new fonts, any glyphs which are empty and
    not in this list will be assumed to be broken and not placed in the
    FcCharSet associated with the font. This provides a significantly more
    accurate CharSet for applications.

    Blanks is deprecated and should not be used in newly written code. It is
    still accepted by some functions for compatibility with older code but will
    be removed in the future.
    """
    cdef c_impl.FcBlanks* _ptr

    def __cinit__(self, ptr: int):
        self._ptr = <c_impl.FcBlanks*>(<intptr_t>(ptr))

    def __dealloc__(self):
        if self._ptr is not NULL:
            c_impl.FcBlanksDestroy(self._ptr)

    cdef intptr_t ptr(self):
        return <intptr_t>self._ptr

    @classmethod
    def create(cls) -> Blanks:
        """Create a Blanks"""
        ptr = c_impl.FcBlanksCreate()
        if ptr is NULL:
            raise MemoryError()
        return cls(<intptr_t>ptr)

    def add(self, ucs4: int) -> bool:
        """Add a character to a Blanks"""
        return <bint>c_impl.FcBlanksAdd(self._ptr, <c_impl.FcChar32>ucs4)

    def is_member(self, ucs4: int) -> bool:
        """Query membership in a Blanks"""
        return <bint>c_impl.FcBlanksIsMember(self._ptr, <c_impl.FcChar32>ucs4)


cdef class Config:
    """A Config object holds the internal representation of a configuration.

    There is a default configuration which applications may use by passing 0 to
    any function using the data within a Config.

    Example::

        # List config content
        config = fontconfig.Config.get_current()
        for name, desc, enabled in config:
            if enabled:
                print(name)
                print(desc)

        # Query fonts from the current config
        pattern = fontconfig.Pattern.parse(":lang=en")
        object_set = fontconfig.ObjectSet.create()
        object_set.add("family")
        fonts = config.font_list(pattern, object_set)
    """
    cdef c_impl.FcConfig* _ptr
    cdef bint _owner

    def __cinit__(self, ptr: int, owner: bool = True):
        self._ptr = <c_impl.FcConfig*>(<intptr_t>(ptr))
        self._owner = owner

    def __dealloc__(self):
        if self._ptr is not NULL and self._owner:
            c_impl.FcConfigDestroy(self._ptr)

    cdef intptr_t ptr(self):
        return <intptr_t>self._ptr

    @classmethod
    def create(cls) -> Config:
        """Create a configuration"""
        ptr = c_impl.FcConfigCreate()
        if ptr is NULL:
            raise MemoryError()
        return cls(<intptr_t>ptr)

    def set_current(self) -> bool:
        """Set configuration as default"""
        return <bint>c_impl.FcConfigSetCurrent(self._ptr)

    @classmethod
    def get_current(cls) -> Config:
        """Return current configuration"""
        return cls(<intptr_t>c_impl.FcConfigGetCurrent(), False)

    def upto_date(self) -> bool:
        """Check timestamps on config files"""
        return <bint>c_impl.FcConfigUptoDate(self._ptr)

    @staticmethod
    def home() -> Optional[str]:
        """Return the current home directory"""
        cdef c_impl.FcChar8* result = c_impl.FcConfigHome()
        if result is NULL:
            return None
        return <bytes>(result).decode("utf-8")

    @staticmethod
    def enable_home(enable: bool) -> bool:
        """Controls use of the home directory"""
        return <bint>c_impl.FcConfigEnableHome(<c_impl.FcBool>(enable))

    def build_fonts(self) -> bool:
        """Build font database"""
        return <bint>c_impl.FcConfigBuildFonts(self._ptr)

    def get_config_dirs(self) -> List[str]:
        """Get config directories"""
        cdef c_impl.FcStrList* str_list = c_impl.FcConfigGetConfigDirs(self._ptr)
        results = _FcStrListToObject(str_list)
        c_impl.FcStrListDone(str_list)
        return results

    def get_font_dirs(self) -> List[str]:
        """Get font directories"""
        cdef c_impl.FcStrList* str_list = c_impl.FcConfigGetFontDirs(self._ptr)
        results = _FcStrListToObject(str_list)
        c_impl.FcStrListDone(str_list)
        return results

    def get_config_files(self) -> List[str]:
        """Get config files"""
        cdef c_impl.FcStrList* str_list = c_impl.FcConfigGetConfigFiles(self._ptr)
        results = _FcStrListToObject(str_list)
        c_impl.FcStrListDone(str_list)
        return results

    def get_cache_dirs(self) -> List[str]:
        """Return the list of directories searched for cache files"""
        cdef c_impl.FcStrList* str_list = c_impl.FcConfigGetCacheDirs(self._ptr)
        results = _FcStrListToObject(str_list)
        c_impl.FcStrListDone(str_list)
        return results

    def get_fonts(self, name: str = "system") -> FontSet:
        """Get config font set"""
        cdef c_impl.FcConfig* ptr
        cdef c_impl.FcFontSet* fonts
        cdef c_impl.FcSetName set_name

        names = {
            "system": c_impl.FcSetName.FcSetSystem,
            "application": c_impl.FcSetName.FcSetApplication,
        }
        if name not in names:
            raise KeyError("Invalid name: %s; must be system or application" % name)
        set_name = names[name]

        ptr = c_impl.FcConfigReference(self._ptr)
        fonts = c_impl.FcConfigGetFonts(ptr, set_name)
        c_impl.FcConfigDestroy(ptr)
        return FontSet(<intptr_t>fonts, owner=False)

    def get_rescan_interval(self) -> int:
        """Get config rescan interval"""
        return c_impl.FcConfigGetRescanInterval(self._ptr)

    def set_rescan_interval(self, interval: int) -> bool:
        """Set config rescan interval"""
        return <bint>c_impl.FcConfigSetRescanInterval(self._ptr, interval)

    def app_font_add_file(self, filename: str) -> bool:
        """Add font file to font database"""
        file_ = filename.encode("utf-8")
        return <bint>c_impl.FcConfigAppFontAddFile(
            self._ptr, <const c_impl.FcChar8*>(file_))

    def app_font_add_dir(self, dirname: str) -> bool:
        """Add fonts from directory to font database"""
        dir_ = dirname.encode("utf-8")
        return <bint>c_impl.FcConfigAppFontAddDir(
            self._ptr, <const c_impl.FcChar8*>(dir_))

    def app_font_clear(self) -> None:
        """Remove all app fonts from font database"""
        c_impl.FcConfigAppFontClear(self._ptr)

    def substitute_with_pat(
        self, p: Pattern, p_pat: Pattern, kind: str = "pattern") -> bool:
        """Execute substitutions"""
        cdef c_impl.FcMatchKind kind_

        kinds = {
            "pattern": c_impl.FcMatchPattern,
            "font": c_impl.FcMatchFont,
        }
        if kind not in kinds:
            raise KeyError("Invalid kind: %s" % kind)
        kind_ = kinds[kind]
        return c_impl.FcConfigSubstituteWithPat(self._ptr, p._ptr, p_pat._ptr, kind_)

    def substitute(self, p: Pattern, kind: str = "pattern") -> bool:
        """Execute substitutions"""
        cdef c_impl.FcMatchKind kind_

        kinds = {
            "pattern": c_impl.FcMatchPattern,
            "font": c_impl.FcMatchFont,
        }
        if kind not in kinds:
            raise KeyError("Invalid kind: %s" % kind)
        kind_ = kinds[kind]
        return c_impl.FcConfigSubstitute(self._ptr, p._ptr, kind_)

    def font_match(self, p: Pattern) -> Optional[Pattern]:
        """Return best font"""
        cdef c_impl.FcResult result
        cdef c_impl.FcPattern* ptr = c_impl.FcFontMatch(self._ptr, p._ptr, &result)
        if result == c_impl.FcResultMatch:
            return Pattern(<intptr_t>ptr)
        elif result == c_impl.FcResultNoMatch:
            return None
        elif result == c_impl.FcResultOutOfMemory:
            raise MemoryError()
        else:
            raise RuntimeError("Match result is %d" % result)

    def font_sort(self, p: Pattern, trim: bool) -> Optional[FontSet]:
        """Return list of matching fonts"""
        cdef c_impl.FcResult result
        cdef c_impl.FcFontSet* ptr = c_impl.FcFontSort(
            self._ptr, p._ptr, <c_impl.FcBool>trim, NULL, &result)
        # TODO: Support csp
        if result == c_impl.FcResultMatch:
            return FontSet(<intptr_t>ptr)
        elif result == c_impl.FcResultNoMatch:
            return None
        elif result == c_impl.FcResultOutOfMemory:
            raise MemoryError()
        else:
            raise RuntimeError("Sort result is %d" % result)

    def font_render_prepare(self, p: Pattern, font: Pattern) -> Pattern:
        """Prepare pattern for loading font file"""
        cdef c_impl.FcPattern* ptr = c_impl.FcFontRenderPrepare(
            self._ptr, p._ptr, font._ptr)
        if ptr is NULL:
            raise MemoryError()
        return Pattern(<intptr_t>ptr)

    def font_list(self, pattern: Pattern, object_set: ObjectSet) -> FontSet:
        """List fonts"""
        cdef c_impl.FcFontSet* ptr = c_impl.FcFontList(
            self._ptr, pattern._ptr, object_set._ptr)
        if ptr is NULL:
            raise MemoryError()
        return FontSet(<intptr_t>ptr)

    '''
    def get_filename(self, name: str = "") -> str:
        """Find a config file"""
        cdef bytes filename
        name_ = name.encode("utf-8")
        filename = <bytes>c_impl.FcConfigGetFilename(
            self._ptr, <const c_impl.FcChar8*>name_)
        return filename.decode("utf-8")
    '''

    def parse_and_load(self, filename: str, complain: bool = True) -> bool:
        """Load a configuration file"""
        cdef bytes filename_ = filename.encode("utf-8")
        return <bint>c_impl.FcConfigParseAndLoad(
            self._ptr, <c_impl.FcChar8*>filename_, <c_impl.FcBool>complain)

    def parse_and_load_from_memory(self, buffer: bytes, complain: bool = True) -> bool:
        """Load a configuration from memory"""
        return <bint>c_impl.FcConfigParseAndLoad(
            self._ptr, <c_impl.FcChar8*>buffer, <c_impl.FcBool>complain)

    def get_sysroot(self) -> Optional[str]:
        """Obtain the system root directory"""
        cdef const c_impl.FcChar8* sysroot
        ptr = c_impl.FcConfigReference(self._ptr)
        sysroot = c_impl.FcConfigGetSysRoot(self._ptr)
        if sysroot is NULL:
            filename = None
        else:
            filename = <bytes>(sysroot).decode("utf-8")
        c_impl.FcConfigDestroy(ptr)
        return filename

    def set_sysroot(self, sysroot: str) -> None:
        """Set the system root directory"""
        sysroot_ = sysroot.encode("utf-8")
        c_impl.FcConfigSetSysRoot(self._ptr, <c_impl.FcChar8*>sysroot_)

    def __iter__(self) -> Iterator[Tuple[str, str, bool]]:
        """Obtain the configuration file information"""
        cdef c_impl.FcConfigFileInfoIter iter
        cdef c_impl.FcChar8 *name, *desc
        cdef c_impl.FcBool enabled
        cdef c_impl.FcConfig* ptr = c_impl.FcConfigReference(self._ptr)
        c_impl.FcConfigFileInfoIter(ptr, &iter)
        while True:
            if <bint>c_impl.FcConfigFileInfoIterGet(ptr, &iter, &name, &desc, &enabled):
                yield (
                    <bytes>name.decode("utf-8"),
                    <bytes>desc.decode("utf-8"),
                    <bint>enabled,
                )
                c_impl.FcStrFree(name)
                c_impl.FcStrFree(desc)
            if not <bint>c_impl.FcConfigFileInfoIterNext(ptr, &iter):
                break
        c_impl.FcConfigDestroy(ptr)


cdef class CharSet:
    """A CharSet is a boolean array indicating a set of Unicode chars.

    Those associated with a font are marked constant and cannot be edited.
    FcCharSets may be reference counted internally to reduce memory consumption;
    this may be visible to applications as the result of FcCharSetCopy may
    return it's argument, and that CharSet may remain unmodifiable.
    """
    cdef c_impl.FcCharSet* _ptr

    def __cinit__(self, ptr: int):
        self._ptr = <c_impl.FcCharSet*>(<intptr_t>ptr)

    def __dealloc__(self):
        if self._ptr is not NULL:
            c_impl.FcCharSetDestroy(self._ptr)

    cdef intptr_t ptr(self):
        return <intptr_t>self._ptr

    @classmethod
    def create(cls) -> CharSet:
        """Create a charset"""
        ptr = c_impl.FcCharSetCreate()
        if ptr is NULL:
            raise MemoryError()
        return cls(<intptr_t>ptr)

    # TODO: Implement me!


cdef class Pattern:
    """A Pattern is an opaque type that holds both patterns to match against
    the available fonts, as well as the information about each font.

    Example::

        # Create a new pattern.
        pattern = fontconfig.Pattern.create()
        pattern.add("family", "Arial")

        # Create a new pattern from str.
        pattern = fontconfig.Pattern.parse(":lang=en:family=Arial")

        # Pattern is iterable. Can convert to a Python dict.
        pattern_dict = dict(pattern)
    """
    cdef c_impl.FcPattern* _ptr
    cdef bint _owner

    def __cinit__(self, ptr: int, owner: bool = True):
        self._ptr = <c_impl.FcPattern*>(<intptr_t>ptr)
        self._owner = owner

    def __dealloc__(self):
        if self._owner and self._ptr is not NULL:
            c_impl.FcPatternDestroy(self._ptr)

    cdef intptr_t ptr(self):
        return <intptr_t>self._ptr

    @classmethod
    def create(cls) -> Pattern:
        """Create a pattern"""
        ptr = c_impl.FcPatternCreate()
        if ptr is NULL:
            raise MemoryError()
        return cls(<intptr_t>ptr)

    def copy(self) -> Pattern:
        """Copy a pattern"""
        ptr = c_impl.FcPatternDuplicate(self._ptr)
        return Pattern(<intptr_t>ptr)

    @classmethod
    def parse(cls, name: str) -> Pattern:
        """Parse a pattern string"""
        ptr = c_impl.FcNameParse(name.encode("utf-8"))
        if ptr is NULL:
            raise ValueError("Invalid name: %s" % name)
        return cls(<intptr_t>ptr)

    def unparse(self) -> str:
        """Convert a pattern back into a string that can be parsed."""
        name = <bytes>(c_impl.FcNameUnparse(self._ptr))
        return name.decode("utf-8")

    def __len__(self) -> int:
        return c_impl.FcPatternObjectCount(self._ptr)

    def __eq__(self, pattern: Pattern) -> bool:
        return <bint>c_impl.FcPatternEqual(self._ptr, pattern._ptr)

    def equal_subset(self, pattern: Pattern, object_set: ObjectSet) -> bool:
        """Compare portions of patterns"""
        return <bint>c_impl.FcPatternEqualSubset(self._ptr, pattern._ptr, object_set._ptr)

    def subset(self, object_set: ObjectSet) -> Pattern:
        """Filter the objects of pattern"""
        ptr = c_impl.FcPatternFilter(self._ptr, object_set._ptr)
        return Pattern(<intptr_t>ptr)

    def __hash__(self) -> int:
        return <int>c_impl.FcPatternHash(self._ptr)

    def add(self, key: str, value: object, append: bool = True) -> bool:
        """Add a value to a pattern"""
        cdef c_impl.FcValue fc_value
        cdef c_impl.FcObjectType* object_type
        key_ = key.encode("utf-8")
        object_type = c_impl.FcNameGetObjectType(key_)
        if object_type is NULL or object_type.type == c_impl.FcTypeUnknown:
            raise KeyError("Invalid key %s" % key)
        fc_value.type = object_type.type
        _ObjectToFcValue(value, &fc_value)
        result = <bint>c_impl.FcPatternAdd(self._ptr, key_, fc_value, append)
        c_impl.FcValueDestroy(fc_value)
        return result

    def get(self, key: str, index: int = 0) -> Any:
        """Return a value from a pattern"""
        cdef c_impl.FcValue fc_value
        result = c_impl.FcPatternGet(self._ptr, key.encode("utf-8"), index, &fc_value)
        if result == c_impl.FcResultMatch:
            return _FcValueToObject(&fc_value)
        elif result == c_impl.FcResultNoMatch:
            raise KeyError("Invalid key %s" % key)
        elif result == c_impl.FcResultNoId:
            raise KeyError("Invalid index %d" % index)
        elif result == c_impl.FcResultOutOfMemory:
            raise MemoryError()
        else:
            raise RuntimeError()

    def delete(self, key: str) -> bool:
        """Delete a property from a pattern"""
        return <bint>c_impl.FcPatternDel(self._ptr, key.encode("utf-8"))

    def remove(self, key: str, index: int = 0) -> bool:
        """Remove one object of the specified type from the pattern"""
        return <bint>c_impl.FcPatternRemove(self._ptr, key.encode("utf-8"), index)

    def __iter__(self) -> Iterator[Tuple[str, Any]]:
        cdef c_impl.FcPatternIter it
        cdef c_impl.FcValue value
        cdef bytes key
        cdef int count
        c_impl.FcPatternIterStart(self._ptr, &it)
        while <bint>c_impl.FcPatternIterIsValid(self._ptr, &it):
            key = c_impl.FcPatternIterGetObject(self._ptr, &it)
            count = c_impl.FcPatternIterValueCount(self._ptr, &it)
            values = []
            for i in range(count):
                result = c_impl.FcPatternIterGetValue(self._ptr, &it, i, &value, NULL)
                if result != c_impl.FcResultMatch:
                    break
                values.append(_FcValueToObject(&value))

            yield key.decode("utf-8"), values

            if not <bint>c_impl.FcPatternIterNext(self._ptr, &it):
                break

    def print(self) -> None:
        """Print a pattern for debugging"""
        c_impl.FcPatternPrint(self._ptr)

    def default_substitute(self) -> None:
        """Perform default substitutions in a pattern.

        Supplies default values for underspecified font patterns:

        - Patterns without a specified style or weight are set to Medium
        - Patterns without a specified style or slant are set to Roman
        - Patterns without a specified pixel size are given one computed from
          any specified point size (default 12), dpi (default 75) and scale
          (default 1).
        """
        c_impl.FcDefaultSubstitute(self._ptr)

    def format(self, fmt: str) -> None:
        """Format a pattern into a string according to a format specifier"""
        result = c_impl.FcPatternFormat(self._ptr, fmt.encode("utf-8"))
        if result is NULL:
            raise ValueError("Invalid format: %s" % fmt)
        py_str = <bytes>(result).decode("utf-8")
        c_impl.FcStrFree(result)
        return py_str

    def __repr__(self) -> str:
        return dict(self).__repr__()


cdef void _ObjectToFcValue(object value, c_impl.FcValue* fc_value):
    assert fc_value is not NULL
    if fc_value.type == c_impl.FcTypeBool:
        fc_value.u.b = <c_impl.FcBool>value
    elif fc_value.type == c_impl.FcTypeDouble:
        fc_value.u.d = <double>value
    elif fc_value.type == c_impl.FcTypeInteger:
        fc_value.u.i = <int>value
    elif fc_value.type == c_impl.FcTypeString:
        fc_value.u.s = _ObjectToFcFcStr(value)
    elif fc_value.type == c_impl.FcTypeCharSet:
        raise NotImplementedError("CharSet is not supported yet")
    elif fc_value.type == c_impl.FcTypeLangSet:
        fc_value.u.l = _ObjectToFcLangSet(value)
    elif fc_value.type == c_impl.FcTypeFTFace:
        raise NotImplementedError("FTFace is not supported yet")
    elif fc_value.type == c_impl.FcTypeMatrix:
        fc_value.u.m = _ObjectToFcMatrix(value)
    elif fc_value.type == c_impl.FcTypeRange:
        fc_value.u.r = _ObjectToFcRange(value)
    elif fc_value.type == c_impl.FcTypeVoid:
        pass
    else:
        raise RuntimeError("Invalid value type: %d" % fc_value[0].type)


cdef c_impl.FcChar8* _ObjectToFcFcStr(object value):
    value = value.encode("utf-8") if isinstance(value, str) else value
    return c_impl.FcStrCopy(<const c_impl.FcChar8*>(value))


cdef c_impl.FcLangSet* _ObjectToFcLangSet(object value):
    cdef c_impl.FcLangSet* lang_set = c_impl.FcLangSetCreate()
    cdef c_impl.FcBool result;
    for item in value:
        lang = item.encode("utf-8") if isinstance(item, str) else item
        result = c_impl.FcLangSetAdd(lang_set, <c_impl.FcChar8*>(lang))
        if not result:
            c_impl.FcLangSetDestroy(lang_set)
            raise ValueError("Failed to add language: %s" % item)
    return lang_set


cdef c_impl.FcMatrix* _ObjectToFcMatrix(object value):
    cdef c_impl.FcMatrix matrix, *result
    matrix.xx = <double>value[0]
    matrix.xy = <double>value[1]
    matrix.yx = <double>value[2]
    matrix.yy = <double>value[3]
    result = c_impl.FcMatrixCopy(&matrix)
    if result is NULL:
        raise MemoryError()
    return result


cdef c_impl.FcRange* _ObjectToFcRange(object value):
    cdef c_impl.FcRange* result
    if isinstance(value[0], int) and isinstance(value[1], int):
        result = c_impl.FcRangeCreateInteger(<int>value[0], <int>value[1])
    else:
        result = c_impl.FcRangeCreateDouble(<double>value[0], <double>value[1])
    if result is NULL:
        raise MemoryError()
    return result


cdef object _FcValueToObject(c_impl.FcValue* value):
    assert value is not NULL
    if value.type == c_impl.FcTypeBool:
        return <bint>value.u.b
    elif value.type == c_impl.FcTypeDouble:
        return value.u.d
    elif value.type == c_impl.FcTypeInteger:
        return value.u.i
    elif value.type == c_impl.FcTypeString:
        py_bytes = <bytes>(value.u.s)
        return py_bytes.decode("utf-8")
    elif value.type == c_impl.FcTypeCharSet:
        logger.warning("CharSet is not supported yet")
        return None
    elif value.type == c_impl.FcTypeLangSet:
        return _FcLangSetToObject(value.u.l)
    elif value.type == c_impl.FcTypeFTFace:
        logger.warning("FTFace is not supported yet")
        return None
    elif value.type == c_impl.FcTypeMatrix:
        return (
            <float>value.u.m.xx, <float>value.u.m.xy
            <float>value.u.m.yx, <float>value.u.m.yy
        )
    elif value.type == c_impl.FcTypeRange:
        return _FcRangeToObject(value.u.r)
    elif value.type == c_impl.FcTypeVoid:
        return <intptr_t>(value.u.f)
    return None


cdef object _FcLangSetToObject(const c_impl.FcLangSet* lang_set):
    cdef c_impl.FcStrSet* str_set
    cdef c_impl.FcStrList* str_list
    cdef c_impl.FcChar8* value

    str_set = c_impl.FcLangSetGetLangs(lang_set)
    assert str_set is not NULL
    str_list = c_impl.FcStrListCreate(str_set)
    langs = _FcStrListToObject(str_list)
    c_impl.FcStrListDone(str_list)
    c_impl.FcStrSetDestroy(str_set)
    return langs


cdef object _FcRangeToObject(const c_impl.FcRange* range):
    cdef double begin, end
    if not c_impl.FcRangeGetDouble(range, &begin, &end):
        raise RuntimeError()
    return (<float>begin, <float>end)


cdef object _FcStrListToObject(const c_impl.FcStrList* str_list):
    assert str_list is not NULL
    langs = []
    while True:
        value = c_impl.FcStrListNext(str_list)
        if value is NULL:
            break
        langs.append(<bytes>(value).decode("utf-8"))
    return langs


cdef class ObjectSet:
    """An ObjectSet holds a list of pattern property names.

    It is used to indicate which properties are to be returned in the patterns
    from FontList.

    Example::

        # Create a new ObjectSet
        object_set = fontconfig.ObjectSet.create()
        object_set.build(["family", "familylang", "style", "stylelang"])

        # Inspect elements
        for name in object_set:
            print(name)
    """
    cdef c_impl.FcObjectSet* _ptr
    cdef bint _owner

    def __cinit__(self, ptr: int, owner: bool = True):
        self._ptr = <c_impl.FcObjectSet*>(<intptr_t>ptr)
        self._owner = owner

    def __dealloc__(self):
        if self._owner and self._ptr is not NULL:
            c_impl.FcObjectSetDestroy(self._ptr)

    cdef intptr_t ptr(self):
        return <intptr_t>self._ptr

    @classmethod
    def create(cls) -> ObjectSet:
        """Create an ObjectSet"""
        ptr = c_impl.FcObjectSetCreate()
        if ptr is NULL:
            raise MemoryError()
        return cls(<intptr_t>ptr)

    def add(self, value: str) -> bool:
        """Add to an object set"""
        cdef bytes value_ = value.encode("utf-8")
        cdef c_impl.FcObjectType* object_type = c_impl.FcNameGetObjectType(value_)
        if object_type is NULL:
            raise KeyError("Invalid value: %s" % value)
        elif object_type.type == c_impl.FcTypeUnknown:
            raise KeyError("Unknown value: %s" % value)
        return <bint>c_impl.FcObjectSetAdd(self._ptr, value_)

    def build(self, values: Iterable[str]) -> None:
        """Build object set from iterable"""
        for value in values:
            if not self.add(value):
                raise MemoryError()

    def __iter__(self) -> Iterator[str]:
        for i in range(self._ptr.nobject):
            yield <bytes>(self._ptr.objects[i]).decode("utf-8")

    def __repr__(self) -> str:
        return list(self).__repr__()

    def __len__(self) -> int:
        return self._ptr.nobject

    def __getitem__(self, index: int) -> str:
        if index >= self._ptr.nobject or index <= -self._ptr.nobject:
            raise IndexError("Invalid index: %d" % index)
        if index < 0:
            index += self._ptr.nobject
        return <bytes>(self._ptr.objects[index]).decode("utf-8")


cdef class FontSet:
    """A FontSet simply holds a list of patterns; these are used to return
    the results of listing available fonts.

    Example::

        fonts = config.font_list(pattern, object_set)

        # Inspect elements
        for pattern in fonts:
            print(pattern)
    """
    cdef c_impl.FcFontSet* _ptr
    cdef bint _owner

    def __cinit__(self, ptr: int, owner: bool = True):
        self._ptr = <c_impl.FcFontSet*>(<intptr_t>ptr)
        self._owner = owner

    def __dealloc__(self):
        if self._owner and self._ptr is not NULL:
            c_impl.FcFontSetDestroy(self._ptr)

    cdef intptr_t ptr(self):
        return <intptr_t>self._ptr

    @classmethod
    def create(cls) -> FontSet:
        """Create a FontSet"""
        ptr = c_impl.FcFontSetCreate()
        if ptr is NULL:
            raise MemoryError()
        return cls(<intptr_t>ptr)

    def add(self, pattern: Pattern) -> bool:
        """Add to a font set"""
        return c_impl.FcFontSetAdd(self._ptr, pattern._ptr)

    def print(self) -> None:
        """Print a set of patterns to stdout"""
        c_impl.FcFontSetPrint(self._ptr)

    def __iter__(self) -> Iterator[Pattern]:
        for i in range(self._ptr.nfont):
            yield Pattern(<intptr_t>(self._ptr.fonts[i]), owner=False)

    def __repr__(self) -> str:
        return list(self).__repr__()

    def __len__(self) -> int:
        return self._ptr.nfont

    def __getitem__(self, index: int) -> Pattern:
        if index >= self._ptr.nfont or index <= -self._ptr.nfont:
            raise IndexError("Invalid index: %d" % index)
        if index < 0:
            index += self._ptr.nfont
        return Pattern(<intptr_t>self._ptr.fonts[index], owner=False)


def query(where: str = "", select: Iterable[str] = ("family",)) -> List[Dict[str, Any]]:
    """
    High-level function to query fonts.

    Example::

        fonts = fontconfig.query(":lang=en", select=("family", "familylang"))
        for font in fonts:
            print(font["family"])

    :param str where: Query string like ``":lang=en:family=Arial"``.
    :param Iterable[str] select: Set of font properties to include in the result.
    :return: List of font dict.


    The following font properties are supported in the query.

    ==============  =======  =======================================================
    Property        Type     Description
    ==============  =======  =======================================================
    family          String   Font family names
    familylang      String   Language corresponding to each family name
    style           String   Font style. Overrides weight and slant
    stylelang       String   Language corresponding to each style name
    fullname        String   Font face full name where different from family and family + style
    fullnamelang    String   Language corresponding to each fullname
    slant           Int      Italic, oblique or roman
    weight          Int      Light, medium, demibold, bold or black
    width           Int      Condensed, normal or expanded
    size            Double   Point size
    aspect          Double   Stretches glyphs horizontally before hinting
    pixelsize       Double   Pixel size
    spacing         Int      Proportional, dual-width, monospace or charcell
    foundry         String   Font foundry name
    antialias       Bool     Whether glyphs can be antialiased
    hintstyle       Int      Automatic hinting style
    hinting         Bool     Whether the rasterizer should use hinting
    verticallayout  Bool     Use vertical layout
    autohint        Bool     Use autohinter instead of normal hinter
    globaladvance   Bool     Use font global advance data (deprecated)
    file            String   The filename holding the font relative to the config's sysroot
    index           Int      The index of the font within the file
    ftface          FT_Face  Use the specified FreeType face object
    rasterizer      String   Which rasterizer is in use (deprecated)
    outline         Bool     Whether the glyphs are outlines
    scalable        Bool     Whether glyphs can be scaled
    dpi             Double   Target dots per inch
    rgba            Int      unknown, rgb, bgr, vrgb, vbgr, none - subpixel geometry
    scale           Double   Scale factor for point->pixel conversions (deprecated)
    minspace        Bool     Eliminate leading from line spacing
    charset         CharSet  Unicode chars encoded by the font
    lang            LangSet  Set of RFC-3066-style languages this font supports
    fontversion     Int      Version number of the font
    capability      String   List of layout capabilities in the font
    fontformat      String   String name of the font format
    embolden        Bool     Rasterizer should synthetically embolden the font
    embeddedbitmap  Bool     Use the embedded bitmap instead of the outline
    decorative      Bool     Whether the style is a decorative variant
    lcdfilter       Int      Type of LCD filter
    namelang        String   Language name to be used for the default value of familylang, stylelang and fullnamelang
    fontfeatures    String   List of extra feature tags in OpenType to be enabled
    prgname         String   Name of the running program
    hash            String   SHA256 hash value of the font data with "sha256:" prefix (deprecated)
    postscriptname  String   Font name in PostScript
    symbol          Bool     Whether font uses MS symbol-font encoding
    color           Bool     Whether any glyphs have color
    fontvariations  String   comma-separated string of axes in variable font
    variable        Bool     Whether font is Variable Font
    fonthashint     Bool     Whether font has hinting
    order           Int      Order number of the font
    ==============  =======  =======================================================
    """
    config = Config.get_current()
    pattern = Pattern.parse(where)
    object_set = ObjectSet.create()
    object_set.build(select)
    font_set = config.font_list(pattern, object_set)
    return [dict(p) for p in font_set]


@atexit.register
def _exit():
    c_impl.FcFini()


if not c_impl.FcInit():
    raise RuntimeError("Failed to initialize fontconfig")
