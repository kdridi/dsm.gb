SECTION "ROM Bank $001", ROMX[$4000], BANK[$1]

    cp e
    ld d, l
    ldh [c], a
    ld d, l
    dec b
    ld d, [hl]
    cp e
    ld d, l
    ldh [c], a
    ld d, l
    dec b
    ld d, [hl]
    cp e
    ld d, l
    ldh [c], a
    ld d, l
    dec b
    ld d, [hl]
    jr nc, PreprocessData_406a

    ld h, l
    ld d, [hl]
    sub h
    ld d, [hl]
    cp e
    ld d, l
    ld de, $0553
    ld d, h
    push de
    ld d, h
    ld a, c
    ld d, c
    ld [hl+], a
    ld d, d
    sbc e
    ld d, d
    ld de, $0553
    ld d, h
    push de
    ld d, h
    ld de, $0553
    ld d, h
    push de
    ld d, h
    rrca

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

BusyWait_IfNotZero_001_42e1:
    jr nz, BusyWait_IfNotZero_001_42e1

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
    jr c, JumpIfCarryClear_B2BC_001_4376

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
    jr z, JumpIfCarryClear_B2BC_001_4376

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

JumpIfCarryClear_B2BC_001_4376:
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

ContinueProcessing_43fd:
    nop
    nop
    nop
    nop
    nop
    ld bc, $0300
    nop
    dec b
    nop

ReturnIfZero_4408:
    add hl, bc
    nop
    ld bc, $0300
    nop
    dec b
    nop
    add hl, bc
    nop
    rst $38
    inc a
    rst $38
    ld a, [hl]

RstMarker_4416:
    rst $38

RstMarkerBlock_4417:
    rst $38
    rst $38
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
    ld bc, $0701
    ld b, $0e
    ld [$1f1f], sp
    inc e
    db $10
    rra
    rra
    inc a
    inc a
    ld d, [hl]
    ld c, [hl]
    rst $38
    rst $38
    add hl, sp
    rlca
    ld a, h
    inc bc
    rst $38
    rst $38
    db $fc
    inc bc
    rst $38
    rst $38
    nop
    nop
    nop
    nop
    add b
    add b
    ldh [hVramPtrLow], a
    ld [hl], b
    ldh a, [$fff8]
    ld hl, sp+$38
    ld hl, sp-$08
    ld hl, sp+$1e
    ld d, $19
    add hl, de
    add hl, de
    add hl, de
    ld e, $16
    inc e
    db $10
    inc e
    db $10
    ccf
    ccf
    db $dd
    call z, $197e
    ld h, [hl]
    dec h
    ld h, [hl]
    dec h
    ld a, [hl]
    add hl, de
    ld a, [hl]
    ld bc, $017e
    rst $38
    rst $38
    rst $28
    ld h, e
    ld a, b
    ld hl, sp-$68
    sbc b
    sbc b
    sbc b
    ld a, b
    ld hl, sp+$38
    ld hl, sp+$38
    ld hl, sp-$04
    db $fc
    rra
    rst $38
    inc bc
    inc bc
    rlca
    inc b
    rrca
    ld [$101f], sp
    ld e, $10
    inc a
    jr nz, DataPaddingWithRst_44ce

    ccf
    jr nz, Return_IfNotZero_001_44b2

    rst $38
    rst $38
    jp $8700


    nop
    rrca
    nop
    rrca
    nop
    rra
    nop
    rst $38
    rst $38
    nop
    nop
    rst $38
    rst $38
    pop bc
    ccf
    ldh [$ff1f], a
    ldh a, [rIF]
    ld hl, sp+$07
    db $fc
    inc bc
    rst $38
    rst $38
    nop
    nop

Return_IfNotZero_001_44b2:
    ret nz

    ret nz

    ldh [hVramPtrLow], a
    ld [hl], b
    ldh a, [$ff38]
    ld hl, sp+$38
    ld hl, sp+$1c
    db $fc
    db $fc
    db $fc
    inc e
    ld a, h
    ld b, b
    ld a, a
    ld a, a
    ld a, a
    add b
    add b
    add b
    rst $38
    rst $38
    rst $38
    db $10
    db $10

DataPaddingWithRst_44ce:
    inc c
    inc c
    inc bc
    inc bc
    nop
    rst $38
    rst $38
    rst $38
    nop
    nop
    nop
    rst $38
    rst $38
    rst $38
    ld [$3038], sp
    ldh a, [hSoundId]
    ret nz

    nop
    rst $38
    rst $38
    rst $38
    nop
    nop
    nop
    rst $38
    rst $38
    rst $38
    db $10
    db $10
    inc c
    inc c
    inc bc
    inc bc
    ld c, $fe
    cp $fe
    rlca
    ccf
    rlca
    rst $38
    rst $38
    rst $38
    ld [$3038], sp
    ldh a, [hSoundId]
    ret nz

    rst $38
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
    rst $38
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
    jr nz, DataPadding_453e

    jr nz, DataPadding_4540

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

DataPadding_4539:
    nop
    nop
    nop
    nop
    nop

DataPadding_453e:
    add b
    add b

DataPadding_4540:
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

DataPadding_4557:
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
    jr nz, DataPadding_4557

    jr nz, DataPadding_4539

    ld b, b
    ret nz

    ld b, b
    add b
    add b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    stop
    jr z, JumpTarget_IfZero

