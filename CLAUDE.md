# Projet Désassemblage Game Boy

## Objectif
Désassembler `rom.gb`, analyser, garantir recompilation bit-perfect (SHA256 + MD5).

## Toolchain
- **mgbdis** : désassembleur
- **rgbds** : rgbasm, rgblink, rgbfix

## Structure
rom.gb, src/, build/, Makefile, ROADMAP.md

## Vérification
Build = SHA256 + MD5 identiques à l'original

## Conventions
- Process générique (indépendant du jeu)
- Commits : `[ROADMAP-XXXXXX] description`
- Code/labels : anglais | Docs/commentaires : français
- 1 tâche ROADMAP = 1 commit

## Workflow
Suivre ROADMAP.md, cocher les tâches, ajouter les découvertes
