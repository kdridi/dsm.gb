# ROADMAP - Reverse Engineering Complet

**Objectif** : Comprendre 100% du code, le documenter de manière compréhensible, et transformer le désassemblage brut en code source lisible et maintenable.

**Progression globale** : ~50% (estimé - Phases 1-5 complétées)

---

## Phase 1 : Setup & Validation bit-perfect ✅
*Terminée le 2025-12-13*

- [x] Créer scripts setup (vérifie/installe rgbds, cross-platform)
- [x] Stocker hash de référence (SHA256 + MD5)
- [x] Obtenir les sources ASM initiales
- [x] Créer Makefile (build + verify) et valider compilation bit-perfect
- [x] Hook pre-commit pour protection anti-régression

---

## Phase 2 : Analyse initiale ✅
*Terminée le 2025-12-14*

- [x] Identifier le point d'entrée et la boucle principale
- [x] Créer `macros.inc` avec macros utilitaires
- [x] Décomposer SystemInit en 14 free functions
- [x] Documenter GameLoop, VBlankHandler
- [x] Documenter routines clés (StateDispatcher, UpdateScoreDisplay, etc.)
- [x] Créer `constants.inc` avec constantes de base

---

## Phase 3 : Nommage & Constantes ✅
*Terminée le 2025-12-14*

- [x] Renommer les labels clés → noms explicites (11 routines)
- [x] Remplacer adresses HRAM hex → 100+ constantes nommées
- [x] Renommer hUnknownXX/wUnknownXX → 70+ noms explicites
- [x] Définir zones WRAM critiques ($DA00, $DFE0, $DF00)

---

## Phase 4 : Élimination des magic values (en cours)

**Objectif** : Zéro adresse en dur dans le code - tout via constantes nommées.

### 4.1 Adresses WRAM restantes ✅

| Zone | Occurrences | Priorité | Status |
|------|-------------|----------|--------|
| $DFE0-$DFF9 (état jeu) | 0 | - | ✅ FAIT |
| $DA00-$DA29 (niveau) | 0 | - | ✅ FAIT |
| $C200-$C248 (joueur/objets) | 0 | - | ✅ FAIT |
| $C0xx (variables jeu) | 0 | - | ✅ FAIT |
| $D0xx (extended WRAM) | 0 | - | ✅ FAIT |

### 4.2 Données statiques (tables ROM) ✅

- [x] Table d'animation ($3FAF) → ROM_ANIM_TILES
- [x] Table audio ($336C) → ROM_AUDIO_CONFIG
- [x] Données de style ($030C, $0734, $0B5C, etc.) → ROM_STYLE_LVL_*
- [x] Tilemaps initiaux ($0783) → ROM_TILEMAP_INIT
- [x] Adresses VRAM HUD ($9806, $9820, $9829, $95D1) → VRAM_*
- [ ] Table de jump StateDispatcher ($02A5) → mal désassemblée, à traiter séparément

### 4.3 Constantes hardware manquantes ✅

- [x] Adresses tilemap HUD ($9806, $9820, $9829) → VRAM_SCORE_POS1/2, VRAM_HUD_LINE
- [x] Adresses tiles spécifiques ($95D1) → VRAM_ANIM_DEST

### 4.4 Reconstruction des zones de données (en cours - Découverte 2025-12-14)

**Problème** : Le désassembleur a interprété les données comme du code.

**Technique** : Utiliser `xxd -s ADDR -l LEN src/game.gb` pour voir les données brutes.

**Zones identifiées** :
- [x] Jump table StateDispatcher ($02A5, 120 octets) → 60 × `dw`
- [x] Table audio ($336C, 63 octets) → 21 × `db` (AudioConfigTable)
- [x] Tables animation ($3FAF, 80 octets) → 10 frames × 8 octets (AnimTilesFrames)
- [x] Zone fin de bank 0 ($3F87-$3FFF, 121 octets) → données + animation + padding
- [ ] Graphiques/tilemaps (autres banks) → à identifier
- [x] Autres jump tables après `rst $28` → aucune autre trouvée (326 occurrences analysées)

**Zone en cours (nouvelle)** : $3100-$37FF (environ 1.8 KB)
- **Contenu** : Jump dispatch tables + data tables + audio/animation data
- **Labels trouvés** : 14 `jr_000_XXXX` + 2 `Call_000_XXXX` dans cette région
- **État** : À restructurer avec `db`/`dw` (voir tâche Phase 4.4.1 ci-dessous)
- **Raison** : Patterns indicatifs de données mal désassemblées :
  - Séquences `jr c, jr_000_XXXX` (jump dispatch)
  - Séquences `ld [hl], $XX` (tables de constantes)
  - `scf` répétés (séparateurs de données)
  - Références internes entre labels
  - Aucun appel depuis du vrai code (bank_001/002)

**Objectif** : Remplacer les instructions absurdes par des directives `db`/`dw`/`INCBIN`.

### 4.4.1 Analyse détaillée zone $3100-$37FF ✅

