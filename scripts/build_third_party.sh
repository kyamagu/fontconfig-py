#!/usr/bin/env bash

set -eux

FREETYPE_VERSION=${FREETYPE_VERSION:-"VER-2-13-0"}
FONTCONFIG_VERSION=${FONTCONFIG_VERSION:-"2.14.0"}

build_freetype() {
    cd third_party/freetype
    ./autogen.sh
    ./configure
    make
    make -j
    make install
    cd ../..
}

build_fontconfig() {
    cd third_party/fontconfig
    ./autogen.sh
    make -j
    make install
    cd ../..
}

# Install build dependencies
if command -v yum &> /dev/null; then
    yum --disablerepo=epel install -y gperf gettext-devel libuuid-devel
elif command -v apk &> /dev/null; then
    apk add gperf gettext-dev util-linux-dev
elif command -v apt &> /dev/null; then
    apt install gperf gettext uuid-dev
elif command -v brew &> /dev/null; then
    brew install gperftools gettext automake
else
    exit 1
fi

build_freetype
build_fontconfig
