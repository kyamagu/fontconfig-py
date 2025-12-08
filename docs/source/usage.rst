Usage
=====

Basic Font Operations
---------------------

fontconfig-py provides three high-level functions that align with the core fontconfig
library operations:

- :py:func:`fontconfig.match` - Find the **single best** matching font (wraps ``FcFontMatch``)
- :py:func:`fontconfig.sort` - Get fonts **sorted by match quality** (wraps ``FcFontSort``)
- :py:func:`fontconfig.list` - **List all** matching fonts (wraps ``FcFontList``)

Choosing the Right Function
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Need one font?** Use :py:func:`match`
- **Need best matches in order?** Use :py:func:`sort`
- **Need to enumerate all fonts?** Use :py:func:`list`

Finding the Best Font (match)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use :py:func:`fontconfig.match` when you need a single font that best matches your
requirements. This is equivalent to the ``fc-match`` command-line tool::

   import fontconfig

   # Find best match for Arial Bold
   font = fontconfig.match(":family=Arial:weight=200")
   if font:
       print(f"Matched: {font['file']}")

   # Using properties dict (alternative to pattern string)
   font = fontconfig.match(properties={"family": "Arial", "weight": 200})

   # Get specific properties
   font = fontconfig.match(":family=Arial", select=("family", "file", "style"))

   # Match with no constraints (returns default font)
   font = fontconfig.match()

Getting Sorted Font Results (sort)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use :py:func:`fontconfig.sort` when you want multiple fonts ordered by match quality.
This is equivalent to the ``fc-match -s`` command-line tool::

   import fontconfig

   # Get all Arial fonts, best matches first
   fonts = fontconfig.sort(":family=Arial")
   for font in fonts[:5]:  # Top 5 matches
       print(f"{font['family']} - {font['file']}")

   # Using properties dict
   fonts = fontconfig.sort(properties={"family": "Arial", "slant": 100})

   # Without trimming (include fonts with no common charset)
   fonts = fontconfig.sort(":family=Arial", trim=False)

Listing All Matching Fonts (list)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use :py:func:`fontconfig.list` when you want to enumerate all fonts matching a pattern.
This is equivalent to the ``fc-list`` command-line tool::

   import fontconfig

   # List all fonts with English support
   fonts = fontconfig.list(":lang=en", select=("family", "file"))
   for font in fonts:
       print(f"{font['family']}: {font['file']}")

   # Using properties dict
   fonts = fontconfig.list(properties={"lang": ["en"]})

   # List all fonts in the system
   all_fonts = fontconfig.list()

Cookbook: Common Font Search Patterns
--------------------------------------

This section shows practical examples for common font search tasks.

Finding Monospace Fonts
~~~~~~~~~~~~~~~~~~~~~~~~

Monospace fonts are useful for code editors, terminals, and tabular data.
Use ``spacing=100`` to find monospace fonts::

   import fontconfig

   # Find the best monospace font
   font = fontconfig.match(properties={"spacing": 100})
   if font:
       print(f"Monospace font: {font['family']}")
       print(f"File: {font['file']}")

   # List all monospace fonts
   mono_fonts = fontconfig.list(
       properties={"spacing": 100},
       select=("family", "file")
   )

   print(f"Found {len(mono_fonts)} monospace fonts:")
   for font in mono_fonts[:10]:  # Show first 10
       print(f"  {font['family']}")

The ``spacing`` property values are:

- ``0`` = proportional
- ``100`` = monospace
- ``110`` = charcell

Finding Fonts by Language Support
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Find fonts that support specific languages using the ``lang`` property::

   import fontconfig

   # Find fonts with Japanese support
   japanese_fonts = fontconfig.list(
       properties={"lang": ["ja"]},
       select=("family", "file")
   )

   print(f"Fonts with Japanese support: {len(japanese_fonts)}")
   for font in japanese_fonts[:5]:
       print(f"  {font['family']}")

   # Find fonts supporting multiple languages
   multilang = fontconfig.match(properties={"lang": ["zh-cn", "ja", "ko"]})
   if multilang:
       print(f"CJK font: {multilang['family']}")

Common language codes:

- ``en`` = English
- ``zh-cn`` = Simplified Chinese
- ``zh-tw`` = Traditional Chinese
- ``ja`` = Japanese
- ``ko`` = Korean
- ``ar`` = Arabic
- ``he`` = Hebrew
- ``ru`` = Russian

