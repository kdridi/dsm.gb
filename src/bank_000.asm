;; ============================================================================
;; ROM Bank 0 - Vecteurs RST et Interruptions ($0000-$00FF)
;; ============================================================================
SECTION "ROM Bank $000", ROM0[$0]

;; ============================================================================
;; RST_00 - Soft Reset Entry Point
;; ============================================================================
;; Description: Vecteur RST $00, point d'entrée principal du programme.
;;              Appelé au démarrage de la Game Boy ou lors d'un reset.
;; In:  Aucun (état initial de la Game Boy)
;; Out: Ne retourne jamais (jump vers SystemInit)
;; Modifie: Tous les registres (via SystemInit)
;; ============================================================================
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

RST_24::
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
; JumpTableDispatcher
; --------------------
; Description: Dispatcher générique de jump table. Utilise A comme index
;              pour sauter vers une entrée dans une table de pointeurs 16-bit.
;              La table doit immédiatement suivre l'appel "rst $28".
; In:  a = index dans la jump table (0, 1, 2...)
; Out: Saute vers l'adresse ciblée (ne retourne jamais)
; Modifie: de, hl
JumpTableDispatcher::
    add a               ; A = A * 2 (car chaque entrée = 2 octets)
    pop hl              ; HL = adresse de retour (= début de la table)
    ld e, a
    ld d, $00           ; DE = offset
    add hl, de          ; HL = table + offset
    ld e, [hl]          ; E = octet bas de l'adresse
    inc hl
    ; Suite dans JumpTableDispatcherContinue...

;; --- RST $30 : Suite du dispatcher ---
; JumpTableDispatcherContinue
; ----------------------------
; Description: Seconde partie du dispatcher (continue depuis RST $28).
;              Charge l'octet haut et effectue le saut.
; In:  hl = pointeur vers octet haut de l'adresse cible, e = octet bas
; Out: Saute vers l'adresse ciblée
; Modifie: de, hl
JumpTableDispatcherContinue::
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
; VBlankInterrupt
; ---------------
; Description: Vecteur d'interruption VBlank. Déclenché quand LY atteint 144.
;              Redirige vers VBlankHandler pour le traitement principal.
; In:  Aucun (interruption matérielle)
; Out: Aucun (jump vers handler)
; Modifie: PC uniquement (jump)
VBlankInterrupt::
    jp VBlankHandler

    ; Padding jusqu'à $0048
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

;; --- INT $48 : LCD STAT Interrupt ---
; LCDCInterrupt
; -------------
; Description: Vecteur d'interruption LCD STAT. Déclenché selon STAT (LYC=LY, mode 0/1/2).
;              Utilisé pour les effets de scanline (scroll, window).
;              Redirige vers LCDStatHandler pour le traitement principal.
; In:  Aucun (interruption matérielle)
; Out: Aucun (jump vers handler)
; Modifie: PC uniquement (jump)
LCDCInterrupt::
    jp LCDStatHandler

    ; Padding jusqu'à $0050
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

;; --- INT $50 : Timer Overflow Interrupt ---
; TimerOverflowInterrupt
; ----------------------
; Description: Handler d'interruption timer overflow (TIMA). Appelle la routine audio en bank 3.
; In:  (none - interrupt context)
; Out: (none)
; Modifie: af (sauvegardé/restauré), bank ROM
; Note: L'interruption Serial ($0058) tombe au milieu du call $7ff0.
;       Ce n'est pas un vrai handler - le jeu n'utilise pas le port série.
TimerOverflowInterrupt::
    push af
    ld a, BANK_AUDIO         ; Bank 3 = audio
    ld [rROMB0], a           ; Switch to audio bank
    call AudioEntryPoint      ; Routine audio en bank 3
    ldh a, [hCurrentBank]    ; Restaurer bank courante
    ld [rROMB0], a
    pop af
    reti


;; ==========================================================================
; VBlankHandler
; ----------------
; Description: Handler principal VBlank, appelé 60 fois par seconde.
;              Sauvegarde contexte, met à jour la logique de jeu (scroll, vies, score, animations),
;              effectue le DMA OAM transfer, incrémente le compteur de frames, gère l'activation
;              du Window selon l'état de jeu, réinitialise le scroll et signale la fin du VBlank.
; In:  (aucun)
; Out: (aucun)
; Modifie: af, bc, de, hl (sauvegardés/restaurés), hFrameCounter, hVBlankFlag, SCX, SCY, LCDC
;
; Structure :
;   1. SaveRegisters      → push af/bc/de/hl
;   2. UpdateGameLogic    → Scroll, vies, score, animations
;   3. DMATransfer        → call $FFB6 (copie OAM depuis wShadowOAM)
;   4. IncrementFrame     → hFrameCounter++
;   5. CheckWindowEnable  → Active Window si game_state == $3A
;   6. ResetScrollAndFlag → SCX/SCY = 0, hVBlankFlag = 1
;   7. RestoreRegisters   → pop + reti
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
    call hDmaRoutine        ; Routine OAM DMA copiée en HRAM

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
    cp GAME_STATE_WINDOW    ; État spécial $3A (window) ?
    jr nz, .resetScrollAndFlag   ; Non → sauter

    ld hl, rLCDC
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
    cp WY_WINDOW_DONE           ; WY == $40 ?
    jr z, LCDStatHandler_WindowDone ; Oui → animation terminée

    dec [hl]                    ; Sinon décrémenter WY
    cp LY_WINDOW_MAX            ; A >= $87 ?

; LCDStat_CheckCarryExit
; ----------------------
; Description: Point d'entrée public - vérifie carry flag et exit si carry clear
; In:  carry = flag à tester (résultat du cp précédent)
;      a = valeur testée (généralement position window)
; Out: Si carry clear (valeur >= seuil) → exit handler
;      Si carry set (valeur < seuil) → continue vers UpdateLYC
; Modifie: rien (saute à Exit ou continue)
LCDStat_CheckCarryExit:
    jr nc, LCDStatHandler_Exit  ; Carry clear → ne pas changer LYC

; LCDStatHandler_UpdateLYC
; ------------------------
; Description: Incrémente LYC de 8 lignes pour animation window (1 tile)
; In:  a = valeur LYC actuelle
; Out: a = nouvelle valeur LYC (ancienne + 8)
; Modifie: a (flow-through vers SetLYC)
LCDStatHandler_UpdateLYC:
    add LYC_SCANLINE_STRIDE     ; Prochaine ligne LYC (+8 = 1 tile)

; LCDStat_SetLYC
; --------------
; Description: Point d'entrée public - écrit la valeur LYC dans le registre hardware et la sauvegarde
; In:  a = nouvelle valeur LYC (ligne de comparaison pour interruption STAT)
; Out: a = inchangé
; Modifie: [rLYC], [wGameConfigA5]
LCDStat_SetLYC:
    ldh [rLYC], a               ; Programmer prochaine interruption
    ld [wGameConfigA5], a       ; Mémoriser pour mode retour

; LCDStatHandler_Exit
; --------------------
; Description: Point de sortie du handler LCD STAT - restaure registres et flow-through vers PopAndReti
; In:  hl = sur la pile (sauvegardé en début de handler)
; Out: rien (flow-through vers LCDStat_PopAndReti)
; Modifie: hl (restauré depuis pile)
LCDStatHandler_Exit:
    pop hl

