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

; --- Joypad ---
DEF hJoypadState    EQU $FF80   ; État joypad (directions + boutons)
DEF hUnknown81      EQU $FF81   ; Variable HRAM

; --- Flags système ---
DEF hVBlankFlag     EQU $FF85   ; Flag VBlank (0=attente, 1=VBlank reçu)
DEF hUnknown89      EQU $FF89   ; Variable HRAM
DEF hPauseFlag      EQU $FFB2   ; Flag pause (0=normal, 1=pause)

; --- Paramètres de fonction ---
DEF hParam1         EQU $FF8D   ; Paramètre de fonction 1
DEF hParam2         EQU $FF8E   ; Paramètre de fonction 2
DEF hParam3         EQU $FF8F   ; Paramètre de fonction 3
DEF hUnknown90      EQU $FF90   ; Variable HRAM
DEF hUnknown91      EQU $FF91   ; Variable HRAM
DEF hUnknown92      EQU $FF92   ; Variable HRAM
DEF hUnknown93      EQU $FF93   ; Variable HRAM
DEF hUnknown94      EQU $FF94   ; Variable HRAM
DEF hUnknown95      EQU $FF95   ; Variable HRAM
DEF hUnknown96      EQU $FF96   ; Variable HRAM
DEF hUnknown97      EQU $FF97   ; Variable HRAM

; --- Variables temporaires ---
DEF hUnknown9A      EQU $FF9A   ; Variable HRAM (init à 0)
DEF hUnknown9B      EQU $FF9B   ; Variable HRAM
DEF hUnknown9C      EQU $FF9C   ; Variable HRAM
DEF hUnknown9D      EQU $FF9D   ; Variable HRAM
DEF hUnknown9E      EQU $FF9E   ; Variable HRAM
DEF hUnknown9F      EQU $FF9F   ; Flag bloquant mise à jour
DEF hTemp0          EQU $FFA0   ; Variable temporaire 0
DEF hTemp1          EQU $FFA1   ; Variable temporaire 1
DEF hTemp2          EQU $FFA2   ; Variable temporaire 2
DEF hTemp3          EQU $FFA3   ; Variable temporaire 3

; --- Scrolling et affichage ---
DEF hShadowSCX      EQU $FFA4   ; Shadow register SCX (effets raster)
DEF hScrollColumn   EQU $FFE9   ; Colonne courante scrolling tilemap
DEF hScrollPhase    EQU $FFEA   ; Phase mise à jour tilemap (1=active, 2=done)

; --- Timers ---
DEF hTimer1         EQU $FFA6   ; Timer principal (décrémenté par GameLoop)
DEF hTimer2         EQU $FFA7   ; Timer secondaire
DEF hTimerAux       EQU $FF99   ; Timer auxiliaire (jeu)
DEF hUnknownA8      EQU $FFA8   ; Variable HRAM
DEF hUnknownA9      EQU $FFA9   ; Variable HRAM
DEF hUnknownAA      EQU $FFAA   ; Variable HRAM
DEF hUnknownAB      EQU $FFAB   ; Variable HRAM
DEF hFrameCounter   EQU $FFAC   ; Compteur de frames

; --- Sprite temporaire (OAM) ---
DEF hSpriteY        EQU $FFAD   ; Coordonnée Y sprite temporaire
DEF hSpriteX        EQU $FFAE   ; Coordonnée X sprite temporaire
DEF hSpriteTile     EQU $FFAF   ; Tile sprite temporaire
DEF hSpriteAttr     EQU $FFB0   ; Attributs sprite temporaire

; --- État du jeu ---
DEF hUnknownB1      EQU $FFB1   ; Flag de mise à jour score
DEF hGameState      EQU $FFB3   ; État du jeu ($0E initial)
DEF hAnimTileIndex  EQU $FFB4   ; Index animation tiles ($11 initial)
DEF hSubState       EQU $FFB5   ; Sous-état de jeu

; --- DMA ---
DEF hDmaRoutine     EQU $FFB6   ; Début routine DMA copiée en HRAM

; --- Audio (système son) ---
DEF hSoundId        EQU $FFC0   ; ID du son à jouer
DEF hSoundFlag      EQU $FFC1   ; Flag son
DEF hSoundParam1    EQU $FFC2   ; Paramètre son 1
DEF hSoundParam2    EQU $FFC3   ; Paramètre son 2
DEF hSoundCh1       EQU $FFC4   ; Canal son 1
DEF hSoundCh2       EQU $FFC5   ; Canal son 2
DEF hSoundCh3       EQU $FFC6   ; Canal son 3
DEF hSoundCh4       EQU $FFC7   ; Canal son 4
DEF hSoundVar1      EQU $FFC8   ; Variable son 1
DEF hSoundVar2      EQU $FFC9   ; Variable son 2
DEF hSoundVar3      EQU $FFCA   ; Variable son 3
DEF hSoundVar4      EQU $FFCB   ; Variable son 4
DEF hSoundVar5      EQU $FFCC   ; Variable son 5
DEF hUnknownD0      EQU $FFD0   ; Variable HRAM
DEF hUnknownD1      EQU $FFD1   ; Variable HRAM
DEF hUnknownD2      EQU $FFD2   ; Variable audio
DEF hUnknownD3      EQU $FFD3   ; Variable audio
DEF hUnknownD5      EQU $FFD5   ; Variable HRAM
DEF hUnknownD6      EQU $FFD6   ; Variable HRAM
DEF hUnknownD7      EQU $FFD7   ; Variable HRAM
DEF hUnknownD8      EQU $FFD8   ; Variable HRAM
DEF hUnknownD9      EQU $FFD9   ; Variable HRAM
DEF hUnknownDA      EQU $FFDA   ; Variable HRAM
DEF hUnknownDE      EQU $FFDE   ; Variable HRAM
DEF hSavedAudio     EQU $FFDF   ; État audio sauvegardé (pause)

