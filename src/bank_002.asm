SECTION "ROM Bank $002", ROMX[$4000], BANK[$2]

    sub d
    ld h, c

Routine_DataProcess_A:
    or a
    ld h, c
    jp c, $9261

    ld h, c
    or a
    ld h, c
    jp c, $9261

    ld h, c
    or a
    ld h, c
    jp c, $9261

    ld h, c
    or a
    ld h, c
    jp c, $9061

    ld h, c
    ld [bc], a
    ld h, b
    ld [hl], e
    ld h, b
    cp $60
    ld [bc], a
    ld h, b
    ld [hl], e
    ld h, b
    cp $60
    ld [bc], a
    ld h, b
    ld [hl], e
    ld h, b
    cp $60
    ld [bc], a
    ld h, b
    ld [hl], e
    ld h, b
    cp $60
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    inc bc
    inc bc
    rlca
    rlca
    rrca
    ld c, $1f
    dec de
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    add b
    add b
    ldh a, [hCurrentTile]
    ldh [rLCDC], a
    ldh a, [rP1]
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $0301
    inc bc
    rlca
    rlca
    rrca
    dec c
    rrca
    inc c
    nop
    nop
    nop
    nop
    nop
    nop
    ret nz

    ret nz

    ld hl, sp-$08
    ldh a, [rNR41]
    ld hl, sp-$80
    ld hl, sp+$30
    nop
    nop
    nop
    nop
    nop
    nop
    inc bc
    inc bc
    rlca
    rlca
    rrca
    ld c, $1f
    dec de
    rra
    jr BytecodeDispatch_Chunk_1

BytecodeDispatch_Chunk_1:
    nop
    nop
    nop
    nop
    nop
    add b
    add b
    ldh a, [hCurrentTile]
    ldh [rLCDC], a
    ldh a, [rP1]
    ldh a, [$ff60]
    nop
    nop
    nop
    nop
    nop
    nop
    ld [bc], a
    ld [bc], a
    rrca
    add hl, bc
    dec c
    nop
    jr @+$12

    inc c
    ld [$0303], sp
    inc a
    ccf
    ld b, e
    ld a, h
    sbc h
    ldh [hSpriteAttr], a
    ret nz

    and b
    ret nz

    sub b
    ldh [$ff50], a
    ld h, b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    inc bc
    inc bc
    rlca
    rlca
    rrca
    ld c, $1f
    dec de
    nop
    nop
    nop
    nop
    nop
    nop
    ld c, $00
    adc [hl]
    add b
    db $fc
    db $fc
    db $ec
    ld c, h
    db $fc
    inc c
    nop
    nop
    nop
    nop
    nop
    nop
    inc bc
    inc bc
    rra
    rra
    rrca
    inc b
    rra
    ld [bc], a
    rrca
    inc c
    nop
    nop
    nop
    nop
    nop
    nop
    add b
    add b
    ldh [hVramPtrLow], a
    ldh a, [hCurrentTile]
    ld hl, sp-$60
    ld hl, sp+$20
    rlca
    rlca
    rrca
    rrca
    rrca
    rrca
    rra
    rra
    rra
    ld e, $3f
    ld a, $3f
    ld a, $3f
    ccf
    ldh [hVramPtrLow], a
    ldh a, [hCurrentTile]
    ldh a, [hAudioControl]
    ldh [rP1], a
    ldh a, [rLCDC]
    ldh [rP1], a
    ldh [rP1], a
    ret nz

    ld b, b
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
    inc e
    inc e
    ld a, $3e
    ld a, a
    ld a, a
    nop
    nop
    nop
    nop
    nop
    nop
    inc bc
    inc bc
    rla
    rlca
    ccf
    ld a, [bc]

BytecodeDispatch_Chunk_2:
    ccf
    inc e
    rra
    dec de
    rra
    jr Skip_9Bytes_002_413c

    nop
    dec c
    rrca
    dec e
    rra
    inc e
    dec b

Skip_9Bytes_002_413c:
    jr @+$09

    ld b, $06
    ld c, $0e
    ldh a, [$ff60]
    ldh [rP1], a
    add b
    ret nz

    or b
    ldh a, [$ff38]
    or b
    jr BytecodeDispatch_Chunk_2

    ld h, b
    ld h, b
    ld [hl], b
    ld [hl], b
    inc bc
    nop
    rrca
    rrca
    ccf
    rrca
    scf
    rlca
    nop
    rrca
    db $10
    rra
    jr BytecodeDispatch_Chunk_4

    ld c, $0e
    ldh a, [rP1]
    ld b, b
    ret nz

    ld a, h

BytecodeDispatch_Chunk_3:
    ldh [$ff3c], a
    ld [hl], b
    ld [$18c8], sp
    ld hl, sp+$18
    ld a, b
    nop
    nop
    rlca
    nop
    ld c, $0f
    ld e, $1f
    ld e, $18
    inc b
    dec de

BytecodeDispatch_Chunk_4:
    nop
    rrca
    rlca
    rlca
    rlca
    rlca
    ldh [rP1], a
    add b
    add b
    ret nz

    ret nz

    nop
    and b
    nop
    ldh [hSoundId], a
    ret nz

    ldh [hVramPtrLow], a
    add b
    add b
    rra
    jr BytecodeDispatch_Chunk_5

    nop
    rrca
    rrca
    rra
    rrca
    jr nc, BytecodeDispatch_Chunk_6

BytecodeDispatch_Chunk_5:
    db $10
    rra
    ld sp, $213d
    ld hl, $60f0
    ldh [rP1], a
    ld e, b
    ret nz

    ld hl, sp-$40
    nop

BytecodeDispatch_Chunk_6:
    ldh [rP1], a
    ret nz

    add b
    add b
    ret nz

    ret nz

    rra
    jr @+$09

    nop
    dec e
    rra
    ld a, h
    ccf
    ld h, b
    ld c, $50
    rra
    jr c, JumpOffset_Set_2

    jr nz, BytecodeDispatch_Chunk_7

    ld hl, sp+$78
    ldh a, [rNR10]
    and b
    ldh [hSoundCh1], a
    db $e4
    inc c
    call c, $fc0c
    nop
    ret nz

    nop
    nop
    rra
    jr JumpOffset_Set_1

    rra
    rra
    rra
    ld c, $0f
    ld bc, $0103
    inc bc
    nop
    nop
    nop
    nop
    nop
    ldh [hSoundId], a
    jr nc, BytecodeDispatch_Chunk_3

    ld [hl], b

BytecodeDispatch_Chunk_7:
    ldh [hCurrentTile], a
    ret nz

    ldh [hObjParamBuf0], a
    add sp, $78
    ld hl, sp+$70
    ld [hl], b
    inc a
    ccf

JumpOffset_Set_1:
    dec sp
    inc a
    ld [de], a
    ld de, $0403
    ld bc, $010e
    ld e, $00

JumpOffset_Set_2:
    ccf
    nop
    ld a, a
    ld b, b
    and b
    nop
    ldh [rP1], a
    ret nz

    nop
    ldh [hJoypadState], a
    ld h, b
    add b
    ld [hl], b
    nop
    ldh a, [rP1]
    ldh a, [rIE]
    rst $38
    ld a, a
    ld a, a
    ld a, $3e
    inc e
    inc e
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    rrca
    ld [$0e0d], sp
    ld hl, $382f
    dec a
    jr c, JumpOffset_Set_5

    nop
    rlca
    nop
    nop
    nop
    nop
    rlca
    rlca
    rrca
    rrca
    rrca
    inc c
    rra
    ld d, $3f
    jr nc, @+$41

    jr nc, JumpOffset_Set_3

    ld [$0f0b], sp
    ret nz

    ret nz

    ldh a, [hCurrentTile]
    ldh [hJoypadState], a
    ld hl, sp+$00
    ld hl, sp+$40
    ldh a, [hCurrentTile]

JumpOffset_Set_3:
    ldh [rP1], a
    add b
    ret nz

    nop
    nop
    inc bc
    inc bc
    rlca
    rlca
    rlca
    ld b, $0f
    dec bc
    rra
    jr @+$21

    jr JumpOffset_Set_4

    inc b
    nop
    nop
    ldh [hVramPtrLow], a
    ld hl, sp-$08

JumpOffset_Set_4:
    ldh a, [rLCDC]
    db $fc

JumpOffset_Set_5:
    nop
    db $fc
    jr nz, @-$06

    ld a, b
    ldh a, [rP1]
    rlca
    rlca
    rrca
    rrca
    rrca
    inc c
    rra
    ld d, $3f
    jr nc, @+$41

    jr nc, JumpOffset_Set_6

    ld [$1f1f], sp
    ret nz

    ret nz

    ldh a, [hCurrentTile]
    ldh [hJoypadState], a
    ld hl, sp+$00
    ld hl, sp+$40
    ldh a, [hCurrentTile]

JumpOffset_Set_6:
    ldh [rP1], a
    ld b, b
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
    inc e
    inc e
    ld [hl+], a
    ld a, $49
    ld [hl], e
    or c
    pop bc
    ld e, c
    ld h, e
    ld [hl+], a
    ld a, $1c
    inc e
    nop
    nop
    nop

JumpOffset_Set_7:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    rlca
    rlca
    rrca
    rrca
    rrca
    inc c
    rra
    ld d, $3f
    jr nc, RoutineOffset_3

    jr nc, RoutineOffset_1

    inc c
    ld c, $00
    sbc $c8
    cp $f0
    cp $9e
    cp $06
    db $fc
    ld b, h
    db $fc
    db $fc

RoutineOffset_1:
    ld hl, sp+$18
    rlca
    rlca
    rra
    rra
    rrca
    ld [bc], a
    rra
    nop
    ccf
    ld b, $3f
    inc c
    rrca
    ld bc, $1f1d
    add b
    add b
    ld hl, sp-$10
    db $fc
    ld h, b
    call z, $c0b0
    jr nz, JumpOffset_Set_7

    ldh a, [hVramPtrLow]
    jr c, @-$1e

    jr RoutineOffset_2

RoutineOffset_2:
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

RoutineOffset_3:
    nop
    nop
    nop
    nop
    nop
    nop
    rlca
    rlca
    adc a
    adc b
    ret c

    ret nc

RoutineOffset_4:
    ld a, b
    ld a, b

RoutineOffset_5:
    ld l, [hl]
    xor $fb
    db $e3
    rst $38
    ld h, b
    nop
    nop
    inc bc
    inc bc
    rlca
    rlca
    rrca
    rrca
    rra
    rra
    rra
    ld e, $3f
    ld a, $3f
    ld a, $00
    nop
    ldh [hVramPtrLow], a
    ldh a, [hCurrentTile]
    ldh a, [hAudioControl]
    ldh [rP1], a
    ldh a, [rLCDC]
    ldh [rP1], a
    ldh [rP1], a
    dec de
    rra
    dec sp
    ccf
    jr c, DataTable_JumpDispatch_004

    jr c, DataTable_JumpDispatch_001

    jr DataTable_JumpDispatch_002

    nop
    ld e, $1c
    inc e
    inc a

DataTable_JumpDispatch_001:
    inc a
    and b

DataTable_JumpDispatch_002:
    ldh [hSpriteAttr], a
    ldh a, [$ff38]
    cp b
    jr c, RoutineOffset_4

    jr nc, RoutineOffset_5

    nop
    ldh a, [rSVBK]
    ld [hl], b
    ld a, b
    ld a, b
    dec bc
    rrca
    inc de
    rra
    inc bc
    rra
    jr nc, @+$41

    jr nc, @+$41

    jr nc, RoutineOffset_6

    jr nz, DataTable_JumpDispatch_005

    nop
    nop
    nop
    ret nz

    ret c

    ret nz

DataTable_JumpDispatch_003:
    db $fc
    ldh [hOAMAddrLow], a
    ldh [hJoypadState], a
    ldh [rP1], a
    ldh [rSVBK], a
    ld [hl], b
    ld a, b
    ld a, b
    rla

DataTable_JumpDispatch_004:
    rra
    rlca
    rra
    nop
    rra
    nop
    rrca
    ld bc, $050f
    rlca
    ld c, $0e

DataTable_JumpDispatch_005:
    rlca
    rlca
    ret nz

    add b
    ldh [hJoypadState], a
    ld h, b
    add b
    nop
    ldh [hJoypadState], a
    ldh [hSoundId], a
    ret nz

    ld b, b
    ld b, b
    nop
    nop
    rrca
    rrca
    rra
    rra
    jr c, @+$09

    jr nc, RoutineOffset_7

RoutineOffset_6:
    jr TableEntry_Variant_3

    jr TableEntry_Variant_4

    jr TableEntry_Variant_2

    inc c

RoutineOffset_7:
    inc c

TableEntry_Variant_1:
    ld e, h
    ldh [$ff5c], a
    ldh [$ff08], a
    ld l, b
    jr c, TableEntry_Variant_1

    jr c, @-$06

    jr c, DataTable_JumpDispatch_003

    nop
    nop
    nop
    nop
    ld a, $3f
    ld a, $37
    inc a
    inc hl

TableEntry_Variant_2:
    inc e
    rlca
    ld h, [hl]

TableEntry_Variant_3:
    ld a, a
    ld h, e

TableEntry_Variant_4:
    ld a, a
    ld h, b
    ld a, [hl]
    ld b, b
    ld b, b
    or b
    ldh a, [$ffa0]
    ldh a, [rSC]
    ld [hl], d
    ld b, $fe
    ld b, $fe
    add [hl]
    cp $00
    nop
    nop
    nop
    rra
    rra
    ld e, $1f
    ld [$000f], sp
    rlca
    nop
    inc bc
    nop
    nop
    nop
    nop
    nop
    nop
    ret nz

    jr nc, DataTable_Lookup_001

    ldh [$ff78], a
    ld hl, sp-$08
    ret z

    ldh a, [c]
    add d
    ld c, [hl]
    cp [hl]
    inc a
    ld a, h
    jr c, TableEntry_Variant_5

    cp a
    xor c
    db $eb
    cp a
    cp h
    db $fc
    rst $38
    rst $38
    rst $08
    rr a
    db $10
    rra
    ld de, $1e1e
    nop
    rst $38
    nop
    nop
    rrca
    rrca
    ld hl, sp-$01
    cp $ff
    rst $38
    ld a, a
    add e
    add e
    nop
    nop
    ld a, a
    ld a, a
    ld a, b
    ld a, e
    ld bc, $0102
    ld [bc], a
    nop
    rlca
    nop
    rrca
    nop
    rra
    nop
    ccf
    ret nz

    ld b, b
    ld b, b
    and b
    nop
    ldh [hSpriteAttr], a
    ld b, b

TableEntry_Variant_5:
    ldh a, [rP1]
    nop
    ldh [rP1], a
    ldh [rP1], a
    ldh a, [rP1]
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
    rrca
    rrca
    rrca
    inc c
    nop
    nop
    nop

DataTable_Lookup_001:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ret nz

    ret nz

TableEntry_Variant_6:
    ldh a, [hCurrentTile]
    ldh [hJoypadState], a
    rra
    ld d, $1f
    db $10
    rra
    jr DataTable_Lookup_004

    jr c, @+$3d

    inc sp
    jr c, DataTable_Lookup_003

    inc e
    rra
    inc a
    inc a
    ld hl, sp+$00
    ld hl, sp+$40
    ldh a, [hCurrentTile]

DataTable_Lookup_002:
    ld hl, sp+$18
    cp b
    xor b
    jr TableEntry_Variant_6

    jr c, DataTable_Lookup_002

    inc a
    inc a
    nop
    nop
    rlca
    rlca
    rrca
    rrca
    rrca
    inc c
    rra
    ld d, $3f
    jr nc, TableEntry_Variant_7

    jr nc, DataTable_Lookup_004

    add hl, bc
    nop
    nop
    ret nz

DataTable_Lookup_003:
    ret nz

    ldh a, [hCurrentTile]
    ldh [hJoypadState], a
    ld hl, sp+$00
    ld hl, sp+$40
    cp $f0

DataTable_Lookup_004:
    db $fc
    ldh a, [$ff0b]
    rrca
    ld bc, $000f
    rra
    nop
    rra
    ld h, b
    ld a, a
    ld h, b
    ld a, [hl]
    ld h, b
    ld l, h
    ld b, b
    ld b, b
    ldh [hVramPtrLow], a
    add b
    ret nz

    nop
    ret nz

    ld b, b
    ldh [hJoypadState], a
    ldh [rP1], a
    ldh [rSVBK], a
    ld [hl], b
    ld a, b
    ld a, b
    rlca
    rlca
    rrca
    rrca
    rra
    rra
    rra
    inc e
    ccf
    dec a
    ccf
    inc a

TableEntry_Variant_7:
    ld a, a
    ld a, h
    ld a, a
    ld a, a
    ret nz

    ret nz

    ldh [hVramPtrLow], a
    ldh a, [rSVBK]
    ldh a, [rNR10]
    ldh a, [$ff50]
    ldh a, [rNR10]
    ldh [hJoypadState], a
    ret nz

    ld b, b
    ld a, c
    ld a, d
    jr nc, TableEntry_Variant_8

    ld b, $01
    rlca
    ld [$1f00], sp
    nop
    ccf
    nop
    ld a, a
    nop
    rst $38
    call nz, $1c20
    ldh [$ff30], a
    ret nz

    ret nz

    nop
    nop
    ret nz

    nop
    ldh [rP1], a
    ldh [rP1], a
    ldh [rP1], a
    nop
    ldh [hVramPtrLow], a
    ldh a, [hAnimObjX]
    adc b
    adc b
    add h
    add h
    adc h
    adc h
    ld a, [$fdfa]
    ld de, wObjBufferVar3D
    ld a, l
    ld d, e
    ld sp, hl
    sub a
    inc de
    rst $38
    ld e, $fe
    db $fc

TableEntry_Variant_8:
    db $fc
    ldh a, [hCurrentTile]
    nop
    nop
    rlca
    rlca
    rrca
    rrca
    rrca
    rrca
    rra
    inc e
    rra
    dec e
    ccf
    inc a
    ccf
    inc a
    ccf
    ccf
    ld e, $1e
    ld de, $1e11
    db $10
    rra
    inc de
    inc e
    inc d
    call z, $ffcf
    cp a
    xor a
    xor b
    dec a
    ld a, $38
    ccf
    ld e, $19
    inc bc
    inc b
    ld bc, $000e
    rra
    nop
    ccf
    nop
    ld a, a
    ret nz

    jr nz, TableEntry_Variant_9

TableEntry_Variant_9:
    ldh a, [$ff30]
    ret nz

    ld h, b
    add b
    ret nz

    jr nz, ReadJoypadInput

ReadJoypadInput:
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [$fffe]
    cp $fe
    add d
    cp $ee
    jr c, ConstTableA_Entry1

    jr c, ConstTableA_Entry2

    jr c, ConstTableA_Entry3

    jr c, ConstTableA_Entry4

    jr c, ConstTableA_Entry5

    xor $ee
    xor $aa
    cp $ba
    cp $82
    cp $ba
    xor $aa
    xor $aa
    xor $ee
    cp $fe
    cp $82
    cp $be
    db $fc
    add h
    db $fc
    cp h
    cp $be
    cp $82
    cp $fe

ConstTableA_Entry1:
    or $f6

ConstTableA_Entry2:
    cp $9a

ConstTableA_Entry3:
    cp $9a

ConstTableA_Entry4:
    cp $aa
    cp $a2
    cp $b2
    xor $aa
    xor $ee
    db $fc
    db $fc
    cp $86
    cp $b2
    xor $aa

ConstTableA_Entry5:
    xor $aa
    cp $b2
    cp $86
    db $fc
    db $fc
    nop
    nop
    ld [hl+], a
    ld [hl+], a
    ld d, l
    ld d, l
    ld d, l
    ld d, l
    ld d, l
    ld d, l
    ld d, l
    ld d, l
    ld [hl+], a
    ld [hl+], a
    nop
    nop
    nop
    nop
    jr nz, ConstTableA_Entry6

    ld d, b
    ld d, b
    ld d, b
    ld d, b
    ld d, b
    ld d, b
    ld d, b
    ld d, b
    jr nz, PaddingZone_002_45e0

    nop
    nop
    nop
    nop
    ld [de], a
    ld [de], a
    dec [hl]
    dec [hl]
    dec d
    dec d
    dec d
    dec d
    dec d
    dec d
    ld [de], a
    ld [de], a
    nop
    nop
    nop
    nop
    ld [hl+], a
    ld [hl+], a

ConstTableA_Entry6:
    ld d, l
    ld d, l
    dec d
    dec d
    dec h
    dec h
    ld b, l
    ld b, l
    ld [hl], d
    ld [hl], d

PaddingZone_002_45e0:
    nop
    nop
    nop
    nop
    and d
    and d
    and l
    and l
    and l
    and l
    push af
    push af
    dec h
    dec h
    ld [hl+], a
    ld [hl+], a
    nop
    nop
    nop
    nop
    ld [hl], d
    ld [hl], d
    ld b, l
    ld b, l
    ld h, l
    ld h, l
    dec d
    dec d
    dec d
    dec d
    ld h, d
    ld h, d
    nop
    nop
    nop
    nop
    ld h, d
    ld h, d
    sub l
    sub l
    ld h, l
    ld h, l
    or l
    or l
    sub l
    sub l
    ld h, d
    ld h, d
    nop
    nop
    nop
    nop
    ld l, [hl]
    ld l, [hl]
    xor $ee
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, a
    ld l, a
    ld h, a
    ld h, a
    nop
    nop
    nop
    nop
    cp [hl]
    cp [hl]
    cp c
    cp c
    cp c
    cp c
    cp [hl]
    cp [hl]
    cp b
    cp b
    jr c, PaddingZone_002_4668

    nop
    nop
    nop
    nop
    inc a
    inc a
    ld h, [hl]
    ld h, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld a, [hl]
    ld a, [hl]
    inc a
    inc a
    nop
    nop
    nop
    nop
    nop
    nop
    inc bc
    inc bc
    inc c
    inc c
    db $10
    db $10
    jr nz, PaddingZone_002_466e

    jr nz, SetVramPointer

    ld b, b
    ld b, b
    nop
    nop
    nop
    nop
    jr SetVramPointer

    inc a
    inc h
    ld a, d
    ld d, [hl]
    inc a
    inc c
    ld [$0018], sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop

PaddingZone_002_4668:
    nop
    nop
    inc bc
    inc bc
    rlca
    rlca

PaddingZone_002_466e:
    ld h, h
    ld h, h

SetVramPointer:
    ld d, h
    ld d, l
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ldh [hVramPtrLow], a
    ldh a, [hCurrentTile]
    ldh a, [$ffa0]
    ld hl, sp-$80
    ld [hl], a
    ld d, a
    ld a, e

InfiniteLoop_002_4685:
    ld a, b
    ld c, a
    ld c, a
    ld a, h
    ld a, h
    jr c, ConstTableA_Entry7

    rra
    rra
    rlca
    rlca
    ld bc, $f801
    jr nc, InfiniteLoop_002_4685

    nop
    ld hl, sp-$08
    inc e
    inc d
    ld a, a
    ld a, l
    call z, InitializeGameObjects
    ld sp, hl
    pop af
    pop af
    ld hl, sp+$30
    pop af
    ld bc, $f9f9
    inc e
    inc d
    ld a, a
    ld a, l
    call z, ProcessSoundParams
    ld hl, sp-$10
    ldh a, [rP1]
    nop
    rlca
    rlca
    rrca
    rrca
    ret


    ret


    xor c
    xor e
    rst $28
    xor a
    rst $20
    and a
    di
    sub b
    nop
    nop

ConstTableA_Entry7:
    ldh [hVramPtrLow], a
    ldh a, [hCurrentTile]
    ldh a, [rLCDC]
    db $fc
    nop
    db $fc
    jr nz, @-$06

    ld a, b
    ldh a, [rP1]
    rst $38
    rst $38
    adc a
    adc a
    ld hl, sp-$08
    ldh [hVramPtrLow], a
    ld l, a
    ld a, a
    inc a
    ccf
    rrca
    rrca
    inc bc
    inc bc
    db $fc
    db $fc
    rst $30
    push af
    rra
    dec d
    db $fc
    db $fc
    adc e
    ei
    dec de
    ei
    di
    ldh a, [hSoundParam2]
    jp RST_00


    ldh [hVramPtrLow], a
    ldh a, [hCurrentTile]
    ldh a, [rLCDC]

LcdStatusWaitLoop:
    rst $38
    inc bc
    rst $38
    jr nz, LcdStatusWaitLoop

    ld a, e
    di
    inc bc
    db $fc
    db $fc
    rst $30
    push af
    rra
    dec d
    db $fc
    db $fc
    adc b
    ld hl, sp+$18
    ld hl, sp-$10
    ldh a, [hSoundId]
    ret nz

    nop
    nop
    inc a
    inc a
    ld l, [hl]
    ld l, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld a, [hl]
    ld a, [hl]
    inc a
    inc a
    nop
    nop
    nop
    nop
    nop
    nop
    add b
    add b
    ld b, b
    ld b, b
    inc h
    inc h
    ld a, [de]
    ld a, [de]
    ld bc, $0601
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    inc bc
    inc bc
    inc b
    inc b
    add hl, bc
    add hl, bc
    dec bc
    dec bc
    rrca
    ld c, $00
    nop
    nop
    nop
    nop
    nop
    db $fc
    db $fc
    ldh [c], a
    ldh [c], a
    db $fd
    db $fd
    ld sp, hl
    sub c
    db $fd
    pop bc
    rrca
    ld c, $09
    ld [$0f0f], sp
    ld h, a
    ld h, h
    ld h, h
    ld h, h
    inc d
    rla
    inc bc
    inc bc
    nop
    nop
    db $fd
    add hl, de
    ld sp, hl
    ld bc, $f9f9
    sub $56
    ld a, a
    ccf
    ld a, l
    ld sp, hl
    ld sp, hl
    db $fd
    cp $fe
    rrca
    ld c, $09
    ld [$0f0f], sp
    rlca
    inc b
    inc b
    inc b
    inc d
    rla
    ld h, e
    ld h, e
    ld h, b
    ld h, b
    rrca
    rrca
    inc de
    inc de
    daa
    daa
    daa
    ld h, $2f
    dec hl
    ccf
    jr c, ConstTableA_Entry9

    jr c, ConstTableA_Entry8

    inc h
    db $fc
    db $fc
    ldh [c], a
    ldh [c], a
    ld sp, hl
    ld sp, hl
    pop af
    ld b, c
    db $fd
    ld bc, $21fd
    ld sp, hl
    ld a, c
    pop af
    ld bc, $3f3f
    rst $18
    call nc, $d4d4
    call nc, AnimStateDispatcher
    ccf
    rra
    rra
    rrca
    rrca
    inc bc
    inc bc
    ld sp, hl
    ld sp, hl
    xor [hl]
    xor [hl]
    rst $38
    ld a, a

