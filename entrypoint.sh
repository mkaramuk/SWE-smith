#!/bin/bash
set -e

ln -s $BASH_HISTORY ~/.bash_history

if [ ! -d /home/sweuser/swesmith/.venv ]; then
  uv venv --python 3.12
  uv sync --all-extras --all-packages
fi

echo "source /home/sweuser/swesmith/.venv/bin/activate" >> ~/.bashrc
exec "$@"
