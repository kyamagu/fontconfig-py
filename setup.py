from Cython.Build import cythonize
from setuptools import setup
from setuptools.extension import Extension

ext_modules = [
    Extension(
        "fontconfig.fontconfig",
        sources=["src/fontconfig/fontconfig.pyx"],
        libraries=["fontconfig", "freetype", "expat", "z"],
    ),
]

setup(ext_modules=cythonize(ext_modules))
