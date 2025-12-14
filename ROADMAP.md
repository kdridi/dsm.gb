# ROADMAP

## Phase 1 : Setup & Validation bit-perfect ✓
*Terminée le 2025-12-13*

- [x] [000001] Créer scripts setup (vérifie/installe rgbds, cross-platform)
- [x] [000002] Stocker hash de référence (SHA256 + MD5)
- [x] [000003] Obtenir les sources ASM initiales
- [x] [000004] Créer Makefile (build + verify) et valider compilation bit-perfect
- [x] [000005] Hook pre-commit pour protection anti-régression

## Phase 2 : Analyse & Documentation (en cours)
*Démarrée le 2025-12-14*

Objectif : comprendre le code via décomposition en "free functions" (macros).

### Terminé ✓

- [x] Identifier le point d'entrée (reset vector) et la boucle principale
- [x] Créer `macros.inc` avec macros utilitaires (CLEAR_LOOP_*, WAIT_LY, etc.)
- [x] Documenter convention "free function" dans CLAUDE.md
- [x] Décomposer SystemInit (Jump_000_0185) en 14 free functions
- [x] Documenter GameLoop (jr_000_0226) - 7 étapes
- [x] Documenter VBlankHandler (JoypadTransitionInterrupt) - 7 étapes
- [x] Documenter routines clés :
  - Call_000_09e8 (InitGameState)
  - Call_000_172d (CallBank3_4823)
  - Call_000_07c3 (CheckInputAndPause)
  - Call_000_02a3 (StateDispatcher + jump table)
  - Call_000_3f24 (UpdateScoreDisplay - BCD→tiles)

- [x] Créer `constants.inc` avec constantes nommées (remplacer magic values)
  - Variables HRAM : hVBlankFlag, hGameState, hShadowSCX, hCurrentBank, etc.
  - Variables WRAM : wUnknownA4, wUnknownA8, wUnknownDC, wUnknownE1
  - Zones mémoire : _VRAM_END, _WRAM_END, _HRAM_END, _OAM_END, _STACK_TOP
  - Config : PALETTE_STANDARD, AUDVOL_MAX, IE_VBLANK_STAT, etc.
- [x] Documenter convention "constantes nommées" dans CLAUDE.md

### À faire

- [x] Documenter routines VBlank restantes :
  - Call_000_224f (UpdateScrollColumn)
  - Call_000_1c2a (UpdateLivesDisplay)
  - Call_000_3d61 (UpdateLevelScore)
  - Call_000_23f8 (UpdateAnimTiles)
- [x] Décoder la jump table StateDispatcher ($02A5) → 60 états identifiés
- [x] Identifier variables HRAM/WRAM → 40+ constantes dans constants.inc

## Phase 3 : Enrichissement (en cours)

Objectif : rendre le code plus lisible sans changer le binaire.

### Terminé ✓

- [x] Créer `constants.inc` avec DEF/EQU pour adresses connues
  - hGameState ($FFB3), hVBlankFlag ($FF85), hCurrentBank ($FFFD), etc.
  - Voir `src/constants.inc` pour liste complète

- [x] Renommer les labels clés → noms explicites :
  - SystemInit, GameLoop, StateDispatcher
  - CheckInputAndPause, InitGameState, CallBank3Handler
  - UpdateScoreDisplay, UpdateScrollColumn, UpdateLivesDisplay
  - UpdateLevelScore, UpdateAnimTiles

- [x] Remplacer toutes les adresses HRAM hex ($FFxx) par constantes nommées
  - 70+ constantes HRAM définies dans `constants.inc`
  - Catégories : Joypad, Timers, Sprites, Audio, État jeu, Pointeurs
  - Exemples : hJoypadState, hTimer1, hSpriteY/X, hSoundId, hGameState

- [x] Renommer hUnknownXX/wUnknownXX → noms explicites (session 2025-12-14)
  - 50+ variables HRAM renommées (hJoypadDelta, hAnimFrameIndex, hAnimObjX/Y, etc.)
  - 20+ variables WRAM renommées (wScoreBCDHigh, wROMBankInit, wStateRender, etc.)
  - Variables audio : hAudioControl, hAudioEnvPos, hAudioEnvDiv, etc.
  - Variables rendu : hRenderContext, hTilemapScrollX/Y, hCurrentTile, etc.

