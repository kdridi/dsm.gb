SECTION "ROM Bank $000", ROM0[$0]

RST_00::
    jp Jump_000_0185


    rst $38
    rst $38
    rst $38
    nop
    nop

RST_08::
    jp Jump_000_0185


    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

RST_10::
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

RST_18::
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

RST_20::
    rst $38
    rst $38
    rst $38
    rst $38

Jump_000_0024:
    rst $38
    rst $38
    rst $38
    rst $38

RST_28::
    add a
    pop hl
    ld e, a
    ld d, $00
    add hl, de
    ld e, [hl]
    inc hl

RST_30::
    ld d, [hl]
    push de
    pop hl
    jp hl


    rst $38
    rst $38
    rst $38
    rst $38

RST_38::
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

VBlankInterrupt::
    jp JoypadTransitionInterrupt


    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

LCDCInterrupt::
    jp Jump_000_0095


    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

TimerOverflowInterrupt::
    push af
    ld a, $03

Call_000_0053:
    ld [$2000], a
    db $cd
    db $f0

SerialTransferCompleteInterrupt::
    ld a, a
    ldh a, [$fffd]
    ld [$2000], a
    pop af
    reti


;; ==========================================================================
;; VBlankHandler - Handler d'interruption VBlank
;; ==========================================================================
;; Appelé 60 fois par seconde pendant le VBlank.
;; Structure :
;;   1. SaveRegisters      → push af/bc/de/hl
;;   2. UpdateGameLogic    → Appels aux routines de mise à jour
;;   3. DMATransfer        → call $FFB6 (routine en HRAM)
;;   4. IncrementFrame     → $FFAC++
;;   5. CheckWindowEnable  → Active Window si game_state == $3A
;;   6. ResetScrollAndFlag → SCX/SCY = 0, frame_ready = 1
;;   7. RestoreRegisters   → pop + reti
;; ==========================================================================
JoypadTransitionInterrupt::
    ; --- 1. SaveRegisters ---
    push af
    push bc
    push de
    push hl

    ; --- 2. UpdateGameLogic ---
    ; Note: db $cd est probablement un CALL mal désassemblé
    call Call_000_224f
    db $cd

    ld a, l
    dec de
    call Call_000_1c2a

    ; --- 3. DMATransfer ---
    call $ffb6              ; Routine OAM DMA copiée en HRAM

    ; --- UpdateGameLogic (suite) ---
    call Call_000_3f24
    call Call_000_3d61
    call Call_000_23f8

    ; --- 4. IncrementFrame ---
    ld hl, $ffac
    inc [hl]                ; frame_counter++

    ; --- 5. CheckWindowEnable ---
Call_000_007d:
    ldh a, [$ffb3]          ; Lire game_state
    cp $3a                  ; État spécial $3A ?
    jr nz, jr_000_0088      ; Non → sauter

    ld hl, $ff40            ; rLCDC
    set 5, [hl]             ; Activer le Window (bit 5)

    ; --- 6. ResetScrollAndFlag ---
jr_000_0088:
    xor a
    ldh [rSCX], a           ; Scroll X = 0
    ldh [rSCY], a           ; Scroll Y = 0
    inc a                   ; A = 1
    ldh [$ff85], a          ; frame_ready = 1 → réveille la game loop

    ; --- 7. RestoreRegisters ---
    pop hl
    pop de
    pop bc
    pop af
    reti                    ; Retour d'interruption


Jump_000_0095:
    push af
    push hl

jr_000_0097:
    ldh a, [rSTAT]
    and $03
    jr nz, jr_000_0097

    ld a, [$c0a5]
    and a
    jr nz, jr_000_00cf

    ldh a, [$ffa4]
    ldh [rSCX], a
    ld a, [$c0de]
    and a
    jr z, jr_000_00b2

    ld a, [$c0df]
    ldh [rSCY], a

jr_000_00b2:
    ldh a, [$ffb3]
    cp $3a
    jr nz, jr_000_00cc

    ld hl, $ff4a
    ld a, [hl]
    cp $40
    jr z, jr_000_00de

    dec [hl]
    cp $87

Jump_000_00c3:
    jr nc, jr_000_00cc

jr_000_00c5:
    add $08

Call_000_00c7:
    ldh [rLYC], a
    ld [$c0a5], a

jr_000_00cc:
    pop hl

Call_000_00cd:
    pop af
    reti


jr_000_00cf:
    ld hl, $ff40
    res 5, [hl]
    ld a, $0f
    ldh [rLYC], a
    xor a
    ld [$c0a5], a
    jr jr_000_00cc

jr_000_00de:
    push af
    ldh a, [$fffb]
    and a
    jr z, jr_000_00ea

    dec a
    ldh [$fffb], a

jr_000_00e7:
    pop af
    jr jr_000_00c5

jr_000_00ea:
    ld a, $ff
    ld [$c0ad], a
    jr jr_000_00e7

    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

Boot::
    nop
    jp Jump_000_0150


HeaderLogo::
    db $ce, $ed, $66, $66, $cc, $0d, $00, $0b, $03, $73, $00, $83, $00, $0c, $00, $0d
    db $00, $08, $11, $1f, $88, $89, $00, $0e, $dc, $cc, $6e, $e6, $dd, $dd, $d9, $99
    db $bb, $bb, $67, $63, $6e, $0e, $ec, $cc, $dd, $dc, $99, $9f, $bb, $b9, $33, $3e

HeaderTitle::
    db "SUPER MARIOLAND", $00

HeaderNewLicenseeCode::
    db $00, $00

HeaderSGBFlag::
    db $00

HeaderCartridgeType::
    db $01

HeaderROMSize::
    db $01

HeaderRAMSize::
    db $00

HeaderDestinationCode::
    db $00

HeaderOldLicenseeCode::
    db $01

HeaderMaskROMVersion::
    db $00

HeaderComplementCheck::
    db $9e

HeaderGlobalChecksum::
    db $41, $6b

Jump_000_0150:
    jp Jump_000_0185


Call_000_0153:
    call Call_000_3ed1

jr_000_0156:
    ldh a, [rSTAT]
    and $03
    jr nz, jr_000_0156

    ld b, [hl]

jr_000_015d:
    ldh a, [rSTAT]
    and $03
    jr nz, jr_000_015d

    ld a, [hl]
    and b
    ret


Call_000_0166:
    ldh a, [$ff9f]
    and a
    ret nz

    ld a, e
    ld hl, $c0a0
    add [hl]
    daa
    ld [hl+], a
    ld a, d
    adc [hl]
    daa
    ld [hl+], a
    ld a, $00
    adc [hl]
    daa
    ld [hl], a
    ld a, $01
    ldh [$ffb1], a
    ret nc

    ld a, $99
    ld [hl-], a
    ld [hl-], a
    ld [hl], a
    ret


;; ==========================================================================
;; SystemInit - Initialisation complète du système Game Boy
;; ==========================================================================
;; Appelé par : RST_00 (soft reset), Boot ($0150)
;; Entrée    : Aucune
;; Sortie    : Système prêt, LCD OFF, mémoire effacée
;; Modifie   : A, HL, BC, SP, tous les registres hardware
;; ==========================================================================
Jump_000_0185:
    ConfigureInterrupts         ; DI + config VBlank/STAT
    ConfigureLCDStat            ; Mode LYC interrupt
    ResetScroll                 ; SCX/SCY = 0
    WaitVBlankAndDisableLCD     ; Attendre VBlank puis LCD OFF
    ConfigurePalettes           ; BGP, OBP0, OBP1
    EnableAudio                 ; NR50/51/52 = ON + volume max
    SetupStack                  ; SP = $CFFF
    ClearWRAM                   ; $C000-$DFFF = 0
    ClearVRAM                   ; $8000-$9FFF = 0
    ClearOAM                    ; $FE00-$FEFF = 0
    ClearHRAM                   ; $FF80-$FFFE = 0
    CopyVBlankRoutine           ; Copie DMA handler vers $FFB6
    InitGameVariables           ; Variables + bank switch → bank 2

;; ==========================================================================
;; GameLoop - Boucle principale du jeu
;; ==========================================================================
;; Structure :
;;   1. CheckSpecialState  → Vérifie $DA1D == 3 (état spécial ?)
;;   2. CallBank3Logic     → Appelle la logique en bank 3
;;   3. CheckPauseOrSkip   → Vérifie si on doit sauter le frame
;;   4. DecrementTimers    → Décrémente 2 timers en $FFA6-$FFA7
;;   5. HandleGameState    → Gestion état de jeu complexe
;;   6. CallStateHandler   → Appelle le handler d'état (Call_000_02a3)
;;   7. WaitForNextFrame   → HALT + attend flag VBlank
;; ==========================================================================

; --- 1. CheckSpecialState ---
jr_000_0226:
    ld a, [$da1d]           ; Lire état spécial
    cp $03                  ; Est-ce == 3 ?
    jr nz, jr_000_0238      ; Non → sauter

    ld a, $ff               ; Oui → reset à $FF
    ld [$da1d], a
    call Call_000_09e8      ; Appeler routine spéciale
    call Call_000_172d

; --- 2. CallBank3Logic ---
jr_000_0238:
    ldh a, [$fffd]          ; Sauvegarder bank courante
    ldh [$ffe1], a
    ld a, $03               ; Switch vers bank 3
    ldh [$fffd], a
    ld [$2000], a
    call $47f2              ; Appeler logique bank 3
    ldh a, [$ffe1]          ; Restaurer bank
    ldh [$fffd], a
    ld [$2000], a

; --- 3. CheckPauseOrSkip ---
    ldh a, [$ff9f]          ; Flag pause ?
    and a
    jr nz, jr_000_025a      ; Si pause → sauter vers timers

    call Call_000_07c3      ; Vérifier input ?
    ldh a, [$ffb2]          ; Flag skip frame ?
    and a
    jr nz, jr_000_0296      ; Si skip → aller directement au wait

; --- 4. DecrementTimers ---
jr_000_025a:
    ld hl, $ffa6            ; Adresse timer 1
    ld b, $02               ; 2 timers à décrémenter

jr_000_025f:
    ld a, [hl]              ; Lire timer
    and a
    jr z, jr_000_0264       ; Si 0 → ne pas décrémenter

    dec [hl]                ; Décrémenter timer

jr_000_0264:
    inc l                   ; Timer suivant
    dec b
    jr nz, jr_000_025f      ; Boucle 2 fois

; --- 5. HandleGameState ---
    ldh a, [$ff9f]          ; Flag pause ?
    and a
    jr z, jr_000_0293       ; Non → aller au handler

    ldh a, [$ff80]          ; Lire joypad
    bit 3, a                ; Start pressé ?
    jr nz, jr_000_0283      ; Oui → traitement spécial

    ldh a, [$ffac]          ; Frame counter
    and $0f                 ; Modulo 16
    jr nz, jr_000_0293      ; Si != 0 → aller au handler

    ld hl, $c0d7            ; Timer spécial
    ld a, [hl]
    and a
    jr z, jr_000_0283       ; Si 0 → traitement spécial

    dec [hl]                ; Décrémenter
    jr jr_000_0293          ; Aller au handler

jr_000_0283:
    ldh a, [$ffb3]          ; Game state
    and a
    jr nz, jr_000_0293      ; Si != 0 → aller au handler

    ld a, $02               ; Switch vers bank 2
    ld [$2000], a
    ldh [$fffd], a
    ld a, $0e               ; Game state = $0E
    ldh [$ffb3], a

; --- 6. CallStateHandler ---
jr_000_0293:
    call Call_000_02a3      ; Dispatch selon $FFB3 (game state)

; --- 7. WaitForNextFrame ---
jr_000_0296:
    halt                    ; Suspend CPU (économie batterie)
    ldh a, [$ff85]          ; Lire frame_ready flag
    and a
    jr z, jr_000_0296       ; Si 0 → continuer à attendre

    xor a
    ldh [$ff85], a          ; Clear flag
    jr jr_000_0226          ; Retour au début de la game loop

jr_000_02a1:
    jr jr_000_02a1

Call_000_02a3:
    ldh a, [$ffb3]
    rst $28
    db $10
    ld b, $a5
    ld b, $c5
    ld b, $84
    dec bc
    call $6a0b
    inc c
    jp nz, Jump_000_370c

    inc c
    ld b, b
    dec c
    ld [de], a
    ld d, $26
    ld d, $63
    ld d, $d1
    ld d, $6d
    inc hl
    ld [hl+], a
    inc bc
    jp $b704


    dec b
    ld e, a
    dec b
    adc [hl]
    dec a
    adc $3d
    ld [hl-], a
    ld e, b
    dec [hl]
    ld e, b
    sbc [hl]
    ld a, $38
    ld e, b
    dec sp
    ld e, b
    ld a, $58
    ld b, c
    ld e, b
    ldh a, [$ff0d]
    inc c
    ld c, $28
    ld c, $54
    ld c, $8d
    ld c, $a0
    ld c, $c4
    ld c, $09
    rrca
    ld a, [hl+]
    rrca
    ld h, c
    rrca
    db $f4
    rrca
    ld c, h
    db $10
    sub b
    db $10
    and b
    ld c, $0d
    ld de, $115c
    adc e
    ld de, $11c7
    ld [de], a
    ld [de], a
    ld c, e
    ld [de], a
    sbc b
    ld [de], a
    cp c
    ld [de], a
    add sp, $12
    add l
    inc de
    rst $20
    inc de
    jr c, @+$16

    ld d, c
    inc d
    ld e, l
    inc d
    ld a, a
    inc d
    db $d3
    inc d
    ld [hl], e
    inc e
    rst $18
    inc e
    rst $20
    inc e
    inc d
    dec e
    and h
    ld b, $af
    ldh [rLCDC], a
    di
    ldh [$ffa4], a
    ld hl, $c000
    ld b, $9f

jr_000_032d:
    ld [hl+], a
    dec b
    jr nz, jr_000_032d

    ldh [$ff99], a
    ld [$c0a5], a
    ld [$c0ad], a
    ld hl, $c0d8
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld a, [$c0e1]
    ldh [$ff9a], a
    ld hl, $791a
    ld de, $9300
    ld bc, $0500
    call Call_000_05c7
    ld hl, $7e1a
    ld de, $8800
    ld bc, $0170
    call Call_000_05c7
    ld hl, $4862
    ldh a, [$ff9a]
    cp $01
    jr c, jr_000_0368

    ld hl, $4e72

jr_000_0368:
    ld de, $8ac0
    ld bc, $0010
    call Call_000_05c7
    ld hl, $5032
    ld de, $9000
    ld bc, $02c0
    call Call_000_05c7
    ld hl, $5032
    ld de, $8000
    ld bc, $02a0
    call Call_000_05c7
    call Call_000_05b8
    xor a
    ldh [$ffe5], a
    ldh a, [$ffe4]
    push af
    ld a, $0c
    ldh [$ffe4], a
    call Call_000_07f0
    pop af
    ldh [$ffe4], a
    ld a, $3c
    ld hl, $9800
    call Call_000_0558
    ld hl, $9804
    ld [hl], $94
    ld hl, $9822
    ld [hl], $95
    inc l
    ld [hl], $96
    inc l
    ld [hl], $8c
    ld hl, $982f
    ld [hl], $3f
    inc l
    ld [hl], $4c
    inc l
    ld [hl], $4d
    ld hl, $c0a2
    ld de, $c0c2
    ld b, $03

jr_000_03c7:
    ld a, [de]
    sub [hl]
    jr c, jr_000_03d4

    jr nz, jr_000_03e2

    dec e
    dec l
    dec b
    jr nz, jr_000_03c7

    jr jr_000_03e2

jr_000_03d4:
    ld hl, $c0a2
    ld de, $c0c2
    ld b, $03

jr_000_03dc:
    ld a, [hl-]
    ld [de], a
    dec e
    dec b
    jr nz, jr_000_03dc

jr_000_03e2:
    ld de, $c0c2
    ld hl, $9969
    call Call_000_3f38
    ld hl, $c004
    ld [hl], $78
    ld a, [$c0a6]
    and a
    jr z, jr_000_041f

    ldh a, [$ff9a]
    cp $02
    jr c, jr_000_03fe

    jr jr_000_041f

jr_000_03fe:
    ld hl, $0446
    ld de, $99c6
    ld b, $0a

jr_000_0406:
    ld a, [hl+]
    ld [de], a
    inc e
    dec b
    jr nz, jr_000_0406

    ld hl, $c000
    ld [hl], $80
    inc l
    ld [hl], $88
    inc l
    ld a, [$c0a6]
    ld [hl], a
    inc l
    ld [hl], $00
    inc l
    ld [hl], $80

jr_000_041f:
    inc l
    ld [hl], $28
    inc l
    ld [hl], $ac
    xor a
    ldh [rIF], a
    ld a, $c3
    ldh [rLCDC], a
    ei
    ld a, $0f
    ldh [$ffb3], a
    xor a
    ldh [$fff9], a
    ld a, $28
    ld [$c0d7], a
    ldh [$ff9f], a
    ld hl, $c0dc
    inc [hl]
    ld a, [hl]
    cp $03
    ret nz

    ld [hl], $00
    ret


    inc c
    jr @+$19

    dec e
    ld [de], a
    rla
    ld e, $0e
    inc l
    dec hl

jr_000_0450:
    ld a, [$c004]
    cp $78
    jr z, jr_000_04a2

    ld a, [$c0a6]
    dec a
    ld [$c0a6], a
    ld a, [$c0a8]
    ldh [$ffb4], a
    ld e, $00
    cp $11
    jr z, jr_000_049c

    inc e
    cp $12
    jr z, jr_000_049c

    inc e
    cp $13
    jr z, jr_000_049c

    inc e
    cp $21
    jr z, jr_000_049c

    inc e
    cp $22
    jr z, jr_000_049c

    inc e
    cp $23
    jr z, jr_000_049c

    inc e
    cp $31
    jr z, jr_000_049c

    inc e
    cp $32
    jr z, jr_000_049c

    inc e
    cp $33
    jr z, jr_000_049c

    inc e
    cp $41
    jr z, jr_000_049c

    inc e
    cp $42
    jr z, jr_000_049c

    inc e

jr_000_049c:
    ld a, e

jr_000_049d:
    ldh [$ffe4], a
    jp Jump_000_053d


jr_000_04a2:
    xor a
    ld [$c0a6], a
    ldh a, [$ff9a]
    cp $02
    jp nc, Jump_000_053d

    ld a, $11
    ldh [$ffb4], a
    xor a
    jr jr_000_049d

jr_000_04b4:
    ld a, [$c0a6]
    and a
    jr z, jr_000_04ce

    ld hl, $c004
    ld a, [hl]
    xor $f8
    ld [hl], a
    jr jr_000_04ce

    ldh a, [$ff81]
    ld b, a
    bit 3, b
    jr nz, jr_000_0450

    bit 2, b
    jr nz, jr_000_04b4

jr_000_04ce:
    ldh a, [$ff9a]
    cp $02
    jr c, jr_000_0519

    bit 0, b
    jr z, jr_000_04f5

    ldh a, [$ffb4]
    inc a
    ld b, a
    and $0f
    cp $04
    ld a, b
    jr nz, jr_000_04e5

    add $0d

jr_000_04e5:
    ldh [$ffb4], a
    ldh a, [$ffe4]
    inc a
    cp $0c
    jr nz, jr_000_04f3

    ld a, $11
    ldh [$ffb4], a
    xor a

jr_000_04f3:
    ldh [$ffe4], a

jr_000_04f5:
    ld hl, $c008
    ldh a, [$ffb4]
    ld b, $78
    ld c, a
    and $f0
    swap a
    ld [hl], b
    inc l
    ld [hl], $78
    inc l
    ld [hl+], a
    inc l
    ld a, c
    and $0f
    ld [hl], b
    inc l
    ld [hl], $88
    inc l
    ld [hl+], a
    inc l
    ld [hl], b
    inc l
    ld [hl], $80
    inc l
    ld [hl], $29

jr_000_0519:
    ld a, [$c0d7]

Jump_000_051c:
    and a
    ret nz

    ld a, [$c0dc]
    sla a
    ld e, a
    ld d, $00
    ld hl, $0552
    add hl, de
    ld a, [hl+]
    ldh [$ffb4], a
    ld a, [hl]
    ldh [$ffe4], a

Jump_000_0530:
    ld a, $50
    ld [$c0d7], a
    ld a, $11
    ldh [$ffb3], a
    xor a
    ldh [$ff9a], a
    ret


Jump_000_053d:
    ld a, $11
    ldh [$ffb3], a
    xor a
    ldh [rIF], a
    ldh [$ff9f], a
    ld [$c0a4], a
    dec a
    ld [$dfe8], a
    ld a, $07
    ldh [rIE], a
    ret


    ld de, $1200
    ld bc, $0833

Call_000_0558:
    ld b, $14

jr_000_055a:
    ld [hl+], a
    dec b
    jr nz, jr_000_055a

    ret


    xor a
    ldh [rLCDC], a
    di
    ldh a, [$ff9f]
    and a
    jr nz, jr_000_0574

    xor a
    ld [$c0a0], a
    ld [$c0a1], a
    ld [$c0a2], a
    ldh [$fffa], a

jr_000_0574:
    call Call_000_05d0
    call Call_000_05b8
    ld hl, $9c00
    ld b, $5f
    ld a, $2c

jr_000_0581:
    ld [hl+], a
    dec b
    jr nz, jr_000_0581

    call Call_000_05f8
    ld a, $0f
    ldh [rLYC], a
    ld a, $07
    ldh [rTAC], a
    ld hl, $ff4a
    ld [hl], $85
    inc l
    ld [hl], $60
    xor a
    ldh [rTMA], a
    ldh [rIF], a
    dec a
    ldh [$ffa7], a
    ldh [$ffb1], a
    ld a, $5b
    ldh [$ffe9], a
    call $2439
    call Call_000_3d11
    call Call_000_1c12
    call Call_000_1c4d
    ldh a, [$ffb4]
    call Call_000_0d64
    ret


Call_000_05b8:
    ld hl, $9bff
    ld bc, $0400

Call_000_05be:
jr_000_05be:
    ld a, $2c
    ld [hl-], a
    dec bc
    ld a, b
    or c
    jr nz, jr_000_05be

    ret


Call_000_05c7:
jr_000_05c7:
    ld a, [hl+]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, jr_000_05c7

    ret


Call_000_05d0:
    ld hl, $5032
    ld de, $9000
    ld bc, $0800
    call Call_000_05c7
    ld hl, $4032
    ld de, $8000
    ld bc, $1000
    call Call_000_05c7
    ld hl, $5603
    ld de, $c600
    ld b, $08

jr_000_05f0:
    ld a, [hl+]
    ld [de], a
    inc hl
    inc de
    dec b
    jr nz, jr_000_05f0

    ret


Call_000_05f8:
    ld hl, $3f87
    ld de, $9800
    ld b, $02

jr_000_0600:
    ld a, [hl+]
    ld [de], a
    inc e
    ld a, e
    and $1f
    cp $14
    jr nz, jr_000_0600

    ld e, $20
    dec b
    jr nz, jr_000_0600

    ret


    call Call_000_218f
    call Call_000_0837
    ldh a, [$fffd]
    ldh [$ffe1], a
    ld a, $03
    ldh [$fffd], a
    ld [$2000], a
    call $48fc
    ld bc, $c208
    ld hl, $2164
    call $490d
    ld bc, $c218
    ld hl, $2164
    call $490d
    ld bc, $c228
    ld hl, $2164
    call $490d
    ld bc, $c238
    ld hl, $2164
    call $490d
    ld bc, $c248
    ld hl, $2164
    call $490d
    call $4a94
    call $498b
    call $4aea
    call $4b3c
    call $4b6f
    call $4b8a
    call $4bb5
    ldh a, [$ffe1]
    ldh [$fffd], a
    ld [$2000], a
    call Call_000_1f24
    call Call_000_2488
    ldh a, [$fffd]
    ldh [$ffe1], a
    ld a, $02
    ldh [$fffd], a
    ld [$2000], a
    call $5844
    ldh a, [$ffe1]
    ldh [$fffd], a
    ld [$2000], a
    call Call_000_1983
    call Call_000_16ec
    call Call_000_17b3
    call Call_000_0ae1
    call Call_000_0a24
    call Call_000_1efa
    ld hl, $c0ce
    ld a, [hl]
    and a
    ret z

    dec [hl]
    call Call_000_210a
    ret


    ld hl, $ffa6
    ld a, [hl]
    and a
    ret nz

    ld hl, $d100
    ld de, $0010
    ld b, $0a

jr_000_06b3:
    ld [hl], $ff
    add hl, de
    dec b
    jr nz, jr_000_06b3

    xor a
    ldh [$ff99], a
    dec a
    ld [$c0a3], a
    ld a, $02
    ldh [$ffb3], a
    ret


    di
    ld a, $00
    ldh [rLCDC], a
    call $1ecb
    call Call_000_1655
    ld hl, $ffe5
    ldh a, [$fff9]
    and a
    jr z, jr_000_06e0

    xor a
    ldh [$fff9], a
    ldh a, [$fff5]
    inc a
    jr jr_000_06e1

jr_000_06e0:
    ld a, [hl]

jr_000_06e1:
    cp $03
    jr z, jr_000_06e6

    dec a

jr_000_06e6:
    ld bc, $030c
    cp $07
    jr c, jr_000_070c

    ld bc, $0734
    cp $0b
    jr c, jr_000_070c

    ld bc, $0b5c
    cp $0f
    jr c, jr_000_070c

    ld bc, $0f84
    cp $13
    jr c, jr_000_070c

    ld bc, $13ac
    cp $17
    jr c, jr_000_070c

    ld bc, $17d4

jr_000_070c:
    ld [hl], b
    inc l
    ld [hl], $00
    ld a, c
    ld [$c0ab], a
    call Call_000_07f0
    ld hl, $982b
    ld [hl], $2c
    inc l
    ldh a, [$ffb4]
    ld b, a
    and $f0
    swap a
    ld [hl+], a
    ld a, b
    and $0f
    inc l
    ld [hl], a
    ld hl, $9c00
    ld de, $0783
    ld b, $09

jr_000_0732:
    ld a, [de]
    ld [hl+], a
    inc de
    dec b
    jr nz, jr_000_0732

    xor a
    ldh [$ffb3], a
    ld [$c0d3], a
    ld a, $c3
    ldh [rLCDC], a
    call Call_000_078c
    xor a
    ldh [rIF], a
    ldh [$ffa4], a
    ld [$c0d2], a
    ldh [$ffee], a
    ld [$da1d], a
    ldh [rTMA], a
    ld hl, $da01
    ld [hl+], a
    ld [hl], $04
    ld a, $28
    ld [$da00], a
    ld a, $5b
    ldh [$ffe9], a
    ldh a, [$ffe4]
    ld c, $0a
    cp $05
    jr z, jr_000_0771

    ld c, $0c
    cp $0b
    jr nz, jr_000_077e

