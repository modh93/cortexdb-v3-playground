# 07 — SDK Python

## Objectif

Utiliser le **SDK Python** de CortexDB pour interagir avec la base de données via une API Python native, sans gérer manuellement les encodages Base64 et les requêtes HTTP.

Ce tutoriel couvre :
- Installation du SDK Python depuis GitHub Releases
- Utilisation des méthodes de base (health, put, get, delete)
- Scans par préfixe
- Transactions

---

## Prérequis

- Avoir suivi `01 — Run CortexDB Locally`
- CortexDB en cours d'exécution sur `http://127.0.0.1:8080`
- Python 3.8+ installé
- GitHub CLI installé et authentifié (pour releases privées)

---

## Étape 1 : Télécharger le SDK Python

Le SDK Python est distribué via GitHub Releases sous forme de wheel (`.whl`).

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
./scripts/download_sdk_python.sh
```

Le script télécharge :
- `cortexdb-sdk-python-<version>.whl` dans `./sdk-dist/python/`
- Vérifie l'intégrité avec SHA256

**Résultat attendu :**

```
Downloading CortexDB Python SDK
  Owner: modh93
  Repo: cortexdb
  Tag: v3.4.0-sdk1

Using GitHub CLI (gh)
✓ Wheel downloaded: cortexdb-sdk-python-3.4.0.whl
✓ Checksum verified
✓ CortexDB Python SDK ready in: ./sdk-dist/python
```

---

## Étape 2 : Installer le SDK

### 2.1. Créer un environnement virtuel Python

```bash
python3 -m venv .venv
source .venv/bin/activate
```

### 2.2. Installer le SDK depuis le wheel

```bash
pip install ./sdk-dist/python/*.whl
```

**Vérification :**

```bash
python -c "from cortexdb import CortexDBClient; print('SDK installed successfully')"
```

---

## Étape 3 : Utiliser le SDK

### 3.1. Script de base

Créez un fichier `example_python.py` :

```python
#!/usr/bin/env python3
from cortexdb import CortexDBClient

# Créer un client
client = CortexDBClient(base_url="http://127.0.0.1:8080")

# Health check
health = client.health()
print(f"Status: {health['status']}")
print(f"Version: {health['version']}")

# Put
client.put("user:1", "Alice")
print("✓ Put: user:1 = Alice")

# Get
value = client.get("user:1")
print(f"✓ Get: user:1 = {value.decode('utf-8')}")

# Delete
client.delete("user:1")
print("✓ Delete: user:1")
```

### 3.2. Exécuter

```bash
python example_python.py
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

```python
from cortexdb import CortexDBClient

client = CortexDBClient(base_url="http://127.0.0.1:8080")

# Insérer plusieurs clés avec préfixe commun
for i in range(1, 4):
    key = f"product:{i}"
    value = f"Product {i}"
    client.put(key, value.encode("utf-8"))
    print(f"✓ Inserted: {key} = {value}")

# Scanner par préfixe
results = client.prefix_scan("product:")
print(f"\n✓ Found {len(results)} keys with prefix 'product:'")

for key, value in results:
    print(f"  - {key.decode('utf-8')} = {value.decode('utf-8')}")

# Nettoyage
for i in range(1, 4):
    client.delete(f"product:{i}")
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

```python
from cortexdb import CortexDBClient

client = CortexDBClient(base_url="http://127.0.0.1:8080")

# Démarrer une transaction
tx = client.begin_tx()
print(f"✓ Transaction started: {tx._tx_id}")

# Opérations dans la transaction
tx.put("account:balance", "1000")
print("✓ Put in transaction: account:balance = 1000")

value = tx.get("account:balance")
print(f"✓ Get in transaction: {value.decode('utf-8')}")

# La clé n'est pas visible en dehors de la transaction
try:
    client.get("account:balance")
    print("✗ Key should not be visible outside transaction")
except Exception as e:
    print(f"✓ Key not visible outside transaction (expected: {type(e).__name__})")

# Commit
tx.commit()
print("✓ Transaction committed")

# Maintenant la clé est visible
value = client.get("account:balance")
print(f"✓ Key visible after commit: {value.decode('utf-8')}")

# Nettoyage
client.delete("account:balance")
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

```python
from cortexdb import CortexDBClient, NotFoundError, BadRequestError

client = CortexDBClient(base_url="http://127.0.0.1:8080")

# NotFoundError : clé inexistante
try:
    client.get("nonexistent:key")
except NotFoundError as e:
    print(f"✓ NotFoundError: {e}")

# BadRequestError : clé invalide (exemple)
try:
    # Le SDK gère automatiquement l'encodage, mais des erreurs peuvent survenir
    pass
except BadRequestError as e:
    print(f"✓ BadRequestError: {e}")
```

---

## Commandes de référence

### Télécharger le SDK

```bash
CORTEXDB_OWNER=modh93 \
CORTEXDB_REPO=cortexdb \
CORTEXDB_SDK_TAG=v3.4.0-sdk1 \
./scripts/download_sdk_python.sh
```

### Installer

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install ./sdk-dist/python/*.whl
```

### Exécuter les tests smoke

```bash
cd sdk-tests/python
python smoke.py
```

---

## Erreurs courantes

### "ModuleNotFoundError: No module named 'cortexdb'"

**Cause :** Le SDK n'est pas installé ou l'environnement virtuel n'est pas activé.

**Solution :**

```bash
source .venv/bin/activate
pip install ./sdk-dist/python/*.whl
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
rm -rf sdk-dist/python/*
./scripts/download_sdk_python.sh
```

---

## Résumé

- Le SDK Python simplifie l'utilisation de CortexDB en gérant automatiquement les encodages
- Installation via wheel depuis GitHub Releases
- API Python native : `client.put()`, `client.get()`, `client.delete()`, `client.prefix_scan()`, `client.begin_tx()`
- Gestion d'erreurs avec exceptions spécifiques (`NotFoundError`, `BadRequestError`)

---

**Prochain tutoriel :** `08 — SDK TypeScript`

