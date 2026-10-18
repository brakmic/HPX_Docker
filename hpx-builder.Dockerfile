# syntax=docker/dockerfile:1.7

FROM ubuntu:24.04 AS hpx-builder

# Keep apt non-interactive during the build.
ENV DEBIAN_FRONTEND=noninteractive

# Toolchain and development packages. The Boost set is deliberately minimal.
# HPX needs the Boost headers, and on architectures that use generic context
# coroutines, for example arm64, it also links Boost.Context, Boost.Thread,
# and Boost.Chrono. Boost.Iostreams and Boost.Regex cover the iostreams
# component and the installed tools.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        ccache \
        cmake \
        git \
        ninja-build \
        python3 \
        wget \
        libaio-dev \
        libasio-dev \
        libboost-chrono-dev \
        libboost-context-dev \
        libboost-dev \
        libboost-iostreams-dev \
        libboost-regex-dev \
        libboost-thread-dev \
        libbz2-dev \
        libhwloc-dev \
        libjemalloc-dev \
        liblzma-dev \
        libssl-dev \
        libzstd-dev \
    && rm -rf /var/lib/apt/lists/*

# Optional MPI parcelport support. The packages are installed in a separate
# layer so the main toolchain layer stays cached when the variant changes.
ARG HPX_WITH_MPI=OFF
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    if [ "${HPX_WITH_MPI}" = "ON" ]; then \
        apt-get update \
        && apt-get install -y --no-install-recommends \
            libopenmpi-dev \
            openmpi-bin \
        && rm -rf /var/lib/apt/lists/*; \
    fi

# Build arguments. Override them on the docker build command line to select
# another HPX release, C++ standard, or compression support.
ARG HPX_TAG=v1.11.0
ARG HPX_REPO=https://github.com/TheHPXProject/hpx.git
ARG HPX_BUILD_TYPE=Release
ARG HPX_CXX_STANDARD=17
ARG HPX_COMPRESSION_BZIP2=ON
ARG HPX_BUILD_JOBS=2
ARG HPX_INSTALL_PREFIX=/usr/local/hpx
ARG HPX_MALLOC=jemalloc
ARG HPX_GENERIC_CONTEXT_COROUTINES=auto
ARG HPX_IMAGE_REVISION=unknown

LABEL org.opencontainers.image.title="HPX builder" \
      org.opencontainers.image.description="HPX C++ runtime builder image" \
      org.opencontainers.image.version="${HPX_TAG}" \
      org.opencontainers.image.revision="${HPX_IMAGE_REVISION}" \
      org.opencontainers.image.source="https://github.com/brakmic/HPX_Docker" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.base.name="ubuntu:24.04"

ENV HPX_TAG=${HPX_TAG} \
    HPX_BUILD_TYPE=${HPX_BUILD_TYPE} \
    HPX_CXX_STANDARD=${HPX_CXX_STANDARD} \
    HPX_INSTALL_PREFIX=${HPX_INSTALL_PREFIX} \
    HPX_SOURCE_DIR=/hpx \
    HPX_BUILD_DIR=/hpx/build \
    CMAKE_PREFIX_PATH=${HPX_INSTALL_PREFIX} \
    PATH=${HPX_INSTALL_PREFIX}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    LD_LIBRARY_PATH=${HPX_INSTALL_PREFIX}/lib

# Clone the release tag, configure with Ninja, compile, and install. HPX does
# not enable generic context coroutines automatically on non-x86
# architectures, so the setting follows the target architecture unless it is
# given explicitly. The source and build trees are removed in the same layer
# so they do not stay in the image. The ccache mount keeps object files across
# local rebuilds.
RUN --mount=type=cache,target=/root/.ccache \
    generic="${HPX_GENERIC_CONTEXT_COROUTINES}"; \
    if [ "${generic}" = "auto" ]; then \
        case "$(dpkg --print-architecture)" in \
            amd64) generic=OFF ;; \
            *) generic=ON ;; \
        esac; \
    fi; \
    git clone --depth 1 --branch "${HPX_TAG}" "${HPX_REPO}" "${HPX_SOURCE_DIR}" \
    && cmake -S "${HPX_SOURCE_DIR}" -B "${HPX_BUILD_DIR}" -G Ninja \
        -DCMAKE_INSTALL_PREFIX="${HPX_INSTALL_PREFIX}" \
        -DCMAKE_BUILD_TYPE="${HPX_BUILD_TYPE}" \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -DBUILD_SHARED_LIBS=ON \
        -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
        -DHPX_WITH_CXX_STANDARD="${HPX_CXX_STANDARD}" \
        -DHPX_WITH_MALLOC="${HPX_MALLOC}" \
        -DHPX_WITH_GENERIC_CONTEXT_COROUTINES="${generic}" \
        -DHPX_WITH_PARCELPORT_MPI="${HPX_WITH_MPI}" \
        -DHPX_WITH_COMPRESSION_BZIP2="${HPX_COMPRESSION_BZIP2}" \
        -DHPX_WITH_EXAMPLES=OFF \
        -DHPX_WITH_TESTS=OFF \
    && cmake --build "${HPX_BUILD_DIR}" --parallel "${HPX_BUILD_JOBS}" \
    && cmake --install "${HPX_BUILD_DIR}" \
    && rm -rf "${HPX_SOURCE_DIR}"

WORKDIR /workspace

CMD ["/bin/bash"]