jr_000_0771:
    ld a, $0d
    ldh [$ffb3], a
    ld a, [$c203]
    and $f0
    or c
    ld [$c203], a

jr_000_077e:
    call Call_000_2453
    ei
    ret


    inc l
    add h
    add hl, de
    ld a, [bc]
    ld e, $1c
    ld c, $84
    inc l

Call_000_078c:
    ld a, [$c0d3]
    and a
    ret nz

    ld a, $03
    ld [$2000], a
    call $7ff3
    ldh a, [$fffd]
    ld [$2000], a
    ldh a, [$fff4]
    and a
    jr nz, jr_000_07b1

    ldh a, [$ffe4]
    ld hl, $07b7
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ld [$dfe8], a
    ret


jr_000_07b1:
    ld a, $04
    ld [$dfe8], a
    ret


    rlca
    rlca
    inc bc
    ld [$0508], sp
    rlca
    inc bc
    inc bc
    ld b, $06
    dec b

Call_000_07c3:
    ldh a, [$ff80]
    and $0f
    cp $0f
    jr nz, jr_000_07ce

    jp Jump_000_0185


jr_000_07ce:
    ldh a, [$ff81]
    bit 3, a
    ret z

    ldh a, [$ffb3]
    cp $0e
    ret nc

    ld hl, $ff40
    ldh a, [$ffb2]
    xor $01
    ldh [$ffb2], a
    jr z, jr_000_07ea

    set 5, [hl]
    ld a, $01

jr_000_07e7:
    ldh [$ffdf], a
    ret


jr_000_07ea:
    res 5, [hl]
    ld a, $02
    jr jr_000_07e7

Call_000_07f0:
    ld hl, $2114
    ld de, $c200
    ld b, $51

jr_000_07f8:
    ld a, [hl+]
    ld [de], a
    inc de
    dec b
    jr nz, jr_000_07f8

    ldh a, [$ff99]
    and a
    jr z, jr_000_0808

    ld a, $10
    ld [$c203], a

Call_000_0808:
jr_000_0808:
    ld hl, $ffe6
    xor a
    ld b, $06

jr_000_080e:
    ld [hl+], a
    dec b
    jr nz, jr_000_080e

    ldh [$ffa3], a
    ld [$c0aa], a
    ld a, $40
    ldh [$ffe9], a
    ld b, $14
    ldh a, [$ffb3]
    cp $0a
    jr z, jr_000_082b

    ldh a, [$ffe4]
    cp $0c
    jr z, jr_000_082b

    ld b, $1b

jr_000_082b:
    push bc
    call Call_000_21a8
    call Call_000_224f
    pop bc
    dec b
    jr nz, jr_000_082b

    ret


Call_000_0837:
    ldh a, [$ff9c]
    and a
    jr z, jr_000_083f

Call_000_083c:
    dec a
    ldh [$ff9c], a

jr_000_083f:
    ld de, $fff0
    ld b, $0a
    ld hl, $d190

jr_000_0847:
    ld a, [hl]
    cp $ff
    jr nz, jr_000_0851

Jump_000_084c:
    add hl, de
    dec b
    jr nz, jr_000_0847

    ret


jr_000_0851:
    ldh [$fffb], a
    ld a, l
    ldh [$fffc], a
    push bc
    push hl
    ld bc, $000a
    add hl, bc
    ld c, [hl]
    inc l
    inc l
    ld a, [hl]
    ldh [$ff9b], a
    ld a, [$c201]
    ld b, a
    ldh a, [$ff99]
    cp $02
    jr nz, jr_000_0877

    ld a, [$c203]
    cp $18
    jr z, jr_000_0877

    ld a, $fe
    add b
    ld b, a

jr_000_0877:
    ld a, b

Call_000_0878:
    ldh [$ffa0], a
    ld a, [$c201]
    add $06
    ldh [$ffa1], a
    ld a, [$c202]
    ld b, a
    sub $03
    ldh [$ffa2], a
    ld a, $02
    add b
    ldh [$ff8f], a
    pop hl
    push hl
    call Call_000_0aa6
    and a
    jp z, Jump_000_0958

    ldh a, [$fffc]
    cp $90
    jp z, Jump_000_096a

    ldh a, [$fffb]
    cp $33
    jp z, Jump_000_09ce

    ldh a, [$ffb3]
    cp $0d
    jr z, jr_000_08b1

    ld a, [$c0d3]
    and a
    jr z, jr_000_08b5

jr_000_08b1:
    dec l
    jp Jump_000_0939


jr_000_08b5:
    ld a, [$c202]
    add $06
    ld c, [hl]
    dec l
    sub c
    jr c, jr_000_0939

    ld a, [$c202]
    sub $06
    sub b
    jr nc, jr_000_0939

    ld b, [hl]
    dec b
    dec b
    dec b
    ld a, [$c201]
    sub b
    jr nc, jr_000_0939

    dec l
    dec l
    push hl
    ld bc, $000a
    add hl, bc
    bit 7, [hl]
    pop hl
    jr nz, jr_000_0955

    call Call_000_0a07
    call Call_000_29f8
    and a
    jr z, jr_000_0955

    ld hl, $c20a
    ld [hl], $00
    dec l
    dec l
    ld [hl], $0d
    dec l
    ld [hl], $01
    ld hl, $c203
    ld a, [hl]
    and $f0
    or $04
    ld [hl], a

jr_000_08fb:
    ld a, $03
    ld [$dfe0], a
    ld a, [$c202]
    add $fc
    ldh [$ffeb], a
    ld a, [$c201]
    sub $10
    ldh [$ffec], a
    ldh a, [$ff9e]
    ldh [$ffed], a
    ldh a, [$ff9c]
    and a
    jr z, jr_000_0934

    ldh a, [$ff9d]
    cp $03
    jr z, jr_000_0920

    inc a
    ldh [$ff9d], a

jr_000_0920:
    ld b, a
    ldh a, [$ffed]
    cp $50
    jr z, jr_000_0934

jr_000_0927:
    sla a
    dec b
    jr nz, jr_000_0927

    ldh [$ffed], a

jr_000_092e:
    ld a, $32
    ldh [$ff9c], a
    jr jr_000_0955

jr_000_0934:
    xor a
    ldh [$ff9d], a
    jr jr_000_092e

Jump_000_0939:
jr_000_0939:
    dec l
    dec l
    ld a, [$c0d3]
    and a
    jr nz, jr_000_0962

    ldh a, [$ff99]
    cp $03
    jr nc, jr_000_0955

    call Call_000_2a3b
    and a
    jr z, jr_000_0955

    ldh a, [$ff99]
    and a
    jr nz, jr_000_095d

    call Call_000_09e8

jr_000_0955:
    pop hl
    pop bc
    ret


Jump_000_0958:
    pop hl
    pop bc
    jp Jump_000_084c


jr_000_095d:
    call Call_000_09d7
    jr jr_000_0955

jr_000_0962:
    call Call_000_2afd
    and a
    jr z, jr_000_0955

    jr jr_000_08fb

Jump_000_096a:
    ldh a, [$fffb]
    cp $29
    jr z, jr_000_09a2

    cp $34
    jr z, jr_000_09b2

    cp $2b
    jr z, jr_000_09be

    cp $2e
    jr nz, jr_000_0955

    ldh a, [$ff99]
    cp $02
    jr nz, jr_000_09a8

    ldh [$ffb5], a

jr_000_0984:
    ld a, $04
    ld [$dfe0], a

jr_000_0989:
    ld a, $10
    ldh [$ffed], a

jr_000_098d:
    ld a, [$c202]
    add $fc
    ldh [$ffeb], a
    ld a, [$c201]
    sub $10
    ldh [$ffec], a

jr_000_099b:
    dec l
    dec l
    dec l
    ld [hl], $ff
    jr jr_000_0955

jr_000_09a2:
    ldh a, [$ff99]
    cp $02
    jr z, jr_000_0989

jr_000_09a8:
    ld a, $01
    ldh [$ff99], a
    ld a, $50
    ldh [$ffa6], a
    jr jr_000_0984

jr_000_09b2:
    ld a, $f8
    ld [$c0d3], a
    ld a, $0c
    ld [$dfe8], a
    jr jr_000_0989

jr_000_09be:
    ld a, $ff
    ldh [$ffed], a
    ld a, $08
    ld [$dfe0], a
    ld a, $01
    ld [$c0a3], a
    jr jr_000_098d

Jump_000_09ce:
    ldh [$fffe], a
    ld a, $05
    ld [$dfe0], a
    jr jr_000_099b

Call_000_09d7:
    ld a, $03
    ldh [$ff99], a
    xor a
    ldh [$ffb5], a
    ld a, $50
    ldh [$ffa6], a
    ld a, $06
    ld [$dfe0], a
    ret


Call_000_09e8:
    ld a, [$d007]
    and a
    ret nz

    ld a, $03
    ldh [$ffb3], a
    xor a
    ldh [$ffb5], a
    ldh [rTMA], a
    ld a, $02
    ld [$dfe8], a
    ld a, $80
    ld [$c200], a
    ld a, [$c201]
    ld [$c0dd], a
    ret


Call_000_0a07:
    push hl
    push de
    ldh a, [$ff9b]
    and $c0
    swap a
    srl a
    srl a
    ld e, a
    ld d, $00
    ld hl, $0a20
    add hl, de
    ld a, [hl]
    ldh [$ff9e], a
    pop de
    pop hl
    ret


    ld bc, $0804
    ld d, b

Call_000_0a24:
    ldh a, [$ffee]
    and a
    ret z

    cp $c0
    ret z

    ld de, $0010
    ld b, $0a
    ld hl, $d100

jr_000_0a33:
    ld a, [hl]
    cp $ff
    jr nz, jr_000_0a3d

Jump_000_0a38:
    add hl, de
    dec b
    jr nz, jr_000_0a33

    ret


jr_000_0a3d:
    push bc
    push hl
    ld bc, $000a
    add hl, bc
    bit 7, [hl]
    jr nz, jr_000_0aa1

    ld c, [hl]
    inc l
    inc l
    ld a, [hl]
    ldh [$ff9b], a
    pop hl
    push hl
    inc l
    inc l
    ld b, [hl]
    ld a, [$c201]
    sub b
    jr c, jr_000_0aa1

    ld b, a
    ld a, $14
    sub b
    jr c, jr_000_0aa1

    cp $07
    jr nc, jr_000_0aa1

    inc l
    ld a, c
    and $70
    swap a
    ld c, a
    ld a, [hl]

jr_000_0a6a:
    add $08
    dec c
    jr nz, jr_000_0a6a

    ld c, a
    ld b, [hl]
    ld a, [$c202]
    sub $06
    sub c
    jr nc, jr_000_0aa1

    ld a, [$c202]
    add $06
    sub b
    jr c, jr_000_0aa1

    dec l
    dec l
    dec l
    push de
    call Call_000_0a07
    call Call_000_2a1a
    pop de
    and a
    jr z, jr_000_0aa1

    ld a, [$c202]
    add $fc
    ldh [$ffeb], a
    ld a, [$c201]
    sub $10
    ldh [$ffec], a
    ldh a, [$ff9e]
    ldh [$ffed], a

jr_000_0aa1:
    pop hl
    pop bc
    jp Jump_000_0a38


Call_000_0aa6:
    inc l
    inc l
    ld a, [hl]
    add $08
    ld b, a
    ldh a, [$ffa0]
    sub b
    jr nc, jr_000_0adf

    ld a, c
    and $0f
    ld b, a
    ld a, [hl]

jr_000_0ab6:
    dec b
    jr z, jr_000_0abd

    sub $08
    jr jr_000_0ab6

jr_000_0abd:
    ld b, a
    ldh a, [$ffa1]
    sub b
    jr c, jr_000_0adf

    inc l
    ldh a, [$ff8f]
    ld b, [hl]
    sub b
    jr c, jr_000_0adf

    ld a, c
    and $70
    swap a
    ld b, a
    ld a, [hl]

jr_000_0ad1:
    add $08
    dec b
    jr nz, jr_000_0ad1

    ld b, a
    ldh a, [$ffa2]
    sub b
    jr nc, jr_000_0adf

    ld a, $01
    ret


jr_000_0adf:
    xor a
    ret


Call_000_0ae1:
    ld a, [$c207]
    cp $01
    ret z

    ld de, $0010
    ld b, $0a
    ld hl, $d100

jr_000_0aef:
    ld a, [hl]
    cp $ff
    jr nz, jr_000_0af9

Jump_000_0af4:
    add hl, de
    dec b
    jr nz, jr_000_0aef

    ret


jr_000_0af9:
    push bc
    push hl
    ld bc, $000a
    add hl, bc
    bit 7, [hl]
    jp z, Jump_000_0b7f

    ld a, [hl]
    and $0f
    ldh [$ffa0], a
    ld bc, $fff8
    add hl, bc
    ldh a, [$ffa0]
    ld b, a
    ld a, [hl]

jr_000_0b11:
    dec b
    jr z, jr_000_0b18

    sub $08
    jr jr_000_0b11

jr_000_0b18:
    ld c, a
    ldh [$ffa0], a
    ld a, [$c201]
    add $06
    ld b, a
    ld a, c
    sub b
    cp $07
    jr nc, jr_000_0b7f

    inc l
    ld a, [$c202]
    ld b, a
    ld a, [hl]
    sub b
    jr c, jr_000_0b34

    cp $03
    jr nc, jr_000_0b7f

jr_000_0b34:
    push hl
    inc l
    inc l
    inc l
    inc l
    inc l
    inc l
    inc l
    ld a, [hl]
    and $70
    swap a
    ld b, a
    pop hl
    ld a, [hl]

jr_000_0b44:
    add $08
    dec b
    jr nz, jr_000_0b44

    ld b, a
    ld a, [$c202]
    sub b
    jr c, jr_000_0b54

    cp $03
    jr nc, jr_000_0b7f

jr_000_0b54:
    dec l
    ldh a, [$ffa0]
    sub $0a
    ld [$c201], a
    push hl
    dec l
    dec l
    call Call_000_29f8
    pop hl
    ld bc, $0009
    add hl, bc
    ld [hl], $01
    xor a
    ld hl, $c207
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], $01
    ld hl, $c20c
    ld a, [hl]
    cp $07
    jr c, jr_000_0b7c

    ld [hl], $06

jr_000_0b7c:
    pop hl
    pop bc
    ret


Jump_000_0b7f:
jr_000_0b7f:
    pop hl
    pop bc
    jp Jump_000_0af4


    ld hl, $c00c
    ld a, [$c0dd]
    ld c, a
    sub $08
    ld d, a
    ld [hl], a
    inc l
    ld a, [$c202]
    add $f8
    ld b, a
    ld [hl+], a
    ld [hl], $0f
    inc l
    ld [hl], $00
    inc l
    ld [hl], c
    inc l
    ld [hl], b
    inc l
    ld [hl], $1f
    inc l
    ld [hl], $00
    inc l
    ld [hl], d
    inc l
    ld a, b
    add $08
    ld b, a
    ld [hl+], a
    ld [hl], $0f
    inc l
    ld [hl], $20
    inc l
    ld [hl], c
    inc l
    ld [hl], b
    inc l
    ld [hl], $1f
    inc l
    ld [hl], $20
    ld a, $04
    ldh [$ffb3], a
    xor a
    ld [$c0ac], a
    ldh [$ff99], a
    ldh [$fff4], a
    call $1ecb
    ret


    ld a, [$c0ac]
    ld e, a
    inc a
    ld [$c0ac], a
    ld d, $00
    ld hl, $0c10
    add hl, de
    ld b, [hl]
    ld a, b
    cp $7f
    jr nz, jr_000_0bea

    ld a, [$c0ac]
    dec a
    ld [$c0ac], a
    ld b, $02

jr_000_0bea:
    ld hl, $c00c
    ld de, $0004
    ld c, $04

jr_000_0bf2:
    ld a, b
    add [hl]
    ld [hl], a
    add hl, de
    dec c
    jr nz, jr_000_0bf2

    cp $b4
    ret c

    ld a, [$da1d]
    cp $ff
    jr nz, jr_000_0c07

    ld a, $3b
    jr jr_000_0c0d

jr_000_0c07:
    ld a, $90
    ldh [$ffa6], a
    ld a, $01

jr_000_0c0d:
    ldh [$ffb3], a
    ret


    cp $fe
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
    nop
    rst $38

Jump_000_0c22:
    nop
    nop
    rst $38
    nop
    nop
    nop
    ld bc, $0000
    ld bc, $0100
    ld bc, $0101
    ld bc, $0101
    ld bc, $7f01
    ld hl, $ffa6
    ld a, [hl]
    and a
    jr z, jr_000_0c42

    call Call_000_172d
    ret


jr_000_0c42:
    ld a, [$d007]
    and a
    jr nz, jr_000_0c4c

    ld a, $40
    ldh [$ffa6], a

jr_000_0c4c:
    ld a, $05
    ldh [$ffb3], a
    xor a
    ld [$da1d], a
    ldh [rTMA], a
    ldh a, [$ffb4]
    and $0f
    cp $03
    ret nz

    call Call_000_2b21
    ldh a, [$ffb4]
    cp $43
    ret nz

    ld a, $06
    ldh [$ffb3], a
    ret


    ldh a, [$ffb4]
    and $0f
    cp $03
    jr nz, jr_000_0c79

    xor a
    ld [$c0ab], a
    call Call_000_2488

jr_000_0c79:
    ldh a, [$ffa6]
    and a
    ret nz

    ld hl, $da01
    ld a, [hl+]
    ld b, [hl]
    or b
    jr z, jr_000_0cb9

    ld a, $01
    ld [$da00], a
    ldh a, [$fffd]
    ldh [$ffe1], a
    ld a, $02
    ldh [$fffd], a
    ld [$2000], a
    call $5844
    ldh a, [$ffe1]
    ldh [$fffd], a
    ld [$2000], a
    ld de, $0010
    call Call_000_0166
    ld a, $01
    ldh [$ffa6], a
    xor a
    ld [$da1d], a
    ld a, [$da01]
    and $01
    ret nz

    ld a, $0a
    ld [$dfe0], a
    ret


jr_000_0cb9:
    ld a, $06
    ldh [$ffb3], a
    ld a, $26
    ldh [$ffa6], a
    ret


    ldh a, [$ffa6]
    and a
    ret nz

    xor a
    ld [$da1d], a
    ldh [rTMA], a
    ldh a, [$ffb4]
    and $0f
    cp $03
    ld a, $1c
    jr z, jr_000_0cf1

    ld a, [$c201]
    cp $60

Call_000_0cdb:
    jr c, jr_000_0ce5

    cp $a0
    jr nc, jr_000_0ce5

    ld a, $08
    jr jr_000_0cee

jr_000_0ce5:
    ld a, $02
    ldh [$fffd], a
    ld [$2000], a
    ld a, $12

jr_000_0cee:
    ldh [$ffb3], a
    ret


jr_000_0cf1:
    ldh [$ffb3], a
    ld a, $03
    ld [$2000], a
    ldh [$fffd], a
    ld hl, $ffe4
    ld a, [hl]
    ldh [$fffb], a
    ld [hl], $0c
    inc l
    xor a
    ld [hl+], a
    ld [hl+], a
    ldh [$ffa3], a
    inc l
    inc l
    ld a, [hl]
    ldh [$ffe0], a
    ld a, $06
    ldh [$ffa6], a
    ldh a, [$ffb4]
    and $f0
    cp $40
    ret nz

    xor a
    ldh [$fffb], a
    ld a, $01
    ld [$c0de], a
    ld a, $bf
    ldh [$fffc], a
    ld a, $ff
    ldh [$ffa6], a
    ld a, $27
    ldh [$ffb3], a
    call $7ff3
    ret


jr_000_0d30:
    di
    ld a, c
    ld [$2000], a
    ldh [$fffd], a
    xor a
    ldh [rLCDC], a
    call Call_000_05d0
    jp Jump_000_0dca


    ld hl, $ffa6
    ld a, [hl]
    and a
    ret nz

    ld a, [$dff9]
    and a
    ret nz

    ldh a, [$ffe4]
    inc a
    cp $0c
    jr nz, jr_000_0d53

    xor a

jr_000_0d53:
    ldh [$ffe4], a
    ldh a, [$ffb4]
    inc a
    ld b, a
    and $0f
    cp $04
    ld a, b
    jr nz, jr_000_0d62

    add $0d

jr_000_0d62:
    ldh [$ffb4], a

Call_000_0d64:
    and $f0
    swap a
    cp $01
    ld c, $02
    jr z, jr_000_0d30

    cp $02
    ld c, $01
    jr z, jr_000_0d7c

    cp $03
    ld c, $03
    jr z, jr_000_0d7c

    ld c, $01

jr_000_0d7c:
    ld b, a
    di
    ld a, c
    ld [$2000], a
    ldh [$fffd], a
    xor a
    ldh [rLCDC], a
    ld a, b
    dec a
    dec a
    sla a
    ld d, $00
    ld e, a
    ld hl, $0de4
    push de
    add hl, de
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $8a00

jr_000_0d9a:
    ld a, [de]
    ld [hl+], a
    inc de
    push hl
    ld bc, $7230
    add hl, bc
    pop hl
    jr nc, jr_000_0d9a

    pop de
    ld hl, $0dea
    add hl, de
    ld e, [hl]
    inc hl
    ld d, [hl]
    push de
    ld hl, $9310

jr_000_0db1:
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, h
    cp $97
    jr nz, jr_000_0db1

    pop hl
    ld de, $02c1
    add hl, de
    ld de, $c600
    ld b, $08

jr_000_0dc3:
    ld a, [hl+]
    ld [de], a
    inc hl
    inc de
    dec b
    jr nz, jr_000_0dc3

Jump_000_0dca:
    xor a
    ldh [rIF], a
    ld a, $c3
    ldh [rLCDC], a
    ei
    ld a, $03
    ldh [$ffe5], a
    xor a
    ld [$c0d2], a
    ldh [$fff9], a
    ld a, $02
    ldh [$ffb3], a
    call $2439
    ret


    ld [hl-], a
    ld b, b
    ld [hl-], a
    ld b, b
    ldh a, [c]
    ld b, a
    ld [bc], a
    ld b, h
    ld [bc], a
    ld b, h
    jp nz, $f34b

    xor a
    ldh [rLCDC], a
    call Call_000_05f8
    call Call_000_1c12
    call Call_000_1c4d
    xor a
    ldh [rIF], a
    ld a, $c3
    ldh [rLCDC], a
    ei
    ld a, $08
    ldh [$ffb3], a
    ldh [$ffb1], a
    ret


    ldh a, [$ffa6]
    and a
    jr z, jr_000_0e1f

    call Call_000_21a8
    xor a
    ld [$c0ab], a
    call Call_000_2488
    call Call_000_172d
    ret


jr_000_0e1f:
    ld a, $40
    ldh [$ffa6], a
    ld hl, $ffb3
    inc [hl]
    ret


    xor a
    ld [$c0ab], a
    call Call_000_2488
    ldh a, [$ffa6]
    and a
    ret nz

    ldh a, [$ffe0]
    sub $02
    cp $40
    jr nc, jr_000_0e3d

    add $20

jr_000_0e3d:
    ld l, a
    ld h, $98
    ld de, $0120
    add hl, de
    ld a, l
    ldh [$ffe0], a
    ld a, $05
    ldh [$fffc], a
    ld a, $08
    ldh [$ffa6], a
    ld hl, $ffb3
    inc [hl]
    ret


    ldh a, [$ffa6]
    and a
    ret nz

    ldh a, [$fffc]
    dec a
    jr z, jr_000_0e7a

    ldh [$fffc], a
    ldh a, [$ffe0]
    ld l, a
    ld h, $99
    sub $20
    ldh [$ffe0], a

jr_000_0e68:
    ldh a, [rSTAT]
    and $03
    jr nz, jr_000_0e68

    ld [hl], $2c
    ld a, $08
    ldh [$ffa6], a
    ld a, $0b
    ld [$dfe0], a
    ret


jr_000_0e7a:
    ld a, $10
    ldh [$ffa6], a
    ld a, $03
    ldh [$fffd], a
    ld [$2000], a
    call $7ff3
    ld hl, $ffb3
    inc [hl]
    ret


    ldh a, [$ffa6]
    and a
    ret nz

    xor a
    ld [$c0d2], a
    ld [$c207], a
    inc a
    ldh [$fff9], a
    ld hl, $ffb3
    inc [hl]
    ret


    call Call_000_0eb2
    ld a, [$c202]
    cp $c0
    ret c

    ld a, $20
    ldh [$ffa6], a
    ld hl, $ffb3
    inc [hl]
    ret


Call_000_0eb2:
    ld a, $10
    ldh [$ff80], a
    ld a, [$c203]
    and $0f
    cp $0a
    call c, Call_000_17b3
    call Call_000_16ec
    ret


    ldh a, [$ffa6]
    and a
    ret nz

    call Call_000_0ede
    xor a
    ldh [$ffea], a
    ldh [$ffa3], a
    ld a, $a1
    ldh [$ffa6], a
    ld a, $0f
    ld [$dfe8], a
    ld hl, $ffb3
    inc [hl]
    ret


Call_000_0ede:
    ld hl, $c201
    ld [hl], $7e
    inc l
    ld [hl], $b0
    inc l
    ld a, [hl]
    and $f0
    ld [hl], a
    ld hl, $c210
    ld de, $2114
    ld b, $10

jr_000_0ef3:
    ld a, [de]
    ld [hl+], a
    inc de
    dec b
    jr nz, jr_000_0ef3

    ld hl, $c211
    ld [hl], $7e
    inc l
    ld [hl], $00
    inc l
    ld [hl], $22
    inc l
    inc l
    ld [hl], $20
    ret


    ldh a, [$ffa6]
    and a
    jr z, jr_000_0f21

    ld hl, $ffa4
    inc [hl]
    call Call_000_218f
    ld hl, $c202
    dec [hl]
    ld hl, $c212
    dec [hl]

jr_000_0f1d:
    call Call_000_172d
    ret


jr_000_0f21:
    ldh a, [$fffb]
    ldh [$ffe4], a
    ld hl, $ffb3
    inc [hl]
    ret


    ld a, $10
    ldh [$ff80], a
    call Call_000_17b3
    call Call_000_16ec
    ld a, [$c202]
    cp $4c
    ret c

    ld a, [$c203]
    and $f0
    ld [$c203], a
    ldh a, [$ffe0]
    sub $40
    add $04
    ld b, a
    and $f0
    cp $c0
    ld a, b
    jr nz, jr_000_0f52

    sub $20

