# CortexDB V3 Playground

**Local-first playground for CortexDB V3.4.0**

A minimal, offline-capable playground to explore CortexDB's HTTP API. No cloud, no dependencies, runs completely offline.

---

## What you need

1. **CortexDB binary** (no source code access required)
   - Download: See [Binary Installation Guide](docs/BINARY_INSTALL.md)
   - Quick: `CORTEXDB_OWNER=modh93 CORTEXDB_RELEASE_TAG=v3.4.0-bin1 ./scripts/download_cortexdb_linux.sh`

2. **A modern web browser** (Chrome, Firefox, Safari, Edge)

3. **Optional**: Python 3 (for static server if needed)

---

## Quick demo

### Step 1: Download CortexDB Binary (No Source Access)

```bash
CORTEXDB_OWNER=modh93 \
CORTEXDB_RELEASE_TAG=v3.4.0-bin1 \
./scripts/download_cortexdb_linux.sh
```

**Note:** For private releases, ensure GitHub CLI is installed and authenticated:
```bash
gh auth login
```

### Step 2: Run CortexDB

```bash
./scripts/run_cortexdb.sh
```

CortexDB will start on `http://127.0.0.1:8080`

### Step 3: Open Playground

In a new terminal:

```bash
./scripts/run_static_server.sh
# Then open: http://localhost:8000/playground/index.html
```

### Step 4: Try It

- Click "Health" to verify connection
- Put a key/value pair
- Get it back
- Explore range scans and transactions

---

## Alternative: Run CortexDB from Source

If you have access to the CortexDB repository:

1. **Build**: `cargo build --release --features v3_server`
2. **Run**: `./target/release/cortexdbd --db-path /tmp/cortexdb_data --port 8080`

---

## Structure

- **`playground/`** - Web UI (HTML/CSS/JS vanilla)
- **`tutorials/`** - Step-by-step tutorials
- **`docs/`** - Encoding rules, FAQ, demo script
- **`scripts/`** - Helper scripts (static server, env check)

---

## Learn more

- **Tutorials**: Start with [`tutorials/00-prerequisites.md`](tutorials/00-prerequisites.md)
- **Demo script**: See [`docs/DEMO_SCRIPT.md`](docs/DEMO_SCRIPT.md) for a 5-minute walkthrough
- **Encoding rules**: Read [`docs/ENCODING.md`](docs/ENCODING.md) to understand Base64/URL encoding

---

## Philosophy

**Local-first**: This playground works entirely offline. No external APIs, no tracking, no cloud dependencies. Your data stays on your machine.

---

## License

See [LICENSE](LICENSE) file.

