# fontconfig-py

Python bindings to [fontconfig](https://www.freedesktop.org/wiki/Software/fontconfig/).

Currently Linux and macOS are supported.

## Install

Install from the PyPI:

   pip install fontconfig-py

## Usage

The following demonstrates the usage of `fontconfig.query` to identify English
fonts in the system:

```python
import fontconfig

fonts = fontconfig.query(where=":lang=en", select=("family",))
for font in fonts:
    print(font["family"])
```

## License notice

This project is distributed in [MIT license](LICENSE.txt). The binary wheels
bundles several libraries that may be distributed in different licenses.
See [THIRD-PARTY-NOTICES.txt](THIRD-PARTY-NOTICES.txt).
