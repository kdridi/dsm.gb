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
