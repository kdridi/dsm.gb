SECTION "ROM Bank $003", ROMX[$4000], BANK[$3]

; Constante pointant vers data table (offset du jr à $4E73)
DEF LevelGraphicsData_4E74 EQU $4E74

; LevelJumpTable Bank 3
; ----------------------
; Description: Table de pointeurs pour les niveaux supplémentaires (Bank 3)
; Format: 3 word-pointers par niveau (init/update/render typiquement)
; Utilisé par: level loader pour charger les routines spécifiques aux niveaux
; Note: Niveau 4 a une entrée supplémentaire ($50C0) - possiblement pointeur de données
LevelJumpTable_Bank3:
    ; Niveau 0
    dw $503F, $5074, $509B
    ; Niveau 1
    dw $503F, $5074, $509B
    ; Niveau 2
    dw $503F, $5074, $509B
    ; Niveau 3
    dw $503F, $5074, $509B
    ; Niveau 4 (4 pointeurs - structure différente)
    dw $50C0, LevelGraphicsData_4E74, LevelHandler_4_7_Part2, $4FD8
    ; Niveau 5
    dw LevelGraphicsData_4E74, LevelHandler_4_7_Part2, $4FD8
    ; Niveau 6
    dw LevelGraphicsData_4E74, LevelHandler_4_7_Part2, $4FD8
    ; Niveau 7
    dw LevelGraphicsData_4E74, LevelHandler_4_7_Part2, $4FD8
    ; Fin de table / Padding
    dw $0000, $0000, $0000, $0000
    inc e
    inc e
    ld a, $22
    ccf
    dec sp
    ld a, a
    ld b, a
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jr c, @+$3a

    ld a, h
    ld b, h
    db $fc
    call c, $e2fe
    nop
    nop
    nop
    nop
    jr PaddingZone_003_4070

    inc a
    inc h
    ld a, [hl]
    ld d, d
    ld a, a
    ld e, e
    ccf
    cpl
    ld a, l
    ld b, l
    nop
    nop
    nop
    nop
    jr @+$1a

    inc a
    inc h
    ld a, [hl]
    ld c, d
    cp $da
    db $fc
    db $f4

PaddingZone_003_4070:
    cp [hl]

PaddingZone_003_4071:
    and d
    nop
    nop
    ld bc, $1b01
    dec de
    daa
    daa
    cpl
    jr z, PaddingZone_003_40bc

    jr nc, PaddingZone_003_40be

PaddingTrap_407f:
    jr nz, PaddingZone_003_40c0

    ld a, $f8
    ld hl, sp-$14
    inc e
    db $e4
    call c, $1ce4
    db $e4
    inc e
    call nz, $843c
    ld a, h
    add h
    ld a, h
    nop
    nop
    ld bc, $0301
    ld [bc], a
    rlca
    rlca
    rrca
    ld c, $1f
    db $10
    ld a, a
    ld a, b
    adc a
    adc b
    nop
    nop
    ldh a, [hCurrentTile]
    ret c

    jr c, PaddingZone_003_4071

    cp b
    ret z

    jr c, @-$36

    jr c, @-$70

    ld a, [hl]
    dec bc
    ei
    nop
    nop
    inc bc
    inc bc
    rrca
    rrca
    ld a, c
    ld a, c
    rst $38
    sbc a

PaddingZone_003_40bc:
    rst $38
    and l

PaddingZone_003_40be:
    rst $38
    xor c

PaddingZone_003_40c0:
    ld d, [hl]
    ld d, [hl]
    nop
    nop
    ret nz

    ret nz

    ldh a, [hCurrentTile]
    sbc [hl]
    sbc [hl]
    rst $38
    ld sp, hl
    rst $38
    and l
    rst $38
    sub l
    ld l, d
    ld l, d
    jr c, PaddingZone_003_410c

    ld b, h
    ld b, h
    add d

PaddingZone_003_40d7:
    add d
    xor c

PaddingZone_003_40d9:
    xor c
    xor d
    xor d
    xor l
    xor l
    or b
    or b
    ld b, b
    ld b, b
    nop
    ld a, [hl]
    nop
    push hl
    nop
    rst $38
    ld a, [hl]
    add c
    ld a, [hl]
    rst $20
    ld a, [hl]
    rst $20
    jr PaddingZone_003_40d7

    jr PaddingZone_003_40d9

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
    ld [hl], c
    ld [hl], c
    add d
    add d
    ld a, h
    ld a, h
    nop
    ld a, [hl]
    ld h, h
    add c
    ld a, [hl]
    rst $20
    jr @-$17

    jr @+$01

PaddingZone_003_410c:
    ld a, [hl]
    add c
    ld a, [hl]
    rst $38
    jr SpriteGraphicsData_Enemy_Set2

    nop
    nop
    ld a, b
    ld a, b
    call nz, $82c4
    add d
    xor c
    xor c
    ld [hl], l
    ld [hl], l
    inc bc
    inc bc
    rlca
    rlca
    nop
    nop
    nop
    nop
    nop
    nop
    ld a, b
    ld a, b
    adc h
    sbc h
    ld h, h
    inc e
    db $e4
    call c, $1ce4
    ld a, a
    ld [hl], a
    ld a, a
    ld c, a
    rst $38
    add a
    rst $38
    or l
    rst $28
    xor l
    rst $20
    and l
    ld b, e
    ld b, d
    ld bc, $fe01
    xor $fe
    ldh a, [c]
    rst $38
    pop hl
    rst $38
    xor l
    rst $30
    or l
    rst $20
    and l
    jp nz, $8042

    add b
    ld a, l
    ld d, l
    ld a, a
    ld e, a
    ccf
    add hl, hl
    ld a, a
    ld c, e
    ld a, [hl]
    ld e, d
    cp $9a
    db $e4
    and h
    ld b, b
    ld b, b
    cp [hl]
    xor d
    cp $fa
    db $fc
    sub h
    cp $d2
    ld a, [hl]
    ld e, d
    ld a, a
    ld e, c
    daa
    dec h
    ld [bc], a
    ld [bc], a
    rrca
    ld [$101f], sp
    rra
    jr SpriteGraphicsData_Enemy_Set1

    inc b
    ld e, $19
    inc e
    inc de
    rrca
    rrca

SpriteGraphicsData_Enemy_Set1:
    nop
    nop
    db $fc
    ld a, h
    cp $0e
    jp nz, ErrorTrap_00

    pop af
    ld hl, $61e1
    pop hl
    xor e
    xor e

SpriteGraphicsData_Enemy_Set2:
    ld a, $3e
    rst $08
    call z, $8c8f
    ld b, a
    ld b, a
    ld h, b
    ld h, b
    ccf
    ccf
    inc a
    inc sp
    jr c, @+$29

    rra
    rra
    add hl, bc
    ld sp, hl
    sbc c
    ld sp, hl
    cp $9e
    db $10
    db $10
    ldh a, [hCurrentTile]
    ld h, b
    ldh [hSoundId], a
    ret nz

    add b
    add b
    ld bc, $0701
    rlca
    rra
    rra
    ld a, a
    ld h, b
    rst $38
    add b
    rst $38
    db $fc
    rra
    db $10
    rra
    rra
    db $fc
    db $fc
    cp $06
    ld a, [$f2c6]
    ld c, $f2
    ld c, $f3
    rrca
    pop hl
    rra
    rst $38
    rst $38
    nop
    nop
    jr c, UnreachableCodeData_003_00

    ld b, [hl]
    ld b, [hl]
    add c
    add c
    sub h
    sub h
    xor e
    xor e
    ld b, b
    ld b, b
    nop
    nop
    jr @+$01

    jr @+$01

    ld a, [hl]
    add c
    ld a, [hl]
    rst $38
    jr @+$01

    add c
    rst $38
    ld a, [hl]
    ld a, [hl]
    ld a, [hl]
    ld a, [hl]
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $0101
    ld bc, $0303
    rlca
    rlca
    rrca
    ld [$0000], sp
    ld e, $1e
    ld a, c
    ld a, c
    adc l
    sbc l
    ld h, l
    dec e
    and $de

UnreachableCodeData_003_00:
    db $e4
    inc e
    db $e4
    inc e
    rrca
    ld [$101f], sp
    ccf
    ld hl, $3e3f
    rra
    db $10
    ccf
    jr nz, DataZone_425e

    inc a
    rlca
    inc b
    db $e4
    inc e
    call nz, $c43c
    inc a
    add h
    ld a, h
    db $fc
    ld a, h
    cp $0e
    jp nz, $b142

    ld [hl], c
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    rra
    inc e
    rra
    db $10
    ld a, $31
    ld a, b
    ld h, a

DataZone_425e:
    ld sp, hl
    add $f3
    adc h
    nop
    nop
    ldh a, [hCurrentTile]
    db $fc
    inc e
    or $0e
    ld a, [hl-]
    add $3a
    add $7b
    add a
    ld a, e
    add a
    ld b, c
    ld b, c
    ld hl, $1222
    inc d
    dec c
    ld c, $96
    sbc b
    ld e, l
    ld e, [hl]
    ld h, $38
    dec e
    ld e, $04
    inc b
    ld [$9088], sp
    ld d, b
    ld h, b
    ldh [hAudioCh1Param], a
    ld [hl-], a
    ld [hl], h
    db $f4
    ret z

    jr c, UnreachableCodeData_003_01

    ldh a, [rNR42]
    ld [hl+], a
    ld [hl+], a
    inc h
    dec l
    ld l, $96
    sbc b
    sbc l
    sbc [hl]
    ld h, [hl]
    ld a, b
    dec e
    ld e, $62
    ld l, h
    ld [$8888], sp
    ld c, b
    ld l, b
    add sp, -$2e
    ld [hl-], a
    ld [hl], d
    ldh a, [c]
    call z, HandleAudioConditionalLogic
    ldh a, [$ff8c]
    ld l, h
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    add e
    add e
    add [hl]
    add [hl]
    ld c, d
    ld c, d
    ld [hl], c
    ld [hl], c
    ld [bc], a
    ld [bc], a
    ld [bc], a
    ld [bc], a
    inc bc
    inc bc
    ld [hl], b
    ld [hl], b
    ret nc

    ret nc

    db $10
    db $10
    ld [$8808], sp
    adc b
    ld [$0808], sp
    ld [$f0f0], sp
    rra
    db $10
    ccf
    ld hl, $3e3f
    rrca
    dec bc
    inc e
    inc d
    inc e
    inc d
    ld a, [hl]
    ld a, [hl]
    sub c

UnreachableCodeData_003_01:
    sub c
    db $e4
    inc e
    call nz, $8c3c
    ld a, h
    xor b
    ld l, b
    ret z

    ret z

    jr @+$1a

    ld [hl], b
    ld [hl], b
    and b
    ldh [$ff3e], a
    ld a, [hl-]
    inc a
    inc [hl]
    jr PaddingZone_003_4330

    ld [$0c08], sp
    inc c
    db $10
    db $10
    db $10
    db $10
    rra
    rra
    ld hl, $2161
    ld hl, $6b6b
    rst $38
    rst $38
    pop hl
    pop hl
    ld e, c
    ld e, c
    ld b, a

PaddingZone_003_432f:
    ld b, a

PaddingZone_003_4330:
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ldh a, [c]
    adc l
    di
    adc h
    db $fd
    jp nz, PaddingTrap_407f

    ld a, a
    ld b, b
    dec a
    ld [hl+], a
    ld sp, $1f3f
    rra
    di
    rrca
    ldh [c], a
    ld e, $f2
    ld e, $f6
    ld e, $c6
    ld a, $8e
    cp $3c
    db $fc
    ldh a, [hCurrentTile]
    ld [hl+], a
    inc l
    ld c, a
    ld c, a
    sub a
    sub a
    add hl, hl
    add hl, hl
    ld c, d
    ld c, d
    add a
    add a
    adc h
    adc h
    ld b, h
    ld b, h
    adc b
    ld l, b
    db $e4
    db $e4
    jp nc, $28d2

    jr z, PaddingZone_003_432f

    and h
    jp nz, DataPadding_62c2

    ld h, d
    ld b, h
    ld b, h
    adc a
    adc a
    scf
    scf
    ld c, c
    ld c, c
    ld c, d
    ld c, d
    ld b, a
    ld b, a
    ld b, [hl]
    ld b, [hl]
    ld [hl+], a
    ld [hl+], a
    nop
    nop
    ldh [c], a
    ldh [c], a
    ret c

Return_IfCarry_003_43a5:
    ret c

    inc h
    inc h
    and h
    and h
    call nz, $c4c4
    call nz, $8888
    nop
    nop
    ld b, c
    ld b, d
    ld [hl], $36
    rlca
    ld [$7e76], sp
    sbc c
    sbc c
    cpl
    cpl
    ld b, h
    ld b, h
    ld [hl+], a
    ld [hl+], a
    inc b
    add h
    ret c

    ret c

    ret nz

    jr nz, Return_IfCarry_003_43a5

    db $fc
    ld [hl-], a
    ld [hl-], a
    add sp, -$18
    ld b, h
    ld b, h
    adc b
    adc b
    nop
    nop
    nop
    nop
    ld a, b
    ld a, b
    db $fc
    call nz, $83e3
    db $fc
    call nz, AudioDataProcessor
    nop
    nop
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
    jr nz, AudioDispatch_Envelope

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
    jr nz, AudioData_003_442e

    jr nz, AudioDispatch_Volume

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

AudioDispatch_Channels:
    nop
    nop
    nop
    nop
    nop

AudioData_003_442e:
    add b
    add b

AudioDispatch_Volume:
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

AudioDispatch_Envelope:
    nop
    nop
    pop bc

AudioDispatch_Frequency:
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
    jr nz, AudioDispatch_Frequency

    jr nz, AudioDispatch_Channels

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
    ld bc, $0200
    nop
    inc bc
    nop
    rlca
    nop
    rrca
    nop
    ld [hl-], a
    nop
    ld a, b
    nop
    add h
    nop
    ld [bc], a
    nop
    ld [bc], a
    nop
    add d
    nop
    jp nz, $0400

    nop
    inc b
    nop
    nop
    nop
    nop
    nop
    ld bc, $0200
    nop
    inc b
    nop
    ld [$1000], sp
    nop
    jr nz, PaddingZone_003_44a3

PaddingZone_003_44a3:
    ld b, b
    nop
    add b
    nop
    ld [bc], a
    nop
    inc b
    nop
    ld [$0800], sp
    nop
    nop
    nop
    stop
    inc b
    nop
    inc b
    nop
    inc b
    nop
    ld [$0800], sp
    nop
    ld [$0800], sp
    nop
    ld [$2000], sp
    nop
    jr c, JoypadInputData_44c7

; ZONE MAL DESASSEMBLEE: Table de données joypad (88 bytes, $44C7-$451E)
; Note: $44FF pointe vers byte de donnée, pas du code
JoypadInputData_44c7:
    ld e, $00
    rrca
    nop
    ld b, $00
    inc b
    nop
    ld b, $00
    rlca
    nop
    stop
    stop
    nop
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
    ld [$1000], sp
    nop
    sub b
    nop
    sub b
    nop
    and b
    nop
    and b
    nop
    ldh [rP1], a
    ld b, b
    nop
    ld b, $00
    ld [$0800], sp
    nop
    stop
    nop
    nop
    ld hl, $2700
    nop
    rra
    nop
    add b
    nop
    nop
    nop
    nop
    nop
    stop
    ld h, b
    nop
    ret nz

    nop
    add d
    nop
    inc b
    nop
    ld b, b
    nop
    ld b, b
    nop
    ld h, b
    nop
    jr nz, PaddingZone_003_451b

PaddingZone_003_451b:
    jr nz, PaddingZone_003_451d

PaddingZone_003_451d:
    ldh [rP1], a
    stop
    ld [$0100], sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $0200
    nop
    ld [bc], a
    nop
    inc b
    nop
    ld [$8000], sp
    nop
    sub b
    nop
    ret nc

    nop
    stop
    jr nz, PaddingZone_003_453f

PaddingZone_003_453f:
    jr nz, SoundEngine_Target_1

SoundEngine_Target_1:
    jr nz, SoundEngine_Target_2

SoundEngine_Target_2:
    inc b
    nop
    inc b
    nop
    inc b
    nop
    inc b
    nop
    ld [bc], a
    nop
    ld [bc], a
    nop
    ld [bc], a
    nop
    ld [bc], a
    nop
    jr c, SoundEngine_Target_3

SoundEngine_Target_3:
    call nz, Boot
    nop
    ld [bc], a
    nop
    add e
    nop
    rlca
    nop
    rrca
    nop
    ld [hl-], a
    nop
    ld b, b
    nop
    add b
    nop
    ld bc, $0200
    nop

AudioData_003_456b:
    inc b
    nop
    ld [$1000], sp

SoundEngine_Target_4:
    nop
    jr nz, SoundEngine_Target_4

    ei
    db $fd
    ei
    db $fd
    ei

SoundEngine_Target_5:
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
    sbc c
    nop
    sbc c
    nop
    add c
    nop
    rst $38
    nop
    sbc c
    nop
    pop bc
    nop
    ld b, d
    nop
    ld a, [hl]
    nop
    nop
    nop
    nop
    nop
    nop
    ld [$1c00], sp
    nop
    ld [hl], $00
    ld l, e
    nop
    db $dd
    nop
    rst $38
    nop
    rst $38
    nop
    cp $00
    ld a, l
    nop
    cp e
    nop
    rst $38
    nop
    rst $38
    nop
    rst $38
    nop
    nop
    nop
    nop
    inc b
    nop
    ld [bc], a
    nop
    ld [bc], a
    nop
    rla
    nop
    sub a
    ld [bc], a
    ld l, l
    ld [bc], a
    dec a
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jr nz, AudioData_003_45cd

AudioData_003_45cd:
    ld b, b
    nop
    ret nz

    nop
    and b
    rlca
    ld a, b
    dec c
    ld [hl], b
    jr SoundEngine_Target_5

    jr PaddingZone_003_463a

    jr PaddingZone_003_463c

    add hl, bc
    jr nc, @+$07

    jr PaddingZone_003_45e1

PaddingZone_003_45e1:
    rrca
    nop
    add sp, -$80
    ld [hl], b
    add b
    ld [hl], b
    ret nz

    jr nc, AudioData_003_456b

    ld h, b
    add b
    ld h, b
    nop
    ret nz

    nop
    nop
    nop
    rrca
    nop
    ld [$0800], sp
    nop
    rlca
    nop
    ld [bc], a
    nop
    ld bc, $0000
    nop
    nop
    nop
    rst $38
    nop
    nop
    nop
    nop
    nop
    or a
    nop
    nop
    nop
    rst $38
    nop
    jr nz, AudioHandler_Entry_1

AudioHandler_Entry_1:
    ld sp, $fe00
    nop
    ld [bc], a
    nop
    ld [bc], a
    nop
    db $fc
    nop
    ld [$f000], sp
    nop
    add b
    nop
    add b
    nop
    rra
    nop
    jr nz, AudioHandler_Entry_2

AudioHandler_Entry_2:
    jr nz, AudioHandler_Entry_3

AudioHandler_Entry_3:
    jr nz, PaddingZone_003_462b

PaddingZone_003_462b:
    jr nz, PaddingZone_003_462d

PaddingZone_003_462d:
    ld a, a
    nop
    add b
    nop
    rst $38
    nop
    nop
    nop
    add b
    nop
    add b
    nop
    add b

PaddingZone_003_463a:
    nop
    add b

PaddingZone_003_463c:
    nop
    ret nz

    nop
    jr nz, AudioHandler_Entry_4

AudioHandler_Entry_4:
    ldh [rIE], a
    rst $38
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
    add c
    nop
    ld b, d
    nop
    inc h
    nop
    jr PaddingZone_003_465b

PaddingZone_003_465b:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld b, d
    nop
    ld e, d
    nop
    ld h, [hl]
    nop
    jp $8100


    nop
    rst $20
    nop
    rst $20
    nop
    sbc c
    nop
    sbc c
    nop
    sbc c
    nop
    cp l
    nop
    and l
    nop
    sbc c
    nop
    ld b, d
    nop
    ld h, [hl]
    nop
    ld e, d
    nop
    inc de
    nop
    dec d
    nop
    add hl, de
    nop
    ld de, $1100
    nop
    inc de
    nop
    dec d
    nop
    add hl, de
    nop
    jr c, JoypadInputEntry_4695

JoypadInputEntry_4695:
    ld b, h
    nop
    add d
    nop
    xor c
    nop
    xor d
    nop
    xor l
    nop
    or b
    nop
    ld b, b
    nop
    ld a, [hl]
    nop
    pop bc
    nop
    add c
    nop
    add c
    nop
    rst $20
    nop
    rst $20
    nop
    sbc c
    nop
    sbc c
    nop
    inc e
    nop
    ld [hl+], a
    nop
    ld b, c
    nop
    sub l
    nop
    ld d, l
    nop
    or l
    nop
    dec c
    nop
    ld [bc], a
    nop
    nop
    nop
    add c
    nop
    ld b, d
    nop
    and l
    nop
    ld a, [hl]
    nop
    inc a
    nop
    jr PaddingZone_003_46d1

PaddingZone_003_46d1:
    nop
    nop
    ld b, d
    nop
    ld b, [hl]
    nop
    ld b, d
    nop
    ld b, [hl]
    nop
    ld b, d
    nop
    ld b, [hl]
    nop
    ld b, d
    nop
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
    nop
    nop
    nop
    nop
    nop
    nop
    rst $38
    rst $38
    rst $38
    ccf
    rst $38
    ld e, $ff
    db $fc
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $08
    rst $38
    add a
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    ld a, [hl]
    rst $38
    ccf
    rst $38
    rst $38
    rst $38
    di
    rst $38
    pop hl
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
    db $fd
    jp $83fd


    ei
    add a
    rst $38
    adc [hl]
    xor b
    rst $18
    rst $18
    rst $38
    ld a, l
    ld a, l
    halt
    halt
    rst $38
    set 7, l
    ld h, e
    db $fd
    inc sp
    db $db
    scf
    sub e
    ld a, a
    ld a, a
    rst $38
    and $e6
    ld a, a
    ld a, a
    ret nz

    ret nz

    sbc a
    sbc a
    cp e
    cp e
    cp a
    cp a
    cp a
    cp a
    or a
    or a
    cp a
    cp a
    cp $fe
    inc bc
    inc bc
    db $fd
    db $fd
    rst $28
    rst $28
    db $fd
    db $fd
    ld a, a
    ld a, a
    rst $38
    rst $38
    ei
    ei
    cp a
    cp a
    cp l
    cp l
    cp a
    cp a
    xor a
    xor a
    cp a
    cp a
    cp [hl]
    cp [hl]
    rst $18
    rst $18
    ld a, a
    ld a, a
    rst $38
    rst $38
    rst $18
    rst $18
    db $fd
    db $fd
    rst $38
    rst $38
    rst $30
    rst $30
    rst $38
    rst $38
    rst $38
    rst $38
    cp $fe
    rst $38
    db $db
    rst $38
    adc c
    rst $38
    adc l
    rst $38
    rst $18
    ld a, d
    ld e, d
    ld [hl], d
    ld [hl], d
    jr nc, AudioData_003_47c0

    jr nz, UnreachableCodeData_003_02

    ld a, [hl]
    ld a, [hl]
    ei
    rst $00
    db $fd
    add e
    db $fd
    jp $f3fd


    db $fd
    bit 7, c
    ld c, a
    cp $ce
    ldh a, [c]
    adc [hl]
    rst $20
    rst $18
    call AudioStateUpdate
    ld [hl], e
    ld a, [hl]
    ld h, d
    ld sp, hl
    rst $00
    di
    rst $38
    ld a, [hl]
    ld a, [hl]

UnreachableCodeData_003_02:
    ld a, a
    ld a, a
    rst $30
    rst $00
    xor $8e
    db $dd
    sbc h
    cp e
    cp b
    or $f0
    rst $38
    rst $38

AudioData_003_47c0:
    ld a, a
    ld a, a
    cp $fe
    ld l, a
    rrca
    rst $18
    rra
    cp e
    dec sp
    ld [hl], a
    ld [hl], e
    rst $28
    rst $20
    rst $38
    rst $38
    cp $fe
    ld a, [hl]
    ld a, [hl]
    rst $28
    rst $08
    rst $18
    sbc a
    cp e
    cp e
    rst $30
    di
    rst $28
    rst $20
    rst $38
    rst $38
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
    nop
    nop
    nop
    nop
    nop
    nop

; JoypadReadHandler
; ------------------
; Description: Lit l'état du joypad et détecte les touches nouvellement pressées
; In:  (rien)
; Out: hJoypadState = état actuel des touches, hJoypadDelta = touches nouvellement pressées
; Modifie: a, b, c
JoypadReadHandler:
    ; Lecture des boutons directionnels (D-pad)
    ld a, $20                   ; Sélectionner D-pad
    ldh [rP1], a
    ldh a, [rP1]                ; Lecture stabilisation
    ldh a, [rP1]
    cpl                         ; Inverser (bouton pressé = 1)
    and $0f                     ; Garder seulement les 4 bits bas
    swap a                      ; Déplacer vers bits hauts
    ld b, a                     ; Sauvegarder D-pad dans b

    ; Lecture des boutons action (A, B, Select, Start)
    ld a, $10                   ; Sélectionner boutons action
    ldh [rP1], a
    ldh a, [rP1]                ; Lectures multiples pour stabilisation
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    cpl                         ; Inverser
    and $0f                     ; Garder les 4 bits bas
    or b                        ; Combiner avec D-pad
    ld c, a                     ; c = nouvel état complet

    ; Calculer les touches nouvellement pressées (delta)
    ldh a, [hJoypadState]       ; Ancien état
    xor c                       ; XOR pour trouver changements
    and c                       ; AND avec nouvel état = nouvelles pressions
    ldh [hJoypadDelta], a

    ; Sauvegarder le nouvel état
    ld a, c
    ldh [hJoypadState], a

    ; Réinitialiser le joypad
    ld a, $30                   ; Désélectionner tout
    ldh [rP1], a
    ret


; AnimationHandler
; ----------------
; Description: Traite les frames d'animation pour les sprites
; In:  hl = pointeur vers structure animation
;      hParam3 = nombre de structures à traiter
;      hParam1:hParam2 = pointeur buffer OAM destination
; Out: Sprites rendus dans buffer OAM
; Modifie: af, bc, de, hl
AnimationHandler:
    ld a, h
    ldh [hAnimStructHigh], a
    ld a, l
    ldh [hAnimStructLow], a
    ld a, [hl]
    and a
    jr z, AnimFrameEnd

    cp ANIM_FLAG_HIDDEN
    jr z, AnimHiddenSet

AnimAdvanceFrame:
    ldh a, [hAnimStructHigh]
    ld h, a
    ldh a, [hAnimStructLow]
    ld l, a
    ld de, ANIM_STRUCT_STRIDE
    add hl, de
    ldh a, [hParam3]
    dec a
    ldh [hParam3], a
    ret z

    jr AnimationHandler

AnimClearHidden:
    xor a
    ldh [hAnimHiddenFlag], a
    jr AnimAdvanceFrame

AnimHiddenSet:
    ldh [hAnimHiddenFlag], a

AnimFrameEnd:
    ld b, ANIM_BUFFER_SIZE
    ld de, hAnimBuffer

AnimCopyLoop:
    ld a, [hl+]
    ld [de], a
    inc de
    dec b
    jr nz, AnimCopyLoop

    ldh a, [hAnimFrameIndex]
    ld hl, AnimFramePointerTable
    rlca
    ld e, a
    ld d, $00
    add hl, de
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld l, a
    inc de
    ld a, [de]
    ld h, a
    inc de
    ld a, [de]
    ldh [hAnimObjX], a
    inc de
    ld a, [de]
    ldh [hAnimObjY], a
    ld e, [hl]
    inc hl
    ld d, [hl]

AnimProcessFrame:
    inc hl
    ldh a, [hAnimBaseAttr]
    ldh [hAnimAttr], a
    ld a, [hl]
    cp ANIM_CMD_END
    jr z, AnimClearHidden

    cp ANIM_CMD_FLIP_ATTR
    jr nz, AnimCheckFlip

    ldh a, [hAnimBaseAttr]
    xor ANIM_ATTR_FLIP_BIT
    ldh [hAnimAttr], a
    jr AnimProcessFrame

AnimSkipXY:
    inc de
    inc de
    jr AnimProcessFrame

AnimCheckFlip:
    cp ANIM_CMD_SKIP_XY
    jr z, AnimSkipXY

    ldh [hAnimFrameIndex], a
    ldh a, [hAnimOffsetX]
    ld b, a
    ld a, [de]
    ld c, a
    ldh a, [hAnimFlipFlags]
    bit 6, a
    jr nz, AnimFlipX

    ldh a, [hAnimObjX]
    add b
    adc c
    jr AnimXDone

AnimFlipX:
    ld a, b
    push af
    ldh a, [hAnimObjX]
    ld b, a
    pop af
    sub b
    sbc c
    sbc SPRITE_SIZE_8X8

AnimXDone:
    ldh [hAnimCalcY], a
    ldh a, [hAnimOffsetY]
    ld b, a
    inc de
    ld a, [de]
    inc de
    ld c, a
    ldh a, [hAnimFlipFlags]
    bit 5, a
    jr nz, AnimFlipY

    ldh a, [hAnimObjY]
    add b
    adc c
    jr AnimYDone

AnimFlipY:
    ld a, b
    push af
    ldh a, [hAnimObjY]
    ld b, a
    pop af
    sub b
    sbc c
    sbc SPRITE_SIZE_8X8

AnimYDone:
    ldh [hAnimCalcX], a
    push hl
    ldh a, [hParam1]
    ld h, a
    ldh a, [hParam2]
    ld l, a
    ldh a, [hAnimHiddenFlag]
    and a
    jr z, AnimHiddenY

    ld a, ANIM_CMD_END
    jr AnimRender

AnimHiddenY:
    ldh a, [hAnimCalcY]

AnimRender:
    ld [hl+], a
    ldh a, [hAnimCalcX]
    ld [hl+], a
    ldh a, [hAnimFrameIndex]
    ld [hl+], a
    ldh a, [hAnimAttr]
    ld b, a
    ldh a, [hAnimFlipFlags]
    or b
    ld b, a
    ldh a, [hAnimFlags2]
    or b
    ld [hl+], a
    ld a, h
    ldh [hParam1], a
    ld a, l
    ldh [hParam2], a
    pop hl
    jp AnimProcessFrame


