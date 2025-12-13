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
;   ld hl, $dfff            ; Fin WRAM
;   ld c, $40               ; 64 blocs
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
;   ld hl, $fffe            ; Fin HRAM
;   ld b, $80               ; 128 octets
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
;   ld c, $b6               ; Destination $FFB6
;   ld b, $0c               ; 12 octets
;   ld hl, $3f7d            ; Source en ROM
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
;   ld a, $80
;   ldh [rLCDC], a          ; LCD ON minimal
;   WAIT_LY $94             ; Attendre VBlank
;   ld a, $03
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
;* Ces macros découpent Jump_000_0185 (init système) en étapes nommées.
;* Le code devient lisible comme une séquence d'appels de fonctions C++.
;*
;* ============================================================================

; -----------------------------------------------------------------------------
; ConfigureInterrupts - Configure et désactive les interruptions
; -----------------------------------------------------------------------------
; Active VBlank + LCD STAT dans IE, clear les pending dans IF, puis DI.
; Les interruptions restent désactivées pendant toute l'init.
MACRO ConfigureInterrupts
    ld a, $03
    di
    ldh [rIF], a
    ldh [rIE], a
ENDM

; -----------------------------------------------------------------------------
; ConfigureLCDStat - Configure le registre STAT pour interruption LYC
; -----------------------------------------------------------------------------
; Bit 6 = LYC interrupt enable. Permet les effets raster mid-screen.
MACRO ConfigureLCDStat
    ld a, $40
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
    ldh [$ffa4], a
ENDM

; -----------------------------------------------------------------------------
; WaitVBlankAndDisableLCD - Attend VBlank puis éteint le LCD
; -----------------------------------------------------------------------------
; POURQUOI : On ne peut éteindre le LCD (LCDC bit 7 = 0) que pendant VBlank,
; sinon on risque d'endommager le hardware. On allume d'abord minimalement
; ($80), on attend la ligne 148 (plein VBlank), puis on éteint ($03).
MACRO WaitVBlankAndDisableLCD
    ld a, $80
    ldh [rLCDC], a
    WAIT_LY $94
    ld a, $03
    ldh [rLCDC], a
ENDM

; -----------------------------------------------------------------------------
; ConfigurePalettes - Initialise les palettes BG et sprites
; -----------------------------------------------------------------------------
; $E4 = %11100100 = couleurs 3,2,1,0 (noir→blanc standard)
; $54 = %01010100 = palette alternative pour sprites (plus claire)
MACRO ConfigurePalettes
    ld a, $e4
    ldh [rBGP], a
    ldh [rOBP0], a
    ld a, $54
    ldh [rOBP1], a
ENDM

; -----------------------------------------------------------------------------
; EnableAudio - Active le système audio avec volume max
; -----------------------------------------------------------------------------
; NR52 = $80 (master ON), NR51 = $FF (tous canaux L+R), NR50 = $77 (vol max)
; Utilise ld [hl-] pour économiser des octets (astuce classique).
MACRO EnableAudio
    ld hl, $ff26
    ld a, $80
    ld [hl-], a
    ld a, $ff
    ld [hl-], a
    ld [hl], $77
ENDM

; -----------------------------------------------------------------------------
; SetupStack - Initialise le stack pointer
; -----------------------------------------------------------------------------
; SP = $CFFF = haut de WRAM bank 0. La pile descend vers $C000.
MACRO SetupStack
    ld sp, $cfff
ENDM

; -----------------------------------------------------------------------------
; ClearWRAM - Efface toute la WRAM (16KB)
; -----------------------------------------------------------------------------
; $C000-$DFFF = 16384 octets = 64 blocs de 256 octets
MACRO ClearWRAM
    xor a
    ld hl, $dfff
    ld c, $40
    ld b, $00
    CLEAR_LOOP_BC
ENDM

; -----------------------------------------------------------------------------
; ClearVRAM - Efface toute la VRAM (8KB)
; -----------------------------------------------------------------------------
; $8000-$9FFF = 8192 octets = 32 blocs de 256 octets
; Note: xor a est APRÈS ld hl/ld c dans l'original (ordre préservé)
MACRO ClearVRAM
    ld hl, $9fff
    ld c, $20
    xor a
    ld b, $00
    CLEAR_LOOP_BC
ENDM

; -----------------------------------------------------------------------------
; ClearOAM - Efface l'OAM et la zone interdite
; -----------------------------------------------------------------------------
; $FE00-$FEFF = 256 octets (OAM = 160, reste = zone interdite)
; Note: A contient déjà 0 du ClearVRAM précédent
MACRO ClearOAM
    ld hl, $feff
    ld b, $00
    CLEAR_LOOP_B
ENDM

; -----------------------------------------------------------------------------
; ClearHRAM - Efface la HRAM
; -----------------------------------------------------------------------------
; $FF80-$FFFE = 128 octets de RAM rapide
MACRO ClearHRAM
    ld hl, $fffe
    ld b, $80
    CLEAR_LOOP_B
ENDM

; -----------------------------------------------------------------------------
; CopyVBlankRoutine - Copie la routine DMA en HRAM
; -----------------------------------------------------------------------------
; POURQUOI : Pendant le DMA OAM, seul HRAM est accessible.
; La routine à $3F7D (12 octets) est copiée vers $FFB6.
MACRO CopyVBlankRoutine
    ld c, $b6
    ld b, $0c
    ld hl, $3f7d
    COPY_TO_HRAM_LOOP
ENDM
