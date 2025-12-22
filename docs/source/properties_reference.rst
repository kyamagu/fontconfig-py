.. _font-properties-reference:

Font Properties Reference
=========================

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
