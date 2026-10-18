# Third-party components

The builder image installs the components below from Ubuntu 24.04 packages
unless noted otherwise. This file records the licenses for attribution. It is
not legal advice. License identifiers follow the SPDX naming where one exists.

## Built from source

| Component | Version | License | Upstream |
| --- | --- | --- | --- |
| HPX | Selectable with `HPX_TAG`, default `v1.11.0` | BSL-1.0 | <https://github.com/TheHPXProject/hpx> |

HPX 2.0 variants may download a pinned stdexec revision during CMake configure
through `HPX_WITH_FETCH_STDEXEC`. The stdexec project is distributed under the
Apache License 2.0 with LLVM Exceptions.

## System libraries and tools

| Component | Ubuntu package | License |
| --- | --- | --- |
| Boost | `libboost-dev`, `libboost-chrono-dev`, `libboost-context-dev`, `libboost-iostreams-dev`, `libboost-regex-dev`, `libboost-thread-dev` | BSL-1.0 |
| Asio | `libasio-dev` | BSL-1.0 |
| jemalloc | `libjemalloc-dev` | BSD-2-Clause |
| hwloc | `libhwloc-dev` | BSD-3-Clause |
| OpenSSL | `libssl-dev` | Apache-2.0 |
| zlib | pulled in as a dependency | Zlib |
| bzip2 | `libbz2-dev` | bzip2-1.0.6 |
| XZ Utils (lzma) | `liblzma-dev` | Public domain |
| Zstandard | `libzstd-dev` | BSD-3-Clause or GPL-2.0 |
| libaio | `libaio-dev` | LGPL-2.1-or-later |
| GCC and libstdc++ | `build-essential` | GPL-3.0-or-later with GCC Runtime Library Exception |
| CMake | `cmake` | BSD-3-Clause |
| Ninja | `ninja-build` | Apache-2.0 |
| ccache | `ccache` | GPL-3.0-or-later |
| Python | `python3` | PSF-2.0 |
| Ubuntu base image | `ubuntu:24.04` | Multiple licenses |

## Variants

An MPI variant would add `libopenmpi-dev` and `openmpi-bin`, which are
distributed under the BSD-3-Clause license. The default image does not install
MPI. The slim runtime and devcontainer variants, when they are added, will
record their own component sets here.

## Application code

The bundled `my_hpx_app` example in this repository is covered by the
repository's [MIT license](LICENSE). It is used as a smoke test and is not
installed into the image.
