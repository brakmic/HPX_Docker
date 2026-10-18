#!/usr/bin/env bash
# Builds and runs the bundled example inside the builder image.
# Usage: bash scripts/smoke-test.sh [path-to-app] [expected-output] [cxx-standard]
set -euo pipefail

app_dir="${1:-/workspace/my_hpx_app}"
expected="${2:-After HPX sort: 10 20 30 40 50}"
cxx_standard="${3:-}"

work_dir="$(mktemp -d)"
trap 'rm -rf "${work_dir}"' EXIT

cp -a "${app_dir}" "${work_dir}/app"

# The tracked example stays on C++17 for the stable image. HPX 2.0 needs
# C++20, so the copy used for that variant is adjusted here.
if [[ -n "${cxx_standard}" ]]; then
    sed -i "s/set(CMAKE_CXX_STANDARD [0-9]*)/set(CMAKE_CXX_STANDARD ${cxx_standard})/" \
        "${work_dir}/app/CMakeLists.txt"
fi

cmake -S "${work_dir}/app" -B "${work_dir}/app/build" \
    -DCMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH:-/usr/local/hpx}"
cmake --build "${work_dir}/app/build" --parallel 2

output="$("${work_dir}/app/build/my_hpx_app")"
printf '%s\n' "${output}"

if ! grep -qF "${expected}" <<< "${output}"; then
    echo "Smoke test failed: expected output not found." >&2
    exit 1
fi

echo "Smoke test passed."
