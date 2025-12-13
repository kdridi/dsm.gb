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
- [ ] Identifier variables HRAM/WRAM restantes (hUnknownXX → noms explicites)

## Phase 3 : Enrichissement (en cours)

Objectif : rendre le code plus lisible sans changer le binaire.

### Terminé ✓

- [x] Créer `constants.inc` avec DEF/EQU pour adresses connues
  - hGameState ($FFB3), hVBlankFlag ($FF85), hCurrentBank ($FFFD), etc.
  - Voir `src/constants.inc` pour liste complète

### À faire

- [ ] Renommer les labels `Jump_000_XXXX` → noms explicites
- [ ] Renommer hUnknownXX/wUnknownXX → noms explicites (reverse engineering)
- [ ] Extraire les données en fichiers séparés (si possible bit-perfect)
- [ ] Documenter les structures de données (player, enemies, level)

## Phase 4 : Compréhension approfondie

- [ ] Cartographier les game states ($00-$0E+)
- [ ] Documenter le système de collision
- [ ] Documenter le système de niveau/scrolling
- [ ] Documenter le système audio

## Découvertes

### Variables identifiées (dans constants.inc)

| Adresse | Constante | Usage |
|---------|-----------|-------|
| $FF85 | `hVBlankFlag` | Flag VBlank→GameLoop |
| $FF9A | `hUnknown9A` | À identifier |
| $FFA4 | `hShadowSCX` | Shadow register SCX |
| $FFB3 | `hGameState` | État du jeu (0-$0E+) |
| $FFB4 | `hUnknownB4` | À identifier ($11 init) |
| $FFB6 | `hDmaRoutine` | Routine DMA copiée |
| $FFE4 | `hUnknownE4` | À identifier |
| $FFFD | `hCurrentBank` | Bank ROM courante |
| $C0A4 | `wUnknownA4` | À identifier ($03 init) |
| $C0A8 | `wUnknownA8` | À identifier ($11 init) |
| $C0DC | `wUnknownDC` | À identifier ($02 init) |
| $C0E1 | `wUnknownE1` | À identifier |

### Variables ajoutées (session 2025-12-14)

| Adresse | Constante | Usage |
|---------|-----------|-------|
| $FF9F | `hUnknown9F` | Flag bloquant mise à jour |
| $FFAC | `hFrameCounter` | Compteur de frames |
| $FFB2 | `hPauseFlag` | 0=normal, 1=pause |
| $FFE1 | `hSavedBank` | Bank sauvegardée (temp) |
| $FFE9 | `hScrollColumn` | Colonne courante scrolling |
| $FFEA | `hScrollPhase` | Phase mise à jour tilemap |
| $C0A2 | `wScoreBCD` | Score en BCD (3 octets) |
| $C0A3 | `wUpdateCounter` | Flag mise à jour compteur |
| $C0B0 | `wScrollBuffer` | Buffer colonne tilemap |
| $C200 | `wPlayerData` | Données joueur (struct) |
| $C600 | `wAnimBuffer` | Buffer animation |
| $D014 | `wAnimFlag` | Flag animation active |
| $DA00 | `wLevelData` | Données niveau (BCD) |
| $DA15 | `wLivesCounter` | Compteur vies/niveau |
| $DA1D | `wSpecialState` | Trigger état spécial |

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
