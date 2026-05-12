# kong-builder

Helper Docker image that mirrors the toolchain used by the APIP release CI workflow, so you can build Kong RPMs locally on macOS (or any non-RHEL host).

The image is based on `rockylinux:9` and includes gcc, Java 11, Python 3, Perl + `IPC::Cmd`, `libyaml-devel`, `pcre2-devel`, and `bazelisk`.

**This image is local-only.** The CI workflow in `kong/.github/workflows/apip-release.yml` installs its toolchain inline inside a fresh `rockylinux:9` container — it does not pull this image. Changes to this Dockerfile only affect local builds.

## Build

```bash
docker build -t veecode/kong-builder:local .
```

## Use

See [apip-parent/RELEASE.md → Local RPM build](../RELEASE.md#local-rpm-build-via-kong-builder) for the full local-build flow (quick analyze, full RPM build, multi-arch).
