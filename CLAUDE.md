# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Kong Builder is a helper Docker image (based on `rockylinux:9`) that provides the build toolchain needed to compile Kong on macOS via container.

## Build

```bash
docker build -t kong-builder .
```

## Architecture

Single-Dockerfile project. The image installs C/C++ compilers, build tools, Python 3, Java 11, and common utilities via `dnf`.
