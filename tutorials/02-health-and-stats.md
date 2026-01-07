# 02 — Health & Stats : observer l’état du serveur

## Objectif
Apprendre à **observer l’état de CortexDB** via ses endpoints système.
Ces endpoints permettent de vérifier que le serveur fonctionne correctement
et d’obtenir des informations internes utiles pour le diagnostic.

À la fin de ce tutoriel, vous saurez :
- utiliser `/health` pour vérifier la disponibilité du serveur
- utiliser `/stats` pour inspecter l’état interne
- comprendre à quoi servent ces endpoints en pratique

---

## Prérequis

- Avoir suivi `01 — Lancer CortexDB en local`
- CortexDB doit être en cours d’exécution sur :
```

[http://127.0.0.1:8080](http://127.0.0.1:8080)

````

---

## Endpoint 1 — Health check

### Description
L’endpoint `/health` permet de vérifier rapidement si le serveur est :
- accessible
- opérationnel

Il est conçu pour être :
- simple
- rapide
- sans effet de bord

---

### Commande

```bash
curl http://127.0.0.1:8080/health
````

---

### Résultat attendu

```json
{
  "status": "ok",
  "version": "3.3.0"
}
```

### Interprétation

* `status: ok` → le serveur répond correctement
* `version` → version du moteur exposée par l’API HTTP

💡 Cet endpoint est souvent utilisé par :

* des scripts de monitoring
* des tests automatisés
* des scripts de démarrage

---

## Endpoint 2 — Stats

### Description

L’endpoint `/stats` fournit des informations internes sur l’état du moteur.

Ces informations sont utiles pour :

* comprendre l’activité du moteur
* diagnostiquer un comportement inattendu
* observer l’évolution du stockage

---

### Commande

```bash
curl http://127.0.0.1:8080/stats
```

---

### Résultat attendu (exemple)

```json
{
  "uptime_seconds": 42,
  "kv": {
    "keys": 0,
    "values": 0
  },
  "storage": {
    "sstables": 0,
    "wal_size_bytes": 0
  }
}
```

⚠️ Les champs exacts peuvent évoluer légèrement selon la version,
mais la structure reste stable.

---

### Interprétation

* `uptime_seconds`
  Temps écoulé depuis le démarrage du serveur.

* `kv.keys` / `kv.values`
  Nombre de clés et valeurs actuellement stockées.

* `storage.sstables`
  Nombre de tables persistées sur disque.

* `storage.wal_size_bytes`
  Taille actuelle du journal d’écriture (WAL).

---

## Observer l’évolution des stats

Lancez la commande `/stats`, puis ajoutez des données (dans les tutoriels suivants),
et relancez `/stats`.

Vous observerez :

* l’augmentation du nombre de clés
* l’évolution des compteurs internes

---

## Utilisation via le playground

Dans le playground :

1. cliquez sur **Health**
2. cliquez sur **Stats**
3. observez les réponses dans la console intégrée

Cela permet de :

* tester sans ligne de commande
* visualiser les réponses HTTP

---

## Cas d’erreur courant

### ❌ Le serveur ne répond pas

Erreur typique :

```text
Connection refused
```

Causes possibles :

* CortexDB n’est pas lancé
* le port est incorrect
* le serveur a été arrêté

Solution :

* relancer `./scripts/run_cortexdb.sh`
* vérifier l’URL (`127.0.0.1:8080`)

---

## Points à retenir

* `/health` = disponibilité du serveur
* `/stats` = état interne du moteur
* ces endpoints n’altèrent pas les données
* ils sont essentiels pour le monitoring et le debug

---

## Prochaine étape

➡️ Passez au tutoriel suivant :
**03 — KV : PUT / GET / DELETE**
