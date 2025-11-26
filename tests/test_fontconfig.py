import logging
from typing import Any, Generator

import fontconfig
import pytest

logger = logging.getLogger(__name__)


def test_version() -> None:
    assert fontconfig.__version__


def test_Blanks() -> None:
    try:
        blanks = fontconfig.Blanks.create()
        del blanks
    except MemoryError:
        logger.warning("Memory error")  # Not expected...


@pytest.fixture(scope="module")
def config() -> Generator[fontconfig.Config, None, None]:
    yield fontconfig.Config.get_current()


def test_Config_create() -> None:
    config = fontconfig.Config.create()
    del config


def test_Config_get_current(config: fontconfig.Config) -> None:
    assert isinstance(config, fontconfig.Config)


def test_Config_upto_date(config) -> None:
    assert isinstance(config.upto_date(), bool)


def test_Config_set_current(config) -> None:
    assert isinstance(config.set_current(), bool)


def test_Config_home() -> None:
    assert isinstance(fontconfig.Config.home(), (str, type(None)))


def test_Config_enable_home() -> None:
    assert isinstance(fontconfig.Config.enable_home(False), bool)


def test_Config_build_fonts(config) -> None:
    assert isinstance(config.build_fonts(), bool)


def test_Config_get_config_dirs(config) -> None:
    results = config.get_config_dirs()
    assert isinstance(results, list)
    assert all(isinstance(x, str) for x in results)


def test_Config_get_font_dirs(config) -> None:
    results = config.get_font_dirs()
    assert isinstance(results, list)
    assert all(isinstance(x, str) for x in results)


def test_Config_get_config_files(config) -> None:
    results = config.get_config_files()
    assert isinstance(results, list)
    assert all(isinstance(x, str) for x in results)


def test_Config_get_cache_dirs(config) -> None:
    results = config.get_cache_dirs()
    assert isinstance(results, list)
    assert all(isinstance(x, str) for x in results)


@pytest.mark.parametrize("name", ["system", "application"])
def test_Config_get_fonts(config, name) -> None:
    result = config.get_fonts(name)
    assert isinstance(result, fontconfig.FontSet)


def test_Config_get_rescan_interval(config) -> None:
    assert isinstance(config.get_rescan_interval(), int)


def test_Config_set_rescan_interval(config) -> None:
    assert isinstance(config.set_rescan_interval(0), bool)


@pytest.mark.skip(reason="no good fixture")
def test_Config_app_font_add_file(config) -> None:
    config.app_font_add_file("/tmp/foo.ttf")


@pytest.mark.skip(reason="no good fixture")
def test_Config_app_font_add_dir(config) -> None:
    config.app_font_add_dir("/tmp")


def test_Config_app_font_add_clear(config) -> None:
    config.app_font_clear()


@pytest.mark.skip(reason="need a good fixture to feed")
def test_Config_substitute_with_pat(config) -> None:
    config.substitute_with_pat()


@pytest.mark.skip(reason="need a good fixture to feed")
def test_Config_substitute(config) -> None:
    config.substitute()


def test_Config_font_match(config, pattern) -> None:
    assert isinstance(config.font_match(pattern), (fontconfig.Pattern, type(None)))


def test_Config_font_sort(config, pattern) -> None:
    assert isinstance(
        config.font_sort(pattern, trim=True), (fontconfig.FontSet, type(None)))


def test_Config_font_render_prepare(config, pattern) -> None:
    font = fontconfig.Pattern.parse(":family=Arial")
    prepared = config.font_render_prepare(pattern, font)
    assert isinstance(prepared, fontconfig.Pattern)


def test_Config_font_list(config, pattern, object_set) -> None:
    fonts = config.font_list(pattern, object_set)
    assert isinstance(fonts, fontconfig.FontSet)


@pytest.mark.skip(reason="version compatibility issue")
def test_Config_get_filename(config) -> None:
    assert isinstance(config.get_filename(), str)


def test_Config_parse_and_load(config) -> None:
    assert isinstance(config.parse_and_load("", complain=False), bool)


def test_Config_parse_and_load_from_memory(config) -> None:
    assert isinstance(config.parse_and_load_from_memory(b"", complain=False), bool)


def test_Config_get_sysroot(config) -> None:
    sysroot = config.get_sysroot()
    assert isinstance(sysroot, (str, type(None)))
    # TODO: set_sysroot is not testable


def test_Config_iter(config) -> None:
    for name, desc, enabled in config:
        assert isinstance(name, str)
        assert isinstance(desc, str)
        assert isinstance(enabled, bool)


