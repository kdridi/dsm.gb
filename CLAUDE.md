# Projet Game Boy ASM

## Objectif
Comprendre, documenter et enrichir des sources ASM Game Boy tout en garantissant une compilation bit-perfect.

## Principe fondamental
**Le hash identique est notre test de non-régression.**

Cycle de travail :
```
1. Modifier le source (renommer, commenter, restructurer)
2. Compiler → Valider hash identique
3. Répéter
```

On peut librement :
- Renommer les labels pour les rendre explicites
- Ajouter des commentaires pour documenter la logique
- Restructurer le code (sections, includes)
- Documenter les routines et structures de données

...tant que `make verify` confirme que le binaire reste identique.

## Premier lancement

Si le fichier `.initialized` n'existe pas à la racine :
```bash
./scripts/setup.sh           # Installe rgbds
./scripts/install-hooks.sh   # Installe le hook pre-commit + crée .initialized
```

## Début de session

Avant de travailler, vérifier que l'environnement est opérationnel :

| Vérification | Commande | Attendu |
|--------------|----------|---------|
| Toolchain | `which rgbasm` | Chemin affiché |
| Hook pre-commit | `ls .git/hooks/pre-commit` | Fichier présent (pas `.sample`) |
| Fichier init | `ls .initialized` | Fichier présent |
| Build OK | `make verify` | `HASH VERIFIED` |

Si quelque chose manque → exécuter les scripts de "Premier lancement".

## Toolchain
- **rgbds** : rgbasm, rgblink, rgbfix

## Structure
```
Makefile        # Build + verify (cible principale)
ROADMAP.md      # Tâches et progression
checksum.*      # Hash de référence (SHA256 + MD5)
src/            # Code source ASM
scripts/        # Scripts utilitaires (.sh + .ps1)
docs/adr/       # Architecture Decision Records
```

## Scripts (voir ADR-0001, ADR-0002)
- Emplacement : `scripts/`
- Unix : `scripts/<nom>.sh`
- Windows : `scripts/<nom>.ps1`
- **Nommage** : verbe + objet (ex: `setup-toolchain.sh`)
- Règle : chaque script a son équivalent cross-platform
- Logging : header d'intention, log par étape, mode DEBUG=1
- Erreurs : arrêt immédiat, message clair, code de sortie approprié

## Vérification
Build = SHA256 + MD5 identiques à la référence

## Macros RGBASM

Les macros permettent d'abstraire les patterns répétitifs **sans changer le binaire**.

**Principe** : Les macros s'expandent à l'assemblage → code machine identique → hash vérifié.

**Convention** :
- Fichier : `src/macros.inc` (inclus avant les banks)
- Nommage : `VERBE_OBJET` en majuscules (ex: `CLEAR_LOOP_BC`, `WAIT_LY`)
- Documentation : chaque macro explique **QUOI** + **POURQUOI** + **PRÉREQUIS**
- Factoriser uniquement la **boucle**, pas le setup des registres
  - Raison : l'ordre des instructions de setup peut varier dans l'original

**Pourquoi cette approche ?**
1. Le nom de la macro documente l'intention
2. Les commentaires d'usage dans bank_000.asm expliquent le contexte
3. Le binaire reste bit-perfect (vérifié par `make verify`)

**Macros existantes** : voir `src/macros.inc` pour la liste complète.

## Conventions
- Process générique
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

## Fin de session
Avant un `/clear` ou une pause, faire un briefing concis :
1. **Ce qu'on a fait** - résumé factuel
2. **À capitaliser** - si quelque chose mérite d'aller dans CLAUDE.md, ROADMAP.md ou un ADR, le faire ou le signaler
3. **Prochaines pistes** - options concrètes avec avis critique sur les priorités
4. **Ou "à plus !"** - la porte reste ouverte

Ton : enthousiaste sur l'élan, honnête sur les priorités.
