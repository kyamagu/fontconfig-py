"""Type stubs for fontconfig module"""
from typing import Any, Dict, Iterable, Iterator, List, Optional, Tuple

def get_version() -> str:
    """Get fontconfig version."""
    ...

class Blanks:
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
    def __init__(self, ptr: int) -> None: ...
    @classmethod
    def create(cls) -> Blanks:
        """Create a Blanks"""
        ...
    def add(self, ucs4: int) -> bool:
        """Add a character to a Blanks"""
        ...
    def is_member(self, ucs4: int) -> bool:
        """Query membership in a Blanks"""
        ...

class Config:
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
    def __init__(self, ptr: int, owner: bool = True) -> None: ...
    @classmethod
    def create(cls) -> Config:
        """Create a configuration"""
        ...
    def set_current(self) -> bool:
        """Set configuration as default"""
        ...
    @classmethod
    def get_current(cls) -> Config:
        """Return current configuration"""
        ...
    def upto_date(self) -> bool:
        """Check timestamps on config files"""
        ...
    @staticmethod
    def home() -> Optional[str]:
        """Return the current home directory"""
        ...
    @staticmethod
    def enable_home(enable: bool) -> bool:
        """Controls use of the home directory"""
        ...
    def build_fonts(self) -> bool:
        """Build font database"""
        ...
    def get_config_dirs(self) -> List[str]:
        """Get config directories"""
        ...
    def get_font_dirs(self) -> List[str]:
        """Get font directories"""
        ...
    def get_config_files(self) -> List[str]:
        """Get config files"""
        ...
    def get_cache_dirs(self) -> List[str]:
        """Return the list of directories searched for cache files"""
        ...
    def get_fonts(self, name: str = "system") -> FontSet:
        """Get config font set"""
        ...
    def get_rescan_interval(self) -> int:
        """Get config rescan interval"""
        ...
    def set_rescan_interval(self, interval: int) -> bool:
        """Set config rescan interval"""
        ...
    def app_font_add_file(self, filename: str) -> bool:
        """Add font file to font database"""
        ...
    def app_font_add_dir(self, dirname: str) -> bool:
        """Add fonts from directory to font database"""
        ...
    def app_font_clear(self) -> None:
        """Remove all app fonts from font database"""
        ...
    def substitute_with_pat(
        self, p: Pattern, p_pat: Pattern, kind: str = "pattern"
    ) -> bool:
        """Execute substitutions"""
        ...
    def substitute(self, p: Pattern, kind: str = "pattern") -> bool:
        """Execute substitutions"""
        ...
    def font_match(self, p: Pattern) -> Optional[Pattern]:
        """Return best font"""
        ...
    def font_sort(self, p: Pattern, trim: bool) -> Optional[FontSet]:
        """Return list of matching fonts"""
        ...
    def font_render_prepare(self, p: Pattern, font: Pattern) -> Pattern:
        """Prepare pattern for loading font file"""
        ...
    def font_list(self, pattern: Pattern, object_set: ObjectSet) -> FontSet:
        """List fonts"""
        ...
    def parse_and_load(self, filename: str, complain: bool = True) -> bool:
        """Load a configuration file"""
        ...
    def parse_and_load_from_memory(self, buffer: bytes, complain: bool = True) -> bool:
        """Load a configuration from memory"""
        ...
    def get_sysroot(self) -> Optional[str]:
        """Obtain the system root directory"""
        ...
    def set_sysroot(self, sysroot: str) -> None:
        """Set the system root directory"""
        ...
    def __iter__(self) -> Iterator[Tuple[str, str, bool]]:
        """Obtain the configuration file information"""
        ...

