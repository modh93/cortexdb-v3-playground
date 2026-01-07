# EX01 — KV Basics : créer, lire, supprimer

## Objectif
Mettre en pratique les opérations KV de base en conditions réelles, en utilisant :
- `PUT /kv/{key}`
- `GET /kv/{key}`
- `DELETE /kv/{key}`
- et `/stats` pour vérifier l’impact

À la fin de l’exercice, vous devez être capable de :
- stocker plusieurs clés cohérentes
- vérifier et décoder les valeurs Base64
- supprimer proprement une clé
- diagnostiquer une erreur d’encodage

---

## Prérequis
- CortexDB lancé sur `http://127.0.0.1:8080`
- Avoir lu les tutoriels `03` et `06`
- Avoir accès à `curl` (ou au playground)

---

## Règles
- Vous travaillez avec des **clés texte** (lisibles) mais vous envoyez :
  - les clés en Base64 + URL percent-encoding (dans l’URL)
  - les valeurs en Base64 (dans le JSON)
- Pour valider vos résultats, vous devez :
  - faire au moins un `GET` après chaque `PUT`
  - décoder au moins une valeur Base64
  - supprimer une clé et vérifier qu’elle n’existe plus

---

## Données à utiliser

Créez 3 paires clé/valeur :

1) `demo:user:1` → `Alice`
2) `demo:user:2` → `Bob`
3) `demo:user:3` → `Charlie`

---

## Étape 0 — Préparer les encodages (donnés)

Clés Base64 (à utiliser dans l’URL) :

- `demo:user:1` → `ZGVtbzp1c2VyOjE=`
- `demo:user:2` → `ZGVtbzp1c2VyOjI=`
- `demo:user:3` → `ZGVtbzp1c2VyOjM=`

Valeurs Base64 (à utiliser dans le body JSON) :

- `Alice` → `QWxpY2U=`
- `Bob` → `Qm9i`
- `Charlie` → `Q2hhcmxpZQ==`

⚠️ Ici, les clés Base64 ne nécessitent pas de percent-encoding additionnel.
(La règle générale reste : Base64 puis percent-encoding.)

---

## Étape 1 — Vérifier l’état initial (stats)

### Commande
```bash
curl http://127.0.0.1:8080/stats
````

### Résultat attendu

* Le serveur répond en JSON
* Le nombre de clés peut être `0` si vous êtes sur une base vide
* Notez le compteur de clés si présent

---

## Étape 2 — Insérer les 3 clés (PUT)

### Commandes

```bash
curl -X PUT http://127.0.0.1:8080/kv/ZGVtbzp1c2VyOjE%3D \
  -H "Content-Type: application/json" \
  -d '{"value":"QWxpY2U="}'

curl -X PUT http://127.0.0.1:8080/kv/ZGVtbzp1c2VyOjI%3D \
  -H "Content-Type: application/json" \
  -d '{"value":"Qm9i"}'

curl -X PUT http://127.0.0.1:8080/kv/ZGVtbzp1c2VyOjM%3D \
  -H "Content-Type: application/json" \
  -d '{"value":"Q2hhcmxpZQ=="}'
```

### Résultat attendu

Pour chaque requête :

```json
{ "status": "ok" }
```

---

## Étape 3 — Vérifier les écritures (GET)

### Commandes

```bash
curl http://127.0.0.1:8080/kv/ZGVtbzp1c2VyOjE%3D
curl http://127.0.0.1:8080/kv/ZGVtbzp1c2VyOjI%3D
curl http://127.0.0.1:8080/kv/ZGVtbzp1c2VyOjM%3D
```

### Résultat attendu

Vous devez recevoir :

* `QWxpY2U=`
* `Qm9i`
* `Q2hhcmxpZQ==`

Puis vérifier au moins un décodage :

* `Qm9i` → `Bob`

---

## Étape 4 — Supprimer une clé (DELETE)

Supprimez `demo:user:2`.

### Commande

```bash
curl -X DELETE http://127.0.0.1:8080/kv/ZGVtbzp1c2VyOjI%3D
```

### Résultat attendu

```json
{ "status": "ok" }
```

---

## Étape 5 — Vérifier la suppression

### Commande

```bash
curl http://127.0.0.1:8080/kv/ZGVtbzp1c2VyOjI%3D
```

### Résultat attendu (exemple)

```json
{
  "error_code": "KEY_NOT_FOUND",
  "message": "key not found"
}
```

---

## Étape 6 — Vérifier l’impact (stats)

### Commande

```bash
curl http://127.0.0.1:8080/stats
```

### Résultat attendu

* le compteur de clés doit refléter la suppression (si exposé)
* sinon, vous devez au minimum constater :

  * `demo:user:1` existe
  * `demo:user:3` existe
  * `demo:user:2` n’existe plus

---

## Défi bonus (debug encodage)

### Consigne

Essayez de faire un `GET` avec une clé volontairement mal encodée :

* retirez le `%3D` final (le `=`) et observez le résultat

Exemple :

```bash
curl http://127.0.0.1:8080/kv/ZGVtbzp1c2VyOjE
```

### Résultat attendu

* soit une erreur d’encodage (`INVALID_BASE64` ou `BAD_REQUEST`)
* soit une clé introuvable (`KEY_NOT_FOUND`)

Dans tous les cas, l’objectif est de constater que :

> l’encodage fait partie du contrat.

---

## Points à retenir

* `PUT` puis `GET` est votre test minimal de cohérence
* les valeurs renvoyées sont Base64 (à décoder côté client)
* `DELETE` est définitif
* la plupart des “bugs” proviennent d’erreurs d’encodage

---

## Suite

➡️ Passez à l’exercice suivant : **EX02 — Scan (range/prefix)**.
