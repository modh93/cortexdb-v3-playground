#!/usr/bin/env bash
# Check environment for CortexDB V3 Playground

set -euo pipefail

echo "CortexDB V3 Playground - Environment Check"
echo "=========================================="
echo ""

# Check Python 3
if command -v python3 >/dev/null 2>&1; then
    PYTHON_VERSION=$(python3 --version)
    echo "✓ Python 3 found: $PYTHON_VERSION"
else
    echo "⚠ Python 3 not found (optional, for static server)"
fi

echo ""
echo "To run a static server (if needed for CORS):"
echo "  python3 -m http.server 8000"
echo ""
echo "Or use the helper script:"
echo "  ./scripts/run_static_server.sh"
echo ""

# Check if CortexDB server is running
if command -v curl >/dev/null 2>&1; then
    if curl -s -f http://127.0.0.1:8080/health >/dev/null 2>&1; then
        echo "✓ CortexDB server is running on http://127.0.0.1:8080"
    else
        echo "⚠ CortexDB server not responding on http://127.0.0.1:8080"
        echo "  Start it with: ./target/release/cortexdbd --db-path /tmp/cortexdb_data --port 8080"
    fi
else
    echo "⚠ curl not found (cannot check CortexDB server)"
fi

echo ""
echo "Environment check complete."

