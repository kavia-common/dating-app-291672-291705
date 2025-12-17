#!/usr/bin/env bash
set -euo pipefail
# Orchestrates start -> test -> stop and returns non-zero on failure
WS="/home/kavia/workspace/code-generation/dating-app-291672-291705/AdminWebPanelReact"
cd "$WS"
# run start, test, stop in sequence; any failure will exit due to set -e
bash .init/start.sh
trap 'bash .init/stop.sh || true' EXIT
bash .init/test.sh
# success; explicit stop
trap - EXIT
bash .init/stop.sh
echo "validation_ok"
