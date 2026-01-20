FROM mcr.microsoft.com/devcontainers/base:ubuntu

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends postgresql

RUN --mount=type=bind,target=/tmp/install-zig.sh,source=install-zig.sh /usr/bin/env bash /tmp/install-zig.sh