; CheckObjectState
; ----------------
; Description: Vérifie et met à jour l'état du premier objet (wObject1)
;              Si l'état suivant est valide (< $0F), il est copié depuis wObject1+1
;              vers wObject1 et wObject1+1 est réinitialisé à 0.
; In:  Aucun paramètre direct
; Out: Aucun
; Modifie: a, b, hl
; Notes: wObject1+0 = wPlayerUnk08 (état actuel objet 1)
;        wObject1+1 = wPlayerUnk09 (état suivant objet 1)
;        Si état suivant = 0, rien n'est fait
;        Si état actuel >= $0F, rien n'est fait (état invalide)
CheckObjectState::
    ld hl, wPlayerUnk09         ; hl = adresse état suivant (wObject1+1)
    ld a, [hl]                  ; a = état suivant
    ld b, a                     ; b = sauvegarde état suivant
    and a                       ; Vérifier si état suivant = 0
    ret z                       ; Si 0, rien à faire

    dec l                       ; hl = wPlayerUnk08 (état actuel = wObject1+0)
    ld a, [hl]                  ; a = état actuel
    cp $0f                      ; Comparer avec état max
    ret nc                      ; Si >= $0F, état invalide, retour

    ld [hl], b                  ; État actuel = état suivant
    inc l                       ; hl = wPlayerUnk09 (état suivant)
    ld [hl], $00                ; Réinitialiser état suivant à 0
    ret


; ProcessObjectData
; ------------------
; Description: Traite et met à jour les données d'un objet en fonction de son état
;              et de la table ROM_OBJECT_INIT_DATA. Gère deux modes (type 1 et 2):
;              - Type 1: décrémente la valeur objet de la valeur table
;              - Type 2: incrémente la valeur objet de la valeur table (marche arrière)
; In:  bc = pointeur structure objet (wObject1-5) + offset $07 (champ index)
;      hl = pointeur table ROM_OBJECT_INIT_DATA
; Out: Objet mis à jour avec nouvel index et état si boundary atteinte
; Modifie: a, bc, de, hl
ProcessObjectData::
    ; Charger index courant dans DE
    ld a, [bc]              ; a = objet.index (+$07)
    ld e, a
    ld d, $00               ; de = index

    ; Pointer vers objet.state (bc - 7 = offset $00)
    dec c
    ld a, [bc]              ; a = objet.state (+$06)
    dec c
    dec c
    dec c
    dec c
    dec c
    dec c                   ; bc pointe maintenant sur objet.value (+$00)

    ; Si state = 0, rien à faire
    and a
    ret z

    ; Dispatch selon type de state
    cp ANIM_TRANSITION_DEFAULT  ; $02
    jr z, StateType2Branch

    ; --- TYPE 1: Décrémentation (marche avant) ---
    add hl, de              ; hl = &ROM_OBJECT_INIT_DATA[index]
    ld a, [hl]
    cp ANIM_TRANSITION_END_MARKER  ; $7f = boundary marker
    jr z, StateBoundaryMax

    ; Décrémenter valeur objet
    ld a, [bc]
    sub [hl]                ; value -= table[index]
    ld [bc], a
    inc e                   ; index++

StateStoreValue:
    ; Sauvegarder nouvel index à objet+$07
    ld a, e
    inc c
    inc c
    inc c
    inc c
    inc c
    inc c
    inc c                   ; bc = objet + $07
    ld [bc], a
    ret


StateType2Branch:
    ; --- TYPE 2: Incrémentation (marche arrière) ---
    ld a, e
    cp SLOT_EMPTY           ; $ff = index invalide
    jr z, StateType2End

    add hl, de              ; hl = &ROM_OBJECT_INIT_DATA[index]
    ld a, [hl]
    cp ANIM_TRANSITION_END_MARKER  ; $7f = boundary marker
    jr z, StateBoundaryCheck

StateProcessValue:
    ; Incrémenter valeur objet
    ld a, [bc]
    add [hl]                ; value += table[index]
    ld [bc], a
    dec e                   ; index-- (marche arrière)
    jr StateStoreValue

StateBoundaryCheck:
    ; Boundary rencontrée en type 2, reculer index
    dec hl
    dec e
    jr StateProcessValue

StateBoundaryMax:
    ; Boundary rencontrée en type 1, basculer vers type 2
    dec de                  ; index--
    dec hl

    ; Changer state vers type 2
    ld a, ANIM_TRANSITION_DEFAULT  ; $02
    inc c
    inc c
    inc c
    inc c
    inc c
    inc c                   ; bc = objet + $06 (state)
    ld [bc], a
    dec c
    dec c
    dec c
    dec c
    dec c
    dec c                   ; bc = objet + $00 (value)
    jr StateProcessValue

StateType2End:
    ; Index invalide en type 2, réinitialiser
    xor a
    inc c
    inc c
    inc c
    inc c
    inc c
    inc c                   ; bc = objet + $06 (state)
    ld [bc], a              ; state = 0
    inc c                   ; bc = objet + $07 (index)
    ld [bc], a              ; index = 0
    ret


FXDispatch_1:
    inc e
    ld a, [de]
    cp $0f
    jr nc, StateValidExit

    inc e
    dec a
    ld [de], a
    dec e
    ld a, $0f
    ld [de], a
    jr StateValidExit

FXDispatch_2:
    push af
    ld a, [de]
    and a
    jr nz, FXDispatch_4

    ld a, [wPlayerUnk0C]
    cp $03
    ld a, $02
    jr c, FXDispatch_3

    ld a, $04

FXDispatch_3:
    ld [wPlayerUnk0E], a

FXDispatch_4:
    pop af
    jr JoypadInputBit0Check

; ProcessGameStateInput
; ---------------------
; Description: Traite les entrées joypad selon l'état du jeu (menu vs gameplay)
;              Gère les actions du bouton A, les transitions d'état et
;              la préparation du buffer sprites
; In:  hGameState = état actuel du jeu
;      hJoypadState = état des boutons
;      hJoypadDelta = boutons nouvellement pressés
; Out: Peut modifier wPlayerUnk0E, wStateBuffer, wPlayerUnk07
; Modifie: a, bc, de, hl
ProcessGameStateInput::
    ldh a, [hGameState]
    cp GAME_STATE_GAMEPLAY  ; État $0D (gameplay actif) ?
    jp z, HandleJoypadInputDelay

    ld de, wPlayerUnk07
    ldh a, [hJoypadDelta]
    ld b, a
    ldh a, [hJoypadState]
    bit 1, a
    jr nz, FXDispatch_2

    push af
    ld a, [wPlayerUnk0E]
    cp $04
    jr nz, JoypadInputCheckFX04

    ld a, $02
    ld [wPlayerUnk0E], a

JoypadInputCheckFX04:
    pop af

JoypadInputBit0Check:
    bit 0, a
    jr nz, JoypadInputProcessAPress

    ld a, [de]
    cp $01
    jr z, FXDispatch_1

StateValidExit:
    bit 7, b
    jp nz, ResetMenuStateToIdle

; ValidateAndProcessGameState
; ----------------------------
; Description: Valide l'état du jeu en fonction du bit 1 de b.
;              Si bit 1 de b est activé, passe au contrôle de verrouillage.
;              Sinon, retourne immédiatement.
; In:  b = flags d'état (bit 1 = contrôle requis)
; Out: Aucun (peut transférer à ValidateAndProcessGameState_CheckLock)
; Modifie: Aucun (sauf si continue vers CheckLock)
ValidateAndProcessGameState:
    bit 1, b
    jr nz, ValidateAndProcessGameState_CheckLock

    ret


JoypadInputProcessAPress:
    ld a, [de]
    and a
    jr nz, StateValidExit

    ld hl, wPlayerUnk0A
    ld a, [hl]
    and a
    jr z, StateValidExit

    bit 0, b
    jr z, StateValidExit

    ld [hl], $00
    ld hl, wPlayerDir
    push hl
    ld a, [hl]
    cp $18
    jr z, JoypadInputProcessAPress_TransitionToGame

    and $f0
    or $04
    ld [hl], a
    ld a, [wPlayerUnk0E]
    cp $04
    jr z, JoypadInputProcessAPress_SetInitialState

    ld a, $02
    ld [wPlayerUnk0E], a
    ld [wPlayerUnk08], a

JoypadInputProcessAPress_SetInitialState:
    ld hl, wPlayerUnk0C
    ld [hl], MENU_STATE_ACTIVE      ; État menu = actif (48 frames)

JoypadInputProcessAPress_TransitionToGame:
    ld hl, wStateBuffer
    ld [hl], $01
    ld a, $01
    ld [de], a
    pop hl
    jr StateValidExit

; ValidateAndProcessGameState_CheckLock
; --------------------------------------
; Description: Vérifie le compteur d'accélération du joueur et le flag de verrouillage.
;              Si le compteur atteint la valeur max (6) ET que les updates ne sont pas
;              verrouillées, réinitialise le compteur. Sinon, passe directement au buffer OAM.
; In:  Aucun (lit wPlayerUnk0C et hUpdateLockFlag)
; Out: Aucun (peut réinitialiser wPlayerUnk0C à 0)
; Modifie: a, hl
ValidateAndProcessGameState_CheckLock:
    ld hl, wPlayerUnk0C
    ld a, [hl]
    cp PLAYER_ACCEL_COUNTER_MAX     ; Vérifie si compteur accélération = 6
    jr nz, InitializeSpriteTransferBuffer

    JumpIfLocked InitializeSpriteTransferBuffer

    ld [hl], $00

; InitializeSpriteTransferBuffer
; ------------------------------
; Description: Prépare le buffer de transfert OAM pour les sprites actifs.
;              Initialise les coordonnées Y/X, tile et attributs des sprites
;              selon l'état du jeu (gameplay ou autre).
; In:  Aucun (utilise états globaux hGameState, hSubState)
; Out: Aucun
; Modifie: a, bc, de, hl, buffer wOamBuffer
InitializeSpriteTransferBuffer:
InitializeSpriteTransferBuffer_CheckGameState:
    ldh a, [hGameState]
    cp GAME_STATE_GAMEPLAY  ; État $0D (gameplay actif) ?
    ld b, $03               ; En gameplay: traiter 3 objets max
    jr z, InitializeSpriteTransferBuffer_SelectBValue

    ldh a, [hSubState]
    and a
    ret z                   ; Si subState = 0, rien à faire

    ld b, $01               ; Sinon: traiter 1 objet

InitializeSpriteTransferBuffer_SelectBValue:
    ld hl, hObjParamBuf1    ; Pointeur vers buffer paramètres objets
    ld de, wOamBuffer       ; Pointeur vers buffer OAM

InitializeSpriteTransferBuffer_CountObjects:
    ld a, [hl+]
    and a                   ; Objet actif ?
    jr z, InitializeSpriteTransferBuffer_LoadObject

    inc e                   ; Skip 4 octets OAM par sprite
    inc e                   ; (Y, X, Tile, Attributs)
    inc e
    inc e
    dec b
    jr nz, InitializeSpriteTransferBuffer_CountObjects

    ret                     ; Tous les slots traités


InitializeSpriteTransferBuffer_LoadObject:
    push hl
    ld hl, wPlayerUnk05     ; Flags/attributs du joueur
    ld b, [hl]
    ld hl, wPlayerX
    ld a, [hl+]             ; Charge X
    add $fe                 ; Ajuste X (-2)
    ld [de], a              ; OAM Y position
    inc e
    ld c, $02               ; Offset X par défaut = +2
    bit 5, b                ; Test flip horizontal
    jr z, SetSpriteXPosition

    ld c, $f8               ; Si flip: offset = -8

SetSpriteXPosition:
    ld a, [hl+]             ; Charge Y
    add c                   ; Applique offset
    ld [de], a              ; OAM X position
    ld c, $60               ; Tile par défaut = $60
    inc e
    ldh a, [hGameState]
    cp GAME_STATE_GAMEPLAY  ; État $0D (gameplay actif) ?
    jr nz, SelectSpriteTile

    ld c, $7a               ; Tile gameplay = $7A
    ldh a, [hRenderContext]
    cp RENDER_CONTEXT_SPECIAL       ; $0B contexte spécial
    jr nz, SelectSpriteTile

    ld c, $6e               ; Tile spécial = $6E

SelectSpriteTile:
    ld a, c
    ld [de], a              ; OAM Tile number
    inc e
    xor a
    ld [de], a              ; OAM Attributs = 0
    pop hl
    dec l                   ; Revenir au buffer de paramètres
    ld c, $0a               ; Animation frame = $0A
    bit 5, b
    jr nz, SetAnimationFrame

    ld c, $09               ; Si pas flip: frame = $09

SetAnimationFrame:
    ld [hl], c              ; Écrit animation frame
    ld hl, wStateBuffer
    ld [hl], $02            ; État buffer = 2
    ld a, $0c
    ld [wGameVarAE], a      ; Timer/délai = 12 frames
    ld a, $ff
    ld [wGameVarA9], a      ; Flag = $FF
    ret


; ResetMenuStateToIdle
; --------------------
; Description: Réinitialise l'état du menu en mode idle et valide l'état du jeu.
;              Appelé quand le bit 7 du registre b est activé (typiquement après
;              une action menu ou un timeout).
; In:  b = flags d'état joypad (bit 7 = reset demandé)
; Out: Aucun
; Modifie: hl, a (via ValidateAndProcessGameState)
ResetMenuStateToIdle:
    ld hl, wPlayerUnk0C
    ld [hl], MENU_STATE_IDLE        ; État menu = idle (32 frames)
    jp ValidateAndProcessGameState


; HandleJoypadInputDelay
; ----------------------
; Description: Gère le délai d'input joypad en mode gameplay.
;              Si un bouton pressé (hJoypadDelta & FRAME_MASK_4), passe au buffer OAM.
;              Sinon, si bouton A appuyé et compteur wGameVarAE actif, décrémente le compteur.
;              Si compteur atteint 0, passe au buffer OAM.
; In:  hJoypadDelta = boutons nouvellement pressés (frame counter & 3)
;      hJoypadState = état actuel des boutons
;      wGameVarAE = compteur de délai (12 frames typiquement)
; Out: Aucun (peut sauter vers InitializeSpriteTransferBuffer)
; Modifie: a, hl
HandleJoypadInputDelay:
    ldh a, [hJoypadDelta]
    and FRAME_MASK_4
    jr nz, InitializeSpriteTransferBuffer

    ldh a, [hJoypadState]
    bit 0, a                            ; Bouton A pressé ?
    ret z

    ld hl, wGameVarAE
    ld a, [hl]
    and a                               ; Compteur délai actif ?
    jp z, InitializeSpriteTransferBuffer

    dec [hl]                            ; Décrémenter compteur délai
    ret


; CheckUnlockState
; ----------------
; Description: Gère la lecture d'inputs démo pré-enregistrés pendant le verrouillage.
;              Utilisé pour les séquences attract mode (démonstrations automatiques).
; In:  hUpdateLockFlag = flag de verrouillage (0 = déverrouillé)
; Out: hJoypadState et hJoypadDelta = inputs simulés depuis séquence démo
; Modifie: a, de, hl
CheckUnlockState::
    ; Early return si système déverrouillé (mode gameplay normal)
    ReturnIfUnlocked

    ; Si a == $ff, ne rien faire (état spécial)
    cp $ff
    ret z

    ; Vérifier si délai actif (wLevelVarD8 = compteur frames entre inputs)
    ld a, [wLevelVarD8]
    and a
    jr z, .loadNextDemoInput

    ; Décrémenter délai et sortir
    dec a
    ld [wLevelVarD8], a
    jr .applyDemoInput

.loadNextDemoInput:
    ; Charger table de pointeurs vers séquences démo par bank
    ld a, [wCurrentROMBank]
    sla a                               ; × 2 (pointeurs 16-bit)
    ld e, a
    ld d, $00
    ld hl, DemoSequencePointersTable
    add hl, de

    ; Charger pointeur vers séquence démo de cette bank
    ld e, [hl]
    inc hl
    ld d, [hl]
    push de
    pop hl

    ; Indexer dans la séquence selon wLevelVarD9 (offset courant)
    ld a, [wLevelVarD9]
    ld d, $00
    ld e, a
    add hl, de

    ; Lire paire [input, délai]
    ld a, [hl+]
    cp $ff                              ; Marqueur fin de séquence ?
    jr z, .clearDemoInput

    ; Stocker input et délai
    ld [wLevelVarDA], a                 ; Input joypad simulé
    ld a, [hl]
    ld [wLevelVarD8], a                 ; Délai avant prochain input

    ; Avancer offset de 2 octets (input + délai)
    inc e
    inc e
    ld a, e
    ld [wLevelVarD9], a

.applyDemoInput:
    ; Sauvegarder ancien état joypad et appliquer input démo
    ldh a, [hJoypadState]
    ld [wLevelVarDB], a                 ; Backup
    ld a, [wLevelVarDA]                 ; Input simulé
    ldh [hJoypadState], a
    ldh [hJoypadDelta], a
    ret

.clearDemoInput:
    ; Fin de séquence : réinitialiser input à 0
    xor a
    ld [wLevelVarDA], a
    jr .applyDemoInput

; DemoSequencePointersTable
; -------------------------
; Description: Table de pointeurs 16-bit vers les séquences d'inputs démo par bank ROM
; Format: 3 pointeurs little-endian (bank 0, 1, 2)
; Référencé par: Routine .loadNextDemoInput à $4AA7
DemoSequencePointersTable:
    dw $6550    ; Bank 0 - Pointeur vers séquence démo
    dw $65E0    ; Bank 1 - Pointeur vers séquence démo
    dw $6670    ; Bank 2 - Pointeur vers séquence démo

; InitRenderLoop
; ----------------
; Description: Initialise et traite la boucle de rendu pour 4 objets.
;              Parcourt les slots d'objets (wPlayerUnk10 + n*16) et ajuste
;              leurs positions X en fonction du scroll (hShadowSCX).
;              - Si objet = $80: marque comme désactivé ($ff)
;              - Si objet = $00 et offset+7 != 0: ajuste position X
; In:  wPlayerUnk10 = premier slot objet (structure 16 bytes)
;      hShadowSCX = position scroll actuelle
;      hRenderAttr = ancienne position scroll
; Out: hRenderAttr = mis à jour avec hShadowSCX
; Modifie: a, b, c, de, hl
InitRenderLoop::
    ld b, INIT_OBJECTS_LOOP_COUNT
    ld de, OBJECT_SLOT_SIZE
    ld hl, wPlayerUnk10

ProcessRenderObjectLoop:
    push hl
    ld a, [hl]
    cp $80
    jr nz, RenderLoopContinue

    ld [hl], $ff

RenderLoopContinue:
    and a
    jr nz, RenderLoopProcessActive

    push de
    ld de, $0007
    add hl, de
    pop de
    ld a, [hl]
    and a
    jr z, RenderLoopSetFlag

    dec l
    dec l
    ld a, [hl]
    dec l
    dec l
    dec l
    and a
    jr nz, RenderLoopDecrement

    inc [hl]
    ldh a, [hRenderAttr]
    ld c, a
    ldh a, [hShadowSCX]
    sub c
    ld c, a
    ld a, [hl]
    sub c
    ld [hl], a

RenderLoopProcessActive:
    pop hl
    add hl, de
    dec b
    jr nz, ProcessRenderObjectLoop

    ldh a, [hShadowSCX]
    ldh [hRenderAttr], a
    ret


RenderLoopDecrement:
    dec [hl]
    ldh a, [hRenderAttr]
    ld c, a
    ldh a, [hShadowSCX]
    sub c
    ld c, a
    ld a, [hl]
    sub c
    ld [hl], a
    jr RenderLoopProcessActive

RenderLoopSetFlag:
    pop hl
    push hl
    ld [hl], $80
    inc l
    inc l
    ld [hl], $ff
    jr RenderLoopProcessActive

; CheckBlockCollision
; -------------------
; Description: Vérifie la collision entre le joueur et les blocs frappés (type $03)
;              et ajuste la position/état selon la distance entre bloc et joueur
; In:  hBlockHitType = type de bloc frappé
;      hRenderX/Y = position du bloc rendu
;      wPlayerX = position X du joueur
;      wPlayerUnk0A = état spécial joueur (si !=0, efface collision)
; Out: carry = non utilisé (ret simple)
; Modifie: a, bc, hl
CheckBlockCollision::
    ldh a, [hBlockHitType]
    cp $03                  ; Type $03 = bloc frappé (à documenter dans constants.inc)
    ret nz

    ld hl, wOamVar2D
    ldh a, [hShadowSCX]
    ld b, a
    ldh a, [hRenderY]
    sub b
    ld [hl-], a
    ld a, [wPlayerX]
    sub PLAYER_X_SUB_OFFSET ; Offset X bloc frappé (11 pixels)
    ld [hl], a
    ld a, [wPlayerUnk0A]
    and a
    jr nz, HandleBlockCollisionClear

    ldh a, [hRenderX]
    ld b, a
    sub COLLISION_OFFSET_4  ; Distance minimale collision (4 pixels)
    cp [hl]
    jr nc, HandleBlockCollisionResolve

    ld a, b
    cp [hl]
    ret nc

HandleBlockCollisionClear:
    ld [hl], $00
    ld a, BLOCK_HIT_ITEM    ; Passer en type "bloc item"
    ldh [hBlockHitType], a
    ret


HandleBlockCollisionResolve:
    ld a, PLAYER_UNK07_FALLING  ; Marquer joueur en chute
    ld [wPlayerUnk07], a
    ret


; CheckPlayerBounds
; -----------------
; Description: Vérifie si le joueur est dans la zone critique de scroll et déclenche une transition d'état
;              Si le joueur est entre PLAYER_X_SCROLL_MIN et PLAYER_X_SCROLL_MAX, réinitialise les états
;              et timers pour déclencher une transition (probablement scrolling ou changement de zone)
; In:  wPlayerX = position X du joueur
; Out: hGameState = 1, wStateRender = 2, hTimer1 = TIMER_CHECKPOINT_LONG si dans zone critique
;      hTimerAux et hSubState = 0
; Modifie: a, hl
CheckPlayerBounds::
    ld hl, wPlayerX
    ld a, [hl]
    cp PLAYER_X_SCROLL_MIN      ; Seuil gauche zone scroll (180 pixels)
    ret c                       ; Si X < 180, retour sans action

    cp PLAYER_X_SCROLL_MAX      ; Seuil droit zone scroll (192 pixels)
    ret nc                      ; Si X >= 192, retour sans action

    ; Joueur dans zone critique [180-191] → déclencher transition
    xor a
    ldh [hTimerAux], a          ; Réinitialiser timer auxiliaire
    ldh [hSubState], a          ; Réinitialiser sous-état
    inc a
    ldh [hGameState], a         ; hGameState = 1
    inc a
    ld [wStateRender], a        ; wStateRender = 2
    ld a, TIMER_CHECKPOINT_LONG ; Timer checkpoint (144 frames)
    ldh [hTimer1], a
    ret


; CheckTimerAux1
; ----------------
; Description: Vérifie l'état du timer auxiliaire (cas 1). Gère l'animation
;              du joueur en mode pipe toutes les 4 frames quand timer actif.
; In:  hTimerAux = état timer, hTimer1 = compteur frames
; Out: wPlayerY mis à 0, wPlayerDir bit animation modifié
; Modifie: a
CheckTimerAux1::
    ldh a, [hTimerAux]
    cp TIMER_AUX_ACTIVE         ; État timer actif?
    ret nz

    ldh a, [hTimer1]
    and a
    jr z, TimerInitializeAux

    and FRAME_MASK_4
    ret nz

    xor a
    ld [wPlayerY], a
    ld a, [wPlayerDir]
    xor PLAYER_DIR_ANIM_BIT     ; Alterner bit animation
    ld [wPlayerDir], a
    ret

; TimerInitializeAux
; -------------------
; Description: Initialise le mode pipe quand timer1 est à 0
; In:  -
; Out: hTimerAux = TIMER_AUX_PIPE_MODE, wPlayerY = 0,
;      wPlayerDir bit animation activé
; Modifie: a
TimerInitializeAux:
    ld a, TIMER_AUX_PIPE_MODE   ; Passer en mode pipe
    ldh [hTimerAux], a
    xor a
    ld [wPlayerY], a
    ld a, [wPlayerDir]
    or PLAYER_DIR_ANIM_BIT      ; Activer bit animation
    ld [wPlayerDir], a
    ret


; CheckTimerAux2
; ----------------
; Description: Gère le timer auxiliaire en état 2 (phase de dégâts/récupération)
;              Alterne l'animation joueur pendant dégâts, puis passe en mode terminé
; In:  hTimerAux = état timer aux ($03=dégâts max, $04=terminé)
;      hTimer1 = timer principal pour timing animations
; Out: hTimerAux, hTimer1, wPlayerDir, wPlayerY modifiés selon état
; Modifie: a
CheckTimerAux2::
    ldh a, [hTimerAux]
    cp TIMER_AUX_COMPLETE       ; Timer terminé?
    jr z, .HandleCompleteState

    cp TIMER_AUX_DAMAGE_MAX     ; Seuil dégâts atteint?
    ret nz

    ldh a, [hTimer1]
    and a
    jr z, .TransitionToComplete

    and FRAME_MASK_4
    ret nz

    ld a, [wPlayerDir]
    xor PLAYER_DIR_ANIM_BIT     ; Alterner bit animation
    ld [wPlayerDir], a
    ret


.TransitionToComplete:
    ld a, TIMER_AUX_COMPLETE    ; Marquer timer comme terminé
    ldh [hTimerAux], a
    ld a, TIMER_CHECKPOINT_SHORT ; Timer checkpoint court (64 frames)
    ldh [hTimer1], a
    ld a, [wPlayerDir]
    and NIBBLE_LOW_MASK         ; Garder seulement nibble bas direction
    ld [wPlayerDir], a
    ret


.HandleCompleteState:
    ldh a, [hTimer1]
    and a
    jr z, .FullReset

    and FRAME_MASK_4
    ret nz

    ld a, [wPlayerY]
    xor $80                     ; Toggle bit 7 de Y (effet visuel fin damage)
    ld [wPlayerY], a
    ret


.FullReset:
    xor a                       ; a = 0
    ldh [hTimerAux], a          ; Reset timer aux
    ld [wPlayerY], a            ; Reset position Y
    ld a, [wPlayerDir]
    and NIBBLE_LOW_MASK         ; Garder seulement nibble bas direction
    ld [wPlayerDir], a
    ret


    ldh a, [hUpdateLockFlag]
    cp $ff
    ret nz

    ldh a, [hJoypadState]
    ld b, a
    ld a, [wLevelVarDA]
    cp b
    jr z, IncrementInputCounter

    ld hl, wDemoRecordBuffer
    ld a, [wLevelVarD9]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [wLevelVarDA]
    ld [hl+], a
    ld a, [wLevelVarD8]
    ld [hl], a
    inc e
    inc e
    ld a, e
    ld [wLevelVarD9], a
    ld a, b
    ld [wLevelVarDA], a
    xor a
    ld [wLevelVarD8], a
    ret


IncrementInputCounter:
    ld a, [wLevelVarD8]
    inc a
    ld [wLevelVarD8], a
    ret


; AnimFramePointerTable
; ----------------------
; Description: Table de pointeurs vers structures d'animation de sprites
; In:  hAnimFrameIndex = index de frame (multiplié par 2 dans le code)
; Format: Chaque entrée est un word (dw) - soit un pointeur vers structure,
;         soit des données embedded (coordonnées, etc.)
;         Dernière entrée: byte orphelin (db)
AnimFramePointerTable:
    dw $4C8D
    dw $4C91
    dw $4C95
    dw $4C99
    dw $4C9D
    dw $4CA1
    dw $4CA5
    dw $4CA9
    dw $4C8D
    dw $4C91
    dw $4CB1
    dw $4CB5
    dw $4CB9
    dw $4CBD
    dw $4CA5
    dw $4CAD
    dw $4CC1
    dw $4CC5
    dw $4CC9
    dw $4CCD
    dw $4CD1
    dw $4CD5
    dw $4CD9
    dw AnimFrame_4CDD_Overlap
    dw $4CE1
    dw $4CE5
    dw $4CE9
    dw $4CED
    dw $4CF1
    dw $4CF5
    dw $4CF5
    dw $4CF5
    dw $4CF9
    dw $4CFD
    dw $4D01
    dw $4D05
    dw $4D09
    dw $4D0D
    dw $4D19
    dw $4D15
    dw $4D11
    dw $4D1D
    dw $4D21
    dw $4D25

; AnimFrame Structures
; --------------------
; Description: Structures de frames d'animation (format: 2 words par structure)

AnimFrame_4C8D:
    dw $F8F9
    dw $4D2C
AnimFrame_4C91:
    dw $F8F9
    dw $4D33
; AnimFrame_Walk3 - Frame d'animation de marche (frame 3)
; Format: word offset_yx, word pointeur_vers_sprites
AnimFrame_4C95:
    dw $F8F9           ; Offset Y/X relatifs (signed bytes)
    dw $4D3A           ; → SpriteData_Walk3 (séquence de commandes sprite)
; AnimFrame_Walk4 - Frame d'animation de marche (frame 4)
; Format: word offset_yx, word pointeur_vers_sprites
AnimFrame_Walk4:
AnimFrame_4C99:
    dw $F8F9           ; Offset Y/X relatifs (signed bytes)
    dw $4D41           ; → SpriteData_Walk4 (séquence de commandes sprite)
; AnimFrame_Walk5 - Frame d'animation de marche (frame 5)
; Format: word offset_yx, word pointeur_vers_sprites
AnimFrame_Walk5:
AnimFrame_4C9D:
    dw $F8F9           ; Offset Y/X relatifs (signed bytes)
    dw $4D48           ; → SpriteData_Walk5 (séquence de commandes sprite)
; AnimFrame_Walk6 - Frame d'animation de marche (frame 6)
; Format: word offset_yx, word pointeur_vers_sprites
AnimFrame_Walk6:
AnimFrame_4CA1:
    dw $F8F9           ; Offset Y/X relatifs (signed bytes)
    dw $4D4F           ; → SpriteData_Walk6 (séquence de commandes sprite)
; WARNING: Zone mal désassemblée! Données réelles @ $4CA7: 02 00 04 00 04 00...
; Cette zone entière ($4BF1-$4CFF) nécessite reconstruction complète
; Adresse ROM réelle de ce label: $4CA7 (pas $4CA5)
AnimFrame_4CA5:
    dw $FBF9
    dw $4D56           ; → SpriteData séquence de commandes sprite
