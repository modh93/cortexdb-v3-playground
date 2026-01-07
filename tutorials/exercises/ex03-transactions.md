# EX03 — Transactions : atomicité et visibilité

## Objectif
Mettre en pratique les **transactions** dans CortexDB pour vérifier :
- l’**isolation** des écritures avant commit
- l’**atomicité** au moment du commit
- l’**annulation** via abort

À la fin de l’exercice, vous devez être capable de :
- enchaîner correctement les appels transactionnels
- prouver qu’une écriture n’est pas visible hors transaction
- valider ou annuler proprement une transaction

---

## Prérequis
- CortexDB lancé sur `http://127.0.0.1:8080`
- Avoir suivi le tutoriel `05 — Transactions`
- Avoir compris les règles d’encodage (tutoriel `06`)

---

## Données à utiliser

Nous allons travailler avec les clés suivantes :

| Clé (texte)      | Valeur (texte) |
|------------------|----------------|
| tx:user:1        | Alice          |
| tx:user:2        | Bob            |

---

## Encodages fournis

### Clés Base64
- `tx:user:1` → `dHg6dXNlcjox`
- `tx:user:2` → `dHg6dXNlcjoy`

### Valeurs Base64
- `Alice` → `QWxpY2U=`
- `Bob` → `Qm9i`

⚠️ Les clés Base64 peuvent nécessiter du percent-encoding si elles contiennent `=`.
Ici, ce n’est pas le cas.

---

## Étape 1 — Démarrer une transaction

### Commande
```bash
curl -X POST http://127.0.0.1:8080/tx/begin
````

### Résultat attendu (exemple)

```json
{
  "tx_id": "tx-abc123"
}
```

➡️ **Notez le `tx_id`**, il sera utilisé dans toutes les étapes suivantes.

---

## Étape 2 — Écrire des données dans la transaction

### Commandes

```bash
curl -X POST http://127.0.0.1:8080/tx/tx-abc123/put \
  -H "Content-Type: application/json" \
  -d '{"key":"dHg6dXNlcjox","value":"QWxpY2U="}'

curl -X POST http://127.0.0.1:8080/tx/tx-abc123/put \
  -H "Content-Type: application/json" \
  -d '{"key":"dHg6dXNlcjoy","value":"Qm9i"}'
```

### Résultat attendu

Pour chaque requête :

```json
{ "status": "ok" }
```

---

## Étape 3 — Lire les données *dans* la transaction

### Commandes

```bash
curl http://127.0.0.1:8080/tx/tx-abc123/get/dHg6dXNlcjox
curl http://127.0.0.1:8080/tx/tx-abc123/get/dHg6dXNlcjoy
```

### Résultat attendu

```json
{ "value": "QWxpY2U=" }
```

```json
{ "value": "Qm9i" }
```

➡️ Les données sont visibles **dans la transaction**.

---

## Étape 4 — Vérifier l’invisibilité hors transaction

### Commandes

```bash
curl http://127.0.0.1:8080/kv/dHg6dXNlcjox
curl http://127.0.0.1:8080/kv/dHg6dXNlcjoy
```

### Résultat attendu

```json
{
  "error_code": "KEY_NOT_FOUND",
  "message": "key not found"
}
```

➡️ Les écritures **ne sont pas encore visibles** hors transaction.

---

## Étape 5 — Valider la transaction (commit)

### Commande

```bash
curl -X POST http://127.0.0.1:8080/tx/tx-abc123/commit
```

### Résultat attendu

```json
{ "status": "ok" }
```

---

## Étape 6 — Vérifier la visibilité après commit

### Commandes

```bash
curl http://127.0.0.1:8080/kv/dHg6dXNlcjox
curl http://127.0.0.1:8080/kv/dHg6dXNlcjoy
```

### Résultat attendu

```json
{ "value": "QWxpY2U=" }
```

```json
{ "value": "Qm9i" }
```

➡️ Les deux écritures apparaissent **en même temps** : atomicité validée.

---

## Étape 7 — Tester l’annulation (abort)

### Démarrer une nouvelle transaction

```bash
curl -X POST http://127.0.0.1:8080/tx/begin
```

```json
{ "tx_id": "tx-def456" }
```

### Écrire une valeur

```bash
curl -X POST http://127.0.0.1:8080/tx/tx-def456/put \
  -H "Content-Type: application/json" \
  -d '{"key":"dHg6dXNlcjox","value":"Qm9i"}'
```

### Annuler la transaction

```bash
curl -X POST http://127.0.0.1:8080/tx/tx-def456/abort
```

### Résultat attendu

```json
{ "status": "aborted" }
```

---

## Étape 8 — Vérifier qu’aucun changement n’a été appliqué

### Commande

```bash
curl http://127.0.0.1:8080/kv/dHg6dXNlcjox
```

### Résultat attendu

```json
{ "value": "QWxpY2U=" }
```

➡️ La valeur précédente est intacte.

---

## Points à retenir

* une transaction regroupe plusieurs opérations KV
* les écritures sont **isolées** jusqu’au commit
* le commit est **atomique**
* `abort` annule tout sans effet de bord
* une transaction terminée ne peut pas être réutilisée

---

## Fin des exercices

🎉 Félicitations.
Vous avez validé :

* les opérations KV
* les scans
* les transactions
* les règles d’encodage
* le modèle local-first de CortexDB

➡️ Vous pouvez maintenant utiliser le playground pour vos propres tests
ou comme support de démonstration.