JumpTarget_IfZero:
    stop
    nop
    nop
    nop
    nop
    nop
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
    rst $38
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    inc bc
    nop
    inc c
    nop
    stop
    jr nz, JumpTarget_IfNotZero

JumpTarget_IfNotZero:
    ld d, d
    nop
    ld d, d
    nop
    ld c, h
    nop
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
    ld c, d
    nop
    ld c, d
    nop
    ld [hl-], a
    nop
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
    ret nz

    nop
    jr nc, JumpTarget_IfNotCarry

JumpTarget_IfNotCarry:
    ld [$0400], sp
    nop
    ld b, b
    nop
    ld b, b
    nop
    ccf
    nop
    ld b, b
    nop
    ccf
    nop
    stop
    ld [$0700], sp
    nop
    nop
    nop
    nop
    nop
    rst $38
    nop
    nop
    nop
    rst $38
    nop
    ld c, b
    nop
    add h
    nop
    inc bc
    nop
    nop
    nop
    nop
    nop
    rst $38
    nop
    nop
    nop
    rst $38
    nop
    ld [de], a
    nop
    ld hl, $c000
    nop
    ld [bc], a
    nop
    ld [bc], a
    nop
    db $fc
    nop
    ld [bc], a
    nop
    db $fc
    nop
    ld [$1000], sp
    nop
    ldh [rP1], a
    ld bc, $0200
    nop
    rrca
    nop
    stop
    ccf
    nop
    ld b, b
    nop
    ld a, a
    nop
    ld c, h
    nop
    add b
    nop
    ld b, b
    nop
    ldh a, [rP1]
    ld [$fc00], sp
    nop
    ld [bc], a
    nop
    cp $00
    ld [hl-], a
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
    nop
    nop
    nop
    nop
    nop
    jr RstDataChain_4669

RstDataChain_4669:
    inc h
    nop
    inc h
    nop
    jr RstDataBlock_466f

RstDataBlock_466f:
    nop
    nop
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
    rst $38
    nop
    nop
    rst $20
    jr RstChainLink1_4681

RstChainLink1_4681:
    nop
    rst $20
    jr RstChainLink2_4685

RstChainLink2_4685:
    nop
    rst $20
    jr RstChainLink3_4689

RstChainLink3_4689:
    nop
    rst $20
    jr RstChainLink4_468d

RstChainLink4_468d:
    nop
    rst $20
    jr RstChainEnd_4691

RstChainEnd_4691:
    nop
    add b
    nop
    add b
    nop
    add b
    nop
    add b
    nop
    add b
    nop
    add b
    nop
    add b
    nop
    add b
    nop
    nop
    jr nz, ConditionalLoadSequence_46a5

ConditionalLoadSequence_46a5:
    ld d, b
    nop
    sub b
    nop
    and b
    nop
    sub b
    nop
    sub b
    nop
    ld c, d
    nop
    ld c, l
    nop
    ld d, l
    nop
    ld c, c
    nop
    add hl, hl
    nop
    ld a, [hl+]
    nop
    ld a, [hl+]
    nop
    inc d
    nop
    inc d
    nop
    inc c
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

    jr nc, CorruptedSection_4836

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

CorruptedSection_4836:
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
    jr nz, CallZeroEntry_48aa

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

CallZeroEntry_48aa:
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

    jr nz, DataTable_4acb

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

DataTable_4acb:
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
    jr nc, DataTable_4b18

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

DataTable_4b18:
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
    jp nz, DataPadding_3cc2

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
    nop
    nop
    ld b, c
    ld b, c
    ld b, c
    ld b, c
    nop
    nop
    nop
    nop
    nop
    nop
    ldh a, [hCurrentTile]
    ld hl, sp+$08
    inc e
    inc b
    inc c
    inc b
    ld a, [bc]
    ld b, $0a
    ld b, $00
    nop
    nop
    rst $38
    nop
    add c
    nop
    cp l
    nop
    and l
    nop
    or l
    nop
    add l
    nop
    db $fd
    nop
    nop
    nop
    ld a, [hl]
    nop
    ld b, d
    nop
    ld e, d
    nop
    ld c, d
    nop
    ld a, d
    nop
    ld [bc], a
    nop
    cp $00
    add c
    nop
    add c
    nop
    add c
    nop
    add c
    nop
    add c
    nop
    add c
    nop
    add c
    nop
    ld e, [hl]
    nop
    nop
    nop
    ld [bc], a
    nop
    ld b, [hl]
    nop
    ld h, $00
    inc d
    nop
    ld [$0800], sp
    nop
    ld [$0400], sp
    nop
    ld [bc], a
    nop
    ld h, d
    nop
    dec e
    nop
    ld bc, $0000
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
    stop
    jr Trampoline_To_4c1f_001_4c1d

Trampoline_To_4c1f_001_4c1d:
    jr DataPadding_4c1f

DataPadding_4c1f:
    add hl, bc
    nop
    add hl, bc
    nop
    ld b, $00
    ld [$1000], sp
    nop
    inc l
    nop
    ld b, a
    nop
    ret nz

    nop
    add b
    nop
    add b
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
    ld [$1400], sp
    nop
    inc d
    nop
    ld a, [hl+]
    nop
    ld h, $00
    ld d, l
    nop
    ld c, c
    nop
    ld d, c
    nop
    ld h, e
    nop
    ld d, l
    nop
    ld bc, $0300
    nop
    dec b
    nop
    add hl, bc
    nop
    ld de, $2100
    nop
    ld b, c
    nop
    ld e, [hl]
    rst $38
    rst $38
    rst $38
    rst $38
    nop
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    nop
    rst $38
    rst $38
    rst $38
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
    rst $38
    nop
    nop
    nop
    ld e, $00
    ld hl, $4000
    nop
    ld b, b
    nop
    and b
    nop
    xor b
    nop
    add b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    add b
    nop
    add b
    nop
    ld b, b
    nop
    jr nz, JumpStub_4ca1

