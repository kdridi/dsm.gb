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
DEF hPendingCoin    EQU _HRAM_END ; Alias: flag pièce en attente de collection
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
DEF IE_VBLANK_STAT_TIMER EQU IEF_VBLANK | IEF_STAT | IEF_TIMER  ; $07 - VBlank + STAT + Timer

; === Configuration Timer (TAC) ===
; (TACF_* sont définis dans hardware.inc)
DEF TAC_ENABLED_16KHZ EQU TACF_START | TACF_16KHZ  ; $07 - Timer actif à 16384 Hz

; === Palettes ===

DEF PALETTE_STANDARD    EQU $E4 ; %11100100 - noir, gris foncé, gris clair, blanc
DEF PALETTE_SPRITE_ALT  EQU $54 ; %01010100 - palette alternative sprites

; === Audio ===
; (AUDENA_ON est défini dans hardware.inc)

DEF AUDVOL_MAX      EQU $77     ; Volume max gauche ($7) et droite ($7)
DEF AUDTERM_ALL     EQU $FF     ; Tous canaux (1-4) sur sorties L et R

; === ROM Banks ===

DEF BANK_AUDIO      EQU $03     ; Bank 3 = routines audio
DEF BANK_DEMO       EQU $02     ; Bank 2 = démo automatique (Attract Mode)

; === GameLoop - Constantes ===

DEF SPECIAL_STATE_TRIGGER   EQU $03     ; wSpecialState = 3 déclenche reset
DEF SPECIAL_STATE_RESET     EQU $FF     ; Valeur reset de wSpecialState
DEF ROM_BANK3_MAIN_LOGIC    EQU $47F2   ; Routine principale en bank 3
DEF GAMELOOP_TIMER_COUNT    EQU $02     ; Nombre de timers à décrémenter
DEF ATTRACT_FRAME_MASK      EQU $0F     ; Masque décrémentation (16 frames)

; === Variables HRAM ($FF80-$FFFE) ===
; Convention: hXxxYyy (h minuscule + CamelCase)

; --- Joypad ---
DEF hJoypadState    EQU $FF80   ; État joypad (directions + boutons)
DEF hJoypadDelta    EQU $FF81   ; Changement joypad (XOR ancien/nouveau)

; --- Flags système ---
DEF hVBlankFlag     EQU $FF85   ; Flag VBlank (0=attente, 1=VBlank reçu)
DEF hAnimFrameIndex EQU $FF89   ; Index frame animation courante
DEF hPauseFlag      EQU $FFB2   ; Flag pause (0=normal, 1=pause)

; --- Paramètres de fonction ---
DEF hParam1         EQU $FF8D   ; Paramètre de fonction 1
DEF hParam2         EQU $FF8E   ; Paramètre de fonction 2
DEF hParam3         EQU $FF8F   ; Paramètre de fonction 3

; --- Animation sprites ---
DEF hAnimObjX       EQU $FF90   ; Coordonnée X objet animation
DEF hAnimObjY       EQU $FF91   ; Coordonnée Y objet animation
DEF hAnimCalcX      EQU $FF92   ; Résultat calcul position X
DEF hAnimCalcY      EQU $FF93   ; Résultat calcul position Y
DEF hAnimAttr       EQU $FF94   ; Attributs sprite animation
DEF hAnimHiddenFlag EQU $FF95   ; Flag sprite caché (!=0 → Y=$FF)
DEF hAnimStructHigh EQU $FF96   ; Pointeur structure anim (haut)
DEF hAnimStructLow  EQU $FF97   ; Pointeur structure anim (bas)

; --- Variables animation (suite) ---
DEF hLevelIndex     EQU $FF9A   ; Index/type de niveau (copie de wLevelType)
DEF hAnimObjSubState EQU $FF9B  ; Sous-état objet animation
DEF hAnimObjCount   EQU $FF9C   ; Compteur objets à traiter
DEF hAnimScaleCounter EQU $FF9D ; Compteur scaling/zoom
DEF hAnimStructBank EQU $FF9E   ; Bank structure animation
DEF hUpdateLockFlag EQU $FF9F   ; Flag bloquant mise à jour graphique

; --- Variables temporaires ---
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
DEF hObjParamBuf0   EQU $FFA8   ; Buffer paramètres objet 0
DEF hObjParamBuf1   EQU $FFA9   ; Buffer paramètres objet 1
DEF hObjParamBuf2   EQU $FFAA   ; Buffer paramètres objet 2
DEF hObjParamBuf3   EQU $FFAB   ; Buffer paramètres objet 3
DEF hFrameCounter   EQU $FFAC   ; Compteur de frames

; --- Sprite temporaire (OAM) ---
DEF hSpriteY        EQU $FFAD   ; Coordonnée Y sprite temporaire
DEF hSpriteX        EQU $FFAE   ; Coordonnée X sprite temporaire
DEF hSpriteTile     EQU $FFAF   ; Tile sprite temporaire
DEF hSpriteAttr     EQU $FFB0   ; Attributs sprite temporaire

; --- État du jeu ---
DEF hScoreNeedsUpdate EQU $FFB1 ; Flag mise à jour affichage score
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

