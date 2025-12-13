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

### À faire

- [ ] Documenter routines VBlank restantes :
  - Call_000_224f (UpdateGameLogic début)
  - Call_000_1c2a (UpdateGameLogic suite)
  - Call_000_3d61 (routine VBlank)
  - Call_000_23f8 (routine VBlank)
- [ ] Décoder la jump table StateDispatcher ($02A5) → identifier les handlers d'état
- [ ] Identifier et nommer les variables HRAM ($FFxx)
- [ ] Identifier et nommer les variables WRAM ($C0xx, $D0xx)

## Phase 3 : Enrichissement

Objectif : rendre le code plus lisible sans changer le binaire.

- [ ] Renommer les labels `Jump_000_XXXX` → noms explicites
- [ ] Créer des DEF/EQU pour les adresses connues :
  - `DEF game_state EQU $FFB3`
  - `DEF frame_ready EQU $FF85`
  - `DEF player_data EQU $C200`
- [ ] Extraire les données en fichiers séparés (si possible bit-perfect)
- [ ] Documenter les structures de données (player, enemies, level)

## Phase 4 : Compréhension approfondie

- [ ] Cartographier les game states ($00-$0E+)
- [ ] Documenter le système de collision
- [ ] Documenter le système de niveau/scrolling
- [ ] Documenter le système audio

## Découvertes

### Variables identifiées

| Adresse | Nom proposé | Usage |
|---------|-------------|-------|
| $FFB3 | game_state | État du jeu (0-$0E+) |
| $FF85 | frame_ready | Flag VBlank→GameLoop |
| $FFAC | frame_counter | Compteur de frames |
| $FFB2 | pause_flag | 0=normal, 1=pause |
| $FFFD | current_bank | Bank ROM courante |
| $FFE1 | saved_bank | Bank sauvegardée (temp) |
| $FFA4 | scx_shadow | Shadow register SCX |
| $C200 | player_data | Données joueur (struct) |
| $C0A2 | score_bcd | Score en BCD (3 octets) |
| $DA1D | special_state | Trigger état spécial |

### Routines identifiées

| Adresse | Nom proposé | Fonction |
|---------|-------------|----------|
| $0185 | SystemInit | Init complète système |
| $0226 | GameLoop | Boucle principale |
| $0296 | WaitVBlank | Attente frame (halt) |
| $0040 | VBlankHandler | Handler interruption |
| $02A3 | StateDispatcher | Dispatch selon game_state |
| $07C3 | CheckInputAndPause | Soft reset + pause |
| $09E8 | InitGameState | Init état $03 |
| $172D | CallBank3_4823 | Wrapper bank switch |
| $3F24 | UpdateScoreDisplay | Score BCD→tilemap |
