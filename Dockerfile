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
        golang \
        dnf-plugins-core \
    && dnf install -y libyaml-devel --enablerepo=devel \
    && dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo \
    && dnf install -y docker-ce-cli docker-compose-plugin \
    && dnf clean all \
    && cpanm --notest IPC::Cmd

# Install Rust toolchain via rustup (stable)
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH
RUN set -eux; \
    case "${TARGETARCH:-$(uname -m)}" in \
        amd64|x86_64) RUST_ARCH=x86_64-unknown-linux-gnu ;; \
        arm64|aarch64) RUST_ARCH=aarch64-unknown-linux-gnu ;; \
        *) echo "unsupported arch: ${TARGETARCH}"; exit 1 ;; \
    esac; \
    curl -fsSL "https://static.rust-lang.org/rustup/dist/${RUST_ARCH}/rustup-init" -o /tmp/rustup-init; \
    chmod +x /tmp/rustup-init; \
    /tmp/rustup-init -y --no-modify-path --default-toolchain none; \
    rm /tmp/rustup-init; \
    rustup toolchain install stable; \
    rustup default stable; \
    chmod -R a+w "$RUSTUP_HOME" "$CARGO_HOME"; \
    rustc --version; \
    cargo --version

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

# Install grpcurl + h2client for gRPC / HTTP2 test buckets. Versions track
# kong/Makefile GRPCURL_VERSION / H2CLIENT_VERSION.
ARG GRPCURL_VERSION=1.8.5
ARG H2CLIENT_VERSION=0.4.4
RUN set -eux; \
    case "${TARGETARCH:-$(uname -m)}" in \
        amd64|x86_64) TOOL_ARCH=x86_64 ;; \
        arm64|aarch64) TOOL_ARCH=arm64 ;; \
        *) echo "unsupported arch: ${TARGETARCH}"; exit 1 ;; \
    esac; \
    mkdir -p /tmp/tools && cd /tmp/tools; \
    curl -fsSL -o grpcurl.tgz \
        "https://github.com/fullstorydev/grpcurl/releases/download/v${GRPCURL_VERSION}/grpcurl_${GRPCURL_VERSION}_linux_${TOOL_ARCH}.tar.gz"; \
    tar xzf grpcurl.tgz grpcurl; mv grpcurl /usr/local/bin/grpcurl; \
    curl -fsSL -o h2client.tgz \
        "https://github.com/Kong/h2client/releases/download/v${H2CLIENT_VERSION}/h2client_${H2CLIENT_VERSION}_linux_${TOOL_ARCH}.tar.gz"; \
    tar xzf h2client.tgz h2client; mv h2client /usr/local/bin/h2client; \
    cd / && rm -rf /tmp/tools; \
    grpcurl --version 2>&1 | head -1; \
    h2client --version 2>&1 | head -1 || true