; NOTE: L'adresse $4CA9 (référencée dans AnimFramePointerTable) pointe ici,
;       au milieu de la structure précédente ($4CA7-$4CAA).
;       Lecture depuis $4CA9: dw $4D56, $FBF9 (optimisation d'espace mémoire)
AnimFrame_4CA9:
    dw $FBF9           ; Offset Y/X relatifs (signed bytes: -5, -7)
    dw $4D5D           ; → SpriteData (séquence de commandes sprite)
; AnimFrame_4CAD - Structure d'animation
; Format: word offset_yx, word pointeur_vers_sprites
AnimFrame_4CAD:
    dw $FCFC           ; Offset Y/X relatifs (signed bytes: -4, -4)
    dw $4D61           ; → SpriteData (séquence de commandes sprite - MAL DÉSASSEMBLÉ)
AnimFrame_4CB1:
    dw $F8F9
    dw $4D68
AnimFrame_4CB5:
    dw $F8F9
    dw $4D6F
AnimFrame_4CB9:
    dw $F8F9
    dw $4D76
; AnimFrame_4CBD - Structure d'animation #13
; Format: word offset_yx, word pointeur_vers_sprites
AnimFrame_4CBD:
    dw $F8F9           ; Offset Y/X relatifs (signed bytes: -8, -7)
    dw $4D7D           ; → SpriteData AnimFrame_4D7D
; AnimFrame_4CC1 - Structure d'animation #14
; Format: word offset_yx, word pointeur_vers_sprites
AnimFrame_4CC1:
    dw $F8F9           ; Offset Y/X relatifs (signed bytes: -8, -7)
    dw $4D84           ; → SpriteData (mal désassemblé à reconstruire)
; AnimFrame_4CC5 - Structure d'animation #16
; Format: word offset_yx, word pointeur_vers_sprites
AnimFrame_4CC5:
    dw $F8F9           ; Offset Y/X relatifs (signed bytes: -8, -7)
    dw $4D8B           ; → SpriteData (mal désassemblé à reconstruire)
; AnimFrame_4CC9 - Structure d'animation #17
; Format: word offset_yx, word pointeur_vers_sprites
AnimFrame_4CC9:
    dw $F8F9           ; Offset Y/X relatifs (signed bytes: -8, -7)
    dw $4D92           ; → SpriteData (mal désassemblé à reconstruire)

; AnimFrame_4CCD - Structure d'animation #18
; Format: word offset_yx, word pointeur_vers_sprites
AnimFrame_4CCD:
    dw $F8F9           ; Offset Y/X relatifs (signed bytes: -8, -7)
    dw $4D99           ; → AnimFrame_4D99 (structure imbriquée)

; AnimFrame_4CD1 - Structure d'animation #19
; Format: word offset_yx, word pointeur_vers_sprites
AnimFrame_4CD1:
    dw $F8F9           ; Offset Y/X relatifs (signed bytes: -8, -7)
    dw $4DA0           ; → SpriteData (mal désassemblé à reconstruire)

; AnimFrame_4CD5 - Structure d'animation #20
; Format: word offset_yx, word pointeur_vers_sprites
AnimFrame_4CD5:
    dw $F8F9           ; Offset Y/X relatifs (signed bytes: -8, -7)
    dw $4DA7           ; [$4CD9] → SpriteData_4DA7 (données sprite OAM)
AnimFrame_4CD9:
    dw $FBF9
; AnimFrame_4CDD - Overlap intentionnel
; Référencé par AnimFramePointerTable[22] - pointe vers le 2e word de AnimFrame_4CD9
; Contenu à $4CDD: dw $4DAE, dw $FBF9 (ce word + 1er word de AnimFrame_4CDF)
AnimFrame_4CDD_Overlap:
    dw $4DAE
AnimFrame_4CDD:
    dw $FBF9
; AnimFrame_4CE1 - Overlap intentionnel (table pointe vers $4CE1)
; Référencé par AnimFramePointerTable[24] - pointe vers le 2e word de AnimFrame_4CDD
; Contenu à $4CE1: dw $4DB5, dw $F8F9 (ce word + 1er word de AnimFrame_4CE3)
AnimFrame_4CE1_Overlap:
    dw $4DB5
; AnimFrame_4CE1 - Structure d'animation #24 (label historique, adresse réelle $4CE3)
; Format: word offset_yx, word pointeur_vers_sprites
AnimFrame_4CE1:
    dw $F8F9           ; Offset Y/X relatifs (signed bytes: -8, -7)
    dw $4DBC           ; → SpriteData_4DBC (données sprite OAM)
; AnimFrame_4CE5 - Structure d'animation #25
; Format: word offset_yx, word pointeur_vers_sprites
AnimFrame_4CE5:
    dw $F8F9           ; Offset Y/X relatifs (signed bytes: -8, -7)
    dw $4DC3           ; → SpriteData_4DC3 (données sprite OAM)
AnimFrame_4CE9:
    dw $F8F9           ; Offset Y/X relatifs (signed bytes: -8, -7)
    dw $4DCA           ; → SpriteData_4DCA (données sprite OAM)
; AnimFrame_4CED - Structure d'animation #27
; Format: word offset_yx, word pointeur_vers_sprites
AnimFrame_4CED:
    dw $F8F9           ; Offset Y/X relatifs (signed bytes: -8, -7)
    dw $4DD1           ; → SpriteData_4DD1 (données sprite OAM - zone mal désassemblée, sera reconstruite)
; AnimFrame_4CF1 - Structure d'animation #28
; Format: word offset_yx, word pointeur_vers_sprites
AnimFrame_4CF1:
    dw $F8F9           ; Offset Y/X relatifs (signed bytes: -8, -7)
    dw $4DD8           ; → SpriteData_4DD8 (données sprite OAM)
; AnimFrame_4CF5 - Structure d'animation #29
; Format: word offset_yx, word pointeur_vers_sprites
AnimFrame_4CF5:
    dw $F8F9           ; Offset Y/X relatifs (signed bytes: -8, -7)
    dw $4DDF           ; → SpriteData_4DDF (données sprite OAM - zone mal désassemblée, sera reconstruite)
; AnimFrame_4CF9 - Structure d'animation #30
; Format: word offset_yx, word pointeur_vers_sprites
AnimFrame_4CF9:
    dw $F8F9           ; Offset Y/X relatifs (signed bytes: -8, -7)
    dw $4DE6           ; → SpriteData_4DE6 (données sprite OAM - zone mal désassemblée, sera reconstruite)
; AnimFrame_4CFD - Structure d'animation #31
; Format: word offset_yx, word pointeur_vers_sprites
AnimFrame_4CFD:
    dw $F8F9           ; Offset Y/X relatifs (signed bytes: -8, -7)
    dw $4DED           ; → SpriteData_4DED (données sprite OAM - zone mal désassemblée, sera reconstruite)
; AnimFrame_4D01 - Structure d'animation #32
; Format: word offset_yx, word pointeur_vers_sprites
AnimFrame_4D01:
    dw $F8F9           ; Offset Y/X relatifs (signed bytes: -8, -7)
    dw $4DF4           ; → SpriteData_4DF4 (données sprite OAM - zone mal désassemblée, sera reconstruite)
; AnimFrame_4D05 - Structure d'animation #33
; Format: word offset_yx, word pointeur_vers_sprites
AnimFrame_4D05:
    dw $F8F9           ; Offset Y/X relatifs (signed bytes: -8, -7)
    dw $4DFB           ; → SpriteData_4DFB (données sprite OAM - zone mal désassemblée, sera reconstruite)
; AnimFrame_4D09 - Structure d'animation #36
; Format: word offset_yx, word pointeur_vers_sprites
AnimFrame_4D09:
    dw $F8F9           ; Offset Y/X relatifs (signed bytes: -8, -7)
    dw $4E02           ; → SpriteData_4E02 (données sprite OAM dans GfxData_SpriteFrames - zone mal désassemblée)
; AnimFrame_4D0D - Structure d'animation #37
; Format: word offset_yx, word pointeur_vers_sprites
AnimFrame_4D0D:
    dw $F8F9           ; Offset Y/X relatifs (signed bytes: -8, -7)
    dw $4E09           ; → SpriteData_4E09 (données sprite OAM - zone mal désassemblée, sera reconstruite)
; AnimFrame_4D11 - Structure d'animation #38
; Format: word offset_yx, word pointeur_vers_sprites
AnimFrame_4D11:
    dw $F8F9           ; Offset Y/X relatifs (signed bytes: -8, -7)
    dw $4E14           ; → SpriteData_4E14 (données sprite OAM)
; AnimFrame_4D15 - Structure d'animation #39
; Format: word offset_yx, word pointeur_vers_sprites
AnimFrame_4D15:
    dw $F7F9           ; Offset Y/X relatifs (signed bytes: -9, -7)
    dw $4E1F           ; → SpriteData_4E1F (données sprite OAM - zone mal désassemblée, sera reconstruite)
; AnimFrame_4D19 - Structure d'animation #40
; Format: word offset_yx, word pointeur_vers_sprites
AnimFrame_4D19:
    dw $F8F9           ; Offset Y/X relatifs (signed bytes: -8, -7)
    dw $4E2A           ; → SpriteData_4E2A (données sprite OAM)
; AnimFrame_4D1D - Structure d'animation #41
; Format: word offset_yx, word pointeur_vers_sprites
AnimFrame_4D1D:
    dw $F8F9           ; Offset Y/X relatifs (signed bytes: -8, -7)
    dw $4E35           ; → SpriteData_4E35 (données sprite OAM)
; AnimFrame_4D21 - Structure d'animation #42
; Format: word offset_yx, word pointeur_vers_sprites
AnimFrame_4D21:
    dw $F8F9           ; Offset Y/X relatifs (signed bytes: -8, -7)
    dw $4E44           ; → SpriteData_4E44 (données sprite OAM - zone mal désassemblée)
; AnimFrame_4D25 - Structure d'animation #43
; Format différent des précédentes (pas d'offset Y/X standard)
AnimFrame_4D25:
    dw $0100           ; Valeur de contrôle ou index
    dw $1110           ; Valeur de contrôle ou index
AnimFrame_4D29:
    dw $44FF
    dw $024E
AnimFrame_4D2D:
    dw $1203
    dw $FF13
AnimFrame_4D31:
    dw $4E44
; SpriteData_4D33 - Données sprite (commence au second word de AnimFrame_4D31)
; Référencé par: AnimFrame_4C91
; Format: Séquence de words (commandes sprite OAM)
; Note: Optimisation de partage - $4D33 pointe au milieu de la structure AnimFrame_4D31
SpriteData_4D33:
    dw $0504
AnimFrame_4D35:
    dw $1514
    db $FF             ; Terminateur de SpriteData_4D33 ($4D37)
; SpriteData_Walk3
; ----------------
; Description: Séquence de commandes sprite pour l'animation de marche (frame 3)
; In:  Pointeur référencé par AnimFrame_4C95 ($4C95)
; Out: Aucun (données pures)
; Format: Séquence de words [sprite_data]*, terminée par $FF
;         Chaque sprite est défini par des words (tile_id, attrs, ou Y/X selon contexte)
; Note: Optimisation mémoire - débute au milieu de la structure précédente
;       Le label pointe à $4D3A, partageant des bytes avec les données adjacentes
SpriteData_Walk3:      ; @ $4D3A
    dw $4E44           ; Sprite 1: tile=$44, attrs=$4E
    dw $0100           ; Sprite 2: Y_offset=$00, X_offset=$01
    dw $1716           ; Sprite 3: Y_offset=$16, X_offset=$17
    db $FF             ; Terminateur de séquence
; SpriteData_Walk4
; ----------------
; Description: Séquence de sprites pour animation marche frame 4
; In:  Pointeur référencé par AnimFrame_Walk4 ($4C99 → adresse $4D41)
; Out: Aucun (données pures)
; Format: word pairs encodant tiles/positions sprite
; Note: Structure mal désassemblée - vrai format: $44 $4E [tiles] [coords] $FF
;       Le label généré AnimFrame_4D41 pointe en fait à $4D43 (décalage de 2)
SpriteData_Walk4:           ; @ $4D41 (commence par dw $4E44 = bytes 44 4e)
    dw $4E44                ; Prefix standard sprite: bytes $44 $4E
SpriteData_Walk4_TileData:  ; @ $4D43 (ancien AnimFrame_4D41)
    dw $0908                ; Tiles: bytes $08 $09
    dw $1918                ; Coords: bytes $18 $19
AnimFrame_4D45:
    dw $44FF
    dw $0A4E
; SpriteData_Walk5
; ----------------
; Description: Données sprite mal désassemblées pour animation marche frame 5
;              Zone de données binaires avec points d'entrée multiples (optimisation mémoire)
; In:  Référencé par AnimFrame_Walk5 ($4C9D)
; Out: Aucun (données pures)
; Format: Séquence de bytes encodant des commandes sprite OAM
;         Les labels AnimFrame_4D** sont des points d'entrée alternatifs dans les données
; Note: Zone mal désassemblée - les dw ne correspondent pas au format réel
;       Nécessite reconstruction complète basée sur xxd pour comprendre le vrai format
SpriteData_Walk5:
AnimFrame_4D48:
AnimFrame_4D49:
    dw $1A0B
    dw $FF1B
AnimFrame_4D4D:
    dw $4E44
    dw $0100
AnimFrame_4D51:
    dw $0D0C
    dw $44FF
AnimFrame_4D55:
    dw $004E
    dw $1C01
AnimFrame_4D59:
    dw $FF1D
    dw $4E44
AnimFrame_4D5D:
    dw $FF62
    dw $4E44
AnimFrame_4D61:
    dw $7170
    dw $7372
AnimFrame_4D65:
    dw $44FF
    dw $704E
AnimFrame_4D69:
    dw $7471
    dw $FF73
AnimFrame_4D6D:
    dw $4E44
    dw $6463
AnimFrame_4D71:
    dw $6665
    dw $44FF
AnimFrame_4D75:
    dw $634E
    dw $6564
AnimFrame_4D79:
    dw $FF67
    dw $4E44
AnimFrame_4D7D:
    dw $2120
    dw $3130
AnimFrame_4D81:
    dw $44FF
    dw $224E
AnimFrame_4D85:
    dw $3223
    dw $FF33
AnimFrame_4D89:
    dw $4E44
    dw $2524
AnimFrame_4D8D:
    dw $3534
    dw $44FF
AnimFrame_4D91:
    dw $224E
    dw $3623
AnimFrame_4D95:
    dw $FF37
    dw $4E44
AnimFrame_4D99:
    dw $2928
    dw $3938
AnimFrame_4D9D:
    dw $44FF
    db $4E


PaddingZone_003_4da2:
    ld a, [hl+]
    dec hl
    ld a, [hl-]
    dec sp
    rst $38
    ld b, h
    ld c, [hl]
    inc l
    dec l
    inc a
    dec a
    rst $38
    ld b, h
    ld c, [hl]
    ld l, $2f
    ld a, $3f

PaddingZone_003_4db4:
    rst $38
    ld b, h
    ld c, [hl]
    ld b, b
    ld b, c
    ld b, d
    ld b, e
    rst $38
    ld b, h
    ld c, [hl]
    ld b, h
    ld b, l
    ld b, [hl]
    ld b, a
    rst $38
    ld b, h
    ld c, [hl]
    ld [hl], l

DispatchDataZone_4dc6:
    halt
    ld [hl], a
    ld a, b
    rst $38
    ld b, h
    ld c, [hl]
    ld [hl], l
    halt
    ld a, c
    ld a, b
    rst $38
    ld b, h
    ld c, [hl]
    ld l, b
    ld l, c
    ld l, d
    ld l, e
    rst $38

DispatchDataZone_4dd8:
    ld b, h
    ld c, [hl]
    ld l, b
    ld l, h
    ld l, d
    ld l, l
    rst $38
    ld b, h
    ld c, [hl]
    and b
    and c
    or b
    or c
    rst $38
    ld b, h
    ld c, [hl]
    and d
    and e
    or d
    or e
    rst $38
    ld b, h
    ld c, [hl]
    ld c, [hl]
    ld c, c
    ld d, b
    ld d, c
    rst $38
    ld b, h
    ld c, [hl]
    ld c, b
    ld c, c
    ld c, d
    ld c, e
    rst $38
    ld b, h
    ld c, [hl]
    inc c
    dec c
    inc e
    dec e
    rst $38
    ld b, h
    ld c, [hl]
    ld l, $2f
    ld a, $3f
    rst $38
    ld e, h
    ld c, [hl]
    inc l
    inc l
    ld c, a
    inc a
    dec l
    dec a
    ld c, h
    ld c, l
    rst $38
    ld c, h
    ld c, [hl]
    ld c, $4f
    dec l
    ld c, h
    ld e, $3c
    dec a
    ld c, l
    rst $38
    ld e, h
    ld c, [hl]
    ld h, $27
    ld c, a
    inc a
    dec l
    dec a
    ld c, h
    ld c, l
    rst $38
    ld e, h
    ld c, [hl]
    cp $7c
    ld h, c
    ld a, l
    ld l, a
    ld a, [hl]
    ld a, e
    ld a, a
    rst $38
    ld e, h
    ld c, [hl]
    cp $7c
    ld h, c
    ld a, l
    ld l, a
    ld a, [hl]
    ld h, c
    ld a, l
    ld l, a
    ld a, [hl]
    ld a, e
    ld a, a
    rst $38
    nop
    nop
    nop
    ld [$0008], sp
    ld [$0008], sp
    nop
    nop
    add hl, bc
    nop
    ld de, $1900
    ld [$0800], sp
    add hl, bc
    ld [$0811], sp
    add hl, de
    nop
    nop
    ld [$0000], sp
    ld [$0808], sp
    nop
    db $10
    ld [$0010], sp
    jr PaddingZone_003_4e73

    jr PaddingZone_003_4e6d

PaddingZone_003_4e6d:
    jr nz, UnreachableCodeData_003_03

    jr nz, PaddingZone_003_4e71

PaddingZone_003_4e71:
    jr z, PaddingZone_003_4e7b

PaddingZone_003_4e73:
    jr z, DispatchDataTable_4e84
    rrca
    inc a

UnreachableCodeData_003_03:
    db $10
    ld c, a
    ret


    inc d

PaddingZone_003_4e7b:
    rrca
    inc b
    jr DispatchDataTable_4e8e

    ld [hl], $18
    adc a
    ld [hl], $19

DispatchDataTable_4e84:
    rrca
    ld [hl], $19
    adc a
    ld [hl], $1a
    rrca
    ld [hl], $1a
    adc a

DispatchDataTable_4e8e:
    ld [hl], $1d
    rrca
    inc b
    rra
    rlca
    cp h
    rra
    ld c, [hl]
    ret


    inc hl
    rrca
    add h
    inc h
    ld c, a
    ld c, c
    ld sp, $0404
    ld sp, $3c04
    inc [hl]
    add a
    ld a, [bc]
    scf
    adc d
    ld a, [hl-]
    ld a, [hl-]
    adc c
    ld a, [bc]
    inc a
    ld c, a
    ld [bc], a
    ld a, $8b
    inc b
    ld b, c
    add hl, bc
    add h
    ld b, a
    ld c, [hl]
    ld [bc], a
    ld c, h
    ld c, a
    ld c, c
    ld d, c
    rrca
    or c
    ld d, e
    rrca
    inc b
    ld d, a
    ld c, $31
    ld e, b
    rrca
    inc b
    ld e, [hl]
    adc d
    add h
    ld h, b
    ld [$6331], sp
    inc b
    inc a
    ld l, d
    ld [$6d04], sp
    inc b
    inc a
    ld [hl], c
    db $10
    dec bc
    ld [hl], d
    ld b, $3a
    ld [hl], a
    ld b, $0b
    ld a, c
    ld c, [hl]
    ld c, c
    ld a, [hl]
    ld c, a
    ld c, c
    add [hl]
    ld c, d
    ld [bc], a
    adc b
    rrca
    ld sp, $0f89
    ld sp, $8789
    inc a
    adc d
    rrca
    ld sp, $878d
    add h
    adc [hl]
    rrca
    inc a
    sub b
    ld c, d
    ld c, c
    sub l
    dec bc
    ld sp, $059b
    inc bc
    and l
    dec b
    inc bc
    xor a
    dec b
    inc bc
    cp c
    dec b
    inc bc
    jp $0345


    rst $10
    dec b
    inc bc
    pop hl
    adc d
    dec sp
    db $e3
    rlca
    ld [hl], $e4
    dec b
    ld [hl], $ff

; LevelHandler_4_7_Part2 - Handler niveaux 4-7 (partie 2)
LevelHandler_4_7_Part2:
    inc c
    add l
    dec h
    rrca
    db $10
    inc b
    db $10
    adc h
    add h
    inc de
    dec b
    dec h
    inc de
    rrca
    adc [hl]
    ld d, $0f
    inc b
    add hl, de
    adc b
    dec h
    ld a, [de]
    adc b
    dec h
    dec e
    ld c, [hl]
    ld [bc], a
    ld e, $05
    dec h
    jr nz, PaddingZone_003_4f41

    or l
    ld hl, $02c4

PaddingZone_003_4f41:
    jr z, DispatchDataZone_4f4a

    dec h
    ld a, [hl+]
    inc c
    ld c, $2c
    rrca
    inc b

DispatchDataZone_4f4a:
    dec l
    add e
    or l
    ld l, $06
    dec h
    ld sp, $840c
    ld [hl-], a
    inc b
    or l
    inc sp
    ld [bc], a
    inc b
    inc [hl]
    inc c
    add h
    scf
    adc a
    inc b
    dec sp
    add [hl]
    dec [hl]
    ld a, $0c
    add h
    ld b, b
    inc c
    inc b
    ld b, h
    ld b, $25
    ld b, l
    dec bc
    ld c, $46
    ld [$4925], sp
    rrca
    inc b
    ld c, e
    add h
    or l
    ld c, [hl]
    ld [$4f0e], sp
    inc c
    add h
    ld d, c
    adc $49
    ld d, e
    dec b
    dec h
    ld d, l
    rrca
    adc [hl]
    ld d, [hl]
    inc c
    inc b
    ld e, b
    ld c, $8e
    ld h, e
    dec bc
    ld c, $69
    add e
    inc bc
    ld [hl], e
    add e
    inc bc
    ld a, e
    dec b
    or l
    ld a, e
    rst $08
    ld c, c
    ld a, h
    adc b
    dec h
    ld a, [hl]
    rrca
    ld c, $7f
    rrca
    add h
    add c
    ld c, [hl]
    ld [bc], a
    add h
    ld [$880a], sp
    dec c
    inc b
    adc c
    ld b, a
    ld a, [hl-]
    adc h
    adc d
    ld [hl], $8d
    ld a, [bc]
    ld [hl], $8e
    adc c
    ld [hl], $8f
    add hl, bc

DispatchDataTable_4fbb:
    ld [hl], $92
    adc d
    ld [hl], $94
    dec bc
    ld [hl], $94
    adc e
    ld [hl], $96
    adc e
    ld [hl], $98
    ld a, [bc]
    ld [hl], $99
    adc c
    ld [hl], $9b
    ld [$9c36], sp
    add a
    ld [hl], $9e
    dec b
    ld [hl], $ff
    ld c, $8c
    dec bc
    ld [de], a
    add hl, bc
    jr c, PaddingZone_003_4ff3

    add hl, bc
    add hl, sp
    add hl, de
    adc b
    jr c, @+$1f

    dec b
    dec sp
    ld h, $0a
    ld a, [hl-]
    daa
    ld [$2736], sp
    adc b
    ld [hl], $27
    dec c
    ld b, a

PaddingZone_003_4ff3:
    jr z, DispatchDataTable_4fbb

    ld [bc], a
    add hl, hl
    dec c
    inc b
    dec [hl]
    db $10
    ld c, $37
    rlca
    inc b
    add hl, sp
    db $10
    ld c, $3f
    ld c, $0b
    ld b, c
    adc h
    jr c, PaddingZone_003_504d

    adc h
    add hl, sp
    ld b, [hl]
    add h
    ld a, [hl-]
    ld c, h
    inc b
    dec bc
    ld c, [hl]
    db $10
    dec bc
    ld d, l
    add hl, bc
    ld [hl], $55
    adc c
    ld [hl], $57
    db $10
    dec bc
    ld e, l
    db $10
    dec sp
    ld h, b
    sub c
    dec sp
    ld l, a
    rrca
    inc a
    ld [hl], c
    rrca
    or c
    ld [hl], e
    rrca
    ld sp, $8f7a
    cp h
    ld a, e
    ld a, [bc]
    add h
    ld a, h
    adc a
    ld b, a
    adc b
    inc c
    cp h
    adc c
    adc d
    inc a
    sub d
    ld c, $32
    rst $38
    and l
    ld d, [hl]
    and l
    ld d, [hl]
    jp nz, $cc5c

    ld d, d
    ld d, e
    ld d, e
    ret


    ld d, e
    ld d, e
    ld d, e

PaddingZone_003_504d:
    jr nz, PaddingZone_003_50a3

    xor d
    ld d, h
    ldh a, [rHDMA4]
    ld d, e
    ld d, e
    call z, CheckAnimObjectState

CheckAnimationState:
    ld d, h
    jr nz, PaddingZone_003_50af

    xor d
    ld d, h
    ld d, e

PaddingZone_003_505e:
    ld d, e
    ld c, [hl]
    ld d, l
    ld c, [hl]
    ld d, l
    cp c
    ld h, d
    dec sp
    ld h, e
    cp c
    ld h, d
    cp c
    ld h, d
    or d
    ld h, e
    db $dd
    ld d, l
    dec sp
    ld h, e
    ld c, c
    ld d, [hl]
    rst $38
    jp nz, $a55c

    ld d, [hl]
    jp nz, $c95c

    ld d, a
    adc b
    ld e, b
    ret


    ld d, a
    inc h
    ld e, c
    rst $20
    ld e, c
    inc h
    ld e, c
    ld c, e
    ld e, d
    rst $20
    ld e, c
    adc b
    ld e, b
    ld c, e
    ld e, d
    cp h
    ld e, d
    cp h
    ld e, d
    ret


    ld d, a
    jp nz, $4b5b

    ld e, h
    ld c, c
    ld d, [hl]
    rst $38
    and l
    ld d, [hl]
    and l
    ld d, [hl]
    jp nz, $815c

    ld e, l

PaddingZone_003_50a3:
    rst $28
    ld e, l
    rst $28
    ld e, l
    add c
    ld e, l
    ld d, a
    ld e, [hl]

Return_IfNotZero_003_50ab:
    ret nz

PaddingZone_003_50ac:
    ld e, [hl]
    rst $28
    ld e, l

PaddingZone_003_50af:
    rst $28
    ld e, l
    ld e, h
    ld e, a
    adc $5f
    ld c, [hl]
    ld h, b
    ld c, [hl]
    ld h, b
    ld b, d
    ld h, c
    ld b, d
    ld h, c
    dec b
    ld h, d
    rst $38
    inc l
    ld d, d
    inc l
    ld d, d
    inc l
    ld d, d
    inc l
    ld d, d
    rst $38
    nop
    dec b
    ld bc, $0501
    jr CheckAnimationState

    ld a, [bc]
    ld bc, $0a02
    jr PaddingZone_003_505e

    rst $38
    rlca
    nop
    ld [bc], a
    rlca
    db $10
    ld a, b
    dec bc
    ld [$0b01], sp
    ld d, b
    jr nc, @+$01

    rlca
    ld [bc], a
    ld bc, $2007
    add b
    ld c, $02
    ld [bc], a
    ld c, $20
    add b
    rst $38
    dec b
    dec b
    ld bc, $3805
    ld e, b
    rrca
    dec b
    ld [bc], a
    rrca
    jr c, AudioDataRaw_003_5155

    rst $38
    ld b, $02
    ld [bc], a
    ld b, $20
    add b
    ld de, $0108
    ld de, $6050
    rst $38
    ld [$0107], sp
    ld [$3048], sp
    rrca
    rlca
    ld [bc], a
    rrca
    ld c, b
    adc b
    rst $38
    rlca
    ld bc, $0701
    jr @+$42

    dec bc
    ld [bc], a
    ld [bc], a
    dec bc
    jr nz, PaddingZone_003_50ac

    rst $38
    inc bc
    ld [bc], a
    ld [bc], a
    inc bc
    jr nz, Return_IfNotZero_003_50ab

    ld d, $07
    ld [bc], a
    ld d, $48
    sbc b
    rst $38
    ld b, $02
    ld bc, $2006
    sub b
    ld [de], a
    ld b, $01
    ld [de], a
    ld b, b
    adc b
    rst $38
    inc b
    ld [bc], a
    jr z, @+$09

    inc bc
    ld a, [hl+]
    rlca
    rrca
    jr z, LoadPointerFromMemory

    ld c, $2c
    rrca
    inc de
    ret nz

    rst $38
    inc b
    ld bc, $0728
    rrca

LoadPointerFromMemory:
    ld a, [hl+]

AudioDataRaw_003_5155:
    dec bc
    inc de
    jr z, DispatchDataZone_5166

    ld c, $2a
    rst $38
    ld bc, $2a0e
    ld [bc], a
    ld [$0228], sp
    rrca
    ret nz

    inc bc

DispatchDataZone_5166:
    ld [bc], a
    rlca
    ld a, [bc]
    ld a, [bc]
    rlca
    inc c
    dec c
    ret nz

    dec c
    ld b, $28
    ld c, $0b
    jr z, @+$01

    ld bc, $2801
    ld bc, $2809
    ld [bc], a
    ld [de], a
    ldh a, [rDIV]
    ld c, $28
    rlca
    add hl, bc
    jr z, @+$0d

    inc b
    inc l
    ld c, $09
    ret nz

    rrca
    inc b
    jr z, PaddingZone_003_519f

    ld [$ff2a], sp
    ld bc, wOamVar09
    ld [bc], a
    inc b
    ldh a, [rSC]
    db $10
    ret nz

    inc b
    db $10
    jr z, @+$0a

    rrca

PaddingZone_003_519f:
    inc l
    add hl, bc
    rrca
    jr z, PaddingZone_003_51ae

    dec bc
    jr z, @+$01

    inc b
    rrca
    jr z, PaddingZone_003_51b1

    ld a, [bc]
    inc l
    inc c

PaddingZone_003_51ae:
    ld [bc], a
    jr z, @+$14

PaddingZone_003_51b1:
    ld [bc], a
    ld a, [hl+]
    inc de
    ld de, $ff28
    dec b
    inc bc
    jr z, AudioTableRaw_003_51c2

    nop
    ret nz

    dec c
    inc b
    ld a, [hl+]
    rrca
    inc bc

AudioTableRaw_003_51c2:
    jr z, @+$01

    ld bc, $2812
    ld [bc], a
    ld a, [bc]
    ret nz

    inc b
    rrca
    ldh a, [rTMA]
    dec c
    jr z, @+$0a

    inc c
    rlca
    ld a, [bc]
    inc de
    jr z, @+$01

    ld bc, $2812
    ld [bc], a
    add hl, bc
    ret nz

    rlca
    dec bc
    jr z, @+$0a

    add hl, bc
    ld a, [hl+]
    dec bc
    inc b
    ldh a, [rIF]
    inc bc
    jr z, @+$01

    inc bc
    db $10
    jr z, PaddingZone_003_51f6

    add hl, bc
    ret nz

    ld a, [bc]
    rlca
    jr z, AudioParam_Set_1

    nop
    inc l

PaddingZone_003_51f6:
    ld c, $11
    ret nz

    rrca
    ld de, $1028
    ld de, $14c0

AudioParam_Set_1:
    add hl, bc
    jr z, AudioParam_Set_3

    inc bc
    ld a, [hl+]
    rst $38
    dec b
    ld a, [bc]
    jr z, AudioParam_Set_2

    ld b, $28
    ld a, [bc]
    add hl, bc
    jr z, AudioDataRaw_003_521d

    dec b
    inc l

AudioParam_Set_2:
    rrca
    dec b
    jr z, @+$13

    nop
    ret nz

AudioParam_Set_3:
    rst $38
    inc bc
    ld c, $28
    add hl, bc

AudioDataRaw_003_521d:
    ld a, [bc]
    jr z, AudioDataRaw_003_522a

    ld c, $2a
    inc c
    ld c, $2c
    rrca
    ld c, $28
    jr AudioParam_Set_4

AudioDataRaw_003_522a:
    jr z, @+$01

    ld [bc], a
    adc [hl]
    adc a
    db $d3
    adc [hl]

AudioParam_Set_4:
    adc a
    adc [hl]
    cp $02
    adc a
    adc [hl]
    db $d3
    adc a
    adc [hl]
    adc a
    cp $02
    adc [hl]
    adc a
    db $d3
    adc [hl]
    adc a
    adc [hl]
    cp $02
    adc a
    adc [hl]
    db $d3
    adc a
    adc [hl]
    adc a
    cp $02
    adc [hl]
    adc a
    db $d3
    adc [hl]
    adc a
    adc [hl]
    cp $02
    adc a
    adc [hl]
    db $d3
    adc a
    adc [hl]
    adc a
    cp $02
    adc [hl]
    adc a
    db $d3
    adc [hl]
    adc a
    adc [hl]
    cp $02
    adc a
    adc [hl]
    db $d3
    adc a
    adc [hl]
    adc a
    cp $02
    adc [hl]
    adc a
    db $d3
    adc [hl]
    adc a
    adc [hl]
    cp $02
    adc a
    adc [hl]
    db $d3
    adc a
    adc [hl]
    adc a
    cp $02
    adc [hl]
    adc a
    db $d3
    adc [hl]
    adc a
    adc [hl]
    cp $02
    adc a
    adc [hl]
    db $d3
    adc a
    adc [hl]
    adc a
    cp $02
    adc [hl]
    adc a
    db $d3
    adc [hl]
    adc a
    adc [hl]
    cp $02
    adc a
    adc [hl]
    db $d3
    adc a
    adc [hl]
    adc a
    cp $02
    adc [hl]
    adc a
    db $d3
    adc [hl]
    adc a
    adc [hl]
    cp $02
    adc a
    adc [hl]
    db $d3
    adc a
    adc [hl]
    adc a
    cp $02
    adc [hl]
    adc a
    db $d3
    adc [hl]
    adc a
    adc [hl]
    cp $02
    adc a
    adc [hl]
    db $d3
    adc a
    adc [hl]
    adc a
    cp $02
    adc [hl]
    adc a
    db $d3
    adc [hl]
    adc a
    adc [hl]
    cp $02
    adc a
    adc [hl]
    db $d3
    adc a
    adc [hl]
    adc a
    cp $e2
    db $fd
    ld h, b
    cp $21
    inc [hl]
    call nz, $3d3a
    ld h, c
    ld h, c
    cp $12
    ld sp, $b535
    jr c, AudioDataRaw_003_5319

    ld a, $60
    ld h, b
    cp $12
    ld [hl-], a
    ld [hl], $b5
    add hl, sp
    inc a
    ccf
    ld h, c
    ld h, c
    cp $12
    ld sp, $e235
    db $fd
    ld h, b
    cp $12
    ld [hl-], a
    ld [hl], $e2
    db $fd
    ld h, c
    cp $12
    inc sp
    scf
    ldh [c], a
    db $fd
    ld h, b
    cp $e2
    db $fd
    ld h, c
    cp $e2
    db $fd
    ld h, b
    cp $e2
    db $fd
    ld h, c
    cp $e2
    db $fd
    ld h, b
    cp $e2
    db $fd
    ld h, c
    cp $d3
    ld a, [hl-]
    ld h, b
    ld h, b

AudioDataRaw_003_5319:
    cp $c4
    jr c, GfxData_TileSheet

    ld h, c
    ld h, c
    cp $c4
    add hl, sp
    inc a
    ld h, b
    ld h, b
    cp $41
    inc [hl]
    ldh [c], a
    db $fd
    ld h, c
    cp $32
    ld sp, $a635
    ld a, [hl-]
    dec a
    ld b, b
    ld b, e
    ld h, b
    ld h, b
    cp $32
    ld [hl-], a
    ld [hl], $97
    jr c, UnreachableCodeData_003_04

    ld a, $41
    ld b, h
    ld h, c
    ld h, c
    cp $32
    inc sp
    scf
    sub a
    add hl, sp
    inc a
    ccf
    ld b, d
    ld b, l
    ld h, b
    ld h, b
    cp $e2
    db $fd
    ld h, c
    cp $e2
    db $fd
    ld h, b
    cp $e2

GfxData_TileSheet:
    db $fd
    ld h, c
    cp $b5
    ld [hl], b
    ld [hl], d
    ld [hl], d
    ld h, b
    ld h, b
    cp $61
    add c
    or l
    ld [hl], c
    ld [hl], e
    ld [hl], e
    ld h, c
    ld h, c
    cp $e2
    db $fd
    ld h, b
    cp $e2
    db $fd
    ld h, c
    cp $fe
    ld hl, $fe34
    ld [de], a

UnreachableCodeData_003_04:
    ld sp, $fe35
    ld [de], a
    ld [hl-], a
    ld [hl], $e2
    db $fd
    ld h, c
    cp $12
    ld sp, $e235
    db $fd
    ld h, b
    cp $12
    ld [hl-], a
    ld [hl], $e2
    db $fd
    ld h, c
    cp $12
    inc sp
    scf
    ld [hl], c
    add c
    call nz, ProcessInputState_Bank3_Part1
    ld h, b
    ld h, b
    cp $71
    add c
    call nz, ProcessInputState_Bank3_Part2
    ld h, c
    ld h, c
    cp $e2
    db $fd
    ld h, b
    cp $e2
    db $fd
    ld h, c
    cp $a6
    ld a, [hl-]
    dec a
    ld b, b
    ld b, e
    ld h, b
    ld h, b
    cp $97
    jr c, @+$3d

    ld a, $41
    ld b, h
    ld h, c
    ld h, c
    cp $97
    add hl, sp
    inc a
    ccf
    ld b, d
    ld b, l
    ld h, b
    ld h, b
    cp $e2
    db $fd
    ld h, c
    cp $51
    add d
    sub c
    ld h, e
    ldh [c], a
    db $fd
    ld h, b
    cp $51
    add d
    sub c
    ld h, h
    ldh [c], a
    db $fd
    ld h, c
    cp $51
    add d
    sub c
    ld h, e
    ldh [c], a
    db $fd
    ld h, b
    cp $51
    add b
    sub c
    ld h, h
    ldh [c], a
    db $fd
    ld h, c
    cp $d3
    ld h, e
    ld h, b
    ld h, b
    cp $d1
    ld h, h
    cp $d1
    ld h, e
    cp $d1
    ld h, h
    cp $fe
    cp $fe
    cp $fe
    cp $11
    inc [hl]
    pop de
    ld h, e
    cp $02
    ld sp, $d335
    ld h, h
    ld h, c
    ld h, c
    cp $02
    ld [hl-], a
    ld [hl], $e2
    db $fd
    ld h, b
    cp $02
    inc sp
    scf
    ldh [c], a
    db $fd
    ld h, c
    cp $e2
    db $fd
    ld h, b
    cp $e2
    db $fd
    ld h, c
    cp $11
    add c
    ld d, c
    ld h, e
    ldh [c], a
    db $fd
    ld h, b
    cp $52
    ld h, h
    ld h, e
    ldh [c], a
    db $fd
    ld h, c
    cp $61
    ld h, h
    sub c
    ld h, e
    ldh [c], a
    db $fd
    ld h, b
    cp $91
    ld h, h
    ldh [c], a
    db $fd
    ld h, c
    cp $31
    ld e, a
    sub c
    ld h, e
    ldh [c], a
    db $fd
    ld h, b
    cp $91
    ld h, h
    ldh [c], a
    db $fd
    ld h, c
    cp $d3
    ld h, e
    ld h, b
    ld h, b
    cp $d3
    ld h, h
    ld h, c
    ld h, c
    cp $91
    ld h, e
    cp $91
    ld h, h
    cp $91
    ld h, e
    cp $91
    ld h, h
    cp $73
    db $fd
    ld h, e
    cp $11
    db $f4
    ld sp, $51f4
    db $f4
    ld [hl], e
    db $fd
    ld h, h
    call nz, $3d3a
    ld b, b
    ld b, e
    cp $b5
    jr c, ByteValueDispatchCase_31

    ld a, $41
    ld b, h
    cp $b5
    add hl, sp
    inc a
    ccf
    ld b, d
    ld b, l
    cp $42
    ld l, d
    ld l, e
    or l
    ld a, [hl-]
    dec a
    ld b, b
    ld b, e
    inc a
    cp $41
    ld h, e
    and [hl]
    jr c, @+$49

    dec a
    ld b, b
    ld b, e
    inc a
    cp $32
    ld h, e
    ld h, h
    and l
    ld b, [hl]
    dec sp
    ld a, $41
    ld b, h
    cp $31
    ld h, h
    and [hl]
    add hl, sp
    inc a
    ccf
    ld b, d
    ld b, l
    inc a
    cp $31
    ld h, h
    cp $fe
    cp $d3
    ld a, [hl-]
    dec a

ByteValueDispatchCase_31:
    ld b, b
    cp $c4
    jr c, @+$3d

    ld a, $41
    cp $21
    inc [hl]
    call nz, $3c39
    ccf
    ld b, d
    cp $12
    ld sp, $fe35
    ld [de], a
    ld [hl-], a
    ld [hl], $fe
    ld [de], a
    ld sp, $fe35
    ld [de], a
    ld [hl-], a
    ld [hl], $fe
    ld [de], a
    inc sp
    scf
    cp $fe
    cp $fe
    cp $fe
    call nz, $3d3a
    ld b, b
    ld b, e
    cp $b5
    jr c, UnreachableCodeData_003_05

    ld a, $41
    ld b, h
    cp $b5
    add hl, sp
    inc a
    ccf
    ld b, d
    ld b, l
    cp $fe
    call nz, ProcessInputState_Bank3_Part1
    ld h, e
    ld h, e
    cp $21
    inc [hl]
    call nz, ProcessInputState_Bank3_Part2
    ld h, h
    ld h, h
    cp $12
    ld sp, $fe35
    ld [de], a
    ld [hl-], a
    ld [hl], $fe
    ld [de], a
    inc sp
    scf
    and [hl]
    db $fd
    ld h, e
    cp $a6
    db $fd
    ld h, h
    cp $fe
    add c
    db $f4
    and c
    db $f4
    pop bc
    db $f4
    pop hl
    db $f4
    cp $fe
    adc b
    db $fd
    ld h, e

UnreachableCodeData_003_05:
    cp $88
    db $fd
    ld h, h
    cp $fe
    add c
    db $f4
    and c
    db $f4
    pop bc
    db $f4
    pop hl
    db $f4
    cp $fe
    ld l, d
    db $fd
    ld h, e
    cp $6a
    db $fd
    ld h, h
    cp $78
    db $fd
    db $f4
    cp $66
    ld l, d
    ld l, e
    ld l, d
    ld l, e
    ld l, d
    ld l, c
    pop af
    ld h, e
    cp $f1
    ld h, h
    cp $c4
    ld l, d
    ld l, e
    ld l, d
    ld l, e
    cp $52
    db $f4
    ld a, a
    ldh [c], a
    db $fd
    ld h, b
    cp $52
    db $f4
    ld a, a
    ldh [c], a
    db $fd
    ld h, c
    cp $52
    db $f4
    ld a, a
    ldh [c], a
    db $fd
    ld h, b
    cp $52
    db $f4
    ld a, a
    ldh [c], a
    db $fd
    ld h, c
    cp $52
    db $f4
    ld a, a
    ldh [c], a
    db $fd
    ld h, b
    cp $52
    db $f4
    ld a, a
    ldh [c], a
    db $fd
    ld h, c
    cp $e2
    db $fd
    ld h, b
    cp $a1
    add c
    ldh [c], a
    db $fd
    ld h, c
    cp $74
    ld [hl], b
    ld [hl], d
    ld [hl], d
    add c
    ldh [c], a
    db $fd
    ld h, b
    cp $11
    inc [hl]
    ld [hl], h
    ld [hl], c
    ld [hl], e
    ld [hl], e
    add c
    ldh [c], a
    db $fd
    ld h, c
    cp $02
    ld sp, $e235
    db $fd
    ld h, b
    cp $02
    ld [hl-], a
    ld [hl], $e2
    db $fd
    ld h, c
    cp $02
    inc sp
    scf
    ldh [c], a
    db $fd
    ld h, b
    cp $a6
    ld a, [hl-]
    dec a
    ld b, b
    ld b, e
    ld h, c
    ld h, c
    cp $97
    jr c, GfxData_SpriteFrames

    ld a, $41
    ld b, h
    ld h, b
    ld h, b
    cp $97
    add hl, sp
    inc a
    ccf
    ld b, d
    ld b, l
    ld h, c
    ld h, c
    cp $e2
    db $fd
    ld h, b
    cp $e2
    db $fd
    ld h, c
    cp $a6
    ld h, e
    ld h, e
    ld h, e
    ld h, e
    ld h, b
    ld h, b
    cp $a6
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld h, c
    ld h, c
    cp $fe
    cp $61
    ld a, a
    cp $21
    add c
    ld d, d
    db $f4
    ld a, a
    cp $21
    add c
    ld d, d
    db $f4
    ld a, a
    cp $21
    add c
    ld d, d

GfxData_SpriteFrames:
    db $f4
    ld a, a
    ldh [c], a
    db $fd
    ld h, c
    cp $e2
    db $fd
    ld h, b
    cp $e2
    db $fd
    ld h, c
    cp $e2
    db $fd
    ld h, b
    cp $fe
    or l
    db $fd
    ld h, e
    cp $21
    inc [hl]
    or l
    db $fd
    ld h, h
    cp $12
    ld sp, $8835
    ld h, e
    ld h, e
    ld l, d
    ld l, e
    ld h, e
    ld h, e
    ld l, d
    ld l, e
    cp $12
    ld [hl-], a
    ld [hl], $88
    ld h, h
    ld h, h
    ld h, e
    ld h, e
    ld h, h
    ld h, h
    ld h, e
    ld h, e
    cp $12
    inc sp
    scf
    adc b
    ld l, d
    ld l, e
    ld h, h
    ld h, h
    ld l, d
    ld l, e
    ld h, h
    ld h, h
    cp $e2
    db $ed
    ld h, c
    cp $e2
    db $ed
    ld h, b
    cp $e2
    db $ed
    ld h, c
    cp $e2
    db $ed
    ld h, b
    cp $e2
    db $ed
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
    ld hl, $8e48
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
    ld hl, $8f48
    cp $00
    db $fd
    ld a, a
    cp $29
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    add b
    pop af
    ld a, a
    cp $29
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    add d
    pop af
    ld a, a
    cp $0b
    ld a, a
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    add d
    db $f4
    db $f4
    db $f4
    add d
    pop af
    ld a, a
    cp $0b
    ld a, a
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    add d
    db $f4
    db $f4
    db $f4
    add d
    pop af
    ld a, a
    cp $0b
    ld a, a
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    add d
    db $f4
    db $f4
    db $f4
    add d
    pop af
    ld a, a
    cp $0b
    ld a, a
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    add d
    db $f4
    db $f4
    db $f4
    add d
    pop af
    ld a, a
    cp $0b
    ld a, a
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    add d
    db $f4
    db $f4
    db $f4
    db $f4
    pop af
    ld a, a
    cp $0b
    ld a, a
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    add d
    pop af
    ld a, a
    cp $0b
    ld a, a
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    add d
    db $f4
    db $f4
    db $f4
    add d
    pop af
    ld a, a
    cp $0b
    ld a, a
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    add d
    db $f4
    db $f4
    db $f4
    add d
    pop af
    ld a, a
    cp $0b
    ld a, a
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    add d
    db $f4
    db $f4
    db $f4
    add d
    pop af
    ld a, a
    cp $0b
    ld a, a
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    add d
    db $f4
    db $f4
    db $f4
    add d
    pop af
    ld a, a
    cp $0b
    ld a, a
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    add d
    db $f4
    db $f4
    db $f4
    add d
    pop af
    ld a, a
    cp $0b
    ld a, a
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    add d
    db $f4
    db $f4
    db $f4
    add d
    pop af
    ld a, a
    cp $0b
    ld a, a
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    add d
    db $f4
    db $f4
    db $f4
    add d
    pop af
    ld a, a
    cp $0b
    ld a, a
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    add d
    db $f4
    db $f4
    db $f4
    add d
    pop af
    ld a, a
    cp $0b
    ld a, a
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    add d
    db $f4
    db $f4
    db $f4
    add d
    db $d3
    ld [hl], h
    ld [hl], a
    ld a, a
    cp $0b
    ld a, a
    ld a, a
    db $f4
    db $f4
    db $f4
    db $f4
    add d
    db $f4
    db $f4
    db $f4
    add c
    db $d3
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
    cp $05
    ld h, h
    ld h, e
    ld l, d
    ld l, e
    ld l, c
    ldh [c], a
    ld h, l
    ld h, a
    cp $06
    ld h, e
    ld h, h
    ld h, e
    ld l, d
    ld l, e
    ld l, c
    ldh [c], a
    ld h, [hl]
    ld l, b
    cp $1f
    db $fd
    ld e, l
    cp $1f
    db $fd
    ld e, l
    cp $03
    ld l, d
    ld l, e
    ld l, c
    ldh [c], a
    ld h, l
    ld h, a
    cp $06
    ld h, e
    ld l, d
    ld l, e
    ld l, d
    ld l, e
    ld l, c
    ldh [c], a
    ld h, [hl]
    ld l, b
    cp $03
    ld h, h
    ld l, d
    ld l, e
    ldh [c], a
    ld h, l
    ld h, a
    cp $02
    ld h, e
    ld l, c
    call nz, ProcessInputState_Bank3_Part1
    ld h, [hl]
    ld l, b
    cp $02
    ld h, h
    ld l, c
    call nz, ProcessInputState_Bank3_Part2
    ld h, l
    ld h, a
    cp $05
    ld h, e
    ld h, h
    ld h, e
    ld l, d
    ld l, e
    ldh [c], a
    ld h, [hl]
    ld l, b
    cp $06
    ld h, h
    ld h, e
    ld h, h
    ld l, d
    ld l, e
    ld l, c
    ldh [c], a
    ld h, l
    ld h, a
    cp $05
    ld h, e
    ld h, h
    ld l, d
    ld l, e
    ld l, c
    ldh [c], a
    ld h, [hl]
    ld l, b
    cp $05
    ld h, h
    ld h, e
    ld l, d
    ld l, e
    ld l, c
    ldh [c], a
    ld h, l
    ld h, a
    cp $05
    ld h, e
    ld h, h
    ld l, d
    ld l, e
    ld l, c
    ldh [c], a
    ld h, [hl]
    ld l, b
    cp $05
    ld h, h
    ld l, d
    ld l, e
    ld l, d
    ld l, e
    ldh [c], a
    ld h, l
    ld h, a
    cp $07
    ld h, e
    ld h, e
    ld h, e
    ld h, e
    ld l, d
    ld l, e
    ld l, c
    ldh [c], a
    ld h, [hl]
    ld l, b
    cp $05
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld l, c
    ldh [c], a
    ld h, l
    ld h, a
    cp $05
    ld h, e
    ld h, e
    ld h, e
    ld h, e
    ld l, c
    ldh [c], a
    ld h, [hl]
    ld l, b
    cp $04
    db $fd
    ld h, h
    or l
    ld [hl], b
    ld [hl], d
    ld [hl], d
    ld h, l
    ld h, a
    cp $06
    ld h, e
    ld l, d
    ld l, e
    ld l, d
    ld l, e
    ld l, c
    or l
    ld [hl], c
    ld [hl], e
    ld [hl], e
    ld h, [hl]
    ld l, b
    cp $04
    ld h, e
    ld l, d
    ld l, e
    ld l, c
    ldh [c], a
    ld h, l
    ld h, a
    cp $03
    ld h, h
    ld h, e
    ld l, c
    ldh [c], a
    ld h, [hl]
    ld l, b
    cp $03
    ld h, e
    ld h, h
    ld l, c
    ldh [c], a
    ld h, l
    ld h, a
    cp $03
    ld h, h
    ld l, d
    ld l, e
    or l
    ld [hl], b
    ld [hl], d
    ld [hl], d
    ld h, [hl]
    ld l, b
    cp $04
    ld h, e
    ld l, d
    ld l, e
    ld l, c
    or l
    ld [hl], c
    ld [hl], e
    ld [hl], e
    ld h, l
    ld h, a
    cp $02
    ld h, h
    ld l, c
    ldh [c], a
    ld h, [hl]
    ld l, b
    cp $02
    ld l, d
    ld l, e
    ldh [c], a
    ld h, l
    ld h, a
    cp $03
    ld l, d
    ld l, e
    ld l, c
    ldh [c], a
    ld h, [hl]
    ld l, b
    cp $05
    ld h, e
    ld l, d
    ld l, e
    ld l, d
    ld l, e
    pop af
    ld h, l
    cp $02
    ld h, h
    ld h, e
    pop af
    ld h, [hl]
    cp $03
    ld h, e
    ld h, h
    ld l, c
    pop af
    ld h, l
    cp $02
    ld h, h
    ld l, c
    pop af
    ld h, [hl]
    cp $71
    add c
    or c
    add c
    pop af
    ld h, l
    cp $71
    add d
    or c
    add d
    pop af
    ld h, [hl]
    cp $71
    add c
    or c
    add c
    pop af
    ld h, l
    cp $31
    ld e, a
    pop af
    ld h, [hl]
    cp $03
    ld l, d
    ld l, e
    ld l, c
    db $d3
    ld h, l
    ld h, a
    ld h, l
    cp $02
    ld h, h
    ld l, c
    db $d3
    ld h, [hl]
    ld l, b
    ld h, [hl]
    cp $03
    ld h, e
    ld l, d
    ld l, e
    ldh [c], a
    ld h, l
    ld h, a
    cp $02
    ld h, h
    ld l, c
    ldh [c], a
    ld h, [hl]
    ld l, b
    cp $02
    db $f4
    ld h, e
    ldh [c], a
    ld h, l
    ld h, a
    cp $12
    ld h, h
    ld l, c
    ldh [c], a
    ld h, [hl]
    ld l, b
    cp $00
    db $f4
    ld h, e
    ld l, c
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    cp $1f
    ld h, h
    ld l, c
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    cp $00
    db $f4
    ld h, e
    ld l, c
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld h, l
    ld h, a
    ld e, l
    ld e, l
    ld e, l
    cp $1f
    ld h, h
    ld l, c
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld h, [hl]
    ld l, b
    ld e, l
    ld e, l
    ld e, l
    cp $00
    db $f4
    ld l, d
    ld l, c
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    cp $1f
    ld [hl], b
    ld [hl], d
    ld h, e
    ld l, c
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    cp $1f
    ld [hl], c
    ld [hl], e
    ld h, h
    ld l, c
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    cp $e2
    ld h, [hl]
    ld l, b
    cp $61
    db $f4
    and c
    add d
    ldh [c], a
    ld h, l
    ld h, a
    cp $a1
    add c
    ldh [c], a
    ld h, [hl]
    ld l, b
    cp $61
    db $f4
    sub d
    ld e, a
    add d
    ldh [c], a
    ld h, l
    ld h, a
    cp $a1
    add c
    ldh [c], a
    ld h, [hl]
    ld l, b
    cp $61
    db $f4
    and c
    add d
    ldh [c], a
    ld h, l
    ld h, a
    cp $e2
    ld h, [hl]
    ld l, b
    cp $fe
    cp $fe
    dec b
    ld l, d
    ld l, e
    ld l, d
    ld l, e
    ld l, c
    db $d3
    ld l, d
    ld l, e
    ld l, d
    cp $13
    ld l, d
    ld l, e
    ld l, c
    ldh [c], a
    ld h, l
    ld h, a
    cp $e2
    ld h, [hl]
    ld l, b
    cp $fe
    cp $e2
    ld h, l
    ld h, a
    cp $e2
    ld h, [hl]
    ld l, b
    cp $e2
    ld h, l
    ld h, a
    cp $e2
    ld h, [hl]
    ld l, b
    cp $fe
    cp $12
    ld h, e
    ld l, c
    sub c
    db $f4
    or c
    ld h, e
    cp $02
    ld h, e
    ld h, h
    sub c
    db $f4
    or c
    ld h, h
    cp $03
    ld h, h
    ld l, d
    ld l, c
    sub c
    db $f4
    or c
    ld h, e
    cp $03
    ld h, e
    ld h, e
    ld l, c
    sub c
    db $f4
    or c
    ld h, h
    cp $03
    ld h, h
    ld h, h
    ld l, c
    cp $1f
    db $fd
    ld e, l
    cp $1f
    db $fd
    ld e, l
    cp $1f
    db $fd
    ld e, l
    cp $03
    ld h, e
    ld h, e
    ld l, c
    or c
    ld h, e
    cp $04
    ld h, h
    ld h, h
    ld l, d
    ld l, c
    ld [hl], c
    add c
    or c
    ld h, h
    cp $1f
    db $fd
    ld e, l
    cp $1f
    db $fd
    ld e, l
    cp $03
    ld l, d
    ld l, e
    ld l, c
    or d
    ld h, e
    ld l, c
    cp $b2
    ld h, h
    ld l, c
    cp $b2
    ld h, e
    ld l, c
    cp $b3
    ld h, h
    ld l, d
    ld l, c
    cp $b2
    ld l, d
    ld l, c
    cp $b4
    ld l, d
    ld l, e
    ld l, d
    ld l, c
    cp $b3
    ld l, d
    ld l, e
    ld l, c
    cp $b2
    ld h, e
    ld l, c
    cp $b2
    ld h, h
    ld l, c
    cp $b3
    ld l, d
    ld l, e
    ld l, c
    cp $13
    ld l, d
    ld l, e
    ld l, c
    cp $03
    ld h, e
    ld h, e
    ld l, c
    cp $03
    ld h, h
    ld h, h
    ld l, c
    and d
    ld l, d
    ld l, c
    cp $03
    ld l, d
    ld l, e
    ld l, c
    and e
    ld l, d
    ld l, e
    ld l, c
    cp $03
    ld l, d
    ld l, e
    ld l, c
    cp $03
    ld h, e
    ld l, d
    ld l, e
    cp $02
    ld h, h
    ld l, c
    and e
    ld l, d
    ld l, e
    ld l, c
    cp $03
    ld l, d
    ld l, e
    ld l, c
    and l
    ld l, d
    ld l, e
    ld l, d
    ld l, e
    ld l, c
    cp $1f
    db $fd
    ld e, l
    cp $1f
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld l, d
    ld l, e
    ld l, d
    ld l, e
    ld l, d
    ld l, c
    ld e, l
    ld e, l
    cp $1f
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld l, d
    ld l, e
    ld l, d
    ld l, e
    ld l, d
    ld l, c
    ld e, l
    ld e, l
    cp $1f
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    db $ed
    ld l, d
    ld l, c
    ld e, l
    ld e, l
    cp $1f
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    db $ed
    ld l, d
    ld l, c
    ld e, l
    ld e, l
    cp $1f
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    db $ed
    ld l, d
    ld l, c
    ld e, l
    ld e, l
    cp $1f
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    db $ed
    ld l, d
    ld l, c
    ld e, l
    ld e, l
    cp $1f
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    db $ed
    ld l, d
    ld l, c
    ld e, l
    ld e, l
    cp $1f
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    db $ed
    ld l, d
    ld l, c
    ld e, l
    ld e, l
    cp $1f
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    db $ed
    ld l, d
    ld l, c
    ld e, l
    ld e, l
    cp $1f
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    db $ed
    ld l, d
    ld l, c
    ld e, l
    ld e, l
    cp $1f
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    db $ed
    ld l, d
    ld l, c
    ld e, l
    ld e, l
    cp $1f
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    db $ed
    ld l, d
    ld l, c
    ld e, l
    ld e, l
    cp $1f
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    db $ed
    ld l, d
    ld l, c
    ld e, l
    ld e, l
    cp $1f
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    db $ed
    ld l, d
    ld l, c
    ld e, l
    ld e, l
    cp $1f
    db $fd
    ld e, l
    cp $1f
    db $fd
    ld e, l
    cp $1f
    db $fd
    ld e, l
    cp $1f
    db $fd
    ld e, l
    cp $1f
    db $fd
    ld e, l
    cp $03
    ld h, h
    ld h, e
    ld l, c
    ldh [c], a
    ld h, l
    ld h, a
    cp $04
    ld h, e
    ld h, h
    ld l, d
    ld l, c
    ldh [c], a
    ld h, [hl]
    ld l, b
    cp $03
    ld h, h
    ld h, e
    ld l, c
    cp $03
    ld h, e
    ld h, h
    ld l, c
    cp $02
    ld h, h
    ld h, e
    cp $03
    ld h, e
    ld h, h
    ld l, c
    cp $05
    ld h, h
    ld h, e
    ld l, d
    ld l, e
    ld l, c
    cp $04
    ld h, e
    ld h, h
    ld l, d
    ld l, c
    cp $03
    ld h, h
    ld h, e
    ld l, c
    cp $03
    ld h, e
    ld h, h
    ld l, c
    cp $03
    ld h, h
    ld h, e
    ld l, c
    jp nz, DispatchAudioWaveCommand

    cp $05
    ld h, e
    ld h, h
    ld h, e
    ld l, d
    ld l, c
    pop bc
    ld h, h
    cp $05
    ld h, h
    ld h, e
    ld h, h
    ld l, d
    ld l, e
    jp nz, DispatchAudioWaveCommand

    cp $04
    ld h, e
    ld h, h
    ld l, d
    ld l, c
    jp nz, $6964

    cp $03
    ld h, h
    ld h, e
    ld l, c
    cp $03
    ld h, e
    ld h, h
    ld l, c
    cp $02
    ld h, h
    ld h, e
    cp $02
    ld h, e
    ld h, h
    ld [hl], e
    ld l, d
    ld l, e
    ld l, c
    cp $02
    ld h, h
    ld l, c
    halt
    ld h, e
    ld l, d
    ld l, e
    ld l, d
    ld l, e
    ld l, c
    cp $02
    ld l, d
    ld l, c
    ld [hl], h
    ld h, h
    ld l, d
    ld l, e
    ld l, c
    cp $1f
    db $fd
    ld e, l
    cp $1f
    db $fd
    ld e, l
    cp $1f
    db $fd
    ld e, l
    cp $1f
    db $fd
    ld e, l
    cp $1f
    db $fd
    ld e, l
    cp $1f
    db $fd
    ld e, l
    cp $1f
    db $fd
    ld e, l
    cp $1f
    db $fd
    ld e, l
    cp $1f
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld l, d
    ld l, e
    ld l, c
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    cp $1f
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld h, e
    ld l, d
    ld l, e
    ld l, c
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    cp $1f
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld h, h
    ld l, d
    ld l, c
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    cp $1f
    db $fd
    ld e, l
    cp $1f
    db $fd
    ld e, l
    cp $1f
    db $fd
    ld e, l
    cp $1f
    db $fd
    ld e, l
    cp $1f
    db $fd
    ld e, l
    cp $1f
    db $fd
    ld e, l
    cp $1f
    db $fd
    ld e, l
    cp $1f
    db $fd
    ld e, l
    cp $1f
    db $fd
    ld e, l
    cp $00
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
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    and c
    ld a, a
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    and c
    ld a, a
    ldh [c], a
    db $fd
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
    and c
    ld a, a
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    and c
    add b
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    ld [hl], c
    add b
    and d
    db $fd
    ld a, a
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    sub e
    db $fd
    ld a, a
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    and d
    db $ed
    ld a, a
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    ld [hl], c
    ld a, a
    and d
    db $ed
    ld a, a
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    and d
    db $ed
    ld a, a
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    ld b, c
    ld a, a
    sub e
    db $fd
    ld a, a
    ldh [c], a
    db $fd
    ld a, a
    cp $01
    ld a, a
    ld b, c
    ld a, a
    ld h, [hl]
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    add d
    ldh [c], a
    db $fd
    ld a, a
    cp $05
    ld a, a
    ld a, a
    ld [hl], h
    ld [hl], a
    ld a, a
    ld h, [hl]
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    add d
    ldh [c], a
    db $fd
    ld a, a
    cp $05
    ld a, a
    ld a, a
    ld [hl], l
    ld a, b
    ld a, a
    ld h, [hl]
    db $f4
    db $f4
    db $f4
    db $f4
    db $f4
    add d
    ldh [c], a
    db $fd
    ld a, a
    cp $00
    ld [hl], d
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
    cp $fe
    ld hl, $a15a
    ld e, a
    pop hl
    ld l, h
    cp $2e
    ld e, e
    ld c, c
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld l, l
    ld l, h
    cp $21
    ld e, h
    ld [hl], c
    ld e, d
    ldh [c], a
    ld l, h
    ld l, l
    cp $79
    ld e, e
    ld c, c
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld l, l
    ld l, h
    cp $71
    ld e, h
    ldh [c], a
    ld l, h
    ld l, l
    cp $21
    inc [hl]
    pop hl
    ld l, l
    cp $12
    ld sp, $fe35
    ld [de], a
    ld [hl-], a
    ld [hl], $fe
    ld [de], a
    ld sp, $8135
    db $f4
    call nz, ProcessInputState_Bank3_Part1
    ld [hl], d
    ld l, h
    cp $12
    ld [hl-], a
    ld [hl], $81
    db $f4
    call nz, ProcessInputState_Bank3_Part2
    ld [hl], e
    ld l, l
    cp $12
    inc sp
    scf
    cp $fe
    cp $c4
    db $fd
    ld l, [hl]
    cp $c4
    db $fd
    ld l, [hl]
    cp $fe
    cp $c4
    db $fd
    ld l, [hl]
    cp $81
    db $f4
    call nz, CalculateAudioNoteFrequency
    cp $fe
    ld b, c
    ld e, d
    ld h, c
    ld e, d
    cp $4c
    ld e, e
    ld c, c
    ld e, e
    ld c, c
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    cp $41
    ld e, h
    ld h, c
    ld e, h
    cp $21
    inc [hl]
    sub c
    db $f4
    cp $12
    ld sp, $fe35
    ld [de], a
    ld [hl-], a
    ld [hl], $91
    db $f4
    cp $12
    inc sp
    scf
    ld h, c
    inc [hl]
    cp $52
    ld sp, $9135
    db $f4
    cp $52
    ld [hl-], a
    ld [hl], $fe
    ld d, d
    ld sp, $9135
    db $f4
    cp $52
    ld [hl-], a
    ld [hl], $fe
    ld d, d
    inc sp
    scf
    cp $11
    inc [hl]
    cp $02
    ld sp, $fe35
    ld [bc], a
    ld [hl-], a
    ld [hl], $b1
    ld e, d
    cp $02
    ld sp, $b535
    ld e, e
    ld c, c
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    cp $02
    ld [hl-], a
    ld [hl], $b1
    ld e, h
    cp $02
    inc sp
    scf
    cp $fe
    call nz, $6cfd
    cp $34
    ld [hl], b
    ld [hl], d
    ld [hl], d
    ld l, h
    call nz, $6dfd
    cp $34
    ld [hl], c
    ld [hl], e
    ld [hl], e
    ld l, l
    call nz, $6cfd
    cp $c4
    db $fd
    ld l, l
    cp $fe
    ld de, $e234
    ld l, [hl]
    ld l, h
    cp $02
    ld sp, $a635
    ld l, h
    ld l, h
    ld l, h
    ld l, h
    ld l, h
    ld l, l
    cp $02
    ld [hl-], a
    ld [hl], $a6
    ld l, l
    ld l, l
    ld l, l
    ld l, l
    ld l, l
    ld l, h
    cp $02
    inc sp
    scf
    and [hl]
    ld l, h
    ld l, h
    ld l, h
    ld l, h
    ld l, h
    ld l, l
    cp $a5
    db $fd
    ld l, l
    cp $fe
    ld h, c
    ld e, a
    and [hl]
    db $fd
    ld l, [hl]
    cp $fe
    and [hl]
    db $fd
    ld l, [hl]
    cp $31
    inc [hl]
    cp $22
    ld sp, $a635
    db $fd
    ld l, [hl]
    cp $22
    ld [hl-], a
    ld [hl], $a6
    db $fd
    ld l, [hl]
    cp $22
    inc sp
    scf
    cp $fe
    cp $d3
    db $fd
    ld l, h
    cp $d3
    db $fd
    ld l, l
    cp $f1
    ld l, h
    cp $11
    add d
    ld sp, $615a
    ld l, h
    pop af
    ld l, l
    cp $11
    add d
    dec a
    ld e, e
    ld c, c
    ld e, [hl]
    ld l, l
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld l, h
    cp $11
    add d
    ld [hl-], a
    ld e, h
    db $f4
    ld h, c
    ld l, h
    pop af
    ld l, l
    cp $11
    add d
    ld b, c
    db $f4
    ld h, c
    ld l, l
    and c
    add c
    pop af
    ld l, h
    cp $11
    add d
    ld b, c
    db $f4
    ld h, c
    ld l, h
    and c
    add c
    pop af
    ld l, l
    cp $11
    add d
    ld b, c
    db $f4
    ld h, c
    ld l, l
    and c
    add c
    pop af
    ld l, h
    cp $11
    add b
    ld b, c
    db $f4
    ld h, c
    ld l, h
    and c
    add c
    pop af
    ld l, l
    cp $11
    add d
    ld b, c
    db $f4
    ld h, c
    ld l, l
    or l
    ld e, e
    ld c, c
    ld e, [hl]
    ld e, [hl]
    ld l, h
    cp $11
    add d
    ld b, c
    db $f4
    ld h, c
    ld l, h
    pop af
    ld l, l
    cp $11
    add d
    ld h, c
    ld l, l
    pop af
    ld l, h
    cp $f1
    ld l, l
    cp $97
    ld e, e
    ld e, b
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld l, h
    cp $11
    inc [hl]
    pop af
    ld l, l
    cp $02
    ld sp, $d335
    db $fd
    ld l, h
    cp $02
    ld [hl-], a
    ld [hl], $d3
    db $fd
    ld l, l
    cp $02
    inc sp
    scf
    cp $fe
    ldh [c], a
    db $fd
    ld l, h
    cp $11
    inc [hl]
    ldh [c], a
    db $fd
    ld l, l
    cp $02
    ld sp, $c435
    ld [hl], b
    ld [hl], d
    ld l, h
    ld l, [hl]
    cp $02
    ld [hl-], a
    ld [hl], $c4
    ld [hl], c
    ld [hl], e
    ld l, l
    ld l, h
    cp $02
    ld sp, $9135
    ld e, a
    ldh [c], a
    ld l, h
    ld l, l
    cp $02
    ld [hl-], a
    ld [hl], $e2
    ld l, l
    ld l, [hl]
    cp $02
    inc sp
    scf
    ld [hl], d
    ld l, h
    ld e, d
    cp $79
    ld l, l
    ld e, e
    ld c, c
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    cp $72
    ld l, h
    ld e, h
    cp $71
    ld l, l
    cp $fe
    cp $71
    ld l, h
    cp $71
    ld l, l
    cp $71
    ld l, h
    cp $21
    ld e, d
    ld [hl], c
    ld l, l
    and c
    ld e, d
    cp $2e
    ld e, e
    ld e, b
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld d, a
    ld e, b
    ld e, [hl]
    ld e, e
    ld c, c
    ld e, [hl]
    cp $21
    ld e, h
    and c
    ld e, h
    cp $d1
    ld l, h
    cp $d1
    ld l, l
    cp $a4
    db $fd
    ld l, h
    cp $21
    db $f4
    ld b, c
    db $f4
    ld h, c
    db $f4
    add c
    db $f4
    and h
    db $fd
    ld l, l
    cp $fe
    cp $0c
    ld l, h
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
    ld l, [hl]
    cp $01
    ld l, l
    and c
    ld l, l
    cp $01
    ld l, h
    ld h, c
    ld l, h
    cp $01
    ld l, l
    ld h, c
    ld l, l
    cp $01
    ld l, h
    ld l, b
    db $fd
    ld l, [hl]
    cp $01
    ld l, l
    cp $08
    ld l, h
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    cp $01
    ld l, l
    ld [hl], c
    ld l, h
    cp $01
    ld l, h
    ld [hl], c
    ld l, l
    cp $01
    ld l, l
    ld sp, $b46c
    db $fd
    ld l, h
    cp $01
    ld l, h
    inc a
    ld l, l
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, l
    ld l, l
    ld l, l
    ld l, l
    cp $01
    ld l, l
    pop hl
    ld l, h
    cp $01
    ld l, h
    pop hl
    ld l, l
    cp $08
    ld l, l
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    pop hl
    ld l, h
    cp $e1
    ld l, l
    cp $e1
    ld l, [hl]
    cp $03
    ld l, h
    ld d, l
    ld d, [hl]
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld l, l
    ld d, l
    ld e, d
    ld h, c
    ld e, d
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $00
    ld l, h
    ld d, l
    ld e, e
    ld c, c
    ld e, [hl]
    ld e, [hl]
    ld d, a
    ld e, b
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld e, [hl]
    ld l, h
    ld l, [hl]
    cp $03
    ld l, l
    ld d, l
    ld e, h
    ld h, c
    ld e, h
    ldh [c], a
    ld l, l
    ld l, h
    cp $03
    ld l, h
    ld d, l
    ld d, [hl]
    ldh [c], a
    ld l, h
    ld l, l
    cp $03
    ld l, l
    ld d, l
    ld d, [hl]
    ld d, c
    ld d, b
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $00
    ld l, h
    ld d, l
    ld d, [hl]
    ld c, h
    ld c, [hl]
    ld d, c
    ld e, c
    ld e, c
    ld e, c
    ld e, c
    ld e, c
    ld e, c
    ld e, c
    ld d, e
    ld l, h
    ld l, [hl]
    cp $06
    ld l, l
    ld d, l
    ld d, [hl]
    ld c, l
    ld c, a
    ld d, d
    db $d3
    ld d, h
    ld l, l
    ld l, h
    cp $03
    ld l, h
    ld d, l
    ld d, [hl]
    ldh [c], a
    ld l, h
    ld l, l
    cp $03
    ld l, l
    ld d, l
    ld d, [hl]
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld l, h
    ld d, l
    ld d, [hl]
    ld d, c
    ld d, b
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $00
    ld l, l
    ld d, l
    ld d, [hl]
    ld c, h
    ld c, [hl]
    ld d, c
    ld e, c
    ld e, c
    ld e, c
    ld e, c
    ld e, c
    ld e, c
    ld e, c
    ld d, e
    ld l, l
    ld l, h
    cp $06
    ld l, h
    ld d, l
    ld d, [hl]
    ld c, l
    ld c, a
    ld d, d
    db $d3
    ld d, h
    ld l, h
    ld l, l
    cp $03
    ld l, l
    ld d, l
    ld d, [hl]
    ldh [c], a
    ld l, l
    ld l, [hl]
    cp $03
    ld l, h
    ld d, l
    ld d, [hl]
    and [hl]
    ld l, h
    ld l, [hl]
    ld l, h
    ld l, [hl]
    ld l, h
    ld l, [hl]
    cp $03
    ld l, l
    ld d, l
    ld d, [hl]
    and [hl]
    ld l, l
    ld l, h
    ld l, l
    ld l, h
    ld l, l
    ld l, h
    cp $00
    ld l, h
    ld d, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld l, h
    ld l, l
    ld l, h
    ld l, l
    ld l, h
    ld l, l
    cp $00
    ld l, l
    ld d, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld l, l
    ld l, [hl]
    ld l, l
    ld l, [hl]
    ld l, l
    ld l, [hl]
    cp $00
    ld l, h
    ld d, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld e, l
    ld l, h
    ld l, h
    ld l, h
    ld l, h
    ld l, h
    ld l, h
    cp $03
    ld l, l
    ld d, l
    ld d, [hl]
    and [hl]
    db $fd
    ld l, l
    cp $03
    ld l, h
    ld d, l
    ld d, [hl]
    db $d3
    ld l, [hl]
    ld l, h
    ld l, [hl]
    cp $08
    ld l, l
    ld d, l
    ld d, [hl]
    ld a, [hl-]
    dec a
    ld b, b
    ld b, e
    ld d, b
    ldh [c], a
    ld l, l
    ld l, h
    cp $00
    ld l, h
    ld d, l
    jr c, DispatchDataZone_6198

    ld a, $41
    ld b, h
    ld d, c
    ld e, c
    ld e, c
    ld e, c
    ld e, c
    ld e, c
    ld d, e
    ld l, h
    ld l, l
    cp $08
    ld l, l
    ld d, l
    add hl, sp
    inc a
    ccf
    ld b, d
    ld b, l
    ld d, d
    and c
    add c
    db $d3
    ld d, h
    ld l, l
    ld l, [hl]
    cp $03
    ld l, h
    ld d, l
    ld d, [hl]
    and c
    add c
    ldh [c], a
    db $fd
    ld l, h
    cp $03
    ld l, l
    ld d, l
    ld d, [hl]
    and c
    add c
    ldh [c], a
    db $fd
    ld l, l
    cp $03
    ld l, h
    ld d, l
    ld d, [hl]
    ldh [c], a
    ld l, h
    ld l, [hl]
    cp $03
    ld l, l

DispatchDataZone_6198:
    ld d, l
    ld d, [hl]
    ldh [c], a
    ld l, l
    ld l, h
    cp $03
    ld l, h
    ld d, l
    ld d, [hl]
    ld [hl], c
    ld d, b
    ldh [c], a
    ld l, h
    ld l, l
    cp $03
    ld l, l
    ld d, l
    ld d, [hl]
    ld e, e
    ld c, h
    ld c, [hl]
    ld d, c
    ld e, c
    ld e, c
    ld e, c
    ld e, c
    ld e, c
    ld d, e
    ld l, l
    ld l, [hl]
    cp $03
    ld l, h
    ld d, l
    ld d, [hl]
    ld d, e
    ld c, l
    ld c, a
    ld d, d
    db $d3
    ld d, h
    ld l, h
    ld l, h
    cp $03
    ld l, l
    ld d, l
    ld d, [hl]
    db $d3
    ld l, h
    ld l, l
    ld l, l
    cp $03
    ld l, h
    ld d, l
    ld d, [hl]
    jp nz, UpdateAudioChannelStatus

    cp $03
    ld l, l
    ld d, l
    ld d, [hl]
    or d
    ld l, h
    ld l, l
    cp $03
    ld l, h
    ld d, l
    ld d, [hl]
    and d
    ld l, h
    ld l, l
    cp $03
    ld l, l
    ld d, l
    ld d, [hl]
    sub d
    ld l, h
    ld l, l
    cp $03
    ld l, h
    ld d, l
    ld d, [hl]
    sub c
    ld l, l
    cp $03
    ld l, l
    ld d, l
    ld d, [hl]
    cp $03
    ld l, h
    ld d, l
    ld d, [hl]
    cp $03
    ld l, l
    ld d, l
    ld d, [hl]
    cp $1f
    db $fd
    ld e, l
    cp $1f
    db $fd
    ld e, l
    cp $02
    ld l, h
    ld l, [hl]
    db $d3
    db $fd
    ld l, h
    cp $02
    ld l, l
    ld l, h
    db $d3
    db $fd
    ld l, l
    cp $02
    ld l, h
    ld l, l
    ld d, c
    ld d, b
    db $d3
    ld l, [hl]
    ld l, h
    ld l, h
    cp $02
    ld l, l
    ld l, h
    dec a
    ld c, h
    ld c, [hl]
    ld d, c
    ld e, c
    ld e, c
    ld e, c
    ld e, c
    ld e, c
    ld e, c
    ld e, c
    ld d, e
    ld l, l
    ld l, l
    cp $02
    ld l, h
    ld l, l
    inc sp
    ld c, l
    ld c, a
    ld d, d
    db $d3
    ld d, h
    ld l, h
    ld l, h
    cp $01
    ld l, l
    ldh [c], a
    db $fd
    ld l, l
    cp $01
    ld l, [hl]
    ldh [c], a
    db $fd
    ld l, [hl]
    cp $1f
    db $fd
    ld e, l
    cp $1f
    db $fd
    ld e, l
    cp $1f
    db $fd
    ld e, l
    cp $01
    ld l, h
    db $d3
    db $fd
    ld l, h
    cp $01
    ld l, l
    ld b, c
    ld d, b
    db $d3
    db $fd
    ld l, l
    cp $01
    ld l, h
    ld h, $4c
    ld c, [hl]
    ld d, c
    ld e, c
    ld d, e
    ld l, h
    db $d3
    db $fd
    ld l, h
    cp $01
    ld l, l
    inc hl
    ld c, l
    ld c, a
    ld d, d
    ld h, l
    ld d, h
    ld l, l
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    db $d3
    db $fd
    ld l, l
    cp $01
    ld l, h
    db $d3
    db $fd
    ld l, h
    cp $06
    ld l, l
    ld l, h
    ld l, [hl]
    ld l, h
    ld l, [hl]
    ld l, h
    sub a
    pop hl
    ld l, [hl]
    ld l, [hl]
    ld l, [hl]
    ld l, l
    ld l, l
    ld l, l
    cp $00
    ld l, h
    ld l, l
    ld l, h
    ld l, l
    ld l, h
    ld l, l
    db $ec
    db $ec
    db $ec
    db $ec
    ld l, h
    ld l, h
    ld l, h
    ld l, h
    ld l, h
    ld l, h
    cp $06
    ld l, l
    ld l, [hl]
    ld l, l
    ld l, [hl]
    ld l, l
    ld l, [hl]
    and [hl]
    db $fd
    ld l, l
    cp $a6
    ld h, e
    ld h, e
    ld h, e
    ld h, e
    ld h, b
    ld h, b
    cp $a6

DataPadding_62c2:
    ld h, h
    ld h, h
    ld h, h
    ld h, h
    ld h, c
    ld h, c
    cp $e2
    db $ed
    ld h, b
    cp $e2
    db $ed
    ld h, c
    cp $e2
    db $ed
    ld h, b
    cp $21
    inc [hl]
    ldh [c], a
    db $ed
    ld h, c
    cp $12
    ld sp, $e235
    db $ed
    ld h, b
    cp $12
    ld [hl-], a
    ld [hl], $e2
    db $ed
    ld h, c
    cp $12
    ld sp, $e235
    db $ed
    ld h, b
    cp $12
    ld [hl-], a
    ld [hl], $b5
    ld a, [hl-]
    dec a
    ld b, b
    db $ed
    ld h, c
    cp $12
    inc sp
    scf
    and [hl]
    jr c, @+$3d

    ld a, $41
    db $ed
    ld h, b
    cp $a6
    add hl, sp
    inc a
    ccf
    ld b, d
    db $ed
    ld h, c
    cp $e2
    db $ed
    ld h, b
    cp $a6
    ld a, [hl-]
    dec a
    ld b, b
    ld b, e
    db $ed
    ld h, c
    cp $97
    jr c, UnreachableCodeData_003_06

    ld a, $41
    ld b, h
    db $ed
    ld h, b
    cp $97
    add hl, sp
    inc a
    ccf
    ld b, d
    ld b, l
    db $ed
    ld h, c
    cp $e2
    db $ed
    ld h, b
    cp $e2
    db $ed
    ld h, c
    cp $e2
    db $ed
    ld h, b
    cp $e2
    db $ed
    ld h, c
    cp $e2
    db $ed
    ld h, b
    cp $e2
    db $ed
    ld h, c
    cp $43
    db $fd
    db $f4
    add d
    db $fd
    ld h, e
    db $d3
    ld h, e
    ld h, b
    ld h, b
    cp $43
    db $fd
    db $f4
    add d
    db $fd
    ld h, h
    db $d3
    ld h, h
    ld h, c

UnreachableCodeData_003_06:
    ld h, c
    cp $43
    db $fd
    db $f4
    add d
    ld l, d
    ld l, e
    ldh [c], a
    db $fd
    ld h, b
    cp $e2
    db $fd
    ld h, c
    cp $d3
    ld h, e
    ld h, b
    ld h, b
    cp $21
    inc [hl]
    db $d3
    ld h, h
    ld h, c
    ld h, c
    cp $12
    ld sp, $e235
    db $ed
    ld h, b
    cp $12
    ld [hl-], a
    ld [hl], $e2
    db $ed
    ld h, c
    cp $12
    inc sp
    scf
    db $d3
    ld h, e
    ld h, b
    ld h, b
    cp $d3
    ld h, h
    ld h, c
    ld h, c
    cp $e2
    db $ed
    ld h, b
    cp $e2
    db $ed
    ld h, c
    cp $d3
    ld h, e
    ld h, b
    ld h, b
    cp $d3
    ld h, h
    ld h, c
    ld h, c
    cp $e2
    db $ed
    ld h, b
    cp $e2
    db $ed
    ld h, c
    cp $d3
    ld h, e
    ld h, b
    ld h, b
    cp $d3
    ld h, h
    ld h, c
    ld h, c
    cp $e2
    db $ed
    ld h, b
    cp $e2
    db $ed
    ld h, c
    cp $81
    ld h, e
    ldh [c], a
    db $ed
    ld h, b
    cp $81
    ld h, h
    ldh [c], a
    db $ed
    ld h, c
    cp $72
    db $fd
    ld h, e
    ldh [c], a
    db $ed
    ld h, b
    cp $72
    db $fd
    ld h, h
    ldh [c], a
    db $ed
    ld h, c
    cp $e2
    db $ed
    ld h, b
    cp $21
    inc [hl]
    ldh [c], a
    db $ed
    ld h, c
    cp $12
    ld sp, $e235
    db $ed
    ld h, b
    cp $12
    ld [hl-], a
    ld [hl], $e2
    db $ed
    ld h, c
    cp $12
    inc sp
    scf
    ldh [c], a
    db $ed
    ld h, b
    cp $e2
    db $ed
    ld h, c
    cp $e2
    db $ed
    ld h, b
    cp $e2
    db $ed
    ld h, c
    cp $e2
    db $ed
    ld h, b
    cp $e2
    db $ed
    ld h, c
    cp $e2
    db $ed
    ld h, b
    cp $e2
    db $ed
    ld h, c
    cp $e2
    db $ed
    ld h, b
    cp $e2
    db $ed
    ld h, c
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
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    jp z, $d650

    ld d, b
    rst $10
    ld d, b
    db $e4
    ld d, b
    pop af
    ld d, b
    db $fd
    ld d, b
    cp $50
    dec bc
    ld d, c
    jr AudioTable_Block2

    dec h
    ld d, c
    ld [hl-], a
    ld d, c
    ld a, $51
    ld a, $51
    ccf
    ld d, c
    ld c, a
    ld d, c
    ld e, h
    ld d, c
    ld [hl], l
    ld d, c
    sub c
    ld d, c
    and a
    ld d, c
    or a
    ld d, c
    call nz, $d751
    ld d, c
    ld [$0651], a
    ld d, d
    add hl, de
    ld d, d
    dec hl
    ld d, d
    nop
    ld b, c
    ld bc, $0007
    jr AudioTable_Block1

    ld e, e
    ld de, $100a
    rlca
    nop
    ld c, e
    ld bc, $000a
    dec l
    db $10
    inc d
    nop
    halt
    db $10

AudioTable_Block1:
    ld bc, $1011
    db $10
    inc h
    ld de, $100b
    nop
    nop
    dec hl
    ld bc, $000f
    inc l
    db $10
    rra
    ld de, $100b
    daa
    ld de, $0101

AudioTable_Block2:
    add hl, bc
    nop
    jr nz, AudioTable_Block3

    ld e, l
    ld de, $1014
    add hl, de
    nop
    daa
    db $10
    ld a, [bc]
    ld de, $1006
    ld a, [hl+]
    nop
    ld d, c
    db $10

AudioTable_Block3:
    ld c, $11
    ld b, $10
    ld [bc], a
    nop
    ld h, e
    ld bc, $110f
    rlca
    db $10
    ld b, $ff
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
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
    jr z, PaddingZone_003_65f3

    ld a, [bc]
    ld de, $100b
    dec h
    ld de, $1011
    ld de, $0811
    db $10
    inc b
    nop
    inc e
    db $10

PaddingZone_003_65f3:
    inc b
    ld de, HeaderLogo
    inc bc
    nop
    rra
    db $10
    ld [bc], a
    ld de, $100d
    rlca
    nop
    cpl
    db $10
    ld bc, $0d11
    db $10
    inc b
    nop
    dec e
    ld bc, $000c
    ld e, c
    db $10
    inc bc
    ld de, $000f
    rra
    jr nz, @+$0c

    nop
    ld [hl+], a
    stop
    ld de, $1016
    dec a
    ld de, $101a
    nop
    nop
    dec de
    db $10
    cpl
    ld de, $010f
    ld bc, $2900
    db $10
    inc b
    ld de, $100d
    ld a, [bc]
    nop
    ld b, b
    ld bc, $210c
    ld bc, $0820
    nop
    add hl, hl
    jr nz, AudioTable_Block4

    nop
    ld b, a
    db $10
    rla
    ld de, $1018
    ld a, [de]
    nop
    ld [de], a
    db $10
    rlca
    ld de, $100c
    ld bc, $1500
    db $10
    add hl, bc
    ld de, $100b

AudioTable_Block4:
    jr nz, AudioTable_Block5

AudioTable_Block5:
    dec e
    ld bc, $0001
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
    rst $38
    rst $38
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
    ld h, $10
    inc bc
    ld de, $100d
    add hl, bc
    nop
    ld [$0c10], sp
    ld de, $100d
    ld a, [bc]
    nop
    jr AudioTable_Block6

    inc b
    ld de, $100b
    inc b
    nop
    ld [hl+], a
    db $10
    ld bc, $1111
    db $10
    ld [bc], a
    nop
    dec a
    db $10

AudioTable_Block6:
    ld [$0c11], sp
    db $10
    dec c
    nop
    ld [hl], b
    ld bc, $1105
    rlca
    db $10
    inc b
    nop
    jr nz, UnreachableCodeData_003_07

    dec c
    ld de, $101c
    ld a, [de]
    nop
    dec h
    ld bc, $1110
    dec b
    db $10
    ld b, $00
    inc l
    db $10

UnreachableCodeData_003_07:
    inc bc
    ld de, $1011
    ld c, $00
    ld h, $10
    db $10
    ld de, $1017
    inc bc
    nop
    inc d
    ld bc, $000d
    dec de
    db $10
    ld a, [bc]
    nop
    ld a, [hl+]
    ld de, $100d
    inc bc
    nop
    ld c, $20
    ld b, $00
    ld a, [de]
    db $10
    inc bc
    ld de, $1009
    ld [$1700], sp
    db $10
    ld [$0501], sp
    ld de, $0004
    inc d
    jr nz, @+$08

    nop
    sbc b
    ld bc, $1109
    ld b, $10
    ld [bc], a
    nop
    dec l
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    xor [hl]
    ld l, b
    db $e3
    ld l, b
    ld [hl], $69
    ld [hl], e
    ld l, c
    inc c
    ld l, c
    cp l
    ld l, c
    sbc [hl]
    ld l, c
    jp hl


    ld l, c
    ld a, d
    ld l, b
    ld l, l
    ld l, b
    ld h, c
    ld l, c
    jp $ef68


    ld l, b
    ld b, d
    ld l, c
    add b
    ld l, c
    ld d, $69
    bit 5, c
    rst $28
    ld l, b
    rrca
    ld l, d
    rst $28
    ld l, b
    rst $28
    ld l, b
    add b
    ld l, c
    ld d, b
    ld l, d
    sbc h
    ld l, d
    ld l, c
    ld l, d
    sub b
    ld l, d
    xor b
    ld l, d
    xor b
    ld l, d
    ld [hl], l
    ld l, d
    xor b
    ld l, d
    sub h
    ld [hl], b
    sbc a
    ld [hl], b
    xor d
    ld [hl], b
    or l
    ld [hl], b
    ret nz

    ld [hl], b
    bit 6, b
    sub $70
    pop hl
    ld [hl], b
    pop bc
    ld a, c
    call z, $d779
    ld a, c
    ldh [c], a
    ld a, c
    db $ed
    ld a, c
    ld hl, sp+$79
    inc bc
    ld a, d
    ld c, $7a
    ld c, a
    ld a, [hl]
    add hl, de
    ld a, d
    inc h
    ld a, d

ProcessAudioSnapshot:
    push af
    push bc
    push de
    push hl
    ld a, $03
    ldh [rIE], a
    ei
    ldh a, [hSavedAudio]
    cp $01
    jr z, ProcessAudioSnapshot_ResetEnvelopes

    cp $02
    jr z, ProcessAudioSnapshot_ClearMixerSnapshot

    ldh a, [hAudioMixerSnapshot]
    and a
    jr nz, ProcessAudioSnapshot_CheckMixerState

    ld c, $d3
    ldh a, [c]
    and a
    jr z, ProcessAudioSnapshot_ProcessChannels

    xor a
    ldh [c], a
    ld a, $08
    ld [wStateBuffer], a

ProcessAudioSnapshot_ProcessChannels:
    call CheckAudioChannel1
    call CheckAudioChannel4
    call InitializeWaveAudio
    call ProcessAudioRequest
    call ProcessAudioQueue
    call UpdateAudioEnvelopeAndPan

ProcessAudioSnapshot_ClearStateAndReturn:
    xor a
    ld [wStateBuffer], a
    ld [wStateRender], a
    ld [wStateVar10], a
    ld [wStateFinal], a
    ldh [hSavedAudio], a
    ld a, $07
    ldh [rIE], a
    pop hl
    pop de
    pop bc
    pop af
    reti


ProcessAudioSnapshot_ResetEnvelopes:
    call ResetAudioChannelEnvelopes
    xor a
    ld [wStateDisplay], a
    ld [wStateVar11], a
    ld [wStateEnd], a
    ld a, $30
    ldh [hAudioMixerSnapshot], a

ProcessAudioSnapshot_SetupBgmData:
    ld hl, $67ec

ProcessAudioSnapshot_ConfigureBgm:
    call ConfigureAudioBgm
    jr ProcessAudioSnapshot_ClearStateAndReturn

ProcessAudioSnapshot_SetupSeData:
    ld hl, $67f0
    jr ProcessAudioSnapshot_ConfigureBgm

ProcessAudioSnapshot_ClearMixerSnapshot:
    xor a
    ldh [hAudioMixerSnapshot], a
    jr ProcessAudioSnapshot_ProcessChannels

ProcessAudioSnapshot_CheckMixerState:
    ld hl, hAudioMixerSnapshot
    dec [hl]
    ld a, [hl]
    cp $28
    jr z, ProcessAudioSnapshot_SetupSeData

    cp $20
    jr z, ProcessAudioSnapshot_SetupBgmData

    cp $18
    jr z, ProcessAudioSnapshot_SetupSeData

    cp $10
    jr nz, ProcessAudioSnapshot_ClearStateAndReturn

    inc [hl]
    jr ProcessAudioSnapshot_ClearStateAndReturn

    or d
    db $e3
    add e
    rst $00
    or d
    db $e3
    pop bc
    rst $00

InitializeWaveAudio:
    ld a, [wStateVar10]
    cp $01
    jr z, @+$0f

    ld a, [wStateVar11]
    cp $01
    jr z, InitializeWaveAudio_ConfigureWave

    ret


    add b
    ld a, [hl-]
    jr nz, @-$4e

    add $ea
    pop af
    rst $18
    ld hl, $df3f
    set 7, [hl]
    xor a
    ld [wStateVar14], a
    ldh [rNR30], a
    ld hl, $7047
    call LoadAudioRegisterRange
    ldh a, [rDIV]
    and AUDIO_POSITION_MASK
    ld b, a
    ld a, $d0
    add b
    ld [wStateVar15], a
    ld hl, $6803
    jp ConfigureAudioWave


InitializeWaveAudio_ConfigureWave:
    ldh a, [rDIV]
    and FRAME_MASK_8
    ld b, a
    ld hl, wStateVar14
    inc [hl]
    ld a, [hl]
    ld hl, wStateVar15
    cp $0e
    jr nc, InitializeWaveAudio_HighFrequency

    inc [hl]
    inc [hl]

InitializeWaveAudio_WriteFrequency:
    ld a, [hl]
    and $f8
    or b
    ld c, $1d
    ldh [c], a
    ret


InitializeWaveAudio_HighFrequency:
    cp $1e
    jr z, InitializeWaveAudio_ResetWave

    dec [hl]
    dec [hl]
    dec [hl]
    jr InitializeWaveAudio_WriteFrequency

InitializeWaveAudio_ResetWave:
    xor a
    ld [wStateVar11], a
    ldh [rNR30], a
    ld hl, $df3f
    res 7, [hl]
    ld bc, $df36
    ld a, [bc]
    ld l, a
    inc c
    ld a, [bc]
    ld h, a
    call LoadAudioRegisterRange
    ret


    nop
    or b
    ld d, e
    add b
    rst $00
    ld a, $03
    ld hl, $6868
    jp DispatchAudioCommand


    inc a
    add b
    and b
    ld d, b
    add h
    call SkipIfGameState05
    ret z

    ld a, $0e
    ld hl, $6875
    jp DispatchAudioCommand


    nop
    add b
    jp nc, $860a

    dec a
    add b
    and e
    add hl, bc
    add a

SkipIfGameState04:
    ld a, [wStateDisplay]
    jr AudioChannelDispatchCase_05

SkipIfGameState03:
    ld a, [wStateDisplay]
    cp $03
    ret z

SkipIfGameState05:
    ld a, [wStateDisplay]
    cp $05
    ret z

AudioChannelDispatchCase_05:
    cp $04
    ret z

    cp $06
    ret z

    cp $08
    ret z

    cp $0b
    ret z

    ret


    call SkipIfGameState03
    ret z

    ld a, $10
    ld hl, $6886
    call DispatchAudioCommand
    ld hl, wStateGraphics
    ld [hl], $0a
    inc l
    ld [hl], $86
    ret


    call UpdateAudioFrameCounter
    and a
    jp z, ResetPulseChannel

    ld hl, wStateGraphics
    ld e, [hl]
    inc l
    ld d, [hl]
    push hl
    ld hl, $000f
    add hl, de
    ld c, $13
    ld a, l
    ldh [c], a
    ld b, a
    inc c
    ld a, h
    and $3f
    ldh [c], a
    pop hl
    ld [hl-], a
    ld [hl], b
    ret


    call SkipIfGameState03
    ret z

    ld a, $03
    ld hl, $688b
    jp DispatchAudioCommand


    call UpdateAudioFrameCounter
    and a
    ret nz

ResetPulseChannel:
    xor a
    ld [wStateDisplay], a

AudioData_003_68f8:
    ldh [rNR10], a
    ldh [rNR12], a
    ld hl, $df1f
    res 7, [hl]
    ret


    nop
    add b
    ldh [c], a
    ld b, $87
    nop
    add b
    ldh [c], a
    add e
    add a
    call SkipIfGameState04
    ret z

    ld hl, $6902
    jp DispatchAudioCommand


    ld hl, wStateGraphics
    inc [hl]
    ld a, [hl]
    cp $04
    jr z, SetupAudioConfiguration

    cp $18
    jp z, ResetPulseChannel

    ret


SetupAudioConfiguration:
    ld hl, $6907
    call ConfigureAudioSe
    ret


    ld d, a
    sub [hl]
    adc h
    jr nc, AudioData_003_68f8

    ld d, a
    sub [hl]
    adc h
    dec [hl]

ProcessAudioFrame:
    rst $00
    call SkipIfGameState05
    ret z

    ld a, $08
    ld hl, $692c
    jp DispatchAudioCommand


    call UpdateAudioFrameCounter
    and a
    ret nz

    ld hl, wStateGraphics
    ld a, [hl]
    inc [hl]
    cp $00
    jr z, SquareChannel1_Setup

    cp $01
    jp z, ResetPulseChannel

    ret


SquareChannel1_Setup:
    ld hl, $6931
    jp InitSquareChannel1


    ld d, h
    nop
    sbc d
    jr nz, @-$77

    ld a, $60

DispatchAudioWaveCommand:
    ld [wStateVar6], a
    ld a, $05
    ld hl, $695c
    jp DispatchAudioCommand


    daa
    add b
    adc d
    db $10
    add [hl]
    ld a, $10
    ld [wStateVar6], a
    ld a, $05
    ld hl, $696e
    jp DispatchAudioCommand


    call UpdateAudioFrameCounter
    and a
    ret nz

    ld hl, wStateVar6
    ld a, $10
    add [hl]
    ld [hl], a
    cp $e0
    jp z, ResetPulseChannel

    ld c, $13
    ldh [c], a
    inc c
    ld a, $86
    ldh [c], a
    ret


    inc l
    add b
    db $d3
    ld b, b
    add h
    call SkipIfGameState05
    ret z

    ld a, $08
    ld hl, $6999
    jp DispatchAudioCommand


    ld a, [hl-]
    add b
    db $e3
    jr nz, ProcessAudioFrame

    di
    or e
    and e
    sub e
    add e
    ld [hl], e
    ld h, e
    ld d, e
    ld b, e
    inc sp
    inc hl
    inc hl
    inc de
    nop
    ld a, [wStateDisplay]
    cp $08
    ret z

    ld a, $06
    ld hl, $69aa
    jp DispatchAudioCommand


    call UpdateAudioFrameCounter
    and a
    ret nz

    ld hl, wStateGraphics
    ld c, [hl]
    inc [hl]
    ld b, $00
    ld hl, $69af
    add hl, bc
    ld a, [hl]
    and a
    jp z, ResetPulseChannel

    ld c, $12
    ldh [c], a
    inc c

AudioData_003_69e4:
    inc c
    ld a, $87
    ldh [c], a
    ret


DispatchAudioWave_Setup:
    ld a, $06
    ld hl, $69f1

DispatchAudioWave_Entry:
    jp DispatchAudioCommand


    nop
    jr nc, AudioData_003_69e4

    and a
    rst $00
    nop
    jr nc, DispatchAudioWave_Setup

    or c
    rst $00
    nop
    jr nc, DispatchAudioWave_Entry

    cp d
    rst $00
    nop
    jr nc, @-$0e

    call nz, LCDStat_SetLYC
    jr nc, @-$0e

    call nc, LCDStat_SetLYC
    jr nc, @-$0e

    set 0, a
    call UpdateAudioFrameCounter
    and a
    ret nz

    ld a, [wStateGraphics]
    inc a
    ld [wStateGraphics], a
    cp $01
    jr z, ChannelType_01_PulseWave

    cp $02
    jr z, ChannelType_02_PulseWave

    cp $03
    jr z, ChannelType_03_WaveMemory

    cp $04
    jr z, ChannelType_04_Noise

    cp $05
    jr z, ChannelType_05_Master

    jp ResetPulseChannel


ChannelType_01_PulseWave:
    ld hl, $69f6
    jr ChannelInitDispatcher

ChannelType_02_PulseWave:
    ld hl, $69fb
    jr ChannelInitDispatcher

ChannelType_03_WaveMemory:
    ld hl, $6a00
    jr ChannelInitDispatcher

ChannelType_04_Noise:
    ld hl, $6a05
    jr ChannelInitDispatcher

ChannelType_05_Master:
    ld hl, $6a0a

ChannelInitDispatcher:
    jp InitSquareChannel1


    nop
    db $f4
    ld d, a
    add b
    ld a, $30
    ld hl, $6a4c
    jp DispatchAudioCommand


CheckAudioActive:
    ld a, [wStateEnd]
    cp $01
    ret z

    ret


    nop
    inc l
    ld e, $80
    rra
    dec l
    cpl
    dec a
    ccf
    nop
    call CheckAudioActive
    ret z

    ld a, $06
    ld hl, $6a5f
    jp DispatchAudioCommand


    call UpdateAudioFrameCounter
    and a
    ret nz

    ld hl, $dffc
    ld c, [hl]
    inc [hl]
    ld b, $00
    ld hl, $6a63
    add hl, bc
    ld a, [hl]
    and a
    jr z, AudioData_003_6aad

    ldh [rNR43], a
    ret


    nop
    ld l, l
    ld d, h
    add b
    ld a, $16
    ld hl, $6a8c
    jp DispatchAudioCommand


    nop
    ldh a, [c]
    ld d, l
    add b
    call CheckAudioActive
    ret z

    ld a, $15
    ld hl, $6a98
    jp DispatchAudioCommand


    call UpdateAudioFrameCounter
    and a
    ret nz

AudioData_003_6aad:
    xor a
    ld [wStateEnd], a
    ldh [rNR42], a
    ld hl, $df4f
    res 7, [hl]
    ret


DispatchAudioCommand:
    push af
    dec e
    ldh a, [hAudioStatus]
    ld [de], a
    inc e
    pop af
    inc e
    ld [de], a
    dec e
    xor a
    ld [de], a
    inc e
    inc e
    ld [de], a
    inc e
    ld [de], a
    ld a, e
    cp $e5
    jr z, ConfigureAudioSe_Entry

    cp $f5
    jr z, ConfigureAudioWave_Entry

    cp $fd
    jr z, AudioData_003_6aed

    ret


ConfigureAudioSe:
InitSquareChannel1:
ConfigureAudioSe_Entry:
    push bc
    ld c, $10
    ld b, $05
    jr AudioRegisterTransferLoop

ConfigureAudioBgm:
    push bc
    ld c, $16
    ld b, $04
    jr AudioRegisterTransferLoop

ConfigureAudioWave:
ConfigureAudioWave_Entry:
    push bc
    ld c, $1a
    ld b, $05
    jr AudioRegisterTransferLoop

AudioData_003_6aed:
    push bc
    ld c, $20
    ld b, $04

AudioRegisterTransferLoop:
    ld a, [hl+]
    ldh [c], a
    inc c
    dec b
    jr nz, AudioRegisterTransferLoop

    pop bc
    ret


SetAudioStatus:
    inc e
    ldh [hAudioStatus], a

IndexAudioTable:
    inc e
    dec a
    sla a
    ld c, a
    ld b, $00
    add hl, bc
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld l, c
    ld h, b
    ld a, h
    ret


UpdateAudioFrameCounter:
    push de
    ld l, e
    ld h, d
    inc [hl]
    ld a, [hl+]
    cp [hl]
    jr nz, AudioFrameCounter_Exit

    dec l
    xor a
    ld [hl], a

AudioFrameCounter_Exit:
    pop de
    ret


LoadAudioRegisterRange:
    push bc
    ld c, $30

.audioRegisterLoop:
    ld a, [hl+]
    ldh [c], a
    inc c
    ld a, c
    cp $40
    jr nz, .audioRegisterLoop

    pop bc
    ret


ClearAudioChannels:
ResetAllAudioChannels:
    xor a
    ld [wStateDisplay], a
    ld [wStateVar9], a
    ld [wStateVar11], a
    ld [wStateEnd], a
    ld [wComplexState1F], a
    ld [wComplexState2F], a
    ld [wComplexState3F], a
    ld [wComplexState4F], a
    ldh [hSavedAudio], a
    ldh [hAudioMixerSnapshot], a
    ld a, $ff
    ldh [rNR51], a
    ld a, $03
    ldh [hAudioEnvCounter], a

ResetAudioChannelEnvelopes:
    ld a, $01
    ldh [rNR12], a
    ldh [rNR22], a
    ldh [rNR42], a
    xor a
    ldh [rNR10], a
    ldh [rNR30], a
    ret


CheckAudioChannel1:
    ld de, wStateBuffer
    ld a, [de]
    and a
    jr z, .audioChannel1Path

    ld hl, $df1f
    set 7, [hl]
    ld hl, $6700
    call SetAudioStatus
    jp hl


.audioChannel1Path:
    inc e
    ld a, [de]
    and a
    jr z, .audioChannelEnd

    ld hl, $6716
    call IndexAudioTable
    jp hl


.audioChannelEnd:
    ret


CheckAudioChannel4:
    ld de, wStateFinal
    ld a, [de]
    and a
    jr z, .audioChannel4Path

    ld hl, $df4f
    set 7, [hl]
    ld hl, $672c
    call SetAudioStatus
    jp hl


.audioChannel4Path:
    inc e
    ld a, [de]
    and a
    jr z, .audioChannel4End

    ld hl, $6734
    call IndexAudioTable
    jp hl


.audioChannel4End:
    ret


AudioClearChannels_Entry:
    call ClearAudioChannels
    ret


ProcessAudioRequest:
    ld hl, wStateRender
    ld a, [hl+]
    and a
    ret z

    ld [hl], a
    cp $ff
    jr z, AudioClearChannels_Entry

    ld b, a
    ld hl, $673c
    ld a, b
    and AUDIO_POSITION_MASK
    call IndexAudioTable
    call InitializeAudioChannelState
    call LookupAudioEnvelope
    ret


LookupAudioEnvelope:
    ld a, [wStateVar9]
    and a
    ret z

    ld hl, $6c2b

.envelopeTableSearchLoop:
    dec a
    jr z, .envelopeTableFound

    inc hl
    inc hl
    inc hl
    inc hl
    jr .envelopeTableSearchLoop

.envelopeTableFound:
    ld a, [hl+]
    ldh [hAudioEnvCounter], a
    ld a, [hl+]
    ldh [hAudioEnvDiv], a
    ld a, [hl+]
    ldh [hAudioEnvParam1], a
    ld a, [hl+]
    ldh [hAudioEnvParam2], a
    xor a
    ldh [hAudioEnvPos], a
    ldh [hAudioEnvRate], a
    ret


UpdateAudioPan:
    ld a, [wStateEnd]
    cp $01
    ret nz

    ld a, [hl]
    bit 1, a
    ld a, $f7
    jr z, .panUpdateDisabled

    ld a, $7f

.panUpdateDisabled:
    call WriteAudioRegisterNr24
    ret


UpdateAudioEnvelopeAndPan:
    ld a, [wStateVar9]
    and a
    jr z, SetMasterVolumeToFull

    ld hl, hAudioEnvPos
    call UpdateAudioPan
    ld a, [hGameState]
    cp $05
    jr z, SetMasterVolumeToFull

    ldh a, [hAudioEnvCounter]
    cp $01
    jr z, SetMasterVolumeFromParam

    cp $03
    jr z, SetMasterVolumeToFull

    inc [hl]
    ld a, [hl+]
    cp [hl]
    ret nz

    dec l
    ld [hl], $00
    inc l
    inc l
    inc [hl]
    ldh a, [hAudioEnvParam1]
    bit 0, [hl]
    jp z, SetAudioMasterVolume

    ldh a, [hAudioEnvParam2]

WriteAudioRegisterNr24:
SetAudioMasterVolume:
SetAudioMasterVolumeImpl:
    ld c, $25
    ldh [c], a
    ret


SetMasterVolumeToFull:
    ld a, $ff
    jr SetAudioMasterVolumeImpl

SetMasterVolumeFromParam:
    ldh a, [hAudioEnvParam1]
    jr SetAudioMasterVolumeImpl

    ld [bc], a
    inc h
    ld h, l
    ld d, [hl]
    ld bc, $bd00
    nop
    ld [bc], a
    jr nz, AudioData_003_6cb5

    or a
    ld bc, $ed00
    nop
    ld [bc], a
    jr @+$81

    rst $30
    ld [bc], a
    ld b, b
    ld a, a
    rst $30
    ld [bc], a
    ld b, b
    ld a, a
    rst $30
    inc bc
    jr @+$81

    rst $30
    inc bc
    db $10
    ld e, d
    and l
    ld bc, $6500
    nop
    inc bc
    nop
    nop
    nop
    ld [bc], a
    ld [$b57f], sp
    ld bc, $ed00
    nop
    ld bc, $ed00
    nop
    inc bc
    nop
    nop
    nop
    ld bc, $ed00
    nop
    ld [bc], a
    jr @+$80

    rst $20
    ld bc, $ed18
    rst $20
    ld bc, $de00
    nop

CopyAudioDataWord:
    ld a, [hl+]
    ld c, a
    ld a, [hl]
    ld b, a
    ld a, [bc]
    ld [de], a
    inc e
    inc bc
    ld a, [bc]
    ld [de], a
    ret


CopyAudioDataPair:
    ld a, [hl+]
    ld [de], a
    inc e
    ld a, [hl+]
    ld [de], a
    ret


InitializeAudioChannelState:
    call ResetAudioChannelEnvelopes
    xor a
    ld [hAudioEnvPos], a
    ld [hAudioEnvRate], a
    ld de, $df00
    ld b, $00
    ld a, [hl+]
    ld [de], a
    inc e
    call CopyAudioDataPair
    ld de, $df10
    call CopyAudioDataPair
    ld de, $df20
    call CopyAudioDataPair
    ld de, $df30
    call CopyAudioDataPair
    ld de, $df40
    call CopyAudioDataPair

AudioData_003_6cb5:
    ld hl, $df10
    ld de, $df14
    call CopyAudioDataWord
    ld hl, $df20
    ld de, $df24
    call CopyAudioDataWord
    ld hl, $df30
    ld de, $df34
    call CopyAudioDataWord
    ld hl, $df40
    ld de, $df44
    call CopyAudioDataWord
    ld bc, $0410
    ld hl, $df12

AudioControlInitLoop:
    ld [hl], $01
    ld a, c
    add l
    ld l, a
    dec b
    jr nz, AudioControlInitLoop

    xor a
    ld [wComplexState1E], a
    ld [wComplexState2E], a
    ld [wComplexState3E], a
    ret


AudioData_003_6cf2:
    push hl
    xor a
    ldh [rNR30], a
    ld l, e
    ld h, d
    call LoadAudioRegisterRange
    pop hl
    jr PaddingZone_003_6d28

LoadAudioParameterTriple:
    call IncrementAudioWord
    call DereferenceAudioPointer
    ld e, a
    call IncrementAudioWord
    call DereferenceAudioPointer
    ld d, a
    call IncrementAudioWord
    call DereferenceAudioPointer
    ld c, a
    inc l
    inc l
    ld [hl], e
    inc l
    ld [hl], d
    inc l
    ld [hl], c
    dec l
    dec l
    dec l
    dec l
    push hl
    ld hl, hAudioControl
    ld a, [hl]
    pop hl
    cp $03
    jr z, AudioData_003_6cf2

PaddingZone_003_6d28:
    call IncrementAudioWord
    jp DecodeAudioOpcode


IncrementAudioWord:
    push de
    ld a, [hl+]
    ld e, a
    ld a, [hl-]
    ld d, a
    inc de

AudioData_003_6d34:
    ld a, e
    ld [hl+], a
    ld a, d
    ld [hl-], a
    pop de
    ret


AdvanceAudioPointerByWord:
    push de
    ld a, [hl+]
    ld e, a
    ld a, [hl-]
    ld d, a
    inc de
    inc de
    jr AudioData_003_6d34

DereferenceAudioPointer:
    ld a, [hl+]
    ld c, a
    ld a, [hl-]
    ld b, a
    ld a, [bc]
    ld b, a
    ret


AudioControlDispatch_6d4a:
    pop hl
    jr PaddingZone_003_6d78

CheckAudioControl3Mode:
    ldh a, [hAudioControl]
    cp $03
    jr nz, AudioChannelStatusCheck

    ld a, [wComplexState38]
    bit 7, a
    jr z, AudioChannelStatusCheck

    ld a, [hl]
    cp $06
    jr nz, AudioChannelStatusCheck

    ld a, $40
    ldh [rNR32], a

AudioChannelStatusCheck:
    push hl
    ld a, l
    add $09
    ld l, a
    ld a, [hl]
    and a
    jr nz, AudioControlDispatch_6d4a

UpdateAudioChannelStatus:
    ld a, l
    add $04
    ld l, a
    bit 7, [hl]
    jr nz, AudioControlDispatch_6d4a

    pop hl
    call HandleAudioChannelStatus

AdvanceAudioChannelState:
PaddingZone_003_6d78:
    dec l
    dec l
    jp AdvanceAudioState


DecodeAudioCommandEntry:
    dec l
    dec l
    dec l
    dec l
    call AdvanceAudioPointerByWord

DecodeAudioOpcodeEntry:
    ld a, l
    add $04
    ld e, a
    ld d, h
    call CopyAudioDataWord
    cp $00
    jr z, AudioChannelComplete

    cp $ff
    jr z, PaddingZone_003_6d98

    inc l
    jp DecodeNextAudioOpcode


PaddingZone_003_6d98:
    dec l
    push hl
    call AdvanceAudioPointerByWord
    call DereferenceAudioPointer
    ld e, a
    call IncrementAudioWord
    call DereferenceAudioPointer
    ld d, a
    pop hl
    ld a, e
    ld [hl+], a
    ld a, d
    ld [hl-], a
    jr DecodeAudioOpcodeEntry

AudioChannelComplete:
    ld hl, $dfe9
    ld [hl], $00
    call ResetAudioChannelEnvelopes
    ret


ProcessAudioQueue:
    ld hl, $dfe9
    ld a, [hl]
    and a
    ret z

    ld a, FLAG_TRUE
    ldh [hAudioControl], a
    ld hl, $df10

AdvanceAudioChannelLoop:
    inc l
    ld a, [hl+]
    and a
    jp z, AdvanceAudioChannelState

    dec [hl]
    jp nz, CheckAudioControl3Mode

DecodeNextAudioOpcode:
    inc l
    inc l

DecodeAudioOpcode:
    call DereferenceAudioPointer
    cp $00
    jp z, DecodeAudioCommandEntry

    cp $9d
    jp z, LoadAudioParameterTriple

    and $f0
    cp $a0
    jr nz, AudioData_003_6dfe

    ld a, b
    and $0f
    ld c, a
    ld b, $00
    push hl
    ld de, $df01
    ld a, [de]
    ld l, a
    inc de
    ld a, [de]
    ld h, a
    add hl, bc
    ld a, [hl]
    pop hl
    dec l
    ld [hl+], a
    call IncrementAudioWord
    call DereferenceAudioPointer

AudioData_003_6dfe:
    ld a, b
    ld c, a
    ld b, $00
    call IncrementAudioWord
    ldh a, [hAudioControl]
    cp $04
    jp z, CopyAudioConfigToRAM

    push hl
    ld a, l
    add $05
    ld l, a
    ld e, l
    ld d, h
    inc l
    inc l
    ld a, c
    cp $01
    jr z, AudioNoteDispatchCase_01

    ld [hl], $00
    ld hl, $6f70
    add hl, bc
    ld a, [hl+]
    ld [de], a
    inc e
    ld a, [hl]
    ld [de], a
    pop hl
    jp RouteAudioControlSetup


AudioNoteDispatchCase_01:
    ld [hl], $01
    pop hl
    jr AudioChannelSetup_Ch3

CopyAudioConfigToRAM:
    push hl
    ld de, $df46
    ld hl, $7002
    add hl, bc

AudioData_003_6e36:
    ld a, [hl+]
    ld [de], a
    inc e
    ld a, e
    cp $4b
    jr nz, AudioData_003_6e36

    ld c, $20
    ld hl, $df44
    jr AudioControlCommonPath

RouteAudioControlSetup:
AudioChannelSetup_Ch3:
    push hl
    ldh a, [hAudioControl]
    cp $01
    jr z, AudioChannelSetup_1

    cp $02
    jr z, AudioChannelSetup_Ch2

    ld c, $1a
    ld a, [wComplexState3F]
    bit 7, a
    jr nz, AudioControlFlagCheck

    xor a
    ldh [c], a
    ld a, $80
    ldh [c], a

AudioControlFlagCheck:
    inc c
    inc l
    inc l
    inc l
    inc l
    ld a, [hl+]
    ld e, a
    ld d, $00
    jr AudioDataLoad

AudioChannelSetup_Ch2:
    ld c, $16
    jr AudioControlCommonPath

AudioChannelSetup_1:
    ld c, $10
    ld a, $00
    inc c

AudioControlCommonPath:
    inc l
    inc l
    inc l
    ld a, [hl-]
    and a
    jr nz, AudioData_003_6ec8

    ld a, [hl+]
    ld e, a

PaddingZone_003_6e7b:
    inc l
    ld a, [hl+]
    ld d, a

AudioDataLoad:
    push hl
    inc l
    inc l
    ld a, [hl+]
    and a
    jr z, PaddingZone_003_6e87

    ld e, $01

PaddingZone_003_6e87:
    inc l
    inc l
    ld [hl], $00
    inc l
    ld a, [hl]
    pop hl
    bit 7, a
    jr nz, AudioData_003_6ea5

    ld a, d
    ldh [c], a
    inc c
    ld a, e
    ldh [c], a
    inc c
    ld a, [hl+]
    ldh [c], a
    inc c
    ld a, [hl]
    or $80
    ldh [c], a
    ld a, l
    or $05
    ld l, a
    res 0, [hl]

AudioData_003_6ea5:
    pop hl
    dec l
    ld a, [hl-]
    ld [hl-], a
    dec l

AdvanceAudioState:
    ld de, hAudioControl
    ld a, [de]
    cp $04
    jr z, IncrementAudioCounters

    inc a
    ld [de], a
    ld de, ANIM_STRUCT_STRIDE
    add hl, de
    jp AdvanceAudioChannelLoop


IncrementAudioCounters:
    ld hl, $df1e
    inc [hl]
    ld hl, $df2e
    inc [hl]
    ld hl, $df3e
    inc [hl]
    ret


AudioData_003_6ec8:
    ld b, $00
    push hl
    pop hl
    inc l
    jr PaddingZone_003_6e7b

GetAudioParameterFromTable:
    ld a, b
    srl a
    ld l, a
    ld h, $00
    add hl, de
    ld e, [hl]
    ret


HandleAudioChannelStatus:
    push hl
    ld a, l
    add $06
    ld l, a
    ld a, [hl]
    and $0f
    jr z, PaddingZone_003_6ef8

    ldh [hAudioStatus], a
    ldh a, [hAudioControl]
    ld c, $13
    cp $01
    jr z, AudioData_003_6efa

    ld c, $18
    cp $02
    jr z, AudioData_003_6efa

    ld c, $1d
    cp $03
    jr z, AudioData_003_6efa

PaddingZone_003_6ef8:
    pop hl
    ret


AudioData_003_6efa:
    inc l
    ld a, [hl+]
    ld e, a

CalculateAudioNoteFrequency:
    ld a, [hl]
    ld d, a
    push de
    ld a, l
    add $04
    ld l, a
    ld b, [hl]
    ldh a, [hAudioStatus]
    cp $01
    jr AudioModeDispatchCase_03_Alt

    cp $03
    jr AudioModeDispatchCase_03

AudioModeDispatchCase_03:
    ld hl, $ffff
    jr PaddingZone_003_6f30

AudioModeDispatchCase_03_Alt:
    ld de, $6f39
    call GetAudioParameterFromTable
    bit 0, b
    jr nz, PaddingZone_003_6f20

    swap e

PaddingZone_003_6f20:
    ld a, e
    and $0f
    bit 3, a
    jr z, PaddingZone_003_6f2d

    ld h, $ff
    or $f0
    jr PaddingZone_003_6f2f

PaddingZone_003_6f2d:
    ld h, $00

PaddingZone_003_6f2f:
    ld l, a

PaddingZone_003_6f30:
    pop de
    add hl, de
    ld a, l
    ldh [c], a
    inc c
    ld a, h
    ldh [c], a
    jr PaddingZone_003_6ef8

    nop
    nop
    nop
    nop
    nop
    nop
    stop
    rrca
    nop
    nop
    ld de, $0f00
    ldh a, [rSB]
    ld [de], a
    db $10
    rst $38
    rst $28
    ld bc, $1012
    rst $38
    rst $28
    ld bc, $1012
    rst $38
    rst $28
    ld bc, $1012
    rst $38
    rst $28
    ld bc, $1012
    rst $38
    rst $28
    ld bc, $1012
    rst $38
    rst $28
    ld bc, $1012
    rst $38
    rst $28
    ld bc, $1012
    rst $38
    rst $28
    nop
    rrca
    inc l
    nop
    sbc h
    nop
    ld b, $01
    ld l, e
    ld bc, $01c9
    inc hl
    ld [bc], a
    ld [hl], a
    ld [bc], a
    add $02
    ld [de], a
    inc bc
    ld d, [hl]
    inc bc
    sbc e
    inc bc
    jp c, PipeEnterRightMoveCheck

    inc b
    ld c, [hl]
    inc b
    add e
    inc b
    or l
    inc b
    push hl
    inc b
    ld de, $3b05
    dec b
    ld h, e
    dec b
    adc c
    dec b
    xor h
    dec b
    adc $05
    db $ed
    dec b
    ld a, [bc]
    ld b, $27
    ld b, $42
    ld b, $5b
    ld b, $72
    ld b, $89
    ld b, $9e
    ld b, $b2
    ld b, $c4
    ld b, $d6
    ld b, $e7
    ld b, $f7
    ld b, $06
    rlca
    inc d
    rlca
    ld hl, $2d07
    rlca
    add hl, sp
    rlca
    ld b, h
    rlca
    ld c, a
    rlca
    ld e, c
    rlca
    ld h, d
    rlca
    ld l, e
    rlca
    ld [hl], e
    rlca
    ld a, e
    rlca
    add e
    rlca
    adc d
    rlca
    sub b
    rlca
    sub a
    rlca
    sbc l
    rlca
    and d
    rlca
    and a
    rlca
    xor h
    rlca
    or c
    rlca
    or [hl]
    rlca
    cp d
    rlca
    cp [hl]
    rlca
    pop bc
    rlca
    call nz, $c807
    rlca
    rlc a
    adc $07
    pop de
    rlca
    call nc, $d607
    rlca
    reti


    rlca
    db $db
    rlca
    db $dd
    rlca
    rst $18
    rlca
    nop
    nop
    nop
    nop
    nop
    ret nz

    and c
    nop
    ld a, [hl-]
    nop
    ret nz

    or c
    nop
    add hl, hl
    ld bc, $81c0
    nop
    add hl, hl
    inc b
    ret nz

    ld bc, $4523
    ld h, a
    adc c
    xor e
    call $feef
    call c, $98ba
    halt
    ld d, h
    ld [hl-], a
    db $10
    ld bc, $2312
    inc [hl]
    ld b, l
    ld d, [hl]
    ld h, a
    ld a, b
    adc c
    sbc d
    xor e
    cp h
    call $eedd
    rst $38
    ld bc, $5623
    ld a, b
    sbc c

HandleAudioConditionalLogic:
    sbc b
    halt
    ld h, a
    sbc d
    rst $18
    cp $c9
    add l
    ld b, d
    ld de, $0100
    inc hl
    ld b, l
    ld h, a
    adc c
    xor e
    call z, LCDStat_PopAndReti
    inc c
    or b
    cp e
    nop
    ei
    cp e
    cp e
    nop
    inc bc
    ld b, $0c
    jr @+$32

    add hl, bc
    ld [de], a
    inc h
    inc b
    ld [$0402], sp
    ld [$2010], sp
    ld b, b
    inc c
    jr PaddingZone_003_709b

    dec b
    ld a, [bc]
    ld bc, $0500
    ld a, [bc]
    inc d
    jr z, PaddingZone_003_70c4

    rrca
    ld e, $3c
    inc bc
    ld b, $0c
    jr AudioDataRaw_003_70ac

    ld h, b
    ld [de], a
    inc h
    ld c, b
    ld [$0010], sp
    rlca
    ld c, $1c
    jr c, AudioDataRaw_003_70f8

    dec d
    ld a, [hl+]
    ld d, h
    inc b
    ld [$2010], sp
    ld b, b
    add b
    jr PaddingZone_003_70c3

    ld h, b
    nop
    ld d, a
    ld [hl], b
    push hl
    ld [hl], e
    jp hl


    ld [hl], e

PaddingZone_003_709b:
    db $eb
    ld [hl], e
    nop
    nop
    nop
    ld [hl], a
    ld [hl], b
    and e
    ld [hl], e
    and a
    ld [hl], e
    xor c
    ld [hl], e
    nop
    nop
    nop
    ld h, d

AudioDataRaw_003_70ac:
    ld [hl], b
    jp hl


    ld [hl], d
    push af
    ld [hl], d
    ld bc, $1573
    ld [hl], e
    nop
    ld [hl], a
    ld [hl], b
    add d
    ld [hl], d
    adc b
    ld [hl], d
    nop
    nop
    adc [hl]
    ld [hl], d
    nop
    ld d, a
    ld [hl], b

PaddingZone_003_70c3:
    inc hl

PaddingZone_003_70c4:
    ld [hl], h
    cpl
    ld [hl], h
    dec sp
    ld [hl], h
    ld b, a
    ld [hl], h
    nop
    ld h, d
    ld [hl], b
    cp h
    ld [hl], l
    ret z

    ld [hl], l
    call nc, $ec75
    ld [hl], l
    nop
    ld h, d
    ld [hl], b
    jp nc, $dc77

    ld [hl], a
    and $77
    ldh a, [c]
    ld [hl], a
    nop
    ld [hl], a
    ld [hl], b
    db $ec
    ld [hl], b
    ld hl, sp+$70
    inc b
    ld [hl], c
    db $10
    ld [hl], c
    jr @+$73

    ld b, b
    ld [hl], c
    ld b, b
    ld [hl], c
    ld e, l
    ld [hl], c
    rst $38
    rst $38
    xor $70

AudioDataRaw_003_70f8:
    jr nz, @+$73

    sub b
    ld [hl], c
    sub b
    ld [hl], c
    xor l
    ld [hl], c
    rst $38
    rst $38
    ld a, [$3070]
    ld [hl], c
    ldh [c], a
    ld [hl], c
    ldh [c], a
    ld [hl], c
    inc de
    ld [hl], d
    rst $38
    rst $38
    ld b, $71
    ld h, l
    ld [hl], d
    ld [hl], h
    ld [hl], d
    rst $38
    rst $38
    ld [de], a
    ld [hl], c
    sbc l
    ld h, [hl]
    nop
    add b
    and l
    ld bc, $0001
    sbc l
    halt
    nop
    add c
    and h
    ld b, d
    ld a, $3a
    xor c
    ld [hl], $36
    ld [hl], $36
    ld [hl], $36
    nop
    sbc l
    scf
    ld [hl], b
    and b
    and h
    ld d, d
    ld c, [hl]
    ld c, h
    xor c
    ld c, b
    ld c, b
    ld c, b
    ld c, b
    ld c, b
    ld c, b
    nop
    and h
    ld bc, $3aa9
    ld bc, $3ea3
    and d
    ld c, h
    and a
    ld bc, $34a9
    ld c, h
    ld bc, $a348
    ld b, h
    ld a, $a9
    ld b, h
    ld bc, $3ea4
    xor c
    ld bc, $01a5
    nop
    and h
    ld bc, $3ea9
    ld bc, $013e
    ld bc, $013e
    ld bc, $0101
    ld bc, $a33a
    ld [hl], $34
    xor c
    jr nc, PaddingZone_003_7173

    inc [hl]

PaddingZone_003_7173:
    ld bc, $4201
    and h
    ld bc, $01a5
    and h
    ld bc, $3ea9
    ld bc, $013e
    ld bc, $013e
    ld bc, $0101
    ld bc, $a33a
    ld [hl], $34
    and l
    ld bc, $0001
    and h
    ld bc, $4ca9
    ld bc, $4ea3
    and d
    ld d, d
    and a
    ld bc, $44a9
    ld d, d
    ld bc, $a34e
    ld c, h
    ld c, b
    xor c
    ld c, h
    ld bc, $44a4
    xor c
    ld bc, $01a5
    nop
    and h
    ld bc, $4ea9
    ld bc, HeaderGlobalChecksum
    ld bc, HeaderGlobalChecksum
    ld bc, $0101
    ld bc, $a34c
    ld c, b
    ld b, h
    xor c
    ld b, d
    ld bc, HeaderNewLicenseeCode
    ld bc, $a448
    ld bc, $01a5
    and h
    ld bc, $4ea9
    ld bc, HeaderGlobalChecksum
    ld bc, HeaderGlobalChecksum
    ld bc, $0101
    ld bc, $a34c
    ld c, b
    ld b, h
    and h
    ld b, d
    ld a, $3a
    ld [hl], $00
    and e
    ld b, h
    xor c
    ld b, h
    ld bc, $a33a
    ld b, h
    xor c
    ld b, h
    ld bc, $a33a
    ld b, h
    xor c
    ld b, h
    ld bc, $a33a
    ld b, h
    xor c
    ld b, h
    ld bc, $a33a
    ld [hl], $a9
    ld [hl], $01
    ld b, h
    and e
    ld [hl], $a9
    ld [hl], $01
    ld b, h
    and e
    ld [hl], $a9
    ld [hl], $01
    ld b, h
    and e
    ld [hl], $a9
    ld [hl], $01
    ld b, h
    nop
    and e
    ld c, b
    xor c
    ld c, b
    ld bc, $a33e
    ld c, b
    xor c
    ld c, b
    ld bc, $a33e
    ld c, b
    xor c
    ld c, b
    ld bc, $a33e
    ld c, b
    xor c
    ld c, b
    ld bc, $a33e
    ld a, [hl-]
    xor c
    ld a, [hl-]
    ld bc, $a348
    ld a, [hl-]
    xor c
    ld a, [hl-]
    ld bc, $a348
    ld a, [hl-]
    xor c
    ld a, [hl-]
    ld bc, $a348
    ld a, [hl-]
    xor c
    ld a, [hl-]
    ld bc, $a348
    ld c, b
    xor c
    ld c, b
    ld bc, $a33e
    ld c, b
    xor c
    ld c, b
    ld bc, $a33e
    ld c, b
    xor c
    ld c, b
    ld bc, $a33e
    ld c, b
    xor c
    ld c, b
    ld bc, $a33e
    ld d, d
    ld d, d
    ld c, [hl]
    ld c, [hl]
    ld c, h
    ld c, h
    ld c, b
    ld c, b
    nop
    and e
    ld b, $06
    ld b, $06
    dec bc
    dec bc
    xor c
    dec bc
    dec bc
    dec bc

ProcessInputState_Bank3_Part1:
    dec bc
    dec bc
    dec bc
    nop
    xor c
    ld b, $01
    ld bc, $0110
    ld b, $01
    ld b, $01
    db $10
    ld bc, $0006
    sub h
    ld [hl], d
    rst $38
    rst $38
    add d
    ld [hl], d
    or l
    ld [hl], d
    rst $38
    rst $38
    adc b
    ld [hl], d
    pop de
    ld [hl], d
    rst $38
    rst $38
    adc [hl]
    ld [hl], d
    sbc l
    ld [hl], e
    nop
    add b
    xor c
    ld bc, $1aa2
    ld bc, $1022
    inc d
    jr @+$1c

    ld bc, $2228
    ld bc, $1a01
    ld bc, $1022
    inc d
    jr @+$1c

    ld bc, $01a3
    xor c
    ld bc, $0001
    sbc l
    sub e
    nop
    add b
    and d
    ld a, [de]
    ld bc, $1022
    inc d
    jr @+$1c

    ld bc, $2228
    ld bc, $1a01
    ld bc, $1022
    inc d
    jr @+$1c

    ld bc, $01a4
    nop
    and d
    ld b, $01
    ld bc, $0106
    ld b, $06
    ld bc, $0606
    ld bc, $0601
    ld bc, $0601
    ld bc, $0606
    ld bc, $01a4
    nop
    jr nz, @+$75

    daa
    ld [hl], e
    daa
    ld [hl], e
    ld e, d
    ld [hl], e
    rst $38

PaddingZone_003_72f2:
    rst $38
    db $eb
    ld [hl], d
    dec de
    ld [hl], e
    daa
    ld [hl], e
    daa
    ld [hl], e
    ld e, d
    ld [hl], e
    rst $38
    rst $38
    rst $30
    ld [hl], d
    ld l, [hl]
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e
    ld [hl], e

AudioData_003_7307:
    ld [hl], e

PaddingZone_003_7308:
    ld [hl], e
    ld [hl], e
    ld [hl], e
    add l
    ld [hl], e
    add l

PaddingZone_003_730e:
    ld [hl], e
    ld [hl], e
    ld [hl], e
    rst $38
    rst $38
    inc bc
    ld [hl], e
    adc [hl]
    ld [hl], e
    rst $38
    rst $38
    dec d
    ld [hl], e
    sbc l
    add b
    nop
    add c
    nop
    sbc l
    jr nc, PaddingZone_003_7323

PaddingZone_003_7323:
    add b
    and a
    ld bc, $a400
    ld b, b
    and e
    ld a, $a9
    jr c, @+$40

    jr c, @-$53

    ld bc, $36a8
    and e
    jr z, AudioDataRaw_003_7360

    and d
    ld a, [hl+]
    ld l, $a3
    ld a, [hl+]
    ld l, $a5
    jr z, @-$5a

    ld b, b
    and e
    ld a, $a9
    jr c, PaddingZone_003_7383

    jr c, PaddingZone_003_72f2

    ld bc, $36a8
    and e
    jr z, PaddingZone_003_7377

    and d
    ld a, [hl+]
    ld l, $a3
    ld [hl-], a
    and c
    ld l, $32
    ld l, $2a
    and l
    jr z, PaddingZone_003_735a

PaddingZone_003_735a:
    and l
    ld a, [hl+]
    and h
    ld bc, $a532

AudioDataRaw_003_7360:
    inc a
    and h
    jr c, AudioData_003_7307

    jr c, PaddingZone_003_7308

    inc a
    jr c, PaddingZone_003_730e

    ld [hl], $01
    ld bc, $0001
    sbc l
    scf
    ld [hl], b

ProcessInputState_Bank3_Part2:
    and b
    nop
    and e
    ld b, b
    ld b, d
    ld b, b

PaddingZone_003_7377:
    ld b, d
    ld b, b
    ld b, d

PaddingZone_003_737a:
    ld b, b
    ld c, [hl]
    ld b, b
    ld b, d
    ld b, b
    ld b, d
    ld b, b
    ld b, d
    ld b, b

PaddingZone_003_7383:
    inc a
    nop
    ld b, d
    ld d, b
    ld b, d
    ld d, b
    ld b, d
    ld d, b
    ld b, d
    ld d, b
    nop
    and e
    ld b, $a2
    ld b, $06
    and e
    ld b, $a2
    ld b, $06
    and e
    ld b, $a2
    ld b, $06
    and e
    dec bc
    and d
    ld b, $06
    nop
    cp [hl]
    ld [hl], e
    nop
    nop
    xor e
    ld [hl], e
    call nc, $9d73
    and c
    nop
    add b
    and b
    ld bc, $58a1
    ld d, h
    ld d, d
    ld c, [hl]
    ld c, d
    and [hl]
    ld bc, $40a2
    ld bc, $0132
    sbc l
    jr nc, PaddingZone_003_73c1

PaddingZone_003_73c1:
    add b
    and c
    ld e, b
    ld d, h
    ld d, d
    ld c, [hl]
    ld c, d
    and [hl]
    ld bc, $a19d
    nop
    add b
    and d
    ld c, [hl]
    ld bc, $0152
    nop
    sbc l
    scf
    ld [hl], b
    jr nz, PaddingZone_003_737a

    ld e, b
    ld d, h
    ld d, d
    ld c, [hl]
    ld c, d
    and [hl]
    ld bc, $60a2
    ld bc, $0162
    db $ed
    ld [hl], e
    nop
    nop
    rst $38
    ld [hl], e
    ld de, $9d74
    ld h, b
    nop
    add b
    xor b
    ld d, d
    and d
    ld d, d
    ld bc, $0152
    ld d, d
    ld bc, $56a8
    ld e, b
    ld e, d
    nop
    sbc l
    add e
    nop
    add b
    xor b
    ld c, d
    and d
    ld c, d
    ld bc, HeaderDestinationCode
    ld c, d
    ld bc, $4ea8
    ld d, b
    ld d, d
    nop
    sbc l
    rla
    ld [hl], b
    ld hl, $70a8
    and d
    ld [hl], b
    ld bc, $0170
    ld [hl], b
    ld bc, $74a8
    halt
    ld a, b
    nop
    ld e, a
    ld [hl], h
    sub c
    ld [hl], h
    sub c
    ld [hl], h
    jr DispatchDataZone_74a0

    rst $38
    rst $38
    dec h
    ld [hl], h
    ld c, a
    ld [hl], h
    cp c
    ld [hl], h
    cp c
    ld [hl], h
    ld c, b
    ld [hl], l
    rst $38
    rst $38
    ld sp, $6f74
    ld [hl], h
    rst $28
    ld [hl], h
    rst $28
    ld [hl], h
    ld a, b
    ld [hl], l
    rst $38
    rst $38
    dec a
    ld [hl], h
    add l
    ld [hl], h
    and e
    ld [hl], l
    rst $38
    rst $38
    ld c, c
    ld [hl], h
    sbc l
    and d
    nop
    add b
    and d
    ld b, b
    ld b, h
    ld bc, HeaderROMSize
    ld b, h
    ld bc, $a540
    inc a
    nop
    sbc l
    add d
    nop
    add b
    and d
    ld c, d
    ld c, d
    ld bc, HeaderDestinationCode
    ld c, d
    ld bc, $a54a
    ld b, h
    nop
    sbc l
    scf
    ld [hl], b
    and b
    and d
    ld d, d
    ld d, h
    ld bc, $0158
    ld d, h
    ld bc, $4052
    ld [hl], $01
    jr nc, @+$2a

    ld bc, $0101
    nop
    and d
    ld b, $06
    ld bc, $0106
    ld b, $01
    ld b, $a5
    ld b, $00
    and d
    ld a, [hl-]
    ld bc, $a701
    ld b, b
    and e
    ld a, [hl-]
    and h
    ld bc, $aa32
    ld [hl], $44
    ld b, h

DispatchDataZone_74a0:
    ld b, h
    ld c, b
    ld c, d
    and l
    ld bc, $3aa2
    ld a, [hl-]
    ld bc, $40a7
    and e
    ld a, [hl-]
    and l
    ld bc, $48aa
    ld bc, $3601
    ld a, [hl-]
    inc a
    and l
    ld a, [hl-]
    nop
    and d
    ld c, d
    ld bc, $a701
    ld d, d
    and e
    ld c, d
    and d
    ld b, h
    ld c, [hl]
    ld bc, $a454
    ld b, h
    xor d
    ld c, b
    ld d, h
    ld d, h
    ld d, h
    ld e, b
    ld e, h
    and d
    ld e, b
    ld d, d
    ld bc, $a44a
    ld b, b
    and d
    ld c, d
    ld c, d
    ld bc, $52a7
    and e
    ld c, d
    and d
    ld b, h
    ld c, [hl]
    ld bc, $a454
    ld b, h
    xor d
    ld c, b
    ld bc, $4801
    ld c, d
    ld c, [hl]
    and l
    ld c, d
    nop
    and a
    ld [hl-], a
    ld a, [hl-]
    and e
    ld b, b
    and a
    inc a
    ld b, h
    and e
    ld c, d
    and a
    ld b, b
    ld c, b
    and e
    ld [hl], $a7
    ld [hl-], a
    ld a, [hl-]
    and e
    ld b, b
    and a
    ld [hl-], a
    ld a, [hl-]
    and e
    ld b, b
    and a
    inc a
    ld b, h
    and e
    ld c, d
    and a
    ld b, b
    ld c, b
    and e
    ld [hl], $a7
    ld [hl-], a
    ld a, [hl-]
    and e
    ld b, b
    nop
    xor d
    ld b, h
    ld b, h
    ld b, h
    ld b, h
    ld b, b
    inc a
    and a
    ld b, b
    ld [hl-], a
    and e
    ld bc, $36a2
    ld bc, $3601
    ld [hl], $3a
    ld bc, $a53c
    ld b, b
    xor d
    ld b, h
    ld bc, $4444
    ld c, b
    ld c, d
    and a
    ld c, b
    ld b, b
    and e
    ld bc, $44a7
    ld b, b
    and e
    inc a
    and d
    ld bc, $013c
    ld bc, $40a4
    nop
    xor d
    ld d, h
    ld d, h
    ld d, h
    ld d, h
    ld d, d
    ld c, [hl]
    and a
    ld d, d
    ld c, d
    and e
    ld bc, $48a2
    ld bc, $4801
    ld c, b
    ld c, d
    ld bc, $a54e
    ld d, d
    xor d
    ld d, h
    ld bc, $5454
    ld e, b
    ld e, h
    and a
    ld e, b
    ld d, d
    and e
    ld bc, $54a7
    ld d, d
    and e
    ld c, [hl]
    and d
    ld bc, HeaderNewLicenseeCode
    ld bc, $48a4
    nop
    and a
    inc a
    ld b, h
    and e
    ld c, d
    and a
    ld [hl-], a
    ld a, [hl-]
    and e
    ld b, b
    and a
    ld b, b
    ld c, b
    and e
    ld [hl], $a7
    ld [hl-], a
    ld a, [hl-]
    and e
    ld b, b
    and a
    inc a
    ld b, h
    and e
    ld c, d
    and a
    ld a, [hl-]
    ld b, b
    and e
    ld c, b
    and a
    inc a
    ld b, h
    and e
    ld c, d
    and d
    ld bc, $0140
    ld bc, $40a4
    nop
    and e
    ld b, $a9
    ld b, $01
    ld b, $a3
    dec bc
    xor c
    ld b, $01
    ld b, $a3
    ld b, $a9
    ld b, $01
    ld b, $a3
    dec bc
    xor c
    ld b, $01
    ld b, $00
    ld [$2876], sp
    halt
    jr z, MusicSequence_Marker_1

    rst $30
    halt
    rst $38
    rst $38

PaddingZone_003_75c6:
    cp [hl]
    ld [hl], l
    db $f4
    ld [hl], l
    ld [hl], a
    halt
    ld [hl], a
    halt
    dec [hl]
    ld [hl], a
    rst $38
    rst $38
    jp z, $1c75

    halt
    or l
    halt
    or l
    halt
    or l
    halt
    sub $76
    or l
    halt
    or l
    halt
    or l
    halt
    sub $76
    ld [hl], e
    ld [hl], a
    rst $38
    rst $38
    sub $75
    inc h
    halt
    cp l
    ld [hl], a
    rst $38
    rst $38
    xor $75
    sbc l
    add h
    nop
    nop
    and d
    ld [hl], b
    ld [hl], b
    ld [hl], b
    ld bc, $016a
    ld l, d
    ld bc, $0166
    ld h, [hl]
    ld bc, $6aa4
    nop
    sbc l
    ld [hl], h
    nop
    nop
    and d
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld bc, $0160
    ld h, b
    ld bc, $015c
    ld e, h
    ld bc, $60a4
    nop
    sbc l
    scf
    ld [hl], b
    jr nz, PaddingZone_003_75c6

    ld bc, $0001
    and l
    ld bc, $0001
    sbc l
    add d
    nop
    nop
    xor b
    ld b, h
    and e
    ld c, b
    and h
    ld c, [hl]
    ld c, b
    and h
    ld b, h
    and e
    ld c, b
    ld b, h

MusicSequence_Marker_1:
    and h
    ld b, b
    and e
    ld a, [hl-]
    ld [hl], $a8
    ld b, h
    and e
    ld c, b
    and h
    ld c, [hl]
    and e
    ld c, b
    ld b, h
    and d
    ld e, b
    ld e, h
    and e
    ld e, b
    and d
    ld d, d
    ld e, b
    and e
    ld d, d
    and d
    ld c, [hl]
    ld d, d
    and e
    ld c, [hl]
    and d
    ld c, b
    ld b, h
    and e
    ld b, b

MusicSequenceData_765a:
    xor b
    ld b, h
    and e
    ld c, b
    and h
    ld c, [hl]
    ld c, b
    and h

MusicSequence_Marker_2:
    ld b, h
    and e
    ld c, b
    ld b, h
    and h
    ld b, b
    and e
    ld a, [hl-]
    ld [hl], $a8
    ld a, [hl-]
    and e

PaddingZone_003_766e:
    ld a, $3a
    ld [hl], $30
    inc l
    and l
    jr nc, MusicSequence_Marker_4

MusicSequence_Marker_3:
    nop

MusicSequence_Marker_4:
    sbc l
    ld [hl], b
    nop
    add c
    xor b
    ld c, [hl]
    and e
    ld d, d
    and h
    ld e, b
    ld d, d
    and h
    ld c, [hl]
    and e
    ld d, d
    ld c, [hl]
    and h
    ld c, b
    and e
    ld b, h
    ld b, b
    xor b
    ld c, [hl]
    and e

MusicSequenceData_768f:
    ld d, d
    and h
    ld e, b
    and e
    ld d, d
    ld c, [hl]
    and l
    ld d, d

MusicSequence_Marker_5:
    ld bc, $4ea8
    and e
    ld d, d
    and h
    ld e, b
    ld d, d
    and h
    ld c, [hl]
    and e
    ld d, d
    ld c, [hl]
    and h
    ld c, b
    and e
    ld b, h
    ld b, b
    xor b
    ld b, h
    and e
    ld c, b
    ld b, h
    ld b, b
    ld a, [hl-]
    ld [hl], $a5
    ld a, [hl-]
    ld bc, $a300
    jr z, MusicSequenceData_765a

    ld b, b
    ld [hl], $a3
    jr z, MusicSequenceData_76fd

    and e
    jr z, MusicSequence_Marker_2

    ld b, b
    ld [hl], $a3
    jr z, MusicSequenceData_7705

    and e
    ld a, [de]
    and d
    ld [hl-], a
    jr z, PaddingZone_003_766e

    ld a, [de]
    ld [hl-], a
    and e
    ld a, [de]
    and d
    ld [hl-], a
    jr z, MusicSequence_Marker_3

    ld a, [de]
    ld [hl-], a
    nop
    and e
    ld e, $a2
    ld [hl], $2c
    and e
    ld e, $36
    and e
    ld e, $a2
    ld [hl], $2c
    and e
    ld e, $36
    and e
    ld [hl+], a
    and d
    ld a, [hl-]
    jr nc, MusicSequenceData_768f

    ld [hl+], a
    ld a, [hl-]
    and e
    ld [hl+], a
    and d
    ld a, [hl-]
    jr nc, MusicSequence_Marker_5

    ld [hl+], a
    ld a, [hl-]
    nop
    xor b
    ld e, h
    and e
    ld h, b
    and h
    ld h, [hl]

MusicSequenceData_76fd:
    and e
    ld h, [hl]
    and d
    ld l, d
    ld h, [hl]
    and h
    ld h, b
    and e

MusicSequenceData_7705:
    ld h, [hl]
    ld h, b
    and e
    ld e, h
    and d
    ld h, b
    ld e, h
    and e
    ld e, b
    and d
    ld d, d
    ld c, [hl]
    and l
    ld h, [hl]
    xor b
    ld h, [hl]
    and e
    ld h, b
    and l
    ld h, [hl]
    ld bc, $52a8
    and e
    ld e, b
    and h
    ld e, h
    ld e, b
    xor b
    ld d, d
    and e
    ld c, [hl]
    and h
    ld c, b
    and e
    ld b, h
    ld b, b
    xor b
    ld b, h

MusicSequenceData_772c:
    and e
    ld c, b
    and h
    ld c, [hl]
    ld d, d
    and l
    ld e, b
    ld bc, $a800
    ld b, h
    and e

MusicSequenceData_7738:
    ld c, b
    and h
    ld c, [hl]
    and e
    ld c, [hl]
    and d
    ld d, d
    ld c, [hl]

MusicSequenceData_7740:
    and h
    ld c, b
    and e
    ld c, [hl]
    ld c, b
    and e
    ld b, h
    and d
    ld c, b
    ld b, h
    and e
    ld b, b
    and d
    ld a, [hl-]
    ld [hl], $a5
    ld c, [hl]
    xor b
    ld c, [hl]
    and e
    ld c, b
    and l
    ld c, [hl]
    ld bc, $52a8
    and e
    ld e, b
    and h
    ld e, h
    ld e, b
    xor b
    ld d, d
    and e
    ld c, [hl]
    and h
    ld c, b
    and e
    ld b, h
    ld b, b
    xor b
    ld b, h
    and e
    ld c, b
    and h
    ld c, [hl]
    ld d, d
    and l
    ld e, b
    ld bc, $a300
    ld e, $a2
    ld [hl], $2c
    and e
    ld e, $36
    and e
    ld e, $a2
    ld [hl], $2c
    and e
    ld e, $36
    and e
    ld a, [de]
    and d
    ld [hl-], a
    jr z, MusicSequenceData_772c

    ld a, [de]
    ld [hl-], a
    and e
    ld a, [de]
    and d
    ld [hl-], a
    jr z, @-$5b

    ld a, [de]
    ld [hl-], a
    and e
    jr nc, MusicSequenceData_7738

    ld c, b
    ld h, $a3
    jr nc, PaddingZone_003_77e3

    and e
    jr nc, MusicSequenceData_7740

    ld c, b
    ld h, $a3
    jr nc, PaddingZone_003_77eb

    and e
    ld e, $a2
    ld [hl], $2c
    and e
    ld e, $36
    and e
    ld e, $a2
    ld [hl], $2c
    and e
    ld e, $36
    and l
    ld [hl+], a
    ld [hl+], a
    ld a, [de]
    ld a, [de]
    ld e, $1e
    ld [hl+], a
    ld [hl+], a

MusicSequenceData_77bc:
    nop
    and e
    ld b, $a2
    ld b, $06
    and e
    dec bc
    and d
    ld b, $06
    and e
    ld b, $a2
    ld b, $06
    and e
    dec bc
    and d
    ld b, $06
    nop
    dec c
    ld a, b
    ld b, e
    ld a, b
    ld c, e
    ld a, c
    rst $38
    rst $38
    call nc, $fa77
    ld [hl], a
    add a
    ld a, b
    rla
    ld a, c
    rst $38

PaddingZone_003_77e3:
    rst $38
    sbc $77
    ld a, [de]
    ld a, b
    di
    ld a, b
    di

PaddingZone_003_77eb:
    ld a, b
    ld a, b
    ld a, c
    rst $38
    rst $38
    add sp, $77
    dec hl
    ld a, b
    xor b
    ld a, c
    rst $38
    rst $38
    db $f4
    ld [hl], a
    sbc l
    sub d
    nop
    add b
    and d
    ld d, d
    ld bc, $0150
    ld c, [hl]
    ld c, d
    ld bc, $0101
    and a
    ld b, b
    and h
    jr z, PaddingZone_003_780d

PaddingZone_003_780d:
    sbc l
    ld h, d
    nop
    add b
    and l
    ld bc, $01a2
    and a
    jr z, MusicSequenceData_77bc

    stop
    sbc l
    scf
    ld [hl], b
    jr nz, @-$5c

    ld [hl], b
    ld bc, $016e
    ld l, h
    ld l, d
    ld bc, $a401
    ld bc, $0040
    and [hl]
    ld b, $a1
    ld b, $a3
    dec bc
    and [hl]
    ld b, $a1
    ld b, $a3
    dec bc
    and d
    ld bc, $0106
    ld bc, $0ba6
    and c
    ld b, $a3
    ld b, $00
    and e
    ld bc, $013a
    ld a, [hl-]
    ld bc, $013a
    ld a, [hl-]
    ld bc, $013a
    ld a, [hl-]
    ld bc, $013a
    ld a, [hl-]
    ld bc, HeaderDestinationCode
    ld c, d
    ld bc, HeaderDestinationCode
    ld c, d
    and l
    ld bc, $01a3
    ld l, [hl]
    and h
    ld l, [hl]
    and e
    ld bc, $013a
    ld a, [hl-]
    ld bc, $013a
    ld a, [hl-]
    ld bc, $013a
    ld a, [hl-]
    ld bc, $013a
    ld a, [hl-]
    ld bc, HeaderDestinationCode
    ld c, d

AudioDataProcessor:
    ld bc, HeaderDestinationCode
    ld c, d
    and l
    ld bc, $01a6
    and c
    ld l, [hl]
    and e
    ld bc, $56a4
    nop
    and e
    ld d, d
    ld bc, $4ea6
    and c
    ld c, d
    and [hl]
    ld bc, $52a1
    xor b
    ld bc, $4aa6
    and c
    ld c, [hl]
    and d
    ld d, d
    ld bc, $0152

MusicSequenceData_789d:
    and e
    ld c, [hl]
    ld c, d
    ld d, d
    ld d, h
    ld e, b
    ld e, h
    ld bc, $4a4a
    ld b, h
    ld b, b
    and [hl]
    ld bc, $4aa1
    and h
    ld bc, $3ca3
    ld b, b
    ld b, h
    ld c, b
    and e
    ld bc, $a470
    ld [hl], b
    and e
    ld d, d
    ld bc, $4ea6
    and c
    ld c, d
    and [hl]
    ld bc, $52a1
    xor b
    ld bc, $4aa6
    and c
    ld c, [hl]
    and d
    ld d, d
    ld bc, $0152
    and e
    ld c, [hl]
    ld c, d
    ld e, h
    ld e, b
    ld h, d
    and [hl]
    ld d, d
    and c
    ld c, [hl]
    and e
    ld bc, $4a4a
    ld c, [hl]
    ld d, d
    and [hl]
    ld bc, $4aa1
    and h
    ld bc, $54a3
    ld d, d
    ld c, d
    ld c, [hl]
    and [hl]
    ld bc, $70a1
    and e
    ld bc, $58a4
    nop
    and e
    ld [hl-], a
    and [hl]
    ld e, b
    and c
    jr z, MusicSequenceData_789d

    ld [hl-], a
    ld e, b
    ld [hl-], a
    ld e, d
    ld [hl-], a
    ld e, d
    ld [hl-], a
    ld e, h
    ld [hl-], a
    ld e, h
    ld [hl-], a
    ld e, [hl]
    ld b, h
    ld e, [hl]
    inc a
    ld e, h
    inc a
    ld e, h
    ld a, [hl-]
    ld e, b
    ld a, [hl-]
    ld e, b
    ld c, [hl]
    ld d, d
    ld d, h
    ld d, [hl]
    and l
    ld bc, $a300
    ld bc, $605c
    ld h, d
    and e
    ld h, b
    and [hl]
    ld bc, $58a1
    and h
    ld bc, $54a3
    ld bc, $58a6
    and c
    ld d, h
    and e
    ld bc, $52a2
    ld bc, $0154
    ld d, [hl]
    ld bc, $0158
    and e
    ld bc, $605c
    ld h, d
    and e
    ld h, b
    and [hl]
    ld bc, $58a1
    and h
    ld bc, $68a3
    ld h, [hl]
    ld bc, $a562
    ld bc, $a300
    ld bc, $4e4a
    ld b, h
    ld c, [hl]
    and [hl]
    ld b, b
    and c
    ld c, b
    and e
    ld bc, $4440
    inc a
    and [hl]
    ld c, b
    and c
    ld b, h
    and e
    ld [hl], $a5
    ld bc, $01a3
    ld c, d
    ld c, [hl]
    ld b, h
    ld c, [hl]
    and [hl]
    ld b, b
    and c
    ld c, b
    and e
    ld bc, $3240
    ld [hl-], a
    ld bc, $0132
    ld bc, $0101
    nop
    and e
    inc a
    ld c, d
    inc a
    ld c, d
    ld a, [hl-]
    ld c, d
    ld a, [hl-]
    ld c, d
    ld [hl], $5c
    ld [hl], $5c
    and d
    ld c, d
    ld bc, HeaderGlobalChecksum
    ld d, b
    ld bc, $0152
    and e
    inc a
    ld c, d
    inc a
    ld c, d
    ld a, [hl-]
    ld c, d
    ld a, [hl-]
    ld c, d
    ld b, d
    ld d, b
    ld b, d
    ld d, b
    and c
    ld e, b
    ld bc, $0158
    and d
    ld d, h
    ld bc, $0152
    ld c, [hl]
    ld bc, $a300
    ld b, $a6
    ld b, $a1
    ld b, $a3
    dec bc
    and [hl]
    ld b, $a1
    ld b, $a3
    ld b, $a6
    ld b, $a1
    ld b, $a3
    dec bc
    and [hl]
    ld b, $a1
    ld b, $00
    nop
    ld l, [hl]
    ld [hl], b
    pop bc
    ld a, l
    rst $00
    ld a, l
    nop
    nop
    call CheckWindowEnable
    ld [hl], a
    ld [hl], b
    ld h, d
    ld a, l
    ld h, [hl]
    ld a, l
    ld l, b
    ld a, l
    nop
    nop
    nop
    ld h, d
    ld [hl], b
    db $10
    ld a, l
    ld d, $7d
    inc e
    ld a, l
    ld [hl+], a
    ld a, l
    nop
    ld h, d
    ld [hl], b
    rla
    ld a, h
    dec l
    ld a, h
    ld b, c
    ld a, h
    ld b, l
    ld a, h
    nop
    ld d, a
    ld [hl], b
    or d
    ld a, e
    nop
    nop
    or [hl]
    ld a, e
    nop
    nop
    nop
    ld h, d
    ld [hl], b
    add sp, $7b
    db $ec
    ld a, e
    nop
    nop
    nop
    nop
    nop
    add d
    ld [hl], b
    ld b, c
    ld a, e
    ld c, e
    ld a, e
    nop
    nop
    nop
    nop
    nop
    add d
    ld [hl], b
    rst $38
    ld a, d
    inc bc
    ld a, e
    dec b
    ld a, e
    nop
    nop

PaddingZone_003_7a19:
    nop
    ld [hl], a
    ld [hl], b
    rst $00
    ld a, d
    call $007a
    nop
    nop
    nop
    nop
    ld [hl], a
    ld [hl], b
    cpl
    ld a, d
    scf
    ld a, d
    ccf
    ld a, d
    ld b, a
    ld a, d
    ld c, l
    ld a, d
    sub d
    ld a, d
    rst $38
    rst $38
    ld sp, $5e7a
    ld a, d
    and a
    ld a, d
    rst $38
    rst $38
    add hl, sp
    ld a, d
    ld l, a
    ld a, d
    or l
    ld a, d
    rst $38
    rst $38
    ld b, c
    ld a, d
    add b
    ld a, d
    rst $38
    rst $38
    ld b, a
    ld a, d
    sbc l
    sub b
    nop
    nop
    and l
    ld bc, $201e
    and h
    ld [hl+], a
    inc h
    and e
    ld h, $28
    ld a, [hl+]
    inc l
    nop
    sbc l
    and b
    nop
    nop
    and l
    ld bc, $1210
    and h
    inc d
    ld d, $a3
    jr PaddingZone_003_7a86

    inc e
    ld e, $00
    sbc l
    scf
    ld [hl], b
    jr nz, PaddingZone_003_7a19

    ld bc, $2a28
    and h
    inc l
    ld l, $a3
    jr nc, PaddingZone_003_7aaf

    inc [hl]
    ld [hl], $00
    and c
    ld b, $06
    ld b, $06
    dec bc

PaddingZone_003_7a86:
    ld b, $06
    ld b, $06
    ld b, $06
    ld b, $0b
    ld b, $06
    ld b, $00
    sbc l
    ld h, b
    nop
    pop bc
    and h
    ld e, $2a
    jr z, DispatchDataZone_7acf

    and l
    ld [hl-], a
    ld bc, $1ea4
    ld a, [hl+]
    jr z, PaddingZone_003_7ad7

    and l
    ld [hl], $01
    nop
    sbc l
    add e
    nop
    nop
    and d
    db $10
    ld c, $0c

PaddingZone_003_7aaf:
    ld a, [bc]
    ld [$0406], sp
    ld [bc], a
    nop
    and c
    jr z, @+$42

    ld h, $3e
    inc h
    inc a
    ld [hl+], a
    ld a, [hl-]
    jr nz, @+$3a

    ld e, $36
    inc e
    inc [hl]
    ld a, [de]
    ld [hl-], a
    nop
    db $d3
    ld a, d
    rst $38
    rst $38
    rst $00
    ld a, d
    jp hl


    ld a, d

DispatchDataZone_7acf:
    rst $38
    rst $38
    call $9d7a
    add h
    nop
    add b

PaddingZone_003_7ad7:
    and d
    ld b, b
    ld b, d
    ld b, b
    ld b, d
    ld b, b
    ld b, d
    ld b, b
    ld b, d
    ld b, b
    ld b, [hl]
    ld c, h
    ld d, d
    ld e, b
    ld d, d
    ld c, h
    ld b, [hl]
    nop
    sbc l
    ld [hl], h
    nop
    add b
    and d
    db $10
    ld [de], a
    db $10
    ld [de], a
    db $10
    ld [de], a
    db $10
    ld [de], a
    ld [hl+], a
    jr z, PaddingZone_003_7b27

    inc [hl]
    ld a, [hl-]
    inc [hl]
    ld l, $28
    nop
    rlca
    ld a, e
    nop
    nop
    ld hl, $347b
    ld a, e
    sbc l
    ld h, b
    nop
    add c
    and e
    inc a
    ld c, d
    ld d, h
    ld c, d
    ld b, b
    ld c, d
    inc a
    ld a, [hl-]
    ld a, [hl+]
    sbc l
    jr nc, PaddingZone_003_7b18

PaddingZone_003_7b18:
    add c
    and c
    ld a, [hl-]
    inc a
    ld a, [hl-]
    ld [hl], $a4
    ld a, [hl-]
    nop
    sbc l
    add b
    nop
    add c
    and e
    ld b, h

PaddingZone_003_7b27:
    ld c, d
    ld e, h
    and h
    ld e, b
    and e
    ld d, d
    and h
    ld c, d
    and e
    ld c, [hl]
    and l
    ld c, d
    nop
    sbc l
    scf
    ld [hl], b
    ld hl, $54a8
    ld d, d
    and h
    ld b, d
    and e
    inc a
    and l
    ld [hl-], a
    ld d, e
    ld a, e
    ld [hl], c
    ld a, e
    ld d, e
    ld a, e
    ld a, d
    ld a, e
    nop
    nop
    add d
    ld a, e
    and c
    ld a, e
    add d
    ld a, e
    xor d
    ld a, e
    sbc l
    ld h, [hl]
    nop
    add c
    and e
    ld e, b
    ld h, b
    ld h, [hl]
    ld h, b
    ld d, [hl]
    ld h, b
    ld h, [hl]
    ld h, b
    ld d, h
    ld h, b
    ld h, [hl]
    ld h, b
    ld d, d
    ld e, b
    ld h, d
    ld e, b
    ld d, b
    ld e, b
    ld h, d
    ld e, b
    ld c, [hl]
    ld e, b
    ld h, b
    ld e, b
    nop
    ld c, h
    ld d, d
    ld e, b
    ld e, h
    ld e, b
    ld c, d
    ld d, [hl]
    ld c, [hl]
    nop
    ld d, d
    ld e, b
    ld e, h
    ld d, [hl]
    and h
    ld h, b
    ld b, b
    nop
    sbc l
    ld h, [hl]
    nop
    add c
    and h
    ld a, b
    and e
    ld [hl], h
    ld [hl], b
    xor b
    ld a, b
    and d
    ld [hl], b
    ld [hl], h
    and e
    ld a, b
    ld a, b
    ld [hl], h
    ld [hl], b
    ld a, b
    ld a, d
    ld a, [hl]
    add d
    ld bc, $7070
    ld l, b
    and h
    ld h, [hl]
    ld a, b
    nop
    and e
    ld l, d
    ld [hl], b
    ld [hl], h
    ld a, b
    and h
    ld [hl], h
    ld h, [hl]
    nop
    and e
    ld a, d
    ld l, d
    ld l, [hl]
    ld h, [hl]
    and l
    ld [hl], b
    nop
    cp b
    ld a, e
    nop
    nop
    jp z, $9d7b

    ld d, b
    nop
    add b
    and c
    ld b, b
    ld bc, $0140
    ld b, b
    ld bc, $42a3
    and d
    ld b, [hl]
    and h
    ld c, d
    nop
    sbc l
    rla
    ld [hl], b
    and b
    and d
    ld a, b
    ld a, b
    ld a, b
    and e
    ld a, d
    and d
    ld a, [hl]
    and c
    add d
    ld [hl], b
    add d
    ld [hl], b
    add d
    ld [hl], b
    add d
    ld [hl], b
    add d
    ld [hl], b
    add d
    ld [hl], b
    add d
    ld [hl], b
    add d
    ld [hl], b
    nop
    xor $7b
    nop
    nop
    inc bc
    ld a, h
    sbc l
    ld [hl], e
    nop
    add b
    and e
    ld e, $a1
    ld bc, $1ea3
    and c
    ld bc, $1ea3
    and c
    ld bc, $1ea3
    and c
    ld bc, $9d00
    db $d3
    nop
    ret nz

    and e
    inc e
    and c
    ld bc, $1ca3
    and c
    ld bc, $1ca3
    and c
    ld bc, $1ca3
    and c
    ld bc, $7c4b
    ld d, d
    ld a, h
    ld l, h
    ld a, h
    ld d, d
    ld a, h
    ld l, a
    ld a, h
    ld c, e
    ld a, h
    ld d, d
    ld a, h
    ld l, h
    ld a, h
    ld d, d
    ld a, h
    ld l, a
    ld a, h
    nop
    nop
    halt
    ld a, h
    ld a, l
    ld a, h
    sub l
    ld a, h
    ld a, l
    ld a, h
    sbc [hl]
    ld a, h
    halt
    ld a, h
    ld a, l
    ld a, h
    sub l
    ld a, h
    ld a, l
    ld a, h
    sbc [hl]
    ld a, h
    and l
    ld a, h
    and l
    ld a, h
    db $eb
    ld a, h
    rst $38
    rst $38
    ld b, l
    ld a, h
    sbc l
    sub e

AudioData_003_7c4d:
    nop
    add b
    and e
    ld bc, $a200
    ld bc, HeaderDestinationCode
    ld c, d
    ld bc, HeaderDestinationCode
    ld c, d
    ld bc, HeaderDestinationCode
    ld c, d
    ld bc, HeaderDestinationCode
    ld c, d
    ld bc, $0140
    ld b, b
    ld bc, $0140
    ld b, b
    nop
    and l
    ld bc, $0100
    ld c, d
    ld bc, $4a4a
    ld bc, $9d00
    jp $c000


    and e
    jr c, JoypadInputEntry_7c7d

JoypadInputEntry_7c7d:
    and h
    ld b, d
    and d
    ld b, [hl]
    ld c, h
    ld c, d
    ld b, [hl]
    and e
    ld d, b
    ld d, b
    and d
    ld d, b
    ld d, h
    ld c, d
    ld c, h
    and e
    ld b, [hl]
    ld b, [hl]
    and d
    ld b, [hl]
    ld c, h
    ld c, d
    ld b, [hl]
    nop
    ld b, d
    ld e, d
    ld e, b
    ld d, h
    ld d, b
    ld c, h
    ld c, d
    ld b, [hl]
    nop
    ld b, d
    ld d, b
    ld b, [hl]
    ld c, d
    ld b, d
    ld bc, $9d00
    rla
    ld [hl], b
    jr nz, AudioData_003_7c4d

    ld bc, $42a2
    ld d, b
    jr c, @+$52

    ld b, d
    ld d, b
    jr c, @+$52

    ld b, d
    ld d, b
    jr c, PaddingZone_003_7d08

    ld b, d
    ld d, b
    jr c, PaddingZone_003_7d0c

    jr c, PaddingZone_003_7d1c

    ld b, [hl]
    ld e, [hl]
    jr c, AudioDispatchEntry_003_7d20

    ld b, [hl]
    ld e, [hl]
    ld b, d
    ld e, d
    ld e, b
    ld d, h
    ld d, b
    ld c, h
    ld c, d
    ld b, [hl]
    ld b, d
    ld d, b
    jr c, AudioDispatchEntry_003_7d20

    ld b, d
    ld d, b
    jr c, AudioDispatchEntry_003_7d24

    ld b, d
    ld d, b
    jr c, AudioDispatchEntry_003_7d28

    ld b, d
    ld d, b
    jr c, PaddingZone_003_7d2c

    jr c, JoypadInputEntry_7d3c

    ld b, [hl]
    ld e, [hl]
    jr c, PaddingZone_003_7d40

    ld b, [hl]
    ld e, [hl]
    ld b, d
    ld d, b
    jr c, PaddingZone_003_7d38

    ld b, d
    ld bc, $a300
    ld bc, $06a2
    dec bc
    ld b, $0b
    ld b, $0b
    dec bc
    dec bc
    ld b, $0b
    ld b, $0b
    ld b, $a1
    dec bc
    dec bc
    and d
    ld b, $0b
    ld b, $0b
    ld b, $0b
    ld b, $0b
    dec bc

PaddingZone_003_7d08:
    dec bc
    dec bc
    ld b, $0b

PaddingZone_003_7d0c:
    ld b, $0b
    ld bc, $3400
    ld a, l
    rst $38
    rst $38
    db $10
    ld a, l
    jr z, PaddingZone_003_7d95

    rst $38
    rst $38
    ld d, $7d

PaddingZone_003_7d1c:
    ld b, b
    ld a, l
    rst $38
    rst $38

AudioDispatchEntry_003_7d20:
    inc e
    ld a, l
    ld d, l
    ld a, l

AudioDispatchEntry_003_7d24:
    rst $38
    rst $38
    ld [hl+], a
    ld a, l

AudioDispatchEntry_003_7d28:
    sbc l
    ld d, h
    nop
    add b

PaddingZone_003_7d2c:
    and d
    ld d, b
    ld c, [hl]
    ld c, h
    ld c, d
    ld c, b
    ld b, [hl]
    nop
    sbc l
    inc [hl]
    nop
    add b

PaddingZone_003_7d38:
    and d

PaddingZone_003_7d39:
    ld a, [hl-]
    jr c, PaddingZone_003_7d72

JoypadInputEntry_7d3c:
    inc [hl]
    ld [hl-], a
    jr nc, PaddingZone_003_7d40

PaddingZone_003_7d40:
    sbc l
    rla
    ld [hl], b
    jr nz, @-$56

    ld b, h
    and a
    ld b, h
    ld c, d
    xor b
    ld d, b
    ld d, b
    xor b
    ld b, h
    and a
    ld b, h
    ld c, d
    xor b
    ld d, b
    ld d, b
    nop
    and d
    ld b, $06
    ld b, $a7
    dec bc
    and d
    ld b, $06
    ld b, $a7
    dec bc
    nop
    ld a, l
    ld a, l
    nop
    nop
    ld l, d
    ld a, l
    sub d
    ld a, l
    sbc l
    pop de
    nop
    add b
    and a
    ld [hl-], a
    ld [hl], $3a

PaddingZone_003_7d72:
    inc a
    ld b, b
    ld b, h
    ld c, b
    ld c, d
    ld c, [hl]
    ld d, d
    ld d, h
    ld e, b
    ld e, h
    nop
    sbc l
    ld b, c
    nop
    add b
    xor d
    ld bc, $32a7
    ld [hl], $3a
    inc a
    ld b, b
    ld b, h
    ld c, b
    ld c, d
    ld c, [hl]
    ld d, d
    ld d, h
    ld e, b
    ld e, h
    nop
    sbc l
    scf
    ld [hl], b

PaddingZone_003_7d95:
    jr nz, PaddingZone_003_7d39

    ld c, d
    ld bc, $4e52
    ld bc, $5254
    ld bc, $5458
    ld bc, $585c
    ld bc, $5c60
    ld bc, $6062
    ld bc, $6266
    ld bc, $666a
    ld bc, $6a6c
    ld bc, $6c70
    ld bc, $7074
    ld bc, $7478
    ld bc, $787a
    ld bc, $d37e
    ld a, l
    rst $38
    rst $38
    pop bc
    ld a, l
    ld sp, hl
    ld a, l
    rst $38
    rst $38
    rst $00
    ld a, l
    ccf
    ld a, [hl]
    rst $38
    rst $38
    call $9d7d
    sub c
    nop
    add b
    and d
    ld b, b
    ld c, [hl]
    ld b, b
    ld c, [hl]
    ld b, b
    ld c, [hl]
    ld b, b
    ld c, [hl]
    ld b, h
    ld d, d
    ld b, h
    ld c, [hl]
    ld b, h
    ld d, d
    ld b, h
    ld c, [hl]
    ld c, d
    ld e, b
    ld c, d
    ld e, b
    ld c, d
    ld e, b
    ld c, d
    ld e, b
    ld c, [hl]
    ld c, [hl]
    ld c, d
    ld c, d
    ld c, b
    ld c, b
    ld b, h
    ld b, h
    nop
    sbc l
    sub c
    nop
    add b
    and c
    ld h, b

AudioStateUpdate:
    ld h, [hl]
    ld [hl], b
    ld h, b
    ld h, [hl]
    ld [hl], b
    ld h, b
    ld h, [hl]
    ld [hl], b
    ld h, b
    ld h, [hl]
    ld [hl], b
    ld h, b
    ld h, [hl]
    ld [hl], b
    ld bc, $645c
    ld [hl], b
    ld e, h
    ld h, h
    ld [hl], b
    ld e, h
    ld h, h
    ld [hl], b
    ld e, h
    ld h, h
    ld [hl], b
    ld e, h
    ld h, h
    ld [hl], b
    ld bc, $6a62
    ld [hl], b
    ld h, d
    ld l, d
    ld [hl], b
    ld h, d
    ld l, d
    ld [hl], b
    ld h, d
    ld l, d
    ld [hl], b
    ld h, d
    ld l, d
    ld [hl], b
    ld bc, $5c6e
    ld l, [hl]
    ld e, h
    ld l, d
    ld [hl], b
    ld l, d
    ld e, b
    ld h, [hl]
    ld d, [hl]
    ld h, [hl]
    ld d, [hl]
    ld h, d
    ld l, d
    ld h, d
    ld d, d
    nop
    and d
    ld b, $a1
    ld b, $06
    and d
    ld b, $a1
    ld b, $06
    and d
    ld b, $a1
    ld b, $06
    nop
    nop
    ld [hl], a
    ld [hl], b
    ld e, d
    ld a, [hl]
    ld l, b
    ld a, [hl]
    halt
    ld a, [hl]
    sub b
    ld a, [hl]
    sbc [hl]
    ld a, [hl]
    xor d
    ld a, [hl]
    call z, $cc7e
    ld a, [hl]
    ld sp, hl
    ld a, [hl]
    rst $38
    rst $38
    ld e, [hl]
    ld a, [hl]
    and l
    ld a, [hl]
    xor d
    ld a, [hl]
    call z, $cc7e
    ld a, [hl]
    ld sp, hl
    ld a, [hl]
    rst $38
    rst $38
    ld l, h
    ld a, [hl]
    inc h
    ld a, a
    add hl, hl
    ld a, a
    add hl, hl
    ld a, a
    dec sp
    ld a, a
    dec sp
    ld a, a
    ld c, h
    ld a, a
    ld c, h
    ld a, a
    ld l, [hl]
    ld a, a
    adc b
    ld a, a
    ld l, [hl]
    ld a, a
    sub c
    ld a, a
    rst $38
    rst $38
    add b
    ld a, [hl]
    or d
    ld a, a
    or d
    ld a, a
    or d
    ld a, a
    or d
    ld a, a
    db $db
    ld a, a
    rst $38
    rst $38
    sbc b
    ld a, [hl]
    sbc l
    jr nc, PaddingZone_003_7ea1

PaddingZone_003_7ea1:
    add c
    xor d
    ld bc, $9d00
    sub b
    nop
    add c
    nop
    and e
    ld c, h
    ld a, [hl-]
    ld b, h
    ld c, h
    ld d, b
    ld a, $48
    ld d, b
    ld d, d
    ld b, b
    ld c, d
    ld d, d
    ld d, [hl]
    ld b, h
    ld c, [hl]
    ld d, [hl]
    ld e, d
    ld c, b
    ld d, d
    ld e, d
    ld e, h
    ld c, d
    ld d, d
    ld e, h
    ld e, d
    ld c, b
    ld d, d
    ld e, d
    ld e, h
    ld c, d
    ld d, d
    ld e, h
    nop
    and d
    ld e, d
    ld bc, $5201
    ld bc, $4801
    ld bc, $5601
    ld bc, $015c
    ld e, d
    ld d, [hl]
    and l
    ld d, d
    ld bc, $01a2
    and d
    ld e, d
    ld bc, $5201
    ld bc, $4801
    ld bc, $52a4
    and d
    ld bc, $5250
    and h
    ld d, [hl]
    and d
    ld bc, $4ca4
    ld d, b
    ld bc, $a800
    ld d, d
    and d
    ld d, b
    ld d, d
    and h
    ld d, [hl]
    ld c, b
    xor b
    ld e, d
    and d
    ld d, [hl]
    ld e, d
    and e
    ld e, h
    ld c, h
    ld d, d
    ld d, b
    xor b
    ld d, d
    and d
    ld d, b
    ld d, d
    and h
    ld d, [hl]
    ld c, b
    xor b
    ld e, d
    and d
    ld d, [hl]
    ld e, d
    and e
    ld h, b
    ld c, d
    ld d, d
    ld e, b
    and h
    ld e, h
    ld h, d
    and l
    ld e, d
    ld d, [hl]
    nop
    sbc l
    scf
    ld [hl], b
    and b
    nop
    and d
    ld b, h
    ld b, h
    ld e, h
    ld e, h
    ld b, h
    ld b, h
    ld e, h
    ld e, h
    ld b, h
    ld b, h
    ld e, h
    ld e, h
    ld b, h
    ld b, h
    ld e, h
    ld e, h
    nop
    ld a, [hl-]
    ld a, [hl-]
    ld d, d
    ld d, d
    ld a, [hl-]
    ld a, [hl-]
    ld d, d
    ld d, d
    ld a, [hl-]
    ld a, [hl-]
    ld d, d
    ld d, d
    ld a, [hl-]
    ld a, [hl-]
    ld d, d
    ld d, d
    nop
    and e
    ld d, d
    ld d, d
    ld d, d
    ld d, d
    ld d, b
    ld d, b
    ld d, b
    ld d, b
    ld c, [hl]
    ld c, [hl]
    ld c, [hl]
    ld c, [hl]
    ld c, h
    ld c, h
    ld c, h
    ld c, h
    ld b, h
    ld b, h
    ld b, h
    ld b, h
    ld b, d
    ld b, d
    ld b, d
    ld b, d
    ld a, $3e
    ld a, $3e
    ld c, b
    ld c, b
    ld c, b
    ld c, b
    nop
    and d
    inc l
    inc l
    ld b, h
    ld b, h
    inc l
    inc l
    ld b, h
    ld b, h
    inc l
    inc l
    ld b, h
    ld b, h
    inc l
    inc l
    ld b, h
    ld b, h
    ld a, [hl+]
    ld a, [hl+]
    ld b, d
    ld b, d
    ld a, [hl+]
    ld a, [hl+]
    ld b, d
    ld b, d
    nop
    ld h, $26
    ld a, $3e
    jr nc, @+$32

    ld c, b
    ld c, b
    nop
    jr z, AudioDispatchData_003_00

    ld b, b
    ld b, b
    jr z, AudioDispatchData_003_01

    ld b, b
    ld b, b
    jr z, @+$2a

    ld b, b
    ld b, b
    jr z, AudioDispatchData_003_02

    ld b, b
    ld b, b
    jr nc, AudioDispatchData_003_03

    ld a, [hl-]
    ld b, d
    jr nc, @+$32

    ld a, [hl-]
    ld b, d
    jr nc, PaddingZone_003_7fdb

    jr c, PaddingZone_003_7feb

    jr nc, PaddingZone_003_7fdf

    jr c, PaddingZone_003_7fef

    nop
    and c
    ld b, $06
    and d
    dec bc
    and c
    ld b, $06
    and d

AudioDispatchData_003_00:
    dec bc
    and c
    ld b, $06

AudioDispatchData_003_01:
    and d
    dec bc
    and c
    ld b, $06
    and d
    dec bc
    and c

AudioDispatchData_003_02:
    ld b, $06
    and d
    dec bc
    and c
    ld b, $06
    and d
    dec bc
    and c
    ld b, $06

AudioDispatchData_003_03:
    and d
    dec bc
    and c
    ld b, $06
    and d
    dec bc
    nop

PaddingZone_003_7fdb:
    and d
    ld b, $06
    db $10

PaddingZone_003_7fdf:
    ld b, $06
    ld b, $10
    ld b, $06
    ld b, $10
    ld b, $06
    ld b, $10

PaddingZone_003_7feb:
    ld b, $00
    rst $38
    rst $38

PaddingZone_003_7fef:
    rst $38

; Routine $7ff0 - Point d'entrée audio (trampoline vers ProcessAudioSnapshot)
AudioEntryPoint::
    jp ProcessAudioSnapshot


    jp ResetAllAudioChannels


    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
