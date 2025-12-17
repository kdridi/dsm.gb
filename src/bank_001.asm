SECTION "ROM Bank $001", ROMX[$4000], BANK[$1]

; LevelJumpTable
; ----------------
; Description: Table des pointeurs pour chaque niveau (triplets: tileset/map/entities)
; Structure: Chaque niveau utilise 3 pointeurs (6 octets)
;   - +0: Pointeur tileset
;   - +2: Pointeur map data
;   - +4: Pointeur entities
LevelJumpTable:
    ; Niveau 0
    dw SharedTilesetData_024, SharedMapData_012, SharedEntitiesData_012
    ; Niveau 1
    dw SharedTilesetData_024, SharedMapData_012, SharedEntitiesData_012
    ; Niveau 2
    dw SharedTilesetData_024, SharedMapData_012, SharedEntitiesData_012
    ; Niveau 3
    dw Level3TilesetData, Level3MapData, Level3EntitiesData
    ; Niveau 4
    dw SharedTilesetData_024, SharedMapData_467, $5405
    ; Niveau 5
    dw SharedTilesetData_578, Level5MapData, Level5EntitiesData
    ; Niveau 6
    dw Level6TilesetData, SharedMapData_467, $5405
    ; Niveau 7
    dw SharedTilesetData_578, SharedMapData_467, $5405
    ; Niveau 8 (incomplet)
    dw SharedTilesetData_578

; ==============================================================================
; ROM_WORLD1_TILES - Données graphiques mondes 1 et 2 ($4032-$4401)
; ==============================================================================
; Description: Zone de tiles graphiques utilisés pour les mondes 1 et 2
;              Cette section est mal désassemblée comme code, mais contient
;              réellement des données graphiques (tiles 8x8, 2bpp)
; Référencé par: GraphicsTableA ($0DE4) pointe vers $4032
; Destination: Copié vers VRAM $8A00 par CopyPatternTileDataLoop
; Taille: $3D0 octets (976 bytes = 61 tiles)
; Format: Chaque tile = 16 octets (8x8 pixels, 2 bits par pixel)
; Note: Les labels dans cette section (ProcessDataValue_4055, etc.) pointent
;       vers des octets de données, pas du code exécutable
; ==============================================================================
ROM_WORLD1_TILES:  ; $4032
    rrca  ; Début données tiles (mal désassemblé)

CalculateOffset_4033:
    rrca
    rra
    jr RotateAndAdjust_4072

    jr nc, AdjustValue_4070

    jr nz, ShiftAccumulator_407a

    daa
    ld a, [hl-]
    ld a, [hl+]

HandlePaletteLookup:
    add hl, sp
    add hl, hl
    ccf
    ld h, $f0
    ldh a, [$ffd8]
    jr c, CalculateOffset_4033

    inc e
    db $f4
    inc c
    db $f4
    db $ec
    ld d, h
    ld e, h
    sub h
    sbc h
    db $f4
    ld l, h
    nop
    nop
    rrca

ProcessDataValue_4055:
    rrca
    ccf
    jr c, RotateAndAdjust_40d4

    ld h, b
    ld [hl], a
    ld b, b
    ld a, a
    ld b, a
    ld a, d
    ld c, d
    ld a, c
    ld c, c
    nop
    nop
    ldh a, [hCurrentTile]
    db $fc
    inc e
    or $0e

PreprocessData_406a:
    ld a, [$fa06]
    and $5a
    ld d, [hl]

AdjustValue_4070:
    sbc d
    sub [hl]

RotateAndAdjust_4072:
    nop
    nop
    inc bc
    inc bc
    rlca
    rlca
    inc c
    inc c

ShiftAccumulator_407a:
    ld [de], a
    ld e, $3c
    inc a
    db $e3
    rst $38
    ld b, e
    ld b, e
    nop
    nop
    ld hl, sp-$08
    add b
    ret nz

    ldh [hVramPtrLow], a
    add [hl]
    and $eb
    jp hl


    dec e
    pop af
    ld a, l
    ld h, c
    ld bc, $0301
    inc bc
    ld b, $06
    dec bc
    rrca
    ld e, $1e
    ld [hl], c
    ld a, a
    ld h, $26
    rrca
    ld [$fcfc], sp
    ret nz

    ldh [rSVBK], a
    ld [hl], b
    ld b, b
    ld [hl], b
    ld a, b
    ld a, b
    xor h
    db $e4
    db $f4
    call nz, $4474
    rra
    rra
    ld [hl-], a
    inc sp
    ld a, d
    ld e, e
    di
    sub d
    rst $38
    adc h
    ld a, h
    ld [hl], b
    ld [hl], b
    ld b, b
    ccf
    ccf
    add $c6
    ld l, $ea
    ld a, [hl]
    ld a, [$a2be]
    cp d
    and d
    ld a, d
    ld a, d
    ld l, d
    ld l, d
    add [hl]
    add [hl]
    nop
    nop

RotateAndAdjust_40d4:
    rlca
    rlca
    jr PaddingAlign_40f7

    daa
    jr c, PaddingAlign_410a

    jr nc, @+$5e

    ld h, b
    ld e, b
    ld h, b
    ld e, b
    ld h, b
    nop
    nop
    nop
    nop
    inc bc
    inc bc
    inc c
    rrca
    inc de
    inc e
    rla
    jr ProcessSoundRegister

    jr nc, ProcessSoundRegister

    jr nc, PaddingAlign_40f3

PaddingAlign_40f3:
    nop
    nop
    nop
    nop

PaddingAlign_40f7:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

PaddingAlign_410a:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $0301

StoreAndRotateValue:
    ld [bc], a
    rlca
    rlca
    ld [$0d08], sp
    dec c
    rra

ProcessSoundRegister:
    rra
    rst $38
    ldh a, [$ffbf]
    add b
    ld hl, sp-$08
    ldh [rNR41], a
    ld hl, sp-$68
    ldh a, [$ff90]
    ld hl, sp-$78
    ldh a, [$ff30]
    ldh [rNR41], a
    ldh a, [$ff30]
    rra
    db $10
    rrca
    add hl, bc
    rra
    ld de, $1c17
    dec e
    rra
    rra
    dec d
    dec e
    rla
    rrca
    dec c
    ret z

    jr c, StoreAndRotateValue

    or b

PaddingTrap_4146:
    ld hl, sp-$78
    ld hl, sp+$38
    cp b
    add sp, -$18
    cp b
    cp b
    add sp, -$10
    or b
    ccf
    ld h, $1f
    db $10
    ld a, a
    ld h, c
    rst $18
    cp b
    ei
    or a
    cp h
    db $f4
    ld a, [hl]
    ld e, d
    inc h
    inc h
    db $f4
    ld l, h
    add sp, $18
    cp $86
    ei
    dec e
    rst $18
    db $ed
    dec a
    cpl
    ld a, [hl]
    ld e, d
    inc h
    inc h
    inc bc
    ld [bc], a
    inc bc
    ld [bc], a
    inc bc
    ld [bc], a
    ld bc, $0801
    ld [$0c0c], sp
    inc b
    rlca
    inc bc

LoopCarryClearBit_4181:
    inc bc
    cp a
    ld hl, $3ebe
    or b
    jr nc, LoopCarryClearBit_4181

    ld a, b
    add b
    ld hl, sp-$08
    ld hl, sp+$00
    ldh a, [hSoundId]
    ret nz

    rrca
    ld [$080f], sp
    rrca
    ld [$0407], sp
    inc hl
    inc hl
    ld sp, $1831
    rra
    rrca
    rrca
    ld a, h
    ld b, h
    ld a, b
    ld a, b
    ld [hl], b
    ld [hl], b
    ldh a, [rSVBK]
    add b
    ldh a, [hCurrentTile]
    ldh a, [rP1]
    ldh [hSoundId], a
    ret nz

    ccf
    ccf
    ld a, c
    ld l, c
    db $fd
    adc l
    ld a, c
    ld l, c
    rra
    ld d, $0f
    ld [$101c], sp
    ld a, a
    ld a, a
    ldh [hVramPtrLow], a
    dec de
    ei
    cpl
    db $ed
    rst $08
    ld c, c
    call StoreAudioChannel4
    dec hl
    jr c, @+$3a

    ret nz

    ret nz

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $0701
    ld b, $00
    nop
    ccf
    ccf
    ld a, [hl]
    ld b, [hl]
    ld a, a
    ld a, c
    adc [hl]
    adc d
    rst $18
    reti


    cp $f6
    db $fc
    inc b
    nop
    nop
    nop
    nop
    ld bc, $0101
    ld bc, $0202
    rrca
    inc c
    or a
    or c
    ld a, [hl]
    ld a, [hl]
    db $fc
    call nz, $88f8
    ld a, b
    ld [$10f0], sp
    ldh [rNR41], a
    ret nz

    ld b, b
    add b
    add b
    nop
    nop
    ld e, a
    ld c, a
    pop af
    pop af
    ld c, $0e
    add hl, de
    jr @+$12

    db $10
    db $10
    db $10
    add hl, de
    jr RotationDataEntry_4228

    ld b, $f6
    or $fd
    xor l
    push af
    rla

RotationDataEntry_4228:
    db $fd
    rrca
    ld [$ea1e], a
    ld e, $cb
    ccf
    sbc e
    ld a, a
    inc b
    inc b
    adc [hl]
    adc d
    adc [hl]
    adc d
    rst $18
    pop de
    rst $38
    xor a
    push af
    sub l
    or c

ValidateOrTransformValue:
PaddingAlign_423f:
    sub c
    cp a
    adc a
    jr PaddingAlign_425c

    ld a, h
    ld h, h
    cp $a2
    cp $ae
    or l
    sub l
    or c
    sub c
    sbc a
    adc a
    ld a, [hl]
    ld a, [hl]
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

PaddingAlign_425c:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    rlca
    rlca
    add hl, bc
    ld c, $1a
    inc e
    ld h, $24
    ld l, $2c
    ld h, $24
    ccf
    ccf
    nop
    nop
    ldh [hVramPtrLow], a
    sub b
    ld [hl], b
    ld e, b
    jr c, ProcessCarryFlag_42ef

    inc h
    ld [hl], h
    inc [hl]
    ld h, h
    inc h
    db $fc
    db $fc
    rlca
    rlca
    add hl, bc
    ld c, $1a
    inc e
    ld h, $24
    ld l, $2c
    ld h, $24
    ccf
    ccf
    nop
    nop
    ldh [hVramPtrLow], a
    sub b
    ld [hl], b
    ld e, b
    jr c, @+$66

    inc h
    ld [hl], h
    inc [hl]
    ld h, h
    inc h
    db $fc
    db $fc
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    rra
    inc e
    rla
    ld de, $0a0a
    inc c
    inc c
    inc bc
    inc bc
    dec c
    inc c
    ld de, $2110

BusyWait_IfNotZero:
    jr nz, BusyWait_IfNotZero

    ld b, $fb
    adc e
    or c
    pop de
    xor c
    pop hl
    ld e, e
    pop bc
    ld a, c
    rst $00
    cp c

ProcessCarryFlag_42ef:
    add a
    ldh a, [c]
    adc [hl]
    jr nz, LoadStaticValue_4314

    jr nz, @+$22

    ld sp, $3931
    add hl, sp
    ccf
    ld h, $1f
    db $10
    rrca
    rrca
    nop
    nop
    cp h
    add h
    db $fc
    call nz, $84bc
    db $fc
    call z, CheckPlayerCollisionWithObject
    ldh a, [rSVBK]
    ret nz

    ret nz

    nop
    nop
    rlca
    rlca

LoadStaticValue_4314:
    ld bc, $0101
    ld bc, $0101
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    db $fd
    rst $38
    ld a, c
    ccf
    ld [hl], c
    ccf
    ld h, [hl]
    ld a, d
    xor $f2
    adc [hl]
    ldh a, [c]
    ld e, [hl]
    ld h, d
    ld a, [hl]
    ld b, [hl]
    ld a, [hl]
    ld a, [hl]
    db $10
    db $10
    ld a, h
    ld a, h
    db $10
    db $10
    ld a, h
    ld a, h
    jr c, JumpIfCarryClear_B2BC

    ld b, h
    ld b, h
    ld a, h
    ld a, h
    db $10
    db $10
    ld a, h
    ld a, h
    db $10
    db $10
    ld a, h
    ld a, h
    db $10
    db $10
    jr z, JumpIfCarryClear_B2BC

    ld b, h
    ld b, h
    ld a, h
    ld a, h
    nop
    nop
    nop

InitializeLevel_4355:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld [hl-], a
    inc a
    ld [hl], d
    ld e, h

JumpIfCarryClear_B2BC:
    jp nc, $b2bc

    db $fc
    rst $18
    rst $18
    inc d
    inc e
    ld [hl], h
    ld l, h
    ld d, h
    ld l, h
    ld c, h
    inc a
    ld c, [hl]
    ld a, [hl-]
    ld c, e
    dec a
    ld c, l
    ccf
    ei
    ei
    jr z, UpdateStateCounter

    ld l, $36
    ld a, [hl+]
    ld [hl], $df
    rst $18
    ldh a, [c]
    cp h
    or d
    call c, DataShim_7c52
    ccf
    ccf
    ld a, [bc]
    ld c, $3a
    ld [hl], $2a
    ld [hl], $fb
    ei
    ld c, a
    dec a
    ld c, l
    dec sp
    ld c, d
    ld a, $fc
    db $fc
    ld d, b
    ld [hl], b
    ld e, h
    ld l, h
    ld d, h
    ld l, h
    rlca
    rlca
    add hl, de
    ld e, $2a
    inc l
    ccf
    ccf
    or [hl]
    ret c

    rst $38
    rst $38
    inc d
    inc e
    ld d, h
    ld l, h
    ldh [hVramPtrLow], a
    sbc b
    ld a, b

UpdateStateCounter:
    ld d, h
    inc [hl]
    db $fc
    db $fc
    ld l, l
    dec de
    rst $38
    rst $38
    jr z, ReturnIfZero_4408

    ld a, [hl+]
    ld [hl], $27
    jr nz, @+$31

    jr nz, RstMarker_4416

    jr nz, RstMarkerBlock_4417

    ld hl, $333c
    jr ContinueProcessing_43fd

    rrca
    rrca
    inc bc
    inc bc
    call nz, $f8bc
    ld hl, sp+$70
    ldh a, [$ff30]
    ldh a, [rSVBK]
    ldh a, [$ffd8]
    add sp, -$64
    db $e4
    inc a
    call nz, RST_00
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

; ==============================================================================
; ROM_WORLD1_PALETTE - Données palette mondes 1 et 2 ($4402-$46C2)
; ==============================================================================
; Description: Palette graphique complète pour les mondes 1 et 2 (identiques)
;              Contient les couleurs et données graphiques pour l'affichage
; Référencé par: GraphicsTableB ($0DEA) pointe vers $4402
; Destination: Copié vers VRAM $9310 par CopyColorPaletteDataLoop
; Taille: $2C1 octets (705 bytes)
; Format: Données de palette Game Boy (format propriétaire)
; Note: La copie continue jusqu'à ce que hl atteigne $9700 (VRAM_COPY_LIMIT_HIGH)
;       Après cette palette (à $46C3), se trouve ROM_WORLD1_ANIM_DATA
; ==============================================================================

; Padding avant la palette ($43FD-$4401)
ContinueProcessing_43fd:
    db $00, $00, $00, $00, $00

; Données de la palette à $4402 (adresse ROM_WORLD1_PALETTE)
World1PaletteData:
    db $01, $00, $03, $00, $05, $00
ReturnIfZero_4408:  ; $4408 - Label conservé pour compatibilité
    db $09, $00, $01, $00, $03, $00, $05, $00, $09, $00, $FF, $3C, $FF, $7E
RstMarker_4416:  ; $4416 - Label conservé pour compatibilité
    db $FF
RstMarkerBlock_4417:  ; $4417 - Label conservé pour compatibilité
    db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $01
    db $01, $07, $06, $0E, $08, $1F, $1F, $1C, $10, $1F, $1F, $3C, $3C, $56, $4E, $FF
    db $FF, $39, $07, $7C, $03, $FF, $FF, $FC, $03, $FF, $FF, $00, $00, $00, $00, $80
    db $80, $E0, $E0, $70, $F0, $F8, $F8, $38, $F8, $F8, $F8, $1E, $16, $19, $19, $19
    db $19, $1E, $16, $1C, $10, $1C, $10, $3F, $3F, $DD, $CC, $7E, $19, $66, $25, $66
    db $25, $7E, $19, $7E, $01, $7E, $01, $FF, $FF, $EF, $63, $78, $F8, $98, $98, $98
    db $98, $78, $F8, $38, $F8, $38, $F8, $FC, $FC, $1F, $FF, $03, $03, $07, $04, $0F
    db $08, $1F, $10, $1E, $10, $3C, $20, $3F, $3F, $20, $20, $FF, $FF, $C3, $00, $87
    db $00, $0F, $00, $0F, $00, $1F, $00, $FF, $FF, $00, $00, $FF, $FF, $C1, $3F, $E0
    db $1F, $F0, $0F, $F8, $07, $FC, $03, $FF, $FF, $00, $00, $C0, $C0, $E0, $E0, $70
    db $F0, $38, $F8, $38, $F8, $1C, $FC, $FC, $FC, $1C, $7C, $40, $7F, $7F, $7F, $80
    db $80, $80, $FF, $FF, $FF, $10, $10, $0C, $0C, $03, $03, $00, $FF, $FF, $FF, $00
    db $00, $00, $FF, $FF, $FF, $08, $38, $30, $F0, $C0, $C0, $00, $FF, $FF, $FF, $00
    db $00, $00, $FF, $FF, $FF, $10, $10, $0C, $0C, $03, $03, $0E, $FE, $FE, $FE, $07
    db $3F, $07, $FF, $FF, $FF, $08, $38, $30, $F0, $C0, $C0, $FF, $FF, $FF, $00, $FF
    db $00, $FF, $00, $FF, $00, $FF, $00, $FF, $FF, $00, $00, $00, $00, $00, $00, $03
    db $03, $0C, $0C, $10, $10, $20, $20, $20, $20, $40, $40, $00, $00, $00, $00, $80
    db $80, $40, $40, $24, $24, $1A, $1A, $01, $01, $06, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00
DataPadding_453e:  ; $453E - Label conservé pour compatibilité
    db $80, $80, $40, $40, $01, $01, $02, $02, $04, $04, $0F, $08, $07, $04, $03, $02
    db $01, $01, $00, $00, $80, $80, $00, $00, $C1, $00, $F7, $00, $FF, $00, $FF, $40
    db $FF, $E3, $3E, $3E, $13, $00, $99, $00, $C1, $00, $E3, $00, $FF, $00, $FF, $80
    db $7F, $41, $3E, $3E, $40, $40, $A0, $20, $E0, $20, $C0, $40, $C0, $40, $80, $80
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $10, $00, $28, $00, $10, $00, $00
    db $00, $00, $00, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
    db $00, $FF, $00, $FF, $00, $FF, $00, $00, $00, $FF, $00, $00, $00, $FF, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $03, $00, $0C
    db $00, $10, $00, $20, $00, $52, $00, $52, $00, $4C, $00, $FF, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $4A, $00, $4A, $00, $32, $00, $FF, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $C0, $00, $30
    db $00, $08, $00, $04, $00, $40, $00, $40, $00, $3F, $00, $40, $00, $3F, $00, $10
    db $00, $08, $00, $07, $00, $00, $00, $00, $00, $FF, $00, $00, $00, $FF, $00, $48
    db $00, $84, $00, $03, $00, $00, $00, $00, $00, $FF, $00, $00, $00, $FF, $00, $12
    db $00, $21, $00, $C0, $00, $02, $00, $02, $00, $FC, $00, $02, $00, $FC, $00, $08
    db $00, $10, $00, $E0, $00, $01, $00, $02, $00, $0F, $00, $10, $00, $3F, $00, $40
    db $00, $7F, $00, $4C, $00, $80, $00, $40, $00, $F0, $00, $08, $00, $FC, $00, $02
    db $00, $FE, $00, $32, $FD, $FB, $FD, $FB, $FD, $FB, $FD, $FB, $FD, $FB, $FD, $FB
    db $FD, $FB, $FD, $03, $00, $00, $00, $00, $00, $18, $00, $24, $00, $24, $00, $18
    db $00, $00, $00, $00, $00, $FF, $FF, $FF, $00, $00, $00, $FF, $FF, $FF, $00, $00
    db $E7, $18, $00, $00, $E7, $18, $00, $00, $E7, $18, $00, $00, $E7, $18, $00, $00
    db $E7, $18, $00, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00
    db $80, $00, $80, $00, $00, $20, $00, $50, $00, $90, $00, $A0, $00, $90, $00, $90
    db $00, $4A, $00, $4D, $00, $55, $00, $49, $00, $29, $00, $2A, $00, $2A, $00, $14
    db $00, $14, $00, $0C, $00
    add e
    nop
    add $00
    ld l, l
    nop
    rst $38
    nop
    rst $38
    nop
    rst $38
    nop
    rst $38
    nop
    rst $38
    nop
    rst $30
    nop
    db $e3
    nop
    pop bc
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    rra
    rra
    ld a, a
    ld a, a
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    sbc c
    sbc c
    sbc c
    sbc c
    and $e6
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    sbc c
    sbc c
    sbc c
    sbc c
    ld h, [hl]
    ld h, [hl]
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld hl, sp-$08
    cp $fe
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    sbc c
    sbc c
    sbc c
    sbc c
    ld h, a
    ld h, a
    xor $ee
    xor $ee
    xor $ee
    xor $ee
    xor $ee
    xor $ee
    nop
    nop
    nop
    nop
    ld a, a
    ld a, a
    ret nz

    ret nz

    and b
    and b
    sbc a
    sbc a
    sbc b
    sbc b
    sub h
    sub h
    rst $38
    rst $38
    rst $38
    rst $38
    cp $fe
    inc bc

TileSheetData_4755:
    inc bc
    rlca
    rlca
    ei
    ei
    dec de
    dec de
    dec sp
    dec sp
    rst $38
    rst $38
    rst $38
    rst $38
    ld a, a
    ld a, a
    ret nz

    ret nz

    and b
    and b
    sbc a
    sbc a
    sbc b
    sbc b
    sub h
    sub h
    sub e
    sub e
    sub d
    sub d
    cp $fe
    inc bc
    inc bc
    rlca
    rlca
    ei
    ei
    dec de
    dec de
    dec sp
    dec sp
    db $db
    db $db
    db $db
    db $db
    sub e
    sub e
    sub e
    sub e
    sub h
    sub h
    sbc a
    sbc a
    sbc a
    sbc a
    and b
    and b
    rst $38
    rst $38
    ld a, a
    ld a, a
    db $db
    db $db
    db $db
    db $db
    dec sp
    dec sp
    ei
    ei
    ei
    ei
    rlca
    rlca
    rst $38
    rst $38
    cp $fe
    nop
    add e
    nop
    add $00
    ld l, l
    nop
    rst $38
    nop
    rst $38
    nop
    rst $38
    nop
    rst $38
    nop
    rst $38
    inc a
    inc a
    ld a, a
    ld h, a
    rst $38
    call z, $90ff
    rst $38
    sub b
    rst $38
    add h
    rst $38
    rst $38
    rst $38
    rst $38
    ld a, h
    ld a, h
    cp $9e
    rst $38
    inc sp
    rst $38
    daa
    rst $38
    inc bc
    rst $38
    sub a
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    ret


    rst $38
    sbc l
    rst $38
    rst $38
    rst $38
    rst $18
    rst $38
    inc e
    rst $38
    ld [hl], b
    rst $38
    rst $20
    rst $38
    rst $38
    ld a, [hl]
    ld a, [hl]
    rst $38
    add e
    rst $38
    ret


    rst $38
    add c
    rst $38
    and l
    rst $38
    add e
    rst $38
    rst $38
    rst $38
    rst $38
    rlca
    rlca
    inc bc
    inc bc
    inc bc
    nop
    rlca
    ld bc, $0003
    inc bc
    nop
    add hl, sp
    add hl, de
    ld a, a
    rra
    ret nz

    ret nz

    jr nc, DataZone_4836

    ldh a, [rSVBK]
    ldh a, [$ff30]
    ldh a, [rNR10]
    add sp, $08
    call nz, $e0e4
    ldh a, [rP1]
    nop
    inc bc
    inc bc
    ld bc, $0101
    nop
    inc bc
    nop
    ld bc, $0100
    nop
    nop
    nop
    nop
    nop
    ldh [hVramPtrLow], a
    sbc b
    sbc b
    ld hl, sp+$38
    ld sp, hl
    sbc c
    cp $0e
    ldh a, [rP1]
    ldh [hCurrentTile], a
    nop
    nop
    ccf
    ccf