ConstTableA_Entry8:
    ld a, l
    pop af
    pop af
    db $fd
    cp $fe
    cp $fe
    db $fc
    db $fc
    ccf
    ccf
    rra
    inc d
    inc d
    inc d
    inc d
    rra
    inc [hl]
    ccf
    rst $18
    rst $18

ConstTableA_Entry9:
    rst $08
    rst $08
    jp LCDStat_CheckCarryExit


    nop
    nop
    nop
    ld e, $1e
    ld [hl], e
    ld [hl], e
    rst $38
    rst $38
    ld a, a
    ld a, a
    ld e, $1e
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

ConstTableA_Entry10:
    nop
    nop
    nop
    nop
    nop
    add b
    add b
    ld b, b
    ld b, b
    ld bc, $0201
    ld [bc], a
    inc b
    inc b
    rrca
    ld [$0407], sp
    inc bc
    ld [bc], a
    ld bc, $0001
    nop
    add b
    add b
    nop
    nop
    pop bc

AudioDispatchEntry_4807:
    nop
    rst $30
    nop
    rst $38
    nop
    rst $38
    ld b, b
    rst $38
    db $e3
    ld a, $3e
    inc de
    nop
    sbc c
    nop
    pop bc
    nop
    db $e3
    nop
    rst $38
    nop
    rst $38
    add b
    ld a, a
    ld b, c
    ld a, $3e
    ld b, b
    ld b, b
    and b
    jr nz, AudioDispatchEntry_4807

    jr nz, ConstTableA_Entry10

    ld b, b
    ret nz

    ld b, b
    add b
    add b
    nop
    nop
    nop
    nop
    ld a, [hl]
    ld a, [hl]
    rst $38
    add e
    rst $38
    cp e
    rst $38
    and e
    rst $38
    and e
    rst $38
    add a
    rst $38
    rst $38
    ld a, [hl]
    ld a, [hl]
    ld a, [hl]
    ld a, [hl]
    sbc c
    sbc c
    and l
    and l
    adc l
    adc l
    sbc c
    sbc c
    add c
    add c
    sbc c
    sbc c
    ld a, [hl]
    ld a, [hl]
    ld a, [hl]
    ld a, [hl]
    rst $38
    add e
    rst $38
    cp e
    rst $38
    and e
    rst $38
    and e
    rst $38
    add a
    rst $38
    rst $38
    ld a, [hl]
    ld a, [hl]
    inc a
    inc a
    ld a, [hl]
    ld b, d
    rst $38
    add c
    rst $38
    add c
    rst $38
    rst $38
    ld b, d
    ld b, d
    ld b, d
    ld b, d
    inc a
    inc a
    nop
    nop
    ld l, [hl]
    ld l, [hl]
    cp a
    sub e
    cp a
    add e
    rst $38
    add e
    ld a, [hl]
    ld b, [hl]
    inc a
    inc l
    jr DispatchEntry_002_489a

    nop
    nop
    stop
    stop
    cp $00
    ld a, h
    nop
    jr c, JoypadInputEntry_488e

JoypadInputEntry_488e:
    ld a, h
    nop
    add $00
    nop
    nop
    db $10
    db $10
    db $10
    db $10
    cp $fe

DispatchEntry_002_489a:
    ld a, h
    ld a, h
    jr c, PaddingZone_002_48d6

    ld a, h
    ld a, h
    add $c6
    jp $3dc3


    dec a
    jp hSoundParam2


    rst $38
    rst $38
    rst $38
    rst $28
    rst $20
    rst $38
    rst $38
    db $db
    db $db
    inc a
    inc a
    jr nz, PaddingZone_002_4904

    rst $38
    rst $38
    rst $38
    cp l
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    cp l
    rst $38
    rst $38
    rrca
    rrca
    rra
    db $10
    jr c, UnknownCode_002_48f8

    ld [hl], b
    ld b, b
    ld h, b
    ld b, b
    ret nz

    add b
    ret nz

    add b
    ret nz

    add b
    cp a
    cp a
    rst $38
    ld b, b

PaddingZone_002_48d6:
    ld b, b
    nop
    nop
    nop
    nop
    nop
    ld b, c
    ld b, c
    ld b, c
    ld b, c
    nop
    nop
    add b
    add b
    ld hl, sp+$78
    inc a
    inc b
    inc c
    inc b
    ld c, $02
    ld b, $02
    dec b
    inc bc
    dec b
    inc bc
    ret nz

    add b
    ret nz

    add b
    ldh [hJoypadState], a

UnknownCode_002_48f8:
    ld [hl], b
    ld b, b
    ld a, $20
    inc hl
    inc a
    dec e
    ld e, $03
    inc bc
    nop
    nop

PaddingZone_002_4904:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ccf
    nop
    sbc h
    ld a, a
    db $e3
    db $e3
    rst $38
    rst $38
    add b
    add b
    cp a
    add b
    xor a
    adc b
    cp a
    sbc b
    cp a
    add b
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    inc bc
    inc bc
    rst $38
    inc bc
    rst $28
    dec bc
    rst $38
    dec de
    rst $38
    inc bc
    rst $38
    rst $38
    rst $38
    rst $38
    inc a
    inc a
    ld a, [hl]
    ld a, [hl]
    db $db
    db $db
    db $db
    db $db
    rst $38
    rst $38
    inc a
    nop
    ld a, [hl]
    ld h, d
    ld [hl], $36
    nop
    nop
    nop
    nop
    nop
    nop
    inc a
    inc a
    ld a, [hl]
    ld a, [hl]
    db $db
    db $db
    inc a
    nop
    jp $18c3


    jr PaddingZone_002_4991

    inc h
    ld a, [hl]
    ld d, d
    ld a, [hl]
    ld b, d
    rst $38
    pop bc
    rst $38
    add l
    rst $38
    add c
    rst $38
    and e
    rst $38
    add c
    rst $38
    jp DataTable_667e


    inc a
    inc a
    sbc c
    sbc c
    db $db
    db $db
    ld a, [hl]
    ld a, [hl]
    inc a
    inc a
    add c
    add c
    add c
    add c
    jp $c3c3


    jp $a5e7


    rst $20
    and l
    rst $20
    and l
    rst $20
    and l
    rst $38
    cp l
    rst $38
    sbc c
    ld a, [hl]
    ld b, d
    inc a
    inc a
    sbc c
    sbc c
    db $db
    db $db
    ld a, [hl]
    ld a, [hl]
    inc a

PaddingZone_002_4991:
    inc a
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
    ld h, b
    ld h, b
    sub b
    sub b
    ret nc

    ret nc

    ret nc

    ret nc

    sub b
    sub b
    add sp, -$20
    ld a, [hl]
    ld l, [hl]
    dec a
    dec l
    rra
    rrca
    rra
    ld b, $3f
    add hl, sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld h, b
    ld h, b
    sub b
    sub b
    ret nc

    ret nc

    ret nc

    ret nc

    sub b
    sub b
    add sp, -$20
    ld a, $2e
    dec a
    dec l
    ld a, a
    ld l, a
    rra
    ld b, $1e
    db $10
    scf
    scf
    nop
    nop
    nop
    nop
    inc a
    inc a
    ld l, [hl]
    ld l, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld a, [hl]
    ld a, [hl]
    inc a
    inc a
    nop
    nop
    nop
    nop
    inc a
    nop
    ld l, [hl]
    nop
    ld e, [hl]
    nop
    ld e, [hl]
    nop
    ld a, [hl]
    nop
    inc a
    nop
    dec b
    inc bc
    dec c
    inc bc
    add hl, bc
    rlca
    ld a, [bc]
    ld b, $32
    ld c, $e4
    inc e
    ld [$f0f8], sp
    ldh a, [rP1]
    nop
    nop
    nop
    ld [bc], a
    ld [bc], a
    nop
    nop
    ld de, $0511
    inc b
    inc bc
    ld bc, $2a2e
    ld b, $06
    ld [$2708], sp
    inc h
    inc l
    jr z, DispatchEntry_002_4a36

    ld de, $8094
    ld e, c
    ld c, c
    inc sp
    inc hl
    nop
    nop
    nop
    nop
    nop
    nop
    rst $38
    rst $38
    rst $38
    rst $38
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

DispatchEntry_002_4a36:
    jr nc, PaddingZone_002_4a68

    ld c, b
    ld c, b
    ld b, h
    ld b, h
    ld [hl], l
    ld b, l
    ld [hl], a
    ld h, [hl]
    add hl, sp
    add hl, sp
    nop
    nop
    nop
    nop
    inc c
    inc c
    ld [de], a
    ld [de], a
    ld [hl+], a
    ld [hl+], a
    xor [hl]
    and d
    xor $66
    sbc h
    sbc h
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
    ld h, c
    ld h, c
    sub a
    sub [hl]
    adc c
    adc c
    nop
    nop
    nop
    nop
    nop
    nop

PaddingZone_002_4a68:
    nop
    nop
    nop
    nop
    add [hl]
    add [hl]
    jp hl


    ld l, c
    sub c
    sub c
    ccf
    ccf
    ld l, l
    ld [hl], b
    ld a, a
    ld a, a
    adc [hl]
    adc e
    xor a
    xor e
    cp $fb
    rst $38
    add e
    cp $87
    add b
    add b
    ld b, b
    ret nz

    ldh [hVramPtrLow], a
    or b
    db $10
    ldh a, [hCurrentTile]
    or b
    db $10
    ldh a, [hCurrentTile]
    ld b, b
    ret nz

UnknownCode_002_4a92:
    rra
    rra
    ld [hl], $38
    ccf
    ccf
    ld b, a
    ld b, l
    ld d, a
    ld d, l
    ld a, a
    ld a, l
    scf
    dec [hl]
    rlca
    dec b
    ret nz

    ret nz

    and b
    ld h, b
    ldh a, [hCurrentTile]
    ld e, b
    adc b
    ld hl, sp-$08
    ld e, b
    adc b
    ld hl, sp-$08
    jr nz, UnknownCode_002_4a92

    ld bc, $0701
    ld b, $0f
    ld [$383f], sp
    ld c, a
    ld c, b
    adc a
    adc [hl]
    cp a
    adc b
    rst $30
    rst $30
    add b
    add b
    ld h, b
    ldh [hAnimObjX], a
    ld [hl], b
    call c, $d23c
    ld [hl-], a
    pop af
    ld [hl], c
    db $dd
    ld sp, $efef
    ld bc, $0301
    inc bc
    rlca
    rlca
    rrca
    rrca
    rrca
    rrca
    ld a, $3e
    ldh [hVramPtrLow], a
    nop
    nop
    rst $38
    sbc l
    ld [hl], a
    ld [hl], l
    daa
    dec h
    rlca
    dec b
    ccf
    dec sp
    ld a, $22
    sbc a
    sbc a
    ld a, [$00fa]
    nop
    jr c, FlagDispatch_Default

    jr c, FlagDispatch_Entry1

    jr c, FlagDispatch_Entry2

    jr c, FlagDispatch_Entry3

    jr c, FlagDispatch_Entry4

    jr c, FlagDispatch_Entry5

    jr c, FlagDispatch_Entry6

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

FlagDispatch_Entry1:
    nop
    nop

FlagDispatch_Entry2:
    nop
    nop

FlagDispatch_Entry3:
    nop
    nop

FlagDispatch_Entry4:
    nop
    nop

FlagDispatch_Entry5:
    nop
    nop

FlagDispatch_Entry6:
    nop
    nop
    nop
    nop

FlagDispatch_Default:
    nop
    nop
    nop
    nop
    dec bc
    ld a, [bc]
    rst $08
    rst $08
    jp hl


    jp hl


    add hl, sp
    add hl, sp
    rlca
    rlca
    inc bc
    ld [bc], a
    ccf
    ld a, $71
    ld [hl], c
    ret nc

    ld d, b
    di
    di
    ld d, a
    ld d, a
    ld e, h
    ld e, h
    ldh [hVramPtrLow], a
    ret nz

    ld b, b
    db $fc
    ld a, h
    adc [hl]
    adc [hl]
    db $eb
    adc d
    ld a, a
    ld a, a
    ld a, [bc]
    ld a, [bc]
    ld a, [hl-]
    ld a, [hl-]
    ld [hl], a
    ld [hl], a
    inc bc
    ld [bc], a
    rrca
    rrca
    inc e
    inc e
    rst $10
    ld d, c
    cp $fe
    sub b
    sub b
    sbc h
    sbc h
    xor $ee
    ret nz

    ld b, b
    ldh a, [hCurrentTile]
    jr c, ConstTable_002_4baa

    ld a, a
    ld a, h
    rra
    jr @+$31

    jr nz, UnknownCode_002_4bd8

    ld b, e
    ld e, l
    ld b, h
    rst $18
    rst $08
    ei
    adc b
    ld a, a
    ld a, a
    ld a, b
    ld hl, sp-$74
    ld a, h
    ldh a, [c]
    ld c, $fb
    add a
    db $fd
    inc bc
    db $fd
    add e
    ei
    rlca
    cp $fe
    rlca
    dec b
    ccf
    dec a
    ccf
    ld [hl+], a
    rra
    dec e
    ld l, $22
    ld e, a
    ld b, a
    ld e, l
    ld b, h
    ccf
    ccf
    cp b
    ld a, b
    call nz, $fa3c
    ld b, $fb
    rst $00

ConstTable_002_4baa:
    db $fd
    inc bc
    db $fd
    add e
    ei
    rlca
    cp $fe
    ccf
    ccf
    ld l, h
    ld h, e
    ld a, a
    ld a, a
    cp $82
    rst $38
    cp e
    cp $82
    rst $38
    add e
    ld a, a
    ld a, a
    jr c, DispatchEntry_002_4bfc

    xor $de
    ldh a, [c]
    adc $bd
    ld h, e
    db $fd
    db $e3
    cp l
    ld h, e
    db $fd
    db $e3
    cp $fe
    inc e
    inc e
    ld a, $3e
    cpl
    cpl

UnknownCode_002_4bd8:
    daa
    daa
    ld h, a
    ld h, a
    pop bc
    pop bc
    add b
    add b
    nop
    nop
    ld [hl], e
    ld [hl], e
    ld b, $06
    add hl, de
    jr PaddingZone_002_4c10

    jr nz, UnknownCode_002_4c69

    ld b, c
    ld a, l
    ld b, a
    ld a, [hl]
    ld d, [hl]
    ld a, b
    ld a, b
    jr c, PaddingZone_002_4c1c

    jr c, PaddingZone_002_4c1e

    jr c, PaddingZone_002_4c20

    cp $fe
    add d
    add d

DispatchEntry_002_4bfc:
    ld b, h
    ld b, h
    jr z, PaddingZone_002_4c28

    db $10
    stop
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

PaddingZone_002_4c10:
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

PaddingZone_002_4c1c:
    nop
    nop

PaddingZone_002_4c1e:
    nop
    nop

PaddingZone_002_4c20:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

PaddingZone_002_4c28:
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
    ld a, $3e
    ld b, a
    ld b, l
    and $a5
    and $a5
    cp $99
    db $fd
    jp $1c1c


    ld h, $26
    ld b, d
    ld b, d
    ld b, [hl]
    ld b, d
    sbc [hl]
    add d
    cp [hl]
    add [hl]
    cp h
    cp h
    ld h, b
    ld h, b
    nop
    nop
    ld a, $3e
    ld b, a
    ld b, l
    and $a5
    and $a5
    cp $99
    db $fd
    db $e3
    rra
    rla
    nop
    nop
    nop
    nop
    nop
    nop
    add b

UnknownCode_002_4c69:
    add b
    cp [hl]
    cp [hl]
    pop bc
    pop bc
    ld bc, $fb01
    jp RST_00


    ld a, $3e
    ld a, a
    ld a, a
    rst $38
    rst $20
    rst $38
    pop bc
    rst $38
    rst $20
    ld a, a
    ld a, a
    ld a, $3e
    nop
    nop
    nop
    nop
    add b
    add b
    ldh [hVramPtrLow], a
    ld hl, sp-$08
    ldh [hVramPtrLow], a
    ret nz

    ret nz

    nop
    nop
    rst $38
    rst $38
    ld b, l
    add e
    rst $38
    rst $38
    ld c, l
    add e
    rst $38
    cp $c3
    ld a, a
    call c, $bbe4
    ret z

    nop
    nop
    nop
    nop
    ldh [hVramPtrLow], a
    jr c, AudioDispatchEntry_4ce2

    db $ec
    inc c
    db $f4
    add h
    ld [hl], a
    rrca
    db $f4
    inc c
    ccf
    ccf
    ld a, a
    ld b, c
    cp $81
    cp $b1
    db $fc
    or e
    ld sp, hl
    add a
    rst $38
    add a
    ld a, c
    ld a, c
    nop
    nop
    add b
    add b
    add b
    add b
    add b
    add b
    cp $fe
    ld bc, $016d
    ld l, l
    cp $fe
    rst $38
    add c
    ld a, a
    ld a, l
    ld a, a
    ld b, c
    ccf
    ld hl, $9f9f
    ld a, [$73fa]
    ld [hl], e
    ld [bc], a
    ld [bc], a

AudioDispatchEntry_4ce2:
    rst $38
    rst $38
    ld b, l
    add e
    rst $38
    rst $38
    ld c, l
    add e
    cp $fe
    db $e3
    ld a, h
    rst $18
    pop hl
    cp [hl]
    add d
    nop
    nop
    nop
    nop
    nop
    nop
    ret nz

    ret nz

    jr nc, AudioDispatchEntry_4d2c

    jp hl


    add hl, bc
    rst $30
    rst $20
    inc de
    rra
    ld a, a
    ld a, a
    ld c, [hl]
    ld [hl], b
    ld a, a
    ld a, a
    ccf
    dec a
    ld d, a
    ld d, l
    ld d, a
    ld d, h
    rst $38
    ld hl, sp-$01
    add b
    ld hl, sp-$08
    inc h
    inc e
    db $fc
    db $fc
    ld a, [de]
    ld b, $fe
    cp $ed
    inc hl
    rst $38
    cp a
    push hl
    inc hl
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

AudioDispatchEntry_4d2c:
    nop
    nop
    nop
    nop
    nop
    nop
    rst $38
    add a
    ld a, e
    ld a, e
    inc bc
    inc bc
    dec h
    dec h
    ld l, b
    ld l, b
    sbc a
    sbc a
    ld l, b
    ld l, b
    jr nz, UnknownCode_002_4d62

    db $fc
    db $fc
    ld b, $2e
    ld [bc], a
    ld l, d
    add d
    jp z, $fcfc

    rst $38
    rst $38
    add h
    add h
    nop
    nop
    ld a, a
    ld a, a
    inc bc
    inc bc
    dec b
    dec b
    jr z, PaddingZone_002_4d82

    ld l, b
    ld l, b
    sbc a
    sbc a
    ld l, b
    ld l, b
    jr nz, PaddingZone_002_4d82

UnknownCode_002_4d62:
    inc a
    inc a
    ld [bc], a
    ld l, d
    add d
    jp z, $fcfc

    ld b, d
    ld b, d
    rst $38
    rst $38
    ld b, d
    ld b, d
    nop
    nop
    nop
    nop
    ld a, h
    ld a, h
    ei
    rst $00
    add h
    add e
    add d
    add c

PaddingZone_002_4d7c:
    ld a, c
    ld b, a
    ld a, $3e
    nop
    nop

PaddingZone_002_4d82:
    nop
    nop
    nop
    nop
    ldh [hVramPtrLow], a
    ld a, $fe
    jr nc, PaddingZone_002_4d7c

    ret nz

    ret nz

    nop
    nop
    nop
    nop
    cp e
    adc b
    ld a, a
    inc b
    db $db
    scf
    and [hl]
    ld a, [hl]
    ld a, b
    ld hl, sp-$7f
    add c
    ld bc, $0101
    ld bc, $0cf4
    or $4e
    ld a, [$7ac6]
    ld b, [hl]
    or $9e
    db $fc
    ld c, h
    ldh a, [$ff30]
    ldh [hVramPtrLow], a
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
    inc bc
    inc bc
    ld bc, $0201
    ld [bc], a
    dec a
    inc a
    ld h, e
    ld b, b
    cp $81
    db $fd
    xor e
    cp $fe
    cp l
    add h
    ld a, l
    inc b
    rst $18
    inc [hl]
    and [hl]
    ld a, e
    ld l, a
    rst $38
    cp a
    or b
    rra
    dec d
    rra
    rra
    ld a, [$fa0e]
    ld b, $fa
    ld b, $fa
    ld b, $7e
    add d
    db $fd
    inc bc
    ld sp, hl
    rlca
    cp $fe
    ccf
    ccf
    ld a, a
    ld a, a
    rst $38
    ret z

    rst $38
    add c
    rst $38
    sub b
    rst $38
    call nz, $ffff
    rst $38
    rst $38
    db $fc
    db $fc
    cp $fe
    rst $38
    daa
    rst $38
    inc bc
    rst $38
    inc de
    rst $38
    ld b, a
    rst $38
    rst $38
    rst $38
    rst $38
    cp $da
    rst $38
    adc c
    rst $38
    call Routine_DataProcess_B
    ld [hl], d
    ld d, d
    ld h, d
    ld h, d
    jr nz, ReturnFromInterrupt_002_4e50

    jr nz, UnknownCode_002_4e52

    ld a, $3e
    ld h, e
    ld h, e
    ld a, a
    ld a, a
    ld a, $3e
    ld [$6b08], sp
    ld l, e
    ld a, $3e
    inc e
    inc e
    inc a
    inc a
    ld l, d
    ld b, [hl]
    ld b, d
    ld a, [hl]
    inc a
    inc a
    jr UnknownCode_002_4e64

    rst $38
    rst $38
    reti


    add a

ReturnFromInterrupt_002_4e50:
    reti


    add a

UnknownCode_002_4e52:
    inc a
    inc a
    ld b, d
    ld a, [hl]
    sbc c
    rst $20
    and l
    jp $c3a5


    sbc c
    rst $20
    ld b, d
    ld a, [hl]
    inc a
    inc a
    nop
    nop

UnknownCode_002_4e64:
    inc a
    inc a
    ld h, [hl]
    ld h, [hl]
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld h, [hl]
    ld h, [hl]
    inc a
    inc a
    nop
    nop
    nop
    nop
    jr c, PaddingZone_002_4eae

    ld a, a
    ld a, a
    cp $e4
    rst $38
    or b
    rst $38
    add [hl]
    ld a, [hl]
    nop
    nop
    nop
    nop
    ld a, $1c
    ld e, l
    nop
    ld b, c
    nop
    ld a, $00
    ld [$6b00], sp
    nop
    ld a, $00
    inc e
    ld a, [hl]
    ld a, [hl]
    and l
    jp $ffff


    and l
    jp $ffff


    and l
    jp DataTable_665a


    inc a
    inc a
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
    rst $38

PaddingZone_002_4eae:
    nop
    rst $38
    nop
    rst $38
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
    rst $38
    nop
    rst $38
    nop
    rst $38
    nop
    jr AudioDispatchEntry_4edc

    jr AudioDispatchEntry_4ede

    jr c, UnknownCode_002_4f00

    ld hl, sp-$08
    ldh a, [hCurrentTile]
    nop
    nop
    nop
    nop
    nop
    nop
    ld a, [hl]
    ld a, [hl]
    add c
    rst $38
    add c
    rst $38
    add c
    rst $38
    add c
    rst $38

AudioDispatchEntry_4edc:
    add c
    rst $38

AudioDispatchEntry_4ede:
    add c
    rst $38
    ld a, [hl]
    ld a, [hl]
    rst $38
    rst $38
    ld de, $1111
    ld de, $1111
    ld de, $ff11
    ld de, $ff11
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    jp $c3ff


    ld a, [hl]
    ld a, [hl]
    rst $38
    rst $38
    rst $38
    jp $c3ff


UnknownCode_002_4f00:
    ld a, [hl]
    ld a, [hl]
    db $10
    db $10
    db $10
    db $10
    jr z, PaddingZone_002_4f30

    jr z, UnknownCode_002_4f32

    ld b, h
    ld b, h
    ld a, h
    ld b, h
    ld a, h
    ld b, h
    ld a, h
    ld a, h
    ld a, [hl]
    ld a, [hl]
    sbc a
    sbc a
    rst $38
    rst $38
    ld l, [hl]
    ld b, d
    ld l, [hl]
    ld b, d
    rst $38
    rst $38
    sbc a
    sbc a
    ld a, [hl]
    ld a, [hl]
    ld a, [hl]
    ld a, [hl]
    rst $38
    add e
    rst $38
    add e
    rst $38
    add a
    ld a, [hl]
    ld a, [hl]
    nop
    nop
    nop
    nop

PaddingZone_002_4f30:
    nop
    nop

UnknownCode_002_4f32:
    rrca
    rrca
    dec bc
    ld [$080b], sp
    dec bc
    ld [$181b], sp
    scf
    jr nc, Return_IfCarry_002_4f6e

    jr nz, UnknownCode_002_4f70

    daa
    ldh a, [hCurrentTile]
    or b
    ld [hl], b
    or b
    ld [hl], b
    or b
    ld [hl], b
    sbc b
    ld a, b
    call c, $cc3c
    inc a
    db $e4
    inc e
    ld l, $21
    inc h
    inc hl
    add hl, hl
    add hl, hl
    cpl
    ld h, $36
    ld sp, $1311
    ld c, $0e
    nop
    nop
    add h
    db $fc
    db $f4
    db $fc
    db $fc
    ld e, h
    ld a, h
    call nc, $b4dc
    inc h
    ld l, h

