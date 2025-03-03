#!/bin/bash
# This script is used to restart Aerospace.app
# refrelsh the app, because sometimes the workspace switching doesn't work well
#
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title aerospace restart
# @raycast.mode compact

pkill AeroSpace
# wait for the app to close
sleep 1
open -a "AeroSpace"
