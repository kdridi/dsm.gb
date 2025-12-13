# Désassemblage Game Boy

Projet de désassemblage et annotation d'une ROM Game Boy avec recompilation bit-perfect.

## Prérequis

- **rgbds** : assembleur/linker Game Boy (`rgbasm`, `rgblink`, `rgbfix`)
- **Python 3** : pour mgbdis (désassembleur)
- **Git**

### Installation des dépendances

```bash
./scripts/setup.sh      # Linux / macOS
./scripts/setup.ps1     # Windows (PowerShell)
```

## ROM originale

Le fichier `rom.gb` n'est pas inclus dans le dépôt. Fournissez votre propre ROM.

La ROM est validée par ses checksums :
- SHA256 : voir `checksum.sha256`
- MD5 : voir `checksum.md5`

## Utilisation

```bash
make          # Compile la ROM (src/game.gb)
make verify   # Compile + vérifie les hash (bit-perfect)
make clean    # Supprime les fichiers générés
```

## Structure

```
Makefile        # Commandes de build
src/            # Code source désassemblé
scripts/        # Scripts utilitaires
docs/adr/       # Décisions d'architecture
ROADMAP.md      # Progression du projet
CLAUDE.md       # Conventions du projet
```

## Workflow

1. Modifier le code source dans `src/`
2. Exécuter `make verify`
3. Si le hash est identique : modification valide