Return_IfCarry_002_4f6e:
    ret c

    ret c

UnknownCode_002_4f70:
    nop
    nop
    jr c, UnknownCode_002_4fac

    ld a, h
    ld b, h
    xor $82
    adc $8a
    adc $8a
    cp $92
    ld a, h
    ld b, h
    jr c, DispatchEntry_002_4fba

    nop
    nop
    nop
    nop
    nop
    nop
    rrca
    rrca
    rra
    rra
    inc e
    inc e
    jr UnknownCode_002_4fa8

    jr UnknownCode_002_4faa

    inc a
    inc a
    ld h, [hl]
    ld h, [hl]
    ld c, [hl]
    ld c, [hl]
    ld c, [hl]
    ld c, [hl]
    ld c, [hl]
    ld c, [hl]
    ld c, [hl]
    ld c, [hl]
    ld h, [hl]
    ld h, [hl]
    inc a
    inc a
    jr DispatchEntry_002_4fbc

    inc a
    inc b
    inc a
    inc b

UnknownCode_002_4fa8:
    inc a
    inc b

UnknownCode_002_4faa:
    inc a
    inc b

UnknownCode_002_4fac:
    inc a
    inc b
    inc a
    inc b
    jr UnknownCode_002_4fca

    jr UnknownCode_002_4fcc

    jr UnknownCode_002_4fce

    jr UnknownCode_002_4fd0

    jr PaddingZone_002_4fd2

DispatchEntry_002_4fba:
    jr PaddingZone_002_4fd4

DispatchEntry_002_4fbc:
    jr UnknownCode_002_4fd6

    jr DispatchEntry_002_4fd8

    jr PaddingZone_002_4fda

    nop
    nop
    nop
    nop
    ld a, $3e
    ld c, b
    ld c, c

UnknownCode_002_4fca:
    xor [hl]
    xor a

UnknownCode_002_4fcc:
    cp $ff

UnknownCode_002_4fce:
    ld a, [hl]
    ld a, a

UnknownCode_002_4fd0:
    ld a, $3e

PaddingZone_002_4fd2:
    nop
    nop

PaddingZone_002_4fd4:
    nop
    nop

UnknownCode_002_4fd6:
    add b
    add b

DispatchEntry_002_4fd8:
    jr PaddingZone_002_4ff2

PaddingZone_002_4fda:
    cp h
    cp h
    sbc b
    sbc b
    add b
    add b
    add b
    add b
    nop
    nop
    nop
    nop
    adc h
    adc h
    ld [de], a
    ld [de], a
    adc c
    adc c
    sub d
    sub d
    adc h
    adc h
    add b
    add b

PaddingZone_002_4ff2:
    nop
    nop
    nop
    nop
    nop
    nop
    ldh a, [hCurrentTile]
    ld hl, sp-$08
    jr c, DataVector_Handler_3

    jr DataVector_Handler_2

    jr PaddingZone_002_501a

    jp RST_24


    ld b, d
    nop
    add c
    nop
    nop
    nop
    nop
    jr PaddingZone_002_500e

PaddingZone_002_500e:
    inc a
    nop
    ld h, [hl]
    jr DataVector_Handler_1

DataVector_Handler_1:
    nop
    nop
    nop
    nop
    nop

DataVector_Handler_2:
    nop
    nop

PaddingZone_002_501a:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jr UnknownCode_002_503c

    jr UnknownCode_002_503e

    inc e
    inc e
    rra
    rra
    rrca
    rrca
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    inc a
    inc a

DataVector_Handler_3:
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]

UnknownCode_002_503c:
    ld h, [hl]
    ld h, [hl]

UnknownCode_002_503e:
    inc a
    inc a
    nop
    nop
    nop
    nop
    jr UnknownCode_002_505e

    jr c, DataVector_Handler_7

    jr DataVector_Handler_4

    jr DataVector_Handler_5

    jr DataVector_Handler_6

    inc a
    inc a
    nop
    nop
    nop
    nop
    inc a
    inc a
    ld c, [hl]
    ld c, [hl]
    ld c, $0e
    inc a
    inc a
    ld [hl], b
    ld [hl], b

UnknownCode_002_505e:
    ld a, [hl]
    ld a, [hl]
    nop
    nop

DataVector_Handler_4:
    nop
    nop

DataVector_Handler_5:
    ld a, h
    ld a, h

DataVector_Handler_6:
    ld c, $0e
    inc a
    inc a
    ld c, $0e
    ld c, $0e
    ld a, h
    ld a, h
    nop
    nop
    nop
    nop
    inc a
    inc a
    ld l, h
    ld l, h
    ld c, h
    ld c, h
    ld c, [hl]
    ld c, [hl]
    ld a, [hl]
    ld a, [hl]
    inc c
    inc c

DataVector_Handler_7:
    nop
    nop
    nop
    nop
    ld a, h
    ld a, h
    ld h, b
    ld h, b
    ld a, h
    ld a, h
    ld c, $0e
    ld c, [hl]
    ld c, [hl]
    inc a
    inc a
    nop
    nop
    nop
    nop
    inc a
    inc a
    ld h, b
    ld h, b
    ld a, h
    ld a, h
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    inc a
    inc a
    nop
    nop
    nop
    nop
    ld a, [hl]
    ld a, [hl]
    ld b, $06
    inc c
    inc c
    jr UnknownCode_002_50c4

    jr c, UnknownCode_002_50e6

    jr c, UnknownCode_002_50e8

    nop
    nop
    nop
    nop
    inc a
    inc a
    ld c, [hl]
    ld c, [hl]
    inc a
    inc a
    ld c, [hl]
    ld c, [hl]
    ld c, [hl]
    ld c, [hl]
    inc a
    inc a
    nop
    nop
    nop
    nop

UnknownCode_002_50c4:
    inc a
    inc a
    ld c, [hl]
    ld c, [hl]
    ld c, [hl]
    ld c, [hl]
    ld a, $3e
    ld c, $0e
    inc a
    inc a
    nop
    nop
    nop
    nop
    inc a
    inc a
    ld c, [hl]
    ld c, [hl]
    ld c, [hl]
    ld c, [hl]
    ld a, [hl]
    ld a, [hl]
    ld c, [hl]
    ld c, [hl]
    ld c, [hl]
    ld c, [hl]
    nop
    nop
    nop
    nop
    ld a, h
    ld a, h

UnknownCode_002_50e6:
    ld h, [hl]
    ld h, [hl]

UnknownCode_002_50e8:
    ld a, h
    ld a, h
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld a, h
    ld a, h
    nop
    nop
    nop
    nop
    inc a
    inc a
    ld h, [hl]
    ld h, [hl]
    ld h, b
    ld h, b
    ld h, b
    ld h, b
    ld h, [hl]
    ld h, [hl]
    inc a
    inc a
    nop
    nop
    nop
    nop
    ld a, h
    ld a, h
    ld c, [hl]
    ld c, [hl]
    ld c, [hl]
    ld c, [hl]
    ld c, [hl]
    ld c, [hl]
    ld c, [hl]
    ld c, [hl]
    ld a, h
    ld a, h
    nop
    nop
    nop
    nop
    ld a, [hl]
    ld a, [hl]
    ld h, b
    ld h, b
    ld a, h
    ld a, h
    ld h, b
    ld h, b
    ld h, b
    ld h, b
    ld a, [hl]
    ld a, [hl]
    nop
    nop
    nop
    nop
    ld a, [hl]
    ld a, [hl]
    ld h, b
    ld h, b
    ld h, b
    ld h, b
    ld a, h
    ld a, h
    ld h, b
    ld h, b
    ld h, b
    ld h, b
    nop
    nop
    nop
    nop
    inc a
    inc a
    ld h, [hl]
    ld h, [hl]
    ld h, b
    ld h, b
    ld l, [hl]
    ld l, [hl]
    ld h, [hl]
    ld h, [hl]
    ld a, $3e
    nop
    nop
    nop
    nop
    ld b, [hl]
    ld b, [hl]
    ld b, [hl]
    ld b, [hl]
    ld a, [hl]
    ld a, [hl]
    ld b, [hl]
    ld b, [hl]
    ld b, [hl]
    ld b, [hl]
    ld b, [hl]
    ld b, [hl]
    nop
    nop
    nop
    nop
    inc a
    inc a
    jr ConstTableB_Entry1

    jr ConstTableB_Entry2

    jr ConstTableB_Entry3

    jr ConstTableB_Entry4

    inc a
    inc a
    nop
    nop
    rst $38
    rst $38
    ldh [hVramPtrLow], a
    rst $08
    ret nz

    sbc b
    add a
    or a
    adc a
    xor a
    sbc a
    xor a
    sbc a

ConstTableB_Entry1:
    xor a
    sbc a

ConstTableB_Entry2:
    nop
    nop

ConstTableB_Entry3:
    ld h, [hl]
    ld h, [hl]

ConstTableB_Entry4:
    ld l, h
    ld l, h
    ld a, b
    ld a, b
    ld a, b
    ld a, b
    ld l, h
    ld l, h
    ld h, [hl]
    ld h, [hl]
    nop
    nop
    nop
    nop
    ld h, b
    ld h, b
    ld h, b
    ld h, b
    ld h, b
    ld h, b
    ld h, b
    ld h, b
    ld h, b
    ld h, b
    ld a, [hl]
    ld a, [hl]
    nop
    nop
    nop
    nop
    ld b, [hl]
    ld b, [hl]
    ld l, [hl]
    ld l, [hl]
    ld a, [hl]
    ld a, [hl]
    ld d, [hl]
    ld d, [hl]
    ld b, [hl]
    ld b, [hl]
    ld b, [hl]
    ld b, [hl]
    nop
    nop
    nop
    nop
    ld b, [hl]
    ld b, [hl]
    ld h, [hl]
    ld h, [hl]
    halt
    halt
    ld e, [hl]
    ld e, [hl]
    ld c, [hl]
    ld c, [hl]
    ld b, [hl]
    ld b, [hl]
    nop
    nop
    nop
    nop
    inc a
    inc a
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    inc a
    inc a
    nop
    nop
    nop
    nop
    ld a, h
    ld a, h
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld a, h
    ld a, h
    ld h, b
    ld h, b
    ld h, b
    ld h, b
    nop
    nop
    nop
    nop
    inc a
    inc a
    ld h, d
    ld h, d
    ld h, d
    ld h, d
    ld l, d
    ld l, d
    ld h, h
    ld h, h
    ld a, [hl-]
    ld a, [hl-]
    nop
    nop
    nop
    nop
    ld a, h
    ld a, h
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld a, h
    ld a, h
    ld l, b
    ld l, b
    ld h, [hl]
    ld h, [hl]
    nop
    nop
    nop
    nop
    inc a
    inc a
    ld h, b
    ld h, b
    inc a
    inc a
    ld c, $0e
    ld c, [hl]
    ld c, [hl]
    inc a
    inc a
    nop
    nop
    nop
    nop
    ld a, [hl]
    ld a, [hl]
    jr ControlFlow_Target_1

    jr ControlFlow_Target_2

    jr ControlFlow_Target_3

    jr ControlFlow_Target_4

    jr ControlFlow_Target_5

    nop
    nop
    nop
    nop
    ld b, [hl]
    ld b, [hl]
    ld b, [hl]
    ld b, [hl]
    ld b, [hl]
    ld b, [hl]
    ld b, [hl]
    ld b, [hl]
    ld c, [hl]
    ld c, [hl]
    inc a
    inc a

ControlFlow_Target_1:
    nop
    nop

ControlFlow_Target_2:
    nop
    nop

ControlFlow_Target_3:
    ld b, [hl]
    ld b, [hl]

ControlFlow_Target_4:
    ld b, [hl]
    ld b, [hl]

ControlFlow_Target_5:
    ld b, [hl]
    ld b, [hl]
    ld b, [hl]
    ld b, [hl]
    inc l
    inc l
    jr ControlFlow_Target_6

    nop
    nop
    nop
    nop
    ld b, [hl]
    ld b, [hl]
    ld b, [hl]
    ld b, [hl]
    ld d, [hl]
    ld d, [hl]
    ld a, [hl]
    ld a, [hl]
    ld l, [hl]
    ld l, [hl]
    ld b, [hl]
    ld b, [hl]
    nop
    nop
    rst $38
    rst $38
    rlca
    rrca
    ei
    rlca

ControlFlow_Target_6:
    dec c
    di
    db $fd
    ei
    db $fd
    ei
    db $fd
    ei
    db $fd
    ei
    nop
    nop
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    inc a
    inc a
    jr ControlFlow_Target_7

    jr ControlFlow_Target_8

    jr ControlFlow_Target_9

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
    jr nc, ConstTable_002_529e

    jr nc, DispatchEntry_002_52a0

    nop
    nop
    xor a
    sbc a

ControlFlow_Target_7:
    xor a
    sbc a

ControlFlow_Target_8:
    xor a
    sbc a

ControlFlow_Target_9:
    xor a
    sbc a
    xor a
    sbc a
    xor a
    sbc a
    xor a
    sbc a
    cp a
    add b
    nop
    nop
    nop
    nop
    jr nc, UnknownCode_002_52b8

    jr nc, UnknownCode_002_52ba

    nop
    nop
    jr nc, UnknownCode_002_52be

    jr nc, PaddingZone_002_52c0

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
    jr nc, PaddingZone_002_52cc

    jr nc, UnknownCode_002_52ce

ConstTable_002_529e:
    db $10
    db $10

DispatchEntry_002_52a0:
    jr nz, PaddingZone_002_52c2

    nop
    nop
    ld a, [hl]
    ld a, [hl]
    ld c, $0e
    inc e
    inc e
    jr c, JoypadInputEntry_52e4

    ld [hl], b
    ld [hl], b
    ld a, [hl]
    ld a, [hl]
    nop
    nop
    nop
    nop
    inc e
    inc e
    inc e
    inc e

UnknownCode_002_52b8:
    inc e
    inc e

UnknownCode_002_52ba:
    inc e
    inc e
    nop
    nop

UnknownCode_002_52be:
    inc e
    inc e

PaddingZone_002_52c0:
    nop
    nop

PaddingZone_002_52c2:
    nop
    nop
    nop
    nop
    nop
    nop
    inc a
    inc a
    inc a
    inc a

PaddingZone_002_52cc:
    nop
    nop

UnknownCode_002_52ce:
    nop
    nop
    nop
    nop
    jr c, AudioDispatchEntry_530c

    ld a, h
    ld b, h
    xor $82
    adc $8a
    adc $8a
    cp $92
    ld a, h
    ld b, h
    jr c, @+$3a

    nop
    nop

JoypadInputEntry_52e4:
    nop
    nop
    ld b, h
    ld b, h
    jr z, AudioDispatchEntry_5312

    db $10
    db $10
    jr z, @+$2a

    ld b, h
    ld b, h
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
    rst $28
    rst $28
    db $10
    db $10
    db $10
    rst $30
    db $10
    rst $30
    rst $38
    rst $38

AudioDispatchEntry_530c:
    rst $38
    rst $38
    nop
    nop
    nop
    nop

AudioDispatchEntry_5312:
    ld a, [hl]
    ld a, h
    rst $38
    cp $ff
    add d
    jp $ff82


    cp $ff
    cp $c3
    add d
    jp $ff82


    cp $ff
    cp $c3
    add d
    jp $ff82


    cp $ff
    cp $c3
    add d
    jp $ef82


    rst $28
    db $10
    db $10
    db $10
    rst $30
    db $10
    rst $30
    rst $38
    rst $38
    rst $38
    rst $38
    nop
    nop
    nop
    nop
    ld bc, $0101
    ld bc, $0101
    ld bc, $0101
    ld bc, $0101
    ld bc, $0101
    ld bc, $1c1c
    ld [hl+], a
    ld [hl+], a
    ld c, a
    ld c, a
    ld c, e
    ld c, e
    ld de, $1111
    ld de, $0101
    ld bc, $7001
    ld [hl], b
    adc b
    adc b
    call nz, StoreAudioState
    inc h
    db $10
    db $10
    db $10

AudioDataDispatchStart:
    stop
    nop
    nop
    nop
    ld bc, $0301
    inc bc
    dec b

AudioDataDispatchJump1:
    dec b
    add hl, bc
    add hl, bc
    ld de, $2111
    ld hl, $4141
    add c
    add c
    nop
    ld a, h
    nop
    ld b, h
    nop
    ld d, h
    nop
    jr z, AudioDataDispatchChain1

AudioDataDispatchChain1:
    jr z, AudioDataDispatchChain2

AudioDataDispatchChain2:
    jr z, AudioDataDispatchChain3

AudioDataDispatchChain3:
    jr c, AudioDataDispatchChain4

AudioDataDispatchChain4:
    nop
    ld bc, $0201
    ld [bc], a
    inc b
    inc b
    ld [$1008], sp
    db $10
    jr nz, AudioDataDispatchJump2

    ld b, b
    ld b, b
    add b
    add b
    nop
    ld a, [hl]
    jr c, AudioDataDispatchStart

    ld a, h
    add e
    ld a, h
    add e
    ld a, h
    add e
    ld a, h
    add e
    jr c, AudioDataDispatchJump1

    nop
    ld a, [hl]
    nop
    nop
    db $10
    db $10
    jr c, UnknownCode_002_53f0

    ld a, h
    ld a, h
    nop
    nop
    db $10
    db $10

AudioDataDispatchJump2:
    jr c, @+$3a

    ld a, h
    ld a, h
    db $fd
    ei
    db $fd
    ei
    db $fd
    ei
    db $fd
    ei
    db $fd
    ei
    db $fd
    ei
    db $fd
    ei
    db $fd
    inc bc
    ld bc, $0601
    ld b, $0a
    ld a, [bc]
    inc c
    inc c
    jr nc, @+$32

    ld d, b
    ld d, b
    ld h, b
    ld h, b
    add b
    add b
    nop
    nop
    nop
    nop
    ld [$1800], sp
    nop
    inc h
    nop
    ld b, h
    nop
    sub d
    nop

UnknownCode_002_53f0:
    add hl, sp
    nop
    add c
    add c
    ld b, c
    ld b, c
    ld hl, $1121
    ld de, $0909
    dec b
    dec b
    inc bc
    inc bc
    ld bc, $ff01
    rst $38
    ld bc, $0101
    ld bc, $0101
    ld bc, $0101
    ld bc, $0101
    ld bc, $8001
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    rst $38
    rst $38
    ccf
    ccf
    ld a, a
    ld a, a
    rst $38
    ret z

    rst $38
    add c
    rst $38
    sub b
    rst $38
    call nz, $ffff
    rst $38
    rst $38
    rst $38
    nop
    nop
    nop
    rst $38
    nop
    nop
    nop
    rst $38
    nop
    nop
    nop
    rst $38
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    inc bc
    inc bc
    inc c
    inc c
    db $10
    db $10
    jr nz, UnknownCode_002_546e

    jr nz, UnknownCode_002_5470

    ld b, b
    ld b, b
    nop
    nop
    nop
    nop
    add b
    add b
    ld b, b
    ld b, b
    inc h
    inc h
    ld a, [de]
    ld a, [de]
    ld bc, $0601
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

PaddingZone_002_5469:
    nop
    nop
    nop
    nop
    nop

UnknownCode_002_546e:
    add b
    add b

UnknownCode_002_5470:
    ld b, b
    ld b, b
    ld bc, $0201
    ld [bc], a
    inc b
    inc b
    rrca
    ld [$0407], sp
    inc bc
    ld [bc], a
    ld bc, $0001
    nop
    add b
    add b
    nop
    nop
    pop bc

AudioDispatchEntry_5487:
    nop
    rst $30
    nop
    rst $38
    nop
    rst $38
    ld b, b
    rst $38
    db $e3
    ld a, $3e
    inc de
    nop
    sbc c
    nop
    pop bc
    nop
    db $e3
    nop
    rst $38
    nop
    rst $38
    add b
    ld a, a
    ld b, c
    ld a, $3e
    ld b, b
    ld b, b
    and b
    jr nz, AudioDispatchEntry_5487

    jr nz, PaddingZone_002_5469

    ld b, b
    ret nz

    ld b, b
    add b
    add b
    nop
    nop
    nop
    nop
    rrca
    rrca
    ld [de], a
    ld [de], a
    ld a, $3e
    ld [hl+], a
    ld [hl+], a
    ld e, e
    ld e, e
    ld b, c
    ld b, c
    ld h, c
    ld h, c
    inc hl
    inc hl
    ret nz

    ret nz

    ld h, b
    ld h, b
    jr nz, AudioDispatchEntry_54e8

    jr nc, AudioDispatchEntry_54fa

    db $10
    db $10
    db $10
    db $10
    db $10
    db $10
    ldh a, [hCurrentTile]
    ld a, $3e
    inc b
    inc b
    ld c, $0e
    db $10
    db $10
    ld a, $3e
    ret nz

    ret nz

    xor b
    xor b
    rst $38
    rst $38
    ld [$0708], sp
    rlca
    nop
    nop

AudioDispatchEntry_54e8:
    nop
    nop
    rlca
    rlca
    jr AudioDispatchEntry_5506

    ld [de], a
    ld [de], a
    rst $38
    rst $38
    nop
    nop
    ldh a, [hCurrentTile]
    inc c
    inc c
    ld [bc], a
    ld [bc], a

AudioDispatchEntry_54fa:
    add c
    add c
    ld bc, $4101
    ld b, c
    cp $fe
    rst $38
    rst $38
    rst $38
    rst $38

AudioDispatchEntry_5506:
    rst $38
    ret z

    rst $38
    add c
    rst $38
    sub b
    rst $38
    call nz, $ffff
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    daa
    rst $38
    inc bc
    rst $38
    inc de
    rst $38
    ld b, a
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    add b
    rst $38
    rst $38
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
    ld bc, $0101
    ld bc, $0101
    ld bc, $0101
    ld bc, $0101
    ld bc, $0101
    ld bc, $00ff
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
    rst $38
    nop
    rst $38
    nop
    db $fc
    db $fc
    cp $fe
    rst $38
    daa
    rst $38
    inc bc
    rst $38
    inc de
    rst $38
    ld b, a
    rst $38
    rst $38
    rst $38
    rst $38
    nop
    nop
    jr UnknownCode_002_559e

    inc h
    inc h
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    inc h
    inc h
    jr UnknownCode_002_55a8

    nop
    nop
    nop

AudioDispatchEntry_5593:
    nop
    rst $38
    rst $38
    add c
    add c
    ld b, d
    ld b, d
    inc a
    inc a
    nop
    nop

UnknownCode_002_559e:
    xor d
    xor d
    ld d, l
    ld d, l
    ld h, d
    ld h, d
    sbc a
    sbc a
    ld h, d
    ld h, d

UnknownCode_002_55a8:
    nop
    nop
    ld a, [hl]
    ld a, [hl]
    add c
    add c
    ld a, [hl]
    ld a, [hl]
    nop
    nop
    or $f6
    sub l
    sub l
    or $f6
    nop
    nop
    ld a, h
    ld a, h
    or d
    or d
    or a
    or a
    ld a, h
    ld a, h
    nop
    nop
    ld b, e
    ld b, e
    ld b, l
    ld b, l
    ld c, a
    ld c, a
    ld c, c
    ld c, c
    ld b, c
    ld b, c
    ld a, a
    ld a, a
    ld e, a
    ld e, a
    nop
    nop
    ldh [c], a
    ldh [c], a
    ld [de], a
    ld [de], a
    sub a
    sub a
    sub l
    sub l
    push af
    push af
    dec h
    dec h
    and a
    and a
    ld b, d
    ld b, d
    ld b, d
    ld b, d
    ld b, d
    ld b, d
    ld b, e
    ld b, e
    ld b, c
    ld b, c
    ld b, c
    ld b, c
    ld b, c
    ld b, c
    ld b, e
    ld b, e
    jr nz, DataPatch_2

    jr nz, DataPatch_3

    ld l, a
    ld l, a
    jp hl


    jp hl


    ld b, [hl]
    ld b, [hl]
    ld b, [hl]
    ld b, [hl]
    ld c, c
    ld c, c
    rst $08
    rst $08
    nop
    nop
    nop
    stop
    jr c, DataPatch_1

DataPatch_1:
    jr c, JoypadInputEntry_560b

JoypadInputEntry_560b:
    ld a, h
    nop
    ld l, h
    nop
    ld l, h
    nop
    jr c, AudioDispatchEntry_5593

    add b

DataPatch_2:
    ld b, b
    ld b, b

DataPatch_3:
    jr nz, DataPatch_4

    db $10
    db $10
    ld [$0408], sp
    inc b
    ld [bc], a
    ld [bc], a
    ld bc, $0001
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
    rst $38
    rst $38
    nop
    nop
    rst $38
    rst $38

