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

## Frontière archivée - Phase 5 (complétée)

### Banks 1-3 - Données et routines secondaires

#### Bank 1 ($4000-$7FFF) - Données niveaux
- [x] `$4000` (data) - **LevelJumpTable_Bank1** : 24 entrées × 2 bytes, pointeurs vers données niveaux
- [x] `$4030` (data) - **TileData_Bank1** : ~4.5KB graphiques 2bpp (mal désassemblé en instructions)
- [x] `$5179` (data) - **LevelData_World4_1** : structure niveau (pointeurs + métadonnées)
- [x] `$5222` (data) - **LevelData_World4_2** : structure niveau
- [x] `$529B` (data) - **LevelData_World4_3** : structure niveau
- [x] `$5311` (data) - **LevelData_Shared_A** : données réutilisées (mondes 3+)
- [x] `$5405` (data) - **LevelData_Shared_B** : données réutilisées (mondes 3+)
- [x] `$54D5` (data) - **LevelData_Bonus** : niveau bonus
- [x] `$55BB` (data) - **LevelData_World1_1** : contient sous-pointeurs ($56CD, $5ABB, etc.)
- [x] `$55E2` (data) - **LevelData_World1_2** : structure niveau
- [x] `$5605` (data) - **LevelData_World1_3** : structure niveau
- [x] `$5630` (data) - **LevelData_World2_1** : structure niveau
- [x] `$5665` (data) - **LevelData_World2_2** : structure niveau
- [x] `$5694` (data) - **LevelData_World2_3** : structure niveau

#### Bank 2 ($4000-$7FFF) - Données niveaux
- [x] `$4000` (data) - **LevelJumpTable_Bank2** : 24 entrées × 2 bytes, pointeurs vers données niveaux
- [x] `$4030` (data) - **TileData_Bank2** : ~8KB graphiques 2bpp (mal désassemblé)
- [x] `$6002` (data) - **LevelData_VariantA** : métadonnées niveau (format: offset + flags)
- [x] `$6073` (data) - **LevelData_VariantB** : métadonnées niveau
- [x] `$6090` (data) - **LevelData_VariantC** : métadonnées niveau
- [x] `$60FE` (data) - **LevelData_VariantD** : métadonnées niveau
- [x] `$6192` (data) - **LevelData_Main2** : sous-pointeurs ($62BE, $6817, etc.)
- [x] `$61B7` (data) - **LevelData_Main2_Alt1** : variante niveau principal
- [x] `$61DA` (data) - **LevelData_Main2_Alt2** : variante niveau principal

#### Bank 3 ($4000-$7FFF) - Audio, joypad et animation
- [x] `$4000` (data) - **LevelJumpTable_Bank3** : 24 entrées × 2 bytes, pointeurs vers données
- [x] `$4030` (data) - **TileData_Bank3** : ~2KB graphiques 2bpp sprites
- [x] `$47F2` (code) - **JoypadReadHandler** : lecture boutons via rP1 ($20=D-pad, $10=buttons)
- [x] `$4823` (code) - **AnimationHandler** : traite structures animation 16 bytes, copie vers HRAM
- [x] `$4C37` (data) - **AnimFrameTable** : ~32 pointeurs vers frames ($4C8D, $4C91, ...)
- [x] `$4E74` (data) - **AudioData_Track1** : données séquenceur audio (notes + durées)
- [x] `$4F1D` (data) - **AudioData_Track2** : données séquenceur audio
- [x] `$4FD8` (data) - **AudioData_Track3** : données séquenceur audio
- [x] `$503F` (data) - **LevelData_Bank3_Main** : sous-pointeurs ($56A5, $5CC2, etc.)
- [x] `$5074` (data) - **LevelData_Bank3_Alt1** : variante niveau
- [x] `$509B` (data) - **LevelData_Bank3_Alt2** : variante niveau
- [x] `$50C0` (data) - **LevelData_Bank3_Variant** : données additionnelles

#### Routines cross-bank identifiées (Bank 0 → Bank X)
- [x] `$172D` → `$4823` Bank 3 - CallBank3Handler (animation)
- [x] `$0226` → `$47F2` Bank 3 - GameLoop appelle JoypadReadHandler

---

## Frontière archivée - Phase 4.5 (complétée)

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
| $14 | $5832 | ⚠️ **Entrée invalide** - pointe vers données tilemap |
| $15 | $5835 | ⚠️ **Entrée invalide** - pointe vers données tilemap |
| $16 | $3E9E | **State16_CopyTilemapData** - copie données vers tilemap |
| $17 | $5838 | ⚠️ **Entrée invalide** - pointe vers données tilemap |
| $18 | $583B | ⚠️ **Entrée invalide** - pointe vers données tilemap |
| $19 | $583E | ⚠️ **Entrée invalide** - pointe vers données tilemap |
| $1A | $5841 | ⚠️ **Entrée invalide** - pointe vers données tilemap |
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