DataZone_4836:
    ld b, b
    ld b, h
    or e
    rst $30
    rst $30
    or e
    rst $38
    add b
    rst $38
    add b
    rst $38
    rst $38
    nop
    nop
    add b
    add b
    ld b, b
    ld b, b
    jr nz, DataChainEntry_48aa

    jr nz, @+$62

    and b
    ld h, b
    and b
    ld h, b
    and b
    ld h, b
    ccf
    ccf
    ld a, a
    ld b, b
    rst $38
    cp e
    rst $38
    add b
    rst $38
    cp a
    rst $08
    rst $08
    rlca
    rlca
    rlca
    rlca
    add b
    add b
    ld b, b
    ret nz

    and b
    ldh [hTemp0], a
    ld h, b
    ldh [rNR41], a
    ldh [hTemp0], a
    ldh [hTemp0], a
    ldh [c], a
    and d
    nop
    nop
    inc bc
    inc bc
    inc bc
    inc bc
    rlca
    ld bc, $0003
    ld a, a
    rra
    ld b, e
    ld bc, $0f0f
    nop
    nop
    ldh [c], a
    ldh [c], a
    ld [hl-], a
    ld [hl-], a
    db $fc
    inc a
    ldh [rP1], a
    ldh a, [hCurrentTile]
    ld hl, sp-$08
    db $fc
    db $fc
    nop
    nop
    rlca
    rlca
    inc e
    rra
    scf
    jr c, DataSection_48c7

    jr nc, JumpStub_4915

    ld h, b
    ld e, b
    ld h, b

ConditionalVramLoop_48a0:
    ld e, c
    ld h, b
    nop
    nop
    ldh [hVramPtrLow], a
    jr c, ConditionalVramLoop_48a0

    sbc h
    ld a, h

DataChainEntry_48aa:
    call z, $ce3c
    ld a, $ce
    ld a, $ce
    ld a, $03
    inc bc
    inc c
    inc c
    db $10
    db $10
    inc h
    jr nz, DataChain_48e3

    jr nz, DataChain_48e5

    jr nz, DataChain_48e8

    ld hl, $2121
    db $fd
    db $fd
    rlca
    inc bc
    inc bc

DataSection_48c7:
    ld bc, $0001
    ld a, l
    ld a, h
    rst $38
    cp $3f
    ld a, [hl-]
    cp a
    or d
    ld a, l
    inc bc
    ei
    rlca
    rst $38
    add h
    db $fc
    or h
    call c, $dfcc
    call z, $cfdc
    rst $18
    rst $08
    nop

DataChain_48e3:
    nop
    ld h, b

DataChain_48e5:
    ld h, b
    ld hl, sp-$48

DataChain_48e8:
    cp h
    and h
    and h
    and h
    db $fc
    and h
    cp b
    ld hl, sp+$60
    ld h, b
    ld b, a
    rlca
    ld bc, $0100
    ld bc, $0101
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ldh [hCurrentTile], a
    ldh a, [hVramPtrLow]
    ld hl, sp-$48
    db $fc
    sbc h
    ldh [rP1], a
    ret nz

    ret nz

    ld h, b
    ld h, b
    ld b, b
    ld b, b
    rra
    rrca
    ccf

JumpStub_4915:
    rrca
    jr nz, DataPadding_4918

DataPadding_4918:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ldh a, [$fff8]
    ldh a, [$fff8]
    ld hl, sp+$70
    ld hl, sp-$28
    ld hl, sp-$28
    ld hl, sp-$68
    ld h, b
    ld h, b
    ldh [hVramPtrLow], a
    ld a, a
    ld b, b
    ccf
    ccf
    ld b, b
    ld b, c
    rst $38
    rst $38
    add c
    add e
    rst $38
    rst $38
    ld b, b
    ld b, b
    ccf
    ccf
    ld b, b
    ret nz

    ld b, c
    pop bc
    add e
    add e
    add l
    add a
    db $db
    db $dd
    ld h, [hl]
    ld a, [$0cfc]
    ld hl, sp-$08
    rst $08
    rst $08
    rst $38
    cp a
    ld a, a
    ld b, b
    ccf
    ccf
    db $10
    db $10
    rra
    rra
    ld [$0708], sp
    rlca
    db $e3
    inc hl
    jp $c743


    push bc
    ld l, e
    db $ed
    ld [hl], a
    ei
    adc $f2
    inc e
    inc l
    ldh a, [hCurrentTile]
    ccf
    ccf
    ld a, [hl]
    ld b, c
    ld a, a
    ld b, b
    rst $38
    sbc [hl]
    rst $38
    add b
    rst $38
    db $fc
    rst $38
    add b
    ld a, a
    ld a, a
    nop
    nop
    add c
    add c
    ld b, e
    jp DataLoopHelper2


    call $db7f
    ld c, l
    rst $28
    db $eb
    sbc [hl]
    sbc [hl]
    ld e, a
    ld h, b
    ld c, a
    ld [hl], b
    ld l, a
    ld [hl], b
    jr nz, PopHlStoreC_49d9

    jr nc, PopDualAndRst_49db

    rra
    rra
    rlca
    rlca
    nop
    nop
    adc $3e
    adc [hl]
    ld a, [hl]
    ld e, $fe
    inc e
    db $fc
    ld a, h
    db $fc
    ld hl, sp-$08
    ldh [hVramPtrLow], a
    nop
    nop
    inc hl
    inc hl
    ld de, $0f11
    rrca
    rst $20
    db $e4
    rst $30
    or h
    ei
    sbc e
    sbc [hl]
    sub h
    sub a
    sub a
    scf
    ld [hl-], a
    db $fd
    db $fd
    rst $38
    rst $38
    rrca
    nop
    ccf
    inc a
    rst $38
    rst $38
    add $45
    cp [hl]

DataLoopHelper1:
    adc l
    rst $38
    rst $38
    rst $08
    cp [hl]
    cp a
    ld [hl], c
    ld [hl], c

PopHlStoreC_49d9:
    pop hl
    ld [hl], c

PopDualAndRst_49db:
    pop hl
    pop hl
    rst $38
    ld sp, $6fff
    cp $e3
    db $e3
    rst $30
    dec d
    dec e
    dec e
    dec e
    dec d
    rst $38
    dec d
    rla
    db $fd
    dec e
    rst $38
    db $fd
    rra
    rlca
    rlca
    rrca
    ld a, [bc]
    rra
    ld de, $223f
    ccf
    inc h
    ccf
    jr z, DataLoadBranch_4a3e

    jr z, AdcDataPoint_4a40

    jr z, ConditionalDispatchPoint_4a03

ConditionalDispatchPoint_4a03:
    nop
    nop
    nop
    jr nc, DataLoadTable_4a38

    ld [hl], c
    ld d, c
    or $97
    ld hl, sp-$61
    ei
    adc a
    rst $38
    add h
    rrca
    rrca
    inc de
    inc de
    dec de
    dec de
    inc de
    inc de
    ccf
    ccf
    ld c, b
    ld c, b
    cp a
    adc b
    rst $38
    adc c
    jp $e5c3


    push hl
    db $eb
    jp hl


    rst $38
    pop af
    rst $38
    rst $38
    ld sp, $fd31
    dec e
    rst $38
    rst $38
    nop
    nop
    inc a
    inc a
    ld a, [hl]
    ld a, [hl]

DataLoadTable_4a38:
    ld c, [hl]
    ld c, [hl]
    ld l, [hl]
    ld l, [hl]
    ld c, a
    ld c, e

DataLoadBranch_4a3e:
    cp a
    or b

AdcDataPoint_4a40:
    adc a
    adc c
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ldh a, [hCurrentTile]
    sbc b
    ld hl, sp-$12

DataPadding_4a4f:
    ld e, $fe
    ld [de], a
    nop
    nop
    nop
    nop

UpdateLevelState_4a56:
    inc a
    inc a
    ld a, [hl]
    ld a, [hl]
    ld c, [hl]
    ld c, [hl]
    ld l, [hl]
    ld l, [hl]
    ld c, a
    ld c, e
    cp a
    or c
    nop
    nop
    ld [hl], b
    ld [hl], b
    ld e, b
    ld a, b
    add sp, -$28
    add sp, -$68
    add sp, -$68
    ret z

    jr c, DataPadding_4a4f

    ld a, $00
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    rra
    nop
    rst $08
    ccf
    ldh a, [hCurrentTile]
    nop
    nop
    ld a, [bc]
    ld b, $0a
    ld b, $12
    ld c, $74
    inc c
    call nz, DecAnimObjCount
    ld hl, sp-$10
    ldh a, [rP1]
    nop
    nop
    nop
    rlca
    rlca
    rra
    jr DataMarker_4ad1

    jr nz, DataZone_4acb

    jr nz, DataEntry_4afd

    ld b, b
    ld h, b
    ld b, b
    ld h, b
    ld b, b
    nop
    nop
    nop
    nop
    rlca
    rlca
    add hl, bc
    add hl, bc
    dec d
    inc de
    dec l
    inc hl
    ld e, l
    ld b, e
    cp l
    add e
    db $f4
    sub h
    rst $38
    sub h
    rst $30
    sbc a
    sub l
    db $fd
    sbc c
    ld sp, hl
    sub b
    ldh a, [hVramPtrLow]
    ldh [rP1], a
    nop
    ld a, [hl]
    ld c, l
    cp $79
    sbc h
    add e
    sbc e
    rlca
    or e

DataZone_4acb:
    ld c, $e7
    sbc a
    ld a, [hl]
    ld a, h
    rlca

DataMarker_4ad1:
    rlca
    db $db
    add a
    db $db
    add a
    db $db
    add a
    rst $38
    rst $38
    ld sp, $ff0f
    rst $38
    ld [hl], c
    ld c, $ff
    rst $38
    rst $20
    push hl
    jp wJumpTarget43


    ret nz

    add b
    add b
    add b
    add b
    ret nz

    ret nz

    ret nz

    ret nz

    ret nz

    ret nz

    rra
    jr @-$6f

    adc b
    rst $00
    rst $00
    db $fd
    db $fd
    ld a, c
    ld a, c
    inc bc

DataEntry_4afd:
    inc bc
    ld b, $06
    inc b
    inc b
    rst $38
    adc b
    ld a, a
    ld c, b
    ccf
    jr nc, PaddingZone_4b18

    rrca
    ld a, c
    ld a, c
    pop af
    pop af
    jp $9fc3


    sbc a
    sbc [hl]
    ld [$ff89], a
    ld c, b
    ld a, a

PaddingZone_4b18:
    ccf
    ccf
    rlca
    rlca
    add hl, bc
    add hl, bc
    rrca
    rrca
    rlca
    rlca
    rlca
    dec b
    jp nz, ErrorTrap_01

    db $fc
    ldh [hVramPtrLow], a
    ret nc

    ret nc

    ldh a, [hCurrentTile]
    ldh a, [hCurrentTile]
    ret nc

    ret nc

    cp a
    cp e
    ret


    rst $08
    ld a, h
    ld a, a
    rlca
    rlca
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld a, d
    ld c, $bc
    sbc h
    ldh a, [hCurrentTile]
    ldh [hVramPtrLow], a
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    adc a
    adc b
    cp a
    cp b
    ret


    adc $7c
    ld a, a
    rlca
    rlca
    nop
    nop
    nop
    nop
    nop
    nop
    sbc [hl]
    ld a, d
    or d
    ld a, [hl]
    db $ec
    inc e
    db $10
    ldh a, [hVramPtrLow]
    ldh [rP1], a
    nop
    nop
    nop
    nop
    nop
    sbc c
    sbc c
    ld a, [hl]
    ld h, [hl]
    ld h, [hl]
    ld b, d
    jp $c381


    add c
    ld h, [hl]
    ld b, d
    ld a, [hl]
    ld h, [hl]
    sbc c
    sbc c
    jr @+$1a

    inc a
    inc a
    ld a, [hl]
    ld a, [hl]
    rst $38
    rst $38
    rst $38
    rst $38
    ld a, [hl]
    ld a, [hl]
    inc a
    inc a
    jr DataPadding_4baa

    ld h, b
    ld b, b
    ld h, b
    ld b, b
    ld [hl], b
    ld b, b
    ld a, $20
    ld de, $0e1e
    rrca
    ld bc, $0001
    nop
    nop
    nop
    ld a, a
    ld a, a
    rst $38
    add b
    add b
    nop

DataPadding_4baa:
    dw $0000
    dw $4141
    dw $4141
    dw $0000
    dw $0000
    dw $0000
    dw $F0F0
    dw $08F8
    dw $041C
    dw $040C
    dw $060A
    dw $060A

; ROM_WORLD3_PALETTE - Données palette monde 3 ($4BC2-$4E83)
; ==============================================================================
; Description: Palette graphique complète pour le monde 3
;              Contient les couleurs et données graphiques pour l'affichage
; Référencé par: GraphicsTableB ($0DEA) pointe vers $4BC2
; Destination: Copié vers VRAM $9310 par CopyColorPaletteDataLoop
; Taille: $2C2 octets (706 bytes)
; Format: Données palette 16-bit little-endian
; ==============================================================================

; Données de la palette à $4BC2 (adresse ROM_WORLD3_PALETTE)
World3PaletteData:
    dw $0000, $FF00, $8100, $BD00, $A500, $B500, $8500, $FD00
    dw $0000, $7E00, $4200, $5A00, $4A00, $7A00, $0200, $FE00
    dw $8100, $8100, $8100, $8100, $8100, $8100, $8100, $5E00
    dw $0000, $0200, $4600, $2600, $1400, $0800, $0800, $0800
    dw $0400, $0200, $6200, $1D00, $0100, $0000, $0000, $0000
    dw $0000, $0000, $0000, $1000, $1800, $1800, $0900, $0900
    dw $0600, $0800, $1000, $2C00, $4700, $C000, $8000, $8000
    dw $0000, $0000, $0000, $0000, $0000, $0000, $0800, $1400
    dw $1400, $2A00, $2600, $5500, $4900, $5100, $6300, $5500
    dw $0100, $0300, $0500, $0900, $1100, $2100, $4100, $5E00
    dw $FFFF, $FFFF, $FF00, $FFFF, $FFFF, $FF00, $FFFF, $FFFF
    dw $FF00, $FF00, $FF00, $FF00, $FF00, $FF00, $FF00, $FF00
    dw $0000, $1E00, $2100, $4000, $4000, $A000, $A800, $8000
    dw $0000, $0000, $0000, $8000, $8000, $4000, $2000, $2000
    dw $0100, $0200, $0200, $0400, $0400, $0400, $0800, $0800
    dw $1000, $1000, $1000, $1100, $1100, $0A00, $0A00, $0C00
    dw $0000, $0000, $E000, $1000, $0800, $0400, $0400, $0400
    dw $0800, $0800, $1000, $1400, $2500, $2400, $4000, $8000
    dw $0800, $0400, $1400, $5400, $0400, $0200, $0000, $0000
    dw $8400, $8200, $2200, $0200, $0100, $0100, $0800, $0000
    dw $1000, $1000, $1000, $1000, $1000, $0800, $0800, $0800
    dw $1600, $2900, $4000, $8004, $805D, $413E, $320C, $0C00
    dw $6800, $9600, $0100, $0084, $00D5, $00FF, $CB34, $3400
    dw $0000, $C000, $2000, $1080, $6080, $8000, $0000, $0000
    dw $0000, $FF00, $FF00, $00FF, $0000, $00FF, $0000, $00FF
    dw $0100, $0100, $0200, $0200, $0200, $0400, $0400, $0800
    dw $0700, $0800, $1000, $1000, $2000, $4000, $4000, $4000
    dw $8000, $4000, $2000, $1000, $1000, $0800, $0800, $0800
    dw $0000, $0000, $0000, $0000, $0100, $0100, $0200, $0200
    dw $4000, $4000, $9000, $9400, $0000, $0000, $0000, $0000
    dw $0400, $1200, $1200, $0100, $0100, $0100, $0000, $0000
    dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
    dw $FBFD, $FBFD, $FBFD, $FBFD, $FBFD, $FBFD, $FBFD, $03FD
    dw $0000, $1F00, $2000, $4000, $8000, $8040, $8040, $4020
    dw $0000, $0700, $E800, $1000, $0800, $0800, $0000, $0000
    dw $0000, $8F00, $5000, $2000, $2000, $0000, $0000, $0000
    dw $0000, $8000, $5800, $2400, $2200, $0100, $0100, $0102
    dw $4020, $4030, $2010, $201C, $1807, $0700, $0000, $0000
    dw $0000, $0008, $0408, $0876, $14E3, $E300, $0000, $0000
    dw $0000, $0010, $0030, $1069, $20DF, $DF00, $0000, $0000
    dw $0102, $0186, $42AC, $4CB0, $B000, $0000, $0000, $0000
    dw $0000, $0010, $0010, $00FE, $007C, $0038, $007C, $00C6
    dw $FFFF, $FF00, $00FF, $0000, $00FF, $0000, $00FF, $0000
    dw $0000, $00FF, $0000, $00FF, $0000, $00FF, $FF00, $FFFF
    dw $0000

; Données après palette monde 3 ($4E84-$4F5D)
DataPadding_4e84:
    dw $3C00, $6600, $DB00, $FF00, $FC00, $7B00, $FF00, $0206
    dw $0808, $2236, $CADE, $2A3E, $0A0E, $0206, $0000, $0000
    dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $C7C7
    dw $68EF, $33FF, $87FC, $FFF8, $FF00, $FF00, $7C83, $F3F3
    dw $3CFF, $89FF, $E3FE, $FF3C, $FF00, $FD02, $708F, $7E7E
    dw $83FF, $BBFF, $A3FF, $A3FF, $87FF, $FFFF, $7E7E, $E0E0
    dw $3CFC, $8AFE, $E77F, $FF1D, $FF01, $FD03, $718F, $01FF
    dw $02FE, $06FE, $04FC, $04FC, $06FE, $03FF, $01FF, $0F0F
    dw $303F, $477F, $CFF9, $FFF0, $FF80, $FF80, $B8C7, $80FF
    dw $C0FF, $407F, $407F, $607F, $203F, $203F, $607F, $7E7E
    dw $89BB, $89BB, $FFFF, $91B7, $91B7, $91B7, $FFFF, $7E7E
    dw $818F, $81BF, $83BF, $FFFF, $7E7E, $0000, $0000, $7F7F
    dw $C0C0, $BFBF, $BFBF, $BFBF, $BFBF, $FF80, $FFFF, $FEFE
    dw $0303, $FFFD, $FFFD, $FFFD, $FFFD

DataPadding_4f5e:
    inc bc
    rst $38
    rst $38
    rst $38
    ld a, a
    ld b, b
    ld a, a
    ld b, b
    rst $38
    rst $38
    rst $38
    add b
    rst $38
    add b
    rst $38
    add b
    rst $38
    add b
    rst $38
    rst $38
    and $1e
    and $1e

PaddingZone_4f76:
    rst $38
    rst $38
    rst $00
    ccf
    rst $00
    ccf
    rst $00
    ccf
    rst $00
    ccf
    rst $38
    rst $38
    ld a, a
    ld b, b
    ld a, a
    ld b, b

PaddingZone_4f86:
    ld a, a
    ld b, b
    ccf
    ccf
    ld a, a
    ld b, b
    ld a, a
    ld b, b
    ld a, a
    ld b, b
    ld a, a
    ld b, b
    and $1e
    and $1e
    and $1e
    db $fc
    db $fc
    and $1e
    and $1e
    and $1e

CheckScrollingConditionAndReset:
    and $1e
    rst $38
    rst $38
    rst $38
    add c
    rst $00
    add l
    rst $18
    sbc l
    rst $18
    sbc l
    rst $38
    cp l
    rst $38
    add c
    rst $38
    rst $38
    ldh a, [$ffac]
    and $01
    ret nz

    ld a, [wCollisionFlag]
    cp COLLISION_THRESHOLD
    jr c, UpdateScrollXAndDecreaseCollisionCounter

    ldh a, [hShadowSCX]
    and $0c
    jr nz, UpdateScrollXAndDecreaseCollisionCounter

    ldh a, [hShadowSCX]
    and SCROLL_ALIGN_MASK        ; Aligner scroll sur 4 pixels
    ldh [hShadowSCX], a
    ret


UpdateScrollXAndDecreaseCollisionCounter:
    ldh a, [hShadowSCX]
    inc a
    ldh [hShadowSCX], a
    ld b, $01
    call OffsetSpritesY
    call OffsetSpritesX
    ld hl, wPlayerState
    dec [hl]
    ld a, [hl]
    and a
    jr nz, PerformCollisionCheckAndIncrementCounter

    ld [hl], $f0

PerformCollisionCheckAndIncrementCounter:
    ld c, $08
    call CheckSpriteCollisionWithOffset
    ld hl, wPlayerState
    inc [hl]
    ret

; ===========================================================================
; UpdateObjectsAndInput
; ---------------------
; Description: Point d'entrée pour la mise à jour des objets du jeu.
;              Vérifie d'abord si les boutons A ou B sont pressés pour
;              des actions spéciales, sinon traite les mouvements directionnels.
; In:  hJoypadState = État actuel du joypad
; Out: Aucun retour spécifique
; Modifie: a, bc, de, hl (via appels)
; ===========================================================================
UpdateObjectsAndInput:
    ldh a, [hJoypadState]
    bit 6, a                         ; Test bit 6 (bouton B)
    jr nz, HandleJoypadButtonB_CheckCollision

    bit 7, a                         ; Test bit 7 (bouton A)
    jr nz, CheckSpriteCollisionSimple
    ; Fall through vers HandleJoypadAndCollision

; HandleJoypadAndCollision
; ------------------------
; Description: Gère le D-Pad (gauche/droite) et applique collisions directionnelles.
;              Gauche (bit 5): offset -6, décrément wPlayerState si >= $10 et pas de collision.
;              Droite (bit 4): offset +8, incrément wPlayerState si < $A0.
; In:  hJoypadState = État boutons (bit 4=droite, bit 5=gauche)
;      wPlayerState = Position état joueur actuelle
;      wCollisionFlag = Flag collision pour tests supplémentaires
; Out: wPlayerState modifié selon direction et collision
; Modifie: a, bc, hl (via appels)
HandleJoypadAndCollision:
    ldh a, [hJoypadState]
    bit 4, a                         ; Test PADF_RIGHT (bit 4)
    jr nz, CheckCollisionWithPositiveOffset

    bit 5, a                         ; Test PADF_LEFT (bit 5)
    ret z

    ld c, COLLISION_SIDE_X_NEG       ; Offset -6 pour collision gauche
    call CheckSpriteCollisionWithOffset
    ld hl, wPlayerState
    ld a, [hl]
    cp PLAYER_STATE_MIN              ; Si état < 16, bloqué
    ret c

    dec [hl]                         ; Décrément état joueur
    ld a, [wCollisionFlag]
    cp COLLISION_THRESHOLD           ; Collision forte ?
    ret nc

    dec [hl]                         ; Double décrément si collision faible
    ret


; CheckCollisionWithPositiveOffset
; --------------------------------
; Description: Gère le mouvement vers la droite avec vérification de collision.
;              Incrémente wPlayerState si pas de blocage (< PLAYER_STATE_MAX).
; In:  wPlayerState = Position état joueur actuelle
; Out: wPlayerState modifié (+1 si mouvement autorisé)
; Modifie: a, bc, hl (via appels)
CheckCollisionWithPositiveOffset:
    ld c, COLLISION_OFFSET_8         ; Offset +8 pour collision droite
    call CheckSpriteCollisionWithOffset
    ld hl, wPlayerState
    ld a, [hl]
    cp PLAYER_STATE_MAX              ; Si état >= 160, bloqué
    ret nc

    inc [hl]                         ; Incrément état joueur
    ret


; CheckSpriteCollisionSimple
; --------------------------
; Description: Vérifie collision sprite lorsque bouton A est pressé.
;              Si aucune collision détectée et position X valide, déplace joueur vers la droite.
; In:  wPlayerX = Position X actuelle du joueur
; Out: Aucun (retourne via HandleJoypadAndCollision)
; Modifie: a, hl (via appels)
CheckSpriteCollisionSimple:
    call CheckSpriteCollision
    cp RETURN_COLLISION_FOUND
    jr z, HandleJoypadAndCollision

    ld hl, wPlayerX
    ld a, [hl]
    cp PLAYER_X_MAX_LIMIT
    jr nc, HandleJoypadAndCollision

    inc [hl]
    jr HandleJoypadAndCollision

