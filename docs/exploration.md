# Exploration du code - Parcours systématique

## Objectif

Comprendre 100% du code en suivant un **algorithme de parcours de graphe** : chaque adresse analysée révèle de nouvelles adresses à explorer, jusqu'à couverture complète.

## Protocole

### 1. Analyser une entrée de la frontière
- Lire le code/données à cette adresse
- Comprendre sa fonction (renommer labels, ajouter commentaires)
- Éliminer les magic values (constantes nommées)
- Identifier les références sortantes (jumps, calls, accès données)

### 2. Enrichir la frontière
- Ajouter chaque nouvelle adresse découverte
- Préciser le type : `(code)` / `(data)` / `(unknown)`
- Noter la source : "depuis XXX" ou "référencé par YYY"

### 3. Marquer comme analysé
- Cocher `[x]` et déplacer vers la section "Analysé"
- Noter les découvertes importantes

### 4. Itérer
- Répéter jusqu'à frontière vide

## Format des entrées

```markdown
- [ ] `$XXXX` (type) - Description courte, depuis SOURCE
```

**Types** :
- `(code)` : routine/fonction exécutable
- `(data)` : table, graphiques, texte
- `(unknown)` : à déterminer
- `(handler)` : gestionnaire d'interruption/état

**Priorité implicite** : les handlers et points d'entrée d'abord, puis les références en profondeur.

---

## Frontière (à analyser)

### Points d'entrée système
- [x] `$0000` (code) - RST $00 : Soft reset → `jp SystemInit`
- [x] `$0008` (code) - RST $08 : Soft reset (alias)
- [x] `$0010` (code) - RST $10 : Non utilisé (padding)
- [x] `$0018` (code) - RST $18 : Non utilisé (padding)
- [x] `$0020` (code) - RST $20 : Non utilisé (padding)
- [x] `$0028` (code) - **RST $28 : Jump Table Dispatcher** (crucial !)
- [x] `$0030` (code) - RST $30 : Suite dispatcher (termine le saut)
- [x] `$0038` (code) - RST $38 : Non utilisé (trap/boucle infinie)
- [x] `$0040` (handler) - VBlank interrupt → `jp VBlankHandler` ($0060)
- [x] `$0048` (handler) - STAT interrupt → `jp LCDStatHandler` ($0095)
- [x] `$0100` (code) - Entry point ROM → header + `jp SystemInit`

### Handlers d'état (depuis StateJumpTable $02A5)
*60 entrées - Tous analysés et documentés*