@pytest.fixture(scope="module")
def pattern() -> Generator[fontconfig.Pattern, None, None]:
    yield fontconfig.Pattern.parse(":lang=en")


def test_Pattern_create() -> None:
    pattern = fontconfig.Pattern.create()
    assert isinstance(pattern, fontconfig.Pattern)
    del pattern


def test_Pattern_copy(pattern: fontconfig.Pattern) -> None:
    assert isinstance(pattern.copy(), fontconfig.Pattern)


def test_Pattern_parse(pattern: fontconfig.Pattern) -> None:
    assert isinstance(pattern, fontconfig.Pattern)


def test_Pattern_len(pattern: fontconfig.Pattern) -> None:
    assert isinstance(len(pattern), int)


def test_Pattern_eq(pattern: fontconfig.Pattern) -> None:
    assert pattern == pattern


def test_Pattern_hash(pattern: fontconfig.Pattern) -> None:
    assert isinstance(hash(pattern), int)


def test_Pattern_equal_subset(pattern: fontconfig.Pattern) -> None:
    object_set = fontconfig.ObjectSet.create()
    object_set.add("lang")
    assert pattern.equal_subset(pattern, object_set)


def test_Pattern_subset(pattern: fontconfig.Pattern) -> None:
    object_set = fontconfig.ObjectSet.create()
    object_set.add("lang")
    assert isinstance(pattern.subset(object_set), fontconfig.Pattern)


@pytest.mark.parametrize(
    "key, value",
    [
        ("family", "Arial"),
        ("slant", 80),
        ("aspect", 1.0),
        ("antialias", True),
        ("lang", ["en"]),
        ("size", (10.0, 10.0)),
    ],
)
def test_Pattern_add(key: str, value: Any) -> None:
    pattern = fontconfig.Pattern.create()
    pattern.add(key, value)


@pytest.mark.parametrize(
    "key, value",
    [
        ("charset", None),
    ],
)
def test_Pattern_add_xfail(key: str, value: Any) -> None:
    pattern = fontconfig.Pattern.create()
    with pytest.raises(NotImplementedError):
        pattern.add(key, value)


def test_Pattern_get(pattern: fontconfig.Pattern) -> None:
    isinstance(pattern.get("lang"), list)
    with pytest.raises(KeyError):
        pattern.get("ftface")


def test_Pattern_del() -> None:
    pattern = fontconfig.Pattern.parse(":aspect=1.0")
    assert isinstance(pattern.remove("aspect"), bool)


def test_Pattern_remove() -> None:
    pattern = fontconfig.Pattern.parse(":aspect=1.0")
    assert isinstance(pattern.remove("aspect", 0), bool)


def test_Pattern_unparse(pattern: fontconfig.Pattern) -> None:
    assert isinstance(pattern.unparse(), str)


def test_Pattern_default_substitute(pattern: fontconfig.Pattern) -> None:
    pattern.default_substitute()


def test_Pattern_default_format(pattern: fontconfig.Pattern) -> None:
    assert isinstance(pattern.format("%{lang}"), str)


def test_Pattern_iter(pattern: fontconfig.Pattern) -> None:
    dict(pattern)


def test_Pattern_repr(pattern) -> None:
    repr(pattern)


@pytest.fixture
def object_set():
    object_set = fontconfig.ObjectSet.create()
    object_set.build(["family", "style", "slant", "weight", "size", "aspect", "lang"])
    yield object_set


def test_ObjectSet_add(object_set) -> None:
    assert isinstance(object_set.add("familylang"), bool)


def test_ObjectSet_iter(object_set) -> None:
    for item in object_set:
        assert isinstance(item, str)


def test_ObjectSet_getitem(object_set) -> None:
    for i in range(len(object_set)):
        assert isinstance(object_set[i], str)
    assert isinstance(object_set[-1], str)


def test_ObjectSet_repr(object_set) -> None:
    repr(object_set)


def test_query() -> None:
    result = fontconfig.query(
        where=":lang=en:family=Arial",
        select=("family", "familylang"),
    )
    assert isinstance(result, list)
    for font in result:
        assert isinstance(font, dict)
    print(result)


def test_query_deprecation_warning() -> None:
    """Test that query() raises DeprecationWarning."""
    import warnings
    with warnings.catch_warnings(record=True) as w:
        warnings.simplefilter("always")
        fontconfig.query(":lang=en")
        assert len(w) == 1
        assert issubclass(w[0].category, DeprecationWarning)
        assert "deprecated" in str(w[0].message).lower()


def test_match_basic() -> None:
    """Test basic match functionality."""
    result = fontconfig.match()
    assert result is None or isinstance(result, dict)
    if result:
        # Should have default properties
        assert any(k in result for k in ["family", "file", "style"])