; --- Audio étendu (enveloppes et état) ---
DEF hAudioControl   EQU $FFD0   ; Contrôle audio principal
DEF hAudioStatus    EQU $FFD1   ; Status audio
DEF hAudioCh1Param  EQU $FFD2   ; Paramètre canal audio 1
DEF hAudioCh2Param  EQU $FFD3   ; Paramètre canal audio 2
DEF hAudioEnvPos    EQU $FFD5   ; Position enveloppe audio
DEF hAudioEnvDiv    EQU $FFD6   ; Diviseur enveloppe
DEF hAudioEnvRate   EQU $FFD7   ; Taux enveloppe
DEF hAudioEnvCounter EQU $FFD8  ; Compteur enveloppe
DEF hAudioEnvParam1 EQU $FFD9   ; Paramètre enveloppe 1
DEF hAudioEnvParam2 EQU $FFDA   ; Paramètre enveloppe 2
DEF hAudioMixerSnapshot EQU $FFDE ; Sauvegarde NR51 (pause)
DEF hSavedAudio     EQU $FFDF   ; État audio sauvegardé (pause)

; --- Pointeurs et copie ---
DEF hVramPtrLow     EQU $FFE0   ; Pointeur VRAM (octet bas)
DEF hSavedBank      EQU $FFE1   ; Bank sauvegardée (temporaire)
DEF hCopyDstLow     EQU $FFE2   ; Destination copie (bas)
DEF hCopyDstHigh    EQU $FFE3   ; Destination copie (haut)

; --- Tilemap et rendu ---
DEF hRenderContext  EQU $FFE4   ; Contexte de rendu (init à 0)
DEF hTilemapScrollX EQU $FFE5   ; Offset X tilemap
DEF hTilemapScrollY EQU $FFE6   ; Offset Y tilemap
DEF hTilemapOffsetX EQU $FFE7   ; Décalage X tilemap
DEF hTilemapOffsetY EQU $FFE8   ; Décalage Y tilemap
DEF hPtrLow         EQU $FFEB   ; Pointeur générique (bas)
DEF hPtrHigh        EQU $FFEC   ; Pointeur générique (haut)
DEF hPtrBank        EQU $FFED   ; Bank du pointeur
DEF hBlockHitType  EQU $FFEE   ; Type collision bloc (0=rien, 1/2/4/$c0=actions)

; --- Rendu tilemap (état machine) ---
DEF hCurrentTile    EQU $FFF0   ; Tile courant en rendu
DEF hRenderX        EQU $FFF1   ; Position X rendu
DEF hRenderY        EQU $FFF2   ; Position Y rendu
DEF hRenderAttr     EQU $FFF3   ; Attributs rendu
DEF hRenderCounter  EQU $FFF4   ; Compteur rendu
DEF hRenderMode     EQU $FFF5   ; Mode rendu
DEF hDestY          EQU $FFF6   ; Position Y destination (pipe/transition)
DEF hDestX          EQU $FFF7   ; Position X destination (pipe/transition)

; --- VBlank et OAM ---
DEF hVBlankSelector EQU $FFF8   ; Sélecteur routine VBlank
DEF hVBlankMode     EQU $FFF9   ; Mode VBlank
DEF hCoinCount     EQU $FFFA   ; Compteur DMA
DEF hOAMIndex       EQU $FFFB   ; Index entrée OAM
DEF hOAMAddrLow     EQU $FFFC   ; Adresse OAM (bas)
DEF hCurrentBank    EQU $FFFD   ; Bank ROM courante

; === Variables WRAM ($C000-$DFFF) ===
; Convention: wXxxYyy (w minuscule + CamelCase)

; --- OAM et sprites ($C000-$C0A0) ---
DEF wOamBuffer      EQU $C000   ; Buffer OAM pour DMA (160 octets)
DEF wOamAttrY       EQU $C001   ; Attribut Y OAM
DEF wOamSprite1Y    EQU $C004   ; Position Y sprite 1 (OAM slot 1)
DEF wOamSprite2     EQU $C008   ; Début données sprite 2 (OAM slot 2)
DEF wOamVar09       EQU $C009   ; Variable OAM +09
DEF wOamVar0C       EQU $C00C   ; Variable OAM +0C
DEF wOamVar1C       EQU $C01C   ; Variable OAM +1C
DEF wOamVar2C       EQU $C02C   ; Variable OAM +2C
DEF wOamVar2D       EQU $C02D   ; Variable OAM +2D
DEF wOamVar2E       EQU $C02E   ; Variable OAM +2E
DEF wSpriteTemp     EQU $C030   ; Buffer sprite temporaire
DEF wSpriteVar31    EQU $C031   ; Variable sprite +01
DEF wSpriteVar32    EQU $C032   ; Variable sprite +02
DEF wSpriteVar36    EQU $C036   ; Variable sprite +06
DEF wJumpTarget43   EQU $C043   ; Cible de saut en WRAM
DEF wSpriteVar50    EQU $C050   ; Variable sprite +20
DEF wTilemapBuf70   EQU $C070   ; Buffer tilemap +00
DEF wTilemapBuf71   EQU $C071   ; Buffer tilemap +01
DEF wTilemapBuf75   EQU $C075   ; Buffer tilemap +05
DEF wTilemapBuf79   EQU $C079   ; Buffer tilemap +09
DEF wTilemapBuf7D   EQU $C07D   ; Buffer tilemap +0D
DEF wTilemapBuf81   EQU $C081   ; Buffer tilemap +11
DEF wTilemapBuf85   EQU $C085   ; Buffer tilemap +15