jr_000_0f52:
    ldh [$ffe3], a
    ld a, $98
    ldh [$ffe2], a
    xor a
    ldh [$fffb], a
    ld hl, $ffb3
    inc [hl]
    jr jr_000_0f1d

    ld hl, $0fd8
    call Call_000_0f81
    cp $ff
    ret nz

    ld hl, $ffb3
    inc [hl]
    ld a, $80
    ld [$c210], a
    ld a, $08
    ldh [$ffa6], a
    ld a, $08
    ldh [$fffb], a
    ld a, $12
    ld [$dfe8], a
    ret


Call_000_0f81:
    ldh a, [$ffa6]
    and a
    ret nz

    ldh a, [$fffb]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ld b, a
    cp $fe

Call_000_0f8f:
    jr z, jr_000_0fc5

    cp $ff
    ret z

    ldh a, [$ffe2]
    ld h, a
    ldh a, [$ffe3]
    ld l, a

jr_000_0f9a:
    ldh a, [rSTAT]
    and $03
    jr nz, jr_000_0f9a

jr_000_0fa0:
    ldh a, [rSTAT]
    and $03
    jr nz, jr_000_0fa0

    ld [hl], b
    inc hl
    ld a, h
    ldh [$ffe2], a
    ld a, l
    and $0f
    jr nz, jr_000_0fc2

    bit 4, l
    jr nz, jr_000_0fc2

    ld a, l
    sub $20

jr_000_0fb7:
    ldh [$ffe3], a
    inc e
    ld a, e
    ldh [$fffb], a
    ld a, $0c
    ldh [$ffa6], a
    ret


jr_000_0fc2:
    ld a, l
    jr jr_000_0fb7

jr_000_0fc5:
    inc hl
    ld a, [hl+]
    ld c, a
    ld b, $00
    ld a, [hl]
    push af
    ldh a, [$ffe2]
    ld h, a
    ldh a, [$ffe3]
    ld l, a
    add hl, bc
    pop bc
    inc de
    inc de
    jr jr_000_0f9a

    dec e
    ld de, $170a
    inc d
    inc l
    ld [hl+], a
    jr jr_000_0fff

    inc l
    ld d, $0a
    dec de
    ld [de], a
    jr jr_000_100b

    cp $73
    jr jr_000_0ffd

    jr z, @+$2e

    dec c
    ld a, [bc]
    ld [de], a
    inc e
    ld [hl+], a
    rst $38
    ldh a, [$ffa6]
    and a
    ret nz

    ldh a, [$fffb]
    dec a
    jr z, jr_000_1016

jr_000_0ffd:
    ldh [$fffb], a

jr_000_0fff:
    and $01
    ld hl, $102c
    jr nz, jr_000_100e

    ld hl, $103c
    ld a, $03

jr_000_100b:
    ld [$dff8], a

jr_000_100e:
    call Call_000_1020
    ld a, $08
    ldh [$ffa6], a
    ret


jr_000_1016:
    ld hl, $c210
    ld [hl], $00
    ld hl, $ffb3
    inc [hl]
    ret


Call_000_1020:
    ld de, $c01c
    ld b, $10

jr_000_1025:
    ld a, [hl+]
    ld [de], a
    inc e
    dec b
    jr nz, jr_000_1025

    ret


    ld a, b
    ld e, b
    ld b, $00
    ld a, b
    ld h, b
    ld b, $20
    add b
    ld e, b
    ld b, $40
    add b
    ld h, b
    ld b, $60
    ld a, b
    ld e, b
    rlca
    nop
    ld a, b
    ld h, b
    rlca
    jr nz, jr_000_0fc5

    ld e, b
    rlca
    ld b, b
    add b
    ld h, b
    rlca
    ld h, b
    ldh a, [$ffa6]
    and a
    ret nz

    ld hl, $c213
    ld [hl], $20
    ld bc, $c218
    ld hl, $2164
    push bc
    call $490d
    pop hl
    dec l
    ld a, [hl]
    and a
    jr nz, jr_000_1070

    ld [hl], $01
    ld hl, $c213
    ld [hl], $21
    ld a, $40
    ldh [$ffa6], a

jr_000_1070:
    ldh a, [$ffac]
    and $01
    jr nz, jr_000_107f

    ld hl, $c212
    inc [hl]
    ld a, [hl]
    cp $d0
    jr nc, jr_000_1083

jr_000_107f:
    call Call_000_172d
    ret


jr_000_1083:
    ld hl, $ffb3
    ld [hl], $12
    ld a, $02
    ldh [$fffd], a
    ld [$2000], a
    ret


    ldh a, [$ffa7]
    and a
    jr nz, jr_000_109e

    ld a, $01
    ld [$dff8], a
    ld a, $20
    ldh [$ffa7], a

jr_000_109e:
    xor a
    ld [$c0ab], a
    call Call_000_2488
    ldh a, [$ffa6]
    ld c, a
    and $03
    jr nz, jr_000_10bf

    ldh a, [$fffb]
    xor $01
    ldh [$fffb], a
    ld b, $fc
    jr z, jr_000_10b8

    ld b, $04

jr_000_10b8:
    ld a, [$c0df]
    add b
    ld [$c0df], a

jr_000_10bf:
    ld a, c
    cp $80
    ret nc

    and $1f
    ret nz

    ld hl, $8dd0
    ld bc, $0220
    ldh a, [$fffc]
    ld d, a

jr_000_10cf:
    ldh a, [rSTAT]
    and $03
    jr nz, jr_000_10cf

    ld a, [hl]
    and d
    ld e, a

jr_000_10d8:
    ldh a, [rSTAT]
    and $03
    jr nz, jr_000_10d8

    ld [hl], e
    inc hl
    ld a, h
    cp $8f
    jr nz, jr_000_10e8

    ld hl, $9690

jr_000_10e8:
    rrc d
    dec bc
    ld a, c
    or b
    jr nz, jr_000_10cf

    ldh a, [$fffc]
    sla a
    jr z, jr_000_10fe

    swap a
    ldh [$fffc], a
    ld a, $3f
    ldh [$ffa6], a
    ret


jr_000_10fe:
    xor a
    ld [$c0df], a
    ld [$c0d2], a
    inc a
    ldh [$fff9], a
    ld hl, $ffb3
    inc [hl]
    ret


    di
    xor a
    ldh [rLCDC], a
    ldh [$fff9], a
    ld hl, $9c00
    ld bc, $0100
    call Call_000_05be
    call Call_000_0808
    call Call_000_0ede
    ld hl, $c202
    ld [hl], $38
    inc l
    ld [hl], $10
    ld hl, $c212
    ld [hl], $78
    xor a
    ldh [rIF], a
    ldh [$ffa4], a
    ld [$c0df], a
    ldh [$fffb], a
    ld hl, $c000
    ld b, $0c

jr_000_113e:
    ld [hl+], a
    dec b
    jr nz, jr_000_113e

    call Call_000_172d
    ld a, $98
    ldh [$ffe2], a
    ld a, $a5
    ldh [$ffe3], a
    ld a, $0f
    ld [$dfe8], a
    ld a, $c3
    ldh [rLCDC], a
    ei
    ld hl, $ffb3
    inc [hl]
    ret


    ld hl, $117a
    call Call_000_0f81
    cp $ff
    ret nz

    xor a
    ldh [$fffb], a
    ld a, $99
    ldh [$ffe2], a
    ld a, $02
    ldh [$ffe3], a
    ld a, $23
    ld [$c213], a
    ld hl, $ffb3
    inc [hl]
    ret


    jr @+$13

    jr z, jr_000_11aa

    dec c
    ld a, [bc]
    ld [de], a
    inc e
    ld [hl+], a
    cp $1b
    dec c
    ld a, [bc]
    ld [de], a
    inc e
    ld [hl+], a
    rst $38
    ld hl, $11b6
    call Call_000_0f81
    ldh a, [$ffac]
    and $03
    ret nz

    ld hl, $c212
    ld a, [hl]
    cp $44
    jr c, jr_000_11a3

    dec [hl]
    call Call_000_172d
    ret


jr_000_11a3:
    ld hl, $ffb3
    inc [hl]
    ld hl, $c030

jr_000_11aa:
    ld [hl], $70
    inc l
    ld [hl], $3a
    inc l
    ld [hl], $84
    inc l
    ld [hl], $00
    ret


    dec e
    ld de, $170a
    inc d
    inc l
    ld [hl+], a
    jr @+$20

    inc l
    ld d, $0a
    dec de
    ld [de], a
    jr jr_000_11e9

    rst $38
    ldh a, [$ffac]
    and $01
    ret nz

    ld hl, $c030
    dec [hl]
    ld a, [hl+]
    cp $20
    jr c, jr_000_11e9

    ldh a, [$fffb]
    and a
    ld a, [hl]
    jr nz, jr_000_11e2

    dec [hl]
    cp $30
    ret nc

jr_000_11df:
    ldh [$fffb], a
    ret


jr_000_11e2:
    inc [hl]
    cp $50
    ret c

    xor a
    jr jr_000_11df

jr_000_11e9:
    ld [hl], $f0
    ld b, $6d
    ld hl, $98a5

jr_000_11f0:
    ldh a, [rSTAT]
    and $03
    jr nz, jr_000_11f0

jr_000_11f6:
    ldh a, [rSTAT]
    and $03
    jr nz, jr_000_11f6

    ld [hl], $2c
    inc hl
    dec b
    jr nz, jr_000_11f0

    xor a
    ldh [$fffb], a
    ld a, $99
    ldh [$ffe2], a
    ld a, $00
    ldh [$ffe3], a
    ld hl, $ffb3
    inc [hl]
    ret


    ld hl, $1236
    call Call_000_0f81
    cp $ff
    ret nz

    ld hl, $c213
    ld [hl], $24
    inc l
    inc l
    ld [hl], $00
    ld hl, $c241
    ld [hl], $7e
    inc l
    inc l
    ld [hl], $28
    inc l
    inc l
    ld [hl], $00
    ld hl, $ffb3
    inc [hl]
    ret


    add hl, hl
    ld [hl+], a
    jr jr_000_1258

    dec de
    inc l
    ld a, [de]
    ld e, $0e
    inc e
    dec e
    inc l
    ld [de], a
    inc e
    inc l
    jr @+$21

    ld c, $1b
    add hl, hl
    rst $38
    ldh a, [$ffac]
    and $03
    jr nz, jr_000_1258

    ld hl, $c213
    ld a, [hl]
    xor $01
    ld [hl], a

jr_000_1258:
    ld hl, $c240
    ld a, [hl]
    and a
    jr nz, jr_000_127f

    inc l
    inc l
    dec [hl]
    ld a, [hl]
    cp $50
    jr nz, jr_000_126e

    ld a, $80
    ld [$c200], a
    jr jr_000_127f

jr_000_126e:
    cp $40
    jr nz, jr_000_127f

    ld a, $80
    ld [$c210], a
    ld a, $40
    ldh [$ffa6], a
    ld hl, $ffb3
    inc [hl]

jr_000_127f:
    call Call_000_0eb2
    call Call_000_218f
    ldh a, [$ffe5]
    cp $03
    ret nz

    ldh a, [$ffe6]
    and a
    ret nz

    ld hl, $c240
    ld [hl], $00
    inc l
    inc l
    ld [hl], $c0
    ret


    ldh a, [$ffa6]
    and a
    ret nz

    ld hl, $c240
    ld de, $c200
    ld b, $06

jr_000_12a4:
    ld a, [hl+]
    ld [de], a
    inc e
    dec b
    jr nz, jr_000_12a4

    ld hl, $c203
    ld [hl], $26
    ld hl, $c241
    ld [hl], $f0
    ld hl, $ffb3
    inc [hl]
    ret


    call Call_000_172d
    ldh a, [$ffac]
    ld b, a
    and $01
    ret nz

    ld hl, $c240
    ld [hl], $ff
    ld hl, $c201
    dec [hl]
    ld a, [hl+]
    cp $58
    jr z, jr_000_12d4

    call Call_000_12dd
    ret


jr_000_12d4:
    ld hl, $ffb3
    inc [hl]
    ld a, $04
    ldh [$fffb], a
    ret


Call_000_12dd:
    ldh a, [$ffac]
    and $03
    ret nz

    inc l
    ld a, [hl]
    xor $01
    ld [hl], a
    ret


    call Call_000_1305
    call Call_000_218f
    ldh a, [$ffa4]
    inc a
    call z, Call_000_130f
    inc a
    call z, Call_000_130f
    ldh [$ffa4], a
    ld a, [$dfe9]
    and a
    ret nz

    ld a, $11
    ld [$dfe8], a
    ret


Call_000_1305:
    ld hl, $c202
    call Call_000_12dd
    call Call_000_172d
    ret


Call_000_130f:
    push af
    ldh a, [$fffb]
    dec a
    ldh [$fffb], a
    jr nz, jr_000_1343

    ldh [rLYC], a
    ld a, $21
    ldh [$fffb], a
    ld a, $54
    ldh [$ffe9], a
    call Call_000_1345
    ld hl, $c210
    ld de, $1376
    call Call_000_136d
    ld hl, $c220
    ld de, $137b
    call Call_000_136d
    ld hl, $c230
    ld de, $1380
    call Call_000_136d
    ld hl, $ffb3
    inc [hl]

jr_000_1343:
    pop af
    ret


Call_000_1345:
    ld hl, $c0b0
    ld b, $10
    ld a, $2c

jr_000_134c:
    ld [hl+], a
    dec b
    jr nz, jr_000_134c

    ld a, $01
    ldh [$ffea], a
    ld b, $02
    ldh a, [$ffe9]
    sub $20
    ld l, a
    ld h, $98

jr_000_135d:
    ldh a, [rSTAT]
    and $03
    jr nz, jr_000_135d

    ld [hl], $2c
    ld a, l
    sub $20
    ld l, a
    dec b
    jr nz, jr_000_135d

    ret


Call_000_136d:
    ld b, $05

jr_000_136f:
    ld a, [de]
    ld [hl+], a
    inc de
    dec b
    jr nz, jr_000_136f

    ret


    nop
    jr nc, @-$2e

    add hl, hl
    add b
    add b
    ld [hl], b
    db $10
    ld a, [hl+]
    add b
    add b
    ld b, b
    ld [hl], b
    add hl, hl
    add b
    call Call_000_1547
    ldh a, [$ffa4]
    inc a
    inc a
    ldh [$ffa4], a
    and $08
    ld b, a
    ldh a, [$ffa3]
    cp b
    ret nz

    xor $08
    ldh [$ffa3], a
    call Call_000_1345
    ldh a, [$fffb]
    dec a
    ldh [$fffb], a
    ret nz

    xor a
    ldh [$ffa4], a
    ld a, $60
    ldh [rLYC], a
    ld hl, $154e
    ld a, h
    ldh [$ffe2], a
    ld a, l
    ldh [$ffe3], a
    ld a, $f0
    ldh [$ffa6], a
    ld hl, $ffb3
    inc [hl]
    ret


Call_000_13bb:
    ld hl, $c212
    ld de, $0010
    ld b, $03

jr_000_13c3:
    dec [hl]
    ld a, [hl]
    cp $01
    jr nz, jr_000_13cd

    ld [hl], $fe
    jr jr_000_13e2

jr_000_13cd:
    cp $e0
    jr nz, jr_000_13e2

    push hl
    ldh a, [rDIV]
    dec l
    add [hl]
    and $7f
    cp $68
    jr nc, jr_000_13de

    and $3f

jr_000_13de:
    ld [hl-], a
    ld [hl], $00
    pop hl

jr_000_13e2:
    add hl, de
    dec b
    jr nz, jr_000_13c3

    ret


    call Call_000_1547
    ldh a, [$ffa6]
    and a
    ret nz

    ldh a, [$ffe2]
    ld h, a
    ldh a, [$ffe3]
    ld l, a
    ld de, $9a42

jr_000_13f7:
    ld a, [hl]
    cp $fe
    jr z, jr_000_1418

    inc hl
    ld b, a

jr_000_13fe:
    ldh a, [rSTAT]
    and $03
    jr nz, jr_000_13fe

jr_000_1404:
    ldh a, [rSTAT]
    and $03
    jr nz, jr_000_1404

    ld a, b
    ld [de], a
    inc de
    ld a, e
    cp $54
    jr z, jr_000_141c

    cp $93
    jr z, jr_000_1422

    jr jr_000_13f7

jr_000_1418:
    ld b, $2c
    jr jr_000_13fe

jr_000_141c:
    ld de, $9a87
    inc hl
    jr jr_000_13f7

jr_000_1422:
    inc hl
    ld a, [hl]
    cp $ff
    jr nz, jr_000_142d

    ld a, $ff
    ld [$c0de], a

jr_000_142d:
    ld a, h
    ldh [$ffe2], a
    ld a, l
    ldh [$ffe3], a
    ld hl, $ffb3
    inc [hl]
    ret


    call Call_000_1547
    ldh a, [$ffac]
    and $03
    ret nz

    ld hl, $c0df
    inc [hl]
    ld a, [hl]
    cp $20
    ret nz

    ld hl, $ffb3
    inc [hl]
    ld a, $50
    ldh [$ffa6], a
    ret


    call Call_000_1547
    ldh a, [$ffa6]
    and a
    ret nz

    ld hl, $ffb3
    inc [hl]
    ret


    call Call_000_1547
    ldh a, [$ffac]
    and $03
    ret nz

    ld hl, $c0df
    inc [hl]
    ld a, [hl]
    cp $50
    ret nz

    xor a
    ld [$c0df], a
    ld a, [$c0de]
    cp $ff
    ld a, $33
    jr nz, jr_000_147c

    ld a, $37

jr_000_147c:
    ldh [$ffb3], a
    ret


    call Call_000_1547
    ld hl, $c202
    inc [hl]
    ld a, [hl]
    cp $d0
    ret nz

    dec l
    ld [hl], $f0
    push hl
    call Call_000_172d
    pop hl
    dec l
    ld [hl], $ff
    ld hl, $c070
    ld de, $14bb
    ld b, $18

jr_000_149d:
    ld a, [de]
    ld [hl+], a
    inc de
    dec b
    jr nz, jr_000_149d

    ld b, $18
    xor a

jr_000_14a6:
    ld [hl+], a
    dec b
    jr nz, jr_000_14a6

    ld a, $90
    ldh [$ffa6], a
    ldh a, [$ff9a]
    inc a
    ldh [$ff9a], a
    ld [$c0e1], a
    ld hl, $ffb3
    inc [hl]
    ret


    ld c, [hl]
    call z, $0052
    ld c, [hl]
    call nc, Call_000_0053
    ld c, [hl]
    call c, $0054
    ld c, [hl]
    db $ec
    ld d, h
    nop
    ld c, [hl]
    db $f4
    ld d, l
    nop
    ld c, [hl]
    db $fc
    ld d, [hl]
    nop
    call Call_000_1547
    ldh a, [$ffa6]
    and a
    ret nz

    ld hl, $c071
    ld a, [hl]
    cp $3c
    jr z, jr_000_14e6

jr_000_14e2:
    dec [hl]
    dec [hl]
    dec [hl]
    ret


jr_000_14e6:
    ld hl, $c075
    ld a, [hl]
    cp $44
    jr nz, jr_000_14e2

    ld hl, $c079
    ld a, [hl]
    cp $4c
    jr nz, jr_000_14e2

    ld hl, $c07d
    ld a, [hl]
    cp $5c
    jr nz, jr_000_14e2

    ld hl, $c081
    ld a, [hl]
    cp $64
    jr nz, jr_000_14e2

    ld hl, $c085
    ld a, [hl]
    cp $6c
    jr nz, jr_000_14e2

    call Call_000_1520
    xor a
    ldh [$ffe4], a
    ldh [$ff99], a
    ldh [$ffb5], a
    ld [$c0a6], a
    ld a, $11
    ldh [$ffb4], a
    ret


Call_000_1520:
    ldh a, [$ff81]
    and a
    ret z

    call $7ff3

Call_000_1527:
    ld a, $02
    ldh [$fffd], a
    ld [$2000], a
    ld [$c0dc], a
    ld [$c0a4], a
    xor a
    ld [$da00], a
    ld [$c0a5], a
    ld [$c0ad], a
    ld a, $03
    ldh [rIE], a
    ld a, $0e
    ldh [$ffb3], a
    ret


Call_000_1547:
    call Call_000_1305
    call Call_000_13bb
    ret


    add hl, de
    dec de
    jr @+$0f

    ld e, $0c
    ld c, $1b
    cp $10
    inc hl
    ld [hl+], a
    jr @+$16

    jr @+$14

    cp $0d
    ld [de], a
    dec de
    ld c, $0c
    dec e
    jr @+$1d

    cp $1c
    inc hl
    jr @+$16

    ld a, [bc]
    dec c
    ld a, [bc]
    cp $19
    dec de
    jr jr_000_1584

    dec de
    ld a, [bc]
    ld d, $16
    ld c, $1b
    cp $16
    inc hl
    ld [hl+], a
    ld a, [bc]
    ld d, $0a
    ld d, $18
    dec e

jr_000_1584:
    jr jr_000_1584

    add hl, de
    dec de
    jr @+$12

    dec de
    ld a, [bc]
    ld d, $16
    ld c, $1b
    cp $1d
    inc hl
    ld de, $1b0a
    ld a, [bc]
    dec c
    ld a, [bc]
    cp $0d
    ld c, $1c
    ld [de], a
    db $10
    rla
    cp $11
    inc hl
    ld d, $0a
    dec e
    inc e
    ld e, $18
    inc d
    ld a, [bc]
    cp $1c
    jr jr_000_15cd

    rla
    dec c
    cp $11
    inc hl
    dec e
    ld a, [bc]
    rla
    ld a, [bc]
    inc d
    ld a, [bc]
    cp $0a
    ld d, $12
    dec c
    ld a, [bc]
    cp $16
    inc hl
    ld [hl+], a
    ld a, [bc]
    ld d, $0a
    rla
    ld a, [bc]
    inc d
    ld a, [bc]
    cp $0d

jr_000_15cd:
    ld c, $1c
    ld [de], a
    db $10
    rla
    cp $16
    ld a, [bc]
    inc e
    ld de, $1612

jr_000_15d9:
    jr jr_000_15d9

    inc e
    add hl, de
    ld c, $0c
    ld [de], a
    ld a, [bc]
    dec d
    inc l
    dec e
    ld de, $170a
    inc d
    inc e
    inc l
    dec e
    jr jr_000_1612

    cp $1d
    ld a, [bc]
    inc d
    ld [de], a
    cp $12
    daa
    ld e, $1c
    ld de, $fe12
    rla
    ld a, [bc]
    db $10
    ld a, [bc]
    dec e
    ld a, [bc]
    cp $14
    ld a, [bc]

Jump_000_1603:
    rla
    jr jr_000_1617

    cp $17
    ld [de], a
    inc e
    ld de, $2712
    ld a, [bc]
    jr nz, jr_000_161a

    cp $ff

jr_000_1612:
    ld hl, $c201
    ldh a, [$fff8]

jr_000_1617:
    cp [hl]
    jr z, jr_000_161f

jr_000_161a:
    inc [hl]
    call Call_000_16ec
    ret


jr_000_161f:
    ld a, $0a
    ldh [$ffb3], a
    ldh [$fff9], a
    ret


    di
    xor a
    ldh [rLCDC], a
    ldh [$ffe6], a
    call $1ecb
    call Call_000_1655
    ldh a, [$fff4]
    ldh [$ffe5], a
    call Call_000_07f0
    call Call_000_2453
    ld hl, $c201
    ld [hl], $20
    inc l
    ld [hl], $1d
    inc l
    inc l
    ld [hl], $00
    xor a
    ldh [rIF], a
    ldh [$ffb3], a
    ldh [$ffa4], a
    ld a, $c3
    ldh [rLCDC], a
    ei
    ret


Call_000_1655:
    ld hl, $ca3f
    ld bc, $0240

jr_000_165b:
    xor a
    ld [hl-], a
    dec bc
    ld a, b
    or c
    jr nz, jr_000_165b

    ret


    ldh a, [$ffac]
    and $01
    ret z

    ld hl, $c202
    ldh a, [$fff8]
    cp [hl]
    jr c, jr_000_1679

    inc [hl]
    ld hl, $c20b
    inc [hl]
    call Call_000_16ec
    ret


jr_000_1679:
    di
    ldh a, [$fff5]
    ldh [$ffe5], a
    xor a
    ldh [rLCDC], a
    ldh [$ffe6], a
    call Call_000_1655
    ld hl, $fff4
    ld [hl+], a
    ld [hl+], a
    ldh a, [$fff7]
    ld d, a
    ldh a, [$fff6]
    ld e, a
    push de
    call Call_000_07f0
    pop de
    ld a, $80
    ld [$c204], a
    ld hl, $c201
    ld a, d
    ld [hl+], a
    sub $12
    ldh [$fff8], a
    ld a, e
    ld [hl], a
    ldh a, [$ffe5]
    sub $04
    ld b, a
    rlca
    rlca
    rlca
    add b
    add b
    add $0c
    ld [$c0ab], a
    xor a
    ldh [rIF], a
    ldh [$ffa4], a
    ld a, $5b
    ldh [$ffe9], a
    call Call_000_2453
    call $1ecb
    ld a, $c3
    ldh [rLCDC], a
    ld a, $0c
    ldh [$ffb3], a
    call Call_000_078c
    ei
    ret


    ldh a, [$ffac]
    and $01
    ret z

    ld hl, $c201
    ldh a, [$fff8]
    cp [hl]
    jr z, jr_000_16e3

    dec [hl]
    call Call_000_16ec
    ret


jr_000_16e3:
    xor a
    ldh [$ffb3], a
    ld [$c204], a
    ldh [$fff9], a
    ret


Call_000_16ec:
    call Call_000_172d
    ld a, [$c20a]
    and a
    jr z, jr_000_1723

    ld a, [$c203]
    and $0f
    cp $0a
    jr nc, jr_000_1723

    ld hl, $c20b
    ld a, [$c20e]
    cp $23
    ld a, [hl]
    jr z, jr_000_1727

    and $03
    jr nz, jr_000_1723

jr_000_170d:
    ld hl, $c203
    ld a, [hl]
    cp $18
    jr z, jr_000_1723

    inc [hl]
    ld a, [hl]
    and $0f
    cp $04
    jr c, jr_000_1723

    ld a, [hl]
    and $f0
    or $01
    ld [hl], a

jr_000_1723:
    call Call_000_1d1d
    ret


jr_000_1727:
    and $01
    jr nz, jr_000_1723

    jr jr_000_170d

