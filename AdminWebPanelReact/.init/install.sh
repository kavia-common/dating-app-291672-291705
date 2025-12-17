#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/dating-app-291672-291705/AdminWebPanelReact"
cd "$WS"
# validate
command -v npm >/dev/null 2>&1 || { echo "npm not found" >&2; exit 3; }
[ -f package.json ] || { echo "package.json missing" >&2; exit 2; }
# fast-path: if node_modules exists and lockfile unchanged we could skip; keep simple and reproducible
# choose reproducible install
if [ -f package-lock.json ] || [ -f npm-shrinkwrap.json ]; then
  npm ci --no-audit --no-fund --silent
else
  npm i --no-audit --no-fund --silent
fi
# ensure dev tools declared in package.json (non-brittle check) and add missing as devDependencies
MISSING=$(node -e "const fs=require('fs'); const pkg=JSON.parse(fs.readFileSync('package.json')); const dev=pkg.devDependencies||{}; const dep=pkg.dependencies||{}; const want=['@testing-library/react','@testing-library/jest-dom','msw','json-server','serve','eslint']; const need=want.filter(x=>!(dev[x]||dep[x])); console.log(need.join(' '))")
if [ -n "$MISSING" ]; then
  npm i --no-audit --no-fund --silent --save-dev $MISSING
fi
# ensure types for TypeScript projects
if [ -f tsconfig.json ] || grep -q '"typescript"' package.json 2>/dev/null || grep -q '\.tsx\?' -r --exclude-dir=node_modules . 2>/dev/null || ls src/*.ts* >/dev/null 2>&1; then
  for t in typescript @types/react @types/react-dom; do
    if ! node -e "const fs=require('fs'); const pkg=JSON.parse(fs.readFileSync('package.json')); if(!((pkg.devDependencies&&pkg.devDependencies['$t'])||(pkg.dependencies&&pkg.dependencies['$t']))) process.exit(0); else process.exit(1);"; then
      npm i --no-audit --no-fund --silent --save-dev "$t"
    fi
  done
fi
# ensure minimal eslint config
[ -f .eslintrc.json ] || cat >.eslintrc.json <<'EOF'
{ "env": {"browser": true, "es2021": true}, "extends": ["eslint:recommended","react-app"], "rules": {} }
EOF
# Export node_modules/.bin for this run and future non-login shells in this session
export PATH="$PWD/node_modules/.bin:$PATH"
# persist PATH for non-login shells started in this container session by writing to /etc/profile.d if writable and content differs
PROFILE="/etc/profile.d/adminwebpanel_node.sh"
PROFILE_TMP="/tmp/adminwebpanel_node.sh"
cat > "$PROFILE_TMP" <<EOF
# AdminWebPanelReact environment additions (idempotent)
export NODE_ENV="${NODE_ENV:-development}"
export PATH=\"\$PWD/node_modules/.bin:\$PATH\"
EOF
if [ -w /etc/profile.d ]; then
  if ! cmp -s "$PROFILE_TMP" "$PROFILE" 2>/dev/null; then
    sudo mv "$PROFILE_TMP" "$PROFILE"
    sudo chmod 644 "$PROFILE"
  else
    rm -f "$PROFILE_TMP"
  fi
else
  rm -f "$PROFILE_TMP" || true
fi
# validate npm/node accessible
command -v node >/dev/null 2>&1 || { echo "node not found on PATH after install" >&2; exit 4; }
node -v >/dev/null 2>&1 && npm -v >/dev/null 2>&1 || { echo "node/npm version check failed" >&2; exit 5; }
echo "deps_ok"