; --- Variables de jeu ($C0A0-$C0FF) ---
DEF wScoreBCDHigh   EQU $C0A0   ; Score BCD (octet haut)
DEF wScoreBCDMid    EQU $C0A1   ; Score BCD (octet milieu)
DEF wScoreBCD       EQU $C0A2   ; Score en BCD (3 octets, octet bas)
DEF wUpdateCounter  EQU $C0A3   ; Flag mise à jour compteur
DEF wROMBankInit    EQU $C0A4   ; Bank ROM init ($03 initial)
DEF wGameConfigA5   EQU $C0A5   ; Configuration jeu
DEF wGameConfigA6   EQU $C0A6   ; Configuration jeu
DEF wAnimTileIdx    EQU $C0A8   ; Index tile animation ($11 initial)
DEF wGameVarA9      EQU $C0A9   ; Variable jeu A9
DEF wGameVarAA      EQU $C0AA   ; Variable jeu AA
DEF wPlayerVarAB    EQU $C0AB   ; Variable joueur
DEF wGameVarAC      EQU $C0AC   ; Variable jeu AC
DEF wPlayerVarAD    EQU $C0AD   ; Variable joueur
DEF wGameVarAE      EQU $C0AE   ; Variable jeu AE
DEF wScrollBuffer   EQU $C0B0   ; Buffer colonne tilemap (16 octets)
DEF wScorePrevious  EQU $C0C2   ; Score précédent (comparaison)
DEF wLevelConfig    EQU $C0CE   ; Configuration niveau
DEF wCollisionFlag  EQU $C0D2   ; Flag collision
DEF wPlayerInvuln   EQU $C0D3   ; Flag invulnérabilité joueur
DEF wAttractModeTimer   EQU $C0D7   ; Timer pour l'Attract Mode (démo auto)
DEF wLevelVarD8     EQU $C0D8   ; Variable niveau
DEF wLevelVarD9     EQU $C0D9   ; Variable niveau D9
DEF wLevelVarDA     EQU $C0DA   ; Variable niveau
DEF wLevelVarDB     EQU $C0DB   ; Variable niveau DB
DEF wCurrentROMBank EQU $C0DC   ; Bank ROM courante ($02 initial)
DEF wLevelVarDD     EQU $C0DD   ; Variable niveau DD
DEF wAudioSaveDE    EQU $C0DE   ; Sauvegarde audio
DEF wLevelInitFlag  EQU $C0DF   ; Flag init niveau
DEF wLevelType      EQU $C0E1   ; Type de niveau (init à 0)
DEF wCoinUpdateDone EQU $C0E2   ; Flag: bloque score update après coin update
DEF wGameVarFE      EQU $C0FE   ; Variable jeu FE
DEF wGameVarFF      EQU $C0FF   ; Variable jeu FF

; --- Structure joueur ($C200-$C217) ---
DEF wPlayerData     EQU $C200   ; Données joueur (structure)
DEF wPlayerY        EQU $C200   ; Position Y joueur
DEF wPlayerX        EQU $C201   ; Position X joueur
DEF wPlayerState    EQU $C202   ; État joueur
DEF wPlayerDir      EQU $C203   ; Direction joueur
DEF wPlayerFlag     EQU $C204   ; Flag joueur actif
DEF wPlayerUnk05    EQU $C205   ; Variable joueur
DEF wPlayerUnk07    EQU $C207   ; Variable joueur
DEF wPlayerUnk0A    EQU $C20A   ; Variable joueur 0A
DEF wPlayerUnk0B    EQU $C20B   ; Variable joueur
DEF wPlayerUnk0C    EQU $C20C   ; Variable joueur
DEF wPlayerUnk0E    EQU $C20E   ; Variable joueur
DEF wPlayerUnk10    EQU $C210   ; Variable joueur
DEF wPlayerUnk11    EQU $C211   ; Variable joueur 11
DEF wPlayerUnk12    EQU $C212   ; Variable joueur 12
DEF wPlayerUnk13    EQU $C213   ; Variable joueur

; --- Stack WRAM ($C149) ---
DEF wStackWRAM      EQU $C149   ; Stack pointer en WRAM

; --- Slots objets ($C208-$C25F) ---
DEF OBJECT_SLOT_SIZE EQU $10    ; Taille d'un slot objet (16 octets)
DEF OBJECT_SLOT_COUNT EQU 5     ; Nombre de slots objets
DEF wObject1        EQU $C208   ; Slot objet 1
DEF wObject2        EQU $C218   ; Slot objet 2
DEF wObject2State   EQU $C222   ; État objet 2 (offset +$0A)
DEF wObject3        EQU $C228   ; Slot objet 3
DEF wObject4        EQU $C238   ; Slot objet 4
DEF wObject4Unk08   EQU $C240   ; Variable objet 4 (offset +$08)
DEF wObject4Unk09   EQU $C241   ; Variable objet 4 (offset +$09)
DEF wObject4Unk0A   EQU $C242   ; Variable objet 4 (offset +$0A)
DEF wObject5        EQU $C248   ; Slot objet 5