class CharSet:
    """A CharSet is a boolean array indicating a set of Unicode chars.

    Those associated with a font are marked constant and cannot be edited.
    FcCharSets may be reference counted internally to reduce memory consumption;
    this may be visible to applications as the result of FcCharSetCopy may
    return it's argument, and that CharSet may remain unmodifiable.
    """
    def __init__(self, ptr: int) -> None: ...
    @classmethod
    def create(cls) -> CharSet:
        """Create an empty charset"""
        ...
    @classmethod
    def from_string(cls, text: str) -> CharSet:
        """Create charset from string characters."""
        ...
    @classmethod
    def from_codepoints(cls, codepoints: Iterable[int]) -> CharSet:
        """Create charset from iterable of Unicode codepoints."""
        ...
    def copy(self) -> CharSet:
        """Create a copy of this charset."""
        ...
    def add(self, item: object) -> bool:
        """Add a character to the charset."""
        ...
    def discard(self, item: object) -> bool:
        """Remove a character from the charset if present."""
        ...
    def __len__(self) -> int:
        """Return the number of characters in the charset."""
        ...
    def __contains__(self, item: object) -> bool:
        """Check if character is in the charset."""
        ...
    def __iter__(self) -> Iterator[int]:
        """Iterate over Unicode codepoints in the charset."""
        ...
    def __eq__(self, other: object) -> bool:
        """Check if two charsets are equal."""
        ...
    def __repr__(self) -> str:
        """Return string representation for debugging."""
        ...

class Pattern:
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
    def __init__(self, ptr: int, owner: bool = True) -> None: ...
    @classmethod
    def create(cls) -> Pattern:
        """Create a pattern"""
        ...
    def copy(self) -> Pattern:
        """Copy a pattern"""
        ...
    @classmethod
    def parse(cls, name: str) -> Pattern:
        """Parse a pattern string"""
        ...
    def unparse(self) -> str:
        """Convert a pattern back into a string that can be parsed."""
        ...
    def __len__(self) -> int: ...
    def __eq__(self, pattern: object) -> bool: ...
    def equal_subset(self, pattern: Pattern, object_set: ObjectSet) -> bool:
        """Compare portions of patterns"""
        ...
    def subset(self, object_set: ObjectSet) -> Pattern:
        """Filter the objects of pattern"""
        ...
    def __hash__(self) -> int: ...
    def add(self, key: str, value: object, append: bool = True) -> bool:
        """Add a value to a pattern"""
        ...
    def get(self, key: str, index: int = 0) -> Any:
        """Return a value from a pattern"""
        ...
    def delete(self, key: str) -> bool:
        """Delete a property from a pattern"""
        ...
    def remove(self, key: str, index: int = 0) -> bool:
        """Remove one object of the specified type from the pattern"""
        ...
    def __iter__(self) -> Iterator[Tuple[str, Any]]: ...
    def print(self) -> None:
        """Print a pattern for debugging"""
        ...
    def default_substitute(self) -> None:
        """Perform default substitutions in a pattern.

        Supplies default values for underspecified font patterns:

        - Patterns without a specified style or weight are set to Medium
        - Patterns without a specified style or slant are set to Roman
        - Patterns without a specified pixel size are given one computed from
          any specified point size (default 12), dpi (default 75) and scale
          (default 1).
        """
        ...
    def format(self, fmt: str) -> str:
        """Format a pattern into a string according to a format specifier"""
        ...
    def __repr__(self) -> str: ...

class ObjectSet:
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
    def __init__(self, ptr: int, owner: bool = True) -> None: ...
    @classmethod
    def create(cls) -> ObjectSet:
        """Create an ObjectSet"""
        ...
    def add(self, value: str) -> bool:
        """Add to an object set"""
        ...
    def build(self, values: Iterable[str]) -> None:
        """Build object set from iterable"""
        ...
    def __iter__(self) -> Iterator[str]: ...
    def __repr__(self) -> str: ...
    def __len__(self) -> int: ...
    def __getitem__(self, index: int) -> str: ...

class FontSet:
    """A FontSet simply holds a list of patterns; these are used to return
    the results of listing available fonts.

    Example::

        fonts = config.font_list(pattern, object_set)

        # Inspect elements
        for pattern in fonts:
            print(pattern)
    """
    def __init__(self, ptr: int, owner: bool = True) -> None: ...
    @classmethod
    def create(cls) -> FontSet:
        """Create a FontSet"""
        ...
    def add(self, pattern: Pattern) -> bool:
        """Add to a font set"""
        ...
    def print(self) -> None:
        """Print a set of patterns to stdout"""
        ...
    def __iter__(self) -> Iterator[Pattern]: ...
    def __repr__(self) -> str: ...
    def __len__(self) -> int: ...
    def __getitem__(self, index: int) -> Pattern: ...

