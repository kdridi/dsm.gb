# Projet Désassemblage Game Boy

## Objectif
Désassembler `rom.gb`, analyser, garantir recompilation bit-perfect (SHA256 + MD5).

## Toolchain
- **mgbdis** : désassembleur
- **rgbds** : rgbasm, rgblink, rgbfix

## Structure
```
rom.gb, src/, build/, Makefile, ROADMAP.md
scripts/        # Scripts utilitaires (.sh + .ps1)
docs/adr/       # Architecture Decision Records
```

## Scripts (voir ADR-0001, ADR-0002)
- Emplacement : `scripts/`
- Unix : `scripts/<nom>.sh`
- Windows : `scripts/<nom>.ps1`
- Règle : chaque script a son équivalent cross-platform
- Logging : header d'intention, log par étape, mode DEBUG=1
- Erreurs : arrêt immédiat, message clair, code de sortie approprié

## Vérification
Build = SHA256 + MD5 identiques à l'original

## Conventions
- Process générique (indépendant du jeu)
- Commits : `[ROADMAP-XXXXXX] description`
- Code/labels : anglais | Docs/commentaires : français
- 1 tâche ROADMAP = 1 commit
- **git commit TOUJOURS seul** : jamais de `&&` ou `;` avec git commit
- **Langue d'échange** : toujours en français

## Gouvernance (ADR)
- **Où ?** `docs/adr/` (voir [index](docs/adr/README.md))
- **Quand créer un ADR ?** Nouvelle convention, choix technique structurant, organisation
- **Consulter avant** : création de scripts, ajout de dossiers, choix d'outils
- **Format** : `NNNN-titre-court.md`

## Workflow
Suivre ROADMAP.md, cocher les tâches, ajouter les découvertes