; --- Buffer animation ---
DEF wAnimBuffer     EQU $C600   ; Buffer animation

; === Variables extended WRAM ($D000-$DFFF) ===

; --- Zone données ($D000-$D100) ---
DEF wAudioData      EQU $D000   ; Données audio
DEF wAudioQueueType EQU $D002   ; Type de son en queue
DEF wAudioQueueId   EQU $D003   ; ID son en queue
DEF wAudioCondition EQU $D007   ; Condition audio
DEF wAudioState0    EQU $D010   ; État audio 0
DEF wAudioState1    EQU $D011   ; État audio 1
DEF wAudioState2    EQU $D013   ; État audio 2
DEF wAnimFlag       EQU $D014   ; Flag animation active
DEF wObjectBuffer   EQU $D100   ; Buffer objets (10 × 16 bytes)
DEF OBJECT_BUFFER_COUNT EQU 10  ; Nombre de slots dans wObjectBuffer
DEF wObjBufferVar03 EQU $D103   ; Variable buffer objets +03
DEF wObjBufferVar3D EQU $D13D   ; Variable buffer objets +3D
DEF wRoutineWRAM    EQU $D14C   ; Routine copiée en WRAM
DEF wStackInit      EQU $D157   ; Stack pointer initial
DEF wAudioBuffer    EQU $D190   ; Buffer audio
DEF wAudioBufVar2   EQU $D192   ; Buffer audio +2
DEF wAudioBufVar3   EQU $D193   ; Buffer audio +3

; --- Zone niveau ($DA00-$DA29) ---
DEF wLevelData      EQU $DA00   ; Type de niveau
DEF wLevelBCD1      EQU $DA01   ; Données niveau BCD 1
DEF wLevelBCD2      EQU $DA02   ; Données niveau BCD 2
DEF wLevelParam03   EQU $DA03   ; Paramètre niveau 03
DEF wLevelParam04   EQU $DA04   ; Paramètre niveau 04
DEF wLevelParam05   EQU $DA05   ; Paramètre niveau 05
DEF wLevelParam06   EQU $DA06   ; Paramètre niveau 06
DEF wLevelParam07   EQU $DA07   ; Paramètre niveau 07
DEF wLevelParam08   EQU $DA08   ; Paramètre niveau 08
DEF wLevelParam09   EQU $DA09   ; Paramètre niveau 09
DEF wLevelParam0A   EQU $DA0A   ; Paramètre niveau 0A
DEF wLevelParam0B   EQU $DA0B   ; Paramètre niveau 0B
DEF wLevelParam0C   EQU $DA0C   ; Paramètre niveau 0C
DEF wLevelParam0D   EQU $DA0D   ; Paramètre niveau 0D
DEF wLevelParam0E   EQU $DA0E   ; Paramètre niveau 0E
DEF wLevelParam0F   EQU $DA0F   ; Paramètre niveau 0F
DEF wLevelDifficulty EQU $DA14  ; Difficulté niveau
DEF wLivesCounter   EQU $DA15   ; Compteur vies (BCD)
DEF wLevelBonus     EQU $DA17   ; Bonus niveau
DEF wLevelParam1C   EQU $DA1C   ; Paramètre niveau 1C
DEF wSpecialState   EQU $DA1D   ; Trigger état spécial
DEF wLevelParam1F   EQU $DA1F   ; Paramètre niveau 1F
DEF wLevelParam20   EQU $DA20   ; Paramètre niveau 20
DEF wLevelParam21   EQU $DA21   ; Paramètre niveau 21
DEF wLevelParam22   EQU $DA22   ; Paramètre niveau 22
DEF wLevelParam23   EQU $DA23   ; Paramètre niveau 23
DEF wLevelParam24   EQU $DA24   ; Paramètre niveau 24
DEF wLevelParam25   EQU $DA25   ; Paramètre niveau 25
DEF wLevelParam26   EQU $DA26   ; Paramètre niveau 26
DEF wLevelParam27   EQU $DA27   ; Paramètre niveau 27
DEF wLevelParam28   EQU $DA28   ; Paramètre niveau 28
DEF wLevelParam29   EQU $DA29   ; Paramètre niveau 29

; --- Zone état complexe ($DF00-$DF46) ---
DEF wComplexState   EQU $DF00   ; Début zone état complexe
DEF wComplexState1E EQU $DF1E   ; État complexe 1E
DEF wComplexState46 EQU $DF46   ; Fin zone état complexe