; LCDStat_PopAndReti
; ------------------
; Description: Point d'entrée public - restaure AF et retourne d'interruption
; In:  af = sur la pile
; Out: rien (retour d'interruption)
; Modifie: af (restauré depuis pile)
LCDStat_PopAndReti:
    pop af
    reti


LCDStatHandler_RestoreMode:
    ; --- Mode retour : désactiver window ---
    ld hl, rLCDC                ; $FF40
    res 5, [hl]                 ; Désactiver Window (bit 5)
    ld a, LYC_TOP_SCREEN
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
    ld a, FLAG_ANIM_DONE
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

; AfterHeader
; -----------
; Description: Point d'entrée après le header ROM. Saute vers l'initialisation système.
; In:  (aucun)
; Out: (ne retourne jamais, saute vers SystemInit)
; Modifie: (aucun avant le saut)
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

; AddScore
; --------
; Description: Ajoute des points au score en notation BCD (Binary-Coded Decimal)
;              et plafonne à 999999 en cas de dépassement
; In:  de = Points à ajouter (format BCD, ex: $0100 = 100 points)
; Out: Aucun
; Modifie: a, hl
; Note: Gère automatiquement la retenue BCD sur 3 octets (6 chiffres décimaux)
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
    ld a, FLAG_FALSE
    adc [hl]
    daa
    ld [hl], a
    ld a, FLAG_UPDATE_NEEDED
    ldh [hScoreNeedsUpdate], a
    ret nc

    ld a, BCD_MAX_DIGIT         ; Score max = 999999 (BCD)
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
; StateDispatcher
; ----------------
; Description: Point d'aiguillage principal du jeu. Dispatche l'exécution vers
;              le handler d'état approprié selon la valeur de hGameState (0-59).
;              Utilise le mécanisme rst $28 avec une jump table de 60 entrées.
; In:  hGameState = index d'état (0-59, lu depuis $FFB3)
; Out: Saute vers le handler correspondant (ne retourne jamais directement)
; Modifie: a, de, hl (via rst $28)
; Appelé par: GameLoop (.callStateHandler)
StateDispatcher:
    ldh a, [hGameState]     ; Charger l'index d'état actuel
    rst $28                 ; → Dispatcher via jump table (voir JumpTableDispatcher)
; === StateDispatcher Jump Table (60 états) ===
; Index = hGameState (0-59), chaque entrée = adresse handler
StateJumpTable:
    dw State00_MainGameplay     ; État $00 - Init/main gameplay
    dw State01_WaitClearObjects ; État $01 - Reset objets
    dw State02_PrepareRender    ; État $02 - Préparation rendu
    dw State03_SetupTransition  ; État $03 - Setup sprites transition
    dw State04_AnimTransition   ; État $04 - Animation transition
    dw State05_SpecialLevel     ; État $05 - Niveau spécial gestion
    dw State06_PostLevel        ; État $06 - Transition post-niveau
    dw State07_WaitBank3        ; État $07 - Attente + bank 3
    dw State08_WorldProgress    ; État $08 - Progression monde/niveau
    dw State09_PipeEnterRight  ; État $09 - Entrée tuyau droite
    dw State0A_LoadSubLevel    ; État $0A - Chargement sous-niveau
    dw State0B_PipeEnterDown   ; État $0B - Descente tuyau
    dw State0C_PipeExitLeft    ; État $0C - Sortie tuyau gauche
    dw State0D_GameplayFull    ; État $0D - Gameplay avec objets
    dw State0E_LevelInit       ; État $0E - Init niveau + HUD
    dw State0F_LevelSelect     ; État $0F - Menu sélection
    dw State10_Noop            ; État $10 - Vide (placeholder)
    dw State11_LevelStart      ; État $11 - Démarrage niveau
    dw State12_EndLevelSetup       ; État $12 - Setup fin de niveau
    dw State13_DrawEndBorder       ; État $13 - Dessin bordure fin
    dw $5832    ; État $14 - (Bank 1, zone données)
    dw $5835    ; État $15 - (Bank 1, zone données)
    dw State16_CopyTilemapData     ; État $16 - Copie données tilemap
    dw $5838    ; État $17 - (Bank 1, zone données)
    dw $583b    ; État $18 - (Bank 1, zone données)
    dw $583e    ; État $19 - (Bank 1, zone données)
    dw $5841    ; État $1A - (Bank 1, zone données)
    dw $0df0    ; État $1B - (décalé d'1 byte par rapport à State1B_BonusComplete)
    dw State1C_WaitTimerGameplay   ; État $1C - Attente timer gameplay
    dw State1D_SetupVRAMPointer    ; État $1D - Setup pointeur VRAM
    dw State1E_ClearTilemapColumn  ; État $1E - Clear colonne tilemap
    dw State1F_EnableVBlankMode    ; État $1F - Active mode VBlank
    dw State20_WaitPlayerPosition  ; État $20 - Attente position joueur
    dw State21_SetupEndCutscene    ; État $21 - Setup cutscene fin
    dw State22_ScrollCutscene      ; État $22 - Scroll cutscene
    dw State23_WalkToDoor          ; État $23 - Marche vers porte
    dw State24_DisplayText         ; État $24 - Affichage texte
    dw State25_SpriteBlinkAnimation ; État $25 - Animation clignotante
    dw State26_PrincessRising      ; État $26 - Princesse montante
    dw State27_PlayerOscillation   ; État $27 - Oscillation joueur
    dw State20_WaitPlayerPosition  ; État $28 - (= État $20)
    dw State29_SetupEndScreen      ; État $29 - Setup écran fin
    dw State2A_DisplayEndText      ; État $2A - Affichage texte fin
    dw State2B_PrincessDescending  ; État $2B - Princesse descendante
    dw State2C_SpriteOscillation   ; État $2C - Oscillation sprite
    dw State2D_DisplayText2        ; État $2D - Affichage texte 2
    dw State2E_DuoAnimation        ; État $2E - Animation duo
    dw State2F_TransferSpriteData  ; État $2F - Transfert données sprite
    dw State30_WalkLeft            ; État $30 - Marche gauche
    dw State31_HorizontalScroll    ; État $31 - Scroll horizontal
    dw State32_CreditsScroll       ; État $32 - Scroll crédits
    dw State33_DisplayCreditsText  ; État $33 - Affichage texte crédits
    dw State34_WaitCreditsCounter  ; État $34 - Attente compteur crédits
    dw State35_WaitTimer           ; État $35 - Attente timer
    dw State36_CreditsFinalTransition ; État $36 - Transition finale crédits
    dw State37_FinalSpriteAnimation ; État $37 - Animation sprite finale
    dw State38_CreditsAnimation    ; État $38 - Animation crédits
    dw State39_GameOver            ; État $39 - Game Over
    dw $1cdf    ; État $3A - (décalé de 4 bytes par rapport à State3A_WindowUpdate)
    dw State3B_WindowSetup         ; État $3B - Setup window

; === Données non référencées ($031E-$0321) ===
; Peut-être du padding ou des données obsolètes
    db $14, $1d, $a4, $06

; ===========================================================================
; État $0E - Initialisation niveau (chargement tiles et HUD)
; LCD off → charge tiles VRAM → configure HUD → LCD on → état $0F
; ===========================================================================
; State0E_LevelInit
; ----------------
; Description: Initialise un niveau - désactive LCD, copie les tiles en VRAM,
;              configure le HUD (MARIO, WORLD, score), et gère les sprites de menu.
; In:  [wLevelType] = index du niveau à charger
; Out: [hGameState] = GAME_STATE_LEVEL_SELECT
; Modifie: af, bc, de, hl, tous les buffers VRAM/OAM
State0E_LevelInit::
    xor a                   ; A = 0 ($AF)
    ldh [rLCDC], a          ; Désactiver LCD
    di
    ldh [hShadowSCX], a
    ld hl, wOamBuffer
    ld b, OAM_BUFFER_SIZE

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
    ld hl, ROM_TILES_MAIN
    ld de, VRAM_TILES_MAIN
    ld bc, SIZE_TILES_MAIN
    call MemCopy
    ld hl, ROM_TILES_AUX
    ld de, VRAM_TILES_AUX
    ld bc, SIZE_TILES_AUX
    call MemCopy
    ld hl, ROM_TILES_LEVEL_1
    ldh a, [hLevelIndex]
    cp WORLD_1                  ; Monde 1 = premier monde
    jr c, SelectLevelAudioTable

    ld hl, ROM_TILES_LEVEL_2

SelectLevelAudioTable:
    ld de, VRAM_TILES_LEVEL
    ld bc, SIZE_TILES_LEVEL
    call MemCopy
    ld hl, ROM_TILES_OBJECTS
    ld de, VRAM_TILES_OBJECTS
    ld bc, SIZE_TILES_OBJECTS
    call MemCopy
    ld hl, ROM_TILES_OBJECTS
    ld de, VRAM_TILES_SPRITES
    ld bc, SIZE_TILES_SPRITES
    call MemCopy
    call ClearBGTilemap
    xor a
    ldh [hTilemapScrollX], a
    ldh a, [hRenderContext]
    push af
    ld a, RENDER_CONTEXT_MAX        ; $0C contexte spécial
    ldh [hRenderContext], a
    call LoadLevelData
    pop af
    ldh [hRenderContext], a
    ld a, TILE_HUD_BORDER
    ld hl, VRAM_BG_BASE
    call FillTilemapRow
    ld hl, VRAM_HUD_MARIO
    ld [hl], TILE_HUD_MARIO_M
    ld hl, VRAM_HUD_COINS
    ld [hl], TILE_HUD_MARIO_A
    inc l
    ld [hl], TILE_HUD_MARIO_R
    inc l
    ld [hl], TILE_HUD_MARIO_I
    ld hl, VRAM_HUD_WORLD
    ld [hl], TILE_HUD_WORLD_W
    inc l
    ld [hl], TILE_HUD_WORLD_O
    inc l
    ld [hl], TILE_HUD_WORLD_R
    ld hl, wScoreBCD
    ld de, wScorePrevious
    ld b, SCORE_BCD_SIZE

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
    ld b, SCORE_BCD_SIZE

CopyScoreBCDPreviousLoop:
    ld a, [hl-]
    ld [de], a
    dec e
    dec b
    jr nz, CopyScoreBCDPreviousLoop

CompareBCDScoresToDisplay:
    ld de, wScorePrevious
    ld hl, VRAM_HIGHSCORE
    call ConvertBCDToTiles
    ld hl, wOamSprite1Y
    ld [hl], SPRITE_Y_MENU
    ld a, [wGameConfigA6]
    and a
    jr z, FinalizeGameStateAfterScore

    ldh a, [hLevelIndex]
    cp LEVEL_THRESHOLD_SPRITES
    jr c, DisplaySpritesForLowLevel

    jr FinalizeGameStateAfterScore

DisplaySpritesForLowLevel:
    ld hl, ROM_MENU_SPRITES
    ld de, VRAM_MENU_DEST
    ld b, SIZE_MENU_SPRITES

CopySpriteDataLoop:
    ld a, [hl+]
    ld [de], a
    inc e
    dec b
    jr nz, CopySpriteDataLoop

    ld hl, wOamBuffer
    ld [hl], OAM_TITLE_SPRITE_Y
    inc l
    ld [hl], OAM_TITLE_SPRITE_X
    inc l
    ld a, [wGameConfigA6]
    ld [hl], a
    inc l
    ld [hl], OAM_ATTR_NORMAL         ; Attributs sprite (palette 0, pas de flip)
    inc l
    ld [hl], OAM_TITLE_SPRITE2_Y

FinalizeGameStateAfterScore:
    inc l
    ld [hl], OAM_TITLE_SPRITE2_X
    inc l
    ld [hl], OAM_TITLE_TILE
    xor a
    ldh [rIF], a
    ld a, LCDC_GAME_STANDARD
    ldh [rLCDC], a
    ei
    ld a, GAME_STATE_LEVEL_SELECT
    ldh [hGameState], a
    xor a
    ldh [hVBlankMode], a
    ld a, ATTRACT_MODE_TIMEOUT
    ld [wAttractModeTimer], a
    ldh [hUpdateLockFlag], a
    ld hl, wCurrentROMBank
    inc [hl]
    ld a, [hl]
    cp ROM_BANK_COUNT
    ret nz

    ld [hl], BANK_0                  ; Reset au bank 0
    ret


    inc c
    jr @+$19

    dec e
    ld [de], a
    rla
    ld e, $0e
    inc l
    dec hl

; StartSelectedLevel
; ------------------
; Description: Lance le niveau sélectionné quand Start est pressé
; In:  wOamSprite1Y = position Y du sprite menu
;      wAnimTileIdx = index de la tuile animée correspondant au niveau
;      wGameConfigA6 = configuration du jeu
; Out: Ne retourne pas (jp vers InitLevelStartFull)
; Modifie: a, e, hAnimTileIndex, hRenderContext
StartSelectedLevel:
    ld a, [wOamSprite1Y]
    cp SPRITE_Y_MENU
    jr z, ResetRenderForHighLevels

    ld a, [wGameConfigA6]
    dec a
    ld [wGameConfigA6], a
    ld a, [wAnimTileIdx]
    ldh [hAnimTileIndex], a
    ld e, $00
    cp ANIM_TILE_W1_L1
    jr z, SelectTileIndexForLevel

    inc e
    cp ANIM_TILE_W1_L2
    jr z, SelectTileIndexForLevel

    inc e
    cp ANIM_TILE_W1_L3
    jr z, SelectTileIndexForLevel

    inc e
    cp ANIM_TILE_W2_L1
    jr z, SelectTileIndexForLevel

    inc e
    cp ANIM_TILE_W2_L2
    jr z, SelectTileIndexForLevel

    inc e
    cp ANIM_TILE_W2_L3
    jr z, SelectTileIndexForLevel

    inc e
    cp ANIM_TILE_W3_L1
    jr z, SelectTileIndexForLevel

    inc e
    cp ANIM_TILE_W3_L2
    jr z, SelectTileIndexForLevel

    inc e
    cp ANIM_TILE_W3_L3
    jr z, SelectTileIndexForLevel

    inc e
    cp ANIM_TILE_W4_L1
    jr z, SelectTileIndexForLevel

    inc e
    cp ANIM_TILE_W4_L2
    jr z, SelectTileIndexForLevel

    inc e

; SelectTileIndexForLevel
; ----------------
; Description: Point de convergence pour la sélection du contexte de rendu.
;              Convertit l'index incrémenté (e) en index de niveau (0-11).
; In:  e = index de niveau calculé (0-11)
; Out: a = e, puis saute vers ApplyRenderContext
; Modifie: a
SelectTileIndexForLevel:
    ld a, e

; ApplyRenderContext
; ----------------
; Description: Applique le contexte de rendu et démarre le niveau complet.
; In:  a = contexte de rendu (index de niveau 0-11)
; Out: Ne retourne pas (jp vers InitLevelStartFull)
; Modifie: hRenderContext
ApplyRenderContext:
    ldh [hRenderContext], a
    jp InitLevelStartFull


; =============================================================================
; ResetRenderForHighLevels
; =============================================================================
; Description: Réinitialise le contexte de rendu pour les niveaux élevés.
;              Si niveau < seuil sprites ($02), réinitialise hAnimTileIndex
;              à $11 et applique contexte rendu 0. Sinon, init complète.
; In:  hLevelIndex = index du niveau courant
; Out: Ne retourne pas (jp vers InitLevelStartFull ou ApplyRenderContext)
; Modifie: a, wGameConfigA6, hAnimTileIndex (si niveau < seuil)
; =============================================================================
ResetRenderForHighLevels:
    xor a
    ld [wGameConfigA6], a
    ldh a, [hLevelIndex]
    cp LEVEL_THRESHOLD_SPRITES
    jp nc, InitLevelStartFull

    ld a, INIT_ANIM_TILE_IDX
    ldh [hAnimTileIndex], a
    xor a
    jr ApplyRenderContext

; =============================================================================
; HandleSelectButtonLevelSelect
; =============================================================================
; Description: Gère le bouton Select dans le menu de sélection de niveau.
;              Toggle la position Y du sprite menu (XOR avec $F8).
; In:  wGameConfigA6 = flag activation (0 = désactivé, autre = activé)
;      wOamSprite1Y = position Y actuelle du sprite
; Out: wOamSprite1Y = position Y modifiée si activé
; Modifie: a, hl
; =============================================================================
HandleSelectButtonLevelSelect:
    ld a, [wGameConfigA6]
    and a
    jr z, UpdateLevelSelectDisplay

    ld hl, wOamSprite1Y
    ld a, [hl]
    xor TOGGLE_SPRITE_Y_MASK
    ld [hl], a
    jr UpdateLevelSelectDisplay

; =============================================================================
; State0F_LevelSelect
; =============================================================================
; Description: Menu de sélection de niveau. Gère l'input joypad (Start/Select/A),
;              met à jour l'affichage des sprites menu (monde-niveau), et lance
;              le mode attract si aucune action après timeout.
; In:  hJoypadDelta = état boutons (edge detect)
;      hLevelIndex = index niveau courant
;      hAnimTileIndex = index tile animation (format $XY: X=monde, Y=niveau)
;      wAttractModeTimer = timer avant mode attract
; Out: hGameState = GAME_STATE_LEVEL_START ($11) si niveau lancé
;      hRenderContext = contexte de rendu mis à jour
; Modifie: a, b, c, de, hl
; =============================================================================
State0F_LevelSelect::
    ldh a, [hJoypadDelta]        ; Joypad state (edge detect)
    ld b, a
    bit 3, b                     ; Start pressé ?
    jr nz, StartSelectedLevel

    bit 2, b                     ; Select pressé ?
    jr nz, HandleSelectButtonLevelSelect

; =============================================================================
; UpdateLevelSelectDisplay
; =============================================================================
; Description: Met à jour l'affichage des sprites du menu de sélection de niveau
;              (monde-niveau). Gère l'animation si bouton A pressé et niveau >= seuil.
; In:  b = état joypad (bit 0 = bouton A)
;      hLevelIndex = index du niveau courant
;      hAnimTileIndex = index tile animation ($XY: X=monde, Y=niveau)
;      hRenderContext = contexte de rendu actuel
; Out: wOamSprite2 à wOamSprite4 = sprites menu configurés (monde, niveau, sélecteur)
;      hAnimTileIndex, hRenderContext = incrémentés si bouton A (avec wrap-around)
; Modifie: a, b, c, hl
; =============================================================================
UpdateLevelSelectDisplay:
    ldh a, [hLevelIndex]
    cp LEVEL_THRESHOLD_SPRITES
    jr c, InitAttractModeDisplay

    bit 0, b
    jr z, AnimRenderContextReady

    ldh a, [hAnimTileIndex]
    inc a
    ld b, a
    and NIBBLE_LOW_MASK              ; Isoler le niveau (bits bas)
    cp ANIM_TILE_LEVELS_PER_WORLD    ; Niveau 4 atteint ?
    ld a, b
    jr nz, SkipAnimTileAdd

    add ANIM_TILE_WORLD_OFFSET       ; Passer au monde suivant niveau 1

SkipAnimTileAdd:
    ldh [hAnimTileIndex], a
    ldh a, [hRenderContext]
    inc a
    cp RENDER_CONTEXT_MAX
    jr nz, AnimRenderContextUpdateDone

    ld a, INIT_ANIM_TILE_IDX
    ldh [hAnimTileIndex], a
    xor a

AnimRenderContextUpdateDone:
    ldh [hRenderContext], a

AnimRenderContextReady:
    ld hl, wOamSprite2
    ldh a, [hAnimTileIndex]
    ld b, SPRITE_Y_MENU
    ld c, a
    and NIBBLE_HIGH_MASK     ; Isoler le monde (bits hauts)
    swap a
    ld [hl], b               ; Sprite 0: Y = SPRITE_Y_MENU
    inc l
    ld [hl], SPRITE_X_LEFT   ; Sprite 0: X = gauche
    inc l
    ld [hl+], a
    inc l
    ld a, c
    and NIBBLE_LOW_MASK      ; Isoler le niveau (bits bas)
    ld [hl], b               ; Sprite 1: Y = SPRITE_Y_MENU
    inc l
    ld [hl], SPRITE_X_RIGHT  ; Sprite 1: X = droite
    inc l
    ld [hl+], a
    inc l
    ld [hl], b               ; Sprite 2: Y = SPRITE_Y_MENU
    inc l
    ld [hl], SPRITE_X_CENTER ; Sprite 2: X = centre
    inc l
    ld [hl], TILE_LEVEL_SELECT

; =============================================================================
; InitAttractModeDisplay
; =============================================================================
; Description: Point d'entrée fall-through qui initialise le mode attract si le
;              timer attract est à 0. Charge les paramètres depuis la table ROM
;              indexée par bank et lance l'état LEVEL_START avec mode attract.
; In:  wAttractModeTimer = timer attract mode (0 = lancer attract)
;      wCurrentROMBank = bank ROM courante (index dans la table)
; Out: Si timer = 0:
;        hAnimTileIndex, hRenderContext = chargés depuis ROM_ATTRACT_INDEX_TABLE
;        wAttractModeTimer = ATTRACT_MODE_LONG ($50)
;        hGameState = GAME_STATE_LEVEL_START ($11)
;        hLevelIndex = 0
; Modifie: a, de, hl
; =============================================================================
InitAttractModeDisplay:
    ld a, [wAttractModeTimer]

InitAttractModeDisplay_CheckTimer:
    and a
    ret nz

    ld a, [wCurrentROMBank]
    sla a
    ld e, a
    ld d, $00
    ld hl, ROM_ATTRACT_INDEX_TABLE
    add hl, de
    ld a, [hl+]
    ldh [hAnimTileIndex], a
    ld a, [hl]
    ldh [hRenderContext], a

; InitLevelStartWithAttractMode
; ------------------------------
; Description: Démarre un niveau avec le mode attract activé (démo auto)
; In:  (aucun)
; Out: (aucun)
; Modifie: a
InitLevelStartWithAttractMode:
    ld a, ATTRACT_MODE_LONG
    ld [wAttractModeTimer], a
    ld a, GAME_STATE_LEVEL_START
    ldh [hGameState], a
    xor a
    ldh [hLevelIndex], a
    ret


; InitLevelStartFull
; ------------------
; Description: Initialisation complète pour démarrer un niveau (état $11)
;              Reset des flags système, config interruptions et état de rendu
; In:  Aucun
; Out: Aucun
; Modifie: a
InitLevelStartFull:
    ld a, GAME_STATE_LEVEL_START
    ldh [hGameState], a          ; Passe en état $11 (Level Start)
    xor a
    ldh [rIF], a                 ; Clear interrupt flags
    ldh [hUpdateLockFlag], a     ; Déverrouille les mises à jour
    ld [wROMBankInit], a         ; Reset bank init à 0
    dec a                        ; a = $FF
    ld [wStateRender], a         ; Force re-render complet
    ld a, IE_VBLANK_STAT_TIMER
    ldh [rIE], a                 ; Active interruptions VBlank+STAT+Timer
    ret

; ROM_ATTRACT_INDEX_TABLE
; -----------------------
; Description: Table des paramètres d'attract mode par ROM bank
;              Chaque entrée contient 2 octets:
;              - Octet 1: hAnimTileIndex (index tile animation)
;              - Octet 2: hRenderContext (contexte de rendu)
; Format: db AnimTileIndex, RenderContext (par bank 0-2)
ROM_ATTRACT_INDEX_TABLE:
    db $11, $00  ; Bank 0: AnimTileIndex=$11, RenderContext=$00
    db $12, $01  ; Bank 1: AnimTileIndex=$12, RenderContext=$01
    db $33, $08  ; Bank 2: AnimTileIndex=$33, RenderContext=$08

; FillTilemapRow
; --------------
; Description: Remplit une ligne de tilemap avec la tile spécifiée
; In:  a = tile à écrire, hl = adresse de début dans la tilemap
; Out: hl = adresse après la ligne (HL + 20)
; Modifie: b
FillTilemapRow:
    ld b, TILEMAP_ROW_WIDTH

.fillTilemapLoop:
    ld [hl+], a
    dec b
    jr nz, .fillTilemapLoop

    ret

; ===========================================================================
; State11_LevelStart
; ------------------
; Description: Initialise le démarrage d'un niveau (reset score, config LCD/timers, init display)
; In:  Aucun
; Out: Aucun
; Modifie: a, bc, de, hl, flags
;
; Étapes:
; 1. Désactive LCD et interruptions
; 2. Reset score (si pas verrouillé par hUpdateLockFlag)
; 3. Charge les tiles du jeu et efface les tilemaps
; 4. Configure le HUD, les timers hardware (LYC=$0F, TAC=16kHz), et la fenêtre
; 5. Initialise les données niveau, l'audio, les animations
; 6. Affiche les vies et pièces
; 7. Fall-through vers State10_Noop (retourne immédiatement)
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
    ld hl, _SCRN1
    ld b, SCRN1_CLEAR_SIZE
    ld a, TILE_EMPTY

.clearTilemapLoop:
    ld [hl+], a
    dec b
    jr nz, .clearTilemapLoop

    call CopyHudTilemap
    ld a, LYC_TOP_SCREEN
    ldh [rLYC], a
    ld a, TAC_ENABLED_16KHZ
    ldh [rTAC], a
    ld hl, rWY              ; Window Y position
    ld [hl], WY_INIT_GAME
    inc l
    ld [hl], WX_INIT_GAME
    xor a
    ldh [rTMA], a
    ldh [rIF], a
    dec a
    ldh [hTimer2], a
    ldh [hScoreNeedsUpdate], a
    ld a, SCROLL_COLUMN_INIT
    ldh [hScrollColumn], a
    call InitAudioAndAnimContext
    call InitLevelData
    call UpdateCoinDisplay
    call DisplayLivesCount
    ldh a, [hAnimTileIndex]
    call LoadAnimTilesByIndex
; ===========================================================================
; State10_Noop
; ------------
; Description: État vide (placeholder) - Retourne immédiatement sans action
; In:  Aucun
; Out: Aucun
; Modifie: Aucun
; ===========================================================================
State10_Noop::
    ret


; ===========================================================================
; ClearBGTilemap
; ----------------
; Description: Efface toute la tilemap background en la remplissant avec le tile vide
; In:  Aucun
; Out: Aucun (_SCRN0 rempli avec TILE_EMPTY)
; Modifie: a, bc, hl
; ===========================================================================
ClearBGTilemap::
    ld hl, _SCRN0 + SCRN_SIZE_MINUS_1 ; Fin de _SCRN0 ($9BFF)
    ld bc, SCRN_SIZE            ; 1024 octets (32×32 tiles)
    ; Fall through vers FillTilemapLoop

; FillTilemapLoop
; ----------------
; Description: Remplit une zone mémoire avec le tile vide en décrémentant
; In:  hl = adresse de fin (inclusif), bc = nombre d'octets
; Out: Aucun (zone remplie avec TILE_EMPTY)
; Modifie: a, bc, hl
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


; MemCopy
; --------
; Description: Copie un bloc mémoire de BC octets de source vers destination
; In:  HL = pointeur source, DE = pointeur destination, BC = nombre d'octets
; Out: HL et DE avancés de BC octets, BC = 0
; Modifie: a, bc, de, hl
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


; LoadGameTiles
; -------------
; Description: Charge les tiles du jeu en VRAM et copie le buffer d'animation
; In:  (aucun)
; Out: (aucun)
; Modifie: a, bc, de, hl
LoadGameTiles:
    ld hl, ROM_GAME_TILES_A
    ld de, VRAM_TILES_OBJECTS
    ld bc, SIZE_GAME_TILES_A
    call MemCopy
    ld hl, ROM_GAME_TILES_B
    ld de, VRAM_TILES_SPRITES
    ld bc, SIZE_GAME_TILES_B
    call MemCopy
    ld hl, ROM_ANIM_BUFFER
    ld de, wAnimBuffer
    ld b, ANIM_BUFFER_COPY_SIZE

LoadGameTiles_TileCopyLoop:
    ld a, [hl+]
    ld [de], a
    inc hl
    inc de
    dec b
    jr nz, LoadGameTiles_TileCopyLoop

    ret


; ===========================================================================
; CopyHudTilemap
; --------------
; Description: Copie les 2 lignes du HUD depuis ROM vers la tilemap VRAM
; In:  Aucun
; Out: Aucun
; Modifie: a, b, de, hl
; ===========================================================================
CopyHudTilemap:
    ld hl, ROM_HUD_TILEMAP
    ld de, VRAM_BG_BASE
    ld b, HUD_LINE_COUNT

.copyHudTilemapLoop:
    ld a, [hl+]
    ld [de], a
    inc e
    ld a, e
    and TILEMAP_COLUMN_MASK      ; Wrap colonne (0-31)
    cp TILEMAP_ROW_WIDTH
    jr nz, .copyHudTilemapLoop

    ld e, TILEMAP_STRIDE
    dec b
    jr nz, .copyHudTilemapLoop

    ret


;; ==========================================================================
;; State00_MainGameplay - Handler d'état $00 ($0610)
;; ==========================================================================
;; Description: Handler principal du gameplay actif. Orchestre les mises à jour
;;              par frame : animations, scroll, collisions, objets, audio.
;;              Switch entre banks 3 et 2 pour appeler les routines spécialisées.
;; In:  rien (lit hGameState implicitement = $00)
;; Out: rien (met à jour l'état complet du jeu via appels multiples)
;; Modifie: a, bc, de, hl (via tous les appels), hCurrentBank, hSavedBank
;; Structure :
;;   1. Init animations et graphiques (UpdateScroll, UpdateAnimatedObjectState)
;;   2. Appels multiples vers bank 3 (init objets wObject1-wObject5)
;;   3. Appels vers bank 2 (UpdateGameTimersAndAnimation)
;;   4. Mise à jour diverses (collisions, animations, audio)
;;   5. Gestion wLevelConfig (décrément si != 0)
;; ==========================================================================
State00_MainGameplay::
    call UpdateScroll
    call UpdateAnimatedObjectState

    ; Switch vers bank 3 pour initialisation objets
    ldh a, [hCurrentBank]
    ldh [hSavedBank], a
    ld a, BANK_AUDIO              ; Bank 3 (aussi utilisé pour objets)
    ldh [hCurrentBank], a
    ld [rROMB0], a

    ; Vérifier état des objets
    call CheckObjectState

    ; Init 5 buffers objets (wObject1-wObject5)
    ; Chaque buffer = 16 bytes, données depuis ROM_OBJECT_INIT_DATA
    ld bc, wObject1
    ld hl, ROM_OBJECT_INIT_DATA
    call ProcessObjectData
    ld bc, wObject2
    ld hl, ROM_OBJECT_INIT_DATA
    call ProcessObjectData
    ld bc, wObject3
    ld hl, ROM_OBJECT_INIT_DATA
    call ProcessObjectData
    ld bc, wObject4
    ld hl, ROM_OBJECT_INIT_DATA
    call ProcessObjectData
    ld bc, wObject5
    ld hl, ROM_OBJECT_INIT_DATA
    call ProcessObjectData

    ; Autres routines bank 3
    call CheckUnlockState
    call ProcessGameStateInput
    call InitRenderLoop
    call CheckBlockCollision
    call CheckPlayerBounds
    call CheckTimerAux1
    call CheckTimerAux2

    ; Restaurer bank
    ldh a, [hSavedBank]
    ldh [hCurrentBank], a
    ld [rROMB0], a

    ; Mises à jour locales
    call ProcessAllObjectCollisions
    call UpdateAudio

    ; Switch vers bank 2
    ldh a, [hCurrentBank]
    ldh [hSavedBank], a
    ld a, BANK_DEMO
    ldh [hCurrentBank], a
    ld [rROMB0], a
    call UpdateGameTimersAndAnimation

    ; Restaurer bank
    ldh a, [hSavedBank]
    ldh [hCurrentBank], a
    ld [rROMB0], a

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
;; State01_WaitClearObjects - Handler d'état $01 ($06A5)
;; ==========================================================================
;; Description: Attente puis reset des objets avant transition vers état $02.
;;              Attend que hTimer1 atteigne 0, puis clear 10 slots d'objets
;;              (marque comme inactifs avec $FF), reset timers auxiliaires,
;;              et transition vers GAME_STATE_PREPARE_RENDER.
;; In:  hTimer1 = timer d'attente
;; Out: hGameState = GAME_STATE_PREPARE_RENDER ($02)
;;      wObjectBuffer = 10 slots marqués SLOT_EMPTY ($FF)
;;      hTimerAux = 0
;;      wUpdateCounter = $FF
;; Modifie: a, b, de, hl
;; ==========================================================================
State01_WaitClearObjects::
    ; Attendre que le timer soit à 0
    ld hl, hTimer1
    ld a, [hl]
    and a
    ret nz                        ; Pas encore → attendre

    ; Clear 10 entrées de wObjectBuffer (16 bytes chacune)
    ; Mettre $FF dans le premier byte de chaque entrée = objet inactif
    ld hl, wObjectBuffer
    ld de, OBJECT_SLOT_SIZE       ; Stride = 16 bytes
    ld b, OBJECT_BUFFER_COUNT     ; 10 objets

.clearLoop:
    ld [hl], SLOT_EMPTY           ; Marquer comme inactif
    add hl, de                    ; Passer à l'entrée suivante
    dec b
    jr nz, .clearLoop

    ; Reset des timers
    xor a
    ldh [hTimerAux], a            ; Timer aux = 0
    dec a                         ; A = $FF
    ld [wUpdateCounter], a        ; Update counter = $FF

    ; Transition vers état $02
    ld a, GAME_STATE_PREPARE_RENDER
    ldh [hGameState], a
    ret


;; ==========================================================================
;; State02_PrepareRender - Handler d'état $02 ($06C5)
;; ==========================================================================
;; State02_PrepareRender
;; ---------------------
;; Description: Désactive LCD, nettoie les buffers écran/sprites, charge le
;;              style du niveau selon le monde actuel, initialise les variables
;;              de jeu et configure le mode gameplay/special selon le contexte.
;; In:  hVBlankMode = flag mode VBlank (0=normal, autre=mode spécial)
;;      hRenderMode = mode rendu alternatif (si VBlank ≠ 0)
;;      hTilemapScrollX = scroll X tilemap pour détecter style niveau
;;      hAnimTileIndex = index tile animation (contient monde+niveau en BCD)
;;      hRenderContext = contexte rendu (RENDER_CONTEXT_GAMEPLAY/SPECIAL)
;; Out: hGameState = GAME_STATE_MAIN ($00) ou GAME_STATE_GAMEPLAY selon contexte
;;      LCD éteint puis rallumé avec LCDC_GAME_STANDARD
;;      Niveau chargé, tilemap initialisé, variables de jeu réinitialisées
;; Modifie: af, bc, de, hl, tous les buffers OAM/tilemap/scroll
;; ==========================================================================
State02_PrepareRender::
    di
    ld a, LCDCF_OFF
    ldh [rLCDC], a
    call ClearOamAndSpriteBuffers
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
    cp LEVEL_STYLE_SPECIAL          ; Style $03 (non décrémenté)
    jr z, StyleLevelAdjusted

    dec a

StyleLevelAdjusted:
    ld bc, ROM_STYLE_LVL_0
    cp LEVEL_GROUP_7_START
    jr c, ApplyLevelStyleConfig

    ld bc, ROM_STYLE_LVL_7
    cp LEVEL_GROUP_11_START
    jr c, ApplyLevelStyleConfig

    ld bc, ROM_STYLE_LVL_11
    cp LEVEL_GROUP_15_START
    jr c, ApplyLevelStyleConfig

    ld bc, ROM_STYLE_LVL_15
    cp LEVEL_GROUP_19_START
    jr c, ApplyLevelStyleConfig

    ld bc, ROM_STYLE_LVL_19
    cp LEVEL_GROUP_23_START
    jr c, ApplyLevelStyleConfig

    ld bc, ROM_STYLE_LVL_23

ApplyLevelStyleConfig:
    ld [hl], b
    inc l
    ld [hl], PLAYER_STATE_CLEAR     ; Clear second byte style
    ld a, c
    ld [wPlayerVarAB], a
    call LoadLevelData
    ld hl, VRAM_WORLD_NUMBER
    ld [hl], TILE_EMPTY
    inc l
    ldh a, [hAnimTileIndex]
    ld b, a
    and NIBBLE_HIGH_MASK         ; Isoler monde (bits hauts)
    swap a
    ld [hl+], a
    ld a, b
    and NIBBLE_LOW_MASK          ; Isoler niveau (bits bas)
    inc l
    ld [hl], a
    ld hl, _SCRN1
    ld de, ROM_TILEMAP_INIT
    ld b, TILEMAP_INIT_SIZE

.copyTilemapInitLoop:
    ld a, [de]
    ld [hl+], a
    inc de
    dec b
    jr nz, .copyTilemapInitLoop

    xor a
    ldh [hGameState], a
    ld [wPlayerInvuln], a
    ld a, LCDC_GAME_STANDARD
    ldh [rLCDC], a
    call RenderPlayerUpdate
    xor a
    ldh [rIF], a
    ldh [hShadowSCX], a
    ld [wCollisionFlag], a
    ldh [hBlockHitType], a
    ld [wSpecialState], a
    ldh [rTMA], a
    ld hl, wLevelBCD1
    ld [hl+], a
    ld [hl], LEVEL_BCD2_INIT
    ld a, LEVEL_DATA_INIT
    ld [wLevelData], a
    ld a, SCROLL_COLUMN_INIT
    ldh [hScrollColumn], a
    ldh a, [hRenderContext]
    ld c, PLAYER_MODE_GAMEPLAY
    cp RENDER_CONTEXT_GAMEPLAY
    jr z, EnterGameplayState

    ld c, PLAYER_MODE_SPECIAL
    cp RENDER_CONTEXT_SPECIAL
    jr nz, ContinueAfterStateSetup

EnterGameplayState:
    ld a, GAME_STATE_GAMEPLAY
    ldh [hGameState], a
    ld a, [wPlayerDir]
    and NIBBLE_HIGH_MASK         ; Garder bits hauts direction
    or c
    ld [wPlayerDir], a

ContinueAfterStateSetup:
    call FindAudioTableEntry
    ei
    ret

;; ==========================================================================
;; Padding/Data zone ($0783-$078B)
;; ==========================================================================
    db $2c, $84, $19, $0a, $1e, $1c, $0e, $84, $2c

;; ==========================================================================
;; RenderPlayerUpdate ($078C)
;; ==========================================================================
;; Description: Met à jour l'état de rendu du joueur selon le contexte actuel
;; In:  hRenderContext = index dans la table de rendu
;;      hRenderCounter = compteur (0 = normal, ≠0 = mode spécial)
;;      wPlayerInvuln = flag d'invulnérabilité
;; Out: wStateRender = nouvel état de rendu
;; Modifie: a, de, hl
;; ==========================================================================
RenderPlayerUpdate:
    ; Si joueur invulnérable, ne pas mettre à jour le rendu
    ld a, [wPlayerInvuln]
    and a
    ret nz

    ; Initialiser la bank audio (bank 3)
    ld a, BANK_AUDIO
    ld [rROMB0], a
    call ROM_INIT_BANK3
    ; Restaurer la bank courante
    ldh a, [hCurrentBank]
    ld [rROMB0], a

    ; Vérifier le compteur de rendu
    ldh a, [hRenderCounter]
    and a
    jr nz, SetStateRenderEnd

    ; Mode normal: chercher l'état de rendu dans la table
    ldh a, [hRenderContext]
    ld hl, RenderContextTable
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ld [wStateRender], a
    ret

SetStateRenderEnd:
    ; Mode spécial: forcer l'état de rendu de fin
    ld a, STATE_RENDER_SPECIAL
    ld [wStateRender], a
    ret

;; ==========================================================================
;; RenderContextTable ($07B7) - Table de contexte de rendu
;; ==========================================================================
;; Description: Table indexée par hRenderContext pour déterminer l'état de
;;              rendu du joueur (wStateRender). Chaque octet correspond à un
;;              contexte de rendu différent (marche, attaque, saut, etc.)
;; In:  Utilisé avec hRenderContext comme index (0-11, soit 12 entrées)
;; Out: Valeur d'état de rendu à stocker dans wStateRender
;; Taille: 12 octets (index 0 à RENDER_CONTEXT_MAX-1)
;; ==========================================================================
RenderContextTable:
    db $07, $07, $03, $08, $08, $05, $07, $03, $03, $06, $06, $05

;; ==========================================================================
;; CheckInputAndPause
;; ==========================================================================
;; Description : Vérifie input pour soft reset ou toggle pause
;;   - Si toutes directions D-pad pressées → SOFT RESET (jp SystemInit)
;;   - Si Start pressé (edge detect) et pas en démo → Toggle pause
;; In  : hJoypadState = état joypad (directions)
;;       hJoypadDelta = changements joypad (edge detect)
;;       hGameState = état du jeu courant
;; Out : hPauseFlag = toggle si pause activée/désactivée
;;       rLCDC bit 5 = Window enable/disable selon état pause
;; Modifie : A, HL
;; ==========================================================================
CheckInputAndPause:
    ; --- CheckSoftReset ---
    ; Si D-pad = $0F (toutes directions), c'est la combo reset
    ldh a, [hJoypadState]          ; Lire joypad (directions)
    and JOYPAD_DPAD_MASK           ; Masquer les 4 bits bas
    cp JOYPAD_ALL_DPAD             ; Toutes les directions ?
    jr nz, CheckStartButtonForPause      ; Non → vérifier pause

    jp SystemInit        ; OUI → SOFT RESET !

; --- CheckStartPressed ---
CheckStartButtonForPause:
    ldh a, [hJoypadDelta]          ; Lire joypad (boutons, edge detect)
    bit 3, a                ; Start pressé (nouveau) ?
    ret z                   ; Non → return

    ; --- CheckCanPause ---
    ldh a, [hGameState]          ; Lire game_state
    cp GAME_STATE_DEMO      ; État >= $0E (démo) ?
    ret nc                  ; Oui → ne peut pas pauser

    ; --- TogglePause ---
    ld hl, rLCDC
    ldh a, [hPauseFlag]          ; Lire flag pause
    xor BIT_0_MASK          ; Toggle (0↔1)
    ldh [hPauseFlag], a          ; Sauvegarder
    jr z, ExitPause       ; Si maintenant 0 → unpause

    ; --- EnterPause ---
    set 5, [hl]             ; Activer Window (afficher "PAUSE")
    ld a, PAUSE_ENTER

SaveAudioStatePause:
    ldh [hSavedAudio], a          ; Sauvegarder état audio ?
    ret

; --- ExitPause ---
ExitPause:
    res 5, [hl]             ; Désactiver Window
    ld a, PAUSE_EXIT
    jr SaveAudioStatePause

; LoadLevelData
; ----------------
; Description: Initialise le niveau en copiant les données ROM vers WRAM et en configurant le scroll
; In:  -
; Out: -
; Modifie: af, bc, de, hl
LoadLevelData:
    ld hl, ROM_LEVEL_INIT_DATA
    ld de, wPlayerY
    ld b, LEVEL_INIT_DATA_SIZE

.loadLevelDataLoop:
    ld a, [hl+]
    ld [de], a
    inc de
    dec b
    jr nz, .loadLevelDataLoop

    ldh a, [hTimerAux]
    and a
    jr z, InitScrollState

    ld a, PLAYER_DIR_RIGHT          ; Direction droite
    ld [wPlayerDir], a

; InitScrollState
; ----------------
; Description: Réinitialise les variables de scroll et remplit le buffer de tilemap
; In:  -
; Out: -
; Modifie: af, bc, de, hl
InitScrollState:
    ld hl, hTilemapScrollY
    xor a
    ld b, SCROLL_VAR_COUNT          ; 6 variables scroll

.clearScrollLoop:
    ld [hl+], a
    dec b
    jr nz, .clearScrollLoop

    ldh [hTemp3], a
    ld [wGameVarAA], a
    ld a, SCROLL_COLUMN_DEFAULT     ; 64 tiles par défaut
    ldh [hScrollColumn], a
    ld b, TILEMAP_VISIBLE_COLS      ; 20 colonnes visibles
    ldh a, [hGameState]
    cp GAME_STATE_PIPE_LOAD         ; État $0A (chargement sous-niveau)
    jr z, .initScrollColumnsLoop

    ldh a, [hRenderContext]
    cp RENDER_CONTEXT_MAX           ; Contexte $0C (wrap-around)
    jr z, .initScrollColumnsLoop

    ld b, TILEMAP_BUFFER_COLS       ; 27 colonnes avec buffer

.initScrollColumnsLoop:
    push bc
    call InitScrollBuffer
    call UpdateScrollColumn
    pop bc
    dec b
    jr nz, .initScrollColumnsLoop

    ret


; UpdateAnimatedObjectState
; -------------------------
; Description: Met à jour l'état des objets animés, gère la détection de collision
;              avec le joueur et déclenche les interactions (coins, ennemis, objets spéciaux)
; In:  hAnimObjCount = nombre d'objets animés restants à traiter
;      wAudioBuffer = buffer des objets actifs (10 slots)
; Out: Interactions traitées (ramassage pièces, dégâts, animations)
; Modifie: a, bc, de, hl, divers flags HRAM (hOAMIndex, hAnimObjCount, etc.)
UpdateAnimatedObjectState::
    ldh a, [hAnimObjCount]
    and a
    jr z, SkipAnimObjectLoop

DecAnimObjCount:
    dec a
    ldh [hAnimObjCount], a

SkipAnimObjectLoop:
    ld de, hCurrentTile
    ld b, OBJECT_BUFFER_COUNT     ; 10 slots à scanner
    ld hl, wAudioBuffer

ScanObjectLoop:
    ld a, [hl]
    cp SLOT_EMPTY
    jr nz, ProcessAudioSlot

NextAudioSlotCheck:
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
    ld bc, OBJ_FIELD_STATE_OFFSET
    add hl, bc
    ld c, [hl]
    inc l
    inc l
    ld a, [hl]
    ldh [hAnimObjSubState], a
    ld a, [wPlayerX]
    ld b, a
    ldh a, [hTimerAux]
    cp TIMER_AUX_PIPE_MODE          ; Mode pipe/transition
    jr nz, AdjustPlayerXForCollision

    ld a, [wPlayerDir]
    cp PLAYER_DIR_LEFT
    jr z, AdjustPlayerXForCollision

    ld a, COLLISION_ADJUST_NEG      ; -2 (ajustement collision droite)
    add b
    ld b, a

AdjustPlayerXForCollision:
    ld a, b

CheckPlayerCollisionWithObject:
    ldh [hTemp0], a
    ld a, [wPlayerX]
    add COLLISION_OFFSET_6      ; +6 pixels pour centrage hitbox
    ldh [hTemp1], a
    ld a, [wPlayerState]
    ld b, a
    sub COLLISION_MARGIN_3      ; -3 pixels marge haute
    ldh [hTemp2], a
    ld a, COLLISION_ADJUST_POS  ; +2 pixels
    add b
    ldh [hParam3], a
    pop hl
    push hl
    call CheckBoundingBoxCollision
    and a
    jp z, NoCollisionReturn

    ldh a, [hOAMAddrLow]
    cp OAM_ADDR_LOW_PLAYER
    jp z, UpdateAnimatedObjectState_ObjectHitDispatch

    ldh a, [hOAMIndex]
    cp OAM_INDEX_COIN
    jp z, UpdateAnimatedObjectState_CoinProceed

    ldh a, [hGameState]
    cp GAME_STATE_GAMEPLAY
    jr z, SkipInvulnCheck

    ld a, [wPlayerInvuln]
    and a
    jr z, ProcessPlayerInteraction

SkipInvulnCheck:
    dec l
    jp PlayerDamageCheckEntry


ProcessPlayerInteraction:
    ld a, [wPlayerState]
    add COLLISION_OFFSET_6      ; +6 pixels bas hitbox
    ld c, [hl]
    dec l
    sub c
    jr c, PlayerInteractionCheckDamage

    ld a, [wPlayerState]
    sub COLLISION_OFFSET_6      ; -6 pixels haut hitbox
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
    ld bc, OBJ_FIELD_STATE_OFFSET
    add hl, bc
    bit 7, [hl]
    pop hl
    jr nz, PlayerInteractionDone

    call SelectAnimationBank
    call GetAnimationDataPointer
    and a
    jr z, PlayerInteractionDone

    ld hl, wPlayerUnk0A
    ld [hl], PLAYER_STATE_CLEAR     ; Reset état
    dec l
    dec l
    ld [hl], PLAYER_ANIM_DEFAULT    ; Frame animation 13
    dec l
    ld [hl], PLAYER_FLAG_ACTIVE     ; Flag actif
    ld hl, wPlayerDir
    ld a, [hl]
    and PLAYER_DIR_HIGH_MASK        ; Masque bits hauts
    or PLAYER_DIR_MODE_INTERACT     ; Mode interaction
    ld [hl], a

SetupAnimationBuffer:
    ld a, STATE_BUFFER_ANIM         ; Buffer animation
    ld [wStateBuffer], a
    ld a, [wPlayerState]
    add PLAYER_ANIM_OFFSET          ; -4 offset
    ldh [hPtrLow], a
    ld a, [wPlayerX]
    sub PLAYER_X_OFFSET             ; -16 pixels
    ldh [hPtrHigh], a
    ldh a, [hAnimStructBank]
    ldh [hPtrBank], a
    ldh a, [hAnimObjCount]
    and a
    jr z, ResetAnimScale

    ldh a, [hAnimScaleCounter]
    cp ANIM_SCALE_MAX               ; Max 3 frames
    jr z, PlayerAnimScaleEntry

    inc a
    ldh [hAnimScaleCounter], a

PlayerAnimScaleEntry:
    ld b, a
    ldh a, [hPtrBank]
    cp ANIM_BANK_SPECIAL            ; Bank spéciale
    jr z, ResetAnimScale

PlayerAnimScaleLoop:
    sla a
    dec b
    jr nz, PlayerAnimScaleLoop

    ldh [hPtrBank], a

AnimObjCountSet:
    ld a, ANIM_OBJ_COUNT_VALUE      ; 50 objets
    ldh [hAnimObjCount], a
    jr PlayerInteractionDone

ResetAnimScale:
    xor a
    ldh [hAnimScaleCounter], a
    jr AnimObjCountSet

PlayerDamageCheckEntry:
PlayerInteractionCheckDamage:
    dec l
    dec l
    ld a, [wPlayerInvuln]
    and a
    jr nz, LoadAudioAndSetupAnim

    ldh a, [hTimerAux]
    cp TIMER_AUX_DAMAGE_MAX         ; Seuil dégâts
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


NoCollisionReturn:
    pop hl
    pop bc
    jp NextAudioSlotCheck


StartGameplayPhaseJump:
    call StartGameplayPhase
    jr PlayerInteractionDone

LoadAudioAndSetupAnim:
    call LoadAudioSlotConfiguration
    and a
    jr z, PlayerInteractionDone

    jr SetupAnimationBuffer

UpdateAnimatedObjectState_ObjectHitDispatch:
    ldh a, [hOAMIndex]
    cp OBJ_TYPE_COIN
    jr z, ObjectInteraction_CoinHit

    cp OBJ_TYPE_ENEMY
    jr z, ObjectInteraction_EnemyHit

    cp OBJ_TYPE_SPECIAL
    jr z, ObjectInteraction_SpecialHit

    cp OBJ_TYPE_DOOR
    jr nz, PlayerInteractionDone

    ldh a, [hTimerAux]
    cp TIMER_AUX_PIPE_MODE          ; Mode pipe/transition
    jr nz, ObjectInteraction_SetupTimer

    ldh [hSubState], a

ObjectInteraction_SetupStateBuffer:
    ld a, STATE_BUFFER_OBJECT       ; Buffer objet
    ld [wStateBuffer], a

ObjectInteraction_SetupAnimBank:
    ld a, ANIM_BANK_OBJECT          ; Bank objets
    ldh [hPtrBank], a

ObjectInteraction_CalcAnimPtr:
    ld a, [wPlayerState]
    add PLAYER_ANIM_OFFSET          ; -4 offset
    ldh [hPtrLow], a
    ld a, [wPlayerX]
    sub PLAYER_X_OFFSET             ; -16 pixels
    ldh [hPtrHigh], a

ObjectInteraction_MarkSpriteHandled:
    dec l
    dec l
    dec l
    ld [hl], SLOT_EMPTY             ; Marquer slot vide
    jr PlayerInteractionDone

ObjectInteraction_CoinHit:
    ldh a, [hTimerAux]
    cp TIMER_AUX_PIPE_MODE          ; Mode pipe/transition
    jr z, ObjectInteraction_SetupAnimBank

ObjectInteraction_SetupTimer:
    ld a, PLAYER_FLAG_ACTIVE        ; Timer actif
    ldh [hTimerAux], a
    ld a, ATTRACT_MODE_LONG         ; 80 frames délai coin
    ldh [hTimer1], a
    jr ObjectInteraction_SetupStateBuffer

ObjectInteraction_EnemyHit:
    ld a, PLAYER_INVULN_TIMER
    ld [wPlayerInvuln], a
    ld a, STATE_RENDER_DAMAGE
    ld [wStateRender], a
    jr ObjectInteraction_SetupAnimBank

ObjectInteraction_SpecialHit:
    ld a, BANK_NONE
    ldh [hPtrBank], a
    ld a, GAME_STATE_CENTER
    ld [wStateBuffer], a
    ld a, FLAG_UPDATE_NEEDED
    ld [wUpdateCounter], a
    jr ObjectInteraction_CalcAnimPtr

UpdateAnimatedObjectState_CoinProceed:
    ldh [hPendingCoin], a
    ld a, STATE_BUFFER_COIN
    ld [wStateBuffer], a
    jr ObjectInteraction_MarkSpriteHandled

; StartGameplayPhase
; ------------------
; Description: Initialise la phase de gameplay après avoir pris des dégâts
; In:  Aucun
; Out: Aucun
; Modifie: a
StartGameplayPhase:
    ld a, TIMER_AUX_DAMAGE_MAX
    ldh [hTimerAux], a           ; Réinitialise timer invulnérabilité
    xor a
    ldh [hSubState], a           ; Reset sous-état
    ld a, TIMER_GAMEPLAY_DELAY
    ldh [hTimer1], a             ; Configure délai gameplay (80 frames)
    ld a, GAME_STATE_POST_LEVEL
    ld [wStateBuffer], a         ; Prépare transition post-niveau
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
    ld a, GAME_STATE_SETUP_TRANSITION
    ldh [hGameState], a          ; game_state = $03

    ; --- ResetTimerAndVariables ---
    xor a
    ldh [hSubState], a          ; Variable = 0
    ldh [rTMA], a           ; Timer Modulo = 0 (désactive timer)

    ld a, STATE_RENDER_INIT
    ld [wStateRender], a           ; Variable WRAM = $02

    ; --- InitPlayerState ---
    ld a, PLAYER_Y_INIT
    ld [wPlayerY], a           ; Player state = $80

    ld a, [wPlayerX]           ; Lire position/état
    ld [wLevelVarDD], a           ; Copier vers variable de travail
    ret


; SelectAnimationBank
; --------------------
; Description: Sélectionne la bank ROM d'animation selon les bits hauts de hAnimObjSubState
;              Transforme bits 7-6 en index 0-3 pour lire AnimBankTable ($0A20)
; In:  hAnimObjSubState = sous-état animation objet (bits 7-6 utilisés)
; Out: hAnimStructBank = bank ROM sélectionnée ($01/$04/$08/$50)
; Modifie: a
SelectAnimationBank:
    push hl
    push de
    ldh a, [hAnimObjSubState]
    and ANIM_SUBSTATE_MASK      ; Garde bits 7-6 uniquement ($C0)
    swap a                       ; Décalage de 4 bits
    srl a                        ; Puis encore 2 bits → index 0-3
    srl a
    ld e, a
    ld d, $00
    ld hl, AnimBankTable
    add hl, de
    ld a, [hl]
    ldh [hAnimStructBank], a
    pop de
    pop hl
    ret

; AnimBankTable
; --------------
; Description: Table de mapping bits 7-6 de hAnimObjSubState vers numéros de bank ROM
; Format: 4 bytes, indexée par (hAnimObjSubState & $C0) >> 6
;         Index 0 (%00xxxxxx) → bank $01
;         Index 1 (%01xxxxxx) → bank $04
;         Index 2 (%10xxxxxx) → bank $08
;         Index 3 (%11xxxxxx) → bank $50
; Utilisée par: SelectAnimationBank ($0A07)
AnimBankTable:
    db $01, $04, $08, $50

; HandleObjectAnimationOnBlockHit
; --------------------------------
; Description: Déclenche l'animation d'un objet quand le joueur frappe un bloc (via saut)
; In:  hBlockHitType = type de bloc frappé (0=rien, $c0=spécial, autres=normal)
;      wPlayerX, wPlayerState = position du joueur
;      wObjectBuffer = table des objets actifs
; Out: hPtrLow, hPtrHigh, hPtrBank = coordonnées collision si détectée
; Modifie: a, bc, de, hl
HandleObjectAnimationOnBlockHit:
    ldh a, [hBlockHitType]
    and a
    ret z

    cp BLOCK_HIT_TYPE_SPECIAL
    ret z

    ld de, OBJECT_SLOT_SIZE       ; 16 bytes par slot
    ld b, OBJECT_BUFFER_COUNT     ; 10 slots
    ld hl, wObjectBuffer

FindObjectLoop:
    ld a, [hl]
    cp SLOT_EMPTY
    jr nz, ProcessFoundObject

NextObjectSlotCheck:
    add hl, de
    dec b
    jr nz, FindObjectLoop

    ret


ProcessFoundObject:
    push bc
    push hl
    ld bc, OBJ_FIELD_STATE_OFFSET
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
    ld a, OBJECT_COLLISION_RANGE ; Distance max collision (20 pixels)
    sub b
    jr c, ContinueObjectScan

    cp COLLISION_THRESHOLD_7    ; Seuil collision 7 pixels
    jr nc, ContinueObjectScan

    inc l
    ld a, c
    and ANIM_HEIGHT_MASK
    swap a
    ld c, a
    ld a, [hl]

Loop_AddValueByEight:
    add TILE_SIZE_PIXELS        ; Ajouter 8 pixels (1 tile)
    dec c
    jr nz, Loop_AddValueByEight

    ld c, a
    ld b, [hl]
    ld a, [wPlayerState]
    sub COLLISION_OFFSET_6      ; -6 pixels haut hitbox
    sub c
    jr nc, ContinueObjectScan

    ld a, [wPlayerState]
    add COLLISION_OFFSET_6      ; +6 pixels bas hitbox
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
    add PLAYER_ANIM_OFFSET      ; -4 ajustement animation
    ldh [hPtrLow], a
    ld a, [wPlayerX]
    sub PLAYER_X_OFFSET         ; -16 pixels décalage X
    ldh [hPtrHigh], a
    ldh a, [hAnimStructBank]
    ldh [hPtrBank], a

ContinueObjectScan:
    pop hl
    pop bc
    jp NextObjectSlotCheck


; CheckBoundingBoxCollision
; -------------------------
; Description: Teste collision AABB (Axis-Aligned Bounding Box) entre deux hitboxes rectangulaires.
;              Vérifie chevauchement sur axes X et Y avec calcul de dimensions multi-tiles.
;              Algorithme: test séparation X (gauche/droite), puis Y (haut/bas).
; In:  hl = pointeur objet+2 (position X objet), c = config (nibble bas=largeur tiles, bits 4-6=hauteur tiles)
;      hTemp0 = position X joueur gauche, hTemp1 = position X joueur droite
;      hParam3 = position Y joueur haut, hTemp2 = position Y joueur bas
; Out: a = RETURN_TRUE ($01) si collision détectée, $00 sinon
; Modifie: a, b, l
CheckBoundingBoxCollision:
    inc l
    inc l
    ld a, [hl]
    add TILE_SIZE_PIXELS        ; Décalage hitbox (8 pixels = 1 tile)
    ld b, a
    ldh a, [hTemp0]
    sub b
    jr nc, ReturnZero

    ld a, c
    and NIBBLE_LOW_MASK          ; Isoler nibble bas = largeur en tiles
    ld b, a
    ld a, [hl]

    ; Calcule position X droite objet: X_pos + (largeur_tiles - 1) * 8
CalculateObjectRightEdge:
    dec b
    jr z, .done

    sub TILE_SIZE_PIXELS        ; Soustraire 8 pixels (1 tile)
    jr CalculateObjectRightEdge

.done:
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
    and ANIM_HEIGHT_MASK
    swap a
    ld b, a
    ld a, [hl]

Loop_AddValueByEightV2:
    add TILE_SIZE_PIXELS        ; Ajouter 8 pixels (1 tile)
    dec b
    jr nz, Loop_AddValueByEightV2

    ld b, a
    ldh a, [hTemp2]
    sub b
    jr nc, ReturnZero

    ld a, RETURN_TRUE
    ret


; ReturnZero
; ----------
; Description: Routine utilitaire retournant RETURN_FALSE (0).
;              Point de sortie commun pour CheckBoundingBoxCollision en cas
;              de non-collision détectée.
; In:  Aucun
; Out: a = RETURN_FALSE (0)
; Modifie: a
ReturnZero:
    xor a                       ; RETURN_FALSE
    ret


; CheckPlayerObjectCollision
; --------------------------
; Description: Vérifie collision joueur avec tous objets actifs dans le buffer.
;              Parcourt les 10 slots, teste AABB (Axis-Aligned Bounding Box),
;              applique knockback si collision détectée.
; In:  wPlayerUnk07 = état joueur (vérifie si au sol)
;      wPlayerX, wPlayerState = position joueur
;      wObjectBuffer = buffer 10 objets (16 bytes chacun)
; Out: Pas de valeur retour explicite
;      wPlayerX = ajusté si collision (knockback -10px)
;      wPlayerUnk07-0A = réinitialisés
;      Objet+9 = flag collision activé
; Modifie: a, bc, de, hl
CheckPlayerObjectCollision:
    ld a, [wPlayerUnk07]
    cp PLAYER_UNK07_GROUNDED
    ret z

    ld de, OBJECT_SLOT_SIZE       ; 16 bytes par slot
    ld b, OBJECT_BUFFER_COUNT     ; 10 slots
    ld hl, wObjectBuffer

CheckCollisionLoop:
    ld a, [hl]
    cp SLOT_EMPTY
    jr nz, CheckCollisionObjectPath

CheckCollisionLoop_NextObject:
    add hl, de
    dec b
    jr nz, CheckCollisionLoop

    ret


CheckCollisionObjectPath:
    push bc
    push hl
    ld bc, OBJ_FIELD_STATE_OFFSET
    add hl, bc
    bit 7, [hl]
    jp z, CollisionCheckFailed_Restart

    ld a, [hl]
    and NIBBLE_LOW_MASK          ; Isoler nibble bas
    ldh [hTemp0], a
    ld bc, hVBlankSelector
    add hl, bc
    ldh a, [hTemp0]
    ld b, a
    ld a, [hl]

SubtractPositionOffset:
    dec b
    jr z, CheckCollisionXAxisPath

    sub TILE_SIZE_PIXELS        ; Soustraire 8 pixels (1 tile)
    jr SubtractPositionOffset

CheckCollisionXAxisPath:
    ld c, a
    ldh [hTemp0], a
    ld a, [wPlayerX]
    add COLLISION_OFFSET_6      ; +6 pixels centrage hitbox
    ld b, a
    ld a, c
    sub b
    cp COLLISION_THRESHOLD_7    ; Seuil 7 pixels
    jr nc, CollisionCheckFailed

    inc l
    ld a, [wPlayerState]
    ld b, a
    ld a, [hl]
    sub b
    jr c, CheckCollisionYAxisPath

    cp COLLISION_MARGIN_3       ; Marge 3 pixels
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
    and ANIM_HEIGHT_MASK
    swap a
    ld b, a
    pop hl
    ld a, [hl]

AddHeightOffset:
    add TILE_SIZE_PIXELS        ; Ajouter 8 pixels (1 tile)
    dec b
    jr nz, AddHeightOffset

    ld b, a
    ld a, [wPlayerState]
    sub b
    jr c, ApplyCollisionKnockback

    cp COLLISION_MARGIN_3       ; Marge 3 pixels
    jr nc, CollisionCheckFailed

ApplyCollisionKnockback:
    dec l
    ldh a, [hTemp0]
    sub COLLISION_KNOCKBACK     ; Knockback 10 pixels
    ld [wPlayerX], a
    push hl
    dec l
    dec l
    call GetAnimationDataPointer
    pop hl
    ld bc, OBJECT_OFFSET_09     ; Offset +9 dans structure
    add hl, bc
    ld [hl], FLAG_TRUE          ; Activer le flag
    xor a
    ld hl, wPlayerUnk07
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], FLAG_TRUE          ; wPlayerUnk0A = actif
    ld hl, wPlayerUnk0C
    ld a, [hl]
    cp COLLISION_THRESHOLD_7    ; Vérifie si >= 7
    jr c, CollisionBoundsCheckEnd

    ld [hl], COLLISION_OFFSET_6 ; Limite à 6

CollisionBoundsCheckEnd:
    pop hl
    pop bc
    ret


CollisionCheckFailed_Restart:
CollisionCheckFailed:
    pop hl
    pop bc
    jp CheckCollisionLoop_NextObject


;; ==========================================================================
;; State03_SetupTransition - Handler d'état $03 ($0B84)
;; ==========================================================================
;; Description: Configure 4 sprites OAM pour un effet visuel de transition.
;;              Place deux tuiles de transition (normale + flip) formant un
;;              motif 2×2, puis passe à l'état animation ($04).
;; In:  wLevelVarDD = Position Y de référence
;;      wPlayerState = Position X du joueur
;; Out: hGameState = GAME_STATE_ANIMATION ($04)
;;      wGameVarAC, hTimerAux, hRenderCounter = 0
;; Modifie: A, BC, DE, HL, appelle ClearOamAndSpriteBuffers
;; ==========================================================================
State03_SetupTransition::
    ; Configurer 4 sprites OAM pour effet de transition
    ld hl, wOamVar0C
    ld a, [wLevelVarDD]
    ld c, a
    sub TILE_SIZE_PIXELS          ; Décalage Y sprite (8 pixels)
    ld d, a
    ld [hl], a                    ; Sprite 0: Y
    inc l
    ld a, [wPlayerState]
    add SPRITE_X_OFFSET_NEG       ; Décalage X sprite (-8)
    ld b, a
    ld [hl+], a                   ; Sprite 0: X
    ld [hl], TILE_TRANSITION_A    ; Sprite 0: tile
    inc l
    ld [hl], OAM_ATTR_NORMAL      ; Sprite 0: attr
    inc l
    ld [hl], c                    ; Sprite 1: Y
    inc l
    ld [hl], b                    ; Sprite 1: X
    inc l
    ld [hl], TILE_TRANSITION_B    ; Sprite 1: tile
    inc l
    ld [hl], OAM_ATTR_NORMAL      ; Sprite 1: attr
    inc l
    ld [hl], d                    ; Sprite 2: Y
    inc l
    ld a, b
    add TILE_SIZE_PIXELS          ; Décalage X sprite (8 pixels)
    ld b, a
    ld [hl+], a                   ; Sprite 2: X
    ld [hl], TILE_TRANSITION_A    ; Sprite 2: tile
    inc l
    ld [hl], OAM_ATTR_X_FLIP      ; Sprite 2: attr (flipped)
    inc l
    ld [hl], c                    ; Sprite 3: Y
    inc l
    ld [hl], b                    ; Sprite 3: X
    inc l
    ld [hl], TILE_TRANSITION_B    ; Sprite 3: tile
    inc l
    ld [hl], OAM_ATTR_X_FLIP      ; Sprite 3: attr (flipped)

    ; Transition vers état $04
    ld a, GAME_STATE_ANIMATION
    ldh [hGameState], a
    xor a
    ld [wGameVarAC], a
    ldh [hTimerAux], a
    ldh [hRenderCounter], a
    call ClearOamAndSpriteBuffers
    ret


;; State04_AnimTransition
;; ----------------
;; Description: Gère l'animation de transition des sprites en modifiant leur position Y
;;              selon une table de vitesses. Utilisé pour faire descendre des sprites
;;              hors de l'écran avec accélération progressive.
;; In:  wGameVarAC = index dans la table de vitesses (incrémenté à chaque frame)
;;      wOamVar0C = buffer OAM des sprites à animer (4 sprites)
;;      wSpecialState = détermine l'état suivant après animation
;; Out: Sprites déplacés, état changé si animation terminée
;; Modifie: A, B, C, D, E, HL
State04_AnimTransition::
    ld a, [wGameVarAC]
    ld e, a
    inc a
    ld [wGameVarAC], a
    ld d, $00
    ld hl, ROM_ANIM_TRANSITION_TABLE
    add hl, de
    ld b, [hl]
    ld a, b
    cp ANIM_TRANSITION_END_MARKER
    jr nz, UpdateSpriteAnimationPath

    ld a, [wGameVarAC]
    dec a
    ld [wGameVarAC], a
    ld b, ANIM_TRANSITION_DEFAULT

;; UpdateSpriteAnimationPath
;; ----------------
;; Description: Applique le déplacement Y (dans B) aux 4 sprites OAM du buffer wOamVar0C
;;              Vérifie si les sprites sont sortis de l'écran (Y >= $B4)
;; In:  B = déplacement Y à ajouter à chaque sprite
;;      wOamVar0C = buffer OAM de 4 sprites (16 bytes)
;; Out: Sprites déplacés, peut changer hGameState si sortie écran
;; Modifie: A, C, HL, DE
UpdateSpriteAnimationPath:
    ld hl, wOamVar0C
    ld de, OAM_ENTRY_SIZE
    ld c, OAM_ENTRY_SIZE

SpriteAnimationOAMLoop:
    ld a, b
    add [hl]
    ld [hl], a
    add hl, de
    dec c
    jr nz, SpriteAnimationOAMLoop

    cp SPRITE_Y_THRESHOLD_EXIT
    ret c

    ld a, [wSpecialState]
    cp SLOT_EMPTY
    jr nz, SetGameStateSpecialPath

    ld a, GAME_STATE_WINDOW_UPDATE
    jr SetGameStateValue

; SetGameStateSpecialPath
; -----------------------
; Description: Configure timer spécial et passe à l'état RESET
; In:  aucun
; Out: hTimer1 = TIMER_SPECIAL_PATH (144 frames), hGameState = GAME_STATE_RESET
; Modifie: a
SetGameStateSpecialPath:
    ld a, TIMER_SPECIAL_PATH
    ldh [hTimer1], a
    ld a, GAME_STATE_RESET

; SetGameStateValue
; -----------------
; Description: Écrit la valeur de 'a' dans hGameState (point d'entrée partagé)
; In:  a = nouvelle valeur de game state
; Out: hGameState = a
; Modifie: aucun
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

;; AnimTransitionTableData
;; ----------------
;; Description: Table des vitesses d'animation pour State04_AnimTransition.
;;              Chaque byte indique le déplacement Y à appliquer par frame.
;;              Séquence d'accélération progressive avec pause initiale
;;              Le marqueur $7F indique la fin (vitesse maintenue)
;; Utilisé par: State04_AnimTransition ($0BCD)
;; Taille: 21 bytes
AnimTransitionTableData:
    db $00, $00, $ff, $00, $00, $00  ; Pause initiale (2 frames) puis recul $FF puis pause (3 frames)
    db $01, $00, $00, $01, $00, $01  ; Accélération très progressive
    db $01, $01, $01, $01, $01, $01  ; Vitesse constante $01
    db $01, $01, $7f                  ; Continue puis marqueur fin (ANIM_TRANSITION_END_MARKER)

;; ==========================================================================
;; State07_WaitBank3 - Handler d'état $07 ($0C37)
;; ==========================================================================
;; Description: Handler d'état $07 - Gère l'attente et la transition vers
;;              le niveau spécial. Appelle la logique bank 3 pendant le timer,
;;              puis passe à l'état SPECIAL_LEVEL ($05). Cas spécial pour W4-L3
;;              qui passe directement à POST_LEVEL ($06).
;; In:  hTimer1 = timer d'attente
;;      wAudioCondition = condition audio (si 0, réinitialise timer)
;;      hAnimTileIndex = index tuile animation (détection style/niveau)
;; Out: hGameState = GAME_STATE_SPECIAL_LEVEL ou GAME_STATE_POST_LEVEL
;; Modifie: a, hl, wSpecialState, rTMA
;; ==========================================================================
State07_WaitBank3::
    ld hl, hTimer1
    ld a, [hl]
    and a
    jr z, .timerDone

    call SwitchBankAndCallBank3Handler
    ret


.timerDone:
    ld a, [wAudioCondition]
    and a
    jr nz, .skipTimerInit

    ld a, TIMER_STATE07_WAIT
    ldh [hTimer1], a

.skipTimerInit:
    ld a, GAME_STATE_SPECIAL_LEVEL
    ldh [hGameState], a
    xor a
    ld [wSpecialState], a
    ldh [rTMA], a
    ldh a, [hAnimTileIndex]
    and NIBBLE_LOW_MASK
    cp LEVEL_STYLE_SPECIAL
    ret nz

    call DestroyAllObjects
    ldh a, [hAnimTileIndex]
    cp ANIM_TILE_W4_L3
    ret nz

    ld a, GAME_STATE_POST_LEVEL
    ldh [hGameState], a
    ret


; State05_SpecialLevel - Handler d'état $05 ($0C6A)
; ----------------
; Description: Gère la logique du niveau spécial (niveau 3). Si le niveau actuel
;              est le niveau spécial et que le timer expire, met à jour l'audio,
;              switch vers bank 2 pour animer, ajoute bonus, et gère transition.
; In:  hAnimTileIndex = index du niveau actuel (nibble bas)
;      hTimer1 = timer de la frame
;      wLevelBCD1 = compteur niveau BCD (2 octets)
; Out: hGameState = peut être modifié vers GAME_STATE_POST_LEVEL ($06)
;      hTimer1 = peut être modifié vers TIMER_TRANSITION_LEVEL ou FLAG_TRUE
; Modifie: a, b, de, hl, wPlayerVarAB, wLevelData, wSpecialState, wStateBuffer
State05_SpecialLevel::
    ldh a, [hAnimTileIndex]
    and NIBBLE_LOW_MASK          ; Isoler niveau (bits bas)
    cp LEVEL_INDEX_SPECIAL
    jr nz, .notSpecialLevel

    xor a
    ld [wPlayerVarAB], a
    call UpdateAudio

.notSpecialLevel:
    ldh a, [hTimer1]
    and a
    ret nz

    ld hl, wLevelBCD1
    ld a, [hl+]
    ld b, [hl]
    or b
    jr z, .levelCompleted

    ld a, FLAG_TRUE
    ld [wLevelData], a
    ldh a, [hCurrentBank]
    ldh [hSavedBank], a
    ld a, BANK_DEMO
    ldh [hCurrentBank], a
    ld [rROMB0], a
    call UpdateGameTimersAndAnimation
    ldh a, [hSavedBank]
    ldh [hCurrentBank], a
    ld [rROMB0], a
    ld de, SCORE_BONUS_10
    call AddScore
    ld a, FLAG_TRUE
    ldh [hTimer1], a
    xor a
    ld [wSpecialState], a
    ld a, [wLevelBCD1]
    and FLAG_TRUE
    ret nz

    ld a, STATE_BUFFER_SPECIAL
    ld [wStateBuffer], a
    ret


.levelCompleted:
    ld a, GAME_STATE_POST_LEVEL
    ldh [hGameState], a
    ld a, TIMER_TRANSITION_LEVEL
    ldh [hTimer1], a
    ret


; State06_PostLevel
; -----------------
; Description: Transition post-niveau - détermine l'état suivant selon le niveau complété et la position du joueur
;              Attend expiration du timer puis route vers: niveau spécial ($1C), zone centrale ($08), ou zone extérieure ($12)
; In:  hTimer1 = timer de transition, hAnimTileIndex = niveau actuel, wPlayerX = position X du joueur
; Out: hGameState = nouvel état ($1C, $08, ou $12), hCurrentBank = bank chargée (2 ou 3)
; Modifie: a, hl
State06_PostLevel::
    ldh a, [hTimer1]
    and a
    ret nz

    xor a
    ld [wSpecialState], a
    ldh [rTMA], a
    ldh a, [hAnimTileIndex]
    and NIBBLE_LOW_MASK          ; Isoler niveau (bits bas)
    cp LEVEL_INDEX_SPECIAL
    ld a, GAME_STATE_SPECIAL      ; État $1C si niveau spécial
    jr z, State06_PostLevel_SpecialLevel

    ; Vérifier position X du joueur
    ld a, [wPlayerX]
    cp PLAYER_X_LEFT

CheckPlayerCenterPosition:
    jr c, State06_PostLevel_SwitchBank2

    cp PLAYER_X_RIGHT
    jr nc, State06_PostLevel_SwitchBank2

    ld a, GAME_STATE_CENTER       ; État $08 si position centrale
    jr State06_PostLevel_SetNextState

State06_PostLevel_SwitchBank2:
    ld a, BANK_DEMO
    ldh [hCurrentBank], a
    ld [rROMB0], a
    ld a, GAME_STATE_OUTER        ; État $12 si hors centre

State06_PostLevel_SetNextState:
    ldh [hGameState], a
    ret


State06_PostLevel_SpecialLevel:
    ldh [hGameState], a
    ld a, BANK_AUDIO
    ld [rROMB0], a
    ldh [hCurrentBank], a
    ld hl, hRenderContext
    ld a, [hl]
    ldh [hOAMIndex], a
    ld [hl], STATE_RENDER_DAMAGE ; Mode rendu collision ($0C)
    inc l
    xor a
    ld [hl+], a
    ld [hl+], a
    ldh [hTemp3], a
    inc l
    inc l
    ld a, [hl]
    ldh [hVramPtrLow], a
    ld a, TIMER_CUTSCENE_6
    ldh [hTimer1], a
    ldh a, [hAnimTileIndex]
    and NIBBLE_HIGH_MASK
    cp ANIM_TILE_WORLD_4_NIBBLE
    ret nz

    xor a
    ldh [hOAMIndex], a
    ld a, FLAG_TRUE
    ld [wAudioSaveDE], a
    ld a, VRAM_DEST_CUTSCENE_HIGH
    ldh [hOAMAddrLow], a
    ld a, TIMER_CUTSCENE_LONG
    ldh [hTimer1], a
    ld a, GAME_STATE_INIT27
    ldh [hGameState], a
    call ROM_INIT_BANK3
    ret


; LoadGameTilesWithBank
; ----------------
; Description: Charge les tiles du jeu depuis une bank spécifique puis initialise le gameplay
; In:  c = numéro de bank ROM à charger (BANK_1, BANK_2, BANK_3)
; Out: (passe au GameplayInitStart)
; Modifie: a, bc, de, hl (via LoadGameTiles et GameplayInitStart)
LoadGameTilesWithBank:
    di
    ld a, c
    ld [rROMB0], a
    ldh [hCurrentBank], a
    xor a
    ldh [rLCDC], a
    call LoadGameTiles
    jp GameplayInitStart


;; ==========================================================================
;; State08_WorldProgress - Handler d'état $08 ($0D40)
;; ==========================================================================
;; Description: Gère la progression monde/niveau et charge les ressources
;;              graphiques selon le monde actuel (tiles, palettes, animations)
;; In:  hTimer1 = timer de délai
;;      wStateEnd = flag de fin de niveau
;;      hRenderContext = contexte de rendu actuel (0-11)
;;      hAnimTileIndex = index monde/niveau (nibble haut=monde, nibble bas=niveau)
;; Out: hGameState = GAME_STATE_PREPARE_RENDER ($02)
;;      hRenderContext = incrémenté avec wrap à RENDER_CONTEXT_MAX ($0C)
;;      hAnimTileIndex = incrémenté (wrap niveau 4→monde suivant niveau 1)
;; Modifie: a, b, c, d, e, h, l
;; ==========================================================================
State08_WorldProgress::
    ld hl, hTimer1
    ld a, [hl]
    and a
    ret nz

    ld a, [wStateEnd]
    and a
    ret nz

    ldh a, [hRenderContext]
    inc a
    cp RENDER_CONTEXT_MAX           ; $0C wrap-around
    jr nz, IncrementRenderContextPath

    xor a

IncrementRenderContextPath:
    ldh [hRenderContext], a
    ldh a, [hAnimTileIndex]
    inc a
    ld b, a
    and NIBBLE_LOW_MASK              ; Isoler le niveau (bits bas)
    cp ANIM_TILE_LEVELS_PER_WORLD    ; Niveau 4 atteint ?
    ld a, b
    jr nz, UpdateAnimationTileIndexPath

    add ANIM_TILE_WORLD_OFFSET       ; Passer au monde suivant niveau 1

UpdateAnimationTileIndexPath:
    ldh [hAnimTileIndex], a

; LoadAnimTilesByIndex
; --------------------
; Description: Charge les tiles animées et palettes selon l'index du monde
;              Extrait le numéro de monde depuis hAnimTileIndex et charge les
;              ressources graphiques appropriées depuis la bank correspondante
; In:  a = AnimTileIndex (déjà chargé depuis hAnimTileIndex)
; Out: VRAM chargé avec tiles monde, palette, et buffer animation
; Modifie: af, bc, de, hl
LoadAnimTilesByIndex:
    and NIBBLE_HIGH_MASK     ; Isoler le monde (bits hauts)
    swap a
    cp WORLD_1              ; Monde 1 ?
    ld c, BANK_2            ; Bank 2 pour monde 1
    jr z, LoadGameTilesWithBank

    cp WORLD_2              ; Monde 2 ?
    ld c, BANK_1            ; Bank 1 pour monde 2
    jr z, LoadAnimTilesWithBank

    cp WORLD_3              ; Monde 3 ?
    ld c, BANK_3            ; Bank 3 pour monde 3
    jr z, LoadAnimTilesWithBank

    ld c, BANK_1            ; Bank 1 par défaut (monde 4+)

; LoadAnimTilesWithBank
; ----------------------
; Description: Charge les tiles animées, palettes et buffer d'animation depuis une bank spécifique puis initialise le gameplay
; In:  a = numéro de monde (WORLD_1, WORLD_2, etc.)
;      c = numéro de bank ROM à charger (BANK_1, BANK_2, BANK_3)
; Out: (passe au GameplayInitStart)
; Modifie: a, bc, de, hl (copie tiles, palette et buffer animation vers VRAM/WRAM)
LoadAnimTilesWithBank:
    ld b, a
    di
    ld a, c
    ld [rROMB0], a
    ldh [hCurrentBank], a
    xor a
    ldh [rLCDC], a
    ld a, b
    dec a
    dec a
    sla a
    ld d, $00
    ld e, a
    ld hl, GraphicsTableA       ; Table pointeurs tiles monde ($0DE4)
    push de
    add hl, de
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, VRAM_WORLD_TILES     ; Destination tiles monde ($8A00)

CopyPatternTileDataLoop:
    ld a, [de]
    ld [hl+], a
    inc de
    push hl
    ld bc, VRAM_WORLD_OVERFLOW  ; Overflow check fin copie ($7230)
    add hl, bc
    pop hl
    jr nc, CopyPatternTileDataLoop

    pop de
    ld hl, GraphicsTableB       ; Table pointeurs palette monde ($0DEA)
    add hl, de
    ld e, [hl]
    inc hl
    ld d, [hl]
    push de
    ld hl, VRAM_WORLD_PALETTE   ; Destination palette monde ($9310)

CopyColorPaletteDataLoop:
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, h
    cp VRAM_COPY_LIMIT_HIGH
    jr nz, CopyColorPaletteDataLoop

    pop hl
    ld de, WORLD_ANIM_OFFSET    ; Offset vers buffer animation ($02C1)
    add hl, de
    ld de, wAnimBuffer
    ld b, ANIM_BUFFER_COPY_SIZE

CopyAnimBufferLoop:
    ld a, [hl+]
    ld [de], a
    inc hl
    inc de
    dec b
    jr nz, CopyAnimBufferLoop

; GameplayInitStart
; -----------------
; Description: Finalise l'initialisation du gameplay après chargement des tiles/palettes.
;              Réactive le LCD, configure le scroll initial, réinitialise les flags et
;              passe à l'état PREPARE_RENDER pour lancer la partie.
; In:  (aucun)
; Out: (aucun, passe à l'état GAME_STATE_PREPARE_RENDER)
; Modifie: a
GameplayInitStart:
    xor a
    ldh [rIF], a                    ; Efface les interruptions en attente
    ld a, LCDC_GAME_STANDARD
    ldh [rLCDC], a                  ; Réactive le LCD avec config standard
    ei                              ; Réactive les interruptions
    ld a, TILEMAP_SCROLL_X_INIT
    ldh [hTilemapScrollX], a        ; Initialise le scroll horizontal
    xor a
    ld [wCollisionFlag], a          ; Efface le flag de collision
    ldh [hVBlankMode], a            ; Réinitialise le mode VBlank
    ld a, GAME_STATE_PREPARE_RENDER
    ldh [hGameState], a             ; Passe à l'état de préparation du rendu
    call InitAudioAndAnimContext    ; Initialise audio et contexte d'animation
    ret

; ===========================================================================
; GraphicsTableA / GraphicsTableB - Tables de pointeurs graphiques par monde
; ===========================================================================
; Description: Tables indexées par (monde - 2) * 2 pour charger les graphiques
;              spécifiques à chaque monde (tiles et palettes)
; Utilisé par: State08_WorldProgress (src/bank_000.asm:3111, 3130)
; Format:      GraphicsTableA[i] = pointeur ROM vers tiles du monde (i+2)
;              GraphicsTableB[i] = pointeur ROM vers palette du monde (i+2)
; Index:       0 = Monde 1, 2 = Monde 2, 4 = Monde 3
; Taille:      6 octets par table (3 entrées × 2 octets)
; ===========================================================================

; GraphicsTableA - Pointeurs vers les tiles de chaque monde ($0DE4)
GraphicsTableA:
    dw $4032               ; Monde 1 - pointeur tiles
    dw $4032               ; Monde 2 - pointeur tiles (identique monde 1)
    dw $47F2               ; Monde 3 - pointeur tiles

; GraphicsTableB - Pointeurs vers les palettes de chaque monde ($0DEA)
GraphicsTableB:
    dw ROM_WORLD1_PALETTE  ; Monde 1 - pointeur palette
    dw ROM_WORLD1_PALETTE  ; Monde 2 - pointeur palette (identique monde 1)
    dw ROM_WORLD3_PALETTE  ; Monde 3 - pointeur palette

; ===========================================================================
; État $1B - Transition bonus complété ($0DF0)
; ===========================================================================
; State1B_BonusComplete
; ---------------------
; Description: Recharge l'écran après complétion zone bonus
;              LCD off → mise à jour HUD/pièces/vies → LCD on → retour état $08
; In:  -
; Out: -
; Modifie: a, flags, appelle CopyHudTilemap/UpdateCoinDisplay/DisplayLivesCount
State1B_BonusComplete::
    di                          ; Désactive interruptions
    xor a
    ldh [rLCDC], a              ; Éteint LCD ($FF40 = $00)
    call CopyHudTilemap         ; Copie tilemap HUD
    call UpdateCoinDisplay      ; Actualise affichage pièces
    call DisplayLivesCount      ; Actualise compteur vies
    xor a
    ldh [rIF], a                ; Efface flags interruptions ($FF0F = $00)
    ld a, LCDC_GAME_STANDARD
    ldh [rLCDC], a              ; Rallume LCD en mode jeu ($FF40 = $C3)
    ei                          ; Réactive interruptions
    ld a, GAME_STATE_CENTER
    ldh [hGameState], a         ; Passe à l'état $08 (joueur centré)
    ldh [hScoreNeedsUpdate], a  ; Marque score à mettre à jour
    ret

; ===========================================================================
; State1C_WaitTimerGameplay ($0E0C)
; ----------------
; Description: Handler d'état $1C - Exécute la logique gameplay si timer actif,
;              sinon passe à l'état suivant avec nouveau timer
; In:  hTimer1 = compteur frames
; Out: hGameState = incrémenté si timer expiré, hTimer1 = réinitialisé si expiré
; Modifie: a, hl, appelle InitScrollBuffer, UpdateAudio, SwitchBankAndCallBank3Handler
; ===========================================================================
State1C_WaitTimerGameplay::
    ldh a, [hTimer1]
    and a
    jr z, TimerExpiredPath

    call InitScrollBuffer
    xor a
    ld [wPlayerVarAB], a
    call UpdateAudio
    call SwitchBankAndCallBank3Handler
    ret


; TimerExpiredPath
; ----------------
; Description: Gère la fin du timer gameplay - réinitialise timer et passe à l'état suivant
; In:  rien (appelé quand hTimer1 == 0)
; Out: hTimer1 = TIMER_STATE07_WAIT, hGameState = incrémenté
; Modifie: a, hl
TimerExpiredPath:
    ld a, TIMER_STATE07_WAIT
    ldh [hTimer1], a
    ld hl, hGameState
    inc [hl]
    ret

; ===========================================================================
; État $1D - Setup VRAM pointer ($0E28)
; State1D_SetupVRAMPointer
; -------------------------
; Description: Calcule l'adresse VRAM pour le rendu du scroll et initialise
;              les compteurs OAM et timer. Attend que hTimer1 expire avant d'exécuter.
; In:  hTimer1 = compteur frames (doit être 0 pour exécuter)
;      hVramPtrLow = position VRAM courante
; Out: hVramPtrLow = nouvelle position VRAM ajustée
;      hOAMAddrLow = OAM_ADDR_INIT ($05)
;      hTimer1 = TIMER_ANIM_STEP ($08)
;      hGameState = incrémenté
;      wPlayerVarAB = 0
; Modifie: a, hl, de
; ===========================================================================
State1D_SetupVRAMPointer::
    xor a
    ld [wPlayerVarAB], a
    call UpdateAudio
    ldh a, [hTimer1]
    and a
    ret nz

    ldh a, [hVramPtrLow]
    sub COLLISION_ADJUST_POS    ; Décalage de 2 colonnes
    cp SCROLL_COLUMN_DEFAULT    ; Seuil wrap-around (64)
    jr nc, VRAMPointerAdjustmentPath

    add TILEMAP_STRIDE          ; Ajuster wrap-around (+32 = 1 ligne tilemap)

VRAMPointerAdjustmentPath:
    ld l, a
    ld h, VRAM_TILEMAP_HIGH
    ld de, VRAM_TILEMAP_OFFSET
    add hl, de
    ld a, l
    ldh [hVramPtrLow], a
    ld a, OAM_ADDR_INIT
    ldh [hOAMAddrLow], a
    ld a, TIMER_ANIM_STEP
    ldh [hTimer1], a
    ld hl, hGameState
    inc [hl]
    ret

; ===========================================================================
; État $1E - Clear tilemap progressif ($0E54)
; Efface une colonne de tiles à chaque frame, puis appelle bank 3
; ===========================================================================
; State1E_ClearTilemapColumn
; --------------------------
; Description: Efface progressivement une colonne de tilemap (1 tile/frame)
;              en montant de bas en haut. Quand terminé, switche vers bank 3.
; In:  hOAMAddrLow = nombre de lignes restantes à effacer
;      hVramPtrLow = position VRAM courante (octet bas)
; Out: hGameState incrémenté (→ état $1F) si colonne complètement effacée
; Modifie: a, hl
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
    ld h, VRAM_SCRN1_HIGH       ; $99 = octet haut _SCRN1
    sub TILEMAP_STRIDE          ; Ligne précédente (-32 = 1 ligne tilemap)
    ldh [hVramPtrLow], a

    WAIT_FOR_HBLANK
    ld [hl], TILE_EMPTY
    ld a, TIMER_ANIM_STEP       ; Timer = 8 frames
    ldh [hTimer1], a
    ld a, STATE_RENDER_STATE_BUFFER
    ld [wStateBuffer], a
    ret


TilemapColumnClearCompletePath:
    ld a, TIMER_ANIM_TRANSITION
    ldh [hTimer1], a
    ld a, BANK_AUDIO
    ldh [hCurrentBank], a
    ld [rROMB0], a
    call ROM_INIT_BANK3
    ld hl, hGameState
    inc [hl]
    ret

; ===========================================================================
; État $1F - Activation VBlank mode ($0E8D)
; Attente timer, clear collision flags, active le mode VBlank
; ===========================================================================
; State1F_EnableVBlankMode
; ------------------------
; Description: Attend la fin du timer, réinitialise les flags de collision et active le mode VBlank
; In:  hTimer1 = timer principal (doit être 0 pour continuer)
; Out: hVBlankMode = 1 (mode VBlank activé), hGameState incrémenté
; Modifie: a, hl
State1F_EnableVBlankMode::
    ldh a, [hTimer1]
    and a                  ; Vérifie si timer est à 0
    ret nz                 ; Retourne si timer pas encore expiré

    xor a                  ; a = 0
    ld [wCollisionFlag], a ; Clear flag collision
    ld [wPlayerUnk07], a   ; Clear variable joueur $07
    inc a                  ; a = 1
    ldh [hVBlankMode], a   ; Active mode VBlank
    ld hl, hGameState
    inc [hl]               ; Passe à l'état suivant ($20)
    ret

; ===========================================================================
; ===========================================================================
; États $20/$28 - Attente position joueur ($0EA0)
; ===========================================================================
; State20_WaitPlayerPosition
; --------------------------
; Description: Simule input droite et attend que le joueur atteigne la position
;              cible (PLAYER_POS_THRESHOLD). Passe à l'état suivant une fois
;              la position atteinte.
; In:  wPlayerState = position actuelle du joueur
; Out: hGameState = incrémenté si position atteinte
;      hTimer1 = initialisé à TIMER_ANIM_WALK si position atteinte
; Modifie: a, hl
; ===========================================================================
State20_WaitPlayerPosition::
    call AutoMovePlayerRight
    ld a, [wPlayerState]
    cp PLAYER_POS_THRESHOLD
    ret c

    ld a, TIMER_ANIM_WALK
    ldh [hTimer1], a
    ld hl, hGameState
    inc [hl]
    ret

; ===========================================================================
; AutoMovePlayerRight ($0EB2)
; -----------------
; Description: Simule une pression sur la touche droite pour déplacer
;              automatiquement le joueur. Gère collision tête et animation pipe.
; In:  wPlayerDir = direction et mode du joueur
; Out: hJoypadState = PADF_RIGHT (input simulé)
; Modifie: a
; ===========================================================================
AutoMovePlayerRight:
    ld a, PADF_RIGHT
    ldh [hJoypadState], a
    ld a, [wPlayerDir]
    and NIBBLE_LOW_MASK
    cp PLAYER_MODE_GAMEPLAY
    call c, CheckPlayerHeadCollision
    call UpdatePipeAnimation
    ret

; ===========================================================================
; State21_SetupEndCutscene
; ------------------------
; Description: Setup cutscene de fin de niveau. Attend que hTimer1 soit à zéro,
;              puis reset la position du joueur, initialise le scroll et démarre
;              le timer de cutscene avant de passer à l'état suivant.
; In:  hTimer1 = timer à vérifier
; Out: hTimer1 = TIMER_CUTSCENE (161 frames), hGameState incrémenté
; Modifie: a, bc, de, hl
; ===========================================================================
State21_SetupEndCutscene::
    ldh a, [hTimer1]
    and a
    ret nz

    call ResetPlayerForCutscene
    xor a
    ldh [hScrollPhase], a
    ldh [hTemp3], a
    ld a, TIMER_CUTSCENE        ; Timer cutscene (161 frames)
    ldh [hTimer1], a
    ld a, STATE_RENDER_CUTSCENE
    ld [wStateRender], a
    ld hl, hGameState
    inc [hl]
    ret

; ResetPlayerForCutscene
; ----------------------
; Description: Réinitialise la position et les données du joueur pour la cutscene.
;              Positionne le joueur à CUTSCENE_PLAYER_X/Y, copie les données OAM
;              depuis ROM_LEVEL_INIT_DATA et configure quelques valeurs fixes.
; In:  Aucun
; Out: wPlayerX/Y = position cutscene, wPlayerUnk10-1F = données OAM + valeurs fixes
; Modifie: a, bc, de, hl
ResetPlayerForCutscene:
    ld hl, wPlayerX
    ld [hl], CUTSCENE_PLAYER_X
    inc l
    ld [hl], CUTSCENE_PLAYER_Y
    inc l
    ld a, [hl]
    and NIBBLE_HIGH_MASK
    ld [hl], a
    ld hl, wPlayerUnk10
    ld de, ROM_LEVEL_INIT_DATA
    ld b, OAM_COPY_SIZE

CopyOAMDataLoop:
    ld a, [de]
    ld [hl+], a
    inc de
    dec b
    jr nz, CopyOAMDataLoop

    ld hl, wPlayerUnk11
    ld [hl], CUTSCENE_PLAYER_X  ; wPlayerUnk11 = position X cutscene
    inc l
    ld [hl], CUTSCENE_INIT_VALUE ; wPlayerUnk12 = valeur init
    inc l
    ld [hl], CUTSCENE_TILE_ATTR ; wPlayerUnk13 = attribut/tile cutscene
    inc l
    inc l
    ld [hl], CUTSCENE_PARAM     ; wPlayerUnk15 = paramètre cutscene
    ret

; ===========================================================================
; State22_ScrollCutscene ($0F09)
; ----------------
; Description: Anime le scroll horizontal de cutscene et déplace le joueur.
;              Incrémente SCX, décrémente wPlayerState et wPlayerUnk12.
;              Continue pendant que hTimer1 > 0, puis passe à l'état suivant.
; In:  hTimer1 = compteur frames restantes
; Out: hGameState = incrémenté quand timer expiré
;      hRenderContext = hOAMIndex (à la fin)
; Modifie: a, hl, hShadowSCX, wPlayerState, wPlayerUnk12
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
    ld hl, wPlayerUnk12
    dec [hl]

; CutsceneAnimationContinuePath ($0F1D)
; ----------------
; Description: Appelle le handler bank 3 pour continuer l'animation cutscene
; In:  rien
; Out: rien
; Modifie: a, bc, de, hl (via SwitchBankAndCallBank3Handler)
CutsceneAnimationContinuePath:
    call SwitchBankAndCallBank3Handler
    ret


; CutsceneEndPath ($0F21)
; ----------------
; Description: Termine la cutscene - copie hOAMIndex vers hRenderContext,
;              passe à l'état suivant (State23_WalkToDoor)
; In:  hOAMIndex = index OAM actuel
; Out: hRenderContext = hOAMIndex, hGameState = incrémenté
; Modifie: a, hl
CutsceneEndPath:
    ldh a, [hOAMIndex]
    ldh [hRenderContext], a
    ld hl, hGameState
    inc [hl]
    ret

; ===========================================================================
; État $23 - Animation joueur vers porte ($0F2A)
; ===========================================================================
; State23_WalkToDoor
; ------------------
; Description: Simule input droite pour faire marcher le joueur vers la porte,
;              anime le sprite, et calcule la position VRAM de destination
; In:  -
; Out: -
; Modifie: a, b, hl
State23_WalkToDoor::
    ld a, PADF_RIGHT
    ldh [hJoypadState], a
    call CheckPlayerHeadCollision
    call UpdatePipeAnimation
    ld a, [wPlayerState]
    cp PLAYER_STATE_PIPE_THRESHOLD
    ret c

    ld a, [wPlayerDir]
    and NIBBLE_HIGH_MASK
    ld [wPlayerDir], a
    ldh a, [hVramPtrLow]
    sub SCROLL_COLUMN_DEFAULT    ; Soustraction offset 64
    add MOVEMENT_OFFSET_4        ; Ajout offset 4
    ld b, a
    and NIBBLE_HIGH_MASK         ; Isoler bits hauts position
    cp PLAYER_POS_THRESHOLD      ; Comparer avec seuil $C0 (192)
    ld a, b
    jr nz, DoorPositionCalculationPath

    sub TILEMAP_STRIDE          ; Ajuster position porte (-32 = 1 ligne tilemap)

DoorPositionCalculationPath:
    ldh [hCopyDstHigh], a
    ld a, VRAM_TILEMAP_HIGH     ; $98 = octet haut _SCRN0
    ldh [hCopyDstLow], a
    xor a
    ldh [hOAMIndex], a
    ld hl, hGameState
    inc [hl]
    jr CutsceneAnimationContinuePath

; ===========================================================================
; State24_DisplayText
; -------------------
; Description: Affiche le texte "THANK YOU MARIO! ♥OH! DAISY" caractère par caractère
;              puis passe à l'état suivant quand le texte est entièrement affiché
; In:  -
; Out: a = TEXT_CMD_END si texte terminé, autre sinon
; Modifie: a, hl
; ===========================================================================
State24_DisplayText::
    ld hl, TextData_ThankYou
    call WriteCharToVRAM
    cp TEXT_CMD_END             ; Fin de texte ?
    ret nz

    ld hl, hGameState
    inc [hl]
    ld a, PLAYER_ANIM_INITIAL
    ld [wPlayerUnk10], a
    ld a, TIMER_ANIM_STEP
    ldh [hTimer1], a
    ld a, OAM_INDEX_CUTSCENE
    ldh [hOAMIndex], a
    ld a, GAME_STATE_OUTER
    ld [wStateRender], a
    ret

; WriteCharToVRAM
; ---------------
; Description: Écrit un caractère de texte en VRAM, gère les commandes spéciales
;              (saut de ligne, fin de texte) et incrémente la position de lecture
; In:  hl = pointeur vers table de texte
; Out: a = caractère lu (TEXT_CMD_END, TEXT_CMD_NEWLINE ou tile)
; Modifie: a, bc, de, hl
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
    cp TEXT_CMD_NEWLINE

; ValidateAndWriteTextCharToVram
; -------------------------------
; Point d'entrée secondaire: valide le caractère et dispatche vers traitement approprié
; Si TEXT_CMD_NEWLINE → charge offset et copie, si TEXT_CMD_END → retourne, sinon → écrit
ValidateAndWriteTextCharToVram:
    jr z, LoadOffsetAndCopy

    cp TEXT_CMD_END
    ret z

    ldh a, [hCopyDstLow]
    ld h, a
    ldh a, [hCopyDstHigh]
    ld l, a

; WaitAndStoreVram
; ----------------
; Écrit le caractère en VRAM avec attente HBlank, puis ajuste la position destination
; Gère le retour à la ligne quand on atteint la fin d'une ligne tilemap
WaitAndStoreVram:
    WAIT_FOR_HBLANK
    WAIT_FOR_HBLANK
    ld [hl], b
    inc hl
    ld a, h
    ldh [hCopyDstLow], a
    ld a, l
    and NIBBLE_LOW_MASK          ; Isoler nibble bas
    jr nz, AdjustDestHighByte

    bit 4, l
    jr nz, AdjustDestHighByte

    ld a, l
    sub TILEMAP_STRIDE          ; Ligne précédente (-32 = 1 ligne tilemap)

; StoreDestHighByte
; -----------------
; Stocke le byte haut de l'adresse destination et configure le timer
StoreDestHighByte:
    ldh [hCopyDstHigh], a
    inc e
    ld a, e
    ldh [hOAMIndex], a
    ld a, TIMER_TEXT_CHAR
    ldh [hTimer1], a
    ret

; AdjustDestHighByte
; ------------------
; Point de convergence pour l'ajustement de l'adresse destination
AdjustDestHighByte:
    ld a, l
    jr StoreDestHighByte

; LoadOffsetAndCopy
; -----------------
; Charge l'offset de nouvelle ligne (commande TEXT_CMD_NEWLINE) et prépare la copie
; Format: $FE <offset_low> <offset_high>
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
; Texte en indices de tiles pour la cutscene de fin
; Ligne 1: "THANK YOU MARIO!" ($FE = saut de ligne)
; Ligne 2: "♥OH! DAISY" ($FF = fin)
TextData_ThankYou:
    db TEXT_CHAR_T, TEXT_CHAR_H, TEXT_CHAR_A, TEXT_CHAR_N, TEXT_CHAR_K  ; "THANK"
    db TEXT_CHAR_SPACE                                                  ; " "
    db TEXT_CHAR_Y, TEXT_CHAR_O, TEXT_CHAR_U                            ; "YOU"
    db TEXT_CHAR_SPACE                                                  ; " "
    db TEXT_CHAR_M, TEXT_CHAR_A, TEXT_CHAR_R, TEXT_CHAR_I, TEXT_CHAR_O  ; "MARIO"
    db TEXT_CHAR_EXCLAIM                                                ; "!"
    db TEXT_CHAR_NEWLINE                                                ; Saut de ligne
    db TEXT_CHAR_HEART                                                  ; ♥
    db TEXT_CHAR_O, TEXT_CHAR_H                                         ; "OH"
    db TEXT_CHAR_EXCLAIM_ALT                                            ; "!"
    db TEXT_CHAR_SPACE                                                  ; " "
    db TEXT_CHAR_D, TEXT_CHAR_A, TEXT_CHAR_I, TEXT_CHAR_S, TEXT_CHAR_Y  ; "DAISY"
    db TEXT_CHAR_END                                                    ; Fin

; ===========================================================================
; État $25 - Animation sprite clignotant ($0FF4)
; ===========================================================================

; State25_SpriteBlinkAnimation
; ----------------------------
; Description: Animation de sprites clignotants qui alterne entre deux
;              configurations sprite jusqu'à ce que le compteur atteigne 0
; In:  hTimer1 = timer d'animation
;      hOAMIndex = compteur de frames restantes
; Out: hGameState = incrémenté si animation terminée
; Modifie: a, hl, de, b
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
    and FRAME_MASK_2             ; Sélection table selon parité
    ld hl, ROM_SPRITE_CONFIG_1
    jr nz, State25_CopySpriteDataToOam

    ld hl, ROM_SPRITE_CONFIG_2
    ld a, SPRITE_CONFIG_COUNT

State25_StoreSpriteValue:
    ld [wStateFinal], a

State25_CopySpriteDataToOam:
    call Copy16BytesToOam
    ld a, TIMER_ANIM_STEP
    ldh [hTimer1], a
    ret


State25_NextState:
    ld hl, wPlayerUnk10
    ld [hl], $00
    ld hl, hGameState
    inc [hl]
    ret

; Copy16BytesToOam
; ----------------
; Description: Copie 16 octets depuis une table source vers la zone OAM
; In:  hl = pointeur vers données source (16 octets)
; Out: hl = pointeur après les 16 octets lus
;      de = wOamVar1C + 16
; Modifie: a, b
Copy16BytesToOam:
    ld de, wOamVar1C
    ld b, OAM_COPY_SIZE

Copy16BytesOam_Loop:
    ld a, [hl+]
    ld [de], a
    inc e
    dec b
    jr nz, Copy16BytesOam_Loop

    ret

; === Tables de configuration sprites cutscene ($102C-$104B) ===
; Format OAM : Y position, X position, Tile index, Attributes
; 4 bytes par sprite × 4 sprites × 2 configurations = 32 bytes
;
; SpriteConfig1 ($102C): Configuration normale (tile $06)
; SpriteConfig2 ($103C): Configuration alternative/clignement (tile $07)

SpriteConfigTable:
; Configuration 1 - Tile $06 (normal)
    db $78, $58, $06, $00  ; Sprite 0: Y=$78, X=$58, Tile=$06, Attr=$00
    db $78, $60, $06, $20  ; Sprite 1: Y=$78, X=$60, Tile=$06, Attr=$20 (X flip)
    db $80, $58, $06, $40  ; Sprite 2: Y=$80, X=$58, Tile=$06, Attr=$40 (Y flip)
    db $80, $60, $06, $60  ; Sprite 3: Y=$80, X=$60, Tile=$06, Attr=$60 (XY flip)

; Configuration 2 - Tile $07 (clignement/alternatif)
    db $78, $58, $07, $00  ; Sprite 0: Y=$78, X=$58, Tile=$07, Attr=$00
    db $78, $60, $07, $20  ; Sprite 1: Y=$78, X=$60, Tile=$07, Attr=$20 (X flip)
    db $80, $58, $07, $40  ; Sprite 2: Y=$80, X=$58, Tile=$07, Attr=$40 (Y flip)
    db $80, $60, $07, $60  ; Sprite 3: Y=$80, X=$60, Tile=$07, Attr=$60 (XY flip)

; ===========================================================================
; État $26 - Animation princesse montante ($104C)
; Déplace sprite princesse vers le haut, appelle bank externe pour animation
; ===========================================================================
State26_PrincessRising::
    ldh a, [hTimer1]
    and a
    ret nz

    ld hl, wPlayerUnk13
    ld [hl], PRINCESS_INIT_VALUE
    ld bc, wObject2
    ld hl, ROM_OBJECT_INIT_DATA
    push bc
    call ProcessObjectData
    pop hl
    dec l
    ld a, [hl]
    and a
    jr nz, UpdateAnimationFrame

    ld [hl], FLAG_TRUE
    ld hl, wPlayerUnk13
    ld [hl], PRINCESS_NEXT_VALUE
    ld a, TIMER_PRINCESS_PAUSE
    ldh [hTimer1], a

UpdateAnimationFrame:
    ldh a, [hFrameCounter]
    and FLAG_TRUE
    jr nz, State26_SwitchBankAndCallBank3Handler

    ld hl, wPlayerUnk12
    inc [hl]
    ld a, [hl]
    cp PRINCESS_ANIM_THRESHOLD
    jr nc, State26_NextState

State26_SwitchBankAndCallBank3Handler:
    call SwitchBankAndCallBank3Handler
    ret


State26_NextState:
    ld hl, hGameState
    ld [hl], GAME_STATE_OUTER
    ld a, BANK_DEMO
    ldh [hCurrentBank], a
    ld [rROMB0], a
    ret

; ===========================================================================
; State27_PlayerOscillation
; -------------------------
; Description: Gère l'animation d'oscillation horizontale du joueur avec effet
;              de fade VRAM progressif. Toggle un flag tous les 4 frames.
; In:  hTimer2 = timer oscillation (si 0, réinitialise)
;      hTimer1 = compteur frames
; Out: hGameState = incrémenté vers état suivant si animation terminée
; Modifie: a, bc, de, hl, wPlayerVarAB, wStateFinal, wLevelInitFlag
; ===========================================================================
State27_PlayerOscillation::
    ldh a, [hTimer2]
    and a
    jr nz, State27_ClearPlayerVar

    ld a, FLAG_TRUE
    ld [wStateFinal], a
    ld a, OSCIL_TIMER_INIT
    ldh [hTimer2], a

State27_ClearPlayerVar:
    xor a
    ld [wPlayerVarAB], a
    call UpdateAudio
    ldh a, [hTimer1]
    ld c, a
    and FRAME_MASK_4
    jr nz, State27_CheckTimer

    ldh a, [hOAMIndex]
    xor FLAG_TRUE
    ldh [hOAMIndex], a
    ld b, OSCIL_OFFSET_NEG
    jr z, State27_AddOffsetToFlag

    ld b, OSCIL_OFFSET_POS

State27_AddOffsetToFlag:
    ld a, [wLevelInitFlag]
    add b
    ld [wLevelInitFlag], a

State27_CheckTimer:
    ld a, c
    cp OSCIL_TIMER_THRESHOLD
    ret nc

    and TILEMAP_COLUMN_MASK     ; Masque colonnes tilemap (31)
    ret nz

    ld hl, VRAM_FADE_START
    ld bc, VRAM_FADE_SIZE
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
    cp VRAM_FADE_BOUND_HI
    jr nz, .skipWrap

    ld hl, VRAM_FADE_WRAP

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
    ld a, OSCIL_TIMER_END
    ldh [hTimer1], a
    ret


; ResetCollisionFlags
; -------------------
; Description: Réinitialise les flags de collision et niveau, active VBlank et passe à l'état suivant
; In:  -
; Out: -
; Modifie: a, hl
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
; State29_SetupEndScreen
; ----------------------
; Description: Configure l'écran de fin de jeu après victoire
;              - Désactive LCD et interruptions
;              - Efface tilemap _SCRN1 (256 octets)
;              - Réinitialise état de scroll et joueur pour cutscene
;              - Positionne joueur à (16, 56), pos=120
;              - Clear OAM buffer (12 octets)
;              - Configure rendu cutscene et réactive LCD
; In:  Aucun
; Out: Aucun (état suivant: $2A)
; Modifie: a, bc, de, hl (via appels de fonctions)
State29_SetupEndScreen::
    di
    xor a
    ldh [rLCDC], a
    ldh [hVBlankMode], a
    ld hl, _SCRN1
    ld bc, SCRN1_FIN_CLEAR_SIZE
    call FillTilemapLoop
    call InitScrollState
    call ResetPlayerForCutscene
    ld hl, wPlayerState
    ld [hl], END_SCREEN_PLAYER_Y
    inc l
    ld [hl], END_SCREEN_PLAYER_X
    ld hl, wPlayerUnk12
    ld [hl], END_SCREEN_PLAYER_POS
    xor a
    ldh [rIF], a
    ldh [hShadowSCX], a
    ld [wLevelInitFlag], a
    ldh [hOAMIndex], a
    ld hl, wOamBuffer
    ld b, OAM_CLEAR_SIZE_END

ClearOamBuffer_Loop:
    ld [hl+], a
    dec b
    jr nz, ClearOamBuffer_Loop

    call SwitchBankAndCallBank3Handler
    ld a, VRAM_TILEMAP_HIGH     ; $98 = octet haut _SCRN0
    ldh [hCopyDstLow], a
    ld a, CUTSCENE_TEXT_OFFSET  ; Offset colonne texte
    ldh [hCopyDstHigh], a
    ld a, STATE_RENDER_CUTSCENE
    ld [wStateRender], a
    ld a, LCDC_GAME_STANDARD
    ldh [rLCDC], a
    ei
    ld hl, hGameState
    inc [hl]
    ret

; State2A_DisplayEndText
; -----------------------
; Description: Affiche le texte "OH! DAISY", configure la destination VRAM pour
;              le sprite de la princesse et passe à l'état suivant
; In:  Aucun
; Out: Aucun (avance l'état du jeu si texte terminé)
; Modifie: a, hl, [hOAMIndex], [hCopyDstLow], [hCopyDstHigh], [wPlayerUnk13], [hGameState]
State2A_DisplayEndText::
    ld hl, TextData_OhDaisy
    call WriteCharToVRAM
    cp TEXT_CMD_END             ; Fin de texte ?
    ret nz

    xor a
    ldh [hOAMIndex], a
    ld a, VRAM_SCRN1_HIGH           ; $99 = octet haut _SCRN1
    ldh [hCopyDstLow], a
    ld a, VRAM_COPY_LINE_OFFSET     ; Ligne 2 tilemap
    ldh [hCopyDstHigh], a
    ld a, CUTSCENE_COUNTER_23       ; Compteur animation cutscene
    ld [wPlayerUnk13], a
    ld hl, hGameState
    inc [hl]
    ret

; === Table de texte "OH! DAISY" ($117A-$118A) ===
; Texte affiché après la descente de la princesse
; "OH! DAISY" (saut de ligne) "RDAISY" (fin)
TextData_OhDaisy:
    db $18, $11                 ; "OH"
    db $28                      ; "!"
    db $2c                      ; " " (espace)
    db $0d, $0a, $12, $1c, $22  ; "DAISY"
    db TEXT_CMD_NEWLINE         ; Saut de ligne
    db $1b                      ; "R" (?)
    db $0d, $0a, $12, $1c, $22  ; "DAISY"
    db TEXT_CMD_END             ; Fin

; ===========================================================================
; État $2B - Animation descente princesse ($118B)
; ===========================================================================
; State2B_PrincessDescending
; --------------------------
; Description: Gère l'animation de descente de la princesse, affiche "THANK YOU MARIO!",
;              décrémente progressivement la position Y, puis passe à l'état suivant.
; In:  [wPlayerUnk12] = position Y actuelle de la princesse
; Out: [hGameState] = incrémenté quand descente terminée
;      [wSpriteTemp+0..3] = données sprite initialisées (Y, X, Tile, flags)
; Modifie: a, hl
State2B_PrincessDescending::
    ld hl, TextData_ThankYouMario
    call WriteCharToVRAM
    ldh a, [hFrameCounter]
    and FRAME_MASK_4
    ret nz

    ld hl, wPlayerUnk12
    ld a, [hl]
    cp PRINCESS_DESCENT_END
    jr c, State2B_NextState

    dec [hl]
    call SwitchBankAndCallBank3Handler
    ret


State2B_NextState:
    ld hl, hGameState
    inc [hl]
    ld hl, wSpriteTemp

State2B_InitSpriteData:
    ld [hl], PRINCESS_SPRITE_Y
    inc l
    ld [hl], PRINCESS_SPRITE_X
    inc l
    ld [hl], PRINCESS_SPRITE_TILE
    inc l
    ld [hl], FLAG_FALSE
    ret

; === Table de texte "THANK YOU MARIO!" ($11B6-$11C6) ===
; Texte affiché pendant l'animation de la princesse
TextData_ThankYouMario:
    db TEXT_CHAR_T, TEXT_CHAR_H, TEXT_CHAR_A, TEXT_CHAR_N, TEXT_CHAR_K  ; "THANK"
    db TEXT_CHAR_SPACE                                                   ; " "
    db TEXT_CHAR_Y, TEXT_CHAR_O, TEXT_CHAR_U                             ; "YOU"
    db TEXT_CHAR_SPACE                                                   ; " "
    db TEXT_CHAR_M, TEXT_CHAR_A, TEXT_CHAR_R, TEXT_CHAR_I, TEXT_CHAR_O  ; "MARIO"
    db TEXT_CHAR_EXCLAIM                                                 ; "!"
    db TEXT_CHAR_END                                                     ; Fin

; ===========================================================================
; État $2C - Animation sprite oscillante ($11C7)
; ===========================================================================
; State2C_SpriteOscillation
; -------------------------
; Description: Anime sprite avec oscillation verticale, efface écran quand terminé
; In:  hFrameCounter = compteur de frames
;      wSpriteTemp = compteur oscillation + valeur position
;      hOAMIndex = direction oscillation (0=descend, autre=monte)
; Out: hGameState incrémenté si animation terminée
; Modifie: a, b, hl
State2C_SpriteOscillation::
    ldh a, [hFrameCounter]
    and FRAME_MASK_2             ; 1 frame sur 2 seulement
    ret nz

    ld hl, wSpriteTemp
    dec [hl]
    ld a, [hl+]
    cp OSCIL_CLEAR_THRESHOLD
    jr c, State2C_ClearScreen

    ldh a, [hOAMIndex]
    and a
    ld a, [hl]
    jr nz, State2C_IncrementOscillation

    dec [hl]
    cp OSCIL_DIR_CHANGE_LOW
    ret nc

State2C_StoreOAMIndex:
    ldh [hOAMIndex], a
    ret


State2C_IncrementOscillation:
    inc [hl]
    cp OSCIL_DIR_CHANGE_HIGH
    ret c

    xor a
    jr State2C_StoreOAMIndex

State2C_ClearScreen:
    ld [hl], OSCIL_RESET_VALUE
    ld b, CUTSCENE_CLEAR_SIZE
    ld hl, VRAM_CUTSCENE_TEXT

.loopClear:
    WAIT_FOR_HBLANK
    WAIT_FOR_HBLANK
    ld [hl], TILE_EMPTY
    inc hl
    dec b
    jr nz, .loopClear

    xor a
    ldh [hOAMIndex], a
    ld a, VRAM_SCRN1_HIGH        ; $99 = octet haut _SCRN1
    ldh [hCopyDstLow], a
    ld a, FLAG_FALSE
    ldh [hCopyDstHigh], a
    ld hl, hGameState
    inc [hl]
    ret

; ===========================================================================
; État $2D - Affichage texte deuxième partie ($1212)
; Affiche texte "YOUR QUEST IS OVER!", configure sprites Mario et Peach
; ===========================================================================
State2D_DisplayText2::
    ld hl, TextData_QuestOver
    call WriteCharToVRAM
    cp SLOT_EMPTY
    ret nz

    ld hl, wPlayerUnk13
    ld [hl], $24
    inc l
    inc l
    ld [hl], $00
    ld hl, wObject4Unk09
    ld [hl], CUTSCENE_PLAYER_X
    inc l
    inc l
    ld [hl], $28
    inc l
    inc l
    ld [hl], $00
    ld hl, hGameState
    inc [hl]
    ret

; === Table de texte "YOUR QUEST IS OVER!" ($1236-$124A) ===
; Texte final de fin de jeu
TextData_QuestOver:
    db TEXT_CHAR_PAREN                                      ; "("
    db TEXT_CHAR_Y, TEXT_CHAR_O, TEXT_CHAR_U, TEXT_CHAR_R   ; "YOUR"
    db TEXT_CHAR_SPACE                                      ; " "
    db TEXT_CHAR_Q, TEXT_CHAR_U, TEXT_CHAR_E, TEXT_CHAR_S, TEXT_CHAR_T  ; "QUEST"
    db TEXT_CHAR_SPACE                                      ; " "
    db TEXT_CHAR_I, TEXT_CHAR_S                             ; "IS"
    db TEXT_CHAR_SPACE                                      ; " "
    db TEXT_CHAR_O, TEXT_CHAR_V, TEXT_CHAR_E, TEXT_CHAR_R   ; "OVER"
    db TEXT_CHAR_PAREN                                      ; ")"
    db TEXT_CHAR_END                                        ; Fin

; ===========================================================================
; State2E_DuoAnimation ($124B)
; ------------------------
; Description: Animation de Mario et Peach ensemble. Toggle la frame d'animation
;              toutes les 4 frames, gère le positionnement vertical des personnages
;              selon des seuils de position, et fait avancer automatiquement vers
;              la droite. Passe à l'état suivant quand les seuils sont atteints.
; In:  hFrameCounter = compteur de frames global
;      wObject4Unk08, wObject4Unk0A = état et position cutscene
; Out: hGameState = incrémenté si seuil atteint
;      wPlayerY, wPlayerUnk10 = positions verticales mises à jour
; Modifie: a, hl (AutoMovePlayerRight et UpdateScroll)
; ===========================================================================
State2E_DuoAnimation::
    ldh a, [hFrameCounter]
    and FRAME_MASK_4
    jr nz, State2E_CheckCharPosition

    ld hl, wPlayerUnk13
    ld a, [hl]
    xor BIT_0_MASK              ; Toggle animation frame (0↔1)
    ld [hl], a

State2E_CheckCharPosition:
    ld hl, wObject4Unk08
    ld a, [hl]
    and a
    jr nz, State2E_UpdateMovement

    inc l
    inc l
    dec [hl]
    ld a, [hl]
    cp CUTSCENE_POS_THRESHOLD_1
    jr nz, State2E_CheckCounterFrame2

    ld a, PLAYER_Y_INIT
    ld [wPlayerY], a
    jr State2E_UpdateMovement

State2E_CheckCounterFrame2:
    cp CUTSCENE_POS_THRESHOLD_2
    jr nz, State2E_UpdateMovement

    ld a, PLAYER_Y_INIT
    ld [wPlayerUnk10], a
    ld a, CUTSCENE_POS_THRESHOLD_2
    ldh [hTimer1], a
    ld hl, hGameState
    inc [hl]

State2E_UpdateMovement:
    call AutoMovePlayerRight
    call UpdateScroll
    ldh a, [hTilemapScrollX]
    cp TILEMAP_SCROLL_X_INIT
    ret nz

    ldh a, [hTilemapScrollY]
    and a
    ret nz

    ld hl, wObject4Unk08
    ld [hl], FLAG_FALSE
    inc l
    inc l
    ld [hl], CUTSCENE_COUNTER_INIT
    ret

; ===========================================================================
; État $2F - Transfer données sprite ($1298)
; State2F_TransferSpriteData
; ----------------
; Description: Attend que timer atteigne 0, puis copie 6 octets de wObject4Unk08
;              vers wPlayerY (position sprite joueur) et avance à l'état suivant
; In:  hTimer1 = compteur temporisation
; Out: hGameState = incrémenté si timer = 0
; Modifie: a, b, de, hl
; ===========================================================================
State2F_TransferSpriteData::
    ldh a, [hTimer1]
    and a
    ret nz

    ld hl, wObject4Unk08
    ld de, wPlayerY
    ld b, SPRITE_DATA_COPY_SIZE

CopySpriteDataToOam_Loop:
    ld a, [hl+]
    ld [de], a
    inc e
    dec b
    jr nz, CopySpriteDataToOam_Loop

    ld hl, wPlayerDir
    ld [hl], PLAYER_DIR_CUTSCENE
    ld hl, wObject4Unk09
    ld [hl], SPRITE_ANIM_RESET
    ld hl, hGameState
    inc [hl]
    ret

; ===========================================================================
; État $30 - Animation marche gauche ($12B9)
; ===========================================================================
; State30_WalkLeft
; ----------------
; Description: Déplace le sprite du joueur vers la gauche avec animation
;              de marche pendant une cutscene. S'arrête à CUTSCENE_WALK_END_X.
; In:  hFrameCounter = compteur de frames pour timing
;      wPlayerX = position X actuelle du joueur
; Out: wPlayerX décrémenté, hGameState avancé si position finale atteinte
; Modifie: a, b, hl, appelle SwitchBankAndCallBank3Handler, ToggleAnimFrame
; ===========================================================================
State30_WalkLeft::
    call SwitchBankAndCallBank3Handler
    ldh a, [hFrameCounter]
    ld b, a
    and FRAME_MASK_2             ; 1 frame sur 2 seulement
    ret nz

    ld hl, wObject4Unk08
    ld [hl], SLOT_EMPTY
    ld hl, wPlayerX
    dec [hl]
    ld a, [hl+]
    cp CUTSCENE_WALK_END_X
    jr z, AdvanceToNextState

    call ToggleAnimFrame
    ret


; AdvanceToNextState
; ------------------
; Description: Passe à l'état suivant et réinitialise l'index OAM
; In:  -
; Out: hGameState incrémenté, hOAMIndex = OAM_ENTRY_SIZE
; Modifie: a, hl
AdvanceToNextState:
    ld hl, hGameState
    inc [hl]
    ld a, OAM_ENTRY_SIZE
    ldh [hOAMIndex], a
    ret

; ToggleAnimFrame
; ---------------
; Description: Alterne la frame d'animation (bit 0) toutes les 4 frames.
;              Suppose que hl pointe vers wPlayerX-1 (utilise inc l).
; In:  hl = pointeur vers wPlayerX-1
;      hFrameCounter = compteur de frames
; Out: [hl+1] = frame d'animation inversée (bit 0 togglé)
; Modifie: a, l
ToggleAnimFrame:
    ldh a, [hFrameCounter]
    and FRAME_MASK_4
    ret nz

    inc l
    ld a, [hl]
    xor BIT_0_MASK              ; Toggle animation frame (0↔1)
    ld [hl], a
    ret

; ===========================================================================
; State31_HorizontalScroll ($12E8)
; --------------------------------
; Description: Gère le scroll horizontal pendant la cutscene finale
;              Incrémente SCX progressivement et déclenche la transition
;              vers l'écran final quand wStateVar9 = 0
; In:  hShadowSCX = position scroll actuelle
;      wStateVar9 = flag de contrôle (0 = transition vers écran final)
; Out: hShadowSCX incrémenté, wStateRender = STATE_RENDER_FINAL si transition
; Modifie: af
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
    ld a, [wStateVar9]
    and a
    ret nz

    ld a, STATE_RENDER_FINAL
    ld [wStateRender], a
    ret

; AnimateAndCallBank3 ($1305)
; ---------------------------
; Description: Bascule la frame d'animation du joueur et appelle le handler bank 3
; In:  wPlayerState = état animation joueur
; Out: Frame d'animation toggleée, handler bank 3 exécuté
; Modifie: hl, af (via sous-routines)
AnimateAndCallBank3:
    ld hl, wPlayerState
    call ToggleAnimFrame
    call SwitchBankAndCallBank3Handler
    ret

; SetupFinalScreen ($130F)
; ------------------------
; Description: Configure l'écran final de la cutscene quand SCX atteint $FE ou $FF
;              Décrémente hOAMIndex, reset LYC, configure sprites et scroll
;              Incrémente hGameState à la fin
; In:  hOAMIndex = compteur décrément, hScrollColumn = colonne scroll courante
; Out: OAM et scroll configurés pour écran final, hGameState incrémenté
; Modifie: af, hl, de, bc (via sous-routines)
SetupFinalScreen:
    push af
    ldh a, [hOAMIndex]
    dec a
    ldh [hOAMIndex], a
    jr nz, PopAndReturn

    ldh [rLYC], a
    ld a, OAM_INDEX_FINAL_SETUP
    ldh [hOAMIndex], a
    ld a, SCROLL_COLUMN_FINAL
    ldh [hScrollColumn], a
    call ClearScrollBuffer
    ld hl, wPlayerUnk10
    ld de, ROM_SPRITE_END_DATA_1
    call Copy5Bytes
    ld hl, wObject2Unk08
    ld de, ROM_SPRITE_END_DATA_2
    call Copy5Bytes
    ld hl, wObject3Unk08
    ld de, ROM_SPRITE_END_DATA_3
    call Copy5Bytes
    ld hl, hGameState
    inc [hl]

; PopAndReturn ($1343)
; --------------------
; Description: Helper local pour SetupFinalScreen - restaure af et retourne
;              Utilisé pour sortie précoce quand compteur hOAMIndex != 0
; In:  Stack contient af sauvegardé
; Out: af restauré
; Modifie: af (restauré depuis stack)
PopAndReturn:
    pop af
    ret

; ClearScrollBuffer ($1345)
; -------------------------
; Description: Efface le buffer de scroll avec des tiles vides
;              Active le scroll et efface HUD_LINE_COUNT lignes dans VRAM
;              en utilisant WAIT_FOR_HBLANK pour chaque tile
; In:  hScrollColumn = colonne de départ dans tilemap
; Out: wScrollBuffer rempli de TILE_EMPTY, hScrollPhase = SCROLL_PHASE_ACTIVE
;      HUD_LINE_COUNT lignes effacées dans VRAM
; Modifie: af, b, hl
ClearScrollBuffer:
    ld hl, wScrollBuffer
    ld b, SCROLL_BUFFER_SIZE
    ld a, TILE_EMPTY

ClearBufferLoop:
    ld [hl+], a
    dec b
    jr nz, ClearBufferLoop

    ld a, SCROLL_PHASE_ACTIVE
    ldh [hScrollPhase], a
    ld b, HUD_LINE_COUNT
    ldh a, [hScrollColumn]
    sub TILEMAP_STRIDE          ; Ligne précédente (-32 = 1 ligne tilemap)
    ld l, a
    ld h, VRAM_TILEMAP_HIGH

.loopClearTile:
    WAIT_FOR_HBLANK
    ld [hl], TILE_EMPTY
    ld a, l
    sub TILEMAP_STRIDE          ; Ligne précédente (-32 = 1 ligne tilemap)
    ld l, a
    dec b
    jr nz, .loopClearTile

    ret

; Copy5Bytes ($136D)
; ------------------
; Description: Copie SPRITE_CONFIG_COPY_SIZE bytes de ROM vers RAM
;              Utilisé pour charger config sprites depuis tables ROM
; In:  hl = destination RAM, de = source ROM
; Out: SPRITE_CONFIG_COPY_SIZE (5) bytes copiés, hl et de avancés
; Modifie: af, b, hl, de
Copy5Bytes:
    ld b, SPRITE_CONFIG_COPY_SIZE

CopyByteLoop:
    ld a, [de]
    ld [hl+], a
    inc de
    dec b
    jr nz, CopyByteLoop

    ret

; === Tables de données sprites finaux ($1376-$1384) ===
; NOTE: Config sprites pour écran final - 3 tables de 5 octets
SpriteEndData:
    db $00, $30, $d0, $29, $80  ; $1376: ROM_SPRITE_END_DATA_1 (joueur)
    db $80, $70, $10, $2a, $80  ; $137b: ROM_SPRITE_END_DATA_2 (objet 2)
    db $80, $40, $70, $29, $80  ; $1380: ROM_SPRITE_END_DATA_3 (objet 3)

; State32_CreditsScroll
; ----------------------
; Description: État $32 - Anime et scroll les crédits, décrémente les sprites OAM
;              Scrolle à vitesse 2 pixels/frame, nettoie buffer tous les 8 pixels
;              Transition vers état $33 quand OAM index atteint 0
; In:  [hShadowSCX] = position scroll actuelle
;      [hTemp3] = bit de toggle pour intervalle de nettoyage
;      [hOAMIndex] = compteur sprites OAM restants
; Out: [hGameState] = GAME_STATE_CREDITS_TEXT ($33) si OAM=0
;      [hShadowSCX] = incrémenté de 2, reset à 0 en fin
;      [rLYC] = LYC_CREDITS_LINE ($60)
;      [hCopyDstLow/High] = ROM_CREDITS_TEXT ($154E)
;      [hTimer1] = TIMER_CREDITS_LONG ($F0)
; Modifie: af, bc, de, hl (via AnimateCreditsFrame et ClearScrollBuffer)
State32_CreditsScroll::
    call AnimateCreditsFrame
    ldh a, [hShadowSCX]
    inc a
    inc a
    ldh [hShadowSCX], a
    and BIT_3_MASK              ; Test bit 3 (intervalle de 8 pixels)
    ld b, a
    ldh a, [hTemp3]
    cp b
    ret nz

    xor BIT_3_MASK              ; Toggle bit 3
    ldh [hTemp3], a
    call ClearScrollBuffer
    ldh a, [hOAMIndex]
    dec a
    ldh [hOAMIndex], a
    ret nz

    xor a
    ldh [hShadowSCX], a
    ld a, LYC_CREDITS_LINE          ; Ligne 96 pour interruption LYC
    ldh [rLYC], a
    ld hl, ROM_CREDITS_TEXT         ; Pointeur texte crédits
    ld a, h
    ldh [hCopyDstLow], a
    ld a, l
    ldh [hCopyDstHigh], a
    ld a, TIMER_CREDITS_LONG        ; Timer long crédits (240 frames)
    ldh [hTimer1], a
    ld hl, hGameState
    inc [hl]
    ret


; UpdateCreditsStars
; ----------------
; Description: Met à jour l'animation des 3 étoiles de l'écran de crédits.
;              Décrémente le compteur d'animation de chaque étoile, et le réinitialise
;              avec randomisation de position quand il atteint les seuils min/max.
; In:  Rien (utilise wPlayerUnk12 comme base des structures d'objets)
; Out: Rien
; Modifie: af, bc, de, hl
UpdateCreditsStars:
    ld hl, wPlayerUnk12
    ld de, OBJECT_STRUCT_SIZE
    ld b, CREDITS_STAR_COUNT

.animationLoop:
    dec [hl]                              ; Décrémente compteur animation
    ld a, [hl]
    cp CREDITS_ANIM_LOW_THRESH            ; Atteint le seuil bas (1)?
    jr nz, .checkCounterReset

    ld [hl], CREDITS_ANIM_RESET           ; Oui: réinitialiser à 254
    jr .moveToNextSprite

.checkCounterReset:
    cp CREDITS_ANIM_HIGH_THRESH           ; Atteint le seuil haut (224)?
    jr nz, .moveToNextSprite

    ; Randomisation de la position
    push hl
    ldh a, [rDIV]                         ; Source d'aléatoire (timer DIV)
    dec l                                 ; Pointe vers le champ précédent
    add [hl]                              ; Ajoute valeur actuelle
    and CLEAR_BIT7_MASK                   ; Garde bits 0-6
    cp CREDITS_POS_RANDOM_THRESH          ; Comparaison avec seuil 104
    jr nc, .storeOffsetValue

    and ANIM_COUNTER_MASK                 ; Applique masque bits 0-5

.storeOffsetValue:
    ld [hl-], a                           ; Stocke nouvelle position
    ld [hl], FLAG_FALSE                   ; Reset flag
    pop hl

.moveToNextSprite:
    add hl, de                            ; Passe à la structure suivante
    dec b
    jr nz, .animationLoop

    ret

; ===========================================================================
; State33_DisplayCreditsText
; --------------------------
; Description: Affiche le texte des crédits caractère par caractère en VRAM
;              Gère l'animation des crédits et copie le texte sur 2 lignes
; In:  hCopyDstLow/hCopyDstHigh = pointeur source texte crédits
; Out: hGameState incrémenté, pointeur source sauvegardé
; Modifie: a, b, de, hl, hTimer1
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
    ld de, VRAM_CREDITS_ROW1

.displayLoop:
    ld a, [hl]
    cp TEXT_CMD_NEWLINE
    jr z, .handleNewline

    inc hl
    ld b, a

.writeCharToVRAM:
    WAIT_FOR_HBLANK
    WAIT_FOR_HBLANK
    ld a, b
    ld [de], a
    inc de
    ld a, e
    cp VRAM_CREDITS_LIMIT1
    jr z, .switchToRow2

    cp VRAM_CREDITS_LIMIT2
    jr z, .finishRow2

    jr .displayLoop

.handleNewline:
    ld b, TILE_EMPTY
    jr .writeCharToVRAM

.switchToRow2:
    ld de, VRAM_CREDITS_ROW2
    inc hl
    jr .displayLoop

.finishRow2:
    inc hl
    ld a, [hl]
    cp SLOT_EMPTY
    jr nz, .savePointerAndAdvanceState

    ld a, SLOT_EMPTY
    ld [wAudioSaveDE], a

.savePointerAndAdvanceState:
    ld a, h
    ldh [hCopyDstLow], a
    ld a, l
    ldh [hCopyDstHigh], a
    ld hl, hGameState
    inc [hl]
    ret

; ===========================================================================
; State34_WaitCreditsCounter
; --------------------------
; Description: Gère l'attente avec compteur durant l'écran de crédits.
;              Incrémente wLevelInitFlag toutes les 4 frames jusqu'à $20,
;              puis passe à l'état suivant et initialise hTimer1.
; In:  hFrameCounter = compteur de frames global
;      wLevelInitFlag = compteur à incrémenter
; Out: hGameState = incrémenté si wLevelInitFlag atteint $20
;      hTimer1 = TIMER_GAMEPLAY_DELAY ($50) si transition
; Modifie: af, hl (via AnimateCreditsFrame également)
; ===========================================================================
State34_WaitCreditsCounter::
    call AnimateCreditsFrame
    ldh a, [hFrameCounter]
    and FRAME_MASK_4
    ret nz

    ld hl, wLevelInitFlag
    inc [hl]
    ld a, [hl]
    cp TIMER_ANIM_WALK
    ret nz

    ld hl, hGameState
    inc [hl]
    ld a, TIMER_GAMEPLAY_DELAY
    ldh [hTimer1], a
    ret

; ===========================================================================
; État $35 - Attente timer simple ($1451)
; Attend timer, puis état suivant
; ===========================================================================

; State35_WaitTimer
; ----------------
; Description: Attend que hTimer1 atteigne zéro, puis passe à l'état suivant
;              Anime les crédits pendant l'attente
; In:  hTimer1 = compteur timer
; Out: hGameState = incrémenté si timer = 0
; Modifie: a, hl
State35_WaitTimer::
    call AnimateCreditsFrame
    ldh a, [hTimer1]
    and a
    ret nz

    ld hl, hGameState
    inc [hl]
    ret

; State36_CreditsFinalTransition
; -------------------------------
; Description: Transition finale après les crédits. Incrémente un compteur jusqu'à
;              $50 frames, puis bascule vers l'état $33 (crédits texte) ou $37 (sprite finale)
;              selon le flag wAudioSaveDE
; In:  [hFrameCounter] = compteur de frames global
;      [wLevelInitFlag] = compteur local (incrémenté toutes les 4 frames)
;      [wAudioSaveDE] = flag déterminant l'état suivant (SLOT_EMPTY → $37, autre → $33)
; Out: [hGameState] = GAME_STATE_CREDITS_TEXT ($33) ou GAME_STATE_SPRITE_FINAL ($37)
;      [wLevelInitFlag] = 0 (réinitialisé après transition)
; Modifie: af, hl
State36_CreditsFinalTransition::
    call AnimateCreditsFrame
    ldh a, [hFrameCounter]
    and FRAME_MASK_4
    ret nz

    ld hl, wLevelInitFlag
    inc [hl]
    ld a, [hl]
    cp TIMER_GAMEPLAY_DELAY
    ret nz

    xor a
    ld [wLevelInitFlag], a
    ld a, [wAudioSaveDE]
    cp SLOT_EMPTY
    ld a, GAME_STATE_CREDITS_TEXT
    jr nz, SetGameStateRegister

    ld a, GAME_STATE_SPRITE_FINAL

; SetGameStateRegister
; --------------------
; Description: Helper local pour écrire l'état de jeu dans hGameState
; In:  a = nouvel état de jeu (GAME_STATE_*)
; Out: [hGameState] = a
; Modifie: rien (juste écriture mémoire)
SetGameStateRegister:
    ldh [hGameState], a
    ret

; ===========================================================================
; État $37 - Animation sprite finale ($147F)
; Anime sprite vers $D0, copie données tilemap, incrémente niveau
; ===========================================================================
; State37_FinalSpriteAnimation
; ----------------------------
; Description: Anime la princesse jusqu'à Y=$D0, puis setup l'écran final des crédits
; In:  wPlayerState = position Y courante de la princesse
; Out: hGameState incrémenté vers état suivant si animation terminée
; Modifie: a, b, de, hl
State37_FinalSpriteAnimation::
    call AnimateCreditsFrame
    ld hl, wPlayerState
    inc [hl]
    ld a, [hl]
    cp PRINCESS_ANIM_THRESHOLD
    ret nz

    dec l
    ld [hl], SPRITE_ANIM_RESET
    push hl
    call SwitchBankAndCallBank3Handler
    pop hl
    dec l
    ld [hl], SLOT_EMPTY
    ld hl, wTilemapBuf70
    ld de, ROM_TILEMAP_END_DATA
    ld b, TILEMAP_END_DATA_SIZE

State37_CopyTilemapData:
    ld a, [de]
    ld [hl+], a
    inc de
    dec b
    jr nz, State37_CopyTilemapData

    ld b, TILEMAP_END_DATA_SIZE
    xor a

State37_ClearTilemapBuffer:
    ld [hl+], a
    dec b
    jr nz, State37_ClearTilemapBuffer

    ld a, TIMER_CREDITS_SETUP
    ldh [hTimer1], a
    ldh a, [hLevelIndex]
    inc a
    ldh [hLevelIndex], a
    ld [wLevelType], a
    ld hl, hGameState
    inc [hl]
    ret

; === Table de données tilemap ($14BB-$14D2) ===
; TilemapEndData
; --------------
; Description: Données tilemap pour l'écran final des crédits (6 entrées × 4 bytes)
;              Copiée vers wTilemapBuf70 par State37_FinalSpriteAnimation
;              Structure probable: Y_offset, attribut/X_hi, tile_id, padding/bank
; Format: db Y_offset, attr, tile_id, padding (×6)
TilemapEndData:
    db $4E, $CC, $52, $00  ; Entrée 0
    db $4E, $D4, $53, $00  ; Entrée 1
    db $4E, $DC, $54, $00  ; Entrée 2
    db $4E, $EC, $54, $00  ; Entrée 3
    db $4E, $F4, $55, $00  ; Entrée 4
    db $4E, $FC, $56, $00  ; Entrée 5

; ===========================================================================
; State38_CreditsAnimation
; ----------------
; Description: Animation finale des crédits, décrémente les positions tilemap
;              jusqu'à atteindre les positions cibles de fin
; In:  hTimer1 = compteur de frames
; Out: -
; Modifie: af, hl (via AnimateCreditsFrame, InitializeCreditsMode)
; ===========================================================================
State38_CreditsAnimation::
    call AnimateCreditsFrame
    ldh a, [hTimer1]
    and a
    ret nz

    ; Vérifier si première position tilemap a atteint sa cible
    ld hl, wTilemapBuf71
    ld a, [hl]
    cp CREDITS_POS_BUF71
    jr z, CheckTilemapCompletion

DecrementTilemapPositions:
    ; Décrémenter 3 fois la position courante
    dec [hl]
    dec [hl]
    dec [hl]
    ret


; CheckTilemapCompletion
; ----------------
; Description: Vérifie si toutes les positions tilemap ont atteint leurs valeurs finales
; In:  -
; Out: -
; Modifie: af, hl
CheckTilemapCompletion:
    ld hl, wTilemapBuf75
    ld a, [hl]
    cp CREDITS_POS_BUF75
    jr nz, DecrementTilemapPositions

    ld hl, wTilemapBuf79
    ld a, [hl]
    cp CREDITS_POS_BUF79
    jr nz, DecrementTilemapPositions

    ld hl, wTilemapBuf7D
    ld a, [hl]
    cp CREDITS_POS_BUF7D
    jr nz, DecrementTilemapPositions

    ld hl, wTilemapBuf81
    ld a, [hl]
    cp CREDITS_POS_BUF81
    jr nz, DecrementTilemapPositions

    ld hl, wTilemapBuf85
    ld a, [hl]
    cp CREDITS_POS_BUF85
    jr nz, DecrementTilemapPositions

    ; Toutes les positions ont atteint leurs cibles -> réinitialiser pour mode démo
    call InitializeCreditsMode
    xor a
    ldh [hRenderContext], a
    ldh [hTimerAux], a
    ldh [hSubState], a
    ld [wGameConfigA6], a
    ld a, INIT_ANIM_TILE_IDX
    ldh [hAnimTileIndex], a
    ret


; InitializeCreditsMode
; ----------------
; Description: Initialise le mode démo si une touche est pressée
; In:  hJoypadDelta = touches pressées depuis dernière frame
; Out: -
; Modifie: af (via ROM_INIT_BANK3 et SetupCreditsState si touche pressée)
InitializeCreditsMode:
    ldh a, [hJoypadDelta]
    and a
    ret z

    call ROM_INIT_BANK3

; SetupCreditsState
; ----------------
; Description: Configure la bank et l'état du jeu pour mode démo
; In:  -
; Out: -
; Modifie: af
SetupCreditsState:
    ld a, BANK_DEMO
    ldh [hCurrentBank], a
    ld [rROMB0], a
    ld [wCurrentROMBank], a
    ld [wROMBankInit], a
    xor a
    ld [wLevelData], a
    ld [wGameConfigA5], a
    ld [wPlayerVarAD], a
    ld a, IE_VBLANK_STAT
    ldh [rIE], a
    ld a, GAME_STATE_DEMO
    ldh [hGameState], a
    ret


; AnimateCreditsFrame
; ----------------
; Description: Anime une frame des crédits (sprites et étoiles)
; In:  -
; Out: -
; Modifie: af, bc, de, hl (via AnimateAndCallBank3, UpdateCreditsStars)
AnimateCreditsFrame:
    call AnimateAndCallBank3
    call UpdateCreditsStars
    ret

; === TextData_CreditsStaff ($154E-$1583) ===
; TextData_CreditsStaff
; ---------------------
; Description: Données texte des crédits affichées dans State33_DisplayCreditsText
;              Référencé par ROM_CREDITS_TEXT ($154E) dans constants.inc
;              Format: caractères tilemap encodés, $FE = TEXT_CMD_NEWLINE
;              Contient 6 lignes de texte pour l'écran de crédits final
; Structure: 54 bytes au total ($154E-$1583)
TextData_CreditsStaff:
    db $19, $1b, $18, $0d, $1e, $0c, $0e, $1b, $fe  ; Ligne 1: "producer" + newline (9 bytes)
    db $10, $23, $22, $18, $14, $18, $12, $fe        ; Ligne 2: nom producteur + newline (8 bytes)
    db $0d, $12, $1b, $0e, $0c, $1d, $18, $1b, $fe  ; Ligne 3: "director" + newline (9 bytes)
    db $1c, $23, $18, $14, $0a, $0d, $0a, $fe        ; Ligne 4: nom directeur + newline (8 bytes)
    db $19, $1b, $18, $10, $1b, $0a, $16, $16, $0e, $1b, $fe  ; Ligne 5: "programmer" + newline (11 bytes)
    db $16, $23, $22, $0a, $16, $0a, $16, $18, $1d  ; Ligne 6: nom programmeur (9 bytes)

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

PipeEnterRightMoveCheck:
    rla
    jr State09_PipeEnterRight.checkTarget

    cp $17
    ld [de], a
    inc e
    ld de, $2712
    ld a, [bc]
    jr nz, State09_PipeEnterRight.moveRight

    cp $ff

; State09_PipeEnterRight
; ----------------------
; Description: Gère l'entrée du joueur dans un tuyau par la droite
;              Déplace le joueur pixel par pixel vers la position X cible jusqu'à
;              atteindre la coordonnée stockée, puis charge le sous-niveau
; In:  hVBlankSelector = position X cible
; Out: hGameState = GAME_STATE_PIPE_LOAD quand cible atteinte
;      hVBlankMode = GAME_STATE_PIPE_LOAD quand cible atteinte
; Modifie: hl, a
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
    ld a, GAME_STATE_PIPE_LOAD
    ldh [hGameState], a          ; Transition vers état $0A
    ldh [hVBlankMode], a
    ret

; State0A_LoadSubLevel
; --------------------
; Description: Charge un sous-niveau après une entrée par tuyau
;              Désactive l'écran, nettoie la mémoire, charge les données du niveau,
;              repositionne le joueur et réactive l'affichage
; In:  Aucun
; Out: hGameState = GAME_STATE_TITLE (retour état $00)
; Modifie: a, hl, flags
State0A_LoadSubLevel::
    di
    xor a
    ldh [rLCDC], a               ; LCD off
    ldh [hTilemapScrollY], a     ; Reset scroll Y
    call ClearOamAndSpriteBuffers
    call ClearTilemapBuffer
    ldh a, [hRenderCounter]
    ldh [hTilemapScrollX], a     ; Init scroll X
    call LoadLevelData           ; Charge données niveau
    call FindAudioTableEntry     ; Configure audio
    ld hl, wPlayerX
    ld [hl], $20                 ; Position X initiale du sous-niveau
    inc l                        ; hl = wPlayerState
    ld [hl], $1d                 ; État initial
    inc l                        ; hl = wPlayerDir
    inc l                        ; hl = wPlayerDir+1
    ld [hl], $00                 ; Reset
    xor a
    ldh [rIF], a                 ; Clear interrupts
    ldh [hGameState], a          ; Retour état $00 (GAME_STATE_TITLE)
    ldh [hShadowSCX], a          ; Reset shadow scroll
    ld a, LCDC_GAME_STANDARD
    ldh [rLCDC], a               ; Réactive LCD
    ei
    ret


; ClearTilemapBuffer
; ------------------
; Description: Efface le buffer tilemap en mettant tous les octets à zéro.
;              Procède par décrémentation depuis la fin du buffer.
; In:  (aucun)
; Out: (aucun)
; Modifie: hl, bc, a
ClearTilemapBuffer::
    ld hl, wTilemapBufferEnd
    ld bc, TILEMAP_BUFFER_SIZE

.loop:
    xor a
    ld [hl-], a
    dec bc
    ld a, b
    or c
    jr nz, .loop

    ret

; ===========================================================================
; State0B_PipeEnterDown
; ---------------------
; Description: Gère la descente du joueur dans un tuyau vertical
;              Déplace le joueur pixel par pixel vers le bas jusqu'à la position
;              cible, puis charge le niveau de destination et transite vers
;              l'état $0C (sortie de tuyau)
; In:  hFrameCounter = compteur de frames
;      hVBlankSelector = position Y cible (point d'arrivée)
;      hRenderMode = mode de rendu (sauvegardé dans hTilemapScrollX)
;      hDestX/hDestY = coordonnées de destination dans le nouveau niveau
; Out: hGameState = GAME_STATE_PIPE_EXIT ($0C) une fois arrivé
;      wPlayerX/wPlayerY = position du joueur dans le nouveau niveau
;      hVBlankSelector = nouvelle cible X pour la sortie du tuyau
; Modifie: a, bc, de, hl
; ===========================================================================
State0B_PipeEnterDown::
    ldh a, [hFrameCounter]
    and FRAME_MASK_2             ; 1 frame sur 2 seulement
    ret z

    ld hl, wPlayerState
    ldh a, [hVBlankSelector]     ; Position Y cible
    cp [hl]                      ; Atteint la cible ?
    jr c, .loadDestLevel

    inc [hl]                     ; Descend d'un pixel
    ld hl, wPlayerUnk0B
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
    ldh a, [hDestX]              ; Position X destination
    ld d, a
    ldh a, [hDestY]              ; Position Y destination
    ld e, a
    push de
    call LoadLevelData
    pop de
    ld a, PLAYER_ANIM_INITIAL
    ld [wPlayerFlag], a          ; Flag joueur actif
    ld hl, wPlayerX
    ld a, d
    ld [hl+], a                  ; wPlayerX = destination X
    sub PIPE_EXIT_X_OFFSET
    ldh [hVBlankSelector], a     ; Cible X pour sortie
    ld a, e
    ld [hl], a                   ; wPlayerY = destination Y
    ldh a, [hTilemapScrollX]
    sub COLLISION_OFFSET_4
    ld b, a
    rlca
    rlca
    rlca
    add b
    add b
    add SCROLL_Y_CALC_OFFSET
    ld [wPlayerVarAB], a
    xor a
    ldh [rIF], a
    ldh [hShadowSCX], a
    ld a, SCROLL_COLUMN_INIT
    ldh [hScrollColumn], a
    call FindAudioTableEntry
    call ClearOamAndSpriteBuffers
    ld a, LCDC_GAME_STANDARD
    ldh [rLCDC], a               ; LCD on
    ld a, GAME_STATE_PIPE_EXIT
    ldh [hGameState], a          ; Transition vers état $0C
    call RenderPlayerUpdate
    ei
    ret

; ===========================================================================
; State0C_PipeExitLeft
; --------------------
; Description: État $0C - Sortie tuyau gauche. Déplace le joueur
;              horizontalement vers la position cible puis retourne
;              à l'état $00 (gameplay normal).
; In:  hFrameCounter = compteur de frames
;      hVBlankSelector = position X cible
;      wPlayerX = position X actuelle du joueur
; Out: hGameState = $00 si sortie complète
;      wPlayerFlag = 0 si sortie complète
;      hVBlankMode = 0 si sortie complète
; Modifie: a, hl
; ===========================================================================
State0C_PipeExitLeft::
    ldh a, [hFrameCounter]
    and FRAME_MASK_2             ; 1 frame sur 2 seulement
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
    ld [wPlayerFlag], a
    ldh [hVBlankMode], a
    ret

; UpdatePipeAnimation
; -------------------
; Description: Gère l'animation du joueur pendant les transitions de tuyau.
;              Appelle le handler bank 3, puis ajuste la direction du joueur
;              en fonction de l'état d'animation.
; In:  wPlayerUnk0A = flag d'état animation
;      wPlayerDir = direction actuelle
;      wPlayerUnk0E = état d'animation
;      wPlayerUnk0B = compteur de frames
; Out: Aucun
; Modifie: a, hl
UpdatePipeAnimation:
    call SwitchBankAndCallBank3Handler
    ld a, [wPlayerUnk0A]
    and a
    jr z, State0C_ProcessAnimation

    ld a, [wPlayerDir]
    and NIBBLE_LOW_MASK          ; Isoler mode direction
    cp PLAYER_MODE_GAMEPLAY      ; Mode gameplay standard ($0a)
    jr nc, State0C_ProcessAnimation

    ld hl, wPlayerUnk0B
    ld a, [wPlayerUnk0E]
    cp PLAYER_ANIM_STATE_PIPE    ; État animation pipe (frame lente)
    ld a, [hl]
    jr z, State0C_CheckOddFrame

    and FRAME_MASK_4
    jr nz, State0C_ProcessAnimation

State0C_IncrementPlayerDir:
    ld hl, wPlayerDir
    ld a, [hl]
    cp PLAYER_DIR_LEFT
    jr z, State0C_ProcessAnimation

    inc [hl]
    ld a, [hl]
    and NIBBLE_LOW_MASK          ; Isoler mode direction
    cp PLAYER_DIR_MODE_INTERACT  ; $04 = seuil interaction
    jr c, State0C_ProcessAnimation

    ld a, [hl]
    and NIBBLE_HIGH_MASK         ; Garder bits hauts
    or PLAYER_DIR_MODE_RESET     ; Reset au mode 1
    ld [hl], a

State0C_ProcessAnimation:
    call ProcessAnimationState
    ret


State0C_CheckOddFrame:
    and FRAME_MASK_2             ; 1 frame sur 2 seulement
    jr nz, State0C_ProcessAnimation

    jr State0C_IncrementPlayerDir

; SwitchBankAndCallBank3Handler
; ----------------
; Description: Configure les paramètres d'animation puis switch vers bank 3
;              pour appeler AnimationHandler, puis restaure la bank précédente
; In:  Aucun
; Out: hParam1 = PLAYER_POS_THRESHOLD ($C0), hParam2 = PLAYER_VAR_AB_INIT ($0C),
;      hParam3 = RENDER_CONTEXT_GAMEPLAY ($05), hl = wPlayerY
; Modifie: a, hl (via AnimationHandler en bank 3)
SwitchBankAndCallBank3Handler:
    ; --- SetupParameters ---
    ld a, PLAYER_VAR_AB_INIT
    ldh [hParam2], a          ; Paramètre = $0C (12)
    ld hl, wPlayerY            ; HL = adresse player data
    ld a, PLAYER_POS_THRESHOLD
    ldh [hParam1], a          ; Paramètre 2 = $C0
    ld a, RENDER_CONTEXT_GAMEPLAY
    ldh [hParam3], a          ; Paramètre 3 = $05

    ; --- SaveCurrentBank ---
    ldh a, [hCurrentBank]          ; Lire bank courante
    ldh [hSavedBank], a          ; Sauvegarder dans temp

    ; --- SwitchToBank3 ---
    ld a, BANK_AUDIO
    ldh [hCurrentBank], a          ; Mettre à jour shadow register
    ld [rROMB0], a           ; MBC: switch vers bank 3

    ; --- CallTargetRoutine ---
    call AnimationHandler   ; Appeler routine d'animation en bank 3

    ; --- RestorePreviousBank ---
    ldh a, [hSavedBank]          ; Récupérer bank sauvegardée
    ldh [hCurrentBank], a          ; Restaurer shadow register
    ld [rROMB0], a           ; MBC: restaurer bank
    ret


; TileE1CollisionHandler
; ----------------------
; Description: Handler de collision pour tile E1 (warp/transition spéciale)
;              Comportement différent selon le mode (jeu vs démo)
; In:  -
; Out: -
; Modifie: a (via jumps)
TileE1CollisionHandler:
    ldh a, [hGameState]
    cp GAME_STATE_DEMO      ; État >= $0E (démo) ?
    jp nc, BlockCollisionPropertyHandler

    jp TriggerBlockCollisionSound_TimerDispatch


; CheckJoypadUp_GameplayLoop
; --------------------------
; Description: Gère entrée du joueur dans un tuyau (pipe) par le haut
;              Vérifie bouton haut pressé et copie données VRAM vers buffer de rendu
;              puis change l'état du jeu vers PIPE_ENTER_RIGHT
; In:  hl = pointeur vers données (position/tile info)
; Out: (aucun) - Change hGameState, wStateRender, met à jour wPlayerX
; Modifie: a, bc, de, hl
CheckJoypadUp_GameplayLoop:
    ldh a, [hJoypadState]
    bit 7, a                    ; Bit 7 = bouton Haut pressé ?
    jp z, PlayerXPositionReset

    ; Copie données depuis hl vers HRAM pour rendu
    ld bc, hVramPtrLow
    ld a, h
    ldh [hSpriteAttr], a
    ld a, l
    ldh [hSpriteTile], a
    ld a, h
    add BCD_TO_ASCII            ; Conversion BCD → ASCII
    ld h, a
    ld de, hRenderCounter
    ld a, [hl]
    and a                       ; Valeur = 0 ?
    jp z, PlayerXPositionReset

    ; Copie 4 bytes de données de hl vers de (buffer de rendu)
    ld [de], a                  ; Byte 1
    inc e
    add hl, bc
    ld a, [hl]
    ld [de], a                  ; Byte 2
    inc e
    add hl, bc
    ld a, [hl]
    ld [de], a                  ; Byte 3
    inc e
    add hl, bc
    ld a, [hl]
    ld [de], a                  ; Byte 4
    inc e
    push de
    call GetSpritePosFromTileAddr
    pop de
    ; Calcule et sauvegarde position du joueur
    ld hl, wPlayerX
    ld a, [hl+]
    add PLAYER_X_OFFSET         ; Ajuste Y joueur (+16)
    ld [de], a                  ; Stocke Y dans buffer
    ldh a, [hShadowSCX]
    ld b, a
    ldh a, [hSpriteX]
    sub b
    add TILE_SIZE_PIXELS        ; Ajuste X du tuyau (+8)
    ld [hl+], a                 ; Mise à jour X joueur (wPlayerX+1)
    inc l
    ld [hl], $80                ; Flag spécial à wPlayerX+3

    ; Change état jeu → entrée tuyau
    ld a, GAME_STATE_PIPE_ENTER_RIGHT
    ldh [hGameState], a

    ; Si joueur invulnérable, skip update rendu
    ld a, [wPlayerInvuln]
    and a
    jr nz, SkipIfInvuln_OnTile

    ; Active mode rendu spécial
    ld a, STATE_RENDER_SPECIAL
    ld [wStateRender], a

SkipIfInvuln_OnTile:
    call ClearOamAndSpriteBuffers
    jp PlayerXPositionReset


; -----------------------------------------------------------------------------
; CheckPlayerHeadCollision
; ------------------------
; Description: Vérifie collision de la tête du joueur avec les tiles au-dessus
;              Calcule position tête (X avec scroll + ajustements, Y avec offset)
;              et teste les tiles pour détecter collisions solides ou spéciales
; In:  (aucun)
; Out: (aucun) - Met à jour wPlayerX, wPlayerUnk07, wPlayerUnk0A, wPlayerUnk0E selon collision
; Modifie: a, b, hl, hSpriteX, hSpriteY
CheckPlayerHeadCollision:
    ld hl, wPlayerUnk07
    ld a, [hl]
    cp FLAG_TRUE                ; Collision déjà détectée ?
    ret z

    ld hl, wPlayerX
    ld a, [hl+]
    add HEAD_COLLISION_OFFSET_Y  ; Offset Y tête joueur (+11)
    ldh [hSpriteY], a
    ldh a, [hShadowSCX]
    ld b, a
    ld a, [hl]
    add b
    add HEAD_COLLISION_ADJUST_X  ; Ajustement hitbox X (-2)
    ldh [hSpriteX], a
    call ReadTileUnderSprite
    cp TILEMAP_CMD_SCROLL        ; Tile scroll $70 ?
    jr z, CheckJoypadUp_GameplayLoop

    cp TILEMAP_CMD_E1            ; Tile collision spéciale E1 ?
    jp z, TileE1CollisionHandler

    cp TILEMAP_CMD_THRESHOLD    ; Tile >= $60 ?
    jr nc, CheckBlockProperties_OnCollide

    ld a, [wPlayerUnk0E]
    ld b, COLLISION_OFFSET_4
    cp COLLISION_OFFSET_4
    jr nz, .testSecondHitboxPoint

    ld a, [wPlayerUnk07]
    and a
    jr nz, .testSecondHitboxPoint

    ld b, COLLISION_OFFSET_8

.testSecondHitboxPoint:
    ; Test second point de collision (décalé de 4 ou 8 pixels en X)
    ldh a, [hSpriteX]
    add b
    ldh [hSpriteX], a
    call ReadTileUnderSprite
    cp TILEMAP_CMD_THRESHOLD    ; Tile >= $60 ?
    jr nc, CheckBlockProperties_OnCollide

; HandleBlockType_Collision
; -------------------------
; Description: Gère la collision du joueur avec un bloc solide
;              Repousse le joueur de 3 pixels vers la droite et active l'état de chute
; In:  Aucun (appelé depuis CheckBlockProperties_OnCollide)
; Out: Aucun
; Modifie: a, hl
HandleBlockType_Collision:
    ; Si le joueur est déjà en train de tomber, ignorer la collision
    ld hl, wPlayerUnk07
    ld a, [hl]
    cp PLAYER_UNK07_FALLING
    ret z

    ; Repousser le joueur de 3 pixels vers la droite
    ld hl, wPlayerX
    inc [hl]
    inc [hl]
    inc [hl]

    ; Réinitialiser un compteur/état lié au mouvement
    ld hl, wPlayerUnk0A
    ld [hl], $00

    ; Si wPlayerUnk0E est déjà actif, ne pas modifier l'état de chute
    ld a, [wPlayerUnk0E]
    and a
    ret nz

    ; Activer l'état de chute
    ld a, PLAYER_UNK07_FALLING
    ld [wPlayerUnk0E], a
    ret


; CheckBlockProperties_OnCollide
; -------------------------------
; Description: Vérifie les propriétés du bloc en collision avec le joueur
;              Gère les tiles dangereuses ($ED) et les tuyaux ($F4) selon l'état du joueur
; In:  a = ID du tile en collision (tile >= $60)
;      de = coordonnées du tile
; Out: Aucun (peut sauter vers d'autres handlers ou initialiser le joueur)
; Modifie: a, de, hl
BlockCollisionPropertyHandler:
CheckBlockProperties_OnCollide:
    cp TILEMAP_CMD_DANGER        ; Tile danger $ED ?
    push af
    jr nz, ProcessBlockEnd_OnCollide

    ld a, [wPlayerInvuln]
    and a
    jr nz, ProcessBlockEnd_OnCollide

    ldh a, [hTimerAux]
    and a
    jr z, InitGameAfterBlock_OnCollide

    cp COLLISION_OFFSET_4
    jr z, ProcessBlockEnd_OnCollide

    cp PLAYER_UNK07_FALLING
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
    cp TILEMAP_CMD_PIPE         ; Tile tuyau $F4 ?
    jr nz, InitPlayerX

    push hl
    pop de
    ld hl, hBlockHitType
    ld a, [hl]
    and a
    jr nz, HandleBlockType_Collision

    ld [hl], BLOCK_HIT_TYPE_SPECIAL
    inc l
    ld [hl], d
    inc l
    ld [hl], e
    ld a, STATE_BUFFER_COIN
    ld [wStateBuffer], a
    jr HandleBlockType_Collision

; PlayerXPositionReset / InitPlayerX
; --------------------------------
; Description: Réinitialise la position X du joueur et ses variables de mouvement
;              Position X est reculée de 2px puis alignée sur grille 4px (offset +6)
; In:  -
; Out: -
; Modifie: a, hl
PlayerXPositionReset:
InitPlayerX:
    ; Recule de 2px puis aligne X sur grille 4 pixels avec offset de 6
    ld hl, wPlayerX
    ld a, [hl]
    dec a                        ; X -= 2 pixels
    dec a
    and SCROLL_ALIGN_MASK        ; Aligner sur 4 pixels
    or TILE_ALIGN_OFFSET         ; Ajoute offset +6
    ld [hl], a

    ; RAZ variables mouvement (wPlayerUnk07..09 = 0, wPlayerUnk0A = 1)
    xor a
    ld hl, wPlayerUnk07
    ld [hl+], a                  ; wPlayerUnk07 = 0
    ld [hl+], a                  ; wPlayerUnk08 = 0
    ld [hl+], a                  ; wPlayerUnk09 = 0
    ld [hl], $01                 ; wPlayerUnk0A = 1

    ; Limite wPlayerUnk0C à 6 si >= 7
    ld hl, wPlayerUnk0C
    ld a, [hl]
    cp COLLISION_THRESHOLD_7
    ret c

    ld [hl], COLLISION_OFFSET_6
    ret


; CollisionHandler_Type5F_Entry
; ------------------------------
; Description: Handler de collision pour le tile type $5F (plateforme conditionnelle)
; In:  hl = pointeur bloc collision
; Out: Peut continuer vers CollisionHandler_Platform_Entry si valeur table non-nulle
; Modifie: a, hl (temporairement via push/pop)
CollisionHandler_Type5F_Entry:
    ldh a, [hBlockHitType]
    and a
    ret nz

    push hl
    ld a, h
    add BCD_TO_ASCII
    ld h, a
    ld a, [hl]
    pop hl
    and a
    ret z

; CollisionHandler_Platform_Entry
; --------------------------------
; Description: Gère la collision avec une plateforme/tile interactive
; In:  hl = adresse tile dans tilemap
; Out: Peut sauter vers PlayerWaterCollisionEntry ou setup sprite/son
; Modifie: a, bc, de, hl (via appels)
CollisionHandler_Platform_Entry:
    ldh a, [hBlockHitType]
    and a
    ret nz

    push hl
    ld a, h
    add BCD_TO_ASCII
    ld h, a
    ld a, [hl]
    pop hl
    and a
    jp z, PlayerWaterCollisionEntry

    cp TILE_SPECIAL_THRESHOLD   ; Tile $F0 = special/vide
    jr z, HandleTileValueF0

; TileC0Handler
; -------------
; Description: Gère collision avec blocs spéciaux (tile $C0). Vide le slot niveau,
;              puis configure état collision coin si aucune collision active.
; In:  a = valeur tile collision (doit être BLOCK_HIT_TYPE_SPECIAL = $C0)
;      hl = adresse tile dans map
; Out: wLevelConfig = SLOT_EMPTY, délégué à ApplyAltSpriteAttributeIfConfigSet ou PlatformCollisionSetup
; Modifie: a, délégué aux handlers appelés
TileC0Handler:
    cp BLOCK_HIT_TYPE_SPECIAL
    jr nz, HandleNonC0TileValue

    ld a, SLOT_EMPTY
    ld [wLevelConfig], a

; PlatformCollisionSetup
; ----------------------
; Description: Configure collision plateforme si pas déjà active. Si hBlockHitType est 0,
;              initialise l'état collision pièce et les paramètres associés.
; In:  hBlockHitType = type collision actuelle (0 = pas de collision)
;      wPlayerX = position X joueur
;      wLevelConfig = configuration niveau courante
; Out: wStateBuffer = STATE_BUFFER_COIN si collision initialisée
;      hPtrHigh = position X joueur - offset
;      hPtrBank, hPendingCoin = BLOCK_HIT_TYPE_SPECIAL ($C0)
; Modifie: a
PlatformCollisionSetup:
    ldh a, [hBlockHitType]
    and a
    ret nz

    ld a, STATE_BUFFER_COIN
    ld [wStateBuffer], a
    ld a, [wPlayerX]
    sub PLAYER_X_OFFSET
    ldh [hPtrHigh], a
    ld a, BLOCK_HIT_TYPE_SPECIAL
    ldh [hPtrBank], a
    ldh [hPendingCoin], a
    ld a, [wLevelConfig]
    and a
    jr nz, ApplyAltSpriteAttributeIfConfigSet

; HandleTileValueF0
; -----------------
; Description: Gère collision avec tile valeur $F0 (tile vide/traversable spécial).
;              Cache le sprite OAM et configure les propriétés de sprite standard.
; In:  hl = adresse tile (conservé pour SetupSpriteProperties)
; Out: (délégué à SetupSpriteProperties)
; Modifie: a
HandleTileValueF0:
    ld a, OAM_SPRITE_HIDDEN
    ld [wOamVar2E], a
    jr SetupSpriteProperties

; HandleNonC0TileValue
; --------------------
; Description: Gère collision avec tiles normales (valeur != $C0 et != $F0).
;              Initialise sprite OAM, stocke adresse tile, calcule position sprite,
;              et joue le son approprié selon le type de collision.
; In:  a = valeur tile collision
;      hl = adresse tile dans map
; Out: (aucun retour spécifique)
; Modifie: a, bc, de, hl, hTemp0, hSpriteAttr, hSpriteTile, hSoundParam1, hSoundParam2
HandleNonC0TileValue:
    ldh [hTemp0], a
    ld a, OAM_SPRITE_HIDDEN
    ld [wOamVar2E], a
    ld a, STATE_BUFFER_DEFAULT
    ld [wStateBuffer], a
    push hl
    pop de
    ld hl, hBlockHitType
    ld a, [hl]
    and a
    ret nz

    ld [hl], PLAYER_UNK07_FALLING
    inc l
    ld [hl], d
    inc l
    ld [hl], e
    ld a, d
    ldh [hSpriteAttr], a
    ld a, e
    ldh [hSpriteTile], a
    ld a, d
    add BCD_TO_ASCII
    ld d, a
    ld a, [de]
    ldh [hTemp0], a
    call GetSpritePosFromTileAddr
    ld hl, wOamVar2C
    ld a, [wPlayerX]
    sub PLAYER_X_SUB_OFFSET
    ld [hl+], a
    ldh [hSoundParam1], a
    ldh [hRenderX], a
    ldh a, [hShadowSCX]
    ld b, a
    ldh a, [hSpriteX]
    ldh [hRenderY], a

CalculateRelativeSpriteX:
    sub b
    ld [hl+], a
    ldh [hSoundParam2], a
    inc l
    ld [hl], $00
    ldh a, [hTemp0]
    cp AUDIO_CMD_F0             ; Commande audio spéciale
    ret z

    cp SFX_BLOCK_HIT
    jr nz, PlaySoundExit

    ldh a, [hTimerAux]
    cp PLAYER_UNK07_FALLING
    ld a, SFX_BLOCK_HIT
    jr nz, PlaySoundExit

    ld a, SFX_BLOCK_HIT_ALT

; PlaySoundExit
; ----------------
; Description: Point de sortie commun pour jouer un son et retourner
; In:  a = identifiant du son à jouer (SFX_*)
; Out: (aucun)
; Modifie: a, bc, de, hl (via PlaySound)
PlaySoundExit:
    call PlaySound
    ret

; ApplyAltSpriteAttributeIfConfigSet
; ----------------------------------
; Description: Applique un attribut sprite alternatif (tile $82) si aucune
;              collision bloc n'est active. Initialise le buffer d'état si
;              nécessaire, puis continue vers SetupSpriteProperties.
; In:  hBlockHitType = type collision active (0=aucune)
;      wStateBuffer = buffer état
;      hl = adresse tile (passée à SetupSpriteProperties)
; Out: wOamVar2E = OAM_SPRITE_TILE_82 ($82) si pas de collision
;      wStateBuffer = STATE_BUFFER_DEFAULT ($07) si était zéro
; Modifie: a, puis appelle SetupSpriteProperties
ApplyAltSpriteAttributeIfConfigSet:
    ldh a, [hBlockHitType]
    and a
    ret nz

    ld a, OAM_SPRITE_TILE_82
    ld [wOamVar2E], a
    ld a, [wStateBuffer]
    and a
    jr nz, SetupSpriteProperties

    ld a, STATE_BUFFER_DEFAULT
    ld [wStateBuffer], a

; SetupSpriteProperties
; ---------------------
; Description: Configure propriétés sprite après collision tile.
;              Sauvegarde adresse tile, configure état collision (chute),
;              calcule position sprite depuis adresse tile, ajuste position
;              selon joueur et scroll, et initialise variables de rendu.
; In:  hl = adresse tile (dans tilemap)
;      wPlayerX = position X joueur
;      wOamVar2E = tile sprite déjà configuré par appelant
;      hShadowSCX = scroll X actuel
; Out: hBlockHitType = PLAYER_UNK07_FALLING ($02)
;      hSpriteAttr, hSpriteTile = coordonnées tile (de/hl copié)
;      hSpriteX = position X sprite calculée (via GetSpritePosFromTileAddr)
;      wOamVar2C = position joueur ajustée (wPlayerX - $0b)
;      wOamVar2D = position sprite relative au scroll
;      wOamVar2F = $00
;      hRenderX = position joueur ajustée
;      hRenderY = position sprite Y
;      hPtrLow = position relative scroll
; Modifie: a, bc, de, hl
SetupSpriteProperties:
    push hl
    pop de
    ld hl, hBlockHitType
    ld [hl], PLAYER_UNK07_FALLING
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
    sub PLAYER_X_SUB_OFFSET
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

; HandlePlayerUpCollision
; -----------------------
; Description: Gère collision vers le haut (joueur frappe un bloc).
;              Vérifie s'il y a déjà une collision active, lit la valeur
;              du bloc dans la zone haute mémoire (h + $30), et route vers
;              TileC0Handler si bloc non-vide, sinon configure sprite coin.
; In:  hl = adresse tile dans tilemap
;      hBlockHitType = état collision (doit être 0 pour continuer)
; Out: Si bloc vide: wStateBuffer = STATE_BUFFER_COIN, sprite configuré via SetupSpriteProperties
;      Si bloc non-vide: délégué à TileC0Handler
; Modifie: a, hl (temporairement), délégué aux handlers appelés
HandlePlayerUpCollision:
    ldh a, [hBlockHitType]
    and a
    ret nz

    push hl
    ld a, h
    add BCD_TO_ASCII
    ld h, a
    ld a, [hl]
    pop hl
    and a
    jp nz, TileC0Handler

    ld a, STATE_BUFFER_COIN
    ld [wStateBuffer], a
    ld a, OAM_SPRITE_TILE_81
    ld [wOamVar2E], a
    ld a, [wPlayerX]
    sub PLAYER_X_OFFSET
    ldh [hPtrHigh], a
    ld a, BLOCK_HIT_TYPE_SPECIAL
    ldh [hPtrBank], a
    jr SetupSpriteProperties

; CheckPlayerFeetCollision
; ------------------------
; Description: Vérifie collision des pieds du joueur avec les tiles du niveau.
;              Teste deux points (gauche et droite des pieds) pour détecter sol,
;              eau, plateformes et tiles spéciales. Gère transitions d'état.
; In:  wPlayerUnk07 = état vertical joueur (doit être GROUNDED)
;      wPlayerX = position X/Y du joueur, hShadowSCX = scroll camera
; Out: (varie selon collision détectée - handlers appelés modifient états)
; Modifie: a, bc, hl, hSpriteX, hSpriteY
CheckPlayerFeetCollision:
    ld a, [wPlayerUnk07]
    cp PLAYER_UNK07_GROUNDED
    ret nz

    ld hl, wPlayerX
    ld a, [hl+]
    add FEET_COLLISION_OFFSET_Y
    ldh [hSpriteY], a
    ldh a, [hShadowSCX]
    ld b, [hl]
    add b
    add FEET_COLLISION_ADJUST_X
    ldh [hSpriteX], a
    call ReadTileUnderSprite
    cp TILEMAP_CMD_LOAD2        ; Tile type $5F ?
    jp z, CollisionHandler_Type5F_Entry

    cp TILEMAP_CMD_THRESHOLD    ; Tile >= $60 ?
    jr nc, ClassifyTileTypeEntry

    ldh a, [hSpriteX]
    add COLLISION_ADJUST_X_NEG4
    ldh [hSpriteX], a
    call ReadTileUnderSprite
    cp TILEMAP_CMD_LOAD2        ; Tile type $5F ?
    jp z, CollisionHandler_Type5F_Entry

    cp TILEMAP_CMD_THRESHOLD    ; Tile >= $60 ?
    ret c

ClassifyTileTypeEntry:
    call ClassifyTileType
    and a
    ret z

    cp TILEMAP_CMD_WATER        ; Tile eau $82 ?
    jr z, HandlePlayerWaterCollision

    cp TILEMAP_CMD_PIPE         ; Tile tuyau $F4 ?
    jp z, CollisionHandler_SpecialF4_Setup

    cp TILEMAP_CMD_LOAD3        ; Tile type $81 ?
    jr z, HandlePlayerUpCollision

    cp TILEMAP_CMD_LOAD1        ; Tile type $80 ?
    jp z, CollisionHandler_Platform_Entry

    ld a, PLAYER_UNK07_FALLING
    ld [wPlayerUnk07], a
    ld a, STATE_BUFFER_DEFAULT
    ld [wStateBuffer], a
    ret


; HandlePlayerWaterCollision / PlayerWaterCollisionEntry
; -------------------------------------------------------
; Description: Gère collision joueur avec eau (tile $82). Vérifie type bloc,
;              mode timer, puis initialise objets et donne bonus si conditions OK
; In:  hl = pointeur tilemap collision
; Out: -
; Modifie: af, bc, de, hl
PlayerWaterCollisionEntry:
HandlePlayerWaterCollision:
    push hl
    ld a, h
    add BCD_TO_ASCII
    ld h, a
    ld a, [hl]
    pop hl
    cp BLOCK_HIT_TYPE_SPECIAL   ; Type spécial ($C0) ?
    jp z, PlatformCollisionSetup

    ldh a, [hTimerAux]
    cp TIMER_AUX_PIPE_MODE      ; $02 = mode pipe/transition
    jp nz, ApplyAltSpriteAttributeIfConfigSet

    push hl
    pop de
    ld hl, hBlockHitType
    ld a, [hl]
    and a
    ret nz

    ld [hl], FLAG_TRUE          ; Marquer bloc touché
    inc l
    ld [hl], d
    inc l
    ld [hl], e
    ld hl, wPlayerUnk10

; InitializeGameObjects
; ---------------------
; Description: Initialise 4 objets actifs, désactive objets 4-5, ajoute bonus +50
; In:  hl = pointeur vers premier objet à initialiser
; Out: -
; Modifie: af, bc, de, hl
InitializeGameObjects:
    ld de, OBJECT_STRUCT_SIZE
    ld b, INIT_OBJECTS_LOOP_COUNT

InitObjectsLoop:
    push hl
    ld [hl], $00
    inc l
    ld a, [wPlayerX]
    add OBJECT_INIT_X_OFFSET
    ld [hl], a
    inc l
    ld a, [wPlayerState]
    add OBJECT_INIT_Y_OFFSET
    ld [hl], a
    inc l
    inc l
    inc l
    inc l
    inc l
    ld [hl], FLAG_TRUE          ; Flag objet actif
    inc l
    ld [hl], STATE_BUFFER_DEFAULT ; État par défaut ($07)
    pop hl
    add hl, de
    dec b
    jr nz, InitObjectsLoop

    ld hl, wObject2State
    ld a, [hl]
    sub MOVEMENT_OFFSET_4
    ld [hl], a
    ld hl, wObject4Unk0A
    ld a, [hl]
    sub MOVEMENT_OFFSET_4
    ld [hl], a
    ld hl, wObject4
    ld [hl], OBJECT_STATE_INACTIVE
    ld hl, wObject5
    ld [hl], OBJECT_STATE_INACTIVE
    ldh a, [hShadowSCX]
    ldh [hRenderAttr], a
    ld a, STATE_FINAL_COMPLETE
    ld [wStateFinal], a
    ld de, SCORE_BONUS_50
    call AddScore
    ld a, PLAYER_UNK07_FALLING
    ld [wPlayerUnk07], a
    ret


CollisionHandler_SpecialF4_Setup:
    push hl
    pop de
    ld hl, hBlockHitType
    ld a, [hl]
    and a
    ret nz

    ld [hl], BLOCK_HIT_TYPE_SPECIAL
    inc l
    ld [hl], d
    inc l
    ld [hl], e
    ld a, STATE_BUFFER_COIN
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
    and NIBBLE_HIGH_MASK         ; Isoler monde (bits hauts)
    swap a
    dec a
    sla a
    ld e, a
    ld d, FLAG_FALSE
    ld hl, ROM_WORLD_TILE_TABLE
    add hl, de
    ld e, [hl]
    inc hl
    ld d, [hl]

SearchByteLoop:
    ld a, [de]
    cp TABLE_END_MARKER
    jr z, TableMarkerFound

    cp b
    jr z, ByteMatched

    inc de
    jr SearchByteLoop

TableMarkerFound:
    pop af
    pop hl
    ret


ByteMatched:
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
    cp GAME_STATE_DEMO      ; État >= $0E (démo) ?
    jr nc, NoCollisionFound

    ld de, COLLISION_SIDE_CONFIG_1  ; D=$07 (offset Y), E=$01 (1 itération)
    ldh a, [hTimerAux]
    cp TIMER_AUX_PIPE_MODE
    jr nz, CollisionConfig_Offset1

    ld a, [wPlayerDir]
    cp PLAYER_DIR_LEFT
    jr z, CollisionConfig_Offset1

    ld de, COLLISION_SIDE_CONFIG_2  ; D=$07 (offset Y), E=$02 (2 itérations)

CollisionConfig_Offset1:
    ld hl, wPlayerX
    ld a, [hl+]
    add d
    ldh [hSpriteY], a
    ld a, [wPlayerUnk05]
    ld b, [hl]
    ld c, COLLISION_SIDE_X_NEG
    and a
    jr nz, CollisionConfig_Offset2

    ld c, COLLISION_SIDE_X_POS

CollisionConfig_Offset2:
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
    jr z, NoCollisionRestartLoop

    cp TILEMAP_CMD_THRESHOLD    ; Tile >= $60 ?
    jr c, NoCollisionRestartLoop

    cp TILEMAP_CMD_PIPE         ; Tile tuyau $F4 ?
    jr z, HandlePlayerSpikeCollision

    cp TILEMAP_CMD_SLIDE        ; Tile glissade $77 ?
    jr z, HandlePlayerSlideCollision

    cp TILEMAP_CMD_BOUNCE       ; Tile rebond $F2 ?
    jr z, TriggerBlockCollisionSound_TimerCheck

CollisionDefaultHandler:
    ld hl, wPlayerUnk0B
    inc [hl]
    ld a, PLAYER_UNK07_FALLING
    ld [wPlayerUnk0E], a
    ld a, RETURN_COLLISION_FOUND
    ret


NoCollisionRestartLoop:
    ld d, COLLISION_LOOP_RESET
    dec e
    jr nz, CollisionConfig_Offset1

NoCollisionFound:
    xor a
    ret


HandlePlayerSpikeCollision:
    push hl
    pop de
    ld hl, hBlockHitType
    ld a, [hl]
    and a
    ret nz

    ld [hl], BLOCK_HIT_TYPE_SPECIAL
    inc l
    ld [hl], d
    inc l
    ld [hl], e
    ld a, STATE_BUFFER_COIN
    ld [wStateBuffer], a
    xor a
    ret


HandlePlayerSlideCollision:
    ldh a, [hVBlankMode]
    and a
    jr z, CollisionDefaultHandler

    ld a, GAME_STATE_PIPE_DOWN
    ldh [hGameState], a
    ld a, PLAYER_FLAG_PIPE_MODE
    ld [wPlayerFlag], a
    ld hl, wPlayerState
    ld a, [hl-]
    add PIPE_OFFSET_Y
    ldh [hVBlankSelector], a
    ld a, [hl]
    and TILE_ALIGN_MASK          ; Aligner sur tile (8 pixels)
    add TILE_ALIGN_OFFSET
    ld [hl], a
    call ClearOamAndSpriteBuffers
    ld a, RETURN_COLLISION_FOUND
    ret
; TriggerBlockCollisionSound_TimerDispatch
; ----------------------------------------
; Description: Gère collision bloc avec masquage direction joueur selon timer
;              Si timer actif (joueur en chute), masque direction avec $FF
;              Sinon réinitialise timer et masque avec $0F
;              Configure état d'attente, rendu et audio selon conditions
; In:  hTimerAux = état timer joueur
;      wPlayerDir = direction/mode actuel du joueur
;      wAudioCondition = condition audio active
; Out: hGameState = GAME_STATE_WAIT_PROCESS
;      wPlayerY = 0
;      wSpecialState = 0
;      rTMA = 0 (registre timer audio)
; Modifie: a, b

TriggerBlockCollisionSound:
TriggerBlockCollisionSound_TimerDispatch:
TriggerBlockCollisionSound_TimerCheck:
    ldh a, [hTimerAux]
    cp PLAYER_UNK07_FALLING
    ld b, SLOT_EMPTY
    jr z, TriggerBlockCollisionSound_TimerCheck_IsTwo

    ld b, OAM_CLEAR_LOOP_COUNT_F
    xor a
    ldh [hTimerAux], a

TriggerBlockCollisionSound_TimerCheck_IsTwo:
    ld a, [wPlayerDir]
    and b
    ld [wPlayerDir], a
    ld b, a
    and NIBBLE_LOW_MASK          ; Isoler mode direction
    cp PLAYER_MODE_GAMEPLAY
    jr nc, TriggerBlockCollisionSound_ApplyMask

    ld a, b
    and NIBBLE_HIGH_MASK         ; Garder bits hauts
    ld [wPlayerDir], a

TriggerBlockCollisionSound_ApplyMask:
    ld a, GAME_STATE_WAIT_PROCESS
    ldh [hGameState], a
    ld a, [wAudioCondition]
    and a
    jr nz, TriggerBlockCollisionSound_AudioCheck

    ld a, STATE_RENDER_ACTIVE
    ld [wStateRender], a
    ld a, TIMER_CREDITS_LONG
    ldh [hTimer1], a

TriggerBlockCollisionSound_AudioCheck:
    call ClearOamAndSpriteBuffers
    xor a
    ld [wPlayerY], a
    ld [wSpecialState], a
    ldh [rTMA], a
    ret
; ProcessBlockCollision
; ---------------------
; Description: Gère les collisions avec les blocs frappés par le joueur.
;              Traite différents types de blocs (cassables, pièces, items, spéciaux)
;              et collecte les pièces en attente. Met à jour la tilemap selon le type.
; In:  hBlockHitType = type de collision bloc ($01=soft, $02=coin, $04=item, $C0=special)
;      hPendingCoin = flag pièce en attente de collection
;      wOamVar2E = type de tile ($82=eau, $81=special)
;      hBlockHitType+1,+2 = pointeur vers la tile à modifier (DE)
; Out: Tilemap modifiée selon le type de bloc
;      wCoinUpdateDone = 0 (réinitialisé), puis possiblement modifié par CollectCoin
;      hBlockHitType = BLOCK_HIT_NONE ($00) après traitement
; Modifie: a, b, de, hl
ProcessBlockCollision:
    xor a
    ld [wCoinUpdateDone], a
    ldh a, [hPendingCoin]
    and a
    call nz, CollectCoin
    ld hl, hBlockHitType
    ld a, [hl]
    cp BLOCK_HIT_SOFT           ; Bloc cassable ?
    jr z, ProcessBlockCollision_HandleSoftBlock

    cp BLOCK_HIT_COIN           ; Bloc pièce ?
    jp z, BlockCollision_CoinProcess

    cp BLOCK_HIT_TYPE_SPECIAL   ; Type spécial $C0 ?
    jr z, ProcessBlockCollision_HandleSoftBlock

    cp BLOCK_HIT_ITEM           ; Bloc item ?
    ret nz

    ld [hl], $00
    inc l
    ld d, [hl]
    inc l
    ld e, [hl]
    ld a, [wOamVar2E]
    cp TILEMAP_CMD_WATER        ; Tile eau $82 ?
    jr z, ProcessBlockCollision_IsType82

    cp TILEMAP_CMD_LOAD3        ; Tile type $81 ?
    call z, CollectCoin
    ld a, TILE_WATER_REPLACED

ProcessBlockCollision_IsType82:
    ld [de], a
    ret


ProcessBlockCollision_HandleSoftBlock:
    ld b, [hl]
    ld [hl], $00

; ProcessBlockCollision_CommonExit
; ---------------------------------
; Description: Point d'entrée commun pour terminer le traitement de collision bloc.
;              Copie une tile vide dans la tilemap, vérifie si c'est un tuyau spécial
;              et gère la collecte de pièce dans ce cas. Utilisé par HandleSoftBlock
;              et CoinProcess pour partager la logique de fin.
; In:  b = type de bloc (BLOCK_HIT_TYPE_SPECIAL ou autre)
;      hl = pointeur vers hBlockHitType (état du bloc)
;      [hl+1,hl+2] = pointeur DE vers la position tilemap à effacer
; Out: Tilemap modifiée avec TILE_EMPTY
;      Si tile tuyau ($F4) détectée: hSpriteAttr/Tile, hPtrLow/High/Bank configurés
; Modifie: a, b, de, hl
ProcessBlockCollision_CommonExit:
    inc l
    ld d, [hl]
    inc l
    ld e, [hl]
    ld a, TILE_EMPTY
    ld [de], a
    ld a, b
    cp BLOCK_HIT_TYPE_SPECIAL
    jr z, ProcessBlockCollision_Special

    ld hl, hVramPtrLow
    add hl, de
    ld a, [hl]
    cp TILEMAP_CMD_PIPE         ; Tile tuyau $F4 ?
    ret nz

    ld [hl], TILE_EMPTY
    ld a, STATE_BUFFER_COIN
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
    add OBJECT_COLLISION_RANGE
    ldh [hPtrHigh], a
    ld a, BLOCK_HIT_TYPE_SPECIAL
    ldh [hPtrBank], a
    call CollectCoin
    ret

; BlockCollision_CoinProcess
; ---------------------------
; Description: Traite la collision avec un bloc pièce (type $03) - marque le bloc
;              comme vide et continue le traitement standard via CommonExit
; In:  hl = pointeur vers l'état du bloc
; Out: rien
; Modifie: a (via jr vers ProcessBlockCollision_CommonExit)
BlockCollision_CoinProcess:
    ld [hl], BLOCK_STATE_EMPTY
    jr ProcessBlockCollision_CommonExit

; ProcessBlockCollision_Special
; ------------------------------
; Description: Gère les blocs spéciaux (type BLOCK_HIT_TYPE_SPECIAL=$C0).
;              Collecte une pièce sans autre traitement additionnel.
; In:  rien (implicite: contexte de collision bloc spécial)
; Out: rien
; Modifie: a, bc, de, hl (via CollectCoin)
ProcessBlockCollision_Special:
    call CollectCoin
    ret


; CollectCoin
; -----------
; Description: Collecte une pièce - ajoute les points au score et incrémente le compteur
;              de pièces (format BCD). Gère l'overflow à 99 pièces (retour à 00).
; In:  rien (lit hCoinCount, écrit via AddScore et dans hCoinCount)
; Out: hCoinCount incrémenté (BCD), score += POINTS_PER_COIN
;      wUpdateCounter = 1 si overflow (passage de 99 à 00)
;      hPendingCoin = 0 (remis à zéro après collection)
;      wCoinUpdateDone = 1 (marque l'affichage comme mis à jour)
; Modifie: a, b, de, hl (via AddScore et UpdateCoinDisplay)
CollectCoin:
    ReturnIfLocked

    push de
    push hl
    ld de, POINTS_PER_COIN
    call AddScore
    pop hl
    pop de
    ldh a, [hCoinCount]
    add FLAG_TRUE              ; Incrément BCD +1
    daa                        ; Ajustement décimal (99 + 1 = 00 avec carry)
    ldh [hCoinCount], a
    and a                      ; Vérifier si = 0 (overflow de 99 à 00)
    jr nz, UpdateCoinDisplay

    inc a                      ; Si overflow: wUpdateCounter = 1
    ld [wUpdateCounter], a

; UpdateCoinDisplay
; -----------------
; Description: Met à jour l'affichage du compteur de pièces en VRAM
; In:  rien (lit hCoinCount)
; Out: rien
; Modifie: a, b
UpdateCoinDisplay:
    ldh a, [hCoinCount]
    ld b, a
    and NIBBLE_LOW_MASK          ; Chiffre unités
    ld [VRAM_COIN_UNITS], a
    ld a, b
    and NIBBLE_HIGH_MASK         ; Chiffre dizaines
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

    cp UPDATE_DECREMENT
    ld a, [wLivesCounter]
    jr z, DisplayLivesDecrement

    cp BCD_MAX_DIGIT
    jr z, ClearUpdateCounter

    push af
    ld a, GAME_STATE_CENTER
    ld [wStateBuffer], a
    ldh [hAudioCh2Param], a
    pop af
    add $01

; DisplayLivesDAA
; ---------------
; Description: Applique DAA pour ajuster le résultat BCD et sauvegarde dans wLivesCounter
; In:  a = valeur BCD brute après add/sub
; Out: wLivesCounter = valeur BCD corrigée
; Modifie: a
DisplayLivesDAA:
    daa
    ld [wLivesCounter], a

; DisplayLivesCount
; ----------------
; Description: Affiche le nombre de vies au format BCD dans le HUD
; In:  wLivesCounter = compteur de vies en BCD (ex: $25 = 25 vies)
; Out: VRAM mis à jour avec chiffres des dizaines et unités
; Modifie: a, b
DisplayLivesCount:
    ld a, [wLivesCounter]
    ld b, a
    and NIBBLE_LOW_MASK          ; Chiffre unités vies
    ld [VRAM_SCORE_POS2], a
    ld a, b
    and NIBBLE_HIGH_MASK         ; Chiffre dizaines vies
    swap a
    ld [VRAM_SCORE_POS1], a

; ClearUpdateCounter
; ------------------
; Description: Réinitialise le compteur de mise à jour à zéro
; In:  Aucun
; Out: wUpdateCounter = 0
; Modifie: a
ClearUpdateCounter:
    xor a
    ld [wUpdateCounter], a
    ret


; DisplayLivesGameOver
; --------------------
; Description: Déclenche le Game Over (état $39) et réinitialise le compteur
; In:  Aucun
; Out: hGameState = GAME_STATE_GAME_OVER, wUpdateCounter = 0
; Modifie: a
DisplayLivesGameOver:
    ld a, GAME_STATE_GAME_OVER
    ldh [hGameState], a
    ld [wROMBankInit], a
    jr ClearUpdateCounter

; DisplayLivesDecrement
; ---------------------
; Description: Décrémente le compteur de vies de 1 (en BCD), Game Over si 0
; In:  a = nombre de vies actuel (BCD)
; Out: wLivesCounter mis à jour, ou Game Over déclenché si vies=0
; Modifie: a
DisplayLivesDecrement:
    and a
    jr z, DisplayLivesGameOver

    sub $01
    jr DisplayLivesDAA

; ===========================================================================
; État $39 - Game Over ($1C73)
; Affiche l'écran GAME OVER, sauvegarde score, clear OAM, configure window
; ===========================================================================
State39_GameOver::
    ld hl, _SCRN1
    ld de, ROM_TEXT_GAME_OVER
    ld b, TEXT_GAME_OVER_SIZE

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

    ld a, STATE_RENDER_GAME_OVER
    ld [wStateRender], a
    ldh a, [hAnimTileIndex]
    ld [wAnimTileIdx], a
    ld a, [wScoreBCD]
    and NIBBLE_HIGH_MASK         ; Nibble haut du score BCD
    swap a
    ld b, a
    ld a, [wGameConfigA6]
    add b
    cp CONFIG_VALUE_MAX
    jr c, State39_StoreConfigValue

    ld a, CONFIG_VALUE_CLAMP

State39_StoreConfigValue:
    ld [wGameConfigA6], a
    ld hl, wOamBuffer
    xor a
    ld b, OAM_BUFFER_FULL

State39_ClearOAMBuffer:
    ld [hl+], a
    dec b
    jr nz, State39_ClearOAMBuffer

    ld [wSpecialState], a
    ldh [rTMA], a
    ld hl, rWY              ; Window Y position
    ld [hl], WY_GAME_OVER
    inc hl
    ld [hl], WX_GAME_OVER
    ld a, SLOT_EMPTY
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
    ld hl, _SCRN1
    ld de, ROM_TEXT_WINDOW_DATA
    ld c, TEXT_WINDOW_DATA_SIZE

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

    ld hl, rLCDC
    set 5, [hl]
    ld a, TIMER_WINDOW_SETUP
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

    ld a, GAME_STATE_RESET
    ldh [hGameState], a
    ret


ProcessAnimationState:
    ld hl, wPlayerUnk0D
    ld a, [hl]
    cp FLAG_TRUE
    jr nz, ProcessAnimationState_CheckType

    dec l
    ld a, [hl]
    and a
    jr nz, ProcessAnimationState_DecrementFlag

    inc l
    ld [hl], $00
    jr ResetPlayerDirection

ProcessAnimationState_DecrementFlag:
    dec [hl]
    ret


ProcessAnimationState_CheckType:
    ld hl, wPlayerUnk0C
    ld a, [hl+]
    cp PLAYER_ACCEL_COUNTER_MAX  ; Compteur accélération max (6)
    jr nz, ProcessAnimationState_AfterTypeCheck

    inc l
    ld a, [hl]
    and a
    jr nz, ProcessAnimationState_AfterTypeCheck

    ld [hl], PLAYER_UNK07_FALLING ; État chute ($02)

ProcessAnimationState_AfterTypeCheck:
    ld de, wPlayerUnk07
    ldh a, [hJoypadState]
    bit 7, a
    jr nz, ProcessAnimationState_JoypadUp

ProcessAnimationState_JoypadTests:
    bit 4, a
    jr nz, ProcessAnimationState_JoypadLeft

    bit 5, a
    jp nz, HandleJoypadRight

    ld hl, wPlayerUnk0C
    ld a, [hl]
    and a
    jr z, ProcessAnimationState_ResetAnimation

    xor a
    ld [wPlayerUnk0E], a
    dec [hl]
    inc l
    ld a, [hl]
    jr ProcessAnimationState_JoypadTests

ProcessAnimationState_ResetAnimation:
    inc l
    ld [hl], $00
    ld a, [de]
    and a
    ret nz

ResetPlayerDirection:
    ld a, [wPlayerUnk07]
    and a
    ret nz

    ld hl, wPlayerDir
    ld a, [hl]
    and NIBBLE_HIGH_MASK
    ld [hl], a
    ld a, FLAG_TRUE
    ld [wPlayerUnk0B], a
    xor a
    ld [wPlayerUnk0E], a
    ret


ProcessAnimationState_JoypadUp:
    push af
    ldh a, [hTimerAux]
    cp TIMER_AUX_PIPE_MODE      ; $02 = mode pipe/transition
    jr nz, ProcessAnimationState_JoypadUp_ContinueTests

    ld a, [de]
    and a
    jr nz, ProcessAnimationState_JoypadUp_ContinueTests

    ld a, PLAYER_DIR_LEFT
    ld [wPlayerDir], a
    ldh a, [hJoypadState]
    and JOYPAD_LR_MASK          ; Test gauche/droite pressé
    jr nz, ProcessAnimationState_JoypadUp_ResetAndReturn

    ld a, [wPlayerUnk0C]
    and a
    jr z, ProcessAnimationState_JoypadUp_ResetAndReturn

ProcessAnimationState_JoypadUp_ContinueTests:
    pop af
    jr ProcessAnimationState_JoypadTests

ProcessAnimationState_JoypadUp_ResetAndReturn:
    xor a
    ld [wPlayerUnk0C], a
    pop af
    ret


ProcessAnimationState_JoypadLeft:
    ld hl, wPlayerUnk0D
    ld a, [hl]
    cp PLAYER_DIR_CHECK_LEFT     ; Vérifie direction gauche confirmée ($20)
    jr nz, ProcessAnimationState_JoypadLeft_CheckCollision

    jp HandleJoypadRight_Setup


ProcessAnimationState_JoypadLeft_CheckCollision:
    ld hl, wPlayerUnk05
    ld [hl], FLAG_FALSE
    call CheckPlayerSideCollision
    and a
    ret nz

    ldh a, [hJoypadState]
    bit 4, a
    jr z, ProcessAnimationState_JoypadLeft_Done

    ld a, [wPlayerDir]
    cp PLAYER_DIR_LEFT
    jr nz, ProcessAnimationState_JoypadLeft_Increment

    ld a, [wPlayerDir]
    and NIBBLE_HIGH_MASK         ; Garder bits hauts direction
    or $01
    ld [wPlayerDir], a

ProcessAnimationState_JoypadLeft_Increment:
    ld hl, wPlayerUnk0C
    ld a, [hl]
    cp PLAYER_ACCEL_COUNTER_MAX  ; Compteur accélération max (6)
    jr z, ProcessAnimationState_JoypadLeft_Done

    inc [hl]
    inc l
    ld [hl], PLAYER_ACCEL_TIMER_LEFT  ; Timer mouvement gauche (16)

ProcessAnimationState_JoypadLeft_Done:
    ld hl, wPlayerState
    ldh a, [hVBlankMode]
    and a
    jr nz, CheckOscillationCollision_Skip

    ld a, [wCollisionFlag]
    cp COLLISION_THRESHOLD_7    ; Seuil collision 7
    jr c, CheckOscillationCollision_CheckScroll

    ldh a, [hShadowSCX]
    and BITS_2_3_MASK           ; Masque bits 2-3 (alignement 4 pixels)
    jr z, CheckOscillationCollision_Skip

CheckOscillationCollision_CheckScroll:
    ld a, SCROLL_THRESHOLD_OSCIL
    cp [hl]
    jr nc, CheckOscillationCollision_Skip

    call GetOscillatingOffset
    ld b, a
    ld hl, hShadowSCX
    add [hl]
    ld [hl], a
    call OffsetSpritesY
    call OffsetSpritesX
    ld hl, wOamAttrY
    ld de, OAM_ENTRY_SIZE
    ld c, OAM_SPRITE_LOOP_3

CheckOscillationCollision_LoopSprites:
    ld a, [hl]
    sub b
    ld [hl], a
    add hl, de
    dec c
    jr nz, CheckOscillationCollision_LoopSprites

CheckOscillationCollision_Done:
    ld hl, wPlayerUnk0B
    inc [hl]
    ret


CheckOscillationCollision_Skip:
    call GetOscillatingOffset
    add [hl]
    ld [hl], a
    ldh a, [hGameState]
    cp GAME_STATE_GAMEPLAY
    jr z, CheckOscillationCollision_Done

    ld a, [wCollisionFlag]
    and a
    jr z, CheckOscillationCollision_Done

    ldh a, [hShadowSCX]
    and SCROLL_ALIGN_MASK        ; Aligner scroll sur 4 pixels
    ldh [hShadowSCX], a
    ld a, [hl]
    cp PLAYER_X_RIGHT            ; Position >= 160px (zone droite)
    jr c, CheckOscillationCollision_Done

    jp TriggerBlockCollisionSound_TimerCheck


HandleJoypadRight:
    ld hl, wPlayerUnk0D
    ld a, [hl]
    cp PLAYER_ACCEL_TIMER_LEFT   ; Vérifie timer mouvement ($10)
    jr nz, HandlePlayerMovement

HandleJoypadRight_Setup:
    ld [hl], FLAG_TRUE
    dec l
    ld [hl], TILE_SIZE_PIXELS
    ld a, [wPlayerUnk07]
    and a
    ret nz

    ld hl, wPlayerDir
    ld a, [hl]
    and NIBBLE_HIGH_MASK
    or $05
    ld [hl], a
    ld a, FLAG_TRUE
    ld [wPlayerUnk0B], a
    ret


HandlePlayerMovement:
    ld hl, wPlayerUnk05
    ld [hl], PLAYER_ACCEL_TIMER_RIGHT  ; Timer mouvement droite ($20)
    call CheckPlayerSideCollision
    and a
    ret nz

    ld hl, wPlayerState
    ld a, [hl]
    cp PLAYER_STATE_OSCIL_THRESH  ; Seuil oscillation ($0F)
    jr c, DecrementOscillationYCounter

    push hl
    ldh a, [hJoypadState]
    bit 5, a
    jr z, ApplyOscillationNegOffset

    ld a, [wPlayerDir]
    cp PLAYER_DIR_LEFT
    jr nz, CheckOscillationCounter

    ld a, [wPlayerDir]
    and NIBBLE_HIGH_MASK         ; Garder bits hauts direction
    or $01
    ld [wPlayerDir], a

CheckOscillationCounter:
    ld hl, wPlayerUnk0C
    ld a, [hl]
    cp PLAYER_ACCEL_COUNTER_MAX  ; Compteur accélération max (6)
    jr z, ApplyOscillationNegOffset

    inc [hl]
    inc l
    ld [hl], PLAYER_ACCEL_TIMER_RIGHT  ; Timer mouvement droite ($20)

ApplyOscillationNegOffset:
    pop hl
    call GetOscillatingOffset
    cpl
    inc a
    add [hl]
    ld [hl], a

DecrementOscillationYCounter:
    ld hl, wPlayerUnk0B
    dec [hl]
    ret


OffsetSpritesY:
    ld hl, wSpriteVar31
    ld de, OAM_ENTRY_SIZE
    ld c, OAM_SPRITE_LOOP_8

OffsetSpritesY_Loop:
    ld a, [hl]
    sub b
    ld [hl], a
    add hl, de
    dec c
    jr nz, OffsetSpritesY_Loop

    ret


GetOscillatingOffset:
    push de
    push hl
    ld hl, OscillationTable
    ld a, [wPlayerUnk0E]
    ld e, a
    ld d, $00
    ld a, [wPlayerUnk0F]
    xor FLAG_TRUE
    ld [wPlayerUnk0F], a
    add e
    ld e, a
    add hl, de
    ld a, [hl]
    pop hl
    pop de
    ret


; =============================================================================
; OscillationTable - Table de valeurs pour l'effet d'oscillation
; =============================================================================
; Utilisée par GetOscillatingOffset pour créer un mouvement sinusoïdal
; 6 octets : [0, 1, 1, 1, 1, 2]
OscillationTable:
    db $00, $01, $01, $01, $01, $02

; =============================================================================
; ClearOamAndSpriteBuffers - Réinitialise les buffers OAM et sprites
; =============================================================================
; QUOI : Efface les buffers OAM et initialise les propriétés des sprites
; ENTRÉE : Aucune
; SORTIE : Buffers OAM effacés, propriétés sprites initialisées
; MODIFIE : A, B, DE, HL
; =============================================================================
ClearOamAndSpriteBuffers:
    push hl
    push bc
    push de
    ld hl, wOamVar1C
    ld b, OAM_VAR_BUFFER_SIZE
    xor a

ClearOamVar_Loop:
    ld [hl+], a
    dec b
    jr nz, ClearOamVar_Loop

    ld hl, wOamBuffer
    ld b, OAM_CLEAR_LOOP_COUNT

ClearOamBuffer2_Loop:
    ld [hl+], a
    dec b
    jr nz, ClearOamBuffer2_Loop

    ldh [hObjParamBuf1], a
    ldh [hObjParamBuf2], a
    ldh [hObjParamBuf3], a
    ld hl, wPlayerUnk10
    ld de, OBJECT_STRUCT_SIZE
    ld b, INIT_OBJECTS_LOOP_COUNT
    ld a, OAM_SPRITE_HIDDEN

InitSpriteProperties_Loop:
    ld [hl], a
    add hl, de
    dec b
    jr nz, InitSpriteProperties_Loop

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
    and FRAME_MASK_4
    ret nz

    ld a, [wPlayerInvuln]
    and a
    ret z

    cp FLAG_TRUE                ; Dernière frame d'invulnérabilité ?
    jr z, .end_invuln

    dec a
    ld [wPlayerInvuln], a
    ld a, [wPlayerY]
    xor BIT_7_MASK              ; Toggle bit 7 pour effet clignotement
    ld [wPlayerY], a
    ld a, [wStateVar9]
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

AnimLoopStart:
    ld a, [hl+]
    and a
    jr nz, ProcessAnimEntry

NextAnimEntry:
    inc e
    inc e
    inc e
    inc e
    dec b
    jr nz, AnimLoopStart

    ret


ProcessAnimEntry:
    push hl
    push de
    push bc
    dec l
    ld a, [wGameVarA9]
    and a
    jr z, ClearSpriteState

    dec a
    ld [wGameVarA9], a
    bit 0, [hl]
    jr z, DecrementYIfConfigBit0Clear

    ld a, [de]
    inc a
    inc a
    ld [de], a
    cp SPRITE_Y_LIMIT_MAX        ; Limite Y max sprite montant
    jr c, IncrementYAndCheckCoin

ClearSpriteState:
    xor a
    res 0, e
    ld [de], a
    ld [hl], a
    jr SpriteCollisionProcessing

IncrementYAndCheckCoin:
    add SPRITE_Y_ADJUST_3        ; Ajustement Y +3 pixels
    push af
    dec e
    ld a, [de]
    ldh [hSpriteY], a
    pop af
    call CheckTileForCoin
    jr c, CheckBit2AndProcessY

    ld a, [hl]
    and SCROLL_ALIGN_MASK        ; Aligner sur 4 pixels
    or $02
    ld [hl], a

CheckBit2AndProcessY:
    bit 2, [hl]
    jr z, IncrementYIfBit2Clear

    ld a, [de]
    dec a
    dec a
    ld [de], a
    cp SPRITE_Y_LIMIT_MIN        ; Limite Y min sprite (haut écran)
    jr c, ClearSpriteState

    sub $01
    ldh [hSpriteY], a

CheckCoinCollision:
    inc e
    ld a, [de]
    call CheckTileForCoin
    jr c, SpriteCollisionProcessing

    ld a, [hl]
    and BITS_2_3_CLEAR_MASK     ; Efface bits 2-3
    or BIT_3_MASK               ; Set bit 3
    ld [hl], a

SpriteCollisionProcessing:
    pop bc
    pop de
    pop hl
    call ProcessObjectCollisions
    jr NextAnimEntry

IncrementYIfBit2Clear:
    ld a, [de]
    inc a
    inc a
    ld [de], a
    cp SPRITE_Y_LIMIT_UPPER      ; Limite Y haute sprite descendant
    jr nc, ClearSpriteState

    add SPRITE_Y_ADJUST_4        ; Ajustement Y +4 pixels
    ldh [hSpriteY], a
    inc e
    ld a, [de]
    call CheckTileForCoin
    jr c, SpriteCollisionProcessing

    ld a, [hl]
    and BITS_2_3_CLEAR_MASK     ; Efface bits 2-3
    or BIT_2_MASK               ; Set bit 2
    ld [hl], a
    jr SpriteCollisionProcessing

DecrementYIfConfigBit0Clear:
    ld a, [de]
    dec a
    dec a
    ld [de], a
    cp SPRITE_Y_LIMIT_LOW        ; Limite Y basse sprite
    jr c, ClearSpriteState

    sub $02
    push af
    dec e
    ld a, [de]
    ldh [hSpriteY], a
    pop af
    call CheckTileForCoin
    jr c, CheckBit2AndProcessY

    ld a, [hl]
    and SCROLL_ALIGN_MASK        ; Aligner sur 4 pixels
    or $01
    ld [hl], a
    jr CheckBit2AndProcessY

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
    cp TILEMAP_CMD_PIPE         ; Tile tuyau $F4 ?
    jr nz, NotCoinTile

    ldh a, [hGameState]
    cp GAME_STATE_GAMEPLAY
    jr z, ReturnAfterCoinCheck

    push hl
    pop de
    ld hl, hBlockHitType
    ld a, [hl]
    and a
    jr nz, ReturnAfterCoinCheck

    ld [hl], BLOCK_HIT_TYPE_SPECIAL
    inc l
    ld [hl], d
    inc l
    ld [hl], e
    ld a, STATE_BUFFER_COIN
    ld [wStateBuffer], a

NotCoinTile:
    cp TILEMAP_CMD_WATER        ; Tile eau $82 ?
    call z, HandleBlockCollision
    cp TILEMAP_CMD_LOAD1        ; Tile type $80 ?
    call z, HandleBlockCollision

ReturnAfterCoinCheck:
    pop hl
    pop de
    cp TILEMAP_CMD_THRESHOLD    ; Tile >= $60 ?
    ret


ProcessObjectCollisions:
    push hl
    push de
    push bc
    ld b, OBJECT_BUFFER_COUNT     ; 10 slots
    ld hl, wObjectBuffer

IterateAnimObjects_Loop:
    ld a, [hl]
    cp SLOT_EMPTY
    jr nz, ProcessAnimObject

NextObjectSlot:
    push de
    ld de, OBJECT_SLOT_SIZE       ; 16 bytes par slot
    add hl, de
    pop de
    dec b
    jr nz, IterateAnimObjects_Loop

    pop bc
    pop de
    pop hl
    ret


IterateAnimObjects_NextSlot:
    pop hl
    pop de
    pop bc
    jr NextObjectSlot

ProcessAnimObject:
    push bc
    push de
    push hl
    ld bc, OBJ_FIELD_STATE_OFFSET
    add hl, bc
    bit 7, [hl]
    jr nz, IterateAnimObjects_NextSlot

    ld c, [hl]
    inc l
    inc l
    ld a, [hl]
    ldh [hAnimObjSubState], a
    ld a, [de]
    ldh [hTemp2], a
    add COLLISION_OFFSET_4
    ldh [hParam3], a
    dec e
    ld a, [de]
    ldh [hTemp0], a
    ld a, [de]
    add COLLISION_OFFSET_3
    ldh [hTemp1], a
    pop hl
    push hl
    call CheckBoundingBoxCollision
    and a
    jr z, IterateAnimObjects_NextSlot

    dec l
    dec l
    dec l
    call SelectAnimationBank
    push de
    ldh a, [hGameState]

CheckAnimObjectState:
    cp GAME_STATE_GAMEPLAY
    jr nz, .not_gameplay

    call HandleGameplayObjectSound
    jr .end_check

.not_gameplay:
    call DecrementObjectAnimationCounter

.end_check:
    pop de
    and a
    jr z, IterateAnimObjects_NextSlot

    push af
    ld a, [de]
    sub TILE_SIZE_PIXELS
    ldh [hPtrHigh], a
    inc e
    ld a, [de]
    ldh [hPtrLow], a
    pop af
    cp SLOT_EMPTY
    jr nz, ClearAnimObjectSlot

    ld a, STATE_BUFFER_ANIM
    ld [wStateBuffer], a
    ldh a, [hAnimStructBank]
    ldh [hPtrBank], a

ClearAnimObjectSlot:
    xor a
    ld [de], a
    dec e
    ld [de], a
    ld hl, hObjParamBuf3
    bit 3, e
    jr nz, StoreAnimObjectData

    dec l
    bit 2, e
    jr nz, StoreAnimObjectData

    dec l

StoreAnimObjectData:
    ld [hl], a
    jr IterateAnimObjects_NextSlot

HandleBlockCollision:
    push hl
    push bc
    push de
    push af
    ldh a, [hGameState]
    cp GAME_STATE_GAMEPLAY
    jr nz, ProcessAnimObjectExit

    push hl
    pop de
    ld hl, hBlockHitType
    ld a, [hl]
    and a
    jr nz, ProcessAnimObjectExit

    ld [hl], $01
    inc l
    ld [hl], d
    inc l
    ld [hl], e
    pop af
    push af
    cp TILEMAP_CMD_LOAD1        ; Tile type $80 ?
    jr nz, InitBlockHitSprites

    ld a, d
    add BCD_TO_ASCII
    ld d, a
    ld a, [de]
    and a
    jr z, InitBlockHitSprites

    call PlaySound

InitBlockHitSprites:
    ld hl, wPlayerUnk10
    ld de, OBJECT_STRUCT_SIZE
    ld b, INIT_OBJECTS_LOOP_COUNT

SpriteSetupLoop:
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
    ld [hl], FLAG_TRUE          ; Flag sprite actif
    inc l
    ld [hl], STATE_BUFFER_DEFAULT ; État par défaut ($07)
    pop hl
    add hl, de
    dec b
    jr nz, SpriteSetupLoop

    ld hl, wObject2State
    ld a, [hl]
    sub MOVEMENT_OFFSET_4
    ld [hl], a
    ld hl, wObject4Unk0A
    ld a, [hl]
    sub MOVEMENT_OFFSET_4
    ld [hl], a
    ld hl, wObject4
    ld [hl], OBJECT_STATE_INACTIVE
    ld hl, wObject5
    ld [hl], OBJECT_STATE_INACTIVE
    ldh a, [hShadowSCX]
    ldh [hRenderAttr], a
    ld de, SCORE_BONUS_50
    call AddScore
    ld a, STATE_FINAL_COMPLETE
    ld [wStateFinal], a

ProcessAnimObjectExit:
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
    jr nz, PaddingZone_00

PaddingZone_00:
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
    jr nz, PaddingZone_01

PaddingZone_01:
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

ResetScrollPhase:
    ld a, SCROLL_PHASE_RESET
    ldh [hScrollPhase], a
    ldh a, [hShadowSCX]
    ld b, a
    ld a, [wGameVarAA]
    cp b
    ret z

    xor a                       ; SCROLL_PHASE_INACTIVE
    ldh [hScrollPhase], a
    ret


UpdateScroll:
    ldh a, [hScrollPhase]
    and a
    jr nz, ResetScrollPhase

    ldh a, [hShadowSCX]
    and BIT_3_MASK              ; Test bit 3 (intervalle de 8 pixels)
    ld hl, hTemp3
    cp [hl]
    ret nz

    ld a, [hl]
    xor BIT_3_MASK              ; Toggle bit 3
    ld [hl], a
    and a
    jr nz, InitScrollBuffer

    ld hl, wPlayerVarAB
    inc [hl]

InitScrollBuffer:
    ld b, SCROLL_BUFFER_SIZE
    ld hl, wScrollBuffer
    ld a, TILE_EMPTY

.fill:
    ld [hl+], a
    dec b
    jr nz, .fill

    ldh a, [hTilemapScrollY]
    and a
    jr z, InitFromRenderContext

    ldh a, [hTilemapOffsetX]
    ld h, a
    ldh a, [hTilemapOffsetY]
    ld l, a
    jr ProcessScrollEntry

InitFromRenderContext:
    ld hl, _ROMX                    ; Base des données niveau (bank switchable)
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
    cp SLOT_EMPTY
    jr z, UpdateCollisionFlag

    ld e, a
    ld d, [hl]
    push de
    pop hl


ProcessScrollEntry:
    ld a, [hl+]
    cp TILEMAP_CMD_END              ; Fin de section tilemap ?
    jr z, StoreTilemapScrollOffsets

    ld de, wScrollBuffer
    ld b, a
    and NIBBLE_HIGH_MASK         ; Offset buffer (nibble haut)
    swap a
    add e
    ld e, a
    ld a, b
    and NIBBLE_LOW_MASK          ; Nombre tiles (nibble bas)
    jr nz, TilemapDataNibbleNonZero

    ld a, TILEMAP_DEFAULT_COUNT

TilemapDataNibbleNonZero:
    ld b, a

TilemapDataCopyStart:
    ld a, [hl+]
    cp TILEMAP_CMD_SKIP
    jr z, TilemapDataCopyLoop

    ld [de], a
    cp TILEMAP_CMD_SCROLL
    jr nz, TilemapDataNotScrollUpdate

    call UpdateTilemapScrolling
    jr ProcessColumnAnimation_End

TilemapDataNotScrollUpdate:
    cp TILEMAP_CMD_LOAD1

ProcessColumnAnimation:
    jr nz, .not_load1

    call LoadLevelTilemap
    jr ProcessColumnAnimation_End

.not_load1:
    cp TILEMAP_CMD_LOAD2
    jr nz, .not_load2

    call LoadLevelTilemap
    jr ProcessColumnAnimation_End

.not_load2:
    cp TILEMAP_CMD_LOAD3
    call z, LoadLevelTilemap

ProcessColumnAnimation_End:
    inc e
    dec b
    jr nz, TilemapDataCopyStart

    jr ProcessScrollEntry

UpdateCollisionFlag:
    ld hl, wCollisionFlag
    inc [hl]
    ret


StoreTilemapScrollOffsets:
    ld a, h
    ldh [hTilemapOffsetX], a
    ld a, l
    ldh [hTilemapOffsetY], a
    ldh a, [hTilemapScrollY]
    inc a
    cp TILEMAP_ROW_WIDTH       ; 20 lignes par tilemap
    jr nz, UpdateTilemapScrollConfig

    ld hl, hTilemapScrollX
    inc [hl]
    xor a

UpdateTilemapScrollConfig:
    ldh [hTilemapScrollY], a
    ldh a, [hShadowSCX]
    ld [wGameVarAA], a
    ld a, SCROLL_PHASE_ACTIVE
    ldh [hScrollPhase], a
    ret


TilemapDataCopyLoop:
    ld a, [hl]

CopyTileDataLoop:
    ld [de], a
    inc e
    dec b
    jr nz, CopyTileDataLoop

    inc hl
    jp ProcessScrollEntry


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
    cp SCROLL_PHASE_ACTIVE
    ret nz

    ldh a, [hScrollColumn]
    ld l, a
    inc a
    cp SCROLL_COLUMN_MAX
    jr nz, ScrollColumnWrapAround

    ld a, SCROLL_COLUMN_DEFAULT

ScrollColumnWrapAround:
    ldh [hScrollColumn], a
    ld h, VRAM_TILEMAP_HIGH
    ld de, wScrollBuffer
    ld b, SCROLL_BUFFER_SIZE

ClearTilemapColumn:
    push hl
    ld a, h
    add BCD_TO_ASCII
    ld h, a
    ld [hl], $00
    pop hl
    ld a, [de]
    ld [hl], a
    cp TILEMAP_CMD_SCROLL        ; Tile scroll $70 ?
    jr nz, CheckIfNotLevelConfigTile

    call ProcessRenderQueue
    jr TilemapScrollLoop

CheckIfNotLevelConfigTile:
    cp TILEMAP_CMD_LOAD1        ; Tile type $80 ?
    jr nz, CheckIfNotCompressedTile

    call ApplyLevelConfig
    jr TilemapScrollLoop

CheckIfNotCompressedTile:
    cp TILEMAP_CMD_LOAD2        ; Tile type $5F ?
    jr nz, HandleSpecialMarkerTile

    call ApplyLevelConfig
    jr TilemapScrollLoop

HandleSpecialMarkerTile:
    cp TILEMAP_CMD_LOAD3        ; Tile type $81 ?
    call z, ApplyLevelConfig

TilemapScrollLoop:
    inc e
    push de
    ld de, TILEMAP_STRIDE
    add hl, de
    pop de
    dec b
    jr nz, ClearTilemapColumn

    ld a, SCROLL_PHASE_DONE
    ldh [hScrollPhase], a
    ret


UpdateTilemapScrolling:
    push hl
    push de
    push bc
    ldh a, [hVBlankMode]
    and a
    jr nz, SearchTilemapExit

    ldh a, [hCurrentBank]
    ldh [hSavedBank], a
    ld a, BANK_AUDIO
    ldh [hCurrentBank], a
    ld [rROMB0], a
    ldh a, [hRenderContext]
    add a
    ld e, a
    ld d, $00
    ld hl, ROM_TILEMAP_POINTERS_A  ; Table pointeurs tilemap A (bank 3)
    add hl, de
    ld e, [hl]
    inc hl
    ld d, [hl]
    push de
    pop hl

SearchTilemapEntry_CheckX:
    ldh a, [hTilemapScrollX]
    cp [hl]
    jr z, SearchTilemapEntry_CheckY

    ld a, [hl]
    cp SLOT_EMPTY
    jr z, SearchTilemapEntry_Exit

    inc hl

SearchTilemapEntry_NextEntry:
    inc hl
    inc hl
    inc hl
    inc hl
    inc hl
    jr SearchTilemapEntry_CheckX

SearchTilemapEntry_CheckY:
    ldh a, [hTilemapScrollY]
    inc hl
    cp [hl]
    jr nz, SearchTilemapEntry_NextEntry

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

SearchTilemapEntry_Exit:
    ldh a, [hSavedBank]
    ldh [hCurrentBank], a
    ld [rROMB0], a

SearchTilemapExit:
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
    add BCD_TO_ASCII
    ld h, a
    pop af
    ld [hl], a
    ldh a, [hRenderMode]
    add hl, de
    ld [hl], a
    ldh a, [hDestY]
    add hl, de
    ld [hl], a
    ldh a, [hDestX]
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
    ld a, BANK_AUDIO
    ldh [hCurrentBank], a
    ld [rROMB0], a
    ldh a, [hRenderContext]
    add a
    ld e, a
    ld d, $00
    ld hl, ROM_TILEMAP_POINTERS_B  ; Table pointeurs tilemap B (bank 3)
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
    cp SLOT_EMPTY
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
    ld [rROMB0], a
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
    add BCD_TO_ASCII
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
    ld a, BANK_AUDIO
    ldh [hCurrentBank], a
    ld [rROMB0], a
    call ProcessGameStateInput   ; Bank 3: traiter entrées
    ld bc, wObject2              ; Slot objet 2
    ld hl, ROM_OBJECT_INIT_DATA
    call ProcessObjectData
    ld bc, wObject3              ; Slot objet 3
    ld hl, ROM_OBJECT_INIT_DATA
    call ProcessObjectData
    ld bc, wObject4              ; Slot objet 4
    ld hl, ROM_OBJECT_INIT_DATA
    call ProcessObjectData
    ld bc, wObject5              ; Slot objet 5
    ld hl, ROM_OBJECT_INIT_DATA
    call ProcessObjectData
    call InitRenderLoop          ; Bank 3: init boucle rendu
    call CheckTimerAux1
    call CheckTimerAux2
    ldh a, [hSavedBank]
    ldh [hCurrentBank], a
    ld [rROMB0], a

    ; Update collision/physics
    call UpdateAudio

    ; Bank 2 : mise à jour spéciale
    ldh a, [hCurrentBank]
    ldh [hSavedBank], a
    ld a, BANK_2
    ldh [hCurrentBank], a
    ld [rROMB0], a
    call UpdateGameTimersAndAnimation                   ; Bank 2: special update
    ldh a, [hSavedBank]
    ldh [hCurrentBank], a
    ld [rROMB0], a

    ; Finalize
    call SwitchBankAndCallBank3Handler
    call $515e                   ; Bank 1: final update
    call UpdatePlayerInvulnBlink  ; Clignotement invulnérabilité

    ; Toggle direction joueur toutes les 4 frames (animation idle)
    ldh a, [hFrameCounter]
    and FRAME_MASK_4
    ret nz

    ld a, [wPlayerDir]
    xor BIT_0_MASK              ; Toggle direction (0↔1)
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
    cp GAME_STATE_GAMEPLAY
    ret nc

    ldh a, [hFrameCounter]
    and FRAME_MASK_8             ; Exécute toutes les 8 frames
    ret nz

    ldh a, [hFrameCounter]
    bit 3, a
    jr z, AnimTile_FromROM

    ld hl, wAnimBuffer
    jr AnimTile_Setup

AnimTile_FromROM:
    ld hl, ROM_ANIM_TILES
    ldh a, [hAnimTileIndex]
    and NIBBLE_HIGH_MASK         ; Isoler monde (bits hauts)
    sub AUDIO_PARAM_BASE_Y       ; Offset monde ($10 = monde 1)
    rrca
    ld d, $00
    ld e, a
    add hl, de

AnimTile_Setup:
    ld de, VRAM_ANIM_DEST
    ld b, ANIM_BUFFER_COPY_SIZE

CopyAnimTileData:
    ld a, [hl+]
    ld [de], a
    inc de
    inc de
    dec b
    jr nz, CopyAnimTileData

    ret


; =============================================================================
; AnimFlagTable - Flags d'animation par contexte de rendu
; =============================================================================
; 12 octets : Un flag par contexte de rendu (0-11)
; Utilisé par InitAudioAndAnimContext pour activer/désactiver les animations
AnimFlagTable:
    db $00, $00, $01, $01, $01, $00, $00, $01, $01, $00, $01, $00

; =============================================================================
; InitAudioAndAnimContext - Initialise le contexte audio et animation
; =============================================================================
; QUOI : Configure wPlayerVarAB, cherche l'entrée audio, et définit wAnimFlag
; ENTRÉE : hRenderContext = contexte de rendu courant
; SORTIE : wPlayerVarAB = $0c, wAudioCondition = 0, wAnimFlag = flag selon contexte
; MODIFIE : A, DE, HL
; =============================================================================
InitAudioAndAnimContext:
    ld a, PLAYER_VAR_AB_INIT
    ld [wPlayerVarAB], a
    call FindAudioTableEntry
    xor a
    ld [wAudioCondition], a
    ld hl, AnimFlagTable
    ldh a, [hRenderContext]
    ld d, $00
    ld e, a
    add hl, de
    ld a, [hl]
    ld [wAnimFlag], a
    ret


FindAudioTableEntry:
    ld hl, ROM_AUDIO_INDEX_TABLE
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
    ld de, OBJECT_STRUCT_SIZE

ClearObjectBuffer_Loop:
    ld [hl], $ff
    add hl, de
    ld a, l
    cp OBJECT_BUFFER_END_LOW     ; Fin buffer objets ($D1A0)
    jp nz, ClearObjectBuffer_Loop

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
    and AUDIO_POSITION_MASK
    rlca
    rlca
    rlca
    add AUDIO_PARAM_BASE_Y
    ldh [hSoundParam1], a
    ld a, [hl+]
    and BITS_6_7_MASK
    swap a
    add AUDIO_PARAM_BASE_X
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
    cp SLOT_EMPTY
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
    jr nz, InitAudioFromSound

    bit 7, [hl]
    ret nz

InitAudioFromSound:
    ld a, [hl]
    and CLEAR_BIT7_MASK
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
    cp AUDIO_PARAM1_LIMIT
    jr c, ConfigAudioChannel

    ld a, STATE_RENDER_STATE_BUFFER
    ld [wStateRender], a

ConfigAudioChannel:
    ld de, OBJECT_STRUCT_SIZE
    ld b, $00
    ld hl, wObjectBuffer

IterateObjects_Loop:
    ld a, [hl]
    inc a
    jr z, IterateObjects_End

    inc b
    add hl, de
    ld a, l
    cp AUDIO_OBJECT_END_LOW
    jr nz, IterateObjects_Loop

    ret


IterateObjects_End:
    ld a, b
    call SaveSoundDataToSlot
    ret


PlaySound:
    ld hl, wAudioBuffer
    ld [hl], a
    ldh a, [hSoundParam1]
    and TILE_ALIGN_MASK          ; Aligner sur tile (8 pixels)
    add $07
    ld [wAudioBufVar2], a
    ldh a, [hSoundParam2]
    ld [wAudioBufVar3], a
    call InitSoundSlot
    ld a, STATE_RENDER_STATE_BUFFER
    ld [wStateBuffer], a
    ret


ProcessAudioSlots:
    xor a
    ld [wAudioState2], a
    ld c, $00

ProcessAudioSlot_Loop:
    ld a, [wAudioState2]
    cp MAX_AUDIO_SLOTS         ; 20 slots max
    ret nc

    push bc
    ld a, c
    swap a
    ld hl, wObjectBuffer
    ld l, a
    ld a, [hl]
    inc a
    jr z, AudioSlotLoopEnd

    ld a, c
    call LoadSoundDataFromSlot
    ldh a, [hSoundParam2]
    cp AUDIO_PARAM2_LIMIT
    jr c, ProcessAudioSlot_CheckParam1

ProcessAudioSlot_Disable:
    ld a, SLOT_EMPTY            ; Marqueur slot audio désactivé
    ldh [hSoundId], a
    ld a, c
    call SaveSoundDataToSlot
    jr AudioSlotLoopEnd

ProcessAudioSlot_CheckParam1:
    ldh a, [hSoundParam1]
    cp AUDIO_PARAM1_LIMIT
    jr nc, ProcessAudioSlot_Disable

    call ProcessAudioChannelData

AudioSlotLoopEnd:
    pop bc
    inc c
    ld a, c
    cp AUDIO_SLOT_LOOP_COUNT     ; 10 slots audio
    jr nz, ProcessAudioSlot_Loop

    ld hl, wSpriteVar50
    ld a, [wAudioState2]
    rlca
    rlca
    ld d, $00
    ld e, a
    add hl, de

FillAudioBufferLoop:
    ld a, l
    cp SPRITE_BUFFER_END_LOW     ; Fin buffer sprite ($C0A0)
    jp nc, FillAudioBuffer_Exit

    ld a, AUDIO_BUFFER_FILL_VALUE
    ld [hl], a
    inc hl
    inc hl
    inc hl
    inc hl
    jr FillAudioBufferLoop

FillAudioBuffer_Exit:
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
    ld hl, ROM_AUDIO_CHANNEL_TABLE_1
    ldh a, [hSoundCh2]
    and BIT_0_MASK
    jr nz, LoadSoundChannel3Data

    ld hl, ROM_AUDIO_CHANNEL_TABLE_2

LoadSoundChannel3Data:
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

ProcessAudioCommandLoop:
    ld a, [wAudioState2]
    cp MAX_AUDIO_SLOTS         ; 20 slots max
    ret nc

NextAudioCommand:
    ld a, [hl]
    cp SLOT_EMPTY
    ret z

    bit 7, a
    jr nz, WriteAudioOutput

    rlca
    res 4, a
    ld [wAudioData], a
    ld a, [hl]
    bit 3, a
    jr z, SkipParam1Sub

    ldh a, [hSoundParam1]
    sub TILE_SIZE_PIXELS
    ldh [hSoundParam1], a
    ld a, [hl]

SkipParam1Sub:
    bit 2, a
    jr z, SkipParam1Add

    ldh a, [hSoundParam1]
    add TILE_SIZE_PIXELS
    ldh [hSoundParam1], a
    ld a, [hl]

SkipParam1Add:
    bit 1, a
    jr z, ProcessAudioParam2

    ldh a, [hSoundParam2]
    sub TILE_SIZE_PIXELS
    ldh [hSoundParam2], a
    ld a, [hl]

ProcessAudioParam2:
    bit 0, a
    jr z, NextAudioData

    ldh a, [hSoundParam2]
    add TILE_SIZE_PIXELS
    ldh [hSoundParam2], a

NextAudioData:
    inc hl
    jr NextAudioCommand

WriteAudioOutput:
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
    jr ProcessAudioCommandLoop

UpdateAllObjectSounds:
    ld hl, wObjectBuffer

AudioObjectLoopIteration:
    ld a, [hl]
    inc a
    jr z, NextSoundObject

    push hl
    call LoadSoundDataFromHL
    ld hl, ROM_AUDIO_POINTERS   ; Table pointeurs données audio ($3495)
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

NextSoundObject:
    ld a, l
    add OBJECT_STRUCT_SIZE
    ld l, a
    cp OBJECT_BUFFER_END_LOW     ; Fin buffer objets
    jp nz, AudioObjectLoopIteration

    ret


ProcessSoundAnimation:

ProcessSoundAnimationLoop:
    ldh a, [hSoundVar1]
    and a
    jr z, ProcessAudioQueue_Loop

    ldh a, [hSoundCh4]
    bit 1, a
    jr z, SoundAnimUpdateVar2

    call CheckObjectTileBottomLeft
    jr nc, SoundAnimClearParam1

    ldh a, [hSoundParam1]
    inc a
    ldh [hSoundParam1], a
    ret


SoundAnimClearParam1:
    ldh a, [hSoundParam1]
    and TILE_ALIGN_MASK          ; Aligner sur tile (8 pixels)
    ldh [hSoundParam1], a

SoundAnimUpdateVar2:
    ldh a, [hSoundVar2]
    and NIBBLE_HIGH_MASK         ; Compteur (nibble haut)
    swap a
    ld b, a
    ldh a, [hSoundVar2]
    and NIBBLE_LOW_MASK          ; Limite (nibble bas)
    cp b
    jr z, SoundAnimResetVar2

    inc b
    swap b
    or b
    ldh [hSoundVar2], a
    ret


SoundAnimResetVar2:
    ldh a, [hSoundVar2]
    and NIBBLE_LOW_MASK          ; Garder limite, reset compteur
    ldh [hSoundVar2], a
    ldh a, [hSoundVar1]
    dec a
    ldh [hSoundVar1], a
    jp ProcessSoundCollisionCheck


AudioQueueProcessing:
ProcessAudioQueue_Loop:
    push hl
    ld d, $00
    ldh a, [hSoundCh1]
    ld e, a
    add hl, de
    ld a, [hl]
    ld [wAudioQueueType], a
    cp SLOT_EMPTY
    jr nz, ProcessAudioQueue_Found

    xor a
    ldh [hSoundCh1], a
    pop hl
    jr ProcessAudioQueue_Loop

ProcessAudioQueue_Found:
    ldh a, [hSoundCh1]
    inc a
    ldh [hSoundCh1], a
    ld a, [wAudioQueueType]
    and NIBBLE_HIGH_MASK         ; Type audio (nibble haut)
    cp AUDIO_CMD_F0              ; Type $F0 = traitement spécial
    jr z, ProcessAudioQueue_Type_F0

    ld a, [wAudioQueueType]
    and BITS_5_7_MASK           ; Masque bits 5-7 audio type
    cp BITS_5_7_MASK            ; Test si tous bits 5-7 actifs
    jr nz, ProcessAudioQueue_Type_Other

    ld a, [wAudioQueueType]
    and NIBBLE_LOW_MASK          ; Paramètre audio (nibble bas)
    ldh [hSoundVar1], a
    pop hl
    jr ProcessSoundAnimationLoop

ProcessAudioQueue_Type_Other:
    ld a, [wAudioQueueType]
    ldh [hSoundFlag], a
    ld a, FLAG_TRUE
    ldh [hSoundVar1], a
    pop hl
    jp ProcessSoundAnimationLoop


ProcessAudioQueue_Type_F0:
    ldh a, [hSoundCh1]
    inc a
    ldh [hSoundCh1], a
    inc hl
    ld a, [hl]
    ld [wAudioQueueId], a
    ld a, [wAudioQueueType]
    cp AUDIO_CMD_F8             ; Commande set channel 3 ?
    jr nz, ProcessAudioQueue_Type_F0_NotF8

    ld a, [wAudioQueueId]
    ldh [hSoundCh3], a
    pop hl
    jr ProcessAudioQueue_Loop

ProcessAudioQueue_Type_F0_NotF8:
    cp AUDIO_CMD_F0             ; Commande special processing ?
    jr nz, CheckAudioCommand_F1

    ld a, [wAudioQueueId]
    and BITS_6_7_MASK           ; Test bits direction audio
    jr z, CheckAudioQueueBits54

    bit 7, a
    jr z, CheckAudioQueueBit6

    ldh a, [hSoundCh2]
    and CLEAR_BIT_1_MASK        ; Efface bit 1
    ld b, a
    ld a, [wPlayerX]
    ld c, a
    ldh a, [hSoundParam1]
    sub c
    rla
    rlca
    and BIT_1_MASK              ; Isole bit 1
    or b
    ldh [hSoundCh2], a

CheckAudioQueueBit6:
    ld a, [wAudioQueueId]
    bit 6, a
    jr z, CheckAudioQueueBits54

    ld a, [wPlayerState]
    ld c, a
    ldh a, [hSoundParam2]
    ld b, a
    ldh a, [hSoundVar3]
    and ANIM_HEIGHT_MASK
    rrca
    rrca
    add b
    sub c
    rla
    and BIT_0_MASK              ; Isole bit 0
    ld b, a
    ldh a, [hSoundCh2]
    and CLEAR_BIT_0_MASK        ; Efface bit 0
    or b
    ldh [hSoundCh2], a

CheckAudioQueueBits54:
    ld a, [wAudioQueueId]
    and BITS_2_3_MASK           ; Masque bits 2-3 (canal audio)
    jr z, CheckAudioQueueBit5

    rra
    rra
    ld b, a
    ldh a, [hSoundCh2]
    xor b
    ldh [hSoundCh2], a

CheckAudioQueueBit5:
    ld a, [wAudioQueueId]
    bit 5, a
    jr z, CheckAudioQueueBit4

    and BIT_1_MASK              ; Isole bit 1
    or CLEAR_BIT_1_MASK         ; Ou avec $FD (preserve autres bits)
    ld b, a
    ldh a, [hSoundCh2]
    set 1, a
    and b
    ldh [hSoundCh2], a

CheckAudioQueueBit4:
    ld a, [wAudioQueueId]
    bit 4, a
    jr z, AudioQueueProcessDone

    and BIT_0_MASK              ; Isole bit 0
    or CLEAR_BIT_0_MASK         ; Ou avec $FE (preserve autres bits)
    ld b, a
    ldh a, [hSoundCh2]
    set 0, a
    and b
    ldh [hSoundCh2], a

AudioQueueProcessDone:
    pop hl
    jp AudioQueueProcessing


CheckAudioCommand_F1:
    cp AUDIO_CMD_F1
    jr nz, CheckAudioCommand_F2

    ld a, AUDIO_SLOT_10
    call SaveSoundDataToSlot
    call LoadQueuedAudioConfig
    ld a, AUDIO_SLOT_10
    call LoadSoundDataFromSlot
    pop hl
    jp AudioQueueProcessing


CheckAudioCommand_F2:
    cp AUDIO_CMD_F2
    jr nz, CheckAudioCommand_F3

    ld a, [wAudioQueueId]
    ldh [hSoundCh4], a
    pop hl
    jp AudioQueueProcessing


CheckAudioCommand_F3:
    cp AUDIO_CMD_F3
    jr nz, CheckAudioCommand_F4

    ld a, [wAudioQueueId]
    ldh [hSoundId], a
    cp SLOT_EMPTY
    jp z, AudioCommand_CompleteExit

    ld hl, hSoundId
    call InitSoundSlot
    pop hl
    ld hl, ROM_AUDIO_POINTERS   ; Table pointeurs données audio
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
    jp AudioQueueProcessing


CheckAudioCommand_F4:
    cp AUDIO_CMD_F4
    jr nz, CheckAudioCommand_F5

    ld a, [wAudioQueueId]
    ldh [hSoundVar2], a
    pop hl
    jp AudioQueueProcessing


CheckAudioCommand_F5:
    cp AUDIO_CMD_F5
    jr nz, CheckAudioCommand_F6

    ldh a, [rDIV]
    and FRAME_MASK_4
    ld a, AUDIO_CMD_F1
    jr z, CheckAudioCommand_F1

    pop hl
    jp AudioQueueProcessing


CheckAudioCommand_F6:
    cp AUDIO_CMD_F6
    jr nz, CheckAudioCommand_F7

    ld a, [wPlayerState]
    ld b, a
    ldh a, [hSoundParam2]
    sub b
    add PLAYER_DISTANCE_OFFSET
    cp PLAYER_DISTANCE_RANGE
    ld a, [wAudioQueueId]
    dec a
    jr z, AudioCommand_F6_CheckTiming

    ccf

AudioCommand_F6_CheckTiming:
    jr c, AudioCommand_F6_Return

    ldh a, [hSoundCh1]
    dec a
    dec a
    ldh [hSoundCh1], a
    pop hl
    ret


AudioCommand_F6_Return:
    pop hl
    jp AudioQueueProcessing


CheckAudioCommand_F7:
    cp AUDIO_CMD_F7
    jr nz, CheckAudioCommand_F9

    call DestroyAllObjects
    pop hl
    ret


CheckAudioCommand_F9:
    cp AUDIO_CMD_F9
    jr nz, CheckAudioCommand_FA

    ld a, [wAudioQueueId]
    ld [wStateFinal], a
    pop hl
    ret


CheckAudioCommand_FA:
    cp AUDIO_CMD_FA
    jr nz, CheckAudioCommand_FB

    ld a, [wAudioQueueId]
    ld [wStateBuffer], a
    pop hl
    ret


CheckAudioCommand_FB:
    cp AUDIO_CMD_FB
    jr nz, CheckAudioCommand_FC

    ld a, [wAudioQueueId]
    ld c, a
    ld a, [wPlayerState]
    ld b, a
    ldh a, [hSoundParam2]
    sub b
    cp c
    jr c, AudioCommand_FB_CarryJump

    xor a
    ldh [hSoundCh1], a
    pop hl
    jp AudioQueueProcessing


AudioCommand_FB_CarryJump:
    pop hl
    jp AudioQueueProcessing


CheckAudioCommand_FC:
    cp AUDIO_CMD_FC
    jr nz, CheckAudioCommand_FD

    ld a, [wAudioQueueId]
    ldh [hSoundParam1], a
    ld a, AUDIO_PARAM2_DEFAULT
    ldh [hSoundParam2], a
    pop hl
    jp AudioQueueProcessing


CheckAudioCommand_FD:
    cp AUDIO_CMD_FD
    jr nz, AudioCommand_Default

    ld a, [wAudioQueueId]
    ld [wStateRender], a
    pop hl
    ret


AudioCommand_Default:
    pop hl
    jp AudioQueueProcessing


AudioCommand_CompleteExit:
    pop hl
    ret


ProcessSoundCollisionCheck:
    ldh a, [hSoundFlag]
    and NIBBLE_LOW_MASK          ; Type collision (nibble bas)
    jp z, UpdatePhysicsCollision

    ldh a, [hSoundCh2]
    bit 0, a
    jr nz, CollisionCheckTileRight

    call CheckObjectTileBase
    jr nc, CheckSoundChannel

    ldh a, [hSoundCh4]
    bit 0, a
    jr z, SoundParamProcessing

    call CheckObjectTileBottom
    jr c, SetSoundFrequency

SoundParamProcessing:
    ldh a, [hSoundFlag]
    and NIBBLE_LOW_MASK          ; Type collision (nibble bas)
    ld b, a
    ldh a, [hSoundParam2]
    sub b
    ldh [hSoundParam2], a
    ldh a, [hSoundVar4]
    and a
    jp z, UpdatePhysicsCollision

    ld a, [wPlayerUnk05]
    ld c, a
    push bc
    ld a, PLAYER_DIR_CHECK_LEFT  ; Valeur direction gauche pour collision
    ld [wPlayerUnk05], a
    call CheckPlayerSideCollision
    pop bc
    and a
    jr nz, RestoreSoundConfig

    ld a, [wPlayerState]
    sub b
    ld [wPlayerState], a
    cp PLAYER_STATE_OSCIL_THRESH  ; Seuil oscillation ($0F)
    jr nc, RestoreSoundConfig

    ld a, PLAYER_STATE_OSCIL_THRESH
    ld [wPlayerState], a

RestoreSoundConfig:
    ld a, c
    ld [wPlayerUnk05], a
    jp UpdatePhysicsCollision


CheckSoundChannel:
    ldh a, [hSoundCh4]
    and BITS_2_3_MASK           ; Masque bits 2-3 (canal son)
    cp BLOCK_HIT_NONE           ; Aucun bit actif ?
    jr z, SoundParamProcessing

    cp BIT_2_MASK               ; Test bit 2 seul
    jr nz, CheckSoundChannel.ch4_0c

SetSoundFrequency:
    ldh a, [hSoundCh2]
    set 0, a
    ldh [hSoundCh2], a
    jp UpdatePhysicsCollision


CheckSoundChannel.ch4_0c:
    cp SOUND_CHANNEL_BOTH_BITS
    jp nz, UpdatePhysicsCollision

    xor a
    ldh [hSoundCh1], a
    ldh [hSoundVar1], a
    jp UpdatePhysicsCollision


CollisionCheckTileRight:
    call CheckObjectTileRight
    jr nc, CheckObjectTileRight_Path

    ldh a, [hSoundCh4]
    bit 0, a
    jr z, ProcessVerticalCollision

    call CheckObjectTileBottomRight
    jr c, ResetSoundCh2Bit0

ProcessVerticalCollision:
    ldh a, [hSoundFlag]
    and NIBBLE_LOW_MASK          ; Type collision (nibble bas)
    ld b, a
    ldh a, [hSoundParam2]
    add b
    ldh [hSoundParam2], a
    ldh a, [hSoundVar4]
    and a
    jr z, UpdatePhysicsCollision

    ld a, [wPlayerUnk05]
    ld c, a
    push bc
    xor a
    ld [wPlayerUnk05], a
    call CheckPlayerSideCollision
    pop bc
    and a
    jr nz, RestoreCollisionFlagAndExit

    ld a, [wPlayerState]
    add b
    ld [wPlayerState], a
    cp PLAYER_STATE_SCROLL_THRESHOLD ; Seuil scroll caméra atteint?
    jr c, RestoreCollisionFlagAndExit

    ld a, [wCollisionFlag]
    cp COLLISION_THRESHOLD_7    ; Seuil collision 7
    jr nc, AlignCameraTo4PixelBoundary

ApplyHorizontalScrollOffset:
    ld a, [wPlayerState]
    sub PLAYER_STATE_SCROLL_LIMIT ; Calculer offset scroll
    ld b, a
    ld a, PLAYER_STATE_SCROLL_LIMIT ; Limiter état joueur
    ld [wPlayerState], a
    ldh a, [hShadowSCX]
    add b
    ldh [hShadowSCX], a
    call OffsetSpritesX

RestoreCollisionFlagAndExit:
    ld a, c
    ld [wPlayerUnk05], a
    jr UpdatePhysicsCollision

AlignCameraTo4PixelBoundary:
    ldh a, [hShadowSCX]
    and BITS_2_3_MASK           ; Masque bits 2-3 (alignement 4 pixels)
    jr nz, ApplyHorizontalScrollOffset

    ldh a, [hShadowSCX]
    and SCROLL_ALIGN_MASK        ; Aligner scroll sur 4 pixels
    ldh [hShadowSCX], a
    jr RestoreCollisionFlagAndExit

CheckObjectTileRight_Path:
    ldh a, [hSoundCh4]
    and BITS_2_3_MASK           ; Masque bits 2-3 (canal son)
    cp BLOCK_HIT_NONE           ; Aucun bit actif ?
    jr z, ProcessVerticalCollision

    cp BIT_2_MASK               ; Test bit 2 seul
    jr nz, ClearSoundCh1AndVar1_Collision

ResetSoundCh2Bit0:
    ldh a, [hSoundCh2]
    res 0, a
    ldh [hSoundCh2], a
    jr UpdatePhysicsCollision

ClearSoundCh1AndVar1_Collision:
    cp SOUND_CHANNEL_BOTH_BITS
    jr nz, UpdatePhysicsCollision

    xor a
    ldh [hSoundCh1], a
    ldh [hSoundVar1], a


UpdatePhysicsCollision:
    ldh a, [hSoundFlag]
    and NIBBLE_HIGH_MASK         ; Vélocité collision (nibble haut)
    jp z, CollisionEnd

    ldh a, [hSoundCh2]
    bit 1, a
    jr nz, CheckObjectTileBottomLeft_Path

    call CheckObjectTileTop
    jr nc, CheckObjectTileTop_Alternatives

SubtractSoundFlagFromParam1:
    ldh a, [hSoundFlag]
    and NIBBLE_HIGH_MASK         ; Vélocité collision (nibble haut)
    swap a
    ld b, a
    ldh a, [hSoundParam1]
    sub b
    ldh [hSoundParam1], a
    ldh a, [hSoundVar4]
    and a
    jr z, CollisionEnd

    ld a, [wPlayerX]
    sub b
    ld [wPlayerX], a
    jr CollisionEnd

CheckObjectTileTop_Alternatives:
    ldh a, [hSoundCh4]
    and BITS_6_7_MASK           ; Masque bits direction audio
    cp BLOCK_HIT_NONE           ; Test si aucun bit direction
    jr z, SubtractSoundFlagFromParam1

    cp BIT_6_MASK               ; Test bit 6 seul
    jp nz, CollisionPhysics_SoundChannelControl

    ldh a, [hSoundCh2]
    set 1, a
    ldh [hSoundCh2], a
    jr CollisionEnd

CollisionPhysics_SoundChannelControl:
    cp BITS_6_7_MASK            ; Test bits 6-7 ($C0)
    jr nz, CollisionEnd

    xor a
    ldh [hSoundCh1], a
    ldh [hSoundVar1], a
    jr CollisionEnd

CheckObjectTileBottomLeft_Path:
    call CheckObjectTileBottomLeft
    jr nc, CheckObjectTileBottomLeft_Alternatives

AddSoundFlagToParam1:
    ldh a, [hSoundFlag]
    and NIBBLE_HIGH_MASK         ; Vélocité collision (nibble haut)
    swap a
    ld b, a
    ldh a, [hSoundParam1]
    add b
    ldh [hSoundParam1], a
    ldh a, [hSoundVar4]
    and a
    jr z, CollisionEnd

    ld a, [wPlayerX]
    add b
    ld [wPlayerX], a
    jr CollisionEnd

CheckObjectTileBottomLeft_Alternatives:
    ldh a, [hSoundCh4]
    and BITS_4_5_MASK           ; Masque bits 4-5 (état audio)
    cp AUDIO_STATE_00           ; État audio 0 ?
    jr z, AddSoundFlagToParam1

    cp AUDIO_STATE_10           ; État audio 1 ?
    jr nz, ClearSoundCh1AndVar1_Collision2

    ldh a, [hSoundCh2]
    res 1, a
    ldh [hSoundCh2], a
    jr CollisionEnd

ClearSoundCh1AndVar1_Collision2:
    cp AUDIO_STATE_30           ; État audio 3 ?
    jr nz, CollisionEnd

    xor a
    ldh [hSoundCh1], a
    ldh [hSoundVar1], a


CollisionEnd:
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
    ld de, ROM_OBJECT_SOUND_TABLE
    add hl, de
    ld a, [hl]
    pop hl
    and a
    ret z

    push hl
    ld [hl], a
    call InitSoundSlot
    ld a, RETURN_COLLISION_FOUND
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
    ld de, ROM_OBJECT_SOUND_TABLE
    add hl, de
    inc hl
    ld a, [hl]
    pop hl
    and a
    ret z

    ld [hl], a
    call InitSoundSlot
    ld a, RETURN_COLLISION_FOUND
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
    ld de, ROM_OBJECT_SOUND_TABLE
    add hl, de
    inc hl
    inc hl
    ld a, [hl]
    pop hl
    cp SLOT_EMPTY
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
    add OBJ_FIELD_ANIM_COUNTER
    ld l, a
    ld a, [hl]
    and ANIM_COUNTER_MASK
    jr z, AnimationCounterZero

    ld a, [hl]
    dec a
    ld [hl], a
    pop hl
    ld a, [hl]
    cp ANIM_COUNTER_TRIGGER_50
    jr z, AnimationObjectTriggerSound

    cp ANIM_COUNTER_TRIGGER_8
    jr z, AnimationObjectTriggerSound

    jr AnimationObjectSoundDone

AnimationObjectTriggerSound:
    ld a, FLAG_TRUE
    ld [wStateVar10], a

AnimationObjectSoundDone:
    ld a, RETURN_ANIM_CONTINUE
    ret


AnimationCounterZero:
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
    ld de, ROM_OBJECT_SOUND_TABLE
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
    ld a, RETURN_COLLISION_FOUND
    ret


HandleGameplayObjectSound:
    push hl
    ld a, l
    add OBJ_FIELD_ANIM_COUNTER
    ld l, a
    ld a, [hl]
    and ANIM_COUNTER_MASK
    jr z, GameplayCounterZero

    ld a, [hl]
    dec a
    ld [hl], a
    pop hl
    ld a, [hl]
    cp ANIM_COUNTER_TRIGGER_26
    jr z, GameplayObjectTriggerSound

    cp ANIM_COUNTER_TRIGGER_97
    jr z, GameplayObjectTriggerSound

    cp ANIM_COUNTER_TRIGGER_96
    jr z, GameplayObject60TriggerSound

    jr GameplayObjectSoundDone

GameplayObject60TriggerSound:
    ld a, FLAG_TRUE
    ld [wStateFinal], a
    jr GameplayObjectSoundDone

GameplayObjectTriggerSound:
    ld a, FLAG_TRUE
    ld [wStateVar10], a

GameplayObjectSoundDone:
    ld a, RETURN_ANIM_CONTINUE
    ret


GameplayCounterZero:
    pop hl
    push hl
    ld a, [hl]
    cp ANIM_COUNTER_TRIGGER_96
    jr nz, GameplayObject60NotFound

    ld [wAudioCondition], a

GameplayObject60NotFound:
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
    ld de, ROM_OBJECT_SOUND_TABLE
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
    ld a, RETURN_COLLISION_FOUND
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
    ld de, ROM_OBJECT_SOUND_TABLE
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
    ld a, RETURN_COLLISION_FOUND
    ret


DestroyAllObjects:
    ld hl, wObjectBuffer

ScanObjectBuffer:
    ld a, [hl]
    cp SLOT_EMPTY
    jr z, NextObjectEntry

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

NextObjectEntry:
    ld a, l
    add OBJECT_STRUCT_SIZE
    ld l, a
    cp OBJECT_BUFFER_END_LOW     ; Fin buffer objets
    jr c, ScanObjectBuffer

    ld a, SFX_OBJECT_COMPLETE
    ldh [hSoundId], a
    xor a
    ldh [hSoundCh1], a

StoreAudioChannel4:
    ldh [hSoundCh4], a
    inc a
    ld [wStateFinal], a
    ret


    ldh a, [hSoundParam2]
    ld c, a
    ldh a, [hShadowSCX]
    add c
    add COLLISION_OFFSET_4
    ldh [hSpriteX], a
    ld c, a
    ldh a, [hSoundCh2]
    bit 0, a
    jr LoadSpriteCoordinates

    ldh a, [hSoundVar3]
    and ANIM_HEIGHT_MASK
    rrca
    add c
    ldh [hSpriteX], a

LoadSpriteCoordinates:
    ldh a, [hSoundParam1]
    ldh [hSpriteY], a
    call ReadTileUnderSprite
    cp TILEMAP_CMD_LOAD2        ; Tile < $5F = solide
    ret c

    cp TILE_SPECIAL_THRESHOLD   ; Tile >= $F0 = vide/traversable
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
    cp TILEMAP_CMD_LOAD2        ; Tile < $5F = solide
    ret c

    cp TILE_SPECIAL_THRESHOLD   ; Tile >= $F0 = vide/traversable
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
    add COLLISION_OFFSET_8
    ld c, a
    ldh a, [hSoundVar3]
    and ANIM_HEIGHT_MASK
    rrca
    add c
    sub COLLISION_OFFSET_8
    ldh [hSpriteX], a
    ldh a, [hSoundParam1]
    ldh [hSpriteY], a
    call ReadTileUnderSprite
    cp TILEMAP_CMD_LOAD2        ; Tile < $5F = solide
    ret c

    cp TILE_SPECIAL_THRESHOLD   ; Tile >= $F0 = vide/traversable
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
    add COLLISION_OFFSET_4
    ldh [hSpriteX], a
    ld c, a
    ldh a, [hSoundCh2]
    bit 0, a
    jr .setY

    ldh a, [hSoundVar3]
    and ANIM_HEIGHT_MASK
    rrca
    add c
    ldh [hSpriteX], a

.setY:
    ldh a, [hSoundParam1]
    add COLLISION_OFFSET_8
    ldh [hSpriteY], a
    call ReadTileUnderSprite
    cp TILEMAP_CMD_LOAD2        ; Tile < $5F = solide
    ret c

    cp TILE_SPECIAL_THRESHOLD   ; Tile >= $F0 = vide/traversable
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
    add COLLISION_OFFSET_3
    ldh [hSpriteX], a
    ldh a, [hSoundParam1]
    add COLLISION_OFFSET_8
    ldh [hSpriteY], a
    call ReadTileUnderSprite
    cp TILEMAP_CMD_LOAD2        ; Tile < $5F = solide
    ret c

    cp TILE_SPECIAL_THRESHOLD   ; Tile >= $F0 = vide/traversable
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
    add COLLISION_OFFSET_5
    ld c, a
    ldh a, [hSoundVar3]
    and ANIM_HEIGHT_MASK
    rrca
    add c
    sub COLLISION_OFFSET_8
    ldh [hSpriteX], a
    ldh a, [hSoundParam1]
    add COLLISION_OFFSET_8
    ldh [hSpriteY], a
    call ReadTileUnderSprite
    cp TILEMAP_CMD_LOAD2        ; Tile < $5F = solide
    ret c

    cp TILE_SPECIAL_THRESHOLD   ; Tile >= $F0 = vide/traversable
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
    add COLLISION_OFFSET_4
    ldh [hSpriteX], a
    ld c, a
    ldh a, [hSoundCh2]
    bit 0, a
    jr .calcY

    ldh a, [hSoundVar3]
    and ANIM_HEIGHT_MASK
    rrca
    add c
    ldh [hSpriteX], a

.calcY:
    ldh a, [hSoundVar3]
    and SPRITE_HEIGHT_INDEX_MASK
    dec a
    swap a
    rrca
    ld c, a
    ldh a, [hSoundParam1]
    sub c
    ldh [hSpriteY], a
    call ReadTileUnderSprite
    cp TILEMAP_CMD_LOAD2        ; Tile < $5F = solide
    ret c

    cp TILE_SPECIAL_THRESHOLD   ; Tile >= $F0 = vide/traversable
    ccf
    ret


    ldh a, [hSoundParam2]
    ld c, a
    ldh a, [hShadowSCX]
    add c
    add COLLISION_OFFSET_3
    ldh [hSpriteX], a
    ldh a, [hSoundVar3]
    and SPRITE_HEIGHT_INDEX_MASK
    dec a
    swap a
    rrca
    ld c, a
    ldh a, [hSoundParam1]
    sub c
    ldh [hSpriteY], a
    call ReadTileUnderSprite
    cp TILEMAP_CMD_LOAD2        ; Tile < $5F = solide
    ret c

    cp TILE_SPECIAL_THRESHOLD   ; Tile >= $F0 = vide/traversable
    ccf
    ret


    ldh a, [hSoundParam2]
    ld c, a
    ldh a, [hShadowSCX]
    add c
    add COLLISION_OFFSET_5
    ld c, a
    ldh a, [hSoundVar3]
    and ANIM_HEIGHT_MASK
    rrca
    sub c
    sub COLLISION_OFFSET_8
    ldh [hSpriteX], a
    ldh a, [hSoundVar3]
    and SPRITE_HEIGHT_INDEX_MASK
    dec a
    swap a
    rrca
    ld c, a
    ldh a, [hSoundParam1]
    sub c
    ldh [hSpriteY], a
    call ReadTileUnderSprite
    cp TILEMAP_CMD_LOAD2        ; Tile < $5F = solide
    ret c

    cp TILE_SPECIAL_THRESHOLD   ; Tile >= $F0 = vide/traversable
    ccf
    ret


OffsetSpritesX:
    ld a, b
    and a
    ret z

OffsetSpritesX.loop:
    ldh a, [hSoundParam2]
    sub b
    ldh [hSoundParam2], a
    push hl
    push de
    ld hl, wObjBufferVar03
    ld de, OBJECT_STRUCT_SIZE

OffsetSpritesX.apply_offset:
    ld a, [hl]
    sub b
    ld [hl], a
    add hl, de
    ld a, l
    cp OBJECT_BUFFER_END_LOW     ; Fin buffer objets
    jr c, OffsetSpritesX.apply_offset

    pop de
    pop hl
    ret


InitSoundSlot:
    push hl
    ld a, [hl]
    ld d, $00

InitSoundSlot.load_table:
    ld e, a
    rlca
    add e
    rl d
    ld e, a
    ld hl, ROM_AUDIO_CONFIG
    add hl, de

InitSoundSlot.read_params:
    ld a, [hl+]
    ld b, a
    ld a, [hl+]

InitSoundSlot.config_ready:
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
    ld b, AUDIO_SLOT_SIZE      ; 13 octets par slot

CopySoundDataLoop:
    ld a, [hl+]
    ld [de], a
    inc de
    dec b
    jr nz, CopySoundDataLoop

    ret


SaveSoundDataToSlot:
    swap a
    ld hl, wObjectBuffer
    ld l, a

SaveSoundDataToHL:
    ld de, hSoundId
    ld b, AUDIO_SLOT_SIZE      ; 13 octets par slot

SaveSoundDataLoop:
    ld a, [de]
    ld [hl+], a
    inc de
    dec b
    jr nz, SaveSoundDataLoop

    ret


    sub b
    rst $38
    db $10
    sub b
    rst $38
    sub c
    rst $38
    jr nz, OffsetSpritesX.loop

    rst $38
    ld b, b
    sub e
    ld c, b
    sub d
    rst $38
    ld b, b
    sub l
    ld c, b

AudioAnimData_00:
    sub h
    rst $38
    sub a
    ld [$ff96], sp
    sbc c
    ld [$ff98], sp
    db $10
    sub a
    jr InitSoundSlot.load_table

    rst $38
    db $10
    sbc c
    jr @-$66

    rst $38
    sbc d
    rst $38
    jr nz, InitSoundSlot.read_params

    jr z, InitSoundSlot.config_ready

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

AudioAnimData_01:
    jr nz, AudioAnimData_00

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

AudioAnimData_02:
    or b
    ld bc, $0ab1
    and b
    ld bc, hTemp1
    db $10
    or c
    ld de, $1ab0
    and c
    ld de, hTemp0
    jr nc, AudioAnimData_01

    ld sp, $3ac2
    db $d3
    ld sp, $ffd2
    or d
    ld bc, $0ab3

AudioAnimData_03:
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
    jr nz, AudioAnimData_02

    ld hl, hObjParamBuf1
    cp b
    ld bc, $ffb9
    db $10
    cp c
    ld de, $ffb8
    jr nz, AudioAnimData_03

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
    jp wPlayerUnk11


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

AudioAnimData_04:
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
    jr nz, AudioAnimData_04

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

AudioAnimData_05:
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
    jr nz, AudioAnimData_05

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
    jr z, AddressTable_00

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

AddressTable_00:
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
    jr DataBlock_00

    ld h, $2d
    jr z, JumpTargetTable_00

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

DataBlock_00:
    dec l
    sub c
    dec l
    sub e

JumpTargetTable_00:
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

AnimFrameDataLookup:
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

ErrorTrap_00:
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
    jr z, PaddingZone_02

PaddingZone_02:
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
    jr nc, JumpDispatchTable_00

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

JumpDispatchTable_00:
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

AnimState_Handler_00:
    xor e
    dec [hl]
    jp z, $da35

    dec [hl]
    db $e4
    dec [hl]
    ld [bc], a

AnimState_Data_00:
    ld [hl], $2f
    ld [hl], $41
    ld [hl], $53
    ld [hl], $6b
    ld [hl], $8a
    ld [hl], $c0

AnimState_Data_01:
    ld [hl], $c8
    ld [hl], $f2
    ld [hl], $f6
    ld [hl], $fa
    ld [hl], $ff
    ld [hl], $11
    scf
    rla
    scf

AnimState_Handler_01:
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

AnimState_Handler_02:
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

AnimStateDispatcher:
    inc d
    jr c, AnimState_Dispatcher_00

    jr c, AnimState_Dispatcher_01

AnimStateLoop:
    jr c, @+$78

    jr c, @-$6d

    jr c, @-$66

    jr c, AnimState_Handler_00

    jr c, AnimState_Data_00

    jr c, AnimState_Data_01

    jr c, AnimState_Handler_01

    jr c, AnimState_Handler_02

    jr c, AnimStateLoop

    jr c, AnimShiftState

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

AnimShiftState:
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

AnimState_Dispatcher_00:
    dec a
    inc a
    ld e, d
    inc a

AnimState_Dispatcher_01:
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

AudioInitData_StackVariantA:
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

JumpDispatchTable_01:
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

JumpDispatchTable_02:
    jr nz, JumpDispatchTable_01

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
    jr nz, JumpDispatchTable_02

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

PaddingZone_03:
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


RawDataBlock_00:
    ld hl, sp+$33
    jp hl


    pop af
    rla
    di
    jr RawDataBlock_00

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

AudioInitData_StackVariantB:
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

RawDataBlock_01:
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
    jr nz, RawDataBlock_01

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
    jr nc, RawDataBlock_02

    rst $28

RawDataBlock_02:
    ld b, c
    pop af
    jr nc, RawDataBlock_03

    rst $28

RawDataBlock_03:
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

RawDataBlock_04:
    nop
    rst $28
    rst $28
    rst $28
    di
    ld b, c

RawDataBlock_05:
    ld sp, hl
    inc bc
    ld hl, sp+$2f
    di
    dec c
    ld hl, sp+$30
    ldh a, [rNR10]
    ld bc, $f8e8
    ld sp, $f8e8
    jr nc, RawDataBlock_04

    ld hl, sp+$31
    add sp, -$08
    jr nc, RawDataBlock_05

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

RawDataBlock_06:
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
    jr nc, RawDataBlock_06

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

RawDataBlock_07:
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
    jr nz, RawDataBlock_07

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

ErrorTrap_01:
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

ClearMemoryLoop:
    ld [hl+], a
    dec b
    jr nz, ClearMemoryLoop

    ld hl, wLevelData
    ld a, LEVEL_DATA_INIT
    ld [hl+], a
    xor a
    ld [hl+], a
    ld a, LEVEL_BCD2_INIT
    ld [hl+], a
    call DisplayLevelBCDScore
    ld a, LEVEL_PARAM_INIT_20
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld a, LEVEL_PARAM_INIT_F6
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld a, LEVEL_PARAM_INIT_30
    ld [hl+], a
    xor a
    ld b, LEVEL_PARAM_LOOP_9

InitLoop_9Bytes:
    ld [hl+], a
    dec b
    jr nz, InitLoop_9Bytes

    ld a, LEVEL_PARAM_INIT_02
    ld [hl+], a
    dec a
    ld [hl+], a
    xor a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld a, LEVEL_PARAM_INIT_40
    ld [hl+], a
    xor a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld a, LEVEL_PARAM_INIT_40
    ld [hl+], a
    xor a
    ld b, LEVEL_PARAM_LOOP_8

InitLoop_8Bytes:
    ld [hl+], a
    dec b
    jr nz, InitLoop_8Bytes

    ld a, LEVEL_PARAM_COPY_COLS
    ld [hl+], a
    ld a, LEVEL_PARAM_COPY_ROWS
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
    cp GAME_STATE_OUTER             ; État $12 (joueur en périphérie)
    ret nc

    ld a, [wLevelData]
    cp LEVEL_DATA_INIT
    ret nz

    call DisplayLevelBCDScore
    ret


DisplayLevelBCDScore:
    ld de, VRAM_LEVEL_BCD
    ld a, [wLevelBCD1]
    ld b, a
    and NIBBLE_LOW_MASK          ; Chiffre unités niveau
    ld [de], a
    dec e
    ld a, b
    and NIBBLE_HIGH_MASK         ; Chiffre dizaines niveau
    swap a
    ld [de], a
    dec e
    ld a, [wLevelBCD2]
    and NIBBLE_LOW_MASK          ; Chiffre centaines niveau
    ld [de], a
    ret


; ===========================================================================
; État $12 - Configuration écran fin de niveau ($3D8E)
; LCD off, clear OAM, fill tilemap avec tiles vides, affiche vies → état $13
; ===========================================================================
State12_EndLevelSetup::
    ld hl, wStateRender
    ld a, STATE_RENDER_END_SETUP
    ld [hl], a
    xor a
    ldh [rLCDC], a
    ldh [hShadowSCX], a
    ld hl, wOamBuffer
    ld b, OAM_BUFFER_FULL

InitLoop_160Bytes:
    ld [hl+], a
    dec b
    jr nz, InitLoop_160Bytes

    ld hl, VRAM_BG_BASE
    ld b, $ff
    ld c, TILEMAP_FILL_LOOPS
    ld a, TILE_EMPTY

FillTilemap_MainLoop:
    ld [hl+], a
    dec b
    jr nz, FillTilemap_MainLoop

    ld b, $ff
    dec c
    jr nz, FillTilemap_MainLoop

    ld de, VRAM_LIVES_DISPLAY
    ld a, [wLivesCounter]
    ld b, a
    and NIBBLE_LOW_MASK          ; Chiffre unités vies
    ld [de], a
    dec e
    ld a, b
    and NIBBLE_HIGH_MASK         ; Chiffre dizaines vies
    swap a
    ld [de], a
    ld a, LCDC_END_SCREEN
    ldh [rLCDC], a
    ld a, GAME_STATE_DRAW_BORDER
    ldh [hGameState], a
    ret

; ===========================================================================
; État $13 - Dessin bordure écran fin ($3DCE)
; Dessine la bordure décorative, texte "BONUS GAME", sélection → état $14
; ===========================================================================
State13_DrawEndBorder::
    xor a
    ldh [rLCDC], a
    ld hl, VRAM_BG_BASE
    ld a, TILE_BORDER_TOP_LEFT
    ld [hl+], a
    ld b, TEXT_LINE_WIDTH
    ld a, TILE_BORDER_HORIZONTAL

FillBorderRow:
    ld [hl+], a
    dec b
    jr nz, FillBorderRow

    ld a, TILE_BORDER_TOP_RIGHT
    ld [hl], a
    ld de, TILEMAP_STRIDE
    ld l, e
    ld b, BORDER_COLUMN_HEIGHT
    ld c, BORDER_COLUMN_COUNT
    ld a, TILE_BORDER_VERTICAL

FillBorderColumn:
    ld [hl], a
    add hl, de
    dec b
    jr nz, FillBorderColumn

    ld l, $33
    dec h
    dec h
    ld b, BORDER_COLUMN_HEIGHT
    dec c
    jr nz, FillBorderColumn

    ld hl, VRAM_BORDER_BOTTOM_ROW
    ld a, TILE_BORDER_BOTTOM_LEFT
    ld [hl+], a
    ld b, TEXT_LINE_WIDTH
    ld a, TILE_BORDER_HORIZONTAL

FillBottomBorderRow:
    ld [hl+], a
    dec b
    jr nz, FillBottomBorderRow

    ld a, TILE_BORDER_BOTTOM_RIGHT
    ld [hl], a
    ; === Écriture "BONUS GAME" ===
    ld hl, VRAM_END_TEXT_ROW1
    ld a, TEXT_CHAR_B              ; 'B'
    ld [hl+], a
    ld a, TEXT_CHAR_O              ; 'O'
    ld [hl+], a
    dec a                          ; 'N' (TEXT_CHAR_O - 1 = $17)
    ld [hl+], a
    ld a, TEXT_CHAR_U              ; 'U'
    ld [hl+], a
    ld a, TEXT_CHAR_S              ; 'S'
    ld [hl+], a
    inc l                          ; espace
    ld a, TEXT_CHAR_G              ; 'G'
    ld [hl+], a
    ld a, TEXT_CHAR_A              ; 'A'
    ld [hl+], a
    ld a, TEXT_CHAR_M              ; 'M'
    ld [hl+], a
    ld a, TEXT_CHAR_E              ; 'E'
    ld [hl], a
    ld hl, VRAM_END_TEXT_ROW2
    ld a, TILE_CREDITS_SPECIAL
    ld [hl+], a
    inc l
    ld a, TILE_TEXT_CORNER
    ld [hl], a
    ld l, $e1
    ld a, TILE_TEXT_FILL
    ld b, TEXT_LINE_WIDTH

FillTextLineRow1:
    ld [hl+], a
    dec b
    jr nz, FillTextLineRow1

    ld l, $d1
    ld a, TILE_TEXT_CORNER
    ld [hl+], a
    ld l, $41
    inc h
    ld a, TILE_TEXT_FILL
    ld b, TEXT_LINE_WIDTH

FillTextLineRow2:
    ld [hl+], a
    dec b
    jr nz, FillTextLineRow2

    ld l, $31
    ld a, TILE_TEXT_CORNER
    ld [hl+], a
    ld l, $a1
    ld a, TILE_TEXT_FILL
    ld b, TEXT_LINE_WIDTH

FillTextLineRow3:
    ld [hl+], a
    dec b
    jr nz, FillTextLineRow3

    ld l, $91
    ld a, TILE_TEXT_CORNER
    ld [hl+], a
    ld l, $01
    inc h
    ld a, TILE_TEXT_FILL
    ld b, TEXT_LINE_WIDTH

FillTextLineRow4:
    ld [hl+], a
    dec b
    jr nz, FillTextLineRow4

    ld l, $f1
    dec h
    ld a, TILE_TEXT_CORNER
    ld [hl+], a
    nop
    ld bc, $e502
    inc bc
    ld bc, $e502
    ld de, $3e72
    ldh a, [rDIV]
    and FRAME_MASK_4
    inc a

SkipFrames:
    inc de
    dec a
    jr nz, SkipFrames

    ld hl, VRAM_END_COPY_START
    ld bc, VRAM_END_COPY_STRIDE ; Stride de 3 lignes

CopyToBackBuffer:
    ld a, [de]
    ld [hl], a
    inc de
    add hl, bc
    ld a, l
    cp VRAM_END_COPY_END_LOW    ; Fin de la copie ?
    jr nz, CopyToBackBuffer

    ld a, LCDC_END_SCREEN
    ldh [rLCDC], a
    ld a, GAME_STATE_BONUS_SELECT
    ldh [hGameState], a
    ret

; ===========================================================================
; État $16 - Copie données tilemap ($3E9E)
; Copie données depuis $DA23 vers tilemap, avec compteur $DA28/$DA29 → état $15
; ===========================================================================
State16_CopyTilemapData::
    ld bc, TILEMAP_STRIDE

CopyTilemapOuter:
    ld de, wLevelParam23
    ld a, [wLevelParam18]
    ld h, a
    ld a, [wLevelParam19]
    ld l, a

CopyTilemapInner:
    ld a, [de]
    ld [hl], a
    inc de
    add hl, bc
    ld a, [wLevelParam28]
    dec a
    ld [wLevelParam28], a
    jr nz, CopyTilemapInner

    ld a, LEVEL_PARAM_COPY_COLS
    ld [wLevelParam28], a
    ld a, [wLevelParam29]
    dec a
    ld [wLevelParam29], a
    jr nz, CopyTilemapOuter

    ld a, LEVEL_PARAM_COPY_ROWS
    ld [wLevelParam29], a
    ld a, GAME_STATE_BONUS_COPY
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
    sub OAM_Y_OFS         ; Retire offset OAM Y
    srl a
    srl a
    srl a                 ; Y pixels → ligne tile (÷8)
    ld de, $0000
    ld e, a
    ld hl, VRAM_BG_BASE   ; Base tilemap BG
    ld b, TILEMAP_STRIDE  ; Largeur = 32 tiles

.multiplyRow:
    add hl, de            ; HL += ligne (×32 via boucle)
    dec b
    jr nz, .multiplyRow

    ldh a, [hSpriteX]
    sub OAM_X_OFS         ; Retire offset OAM X
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
    ld b, SPRITE_BITS_SHIFT

.shiftRight:
    rr d
    rr e
    dec b
    jr nz, .shiftRight

    ld a, e
    sub TILE_ADDR_Y_BASE
    and CLEAR_BIT_0_MASK
    rlca
    rlca
    add TILE_SIZE_PIXELS
    ldh [hSpriteY], a
    ldh a, [hSpriteTile]
    and TILEMAP_COLUMN_MASK
    rla
    rla
    rla
    add TILE_SIZE_PIXELS
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
    cp SCROLL_PHASE_DONE
    ret z                   ; Oui → return

    ; --- SetupPointers ---
    ld de, wScoreBCD        ; DE = source (score BCD, high byte first)
    ld hl, VRAM_HUD_LINE    ; HL = destination (tilemap)

;; --- ConvertBCDToTiles ---
;; Convertit 3 octets BCD en 6 tiles avec suppression des zéros de tête
ConvertBCDToTiles:
    xor a
    ldh [hScoreNeedsUpdate], a          ; Clear "needs update" flag
    ld c, SCORE_BCD_SIZE    ; 3 octets à traiter

BCD_ProcessByte:
    ; --- ProcessHighNibble ---
    ld a, [de]              ; Lire octet BCD
    ld b, a                 ; Sauvegarder dans B
    swap a                  ; High nibble → low nibble
    and NIBBLE_LOW_MASK     ; Masquer nibble bas (ex-haut)
    jr nz, BCD_MarkNonZeroHigh      ; Si != 0 → afficher chiffre

    ; Chiffre = 0, vérifier si leading zero
    ldh a, [hScoreNeedsUpdate]          ; Déjà affiché un chiffre non-zéro ?
    and a
    ld a, TILE_DIGIT_0      ; Tile "0"
    jr nz, BCD_WriteTile      ; Oui → afficher "0"

    ld a, TILE_EMPTY        ; Non → afficher espace (leading zero suppression)

BCD_WriteTile:
    ld [hl+], a             ; Écrire tile, avancer

    ; --- ProcessLowNibble ---
    ld a, b                 ; Récupérer octet original
    and NIBBLE_LOW_MASK     ; Low nibble
    jr nz, BCD_MarkNonZeroLow      ; Si != 0 → afficher chiffre

    ; Chiffre = 0, vérifier si leading zero
    ldh a, [hScoreNeedsUpdate]          ; Déjà affiché un chiffre non-zéro ?
    and a
    ld a, TILE_DIGIT_0      ; Tile "0"
    jr nz, BCD_WriteLowNibble      ; Oui → afficher "0"

    ; Cas spécial : dernier octet, afficher au moins "0"
    ld a, FLAG_TRUE
    cp c                    ; Est-ce le dernier octet ?
    ld a, TILE_DIGIT_0
    jr z, BCD_WriteLowNibble       ; Oui → afficher "0" (pas d'espace)

    ld a, TILE_EMPTY        ; Non → espace (leading zero)

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
    ld a, FLAG_TRUE
    ldh [hScoreNeedsUpdate], a          ; Marquer "a vu un chiffre non-zéro"
    pop af
    jr BCD_WriteTile

; --- MarkNonZeroSeen (low nibble) ---
BCD_MarkNonZeroLow:
    push af
    ld a, FLAG_TRUE
    ldh [hScoreNeedsUpdate], a          ; Marquer "a vu un chiffre non-zéro"
    pop af
    jr BCD_WriteLowNibble

; Routine DMA - copiée en HRAM pour transfert OAM
; Transfère 160 octets de $C000 (shadow OAM) vers $FE00 (OAM)
DMA_Routine:
    ld a, DMA_SOURCE_HIGH
    ldh [rDMA], a
    ld a, DMA_WAIT_CYCLES

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