; HandleJoypadButtonB_CheckCollision
; ----------------------------------
; Description: Gère collision lors appui bouton B (mouvement gauche)
; In:  -
; Out: a = $FF si collision solide, autre valeur si OK ou pipe
; Modifie: a, hl, bc, de
HandleJoypadButtonB_CheckCollision:
    call CheckPlayerCollisionWithTile
    cp RETURN_COLLISION_FOUND
    jr z, HandleJoypadAndCollision

    ld hl, wPlayerX
    ld a, [hl]
    cp GAME_STATE_WALK_LEFT        ; Limite gauche $30
    jr c, HandleJoypadAndCollision

    dec [hl]
    jr HandleJoypadAndCollision

; CheckPlayerCollisionWithTile
; ----------------------------
; Description: Vérifie collision joueur avec tiles devant lui (2 points test)
; In:  -
; Out: a = $FF si collision solide, 0 si libre, code spécial si pipe
; Modifie: a, b, hl, hSpriteX, hSpriteY
CheckPlayerCollisionWithTile:
    ld hl, wPlayerX
    ldh a, [hTimerAux]
    ld b, FEET_COLLISION_OFFSET_Y  ; $FD = -3
    and a
    jr z, .checkFirstTile

    ld b, COLLISION_ADJUST_X_NEG4  ; $FC = -4

.checkFirstTile:
    ld a, [hl+]
    add b
    ldh [hSpriteY], a
    ldh a, [hShadowSCX]
    ld b, [hl]
    add b
    add FEET_COLLISION_ADJUST_X    ; +2
    ldh [hSpriteX], a
    call ReadTileUnderSprite
    cp TILEMAP_CMD_THRESHOLD       ; Tiles < $60 = non-solides
    jr nc, .tileIsSolid

    ldh a, [hSpriteX]
    add COLLISION_SIDE_X_NEG       ; -6 pixels
    ldh [hSpriteX], a
    call ReadTileUnderSprite
    cp TILEMAP_CMD_THRESHOLD
    ret c

.tileIsSolid:
    cp TILEMAP_CMD_PIPE         ; Tile tuyau $F4 ?
    jr z, .activateCollision

    ld a, RETURN_COLLISION_FOUND
    ret


.activateCollision:
    push hl
    pop de
    ld hl, hBlockHitType
    ld [hl], BLOCK_HIT_TYPE_SPECIAL
    inc l
    ld [hl], d
    inc l
    ld [hl], e
    ld a, STATE_BUFFER_COIN
    ld [wStateBuffer], a
    ret


; CheckSpriteCollision
; --------------------
; Description: Détecte les collisions du sprite joueur avec les tiles de la tilemap
;              Vérifie 2 points de collision (gauche et droite de la hitbox)
; In:  c = offset X relatif
; Out: a = résultat collision ($FF si aucune, valeur tile si collision)
;      zero flag set si collision spéciale détectée
; Modifie: a, bc, de, hl, hSpriteX, hSpriteY
CheckSpriteCollision:
    ld hl, wPlayerX
    ld a, [hl+]
    add SPRITE_COLLISION_OFFSET_Y
    ldh [hSpriteY], a
    ldh a, [hShadowSCX]
    ld b, a
    ld a, [hl]
    add b
    add HEAD_COLLISION_ADJUST_X  ; Ajustement hitbox X (-2)
    ldh [hSpriteX], a
    call ReadTileUnderSprite
    cp TILEMAP_CMD_THRESHOLD
    jr nc, CheckForSpecialCollisionTile

    ldh a, [hSpriteX]
    add SPRITE_COLLISION_WIDTH
    ldh [hSpriteX], a
    call ReadTileUnderSprite
    cp TILEMAP_CMD_E1            ; Tile collision spéciale E1 ?
    jp z, TriggerBlockCollisionSound_TimerDispatch

    cp TILEMAP_CMD_THRESHOLD
    jr nc, CheckForSpecialCollisionTile

    ret


CheckForSpecialCollisionTile:
    cp TILEMAP_CMD_PIPE         ; Tile tuyau $F4 ?
    jr nz, ReturnNoCollisionDetected

    push hl
    pop de
    ld hl, $ffee
    ld [hl], $c0
    inc l
    ld [hl], d
    inc l
    ld [hl], e
    ld a, $05
    ld [wStateBuffer], a
    ret


ReturnNoCollisionDetected:
    ld a, $ff
    ret


; CheckSpriteCollisionWithOffset
; --------------------------------
; Description: Vérifie collision sprite avec tile en testant plusieurs points d'offset.
;              Teste 5 ou 1 point(s) selon timer, détecte tiles spéciaux (pipe, blocs).
; In:  c = offset horizontal additionnel pour le test
; Out: a = tile ID si collision spéciale, sinon indéfini
;      carry/zero selon résultat de collision
; Modifie: a, bc, de, hl
; Calls: ReadTileUnderSprite, TriggerBlockCollisionSound_TimerDispatch
CheckSpriteCollisionWithOffset:
    ld de, $0502                ; d=offset Y (+5), e=compteur (2 tests)
    ldh a, [hTimerAux]
    cp $02
    jr z, CollisionCheckOffsetLoop

    ld de, $0501                ; Si timer != 2: d=offset Y (+5), e=1 test

CollisionCheckOffsetLoop:
    ld hl, wPlayerX
    ld a, [hl+]                 ; a = wPlayerX (en fait Y sur GB)
    add d                       ; Ajoute offset Y
    ldh [hSpriteY], a
    ld b, [hl]                  ; b = wPlayerX+1 (position X)
    ld a, c                     ; Ajoute offset X passé en paramètre
    add b
    ld b, a
    ldh a, [hShadowSCX]         ; Ajoute scroll X
    add b
    ldh [hSpriteX], a
    push de
    call ReadTileUnderSprite    ; Lit tile aux coordonnées (hSpriteY, hSpriteX)
    pop de
    cp TILEMAP_CMD_THRESHOLD    ; Tile >= $60 ?
    jr c, DecrementOffsetAndRetryCollision

    cp TILEMAP_CMD_PIPE         ; Tile tuyau $F4 ?
    jr z, TriggerSpecialCollisionEvent

    cp TILEMAP_CMD_E1            ; Tile collision spéciale E1 ?
    jp z, TriggerBlockCollisionSound_TimerDispatch

    cp TILEMAP_CMD_BLOCK         ; Tile bloc collision ?
    jp z, TriggerBlockCollisionSound_TimerDispatch

    pop hl
    ret


; DecrementOffsetAndRetryCollision
; ---------------------------------
; Description: Ajuste l'offset Y de collision vers le bas et retente si nécessaire.
;              Change l'offset de +5 à -3 pour tester les pieds du sprite.
; In:  e = compteur de tests restants, d = offset Y précédent
; Out: (retourne ou reboucle selon compteur)
; Modifie: d
DecrementOffsetAndRetryCollision:
    ld d, FEET_COLLISION_OFFSET_Y  ; Offset Y devient -3 (pieds)
    dec e                       ; Décrémente compteur de tests
    jr nz, CollisionCheckOffsetLoop

    ret


; TriggerSpecialCollisionEvent
; ----------------------------
; Description: Déclenche un événement collision spéciale (tuyau/pipe $F4).
;              Configure le type de collision à $C0 et mémorise les coordonnées du sprite.
;              Passe l'état buffer à 5 pour traiter l'événement spécial.
; In:  hl = coordonnées du sprite (h=Y, l=X)
; Out: -
; Modifie: a, de, hl
TriggerSpecialCollisionEvent:
    push hl                     ; Copie hl -> de
    pop de
    ld hl, hBlockHitType        ; $FFEE
    ld [hl], BLOCK_HIT_TYPE_SPECIAL ; Type collision = $C0 (spécial)
    inc l                       ; $FFEF (stocke coordonnée Y du sprite)
    ld [hl], d
    inc l                       ; hCurrentTile ($FFF0)
    ld [hl], e
    ld a, $05
    ld [wStateBuffer], a        ; Change état buffer à 5 (événement spécial)
    ret


; UpdateActiveSpriteAnimations
; ----------------------------
; Description: Met à jour les animations des 3 sprites actifs (slots $FFA9-$FFAB).
;              Pour chaque sprite actif, incrémente sa position Y OAM de +2 pixels/frame.
;              Nettoie les sprites qui atteignent Y >= $A9 (hors écran).
;              Vérifie les collisions pièces et appelle ProcessObjectCollisions.
; In:  hObjParamBuf1 = flags activité sprites (0=inactif, !=0=actif)
;      wOamAttrY = buffer OAM (position Y sprites)
; Out: Sprites mis à jour dans OAM, flags nettoyés si hors écran
; Modifie: a, bc, de, hl
; Calls: CheckTileForCoin, ProcessObjectCollisions
UpdateActiveSpriteAnimations:
    ld b, OAM_SPRITE_LOOP_3
    ld hl, hObjParamBuf1
    ld de, wOamAttrY

OamSpriteActivityCheckLoop:
    ld a, [hl+]
    and a
    jr nz, ProcessActiveSpriteOffset

IncrementOamPointerAndLoop:
    inc e
    inc e
    inc e
    inc e
    dec b
    jr nz, OamSpriteActivityCheckLoop

    ret


ProcessActiveSpriteOffset:
    push hl
    push de
    push bc
    dec l
    ld a, [de]
    inc a
    inc a
    ld [de], a
    ldh [hTemp1], a
    ldh [hSoundParam2], a
    cp OAM_Y_OFFSCREEN_LIMIT
    jr c, CheckCoinCollisionLogic

ClearOamAndMemory:
    xor a
    res 0, e
    ld [de], a
    ld [hl], a
    jr ProcessCollisionAndLoopContinue

CheckCoinCollisionLogic:
    add $02
    push af
    dec e
    ld a, [de]
    ldh [hSoundParam1], a
    add $06
    ldh [hSpriteY], a
    pop af
    call CheckTileForCoin
    jr c, ProcessCollisionAndLoopContinue

    jr ClearOamAndMemory

ProcessCollisionAndLoopContinue:
    pop bc
    pop de
    pop hl
    call ProcessObjectCollisions
    jr IncrementOamPointerAndLoop

; CheckPlayerStateAndReset
; -------------------------
; Description: Vérifie l'état du joueur et réinitialise le jeu si nécessaire.
;              Appelé en fin de boucle principale (State0D) pour détecter
;              la mort du joueur (< $01) ou un état critique (>= $F0).
; In:  [wPlayerState] = état actuel du joueur (0-255)
; Out: Aucun (ou reset du jeu via ResetGameStateInit)
; Modifie: a
CheckPlayerStateAndReset:
    ld a, [wPlayerState]
    cp PLAYER_STATE_ALIVE_MIN
    jr c, ResetGameStateInit     ; Si < $01 (mort), réinitialiser

    cp PLAYER_STATE_CRITICAL
    ret c                        ; Si < $F0, état normal, continuer

    ; Si >= $F0 (état critique), tomber dans ResetGameStateInit

; ResetGameStateInit
; -------------------
; Description: Réinitialise le jeu à l'état initial (game state = $01).
;              Appelé quand le joueur meurt ou atteint un état critique.
; In:  Aucun
; Out: Aucun
; Modifie: a
;          [hTimerAux] = $00, [hSubState] = $00
;          [hGameState] = $01, [wStateRender] = $02
;          [hTimer1] = TIMER_CHECKPOINT_LONG
ResetGameStateInit:
    xor a                        ; a = $00
    ldh [hTimerAux], a           ; Reset timer auxiliaire
    ldh [hSubState], a           ; Reset sous-état
    inc a                        ; a = $01
    ldh [hGameState], a          ; Game state = $01 (init)
    inc a                        ; a = $02
    ld [wStateRender], a         ; State render = $02
    ld a, TIMER_CHECKPOINT_LONG  ; Timer checkpoint (144 frames)
    ldh [hTimer1], a             ; Timer1 = TIMER_CHECKPOINT_LONG
    ret

; ==============================================================================
; Level5MapData - Map data for level 5 ($5179-$5221)
; ==============================================================================
; Description: Compressed map data (RLE format) for level 5
; Format:
;   - Standard bytes: high nibble = tile count-1, low nibble = tile base
;   - Command $84: Special tile marker
;   - Command $93: Repeat/pattern marker
;   - Command $00: Separator/special marker
;   - End marker: $FF
; Referenced by: LevelJumpTable entry for level 5 (line 22)
; Size: 169 bytes (0xA9)
; ==============================================================================
Level5MapData:
    db $0E, $13, $10, $10, $13, $10, $11, $0D, $84, $12, $04, $84, $17, $0B, $84, $1A
    db $93, $10, $1B, $05, $84, $1C, $93, $10, $21, $09, $0B, $25, $06, $0B, $2A, $0F
    db $84, $2D, $0C, $84, $2E, $13, $00, $2F, $05, $84, $34, $13, $10, $37, $13, $10
    db $3A, $13, $10, $3D, $13, $10, $40, $13, $10, $41, $08, $04, $43, $13, $10, $47
    db $93, $10, $49, $93, $10, $4C, $13, $A4, $4E, $13, $10, $51, $07, $00, $52, $07
    db $00, $57, $04, $00, $58, $04, $00, $59, $04, $00, $5C, $93, $10, $5E, $93, $10
    db $60, $93, $10, $62, $93, $10, $66, $93, $10, $68, $93, $10, $6A, $93, $24, $6C
    db $93, $90, $6F, $4E, $02, $71, $0F, $84, $78, $07, $00, $79, $07, $00, $7D, $0B
    db $84, $7D, $87, $84, $7F, $04, $00, $80, $04, $80, $84, $13, $90, $87, $13, $24
    db $88, $08, $84, $8B, $93, $24, $8E, $0F, $84, $90, $08, $0A, $98, $08, $0A, $99
    db $10, $84, $9C, $05, $36, $9C, $85, $36, $FF

; ==============================================================================
; Level5EntitiesData - Entities/objects data for level 5 ($5222-$5277)
; ==============================================================================
; Description: Entity placement data for level 5 (enemies, coins, blocks, etc.)
; Format: Variable-length entries, each entity contains:
;   - Position data (X, Y coordinates)
;   - Entity type ID
;   - Properties/flags
; Size: 86 bytes ($56)
; Referenced by: LevelJumpTable entry for level 5 (line 22)
; Note: Format appears specific to level 5 layout
; ==============================================================================
Level5EntitiesData:
    db $0C, $0C, $16, $12, $0C, $84, $16, $0B, $00, $17, $07, $04, $1D, $0B, $04, $22
    db $07, $0B, $23, $13, $A4, $27, $07, $0B, $2A, $0D, $04, $31, $09, $16, $36, $09
    db $04, $37, $0E, $00, $3A, $09, $80, $3E, $09, $16, $41, $0E, $00, $44, $09, $80
    db $46, $09, $04, $48, $09, $16, $4B, $0E, $00, $57, $8F, $04, $58, $0E, $84, $59
    db $0C, $00, $5B, $13, $24, $60, $8F, $16, $65, $85, $0A, $6B, $0A, $0B, $70, $0D
    db $04, $71, $13, $A4, $73, $13

DataZone_5278:
    inc h
    ld [hl], a
    ld c, e
    ld [bc], a
    ld a, b
    add hl, bc
    add h
    ld a, c
    adc e
    nop
    ld a, d
    ret


    ld [bc], a
    ld a, l
    dec b
    inc b
    ld a, a
    dec b
    add h
    add e
    inc de
    and h
    add a
    add l
    ld [hl], $88
    inc bc
    dec bc
    adc b
    adc c
    ld [hl], $89
    adc l
    ld [hl], $ff

; Level6TilesetData
; ----------------
; Description: Tileset pour le niveau 6 (format RLE compressé)
; Format: Paires d'octets (count, tile_id), terminé par $1A $FF
; Taille: 118 octets ($76)
; Référencé par: LevelJumpTable niveau 6
Level6TilesetData:
    db $0F, $05, $AF, $19, $0E, $2F, $1B, $53
    db $10, $23, $0E, $9D, $25, $0B, $1D, $27
    db $08, $9D, $29, $05, $1D, $2D, $08, $2F
    db $2F, $53, $10, $39, $53, $10, $3B, $05
    db $1D, $3E, $05, $9D, $40, $0D, $1D, $43
    db $0D, $9D, $43, $13, $10, $49, $07, $1D
    db $4D, $13, $10, $4E, $07, $2F, $54, $08
    db $20, $57, $08, $1D, $5F, $09, $20, $69
    db $07, $20, $69, $0D, $20, $73, $07, $2F
    db $75, $13, $24, $78, $0C, $1D, $7F, $13
    db $24, $85, $0A, $20, $88, $0C, $2F, $89
    db $13, $A4, $8E, $0F, $1D, $92, $0F, $9D
    db $9B, $0D, $20, $9C, $0F, $9D, $A5, $07
    db $A0, $A8, $0F, $1D, $AE, $0B, $48, $AF
    db $0A, $C8, $B0, $0C, $1A, $FF

; ==============================================================================
; SharedMapData_467 - Map data partagée niveaux 4, 6, 7 ($5311-$5404)
; ==============================================================================
; Description: Données de carte partagées entre les niveaux 4, 6 et 7
;              Zone mal désassemblée comme du code (rrca, call z, etc.)
;              Réellement: données de map au format similaire à Level5MapData
; Format: Variable-length entries describing tile placement, terminated by $FF
; Referenced by: LevelJumpTable entries for levels 4, 6, and 7
; Size: 244 bytes ($F4)
; Note: Reconstruire avec des 'db' statements pour une meilleure lisibilité
; ==============================================================================
SharedMapData_467:  ; $5311
    rrca
    call z, $1155
    pop de
    ld [bc], a
    add hl, de
    ld d, c
    ld [bc], a
    ld a, [de]
    dec bc
    sub $1b
    rrca
    add h
    inc e
    rrca
    ld d, [hl]
    rra
    adc c
    ld a, [bc]
    inc h
    add a
    dec bc
    inc l
    rrca
    add h
    dec l
    ld d, c
    ld c, c
    cpl
    rrca
    ld d, [hl]
    scf
    ld c, $84
    add hl, sp
    adc [hl]
    inc b
    ld a, [hl-]
    ld c, $56
    ld b, b
    ld c, $56
    ld b, c
    ld c, $04
    ld b, e
    adc [hl]
    inc b

PaddingZone_5344:
    ld c, d
    rrca
    ld d, [hl]

PaddingZone_5347:
    ld c, e
    ld d, c
    ld [bc], a
    ld c, l
    dec bc
    ld d, [hl]
    ld c, l
    rrca

ValidateCondition_534f:
    add h
    ld d, c
    ld d, c
    add d
    ld d, e

PaddingZone_5354:
    ld d, c
    ld [bc], a
    ld d, h
    ld c, a
    ld [bc], a
    ld d, l
    call ProcessLevelData_5b49
    ld c, [hl]
    ld [bc], a
    ld e, [hl]
    ld a, [bc]
    ld d, [hl]
    ld e, [hl]
    adc d
    inc b
    ld h, d
    ld c, l
    ld [bc], a
    ld h, e
    ld c, [hl]
    ret


    ld h, a
    ld c, $39
    ld l, e
    ld a, [bc]
    jr c, @+$71

    rst $08
    ld [bc], a
    ld [hl], c
    call z, ValidationData_7355
    call z, ConfigData_7555
    pop de
    ld [bc], a
    ld a, c
    rst $08
    ld c, c
    ld a, e
    call z, LevelData_7c55
    rrca
    add b
    ld a, l
    call z, DataPadding_7e55
    rrca
    nop
    ld a, a
    pop de
    ld [bc], a
    add e
    rst $08
    ld c, c
    add l
    call z, $8755
    call z, $8855
    rrca
    add h
    adc c
    pop de
    ld [bc], a
    adc d
    add [hl]
    inc c
    adc [hl]
    adc l
    dec bc
    sub d
    ld b, $38
    sub l
    add l
    ld [hl], $96
    dec b
    ld [hl], $98
    dec b
    ld [hl], $98
    add l
    ld [hl], $9a
    ld b, $36
    sbc d
    add [hl]
    ld [hl], $9d
    ld b, $0a
    and c
    ld d, c
    add d
    and d
    ld d, c
    ld c, c
    and e
    ld d, c
    add d
    and h
    ld c, a
    add d
    and l
    call $a7c9
    adc c
    ld d, [hl]
    xor [hl]
    ld c, $56
    xor a
    ld c, $04
    or c
    adc [hl]
    inc b
    or d
    ld c, $56
    or h
    add hl, bc
    ld a, [bc]
    jp nz, DataLoopHelper1

    call nz, $49cf
    push bc
    adc d
    inc b
    add $c9
    ld c, c
    rst $08
    dec b
    ld d, [hl]
    rst $08
    ld [$cf56], sp
    ld c, $56
    call nc, AudioInitData_StackVariantA
    push de
    db $10
    ld [hl], $d7
    pop de
    ld c, c
    ret c

    rst $08
    ld c, c
    reti


    call z, $de49
    adc b
    add hl, sp
    rst $38
    rrca
    dec bc
    inc b
    ld de, $8909
    dec d
    rrca
    inc b
    add hl, de
    dec bc
    inc b
    dec de
    rrca
    add hl, bc
    rra
    ld d, b
    ld c, c
    jr nz, JumpStub_5428

    add h
    inc hl
    dec c
    inc b
    daa
    dec bc
    add hl, bc
    add hl, hl
    ld d, b
    ld c, c
    ld a, [hl+]
    rrca
    add h
    dec l
    adc l

JumpStub_5428:
    cp a
    jr nc, ConditionalProcessingRoutine_5436

    ccf
    inc [hl]
    call AudioInitData_StackVariantB
    add hl, bc
    inc b
    scf
    call $3a55

ConditionalProcessingRoutine_5436:
    call z, $3e55
    call ProcessDataValue_4055
    ld d, b
    ret


    ld b, c
    call InitializeLevel_4355
    ld d, b
    ld c, c
    ld b, h
    call z, TileSheetData_4755
    add hl, bc
    inc b
    ld c, b

; SharedEntitiesData_467 - Entities data partagée niveaux 4, 6, 7 ($5405-$5509)
SharedEntitiesData_467:  ; $5405
    rrca
    nop
    ld c, e
    inc c
    cp a
    ld c, l
    ld c, $09
    ld d, e
    rrca
    ld d, h
    ld d, h
    ld c, h
    ld [bc], a
    ld d, [hl]
    rlca
    ld d, h
    ld e, c
    rrca
    ld d, h
    ld e, d
    rrca
    nop
    ld e, l
    rrca
    ld d, h
    ld h, b
    rlca
    ld d, h
    ld h, e
    rrca
    ld d, h
    ld l, b
    inc c
    ld d, h
    ld l, d
    rrca
    inc b
    ld l, h
    dec c
    ld d, h
    ld [hl], b
    adc a
    call nc, $8e72
    dec bc
    halt
    adc h
    dec bc
    ld a, d
    rrca
    inc b
    ld a, h
    inc c
    ld d, h
    ld a, [hl]
    rrca
    inc b
    add b
    dec c
    ld d, h
    add h
    adc a
    call nc, $8e86
    dec bc
    adc d
    adc h
    dec bc
    adc e
    add a
    call nc, ValidateAndWriteTextCharToVram
    inc b
    sub c
    inc c
    ccf
    sub h
    adc d
    inc b
    sub l
    add a
    ld d, h
    sbc c
    rrca
    ld d, h
    sbc h
    rlca
    ld d, h
    sbc l
    adc l
    inc b
    sbc a
    rrca
    ld d, h
    and e
    rrca
    ccf
    and l
    inc c
    inc b
    and a
    adc l
    cp a
    xor b
    adc d
    inc b
    xor c
    add a
    ld d, h
    or c
    rrca
    res 6, l
    ld c, h
    ld d, l
    or a
    ld b, $3a
    cp h
    ld b, $36
    cp a
    ld c, $36
    cp a
    adc e
    ld [hl], $c0
    ld [wSpriteVar36], sp
    add [hl]
    ld [hl], $ff