Finding Bold and Italic Variants
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Search for specific font styles using ``weight`` and ``slant`` properties::

   import fontconfig

   # Find bold variant
   bold_font = fontconfig.match(properties={
       "family": "Arial",
       "weight": 200  # Bold
   })

   # Find italic variant
   italic_font = fontconfig.match(properties={
       "family": "Arial",
       "slant": 100  # Italic
   })

   # Find bold italic
   bold_italic = fontconfig.match(properties={
       "family": "Arial",
       "weight": 200,  # Bold
       "slant": 100    # Italic
   })

   if bold_italic:
       print(f"Bold Italic: {bold_italic['style']}")
       print(f"File: {bold_italic['file']}")

**Weight values**:

- ``0`` = Thin
- ``40`` = Light
- ``80`` = Normal/Regular (default)
- ``200`` = Bold
- ``210`` = Black/Heavy

**Slant values**:

- ``0`` = Roman (upright)
- ``100`` = Italic
- ``110`` = Oblique

Checking if a Specific Font Exists
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Check whether a particular font is installed and get fallbacks if not::

   import fontconfig

   def find_font_or_fallback(family_name, fallbacks=None):
       """Find a font by family name with optional fallbacks."""
       if fallbacks is None:
           fallbacks = []

       # Try each font in order
       for family in [family_name] + fallbacks:
           font = fontconfig.match(properties={"family": family})
           if font and font.get('family') == family:
               return font

       # Return any matched font as last resort
       return fontconfig.match()

   # Example usage
   font = find_font_or_fallback(
       "Helvetica",
       fallbacks=["Arial", "Liberation Sans", "sans-serif"]
   )

   if font:
       print(f"Using: {font['family']}")
       print(f"File: {font['file']}")

