Getting Started
===============

fontconfig-py provides three high-level functions that align with the core fontconfig
library operations:

- :py:func:`fontconfig.match` - Find the **single best** matching font (wraps ``FcFontMatch``)
- :py:func:`fontconfig.sort` - Get fonts **sorted by match quality** (wraps ``FcFontSort``)
- :py:func:`fontconfig.list` - **List all** matching fonts (wraps ``FcFontList``)

Choosing the Right Function
----------------------------

- **Need one font?** Use :py:func:`match`
- **Need best matches in order?** Use :py:func:`sort`
- **Need to enumerate all fonts?** Use :py:func:`list`

Finding the Best Font (match)
------------------------------

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
-----------------------------------

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
----------------------------------

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