**Complété le 2025-12-14** :
- ✅ Tous les 36 labels `jr_000_XXXX` + `Call_000_XXXX` ont été renommés
- ✅ Région $3300-$37FF : Jump dispatch table pour animations/sons
- Sous-zones identifiées :
  - $3434-$354b : État du dispatch (10 entrées) → renommées
  - $349f-$34e4 : Jump table de sélection (8 entrées) → renommées
  - $3528-$30ec : Données de saut/états audio → renommées
  - $3690, $3755 : Tables audio (avec `rst $28` markers) → renommées
  - $3132 : Table de données (répétitions `ld l, $XX`) → renommées

**Résultat** : Zone $3100-$37FF entièrement renommée avec noms contextuels explicites

### 4.5 Protocole d'exploration systématique ✅

**Fichier** : `docs/exploration.md`

**Méthode** : Parcours de graphe - chaque adresse analysée révèle de nouvelles adresses.

**État** : ✅ COMPLET (102/102 entrées analysées)
- [x] Créer `docs/exploration.md` avec protocole documenté
- [x] Initialiser la frontière (80 points d'entrée)
- [x] Analyser les 8 handlers RST ($0000-$0038)
- [x] Analyser les 60 handlers d'état (StateJumpTable)
- [x] Analyser les 18 routines identifiées
- [x] Itérer jusqu'à couverture complète

**Découverte** : 6 états Bank 1 ($14-$1A) pointent vers des données tilemap, pas du code (entrées invalides dans StateJumpTable).

### 4.6 Carte mémoire ROM (optionnel)

- [ ] Créer `docs/memory-map.md` avec schéma visuel (généré depuis exploration)

### 4.7 Extraction graphiques (optionnel, futur)

- [ ] Localiser les blocs de tiles dans la ROM
- [ ] Extraire en fichiers `.2bpp` ou `.png`
- [ ] Documenter le mapping tiles ↔ sprites/backgrounds

---

## Phase 5 : Exploration Banks 1-3 ✅
*Terminée le 2025-12-14*

**Objectif** : Explorer et documenter les banks de données (Banks 1-3).

**État** : ✅ COMPLET (36/36 entrées analysées dans `docs/exploration.md`)

### 5.1 Résultats Banks 1-3

| Bank | Contenu identifié |
|------|-------------------|
| Bank 1 | LevelJumpTable (24 ptrs) + TileData (~4.5KB 2bpp) + LevelData (Mondes 1-4) |
| Bank 2 | LevelJumpTable (24 ptrs) + TileData (~8KB 2bpp) + LevelData (variantes) |
| Bank 3 | LevelJumpTable (24 ptrs) + TileData (~2KB 2bpp) + JoypadReadHandler + AnimationHandler + AudioData |

### 5.2 Découvertes clés

- **Format des banks** : Jump table (48 bytes à $4000) + Tiles 2bpp + Level data
- **Bank 3** contient du code exécutable (JoypadReadHandler $47F2, AnimationHandler $4823)
- **Données audio** : Tables $4E74, $4F1D, $4FD8 = séquences notes/durées
- **275 labels** restants à renommer (94 `Jump_*` + 181 `Call_*`)

---

## Phase 5b : Documentation des structures (en cours)

**Objectif** : Comprendre toutes les structures de données du jeu.

**Note** : Ces tâches seront complétées via le protocole d'exploration.

### 5b.1 Structure Joueur ($C200, 20 bytes)

- [x] Définir constantes de base (wPlayerY, wPlayerX, wPlayerState, wPlayerDir)
- [ ] Comprendre les variables wPlayerUnk05/07/0B/0C/0E/10/13
- [ ] Créer macros RSRESET pour offsets structurés

### 5b.2 Structure Objets ($C208-$C248, 5 slots × 16 bytes)

- [x] Définir constantes slots (wObject1-5, OBJECT_SLOT_SIZE)
- [ ] Documenter les 16 bytes de chaque slot (offsets internes)
- [ ] Comprendre le système d'activation (bit 7)
- [ ] Identifier les types d'objets

### 5b.3 Buffer OAM ($C000, 160 bytes)

- [x] Définir constante de base (wOamBuffer)
- [ ] Documenter l'usage des 40 sprites
- [ ] Comprendre l'allocation dynamique

### 5b.4 Zone Niveau ($DA00-$DA29)

- [x] Définir constantes (wLevelData, wLevelParam03-29, wLivesCounter, etc.)
- [ ] Identifier le rôle de chaque wLevelParam* (reverse engineering)
- [ ] Comprendre le format des données de niveau

### 5b.5 Buffer État ($DFE0-$DFF9)

- [x] Définir constantes (wStateBuffer, wStateDisplay, wStateRender, etc.)
- [ ] Identifier le rôle de chaque wState* (reverse engineering)
- [ ] Comprendre les transitions d'état

---

## Phase 6 : Documentation des systèmes

**Objectif** : Comprendre la logique métier du jeu.

### 6.1 Système de Game States (60 états)

- [ ] Cartographier les 60 états du StateDispatcher
- [ ] Documenter les transitions entre états
- [ ] Identifier les états : menu, jeu, pause, game over, etc.
- [ ] Créer un diagramme d'états

### 6.2 Système de Collision

- [ ] Identifier les routines de collision
- [ ] Comprendre les hitboxes joueur/ennemis
- [ ] Documenter les types de collision (sol, mur, ennemi, bonus)

### 6.3 Système de Scrolling

- [ ] Comprendre UpdateScrollColumn
- [ ] Documenter le système de tilemap dynamique
- [ ] Analyser le chargement de niveau

### 6.4 Système Audio

- [ ] Documenter les 4 canaux (NR10-NR44)
- [ ] Comprendre les enveloppes (hAudioEnv*)
- [ ] Identifier tous les sons/musiques
- [ ] Documenter le système de queue audio

### 6.5 Système d'Animation

- [ ] Comprendre hAnimFrameIndex, hAnimObjX/Y
- [ ] Documenter les frames d'animation joueur
- [ ] Documenter les animations d'objets

---

## Phase 7 : Renommage des labels

**Objectif** : Tous les labels Jump_XXX/Call_XXX → noms explicites.

### Status: 7.0 - Labels Call_000_XXXX / jr_000_XXXX ✅
*Analysé le 2025-12-15*

- [x] Audit complet des labels `Call_000_XXXX` et `jr_000_XXXX`
- [x] Découverte: Tous renommés (1200+ labels, 5 commits précédents)
- [x] Stratégie confirmée: `jr_*` → `SkipPadding_*` → `UnknownCode_*` (progressive)
- [x] 376 `UnknownCode_*` restants (Banks 002/003) = padding/données désassemblées
- [x] Compilation: HASH VERIFIED ✅

**Détails** : Voir `analysis-session-20251215.md`

**Prochaines étapes** : Phase 5b/6 (exploration progressive, non urgent)

### Bank 0 (~500 labels)

- [ ] Routines d'init (SystemInit fait)
- [ ] Routines de jeu
- [ ] Routines audio
- [ ] Routines d'affichage

### Bank 1 (~400 labels)

- [ ] Identifier le contenu principal
- [ ] Renommer les routines clés

### Bank 2 (~400 labels)

- [ ] Identifier le contenu principal
- [ ] Renommer les routines clés

### Bank 3 (~400 labels)

- [ ] Routines audio (identifiées)
- [ ] Renommer les routines clés

---

## Phase 8 : Extraction et organisation

**Objectif** : Code modulaire et organisé.

- [ ] Extraire les données en fichiers séparés (data/*.asm)
- [ ] Séparer les routines par fonction (audio.asm, collision.asm, etc.)
- [ ] Créer un fichier de constantes par catégorie si nécessaire
- [ ] Vérifier bit-perfect après chaque extraction

---

## Phase 9 : Documentation finale

**Objectif** : Documentation complète et publiable.

- [ ] Créer docs/memory-map.md (schéma mémoire complet)
- [ ] Créer docs/game-states.md (diagramme d'états)
- [ ] Créer docs/data-structures.md (structures détaillées)
- [ ] Créer docs/audio-system.md (système audio)
- [ ] Créer docs/technical-notes.md (astuces, optimisations)
- [ ] README.md complet avec guide de contribution

---

## Phase 10 : Au-delà (futur)

*À faire après reverse engineering complet*

- [ ] Créer un éditeur de niveau
- [ ] Ajouter des features (sauvegarde, nouveaux niveaux)
- [ ] Port vers autre plateforme
- [ ] Tutoriel "Comprendre un jeu Game Boy"

---

## Métriques de progression

| Catégorie | Fait | Total | % |
|-----------|------|-------|---|
| Constantes HRAM | 100+ | ~120 | 85% |
| Constantes WRAM | 130+ | ~200 | 65% |
| Constantes ROM/VRAM | 13 | ~15 | 87% |
| Adresses WRAM en dur éliminées | ~220 | ~220 | 100% |
| Labels renommés | ~15 | ~1700 | 1% |
| Routines documentées | 18 | ~200 | 9% |
| Structures définies | 5 | 5 | 100% |
| Structures comprises | 0 | 5 | 0% |
| Systèmes documentés | 2 | 5 | 40% |
| Exploration Phase 4.5 (Bank 0) | 102 | 102 | 100% |
| Exploration Phase 5 (Banks 1-3) | 36 | 36 | 100% |

*Notes:*
- *Phase 4.5 terminée : 60 handlers d'état, 18 routines, 8 handlers RST documentés.*
- *Phase 5 terminée : Banks 1-3 explorées, jump tables, tiles, level data, routines audio/joypad identifiées.*
- *275 labels Jump_*/Call_* restants à renommer (Phase 7).*

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
| **VBlank/OAM** | hVBlankSelector, hVBlankMode, hCoinCount, hOAMIndex, hOAMAddrLow |
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
