# Demo Script - CortexDB V3 Playground

**Duration:** ~5 minutes  
**Audience:** Team members, potential partners  
**Goal:** Demonstrate local-first philosophy and CortexDB capabilities

---

## Setup (Before Demo)

1. **Start CortexDB server:**
   ```bash
   cd /path/to/cortexdb
   cargo build --release --features v3_server
   ./target/release/cortexdbd --db-path /tmp/cortexdb_demo --port 8080
   ```

2. **Start playground server:**
   ```bash
   cd /path/to/cortexdb-v3-playground
   ./scripts/run_playground_proxy.sh
   # Open: http://localhost:8000/playground/index.html
   ```
   
   **Note:** The proxy server avoids CORS issues by forwarding `/api/*` requests to CortexDB on the same origin.

---

## Demo Flow

### 1. Introduction (30 seconds)

**TODO:** Write introduction talking points:
- Local-first philosophy
- No cloud dependencies
- Offline-capable
- Data sovereignty

---

### 2. Health Check (30 seconds)

**TODO:** 
- Click "Health" button
- Show response: `{"status":"ok","version":"3.4.0"}`
- Explain: "Server is running locally, no external API calls"

---

### 3. Key-Value Operations (1 minute)

**TODO:**
- Put a key: `user:1` → `Alice`
- Show encoding in console (Base64 + URL encoding)
- Get the key back
- Show decoded value
- Delete the key
- Try to get again (404)

**Key points:**
- Encoding is transparent in the UI
- Console shows encoding steps for learning

---

### 4. Range Scan (1 minute)

**TODO:**
- Put multiple keys: `user:1`, `user:2`, `user:3`
- Show range scan from `a` to `z`
- Explain lexicographic ordering
- Show Base64 encoding for start/end keys

---

### 5. Transactions (1.5 minutes)

**TODO:**
- Begin transaction
- Show TX ID
- Put multiple keys in transaction
- Show they're not visible until commit
- Commit transaction
- Verify keys are now visible

**Key points:**
- ACID transactions
- Isolation until commit

---

### 6. Local-First Emphasis (30 seconds)

**TODO:**
- Disconnect from network (or show it's not needed)
- All operations still work
- Data stays on local machine
- No external dependencies

---

## Closing

**TODO:** Write closing talking points:
- Recap: local-first, offline-capable
- Next steps: tutorials, exercises
- Questions?

---

## Backup Scenarios

**TODO:** Prepare for:
- Server not starting
- CORS issues (should be resolved with proxy server)
- Encoding questions
- Performance questions

