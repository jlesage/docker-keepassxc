#
# keepassxc Dockerfile
#
# https://github.com/jlesage/docker-keepassxc
#

# Docker image version is provided via build arg.
ARG DOCKER_IMAGE_VERSION=

# Define software versions.
ARG KEEPASSXC_VERSION=2.7.11

# Define software download URLs.
ARG KEEPASSXC_URL=https://github.com/keepassxreboot/keepassxc/releases/download/2.7.11/keepassxc-${KEEPASSXC_VERSION}-src.tar.xz

# Get Dockerfile cross-compilation helpers.
FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx

# Build KeePassXC.
FROM --platform=$BUILDPLATFORM alpine:3.20 AS keepassxc
ARG TARGETPLATFORM
ARG KEEPASSXC_URL
COPY --from=xx / /
COPY src/keepassxc /build
RUN /build/build.sh "$KEEPASSXC_URL"
RUN xx-verify /tmp/keepassxc-install/usr/bin/keepassxc

# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.20-v4.10.6

ARG KEEPASSXC_VERSION
ARG DOCKER_IMAGE_VERSION

# Define working directory.
WORKDIR /tmp

# Install dependencies.
RUN add-pkg \
        qt5-qtbase-x11 \
        qt5-qtsvg \
        adwaita-qt \
        botan-libs \
        minizip \
        pcsc-lite-libs \
        libqrencode \
        argon2-libs \
        # A font is needed.
        font-croscore

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://raw.githubusercontent.com/jlesage/docker-templates/master/jlesage/images/keepassxc-icon.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /
COPY --from=keepassxc /tmp/keepassxc-install /

# Set internal environment variables.
RUN \
    set-cont-env APP_NAME "KeePassXC" && \
    set-cont-env APP_VERSION "$KEEPASSXC_VERSION" && \
    set-cont-env DOCKER_IMAGE_VERSION "$DOCKER_IMAGE_VERSION" && \
    true

# Define mountable directories.
VOLUME ["/storage"]

# Metadata.
LABEL \
      org.label-schema.name="keepassxc" \
      org.label-schema.description="Docker container for KeePassXC" \
      org.label-schema.version="${DOCKER_IMAGE_VERSION:-unknown}" \
      org.label-schema.vcs-url="https://github.com/jlesage/docker-keepassxc" \
      org.label-schema.schema-version="1.0"