| État | Adresse | Rôle |
|------|---------|------|
| $00 | $0610 | **Main gameplay** - boucle de jeu principale |
| $01 | $06A5 | **Reset objets** - clear buffers → état $02 |
| $02 | $06C5 | **Chargement niveau** - LCD off, config, → état $00 |
| $03 | $0B84 | **Setup sprites** - transition visuelle → état $04 |
| $04 | $0BCD | **Animation transition** - via table $0C10 |
| $05 | $0C6A | **Niveau spécial** - gestion monde 3? |
| $06 | $0CC2 | **Post-niveau** - transition selon position |
| $07 | $0C37 | **Attente timer** - appel bank 3 → état $05 |
| $08 | $0D40 | **Progression** - changement monde/niveau |
| $09 | $1612 | **Entrée tuyau droite** - déplace joueur vers X cible → $0A |
| $0A | $1626 | **Chargement sous-niveau** - LCD off, clear, repositionne → $00 |
| $0B | $1663 | **Descente tuyau** - déplace joueur vers bas → charge dest → $0C |
| $0C | $16D1 | **Sortie tuyau gauche** - déplace joueur vers X cible → $00 |
| $0D | $236D | **Gameplay complet** - update objets/ennemis, 4 slots, multi-bank |
| $0E | $0322 | **Init niveau** - charge tiles VRAM, config HUD → $0F |
| $0F | $04C3 | **Menu sélection** - navigation joypad, affiche indices → $11 |
| $10 | $05B7 | **Noop** - état vide (placeholder, ret immédiat) |
| $11 | $055F | **Démarrage niveau** - reset score, config timers, init display |
| $12 | $3D8E | **State12_EndLevelSetup** - LCD off, clear OAM, fill tilemap → $13 |
| $13 | $3DCE | **State13_DrawEndBorder** - bordure décorative, texte → $14 |
| $14 | $5832 | (Bank 1, zone données - non analysable) |
| $15 | $5835 | (Bank 1, zone données - non analysable) |
| $16 | $3E9E | **State16_CopyTilemapData** - copie données vers tilemap → $15 |
| $17 | $5838 | (Bank 1, zone données - non analysable) |
| $18 | $583B | (Bank 1, zone données - non analysable) |
| $19 | $583E | (Bank 1, zone données - non analysable) |
| $1A | $5841 | (Bank 1, zone données - non analysable) |
| $1B | $0DF0 | **State1B_BonusComplete** - LCD off, charge tiles, LCD on → $08 |
| $1C | $0E0C | **State1C_WaitTimerGameplay** - attente timer + call bank3 |
| $1D | $0E28 | **State1D_SetupVRAMPointer** - configure pointeur VRAM/bank |
| $1E | $0E54 | **State1E_ClearTilemapColumn** - efface colonne tilemap |
| $1F | $0E8D | **State1F_EnableVBlankMode** - configure mode VBlank |
| $20 | $0EA0 | **State20_WaitPlayerPosition** - attente position joueur cible |
| $21 | $0EC4 | **State21_SetupEndCutscene** - configure cutscene fin niveau |
| $22 | $0F09 | **State22_ScrollCutscene** - scrolling cutscene |
| $23 | $0F2A | **State23_WalkToDoor** - marche vers porte château |
| $24 | $0F61 | **State24_DisplayText** - affichage texte écran |
| $25 | $0FF4 | **State25_SpriteBlinkAnimation** - animation clignotement |
| $26 | $104C | **State26_PrincessRising** - animation princesse qui monte |
| $27 | $1090 | **State27_PlayerOscillation** - oscillation joueur |
| $28 | $0EA0 | (= État $20 - WaitPlayerPosition) |
| $29 | $110D | **State29_SetupEndScreen** - config écran fin |
| $2A | $115C | **State2A_DrawEndBackground** - dessine fond fin |
| $2B | $118B | **State2B_LoadEndTiles** - charge tiles fin niveau |
| $2C | $11C7 | **State2C_SetupCreditsScroll** - config scroll crédits |
| $2D | $1212 | **State2D_DrawCreditsLine** - dessine ligne crédits |
| $2E | $124B | **State2E_WaitCreditsScroll** - attente scroll crédits |
| $2F | $1298 | **State2F_FadeTransition** - transition fondu |
| $30 | $12B9 | **State30_EndingSequence** - séquence fin |
| $31 | $12E8 | **State31_DrawEndingSprites** - sprites fin |
| $32 | $1385 | **State32_ConfigureLYC** - configure LYC pour effets |
| $33 | $13E7 | **State33_DisplayCreditsText** - affiche texte crédits vers VRAM |
| $34 | $1438 | **State34_WaitCreditsCounter** - compteur crédits → timer |
| $35 | $1451 | **State35_WaitTimer** - attente timer simple |
| $36 | $145D | **State36_CreditsFinalTransition** - transition finale crédits |
| $37 | $147F | **State37_FinalSpriteAnimation** - animation sprite finale |
| $38 | $14D3 | **State38_CreditsAnimation** - animation crédits finale |
| $39 | $1C73 | **State39_GameOver** - affiche écran GAME OVER, clear OAM |
| $3A | $1CDF | **State3A_WindowUpdate** - mise à jour window |
| $3B | $1CE7 | **State3B_WindowSetup** - copie données vers window, active |

### Tables de données connues
- [x] `$02A5` (data) - StateJumpTable, 60 entrées × 2 bytes
- [x] `$336C` (data) - AudioConfigTable, 21 sons × 3 bytes
- [x] `$3FAF` (data) - AnimTilesFrames, 10 frames × 8 bytes
- [x] `$0DE4` (data) - GraphicsTableA, 12 bytes (mal désassemblé)
- [x] `$14BB` (data) - TilemapEndData, 24 bytes (mal désassemblé)
- [x] `$1CCE` (data) - TextData_GameOver, 17 bytes (mal désassemblé)

