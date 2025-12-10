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
    asciidoctor \
    qtchooser \
    qt5-qtbase-dev \
    qt5-qttools-dev \

xx-apk --no-cache --no-scripts add \
    musl-dev \
    gcc \
    g++ \
    qt5-qtbase-dev \
    qt5-qttools-dev \
    qt5-qtsvg-dev \
    qt5-qtx11extras-dev \
    botan-dev \
    zlib-dev \
    minizip-dev \
    pcsc-lite-dev \
    libqrencode-dev \
    argon2-dev \

# Make sure tools used to generate code are the ones from the host.
if [ "$(xx-info sysroot)" != "/" ]
then
    ln -sf /usr/bin/moc $(xx-info sysroot)usr/lib/qt5/bin/moc
    ln -sf /usr/bin/uic $(xx-info sysroot)usr/lib/qt5/bin/uic
    ln -sf /usr/bin/rcc $(xx-info sysroot)usr/lib/qt5/bin/rcc
    ln -sf /usr/bin/qdbusxml2cpp $(xx-info sysroot)usr/lib/qt5/bin/qdbusxml2cpp
    ln -sf /usr/bin/lrelease $(xx-info sysroot)usr/lib/qt5/bin/lrelease
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
        -DWITH_XC_DOCS=OFF \
        -DWITH_XC_AUTOTYPE=OFF \
        -DWITH_XC_YUBIKEY=OFF \
        -DWITH_XC_BROWSER=OFF \
        -DWITH_XC_NETWORKING=ON \
        -DWITH_XC_SSHAGENT=ON \
        -DWITH_XC_FDOSECRETS=OFF \
        -DWITH_XC_KEESHARE=ON \
        -DWITH_XC_UPDATECHECK=OFF \
        -DWITH_TESTS=OFF \
        -DWITH_GUI_TESTS=OFF \
        -DWITH_DEV_BUILD=OFF \
        -DKEEPASSXC_BUILD_TYPE=Release \
        ..
)

log "Compiling KeePassXC..."
make -C /tmp/keepassxc/build -j$(nproc)

log "Installing KeePassXC..."
make DESTDIR=/tmp/keepassxc-install -C /tmp/keepassxc/build install