DataPatch_4:
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    ld [$40ff], sp
    rst $38
    ld de, $00ff
    rst $38
    nop
    rst $38
    rst $38
    nop
    rst $38
    rst $38
    rst $38
    nop
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    ld a, [hl]
    ld a, [hl]
    rst $38
    add e
    rst $38
    cp e
    rst $38
    and e
    rst $38
    and e
    rst $38
    add a
    rst $38
    rst $38
    ld a, [hl]
    ld a, [hl]
    ld a, [hl]
    ld a, [hl]
    add e
    add e
    sbc a
    sbc a
    sbc a
    sbc a
    sbc a
    sbc a
    rst $38
    rst $38
    rst $38
    rst $38
    ld a, [hl]
    ld a, [hl]
    rst $38
    rst $38
    rst $38
    ld [hl+], a
    rst $38
    ld [hl+], a
    rst $38
    ld [hl+], a
    rst $38
    rst $38
    rst $38
    adc b
    rst $38
    adc b
    rst $38
    adc b
    ccf
    ccf
    ld a, a
    ld a, a
    rst $38
    ret z

    rst $38
    add c
    rst $38
    sub b
    rst $38
    call nz, $ffff
    rst $38
    rst $38
    db $fc
    db $fc
    cp $fe
    rst $38
    daa
    rst $38
    inc bc
    rst $38
    inc de
    rst $38
    ld b, a
    rst $38
    rst $38
    rst $38
    rst $38
    ld a, $3e
    ld h, e
    ld h, e
    pop bc
    pop bc
    add c
    add c
    add e
    add e
    add e
    add e
    rst $28
    rst $28
    ld a, a
    ld a, a
    ccf
    ccf
    ld a, a
    ld a, a
    rst $38
    rst $38
    rst $38
    rst $38
    rst $30
    rst $30
    push de
    push de
    ld d, l
    ld d, l
    ld d, c
    ld d, c
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    ld [hl], a
    ld [hl], a
    ld d, l
    ld d, l
    ld d, l
    ld d, l
    ld de, $fc11
    db $fc
    cp $fe
    rst $38
    rst $38
    rst $38
    rst $38
    ld [hl], a
    ld [hl], a
    ld d, l
    ld d, l
    ld d, l
    ld d, l
    inc d
    inc d
    rst $38
    rst $38
    rst $38
    sbc c
    rst $38
    sbc c
    rst $38
    sbc c
    rst $38
    rst $38
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
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    ret z

    rst $38
    add c
    rst $38
    sub b
    rst $38
    call nz, $ffff
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    daa
    rst $38
    inc bc
    rst $38
    inc de
    rst $38
    ld b, a
    rst $38
    rst $38
    rst $38
    rst $38
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
    ld a, a
    ld b, b
    ld a, a
    ld b, b
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
    and $1e
    and $1e
    ld a, a
    ld b, b
    ld a, a
    ld b, b
    ld a, a
    ld b, b
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
    and $1e
    and $1e
    and $1e
    and $1e
    db $fc
    db $fc
    and $1e
    and $1e
    and $1e
    db $fd
    db $fd
    rst $38
    add [hl]
    rst $38

Routine_DataProcess_B:
    add h
    rst $38
    add h
    rst $38
    add h
    rst $38
    add h
    rst $38
    add h
    rst $38
    add h
    rst $30
    rst $30
    rst $38
    ld [$08ff], sp
    rst $38
    ld [$08ff], sp
    rst $38
    ld [$08ff], sp
    rst $38
    ld [wGameVarFF], sp
    rst $38
    ld h, b
    rst $38
    jr nc, @+$01

    db $10
    rst $38
    rra
    rst $38
    jr @+$01

    jr @+$01

    jr @+$01

    add h
    rst $38
    add h
    rst $38
    add h
    add a
    db $fc
    add h
    rst $38
    db $fc
    rst $38
    rst $38
    rst $38
    db $fd
    db $fd
    rst $38
    ld [$08ff], sp
    rst $38
    ld [$08ff], sp
    ld [$08ff], sp
    rst $38
    rst $38
    rst $38
    rst $30
    rst $30
    rst $38
    jr @+$01

    jr @+$01

    jr @+$01

    jr PaddingZone_002_580a

    rst $38
    ld a, a
    ldh a, [rIE]
    ldh [rIE], a
    ret nz

    cp a
    cp a
    rst $38
    ld h, c
    rst $38
    ld hl, $21ff
    rst $38
    ld hl, $21ff
    rst $38
    ld hl, $21ff
    rst $38
    ld hl, $21ff
    rst $38
    ld hl, $3fe1
    ld hl, $3fff
    rst $38
    rst $38
    rst $38
    cp a
    cp a
    ld h, [hl]
    ld h, [hl]
    rst $38
    sbc c
    rst $38
    sbc c
    rst $38
    sbc c
    rst $38
    sbc c
    rst $38
    sbc c
    rst $38
    sbc c
    ld h, [hl]
    ld h, [hl]
    rst $38
    rst $38
    nop
    nop
    rst $38
    rst $38
    rst $38
    nop

PaddingZone_002_580a:
    nop
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    ld de, $1111
    ld de, $1111
    ld de, $ff11
    ld de, $ff11
    rst $38
    rst $38
    ld a, [hl]
    ld a, [hl]
    add c
    rst $38
    add c
    rst $38
    add c
    rst $38
    add c
    rst $38
    add c
    rst $38
    add c
    rst $38
    ld a, [hl]
    ld a, [hl]
    jp ComputeAnimationSpeed


    jp SpriteAnimationState_CheckAndUpdate


    jp SpriteAnimationState_CheckActiveFlag


    jp SpriteAnimationState_LoadTileIndex


    jp SpriteAnimationState_ValidateAndLoad


    jp SpriteAnimationState_LoadPalette


    call DecrementGameTimer
    call UpdateSpriteAnimationFrame
    ret


DecrementGameTimer:
    ld a, [$da1d]
    cp $03
    ret z

    ld hl, $da00
    ld a, [hl]
    dec a
    ld [hl], a
    ret nz

    ld a, $28
    ld [hl], a
    inc hl
    ld a, [hl+]
    ld c, [hl]
    dec hl
    sub $01
    daa
    ld [hl+], a
    cp $99
    jr nz, CounterStateDispatcher

    dec c
    ld a, c
    ld [hl], a
    ret


CounterStateDispatcher:
    ld hl, $da1d
    cp $50
    jr z, SetTimerForSpecialCase

    and a
    ret nz

    or c
    jr nz, SetTimerForAlternateCase

    ld a, $03
    ld [hl], a
    ret


SetTimerForSpecialCase:
    ld a, c
    and a
    ret nz

    ld a, $02
    ld [hl], a
    ld a, $50
    ldh [rTMA], a
    ret


SetTimerForAlternateCase:
    ld a, c
    cp $01
    ret nz

    ld a, $01
    ld [hl], a
    ld a, $30
    ldh [rTMA], a
    ret


UpdateSpriteAnimationFrame:
    ldh a, [hPtrBank]
    ld b, a
    and a
    jp z, ProcessSpriteAnimation

    ld a, [$da0b]
    ld l, a
    ld h, $c0
    ld de, $0008
    push hl
    add hl, de
    ld a, l
    ld [$da0b], a
    cp $50
    jr nz, UnknownCode_002_58b1

    ld a, $30
    ld [$da0b], a

UnknownCode_002_58b1:
    pop hl
    ld c, $20
    ld d, $f6
    ld a, l
    cp $30
    jr nz, DispatchEntry_002_58cd

    ld a, c
    ld [$da03], a
    ld a, d
    ld [$da07], a
    ld a, b
    cp $c0
    jr nz, AnimationDispatch_SelectHandler

    ld [$da0c], a
    jr AnimationDispatch_SelectHandler

DispatchEntry_002_58cd:
    cp $38
    jr nz, DispatchEntry_002_58e3

    ld a, c
    ld [$da04], a
    ld a, d
    ld [$da08], a
    ld a, b
    cp $c0
    jr nz, AnimationDispatch_SelectHandler

    ld [$da0d], a
    jr AnimationDispatch_SelectHandler

DispatchEntry_002_58e3:
    cp $40
    jr nz, UnknownCode_002_58f9

    ld a, c
    ld [$da05], a
    ld a, d
    ld [$da09], a
    ld a, b
    cp $c0
    jr nz, AnimationDispatch_SelectHandler

    ld [$da0e], a
    jr AnimationDispatch_SelectHandler

UnknownCode_002_58f9:
    ld a, c
    ld [$da06], a
    ld a, d
    ld [$da0a], a
    ld a, b
    cp $c0
    jr nz, AnimationDispatch_SelectHandler

    ld [$da0f], a

AnimationDispatch_SelectHandler:
    ldh a, [hPtrHigh]
    ld [hl+], a
    ldh a, [hPtrLow]
    ld [hl+], a
    ld a, b
    ld de, $5958
    cp $01
    jr z, AnimationDispatch_SetAndJump

    inc d
    cp $02
    jr z, AnimationDispatch_SetAndJump

    inc d
    cp $04
    jr z, AnimationDispatch_SetAndJump

    inc d
    cp $05
    jr z, AnimationDispatch_SetAndJump

    inc d
    cp $08
    jr z, AnimationDispatch_SetAndJump

    ld d, $59
    dec e
    cp $10
    jr z, AnimationDispatch_SetAndJump

    inc d
    cp $20
    jr z, AnimationDispatch_SetAndJump

    inc d
    cp $40
    jr z, AnimationDispatch_SetAndJump

    inc d
    cp $50
    jr z, AnimationDispatch_SetAndJump

    inc d
    cp $80
    jr z, AnimationDispatch_SetAndJump

    inc d
    ld e, $5f
    cp $ff
    jr z, AnimationDispatch_SetAndJump

    ld de, $f6fe

AnimationDispatch_SetAndJump:
    ld a, d
    ld [hl+], a
    inc hl
    ldh a, [hPtrHigh]
    ld [hl+], a
    ldh a, [hPtrLow]
    add $08
    ld [hl+], a
    ld a, e
    ld [hl], a
    xor a
    ldh [hPtrBank], a
    ldh [hPtrHigh], a
    ldh [hPtrLow], a
    ld a, b
    ld de, $0100
    cp $01
    jr z, AnimationDispatch_SelectPalette

    inc d
    cp $02
    jr z, AnimationDispatch_SelectPalette

    inc d
    inc d
    cp $04
    jr z, AnimationDispatch_SelectPalette

    inc d
    cp $05
    jr z, AnimationDispatch_SelectPalette

    ld d, $08
    cp $08
    jr z, AnimationDispatch_SelectPalette

    ld d, $10
    cp $10
    jr z, AnimationDispatch_SelectPalette

    ld d, $20
    cp $20
    jr z, AnimationDispatch_SelectPalette

    ld d, $40
    cp $40
    jr z, AnimationDispatch_SelectPalette

    ld d, $50
    cp $50
    jr z, AnimationDispatch_SelectPalette

    ld d, $80
    cp $80
    jr z, AnimationDispatch_SelectPalette

    jr UnknownCode_002_59a5

AnimationDispatch_SelectPalette:
    call AddScore

ProcessSpriteAnimation:
UnknownCode_002_59a5:
    ld hl, $c030

SpriteAnimationDispatch_ByType:
    push hl
    ld a, [hl]
    and a
    jp z, ExitSpriteHandler

    ld a, l
    ld bc, $da06
    ld de, $da0a
    ld hl, $da13
    cp $48
    jr z, UnknownCode_002_5a05

    dec c
    dec e
    dec l
    cp $40
    jr z, UnknownCode_002_59f3

    dec c
    dec e
    dec l
    cp $38
    jr z, DispatchEntry_002_59e0

    dec c
    dec e
    dec l
    ld a, [$da0c]
    cp $c0
    jr z, UnknownCode_002_5a15

    ld a, [hl]
    inc a
    ld [hl], a
    cp $02
    jp nz, ExitSpriteHandler

    xor a
    ld [hl], a
    jr UnknownCode_002_5a15

DispatchEntry_002_59e0:
    ld a, [$da0d]
    cp $c0
    jr z, UnknownCode_002_5a15

    ld a, [hl]
    inc a
    ld [hl], a
    cp $02
    jp nz, ExitSpriteHandler

    xor a
    ld [hl], a
    jr UnknownCode_002_5a15

UnknownCode_002_59f3:
    ld a, [$da0e]
    cp $c0
    jr z, UnknownCode_002_5a15

    ld a, [hl]
    inc a
    ld [hl], a
    cp $02
    jr nz, UnknownCode_002_5a66

    xor a
    ld [hl], a
    jr UnknownCode_002_5a15

UnknownCode_002_5a05:
    ld a, [$da0f]
    cp $c0
    jr z, UnknownCode_002_5a15

    ld a, [hl]
    inc a
    ld [hl], a
    cp $02
    jr nz, UnknownCode_002_5a66

    xor a
    ld [hl], a

UnknownCode_002_5a15:
    pop hl
    push hl
    dec [hl]
    inc l
    inc l
    inc l
    inc l
    dec [hl]
    dec l
    dec l
    ld a, [hl]
    cp $f6
    jr c, UnknownCode_002_5a37

    ld a, [de]
    inc a
    ld [de], a
    ld [hl], a
    cp $f9
    jr c, UnknownCode_002_5a37

    dec a
    dec a
    ld [hl], a
    cp $f7
    jr z, UnknownCode_002_5a37

    dec a
    dec a
    ld [de], a
    ld [hl], a

UnknownCode_002_5a37:
    ld a, [bc]
    dec a
    ld [bc], a
    jr nz, UnknownCode_002_5a66

    ld a, $20
    ld [bc], a
    ld a, $f6
    ld [de], a
    xor a
    ld [hl-], a
    ld [hl-], a
    ld [hl+], a
    inc l
    inc l
    inc l
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ld a, l
    ld hl, $da0c
    ld bc, $0004
    cp $36
    jr z, UnknownCode_002_5a62

    inc l
    cp $3e
    jr z, UnknownCode_002_5a62

    inc l
    cp $46
    jr z, UnknownCode_002_5a62

    inc l

UnknownCode_002_5a62:
    xor a
    ld [hl], a
    add hl, bc
    ld [hl], a

ExitSpriteHandler:
UnknownCode_002_5a66:
    pop hl
    ld de, $0008
    add hl, de
    ld a, l
    cp $50
    jp nz, SpriteAnimationDispatch_ByType

    ret


ComputeAnimationSpeed:
    ld hl, $c030
    ldh a, [rDIV]
    and $03
    inc a
    ld b, a
    ld a, $20

.frequencyCalculationLoop:
    add $18
    dec b
    jr nz, .frequencyCalculationLoop

    ld b, a
    ld [hl+], a
    ld a, $10
    ld c, a
    ld [hl+], a
    xor a
    ld d, a
    ldh a, [hTimerAux]
    cp $02
    jr nz, UnknownCode_002_5a93

    ld a, $20
    ld d, a

UnknownCode_002_5a93:
    ld a, d
    ld [hl+], a
    inc l
    ld a, b
    ld [hl+], a
    ld a, c
    add $08
    ld [hl+], a
    ld a, d
    inc a
    ld [hl+], a
    inc l
    ld a, b
    add $08
    ld b, a
    ld [hl+], a
    ld a, c
    ld [hl+], a
    ld a, d
    add $10
    ld d, a
    ld [hl+], a
    inc l
    ld a, b
    ld [hl+], a
    ld a, c
    add $08
    ld [hl+], a
    inc d
    ld a, d
    ld [hl], a
    ld a, $15
    ldh [hGameState], a
    ret


SpriteAnimationState_CheckAndUpdate:
    ld a, [$da27]
    bit 0, a
    jr z, UnknownCode_002_5ac9

    ldh a, [hJoypadState]
    bit 0, a
    jp nz, SpriteAnimationState_ResetCounter

UnknownCode_002_5ac9:
    ld hl, $da22
    ld a, [hl]
    inc a
    ld [hl], a
    cp $03
    ret nz

    xor a
    ld [hl], a
    ld a, [$da27]
    bit 0, a
    jr z, UnknownCode_002_5b07

    ld hl, $c030
    ld b, $04
    ld a, [hl]
    cp $80
    jr z, UnknownCode_002_5af1

UpdateSpritePositionLoop:
    ld a, $18
    add [hl]
    ld [hl+], a
    inc l
    inc l
    inc l
    dec b
    jr nz, UpdateSpritePositionLoop

    jr UnknownCode_002_5b07

UnknownCode_002_5af1:
    ld b, $02
    ld a, $38

WriteAnimationValueLoop:
    ld [hl+], a
    inc l
    inc l
    inc l
    dec b
    jr nz, WriteAnimationValueLoop

    ld b, $02
    ld a, $40

ResetSpriteAnimationLoop:
    ld [hl+], a
    inc l
    inc l
    inc l
    dec b
    jr nz, ResetSpriteAnimationLoop

UnknownCode_002_5b07:
    ld hl, $98ea
    ld bc, $0060
    ld de, $da27
    ld a, [de]
    inc a
    ld [de], a
    cp $03
    jr c, UnknownCode_002_5b27

    add hl, bc
    cp $05
    jr c, UnknownCode_002_5b27

    add hl, bc
    cp $07
    jr c, UnknownCode_002_5b27

    ld hl, $98ea
    xor a
    inc a
    ld [de], a

UnknownCode_002_5b27:
    ld a, h
    ld [$da18], a
    ld a, l
    ld [$da19], a
    ld hl, $da23
    ld a, [de]
    bit 0, a
    jr z, UnknownCode_002_5b45

    ld a, $2e
    ld [hl+], a
    ld a, $2f
    ld [hl+], a
    ld a, $2f
    ld [hl+], a
    ld a, $30
    ld [hl], a
    jr UnknownCode_002_5b51

UnknownCode_002_5b45:
    ld a, $2d
    ld [hl+], a
    ld a, $2c
    ld [hl+], a
    ld a, $2c
    ld [hl+], a
    ld a, $2d
    ld [hl], a

UnknownCode_002_5b51:
    ld a, $16
    ldh [hGameState], a
    ret


SpriteAnimationState_ResetCounter:
    xor a
    ld [$da22], a
    ld [$da27], a
    ld [$da1a], a
    ld a, $17
    ldh [hGameState], a
    ret


SpriteAnimationState_CheckActiveFlag:
    ld hl, $da1c
    ld a, [hl]
    and a
    jr nz, UnknownCode_002_5b73

    inc [hl]
    ld hl, $dfe8
    ld a, $0a
    ld [hl], a

UnknownCode_002_5b73:
    ld hl, wSpriteVar31
    ld de, $5c9d
    ld b, $04
    ld a, [$da14]
    and a
    jr z, UnknownCode_002_5b85

CountdownAnimationFramesLoop:
    inc de
    dec a
    jr nz, CountdownAnimationFramesLoop

UnknownCode_002_5b85:
    inc [hl]
    inc l
    ld a, [de]
    ld c, a
    cp $ff
    jr nz, UnknownCode_002_5b96

    ld de, $5c9d
    xor a
    ld [$da14], a
    ld a, [de]
    ld c, a

UnknownCode_002_5b96:
    ldh a, [hTimerAux]
    cp $02
    jr nz, UnknownCode_002_5ba0

    ld a, c
    add $20
    ld c, a

UnknownCode_002_5ba0:
    ld a, c
    ld [hl+], a
    inc de
    inc l
    inc l
    dec b
    jr nz, UnknownCode_002_5b85

    ld a, [$da14]
    add $04
    ld [$da14], a
    ld hl, wSpriteVar31
    ld a, [hl-]
    cp $80
    jr nc, SetGameStateAnimationComplete

    add $04
    ldh [hSpriteX], a
    ld a, [hl]
    add $10
    ldh [hSpriteY], a
    ld bc, $da16
    ld a, [bc]
    dec a
    ld [bc], a
    ret nz

    ld a, $01
    ld [bc], a
    call ReadTileUnderSprite
    ld a, [hl]
    cp $2e
    jr z, SetGameStateCollisionTile1

    cp $30
    jr z, SetGameStateCollisionTile2

    ret


SetGameStateCollisionTile1:
    ld a, $18
    ldh [hGameState], a
    ret


SetGameStateCollisionTile2:
    ld a, $19
    ldh [hGameState], a
    ret


SetGameStateAnimationComplete:
    xor a
    ld [$da1c], a
    ld a, $1a
    ldh [hGameState], a
    ret


SpriteAnimationState_LoadTileIndex:
    ld hl, $c030
    ld b, $04
    ld de, $5c9d
    ld a, [$da14]
    and a
    jr z, UnknownCode_002_5bfe

    ld c, a

SkipAnimationFrames_Loop:
    inc de
    dec c
    jr nz, SkipAnimationFrames_Loop

UnknownCode_002_5bfe:
    inc [hl]
    inc l
    inc l
    ld a, [de]
    ld c, a
    cp $ff
    jr nz, UnknownCode_002_5c10

    ld de, $5c9d
    xor a
    ld [$da14], a
    ld a, [de]
    ld c, a

UnknownCode_002_5c10:
    ldh a, [hTimerAux]
    cp $02
    jr nz, UnknownCode_002_5c1a

    ld a, c
    add $20
    ld c, a

UnknownCode_002_5c1a:
    ld a, c
    ld [hl+], a
    inc de
    inc l
    dec b
    jr nz, UnknownCode_002_5bfe

    ld a, [$da14]
    add $04
    ld [$da14], a
    ld hl, $c030
    ld a, [hl]
    cp $50
    jr z, OnAnimationThresholdReached

    cp $68
    jr z, OnAnimationThresholdReached

    cp $80
    jr z, OnAnimationThresholdReached

    ret


OnAnimationThresholdReached:
    ld a, $08
    ld [$da16], a
    ld a, $17
    ldh [hGameState], a
    ret


SpriteAnimationState_ValidateAndLoad:
    ld hl, $c030
    ld b, $04
    ld de, $5c9d
    ld a, [$da14]
    and a
    jr z, UnknownCode_002_5c57

    ld c, a

CountdownPointerOffsetLoop:
    inc de
    dec c
    jr nz, CountdownPointerOffsetLoop

UnknownCode_002_5c57:
    dec [hl]
    inc l
    inc l
    ld a, [de]
    ld c, a
    cp $ff
    jr nz, UnknownCode_002_5c69

    ld de, $5c9d
    xor a
    ld [$da14], a
    ld a, [de]
    ld c, a

UnknownCode_002_5c69:
    ldh a, [hTimerAux]
    cp $02
    jr nz, UnknownCode_002_5c73

    ld a, c
    add $20
    ld c, a

UnknownCode_002_5c73:
    ld a, c
    ld [hl+], a
    inc de
    inc l
    dec b
    jr nz, UnknownCode_002_5c57

    ld a, [$da14]
    add $04
    ld [$da14], a
    ld hl, $c030
    ld a, [hl]
    cp $38
    jr z, UnknownCode_002_5c93

    cp $50
    jr z, UnknownCode_002_5c93

    cp $68
    jr z, UnknownCode_002_5c93

    ret


UnknownCode_002_5c93:
    ld a, $08
    ld [$da16], a
    ld a, $17
    ldh [hGameState], a
    ret


    ld [bc], a
    inc bc
    ld [de], a
    inc de
    ld [bc], a
    inc bc
    ld [de], a
    inc de
    ld [bc], a
    inc bc
    ld [de], a
    inc de
    ld [bc], a
    inc bc
    ld [de], a
    inc de
    inc b
    dec b
    inc d
    dec d
    inc b
    dec b
    inc d
    dec d
    inc b
    dec b
    inc d
    dec d
    inc b
    dec b
    inc d
    dec d
    nop
    ld bc, $1716
    nop
    ld bc, $1716
    nop
    ld bc, $1716
    nop
    ld bc, $1716
    inc b
    dec b
    inc d
    dec d
    inc b
    dec b
    inc d
    dec d
    inc b
    dec b
    inc d
    dec d
    inc b
    dec b
    inc d
    dec d
    rst $38

SpriteAnimationState_LoadPalette:
    ld a, [$da17]
    and a
    jp nz, SpriteAnimationState_WritePalette

    ld c, $02

CheckAnimationTilesLoop:
    ld hl, $98d1
    ld de, $0060
    ld a, [$c030]
    ld b, a
    cp $38
    jr z, UnknownCode_002_5cf9

    ld a, $2c
    ld [hl+], a
    ld [hl-], a

UnknownCode_002_5cf9:
    add hl, de
    ld a, b
    cp $50
    jr z, UnknownCode_002_5d03

    ld a, $2c
    ld [hl+], a
    ld [hl-], a

UnknownCode_002_5d03:
    add hl, de
    ld a, b
    cp $68
    jr z, UnknownCode_002_5d0d

    ld a, $2c
    ld [hl+], a
    ld [hl-], a

UnknownCode_002_5d0d:
    add hl, de
    ld a, b
    cp $80
    jr z, UnknownCode_002_5d17

    ld a, $2c
    ld [hl+], a
    ld [hl], a

UnknownCode_002_5d17:
    dec c
    jr nz, CheckAnimationTilesLoop

    ld hl, wSpriteVar31
    ld a, [hl-]
    add $18
    ldh [hSpriteX], a
    ld a, [hl]
    add $08
    ldh [hSpriteY], a
    call ReadTileUnderSprite
    ld a, [hl]
    cp $03
    jr z, UnknownCode_002_5d4a

    cp $e5
    jr z, UnknownCode_002_5d51

    cp $02
    jr z, UnknownCode_002_5d43

    ld a, $02
    ld [$da17], a

UnknownCode_002_5d3c:
    ld hl, $dfe8
    ld a, $0d
    ld [hl], a
    ret


UnknownCode_002_5d43:
    ld a, $03
    ld [$da17], a
    jr UnknownCode_002_5d3c

UnknownCode_002_5d4a:
    ld a, $04
    ld [$da17], a
    jr UnknownCode_002_5d3c

UnknownCode_002_5d51:
    ldh a, [hSubState]
    and a
    jr z, UnknownCode_002_5d62

    ld hl, $dfe8
    ld a, $0e
    ld [hl], a
    ld a, $01
    ld [$da17], a
    ret


UnknownCode_002_5d62:
    ld a, $10
    ld [$da17], a
    jr UnknownCode_002_5d3c

SpriteAnimationState_WritePalette:
    ld a, [$da17]
    cp $10
    jr nc, UnknownCode_002_5da0

    cp $02
    jp nc, SpriteAnimationState_FinishPalette

    ld a, [$da1b]
    dec a
    ld [$da1b], a
    ret nz

    ld a, $40
    ld [$da1b], a
    xor a
    ld [$da17], a
    ld [$da14], a
    ld [$da1c], a
    ld [$da1e], a
    ld [$da20], a
    inc a
    ld [$da16], a
    ld a, $40
    ld [$da1f], a
    ld a, $1b
    ldh [hGameState], a
    ret


UnknownCode_002_5da0:
    ld a, [$da1f]
    dec a
    ld [$da1f], a
    ret nz

    ld a, $03
    ld [$da1f], a
    ld a, [$da17]
    inc a
    ld [$da17], a
    cp $28
    jr z, UnknownCode_002_5df7

    ld a, [$da1c]
    and a
    jr nz, UnknownCode_002_5dce

    inc a
    ld [$da1c], a
    ld hl, $dfe0
    ld a, $04
    ld [hl], a
    ldh a, [hTimerAux]
    cp $02
    jr z, UnknownCode_002_5df7