### Routines identifiées
*Toutes analysées et documentées dans le code source*

| Routine | Adresse | Description |
|---------|---------|-------------|
| SystemInit | $0185 | Init système (macros descriptives) |
| GameLoop | $0226 | Boucle principale (7 étapes) |
| WaitVBlank | $0296 | Attente VBlank (halt + flag) |
| StateDispatcher | $02A3 | Dispatch états via RST $28 |
| CheckInputAndPause | $07C3 | Soft reset + toggle pause |
| InitGameState | $09E8 | Init état $03 |
| SimulateRightInput | $0EB2 | Simule input droite joueur |
| ResetPlayerPositionForCutscene | $0EDE | Reset position pour cutscene |
| WriteTextCharacter | $0F81 | Écrit caractère texte vers VRAM |
| CopyOAMData | $1020 | Copie données vers OAM |
| ClearTilemapBuffer | $1655 | Clear zone $c800-$ca3f (576 bytes) |
| UpdatePipeAnimation | $16EC | Animation joueur pendant transition tuyau |
| CallBank3Handler | $172D | Wrapper bank switch |
| UpdateLivesDisplay | $1C2A | BCD vies → tilemap |
| UpdateScrollColumn | $224F | Scrolling colonne tilemap |
| UpdateAnimTiles | $23F8 | Animation eau/lave |
| UpdateLevelScore | $3D61 | Score niveau |
| UpdateScoreDisplay | $3F24 | BCD score → tiles |

---

## Analysé

### Handlers RST ($0000-$0038)
- [x] `$0000` RST $00 - Soft reset → `jp SystemInit`
- [x] `$0008` RST $08 - Soft reset (alias)
- [x] `$0010-$0027` RST $10-$20 - Non utilisés (padding `rst $38`)
- [x] `$0028` **RST $28 - Jump Table Dispatcher** : A*2 → offset, lit adresse, saute
- [x] `$0030` RST $30 - Suite du dispatcher (termine le saut via `jp hl`)
- [x] `$0038` RST $38 - Non utilisé (boucle infinie = trap)

### Interruptions ($0040-$0068)
- [x] `$0040` **VBlankInterrupt** - `jp VBlankHandler` ($0060)
- [x] `$0048` **LCDCInterrupt** - `jp LCDStatHandler` ($0095)
- [x] `$0050` **TimerOverflowInterrupt** - Bank switch vers audio (bank 3)
- [x] `$0058` **SerialTransferCompleteInterrupt** - Restaure bank + reti
- [x] `$0060` **VBlankHandler** - Scroll, vies, score, DMA OAM, frame++, flag
- [x] `$0095` **LCDStatHandler** - Effets scanline (scroll mid-screen, window)

### Entry Point ($0100-$0150)
- [x] `$0100` **Boot** - nop + jp AfterHeader
- [x] `$0104-$014F` **ROM Header** - Logo Nintendo, titre "SUPER MARIOLAND", métadonnées
- [x] `$0150` **AfterHeader** - jp SystemInit

### Tables de données
- [x] `$02A5` (data) - **StateJumpTable** : 60 handlers d'état, format `dw`
- [x] `$336C` (data) - **AudioConfigTable** : 21 configs son × 3 bytes
- [x] `$3FAF` (data) - **AnimTilesFrames** : 10 frames animation tiles
- [x] `$3F87` (data) - **Zone fin bank 0** : 121 bytes données + padding

