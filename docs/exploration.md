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
- [ ] `$0610` (handler) - État $00
- [ ] `$06A5` (handler) - État $01
- [ ] `$06C5` (handler) - État $02
- [ ] `$0B84` (handler) - État $03
- [ ] `$0BCD` (handler) - État $04
- [ ] `$0B6A` (handler) - État $05
- [ ] `$0CC2` (handler) - État $06
- [ ] `$0C37` (handler) - État $07
- [ ] `$0C40` (handler) - État $08
- [ ] `$0D12` (handler) - État $09
- [ ] `$1626` (handler) - État $0A
- [ ] `$1663` (handler) - État $0B
- [ ] `$16D1` (handler) - État $0C
- [ ] `$166D` (handler) - État $0D
- [ ] `$2322` (handler) - État $0E
- [ ] `$03C3` (handler) - État $0F
- [ ] `$03DA` (handler) - État $10
- [ ] `$03E5` (handler) - État $11
- [ ] `$0415` (handler) - État $12
- [ ] `$0445` (handler) - État $13
- [ ] `$0475` (handler) - État $14
- [ ] `$04A5` (handler) - État $15
- [ ] `$0F92` (handler) - État $16
- [ ] `$0FCB` (handler) - État $17
- [ ] `$1038` (handler) - État $18
- [ ] `$10F1` (handler) - État $19
- [ ] `$113B` (handler) - État $1A
- [ ] `$11C6` (handler) - État $1B
- [ ] `$125D` (handler) - État $1C
- [ ] `$12F4` (handler) - État $1D
- [ ] `$138B` (handler) - État $1E
- [ ] `$13AB` (handler) - État $1F
- [ ] `$1422` (handler) - État $20
- [ ] `$1499` (handler) - État $21
- [ ] `$1510` (handler) - État $22
- [ ] `$04D5` (handler) - État $23
- [ ] `$050B` (handler) - État $24
- [ ] `$0541` (handler) - État $25
- [ ] `$0577` (handler) - État $26
- [ ] `$05AD` (handler) - État $27
- [ ] `$05E3` (handler) - État $28
- [ ] `$157D` (handler) - État $29
- [ ] `$15EA` (handler) - État $2A
- [ ] `$1719` (handler) - État $2B
- [ ] `$1761` (handler) - État $2C
- [ ] `$17C5` (handler) - État $2D
- [ ] `$1829` (handler) - État $2E
- [ ] `$188D` (handler) - État $2F
- [ ] `$18F1` (handler) - État $30
- [ ] `$1955` (handler) - État $31
- [ ] `$19B9` (handler) - État $32
- [ ] `$1A1D` (handler) - État $33
- [ ] `$1A81` (handler) - État $34
- [ ] `$1AE5` (handler) - État $35
- [ ] `$1B49` (handler) - État $36
- [ ] `$1BAD` (handler) - État $37
- [ ] `$1C11` (handler) - État $38
- [ ] `$1C4F` (handler) - État $39
- [ ] `$1C8D` (handler) - État $3A
- [ ] `$1CE7` (handler) - État $3B

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
