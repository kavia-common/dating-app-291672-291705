#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/dating-app-291672-291705/AdminWebPanelReact"
cd "$WS"
# Ensure local node binaries are prioritized for this run
export PATH="$PWD/node_modules/.bin:$PATH"
# Confirm package.json present
[ -f package.json ] || { echo "package.json missing" >&2; exit 2; }
# Run production build silently
npm run build --silent
# Validate output dir (create-react-app default is 'build')
if [ -d build ]; then echo "build_ok"; else echo "build missing" >&2; exit 3; fi
