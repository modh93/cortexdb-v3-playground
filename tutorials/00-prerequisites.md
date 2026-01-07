# 00 — Prérequis

## Objectif
Vérifier que l’environnement local est prêt pour utiliser CortexDB V3
et le playground **sans accès au code source** et **sans dépendance cloud**.

À la fin de ce tutoriel, vous devez pouvoir :
- lancer CortexDB en local via un binaire
- ouvrir le playground local
- comprendre l’architecture locale (serveur + UI)

---

## Prérequis système

### Système d’exploitation
- Linux x86_64 (recommandé)
- macOS : support ultérieur (non couvert ici)

### Outils requis
- `bash`
- `curl`
- un navigateur web moderne (Firefox, Chrome, Chromium)
- **optionnel mais recommandé** : GitHub CLI (`gh`)

Vérifier les outils :
```bash
bash --version
curl --version
````

---

## Prérequis CortexDB

### Accès au binaire

Vous n’avez **pas besoin** du code source CortexDB.

Le binaire est distribué via **GitHub Releases**.

Deux cas possibles :

#### Cas 1 — Release publique

Aucune authentification requise.

#### Cas 2 — Release privée

Vous devez :

```bash
gh auth login
```

⚠️ Vous devez avoir été ajouté comme collaborateur au dépôt contenant les releases.

---

## Structure attendue du playground

Vous devez être dans le dépôt :

```text
cortexdb-v3-playground/
  playground/
  scripts/
  tutorials/
  docs/
```

Vérifier :

```bash
ls
```

---

## Étape 1 — Télécharger le binaire CortexDB

Depuis la racine du repo playground :

```bash
CORTEXDB_OWNER=modh93 \
CORTEXDB_RELEASE_TAG=v3.4.0-bin1 \
./scripts/download_cortexdb_linux.sh
```

### Résultat attendu

* le binaire est téléchargé dans `./bin/cortexdbd`
* le checksum SHA256 est vérifié
* le script termine sans erreur

Vérifier :

```bash
ls -lh bin/
```

---

## Étape 2 — Lancer CortexDB en local

```bash
./scripts/run_cortexdb.sh
```

### Résultat attendu

* CortexDB démarre sans erreur
* message affiché indiquant :

  ```
  CortexDB running on http://127.0.0.1:8080
  ```

Le serveur est maintenant **local**, **offline**, et **non exposé**.

---

## Étape 3 — Vérifier que l’API répond

Dans un autre terminal :

```bash
curl http://127.0.0.1:8080/health
```

### Résultat attendu

```json
{
  "status": "ok",
  "version": "3.3.0"
}
```

---

## Étape 4 — Lancer le playground

Toujours depuis la racine du repo playground :

```bash
./scripts/run_static_server.sh
```

Puis ouvrir dans le navigateur :

```
http://localhost:8000/playground/index.html
```

### Résultat attendu

* l’interface du playground s’affiche
* le champ `Base URL` contient `http://127.0.0.1:8080`
* le bouton **Health** fonctionne

---

## Architecture locale (à comprendre)

```text
Navigateur (index.html)
        |
        | HTTP (localhost)
        v
CortexDB (127.0.0.1:8080)
```

* aucune donnée ne sort de la machine
* aucun service externe n’est utilisé
* le playground est un simple client local

---

## Points à retenir

* CortexDB V3 est **local-first**
* le playground fonctionne **sans cloud**
* le binaire suffit pour démarrer
* la sécurité repose d’abord sur **l’absence d’exposition réseau**

---

## Prochaine étape

➡️ Passez au tutoriel suivant :
**01 — Run CortexDB locally**
