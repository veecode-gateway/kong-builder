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
    perl-core \
    zlib-devel \
    pcre2-devel \
    && dnf install -y libyaml-devel --enablerepo=devel \
    && dnf clean all
