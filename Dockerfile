FROM rockylinux:9

# Toolchain to build Kong via Bazel on RHEL 9 (matches the CI workflow in
# kong/.github/workflows/apip-release.yml). Used for local RPM builds on
# macOS or any non-RHEL host. Not used by CI.

ARG BAZELISK_VERSION=1.20.0
ARG TARGETARCH

RUN dnf install -y \
        gcc \
        gcc-c++ \
        make \
        patch \
        git \
        python3 \
        tar \
        gzip \
        zip \
        unzip \
        which \
        file \
        java-11-openjdk-devel \
        perl-core \
        perl-CPAN \
        perl-devel \
        cpanminus \
        zlib-devel \
        openssl-devel \
        pcre2-devel \
    && dnf install -y libyaml-devel --enablerepo=devel \
    && dnf clean all \
    && cpanm --notest IPC::Cmd

# Install bazelisk (which fetches the right Bazel version on demand)
RUN set -eux; \
    case "${TARGETARCH:-$(uname -m)}" in \
        amd64|x86_64) BZ_ARCH=amd64 ;; \
        arm64|aarch64) BZ_ARCH=arm64 ;; \
        *) echo "unsupported arch: ${TARGETARCH}"; exit 1 ;; \
    esac; \
    curl -fsSL -o /usr/local/bin/bazel \
        "https://github.com/bazelbuild/bazelisk/releases/download/v${BAZELISK_VERSION}/bazelisk-linux-${BZ_ARCH}"; \
    chmod +x /usr/local/bin/bazel; \
    bazel version || true

WORKDIR /kong