; --- Zone état jeu ($DFE0-$DFF9) ---
DEF wStateBuffer    EQU $DFE0   ; Buffer état jeu (début)
DEF wStateDisplay   EQU $DFE1   ; Mode affichage état
DEF wStateVar2      EQU $DFE2   ; Variable état 2
DEF wStateVar3      EQU $DFE3   ; Variable état 3
DEF wStateGraphics  EQU $DFE4   ; Flags graphiques état
DEF wStateVar5      EQU $DFE5   ; Variable état 5
DEF wStateVar6      EQU $DFE6   ; Variable état 6
DEF wStateVar7      EQU $DFE7   ; Variable état 7
DEF wStateRender    EQU $DFE8   ; Mode rendu état
DEF wStateVar9      EQU $DFE9   ; Variable état 9
DEF wStateVarA      EQU $DFEA   ; Variable état A
DEF wStateVarB      EQU $DFEB   ; Variable état B
DEF wStateVarC      EQU $DFEC   ; Variable état C
DEF wStateVarD      EQU $DFED   ; Variable état D
DEF wStateVarE      EQU $DFEE   ; Variable état E
DEF wStateVarF      EQU $DFEF   ; Variable état F
DEF wStateVar10     EQU $DFF0   ; Variable état 10
DEF wStateVar11     EQU $DFF1   ; Variable état 11
DEF wStateVar12     EQU $DFF2   ; Variable état 12
DEF wStateVar13     EQU $DFF3   ; Variable état 13
DEF wStateVar14     EQU $DFF4   ; Variable état 14
DEF wStateVar15     EQU $DFF5   ; Variable état 15
DEF wStateVar16     EQU $DFF6   ; Variable état 16
DEF wStateVar17     EQU $DFF7   ; Variable état 17
DEF wStateFinal     EQU $DFF8   ; Flag final état
DEF wStateEnd       EQU $DFF9   ; Marqueur fin état

; === Adresses ROM ===

DEF ROM_DMA_ROUTINE EQU $3F7D   ; Source routine DMA en ROM (12 octets)
DEF ROM_INIT_BANK3  EQU $7FF3   ; Routine d'initialisation en bank 3

; --- Tables audio ---
DEF ROM_AUDIO_CONFIG    EQU $336C   ; Configurations son (3 octets/son)

; --- Tables style (par niveau) ---
DEF ROM_STYLE_LVL_0     EQU $030C   ; Niveaux 0-6
DEF ROM_STYLE_LVL_7     EQU $0734   ; Niveaux 7-10
DEF ROM_STYLE_LVL_11    EQU $0B5C   ; Niveaux 11-14
DEF ROM_STYLE_LVL_15    EQU $0F84   ; Niveaux 15-18
DEF ROM_STYLE_LVL_19    EQU $13AC   ; Niveaux 19-22
DEF ROM_STYLE_LVL_23    EQU $17D4   ; Niveaux 23+

; --- Tables animation ---
DEF ROM_ANIM_TILES      EQU $3FAF   ; Frames animation tiles

; --- Données initiales ---
DEF ROM_TILEMAP_INIT    EQU $0783   ; Tilemap initial (9 octets)
DEF ROM_MENU_SPRITES    EQU $0446   ; Sprites menu sélection (10 octets)
DEF ROM_HUD_TILEMAP     EQU $3F87   ; Tilemap HUD (données compressées)

; --- Données graphiques (tiles/tilemaps) ---
DEF ROM_TILES_MAIN      EQU $791A   ; Tiles principaux ($0500 octets)
DEF ROM_TILES_AUX       EQU $7E1A   ; Tiles auxiliaires ($0170 octets)
DEF ROM_TILES_LEVEL_1   EQU $4862   ; Tiles niveau type 1 ($0010 octets)
DEF ROM_TILES_LEVEL_2   EQU $4E72   ; Tiles niveau type 2 ($0010 octets)
DEF ROM_TILES_OBJECTS   EQU $5032   ; Tiles objets ($02C0 octets)

; --- Tailles de copies mémoire ---
DEF SIZE_TILES_MAIN     EQU $0500   ; 1280 octets
DEF SIZE_TILES_AUX      EQU $0170   ; 368 octets
DEF SIZE_TILES_LEVEL    EQU $0010   ; 16 octets
DEF SIZE_TILES_OBJECTS  EQU $02C0   ; 704 octets
DEF SIZE_TILES_SPRITES  EQU $02A0   ; 672 octets
DEF SIZE_MENU_SPRITES   EQU $0A    ; 10 octets
DEF SIZE_GAME_TILES_A   EQU $0800   ; 2048 octets (tiles de jeu part A)
DEF SIZE_GAME_TILES_B   EQU $1000   ; 4096 octets (tiles de jeu part B)

; --- Données graphiques (tiles de jeu) ---
DEF ROM_GAME_TILES_A    EQU $5032   ; Tiles de jeu partie A
DEF ROM_GAME_TILES_B    EQU $4032   ; Tiles de jeu partie B
DEF ROM_ANIM_BUFFER     EQU $5603   ; Buffer animation (8 octets)

; --- Données objets ---
DEF ROM_OBJECT_INIT_DATA EQU $2164  ; Table init objets (vitesses/priorités)

; === Adresses VRAM ===
; --- Destinations copie tiles ---
DEF VRAM_TILES_MAIN     EQU $9300   ; Destination tiles principaux
DEF VRAM_TILES_AUX      EQU $8800   ; Destination tiles auxiliaires
DEF VRAM_TILES_LEVEL    EQU $8AC0   ; Destination tiles niveau
DEF VRAM_TILES_OBJECTS  EQU $9000   ; Destination tiles objets
DEF VRAM_TILES_SPRITES  EQU $8000   ; Destination tiles sprites

