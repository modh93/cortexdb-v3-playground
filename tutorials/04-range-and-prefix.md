# 04 — Range & Prefix : parcourir les données

## Objectif
Apprendre à **parcourir plusieurs clés** stockées dans CortexDB
à l’aide des requêtes :
- `range` : parcours entre deux bornes
- `prefix` : parcours par préfixe commun

Ces opérations sont essentielles pour :
- lister des ensembles de données
- implémenter des index simples
- effectuer des lectures groupées efficaces

---

## Prérequis

- Avoir suivi `03 — KV : PUT / GET / DELETE`
- CortexDB en cours d’exécution sur :
```

[http://127.0.0.1:8080](http://127.0.0.1:8080)

````

---

## Jeu de données d’exemple

Nous allons créer les clés suivantes :

| Clé (texte) | Valeur (texte) |
|------------|----------------|
| user:1 | Alice |
| user:2 | Bob |
| user:3 | Charlie |
| order:1 | Order-A |

---

## Étape 1 — Insérer des données

### Commandes

```bash
curl -X PUT http://127.0.0.1:8080/kv/dXNlcjox \
-H "Content-Type: application/json" \
-d '{"value":"QWxpY2U="}'

curl -X PUT http://127.0.0.1:8080/kv/dXNlcjoy \
-H "Content-Type: application/json" \
-d '{"value":"Qm9i"}'

curl -X PUT http://127.0.0.1:8080/kv/dXNlcjoz \
-H "Content-Type: application/json" \
-d '{"value":"Q2hhcmxpZQ=="}'

curl -X PUT http://127.0.0.1:8080/kv/b3JkZXI6MQ== \
-H "Content-Type: application/json" \
-d '{"value":"T3JkZXItQQ=="}'
````

---

## Étape 2 — Requête Range

### Description

La requête `range` retourne toutes les paires clé/valeur
dont la clé est comprise **entre deux bornes** (ordre lexicographique).

---

### Commande

```bash
curl -X POST http://127.0.0.1:8080/range \
  -H "Content-Type: application/json" \
  -d '{
    "start": "dXNlcjox",
    "end": "dXNlcjoz",
    "limit": 10
  }'
```

---

### Résultat attendu (exemple)

```json
{
  "items": [
    { "key": "dXNlcjox", "value": "QWxpY2U=" },
    { "key": "dXNlcjoy", "value": "Qm9i" },
    { "key": "dXNlcjoz", "value": "Q2hhcmxpZQ==" }
  ]
}
```

Décodage :

* `user:1 → Alice`
* `user:2 → Bob`
* `user:3 → Charlie`

---

## Étape 3 — Requête Prefix

### Description

La requête `prefix` retourne toutes les clés
commençant par un **préfixe commun**.

---

### Commande

```bash
curl -X POST http://127.0.0.1:8080/prefix \
  -H "Content-Type: application/json" \
  -d '{
    "prefix": "dXNlcjo",
    "limit": 10
  }'
```

---

### Résultat attendu (exemple)

```json
{
  "items": [
    { "key": "dXNlcjox", "value": "QWxpY2U=" },
    { "key": "dXNlcjoy", "value": "Qm9i" },
    { "key": "dXNlcjoz", "value": "Q2hhcmxpZQ==" }
  ]
}
```

---

## Utilisation via le playground

Dans le playground :

1. ouvrez la section **Range**
2. saisissez les bornes ou le préfixe en texte clair
3. cliquez sur **Run**
4. observez la liste des résultats dans la console

Le playground affiche :

* les clés encodées
* les valeurs encodées
* les réponses JSON brutes

---

## Erreurs courantes

### ❌ Bornes inversées (range)

Symptôme :

* résultat vide

Cause :

* `start` > `end` (ordre lexicographique)

Solution :

* vérifier l’ordre des clés encodées

---

### ❌ Préfixe mal encodé

Symptôme :

* aucun résultat

Cause :

* oubli du Base64
* erreur de percent-encoding

Solution :

* utiliser le playground
* vérifier le champ `prefix`

---

## Points à retenir

* `range` permet un parcours ordonné
* `prefix` est idéal pour regrouper des clés logiques
* les clés sont comparées **après encodage**
* ces requêtes sont en lecture seule

---

## Prochaine étape

➡️ Passez au tutoriel suivant :
**05 — Transactions**