JumpStub_4ca1:
    jr nz, DataPadding_4ca3

DataPadding_4ca3:
    ld bc, $0200
    nop
    ld [bc], a
    nop
    inc b
    nop
    inc b
    nop
    inc b
    nop
    ld [$0800], sp
    nop
    stop
    stop
    stop

DataPadding_4cb9:
    ld de, $1100
    nop
    ld a, [bc]
    nop
    ld a, [bc]
    nop
    inc c
    nop
    nop
    nop
    nop
    nop
    ldh [rP1], a
    stop
    ld [$0400], sp
    nop
    inc b
    nop
    inc b
    nop
    ld [$0800], sp
    nop
    stop
    inc d
    nop
    dec h
    nop
    inc h
    nop
    ld b, b
    nop
    add b
    nop
    ld [$0400], sp
    nop
    inc d
    nop
    ld d, h
    nop
    inc b
    nop
    ld [bc], a
    nop
    nop
    nop
    nop
    nop
    add h
    nop
    add d
    nop
    ld [hl+], a
    nop
    ld [bc], a
    nop
    ld bc, $0100
    nop
    ld [$0000], sp
    nop
    stop
    stop
    stop
    stop
    stop
    ld [$0800], sp
    nop
    ld [$1600], sp
    nop
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
    nop
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
    jr nz, DataPadding_4cb9

    db $10
    add b
    ld h, b
    nop
    add b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    rst $38
    nop
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
    ld bc, $0100
    nop
    ld [bc], a
    nop
    ld [bc], a
    nop
    ld [bc], a
    nop
    inc b
    nop
    inc b
    nop
    ld [$0700], sp
    nop
    ld [$1000], sp
    nop
    stop
    jr nz, DataPadding_4d6d

DataPadding_4d6d:
    ld b, b
    nop
    ld b, b
    nop
    ld b, b
    nop
    add b
    nop
    ld b, b
    nop
    jr nz, DataMarker_4d79

DataMarker_4d79:
    stop
    stop
    ld [$0800], sp
    nop
    ld [$0000], sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $0100
    nop
    ld [bc], a
    nop
    ld [bc], a
    nop
    ld b, b
    nop
    ld b, b
    nop
    sub b
    nop
    sub h
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    inc b
    nop
    ld [de], a
    nop
    ld [de], a
    nop
    ld bc, $0100
    nop
    ld bc, $0000
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
    nop
    nop
    nop
    rra
    nop
    jr nz, DataPadding_4dd9

DataPadding_4dd9:
    ld b, b
    nop
    add b
    ld b, b
    add b
    ld b, b
    add b
    jr nz, DataPadding_4e22

    nop
    nop
    nop
    rlca
    nop
    add sp, $00
    stop
    ld [$0800], sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    adc a
    nop
    ld d, b
    nop
    jr nz, JumpStub_4dfb

JumpStub_4dfb:
    jr nz, DataPadding_4dfd

DataPadding_4dfd:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    add b
    nop
    ld e, b
    nop
    inc h
    nop
    ld [hl+], a
    nop
    ld bc, $0100
    ld [bc], a
    ld bc, $4020
    jr nc, JumpStub_4e56

    db $10
    jr nz, @+$1e

    jr nz, DataPadding_4e22

    jr DataPadding_4e1d

DataPadding_4e1d:
    rlca
    nop
    nop
    nop
    nop

DataPadding_4e22:
    nop
    nop
    ld [$0800], sp
    inc b
    halt
    ld [$14e3], sp
    nop
    db $e3
    nop
    nop
    nop
    nop
    nop
    nop
    stop
    jr nc, JumpStub_4e38

JumpStub_4e38:
    ld l, c
    db $10
    rst $18
    jr nz, DataPadding_4e3d

DataPadding_4e3d:
    rst $18
    nop
    nop
    nop
    nop
    ld [bc], a
    ld bc, $0186
    xor h
    ld b, d
    or b
    ld c, h
    nop
    or b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    stop

JumpStub_4e56:
    stop
    cp $00
    ld a, h
    nop
    jr c, DataPadding_4e5e

