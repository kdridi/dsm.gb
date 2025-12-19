Consulte le [script]("../scripts/bfs_explorer.py") qui a permis de générer ces informations

Je souhaite pouvoir améliorer ce script en te laissant constater les résultats qu'il a  produit

Voici le commentaire git
<CommentaireGit>
[BFS-5BA3] Tile data référencée par map
</CommentaireGit>

Le diff git
<DiffGit>
diff --git a/scripts/bfs_state.json b/scripts/bfs_state.json
index 5d01efe..4edcf8f 100644
--- a/scripts/bfs_state.json
+++ b/scripts/bfs_state.json
@@ -5664,6 +5664,14 @@
       "bank": 0,
       "priority": 3
     },
+    {
+      "address": "$DA1C",
+      "node_type": "data",
+      "description": "Flag d'\u00e9tat animation sprite",
+      "source": "$5B58",
+      "bank": 0,
+      "priority": 3
+    },
     {
       "address": "$DFE0",
       "node_type": "data",
@@ -5672,6 +5680,14 @@
       "bank": 0,
       "priority": 3
     },
+    {
+      "address": "$DFE8",
+      "node_type": "data",
+      "description": "Valeur d'initialisation animation",
+      "source": "$5B58",
+      "bank": 0,
+      "priority": 3
+    },
     {
       "address": "$F6FE",
       "node_type": "data",
@@ -5751,22 +5767,6 @@
       "source": "$0095",
       "bank": 0,
       "priority": 3
-    },
-    {
-      "address": "$DA1C",
-      "node_type": "data",
-      "description": "Flag d'\u00e9tat animation sprite",
-      "source": "$5B58",
-      "bank": 0,
-      "priority": 3
-    },
-    {
-      "address": "$DFE8",
-      "node_type": "data",
-      "description": "Valeur d'initialisation animation",
-      "source": "$5B58",
-      "bank": 0,
-      "priority": 3
     }
   ],
   "visited": [
@@ -5853,6 +5853,7 @@
     "$2D41",
     "$2d1c",
     "$1a8a",
+    "$5BA3",
     "$4D56",
     "$0E0C",
     "$1C49",
@@ -6395,6 +6396,6 @@
     "$24e6",
     "$2D7F"
   ],
-  "commits_since_push": 3,
-  "total_explored": 624
+  "commits_since_push": 4,
+  "total_explored": 625
 }
\ No newline at end of file
diff --git a/src/bank_001.asm b/src/bank_001.asm
index 3d6677e..26ce81b 100644
--- a/src/bank_001.asm
+++ b/src/bank_001.asm
@@ -3393,7 +3393,7 @@ SharedTilesetData_024:
 ; Référencé par: LevelJumpTable niveaux 0, 1, 2 (lignes 12, 14, 16)
 ; ==============================================================================
 SharedMapData_012:
-    dw $56CD, TileGraphic_5ABB, $6048, $5BA3, $5C22, $5CA6, $5D32, $5D8A
+    dw $56CD, TileGraphic_5ABB, $6048, MapTileData_5BA3, $5C22, $5CA6, $5D32, $5D8A
     dw $5E32, $5E32, $5E32, $5F44, $5F44, $5D32, $5FAD, $5CA6
     dw $5A5F
     db $FF  ; Terminateur
@@ -4425,114 +4425,30 @@ ProcessLevelData_5b49:
     ld a, a
     ld a, a
     ld a, a
-    cp $f1
-    ld e, l
-    cp $f1
-    ld e, l
-    cp $e2
-    ld h, l
-    ld e, l
-    cp $42
-    add hl, sp
-    dec a
-    ldh [c], a
-    ld h, [hl]
-    ld e, l
-    cp $24
-    inc sp
-    ld [hl], $3a
-    ld a, $e2
-    ld h, l
-    ld e, l
-    cp $2e
-    inc [hl]
-    scf
-    ld b, c
-    ld e, b
-    ld e, c
-    ld e, c
-    ld e, c
-    ld e, c
-    ld e, c
-    ld e, c
-    ld e, c
-    ld e, c
-    ld h, [hl]
-    ld e, l
-    cp $24
-    dec [hl]
-    jr c, DataZone_5c0c
-
-    ccf
-    ldh [c], a
-    ld h, l
-    ld e, l
-    cp $42
-    inc a
-    ld b, b
-    ldh [c], a
-    ld h, [hl]
-    ld e, l
-    cp $e2
-    ld h, l
-    ld e, l
-    cp $e2
-    ld h, [hl]
-    ld e, l
-    cp $e2
-    ld h, l
-    ld e, l
-    cp $e2
-    ld h, [hl]
-    ld e, l
-    cp $e2
-    ld h, l
-    ld e, l
-    cp $21
-    ld b, l
-    ldh [c], a
-    ld h, [hl]
-    ld e, l
-    cp $12
-    ld b, d
-    ld b, [hl]
-    ldh [c], a
-    ld h, l
-    ld e, l
-    cp $12
-    ld b, e
-    ld b, a
-    ldh [c], a
-    ld h, [hl]
-    ld e, l
-    cp $12
-    ld b, h
-    ld c, b
-    or l
-    ld h, a
-    ld l, c
-    ld h, a
+    db $FE  ; Dernier byte de ProcessLevelData_5b49 ($5BA2)
 
-DataZone_5c0c:
-    ld l, c
-    ld e, l
-    cp $b5
-    ld l, b
-    ld l, d
-    ld l, b
-    ld l, d
-    ld e, l
-    cp $b2
-    ld h, a
-    ld l, c
-    pop af
-    ld e, l
-    cp $b2
-    ld l, b
-    ld l, d
-    pop af
-    ld e, l
-    cp $b2
+; ==============================================================================
+; MapTileData_5BA3 - Données de map encodées ($5BA3-$5C21)
+; ==============================================================================
+; Description: Données de tiles/map encodées, utilisées pour construire le layout
+; Format: Séquence de bytes encodés (opcodes de compression/repeat + paramètres)
+;         Pattern: $FE = commande, $F1/$E2/$5D = fin/séparateur, autres = données
+; Taille: 127 octets ($7F)
+; Référencé par: SharedMapData_012 (ligne 3396) - niveaux 0, 1, 2
+; ==============================================================================
+MapTileData_5BA3:  ; $5BA3
+    db $F1, $5D, $FE, $F1, $5D, $FE, $E2, $65, $5D, $FE, $42, $39, $3D, $E2, $66, $5D
+    db $FE, $24, $33, $36, $3A, $3E, $E2, $65, $5D, $FE, $2E, $34, $37, $41, $58, $59
+    db $59, $59, $59, $59, $59, $59, $59, $66, $5D, $FE, $24, $35, $38, $3B, $3F, $E2
+    db $65, $5D, $FE, $42, $3C, $40, $E2, $66, $5D, $FE, $E2, $65, $5D, $FE, $E2, $66
+    db $5D, $FE, $E2, $65, $5D, $FE, $E2, $66, $5D, $FE, $E2, $65, $5D, $FE, $21, $45
+    db $E2, $66, $5D, $FE, $12, $42, $46, $E2, $65, $5D, $FE, $12, $43, $47, $E2, $66
+    db $5D, $FE, $12, $44, $48, $B5, $67, $69, $67, $69, $5D, $FE, $B5, $68, $6A, $68
+    db $6A, $5D, $FE, $B2, $67, $69, $F1, $5D, $FE, $B2, $68, $6A, $F1, $5D, $FE
+
+; Suite: données mal désassemblées à $5C22+ (à reconstruire dans un futur nœud BFS)
+DataZone_5c0c:  ; Label incorrect (devrait être supprimé), à l'origine à $5C0C milieu de données
+    or d
     ld h, a
     ld l, c
     pop af
diff --git a/src/bank_001.asm.bak b/src/bank_001.asm.bak
index d470897..9d475ae 100644
--- a/src/bank_001.asm.bak
+++ b/src/bank_001.asm.bak
@@ -9,23 +9,23 @@ SECTION "ROM Bank $001", ROMX[$4000], BANK[$1]
 ;   - +4: Pointeur entities
 LevelJumpTable:
     ; Niveau 0
-    dw $55BB, $55E2, $5605
+    dw SharedTilesetData_024, SharedMapData_012, SharedEntitiesData_012
     ; Niveau 1
-    dw $55BB, $55E2, $5605
+    dw SharedTilesetData_024, SharedMapData_012, SharedEntitiesData_012
     ; Niveau 2
-    dw $55BB, $55E2, $5605
+    dw SharedTilesetData_024, SharedMapData_012, SharedEntitiesData_012
     ; Niveau 3
-    dw $5630, $5665, $5694
+    dw Level3TilesetData, Level3MapData, Level3EntitiesData
     ; Niveau 4
-    dw $55BB, $5311, $5405
+    dw SharedTilesetData_024, SharedMapData_467, $5405
     ; Niveau 5
-    dw $54D5, Level5MapData, $5222
+    dw SharedTilesetData_578, Level5MapData, Level5EntitiesData
     ; Niveau 6
-    dw $529B, $5311, $5405
+    dw Level6TilesetData, SharedMapData_467, $5405
     ; Niveau 7
-    dw $54D5, $5311, $5405
+    dw SharedTilesetData_578, SharedMapData_467, $5405
     ; Niveau 8 (incomplet)
