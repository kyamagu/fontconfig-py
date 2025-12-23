# fontconfig-py

[![PyPI version](https://badge.fury.io/py/fontconfig-py.svg)](https://pypi.org/project/fontconfig-py)
[![Docs status](https://readthedocs.org/projects/fontconfig-py/badge/)](https://fontconfig-py.readthedocs.io/)

Python bindings to [fontconfig](https://www.freedesktop.org/wiki/Software/fontconfig/) based on Cython.

**What is fontconfig?** Fontconfig is a library for configuring and customizing font access on Unix-based systems. It helps applications locate installed fonts and select the best matching font based on criteria like family name, weight, slant, and language support. Instead of hardcoding font paths, applications use fontconfig to query the system's font database.

Currently, Linux and macOS are supported.

## Install

Install from PyPI:

```bash
pip install fontconfig-py
```

## Usage

### Finding the best matching font

Use `fontconfig.match()` to find the single best font matching your criteria:

```python
import fontconfig

# Find the best Arial font
font = fontconfig.match(":family=Arial:weight=200")
if font:
    print(font["family"], font["file"])

# Or using a properties dict
font = fontconfig.match(properties={"family": "Arial", "weight": 200})
```

### Listing all matching fonts

Use `fontconfig.list()` to get all fonts matching a pattern:

```python
import fontconfig

# List all English fonts
fonts = fontconfig.list(":lang=en", select=("family", "file"))
for font in fonts:
    print(font["family"], font["file"])

# List all available fonts
all_fonts = fontconfig.list()
```

### Getting sorted font results

Use `fontconfig.sort()` to get fonts sorted by match quality:

```python
import fontconfig

# Get Arial fonts sorted by match quality
fonts = fontconfig.sort(":family=Arial")
for font in fonts[:5]:  # Top 5 matches
    print(font["family"], font["file"])
```

## Documentation

For detailed API documentation and advanced usage, visit [fontconfig-py.readthedocs.io](https://fontconfig-py.readthedocs.io/).

## Features

This package offers several advantages over other fontconfig wrappers:

- **Cython-based wrapper** - High performance with Pythonic API
- **Statically linked binary wheels** - No runtime dependencies on fontconfig or freetype
- **Cross-platform support** - Linux and macOS wheels available
- **Modern high-level API** - Simple `match()`, `list()`, and `sort()` functions
- **Continuous integration** - Automated PyPI releases and testing
- **MIT license** - Permissive licensing

### Other Python fontconfig wrappers

- [fontconfig](https://pypi.org/project/fontconfig/): CFFI bindings for fontconfig
- [python_fontconfig](https://github.com/ldo/python_fontconfig): Python wrapper based on ctypes
- [Python_fontconfig](https://pypi.org/project/Python-fontconfig/): Unmaintained Cython wrapper

## Contributing

Contributions are welcome! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on:

- Setting up the development environment
- Running tests and code quality checks
- Submitting pull requests
- Code of conduct

For security vulnerabilities, please see our [Security Policy](SECURITY.md).

## License

This project is distributed under [MIT license](LICENSE).

The binary wheels bundle [fontconfig](https://www.fontconfig.org) and [freetype](https://www.freetype.org), which are distributed under their respective licenses. See [NOTICE](NOTICE) for details.