Call_000_172d:
    ld a, $0c
    ldh [$ff8e], a
    ld hl, $c200
    ld a, $c0
    ldh [$ff8d], a
    ld a, $05
    ldh [$ff8f], a
    ldh a, [$fffd]
    ldh [$ffe1], a
    ld a, $03
    ldh [$fffd], a
    ld [$2000], a
    call $4823
    ldh a, [$ffe1]
    ldh [$fffd], a
    ld [$2000], a
    ret


Jump_000_1752:
    ldh a, [$ffb3]
    cp $0e
    jp nc, Jump_000_1815

    jp Jump_000_1b3c


jr_000_175c:
    ldh a, [$ff80]
    bit 7, a
    jp z, Jump_000_1854

    ld bc, $ffe0
    ld a, h
    ldh [$ffb0], a
    ld a, l
    ldh [$ffaf], a
    ld a, h
    add $30
    ld h, a
    ld de, $fff4
    ld a, [hl]
    and a
    jp z, Jump_000_1854

    ld [de], a
    inc e
    add hl, bc
    ld a, [hl]
    ld [de], a
    inc e
    add hl, bc
    ld a, [hl]
    ld [de], a
    inc e
    add hl, bc
    ld a, [hl]
    ld [de], a
    inc e
    push de
    call Call_000_3efe
    pop de
    ld hl, $c201
    ld a, [hl+]
    add $10
    ld [de], a
    ldh a, [$ffa4]
    ld b, a
    ldh a, [$ffae]
    sub b
    add $08
    ld [hl+], a
    inc l
    ld [hl], $80
    ld a, $09
    ldh [$ffb3], a
    ld a, [$c0d3]
    and a
    jr nz, jr_000_17ad

    ld a, $04
    ld [$dfe8], a

jr_000_17ad:
    call $1ecb
    jp Jump_000_1854


Call_000_17b3:
    ld hl, $c207
    ld a, [hl]
    cp $01
    ret z

    ld hl, $c201
    ld a, [hl+]
    add $0b
    ldh [$ffad], a
    ldh a, [$ffa4]
    ld b, a
    ld a, [hl]
    add b
    add $fe
    ldh [$ffae], a
    call Call_000_0153
    cp $70
    jr z, jr_000_175c

    cp $e1
    jp z, Jump_000_1752

    cp $60
    jr nc, jr_000_1815

    ld a, [$c20e]
    ld b, $04
    cp $04
    jr nz, jr_000_17ec

    ld a, [$c207]
    and a
    jr nz, jr_000_17ec

    ld b, $08

jr_000_17ec:
    ldh a, [$ffae]
    add b
    ldh [$ffae], a
    call Call_000_0153
    cp $60
    jr nc, jr_000_1815

jr_000_17f8:
    ld hl, $c207
    ld a, [hl]
    cp $02
    ret z

    ld hl, $c201
    inc [hl]
    inc [hl]
    inc [hl]
    ld hl, $c20a
    ld [hl], $00
    ld a, [$c20e]
    and a
    ret nz

    ld a, $02
    ld [$c20e], a
    ret


Jump_000_1815:
jr_000_1815:
    cp $ed
    push af
    jr nz, jr_000_1839

    ld a, [$c0d3]
    and a
    jr nz, jr_000_1839

    ldh a, [$ff99]
    and a
    jr z, jr_000_1833

    cp $04
    jr z, jr_000_1839

    cp $02
    jr nz, jr_000_1839

    pop af
    call Call_000_09d7
    jr jr_000_1854

jr_000_1833:
    pop af
    call Call_000_09e8
    jr jr_000_1854

jr_000_1839:
    pop af
    cp $f4
    jr nz, jr_000_1854

    push hl
    pop de
    ld hl, $ffee
    ld a, [hl]
    and a
    jr nz, jr_000_17f8

    ld [hl], $c0
    inc l
    ld [hl], d
    inc l
    ld [hl], e
    ld a, $05
    ld [$dfe0], a
    jr jr_000_17f8

Jump_000_1854:
jr_000_1854:
    ld hl, $c201
    ld a, [hl]
    dec a
    dec a
    and $fc
    or $06
    ld [hl], a
    xor a
    ld hl, $c207
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], $01
    ld hl, $c20c
    ld a, [hl]
    cp $07
    ret c

    ld [hl], $06
    ret


Jump_000_1872:
    ldh a, [$ffee]
    and a
    ret nz

    push hl
    ld a, h
    add $30
    ld h, a
    ld a, [hl]
    pop hl
    and a
    ret z

Jump_000_187f:
    ldh a, [$ffee]
    and a
    ret nz

    push hl
    ld a, h
    add $30
    ld h, a
    ld a, [hl]
    pop hl
    and a
    jp z, Jump_000_19d8

    cp $f0
    jr z, jr_000_18b7

Jump_000_1892:
    cp $c0
    jr nz, jr_000_18be

    ld a, $ff
    ld [$c0ce], a

Jump_000_189b:
    ldh a, [$ffee]
    and a
    ret nz

    ld a, $05
    ld [$dfe0], a
    ld a, [$c201]
    sub $10
    ldh [$ffec], a
    ld a, $c0
    ldh [$ffed], a
    ldh [$fffe], a
    ld a, [$c0ce]
    and a
    jr nz, jr_000_191a

jr_000_18b7:
    ld a, $80
    ld [$c02e], a
    jr jr_000_192e

jr_000_18be:
    ldh [$ffa0], a
    ld a, $80
    ld [$c02e], a
    ld a, $07
    ld [$dfe0], a
    push hl
    pop de
    ld hl, $ffee
    ld a, [hl]
    and a
    ret nz

    ld [hl], $02
    inc l
    ld [hl], d
    inc l
    ld [hl], e
    ld a, d
    ldh [$ffb0], a
    ld a, e
    ldh [$ffaf], a
    ld a, d
    add $30
    ld d, a
    ld a, [de]
    ldh [$ffa0], a
    call Call_000_3efe
    ld hl, $c02c
    ld a, [$c201]
    sub $0b
    ld [hl+], a
    ldh [$ffc2], a
    ldh [$fff1], a
    ldh a, [$ffa4]
    ld b, a
    ldh a, [$ffae]
    ldh [$fff2], a

Call_000_18fc:
    sub b
    ld [hl+], a
    ldh [$ffc3], a
    inc l
    ld [hl], $00
    ldh a, [$ffa0]
    cp $f0
    ret z

    cp $28
    jr nz, jr_000_1916

    ldh a, [$ff99]
    cp $02
    ld a, $28
    jr nz, jr_000_1916

    ld a, $2d

jr_000_1916:
    call Call_000_2544
    ret


Jump_000_191a:
jr_000_191a:
    ldh a, [$ffee]
    and a
    ret nz

    ld a, $82
    ld [$c02e], a
    ld a, [$dfe0]
    and a
    jr nz, jr_000_192e

    ld a, $07
    ld [$dfe0], a

jr_000_192e:
    push hl
    pop de
    ld hl, $ffee
    ld [hl], $02
    inc l
    ld [hl], d
    inc l
    ld [hl], e
    ld a, d
    ldh [$ffb0], a
    ld a, e
    ldh [$ffaf], a
    call Call_000_3efe
    ld hl, $c02c
    ld a, [$c201]
    sub $0b
    ld [hl+], a
    ldh [$fff1], a
    ldh a, [$ffa4]
    ld b, a
    ldh a, [$ffae]
    ld c, a
    ldh [$fff2], a
    sub b
    ld [hl+], a
    inc l
    ld [hl], $00
    ldh [$ffeb], a
    ret


jr_000_195d:
    ldh a, [$ffee]
    and a
    ret nz

    push hl
    ld a, h
    add $30
    ld h, a
    ld a, [hl]
    pop hl
    and a
    jp nz, Jump_000_1892

    ld a, $05
    ld [$dfe0], a
    ld a, $81
    ld [$c02e], a
    ld a, [$c201]
    sub $10
    ldh [$ffec], a
    ld a, $c0
    ldh [$ffed], a
    jr jr_000_192e

Call_000_1983:
    ld a, [$c207]
    cp $01
    ret nz

    ld hl, $c201
    ld a, [hl+]
    add $fd
    ldh [$ffad], a
    ldh a, [$ffa4]
    ld b, [hl]
    add b
    add $02
    ldh [$ffae], a
    call Call_000_0153
    cp $5f
    jp z, Jump_000_1872

    cp $60
    jr nc, jr_000_19b6

    ldh a, [$ffae]
    add $fc
    ldh [$ffae], a
    call Call_000_0153
    cp $5f
    jp z, Jump_000_1872

    cp $60
    ret c

jr_000_19b6:
    call Call_000_1a62
    and a
    ret z

    cp $82
    jr z, jr_000_19d8

    cp $f4
    jp z, Jump_000_1a4e

    cp $81
    jr z, jr_000_195d

    cp $80
    jp z, Jump_000_187f

    ld a, $02
    ld [$c207], a
    ld a, $07
    ld [$dfe0], a
    ret


Jump_000_19d8:
jr_000_19d8:
    push hl
    ld a, h
    add $30
    ld h, a
    ld a, [hl]
    pop hl
    cp $c0
    jp z, Jump_000_189b

    ldh a, [$ff99]
    cp $02
    jp nz, Jump_000_191a

    push hl
    pop de
    ld hl, $ffee
    ld a, [hl]
    and a
    ret nz

    ld [hl], $01
    inc l
    ld [hl], d
    inc l
    ld [hl], e
    ld hl, $c210

Call_000_19fc:
    ld de, $0010
    ld b, $04

jr_000_1a01:
    push hl
    ld [hl], $00
    inc l
    ld a, [$c201]
    add $f3
    ld [hl], a
    inc l
    ld a, [$c202]
    add $02
    ld [hl], a
    inc l
    inc l
    inc l
    inc l
    inc l
    ld [hl], $01
    inc l
    ld [hl], $07
    pop hl
    add hl, de
    dec b
    jr nz, jr_000_1a01

    ld hl, $c222
    ld a, [hl]
    sub $04
    ld [hl], a
    ld hl, $c242
    ld a, [hl]
    sub $04
    ld [hl], a
    ld hl, $c238
    ld [hl], $0b
    ld hl, $c248
    ld [hl], $0b
    ldh a, [$ffa4]
    ldh [$fff3], a
    ld a, $02
    ld [$dff8], a
    ld de, $0050
    call Call_000_0166
    ld a, $02
    ld [$c207], a
    ret


Jump_000_1a4e:
    push hl
    pop de
    ld hl, $ffee
    ld a, [hl]
    and a
    ret nz

    ld [hl], $c0
    inc l
    ld [hl], d
    inc l
    ld [hl], e
    ld a, $05
    ld [$dfe0], a
    ret


Call_000_1a62:
    push hl
    push af
    ld b, a
    ldh a, [$ffb4]
    and $f0
    swap a
    dec a
    sla a
    ld e, a
    ld d, $00
    ld hl, $1a8a
    add hl, de
    ld e, [hl]
    inc hl
    ld d, [hl]

jr_000_1a78:
    ld a, [de]
    cp $fd
    jr z, jr_000_1a83

    cp b
    jr z, jr_000_1a86

    inc de
    jr jr_000_1a78

jr_000_1a83:
    pop af
    pop hl
    ret


jr_000_1a86:
    pop af
    pop hl
    xor a
    ret


    sub h
    ld a, [de]
    sbc c
    ld a, [de]
    sbc [hl]
    ld a, [de]
    and b
    ld a, [de]
    and d
    ld a, [de]
    ld l, b
    ld l, c
    ld l, d
    ld a, h
    db $fd
    ld h, b
    ld h, c
    ld h, e
    ld a, h
    db $fd
    ld a, h
    db $fd
    ld a, h
    db $fd
    ld a, h
    db $fd

Call_000_1aa4:
    ldh a, [$ffb3]
    cp $0e
    jr nc, jr_000_1b03

    ld de, $0701
    ldh a, [$ff99]
    cp $02
    jr nz, jr_000_1abd

    ld a, [$c203]
    cp $18
    jr z, jr_000_1abd

    ld de, $0702

jr_000_1abd:
    ld hl, $c201
    ld a, [hl+]
    add d
    ldh [$ffad], a
    ld a, [$c205]
    ld b, [hl]
    ld c, $fa
    and a
    jr nz, jr_000_1acf

    ld c, $06

jr_000_1acf:
    ld a, c
    add b
    ld b, a
    ldh a, [$ffa4]
    add b
    ldh [$ffae], a
    push de
    call Call_000_0153
    call Call_000_1a62
    pop de
    and a
    jr z, jr_000_1afe

    cp $60
    jr c, jr_000_1afe

    cp $f4
    jr z, jr_000_1b05

    cp $77
    jr z, jr_000_1b1a

    cp $f2
    jr z, jr_000_1b3c

jr_000_1af2:
    ld hl, $c20b
    inc [hl]
    ld a, $02
    ld [$c20e], a
    ld a, $ff
    ret


jr_000_1afe:
    ld d, $fc
    dec e
    jr nz, jr_000_1abd

jr_000_1b03:
    xor a
    ret


jr_000_1b05:
    push hl
    pop de
    ld hl, $ffee
    ld a, [hl]
    and a
    ret nz

    ld [hl], $c0
    inc l
    ld [hl], d
    inc l
    ld [hl], e
    ld a, $05
    ld [$dfe0], a
    xor a
    ret


jr_000_1b1a:
    ldh a, [$fff9]
    and a
    jr z, jr_000_1af2

    ld a, $0b
    ldh [$ffb3], a
    ld a, $80
    ld [$c204], a
    ld hl, $c202
    ld a, [hl-]
    add $18
    ldh [$fff8], a
    ld a, [hl]
    and $f8
    add $06
    ld [hl], a
    call $1ecb
    ld a, $ff
    ret


Call_000_1b3c:
Jump_000_1b3c:
jr_000_1b3c:
    ldh a, [$ff99]
    cp $02
    ld b, $ff
    jr z, jr_000_1b49

    ld b, $0f
    xor a
    ldh [$ff99], a

jr_000_1b49:
    ld a, [$c203]
    and b
    ld [$c203], a
    ld b, a
    and $0f
    cp $0a
    jr nc, jr_000_1b5d

    ld a, b
    and $f0
    ld [$c203], a

jr_000_1b5d:
    ld a, $07
    ldh [$ffb3], a
    ld a, [$d007]
    and a
    jr nz, jr_000_1b70

    ld a, $01
    ld [$dfe8], a
    ld a, $f0
    ldh [$ffa6], a

jr_000_1b70:
    call $1ecb
    xor a
    ld [$c200], a
    ld [$da1d], a
    ldh [rTMA], a
    ret


Call_000_1b7d:
    xor a
    ld [$c0e2], a
    ldh a, [$fffe]
    and a
    call nz, Call_000_1bf6
    ld hl, $ffee
    ld a, [hl]
    cp $01
    jr z, jr_000_1bb1

    cp $02
    jp z, Jump_000_1bee

    cp $c0
    jr z, jr_000_1bb1

    cp $04
    ret nz

    ld [hl], $00
    inc l
    ld d, [hl]
    inc l
    ld e, [hl]
    ld a, [$c02e]
    cp $82
    jr z, jr_000_1baf

    cp $81
    call z, Call_000_1bf6
    ld a, $7f

jr_000_1baf:
    ld [de], a
    ret


jr_000_1bb1:
    ld b, [hl]
    ld [hl], $00

jr_000_1bb4:
    inc l
    ld d, [hl]
    inc l
    ld e, [hl]
    ld a, $2c
    ld [de], a
    ld a, b
    cp $c0
    jr z, jr_000_1bf2

    ld hl, $ffe0
    add hl, de
    ld a, [hl]
    cp $f4
    ret nz

    ld [hl], $2c
    ld a, $05
    ld [$dfe0], a
    ld a, h
    ldh [$ffb0], a
    ld a, l
    ldh [$ffaf], a
    call Call_000_3efe
    ldh a, [$ffa4]
    ld b, a
    ldh a, [$ffae]
    sub b
    ldh [$ffeb], a
    ldh a, [$ffad]
    add $14
    ldh [$ffec], a
    ld a, $c0
    ldh [$ffed], a
    call Call_000_1bf6
    ret


Jump_000_1bee:
    ld [hl], $03
    jr jr_000_1bb4

jr_000_1bf2:
    call Call_000_1bf6
    ret


Call_000_1bf6:
    ldh a, [$ff9f]
    and a
    ret nz

    push de
    push hl
    ld de, $0100
    call Call_000_0166
    pop hl
    pop de
    ldh a, [$fffa]
    add $01
    daa
    ldh [$fffa], a
    and a
    jr nz, jr_000_1c12

    inc a
    ld [$c0a3], a

Call_000_1c12:
jr_000_1c12:
    ldh a, [$fffa]
    ld b, a
    and $0f
    ld [$982a], a
    ld a, b
    and $f0
    swap a
    ld [$9829], a
    xor a
    ldh [$fffe], a
    inc a
    ld [$c0e2], a
    ret


Call_000_1c2a:
    ldh a, [$ff9f]
    and a
    ret nz

    ld a, [$c0a3]
    or a
    ret z

    cp $ff
    ld a, [$da15]
    jr z, jr_000_1c6c

    cp $99
    jr z, jr_000_1c5e

    push af
    ld a, $08
    ld [$dfe0], a
    ldh [$ffd3], a
    pop af
    add $01

jr_000_1c49:
    daa
    ld [$da15], a

Call_000_1c4d:
    ld a, [$da15]
    ld b, a
    and $0f
    ld [$9807], a
    ld a, b
    and $f0
    swap a
    ld [$9806], a

jr_000_1c5e:
    xor a
    ld [$c0a3], a
    ret


jr_000_1c63:
    ld a, $39
    ldh [$ffb3], a
    ld [$c0a4], a
    jr jr_000_1c5e

jr_000_1c6c:
    and a
    jr z, jr_000_1c63

    sub $01
    jr jr_000_1c49

    ld hl, $9c00
    ld de, $1cce
    ld b, $11

jr_000_1c7b:
    ld a, [de]
    ld c, a

jr_000_1c7d:
    ldh a, [rSTAT]
    and $03
    jr nz, jr_000_1c7d

jr_000_1c83:
    ldh a, [rSTAT]
    and $03
    jr nz, jr_000_1c83

    ld [hl], c
    inc l
    inc de
    dec b
    jr nz, jr_000_1c7b

    ld a, $10
    ld [$dfe8], a
    ldh a, [$ffb4]
    ld [$c0a8], a
    ld a, [$c0a2]
    and $f0
    swap a
    ld b, a
    ld a, [$c0a6]
    add b
    cp $0a
    jr c, jr_000_1cab

    ld a, $09

jr_000_1cab:
    ld [$c0a6], a
    ld hl, $c000
    xor a
    ld b, $a0

jr_000_1cb4:
    ld [hl+], a
    dec b
    jr nz, jr_000_1cb4

    ld [$da1d], a
    ldh [rTMA], a
    ld hl, $ff4a
    ld [hl], $8f
    inc hl
    ld [hl], $07
    ld a, $ff
    ldh [$fffb], a
    ld hl, $ffb3
    inc [hl]
    ret


    inc l
    inc l
    inc l
    inc l
    inc l
    db $10
    ld a, [bc]
    ld d, $0e
    inc l
    inc l
    jr jr_000_1cfa

    ld c, $1b
    inc l
    inc l
    ld a, [$c0ad]
    and a
    call nz, Call_000_1527
    ret


    ld hl, $9c00
    ld de, $1d0b
    ld c, $09

jr_000_1cef:
    ld a, [de]
    ld b, a

jr_000_1cf1:
    ldh a, [rSTAT]
    and $03
    jr nz, jr_000_1cf1

    ld [hl], b
    inc l
    inc de

jr_000_1cfa:
    dec c
    jr nz, jr_000_1cef

    ld hl, $ff40
    set 5, [hl]
    ld a, $a0
    ldh [$ffa6], a
    ld hl, $ffb3
    inc [hl]
    ret


    inc l
    dec e
    ld [de], a
    ld d, $0e
    inc l
    ld e, $19
    inc l
    ldh a, [$ffa6]
    and a
    ret nz

    ld a, $01
    ldh [$ffb3], a
    ret


Call_000_1d1d:
    ld hl, $c20d
    ld a, [hl]
    cp $01
    jr nz, jr_000_1d31

    dec l
    ld a, [hl]
    and a
    jr nz, jr_000_1d2f

    inc l
    ld [hl], $00
    jr jr_000_1d68

jr_000_1d2f:
    dec [hl]
    ret


jr_000_1d31:
    ld hl, $c20c
    ld a, [hl+]
    cp $06
    jr nz, jr_000_1d40

    inc l
    ld a, [hl]
    and a
    jr nz, jr_000_1d40

    ld [hl], $02

jr_000_1d40:
    ld de, $c207
    ldh a, [$ff80]
    bit 7, a
    jr nz, jr_000_1d7e

jr_000_1d49:
    bit 4, a
    jr nz, jr_000_1da3

    bit 5, a
    jp nz, Jump_000_1e37

    ld hl, $c20c
    ld a, [hl]
    and a
    jr z, jr_000_1d62

    xor a
    ld [$c20e], a
    dec [hl]
    inc l
    ld a, [hl]
    jr jr_000_1d49

jr_000_1d62:
    inc l
    ld [hl], $00
    ld a, [de]
    and a
    ret nz

jr_000_1d68:
    ld a, [$c207]
    and a
    ret nz

    ld hl, $c203
    ld a, [hl]
    and $f0
    ld [hl], a
    ld a, $01
    ld [$c20b], a
    xor a
    ld [$c20e], a
    ret


jr_000_1d7e:
    push af
    ldh a, [$ff99]
    cp $02
    jr nz, jr_000_1d9a

    ld a, [de]
    and a
    jr nz, jr_000_1d9a

    ld a, $18
    ld [$c203], a
    ldh a, [$ff80]
    and $30
    jr nz, jr_000_1d9d

    ld a, [$c20c]
    and a
    jr z, jr_000_1d9d

jr_000_1d9a:
    pop af
    jr jr_000_1d49

jr_000_1d9d:
    xor a
    ld [$c20c], a
    pop af
    ret


jr_000_1da3:
    ld hl, $c20d
    ld a, [hl]
    cp $20
    jr nz, jr_000_1dae

    jp Jump_000_1e3f


jr_000_1dae:
    ld hl, $c205
    ld [hl], $00
    call Call_000_1aa4
    and a
    ret nz

    ldh a, [$ff80]
    bit 4, a
    jr z, jr_000_1ddb

    ld a, [$c203]
    cp $18
    jr nz, jr_000_1dcf

    ld a, [$c203]
    and $f0
    or $01
    ld [$c203], a

jr_000_1dcf:
    ld hl, $c20c
    ld a, [hl]
    cp $06
    jr z, jr_000_1ddb

    inc [hl]
    inc l
    ld [hl], $10

jr_000_1ddb:
    ld hl, $c202
    ldh a, [$fff9]
    and a
    jr nz, jr_000_1e18

    ld a, [$c0d2]
    cp $07
    jr c, jr_000_1df0

    ldh a, [$ffa4]
    and $0c
    jr z, jr_000_1e18

jr_000_1df0:
    ld a, $50
    cp [hl]
    jr nc, jr_000_1e18

    call Call_000_1eab
    ld b, a
    ld hl, $ffa4
    add [hl]
    ld [hl], a
    call Call_000_1e9b
    call Call_000_2c96
    ld hl, $c001
    ld de, $0004
    ld c, $03

jr_000_1e0c:
    ld a, [hl]
    sub b
    ld [hl], a
    add hl, de
    dec c
    jr nz, jr_000_1e0c

jr_000_1e13:
    ld hl, $c20b
    inc [hl]
    ret


jr_000_1e18:
    call Call_000_1eab
    add [hl]
    ld [hl], a
    ldh a, [$ffb3]
    cp $0d
    jr z, jr_000_1e13

    ld a, [$c0d2]
    and a
    jr z, jr_000_1e13

    ldh a, [$ffa4]
    and $fc
    ldh [$ffa4], a
    ld a, [hl]
    cp $a0
    jr c, jr_000_1e13

    jp Jump_000_1b3c


Jump_000_1e37:
    ld hl, $c20d
    ld a, [hl]
    cp $10
    jr nz, jr_000_1e58

Jump_000_1e3f:
    ld [hl], $01
    dec l
    ld [hl], $08
    ld a, [$c207]
    and a
    ret nz

    ld hl, $c203
    ld a, [hl]
    and $f0
    or $05
    ld [hl], a
    ld a, $01
    ld [$c20b], a
    ret


jr_000_1e58:
    ld hl, $c205
    ld [hl], $20
    call Call_000_1aa4
    and a
    ret nz

    ld hl, $c202
    ld a, [hl]
    cp $0f
    jr c, jr_000_1e96

    push hl
    ldh a, [$ff80]
    bit 5, a
    jr z, jr_000_1e8e

    ld a, [$c203]
    cp $18
    jr nz, jr_000_1e82

    ld a, [$c203]
    and $f0
    or $01
    ld [$c203], a

jr_000_1e82:
    ld hl, $c20c
    ld a, [hl]
    cp $06
    jr z, jr_000_1e8e

    inc [hl]
    inc l
    ld [hl], $20

jr_000_1e8e:
    pop hl
    call Call_000_1eab
    cpl
    inc a
    add [hl]
    ld [hl], a

jr_000_1e96:
    ld hl, $c20b
    dec [hl]
    ret


Call_000_1e9b:
    ld hl, $c031
    ld de, $0004
    ld c, $08

jr_000_1ea3:
    ld a, [hl]
    sub b
    ld [hl], a
    add hl, de
    dec c
    jr nz, jr_000_1ea3

    ret


Call_000_1eab:
    push de
    push hl
    ld hl, $1ec5
    ld a, [$c20e]
    ld e, a
    ld d, $00
    ld a, [$c20f]
    xor $01
    ld [$c20f], a
    add e
    ld e, a
    add hl, de
    ld a, [hl]
    pop hl
    pop de
    ret


    nop
    ld bc, $0101
    ld bc, $e502
    push bc
    push de
    ld hl, $c01c
    ld b, $34
    xor a

jr_000_1ed4:
    ld [hl+], a
    dec b
    jr nz, jr_000_1ed4

    ld hl, $c000
    ld b, $0b

jr_000_1edd:
    ld [hl+], a
    dec b
    jr nz, jr_000_1edd

    ldh [$ffa9], a
    ldh [$ffaa], a
    ldh [$ffab], a
    ld hl, $c210
    ld de, $0010
    ld b, $04
    ld a, $80

