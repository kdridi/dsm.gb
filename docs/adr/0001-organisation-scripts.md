# ADR-0001 : Organisation des scripts

## Statut
Accepté

## Contexte
Le projet nécessite des scripts utilitaires (setup, build, etc.) et doit être cross-platform (Linux, macOS, Windows).

## Décision

### Emplacement
Tous les scripts utilitaires sont placés dans le dossier `scripts/` à la racine.

### Convention de nommage

#### Extensions
- `<nom>.sh` : Linux / macOS (Bash)
- `<nom>.ps1` : Windows (PowerShell)

#### Nom du script
- **Doit commencer par un verbe d'action** qui exprime l'intention
- Le nom doit être explicite sur ce que fait le script
- Format recommandé : `verbe-objet` (ex: `setup-toolchain`, `compute-hash`, `verify-build`)

**Exemples :**
| ❌ Mauvais | ✅ Bon | Pourquoi |
|-----------|--------|----------|
| `hash.sh` | `store-original-hash.sh` | "hash" ne dit pas l'intention (calculer ? vérifier ? stocker ?) |
| `build.sh` | `build-rom.sh` | Plus explicite sur ce qu'on construit |
| `tools.sh` | `setup-toolchain.sh` | Le verbe clarifie l'action |

### Structure
```
scripts/
├── setup.sh          # Installation dépendances (Unix)
├── setup.ps1         # Installation dépendances (Windows)
└── ...
```

### Règles
1. Chaque script doit avoir son équivalent pour les 2 plateformes (Unix + Windows)
2. Les scripts doivent être idempotents (peuvent être relancés sans effet de bord)
3. Afficher clairement le statut des vérifications/installations

## Conséquences
- Pas de dépendance externe (Node.js, Python) pour les scripts
- Maintenance de 2 versions par script
- Compatibilité native sur chaque OS