**Note**: The :py:func:`match` function always returns a font (even if the
exact family isn't found), so check if the returned family matches what you
requested.

Finding System Default Fonts
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Get the system's default fonts for common font families::

   import fontconfig

   # Get default sans-serif font
   sans = fontconfig.match(properties={"family": "sans-serif"})
   print(f"Default sans-serif: {sans['family']}")

   # Get default serif font
   serif = fontconfig.match(properties={"family": "serif"})
   print(f"Default serif: {serif['family']}")

   # Get default monospace font
   mono = fontconfig.match(properties={"family": "monospace"})
   print(f"Default monospace: {mono['family']}")

   # Get all details
   print(f"\nSans-serif details:")
   print(f"  Family: {sans['family']}")
   print(f"  Style: {sans['style']}")
   print(f"  File: {sans['file']}")

The generic family names (``sans-serif``, ``serif``, ``monospace``) are
special aliases that fontconfig resolves to the system's preferred fonts.

Finding Fonts with Color/Emoji Support
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Modern color fonts and emoji fonts can be found using the ``color`` property::

   import fontconfig

   # Find fonts with color support
   color_fonts = fontconfig.list(
       properties={"color": True},
       select=("family", "file", "fontformat")
   )

   print(f"Color fonts available: {len(color_fonts)}")
   for font in color_fonts:
       print(f"  {font['family']} ({font.get('fontformat', 'unknown')})")

   # Find best emoji font
   emoji_font = fontconfig.match(properties={"color": True})
   if emoji_font:
       print(f"\nEmoji font: {emoji_font['family']}")
       print(f"File: {emoji_font['file']}")

Common color font formats include:

- ``CBDT/CBLC`` = Color bitmap (used in Noto Color Emoji)
- ``SBIX`` = Apple color emoji format
- ``COLR`` = Microsoft layered color format
- ``SVG`` = SVG-in-OpenType

Finding Variable Fonts
~~~~~~~~~~~~~~~~~~~~~~~

Variable fonts contain multiple style variations in a single file::

   import fontconfig

   # Find variable fonts
   variable_fonts = fontconfig.list(
       properties={"variable": True},
       select=("family", "file", "fontvariations")
   )

   print(f"Variable fonts: {len(variable_fonts)}")
   for font in variable_fonts[:10]:
       print(f"  {font['family']}")
       if 'fontvariations' in font:
           print(f"    Axes: {font['fontvariations']}")

The ``fontvariations`` property shows available variation axes (like weight,
width, slant, optical size).

Getting Font File Paths
~~~~~~~~~~~~~~~~~~~~~~~~

Extract font file paths and handle fonts with multiple faces::

   import fontconfig

   # Get font file path
   font = fontconfig.match(":family=Arial")
   if font:
       filepath = font['file']
       index = font.get('index', 0)

       print(f"Font file: {filepath}")
       print(f"Face index: {index}")

       # Use with font libraries
       # freetype_face = freetype.Face(filepath, index)
       # pil_font = ImageFont.truetype(filepath, size=12)

   # Get all files for a font family
   family_fonts = fontconfig.list(
       properties={"family": "Arial"},
       select=("family", "style", "file", "index")
   )

   print(f"\nAll Arial variants:")
   for font in family_fonts:
       print(f"  {font['style']}: {font['file']} (index {font.get('index', 0)})")

**Note**: The ``index`` property is important for TrueType Collection (TTC)
files that contain multiple font faces in one file. It defaults to 0.

Query fonts by family name (deprecated)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. deprecated:: 0.3.0
   Use :py:func:`list`, :py:func:`match`, or :py:func:`sort` instead.

The legacy :py:func:`fontconfig.query` function is still available but deprecated::

   import fontconfig

   # Old way (deprecated)
   fonts = fontconfig.query(
       where=":family=Arial",
       select=("family", "style", "file", "lang")
   )

   # New way (recommended)
   fonts = fontconfig.list(
       pattern=":family=Arial",
       select=("family", "style", "file", "lang")
   )

Error Handling and Edge Cases
------------------------------

This section covers common error scenarios and how to handle them gracefully.

Handling No Matches
~~~~~~~~~~~~~~~~~~~

The :py:func:`match` function returns ``None`` when no fonts match the pattern.
Always check for ``None`` before accessing properties::

   import fontconfig

   # BAD: Can raise AttributeError
   font = fontconfig.match(":family=NonExistentFont")
   print(font['family'])  # Error if font is None!

   # GOOD: Check for None first
   font = fontconfig.match(":family=NonExistentFont")
   if font:
       print(f"Found: {font['family']}")
   else:
       print("No font matched")

   # GOOD: Use fallback strategy
   font = fontconfig.match(":family=PreferredFont")
   if not font:
       font = fontconfig.match()  # Get system default

   print(f"Using: {font['family']}")

**Best Practice**: :py:func:`match` with no constraints always returns a font,
so you can use it as a fallback.

Working with Empty Results
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The :py:func:`list` and :py:func:`sort` functions return empty lists when
nothing matches::

   import fontconfig

   # Check for empty results
   fonts = fontconfig.list(":family=NonExistent")
   if not fonts:
       print("No fonts found")
   else:
       print(f"Found {len(fonts)} fonts")

   # Safe iteration
   for font in fontconfig.list(":lang=fictional"):
       print(font['family'])  # This loop won't execute if empty

   # Get first result safely
   fonts = fontconfig.sort(":family=Arial")
   first_font = fonts[0] if fonts else None
   if first_font:
       print(f"Best match: {first_font['family']}")

Invalid Property Names
~~~~~~~~~~~~~~~~~~~~~~

Using invalid property names in patterns will cause them to be ignored::

   import fontconfig

   # Typo in property name - will be ignored
   font = fontconfig.match(":famly=Arial")  # Should be "family"
   # This matches any font because pattern is effectively empty

   # Check your pattern syntax
   valid_properties = [
       "family", "style", "weight", "slant", "size", "file",
       "spacing", "lang", "charset", "color", "variable"
   ]

   # Using dict helps catch typos at runtime
   try:
       font = fontconfig.match(properties={"famly": "Arial"})
   except KeyError:
       print("Invalid property name")

See the :ref:`font-properties-reference` for a complete list of valid properties.

Pattern Parsing Errors
~~~~~~~~~~~~~~~~~~~~~~

Invalid pattern string syntax can cause unexpected results::

   import fontconfig

   # CORRECT pattern syntax
   font = fontconfig.match(":family=Arial:weight=200")

   # INCORRECT: Missing colon before first property
   font = fontconfig.match("family=Arial")  # Parsed as single value

   # INCORRECT: Wrong separator
   font = fontconfig.match(":family=Arial,weight=200")  # Comma is for values

   # CORRECT: Multiple values for same property
   font = fontconfig.match(":family=Arial,Helvetica,sans-serif")

   # Better: Use properties dict to avoid syntax errors
   font = fontconfig.match(properties={
       "family": "Arial",
       "weight": 200
   })

**Best Practice**: Use the ``properties`` dict parameter instead of pattern
strings when building patterns programmatically. It's less error-prone and
more readable.

Accessing Missing Properties
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Not all fonts have all properties. Handle missing properties gracefully::

   import fontconfig

   font = fontconfig.match(":family=Arial")

   # BAD: May raise KeyError
   print(font['fontvariations'])

   # GOOD: Use .get() with default
   variations = font.get('fontvariations', 'Not a variable font')
   print(variations)

   # GOOD: Check membership
   if 'color' in font:
       print(f"Color support: {font['color']}")
   else:
       print("Color property not available")

   # Get multiple properties safely
   family = font.get('family', 'Unknown')
   style = font.get('style', 'Regular')
   file = font.get('file', 'Not available')

   print(f"{family} {style}: {file}")

Advanced Usage with Low-Level API
----------------------------------

For more control over font matching and configuration, use the low-level API
with :py:class:`Config`, :py:class:`Pattern`, and :py:class:`ObjectSet`.

Font Matching
~~~~~~~~~~~~~

Find the best matching font for a given pattern::

   import fontconfig

   # Get current fontconfig configuration
   config = fontconfig.Config.get_current()

   # Create a pattern for the desired font
   pattern = fontconfig.Pattern.create()
   pattern.add("family", "Arial")
   pattern.add("weight", 200)  # Bold weight
   pattern.add("slant", 0)     # Roman (not italic)

   # Apply default substitutions
   pattern.default_substitute()
   config.substitute(pattern)

   # Find the best match
   matched = config.font_match(pattern)
   if matched:
       print(f"Matched font: {matched.get('file')}")
       print(f"Family: {matched.get('family')}")
       print(f"Style: {matched.get('style')}")

Font Sorting
~~~~~~~~~~~~

Get a sorted list of fonts matching a pattern::

   import fontconfig

   config = fontconfig.Config.get_current()
   pattern = fontconfig.Pattern.parse(":family=Arial")
   pattern.default_substitute()

   # Get sorted list of matching fonts
   font_set = config.font_sort(pattern, trim=True)
   if font_set:
       for i in range(len(font_set)):
           font = font_set[i]
           print(f"{i+1}. {font.get('family')} - {font.get('file')}")

List Fonts with Specific Properties
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use :py:class:`ObjectSet` to specify which properties to retrieve::

   import fontconfig

   config = fontconfig.Config.get_current()

   # Create a pattern
   pattern = fontconfig.Pattern.parse(":lang=en")

   # Specify which properties to retrieve
   object_set = fontconfig.ObjectSet.create()
   object_set.add("family")
   object_set.add("style")
   object_set.add("file")
   object_set.add("slant")
   object_set.add("weight")

   # List all matching fonts
   fonts = config.font_list(pattern, object_set)
   for i in range(len(fonts)):
       font = fonts[i]
       print(f"Family: {font.get('family')}")
       print(f"Style: {font.get('style')}")
       print(f"Weight: {font.get('weight')}")
       print("---")

Working with Patterns
~~~~~~~~~~~~~~~~~~~~~

:py:class:`Pattern` objects can be created, modified, and parsed.

Understanding Pattern Syntax
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Patterns use a colon-separated format to specify font properties. The general
syntax is::

   :property1=value1:property2=value2:property3=value3

**Key rules**:

- Start with a colon ``:``
- Separate properties with colons
- Use ``=`` between property name and value
- Separate multiple values for the same property with commas
- No spaces (spaces are treated as part of values)

Pattern Examples
^^^^^^^^^^^^^^^^

Common pattern formats::

   import fontconfig

   # Simple pattern
   font = fontconfig.match(":family=Arial")

   # Multiple properties
   font = fontconfig.match(":family=Arial:weight=200:slant=100")

   # Multiple values (fallback list for family)
   font = fontconfig.match(":family=Helvetica,Arial,sans-serif")

   # Boolean values
   font = fontconfig.match(":family=Arial:antialias=True")

   # Numeric values
   font = fontconfig.match(":family=Arial:size=12.0:pixelsize=16")

   # String values with spaces (avoid if possible)
   font = fontconfig.match(":family=Noto Sans")  # Works but be careful

Property Value Types
^^^^^^^^^^^^^^^^^^^^

Different properties accept different value types:

**String properties** (family, style, file, etc.)::

   ":family=Arial"
   ":style=Bold"

**Integer properties** (weight, slant, spacing, etc.)::

   ":weight=200"  # Bold
   ":slant=100"   # Italic

**Double properties** (size, pixelsize, aspect, etc.)::

   ":size=12.0"
   ":pixelsize=16.5"

**Boolean properties** (antialias, hinting, outline, etc.)::

   ":antialias=True"
   ":hinting=False"

Pattern Strings vs Properties Dict
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can specify font properties in two ways:

**1. Pattern strings** (fontconfig native format)::

   font = fontconfig.match(":family=Arial:weight=200")

**Advantages**:

- Compact and readable for simple queries
- Native fontconfig syntax
- Can copy/paste from ``fc-match`` command line

**Disadvantages**:

- Easy to make syntax errors
- Harder to build dynamically
- Requires string formatting for variables

**2. Properties dictionary** (Python dict)::

   font = fontconfig.match(properties={
       "family": "Arial",
       "weight": 200
   })

**Advantages**:

- Type-safe and IDE-friendly
- Easy to build programmatically
- Clear and Pythonic
- Less error-prone

**Disadvantages**:

- Slightly more verbose

**Best Practice**: Use properties dict for programmatic queries, pattern strings
for simple hardcoded queries.

Example: Building patterns dynamically::

   import fontconfig

   # Dynamic pattern building
   def find_font(family, bold=False, italic=False):
       properties = {"family": family}

       if bold:
           properties["weight"] = 200
       if italic:
           properties["slant"] = 100

       return fontconfig.match(properties=properties)

   # Easy to use
   regular = find_font("Arial")
   bold = find_font("Arial", bold=True)
   bold_italic = find_font("Arial", bold=True, italic=True)

Common Pattern Mistakes
^^^^^^^^^^^^^^^^^^^^^^^

Avoid these common errors::

   # ❌ WRONG: Missing initial colon
   fontconfig.match("family=Arial")

   # ✅ CORRECT
   fontconfig.match(":family=Arial")

   # ❌ WRONG: Using comma between different properties
   fontconfig.match(":family=Arial,weight=200")

   # ✅ CORRECT: Comma only for multiple values of SAME property
   fontconfig.match(":family=Arial,Helvetica:weight=200")

   # ❌ WRONG: Spaces around separators
   fontconfig.match(": family = Arial : weight = 200")

   # ✅ CORRECT: No spaces
   fontconfig.match(":family=Arial:weight=200")

   # ❌ WRONG: Invalid property name (typo)
   fontconfig.match(":famly=Arial")  # Will be ignored silently

   # ✅ CORRECT: Use dict to catch typos
   fontconfig.match(properties={"family": "Arial"})

Creating and Modifying Patterns
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Pattern objects support creation, modification, and parsing::

   import fontconfig

   # Create from scratch
   pattern = fontconfig.Pattern.create()
   pattern.add("family", "Arial")
   pattern.add("size", 12.0)
   pattern.add("antialias", True)

   # Parse from string
   pattern = fontconfig.Pattern.parse(":family=Arial:size=12:antialias=True")

   # Get properties
   family = pattern.get("family")
   size = pattern.get("size")

   # Remove properties
   pattern.remove("size")

   # Convert back to string
   pattern_str = pattern.unparse()
   print(pattern_str)

   # Format pattern with custom template
   formatted = pattern.format("%{family} %{style}")
   print(formatted)

Configuration Management
~~~~~~~~~~~~~~~~~~~~~~~~

Access fontconfig configuration directories and files::

   import fontconfig

   config = fontconfig.Config.get_current()

   # Get configuration directories
   print("Config directories:", config.get_config_dirs())
   print("Font directories:", config.get_font_dirs())
   print("Config files:", config.get_config_files())
   print("Cache directories:", config.get_cache_dirs())

   # Get available fonts
   system_fonts = config.get_fonts("system")
   app_fonts = config.get_fonts("application")

   print(f"System fonts: {len(system_fonts)}")
   print(f"Application fonts: {len(app_fonts)}")

Working with Character Sets
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:py:class:`CharSet` represents the set of Unicode characters supported by a font.
This is useful for checking whether a font can display specific text or for
filtering fonts by character coverage.

What is CharSet?
^^^^^^^^^^^^^^^^

A CharSet is a boolean array indicating which Unicode codepoints are present in
a font. When you need to:

- Check if a font supports specific characters
- Find fonts that can render a given string
- Filter fonts by Unicode range (e.g., only fonts with Cyrillic)

You'll work with CharSet objects.

Creating CharSets
^^^^^^^^^^^^^^^^^

Create CharSets from strings or codepoint lists::

   import fontconfig

   # Create from string
   charset = fontconfig.CharSet.from_string("Hello, World!")
   print(f"Character count: {len(charset)}")

   # Create from Unicode codepoints
   charset = fontconfig.CharSet.from_codepoints([0x41, 0x42, 0x43])  # A, B, C

   # Create empty and add characters
   charset = fontconfig.CharSet.create()
   charset.add('A')
   charset.add(0x42)  # Add by codepoint
   charset.add('C')

   print(f"Contains: {len(charset)} characters")

Checking Character Membership
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Check if specific characters are in a CharSet::

   import fontconfig

   charset = fontconfig.CharSet.from_string("Hello")

   # Check with 'in' operator
   if 'H' in charset:
       print("Has H")

   if 'Z' not in charset:
       print("Does not have Z")

   # Check by codepoint
   if 0x48 in charset:  # 0x48 = 'H'
       print("Has H (by codepoint)")

   # Iterate over all codepoints
   print("Characters in charset:")
   for codepoint in charset:
       char = chr(codepoint)
       print(f"  U+{codepoint:04X} = '{char}'")

Finding Fonts for Specific Text
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Find fonts that can render a given string by checking character support::

   import fontconfig

   def find_fonts_for_text(text, max_results=10):
       """Find fonts that support all characters in the text."""
       # Create charset from text
       required_chars = fontconfig.CharSet.from_string(text)

       # Get all system fonts
       all_fonts = fontconfig.list(select=("family", "file", "charset"))

       # Filter fonts that support all required characters
       compatible_fonts = []
       for font in all_fonts:
           if 'charset' not in font:
               continue

           font_charset = font['charset']

           # Check if font supports all characters
           all_supported = all(char in font_charset for char in text)
           if all_supported:
               compatible_fonts.append(font)
               if len(compatible_fonts) >= max_results:
                   break

       return compatible_fonts

   # Example: Find fonts for Chinese text
   chinese_text = "你好世界"
   fonts = find_fonts_for_text(chinese_text)

   print(f"Fonts that support '{chinese_text}':")
   for font in fonts:
       print(f"  {font['family']}")

   # Example: Find fonts for mathematical symbols
   math_text = "∑∫∂∇"
   fonts = find_fonts_for_text(math_text, max_results=5)

   print(f"\nFonts that support math symbols:")
   for font in fonts:
       print(f"  {font['family']}")

**Performance Note**: Checking character support for every font in the system
can be slow. For better performance, filter by language first::

   # More efficient: Filter by language first
   japanese_fonts = fontconfig.list(
       properties={"lang": ["ja"]},
       select=("family", "file", "charset")
   )

   # Then check character support within filtered results
   text = "こんにちは"
   for font in japanese_fonts:
       if 'charset' in font:
           charset = font['charset']
           if all(char in charset for char in text):
               print(f"Compatible: {font['family']}")

Getting Font CharSets
^^^^^^^^^^^^^^^^^^^^^^

Access the charset property from font patterns::

   import fontconfig

   # Get charset from matched font
   font = fontconfig.match(":family=Arial")
   if 'charset' in font:
       charset = font['charset']
       print(f"Font supports {len(charset)} characters")

       # Check specific character support
       if 'é' in charset:
           print("Supports accented characters")

       if '中' in charset:
           print("Supports Chinese characters")

   # List fonts with their character counts
   fonts = fontconfig.list(select=("family", "charset"))

   for font in fonts[:20]:  # First 20
       if 'charset' in font:
           count = len(font['charset'])
           print(f"{font['family']}: {count} characters")

Font Properties Reference
--------------------------

The following font properties are supported in patterns (for matching/filtering) and
can be used in the ``select`` parameter (for retrieving values). This applies to all
three high-level functions: :py:func:`match`, :py:func:`sort`, and :py:func:`list`.

.. list-table::
   :header-rows: 1
   :widths: 15 10 50

   * - Property
     - Type
     - Description
   * - family
     - String
     - Font family names
   * - familylang
     - String
     - Language corresponding to each family name
   * - style
     - String
     - Font style. Overrides weight and slant
   * - stylelang
     - String
     - Language corresponding to each style name
   * - fullname
     - String
     - Font face full name where different from family and family + style
   * - fullnamelang
     - String
     - Language corresponding to each fullname
   * - slant
     - Int
     - Italic, oblique or roman (0=roman, 100=italic, 110=oblique)
   * - weight
     - Int
     - Light, medium, demibold, bold or black (0=thin, 80=normal, 200=bold)
   * - width
     - Int
     - Condensed, normal or expanded
   * - size
     - Double
     - Point size
   * - aspect
     - Double
     - Stretches glyphs horizontally before hinting
   * - pixelsize
     - Double
     - Pixel size
   * - spacing
     - Int
     - Proportional, dual-width, monospace or charcell
   * - foundry
     - String
     - Font foundry name
   * - antialias
     - Bool
     - Whether glyphs can be antialiased
   * - hintstyle
     - Int
     - Automatic hinting style (0=none, 1=slight, 2=medium, 3=full)
   * - hinting
     - Bool
     - Whether the rasterizer should use hinting
   * - verticallayout
     - Bool
     - Use vertical layout
   * - autohint
     - Bool
     - Use autohinter instead of normal hinter
   * - globaladvance
     - Bool
     - Use font global advance data (deprecated)
   * - file
     - String
     - The filename holding the font relative to the config's sysroot
   * - index
     - Int
     - The index of the font within the file
   * - ftface
     - FT_Face
     - Use the specified FreeType face object
   * - rasterizer
     - String
     - Which rasterizer is in use (deprecated)
   * - outline
     - Bool
     - Whether the glyphs are outlines
   * - scalable
     - Bool
     - Whether glyphs can be scaled
   * - dpi
     - Double
     - Target dots per inch
   * - rgba
     - Int
     - Subpixel geometry: unknown, rgb, bgr, vrgb, vbgr, none
   * - scale
     - Double
     - Scale factor for point->pixel conversions (deprecated)
   * - minspace
     - Bool
     - Eliminate leading from line spacing
   * - charset
     - CharSet
     - Unicode chars encoded by the font
   * - lang
     - LangSet
     - Set of RFC-3066-style languages this font supports
   * - fontversion
     - Int
     - Version number of the font
   * - capability
     - String
     - List of layout capabilities in the font
   * - fontformat
     - String
     - String name of the font format
   * - embolden
     - Bool
     - Rasterizer should synthetically embolden the font
   * - embeddedbitmap
     - Bool
     - Use the embedded bitmap instead of the outline
   * - decorative
     - Bool
     - Whether the style is a decorative variant
   * - lcdfilter
     - Int
     - Type of LCD filter
   * - namelang
     - String
     - Language name to be used for default value of familylang, stylelang, fullnamelang
   * - fontfeatures
     - String
     - List of extra feature tags in OpenType to be enabled
   * - prgname
     - String
     - Name of the running program
   * - hash
     - String
     - SHA256 hash value of the font data with "sha256:" prefix (deprecated)
   * - postscriptname
     - String
     - Font name in PostScript
   * - symbol
     - Bool
     - Whether font uses MS symbol-font encoding
   * - color
     - Bool
     - Whether any glyphs have color
   * - fontvariations
     - String
     - Comma-separated string of axes in variable font
   * - variable
     - Bool
     - Whether font is Variable Font
   * - fonthashint
     - Bool
     - Whether font has hinting
   * - order
     - Int
     - Order number of the font

Troubleshooting
---------------

Cannot load default config file
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you encounter the following error::

   Fontconfig error: Cannot load default config file: No such file: (null)

This indicates that fontconfig cannot find its configuration files. This error
occurred in previous releases that incorrectly skipped setting the ``--sysconfdir``
flag during the build process.

**Solution:** Set the ``FONTCONFIG_PATH`` environment variable to specify the
configuration directory location. For example::

   export FONTCONFIG_PATH=/etc/fonts

Or in Python before importing fontconfig::

   import os
   os.environ['FONTCONFIG_PATH'] = '/etc/fonts'
   import fontconfig

Common configuration paths by platform:

- **Linux**: ``/etc/fonts``
- **macOS (Homebrew)**: ``/opt/homebrew/etc/fonts`` or ``/usr/local/etc/fonts``
- **macOS (System)**: ``/etc/fonts`` or ``/System/Library/Fonts``

If you're using a recent version of fontconfig-py (v0.2.0 or later), this issue
should be resolved. Consider upgrading::

   pip install --upgrade fontconfig-py
