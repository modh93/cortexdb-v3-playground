#!/usr/bin/env bash
# Run a simple static HTTP server for the playground
# Solves CORS issues when opening index.html directly

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PORT="${1:-8000}"

echo "Starting static server for CortexDB V3 Playground"
echo "=================================================="
echo ""
echo "Server will run on: http://localhost:$PORT"
echo "Playground URL: http://localhost:$PORT/playground/index.html"
echo ""
echo "Press CTRL+C to stop"
echo ""

cd "$REPO_ROOT"

if command -v python3 >/dev/null 2>&1; then
    python3 -m http.server "$PORT"
elif command -v python >/dev/null 2>&1; then
    python -m SimpleHTTPServer "$PORT" 2>/dev/null || python -m http.server "$PORT"
else
    echo "Error: Python not found. Please install Python 3."
    exit 1
fi

