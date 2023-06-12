#!/usr/bin/env bash

if test -f /usr/local/bin/op; then
  /usr/local/bin/op item get "System Password" --fields password
else
  /usr/bin/op item get "System Password" --fields password
fi