DataPadding_4e5e:
    ld a, h
    nop
    add $00
    rst $38
    rst $38
    nop
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
    rst $38
    rst $38
    rst $38
    nop
    nop
    nop
    inc a
    nop
    ld h, [hl]
    nop
    db $db
    nop
    rst $38
    nop
    db $fc
    nop
    ld a, e
    nop
    rst $38
    ld b, $02
    ld [$3608], sp
    ld [hl+], a
    sbc $ca
    ld a, $2a
    ld c, $0a
    ld b, $02
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
    rst $00
    rst $00
    rst $28
    ld l, b
    rst $38
    inc sp
    db $fc
    add a
    ld hl, sp-$01
    nop
    rst $38
    nop
    rst $38
    add e
    ld a, h
    di
    di
    rst $38
    inc a
    rst $38
    adc c
    cp $e3
    inc a
    rst $38
    nop
    rst $38
    ld [bc], a
    db $fd
    adc a
    ld [hl], b
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
    ldh [hVramPtrLow], a
    db $fc
    inc a
    cp $8a
    ld a, a
    rst $20
    dec e
    rst $38
    ld bc, $03ff
    db $fd
    adc a
    ld [hl], c
    rst $38
    ld bc, $02fe
    cp $06
    db $fc
    inc b
    db $fc
    inc b
    cp $06
    rst $38
    inc bc
    rst $38
    ld bc, $0f0f
    ccf
    jr nc, DataTable_4f86

    ld b, a
    ld sp, hl
    rst $08
    ldh a, [rIE]
    add b
    rst $38
    add b
    rst $38
    rst $00
    cp b
    rst $38
    add b
    rst $38
    ret nz

    ld a, a
    ld b, b
    ld a, a
    ld b, b
    ld a, a
    ld h, b
    ccf
    jr nz, DataPadding_4f5e

    jr nz, CheckScrollingConditionAndReset_001_4fa0

    ld h, b
    ld a, [hl]
    ld a, [hl]
    cp e
    adc c
    cp e
    adc c
    rst $38
    rst $38
    or a
    sub c
    or a
    sub c
    or a
    sub c
    rst $38
    rst $38
    ld a, [hl]
    ld a, [hl]
    adc a
    add c
    cp a
    add c
    cp a
    add e
    rst $38
    rst $38
    ld a, [hl]
    ld a, [hl]
    nop
    nop
    nop
    nop
    ld a, a
    ld a, a
    ret nz

    ret nz

    cp a
    cp a
    cp a
    cp a
    cp a
    cp a
    cp a
    cp a
    add b
    rst $38
    rst $38
    rst $38
    cp $fe
    inc bc
    inc bc
    db $fd
    rst $38
    db $fd
    rst $38
    db $fd
    rst $38
    db $fd
    rst $38

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

DataTable_4f76:
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

DataTable_4f86:
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

CheckScrollingConditionAndReset_001_4fa0:
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

    ld a, [$c0d2]
    cp $07
    jr c, UpdateScrollXAndDecreaseCollisionCounter_001_4fcb

    ldh a, [hShadowSCX]
    and $0c
    jr nz, UpdateScrollXAndDecreaseCollisionCounter_001_4fcb

    ldh a, [hShadowSCX]
    and $fc
    ldh [hShadowSCX], a
    ret


UpdateScrollXAndDecreaseCollisionCounter_001_4fcb:
    ldh a, [hShadowSCX]
    inc a
    ldh [hShadowSCX], a
    ld b, $01
    call OffsetSpritesY
    call OffsetSpritesX
    ld hl, $c202
    dec [hl]
    ld a, [hl]
    and a
    jr nz, PerformCollisionCheckAndIncrementCounter_001_4fe2

    ld [hl], $f0

PerformCollisionCheckAndIncrementCounter_001_4fe2:
    ld c, $08
    call CheckSpriteCollisionWithOffset
    ld hl, $c202
    inc [hl]
    ret


    ldh a, [hJoypadState]
    bit 6, a
    jr nz, HandleJoypadButtonB_CheckCollision_001_5034

    bit 7, a
    jr nz, CheckSpriteCollisionSimple_001_5022

HandleJoypadAndCollision_001_4ff6:
    ldh a, [hJoypadState]
    bit 4, a
    jr nz, CheckCollisionWithPositiveOffset_001_5014

    bit 5, a
    ret z

    ld c, $fa
    call CheckSpriteCollisionWithOffset
    ld hl, $c202
    ld a, [hl]
    cp $10
    ret c

    dec [hl]
    ld a, [$c0d2]
    cp $07
    ret nc

    dec [hl]
    ret


CheckCollisionWithPositiveOffset_001_5014:
    ld c, $08
    call CheckSpriteCollisionWithOffset
    ld hl, $c202
    ld a, [hl]
    cp $a0
    ret nc

    inc [hl]
    ret


CheckSpriteCollisionSimple_001_5022:
    call CheckSpriteCollision
    cp $ff
    jr z, HandleJoypadAndCollision_001_4ff6

    ld hl, $c201
    ld a, [hl]
    cp $94
    jr nc, HandleJoypadAndCollision_001_4ff6

    inc [hl]
    jr HandleJoypadAndCollision_001_4ff6

HandleJoypadButtonB_CheckCollision_001_5034:
    call CheckPlayerCollisionWithTile
    cp $ff
    jr z, HandleJoypadAndCollision_001_4ff6

    ld hl, $c201
    ld a, [hl]
    cp $30
    jr c, HandleJoypadAndCollision_001_4ff6

    dec [hl]
    jr HandleJoypadAndCollision_001_4ff6

CheckPlayerCollisionWithTile:
    ld hl, $c201
    ldh a, [hTimerAux]
    ld b, $fd
    and a
    jr z, .checkFirstTile

    ld b, $fc

.checkFirstTile:
    ld a, [hl+]
    add b
    ldh [hSpriteY], a
    ldh a, [hShadowSCX]
    ld b, [hl]
    add b
    add $02
    ldh [hSpriteX], a
    call ReadTileUnderSprite
    cp $60
    jr nc, .tileIsSolid

    ldh a, [hSpriteX]
    add $fa
    ldh [hSpriteX], a
    call ReadTileUnderSprite
    cp $60
    ret c

.tileIsSolid:
    cp $f4
    jr z, .activateCollision

    ld a, $ff
    ret


