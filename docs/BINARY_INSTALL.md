# Binary Installation Guide

## Philosophy

This playground repository **does not contain** the CortexDB source code. Instead, it uses pre-compiled binaries distributed via GitHub Releases.

**Benefits:**
- No need for Rust toolchain
- No access to private CortexDB repository required
- Quick setup for demos and presentations
- Local-first: works completely offline after download

---

## Download Binary (Linux)

### Prerequisites

- **GitHub CLI** (`gh`) - Recommended for private releases
  - Install: https://cli.github.com/
  - Authenticate: `gh auth login`

OR

- **curl** - For public releases only

### Download Script

Use the provided download script:

```bash
CORTEXDB_OWNER=modh93 \
CORTEXDB_REPO=cortexdb \
CORTEXDB_RELEASE_TAG=v3.4.0 \
./scripts/download_cortexdb_linux.sh
```

**Environment variables:**
- `CORTEXDB_OWNER` - GitHub owner/org (required)
- `CORTEXDB_REPO` - Repository name (default: `cortexdb`)
- `CORTEXDB_RELEASE_TAG` - Release tag (required, e.g., `v3.4.0`)

### What the Script Does

1. Downloads `cortexdbd-linux-x86_64` from GitHub Release
2. Downloads `cortexdbd-linux-x86_64.sha256` checksum
3. Verifies SHA256 checksum
4. Places binary in `./bin/cortexdbd`
5. Makes it executable

### Private Releases

If the CortexDB repository is private:

1. **Install GitHub CLI**: https://cli.github.com/
2. **Authenticate**: `gh auth login`
3. **Run download script** (same as above)

The script will automatically use `gh release download` which handles authentication.

---

## Run CortexDB

After downloading the binary:

```bash
./scripts/run_cortexdb.sh
```

This will:
- Start CortexDB on `http://127.0.0.1:8080`
- Create data directory at `./.cortexdb_data`
- Display connection information

**To stop:** Press `CTRL+C`

### Custom Configuration

You can override defaults via environment variables:

```bash
CORTEXDB_DATA_DIR=/custom/path \
CORTEXDB_PORT=9090 \
./scripts/run_cortexdb.sh
```

---

## Verify Installation

Check that the binary is downloaded and executable:

```bash
ls -lh ./bin/cortexdbd
./bin/cortexdbd --version
```

---

## Troubleshooting

### "Binary not found"

**Solution:** Run the download script first (see above).

### "Checksum verification failed"

**Solution:** Re-download the binary. The file may be corrupted.

### "Failed to download" (private release)

**Solution:** 
1. Install GitHub CLI: `gh auth login`
2. Ensure you have access to the repository
3. Re-run the download script

### "Permission denied"

**Solution:** The script should make the binary executable automatically. If not:
```bash
chmod +x ./bin/cortexdbd
```

---

## Manual Download (Alternative)

If you prefer to download manually:

1. Go to GitHub Releases: `https://github.com/OWNER/REPO/releases/tag/v3.4.0`
2. Download `cortexdbd-linux-x86_64`
3. Download `cortexdbd-linux-x86_64.sha256`
4. Verify checksum: `sha256sum -c cortexdbd-linux-x86_64.sha256`
5. Rename: `mv cortexdbd-linux-x86_64 bin/cortexdbd`
6. Make executable: `chmod +x bin/cortexdbd`

---

## Next Steps

Once CortexDB is running:

1. **Start playground**: `./scripts/run_static_server.sh`
2. **Open browser**: `http://localhost:8000/playground/index.html`
3. **Follow tutorials**: Start with `tutorials/00-prerequisites.md`

---

## Security Note

Always verify the SHA256 checksum before running the binary. The download script does this automatically.

