# base-image-snapcd-runner

Static base images for the SnapCd Runner. Each image bakes the OS-level
prerequisites the Runner needs at runtime onto `mcr.microsoft.com/dotnet/aspnet:10.0-noble`,
so the application Dockerfiles in `snapcd/SnapCd.Runner/` can be a thin
`FROM <base> + COPY app + ENTRYPOINT`.

| Variant      | Dockerfile         | Adds                                                         | Published as                                                         |
|--------------|--------------------|--------------------------------------------------------------|----------------------------------------------------------------------|
| Plain        | `Dockerfile`       | `git`, `openssh-client`, `wget`, `curl`                      | `ghcr.io/schrieksoft/base-image-snapcd-runner:<SemVer>`              |
| Azure        | `Dockerfile.azure` | the above + Azure CLI (`az`) via `aka.ms/InstallAzureCLIDeb` | `ghcr.io/schrieksoft/base-image-snapcd-runner:<SemVer>-azure`        |

Versions are computed by GitVersion (`gitversion.yaml`) and published by
`.github/workflows/release.yaml` on every push to `main` and on `workflow_dispatch`.

## Building locally

From this directory:

```bash
# Plain variant
docker build -f Dockerfile -t base-image-snapcd-runner:local .

# Azure variant
docker build -f Dockerfile.azure -t base-image-snapcd-runner:local-azure .
```

Verify the tools are present:

```bash
docker run --rm base-image-snapcd-runner:local \
    sh -c "git --version && ssh -V && wget --version | head -1 && curl --version | head -1"

docker run --rm base-image-snapcd-runner:local-azure \
    sh -c "git --version && az --version | head -1"
```

### Trying it as the Runner's base

To smoke-test the Runner with a locally-built base image, point the Runner's
Dockerfile at the local tag temporarily:

```bash
# In applications/snapcd/SnapCd.Runner/Dockerfile, swap the FROM line:
#   FROM ghcr.io/schrieksoft/base-image-snapcd-runner:<ver>
# →
#   FROM base-image-snapcd-runner:local
```

Then build the Runner image as you normally would. Revert before committing.

### Multi-arch

The published workflow is amd64-only, matching the rest of the SnapCd
container family. To build locally for arm64, use buildx:

```bash
docker buildx build --platform linux/arm64 -f Dockerfile -t base-image-snapcd-runner:local-arm64 .
```

## Release flow

1. Push to `main` → `release.yaml` runs → both variants published to GHCR
   under the SemVer that GitVersion computes from commit history.
2. The first published version creates a *private* GHCR package — flip it
   to *public* in `Settings → Packages → base-image-snapcd-runner` so
   downstream `FROM` lines can pull without auth.
3. To consume in `snapcd/SnapCd.Runner/Dockerfile{,.azure}`, bump the
   pinned tag in those Dockerfiles' `FROM` line. (No automated dispatch
   is wired up yet — bumps are manual.)

To force a specific version bump, follow the snapcd-family GitVersion
conventions in your commit message:

- `+semver: major` / `+semver: breaking`
- `+semver: minor` / `+semver: feature`
- `+semver: patch` / `+semver: fix`
- `+semver: skip` to leave the version untouched