.activateCollision:
    push hl
    pop de
    ld hl, $ffee
    ld [hl], $c0
    inc l
    ld [hl], d
    inc l
    ld [hl], e
    ld a, $05
    ld [$dfe0], a
    ret


CheckSpriteCollision:
    ld hl, $c201
    ld a, [hl+]
    add $0a
    ldh [hSpriteY], a
    ldh a, [hShadowSCX]
    ld b, a
    ld a, [hl]
    add b
    add $fe
    ldh [hSpriteX], a
    call ReadTileUnderSprite
    cp $60
    jr nc, CheckForSpecialCollisionTile_001_50b4

    ldh a, [hSpriteX]
    add $04
    ldh [hSpriteX], a
    call ReadTileUnderSprite
    cp $e1
    jp z, TriggerBlockCollisionSound_TimerDispatch

    cp $60
    jr nc, CheckForSpecialCollisionTile_001_50b4

    ret


CheckForSpecialCollisionTile_001_50b4:
    cp $f4
    jr nz, ReturnNoCollisionDetected_001_50c9

    push hl
    pop de
    ld hl, $ffee
    ld [hl], $c0
    inc l
    ld [hl], d
    inc l
    ld [hl], e
    ld a, $05
    ld [$dfe0], a
    ret


ReturnNoCollisionDetected_001_50c9:
    ld a, $ff
    ret


CheckSpriteCollisionWithOffset:
    ld de, $0502
    ldh a, [hTimerAux]
    cp $02
    jr z, CollisionCheckOffsetLoop_001_50d8

    ld de, $0501

CollisionCheckOffsetLoop_001_50d8:
    ld hl, $c201
    ld a, [hl+]
    add d
    ldh [hSpriteY], a
    ld b, [hl]
    ld a, c
    add b
    ld b, a
    ldh a, [hShadowSCX]
    add b
    ldh [hSpriteX], a
    push de
    call ReadTileUnderSprite
    pop de
    cp $60
    jr c, DecrementOffsetAndRetryCollisionCheck_001_5101

    cp $f4
    jr z, TriggerSpecialCollisionEvent_001_5107

    cp $e1
    jp z, TriggerBlockCollisionSound_TimerDispatch

    cp $83
    jp z, TriggerBlockCollisionSound_TimerDispatch

    pop hl
    ret


DecrementOffsetAndRetryCollisionCheck_001_5101:
    ld d, $fd
    dec e
    jr nz, CollisionCheckOffsetLoop_001_50d8

    ret


TriggerSpecialCollisionEvent_001_5107:
    push hl
    pop de
    ld hl, $ffee
    ld [hl], $c0
    inc l
    ld [hl], d
    inc l
    ld [hl], e
    ld a, $05
    ld [$dfe0], a
    ret


    ld b, $03
    ld hl, $ffa9
    ld de, wOamAttrY

OamSpriteActivityCheckLoop_001_5120:
    ld a, [hl+]
    and a
    jr nz, ProcessActiveSpriteOffset_001_512c

IncrementOamPointerAndLoop_001_5124:
    inc e
    inc e
    inc e
    inc e
    dec b
    jr nz, OamSpriteActivityCheckLoop_001_5120

    ret


ProcessActiveSpriteOffset_001_512c:
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
    cp $a9
    jr c, CheckCoinCollisionLogic_001_5143

ClearOamAndMemory_001_513c:
    xor a
    res 0, e
    ld [de], a
    ld [hl], a
    jr ProcessCollisionAndLoopContinue_001_5156

CheckCoinCollisionLogic_001_5143:
    add $02
    push af
    dec e
    ld a, [de]
    ldh [hSoundParam1], a
    add $06
    ldh [hSpriteY], a
    pop af
    call CheckTileForCoin
    jr c, ProcessCollisionAndLoopContinue_001_5156

    jr ClearOamAndMemory_001_513c

ProcessCollisionAndLoopContinue_001_5156:
    pop bc
    pop de
    pop hl
    call ProcessObjectCollisions
    jr IncrementOamPointerAndLoop_001_5124

    ld a, [$c202]
    cp $01
    jr c, ResetGameStateInit_001_5168

    cp $f0
    ret c

