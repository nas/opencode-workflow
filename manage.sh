#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$ROOT_DIR/commands"
CONFIG_DIR="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"
TARGET_DIR="$CONFIG_DIR/commands"
MODE="${1:-status}"

print_usage() {
  printf "Usage: %s <install|pull|status>\n" "$0"
}

install_commands() {
  mkdir -p "$CONFIG_DIR"

  if [ -L "$TARGET_DIR" ]; then
    rm "$TARGET_DIR"
  elif [ -d "$TARGET_DIR" ]; then
    BACKUP_DIR="${TARGET_DIR}.backup.$(date +%Y%m%d%H%M%S)"
    mv "$TARGET_DIR" "$BACKUP_DIR"
    printf "Backed up existing commands to: %s\n" "$BACKUP_DIR"
  fi

  ln -s "$SOURCE_DIR" "$TARGET_DIR"
  printf "Linked commands: %s -> %s\n" "$TARGET_DIR" "$SOURCE_DIR"
}

pull_commands() {
  if [ ! -d "$TARGET_DIR" ]; then
    printf "No commands directory found at %s\n" "$TARGET_DIR"
    exit 1
  fi

  mkdir -p "$SOURCE_DIR"
  cp "$TARGET_DIR"/*.md "$SOURCE_DIR"/
  printf "Pulled command files from %s into %s\n" "$TARGET_DIR" "$SOURCE_DIR"
}

status_commands() {
  printf "Config dir: %s\n" "$CONFIG_DIR"
  printf "Target dir: %s\n" "$TARGET_DIR"
  printf "Source dir: %s\n" "$SOURCE_DIR"

  if [ -L "$TARGET_DIR" ]; then
    printf "Status: symlinked\n"
    printf "Symlink target: %s\n" "$(readlink "$TARGET_DIR")"
  elif [ -d "$TARGET_DIR" ]; then
    printf "Status: directory (not symlinked)\n"
  else
    printf "Status: missing\n"
  fi

  if [ -d "$SOURCE_DIR" ]; then
    printf "Tracked command files:\n"
    ls "$SOURCE_DIR"
  fi
}

case "$MODE" in
  install)
    install_commands
    ;;
  pull)
    pull_commands
    ;;
  status)
    status_commands
    ;;
  *)
    print_usage
    exit 1
    ;;
esac
