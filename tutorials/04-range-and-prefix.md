# Tutorial 04 — Range and Prefix Scans

## Objectif

TODO: Apprendre à scanner des plages de clés et faire des recherches par préfixe.

## Prérequis

TODO: Compréhension des opérations KV de base (tutorial 03).

## Range Scan

### Commandes

TODO: Commandes pour :
- Préparer plusieurs clés (user:1, user:2, product:1, etc.)
- Faire un range scan de "a" à "z"
- Comprendre l'ordre lexicographique

### Résultats attendus

TODO:
- Status code: 200
- Body: `{"results":[...],"count":N}`
- Clés triées lexicographiquement

## Prefix Scan

### Commandes

TODO: Commandes pour :
- Faire un prefix scan sur "user:"
- Limiter le nombre de résultats
- Comprendre la différence avec range

### Résultats attendus

TODO:
- Status code: 200
- Body: `{"results":[...],"count":N}`
- Seulement les clés commençant par le préfixe

## Points à retenir

TODO: Points clés :
- Range scan : plage de clés (start → end)
- Prefix scan : toutes les clés avec un préfixe donné
- Les clés sont triées lexicographiquement
- Les start/end/prefix doivent être en Base64 dans le JSON

