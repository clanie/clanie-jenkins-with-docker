#!/usr/bin/env bash
set -euo pipefail

SOCK=/var/run/docker.sock

if [ -S "$SOCK" ]; then
  SOCK_GID="$(stat -c '%g' "$SOCK")"

  # Create a group with the same GID as the docker socket (if missing)
  if ! getent group dockersock >/dev/null; then
    groupadd -g "$SOCK_GID" dockersock 2>/dev/null || true
  fi

  # Add jenkins user to that group
  usermod -aG "$SOCK_GID" jenkins 2>/dev/null || true
  usermod -aG dockersock jenkins 2>/dev/null || true
fi

# Drop privileges and start Jenkins
exec gosu jenkins /usr/bin/tini -- /usr/local/bin/jenkins.sh
