.. _troubleshooting_reference:

Troubleshooting Reference
=========================

This section covers common error scenarios and how to handle them gracefully.

Error Handling and Edge Cases
------------------------------

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
~~~~~~~~~~~~~~~~~~~~~~~

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

Common Issues
-------------

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