jr_000_1ef1:
    ld [hl], a
    add hl, de
    dec b
    jr nz, jr_000_1ef1

    pop de
    pop bc
    pop hl
    ret


Call_000_1efa:
    ldh a, [$ffac]
    and $03
    ret nz

    ld a, [$c0d3]
    and a
    ret z

    cp $01
    jr z, jr_000_1f19

    dec a
    ld [$c0d3], a
    ld a, [$c200]
    xor $80
    ld [$c200], a
    ld a, [$dfe9]
    and a
    ret nz

jr_000_1f19:
    xor a
    ld [$c0d3], a
    ld [$c200], a
    call Call_000_078c
    ret


Call_000_1f24:
    ld b, $01
    ld hl, $ffa9
    ld de, $c001

jr_000_1f2c:
    ld a, [hl+]
    and a
    jr nz, jr_000_1f38

jr_000_1f30:
    inc e
    inc e
    inc e
    inc e
    dec b
    jr nz, jr_000_1f2c

    ret


jr_000_1f38:
    push hl
    push de
    push bc
    dec l
    ld a, [$c0a9]
    and a
    jr z, jr_000_1f52

    dec a
    ld [$c0a9], a
    bit 0, [hl]
    jr z, jr_000_1fac

    ld a, [de]
    inc a
    inc a
    ld [de], a
    cp $a2
    jr c, jr_000_1f59

jr_000_1f52:
    xor a
    res 0, e
    ld [de], a
    ld [hl], a
    jr jr_000_1f89

jr_000_1f59:
    add $03
    push af
    dec e
    ld a, [de]
    ldh [$ffad], a
    pop af
    call Call_000_1fc9
    jr c, jr_000_1f6c

    ld a, [hl]
    and $fc
    or $02
    ld [hl], a

jr_000_1f6c:
    bit 2, [hl]
    jr z, jr_000_1f91

    ld a, [de]
    dec a
    dec a
    ld [de], a
    cp $10
    jr c, jr_000_1f52

    sub $01
    ldh [$ffad], a

Call_000_1f7c:
    inc e
    ld a, [de]
    call Call_000_1fc9
    jr c, jr_000_1f89

    ld a, [hl]
    and $f3
    or $08
    ld [hl], a

jr_000_1f89:
    pop bc
    pop de
    pop hl
    call Call_000_2001
    jr jr_000_1f30

jr_000_1f91:
    ld a, [de]
    inc a
    inc a
    ld [de], a
    cp $a8
    jr nc, jr_000_1f52

    add $04
    ldh [$ffad], a
    inc e
    ld a, [de]
    call Call_000_1fc9
    jr c, jr_000_1f89

    ld a, [hl]
    and $f3
    or $04
    ld [hl], a
    jr jr_000_1f89

jr_000_1fac:
    ld a, [de]
    dec a
    dec a
    ld [de], a
    cp $04
    jr c, jr_000_1f52

    sub $02
    push af
    dec e
    ld a, [de]
    ldh [$ffad], a
    pop af
    call Call_000_1fc9
    jr c, jr_000_1f6c

    ld a, [hl]
    and $fc
    or $01
    ld [hl], a
    jr jr_000_1f6c

Call_000_1fc9:
    ld b, a
    ldh a, [$ffa4]
    add b
    ldh [$ffae], a
    push de
    push hl
    call Call_000_0153
    cp $f4
    jr nz, jr_000_1ff2

    ldh a, [$ffb3]
    cp $0d
    jr z, jr_000_1ffc

    push hl
    pop de
    ld hl, $ffee
    ld a, [hl]
    and a
    jr nz, jr_000_1ffc

    ld [hl], $c0
    inc l
    ld [hl], d
    inc l
    ld [hl], e
    ld a, $05
    ld [$dfe0], a

jr_000_1ff2:
    cp $82
    call z, Call_000_208e
    cp $80
    call z, Call_000_208e

jr_000_1ffc:
    pop hl
    pop de
    cp $60
    ret


Call_000_2001:
    push hl
    push de
    push bc
    ld b, $0a
    ld hl, $d100

jr_000_2009:
    ld a, [hl]
    cp $ff
    jr nz, jr_000_2020

jr_000_200e:
    push de
    ld de, $0010
    add hl, de
    pop de
    dec b
    jr nz, jr_000_2009

    pop bc
    pop de
    pop hl
    ret


jr_000_201b:
    pop hl
    pop de
    pop bc
    jr jr_000_200e

jr_000_2020:
    push bc
    push de
    push hl
    ld bc, $000a
    add hl, bc
    bit 7, [hl]
    jr nz, jr_000_201b

    ld c, [hl]
    inc l
    inc l
    ld a, [hl]
    ldh [$ff9b], a
    ld a, [de]
    ldh [$ffa2], a
    add $04
    ldh [$ff8f], a
    dec e
    ld a, [de]
    ldh [$ffa0], a
    ld a, [de]
    add $03
    ldh [$ffa1], a
    pop hl
    push hl
    call Call_000_0aa6
    and a
    jr z, jr_000_201b

    dec l
    dec l
    dec l
    call Call_000_0a07
    push de
    ldh a, [$ffb3]

Call_000_2052:
    cp $0d
    jr nz, jr_000_205b

    call Call_000_2aa4
    jr jr_000_205e

jr_000_205b:
    call Call_000_2a5f

jr_000_205e:
    pop de
    and a
    jr z, jr_000_201b

    push af
    ld a, [de]
    sub $08
    ldh [$ffec], a
    inc e
    ld a, [de]
    ldh [$ffeb], a
    pop af
    cp $ff
    jr nz, jr_000_207a

    ld a, $03
    ld [$dfe0], a
    ldh a, [$ff9e]
    ldh [$ffed], a

jr_000_207a:
    xor a
    ld [de], a
    dec e
    ld [de], a
    ld hl, $ffab
    bit 3, e
    jr nz, jr_000_208b

    dec l
    bit 2, e
    jr nz, jr_000_208b

    dec l

jr_000_208b:
    ld [hl], a
    jr jr_000_201b

Call_000_208e:
    push hl
    push bc
    push de
    push af
    ldh a, [$ffb3]
    cp $0d
    jr nz, jr_000_2105

    push hl
    pop de
    ld hl, $ffee
    ld a, [hl]
    and a
    jr nz, jr_000_2105

    ld [hl], $01
    inc l
    ld [hl], d
    inc l
    ld [hl], e
    pop af
    push af
    cp $80
    jr nz, jr_000_20b8

    ld a, d
    add $30
    ld d, a
    ld a, [de]
    and a
    jr z, jr_000_20b8

    call Call_000_2544

jr_000_20b8:
    ld hl, $c210
    ld de, $0010
    ld b, $04

jr_000_20c0:
    push hl
    ld [hl], $00
    inc l
    ldh a, [$ffad]
    add $00
    ld [hl], a
    inc l
    ldh a, [$ffa1]
    add $00
    ld [hl], a
    inc l
    inc l
    inc l
    inc l
    inc l
    ld [hl], $01
    inc l
    ld [hl], $07
    pop hl
    add hl, de
    dec b
    jr nz, jr_000_20c0

    ld hl, $c222
    ld a, [hl]
    sub $04
    ld [hl], a
    ld hl, $c242
    ld a, [hl]
    sub $04
    ld [hl], a
    ld hl, $c238
    ld [hl], $0b
    ld hl, $c248
    ld [hl], $0b
    ldh a, [$ffa4]
    ldh [$fff3], a
    ld de, $0050
    call Call_000_0166
    ld a, $02
    ld [$dff8], a

jr_000_2105:
    pop af
    pop de
    pop bc
    pop hl
    ret


Call_000_210a:
    ldh a, [$ff9f]
    and a
    ret z

    ld a, [$c0db]
    ldh [$ff80], a
    ret


    nop
    add [hl]
    ld [hl-], a
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $0000
    rrca
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $0000
    rrca
    nop
    jr nz, jr_000_213b

jr_000_213b:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $0000
    rrca
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $0000
    rrca
    nop
    jr nz, jr_000_215b

jr_000_215b:
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
    inc b
    inc bc
    inc bc
    ld [bc], a
    ld [bc], a
    ld [bc], a
    ld [bc], a
    ld [bc], a
    ld [bc], a
    ld [bc], a
    ld [bc], a
    ld [bc], a
    ld bc, $0101
    ld bc, $0101
    ld bc, $0100
    nop
    ld bc, $0000
    ld a, a

jr_000_217f:
    ld a, $03
    ldh [$ffea], a
    ldh a, [$ffa4]
    ld b, a
    ld a, [$c0aa]
    cp b
    ret z

    xor a
    ldh [$ffea], a
    ret


Call_000_218f:
    ldh a, [$ffea]
    and a
    jr nz, jr_000_217f

    ldh a, [$ffa4]
    and $08
    ld hl, $ffa3
    cp [hl]
    ret nz

    ld a, [hl]
    xor $08
    ld [hl], a
    and a
    jr nz, jr_000_21a8

    ld hl, $c0ab
    inc [hl]

Call_000_21a8:
jr_000_21a8:
    ld b, $10
    ld hl, $c0b0
    ld a, $2c

jr_000_21af:
    ld [hl+], a
    dec b
    jr nz, jr_000_21af

    ldh a, [$ffe6]
    and a
    jr z, jr_000_21c0

    ldh a, [$ffe7]
    ld h, a
    ldh a, [$ffe8]
    ld l, a
    jr jr_000_21df

jr_000_21c0:
    ld hl, $4000
    ldh a, [$ffe4]
    add a
    ld e, a
    ld d, $00
    add hl, de
    ld e, [hl]
    inc hl
    ld d, [hl]
    push de
    pop hl
    ldh a, [$ffe5]
    add a
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl+]
    cp $ff
    jr z, jr_000_2222

    ld e, a
    ld d, [hl]
    push de
    pop hl

Jump_000_21df:
jr_000_21df:
    ld a, [hl+]
    cp $fe
    jr z, jr_000_2227

    ld de, $c0b0
    ld b, a
    and $f0
    swap a
    add e
    ld e, a
    ld a, b
    and $0f
    jr nz, jr_000_21f5

    ld a, $10

jr_000_21f5:
    ld b, a

jr_000_21f6:
    ld a, [hl+]
    cp $fd
    jr z, jr_000_2245

    ld [de], a
    cp $70
    jr nz, jr_000_2205

    call Call_000_22a0
    jr jr_000_221c

jr_000_2205:
    cp $80

Call_000_2207:
    jr nz, jr_000_220e

    call Call_000_2318
    jr jr_000_221c

jr_000_220e:
    cp $5f
    jr nz, jr_000_2217

    call Call_000_2318
    jr jr_000_221c

jr_000_2217:
    cp $81
    call z, Call_000_2318

jr_000_221c:
    inc e
    dec b
    jr nz, jr_000_21f6

    jr jr_000_21df

jr_000_2222:
    ld hl, $c0d2
    inc [hl]
    ret


jr_000_2227:
    ld a, h
    ldh [$ffe7], a
    ld a, l
    ldh [$ffe8], a
    ldh a, [$ffe6]
    inc a
    cp $14
    jr nz, jr_000_2239

    ld hl, $ffe5
    inc [hl]
    xor a

jr_000_2239:
    ldh [$ffe6], a
    ldh a, [$ffa4]
    ld [$c0aa], a
    ld a, $01
    ldh [$ffea], a
    ret


jr_000_2245:
    ld a, [hl]

jr_000_2246:
    ld [de], a
    inc e
    dec b
    jr nz, jr_000_2246

    inc hl
    jp Jump_000_21df


Call_000_224f:
    ldh a, [$ffea]
    cp $01
    ret nz

    ldh a, [$ffe9]
    ld l, a
    inc a
    cp $60
    jr nz, jr_000_225e

    ld a, $40

jr_000_225e:
    ldh [$ffe9], a
    ld h, $98
    ld de, $c0b0
    ld b, $10

jr_000_2267:
    push hl
    ld a, h
    add $30
    ld h, a
    ld [hl], $00
    pop hl
    ld a, [de]
    ld [hl], a
    cp $70
    jr nz, jr_000_227a

    call Call_000_22f4
    jr jr_000_2291

jr_000_227a:
    cp $80
    jr nz, jr_000_2283

    call Call_000_235a
    jr jr_000_2291

jr_000_2283:
    cp $5f
    jr nz, jr_000_228c

    call Call_000_235a
    jr jr_000_2291

jr_000_228c:
    cp $81
    call z, Call_000_235a

jr_000_2291:
    inc e
    push de
    ld de, $0020
    add hl, de
    pop de
    dec b
    jr nz, jr_000_2267

    ld a, $02
    ldh [$ffea], a
    ret


Call_000_22a0:
    push hl
    push de
    push bc
    ldh a, [$fff9]
    and a
    jr nz, jr_000_22f0

    ldh a, [$fffd]
    ldh [$ffe1], a
    ld a, $03
    ldh [$fffd], a
    ld [$2000], a
    ldh a, [$ffe4]
    add a
    ld e, a
    ld d, $00
    ld hl, $651c
    add hl, de
    ld e, [hl]
    inc hl
    ld d, [hl]
    push de
    pop hl

jr_000_22c2:
    ldh a, [$ffe5]
    cp [hl]
    jr z, jr_000_22d4

    ld a, [hl]
    cp $ff
    jr z, jr_000_22e9

    inc hl

jr_000_22cd:
    inc hl
    inc hl
    inc hl
    inc hl
    inc hl
    jr jr_000_22c2

jr_000_22d4:
    ldh a, [$ffe6]
    inc hl
    cp [hl]
    jr nz, jr_000_22cd

    inc hl
    ld de, $fff4
    ld a, [hl+]
    ld [de], a
    inc e
    ld a, [hl+]
    ld [de], a
    inc e
    ld a, [hl+]
    ld [de], a
    inc e
    ld a, [hl]
    ld [de], a

jr_000_22e9:
    ldh a, [$ffe1]
    ldh [$fffd], a
    ld [$2000], a

jr_000_22f0:
    pop bc
    pop de
    pop hl
    ret


Call_000_22f4:
    ldh a, [$fff4]
    and a
    ret z

    push hl
    push de
    ld de, $ffe0
    push af
    ld a, h
    add $30
    ld h, a
    pop af
    ld [hl], a
    ldh a, [$fff5]
    add hl, de
    ld [hl], a
    ldh a, [$fff6]
    add hl, de
    ld [hl], a
    ldh a, [$fff7]
    add hl, de
    ld [hl], a
    xor a
    ldh [$fff4], a
    ldh [$fff5], a
    pop de
    pop hl
    ret


Call_000_2318:
    push hl
    push de
    push bc
    ldh a, [$fffd]
    ldh [$ffe1], a
    ld a, $03
    ldh [$fffd], a
    ld [$2000], a
    ldh a, [$ffe4]
    add a
    ld e, a
    ld d, $00
    ld hl, $6536
    add hl, de
    ld e, [hl]
    inc hl
    ld d, [hl]
    push de
    pop hl

jr_000_2335:
    ldh a, [$ffe5]
    cp [hl]
    jr z, jr_000_2344

    ld a, [hl]
    cp $ff
    jr z, jr_000_234f

    inc hl

jr_000_2340:
    inc hl
    inc hl
    jr jr_000_2335

jr_000_2344:
    ldh a, [$ffe6]
    inc hl
    cp [hl]
    jr nz, jr_000_2340

    inc hl
    ld a, [hl]
    ld [$c0cd], a

jr_000_234f:
    ldh a, [$ffe1]
    ldh [$fffd], a
    ld [$2000], a
    pop bc
    pop de
    pop hl
    ret


Call_000_235a:
    ld a, [$c0cd]
    and a
    ret z

    push hl
    push af
    ld a, h
    add $30
    ld h, a
    pop af
    ld [hl], a
    xor a
    ld [$c0cd], a
    pop hl
    ret


    ldh a, [$ffb2]
    and a
    ret nz

    call Call_000_218f
    call $4fb2
    ld a, [$d007]
    and a
    call nz, Call_000_1b3c
    call Call_000_0837
    call $4fec
    call $5118
    ldh a, [$fffd]
    ldh [$ffe1], a
    ld a, $03
    ldh [$fffd], a
    ld [$2000], a
    call $498b
    ld bc, $c218
    ld hl, $2164
    call $490d
    ld bc, $c228
    ld hl, $2164
    call $490d
    ld bc, $c238
    ld hl, $2164
    call $490d
    ld bc, $c248
    ld hl, $2164
    call $490d
    call $4aea
    call $4b8a
    call $4bb5
    ldh a, [$ffe1]
    ldh [$fffd], a
    ld [$2000], a
    call Call_000_2488
    ldh a, [$fffd]
    ldh [$ffe1], a
    ld a, $02
    ldh [$fffd], a
    ld [$2000], a
    call $5844
    ldh a, [$ffe1]
    ldh [$fffd], a
    ld [$2000], a
    call Call_000_172d
    call $515e
    call Call_000_1efa
    ldh a, [$ffac]
    and $03
    ret nz

    ld a, [$c203]
    xor $01
    ld [$c203], a
    ret


Call_000_23f8:
    ld a, [$d014]
    and a
    ret z

    ldh a, [$ffb3]
    cp $0d
    ret nc

    ldh a, [$ffac]
    and $07
    ret nz

    ldh a, [$ffac]
    bit 3, a
    jr z, jr_000_2412

    ld hl, $c600
    jr jr_000_2420

jr_000_2412:
    ld hl, $3faf
    ldh a, [$ffb4]
    and $f0
    sub $10
    rrca
    ld d, $00
    ld e, a
    add hl, de

jr_000_2420:
    ld de, $95d1
    ld b, $08

jr_000_2425:
    ld a, [hl+]
    ld [de], a
    inc de
    inc de
    dec b
    jr nz, jr_000_2425

    ret


    nop
    nop
    ld bc, $0101
    nop
    nop
    ld bc, $0001
    ld bc, $3e00
    inc c
    ld [$c0ab], a
    call Call_000_2453
    xor a
    ld [$d007], a
    ld hl, $242d
    ldh a, [$ffe4]
    ld d, $00
    ld e, a
    add hl, de
    ld a, [hl]
    ld [$d014], a
    ret


Call_000_2453:
    ld hl, $401a
    ldh a, [$ffe4]
    rlca
    ld d, $00
    ld e, a
    add hl, de
    ld a, [hl+]
    ld e, a
    ld a, [hl]
    ld d, a
    ld h, d
    ld l, e
    ld a, [$c0ab]
    ld b, a

jr_000_2467:
    ld a, [hl]
    cp b
    jr nc, jr_000_2470

    inc hl
    inc hl
    inc hl
    jr jr_000_2467

jr_000_2470:
    ld a, l
    ld [$d010], a
    ld a, h
    ld [$d011], a
    ld hl, $d100
    ld de, $0010

Jump_000_247e:
    ld [hl], $ff
    add hl, de
    ld a, l
    cp $a0
    jp nz, Jump_000_247e

    ret


Call_000_2488:
    call Call_000_2492
    call Call_000_263f
    call Call_000_255f
    ret


Call_000_2492:
jr_000_2492:
    ld a, [$d010]
    ld l, a
    ld a, [$d011]
    ld h, a
    ld a, [hl]
    ld b, a
    ld a, [$c0ab]
    sub b
    ret z

    ret c

    ld c, a
    swap c
    push hl
    inc hl
    ld a, [hl]
    and $1f
    rlca
    rlca
    rlca
    add $10
    ldh [$ffc2], a
    ld a, [hl+]
    and $c0
    swap a
    add $d0
    sub c
    ldh [$ffc3], a
    call Call_000_24e6
    pop hl
    ld de, $0003
    add hl, de
    ld a, l

Call_000_24c4:
    ld [$d010], a
    ld a, h
    ld [$d011], a
    jr jr_000_2492

Call_000_24cd:
    ld a, [$d003]
    ldh [$ffc0], a
    cp $ff
    ret z

    ld d, $00
    ld e, a
    rlca
    add e
    rl d
    ld e, a
    ld hl, $336c
    add hl, de
    ld a, [hl+]
    ldh [$ffc7], a
    jr jr_000_2502

Call_000_24e6:
    ldh a, [$ff9a]
    and a
    jr nz, jr_000_24ee

    bit 7, [hl]
    ret nz

jr_000_24ee:
    ld a, [hl]
    and $7f
    ldh [$ffc0], a
    ld d, $00
    ld e, a
    rlca
    add e
    rl d
    ld e, a
    ld hl, $336c
    add hl, de
    ld a, [hl]
    ldh [$ffc7], a

jr_000_2502:
    xor a
    ldh [$ffc4], a
    ldh [$ffc5], a
    ldh [$ffc8], a
    ldh [$ffc9], a
    ldh [$ffcb], a
    ldh a, [$ffc0]
    ld d, $00
    ld e, a
    rlca
    add e
    rl d
    ld e, a
    ld hl, $336c
    add hl, de
    inc hl
    ld a, [hl+]
    ldh [$ffca], a
    ld a, [hl]
    ldh [$ffcc], a
    cp $c0
    jr c, jr_000_252b

    ld a, $0b
    ld [$dfe8], a

jr_000_252b:
    ld de, $0010
    ld b, $00
    ld hl, $d100

jr_000_2533:
    ld a, [hl]
    inc a
    jr z, jr_000_253f

    inc b
    add hl, de
    ld a, l
    cp $90
    jr nz, jr_000_2533

    ret


jr_000_253f:
    ld a, b
    call Call_000_2cee
    ret


Call_000_2544:
    ld hl, $d190
    ld [hl], a
    ldh a, [$ffc2]
    and $f8
    add $07
    ld [$d192], a
    ldh a, [$ffc3]
    ld [$d193], a
    call Call_000_2cb2
    ld a, $0b
    ld [$dfe0], a
    ret


Call_000_255f:
    xor a
    ld [$d013], a
    ld c, $00

jr_000_2565:
    ld a, [$d013]
    cp $14
    ret nc

    push bc
    ld a, c
    swap a
    ld hl, $d100
    ld l, a
    ld a, [hl]
    inc a
    jr z, jr_000_2594

    ld a, c
    call Call_000_2cdc
    ldh a, [$ffc3]
    cp $e0
    jr c, jr_000_258b

jr_000_2581:
    ld a, $ff
    ldh [$ffc0], a
    ld a, c
    call Call_000_2cee
    jr jr_000_2594

jr_000_258b:
    ldh a, [$ffc2]
    cp $c0
    jr nc, jr_000_2581

    call Call_000_25b7

jr_000_2594:
    pop bc
    inc c
    ld a, c
    cp $0a
    jr nz, jr_000_2565

    ld hl, $c050
    ld a, [$d013]
    rlca
    rlca
    ld d, $00
    ld e, a
    add hl, de

jr_000_25a7:
    ld a, l
    cp $a0
    jp nc, Jump_000_25b6

    ld a, $b4
    ld [hl], a
    inc hl
    inc hl
    inc hl
    inc hl
    jr jr_000_25a7

Jump_000_25b6:
    ret


Call_000_25b7:
    xor a
    ld [$d000], a
    ld hl, $c050
    ld a, [$d013]
    rlca
    rlca
    ld d, $00
    ld e, a
    add hl, de
    ld b, h
    ld c, l
    ld hl, $2fd9
    ldh a, [$ffc5]
    and $01
    jr nz, jr_000_25d5

    ld hl, $30ab

jr_000_25d5:
    ldh a, [$ffc6]
    rlca
    ld d, $00
    ld e, a
    add hl, de
    ld a, [hl+]
    ld e, a
    ld a, [hl]
    ld d, a
    ld h, d
    ld l, e

jr_000_25e2:
    ld a, [$d013]
    cp $14
    ret nc

jr_000_25e8:
    ld a, [hl]
    cp $ff
    ret z

    bit 7, a
    jr nz, jr_000_2625

    rlca
    res 4, a
    ld [$d000], a
    ld a, [hl]
    bit 3, a
    jr z, jr_000_2602

    ldh a, [$ffc2]
    sub $08
    ldh [$ffc2], a
    ld a, [hl]

jr_000_2602:
    bit 2, a
    jr z, jr_000_260d

    ldh a, [$ffc2]
    add $08
    ldh [$ffc2], a
    ld a, [hl]

jr_000_260d:
    bit 1, a
    jr z, jr_000_2618

    ldh a, [$ffc3]
    sub $08
    ldh [$ffc3], a
    ld a, [hl]

jr_000_2618:
    bit 0, a
    jr z, jr_000_2622

    ldh a, [$ffc3]
    add $08
    ldh [$ffc3], a

jr_000_2622:
    inc hl
    jr jr_000_25e8

jr_000_2625:
    ldh a, [$ffc2]
    ld [bc], a
    inc bc
    ldh a, [$ffc3]
    ld [bc], a
    inc bc
    ld a, [hl]
    ld [bc], a
    inc bc
    ld a, [$d000]
    ld [bc], a
    inc bc
    inc hl
    ld a, [$d013]
    inc a
    ld [$d013], a
    jr jr_000_25e2

Call_000_263f:
    ld hl, $d100

Jump_000_2642:
    ld a, [hl]
    inc a
    jr z, jr_000_2663

    push hl
    call Call_000_2ce2
    ld hl, $3495
    ldh a, [$ffc0]
    rlca
    ld d, $00
    ld e, a
    add hl, de
    ld a, [hl+]
    ld e, a
    ld a, [hl]
    ld d, a
    ld h, d
    ld l, e
    call Call_000_266d
    pop hl
    push hl
    call Call_000_2cf4
    pop hl

jr_000_2663:
    ld a, l
    add $10
    ld l, a
    cp $a0
    jp nz, Jump_000_2642

    ret


Call_000_266d:
Jump_000_266d:
jr_000_266d:
    ldh a, [$ffc8]
    and a
    jr z, jr_000_26ac

    ldh a, [$ffc7]
    bit 1, a
    jr z, jr_000_2689

    call Call_000_2bb2
    jr nc, jr_000_2683

    ldh a, [$ffc2]
    inc a
    ldh [$ffc2], a
    ret


jr_000_2683:
    ldh a, [$ffc2]
    and $f8
    ldh [$ffc2], a

jr_000_2689:
    ldh a, [$ffc9]
    and $f0
    swap a
    ld b, a
    ldh a, [$ffc9]
    and $0f
    cp b
    jr z, jr_000_269e

    inc b
    swap b
    or b
    ldh [$ffc9], a
    ret


jr_000_269e:
    ldh a, [$ffc9]
    and $0f
    ldh [$ffc9], a
    ldh a, [$ffc8]
    dec a
    ldh [$ffc8], a
    jp Jump_000_2870


Jump_000_26ac:
jr_000_26ac:
    push hl
    ld d, $00
    ldh a, [$ffc4]
    ld e, a
    add hl, de
    ld a, [hl]
    ld [$d002], a
    cp $ff
    jr nz, jr_000_26c1

    xor a
    ldh [$ffc4], a
    pop hl
    jr jr_000_26ac

