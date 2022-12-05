#!/usr/bin/env bash

if [ "$TMUX" = "" ]; then
  eval "nvim $*"
  exit
fi

tmux popup -E -x 15 "nvim $*"