ResetGameStateInit_001_5168:
    xor a
    ldh [hTimerAux], a
    ldh [hSubState], a
    inc a
    ldh [hGameState], a
    inc a
    ld [$dfe8], a
    ld a, $90
    ldh [hTimer1], a
    ret


    ld c, $13
    db $10
    db $10
    inc de
    db $10
    ld de, $840d
    ld [de], a
    inc b
    add h
    rla
    dec bc
    add h
    ld a, [de]
    sub e
    db $10
    dec de
    dec b
    add h
    inc e
    sub e
    db $10
    ld hl, $0b09
    dec h
    ld b, $0b
    ld a, [hl+]
    rrca
    add h
    dec l
    inc c
    add h
    ld l, $13
    nop
    cpl
    dec b
    add h
    inc [hl]
    inc de
    db $10
    scf
    inc de
    db $10
    ld a, [hl-]
    inc de
    db $10
    dec a
    inc de
    db $10
    ld b, b
    inc de
    db $10
    ld b, c
    ld [$4304], sp
    inc de
    db $10
    ld b, a
    sub e
    db $10
    ld c, c
    sub e
    db $10
    ld c, h
    inc de
    and h
    ld c, [hl]
    inc de
    db $10
    ld d, c
    rlca
    nop
    ld d, d
    rlca
    nop
    ld d, a
    inc b
    nop
    ld e, b
    inc b
    nop
    ld e, c
    inc b
    nop
    ld e, h
    sub e
    db $10
    ld e, [hl]
    sub e
    db $10
    ld h, b
    sub e
    db $10
    ld h, d
    sub e
    db $10
    ld h, [hl]
    sub e
    db $10
    ld l, b
    sub e
    db $10
    ld l, d
    sub e
    inc h
    ld l, h
    sub e
    sub b
    ld l, a
    ld c, [hl]
    ld [bc], a
    ld [hl], c
    rrca
    add h
    ld a, b
    rlca
    nop
    ld a, c
    rlca
    nop
    ld a, l
    dec bc
    add h
    ld a, l
    add a
    add h
    ld a, a
    inc b
    nop
    add b
    inc b
    add b
    add h
    inc de
    sub b
    add a
    inc de
    inc h
    adc b
    ld [$8b84], sp
    sub e
    inc h
    adc [hl]
    rrca
    add h
    sub b
    ld [$980a], sp
    ld [$990a], sp
    db $10
    add h
    sbc h
    dec b
    ld [hl], $9c
    add l
    ld [hl], $ff
    inc c
    inc c
    ld d, $12
    inc c
    add h
    ld d, $0b
    nop
    rla
    rlca
    inc b
    dec e
    dec bc
    inc b
    ld [hl+], a
    rlca
    dec bc
    inc hl
    inc de
    and h
    daa
    rlca
    dec bc
    ld a, [hl+]
    dec c
    inc b
    ld sp, $1609
    ld [hl], $09
    inc b
    scf
    ld c, $00
    ld a, [hl-]
    add hl, bc
    add b
    ld a, $09
    ld d, $41
    ld c, $00
    ld b, h
    add hl, bc
    add b
    ld b, [hl]
    add hl, bc
    inc b
    ld c, b
    add hl, bc
    ld d, $4b
    ld c, $00
    ld d, a
    adc a
    inc b
    ld e, b
    ld c, $84
    ld e, c
    inc c
    nop
    ld e, e
    inc de
    inc h
    ld h, b
    adc a
    ld d, $65
    add l
    ld a, [bc]
    ld l, e
    ld a, [bc]
    dec bc
    ld [hl], b
    dec c
    inc b
    ld [hl], c
    inc de
    and h
    ld [hl], e
    inc de

DataTable_5278:
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

DataTable_529b:
    rrca
    dec b
    xor a
    add hl, de
    ld c, $2f
    dec de
    ld d, e
    db $10
    inc hl
    ld c, $9d
    dec h
    dec bc
    dec e
    daa
    ld [$299d], sp
    dec b
    dec e
    dec l
    ld [$2f2f], sp
    ld d, e
    db $10
    add hl, sp
    ld d, e
    db $10
    dec sp
    dec b
    dec e
    ld a, $05
    sbc l
    ld b, b
    dec c
    dec e
    ld b, e
    dec c
    sbc l
    ld b, e
    inc de
    db $10
    ld c, c
    rlca
    dec e
    ld c, l
    inc de
    db $10
    ld c, [hl]
    rlca
    cpl
    ld d, h
    ld [$5720], sp
    ld [$5f1d], sp
    add hl, bc
    jr nz, DataTable_5344

    rlca
    jr nz, DataTable_5347

    dec c
    jr nz, DataTable_5354

    rlca
    cpl
    ld [hl], l
    inc de
    inc h
    ld a, b
    inc c
    dec e
    ld a, a
    inc de
    inc h
    add l
    ld a, [bc]
    jr nz, DataTable_5278

    inc c
    cpl
    adc c
    inc de
    and h
    adc [hl]
    rrca
    dec e
    sub d
    rrca
    sbc l
    sbc e
    dec c
    jr nz, DataTable_529b

    rrca
    sbc l
    and l
    rlca
    and b
    xor b
    rrca
    dec e
    xor [hl]
    dec bc
    ld c, b
    xor a
    ld a, [bc]
    ret z

    or b
    inc c
    ld a, [de]
    rst $38
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

DataTable_5344:
    ld c, d
    rrca
    ld d, [hl]

DataTable_5347:
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

DataTable_5354:
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
    call nc, CallStub_StackInitVariant_A
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
    jr nc, CallStub_5436

    ccf
    inc [hl]
    call CallStub_StackInitVariant_B
    add hl, bc
    inc b
    scf
    call $3a55

CallStub_5436:
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
    db $10
    ld b, $53
    ld de, $d30f
    inc de
    ld [$1453], sp
    dec c
    ld d, e
    rla
    ld a, [bc]
    ld d, e
    add hl, de
    ld b, $53
    ld a, [de]
    rrca
    db $d3
    inc e
    inc c
    ld d, e
    dec e
    add hl, bc
    ld d, e
    inc hl
    ld b, $53
    inc h
    ld [$25d3], sp
    ld a, [bc]
    ld d, e
    daa
    ld c, $53
    jr z, JumpHandler_550a

    db $d3
    add hl, hl
    ld a, [bc]
    ld d, e
    dec hl
    ld b, $53
    inc l
    dec b
    ld d, d
    ld l, $05

