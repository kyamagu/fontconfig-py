import logging
from typing import Any

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
def config() -> fontconfig.Config:
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


def test_Config_font_match(config, pattern):
    assert isinstance(config.match(pattern), fontconfig.Pattern)


def test_Config_font_sort(config, pattern):
    assert isinstance(config.sort(pattern, trim=True), fontconfig.FontSet)


@pytest.fixture(scope="module")
def pattern() -> fontconfig.Pattern:
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


def test_Pattern_iter(pattern: fontconfig.Pattern) -> None:
    dict(pattern)


def test_Pattern_unparse(pattern: fontconfig.Pattern) -> None:
    assert isinstance(pattern.unparse(), str)


def test_Pattern_default_substitute(pattern: fontconfig.Pattern) -> None:
    pattern.default_substitute()


def test_Pattern_default_format(pattern: fontconfig.Pattern) -> None:
    assert isinstance(pattern.format("%{lang}"), str)


@pytest.fixture
def object_set():
    object_set = fontconfig.ObjectSet.create()
    object_set.build(["family", "style", "slant", "weight", "size", "aspect", "lang"])
    yield object_set


def test_query() -> None:
    result = fontconfig.query(
        where=":lang=en:family=Arial",
        select=("family", "familylang"),
    )
    assert isinstance(result, list)
    for font in result:
        assert isinstance(font, dict)
    print(result)
