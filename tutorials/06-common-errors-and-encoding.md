# Tutorial 06 — Common Errors and Encoding

## Objectif

TODO: Comprendre les erreurs courantes et maîtriser l'encodage Base64/URL.

## Prérequis

TODO: Avoir fait les tutorials précédents et rencontré quelques erreurs.

## Erreurs Courantes

### 404 Not Found

TODO: Causes et solutions :
- Clé mal encodée dans l'URL
- Clé n'existe pas vraiment
- Vérification de l'encodage

### 400 Bad Request

TODO: Causes et solutions :
- JSON mal formé
- Base64 invalide dans le body
- Paramètres manquants

### 413 Payload Too Large

TODO: Causes et solutions :
- Valeur trop grande
- Limites du serveur

## Encodage : Cas Pratiques

### Cas 1 : Clé simple

TODO: Exemple avec clé sans caractères spéciaux :
- `"user:1"` → Base64 → URL
- Pas de changement pour URL encoding

### Cas 2 : Clé avec caractères spéciaux

TODO: Exemple avec clé contenant `/`, `+`, `=` :
- Base64 peut contenir ces caractères
- URL encoding nécessaire

### Cas 3 : Valeur dans JSON

TODO: Exemple montrant :
- Base64 seulement (pas d'URL encoding)
- Décodage pour vérification

## Debugging Tips

TODO: Conseils pour déboguer :
- Utiliser le playground console
- Vérifier chaque étape d'encodage
- Tester avec curl pour isoler les problèmes

## Points à retenir

TODO: Points clés :
- Toujours vérifier l'encodage en cas d'erreur
- Clés dans URL : Base64 + URL percent-encoding
- Valeurs dans JSON : Base64 seulement
- Le playground montre les étapes d'encodage

