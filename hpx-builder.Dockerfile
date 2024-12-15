FROM ubuntu:22.04 AS hpx-builder

# Set non-interactive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary system dependencies for building HPX
RUN apt update && apt install -y \
    build-essential \
    cmake \
    git \
    libboost-all-dev \
    libjemalloc-dev \
    libasio-dev \
    libssl-dev \
    liblzma-dev \
    libbz2-dev \
    libzstd-dev \
    libaio-dev \
    libhwloc-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables for HPX
ARG HPX_TAG=v1.10.0
ARG HPX_ASIO=ASIO
ENV HPX_TAG=${HPX_TAG}
ENV HPX_ASIO=${HPX_ASIO}
ENV HPX_SOURCE_DIR=/hpx
ENV HPX_BUILD_DIR=/hpx/build

# Clone HPX repository
RUN git clone --recurse-submodules https://github.com/STEllAR-GROUP/hpx.git ${HPX_SOURCE_DIR} \
    && cd ${HPX_SOURCE_DIR} \
    && git checkout tags/${HPX_TAG} -b build-${HPX_TAG}

# Build HPX
RUN mkdir -p ${HPX_BUILD_DIR} \
    && cd ${HPX_BUILD_DIR} \
    && cmake .. \
        -DCMAKE_INSTALL_PREFIX=/usr/local/hpx \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -DBUILD_SHARED_LIBS=ON \
        -DHPX_WITH_ASIO=${HPX_ASIO} \
        -DHPX_WITH_MALLOC=jemalloc \
        -DHPX_WITH_COMPRESSION_BZIP2=ON \
        -DHPX_WITH_EXAMPLES=OFF \
        -DHPX_WITH_TESTS=OFF \
    && make -j$(nproc) \
    && make install

# Clean up source and build directories to reduce image size
RUN rm -rf ${HPX_SOURCE_DIR}