-    dw $54D5
+    dw SharedTilesetData_578
 
 ; ==============================================================================
 ; ROM_WORLD1_TILES - Données graphiques mondes 1 et 2 ($4032-$4401)
@@ -2827,232 +2827,51 @@ ResetGameStateInit:
     ldh [hTimer1], a             ; Timer1 = TIMER_CHECKPOINT_LONG
     ret
 
+; ==============================================================================
+; Level5MapData - Map data for level 5 ($5179-$5221)
+; ==============================================================================
+; Description: Compressed map data (RLE format) for level 5
+; Format:
+;   - Standard bytes: high nibble = tile count-1, low nibble = tile base
+;   - Command $84: Special tile marker
+;   - Command $93: Repeat/pattern marker
+;   - Command $00: Separator/special marker
+;   - End marker: $FF
+; Referenced by: LevelJumpTable entry for level 5 (line 22)
+; Size: 169 bytes (0xA9)
+; ==============================================================================
+Level5MapData:
+    db $0E, $13, $10, $10, $13, $10, $11, $0D, $84, $12, $04, $84, $17, $0B, $84, $1A
+    db $93, $10, $1B, $05, $84, $1C, $93, $10, $21, $09, $0B, $25, $06, $0B, $2A, $0F
+    db $84, $2D, $0C, $84, $2E, $13, $00, $2F, $05, $84, $34, $13, $10, $37, $13, $10
+    db $3A, $13, $10, $3D, $13, $10, $40, $13, $10, $41, $08, $04, $43, $13, $10, $47
+    db $93, $10, $49, $93, $10, $4C, $13, $A4, $4E, $13, $10, $51, $07, $00, $52, $07
+    db $00, $57, $04, $00, $58, $04, $00, $59, $04, $00, $5C, $93, $10, $5E, $93, $10
+    db $60, $93, $10, $62, $93, $10, $66, $93, $10, $68, $93, $10, $6A, $93, $24, $6C
+    db $93, $90, $6F, $4E, $02, $71, $0F, $84, $78, $07, $00, $79, $07, $00, $7D, $0B
+    db $84, $7D, $87, $84, $7F, $04, $00, $80, $04, $80, $84, $13, $90, $87, $13, $24
+    db $88, $08, $84, $8B, $93, $24, $8E, $0F, $84, $90, $08, $0A, $98, $08, $0A, $99
+    db $10, $84, $9C, $05, $36, $9C, $85, $36, $FF
 
-    ld c, $13
-    db $10
-    db $10
-    inc de
-    db $10
-    ld de, $840d
-    ld [de], a
-    inc b
-    add h
-    rla
-    dec bc
-    add h
-    ld a, [de]
-    sub e
-    db $10
-    dec de
-    dec b
-    add h
-    inc e
-    sub e
-    db $10
-    ld hl, $0b09
-    dec h
-    ld b, $0b
-    ld a, [hl+]
-    rrca
-    add h
-    dec l
-    inc c
-    add h
-    ld l, $13
-    nop
-    cpl
-    dec b
-    add h
-    inc [hl]
-    inc de
-    db $10
-    scf
-    inc de
-    db $10
-    ld a, [hl-]
-    inc de
-    db $10
-    dec a
-    inc de
-    db $10
-    ld b, b
-    inc de
-    db $10
-    ld b, c
-    ld [$4304], sp
-    inc de
-    db $10
-    ld b, a
-    sub e
-    db $10
-    ld c, c
-    sub e
-    db $10
-    ld c, h
-    inc de
-    and h
-    ld c, [hl]
-    inc de
-    db $10
-    ld d, c
-    rlca
-    nop
-    ld d, d
-    rlca
-    nop
-    ld d, a
-    inc b
-    nop
-    ld e, b
-    inc b
-    nop
-    ld e, c
-    inc b
-    nop
-    ld e, h
-    sub e
-    db $10
-    ld e, [hl]
-    sub e
-    db $10
-    ld h, b
-    sub e
-    db $10
-    ld h, d
-    sub e
-    db $10
-    ld h, [hl]
-    sub e
-    db $10
-    ld l, b
-    sub e
-    db $10
-    ld l, d
-    sub e
-    inc h
-    ld l, h
-    sub e
-    sub b
-    ld l, a
-    ld c, [hl]
-    ld [bc], a
-    ld [hl], c
-    rrca
-    add h
-    ld a, b
-    rlca
-    nop
-    ld a, c
-    rlca
-    nop
-    ld a, l
-    dec bc
-    add h
-    ld a, l
-    add a
-    add h
-    ld a, a
-    inc b
-    nop
-    add b
-    inc b
-    add b
-    add h
-    inc de
-    sub b
-    add a
-    inc de
-    inc h
-    adc b
-    ld [$8b84], sp
-    sub e
-    inc h
-    adc [hl]
-    rrca
-    add h
-    sub b
-    ld [$980a], sp
-    ld [$990a], sp
-    db $10
-    add h
-    sbc h
-    dec b
-    ld [hl], $9c
-    add l
-    ld [hl], $ff
-    inc c
-    inc c
-    ld d, $12
-    inc c
-    add h
-    ld d, $0b
-    nop
-    rla
-    rlca
-    inc b
-    dec e
-    dec bc
-    inc b
-    ld [hl+], a
-    rlca
-    dec bc
-    inc hl
-    inc de
-    and h
-    daa
-    rlca
-    dec bc
-    ld a, [hl+]
-    dec c
-    inc b
-    ld sp, $1609
-    ld [hl], $09
-    inc b
-    scf
-    ld c, $00
-    ld a, [hl-]
-    add hl, bc
-    add b
-    ld a, $09
-    ld d, $41
-    ld c, $00
-    ld b, h
-    add hl, bc
-    add b
-    ld b, [hl]
-    add hl, bc
-    inc b
-    ld c, b
-    add hl, bc
-    ld d, $4b
-    ld c, $00
-    ld d, a
-    adc a
-    inc b
-    ld e, b
-    ld c, $84
-    ld e, c
-    inc c
-    nop
-    ld e, e
-    inc de
-    inc h
-    ld h, b
-    adc a
-    ld d, $65
-    add l
-    ld a, [bc]
-    ld l, e
-    ld a, [bc]
-    dec bc
-    ld [hl], b
-    dec c
-    inc b
-    ld [hl], c
-    inc de
-    and h
-    ld [hl], e
-    inc de
+; ==============================================================================
+; Level5EntitiesData - Entities/objects data for level 5 ($5222-$5277)
+; ==============================================================================
+; Description: Entity placement data for level 5 (enemies, coins, blocks, etc.)
+; Format: Variable-length entries, each entity contains:
+;   - Position data (X, Y coordinates)
+;   - Entity type ID
+;   - Properties/flags
+; Size: 86 bytes ($56)
+; Referenced by: LevelJumpTable entry for level 5 (line 22)
+; Note: Format appears specific to level 5 layout
+; ==============================================================================
+Level5EntitiesData:
+    db $0C, $0C, $16, $12, $0C, $84, $16, $0B, $00, $17, $07, $04, $1D, $0B, $04, $22
+    db $07, $0B, $23, $13, $A4, $27, $07, $0B, $2A, $0D, $04, $31, $09, $16, $36, $09
+    db $04, $37, $0E, $00, $3A, $09, $80, $3E, $09, $16, $41, $0E, $00, $44, $09, $80
+    db $46, $09, $04, $48, $09, $16, $4B, $0E, $00, $57, $8F, $04, $58, $0E, $84, $59
+    db $0C, $00, $5B, $13, $24, $60, $8F, $16, $65, $85, $0A, $6B, $0A, $0B, $70, $0D
+    db $04, $71, $13, $A4, $73, $13
 
 DataZone_5278:
     inc h
@@ -3090,141 +2909,41 @@ DataZone_5278:
     adc l
     ld [hl], $ff
 
+; Level6TilesetData
+; ----------------
+; Description: Tileset pour le niveau 6 (format RLE compressé)
+; Format: Paires d'octets (count, tile_id), terminé par $1A $FF
+; Taille: 118 octets ($76)
+; Référencé par: LevelJumpTable niveau 6
+Level6TilesetData:
+    db $0F, $05, $AF, $19, $0E, $2F, $1B, $53
+    db $10, $23, $0E, $9D, $25, $0B, $1D, $27
+    db $08, $9D, $29, $05, $1D, $2D, $08, $2F
+    db $2F, $53, $10, $39, $53, $10, $3B, $05
+    db $1D, $3E, $05, $9D, $40, $0D, $1D, $43
+    db $0D, $9D, $43, $13, $10, $49, $07, $1D
+    db $4D, $13, $10, $4E, $07, $2F, $54, $08
+    db $20, $57, $08, $1D, $5F, $09, $20, $69
+    db $07, $20, $69, $0D, $20, $73, $07, $2F
+    db $75, $13, $24, $78, $0C, $1D, $7F, $13
+    db $24, $85, $0A, $20, $88, $0C, $2F, $89
+    db $13, $A4, $8E, $0F, $1D, $92, $0F, $9D
+    db $9B, $0D, $20, $9C, $0F, $9D, $A5, $07
+    db $A0, $A8, $0F, $1D, $AE, $0B, $48, $AF
+    db $0A, $C8, $B0, $0C, $1A, $FF
+
 ; ==============================================================================
