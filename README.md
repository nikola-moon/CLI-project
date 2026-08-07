# Todo CLI

Application de gestion de tâches en ligne de commande, écrite en Dart. Les tâches sont enregistrées dans `tasks.json` à la racine du projet.

## Prérequis

- Dart SDK 3.6 ou supérieur
- Un terminal

## Installation et lancement

```bash
dart pub get
dart run bin/main.dart
```

## Utilisation

Le menu permet de :

- créer une tâche avec un titre, une priorité obligatoire (faible, moyenne ou élevée) et une échéance facultative au format `AAAA-MM-JJ` ;
- marquer une tâche comme urgente lorsqu'elle a une priorité élevée ;
- afficher les tâches triées explicitement par priorité ou par date limite ;
- marquer une tâche comme terminée et supprimer une tâche à partir de son ID.

Les erreurs de saisie, d'ID, de date et de stockage sont affichées comme des `TaskException` compréhensibles, sans arrêter l'application.

## Architecture

- `models/` : modèle abstrait `Task`, avec `StandardTask` et `UrgentTask`.
- `repositories/` : contrat générique `Repository<T>` et persistance JSON.
- `services/task_service.dart` : règles métier (création, tri, complétion, suppression).
- `services/cli_service.dart` : interactions terminal uniquement.

## Tests et analyse statique

```bash
dart test
dart analyze
```
