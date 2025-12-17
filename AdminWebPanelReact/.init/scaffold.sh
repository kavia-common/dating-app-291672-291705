#!/usr/bin/env bash
set -euo pipefail
# Minimal CRA scaffold with explicit TS opt-in; uses container workspace variable
WS="/home/kavia/workspace/code-generation/dating-app-291672-291705/AdminWebPanelReact"
mkdir -p "$WS" && cd "$WS"
# skip if project exists
if [ -f package.json ]; then echo "package.json exists, skipping scaffold"; exit 0; fi
# ensure dir effectively empty (allow .git)
shopt -s dotglob
non_ignored=$(find "$WS" -maxdepth 1 -mindepth 1 ! -name '.git' ! -name '.' -print -quit || true)
if [ -n "$non_ignored" ]; then echo "workspace not empty and package.json missing; aborting" >&2; exit 5; fi
# choose CRA: prefer preinstalled create-react-app
if command -v create-react-app >/dev/null 2>&1; then CRA_CMD=(create-react-app); else CRA_CMD=(npx --yes create-react-app@5); fi
# Require explicit TypeScript opt-in
USE_TS="${USE_TYPESCRIPT:-0}"
if [ "$USE_TS" = "1" ]; then
  "${CRA_CMD[@]}" . --use-npm --template typescript --silent
else
  "${CRA_CMD[@]}" . --use-npm --silent
fi
# ensure package name and essential scripts
if [ -f package.json ]; then
  node -e "const fs=require('fs');const p='./package.json';let f=require(p)||{};f.name=f.name||'admin-web-panel-react';f.scripts=f.scripts||{};f.scripts.start=f.scripts.start||'react-scripts start';f.scripts.build=f.scripts.build||'react-scripts build';f.scripts.test=f.scripts.test||'react-scripts test';fs.writeFileSync(p,JSON.stringify(f,null,2));"
fi
# add .env and README.md if missing
[ -f "$WS/.env" ] || cat > "$WS/.env" <<'EOF'
REACT_APP_API_URL=http://localhost:4000
EOF
[ -f "$WS/README.md" ] || echo "Admin Web Panel React - scaffolded" > "$WS/README.md"
# signal completion
echo "scaffold_ok"