-; Level5MapData - Map data for level 5 ($5179-$5221)
+; SharedMapData_467 - Map data partagée niveaux 4, 6, 7 ($5311-$5404)
 ; ==============================================================================
-; Description: Compressed map data (RLE format) for level 5
-; Format:
-;   - Standard bytes: high nibble = tile count-1, low nibble = tile base
-;   - Command $84: Special tile marker
-;   - Command $93: Repeat/pattern marker
-;   - Command $00: Separator/special marker
-;   - End marker: $FF
-; Referenced by: LevelJumpTable entry for level 5 (line 22)
-; Size: 169 bytes (0xA9)
+; Description: Données de carte partagées entre les niveaux 4, 6 et 7
+;              Zone mal désassemblée comme du code (rrca, call z, etc.)
+;              Réellement: données de map au format similaire à Level5MapData
+; Format: Variable-length entries describing tile placement, terminated by $FF
+; Referenced by: LevelJumpTable entries for levels 4, 6, and 7
+; Size: 244 bytes ($F4)
+; Note: Reconstruire avec des 'db' statements pour une meilleure lisibilité
 ; ==============================================================================
-Level5MapData:
-    db $0E, $13, $10, $10, $13, $10, $11, $0D, $84, $12, $04, $84, $17, $0B, $84, $1A
-    db $93, $10, $1B, $05, $84, $1C, $93, $10, $21, $09, $0B, $25, $06, $0B, $2A, $0F
-    db $84, $2D, $0C, $84, $2E, $13, $00, $2F, $05, $84, $34, $13, $10, $37, $13, $10
-    db $3A, $13, $10, $3D, $13, $10, $40, $13, $10, $41, $08, $04, $43, $13, $10, $47
-    db $93, $10, $49, $93, $10, $4C, $13, $A4, $4E, $13, $10, $51, $07, $00, $52, $07
-    db $00, $57, $04, $00, $58, $04, $00, $59, $04, $00, $5C, $93, $10, $5E, $93, $10
-    db $60, $93, $10, $62, $93, $10, $66, $93, $10, $68, $93, $10, $6A, $93, $24, $6C
-    db $93, $90, $6F, $4E, $02, $71, $0F, $84, $78, $07, $00, $79, $07, $00, $7D, $0B
-    db $84, $7D, $87, $84, $7F, $04, $00, $80, $04, $80, $84, $13, $90, $87, $13, $24
-    db $88, $08, $84, $8B, $93, $24, $8E, $0F, $84, $90, $08, $0A, $98, $08, $0A, $99
-    db $10, $84, $9C, $05, $36, $9C, $85, $36, $FF
-
-DataZone_529b:
-    rrca
-    dec b
-    xor a
-    add hl, de
-    ld c, $2f
-    dec de
-    ld d, e
-    db $10
-    inc hl
-    ld c, $9d
-    dec h
-    dec bc
-    dec e
-    daa
-    ld [$299d], sp
-    dec b
-    dec e
-    dec l
-    ld [$2f2f], sp
-    ld d, e
-    db $10
-    add hl, sp
-    ld d, e
-    db $10
-    dec sp
-    dec b
-    dec e
-    ld a, $05
-    sbc l
-    ld b, b
-    dec c
-    dec e
-    ld b, e
-    dec c
-    sbc l
-    ld b, e
-    inc de
-    db $10
-    ld c, c
-    rlca
-    dec e
-    ld c, l
-    inc de
-    db $10
-    ld c, [hl]
-    rlca
-    cpl
-    ld d, h
-    ld [$5720], sp
-    ld [$5f1d], sp
-    add hl, bc
-    jr nz, PaddingZone_5344
-
-    rlca
-    jr nz, PaddingZone_5347
-
-    dec c
-    jr nz, PaddingZone_5354
-
-    rlca
-    cpl
-    ld [hl], l
-    inc de
-    inc h
-    ld a, b
-    inc c
-    dec e
-    ld a, a
-    inc de
-    inc h
-    add l
-    ld a, [bc]
-    jr nz, DataZone_5278
-
-    inc c
-    cpl
-    adc c
-    inc de
-    and h
-    adc [hl]
-    rrca
-    dec e
-    sub d
-    rrca
-    sbc l
-    sbc e
-    dec c
-    jr nz, DataZone_529b
-
-    rrca
-    sbc l
-    and l
-    rlca
-    and b
-    xor b
-    rrca
-    dec e
-    xor [hl]
-    dec bc
-    ld c, b
-    xor a
-    ld a, [bc]
-    ret z
-
-    or b
-    inc c
-    ld a, [de]
-    rst $38
+SharedMapData_467:  ; $5311
     rrca
     call z, $1155
     pop de
@@ -3497,6 +3216,9 @@ ConditionalProcessingRoutine_5436:
     add hl, bc
     inc b
     ld c, b
+
+; SharedEntitiesData_467 - Entities data partagée niveaux 4, 6, 7 ($5405-$5509)
+SharedEntitiesData_467:  ; $5405
     rrca
     nop
     ld c, e
@@ -3620,484 +3342,194 @@ ConditionalProcessingRoutine_5436:
     ld [wSpriteVar36], sp
     add [hl]
     ld [hl], $ff
-    db $10
-    ld b, $53
-    ld de, $d30f
-    inc de
-    ld [$1453], sp
-    dec c
-    ld d, e
-    rla
-    ld a, [bc]
-    ld d, e
-    add hl, de
-    ld b, $53
-    ld a, [de]
-    rrca
-    db $d3
-    inc e
-    inc c
-    ld d, e
-    dec e
-    add hl, bc
-    ld d, e
-    inc hl
-    ld b, $53
-    inc h
-    ld [$25d3], sp
-    ld a, [bc]
-    ld d, e
-    daa
-    ld c, $53
-    jr z, JumpHandler_550a
+; SharedTilesetData_578 - Tileset data partagée niveaux 5, 7, 8 ($54D5-$55BB)
+; ==============================================================================
+; Description: Tileset partagé utilisé par les niveaux 5, 7 et 8
+; Format: Paires d'octets (position, tile_id), terminé par $FF $FF
+;         - Chaque paire définit: position (nibbles: Y/X), tile ID
+;         - Valeurs spéciales: $52/$53/$59 (bank selectors?), $D2/$D3 (commands?)
+; Taille: 227 octets ($E3)
+; Référencé par: LevelJumpTable niveaux 5, 7, 8 (lignes 22, 26, 28)
+; ==============================================================================
+SharedTilesetData_578:
+    db $10, $06, $53, $11, $0F, $D3, $13, $08, $53, $14, $0D, $53, $17, $0A, $53, $19
+    db $06, $53, $1A, $0F, $D3, $1C, $0C, $53, $1D, $09, $53, $23, $06, $53, $24, $08
+    db $D3, $25, $0A, $53, $27, $0E, $53, $28, $0C, $D3, $29, $0A, $53, $2B, $06, $53
+    db $2C, $05, $52, $2E, $05, $D2, $30, $05, $52, $34, $0F, $52, $36, $0F, $D2, $38
+    db $0F, $52, $3C, $05, $52, $3D, $0A, $D2, $3E, $0F, $52, $42, $06, $52, $43, $0D
+    db $52, $4C, $05, $53, $4D, $8B, $59, $4E, $06, $D3, $4E, $0C, $52, $50, $85, $59
+    db $52, $0F, $52, $52, $06, $53, $56, $06, $59, $57, $0E, $53, $58, $8F, $59, $5A
+    db $06, $52, $5A, $0E, $D2, $5C, $0F, $53, $5D, $09, $59, $5F, $08, $53, $60, $0D
+    db $59, $63, $05, $53, $63, $0A, $52, $65, $0E, $53, $67, $09, $59, $68, $09, $53
+    db $69, $0E, $D2, $6B, $09, $59, $6C, $08, $53, $71, $8A, $59, $72, $07, $53, $73
+    db $0A, $52, $75, $0C, $52, $76, $8F, $59, $78, $08, $52, $7A, $0A, $53, $7B, $0E
+    db $59, $7D, $07, $53, $7E, $0D, $53, $80, $8C, $59, $85, $05, $53, $87, $0E, $53
+    db $89, $0E, $D2, $8E, $0A, $52, $90, $07, $52, $93, $0D, $53, $93, $06, $52, $CF
+    db $8A, $54, $D9, $87, $D4, $DB, $0C, $54, $DC, $0D, $86, $E0, $08, $06, $E1, $08
+    db $06, $EC, $8A, $61, $FF, $FF
 
-    db $d3
-    add hl, hl
-    ld a, [bc]
-    ld d, e
-    dec hl
-    ld b, $53
-    inc l
-    dec b
-    ld d, d
-    ld l, $05
+; ==============================================================================
+; SharedTilesetData_024 - Tileset data partagée niveaux 0, 1, 2, 4 ($55BB-$55E1)
+; ==============================================================================
+; Description: Table de pointeurs vers tiles graphiques (8 bytes/tile)
+; Format: Séquence de words (16-bit pointers), terminée par $FF
+;         - Chaque word pointe vers une tile de 8 octets en mémoire
+; Taille: 39 octets ($27) - 19 pointeurs + terminateur
+; Référencé par: LevelJumpTable niveaux 0, 1, 2, 4 (lignes 12, 14, 16, 20)
+; ==============================================================================
+SharedTilesetData_024:
+    dw $56CD, TileGraphic_5ABB, $6048, $56CD, $574A, $57EB, $5D32, $586F
+    dw TilesetBlock_58FE, TilesetBlock_58FE, TilesetBlock_596E, $574A, $57EB, $57EB, $586F, $574A
+    dw TilesetBlock_58FE, $59EE, $5A5F
+    db $FF  ; Terminateur
 