jr_000_26c1:
    ldh a, [$ffc4]
    inc a
    ldh [$ffc4], a
    ld a, [$d002]
    and $f0
    cp $f0
    jr z, jr_000_26ef

    ld a, [$d002]
    and $e0
    cp $e0
    jr nz, jr_000_26e2

    ld a, [$d002]
    and $0f
    ldh [$ffc8], a
    pop hl
    jr jr_000_266d

jr_000_26e2:
    ld a, [$d002]
    ldh [$ffc1], a
    ld a, $01
    ldh [$ffc8], a
    pop hl
    jp Jump_000_266d


jr_000_26ef:
    ldh a, [$ffc4]
    inc a
    ldh [$ffc4], a
    inc hl
    ld a, [hl]
    ld [$d003], a
    ld a, [$d002]
    cp $f8
    jr nz, jr_000_2708

    ld a, [$d003]
    ldh [$ffc6], a
    pop hl
    jr jr_000_26ac

jr_000_2708:
    cp $f0
    jr nz, jr_000_2784

    ld a, [$d003]
    and $c0
    jr z, jr_000_274b

    bit 7, a
    jr z, jr_000_272a

    ldh a, [$ffc5]
    and $fd
    ld b, a
    ld a, [$c201]
    ld c, a
    ldh a, [$ffc2]
    sub c
    rla
    rlca
    and $02
    or b
    ldh [$ffc5], a

jr_000_272a:
    ld a, [$d003]
    bit 6, a
    jr z, jr_000_274b

    ld a, [$c202]
    ld c, a
    ldh a, [$ffc3]
    ld b, a
    ldh a, [$ffca]
    and $70
    rrca
    rrca
    add b
    sub c
    rla
    and $01
    ld b, a
    ldh a, [$ffc5]
    and $fe
    or b
    ldh [$ffc5], a

jr_000_274b:
    ld a, [$d003]
    and $0c
    jr z, jr_000_275a

    rra
    rra
    ld b, a
    ldh a, [$ffc5]
    xor b
    ldh [$ffc5], a

jr_000_275a:
    ld a, [$d003]
    bit 5, a
    jr z, jr_000_276d

    and $02
    or $fd
    ld b, a
    ldh a, [$ffc5]
    set 1, a
    and b
    ldh [$ffc5], a

jr_000_276d:
    ld a, [$d003]
    bit 4, a
    jr z, jr_000_2780

    and $01
    or $fe
    ld b, a
    ldh a, [$ffc5]
    set 0, a
    and b
    ldh [$ffc5], a

jr_000_2780:
    pop hl
    jp Jump_000_26ac


jr_000_2784:
    cp $f1
    jr nz, jr_000_2799

    ld a, $0a
    call Call_000_2cee
    call Call_000_24cd
    ld a, $0a
    call Call_000_2cdc
    pop hl
    jp Jump_000_26ac


jr_000_2799:
    cp $f2
    jr nz, jr_000_27a6

    ld a, [$d003]
    ldh [$ffc7], a
    pop hl
    jp Jump_000_26ac


jr_000_27a6:
    cp $f3
    jr nz, jr_000_27ce

    ld a, [$d003]
    ldh [$ffc0], a
    cp $ff
    jp z, Jump_000_286e

    ld hl, $ffc0
    call Call_000_2cb2
    pop hl
    ld hl, $3495
    ldh a, [$ffc0]
    rlca
    ld d, $00
    ld e, a
    add hl, de
    ld a, [hl+]
    ld e, a
    ld a, [hl]
    ld d, a
    ld h, d
    ld l, e
    jp Jump_000_26ac


jr_000_27ce:
    cp $f4
    jr nz, jr_000_27db

    ld a, [$d003]
    ldh [$ffc9], a
    pop hl
    jp Jump_000_26ac


jr_000_27db:
    cp $f5
    jr nz, jr_000_27eb

    ldh a, [rDIV]
    and $03
    ld a, $f1
    jr z, jr_000_2784

    pop hl
    jp Jump_000_26ac


jr_000_27eb:
    cp $f6
    jr nz, jr_000_280f

    ld a, [$c202]
    ld b, a
    ldh a, [$ffc3]
    sub b
    add $14
    cp $20
    ld a, [$d003]
    dec a
    jr z, jr_000_2801

    ccf

jr_000_2801:
    jr c, jr_000_280b

    ldh a, [$ffc4]
    dec a
    dec a
    ldh [$ffc4], a
    pop hl
    ret


jr_000_280b:
    pop hl
    jp Jump_000_26ac


jr_000_280f:
    cp $f7
    jr nz, jr_000_2818

    call Call_000_2b21
    pop hl
    ret


jr_000_2818:
    cp $f9
    jr nz, jr_000_2824

    ld a, [$d003]
    ld [$dff8], a
    pop hl
    ret


jr_000_2824:
    cp $fa
    jr nz, jr_000_2830

    ld a, [$d003]
    ld [$dfe0], a
    pop hl
    ret


jr_000_2830:
    cp $fb
    jr nz, jr_000_284d

    ld a, [$d003]
    ld c, a
    ld a, [$c202]
    ld b, a
    ldh a, [$ffc3]
    sub b
    cp c
    jr c, jr_000_2849

    xor a
    ldh [$ffc4], a
    pop hl
    jp Jump_000_26ac


jr_000_2849:
    pop hl
    jp Jump_000_26ac


jr_000_284d:
    cp $fc
    jr nz, jr_000_285e

    ld a, [$d003]
    ldh [$ffc2], a
    ld a, $70
    ldh [$ffc3], a
    pop hl
    jp Jump_000_26ac


jr_000_285e:
    cp $fd
    jr nz, jr_000_286a

    ld a, [$d003]
    ld [$dfe8], a
    pop hl
    ret


jr_000_286a:
    pop hl
    jp Jump_000_26ac


Jump_000_286e:
    pop hl
    ret


Jump_000_2870:
    ldh a, [$ffc1]
    and $0f
    jp z, Jump_000_296c

    ldh a, [$ffc5]
    bit 0, a
    jr nz, jr_000_28e7

    call Call_000_2b7b
    jr nc, jr_000_28c5

    ldh a, [$ffc7]
    bit 0, a
    jr z, jr_000_288d

    call Call_000_2bdb
    jr c, jr_000_28d1

jr_000_288d:
    ldh a, [$ffc1]
    and $0f
    ld b, a
    ldh a, [$ffc3]
    sub b
    ldh [$ffc3], a
    ldh a, [$ffcb]
    and a
    jp z, Jump_000_296c

    ld a, [$c205]
    ld c, a
    push bc
    ld a, $20
    ld [$c205], a
    call Call_000_1aa4
    pop bc
    and a
    jr nz, jr_000_28be

    ld a, [$c202]
    sub b
    ld [$c202], a
    cp $0f
    jr nc, jr_000_28be

    ld a, $0f
    ld [$c202], a

jr_000_28be:
    ld a, c
    ld [$c205], a
    jp Jump_000_296c


jr_000_28c5:
    ldh a, [$ffc7]
    and $0c
    cp $00
    jr z, jr_000_288d

    cp $04
    jr nz, jr_000_28da

jr_000_28d1:
    ldh a, [$ffc5]
    set 0, a
    ldh [$ffc5], a
    jp Jump_000_296c


jr_000_28da:
    cp $0c
    jp nz, Jump_000_296c

    xor a
    ldh [$ffc4], a
    ldh [$ffc8], a
    jp Jump_000_296c


jr_000_28e7:
    call Call_000_2b91
    jr nc, jr_000_294f

    ldh a, [$ffc7]
    bit 0, a
    jr z, jr_000_28f7

    call Call_000_2bf5
    jr c, jr_000_295b

jr_000_28f7:
    ldh a, [$ffc1]
    and $0f
    ld b, a
    ldh a, [$ffc3]
    add b
    ldh [$ffc3], a
    ldh a, [$ffcb]
    and a
    jr z, jr_000_296c

    ld a, [$c205]
    ld c, a
    push bc
    xor a
    ld [$c205], a
    call Call_000_1aa4
    pop bc
    and a
    jr nz, jr_000_293b

    ld a, [$c202]
    add b
    ld [$c202], a
    cp $51
    jr c, jr_000_293b

    ld a, [$c0d2]
    cp $07
    jr nc, jr_000_2941

jr_000_2928:
    ld a, [$c202]
    sub $50
    ld b, a
    ld a, $50
    ld [$c202], a
    ldh a, [$ffa4]
    add b
    ldh [$ffa4], a
    call Call_000_2c96

jr_000_293b:
    ld a, c
    ld [$c205], a
    jr jr_000_296c

jr_000_2941:
    ldh a, [$ffa4]
    and $0c
    jr nz, jr_000_2928

    ldh a, [$ffa4]
    and $fc
    ldh [$ffa4], a
    jr jr_000_293b

jr_000_294f:
    ldh a, [$ffc7]
    and $0c
    cp $00
    jr z, jr_000_28f7

    cp $04
    jr nz, jr_000_2963

jr_000_295b:
    ldh a, [$ffc5]
    res 0, a
    ldh [$ffc5], a
    jr jr_000_296c

jr_000_2963:
    cp $0c
    jr nz, jr_000_296c

    xor a
    ldh [$ffc4], a
    ldh [$ffc8], a

Jump_000_296c:
jr_000_296c:
    ldh a, [$ffc1]
    and $f0
    jp z, Jump_000_29f4

    ldh a, [$ffc5]
    bit 1, a
    jr nz, jr_000_29b8

    call Call_000_2c18
    jr nc, jr_000_2998

jr_000_297e:
    ldh a, [$ffc1]
    and $f0
    swap a
    ld b, a
    ldh a, [$ffc2]
    sub b
    ldh [$ffc2], a
    ldh a, [$ffcb]
    and a
    jr z, jr_000_29f4

    ld a, [$c201]
    sub b
    ld [$c201], a
    jr jr_000_29f4

jr_000_2998:
    ldh a, [$ffc7]
    and $c0
    cp $00
    jr z, jr_000_297e

    cp $40
    jp nz, Jump_000_29ad

    ldh a, [$ffc5]
    set 1, a
    ldh [$ffc5], a
    jr jr_000_29f4

Jump_000_29ad:
    cp $c0
    jr nz, jr_000_29f4

    xor a
    ldh [$ffc4], a
    ldh [$ffc8], a
    jr jr_000_29f4

jr_000_29b8:
    call Call_000_2bb2
    jr nc, jr_000_29d7

jr_000_29bd:
    ldh a, [$ffc1]
    and $f0
    swap a
    ld b, a
    ldh a, [$ffc2]
    add b
    ldh [$ffc2], a
    ldh a, [$ffcb]
    and a
    jr z, jr_000_29f4

    ld a, [$c201]
    add b
    ld [$c201], a
    jr jr_000_29f4

jr_000_29d7:
    ldh a, [$ffc7]
    and $30
    cp $00
    jr z, jr_000_29bd

    cp $10
    jr nz, jr_000_29eb

    ldh a, [$ffc5]
    res 1, a
    ldh [$ffc5], a
    jr jr_000_29f4

jr_000_29eb:
    cp $30
    jr nz, jr_000_29f4

    xor a
    ldh [$ffc4], a
    ldh [$ffc8], a

Jump_000_29f4:
jr_000_29f4:
    xor a
    ldh [$ffcb], a
    ret


Call_000_29f8:
    push hl
    ld a, [hl]
    ld e, a
    ld d, $00
    ld l, a
    ld h, $00
    sla e
    rl d
    sla e
    rl d
    add hl, de
    ld de, $317d
    add hl, de
    ld a, [hl]
    pop hl
    and a
    ret z

    push hl
    ld [hl], a
    call Call_000_2cb2
    ld a, $ff
    pop hl
    ret


Call_000_2a1a:
    push hl
    ld a, [hl]
    ld e, a
    ld d, $00
    ld l, a
    ld h, $00
    sla e
    rl d
    sla e
    rl d
    add hl, de
    ld de, $317d
    add hl, de
    inc hl
    ld a, [hl]
    pop hl
    and a
    ret z

    ld [hl], a
    call Call_000_2cb2
    ld a, $ff
    ret


Call_000_2a3b:
    push hl
    ld a, [hl]
    ld e, a
    ld d, $00
    ld l, a
    ld h, $00
    sla e
    rl d
    sla e
    rl d
    add hl, de
    ld de, $317d
    add hl, de
    inc hl
    inc hl
    ld a, [hl]
    pop hl
    cp $ff
    ret z

    and a
    ret z

    ld [hl], a
    call Call_000_2cb2
    xor a
    ret


Call_000_2a5f:
    push hl
    ld a, l
    add $0c
    ld l, a
    ld a, [hl]
    and $3f
    jr z, jr_000_2a80

    ld a, [hl]
    dec a
    ld [hl], a
    pop hl
    ld a, [hl]
    cp $32
    jr z, jr_000_2a78

    cp $08
    jr z, jr_000_2a78

    jr jr_000_2a7d

jr_000_2a78:
    ld a, $01
    ld [$dff0], a

jr_000_2a7d:
    ld a, $fe
    ret


jr_000_2a80:
    pop hl
    push hl
    ld a, [hl]
    ld e, a
    ld d, $00
    ld l, a
    ld h, $00
    sla e
    rl d
    sla e
    rl d
    add hl, de
    ld de, $317d
    add hl, de
    inc hl
    inc hl
    inc hl
    ld a, [hl]
    pop hl
    and a
    ret z

    ld [hl], a
    call Call_000_2cb2
    ld a, $ff
    ret


Call_000_2aa4:
    push hl
    ld a, l
    add $0c
    ld l, a
    ld a, [hl]
    and $3f
    jr z, jr_000_2ad0

    ld a, [hl]
    dec a
    ld [hl], a
    pop hl
    ld a, [hl]
    cp $1a
    jr z, jr_000_2ac8

    cp $61
    jr z, jr_000_2ac8

    cp $60
    jr z, jr_000_2ac1

    jr jr_000_2acd

jr_000_2ac1:
    ld a, $01
    ld [$dff8], a
    jr jr_000_2acd

jr_000_2ac8:
    ld a, $01
    ld [$dff0], a

jr_000_2acd:
    ld a, $fe
    ret


jr_000_2ad0:
    pop hl
    push hl
    ld a, [hl]
    cp $60
    jr nz, jr_000_2ada

    ld [$d007], a

jr_000_2ada:
    ld a, [hl]
    ld e, a
    ld d, $00
    ld l, a
    ld h, $00
    sla e
    rl d
    sla e
    rl d
    add hl, de
    ld de, $317d
    add hl, de
    inc hl
    inc hl
    inc hl
    inc hl
    ld a, [hl]
    pop hl
    and a
    ret z

    ld [hl], a
    call Call_000_2cb2
    ld a, $ff
    ret


Call_000_2afd:
    push hl
    ld a, [hl]
    ld e, a
    ld d, $00
    ld l, a
    ld h, $00
    sla e
    rl d
    sla e
    rl d
    add hl, de
    ld de, $317d
    add hl, de
    inc hl
    inc hl
    inc hl
    inc hl
    ld a, [hl]
    pop hl
    and a
    ret z

    ld [hl], a
    call Call_000_2cb2
    ld a, $ff
    ret


Call_000_2b21:
    ld hl, $d100

jr_000_2b24:
    ld a, [hl]
    cp $ff
    jr z, jr_000_2b3e

    push hl
    ld [hl], $27
    inc hl
    inc hl
    inc hl
    inc hl
    ld [hl], $00
    inc hl
    inc hl
    inc hl
    inc hl
    inc hl
    ld [hl], $00
    inc hl
    inc hl
    ld [hl], $00
    pop hl

jr_000_2b3e:
    ld a, l
    add $10
    ld l, a
    cp $a0
    jr c, jr_000_2b24

    ld a, $27
    ldh [$ffc0], a
    xor a
    ldh [$ffc4], a

Call_000_2b4d:
    ldh [$ffc7], a
    inc a
    ld [$dff8], a
    ret


    ldh a, [$ffc3]
    ld c, a
    ldh a, [$ffa4]
    add c
    add $04
    ldh [$ffae], a
    ld c, a
    ldh a, [$ffc5]
    bit 0, a
    jr jr_000_2b6d

    ldh a, [$ffca]
    and $70
    rrca
    add c
    ldh [$ffae], a

jr_000_2b6d:
    ldh a, [$ffc2]
    ldh [$ffad], a
    call Call_000_0153
    cp $5f
    ret c

    cp $f0
    ccf
    ret


Call_000_2b7b:
    ldh a, [$ffc3]
    ld c, a
    ldh a, [$ffa4]
    add c
    ldh [$ffae], a
    ldh a, [$ffc2]
    ldh [$ffad], a
    call Call_000_0153
    cp $5f
    ret c

    cp $f0
    ccf
    ret


Call_000_2b91:
    ldh a, [$ffc3]
    ld c, a
    ldh a, [$ffa4]
    add c
    add $08
    ld c, a
    ldh a, [$ffca]
    and $70
    rrca
    add c
    sub $08
    ldh [$ffae], a
    ldh a, [$ffc2]
    ldh [$ffad], a
    call Call_000_0153
    cp $5f
    ret c

    cp $f0
    ccf
    ret


Call_000_2bb2:
    ldh a, [$ffc3]
    ld c, a
    ldh a, [$ffa4]
    add c
    add $04
    ldh [$ffae], a
    ld c, a
    ldh a, [$ffc5]
    bit 0, a
    jr jr_000_2bcb

    ldh a, [$ffca]
    and $70
    rrca
    add c
    ldh [$ffae], a

jr_000_2bcb:
    ldh a, [$ffc2]
    add $08
    ldh [$ffad], a
    call Call_000_0153
    cp $5f
    ret c

    cp $f0
    ccf
    ret


Call_000_2bdb:
    ldh a, [$ffc3]
    ld c, a
    ldh a, [$ffa4]
    add c
    add $03
    ldh [$ffae], a
    ldh a, [$ffc2]
    add $08
    ldh [$ffad], a
    call Call_000_0153
    cp $5f
    ret c

    cp $f0
    ccf
    ret


Call_000_2bf5:
    ldh a, [$ffc3]
    ld c, a
    ldh a, [$ffa4]
    add c
    add $05
    ld c, a
    ldh a, [$ffca]
    and $70
    rrca
    add c
    sub $08
    ldh [$ffae], a
    ldh a, [$ffc2]
    add $08
    ldh [$ffad], a
    call Call_000_0153
    cp $5f
    ret c

    cp $f0
    ccf
    ret


Call_000_2c18:
    ldh a, [$ffc3]
    ld c, a
    ldh a, [$ffa4]
    add c
    add $04
    ldh [$ffae], a
    ld c, a
    ldh a, [$ffc5]
    bit 0, a
    jr jr_000_2c31

    ldh a, [$ffca]
    and $70
    rrca
    add c
    ldh [$ffae], a

jr_000_2c31:
    ldh a, [$ffca]
    and $07
    dec a
    swap a
    rrca
    ld c, a
    ldh a, [$ffc2]
    sub c
    ldh [$ffad], a
    call Call_000_0153
    cp $5f
    ret c

    cp $f0
    ccf
    ret


    ldh a, [$ffc3]
    ld c, a
    ldh a, [$ffa4]
    add c
    add $03
    ldh [$ffae], a
    ldh a, [$ffca]
    and $07
    dec a
    swap a
    rrca
    ld c, a
    ldh a, [$ffc2]
    sub c
    ldh [$ffad], a
    call Call_000_0153
    cp $5f
    ret c

    cp $f0
    ccf
    ret


    ldh a, [$ffc3]
    ld c, a
    ldh a, [$ffa4]
    add c
    add $05
    ld c, a
    ldh a, [$ffca]
    and $70
    rrca
    sub c
    sub $08
    ldh [$ffae], a
    ldh a, [$ffca]
    and $07
    dec a
    swap a
    rrca
    ld c, a
    ldh a, [$ffc2]
    sub c
    ldh [$ffad], a
    call Call_000_0153
    cp $5f
    ret c

    cp $f0
    ccf
    ret


Call_000_2c96:
    ld a, b
    and a
    ret z

jr_000_2c99:
    ldh a, [$ffc3]
    sub b
    ldh [$ffc3], a
    push hl
    push de
    ld hl, $d103
    ld de, $0010

jr_000_2ca6:
    ld a, [hl]
    sub b
    ld [hl], a
    add hl, de
    ld a, l
    cp $a0
    jr c, jr_000_2ca6

    pop de
    pop hl
    ret


Call_000_2cb2:
    push hl
    ld a, [hl]
    ld d, $00

jr_000_2cb6:
    ld e, a
    rlca
    add e
    rl d
    ld e, a
    ld hl, $336c
    add hl, de

jr_000_2cc0:
    ld a, [hl+]
    ld b, a
    ld a, [hl+]

jr_000_2cc3:
    ld d, a
    ld a, [hl]
    pop hl
    inc hl
    inc hl
    inc hl
    inc hl
    ld [hl], $00
    inc hl
    inc hl
    inc hl
    ld [hl], b
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], d
    inc hl
    inc hl
    ld [hl], a
    ret


Call_000_2cdc:
    swap a
    ld hl, $d100
    ld l, a

Call_000_2ce2:
    ld de, $ffc0
    ld b, $0d

jr_000_2ce7:
    ld a, [hl+]
    ld [de], a
    inc de
    dec b
    jr nz, jr_000_2ce7

    ret


Call_000_2cee:
    swap a
    ld hl, $d100
    ld l, a

Call_000_2cf4:
    ld de, $ffc0
    ld b, $0d

jr_000_2cf9:
    ld a, [de]
    ld [hl+], a
    inc de
    dec b
    jr nz, jr_000_2cf9

    ret


    sub b
    rst $38
    db $10
    sub b
    rst $38
    sub c
    rst $38
    jr nz, jr_000_2c99

    rst $38
    ld b, b
    sub e
    ld c, b
    sub d
    rst $38
    ld b, b
    sub l
    ld c, b

jr_000_2d12:
    sub h
    rst $38
    sub a
    ld [$ff96], sp
    sbc c
    ld [$ff98], sp
    db $10
    sub a
    jr jr_000_2cb6

    rst $38
    db $10
    sbc c
    jr @-$66

    rst $38
    sbc d
    rst $38
    jr nz, jr_000_2cc0

    jr z, jr_000_2cc3

    rst $38
    db $10
    adc c
    ld de, $1888
    add a
    rst $38
    db $10
    adc h
    ld de, $188b
    adc d
    rst $38
    adc b
    ld bc, $0a89
    add a
    rst $38
    adc e
    ld bc, $0a8c
    adc d
    rst $38
    db $10
    sbc h
    ld de, $ff8d
    adc l
    ld bc, $ff9c
    jr nz, @-$71

    ld hl, $ff9c
    sbc e
    rst $38
    sbc l
    ld de, $ff9d
    sbc [hl]
    ld de, $ff9e
    rst $28
    ld bc, $01ef
    rst $28
    rst $38
    db $dd
    ld bc, $ffde
    jr nz, @-$61

    ld sp, $0a9d
    sbc l
    ld de, $ff9d

jr_000_2d72:
    jr nz, jr_000_2d12

    ld sp, $0a9e
    sbc [hl]
    ld de, $ff9e
    add e
    rst $38
    add h
    rst $38
    add l
    rst $38
    add [hl]
    rst $38
    ld b, b
    ldh [rIE], a
    push hl
    rst $38
    ld b, b
    or $ff
    ld b, b
    rst $30
    rst $38
    ld b, b
    ld hl, sp-$01
    cp $ff
    rst $18
    rst $38
    ld b, b
    xor $ff
    rst $28
    ld bc, $ffef

jr_000_2d9c:
    or b
    ld bc, $0ab1
    and b
    ld bc, $ffa1
    db $10
    or c
    ld de, $1ab0
    and c
    ld de, $ffa0
    jr nc, jr_000_2d72

    ld sp, $3ac2
    db $d3
    ld sp, $ffd2
    or d
    ld bc, $0ab3

jr_000_2dba:
    and d
    ld bc, $ffa3
    db $10
    or e
    ld de, $1ab2
    and e
    ld de, $ffa2
    or h
    ld bc, $0ab5
    and h
    ld bc, $ffa5
    db $10
    or l
    ld de, $1ab4
    and l
    ld de, $ffa4
    or [hl]
    ld bc, $0ab7
    and [hl]
    ld bc, $ffa7
    db $10
    or a
    ld de, $1ab6
    and a
    ld de, $ffa6
    xor b
    ld bc, $ffa9
    db $10
    xor c
    ld de, $ffa8
    jr nz, jr_000_2d9c

    ld hl, $ffa9
    cp b
    ld bc, $ffb9
    db $10
    cp c
    ld de, $ffb8
    jr nz, jr_000_2dba

    ld hl, $ffb9
    ret nc

    ld bc, $0ad1
    ret nz

    ld bc, $ffc1
    db $10
    pop de
    ld de, $1ad0
    pop bc
    ld de, $ffc0
    jp nc, $d301

    ld a, [bc]
    jp nz, $c301

    rst $38
    db $10
    db $d3
    ld de, $1ad2
    jp $c211


    rst $38
    call nc, $d501
    ld a, [bc]
    call nz, $c501
    rst $38
    db $10
    push de
    ld de, $1ad4
    push bc
    ld de, $ffc4
    sub $01

jr_000_2e3a:
    rst $10
    ld a, [bc]
    add $01
    rst $00
    rst $38
    db $10
    rst $10
    ld de, $1ad6
    rst $00
    ld de, $ffc6
    ret z

    ld bc, $ffc9
    db $10
    ret


    ld de, $ffc8
    jr nz, @-$36

    ld hl, $ffc9
    ret c

    ld bc, $ffd9
    db $10
    reti


    ld de, $ffd8
    jr nz, jr_000_2e3a

    ld hl, $ffd9
    xor h
    rst $38
    xor [hl]
    rst $38
    xor a
    rst $38
    cp l
    ld bc, $01be
    cp a
    rst $38
    db $10
    cp a
    ld de, $11be
    cp l
    rst $38
    cp d
    rst $38
    cp e
    rst $38
    add $01
    rst $00
    rst $38
    jr nz, @-$38

    ld hl, $ffc7
    sub $01
    rst $10
    rst $38

