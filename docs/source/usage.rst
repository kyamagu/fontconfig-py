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

:py:class:`Pattern` objects can be created, modified, and parsed::

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

Common Pattern Properties
-------------------------

Here are commonly used pattern properties:

- ``family``: Font family name (string)
- ``style``: Font style name (string)
- ``slant``: Italic, oblique, or roman (integer: 0=roman, 100=italic, 110=oblique)
- ``weight``: Font weight (integer: 0=thin, 80=normal, 200=bold, 205=extra bold, 210=black)
- ``size``: Font size in points (float)
- ``aspect``: Aspect ratio (float)
- ``file``: Font file path (string)
- ``lang``: Supported languages (list of strings)
- ``antialias``: Whether to antialias (boolean)
- ``hinting``: Whether to hint (boolean)
- ``hintstyle``: Hint style (integer: 0=none, 1=slight, 2=medium, 3=full)

For a complete list of properties, refer to the fontconfig documentation.

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