JumpHandler_550a:
    jp nc, InitLevelStartWithAttractMode

    ld d, d
    inc [hl]
    rrca
    ld d, d
    ld [hl], $0f
    jp nc, $0f38

    ld d, d
    inc a
    dec b
    ld d, d
    dec a
    ld a, [bc]
    jp nc, $0f3e

    ld d, d
    ld b, d
    ld b, $52
    ld b, e
    dec c
    ld d, d
    ld c, h
    dec b
    ld d, e
    ld c, l
    adc e
    ld e, c
    ld c, [hl]
    ld b, $d3
    ld c, [hl]
    inc c
    ld d, d
    ld d, b
    add l
    ld e, c
    ld d, d
    rrca
    ld d, d
    ld d, d
    ld b, $53
    ld d, [hl]
    ld b, $59
    ld d, a
    ld c, $53
    ld e, b
    adc a
    ld e, c
    ld e, d
    ld b, $52
    ld e, d
    ld c, $d2
    ld e, h
    rrca
    ld d, e
    ld e, l
    add hl, bc
    ld e, c
    ld e, a
    ld [$6053], sp
    dec c
    ld e, c
    ld h, e
    dec b
    ld d, e
    ld h, e
    ld a, [bc]
    ld d, d
    ld h, l
    ld c, $53
    ld h, a
    add hl, bc
    ld e, c
    ld l, b
    add hl, bc
    ld d, e
    ld l, c
    ld c, $d2
    ld l, e
    add hl, bc
    ld e, c
    ld l, h
    ld [$7153], sp
    adc d
    ld e, c
    ld [hl], d
    rlca
    ld d, e
    ld [hl], e
    ld a, [bc]
    ld d, d
    ld [hl], l
    inc c
    ld d, d
    halt
    adc a
    ld e, c
    ld a, b
    ld [$7a52], sp
    ld a, [bc]
    ld d, e
    ld a, e
    ld c, $59
    ld a, l
    rlca
    ld d, e
    ld a, [hl]
    dec c
    ld d, e
    add b
    adc h
    ld e, c
    add l
    dec b
    ld d, e
    add a
    ld c, $53
    adc c
    ld c, $d2
    adc [hl]
    ld a, [bc]
    ld d, d
    sub b
    rlca
    ld d, d
    sub e
    dec c
    ld d, e
    sub e
    ld b, $52
    rst $08
    adc d
    ld d, h
    reti


    add a
    call nc, CheckPlayerCenterPosition
    ld d, h
    call c, $860d
    ldh [$ff08], a
    ld b, $e1
    ld [$ec06], sp
    adc d
    ld h, c
    rst $38
    rst $38
    call $bb56
    ld e, d
    ld c, b
    ld h, b
    call UpdateLevelState_4a56
    ld d, a
    db $eb
    ld d, a
    ld [hl-], a
    ld e, l
    ld l, a
    ld e, b
    cp $58
    cp $58
    ld l, [hl]
    ld e, c
    ld c, d
    ld d, a
    db $eb
    ld d, a
    db $eb
    ld d, a
    ld l, a
    ld e, b
    ld c, d
    ld d, a
    cp $58
    xor $59
    ld e, a
    ld e, d
    rst $38
    call $bb56
    ld e, d
    ld c, b
    ld h, b
    and e
    ld e, e
    ld [hl+], a
    ld e, h
    and [hl]
    ld e, h
    ld [hl-], a
    ld e, l
    adc d
    ld e, l
    ld [hl-], a
    ld e, [hl]
    ld [hl-], a
    ld e, [hl]
    ld [hl-], a
    ld e, [hl]
    ld b, h
    ld e, a
    ld b, h
    ld e, a
    ld [hl-], a
    ld e, l
    xor l
    ld e, a
    and [hl]
    ld e, h
    ld e, a
    ld e, d
    rst $38
    call $2756
    ld h, e
    daa
    ld h, e
    nop
    ld h, c
    cp b
    ld h, c
    ld [hl], d
    ld h, d
    cp b
    ld h, c
    nop
    ld h, c
    nop
    ld h, c
    ld [hl], d
    ld h, d
    ld [hl], d
    ld h, d
    cp b
    ld h, c
    daa
    ld h, e
    daa
    ld h, e
    ld [hl], d
    ld h, d
    ld [hl], d
    ld h, d
    nop
    ld h, c
    dec c
    ld h, h
    daa
    ld h, e
    daa
    ld h, e
    dec c
    ld h, l
    rst $38
    add c
    ld l, h
    add c
    ld l, h
    db $db
    ld l, l
    db $d3
    ld h, l
    and c
    ld h, [hl]
    cp a
    ld h, a
    add d
    ld l, b
    cp a
    ld h, a
    inc e
    ld l, c
    inc e
    ld l, c
    cp a
    ld h, a
    ldh [c], a
    ld l, c
    db $d3
    ld h, l
    add d
    ld l, b
    and c
    ld h, [hl]
    and c
    ld h, [hl]
    and c
    ld h, [hl]