-JumpHandler_550a:
-    jp nc, InitLevelStartWithAttractMode
+; ==============================================================================
+; SharedMapData_012 - Map data partagée niveaux 0, 1, 2 ($55E2-$5604)
+; ==============================================================================
+; Description: Données de map (layout de tiles) partagées par les niveaux 0, 1 et 2
+; Format: Séquence de words (16-bit tile IDs ou pointeurs), terminée par $FF
+;         - Chaque word représente un tile dans le layout de la map
+; Taille: 35 octets ($23) - 17 words + terminateur
+; Référencé par: LevelJumpTable niveaux 0, 1, 2 (lignes 12, 14, 16)
+; ==============================================================================
+SharedMapData_012:
+    dw $56CD, TileGraphic_5ABB, $6048, $5BA3, $5C22, $5CA6, $5D32, $5D8A
+    dw $5E32, $5E32, $5E32, $5F44, $5F44, $5D32, $5FAD, $5CA6
+    dw $5A5F
+    db $FF  ; Terminateur
 
-    ld d, d
-    inc [hl]
-    rrca
-    ld d, d
-    ld [hl], $0f
-    jp nc, $0f38
+; ==============================================================================
+; SharedEntitiesData_012 - Entities data partagée niveaux 0-2 ($5605-$562F)
+; ==============================================================================
+; Description: Table de pointeurs vers les données d'entités pour niveaux 0, 1, 2
+; Format: Séquence de words (16-bit pointeurs vers entités), terminée par $FF
+;         - Chaque word pointe vers une définition d'entité (position/type)
+; Taille: 43 octets ($2B) - 21 words + terminateur
+; Référencé par: LevelJumpTable niveaux 0, 1, 2 (lignes 12, 14, 16)
+; ==============================================================================
+SharedEntitiesData_012:  ; $5605
+    dw $56CD, $6327, $6327, $6100, $61B8, $6272, $61B8, $6100
+    dw $6100, $6272, $6272, $61B8, $6327, $6327, $6272, $6272
+    dw $6100, $640D, $6327, $6327, $650D
+    db $FF  ; Terminateur
 
-    ld d, d
-    inc a
-    dec b
-    ld d, d
+; ==============================================================================
+; Level3TilesetData - Tileset data niveau 3 ($5630-$5664)
+; ==============================================================================
+; Description: Table de pointeurs vers tiles graphiques pour le niveau 3
+; Format: Séquence de words (16-bit pointers), terminée par $FF
+;         - Chaque word pointe vers une tile de 8 octets en mémoire
+; Taille: 53 octets ($35) - 26 pointeurs + terminateur
+; Référencé par: LevelJumpTable niveau 3 (ligne 18)
+; ==============================================================================
+Level3TilesetData:  ; $5630
+    dw $6C81, $6C81, $6DDB, $65D3, $66A1, $67BF, $6882, $67BF
+    dw $691C, $691C, $67BF, $69E2, $65D3, $6882, $66A1, $66A1
+    dw $66A1
+DataZone_5652:  ; $5652 - Référencé par du code (lignes 10194, 10254)
+    dw $6882, $6882, $69E2, $691C, $6AA0, $6B51, $691C
+    dw $6B51, $6C1B
+    db $FF  ; Terminateur
+
+; ==============================================================================
+; Level3MapData - Map data niveau 3 ($5665-$5693)
+; ==============================================================================
+; Description: Données de map (layout de tiles) pour le niveau 3
+; Format: Séquence de words (16-bit pointeurs vers tileset data), terminée par $FF
+;         - Chaque word pointe vers des données de tileset dans bank 1
+;         - Les pointeurs référencent des blocs de tile patterns compressés
+; Taille: 47 octets ($2F) - 23 words + terminateur
+; Référencé par: LevelJumpTable niveau 3 (ligne 18)
+; ==============================================================================
+Level3MapData:  ; $5665
+    dw $6C81, $6C81, $6DDB, $6EA6, $6F60, $6F60, $6EA6, $6EA6
+    dw $7038, $7038, $6F60, $7123, $7123, $71FC, $72BC, $71FC
+    dw $72BC, $7379, $7123, $7379, $7442, $757C, $6C1B
+    db $FF  ; Terminateur
+
+; ==============================================================================
+; Level3EntitiesData - Entities data niveau 3 ($5694-$56CA)
+; ==============================================================================
+; Description: Table de pointeurs vers les données d'entités pour niveau 3
+; Format: Séquence de words (16-bit pointeurs vers entités), terminée par $FF
+;         - Chaque word pointe vers une définition d'entité (position/type)
+; Taille: 55 octets ($37) - 27 words + terminateur
+; Référencé par: LevelJumpTable niveau 3 (ligne 18)
+; ==============================================================================
+Level3EntitiesData:  ; $5694
+    dw $6C81, $6C81, $6DDB, $764F, $764F, $764F, $764F, $76D2
+    dw $76D2, $76D2, $764F, $764F, $764F, $76D2, $76D2, $764F
+    dw $775A, $775A, $77BD, $79E9, $791A, $791A, $79E9, $7AB2
+    dw $7B5F, $7C0E, $7D01
+    db $FF  ; Terminateur
+
+; ==============================================================================
+; ZONE MAL DÉSASSEMBLÉE: $56CB-$5A5F (Données compressées + pointeurs états)
+; ==============================================================================
+; ATTENTION: Les instructions ci-dessous sont en réalité des DONNÉES compressées
+; mal interprétées comme du code par le désassembleur.
+;
+; Structure réelle:
+;   $56CB-$56CC: Padding (2 bytes: $00 $00)
+;   $56CD-$5749: CompressedTilesetData (125 bytes de données compressées)
+;   $574A-$5A5F: Continuation données compressées/tiles
+;
+; Pointeurs d'états dans cette zone (bank_000.asm StateJumpTable):
+;   Ces adresses sont utilisées comme pointeurs dans StateJumpTable mais pointent
+;   vers des DONNÉES (stream de compression) et NON vers du code exécutable.
+;   Les "états" $14, $15, $17-$1A sont en réalité des curseurs/pointeurs dans
+;   un flux de données compressées utilisé pour décoder des tiles/maps.
+;
+;   $5832: État $14 - State14_CompressedDataPtr (offset +359 depuis $56CB)
+;   $5835: État $15 - State15_CompressedDataPtr (offset +362 depuis $56CB) ← ANALYSÉ
+;   $5838: État $17 - State17_CompressedDataPtr (offset +365 depuis $56CB)
+;   $583B: État $18 - State18_CompressedDataPtr (offset +368 depuis $56CB)
+;   $583E: État $19 - State19_CompressedDataPtr (offset +371 depuis $56CB)
+;   $5841: État $1A - State1A_CompressedDataPtr (offset +374 depuis $56CB)
+;
+; Référencé par:
+;   - SharedTilesetData_024 (ligne 3381) - niveaux 0, 1, 2
+;   - SharedMapData_012 (ligne 3396) - niveaux 0, 1, 2
+;   - SharedEntitiesData_012 (ligne 3411) - niveaux 0, 1, 2
+;   - StateJumpTable (bank_000.asm:688-694) - états $14-$15, $17-$1A
+;
+; Format compression: Stream de commandes + données
+;   - $5D $FE: Commande de répétition/copie
+;   - $E2 XX: Commande avec argument
+;   - Autres: Données brutes ou arguments
+;
+; TODO BFS: Reconstruire cette zone avec des 'db' statements corrects pour pouvoir
+;           placer les labels State14-State1A aux adresses exactes
+; ==============================================================================
+TilesetData_Padding:  ; $56CB
+    nop
+    nop
+CompressedTilesetData:  ; $56CD
+    pop af
+    ld e, l
+    cp $f1
+    ld e, l
+    cp $e2
+    ld h, b
+    ld e, l
+    cp $72
+    add hl, sp
     dec a
-    ld a, [bc]
-    jp nc, $0f3e
+    ldh [c], a
+    ld h, c
+    ld e, l
+    cp $54
+    inc sp
+    ld [hl], $3a
+    ld a, $e2
+    ld h, c
+    ld e, l
+    cp $5b
+    inc [hl]
 
