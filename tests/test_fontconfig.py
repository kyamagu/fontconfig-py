import logging

import fontconfig
import pytest

logger = logging.getLogger(__name__)


def test_version() -> None:
    assert fontconfig.__version__


def test_Blanks() -> None:
    try:
        blanks = fontconfig.Blanks.create()
        del blanks
    except MemoryError as e:
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


# def test_Pattern_add(pattern: fontconfig.Pattern) -> None:
#     pattern.add("family", b"Arial")


def test_Pattern_iter(pattern: fontconfig.Pattern) -> None:
    dict(pattern)


@pytest.fixture
def object_set():
    object_set = fontconfig.ObjectSet.create()
    object_set.build(["family", "style", "slant", "weight", "size", "aspect", "lang"])
    yield object_set


def test_query() -> None:
    result = fontconfig.query(
        where=":lang=ja:family=Hiragino Kaku Gothic Std",
        select=("family", "familylang"),
    )
    assert isinstance(result, list)
    for font in result:
        assert isinstance(font, dict)
    print(result)
