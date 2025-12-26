# CortexDB V3 Playground

**Local-first playground for CortexDB V3.4.0**

A minimal, offline-capable playground to explore CortexDB's HTTP API. No cloud, no dependencies, runs completely offline.

---

## What you need

1. **CortexDB server running locally** on `http://127.0.0.1:8080`
   - Build: `cargo build --release --features v3_server`
   - Run: `./target/release/cortexdbd --db-path /tmp/cortexdb_data --port 8080`

2. **A modern web browser** (Chrome, Firefox, Safari, Edge)

3. **Optional**: Python 3 (for static server if needed)

---

## Quick demo

1. **Start CortexDB server** (see above)

2. **Open the playground**:
   ```bash
   # Option 1: Direct file (may have CORS restrictions)
   open playground/index.html
   
   # Option 2: Static server (recommended)
   ./scripts/run_static_server.sh
   # Then open http://localhost:8000/playground/index.html
   ```

3. **Try it**:
   - Click "Health" to verify connection
   - Put a key/value pair
   - Get it back
   - Explore range scans and transactions

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

