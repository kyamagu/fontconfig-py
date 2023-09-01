from distutils.core import Extension

from Cython.Build import cythonize

ext_modules = [
    Extension(
        "fontconfig.fontconfig",
        sources=["src/fontconfig/fontconfig.pyx"],
        libraries=["fontconfig", "freetype", "expat", "z"],
    ),
]

def build(setup_kwargs):
    options = dict(
        ext_modules=cythonize(ext_modules),
    )
    setup_kwargs.update(options)
