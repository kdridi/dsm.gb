;; ============================================================================
;; ROM Bank 0 - Vecteurs RST et Interruptions ($0000-$00FF)
;; ============================================================================
SECTION "ROM Bank $000", ROM0[$0]

;; --- RST $00 : Soft Reset ---
RST_00::
    jp SystemInit

    ; Padding jusqu'à RST $08
    rst $38
    rst $38
    rst $38
    nop
    nop

;; --- RST $08 : Soft Reset (alias) ---
RST_08::
    jp SystemInit

    ; Padding jusqu'à RST $10
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

;; --- RST $10-$20 : Non utilisés ---
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

Jump_000_0024::
    rst $38
    rst $38
    rst $38
    rst $38

;; ============================================================================
;; RST $28 : Jump Table Dispatcher
;; ============================================================================
;; Usage : rst $28 suivi immédiatement d'une table de mots (dw addr1, addr2...)
;; Entrée : A = index dans la table (0, 1, 2...)
;; Effet  : Saute vers l'adresse à table[A]
;;
;; Exemple :
;;   ld a, [hGameState]
;;   rst $28
;;   dw State0Handler, State1Handler, State2Handler
;; ============================================================================
RST_28::
    add a               ; A = A * 2 (car chaque entrée = 2 octets)
    pop hl              ; HL = adresse de retour (= début de la table)
    ld e, a
    ld d, $00           ; DE = offset
    add hl, de          ; HL = table + offset
    ld e, [hl]          ; E = octet bas de l'adresse
    inc hl
    ; Suite dans RST $30...

;; --- RST $30 : Suite du dispatcher ---
RST_30::
    ld d, [hl]          ; D = octet haut de l'adresse
    push de
    pop hl              ; HL = adresse cible
    jp hl               ; Saut vers le handler

    ; Padding jusqu'à RST $38
    rst $38
    rst $38
    rst $38
    rst $38

;; --- RST $38 : Non utilisé (trap) ---
RST_38::
    rst $38             ; Boucle infinie si appelé par erreur
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

;; ==========================================================================
;; Interrupt Vectors ($0040-$0068)
;; ==========================================================================
;; Le Game Boy a 5 vecteurs d'interruption fixes. Chaque vecteur a 8 bytes.
;; On utilise un JP pour sauter vers le handler réel (car 8 bytes = trop court).
;; ==========================================================================

