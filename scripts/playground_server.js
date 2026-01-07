#!/usr/bin/env node
/**
 * CortexDB V3 Playground Server
 * 
 * Serves the playground static files and proxies API requests to CortexDB.
 * This solves CORS issues by keeping everything on the same origin.
 */

import express from 'express';
import { createProxyMiddleware } from 'http-proxy-middleware';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const REPO_ROOT = join(__dirname, '..');

const app = express();
const PORT = process.env.PORT || 8000;
const CORTEXDB_URL = process.env.CORTEXDB_URL || 'http://127.0.0.1:8080';

// Logging middleware
app.use((req, res, next) => {
    const timestamp = new Date().toISOString();
    console.log(`[${timestamp}] ${req.method} ${req.path}`);
    next();
});

// Serve static files from playground directory
app.use('/playground', express.static(join(REPO_ROOT, 'playground')));

// Serve assets if needed
app.use('/assets', express.static(join(REPO_ROOT, 'playground', 'assets')));

// Proxy API requests to CortexDB
app.use(
    '/api',
    createProxyMiddleware({
        target: CORTEXDB_URL,
        changeOrigin: true,
        pathRewrite: {
            '^/api': '', // Remove /api prefix when forwarding to CortexDB
        },
        onProxyReq: (proxyReq, req, res) => {
            console.log(`[PROXY] ${req.method} ${req.path} -> ${CORTEXDB_URL}${req.path.replace('/api', '')}`);
        },
        onProxyRes: (proxyRes, req, res) => {
            console.log(`[PROXY] ${req.method} ${req.path} <- ${proxyRes.statusCode}`);
        },
        onError: (err, req, res) => {
            console.error(`[PROXY ERROR] ${req.method} ${req.path}:`, err.message);
            res.status(502).json({
                error: {
                    code: 'PROXY_ERROR',
                    message: `Failed to connect to CortexDB at ${CORTEXDB_URL}`,
                    details: err.message,
                },
            });
        },
    })
);

// Root redirect to playground
app.get('/', (req, res) => {
    res.redirect('/playground/index.html');
});

// Health check for the proxy server itself
app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        service: 'cortexdb-playground-proxy',
        cortexdb_url: CORTEXDB_URL,
    });
});

// Start server
app.listen(PORT, () => {
    console.log('='.repeat(60));
    console.log('CortexDB V3 Playground Server');
    console.log('='.repeat(60));
    console.log(`Server running on: http://localhost:${PORT}`);
    console.log(`Playground URL: http://localhost:${PORT}/playground/index.html`);
    console.log(`API Proxy: http://localhost:${PORT}/api/* -> ${CORTEXDB_URL}/*`);
    console.log('');
    console.log('Press CTRL+C to stop');
    console.log('='.repeat(60));
});

