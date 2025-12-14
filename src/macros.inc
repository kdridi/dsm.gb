;* ============================================================================
;* MACROS.INC - Abstractions pour Super Mario Land
;* ============================================================================
;*
;* POURQUOI CES MACROS ?
;* ---------------------
;* Le code désassemblé contient des patterns répétitifs (boucles de clear,
;* copies mémoire, attentes LCD). Ces patterns sont identiques en structure
;* mais difficiles à lire car noyés dans le flux d'instructions.
;*
;* Les macros RGBASM permettent de :
;* 1. DOCUMENTER l'intention (le nom de la macro dit ce qu'on fait)
;* 2. FACTORISER sans changer le binaire (expansion à l'assemblage)
;* 3. FACILITER la lecture du code d'initialisation
;*
;* GARANTIE : Ces macros génèrent EXACTEMENT le même code machine que
;* l'original. Vérifié par `make verify` (hash identique).
;*
;* CONVENTION : On ne factorise que la BOUCLE, pas le setup des registres.
;* Ainsi l'ordre des instructions de setup reste explicite et le binaire
;* reste identique même si l'ordre original était particulier.
;*
;* ============================================================================

; -----------------------------------------------------------------------------
; CLEAR_LOOP_BC - Boucle de clear mémoire avec compteur double
; -----------------------------------------------------------------------------
; QUOI : Écrit la valeur de A en mémoire, en décrémentant HL, B*C fois.
;
; POURQUOI : Sur Game Boy, effacer de grandes zones mémoire (WRAM 16KB,
; VRAM 8KB) nécessite une boucle imbriquée car un seul registre 8-bit
; ne peut compter que jusqu'à 256. On utilise B (inner) et C (outer).
;
; PRÉREQUIS :
;   HL = adresse de fin (on décrémente vers le bas)
;   C  = nombre de blocs (outer loop)
;   B  = taille de chaque bloc (inner loop, 0 = 256)
;   A  = valeur à écrire (généralement 0 via xor a)
;
; USAGE :
;   xor a                   ; A = 0
;   ld hl, _WRAM_END        ; Fin WRAM
;   ld c, WRAM_BLOCKS       ; 64 blocs
;   ld b, $00               ; de 256 octets = 16KB
;   CLEAR_LOOP_BC
; -----------------------------------------------------------------------------
MACRO CLEAR_LOOP_BC
.clear\@:
    ld [hl-], a
    dec b
    jr nz, .clear\@
    dec c
    jr nz, .clear\@
ENDM

; -----------------------------------------------------------------------------
; CLEAR_LOOP_B - Boucle de clear mémoire avec compteur simple
; -----------------------------------------------------------------------------
; QUOI : Comme CLEAR_LOOP_BC mais pour des zones plus petites (≤256 octets).
;
; POURQUOI : Pour OAM (160 octets) ou HRAM (128 octets), un seul compteur
; suffit. Plus simple et plus rapide que la version double.
;
; PRÉREQUIS :
;   HL = adresse de fin
;   B  = nombre d'octets (0 = 256)
;   A  = valeur à écrire
;
; USAGE :
;   ; A contient déjà 0 du clear précédent
;   ld hl, _HRAM_END        ; Fin HRAM
;   ld b, HRAM_SIZE         ; 128 octets
;   CLEAR_LOOP_B
; -----------------------------------------------------------------------------
MACRO CLEAR_LOOP_B
.clear\@:
    ld [hl-], a
    dec b
    jr nz, .clear\@
ENDM

; -----------------------------------------------------------------------------
; COPY_TO_HRAM_LOOP - Copie depuis ROM vers HRAM
; -----------------------------------------------------------------------------
; QUOI : Copie B octets depuis HL (ROM) vers $FF00+C (HRAM).
;
; POURQUOI : Pendant le DMA OAM (transfert sprites), seul HRAM est accessible.
; On doit donc copier certaines routines critiques (comme le handler DMA)
; en HRAM au démarrage. Cette copie utilise `ldh [c], a` qui est plus
; rapide que `ld [hl], a` pour accéder à la page $FF00.
;
; PRÉREQUIS :
;   HL = adresse source en ROM
;   C  = offset destination dans HRAM ($FF00 + C)
;   B  = nombre d'octets à copier
;
; USAGE :
;   ld c, LOW(hDmaRoutine)  ; Destination $FFB6
;   ld b, DMA_ROUTINE_SIZE  ; 12 octets
;   ld hl, ROM_DMA_ROUTINE  ; Source en ROM
;   COPY_TO_HRAM_LOOP
; -----------------------------------------------------------------------------
MACRO COPY_TO_HRAM_LOOP
.copy\@:
    ld a, [hl+]
    ldh [c], a
    inc c
    dec b
    jr nz, .copy\@
ENDM

; -----------------------------------------------------------------------------
; WAIT_LY - Attente d'une ligne LCD spécifique
; -----------------------------------------------------------------------------
; QUOI : Boucle jusqu'à ce que le registre LY atteigne la valeur spécifiée.
;
; POURQUOI : Le LCD Game Boy ne peut pas être éteint (bit 7 de LCDC) en
; dehors du VBlank sans risquer d'endommager le hardware. On doit donc
; attendre que LY ≥ 144 (VBlank) avant d'éteindre l'écran pour modifier
; la VRAM librement. $94 = 148 est une valeur sûre en plein VBlank.
;
; PARAMÈTRE :
;   \1 = numéro de ligne LCD à attendre (ex: $94 pour VBlank)
;
; USAGE :
;   ld a, LCDCF_ON
;   ldh [rLCDC], a          ; LCD ON minimal
;   WAIT_LY LY_VBLANK_SAFE  ; Attendre VBlank
;   ld a, IE_VBLANK_STAT
;   ldh [rLCDC], a          ; LCD OFF (safe maintenant)
; -----------------------------------------------------------------------------
MACRO WAIT_LY
.wait\@:
    ldh a, [rLY]
    cp \1
    jr nz, .wait\@
ENDM

;* ============================================================================
;* FREE FUNCTIONS - Décomposition algorithmique de SystemInit
;* ============================================================================
;*
;* Ces macros découpent SystemInit (init système) en étapes nommées.
;* Le code devient lisible comme une séquence d'appels de fonctions C++.
;*
;* ============================================================================

; -----------------------------------------------------------------------------
; ConfigureInterrupts - Configure et désactive les interruptions
; -----------------------------------------------------------------------------
; Active VBlank + LCD STAT dans IE, clear les pending dans IF, puis DI.
; Les interruptions restent désactivées pendant toute l'init.
MACRO ConfigureInterrupts
    ld a, IE_VBLANK_STAT
    di
    ldh [rIF], a
    ldh [rIE], a
ENDM

; -----------------------------------------------------------------------------
; ConfigureLCDStat - Configure le registre STAT pour interruption LYC
; -----------------------------------------------------------------------------
; Bit 6 = LYC interrupt enable. Permet les effets raster mid-screen.
MACRO ConfigureLCDStat
    ld a, STATF_LYC
    ldh [rSTAT], a
ENDM

; -----------------------------------------------------------------------------
; ResetScroll - Remet le scroll à zéro
; -----------------------------------------------------------------------------
; SCX, SCY = 0. Aussi le shadow register $FFA4 utilisé pour effets raster.
MACRO ResetScroll
    xor a
    ldh [rSCY], a
    ldh [rSCX], a
    ldh [hShadowSCX], a
ENDM

; -----------------------------------------------------------------------------
; WaitVBlankAndDisableLCD - Attend VBlank puis éteint le LCD
; -----------------------------------------------------------------------------
; POURQUOI : On ne peut éteindre le LCD (LCDC bit 7 = 0) que pendant VBlank,
; sinon on risque d'endommager le hardware. On allume d'abord minimalement
; ($80), on attend la ligne 148 (plein VBlank), puis on éteint ($03).
MACRO WaitVBlankAndDisableLCD
    ld a, LCDCF_ON
    ldh [rLCDC], a
    WAIT_LY LY_VBLANK_SAFE
    ld a, IE_VBLANK_STAT
    ldh [rLCDC], a
ENDM

; -----------------------------------------------------------------------------
; ConfigurePalettes - Initialise les palettes BG et sprites
; -----------------------------------------------------------------------------
; $E4 = %11100100 = couleurs 3,2,1,0 (noir→blanc standard)
; $54 = %01010100 = palette alternative pour sprites (plus claire)
MACRO ConfigurePalettes
    ld a, PALETTE_STANDARD
    ldh [rBGP], a
    ldh [rOBP0], a
    ld a, PALETTE_SPRITE_ALT
    ldh [rOBP1], a
ENDM

; -----------------------------------------------------------------------------
; EnableAudio - Active le système audio avec volume max
; -----------------------------------------------------------------------------
; NR52 = $80 (master ON), NR51 = $FF (tous canaux L+R), NR50 = $77 (vol max)
; Utilise ld [hl-] pour économiser des octets (astuce classique).
MACRO EnableAudio
    ld hl, rNR52
    ld a, AUDENA_ON
    ld [hl-], a
    ld a, AUDTERM_ALL
    ld [hl-], a
    ld [hl], AUDVOL_MAX
ENDM

; -----------------------------------------------------------------------------
; SetupStack - Initialise le stack pointer
; -----------------------------------------------------------------------------
; SP = $CFFF = haut de WRAM bank 0. La pile descend vers $C000.
MACRO SetupStack
    ld sp, _STACK_TOP
ENDM

; -----------------------------------------------------------------------------
; ClearWRAM - Efface toute la WRAM (16KB)
; -----------------------------------------------------------------------------
; $C000-$DFFF = 16384 octets = 64 blocs de 256 octets
MACRO ClearWRAM
    xor a
    ld hl, _WRAM_END
    ld c, WRAM_BLOCKS
    ld b, $00               ; 256 octets par bloc
    CLEAR_LOOP_BC
ENDM

; -----------------------------------------------------------------------------
; ClearVRAM - Efface toute la VRAM (8KB)
; -----------------------------------------------------------------------------
; $8000-$9FFF = 8192 octets = 32 blocs de 256 octets
; Note: xor a est APRÈS ld hl/ld c dans l'original (ordre préservé)
MACRO ClearVRAM
    ld hl, _VRAM_END
    ld c, VRAM_BLOCKS
    xor a
    ld b, $00               ; 256 octets par bloc
    CLEAR_LOOP_BC
ENDM

; -----------------------------------------------------------------------------
; ClearOAM - Efface l'OAM et la zone interdite
; -----------------------------------------------------------------------------
; $FE00-$FEFF = 256 octets (OAM = 160, reste = zone interdite)
; Note: A contient déjà 0 du ClearVRAM précédent
MACRO ClearOAM
    ld hl, _OAM_END
    ld b, $00               ; 256 octets (OAM + zone interdite)
    CLEAR_LOOP_B
ENDM

; -----------------------------------------------------------------------------
; ClearHRAM - Efface la HRAM
; -----------------------------------------------------------------------------
; $FF80-$FFFE = 128 octets de RAM rapide
MACRO ClearHRAM
    ld hl, _HRAM_END
    ld b, HRAM_SIZE
    CLEAR_LOOP_B
ENDM

; -----------------------------------------------------------------------------
; CopyVBlankRoutine - Copie la routine DMA en HRAM
; -----------------------------------------------------------------------------
; POURQUOI : Pendant le DMA OAM, seul HRAM est accessible.
; La routine à $3F7D (12 octets) est copiée vers $FFB6.
MACRO CopyVBlankRoutine
    ld c, LOW(hDmaRoutine)
    ld b, DMA_ROUTINE_SIZE
    ld hl, ROM_DMA_ROUTINE
    COPY_TO_HRAM_LOOP
ENDM

; -----------------------------------------------------------------------------
; InitGameVariables - Initialise les variables de jeu
; -----------------------------------------------------------------------------
; Configure les variables HRAM/WRAM initiales et fait le premier bank switch.
; $FFE4 = 0, $FFB4 = $11, $C0A8 = $11, $C0DC = $02
; $FFB3 = $0E (game_state), $C0A4 = $03, $C0E1 = 0, $FF9A = 0
; Appelle la routine d'init en bank 3, puis switch vers bank 2.
MACRO InitGameVariables
    xor a
    ldh [hRenderContext], a
    ld a, INIT_ANIM_TILE_IDX
    ldh [hAnimTileIndex], a
    ld [wAnimTileIdx], a
    ld a, INIT_UNKNOWN_DC
    ld [wCurrentROMBank], a
    ld a, INIT_GAME_STATE
    ldh [hGameState], a
    ld a, INIT_UNKNOWN_A4
    ld [rROMB0], a
    ld [wROMBankInit], a
    ld a, $00
    ld [wLevelType], a
    ldh [hLevelIndex], a
    call ROM_INIT_BANK3
    ld a, INIT_UNKNOWN_DC
    ld [rROMB0], a
    ldh [hCurrentBank], a
ENDM

; -----------------------------------------------------------------------------
; WaitForNextFrame - Attend le prochain VBlank
; -----------------------------------------------------------------------------
; HALT économise la batterie en suspendant le CPU jusqu'à interruption.
; Le VBlank handler met $FF85 à 1, on le remet à 0 et on continue.
MACRO WaitForNextFrame
.wait\@:
    halt
    ldh a, [hVBlankFlag]
    and a
    jr z, .wait\@
    xor a
    ldh [hVBlankFlag], a
ENDM

;* ============================================================================
;* GUARD CLAUSES - Macros de contrôle de flux basées sur hUpdateLockFlag
;* ============================================================================
;*
;* Ces macros encapsulent les patterns récurrents de vérification du flag
;* de verrouillage des mises à jour graphiques (hUpdateLockFlag).
;*
;* ============================================================================

; -----------------------------------------------------------------------------
; ReturnIfLocked - Quitte la fonction si les updates sont verrouillées
; -----------------------------------------------------------------------------
; QUOI : Guard clause qui fait un early return si hUpdateLockFlag != 0
; USAGE : En début de fonction pour éviter les updates graphiques pendant
;         certaines phases critiques (transitions, etc.)
MACRO ReturnIfLocked
    ldh a, [hUpdateLockFlag]
    and a
    ret nz
ENDM

; -----------------------------------------------------------------------------
; JumpIfLocked - Saute vers un label si les updates sont verrouillées
; -----------------------------------------------------------------------------
; QUOI : Branch conditionnel vers \1 si hUpdateLockFlag != 0
; PARAMÈTRE : \1 = label de destination
MACRO JumpIfLocked
    ldh a, [hUpdateLockFlag]
    and a
    jr nz, \1
ENDM

; -----------------------------------------------------------------------------
; ReturnIfUnlocked - Quitte la fonction si les updates sont déverrouillées
; -----------------------------------------------------------------------------
; QUOI : Guard clause inverse - early return si hUpdateLockFlag == 0
; USAGE : Pour du code qui ne doit s'exécuter QUE pendant le verrouillage
MACRO ReturnIfUnlocked
    ldh a, [hUpdateLockFlag]
    and a
    ret z
ENDM

; -----------------------------------------------------------------------------
; JumpIfUnlocked - Saute vers un label si les updates sont déverrouillées
; -----------------------------------------------------------------------------
; QUOI : Branch conditionnel vers \1 si hUpdateLockFlag == 0
; PARAMÈTRE : \1 = label de destination
MACRO JumpIfUnlocked
    ldh a, [hUpdateLockFlag]
    and a
    jr z, \1
ENDM
