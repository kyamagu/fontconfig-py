import atexit
import logging
from typing import Any, Callable, Iterable, Iterator, Optional, Tuple

cimport fontconfig._fontconfig as c_impl

logger = logging.getLogger(__name__)

ctypedef Py_ssize_t intptr_t


def get_version() -> str:
    version = c_impl.FcGetVersion()
    major = version / 10000
    minor = (version % 10000) / 100
    revision = version % 100
    return "%d.%d.%d" % (major, minor, revision)


cdef class Blanks:
    """
    An FcBlanks object holds a list of Unicode chars which are expected to be
    blank when drawn. When scanning new fonts, any glyphs which are empty and
    not in this list will be assumed to be broken and not placed in the
    FcCharSet associated with the font. This provides a significantly more
    accurate CharSet for applications.

    FcBlanks is deprecated and should not be used in newly written code. It is
    still accepted by some functions for compatibility with older code but will
    be removed in the future.
    """
    cdef c_impl.FcBlanks* _ptr

    def __cinit__(self, ptr: int):
        self._ptr = <c_impl.FcBlanks*>(<intptr_t>(ptr))

    def __dealloc__(self):
        if self._ptr is not NULL:
            c_impl.FcBlanksDestroy(self._ptr)

    @classmethod
    def create(cls) -> Blanks:
        ptr = c_impl.FcBlanksCreate()
        if ptr is NULL:
            raise MemoryError()
        return cls(<intptr_t>ptr)

    def add(self, ucs4: int) -> bool:
        """Add a character to an FcBlanks"""
        return <bint>c_impl.FcBlanksAdd(self._ptr, <c_impl.FcChar32>ucs4)

    def is_member(self, ucs4: int) -> bool:
        return <bint>c_impl.FcBlanksIsMember(self._ptr, <c_impl.FcChar32>ucs4)


cdef class Config:
    """An FcConfig object holds the internal representation of a configuration.

    There is a default configuration which applications may use by passing 0 to
    any function using the data within an FcConfig.
    """
    cdef c_impl.FcConfig* _ptr

    def __cinit__(self, ptr: int = 0):
        self._ptr = <c_impl.FcConfig*>(<intptr_t>(ptr))

    def __dealloc__(self):
        if self._ptr is not NULL:
            c_impl.FcConfigDestroy(self._ptr)

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
        return cls(<intptr_t>c_impl.FcConfigReference(NULL))

    def upto_date(self) -> bool:
        return <bint>c_impl.FcConfigUptoDate(self._ptr)

    # TODO: Implement me!


