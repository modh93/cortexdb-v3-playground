# 06 — Erreurs courantes & encodage

## Objectif
Identifier et comprendre les **erreurs les plus fréquentes** rencontrées
lors de l’utilisation de CortexDB V3, et maîtriser définitivement
les **règles d’encodage** (clé / valeur).

À la fin de ce tutoriel, vous saurez :
- reconnaître les erreurs API les plus courantes
- interpréter le modèle d’erreur standard
- corriger rapidement un problème d’encodage
- savoir quand utiliser le playground plutôt que `curl`

---

## Rappel — modèle d’erreur standard

Lorsqu’une requête échoue, CortexDB renvoie un JSON structuré :

```json
{
  "error_code": "ERROR_CODE",
  "message": "human readable message",
  "details": "optional"
}
````

### Champs

* `error_code` : code stable, exploitable par un programme
* `message` : message explicatif
* `details` : information optionnelle (debug)

---

## Erreur 1 — Clé non trouvée (`KEY_NOT_FOUND`)

### Symptôme

```json
{
  "error_code": "KEY_NOT_FOUND",
  "message": "key not found"
}
```

### Causes possibles

* la clé n’existe pas
* la clé est mal encodée
* la clé a été supprimée

### Vérifications

* la clé est-elle bien encodée en Base64 ?
* la clé encodée est-elle identique à celle utilisée lors du `PUT` ?

---

## Erreur 2 — Encodage Base64 invalide

### Symptôme

```json
{
  "error_code": "INVALID_BASE64",
  "message": "invalid base64 encoding"
}
```

### Cause

* la valeur envoyée n’est pas un Base64 valide
* caractères manquants (`=`), chaîne tronquée, etc.

### Règle à retenir

* **toutes les valeurs** doivent être envoyées en Base64
* aucun texte brut n’est accepté dans les bodies JSON

---

## Erreur 3 — Oubli du percent-encoding dans l’URL

### Symptôme

* erreur 400
* clé introuvable alors qu’elle existe

### Exemple problématique

Clé texte :

```
user/a
```

Encodage Base64 :

```
dXNlci9h
```

Cette valeur contient `/` → **doit être percent-encodée** :

```
dXNlci9h  →  dXNlci9h%2F
```

### Solution

* toujours appliquer :

  1. Base64
  2. URL percent-encoding

---

## Erreur 4 — Transaction inconnue (`TX_NOT_FOUND`)

### Symptôme

```json
{
  "error_code": "TX_NOT_FOUND",
  "message": "transaction not found"
}
```

### Causes possibles

* `tx_id` incorrect
* transaction déjà commit ou abort
* serveur redémarré

### Solution

* démarrer une nouvelle transaction
* vérifier que le serveur n’a pas été redémarré

---

## Erreur 5 — Mauvaise méthode HTTP

### Symptôme

```json
{
  "error_code": "METHOD_NOT_ALLOWED",
  "message": "method not allowed"
}
```

### Cause

* `GET` au lieu de `POST`
* `POST` au lieu de `PUT`, etc.

### Solution

* vérifier la méthode HTTP
* se référer à la spécification OpenAPI

---

## Erreur 6 — Serveur non disponible

### Symptôme

```text
Connection refused
```

### Causes possibles

* CortexDB n’est pas lancé
* mauvais port
* serveur arrêté

### Solution

```bash
./scripts/run_cortexdb.sh
```

Puis vérifier :

```bash
curl http://127.0.0.1:8080/health
```

---

## Quand utiliser le playground

Utilisez le playground si :

* vous doutez de l’encodage
* vous testez une requête pour la première fois
* vous voulez visualiser les requêtes HTTP réelles

Le playground :

* encode automatiquement
* affiche les données en clair et encodées
* montre les requêtes et réponses brutes

---

## Checklist de debug rapide

Avant de conclure à un bug :

* [ ] le serveur est lancé
* [ ] l’URL est correcte (`127.0.0.1`)
* [ ] la clé est Base64 + URL-encodée
* [ ] la valeur est Base64
* [ ] la méthode HTTP est correcte
* [ ] la transaction est valide (si utilisée)

---

## Points à retenir

* la majorité des erreurs viennent de l’encodage
* le modèle d’erreur est stable et explicite
* le playground est un outil de debug, pas juste une démo
* CortexDB privilégie la clarté contractuelle à la magie implicite

---

## Suite

Vous avez terminé les tutoriels principaux.

➡️ Vous pouvez maintenant passer aux **exercices pratiques**
dans `tutorials/exercises/`.
