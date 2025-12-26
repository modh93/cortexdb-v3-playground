#!/usr/bin/env bash
# Run CortexDB binary locally

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BIN_DIR="$REPO_ROOT/bin"
BINARY="$BIN_DIR/cortexdbd"
DATA_DIR="${CORTEXDB_DATA_DIR:-$REPO_ROOT/.cortexdb_data}"
PORT="${CORTEXDB_PORT:-8080}"

# Check if binary exists
if [[ ! -f "$BINARY" ]]; then
    echo -e "${RED}Error: CortexDB binary not found${NC}"
    echo ""
    echo "Binary expected at: $BINARY"
    echo ""
    echo "Download it first:"
    echo "  CORTEXDB_OWNER=modh93 \\"
    echo "  CORTEXDB_RELEASE_TAG=v3.4.0-bin1 \\"
    echo "  ./scripts/download_cortexdb_linux.sh"
    exit 1
fi

# Check if binary is executable
if [[ ! -x "$BINARY" ]]; then
    echo -e "${YELLOW}Making binary executable...${NC}"
    chmod +x "$BINARY"
fi

# Create data directory
mkdir -p "$DATA_DIR"

echo -e "${GREEN}CortexDB V3 Playground - Starting Server${NC}"
echo "=========================================="
echo ""
echo "Binary: $BINARY"
echo "Data directory: $DATA_DIR"
echo "Port: $PORT"
echo ""
echo -e "${GREEN}CortexDB running on http://127.0.0.1:$PORT${NC}"
echo ""
echo "To stop: Press CTRL+C"
echo ""

# Run CortexDB
"$BINARY" --db-path "$DATA_DIR" --port "$PORT"

