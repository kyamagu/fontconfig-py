Common Patterns
===============

This section shows practical examples for common font search tasks.

Finding Monospace Fonts
------------------------

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
----------------------------------

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
---------------------------------

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
-----------------------------------

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
-----------------------------

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
---------------------------------------

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
-----------------------

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
------------------------

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
----------------------------------------

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