UnknownCode_002_5dce:
    ld hl, wSpriteVar32
    ld b, $04
    ld a, [$da1e]
    and a
    jr nz, UnknownCode_002_5de8

    inc a
    ld [$da1e], a

UnknownCode_002_5ddd:
    ld a, [hl]
    add $20
    ld [hl+], a
    inc l
    inc l
    inc l
    dec b
    jr nz, UnknownCode_002_5ddd

    ret


UnknownCode_002_5de8:
    dec a
    ld [$da1e], a

UnknownCode_002_5dec:
    ld a, [hl]
    sub $20
    ld [hl+], a
    inc l
    inc l
    inc l
    dec b
    jr nz, UnknownCode_002_5dec

    ret


UnknownCode_002_5df7:
    ld a, $01
    ld [$da17], a
    inc a
    ldh [hTimerAux], a
    ldh [hSubState], a
    ret


SpriteAnimationState_FinishPalette:
    ld a, [$da1f]
    dec a
    ld [$da1f], a
    ret nz

    ld a, $04
    ld [$da1f], a
    ld a, [$da20]
    and a
    jr nz, UnknownCode_002_5e3f

    ld hl, $c030
    ld a, $38
    ld b, a
    ld [hl+], a
    ld a, $58
    ld c, a
    ld [hl+], a
    inc l
    inc l
    ld a, b
    ld [hl+], a
    ld a, c
    add $08
    ld [hl+], a
    inc l
    inc l
    ld a, b
    add $08
    ld b, a
    ld [hl+], a
    ld a, c
    ld [hl+], a
    inc l
    inc l
    ld a, b
    ld [hl+], a
    ld a, c
    add $08
    ld [hl+], a
    xor a
    inc a
    ld [$da20], a
    ret


UnknownCode_002_5e3f:
    ld hl, $c030
    ld a, [$da21]
    cp $02
    jp z, SpriteAnimationState_IncrementCounter

    and a
    jr nz, UnknownCode_002_5eb2

    ld a, [hl]
    dec a
    ld [hl+], a
    inc l
    ld a, $08
    ld b, a
    ldh a, [hTimerAux]
    cp $02
    jr nz, UnknownCode_002_5e5e

    ld a, b
    add $20
    ld b, a

UnknownCode_002_5e5e:
    ld a, b
    ld [hl+], a
    inc l
    ld a, [hl]
    dec a
    ld [hl+], a
    inc l
    ld a, b
    inc a
    ld [hl+], a
    inc l
    ld a, [hl]
    dec a
    ld [hl+], a
    inc l
    ld a, b
    add $10
    ld b, a
    ld [hl+], a
    inc l
    ld a, [hl]
    dec a
    ld [hl+], a
    inc l
    ld a, b
    inc a
    ld [hl], a
    ld a, [$da20]
    inc a
    ld [$da20], a
    cp $06
    ret nz

    ld hl, $dfe0
    ld a, $08
    ld [hl], a
    ld a, [$da15]
    and a
    cp $99
    jr nc, UnknownCode_002_5ea9

    add $01
    daa
    ld [$da15], a
    ld de, $988b
    ld a, [$da15]
    ld b, a
    and $0f
    ld [de], a
    dec e
    ld a, b
    and $f0
    swap a
    ld [de], a

UnknownCode_002_5ea9:
    ld a, $01
    ld [$da20], a
    ld [$da21], a
    ret


UnknownCode_002_5eb2:
    ld a, [hl]
    inc a
    ld [hl+], a
    inc l
    inc l
    inc l
    ld a, [hl]
    inc a
    ld [hl+], a
    inc l
    inc l
    inc l
    ld a, [hl]
    inc a
    ld [hl+], a
    inc l
    inc l
    inc l
    ld a, [hl]
    inc a
    ld [hl], a
    ld a, [$da20]
    inc a
    ld [$da20], a
    cp $05
    ret nz

    ld hl, $dfe0
    ld a, $02
    ld [$da21], a
    ret


SpriteAnimationState_IncrementCounter:
    ld a, [hl]
    inc a
    ld [hl+], a
    inc l
    xor a
    ld b, a
    ldh a, [hTimerAux]
    cp $02
    jr nz, UnknownCode_002_5eea

    ld a, b
    add $20
    ld b, a

UnknownCode_002_5eea:
    ld a, b
    ld [hl+], a
    inc l
    ld a, [hl]
    inc a
    ld [hl+], a
    inc l
    ld a, b
    inc a
    ld [hl+], a
    inc l
    ld a, [hl]
    inc a
    ld [hl+], a
    inc l
    ld a, b
    add $10
    ld b, a
    ld [hl+], a
    inc l
    ld a, [hl]
    inc a
    ld [hl+], a
    inc l
    ld a, b
    inc a
    ld [hl], a
    xor a
    ld [$da20], a
    ld [$da21], a
    ld a, [$da17]
    dec a
    ld [$da17], a
    ret


    ld [hl], d
    adc d
    dec a
    cp $09
    jr nc, @-$6e

    add d
    add d
    add d
    sub e
    ld l, a
    adc e
    dec a
    cp $02
    adc l
    sub c
    ld [hl], $50
    ld h, b
    ld [hl], b
    add b
    adc c
    dec a
    cp $02
    adc [hl]
    ld b, c
    ld [hl], $51
    ld h, c
    ld [hl], c
    add b
    adc d
    dec a
    cp $02
    adc a
    ld b, c
    ld [hl], $52
    ld h, d
    ld [hl], d
    add b
    adc e
    dec a
    pop hl
    ld a, $fe
    rlca
    ld sp, $4333
    ld d, e
    ld h, e
    ld [hl], e
    add b
    add d
    dec a
    dec e
    pop hl
    ld bc, $07fe
    ld sp, $4434
    ld d, h
    ld h, h
    ld [hl], h
    add b
    add d
    dec a
    jr @-$4d

    inc e
    pop hl
    add hl, bc
    cp $07
    ld sp, $4535
    ld d, l
    ld h, l
    ld [hl], l
    add b
    add d
    dec a
    add hl, de
    or c
    dec e
    pop hl
    ld [$0afe], sp
    add h
    ld [hl], $46
    ld d, [hl]
    ld h, [hl]
    halt
    adc b
    add d
    dec a
    add hl, hl
    or c
    ld a, [bc]
    pop hl
    add hl, bc
    cp $07
    add l
    scf
    ld b, a
    ld d, a
    ld h, a
    ld [hl], a
    add b
    add c
    dec a
    or c
    dec de
    cp $07
    add l
    jr c, UnknownCode_002_5fde

    ld e, b
    ld l, b
    ld a, b
    add b
    add c
    dec a
    or c
    dec e
    pop hl
    ld c, [hl]
    cp $09
    add [hl]
    add hl, sp
    ld c, c
    ld e, c
    ld l, c
    ld a, c
    add a
    add e
    dec a
    pop hl
    ld c, a
    cp $07
    ld sp, $4a3a
    ld e, d
    ld l, d
    ld a, d
    add b
    add c
    dec a
    pop hl
    ld e, h
    cp $07
    ld sp, $4b3b
    ld e, e
    ld l, e
    ld a, e
    add b
    add c
    dec a
    pop hl
    ld e, l
    cp $02
    ld sp, $4341
    ld l, h
    ld a, h
    add b
    add c
    dec a
    pop hl
    ld e, [hl]
    cp $02
    ld sp, $4341
    ld l, l
    ld a, l
    add b
    add c
    dec a
    pop hl

UnknownCode_002_5fde:
    ld e, a
    cp $02
    ld sp, $4341
    ld l, [hl]
    ld a, [hl]
    add b
    add c
    dec a
    cp $02
    ld sp, $5292
    ld a, a
    add b
    add c
    dec a
    cp $09
    ld [hl-], a
    ld b, d
    add e
    add e
    add e
    add e
    add c
    adc c
    dec a
    cp $72
    adc d
    dec a
    cp $0c
    rrca
    nop
    rrca
    rrca
    add b
    inc de
    inc c
    add h
    ld hl, $000c
    dec h
    inc c
    add h
    jr z, UnknownCode_002_6017

    nop
    add hl, hl
    inc b
    nop

UnknownCode_002_6017:
    ld a, [hl+]
    ld b, $84
    dec l
    adc e
    adc [hl]
    ld [hl-], a
    rrca
    add h
    dec sp
    rrca
    inc b
    inc a
    rrca
    add h
    dec a
    rrca
    add h
    ld b, b
    inc bc
    adc [hl]
    ld b, d
    rrca
    adc [hl]
    ld b, [hl]
    adc l
    add h
    ld c, a
    rrca
    nop
    ld d, d
    inc b
    adc [hl]
    ld d, d
    adc a
    ld c, $53
    adc l
    add h
    ld d, l
    rrca
    nop
    ld d, a
    inc c
    add h
    ld e, l
    inc c
    nop
    ld e, [hl]
    adc h
    add b
    ld h, b
    inc c
    add b
    ld h, d
    inc c
    nop
    ld h, h
    rrca
    nop
    ld l, c
    rrca
    nop
    ld l, l
    rrca
    add h
    ld [hl], l
    rrca
    ld c, $78
    rrca
    add h
    ld a, d
    rrca
    ld c, $80
    inc c
    add h
    add c
    ld [$89bf], sp
    inc bc
    adc [hl]
    adc [hl]
    add a
    ld a, [bc]
    sub d
    add h
    dec bc
    rst $38
    rst $38
    ld c, $0c
    add h
    db $10
    ld a, [bc]
    add h
    ld de, $c205
    inc de
    ld [$1500], sp
    ld b, $c2
    rla
    ld [$1842], sp
    ld [$1a84], sp
    rlca
    jp nz, InitAttractModeDisplay_CheckTimer

    ld b, d
    ld e, $08
    jp nz, PaddingZone_0c22

    inc b
    inc h
    ld a, [bc]
    inc b
    daa
    ld [$2f84], sp
    inc b
    inc b
    cpl
    ld [$3084], sp
    ld [$3400], sp
    add l
    ld a, [bc]
    scf
    adc d
    ld a, [bc]
    add hl, sp
    inc b
    jp nz, $083e

    add h
    ccf
    ld [$42c2], sp
    rlca
    jp nz, $0644

    ld b, d
    ld b, a
    ld b, $42
    ld c, c
    inc b
    jp nz, $084b

    add h
    ld c, h
    rlca
    jp nz, $054e

    ld b, d
    ld d, b
    ld [$5342], sp
    rrca
    add h
    ld e, b
    inc c
    nop
    ld e, c
    adc c
    nop
    ld e, l
    adc b
    ld a, [bc]
    ld h, b
    inc b
    ld a, [bc]
    ld h, d
    adc c
    ld a, [bc]
    ld h, a
    inc b
    jp nz, $8b68

    inc b
    ld l, e
    inc b
    ld b, d
    ld l, h
    ld [$7484], sp
    ld a, [bc]
    dec bc
    ld a, [hl]
    inc c
    add h
    ld a, a
    ld a, [bc]
    ld b, d
    add c
    ld b, $42
    add h
    rlca
    ld a, [bc]
    add a
    add l
    ld [hl], $88
    dec b
    ld [hl], $ff
    dec c
    ld c, l
    ld [bc], a
    rrca
    ld a, [bc]
    add h
    inc de
    rrca
    add h
    dec de
    ld b, $0c
    inc e
    ld b, $0c
    dec e
    ld c, a
    ld [bc], a
    rra
    dec c
    add b
    inc h
    ld c, a
    ld [bc], a
    daa
    ld c, a
    add d
    jr z, UnknownCode_002_6121

    adc h
    jr z, UnknownCode_002_616b

    ld [bc], a
    ld a, [hl+]
    rrca

UnknownCode_002_6121:
    add h
    cpl
    ld [$308c], sp
    ld [$310c], sp
    ld [$328c], sp
    adc $02
    dec [hl]
    dec bc
    add h
    scf
    ld c, h
    ld [bc], a
    add hl, sp
    call Routine_DataProcess_A
    inc b
    inc c
    ld b, c
    inc b
    inc c
    ld b, d
    adc l
    cp a
    ld c, d
    dec bc
    cp a
    ld c, h
    adc l
    ccf
    ld d, c
    inc b
    adc h
    ld d, d
    inc b
    adc h
    ld d, h
    ld b, h
    add d
    ld d, l
    add l
    adc h
    ld e, [hl]
    inc c
    inc b
    ld e, [hl]
    ld c, $80
    ld h, c
    add h
    adc h
    ld h, d
    add h
    adc h
    ld h, l
    add h
    inc c
    ld h, [hl]
    add h
    inc c
    ld h, a
    add h
    inc c
    ld l, c
    db $10
    add h
    ld l, a

UnknownCode_002_616b:
    ld a, [bc]
    cp a
    ld [hl], l
    adc l
    ld [hl], $76
    dec c
    ld [hl], $76
    adc l
    ld [hl], $77
    dec c
    ld [hl], $77
    adc l
    ld [hl], $7d
    adc [hl]
    ccf
    add b
    dec c
    cp a
    add a
    adc [hl]
    cp a
    adc d
    dec c
    ccf
    adc l
    dec b
    adc h
    sub d
    dec c
    ld [$ffff], sp
    dec d
    ld e, a
    cp [hl]
    ld h, d
    rla
    ld l, b
    rst $00
    ld l, b
    cp [hl]
    ld h, d
    nop
    ld h, d
    cp [hl]
    ld h, d
    add c
    ld h, e
    ld e, a
    ld h, h
    cp [hl]
    ld h, d
    dec c
    ld h, l
    cp [hl]
    ld h, d
    nop
    ld h, d
    add c
    ld h, e
    nop
    ld h, d
    cp [hl]
    ld h, d
    sbc $65
    or l
    ld h, [hl]
    cp e
    ld h, a
    rst $38
    cp [hl]
    ld h, d
    rla
    ld l, b
    rst $00
    ld l, b
    and [hl]
    ld l, c
    ld h, c
    ld l, d
    inc hl
    ld l, e
    ld h, c
    ld l, d
    push af
    ld l, e
    xor e
    ld l, h
    inc hl
    ld l, e
    inc hl
    ld l, e
    add hl, hl
    ld l, l
    xor l
    ld l, l
    push af
    ld l, e
    xor e
    ld l, h
    and [hl]
    ld l, c
    cp e
    ld h, a
    rst $38
    cp [hl]
    ld h, d
    jp z, $9f76

    ld [hl], a
    cpl
    ld l, [hl]
    ld hl, $f26f
    ld l, a
    ldh a, [c]
    ld l, a
    db $fd
    ld [hl], b
    ld hl, $2f6f
    ld l, [hl]
    cpl
    ld l, [hl]
    ld d, e
    ld [hl], d
    ldh a, [c]
    ld [hl], d
    ldh [$ff73], a
    ret z

    ld [hl], h
    add a
    ld [hl], c
    add a
    ld [hl], c
    add $75
    rst $38
    nop
    ld [bc], a
    ld d, e
    ld b, b
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    sub c
    add c
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    call nz, ProcessInputState_Bank2_Part1
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    call nz, ProcessInputState_Bank2_Part2
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    pop bc
    ld [hl], $e2
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    sub a
    ld [hl-], a
    ld d, d
    inc [hl]
    ld d, d
    ld d, d
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    sub d
    inc sp
    ld [hl], $e2
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    sub c
    ld [hl], $e2
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    add c
    ld [hl], $e2
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld h, c
    add c
    add c
    ld e, [hl]
    or l
    ld h, e
    ld h, e
    ld h, e
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    sub c
    ld e, [hl]
    or l
    ld h, e
    ld h, e
    ld h, e
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld b, c
    ld b, h
    and c
    ld e, [hl]
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld [hl-], a
    ld b, c
    ld b, l
    or c
    ld e, [hl]
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld [hl-], a
    ld b, d
    ld b, [hl]
    pop bc
    ld e, [hl]
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld [hl-], a
    ld b, e
    ld b, a
    db $d3
    ld e, [hl]
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    db $d3
    ld [hl], $60
    ld h, c
    cp $02
    ld d, e
    ld b, b
    call nz, ProcessInputState_Bank2_Part1
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    or l
    ld [hl], $71
    ld [hl], e
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    or c
    ld e, [hl]
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    or d
    ld [hl], $5e
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    sub d
    add c
    ld [hl], $d3
    ld e, [hl]
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    sub c
    ld [hl], $e2
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    add c
    ld [hl], $c4
    ld [hl-], a
    ld sp, $6160
    cp $02
    ld d, e
    ld b, b
    ld [hl], c
    ld [hl], $c1
    inc sp
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld [hl], c
    ld e, [hl]
    or l
    ld [hl-], a
    ld sp, $6031
    ld h, c
    cp $02
    ld d, e
    ld b, b
    add c
    ld e, [hl]
    or c
    inc sp
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld sp, $9144
    ld e, [hl]
    ldh [c], a
    ld h, b
    ld h, c
    cp $04
    ld d, e
    ld b, b
    ld b, c
    ld b, l
    and c
    ld e, [hl]
    ldh [c], a
    ld h, b
    ld h, c
    cp $04
    ld d, e
    ld b, b
    ld b, d
    ld b, [hl]
    or c
    ld e, [hl]
    ldh [c], a
    ld h, b
    ld h, c
    cp $04
    ld d, e
    ld b, b
    ld b, c
    ld b, l
    pop bc
    ld e, [hl]
    ldh [c], a
    ld h, b
    ld h, c
    cp $04
    ld d, e
    ld b, b
    ld b, d
    ld b, [hl]
    db $d3
    ld e, [hl]
    ld h, b
    ld h, c
    cp $04
    ld d, e
    ld b, b
    ld b, e
    ld b, a
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    or l
    ld d, d
    ld d, d
    ld d, d
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    and [hl]
    ld [hl], $60
    add sp, -$18
    add sp, $61
    cp $02
    ld d, e
    ld b, b
    and [hl]
    ld e, [hl]
    ld h, b
    add sp, -$18
    add sp, $61
    cp $02
    ld d, e
    ld b, b
    or l
    ld h, b
    add sp, -$18
    add sp, $61
    cp $02
    ld d, e
    ld b, b
    and [hl]
    ld [hl], $60
    add sp, -$18
    add sp, $61
    cp $02
    ld d, e
    ld b, b
    and [hl]
    ld e, [hl]
    ld h, b
    add sp, -$18
    add sp, $61
    cp $02
    ld d, e
    ld b, b
    or l
    ld h, b
    add sp, -$18
    add sp, $61
    cp $02
    ld d, e
    ld b, b
    ld [hl], c
    add c
    or l
    ld h, b
    add sp, -$18
    add sp, $61
    cp $02
    ld d, e
    ld b, b
    ld [hl], c
    add d
    or l
    ld h, b
    add sp, -$18
    add sp, $61
    cp $02
    ld d, e
    ld b, b
    ld [hl], c
    add c
    or l
    ld h, b
    add sp, -$18
    add sp, $61
    cp $02
    ld d, e
    ld b, b
    ld [hl], c
    add d
    or l
    ld h, b
    add sp, -$18
    add sp, $61
    cp $02
    ld d, e

Routine_DataProcess_H:
    ld b, b
    ld [hl], c
    add c
    or l
    ld h, b
    add sp, -$18
    add sp, $61
    cp $02
    ld d, e
    ld b, b
    or l
    ld h, b
    add sp, -$18
    add sp, $61
    cp $02
    ld d, e
    ld b, b
    or l
    ld h, b
    add sp, -$18
    add sp, $61
    cp $02
    ld d, e
    ld b, b
    or l
    ld h, b
    add sp, -$18
    add sp, $61
    cp $02
    ld d, e
    ld b, b
    or l
    ld h, b
    add sp, -$18
    add sp, $61
    cp $02
    ld d, e
    ld b, b
    or l
    ld h, b
    add sp, -$18
    add sp, $61
    cp $02
    ld d, e
    ld b, b
    or l
    ld h, b
    add sp, -$18
    add sp, $61
    cp $02
    ld d, e
    ld b, b
    ld a, c
    ld [hl], b
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld h, b
    add sp, -$18
    add sp, $61
    cp $02
    ld d, e
    ld b, b
    ld a, c
    ld [hl], c
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld h, b
    add sp, -$18
    add sp, $61
    cp $02
    ld d, e
    ld b, b
    ld d, c
    add d
    ldh [c], a
    ld h, b
    ld h, c

Routine_DataProcess_C:
    cp $02
    ld d, e
    ld b, b
    ld d, c
    add d
    call nz, AnimFrameDataLookup
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld d, c
    add d
    and c
    add c
    pop bc
    inc sp
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld d, c
    add b
    or l
    ld [hl-], a
    ld sp, $6031
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld d, c
    add d
    or c
    inc sp
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld d, c
    add d
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    scf
    db $fd
    db $f4
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ldh [c], a
    db $fd
    ld d, b
    cp $02
    ld d, e
    ld b, b
    ldh [c], a
    db $fd
    ld d, d
    cp $02
    ld d, e
    ld b, b
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    and c
    add d
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld h, c
    add c
    and c
    add d
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    and c
    add d
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ldh [c], a
    ld h, b

Routine_DataProcess_I:
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    db $d3
    ld [hl], $60
    ld h, c
    cp $02
    ld d, e
    ld b, b
    pop bc
    ld [hl], $e2
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    or c
    ld [hl], $e2
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    and c
    ld [hl], $e2
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    sub d
    ld [hl], $7f
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    add c
    ld [hl], $a1
    ld a, a
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld h, d
    add c
    ld [hl], $a1
    ld a, a
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld h, c
    add c
    and c
    ld a, a
    ldh [c], a
    ld h, b
    ld h, c
    cp $03
    ld d, e
    ld b, b
    add c
    ld d, d
    ld [hl], $81
    and c
    ld a, a

Routine_DataProcess_D:
    ldh [c], a
    ld h, b
    ld h, c
    cp $03
    ld d, e
    ld b, b
    add c
    ld d, d
    ld e, [hl]
    add c
    and c
    ld a, a
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld h, c
    add c
    and c
    ld a, a
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld h, d
    add c
    ld e, [hl]
    and c
    ld a, a
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    add c
    ld e, [hl]
    and c
    ld a, a
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    sub d
    ld e, [hl]
    ld a, a
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    and c
    ld e, [hl]
    call nz, AnimFrameDataLookup
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    or d
    ld e, [hl]
    inc sp
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld sp, $b544
    ld [hl-], a
    inc a
    ld sp, $6160
    cp $04
    ld d, e
    ld b, b
    ld b, c
    ld b, l
    or c
    inc sp
    db $d3
    ld e, [hl]
    ld h, b
    ld h, c
    cp $04
    ld d, e
    ld b, b
    ld b, d
    ld b, [hl]
    ldh [c], a
    db $fd
    ld d, b
    cp $04
    ld d, e
    ld b, b
    ld b, e
    ld b, a
    cp $02
    ld d, e
    ld b, b
    or l
    ld [hl-], a
    ld sp, $6031
    ld h, c
    cp $02
    ld d, e
    ld b, b
    or c
    inc sp
    db $d3
    ld [hl], $60
    ld h, c
    cp $02
    ld d, e
    ld b, b
    and [hl]
    ld [hl-], a
    ld sp, $3134
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    and d
    inc sp
    ld [hl], $e2
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    or c
    ld e, [hl]
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    or d
    ld [hl], $5e
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    and c
    ld [hl], $d3
    ld e, [hl]
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    sub c
    ld [hl], $e2
    db $fd
    ld d, b
    cp $02
    ld d, e
    ld b, b
    add c
    ld [hl], $fe
    ld [bc], a
    ld d, e
    ld b, b
    ld [hl], c
    ld [hl], $e2
    db $fd
    ld d, d
    cp $02
    ld d, e
    ld b, b
    ld h, c
    ld [hl], $a6
    ld c, b
    ld c, d
    ld h, e
    ld h, e
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld d, c
    ld [hl], $a6
    ld c, c
    ld c, e
    ld h, e
    ld h, e
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld d, c

DataTable_665a:
    ld e, [hl]
    or l
    ld c, h
    ld h, e
    ld h, e
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld h, c

Routine_DataProcess_E:
    ld e, [hl]
    call nz, $6363
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld [hl], c
    ld e, [hl]
    call nz, $6363
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    add c
    ld e, [hl]
    or l

