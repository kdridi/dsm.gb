;* ============================================================================
;* CONSTANTS.INC - Constantes spécifiques au projet
;* ============================================================================
;*
;* Ce fichier contient les constantes propres au jeu, en complément de
;* hardware.inc (constantes hardware standard Game Boy).
;*
;* CONVENTIONS DE NOMMAGE :
;*   hXxxYyy     - Variable HRAM ($FF80-$FFFE)
;*   wXxxYyy     - Variable WRAM ($C000-$DFFF)
;*   _XXXX_END   - Adresse de fin de zone mémoire
;*   XXX_YYY     - Constante de configuration
;*   INIT_XXX    - Valeur d'initialisation
;*   ROM_XXX     - Adresse en ROM
;*
;* ============================================================================

; === Adresses de fin des zones mémoire ===
; (Les adresses de début sont dans hardware.inc : _VRAM, _RAM, _OAMRAM, _HRAM)

DEF _VRAM_END       EQU $9FFF   ; Fin VRAM ($8000-$9FFF, 8KB)
DEF _WRAM_END       EQU $DFFF   ; Fin WRAM ($C000-$DFFF, 16KB)
DEF _OAM_END        EQU $FEFF   ; Fin OAM + zone interdite ($FE00-$FEFF)
DEF _HRAM_END       EQU $FFFE   ; Fin HRAM ($FF80-$FFFE, 127 octets)
DEF _STACK_TOP      EQU $CFFF   ; Haut de pile (descend vers $C000)

; === Tailles pour boucles de clear ===
; Note: B=0 signifie 256 en décrémentation sur Game Boy

DEF WRAM_BLOCKS     EQU $40     ; 64 blocs de 256 octets = 16KB
DEF VRAM_BLOCKS     EQU $20     ; 32 blocs de 256 octets = 8KB
DEF HRAM_SIZE       EQU $80     ; 128 octets ($FF80-$FFFE + 1)
DEF DMA_ROUTINE_SIZE EQU $0C    ; 12 octets (routine DMA en HRAM)

; === LCD ===

DEF LY_VBLANK_SAFE  EQU $94     ; Ligne 148, sûre en plein VBlank
                                ; (VBlank = lignes 144-153)

; === Configuration interruptions ===
; (IEF_VBLANK et IEF_STAT sont définis dans hardware.inc)

DEF IE_VBLANK_STAT  EQU IEF_VBLANK | IEF_STAT  ; $03 - VBlank + LCD STAT

; === Palettes ===

DEF PALETTE_STANDARD    EQU $E4 ; %11100100 - noir, gris foncé, gris clair, blanc
DEF PALETTE_SPRITE_ALT  EQU $54 ; %01010100 - palette alternative sprites

; === Audio ===
; (AUDENA_ON est défini dans hardware.inc)

DEF AUDVOL_MAX      EQU $77     ; Volume max gauche ($7) et droite ($7)
DEF AUDTERM_ALL     EQU $FF     ; Tous canaux (1-4) sur sorties L et R

; === Variables HRAM ($FF80-$FFFE) ===
; Convention: hXxxYyy (h minuscule + CamelCase)

DEF hVBlankFlag     EQU $FF85   ; Flag VBlank (0=attente, 1=VBlank reçu)
DEF hUnknown9A      EQU $FF9A   ; Variable HRAM (init à 0)
DEF hUnknown9F      EQU $FF9F   ; Flag bloquant mise à jour
DEF hShadowSCX      EQU $FFA4   ; Shadow register SCX (effets raster)
DEF hFrameCounter   EQU $FFAC   ; Compteur de frames
DEF hPauseFlag      EQU $FFB2   ; Flag pause (0=normal, 1=pause)
DEF hGameState      EQU $FFB3   ; État du jeu ($0E initial)
DEF hUnknownB4      EQU $FFB4   ; Variable HRAM ($11 initial)
DEF hDmaRoutine     EQU $FFB6   ; Début routine DMA copiée en HRAM
DEF hSavedBank      EQU $FFE1   ; Bank sauvegardée (temporaire)
DEF hUnknownE4      EQU $FFE4   ; Variable HRAM (init à 0)
DEF hScrollColumn   EQU $FFE9   ; Colonne courante scrolling tilemap
DEF hScrollPhase    EQU $FFEA   ; Phase mise à jour tilemap (1=active, 2=done)
DEF hCurrentBank    EQU $FFFD   ; Bank ROM courante

; === Variables WRAM ($C000-$DFFF) ===
; Convention: wXxxYyy (w minuscule + CamelCase)

DEF wScoreBCD       EQU $C0A2   ; Score en BCD (3 octets)
DEF wUpdateCounter  EQU $C0A3   ; Flag mise à jour compteur
DEF wUnknownA4      EQU $C0A4   ; Variable WRAM ($03 initial)
DEF wUnknownA8      EQU $C0A8   ; Variable WRAM ($11 initial)
DEF wScrollBuffer   EQU $C0B0   ; Buffer colonne tilemap (16 octets)
DEF wUnknownDC      EQU $C0DC   ; Variable WRAM ($02 initial)
DEF wUnknownE1      EQU $C0E1   ; Variable WRAM (init à 0)
DEF wPlayerData     EQU $C200   ; Données joueur (structure)
DEF wAnimBuffer     EQU $C600   ; Buffer animation

; === Variables extended WRAM ($D000-$DFFF) ===

DEF wLevelData      EQU $DA00   ; Données niveau (DA00=type, DA01-02=BCD)
DEF wAnimFlag       EQU $D014   ; Flag animation active
DEF wLivesCounter   EQU $DA15   ; Compteur vies/niveau (BCD)
DEF wSpecialState   EQU $DA1D   ; Trigger état spécial

; === Adresses ROM ===

DEF ROM_DMA_ROUTINE EQU $3F7D   ; Source routine DMA en ROM (12 octets)
DEF ROM_INIT_BANK3  EQU $7FF3   ; Routine d'initialisation en bank 3

; === Valeurs d'initialisation ===

DEF INIT_GAME_STATE EQU $0E     ; État jeu initial (hGameState)
DEF INIT_UNKNOWN_B4 EQU $11     ; Valeur initiale hUnknownB4 et wUnknownA8
DEF INIT_UNKNOWN_DC EQU $02     ; Valeur initiale wUnknownDC (et bank switch)
DEF INIT_UNKNOWN_A4 EQU $03     ; Valeur initiale wUnknownA4 (et bank switch)
