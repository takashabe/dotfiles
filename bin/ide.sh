#!/bin/env bash

set -eou

# generate IDE-like windows
tmux split-window -v -p 30
tmux split-window -h -p 66
tmux split-window -h -p 50