DataTable_5652:
    add d
    ld l, b
    add d
    ld l, b
    ldh [c], a
    ld l, c
    inc e
    ld l, c
    and b
    ld l, d
    ld d, c
    ld l, e
    inc e
    ld l, c
    ld d, c
    ld l, e
    dec de
    ld l, h
    rst $38
    add c
    ld l, h
    add c
    ld l, h
    db $db
    ld l, l
    and [hl]
    ld l, [hl]
    ld h, b
    ld l, a
    ld h, b
    ld l, a
    and [hl]
    ld l, [hl]
    and [hl]
    ld l, [hl]
    jr c, @+$72

    jr c, DataTable_56e9

    ld h, b
    ld l, a
    inc hl
    ld [hl], c
    inc hl
    ld [hl], c
    db $fc
    ld [hl], c
    cp h
    ld [hl], d
    db $fc
    ld [hl], c
    cp h
    ld [hl], d
    ld a, c
    ld [hl], e
    inc hl
    ld [hl], c
    ld a, c
    ld [hl], e
    ld b, d
    ld [hl], h
    ld a, h
    ld [hl], l
    dec de
    ld l, h
    rst $38
    add c
    ld l, h
    add c
    ld l, h
    db $db
    ld l, l
    ld c, a
    halt
    ld c, a
    halt
    ld c, a
    halt
    ld c, a
    halt
    jp nc, $d276

    halt
    jp nc, DataTable_4f76

    halt
    ld c, a
    halt
    ld c, a
    halt
    jp nc, $d276

    halt
    ld c, a
    halt
    ld e, d
    ld [hl], a
    ld e, d
    ld [hl], a
    cp l
    ld [hl], a
    jp hl


    ld a, c
    ld a, [de]
    ld a, c
    ld a, [de]
    ld a, c
    jp hl


    ld a, c
    or d
    ld a, d
    ld e, a
    ld a, e
    ld c, $7c
    ld bc, $ff7d
    nop
    nop
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

DataTable_56e9:
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
    jr c, DataTable_5733

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

DataTable_5733:
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
    cp $6a
    ld h, b
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld e, d
    ld e, d
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
    ld e, l
    cp $c4
    ld h, b
    ld e, d
    ld e, d
    ld e, l
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
    pop af
    ld e, l
    cp $f1
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
    cp $02
    ld b, h
    ld c, b
    pop af
    ld e, l
    cp $f1
    ld e, l
    cp $f1

PatternData_5a60:
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
    ld hl, $8e56
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
    ld hl, $8f56
    cp $00
    db $fd
    ld a, a
    cp $a1
    ld e, a
    pop af
    ld a, a
    cp $f1
    ld a, a
    cp $f1
    ld a, a
    cp $05
    db $fd
    ld a, a
    pop af
    ld a, a
    cp $05
    ld a, a
    db $f4
    db $f4
    db $f4
    ld a, a
    pop af
    ld a, a
    cp $05
    ld a, a
    db $f4
    db $f4
    db $f4
    ld a, a
    ldh [c], a
    db $fd
    ld a, a
    cp $05
    ld a, a
    db $f4
    db $f4
    db $f4
    ld a, a
    and c
    add d
    ldh [c], a
    db $fd
    ld a, a
    cp $05
    ld a, a
    db $f4
    db $f4
    db $f4
    add d
    ld [hl], c
    add d
    and c
    ld a, a
    ldh [c], a
    db $fd
    ld a, a
    cp $06
    ld a, a
    db $f4
    db $f4
    db $f4
    ld a, a
    ld a, a
    sub c
    add b
    ldh [c], a
    db $fd
    ld a, a
    cp $06
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    sub a
    db $fd
    ld a, a
    cp $06
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    and [hl]
    db $f4
    db $f4
    db $f4
    ld a, a
    ld a, a
    ld a, a
    cp $06
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    sub a
    ld a, a
    db $f4
    db $f4
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
    sub a
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    ld a, a
    cp $08
    ld a, a
    db $f4
    db $f4
    db $f4

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
    cp $f1
    ld e, l
    cp $f1
    ld e, l
    cp $e2
    ld h, l
    ld e, l
    cp $42
    add hl, sp
    dec a
    ldh [c], a
    ld h, [hl]
    ld e, l
    cp $24
    inc sp
    ld [hl], $3a
    ld a, $e2
    ld h, l
    ld e, l
    cp $2e
    inc [hl]
    scf
    ld b, c
    ld e, b
    ld e, c
    ld e, c
    ld e, c
    ld e, c
    ld e, c
    ld e, c
    ld e, c
    ld e, c
    ld h, [hl]
    ld e, l
    cp $24
    dec [hl]
    jr c, DataTable_5c0c

    ccf
    ldh [c], a
    ld h, l
    ld e, l
    cp $42
    inc a
    ld b, b
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
    cp $21
    ld b, l
    ldh [c], a
    ld h, [hl]
    ld e, l
    cp $12
    ld b, d
    ld b, [hl]
    ldh [c], a
    ld h, l
    ld e, l
    cp $12
    ld b, e
    ld b, a
    ldh [c], a
    ld h, [hl]
    ld e, l
    cp $12
    ld b, h
    ld c, b
    or l
    ld h, a
    ld l, c
    ld h, a

DataTable_5c0c:
    ld l, c
    ld e, l
    cp $b5
    ld l, b
    ld l, d
    ld l, b
    ld l, d
    ld e, l
    cp $b2
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
    cp $84
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
    jp nz, TrapInfiniteLoop_7ff4

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
    jp nz, TrapInfiniteLoop_7ff4

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
    jp nz, TrapInfiniteLoop_7ff4

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
    jp nz, TrapInfiniteLoop_7ff4

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
    jp nz, TrapInfiniteLoop_7ff4

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
    call nz, ValidateCondition_534f
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
    call nz, ValidateCondition_534f
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
    call nz, ValidateCondition_534f
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
    call nz, ValidateCondition_534f
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
    call nz, ValidateCondition_534f
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
    jp nz, DataTable_5652

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
    jp nz, DataTable_5652

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

TrapInfiniteLoop_7ff4:
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
