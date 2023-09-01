#!/usr/bin/env bash

set -ex

# Set up cross-compilation on macOS.
HOST_ARCH=${HOST_ARCH:-$(gcc -dumpmachine)}
if [[ $OSTYPE == "darwin"* ]] && [[ "$_PYTHON_HOST_PLATFORM" == *"arm64" ]]; then
    HOST_ARCH="arm64-apple-darwin"
fi


build_freetype() {
    cd third_party/freetype
    ./autogen.sh
    ./configure \
        --host=$HOST_ARCH \
        --disable-shared \
        --with-pic \
        --without-bzip2 \
        --without-png \
        --without-harfbuzz \
        --without-brotli \
        --without-librsvg
    make -j
    make install
    cd ../..
}

build_fontconfig() {
    cd third_party/fontconfig
    ./autogen.sh \
        --host=$HOST_ARCH \
        --disable-shared \
        --with-pic \
        --disable-nls \
        --disable-libxml2 \
        --disable-iconv \
        --disable-docs \
        --disable-cache-build
    make -j
    make install
    cd ../..
}

# Install build dependencies
if [[ "$OSTYPE" == "darwin"* ]]; then
    brew uninstall --ignore-dependencies -f fontconfig freetype
    brew install gperftools gettext automake
elif command -v yum &> /dev/null; then
    yum --disablerepo=epel install -y gperf gettext-devel libuuid-devel
elif command -v apk &> /dev/null; then
    apk add gperf gettext-dev util-linux-dev
elif command -v apt &> /dev/null; then
    apt -y install gperf gettext uuid-dev
else
    exit 1
fi

build_freetype
build_fontconfig
