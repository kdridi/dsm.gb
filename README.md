# Projet Game Boy ASM

Exercice pédagogique : comprendre, documenter et enrichir des sources ASM Game Boy.

## Contexte

Notre prof nous a confié une quête : partir de sources ASM d'un vrai projet Game Boy, les comprendre, les documenter, puis les enrichir. La contrainte : chaque modification doit produire un binaire **bit-perfect** avec l'original.

## Prérequis

- **rgbds** : assembleur/linker Game Boy (`rgbasm`, `rgblink`, `rgbfix`)

### Installation

```bash
./scripts/setup.sh           # Linux / macOS
./scripts/setup.ps1          # Windows (PowerShell)

./scripts/install-hooks.sh   # Installe le hook pre-commit (recommandé)
./scripts/install-hooks.ps1  # Windows
```

Le hook pre-commit vérifie automatiquement le build bit-perfect avant chaque commit.

## Utilisation

```bash
make          # Compile le projet (src/game.gb)
make verify   # Compile + vérifie les checksums
make clean    # Supprime les fichiers générés
```

## Structure

```
src/            # Code source ASM
Makefile        # Commandes de build
scripts/        # Scripts utilitaires
docs/adr/       # Décisions d'architecture
ROADMAP.md      # Progression du projet
CLAUDE.md       # Conventions du projet
checksum.*      # Hash de référence
```

## Workflow

1. Modifier le code source dans `src/`
2. Exécuter `make verify`
3. Si les checksums correspondent : modification valide
