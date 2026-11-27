#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

# Set same default compilation flags as abuild.
export CFLAGS="-Os -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export CPPFLAGS="$CFLAGS"
export LDFLAGS="-Wl,--strip-all -Wl,--as-needed"

export CC=xx-clang
export CXX=xx-clang++

log() {
    echo ">>> $*"
}

KEEPASSXC_URL="$1"

if [ -z "$KEEPASSXC_URL" ]; then
    log "ERROR: KeePassXC URL missing."
    exit 1
fi

#
# Install required packages.
#
apk --no-cache add \
    curl \
    binutils \
    clang \
    cmake \
    make \
    pkgconf \
    qt6-qtbase-dev \
    qt6-qttools \
    qt6-qttools-dev \

xx-apk --no-cache --no-scripts add \
    musl-dev \
    gcc \
    g++ \
    qt6-qtbase-dev \
    qt6-qttools-dev \
    qt6-qtsvg-dev \
    botan-dev \
    zlib-dev \
    minizip-dev \
    pcsc-lite-dev \
    libqrencode-dev \
    libusb-dev \
    keyutils-dev \
    libxkbcommon-dev \
    libxi-dev \
    libxtst-dev \

# Make sure tools used to generate code are the ones from the host.
if xx-info is-cross; then
    for bin in moc uic rcc; do
        if [ -e "/usr/lib/qt6/libexec/$bin" ]; then
            ln -sf "/usr/lib/qt6/libexec/$bin" "$(xx-info sysroot)usr/lib/qt6/libexec/$bin"
        fi
    done
    for bin in qdbusxml2cpp qdbuscpp2xml lrelease lupdate qtpaths; do
        if [ -e "/usr/lib/qt6/bin/$bin" ]; then
            ln -sf "/usr/lib/qt6/bin/$bin" "$(xx-info sysroot)usr/lib/qt6/bin/$bin"
        fi
    done

    # keyutils-dev ships /usr/lib/libkeyutils.so -> /usr/lib/libkeyutils.so.1.
    # That absolute target is outside the cross sysroot, so find_library misses it.
    so="$(xx-info sysroot)usr/lib/libkeyutils.so"
    if [ -L "$so" ]; then
        ln -sf libkeyutils.so.1 "$so"
    fi

    # libproxy.so.1 records RUNPATH /usr/lib/libproxy. The cross linker searches
    # that host path and misses libpxbackend-1.0.so in the sysroot.
    LDFLAGS="$LDFLAGS -Wl,-rpath-link=$(xx-info sysroot)usr/lib/libproxy"
fi

#
# Download sources.
#

log "Downloading KeePassXC package..."
mkdir /tmp/keepassxc
curl -# -L -f ${KEEPASSXC_URL} | tar xJ --strip 1 -C /tmp/keepassxc

#
# Compile KeePassXC.
#

log "Configuring KeePassXC..."
(
    mkdir /tmp/keepassxc/build && \
    cd /tmp/keepassxc/build && cmake \
        $(xx-clang --print-cmake-defines) \
        -DCMAKE_FIND_ROOT_PATH=$(xx-info sysroot) \
        -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
        -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
        -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY \
        -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_BUILD_TYPE=Release \
        -DKPXC_FEATURE_DOCS=OFF \
        -DKPXC_FEATURE_BROWSER=OFF \
        -DKPXC_FEATURE_NETWORK=ON \
        -DKPXC_FEATURE_SSHAGENT=ON \
        -DKPXC_FEATURE_FDOSECRETS=OFF \
        -DKPXC_FEATURE_UPDATES=OFF \
        -DWITH_X11=ON \
        -DWITH_TESTS=OFF \
        -DWITH_GUI_TESTS=OFF \
        -DKEEPASSXC_BUILD_TYPE=Release \
        ..
)

log "Compiling KeePassXC..."
make -C /tmp/keepassxc/build -j$(nproc)

log "Installing KeePassXC..."
make DESTDIR=/tmp/keepassxc-install -C /tmp/keepassxc/build install