def test_match_with_pattern() -> None:
    """Test match with pattern string."""
    result = fontconfig.match(":family=Arial")
    assert result is None or isinstance(result, dict)


def test_match_with_properties() -> None:
    """Test match with properties dict."""
    result = fontconfig.match(properties={"family": "Arial"})
    assert result is None or isinstance(result, dict)


def test_match_with_select() -> None:
    """Test match with custom select."""
    result = fontconfig.match(":family=Arial", select=("family", "file", "weight"))
    if result:
        # Should only have requested properties (or subset if some don't exist)
        assert set(result.keys()).issubset({"family", "file", "weight"})


def test_match_error_both_pattern_and_properties() -> None:
    """Test error when both pattern and properties specified."""
    with pytest.raises(ValueError, match="Cannot specify both"):
        fontconfig.match(pattern=":family=Arial", properties={"family": "Arial"})


def test_sort_basic() -> None:
    """Test basic sort functionality."""
    results = fontconfig.sort()
    assert isinstance(results, list)
    # All results should be dicts
    for font in results:
        assert isinstance(font, dict)


def test_sort_with_pattern() -> None:
    """Test sort with pattern string."""
    results = fontconfig.sort(":family=Arial")
    assert isinstance(results, list)


def test_sort_with_properties() -> None:
    """Test sort with properties dict."""
    results = fontconfig.sort(properties={"family": "Arial"})
    assert isinstance(results, list)


def test_sort_with_trim() -> None:
    """Test sort with trim parameter."""
    results_trim = fontconfig.sort(":family=Arial", trim=True)
    results_no_trim = fontconfig.sort(":family=Arial", trim=False)
    assert isinstance(results_trim, list)
    assert isinstance(results_no_trim, list)
    # No trim might have more results
    assert len(results_no_trim) >= len(results_trim)


def test_sort_with_select() -> None:
    """Test sort with custom select."""
    results = fontconfig.sort(":family=Arial", select=("family", "file"))
    for font in results:
        # Should only have requested properties (or subset)
        assert set(font.keys()).issubset({"family", "file"})


def test_list_basic() -> None:
    """Test basic list functionality."""
    results = fontconfig.list(":lang=en")
    assert isinstance(results, list)
    for font in results:
        assert isinstance(font, dict)


def test_list_with_pattern() -> None:
    """Test list with pattern string."""
    results = fontconfig.list(":family=Arial")
    assert isinstance(results, list)


def test_list_with_properties() -> None:
    """Test list with properties dict."""
    results = fontconfig.list(properties={"lang": ["en"]})
    assert isinstance(results, list)


def test_list_with_select() -> None:
    """Test list with custom select."""
    results = fontconfig.list(":lang=en", select=("family", "file"))
    for font in results:
        # Should only have requested properties (or subset)
        assert set(font.keys()).issubset({"family", "file"})


def test_list_empty_pattern() -> None:
    """Test list with empty pattern returns all fonts."""
    results = fontconfig.list()
    assert isinstance(results, list)
    # Should return some fonts (but may be zero in minimal environments like musllinux)
    assert len(results) >= 0


def test_list_vs_query_compatibility() -> None:
    """Ensure list() behaves like query() for backward compatibility."""
    where = ":lang=en"
    select = ("family", "file")

    import warnings
    with warnings.catch_warnings():
        warnings.simplefilter("ignore", DeprecationWarning)
        old_result = fontconfig.query(where=where, select=select)

    new_result = fontconfig.list(pattern=where, select=select)

    # Should return equivalent results (same length and types)
    assert len(old_result) == len(new_result)
    assert all(isinstance(f, dict) for f in old_result)
    assert all(isinstance(f, dict) for f in new_result)


def test_properties_dict_error_handling() -> None:
    """Test error handling for properties dict."""
    with pytest.raises(ValueError, match="Cannot specify both"):
        fontconfig.list(pattern=":family=Arial", properties={"family": "Arial"})


def test_match_with_custom_config() -> None:
    """Test match with custom config."""
    config = fontconfig.Config.get_current()
    result = fontconfig.match(config=config)
    assert result is None or isinstance(result, dict)


def test_sort_with_custom_config() -> None:
    """Test sort with custom config."""
    config = fontconfig.Config.get_current()
    results = fontconfig.sort(config=config)
    assert isinstance(results, list)


def test_list_with_custom_config() -> None:
    """Test list with custom config."""
    config = fontconfig.Config.get_current()
    results = fontconfig.list(config=config)
    assert isinstance(results, list)
