# Tests SDK - Guide Complet

Ce document explique comment tester les SDK Python et TypeScript de CortexDB dans le playground.

## Vue d'ensemble

Les SDKs sont distribués via GitHub Releases sous des tags dédiés (ex: `v3.4.0-sdk1`). Le repo playground fournit des scripts pour télécharger ces SDKs et exécuter des tests smoke.

## Prérequis

### 1. CortexDB en cours d'exécution

Avant de tester les SDKs, vous devez lancer CortexDB :

```bash
./scripts/run_cortexdb.sh
```

CortexDB sera accessible sur `http://127.0.0.1:8080` par défaut.

### 2. GitHub CLI (recommandé pour releases privées)

Pour télécharger les SDKs depuis un repo privé, installez et authentifiez GitHub CLI :

```bash
# Installation (Linux)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# Authentification
gh auth login
```

Pour les releases publiques, `curl` peut être utilisé en fallback (mais nécessite de connaître les noms exacts des fichiers).

## Convention de tags SDK

Les SDKs sont publiés dans GitHub Releases avec des tags dédiés :

- Format : `vX.Y.Z-sdkN` (ex: `v3.4.0-sdk1`)
- Assets attendus dans la release :
  - `cortexdb-sdk-python-<version>.whl`
  - `cortexdb-sdk-python-<version>.whl.sha256`
  - `cortexdb-sdk-ts-<version>.tgz`
  - `cortexdb-sdk-ts-<version>.tgz.sha256`

## Téléchargement des SDKs

### Python SDK

```bash
CORTEXDB_OWNER=modh93 \
CORTEXDB_REPO=cortexdb \
CORTEXDB_SDK_TAG=v3.4.0-sdk1 \
./scripts/download_sdk_python.sh
```

Le script :
1. Télécharge le wheel et son checksum depuis la release GitHub
2. Vérifie l'intégrité avec SHA256
3. Place les fichiers dans `./sdk-dist/python/`

### TypeScript SDK

```bash
CORTEXDB_OWNER=modh93 \
CORTEXDB_REPO=cortexdb \
CORTEXDB_SDK_TAG=v3.4.0-sdk1 \
./scripts/download_sdk_ts.sh
```

Le script :
1. Télécharge le tarball et son checksum depuis la release GitHub
2. Vérifie l'intégrité avec SHA256
3. Place les fichiers dans `./sdk-dist/ts/`

## Installation et exécution des tests

### Python SDK

#### 1. Créer un environnement virtuel

```bash
python3 -m venv .venv
source .venv/bin/activate
```

#### 2. Installer le SDK

```bash
pip install ./sdk-dist/python/*.whl
```

#### 3. Exécuter les tests smoke

```bash
cd sdk-tests/python
python smoke.py
```

Ou avec une URL personnalisée :

```bash
BASE_URL=http://127.0.0.1:8080 python smoke.py
```

### TypeScript SDK

#### 1. Installer les dépendances

```bash
cd sdk-tests/ts
npm install ../../sdk-dist/ts/*.tgz
```

#### 2. Exécuter les tests smoke

```bash
npm run smoke
```

Ou avec une URL personnalisée :

```bash
BASE_URL=http://127.0.0.1:8080 npm run smoke
```

## Tests smoke - Détails

Les tests smoke vérifient les fonctionnalités de base :

1. **Health check** : Vérifie que le serveur répond et retourne un statut "ok"
2. **KV operations** : Put, Get, Delete sur une clé unique
3. **Prefix scan** : Insertion de 3 clés avec préfixe commun, puis scan par préfixe
4. **Transactions** : Begin, Put, Get dans la transaction, Commit, vérification de la visibilité

### Résultat attendu