; --- Tilemap BG ---
DEF VRAM_BG_BASE        EQU $9800   ; Base tilemap BG (_SCRN0)
DEF VRAM_HUD_MARIO      EQU $9804   ; Position "MARIO" HUD
DEF VRAM_HUD_COINS      EQU $9822   ; Position icône pièces HUD
DEF VRAM_HUD_WORLD      EQU $982F   ; Position "WORLD" HUD
DEF VRAM_MENU_DEST      EQU $99C6   ; Destination sprites menu
DEF VRAM_HIGHSCORE      EQU $9969   ; Position high score

; --- HUD et score ---
DEF VRAM_SCORE_POS1     EQU $9806   ; Score HUD position 1
DEF VRAM_HUD_LINE       EQU $9820   ; Ligne HUD
DEF VRAM_COIN_TENS      EQU $9829   ; Compteur pièces HUD (dizaines)
DEF VRAM_COIN_UNITS     EQU $982A   ; Compteur pièces HUD (unités)
DEF VRAM_WORLD_NUMBER   EQU $982B   ; Numéro monde HUD (après pièces)
DEF VRAM_ANIM_DEST      EQU $95D1   ; Destination tiles animation

; === Tiles spéciaux ===

DEF TILE_EMPTY          EQU $2C   ; Tile vide/espace (fond, leading zero)

; --- Tiles HUD ---
DEF TILE_HUD_BORDER     EQU $3C   ; Bordure HUD (barre horizontale)
DEF TILE_HUD_MARIO_M    EQU $94   ; Lettre "M" de MARIO
DEF TILE_HUD_MARIO_A    EQU $95   ; Lettre "A" de MARIO (aussi première)
DEF TILE_HUD_MARIO_R    EQU $96   ; Lettre "R" de MARIO
DEF TILE_HUD_MARIO_I    EQU $8C   ; Lettre "I" de MARIO (aussi icône)
DEF TILE_HUD_WORLD_W    EQU $3F   ; Lettre "W" de WORLD
DEF TILE_HUD_WORLD_O    EQU $4C   ; Lettre "O" de WORLD
DEF TILE_HUD_WORLD_R    EQU $4D   ; Lettre "R" de WORLD

; === Valeurs de gameplay ===

DEF POINTS_PER_COIN     EQU $0100 ; Points par pièce (100 en BCD)

; Bornes de position X joueur (vérification zone centrale)
DEF PLAYER_X_LEFT       EQU $60   ; Position X limite gauche zone centrale (96px)
DEF PLAYER_X_RIGHT      EQU $A0   ; Position X limite droite zone centrale (160px)

; Direction joueur
DEF PLAYER_DIR_LEFT     EQU $18   ; Direction gauche

; === Valeurs d'initialisation ===

DEF INIT_GAME_STATE     EQU $0E ; État jeu initial (hGameState)
DEF GAME_STATE_TITLE    EQU $00 ; Écran titre (attente Start / timeout)
DEF GAME_STATE_DEMO     EQU $0E ; Lancement démo automatique (Attract Mode)
DEF GAME_STATE_WINDOW   EQU $3A ; État spécial window (animation écran)
DEF INIT_ANIM_TILE_IDX  EQU $11 ; Valeur initiale hAnimTileIndex et wAnimTileIdx
DEF INIT_UNKNOWN_DC     EQU $02 ; Valeur initiale wCurrentROMBank (et bank switch)
DEF INIT_UNKNOWN_A4     EQU $03 ; Valeur initiale wROMBankInit (et bank switch)

; === Marqueurs de slots ===

DEF SLOT_EMPTY          EQU $FF ; Marqueur slot vide/inactif dans les tables

; === États de jeu (hGameState) ===

; États de transition initialisation (post-reset)
DEF GAME_STATE_RESET        EQU $01 ; Post-timer reset (après game over)
DEF GAME_STATE_PREPARE_RENDER EQU $02 ; Préparation rendu (LCD off, clear)
DEF GAME_STATE_SETUP_TRANSITION EQU $03 ; Setup sprites transition
DEF GAME_STATE_ANIMATION    EQU $04 ; Animation transition en cours
DEF GAME_STATE_SPECIAL_LEVEL EQU $05 ; Gestion niveau spécial
DEF GAME_STATE_POST_LEVEL   EQU $06 ; Transition post-niveau
DEF GAME_STATE_WAIT_PROCESS EQU $07 ; Attente + traitement bank 3

; États gameplay
DEF GAME_STATE_CENTER   EQU $08 ; État transition - joueur au centre
DEF GAME_STATE_GAMEPLAY EQU $0D ; État gameplay actif (jeu en cours)

; États tuyaux (pipe navigation)
DEF GAME_STATE_PIPE_ENTER_RIGHT EQU $09 ; Entrée tuyau par la droite
DEF GAME_STATE_PIPE_LOAD    EQU $0A ; Chargement sous-niveau (après pipe)
DEF GAME_STATE_PIPE_DOWN    EQU $0B ; Descente dans tuyau vertical
DEF GAME_STATE_PIPE_EXIT    EQU $0C ; Sortie tuyau vers la gauche

