Consulte le [script]("../scripts/bfs_explorer.py") qui a permis de générer ces informations

Je souhaite pouvoir améliorer ce script en te laissant constater les résultats qu'il a  produit

Voici le commentaire git
<CommentaireGit>
[BFS-2D1C] Audio command sequence 6 (table 1)
</CommentaireGit>

Le diff git
<DiffGit>
diff --git a/scripts/bfs_state.json b/scripts/bfs_state.json
index 6ed5a6e..98b7001 100644
--- a/scripts/bfs_state.json
+++ b/scripts/bfs_state.json
@@ -3580,6 +3580,7 @@
     "$124B",
     "$1D0B",
     "$21f5",
+    "$2D1C",
     "$255F",
     "$2A1A",
     "$1385",
@@ -3887,6 +3888,6 @@
     "$14BB",
     "$2222"
   ],
-  "commits_since_push": 3,
-  "total_explored": 324
+  "commits_since_push": 4,
+  "total_explored": 325
 }
\ No newline at end of file
diff --git a/src/bank_000.asm b/src/bank_000.asm
index 2217583..d2563e3 100644
--- a/src/bank_000.asm
+++ b/src/bank_000.asm
@@ -10866,463 +10866,192 @@ AudioCmdSeq_04:
 AudioCmdSeq_05:
     db $40, $95, $48
 
-; AudioAnimData_00 ($2D12)
-; ----------------
-; Table de données d'animation audio n°0
-; Format: séquence d'octets de commandes d'animation, terminée par $FF
-; Note: partage les 2 premiers octets ($94, $FF) avec la fin de AudioCmdSeq_05 pour économiser la ROM
+; Optimisation ROM: AudioAnimData_00 ($2D12) partage ses octets avec la fin de AudioCmdSeq_05
+; Cette zone contient des séquences de commandes audio référencées par AudioChannelCommandTable1
+; et des données d'animation audio (AudioAnimData_00, _01, etc.)
 AudioAnimData_00:
     db $94, $FF  ; octets partagés avec AudioCmdSeq_05
-    db $97, $08, $96, $FF
-    db $99, $08, $98, $FF
-    db $10, $97, $18, $96, $FF
-    db $10, $99, $18, $98, $FF
-    db $9A, $FF
-    db $20, $96, $28, $97, $FF
-    db $10, $89, $11, $88, $18, $87, $FF
-    db $10, $8C, $11, $8B, $18, $8A, $FF
-    db $88, $01, $89, $0A, $87, $FF
-    db $8B, $01, $8C, $0A, $8A, $FF
-    db $10, $9C, $11, $8D, $FF
-    db $8D, $01, $9C, $FF
-    db $20, $8D, $21, $9C, $FF
-    db $9B, $FF
-    db $9D, $11, $9D, $FF
-    db $9E, $11, $9E, $FF
-    db $EF, $01, $EF, $01, $EF, $FF
-    db $DD, $01, $DE, $FF
-    db $20, $9D, $31, $9D, $0A, $9D, $11, $9D, $FF
 
+; AudioAnimData_01 ($2D14)
+; Séquence de 4 octets pour animation audio
 AudioAnimData_01:
-    jr nz, AudioAnimData_00
-
-    ld sp, $0a9e
-    sbc [hl]
-    ld de, hAnimStructBank
-    add e
-    rst $38
-    add h
-    rst $38
-    add l
-    rst $38
-    add [hl]
-    rst $38
-    ld b, b
-    ldh [rIE], a
-    push hl
-    rst $38
-    ld b, b
-    or $ff
-    ld b, b
-    rst $30
-    rst $38
-    ld b, b
-    ld hl, sp-$01
-    cp $ff
-    rst $18
-    rst $38
-    ld b, b
-    xor $ff
-    rst $28
-    ld bc, $ffef
+    db $97, $08, $96, $FF
 
+; AudioAnimData_02 ($2D18)
+; Séquence de 4 octets pour animation audio
 AudioAnimData_02:
-    or b
-    ld bc, $0ab1
-    and b
-    ld bc, hTemp1
-    db $10
-    or c
-    ld de, $1ab0
-    and c
-    ld de, hTemp0
-    jr nc, AudioAnimData_01
-
-    ld sp, $3ac2
-    db $d3
-    ld sp, $ffd2
-    or d
-    ld bc, $0ab3
-
-AudioAnimData_03:
-    and d
-    ld bc, hTemp3
-    db $10
-    or e
-    ld de, $1ab2
-    and e
-    ld de, hTemp2
-    or h
-    ld bc, $0ab5
-    and h
-    ld bc, $ffa5
-    db $10
-    or l
-    ld de, $1ab4
-    and l
-    ld de, hShadowSCX
-    or [hl]
-    ld bc, $0ab7
-    and [hl]
-    ld bc, hTimer2
-    db $10
-    or a
-    ld de, $1ab6
-    and a
-    ld de, hTimer1
-    xor b
-    ld bc, hObjParamBuf1
-    db $10
-    xor c
-    ld de, $ffa8
-    jr nz, AudioAnimData_02
-
-    ld hl, hObjParamBuf1
-    cp b
-    ld bc, $ffb9
-    db $10
-    cp c
-    ld de, $ffb8
-    jr nz, AudioAnimData_03
+    db $99, $08, $98, $FF
 
-    ld hl, $ffb9
-    ret nc
+; AudioCmdSeq_06 ($2D1C)
+; ----------------
+; Séquence de commandes audio n°6 (entrée 6 de AudioChannelCommandTable1)
+; Description: Commandes audio $97 et $96 avec paramètres $10 et $18
+; In: via pointeur de AudioChannelCommandTable1[6]
+; Format: [paramètre, commande, paramètre, commande, $FF]
+AudioCmdSeq_06:
+    db $10, $97, $18, $96, $FF
 
-    ld bc, $0ad1
-    ret nz
+; AudioCmdSeq_07 ($2D21)
+; ----------------
+; Séquence de commandes audio n°7 (entrée 7 de AudioChannelCommandTable1)
+; Description: Commandes audio $99 et $98 avec paramètres $10 et $18
+; In: via pointeur de AudioChannelCommandTable1[7]
+; Format: [paramètre, commande, paramètre, commande, $FF]
+AudioCmdSeq_07:
+    db $10, $99, $18, $98, $FF
 
-    ld bc, hSoundFlag
-    db $10
-    pop de
-    ld de, $1ad0
-    pop bc
-    ld de, hSoundId
-    jp nc, $d301
+; AudioCmdSeq_08 ($2D26)
+; ----------------
+; Séquence de commandes audio n°8 (entrée 8 de AudioChannelCommandTable1)
+; Description: Commande audio $9A simple
+; In: via pointeur de AudioChannelCommandTable1[8]
+; Format: [commande, $FF]
+AudioCmdSeq_08:
+    db $9A, $FF
 
-    ld a, [bc]
-    jp nz, $c301
+; AudioCmdSeq_09 ($2D28)
+; ----------------
+; Séquence de commandes audio n°9 (entrée 9 de AudioChannelCommandTable1)
+; Description: Commandes audio $96 et $97 avec paramètres $20 et $28
+; In: via pointeur de AudioChannelCommandTable1[9]
+; Format: [paramètre, commande, paramètre, commande, $FF]
+AudioCmdSeq_09:
+    db $20, $96, $28, $97, $FF
 
-    rst $38
-    db $10
-    db $d3
-    ld de, $1ad2
-    jp wPlayerUnk11
+; AudioCmdSeq_10 ($2D2D)
+; ----------------
+; Séquence de commandes audio n°10 (entrée 10 de AudioChannelCommandTable1)
+; Description: Trio de commandes audio $89, $88, $87 avec paramètres $10, $11, $18
+; In: via pointeur de AudioChannelCommandTable1[10]
+; Format: [param, cmd, param, cmd, param, cmd, $FF]
+AudioCmdSeq_10:
+    db $10, $89, $11, $88, $18, $87, $FF
 