### Routines principales (18/18)
- [x] `$0185` **SystemInit** - Init LCD, audio, mémoire, variables (macros)
- [x] `$0226` **GameLoop** - Boucle principale : bank3 → timers → state → halt
- [x] `$0296` **WaitVBlank** - Halt + attente flag hVBlankFlag
- [x] `$02A3` **StateDispatcher** - `ldh a, [hGameState]` + `rst $28` + table
- [x] `$07C3` **CheckInputAndPause** - Combo A+B+Start+Select = reset, Start = pause
- [x] `$09E8` **InitGameState** - Configure état $03, reset variables
- [x] `$0EB2` **SimulateRightInput** - Simule input droite pour cutscenes
- [x] `$0EDE` **ResetPlayerPositionForCutscene** - Reset position joueur
- [x] `$0F81` **WriteTextCharacter** - Écrit caractère vers VRAM avec attente STAT
- [x] `$1020` **CopyOAMData** - Copie données sprite vers buffer OAM
- [x] `$1655` **ClearTilemapBuffer** - Clear zone $c800-$ca3f (576 bytes)
- [x] `$16EC` **UpdatePipeAnimation** - Animation joueur pendant transition tuyau
- [x] `$172D` **CallBank3Handler** - Save bank → switch $03 → call $4823 → restore
- [x] `$1C2A` **UpdateLivesDisplay** - Affiche wLivesCounter en BCD sur tilemap
- [x] `$224F` **UpdateScrollColumn** - Met à jour 16 tiles d'une colonne (wScrollBuffer)
- [x] `$23F8` **UpdateAnimTiles** - Copie 8 bytes depuis AnimTilesFrames vers VRAM
- [x] `$3D61` **UpdateLevelScore** - Affiche score niveau si wLevelData == $28
- [x] `$3F24` **UpdateScoreDisplay** - Convertit 3 bytes BCD en 6 tiles avec leading zero suppression

### Handlers d'état analysés (54/60)
*6 états Bank 1 non analysables (zone données)*

#### Gameplay principal ($00-$0D)
- [x] `$0610` État $00 - Main gameplay
- [x] `$06A5` État $01 - Reset objets
- [x] `$06C5` État $02 - Chargement niveau
- [x] `$0B84` État $03 - Setup sprites
- [x] `$0BCD` État $04 - Animation transition
- [x] `$0C6A` État $05 - Niveau spécial
- [x] `$0CC2` État $06 - Post-niveau
- [x] `$0C37` État $07 - Attente timer
- [x] `$0D40` État $08 - Progression
- [x] `$1612` État $09 - Entrée tuyau droite
- [x] `$1626` État $0A - Chargement sous-niveau
- [x] `$1663` État $0B - Descente tuyau
- [x] `$16D1` État $0C - Sortie tuyau gauche
- [x] `$236D` État $0D - Gameplay complet

#### Menu et initialisation ($0E-$11)
- [x] `$0322` État $0E - Init niveau
- [x] `$04C3` État $0F - Menu sélection
- [x] `$05B7` État $10 - Noop
- [x] `$055F` État $11 - Démarrage niveau

#### Écran fin niveau ($12-$13, $16)
- [x] `$3D8E` État $12 - EndLevelSetup
- [x] `$3DCE` État $13 - DrawEndBorder
- [x] `$3E9E` État $16 - CopyTilemapData

#### Bank 1 (non analysables - zone données)
- [ ] `$5832` État $14
- [ ] `$5835` État $15
- [ ] `$5838` État $17
- [ ] `$583B` État $18
- [ ] `$583E` État $19
- [ ] `$5841` État $1A

#### Transitions et bonus ($1B-$28)
- [x] `$0DF0` État $1B - BonusComplete
- [x] `$0E0C` État $1C - WaitTimerGameplay
- [x] `$0E28` État $1D - SetupVRAMPointer
- [x] `$0E54` État $1E - ClearTilemapColumn
- [x] `$0E8D` État $1F - EnableVBlankMode
- [x] `$0EA0` État $20 - WaitPlayerPosition
- [x] `$0EC4` État $21 - SetupEndCutscene
- [x] `$0F09` État $22 - ScrollCutscene
- [x] `$0F2A` État $23 - WalkToDoor
- [x] `$0F61` État $24 - DisplayText
- [x] `$0FF4` État $25 - SpriteBlinkAnimation
- [x] `$104C` État $26 - PrincessRising
- [x] `$1090` État $27 - PlayerOscillation
- [x] `$0EA0` État $28 - (= $20)