-    ld d, d
-    ld b, d
-    ld b, $52
-    ld b, e
-    dec c
-    ld d, d
-    ld c, h
-    dec b
-    ld d, e
-    ld c, l
-    adc e
-    ld e, c
-    ld c, [hl]
-    ld b, $d3
-    ld c, [hl]
-    inc c
-    ld d, d
-    ld d, b
-    add l
-    ld e, c
-    ld d, d
-    rrca
-    ld d, d
-    ld d, d
-    ld b, $53
-    ld d, [hl]
-    ld b, $59
-    ld d, a
-    ld c, $53
-    ld e, b
-    adc a
-    ld e, c
-    ld e, d
-    ld b, $52
-    ld e, d
-    ld c, $d2
-    ld e, h
-    rrca
-    ld d, e
-    ld e, l
-    add hl, bc
-    ld e, c
-    ld e, a
-    ld [$6053], sp
-    dec c
-    ld e, c
-    ld h, e
-    dec b
-    ld d, e
-    ld h, e
-    ld a, [bc]
-    ld d, d
-    ld h, l
-    ld c, $53
-    ld h, a
-    add hl, bc
-    ld e, c
-    ld l, b
-    add hl, bc
-    ld d, e
-    ld l, c
-    ld c, $d2
-    ld l, e
-    add hl, bc
-    ld e, c
-    ld l, h
-    ld [$7153], sp
-    adc d
-    ld e, c
-    ld [hl], d
-    rlca
-    ld d, e
-    ld [hl], e
-    ld a, [bc]
-    ld d, d
-    ld [hl], l
-    inc c
-    ld d, d
-    halt
-    adc a
-    ld e, c
-    ld a, b
-    ld [$7a52], sp
-    ld a, [bc]
-    ld d, e
-    ld a, e
-    ld c, $59
-    ld a, l
-    rlca
-    ld d, e
-    ld a, [hl]
-    dec c
-    ld d, e
-    add b
-    adc h
-    ld e, c
-    add l
-    dec b
-    ld d, e
-    add a
-    ld c, $53
-    adc c
-    ld c, $d2
-    adc [hl]
-    ld a, [bc]
-    ld d, d
-    sub b
-    rlca
-    ld d, d
-    sub e
-    dec c
-    ld d, e
-    sub e
-    ld b, $52
-    rst $08
-    adc d
-    ld d, h
-    reti
-
-
-    add a
-    call nc, CheckPlayerCenterPosition
-    ld d, h
-    call c, $860d
-    ldh [$ff08], a
-    ld b, $e1
-    ld [$ec06], sp
-    adc d
-    ld h, c
-    rst $38
-    rst $38
-    call $bb56
-    ld e, d
-    ld c, b
-    ld h, b
-    call UpdateLevelState_4a56
-    ld d, a
-    db $eb
-    ld d, a
-    ld [hl-], a
-    ld e, l
-    ld l, a
-    ld e, b
-    cp $58
-    cp $58
-    ld l, [hl]
-    ld e, c
-    ld c, d
-    ld d, a
-    db $eb
-    ld d, a
-    db $eb
-    ld d, a
-    ld l, a
-    ld e, b
-    ld c, d
-    ld d, a
-    cp $58
-    xor $59
-    ld e, a
-    ld e, d
-    rst $38
-    call $bb56
-    ld e, d
-    ld c, b
-    ld h, b
-    and e
-    ld e, e
-    ld [hl+], a
-    ld e, h
-    and [hl]
-    ld e, h
-    ld [hl-], a
-    ld e, l
-    adc d
-    ld e, l
-    ld [hl-], a
-    ld e, [hl]
-    ld [hl-], a
-    ld e, [hl]
-    ld [hl-], a
-    ld e, [hl]
-    ld b, h
-    ld e, a
-    ld b, h
-    ld e, a
-    ld [hl-], a
-    ld e, l
-    xor l
-    ld e, a
-    and [hl]
-    ld e, h
-    ld e, a
-    ld e, d
-    rst $38
-    call $2756
-    ld h, e
-    daa
-    ld h, e
-    nop
-    ld h, c
-    cp b
-    ld h, c
-    ld [hl], d
-    ld h, d
-    cp b
-    ld h, c
-    nop
-    ld h, c
-    nop
-    ld h, c
-    ld [hl], d
-    ld h, d
-    ld [hl], d
-    ld h, d
-    cp b
-    ld h, c
-    daa
-    ld h, e
-    daa
-    ld h, e
-    ld [hl], d
-    ld h, d
-    ld [hl], d
-    ld h, d
-    nop
-    ld h, c
-    dec c
-    ld h, h
-    daa
-    ld h, e
-    daa
-    ld h, e
-    dec c
-    ld h, l
-    rst $38
-    add c
-    ld l, h
-    add c
-    ld l, h
-    db $db
-    ld l, l
-    db $d3
-    ld h, l
-    and c
-    ld h, [hl]
-    cp a
-    ld h, a
-    add d
-    ld l, b
-    cp a
-    ld h, a
-    inc e
-    ld l, c
-    inc e
-    ld l, c
-    cp a
-    ld h, a
-    ldh [c], a
-    ld l, c
-    db $d3
-    ld h, l
-    add d
-    ld l, b
-    and c
-    ld h, [hl]
-    and c
-    ld h, [hl]
-    and c
-    ld h, [hl]
-
-DataZone_5652:
-    add d
-    ld l, b
-    add d
-    ld l, b
-    ldh [c], a
-    ld l, c
-    inc e
-    ld l, c
-    and b
-    ld l, d
-    ld d, c
-    ld l, e
-    inc e
-    ld l, c
-    ld d, c
-    ld l, e
-    dec de
-    ld l, h
-    rst $38
-    add c
-    ld l, h
-    add c
-    ld l, h
-    db $db
-    ld l, l
-    and [hl]
-    ld l, [hl]
-    ld h, b
-    ld l, a
-    ld h, b
-    ld l, a
-    and [hl]
-    ld l, [hl]
-    and [hl]
-    ld l, [hl]
-    jr c, @+$72
-
-    jr c, DataZone_56e9
-
-    ld h, b
-    ld l, a
-    inc hl
-    ld [hl], c
-    inc hl
-    ld [hl], c
-    db $fc
-    ld [hl], c
-    cp h
-    ld [hl], d
-    db $fc
-    ld [hl], c
-    cp h
-    ld [hl], d
-    ld a, c
-    ld [hl], e
-    inc hl
-    ld [hl], c
-    ld a, c
-    ld [hl], e
-    ld b, d
-    ld [hl], h
-    ld a, h
-    ld [hl], l
-    dec de
-    ld l, h
-    rst $38
-    add c
-    ld l, h
-    add c
-    ld l, h
-    db $db
-    ld l, l
-    ld c, a
-    halt
-    ld c, a
-    halt
-    ld c, a
-    halt
-    ld c, a
-    halt
-    jp nc, $d276
-
-    halt
-    jp nc, PaddingZone_4f76
-
-    halt
-    ld c, a
-    halt
-    ld c, a
-    halt
-    jp nc, $d276
-
-    halt
-    ld c, a
-    halt
-    ld e, d
-    ld [hl], a
-    ld e, d
-    ld [hl], a
-    cp l
-    ld [hl], a
-    jp hl
-
-
-    ld a, c
-    ld a, [de]
-    ld a, c
-    ld a, [de]
-    ld a, c
-    jp hl
-
-
-    ld a, c
-    or d
-    ld a, d
-    ld e, a
-    ld a, e
-    ld c, $7c
-    ld bc, $ff7d
-    nop
-    nop
-    pop af
-    ld e, l
-    cp $f1
-    ld e, l
-    cp $e2
-    ld h, b
-    ld e, l
-    cp $72
-    add hl, sp
-    dec a
-    ldh [c], a
-    ld h, c
-    ld e, l
-    cp $54
-    inc sp
-    ld [hl], $3a
-    ld a, $e2
-    ld h, c
-    ld e, l
-    cp $5b
-    inc [hl]
-
-DataZone_56e9:
-    scf
-    ld b, c
+DataZone_56e9:
+    scf
+    ld b, c
     ld e, b
     ld e, c
     ld e, c
@@ -4173,16 +3605,21 @@ DataZone_5733:
     ld sp, $3131
     ld sp, $3131
     ld e, l
-    cp $6a
-    ld h, b
-    ld e, d
-    ld e, d
-    ld e, d
-    ld e, d
-    ld e, d
-    ld e, d
-    ld e, d
-    ld e, d
+    db $FE  ; Opcode cp (partie de données compressées mal désassemblées)
+
+; ==============================================================================
+; TileGraphic_574A - Tile graphique 8x8 pixels (8 bytes)
+; ==============================================================================
+; Description: Données de tile graphique 8x8 (2 bits par pixel, 2 bytes par ligne)
+; Format: 8 bytes représentant 8 lignes de pixels (2bpp format Game Boy)
+;         Pattern: $6A $60 suivi de 6x $5A
+; Taille: 8 octets
+; Référencé par: SharedTilesetData_024 (lignes 3381-3382) - 3 occurrences
+; ==============================================================================
+TileGraphic_574A:  ; $574A
+    db $6A, $60, $5A, $5A, $5A, $5A, $5A, $5A
+
+    db $5A, $5A  ; Suite des données (2 bytes additionnels)
     ld e, l
     cp $61
     ld h, c
@@ -4287,12 +3724,28 @@ DataZone_5733:
     cp $f1
     ld e, l
     cp $f1
+
+; ==============================================================================
+; TileGraphic_57EB - Tile graphique 8x8 pixels (8 bytes)
+; ==============================================================================
+; Description: Données de tile graphique (format pattern compressé)
+; Format: 8 bytes de données graphiques mal désassemblées comme code
+;         Pattern binaire: $5D $FE $C4 $60 $5A $5A $5D $FE
+;         Interprété comme: ld e,l / cp $c4 / ld h,b / ld e,d / ld e,d / ld e,l / (cp partiel)
+; In: Aucun (données, pas du code exécutable)
+; Out: Aucun
+; Modifie: Aucun
+; Taille: 8 octets ($57EB-$57F2)
+; Référencé par: SharedTilesetData_024 (lignes 3381-3382) - 3 occurrences
+; ==============================================================================
+TileGraphic_57EB:  ; $57EB
     ld e, l
     cp $c4
     ld h, b
     ld e, d
     ld e, d
     ld e, l
