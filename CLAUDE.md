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

### Deux types de macros

#### 1. Macros utilitaires (boucles réutilisables)
Pour les patterns répétés plusieurs fois (clear mémoire, copies, attentes).

```asm
; Définition dans macros.inc
MACRO CLEAR_LOOP_B
.clear\@:
    ld [hl-], a
    dec b
    jr nz, .clear\@
ENDM

; Usage - le setup reste explicite
ld hl, $fffe
ld b, $80
CLEAR_LOOP_B            ; Clear HRAM
```

#### 2. Macros "free function" (décomposition algorithmique)
Pour comprendre un algorithme complexe en le découpant en étapes nommées.

**Objectif** : Lire le code ASM comme du C++ avec des appels de fonctions.

```asm
; === MACROS = "free functions" encapsulant chaque étape ===

MACRO DisableInterruptsAndConfigure
    ld a, $03
    di
    ldh [rIF], a
    ldh [rIE], a
ENDM

MACRO ConfigureLCDStat
    ld a, $40
    ldh [rSTAT], a
ENDM

MACRO ResetScroll
    xor a
    ldh [rSCY], a
    ldh [rSCX], a
    ldh [$ffa4], a
ENDM

; === CODE = séquence d'appels lisible ===

SystemInit::
    DisableInterruptsAndConfigure   ; Comme DisableInterruptsAndConfigure()
    ConfigureLCDStat                ; Comme ConfigureLCDStat()
    ResetScroll                     ; Comme ResetScroll()
    ; ...
```

**Équivalent C++ mental** :
```cpp
void SystemInit() {
    DisableInterruptsAndConfigure();
    ConfigureLCDStat();
    ResetScroll();
}
```

### Convention de nommage

| Type | Nommage | Exemple |
|------|---------|---------|
| Utilitaire | `VERBE_OBJET` majuscules | `CLEAR_LOOP_BC`, `WAIT_LY` |
| Free function | `VerbeCamelCase` | `DisableInterrupts`, `ConfigurePalettes` |

### Fichiers
- `src/macros.inc` : toutes les macros (utilitaires + free functions)
- Inclus avant les banks dans `game.asm`

### Prochaine étape
Décomposer `Jump_000_0185` (init système) en macros free function pour documenter l'algorithme d'initialisation.

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