DataTable_667e:
    ld h, e
    ld h, e
    ld h, e
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    sub c
    ld e, [hl]
    or l
    ld h, e
    ld h, e
    ld h, e
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld [hl], c
    add d
    and [hl]
    ld e, [hl]
    ld h, e
    ld h, e
    ld h, e
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld [hl], c
    add d
    or l
    ld h, e
    ld h, e
    ld h, e
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld [hl], c
    add b
    or l
    ld h, e
    ld h, e
    ld h, e
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld sp, $b544
    ld h, e
    ld h, e
    ld h, e
    ld h, b
    ld h, c
    cp $04
    ld d, e
    ld b, b
    ld b, c
    ld b, l
    or c
    ld [hl], $e2
    db $fd
    ld d, b
    cp $04
    ld d, e
    ld b, b
    ld b, d
    ld b, [hl]
    and c
    ld [hl], $e2
    db $fd
    ld d, d
    cp $04
    ld d, e
    ld b, b
    ld b, e
    ld b, a
    sub c
    ld [hl], $d3
    ld h, e
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    add c
    ld [hl], $c4
    ld h, e
    ld h, e
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld [hl], c
    ld [hl], $c4
    ld h, e
    ld h, e
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld h, c
    ld [hl], $a6
    ld h, e
    db $f4
    ld h, e
    ld h, e
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld d, c
    ld [hl], $92
    db $fd
    ld h, e
    call nz, $6363
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld d, c
    ld e, [hl]
    sub a
    ld h, e
    ld h, e
    db $f4
    ld h, e
    ld h, e
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld h, d
    ld e, [hl]
    ld h, e
    sub d
    db $fd
    ld h, e
    call nz, $6363
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld l, d
    ld h, e
    ld h, e
    db $f4
    ld h, e
    ld h, e
    db $f4
    ld h, e
    ld h, e
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld e, e
    ld h, e
    ld h, e
    ld h, e
    ld e, [hl]
    ld h, e
    ld h, e
    ld h, e
    ld h, e
    ld h, e
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld c, h
    ld h, e
    ld h, e
    ld h, e
    ld h, e
    db $f4
    ld h, e
    ld h, e
    ld h, e
    ld h, e
    ld h, e
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    dec [hl]
    db $fd
    ld h, e
    sub a
    ld h, e
    ld h, e
    ld h, e
    ld h, e
    ld h, e
    ld h, b
    ld h, c
    cp $00
    ld d, e
    ld b, b
    ld h, e
    ld h, e
    ld h, e
    ld h, e
    ld h, e
    ld h, e
    db $f4
    ld h, e
    ld h, e
    ld h, e
    ld h, e
    ld h, e
    ld h, b
    ld h, c
    cp $08
    ld d, e
    ld b, b
    ld h, e
    ld h, e
    ld h, e
    ld h, e
    ld h, e
    ld h, e
    sub a
    ld h, e
    ld h, e
    ld h, e
    ld h, e
    ld h, e
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    db $d3
    ld e, [hl]
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld sp, $51f4
    db $f4
    ld [hl], c
    db $f4
    sub c
    db $f4
    or c
    db $f4
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ldh [c], a
    ld h, b
    ld h, c
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
    cp $f1
    adc a
    cp $f1
    adc [hl]
    cp $f1
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
    ld hl, $8e39
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
    ld hl, $8f39
    cp $00
    db $fd
    ld a, a
    cp $e2
    db $fd
    ld a, a
    cp $e2
    db $fd
    ld a, a
    cp $e2
    db $fd
    ld a, a
    cp $01
    ld a, a
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    call nz, TrapHalt_7ffd
    cp $01
    ld a, a
    ld [hl], c
    db $f4
    sub c
    db $f4
    or l
    db $f4
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    cp $01
    ld a, a
    ld [hl], c
    db $f4
    sub c
    db $f4
    or l
    db $f4
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    cp $01
    ld a, a
    ld [hl], c
    db $f4
    sub c
    db $f4
    or l
    db $f4
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    cp $01
    ld a, a
    ld [hl], c
    db $f4
    sub c
    db $f4
    or l
    db $f4
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    cp $01
    ld a, a
    ld [hl], c
    db $f4
    sub c
    db $f4
    or l
    db $f4
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    cp $01
    ld a, a
    ld [hl], c
    db $f4
    sub c
    db $f4
    or l
    db $f4
    ld a, a
    ld a, a
    ld a, a
    ld a, a
    cp $01
    ld a, a
    call nz, TrapHalt_7ffd
    cp $01
    ld a, a
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    ldh [c], a
    db $fd
    ld a, a
    cp $e2
    db $fd
    ld a, a
    cp $c4
    ld [hl], h
    ld [hl], a
    ld a, a
    ld a, a
    cp $c4
    ld [hl], l
    ld a, b
    ld a, a
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
    halt
    ld a, c
    ld a, a
    ld a, a
    cp $00
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld a, a
    ld a, a
    cp $00
    db $fd
    ld a, a
    cp $e2
    db $fd
    ld a, a
    cp $c1
    db $f4
    ldh [c], a
    db $fd
    ld a, a
    cp $e2
    db $fd
    ld a, a
    cp $08
    db $fd
    ld a, a
    pop bc
    db $f4
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    ld sp, $74f4
    db $fd
    ld a, a
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    add c
    db $f4
    and c
    ld a, a
    pop bc
    db $f4
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    ld sp, $51f4
    ld a, a
    and c
    ld a, a
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    ld d, c
    ld a, a
    add c
    db $f4
    and c
    ld a, a
    pop bc
    db $f4
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    ld sp, $51f4
    ld a, a
    and c
    ld a, a
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    ld d, c
    ld a, a
    add c
    db $f4
    and c
    ld a, a
    pop bc
    db $f4
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    ld sp, $51f4
    ld a, a
    and c
    ld a, a
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    ld d, c
    ld a, a
    add c
    db $f4
    and c
    ld a, a
    pop bc
    db $f4
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    ld sp, $51f4
    ld a, a
    and c
    ld a, a
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    ld d, c
    ld a, a
    add c
    db $f4
    and c
    ld a, a
    pop bc
    db $f4
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    ld sp, $51f4
    ld a, a
    and c
    ld a, a
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    inc sp
    ld [hl], h
    ld [hl], a
    ld a, a
    add c
    db $f4
    and c
    ld a, a
    pop bc
    db $f4
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    inc sp
    ld [hl], l
    ld a, b
    ld a, a
    ldh [c], a
    db $fd
    ld a, a
    cp $06
    ld [hl], d
    ld [hl], d
    ld [hl], d
    halt
    ld a, c
    ld a, a
    pop bc
    db $f4
    ldh [c], a
    db $fd
    ld a, a
    cp $00
    ld [hl], e
    ld [hl], e
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
    cp $02
    ld d, e
    ld b, b
    cp $02
    ld d, e
    ld b, b
    ldh [c], a
    db $fd
    ld d, d
    cp $02
    ld d, e
    ld b, b
    ld b, c
    ld b, h
    or l
    ld [hl-], a
    ld sp, $6031
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld [hl-], a
    ld b, c
    ld b, l
    or c
    inc sp
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld [hl-], a
    ld b, d
    ld b, [hl]
    adc b
    ld [hl-], a
    ld sp, $3131
    ld sp, $6031
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ld [hl-], a
    ld b, e
    ld b, a
    adc b
    inc sp
    ld [hl-], a
    ld sp, $3131
    ld sp, $6160
    cp $02
    ld d, e
    ld b, b
    sub c
    inc sp
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ldh [c], a
    ld h, b
    ld h, c
    cp $02
    ld d, e
    ld b, b
    ldh [c], a
    db $fd
    ld d, b
    cp $02
    ld d, e
    ld b, b
    or c
    ld l, b
    cp $02
    ld d, e
    ld b, b
    or c
    ld l, c
    cp $02
    ld d, e
    ld b, b
    ld sp, $b544
    ld l, c
    scf
    scf
    scf
    scf
    cp $04
    ld d, e
    ld b, b
    ld b, c
    ld b, l
    or l
    ld l, c
    scf
    scf
    scf
    scf
    cp $04
    ld d, e
    ld b, b
    ld b, d
    ld b, [hl]
    or c
    ld l, c
    cp $04
    ld d, e
    ld b, b
    ld b, e
    ld b, a
    ld [hl], c
    ld l, b
    or c
    ld l, d
    cp $02
    ld d, e
    ld b, b
    ld d, c
    db $f4
    ld [hl], c
    ld l, c
    cp $02
    ld d, e
    ld b, b
    ld a, c
    ld l, c
    scf
    scf
    scf
    scf
    scf
    scf
    scf
    scf
    cp $02
    ld d, e
    ld b, b
    ld d, c
    db $f4
    ld [hl], c
    ld l, c
    cp $02
    ld d, e
    ld b, b
    ld [hl], c
    ld l, d
    cp $02
    ld d, e
    ld b, b
    ld sp, $71f4
    ld l, b
    cp $02
    ld d, e
    ld b, b
    ld sp, $7981
    ld l, c
    scf
    scf
    scf
    scf
    scf
    scf
    scf
    scf
    cp $02
    ld d, e
    ld b, b
    ld sp, $71f4
    ld l, d
    pop af
    ld [hl], $fe
    ld [bc], a
    ld d, e
    ld b, b
    or c
    ld l, b
    pop hl
    ld [hl], $fe
    ld [bc], a
    ld d, e
    ld b, b
    or c
    ld l, c
    pop hl
    ld e, [hl]
    cp $02
    ld d, e
    ld b, b
    or c
    ld l, c
    ldh [c], a
    ld [hl], $5e
    cp $02
    ld d, e
    ld b, b
    or l
    ld l, c
    scf
    scf
    scf
    scf
    cp $02
    ld d, e
    ld b, b
    or d
    ld l, c
    ld [hl], $fe
    ld [bc], a
    ld d, e
    ld b, b
    or d
    ld l, c
    ld e, [hl]
    cp $02
    ld d, e
    ld b, b
    ld b, c
    ld b, h
    or c
    ld l, d
    pop de
    ld e, [hl]
    cp $02
    ld d, e
    ld b, b
    ld [hl-], a
    ld b, c
    ld b, l
    sub c
    ld l, b
    pop hl
    ld e, [hl]
    cp $02
    ld d, e
    ld b, b
    ld [hl-], a
    ld b, d
    ld b, [hl]
    sub c
    ld l, c
    pop af
    ld e, [hl]
    cp $02
    ld d, e
    ld b, b
    ld [hl-], a
    ld b, e
    ld b, a
    sub c
    ld l, c
    cp $02
    ld d, e
    ld b, b
    ld d, c
    db $f4
    sub a
    ld l, c
    scf
    scf
    scf
    scf
    scf
    scf
    cp $02
    ld d, e
    ld b, b
    sub c
    ld l, c
    pop af
    ld [hl], $fe
    ld [bc], a
    ld d, e
    ld b, b
    sub c
    ld l, c
    pop hl
    ld [hl], $fe
    ld [bc], a
    ld d, e
    ld b, b
    sub c
    ld l, d
    pop de
    ld [hl], $fe
    ld [bc], a
    ld d, e
    ld b, b
    ld [hl], c
    ld l, b
    pop de
    ld e, [hl]
    cp $02
    ld d, e
    ld b, b
    ld sp, $79f4
    ld l, c
    scf
    scf
    scf
    scf
    scf
    scf
    scf
    scf
    cp $02
    ld d, e
    ld b, b
    ld [hl], c
    ld l, d
    pop af
    ld e, [hl]
    cp $02
    ld d, e
    ld b, b
    ld [hl], c
    ld l, b
    cp $02
    ld d, e
    ld b, b
    ld [hl], c
    ld l, c
    cp $02
    ld d, e
    ld b, b
    ld [hl], c
    ld l, c
    cp $02
    ld d, e
    ld b, b
    ld [hl], c
    ld l, c
    cp $02
    ld d, e
    ld b, b
    ld [hl], c
    ld l, c
    ldh [c], a
    ld [hl-], a
    ld sp, $02fe
    ld d, e
    ld b, b
    ld [hl], c
    ld l, c
    pop hl
    inc sp
    cp $02
    ld d, e
    ld b, b
    ld [hl], c
    ld l, c
    cp $02
    ld d, e
    ld b, b
    ld a, c
    ld l, c
    scf
    scf
    scf
    scf
    scf
    scf
    scf
    scf
    cp $02
    ld d, e
    ld b, b

DataTable_6b63:
    ld a, c
    ld l, c
    scf
    scf
    scf
    scf
    scf
    scf
    scf
    scf
    cp $02
    ld d, e
    ld b, b
    ld a, c
    ld l, c
    scf
    scf
    scf
    scf
    scf
    scf
    scf
    scf
    cp $02
    ld d, e
    ld b, b
    ld sp, $7944
    ld l, c
    scf
    scf
    scf
    scf
    scf
    scf
    scf
    scf
    cp $04
    ld d, e
    ld b, b
    ld b, c
    ld b, l
    ld a, c
    ld l, c
    scf
    scf
    scf
    scf
    scf
    scf
    scf
    scf
    cp $04
    ld d, e
    ld b, b
    ld b, d
    ld b, [hl]
    ld a, c
    ld l, c
    scf
    scf
    scf
    scf
    scf
    scf
    scf
    scf
    cp $04
    ld d, e
    ld b, b
    ld b, c
    ld b, l
    ld [hl], c
    ld l, c
    pop hl
    ld [hl], $fe
    inc b
    ld d, e
    ld b, b
    ld b, d
    ld b, [hl]
    ld [hl], c
    ld l, c
    pop hl
    ld e, [hl]
    cp $04
    ld d, e
    ld b, b
    ld b, e
    ld b, a
    ld [hl], c
    ld l, c
    ldh [c], a
    ld [hl], $5e
    cp $02
    ld d, e
    ld b, b
    ld [hl], c
    ld l, c
    pop de
    ld [hl], $f1
    ld [hl-], a
    cp $02
    ld d, e
    ld b, b
    ld [hl], c
    ld l, c
    pop de
    ld e, [hl]
    pop af
    inc sp
    cp $02
    ld d, e
    ld b, b
    ld [hl], c
    ld l, c
    or l
    ld [hl-], a
    ld sp, $3c31
    ld sp, $02fe
    ld d, e
    ld b, b
    ld [hl], c
    ld l, d
    or c
    inc sp
    pop af
    ld e, [hl]
    cp $02
    ld d, e
    ld b, b
    cp $02
    ld d, e
    ld b, b
    cp $02
    ld d, e
    ld b, b
    cp $02
    ld d, e
    ld b, b
    ld d, c
    db $f4
    ld [hl], c
    db $f4
    sub c
    db $f4
    pop hl
    ld l, b
    cp $02
    ld d, e
    ld b, b
    pop hl
    ld l, c
    cp $02
    ld d, e
    ld b, b
    ldh [c], a
    ld l, c
    scf
    cp $02
    ld d, e
    ld b, b
    pop hl
    ld l, c
    cp $02
    ld d, e
    ld b, b
    and c
    ld l, b
    pop hl
    ld l, d
    cp $02
    ld d, e
    ld b, b
    and c
    ld l, c
    cp $02
    ld d, e
    ld b, b
    and [hl]
    ld l, c
    scf
    scf
    scf
    scf
    scf
    cp $02
    ld d, e
    ld b, b
    ld [hl], c
    ld l, b
    and c
    ld l, c
    pop af
    ld [hl], $fe
    ld [bc], a
    ld d, e
    ld b, b
    ld [hl], c
    ld l, c
    and c
    ld l, d
    pop hl
    ld [hl], $fe
    ld [bc], a
    ld d, e
    ld b, b
    ld sp, $7181
    ld l, c
    pop hl
    ld e, [hl]
    cp $02
    ld d, e
    ld b, b
    ld sp, $7182
    ld l, c
    ldh [c], a
    ld [hl], $5e
    cp $02
    ld d, e
    ld b, b
    ld sp, $7981
    ld l, c
    scf
    scf
    scf
    scf
    scf
    scf
    scf
    scf
    cp $02
    ld d, e
    ld b, b
    ld sp, $7182
    ld l, c
    or d
    ld e, a
    ld [hl], $e1
    ld l, b
    cp $02
    ld d, e
    ld b, b
    ld sp, $7181
    ld l, c
    and [hl]
    ld [hl-], a
    ld d, d
    inc a
    ld d, d
    ld l, c
    ld d, d
    cp $02
    ld d, e
    ld b, b
    ld [hl], c
    ld l, c
    and c
    inc sp
    db $d3
    ld e, [hl]
    ld l, c
    scf
    cp $02
    ld d, e
    ld b, b
    ld [hl], c
    ld l, d
    pop hl
    ld l, c
    cp $02
    ld d, e
    ld b, b
    or c
    add c
    ldh [c], a
    ld l, d
    ld e, [hl]
    cp $02
    ld d, e
    ld b, b
    ld [hl], c
    ld l, b
    cp $02
    ld d, e
    ld b, b
    ld sp, $7944
    ld l, c
    scf
    scf
    scf
    scf
    scf
    scf
    scf
    scf
    cp $04
    ld d, e
    ld b, b
    ld b, c
    ld b, l
    ld [hl], c
    ld l, d
    cp $04
    ld d, e
    ld b, b
    ld b, d
    ld b, [hl]
    cp $04
    ld d, e
    ld b, b
    ld b, e
    ld b, a
    cp $02
    ld d, e
    ld b, b
    call nz, AnimFrameDataLookup
    ld sp, $fe31
    ld [bc], a
    ld d, e
    ld b, b
    pop bc
    inc sp
    cp $02
    ld d, e
    ld b, b
    ldh [c], a
    ld [hl-], a
    ld sp, $02fe
    ld d, e
    ld b, b
    pop hl
    inc sp
    cp $02
    ld d, e
    ld b, b
    cp $02
    ld d, e
    ld b, b
    cp $02
    ld d, e
    ld b, b
    cp $02
    ld d, e
    ld b, b
    cp $02
    ld d, e
    ld b, b
    cp $02
    ld d, e
    ld b, b
    ld b, c
    db $f4
    cp $02
    ld d, e
    ld b, b
    ld b, c
    db $f4
    cp $02
    ld d, e
    ld b, b
    ld b, c
    db $f4
    cp $02
    ld d, e
    ld b, b
    add c
    ld a, a
    cp $02
    ld d, e
    ld b, b
    add c
    ld a, a
    cp $02
    ld d, e
    ld b, b
    add c
    ld a, a
    cp $02
    ld d, e
    ld b, b
    ld sp, $fef4
    ld [bc], a
    ld d, e
    ld b, b
    cp $02
    ld d, e
    ld b, b
    ld sp, $e1f4
    ld l, b
    cp $02
    ld d, e
    ld b, b
    pop hl
    ld l, c
    cp $02
    ld d, e
    ld b, b
    pop hl
    ld l, c
    cp $02
    ld d, e
    ld b, b
    ldh [c], a
    ld l, c
    scf
    cp $02
    ld d, e
    ld b, b
    pop hl
    ld l, c
    cp $02
    ld d, e
    ld b, b
    pop hl
    ld l, c
    cp $02
    ld d, e
    ld b, b
    pop hl
    ld l, d
    cp $02
    ld d, e
    ld b, b
    ld sp, $fe44
    inc b
    ld d, e
    ld b, b
    ld b, c
    ld b, l
    cp $04
    ld d, e
    ld b, b
    ld b, d
    ld b, [hl]
    cp $04
    ld d, e
    ld b, b
    ld b, e
    ld b, a
    pop af
    ld h, e
    cp $02
    ld d, e
    ld b, b
    ldh [c], a
    db $fd
    ld h, e
    cp $02
    ld d, e
    ld b, b
    db $d3
    db $fd
    ld h, e
    cp $02
    ld d, e
    ld b, b
    call nz, Routine_DataProcess_H
    cp $02
    ld d, e
    ld b, b
    or l
    db $fd
    ld h, e
    cp $02
    ld d, e
    ld b, b
    and [hl]
    db $fd
    ld h, e
    cp $02
    ld d, e
    ld b, b
    sub a
    db $fd
    ld h, e
    cp $02
    ld d, e
    ld b, b
    ld d, c
    add c
    sub a
    db $fd
    ld h, e
    cp $02
    ld d, e
    ld b, b
    sub a
    db $fd
    ld h, e
    cp $02
    ld d, e
    ld b, b
    ld sp, $a644
    db $fd
    ld h, e
    cp $04
    ld d, e
    ld b, b
    ld b, c
    ld b, l
    or l
    db $fd
    ld h, e
    cp $04
    ld d, e
    ld b, b
    ld b, d
    ld b, [hl]
    pop af
    ld [hl], $fe
    inc b
    ld d, e
    ld b, b
    ld b, c
    ld b, l
    db $d3
    db $fd
    ld h, e
    cp $04
    ld d, e
    ld b, b
    ld b, d
    ld b, [hl]
    db $d3
    ld [hl], $63
    ld h, e
    cp $04
    ld d, e
    ld b, b
    ld b, e
    ld b, a
    pop bc
    ld [hl], $f1
    ld h, e
    cp $02
    ld d, e
    ld b, b
    pop bc
    ld e, [hl]
    cp $02
    ld d, e
    ld b, b
    pop de
    ld e, [hl]
    cp $02
    ld d, e
    ld b, b
    pop hl
    ld e, [hl]
    cp $02
    ld d, e
    ld b, b
    pop af
    ld e, [hl]
    cp $02
    ld d, e
    ld b, b
    cp $02
    ld d, e
    ld b, b
    ldh [c], a
    ld [hl-], a
    ld sp, $02fe
    ld d, e
    ld b, b
    ldh [c], a
    inc sp
    ld [hl-], a
    cp $02
    ld d, e
    ld b, b
    pop af
    inc sp
    cp $02
    ld d, e
    ld b, b
    cp $02
    ld d, e
    ld b, b
    cp $02
    ld d, e
    ld b, b
    cp $02
    ld d, e
    ld b, b
    cp $02
    ld d, e
    ld b, b
    cp $0b
    ld h, l
    ld l, [hl]
    ld l, l
    ld l, [hl]
    ld l, l
    ld h, l
    ld h, l
    ld h, l
    ld h, l
    ld h, l
    ld h, l
    ldh [c], a
    ld h, l
    ld l, [hl]
    cp $0b
    ld h, [hl]
    ld l, l
    ld l, [hl]
    ld l, l
    ld l, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ldh [c], a
    ld h, [hl]
    ld l, l
    cp $06
    ld h, l
    ld l, [hl]
    ld l, l
    ld l, [hl]
    ld e, c
    ld e, e
    sub c
    ld e, a
    ldh [c], a
    ld h, l
    ld l, [hl]
    cp $06
    ld h, [hl]
    ld l, l
    ld l, [hl]
    ld l, l
    ld e, d
    ld e, h
    ldh [c], a
    ld h, [hl]
    ld l, l

Routine_DataProcess_J:
    cp $05
    ld h, l
    ld l, [hl]
    ld l, l
    ld h, [hl]
    ld d, l
    ldh [c], a
    ld h, l
    ld l, [hl]
    cp $03
    ld h, [hl]
    ld l, l
    ld l, [hl]
    ld b, c
    ld d, [hl]
    ld h, d
    ld e, l
    dec [hl]
    ldh [c], a
    ld h, [hl]
    ld l, l
    cp $03
    ld h, l
    ld l, [hl]
    ld l, l
    ld b, c
    ld d, a
    ldh [c], a
    ld h, l
    ld l, [hl]
    cp $03
    ld h, [hl]
    ld l, l
    ld h, [hl]
    ld b, d
    ld e, b
    dec hl
    and c
    add c
    ldh [c], a
    ld h, [hl]
    ld l, l
    cp $02
    ld h, l
    ld l, [hl]
    ld b, d
    ld e, c
    ld e, e
    and c
    add d
    ldh [c], a
    ld h, l
    ld l, [hl]
    cp $02
    ld h, [hl]
    ld l, l
    ld b, d
    ld e, d
    ld e, h
    and c
    add c
    ldh [c], a
    ld h, [hl]
    ld l, l
    cp $02
    ld h, l
    ld l, [hl]
    ld b, d
    ld d, a
    ld d, l
    sub d
    ld e, a
    add d
    ldh [c], a
    ld h, l
    ld l, [hl]
    cp $02
    ld h, [hl]
    ld l, l
    and c
    add c
    ldh [c], a
    ld h, [hl]
    ld l, l
    cp $02
    ld h, l
    ld l, [hl]
    ld b, d
    ld d, [hl]
    ld d, a
    ldh [c], a
    ld h, l
    ld l, [hl]
    cp $02
    ld l, [hl]
    ld l, l
    ld b, c
    dec hl
    call nz, Routine_DataProcess_D
    ld l, [hl]
    ld l, l
    cp $02
    ld l, l
    ld l, [hl]
    ld b, c
    ld d, l
    ld h, d
    ld e, l
    dec [hl]
    call nz, Routine_DataProcess_E
    ld l, l
    ld l, [hl]
    cp $02
    ld h, [hl]
    ld l, l
    ld b, c
    ld d, a
    ldh [c], a
    ld h, [hl]
    ld l, l
    cp $03
    ld h, l
    ld l, [hl]
    ld h, l
    ld b, d
    jr c, @+$2d

    ldh [c], a
    ld h, l
    ld l, [hl]
    cp $06
    ld h, [hl]
    ld l, l
    ld l, [hl]
    ld h, l
    jr c, UnknownCode_002_6f56

    ldh [c], a
    ld h, [hl]
    ld l, l
    cp $09
    ld h, l
    ld l, [hl]
    ld l, l
    ld l, [hl]
    ld h, l
    ld h, l
    ld h, l
    ld h, l
    ld h, l
    ldh [c], a
    ld h, l
    ld l, [hl]
    cp $09
    ld h, [hl]
    ld l, l
    ld l, [hl]
    ld l, l
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ldh [c], a
    ld h, [hl]
    ld l, l
    cp $04
    ld h, l
    ld l, [hl]
    ld l, l
    ld h, [hl]
    ld d, c
    ld d, a
    ldh [c], a
    ld h, l
    ld c, [hl]
    cp $03
    ld h, [hl]
    ld l, l
    ld l, [hl]
    ld d, c
    ld d, l
    or l
    ld [hl], b
    ld [hl], d
    ld [hl], d
    ld l, [hl]
    ld l, l
    cp $03
    ld h, l
    ld l, [hl]
    ld l, l
    ld d, c
    ld d, l
    or l
    ld [hl], c
    ld [hl], e
    ld [hl], e
    ld l, l
    ld l, [hl]
    cp $03
    ld h, [hl]
    ld l, l
    ld l, [hl]
    ld d, c
    ld e, b
    ldh [c], a
    ld h, [hl]
    ld l, l
    cp $03
    ld h, l
    ld l, [hl]
    ld l, l
    ld b, e
    dec hl

