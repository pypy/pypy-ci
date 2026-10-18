# pypy-ci

GitHub Actions workflows and Docker images for the [PyPy](https://pypy.org) CI infrastructure.

## Docker images

Linux builds run inside Docker containers derived from `manylinux_2_28` (AlmaLinux 8,
glibc 2.28). The images are published to GHCR and rebuilt automatically whenever files
under `docker/` change.

| Image | Arch | Runner |
|---|---|---|
| `ghcr.io/pypy/pypy/buildworker_x86_64` | x86-64 | `ubuntu-latest` |
| `ghcr.io/pypy/pypy/buildworker_i686` | x86-32 | `ubuntu-latest` |
| `ghcr.io/pypy/pypy/buildworker_aarch64` | aarch64 | `ubuntu-24.04-arm` |

### What's in the image

- **PyPy 2.7** — used both for translation (building PyPy from source) and for running
  the RPython test suite (`pypy -mpytest ...`).
- **pytest, hypothesis, mercurial, pexpect, vmprof, automat** — test dependencies,
  installed into PyPy with pinned hashes (`docker/requirements.txt`).
- **sqlite 3.53.x, libexpat 2.8.x, libffi 3.5.x, openssl 3.0.x** — built from source
  at specific versions because they are baked into the PyPy binary at translation time.
- **zlib-ng 2.3.x** — built from source in zlib-compat mode and installed to `/usr/local`,
  replacing the system zlib (same API/ABI, SIMD-accelerated) for PyPy's `zlib` module.
- **gc, ncurses, libunwind, bzip2** — installed via yum from the AlmaLinux 8 repos.

### Build locally

```sh
docker build --pull -t buildworker_x86_64 \
  --build-arg BUILDWORKER_UID=$(id -u) \
  -f docker/Dockerfile docker
```

Run interactively against a PyPy checkout:

```sh
docker run -it --rm -v /path/to/pypy:/build_dir buildworker_x86_64 /bin/bash
```

### Updating dependencies

**PyPy version** — update `PYPY_VERSION` and the three per-arch `PYPY_SHA256` values
in `docker/install_pypy.sh`. Checksums are at <https://pypy.org/checksums>.

**libexpat / libffi** — update the version and `EXPAT_SHA256` / `LIBFFI_SHA256`
variables in `docker/install_libexpat.sh` / `docker/install_libffi.sh`.

**sqlite** — update `SQLITE_VERSION` and `SQLITE_SHA3` in `docker/install_sqlite.sh`.

**zlib-ng** — update `ZLIB_NG_VERSION` and `ZLIB_NG_SHA256` in `docker/install_zlib_ng.sh`
(sha256 of the GitHub source tarball `archive/refs/tags/<version>.tar.gz`).

**Python test dependencies** — regenerate `docker/requirements.txt`:

```sh
pypy -mpip download --no-deps --dest /tmp/wheels \
    "pytest==X.Y" "hypothesis==X.Y" ... 
sha256sum /tmp/wheels/* | awk '{print $2"==... \\\n    --hash=sha256:"$1}' \
    > docker/requirements.txt  # then edit into proper pip format
```

**GitHub Actions pins** — the six actions in `.github/workflows/docker-build.yml` are
pinned to commit SHAs. To update them, look up the current SHA for each tag:

```sh
gh api repos/actions/checkout/git/ref/tags/v4 --jq '.object.sha'
```
