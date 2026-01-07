# 08 — SDK TypeScript

## Objectif

Utiliser le **SDK TypeScript** de CortexDB pour interagir avec la base de données via une API TypeScript/JavaScript native, sans gérer manuellement les encodages Base64 et les requêtes HTTP.

Ce tutoriel couvre :
- Installation du SDK TypeScript depuis GitHub Releases
- Utilisation des méthodes de base (health, put, get, delete)
- Scans par préfixe
- Transactions

---

## Prérequis

- Avoir suivi `01 — Run CortexDB Locally`
- CortexDB en cours d'exécution sur `http://127.0.0.1:8080`
- Node.js 16+ installé
- GitHub CLI installé et authentifié (pour releases privées)

---

## Étape 1 : Télécharger le SDK TypeScript

Le SDK TypeScript est distribué via GitHub Releases sous forme de tarball (`.tgz`).

### 1.1. Vérifier l'authentification GitHub CLI

```bash
gh auth status
```

Si non authentifié :

```bash
gh auth login
```

### 1.2. Télécharger le SDK

```bash
CORTEXDB_OWNER=modh93 \
CORTEXDB_REPO=cortexdb \
CORTEXDB_SDK_TAG=v3.4.0-sdk1 \
./scripts/download_sdk_ts.sh
```

Le script télécharge :
- `cortexdb-sdk-ts-<version>.tgz` dans `./sdk-dist/ts/`
- Vérifie l'intégrité avec SHA256

**Résultat attendu :**

```
Downloading CortexDB TypeScript SDK
  Owner: modh93
  Repo: cortexdb
  Tag: v3.4.0-sdk1

Using GitHub CLI (gh)
✓ Tarball downloaded: cortexdb-sdk-ts-3.4.0.tgz
✓ Checksum verified
✓ CortexDB TypeScript SDK ready in: ./sdk-dist/ts
```

---

## Étape 2 : Installer le SDK

### 2.1. Créer un projet Node.js (optionnel)

Si vous n'avez pas encore de projet :

```bash
mkdir my-cortexdb-app
cd my-cortexdb-app
npm init -y
```

### 2.2. Installer le SDK depuis le tarball

```bash
npm install ../sdk-dist/ts/*.tgz
```

Ou depuis le répertoire du playground :

```bash
cd sdk-tests/ts
npm install ../../sdk-dist/ts/*.tgz
```

**Vérification :**

```bash
node -e "import('cortexdb').then(m => console.log('SDK installed successfully'))"
```

---

## Étape 3 : Utiliser le SDK

### 3.1. Script de base

Créez un fichier `example_ts.mjs` :

```javascript
#!/usr/bin/env node
import { CortexDBClient } from 'cortexdb';

// Créer un client
const client = new CortexDBClient({ baseUrl: 'http://127.0.0.1:8080' });

// Health check
const health = await client.health();
console.log(`Status: ${health.status}`);
console.log(`Version: ${health.version}`);

// Put
await client.put('user:1', Buffer.from('Alice', 'utf-8'));
console.log('✓ Put: user:1 = Alice');

// Get
const value = await client.get('user:1');
console.log(`✓ Get: user:1 = ${value.toString('utf-8')}`);

// Delete
await client.delete('user:1');
console.log('✓ Delete: user:1');
```

### 3.2. Exécuter

```bash
node example_ts.mjs
```

**Résultat attendu :**

```
Status: ok
Version: 3.4.0
✓ Put: user:1 = Alice
✓ Get: user:1 = Alice
✓ Delete: user:1
```

---

## Étape 4 : Opérations avancées

### 4.1. Scan par préfixe

```javascript
import { CortexDBClient } from 'cortexdb';

const client = new CortexDBClient({ baseUrl: 'http://127.0.0.1:8080' });

// Insérer plusieurs clés avec préfixe commun
for (let i = 1; i <= 3; i++) {
  const key = `product:${i}`;
  const value = Buffer.from(`Product ${i}`, 'utf-8');
  await client.put(key, value);
  console.log(`✓ Inserted: ${key} = ${value.toString('utf-8')}`);
}

// Scanner par préfixe
const results = await client.prefixScan('product:');
console.log(`\n✓ Found ${results.length} keys with prefix 'product:'`);

for (const { key, value } of results) {
  console.log(`  - ${key.toString('utf-8')} = ${value.toString('utf-8')}`);
}

// Nettoyage
for (let i = 1; i <= 3; i++) {
  await client.delete(`product:${i}`);
}
```

**Résultat attendu :**

```
✓ Inserted: product:1 = Product 1
✓ Inserted: product:2 = Product 2
✓ Inserted: product:3 = Product 3

✓ Found 3 keys with prefix 'product:'
  - product:1 = Product 1
  - product:2 = Product 2
  - product:3 = Product 3
```

### 4.2. Transactions

