# HPX Builder Docker Image

![Docker Pulls](https://img.shields.io/docker/pulls/brakmic/hpx-builder)
![Docker Image Size](https://img.shields.io/docker/image-size/brakmic/hpx-builder/latest)
![GitHub License](https://img.shields.io/github/license/brakmic/hpx_docker)

## Table of Contents

- [HPX Builder Docker Image](#hpx-builder-docker-image)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Features](#features)
  - [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Pulling the Docker Image](#pulling-the-docker-image)
    - [Running the Builder Container](#running-the-builder-container)
  - [Using the HPX Builder](#using-the-hpx-builder)
    - [Locating HPX Libraries and Headers](#locating-hpx-libraries-and-headers)
    - [Configuring Your C++ Application](#configuring-your-c-application)
    - [Compiling and Linking Your Application](#compiling-and-linking-your-application)
  - [Example: Simple HPX Application](#example-simple-hpx-application)
    - [Project Structure](#project-structure)
    - [CMake Configuration](#cmake-configuration)
    - [Example HPX Application](#example-hpx-application)
    - [Building the Example](#building-the-example)
    - [Running the Example](#running-the-example)
  - [Advanced Usage](#advanced-usage)
    - [Custom Build Arguments](#custom-build-arguments)
    - [Mounting Volumes for Development](#mounting-volumes-for-development)
    - [Integration with CI/CD](#integration-with-cicd)
  - [License](#license)

## Introduction

The **HPX Builder Docker Image** provides a pre-configured environment for C++ developers to efficiently build and develop applications using [HPX](https://hpx.stellar-group.org/), a high-performance parallel and distributed runtime system. By leveraging Docker, this image ensures a consistent development setup across different machines and environments, eliminating the "it works on my machine" problem.

## Features

- **Precompiled HPX Libraries:** Quickly integrate HPX into your projects without manual compilation.
- **Boost.Asio Integration:** Utilizes Boost.Asio for asynchronous operations, ensuring compatibility and performance.
- **Memory Allocator Support:** Configured to use `jemalloc` for optimized memory management.
- **Customizable Builds:** Supports build arguments to tailor the HPX build to your specific requirements.
- **Efficient Docker Layers:** Optimized Dockerfile structure for faster builds and smaller image sizes.
- **Comprehensive Logging:** Provides detailed build logs to assist in monitoring and debugging.

## Getting Started

### Prerequisites

- **Docker:** Ensure Docker is installed on your system. You can download it from [here](https://www.docker.com/get-started).
- **C++ Development Environment:** Familiarity with C++ and CMake for building HPX applications.

### Pulling the Docker Image

Retrieve the latest HPX Builder image from Docker Hub:

```bash
docker pull brakmic/hpx-builder:latest
```

### Running the Builder Container

Launch an interactive container using the HPX Builder image:

```bash
docker run --rm -it brakmic/hpx-builder:latest /bin/bash
```

This command starts a container and opens a bash shell, allowing you to interact with the HPX environment.

## Using the HPX Builder

### Locating HPX Libraries and Headers

Within the running container, HPX is installed at `/usr/local/hpx`. The libraries and headers can be found in the following directories:

- **Headers:** `/usr/local/hpx/include/`
- **Libraries:** `/usr/local/hpx/lib/`

### Configuring Your C++ Application

To utilize HPX in your C++ project, configure your `CMakeLists.txt` to find and link against the HPX libraries provided by the builder image.

**Example `CMakeLists.txt`:**

```cmake
cmake_minimum_required(VERSION 3.15)
project(MyHPXApp)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Specify the path to HPX installation
set(HPX_ROOT "/usr/local/hpx")

# Find HPX
find_package(HPX REQUIRED)

add_executable(my_hpx_app src/main.cpp)

# Link HPX libraries
target_link_libraries(my_hpx_app PRIVATE HPX::hpx HPX::wrap_main)
```

### Compiling and Linking Your Application

Within the builder container, navigate to your project directory and build your application using CMake and Make.

**Steps:**

1. **Navigate to Project Directory:**

   ```bash
   cd /path/to/your/project
   ```

2. **Create a Build Directory:**

   ```bash
   mkdir build && cd build
   ```

3. **Configure the Project with CMake:**

   ```bash
   cmake .. -DCMAKE_PREFIX_PATH=/usr/local/hpx
   ```

4. **Build the Project:**

   ```bash
   make -j$(nproc)
   ```

This process compiles your application and links it against the precompiled HPX libraries.

## Example: Simple HPX Application

To demonstrate the usage of the HPX Builder image, let's walk through building a simple HPX-based C++ application.

### Project Structure

```
my_hpx_app/
├── CMakeLists.txt
└── src/
    └── main.cpp
```

### CMake Configuration

**`CMakeLists.txt`:**

```cmake
cmake_minimum_required(VERSION 3.15)
project(MyHPXApp)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Specify the path to HPX installation
set(HPX_ROOT "/usr/local/hpx")

# Find HPX
find_package(HPX REQUIRED)

add_executable(my_hpx_app src/main.cpp)

# Link HPX libraries
target_link_libraries(my_hpx_app PRIVATE HPX::hpx HPX::wrap_main)
```

### Example HPX Application

**`src/main.cpp`:**

```cpp
#include <hpx/hpx_main.hpp>
#include <hpx/include/parallel_sort.hpp>
#include <vector>
#include <algorithm>
#include <iostream>

int main()
{
    // Initialize a vector with unsorted integers
    std::vector<int> data = {50, 20, 40, 10, 30};

    std::cout << "Before HPX sort: ";
    for(auto num : data)
        std::cout << num << " ";
    std::cout << std::endl;

    // Perform parallel sort using HPX
    hpx::sort(hpx::execution::par, data.begin(), data.end());

    std::cout << "After HPX sort: ";
    for(auto num : data)
        std::cout << num << " ";
    std::cout << std::endl;

    return 0;
}
```

### Building the Example

1. **Start the Builder Container:**

   ```bash
   docker run --rm -it -v $(pwd)/my_hpx_app:/app brakmic/hpx-builder:latest /bin/bash
   ```

   *This command mounts your local `my_hpx_app` directory to `/app` inside the container.*

2. **Navigate to the Application Directory:**

   ```bash
   cd /app
   ```

3. **Create and Navigate to Build Directory:**

   ```bash
   mkdir build && cd build
   ```

4. **Configure the Project with CMake:**

   ```bash
   cmake .. -DCMAKE_PREFIX_PATH=/usr/local
   ```

5. **Build the Application:**

   ```bash
   make -j$(nproc)
   ```

### Running the Example

After a successful build, run the application:

```bash
./my_hpx_app
```

**Expected Output:**

```
Before HPX sort: 50 20 40 10 30 
After HPX sort: 10 20 30 40 50 
```

This output confirms that HPX successfully sorted the vector in parallel.

## Advanced Usage

### Custom Build Arguments

The HPX Builder image supports build arguments to customize the HPX build process.

- **`HPX_TAG`**: Specifies the HPX version to build.
  - **Default**: `v1.10.0`
  - **Usage**:
    ```bash
    docker build -t brakmic/hpx-builder:v1.11.0 \
      -f docker/hpx-builder.Dockerfile \
      --build-arg HPX_TAG=v1.10.0 \
      .
    ```

- **`HPX_WITH_ASIO`**: Configures HPX to use either Boost.Asio or standalone Asio.
  - **Options**: `Boost`, `ASIO`
  - **Default**: `ASIO`
  - **Usage**:
    ```bash
    docker build -t brakmic/hpx:v1.10.0-asio \
      -f docker/hpx-builder.Dockerfile \
      --build-arg HPX_WITH_ASIO=ASIO \
      .
    ```

### Mounting Volumes for Development

For an efficient development workflow, mount your local project directory into the container. This allows you to edit files locally and build within the container.

**Example Command:**

```bash
docker run --rm -it \
  -v $(pwd)/my_hpx_app:/app \
  brakmic/hpx-builder:latest \
  /bin/bash
```

**Inside the Container:**

1. **Navigate to the Mounted Directory:**

   ```bash
   cd /app
   ```

2. **Build as Usual:**

   ```bash
   mkdir build && cd build
   cmake .. -DCMAKE_PREFIX_PATH=/usr/local
   make -j$(nproc)
   ```

### Integration with CI/CD

Integrate the HPX Builder image into your Continuous Integration/Continuous Deployment (CI/CD) pipelines to automate the build and testing of your HPX-based applications.

**Example GitHub Actions Workflow:**

```yaml
name: Build and Test HPX Application

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout Repository
      uses: actions/checkout@v3

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2

    - name: Build HPX Builder Image
      run: |
        docker build -t brakmic/hpx-builder:latest \
          -f docker/hpx-builder.Dockerfile \
          .

    - name: Build Application
      run: |
        docker run --rm -v ${{ github.workspace }}/my_hpx_app:/app \
          brakmic/hpx-builder:latest \
          bash -c "cd /app && mkdir build && cd build && cmake .. -DCMAKE_PREFIX_PATH=/usr/local && make -j$(nproc)"

    - name: Run Tests
      run: |
        docker run --rm -v ${{ github.workspace }}/my_hpx_app:/app \
          brakmic/hpx-builder:latest \
          bash -c "cd /app/build && ./my_hpx_app"
```

## License

This project is licensed under the [MIT License](./LICENSE).
