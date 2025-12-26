// CortexDB V3 Playground - Main Application Logic

let currentTxId = null;

// Get base URL from input
function getBaseUrl() {
    return document.getElementById('baseUrl').value.trim() || 'http://127.0.0.1:8080';
}

// Encoding helpers
function toBase64(str) {
    return btoa(unescape(encodeURIComponent(str)));
}

function fromBase64(b64) {
    try {
        return decodeURIComponent(escape(atob(b64)));
    } catch (e) {
        return `[Invalid Base64: ${b64}]`;
    }
}

function urlEncodeBase64(b64) {
    return encodeURIComponent(b64)
        .replace(/%2F/g, '%2F')
        .replace(/%2B/g, '%2B')
        .replace(/%3D/g, '%3D');
}

function encodeKeyForPath(keyText) {
    const b64 = toBase64(keyText);
    return urlEncodeBase64(b64);
}

// Console output
function logToConsole(title, data, isError = false, isSuccess = false) {
    const output = document.getElementById('consoleOutput');
    const entry = document.createElement('div');
    entry.className = `console-entry ${isError ? 'error' : ''} ${isSuccess ? 'success' : ''}`;
    
    let html = `<h3>${title}</h3>`;
    
    if (data.method) {
        html += `<div><strong>Method:</strong> ${data.method}</div>`;
    }
    if (data.url) {
        html += `<div><strong>URL:</strong> <code>${data.url}</code></div>`;
    }
    if (data.requestBody) {
        html += `<div><strong>Request Body:</strong> <pre>${JSON.stringify(data.requestBody, null, 2)}</pre></div>`;
    }
    if (data.status) {
        html += `<div><strong>Status:</strong> <span style="color: ${data.status >= 200 && data.status < 300 ? '#4caf50' : '#f44336'}">${data.status}</span></div>`;
    }
    if (data.response) {
        html += `<div><strong>Response:</strong> <pre>${JSON.stringify(data.response, null, 2)}</pre></div>`;
    }
    if (data.encoding) {
        html += `<div class="encoding-info"><strong>Encoding Info:</strong><br>${data.encoding}</div>`;
    }
    if (data.error) {
        html += `<div style="color: #f44336;"><strong>Error:</strong> ${data.error}</div>`;
    }
    
    entry.innerHTML = html;
    output.insertBefore(entry, output.firstChild);
    
    // Keep only last 20 entries
    while (output.children.length > 20) {
        output.removeChild(output.lastChild);
    }
}

// Generic fetch wrapper
async function apiCall(method, path, body = null, showEncoding = false) {
    const baseUrl = getBaseUrl();
    const url = `${baseUrl}${path}`;
    
    const options = {
        method: method,
        headers: {}
    };
    
    if (body) {
        options.headers['Content-Type'] = 'application/json';
        options.body = JSON.stringify(body);
    }
    
    let encodingInfo = '';
    if (showEncoding && body && body.key) {
        const keyB64 = toBase64(body.key);
        const keyUrl = encodeKeyForPath(body.key);
        encodingInfo = `Key "${body.key}" → Base64: "${keyB64}" → URL: "${keyUrl}"`;
    }
    
    try {
        logToConsole(`${method} ${path}`, {
            method,
            url,
            requestBody: body,
            encoding: encodingInfo
        });
        
        const response = await fetch(url, options);
        const responseText = await response.text();
        
        let responseData;
        try {
            responseData = JSON.parse(responseText);
        } catch (e) {
            responseData = responseText || '(empty)';
        }
        
        const isSuccess = response.status >= 200 && response.status < 300;
        const isError = response.status >= 400;
        
        logToConsole(`${method} ${path} - Response`, {
            status: response.status,
            response: responseData
        }, isError, isSuccess);
        
        return { status: response.status, data: responseData };
    } catch (error) {
        logToConsole(`${method} ${path} - Error`, {
            error: error.message
        }, true);
        return { status: 0, error: error.message };
    }
}

// System operations
async function testConnection() {
    await callHealth();
}

async function callHealth() {
    const result = await apiCall('GET', '/health');
    if (result.status === 200) {
        logToConsole('✓ Connection successful', {}, false, true);
    }
}

async function callStats() {
    await apiCall('GET', '/stats');
}

// KV operations
async function kvPut() {
    const key = document.getElementById('kvKey').value.trim();
    const value = document.getElementById('kvValue').value.trim();
    
    if (!key || !value) {
        logToConsole('KV PUT - Error', { error: 'Key and value are required' }, true);
        return;
    }
    
    const keyB64 = toBase64(key);
    const valueB64 = toBase64(value);
    const keyUrl = encodeKeyForPath(key);
    
    const encodingInfo = `Key "${key}" → Base64: "${keyB64}" → URL: "${keyUrl}"<br>Value "${value}" → Base64: "${valueB64}"`;
    
    logToConsole('KV PUT - Encoding', { encoding: encodingInfo });
    
    await apiCall('PUT', `/kv/${keyUrl}`, { value: valueB64 });
}

