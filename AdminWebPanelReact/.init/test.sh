#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/dating-app-291672-291705/AdminWebPanelReact"
cd "$WS"
export PATH="$PWD/node_modules/.bin:$PATH"
if [ ! -f /tmp/serve.pid ] || [ ! -f /tmp/serve.port ]; then echo "test: server not started (missing /tmp/serve.pid or /tmp/serve.port)" >&2; exit 2; fi
PID=$(cat /tmp/serve.pid)
PORT=$(cat /tmp/serve.port)
URL="http://127.0.0.1:${PORT}/"
# poll readiness up to 30s
SECS=0
HTTP_STATUS=000
while [ $SECS -lt 30 ]; do
  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL" || echo "000")
  [ "$HTTP_STATUS" = "200" ] && break
  sleep 1
  SECS=$((SECS+1))
done
if [ "$HTTP_STATUS" != "200" ]; then
  echo "test: smoke test failed status=$HTTP_STATUS" >&2
  LOG="/tmp/serve-${PORT}.log"
  echo "-- serve log (first 400 lines) --" >&2
  sed -n '1,400p' "$LOG" >&2 || true
  # attempt cleanup
  kill "$PID" >/dev/null 2>&1 || true
  wait "$PID" 2>/dev/null || true
  exit 3
fi
echo "test_ok: http_status=$HTTP_STATUS port=$PORT"