+; AudioCmdSeq_11 ($2D34)
+; ----------------
+; Séquence de commandes audio n°11 (entrée 11 de AudioChannelCommandTable1)
+; Description: Trio de commandes audio $8C, $8B, $8A avec paramètres $10, $11, $18
+; In: via pointeur de AudioChannelCommandTable1[11]
+; Format: [param, cmd, param, cmd, param, cmd, $FF]
+AudioCmdSeq_11:
+    db $10, $8C, $11, $8B, $18, $8A, $FF
 
-    rst $38
-    call nc, $d501
-    ld a, [bc]
-    call nz, $c501
-    rst $38
-    db $10
-    push de
-    ld de, $1ad4
-    push bc
-    ld de, hSoundCh1
-    sub $01
+; AudioAnimData_03 ($2D3B)
+; Séquence de 6 octets pour animation audio
+AudioAnimData_03:
+    db $88, $01, $89, $0A, $87, $FF
 
+; AudioAnimData_04 ($2D41)
+; Séquence de 6 octets pour animation audio
 AudioAnimData_04:
-    rst $10
-    ld a, [bc]
-    add $01
-    rst $00
-    rst $38
-    db $10
-    rst $10
-    ld de, $1ad6
-    rst $00
-    ld de, hSoundCh3
-    ret z
-
-    ld bc, hSoundVar2
-    db $10
-    ret
-
-
-    ld de, hSoundVar1
-    jr nz, @-$36
-
-    ld hl, hSoundVar2
-    ret c
-
-    ld bc, $ffd9
-    db $10
-    reti
-
-
-    ld de, $ffd8
-    jr nz, AudioAnimData_04
-
-    ld hl, $ffd9
-    xor h
-    rst $38
-    xor [hl]
-    rst $38
-    xor a
-    rst $38
-    cp l
-    ld bc, $01be
-    cp a
-    rst $38
-    db $10
-    cp a
-    ld de, $11be
-    cp l
-    rst $38
-    cp d
-    rst $38
-    cp e
-    rst $38
-    add $01
-    rst $00
-    rst $38
-    jr nz, @-$38
+    db $8B, $01, $8C, $0A, $8A, $FF
 
-    ld hl, hSoundCh4
-    sub $01
-    rst $10
-    rst $38
+; AudioCmdSeq_12 ($2D47)
+; ----------------
+; Séquence de commandes audio n°12 (entrée 12 de AudioChannelCommandTable1)
+; Description: Commandes audio $9C et $8D avec paramètres $10 et $11
+; In: via pointeur de AudioChannelCommandTable1[12]
+; Format: [param, cmd, param, cmd, $FF]
+AudioCmdSeq_12:
+    db $10, $9C, $11, $8D, $FF
 
+; AudioAnimData_05 ($2D4C)
+; Séquence de 4 octets pour animation audio
 AudioAnimData_05:
