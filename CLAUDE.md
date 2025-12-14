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
Makefile            # Build + verify (cible principale)
ROADMAP.md          # Tâches et progression
checksum.*          # Hash de référence (SHA256 + MD5)
src/                # Code source ASM
scripts/            # Scripts utilitaires (.sh + .ps1)
docs/adr/           # Architecture Decision Records
docs/exploration.md # Parcours systématique du code
```

## Protocole d'exploration

**Fichier** : `docs/exploration.md`

Algorithme de parcours de graphe pour comprendre le code de manière systématique.

### Principe

1. **Frontière** : liste d'adresses à analyser (points d'entrée, références découvertes)
2. **Analyser** : comprendre le code/données, renommer, commenter, éliminer magic values
3. **Enrichir** : ajouter les nouvelles adresses découvertes (jumps, calls, tables)
4. **Marquer** : cocher `[x]` et déplacer vers "Analysé"
5. **Itérer** : répéter jusqu'à frontière vide

### Format des entrées

```markdown
- [ ] `$XXXX` (type) - Description, depuis SOURCE
```

**Types** : `(code)`, `(data)`, `(handler)`, `(unknown)`

### Workflow typique

```
1. Ouvrir docs/exploration.md
2. Prendre la première entrée non cochée de la frontière
3. Analyser l'adresse (lire, comprendre, renommer, commenter)
4. Ajouter les références sortantes à la frontière
5. Cocher et déplacer vers "Analysé"
6. make verify (toujours !)
7. Répéter
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
ld hl, _HRAM_END
ld b, HRAM_SIZE
CLEAR_LOOP_B            ; Clear HRAM
```

#### 2. Macros "free function" (décomposition algorithmique)
Pour comprendre un algorithme complexe en le découpant en étapes nommées.

**Objectif** : Lire le code ASM comme du C++ avec des appels de fonctions.

```asm
; === MACROS = "free functions" encapsulant chaque étape ===

MACRO DisableInterruptsAndConfigure
    ld a, IE_VBLANK_STAT
    di
    ldh [rIF], a
    ldh [rIE], a
ENDM

MACRO ConfigureLCDStat
    ld a, STATF_LYC
    ldh [rSTAT], a
ENDM

MACRO ResetScroll
    xor a
    ldh [rSCY], a
    ldh [rSCX], a
    ldh [hShadowSCX], a
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

## Constantes nommées

**Règle d'or** : Jamais de magic value dans `macros.inc` - toujours utiliser une constante nommée.

### Organisation des fichiers

| Fichier | Contenu |
|---------|---------|
| `hardware.inc` | Constantes hardware standard Game Boy (ne pas modifier) |
| `constants.inc` | Constantes spécifiques au projet |
| `macros.inc` | Macros utilisant les constantes |

### Conventions de nommage

| Type | Préfixe/Format | Exemple | Fichier |
|------|----------------|---------|---------|
| Registre hardware | `rXXX` | `rNR52`, `rLCDC` | hardware.inc |
| Zone mémoire début | `_XXXX` | `_VRAM`, `_HRAM` | hardware.inc |
| Zone mémoire fin | `_XXXX_END` | `_VRAM_END`, `_WRAM_END` | constants.inc |
| Flag/constante | `XXXF_YYY` | `LCDCF_ON`, `STATF_LYC` | hardware.inc |
| Variable HRAM | `hXxxYyy` | `hVBlankFlag`, `hGameState` | constants.inc |
| Variable WRAM | `wXxxYyy` | `wUnknownA8`, `wUnknownDC` | constants.inc |
| Constante config | `XXX_YYY` | `PALETTE_STANDARD`, `AUDVOL_MAX` | constants.inc |
| Valeur init | `INIT_XXX` | `INIT_GAME_STATE` | constants.inc |
| Adresse ROM | `ROM_XXX` | `ROM_DMA_ROUTINE` | constants.inc |

### Exemples

```asm
; AVANT (magic values)
ld hl, $ff26
ld a, $80
ld [hl-], a

; APRÈS (constantes nommées)
ld hl, rNR52
ld a, AUDENA_ON
ld [hl-], a
```

## Analyse des zones de données

### Problème du désassemblage complet

Un désassembleur interprète **tout** comme des instructions, y compris les données :
- Jump tables (adresses 16-bit)
- Tilemaps et graphiques
- Tables de sons/palettes
- Textes

**Symptômes** d'une zone data mal désassemblée :
- Instructions qui n'ont pas de sens (`db $10`, `ld b, $xx` répétés)
- Labels `Jump_XXX` au milieu de données
- Pas de structure logique (pas de `ret`, `jp`, `call` cohérents)

### Technique : xxd sur la ROM bit-perfect

Puisque `make verify` confirme que `src/game.gb` est identique à l'originale, on peut analyser les données brutes :

```bash
# Voir 120 octets à partir de l'adresse $02A5
xxd -s 0x02A5 -l 120 src/game.gb

# Voir en format plus lisible (1 octet par ligne)
xxd -s 0x02A5 -l 60 -c 2 src/game.gb
```

### Reconstruction des données

| Type de données | Directive RGBASM | Exemple |
|-----------------|------------------|---------|
| Octet simple | `db` | `db $10, $20, $30` |
| Mot 16-bit (adresse) | `dw` | `dw $0610, $06A5` |
| Espace réservé | `ds` | `ds 16` (16 octets à 0) |
| Fichier binaire | `INCBIN` | `INCBIN "tiles.bin"` |

### Exemple : Jump table

```asm
; AVANT (mal désassemblé)
    db $10
    ld b, $a5
    ld b, $c5

; APRÈS (reconstruit)
    dw $0610    ; État $00 → Handler à $0610
    dw $06A5    ; État $01 → Handler à $06A5
    dw $06C5    ; État $02 → Handler à $06C5
```

### Zones à investiguer

- Jump tables après `rst $28` ou `jp hl`
- Blocs de données après les routines (fin de bank)
- Séquences répétitives d'instructions absurdes

### Recherche automatisée des zones data

```bash
# Trouver les jump tables (rst $28 suivi de données)
grep -n "rst \$28" src/bank_*.asm

# Trouver les séquences suspectes (db répétés)
grep -n "db \$" src/bank_*.asm | head -50

# Analyser une zone avec xxd
xxd -s 0x02A5 -l 120 src/game.gb
```

### Convention de nommage pour tables de données

| Type | Suffixe | Exemple |
|------|---------|---------|
| Jump table | `*JumpTable` | `StateJumpTable` |
| Données d'animation | `*AnimData` | `PlayerAnimData` |
| Tilemaps | `*Tilemap` | `HUDTilemap` |
| Palettes | `*Palette` | `LevelPalette` |
| Graphiques | `*Tiles` ou `*Gfx` | `PlayerTiles` |

### Extraction des graphiques (optionnel)

Les tiles Game Boy sont en format 2bpp (2 bits par pixel). Pour visualiser :

```bash
# Extraire des tiles bruts
dd if=src/game.gb bs=1 skip=$((0x4000)) count=$((0x1000)) of=tiles.2bpp

# Convertir en PNG (si rgbgfx disponible)
rgbgfx -r -o tiles.png tiles.2bpp
```

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
