# Encoding Rules for CortexDB V3

CortexDB V3 uses **Base64 encoding** (RFC 4648) for keys and values, with additional **URL percent-encoding** for keys in URL paths.

---

## Key Encoding (for URL paths)

Keys in URL paths (e.g., `/kv/{key}`) must be:

1. **Base64 encoded** (RFC 4648 with padding `=`)
2. **URL percent-encoded** (to handle special characters)

### Example

```
Original key: "user:1"
↓
Base64: "dXNlcjox"
↓
URL encoded: "dXNlcjox" (no special chars, so unchanged)
```

If the Base64 contains special characters:
```
Base64: "a/b+c="
↓
URL encoded: "a%2Fb%2Bc%3D"
```

**Characters that need URL encoding:**
- `/` → `%2F`
- `+` → `%2B`
- `=` → `%3D`

---

## Value Encoding (in JSON bodies)

Values in JSON request/response bodies use **Base64 only** (no URL encoding).

### Example

```json
{
  "value": "QWxpY2U="
}
```

The Base64 string `"QWxpY2U="` represents the text `"Alice"`.

---

## Helper Functions

### JavaScript (Browser)

```javascript
// Encode key for URL path
function encodeKeyForPath(keyText) {
    const b64 = btoa(keyText);
    return encodeURIComponent(b64);
}

// Encode value for JSON body
function encodeValueForBody(valueText) {
    return btoa(valueText);
}

// Decode Base64 to text
function decodeBase64(b64) {
    return atob(b64);
}
```

### Python

```python
import base64
import urllib.parse

# Encode key for URL path
def encode_key_for_path(key_text):
    b64 = base64.b64encode(key_text.encode()).decode()
    return urllib.parse.quote(b64, safe='')

# Encode value for JSON body
def encode_value_for_body(value_text):
    return base64.b64encode(value_text.encode()).decode()

# Decode Base64 to text
def decode_base64(b64):
    return base64.b64decode(b64).decode()
```

---

## Common Mistakes

❌ **Wrong**: Using URL encoding in JSON body values
```json
{"value": "QWxpY2U%3D"}  // ❌ Don't URL-encode in JSON
```

✅ **Correct**: Base64 only in JSON body
```json
{"value": "QWxpY2U="}  // ✅ Base64 only
```

❌ **Wrong**: Forgetting URL encoding for keys in paths
```
/kv/dXNlcjox  // ❌ If Base64 contains /, +, or =
```

✅ **Correct**: URL-encode the Base64 key
```
/kv/dXNlcjox  // ✅ If no special chars
/kv/a%2Fb%2Bc%3D  // ✅ If special chars present
```

---

## Quick Reference

| Location | Encoding | Example |
|----------|----------|---------|
| Key in URL path | Base64 + URL percent-encoding | `/kv/dXNlcjox` |
| Value in JSON body | Base64 only | `{"value": "QWxpY2U="}` |
| Key in JSON body (tx) | Base64 only | `{"key": "dXNlcjox", "value": "..."}` |

