# Tutorial 05 — Transactions

## Objectif

TODO: Apprendre à utiliser les transactions pour des opérations atomiques.

## Prérequis

TODO: Compréhension des opérations KV de base (tutorial 03).

## Begin Transaction

### Commandes

TODO: Commandes pour :
- `POST /tx/begin`
- Récupérer le TX ID
- Comprendre l'isolation

### Résultats attendus

TODO:
- Status code: 200
- Body: `{"tx_id":"..."}`
- TX ID à utiliser pour les opérations suivantes

## Operations in Transaction

### Commandes

TODO: Commandes pour :
- `POST /tx/{id}/put` (plusieurs clés)
- `GET /tx/{id}/get/{key}` (lecture isolée)
- Vérifier que les clés ne sont pas visibles en dehors de la transaction

### Résultats attendus

TODO:
- PUT dans transaction: 200
- GET dans transaction: 200 avec valeur
- GET hors transaction: 404 (pas encore commité)

## Commit / Abort

### Commandes

TODO: Commandes pour :
- `POST /tx/{id}/commit` (valider)
- `POST /tx/{id}/abort` (annuler)
- Vérifier l'état après commit/abort

### Résultats attendus

TODO:
- Commit: 200, les clés deviennent visibles
- Abort: 200, les clés ne sont pas persistées
- GET après commit: 200
- GET après abort: 404

## Points à retenir

TODO: Points clés :
- Transactions garantissent l'atomicité
- Isolation : les changements ne sont visibles qu'après commit
- Abort annule tous les changements de la transaction

