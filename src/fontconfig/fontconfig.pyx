import atexit
import logging
from typing import Any, Dict, Iterable, Iterator, List, Tuple

from cython.cimports.libc.stdlib import free
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
    """
    cdef c_impl.FcConfig* _ptr

    def __cinit__(self, ptr: int = 0):
        self._ptr = <c_impl.FcConfig*>(<intptr_t>(ptr))

    def __dealloc__(self):
        if self._ptr is not NULL:
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
        return cls(<intptr_t>c_impl.FcConfigReference(NULL))

    def upto_date(self) -> bool:
        """Check timestamps on config files"""
        return <bint>c_impl.FcConfigUptoDate(self._ptr)

    # TODO: Implement me!


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
        key_ = key.encode("utf-8")
        object_type = c_impl.FcNameGetObjectType(key_)
        if object_type is NULL or object_type.type == c_impl.FcTypeUnknown:
            raise KeyError("Invalid key %s" % key)
        fc_value.type = object_type.type
        _ObjectToFcValue(value, &fc_value)
        return <bint>c_impl.FcPatternAdd(self._ptr, key_, fc_value, append)

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
        free(result)
        return py_str


cdef void _ObjectToFcValue(object value, c_impl.FcValue* fc_value):
    assert fc_value is not NULL
    cdef c_impl.FcMatrix matrix
    if fc_value[0].type == c_impl.FcTypeBool:
        fc_value[0].u.b = <c_impl.FcBool>value
    elif fc_value[0].type == c_impl.FcTypeDouble:
        fc_value[0].u.d = <double>value
    elif fc_value[0].type == c_impl.FcTypeInteger:
        fc_value[0].u.i = <int>value
    elif fc_value[0].type == c_impl.FcTypeString:
        # NOTE: When Python garbage collects bytes, this pointer becomes invalid!
        fc_value[0].u.s = <const c_impl.FcChar8*>(value)
    elif fc_value[0].type == c_impl.FcTypeCharSet:
        raise NotImplementedError("CharSet is not supported yet")
    elif fc_value[0].type == c_impl.FcTypeLangSet:
        fc_value[0].u.l = _ObjectToFcLangSet(value)  # TODO: Possible memory leak
    elif fc_value[0].type == c_impl.FcTypeFTFace:
        raise NotImplementedError("FTFace is not supported yet")
    elif fc_value[0].type == c_impl.FcTypeMatrix:
        matrix.xx = <double>value[0]
        matrix.xy = <double>value[1]
        matrix.yx = <double>value[2]
        matrix.yy = <double>value[3]
        fc_value[0].u.m = c_impl.FcMatrixCopy(&matrix)  # TODO: Possible memory leak
    elif fc_value[0].type == c_impl.FcTypeRange:
        fc_value[0].u.r = c_impl.FcRangeCreateDouble(
            <double>value[0], <double>value[1])
    elif fc_value[0].type == c_impl.FcTypeVoid:
        pass
    else:
        raise ValueError("Unsupported python object: %s" % value)


cdef c_impl.FcLangSet* _ObjectToFcLangSet(object value):
    cdef c_impl.FcLangSet* lang_set = c_impl.FcLangSetCreate()
    for item in value:
        c_impl.FcLangSetAdd(lang_set, <c_impl.FcChar8*>(item))
    return lang_set


cdef object _FcValueToObject(c_impl.FcValue* value):
    assert value is not NULL
    if value[0].type == c_impl.FcTypeBool:
        return <bint>value[0].u.b
    elif value[0].type == c_impl.FcTypeDouble:
        return value[0].u.d
    elif value[0].type == c_impl.FcTypeInteger:
        return value[0].u.i
    elif value[0].type == c_impl.FcTypeString:
        py_bytes = <bytes>(value[0].u.s)
        return py_bytes.decode("utf-8")
    elif value[0].type == c_impl.FcTypeCharSet:
        logger.warning("CharSet is not supported yet")
        return None
    elif value[0].type == c_impl.FcTypeLangSet:
        return _FcLangSetToObject(value[0].u.l)
    elif value[0].type == c_impl.FcTypeFTFace:
        logger.warning("FTFace is not supported yet")
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
        langs.append(<bytes>(value))
    c_impl.FcStrListDone(str_list)
    c_impl.FcStrSetDestroy(str_set)
    return langs


cdef object _FcRangeToObject(const c_impl.FcRange* range):
    cdef double begin, end
    if not c_impl.FcRangeGetDouble(range, &begin, &end):
        raise RuntimeError()
    return (<float>begin, <float>end)


cdef class ObjectSet:
    """An ObjectSet holds a list of pattern property names.

    It is used to indicate which properties are to be returned in the patterns
    from FontList.
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
        return c_impl.FcObjectSetAdd(self._ptr, value.encode("utf-8"))

    def build(self, values: Iterable[str]) -> None:
        """Build object set from iterable"""
        for value in values:
            if not self.add(value):
                raise MemoryError()


cdef class FontSet:
    """A FontSet simply holds a list of patterns; these are used to return
    the results of listing available fonts.
    """
    cdef c_impl.FcFontSet* _ptr

    def __cinit__(self, ptr: int):
        self._ptr = <c_impl.FcFontSet*>(<intptr_t>ptr)

    def __dealloc__(self):
        if self._ptr is not NULL:
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
        for i in range(self._ptr[0].nfont):
            yield Pattern(<intptr_t>(self._ptr[0].fonts[i]), owner=False)

    @classmethod
    def query(cls, pattern: Pattern, object_set: ObjectSet) -> FontSet:
        """Query FontSet from the specified Pattern and ObjectSet."""
        ptr = c_impl.FcFontList(NULL, pattern._ptr, object_set._ptr)
        return cls(<intptr_t>ptr)


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