-    jr nz, @-$28
-
-    ld hl, $ffd7
-    ld b, b
-    ret nc
-
-    ld c, b
-    ret nz
-
-    rst $38
-    ld b, b
-    pop de
-    ld c, b
-    pop bc
-    rst $38
-    cp h
-    ld [hFrameCounter], sp
-    ldh [c], a
-    rst $38
-    db $e3
-    rst $38
-    call nz, $c501
-    rst $38
-    call nc, $d501
-    rst $38
-    sbc a
-    rst $38
-    xor d
-    rst $38
-    xor l
-    rst $38
-    ret c
-
-    rst $38
-    reti
-
-
-    rst $38
-    cp d
-    ld bc, $0abb
-    xor d
-    ld bc, hObjParamBuf3
-    ld b, b
-    and $ff
-    cp e
-    ld a, [bc]
-    xor d
-    ld bc, $11ab
-    xor d
-    rst $38
-    cp e
-    ld a, [bc]
-    cp d
-    ld bc, $11ab
-    cp d
-    rst $38
-    cp e
-    ld a, [bc]
-    xor h
-    ld bc, $11ab
-    xor h
-    rst $38
-    xor h
-    ld bc, $11ad
-    xor h
-    rst $38
-    jr nz, AudioAnimData_05
-
-    ld hl, $31ad
-    xor h
-    rst $38
-    jp c, $db01
-
-    ld bc, $0adc
-    ld [bc], a
-    jp z, $cb01
-
-    ld bc, $01cc
-    cp d
-    ld a, [bc]
-    ld [bc], a
-    ld [bc], a
-    call $ce01
-    rst $38
-    cp e
-    ld bc, $01d6
-    rst $10
-    ld a, [bc]
-    ld [bc], a
-    xor e
-    ld bc, $01c6
-    rst $00
-    ld bc, $0aaa
-    ld [bc], a
-    ld [bc], a
-    call $ce01
-    rst $38
-    jr nz, @-$54
-
-    ld sp, $0aaa
-    xor d
-    ld de, hObjParamBuf2
-    jr nz, @-$53
+    db $8D, $01, $9C, $FF
 
-    ld sp, $0aab
-    xor e
-    ld de, hObjParamBuf3
-    cp h
-    ld bc, $0abd
-    adc $01
-    rst $08
-    ld a, [bc]
-    cp [hl]
-    ld bc, $0abf
-    xor [hl]
-    ld bc, hSpriteTile
-    call z, $cd01
-    ld a, [bc]
-    jp c, $db01
+; AudioCmdSeq_13 ($2D50)
+; ----------------
+; Séquence de commandes audio n°13 (entrée 13 de AudioChannelCommandTable1)
+; Description: Commandes audio $8D et $9C avec paramètres $20 et $21
+; In: via pointeur de AudioChannelCommandTable1[13]
+; Format: [param, cmd, param, cmd, $FF]
+AudioCmdSeq_13:
+    db $20, $8D, $21, $9C, $FF
 
-    ld a, [bc]
-    jp z, $cb01
+; AudioCmdSeq_14 ($2D55)
+; ----------------
+; Séquence de commandes audio n°14 (entrée 14 de AudioChannelCommandTable1)
+; Description: Commande audio $9B simple
+; In: via pointeur de AudioChannelCommandTable1[14]
+; Format: [commande, $FF]
+AudioCmdSeq_14:
+    db $9B, $FF
 
-    ld a, [bc]
-    cp d
-    ld bc, $ffbb
-    ld b, b
-    adc b
-    ld c, b
-    add a
-    rst $38
-    ld sp, hl
-    ld bc, hOAMIndex
-    ld sp, hl
-    ld bc, hCoinCount
-    db $10
-    ld sp, hl
-    ld [de], a
-    ei
-    rst $38
-    db $10
-    ld sp, hl
-    ld [de], a
-    ld a, [$ceff]
-    ld bc, $0acf
-    cp [hl]
-    ld bc, $0abf
-    xor [hl]
-    ld bc, hSpriteTile
-    jp z, $cb01
+; AudioCmdSeq_15 ($2D57)
+; ----------------
+; Séquence de commandes audio n°15 (entrée 15 de AudioChannelCommandTable1)
+; Description: Commande audio $9D répétée avec paramètre $11
+; In: via pointeur de AudioChannelCommandTable1[15]
+; Format: [cmd, param, cmd, $FF]
+AudioCmdSeq_15:
+    db $9D, $11, $9D, $FF
 
-    ld a, [bc]
-    call z, $cd01
-    ld a, [bc]
-    cp h
-    ld bc, $ffbd
-    ret nc
+; AudioAnimData_06 ($2D5B)
+; Séquence de 4 octets pour animation audio
+AudioAnimData_06:
+    db $9E, $11, $9E, $FF
 
