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
        ("family", b"Arial"),
        ("slant", 80),
        ("aspect", 1.0),
        ("antialias", True),
        ("lang", [b"en"]),
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
