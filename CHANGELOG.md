# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0] - 2025-12-08

### Added

- Pythonic CharSet support with comprehensive API
  - Factory methods: `CharSet.from_string()`, `CharSet.from_codepoints()`
  - Modification methods: `add()`, `discard()`
  - Inspection methods: `__len__()`, `__contains__()`, `__iter__()`, `__eq__()`, `__repr__()`
  - Utility method: `copy()`
- CharSet integration with fontconfig queries (match, sort, list)
  - Auto-conversion from strings and codepoint iterables
  - Support for both character strings and integer codepoints
  - Seamless integration with Pattern objects
- 40 comprehensive test cases for CharSet functionality
  - Creation, modification, inspection, iteration tests
  - Integration tests with public APIs
  - Edge case handling (empty charsets, invalid inputs, Unicode planes)

### Documentation

- Added beginner-friendly cookbook with 8 common font search patterns
  - Finding monospace fonts, fonts by language, bold/italic variants
  - Checking font existence with fallbacks, system defaults
  - Color/emoji support, variable fonts, getting file paths
- Added error handling and edge cases section
  - Handling None results, empty results, invalid properties
  - Pattern parsing errors, safe property access
- Added working with character sets section
  - CharSet creation and usage examples
  - Character membership checking
  - Finding fonts for specific text
  - Performance optimization tips
- Expanded pattern documentation
  - Complete pattern syntax reference
  - Property value types and examples
  - Pattern strings vs properties dict comparison
  - Dynamic pattern building examples
  - Common pattern mistakes guide
- Consolidated installation documentation in index.rst
- 800+ lines of practical, real-world examples

## [0.3.1] - 2025-12-08

### Fixed

- Fixed TypeError when using single integer/float values for range properties (#36)
  - `fontconfig.match(properties={"weight": 200})` now works correctly
  - Single int/float values are automatically converted to ranges [value, value]
  - Matches the behavior of pattern strings like `:weight=200`

### Changed

- Implemented single-source versioning from `__init__.py`

### Documentation

- Updated README with modern API examples and improved structure

## [0.3.0] - 2025-11-26

### Added

- New high-level API functions aligned with fontconfig core operations:
  - `match()` - Find the single best matching font (wraps `FcFontMatch`)
  - `sort()` - Get fonts sorted by match quality (wraps `FcFontSort`)
  - `list()` - List all matching fonts (wraps `FcFontList`)
- Properties dict parameter support for all new functions (alternative to pattern strings)
- Custom config parameter support for all high-level functions
- Comprehensive test coverage for new API functions

### Deprecated

- `query()` function is now deprecated in favor of `match()`, `sort()`, or `list()`
  - A `DeprecationWarning` is now raised when using `query()`
  - The function remains fully functional for backward compatibility

### Changed

- Restructured usage documentation with clear guidance on choosing the right function
- Added examples for all three new high-level functions
- Updated documentation to show equivalents to `fc-match`, `fc-match -s`, and `fc-list` CLI tools
- Added migration guide from `query()` to new functions

## [0.2.1] - 2025-11-25

### Fixed

- Fixed fontconfig build paths and added Homebrew check for macOS compatibility
- Fixed _FcSetName enum import warning

### Documentation

- Expanded usage documentation with comprehensive examples
- Improved API documentation and usage patterns

## [0.2.0] - 2024-01-XX

### Added

- Type hint support with mypy and stub files
- CLAUDE.md documentation for Claude Code integration

### Changed

- Migrated from Poetry to uv package manager
- Updated build system and fixed build issues

### Fixed

- Fixed license notice for bundled freetype

## [0.1.3] - 2024-XX-XX

### Fixed

- License updates for bundled dependencies

## Earlier Versions

See git history for changes in versions prior to 0.1.3.