DEF GAME_STATE_LEVEL_SELECT EQU $0F ; État sélection niveau (State0F)
DEF GAME_STATE_LEVEL_START  EQU $11 ; État démarrage niveau (State11)
DEF GAME_STATE_OUTER    EQU $12 ; État transition - joueur en périphérie

; États écran bonus/fin
DEF GAME_STATE_DRAW_BORDER  EQU $13 ; Dessin bordure écran fin
DEF GAME_STATE_BONUS_SELECT EQU $14 ; Sélection bonus (post-bordure)
DEF GAME_STATE_BONUS_COPY   EQU $15 ; Copie données tilemap bonus

DEF GAME_STATE_SPECIAL  EQU $1C ; État niveau spécial
DEF GAME_STATE_INIT27   EQU $27 ; État initialisation spéciale

; États game over
DEF GAME_STATE_GAME_OVER    EQU $39 ; Écran GAME OVER

; === Conversion BCD ===

DEF BCD_TO_ASCII        EQU $30 ; Offset pour convertir BCD → caractère ASCII ('0')
DEF BCD_MAX_DIGIT       EQU $99 ; Valeur max d'un octet BCD (99)

; === Configuration LCD ===

; LCDC standard du jeu : LCD ON + WIN 9C00 + OBJ ON + BG ON
; $C3 = %11000011 = LCDCF_ON | LCDCF_WIN9C00 | LCDCF_OBJON | LCDCF_BGON
DEF LCDC_GAME_STANDARD  EQU $C3

; Lignes LCD pour les effets scanline
DEF LYC_TOP_SCREEN      EQU $0F ; Ligne 15, haut écran (après HUD)
DEF WY_WINDOW_DONE      EQU $40 ; Position finale window (ligne 64)
DEF LY_WINDOW_MAX       EQU $87 ; Ligne max pour animation window (135)

; === Dimensions tilemap ===

DEF TILEMAP_ROW_WIDTH   EQU $14 ; 20 tiles = largeur écran visible (160px / 8px)
DEF TILEMAP_INIT_SIZE   EQU $09 ; Taille données init tilemap (9 octets)

; === Audio/Sound ===

DEF MAX_AUDIO_SLOTS     EQU $14 ; 20 slots audio maximum
DEF AUDIO_SLOT_SIZE     EQU $0D ; 13 octets par slot audio

; === Tailles OAM ===

DEF OAM_BUFFER_SIZE     EQU $9F ; 159 octets (40 sprites × 4 - 1)

; === Joypad ===

; Masque pour isoler les directions D-pad (bits 0-3 de hJoypadState)
DEF JOYPAD_DPAD_MASK    EQU $0F ; Masque 4 bits bas (R/L/U/D)
; Valeur quand toutes les directions sont pressées (combo soft reset)
DEF JOYPAD_ALL_DPAD     EQU $0F ; R+L+U+D simultanés

; === Attract Mode / Menu ===

DEF ATTRACT_MODE_TIMEOUT EQU $28 ; Timer attract mode (40 frames)
DEF ATTRACT_MODE_LONG    EQU $50 ; Timer attract mode long (80 frames)

; === Positions sprites menu sélection niveau ===

DEF SPRITE_Y_MENU       EQU $78 ; Position Y sprites menu (120 pixels)
DEF SPRITE_X_LEFT       EQU $78 ; Position X gauche (120 pixels)
DEF SPRITE_X_CENTER     EQU $80 ; Position X centre (128 pixels)
DEF SPRITE_X_RIGHT      EQU $88 ; Position X droite (136 pixels)
DEF TILE_LEVEL_SELECT   EQU $29 ; Tile indicateur sélection niveau

; === DMA ===

DEF DMA_WAIT_CYCLES     EQU $28 ; Cycles d'attente DMA (40 cycles)

; === Types d'objets OAM ===
; Utilisés dans UpdateAnimatedObjectState_ObjectHitDispatch pour identifier
; le type d'objet avec lequel le joueur interagit

DEF OBJ_TYPE_COIN       EQU $29 ; Pièce à collecter
DEF OBJ_TYPE_SPECIAL    EQU $2B ; Objet spécial (transition)
DEF OBJ_TYPE_DOOR       EQU $2E ; Porte/portail (transition zone)
DEF OBJ_TYPE_ENEMY      EQU $34 ; Ennemi

; === Indices de tiles animation (Monde.Niveau) ===
; Format: $XY où X = monde (1-4), Y = niveau dans le monde (1-3)
; Utilisés pour sélectionner le contexte de rendu selon le niveau