-    ld de, $0ad0
-    ret nz
+; AudioAnimData_07 ($2D5F)
+; Séquence de 6 octets pour animation audio
+AudioAnimData_07:
+    db $EF, $01, $EF, $01, $EF, $FF
 
-    ld de, hSoundId
-    pop de
-    ld de, $0ad1
-    pop bc
-    ld de, hSoundFlag
-    cp d
-    ld bc, $01bb
-    cp h
-    ld a, [bc]
-    xor e
-    rst $38
-    cp l
-    ld bc, $01be
-    cp a
-    ld a, [bc]
-    xor [hl]
-    rst $38
-    ld h, b
-    sub e
-    ld h, h
-    sub d
-    rst $38
-    ld h, b
-    sub l
-    ld h, h
-    sub h
-    rst $38
-    ld b, b
-    call z, $cd41
-    ld b, c
-    adc $41
-    rst $08
-    ld c, d
-    ld b, d
-    ld b, d
-    cp h
-    ld b, c
-    cp l
-    ld b, c
-    cp [hl]
-    ld b, c
-    cp a
-    ld c, d
-    ld b, d
-    ld b, d
-    xor h
-    ld b, c
-    xor l
-    ld b, c
-    xor [hl]
-    ld b, c
-    xor a
-    ld c, d
-    set 7, a
-    ld b, b
-    ldh a, [c]
-    ld b, c
-    di
-    ld c, d
-    ldh a, [rSTAT]
-    pop af
-    rst $38
-    adc h
-    ld bc, $018d
-    sbc h
-    ld a, [bc]
-    ld [bc], a
-    adc c
-    ld bc, $018a
-    adc e
-    rst $38
-    jp c, $c801
+; AudioAnimData_08 ($2D65)
+; Séquence de 4 octets pour animation audio
+AudioAnimData_08:
+    db $DD, $01, $DE, $FF
 
-    ld bc, $0ac9
-    ld [bc], a
-    jp z, $db01
+; AudioAnimData_09 ($2D69)
+; Séquence de 9 octets pour animation audio
+AudioAnimData_09:
+    db $20, $9D, $31, $9D, $0A, $9D, $11, $9D, $FF
 
