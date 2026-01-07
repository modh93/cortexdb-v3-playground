# 03 — KV : PUT / GET / DELETE

## Objectif
Manipuler des données **clé/valeur** avec CortexDB :
- écrire une valeur (`PUT`)
- lire une valeur (`GET`)
- supprimer une valeur (`DELETE`)

Ce tutoriel insiste sur **l’encodage correct** des clés et des valeurs.

---

## Prérequis

- Avoir suivi `02 — Health & Stats`
- CortexDB en cours d’exécution sur :
```

[http://127.0.0.1:8080](http://127.0.0.1:8080)

````

---

## Rappel essentiel — règles d’encodage

### Clé (dans l’URL)
1. convertir la clé texte en **Base64 RFC4648**
2. appliquer un **URL percent-encoding** (`/ → %2F`, `+ → %2B`, `= → %3D`)

### Valeur (dans le body JSON)
- **Base64 brut uniquement**
- **pas** de percent-encoding

💡 Le playground gère cet encodage automatiquement.

---

## Exemple de données

- clé (texte) : `user:1`
- valeur (texte) : `Alice`

Encodages correspondants :
- clé base64 : `dXNlcjox`
- clé URL-encodée : `dXNlcjox` (pas de caractère spécial ici)
- valeur base64 : `QWxpY2U=`

---

## Étape 1 — PUT (écrire une valeur)

### Commande

```bash
curl -X PUT \
http://127.0.0.1:8080/kv/dXNlcjox \
-H "Content-Type: application/json" \
-d '{
  "value": "QWxpY2U="
}'
````

### Résultat attendu

```json
{
  "status": "ok"
}
```

---

## Étape 2 — GET (lire une valeur)

### Commande

```bash
curl http://127.0.0.1:8080/kv/dXNlcjox
```

### Résultat attendu

```json
{
  "value": "QWxpY2U="
}
```

Décodage Base64 :

```text
QWxpY2U= → Alice
```

---

## Étape 3 — DELETE (supprimer une valeur)

### Commande

```bash
curl -X DELETE http://127.0.0.1:8080/kv/dXNlcjox
```

### Résultat attendu

```json
{
  "status": "ok"
}
```

---

## Étape 4 — Vérifier la suppression

### Commande

```bash
curl http://127.0.0.1:8080/kv/dXNlcjox
```

### Résultat attendu (exemple)

```json
{
  "error_code": "KEY_NOT_FOUND",
  "message": "key not found"
}
```

---

## Vérification via `/stats`

Après un `PUT`, puis un `DELETE` :

```bash
curl http://127.0.0.1:8080/stats
```

Vous pouvez observer :

* l’évolution du nombre de clés
* l’activité du moteur

---

## Utilisation via le playground

Dans le playground :

1. renseignez la clé et la valeur en **texte**
2. cliquez sur **PUT**
3. cliquez sur **GET**
4. cliquez sur **DELETE**
5. observez la console (requêtes + réponses)

Le playground affiche :

* la clé en clair
* la clé encodée
* la valeur encodée
* la réponse brute

---

## Erreurs courantes

### ❌ Clé mal encodée

Symptôme :

* erreur 400 ou clé introuvable

Cause :

* oubli du Base64
* oubli du percent-encoding

Solution :

* utiliser le playground
* ou vérifier l’encodage manuellement

---

### ❌ Valeur non encodée en Base64

Symptôme :

* erreur de parsing JSON
* erreur serveur

Solution :

* toujours envoyer la valeur en Base64

---

## Points à retenir

* CortexDB est **clé/valeur strict**
* l’encodage fait partie du contrat API
* `PUT`, `GET`, `DELETE` sont déterministes
* aucune opération cachée ou implicite

---

## Prochaine étape

➡️ Passez au tutoriel suivant :
**04 — Range & Prefix : parcourir les données**
