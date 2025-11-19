# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**fontconfig-py** is a Python package providing Cython-based bindings to the fontconfig library. The project builds statically-linked binary wheels that bundle fontconfig and freetype, eliminating runtime dependencies for users.

**Key characteristics:**

- Cython wrapper around fontconfig C library
- Statically linked binaries (bundles fontconfig and freetype)
- Currently supports Linux and macOS
- MIT license (with bundled dependencies under FTL and fontconfig licenses)

## Architecture

### Core Components

**Cython Layer** ([src/fontconfig/](src/fontconfig/))

- `fontconfig.pyx`: Main Cython implementation exposing Python API
- `_fontconfig.pxd`: Cython declarations for fontconfig C API

**Key Python Classes:**

- `Config`: Holds fontconfig configuration (default or custom)
- `Pattern`: Represents font patterns for matching/querying
- `FontSet`: Container for lists of font patterns
- `ObjectSet`: Defines which properties to return from queries
- `Blanks`: Legacy Unicode blank character handling (deprecated)
- `CharSet`: Set of Unicode characters

**High-level API:**

- `query(where, select)`: Simplified font querying function that wraps Config/Pattern/ObjectSet operations

### Build System

The build process is more complex than typical Python packages due to static linking:

1. **Third-party libraries** (`third_party/` as git submodules):
   - `freetype`: Font rendering engine
   - `fontconfig`: Font configuration library

2. **Build script** (`scripts/build_third_party.sh`):
   - Builds freetype statically with minimal dependencies
   - Builds fontconfig statically on top of freetype
   - Installs to `/usr/local/` (macOS) or system paths (Linux)
   - Handles platform-specific flags (universal2 for macOS)

3. **Python build** (`setup.py`):
   - Uses Cython to compile `.pyx` to C
   - Links against static fontconfig, freetype, expat, and zlib
   - Package discovery via setuptools

4. **CI/CD** (`.github/workflows/wheels.yaml`):
   - Uses cibuildwheel for multi-platform wheel building
   - Runs `build_third_party.sh` before Python build
   - Tests with pytest before uploading wheels
   - Auto-publishes to PyPI on releases

## Development Commands

### Environment Setup

```bash
# Install with development dependencies
uv sync --dev

# Or install docs dependencies
uv sync --group docs
```

### Building from Source

**Important:** Building requires system dependencies and compiling C libraries. For local development, you'll need:

```bash
# Run the third-party build script first
bash scripts/build_third_party.sh

# Then build the Python package
uv build --wheel
```

The build script installs: gperf, gettext, uuid libraries, automake, libtool (platform-dependent).

### Testing

```bash
# Run all tests
uv run pytest tests/

# Run a single test file
uv run pytest tests/test_fontconfig.py

# Run a specific test
uv run tests/test_fontconfig.py::test_query -v
```

**Test fixtures:**

- Tests use module-scoped `config` fixture (current fontconfig config)
- Tests use `pattern` fixture (":lang=en" pattern)
- Tests use `object_set` fixture with common properties

### Code Quality

```bash
# Lint with ruff
uvx ruff check .

# Format with ruff
uvx ruff format .
```

### Documentation

```bash
# Build documentation
cd docs/
make html

# View docs
open build/html/index.html  # macOS
xdg-open build/html/index.html  # Linux
```

## Working with Cython Code

**Key patterns when editing `.pyx` files:**

1. **Memory management**: C pointers must be manually freed
   - Most wrapper classes store a `_ptr` and use `__dealloc__` to free
   - Some objects have `_owner` flag to prevent double-free

2. **Type conversions**:
   - `_ObjectToFcValue()`: Python → fontconfig value
   - `_FcValueToObject()`: fontconfig value → Python
   - String encoding: Python str ↔ UTF-8 bytes ↔ `FcChar8*`

3. **C API patterns**:
   - Most fontconfig functions start with `Fc`
   - Result codes: `FcResultMatch`, `FcResultNoMatch`, `FcResultOutOfMemory`
   - Boolean type is `FcBool` (C int, cast to Python bool)

4. **After editing `.pyx` or `.pxd` files**:

   ```bash
   # Rebuild extension
   uv sync --reinstall
   ```

## Common Patterns

### Querying Fonts

```python
# High-level API (recommended for simple queries)
fonts = fontconfig.query(where=":lang=en:family=Arial", select=("family", "file"))

# Low-level API (more control)
config = fontconfig.Config.get_current()
pattern = fontconfig.Pattern.parse(":lang=en")
object_set = fontconfig.ObjectSet.create()
object_set.add("family")
fonts = config.font_list(pattern, object_set)
```

### Font Matching

```python
config = fontconfig.Config.get_current()
pattern = fontconfig.Pattern.parse(":family=Arial")
pattern.default_substitute()
config.substitute(pattern)
matched = config.font_match(pattern)
```

## Troubleshooting

**Build failures:**

- Ensure git submodules are initialized: `git submodule update --init --recursive`
- Check system dependencies are installed (see `build_third_party.sh`)
- On macOS, ensure Xcode command line tools are installed

**Test failures on "family=Arial":**

- These tests may fail if Arial isn't installed on the system
- Consider using more universal test fonts or system defaults

**Version mismatches:**

- Package version is in `pyproject.toml` (currently 0.1.3)
- `__version__` in `__init__.py` should match (currently 0.1.2 - needs update)

## Release Process

1. Update version in `pyproject.toml`
2. Update `__version__` in `src/fontconfig/__init__.py`
3. Create and push git tag
4. Create GitHub release (triggers wheel build and PyPI upload via CI)
