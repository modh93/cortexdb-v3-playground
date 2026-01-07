#!/usr/bin/env bash
# Run the playground server with proxy support
# This solves CORS issues by proxying API requests

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PORT="${PORT:-8000}"

echo -e "${GREEN}CortexDB V3 Playground - Proxy Server${NC}"
echo "=========================================="
echo ""

# Check if Node.js is installed
if ! command -v node >/dev/null 2>&1; then
    echo -e "${YELLOW}Error: Node.js is not installed${NC}"
    echo "Please install Node.js 16+ to run the playground server."
    echo ""
    echo "Installation:"
    echo "  - Ubuntu/Debian: sudo apt install nodejs npm"
    echo "  - macOS: brew install node"
    echo "  - Or download from: https://nodejs.org/"
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [[ "$NODE_VERSION" -lt 16 ]]; then
    echo -e "${YELLOW}Warning: Node.js version should be 16 or higher${NC}"
    echo "Current version: $(node -v)"
    echo ""
fi

# Install dependencies if node_modules doesn't exist
if [[ ! -d "$REPO_ROOT/node_modules" ]]; then
    echo -e "${YELLOW}Installing dependencies...${NC}"
    cd "$REPO_ROOT"
    npm install
    echo ""
fi

# Run the server
cd "$REPO_ROOT"
echo -e "${GREEN}Starting playground server on port $PORT...${NC}"
echo ""
echo "Open in your browser:"
echo "  http://localhost:$PORT/playground/index.html"
echo ""
echo "Press CTRL+C to stop"
echo ""

PORT="$PORT" npm run playground:serve

