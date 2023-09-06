# fontconfig-py

[![PyPI version](https://badge.fury.io/py/fontconfig-py.svg)](https://pypi.org/project/fontconfig-py)
[![Docs status](https://readthedocs.org/projects/fontconfig-py/badge/)](https://fontconfig-py.readthedocs.io/)

Python bindings to [fontconfig](https://www.freedesktop.org/wiki/Software/fontconfig/) based on Cython.

Currently, Linux and macOS are supported.

## Install

Install from the PyPI:

```bash
pip install fontconfig-py
```

## Usage

The following demonstrates the usage of `fontconfig.query` to identify English
fonts in the system:

```python
import fontconfig

fonts = fontconfig.query(where=":lang=en", select=("family",))
for font in fonts:
    print(font["family"])
```

## Development notes

There are other Python wrappers for fontconfig:

- [fontconfig](https://pypi.org/project/fontconfig/): CFFI bindings for fontconfig
- [python_fontconfig](https://github.com/ldo/python_fontconfig): Python wrapper based on ctypes
- [Python_fontconfig](https://pypi.org/project/Python-fontconfig/): Unmaintained Cython wrapper

The features of this package are the following:

- Cython-based wrapper
- Statically linked binary wheels; no runtime dependency
- Continuous integration to the PyPI distribution
- [User documentation](https://fontconfig-py.readthedocs.io/)
- MIT license

## License notice

This project is distributed under [MIT license](LICENSE.txt).
The binary wheels link [fontconfig](https://www.fontconfig.org) and [freetype](https://www.freetype.org) which are distributed under different licenses.
See [THIRD-PARTY-NOTICES.txt](THIRD-PARTY-NOTICES.txt).