; --- Pointeurs et copie ---
DEF hVramPtrLow     EQU $FFE0   ; Pointeur VRAM (octet bas)
DEF hSavedBank      EQU $FFE1   ; Bank sauvegardée (temporaire)
DEF hCopyDstLow     EQU $FFE2   ; Destination copie (bas)
DEF hCopyDstHigh    EQU $FFE3   ; Destination copie (haut)
DEF hUnknownE4      EQU $FFE4   ; Variable HRAM (init à 0)
DEF hUnknownE5      EQU $FFE5   ; Variable HRAM
DEF hUnknownE6      EQU $FFE6   ; Variable HRAM
DEF hUnknownE7      EQU $FFE7   ; Variable HRAM
DEF hUnknownE8      EQU $FFE8   ; Variable HRAM
DEF hPtrLow         EQU $FFEB   ; Pointeur générique (bas)
DEF hPtrHigh        EQU $FFEC   ; Pointeur générique (haut)
DEF hPtrBank        EQU $FFED   ; Bank du pointeur
DEF hUnknownEE      EQU $FFEE   ; Variable HRAM

; --- Variables diverses ---
DEF hUnknownF0      EQU $FFF0   ; Variable HRAM
DEF hUnknownF1      EQU $FFF1   ; Variable HRAM
DEF hUnknownF2      EQU $FFF2   ; Variable HRAM
DEF hUnknownF3      EQU $FFF3   ; Variable HRAM
DEF hUnknownF4      EQU $FFF4   ; Variable HRAM
DEF hUnknownF5      EQU $FFF5   ; Variable HRAM
DEF hUnknownF8      EQU $FFF8   ; Variable HRAM
DEF hUnknownF9      EQU $FFF9   ; Flag HRAM
DEF hUnknownFA      EQU $FFFA   ; Variable HRAM
DEF hUnknownFB      EQU $FFFB   ; Flag HRAM
DEF hUnknownFC      EQU $FFFC   ; Compteur/flag HRAM
DEF hCurrentBank    EQU $FFFD   ; Bank ROM courante

; === Variables WRAM ($C000-$DFFF) ===
; Convention: wXxxYyy (w minuscule + CamelCase)

DEF wOamBuffer      EQU $C000   ; Buffer OAM pour DMA (160 octets)
DEF wUnknown04      EQU $C004   ; Variable WRAM
DEF wUnknown08      EQU $C008   ; Variable WRAM
DEF wUnknownA0      EQU $C0A0   ; Variable WRAM (score/compteur?)
DEF wUnknownA1      EQU $C0A1   ; Variable WRAM
DEF wScoreBCD       EQU $C0A2   ; Score en BCD (3 octets)
DEF wUpdateCounter  EQU $C0A3   ; Flag mise à jour compteur
DEF wUnknownA4      EQU $C0A4   ; Variable WRAM ($03 initial)
DEF wUnknownA5      EQU $C0A5   ; Variable WRAM
DEF wUnknownA6      EQU $C0A6   ; Variable WRAM
DEF wUnknownA8      EQU $C0A8   ; Variable WRAM ($11 initial)
DEF wUnknownAB      EQU $C0AB   ; Variable WRAM
DEF wUnknownAD      EQU $C0AD   ; Variable WRAM
DEF wScrollBuffer   EQU $C0B0   ; Buffer colonne tilemap (16 octets)
DEF wUnknownC2      EQU $C0C2   ; Variable WRAM (buffer copie?)
DEF wUnknownCE      EQU $C0CE   ; Variable WRAM
DEF wTimerSpecial   EQU $C0D7   ; Timer spécial
DEF wUnknownD8      EQU $C0D8   ; Variable WRAM
DEF wUnknownDC      EQU $C0DC   ; Variable WRAM ($02 initial)
DEF wUnknownDE      EQU $C0DE   ; Variable WRAM
DEF wUnknownDF      EQU $C0DF   ; Variable WRAM
DEF wUnknownE1      EQU $C0E1   ; Variable WRAM (init à 0)
DEF wPlayerData     EQU $C200   ; Données joueur (structure)
DEF wObject1        EQU $C208   ; Slot objet 1
DEF wObject2        EQU $C218   ; Slot objet 2
DEF wObject3        EQU $C228   ; Slot objet 3
DEF wObject4        EQU $C238   ; Slot objet 4
DEF wObject5        EQU $C248   ; Slot objet 5
DEF wAnimBuffer     EQU $C600   ; Buffer animation

; === Variables extended WRAM ($D000-$DFFF) ===

DEF wAnimFlag       EQU $D014   ; Flag animation active
DEF wLevelData      EQU $DA00   ; Données niveau (DA00=type, DA01-02=BCD)
DEF wLivesCounter   EQU $DA15   ; Compteur vies/niveau (BCD)
DEF wSpecialState   EQU $DA1D   ; Trigger état spécial

; === Adresses ROM ===

DEF ROM_DMA_ROUTINE EQU $3F7D   ; Source routine DMA en ROM (12 octets)
DEF ROM_INIT_BANK3  EQU $7FF3   ; Routine d'initialisation en bank 3

; === Valeurs d'initialisation ===

DEF INIT_GAME_STATE     EQU $0E ; État jeu initial (hGameState)
DEF INIT_ANIM_TILE_IDX  EQU $11 ; Valeur initiale hAnimTileIndex et wUnknownA8
DEF INIT_UNKNOWN_DC     EQU $02 ; Valeur initiale wUnknownDC (et bank switch)
DEF INIT_UNKNOWN_A4     EQU $03 ; Valeur initiale wUnknownA4 (et bank switch)
