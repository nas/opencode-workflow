#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"
MODE="${1:-status}"

print_usage() {
  printf "Usage: %s <install|status|unlink>\n" "$0"
}

install_config() {
  mkdir -p "$(dirname "$CONFIG_DIR")"

  if [ -L "$CONFIG_DIR" ]; then
    EXISTING_TARGET="$(readlink "$CONFIG_DIR")"
    if [ "$EXISTING_TARGET" = "$ROOT_DIR" ]; then
      printf "Already linked: %s -> %s\n" "$CONFIG_DIR" "$ROOT_DIR"
      return
    fi
    rm "$CONFIG_DIR"
  elif [ -d "$CONFIG_DIR" ]; then
    BACKUP_DIR="${CONFIG_DIR}.backup.$(date +%Y%m%d%H%M%S)"
    mv "$CONFIG_DIR" "$BACKUP_DIR"
    printf "Backed up existing config to: %s\n" "$BACKUP_DIR"
  elif [ -e "$CONFIG_DIR" ]; then
    BACKUP_FILE="${CONFIG_DIR}.backup.$(date +%Y%m%d%H%M%S)"
    mv "$CONFIG_DIR" "$BACKUP_FILE"
    printf "Backed up existing file to: %s\n" "$BACKUP_FILE"
  fi

  ln -s "$ROOT_DIR" "$CONFIG_DIR"
  printf "Linked config: %s -> %s\n" "$CONFIG_DIR" "$ROOT_DIR"
}

unlink_config() {
  if [ ! -L "$CONFIG_DIR" ]; then
    printf "Config path is not a symlink: %s\n" "$CONFIG_DIR"
    exit 1
  fi

  TARGET="$(readlink "$CONFIG_DIR")"
  rm "$CONFIG_DIR"
  mkdir -p "$CONFIG_DIR"
  printf "Removed symlink. Created empty config dir at %s (was -> %s)\n" "$CONFIG_DIR" "$TARGET"
}

status_config() {
  printf "Repo dir: %s\n" "$ROOT_DIR"
  printf "Config dir: %s\n" "$CONFIG_DIR"

  if [ -L "$CONFIG_DIR" ]; then
    printf "Status: symlinked\n"
    printf "Symlink target: %s\n" "$(readlink "$CONFIG_DIR")"
  elif [ -d "$CONFIG_DIR" ]; then
    printf "Status: directory (not symlinked)\n"
  else
    printf "Status: missing\n"
  fi

  if [ -d "$ROOT_DIR/commands" ]; then
    printf "Tracked command files:\n"
    ls "$ROOT_DIR/commands"
  fi
}

case "$MODE" in
  install)
    install_config
    ;;
  status)
    status_config
    ;;
  unlink)
    unlink_config
    ;;
  *)
    print_usage
    exit 1
    ;;
esac
