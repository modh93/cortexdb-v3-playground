# Tutorial 03 — KV: PUT / GET / DELETE

## Objectif

TODO: Apprendre les opérations de base : créer, lire, supprimer des clés/valeurs.

## Prérequis

TODO: Serveur lancé, compréhension de l'encodage Base64.

## PUT (Create/Update)

### Commandes

TODO: Commandes curl pour :
- Encoder une clé en Base64 puis URL
- Encoder une valeur en Base64
- Faire un PUT avec le bon format

### Résultats attendus

TODO: 
- Status code: 201 (created) ou 200 (updated)
- Body vide ou confirmation

## GET (Read)

### Commandes

TODO: Commandes curl pour :
- GET avec clé encodée dans l'URL
- Décoder la réponse

### Résultats attendus

TODO:
- Status code: 200
- Body: `{"key":"...","value":"..."}` (Base64)
- Décodage de la valeur

## DELETE

### Commandes

TODO: Commandes curl pour :
- DELETE avec clé encodée
- Vérifier la suppression

### Résultats attendus

TODO:
- Status code: 204 (No Content)
- GET après DELETE doit retourner 404

## Points à retenir

TODO: Points clés :
- Clés dans URL : Base64 + URL percent-encoding
- Valeurs dans JSON : Base64 seulement
- DELETE est idempotent (pas d'erreur si clé n'existe pas)

