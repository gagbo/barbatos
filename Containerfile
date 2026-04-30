# Barbatos - Gerry Agbobada's customized Universal Blue image
#
# Multi-stage build following the finpilot / upstream Bluefin pattern.
# Base: silverblue-main (Fedora GNOME)
# Layers: projectbluefin/common (shared desktop config) + ublue-os/brew (homebrew)
#
# Renovate auto-updates the @sha256: digests via the dockerfile manager.

# --- Stage: assemble build context ---
FROM scratch AS ctx

COPY build        /build
COPY custom       /custom
COPY system_files /system_files
# OCI containers — Renovate pins the digest after :latest
COPY --from=ghcr.io/projectbluefin/common:latest /system_files/shared  /oci/common/shared
COPY --from=ghcr.io/projectbluefin/common:latest /system_files/bluefin /oci/common/shared
COPY --from=ghcr.io/ublue-os/brew:latest         /system_files         /oci/brew

# --- Stage: final image ---
FROM ghcr.io/ublue-os/silverblue-main:43

ARG IMAGE_NAME="barbatos"
ARG IMAGE_VENDOR="gagbo"
ARG SHA_HEAD_SHORT=""
ARG SET_X=""

# Brand the OS
RUN sed -i '/^PRETTY_NAME/s/.*/PRETTY_NAME="Barbatos"/' /usr/lib/os-release

# Build
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build/build.sh

# /opt writeable (needed for k0s, google-chrome, docker-desktop, etc.)
RUN rm -rf /opt && ln -s /var/opt /opt

RUN bootc container lint