### Handlers d'état analysés (60/60)
*Tous analysés - 6 états Bank 1 pointent vers des données tilemap (entrées invalides)*

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

#### Bank 1 - États invalides ($14-$1A)
- [x] `$5832` État $14 - **Données tilemap** (pas du code - entrée invalide)
- [x] `$5835` État $15 - **Données tilemap** (pas du code - entrée invalide)
- [x] `$5838` État $17 - **Données tilemap** (pas du code - entrée invalide)
- [x] `$583B` État $18 - **Données tilemap** (pas du code - entrée invalide)
- [x] `$583E` État $19 - **Données tilemap** (pas du code - entrée invalide)
- [x] `$5841` État $1A - **Données tilemap** (pas du code - entrée invalide)

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
- **États Bank 1 ($14-$1A)** : Ce sont des entrées invalides dans la StateJumpTable qui pointent vers des données tilemap à $5832-$5841. Ces états ne sont probablement jamais appelés, ou la table originale contient des erreurs/placeholders.

### Questions ouvertes
- ~~Organisation précise des niveaux dans les banks~~ → **Résolu Phase 5** : Jump tables 24×2 bytes à $4000, pointeurs vers données niveau
- ~~Localisation des graphiques sprites/backgrounds~~ → **Résolu Phase 5** : Données tiles 2bpp à $4030 dans chaque bank (~2-8KB)
- Format exact des structures de niveau → **Partiellement compris** : Sous-pointeurs vers données, format à documenter
- ~~Système audio Bank 3~~ → **Résolu Phase 5** : Tables à $4E74, $4F1D, $4FD8 = séquences notes/durées

### Organisation des banks (découverte Phase 4.5 + 5)

| Bank | Début ($4000) | Contenu identifié |
|------|---------------|-------------------|
| Bank 0 | Code | Handlers RST, interruptions, états $00-$0D, $0E-$11, $1B-$3B, routines principales |
| Bank 1 | Données | **LevelJumpTable_Bank1** (24 ptrs) → données niveaux Mondes 1-4 |
| Bank 2 | Données | **LevelJumpTable_Bank2** (24 ptrs) → données niveaux variantes |
| Bank 3 | Données + Code | **LevelJumpTable_Bank3** (24 ptrs) + **JoypadReadHandler** ($47F2) + **AnimationHandler** ($4823) |

### Structure des Level Jump Tables (découverte Phase 5)

Chaque bank contient une table de 24 pointeurs (48 bytes) à $4000 :
- Format : `dw adresse` (little-endian)
- Organisation : répétitions + variantes par mode de jeu

**Bank 1** - Adresses identifiées :
| Index | Adresse | Monde/Niveau |
|-------|---------|--------------|
| $00-$08 | $55BB, $55E2, $5605 | Monde 1 (3× répété) |
| $09-$0B | $5630, $5665, $5694 | Monde 2 |
| $0C | $55BB | Monde 3-1 (= 1-1) |
| $0D-$0F | $5311, $5405, $54D5 | Monde 3 suite |
| $10-$12 | $5179, $5222, $529B | Monde 4 |
| $13-$17 | $5311, $5405, $54D5 | Répétitions |

**Bank 2** - Adresses identifiées :
| Index | Adresse | Description |
|-------|---------|-------------|
| $00-$0B | $6192, $61B7, $61DA | Données principales (4× répété) |
| $0C+ | $6090, $6002, $6073, $60FE | Variantes |

**Bank 3** - Adresses identifiées :
| Index | Adresse | Description |
|-------|---------|-------------|
| $00-$0B | $503F, $5074, $509B | Données principales (4× répété) |
| $0C+ | $50C0, $4E74, $4F1D, $4FD8 | Variantes audio/data |

**Labels non renommés restants** :
- Bank 0 : 44 `Jump_*`, 108 `Call_*`
- Bank 1 : 8 `Jump_*`, 21 `Call_*`
- Bank 2 : 16 `Jump_*`, 16 `Call_*`
- Bank 3 : 26 `Jump_*`, 36 `Call_*`
- **Total** : 94 `Jump_*` + 181 `Call_*` = 275 labels à renommer

---

## Statistiques

### Phase 4.5 (complétée)

| Catégorie | Frontière | Analysé | Total |
|-----------|-----------|---------|-------|
| Handlers RST | 0 | 8 | 8 |
| Interruptions | 0 | 6 | 6 |
| Entry point | 0 | 3 | 3 |
| Handlers état | 0 | 60 | 60 |
| Routines | 0 | 18 | 18 |
| Tables données | 0 | 7 | 7 |
| **Total Phase 4.5** | **0** | **102** | **102** |