-    ld bc, $ffdc
+; ===========================================================================
+; Zone de données mal désassemblées ($2D72-$2FD8)
+; TODO BFS: Reconstruire ces séquences audio référencées par AudioChannelCommandTable1Alt
+; et autres tables d'animation audio
+; ===========================================================================
+AudioAnimData_10:
+    db $20, $9E, $31, $9E, $0A, $9E, $11, $9E, $FF, $83, $FF, $84, $FF, $85, $FF, $86
+    db $FF, $40, $E0, $FF, $E5, $FF, $40, $F6, $FF, $40, $F7, $FF, $40, $F8, $FF, $FE
+    db $FF, $DF, $FF, $40, $EE, $FF, $EF, $01, $EF, $FF, $B0, $01, $B1, $0A, $A0, $01
+    db $A1, $FF, $10, $B1, $11, $B0, $1A, $A1, $11, $A0, $FF, $30, $C3, $31, $C2, $3A
+    db $D3, $31, $D2, $FF, $B2, $01, $B3, $0A, $A2, $01, $A3, $FF, $10, $B3, $11, $B2
+    db $1A, $A3, $11, $A2, $FF, $B4, $01, $B5, $0A, $A4, $01, $A5, $FF, $10, $B5, $11
+    db $B4, $1A, $A5, $11, $A4, $FF, $B6, $01, $B7, $0A, $A6, $01, $A7, $FF, $10, $B7
+    db $11, $B6, $1A, $A7, $11, $A6, $FF, $A8, $01, $A9, $FF, $10, $A9, $11, $A8, $FF
+    db $20, $A8, $21, $A9, $FF, $B8, $01, $B9, $FF, $10, $B9, $11, $B8, $FF, $20, $B8
+    db $21, $B9, $FF, $D0, $01, $D1, $0A, $C0, $01, $C1, $FF, $10, $D1, $11, $D0, $1A
+    db $C1, $11, $C0, $FF, $D2, $01, $D3, $0A, $C2, $01, $C3, $FF, $10, $D3, $11, $D2
+    db $1A, $C3, $11, $C2, $FF, $D4, $01, $D5, $0A, $C4, $01, $C5, $FF, $10, $D5, $11
+    db $D4, $1A, $C5, $11, $C4, $FF, $D6, $01, $D7, $0A, $C6, $01, $C7, $FF, $10, $D7
+    db $11, $D6, $1A, $C7, $11, $C6, $FF, $C8, $01, $C9, $FF, $10, $C9, $11, $C8, $FF
+    db $20, $C8, $21, $C9, $FF, $D8, $01, $D9, $FF, $10, $D9, $11, $D8, $FF, $20, $D8
+    db $21, $D9, $FF, $AC, $FF, $AE, $FF, $AF, $FF, $BD, $01, $BE, $01, $BF, $FF, $10
+    db $BF, $11, $BE, $11, $BD, $FF, $BA, $FF, $BB, $FF, $C6, $01, $C7, $FF, $20, $C6
+    db $21, $C7, $FF, $D6, $01, $D7, $FF, $20, $D6, $21, $D7, $FF, $40, $D0, $48, $C0
+    db $FF, $40, $D1, $48, $C1, $FF, $BC, $08, $AC, $FF, $E2, $FF, $E3, $FF, $C4, $01
+    db $C5, $FF, $D4, $01, $D5, $FF, $9F, $FF, $AA, $FF, $AD, $FF, $D8, $FF, $D9, $FF
+    db $BA, $01, $BB, $0A, $AA, $01, $AB, $FF, $40, $E6, $FF, $BB, $0A, $AA, $01, $AB
+    db $11, $AA, $FF, $BB, $0A, $BA, $01, $AB, $11, $BA, $FF, $BB, $0A, $AC, $01, $AB
+    db $11, $AC, $FF, $AC, $01, $AD, $11, $AC, $FF, $20, $AC, $21, $AD, $31, $AC, $FF
+    db $DA, $01, $DB, $01, $DC, $0A, $02, $CA, $01, $CB, $01, $CC, $01, $BA, $0A, $02
+    db $02, $CD, $01, $CE, $FF, $BB, $01, $D6, $01, $D7, $0A, $02, $AB, $01, $C6, $01
+    db $C7, $01, $AA, $0A, $02, $02, $CD, $01, $CE, $FF, $20, $AA, $31, $AA, $0A, $AA
+    db $11, $AA, $FF, $20, $AB, $31, $AB, $0A, $AB, $11, $AB, $FF, $BC, $01, $BD, $0A
+    db $CE, $01, $CF, $0A, $BE, $01, $BF, $0A, $AE, $01, $AF, $FF, $CC, $01, $CD, $0A
+    db $DA, $01, $DB, $0A, $CA, $01, $CB, $0A, $BA, $01, $BB, $FF, $40, $88, $48, $87
+    db $FF, $F9, $01, $FB, $FF, $F9, $01, $FA, $FF, $10, $F9, $12, $FB, $FF, $10, $F9
+    db $12, $FA, $FF, $CE, $01, $CF, $0A, $BE, $01, $BF, $0A, $AE, $01, $AF, $FF, $CA
+    db $01, $CB, $0A, $CC, $01, $CD, $0A, $BC, $01, $BD, $FF, $D0, $11, $D0, $0A, $C0
+    db $11, $C0, $FF, $D1, $11, $D1, $0A, $C1, $11, $C1, $FF, $BA, $01, $BB, $01, $BC
+    db $0A, $AB, $FF, $BD, $01, $BE, $01, $BF, $0A, $AE, $FF, $60, $93, $64, $92, $FF
+    db $60, $95, $64, $94, $FF, $40, $CC, $41, $CD, $41, $CE, $41, $CF, $4A, $42, $42
+    db $BC, $41, $BD, $41, $BE, $41, $BF, $4A, $42, $42, $AC, $41, $AD, $41, $AE, $41
+    db $AF, $4A, $CB, $FF, $40, $F2, $41, $F3, $4A, $F0, $41, $F1, $FF, $8C, $01, $8D
+    db $01, $9C, $0A, $02, $89, $01, $8A, $01, $8B, $FF, $DA, $01, $C8, $01, $C9, $0A
+    db $02, $CA, $01, $DB, $01, $DC, $FF
 
 ; ===========================================================================
 ; AudioChannelCommandTable1 ($2FD9)
