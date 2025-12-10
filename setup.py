from Cython.Build import cythonize
from setuptools import setup
from setuptools.extension import Extension
import os

# Enable Limited API (can be disabled with env var for troubleshooting)
USE_LIMITED_API = os.getenv("FONTCONFIG_USE_LIMITED_API", "1") == "1"
PY_LIMITED_API_VERSION = 0x030A0000  # Python 3.10+ (3.9 is EOL)

define_macros = [("Py_LIMITED_API", PY_LIMITED_API_VERSION)] if USE_LIMITED_API else []
py_limited_api = USE_LIMITED_API

ext_modules = [
    Extension(
        "fontconfig.fontconfig",
        sources=["src/fontconfig/fontconfig.pyx"],
        libraries=["fontconfig", "freetype", "expat", "z"],
        define_macros=define_macros,
        py_limited_api=py_limited_api,
    ),
]

setup(
    ext_modules=cythonize(
        ext_modules,
        compiler_directives={"binding": True, "embedsignature": True}
    )
)
