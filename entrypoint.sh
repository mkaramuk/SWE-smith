#!/bin/bash
set -e

ln -s $BASH_HISTORY ~/.bash_history

# SSH setup: start agent
eval "$(ssh-agent -s)" > /dev/null

# Load SSH key if a valid one was mounted, otherwise unset the variable
MOUNTED_KEY="/home/sweuser/.ssh/github_key"
if [ -f "$MOUNTED_KEY" ] && [ -s "$MOUNTED_KEY" ]; then
  ssh-add "$MOUNTED_KEY" 2>/dev/null
  export GITHUB_USER_SSH_KEY="$MOUNTED_KEY"
else
  unset GITHUB_USER_SSH_KEY
fi

if [ ! -d /home/sweuser/swesmith/.venv ]; then
  uv venv --python 3.12
  uv sync --all-extras --all-packages
fi

echo "source /home/sweuser/swesmith/.venv/bin/activate" >> ~/.bashrc
exec "$@"