@@ -11337,16 +11066,16 @@ AudioChannelCommandTable1:
     dw AudioCmdSeq_03  ; Entry  3 @ $2D07
     dw AudioCmdSeq_04  ; Entry  4 @ $2D0A
     dw AudioCmdSeq_05  ; Entry  5 @ $2D0F
-    dw $2D1C           ; Entry  6 - Audio sequence 6 (TODO: reconstruire)
-    dw $2D21           ; Entry  7 - Audio sequence 7 (TODO: reconstruire)
-    dw $2D26           ; Entry  8 - Audio sequence 8 (TODO: reconstruire)
-    dw $2D28           ; Entry  9 - Audio sequence 9 (TODO: reconstruire)
-    dw $2D2D           ; Entry 10 - Audio sequence 10 (TODO: reconstruire)
-    dw $2D34           ; Entry 11 - Audio sequence 11 (TODO: reconstruire)
-    dw $2D47           ; Entry 12 - Audio sequence 12 (TODO: reconstruire)
-    dw $2D50           ; Entry 13 - Audio sequence 13 (TODO: reconstruire)
-    dw $2D55           ; Entry 14 - Audio sequence 14 (TODO: reconstruire)
-    dw $2D57           ; Entry 15 - Audio sequence 15 (TODO: reconstruire)
+    dw AudioCmdSeq_06  ; Entry  6 @ $2D1C
+    dw AudioCmdSeq_07  ; Entry  7 @ $2D21
+    dw AudioCmdSeq_08  ; Entry  8 @ $2D26
+    dw AudioCmdSeq_09  ; Entry  9 @ $2D28
+    dw AudioCmdSeq_10  ; Entry 10 @ $2D2D
+    dw AudioCmdSeq_11  ; Entry 11 @ $2D34
+    dw AudioCmdSeq_12  ; Entry 12 @ $2D47
+    dw AudioCmdSeq_13  ; Entry 13 @ $2D50
+    dw AudioCmdSeq_14  ; Entry 14 @ $2D55
+    dw AudioCmdSeq_15  ; Entry 15 @ $2D57
 
 ; ===========================================================================
 ; AudioChannelCommandTable1Alt ($2FF9)

</DiffGit>

Tes réflexions produites dans la production finale. Ces commenentaires ont été coupés.
<ReflexionAgent>

 │ Je vais analyser le nœud à l'adresse $2D57 (Audio command sequence 15, table 1).
│ Parfait ! J'ai trouvé le code. Le label est déjà bien nommé `AudioCmdSeq_15` avec un commentaire de 
│ Parfait ! Le nœud $2D57 est déjà bien documenté et nommé. C'est une séquence de données audio avec 4
│   "summary": "Séquence de commandes audio n°15 : commande $9D répétée avec paramètre $11, terminée p
│ }
│ ```

</ReflexionAgent>

Je veux que tu améliores le [fichier des conseils](../recommendations.md) en y insérant :
- des critiques sur le prompt initial
- des pistes d'améliorations
- les découvertes que tu pourrais faire

Dans ce meme fichier, je souhaite que tu établisses une note de réalisation pour cette étape