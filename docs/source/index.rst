fontconfig-py
=============

fontconfig-py is a Python wrapper to `fontconfig <https://fontconfig.org>`_,
which is a library for configuring and customizing font access.

Installation
------------

Basic Installation
~~~~~~~~~~~~~~~~~~

Install fontconfig-py from PyPI::

   pip install fontconfig-py

This will install pre-built binary wheels for Linux and macOS that include
statically-linked fontconfig and freetype libraries, so no system dependencies
are required.

Platform Support
~~~~~~~~~~~~~~~~

**Linux**: Works out of the box with system fonts. Supported architectures:

- x86_64 (Intel/AMD 64-bit)
- ARM (64-bit)

**macOS**: Works with system fonts. Universal2 wheels support both Intel and Apple Silicon.

**Windows**: Not currently supported.

Verifying Installation
~~~~~~~~~~~~~~~~~~~~~~

Test that fontconfig-py is working correctly::

   import fontconfig

   # Check version
   print(f"fontconfig version: {fontconfig.get_version()}")

   # Try to match a font
   font = fontconfig.match()
   if font:
       print(f"Default font: {font.get('family')}")
       print("Installation successful!")
   else:
       print("Warning: Could not find fonts")

Quick Start
~~~~~~~~~~~

Find and use a font in three lines::

   import fontconfig

   font = fontconfig.match(":family=Arial:weight=200")
   if font:
       print(f"Font file: {font['file']}")

For detailed usage instructions, see the :doc:`usage` guide.

Troubleshooting
~~~~~~~~~~~~~~~

**Error: "Cannot load default config file"**

If you see this error, fontconfig cannot find its configuration files.
Set the ``FONTCONFIG_PATH`` environment variable::

   export FONTCONFIG_PATH=/etc/fonts  # Linux
   export FONTCONFIG_PATH=/opt/homebrew/etc/fonts  # macOS Homebrew

Or set it in Python before importing::

   import os
   os.environ['FONTCONFIG_PATH'] = '/etc/fonts'
   import fontconfig

See the :ref:`troubleshooting` section in the usage guide for more details.

.. toctree::
   :maxdepth: 2

   usage
   references
