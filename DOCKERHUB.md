# Docker container for KeePassXC
[![Release](https://img.shields.io/github/release/jlesage/docker-keepassxc.svg?logo=github&style=for-the-badge)](https://github.com/jlesage/docker-keepassxc/releases/latest)
[![Docker Image Size](https://img.shields.io/docker/image-size/jlesage/keepassxc/latest?logo=docker&style=for-the-badge)](https://hub.docker.com/r/jlesage/keepassxc/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/jlesage/keepassxc?label=Pulls&logo=docker&style=for-the-badge)](https://hub.docker.com/r/jlesage/keepassxc)
[![Docker Stars](https://img.shields.io/docker/stars/jlesage/keepassxc?label=Stars&logo=docker&style=for-the-badge)](https://hub.docker.com/r/jlesage/keepassxc)
[![Build Status](https://img.shields.io/github/actions/workflow/status/jlesage/docker-keepassxc/build-image.yml?logo=github&branch=master&style=for-the-badge)](https://github.com/jlesage/docker-keepassxc/actions/workflows/build-image.yml)
[![Source](https://img.shields.io/badge/Source-GitHub-blue?logo=github&style=for-the-badge)](https://github.com/jlesage/docker-keepassxc)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg?style=for-the-badge)](https://paypal.me/JocelynLeSage)

This is a Docker container for [KeePassXC](https://keepassxc.org).

The graphical user interface (GUI) of the application can be accessed through a
modern web browser, requiring no installation or configuration on the client

> This Docker container is entirely unofficial and not made by the creators of KeePassXC.

---

[![KeePassXC logo](https://images.weserv.nl/?url=raw.githubusercontent.com/jlesage/docker-templates/master/jlesage/images/keepassxc-icon.png&w=110)](https://keepassxc.org)[![KeePassXC](https://images.placeholders.dev/?width=288&height=110&fontFamily=monospace&fontWeight=400&fontSize=52&text=KeePassXC&bgColor=rgba(0,0,0,0.0)&textColor=rgba(121,121,121,1))](https://keepassxc.org)

KeePassXC is a modern, secure, and open-source password manager that stores and
manages your most sensitive information.

---

## Quick Start

**NOTE**:
    The Docker command provided in this quick start is an example, and parameters
    should be adjusted to suit your needs.

Launch the KeePassXC docker container with the following command:
```shell
docker run -d \
    --name=keepassxc \
    -p 5800:5800 \
    -v /docker/appdata/keepassxc:/config:rw \
    jlesage/keepassxc
```

Where:

  - `/docker/appdata/keepassxc`: Stores the application's configuration, state, logs, and any files requiring persistency.

Access the KeePassXC GUI by browsing to `http://your-host-ip:5800`.

## Documentation

Full documentation is available at https://github.com/jlesage/docker-keepassxc.

## Support or Contact

Having troubles with the container or have questions? Please
[create a new issue](https://github.com/jlesage/docker-keepassxc/issues).

For other Dockerized applications, visit https://jlesage.github.io/docker-apps.
