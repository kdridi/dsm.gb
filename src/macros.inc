;*
;* Macros pour Super Mario Land
;*
;* Ces macros abstraient les patterns répétitifs sans changer le binaire.
;*

; Boucle de clear avec compteur double (b/c)
; Prérequis: HL = adresse fin, C = outer count, B = inner count, A = valeur
MACRO CLEAR_LOOP_BC
.clear\@:
    ld [hl-], a
    dec b
    jr nz, .clear\@
    dec c
    jr nz, .clear\@
ENDM

; Boucle de clear avec compteur simple (b)
; Prérequis: HL = adresse fin, B = count, A = valeur
MACRO CLEAR_LOOP_B
.clear\@:
    ld [hl-], a
    dec b
    jr nz, .clear\@
ENDM

; Boucle de copie ROM vers HRAM
; Prérequis: HL = source, C = dest offset ($FF00+), B = count
MACRO COPY_TO_HRAM_LOOP
.copy\@:
    ld a, [hl+]
    ldh [c], a
    inc c
    dec b
    jr nz, .copy\@
ENDM

; Attente jusqu'à ce que LY atteigne une ligne spécifique
; \1 = numéro de ligne LCD à attendre
MACRO WAIT_LY
.wait\@:
    ldh a, [rLY]
    cp \1
    jr nz, .wait\@
ENDM
