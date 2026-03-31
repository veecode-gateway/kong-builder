FROM rockylinux:9

RUN dnf install -y \
    gcc \
    gcc-c++ \
    make \
    patch \
    git \
    python3 \
    zip \
    unzip \
    which \
    java-11-openjdk-devel \
    && dnf clean all

RUN curl -fsSL https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-linux-arm64 -o /usr/local/bin/bazel && \
    chmod +x /usr/local/bin/bazel