UnknownCode_002_6f56:
    dec hl
    ld d, [hl]
    ldh [c], a
    ld h, l
    ld l, [hl]
    cp $03
    ld h, [hl]
    ld l, l
    ld l, [hl]
    ld d, c
    dec h
    ldh [c], a
    ld h, [hl]
    ld l, l
    cp $03
    ld h, l
    ld l, [hl]
    ld l, l
    ld d, c
    ld d, a
    and [hl]
    ld [hl], b
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    cp $03
    ld h, [hl]
    ld l, l
    ld l, [hl]
    and [hl]
    ld [hl], c
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    cp $03
    ld h, l
    ld l, [hl]
    ld l, l
    cp $03
    ld h, [hl]
    ld l, l
    ld l, [hl]
    cp $03
    ld h, l
    ld l, [hl]
    ld l, l
    sub a
    ld [hl], b
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld [hl], d
    cp $03
    ld h, [hl]
    ld l, l
    ld l, [hl]
    sub a
    ld [hl], c
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    cp $03
    ld h, l
    ld l, [hl]
    ld l, l
    cp $03
    ld h, [hl]
    ld l, l
    ld l, [hl]
    ld d, c
    ld d, a
    cp $03
    ld h, l
    ld l, [hl]
    ld l, l
    ld d, c
    ld e, b
    pop hl
    ld h, l
    cp $03
    ld h, [hl]
    ld l, l
    ld l, [hl]
    and [hl]
    ld [hl], b
    ld [hl], d
    ld [hl], d
    ld [hl], d
    ld l, [hl]
    ld h, l
    cp $03
    ld h, l
    ld l, [hl]
    ld l, l
    ld d, c
    ld d, l
    and [hl]
    ld [hl], c
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld l, l
    ld l, [hl]
    cp $03
    ld h, [hl]
    ld l, l
    ld l, [hl]
    ld d, c
    ld d, [hl]
    ldh [c], a
    ld h, [hl]
    ld l, l
    cp $03
    ld h, l
    ld l, [hl]
    ld l, l
    ld d, c
    ld d, a
    ldh [c], a
    ld h, l
    ld l, [hl]
    cp $04
    ld h, [hl]
    ld l, l
    ld l, [hl]
    ld h, l
    ld d, c
    ld e, b
    ldh [c], a
    ld h, [hl]
    ld l, l
    cp $06
    ld h, l
    ld l, [hl]
    ld l, l
    ld l, [hl]
    ld l, l
    ld d, [hl]
    call nz, Routine_DataProcess_D
    ld l, l
    ld l, [hl]
    cp $06
    ld h, [hl]
    ld l, l
    ld l, [hl]
    ld l, l
    ld l, [hl]
    ld e, b
    call nz, Routine_DataProcess_J
    ld l, [hl]
    ld l, l
    cp $05
    ld h, l
    ld l, [hl]
    ld l, l
    ld l, [hl]
    ld l, l
    ld h, d
    ld e, l
    dec [hl]
    call nz, $6d65
    ld l, l
    ld l, [hl]
    cp $06
    ld h, [hl]
    ld l, l
    ld l, [hl]
    ld l, l
    ld l, [hl]
    ld d, [hl]
    call nz, Routine_DataProcess_J
    ld l, [hl]
    ld l, l
    cp $16
    ld l, [hl]

UnknownCode_002_702a:
    ld l, l
    ld l, [hl]
    ld l, l
    ld e, c
    ld e, e
    call nz, $6d65
    ld l, l
    ld l, [hl]
    cp $07
    db $f4
    ld l, l

UnknownCode_002_7038:
    ld l, [hl]
    ld l, l
    ld l, [hl]
    ld e, d
    ld e, h
    call nz, Routine_DataProcess_J
    ld l, [hl]
    ld l, l
    cp $06
    db $f4
    ld l, [hl]
    ld l, l
    ld l, [hl]
    ld l, l
    dec hl
    call nz, $6d65
    ld l, l
    ld l, [hl]
    cp $06
    db $f4
    ld l, l
    ld l, [hl]
    ld l, l
    ld l, [hl]
    add hl, hl
    call nz, Routine_DataProcess_J
    ld l, [hl]
    ld l, l
    cp $07
    db $f4
    ld l, [hl]
    ld l, l
    ld l, [hl]
    ld l, l
    ld d, l
    jr c, UnknownCode_002_702a

    ld h, l
    ld l, l
    ld l, l
    ld l, [hl]
    cp $07
    db $f4
    ld l, l
    ld l, [hl]
    ld l, l
    ld l, [hl]
    ld d, a
    jr c, UnknownCode_002_7038

    ld h, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, l
    cp $07
    db $f4
    ld l, [hl]
    ld l, l
    ld l, [hl]
    ld l, l
    ld d, l
    ld d, [hl]
    call nz, $6d65
    ld l, l
    ld l, [hl]
    cp $06
    db $f4
    ld h, l
    ld l, [hl]
    ld l, l
    ld l, [hl]
    ld d, l
    call nz, Routine_DataProcess_J
    ld l, [hl]
    ld l, l
    cp $06
    db $f4
    ld h, [hl]
    ld l, l
    ld l, [hl]
    ld l, l
    ld d, a
    call nz, ProcessInputState_Bank2_Part1
    ld l, l
    ld l, [hl]
    cp $06
    db $f4
    ld h, l
    ld l, [hl]
    ld l, l
    ld l, [hl]
    dec hl
    call nz, ProcessInputState_Bank2_Part2
    ld l, [hl]
    ld l, l
    cp $05
    db $f4

UnknownCode_002_70b0:
    ld h, [hl]
    ld l, l
    ld l, [hl]
    ld l, l
    call nz, $6d65
    ld l, l
    ld l, [hl]
    cp $05
    db $f4
    ld h, l
    ld l, [hl]
    ld l, l
    ld l, [hl]
    ld h, d
    ld e, l
    dec [hl]
    call nz, Routine_DataProcess_J
    ld l, [hl]
    ld l, l
    cp $06
    db $f4
    ld h, [hl]
    ld l, l
    ld l, [hl]
    ld l, l
    ld d, l
    call nz, $6d65
    ld l, l
    ld l, [hl]
    cp $06
    db $f4
    ld h, l
    ld l, [hl]
    ld l, l
    ld l, [hl]
    ld e, b
    call nz, Routine_DataProcess_J
    ld l, [hl]
    ld l, l
    cp $07
    db $f4
    ld h, [hl]
    ld l, l
    ld l, [hl]
    ld l, l
    ld d, [hl]
    jr c, UnknownCode_002_70b0

    ld [hl], b
    ld [hl], d
    ld l, l
    ld l, [hl]
    cp $15
    ld h, l
    ld l, [hl]
    ld l, l
    ld l, [hl]
    ld d, l
    call nz, ProcessInputState_Bank2_Part2
    ld l, [hl]
    ld l, l
    cp $11
    ld h, [hl]
    ld sp, $a666
    ld [hl], b
    ld [hl], d

UnknownCode_002_7104:
    ld [hl], d
    ld [hl], d
    ld l, l
    ld l, [hl]
    cp $22
    ld e, c
    ld e, e
    and [hl]
    ld [hl], c
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld l, [hl]
    ld l, l
    cp $22
    ld e, d
    ld e, h
    ldh [c], a
    ld h, l
    ld l, [hl]
    cp $e2
    ld h, [hl]
    ld l, l
    cp $31
    jr c, UnknownCode_002_7104

    ld h, l
    ld l, [hl]
    cp $31
    ld d, l
    ld d, d
    ld e, l
    dec [hl]
    ldh [c], a
    ld h, [hl]
    ld l, l
    cp $32
    ld d, [hl]
    ld d, l
    ldh [c], a
    ld h, l
    ld h, [hl]
    cp $32
    ld d, a
    dec hl
    pop hl
    ld h, [hl]
    cp $32
    ld e, b
    dec hl
    cp $32
    ld d, a

UnknownCode_002_7141:
    jr c, UnknownCode_002_7141

    ld [hl-], a
    ld d, [hl]

JoypadInputEntry_7145:
    jr c, JoypadInputEntry_7145

    cp $31

JoypadInputEntry_7149:
    ld d, [hl]
    ld d, d
    ld e, l
    dec [hl]
    pop hl
    ld h, l
    cp $31
    ld d, l
    ldh [c], a
    ld h, [hl]
    ld h, l
    cp $31
    ld d, [hl]
    ldh [c], a
    ld h, l
    ld l, [hl]
    cp $31
    ld d, a
    ldh [c], a
    ld h, [hl]
    ld l, l
    cp $23
    ld e, c
    ld e, e
    jr c, JoypadInputEntry_7149

    ld h, l
    ld l, [hl]
    cp $14
    ld h, l
    ld e, d
    ld e, h
    ld d, l
    ldh [c], a
    ld h, [hl]
    ld c, l
    cp $02
    ld h, l
    ld l, [hl]
    ld b, d
    db $fd
    jr c, @-$1c

    ld h, l
    ld c, [hl]
    cp $02
    ld h, [hl]
    ld l, l
    ld [hl-], a
    ld h, l
    ld d, [hl]
    ldh [c], a
    ld h, [hl]
    ld c, l
    cp $04
    ld h, h
    ld h, h
    ld d, c
    ld d, l
    or l
    db $fd
    ld h, h
    cp $04
    ld h, h
    ld h, h
    ld d, c
    ld d, [hl]
    or l
    db $fd
    ld h, h
    cp $04
    ld h, h
    ld h, h
    ld d, c
    ld d, a
    ldh [c], a
    dec sp
    ld d, e
    cp $06
    ld h, h
    ld h, h
    ld d, c
    ld d, l
    ld e, l
    dec [hl]
    ldh [c], a
    dec sp
    ld d, e
    cp $03
    ld h, h
    ld h, h
    ld d, c
    ldh [c], a
    db $fd
    ld h, h
    cp $05
    ld h, h
    ld h, h
    ld d, c
    ld e, c
    ld e, e
    ldh [c], a
    db $fd
    ld h, h
    cp $05
    ld h, h
    ld h, h
    ld d, c
    ld e, d
    ld e, h
    ldh [c], a
    db $fd
    ld h, h
    cp $05
    ld h, h
    ld h, h
    ld d, c
    ld d, l
    ld d, [hl]
    ldh [c], a
    db $fd
    ld h, h
    cp $04
    ld h, h
    ld h, h
    ld d, c
    dec hl
    ldh [c], a
    dec sp
    ld d, e
    cp $04
    ld h, h
    ld h, h
    ld d, c
    ld d, l
    db $d3
    ld a, a
    dec sp
    ld d, e
    cp $05
    ld h, h
    ld h, h
    ld d, c
    ld d, a
    ld d, [hl]
    db $d3
    ld a, a
    dec sp
    ld d, e
    cp $05
    ld h, h
    ld h, h
    ld d, c
    ld e, c
    ld e, e
    db $d3
    ld a, a
    dec sp
    ld d, e
    cp $05
    ld h, h
    ld h, h
    ld d, c
    ld e, d
    ld e, h
    db $d3
    ld a, a
    dec sp
    ld d, e
    cp $03
    ld h, h
    ld h, h
    ld d, c
    db $d3
    ld a, a
    dec sp
    ld d, e
    cp $06
    ld h, h
    ld h, h
    dec a
    ld d, d
    ld e, l
    dec [hl]
    call nz, PaddingData_7f3a
    dec sp
    ld d, e
    cp $06
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld d, c
    ld d, [hl]
    call nz, Routine_DataProcess_I
    cp $06
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld d, c
    dec hl
    call nz, Routine_DataProcess_I
    cp $06
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld d, c
    ld d, a
    call nz, Routine_DataProcess_I
    cp $04
    ld h, h
    ld h, h
    ld c, a
    ld d, b
    ld d, c
    ld d, l
    call nz, Routine_DataProcess_I
    cp $03
    ld h, h
    ld h, h
    ld d, c
    ld d, c
    ld e, b
    call nz, Routine_DataProcess_I
    cp $13
    ld h, [hl]
    ld l, l
    ld l, [hl]
    pop af
    ld h, [hl]
    cp $22
    ld h, [hl]
    ld l, l
    cp $22
    ld h, l
    ld l, [hl]
    cp $22
    ld h, [hl]
    ld l, l
    cp $22
    ld h, l
    ld l, [hl]
    ld d, d
    ld e, l
    dec [hl]
    pop hl
    ld h, l
    cp $22

ProcessInputState_Bank2_Part1:
    ld h, [hl]
    ld l, l
    ldh [c], a
    ld h, [hl]
    ld h, l
    cp $22
    ld h, l
    ld l, [hl]
    ldh [c], a
    ld h, l
    ld l, [hl]
    cp $22
    ld h, [hl]
    ld l, l
    ldh [c], a
    ld h, [hl]
    ld l, l
    cp $13
    ld [hl], b
    ld [hl], d
    ld l, [hl]
    ldh [c], a
    ld h, l
    ld l, [hl]
    cp $13
    ld [hl], c
    ld [hl], e
    ld l, l
    db $d3
    ld h, e
    ld l, [hl]
    ld l, l
    cp $31
    ld h, [hl]
    call nz, $6363
    ld l, l
    ld l, [hl]
    cp $b5
    ld h, e
    ld h, e
    ld h, e
    ld l, [hl]
    ld l, l
    cp $a6
    ld h, e
    ld h, e
    ld h, e
    ld h, e
    ld l, l
    ld l, [hl]
    cp $13
    ld e, c
    ld e, e
    ld d, l
    sub a
    ld h, e
    ld h, e
    ld h, e
    ld h, e
    ld h, e
    ld l, [hl]
    ld l, l
    cp $13
    ld e, d
    ld e, h
    ld d, [hl]
    and [hl]
    ld h, e
    ld h, e
    ld h, e
    ld h, e
    ld l, l
    ld l, [hl]
    cp $31
    ld d, a
    or l
    ld h, e
    ld h, e
    ld h, e
    ld l, [hl]
    ld l, l
    cp $11
    dec hl
    ld sp, $c458
    ld h, e
    ld h, e
    ld l, l
    ld l, [hl]
    cp $11
    ld d, [hl]
    ld d, d
    ld e, l
    dec [hl]
    db $d3
    ld h, e
    ld l, [hl]
    ld l, l
    cp $11
    ld d, l
    ld sp, $e256
    ld h, l
    ld l, [hl]
    cp $11
    ld d, a
    ld sp, $e255
    ld h, [hl]
    ld h, h
    cp $f1
    ld h, h
    cp $f1
    ld h, h
    cp $d1
    ld a, a
    pop af
    ld h, h
    cp $01
    ld h, l
    ld hl, $4165
    ld h, l
    ld h, l
    ld h, l
    add c
    add d
    add d
    add d
    pop de
    ld a, a
    pop af
    ld h, h
    cp $0b
    ld h, [hl]
    ld h, l
    ld l, [hl]
    ld h, l
    ld h, [hl]
    ld h, l
    ld h, [hl]
    add c
    add d
    add d
    add d
    pop de
    ld a, a
    pop af
    ld h, h
    cp $04
    ld h, l
    ld l, [hl]
    ld l, l
    ld h, [hl]
    ld d, c
    ld h, [hl]
    or c
    ld l, e
    pop de
    ld l, e
    pop af
    ld h, h
    cp $04
    ld h, [hl]
    ld l, l
    ld h, [hl]
    ld d, l
    and d
    db $f4
    ld l, e
    pop de
    ld l, e
    pop af
    ld h, h
    cp $02
    ld h, l
    ld l, [hl]
    ld b, d
    ld e, l
    dec [hl]
    or e
    ld l, e
    db $f4
    ld l, e
    pop af
    ld h, h
    cp $02
    ld h, [hl]
    ld l, l
    ld [hl-], a
    ld e, c
    ld e, e
    and d
    db $f4
    ld l, e
    pop de
    ld l, e
    pop af
    ld h, h
    cp $02
    ld h, l
    ld l, [hl]
    ld [hl-], a
    ld e, d
    ld e, h
    or e
    ld l, e
    db $f4
    ld l, e
    pop af
    ld h, h
    cp $02
    ld h, [hl]
    ld l, l
    ld sp, $a258
    db $f4
    ld l, e
    pop de
    ld l, e
    pop af
    ld h, h
    cp $02
    ld h, l

ProcessInputState_Bank2_Part2:
    ld l, [hl]
    ld sp, $7756
    ld d, d
    ld d, d
    ld d, d
    ld d, d
    ld l, e
    db $f4
    ld l, e
    pop af
    ld h, h
    cp $02
    ld h, [hl]
    ld l, l
    ld sp, $7557
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld l, e
    pop de
    ld l, e
    pop af
    ld h, h
    cp $02
    ld h, l
    ld l, [hl]
    ld sp, $7258
    ld h, h
    ld e, a
    pop de
    ld l, e
    pop af
    ld h, h
    cp $02
    ld h, [hl]
    ld l, l
    ld [hl], c
    ld h, h
    pop de
    ld l, e
    pop af
    ld h, h
    cp $02
    ld h, l
    ld l, [hl]
    ld sp, $7155
    ld h, h
    pop de
    ld l, e
    pop af
    ld h, h
    cp $02
    ld h, [hl]
    ld l, l
    ld sp, $7157
    ld h, h
    pop de
    ld l, e
    pop af
    ld h, h
    cp $02
    ld h, l
    ld l, [hl]
    ld sp, $7156
    ld d, b
    pop de
    ld l, e
    pop af
    ld h, h
    cp $02
    ld h, [hl]
    ld l, l
    ld sp, wStackInit
    ld l, e
    pop af
    ld h, h
    cp $03
    ld h, l
    ld l, [hl]
    ld h, l
    ld b, d
    ld e, l
    dec [hl]
    pop de
    ld l, e
    pop af
    ld h, h
    cp $04
    ld h, [hl]
    ld l, l
    ld l, [hl]
    ld d, a
    jp nz, DataTable_6b63

    pop af
    ld h, h
    cp $04
    ld h, l
    ld l, [hl]
    ld l, l
    ld d, l
    or e
    ld h, e
    db $f4
    db $f4
    pop af
    ld h, h
    cp $03
    ld h, [hl]
    ld l, l
    ld h, [hl]
    and [hl]
    ld h, e
    db $f4
    db $f4
    db $f4
    ld d, d
    ld h, h
    cp $02
    ld h, l
    ld l, [hl]
    sub a
    ld h, e
    db $f4
    db $f4
    db $f4
    db $f4
    ld h, h
    ld h, h
    cp $02
    ld h, [hl]
    ld l, l
    add c
    ld h, e
    and [hl]
    db $f4
    db $f4
    db $f4
    db $f4
    ld d, b
    ld h, h
    cp $02
    ld h, l
    ld l, [hl]
    ld [hl], c
    ld h, e
    and h
    db $fd
    db $f4
    pop af
    ld h, h
    cp $02
    ld h, [hl]
    ld l, l
    ld sp, $6156
    ld h, e
    and h
    db $f4
    add c
    db $f4
    db $f4
    pop af
    ld h, h
    cp $02
    ld h, l
    ld l, [hl]
    ld sp, $7155
    ld h, e
    and h
    db $fd
    db $f4
    pop af
    ld h, h
    cp $02
    ld h, [hl]
    ld l, l
    add c
    ld h, e
    and h
    db $fd
    db $f4
    pop af
    ld h, h
    cp $02
    ld h, l
    ld l, [hl]
    ld sp, $9556
    ld h, e
    db $f4
    db $f4
    db $f4
    db $f4
    pop af
    ld h, h
    cp $02
    ld h, [hl]
    ld l, l
    ld [hl-], a
    ld d, a
    dec hl
    and h
    add d
    db $f4
    db $f4
    db $f4
    pop af
    ld h, h
    cp $02
    ld h, l
    ld l, [hl]
    ld [hl-], a
    ld d, l
    dec hl
    or e
    add d
    db $f4
    db $f4
    pop af
    ld h, h
    cp $02
    ld h, [hl]
    ld l, l
    ld [hl-], a
    ld e, c
    ld e, e
    jp nz, $f463

    pop af
    ld h, h
    cp $02
    ld h, l
    ld l, [hl]
    ld [hl-], a
    ld e, d
    ld e, h
    pop de
    ld h, e
    cp $02
    ld h, [hl]
    ld l, l
    ld sp, $d356
    db $fd
    ld h, h
    cp $02
    ld h, l
    ld l, [hl]
    inc sp
    ld d, a
    ld e, l
    dec [hl]
    db $d3
    db $fd
    ld h, h
    cp $02
    ld h, [hl]
    ld l, l
    ld sp, $a655
    ld d, d
    ld d, d
    ld d, d
    ld h, h
    ld h, h
    ld h, h
    cp $02
    ld h, h
    ld l, [hl]
    and [hl]
    db $fd
    ld h, h
    cp $05
    ld h, h
    ld h, h
    ld d, c
    ld e, c
    ld e, e
    and [hl]
    db $fd
    ld h, h
    cp $05
    ld h, h
    ld h, h
    ld d, c
    ld e, d
    ld e, h
    and [hl]
    db $fd
    ld h, h
    cp $04
    ld h, h
    ld h, h
    ld d, c
    dec hl
    and [hl]
    db $fd
    ld d, b
    cp $04
    ld h, h
    ld h, h
    ld d, c
    ld d, a
    sub a
    db $fd
    ld d, d
    cp $04
    ld h, h
    ld h, h
    ld d, c
    dec h
    sub a
    db $fd
    ld h, h
    cp $03
    ld h, h
    ld h, h
    ld d, c
    ld b, d
    ld e, l
    dec [hl]
    sub a
    db $fd
    ld h, h
    cp $03
    ld h, h
    ld h, h
    ld d, c
    sub a
    ld d, b
    ld d, b
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    cp $05
    ld h, h
    ld h, h
    dec a
    ld d, d
    ld d, d
    or l
    db $fd
    ld h, h
    cp $06
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld d, c
    ld [hl], d
    db $fd
    add d
    or l
    db $fd
    ld h, h
    cp $06
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld d, c
    ld a, c
    add d
    add d
    ld c, b
    ld c, d
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    cp $06
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld d, c
    ld a, c
    add d
    add d
    ld c, c
    ld c, e
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    cp $06
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld d, c
    ld [hl], d
    db $fd
    add d
    and [hl]
    ld c, h
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    cp $06
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld d, c
    ld [hl], d
    db $fd
    add d
    or l
    db $fd
    ld h, h
    cp $06
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld d, c
    ld a, c
    add b
    add d
    ld c, b
    ld c, d
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    cp $06
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld d, c
    ld a, c
    add d
    add d
    ld c, c
    ld c, e
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    cp $06
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld d, c
    ld [hl], d
    db $fd
    add d
    and [hl]
    ld c, h
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    cp $05
    ld h, h
    ld h, h
    ld c, a
    ld d, b
    ld d, b
    or l
    db $fd
    ld h, h
    cp $06
    ld h, h
    ld h, h
    ld d, c
    ld e, b
    ld e, l
    dec [hl]
    or l
    db $fd
    ld h, h
    cp $05
    ld h, h
    ld h, h
    ld d, c
    ld e, c
    ld e, e
    or l
    db $fd
    ld d, b
    cp $05
    ld h, h
    ld h, h
    ld d, c
    ld e, d
    ld e, h
    cp $09
    ld h, h
    ld h, h
    ld d, c
    ld d, l
    ld d, [hl]
    ld d, a
    ld d, l
    ld d, [hl]
    ld d, l
    cp $03
    ld h, h
    ld h, h
    ld d, c
    or l
    db $fd
    ld d, d
    cp $03
    ld h, h
    ld h, h
    ld d, c
    ld d, c
    ld d, l
    call nz, Routine_DataProcess_I
    cp $04
    ld h, h
    ld h, h
    dec a
    ld d, d
    ld d, c
    ld d, [hl]
    call nz, Routine_DataProcess_I
    cp $06
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld d, c
    ld d, a
    pop bc
    ld a, a
    ldh [c], a
    dec sp
    ld d, e
    cp $06
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld d, c
    ld e, b
    pop bc
    ld a, a
    ldh [c], a
    dec sp
    ld d, e
    cp $06
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld d, c
    ld d, a
    pop bc
    ld a, a
    ldh [c], a
    dec sp
    ld d, e
    cp $06
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld d, c
    dec hl
    pop bc
    ld a, a
    ldh [c], a
    dec sp
    ld d, e
    cp $06
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld d, c
    ld d, l
    pop bc
    ld a, a
    ldh [c], a
    dec sp
    ld d, e
    cp $06
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld d, c
    ld d, [hl]
    pop bc
    ld a, a
    ldh [c], a
    dec sp
    ld d, e
    cp $06
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld d, c
    ld d, a
    pop bc
    ld a, a
    ldh [c], a
    dec sp
    ld d, e
    cp $06
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld d, c
    dec h
    pop bc
    ld a, a
    ldh [c], a
    dec sp
    ld d, e
    cp $06
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld d, c
    ld d, [hl]
    pop bc
    ld a, a
    ldh [c], a
    dec sp
    ld d, e
    cp $06
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld d, c
    ld d, l
    pop bc
    ld a, a
    ldh [c], a
    dec sp
    ld d, e
    cp $06
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld d, c
    ld d, [hl]
    pop bc
    ld a, a
    ldh [c], a
    dec sp
    ld d, e
    cp $05
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld d, c
    pop bc
    ld a, a
    ldh [c], a
    dec sp
    ld d, e
    cp $07
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld d, c
    ld e, l
    dec [hl]
    pop bc
    ld a, a
    ldh [c], a
    dec sp
    ld d, e
    cp $05
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld d, c
    or d
    ld a, [hl-]
    ld a, a
    ldh [c], a
    dec sp
    ld d, e
    cp $07
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld d, c
    ld e, l
    dec [hl]
    and c
    ld a, [hl-]
    pop bc
    ld a, a
    ldh [c], a
    dec sp
    ld d, e
    cp $06
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    dec a
    ld d, d
    sub a
    pop hl
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    cp $00
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    db $ec
    db $ec
    db $ec
    db $ec
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    cp $06
    db $fd
    ld h, h
    and [hl]
    db $fd
    ld h, h
    cp $00
    db $fd
    ld a, a
    cp $e2
    db $fd
    ld a, a
    cp $e2
    db $fd
    ld a, a
    cp $e2
    db $fd
    ld a, a

UnknownCode_002_76d9:
    cp $e2
    db $fd
    ld a, a
    cp $01

