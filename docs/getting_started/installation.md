# Installation

For the latest stable release

```bash
pip install swesmith
```

For the latest development version

```bash
git clone https://github.com/SWE-bench/SWE-smith
cd SWE-smith
./setup.sh
```

If you plan to contribute to SWE-smith, please also perform:

```bash
pre-commit install
```

## Docker Development Environment

You can also use the containerized development setup that provides a consistent environment with all dependencies pre-configured.

### Prerequisites

- Docker and Docker Compose
- Linux host (tested on Debian 13)

### Setup

1. Clone the repository:

```bash
git clone https://github.com/SWE-bench/SWE-smith
cd SWE-smith
```

2. Create your `.env` file from the example:

```bash
cp .env.example .env
```

3. Fill in the required values in `.env`:

```bash
# Your user/group IDs (run `id` to check)
UID=1000
GID=1000

# API keys (fill in the ones you need)
GITHUB_TOKEN=
OPENROUTER_API_KEY=
OPENAI_API_KEY=
ANTHROPIC_API_KEY=
HF_TOKEN=

# Docker group ID — required for Docker-in-Docker
# Check via: stat -c '%g' /var/run/docker.sock
DOCKER_GID=999

# Path to your SSH keys (used for git operations)
SSH_KEY_DIR=./keys
```

4. Build and start the container:

```bash
docker compose build
docker compose run --rm swesmith
```

You'll be dropped into a bash shell inside the container with the virtualenv activated.

### How It Works

The Docker setup uses a bind mount to map the project directory into the container at `/home/sweuser/swesmith`. This means:

- Code changes on your host are immediately reflected inside the container
- Logs, generated files, and the `.venv` directory persist across container restarts
- The Docker socket is mounted so the container can build/run Docker images (Docker-in-Docker)

#### Caching

Several directories are cached inside `.container-cache/` (within the project mount) to avoid re-downloading on every container restart:

| Environment Variable    | Purpose                            |
| ----------------------- | ---------------------------------- |
| `PIP_CACHE_DIR`         | pip download cache                 |
| `UV_CACHE_DIR`          | uv package cache                   |
| `UV_PYTHON_INSTALL_DIR` | uv-managed Python interpreters     |
| `CONDA_PKGS_DIRS`       | conda package cache                |
| `HF_HOME`               | Hugging Face datasets/models cache |
| `BASH_HISTORY`          | Persistent bash history            |

These are set in `.env` and pointed to paths inside the bind mount, so they survive container recreation. If you do not need specific paths, you can leave them as they are.

#### Entrypoint

On first run, the entrypoint script:

1. Creates a Python 3.12 virtualenv via `uv venv`
2. Installs all dependencies via `uv sync --all-extras --all-packages`
3. Activates the virtualenv

On subsequent runs, the existing `.venv` is reused (skipping install).

### Troubleshooting

#### Docker permission denied

Make sure `DOCKER_GID` in `.env` matches your host's Docker socket group:

```bash
stat -c '%g' /var/run/docker.sock
```