; SharedTilesetData_578 - Tileset data partagée niveaux 5, 7, 8 ($54D5-$55BB)
; ==============================================================================
; Description: Tileset partagé utilisé par les niveaux 5, 7 et 8
; Format: Paires d'octets (position, tile_id), terminé par $FF $FF
;         - Chaque paire définit: position (nibbles: Y/X), tile ID
;         - Valeurs spéciales: $52/$53/$59 (bank selectors?), $D2/$D3 (commands?)
; Taille: 227 octets ($E3)
; Référencé par: LevelJumpTable niveaux 5, 7, 8 (lignes 22, 26, 28)
; ==============================================================================
SharedTilesetData_578:
    db $10, $06, $53, $11, $0F, $D3, $13, $08, $53, $14, $0D, $53, $17, $0A, $53, $19
    db $06, $53, $1A, $0F, $D3, $1C, $0C, $53, $1D, $09, $53, $23, $06, $53, $24, $08
    db $D3, $25, $0A, $53, $27, $0E, $53, $28, $0C, $D3, $29, $0A, $53, $2B, $06, $53
    db $2C, $05, $52, $2E, $05, $D2, $30, $05, $52, $34, $0F, $52, $36, $0F, $D2, $38
    db $0F, $52, $3C, $05, $52, $3D, $0A, $D2, $3E, $0F, $52, $42, $06, $52, $43, $0D
    db $52, $4C, $05, $53, $4D, $8B, $59, $4E, $06, $D3, $4E, $0C, $52, $50, $85, $59
    db $52, $0F, $52, $52, $06, $53, $56, $06, $59, $57, $0E, $53, $58, $8F, $59, $5A
    db $06, $52, $5A, $0E, $D2, $5C, $0F, $53, $5D, $09, $59, $5F, $08, $53, $60, $0D
    db $59, $63, $05, $53, $63, $0A, $52, $65, $0E, $53, $67, $09, $59, $68, $09, $53
    db $69, $0E, $D2, $6B, $09, $59, $6C, $08, $53, $71, $8A, $59, $72, $07, $53, $73
    db $0A, $52, $75, $0C, $52, $76, $8F, $59, $78, $08, $52, $7A, $0A, $53, $7B, $0E
    db $59, $7D, $07, $53, $7E, $0D, $53, $80, $8C, $59, $85, $05, $53, $87, $0E, $53
    db $89, $0E, $D2, $8E, $0A, $52, $90, $07, $52, $93, $0D, $53, $93, $06, $52, $CF
    db $8A, $54, $D9, $87, $D4, $DB, $0C, $54, $DC, $0D, $86, $E0, $08, $06, $E1, $08
    db $06, $EC, $8A, $61, $FF, $FF

; ==============================================================================
; SharedTilesetData_024 - Tileset data partagée niveaux 0, 1, 2, 4 ($55BB-$55E1)
; ==============================================================================
; Description: Table de pointeurs vers tiles graphiques (8 bytes/tile)
; Format: Séquence de words (16-bit pointers), terminée par $FF
;         - Chaque word pointe vers une tile de 8 octets en mémoire
; Taille: 39 octets ($27) - 19 pointeurs + terminateur
; Référencé par: LevelJumpTable niveaux 0, 1, 2, 4 (lignes 12, 14, 16, 20)
; ==============================================================================
SharedTilesetData_024:
    dw $56CD, TileGraphic_5ABB, $6048, $56CD, $574A, $57EB, $5D32, $586F
    dw TilesetBlock_58FE, TilesetBlock_58FE, TilesetBlock_596E, $574A, $57EB, $57EB, $586F, $574A
    dw TilesetBlock_58FE, $59EE, $5A5F
    db $FF  ; Terminateur

; ==============================================================================
; SharedMapData_012 - Map data partagée niveaux 0, 1, 2 ($55E2-$5604)
; ==============================================================================
; Description: Données de map (layout de tiles) partagées par les niveaux 0, 1 et 2
; Format: Séquence of words (16-bit tile IDs ou pointeurs), terminée par $FF
;         - Chaque word représente un tile dans le layout de la map
; Taille: 35 octets ($23) - 17 words + terminateur
; Référencé par: LevelJumpTable niveaux 0, 1, 2 (lignes 12, 14, 16)
; Note: $5E32, $5F44, $5FAD sont des pointeurs vers tile data non labellisés
;       Ces données font partie d'une grande zone mal désassemblée ($5D8A-$60xx)
;       TODO BFS: Créer labels MapTileData_5E32, MapTileData_5F44, MapTileData_5FAD
; ==============================================================================
SharedMapData_012:
    dw $56CD, TileGraphic_5ABB, $6048, MapTileData_5BA3, MapTileData_5C22, MapTileData_5CA6, $5D32, $5D8A
    dw $5E32, $5E32, $5E32, $5F44, $5F44, $5D32, $5FAD, MapTileData_5CA6  ; $5E32/$5F44/$5FAD: Tile data non labellisés
    dw $5A5F
    db $FF  ; Terminateur

; ==============================================================================
; SharedEntitiesData_012 - Entities data partagée niveaux 0-2 ($5605-$562F)
; ==============================================================================
; Description: Table de pointeurs vers les données d'entités pour niveaux 0, 1, 2
; Format: Séquence de words (16-bit pointeurs vers entités), terminée par $FF
;         - Chaque word pointe vers une définition d'entité (position/type)
; Taille: 43 octets ($2B) - 21 words + terminateur
; Référencé par: LevelJumpTable niveaux 0, 1, 2 (lignes 12, 14, 16)
; ==============================================================================
SharedEntitiesData_012:  ; $5605
    dw $56CD, $6327, $6327, $6100, $61B8, $6272, $61B8, $6100
    dw $6100, $6272, $6272, $61B8, $6327, $6327, $6272, $6272
    dw $6100, $640D, $6327, $6327, $650D
    db $FF  ; Terminateur

; ==============================================================================
; Level3TilesetData - Tileset data niveau 3 ($5630-$5664)
; ==============================================================================
; Description: Table de pointeurs vers tiles graphiques pour le niveau 3
; Format: Séquence de words (16-bit pointers), terminée par $FF
;         - Chaque word pointe vers une tile de 8 octets en mémoire
; Taille: 53 octets ($35) - 26 pointeurs + terminateur
; Référencé par: LevelJumpTable niveau 3 (ligne 18)
; ==============================================================================
Level3TilesetData:  ; $5630
    dw $6C81, $6C81, $6DDB, $65D3, $66A1, $67BF, $6882, $67BF
    dw $691C, $691C, $67BF, $69E2, $65D3, $6882, $66A1, $66A1
    dw $66A1
DataZone_5652:  ; $5652 - Référencé par du code (lignes 10194, 10254)
    dw $6882, $6882, $69E2, $691C, $6AA0, $6B51, $691C
    dw $6B51, $6C1B
    db $FF  ; Terminateur

; ==============================================================================
; Level3MapData - Map data niveau 3 ($5665-$5693)
; ==============================================================================
; Description: Données de map (layout de tiles) pour le niveau 3
; Format: Séquence de words (16-bit pointeurs vers tileset data), terminée par $FF
;         - Chaque word pointe vers des données de tileset dans bank 1
;         - Les pointeurs référencent des blocs de tile patterns compressés
; Taille: 47 octets ($2F) - 23 words + terminateur
; Référencé par: LevelJumpTable niveau 3 (ligne 18)
; ==============================================================================
Level3MapData:  ; $5665
    dw $6C81, $6C81, $6DDB, $6EA6, $6F60, $6F60, $6EA6, $6EA6
    dw $7038, $7038, $6F60, $7123, $7123, $71FC, $72BC, $71FC
    dw $72BC, $7379, $7123, $7379, $7442, $757C, $6C1B
    db $FF  ; Terminateur

; ==============================================================================
; Level3EntitiesData - Entities data niveau 3 ($5694-$56CA)
; ==============================================================================
; Description: Table de pointeurs vers les données d'entités pour niveau 3
; Format: Séquence de words (16-bit pointeurs vers entités), terminée par $FF
;         - Chaque word pointe vers une définition d'entité (position/type)
; Taille: 55 octets ($37) - 27 words + terminateur
; Référencé par: LevelJumpTable niveau 3 (ligne 18)
; ==============================================================================
Level3EntitiesData:  ; $5694
    dw $6C81, $6C81, $6DDB, $764F, $764F, $764F, $764F, $76D2
    dw $76D2, $76D2, $764F, $764F, $764F, $76D2, $76D2, $764F
    dw $775A, $775A, $77BD, $79E9, $791A, $791A, $79E9, $7AB2
    dw $7B5F, $7C0E, $7D01
    db $FF  ; Terminateur

; ==============================================================================
; ZONE MAL DÉSASSEMBLÉE: $56CB-$5A5F (Données compressées + pointeurs états)
; ==============================================================================
; ATTENTION: Les instructions ci-dessous sont en réalité des DONNÉES compressées
; mal interprétées comme du code par le désassembleur.
;
; Structure réelle:
;   $56CB-$56CC: Padding (2 bytes: $00 $00)
;   $56CD-$5749: CompressedTilesetData (125 bytes de données compressées)
;   $574A-$5A5F: Continuation données compressées/tiles
;
; Pointeurs d'états dans cette zone (bank_000.asm StateJumpTable):
;   Ces adresses sont utilisées comme pointeurs dans StateJumpTable mais pointent
;   vers des DONNÉES (stream de compression) et NON vers du code exécutable.
;   Les "états" $14, $15, $17-$1A sont en réalité des curseurs/pointeurs dans
;   un flux de données compressées utilisé pour décoder des tiles/maps.
;
;   $5832: État $14 - State14_CompressedDataPtr (offset +359 depuis $56CB)
;   $5835: État $15 - State15_CompressedDataPtr (offset +362 depuis $56CB) ← ANALYSÉ
;   $5838: État $17 - State17_CompressedDataPtr (offset +365 depuis $56CB)
;   $583B: État $18 - State18_CompressedDataPtr (offset +368 depuis $56CB)
;   $583E: État $19 - State19_CompressedDataPtr (offset +371 depuis $56CB)
;   $5841: État $1A - State1A_CompressedDataPtr (offset +374 depuis $56CB)
;
; Référencé par:
;   - SharedTilesetData_024 (ligne 3381) - niveaux 0, 1, 2
;   - SharedMapData_012 (ligne 3396) - niveaux 0, 1, 2
;   - SharedEntitiesData_012 (ligne 3411) - niveaux 0, 1, 2
;   - StateJumpTable (bank_000.asm:688-694) - états $14-$15, $17-$1A
;
; Format compression: Stream de commandes + données
;   - $5D $FE: Commande de répétition/copie
;   - $E2 XX: Commande avec argument
;   - Autres: Données brutes ou arguments
;
; TODO BFS: Reconstruire cette zone avec des 'db' statements corrects pour pouvoir
;           placer les labels State14-State1A aux adresses exactes
; ==============================================================================
TilesetData_Padding:  ; $56CB
    nop
    nop
CompressedTilesetData:  ; $56CD
    pop af
    ld e, l
    cp $f1
    ld e, l
    cp $e2
    ld h, b
    ld e, l
    cp $72
    add hl, sp
    dec a
    ldh [c], a
    ld h, c
    ld e, l
    cp $54
    inc sp
    ld [hl], $3a
    ld a, $e2
    ld h, c
    ld e, l
    cp $5b
    inc [hl]

DataZone_56e9:
    scf
    ld b, c
    ld e, b
    ld e, c
    ld e, c
    ld e, c
    ld e, c
    ld e, c
    ld h, c
    ld e, l
    cp $54
    dec [hl]
    jr c, DataZone_5733

    ccf
    ldh [c], a
    ld h, c
    ld e, l
    cp $72
    inc a
    ld b, b
    ldh [c], a
    ld h, c
    ld e, l
    cp $e2
    ld h, c
    ld e, l
    cp $e2
    ld h, c
    ld e, l
    cp $e2
    ld h, c
    ld e, l
    cp $e2
    ld h, c
    ld e, l
    cp $c4
    ld h, b
    ld e, d
    ld h, c
    ld e, l
    cp $c1
    ld h, c
    ldh [c], a
    ld h, e
    ld e, l
    cp $c1
    ld h, c
    pop af
    ld e, l
    cp $85
    ld h, b
    ld e, d
    ld e, d
    ld e, d
    ld h, c
    pop af
    ld e, l
    cp $81
    ld h, c
    call nz, $3163

DataZone_5733:
    ld sp, $fe5d
    add c
    ld h, c
    pop af
    ld e, l
    cp $81
    ld h, c
    pop af
    ld e, l
    cp $88
    ld h, e
    ld sp, $3131
    ld sp, $3131
    ld e, l
    db $FE  ; Opcode cp (partie de données compressées mal désassemblées)

; ==============================================================================
; TileGraphic_574A - Tile graphique 8x8 pixels (8 bytes)
; ==============================================================================
; Description: Données de tile graphique 8x8 (2 bits par pixel, 2 bytes par ligne)
; Format: 8 bytes représentant 8 lignes de pixels (2bpp format Game Boy)
;         Pattern: $6A $60 suivi de 6x $5A
; Taille: 8 octets
; Référencé par: SharedTilesetData_024 (lignes 3381-3382) - 3 occurrences
; ==============================================================================
TileGraphic_574A:  ; $574A
    db $6A, $60, $5A, $5A, $5A, $5A, $5A, $5A

    db $5A, $5A  ; Suite des données (2 bytes additionnels)
    ld e, l
    cp $61
    ld h, c
    pop af
    ld e, l
    cp $21
    add c
    ld h, c
    ld h, c
    pop af
    ld e, l
    cp $21
    add d
    ld h, c
    ld h, c
    ldh [c], a
    ld h, b
    ld e, l
    cp $21
    add c
    ld h, c
    ld h, c
    ldh [c], a
    ld h, c
    ld e, l
    cp $6a
    ld h, e
    ld sp, $3131
    ld sp, $3131
    ld sp, $5d61
    cp $e2
    ld h, c
    ld e, l
    cp $e2
    ld h, c
    ld e, l
    cp $e2
    ld h, c
    ld e, l
    cp $a6
    ld h, b
    ld e, d
    ld e, d
    ld e, d
    ld h, c
    ld e, l
    cp $a1
    ld h, c
    ldh [c], a
    ld h, e
    ld e, l
    cp $6a
    ld h, b
    ld e, d
    ld e, d
    ld e, d
    ld h, e
    ld sp, $3131
    ld sp, $fe5d
    dec a
    ld h, b
    ld e, d
    ld e, d
    ld h, e
    ld sp, $3131
    ld sp, $3131
    ld sp, $5d31
    cp $22
    db $f4
    ld h, c
    pop af
    ld e, l
    cp $31
    ld h, c
    add c
    ld e, a
    call nz, PatternData_5a60
    ld e, d
    ld e, l
    cp $22
    db $f4
    ld h, c
    pop bc
    ld h, c
    pop af
    ld e, l
    cp $31
    ld h, c
    call nz, $3163
    ld sp, $fe5d
    ld [hl+], a
    db $f4
    ld h, c
    pop af
    ld e, l
    cp $3d
    ld h, e
    ld sp, $3131
    ld sp, $3131
    ld sp, $3131
    ld sp, $5d31
    cp $f1
    ld e, l
    cp $f1

; ==============================================================================
; TileGraphic_57EB - Tile graphique 8x8 pixels (8 bytes)
; ==============================================================================
; Description: Données de tile graphique (format pattern compressé)
; Format: 8 bytes de données graphiques mal désassemblées comme code
;         Pattern binaire: $5D $FE $C4 $60 $5A $5A $5D $FE
;         Interprété comme: ld e,l / cp $c4 / ld h,b / ld e,d / ld e,d / ld e,l / (cp partiel)
; In: Aucun (données, pas du code exécutable)
; Out: Aucun
; Modifie: Aucun
; Taille: 8 octets ($57EB-$57F2)
; Référencé par: SharedTilesetData_024 (lignes 3381-3382) - 3 occurrences
; ==============================================================================
TileGraphic_57EB:  ; $57EB
    ld e, l
    cp $c4
    ld h, b
    ld e, d
    ld e, d
    ld e, l
    ; Note: Le byte $FE qui suit fait partie du tile, mais est aussi l'opcode de 'cp $c1'
    cp $c1
    ld h, c
    pop af
    ld e, l
    cp $c4
    ld h, e
    ld sp, $5d31
    cp $f1
    ld e, l
    cp $f1
    ld e, l
    cp $a6
    ld h, b
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld e, l
    cp $a1
    ld h, c
    pop af
    ld e, l
    cp $a6
    ld h, e
    ld sp, $3131
    ld sp, $fe5d
    pop af
    ld e, l
    cp $79
    ld h, b
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld e, l
    cp $71
    ld h, c
    pop af
    ld e, l
    cp $79
    ld h, e
    ld sp, $3131
    ld sp, $3131
    ld sp, $fe5d
    pop af
    ld e, l
    cp $4c
    ld h, b
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld e, l
    cp $41
    ld h, c
    pop af
    ld e, l
    cp $4c
    ld h, e
    ld sp, $3131
    ld sp, $5a60
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld e, l
    cp $91
    ld h, c
    pop af
    ld e, l
    cp $91
    ld h, c
    pop af
    ld e, l
    cp $97
    ld h, e
    ld sp, $3131
    ld sp, $5d31
