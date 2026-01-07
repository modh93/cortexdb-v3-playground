# EX02 — Scan : range & prefix

## Objectif
Mettre en pratique les **lectures groupées** avec CortexDB en utilisant :
- `POST /range`
- `POST /prefix`

À la fin de l’exercice, vous devez être capable de :
- structurer des clés pour faciliter les scans
- récupérer un sous-ensemble de données par bornes (range)
- lister des données par préfixe (prefix)
- comprendre l’impact de l’ordre lexicographique

---

## Prérequis
- CortexDB lancé sur `http://127.0.0.1:8080`
- Avoir validé **EX01 — KV Basics**
- Avoir des clés présentes en base (sinon, suivez l’étape 1)

---

## Jeu de données à utiliser

Nous allons travailler avec les clés suivantes :

| Clé (texte)     | Valeur (texte) |
|-----------------|----------------|
| scan:user:1     | Alice          |
| scan:user:2     | Bob            |
| scan:user:3     | Charlie        |
| scan:order:1   | Order-A        |
| scan:order:2   | Order-B        |

---

## Étape 0 — Encodages fournis

### Clés Base64
- `scan:user:1` → `c2Nhbjp1c2VyOjE=`
- `scan:user:2` → `c2Nhbjp1c2VyOjI=`
- `scan:user:3` → `c2Nhbjp1c2VyOjM=`
- `scan:order:1` → `c2NhbjpvcmRlcjox`
- `scan:order:2` → `c2NhbjpvcmRlcjoy`

### Valeurs Base64
- `Alice` → `QWxpY2U=`
- `Bob` → `Qm9i`
- `Charlie` → `Q2hhcmxpZQ==`
- `Order-A` → `T3JkZXItQQ==`
- `Order-B` → `T3JkZXItQg==`

⚠️ Certaines clés Base64 se terminent par `=` → **URL percent-encoding requis** (`=` → `%3D`).

---

## Étape 1 — Insérer les données

### Commandes
```bash
curl -X PUT http://127.0.0.1:8080/kv/c2Nhbjp1c2VyOjE%3D \
  -H "Content-Type: application/json" \
  -d '{"value":"QWxpY2U="}'

curl -X PUT http://127.0.0.1:8080/kv/c2Nhbjp1c2VyOjI%3D \
  -H "Content-Type: application/json" \
  -d '{"value":"Qm9i"}'

curl -X PUT http://127.0.0.1:8080/kv/c2Nhbjp1c2VyOjM%3D \
  -H "Content-Type: application/json" \
  -d '{"value":"Q2hhcmxpZQ=="}'

curl -X PUT http://127.0.0.1:8080/kv/c2NhbjpvcmRlcjox \
  -H "Content-Type: application/json" \
  -d '{"value":"T3JkZXItQQ=="}'

curl -X PUT http://127.0.0.1:8080/kv/c2NhbjpvcmRlcjoy \
  -H "Content-Type: application/json" \
  -d '{"value":"T3JkZXItQg=="}'
````

---

## Étape 2 — Scan par range (users uniquement)

### Objectif

Récupérer les clés `scan:user:*` via des bornes.

### Commande

```bash
curl -X POST http://127.0.0.1:8080/range \
  -H "Content-Type: application/json" \
  -d '{
    "start": "c2Nhbjp1c2VyOjE=",
    "end": "c2Nhbjp1c2VyOjM=",
    "limit": 10
  }'
```

### Résultat attendu (exemple)

```json
{
  "items": [
    { "key": "c2Nhbjp1c2VyOjE=", "value": "QWxpY2U=" },
    { "key": "c2Nhbjp1c2VyOjI=", "value": "Qm9i" },
    { "key": "c2Nhbjp1c2VyOjM=", "value": "Q2hhcmxpZQ==" }
  ]
}
```

---

## Étape 3 — Scan par prefix (users)

### Objectif

Lister toutes les clés dont le préfixe est `scan:user:`.

### Préfixe Base64

* `scan:user:` → `c2Nhbjp1c2VyOg==`

### Commande

```bash
curl -X POST http://127.0.0.1:8080/prefix \
  -H "Content-Type: application/json" \
  -d '{
    "prefix": "c2Nhbjp1c2VyOg==",
    "limit": 10
  }'
```

### Résultat attendu

Identique à l’étape précédente (les 3 users).

---

## Étape 4 — Scan par prefix (orders)

### Préfixe Base64

* `scan:order:` → `c2NhbjpvcmRlcjo=`

### Commande

```bash
curl -X POST http://127.0.0.1:8080/prefix \
  -H "Content-Type: application/json" \
  -d '{
    "prefix": "c2NhbjpvcmRlcjo=",
    "limit": 10
  }'
```

### Résultat attendu

```json
{
  "items": [
    { "key": "c2NhbjpvcmRlcjox", "value": "T3JkZXItQQ==" },
    { "key": "c2NhbjpvcmRlcjoy", "value": "T3JkZXItQg==" }
  ]
}
```

---

## Étape 5 — Tester la limite

### Commande

```bash
curl -X POST http://127.0.0.1:8080/prefix \
  -H "Content-Type: application/json" \
  -d '{
    "prefix": "c2Nhbjp1c2VyOg==",
    "limit": 2
  }'
```

### Résultat attendu

* seulement **2 éléments** retournés
* l’ordre est lexicographique

---

## Points à observer

* Les scans respectent l’ordre **des clés encodées**
* Le design des clés est **crucial** pour l’efficacité
* `prefix` est souvent plus simple que `range`
* `limit` protège contre des réponses trop volumineuses

---

## Défi bonus

Essayez un `range` trop large (bornes incluant users + orders) et observez :

* l’ordre des résultats
* le mélange des catégories

---

## Points à retenir

* `range` = bornes explicites
* `prefix` = regroupement logique
* les scans sont **en lecture seule**
* bien nommer les clés simplifie tout

---

## Suite

➡️ Passez à l’exercice suivant : **EX03 — Transactions**.