def match(
    pattern: str = "",
    properties: Optional[Dict[str, Any]] = None,
    select: Iterable[str] = ("family", "file", "style"),
    config: Optional[Config] = None,
) -> Optional[Dict[str, Any]]:
    """
    Find the best matching font for a given pattern.

    This wraps FcFontMatch and performs all necessary substitutions.
    Equivalent to the ``fc-match`` command-line tool.

    Example::

        # Find best match for Arial Bold
        font = fontconfig.match(":family=Arial:weight=200")
        if font:
            print(font["file"])

        # Using properties dict
        font = fontconfig.match(properties={"family": "Arial", "weight": 200})

        # Custom properties to return
        font = fontconfig.match(":family=Arial", select=("family", "file", "weight"))

    :param str pattern: Pattern string like ``":family=Arial:weight=200"``.
    :param Optional[Dict[str, Any]] properties: Dict of pattern properties (alternative to pattern string).
    :param Iterable[str] select: Properties to include in result dict.
    :param Optional[Config] config: Config instance (default: current config).
    :return: Dict with selected properties, or None if no match.
    """
    ...

def sort(
    pattern: str = "",
    properties: Optional[Dict[str, Any]] = None,
    select: Iterable[str] = ("family", "file", "style"),
    trim: bool = True,
    config: Optional[Config] = None,
) -> List[Dict[str, Any]]:
    """
    Get a sorted list of fonts matching a pattern, ordered by quality.

    This wraps FcFontSort and returns fonts in preference order.
    Equivalent to the ``fc-match -s`` command-line tool.

    Example::

        # Get all Arial fonts, best matches first
        fonts = fontconfig.sort(":family=Arial")
        for font in fonts[:5]:  # Top 5 matches
            print(font["family"], font["file"])

        # Using properties dict
        fonts = fontconfig.sort(properties={"family": "Arial"})

        # Without trimming (include all fonts even with no common charset)
        fonts = fontconfig.sort(":family=Arial", trim=False)

    :param str pattern: Pattern string like ``":family=Arial"``.
    :param Optional[Dict[str, Any]] properties: Dict of pattern properties (alternative to pattern string).
    :param Iterable[str] select: Properties to include in result dicts.
    :param bool trim: Remove fonts with no common charset.
    :param Optional[Config] config: Config instance (default: current config).
    :return: List of dicts with selected properties, sorted by match quality.
    """
    ...

def list(
    pattern: str = "",
    properties: Optional[Dict[str, Any]] = None,
    select: Iterable[str] = ("family",),
    config: Optional[Config] = None,
) -> List[Dict[str, Any]]:
    """
    List all fonts matching a pattern.

    This wraps FcFontList (same as query() but with better naming).
    Equivalent to the ``fc-list`` command-line tool.

    Example::

        # List all fonts with English support
        fonts = fontconfig.list(":lang=en", select=("family", "file"))

        # Using properties dict
        fonts = fontconfig.list(properties={"lang": ["en"]})

        # List all fonts
        fonts = fontconfig.list()

    :param str pattern: Pattern string like ``":lang=en:family=Arial"``.
    :param Optional[Dict[str, Any]] properties: Dict of pattern properties (alternative to pattern string).
    :param Iterable[str] select: Properties to include in result dicts.
    :param Optional[Config] config: Config instance (default: current config).
    :return: List of dicts with selected properties (no particular order).

    **Font Properties**

    The following font properties are supported in patterns and can be used in the
    ``select`` parameter. See also :py:func:`match` and :py:func:`sort`.

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
    ...

def query(where: str = "", select: Iterable[str] = ("family",)) -> List[Dict[str, Any]]:
    """
    High-level function to query fonts.

    .. deprecated:: 0.3.0
        Use :py:func:`list`, :py:func:`match`, or :py:func:`sort` instead.
        This function is kept for backward compatibility.

    Example::

        fonts = fontconfig.query(":lang=en", select=("family", "familylang"))
        for font in fonts:
            print(font["family"])

    :param str where: Query string like ``":lang=en:family=Arial"``.
    :param Iterable[str] select: Set of font properties to include in the result.
        See :py:func:`list` for a complete list of supported font properties.
    :return: List of font dict.
    """
    ...