jr_000_2e89:
    jr nz, @-$28

    ld hl, $ffd7
    ld b, b
    ret nc

    ld c, b
    ret nz

    rst $38
    ld b, b
    pop de
    ld c, b
    pop bc
    rst $38
    cp h
    ld [$ffac], sp
    ldh [c], a
    rst $38
    db $e3
    rst $38
    call nz, $c501
    rst $38
    call nc, $d501
    rst $38
    sbc a
    rst $38
    xor d
    rst $38
    xor l
    rst $38
    ret c

    rst $38
    reti


    rst $38
    cp d
    ld bc, $0abb
    xor d
    ld bc, $ffab
    ld b, b
    and $ff
    cp e
    ld a, [bc]
    xor d
    ld bc, $11ab
    xor d
    rst $38
    cp e
    ld a, [bc]
    cp d
    ld bc, $11ab
    cp d
    rst $38
    cp e
    ld a, [bc]
    xor h
    ld bc, $11ab
    xor h
    rst $38
    xor h
    ld bc, $11ad
    xor h
    rst $38
    jr nz, jr_000_2e89

    ld hl, $31ad
    xor h
    rst $38
    jp c, $db01

    ld bc, $0adc
    ld [bc], a
    jp z, $cb01

    ld bc, $01cc
    cp d
    ld a, [bc]
    ld [bc], a
    ld [bc], a
    call $ce01
    rst $38
    cp e
    ld bc, $01d6
    rst $10
    ld a, [bc]
    ld [bc], a
    xor e
    ld bc, $01c6
    rst $00
    ld bc, $0aaa
    ld [bc], a
    ld [bc], a
    call $ce01
    rst $38
    jr nz, @-$54

    ld sp, $0aaa
    xor d
    ld de, $ffaa
    jr nz, @-$53

    ld sp, $0aab
    xor e
    ld de, $ffab
    cp h
    ld bc, $0abd
    adc $01
    rst $08
    ld a, [bc]
    cp [hl]
    ld bc, $0abf
    xor [hl]
    ld bc, $ffaf
    call z, $cd01
    ld a, [bc]
    jp c, $db01

    ld a, [bc]
    jp z, $cb01

    ld a, [bc]
    cp d
    ld bc, $ffbb
    ld b, b
    adc b
    ld c, b
    add a
    rst $38
    ld sp, hl
    ld bc, $fffb
    ld sp, hl
    ld bc, $fffa
    db $10
    ld sp, hl
    ld [de], a
    ei
    rst $38
    db $10
    ld sp, hl
    ld [de], a
    ld a, [$ceff]
    ld bc, $0acf
    cp [hl]
    ld bc, $0abf
    xor [hl]
    ld bc, $ffaf
    jp z, $cb01

    ld a, [bc]
    call z, $cd01
    ld a, [bc]
    cp h
    ld bc, $ffbd
    ret nc

    ld de, $0ad0
    ret nz

    ld de, $ffc0
    pop de
    ld de, $0ad1
    pop bc
    ld de, $ffc1
    cp d
    ld bc, $01bb
    cp h
    ld a, [bc]
    xor e
    rst $38
    cp l
    ld bc, $01be
    cp a
    ld a, [bc]
    xor [hl]
    rst $38
    ld h, b
    sub e
    ld h, h
    sub d
    rst $38
    ld h, b
    sub l
    ld h, h
    sub h
    rst $38
    ld b, b
    call z, $cd41
    ld b, c
    adc $41
    rst $08
    ld c, d
    ld b, d
    ld b, d
    cp h
    ld b, c
    cp l
    ld b, c
    cp [hl]
    ld b, c
    cp a
    ld c, d
    ld b, d
    ld b, d
    xor h
    ld b, c
    xor l
    ld b, c
    xor [hl]
    ld b, c
    xor a
    ld c, d
    set 7, a
    ld b, b
    ldh a, [c]
    ld b, c
    di
    ld c, d
    ldh a, [rSTAT]
    pop af
    rst $38
    adc h
    ld bc, $018d
    sbc h
    ld a, [bc]
    ld [bc], a
    adc c
    ld bc, $018a
    adc e
    rst $38
    jp c, $c801

    ld bc, $0ac9
    ld [bc], a
    jp z, $db01

    ld bc, $ffdc
    nop
    dec l
    ld [bc], a
    dec l
    dec b
    dec l
    rlca
    dec l
    ld a, [bc]
    dec l
    rrca
    dec l
    inc e
    dec l
    ld hl, $262d
    dec l
    jr z, jr_000_301a

    dec l
    dec l
    inc [hl]
    dec l
    ld b, a
    dec l
    ld d, b
    dec l
    ld d, l
    dec l
    ld d, a
    dec l
    ld e, e
    dec l
    ld e, a
    dec l
    ld e, a
    dec l
    ld h, l
    dec l
    ld l, c
    dec l
    ld [hl], d
    dec l
    ld a, e
    dec l
    ld a, l
    dec l
    ld a, a
    dec l
    add c
    dec l
    add e
    dec l
    add [hl]
    dec l
    adc b
    dec l
    adc e
    dec l
    adc [hl]
    dec l
    sub c
    dec l
    sub e

jr_000_301a:
    dec l
    sub l
    dec l
    sbc b
    dec l
    cp l
    ld l, $c5
    ld l, $cd
    ld l, $d5
    ld l, $db
    ld l, $a4
    dec l
    cp [hl]
    dec l
    rst $08
    dec l
    ldh [$ff2d], a
    db $ed
    dec l
    ldh a, [c]
    dec l
    ei
    dec l
    nop
    ld l, $0d
    ld l, $1e
    ld l, $2f
    ld l, $40
    ld l, $4d
    ld l, $52
    ld l, $5b
    ld l, $60
    ld l, $65
    ld l, $67
    ld l, $69
    ld l, $71
    ld l, $78
    ld l, $7a
    ld l, $7c
    ld l, $80
    ld l, $85
    ld l, $89
    ld l, $8e
    ld l, $93
    ld l, $98
    ld l, $9c
    ld l, $9e
    ld l, $ad
    dec l
    ldh [c], a
    ld l, $f7
    ld l, $a0
    ld l, $a4
    ld l, $0c
    cpl
    dec d
    cpl
    ld e, $2f
    ld l, $2f
    xor b
    ld l, $3e
    cpl
    ld c, e
    cpl
    ld d, b
    cpl
    ld d, l
    cpl
    ld h, c
    cpl
    ld l, l
    cpl
    ld [hl], l
    cpl
    sub c
    dec l
    ld l, c
    ld l, $aa
    ld l, $65
    ld l, $ac
    ld l, $7d
    cpl
    add l
    cpl
    adc l
    cpl
    sub d
    cpl
    xor [hl]
    ld l, $b0
    ld l, $97
    cpl
    or d
    ld l, $b6
    cpl
    cp a
    cpl
    call z, $ba2f
    ld l, $00
    dec l
    ld [bc], a
    dec l
    dec b
    dec l
    rlca
    dec l
    ld a, [bc]
    dec l
    rrca
    dec l
    inc d
    dec l
    jr jr_000_30e8

    ld h, $2d
    jr z, jr_000_30ec

    dec sp
    dec l
    ld b, c
    dec l
    ld c, h
    dec l
    ld d, b
    dec l
    ld d, l
    dec l
    ld d, a
    dec l
    ld e, e
    dec l
    ld e, a
    dec l
    ld e, a
    dec l
    ld h, l
    dec l
    ld l, c
    dec l
    ld [hl], d
    dec l
    ld a, e
    dec l
    ld a, l
    dec l
    ld a, a
    dec l
    add c
    dec l
    add e
    dec l
    add [hl]
    dec l
    adc b
    dec l
    adc e
    dec l
    adc [hl]

jr_000_30e8:
    dec l
    sub c
    dec l
    sub e

jr_000_30ec:
    dec l
    sub l
    dec l
    sbc b
    dec l
    cp l
    ld l, $c5
    ld l, $cd
    ld l, $d5
    ld l, $db
    ld l, $9c
    dec l
    or [hl]
    dec l
    rst $00
    dec l
    ret c

    dec l
    jp hl


    dec l
    ldh a, [c]
    dec l
    rst $30
    dec l
    nop
    ld l, $05
    ld l, $16
    ld l, $27
    ld l, $38
    ld l, $49
    ld l, $52
    ld l, $57
    ld l, $60
    ld l, $65
    ld l, $67
    ld l, $69
    ld l, $6b
    ld l, $78
    ld l, $7a
    ld l, $7c
    ld l, $80
    ld l, $85
    ld l, $89
    ld l, $8e
    ld l, $93

Call_000_3132:
    ld l, $98
    ld l, $9c
    ld l, $9e
    ld l, $ad
    dec l
    ldh [c], a
    ld l, $f7
    ld l, $a0
    ld l, $a4
    ld l, $0c
    cpl
    dec d
    cpl
    ld e, $2f
    ld l, $2f
    xor b
    ld l, $3e
    cpl
    ld b, e
    cpl
    ld b, a
    cpl
    ld d, l
    cpl
    ld h, c
    cpl
    ld l, l
    cpl
    ld [hl], l
    cpl
    sub c
    dec l
    ld l, c
    ld l, $aa
    ld l, $65
    ld l, $ac
    ld l, $7d
    cpl
    add l
    cpl
    adc l
    cpl
    sub d
    cpl
    xor [hl]
    ld l, $b0
    ld l, $97
    cpl
    or d
    ld l, $b6
    cpl
    cp a
    cpl
    call z, $ba2f
    ld l, $01
    ld de, $11ff
    ld de, $0000
    nop
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
    nop
    nop
    dec b
    ld [de], a
    rst $38
    ld [de], a
    ld [de], a
    nop
    nop
    nop
    nop
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
    rst $38
    ld c, a
    ld c, a
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
    rst $38
    nop
    nop
    nop
    nop
    nop
    nop

Jump_000_31c2:
    nop
    rrca
    dec d
    rst $38
    dec d
    dec d
    nop
    nop
    nop
    nop
    nop
    rst $38
    nop
    rst $38
    nop
    daa
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    inc d
    nop
    nop
    nop
    nop
    nop
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
    add hl, de
    rst $38
    add hl, de
    add hl, de
    rst $38
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
    rst $38
    nop
    ld c, a
    nop
    nop
    nop
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
    nop
    daa
    nop
    nop
    rst $38
    nop
    nop
    nop
    nop
    rst $38
    nop
    nop
    rst $38
    nop
    rst $38
    ld hl, $0021
    nop
    nop
    nop
    nop
    nop
    nop
    rst $38
    nop
    nop
    nop
    nop
    rst $38
    nop
    nop
    rst $38
    nop
    rst $38
    nop
    daa
    inc e
    add hl, de
    rst $38
    add hl, de
    add hl, de
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jr z, jr_000_324d

jr_000_324d:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld a, [hl+]
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    daa
    daa
    nop
    nop
    rst $38
    daa
    daa
    ld b, b
    ld b, c
    rst $38
    ld b, c
    ld b, c
    nop
    nop
    rst $38
    ld c, a
    ld c, a
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
    rst $38
    nop
    nop
    scf
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    dec a
    ld a, $ff
    ld a, $3e
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld b, b
    ld b, c
    rst $38
    ld b, c
    ld b, c
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld b, e
    ld b, h
    rst $38
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
    rst $38
    nop
    nop
    nop
    nop
    rst $38
    nop
    nop
    nop
    nop
    rst $38
    nop
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
    dec c
    dec c
    rst $38
    nop
    dec c
    ld c, l
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    nop
    nop
    rst $38
    rst $38
    rst $38
    rst $38
    daa
    rst $38
    rst $38
    rst $38
    rst $38
    daa
    nop
    nop
    rst $38
    nop
    nop
    nop
    nop
    rst $38
    rst $38
    rst $38
    ld d, a
    dec d
    rst $38
    dec d
    dec d
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    rst $38
    nop
    nop
    rst $38
    rst $38
    rst $38
    rst $38
    daa
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
    rst $38
    nop
    rst $38
    nop
    nop
    rst $38
    nop
    rst $38
    nop
    nop
    rst $38
    nop
    rst $38
    nop
    nop
    rst $38
    nop
    rst $38
    nop
    nop
    rst $38
    nop
    ld c, a
    nop
    nop
    rst $38
    nop
    ld h, d
    nop
    nop
    nop
    nop
    nop
    ld b, $11
    nop
    ld [bc], a
    ld de, $0100
    ld de, $0000
    ld de, $0700
    ld de, $0200
    ld de, $0000
    ld [hl+], a
    nop
    nop
    sub c
    nop
    add hl, bc
    inc sp
    call nz, Call_000_2207
    add c
    nop
    or c
    nop
    nop
    or c
    nop
    nop
    and c
    nop
    nop
    nop
    nop
    inc [hl]
    ld [hl+], a
    ld b, c
    ld [bc], a
    ld hl, $0000
    ld [de], a
    nop
    nop
    ld de, $0000
    ld de, $0000
    sub c
    nop
    ld [$0091], sp
    nop
    ld hl, $0700
    ld [hl+], a
    ld b, b
    nop
    ld hl, $0000
    ld hl, $0000
    ld [hl+], a
    nop
    ld d, b
    inc h
    db $d3
    nop
    ld hl, $0200
    ld hl, $0000
    ld [hl+], a
    ld b, c
    nop
    ld hl, $0000
    ld de, $0000
    ld [hl+], a
    add d
    nop
    ld [hl+], a
    nop
    nop
    ld de, $0000
    ld de, $0000
    ld [hl+], a
    ld b, c
    ldh [rNR43], a
    ld b, c
    nop
    ld de, $0000
    ld [hl+], a
    nop
    inc h
    ld de, $0600
    ld de, $2400
    ld de, $0600
    ld de, $0400
    ld de, $0000
    ld de, $0000
    ld de, $0000
    ld hl, $0000
    ld hl, $0600
    ld [hl+], a
    ld b, b
    nop
    inc hl
    ret


    nop
    and d
    nop
    inc c
    ld de, $0000
    sub c
    nop
    nop
    sub c
    nop
    nop
    sub c
    nop
    nop
    or c
    nop
    nop
    or c
    nop
    nop
    and c
    nop
    nop
    and c
    nop
    jr nc, jr_000_3434

    add d
    ld [bc], a
    ld de, $0000
    ld de, $0000
    ld [hl+], a
    add b
    ld [bc], a
    ld hl, $0000
    ld hl, $0000
    ld [hl+], a

jr_000_3434:
    add b
    ld [bc], a
    ld hl, $0000
    ld hl, $0000
    ld [de], a
    nop
    nop
    ld [hl+], a
    nop
    inc [hl]
    and d
    nop
    ld d, h
    ld [hl+], a
    rst $38
    nop
    sub d
    nop
    nop
    ld de, $0000
    ld de, $0040
    sub c
    nop
    nop
    sub c
    nop
    nop
    sub c
    nop
    nop
    ld [hl+], a
    nop
    nop
    ld de, $0000
    ld de, $0000
    ld [hl+], a
    ld b, b
    nop
    ld [hl+], a
    ld b, b
    nop
    ld de, $0000
    ld de, $b440
    ld [hl+], a
    add c
    ld [bc], a
    ld hl, $0000
    ld de, $0000
    ld de, $0089
    ld de, $0000
    ld b, e
    ret nz

    nop
    ld de, $0032
    ld de, $0002
    ld de, $0005
    ld de, $0002
    ld b, e
    ret c

    ld d, h
    ld [hl-], a
    db $d3
    ld d, h
    ld [hl+], a
    nop
    ld e, e
    dec [hl]
    ld h, l
    dec [hl]
    ld l, l
    dec [hl]
    sub h
    dec [hl]
    and c
    dec [hl]

jr_000_349f:
    xor e
    dec [hl]
    jp z, $da35

    dec [hl]
    db $e4
    dec [hl]
    ld [bc], a

jr_000_34a8:
    ld [hl], $2f
    ld [hl], $41
    ld [hl], $53
    ld [hl], $6b
    ld [hl], $8a
    ld [hl], $c0

jr_000_34b4:
    ld [hl], $c8
    ld [hl], $f2
    ld [hl], $f6
    ld [hl], $fa
    ld [hl], $ff
    ld [hl], $11
    scf
    rla
    scf

jr_000_34c3:
    ld [hl-], a
    scf
    ld c, a
    scf
    ld e, h
    scf
    ld h, d
    scf
    ld [hl], d
    scf

jr_000_34cd:
    ld a, d
    scf
    add h
    scf
    sub b
    scf
    sbc b
    scf
    and c
    scf
    xor l
    scf
    call nz, $ce37
    scf
    ldh [c], a
    scf

Call_000_34df:
    inc d
    jr c, jr_000_3547

    jr c, jr_000_354b

jr_000_34e4:
    jr c, @+$78

    jr c, @-$6d

    jr c, @-$66

    jr c, jr_000_349f

    jr c, jr_000_34a8

    jr c, jr_000_34b4

    jr c, jr_000_34c3

    jr c, jr_000_34cd

    jr c, jr_000_34e4

    jr c, jr_000_3528

    add hl, sp
    add hl, sp
    add hl, sp
    ld d, d
    add hl, sp
    ld e, e
    add hl, sp
    ld a, d
    add hl, sp
    sub b
    add hl, sp
    sub h
    add hl, sp
    xor b
    add hl, sp
    cp c
    add hl, sp
    jp z, $dc39

    add hl, sp
    xor $39
    cpl
    ld a, [hl-]
    scf
    ld a, [hl-]
    dec a
    ld a, [hl-]
    ld d, h
    ld a, [hl-]
    ld e, h
    ld a, [hl-]
    ld h, d
    ld a, [hl-]
    add [hl]
    ld a, [hl-]
    adc [hl]
    ld a, [hl-]
    sub h
    ld a, [hl-]
    sbc e
    ld a, [hl-]
    pop bc
    ld a, [hl-]
    add sp, $3a
    ldh a, [c]

jr_000_3528:
    ld a, [hl-]
    rrca
    dec sp
    add hl, de
    dec sp
    ld hl, $253b
    dec sp
    dec [hl]
    dec sp
    inc a
    dec sp
    ld c, b
    dec sp
    ld c, [hl]
    dec sp
    ld h, a
    dec sp
    ld a, d
    dec sp
    cp h
    dec sp
    rst $10
    dec sp
    cp $3b
    ld a, [hl+]
    inc a
    dec [hl]
    inc a

jr_000_3547:
    dec a
    inc a
    ld e, d
    inc a

jr_000_354b:
    ld h, h
    inc a
    ld a, b
    inc a
    sub c
    inc a
    and [hl]
    inc a
    cp d
    inc a
    rst $08
    inc a
    db $e4
    inc a
    db $fc
    inc a
    ld hl, sp+$00
    db $f4
    ld [bc], a
    ld bc, $f8e2
    ld bc, $ffe3
    ld hl, sp+$02
    nop
    rst $28
    rst $28
    rst $28
    di
    rst $38
    ldh a, [rNR41]
    ld hl, sp+$04
    nop
    rst $28
    or $00
    db $10
    rst $28
    nop
    rst $28
    ld hl, sp+$05
    rst $28
    ld hl, sp+$04
    rst $28
    ld hl, sp+$05
    rst $28
    ld hl, sp+$04
    rst $28
    ld hl, sp+$05
    rst $28
    ld hl, sp+$04
    rst $28
    ldh a, [rNR43]
    db $10
    rst $28
    nop
    rst $28
    rst $28
    rst $28
    rst $38
    ld hl, sp+$1f
    db $f4
    ld [bc], a
    nop
    rst $28
    rst $28
    pop af
    ld b, a
    rst $28
    rst $28
    rst $28
    rst $38
    db $f4
    ld [bc], a
    ld hl, sp+$06
    ld bc, $f8e2
    rlca
    db $e3
    rst $38
    ld hl, sp+$08
    nop
    rst $28
    rst $28
    ld hl, sp+$0e
    db $e4
    ld hl, sp+$08
    db $e4
    ld hl, sp+$0e
    db $e4
    ld hl, sp+$08
    db $e4
    ld hl, sp+$0e
    db $e4
    ld hl, sp+$08
    db $e4
    ld hl, sp+$0e
    db $e4
    ld hl, sp+$08
    db $e4
    di
    ld b, [hl]
    ld hl, sp+$65
    ldh a, [rNR43]
    db $f4
    ld bc, $ef10
    ldh a, [rNR41]
    db $10
    rst $28
    nop
    rst $28
    add sp, -$01
    ld hl, sp+$68
    db $f4
    ld bc, $20f0
    db $10
    ldh [c], a
    di
    inc de
    ldh a, [$ff30]
    db $f4
    ld bc, $48f8
    nop
    rst $28
    ld hl, sp+$49
    nop
    rst $28
    ld sp, hl
    inc b
    pop af
    dec de
    add sp, $10
    rst $28
    db $e4
    ld sp, hl
    inc b
    pop af
    dec de
    ldh a, [rNR43]
    db $10
    rst $28
    db $e4
    rst $38
    db $f4
    inc bc
    ld hl, sp+$56
    ld bc, $f8e2
    ld d, a
    ldh [c], a
    ld hl, sp+$56
    ldh [c], a
    ld hl, sp+$57
    ldh [c], a
    ld hl, sp+$56
    ldh [c], a
    ld hl, sp+$57
    ldh [c], a
    ld hl, sp+$56
    ldh [c], a
    ld hl, sp+$57
    ldh [c], a
    ld hl, sp+$56
    ldh [c], a
    ld hl, sp+$57
    ldh [c], a
    ld hl, sp+$56
    nop
    add sp, -$08
    ld d, a
    ld sp, hl
    inc b
    pop af
    ld d, c
    add sp, -$01
    ld hl, sp+$12
    db $f4
    ld bc, $22f0
    db $10
    xor $ef
    rst $28
    rst $28
    ldh a, [rNR41]
    rst $28
    rst $28
    rst $28
    rst $28
    rst $38
    ld hl, sp+$12
    db $f4
    ld bc, $10f0
    ld bc, $efee
    rst $28
    add sp, -$10
    ld de, $efef
    rst $28
    add sp, -$01
    ld hl, sp+$13
    ldh a, [rNR43]
    db $f4
    rrca
    nop
    ld [$00f4], a
    db $10
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $38
    ldh a, [$ff64]
    ld de, $01e5
    ld de, $1101
    ld bc, $f001
    ld [hl+], a
    ld bc, $1101
    ld bc, $0111
    ld de, $20e5
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $38
    ld hl, sp+$28
    ldh a, [$ff60]
    db $f4
    ld [bc], a

Call_000_3690:
    nop
    db $e4
    ld hl, sp+$29
    db $e4
    ld hl, sp+$28
    db $e4
    ld hl, sp+$29
    db $e4
    ld hl, sp+$28
    ldh a, [$ff60]
    ld b, d
    ld b, d
    ld [hl+], a
    ld [hl+], a
    ld hl, sp+$29
    ld [de], a
    ld [de], a
    ld [de], a
    ld [bc], a
    ldh a, [rNR43]
    ld hl, sp+$28
    ld [bc], a
    ld [de], a
    ld [de], a
    ld [de], a
    ld hl, sp+$29
    ld [hl+], a
    ld [hl+], a
    ld b, d
    ld b, d
    ld hl, sp+$28
    ld b, c
    rst $28
    rst $28

jr_000_36bc:
    rst $28
    rst $28
    rst $28
    rst $38
    ld hl, sp+$2c
    nop
    rst $28
    rst $28
    rst $28
    di
    dec d
    ld hl, sp+$42
    ldh a, [rNR41]

jr_000_36cc:
    jr nz, jr_000_36bc

    ld hl, sp+$43
    rst $28
    ld hl, sp+$42
    rst $28
    ld hl, sp+$43
    add sp, $10
    rst $20
    nop
    db $e3
    ld hl, sp+$42
    ldh a, [rNR43]
    nop
    db $e3
    db $10
    rst $20
    jr nz, jr_000_36cc

    ld hl, sp+$43
    rst $28
    ld hl, sp+$42
    rst $28
    ld hl, sp+$43
    rst $28
    nop
    rst $28
    rst $28
    rst $38
    ld hl, sp+$03
    di
    dec c
    ld hl, sp+$09
    di
    dec c
    ld hl, sp+$68
    nop
    rst $28
    rst $38
    ld hl, sp+$68
    ldh a, [rNR41]
    db $f4
    ld bc, $ee10
    rst $28
    rst $28
    rst $28
    add sp, -$0c

Jump_000_370c:
    rrca
    nop
    rst $28
    di
    rst $38
    ld sp, hl
    inc bc
    ld hl, sp+$2d
    di
    dec c
    db $f4
    ld [bc], a
    ldh a, [rLCDC]
    ld hl, sp+$32
    ld bc, $f8e8
    inc sp
    jp hl


    ld hl, sp+$32
    jp hl


    ld hl, sp+$33
    jp hl


    ld hl, sp+$32
    jp hl


jr_000_372b:
    ld hl, sp+$33
    jp hl


    pop af
    rla
    di
    jr jr_000_372b

    ld a, $70
    ldh a, [rNR41]
    db $10
    xor $e8
    ldh a, [rLCDC]
    ld de, $01ee
    xor $f0
    ld [hl+], a
    ld de, $10ee
    rst $20
    ldh a, [rDIV]
    ld de, $01ee
    xor $ef
    di
    rst $38
    ld hl, sp+$40
    nop
    rst $28
    rst $28
    rst $28

Call_000_3755:
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    di
    ld d, $f9
    inc bc
    ld hl, sp+$37
    di
    dec c
    ld hl, sp+$4f
    db $10
    rst $28
    rst $28
    add sp, -$08
    ld c, [hl]
    nop
    add sp, -$07
    inc b
    pop af
    rra
    rst $28
    rst $38
    ldh a, [$ff30]
    ld hl, sp+$1f
    scf
    ld b, h
    di
    ld e, $f4
    ld bc, $36f8
    nop
    rst $28
    rst $28
    rst $28
    di
    add hl, de
    ld hl, sp+$2a
    ldh a, [$ff90]
    db $f4
    ld [bc], a
    ld [de], a
    rst $20
    ld hl, sp+$2b
    add sp, -$01
    ld hl, sp+$4a
    ld bc, $f8e7
    ld c, e
    add sp, -$01
    ld hl, sp+$1f
    ldh a, [$ff30]
    ld [hl], b
    ld [hl], b
    ld b, b
    di
    ld e, b
    ld hl, sp+$28
    ldh a, [$ff08]
    db $f4
    ld [bc], a
    db $10
    db $e3
    ld hl, sp+$29
    db $e4
    rst $38
    ldh a, [rNR43]
    ld b, b
    pop af
    ld [hl+], a
    ldh a, [rNR41]
    ld d, b
    ld d, b
    ld h, b
    pop af
    ld [hl+], a
    ld hl, sp+$14
    nop
    rst $28
    ld hl, sp+$15
    rst $28
    ld hl, sp+$1f
    di
    rst $38
    ld hl, sp+$45
    db $f4
    ld bc, $e301
    ld hl, sp+$46
    db $e4
    rst $38
    ld hl, sp+$45
    ldh a, [$ffc0]
    db $f4
    ld bc, $ef12

