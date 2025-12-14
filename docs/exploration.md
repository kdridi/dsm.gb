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
- [ ] `$0040` (handler) - VBlank interrupt
- [ ] `$0048` (handler) - STAT interrupt
- [ ] `$0100` (code) - Entry point ROM

### Handlers d'état (depuis StateJumpTable $02A5)
*Adresses corrigées depuis le code source*

| État | Adresse | Rôle supposé |
|------|---------|--------------|
| $00 | $0610 | ? (init/menu) |
| $01 | $06A5 | ? |
| $02 | $06C5 | ? |
| $03 | $0B84 | ? |
| $04 | $0BCD | ? |
| $05 | $0C6A | ? |
| $06 | $0CC2 | ? |
| $07 | $0C37 | ? |
| $08 | $0D40 | ? |
| $09 | $1612 | ? |
| $0A | $1626 | ? |
| $0B | $1663 | ? |
| $0C | $16D1 | ? |
| $0D | $236D | ? |
| $0E | $0322 | **Init niveau** (INIT_GAME_STATE) |
| $0F | $04C3 | ? |
| $10 | $05B7 | ? |
| $11 | $055F | ? |
| $12 | $3D8E | ? |
| $13 | $3DCE | ? |
| $14 | $5832 | Bank 1 |
| $15 | $5835 | Bank 1 |
| $16 | $3E9E | ? |
| $17 | $5838 | Bank 1 |
| $18 | $583B | Bank 1 |
| $19 | $583E | Bank 1 |
| $1A | $5841 | Bank 1 |
| $1B | $0DF0 | ? |
| $1C | $0E0C | ? |
| $1D | $0E28 | ? |
| $1E | $0E54 | ? |
| $1F | $0E8D | ? |
| $20 | $0EA0 | ? |
| $21 | $0EC4 | ? |
| $22 | $0F09 | ? |
| $23 | $0F2A | ? |
| $24 | $0F61 | ? |
| $25 | $0FF4 | ? |
| $26 | $104C | ? |
| $27 | $1090 | ? |
| $28 | $0EA0 | ? (même que $20) |
| $29 | $110D | ? |
| $2A | $115C | ? |
| $2B | $118B | ? |
| $2C | $11C7 | ? |
| $2D | $1212 | ? |
| $2E | $124B | ? |
| $2F | $1298 | ? |
| $30 | $12B9 | ? |
| $31 | $12E8 | ? |
| $32 | $1385 | ? |
| $33 | $13E7 | ? |
| $34 | $1438 | ? |
| $35 | $1451 | ? |
| $36 | $145D | ? |
| $37 | $147F | ? |
| $38 | $14D3 | ? |
| $39 | $1C73 | **Game over** |
| $3A | $1CDF | **État spécial window** |
| $3B | $1CE7 | ? |

### Tables de données connues
- [x] `$02A5` (data) - StateJumpTable, 60 entrées × 2 bytes
- [x] `$336C` (data) - AudioConfigTable, 21 sons × 3 bytes
- [x] `$3FAF` (data) - AnimTilesFrames, 10 frames × 8 bytes

### Routines identifiées (à approfondir)
- [ ] `$0185` (code) - SystemInit, initialisation système
- [ ] `$0226` (code) - GameLoop, boucle principale
- [ ] `$0296` (code) - WaitVBlank, attente frame
- [ ] `$02A3` (code) - StateDispatcher, dispatch états
- [ ] `$07C3` (code) - CheckInputAndPause, gestion pause
- [ ] `$09E8` (code) - InitGameState, init état $03
- [ ] `$172D` (code) - CallBank3_4823, wrapper bank switch
- [ ] `$1C2A` (code) - UpdateLivesDisplay, affichage vies
- [ ] `$224F` (code) - UpdateScrollColumn, scrolling tilemap
- [ ] `$23F8` (code) - UpdateAnimTiles, animation eau/lave
- [ ] `$3D61` (code) - UpdateLevelScore, score niveau
- [ ] `$3F24` (code) - UpdateScoreDisplay, score BCD→tilemap

---

## Analysé

### Handlers RST ($0000-$0038)
- [x] `$0000` RST $00 - Soft reset → `jp SystemInit`
- [x] `$0008` RST $08 - Soft reset (alias)
- [x] `$0010-$0027` RST $10-$20 - Non utilisés (padding `rst $38`)
- [x] `$0028` **RST $28 - Jump Table Dispatcher** : A*2 → offset, lit adresse, saute
- [x] `$0030` RST $30 - Suite du dispatcher (termine le saut via `jp hl`)
- [x] `$0038` RST $38 - Non utilisé (boucle infinie = trap)

### Tables de données
- [x] `$02A5` (data) - **StateJumpTable** : 60 handlers d'état, format `dw`
- [x] `$336C` (data) - **AudioConfigTable** : 21 configs son × 3 bytes
- [x] `$3FAF` (data) - **AnimTilesFrames** : 10 frames animation tiles
- [x] `$3F87` (data) - **Zone fin bank 0** : 121 bytes données + padding

---

## Découvertes

### Patterns identifiés
- `rst $28` : Dispatcher de jump table (lit adresse depuis table suivante)
- `ldh [hGameState], a` + `ret` : Transition d'état
- `call CallBank3_XXXX` : Appel cross-bank vers bank 3

### Questions ouvertes
- Quel état correspond à quoi ? (menu, jeu, pause, game over...)
- Comment sont organisés les niveaux ?
- Où sont les graphiques des sprites/backgrounds ?

---

## Statistiques

| Catégorie | Frontière | Analysé | Total |
|-----------|-----------|---------|-------|
| Handlers RST | 0 | 8 | 8 |
| Interruptions | 3 | 0 | 3 |
| Handlers état | 60 | 0 | 60 |
| Routines | 12 | 0 | 12 |
| Tables données | 0 | 4 | 4 |
| **Total** | **75** | **12** | **87** |
