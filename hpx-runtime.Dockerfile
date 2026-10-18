# syntax=docker/dockerfile:1.7

# Source the HPX installation from the published builder image of the same
# version. No HPX rebuild is needed for the runtime image.
ARG HPX_BUILDER_IMAGE=brakmic/hpx-builder
ARG HPX_VERSION=1.11.0

FROM ${HPX_BUILDER_IMAGE}:${HPX_VERSION} AS hpx-artifacts

# Keep only what is needed to run applications: shared libraries, runtime
# plugins, and the launcher script.
RUN mkdir -p /runtime/usr/local/hpx/lib /runtime/usr/local/hpx/bin \
    && cp -a /usr/local/hpx/lib/*.so* /runtime/usr/local/hpx/lib/ \
    && cp -a /usr/local/hpx/lib/hpx /runtime/usr/local/hpx/lib/ \
    && if [ -f /usr/local/hpx/bin/hpxrun.py ]; then \
        cp -a /usr/local/hpx/bin/hpxrun.py /runtime/usr/local/hpx/bin/; \
    fi

FROM ubuntu:24.04 AS hpx-runtime

ENV DEBIAN_FRONTEND=noninteractive

# Runtime libraries for HPX and its compression plugin. Headers, compilers,
# CMake, and the static archives stay in the builder image.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libboost-context1.83.0 \
        libboost-iostreams1.83.0 \
        libbz2-1.0 \
        libcap2 \
        libhwloc15 \
        libjemalloc2 \
        liblzma5 \
        libstdc++6 \
        libudev1 \
        libzstd1 \
        python3 \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*

COPY --from=hpx-artifacts /runtime/ /

RUN echo "/usr/local/hpx/lib" > /etc/ld.so.conf.d/hpx.conf && ldconfig

ENV PATH=/usr/local/hpx/bin:${PATH} \
    LD_LIBRARY_PATH=/usr/local/hpx/lib

WORKDIR /workspace

CMD ["/bin/bash"]