- [x] Définir zones WRAM critiques avec constantes nommées
  - Zone niveau $DA00-$DA29 : wLevelData, wLevelParam03-29, wLivesCounter, etc.
  - Zone état $DFE0-$DFF9 : wStateBuffer, wStateDisplay, wStateRender, etc.
  - Zone complexe $DF00-$DF46 : wComplexState, wComplexState1E, etc.

### À faire

- [ ] Remplacer adresses WRAM restantes en dur ($Cxxx, $Dxxx) - ~170 occurrences
- [ ] Extraire les données en fichiers séparés (si possible bit-perfect)
- [ ] Documenter les structures de données (player, enemies, level)

## Phase 4 : Compréhension approfondie

- [ ] Cartographier les game states ($00-$0E+)
- [ ] Documenter le système de collision
- [ ] Documenter le système de niveau/scrolling
- [ ] Documenter le système audio

## Découvertes

### Variables HRAM identifiées (session 2025-12-14)

Voir `src/constants.inc` pour la liste complète (100+ constantes).

| Catégorie | Constantes clés |
|-----------|-----------------|
| **Joypad** | hJoypadState, hJoypadDelta |
| **Animation** | hAnimFrameIndex, hAnimObjX/Y, hAnimCalcX/Y, hAnimAttr, hAnimHiddenFlag |
| **Animation (suite)** | hAnimStructHigh/Low, hAnimStructBank, hAnimObjSubState, hAnimObjCount |
| **Timers** | hTimer1, hTimer2, hTimerAux, hFrameCounter |
| **Audio** | hAudioControl, hAudioStatus, hAudioEnvPos/Div/Rate/Counter |
| **Rendu** | hRenderContext, hTilemapScrollX/Y, hCurrentTile, hRenderX/Y/Attr/Mode |
| **VBlank/OAM** | hVBlankSelector, hVBlankMode, hDMACounter, hOAMIndex, hOAMAddrLow |
| **État jeu** | hGameState, hSubState, hScoreNeedsUpdate, hUpdateLockFlag |

### Variables WRAM identifiées

| Catégorie | Constantes clés |
|-----------|-----------------|
| **Score** | wScoreBCDHigh, wScoreBCDMid, wScoreBCD, wScorePrevious |
| **Config** | wROMBankInit, wCurrentROMBank, wLevelType, wLevelConfig |
| **Niveau $DA00** | wLevelData, wLevelParam03-29, wLevelDifficulty, wLivesCounter |
| **État $DFE0** | wStateBuffer, wStateDisplay, wStateGraphics, wStateRender |
| **Joueur** | wPlayerY, wPlayerX, wPlayerState, wPlayerDir |
| **Objets** | wObject1-5 (slots de 16 bytes) |
| **Audio** | wAudioQueueType, wAudioQueueId, wAudioState0/1/2 |

### Routines identifiées

| Adresse | Nom proposé | Fonction |
|---------|-------------|----------|
| $0185 | SystemInit | Init complète système |
| $0226 | GameLoop | Boucle principale |
| $0296 | WaitVBlank | Attente frame (halt) |
| $0040 | VBlankHandler | Handler interruption |
| $02A3 | StateDispatcher | Dispatch selon game_state (60 états) |
| $07C3 | CheckInputAndPause | Soft reset + pause |
| $09E8 | InitGameState | Init état $03 |
| $172D | CallBank3_4823 | Wrapper bank switch |
| $1C2A | UpdateLivesDisplay | Mise à jour vies (BCD) |
| $224F | UpdateScrollColumn | Scrolling vertical tilemap |
| $23F8 | UpdateAnimTiles | Animation eau/lave |
| $3D61 | UpdateLevelScore | Affichage score niveau |
| $3F24 | UpdateScoreDisplay | Score BCD→tilemap |
