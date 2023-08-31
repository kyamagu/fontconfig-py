Usage
=====

The following demonstrates the usage of :py:func:`fontconfig.query` to
identify English fonts available in the system::

   import fontconfig

   fonts = fontconfig.query(where=":lang=en", select=("family",))
   for font in fonts:
      print(font["family"])
