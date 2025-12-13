# Projet Désassemblage Game Boy

## Objectif
Désassembler `rom.gb`, analyser et annoter le code source tout en garantissant une recompilation bit-perfect.

## Principe fondamental
**Le hash identique est notre test de non-régression.**

Cycle de travail :
```
1. Désassembler (une fois)
2. Recompiler → Valider hash identique
3. Annoter/Modifier le source → Recompiler → Valider
4. Répéter étape 3
```

On peut librement :
- Renommer les labels pour les rendre explicites
- Ajouter des commentaires pour documenter la logique
- Restructurer le code (sections, includes)
- Documenter les routines et structures de données

...tant que `make verify` confirme que le binaire reste identique à l'original.

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
- **Capitalisation des découvertes** :
  - Principe/convention → mettre à jour CLAUDE.md
  - Impact sur les tâches → mettre à jour ROADMAP.md
  - Choix technique structurant → créer un ADR

## Gouvernance (ADR)
- **Où ?** `docs/adr/` (voir [index](docs/adr/README.md))
- **Quand créer un ADR ?** Nouvelle convention, choix technique structurant, organisation
- **Consulter avant** : création de scripts, ajout de dossiers, choix d'outils
- **Format** : `NNNN-titre-court.md`

## Workflow
1. Suivre ROADMAP.md pour les tâches structurantes
2. Pour chaque modification du source : **toujours valider avec `make verify`**
3. Capitaliser les découvertes (voir convention ci-dessus)
