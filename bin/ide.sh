#!/usr/bin/env bash

set -euo pipefail

# generate IDE-like windows
tmux split-window -v -p 20
tmux split-window -h
