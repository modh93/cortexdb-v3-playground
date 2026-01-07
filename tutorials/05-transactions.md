# 05 — Transactions

## Objectif
Comprendre et utiliser les **transactions** dans CortexDB afin de :
- regrouper plusieurs opérations KV
- garantir la cohérence des écritures
- valider ou annuler un ensemble d’actions de manière atomique

À la fin de ce tutoriel, vous saurez :
- démarrer une transaction
- effectuer des opérations KV dans une transaction
- valider (commit) ou annuler (abort) une transaction

---

## Prérequis

- Avoir suivi `04 — Range & Prefix`
- CortexDB en cours d’exécution sur :
```

[http://127.0.0.1:8080](http://127.0.0.1:8080)

````

---

## Principe des transactions dans CortexDB

Une transaction suit toujours le même cycle :

1. **Begin** → création d’un contexte transactionnel
2. **Operations** → `put` / `get` dans la transaction
3. **Commit** ou **Abort**

Tant qu’une transaction n’est pas validée :
- les écritures ne sont **pas visibles** hors transaction
- elles peuvent être **annulées**

---

## Étape 1 — Démarrer une transaction

### Commande

```bash
curl -X POST http://127.0.0.1:8080/tx/begin
````

### Résultat attendu (exemple)

```json
{
  "tx_id": "tx-123456"
}
```

💡 Notez soigneusement la valeur de `tx_id`, elle sera utilisée dans toutes les étapes suivantes.

---

## Étape 2 — Écrire une valeur dans la transaction

### Exemple de données

* clé (texte) : `user:10`
* valeur (texte) : `David`

Encodages :

* clé base64 : `dXNlcjoxMA==`
* valeur base64 : `RGF2aWQ=`

---

### Commande

```bash
curl -X POST http://127.0.0.1:8080/tx/tx-123456/put \
  -H "Content-Type: application/json" \
  -d '{
    "key": "dXNlcjoxMA==",
    "value": "RGF2aWQ="
  }'
```

### Résultat attendu

```json
{
  "status": "ok"
}
```

---

## Étape 3 — Lire une valeur dans la transaction

### Commande

```bash
curl http://127.0.0.1:8080/tx/tx-123456/get/dXNlcjoxMA==
```

### Résultat attendu

```json
{
  "value": "RGF2aWQ="
}
```

Décodage :

```text
RGF2aWQ= → David
```

💡 Cette valeur **n’est pas encore visible hors transaction**.

---

## Étape 4 — Vérifier l’invisibilité hors transaction

### Commande

```bash
curl http://127.0.0.1:8080/kv/dXNlcjoxMA==
```

### Résultat attendu (exemple)

```json
{
  "error_code": "KEY_NOT_FOUND",
  "message": "key not found"
}
```

---

## Étape 5 — Valider la transaction (commit)

### Commande

```bash
curl -X POST http://127.0.0.1:8080/tx/tx-123456/commit
```

### Résultat attendu

```json
{
  "status": "ok"
}
```

---

## Étape 6 — Lire la valeur après commit

### Commande

```bash
curl http://127.0.0.1:8080/kv/dXNlcjoxMA==
```

### Résultat attendu

```json
{
  "value": "RGF2aWQ="
}
```

---

## Étape 7 — Annuler une transaction (abort)

### Cas d’usage

Si vous souhaitez **annuler toutes les écritures** effectuées dans une transaction.

### Commandes

```bash
curl -X POST http://127.0.0.1:8080/tx/begin
```

```json
{
  "tx_id": "tx-789000"
}
```

```bash
curl -X POST http://127.0.0.1:8080/tx/tx-789000/abort
```

### Résultat attendu

```json
{
  "status": "aborted"
}
```

Aucune donnée n’est persistée.

---

## Utilisation via le playground

Dans le playground :

1. cliquez sur **Begin Transaction**
2. copiez le `tx_id`
3. utilisez **Tx Put** / **Tx Get**
4. cliquez sur **Commit** ou **Abort**
5. observez la visibilité des données

La console montre :

* les requêtes transactionnelles
* les réponses associées
* l’ordre exact des appels HTTP

---

## Erreurs courantes

### ❌ Transaction inconnue

Erreur :

```json
{
  "error_code": "TX_NOT_FOUND",
  "message": "transaction not found"
}
```

Cause :

* `tx_id` incorrect
* transaction déjà commit/abort

---

### ❌ Commit en double

Cause :

* tentative de commit après un commit ou abort

Solution :

* créer une nouvelle transaction

---

## Points à retenir

* les transactions garantissent la cohérence
* les écritures sont isolées jusqu’au commit
* `abort` annule toutes les opérations
* chaque transaction est identifiée par un `tx_id`

---

## Prochaine étape

➡️ Passez au tutoriel suivant :
**06 — Erreurs courantes & encodage**
