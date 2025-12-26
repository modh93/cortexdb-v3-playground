# Tutorial 02 — Health and Stats

## Objectif

TODO: Apprendre à vérifier l'état du serveur et consulter les statistiques.

## Prérequis

TODO: Serveur CortexDB lancé (tutorial 01).

## Health Check

### Commandes

TODO: Commandes curl pour :
- `GET /health`
- Interpréter la réponse

### Résultats attendus

TODO: Réponse attendue :
```json
{
  "status": "ok",
  "version": "3.4.0"
}
```

## Stats Endpoint

### Commandes

TODO: Commandes curl pour :
- `GET /stats`
- Comprendre les métriques retournées

### Résultats attendus

TODO: Structure de la réponse stats :
- Nombre de clés
- Taille de la base
- (autres métriques selon implémentation)

## Points à retenir

TODO: Points clés :
- `/health` est l'endpoint de base pour vérifier la disponibilité
- `/stats` donne des informations sur l'état de la base
- Ces endpoints ne nécessitent pas d'encodage

