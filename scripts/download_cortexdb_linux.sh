#!/usr/bin/env bash
# Download CortexDB Linux binary from GitHub Release
# Supports both public and private releases (via gh CLI)

set -euo pipefail

# Default values (can be overridden via environment)
CORTEXDB_OWNER="${CORTEXDB_OWNER:-}"
CORTEXDB_REPO="${CORTEXDB_REPO:-cortexdb}"
CORTEXDB_RELEASE_TAG="${CORTEXDB_RELEASE_TAG:-}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BIN_DIR="$REPO_ROOT/bin"
BINARY_NAME="cortexdbd"
ASSET_NAME="cortexdbd-linux-x86_64"
SHA256_NAME="${ASSET_NAME}.sha256"

# Check required parameters
if [[ -z "$CORTEXDB_OWNER" ]] || [[ -z "$CORTEXDB_RELEASE_TAG" ]]; then
    echo -e "${RED}Error: Missing required parameters${NC}"
    echo ""
    echo "Usage:"
    echo "  CORTEXDB_OWNER=modh93 \\"
    echo "  CORTEXDB_REPO=cortexdb \\"
    echo "  CORTEXDB_RELEASE_TAG=v3.4.0-bin1 \\"
    echo "  ./scripts/download_cortexdb_linux.sh"
    echo ""
    echo "Environment variables:"
    echo "  CORTEXDB_OWNER      - GitHub owner/org (required)"
    echo "  CORTEXDB_REPO       - Repository name (default: cortexdb)"
    echo "  CORTEXDB_RELEASE_TAG - Release tag (required, e.g., v3.4.0-bin1)"
    echo ""
    echo "For private releases, ensure 'gh' CLI is installed and authenticated:"
    echo "  gh auth login"
    exit 1
fi

echo -e "${YELLOW}Downloading CortexDB binary${NC}"
echo "  Owner: $CORTEXDB_OWNER"
echo "  Repo: $CORTEXDB_REPO"
echo "  Tag: $CORTEXDB_RELEASE_TAG"
echo ""

# Create bin directory
mkdir -p "$BIN_DIR"

# Check if gh CLI is available
if command -v gh >/dev/null 2>&1; then
    echo -e "${GREEN}Using GitHub CLI (gh)${NC}"
    
    # Check if authenticated
    if ! gh auth status >/dev/null 2>&1; then
        echo -e "${YELLOW}Warning: GitHub CLI not authenticated${NC}"
        echo "Run: gh auth login"
        echo ""
    fi
    
    # Download using gh CLI (works for both public and private)
    cd "$BIN_DIR"
    gh release download "$CORTEXDB_RELEASE_TAG" \
        --repo "$CORTEXDB_OWNER/$CORTEXDB_REPO" \
        --pattern "$ASSET_NAME" \
        --pattern "$SHA256_NAME" \
        --clobber || {
        echo -e "${RED}Error: Failed to download release assets${NC}"
        echo "Make sure:"
        echo "  1. The release tag exists: $CORTEXDB_RELEASE_TAG"
        echo "  2. You have access to the repository"
        echo "  3. GitHub CLI is authenticated: gh auth login"
        exit 1
    }
    
    # Rename to cortexdbd
    if [[ -f "$ASSET_NAME" ]]; then
        mv "$ASSET_NAME" "$BINARY_NAME"
        echo -e "${GREEN}✓ Binary downloaded: $BIN_DIR/$BINARY_NAME${NC}"
    else
        echo -e "${RED}Error: Binary file not found after download${NC}"
        exit 1
    fi
    
    # Verify checksum
    if [[ -f "$SHA256_NAME" ]]; then
        echo -e "${YELLOW}Verifying checksum...${NC}"
        # Extract expected hash from .sha256 file (format: hash  filename)
        EXPECTED_HASH=$(awk '{print $1}' "$SHA256_NAME")
        ACTUAL_HASH=$(sha256sum "$BINARY_NAME" | awk '{print $1}')
        
        if [[ "$EXPECTED_HASH" == "$ACTUAL_HASH" ]]; then
            echo -e "${GREEN}✓ Checksum verified${NC}"
        else
            echo -e "${RED}Error: Checksum verification failed${NC}"
            echo "Expected: $EXPECTED_HASH"
            echo "Actual:   $ACTUAL_HASH"
            exit 1
        fi
        rm "$SHA256_NAME"
    else
        echo -e "${YELLOW}Warning: SHA256 file not found, skipping verification${NC}"
    fi
    
else
    echo -e "${YELLOW}GitHub CLI not found, using curl (public releases only)${NC}"
    
    # Fallback to curl (public releases only)
    BASE_URL="https://github.com/${CORTEXDB_OWNER}/${CORTEXDB_REPO}/releases/download/${CORTEXDB_RELEASE_TAG}"
    
    cd "$BIN_DIR"
    
    # Download binary
    echo "Downloading binary..."
    curl -L -f -o "$ASSET_NAME" "${BASE_URL}/${ASSET_NAME}" || {
        echo -e "${RED}Error: Failed to download binary${NC}"
        echo "This might be a private release. Install GitHub CLI:"
        echo "  https://cli.github.com/"
        echo "Then run: gh auth login"
        exit 1
    }
    
    # Download checksum
    echo "Downloading checksum..."
    curl -L -f -o "$SHA256_NAME" "${BASE_URL}/${SHA256_NAME}" || {
        echo -e "${YELLOW}Warning: Failed to download checksum file${NC}"
    }
    
    # Rename to cortexdbd
    mv "$ASSET_NAME" "$BINARY_NAME"
    echo -e "${GREEN}✓ Binary downloaded: $BIN_DIR/$BINARY_NAME${NC}"
    
    # Verify checksum if available
    if [[ -f "$SHA256_NAME" ]]; then
        echo -e "${YELLOW}Verifying checksum...${NC}"
        # Extract expected hash from .sha256 file (format: hash  filename)
        EXPECTED_HASH=$(awk '{print $1}' "$SHA256_NAME")
        ACTUAL_HASH=$(sha256sum "$BINARY_NAME" | awk '{print $1}')
        
        if [[ "$EXPECTED_HASH" == "$ACTUAL_HASH" ]]; then
            echo -e "${GREEN}✓ Checksum verified${NC}"
        else
            echo -e "${RED}Error: Checksum verification failed${NC}"
            echo "Expected: $EXPECTED_HASH"
            echo "Actual:   $ACTUAL_HASH"
            exit 1
        fi
        rm "$SHA256_NAME"
    fi
fi

# Make executable
chmod +x "$BIN_DIR/$BINARY_NAME"

echo ""
echo -e "${GREEN}✓ CortexDB binary ready: $BIN_DIR/$BINARY_NAME${NC}"
echo ""
echo "To run CortexDB:"
echo "  ./scripts/run_cortexdb.sh"

