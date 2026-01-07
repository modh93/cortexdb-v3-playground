# Validation SDK - Points Critiques Vérifiés

## ✅ Corrections Effectuées

### 1. Nom du module/package

**Python :** ✅ Correct
- Import : `from cortexdb import CortexDBClient`
- Module réel : `cortexdb` (défini dans `pyproject.toml`)

**TypeScript :** ✅ Corrigé
- Import avant : `import { CortexDBClient } from 'cortexdb-sdk';` ❌
- Import après : `import { CortexDBClient } from 'cortexdb';` ✅
- Package réel : `cortexdb` (défini dans `package.json`)

### 2. Patterns de téléchargement

**Python SDK :**
- Pattern wheel : `cortexdb-sdk-python-*.whl` ✅
- Pattern checksum : `cortexdb-sdk-python-*.whl.sha256` ✅

**TypeScript SDK :**
- Pattern tarball : `cortexdb-sdk-ts-*.tgz` ✅
- Pattern checksum : `cortexdb-sdk-ts-*.tgz.sha256` ✅

### 3. Encodage (géré automatiquement par les SDKs)

**Clés dans les URLs :**
- Base64 + URL encoding (géré par `quote()` en Python, `encodeBase64UrlSafe()` en TS) ✅

**Clés/Valeurs dans les JSON bodies :**
- Base64 brut uniquement (pas d'URL encoding) ✅
- Géré automatiquement par les SDKs ✅

### 4. Nettoyage et collisions

**Python :**
- Clés namespacées : `sdk:py:smoke:{TEST_ID}`, `sdk:py:scan:{TEST_ID}`, `sdk:py:tx:{TEST_ID}` ✅
- TEST_ID généré avec `uuid.uuid4()[:8]` ✅
- Nettoyage garanti à la fin de chaque test ✅

**TypeScript :**
- Clés namespacées : `sdk:ts:smoke:{TEST_ID}`, `sdk:ts:scan:{TEST_ID}`, `sdk:ts:tx:{TEST_ID}` ✅
- TEST_ID généré avec `randomUUID().substring(0, 8)` ✅
- Nettoyage garanti à la fin de chaque test ✅

## 📋 Checklist de Validation

### 1. Vérifier les assets de release

```bash
# Dans le repo CortexDB source
gh release view v3.4.0-sdk1 --repo modh93/cortexdb
```

**Assets attendus :**
- `cortexdb-sdk-python-<version>.whl`
- `cortexdb-sdk-python-<version>.whl.sha256`
- `cortexdb-sdk-ts-<version>.tgz`
- `cortexdb-sdk-ts-<version>.tgz.sha256`

### 2. Tester le téléchargement

```bash
# Python
CORTEXDB_OWNER=modh93 \
CORTEXDB_REPO=cortexdb \
CORTEXDB_SDK_TAG=v3.4.0-sdk1 \
./scripts/download_sdk_python.sh

# TypeScript
CORTEXDB_OWNER=modh93 \
CORTEXDB_REPO=cortexdb \
CORTEXDB_SDK_TAG=v3.4.0-sdk1 \
./scripts/download_sdk_ts.sh
```

**Vérifications :**
- [ ] Fichiers déposés dans `sdk-dist/python/` et `sdk-dist/ts/`
- [ ] Checksum OK (pas d'erreur de vérification)

### 3. Test Python - Import

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install ./sdk-dist/python/*.whl
python -c "from cortexdb import CortexDBClient; print('import ok')"
python sdk-tests/python/smoke.py
```

**Vérifications :**
- [ ] Import réussi : `from cortexdb import CortexDBClient`
- [ ] Tests smoke passent (health, kv, prefix, tx)

### 4. Test TypeScript - Import

```bash
cd sdk-tests/ts
npm install ../../sdk-dist/ts/*.tgz
node -e "import('cortexdb').then(m => console.log('import ok'))"
npm run smoke
```

**Vérifications :**
- [ ] Import réussi : `import { CortexDBClient } from 'cortexdb'`
- [ ] Tests smoke passent (health, kv, prefix, tx)

## 🔍 Points Critiques Vérifiés

### Piège 1 : Nom exact du module/package ✅

**Python :**
```python
from cortexdb import CortexDBClient  # ✅ Correct
```

**TypeScript :**
```javascript
import { CortexDBClient } from 'cortexdb';  // ✅ Corrigé (était 'cortexdb-sdk')
```

### Piège 2 : Encodage ✅

Les SDKs gèrent automatiquement :
- **URLs** : Clés en base64 + URL encoding (`quote()` / `encodeBase64UrlSafe()`)
- **JSON bodies** : Clés/valeurs en base64 brut (pas d'URL encoding)

Les tests smoke utilisent directement les méthodes du SDK, donc l'encodage est correct.

### Piège 3 : Nettoyage / Collisions ✅

**Stratégie :**
- Clés namespacées avec UUID : `sdk:py:smoke:{TEST_ID}`
- TEST_ID unique à chaque exécution
- Nettoyage garanti dans chaque test (delete après utilisation)

**Exemples de clés générées :**
- Python : `sdk:py:smoke:a1b2c3d4`, `sdk:py:scan:a1b2c3d4:1`, etc.
- TypeScript : `sdk:ts:smoke:e5f6g7h8`, `sdk:ts:scan:e5f6g7h8:1`, etc.

## 🚨 Erreurs Potentielles à Surveiller

### Si les assets n'existent pas

**Symptôme :** `Error: Failed to download release assets`

**Solution :**
1. Vérifier que le tag existe : `gh release view v3.4.0-sdk1 --repo modh93/cortexdb`
2. Vérifier les noms exacts des assets (respecter les patterns)
3. Vérifier l'authentification : `gh auth status`

### Si l'import échoue

**Python :**
- Vérifier que le wheel est installé : `pip list | grep cortexdb`
- Vérifier le nom du module dans `pyproject.toml` du SDK source

**TypeScript :**
- Vérifier que le package est installé : `npm list cortexdb`
- Vérifier le nom du package dans `package.json` du SDK source

### Si les tests échouent

**Connection refused :**
- Vérifier que CortexDB est en cours d'exécution : `./scripts/run_cortexdb.sh`

**Clés non trouvées :**
- Vérifier que les clés sont bien namespacées avec UUID
- Vérifier que le nettoyage s'est bien exécuté

## 📝 Notes Finales

- Les patterns de téléchargement sont flexibles (`*.whl`, `*.tgz`) pour supporter différentes versions
- Les tests sont idempotents grâce aux UUID et au nettoyage
- Les SDKs gèrent automatiquement tous les encodages nécessaires
- Les noms de modules/packages correspondent aux définitions dans les repos sources

