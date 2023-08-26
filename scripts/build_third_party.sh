#!/usr/bin/env bash

set -eux

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
if [[ "$OSTYPE" == "darwin"* ]]; then
    # TODO: This will conflict with brew-installed freetype and fontconfig
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
