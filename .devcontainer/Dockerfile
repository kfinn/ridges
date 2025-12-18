FROM mcr.microsoft.com/devcontainers/base:ubuntu

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && apt-get -y install --no-install-recommends postgresql

RUN --mount=type=bind,target=/tmp/install-zig.sh,source=.devcontainer/install-zig.sh /usr/bin/env bash /tmp/install-zig.sh