```
============================================================
CortexDB Python SDK - Smoke Test
============================================================
Base URL: http://127.0.0.1:8080
Test ID: abc12345

[TEST 1] Health check...
  ✓ Health OK: ok (version: 3.4.0)

[TEST 2] KV operations...
  ✓ Put: sdk:py:smoke:abc12345
  ✓ Get: sdk:py:smoke:abc12345 = smoke_test_value
  ✓ Delete: sdk:py:smoke:abc12345
  ✓ Verified deletion (expected error: NotFoundError)

[TEST 3] Prefix scan...
  ✓ Inserted: sdk:py:scan:abc12345:1
  ✓ Inserted: sdk:py:scan:abc12345:2
  ✓ Inserted: sdk:py:scan:abc12345:3
  ✓ Prefix scan found 3 keys
  ✓ Cleanup completed

[TEST 4] Transactions...
  ✓ Transaction started: tx_abc123
  ✓ Put in transaction: sdk:py:tx:abc12345
  ✓ Get in transaction: tx_value
  ✓ Key not visible outside transaction (expected)
  ✓ Transaction committed
  ✓ Key visible after commit: tx_value
  ✓ Update outside transaction: after_tx_value
  ✓ Cleanup completed

============================================================
[OK] Python SDK smoke test passed
============================================================
```

## Dépannage

### Erreur : "GitHub CLI not authenticated"

```bash
gh auth login
```

### Erreur : "Failed to download release assets"

Vérifiez :
1. Le tag de release existe : `gh release view v3.4.0-sdk1 --repo modh93/cortexdb`
2. Vous avez accès au repo (pour releases privées)
3. GitHub CLI est authentifié : `gh auth status`

### Erreur : "Connection refused" lors des tests

Assurez-vous que CortexDB est en cours d'exécution :

```bash
./scripts/run_cortexdb.sh
```

### Erreur : "Module not found" (Python)

Vérifiez que le SDK est installé :

```bash
pip list | grep cortexdb
```

Si absent, réinstallez :

```bash
pip install ./sdk-dist/python/*.whl
```

### Erreur : "Cannot find module" (TypeScript)

Vérifiez que les dépendances sont installées :

```bash
cd sdk-tests/ts
npm install ../../sdk-dist/ts/*.tgz
```

## Structure des fichiers

```
cortexdb-v3-playground/
├── scripts/
│   ├── download_sdk_python.sh    # Télécharge le SDK Python
│   └── download_sdk_ts.sh        # Télécharge le SDK TypeScript
├── sdk-dist/                      # Non versionné (dans .gitignore)
│   ├── python/                    # Wheels Python téléchargés
│   └── ts/                        # Tarballs TypeScript téléchargés
├── sdk-tests/
│   ├── python/
│   │   ├── smoke.py              # Tests smoke Python
│   │   ├── requirements.txt      # Dépendances (minimal)
│   │   └── README.md             # Guide Python
│   └── ts/
│       ├── smoke.mjs             # Tests smoke TypeScript
│       ├── package.json          # Configuration npm
│       └── README.md             # Guide TypeScript
└── docs/
    └── SDK_TESTING.md            # Ce document
```

## Notes importantes

- Les SDKs sont téléchargés dans `sdk-dist/` qui n'est **pas versionné** (dans `.gitignore`)
- Les tests utilisent des clés avec préfixes uniques (`sdk:py:smoke:<id>`, `sdk:ts:smoke:<id>`) pour éviter les conflits
- Les tests sont **idempotents** : ils nettoient après eux-mêmes
- Pour les releases **publiques**, `curl` peut être utilisé en fallback (mais nécessite de connaître les noms exacts des fichiers)

## Workflow complet

```bash
# 1. Lancer CortexDB
./scripts/run_cortexdb.sh

# 2. Télécharger les SDKs (dans un autre terminal)
gh auth login
CORTEXDB_OWNER=modh93 CORTEXDB_REPO=cortexdb CORTEXDB_SDK_TAG=v3.4.0-sdk1 ./scripts/download_sdk_python.sh
CORTEXDB_OWNER=modh93 CORTEXDB_REPO=cortexdb CORTEXDB_SDK_TAG=v3.4.0-sdk1 ./scripts/download_sdk_ts.sh

# 3. Tester Python
python3 -m venv .venv
source .venv/bin/activate
pip install ./sdk-dist/python/*.whl
python sdk-tests/python/smoke.py

# 4. Tester TypeScript
cd sdk-tests/ts
npm install ../../sdk-dist/ts/*.tgz
npm run smoke
```

