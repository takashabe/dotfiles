#!/bin/env bash

set -euo pipefail

# generate IDE-like windows
tmux split-window -v -p 30
tmux split-window -h
