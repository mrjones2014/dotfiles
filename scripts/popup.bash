#!/usr/bin/env bash

if [ "$TMUX" = "" ]; then
  eval "$*"
  exit
fi

fifo="${TMPDIR:-/tmp/}_popup-fifo"

cleanup() {
  rm -f "$fifo"
}

trap 'cleanup' EXIT

mkfifo "$fifo"
tmux popup -d "$(pwd)" -E -x 15 "$* > $fifo" &
cat "$fifo"
rm -f "$fifo"