**Progression Phase 4.5** : ✅ **100% analysé** (102/102)

*Note : Les 6 états Bank 1 ($14-$1A) pointent vers des données tilemap, pas du code. Ils ont été marqués comme analysés avec cette conclusion.*

### Phase 5 (en cours)

| Catégorie | Frontière | Analysé | Total estimé |
|-----------|-----------|---------|--------------|
| Bank 1 jump table | 0 | 1 | 1 |
| Bank 1 tile data | 0 | 1 | 1 |
| Bank 1 level data | 0 | 12 | 12 |
| Bank 2 jump table | 0 | 1 | 1 |
| Bank 2 tile data | 0 | 1 | 1 |
| Bank 2 level data | 0 | 7 | 7 |
| Bank 3 jump table | 0 | 1 | 1 |
| Bank 3 tile data | 0 | 1 | 1 |
| Bank 3 routines | 0 | 2 | 2 |
| Bank 3 anim/audio | 0 | 7 | 7 |
| Cross-bank calls | 0 | 2 | 2 |
| **Total Phase 5** | **0** | **36** | **36** |

**Progression Phase 5** : ✅ **100%** (36/36 entrées analysées)

#### Routines Bank 3 analysées
- **$47F2 JoypadReadHandler** : Lecture boutons via rP1 ($20 D-pad, $10 buttons), stocke dans hJoypadState/hJoypadDelta
- **$4823 AnimationHandler** : Boucle sur structures animation (16 bytes chacune), copie vers HRAM ($ff86+), utilise AnimFrameTable à $4C37

#### Découvertes Phase 5
- **Banks 1-3** contiennent principalement des données, pas du code
- **Format des banks** : Jump table (48 bytes) + Tiles 2bpp (~2-8KB) + Level data (structures avec sous-pointeurs)
- **Bank 3** contient aussi du code exécutable (JoypadReadHandler, AnimationHandler)
- **Données audio** : Séquences de notes/durées pour le séquenceur audio Game Boy

### Labels non renommés (cible Phase 7)

| Bank | Jump_* | Call_* | Total |
|------|--------|--------|-------|
| Bank 0 | 44 | 108 | 152 |
| Bank 1 | 8 | 21 | 29 |
| Bank 2 | 16 | 16 | 32 |
| Bank 3 | 26 | 36 | 62 |
| **Total** | **94** | **181** | **275** |

---

## Phase 6 : Reconstruction des données (prochaines étapes)

Les Phases 4.5 et 5 couvrent **l'exploration complète** du code. La Phase 6 se concentre sur la reconstruction des zones mal désassemblées.

### 6.1 Reconstruction des données mal désassemblées

**Priorité haute** - Zones identifiées :

| Zone | Bank | Adresse | Type | Statut |
|------|------|---------|------|--------|
| Jump table Bank 1 | 1 | $4000-$402F | `dw` × 24 | À reconstruire |
| Tiles Bank 1 | 1 | $4030-$5178 | INCBIN | À extraire |
| Jump table Bank 2 | 2 | $4000-$402F | `dw` × 24 | À reconstruire |
| Tiles Bank 2 | 2 | $4030-$6001 | INCBIN | À extraire |
| Jump table Bank 3 | 3 | $4000-$402F | `dw` × 24 | À reconstruire |
| Tiles Bank 3 | 3 | $4030-$47F1 | INCBIN | À extraire |
| Texte cutscenes | 0 | $0FD8-$1018 | Texte encodé | À reconstruire |

### 6.2 Renommage systématique des labels

**275 labels** restants à renommer (voir statistiques ci-dessus).

**Méthode** :
1. Identifier les points d'entrée cross-bank (depuis bank 0)
2. Tracer les appels : `call $4xxx` → label en bank active
3. Comprendre la fonction → renommer explicitement

### 6.3 Systèmes à documenter

| Système | Routines clés | Priorité |
|---------|---------------|----------|
| Collision | Non identifiées | Haute |
| Ennemis | $236D (état $0D) appelle multi-bank | Moyenne |
| Niveaux | Banks 1-2 (data), bank 0 (loader) | Moyenne |
| Audio | Bank 3 ($4823+), AudioConfigTable | Basse |

### 6.4 Tâches Phase 6 (suggérées)

```markdown
- [ ] Reconstruire jump tables Banks 1-3 avec `dw`
- [ ] Extraire tiles en fichiers binaires séparés (INCBIN)
- [ ] Documenter format des structures de niveau
- [ ] Renommer les 275 labels Jump_*/Call_* restants
```