```javascript
import { CortexDBClient } from 'cortexdb';

const client = new CortexDBClient({ baseUrl: 'http://127.0.0.1:8080' });

// Démarrer une transaction
const tx = await client.beginTx();
console.log(`✓ Transaction started: ${tx.txId}`);

// Opérations dans la transaction
await tx.put('account:balance', Buffer.from('1000', 'utf-8'));
console.log('✓ Put in transaction: account:balance = 1000');

const value = await tx.get('account:balance');
console.log(`✓ Get in transaction: ${value.toString('utf-8')}`);

// La clé n'est pas visible en dehors de la transaction
try {
  await client.get('account:balance');
  console.log('✗ Key should not be visible outside transaction');
} catch (error) {
  console.log(`✓ Key not visible outside transaction (expected: ${error.constructor.name})`);
}

// Commit
await tx.commit();
console.log('✓ Transaction committed');

// Maintenant la clé est visible
const valueAfter = await client.get('account:balance');
console.log(`✓ Key visible after commit: ${valueAfter.toString('utf-8')}`);

// Nettoyage
await client.delete('account:balance');
```

**Résultat attendu :**

```
✓ Transaction started: tx_abc123
✓ Put in transaction: account:balance = 1000
✓ Get in transaction: 1000
✓ Key not visible outside transaction (expected: NotFoundError)
✓ Transaction committed
✓ Key visible after commit: 1000
```

---

## Étape 5 : Gestion des erreurs

Le SDK lève des exceptions spécifiques :

```javascript
import { CortexDBClient, NotFoundError, BadRequestError } from 'cortexdb';

const client = new CortexDBClient({ baseUrl: 'http://127.0.0.1:8080' });

// NotFoundError : clé inexistante
try {
  await client.get('nonexistent:key');
} catch (error) {
  if (error instanceof NotFoundError) {
    console.log(`✓ NotFoundError: ${error.message}`);
  }
}

// BadRequestError : clé invalide (exemple)
try {
  // Le SDK gère automatiquement l'encodage, mais des erreurs peuvent survenir
} catch (error) {
  if (error instanceof BadRequestError) {
    console.log(`✓ BadRequestError: ${error.message}`);
  }
}
```

---

## Étape 6 : Utilisation avec TypeScript

Si vous utilisez TypeScript, créez un fichier `example.ts` :

```typescript
import { CortexDBClient, HealthResponse } from 'cortexdb';

const client = new CortexDBClient({ baseUrl: 'http://127.0.0.1:8080' });

async function main() {
  const health: HealthResponse = await client.health();
  console.log(`Status: ${health.status}`);
  console.log(`Version: ${health.version}`);
  
  await client.put('key', Buffer.from('value', 'utf-8'));
  const value = await client.get('key');
  console.log(`Value: ${value.toString('utf-8')}`);
}

main().catch(console.error);
```

Compilez et exécutez :

```bash
tsc example.ts
node example.js
```

---

## Commandes de référence

### Télécharger le SDK

```bash
CORTEXDB_OWNER=modh93 \
CORTEXDB_REPO=cortexdb \
CORTEXDB_SDK_TAG=v3.4.0-sdk1 \
./scripts/download_sdk_ts.sh
```

### Installer

```bash
npm install ../../sdk-dist/ts/*.tgz
```

### Exécuter les tests smoke

```bash
cd sdk-tests/ts
npm install ../../sdk-dist/ts/*.tgz
npm run smoke
```

---

## Erreurs courantes

### "Cannot find module 'cortexdb'"

**Cause :** Le SDK n'est pas installé.

**Solution :**

```bash
npm install ../../sdk-dist/ts/*.tgz
```

### "Connection refused"

**Cause :** CortexDB n'est pas en cours d'exécution.

**Solution :**

```bash
./scripts/run_cortexdb.sh
```

### "Failed to download release assets"

**Cause :** GitHub CLI non authentifié ou tag de release inexistant.

**Solution :**

```bash
gh auth login
# Vérifier le tag
gh release view v3.4.0-sdk1 --repo modh93/cortexdb
```

### "Checksum verification failed"

**Cause :** Fichier corrompu lors du téléchargement.

**Solution :** Retélécharger le SDK :

```bash
rm -rf sdk-dist/ts/*
./scripts/download_sdk_ts.sh
```

### "SyntaxError: Cannot use import statement outside a module"

**Cause :** Le fichier n'est pas reconnu comme module ES6.

**Solution :** Utiliser l'extension `.mjs` ou ajouter `"type": "module"` dans `package.json` :

```json
{
  "type": "module"
}
```

---

## Résumé

- Le SDK TypeScript simplifie l'utilisation de CortexDB en gérant automatiquement les encodages
- Installation via tarball depuis GitHub Releases
- API TypeScript/JavaScript native : `client.put()`, `client.get()`, `client.delete()`, `client.prefixScan()`, `client.beginTx()`
- Support TypeScript avec types complets
- Gestion d'erreurs avec classes d'erreur spécifiques (`NotFoundError`, `BadRequestError`)

---

**Fin des tutoriels SDK**