UnknownCode_002_76df:
    ld a, a
    jr c, UnknownCode_002_76df

    add d
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    and c
    add d
    db $d3
    db $f4
    ld a, a
    ld a, a
    cp $01
    ld a, a
    ld sp, $51f4
    db $f4
    ld [hl], c
    db $f4
    sub d
    db $f4
    add d
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    ld sp, $51f4
    db $f4
    ld [hl], c
    db $f4
    sub d
    db $f4
    add d
    db $d3
    db $f4
    ld a, a
    ld a, a
    cp $01
    ld a, a
    ld sp, $51f4
    db $f4
    ld [hl], c
    db $f4
    sub d
    db $f4
    add d
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    ld sp, $51f4
    db $f4
    ld [hl], c
    db $f4
    sub d
    db $f4
    add d
    db $d3
    db $f4
    ld a, a
    ld a, a
    cp $01
    ld a, a
    ld sp, $51f4
    db $f4
    ld [hl], c
    db $f4
    sub d
    db $f4
    add d
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    ld sp, $51f4
    db $f4
    ld [hl], c
    db $f4
    sub d
    db $f4
    add d
    db $d3
    db $f4
    ld a, a
    ld a, a
    cp $01
    ld a, a
    and c
    add d
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    jr c, UnknownCode_002_76d9

    add d
    add d
    add d
    add d
    add d
    add d
    add d
    db $d3
    db $f4
    ld a, a
    ld a, a
    cp $e2
    db $fd
    ld a, a
    cp $72
    db $fd
    db $f4
    call nz, Routine_DataProcess_F
    ld a, a
    ld a, a
    cp $72
    db $fd

Routine_DataProcess_F:
    db $f4
    call nz, Routine_DataProcess_G
    ld a, a
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
    halt
    ld a, c
    ld a, a
    ld a, a
    cp $00
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld a, a
    ld a, a
    cp $00
    db $fd
    ld a, a
    cp $f1
    ld a, a
    cp $f1
    ld a, a
    cp $0c
    db $fd
    ld a, a
    pop af
    ld a, a
    cp $01
    ld a, a
    ld sp, $a27f
    db $f4
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
    or c
    add d
    pop af
    ld a, a
    cp $01
    ld a, a
    ld sp, $7180
    add d
    and d
    db $f4
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
    or c
    add d
    pop af
    ld a, a
    cp $01
    ld a, a
    ld sp, $7182
    add b
    and d
    db $f4
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
    or c
    add d
    pop af
    ld a, a
    cp $01
    ld a, a
    ld sp, $7182
    ld a, a
    and d
    db $f4
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
    or c
    add d
    pop af
    ld a, a
    cp $01
    ld a, a
    ld [hl], c
    ld a, a
    and d
    db $f4
    ld a, a
    pop af
    ld a, a
    cp $01
    ld a, a
    ld h, d
    db $f4
    add d
    or c
    add d
    pop af
    ld a, a
    cp $01
    ld a, a
    ld sp, $717f
    ld a, a
    and d
    db $f4
    ld a, a
    pop af
    ld a, a
    cp $01
    ld a, a
    ld sp, $627f
    db $f4
    ld a, a
    or c
    add b
    pop af
    ld a, a
    cp $04
    ld a, a
    ld [hl], h
    ld [hl], a
    ld a, a
    ld [hl], c
    ld a, a
    and d
    db $f4
    ld a, a
    pop af
    ld a, a
    cp $04
    ld a, a
    ld [hl], l
    ld a, b
    ld a, a
    ld h, d
    db $f4
    ld a, a
    or c
    add d
    pop af
    ld a, a
    cp $04
    ld [hl], d
    halt
    ld a, c
    ld a, a
    ld [hl], c
    ld a, a
    pop af
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
    cp $ff
    rst $38

Routine_DataProcess_G:
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
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
    rst $38
    rst $38
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
    rst $38
    nop
    nop
    nop
    rst $38
    rst $38
    nop
    nop
    nop
    nop
    ld bc, $0101
    ld bc, $0303
    rst $38
    nop
    nop
    nop
    rst $38
    rst $38
    nop
    nop
    ld a, a
    ld a, a
    ret nz

    ret nz

    ccf
    nop
    rst $38
    nop
    rst $38
    nop
    nop
    nop
    rst $38
    rst $38
    nop
    nop
    ldh a, [hCurrentTile]
    db $10
    db $10
    rst $30
    rla
    db $f4
    inc d
    rst $38
    nop
    nop
    nop
    rst $38
    rst $38
    nop
    nop
    nop
    nop
    nop
    nop
    rst $18
    rst $18
    ld d, b
    ld d, b
    rst $38
    nop
    nop
    nop
    rst $38
    rst $38
    nop
    nop
    nop
    nop
    nop
    nop
    cp a
    cp a
    and b
    and b
    rst $38
    nop
    nop
    nop
    rst $38
    rst $38
    nop
    nop
    nop
    nop
    nop
    nop
    pop af
    pop af
    add hl, de
    add hl, de
    rst $38
    nop
    nop
    nop
    rst $38
    rst $38
    nop
    nop
    nop
    nop
    nop
    nop
    rst $38
    rst $38
    nop
    nop
    rst $38
    nop
    nop
    nop
    rst $38
    rst $38
    nop
    nop
    nop
    nop
    nop
    nop
    cp a
    cp a
    and b
    and b
    rst $38
    nop
    nop
    nop
    rst $38
    rst $38
    nop
    nop
    nop
    nop
    nop
    nop
    ldh a, [hCurrentTile]
    jr PaddingZone_002_79f2

    rst $38
    rst $38
    rst $38
    rst $38
    nop
    rst $38
    nop
    nop
    rst $38
    nop
    nop
    nop
    rst $38
    nop
    nop
    nop
    rst $38
    rst $38
    rst $38
    rst $38
    ld d, l
    ld d, l
    xor d
    xor d

PaddingZone_002_79f2:
    ld d, l
    ld d, l
    nop
    nop
    nop
    nop
    nop
    nop
    inc e
    inc e
    ld [hl+], a
    ld [hl+], a
    ld e, l
    ld e, l
    ld d, c
    ld d, c
    ld e, l
    ld e, l
    ld [hl+], a
    ld [hl+], a
    inc e
    inc e
    nop
    nop
    nop
    ld d, $00
    add hl, hl
    nop
    ld b, b
    inc b
    add b
    ld e, l
    add b
    ld a, $41
    inc c
    ld [hl-], a
    nop
    inc c
    ccf
    jr nz, UnknownCode_002_7a8d

    ld d, b
    ld l, a
    ld c, a
    ld l, b
    ld c, b
    ld l, b
    ld c, b
    ld l, b
    ld c, b
    ld l, b
    ld c, b
    ld l, b
    ld c, b
    rst $38
    nop
    nop
    nop
    rst $38
    rst $38
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
    db $fc
    inc e
    ld l, $3e
    xor $de
    ld l, [hl]
    ld e, [hl]
    ld l, [hl]
    ld e, [hl]
    ld l, [hl]
    ld e, [hl]
    ld l, [hl]
    ld e, [hl]
    ld l, [hl]
    ld e, [hl]
    inc bc
    ld [bc], a
    inc bc
    ld [bc], a
    inc bc
    ld [bc], a
    inc bc
    inc bc
    ld bc, $0101
    ld bc, $0000
    nop
    nop
    rst $38
    nop
    rst $38
    rlca
    db $fc
    inc c
    rst $30
    rlca

UnknownCode_002_7a62:
    ld sp, hl
    ld bc, wGameVarFE
    ld a, a
    ld [hl], b
    dec de
    jr UnknownCode_002_7a62

    inc d
    rst $30
    db $f4
    rlca
    inc b
    rlca

UnknownCode_002_7a71:
    inc b
    rst $00
    call nz, Routine_DataProcess_C
    or a
    inc [hl]
    rst $10
    inc d
    rst $18
    ld d, b
    rst $18
    ld d, b
    rst $18
    ld d, b
    rst $18
    ld d, b
    rst $18
    ld d, b
    rst $18
    ld d, b
    rst $18
    ld d, b
    rst $38
    ld [hl], b
    cp a
    and b
    cp a

UnknownCode_002_7a8d:
    and e
    cp [hl]
    and d
    cp [hl]
    and d
    cp [hl]
    and d
    cp [hl]
    and d
    cp [hl]
    and d
    cp a
    and e
    db $ed
    dec c
    push af
    add l
    db $fd
    add l
    db $fd
    add l
    db $fd
    add l
    db $fd
    add l
    db $fd
    add l
    db $fd
    add l
    rst $38
    nop
    rst $38
    rra
    ldh a, [rNR10]
    rst $38
    rra
    ldh a, [rP1]
    rst $38
    nop
    rst $38

UnknownCode_002_7ab7:
    rra
    ldh a, [rNR10]
    cp a
    and b
    cp a
    and e
    ld a, $22
    cp [hl]
    and d
    cp [hl]
    and d
    cp [hl]
    and d
    cp a
    and e
    inc a
    jr nz, UnknownCode_002_7ab7

    inc c
    db $f4
    add h
    db $fc
    add h
    db $fc
    add h
    db $fc
    add h
    db $fc
    add h
    db $fc
    adc h
    ld a, b
    jr AudioDispatchEntry_7adb

AudioDispatchEntry_7adb:
    ld l, b
    nop
    sub [hl]
    nop
    ld bc, $0084
    push de
    nop
    rst $38
    nop
    inc [hl]
    rlc b
    inc [hl]
    nop
    nop
    nop
    ret nz

    nop
    jr nz, UnknownCode_002_7a71

    db $10
    add b
    ld h, b
    nop
    add b
    nop
    nop
    nop
    nop
    add $c6
    and $e6
    and $e6
    sub $d6
    sub $d6
    adc $ce
    adc $ce
    add $c6
    ret nz

    ret nz

    ret nz

    ret nz

    nop
    nop
    db $db
    db $db
    db $dd
    db $dd
    reti


    reti


    reti


    reti


    reti


    reti


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
    ld bc, $0001
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
    db $fd
    db $fd
    add a
    add a
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
    db $fc
    db $fc
    ld b, $06
    ld a, a
    ld a, a
    ld b, b
    ld b, b
    ld a, a
    ld b, b
    ld a, a
    ld b, b
    ld a, a
    ld b, b
    ld a, a
    ld a, a
    nop
    nop
    nop
    nop
    ei
    ld hl, sp+$0f
    nop
    rst $38
    nop
    rst $38
    nop
    rst $38
    nop
    rst $38
    rst $38
    nop
    nop
    nop
    nop
    rst $30
    inc d
    rst $30
    inc d
    rst $30
    inc d
    rst $30
    ld [hl], $e3
    db $e3
    add c
    add c
    nop
    nop
    nop
    nop
    adc a
    nop
    rst $38
    nop
    rst $38
    nop
    rst $38
    ld bc, $03ff
    cp $fe
    nop
    nop
    nop
    nop
    cp h
    and b
    cp a
    and b
    cp a
    and e
    cp [hl]
    and d
    ld a, $22
    ld a, $3e
    nop
    nop
    nop
    nop
    ld a, l
    dec c
    ld sp, hl
    add hl, de
    pop af
    pop af
    ld bc, $0101
    ld bc, $0101
    nop
    nop
    nop
    nop
    rst $38
    rra
    ldh a, [rP1]
    rst $38
    nop
    rst $38
    nop
    rst $38
    nop
    rst $38
    rst $38
    nop
    nop
    nop
    nop
    cp a
    and b
    cp a
    and e
    cp [hl]
    and d
    cp [hl]
    and d
    cp [hl]
    and d
    cp [hl]
    cp [hl]
    nop
    nop
    nop
    nop
    ldh a, [$ff30]
    ret c

    sbc b
    db $ec
    adc h
    or $86
    ld a, [$fe82]
    cp $00
    nop
    nop
    nop
    nop
    nop
    jr nc, UnknownCode_002_7c0e

    ld a, b
    ld a, b
    inc sp
    inc sp
    or [hl]
    or [hl]
    or a
    or a
    or [hl]
    or [hl]
    or e
    or e
    nop
    nop
    nop
    nop
    nop
    nop
    call $6ecd
    ld l, [hl]
    db $ec
    db $ec
    inc c
    inc c
    db $ec
    db $ec
    ld bc, $0101
    ld bc, $0101
    adc a
    adc a
    reti


    reti


    reti


    reti


    reti


    reti


    rst $08
    rst $08
    add b
    add b
    add b
    add b

UnknownCode_002_7c0e:
    add b
    add b
    sbc [hl]
    sbc [hl]
    or e
    or e
    or e
    or e
    or e
    or e
    sbc [hl]
    sbc [hl]
    inc bc
    inc bc
    inc bc
    ld [bc], a
    inc bc
    ld [bc], a
    inc bc
    ld [bc], a

UnknownCode_002_7c22:
    inc bc
    ld [bc], a

UnknownCode_002_7c24:
    inc bc
    ld [bc], a

AudioDispatchEntry_7c26:
    inc bc
    ld [bc], a

AudioDispatchEntry_7c28:
    inc bc
    ld [bc], a
    ei
    ld [bc], a
    rst $38
    nop
    rst $38
    nop
    rst $38
    jr c, UnknownCode_002_7c22

    jr z, UnknownCode_002_7c24

    jr z, AudioDispatchEntry_7c26

    jr z, AudioDispatchEntry_7c28

    jr z, @-$03

    inc bc
    db $fd
    ld bc, $01ff
    rst $38
    pop hl
    cp a
    and c
    cp a
    and c
    cp a
    and c
    cp a
    and c
    rra
    rra
    jr nc, UnknownCode_002_7c7e

    ld a, a
    ld h, b
    ld a, a
    ld b, a
    ld a, l
    ld b, l
    ld a, l
    ld b, l
    ld a, l
    ld b, l
    ld a, l
    ld b, l
    db $e3
    db $e3
    ld [hl-], a
    ld [hl-], a
    db $db
    ld a, [de]
    db $eb
    ld a, [bc]

UnknownCode_002_7c62:
    ei
    ld a, [bc]

UnknownCode_002_7c64:
    ei
    ld a, [bc]

AudioDispatchEntry_7c66:
    ei
    ld a, [bc]

AudioDispatchEntry_7c68:
    ei
    ld a, [bc]
    rst $38
    rst $38
    ld bc, $fe01
    nop
    rst $38
    jr c, UnknownCode_002_7c62

    jr z, UnknownCode_002_7c64

    jr z, AudioDispatchEntry_7c66

    jr z, AudioDispatchEntry_7c68

    jr z, UnknownCode_002_7c9a

    rra
    sub c
    sub c

UnknownCode_002_7c7e:
    rst $18
    pop de
    ld e, a
    ld d, c
    rst $18
    ld d, c
    rst $18
    ld d, c
    rst $18
    ld d, c
    rst $18
    ld d, c
    rra
    rra
    jr nc, UnknownCode_002_7cbe

    ld a, a
    ld h, b
    ld a, a
    ld b, a
    ld a, l
    ld b, l
    ld a, l
    ld b, l
    ld a, l
    ld b, l
    ld a, l
    ld b, l

UnknownCode_002_7c9a:
    pop hl
    pop hl
    ld sp, $d931
    add hl, de
    jp hl


    add hl, bc
    ld sp, hl
    add hl, bc
    ld sp, hl
    add hl, bc
    ld sp, hl
    add hl, bc
    ld sp, hl
    add hl, bc
    ldh a, [hCurrentTile]
    db $10
    db $10
    ldh a, [rNR10]
    ldh a, [rNR10]
    ldh a, [rNR10]
    ldh a, [rNR10]
    ldh a, [rNR10]
    ldh a, [rNR10]
    rrca
    rrca
    jr PaddingZone_002_7cd6

UnknownCode_002_7cbe:
    ccf
    jr nc, ConstTable_002_7d00

    inc hl
    ld a, $22
    ld a, $22
    ld a, $22
    ld a, $22
    pop af
    pop af
    add hl, de
    add hl, de
    db $ed
    dec c
    push af
    add l
    db $fd
    add l
    db $fd
    add l

PaddingZone_002_7cd6:
    db $fd
    add l
    db $fd
    add l
    rst $38
    rst $38
    nop
    nop
    rst $38
    nop
    rst $38
    inc e

UnknownCode_002_7ce2:
    rst $30
    inc d

UnknownCode_002_7ce4:
    rst $30
    inc d

UnknownCode_002_7ce6:
    rst $30
    inc d

UnknownCode_002_7ce8:
    rst $30
    inc d
    adc a
    adc a
    ret z

    ret z

    ld l, a
    ld l, b
    xor a
    jr z, UnknownCode_002_7ce2

    jr z, UnknownCode_002_7ce4

    jr z, UnknownCode_002_7ce6

UnknownCode_002_7cf7:
    jr z, UnknownCode_002_7ce8

    jr z, UnknownCode_002_7cf7

    db $fc
    ld b, $06
    ei
    inc bc

ConstTable_002_7d00:
    db $fd
    pop hl
    cp a
    and c
    cp a
    and c
    cp a
    and c
    cp a
    and c
    ld l, b
    ld c, b
    ld l, a
    ld c, a
    ld a, a
    ld d, b
    ld h, b
    ld a, a
    ld a, a
    ld a, a
    ccf
    ccf
    rra
    rra
    nop
    nop
    inc bc
    ld [bc], a

BitDispatch_Entry0:
    inc bc
    ld [bc], a

BitDispatch_Entry1:
    inc bc
    ld [bc], a

BitDispatch_Entry2:
    inc bc
    ld [bc], a

BitDispatch_Entry3:
    inc bc
    ld [bc], a

BitDispatch_Entry4:
    add e
    add d

BitDispatch_Entry5:
    add e
    add d

BitDispatch_Entry6:
    add e
    add e
    rst $28
    jr z, BitDispatch_Entry0

    jr z, BitDispatch_Entry1

    jr z, BitDispatch_Entry2

    jr z, BitDispatch_Entry3

    jr z, BitDispatch_Entry4

    jr z, BitDispatch_Entry5

    jr z, BitDispatch_Entry6

    rst $28
    cp a
    and c
    cp a
    and c
    cp a
    and c
    cp a
    and c
    cp a
    and c
    cp a
    and c
    cp a
    and c
    cp a
    cp a
    ld a, a
    ld b, a
    ld a, b
    ld b, b
    ld a, a
    ld b, b
    ld a, a
    ld b, a
    ld a, l
    ld b, l
    ld a, l
    ld b, l
    ld a, l
    ld b, l
    ld a, l
    ld a, l
    ei
    ld a, [bc]
    ei
    ld a, [bc]
    ei
    ld a, [bc]
    ei
    ld a, [bc]
    ei
    ld a, [bc]

UnknownCode_002_7d64:
    ei
    ld a, [bc]

AudioDispatchEntry_7d66:
    ei
    ld a, [bc]

AudioDispatchEntry_7d68:
    ei
    ei
    rst $38
    jr c, @-$37

    nop
    rst $38
    ld bc, $38ff
    rst $28
    jr z, UnknownCode_002_7d64

    jr z, AudioDispatchEntry_7d66

    jr z, AudioDispatchEntry_7d68

    rst $28
    rst $18
    ld d, c
    rst $18
    pop de

UnknownCode_002_7d7e:
    sbc a
    sub c
    rst $18
    pop de
    rst $18
    ld d, c
    rst $18
    ld d, c
    rst $18
    ld d, c
    rst $18
    rst $18
    ld a, l
    ld b, l
    ld a, l
    ld b, l
    ld a, a
    ld b, a
    ld a, b
    ld b, b
    ld a, a
    ld b, b
    ld a, a
    ld h, b
    ccf
    jr nc, AudioDispatchEntry_7db8

    rra
    ld sp, hl
    add hl, bc
    ld sp, hl
    add hl, bc
    ld sp, hl
    add hl, bc
    ld sp, hl
    add hl, bc
    ld sp, hl
    add hl, bc
    ld sp, hl
    add hl, de
    pop af
    ld sp, $e1e1
    ldh a, [rNR10]
    ldh a, [rNR10]
    rst $38
    rra
    ldh a, [rP1]
    rst $38
    nop
    rst $38
    nop
    rst $38
    nop

AudioDispatchEntry_7db8:
    rst $38
    rst $38
    ccf
    inc hl
    inc a
    jr nz, UnknownCode_002_7d7e

    and b
    cp a
    and e
    cp [hl]
    and d
    cp [hl]
    and d
    cp [hl]
    and d
    cp [hl]
    cp [hl]
    db $fd
    add l
    ld a, l
    dec b
    db $fd
    dec b
    db $fd
    add l
    db $fd
    add l
    db $fd
    add l
    db $fd
    add l
    db $fd
    db $fd
    rst $30
    inc d

UnknownCode_002_7ddc:
    rst $30
    inc d

UnknownCode_002_7dde:
    rst $30
    inc d

UnknownCode_002_7de0:
    rst $30
    inc d

UnknownCode_002_7de2:
    rst $30
    inc d

UnknownCode_002_7de4:
    rst $30
    inc d

UnknownCode_002_7de6:
    rst $30
    inc d

UnknownCode_002_7de8:
    rst $30
    rst $30
    rst $28
    jr z, UnknownCode_002_7ddc

    jr z, UnknownCode_002_7dde

    jr z, UnknownCode_002_7de0

    jr z, UnknownCode_002_7de2

    jr z, UnknownCode_002_7de4

    jr z, UnknownCode_002_7de6

    jr z, UnknownCode_002_7de8

    rst $28
    cp a
    and c
    cp a
    and c
    rst $38
    pop hl
    rra
    ld bc, $01ff
    rst $38
    inc bc
    cp $06
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
    rlca
    ld bc, $0107
    rlca
    rlca
    nop
    nop
    rst $38
    rst $38
    rst $38
    nop
    nop
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    nop
    nop
    ld l, [hl]
    ld e, [hl]
    xor $de
    xor $3e
    ld e, $fe
    cp $fe
    db $fc
    db $fc
    ld hl, sp-$08
    nop
    nop
    ld l, b
    ld c, b
    ld l, b
    ld c, b
    ld l, b
    ld c, b
    ld l, b
    ld c, b
    ld l, b
    ld c, b
    ld l, b
    ld c, b
    ld l, b
    ld c, b
    ld l, b
    ld c, b
    ld l, [hl]
    ld e, [hl]
    ld l, [hl]
    ld e, [hl]
    ld l, [hl]
    ld e, [hl]
    ld l, [hl]
    ld e, [hl]
    ld l, [hl]
    ld e, [hl]
    ld l, [hl]
    ld e, [hl]
    ld l, [hl]
    ld e, [hl]
    ld l, [hl]
    ld e, [hl]
    nop
    nop
    rra
    rra
    ccf
    jr nz, @+$72

    ld d, b
    ld l, a
    ld c, a
    ld l, b
    ld c, b
    ld l, b
    ld c, b
    rst $38
    rst $38
    nop
    nop
    rst $38
    rst $38
    rst $38
    nop
    nop
    nop
    rst $38
    rst $38
    nop
    nop
    nop
    nop
    rst $38
    rst $38
    nop
    nop
    ld hl, sp-$08
    db $fc
    inc e
    ld l, $3e
    xor $de
    ld l, [hl]
    ld e, [hl]
    ld l, [hl]
    ld e, [hl]
    rst $38
    rst $38
    nop
    nop
    rst $38
    rst $38
    rst $38
    nop
    nop
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    ld l, [hl]
    ld e, [hl]
    nop
    nop
    rst $38
    rst $38
    rst $38
    nop
    nop
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    ld l, b
    ld c, b
    nop
    nop
    ld bc, $0601
    ld b, $08
    ld [$1010], sp
    jr nz, UnknownCode_002_7ed6

    ld b, l
    ld b, b
    add b
    add b
    nop
    nop
    ret nz

    ret nz

    jr nc, UnknownCode_002_7ef0

    ld [$5508], sp
    dec b
    ld [bc], a
    ld [bc], a
    ld bc, $0001
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ldh [hVramPtrLow], a
    jr UnknownCode_002_7eec

    inc b
    inc b

UnknownCode_002_7ed6:
    ld [bc], a
    ld [bc], a
    add c
    add c
    and d
    and d
    xor c
    xor c
    pop de
    pop de
    call $fdcd
    db $fd
    pop hl
    ld h, c
    or $76
    call c, CheckCoinCollision
    ld [de], a

UnknownCode_002_7eec:
    rra
    db $10
    rrca
    ld a, [bc]

UnknownCode_002_7ef0:
    rrca
    rrca
    db $10
    db $10
    ld [hl+], a
    ld [hl+], a
    dec hl
    dec hl
    jp hl


    jp hl


    rst $38
    add h
    rst $38
    rst $38
    rst $38
    ld l, [hl]
    db $e3
    ld bc, $d3f3
    ld a, a
    ld a, [hl]
    ld sp, hl
    rst $08
    rst $38
    rst $38
    ret z

    ld hl, sp-$78
    ld hl, sp-$70
    ldh a, [rNR10]
    ldh a, [hVramPtrLow]
    ldh [hSoundId], a
    ld b, b
    ldh [rNR41], a
    rst $38
    rst $38
    ccf
    jr nz, PaddingZone_002_7f8d

    ld d, b
    ld l, a
    ld c, a
    ld l, b
    ld c, b
    ld l, e
    ld c, b
    ld l, e
    ld c, b
    ld l, e
    ld c, e
    ld l, b
    ld c, b
    rst $20
    ld h, $18
    jr @+$01

    rst $38
    nop
    nop
    add b
    add b
    add b
    add b
    add b
    add b
    nop
    nop

PaddingData_7f3a:
    rst $38
    nop
    nop
    nop
    rst $38
    rst $38
    nop
    nop
    rlca
    ld bc, $0107
    rlca
    rlca
    nop
    nop
    ld l, b
    ld c, b
    ld l, b
    ld c, b
    ld l, b
    ld c, b
    ld l, b
    ld c, b
    ld l, b
    ld c, b
    ld l, e
    ld c, b
    ld l, e
    ld c, b
    ld l, e
    ld c, e
    rst $38
    rst $38
    rst $38
    rst $38
    nop
    rst $38
    nop
    nop
    rst $38
    nop
    nop
    nop
    cp e
    jr c, PaddingZone_002_7fad

    ld b, h
    rlca
    rlca
    inc b
    rlca
    ld [$080f], sp
    rrca
    add hl, bc
    rrca
    dec de
    rra
    inc hl
    ld a, $2f
    ccf
    sbc [hl]
    sbc [hl]
    ld [hl], c
    ld a, a
    ld b, c
    ld a, a
    cp $e6
    ld sp, hl
    pop af
    rst $08
    ld c, h
    rst $18
    ld e, b
    rst $08
    ld b, b
    rst $38
    rst $38
    rst $38

PaddingZone_002_7f8d:
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

PaddingZone_002_7fad:
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

TrapHalt_7ffd:
    rst $38
    rst $38
    rst $38
