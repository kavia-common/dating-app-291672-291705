#!/usr/bin/env bash
set -euo pipefail
# Start static server serving build/ on a free port; write PID to /tmp/serve.pid
WS="/home/kavia/workspace/code-generation/dating-app-291672-291705/AdminWebPanelReact"
cd "$WS"
export PATH="$PWD/node_modules/.bin:$PATH"
[ -d build ] || { echo "start: build directory missing" >&2; exit 2; }
# choose serve binary
if [ -x "$PWD/node_modules/.bin/serve" ]; then SERVE_BIN="$PWD/node_modules/.bin/serve";
elif command -v serve >/dev/null 2>&1; then SERVE_BIN=$(command -v serve);
else echo "start: serve not available" >&2; exit 3; fi
# find free port 3000..3010
PORT=0
for p in $(seq 3000 3010); do ss -ltn "sport = :$p" 2>/dev/null | grep -q LISTEN || { PORT=$p; break; }; done
[ "$PORT" -ne 0 ] || { echo "start: no free port" >&2; exit 4; }
LOG="/tmp/serve-${PORT}.log"
# start in background
"$SERVE_BIN" -s build -l "$PORT" >"$LOG" 2>&1 &
PID=$!
echo "$PID" >/tmp/serve.pid
# give process a moment to spawn
sleep 0.5
# verify process is running
if ! kill -0 "$PID" >/dev/null 2>&1; then echo "start: serve failed to start (pid $PID)" >&2; sed -n '1,200p' "$LOG" >&2 || true; exit 5; fi
printf "%s\n" "$PORT" > /tmp/serve.port
echo "start_ok: pid=$PID port=$PORT log=$LOG"