async function kvGet() {
    const key = document.getElementById('kvKey').value.trim();
    
    if (!key) {
        logToConsole('KV GET - Error', { error: 'Key is required' }, true);
        return;
    }
    
    const keyUrl = encodeKeyForPath(key);
    const encodingInfo = `Key "${key}" → Base64 → URL: "${keyUrl}"`;
    
    logToConsole('KV GET - Encoding', { encoding: encodingInfo });
    
    const result = await apiCall('GET', `/kv/${keyUrl}`);
    
    if (result.status === 200 && result.data && result.data.value) {
        const decodedValue = fromBase64(result.data.value);
        logToConsole('KV GET - Decoded', {
            encoding: `Base64 "${result.data.value}" → Text: "${decodedValue}"`
        }, false, true);
    }
}

async function kvDelete() {
    const key = document.getElementById('kvKey').value.trim();
    
    if (!key) {
        logToConsole('KV DELETE - Error', { error: 'Key is required' }, true);
        return;
    }
    
    const keyUrl = encodeKeyForPath(key);
    await apiCall('DELETE', `/kv/${keyUrl}`);
}

// Range scan
async function rangeScan() {
    const start = document.getElementById('rangeStart').value.trim();
    const end = document.getElementById('rangeEnd').value.trim();
    const limit = parseInt(document.getElementById('rangeLimit').value) || 10;
    
    if (!start || !end) {
        logToConsole('Range Scan - Error', { error: 'Start and end keys are required (Base64)' }, true);
        return;
    }
    
    await apiCall('POST', '/range', { start, end, limit });
}

// Prefix scan
async function prefixScan() {
    const prefix = document.getElementById('prefixKey').value.trim();
    const limit = parseInt(document.getElementById('prefixLimit').value) || 10;
    
    if (!prefix) {
        logToConsole('Prefix Scan - Error', { error: 'Prefix key is required (Base64)' }, true);
        return;
    }
    
    await apiCall('POST', '/prefix', { prefix, limit });
}

// Transaction operations
async function txBegin() {
    const result = await apiCall('POST', '/tx/begin', {});
    if (result.status === 200 && result.data && result.data.tx_id) {
        currentTxId = result.data.tx_id;
        document.getElementById('txId').value = currentTxId;
        logToConsole('Transaction started', { encoding: `TX ID: ${currentTxId}` }, false, true);
    }
}

async function txPut() {
    if (!currentTxId) {
        logToConsole('Tx PUT - Error', { error: 'No active transaction. Click "Begin" first.' }, true);
        return;
    }
    
    const key = document.getElementById('txKey').value.trim();
    const value = document.getElementById('txValue').value.trim();
    
    if (!key || !value) {
        logToConsole('Tx PUT - Error', { error: 'Key and value are required' }, true);
        return;
    }
    
    const keyB64 = toBase64(key);
    const valueB64 = toBase64(value);
    
    await apiCall('POST', `/tx/${currentTxId}/put`, {
        key: keyB64,
        value: valueB64
    });
}

async function txGet() {
    if (!currentTxId) {
        logToConsole('Tx GET - Error', { error: 'No active transaction. Click "Begin" first.' }, true);
        return;
    }
    
    const key = document.getElementById('txKey').value.trim();
    
    if (!key) {
        logToConsole('Tx GET - Error', { error: 'Key is required' }, true);
        return;
    }
    
    const keyUrl = encodeKeyForPath(key);
    await apiCall('GET', `/tx/${currentTxId}/get/${keyUrl}`);
}

async function txCommit() {
    if (!currentTxId) {
        logToConsole('Tx Commit - Error', { error: 'No active transaction.' }, true);
        return;
    }
    
    const result = await apiCall('POST', `/tx/${currentTxId}/commit`, {});
    if (result.status === 200) {
        currentTxId = null;
        document.getElementById('txId').value = '';
        logToConsole('Transaction committed', {}, false, true);
    }
}

async function txAbort() {
    if (!currentTxId) {
        logToConsole('Tx Abort - Error', { error: 'No active transaction.' }, true);
        return;
    }
    
    const result = await apiCall('POST', `/tx/${currentTxId}/abort`, {});
    if (result.status === 200) {
        currentTxId = null;
        document.getElementById('txId').value = '';
        logToConsole('Transaction aborted', {}, false, true);
    }
}