cdef class CharSet:
    """An FcCharSet is a boolean array indicating a set of Unicode chars.
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

    @classmethod
    def create(cls) -> CharSet:
        """Create a charset"""
        ptr = c_impl.FcCharSetCreate()
        if ptr is NULL:
            raise MemoryError()
        return cls(<intptr_t>ptr)

    # TODO: Implement me!


cdef class Pattern:
    """An FcPattern is an opaque type that holds both patterns to match against
    the available fonts, as well as the information about each font.
    """
    cdef c_impl.FcPattern* _ptr
    cdef bint _owner

    def __cinit__(self, ptr: int, owner: bool = True):
        self._ptr = <c_impl.FcPattern*>(<intptr_t>ptr)
        self._owner = owner

    def __dealloc__(self):
        if self._owner and self._ptr is not NULL:
            c_impl.FcPatternDestroy(self._ptr)

    cpdef int ptr(self):
        return <intptr_t>self._ptr

    @classmethod
    def create(cls) -> Pattern:
        """Create a pattern"""
        ptr = c_impl.FcPatternCreate()
        if ptr is NULL:
            raise MemoryError()
        return cls(<intptr_t>ptr)

    @classmethod
    def parse(cls, name: str) -> Pattern:
        """Parse a pattern string"""
        ptr = c_impl.FcNameParse(name.encode("utf-8"))
        if ptr is NULL:
            raise ValueError("Invalid name: %s" % name)
        return cls(<intptr_t>ptr)

    def print(self) -> None:
        c_impl.FcPatternPrint(self._ptr)

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


    # TODO: Implement me!


cdef object _FcValueToObject(c_impl.FcValue* value):
    assert value is not NULL
    if value[0].type == c_impl.FcTypeBool:
        return <bint>value[0].u.b
    elif value[0].type == c_impl.FcTypeDouble:
        return value[0].u.d
    elif value[0].type == c_impl.FcTypeInteger:
        return value[0].u.i
    elif value[0].type == c_impl.FcTypeString:
        return <bytes>(value[0].u.s).decode("utf-8")
    elif value[0].type == c_impl.FcTypeCharSet:
        # TODO: Implement me!
        return None
    elif value[0].type == c_impl.FcTypeLangSet:
        return _FcLangSetToObject(value[0].u.l)
    elif value[0].type == c_impl.FcTypeFTFace:
        # TODO: Implement me!
        return None
    elif value[0].type == c_impl.FcTypeMatrix:
        return (
            <float>value[0].u.m[0].xx, <float>value[0].u.m[0].xy
            <float>value[0].u.m[0].yx, <float>value[0].u.m[0].yy
        )
    elif value[0].type == c_impl.FcTypeRange:
        return _FcRangeToObject(value[0].u.r)
    elif value[0].type == c_impl.FcTypeVoid:
        return <intptr_t>(value[0].u.f)
    return None


cdef object _FcLangSetToObject(const c_impl.FcLangSet* lang_set):
    cdef c_impl.FcStrSet* str_set
    cdef c_impl.FcStrList* str_list
    cdef c_impl.FcChar8* value

    str_set = c_impl.FcLangSetGetLangs(lang_set)
    assert str_set is not NULL
    str_list = c_impl.FcStrListCreate(str_set)
    assert str_list is not NULL
    langs = []
    while True:
        value = c_impl.FcStrListNext(str_list)
        if value is NULL:
            break
        langs.append(<bytes>(value).decode("utf-8"))
    c_impl.FcStrListDone(str_list)
    c_impl.FcStrSetDestroy(str_set)
    return langs


cdef object _FcRangeToObject(const c_impl.FcRange* range):
    cdef double begin, end
    if not c_impl.FcRangeGetDouble(range, &begin, &end):
        raise RuntimeError()
    return (<float>begin, <float>end)


cdef class ObjectSet:
    """An FcObjectSet holds a list of pattern property names; it is used to
    indicate which properties are to be returned in the patterns from FcFontList.
    """
    cdef c_impl.FcObjectSet* _ptr
    cdef bint _owner

    def __cinit__(self, ptr: int, owner: bool = True):
        self._ptr = <c_impl.FcObjectSet*>(<intptr_t>ptr)
        self._owner = owner

    def __dealloc__(self):
        if self._owner and self._ptr is not NULL:
            c_impl.FcObjectSetDestroy(self._ptr)

    cpdef int ptr(self):
        return <intptr_t>self._ptr

    @classmethod
    def create(cls) -> ObjectSet:
        ptr = c_impl.FcObjectSetCreate()
        if ptr is NULL:
            raise MemoryError()
        return cls(<intptr_t>ptr)

    def add(self, value: str) -> bool:
        return c_impl.FcObjectSetAdd(self._ptr, value.encode("utf-8"))

    def build(self, values: Iterable[str]) -> None:
        for value in values:
            if not self.add(value):
                raise MemoryError()


cdef class FontSet:
    """An FcFontSet simply holds a list of patterns; these are used to return
    the results of listing available fonts.
    """
    cdef c_impl.FcFontSet* _ptr

    def __cinit__(self, ptr: int):
        self._ptr = <c_impl.FcFontSet*>(<intptr_t>ptr)

    def __dealloc__(self):
        if self._ptr is not NULL:
            c_impl.FcFontSetDestroy(self._ptr)

    @classmethod
    def create(cls) -> FontSet:
        ptr = c_impl.FcFontSetCreate()
        if ptr is NULL:
            raise MemoryError()
        return cls(<intptr_t>ptr)

    def add(self, pattern: Pattern) -> bool:
        return c_impl.FcFontSetAdd(self._ptr, pattern._ptr)

    def print(self) -> None:
        c_impl.FcFontSetPrint(self._ptr)

    def __iter__(self) -> Iterator[Pattern]:
        for i in range(self._ptr[0].nfont):
            yield Pattern(<intptr_t>(self._ptr[0].fonts[i]), owner=False)

    @classmethod
    def query(cls, pattern: Pattern, object_set: ObjectSet) -> FontSet:
        ptr = c_impl.FcFontList(NULL, pattern._ptr, object_set._ptr)
        return cls(<intptr_t>ptr)


def query(where: str, select: Iterable[str] = ("family",)):
    """Query fonts.

    Selects fonts matching pattern, creates patterns from those fonts containing
    only the objects in os and returns the set of unique such patterns. If
    config is NULL, the default configuration is checked to be up to date, and
    used.
    """
    pattern = Pattern.parse(where)
    object_set = ObjectSet.create()
    object_set.build(select)
    font_set = FontSet.query(pattern, object_set)
    return [dict(p) for p in font_set]


@atexit.register
def _exit():
    c_impl.FcFini()


if not c_impl.FcInit():
    raise RuntimeError("Failed to initialize fontconfig")