+    ; Note: Le byte $FE qui suit fait partie du tile, mais est aussi l'opcode de 'cp $c1'
     cp $c1
     ld h, c
     pop af
@@ -4380,6 +3833,16 @@ DataZone_5733:
     ld h, e
     ld sp, $3131
     ld sp, $5d31
+; ==============================================================================
+; TileGraphic_586F - Tile graphique 2BPP ($586F-$5876)
+; ==============================================================================
+; Description: Tile graphique 8x8 pixels, format 2BPP Game Boy
+; Taille: 8 octets (4 lignes de pixels, 2 bytes/ligne)
+; Référencé par: SharedTilesetData_024 (lignes 3381-3382) - 2 occurrences
+; Note: Cette zone est mal désassemblée et nécessite reconstruction en db
+; TODO: Reconstruire toute la zone $57F3-$5A5F en format db (tiles graphiques)
+; ==============================================================================
+TileGraphic_586F:  ; $586F (au milieu de l'instruction ci-dessous, byte 2)
     cp $e2
     ld h, b
     ld e, l
@@ -4491,7 +3954,24 @@ DataZone_5733:
     ld h, e
     ld sp, $3131
     ld sp, $5d31
-    cp $71
+
+; ==============================================================================
+; TilesetBlock_58FE - Bloc de tiles graphiques 2BPP ($58FE-$596D)
+; ==============================================================================
+; Description: Bloc de 14 tiles graphiques 8x8 pixels, format 2BPP Game Boy
+; Taille: 112 octets ($70) = 14 tiles × 8 bytes
+; Référencé par: SharedTilesetData_024 (lignes 3382-3383) - 3 occurrences
+; Format: Séquence de tiles 2BPP (2 bits par pixel, 8 bytes par tile)
+; Note: Zone mal désassemblée comme code - devrait être reconstruite en 'db'
+; TODO BFS: Reconstruire en format:
+;   TilesetBlock_58FE:
+;       db $71, $64, $F1, $5D, $FE, $71, $64, $F1  ; Tile 0
+;       db $5D, $FE, $71, $64, $F1, $5D, $FE, $51  ; Tile 1
+;       ... (12 tiles de plus)
+; ==============================================================================
+    db $FE  ; Premier byte de l'instruction 'cp $71' (opcode FE)
+TilesetBlock_58FE:  ; $58FE - pointe vers le paramètre $71
+    db $71  ; Deuxième byte de 'cp $71'
     ld h, h
     pop af
     ld e, l
@@ -4535,438 +4015,330 @@ DataZone_5733:
     ld e, l
     cp $71
     ld h, h
-    pop af
-    ld e, l
-    cp $71
-    ld h, h
-    pop af
-    ld e, l
-    cp $71
-    ld h, h
-    pop af
-    ld e, l
-    cp $51
-    db $f4
-    ld [hl], c
-    ld h, h
-    pop af
-    ld e, l
-    cp $51
-    db $f4
-    ld [hl], c
-    ld h, h
-    pop af
-    ld e, l
-    cp $51
-    db $f4
-    ld [hl], c
-    ld h, h
-    pop af
-    ld e, l
-    cp $71
-    ld h, h
-    pop af
-    ld e, l
-    cp $71
-    ld h, h
-    pop af
-    ld e, l
-    cp $71
-    ld h, h
-    pop af
-    ld e, l
-    cp $31
-    db $f4
-    pop af
-    ld e, l
-    cp $31
-    db $f4
-    pop af
-    ld e, l
-    cp $f1
-    ld e, l
-    cp $79
-    ld h, b
-    ld e, d
-    ld e, d
-    ld e, d
-    ld e, d
-    ld e, d
-    ld e, d
-    ld e, d
-    ld e, l
-    cp $79
-    ld h, e
-    ld sp, $3131
-    ld sp, $3131
-    ld sp, $fe5d
-    or c
-    ld a, a
-    pop af
-    ld e, l
-    cp $b1
-    ld a, a
-    pop af
-    ld e, l
-    cp $b5
-    ld h, b
-    ld e, d
-    ld e, d
-    ld e, d
-    ld e, l
-    cp $b5
-    ld h, e
-    ld sp, $3131
-    ld e, l
-    cp $f1
-    ld e, l
-    cp $f1
-    ld e, l
-    cp $97
-    ld h, b
-    ld e, d
-    ld e, d
-    ld e, d
-    ld e, d
-    ld e, d
-    ld e, l
-    cp $97
-    ld h, e
-    ld sp, $3131
-    ld sp, $5d31
-    cp $91
-    ld a, a
-    pop af
-    ld e, l
-    cp $91
-    ld a, a
-    pop af
-    ld e, l
-    cp $91
-    ld a, a
-    pop af
-    ld e, l
-    cp $91
-    ld a, a
-    pop af
-    ld e, l
-    cp $91
-    ld a, a
-    pop af
-    ld e, l
-    cp $91
-    ld a, a
-    pop af
-    ld e, l
-    cp $91
-    ld a, a
-    pop af
-    ld e, l
-    cp $88
-    ld h, b
-    ld e, d
-    ld e, d
-    ld e, d
-    ld e, d
-    ld e, d
-    ld e, d
-    ld e, l
-    cp $88
-    ld h, e
-    ld sp, $3131
-    ld sp, $3131
-    ld e, l
-    cp $31
-    ld b, l
-    pop af
-    ld e, l
-    cp $22
-    ld b, d
-    ld b, [hl]
-    pop af
-    ld e, l
-    cp $22
-    ld b, e
-    ld b, a
-    ldh [c], a
-    ld h, h
-    ld e, l
-    cp $22
-    ld b, h
-    ld c, b
-    ldh [c], a
-    ld h, h
-    ld e, l
-    cp $e2
-    ld h, h
-    ld e, l
-    cp $e2
-    ld h, h
-    ld e, l
-    cp $f1
-    ld e, l
-    cp $f1
-    ld e, l
-    cp $22
-    add c
-    add d
-    pop af
-    ld e, l
-    cp $f1
+    pop af
     ld e, l
-    cp $f1
+    cp $71
+    ld h, h
+    pop af
     ld e, l
-    cp $31
-    add d
-    or c
-    ld a, a
+    cp $71
+    ld h, h
     pop af
     ld e, l
-    cp $35
-    add d
-    db $f4
-    db $f4
+    cp $51
     db $f4
-    add d
+    ld [hl], c
+    ld h, h
     pop af
     ld e, l
-    cp $44
-    db $f4
-    db $f4
+    cp $51
     db $f4
-    add d
+    ld [hl], c
+    ld h, h
     pop af
     ld e, l
-    cp $35
-    add d
-    db $f4
-    db $f4
+    cp $51
     db $f4
-    add d
+    ld [hl], c
+    ld h, h
     pop af
     ld e, l
-    cp $11
-    ld b, l
-    dec [hl]
-    db $fd
-    add d
+    cp $71
+    ld h, h
     pop af
     ld e, l
-    cp $02
-    ld b, d
-    ld b, [hl]
+    cp $71
+    ld h, h
     pop af
     ld e, l
-    cp $02
-    ld b, e
-    ld b, a
+    cp $71
+    ld h, h
     pop af
     ld e, l
-    cp $02
-    ld b, h
-    ld c, b
+    cp $31
+    db $f4
     pop af
     ld e, l
-    cp $f1
-    ld e, l
-    cp $f1
+    cp $31
+    db $f4
+    db $F1, $5D  ; Derniers 2 bytes de TilesetBlock_58FE ($596B-$596C)
+    db $FE       ; Dernier byte de TilesetBlock_58FE ($596D)
 
-PatternData_5a60:
-    adc [hl]
-    cp $f1
-    adc a
-    cp $f1
-    adc [hl]
-    cp $f1
-    adc a
-    cp $f1
-    adc [hl]
-    cp $f1
-    adc a
-    cp $f1
-    adc [hl]
-    cp $f1
-    adc a
-    cp $f1
-    adc [hl]
-    cp $f1
-    adc a
-    cp $f1
-    adc [hl]
-    cp $f1
-    adc a
-    cp $f1
-    adc [hl]
-    cp $f1
-    adc a
-    cp $f1
-    adc [hl]
-    cp $f1
-    adc a
-    cp $f1
-    adc [hl]
-    cp $21
-    adc [hl]
-    pop af
-    adc a
-    cp $00
-    inc de
-    inc h
-    adc a
-    adc [hl]
-    adc [hl]
-    adc [hl]
-    adc [hl]
-    adc [hl]
-    adc [hl]
-    adc [hl]
-    adc [hl]
-    adc [hl]
-    adc [hl]
-    inc de
-    inc h
-    adc [hl]
-    cp $00
-    ld hl, $8e56
-    adc a
-    adc a
-    adc a
-    adc a
-    adc a
-    adc a
-    adc a
-    adc a
-    adc a
-    adc a
-    ld hl, $8f56
-    cp $00
-    db $fd
+; ==============================================================================
+; TilesetBlock_596E - Tile graphique 2BPP ($596E-$5975)
+; ==============================================================================
+; Description: Tile graphique 8x8 pixels, format 2BPP Game Boy
+; Taille: 8 octets (1 tile × 8 bytes)
+; Référencé par: SharedTilesetData_024 (ligne 3382)
+; Format: Tile 2BPP (2 bits par pixel, 8 bytes par tile)
+; ==============================================================================
+TilesetBlock_596E:
+    db $F1, $5D, $FE, $79, $60, $5A, $5A, $5A
+    ld e, d
+    ld e, d
+    ld e, d
+    ld e, d
+    ld e, l
+    cp $79
+    ld h, e
+    ld sp, $3131
+    ld sp, $3131
+    ld sp, $fe5d
+    or c
     ld a, a
-    cp $a1
-    ld e, a
     pop af
+    ld e, l
+    cp $b1
     ld a, a
+    pop af
+    ld e, l
+    cp $b5
+    ld h, b
+    ld e, d
+    ld e, d
+    ld e, d
+    ld e, l
+    cp $b5
+    ld h, e
+    ld sp, $3131
+    ld e, l
     cp $f1
-    ld a, a
+    ld e, l
     cp $f1
-    ld a, a
-    cp $05
-    db $fd
-    ld a, a
-    pop af
-    ld a, a
-    cp $05
-    ld a, a
-    db $f4
-    db $f4
-    db $f4
+    ld e, l
+    cp $97
+    ld h, b
+    ld e, d
+    ld e, d
+    ld e, d
+    ld e, d
+    ld e, d
+    ld e, l
+    cp $97
+    ld h, e
+    ld sp, $3131
+    ld sp, $5d31
+    cp $91
     ld a, a
     pop af
+    ld e, l
+    cp $91
     ld a, a
-    cp $05
-    ld a, a
-    db $f4
-    db $f4
-    db $f4
-    ld a, a
-    ldh [c], a
-    db $fd
-    ld a, a
-    cp $05
-    ld a, a
-    db $f4
-    db $f4
-    db $f4
-    ld a, a
-    and c
-    add d
-    ldh [c], a
-    db $fd
-    ld a, a
-    cp $05
-    ld a, a
-    db $f4
-    db $f4
-    db $f4
-    add d
-    ld [hl], c
-    add d
-    and c
-    ld a, a
-    ldh [c], a
-    db $fd
-    ld a, a
-    cp $06
-    ld a, a
-    db $f4
-    db $f4
-    db $f4
-    ld a, a
-    ld a, a
-    sub c
-    add b
-    ldh [c], a
-    db $fd
-    ld a, a
-    cp $06
-    ld a, a
-    db $f4
-    db $f4
-    db $f4
-    db $f4
-    ld a, a
-    sub a
-    db $fd
-    ld a, a
-    cp $06
-    ld a, a
-    db $f4
-    db $f4
-    db $f4
-    db $f4
-    ld a, a
-    and [hl]
-    db $f4
-    db $f4
-    db $f4
-    ld a, a
-    ld a, a
+    pop af
+    ld e, l
+    cp $91
     ld a, a
-    cp $06
+    pop af
+    ld e, l
+    cp $91
     ld a, a
-    db $f4
-    db $f4
-    db $f4
-    db $f4
+    pop af
+    ld e, l
+    cp $91
     ld a, a
-    sub a
+    pop af
+    ld e, l
+    cp $91
     ld a, a
-    db $f4
-    db $f4
-    db $f4
-    db $f4
-    db $f4
+    pop af
+    ld e, l
+    cp $91
     ld a, a
-    cp $06
+    pop af
+    ld e, l
+    cp $88
+    ld h, b
+    ld e, d
+    ld e, d
+    ld e, d
+    ld e, d
+    ld e, d
+    ld e, d
+    ld e, l
+    cp $88
+    ld h, e
+    ld sp, $3131
+    ld sp, $3131
+    ld e, l
+    cp $31
+    ld b, l
+    pop af
+    ld e, l
+    cp $22
+    ld b, d
+    ld b, [hl]
+    pop af
+    ld e, l
+    cp $22
+    ld b, e
+    ld b, a
+    ldh [c], a
+    ld h, h
+    ld e, l
+    cp $22
+    ld b, h
+    ld c, b
+    ldh [c], a
+    ld h, h
+    ld e, l
+    cp $e2
+    ld h, h
+    ld e, l
+    cp $e2
+    ld h, h
+    ld e, l
+    cp $f1
+    ld e, l
+    cp $f1
+    ld e, l
+    cp $22
+    add c
+    add d
+    pop af
+    ld e, l
+    cp $f1
+    ld e, l
+    cp $f1
+    ld e, l
+    cp $31
+    add d
+    or c
     ld a, a
+    pop af
+    ld e, l
+    cp $35
+    add d
     db $f4
     db $f4
     db $f4
-    db $f4
-    ld a, a
-    sub a
-    ld a, a
-    db $f4
-    db $f4
+    add d
+    pop af
+    ld e, l
+    cp $44
     db $f4
     db $f4
     db $f4
-    ld a, a
-    cp $08
-    ld a, a
+    add d
+    pop af
+    ld e, l
+    cp $35
+    add d
     db $f4
     db $f4
     db $f4
+    add d
+    pop af
+    ld e, l
+    cp $11
+    ld b, l
+    dec [hl]
+    db $fd
+    add d
+    pop af
+    ld e, l
+    cp $02
+    ld b, d
+    ld b, [hl]
+    pop af
+    ld e, l
+    cp $02
+    ld b, e
+    ld b, a
+    pop af
+    ld e, l
+; ==============================================================================
+; CompressedData_5A55 - Données compressées (tileset/map)
+; ==============================================================================
+; Description: Données compressées faisant partie du flux de compression
+;              utilisé pour décoder tiles/maps (continuation depuis $56CB)
+; Adresse: $5A55-$5A5F (11 bytes)
+; Format: Commandes de compression + arguments
+;   $5D $FE: Commande de répétition/copie
+;   $02/$F1: Arguments de commande ou données brutes
+; Référencé par:
+;   - SharedTilesetData_024 (ligne 3383): pointeur $5A5F
+;   - SharedMapData_012 (ligne 3398): pointeur $5A5F
+; Note: Cette zone fait partie de la grande zone mal désassemblée $56CB-$5A5F
+;       documentée ligne 3467. C'est des DONNÉES, pas du code exécutable.
+; ==============================================================================
+CompressedData_5A55:  ; $5A55
+    db $FE, $02, $44, $48, $F1  ; $5A55-$5A59: Commande compression type 1
+    db $5D                       ; $5A5A: Marqueur/commande
+TilesetPointer_5A5B:  ; $5A5B - Pointeur utilisé dans tables tilesets
+    db $FE, $F1                  ; $5A5B-$5A5C: Commande compression type 2
+    db $5D                       ; $5A5D: Marqueur/commande
+TilesetPointer_5A5F:  ; $5A5F - Pointeur vers TilePatternData_5A60
+    db $FE, $F1                  ; $5A5E-$5A5F: Commande compression type 2
+
+; PatternData_5a60
+; ----------------
+; Description: Données de pattern compressées (50 bytes)
+;              Format: séquences de commandes de décompression
+;              Pattern répété: $8E $FE $F1 $8F $FE $F1
+; Utilisation: Référencé à $5A5F (TilesetPointer)
+PatternData_5a60:
+    db $8E, $FE, $F1, $8F, $FE, $F1  ; Pattern répété x8
+    db $8E, $FE, $F1, $8F, $FE, $F1
+    db $8E, $FE, $F1, $8F, $FE, $F1
+    db $8E, $FE, $F1, $8F, $FE, $F1
+    db $8E, $FE, $F1, $8F, $FE, $F1
+    db $8E, $FE, $F1, $8F, $FE, $F1
+    db $8E, $FE, $F1, $8F, $FE, $F1
+    db $8E, $FE, $F1, $8F, $FE, $F1
+    db $8E, $FE                       ; Pattern partiel final
+
+; ==============================================================================
+; CompressedTileData_5A92 - Données compressées de tiles/map ($5A92-$5B48)
+; ==============================================================================
+; Description: Bloc de données compressées (pattern/commandes de compression)
+;              Contient des tiles graphiques et des commandes de décompression
+; Taille: 183 bytes
+; Référencé par: SharedTilesetData_024, SharedMapData_012
+; Format: Mélange de commandes compression ($FE, $FD) et données raw
+; ==============================================================================
+CompressedTileData_5A92:  ; $5A92
+    db $21, $8E, $F1, $8F, $FE, $00, $13, $24
+    db $8F, $8E, $8E, $8E, $8E, $8E, $8E, $8E
+    db $8E, $8E, $8E, $13, $24, $8E, $FE, $00
+    db $21, $56, $8E, $8F, $8F, $8F, $8F, $8F
+    db $8F, $8F, $8F, $8F, $8F, $21, $56, $8F
+    db $FE
+
+; ==============================================================================
+; TileGraphic_5ABB - Tile graphique 8x8 pixels (8 bytes)
+; ==============================================================================
+; Description: Tile graphique au format 2BPP Game Boy
+;              Pattern: $00 $FD $7F $FE $A1 $5F $F1 $7F
+; In: Aucun (données, pas du code exécutable)
+; Out: Aucun
+; Modifie: Aucun
+; Taille: 8 octets (1 tile)
+; Référencé par:
+;   - SharedTilesetData_024 (ligne 3381) - niveaux 0,1,2,4
+;   - SharedMapData_012 (ligne 3396) - niveaux 0,1,2
+; Format: 8 bytes 2BPP (2 bits par pixel)
+; ==============================================================================
+TileGraphic_5ABB:  ; $5ABB
+    db $00, $FD, $7F, $FE, $A1, $5F, $F1, $7F
+
+; Continuation données compressées après TileGraphic_5ABB
+    db $FE, $F1, $7F, $FE, $F1, $7F, $FE, $05
+    db $FD, $7F, $F1, $7F, $FE, $05, $7F, $F4
+    db $F4, $F4, $7F, $F1, $7F, $FE, $05, $7F
+    db $F4, $F4, $F4, $7F, $E2, $FD, $7F, $FE
+    db $05, $7F, $F4, $F4, $F4, $7F, $A1, $82
+    db $E2, $FD, $7F, $FE, $05, $7F, $F4, $F4
+    db $F4, $82, $71, $82, $A1, $7F, $E2, $FD
+    db $7F, $FE, $06, $7F, $F4, $F4, $F4, $7F
+    db $7F, $91, $80, $E2, $FD, $7F, $FE, $06
+    db $7F, $F4, $F4, $F4, $F4, $7F, $97, $FD
+    db $7F, $FE, $06, $7F, $F4, $F4, $F4, $F4
+    db $7F, $A6, $F4, $F4, $F4, $7F, $7F, $7F
+    db $FE, $06, $7F, $F4, $F4, $F4, $F4, $7F
+    db $97, $7F, $F4, $F4, $F4, $F4, $F4, $7F
+    db $FE, $06, $7F, $F4, $F4, $F4, $F4, $7F
+    db $97, $7F, $F4, $F4, $F4, $F4, $F4, $7F
+    db $FE, $08, $7F, $F4, $F4, $F4
 
 ProcessLevelData_5b49:
     db $f4
@@ -5053,123 +4425,28 @@ ProcessLevelData_5b49:
     ld a, a
     ld a, a
     ld a, a
-    cp $f1
-    ld e, l
-    cp $f1
-    ld e, l
-    cp $e2
-    ld h, l
-    ld e, l
-    cp $42
-    add hl, sp
-    dec a
-    ldh [c], a
-    ld h, [hl]
-    ld e, l
-    cp $24
-    inc sp
-    ld [hl], $3a
-    ld a, $e2
-    ld h, l
-    ld e, l
-    cp $2e
-    inc [hl]
-    scf
-    ld b, c
-    ld e, b
-    ld e, c
-    ld e, c
-    ld e, c
-    ld e, c
-    ld e, c
-    ld e, c
-    ld e, c
-    ld e, c
-    ld h, [hl]
-    ld e, l
-    cp $24
-    dec [hl]
-    jr c, DataZone_5c0c
-
-    ccf
-    ldh [c], a
-    ld h, l
-    ld e, l
-    cp $42
-    inc a
-    ld b, b
-    ldh [c], a
-    ld h, [hl]
-    ld e, l
-    cp $e2
-    ld h, l
-    ld e, l
-    cp $e2
-    ld h, [hl]
-    ld e, l
-    cp $e2
-    ld h, l
-    ld e, l
-    cp $e2
-    ld h, [hl]
-    ld e, l
-    cp $e2
-    ld h, l
-    ld e, l
-    cp $21
-    ld b, l
-    ldh [c], a
-    ld h, [hl]
-    ld e, l
-    cp $12
-    ld b, d
-    ld b, [hl]
-    ldh [c], a
-    ld h, l
-    ld e, l
-    cp $12
-    ld b, e
-    ld b, a
-    ldh [c], a
-    ld h, [hl]
-    ld e, l
-    cp $12
-    ld b, h
-    ld c, b
-    or l
-    ld h, a
-    ld l, c
-    ld h, a
+    db $FE  ; Dernier byte de ProcessLevelData_5b49 ($5BA2)
 
-DataZone_5c0c:
-    ld l, c
-    ld e, l
-    cp $b5
-    ld l, b
-    ld l, d
-    ld l, b
-    ld l, d
-    ld e, l
-    cp $b2
-    ld h, a
-    ld l, c
-    pop af
-    ld e, l
-    cp $b2
-    ld l, b
-    ld l, d
-    pop af
-    ld e, l
-    cp $b2
-    ld h, a
-    ld l, c
-    pop af
-    ld e, l
-    cp $b2
-    ld l, b
-    ld l, d
-    pop af
-    ld e, l
+; ==============================================================================
+; MapTileData_5BA3 - Données de map encodées ($5BA3-$5C21)
+; ==============================================================================
+; Description: Données de tiles/map encodées, utilisées pour construire le layout
+; Format: Séquence de bytes encodés (opcodes de compression/repeat + paramètres)
+;         Pattern: $FE = commande, $F1/$E2/$5D = fin/séparateur, autres = données
+; Taille: 127 octets ($7F)
+; Référencé par: SharedMapData_012 (ligne 3396) - niveaux 0, 1, 2
+; ==============================================================================
+MapTileData_5BA3:  ; $5BA3
+    db $F1, $5D, $FE, $F1, $5D, $FE, $E2, $65, $5D, $FE, $42, $39, $3D, $E2, $66, $5D
+    db $FE, $24, $33, $36, $3A, $3E, $E2, $65, $5D, $FE, $2E, $34, $37, $41, $58, $59
+    db $59, $59, $59, $59, $59, $59, $59, $66, $5D, $FE, $24, $35, $38, $3B, $3F, $E2
+    db $65, $5D, $FE, $42, $3C, $40, $E2, $66, $5D, $FE, $E2, $65, $5D, $FE, $E2, $66
+    db $5D, $FE, $E2, $65, $5D, $FE, $E2, $66, $5D, $FE, $E2, $65, $5D, $FE, $21, $45
+    db $E2, $66, $5D, $FE, $12, $42, $46, $E2, $65, $5D, $FE, $12, $43, $47, $E2, $66
+    db $5D, $FE, $12, $44, $48, $B5, $67, $69, $67, $69, $5D, $FE, $B5, $68, $6A, $68
+    db $6A, $5D, $FE, $B2, $67, $69, $F1, $5D, $FE, $B2, $68, $6A, $F1, $5D, $FE
+
+; Suite: données mal désassemblées à $5C22 (à reconstruire dans un futur nœud BFS)
     cp $b2
     ld h, a
     ld l, c
@@ -6327,7 +5604,7 @@ CheckResult_5c5b:
     ld e, l
     ld c, d
     ld e, [hl]
-    call nz, ValidateCondition_534f
+    db $C4, $4F, $53  ; call nz, $534f (data within SharedMapData_467, not code)
     ld l, h
     ld l, [hl]
     cp $03
@@ -6943,7 +6220,7 @@ CheckResult_5c5b:
     ld e, l
     ld c, d
     ld e, [hl]
-    call nz, ValidateCondition_534f
+    db $C4, $4F, $53  ; call nz, $534f (data within SharedMapData_467, not code)
     ld l, l
     ld l, [hl]
     cp $03
@@ -6998,7 +6275,7 @@ CheckResult_5c5b:
     ld e, l
     ld c, d
     ld e, [hl]
-    call nz, ValidateCondition_534f
+    db $C4, $4F, $53  ; call nz, $534f (data within SharedMapData_467, not code)
     ld l, h
     ld l, [hl]
     cp $03
@@ -7057,7 +6334,7 @@ CheckResult_5c5b:
     ld e, l
     ld c, d
     ld e, [hl]
-    call nz, ValidateCondition_534f
+    db $C4, $4F, $53  ; call nz, $534f (data within SharedMapData_467, not code)
     ld l, l
     ld l, [hl]
     cp $03
@@ -7112,7 +6389,7 @@ CheckResult_5c5b:
     db $f4
     sub c
     db $f4
-    call nz, ValidateCondition_534f
+    db $C4, $4F, $53  ; call nz, $534f (data within SharedMapData_467, not code)
     ld l, h
     ld l, [hl]
     cp $03

</DiffGit>

Tes réflexions produites dans la production finale. Ces commenentaires ont été coupés.
<ReflexionAgent>

 │ - Extraire les références sortantes pour continuer le BFS
│ Commençons par localiser le code à l'adresse $5C9D dans le fichier source.
│ Je vois que $5C9D correspond au label `SpriteAnimationType50Data` (ligne 1173 du fichier game.sym). 
│ Parfait ! Je vois maintenant la table elle-même. Continuons la lecture pour voir la table de données
│ Parfait ! J'ai trouvé la table de données. Maintenant je vais analyser plus en détail et chercher d'
│ Excellent ! La table est bien référencée. Maintenant vérifions le contexte autour de la table pour c
│ Excellent ! Toutes les constantes sont déjà définies. Maintenant vérifions `make verify` pour confir
│   "summary": "Table de 65 bytes contenant 16 frames d'animation (4 tile IDs par frame) pour sprites 
│ }
│ ```

</ReflexionAgent>

Je veux que tu améliores le [fichier des conseils](../recommendations.md) en y insérant :
- des critiques sur le prompt initial
- des pistes d'améliorations
- les découvertes que tu pourrais faire

Dans ce meme fichier, je souhaite que tu établisses une note de réalisation pour cette étape