DEF ANIM_TILE_W1_L1     EQU $11 ; Monde 1, Niveau 1
DEF ANIM_TILE_W1_L2     EQU $12 ; Monde 1, Niveau 2
DEF ANIM_TILE_W1_L3     EQU $13 ; Monde 1, Niveau 3
DEF ANIM_TILE_W2_L1     EQU $21 ; Monde 2, Niveau 1
DEF ANIM_TILE_W2_L2     EQU $22 ; Monde 2, Niveau 2
DEF ANIM_TILE_W2_L3     EQU $23 ; Monde 2, Niveau 3
DEF ANIM_TILE_W3_L1     EQU $31 ; Monde 3, Niveau 1
DEF ANIM_TILE_W3_L2     EQU $32 ; Monde 3, Niveau 2
DEF ANIM_TILE_W3_L3     EQU $33 ; Monde 3, Niveau 3
DEF ANIM_TILE_W4_L1     EQU $41 ; Monde 4, Niveau 1
DEF ANIM_TILE_W4_L2     EQU $42 ; Monde 4, Niveau 2

; === Commandes/tokens tilemap ===
; Valeurs spéciales dans les données tilemap qui déclenchent des comportements

DEF TILEMAP_CMD_SKIP    EQU $FD ; Marqueur skip/continuation (pas de copie tile)
DEF TILEMAP_CMD_SCROLL  EQU $70 ; Déclenche mise à jour scrolling
DEF TILEMAP_CMD_LOAD1   EQU $80 ; Charge tilemap niveau (type 1)
DEF TILEMAP_CMD_LOAD2   EQU $5F ; Charge tilemap niveau (type 2)
DEF TILEMAP_CMD_LOAD3   EQU $81 ; Charge tilemap niveau (type 3)

; === Seuils de groupes de niveaux ===
; Utilisés pour sélectionner la table de style selon le numéro de niveau
; Les niveaux sont groupés : 0-6, 7-10, 11-14, 15-18, 19-22, 23+

DEF LEVEL_GROUP_7_START  EQU $07 ; Premier niveau du groupe 2 (niveaux 7-10)
DEF LEVEL_GROUP_11_START EQU $0B ; Premier niveau du groupe 3 (niveaux 11-14)
DEF LEVEL_GROUP_15_START EQU $0F ; Premier niveau du groupe 4 (niveaux 15-18)
DEF LEVEL_GROUP_19_START EQU $13 ; Premier niveau du groupe 5 (niveaux 19-22)
DEF LEVEL_GROUP_23_START EQU $17 ; Premier niveau du groupe 6 (niveaux 23+)

; === Indices OAM pour collision ===
; Utilisés dans UpdateAnimatedObjectState pour identifier les objets par leur index OAM

DEF OAM_ADDR_LOW_PLAYER  EQU $90 ; Adresse basse OAM joueur (hOAMAddrLow)
DEF OAM_INDEX_COIN       EQU $33 ; Index OAM pièce (hOAMIndex = 51)

; === Contextes de rendu ===
; Utilisés pour déterminer le mode de rendu graphique selon l'état du jeu

DEF RENDER_CONTEXT_GAMEPLAY EQU $05 ; Contexte gameplay standard
DEF RENDER_CONTEXT_SPECIAL  EQU $0B ; Contexte niveau spécial
DEF RENDER_CONTEXT_MAX      EQU $0C ; Valeur max contexte (wrap-around)

; === Score BCD ===

DEF SCORE_BCD_SIZE          EQU $03 ; Taille du score en BCD (3 octets = 6 chiffres)

; === ROM Banks ===

DEF ROM_BANK_COUNT          EQU $03 ; Nombre de banks switchables (1-3, bank 0 fixe)

; === Seuils de niveaux ===

DEF LEVEL_THRESHOLD_SPRITES EQU $02 ; Seuil niveau pour affichage sprites menu

; === OAM Sprites écran titre/menu ===
; Positions des sprites dans le buffer OAM pour l'écran titre

DEF OAM_TITLE_SPRITE_Y      EQU $80 ; Position Y sprite titre (128 pixels)
DEF OAM_TITLE_SPRITE_X      EQU $88 ; Position X sprite titre (136 pixels)
DEF OAM_TITLE_SPRITE2_Y     EQU $80 ; Position Y second sprite titre
DEF OAM_TITLE_SPRITE2_X     EQU $28 ; Position X second sprite titre (40 pixels)
DEF OAM_TITLE_TILE          EQU $ac ; Tile sprite écran titre

; === Masques et toggles ===

DEF TOGGLE_SPRITE_Y_MASK    EQU $f8 ; Masque XOR pour toggle position Y sprite

; === Types de collision bloc (hBlockHitType) ===
; Valeurs spéciales utilisées pour les interactions joueur/blocs

DEF BLOCK_HIT_NONE          EQU $00 ; Pas de collision
DEF BLOCK_HIT_TYPE_SPECIAL  EQU $c0 ; Type spécial (annule l'animation objet)

; === Window/LCD positions ===

DEF WY_INIT_GAME            EQU $85 ; Position Window Y initiale gameplay (133)
DEF WX_INIT_GAME            EQU $60 ; Position Window X initiale gameplay (96)

; === Scroll/Tilemap initiaux ===

DEF SCROLL_COLUMN_INIT      EQU $5b ; Colonne scroll initiale (91)
DEF SCRN1_CLEAR_SIZE        EQU $5f ; Taille clear _SCRN1 (95 octets)

; === Tables ROM (adresses lookup) ===

DEF ROM_ATTRACT_INDEX_TABLE EQU $0552 ; Table index attract mode par bank