#### Crédits et fin de jeu ($29-$38)
- [x] `$110D` État $29 - SetupEndScreen
- [x] `$115C` État $2A - DrawEndBackground
- [x] `$118B` État $2B - LoadEndTiles
- [x] `$11C7` État $2C - SetupCreditsScroll
- [x] `$1212` État $2D - DrawCreditsLine
- [x] `$124B` État $2E - WaitCreditsScroll
- [x] `$1298` État $2F - FadeTransition
- [x] `$12B9` État $30 - EndingSequence
- [x] `$12E8` État $31 - DrawEndingSprites
- [x] `$1385` État $32 - ConfigureLYC
- [x] `$13E7` État $33 - DisplayCreditsText
- [x] `$1438` État $34 - WaitCreditsCounter
- [x] `$1451` État $35 - WaitTimer
- [x] `$145D` État $36 - CreditsFinalTransition
- [x] `$147F` État $37 - FinalSpriteAnimation
- [x] `$14D3` État $38 - CreditsAnimation

#### Game Over et Window ($39-$3B)
- [x] `$1C73` État $39 - GameOver
- [x] `$1CDF` État $3A - WindowUpdate
- [x] `$1CE7` État $3B - WindowSetup

---

## Découvertes

### Patterns identifiés
- `rst $28` : Dispatcher de jump table (lit adresse depuis table suivante)
- `ldh [hGameState], a` + `ret` : Transition d'état
- `call CallBank3_XXXX` : Appel cross-bank vers bank 3
- `ld hl, hGameState` + `inc [hl]` : Transition vers état suivant

### Systèmes découverts

#### Système de tuyaux (pipes) - États $09-$0C
- $09 : Entrée horizontale (joueur avance vers la droite)
- $0A : Chargement sous-niveau (LCD off, clear mémoire, repositionner)
- $0B : Descente verticale + chargement destination
- $0C : Sortie horizontale (joueur recule vers la gauche)
- Utilise hVBlankSelector comme position cible et $fff6/$fff7 pour destination

#### Système de crédits - États $29-$38
- Séquence complexe d'états pour afficher les crédits
- Utilise LYC pour effets de scroll mid-screen
- Tables de texte mal désassemblées ($0FD8, $14BB, etc.)
- Animation finale avec timer et positions tilemap

#### Système d'écran de fin - États $12-$13, $16
- $12 : Prépare l'écran (LCD off, clear)
- $13 : Dessine la bordure décorative
- $16 : Copie les données tilemap depuis WRAM

#### Game Over - États $39-$3B
- $39 : Affiche "GAME OVER", sauvegarde score, clear OAM
- $3A : Mise à jour de la window (effet visuel)
- $3B : Configuration finale de la window

### Zones de données mal désassemblées identifiées
- `$0DE4-$0DEF` : GraphicsTableA/B (12 bytes)
- `$0FD8-$1018` : Tables de texte pour cutscenes
- `$14BB-$14D2` : TilemapEndData (24 bytes)
- `$1CCE-$1CDE` : TextData_GameOver (17 bytes)
- `$5832-$5841` : Zone Bank 1 (handlers $14-$1A - non code)

### Questions résolues
- États $12-$3B : Tous documentés avec rôles identifiés
- Système de crédits : Compris (états $29-$38)
- Game Over : États $39-$3B gèrent l'écran de fin

### Questions ouvertes
- Pourquoi les handlers Bank 1 ($14-$1A) pointent vers une zone données ?
- Organisation précise des niveaux dans les banks
- Localisation des graphiques sprites/backgrounds

---

## Statistiques

| Catégorie | Frontière | Analysé | Total |
|-----------|-----------|---------|-------|
| Handlers RST | 0 | 8 | 8 |
| Interruptions | 0 | 6 | 6 |
| Entry point | 0 | 3 | 3 |
| Handlers état | 6* | 54 | 60 |
| Routines | 0 | 18 | 18 |
| Tables données | 0 | 7 | 7 |
| **Total** | **6** | **96** | **102** |

*Les 6 handlers Bank 1 restants pointent vers des zones données non analysables comme code.

**Progression** : 94% analysé (96/102)