; ==============================================================================
; TileGraphic_586F - Tile graphique 2BPP ($586F-$5876)
; ==============================================================================
; Description: Tile graphique 8x8 pixels, format 2BPP Game Boy
; Taille: 8 octets (4 lignes de pixels, 2 bytes/ligne)
; Référencé par: SharedTilesetData_024 (lignes 3381-3382) - 2 occurrences
; Note: Cette zone est mal désassemblée et nécessite reconstruction en db
; TODO: Reconstruire toute la zone $57F3-$5A5F en format db (tiles graphiques)
; ==============================================================================
TileGraphic_586F:  ; $586F (au milieu de l'instruction ci-dessous, byte 2)
    cp $e2
    ld h, b
    ld e, l
    cp $e2
    ld h, c
    ld e, l
    cp $b5
    ld [hl], b
    ld [hl], d
    ld [hl], d
    ld h, c
    ld e, l
    cp $b5
    ld [hl], c
    ld [hl], e
    ld [hl], e
    ld h, c
    ld e, l
    cp $e2
    ld h, c
    ld e, l
    cp $e2
    ld h, c
    ld e, l
    cp $e2
    ld h, c
    ld e, l
    cp $b5
    ld h, b
    ld e, d
    ld e, d
    ld h, c
    ld e, l
    cp $b1
    ld h, c
    ldh [c], a
    ld h, c
    ld e, l
    cp $31
    add c
    ld [hl], l
    ld h, b
    ld e, d
    ld e, d
    ld e, d
    ld h, c
    ldh [c], a
    ld h, c
    ld e, l
    cp $75
    ld h, e
    ld sp, $3131
    ld h, c
    ldh [c], a
    ld h, e
    ld e, l
    cp $b1
    ld h, c
    pop af
    ld e, l
    cp $48
    ld h, b
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld h, c
    pop af
    ld e, l
    cp $32
    db $f4
    ld h, c
    or c
    ld h, c
    pop af
    ld e, l
    cp $32
    db $f4
    ld h, c
    adc b
    db $f4
    ld h, b
    ld e, d
    ld h, e
    ld sp, $3131
    ld e, l
    cp $46
    ld h, e
    ld sp, $3131
    ld sp, $f161
    ld e, l
    cp $82
    db $f4
    ld h, c
    pop af
    ld e, l
    cp $91
    ld h, c
    pop af
    ld e, l
    cp $82
    db $f4
    ld h, c
    pop af
    ld e, l
    cp $97
    ld h, e
    ld sp, $3131
    ld sp, $5d31

; ==============================================================================
; TilesetBlock_58FE - Bloc de tiles graphiques 2BPP ($58FE-$596D)
; ==============================================================================
; Description: Bloc de 14 tiles graphiques 8x8 pixels, format 2BPP Game Boy
; Taille: 112 octets ($70) = 14 tiles × 8 bytes
; Référencé par: SharedTilesetData_024 (lignes 3382-3383) - 3 occurrences
; Format: Séquence de tiles 2BPP (2 bits par pixel, 8 bytes par tile)
; Note: Zone mal désassemblée comme code - devrait être reconstruite en 'db'
; TODO BFS: Reconstruire en format:
;   TilesetBlock_58FE:
;       db $71, $64, $F1, $5D, $FE, $71, $64, $F1  ; Tile 0
;       db $5D, $FE, $71, $64, $F1, $5D, $FE, $51  ; Tile 1
;       ... (12 tiles de plus)
; ==============================================================================
    db $FE  ; Premier byte de l'instruction 'cp $71' (opcode FE)
TilesetBlock_58FE:  ; $58FE - pointe vers le paramètre $71
    db $71  ; Deuxième byte de 'cp $71'
    ld h, h
    pop af
    ld e, l
    cp $71
    ld h, h
    pop af
    ld e, l
    cp $71
    ld h, h
    pop af
    ld e, l
    cp $51
    db $f4
    ld [hl], c
    ld h, h
    pop af
    ld e, l
    cp $51
    db $f4
    ld [hl], c
    ld h, h
    pop af
    ld e, l
    cp $51
    db $f4
    ld [hl], c
    ld h, h
    pop af
    ld e, l
    cp $71
    ld h, h
    pop af
    ld e, l
    cp $71
    ld h, h
    pop af
    ld e, l
    cp $71
    ld h, h
    pop af
    ld e, l
    cp $71
    ld h, h
    pop af
    ld e, l
    cp $71
    ld h, h
    pop af
    ld e, l
    cp $71
    ld h, h
    pop af
    ld e, l
    cp $51
    db $f4
    ld [hl], c
    ld h, h
    pop af
    ld e, l
    cp $51
    db $f4
    ld [hl], c
    ld h, h
    pop af
    ld e, l
    cp $51
    db $f4
    ld [hl], c
    ld h, h
    pop af
    ld e, l
    cp $71
    ld h, h
    pop af
    ld e, l
    cp $71
    ld h, h
    pop af
    ld e, l
    cp $71
    ld h, h
    pop af
    ld e, l
    cp $31
    db $f4
    pop af
    ld e, l
    cp $31
    db $f4
    db $F1, $5D  ; Derniers 2 bytes de TilesetBlock_58FE ($596B-$596C)
    db $FE       ; Dernier byte de TilesetBlock_58FE ($596D)

; ==============================================================================
; TilesetBlock_596E - Tile graphique 2BPP ($596E-$5975)
; ==============================================================================
; Description: Tile graphique 8x8 pixels, format 2BPP Game Boy
; Taille: 8 octets (1 tile × 8 bytes)
; Référencé par: SharedTilesetData_024 (ligne 3382)
; Format: Tile 2BPP (2 bits par pixel, 8 bytes par tile)
; ==============================================================================
TilesetBlock_596E:
    db $F1, $5D, $FE, $79, $60, $5A, $5A, $5A
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld e, l
    cp $79
    ld h, e
    ld sp, $3131
    ld sp, $3131
    ld sp, $fe5d
    or c
    ld a, a
    pop af
    ld e, l
    cp $b1
    ld a, a
    pop af
    ld e, l
    cp $b5
    ld h, b
    ld e, d
    ld e, d
    ld e, d
    ld e, l
    cp $b5
    ld h, e
    ld sp, $3131
    ld e, l
    cp $f1
    ld e, l
    cp $f1
    ld e, l
    cp $97
    ld h, b
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld e, l
    cp $97
    ld h, e
    ld sp, $3131
    ld sp, $5d31
    cp $91
    ld a, a
    pop af
    ld e, l
    cp $91
    ld a, a
    pop af
    ld e, l
    cp $91
    ld a, a
    pop af
    ld e, l
    cp $91
    ld a, a
    pop af
    ld e, l
    cp $91
    ld a, a
    pop af
    ld e, l
    cp $91
    ld a, a
    pop af
    ld e, l
    cp $91
    ld a, a
    pop af
    ld e, l
    cp $88
    ld h, b
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld e, l
    cp $88
    ld h, e
    ld sp, $3131
    ld sp, $3131
    ld e, l
    cp $31
    ld b, l
    pop af
    ld e, l
    cp $22
    ld b, d
    ld b, [hl]
    pop af
    ld e, l
    cp $22
    ld b, e
    ld b, a
    ldh [c], a
    ld h, h
    ld e, l
    cp $22
    ld b, h
    ld c, b
    ldh [c], a
    ld h, h
    ld e, l
    cp $e2
    ld h, h
    ld e, l
    cp $e2
    ld h, h
    ld e, l
    cp $f1
    ld e, l
    cp $f1
    ld e, l
    cp $22
    add c
    add d
    pop af
    ld e, l
    cp $f1
    ld e, l
    cp $f1
    ld e, l
    cp $31
    add d
    or c
    ld a, a
    pop af
    ld e, l
    cp $35
    add d
    db $f4
    db $f4
    db $f4
    add d
    pop af
    ld e, l
    cp $44
    db $f4
    db $f4
    db $f4
    add d
    pop af
    ld e, l
    cp $35
    add d
    db $f4
    db $f4
    db $f4
    add d
    pop af
    ld e, l
    cp $11
    ld b, l
    dec [hl]
    db $fd
    add d
    pop af
    ld e, l
    cp $02
    ld b, d
    ld b, [hl]
    pop af
    ld e, l
    cp $02
    ld b, e
    ld b, a
    pop af
    ld e, l
; ==============================================================================
; CompressedData_5A55 - Données compressées (tileset/map)
; ==============================================================================
; Description: Données compressées faisant partie du flux de compression
;              utilisé pour décoder tiles/maps (continuation depuis $56CB)
; Adresse: $5A55-$5A5F (11 bytes)
; Format: Commandes de compression + arguments
;   $5D $FE: Commande de répétition/copie
;   $02/$F1: Arguments de commande ou données brutes
; Référencé par:
;   - SharedTilesetData_024 (ligne 3383): pointeur $5A5F
;   - SharedMapData_012 (ligne 3398): pointeur $5A5F
; Note: Cette zone fait partie de la grande zone mal désassemblée $56CB-$5A5F
;       documentée ligne 3467. C'est des DONNÉES, pas du code exécutable.
; ==============================================================================
CompressedData_5A55:  ; $5A55
    db $FE, $02, $44, $48, $F1  ; $5A55-$5A59: Commande compression type 1
    db $5D                       ; $5A5A: Marqueur/commande
TilesetPointer_5A5B:  ; $5A5B - Pointeur utilisé dans tables tilesets
    db $FE, $F1                  ; $5A5B-$5A5C: Commande compression type 2
    db $5D                       ; $5A5D: Marqueur/commande
TilesetPointer_5A5F:  ; $5A5F - Pointeur vers TilePatternData_5A60
    db $FE, $F1                  ; $5A5E-$5A5F: Commande compression type 2

; PatternData_5a60
; ----------------
; Description: Données de pattern compressées (50 bytes)
;              Format: séquences de commandes de décompression
;              Pattern répété: $8E $FE $F1 $8F $FE $F1
; Utilisation: Référencé à $5A5F (TilesetPointer)
PatternData_5a60:
    db $8E, $FE, $F1, $8F, $FE, $F1  ; Pattern répété x8
    db $8E, $FE, $F1, $8F, $FE, $F1
    db $8E, $FE, $F1, $8F, $FE, $F1
    db $8E, $FE, $F1, $8F, $FE, $F1
    db $8E, $FE, $F1, $8F, $FE, $F1
    db $8E, $FE, $F1, $8F, $FE, $F1
    db $8E, $FE, $F1, $8F, $FE, $F1
    db $8E, $FE, $F1, $8F, $FE, $F1
    db $8E, $FE                       ; Pattern partiel final

; ==============================================================================
; CompressedTileData_5A92 - Données compressées de tiles/map ($5A92-$5B48)
; ==============================================================================
; Description: Bloc de données compressées (pattern/commandes de compression)
;              Contient des tiles graphiques et des commandes de décompression
; Taille: 183 bytes
; Référencé par: SharedTilesetData_024, SharedMapData_012
; Format: Mélange de commandes compression ($FE, $FD) et données raw
; ==============================================================================
CompressedTileData_5A92:  ; $5A92
    db $21, $8E, $F1, $8F, $FE, $00, $13, $24
    db $8F, $8E, $8E, $8E, $8E, $8E, $8E, $8E
    db $8E, $8E, $8E, $13, $24, $8E, $FE, $00
    db $21, $56, $8E, $8F, $8F, $8F, $8F, $8F
    db $8F, $8F, $8F, $8F, $8F, $21, $56, $8F
    db $FE

; ==============================================================================
; TileGraphic_5ABB - Tile graphique 8x8 pixels (8 bytes)
; ==============================================================================
; Description: Tile graphique au format 2BPP Game Boy
;              Pattern: $00 $FD $7F $FE $A1 $5F $F1 $7F
; In: Aucun (données, pas du code exécutable)
; Out: Aucun
; Modifie: Aucun
; Taille: 8 octets (1 tile)
; Référencé par:
;   - SharedTilesetData_024 (ligne 3381) - niveaux 0,1,2,4
;   - SharedMapData_012 (ligne 3396) - niveaux 0,1,2
; Format: 8 bytes 2BPP (2 bits par pixel)
; ==============================================================================
TileGraphic_5ABB:  ; $5ABB
    db $00, $FD, $7F, $FE, $A1, $5F, $F1, $7F

; Continuation données compressées après TileGraphic_5ABB
    db $FE, $F1, $7F, $FE, $F1, $7F, $FE, $05
    db $FD, $7F, $F1, $7F, $FE, $05, $7F, $F4
    db $F4, $F4, $7F, $F1, $7F, $FE, $05, $7F
    db $F4, $F4, $F4, $7F, $E2, $FD, $7F, $FE
    db $05, $7F, $F4, $F4, $F4, $7F, $A1, $82
    db $E2, $FD, $7F, $FE, $05, $7F, $F4, $F4
    db $F4, $82, $71, $82, $A1, $7F, $E2, $FD
    db $7F, $FE, $06, $7F, $F4, $F4, $F4, $7F
    db $7F, $91, $80, $E2, $FD, $7F, $FE, $06
    db $7F, $F4, $F4, $F4, $F4, $7F, $97, $FD
    db $7F, $FE, $06, $7F, $F4, $F4, $F4, $F4
    db $7F, $A6, $F4, $F4, $F4, $7F, $7F, $7F
    db $FE, $06, $7F, $F4, $F4, $F4, $F4, $7F
    db $97, $7F, $F4, $F4, $F4, $F4, $F4, $7F
    db $FE, $06, $7F, $F4, $F4, $F4, $F4, $7F
    db $97, $7F, $F4, $F4, $F4, $F4, $F4, $7F
    db $FE, $08, $7F, $F4, $F4, $F4

ProcessLevelData_5b49:
    db $f4
    ld a, a
    ld a, a
    ld a, a
    sub a
    add d
    add d
    add d
    db $f4
    db $f4
    db $f4
    ld a, a
    cp $06
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    or l
    add d
    db $f4
    db $f4
    db $f4
    ld a, a
    cp $06
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    or l
    ld a, a
    db $f4
    db $f4
    db $f4
    ld a, a
    cp $06
    ld a, a
    db $f4
    db $f4
    ld a, a
    ld a, a
    ld a, a
    sub a
    ld [hl], h
    ld [hl], a
    ld a, a
    db $f4
    db $f4
    db $f4
    ld a, a
    cp $05
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    sub a
    ld [hl], l
    ld a, b
    ld a, a
    db $f4
    db $f4
    db $f4
    ld a, a
    cp $00
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    halt
    ld a, c
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    db $FE  ; Dernier byte de ProcessLevelData_5b49 ($5BA2)

; ==============================================================================
; MapTileData_5BA3 - Données de map encodées ($5BA3-$5C21)
; ==============================================================================
; Description: Données de tiles/map encodées, utilisées pour construire le layout
; Format: Séquence de bytes encodés (opcodes de compression/repeat + paramètres)
;         Pattern: $FE = commande, $F1/$E2/$5D = fin/séparateur, autres = données
; Taille: 127 octets ($7F)
; Référencé par: SharedMapData_012 (ligne 3396) - niveaux 0, 1, 2
; ==============================================================================
MapTileData_5BA3:  ; $5BA3
    db $F1, $5D, $FE, $F1, $5D, $FE, $E2, $65, $5D, $FE, $42, $39, $3D, $E2, $66, $5D
    db $FE, $24, $33, $36, $3A, $3E, $E2, $65, $5D, $FE, $2E, $34, $37, $41, $58, $59
    db $59, $59, $59, $59, $59, $59, $59, $66, $5D, $FE, $24, $35, $38, $3B, $3F, $E2
    db $65, $5D, $FE, $42, $3C, $40, $E2, $66, $5D, $FE, $E2, $65, $5D, $FE, $E2, $66
    db $5D, $FE, $E2, $65, $5D, $FE, $E2, $66, $5D, $FE, $E2, $65, $5D, $FE, $21, $45
    db $E2, $66, $5D, $FE, $12, $42, $46, $E2, $65, $5D, $FE, $12, $43, $47, $E2, $66
    db $5D, $FE, $12, $44, $48, $B5, $67, $69, $67, $69, $5D, $FE, $B5, $68, $6A, $68
    db $6A, $5D, $FE, $B2, $67, $69, $F1, $5D, $FE, $B2, $68, $6A, $F1, $5D, $FE

; ==============================================================================
; MapTileData_5C22 - Tile data map section (mal désassemblé) ($5C22-$5CA5)
; ==============================================================================
; Description: Données de tiles pour map, actuellement mal désassemblées comme du code
;              Les octets générés par ces instructions forment des tile data compressées
;              Format RLE avec pattern: [flag/count] [tile_ids]* $F1 $5D $FE (fin ligne)
; Format: Instructions Z80 qui génèrent les bytes corrects pour tile data
; Taille: 132 octets ($84)
; Référencé par: SharedMapData_012 (ligne 3396, index 4)
; Note: Ces instructions DOIVENT rester telles quelles car elles génèrent les bons bytes
; ==============================================================================
MapTileData_5C22:  ; ($5C22) Tile data (mal désassemblée - à reconstruire en db dans futur BFS)
    or d
    ld h, a
    ld l, c
    pop af
    ld e, l
    cp $b2
    ld l, b
    ld l, d
    pop af
    ld e, l
    cp $b2
    ld h, a
    ld l, c
    pop af
    ld e, l
    cp $31
    ld b, l
    or d
    ld l, b
    ld l, d
    pop af
    ld e, l
    cp $22
    ld b, d
    ld b, [hl]
    or d
    ld h, a
    ld l, c
    pop af
    ld e, l
    cp $22
    ld b, e
    ld b, a
    or d
    ld l, b
    ld l, d
    pop af
    ld e, l
    cp $22
    ld b, h
    ld c, b
    pop af
    ld e, l
    cp $b1
    ld a, a
    pop af
    ld e, l
    cp $f1
    ld e, l

CheckResult_5c5b:
    cp $b1
    ld a, a
    pop af
    ld e, l
    cp $f1
    ld e, l
    cp $b1
    ld a, a
    pop af
    ld e, l
    cp $11
    ld b, l
    pop af
    ld e, l
    cp $02
    ld b, d
    ld b, [hl]
    or d
    ld h, a
    ld l, c
    pop af
    ld e, l
    cp $02
    ld b, e
    ld b, a
    or d
    ld l, b
    ld l, d
    pop af
    ld e, l
    cp $02
    ld b, d
    ld b, [hl]
    or d
    ld h, a
    ld l, c
    pop af
    ld e, l
    cp $02
    ld b, e
    ld b, a
    ld h, c
    add c
    or d
    ld l, b
    ld l, d
    pop af
    ld e, l
    cp $02
    ld b, h
    ld c, b
    or d
    ld h, a
    ld l, c
    pop af
    ld e, l
    cp $b2
    ld l, b
    ld l, d
    pop af
    ld e, l
    cp $f1
    ld e, l
    db $FE  ; cp (opcode, fait partie de MapTileData_5C22)
; MapTileData_5CA6 ($5CA6-$5D31) - Tile data RLE (140 bytes, mal désassemblé)
; Données de tiles pour map référencées par SharedMapData_012 (index 5, 15)
; Format: bytes RLE [flag][tiles]*[$F1 $5D $FE] - À reconstruire en db dans futur BFS
MapTileData_5CA6:  ; ($5CA6)
    db $84  ; Opérande de l'instruction cp précédente, début MapTileData_5CA6
    ld h, a
    ld l, c
    ld h, a
    ld l, c
    pop af
    ld e, l
    cp $84
    ld l, b
    ld l, d
    ld l, b
    ld l, d
    pop af
    ld e, l
    cp $a2
    ld h, a
    ld l, c
    pop af
    ld e, l
    cp $61
    add c
    and d
    ld l, b
    ld l, d
    ldh [c], a
    ld a, a
    ld e, l
    cp $a2
    ld h, a
    ld l, c
    ldh [c], a
    ld a, a
    ld e, l
    cp $11
    db $f4
    ld h, [hl]
    ld [hl], b
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld l, b
    ld l, d
    ldh [c], a
    ld a, a
    ld e, l
    cp $11
    db $f4
    ld h, [hl]
    ld [hl], c
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld h, a
    ld l, c
    ldh [c], a
    ld a, a
    ld e, l
    cp $a2
    ld l, b
    ld l, d
    ldh [c], a
    ld a, a
    ld e, l
    cp $e2
    ld a, a
    ld e, l
    cp $e2
    ld a, a
    ld e, l
    cp $42
    ld h, a
    ld l, c
    pop af
    ld e, l
    cp $42
    ld l, b
    ld l, d
    pop af
    ld e, l
    cp $f1
    ld e, l
    cp $82
    ld h, a
    ld l, c
    pop af
    ld e, l
    cp $84
    ld l, b
    ld l, d
    ld h, a
    ld l, c
    pop af
    ld e, l
    cp $a2
    ld l, b
    ld l, d
    pop af
    ld e, l
    cp $a2
    ld h, a
    ld l, c
    pop af
    ld e, l
    cp $a2
    ld l, b
    ld l, d
    pop af
    ld e, l
    cp $a2
    ld h, a
    ld l, c
    pop af
    ld e, l
    cp $61
    add c
    and d
    ld l, b
    ld l, d
    pop af
    ld e, l
    cp $f1
    ld e, l
    cp $f1
    ld e, l
    cp $11
    ld b, l
    pop af
    ld e, l
    cp $02
    ld b, d
    ld b, [hl]
    pop af
    ld e, l
    cp $02
    ld b, e
    ld b, a
    pop af
    ld e, l
    cp $02
    ld b, d
    ld b, [hl]
    pop af
    ld e, l
    cp $02
    ld b, e
    ld b, a
    pop af
    ld e, l
    cp $02
    ld b, h
    ld c, b
    pop af
    ld e, l
    cp $f1
    ld e, l
    cp $f1
    ld e, l
    cp $f1
    ld e, l
    cp $f1
    ld e, l
    cp $f1
    ld e, l
    cp $21
    ld b, l
    pop af
    ld e, l
    cp $12
    ld b, d
    ld b, [hl]
    pop af
    ld e, l
    cp $12
    ld b, e
    ld b, a
    pop af
    ld e, l
    cp $12
    ld b, h
    ld c, b
    pop af
    ld e, l
    cp $f1
    ld e, l
    cp $f1
    ld e, l
    cp $f1
    ld e, l
; MapTileData_5D8A ($5D8A-$5E31) - Map tile data encoded (168 bytes)
; Référencé par SharedMapData_012 (ligne 3400)
; Note: Le label pointe vers le 2e byte de l'instruction 'cp $f1' ci-dessous
; TODO BFS: Zone mal désassemblée $5D8A-$60xx contient aussi:
;           - MapTileData_5E32 @ $5E32 (168 bytes, pattern similaire)
;           - MapTileData_5F44 @ $5F44 (105 bytes, format RLE: $E1 $XX $FE ...)
;           - MapTileData_5FAD @ $5FAD (339 bytes, $5FAD-$60FF, RLE, ligne 5235)
;           Reconstruire ces zones en db avec labels appropriés
MapTileData_5D8A:  ; $5D8A - pointe vers le byte $F1
    cp $f1
    ld e, l
    cp $f1
    ld e, l
    cp $d3
    ld [hl], b
    ld [hl], d
    ld e, l
    cp $d3
    ld [hl], c
    ld [hl], e
    ld e, l
    cp $08
    db $fd
    db $f4
    ldh [c], a
    ld h, l
    ld e, l
    cp $e2
    ld h, [hl]
    ld e, l
    cp $f1
    ld e, l
    cp $f1
    ld e, l
    cp $11
    ld b, l
    ldh [c], a
    ld h, d
    ld e, l
    cp $02
    ld b, d
    ld b, [hl]
    pop bc
    ld a, a
    ldh [c], a
    ld h, d
    ld e, l
    cp $02
    ld b, e
    ld b, a
    pop bc
    ld a, a
    ldh [c], a
    ld h, d
    ld e, l
    cp $02
    ld b, h
    ld c, b
    and e
    ld h, a
    ld l, c
    ld a, a
    ldh [c], a
    ld h, d
    ld e, l
    cp $85
    ld h, a
    ld l, c
    ld l, b
    ld l, d
    ld a, a
    ldh [c], a
    ld h, d
    ld e, l
    cp $82
    ld l, b
    ld l, d
    ldh [c], a
    ld h, d
    ld e, l
    cp $02
    ld h, a
    ld l, c
    add d
    ld h, a
    ld l, c
    ldh [c], a
    ld h, d
    ld e, l
    cp $00
    ld l, b
    ld l, d
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld l, b
    ld l, d
    ld e, d
    ld e, d
    ld e, d
    ld a, a
    ld e, d
    ld e, l
    cp $00
    ld h, a
    ld l, c
    ld sp, $3131
    ld sp, $3131
    ld h, a
    ld l, c
    ld sp, $3131
    ld a, a
    ld sp, $fe5d
    ld [bc], a
    ld l, b
    ld l, d
    add d
    ld l, b
    ld l, d
    pop de
    ld a, a
    pop af
    ld e, l
    cp $02
    ld h, a
    ld l, c
    add h
    ld h, a
    ld l, c
    ld h, a
    ld l, c
    pop de
    ld a, a
    pop af
    ld e, l
    cp $02
    ld l, b
    ld l, d
    add h
    ld l, b
    ld l, d
    ld l, b
    ld l, d
    pop de
    ld a, a
    pop af
    ld e, l
    cp $02
    ld h, a
    ld l, c
    ld b, c
    add d
    add h
    ld h, a
    ld l, c
    ld h, a
    ld l, c
    ldh [c], a
    ld a, a
    ld e, l
    cp $02
    ld l, b
    ld l, d
    ld b, c
    add d
    add h
    ld l, b
    ld l, d
    ld l, b
    ld l, d
    ldh [c], a
    ld a, a
    ld e, l
    cp $02
    ld h, a
    ld l, c
    ld b, c
    add d
    add d
    ld h, a
    ld l, c
    ldh [c], a
    ld a, a
    ld e, l
    cp $02
    ld l, b
    ld l, d
    ld b, c
    add d
    add d
    ld l, b
    ld l, d
    jp nz, Bank1EndPadding

    pop af
    ld e, l
    cp $02
    ld h, a
    ld l, c
    ld b, c
    add d
    add d
    ld h, a
    ld l, c
    jp nz, Bank1EndPadding

    pop af
    ld e, l
    cp $02
    ld l, b
    ld l, d
    ld b, c
    add d
    add d
    ld l, b
    ld l, d
    jp nz, Bank1EndPadding

    pop af
    ld e, l
    cp $02
    ld h, a
    ld l, c
    ld b, c
    add d
    add d
    ld h, a
    ld l, c
    jp nz, Bank1EndPadding

    pop af
    ld e, l
    cp $02
    ld l, b
    ld l, d
    ld b, c
    add d
    add d
    ld l, b
    ld l, d
    jp nz, Bank1EndPadding

    pop af
    ld e, l
    cp $02
    ld h, a
    ld l, c
    ld b, c
    add d
    add [hl]
    ld h, a
    ld l, c
    ld h, a
    ld l, c
    db $f4
    ld a, a
    pop af
    ld e, l
    cp $02
    ld l, b
    ld l, d
    ld b, c
    add d
    add [hl]
    ld l, b
    ld l, d
    ld l, b
    ld l, d
    db $f4
    ld a, a
    pop af
    ld e, l
    cp $02
    ld h, a
    ld l, c
    ld b, c
    add d
    add c
    add d
    ldh [c], a
    ld a, a
    ld e, l
    cp $02
    ld l, b
    ld l, d
    ld b, c
    add d
    add c
    add d
    or c
    add b
    ldh [c], a
    ld a, a
    ld e, l
    cp $02
    ld h, a
    ld l, c
    ld b, c
    add d
    add l
    ld h, a
    ld l, c
    ld h, a
    ld l, c
    ld a, a
    ldh [c], a
    ld a, a
    ld e, l
    cp $02
    ld l, b
    ld l, d
    ld b, c
    add d
    add l
    ld l, b
    ld l, d
    ld l, b
    ld l, d
    ld a, a
    ldh [c], a
    ld a, a
    ld e, l
    cp $02
    ld h, a
    ld l, c
    ld b, c
    add d
    add d
    ld h, a
    ld l, c
    ldh [c], a
    ld a, a
    ld e, l
    cp $02
    ld l, b
    ld l, d
    ld b, c
    add b
    add d
    ld l, b
    ld l, d
    ldh [c], a
    ld a, a
    ld e, l
    cp $00
    ld h, a
    ld l, c
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld h, a
    ld l, c
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld a, a
    ld e, l
    cp $00
    ld l, b
    ld l, d
    ld sp, $3131
    ld sp, $3131
    ld l, b
    ld l, d
    ld sp, $3131
    ld sp, $5d7f
    cp $02
    ld h, a
    ld l, c
    add c
    add d
    or c
    ld a, a
    ldh [c], a
    ld a, a
    ld e, l
    cp $02
    ld l, b
    ld l, d
    add c
    add d
    ldh [c], a
    ld a, a
    ld e, l
    cp $d1
    ld a, a
    pop af
    ld e, l
    cp $d1
    ld a, a
    pop af
    ld e, l
    cp $f1
    ld e, l
    cp $f1
    ld e, l
    cp $21
    ld b, l
    ldh [c], a
    ld h, l
    ld e, l
    cp $12
    ld b, d
    ld b, [hl]
    ldh [c], a
    ld h, [hl]
    ld e, l
    cp $12
    ld b, e
    ld b, a
    ldh [c], a
    ld h, l
    ld e, l
    cp $12
    ld b, d
    ld b, [hl]
    ldh [c], a
    ld h, [hl]
    ld e, l
    cp $12
    ld b, e
    ld b, a
    ldh [c], a
    ld h, l
    ld e, l
    cp $12
    ld b, h
    ld c, b
    ldh [c], a
    ld h, [hl]
    ld e, l
    cp $e2
    ld h, l
    ld e, l
    cp $e2
    ld h, [hl]
    ld e, l
    cp $e2
    ld h, l
    ld e, l
    cp $e2
    ld h, [hl]
    ld e, l
    cp $e2
    ld h, l
    ld e, l
    cp $e2
    ld h, [hl]
    ld e, l
    cp $d3
    ld h, a
    ld l, c
    ld e, l
    cp $d3
    ld l, b
    ld l, d
    ld e, l
    cp $b5
    ld h, a
    ld l, c
    ld h, a
    ld l, c
    ld e, l
    cp $b5
    ld l, b
    ld l, d
    ld l, b
    ld l, d
    ld e, l
    cp $b5
    ld h, a
    ld l, c
    ld h, a
    ld l, c
    ld e, l
    cp $b5
    ld l, b
    ld l, d
    ld l, b
    ld l, d
    ld e, l
    cp $c1
    ld a, a
    pop af
    ld e, l
    cp $c1
    ld a, a
    pop af
    ld e, l
    cp $11
    ld b, l
    add c
    add c
    pop bc
    ld a, a
    pop af
    ld e, l
    cp $02
    ld b, d
    ld b, [hl]
    ld b, c
    add c
    add c
    add c
    pop bc
    ld a, a
    pop af
    ld e, l
    cp $02
    ld b, e
    ld b, a
    add c
    add c
    pop bc
    ld a, a
    pop af
    ld e, l
    cp $02
    ld b, d
    ld b, [hl]
    pop bc
    ld a, a
    pop af
    ld e, l
    cp $02
    ld b, e
    ld b, a
    or d
    ld h, a
    ld l, c
    pop af
    ld e, l
    cp $02
    ld b, h
    ld c, b
    or d
    ld l, b
    ld l, d
    pop af
    ld e, l
    cp $f1
    ld e, l
    cp $f1
    ld e, l
    cp $97
    ld h, a
    ld l, c
    ld h, a
    ld l, c
    ld h, a
    ld l, c
    ld e, l
    cp $97
    ld l, b
    ld l, d
    ld l, b
    ld l, d
    ld l, b
    ld l, d
    ld e, l
    cp $68
    ld h, a
    ld l, c
    ld h, a
    ld l, c
    ld h, a
    ld l, c
    ld h, a
    ld l, c
    pop af
    ld e, l
    cp $68
    ld l, b
    ld l, d
    ld l, b
    ld l, d
    ld l, b
    ld l, d
    ld l, b
    ld l, d
    pop af
    ld e, l
    cp $f1
    ld e, l
    cp $f1
    ld e, l
    cp $86
    ld [hl], b
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld h, a
    ld l, c
    pop af
    ld e, l
    cp $86
    ld [hl], c
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld l, b
    ld l, d
    pop af
    ld e, l
    cp $00
    db $fd
    ld a, a
    cp $f1
    ld a, a
    cp $e2
    db $f4
    ld a, a
    cp $08
    db $fd
    ld a, a
    pop af
    ld a, a
    cp $01
    ld a, a
    or c
    ld e, a
    ldh [c], a
    db $f4
    ld a, a
    cp $01
    ld a, a
    ld [hl], c
    ld a, a
    pop af
    ld a, a
    cp $01
    ld a, a
    ld [hl+], a
    db $f4
    ld a, a
    ld h, d
    db $f4
    ld a, a
    ldh [c], a
    db $f4
    ld a, a
    cp $01
    ld a, a
    ld sp, $717f
    ld a, a
    pop af
    ld a, a
    cp $01
    ld a, a
    ld [hl+], a
    db $f4
    ld a, a
    ld h, c
    db $f4
    ldh [c], a
    db $f4
    ld a, a
    cp $01
    ld a, a
    ld sp, $717f
    ld a, a
    pop af
    ld a, a
    cp $01
    ld a, a
    ld [hl+], a
    db $f4
    ld a, a
    ld h, c
    db $f4
    ldh [c], a
    db $f4
    ld a, a
    cp $01
    ld a, a
    ld sp, $717f
    ld a, a
    pop af
    ld a, a
    cp $01
    ld a, a
    ld [hl+], a
    db $f4
    ld a, a
    ld h, c
    db $f4
    ldh [c], a
    db $f4
    ld a, a
    cp $01
    ld a, a
    ld sp, $717f
    ld a, a
    pop af
    ld a, a
    cp $01
    ld a, a
    ld [hl+], a
    db $f4
    ld a, a
    ld h, c
    db $f4
    ldh [c], a
    db $f4
    ld a, a
    cp $01
    ld a, a
    ld sp, $717f
    ld a, a
    pop af
    ld a, a
    cp $04
    ld a, a
    ld [hl], h
    ld [hl], a
    add b
    ld h, d
    db $f4
    ld a, a
    ldh [c], a
    db $f4
    ld a, a
    cp $04
    ld a, a
    ld [hl], l
    ld a, b
    add d
    ld [hl], c
    ld a, a
    pop af
    ld a, a
    cp $04
    ld [hl], d
    halt
    ld a, c
    ld a, a
    or c
    ld e, a
    ldh [c], a
    db $f4
    ld a, a
    cp $00
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    and c
    ld c, c
    call nz, CheckResult_5c5b
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ld [hl], c
    ld d, a
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    pop bc
    ld c, c
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    sub c
    ld d, a
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ld d, c
    ld d, a
    or l
    ld c, c
    ld c, h
    ld d, b
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    add c
    ld d, a
    or l
    ld d, h
    ld c, l
    ld d, c
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    or l
    ld d, l
    ld c, [hl]
    ld d, d
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    db $C4, $4F, $53  ; call nz, $534f (data within SharedMapData_467, not code)
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ld b, [hl]
    db $fd
    db $f4
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ld d, c
    db $f4
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ld [hl], c
    ld d, a
    or c
    ld c, c
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    and c
    ld d, a
    call nz, CheckResult_5c5b
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ld b, c
    db $f4
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ld b, c
    db $f4
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    call nz, $8282
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    call nz, $8280
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    pop bc
    db $f4
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ld b, d
    db $fd
    add d
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ld b, d
    add b
    add d
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    pop bc
    db $f4
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    call nz, $504c
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    or l
    ld d, h
    ld c, l
    ld d, c
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    sub c
    ld d, a
    or l
    ld d, l
    ld c, [hl]
    ld d, d
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    or l
    ld c, c
    ld c, a
    ld d, e
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    sub c
    ld l, h
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    sub c
    ld l, l
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    sub c
    ld d, a
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ld [hl], c
    ld l, h
    or c
    ld c, c
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ld [hl], c
    ld l, l
    call nz, CheckResult_5c5b
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $09
    ld e, l
    ld c, d
    ld l, h
    ld l, h
    add d
    add d
    add d
    add d
    add d
    and [hl]
    add d
    add d
    add d
    add d
    ld l, h
    ld l, [hl]
    cp $09
    ld e, l
    ld c, d
    ld l, l
    ld l, l
    add d
    add d
    add d
    add d
    add d
    and [hl]
    add d
    add d
    add d
    add d
    ld l, l
    ld l, [hl]
    cp $09
    ld e, l
    ld c, d
    ld l, h
    ld l, h
    add d
    add d
    add d
    add d
    add d
    and [hl]
    add b
    add d
    add d
    add d
    ld l, h
    ld l, [hl]
    cp $04
    ld e, l
    ld c, d
    ld l, l
    ld l, l
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld l, h
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld l, l
    and c
    db $f4
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld l, h
    and c
    db $f4
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld l, l
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld l, h
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld l, l
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld l, h
    ld d, c
    db $f4
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld l, l
    ld d, c
    db $f4
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld l, h
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld l, l
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $04
    ld e, l
    ld c, d
    ld l, h
    ld l, h
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $07
    ld e, l
    ld c, d
    ld l, l
    ld l, l
    add d
    add d
    add d
    adc b
    add d
    add d
    add d
    add d
    add d
    add d
    ld l, l
    ld l, [hl]
    cp $07
    ld e, l
    ld c, d
    ld l, h
    ld l, h
    add d
    add d
    add d
    adc b
    add d
    add d
    add d
    add d
    add d
    add d
    ld l, h
    ld l, [hl]
    cp $07
    ld e, l
    ld c, d
    ld l, l
    ld l, l
    add d
    add d
    add d
    adc b
    add b
    add d
    add d
    add d
    add d
    add d
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld l, h
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld l, l
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ld h, c
    db $f4
    call nz, $504c
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ld d, c
    db $f4
    or l
    ld d, h
    ld c, l
    ld d, c
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ld b, [hl]
    db $fd
    db $f4
    or l
    ld d, l
    ld c, [hl]
    ld d, d
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    db $C4, $4F, $53  ; call nz, $534f (data within SharedMapData_467, not code)
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ld d, l
    db $fd
    db $f4
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ld b, c
    db $f4
    ld [hl], c
    db $f4
    call nz, $504c
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ld b, c
    db $f4
    ld [hl], c
    db $f4
    or l
    ld d, h
    ld c, l
    ld d, c
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ld d, l
    db $fd
    db $f4
    or l
    ld d, l
    ld c, [hl]
    ld d, d
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    db $C4, $4F, $53  ; call nz, $534f (data within SharedMapData_467, not code)
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ld b, [hl]
    db $fd
    db $f4
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ld b, c
    db $f4
    ld h, c
    db $f4
    call nz, $504c
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ld b, c
    db $f4
    ld h, d
    db $fd
    db $f4
    or l
    ld d, h
    ld c, l
    ld d, c
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ld d, d
    db $fd
    db $f4
    add d
    db $fd
    db $f4
    or l
    ld d, l
    ld c, [hl]
    ld d, d
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    db $C4, $4F, $53  ; call nz, $534f (data within SharedMapData_467, not code)
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ld b, [hl]
    db $fd
    db $f4
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    call nz, $504c
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ld d, h
    db $fd
    db $f4
    or l
    ld d, h
    ld c, l
    ld d, c
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ld b, c
    db $f4
    sub c
    db $f4
    or l
    ld d, l
    ld c, [hl]
    ld d, d
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ld b, c
    db $f4
    sub c
    db $f4
    db $C4, $4F, $53  ; call nz, $534f (data within SharedMapData_467, not code)
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld c, d
    ld e, [hl]
    ld d, h
    db $fd
    db $f4
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $0d
    ld e, l
    ld l, h
    ld e, a
    ld e, a
    ld e, a
    ld e, a
    ld e, a
    ld e, a
    ld e, a
    ld e, a
    ld e, a
    ld e, a
    ld e, a
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $02
    ld e, l
    ld l, l
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $02
    ld e, l
    ld l, h
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $02
    ld e, l
    ld l, l
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $02
    ld e, l
    ld l, h
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $02
    ld e, l
    ld l, l
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $02
    ld e, l
    ld l, h
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $02
    ld e, l
    ld l, l
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $02
    ld e, l
    ld l, h
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $02
    ld e, l
    ld l, l
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld l, h
    ld l, h
    db $d3
    ld l, h
    ld l, h
    ld l, [hl]
    cp $03
    ld e, l
    ld l, l
    ld l, l
    db $d3
    ld l, l
    ld l, l
    ld l, [hl]
    cp $03
    ld e, l
    ld l, h
    ld l, h
    pop af
    ld l, [hl]
    cp $03
    ld e, l
    ld l, l
    ld l, l
    pop af
    ld l, [hl]
    cp $00
    ld e, l
    ld l, h
    ld l, h
    ld l, h
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    add d
    add d
    ld l, [hl]
    cp $04
    ld e, l
    ld l, l
    ld l, l
    ld l, l
    db $d3
    add d
    add d
    ld l, [hl]
    cp $04
    ld e, l
    ld l, h
    ld l, h
    ld l, h
    db $d3
    add d
    add d
    ld l, [hl]
    cp $04
    ld e, l
    ld l, l
    ld l, l
    ld l, l
    sub a
    pop hl
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld l, [hl]
    cp $00
    ld e, l
    ld l, h
    ld l, h
    ld l, h
    ld a, a
    ld a, a
    db $ec
    db $ec
    db $ec
    db $ec
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld l, [hl]
    cp $06
    ld e, l
    ld l, l
    ld l, l
    ld l, l
    ld a, a
    ld a, a
    and [hl]
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld l, [hl]
    cp $02
    ld sp, $e280
    ld h, l
    ld h, [hl]
    cp $02
    ld [hl-], a
    add d
    ldh [c], a
    ld h, c
    add sp, -$02
    ld [bc], a
    ld sp, $b582
    ld [hl], b
    ld [hl], d
    ld [hl], d
    ld h, c
    add sp, -$02
    ld [bc], a
    ld [hl-], a
    add d
    or l
    ld [hl], c
    ld [hl], e
    ld [hl], e
    ld h, c
    add sp, -$02
    ld [bc], a
    ld sp, $3282
    inc [hl]
    dec [hl]
    ldh [c], a
    ld h, b
    add sp, -$02
    nop
    ld [hl-], a
    add d
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    ld h, c
    add sp, -$02
    ld [bc], a
    ld sp, $5282
    ld [hl], $37
    call nz, $3938
    ld h, c
    add sp, -$02
    ld [bc], a
    ld [hl-], a
    add d
    ldh [c], a
    ld h, c
    add sp, -$02
    ld [bc], a
    ld sp, $9182
    add c
    ldh [c], a
    ld h, b
    add sp, -$02
    ld [bc], a
    ld [hl-], a
    ld a, a
    sub c
    add c
    ldh [c], a
    ld h, b
    add sp, -$02
    ld [bc], a
    ld sp, $917f
    add c
    ldh [c], a
    ld h, c
    add sp, -$02
    ld [bc], a
    ld [hl-], a
    ld a, a
    ldh [c], a
    ld h, c
    add sp, -$02
    ld [bc], a
    ld sp, $4c7f
    ld a, [hl-]
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    ld h, c
    add sp, -$02
    ld [bc], a
    ld [hl-], a
    ld a, a
    ld h, d
    ld [hl], $37
    ldh [c], a
    ld h, c
    add sp, -$02
    ld [bc], a
    ld sp, $c47f
    ld [hl], b
    ld [hl], d
    ld h, b
    add sp, -$02
    ld [bc], a
    ld [hl-], a
    ld a, a
    call nz, ProcessValidation_7371
    ld h, c
    add sp, -$02
    ld [bc], a
    ld sp, $617f
    add b
    and [hl]
    ld [hl], b
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld h, b
    add sp, -$02
    ld [bc], a
    ld [hl-], a
    ld a, a
    ld h, c
    add d
    and [hl]
    ld [hl], c
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld h, c
    add sp, -$02
    ld [bc], a
    ld sp, $b57f
    ld [hl], b
    ld [hl], d
    ld [hl], d
    ld h, b
    add sp, -$02
    ld [bc], a
    ld [hl-], a
    ld a, a
    or l
    ld [hl], c
    ld [hl], e
    ld [hl], e
    ld h, e
    ld h, h
    cp $04
    ld sp, $7f7f
    ld a, a
    ld d, d
    inc [hl]
    dec [hl]
    ldh [c], a
    ld h, l
    ld h, [hl]
    cp $00
    ld [hl-], a
    ld a, a
    ld a, a
    ld a, a
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    ld h, c
    add sp, -$02
    inc b
    ld sp, $7f7f
    ld a, a
    ld d, c
    scf
    ldh [c], a
    ld h, e
    ld h, h
    cp $04
    ld [hl-], a
    ld a, a
    ld a, a
    ld a, a
    call nz, $7270
    ld [hl], d
    ld [hl], d
    cp $04
    ld sp, $7f7f
    ld a, a
    call nz, ProcessValidation_7371
    ld [hl], e
    ld [hl], e
    cp $04
    ld [hl-], a
    ld a, a
    ld a, a
    ld a, a
    ldh [c], a
    ld h, l
    ld h, [hl]
    cp $08
    ld sp, $7f7f
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ldh [c], a
    ld h, c
    add sp, -$02
    inc c
    ld [hl-], a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld l, l
    ld l, l
    ld l, l
    ld l, l
    ld l, e
    ldh [c], a
    ld h, c
    add sp, -$02
    inc c
    ld sp, $7f7f
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, h
    ldh [c], a
    ld h, b
    add sp, -$02
    ld [$7f32], sp
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ldh [c], a
    ld h, b
    add sp, -$02
    ld [$7f31], sp
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ldh [c], a
    ld h, c
    add sp, -$02
    inc c
    ld [hl-], a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld l, l
    ld l, l
    ld l, l
    ld l, l
    ld l, e
    ldh [c], a
    ld h, c
    add sp, -$02
    inc c
    ld sp, $7f7f
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, h
    ldh [c], a
    ld h, c
    add sp, -$02
    dec bc
    ld [hl-], a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    add d
    ldh [c], a
    ld h, c
    add sp, -$02
    dec bc
    ld sp, $7f7f
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    add d
    ldh [c], a
    ld h, e
    ld h, h
    cp $0b
    ld [hl-], a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    add d
    ldh [c], a
    ld [hl], b
    ld [hl], d
    cp $0b
    ld sp, $7f7f
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    add d
    ldh [c], a
    ld [hl], c
    ld [hl], e
    cp $04
    ld [hl-], a
    ld a, a
    ld a, a
    ld a, a
    ld d, c
    dec [hl]
    and c
    add b
    ldh [c], a
    ld h, l
    ld h, [hl]
    cp $00
    ld sp, $7f7f
    ld a, a
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    ld h, c
    add sp, -$02
    inc b
    ld [hl-], a
    ld a, a
    ld a, a
    ld a, a
    ld d, d
    ld [hl], $37
    ldh [c], a
    ld h, e
    ld h, h
    cp $02
    ld sp, $fe49
    ld [bc], a
    ld [hl-], a
    ld c, c
    cp $02
    ld sp, $e249
    ld h, l
    ld h, [hl]
    cp $02
    ld [hl-], a
    ld c, c
    ld sp, $7235
    inc [hl]
    dec [hl]
    ldh [c], a
    ld h, c
    add sp, -$02
    nop
    ld sp, $3349
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    ld h, b
    add sp, -$02
    ld [bc], a
    ld [hl-], a
    ld c, c
    ld d, c
    scf
    call nz, $3938
    ld h, c
    add sp, -$02
    ld [bc], a
    ld sp, $a149
    add c
    ldh [c], a
    ld h, b
    add sp, -$02
    ld [bc], a
    ld [hl-], a
    ld c, c
    and c
    add c
    ldh [c], a
    ld h, c
    add sp, -$02
    ld [bc], a
    ld sp, wStackWRAM
    dec [hl]
    ldh [c], a
    ld h, b
    add sp, -$02
    ld [bc], a
    ld [hl-], a
    ld c, c
    dec a
    ld a, [hl-]
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    ld h, e
    ld h, h
    cp $02
    ld sp, $6249
    ld [hl], $37
    ldh [c], a
    ld [hl], b
    ld [hl], d
    cp $02
    ld [hl-], a
    ld c, c
    ldh [c], a
    ld [hl], c
    ld [hl], e
    cp $02
    ld sp, $e249
    ld h, l
    ld h, [hl]
    cp $02
    ld [hl-], a
    ld c, c
    ldh [c], a
    ld h, c
    add sp, -$02
    ld [bc], a
    ld sp, $a149
    add c
    ldh [c], a
    ld h, b
    add sp, -$02
    ld [bc], a
    ld [hl-], a
    ld c, c
    and c
    add c
    ldh [c], a
    ld h, c
    add sp, -$02
    ld [bc], a
    ld sp, $4149
    dec [hl]
    call nz, $3938
    ld h, b
    add sp, -$02
    nop
    ld [hl-], a
    ld c, c
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    ld h, b
    add sp, -$02
    inc b
    ld sp, $3649
    scf
    ldh [c], a
    ld h, c
    add sp, -$02
    ld [bc], a
    ld [hl-], a
    ld c, c
    ldh [c], a
    ld h, e
    ld h, h
    cp $02
    ld sp, $fe49
    ld [bc], a
    ld [hl-], a
    ld c, c
    ld sp, $b246
    inc [hl]
    dec [hl]
    cp $02
    ld sp, $3149
    ld b, a
    or l
    ld a, [hl-]
    inc sp
    inc sp
    inc sp
    inc sp
    cp $02
    ld [hl-], a
    ld c, c
    ld sp, $e148
    scf
    cp $02
    ld sp, $fe49
    ld [bc], a
    ld [hl-], a
    ld c, c
    cp $02
    ld sp, $4149
    dec [hl]
    add d
    inc [hl]
    dec [hl]
    cp $00
    ld [hl-], a
    ld c, c
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    cp $02
    ld sp, $6149
    scf
    sub d
    ld [hl], $37
    cp $02
    ld [hl-], a
    ld c, c
    and d
    ccf
    ld b, d
    cp $02
    ld sp, $9149
    dec a
    cp $02
    ld [hl-], a
    ld c, c
    sub e
    ld a, $40
    ld b, e
    cp $02
    ld sp, $9349
    ld b, [hl]
    ld b, c
    ld b, h
    cp $02
    ld [hl-], a
    ld c, c
    sub c
    ld b, a
    cp $02
    ld sp, $9149
    ld c, b
    cp $02
    ld [hl-], a
    ld c, c
    cp $02
    ld sp, $fe49
    ld [bc], a
    ld [hl-], a
    ld c, c
    or d
    inc [hl]
    dec [hl]
    cp $02
    ld sp, $6a49
    ld a, [hl-]
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    cp $02
    ld [hl-], a
    ld c, c
    add c
    scf
    cp $02
    ld sp, $fe49
    ld [bc], a
    ld [hl-], a
    ld c, c
    cp $02
    ld sp, $e249
    ld h, l
    ld h, [hl]
    cp $02
    ld [hl-], a
    ld c, c
    call nz, $3938
    ld h, c
    add sp, -$02
    inc b
    ld sp, $3449
    dec [hl]
    ld h, c
    dec [hl]
    ldh [c], a
    ld h, b
    add sp, -$02
    nop
    ld [hl-], a
    ld c, c
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    ld h, c
    add sp, -$02
    ld [bc], a
    ld sp, $3149
    scf
    ldh [c], a
    ld h, b
    add sp, -$02
    ld [bc], a
    ld [hl-], a
    ld c, c
    ldh [c], a
    ld h, c
    add sp, -$02
    ld [bc], a
    ld sp, $9149
    add d
    db $d3
    ld a, a
    ld h, b
    add sp, -$02
    ld [bc], a
    ld [hl-], a
    ld c, c
    ld d, c
    add c
    sub c
    add d
    db $d3
    ld a, a
    ld h, c
    add sp, -$02
    ld [bc], a
    ld sp, $9149
    add d
    db $d3
    ld a, a
    ld h, b
    add sp, -$02
    ld [bc], a
    ld [hl-], a
    ld c, c
    db $d3
    ld a, a
    ld h, c
    add sp, -$02
    ld [bc], a
    ld sp, $7949
    ld a, [hl-]
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    ld a, a
    ld h, b
    add sp, -$02
    ld [bc], a
    ld [hl-], a
    ld c, c
    add d
    ld [hl], $37
    db $d3
    ld a, a
    ld h, c
    add sp, -$02
    ld [bc], a
    ld sp, $5149
    dec [hl]
    db $d3
    ld a, a
    ld h, b
    add sp, -$02
    ld [bc], a
    ld [hl-], a
    ld c, c
    dec a
    ld a, [hl-]
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    ld a, a
    ld h, c
    add sp, -$02
    ld [bc], a
    ld sp, $4149
    scf
    or l
    jr c, CheckStateValue_69ff

    ld a, a
    ld h, b
    add sp, -$02
    ld [bc], a
    ld [hl-], a
    ld c, c
    db $d3
    ld a, a
    ld h, b
    add sp, -$02
    ld [bc], a
    ld sp, $d349
    ld a, a
    ld h, b
    add sp, -$02
    ld [bc], a
    ld [hl-], a
    ld c, c
    db $d3
    ld a, a
    ld h, e
    ld h, h
    cp $02
    ld sp, $fe49
    ld [bc], a
    ld [hl-], a
    ld c, c
    cp $02
    ld sp, $9249
    ccf
    ld b, d
    ldh [c], a
    ld [hl], b
    ld [hl], d
    cp $02
    ld [hl-], a
    ld c, c
    ld [hl], d
    ld b, [hl]
    dec a
    ldh [c], a
    ld [hl], c
    ld [hl], e

ValidatePlayerState_69fd:
    cp $02

CheckStateValue_69ff:
    ld sp, $7449
    ld b, a
    ld a, $40
    ld b, e
    ldh [c], a
    ld [hl], b
    ld [hl], d
    cp $02
    ld [hl-], a
    ld c, c
    ld [hl], c
    ld c, b
    sub d
    ld b, c
    ld b, h
    ldh [c], a
    ld [hl], c
    ld [hl], e
    cp $02
    ld sp, $8249
    ccf
    ld b, d
    ldh [c], a
    ld [hl], b
    ld [hl], d
    cp $02
    ld [hl-], a
    ld c, c
    ld [hl], c
    dec a
    ldh [c], a
    ld [hl], c
    ld [hl], e
    cp $02
    ld sp, $6449
    ld b, [hl]
    ld a, $45
    ld b, e
    call nz, $7270
    ld [hl], d
    ld [hl], d
    cp $02
    ld [hl-], a
    ld c, c
    ld h, c
    ld b, a
    call nz, ProcessValidation_7371
    ld [hl], e
    ld [hl], e
    cp $02
    ld sp, $6149
    ld c, b
    cp $02
    ld [hl-], a
    ld c, c
    and [hl]
    ld [hl], b
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    cp $02
    ld sp, $a649
    ld [hl], c
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    cp $02
    ld [hl-], a
    ld c, c
    and [hl]
    ld [hl], b
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    cp $02
    ld sp, $a649
    ld [hl], c
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    cp $02
    ld [hl-], a
    ld c, c
    adc b
    ld [hl], b
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    cp $02
    ld sp, $8849
    ld [hl], c
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    cp $02
    ld [hl-], a
    ld c, c
    cp $02
    ld sp, $e249
    ld [hl], b
    ld [hl], d
    cp $02
    ld [hl-], a
    ld c, c
    ldh [c], a
    ld [hl], c
    ld [hl], e
    cp $02
    ld sp, $fe49
    ld [bc], a
    ld [hl-], a
    ld c, c
    cp $02
    ld sp, $fe49
    inc bc
    ld [hl-], a
    ld c, c
    ld e, a
    ld b, c
    db $f4
    ld h, c
    db $f4
    add c
    db $f4
    and c
    db $f4
    pop bc
    db $f4
    cp $06
    ld sp, $7f49
    ld a, a
    ld a, a
    ld a, a
    and l
    db $fd
    ld a, a
    cp $02
    ld [hl-], a
    ld c, c
    ld d, c
    ld a, a
    and c
    ld a, a
    cp $06
    ld sp, $f449
    db $f4
    db $f4
    ld a, a
    and c
    ld a, a
    cp $06
    ld [hl-], a
    ld c, c
    db $f4
    db $f4
    db $f4
    ld a, a
    and c
    ld a, a
    cp $06
    ld sp, $f449
    db $f4
    db $f4
    ld a, a
    and c
    ld a, a
    cp $06
    ld [hl-], a
    ld c, c
    db $f4
    db $f4
    db $f4
    ld a, a
    and c
    ld a, a
    cp $06
    ld sp, $f449
    db $f4
    db $f4
    ld a, a

CheckPlayerAction_6afd:
    and c
    ld a, a
    jp nc, PaddingAlign_423f

    cp $02
    ld [hl-], a
    ld c, c
    and c
    ld a, a
    pop bc
    dec a
    cp $02
    ld sp, $c349
    ld a, $40
    ld b, e
    cp $02
    ld [hl-], a
    ld c, c
    add c
    ld a, a
    jp PaddingTrap_4146


    ld b, h
    cp $02
    ld sp, $8149
    ld a, a
    pop bc
    ld b, a
    cp $02
    ld [hl-], a
    ld c, c
    add c
    ld a, a
    or d
    ccf
    ld c, b
    cp $02
    ld sp, $8149
    ld a, a
    and c
    dec a
    cp $02
    ld [hl-], a
    ld c, c
    add c
    ld a, a
    and h
    ld a, $45
    ld b, h
    ld b, [hl]
    cp $02
    ld sp, $8149
    ld a, a
    pop de
    ld b, a
    cp $02
    ld [hl-], a
    ld c, c
    add c
    ld a, a
    pop de
    ld c, b
    cp $02
    ld sp, $fe49
    ld [bc], a
    ld [hl-], a
    ld c, c
    ld b, c
    dec [hl]
    add d
    inc [hl]
    dec [hl]
    cp $00
    ld sp, $3349
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    cp $04
    ld [hl-], a
    ld c, c
    ld [hl], $37
    ld [hl], c
    scf
    cp $02
    ld sp, $e249
    db $fd
    ld a, a
    cp $02
    ld [hl-], a
    ld c, c
    sub a
    ld a, [hl-]
    inc sp
    inc sp
    inc sp
    inc sp
    ld a, a
    ld a, a
    cp $02
    ld sp, $b149
    scf
    ldh [c], a
    db $fd
    ld a, a
    cp $02
    ld [hl-], a
    ld c, c
    ldh [c], a
    ld [hl], b
    ld [hl], d
    cp $02
    ld sp, $9249
    ccf
    ld b, d
    ldh [c], a
    ld [hl], c
    ld [hl], e
    cp $02
    ld [hl-], a
    ld c, c
    add c
    dec a
    ldh [c], a
    ld [hl], b
    ld [hl], d
    cp $02
    ld sp, $8349
    ld a, $40
    ld b, e
    ldh [c], a
    ld [hl], c
    ld [hl], e
    cp $02
    ld [hl-], a
    ld c, c
    add e
    ld b, [hl]
    ld b, c
    ld b, h
    ldh [c], a
    ld [hl], b
    ld [hl], d
    cp $02
    ld sp, $8149
    ld b, a
    ldh [c], a
    ld [hl], c
    ld [hl], e
    cp $02
    ld [hl-], a
    ld c, c
    add c
    ld c, b
    call nz, $7270
    ld [hl], d
    ld [hl], d
    cp $02
    ld sp, $c449
    ld [hl], c
    ld [hl], e
    ld [hl], e
    ld [hl], e
    cp $02
    ld [hl-], a
    ld c, c
    sub a
    ld [hl], b
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    cp $02
    ld sp, $9749
    ld [hl], c
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    cp $02
    ld [hl-], a
    ld c, c
    ld l, d
    ld [hl], b
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    cp $02
    ld sp, $6a49
    ld [hl], c
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    cp $02
    ld [hl-], a
    ld c, c
    cp $f1
    adc [hl]
    cp $f1
    adc a
    cp $f1
    adc [hl]
    cp $f1
    adc a
    cp $f1
    adc [hl]
    cp $f1
    adc a
    cp $f1
    adc [hl]
    cp $21
    ld a, a
    pop af
    adc a
    cp $f1
    adc [hl]
    cp $21
    ld a, a
    pop af
    adc a
    cp $f1
    adc [hl]
    cp $21
    ld a, a
    pop af
    adc a
    cp $f1
    adc [hl]
    cp $21
    ld a, a
    pop af
    adc a
    cp $f1
    adc [hl]
    cp $21
    ld a, a
    pop af
    adc a
    cp $f1
    adc [hl]
    cp $21
    adc [hl]
    pop af
    adc a
    cp $00
    inc de
    inc h
    adc a
    adc [hl]
    adc [hl]
    adc [hl]
    adc [hl]
    adc [hl]
    adc [hl]
    adc [hl]
    adc [hl]
    adc [hl]
    adc [hl]
    inc de
    inc h
    adc [hl]
    cp $00
    ld hl, $8e51
    adc a
    adc a
    adc a
    adc a
    adc a
    adc a
    adc a
    adc a
    adc a
    adc a
    ld hl, $8f51
    cp $00
    db $fd
    ld a, a
    cp $00
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    cp $00
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    cp $00
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    cp $00
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    cp $00
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    cp $00
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    cp $00
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    cp $00
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    cp $00
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    cp $00
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    cp $00
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    cp $00
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    cp $00
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    cp $00
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    cp $00
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    cp $00
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    cp $00
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    ld [hl], h
    ld [hl], a
    ld a, a
    cp $00
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    ld [hl], l
    ld a, b
    ld a, a
    cp $00
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    halt
    ld a, c
    ld a, a
    cp $00
    db $fd
    ld a, a
    cp $f1
    ld a, a
    cp $f1
    ld a, a
    cp $01
    ld a, a
    pop af
    ld a, a
    cp $01
    ld a, a
    add l
    db $fd
    ld a, a
    pop af
    ld a, a
    cp $01
    ld a, a
    add l
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    pop af
    ld a, a
    cp $01
    ld a, a
    add l
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    pop af
    ld a, a
    cp $01
    ld a, a
    add l
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    pop af
    ld a, a
    cp $01
    ld a, a
    add l
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    pop af
    ld a, a
    cp $01
    ld a, a
    add l
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    pop af
    ld a, a
    cp $01
    ld a, a
    add l
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    pop af
    ld a, a
    cp $01
    ld a, a
    add l
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    pop af
    ld a, a
    cp $0d
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    pop af
    ld a, a
    cp $01
    ld a, a
    halt
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    pop af
    ld a, a
    cp $01
    ld a, a
    halt
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    pop af
    ld a, a
    cp $01
    ld a, a
    ld sp, $767f
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    pop af
    ld a, a
    cp $01
    ld a, a
    ld sp, $767f
    db $fd
    ld a, a
    pop af
    ld a, a
    cp $04
    ld a, a
    ld [hl], h
    ld [hl], a
    ld a, a
    ld [hl], c
    ld a, a
    pop af
    ld a, a
    cp $04
    ld a, a
    ld [hl], l
    ld a, b
    ld a, a
    or c
    ld a, a
    pop af
    ld a, a
    cp $00
    ld [hl], d
    halt
    ld a, c
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    cp $02
    ld sp, $c249
    ccf
    ld b, d
    pop af
    ld e, l
    cp $02
    ld [hl-], a
    ld c, c
    add c
    ld b, [hl]
    or c
    dec a
    pop af
    ld e, l
    cp $02
    ld sp, $8149
    ld b, a
    or l
    ld a, $40
    ld [hl], b
    ld [hl], d
    ld h, a
    cp $02
    ld [hl-], a
    ld c, c
    add e
    ld c, b
    ccf
    ld b, d
    call nz, $7141
    ld [hl], e
    ld h, a
    cp $02
    ld sp, $8149
    dec a
    pop bc
    ld c, d
    ldh [c], a
    db $fd
    ld h, a
    cp $02
    ld [hl-], a
    ld c, c
    add d
    ld a, $45
    or c
    dec a
    ldh [c], a
    db $fd
    ld h, a
    cp $02
    ld sp, $b249
    ld a, $45
    ldh [c], a
    db $fd
    ld h, a
    cp $02
    ld [hl-], a
    ld c, c
    ldh [c], a
    db $fd
    ld h, a
    cp $02
    ld sp, $f149
    ld e, l
    cp $02
    ld [hl-], a
    ld c, c
    pop af
    ld e, l
    cp $02
    ld sp, wStackWRAM
    ld l, b
    pop af
    ld e, l
    cp $02
    ld [hl-], a
    ld c, c
    pop bc
    ld l, b
    pop af
    ld e, l
    cp $02
    ld sp, $c449
    ld l, b
    ld c, d
    ld b, d
    ld e, l
    cp $02
    ld [hl-], a
    ld c, c
    or d
    ccf
    ld b, d
    pop af
    ld e, l
    cp $02
    ld sp, $a149
    dec a
    pop af
    ld e, l
    cp $02
    ld [hl-], a
    ld c, c
    and h
    ld a, $45
    ld b, e
    ld c, d
    pop af
    ld e, l
    cp $02
    ld sp, $a149
    ld l, b
    pop bc
    dec a
    pop af
    ld e, l
    cp $02
    ld [hl-], a
    ld c, c
    and c
    ld l, b
    jp nz, DataPadding_453e

    pop af
    ld e, l
    cp $02
    ld sp, $a149
    ld l, b
    pop af
    ld e, l
    cp $02
    ld [hl-], a
    ld c, c
    and c
    ld l, b
    pop af
    ld e, l
    cp $02
    ld sp, $e249
    db $fd
    ld h, a
    cp $02
    ld [hl-], a
    ld c, c
    ld sp, $8146
    ld h, a
    call nz, ValidateOrTransformValue
    ld h, a
    ld h, a
    cp $02
    ld sp, $3149
    ld b, a
    add c
    ld h, a
    or c
    dec a
    ldh [c], a
    db $fd
    ld h, a
    cp $02
    ld [hl-], a
    ld c, c
    ld sp, $8148
    ld h, a
    or l
    ld a, $40
    ld b, d
    ld h, a
    ld h, a
    cp $02
    ld sp, $8149
    ld h, a
    or l
    ld b, [hl]
    ld b, c
    ld b, e
    ld h, a
    ld h, a
    cp $02
    ld [hl-], a
    ld c, c
    add c
    ld h, a
    or c
    ld b, a
    ldh [c], a
    db $fd
    ld h, a
    cp $02
    ld sp, $b149
    ld c, b
    ldh [c], a
    db $fd
    ld h, a
    cp $02
    ld [hl-], a
    ld c, c
    db $d3
    ld c, l
    ld h, a
    ld h, a
    cp $02
    ld sp, $b549
    ld h, a
    ld c, e
    ld c, [hl]
    ld h, a
    ld h, a
    cp $02
    ld [hl-], a
    ld c, c
    ld [hl], c
    add c
    or l
    ld h, a
    ld c, h
    ld c, a
    ld h, a
    ld h, a
    cp $02
    ld sp, $7149
    add c
    or c
    ld h, a
    ldh [c], a
    db $fd
    ld h, a
    cp $02
    ld [hl-], a
    ld c, c
    or c
    ld h, a
    ldh [c], a
    db $fd
    ld h, a
    cp $02
    ld sp, $a249
    ccf
    ld b, d
    ldh [c], a
    db $fd
    ld h, a
    cp $02
    ld [hl-], a
    ld c, c
    add d
    ld h, a
    dec a
    db $d3
    ccf
    ld h, a
    ld h, a
    cp $02
    ld sp, $8549
    ld h, a
    ld a, $45
    ld b, e
    dec a
    ldh [c], a
    db $fd
    ld h, a
    cp $02
    ld [hl-], a
    ld c, c
    add c
    ld h, a
    call nz, HandlePaletteLookup
    ld h, a
    ld h, a
    cp $02
    ld sp, $5149
    ld b, [hl]
    add c
    ld h, a
    or l
    ccf
    ld b, d
    ld b, c
    ld h, a
    ld h, a
    cp $02
    ld [hl-], a
    ld c, c
    ld d, c
    ld b, a
    and c
    dec a
    ldh [c], a
    db $fd
    ld h, a
    cp $02
    ld sp, $5149
    ld c, b
    and d
    ld a, $45
    pop af
    ld e, l
    cp $02
    ld [hl-], a
    ld c, c
    pop af
    ld e, l
    cp $02
    ld sp, $a667
    db $fd
    ld h, a
    cp $08
    ld [hl-], a
    ld h, a
    ld h, a
    ld h, a
    add d
    add d
    add d
    add d
    and [hl]
    db $fd
    ld h, a
    cp $02
    ld sp, $7167
    ld h, a
    pop af
    ld h, a
    cp $02
    ld [hl-], a
    ld h, a
    ld [hl], c
    ld h, a
    pop af
    ld h, a
    cp $02
    ld sp, $7267
    db $fd
    ld h, a
    pop af
    ld h, a
    cp $02
    ld [hl-], a
    ld h, a
    ld b, c
    add d
    halt
    db $f4
    ld h, a
    ld l, l
    ld l, l
    ld l, l
    ld l, e
    pop af
    ld h, a
    cp $02
    ld sp, $4167
    add c
    add l
    ld h, a
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, h
    pop af
    ld h, a
    cp $02
    ld [hl-], a
    ld h, a
    ld b, c
    add b
    ld [hl], d
    db $f4
    ld h, a
    pop af
    ld h, a
    cp $02
    ld sp, $4167
    add c
    add c
    ld h, a
    db $d3
    ld [hl], b
    ld [hl], d
    ld h, a
    cp $02
    ld [hl-], a
    ld h, a
    ld b, c
    add d
    ld [hl], d
    db $f4
    ld h, a
    db $d3
    ld [hl], c
    ld [hl], e
    ld h, a
    cp $02
    ld sp, $4167
    add c
    add c
    ld h, a
    pop af
    ld h, a
    cp $02
    ld [hl-], a
    ld h, a
    ld b, c
    add b
    halt
    db $f4
    ld h, a
    ld l, l
    ld l, l
    ld l, l
    ld l, e
    pop af
    ld h, a
    cp $02
    ld sp, $4167
    add c
    add l
    ld h, a
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, h
    pop af
    ld h, a
    cp $02
    ld [hl-], a
    ld h, a
    ld b, c
    add d
    ld [hl], d
    db $f4
    ld h, a
    pop af
    ld h, a
    cp $02
    ld sp, $4167
    add c
    add c
    ld h, a
    db $d3
    ld [hl], b
    ld l, l
    ld h, a
    cp $02
    ld [hl-], a
    ld h, a
    ld b, c
    add d
    ld [hl], d
    db $f4
    ld h, a
    db $d3
    ld [hl], c
    ld l, [hl]
    ld h, a
    cp $02
    ld sp, $4167
    add c
    add c
    ld h, a
    ldh [c], a
    db $fd
    ld h, a
    cp $02
    ld [hl-], a
    ld h, a
    ld b, c
    add d
    ld [hl], l
    ld h, a
    ld h, a
    ld l, l
    ld l, l
    ld l, e
    ldh [c], a
    db $fd
    ld h, a
    cp $02
    ld sp, $4167
    add c
    ld [hl], l
    ld h, a
    ld h, a
    ld l, [hl]
    ld l, [hl]
    ld l, h
    ldh [c], a
    db $fd
    ld h, a
    cp $02
    ld [hl-], a
    ld h, a
    ld b, c
    add d
    ldh [c], a
    db $fd
    ld h, a
    cp $05
    ld sp, $697f
    ld a, a
    ld l, c
    ldh [c], a
    ld l, c
    ld a, a
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ldh [c], a
    ld l, d
    ld l, c
    cp $05
    ld sp, $696a
    ld l, d
    ld l, c
    ldh [c], a
    ld l, c
    ld l, d
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    db $d3
    ld l, a
    ld l, d
    ld l, c
    cp $05
    ld sp, $696a
    ld l, d
    ld l, c
    ldh [c], a
    ld l, c
    ld l, d
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ldh [c], a
    ld l, d
    ld l, c
    cp $05
    ld sp, $696a
    ld l, d
    ld l, c
    call nz, $7270
    ld l, c
    ld l, d
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    call nz, ProcessValidation_7371
    ld l, d
    ld l, c
    cp $05
    ld sp, $696a
    ld l, d
    ld l, c
    sub a
    ld [hl], b
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld l, c
    ld l, d
    cp $06
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, a
    sub a
    ld [hl], c
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld l, d
    ld l, c
    cp $05
    ld sp, $696a
    ld l, d
    ld l, c
    ldh [c], a
    ld l, c
    ld l, d
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ldh [c], a
    ld l, d
    ld l, c
    cp $05
    ld sp, $696a
    ld l, d
    ld l, c
    ldh [c], a
    ld l, c
    ld l, d
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ldh [c], a
    ld l, d
    ld l, c
    cp $05
    ld sp, $696a
    ld l, d
    ld l, c
    ldh [c], a
    ld l, c
    ld l, d
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    db $d3
    ld l, a
    ld l, d
    ld l, c
    cp $05
    ld sp, $696a
    ld l, d
    ld l, c
    ldh [c], a
    ld l, c
    ld l, d
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ldh [c], a
    ld l, d
    ld l, c
    cp $05
    ld sp, $696a
    ld l, d
    ld l, c
    ldh [c], a
    ld l, c
    ld l, d
    cp $05
    ld [hl-], a
    ld a, a
    ld l, d
    ld a, a
    ld l, d
    ldh [c], a
    ld l, d
    ld a, a
    cp $05
    ld sp, $697f
    ld a, a
    ld l, c
    pop af
    ld e, l
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    pop af
    ld e, l
    cp $04
    ld sp, $696a
    ld l, d
    ldh [c], a
    ld l, c
    ld e, l
    cp $04
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ldh [c], a
    ld l, d
    ld l, c
    cp $04
    ld sp, $696a
    ld l, d
    ldh [c], a
    ld l, c
    ld l, d
    cp $04
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    and c
    add c
    ldh [c], a
    ld l, d
    ld l, c
    cp $04
    ld sp, $696a
    ld l, d
    ldh [c], a
    ld l, c
    ld l, d
    cp $04
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ldh [c], a
    ld l, d
    ld l, c
    cp $05
    ld sp, $696a
    ld l, d
    ld l, c
    ldh [c], a
    ld l, c
    ld l, d
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ldh [c], a
    ld l, d
    ld l, c
    cp $05
    ld sp, $696a
    ld l, d
    ld l, c
    ldh [c], a
    ld l, c
    ld l, d
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ldh [c], a
    ld l, d
    ld l, c
    cp $04
    ld sp, $696a
    ld l, d
    ldh [c], a
    ld l, c
    ld l, d
    cp $04
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    or c
    ld l, a
    ldh [c], a
    ld l, d
    ld l, c
    cp $04
    ld sp, $696a
    ld l, d
    ldh [c], a
    ld l, c
    ld l, d
    cp $04
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ldh [c], a
    ld l, d
    ld l, c
    cp $05
    ld sp, $696a
    ld l, d
    ld l, c
    ldh [c], a
    ld l, c
    ld l, d
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ldh [c], a
    ld l, d
    ld l, c
    cp $05
    ld sp, $696a
    ld l, d
    ld l, c
    ldh [c], a
    ld l, c
    ld l, d
    cp $05
    ld [hl-], a
    ld a, a
    ld l, d
    ld a, a
    ld l, d
    ldh [c], a
    ld l, d
    ld a, a
    cp $05
    ld sp, $697f
    ld a, a
    ld l, c
    pop de
    ld a, a
    pop af
    ld e, l
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    pop de
    ld a, a
    pop af
    ld e, l
    cp $05
    ld sp, $696a
    ld l, d
    ld l, c
    pop de
    ld l, a
    pop af
    ld e, l
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    pop de
    ld a, a
    pop af
    ld e, l
    cp $05
    ld sp, $696a
    ld l, d
    ld l, c
    pop af
    ld e, l
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    pop af
    ld e, l
    cp $05
    ld sp, $696a
    ld l, d
    ld l, c
    pop af
    ld e, l
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    pop af
    ld e, l
    cp $05
    ld sp, $696a
    ld l, d
    ld l, c
    pop af
    ld e, l
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    pop af
    ld e, l
    cp $05
    ld sp, $696a
    ld l, d
    ld l, c
    pop af
    ld e, l
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    pop af
    ld e, l
    cp $05
    ld sp, $696a
    ld l, d
    ld l, c
    pop af
    ld e, l
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    pop af
    ld e, l
    cp $05
    ld sp, $696a
    ld l, d
    ld l, c
    pop af
    ld e, l
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    pop af
    ld e, l
    cp $06

ValidationData_7355:
    ld sp, $696a
    ld l, d
    ld l, c
    ld l, a
    pop af
    ld e, l
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    pop af
    ld e, l
    cp $05
    ld sp, $696a
    ld l, d
    ld l, c
    pop af
    ld e, l
    cp $05

ProcessValidation_7371:
    ld [hl-], a
    ld a, a
    ld l, d
    ld a, a
    ld l, d
    pop af
    ld e, l
    cp $05
    ld sp, $697f
    ld a, a
    ld l, c
    ld [hl], c
    ld e, a
    call nz, ValidatePlayerState_69fd
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    call nz, CheckPlayerAction_6afd
    cp $05
    ld sp, $696a
    ld l, d
    ld l, c
    pop af
    ld e, l
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    pop af
    ld e, l
    cp $05
    ld sp, $696a
    ld l, d
    ld l, c
    ldh [c], a
    db $fd
    ld l, c
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ldh [c], a
    db $fd
    ld l, d
    cp $05
    ld sp, $696a
    ld l, d
    ld l, c
    ldh [c], a
    db $fd
    ld l, c
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ldh [c], a
    db $fd
    ld l, d
    cp $05
    ld sp, $696a
    ld l, d
    ld l, c
    ldh [c], a
    db $fd
    ld l, c
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ldh [c], a
    db $fd
    ld l, d
    cp $05
    ld sp, $696a
    ld l, d
    ld l, c
    ld [hl], c
    db $f4
    or l
    db $fd
    ld l, c
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld [hl], c
    db $f4
    or l
    db $fd

DataLoopHelper2:
    ld l, d
    cp $05
    ld sp, $696a
    ld l, d
    ld l, c
    pop af
    ld e, l
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    pop af
    ld e, l
    cp $05
    ld sp, $696a
    ld l, d
    ld l, c
    pop af
    ld e, l
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    call nz, ValidatePlayerState_69fd
    cp $06
    ld sp, $696a
    ld l, d
    ld l, c
    ld l, a
    call nz, CheckPlayerAction_6afd
    cp $05
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    sub a
    db $fd
    ld l, c
    cp $05
    ld sp, $696a
    ld l, d
    ld l, c
    sub a
    db $fd
    ld l, d
    cp $05
    ld [hl-], a
    ld a, a
    ld l, d
    ld a, a
    ld l, d
    pop af
    ld e, l
    cp $0b
    ld sp, $697f
    ld a, a
    ld l, c
    ld a, a
    ld l, c
    ld a, a
    ld l, c
    ld a, a
    ld l, c
    ldh [c], a
    db $fd
    ld l, c
    cp $0b
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ldh [c], a
    db $fd
    ld l, d
    cp $0b
    ld sp, $696a
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ldh [c], a
    db $fd
    ld l, c
    cp $0b
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ldh [c], a
    db $fd
    ld l, d
    cp $0b
    ld sp, $696a
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ldh [c], a
    db $fd
    ld l, c
    cp $0b
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ldh [c], a
    db $fd
    ld l, d
    cp $0b
    ld sp, $696a
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    pop af
    ld e, l
    cp $0b
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ldh [c], a
    ld a, a
    ld e, l
    cp $0b
    ld sp, $696a
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    pop af
    ld e, l
    cp $0b
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ldh [c], a
    ld a, a
    ld e, l
    cp $0b
    ld sp, $696a
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    pop af
    ld e, l
    cp $0b
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ldh [c], a
    ld a, a
    ld e, l
    cp $0b
    ld sp, $696a
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    pop af
    ld e, l
    cp $0b
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ldh [c], a
    ld a, a
    ld e, l
    cp $0b
    ld sp, $696a
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    pop af
    ld e, l
    cp $0b
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ldh [c], a
    ld a, a
    ld e, l
    cp $0b
    ld sp, $696a
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    pop af
    ld e, l
    cp $0b
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c

ConfigData_7555:
    ld l, d
    ld l, c
    ld l, d
    ldh [c], a
    ld l, c
    ld e, l
    cp $0b
    ld sp, $696a
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ldh [c], a
    ld l, d
    ld l, c
    cp $0b
    ld [hl-], a
    ld a, a
    ld l, d
    ld a, a
    ld l, d
    ld a, a
    ld l, d
    ld a, a
    ld l, d
    ld a, a
    ld l, d
    ldh [c], a
    ld l, c
    ld l, d
    cp $0b
    ld sp, $697f
    ld a, a
    ld l, c
    ld a, a
    ld l, c
    ld a, a
    ld l, c
    ld a, a
    ld l, c
    ldh [c], a
    ld l, d
    ld l, c
    cp $0b
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ldh [c], a
    ld l, c
    ld l, d
    cp $0c
    ld sp, $696a
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, l
    ld l, e
    ldh [c], a
    ld l, d
    ld l, c
    cp $0c
    ld [hl-], a
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, d
    ld l, c
    ld l, [hl]
    ld l, h
    ldh [c], a
    ld l, c
    ld l, d
    cp $0b
    ld sp, $7f6a
    ld l, d
    ld a, a
    ld l, d
    ld a, a
    ld l, d
    ld a, a
    ld l, d
    ld a, a
    ldh [c], a
    ld l, d
    ld l, c
    cp $02
    ld [hl-], a
    ld l, c
    ldh [c], a
    ld a, a
    ld l, d
    cp $02
    ld sp, $f16a
    ld e, l
    cp $02
    ld [hl-], a
    ld l, c
    pop af
    ld e, l
    cp $02
    ld sp, $416a
    ld l, c
    pop af
    ld e, l
    cp $02
    ld [hl-], a
    ld l, c
    ld b, c
    ld l, d
    pop af
    ld e, l
    cp $02
    ld sp, $416a
    ld l, c
    pop af
    ld e, l
    cp $02
    ld [hl-], a
    ld l, c
    ld b, c
    ld l, d
    pop af
    ld e, l
    cp $02
    ld sp, $416a
    ld l, c
    pop af
    ld e, l
    cp $02
    ld [hl-], a
    ld l, c
    ld b, c
    ld l, d
    pop af
    ld e, l
    cp $02
    ld sp, $416a
    ld l, c
    pop af
    ld e, l
    cp $02
    ld [hl-], a
    ld l, c
    ld c, h
    ld l, d
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    cp $02
    ld sp, $fe6a
    dec bc
    ld [hl-], a
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    cp $0b
    ld sp, $6a6a
    ld l, d
    ld l, d
    ld l, d
    ld l, d
    ld l, d
    ld l, d
    ld l, d
    ld l, d
    pop af
    ld l, c
    cp $01
    ld [hl-], a
    pop af
    ld l, d
    cp $02
    ld d, d
    ld d, [hl]
    pop af
    ld d, d
    cp $02
    ld d, e
    ld d, a
    pop af
    ld d, e
    cp $03
    ld d, h
    ld d, d
    ld d, [hl]
    db $d3
    ld d, d
    ld d, [hl]
    ld d, h
    cp $03
    ld d, l
    ld d, e
    ld d, a
    db $d3
    ld d, e
    ld d, a
    ld d, l
    cp $12
    ld d, l
    ld e, c
    ld b, d
    ld d, d
    ld d, [hl]
    jp nc, $5854

    cp $02
    ld d, d
    ld d, [hl]
    ld b, d
    ld d, l
    ld e, c
    db $d3
    ld d, l
    ld e, c
    ld d, d
    cp $02
    ld d, e
    ld d, a
    pop af
    ld d, e
    cp $02
    ld d, h
    ld e, b
    pop af
    ld d, h
    cp $02
    ld d, l
    ld e, c
    ldh [c], a
    ld d, d
    ld d, l
    cp $e2
    ld d, e
    ld d, a
    cp $12
    ld d, d
    ld d, [hl]
    ldh [c], a
    ld d, l
    ld e, c
    cp $12
    ld d, h
    ld e, b
    cp $03
    ld d, d
    ld d, l
    ld e, c
    jp nz, DataZone_5652

    cp $02
    ld d, e
    ld d, a
    jp nz, $5955

    cp $02
    ld d, h
    ld e, b
    ld sp, $f180
    ld d, d
    cp $02
    ld d, l
    ld e, c
    pop af
    ld d, e
    cp $12
    ld d, d
    ld d, [hl]
    pop af
    ld d, h
    cp $12
    ld d, h
    ld e, b
    pop af
    ld d, l
    cp $12
    ld d, l
    ld e, c
    cp $fe
    cp $12
    ld d, d
    ld d, [hl]
    cp $12
    ld d, h
    ld d, a
    add d
    add b
    add d
    pop af
    ld d, d
    cp $03
    ld d, d
    ld d, l
    ld e, c
    ld b, c
    db $f4
    pop af
    ld d, h
    cp $02
    ld d, e
    ld d, a
    pop af
    ld d, l
    cp $02
    ld d, h
    ld e, b
    ld b, c
    db $f4
    jp nz, DataZone_5652

    cp $02
    ld d, l
    ld e, c
    call nz, $5955
    ld d, d
    ld d, [hl]
    cp $e2
    ld d, e
    ld d, a
    cp $12
    ld d, d
    ld d, [hl]
    ldh [c], a
    ld d, h
    ld e, b
    cp $12
    ld d, l
    ld e, c
    or c
    db $f4
    ldh [c], a
    ld d, l
    ld e, c
    cp $32
    add d
    add b
    cp $b1
    db $f4
    ldh [c], a
    ld d, d
    ld d, [hl]
    cp $02
    ld d, d
    ld d, [hl]
    ldh [c], a
    ld d, e
    ld d, a
    cp $02
    ld d, e
    ld d, a
    ldh [c], a
    ld d, l
    ld d, d
    cp $03
    ld d, l
    ld d, d
    ld d, [hl]
    pop af
    ld d, e
    cp $12
    ld d, e
    ld d, a
    or d
    db $fd
    add d
    pop af
    ld d, h
    cp $12
    ld d, h
    ld e, b
    ld b, d
    ld d, d
    ld d, [hl]
    pop af
    ld d, l
    cp $12
    ld d, l
    ld e, c
    ld b, d
    ld d, l
    ld e, c
    ldh [c], a
    ld d, d
    ld d, [hl]
    cp $81
    db $f4
    ldh [c], a
    ld d, h
    ld d, a
    cp $e2
    ld d, l
    ld e, c
    cp $05
    db $fd
    ld l, a
    or l
    db $fd
    ld l, a
    cp $b1
    ld l, a
    cp $02
    ld d, d
    ld d, [hl]
    or c
    ld l, a
    cp $02
    ld d, e
    ld d, a
    or c
    ld l, a
    pop af
    ld d, d
    cp $03
    ld d, h
    ld e, b
    ld d, [hl]
    or c
    ld l, a
    pop af
    ld d, e
    cp $03
    ld d, l
    ld e, c
    ld d, a
    or c
    ld l, a
    pop af
    ld d, h
    cp $12
    ld d, l
    ld e, c
    ld h, [hl]
    db $fd
    ld l, a
    pop af
    ld d, l
    cp $fe
    cp $fe
    ldh [c], a
    ld d, d
    ld d, [hl]
    cp $02
    ld d, d
    ld d, [hl]
    ldh [c], a
    ld d, l
    ld e, c
    cp $02
    ld d, e
    ld d, a
    cp $08
    db $fd
    ld l, a
    cp $02
    ld d, l
    ld e, c
    cp $e2
    ld d, d
    ld d, [hl]
    cp $d3
    ld d, d
    ld d, e
    ld d, a
    cp $d3
    ld d, e
    ld d, l
    ld e, c
    cp $d2
    ld d, h
    ld e, b
    cp $d2
    ld d, l
    ld e, c
    cp $07
    db $fd
    ld l, a
    and [hl]
    db $fd
    ld l, a
    cp $03
    dec sp
    ld e, e
    ld l, a
    ld b, c
    db $f4
    ld h, c
    db $f4
    add c
    db $f4
    and c
    db $f4
    pop bc
    db $f4
    ldh [c], a
    ld l, a
    dec sp
    cp $04
    dec sp
    ld e, e
    ld l, a
    db $f4
    ld d, c
    db $f4
    ld [hl], c
    db $f4
    sub c
    db $f4
    or c
    db $f4
    db $d3
    db $f4
    ld l, a
    dec sp
    cp $03
    dec sp
    ld e, e
    ld l, a
    ld b, c
    db $f4
    ld h, c
    db $f4
    add c
    db $f4
    and c
    db $f4
    pop bc
    db $f4
    ldh [c], a
    ld l, a
    dec sp
    cp $04
    dec sp
    ld e, e
    ld l, a
    db $f4
    ld d, c
    db $f4
    ld [hl], c
    db $f4
    sub c
    db $f4
    or c
    db $f4
    db $d3
    db $f4
    ld l, a
    dec sp
    cp $03
    dec sp
    ld e, e
    ld l, a
    ld b, c
    db $f4
    ld h, c
    db $f4
    add c
    db $f4
    and c
    db $f4
    pop bc
    db $f4
    ldh [c], a
    ld l, a
    dec sp
    cp $04
    dec sp
    ld e, e
    ld l, a
    db $f4
    ld d, c
    db $f4
    ld [hl], c
    db $f4
    sub c
    db $f4
    or c
    db $f4
    db $d3
    db $f4
    ld l, a
    dec sp
    cp $03
    dec sp
    ld e, e
    ld l, a
    ld b, c
    db $f4
    ld h, c
    db $f4
    add c
    db $f4
    and c
    db $f4
    pop bc
    db $f4
    ldh [c], a
    ld l, a
    dec sp
    cp $04
    dec sp
    ld e, e
    ld l, a
    db $f4
    ld d, c
    db $f4
    ld [hl], c
    db $f4
    sub c
    db $f4
    or c
    db $f4
    db $d3
    db $f4
    ld l, a
    dec sp
    cp $03
    dec sp
    ld e, e
    ld l, a
    ld b, c
    db $f4
    ld h, c
    db $f4
    add c
    db $f4
    and c
    db $f4
    pop bc
    db $f4
    ldh [c], a
    ld l, a
    dec sp
    cp $04
    dec sp
    ld e, e
    ld l, a
    db $f4
    ld d, c
    db $f4
    ld [hl], c
    db $f4
    sub c
    db $f4
    or c
    db $f4
    db $d3
    db $f4
    ld l, a
    dec sp
    cp $03
    dec sp
    ld e, e
    ld l, a
    ld b, c
    db $f4
    ld h, c
    db $f4
    add c
    db $f4
    and c
    db $f4
    pop bc
    db $f4
    ldh [c], a
    ld l, a
    dec sp
    cp $04
    dec sp
    ld e, e
    ld l, a
    db $f4
    ld d, c
    db $f4
    ld [hl], c
    db $f4
    sub c
    db $f4
    or c
    db $f4
    db $d3
    db $f4
    ld l, a
    dec sp
    cp $03
    dec sp
    ld e, e
    ld l, a
    ld b, c
    db $f4
    ld h, c
    db $f4
    add c
    db $f4
    and c
    db $f4
    pop bc
    db $f4
    ldh [c], a
    ld l, a
    dec sp
    cp $04
    dec sp
    ld e, e
    ld l, a
    db $f4
    ld d, c
    db $f4
    ld [hl], c
    db $f4
    sub c
    db $f4
    or c
    db $f4
    db $d3
    db $f4
    ld l, a
    dec sp
    cp $03
    dec sp
    ld e, e
    ld l, a
    ld b, c
    db $f4
    ld h, c
    db $f4
    add c
    db $f4
    and c
    db $f4
    pop bc
    db $f4
    ldh [c], a
    ld l, a
    dec sp
    cp $04
    dec sp
    ld e, e
    ld l, a
    db $f4
    ld d, c
    db $f4
    ld [hl], c
    db $f4
    sub c
    db $f4
    or c
    db $f4
    db $d3
    db $f4
    ld l, a
    dec sp
    cp $03
    dec sp
    ld e, e
    ld l, a
    ld b, c
    db $f4
    ld h, c
    db $f4
    add c
    db $f4
    and c
    db $f4
    pop bc
    db $f4
    ldh [c], a
    ld l, a
    dec sp
    cp $04
    dec sp
    ld e, e
    ld l, a
    db $f4
    ld d, c
    db $f4
    ld [hl], c
    db $f4
    sub c
    db $f4
    or c
    db $f4
    db $d3
    db $f4
    ld l, a
    dec sp
    cp $00
    dec sp
    ld e, e
    ld l, a
    ld l, a
    ld l, a
    ld l, a
    ld l, a
    ld l, a
    ld l, a
    ld l, a
    ld l, a
    ld l, a
    add d
    add d
    ld l, a
    dec sp
    cp $03
    dec sp
    ld e, e
    ld d, [hl]
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $03
    dec sp
    ld e, e
    ld d, a
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $03
    dec sp
    ld e, e
    ld e, c
    ld b, c
    ld e, d
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    sub c
    ld e, d
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $09
    db $fd
    ld l, a
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    ld l, a
    ld e, e
    add c
    ld l, a
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    ld l, a
    ld e, e
    add h
    db $fd
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    ld l, a
    ld e, e
    inc sp
    db $fd
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    ld l, a
    ld e, e
    ld sp, $516f
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    ld l, a
    ld e, e
    ld sp, $5b6f
    ld l, a
    ld l, a
    ld l, a
    ld l, a
    ld l, a
    ld l, a
    ld l, a
    ld l, a
    ld l, a
    ld l, a
    dec sp
    cp $02
    ld l, a
    ld e, e
    ld sp, $e26f
    ld e, h
    dec sp
    cp $02
    ld l, a
    ld e, e
    dec a
    ld l, a
    ld l, a
    ld l, a
    ld l, a
    ld l, a
    ld l, a
    ld l, a
    ld l, a
    ld l, a
    ld l, a
    ld l, a
    ld l, a
    dec sp
    cp $02
    ld l, a
    ld e, e
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    ld l, a
    ld e, e
    ldh [c], a
    ld l, a
    dec sp
    cp $0c
    db $fd
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    add c
    ld e, d
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    ld d, c
    ld e, d
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $03
    dec sp
    ld e, e
    ld d, [hl]
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $03
    dec sp
    ld e, e
    ld d, a
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $03
    dec sp
    ld e, e
    ld e, b
    sub c
    ld e, d
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $03
    dec sp
    ld e, e
    ld e, c
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    ld d, d
    ld d, d
    ld d, [hl]
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    ld d, d
    ld d, e
    ld d, a
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    ld sp, $525a
    ld d, l
    ld e, c
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    ld [hl], c
    ld e, d
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    or c
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    and d
    ld e, [hl]
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    sub e
    ld e, [hl]
    ld l, a
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    ld sp, $835a
    ld e, [hl]
    ld l, a
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    ld [hl], e
    ld e, [hl]
    ld l, a
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    ld h, e
    ld e, [hl]
    ld l, a
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    ld d, e
    ld e, [hl]
    ld l, a
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    ld b, e
    ld e, [hl]
    ld l, a
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $02
    dec sp
    ld e, e
    inc sp
    ld e, [hl]
    ld l, a
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $05
    dec sp
    ld e, e
    ld e, [hl]
    ld l, a
    ld l, a
    ldh [c], a
    ld l, a
    dec sp
    cp $04
    dec sp
    ld e, e
    ld l, a
    ld l, a
    ldh [c], a
    db $fd
    ld l, a
    cp $03
    dec sp
    ld l, a
    ld l, a
    ldh [c], a
    ld l, c
    ld l, a
    cp $02
    db $fd
    ld l, a
    ldh [c], a
    ld l, d
    ld l, a
    cp $01
    ld l, a
    add c
    ld l, a
    ldh [c], a
    ld l, c
    ld l, a
    cp $01
    ld l, a
    ldh [c], a
    ld l, d
    ld l, a
    cp $01
    ld l, a
    ldh [c], a
    ld l, c
    ld l, a
    cp $01
    ld l, a
    ldh [c], a
    ld l, d
    ld l, a
    cp $01
    ld l, a
    ldh [c], a
    ld l, c
    ld l, a
    cp $01
    ld l, a
    ldh [c], a
    ld l, d
    ld l, a
    cp $01
    ld l, a
    ldh [c], a
    ld l, c
    ld l, a
    cp $01
    ld l, a
    ldh [c], a
    ld l, d
    ld l, a
    cp $06
    ld l, a
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    or l
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    ld l, a
    cp $00
    ld l, a
    ld l, d
    ld l, d
    ld l, d
    ld l, d
    ld l, d
    add b
    add d
    add d
    add d
    add d
    ld l, d
    ld l, d
    ld l, d
    ld l, d
    ld l, a
    cp $02
    ld l, a
    ld l, c
    ldh [c], a
    ld l, c
    ld l, a
    cp $02
    ld l, a
    ld l, d
    ldh [c], a
    ld l, d
    ld l, a
    cp $02
    ld l, a
    ld l, c
    ldh [c], a
    ld l, c
    ld l, a
    cp $02
    ld l, a
    ld l, d
    ldh [c], a
    ld l, d
    ld l, a
    cp $02
    ld l, a
    ld l, c
    ld h, h
    db $fd
    db $dd
    ldh [c], a
    ld l, c
    ld l, a
    cp $02
    ld l, a
    ld l, d
    ld c, h
    add b
    add d
    sbc $de
    sbc $de
    add d
    add d
    add d
    add d
    ld l, d
    ld l, a
    cp $02
    ld l, a
    ld l, c
    ldh [c], a
    ld l, c
    ld l, a
    cp $02
    ld l, a
    ld l, d
    ldh [c], a
    ld l, d
    ld l, a
    cp $02
    ld l, a
    ld l, c
    ldh [c], a
    ld l, c
    ld l, a
    cp $02
    ld l, a
    ld l, d
    ldh [c], a
    ld l, d
    ld l, a
    cp $02
    ld l, a
    ld l, c
    ld d, c
    ld l, a
    ldh [c], a
    ld l, c
    ld l, a
    cp $02
    ld l, a
    ld l, d
    ldh [c], a
    ld l, d
    ld l, a
    cp $02
    ld l, a
    ld l, c
    ldh [c], a
    ld l, c
    ld l, a
    cp $02
    ld l, a
    ld l, d
    and c
    ld l, a
    ldh [c], a
    ld l, d
    ld l, a
    cp $02
    ld l, a
    ld l, c
    ldh [c], a
    ld l, c
    ld l, a
    cp $02
    ld l, a
    ld l, d
    ldh [c], a
    ld l, d
    ld l, a
    cp $02
    ld l, a
    ld l, c
    ldh [c], a
    ld l, c
    ld l, a
    cp $02
    ld l, a
    ld l, d
    ldh [c], a
    ld l, d
    ld l, a
    cp $0c
    ld l, a
    ld l, c
    ld l, l
    ld l, l
    ld l, l
    ld l, l
    ld l, l
    ld l, l
    ld l, l
    ld l, l
    ld l, l
    ld l, e
    ldh [c], a
    ld l, c
    ld l, a
    cp $0c
    ld l, a
    ld l, d
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, h
    ldh [c], a
    ld l, d
    ld l, a
    cp $02
    ld l, a
    ld l, c
    ld [hl], e
    db $fd
    db $f4
    ldh [c], a
    ld l, c
    ld l, a
    cp $02
    ld l, a
    ld l, d
    ld [hl], e
    db $fd
    db $f4
    ldh [c], a
    ld l, d
    ld l, a
    cp $02
    ld l, a
    ld l, c
    ld [hl], e
    db $fd
    db $f4
    ldh [c], a
    ld l, c
    ld l, a
    cp $02
    ld l, a
    ld l, d
    ld [hl], e

DataShim_7c52:
    db $fd
    db $f4
    ldh [c], a

LevelData_7c55:
    ld l, d
    ld l, a
    cp $02
    ld l, a
    ld l, c
    ld [hl], e
    db $fd
    db $f4
    ldh [c], a
    ld l, c
    ld l, a
    cp $02
    ld l, a
    ld l, d
    ld [hl], e
    db $fd
    db $f4
    ldh [c], a
    ld l, d
    ld l, a
    cp $07
    ld l, a
    ld l, c
    ld l, l
    ld l, l
    ld l, l
    ld l, l
    ld l, e
    and [hl]
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    ld l, a
    cp $07
    ld l, a
    ld l, d
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, h
    and [hl]
    ld l, d
    ld l, d
    ld l, d
    ld l, d
    ld l, d
    ld l, a
    cp $07
    ld l, a
    ld l, c
    ld l, l
    ld l, l
    ld l, l
    ld l, l
    ld l, e
    and [hl]
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    ld l, a
    cp $07
    ld l, a
    ld l, d
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, h
    and [hl]
    ld l, d
    ld l, d
    ld l, d
    ld l, d
    ld l, d
    ld l, a
    cp $07
    ld l, a
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    and [hl]
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    ld l, a
    cp $07
    ld l, a
    ld l, d
    ld l, d
    ld l, d
    ld l, d
    ld l, d
    ld l, d
    and [hl]
    ld l, d
    ld l, d
    ld l, d
    ld l, d
    ld l, d
    ld l, a
    cp $00
    ld l, a
    ld l, c
    ld l, a
    ld l, a
    ld l, a
    ld l, a
    ld l, a
    add d
    add d
    add d
    ld l, a
    ld l, a
    ld l, a
    ld l, a
    ld l, c
    ld l, a
    cp $02
    ld l, a
    ld l, d
    ldh [c], a
    ld l, d
    ld l, a
    cp $02
    ld l, a
    ld l, c
    ldh [c], a
    ld l, c
    ld l, a
    cp $02
    ld l, a
    ld l, d
    ldh [c], a
    ld l, d
    ld l, a
    cp $02
    ld l, a
    ld l, c
    ldh [c], a
    ld l, c
    ld l, a
    cp $02
    ld l, a
    ld l, d
    ldh [c], a
    ld l, d
    ld l, a
    cp $00
    ld l, a
    ld l, c
    ld e, a
    ld e, a
    ld e, a
    ld e, a
    ld e, a
    ld e, a
    ld e, a
    ld e, a
    ld e, a
    ld e, a
    ld e, a
    ld e, a
    ld l, c
    ld l, a
    cp $02
    ld l, a
    ld l, d
    ldh [c], a
    ld l, d
    ld l, a
    cp $02
    ld l, a
    ld l, c
    ldh [c], a
    ld l, c
    ld l, a
    cp $02
    ld l, a
    ld l, d
    ldh [c], a
    ld l, d
    ld l, a
    cp $02
    ld l, a
    ld l, c
    ldh [c], a
    ld l, c
    ld l, a
    cp $02
    ld l, a
    ld l, d
    ldh [c], a
    ld l, d
    ld l, a
    cp $02
    ld l, a
    ld l, c
    ldh [c], a
    ld l, c
    ld l, a
    cp $02
    ld l, a
    ld l, d
    ldh [c], a
    ld l, d
    ld l, a
    cp $02
    ld l, a
    ld l, c
    ldh [c], a
    ld l, c
    ld l, a
    cp $02
    ld l, a
    ld l, d
    ldh [c], a
    ld l, d
    ld l, a
    cp $02
    ld l, a
    ld l, c
    ldh [c], a
    ld l, c
    ld l, a
    cp $02
    ld l, a
    ld l, d
    ldh [c], a
    ld l, d
    ld l, a
    cp $02
    ld l, a
    ld l, c
    ldh [c], a
    ld l, c
    ld l, a
    cp $02
    ld l, a
    ld l, d
    ldh [c], a
    ld l, d
    ld l, a
    cp $02
    ld l, a
    ld l, c
    ldh [c], a
    ld l, c
    ld l, a
    cp $02
    ld l, a
    ld l, d
    ldh [c], a
    ld l, d
    ld l, a
    cp $02
    ld l, a
    ld l, c
    ldh [c], a
    ld l, c
    ld l, a
    cp $02
    ld l, a
    ld l, d
    ldh [c], a
    ld l, d
    ld l, a
    cp $00
    ld l, a
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    ld l, c
    ld l, a
    cp $00
    ld l, a
    ld l, d
    ld l, d
    ld l, d
    ld l, d
    ld l, d
    ld l, d
    ld l, d
    ld l, d
    ld l, d
    ld l, d
    ld l, d
    ld l, d
    ld l, d
    ld l, d
    ld l, a
    cp $ff
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

DataPadding_7e55:
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

Bank1EndPadding:
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