;; --- INT $40 : VBlank Interrupt ---
;; Déclenché quand LY atteint 144 (fin de l'affichage visible).
;; C'est la seule période où on peut écrire en VRAM/OAM en toute sécurité.
VBlankInterrupt::
    jp VBlankHandler

    ; Padding jusqu'à $0048
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

;; --- INT $48 : LCD STAT Interrupt ---
;; Déclenché selon les conditions configurées dans STAT (LYC=LY, mode 0/1/2).
;; Utilisé ici pour les effets de scanline (scroll, window).
LCDCInterrupt::
    jp LCDStatHandler

    ; Padding jusqu'à $0050
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

;; --- INT $50 : Timer Overflow Interrupt ---
;; Déclenché quand TIMA overflow. Utilisé ici pour le son (bank 3).
;; Note: L'interruption Serial ($0058) tombe au milieu du call $7ff0.
;; Ce n'est pas un vrai handler - le jeu n'utilise pas le port série.
TimerOverflowInterrupt::
    push af
    ld a, BANK_AUDIO         ; Bank 3 = audio
    ld [rROMB0], a           ; Switch to audio bank
    call $7ff0               ; Routine audio en bank 3
    ldh a, [hCurrentBank]    ; Restaurer bank courante
    ld [rROMB0], a
    pop af
    reti


;; ==========================================================================
;; VBlankHandler - Handler principal VBlank ($0060)
;; ==========================================================================
;; Appelé 60 fois par seconde pendant le VBlank.
;; Structure :
;;   1. SaveRegisters      → push af/bc/de/hl
;;   2. UpdateGameLogic    → Scroll, vies, score, animations
;;   3. DMATransfer        → call $FFB6 (copie OAM depuis wShadowOAM)
;;   4. IncrementFrame     → hFrameCounter++
;;   5. CheckWindowEnable  → Active Window si game_state == $3A
;;   6. ResetScrollAndFlag → SCX/SCY = 0, hVBlankFlag = 1
;;   7. RestoreRegisters   → pop + reti
;; ==========================================================================
VBlankHandler::
    ; --- 1. SaveRegisters ---
    push af
    push bc
    push de
    push hl

    ; --- 2. UpdateGameLogic ---
    call UpdateScrollColumn
    call ProcessBlockCollision
    call UpdateLivesDisplay

    ; --- 3. DMATransfer ---
    call $ffb6              ; Routine OAM DMA copiée en HRAM

    ; --- UpdateGameLogic (suite) ---
    call UpdateScoreDisplay
    call UpdateLevelScore
    call UpdateAnimTiles

    ; --- 4. IncrementFrame ---
    ld hl, hFrameCounter
    inc [hl]                ; frame_counter++

    ; --- 5. CheckWindowEnable ---
CheckWindowEnable:
    ldh a, [hGameState]          ; Lire game_state
    cp $3a                  ; État spécial $3A ?
    jr nz, .resetScrollAndFlag   ; Non → sauter

    ld hl, $ff40            ; rLCDC
    set 5, [hl]             ; Activer le Window (bit 5)

    ; --- 6. ResetScrollAndFlag ---
.resetScrollAndFlag:
    xor a
    ldh [rSCX], a           ; Scroll X = 0
    ldh [rSCY], a           ; Scroll Y = 0
    inc a                   ; A = 1
    ldh [hVBlankFlag], a          ; frame_ready = 1 → réveille la game loop

    ; --- 7. RestoreRegisters ---
    pop hl
    pop de
    pop bc
    pop af
    reti                    ; Retour d'interruption


;; ==========================================================================
;; LCDStatHandler - Handler LCD STAT Interrupt ($0095)
;; ==========================================================================
;; Déclenché par LYC=LY. Gère les effets de scanline :
;;   - Scroll mid-screen (hShadowSCX/wLevelInitFlag)
;;   - Animation window (état $3A = écran spécial window)
;;
;; Modes (wGameConfigA5) :
;;   0 = Mode normal : applique scroll, gère window
;;   !=0 = Mode retour : désactive window, reset LYC
;;
;; Points d'entrée publics (utilisés par bank 2/3) :
;;   LCDStat_CheckCarryExit : Vérifie carry et saute à exit si >= $87
;;   LCDStat_SetLYC : Écrit A dans rLYC et wGameConfigA5
;;   LCDStat_PopAndReti : Pop af + reti
;; ==========================================================================
LCDStatHandler:
    push af
    push hl

    ; Attendre Mode 0 (HBlank) avant de toucher aux registres
LCDStatHandler_WaitMode0:
    ldh a, [rSTAT]
    and STATF_LCD               ; Bits 0-1 = mode LCD
    jr nz, LCDStatHandler_WaitMode0 ; Boucle tant que != Mode 0

    ; Vérifier le mode du handler
    ld a, [wGameConfigA5]
    and a
    jr nz, LCDStatHandler_RestoreMode ; Si !=0 → mode retour

    ; --- Mode normal : appliquer scroll ---
    ldh a, [hShadowSCX]
    ldh [rSCX], a               ; Scroll X = shadow

    ld a, [wAudioSaveDE]        ; Flag scroll Y actif ?
    and a
    jr z, LCDStatHandler_CheckWindow

    ld a, [wLevelInitFlag]      ; Si oui, appliquer scroll Y
    ldh [rSCY], a

LCDStatHandler_CheckWindow:
    ; Vérifier si état $3A (écran spécial window)
    ldh a, [hGameState]
    cp GAME_STATE_WINDOW        ; $3A
    jr nz, LCDStatHandler_Exit

    ; --- Animation window (état $3A) ---
    ld hl, rWY                  ; $FF4A = Window Y position
    ld a, [hl]
    cp $40                      ; WY == $40 ?
    jr z, LCDStatHandler_WindowDone ; Oui → animation terminée

    dec [hl]                    ; Sinon décrémenter WY
    cp $87                      ; A >= $87 ?

;; Point d'entrée public : vérifie carry flag et exit si >= $87
LCDStat_CheckCarryExit:
    jr nc, LCDStatHandler_Exit  ; Oui → ne pas changer LYC

LCDStatHandler_UpdateLYC:
    add $08                     ; Prochaine ligne LYC

;; Point d'entrée public : écrit A dans rLYC et wGameConfigA5
LCDStat_SetLYC:
    ldh [rLYC], a               ; Programmer prochaine interruption
    ld [wGameConfigA5], a       ; Mémoriser pour mode retour

LCDStatHandler_Exit:
    pop hl

;; Point d'entrée public : pop af + reti
LCDStat_PopAndReti:
    pop af
    reti


LCDStatHandler_RestoreMode:
    ; --- Mode retour : désactiver window ---
    ld hl, rLCDC                ; $FF40
    res 5, [hl]                 ; Désactiver Window (bit 5)
    ld a, $0f
    ldh [rLYC], a               ; LYC = 15 (haut écran)
    xor a
    ld [wGameConfigA5], a       ; Repasser en mode normal
    jr LCDStatHandler_Exit

LCDStatHandler_WindowDone:
    ; WY a atteint $40 : ajuster animation sprites
    push af
    ldh a, [hOAMIndex]
    and a
    jr z, LCDStatHandler_OAMDone

    dec a
    ldh [hOAMIndex], a

LCDStatHandler_OAMContinue:
    pop af
    jr LCDStatHandler_UpdateLYC

LCDStatHandler_OAMDone:
    ld a, $ff
    ld [wPlayerVarAD], a        ; Flag animation terminée
    jr LCDStatHandler_OAMContinue

    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

;; ==========================================================================
;; Entry Point ($0100-$0103)
;; ==========================================================================
;; Le bootstrap du Game Boy termine à $0100. C'est là que l'exécution
;; commence après le boot screen Nintendo. La convention est :
;;   $0100: nop
;;   $0101-$0103: jp <init>
;; Le nop laisse la place pour un éventuel di avant le jump.
;; ==========================================================================
Boot::
    nop
    jp AfterHeader


;; ==========================================================================
;; ROM Header ($0104-$014F)
;; ==========================================================================
;; Structure fixe imposée par Nintendo, vérifiée par le bootstrap.
;; Le header contient le logo Nintendo (obligatoire pour boot), le titre,
;; et les métadonnées de la cartouche.
;; ==========================================================================

;; Logo Nintendo ($0104-$0133) - Obligatoire, vérifié au boot
HeaderLogo::
    db $ce, $ed, $66, $66, $cc, $0d, $00, $0b, $03, $73, $00, $83, $00, $0c, $00, $0d
    db $00, $08, $11, $1f, $88, $89, $00, $0e, $dc, $cc, $6e, $e6, $dd, $dd, $d9, $99
    db $bb, $bb, $67, $63, $6e, $0e, $ec, $cc, $dd, $dc, $99, $9f, $bb, $b9, $33, $3e

;; Titre du jeu ($0134-$0143) - 16 caractères max, padding avec $00
HeaderTitle::
    db "SUPER MARIOLAND", $00

;; Code éditeur nouveau format ($0144-$0145) - Non utilisé ici
HeaderNewLicenseeCode::
    db $00, $00

;; Flag Super Game Boy ($0146) - $00 = pas de fonctions SGB
HeaderSGBFlag::
    db $00

;; Type cartouche ($0147) - $01 = ROM + MBC1
HeaderCartridgeType::
    db $01

;; Taille ROM ($0148) - $01 = 64 KB (4 banks × 16 KB)
HeaderROMSize::
    db $01

;; Taille RAM ($0149) - $00 = pas de RAM externe
HeaderRAMSize::
    db $00

;; Code destination ($014A) - $00 = Japon
HeaderDestinationCode::
    db $00

;; Code éditeur ancien format ($014B) - $01 = Nintendo
HeaderOldLicenseeCode::
    db $01

;; Version ROM ($014C) - $00 = version 1.0
HeaderMaskROMVersion::
    db $00

;; Checksum header ($014D) - Vérifié au boot
HeaderComplementCheck::
    db $9e

;; Checksum global ($014E-$014F) - Non vérifié
HeaderGlobalChecksum::
    db $41, $6b

;; ==========================================================================
;; After Header ($0150)
;; ==========================================================================
;; Premier code exécutable après le header. Saute vers l'initialisation.
;; ==========================================================================
AfterHeader:
    jp SystemInit


; -----------------------------------------------------------------------------
; ReadTileUnderSprite - Lit le tile BG sous le sprite de manière sûre
; -----------------------------------------------------------------------------
; Entrées : hSpriteY, hSpriteX (coordonnées OAM en pixels)
; Sortie  : A = numéro du tile BG sous le sprite
; Note    : Double lecture + AND pour filtrer les erreurs VRAM
; -----------------------------------------------------------------------------
ReadTileUnderSprite:
    call GetTileAddrFromSprite

    WAIT_FOR_HBLANK
    ld b, [hl]

    WAIT_FOR_HBLANK
    ld a, [hl]
    and b
    ret


AddScore:
    ReturnIfLocked

    ld a, e
    ld hl, wScoreBCDHigh
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
    ldh [hScoreNeedsUpdate], a
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
SystemInit:
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
;;   1. CheckSpecialState  → Vérifie wSpecialState == 3 (reset ?)
;;   2. CallBank3Logic     → Appelle la logique en bank 3
;;   3. CheckPauseOrSkip   → Vérifie si on doit sauter le frame
;;   4. DecrementTimers    → Décrémente 2 timers (hTimer1, hTimer2)
;;   5. HandleAttractMode  → Gestion de l'Attract Mode (voir ci-dessous)
;;   6. CallStateHandler   → Appelle le handler d'état (StateDispatcher)
;;   7. WaitForNextFrame   → HALT + attend flag VBlank
;;
;; --------------------------------------------------------------------------
;; ATTRACT MODE (étape 5)
;; --------------------------------------------------------------------------
;; Pattern classique Nintendo : écran titre → timeout → démo auto → boucle
;;
;;   ┌─────────────────────────────────────────────────────────┐
;;   │                                                         │
;;   │  ┌───────────────────┐  timeout   ┌──────────────────┐  │
;;   │  │   Écran titre     │ ────────→  │   Démo auto      │  │
;;   │  │ (GAME_STATE_TITLE)│            │ (GAME_STATE_DEMO)│  │
;;   │  └───────────────────┘            └──────────────────┘  │
;;   │           ↑                              │              │
;;   │           │       timeout / fin démo     │              │
;;   │           └──────────────────────────────┘              │
;;   │           │                                             │
;;   │           │ Start pressé                                │
;;   │           ↓                                             │
;;   │  ┌──────────────────┐                                   │
;;   │  │  Démarrer le jeu │                                   │
;;   │  └──────────────────┘                                   │
;;   └─────────────────────────────────────────────────────────┘
;;
;; Mécanisme :
;;   - wAttractModeTimer : compteur décrémenté toutes les 16 frames
;;   - Quand timer = 0 ET hGameState = GAME_STATE_TITLE ($00)
;;     → Switch vers bank 2, hGameState = GAME_STATE_DEMO ($0E)
;;   - Start pressé : bypass le timer (déclenchement immédiat)
;;
;; Timing : ~256 × 16 frames ÷ 60fps ≈ 68 secondes avant démo
;; ==========================================================================

; --- 1. CheckSpecialState ---
GameLoop:
    CheckSpecialStateAndReset .callBank3Logic

; --- 2. CallBank3Logic ---
.callBank3Logic:
    CallBank3Routine ROM_BANK3_MAIN_LOGIC

; --- 3. CheckPauseOrSkip ---
    CheckPauseAndSkip .decrementTimers, .waitVBlank

; --- 4. DecrementTimers ---
.decrementTimers:
    ld hl, hTimer1
    ld b, GAMELOOP_TIMER_COUNT
    DECREMENT_TIMERS_LOOP

; --- 5. HandleAttractMode ---
    CheckAttractModeTimer .callStateHandler, .triggerAttractDemo

.triggerAttractDemo:
    TriggerAttractDemoIfOnTitle .callStateHandler

; --- 6. CallStateHandler ---
.callStateHandler:
    call StateDispatcher

; --- 7. WaitForNextFrame ---
.waitVBlank:
    WaitForNextFrame
    jr GameLoop

DeadLoop:
    jr DeadLoop

;; ==========================================================================
;; StateDispatcher - Dispatch vers le handler selon game_state ($FFB3)
;; ==========================================================================
;; Appelé par : GameLoop (CallStateHandler)
;; Mécanisme  : rst $28 = jump table indirect
;;   - Lit A (game_state)
;;   - A *= 2 (chaque entrée = 2 octets)
;;   - Saute à l'adresse dans la table
;;
;; NOTE: Le code après "rst $28" est une TABLE DE POINTEURS mal désassemblée.
;; Les "db", "ld b, $xx", etc. sont en fait des adresses 16-bit.
;; Ne pas modifier ce code sans comprendre la structure de la table !
;;
;; === JUMP TABLE DÉCODÉE (60 états, $00-$3B) ===
;;
;; | État | Adresse | Description (hypothèse)          |
;; |------|---------|-----------------------------------|
;; | $00  | $0610   | ?                                 |
;; | $01  | $06A5   | ?                                 |
;; | $02  | $06C5   | ?                                 |
;; | $03  | $0B84   | InitGameState cible               |
;; | $04  | $0BCD   | ?                                 |
;; | $05  | $0C6A   | ?                                 |
;; | $06  | $0CC2   | ?                                 |
;; | $07  | $0C37   | ?                                 |
;; | $08  | $0D40   | ?                                 |
;; | $09  | $1612   | ?                                 |
;; | $0A  | $1626   | ?                                 |
;; | $0B  | $1663   | ?                                 |
;; | $0C  | $16D1   | ?                                 |
;; | $0D  | $236D   | ?                                 |
;; | $0E  | $0322   | État initial (INIT_GAME_STATE)    |
;; | $0F  | $04C3   | ?                                 |
;; | $10  | $05B7   | ?                                 |
;; | $11  | $055F   | ?                                 |
;; | $12  | $3D8E   | Écran fin (UpdateLevelScore skip) |
;; | $13  | $3DCE   | ?                                 |
;; | $14  | $5832   | (bank switch requis)              |
;; | ...  | ...     | (voir bytes à $02A5)              |
;; | $39  | $????   | Game over (depuis UpdateLives)    |
;; | $3A  | $????   | État spécial window               |
;;
;; ==========================================================================
StateDispatcher:
    ldh a, [hGameState]          ; Lire game_state (0-N)
    rst $28                 ; → Jump table dispatcher (voir RST_28)
; === StateDispatcher Jump Table (60 états) ===
; Index = hGameState (0-59), chaque entrée = adresse handler
StateJumpTable:
    dw StateHandler_00  ; État $00 - Init/main gameplay
    dw StateHandler_01  ; État $01 - Reset objets
    dw StateHandler_02  ; État $02 - Préparation rendu
    dw StateHandler_03  ; État $03 - Setup sprites transition
    dw StateHandler_04  ; État $04 - Animation transition
    dw StateHandler_05  ; État $05 - Niveau spécial gestion
    dw StateHandler_06  ; État $06 - Transition post-niveau
    dw StateHandler_07  ; État $07 - Attente + bank 3
    dw StateHandler_08  ; État $08 - Progression monde/niveau
    dw State09_PipeEnterRight  ; État $09 - Entrée tuyau droite
    dw State0A_LoadSubLevel    ; État $0A - Chargement sous-niveau
    dw State0B_PipeEnterDown   ; État $0B - Descente tuyau
    dw State0C_PipeExitLeft    ; État $0C - Sortie tuyau gauche
    dw State0D_GameplayFull    ; État $0D - Gameplay avec objets
    dw State0E_LevelInit       ; État $0E - Init niveau + HUD
    dw State0F_LevelSelect     ; État $0F - Menu sélection
    dw State10_Noop            ; État $10 - Vide (placeholder)
    dw State11_LevelStart      ; État $11 - Démarrage niveau
    dw $3d8e    ; État $12 - State12_EndLevelSetup
    dw $3dce    ; État $13 - State13_DrawEndBorder
    dw $5832    ; État $14 - (Bank 1, zone données)
    dw $5835    ; État $15 - (Bank 1, zone données)
    dw $3e9e    ; État $16 - State16_CopyTilemapData
    dw $5838    ; État $17 - (Bank 1, zone données)
    dw $583b    ; État $18 - (Bank 1, zone données)
    dw $583e    ; État $19 - (Bank 1, zone données)
    dw $5841    ; État $1A - (Bank 1, zone données)
    dw $0df0    ; État $1B - State1B_BonusComplete
    dw $0e0c    ; État $1C - State1C_WaitTimerGameplay
    dw $0e28    ; État $1D - State1D_SetupVRAMPointer
    dw $0e54    ; État $1E - State1E_ClearTilemapColumn
    dw $0e8d    ; État $1F - State1F_EnableVBlankMode
    dw $0ea0    ; État $20 - State20_WaitPlayerPosition
    dw $0ec4    ; État $21 - State21_SetupEndCutscene
    dw $0f09    ; État $22 - State22_ScrollCutscene
    dw $0f2a    ; État $23 - State23_WalkToDoor
    dw $0f61    ; État $24 - State24_DisplayText
    dw $0ff4    ; État $25 - State25_SpriteBlinkAnimation
    dw $104c    ; État $26 - State26_PrincessRising
    dw $1090    ; État $27 - State27_PlayerOscillation
    dw $0ea0    ; État $28 - (= État $20)
    dw $110d    ; État $29
    dw $115c    ; État $2A
    dw $118b    ; État $2B
    dw $11c7    ; État $2C
    dw $1212    ; État $2D
    dw $124b    ; État $2E
    dw $1298    ; État $2F
    dw $12b9    ; État $30
    dw $12e8    ; État $31
    dw $1385    ; État $32
    dw $13e7    ; État $33
    dw $1438    ; État $34
    dw $1451    ; État $35
    dw $145d    ; État $36
    dw $147f    ; État $37
    dw $14d3    ; État $38
    dw $1c73    ; État $39
    dw $1cdf    ; État $3A
    dw $1ce7    ; État $3B

; === Données non référencées ($031E-$0321) ===
; Peut-être du padding ou des données obsolètes
    db $14, $1d, $a4, $06

; ===========================================================================
; État $0E - Initialisation niveau (chargement tiles et HUD)
; LCD off → charge tiles VRAM → configure HUD → LCD on → état $0F
; ===========================================================================
State0E_LevelInit::
    xor a                   ; A = 0 ($AF)
    ldh [rLCDC], a          ; Désactiver LCD
    di
    ldh [hShadowSCX], a
    ld hl, wOamBuffer
    ld b, $9f

ClearOamLoop:
    ld [hl+], a
    dec b
    jr nz, ClearOamLoop

    ldh [hTimerAux], a
    ld [wGameConfigA5], a
    ld [wPlayerVarAD], a
    ld hl, wLevelVarD8
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld a, [wLevelType]
    ldh [hLevelIndex], a
    ld hl, $791a
    ld de, $9300
    ld bc, $0500
    call MemCopy
    ld hl, $7e1a
    ld de, $8800
    ld bc, $0170
    call MemCopy
    ld hl, $4862
    ldh a, [hLevelIndex]
    cp $01
    jr c, SelectLevelAudioTable

    ld hl, $4e72

SelectLevelAudioTable:
    ld de, $8ac0
    ld bc, $0010
    call MemCopy
    ld hl, $5032
    ld de, $9000
    ld bc, $02c0
    call MemCopy
    ld hl, $5032
    ld de, $8000
    ld bc, $02a0
    call MemCopy
    call ClearBGTilemap
    xor a
    ldh [hTilemapScrollX], a
    ldh a, [hRenderContext]
    push af
    ld a, $0c
    ldh [hRenderContext], a
    call LoadLevelData
    pop af
    ldh [hRenderContext], a
    ld a, $3c
    ld hl, $9800
    call FillTilemapRow
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
    ld hl, wScoreBCD
    ld de, wScorePrevious
    ld b, $03

CompareBCDScoresLoop:
    ld a, [de]
    sub [hl]
    jr c, CopyScoreBCD

    jr nz, CompareBCDScoresToDisplay

    dec e
    dec l
    dec b
    jr nz, CompareBCDScoresLoop

    jr CompareBCDScoresToDisplay

CopyScoreBCD:
    ld hl, wScoreBCD
    ld de, wScorePrevious
    ld b, $03

CopyScoreBCDPreviousLoop:
    ld a, [hl-]
    ld [de], a
    dec e
    dec b
    jr nz, CopyScoreBCDPreviousLoop

CompareBCDScoresToDisplay:
    ld de, wScorePrevious
    ld hl, $9969
    call ConvertBCDToTiles
    ld hl, wUnknown04
    ld [hl], $78
    ld a, [wGameConfigA6]
    and a
    jr z, FinalizeGameStateAfterScore

    ldh a, [hLevelIndex]
    cp $02
    jr c, DisplaySpritesForLowLevel

    jr FinalizeGameStateAfterScore

DisplaySpritesForLowLevel:
    ld hl, $0446
    ld de, $99c6
    ld b, $0a

CopySpriteDataLoop:
    ld a, [hl+]
    ld [de], a
    inc e
    dec b
    jr nz, CopySpriteDataLoop

    ld hl, wOamBuffer
    ld [hl], $80
    inc l
    ld [hl], $88
    inc l
    ld a, [wGameConfigA6]
    ld [hl], a
    inc l
    ld [hl], $00
    inc l
    ld [hl], $80

FinalizeGameStateAfterScore:
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
    ldh [hGameState], a
    xor a
    ldh [hVBlankMode], a
    ld a, $28
    ld [wAttractModeTimer], a
    ldh [hUpdateLockFlag], a
    ld hl, wCurrentROMBank
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

StartSelectedLevel:
    ld a, [wUnknown04]
    cp $78
    jr z, ResetRenderForHighLevels

    ld a, [wGameConfigA6]
    dec a
    ld [wGameConfigA6], a
    ld a, [wAnimTileIdx]
    ldh [hAnimTileIndex], a
    ld e, $00
    cp $11
    jr z, SelectTileIndexForLevel

    inc e
    cp $12
    jr z, SelectTileIndexForLevel

    inc e
    cp $13
    jr z, SelectTileIndexForLevel

    inc e
    cp $21
    jr z, SelectTileIndexForLevel

    inc e
    cp $22
    jr z, SelectTileIndexForLevel

    inc e
    cp $23
    jr z, SelectTileIndexForLevel

    inc e
    cp $31
    jr z, SelectTileIndexForLevel

    inc e
    cp $32
    jr z, SelectTileIndexForLevel

    inc e
    cp $33
    jr z, SelectTileIndexForLevel

    inc e
    cp $41
    jr z, SelectTileIndexForLevel

    inc e
    cp $42
    jr z, SelectTileIndexForLevel

    inc e

SelectTileIndexForLevel:
    ld a, e

ApplyRenderContext:
    ldh [hRenderContext], a
    jp Jump_000_053d


ResetRenderForHighLevels:
    xor a
    ld [wGameConfigA6], a
    ldh a, [hLevelIndex]
    cp $02
    jp nc, Jump_000_053d

    ld a, $11
    ldh [hAnimTileIndex], a
    xor a
    jr ApplyRenderContext

HandleSelectButtonLevelSelect:
    ld a, [wGameConfigA6]
    and a
    jr z, UpdateLevelSelectDisplay

    ld hl, wUnknown04
    ld a, [hl]
    xor $f8
    ld [hl], a
    jr UpdateLevelSelectDisplay

; ===========================================================================
; État $0F - Menu/Écran sélection niveau
; Gère la navigation avec le joypad, affiche les indices de niveau
; Attend timer ou action → état $11
; ===========================================================================
State0F_LevelSelect::
    ldh a, [$ff81]               ; Joypad state
    ld b, a
    bit 3, b                     ; Start pressé ?
    jr nz, StartSelectedLevel

    bit 2, b                     ; Select pressé ?
    jr nz, HandleSelectButtonLevelSelect

UpdateLevelSelectDisplay:
    ldh a, [hLevelIndex]
    cp $02
    jr c, InitAttractModeDisplay

    bit 0, b
    jr z, AnimRenderContextReady

    ldh a, [hAnimTileIndex]
    inc a
    ld b, a
    and $0f
    cp $04
    ld a, b
    jr nz, SkipAnimTileAdd

    add $0d

SkipAnimTileAdd:
    ldh [hAnimTileIndex], a
    ldh a, [hRenderContext]
    inc a
    cp $0c
    jr nz, AnimRenderContextUpdateDone

    ld a, $11
    ldh [hAnimTileIndex], a
    xor a

AnimRenderContextUpdateDone:
    ldh [hRenderContext], a

AnimRenderContextReady:
    ld hl, wUnknown08
    ldh a, [hAnimTileIndex]
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

InitAttractModeDisplay:
    ld a, [wAttractModeTimer]

Jump_000_051c:
    and a
    ret nz

    ld a, [wCurrentROMBank]
    sla a
    ld e, a
    ld d, $00
    ld hl, $0552
    add hl, de
    ld a, [hl+]
    ldh [hAnimTileIndex], a
    ld a, [hl]
    ldh [hRenderContext], a

Jump_000_0530:
    ld a, $50
    ld [wAttractModeTimer], a
    ld a, $11
    ldh [hGameState], a
    xor a
    ldh [hLevelIndex], a
    ret


Jump_000_053d:
    ld a, $11
    ldh [hGameState], a
    xor a
    ldh [rIF], a
    ldh [hUpdateLockFlag], a
    ld [wROMBankInit], a
    dec a
    ld [wStateRender], a
    ld a, $07
    ldh [rIE], a
    ret


    ld de, $1200
    ld bc, $0833

; =============================================================================
; FillTilemapRow - Remplit une ligne de tilemap avec un tile
; =============================================================================
; ENTRÉE : A = tile à écrire, HL = adresse de début
; SORTIE : HL = adresse après la ligne (HL + 20)
; DÉTRUIT : A, B
; NOTE : Remplit exactement 20 octets (largeur visible de l'écran GB)
; =============================================================================
FillTilemapRow:
    ld b, $14

.fillTilemapLoop:
    ld [hl+], a
    dec b
    jr nz, .fillTilemapLoop

    ret

; ===========================================================================
; État $11 - Démarrage niveau (reset score, config timers, init display)
; LCD off → clear score si pas lock → config timers → init routines
; ===========================================================================
State11_LevelStart::
    xor a
    ldh [rLCDC], a               ; LCD off
    di
    JumpIfLocked .skipScoreReset

    ; Reset score si pas verrouillé
    xor a
    ld [wScoreBCDHigh], a
    ld [wScoreBCDMid], a
    ld [wScoreBCD], a
    ldh [hCoinCount], a

.skipScoreReset:
    call LoadGameTiles
    call ClearBGTilemap
    ld hl, $9c00
    ld b, $5f
    ld a, $2c

.clearTilemapLoop:
    ld [hl+], a
    dec b
    jr nz, .clearTilemapLoop

    call CopyHudTilemap
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
    ldh [hTimer2], a
    ldh [hScoreNeedsUpdate], a
    ld a, $5b
    ldh [hScrollColumn], a
    call $2439
    call InitLevelData
    call UpdateCoinDisplay
    call DisplayLivesCount
    ldh a, [hAnimTileIndex]
    call LoadAnimTilesByIndex
; ===========================================================================
; État $10 - État vide (placeholder)
; Retourne immédiatement sans action
; ===========================================================================
State10_Noop::
    ret


; ===========================================================================
; ClearBGTilemap - Remplit la tilemap _SCRN0 avec le tile vide
; Entrée : Aucune
; Sortie : _SCRN0 ($9800-$9BFF) rempli avec TILE_EMPTY
; ===========================================================================
ClearBGTilemap::
    ld hl, _SCRN0 + $03FF       ; Fin de _SCRN0 ($9BFF)
    ld bc, $0400                ; 1024 octets (32x32 tiles)

; ===========================================================================
; FillTilemapLoop - Remplit une zone mémoire avec le tile vide
; Entrée : HL = adresse de fin (décrémente), BC = nombre d'octets
; Sortie : Zone remplie avec TILE_EMPTY ($2C)
; ===========================================================================
FillTilemapLoop::
.loop:
    ld a, TILE_EMPTY
    ld [hl-], a
    dec bc
    ld a, b
    or c
    jr nz, .loop

    ret


; ===========================================================================
; MemCopy - Copie BC octets de HL vers DE
; Entrée : HL = source, DE = destination, BC = nombre d'octets
; Sortie : HL et DE avancés de BC, BC = 0
; ===========================================================================
MemCopy::
.loop:
    ld a, [hl+]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, .loop

    ret


LoadGameTiles:
    ld hl, $5032
    ld de, $9000
    ld bc, $0800
    call MemCopy
    ld hl, $4032
    ld de, $8000
    ld bc, $1000
    call MemCopy
    ld hl, $5603
    ld de, $c600
    ld b, $08

LoadGameTiles_TileCopyLoop:
    ld a, [hl+]
    ld [de], a
    inc hl
    inc de
    dec b
    jr nz, LoadGameTiles_TileCopyLoop

    ret


CopyHudTilemap:
    ld hl, $3f87
    ld de, $9800
    ld b, $02

.copyHudTilemapLoop:
    ld a, [hl+]
    ld [de], a
    inc e
    ld a, e
    and $1f
    cp $14
    jr nz, .copyHudTilemapLoop

    ld e, $20
    dec b
    jr nz, .copyHudTilemapLoop

    ret


;; ==========================================================================
;; StateHandler_00 - Handler d'état $00 ($0610)
;; ==========================================================================
;; Premier état du jeu. Probablement l'initialisation du menu/écran titre.
;; Structure :
;;   1. Init animations et graphiques (UpdateScroll, UpdateAnimatedObjectState)
;;   2. Appels multiples vers bank 3 (init objets $c208-$c248)
;;   3. Appels vers bank 2 ($5844)
;;   4. Mise à jour diverses (scroll, tiles, etc.)
;;   5. Gestion wLevelConfig
;; ==========================================================================
StateHandler_00::
    call UpdateScroll
    call UpdateAnimatedObjectState

    ; Switch vers bank 3 pour initialisation objets
    ldh a, [hCurrentBank]
    ldh [hSavedBank], a
    ld a, BANK_AUDIO              ; Bank 3 (aussi utilisé pour objets)
    ldh [hCurrentBank], a
    ld [$2000], a

    ; Init structure à $48fc
    call $48fc

    ; Init 5 buffers objets ($c208, $c218, $c228, $c238, $c248)
    ; Chaque buffer = 16 bytes, pattern $2164
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

    ; Autres inits bank 3
    call $4a94
    call $498b
    call $4aea
    call $4b3c
    call $4b6f
    call $4b8a
    call $4bb5

    ; Restaurer bank
    ldh a, [hSavedBank]
    ldh [hCurrentBank], a
    ld [$2000], a

    ; Mises à jour locales
    call ProcessAllObjectCollisions
    call UpdateAudio

    ; Switch vers bank 2
    ldh a, [hCurrentBank]
    ldh [hSavedBank], a
    ld a, $02
    ldh [hCurrentBank], a
    ld [$2000], a
    call $5844

    ; Restaurer bank
    ldh a, [hSavedBank]
    ldh [hCurrentBank], a
    ld [$2000], a

    ; Mises à jour finales
    call CheckPlayerFeetCollision
    call UpdatePipeAnimation
    call CheckPlayerHeadCollision
    call CheckPlayerObjectCollision
    call HandleObjectAnimationOnBlockHit
    call UpdatePlayerInvulnBlink

    ; Gestion compteur niveau
    ld hl, wLevelConfig
    ld a, [hl]
    and a
    ret z                         ; Si 0, fin

    dec [hl]                      ; Sinon décrémente
    call LoadDemoInput
    ret


;; ==========================================================================
;; StateHandler_01 - Handler d'état $01 ($06A5)
;; ==========================================================================
;; Attente puis reset des objets avant transition.
;; Structure :
;;   1. Attente timer (ret si hTimer1 != 0)
;;   2. Clear 10 objets (wObjectBuffer, 16 bytes × 10)
;;   3. Reset timers auxiliaires
;;   4. Transition vers état $02
;; ==========================================================================
StateHandler_01::
    ; Attendre que le timer soit à 0
    ld hl, hTimer1
    ld a, [hl]
    and a
    ret nz                        ; Pas encore → attendre

    ; Clear 10 entrées de wObjectBuffer (16 bytes chacune)
    ; Mettre $FF dans le premier byte de chaque entrée = objet inactif
    ld hl, wObjectBuffer
    ld de, $0010                  ; Stride = 16 bytes
    ld b, $0a                     ; 10 objets

.clearLoop:
    ld [hl], $ff                  ; Marquer comme inactif
    add hl, de                    ; Passer à l'entrée suivante
    dec b
    jr nz, .clearLoop

    ; Reset des timers
    xor a
    ldh [hTimerAux], a            ; Timer aux = 0
    dec a                         ; A = $FF
    ld [wUpdateCounter], a        ; Update counter = $FF

    ; Transition vers état $02
    ld a, $02
    ldh [hGameState], a
    ret


;; ==========================================================================
;; StateHandler_02 - Handler d'état $02 ($06C5)
;; ==========================================================================
;; Désactive LCD et prépare le rendu.
;; ==========================================================================
StateHandler_02::
    di
    ld a, $00
    ldh [rLCDC], a
    call $1ecb
    call ClearTilemapBuffer
    ld hl, hTilemapScrollX
    ldh a, [hVBlankMode]
    and a
    jr z, LoadLevelStyleFromHL

    xor a
    ldh [hVBlankMode], a
    ldh a, [hRenderMode]
    inc a
    jr StyleLevelCheck

LoadLevelStyleFromHL:
    ld a, [hl]

StyleLevelCheck:
    cp $03
    jr z, StyleLevelAdjusted

    dec a

StyleLevelAdjusted:
    ld bc, ROM_STYLE_LVL_0
    cp $07
    jr c, ApplyLevelStyleConfig

    ld bc, ROM_STYLE_LVL_7
    cp $0b
    jr c, ApplyLevelStyleConfig

    ld bc, ROM_STYLE_LVL_11
    cp $0f
    jr c, ApplyLevelStyleConfig

    ld bc, ROM_STYLE_LVL_15
    cp $13
    jr c, ApplyLevelStyleConfig

    ld bc, ROM_STYLE_LVL_19
    cp $17
    jr c, ApplyLevelStyleConfig

    ld bc, ROM_STYLE_LVL_23

ApplyLevelStyleConfig:
    ld [hl], b
    inc l
    ld [hl], $00
    ld a, c
    ld [wPlayerVarAB], a
    call LoadLevelData
    ld hl, $982b
    ld [hl], $2c
    inc l
    ldh a, [hAnimTileIndex]
    ld b, a
    and $f0
    swap a
    ld [hl+], a
    ld a, b
    and $0f
    inc l
    ld [hl], a
    ld hl, $9c00
    ld de, ROM_TILEMAP_INIT
    ld b, $09

.copyTilemapInitLoop:
    ld a, [de]
    ld [hl+], a
    inc de
    dec b
    jr nz, .copyTilemapInitLoop

    xor a
    ldh [hGameState], a
    ld [wPlayerInvuln], a
    ld a, $c3
    ldh [rLCDC], a
    call RenderPlayerUpdate
    xor a
    ldh [rIF], a
    ldh [hShadowSCX], a
    ld [wCollisionFlag], a
    ldh [hBlockHitType], a
    ld [wSpecialState], a
    ldh [rTMA], a
    ld hl, $da01
    ld [hl+], a
    ld [hl], $04
    ld a, $28
    ld [wLevelData], a
    ld a, $5b
    ldh [hScrollColumn], a
    ldh a, [hRenderContext]
    ld c, $0a
    cp $05
    jr z, EnterGameplayState

    ld c, $0c
    cp $0b
    jr nz, ContinueAfterStateSetup

EnterGameplayState:
    ld a, $0d
    ldh [hGameState], a
    ld a, [wPlayerDir]
    and $f0
    or c
    ld [wPlayerDir], a

ContinueAfterStateSetup:
    call FindAudioTableEntry
    ei
    ret


    inc l
    add h
    add hl, de
    ld a, [bc]
    ld e, $1c
    ld c, $84
    inc l

RenderPlayerUpdate:
    ld a, [wPlayerInvuln]
    and a
    ret nz

    ld a, $03
    ld [$2000], a
    call $7ff3
    ldh a, [hCurrentBank]
    ld [$2000], a
    ldh a, [hRenderCounter]
    and a
    jr nz, SetStateRenderEnd

    ldh a, [hRenderContext]
    ld hl, $07b7
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ld [wStateRender], a
    ret


SetStateRenderEnd:
    ld a, $04
    ld [wStateRender], a
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

;; ==========================================================================
;; CheckInputAndPause - Vérifie input pour soft reset ou toggle pause
;; ==========================================================================
;; Appelé par : GameLoop (CheckPauseOrSkip)
;; Effets :
;;   - Si A+B+Start+Select pressés → SOFT RESET (jp SystemInit)
;;   - Si Start pressé (nouveau) → Toggle pause ($FFB2)
;; ==========================================================================
CheckInputAndPause:
    ; --- CheckSoftReset ---
    ; Si D-pad = $0F (toutes directions), c'est la combo reset
    ldh a, [hJoypadState]          ; Lire joypad (directions)
    and $0f                 ; Masquer les 4 bits bas
    cp $0f                  ; Toutes les directions ?
    jr nz, CheckStartButtonForPause      ; Non → vérifier pause

    jp SystemInit        ; OUI → SOFT RESET !

; --- CheckStartPressed ---
CheckStartButtonForPause:
    ldh a, [$ff81]          ; Lire joypad (boutons, edge detect)
    bit 3, a                ; Start pressé (nouveau) ?
    ret z                   ; Non → return

    ; --- CheckCanPause ---
    ldh a, [hGameState]          ; Lire game_state
    cp $0e                  ; État >= $0E ?
    ret nc                  ; Oui → ne peut pas pauser

    ; --- TogglePause ---
    ld hl, $ff40            ; HL = rLCDC
    ldh a, [hPauseFlag]          ; Lire flag pause
    xor $01                 ; Toggle (0↔1)
    ldh [hPauseFlag], a          ; Sauvegarder
    jr z, ExitPause       ; Si maintenant 0 → unpause

    ; --- EnterPause ---
    set 5, [hl]             ; Activer Window (afficher "PAUSE")
    ld a, $01

SaveAudioStatePause:
    ldh [hSavedAudio], a          ; Sauvegarder état audio ?
    ret

; --- ExitPause ---
ExitPause:
    res 5, [hl]             ; Désactiver Window
    ld a, $02
    jr SaveAudioStatePause

LoadLevelData:
    ld hl, $2114
    ld de, wPlayerY
    ld b, $51

.loadLevelDataLoop:
    ld a, [hl+]
    ld [de], a
    inc de
    dec b
    jr nz, .loadLevelDataLoop

    ldh a, [hTimerAux]
    and a
    jr z, InitScrollState

    ld a, $10
    ld [wPlayerDir], a

InitScrollState:
    ld hl, hTilemapScrollY
    xor a
    ld b, $06

.clearScrollLoop:
    ld [hl+], a
    dec b
    jr nz, .clearScrollLoop

    ldh [hTemp3], a
    ld [wGameVarAA], a
    ld a, $40
    ldh [hScrollColumn], a
    ld b, $14
    ldh a, [hGameState]
    cp $0a
    jr z, .initScrollColumnsLoop

    ldh a, [hRenderContext]
    cp $0c
    jr z, .initScrollColumnsLoop

    ld b, $1b

.initScrollColumnsLoop:
    push bc
    call InitScrollBuffer
    call UpdateScrollColumn
    pop bc
    dec b
    jr nz, .initScrollColumnsLoop

    ret


UpdateAnimatedObjectState::
    ldh a, [hAnimObjCount]
    and a
    jr z, SkipAnimObjectLoop

DecAnimObjCount:
    dec a
    ldh [hAnimObjCount], a

SkipAnimObjectLoop:
    ld de, hCurrentTile
    ld b, $0a
    ld hl, wAudioBuffer

ScanObjectLoop:
    ld a, [hl]
    cp $ff
    jr nz, ProcessAudioSlot

Jump_000_084c:
    add hl, de
    dec b
    jr nz, ScanObjectLoop

    ret


ProcessAudioSlot:
    ldh [hOAMIndex], a
    ld a, l
    ldh [hOAMAddrLow], a
    push bc
    push hl
    ld bc, $000a
    add hl, bc
    ld c, [hl]
    inc l
    inc l
    ld a, [hl]
    ldh [hAnimObjSubState], a
    ld a, [wPlayerX]
    ld b, a
    ldh a, [hTimerAux]
    cp $02
    jr nz, AdjustPlayerXForCollision

    ld a, [wPlayerDir]
    cp $18
    jr z, AdjustPlayerXForCollision

    ld a, $fe
    add b
    ld b, a

AdjustPlayerXForCollision:
    ld a, b

CheckPlayerCollisionWithObject:
    ldh [hTemp0], a
    ld a, [wPlayerX]
    add $06
    ldh [hTemp1], a
    ld a, [wPlayerState]
    ld b, a
    sub $03
    ldh [hTemp2], a
    ld a, $02
    add b
    ldh [hParam3], a
    pop hl
    push hl
    call CheckBoundingBoxCollision
    and a
    jp z, Jump_000_0958

    ldh a, [hOAMAddrLow]
    cp $90
    jp z, Jump_000_096a

    ldh a, [hOAMIndex]
    cp $33
    jp z, Jump_000_09ce

    ldh a, [hGameState]
    cp $0d
    jr z, SkipInvulnCheck

    ld a, [wPlayerInvuln]
    and a
    jr z, ProcessPlayerInteraction

SkipInvulnCheck:
    dec l
    jp Jump_000_0939


ProcessPlayerInteraction:
    ld a, [wPlayerState]
    add $06
    ld c, [hl]
    dec l
    sub c
    jr c, PlayerInteractionCheckDamage

    ld a, [wPlayerState]
    sub $06
    sub b
    jr nc, PlayerInteractionCheckDamage

    ld b, [hl]
    dec b
    dec b
    dec b
    ld a, [wPlayerX]
    sub b
    jr nc, PlayerInteractionCheckDamage

    dec l
    dec l
    push hl
    ld bc, $000a
    add hl, bc
    bit 7, [hl]
    pop hl
    jr nz, PlayerInteractionDone

    call SelectAnimationBank
    call GetAnimationDataPointer
    and a
    jr z, PlayerInteractionDone

    ld hl, $c20a
    ld [hl], $00
    dec l
    dec l
    ld [hl], $0d
    dec l
    ld [hl], $01
    ld hl, wPlayerDir
    ld a, [hl]
    and $f0
    or $04
    ld [hl], a

SetupAnimationBuffer:
    ld a, $03
    ld [wStateBuffer], a
    ld a, [wPlayerState]
    add $fc
    ldh [hPtrLow], a
    ld a, [wPlayerX]
    sub $10
    ldh [hPtrHigh], a
    ldh a, [hAnimStructBank]
    ldh [hPtrBank], a
    ldh a, [hAnimObjCount]
    and a
    jr z, ResetAnimScale

    ldh a, [hAnimScaleCounter]
    cp $03
    jr z, PlayerAnimScaleEntry

    inc a
    ldh [hAnimScaleCounter], a

PlayerAnimScaleEntry:
    ld b, a
    ldh a, [hPtrBank]
    cp $50
    jr z, ResetAnimScale

PlayerAnimScaleLoop:
    sla a
    dec b
    jr nz, PlayerAnimScaleLoop

    ldh [hPtrBank], a

AnimObjCountSet:
    ld a, $32
    ldh [hAnimObjCount], a
    jr PlayerInteractionDone

ResetAnimScale:
    xor a
    ldh [hAnimScaleCounter], a
    jr AnimObjCountSet

Jump_000_0939:
PlayerInteractionCheckDamage:
    dec l
    dec l
    ld a, [wPlayerInvuln]
    and a
    jr nz, LoadAudioAndSetupAnim

    ldh a, [hTimerAux]
    cp $03
    jr nc, PlayerInteractionDone

    call TriggerObjectSound
    and a
    jr z, PlayerInteractionDone

    ldh a, [hTimerAux]
    and a
    jr nz, StartGameplayPhaseJump

    call InitGameState

PlayerInteractionDone:
    pop hl
    pop bc
    ret


Jump_000_0958:
    pop hl
    pop bc
    jp Jump_000_084c


StartGameplayPhaseJump:
    call StartGameplayPhase
    jr PlayerInteractionDone

LoadAudioAndSetupAnim:
    call LoadAudioSlotConfiguration
    and a
    jr z, PlayerInteractionDone

    jr SetupAnimationBuffer

Jump_000_096a:
    ldh a, [hOAMIndex]
    cp $29
    jr z, ObjectInteraction_CoinHit

    cp $34
    jr z, ObjectInteraction_EnemyHit

    cp $2b
    jr z, ObjectInteraction_SpecialHit

    cp $2e
    jr nz, PlayerInteractionDone

    ldh a, [hTimerAux]
    cp $02
    jr nz, ObjectInteraction_SetupTimer

    ldh [hSubState], a

ObjectInteraction_SetupStateBuffer:
    ld a, $04
    ld [wStateBuffer], a

ObjectInteraction_SetupAnimBank:
    ld a, $10
    ldh [hPtrBank], a

ObjectInteraction_CalcAnimPtr:
    ld a, [wPlayerState]
    add $fc
    ldh [hPtrLow], a
    ld a, [wPlayerX]
    sub $10
    ldh [hPtrHigh], a

ObjectInteraction_MarkSpriteHandled:
    dec l
    dec l
    dec l
    ld [hl], $ff
    jr PlayerInteractionDone

ObjectInteraction_CoinHit:
    ldh a, [hTimerAux]
    cp $02
    jr z, ObjectInteraction_SetupAnimBank

ObjectInteraction_SetupTimer:
    ld a, $01
    ldh [hTimerAux], a
    ld a, $50
    ldh [hTimer1], a
    jr ObjectInteraction_SetupStateBuffer

ObjectInteraction_EnemyHit:
    ld a, $f8
    ld [wPlayerInvuln], a
    ld a, $0c
    ld [wStateRender], a
    jr ObjectInteraction_SetupAnimBank

ObjectInteraction_SpecialHit:
    ld a, $ff
    ldh [hPtrBank], a
    ld a, $08
    ld [wStateBuffer], a
    ld a, $01
    ld [wUpdateCounter], a
    jr ObjectInteraction_CalcAnimPtr

Jump_000_09ce:
    ldh [hPendingCoin], a
    ld a, $05
    ld [wStateBuffer], a
    jr ObjectInteraction_MarkSpriteHandled

StartGameplayPhase:
    ld a, $03
    ldh [hTimerAux], a
    xor a
    ldh [hSubState], a
    ld a, $50
    ldh [hTimer1], a
    ld a, $06
    ld [wStateBuffer], a
    ret


;; ==========================================================================
;; InitGameState - Initialise l'état de jeu (appelé quand $DA1D == 3)
;; ==========================================================================
;; Appelé par : GameLoop (CheckSpecialState)
;; Condition  : $D007 == 0 (sinon early return)
;; Effet      : Configure game_state = $03 et initialise les variables
;; ==========================================================================
InitGameState:
    ; --- Early return si $D007 != 0 ---
    ld a, [wAudioCondition]
    and a
    ret nz

    ; --- SetGameState($03) ---
    ld a, $03
    ldh [hGameState], a          ; game_state = $03

    ; --- ResetTimerAndVariables ---
    xor a
    ldh [hSubState], a          ; Variable = 0
    ldh [rTMA], a           ; Timer Modulo = 0 (désactive timer)

    ld a, $02
    ld [wStateRender], a           ; Variable WRAM = $02

    ; --- InitPlayerState ---
    ld a, $80
    ld [wPlayerY], a           ; Player state = $80

    ld a, [wPlayerX]           ; Lire position/état
    ld [wLevelVarDD], a           ; Copier vers variable de travail
    ret


SelectAnimationBank:
    push hl
    push de
    ldh a, [hAnimObjSubState]
    and $c0
    swap a
    srl a
    srl a
    ld e, a
    ld d, $00
    ld hl, $0a20
    add hl, de
    ld a, [hl]
    ldh [hAnimStructBank], a
    pop de
    pop hl
    ret


    ld bc, $0804
    ld d, b

HandleObjectAnimationOnBlockHit:
    ldh a, [hBlockHitType]
    and a
    ret z

    cp $c0
    ret z

    ld de, $0010
    ld b, $0a
    ld hl, wObjectBuffer

FindObjectLoop:
    ld a, [hl]
    cp $ff
    jr nz, ProcessFoundObject

Jump_000_0a38:
    add hl, de
    dec b
    jr nz, FindObjectLoop

    ret


ProcessFoundObject:
    push bc
    push hl
    ld bc, $000a
    add hl, bc
    bit 7, [hl]
    jr nz, ContinueObjectScan

    ld c, [hl]
    inc l
    inc l
    ld a, [hl]
    ldh [hAnimObjSubState], a
    pop hl
    push hl
    inc l
    inc l
    ld b, [hl]
    ld a, [wPlayerX]
    sub b
    jr c, ContinueObjectScan

    ld b, a
    ld a, $14
    sub b
    jr c, ContinueObjectScan

    cp $07
    jr nc, ContinueObjectScan

    inc l
    ld a, c
    and $70
    swap a
    ld c, a
    ld a, [hl]

Loop_AddValueByEight:
    add $08
    dec c
    jr nz, Loop_AddValueByEight

    ld c, a
    ld b, [hl]
    ld a, [wPlayerState]
    sub $06
    sub c
    jr nc, ContinueObjectScan

    ld a, [wPlayerState]
    add $06
    sub b
    jr c, ContinueObjectScan

    dec l
    dec l
    dec l
    push de
    call SelectAnimationBank
    call CheckObjectBottomCollision
    pop de
    and a
    jr z, ContinueObjectScan

    ld a, [wPlayerState]
    add $fc
    ldh [hPtrLow], a
    ld a, [wPlayerX]
    sub $10
    ldh [hPtrHigh], a
    ldh a, [hAnimStructBank]
    ldh [hPtrBank], a

ContinueObjectScan:
    pop hl
    pop bc
    jp Jump_000_0a38


CheckBoundingBoxCollision:
    inc l
    inc l
    ld a, [hl]
    add $08
    ld b, a
    ldh a, [hTemp0]
    sub b
    jr nc, ReturnZero

    ld a, c
    and $0f
    ld b, a
    ld a, [hl]

Loop_SubtractValueByEight:
    dec b
    jr z, Loop_SubtractValueByEightEnd

    sub $08
    jr Loop_SubtractValueByEight

Loop_SubtractValueByEightEnd:
    ld b, a
    ldh a, [hTemp1]
    sub b
    jr c, ReturnZero

    inc l
    ldh a, [hParam3]
    ld b, [hl]
    sub b
    jr c, ReturnZero

    ld a, c
    and $70
    swap a
    ld b, a
    ld a, [hl]

Loop_AddValueByEightV2:
    add $08
    dec b
    jr nz, Loop_AddValueByEightV2

    ld b, a
    ldh a, [hTemp2]
    sub b
    jr nc, ReturnZero

    ld a, $01
    ret


ReturnZero:
    xor a
    ret


CheckPlayerObjectCollision:
    ld a, [$c207]
    cp $01
    ret z

    ld de, $0010
    ld b, $0a
    ld hl, wObjectBuffer

CheckCollisionLoop:
    ld a, [hl]
    cp $ff
    jr nz, CheckCollisionObjectPath

Jump_000_0af4:
    add hl, de
    dec b
    jr nz, CheckCollisionLoop

    ret


CheckCollisionObjectPath:
    push bc
    push hl
    ld bc, $000a
    add hl, bc
    bit 7, [hl]
    jp z, Jump_000_0b7f

    ld a, [hl]
    and $0f
    ldh [hTemp0], a
    ld bc, hVBlankSelector
    add hl, bc
    ldh a, [hTemp0]
    ld b, a
    ld a, [hl]

SubtractPositionOffset:
    dec b
    jr z, CheckCollisionXAxisPath

    sub $08
    jr SubtractPositionOffset

CheckCollisionXAxisPath:
    ld c, a
    ldh [hTemp0], a
    ld a, [wPlayerX]
    add $06
    ld b, a
    ld a, c
    sub b
    cp $07
    jr nc, CollisionCheckFailed

    inc l
    ld a, [wPlayerState]
    ld b, a
    ld a, [hl]
    sub b
    jr c, CheckCollisionYAxisPath

    cp $03
    jr nc, CollisionCheckFailed

CheckCollisionYAxisPath:
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

AddHeightOffset:
    add $08
    dec b
    jr nz, AddHeightOffset

    ld b, a
    ld a, [wPlayerState]
    sub b
    jr c, ApplyCollisionKnockback

    cp $03
    jr nc, CollisionCheckFailed

ApplyCollisionKnockback:
    dec l
    ldh a, [hTemp0]
    sub $0a
    ld [wPlayerX], a
    push hl
    dec l
    dec l
    call GetAnimationDataPointer
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
    jr c, CollisionBoundsCheckEnd

    ld [hl], $06

CollisionBoundsCheckEnd:
    pop hl
    pop bc
    ret


Jump_000_0b7f:
CollisionCheckFailed:
    pop hl
    pop bc
    jp Jump_000_0af4


;; ==========================================================================
;; StateHandler_03 - Handler d'état $03 ($0B84)
;; ==========================================================================
;; Configure les sprites OAM pour un effet visuel (transition ?).
;; Place 4 sprites dans wOamVar0C puis passe à l'état $04.
;; ==========================================================================
StateHandler_03::
    ; Configurer 4 sprites OAM pour effet de transition
    ld hl, wOamVar0C
    ld a, [wLevelVarDD]
    ld c, a
    sub $08
    ld d, a
    ld [hl], a                    ; Sprite 0: Y
    inc l
    ld a, [wPlayerState]
    add $f8
    ld b, a
    ld [hl+], a                   ; Sprite 0: X
    ld [hl], $0f                  ; Sprite 0: tile
    inc l
    ld [hl], $00                  ; Sprite 0: attr
    inc l
    ld [hl], c                    ; Sprite 1: Y
    inc l
    ld [hl], b                    ; Sprite 1: X
    inc l
    ld [hl], $1f                  ; Sprite 1: tile
    inc l
    ld [hl], $00                  ; Sprite 1: attr
    inc l
    ld [hl], d                    ; Sprite 2: Y
    inc l
    ld a, b
    add $08
    ld b, a
    ld [hl+], a                   ; Sprite 2: X
    ld [hl], $0f                  ; Sprite 2: tile
    inc l
    ld [hl], $20                  ; Sprite 2: attr (flipped)
    inc l
    ld [hl], c                    ; Sprite 3: Y
    inc l
    ld [hl], b                    ; Sprite 3: X
    inc l
    ld [hl], $1f                  ; Sprite 3: tile
    inc l
    ld [hl], $20                  ; Sprite 3: attr (flipped)

    ; Transition vers état $04
    ld a, $04
    ldh [hGameState], a
    xor a
    ld [wGameVarAC], a
    ldh [hTimerAux], a
    ldh [hRenderCounter], a
    call $1ecb
    ret


;; ==========================================================================
;; StateHandler_04 - Handler d'état $04 ($0BCD)
;; ==========================================================================
;; Animation/progression d'un effet visuel via wGameVarAC.
;; ==========================================================================
StateHandler_04::
    ld a, [wGameVarAC]
    ld e, a
    inc a
    ld [wGameVarAC], a
    ld d, $00
    ld hl, $0c10
    add hl, de
    ld b, [hl]
    ld a, b
    cp $7f
    jr nz, UpdateSpriteAnimationPath

    ld a, [wGameVarAC]
    dec a
    ld [wGameVarAC], a
    ld b, $02

UpdateSpriteAnimationPath:
    ld hl, wOamVar0C
    ld de, $0004
    ld c, $04

SpriteAnimationOAMLoop:
    ld a, b
    add [hl]
    ld [hl], a
    add hl, de
    dec c
    jr nz, SpriteAnimationOAMLoop

    cp $b4
    ret c

    ld a, [wSpecialState]
    cp $ff
    jr nz, SetGameStateSpecialPath

    ld a, $3b
    jr SetGameStateValue

SetGameStateSpecialPath:
    ld a, $90
    ldh [hTimer1], a
    ld a, $01

SetGameStateValue:
    ldh [hGameState], a
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

;; Zone de données ($0C10-$0C36)
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

;; ==========================================================================
;; StateHandler_07 - Handler d'état $07 ($0C37)
;; ==========================================================================
;; Attente timer puis appel bank 3, transition vers état $05.
;; ==========================================================================
StateHandler_07::
    ld hl, hTimer1
    ld a, [hl]
    and a
    jr z, .timerDone

    call CallBank3Handler
    ret


.timerDone:
    ld a, [wAudioCondition]
    and a
    jr nz, .skipTimerInit

    ld a, $40
    ldh [hTimer1], a

.skipTimerInit:
    ld a, $05
    ldh [hGameState], a
    xor a
    ld [wSpecialState], a
    ldh [rTMA], a
    ldh a, [hAnimTileIndex]
    and $0f
    cp $03
    ret nz

    call DestroyAllObjects
    ldh a, [hAnimTileIndex]
    cp $43
    ret nz

    ld a, $06
    ldh [hGameState], a
    ret


;; ==========================================================================
;; StateHandler_05 - Handler d'état $05 ($0C6A)
;; ==========================================================================
;; Gestion niveau spécial (monde 3?), peut passer à état $06.
;; ==========================================================================
StateHandler_05::
    ldh a, [hAnimTileIndex]
    and $0f
    cp $03
    jr nz, AnimationCheckCompleteExit

    xor a
    ld [wPlayerVarAB], a
    call UpdateAudio

AnimationCheckCompleteExit:
    ldh a, [hTimer1]
    and a
    ret nz

    ld hl, $da01
    ld a, [hl+]
    ld b, [hl]
    or b
    jr z, TransitionToLevelPath

    ld a, $01
    ld [wLevelData], a
    ldh a, [hCurrentBank]
    ldh [hSavedBank], a
    ld a, $02
    ldh [hCurrentBank], a
    ld [$2000], a
    call $5844
    ldh a, [hSavedBank]
    ldh [hCurrentBank], a
    ld [$2000], a
    ld de, $0010
    call AddScore
    ld a, $01
    ldh [hTimer1], a
    xor a
    ld [wSpecialState], a
    ld a, [$da01]
    and $01
    ret nz

    ld a, $0a
    ld [wStateBuffer], a
    ret


TransitionToLevelPath:
    ld a, $06
    ldh [hGameState], a
    ld a, $26
    ldh [hTimer1], a
    ret


;; ==========================================================================
;; StateHandler_06 - Handler d'état $06 ($0CC2)
;; ==========================================================================
;; Transition après niveau, choix état suivant selon position et niveau.
;; ==========================================================================
StateHandler_06::
    ldh a, [hTimer1]
    and a
    ret nz

    xor a
    ld [wSpecialState], a
    ldh [rTMA], a
    ldh a, [hAnimTileIndex]
    and $0f
    cp $03
    ld a, $1c                     ; État $1C si niveau spécial
    jr z, StateHandler_06_SpecialLevel

    ; Vérifier position X du joueur
    ld a, [wPlayerX]
    cp $60

CheckPlayerCenterPosition:
    jr c, StateHandler_06_SwitchBank2

    cp $a0
    jr nc, StateHandler_06_SwitchBank2

    ld a, $08                     ; État $08 si position centrale
    jr StateHandler_06_SetNextState

StateHandler_06_SwitchBank2:
    ld a, $02
    ldh [hCurrentBank], a
    ld [$2000], a
    ld a, $12                     ; État $12 si hors centre

StateHandler_06_SetNextState:
    ldh [hGameState], a
    ret


StateHandler_06_SpecialLevel:
    ldh [hGameState], a
    ld a, $03
    ld [$2000], a
    ldh [hCurrentBank], a
    ld hl, hRenderContext
    ld a, [hl]
    ldh [hOAMIndex], a
    ld [hl], $0c
    inc l
    xor a
    ld [hl+], a
    ld [hl+], a
    ldh [hTemp3], a
    inc l
    inc l
    ld a, [hl]
    ldh [hVramPtrLow], a
    ld a, $06
    ldh [hTimer1], a
    ldh a, [hAnimTileIndex]
    and $f0
    cp $40
    ret nz

    xor a
    ldh [hOAMIndex], a
    ld a, $01
    ld [wAudioSaveDE], a
    ld a, $bf
    ldh [hOAMAddrLow], a
    ld a, $ff
    ldh [hTimer1], a
    ld a, $27
    ldh [hGameState], a
    call $7ff3
    ret


LoadGameTilesWithBank:
    di
    ld a, c
    ld [$2000], a
    ldh [hCurrentBank], a
    xor a
    ldh [rLCDC], a
    call LoadGameTiles
    jp Jump_000_0dca


;; ==========================================================================
;; StateHandler_08 - Handler d'état $08 ($0D40)
;; ==========================================================================
;; Gestion progression monde/niveau, change bank et contexte.
;; ==========================================================================
StateHandler_08::
    ld hl, hTimer1
    ld a, [hl]
    and a
    ret nz

    ld a, [$dff9]
    and a
    ret nz

    ldh a, [hRenderContext]
    inc a
    cp $0c
    jr nz, IncrementRenderContextPath

    xor a

IncrementRenderContextPath:
    ldh [hRenderContext], a
    ldh a, [hAnimTileIndex]
    inc a
    ld b, a
    and $0f
    cp $04
    ld a, b
    jr nz, UpdateAnimationTileIndexPath

    add $0d

UpdateAnimationTileIndexPath:
    ldh [hAnimTileIndex], a

LoadAnimTilesByIndex:
    and $f0
    swap a
    cp $01
    ld c, $02
    jr z, LoadGameTilesWithBank

    cp $02
    ld c, $01
    jr z, LoadAnimTilesWithBank

    cp $03
    ld c, $03
    jr z, LoadAnimTilesWithBank

    ld c, $01

LoadAnimTilesWithBank:
    ld b, a
    di
    ld a, c
    ld [$2000], a
    ldh [hCurrentBank], a
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

CopyPatternTileDataLoop:
    ld a, [de]
    ld [hl+], a
    inc de
    push hl
    ld bc, $7230
    add hl, bc
    pop hl
    jr nc, CopyPatternTileDataLoop

    pop de
    ld hl, $0dea
    add hl, de
    ld e, [hl]
    inc hl
    ld d, [hl]
    push de
    ld hl, $9310

CopyColorPaletteDataLoop:
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, h
    cp $97
    jr nz, CopyColorPaletteDataLoop

    pop hl
    ld de, $02c1
    add hl, de
    ld de, $c600
    ld b, $08

CopyGraphicsPaletteLoop:
    ld a, [hl+]
    ld [de], a
    inc hl
    inc de
    dec b
    jr nz, CopyGraphicsPaletteLoop

Jump_000_0dca:
    xor a
    ldh [rIF], a
    ld a, $c3
    ldh [rLCDC], a
    ei
    ld a, $03
    ldh [hTilemapScrollX], a
    xor a
    ld [wCollisionFlag], a
    ldh [hVBlankMode], a
    ld a, $02
    ldh [hGameState], a
    call $2439
    ret

; === Tables de pointeurs graphiques ($0DE4-$0DEF) ===
; NOTE: Code mal désassemblé - ce sont des données (adresses pour chargement tiles)
; Utilisées par StateHandler_08 pour charger les tiles selon le monde
; GraphicsTableA ($0DE4): dw $4032, $4032, $47F2 (3 pointeurs)
; GraphicsTableB ($0DEA): dw $4402, $4402, $4BC2 (3 pointeurs)
GraphicsTableA:
    ld [hl-], a
    ld b, b
    ld [hl-], a
    ld b, b
    ldh a, [c]
    ld b, a
GraphicsTableB:
    ld [bc], a
    ld b, h
    ld [bc], a
    ld b, h
    jp nz, $f34b

; ===========================================================================
; État $1B - Transition bonus complété ($0DF0)
; Recharge l'écran après zone bonus, LCD off → charge tiles → LCD on → état $08
; ===========================================================================
State1B_BonusComplete::
    xor a
    ldh [rLCDC], a
    call CopyHudTilemap
    call UpdateCoinDisplay
    call DisplayLivesCount
    xor a
    ldh [rIF], a
    ld a, $c3
    ldh [rLCDC], a
    ei
    ld a, $08
    ldh [hGameState], a
    ldh [hScoreNeedsUpdate], a
    ret

; ===========================================================================
; État $1C - Attente timer gameplay ($0E0C)
; Exécute logique tant que timer actif, sinon configure timer → état suivant
; ===========================================================================
State1C_WaitTimerGameplay::
    ldh a, [hTimer1]
    and a
    jr z, TimerExpiredPath

    call InitScrollBuffer
    xor a
    ld [wPlayerVarAB], a
    call UpdateAudio
    call CallBank3Handler
    ret


TimerExpiredPath:
    ld a, $40
    ldh [hTimer1], a
    ld hl, hGameState
    inc [hl]
    ret

; ===========================================================================
; État $1D - Setup VRAM pointer ($0E28)
; Calcule la position VRAM pour le scroll, configure le compteur OAM
; ===========================================================================
State1D_SetupVRAMPointer::
    xor a
    ld [wPlayerVarAB], a
    call UpdateAudio
    ldh a, [hTimer1]
    and a
    ret nz

    ldh a, [hVramPtrLow]
    sub $02
    cp $40
    jr nc, VRAMPointerAdjustmentPath

    add $20

VRAMPointerAdjustmentPath:
    ld l, a
    ld h, $98
    ld de, $0120
    add hl, de
    ld a, l
    ldh [hVramPtrLow], a
    ld a, $05
    ldh [hOAMAddrLow], a
    ld a, $08
    ldh [hTimer1], a
    ld hl, hGameState
    inc [hl]
    ret

; ===========================================================================
; État $1E - Clear tilemap progressif ($0E54)
; Efface une colonne de tiles à chaque frame, puis appelle bank 3
; ===========================================================================
State1E_ClearTilemapColumn::
    ldh a, [hTimer1]
    and a
    ret nz

    ldh a, [hOAMAddrLow]
    dec a
    jr z, TilemapColumnClearCompletePath

    ldh [hOAMAddrLow], a
    ldh a, [hVramPtrLow]
    ld l, a
    ld h, $99
    sub $20
    ldh [hVramPtrLow], a

    WAIT_FOR_HBLANK
    ld [hl], $2c
    ld a, $08
    ldh [hTimer1], a
    ld a, $0b
    ld [wStateBuffer], a
    ret


TilemapColumnClearCompletePath:
    ld a, $10
    ldh [hTimer1], a
    ld a, $03
    ldh [hCurrentBank], a
    ld [$2000], a
    call $7ff3
    ld hl, hGameState
    inc [hl]
    ret

; ===========================================================================
; État $1F - Activation VBlank mode ($0E8D)
; Attente timer, clear collision flags, active le mode VBlank
; ===========================================================================
State1F_EnableVBlankMode::
    ldh a, [hTimer1]
    and a
    ret nz

    xor a
    ld [wCollisionFlag], a
    ld [$c207], a
    inc a
    ldh [hVBlankMode], a
    ld hl, hGameState
    inc [hl]
    ret

; ===========================================================================
; États $20/$28 - Attente position joueur ($0EA0)
; Simule input droite, attend que joueur atteigne position cible
; ===========================================================================
State20_WaitPlayerPosition::
    call AutoMovePlayerRight
    ld a, [wPlayerState]
    cp $c0
    ret c

    ld a, $20
    ldh [hTimer1], a
    ld hl, hGameState
    inc [hl]
    ret

; --- Routine : simule input droite pour animation ---
AutoMovePlayerRight:
    ld a, $10
    ldh [hJoypadState], a
    ld a, [wPlayerDir]
    and $0f
    cp $0a
    call c, CheckPlayerHeadCollision
    call UpdatePipeAnimation
    ret

; ===========================================================================
; État $21 - Setup cutscene fin niveau ($0EC4)
; Attente timer, reset position joueur, configure scroll et timer
; ===========================================================================
State21_SetupEndCutscene::
    ldh a, [hTimer1]
    and a
    ret nz

    call ResetPlayerForCutscene
    xor a
    ldh [hScrollPhase], a
    ldh [hTemp3], a
    ld a, $a1
    ldh [hTimer1], a
    ld a, $0f
    ld [wStateRender], a
    ld hl, hGameState
    inc [hl]
    ret

; --- Routine : reset position joueur pour cutscene ---
ResetPlayerForCutscene:
    ld hl, wPlayerX
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

CopyOAMDataLoop:
    ld a, [de]
    ld [hl+], a
    inc de
    dec b
    jr nz, CopyOAMDataLoop

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

; ===========================================================================
; État $22 - Animation scroll cutscene ($0F09)
; Scroll horizontal + déplace joueur pendant timer actif
; ===========================================================================
State22_ScrollCutscene::
    ldh a, [hTimer1]
    and a
    jr z, CutsceneEndPath

    ld hl, hShadowSCX
    inc [hl]
    call UpdateScroll
    ld hl, wPlayerState
    dec [hl]
    ld hl, $c212
    dec [hl]

CutsceneAnimationContinuePath:
    call CallBank3Handler
    ret


CutsceneEndPath:
    ldh a, [hOAMIndex]
    ldh [hRenderContext], a
    ld hl, hGameState
    inc [hl]
    ret

; ===========================================================================
; État $23 - Animation joueur vers porte ($0F2A)
; Simule input droite, anime le joueur, calcule position VRAM destination
; ===========================================================================
State23_WalkToDoor::
    ld a, $10
    ldh [hJoypadState], a
    call CheckPlayerHeadCollision
    call UpdatePipeAnimation
    ld a, [wPlayerState]
    cp $4c
    ret c

    ld a, [wPlayerDir]
    and $f0
    ld [wPlayerDir], a
    ldh a, [hVramPtrLow]
    sub $40
    add $04
    ld b, a
    and $f0
    cp $c0
    ld a, b
    jr nz, DoorPositionCalculationPath

    sub $20

DoorPositionCalculationPath:
    ldh [hCopyDstHigh], a
    ld a, $98
    ldh [hCopyDstLow], a
    xor a
    ldh [hOAMIndex], a
    ld hl, hGameState
    inc [hl]
    jr CutsceneAnimationContinuePath

; ===========================================================================
; État $24 - Affichage texte cutscene ($0F61)
; Affiche le texte depuis table $0FD8 caractère par caractère
; ===========================================================================
State24_DisplayText::
    ld hl, $0fd8
    call WriteCharToVRAM
    cp $ff
    ret nz

    ld hl, hGameState
    inc [hl]
    ld a, $80
    ld [$c210], a
    ld a, $08
    ldh [hTimer1], a
    ld a, $08
    ldh [hOAMIndex], a
    ld a, $12
    ld [wStateRender], a
    ret

; --- Routine : écrit un caractère de texte en VRAM ---
WriteCharToVRAM:
    ldh a, [hTimer1]
    and a
    ret nz

    ldh a, [hOAMIndex]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ld b, a
    cp $fe

ValidateAndWriteTextCharToVram:
    jr z, LoadOffsetAndCopy

    cp $ff
    ret z

    ldh a, [hCopyDstLow]
    ld h, a
    ldh a, [hCopyDstHigh]
    ld l, a

WaitAndStoreVram:
    WAIT_FOR_HBLANK
    WAIT_FOR_HBLANK
    ld [hl], b
    inc hl
    ld a, h
    ldh [hCopyDstLow], a
    ld a, l
    and $0f
    jr nz, AdjustDestHighByte

    bit 4, l
    jr nz, AdjustDestHighByte

    ld a, l
    sub $20

StoreDestHighByte:
    ldh [hCopyDstHigh], a
    inc e
    ld a, e
    ldh [hOAMIndex], a
    ld a, $0c
    ldh [hTimer1], a
    ret


AdjustDestHighByte:
    ld a, l
    jr StoreDestHighByte

LoadOffsetAndCopy:
    inc hl
    ld a, [hl+]
    ld c, a
    ld b, $00
    ld a, [hl]
    push af
    ldh a, [hCopyDstLow]
    ld h, a
    ldh a, [hCopyDstHigh]
    ld l, a
    add hl, bc
    pop bc
    inc de
    inc de
    jr WaitAndStoreVram

; === Table de texte cutscene ($0FD8-$0FF3) ===
; NOTE: Mal désassemblé - données de texte (indices de tiles)
; Contenu: "THANK YOU MARIO!" terminé par $FF
TextData_0FD8:
    dec e
    ld de, $170a
    inc d
    inc l
    ld [hl+], a
    jr State25_LoadSpriteTableAddress

    inc l
    ld d, $0a
    dec de
    ld [de], a
    jr State25_StoreSpriteValue

    cp $73
    jr State25_StoreOAMIndex

    jr z, @+$2e

    dec c
    ld a, [bc]
    ld [de], a
    inc e
    ld [hl+], a
    rst $38

; ===========================================================================
; État $25 - Animation sprite clignotant ($0FF4)
; Alterne entre deux configs sprite, décrémenter compteur jusqu'à 0
; ===========================================================================
State25_SpriteBlinkAnimation::
    ldh a, [hTimer1]
    and a
    ret nz

    ldh a, [hOAMIndex]
    dec a
    jr z, State25_NextState

State25_StoreOAMIndex:
    ldh [hOAMIndex], a

State25_LoadSpriteTableAddress:
    and $01
    ld hl, $102c
    jr nz, State25_CopySpriteDataToOam

    ld hl, $103c
    ld a, $03

State25_StoreSpriteValue:
    ld [$dff8], a

State25_CopySpriteDataToOam:
    call Copy16BytesToOam
    ld a, $08
    ldh [hTimer1], a
    ret


State25_NextState:
    ld hl, $c210
    ld [hl], $00
    ld hl, hGameState
    inc [hl]
    ret

; --- Routine : copie données OAM depuis table ---
Copy16BytesToOam:
    ld de, wOamVar1C
    ld b, $10

Copy16BytesOam_Loop:
    ld a, [hl+]
    ld [de], a
    inc e
    dec b
    jr nz, Copy16BytesOam_Loop

    ret

; === Tables de données sprites cutscene ($102C-$104B) ===
; NOTE: Mal désassemblé - données de configuration sprite
; SpriteConfig1 ($102C): 16 bytes pour position sprite normal
; SpriteConfig2 ($103C): 16 bytes pour position sprite alternatif
SpriteConfigTable:
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
    jr nz, LoadOffsetAndCopy

    ld e, b
    rlca
    ld b, b
    add b
    ld h, b
    rlca
    ld h, b

; ===========================================================================
; État $26 - Animation princesse montante ($104C)
; Déplace sprite princesse vers le haut, appelle bank externe pour animation
; ===========================================================================
State26_PrincessRising::
    ldh a, [hTimer1]
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
    jr nz, UpdateAnimationFrame

    ld [hl], $01
    ld hl, $c213
    ld [hl], $21
    ld a, $40
    ldh [hTimer1], a

UpdateAnimationFrame:
    ldh a, [hFrameCounter]
    and $01
    jr nz, State26_CallBank3Handler

    ld hl, $c212
    inc [hl]
    ld a, [hl]
    cp $d0
    jr nc, State26_NextState

State26_CallBank3Handler:
    call CallBank3Handler
    ret


State26_NextState:
    ld hl, hGameState
    ld [hl], $12
    ld a, $02
    ldh [hCurrentBank], a
    ld [$2000], a
    ret

; ===========================================================================
; État $27 - Animation joueur oscillante ($1090)
; Animation avec oscillation horizontale du joueur, toggle timer
; ===========================================================================
State27_PlayerOscillation::
    ldh a, [hTimer2]
    and a
    jr nz, State27_ClearPlayerVar

    ld a, $01
    ld [$dff8], a
    ld a, $20
    ldh [hTimer2], a

State27_ClearPlayerVar:
    xor a
    ld [wPlayerVarAB], a
    call UpdateAudio
    ldh a, [hTimer1]
    ld c, a
    and $03
    jr nz, State27_CheckTimer

    ldh a, [hOAMIndex]
    xor $01
    ldh [hOAMIndex], a
    ld b, $fc
    jr z, State27_AddOffsetToFlag

    ld b, $04

State27_AddOffsetToFlag:
    ld a, [wLevelInitFlag]
    add b
    ld [wLevelInitFlag], a

State27_CheckTimer:
    ld a, c
    cp $80
    ret nc

    and $1f
    ret nz

    ld hl, $8dd0
    ld bc, $0220
    ldh a, [hOAMAddrLow]
    ld d, a

.loopVramOp:
    WAIT_FOR_HBLANK
    ld a, [hl]
    and d
    ld e, a

    WAIT_FOR_HBLANK
    ld [hl], e
    inc hl
    ld a, h
    cp $8f
    jr nz, .skipWrap

    ld hl, $9690

.skipWrap:
    rrc d
    dec bc
    ld a, c
    or b
    jr nz, .loopVramOp

    ldh a, [hOAMAddrLow]
    sla a
    jr z, ResetCollisionFlags

    swap a
    ldh [hOAMAddrLow], a
    ld a, $3f
    ldh [hTimer1], a
    ret


ResetCollisionFlags:
    xor a
    ld [wLevelInitFlag], a
    ld [wCollisionFlag], a
    inc a
    ldh [hVBlankMode], a
    ld hl, hGameState
    inc [hl]
    ret

; ===========================================================================
; État $29 - Setup écran fin de jeu ($110D)
; LCD off, clear VRAM, configure sprites, LCD on → état suivant
; ===========================================================================
State29_SetupEndScreen::
    di
    xor a
    ldh [rLCDC], a
    ldh [hVBlankMode], a
    ld hl, $9c00
    ld bc, $0100
    call FillTilemapLoop
    call InitScrollState
    call ResetPlayerForCutscene
    ld hl, wPlayerState
    ld [hl], $38
    inc l
    ld [hl], $10
    ld hl, $c212
    ld [hl], $78
    xor a
    ldh [rIF], a
    ldh [hShadowSCX], a
    ld [wLevelInitFlag], a
    ldh [hOAMIndex], a
    ld hl, wOamBuffer
    ld b, $0c

ClearOamBuffer_Loop:
    ld [hl+], a
    dec b
    jr nz, ClearOamBuffer_Loop

    call CallBank3Handler
    ld a, $98
    ldh [hCopyDstLow], a
    ld a, $a5
    ldh [hCopyDstHigh], a
    ld a, $0f
    ld [wStateRender], a
    ld a, $c3
    ldh [rLCDC], a
    ei
    ld hl, hGameState
    inc [hl]
    ret

; ===========================================================================
; État $2A - Affichage texte fin ($115C)
; Affiche texte depuis table $117A, puis configure sprite princesse
; ===========================================================================
State2A_DisplayEndText::
    ld hl, $117a
    call WriteCharToVRAM
    cp $ff
    ret nz

    xor a
    ldh [hOAMIndex], a
    ld a, $99
    ldh [hCopyDstLow], a
    ld a, $02
    ldh [hCopyDstHigh], a
    ld a, $23
    ld [$c213], a
    ld hl, hGameState
    inc [hl]
    ret

; === Table de données texte fin ($117A-$118A) ===
; NOTE: Mal désassemblé - données de texte
TextData_117A:
    jr @+$13

    jr z, State2B_InitSpriteData

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

; ===========================================================================
; État $2B - Animation descente princesse ($118B)
; Descend sprite princesse, affiche texte depuis $11B6
; ===========================================================================
State2B_PrincessDescending::
    ld hl, $11b6
    call WriteCharToVRAM
    ldh a, [hFrameCounter]
    and $03
    ret nz

    ld hl, $c212
    ld a, [hl]
    cp $44
    jr c, State2B_NextState

    dec [hl]
    call CallBank3Handler
    ret


State2B_NextState:
    ld hl, hGameState
    inc [hl]
    ld hl, wSpriteTemp

State2B_InitSpriteData:
    ld [hl], $70
    inc l
    ld [hl], $3a
    inc l
    ld [hl], $84
    inc l
    ld [hl], $00
    ret

; === Table de données texte ($11B6-$11C6) ===
; NOTE: Mal désassemblé - données de texte
TextData_11B6:
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
    jr State2C_ClearScreen

    rst $38

; ===========================================================================
; État $2C - Animation sprite oscillante ($11C7)
; Anime sprite avec oscillation, clear écran quand terminé
; ===========================================================================
State2C_SpriteOscillation::
    ldh a, [hFrameCounter]
    and $01
    ret nz

    ld hl, wSpriteTemp
    dec [hl]
    ld a, [hl+]
    cp $20
    jr c, State2C_ClearScreen

    ldh a, [hOAMIndex]
    and a
    ld a, [hl]
    jr nz, State2C_IncrementOscillation

    dec [hl]
    cp $30
    ret nc

State2C_StoreOAMIndex:
    ldh [hOAMIndex], a
    ret


State2C_IncrementOscillation:
    inc [hl]
    cp $50
    ret c

    xor a
    jr State2C_StoreOAMIndex

State2C_ClearScreen:
    ld [hl], $f0
    ld b, $6d
    ld hl, $98a5

.loopClear:
    WAIT_FOR_HBLANK
    WAIT_FOR_HBLANK
    ld [hl], $2c
    inc hl
    dec b
    jr nz, .loopClear

    xor a
    ldh [hOAMIndex], a
    ld a, $99
    ldh [hCopyDstLow], a
    ld a, $00
    ldh [hCopyDstHigh], a
    ld hl, hGameState
    inc [hl]
    ret

; ===========================================================================
; État $2D - Affichage texte deuxième partie ($1212)
; Affiche texte depuis $1236, configure sprites Mario et Peach
; ===========================================================================
State2D_DisplayText2::
    ld hl, $1236
    call WriteCharToVRAM
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
    ld hl, hGameState
    inc [hl]
    ret

; === Table de données texte ($1236-$124A) ===
; NOTE: Mal désassemblé - données de texte
TextData_1236:
    add hl, hl
    ld [hl+], a
    jr State2E_CheckCharPosition

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

; ===========================================================================
; État $2E - Animation sprites ensemble ($124B)
; Anime Mario et Peach ensemble, toggle sprite frame
; ===========================================================================
State2E_DuoAnimation::
    ldh a, [hFrameCounter]
    and $03
    jr nz, State2E_CheckCharPosition

    ld hl, $c213
    ld a, [hl]
    xor $01
    ld [hl], a

State2E_CheckCharPosition:
    ld hl, $c240
    ld a, [hl]
    and a
    jr nz, State2E_UpdateMovement

    inc l
    inc l
    dec [hl]
    ld a, [hl]
    cp $50
    jr nz, State2E_CheckCounterFrame2

    ld a, $80
    ld [wPlayerY], a
    jr State2E_UpdateMovement

State2E_CheckCounterFrame2:
    cp $40
    jr nz, State2E_UpdateMovement

    ld a, $80
    ld [$c210], a
    ld a, $40
    ldh [hTimer1], a
    ld hl, hGameState
    inc [hl]

State2E_UpdateMovement:
    call AutoMovePlayerRight
    call UpdateScroll
    ldh a, [hTilemapScrollX]
    cp $03
    ret nz

    ldh a, [hTilemapScrollY]
    and a
    ret nz

    ld hl, $c240
    ld [hl], $00
    inc l
    inc l
    ld [hl], $c0
    ret

; ===========================================================================
; État $2F - Transfer données sprite ($1298)
; Attend timer, copie données vers position sprite joueur
; ===========================================================================
State2F_TransferSpriteData::
    ldh a, [hTimer1]
    and a
    ret nz

    ld hl, $c240
    ld de, wPlayerY
    ld b, $06

CopySpriteDataToOam_Loop:
    ld a, [hl+]
    ld [de], a
    inc e
    dec b
    jr nz, CopySpriteDataToOam_Loop

    ld hl, wPlayerDir
    ld [hl], $26
    ld hl, $c241
    ld [hl], $f0
    ld hl, hGameState
    inc [hl]
    ret

; ===========================================================================
; État $30 - Animation marche gauche ($12B9)
; Déplace sprite vers la gauche avec animation de marche
; ===========================================================================
State30_WalkLeft::
    call CallBank3Handler
    ldh a, [hFrameCounter]
    ld b, a
    and $01
    ret nz

    ld hl, $c240
    ld [hl], $ff
    ld hl, wPlayerX
    dec [hl]
    ld a, [hl+]
    cp $58
    jr z, AdvanceToNextState

    call ToggleAnimFrame
    ret


AdvanceToNextState:
    ld hl, hGameState
    inc [hl]
    ld a, $04
    ldh [hOAMIndex], a
    ret

; --- Routine : toggle frame animation ---
ToggleAnimFrame:
    ldh a, [hFrameCounter]
    and $03
    ret nz

    inc l
    ld a, [hl]
    xor $01
    ld [hl], a
    ret

; ===========================================================================
; État $31 - Scroll horizontal cutscene ($12E8)
; Scroll l'écran horizontalement, prépare transition finale
; ===========================================================================
State31_HorizontalScroll::
    call AnimateAndCallBank3
    call UpdateScroll
    ldh a, [hShadowSCX]
    inc a
    call z, SetupFinalScreen
    inc a
    call z, SetupFinalScreen
    ldh [hShadowSCX], a
    ld a, [$dfe9]
    and a
    ret nz

    ld a, $11
    ld [wStateRender], a
    ret

; --- Routine : animation + bank 3 ---
AnimateAndCallBank3:
    ld hl, wPlayerState
    call ToggleAnimFrame
    call CallBank3Handler
    ret

; --- Routine : setup écran final ---
SetupFinalScreen:
    push af
    ldh a, [hOAMIndex]
    dec a
    ldh [hOAMIndex], a
    jr nz, PopAndReturn

    ldh [rLYC], a
    ld a, $21
    ldh [hOAMIndex], a
    ld a, $54
    ldh [hScrollColumn], a
    call ClearScrollBuffer
    ld hl, $c210
    ld de, $1376
    call Copy5Bytes
    ld hl, $c220
    ld de, $137b
    call Copy5Bytes
    ld hl, $c230
    ld de, $1380
    call Copy5Bytes
    ld hl, hGameState
    inc [hl]

PopAndReturn:
    pop af
    ret

; --- Routine : clear scroll buffer ---
ClearScrollBuffer:
    ld hl, wScrollBuffer
    ld b, $10
    ld a, $2c

ClearBufferLoop:
    ld [hl+], a
    dec b
    jr nz, ClearBufferLoop

    ld a, $01
    ldh [hScrollPhase], a
    ld b, $02
    ldh a, [hScrollColumn]
    sub $20
    ld l, a
    ld h, $98

.loopClearTile:
    WAIT_FOR_HBLANK
    ld [hl], $2c
    ld a, l
    sub $20
    ld l, a
    dec b
    jr nz, .loopClearTile

    ret

; --- Routine : copie 5 bytes de config sprite ---
Copy5Bytes:
    ld b, $05

CopyByteLoop:
    ld a, [de]
    ld [hl+], a
    inc de
    dec b
    jr nz, CopyByteLoop

    ret

; === Tables de données sprites finaux ($1376-$1384) ===
; NOTE: Mal désassemblé - config sprites pour écran final
SpriteEndData:
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

; ===========================================================================
; État $32 - Animation scroll crédits ($1385)
; Scroll avec animation des sprites, transition vers écran suivant
; ===========================================================================
State32_CreditsScroll::
    call AnimateCreditsFrame
    ldh a, [hShadowSCX]
    inc a
    inc a
    ldh [hShadowSCX], a
    and $08
    ld b, a
    ldh a, [hTemp3]
    cp b
    ret nz

    xor $08
    ldh [hTemp3], a
    call ClearScrollBuffer
    ldh a, [hOAMIndex]
    dec a
    ldh [hOAMIndex], a
    ret nz

    xor a
    ldh [hShadowSCX], a
    ld a, $60
    ldh [rLYC], a
    ld hl, $154e
    ld a, h
    ldh [hCopyDstLow], a
    ld a, l
    ldh [hCopyDstHigh], a
    ld a, $f0
    ldh [hTimer1], a
    ld hl, hGameState
    inc [hl]
    ret


UpdateCreditsStars:
    ld hl, $c212
    ld de, $0010
    ld b, $03

ScrollAnimationLoop:
    dec [hl]
    ld a, [hl]
    cp $01
    jr nz, State32_CheckCounterReset

    ld [hl], $fe
    jr State32_MoveToNextSprite

State32_CheckCounterReset:
    cp $e0
    jr nz, State32_MoveToNextSprite

    push hl
    ldh a, [rDIV]
    dec l
    add [hl]
    and $7f
    cp $68
    jr nc, State32_StoreOffsetValue

    and $3f

State32_StoreOffsetValue:
    ld [hl-], a
    ld [hl], $00
    pop hl

State32_MoveToNextSprite:
    add hl, de
    dec b
    jr nz, ScrollAnimationLoop

    ret

; ===========================================================================
; État $33 - Affichage texte crédits ($13E7)
; Affiche le texte des crédits ligne par ligne vers VRAM
; ===========================================================================
State33_DisplayCreditsText::
    call AnimateCreditsFrame
    ldh a, [hTimer1]
    and a
    ret nz

    ldh a, [hCopyDstLow]
    ld h, a
    ldh a, [hCopyDstHigh]
    ld l, a
    ld de, $9a42

DisplayCreditsLoop:
    ld a, [hl]
    cp $fe
    jr z, .clearTile

    inc hl
    ld b, a

.waitAndWrite:
    WAIT_FOR_HBLANK
    WAIT_FOR_HBLANK
    ld a, b
    ld [de], a
    inc de
    ld a, e
    cp $54
    jr z, State33_UpdateVRAMRow1

    cp $93
    jr z, State33_UpdateVRAMRow2

    jr DisplayCreditsLoop

.clearTile:
    ld b, $2c
    jr .waitAndWrite

State33_UpdateVRAMRow1:
    ld de, $9a87
    inc hl
    jr DisplayCreditsLoop

State33_UpdateVRAMRow2:
    inc hl
    ld a, [hl]
    cp $ff
    jr nz, State33_SaveVRAMPointer

    ld a, $ff
    ld [wAudioSaveDE], a

State33_SaveVRAMPointer:
    ld a, h
    ldh [hCopyDstLow], a
    ld a, l
    ldh [hCopyDstHigh], a
    ld hl, hGameState
    inc [hl]
    ret

; ===========================================================================
; État $34 - Attente compteur crédits ($1438)
; Incrémente compteur jusqu'à $20, puis configure timer et état suivant
; ===========================================================================
State34_WaitCreditsCounter::
    call AnimateCreditsFrame
    ldh a, [hFrameCounter]
    and $03
    ret nz

    ld hl, wLevelInitFlag
    inc [hl]
    ld a, [hl]
    cp $20
    ret nz

    ld hl, hGameState
    inc [hl]
    ld a, $50
    ldh [hTimer1], a
    ret

; ===========================================================================
; État $35 - Attente timer simple ($1451)
; Attend timer, puis état suivant
; ===========================================================================
State35_WaitTimer::
    call AnimateCreditsFrame
    ldh a, [hTimer1]
    and a
    ret nz

    ld hl, hGameState
    inc [hl]
    ret

; ===========================================================================
; État $36 - Transition crédits finale ($145D)
; Compteur jusqu'à $50, puis transition vers $33 ou $37 selon flag
; ===========================================================================
State36_CreditsFinalTransition::
    call AnimateCreditsFrame
    ldh a, [hFrameCounter]
    and $03
    ret nz

    ld hl, wLevelInitFlag
    inc [hl]
    ld a, [hl]
    cp $50
    ret nz

    xor a
    ld [wLevelInitFlag], a
    ld a, [wAudioSaveDE]
    cp $ff
    ld a, $33
    jr nz, SetGameStateRegister

    ld a, $37

SetGameStateRegister:
    ldh [hGameState], a
    ret

; ===========================================================================
; État $37 - Animation sprite finale ($147F)
; Anime sprite vers $D0, copie données tilemap, incrémente niveau
; ===========================================================================
State37_FinalSpriteAnimation::
    call AnimateCreditsFrame
    ld hl, wPlayerState
    inc [hl]
    ld a, [hl]
    cp $d0
    ret nz

    dec l
    ld [hl], $f0
    push hl
    call CallBank3Handler
    pop hl
    dec l
    ld [hl], $ff
    ld hl, wTilemapBuf70
    ld de, $14bb
    ld b, $18

State37_CopyTilemapData:
    ld a, [de]
    ld [hl+], a
    inc de
    dec b
    jr nz, State37_CopyTilemapData

    ld b, $18
    xor a

State37_ClearTilemapBuffer:
    ld [hl+], a
    dec b
    jr nz, State37_ClearTilemapBuffer

    ld a, $90
    ldh [hTimer1], a
    ldh a, [hLevelIndex]
    inc a
    ldh [hLevelIndex], a
    ld [wLevelType], a
    ld hl, hGameState
    inc [hl]
    ret

; === Table de données tilemap ($14BB-$14D2) ===
; NOTE: Mal désassemblé - données tilemap pour écran final (24 bytes)
TilemapEndData:
    ld c, [hl]
    call z, $0052
    ld c, [hl]
    call nc, $0053
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

; ===========================================================================
; État $38 - Animation crédits finale ($14D3)
; Attend timer, anime les positions tilemap jusqu'à valeurs finales
; ===========================================================================
State38_CreditsAnimation::
    call AnimateCreditsFrame
    ldh a, [hTimer1]
    and a
    ret nz

    ld hl, wTilemapBuf71
    ld a, [hl]
    cp $3c
    jr z, CheckTilemapCompletion

DecrementTilemapPositions:
    dec [hl]
    dec [hl]
    dec [hl]
    ret


CheckTilemapCompletion:
    ld hl, wTilemapBuf75
    ld a, [hl]
    cp $44
    jr nz, DecrementTilemapPositions

    ld hl, wTilemapBuf79
    ld a, [hl]
    cp $4c
    jr nz, DecrementTilemapPositions

    ld hl, wTilemapBuf7D
    ld a, [hl]
    cp $5c
    jr nz, DecrementTilemapPositions

    ld hl, wTilemapBuf81
    ld a, [hl]
    cp $64
    jr nz, DecrementTilemapPositions

    ld hl, wTilemapBuf85
    ld a, [hl]
    cp $6c
    jr nz, DecrementTilemapPositions

    call InitializeCreditsMode
    xor a
    ldh [hRenderContext], a
    ldh [hTimerAux], a
    ldh [hSubState], a
    ld [wGameConfigA6], a
    ld a, $11
    ldh [hAnimTileIndex], a
    ret


InitializeCreditsMode:
    ldh a, [$ff81]
    and a
    ret z

    call $7ff3

SetupCreditsState:
    ld a, $02
    ldh [hCurrentBank], a
    ld [$2000], a
    ld [wCurrentROMBank], a
    ld [wROMBankInit], a
    xor a
    ld [wLevelData], a
    ld [wGameConfigA5], a
    ld [wPlayerVarAD], a
    ld a, $03
    ldh [rIE], a
    ld a, $0e
    ldh [hGameState], a
    ret


AnimateCreditsFrame:
    call AnimateAndCallBank3
    call UpdateCreditsStars
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
    jr InfiniteLockup_CollideScore

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

InfiniteLockup_CollideScore:
    jr InfiniteLockup_CollideScore

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
    jr ReadScoreValue_CollideScore

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

ReadScoreValue_CollideScore:
    ld c, $1c
    ld [de], a
    db $10
    rla
    cp $16
    ld a, [bc]
    inc e
    ld de, $1612

InfiniteLockup_Render:
    jr InfiniteLockup_Render

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
    jr State09_PipeEnterRight

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
    jr State09_PipeEnterRight.checkTarget

    cp $17
    ld [de], a
    inc e
    ld de, $2712
    ld a, [bc]
    jr nz, State09_PipeEnterRight.moveRight

    cp $ff

; ===========================================================================
; État $09 - Entrée tuyau (déplacement vers la DROITE)
; Déplace le joueur horizontalement vers la position cible (hVBlankSelector)
; puis transite vers état $0A pour charger le sous-niveau
; ===========================================================================
State09_PipeEnterRight::
    ld hl, wPlayerX
    ldh a, [hVBlankSelector]     ; Position X cible

.checkTarget:
    cp [hl]                      ; Atteint la cible ?
    jr z, .reachedTarget

.moveRight:
    inc [hl]                     ; Avance vers la droite
    call UpdatePipeAnimation
    ret

.reachedTarget:
    ld a, $0a
    ldh [hGameState], a          ; Transition vers état $0A
    ldh [hVBlankMode], a
    ret

; ===========================================================================
; État $0A - Chargement sous-niveau (après entrée tuyau)
; LCD off, clear mémoire, repositionne joueur, retour état $00
; ===========================================================================
State0A_LoadSubLevel::
    di
    xor a
    ldh [rLCDC], a
    ldh [hTilemapScrollY], a
    call $1ecb
    call ClearTilemapBuffer
    ldh a, [hRenderCounter]
    ldh [hTilemapScrollX], a
    call LoadLevelData
    call FindAudioTableEntry
    ld hl, wPlayerX
    ld [hl], $20
    inc l
    ld [hl], $1d
    inc l
    inc l
    ld [hl], $00
    xor a
    ldh [rIF], a
    ldh [hGameState], a
    ldh [hShadowSCX], a
    ld a, $c3
    ldh [rLCDC], a
    ei
    ret


; ---------------------------------------------------------------------------
; Routine utilitaire : Clear buffer tilemap ($c800-$ca3f, 576 bytes)
; ---------------------------------------------------------------------------
ClearTilemapBuffer::
    ld hl, $ca3f
    ld bc, $0240

.loop:
    xor a
    ld [hl-], a
    dec bc
    ld a, b
    or c
    jr nz, .loop

    ret

; ===========================================================================
; État $0B - Descente dans tuyau vertical
; Déplace le joueur vers le BAS jusqu'à position cible
; puis charge le niveau de destination et transite vers état $0C
; ===========================================================================
State0B_PipeEnterDown::
    ldh a, [hFrameCounter]
    and $01                      ; 1 frame sur 2 seulement
    ret z

    ld hl, wPlayerState
    ldh a, [hVBlankSelector]     ; Position Y cible
    cp [hl]                      ; Atteint la cible ?
    jr c, .loadDestLevel

    inc [hl]                     ; Descend d'un pixel
    ld hl, $c20b
    inc [hl]                     ; Compteur animation
    call UpdatePipeAnimation
    ret

.loadDestLevel:
    di
    ldh a, [hRenderMode]
    ldh [hTilemapScrollX], a
    xor a
    ldh [rLCDC], a               ; LCD off
    ldh [hTilemapScrollY], a
    call ClearTilemapBuffer
    ld hl, hRenderCounter
    ld [hl+], a
    ld [hl+], a
    ldh a, [$fff7]               ; Position X destination
    ld d, a
    ldh a, [$fff6]               ; Position Y destination
    ld e, a
    push de
    call LoadLevelData
    pop de
    ld a, $80
    ld [$c204], a                ; Flag joueur actif
    ld hl, wPlayerX
    ld a, d
    ld [hl+], a                  ; wPlayerX = destination X
    sub $12
    ldh [hVBlankSelector], a     ; Cible X pour sortie
    ld a, e
    ld [hl], a                   ; wPlayerY = destination Y
    ldh a, [hTilemapScrollX]
    sub $04
    ld b, a
    rlca
    rlca
    rlca
    add b
    add b
    add $0c
    ld [wPlayerVarAB], a
    xor a
    ldh [rIF], a
    ldh [hShadowSCX], a
    ld a, $5b
    ldh [hScrollColumn], a
    call FindAudioTableEntry
    call $1ecb
    ld a, $c3
    ldh [rLCDC], a               ; LCD on
    ld a, $0c
    ldh [hGameState], a          ; Transition vers état $0C
    call RenderPlayerUpdate
    ei
    ret

; ===========================================================================
; État $0C - Sortie tuyau (déplacement vers la GAUCHE)
; Déplace le joueur horizontalement vers la position cible
; puis retourne à l'état $00 (gameplay normal)
; ===========================================================================
State0C_PipeExitLeft::
    ldh a, [hFrameCounter]
    and $01                      ; 1 frame sur 2 seulement
    ret z

    ld hl, wPlayerX
    ldh a, [hVBlankSelector]     ; Position X cible
    cp [hl]                      ; Atteint la cible ?
    jr z, .exitComplete

    dec [hl]                     ; Avance vers la gauche
    call UpdatePipeAnimation
    ret

.exitComplete:
    xor a
    ldh [hGameState], a
    ld [$c204], a
    ldh [hVBlankMode], a
    ret


UpdatePipeAnimation:
    call CallBank3Handler
    ld a, [$c20a]
    and a
    jr z, State0C_ProcessAnimation

    ld a, [wPlayerDir]
    and $0f
    cp $0a
    jr nc, State0C_ProcessAnimation

    ld hl, $c20b
    ld a, [$c20e]
    cp $23
    ld a, [hl]
    jr z, State0C_CheckOddFrame

    and $03
    jr nz, State0C_ProcessAnimation

State0C_IncrementPlayerDir:
    ld hl, wPlayerDir
    ld a, [hl]
    cp $18
    jr z, State0C_ProcessAnimation

    inc [hl]
    ld a, [hl]
    and $0f
    cp $04
    jr c, State0C_ProcessAnimation

    ld a, [hl]
    and $f0
    or $01
    ld [hl], a

State0C_ProcessAnimation:
    call ProcessAnimationState
    ret


State0C_CheckOddFrame:
    and $01
    jr nz, State0C_ProcessAnimation

    jr State0C_IncrementPlayerDir

;; ==========================================================================
;; CallBank3_4823 - Appelle la routine $4823 en bank 3
;; ==========================================================================
;; Appelé par : GameLoop (CheckSpecialState, après InitGameState)
;; Pattern    : Save bank → Switch bank 3 → Call → Restore bank
;; Variables  : $FF8E=$0C, $FF8D=$C0, $FF8F=$05, HL=$C200
;; ==========================================================================
CallBank3Handler:
    ; --- SetupParameters ---
    ld a, $0c
    ldh [hParam2], a          ; Paramètre 1 = $0C
    ld hl, wPlayerY            ; HL = adresse player data
    ld a, $c0
    ldh [hParam1], a          ; Paramètre 2 = $C0
    ld a, $05
    ldh [hParam3], a          ; Paramètre 3 = $05

    ; --- SaveCurrentBank ---
    ldh a, [hCurrentBank]          ; Lire bank courante
    ldh [hSavedBank], a          ; Sauvegarder dans temp

    ; --- SwitchToBank3 ---
    ld a, $03
    ldh [hCurrentBank], a          ; Mettre à jour shadow register
    ld [$2000], a           ; MBC: switch vers bank 3

    ; --- CallTargetRoutine ---
    call $4823              ; Appeler routine en bank 3

    ; --- RestorePreviousBank ---
    ldh a, [hSavedBank]          ; Récupérer bank sauvegardée
    ldh [hCurrentBank], a          ; Restaurer shadow register
    ld [$2000], a           ; MBC: restaurer bank
    ret


Jump_000_1752:
    ldh a, [hGameState]
    cp $0e
    jp nc, Jump_000_1815

    jp Jump_000_1b3c


CheckJoypadUp_GameplayLoop:
    ldh a, [hJoypadState]
    bit 7, a
    jp z, Jump_000_1854

    ld bc, hVramPtrLow
    ld a, h
    ldh [hSpriteAttr], a
    ld a, l
    ldh [hSpriteTile], a
    ld a, h
    add $30
    ld h, a
    ld de, hRenderCounter
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
    call GetSpritePosFromTileAddr
    pop de
    ld hl, wPlayerX
    ld a, [hl+]
    add $10
    ld [de], a
    ldh a, [hShadowSCX]
    ld b, a
    ldh a, [hSpriteX]
    sub b
    add $08
    ld [hl+], a
    inc l
    ld [hl], $80
    ld a, $09
    ldh [hGameState], a
    ld a, [wPlayerInvuln]
    and a
    jr nz, SkipIfInvuln_OnTile

    ld a, $04
    ld [wStateRender], a

SkipIfInvuln_OnTile:
    call $1ecb
    jp Jump_000_1854


; -----------------------------------------------------------------------------
; CheckPlayerHeadCollision - Vérifie collision tête du joueur (vers le haut)
; -----------------------------------------------------------------------------
CheckPlayerHeadCollision:
    ld hl, $c207
    ld a, [hl]
    cp $01
    ret z

    ld hl, wPlayerX
    ld a, [hl+]
    add $0b
    ldh [hSpriteY], a
    ldh a, [hShadowSCX]
    ld b, a
    ld a, [hl]
    add b
    add $fe
    ldh [hSpriteX], a
    call ReadTileUnderSprite
    cp $70
    jr z, CheckJoypadUp_GameplayLoop

    cp $e1
    jp z, Jump_000_1752

    cp $60
    jr nc, CheckBlockProperties_OnCollide

    ld a, [$c20e]
    ld b, $04
    cp $04
    jr nz, CalcOffsetLoop_BlockHit

    ld a, [$c207]
    and a
    jr nz, CalcOffsetLoop_BlockHit

    ld b, $08

CalcOffsetLoop_BlockHit:
    ldh a, [hSpriteX]
    add b
    ldh [hSpriteX], a
    call ReadTileUnderSprite
    cp $60
    jr nc, CheckBlockProperties_OnCollide

HandleBlockType_Collision:
    ld hl, $c207
    ld a, [hl]
    cp $02
    ret z

    ld hl, wPlayerX
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
CheckBlockProperties_OnCollide:
    cp $ed
    push af
    jr nz, ProcessBlockEnd_OnCollide

    ld a, [wPlayerInvuln]
    and a
    jr nz, ProcessBlockEnd_OnCollide

    ldh a, [hTimerAux]
    and a
    jr z, InitGameAfterBlock_OnCollide

    cp $04
    jr z, ProcessBlockEnd_OnCollide

    cp $02
    jr nz, ProcessBlockEnd_OnCollide

    pop af
    call StartGameplayPhase
    jr InitPlayerX

InitGameAfterBlock_OnCollide:
    pop af
    call InitGameState
    jr InitPlayerX

ProcessBlockEnd_OnCollide:
    pop af
    cp $f4
    jr nz, InitPlayerX

    push hl
    pop de
    ld hl, hBlockHitType
    ld a, [hl]
    and a
    jr nz, HandleBlockType_Collision

    ld [hl], $c0
    inc l
    ld [hl], d
    inc l
    ld [hl], e
    ld a, $05
    ld [wStateBuffer], a
    jr HandleBlockType_Collision

Jump_000_1854:
InitPlayerX:
    ld hl, wPlayerX
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
    ldh a, [hBlockHitType]
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
    ldh a, [hBlockHitType]
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
    ld [wLevelConfig], a

Jump_000_189b:
    ldh a, [hBlockHitType]
    and a
    ret nz

    ld a, $05
    ld [wStateBuffer], a
    ld a, [wPlayerX]
    sub $10
    ldh [hPtrHigh], a
    ld a, $c0
    ldh [hPtrBank], a
    ldh [hPendingCoin], a
    ld a, [wLevelConfig]
    and a
    jr nz, jr_000_191a

jr_000_18b7:
    ld a, $80
    ld [wOamVar2E], a
    jr SetupSpriteProperties

jr_000_18be:
    ldh [hTemp0], a
    ld a, $80
    ld [wOamVar2E], a
    ld a, $07
    ld [wStateBuffer], a
    push hl
    pop de
    ld hl, hBlockHitType
    ld a, [hl]
    and a
    ret nz

    ld [hl], $02
    inc l
    ld [hl], d
    inc l
    ld [hl], e
    ld a, d
    ldh [hSpriteAttr], a
    ld a, e
    ldh [hSpriteTile], a
    ld a, d
    add $30
    ld d, a
    ld a, [de]
    ldh [hTemp0], a
    call GetSpritePosFromTileAddr
    ld hl, wOamVar2C
    ld a, [wPlayerX]
    sub $0b
    ld [hl+], a
    ldh [hSoundParam1], a
    ldh [hRenderX], a
    ldh a, [hShadowSCX]
    ld b, a
    ldh a, [hSpriteX]
    ldh [hRenderY], a

ProcessSoundParams:
    sub b
    ld [hl+], a
    ldh [hSoundParam2], a
    inc l
    ld [hl], $00
    ldh a, [hTemp0]
    cp $f0
    ret z

    cp $28
    jr nz, jr_000_1916

    ldh a, [hTimerAux]
    cp $02
    ld a, $28
    jr nz, jr_000_1916

    ld a, $2d

jr_000_1916:
    call PlaySound
    ret


Jump_000_191a:
jr_000_191a:
    ldh a, [hBlockHitType]
    and a
    ret nz

    ld a, $82
    ld [wOamVar2E], a
    ld a, [wStateBuffer]
    and a
    jr nz, SetupSpriteProperties

    ld a, $07
    ld [wStateBuffer], a

SetupSpriteProperties:
    push hl
    pop de
    ld hl, hBlockHitType
    ld [hl], $02
    inc l
    ld [hl], d
    inc l
    ld [hl], e
    ld a, d
    ldh [hSpriteAttr], a
    ld a, e
    ldh [hSpriteTile], a
    call GetSpritePosFromTileAddr
    ld hl, wOamVar2C
    ld a, [wPlayerX]
    sub $0b
    ld [hl+], a
    ldh [hRenderX], a
    ldh a, [hShadowSCX]
    ld b, a
    ldh a, [hSpriteX]
    ld c, a
    ldh [hRenderY], a
    sub b
    ld [hl+], a
    inc l
    ld [hl], $00
    ldh [hPtrLow], a
    ret


jr_000_195d:
    ldh a, [hBlockHitType]
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
    ld [wStateBuffer], a
    ld a, $81
    ld [wOamVar2E], a
    ld a, [wPlayerX]
    sub $10
    ldh [hPtrHigh], a
    ld a, $c0
    ldh [hPtrBank], a
    jr SetupSpriteProperties

; -----------------------------------------------------------------------------
; CheckPlayerFeetCollision - Vérifie collision pieds du joueur (vers le bas)
; -----------------------------------------------------------------------------
CheckPlayerFeetCollision:
    ld a, [$c207]
    cp $01
    ret nz

    ld hl, wPlayerX
    ld a, [hl+]
    add $fd
    ldh [hSpriteY], a
    ldh a, [hShadowSCX]
    ld b, [hl]
    add b
    add $02
    ldh [hSpriteX], a
    call ReadTileUnderSprite
    cp $5f
    jp z, Jump_000_1872

    cp $60
    jr nc, jr_000_19b6

    ldh a, [hSpriteX]
    add $fc
    ldh [hSpriteX], a
    call ReadTileUnderSprite
    cp $5f
    jp z, Jump_000_1872

    cp $60
    ret c

jr_000_19b6:
    call ClassifyTileType
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
    ld [wStateBuffer], a
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

    ldh a, [hTimerAux]
    cp $02
    jp nz, Jump_000_191a

    push hl
    pop de
    ld hl, hBlockHitType
    ld a, [hl]
    and a
    ret nz

    ld [hl], $01
    inc l
    ld [hl], d
    inc l
    ld [hl], e
    ld hl, $c210

InitializeGameObjects:
    ld de, $0010
    ld b, $04

InitObjectsLoop:
    push hl
    ld [hl], $00
    inc l
    ld a, [wPlayerX]
    add $f3
    ld [hl], a
    inc l
    ld a, [wPlayerState]
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
    jr nz, InitObjectsLoop

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
    ldh a, [hShadowSCX]
    ldh [hRenderAttr], a
    ld a, $02
    ld [$dff8], a
    ld de, $0050
    call AddScore
    ld a, $02
    ld [$c207], a
    ret


Jump_000_1a4e:
    push hl
    pop de
    ld hl, hBlockHitType
    ld a, [hl]
    and a
    ret nz

    ld [hl], $c0
    inc l
    ld [hl], d
    inc l
    ld [hl], e
    ld a, $05
    ld [wStateBuffer], a
    ret


; -----------------------------------------------------------------------------
; ClassifyTileType - Vérifie si un tile est dans la liste des tiles spéciaux
; -----------------------------------------------------------------------------
; Entrée  : A = numéro du tile à classifier
; Sortie  : A = type si trouvé, sinon A inchangé
; -----------------------------------------------------------------------------
ClassifyTileType:
    push hl
    push af
    ld b, a
    ldh a, [hAnimTileIndex]
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

SearchByteLoop:
    ld a, [de]
    cp $fd
    jr z, jr_000_1a83

    cp b
    jr z, jr_000_1a86

    inc de
    jr SearchByteLoop

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

; -----------------------------------------------------------------------------
; CheckPlayerSideCollision - Vérifie collision latérale du joueur
; -----------------------------------------------------------------------------
CheckPlayerSideCollision:
    ldh a, [hGameState]
    cp $0e
    jr nc, jr_000_1b03

    ld de, $0701
    ldh a, [hTimerAux]
    cp $02
    jr nz, jr_000_1abd

    ld a, [wPlayerDir]
    cp $18
    jr z, jr_000_1abd

    ld de, $0702

jr_000_1abd:
    ld hl, wPlayerX
    ld a, [hl+]
    add d
    ldh [hSpriteY], a
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
    ldh a, [hShadowSCX]
    add b
    ldh [hSpriteX], a
    push de
    call ReadTileUnderSprite
    call ClassifyTileType
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
    ld hl, hBlockHitType
    ld a, [hl]
    and a
    ret nz

    ld [hl], $c0
    inc l
    ld [hl], d
    inc l
    ld [hl], e
    ld a, $05
    ld [wStateBuffer], a
    xor a
    ret


jr_000_1b1a:
    ldh a, [hVBlankMode]
    and a
    jr z, jr_000_1af2

    ld a, $0b
    ldh [hGameState], a
    ld a, $80
    ld [$c204], a
    ld hl, wPlayerState
    ld a, [hl-]
    add $18
    ldh [hVBlankSelector], a
    ld a, [hl]
    and $f8
    add $06
    ld [hl], a
    call $1ecb
    ld a, $ff
    ret


TriggerBlockCollisionSound:
Jump_000_1b3c:
jr_000_1b3c:
    ldh a, [hTimerAux]
    cp $02
    ld b, $ff
    jr z, jr_000_1b49

    ld b, $0f
    xor a
    ldh [hTimerAux], a

jr_000_1b49:
    ld a, [wPlayerDir]
    and b
    ld [wPlayerDir], a
    ld b, a
    and $0f
    cp $0a
    jr nc, jr_000_1b5d

    ld a, b
    and $f0
    ld [wPlayerDir], a

jr_000_1b5d:
    ld a, $07
    ldh [hGameState], a
    ld a, [wAudioCondition]
    and a
    jr nz, jr_000_1b70

    ld a, $01
    ld [wStateRender], a
    ld a, $f0
    ldh [hTimer1], a

jr_000_1b70:
    call $1ecb
    xor a
    ld [wPlayerY], a
    ld [wSpecialState], a
    ldh [rTMA], a
    ret


ProcessBlockCollision:
    xor a
    ld [wCoinUpdateDone], a
    ldh a, [hPendingCoin]
    and a
    call nz, CollectCoin
    ld hl, hBlockHitType
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
    ld a, [wOamVar2E]
    cp $82
    jr z, jr_000_1baf

    cp $81
    call z, CollectCoin
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

    ld hl, hVramPtrLow
    add hl, de
    ld a, [hl]
    cp $f4
    ret nz

    ld [hl], $2c
    ld a, $05
    ld [wStateBuffer], a
    ld a, h
    ldh [hSpriteAttr], a
    ld a, l
    ldh [hSpriteTile], a
    call GetSpritePosFromTileAddr
    ldh a, [hShadowSCX]
    ld b, a
    ldh a, [hSpriteX]
    sub b
    ldh [hPtrLow], a
    ldh a, [hSpriteY]
    add $14
    ldh [hPtrHigh], a
    ld a, $c0
    ldh [hPtrBank], a
    call CollectCoin
    ret


Jump_000_1bee:
    ld [hl], $03
    jr jr_000_1bb4

jr_000_1bf2:
    call CollectCoin
    ret


CollectCoin:
    ReturnIfLocked

    push de
    push hl
    ld de, POINTS_PER_COIN
    call AddScore
    pop hl
    pop de
    ldh a, [hCoinCount]
    add $01
    daa
    ldh [hCoinCount], a
    and a
    jr nz, UpdateCoinDisplay

    inc a
    ld [wUpdateCounter], a

UpdateCoinDisplay:
    ldh a, [hCoinCount]
    ld b, a
    and $0f
    ld [VRAM_COIN_UNITS], a
    ld a, b
    and $f0
    swap a
    ld [VRAM_COIN_TENS], a
    xor a
    ldh [hPendingCoin], a
    inc a
    ld [wCoinUpdateDone], a
    ret


; =============================================================================
; UpdateLivesDisplay - UpdateLivesDisplay
; =============================================================================
; QUOI : Met à jour l'affichage du compteur de vies/niveau à l'écran.
;
; ALGORITHME :
;   1. Vérifie hUpdateLockFlag == 0 (pas bloqué)
;   2. Vérifie wUpdateCounter ($C0A3) != 0 (update demandée)
;   3. Si wLivesCounter == $99, c'est le max → ne pas incrémenter
;   4. Si wUpdateCounter == $FF, décrémente le compteur (perte de vie)
;   5. Sinon incrémente le compteur (gain de vie) avec DAA (BCD)
;   6. Affiche les chiffres BCD aux positions $9806-$9807
;   7. Si compteur tombe à 0, déclenche état spécial ($39 = game over?)
;   8. Remet wUpdateCounter à 0
;
; ENTRÉE : wUpdateCounter ($C0A3) = direction ($FF=down, autre=up)
; SORTIE : wLivesCounter ($DA15) mis à jour, tilemap modifié
; MODIFIE : A, B
; =============================================================================
UpdateLivesDisplay:
    ReturnIfLocked

    ld a, [wUpdateCounter]
    or a
    ret z

    cp $ff
    ld a, [wLivesCounter]
    jr z, jr_000_1c6c

    cp $99
    jr z, ClearUpdateCounter

    push af
    ld a, $08
    ld [wStateBuffer], a
    ldh [hAudioCh2Param], a
    pop af
    add $01

jr_000_1c49:
    daa
    ld [wLivesCounter], a

DisplayLivesCount:
    ld a, [wLivesCounter]
    ld b, a
    and $0f
    ld [$9807], a
    ld a, b
    and $f0
    swap a
    ld [VRAM_SCORE_POS1], a

ClearUpdateCounter:
    xor a
    ld [wUpdateCounter], a
    ret


jr_000_1c63:
    ld a, $39
    ldh [hGameState], a
    ld [wROMBankInit], a
    jr ClearUpdateCounter

jr_000_1c6c:
    and a
    jr z, jr_000_1c63

    sub $01
    jr jr_000_1c49

; ===========================================================================
; État $39 - Game Over ($1C73)
; Affiche l'écran GAME OVER, sauvegarde score, clear OAM, configure window
; ===========================================================================
State39_GameOver::
    ld hl, $9c00
    ld de, $1cce
    ld b, $11

.loopWriteTile:
    ld a, [de]
    ld c, a

    WAIT_FOR_HBLANK
    WAIT_FOR_HBLANK
    ld [hl], c
    inc l
    inc de
    dec b
    jr nz, .loopWriteTile

    ld a, $10
    ld [wStateRender], a
    ldh a, [hAnimTileIndex]
    ld [wAnimTileIdx], a
    ld a, [wScoreBCD]
    and $f0
    swap a
    ld b, a
    ld a, [wGameConfigA6]
    add b
    cp $0a
    jr c, State39_StoreConfigValue

    ld a, $09

State39_StoreConfigValue:
    ld [wGameConfigA6], a
    ld hl, wOamBuffer
    xor a
    ld b, $a0

State39_ClearOAMBuffer:
    ld [hl+], a
    dec b
    jr nz, State39_ClearOAMBuffer

    ld [wSpecialState], a
    ldh [rTMA], a
    ld hl, $ff4a
    ld [hl], $8f
    inc hl
    ld [hl], $07
    ld a, $ff
    ldh [hOAMIndex], a
    ld hl, hGameState
    inc [hl]
    ret

; === Données texte GAME OVER ($1CCE-$1CDE) ===
; NOTE: Mal désassemblé - 17 bytes pour tilemap window "GAME OVER"
TextData_GameOver:
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
    jr State3B_DecrementCounter

; ===========================================================================
; État $3A - Mise à jour window ($1CDF)
; Vérifie variable player et appelle routine de mise à jour si != 0
; ===========================================================================
State3A_WindowUpdate::
    ld c, $1b
    inc l
    inc l
    ld a, [wPlayerVarAD]
    and a
    call nz, SetupCreditsState
    ret

; ===========================================================================
; État $3B - Setup window finale ($1CE7)
; Copie 9 bytes vers $9C00 (window), active window, configure timer
; ===========================================================================
State3B_WindowSetup::
    ld hl, $9c00
    ld de, $1d0b
    ld c, $09

State3B_CopyWindowData:
    ld a, [de]
    ld b, a

    WAIT_FOR_HBLANK
    ld [hl], b
    inc l
    inc de

State3B_DecrementCounter:
    dec c
    jr nz, State3B_CopyWindowData

    ld hl, $ff40
    set 5, [hl]
    ld a, $a0
    ldh [hTimer1], a
    ld hl, hGameState
    inc [hl]
    ret


    inc l
    dec e
    ld [de], a
    ld d, $0e
    inc l
    ld e, $19
    inc l
    ldh a, [hTimer1]
    and a
    ret nz

    ld a, $01
    ldh [hGameState], a
    ret


ProcessAnimationState:
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
    jr ResetPlayerDirection

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
    ldh a, [hJoypadState]
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

ResetPlayerDirection:
    ld a, [$c207]
    and a
    ret nz

    ld hl, wPlayerDir
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
    ldh a, [hTimerAux]
    cp $02
    jr nz, jr_000_1d9a

    ld a, [de]
    and a
    jr nz, jr_000_1d9a

    ld a, $18
    ld [wPlayerDir], a
    ldh a, [hJoypadState]
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
    call CheckPlayerSideCollision
    and a
    ret nz

    ldh a, [hJoypadState]
    bit 4, a
    jr z, jr_000_1ddb

    ld a, [wPlayerDir]
    cp $18
    jr nz, jr_000_1dcf

    ld a, [wPlayerDir]
    and $f0
    or $01
    ld [wPlayerDir], a

jr_000_1dcf:
    ld hl, $c20c
    ld a, [hl]
    cp $06
    jr z, jr_000_1ddb

    inc [hl]
    inc l
    ld [hl], $10

jr_000_1ddb:
    ld hl, wPlayerState
    ldh a, [hVBlankMode]
    and a
    jr nz, jr_000_1e18

    ld a, [wCollisionFlag]
    cp $07
    jr c, jr_000_1df0

    ldh a, [hShadowSCX]
    and $0c
    jr z, jr_000_1e18

jr_000_1df0:
    ld a, $50
    cp [hl]
    jr nc, jr_000_1e18

    call GetOscillatingOffset
    ld b, a
    ld hl, hShadowSCX
    add [hl]
    ld [hl], a
    call OffsetSpritesY
    call OffsetSpritesX
    ld hl, wOamAttrY
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
    call GetOscillatingOffset
    add [hl]
    ld [hl], a
    ldh a, [hGameState]
    cp $0d
    jr z, jr_000_1e13

    ld a, [wCollisionFlag]
    and a
    jr z, jr_000_1e13

    ldh a, [hShadowSCX]
    and $fc
    ldh [hShadowSCX], a
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

    ld hl, wPlayerDir
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
    call CheckPlayerSideCollision
    and a
    ret nz

    ld hl, wPlayerState
    ld a, [hl]
    cp $0f
    jr c, jr_000_1e96

    push hl
    ldh a, [hJoypadState]
    bit 5, a
    jr z, jr_000_1e8e

    ld a, [wPlayerDir]
    cp $18
    jr nz, jr_000_1e82

    ld a, [wPlayerDir]
    and $f0
    or $01
    ld [wPlayerDir], a

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
    call GetOscillatingOffset
    cpl
    inc a
    add [hl]
    ld [hl], a

jr_000_1e96:
    ld hl, $c20b
    dec [hl]
    ret


OffsetSpritesY:
    ld hl, wSpriteVar31
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


GetOscillatingOffset:
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
    ld hl, wOamVar1C
    ld b, $34
    xor a

jr_000_1ed4:
    ld [hl+], a
    dec b
    jr nz, jr_000_1ed4

    ld hl, wOamBuffer
    ld b, $0b

jr_000_1edd:
    ld [hl+], a
    dec b
    jr nz, jr_000_1edd

    ldh [hObjParamBuf1], a
    ldh [hObjParamBuf2], a
    ldh [hObjParamBuf3], a
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


; =============================================================================
; UpdatePlayerInvulnBlink - Gère le clignotement du joueur pendant l'invulnérabilité
; =============================================================================
; QUOI : Fait clignoter le joueur (toggle Y visible/invisible) pendant
;        la période d'invulnérabilité après avoir pris un dégât.
;
; CONDITIONS :
;   - S'exécute toutes les 4 frames (hFrameCounter & $03 == 0)
;   - wPlayerInvuln > 0 (joueur invulnérable)
;
; ALGORITHME :
;   1. Vérifie si c'est une frame d'update (toutes les 4 frames)
;   2. Si invulnérabilité == 1, la termine
;   3. Sinon décrémente le compteur et toggle la visibilité Y
;   4. Si $dfe9 != 0, garde le joueur visible
;
; SORTIE : wPlayerInvuln mis à jour, wPlayerY togglé pour effet clignotement
; MODIFIE : A
; =============================================================================
UpdatePlayerInvulnBlink:
    ldh a, [hFrameCounter]
    and $03
    ret nz

    ld a, [wPlayerInvuln]
    and a
    ret z

    cp $01
    jr z, .end_invuln

    dec a
    ld [wPlayerInvuln], a
    ld a, [wPlayerY]
    xor $80
    ld [wPlayerY], a
    ld a, [$dfe9]
    and a
    ret nz

.end_invuln:
    xor a
    ld [wPlayerInvuln], a
    ld [wPlayerY], a
    call RenderPlayerUpdate
    ret


ProcessAllObjectCollisions:
    ld b, $01
    ld hl, hObjParamBuf1
    ld de, wOamAttrY

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
    ld a, [wGameVarA9]
    and a
    jr z, jr_000_1f52

    dec a
    ld [wGameVarA9], a
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
    ldh [hSpriteY], a
    pop af
    call CheckTileForCoin
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
    ldh [hSpriteY], a

CheckCoinCollision:
    inc e
    ld a, [de]
    call CheckTileForCoin
    jr c, jr_000_1f89

    ld a, [hl]
    and $f3
    or $08
    ld [hl], a

jr_000_1f89:
    pop bc
    pop de
    pop hl
    call ProcessObjectCollisions
    jr jr_000_1f30

jr_000_1f91:
    ld a, [de]
    inc a
    inc a
    ld [de], a
    cp $a8
    jr nc, jr_000_1f52

    add $04
    ldh [hSpriteY], a
    inc e
    ld a, [de]
    call CheckTileForCoin
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
    ldh [hSpriteY], a
    pop af
    call CheckTileForCoin
    jr c, jr_000_1f6c

    ld a, [hl]
    and $fc
    or $01
    ld [hl], a
    jr jr_000_1f6c

; -----------------------------------------------------------------------------
; CheckTileForCoin - Vérifie si tile est une pièce ($F4) et gère la collecte
; -----------------------------------------------------------------------------
CheckTileForCoin:
    ld b, a
    ldh a, [hShadowSCX]
    add b
    ldh [hSpriteX], a
    push de
    push hl
    call ReadTileUnderSprite
    cp $f4
    jr nz, jr_000_1ff2

    ldh a, [hGameState]
    cp $0d
    jr z, jr_000_1ffc

    push hl
    pop de
    ld hl, hBlockHitType
    ld a, [hl]
    and a
    jr nz, jr_000_1ffc

    ld [hl], $c0
    inc l
    ld [hl], d
    inc l
    ld [hl], e
    ld a, $05
    ld [wStateBuffer], a

jr_000_1ff2:
    cp $82
    call z, HandleBlockCollision
    cp $80
    call z, HandleBlockCollision

jr_000_1ffc:
    pop hl
    pop de
    cp $60
    ret


ProcessObjectCollisions:
    push hl
    push de
    push bc
    ld b, $0a
    ld hl, wObjectBuffer

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
    ldh [hAnimObjSubState], a
    ld a, [de]
    ldh [hTemp2], a
    add $04
    ldh [hParam3], a
    dec e
    ld a, [de]
    ldh [hTemp0], a
    ld a, [de]
    add $03
    ldh [hTemp1], a
    pop hl
    push hl
    call CheckBoundingBoxCollision
    and a
    jr z, jr_000_201b

    dec l
    dec l
    dec l
    call SelectAnimationBank
    push de
    ldh a, [hGameState]

CheckAnimObjectState:
    cp $0d
    jr nz, .not_gameplay

    call HandleGameplayObjectSound
    jr .end_check

.not_gameplay:
    call DecrementObjectAnimationCounter

.end_check:
    pop de
    and a
    jr z, jr_000_201b

    push af
    ld a, [de]
    sub $08
    ldh [hPtrHigh], a
    inc e
    ld a, [de]
    ldh [hPtrLow], a
    pop af
    cp $ff
    jr nz, jr_000_207a

    ld a, $03
    ld [wStateBuffer], a
    ldh a, [hAnimStructBank]
    ldh [hPtrBank], a

jr_000_207a:
    xor a
    ld [de], a
    dec e
    ld [de], a
    ld hl, hObjParamBuf3
    bit 3, e
    jr nz, jr_000_208b

    dec l
    bit 2, e
    jr nz, jr_000_208b

    dec l

jr_000_208b:
    ld [hl], a
    jr jr_000_201b

HandleBlockCollision:
    push hl
    push bc
    push de
    push af
    ldh a, [hGameState]
    cp $0d
    jr nz, jr_000_2105

    push hl
    pop de
    ld hl, hBlockHitType
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

    call PlaySound

jr_000_20b8:
    ld hl, $c210
    ld de, $0010
    ld b, $04

jr_000_20c0:
    push hl
    ld [hl], $00
    inc l
    ldh a, [hSpriteY]
    add $00
    ld [hl], a
    inc l
    ldh a, [hTemp1]
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
    ldh a, [hShadowSCX]
    ldh [hRenderAttr], a
    ld de, $0050
    call AddScore
    ld a, $02
    ld [$dff8], a

jr_000_2105:
    pop af
    pop de
    pop bc
    pop hl
    ret


LoadDemoInput:
    ReturnIfUnlocked

    ld a, [wLevelVarDB]
    ldh [hJoypadState], a
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
    ldh [hScrollPhase], a
    ldh a, [hShadowSCX]
    ld b, a
    ld a, [wGameVarAA]
    cp b
    ret z

    xor a
    ldh [hScrollPhase], a
    ret


UpdateScroll:
    ldh a, [hScrollPhase]
    and a
    jr nz, jr_000_217f

    ldh a, [hShadowSCX]
    and $08
    ld hl, hTemp3
    cp [hl]
    ret nz

    ld a, [hl]
    xor $08
    ld [hl], a
    and a
    jr nz, InitScrollBuffer

    ld hl, wPlayerVarAB
    inc [hl]

InitScrollBuffer:
    ld b, $10
    ld hl, wScrollBuffer
    ld a, TILE_EMPTY

.fill:
    ld [hl+], a
    dec b
    jr nz, .fill

    ldh a, [hTilemapScrollY]
    and a
    jr z, jr_000_21c0

    ldh a, [hTilemapOffsetX]
    ld h, a
    ldh a, [hTilemapOffsetY]
    ld l, a
    jr ProcessScrollEntry

jr_000_21c0:
    ld hl, $4000
    ldh a, [hRenderContext]
    add a
    ld e, a
    ld d, $00
    add hl, de
    ld e, [hl]
    inc hl
    ld d, [hl]
    push de
    pop hl
    ldh a, [hTilemapScrollX]
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
ProcessScrollEntry:
    ld a, [hl+]
    cp $fe
    jr z, jr_000_2227

    ld de, wScrollBuffer
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

    call UpdateTilemapScrolling
    jr ProcessColumnAnimation_End

jr_000_2205:
    cp $80

ProcessColumnAnimation:
    jr nz, .not_5e

    call LoadLevelTilemap
    jr ProcessColumnAnimation_End

.not_5e:
    cp $5f
    jr nz, .not_5f

    call LoadLevelTilemap
    jr ProcessColumnAnimation_End

.not_5f:
    cp $81
    call z, LoadLevelTilemap

ProcessColumnAnimation_End:
    inc e
    dec b
    jr nz, jr_000_21f6

    jr ProcessScrollEntry

jr_000_2222:
    ld hl, wCollisionFlag
    inc [hl]
    ret


jr_000_2227:
    ld a, h
    ldh [hTilemapOffsetX], a
    ld a, l
    ldh [hTilemapOffsetY], a
    ldh a, [hTilemapScrollY]
    inc a
    cp $14
    jr nz, jr_000_2239

    ld hl, hTilemapScrollX
    inc [hl]
    xor a

jr_000_2239:
    ldh [hTilemapScrollY], a
    ldh a, [hShadowSCX]
    ld [wGameVarAA], a
    ld a, $01
    ldh [hScrollPhase], a
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


; =============================================================================
; UpdateScrollColumn - UpdateScrollColumn
; =============================================================================
; QUOI : Met à jour une colonne du tilemap pour le scrolling vertical.
;
; ALGORITHME :
;   1. Vérifie si phase d'update active (hScrollPhase == 1)
;   2. Incrémente la colonne courante ($40-$5F, wrap à $40)
;   3. Copie 16 tiles depuis wScrollBuffer vers le tilemap ($98xx)
;   4. Pour chaque tile, vérifie les valeurs spéciales ($70, $80, $5F, $81)
;      et appelle les handlers appropriés
;   5. Avance de $20 (32) pour passer à la ligne suivante
;   6. Met hScrollPhase à 2 (terminé)
;
; ENTRÉE : hScrollPhase ($FFEA) = 1 pour activer
; SORTIE : hScrollPhase = 2 quand terminé
; MODIFIE : A, B, DE, HL
; =============================================================================
UpdateScrollColumn:
    ldh a, [hScrollPhase]
    cp $01
    ret nz

    ldh a, [hScrollColumn]
    ld l, a
    inc a
    cp $60
    jr nz, jr_000_225e

    ld a, $40

jr_000_225e:
    ldh [hScrollColumn], a
    ld h, $98
    ld de, wScrollBuffer
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

    call ProcessRenderQueue
    jr TilemapScrollLoop

jr_000_227a:
    cp $80
    jr nz, jr_000_2283

    call ApplyLevelConfig
    jr TilemapScrollLoop

jr_000_2283:
    cp $5f
    jr nz, jr_000_228c

    call ApplyLevelConfig
    jr TilemapScrollLoop

jr_000_228c:
    cp $81
    call z, ApplyLevelConfig

TilemapScrollLoop:
    inc e
    push de
    ld de, $0020
    add hl, de
    pop de
    dec b
    jr nz, jr_000_2267

    ld a, $02
    ldh [hScrollPhase], a
    ret


UpdateTilemapScrolling:
    push hl
    push de
    push bc
    ldh a, [hVBlankMode]
    and a
    jr nz, jr_000_22f0

    ldh a, [hCurrentBank]
    ldh [hSavedBank], a
    ld a, $03
    ldh [hCurrentBank], a
    ld [$2000], a
    ldh a, [hRenderContext]
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
    ldh a, [hTilemapScrollX]
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
    ldh a, [hTilemapScrollY]
    inc hl
    cp [hl]
    jr nz, jr_000_22cd

    inc hl
    ld de, hRenderCounter
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
    ldh a, [hSavedBank]
    ldh [hCurrentBank], a
    ld [$2000], a

jr_000_22f0:
    pop bc
    pop de
    pop hl
    ret


ProcessRenderQueue:
    ldh a, [hRenderCounter]
    and a
    ret z

    push hl
    push de
    ld de, hVramPtrLow
    push af
    ld a, h
    add $30
    ld h, a
    pop af
    ld [hl], a
    ldh a, [hRenderMode]
    add hl, de
    ld [hl], a
    ldh a, [$fff6]
    add hl, de
    ld [hl], a
    ldh a, [$fff7]
    add hl, de
    ld [hl], a
    xor a
    ldh [hRenderCounter], a
    ldh [hRenderMode], a
    pop de
    pop hl
    ret


LoadLevelTilemap:
    push hl
    push de
    push bc
    ldh a, [hCurrentBank]
    ldh [hSavedBank], a
    ld a, $03
    ldh [hCurrentBank], a
    ld [$2000], a
    ldh a, [hRenderContext]
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

.search_tilemap:
    ldh a, [hTilemapScrollX]
    cp [hl]
    jr z, .check_y

    ld a, [hl]
    cp $ff
    jr z, .end_load

    inc hl

.skip_entry:
    inc hl
    inc hl
    jr .search_tilemap

.check_y:
    ldh a, [hTilemapScrollY]
    inc hl
    cp [hl]
    jr nz, .skip_entry

    inc hl
    ld a, [hl]
    ld [wLevelConfig - 1], a

.end_load:
    ldh a, [hSavedBank]
    ldh [hCurrentBank], a
    ld [$2000], a
    pop bc
    pop de
    pop hl
    ret


ApplyLevelConfig:
    ld a, [wLevelConfig - 1]
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
    ld [wLevelConfig - 1], a
    pop hl
    ret

; ===========================================================================
; État $0D - Gameplay principal avec objets/ennemis actifs
; C'est le mode de jeu normal où les ennemis et bonus sont mis à jour.
; ===========================================================================
State0D_GameplayFull::
    ldh a, [hPauseFlag]
    and a
    ret nz                       ; Skip si pause

    ; Mise à jour logique du jeu
    call UpdateScroll
    call $4fb2                   ; Bank 1: update level?
    ld a, [wAudioCondition]
    and a
    call nz, TriggerBlockCollisionSound       ; Trigger son si condition
    call UpdateAnimatedObjectState           ; Update collisions?
    call $4fec                   ; Bank 1: update objects?
    call $5118                   ; Bank 1: update sprites?

    ; Bank 3 : mise à jour des 4 slots d'objets
    ldh a, [hCurrentBank]
    ldh [hSavedBank], a
    ld a, $03
    ldh [hCurrentBank], a
    ld [$2000], a
    call $498b                   ; Bank 3: init update
    ld bc, $c218                 ; Slot objet 1
    ld hl, $2164
    call $490d
    ld bc, $c228                 ; Slot objet 2
    ld hl, $2164
    call $490d
    ld bc, $c238                 ; Slot objet 3
    ld hl, $2164
    call $490d
    ld bc, $c248                 ; Slot objet 4
    ld hl, $2164
    call $490d
    call $4aea                   ; Bank 3: finalize
    call $4b8a
    call $4bb5
    ldh a, [hSavedBank]
    ldh [hCurrentBank], a
    ld [$2000], a

    ; Update collision/physics
    call UpdateAudio

    ; Bank 2 : mise à jour spéciale
    ldh a, [hCurrentBank]
    ldh [hSavedBank], a
    ld a, $02
    ldh [hCurrentBank], a
    ld [$2000], a
    call $5844                   ; Bank 2: special update
    ldh a, [hSavedBank]
    ldh [hCurrentBank], a
    ld [$2000], a

    ; Finalize
    call CallBank3Handler
    call $515e                   ; Bank 1: final update
    call UpdatePlayerInvulnBlink  ; Clignotement invulnérabilité

    ; Toggle direction joueur toutes les 4 frames (animation idle)
    ldh a, [hFrameCounter]
    and $03
    ret nz

    ld a, [wPlayerDir]
    xor $01
    ld [wPlayerDir], a
    ret

; =============================================================================
; UpdateAnimTiles - UpdateAnimTiles
; =============================================================================
; QUOI : Met à jour les tiles d'animation (eau, lave, etc.) périodiquement.
;
; CONDITIONS :
;   - wAnimFlag ($D014) != 0 (animation active)
;   - hGameState < $0D (en jeu)
;   - hFrameCounter ($FFAC) & 7 == 0 (toutes les 8 frames)
;
; ALGORITHME :
;   1. Selon bit 3 de hFrameCounter :
;      - Si 1 : lit depuis wAnimBuffer ($C600)
;      - Si 0 : lit depuis table ROM $3FAF (selon hAnimTileIndex)
;   2. Copie 8 octets vers $95D1 (tiles VRAM)
;
; NOTE : Crée l'effet d'animation de l'eau/lave toutes les 8 frames
;        en alternant entre deux frames d'animation.
;
; SORTIE : Tiles VRAM mis à jour
; MODIFIE : A, B, DE, HL
; =============================================================================
UpdateAnimTiles:
    ld a, [wAnimFlag]
    and a
    ret z

    ldh a, [hGameState]
    cp $0d
    ret nc

    ldh a, [hFrameCounter]
    and $07
    ret nz

    ldh a, [hFrameCounter]
    bit 3, a
    jr z, jr_000_2412

    ld hl, $c600
    jr jr_000_2420

jr_000_2412:
    ld hl, ROM_ANIM_TILES
    ldh a, [hAnimTileIndex]
    and $f0
    sub $10
    rrca
    ld d, $00
    ld e, a
    add hl, de

jr_000_2420:
    ld de, VRAM_ANIM_DEST
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
    ld [wPlayerVarAB], a
    call FindAudioTableEntry
    xor a
    ld [wAudioCondition], a
    ld hl, $242d
    ldh a, [hRenderContext]
    ld d, $00
    ld e, a
    add hl, de
    ld a, [hl]
    ld [wAnimFlag], a
    ret


FindAudioTableEntry:
    ld hl, $401a
    ldh a, [hRenderContext]
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
    ld a, [wPlayerVarAB]
    ld b, a

FindAudioTableEntry_SearchLoop:
    ld a, [hl]
    cp b
    jr nc, FindAudioTableEntry_Found

    inc hl
    inc hl
    inc hl
    jr FindAudioTableEntry_SearchLoop

FindAudioTableEntry_Found:
    ld a, l
    ld [wAudioState0], a
    ld a, h
    ld [wAudioState1], a
    ld hl, wObjectBuffer
    ld de, $0010

Jump_000_247e:
    ld [hl], $ff
    add hl, de
    ld a, l
    cp $a0
    jp nz, Jump_000_247e

    ret


UpdateAudio:
    call UpdateAudioState
    call UpdateAllObjectSounds
    call ProcessAudioSlots
    ret


UpdateAudioState:
    ld a, [wAudioState0]
    ld l, a
    ld a, [wAudioState1]
    ld h, a
    ld a, [hl]
    ld b, a
    ld a, [wPlayerVarAB]
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
    ldh [hSoundParam1], a
    ld a, [hl+]
    and $c0
    swap a
    add $d0
    sub c
    ldh [hSoundParam2], a
    call InitSoundConditional
    pop hl
    ld de, $0003
    add hl, de
    ld a, l

StoreAudioState:
    ld [wAudioState0], a
    ld a, h
    ld [wAudioState1], a
    jr UpdateAudioState

LoadQueuedAudioConfig:
    ld a, [wAudioQueueId]
    ldh [hSoundId], a
    cp $ff
    ret z

    ld d, $00
    ld e, a
    rlca
    add e
    rl d
    ld e, a
    ld hl, ROM_AUDIO_CONFIG
    add hl, de
    ld a, [hl+]
    ldh [hSoundCh4], a
    jr InitAudioChannels

InitSoundConditional:
    ldh a, [hLevelIndex]
    and a
    jr nz, jr_000_24ee

    bit 7, [hl]
    ret nz

jr_000_24ee:
    ld a, [hl]
    and $7f
    ldh [hSoundId], a
    ld d, $00
    ld e, a
    rlca
    add e
    rl d
    ld e, a
    ld hl, ROM_AUDIO_CONFIG
    add hl, de
    ld a, [hl]
    ldh [hSoundCh4], a

InitAudioChannels:
    xor a
    ldh [hSoundCh1], a
    ldh [hSoundCh2], a
    ldh [hSoundVar1], a
    ldh [hSoundVar2], a
    ldh [hSoundVar4], a
    ldh a, [hSoundId]
    ld d, $00
    ld e, a
    rlca
    add e
    rl d
    ld e, a
    ld hl, ROM_AUDIO_CONFIG
    add hl, de
    inc hl
    ld a, [hl+]
    ldh [hSoundVar3], a
    ld a, [hl]
    ldh [hSoundVar5], a
    cp $c0
    jr c, jr_000_252b

    ld a, $0b
    ld [wStateRender], a

jr_000_252b:
    ld de, $0010
    ld b, $00
    ld hl, wObjectBuffer

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
    call SaveSoundDataToSlot
    ret


PlaySound:
    ld hl, wAudioBuffer
    ld [hl], a
    ldh a, [hSoundParam1]
    and $f8
    add $07
    ld [wAudioBufVar2], a
    ldh a, [hSoundParam2]
    ld [wAudioBufVar3], a
    call InitSoundSlot
    ld a, $0b
    ld [wStateBuffer], a
    ret


ProcessAudioSlots:
    xor a
    ld [wAudioState2], a
    ld c, $00

jr_000_2565:
    ld a, [wAudioState2]
    cp $14
    ret nc

    push bc
    ld a, c
    swap a
    ld hl, wObjectBuffer
    ld l, a
    ld a, [hl]
    inc a
    jr z, jr_000_2594

    ld a, c
    call LoadSoundDataFromSlot
    ldh a, [hSoundParam2]
    cp $e0
    jr c, jr_000_258b

jr_000_2581:
    ld a, $ff
    ldh [hSoundId], a
    ld a, c
    call SaveSoundDataToSlot
    jr jr_000_2594

jr_000_258b:
    ldh a, [hSoundParam1]
    cp $c0
    jr nc, jr_000_2581

    call ProcessAudioChannelData

jr_000_2594:
    pop bc
    inc c
    ld a, c
    cp $0a
    jr nz, jr_000_2565

    ld hl, wSpriteVar50
    ld a, [wAudioState2]
    rlca
    rlca
    ld d, $00
    ld e, a
    add hl, de

FillAudioBufferLoop:
    ld a, l
    cp $a0
    jp nc, Jump_000_25b6

    ld a, $b4
    ld [hl], a
    inc hl
    inc hl
    inc hl
    inc hl
    jr FillAudioBufferLoop

Jump_000_25b6:
    ret


ProcessAudioChannelData:
    xor a
    ld [wAudioData], a
    ld hl, wSpriteVar50
    ld a, [wAudioState2]
    rlca
    rlca
    ld d, $00
    ld e, a
    add hl, de
    ld b, h
    ld c, l
    ld hl, $2fd9
    ldh a, [hSoundCh2]
    and $01
    jr nz, jr_000_25d5

    ld hl, $30ab

jr_000_25d5:
    ldh a, [hSoundCh3]
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
    ld a, [wAudioState2]
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
    ld [wAudioData], a
    ld a, [hl]
    bit 3, a
    jr z, jr_000_2602

    ldh a, [hSoundParam1]
    sub $08
    ldh [hSoundParam1], a
    ld a, [hl]

jr_000_2602:
    bit 2, a
    jr z, jr_000_260d

    ldh a, [hSoundParam1]
    add $08
    ldh [hSoundParam1], a
    ld a, [hl]

jr_000_260d:
    bit 1, a
    jr z, jr_000_2618

    ldh a, [hSoundParam2]
    sub $08
    ldh [hSoundParam2], a
    ld a, [hl]

jr_000_2618:
    bit 0, a
    jr z, jr_000_2622

    ldh a, [hSoundParam2]
    add $08
    ldh [hSoundParam2], a

jr_000_2622:
    inc hl
    jr jr_000_25e8

jr_000_2625:
    ldh a, [hSoundParam1]
    ld [bc], a
    inc bc
    ldh a, [hSoundParam2]
    ld [bc], a
    inc bc
    ld a, [hl]
    ld [bc], a
    inc bc
    ld a, [wAudioData]
    ld [bc], a
    inc bc
    inc hl
    ld a, [wAudioState2]
    inc a
    ld [wAudioState2], a
    jr jr_000_25e2

UpdateAllObjectSounds:
    ld hl, wObjectBuffer

Jump_000_2642:
    ld a, [hl]
    inc a
    jr z, jr_000_2663

    push hl
    call LoadSoundDataFromHL
    ld hl, $3495
    ldh a, [hSoundId]
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
    call ProcessSoundAnimation
    pop hl
    push hl
    call SaveSoundDataToHL
    pop hl

jr_000_2663:
    ld a, l
    add $10
    ld l, a
    cp $a0
    jp nz, Jump_000_2642

    ret


ProcessSoundAnimation:
Jump_000_266d:
jr_000_266d:
    ldh a, [hSoundVar1]
    and a
    jr z, jr_000_26ac

    ldh a, [hSoundCh4]
    bit 1, a
    jr z, jr_000_2689

    call CheckObjectTileBottomLeft
    jr nc, jr_000_2683

    ldh a, [hSoundParam1]
    inc a
    ldh [hSoundParam1], a
    ret


jr_000_2683:
    ldh a, [hSoundParam1]
    and $f8
    ldh [hSoundParam1], a

jr_000_2689:
    ldh a, [hSoundVar2]
    and $f0
    swap a
    ld b, a
    ldh a, [hSoundVar2]
    and $0f
    cp b
    jr z, jr_000_269e

    inc b
    swap b
    or b
    ldh [hSoundVar2], a
    ret


jr_000_269e:
    ldh a, [hSoundVar2]
    and $0f
    ldh [hSoundVar2], a
    ldh a, [hSoundVar1]
    dec a
    ldh [hSoundVar1], a
    jp Jump_000_2870


Jump_000_26ac:
jr_000_26ac:
    push hl
    ld d, $00
    ldh a, [hSoundCh1]
    ld e, a
    add hl, de
    ld a, [hl]
    ld [wAudioQueueType], a
    cp $ff
    jr nz, jr_000_26c1

    xor a
    ldh [hSoundCh1], a
    pop hl
    jr jr_000_26ac

jr_000_26c1:
    ldh a, [hSoundCh1]
    inc a
    ldh [hSoundCh1], a
    ld a, [wAudioQueueType]
    and $f0
    cp $f0
    jr z, jr_000_26ef

    ld a, [wAudioQueueType]
    and $e0
    cp $e0
    jr nz, jr_000_26e2

    ld a, [wAudioQueueType]
    and $0f
    ldh [hSoundVar1], a
    pop hl
    jr jr_000_266d

jr_000_26e2:
    ld a, [wAudioQueueType]
    ldh [hSoundFlag], a
    ld a, $01
    ldh [hSoundVar1], a
    pop hl
    jp Jump_000_266d


jr_000_26ef:
    ldh a, [hSoundCh1]
    inc a
    ldh [hSoundCh1], a
    inc hl
    ld a, [hl]
    ld [wAudioQueueId], a
    ld a, [wAudioQueueType]
    cp $f8
    jr nz, jr_000_2708

    ld a, [wAudioQueueId]
    ldh [hSoundCh3], a
    pop hl
    jr jr_000_26ac

jr_000_2708:
    cp $f0
    jr nz, jr_000_2784

    ld a, [wAudioQueueId]
    and $c0
    jr z, jr_000_274b

    bit 7, a
    jr z, jr_000_272a

    ldh a, [hSoundCh2]
    and $fd
    ld b, a
    ld a, [wPlayerX]
    ld c, a
    ldh a, [hSoundParam1]
    sub c
    rla
    rlca
    and $02
    or b
    ldh [hSoundCh2], a

jr_000_272a:
    ld a, [wAudioQueueId]
    bit 6, a
    jr z, jr_000_274b

    ld a, [wPlayerState]
    ld c, a
    ldh a, [hSoundParam2]
    ld b, a
    ldh a, [hSoundVar3]
    and $70
    rrca
    rrca
    add b
    sub c
    rla
    and $01
    ld b, a
    ldh a, [hSoundCh2]
    and $fe
    or b
    ldh [hSoundCh2], a

jr_000_274b:
    ld a, [wAudioQueueId]
    and $0c
    jr z, jr_000_275a

    rra
    rra
    ld b, a
    ldh a, [hSoundCh2]
    xor b
    ldh [hSoundCh2], a

jr_000_275a:
    ld a, [wAudioQueueId]
    bit 5, a
    jr z, jr_000_276d

    and $02
    or $fd
    ld b, a
    ldh a, [hSoundCh2]
    set 1, a
    and b
    ldh [hSoundCh2], a

jr_000_276d:
    ld a, [wAudioQueueId]
    bit 4, a
    jr z, jr_000_2780

    and $01
    or $fe
    ld b, a
    ldh a, [hSoundCh2]
    set 0, a
    and b
    ldh [hSoundCh2], a

jr_000_2780:
    pop hl
    jp Jump_000_26ac


jr_000_2784:
    cp $f1
    jr nz, jr_000_2799

    ld a, $0a
    call SaveSoundDataToSlot
    call LoadQueuedAudioConfig
    ld a, $0a
    call LoadSoundDataFromSlot
    pop hl
    jp Jump_000_26ac


jr_000_2799:
    cp $f2
    jr nz, jr_000_27a6

    ld a, [wAudioQueueId]
    ldh [hSoundCh4], a
    pop hl
    jp Jump_000_26ac


jr_000_27a6:
    cp $f3
    jr nz, jr_000_27ce

    ld a, [wAudioQueueId]
    ldh [hSoundId], a
    cp $ff
    jp z, Jump_000_286e

    ld hl, hSoundId
    call InitSoundSlot
    pop hl
    ld hl, $3495
    ldh a, [hSoundId]
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

    ld a, [wAudioQueueId]
    ldh [hSoundVar2], a
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

    ld a, [wPlayerState]
    ld b, a
    ldh a, [hSoundParam2]
    sub b
    add $14
    cp $20
    ld a, [wAudioQueueId]
    dec a
    jr z, jr_000_2801

    ccf

jr_000_2801:
    jr c, jr_000_280b

    ldh a, [hSoundCh1]
    dec a
    dec a
    ldh [hSoundCh1], a
    pop hl
    ret


jr_000_280b:
    pop hl
    jp Jump_000_26ac


jr_000_280f:
    cp $f7
    jr nz, jr_000_2818

    call DestroyAllObjects
    pop hl
    ret


jr_000_2818:
    cp $f9
    jr nz, jr_000_2824

    ld a, [wAudioQueueId]
    ld [$dff8], a
    pop hl
    ret


jr_000_2824:
    cp $fa
    jr nz, jr_000_2830

    ld a, [wAudioQueueId]
    ld [wStateBuffer], a
    pop hl
    ret


jr_000_2830:
    cp $fb
    jr nz, jr_000_284d

    ld a, [wAudioQueueId]
    ld c, a
    ld a, [wPlayerState]
    ld b, a
    ldh a, [hSoundParam2]
    sub b
    cp c
    jr c, jr_000_2849

    xor a
    ldh [hSoundCh1], a
    pop hl
    jp Jump_000_26ac


jr_000_2849:
    pop hl
    jp Jump_000_26ac


jr_000_284d:
    cp $fc
    jr nz, jr_000_285e

    ld a, [wAudioQueueId]
    ldh [hSoundParam1], a
    ld a, $70
    ldh [hSoundParam2], a
    pop hl
    jp Jump_000_26ac


jr_000_285e:
    cp $fd
    jr nz, jr_000_286a

    ld a, [wAudioQueueId]
    ld [wStateRender], a
    pop hl
    ret


jr_000_286a:
    pop hl
    jp Jump_000_26ac


Jump_000_286e:
    pop hl
    ret


Jump_000_2870:
    ldh a, [hSoundFlag]
    and $0f
    jp z, Jump_000_296c

    ldh a, [hSoundCh2]
    bit 0, a
    jr nz, jr_000_28e7

    call CheckObjectTileBase
    jr nc, jr_000_28c5

    ldh a, [hSoundCh4]
    bit 0, a
    jr z, jr_000_288d

    call CheckObjectTileBottom
    jr c, jr_000_28d1

jr_000_288d:
    ldh a, [hSoundFlag]
    and $0f
    ld b, a
    ldh a, [hSoundParam2]
    sub b
    ldh [hSoundParam2], a
    ldh a, [hSoundVar4]
    and a
    jp z, Jump_000_296c

    ld a, [$c205]
    ld c, a
    push bc
    ld a, $20
    ld [$c205], a
    call CheckPlayerSideCollision
    pop bc
    and a
    jr nz, jr_000_28be

    ld a, [wPlayerState]
    sub b
    ld [wPlayerState], a
    cp $0f
    jr nc, jr_000_28be

    ld a, $0f
    ld [wPlayerState], a

jr_000_28be:
    ld a, c
    ld [$c205], a
    jp Jump_000_296c


jr_000_28c5:
    ldh a, [hSoundCh4]
    and $0c
    cp $00
    jr z, jr_000_288d

    cp $04
    jr nz, jr_000_28da

jr_000_28d1:
    ldh a, [hSoundCh2]
    set 0, a
    ldh [hSoundCh2], a
    jp Jump_000_296c


jr_000_28da:
    cp $0c
    jp nz, Jump_000_296c

    xor a
    ldh [hSoundCh1], a
    ldh [hSoundVar1], a
    jp Jump_000_296c


jr_000_28e7:
    call CheckObjectTileRight
    jr nc, jr_000_294f

    ldh a, [hSoundCh4]
    bit 0, a
    jr z, jr_000_28f7

    call CheckObjectTileBottomRight
    jr c, jr_000_295b

jr_000_28f7:
    ldh a, [hSoundFlag]
    and $0f
    ld b, a
    ldh a, [hSoundParam2]
    add b
    ldh [hSoundParam2], a
    ldh a, [hSoundVar4]
    and a
    jr z, UpdatePhysicsCollision

    ld a, [$c205]
    ld c, a
    push bc
    xor a
    ld [$c205], a
    call CheckPlayerSideCollision
    pop bc
    and a
    jr nz, jr_000_293b

    ld a, [wPlayerState]
    add b
    ld [wPlayerState], a
    cp $51
    jr c, jr_000_293b

    ld a, [wCollisionFlag]
    cp $07
    jr nc, jr_000_2941

jr_000_2928:
    ld a, [wPlayerState]
    sub $50
    ld b, a
    ld a, $50
    ld [wPlayerState], a
    ldh a, [hShadowSCX]
    add b
    ldh [hShadowSCX], a
    call OffsetSpritesX

jr_000_293b:
    ld a, c
    ld [$c205], a
    jr UpdatePhysicsCollision

jr_000_2941:
    ldh a, [hShadowSCX]
    and $0c
    jr nz, jr_000_2928

    ldh a, [hShadowSCX]
    and $fc
    ldh [hShadowSCX], a
    jr jr_000_293b

jr_000_294f:
    ldh a, [hSoundCh4]
    and $0c
    cp $00
    jr z, jr_000_28f7

    cp $04
    jr nz, jr_000_2963

jr_000_295b:
    ldh a, [hSoundCh2]
    res 0, a
    ldh [hSoundCh2], a
    jr UpdatePhysicsCollision

jr_000_2963:
    cp $0c
    jr nz, UpdatePhysicsCollision

    xor a
    ldh [hSoundCh1], a
    ldh [hSoundVar1], a

Jump_000_296c:
UpdatePhysicsCollision:
    ldh a, [hSoundFlag]
    and $f0
    jp z, Jump_000_29f4

    ldh a, [hSoundCh2]
    bit 1, a
    jr nz, jr_000_29b8

    call CheckObjectTileTop
    jr nc, jr_000_2998

jr_000_297e:
    ldh a, [hSoundFlag]
    and $f0
    swap a
    ld b, a
    ldh a, [hSoundParam1]
    sub b
    ldh [hSoundParam1], a
    ldh a, [hSoundVar4]
    and a
    jr z, jr_000_29f4

    ld a, [wPlayerX]
    sub b
    ld [wPlayerX], a
    jr jr_000_29f4

jr_000_2998:
    ldh a, [hSoundCh4]
    and $c0
    cp $00
    jr z, jr_000_297e

    cp $40
    jp nz, Jump_000_29ad

    ldh a, [hSoundCh2]
    set 1, a
    ldh [hSoundCh2], a
    jr jr_000_29f4

Jump_000_29ad:
    cp $c0
    jr nz, jr_000_29f4

    xor a
    ldh [hSoundCh1], a
    ldh [hSoundVar1], a
    jr jr_000_29f4

jr_000_29b8:
    call CheckObjectTileBottomLeft
    jr nc, jr_000_29d7

jr_000_29bd:
    ldh a, [hSoundFlag]
    and $f0
    swap a
    ld b, a
    ldh a, [hSoundParam1]
    add b
    ldh [hSoundParam1], a
    ldh a, [hSoundVar4]
    and a
    jr z, jr_000_29f4

    ld a, [wPlayerX]
    add b
    ld [wPlayerX], a
    jr jr_000_29f4

jr_000_29d7:
    ldh a, [hSoundCh4]
    and $30
    cp $00
    jr z, jr_000_29bd

    cp $10
    jr nz, jr_000_29eb

    ldh a, [hSoundCh2]
    res 1, a
    ldh [hSoundCh2], a
    jr jr_000_29f4

jr_000_29eb:
    cp $30
    jr nz, jr_000_29f4

    xor a
    ldh [hSoundCh1], a
    ldh [hSoundVar1], a

Jump_000_29f4:
jr_000_29f4:
    xor a
    ldh [hSoundVar4], a
    ret


GetAnimationDataPointer:
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
    call InitSoundSlot
    ld a, $ff
    pop hl
    ret


CheckObjectBottomCollision:
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
    call InitSoundSlot
    ld a, $ff
    ret


TriggerObjectSound:
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
    call InitSoundSlot
    xor a
    ret


DecrementObjectAnimationCounter:
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
    call InitSoundSlot
    ld a, $ff
    ret


HandleGameplayObjectSound:
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

    ld [wAudioCondition], a

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
    call InitSoundSlot
    ld a, $ff
    ret


LoadAudioSlotConfiguration:
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
    call InitSoundSlot
    ld a, $ff
    ret


DestroyAllObjects:
    ld hl, wObjectBuffer

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
    ldh [hSoundId], a
    xor a
    ldh [hSoundCh1], a

StoreAudioChannel4:
    ldh [hSoundCh4], a
    inc a
    ld [$dff8], a
    ret


    ldh a, [hSoundParam2]
    ld c, a
    ldh a, [hShadowSCX]
    add c
    add $04
    ldh [hSpriteX], a
    ld c, a
    ldh a, [hSoundCh2]
    bit 0, a
    jr jr_000_2b6d

    ldh a, [hSoundVar3]
    and $70
    rrca
    add c
    ldh [hSpriteX], a

jr_000_2b6d:
    ldh a, [hSoundParam1]
    ldh [hSpriteY], a
    call ReadTileUnderSprite
    cp $5f
    ret c

    cp $f0
    ccf
    ret


; -----------------------------------------------------------------------------
; CheckObjectTileBase - Vérifie collision au point de base de l'objet
; -----------------------------------------------------------------------------
; Entrées : hSoundParam1 = Y objet, hSoundParam2 = X objet
; Sortie  : Carry set si tile solide (<$5F) ou spécial (>=$F0)
; -----------------------------------------------------------------------------
CheckObjectTileBase:
    ldh a, [hSoundParam2]
    ld c, a
    ldh a, [hShadowSCX]
    add c
    ldh [hSpriteX], a
    ldh a, [hSoundParam1]
    ldh [hSpriteY], a
    call ReadTileUnderSprite
    cp $5f
    ret c

    cp $f0
    ccf
    ret


; -----------------------------------------------------------------------------
; CheckObjectTileRight - Vérifie collision côté droit de l'objet
; -----------------------------------------------------------------------------
CheckObjectTileRight:
    ldh a, [hSoundParam2]
    ld c, a
    ldh a, [hShadowSCX]
    add c
    add $08
    ld c, a
    ldh a, [hSoundVar3]
    and $70
    rrca
    add c
    sub $08
    ldh [hSpriteX], a
    ldh a, [hSoundParam1]
    ldh [hSpriteY], a
    call ReadTileUnderSprite
    cp $5f
    ret c

    cp $f0
    ccf
    ret


; -----------------------------------------------------------------------------
; CheckObjectTileBottomLeft - Vérifie collision coin bas-gauche de l'objet
; -----------------------------------------------------------------------------
CheckObjectTileBottomLeft:
    ldh a, [hSoundParam2]
    ld c, a
    ldh a, [hShadowSCX]
    add c
    add $04
    ldh [hSpriteX], a
    ld c, a
    ldh a, [hSoundCh2]
    bit 0, a
    jr .setY

    ldh a, [hSoundVar3]
    and $70
    rrca
    add c
    ldh [hSpriteX], a

.setY:
    ldh a, [hSoundParam1]
    add $08
    ldh [hSpriteY], a
    call ReadTileUnderSprite
    cp $5f
    ret c

    cp $f0
    ccf
    ret


; -----------------------------------------------------------------------------
; CheckObjectTileBottom - Vérifie collision bas centre de l'objet
; -----------------------------------------------------------------------------
CheckObjectTileBottom:
    ldh a, [hSoundParam2]
    ld c, a
    ldh a, [hShadowSCX]
    add c
    add $03
    ldh [hSpriteX], a
    ldh a, [hSoundParam1]
    add $08
    ldh [hSpriteY], a
    call ReadTileUnderSprite
    cp $5f
    ret c

    cp $f0
    ccf
    ret


; -----------------------------------------------------------------------------
; CheckObjectTileBottomRight - Vérifie collision coin bas-droit de l'objet
; -----------------------------------------------------------------------------
CheckObjectTileBottomRight:
    ldh a, [hSoundParam2]
    ld c, a
    ldh a, [hShadowSCX]
    add c
    add $05
    ld c, a
    ldh a, [hSoundVar3]
    and $70
    rrca
    add c
    sub $08
    ldh [hSpriteX], a
    ldh a, [hSoundParam1]
    add $08
    ldh [hSpriteY], a
    call ReadTileUnderSprite
    cp $5f
    ret c

    cp $f0
    ccf
    ret


; -----------------------------------------------------------------------------
; CheckObjectTileTop - Vérifie collision haut de l'objet (hauteur variable)
; -----------------------------------------------------------------------------
CheckObjectTileTop:
    ldh a, [hSoundParam2]
    ld c, a
    ldh a, [hShadowSCX]
    add c
    add $04
    ldh [hSpriteX], a
    ld c, a
    ldh a, [hSoundCh2]
    bit 0, a
    jr .calcY

    ldh a, [hSoundVar3]
    and $70
    rrca
    add c
    ldh [hSpriteX], a

.calcY:
    ldh a, [hSoundVar3]
    and $07
    dec a
    swap a
    rrca
    ld c, a
    ldh a, [hSoundParam1]
    sub c
    ldh [hSpriteY], a
    call ReadTileUnderSprite
    cp $5f
    ret c

    cp $f0
    ccf
    ret


    ldh a, [hSoundParam2]
    ld c, a
    ldh a, [hShadowSCX]
    add c
    add $03
    ldh [hSpriteX], a
    ldh a, [hSoundVar3]
    and $07
    dec a
    swap a
    rrca
    ld c, a
    ldh a, [hSoundParam1]
    sub c
    ldh [hSpriteY], a
    call ReadTileUnderSprite
    cp $5f
    ret c

    cp $f0
    ccf
    ret


    ldh a, [hSoundParam2]
    ld c, a
    ldh a, [hShadowSCX]
    add c
    add $05
    ld c, a
    ldh a, [hSoundVar3]
    and $70
    rrca
    sub c
    sub $08
    ldh [hSpriteX], a
    ldh a, [hSoundVar3]
    and $07
    dec a
    swap a
    rrca
    ld c, a
    ldh a, [hSoundParam1]
    sub c
    ldh [hSpriteY], a
    call ReadTileUnderSprite
    cp $5f
    ret c

    cp $f0
    ccf
    ret


OffsetSpritesX:
    ld a, b
    and a
    ret z

jr_000_2c99:
    ldh a, [hSoundParam2]
    sub b
    ldh [hSoundParam2], a
    push hl
    push de
    ld hl, wObjBufferVar03
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


InitSoundSlot:
    push hl
    ld a, [hl]
    ld d, $00

jr_000_2cb6:
    ld e, a
    rlca
    add e
    rl d
    ld e, a
    ld hl, ROM_AUDIO_CONFIG
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


LoadSoundDataFromSlot:
    swap a
    ld hl, wObjectBuffer
    ld l, a

LoadSoundDataFromHL:
    ld de, hSoundId
    ld b, $0d

jr_000_2ce7:
    ld a, [hl+]
    ld [de], a
    inc de
    dec b
    jr nz, jr_000_2ce7

    ret


SaveSoundDataToSlot:
    swap a
    ld hl, wObjectBuffer
    ld l, a

SaveSoundDataToHL:
    ld de, hSoundId
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
    ld de, hParam1
    adc l
    ld bc, hAnimObjCount
    jr nz, @-$71

    ld hl, hAnimObjCount
    sbc e
    rst $38
    sbc l
    ld de, hAnimScaleCounter
    sbc [hl]
    ld de, hAnimStructBank
    rst $28
    ld bc, $01ef
    rst $28
    rst $38
    db $dd
    ld bc, $ffde
    jr nz, @-$61

    ld sp, $0a9d
    sbc l
    ld de, hAnimScaleCounter

jr_000_2d72:
    jr nz, jr_000_2d12

    ld sp, $0a9e
    sbc [hl]
    ld de, hAnimStructBank
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
    ld bc, hTemp1
    db $10
    or c
    ld de, $1ab0
    and c
    ld de, hTemp0
    jr nc, jr_000_2d72

    ld sp, $3ac2
    db $d3
    ld sp, $ffd2
    or d
    ld bc, $0ab3

jr_000_2dba:
    and d
    ld bc, hTemp3
    db $10
    or e
    ld de, $1ab2
    and e
    ld de, hTemp2
    or h
    ld bc, $0ab5
    and h
    ld bc, $ffa5
    db $10
    or l
    ld de, $1ab4
    and l
    ld de, hShadowSCX
    or [hl]
    ld bc, $0ab7
    and [hl]
    ld bc, hTimer2
    db $10
    or a
    ld de, $1ab6
    and a
    ld de, hTimer1
    xor b
    ld bc, hObjParamBuf1
    db $10
    xor c
    ld de, $ffa8
    jr nz, jr_000_2d9c

    ld hl, hObjParamBuf1
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

    ld bc, hSoundFlag
    db $10
    pop de
    ld de, $1ad0
    pop bc
    ld de, hSoundId
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
    ld de, hSoundCh1
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
    ld de, hSoundCh3
    ret z

    ld bc, hSoundVar2
    db $10
    ret


    ld de, hSoundVar1
    jr nz, @-$36

    ld hl, hSoundVar2
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

    ld hl, hSoundCh4
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
    ld [hFrameCounter], sp
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
    ld bc, hObjParamBuf3
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
    ld de, hObjParamBuf2
    jr nz, @-$53

    ld sp, $0aab
    xor e
    ld de, hObjParamBuf3
    cp h
    ld bc, $0abd
    adc $01
    rst $08
    ld a, [bc]
    cp [hl]
    ld bc, $0abf
    xor [hl]
    ld bc, hSpriteTile
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
    ld bc, hOAMIndex
    ld sp, hl
    ld bc, hCoinCount
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
    ld bc, hSpriteTile
    jp z, $cb01

    ld a, [bc]
    call z, $cd01
    ld a, [bc]
    cp h
    ld bc, $ffbd
    ret nc

    ld de, $0ad0
    ret nz

    ld de, hSoundId
    pop de
    ld de, $0ad1
    pop bc
    ld de, hSoundFlag
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

; === Table configuration audio ($336C, 63 bytes) ===
; Format: 3 bytes par son, indexé par sound_id * 3
AudioConfigTable::
    db $06, $11, $00  ; Son 00
    db $02, $11, $00  ; Son 01
    db $01, $11, $00  ; Son 02
    db $00, $11, $00  ; Son 03
    db $07, $11, $00  ; Son 04
    db $02, $11, $00  ; Son 05
    db $00, $22, $00  ; Son 06
    db $00, $91, $00  ; Son 07
    db $09, $33, $c4  ; Son 08
    db $07, $22, $81  ; Son 09
    db $00, $b1, $00  ; Son 0A
    db $00, $b1, $00  ; Son 0B
    db $00, $a1, $00  ; Son 0C
    db $00, $00, $00  ; Son 0D
    db $34, $22, $41  ; Son 0E
    db $02, $21, $00  ; Son 0F
    db $00, $12, $00  ; Son 10
    db $00, $11, $00  ; Son 11
    db $00, $11, $00  ; Son 12
    db $00, $91, $00  ; Son 13
    db $08, $91, $00  ; Son 14
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
    ld bc, hCopyDstHigh
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
    ldh a, [hSoundId]
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

InitLevelData:
    ld hl, wSpriteTemp
    ld b, $20
    xor a

jr_000_3d17:
    ld [hl+], a
    dec b
    jr nz, jr_000_3d17

    ld hl, wLevelData
    ld a, $28
    ld [hl+], a
    xor a
    ld [hl+], a
    ld a, $04
    ld [hl+], a
    call DisplayLevelBCDScore
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


; =============================================================================
; UpdateLevelScore - UpdateLevelScore
; =============================================================================
; QUOI : Met à jour l'affichage du score de niveau à l'écran.
;
; CONDITIONS :
;   - wROMBankInit ($C0A4) == 0 (pas en état spécial)
;   - hGameState < $12 (pas en écran de fin)
;   - wLevelData ($DA00) == $28 (type de niveau spécifique?)
;
; ALGORITHME :
;   Appelle DisplayLevelBCDScore qui affiche le score BCD de $DA01-$DA02
;   aux positions $9831-$9833 du tilemap.
;
; SORTIE : Tilemap mis à jour avec le score
; MODIFIE : A, B, DE
; =============================================================================
UpdateLevelScore:
    ld a, [wROMBankInit]
    and a
    ret nz

    ldh a, [hGameState]
    cp $12
    ret nc

    ld a, [wLevelData]
    cp $28
    ret nz

    call DisplayLevelBCDScore
    ret


DisplayLevelBCDScore:
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


; ===========================================================================
; État $12 - Configuration écran fin de niveau ($3D8E)
; LCD off, clear OAM, fill tilemap avec tiles vides, affiche vies → état $13
; ===========================================================================
State12_EndLevelSetup::
    ld hl, wStateRender
    ld a, $09
    ld [hl], a
    xor a
    ldh [rLCDC], a
    ldh [hShadowSCX], a
    ld hl, wOamBuffer
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
    ld a, [wLivesCounter]
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
    ldh [hGameState], a
    ret

; ===========================================================================
; État $13 - Dessin bordure écran fin ($3DCE)
; Dessine la bordure décorative, texte "BONUS GAME", sélection → état $14
; ===========================================================================
State13_DrawEndBorder::
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
    ldh [hGameState], a
    ret

; ===========================================================================
; État $16 - Copie données tilemap ($3E9E)
; Copie données depuis $DA23 vers tilemap, avec compteur $DA28/$DA29 → état $15
; ===========================================================================
State16_CopyTilemapData::
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
    ldh [hGameState], a
    ret


; -----------------------------------------------------------------------------
; GetTileAddrFromSprite - Convertit coordonnées sprite en adresse tilemap
; -----------------------------------------------------------------------------
; Entrées : hSpriteY, hSpriteX (coordonnées OAM en pixels)
; Sorties : HL = adresse du tile BG sous le sprite
;           hSpriteAttr = H, hSpriteTile = L
; -----------------------------------------------------------------------------
GetTileAddrFromSprite:
    ldh a, [hSpriteY]
    sub $10               ; Retire offset OAM Y
    srl a
    srl a
    srl a                 ; Y pixels → ligne tile (÷8)
    ld de, $0000
    ld e, a
    ld hl, $9800          ; Base tilemap BG
    ld b, $20             ; Largeur = 32 tiles

.multiplyRow:
    add hl, de            ; HL += ligne (×32 via boucle)
    dec b
    jr nz, .multiplyRow

    ldh a, [hSpriteX]
    sub $08               ; Retire offset OAM X
    srl a
    srl a
    srl a                 ; X pixels → colonne tile (÷8)
    ld de, $0000
    ld e, a
    add hl, de            ; Ajoute colonne
    ld a, h
    ldh [hSpriteAttr], a
    ld a, l
    ldh [hSpriteTile], a
    ret


; -----------------------------------------------------------------------------
; GetSpritePosFromTileAddr - Convertit adresse tilemap en coordonnées sprite
; -----------------------------------------------------------------------------
; Entrées : hSpriteAttr/hSpriteTile (adresse tilemap)
; Sorties : hSpriteY, hSpriteX (coordonnées OAM en pixels)
; Note    : Fonction inverse de GetTileAddrFromSprite
; -----------------------------------------------------------------------------
GetSpritePosFromTileAddr:
    ldh a, [hSpriteAttr]
    ld d, a
    ldh a, [hSpriteTile]
    ld e, a
    ld b, $04

.shiftRight:
    rr d
    rr e
    dec b
    jr nz, .shiftRight

    ld a, e
    sub $84
    and $fe
    rlca
    rlca
    add $08
    ldh [hSpriteY], a
    ldh a, [hSpriteTile]
    and $1f
    rla
    rla
    rla
    add $08
    ldh [hSpriteX], a
    ret


;; ==========================================================================
;; UpdateScoreDisplay - Met à jour l'affichage du score dans la tilemap
;; ==========================================================================
;; Appelé par : VBlankHandler
;; Source     : $C0A2 (score en BCD, 3 octets = 6 chiffres)
;; Destination: $9820 (tilemap, ligne du HUD)
;; Format     : BCD → tiles ($00-$09 = chiffres, $2C = espace/zéro leading)
;; ==========================================================================
UpdateScoreDisplay:
    ; --- EarlyReturnChecks ---
    ldh a, [hScoreNeedsUpdate]          ; Flag "needs update" ?
    and a
    ret z                   ; Non → return

    ld a, [wCoinUpdateDone]           ; Flag blocker ?
    and a
    ret nz                  ; Oui → return

    ldh a, [hScrollPhase]          ; État spécial ?
    cp $02
    ret z                   ; Oui → return

    ; --- SetupPointers ---
    ld de, wScoreBCD        ; DE = source (score BCD, high byte first)
    ld hl, VRAM_HUD_LINE    ; HL = destination (tilemap)

;; --- ConvertBCDToTiles ---
;; Convertit 3 octets BCD en 6 tiles avec suppression des zéros de tête
ConvertBCDToTiles:
    xor a
    ldh [hScoreNeedsUpdate], a          ; Clear "needs update" flag
    ld c, $03               ; 3 octets à traiter

BCD_ProcessByte:
    ; --- ProcessHighNibble ---
    ld a, [de]              ; Lire octet BCD
    ld b, a                 ; Sauvegarder dans B
    swap a                  ; High nibble → low nibble
    and $0f                 ; Masquer
    jr nz, BCD_MarkNonZeroHigh      ; Si != 0 → afficher chiffre

    ; Chiffre = 0, vérifier si leading zero
    ldh a, [hScoreNeedsUpdate]          ; Déjà affiché un chiffre non-zéro ?
    and a
    ld a, $00               ; Tile "0"
    jr nz, BCD_WriteTile      ; Oui → afficher "0"

    ld a, $2c               ; Non → afficher espace (leading zero suppression)

BCD_WriteTile:
    ld [hl+], a             ; Écrire tile, avancer

    ; --- ProcessLowNibble ---
    ld a, b                 ; Récupérer octet original
    and $0f                 ; Low nibble
    jr nz, BCD_MarkNonZeroLow      ; Si != 0 → afficher chiffre

    ; Chiffre = 0, vérifier si leading zero
    ldh a, [hScoreNeedsUpdate]          ; Déjà affiché un chiffre non-zéro ?
    and a
    ld a, $00               ; Tile "0"
    jr nz, BCD_WriteLowNibble      ; Oui → afficher "0"

    ; Cas spécial : dernier octet, afficher au moins "0"
    ld a, $01
    cp c                    ; Est-ce le dernier octet ?
    ld a, $00
    jr z, BCD_WriteLowNibble       ; Oui → afficher "0" (pas d'espace)

    ld a, $2c               ; Non → espace (leading zero)

BCD_WriteLowNibble:
    ld [hl+], a             ; Écrire tile, avancer
    dec e                   ; Octet BCD suivant
    dec c                   ; Compteur--
    jr nz, BCD_ProcessByte      ; Boucle 3 fois

    xor a
    ldh [hScoreNeedsUpdate], a          ; Clear flag
    ret

; --- MarkNonZeroSeen (high nibble) ---
BCD_MarkNonZeroHigh:
    push af
    ld a, $01
    ldh [hScoreNeedsUpdate], a          ; Marquer "a vu un chiffre non-zéro"
    pop af
    jr BCD_WriteTile

; --- MarkNonZeroSeen (low nibble) ---
BCD_MarkNonZeroLow:
    push af
    ld a, $01
    ldh [hScoreNeedsUpdate], a          ; Marquer "a vu un chiffre non-zéro"
    pop af
    jr BCD_WriteLowNibble

    ld a, $c0
    ldh [rDMA], a
    ld a, $28

DMA_WaitLoop:
    dec a
    jr nz, DMA_WaitLoop

    ret


; === Données fin de bank 0 ($3F87-$3FFF, 121 bytes) ===

; Données texte/tilemap ($3F87-$3FAE, 40 bytes)
    db $16, $0a, $1b, $12, $18, $2b, $2c, $2c  ; $3F87
    db $2c, $2c, $20, $18, $1b, $15, $0d, $2c  ; $3F8F
    db $1d, $12, $16, $0e, $2c, $2c, $2c, $2c  ; $3F97
    db $2c, $2c, $2c, $2a, $2b, $2c, $2c, $2c  ; $3F9F
    db $01, $29, $01, $2c, $2c, $00, $00, $00  ; $3FA7

; Table animation tiles ($3FAF, 80 bytes)
AnimTilesFrames::
    db $00, $00, $00, $10, $38, $38, $28, $10  ; Frame 0
    db $00, $e0, $b1, $5b, $ff, $ff, $ff, $ff  ; Frame 1
    db $7e, $3c, $18, $00, $00, $81, $42, $a5  ; Frame 2
    db $00, $e1, $33, $de, $ff, $e7, $db, $ff  ; Frame 3
    ds 48, $ff                                  ; Frames 4-9 (padding)

; Padding fin de bank ($3FFF, 1 byte)
    db $ff
