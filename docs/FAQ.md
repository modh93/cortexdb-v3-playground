# Frequently Asked Questions

## Server Issues

### Q: "Connection failed" or "Network error"

**A:** Make sure CortexDB server is running:
```bash
./target/release/cortexdbd --db-path /tmp/cortexdb_data --port 8080
```

Check with:
```bash
curl http://127.0.0.1:8080/health
```

---

### Q: "CORS error" when opening `index.html` directly

**A:** Browsers block `fetch()` from `file://` URLs. Use a static server:

```bash
./scripts/run_static_server.sh
# Then open: http://localhost:8000/playground/index.html
```

---

## Encoding Issues

### Q: "404 Not Found" when trying to GET a key

**A:** Check your key encoding:
1. Is the key Base64 encoded?
2. Is it URL percent-encoded? (especially `/`, `+`, `=`)

Use the playground's console to see the encoding steps.

---

### Q: "Invalid Base64" error

**A:** Make sure you're using:
- **RFC 4648** standard (with padding `=`)
- **No URL encoding** in JSON body values (only in URL paths)

---

## General

### Q: Can I use this playground offline?

**A:** Yes! Once CortexDB server is running locally, everything works offline. No external APIs, no cloud dependencies.

---

### Q: Where is my data stored?

**A:** Data is stored in the directory you specify with `--db-path`:
```bash
--db-path /tmp/cortexdb_data
```

This is a local directory on your machine.

---

### Q: Can I modify the playground code?

**A:** Absolutely! It's vanilla HTML/CSS/JS. Edit `playground/index.html`, `styles.css`, or `app.js` as needed.

---

### Q: How do I reset the database?

**A:** Stop the server, delete the database directory, and restart:
```bash
rm -rf /tmp/cortexdb_data
./target/release/cortexdbd --db-path /tmp/cortexdb_data --port 8080
```

---

## Troubleshooting

### Q: Playground shows "undefined" in console

**A:** Check browser console (F12) for JavaScript errors. Make sure all files (`index.html`, `styles.css`, `app.js`) are in the same directory.

---

### Q: Buttons don't work

**A:** 
1. Check browser console for errors
2. Verify CortexDB server is running
3. Try refreshing the page
4. If using `file://`, switch to static server

---

### Q: Transaction ID doesn't appear

**A:** Click "Begin" first to start a transaction. The TX ID will appear in the input field.

