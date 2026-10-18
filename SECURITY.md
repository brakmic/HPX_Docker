# Security policy

## Supported versions

| Image tag | Supported |
| --- | --- |
| `latest`, `1.11`, `1.11.x` | Yes |
| `2.0`, `2.0.x-rc*` | Pre-release, security fixes when practical |

## Reporting a vulnerability

Report vulnerabilities in this repository through GitHub private vulnerability
reporting:

<https://github.com/brakmic/HPX_Docker/security/advisories/new>

Do not open a public issue for a suspected vulnerability and do not include
tokens, credentials, or personal paths in a report.

This policy covers the Dockerfile, the build arguments, the helper scripts, and
the GitHub Actions workflows in this repository. Vulnerabilities in HPX, Boost,
Asio, jemalloc, hwloc, or other upstream projects should be reported to those
projects.

## Scope notes

- The image installs distribution packages from Ubuntu 24.04. Vulnerabilities in
  those packages are fixed by rebuilding the image with updated packages.
- Release images are built only by the release workflow from signed `v*` tags.
- Secrets used by the release workflow are stored in the `release` environment
  and are never written to the image or the build logs.