jr_000_37d6:
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    di
    rst $38
    ld hl, sp+$2a
    ldh a, [$ff60]
    jr nz, jr_000_37d6

    ld hl, sp+$2b
    rst $28
    ld hl, sp+$2a
    ldh a, [$ff60]
    rst $28
    ld hl, sp+$2b
    add sp, $10
    rst $20
    nop
    db $e3
    ld hl, sp+$2a
    ldh a, [$ff62]
    ld sp, hl
    inc b
    pop af
    inc hl
    nop
    db $e3
    db $10
    rst $20
    jr nz, @-$17

    ld hl, sp+$2b
    rst $28
    ld hl, sp+$2a
    ldh a, [rLCDC]
    rst $28
    ld hl, sp+$2b
    rst $28
    nop
    rst $28
    rst $28
    rst $38
    ld hl, sp+$32
    ldh a, [rNR43]
    nop
    rst $28
    rst $28
    db $f4
    nop
    or $01
    db $10
    add sp, -$08
    inc sp
    add sp, -$08
    ld [hl-], a
    add sp, -$08
    inc sp
    add sp, -$08
    ld [hl-], a
    add sp, -$08
    inc sp
    add sp, -$08
    ld [hl-], a
    add sp, -$08
    inc sp
    add sp, -$08
    ld [hl-], a
    add sp, -$08
    inc sp
    add sp, -$08
    ld [hl-], a
    ldh a, [rNR41]
    db $f4
    ld bc, $f8e8
    inc sp
    add sp, -$08
    ld [hl-], a
    add sp, -$08
    inc sp
    add sp, -$08
    ld [hl-], a
    add sp, -$08
    inc sp
    add sp, -$08
    ld [hl-], a
    add sp, -$08
    inc sp
    add sp, -$08
    ld [hl-], a
    add sp, -$08
    inc sp
    add sp, -$08
    ld [hl-], a
    add sp, -$08
    inc sp
    add sp, -$01
    di
    rst $38
    ld hl, sp+$14
    nop
    rst $20
    ld hl, sp+$15
    add sp, -$08
    inc d
    add sp, -$08
    dec d
    add sp, -$0d
    rst $38
    db $f4
    ld bc, $16f8
    ldh a, [$ff31]
    ld [hl], b
    ld de, $01e5
    ld de, $1101
    ld bc, $f001
    ld [hl+], a
    ld bc, $1101
    ld bc, $0111
    ld de, $f3e5
    add hl, hl
    ld hl, sp+$16
    db $f4
    ld bc, $ef01
    rst $38
    db $f4
    ld bc, $17f8
    ldh a, [$ff31]
    ld [hl], b
    ld de, $01e5
    ld de, $1101
    ld bc, $f001
    ld [hl+], a
    ld bc, $1101
    ld bc, $0111
    ld de, $f3e5
    dec hl
    ld hl, sp+$17
    db $f4
    ld bc, $ef01
    rst $38
    db $f4
    ld bc, $19f8
    ldh a, [$ff31]
    ld b, b
    ld b, b
    di
    inc [hl]
    db $f4
    ld [bc], a
    ldh a, [rNR41]
    ld hl, sp+$1a
    db $10
    db $e3
    ld hl, sp+$1b
    db $e3
    di
    ld l, $f8
    ld a, [de]
    nop
    add sp, -$08
    dec de
    add sp, -$01
    ld hl, sp+$2c
    ldh a, [$ff91]
    db $f4
    ld bc, $ef01
    ld b, c
    pop af
    jr nc, jr_000_38e6

    rst $28

jr_000_38e6:
    ld b, c
    pop af
    jr nc, jr_000_38eb

    rst $28

jr_000_38eb:
    ld b, c
    di
    jr nc, @-$0e

    db $10
    ld hl, sp+$2c
    ld bc, $f8ee
    ld l, $ef
    ld hl, sp+$2c
    rst $28
    ld hl, sp+$2e
    rst $28
    ld hl, sp+$2c
    rst $28
    ld hl, sp+$2e
    rst $28
    ld hl, sp+$2c
    rst $28
    ld hl, sp+$2e
    add sp, -$10
    add b
    ld hl, sp+$2c
    db $10
    rst $28
    ldh a, [rNR11]
    ld hl, sp+$2e
    db $10
    rst $28
    ld hl, sp+$2c
    ld [bc], a
    xor $f8
    ld l, $ef
    ld hl, sp+$2c
    rst $28
    ld hl, sp+$2e
    rst $28
    ld hl, sp+$2c
    rst $28
    ld hl, sp+$2e
    rst $28
    ld hl, sp+$2c
    rst $28
    ld hl, sp+$2e
    rst $28
    di
    rst $38
    db $f4
    inc b
    ld hl, sp+$2a
    ld b, $f8
    dec hl
    ld b, $ff
    ld hl, sp+$54
    db $f4
    ld bc, $33f1
    ldh a, [rDIV]
    nop
    rst $20
    ld hl, sp+$55
    rlca
    dec b
    nop
    rst $28
    rst $28
    rst $28
    ldh a, [rLCDC]
    ld hl, sp+$54
    rlca
    dec b
    rst $38
    ld hl, sp+$1f
    ldh a, [$ff30]
    ld [hl], d
    ld [hl], d
    ld b, d
    di
    ld b, a
    ld hl, sp+$19
    db $f4
    ld [bc], a
    ldh a, [rNR41]
    ld sp, $e421
    ld de, $01e4
    ld de, $f001
    ld [hl+], a
    ld bc, $0111
    ld de, $21e4
    db $e4
    ld sp, $ef30
    rst $28
    rst $28
    rst $28
    rst $28
    rst $38
    ld hl, sp+$20
    ldh a, [rNR43]
    db $f4
    ld bc, $01f6
    db $10
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $38
    ld hl, sp+$21
    nop
    rst $38
    ld hl, sp+$21
    ldh a, [rNR43]
    nop
    rst $20
    db $10
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $38
    ld hl, sp+$12
    ldh a, [$ff32]
    db $f4
    ld [bc], a
    ld de, $efee
    add sp, -$10
    ld sp, $ee11
    rst $28
    add sp, -$01
    ld hl, sp+$12
    ldh a, [$ff30]
    db $f4
    ld [bc], a
    ld de, $efee
    add sp, -$10
    inc sp
    ld de, $efee
    add sp, -$01
    ld hl, sp+$22
    db $f4
    ld bc, $22f0
    db $10
    xor $ef
    rst $28
    rst $28
    ldh a, [rNR41]
    rst $28
    rst $28
    rst $28
    rst $28
    rst $38
    ld hl, sp+$22
    db $f4
    ld bc, $10f0
    ld bc, $efee
    rst $28
    add sp, -$10
    ld de, $efef
    rst $28
    add sp, -$01
    ld hl, sp+$23
    db $f4
    ld bc, $60f0
    ld sp, $e221
    ld hl, sp+$24
    db $e4
    ld hl, sp+$25
    ldh [c], a
    ld de, $f8e1
    inc h
    db $e4
    ld de, $23f8
    nop
    ld de, $1100
    ld hl, sp+$24
    nop
    ld bc, $22f0
    ld bc, $f800
    dec h
    ld de, $1100
    nop
    ld hl, sp+$24
    ld de, $f8e3
    inc hl
    db $e3
    ld hl, $24f8
    db $e4
    ld hl, sp+$25
    db $e4
    ld hl, sp+$24
    ld sp, $ef40
    rst $28
    rst $28
    rst $28
    rst $28
    rst $38
    ld hl, sp+$26
    nop
    rst $28
    rst $28
    rst $28
    di
    ld a, $f9
    inc bc
    ld hl, sp+$27
    di
    dec c
    ld hl, sp+$2a
    ldh a, [rLCDC]
    nop
    rst $28
    rst $28
    rst $28
    rst $28
    ldh a, [rLCDC]
    rst $28
    rst $28
    ld hl, sp+$2b
    ld sp, hl
    inc b
    pop af
    inc hl
    rst $28
    rst $28
    rst $28
    rst $38
    ld hl, sp+$2e

jr_000_3a56:
    nop
    rst $28
    rst $28
    rst $28
    di
    ld b, c

jr_000_3a5c:
    ld sp, hl
    inc bc
    ld hl, sp+$2f
    di
    dec c
    ld hl, sp+$30
    ldh a, [rNR10]
    ld bc, $f8e8
    ld sp, $f8e8
    jr nc, jr_000_3a56

    ld hl, sp+$31
    add sp, -$08
    jr nc, jr_000_3a5c

    ld hl, sp+$31
    nop
    add sp, -$08
    jr nc, @-$16

    ld hl, sp+$31
    pop af
    ld b, l
    add sp, -$08
    jr nc, @-$16

    ld hl, sp+$31
    rst $38
    ld hl, sp+$34
    nop
    rst $28
    rst $28
    rst $28
    di
    ld b, h
    ld sp, hl
    inc bc
    ld hl, sp+$35
    di
    dec c
    ldh a, [rNR43]
    ld hl, sp+$44
    db $10
    rst $28
    rst $38
    ldh a, [rNR10]
    inc b
    ld sp, hl
    ld bc, $0ff8
    nop
    db $e4
    ld hl, sp+$10
    db $e4
    ld hl, sp+$0f
    db $e4
    ld hl, sp+$10
    db $e4
    ld hl, sp+$0f
    db $e4
    ld hl, sp+$10
    db $e4
    ld hl, sp+$0f
    db $e4
    ld hl, sp+$10
    db $e4
    ld hl, sp+$0f
    db $e4
    ld hl, sp+$10
    db $e4
    di
    rst $38
    ld hl, sp+$31
    ldh a, [rNR41]
    db $f4
    ld [bc], a
    ld b, d
    ld b, d
    ld [hl+], a
    ld [hl+], a
    ld hl, sp+$47
    ld [de], a
    ld [de], a
    ld [de], a
    ld [bc], a
    ldh a, [rNR43]
    ld hl, sp+$31
    ld [bc], a
    ld [de], a
    ld [de], a
    ld [de], a
    ld hl, sp+$47
    ld [hl+], a
    ld [hl+], a
    ld b, d
    ld b, d
    ld hl, sp+$31
    ld b, c
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $38
    db $f4
    ld bc, $4cf8
    ld de, $f8ee
    ld c, l
    rst $28
    rst $38
    ld hl, sp+$51
    ldh a, [rNR41]
    nop
    rst $28
    db $10
    rst $28
    nop
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    ld a, [$f109]
    ld c, d
    rst $28
    rst $28

jr_000_3b06:
    ldh a, [rNR43]
    db $10
    rst $28
    nop
    rst $28
    rst $28
    rst $28
    rst $38
    ld hl, sp+$1f
    ldh a, [$ff30]
    ld [hl], b
    jr nc, jr_000_3b06

    ld b, b
    di
    ld c, e
    ld hl, sp+$52
    ld bc, $f8e7
    ld d, e
    add sp, -$01
    ld hl, sp+$21
    nop
    rst $38
    ld hl, sp+$21
    ldh a, [rNR41]
    nop
    rst $20
    db $10
    xor $ef
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    di
    ld c, [hl]
    ld hl, sp+$21
    ldh a, [rNR11]
    ld [bc], a
    rst $28
    rst $38
    ld sp, hl
    ld bc, $14f8
    nop
    rst $28
    ld hl, sp+$15
    rst $28
    ld sp, hl

jr_000_3b46:
    ld bc, $f8f7
    rra
    ldh a, [$ff91]
    di
    ld e, d
    ld hl, sp+$46
    ldh a, [$ff31]
    ld [hl], h
    db $f4
    nop
    jr nz, jr_000_3b46

    add sp, $10
    rst $28
    ldh a, [rNR43]
    db $10
    rst $28
    jr nz, @-$0f

    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $38
    ld hl, sp+$31
    ldh a, [rNR10]
    db $f4
    ld bc, $ef02
    rst $28
    db $e4
    ldh a, [$ff90]
    ld [hl+], a
    ld [$09fa], a
    pop af
    ld d, b
    rst $38
    ld hl, sp+$33
    ldh a, [$ff90]
    db $f4
    ld bc, $e302
    ld hl, sp+$32
    db $e4
    ei
    jr nz, @-$06

    ld [hl-], a
    ld b, c
    ld b, c
    ld b, c
    ld sp, $33f8
    ld sp, $1131
    ld hl, $32f8
    ld de, $1111
    ld hl, sp+$33
    ld de, $0101
    ldh a, [$ff08]
    ld hl, sp+$32
    ld bc, $1101
    ld hl, sp+$33
    ld de, $1111
    ld hl, sp+$32
    ld hl, $3111
    ld sp, $33f8
    ld sp, $4141
    ld b, c
    ld [bc], a
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $38
    ld hl, sp+$45
    db $f4
    inc bc
    ld b, c
    ld b, c
    ld b, c
    ld b, e
    inc sp
    inc hl
    inc h
    inc d
    inc b
    ldh a, [$ff08]
    inc d
    inc d
    inc d
    inc [hl]
    inc sp
    ld [hl-], a
    ld b, d
    ld b, c
    ld b, b
    ldh a, [rDIV]
    rst $38
    ld hl, sp+$5f
    ldh a, [rNR43]
    ld hl, sp+$5f
    nop
    rst $28
    db $10
    rst $28
    nop
    rst $28
    ld hl, sp+$60
    rst $28
    ld hl, sp+$5f
    rst $28
    ld hl, sp+$60
    rst $28
    ld hl, sp+$5f
    rst $28
    ld hl, sp+$60
    rst $28
    ld hl, sp+$5f
    rst $28
    ldh a, [rNR41]
    db $10
    rst $28
    nop
    rst $28
    rst $28
    rst $28
    rst $38
    ld hl, sp+$28
    ldh a, [$ff60]
    db $f4
    ld [bc], a
    nop
    ldh [c], a
    ld hl, sp+$29
    ldh [c], a
    ld hl, sp+$28
    ldh [c], a
    ld hl, sp+$29
    ldh [c], a
    ld hl, sp+$28
    ldh a, [$ff60]
    ld b, d
    ld [hl-], a
    ld [hl-], a
    ld [hl+], a
    ld [de], a
    ld [de], a
    ldh a, [rNR43]
    ld [de], a
    ld [hl+], a
    ld [hl+], a
    ld [hl-], a
    ld [hl-], a
    ld b, d
    ld hl, sp+$28
    ld b, c
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $38
    db $f4
    ld [bc], a
    ld hl, sp+$2c
    nop
    rst $28
    rst $28
    rst $28
    rst $28
    di
    ld d, [hl]
    ld hl, sp+$45
    ld bc, $f8e3
    ld b, [hl]
    db $e4
    rst $38
    ldh a, [$ff08]
    db $f4
    ld [bc], a
    ld hl, sp+$61
    db $10
    ld hl, sp+$62
    db $10
    ld hl, sp+$61
    db $10
    ld hl, sp+$62
    db $10
    ld hl, sp+$61
    db $10
    ld hl, sp+$62
    db $10
    ld hl, sp+$61
    db $10
    ld hl, sp+$62
    db $10
    rst $38
    db $f4
    ld bc, $52f8
    ld [de], a
    rst $20
    ld hl, sp+$53
    add sp, -$01
    db $fd
    inc de
    ld hl, sp+$1f
    db $f4
    rrca
    nop
    rst $28
    ld hl, sp+$63
    ldh a, [rNR41]
    db $f4
    ld [bc], a
    db $10
    rst $28
    rst $28
    rst $28
    di
    ld h, b
    ld hl, sp+$1f
    ldh a, [rNR10]
    inc b
    ld hl, sp+$64
    ldh a, [rNR41]
    db $f4
    ld bc, $e801
    db $f4
    nop
    ld hl, sp+$1f
    pop af
    ld e, a
    ld b, b
    pop af
    ld e, [hl]
    ld b, b
    di
    ld e, l
    ld hl, sp+$45
    ldh a, [$ff30]
    db $f4
    ld bc, $ea21
    db $f4
    nop
    add sp, $02
    add sp, -$11
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $38
    ld hl, sp+$45
    ldh a, [$ff30]
    db $f4
    ld bc, $ea01
    db $f4
    nop
    add sp, $02
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $38
    ld hl, sp+$45
    ldh a, [$ff32]
    db $f4
    ld bc, $ea21

Jump_000_3cc2:
    db $f4
    nop
    add sp, $02
    add sp, -$11
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $28
    rst $38
    ld hl, sp+$63
    pop af
    ld e, h
    ldh a, [$ff90]
    db $10
    rst $28
    rst $28
    ld bc, $f1ef
    ld e, h
    ldh a, [$ff91]
    db $10
    rst $28
    add sp, $01
    rst $28
    rst $38
    db $f4
    ld bc, $66f8
    ld de, $f8e3
    ld h, a
    db $e4
    ld hl, sp+$66
    db $e4
    ld hl, sp+$67
    db $e4
    ld hl, sp+$66
    db $e4
    ld hl, sp+$67
    db $e4
    pop af
    ld d, e
    rst $38
    ld sp, hl
    ld bc, $14f8
    nop
    rst $20
    ld hl, sp+$15
    add sp, -$08
    inc d
    add sp, -$08
    dec d
    add sp, -$08
    rra
    db $fc
    xor b
    di
    ld e, e

Call_000_3d11:
    ld hl, $c030
    ld b, $20
    xor a

jr_000_3d17:
    ld [hl+], a
    dec b
    jr nz, jr_000_3d17

    ld hl, $da00
    ld a, $28
    ld [hl+], a
    xor a
    ld [hl+], a
    ld a, $04
    ld [hl+], a
    call Call_000_3d75
    ld a, $20
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld a, $f6
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld a, $30
    ld [hl+], a
    xor a
    ld b, $09

jr_000_3d3b:
    ld [hl+], a
    dec b
    jr nz, jr_000_3d3b

    ld a, $02
    ld [hl+], a
    dec a
    ld [hl+], a
    xor a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld a, $40
    ld [hl+], a
    xor a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld a, $40
    ld [hl+], a
    xor a
    ld b, $08

jr_000_3d56:
    ld [hl+], a
    dec b
    jr nz, jr_000_3d56

    ld a, $04
    ld [hl+], a
    ld a, $11
    ld [hl], a
    ret


Call_000_3d61:
    ld a, [$c0a4]
    and a
    ret nz

    ldh a, [$ffb3]
    cp $12
    ret nc

    ld a, [$da00]
    cp $28
    ret nz

    call Call_000_3d75
    ret


Call_000_3d75:
    ld de, $9833
    ld a, [$da01]
    ld b, a
    and $0f
    ld [de], a
    dec e
    ld a, b
    and $f0
    swap a
    ld [de], a
    dec e
    ld a, [$da02]
    and $0f
    ld [de], a
    ret


    ld hl, $dfe8
    ld a, $09
    ld [hl], a
    xor a
    ldh [rLCDC], a
    ldh [$ffa4], a
    ld hl, $c000
    ld b, $a0

jr_000_3d9e:
    ld [hl+], a
    dec b
    jr nz, jr_000_3d9e

    ld hl, $9800
    ld b, $ff
    ld c, $03
    ld a, $2c

jr_000_3dab:
    ld [hl+], a
    dec b
    jr nz, jr_000_3dab

    ld b, $ff
    dec c
    jr nz, jr_000_3dab

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
    ld a, $83
    ldh [rLCDC], a
    ld a, $13
    ldh [$ffb3], a
    ret


    xor a
    ldh [rLCDC], a
    ld hl, $9800
    ld a, $f5
    ld [hl+], a
    ld b, $12
    ld a, $9f

jr_000_3ddb:
    ld [hl+], a
    dec b
    jr nz, jr_000_3ddb

    ld a, $fc
    ld [hl], a
    ld de, $0020
    ld l, e
    ld b, $10
    ld c, $02
    ld a, $f8

jr_000_3dec:
    ld [hl], a
    add hl, de
    dec b
    jr nz, jr_000_3dec

    ld l, $33
    dec h
    dec h
    ld b, $10
    dec c
    jr nz, jr_000_3dec

    ld hl, $9a20
    ld a, $ff
    ld [hl+], a
    ld b, $12
    ld a, $9f

jr_000_3e04:
    ld [hl+], a
    dec b
    jr nz, jr_000_3e04

    ld a, $e9
    ld [hl], a
    ld hl, $9845
    ld a, $0b
    ld [hl+], a
    ld a, $18
    ld [hl+], a
    dec a
    ld [hl+], a
    ld a, $1e
    ld [hl+], a
    ld a, $1c
    ld [hl+], a
    inc l
    ld a, $10
    ld [hl+], a
    ld a, $0a
    ld [hl+], a
    ld a, $16
    ld [hl+], a
    ld a, $0e
    ld [hl], a
    ld hl, $9887
    ld a, $e4
    ld [hl+], a
    inc l
    ld a, $2b
    ld [hl], a
    ld l, $e1
    ld a, $2d
    ld b, $12

jr_000_3e39:
    ld [hl+], a
    dec b
    jr nz, jr_000_3e39

    ld l, $d1
    ld a, $2b
    ld [hl+], a
    ld l, $41
    inc h
    ld a, $2d
    ld b, $12

jr_000_3e49:
    ld [hl+], a
    dec b
    jr nz, jr_000_3e49

    ld l, $31
    ld a, $2b
    ld [hl+], a
    ld l, $a1
    ld a, $2d
    ld b, $12

jr_000_3e58:
    ld [hl+], a
    dec b
    jr nz, jr_000_3e58

    ld l, $91
    ld a, $2b
    ld [hl+], a
    ld l, $01
    inc h
    ld a, $2d
    ld b, $12

jr_000_3e68:
    ld [hl+], a
    dec b
    jr nz, jr_000_3e68

    ld l, $f1
    dec h
    ld a, $2b
    ld [hl+], a
    nop
    ld bc, $e502
    inc bc
    ld bc, $e502
    ld de, $3e72
    ldh a, [rDIV]
    and $03
    inc a

jr_000_3e82:
    inc de
    dec a
    jr nz, jr_000_3e82

    ld hl, $98d2
    ld bc, $0060

jr_000_3e8c:
    ld a, [de]
    ld [hl], a
    inc de
    add hl, bc
    ld a, l
    cp $52
    jr nz, jr_000_3e8c

    ld a, $83
    ldh [rLCDC], a
    ld a, $14
    ldh [$ffb3], a
    ret


    ld bc, $0020

jr_000_3ea1:
    ld de, $da23
    ld a, [$da18]
    ld h, a
    ld a, [$da19]
    ld l, a

jr_000_3eac:
    ld a, [de]
    ld [hl], a
    inc de
    add hl, bc
    ld a, [$da28]
    dec a
    ld [$da28], a
    jr nz, jr_000_3eac

    ld a, $04
    ld [$da28], a
    ld a, [$da29]
    dec a
    ld [$da29], a
    jr nz, jr_000_3ea1

    ld a, $11
    ld [$da29], a
    ld a, $15
    ldh [$ffb3], a
    ret


Call_000_3ed1:
    ldh a, [$ffad]
    sub $10
    srl a
    srl a
    srl a
    ld de, $0000
    ld e, a
    ld hl, $9800
    ld b, $20

jr_000_3ee4:
    add hl, de
    dec b
    jr nz, jr_000_3ee4

    ldh a, [$ffae]
    sub $08
    srl a
    srl a
    srl a
    ld de, $0000
    ld e, a
    add hl, de
    ld a, h
    ldh [$ffb0], a
    ld a, l
    ldh [$ffaf], a
    ret


Call_000_3efe:
    ldh a, [$ffb0]
    ld d, a
    ldh a, [$ffaf]
    ld e, a
    ld b, $04

jr_000_3f06:
    rr d
    rr e
    dec b
    jr nz, jr_000_3f06

    ld a, e
    sub $84
    and $fe
    rlca
    rlca
    add $08
    ldh [$ffad], a
    ldh a, [$ffaf]
    and $1f
    rla
    rla
    rla
    add $08
    ldh [$ffae], a
    ret


Call_000_3f24:
    ldh a, [$ffb1]
    and a
    ret z

    ld a, [$c0e2]
    and a
    ret nz

    ldh a, [$ffea]
    cp $02
    ret z

    ld de, $c0a2
    ld hl, $9820

Call_000_3f38:
    xor a
    ldh [$ffb1], a
    ld c, $03

jr_000_3f3d:
    ld a, [de]
    ld b, a
    swap a
    and $0f
    jr nz, jr_000_3f6d

    ldh a, [$ffb1]
    and a
    ld a, $00
    jr nz, jr_000_3f4e

    ld a, $2c

jr_000_3f4e:
    ld [hl+], a
    ld a, b
    and $0f
    jr nz, jr_000_3f75

    ldh a, [$ffb1]
    and a
    ld a, $00
    jr nz, jr_000_3f64

    ld a, $01
    cp c
    ld a, $00
    jr z, jr_000_3f64

    ld a, $2c

jr_000_3f64:
    ld [hl+], a
    dec e
    dec c
    jr nz, jr_000_3f3d

    xor a
    ldh [$ffb1], a
    ret


jr_000_3f6d:
    push af
    ld a, $01
    ldh [$ffb1], a
    pop af
    jr jr_000_3f4e

jr_000_3f75:
    push af
    ld a, $01
    ldh [$ffb1], a
    pop af
    jr jr_000_3f64

    ld a, $c0
    ldh [rDMA], a
    ld a, $28

jr_000_3f83:
    dec a
    jr nz, jr_000_3f83

    ret


    ld d, $0a
    dec de
    ld [de], a
    jr jr_000_3fb8

    inc l
    inc l
    inc l
    inc l
    jr nz, jr_000_3fab

    dec de
    dec d
    dec c
    inc l
    dec e
    ld [de], a
    ld d, $0e
    inc l
    inc l
    inc l
    inc l
    inc l
    inc l
    inc l
    ld a, [hl+]
    dec hl
    inc l
    inc l
    inc l
    ld bc, $0129
    inc l

jr_000_3fab:
    inc l
    nop
    nop
    nop
    nop
    nop
    nop
    db $10
    jr c, jr_000_3fed

    jr z, jr_000_3fc7

    nop

jr_000_3fb8:
    ldh [$ffb1], a
    ld e, e
    rst $38
    rst $38
    rst $38
    rst $38
    ld a, [hl]
    inc a
    jr jr_000_3fc3

jr_000_3fc3:
    nop
    add c
    ld b, d
    and l

jr_000_3fc7:
    nop
    pop hl
    inc sp
    sbc $ff
    rst $20
    db $db
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

jr_000_3fed:
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
