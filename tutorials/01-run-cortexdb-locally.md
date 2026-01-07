# 01 — Lancer CortexDB en local

## Objectif
Comprendre **comment lancer, arrêter et configurer CortexDB en local**,
en cohérence avec l’approche *local-first*.

À la fin de ce tutoriel, vous saurez :
- lancer CortexDB avec un chemin de données explicite
- comprendre ce qui est stocké sur disque
- arrêter proprement le serveur
- reconnaître les erreurs courantes au démarrage

---

## Rappel : ce que vous lancez réellement

CortexDB est composé de deux éléments distincts :

- **cortexdbd** : le **serveur HTTP** (daemon)
- **playground** : un **client** (navigateur)

Dans ce tutoriel, nous nous concentrons uniquement sur **le serveur**.

---

## Prérequis

- Avoir suivi `00 — Prérequis`
- Le binaire `bin/cortexdbd` doit exister
- Aucun autre service ne doit utiliser le port `8080`

---

## Étape 1 — Comprendre le script de lancement

Le script fourni :

```bash
./scripts/run_cortexdb.sh
```

fait les choses suivantes :

1. crée un dossier de données local : `./.cortexdb_data`
2. lance `cortexdbd` avec :

   * un chemin de stockage explicite
   * un port local (`127.0.0.1:8080`)

Cela garantit :

* persistance locale
* aucune exposition réseau externe

---

## Étape 2 — Lancer CortexDB

Depuis la racine du repo playground :

```bash
./scripts/run_cortexdb.sh
```

### Résultat attendu

* aucune erreur au démarrage
* un message indiquant que le serveur écoute sur :

  ```
  http://127.0.0.1:8080
  ```

Le terminal reste **ouvert** : le serveur tourne tant que le processus est actif.

---

## Étape 3 — Vérifier la persistance locale

Dans un autre terminal :

```bash
ls -lh .cortexdb_data/
```

### Résultat attendu

* un ou plusieurs fichiers/dossiers internes
* leur contenu est géré automatiquement par CortexDB

⚠️ Ne modifiez jamais ces fichiers à la main.

---

## Étape 4 — Vérifier que le serveur répond

```bash
curl http://127.0.0.1:8080/health
```

### Résultat attendu

```json
{
  "status": "ok",
  "version": "3.3.0"
}
```

Cela confirme que :

* le serveur est lancé
* l’API HTTP est disponible
* aucun client externe n’est requis

---

## Étape 5 — Arrêter CortexDB proprement

Dans le terminal où le serveur tourne :

```text
CTRL + C
```

### Résultat attendu

* le serveur s’arrête proprement
* aucune corruption des données
* retour au prompt shell

💡 CortexDB gère un **graceful shutdown**.

---

## Étape 6 — Relancer CortexDB

Relancez simplement :

```bash
./scripts/run_cortexdb.sh
```

### Point important

* les données précédentes sont **toujours présentes**
* la persistance est locale et durable

---

## Erreurs courantes et solutions

### ❌ Port déjà utilisé

Erreur typique :

```text
address already in use
```

Solution :

* vérifier qu’aucune autre instance ne tourne
* arrêter le processus précédent
* ou changer le port (non couvert ici)

---

### ❌ Binaire introuvable

Erreur :

```text
./bin/cortexdbd: No such file or directory
```

Solution :

* relancer `scripts/download_cortexdb_linux.sh`
* vérifier les droits d’exécution :

  ```bash
  chmod +x bin/cortexdbd
  ```

---

### ❌ Le serveur ne répond pas

Vérifier :

* que le script est toujours en cours d’exécution
* que l’URL utilisée est bien `127.0.0.1` et non une IP externe

---

## Points à retenir

* CortexDB fonctionne **entièrement en local**
* les données sont stockées sur disque
* le serveur est un processus simple à lancer/arrêter
* aucune dépendance réseau externe n’est nécessaire

---

## Prochaine étape

➡️ Passez au tutoriel suivant :
**02 — Health & Stats : observer l’état du serveur**
