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

DEF _ROMX           EQU $4000   ; Début ROM switchable ($4000-$7FFF, 16KB)
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
DEF DMA_SOURCE_HIGH  EQU $C0    ; Octet haut adresse source OAM ($C000)

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
DEF AUDIO_BUFFER_FILL_VALUE EQU $b4 ; Valeur remplissage buffer audio
DEF AUDIO_PARAM2_DEFAULT    EQU $70 ; Paramètre audio 2 par défaut

; === ROM Banks ===

DEF BANK_0          EQU $00     ; Bank 0 = bank fixe (vecteurs, init, main)
DEF BANK_1          EQU $01     ; Bank 1 = données monde 2/4
DEF BANK_2          EQU $02     ; Bank 2 = données monde 1
DEF BANK_3          EQU $03     ; Bank 3 = données monde 3
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
DEF hPauseFlag      EQU $FFB2   ; Flag pause (0=normal, 1=pause)

; --- Buffer animation (7 octets copiés depuis données anim) ---
DEF hAnimBuffer     EQU $FF86   ; Début buffer animation (7 bytes)
DEF hAnimOffsetX    EQU $FF87   ; Offset X animation (signé)
DEF hAnimOffsetY    EQU $FF88   ; Offset Y animation (signé)
DEF hAnimFrameIndex EQU $FF89   ; Index frame animation courante
DEF hAnimFlags2     EQU $FF8A   ; Flags attributs supplémentaires
DEF hAnimFlipFlags  EQU $FF8B   ; Flags flip (bit 5=Y, bit 6=X)
DEF hAnimBaseAttr   EQU $FF8C   ; Attributs de base sprite

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
DEF SCROLL_PHASE_INACTIVE EQU $00  ; Scroll inactif
DEF SCROLL_PHASE_ACTIVE   EQU $01  ; Scroll en cours de mise à jour
DEF SCROLL_PHASE_DONE     EQU $02  ; Scroll terminé
DEF SCROLL_PHASE_RESET    EQU $03  ; Reset scroll phase (ResetScrollPhase)

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
DEF SPRITE_BUFFER_END_LOW EQU $a0 ; Octet bas fin buffer sprite ($C0A0)
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
DEF wScrollBuffer       EQU $C0B0   ; Buffer colonne tilemap (16 octets)
DEF SCROLL_BUFFER_SIZE  EQU $10     ; Taille buffer scroll (16 octets)
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
DEF wPlayerUnk06    EQU $C206   ; Variable joueur 06
DEF wPlayerUnk07    EQU $C207   ; Variable joueur
DEF wPlayerUnk08    EQU $C208   ; Variable joueur 08
DEF wPlayerUnk09    EQU $C209   ; Variable joueur 09
DEF wPlayerUnk0A    EQU $C20A   ; Variable joueur 0A
DEF wPlayerUnk0B    EQU $C20B   ; Variable joueur
DEF wPlayerUnk0C    EQU $C20C   ; Variable joueur
DEF wPlayerUnk0D    EQU $C20D   ; Variable joueur 0D
DEF wPlayerUnk0E    EQU $C20E   ; Variable joueur
DEF wPlayerUnk0F    EQU $C20F   ; Variable joueur 0F
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
DEF wObject2Unk08   EQU $C220   ; Variable objet 2 (offset +$08)
DEF wObject2State   EQU $C222   ; État objet 2 (offset +$0A)
DEF wObject3        EQU $C228   ; Slot objet 3
DEF wObject3Unk08   EQU $C230   ; Variable objet 3 (offset +$08)
DEF wObject4        EQU $C238   ; Slot objet 4
DEF wObject4Unk08   EQU $C240   ; Variable objet 4 (offset +$08)
DEF wObject4Unk09   EQU $C241   ; Variable objet 4 (offset +$09)
DEF wObject4Unk0A   EQU $C242   ; Variable objet 4 (offset +$0A)
DEF wObject5        EQU $C248   ; Slot objet 5

; --- Buffer enregistrement démo ($C300) ---
DEF wDemoRecordBuffer EQU $C300   ; Buffer enregistrement inputs démo

; --- Buffer animation ---
DEF wAnimBuffer     EQU $C600   ; Buffer animation

; --- Buffer tilemap ($C800-$CA3F) ---
DEF wTilemapBuffer      EQU $C800   ; Début buffer tilemap
DEF wTilemapBufferEnd   EQU $CA3F   ; Fin buffer tilemap (576 octets)
DEF TILEMAP_BUFFER_SIZE EQU $0240   ; Taille buffer tilemap (576 octets)

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
DEF OBJECT_BUFFER_END_LOW EQU $a0 ; Octet bas fin buffer ($D1A0 = $D100 + 10×16)
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
DEF wLevelParam16   EQU $DA16   ; Paramètre niveau 16
DEF wLevelBonus     EQU $DA17   ; Bonus niveau
DEF wLevelParam18   EQU $DA18   ; Paramètre niveau 18
DEF wLevelParam19   EQU $DA19   ; Paramètre niveau 19
DEF wLevelParam1A   EQU $DA1A   ; Paramètre niveau 1A
DEF wLevelParam1B   EQU $DA1B   ; Paramètre niveau 1B
DEF wLevelParam1C   EQU $DA1C   ; Paramètre niveau 1C
DEF wSpecialState   EQU $DA1D   ; Trigger état spécial
DEF wLevelParam1E   EQU $DA1E   ; Paramètre niveau 1E
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

; --- Zone état complexe ($DF00-$DF4F) ---
DEF wComplexState   EQU $DF00   ; Début zone état complexe
DEF wComplexState1E EQU $DF1E   ; État complexe 1E
DEF wComplexState1F EQU $DF1F   ; État complexe 1F
DEF wComplexState2E EQU $DF2E   ; État complexe 2E
DEF wComplexState2F EQU $DF2F   ; État complexe 2F
DEF wComplexState38 EQU $DF38   ; État complexe 38
DEF wComplexState3E EQU $DF3E   ; État complexe 3E
DEF wComplexState3F EQU $DF3F   ; État complexe 3F
DEF wComplexState46 EQU $DF46   ; Fin zone état complexe
DEF wComplexState4F EQU $DF4F   ; État complexe 4F

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
DEF ROM_AUDIO_POINTERS  EQU $3495   ; Pointeurs vers données audio (2 octets/son)
DEF ROM_AUDIO_INDEX_TABLE EQU $401a ; Table index audio en bank 1 (2 octets/entrée)
DEF ROM_AUDIO_CHANNEL_TABLE_1 EQU $2fd9 ; Table sélection canal audio (option 1)
DEF ROM_AUDIO_CHANNEL_TABLE_2 EQU $30ab ; Table sélection canal audio (option 2)

; --- Tables tilemap (bank 3) ---
DEF ROM_TILEMAP_POINTERS_A EQU $651C ; Table pointeurs tilemap A (bank 3)
DEF ROM_TILEMAP_POINTERS_B EQU $6536 ; Table pointeurs tilemap B (bank 3)

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
DEF ROM_CREDITS_TEXT    EQU $154E   ; Texte des crédits

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
DEF VRAM_WORLD_OVERFLOW EQU $7230   ; Offset overflow check ($8A00 + $7230 = $FC30, overflow à $10000)
DEF WORLD_ANIM_OFFSET   EQU $02C1   ; Offset vers buffer animation dans données monde

; --- Données graphiques (tiles de jeu) ---
DEF ROM_GAME_TILES_A    EQU $5032   ; Tiles de jeu partie A
DEF ROM_GAME_TILES_B    EQU $4032   ; Tiles de jeu partie B
DEF ROM_ANIM_BUFFER     EQU $5603   ; Buffer animation (8 octets)

; --- Palettes mondes ---
DEF ROM_WORLD1_PALETTE  EQU $4402   ; Palette monde 1 (et 2)
DEF ROM_WORLD3_PALETTE  EQU $4BC2   ; Palette monde 3

; --- Données objets ---
DEF ROM_OBJECT_INIT_DATA EQU $2164  ; Table init objets (vitesses/priorités)

; === Adresses VRAM ===
; --- Destinations copie tiles ---
DEF VRAM_TILES_MAIN     EQU $9300   ; Destination tiles principaux
DEF VRAM_TILES_AUX      EQU $8800   ; Destination tiles auxiliaires
DEF VRAM_TILES_LEVEL    EQU $8AC0   ; Destination tiles niveau
DEF VRAM_TILES_OBJECTS  EQU $9000   ; Destination tiles objets
DEF VRAM_TILES_SPRITES  EQU $8000   ; Destination tiles sprites
DEF VRAM_WORLD_TILES    EQU $8A00   ; Destination tiles monde (State08_WorldProgress)
DEF VRAM_WORLD_PALETTE  EQU $9310   ; Destination palette monde (State08_WorldProgress)

; --- Tilemap BG ---
DEF VRAM_BG_BASE        EQU $9800   ; Base tilemap BG (_SCRN0)
DEF VRAM_HUD_MARIO      EQU $9804   ; Position "MARIO" HUD
DEF VRAM_HUD_COINS      EQU $9822   ; Position icône pièces HUD
DEF VRAM_HUD_WORLD      EQU $982F   ; Position "WORLD" HUD
DEF VRAM_MENU_DEST      EQU $99C6   ; Destination sprites menu
DEF VRAM_HIGHSCORE      EQU $9969   ; Position high score

; --- HUD et score ---
DEF VRAM_SCORE_POS1     EQU $9806   ; Score HUD position 1
DEF VRAM_SCORE_POS2     EQU $9807   ; Score HUD position 2 (vies unités)
DEF VRAM_HUD_LINE       EQU $9820   ; Ligne HUD
DEF VRAM_COIN_TENS      EQU $9829   ; Compteur pièces HUD (dizaines)
DEF VRAM_COIN_UNITS     EQU $982A   ; Compteur pièces HUD (unités)
DEF VRAM_WORLD_NUMBER   EQU $982B   ; Numéro monde HUD (après pièces)
DEF VRAM_LEVEL_BCD      EQU $9833   ; Affichage niveau BCD (3 chiffres)
DEF VRAM_LIVES_DISPLAY  EQU $988B   ; Affichage compteur vies HUD
DEF VRAM_ANIM_DEST      EQU $95D1   ; Destination tiles animation
DEF VRAM_FADE_START     EQU $8DD0   ; Début zone VRAM pour effet fade
DEF VRAM_FADE_SIZE      EQU $0220   ; Taille zone fade (544 octets)
DEF VRAM_FADE_WRAP      EQU $9690   ; Adresse après wrap zone fade
DEF VRAM_FADE_BOUND_HI  EQU $8F     ; Octet haut limite zone fade

; --- VRAM Crédits ---
DEF VRAM_CREDITS_ROW1       EQU $9a42   ; Tilemap ligne 1 crédits
DEF VRAM_CREDITS_ROW2       EQU $9a87   ; Tilemap ligne 2 crédits
DEF VRAM_CREDITS_LIMIT1     EQU $54     ; Limite colonne VRAM (fin ligne 1)
DEF VRAM_CREDITS_LIMIT2     EQU $93     ; Limite colonne VRAM (fin ligne 2)

; --- VRAM Écran fin (State13_DrawEndBorder) ---
DEF VRAM_BORDER_BOTTOM_ROW  EQU $9a20   ; Ligne bas bordure écran fin
DEF VRAM_END_TEXT_ROW1      EQU $9845   ; Ligne texte 1 écran fin (PUSH GAME)
DEF VRAM_END_TEXT_ROW2      EQU $9887   ; Ligne texte 2 écran fin
DEF VRAM_END_COPY_START     EQU $98d2   ; Début copie données écran fin
DEF VRAM_END_COPY_END_LOW   EQU $52     ; Octet bas adresse fin boucle copie
DEF VRAM_END_COPY_STRIDE    EQU $0060   ; Stride copie (3 lignes = 96 octets)

; === Tiles spéciaux ===

DEF TILE_EMPTY          EQU $2C   ; Tile vide/espace (fond, leading zero)
DEF TILE_DIGIT_0        EQU $00   ; Tile chiffre "0" (index 0 dans tileset)

; --- Tiles HUD ---
DEF TILE_HUD_BORDER     EQU $3C   ; Bordure HUD (barre horizontale)
DEF TILE_HUD_MARIO_M    EQU $94   ; Lettre "M" de MARIO
DEF TILE_HUD_MARIO_A    EQU $95   ; Lettre "A" de MARIO (aussi première)
DEF TILE_HUD_MARIO_R    EQU $96   ; Lettre "R" de MARIO
DEF TILE_HUD_MARIO_I    EQU $8C   ; Lettre "I" de MARIO (aussi icône)
DEF TILE_HUD_WORLD_W    EQU $3F   ; Lettre "W" de WORLD
DEF TILE_HUD_WORLD_O    EQU $4C   ; Lettre "O" de WORLD
DEF TILE_HUD_WORLD_R    EQU $4D   ; Lettre "R" de WORLD

; --- Tiles écran texte/bordure ---
DEF TILE_TEXT_CORNER    EQU $2B   ; Coin de bordure texte (angle)
DEF TILE_TEXT_FILL      EQU $2D   ; Remplissage bordure texte (ligne)
DEF TEXT_LINE_WIDTH     EQU $12   ; Largeur ligne texte (18 tiles)

; --- Tiles bordure écran fin (State13_DrawEndBorder) ---
DEF TILE_BORDER_TOP_LEFT     EQU $f5   ; Coin supérieur gauche bordure
DEF TILE_BORDER_HORIZONTAL   EQU $9f   ; Bordure horizontale
DEF TILE_BORDER_TOP_RIGHT    EQU $fc   ; Coin supérieur droit bordure
DEF TILE_BORDER_VERTICAL     EQU $f8   ; Bordure verticale
DEF TILE_BORDER_BOTTOM_LEFT  EQU $ff   ; Coin inférieur gauche bordure
DEF TILE_BORDER_BOTTOM_RIGHT EQU $e9   ; Coin inférieur droit bordure
DEF TILE_CREDITS_SPECIAL     EQU $e4   ; Tile spécial ligne crédits

; --- Dimensions bordure écran fin ---
DEF BORDER_COLUMN_HEIGHT     EQU $10   ; Hauteur colonne bordure (16 tiles)
DEF BORDER_COLUMN_COUNT      EQU $02   ; Nombre de colonnes bordure (2)

; --- Animation structures ---
DEF ANIM_STRUCT_STRIDE  EQU $10   ; Taille structure animation (16 octets)

; === Valeurs de gameplay ===

DEF POINTS_PER_COIN     EQU $0100 ; Points par pièce (100 en BCD)
DEF SCORE_BONUS_10      EQU $0010 ; Bonus 10 points (score)
DEF SCORE_BONUS_50      EQU $0050 ; Bonus 50 points (score)

; Collision et scroll
DEF COLLISION_THRESHOLD EQU $07   ; Seuil collision pour scroll (7)

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

; === Marqueurs système ===

DEF UPDATE_DECREMENT    EQU $FF ; Marqueur décrémentation (wUpdateCounter)

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

; États crédits/fin de jeu ($30-$38)
DEF GAME_STATE_WALK_LEFT        EQU $30 ; Marche vers la gauche
DEF GAME_STATE_H_SCROLL         EQU $31 ; Scroll horizontal
DEF GAME_STATE_CREDITS_SCROLL   EQU $32 ; Scroll crédits
DEF GAME_STATE_CREDITS_TEXT     EQU $33 ; Affichage texte crédits
DEF GAME_STATE_CREDITS_WAIT     EQU $34 ; Attente compteur crédits
DEF GAME_STATE_WAIT_TIMER       EQU $35 ; Attente timer
DEF GAME_STATE_CREDITS_FINAL    EQU $36 ; Transition finale crédits
DEF GAME_STATE_SPRITE_FINAL     EQU $37 ; Animation sprite finale
DEF GAME_STATE_CREDITS_ANIM     EQU $38 ; Animation crédits

; États game over
DEF GAME_STATE_GAME_OVER    EQU $39 ; Écran GAME OVER

; === Conversion BCD ===

DEF BCD_TO_ASCII        EQU $30 ; Offset pour convertir BCD → caractère ASCII ('0')
DEF BCD_MAX_DIGIT       EQU $99 ; Valeur max d'un octet BCD (99)

; === Configuration LCD ===

; LCDC standard du jeu : LCD ON + WIN 9C00 + OBJ ON + BG ON
; $C3 = %11000011 = LCDCF_ON | LCDCF_WIN9C00 | LCDCF_OBJON | LCDCF_BGON
DEF LCDC_GAME_STANDARD  EQU $C3

; LCDC écran fin niveau : LCD ON + OBJ ON + BG ON (sans window)
; $83 = %10000011 = LCDCF_ON | LCDCF_OBJON | LCDCF_BGON
DEF LCDC_END_SCREEN     EQU $83

; Lignes LCD pour les effets scanline
DEF LYC_TOP_SCREEN      EQU $0F ; Ligne 15, haut écran (après HUD)
DEF LYC_CREDITS_LINE    EQU $60 ; Ligne 96, interruption LYC pour crédits
DEF WY_WINDOW_DONE      EQU $40 ; Position finale window (ligne 64)
DEF LY_WINDOW_MAX       EQU $87 ; Ligne max pour animation window (135)
DEF LYC_SCANLINE_STRIDE EQU $08 ; Stride scanline (8 lignes = 1 tile)

; === Dimensions tilemap ===

DEF TILE_SIZE_PIXELS    EQU $08 ; 8 pixels = 1 tile (dimensions standard Game Boy)
DEF TILE_ALIGN_MASK     EQU $f8 ; Masque alignement tile (efface bits 0-2)
DEF TILEMAP_ROW_WIDTH   EQU $14 ; 20 tiles = largeur écran visible (160px / 8px)
DEF TILEMAP_STRIDE      EQU $20 ; 32 tiles = largeur complète tilemap (256px / 8px)
DEF TILEMAP_COLUMN_MASK EQU $1f ; Masque colonnes tilemap (TILEMAP_STRIDE - 1)
DEF TILEMAP_INIT_SIZE   EQU $09 ; Taille données init tilemap (9 octets)
DEF HUD_LINE_COUNT      EQU $02 ; Nombre de lignes HUD à copier
DEF SCRN_SIZE           EQU $0400 ; 1024 octets = taille tilemap complète (32×32 tiles)
DEF SCRN_SIZE_MINUS_1   EQU $03FF ; SCRN_SIZE - 1 (pour adressage depuis fin)
DEF TILEMAP_FILL_LOOPS  EQU $03   ; Nombre de boucles pour remplir tilemap (3 × 255 = 765 tiles)

; === Audio/Sound ===

DEF MAX_AUDIO_SLOTS     EQU $14 ; 20 slots audio maximum
DEF AUDIO_SLOT_SIZE     EQU $0D ; 13 octets par slot audio

; === Tailles OAM ===

DEF OAM_BUFFER_SIZE     EQU $9F ; 159 octets (40 sprites × 4 - 1)
DEF OAM_BUFFER_FULL     EQU $A0 ; 160 octets (40 sprites × 4, taille complète)

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

DEF LEVEL_INDEX_SPECIAL EQU $03 ; Niveau 3 (nibble bas) = niveau spécial/boss
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
DEF TILEMAP_CMD_WATER   EQU $82 ; Tile eau (collision spéciale)
DEF TILEMAP_CMD_PIPE    EQU $F4 ; Tile tuyau/pipe (entrée zone spéciale)
DEF TILEMAP_CMD_E1      EQU $E1 ; Tile collision spéciale E1 (transition/warp)
DEF TILEMAP_CMD_DANGER  EQU $ED ; Tile danger (collision fatale si vulnérable)
DEF TILEMAP_CMD_SLIDE   EQU $77 ; Tile glissade/slide (collision spéciale)
DEF TILEMAP_CMD_BOUNCE  EQU $F2 ; Tile rebond/bloc collision (son + effet)
DEF TILEMAP_CMD_END     EQU $FE ; Marqueur fin de section tilemap

; Seuil pour distinguer les tiles commandes (>= $60) des tiles normaux (< $60)
DEF TILEMAP_CMD_THRESHOLD EQU $60 ; Seuil: >= $60 = tile spécial/commande

; === Offsets collision joueur ===
; Utilisés pour les calculs de collision tête du joueur

DEF HEAD_COLLISION_OFFSET_Y  EQU $0B ; Offset Y tête joueur (11 pixels vers haut)
DEF HEAD_COLLISION_ADJUST_X  EQU $FE ; Ajustement X hitbox (-2 en complément à 2)

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
DEF BLOCK_HIT_SOFT          EQU $01 ; Bloc cassable (soft block)
DEF BLOCK_HIT_COIN          EQU $02 ; Bloc pièce (coin block)
DEF BLOCK_HIT_ITEM          EQU $04 ; Bloc item (mushroom/flower)
DEF BLOCK_HIT_TYPE_SPECIAL  EQU $c0 ; Type spécial (annule l'animation objet)

; === Window/LCD positions ===

DEF WY_INIT_GAME            EQU $85 ; Position Window Y initiale gameplay (133)
DEF WX_INIT_GAME            EQU $60 ; Position Window X initiale gameplay (96)
DEF WY_GAME_OVER            EQU $8F ; Position Window Y écran Game Over (143)
DEF WX_GAME_OVER            EQU $07 ; Position Window X écran Game Over (7)

; === Scroll/Tilemap initiaux ===

DEF SCROLL_COLUMN_INIT      EQU $5b ; Colonne scroll initiale (91)
DEF SCRN1_CLEAR_SIZE        EQU $5f ; Taille clear _SCRN1 (95 octets)
DEF LEVEL_DATA_INIT         EQU $28 ; Valeur initiale wLevelData (timer niveau)
DEF LEVEL_BCD2_INIT         EQU $04 ; Valeur initiale wLevelBCD2

; === Tables ROM (adresses lookup) ===
; (Utiliser directement les labels des tables au lieu de constantes EQU)

; === Directions joueur (wPlayerDir) ===
; Bits bas utilisés pour le mode gameplay

DEF PLAYER_MODE_GAMEPLAY    EQU $0a ; Mode gameplay standard
DEF PLAYER_MODE_SPECIAL     EQU $0c ; Mode niveau spécial

; === Tailles de buffer ===

DEF ANIM_BUFFER_COPY_SIZE   EQU $08 ; Taille copie buffer animation (8 octets)

; === Offsets structure objets ===

DEF OBJ_FIELD_STATE_OFFSET  EQU $0A ; Offset vers le champ état/type (10 octets)

; === Données niveau ROM ===

DEF ROM_LEVEL_INIT_DATA     EQU $2114 ; Table données initialisation niveau
DEF LEVEL_INIT_DATA_SIZE    EQU $51   ; Taille données init niveau (81 octets)

; === Variables scroll et tilemap ===

DEF SCROLL_VAR_COUNT        EQU $06   ; Nombre de variables scroll à initialiser (6 octets)
DEF SCROLL_COLUMN_DEFAULT   EQU $40   ; Colonne scroll par défaut (64 tiles)
DEF SCROLL_COLUMN_MAX       EQU $60   ; Colonne scroll max avant wrap (96 tiles)
DEF TILEMAP_VISIBLE_COLS    EQU $14   ; Colonnes tilemap visibles (20 = écran)
DEF TILEMAP_BUFFER_COLS     EQU $1b   ; Colonnes tilemap avec buffer (27)

; === Direction joueur étendu ===

DEF PLAYER_DIR_RIGHT        EQU $10   ; Direction droite (complément de PLAYER_DIR_LEFT=$18)
DEF PLAYER_DIR_RIGHT_SUBMODE EQU $05  ; Sous-mode direction droite (nibble bas)

; === Animation ===

DEF ANIM_SCALE_MAX          EQU $03   ; Compteur scaling max (3 frames)
DEF ANIM_BANK_SPECIAL       EQU $50   ; Bank animation spéciale
DEF ANIM_BANK_OBJECT        EQU $10   ; Bank animation objets

; === State Buffer ===

DEF STATE_BUFFER_ANIM       EQU $03   ; Buffer état animation
DEF STATE_BUFFER_OBJECT     EQU $04   ; Buffer état objet

; === Timer AUX états ===

DEF TIMER_AUX_ACTIVE        EQU $01   ; Timer AUX actif (vérification)
DEF TIMER_AUX_PIPE_MODE     EQU $02   ; Timer AUX mode pipe/transition
DEF TIMER_AUX_DAMAGE_MAX    EQU $03   ; Timer AUX seuil dégâts
DEF TIMER_AUX_COMPLETE      EQU $04   ; Timer AUX terminé

; === Limites position X joueur (zone de scroll) ===

DEF PLAYER_X_SCROLL_MIN     EQU $b4   ; Position X minimum pour déclencher scroll (180 pixels)
DEF PLAYER_X_SCROLL_MAX     EQU $c0   ; Position X maximum pour déclencher scroll (192 pixels)

; === Valeurs timer checkpoint ===

DEF TIMER_CHECKPOINT_LONG   EQU $90   ; Timer checkpoint long (144 frames)
DEF TIMER_CHECKPOINT_SHORT  EQU $40   ; Timer checkpoint court (64 frames)

; === Masques direction joueur ===

DEF PLAYER_DIR_ANIM_BIT     EQU $10   ; Bit animation direction (XOR pour alterner)

; === Seuils état joueur pour scroll caméra ===

DEF PLAYER_STATE_SCROLL_THRESHOLD EQU $51 ; Seuil état déclenchant scroll caméra (81)
DEF PLAYER_STATE_SCROLL_LIMIT     EQU $50 ; Position état joueur après scroll (80)

; === Animation compteur objets ===

DEF ANIM_OBJ_COUNT_VALUE    EQU $32   ; Valeur compteur objets animation (50)

; === Offset calcul position ===

DEF PLAYER_ANIM_OFFSET      EQU $fc   ; Offset calcul animation joueur (-4)
DEF PLAYER_X_OFFSET         EQU $10   ; Offset soustrait de X joueur (16 pixels)
DEF OBJECT_COLLISION_RANGE  EQU $14   ; Distance max collision objet (20 pixels)

; === Initialisation structure joueur ===

DEF PLAYER_STATE_CLEAR      EQU $00   ; État joueur reset
DEF PLAYER_ANIM_DEFAULT     EQU $0d   ; Frame animation par défaut (13)
DEF PLAYER_FLAG_ACTIVE      EQU $01   ; Flag joueur actif
DEF PLAYER_VAR_AB_INIT      EQU $0c   ; Valeur initiale wPlayerVarAB (12)

; === Masques direction ===

DEF PLAYER_DIR_HIGH_MASK    EQU $f0   ; Masque bits hauts direction
DEF PLAYER_DIR_MODE_RESET   EQU $01   ; Mode direction initial/reset
DEF PLAYER_DIR_MODE_INTERACT EQU $04  ; Mode interaction direction (seuil)
DEF PLAYER_ANIM_STATE_PIPE  EQU $23   ; État animation pipe (35 = frame lente)

; === Style niveau ===

DEF LEVEL_STYLE_SPECIAL     EQU $03   ; Style niveau spécial (non décrémenté)

; === Masques génériques ===

DEF NIBBLE_LOW_MASK         EQU $0f   ; Masque 4 bits bas (nibble inférieur)
DEF NIBBLE_HIGH_MASK        EQU $f0   ; Masque 4 bits hauts (nibble supérieur)

; === Masques bitwise individuels ===

DEF BIT_0_MASK              EQU $01   ; Masque bit 0 uniquement
DEF BIT_1_MASK              EQU $02   ; Masque bit 1 uniquement
DEF BIT_2_MASK              EQU $04   ; Masque bit 2 uniquement
DEF BIT_3_MASK              EQU $08   ; Masque bit 3 uniquement
DEF BIT_6_MASK              EQU $40   ; Masque bit 6 uniquement
DEF BIT_7_MASK              EQU $80   ; Masque bit 7 uniquement
DEF BITS_2_3_MASK           EQU $0c   ; Masque bits 2-3
DEF BITS_2_3_CLEAR_MASK     EQU $f3   ; Efface bits 2-3 (inverse de $0c)
DEF BITS_4_5_MASK           EQU $30   ; Masque bits 4-5

; === États audio (bits 4-5 de hSoundCh4) ===
; Après masquage avec BITS_4_5_MASK ($30), les valeurs possibles sont :

DEF AUDIO_STATE_00          EQU $00   ; État audio 0 (bits 4-5 = 00)
DEF AUDIO_STATE_10          EQU $10   ; État audio 1 (bits 4-5 = 01)
DEF AUDIO_STATE_30          EQU $30   ; État audio 3 (bits 4-5 = 11)
DEF BITS_6_7_MASK           EQU $c0   ; Masque bits 6-7 (audio direction)
DEF BITS_5_7_MASK           EQU $e0   ; Masque bits 5-7 (audio type)
DEF CLEAR_BIT_0_MASK        EQU $fe   ; Efface bit 0 (inverse de $01)
DEF CLEAR_BIT_1_MASK        EQU $fd   ; Efface bit 1 (inverse de $02)

; === Masques joypad combinés ===
; (Les constantes individuelles PADF_* sont dans hardware.inc)

DEF JOYPAD_LR_MASK          EQU PADF_LEFT | PADF_RIGHT    ; $30 - Masque gauche/droite
DEF JOYPAD_SELECT_START_MASK EQU PADF_SELECT | PADF_START ; $0c - Masque Select/Start

; === Animation tiles - Calcul index monde/niveau ===
; Format hAnimTileIndex: $XY où X=monde (1-4), Y=niveau (1-3)
; Quand Y atteint 4 (inexistant), on passe au monde suivant niveau 1

DEF ANIM_TILE_LEVELS_PER_WORLD EQU $04 ; Seuil wrap niveau (3 niveaux → wrap à 4)
DEF ANIM_TILE_WORLD_OFFSET     EQU $0d ; Offset pour passer au monde suivant ($10-$03=13)

; === Invulnérabilité joueur ===

DEF PLAYER_INVULN_TIMER        EQU $f8   ; Timer invulnérabilité (-8, compte vers 0)

; === État rendu (wStateRender) ===

DEF STATE_RENDER_ACTIVE        EQU $01   ; Mode rendu actif (1)
DEF STATE_RENDER_DAMAGE        EQU $0c   ; Mode rendu après collision ennemi (12)
DEF STATE_RENDER_INIT          EQU $02   ; Mode rendu initialisation
DEF STATE_RENDER_SPECIAL       EQU $04   ; Mode rendu spécial (fin de niveau)
DEF STATE_RENDER_CUTSCENE      EQU $0f   ; Mode rendu cutscene fin niveau
DEF STATE_RENDER_STATE_BUFFER  EQU $0b   ; Mode rendu via wStateBuffer

; === Flags pause audio (hSavedAudio) ===

DEF PAUSE_ENTER                EQU $01   ; Entrée en pause (audio → mute)
DEF PAUSE_EXIT                 EQU $02   ; Sortie de pause (audio → restore)

; === Timers gameplay ===

DEF TIMER_STATE07_WAIT         EQU $40   ; Timer attente état $07 (64 frames)
DEF TIMER_GAMEPLAY_DELAY       EQU $50   ; Timer délai gameplay (80 frames)
DEF TIMER_SPECIAL_PATH         EQU $90   ; Timer chemin spécial (144 frames)

; === États de jeu additionnels ===

DEF GAME_STATE_WINDOW_UPDATE   EQU $3b   ; État mise à jour window ($3B)

; === Niveau monde 4-3 ===

DEF ANIM_TILE_W4_L3            EQU $43   ; Monde 4, Niveau 3 (fin du jeu)

; === VRAM Tilemap ===

DEF VRAM_TILEMAP_HIGH          EQU $98   ; Octet haut adresse tilemap BG ($9800)
DEF VRAM_SCRN1_HIGH            EQU $99   ; Octet haut adresse _SCRN1 ($9900)
DEF VRAM_TILEMAP_OFFSET        EQU $0120 ; Offset pour calcul scroll (288 bytes = 9 lignes)

; === Scroll initial ===

DEF TILEMAP_SCROLL_X_INIT      EQU $03   ; Valeur initiale hTilemapScrollX
DEF SCROLL_ALIGN_MASK          EQU $fc   ; Masque alignement 4 pixels (efface bits 0-1)

; === Collision - Offsets et seuils ===

DEF COLLISION_OFFSET_6         EQU $06   ; Offset collision ±6 pixels (demi-tile)
DEF COLLISION_THRESHOLD_7      EQU $07   ; Seuil collision 7 pixels
DEF COLLISION_MARGIN_3         EQU $03   ; Marge collision 3 pixels
DEF COLLISION_KNOCKBACK        EQU $0a   ; Distance knockback (10 pixels)
DEF COLLISION_ADJUST_NEG       EQU $fe   ; Ajustement collision négatif (-2)
DEF COLLISION_ADJUST_POS       EQU $02   ; Ajustement collision positif (+2)

; === Conversion adresse tile ↔ position sprite ===

DEF TILE_ADDR_Y_BASE           EQU $84   ; Base pour conversion adresse tile → Y sprite
DEF SPRITE_BITS_SHIFT          EQU $04   ; Nombre de bits à shifter (4)

; === Identifiants Monde (pour sélection banque/tiles) ===

DEF WORLD_1                    EQU $01   ; Monde 1
DEF WORLD_2                    EQU $02   ; Monde 2
DEF WORLD_3                    EQU $03   ; Monde 3
DEF WORLD_4                    EQU $04   ; Monde 4

; === Timers animations/cutscenes ===

DEF TIMER_ANIM_STEP            EQU $08   ; Timer step animation (8 frames)
DEF TIMER_ANIM_TRANSITION      EQU $10   ; Timer transition animation (16 frames)
DEF TIMER_ANIM_WALK            EQU $20   ; Timer marche animation (32 frames)
DEF TIMER_CUTSCENE             EQU $a1   ; Timer cutscene fin niveau (161 frames)
DEF TIMER_TRANSITION_LEVEL     EQU $26   ; Timer transition niveau (38 frames)
DEF TIMER_CREDITS_LONG         EQU $f0   ; Timer long crédits (240 frames)
DEF TIMER_WINDOW_SETUP         EQU $a0   ; Timer setup window (160 frames)

; === Positions cutscene joueur ===

DEF CUTSCENE_PLAYER_X          EQU $7e   ; Position X joueur cutscene (126 pixels)
DEF CUTSCENE_PLAYER_Y          EQU $b0   ; Position Y joueur cutscene (176 pixels)
DEF CUTSCENE_INIT_VALUE        EQU $00   ; Valeur init cutscene (wPlayerUnk12)
DEF CUTSCENE_TILE_ATTR         EQU $22   ; Attribut/tile cutscene (wPlayerUnk13)
DEF CUTSCENE_PARAM             EQU $20   ; Paramètre cutscene (wPlayerUnk15)

; === Seuils position état ===

DEF PLAYER_POS_THRESHOLD       EQU $c0   ; Seuil position Y joueur ($C0 = 192)
DEF PLAYER_Y_INIT              EQU $80   ; Position Y joueur initial (128 pixels)

; === État buffer (wStateBuffer) ===

DEF STATE_BUFFER_COIN          EQU $05   ; État buffer après collecte pièce

; === OAM et animation ===

DEF OAM_ADDR_INIT              EQU $05   ; Adresse OAM initiale colonne
DEF OAM_COPY_SIZE              EQU $10   ; Taille copie données OAM (16 octets)
DEF OAM_SPRITE_LOOP_3          EQU $03   ; Nombre de sprites dans boucle OAM (3)
DEF OAM_SPRITE_LOOP_8          EQU $08   ; Nombre de sprites dans boucle OAM (8)

; === Masques animation ===

DEF ANIM_SUBSTATE_MASK         EQU $c0   ; Masque bits hauts sous-état animation
DEF ANIM_HEIGHT_MASK           EQU $70   ; Masque hauteur objet animation
DEF ANIM_COUNTER_MASK          EQU $3f   ; Masque compteur animation (bits 0-5)
DEF CLEAR_BIT7_MASK            EQU $7f   ; Masque pour effacer le bit 7 (garde bits 0-6)
DEF FRAME_MASK_2               EQU $01   ; Masque pour exécuter toutes les 2 frames (counter & 1)
DEF FRAME_MASK_4               EQU $03   ; Masque pour exécuter toutes les 4 frames (counter & 3)
DEF FRAME_MASK_8               EQU $07   ; Masque pour exécuter toutes les 8 frames (counter & 7)
DEF SPRITE_HEIGHT_INDEX_MASK   EQU $07   ; Masque index hauteur sprite (bits 0-2, valeurs 0-7)
DEF AUDIO_POSITION_MASK        EQU $1f   ; Masque position audio (bits 0-4, valeurs 0-31)

; === Flags et valeurs de retour génériques ===

DEF FLAG_TRUE                  EQU $01   ; Flag actif / valeur vraie
DEF FLAG_FALSE                 EQU $00   ; Flag inactif / valeur fausse
DEF RETURN_TRUE                EQU $01   ; Valeur de retour vraie
DEF RETURN_FALSE               EQU $00   ; Valeur de retour fausse

; === Flags animation ===

DEF FLAG_ANIM_DONE             EQU $ff   ; Animation terminée (wPlayerVarAD)
DEF FLAG_UPDATE_NEEDED         EQU $01   ; Flag mise à jour nécessaire

; === Bank spéciale ===

DEF BANK_NONE                  EQU $ff   ; Pas de bank spécifique (hPtrBank)

; === Cutscene fin de jeu (États $2A-$31) ===

; Positions sprite princesse (State2B)
DEF PRINCESS_SPRITE_Y          EQU $70   ; Position Y sprite princesse (112 pixels)
DEF PRINCESS_SPRITE_X          EQU $3a   ; Position X sprite princesse (58 pixels)
DEF PRINCESS_SPRITE_TILE       EQU $84   ; Tile sprite princesse
DEF PRINCESS_DESCENT_END       EQU $44   ; Position Y fin descente princesse (68 pixels)

; Oscillation sprite (State2C)
DEF OSCIL_CLEAR_THRESHOLD      EQU $20   ; Seuil déclenchant clear écran (32)
DEF OSCIL_DIR_CHANGE_LOW       EQU $30   ; Seuil changement direction bas (48)
DEF OSCIL_DIR_CHANGE_HIGH      EQU $50   ; Seuil changement direction haut (80)
DEF OSCIL_RESET_VALUE          EQU $f0   ; Valeur reset oscillation (240)

; Clear écran cutscene (State2C)
DEF CUTSCENE_CLEAR_SIZE        EQU $6d   ; Taille zone à effacer (109 octets)
DEF VRAM_CUTSCENE_TEXT         EQU $98a5 ; Adresse début texte cutscene

; Marche cutscene (State2E-$30)
DEF CUTSCENE_COUNTER_INIT      EQU $c0   ; Compteur animation initial (192)
DEF CUTSCENE_POS_THRESHOLD_1   EQU $50   ; Seuil position 1 (80)
DEF CUTSCENE_POS_THRESHOLD_2   EQU $40   ; Seuil position 2 (64)
DEF CUTSCENE_WALK_END_X        EQU $58   ; Position X fin marche gauche (88 pixels)

; Transfert données sprite (State2F)
DEF SPRITE_DATA_COPY_SIZE      EQU $06   ; Taille copie données sprite (6 octets)
DEF PLAYER_DIR_CUTSCENE        EQU $26   ; Direction joueur cutscene
DEF SPRITE_ANIM_RESET          EQU $f0   ; Valeur reset animation sprite

; État rendu cutscene
DEF STATE_RENDER_FINAL         EQU $11   ; Mode rendu écran final

; === Marqueurs de contrôle texte ===
; Utilisés dans WriteCharToVRAM pour contrôler l'affichage du texte

DEF TEXT_CMD_NEWLINE           EQU $fe   ; Marqueur nouvelle ligne/offset
DEF TEXT_CMD_END               EQU $ff   ; Marqueur fin de texte

; === Valeurs d'animation/cutscene ===

DEF PLAYER_ANIM_INITIAL        EQU $80   ; Position/animation initiale joueur ($80)
DEF OAM_INDEX_CUTSCENE         EQU $08   ; Index OAM cutscene (8 sprites)
DEF SPRITE_CONFIG_COUNT        EQU $03   ; Compteur configuration sprite (3)
DEF STATE_BUFFER_SPECIAL       EQU $0a   ; Valeur spéciale wStateBuffer

; === Adresses tables sprites cutscene ===

DEF ROM_SPRITE_CONFIG_1        EQU $102c ; Table sprites config normale
DEF ROM_SPRITE_CONFIG_2        EQU $103c ; Table sprites config alternative

; === Timers cutscene spécifiques ===

DEF TIMER_CUTSCENE_6           EQU $06   ; Timer cutscene court (6 frames)
DEF TIMER_CUTSCENE_LONG        EQU $ff   ; Timer cutscene très long (255 frames)

; === VRAM/Tilemap cutscene ===

DEF VRAM_TILEMAP_WRAP_HIGH     EQU $99   ; Octet haut wrap tilemap ($9900)
DEF VRAM_DEST_CUTSCENE_HIGH    EQU $bf   ; Octet haut destination cutscene

; === Animation tiles - Identifiants mondes (nibble haut de hAnimTileIndex) ===

DEF ANIM_TILE_WORLD_4_NIBBLE   EQU $40   ; Monde 4 (nibble haut = $4X)

; === Tiles et attributs sprites transition (State03_SetupTransition) ===
; Tiles utilisés pour l'effet visuel de transition entre états

DEF TILE_TRANSITION_A          EQU $0f   ; Tile sprite transition A
DEF TILE_TRANSITION_B          EQU $1f   ; Tile sprite transition B
DEF OAM_ATTR_NORMAL            EQU $00   ; Attribut OAM: pas de flip
DEF OAM_ATTR_X_FLIP            EQU $20   ; Attribut OAM: flip horizontal (bit 5)
DEF OAM_ATTR_Y_FLIP            EQU $40   ; Attribut OAM: flip vertical (bit 6)
DEF OAM_ATTR_XY_FLIP           EQU $60   ; Attribut OAM: flip X+Y (bits 5+6)

; === Offset calcul sprite position ===

DEF SPRITE_X_OFFSET_NEG        EQU $f8   ; Offset X sprite négatif (-8)

; === Animation State04_AnimTransition ===
; Table et constantes pour l'animation de transition d'état

DEF ROM_ANIM_TRANSITION_TABLE  EQU $0c10 ; Table vitesses animation transition
DEF ANIM_TRANSITION_END_MARKER EQU $7f   ; Marqueur fin animation (valeur max)
DEF ANIM_TRANSITION_DEFAULT    EQU $02   ; Incrément animation par défaut
DEF OAM_ENTRY_SIZE             EQU $04   ; Taille d'une entrée OAM (4 octets: Y, X, Tile, Attr)
DEF SPRITE_Y_THRESHOLD_EXIT    EQU $b4   ; Seuil Y sprite pour sortie animation (180 pixels)

; === Timer texte cutscene ===

DEF TIMER_TEXT_CHAR            EQU $0c   ; Timer entre caractères texte (12 frames)
DEF CUTSCENE_TEXT_OFFSET       EQU $a5   ; Offset colonne texte cutscene ($98A5)

; === Encodage caractères texte (tiles) ===
; Pattern: lettre = $0A + (position dans alphabet)
; Utilisé pour les textes "THANK YOU MARIO!", "BONUS GAME", etc.

DEF TEXT_CHAR_A                EQU $0a   ; Caractère 'A'
DEF TEXT_CHAR_B                EQU $0b   ; Caractère 'B'
DEF TEXT_CHAR_D                EQU $0d   ; Caractère 'D'
DEF TEXT_CHAR_E                EQU $0e   ; Caractère 'E'
DEF TEXT_CHAR_G                EQU $10   ; Caractère 'G'
DEF TEXT_CHAR_H                EQU $11   ; Caractère 'H'
DEF TEXT_CHAR_I                EQU $12   ; Caractère 'I'
DEF TEXT_CHAR_K                EQU $14   ; Caractère 'K'
DEF TEXT_CHAR_M                EQU $16   ; Caractère 'M'
DEF TEXT_CHAR_N                EQU $17   ; Caractère 'N'
DEF TEXT_CHAR_O                EQU $18   ; Caractère 'O'
DEF TEXT_CHAR_Q                EQU $1a   ; Caractère 'Q'
DEF TEXT_CHAR_R                EQU $1b   ; Caractère 'R'
DEF TEXT_CHAR_S                EQU $1c   ; Caractère 'S'
DEF TEXT_CHAR_T                EQU $1d   ; Caractère 'T'
DEF TEXT_CHAR_U                EQU $1e   ; Caractère 'U'
DEF TEXT_CHAR_V                EQU $1f   ; Caractère 'V'
DEF TEXT_CHAR_Y                EQU $22   ; Caractère 'Y'
DEF TEXT_CHAR_EXCLAIM          EQU $23   ; Caractère '!' (style 1)
DEF TEXT_CHAR_EXCLAIM_ALT      EQU $28   ; Caractère '!' (style 2)
DEF TEXT_CHAR_PAREN            EQU $29   ; Caractère '(' ou ')'
DEF TEXT_CHAR_SPACE            EQU $2c   ; Caractère espace
DEF TEXT_CHAR_NEWLINE          EQU $fe   ; Saut de ligne
DEF TEXT_CHAR_END              EQU $ff   ; Fin de texte
DEF TEXT_CHAR_HEART            EQU $73   ; Icône coeur

; === Animation princesse (State26) ===

DEF PRINCESS_ANIM_THRESHOLD    EQU $d0   ; Seuil Y animation princesse (208 pixels)
DEF PRINCESS_INIT_VALUE        EQU $20   ; Valeur initiale animation princesse
DEF PRINCESS_NEXT_VALUE        EQU $21   ; Valeur suivante animation princesse
DEF TIMER_PRINCESS_PAUSE       EQU $40   ; Timer pause animation princesse (64 frames)

; === Animation oscillation (State27) ===

DEF OSCIL_TIMER_INIT           EQU $20   ; Timer init oscillation (32 frames)
DEF OSCIL_OFFSET_NEG           EQU $fc   ; Offset oscillation négatif (-4)
DEF OSCIL_OFFSET_POS           EQU $04   ; Offset oscillation positif (+4)
DEF OSCIL_TIMER_THRESHOLD      EQU $80   ; Seuil timer oscillation (128)
DEF OSCIL_TIMER_END            EQU $3f   ; Timer fin oscillation (63 frames)

; === État $2A - Affichage texte fin ===

DEF VRAM_COPY_LINE_OFFSET      EQU $02   ; Offset ligne copie VRAM (ligne 2)
DEF CUTSCENE_COUNTER_23        EQU $23   ; Compteur cutscene animation (35 frames)

; === État $29 - Setup écran fin ===

DEF SCRN1_FIN_CLEAR_SIZE       EQU $0100 ; Taille clear _SCRN1 fin (256 octets)
DEF END_SCREEN_PLAYER_Y        EQU $38   ; Position Y joueur écran fin (56)
DEF END_SCREEN_PLAYER_X        EQU $10   ; Position X joueur écran fin (16)
DEF END_SCREEN_PLAYER_POS      EQU $78   ; Position joueur écran fin (120)
DEF OAM_CLEAR_SIZE_END         EQU $0c   ; Taille clear OAM fin (12 octets)

; === Commandes audio (queue processing) ===
; Commandes spéciales dans les données audio ($f0-$fd)

DEF AUDIO_CMD_F0               EQU $f0   ; Commande audio F0 (special processing)
DEF AUDIO_CMD_F1               EQU $f1   ; Commande audio F1 (save/load slot)
DEF AUDIO_CMD_F8               EQU $f8   ; Commande audio F8 (set channel 3)
DEF AUDIO_CMD_F2               EQU $f2   ; Commande audio F2 (set channel 4)
DEF AUDIO_CMD_F3               EQU $f3   ; Commande audio F3 (init sound)
DEF AUDIO_CMD_F4               EQU $f4   ; Commande audio F4 (set var2)
DEF AUDIO_CMD_F5               EQU $f5   ; Commande audio F5 (random timing)
DEF AUDIO_CMD_F6               EQU $f6   ; Commande audio F6 (player position check)
DEF AUDIO_CMD_F7               EQU $f7   ; Commande audio F7 (destroy all objects)
DEF AUDIO_CMD_F9               EQU $f9   ; Commande audio F9 (set state final)
DEF AUDIO_CMD_FA               EQU $fa   ; Commande audio FA (set state buffer)
DEF AUDIO_CMD_FB               EQU $fb   ; Commande audio FB (player distance check)
DEF AUDIO_CMD_FC               EQU $fc   ; Commande audio FC (set sound params)
DEF AUDIO_CMD_FD               EQU $fd   ; Commande audio FD (set state render)

; === Index slots audio ===

DEF AUDIO_SLOT_10              EQU $0a   ; Index slot audio 10 (pour save/load)

; === Seuils audio (ProcessAudioSlots, FindAudioTableEntry) ===

DEF AUDIO_PARAM2_LIMIT         EQU $e0   ; Seuil param2 désactivation slot ($E0 = 224)
DEF AUDIO_PARAM1_LIMIT         EQU $c0   ; Seuil param1 désactivation slot ($C0 = 192)
DEF AUDIO_OBJECT_END_LOW       EQU $90   ; Octet bas fin itération objets ($D190)

; === Calcul distance joueur audio (AUDIO_CMD_F6) ===

DEF PLAYER_DISTANCE_OFFSET     EQU $14   ; Offset calcul distance audio (+20)
DEF PLAYER_DISTANCE_RANGE      EQU $20   ; Plage distance audio (32 = -20 à +12)

; === Valeurs canaux son ===

DEF SOUND_CHANNEL_BOTH_BITS    EQU $0c   ; Bits 2-3 actifs (les deux canaux)

; === Seuils positions crédits (CheckTilemapCompletion) ===
; Ces valeurs représentent les positions finales des 6 buffers tilemap
; avant de passer à l'état InitializeCreditsMode

DEF CREDITS_POS_BUF71          EQU $3c   ; Position finale wTilemapBuf71 (60)
DEF CREDITS_POS_BUF75          EQU $44   ; Position finale wTilemapBuf75 (68)
DEF CREDITS_POS_BUF79          EQU $4c   ; Position finale wTilemapBuf79 (76)
DEF CREDITS_POS_BUF7D          EQU $5c   ; Position finale wTilemapBuf7D (92)
DEF CREDITS_POS_BUF81          EQU $64   ; Position finale wTilemapBuf81 (100)
DEF CREDITS_POS_BUF85          EQU $6c   ; Position finale wTilemapBuf85 (108)

; === Seuils état joueur (pipes/transitions) ===

DEF PLAYER_STATE_PIPE_THRESHOLD EQU $4c  ; Seuil état joueur pour sortie pipe (76)

; === Constantes initialisation niveau (InitLevelData wLevelParam*) ===

DEF LEVEL_PARAM_COPY_COLS       EQU $04   ; Nombre colonnes copie tilemap (4)
DEF LEVEL_PARAM_COPY_ROWS       EQU $11   ; Nombre lignes copie tilemap (17)

; === Adresses VRAM hautes (limites de boucle) ===

DEF VRAM_COPY_LIMIT_HIGH       EQU $97   ; Octet haut limite copie VRAM ($9700)

; === Tailles copie mémoire (State37/crédits) ===

DEF TILEMAP_END_DATA_SIZE      EQU $18   ; Taille données tilemap fin (24 octets)
DEF SPRITE_CONFIG_COPY_SIZE    EQU $05   ; Taille copie config sprite (5 octets)

; === Valeurs scroll crédits/écran final ===

DEF OAM_INDEX_FINAL_SETUP      EQU $21   ; Index OAM setup écran final (33)
DEF SCROLL_COLUMN_FINAL        EQU $54   ; Colonne scroll écran final (84)

; === Timers écran final ===

DEF TIMER_CREDITS_SETUP        EQU $90   ; Timer setup crédits (144 frames)

; === Adresses ROM tables données (écran final) ===
; Tables de configuration sprites pour écran final ($1376-$1384)

DEF ROM_SPRITE_END_DATA_1      EQU $1376 ; Table config sprite joueur final
DEF ROM_SPRITE_END_DATA_2      EQU $137b ; Table config sprite objet 2 final
DEF ROM_SPRITE_END_DATA_3      EQU $1380 ; Table config sprite objet 3 final
DEF ROM_TILEMAP_END_DATA       EQU $14bb ; Table données tilemap écran final
DEF ROM_TEXT_GAME_OVER         EQU $1cce ; Données texte "GAME OVER" (17 octets)
DEF TEXT_GAME_OVER_SIZE        EQU $11   ; Taille texte Game Over (17 octets)
DEF TEXT_WINDOW_DATA_SIZE      EQU $09   ; Taille données window (9 octets)

; === Collision - Offsets et ajustements ===

DEF COLLISION_OFFSET_4         EQU $04   ; Offset collision 4 pixels
DEF COLLISION_OFFSET_8         EQU $08   ; Offset collision 8 pixels
DEF PLAYER_X_SUB_OFFSET        EQU $0b   ; Offset soustrait de X joueur (11 pixels)

; === États joueur (wPlayerUnk07) ===

DEF PLAYER_UNK07_GROUNDED      EQU $01   ; Joueur au sol
DEF PLAYER_UNK07_FALLING       EQU $02   ; Joueur en chute

; === Valeurs OAM sprites ===

DEF OAM_SPRITE_TILE_81         EQU $81   ; Tile sprite effet spécial
DEF OAM_SPRITE_TILE_82         EQU $82   ; Tile sprite eau/effet

; === Constantes de boucle/compteur ===

DEF INIT_OBJECTS_LOOP_COUNT    EQU $04   ; Nombre d'objets à initialiser (4)
DEF OBJECT_STRUCT_SIZE         EQU $10   ; Taille structure objet (16 octets)
DEF OBJECT_OFFSET_09           EQU $09   ; Offset +9 dans structure objet (flag état)
DEF OBJECT_INIT_X_OFFSET       EQU $f3   ; Offset X pour init objets (-13 en signé)
DEF OBJECT_INIT_Y_OFFSET       EQU $02   ; Offset Y pour init objets (+2)

; === Valeurs wStateBuffer ===

DEF STATE_BUFFER_DEFAULT       EQU $07   ; Valeur par défaut wStateBuffer

; === IDs Sons (pour PlaySound) ===

DEF SFX_OBJECT_COMPLETE        EQU $27   ; Son fin traitement objets
DEF SFX_BLOCK_HIT              EQU $28   ; Son collision bloc
DEF SFX_BLOCK_HIT_ALT          EQU $2d   ; Son collision bloc alternatif

; === Collision pieds/tête joueur ===

DEF FEET_COLLISION_OFFSET_Y    EQU $fd   ; Offset Y pieds joueur (-3)
DEF FEET_COLLISION_ADJUST_X    EQU $02   ; Ajustement X pieds joueur (+2)
DEF COLLISION_ADJUST_X_NEG4    EQU $fc   ; Ajustement X collision (-4)
DEF PIPE_OFFSET_Y              EQU $18   ; Offset Y calcul pipe (+24)
DEF TILE_ALIGN_OFFSET          EQU $06   ; Offset alignement tile

; === Flags joueur (wPlayerFlag) ===

DEF PLAYER_FLAG_PIPE_MODE      EQU $80   ; Flag mode pipe/transition

; === Valeurs OAM sprite ===

DEF OAM_SPRITE_HIDDEN          EQU $80   ; Y position cachée (hors écran)

; === Compteurs de boucle (clear/init) ===

DEF OAM_CLEAR_LOOP_COUNT       EQU $0b   ; Compteur clear OAM (11 octets)
DEF OAM_CLEAR_LOOP_COUNT_F     EQU $0f   ; Compteur clear OAM (15 octets)
DEF OAM_VAR_BUFFER_SIZE        EQU $34   ; Taille buffer OAM variables (52 octets)

; === États objets (wObject*) ===

DEF OBJECT_STATE_INACTIVE      EQU $0b   ; État objet inactif/désactivé

; === Valeurs d'état (wStateFinal) ===

DEF STATE_FINAL_COMPLETE       EQU $02   ; État final: transition complète

; === Offsets mouvement/ajustement ===

DEF MOVEMENT_OFFSET_4          EQU $04   ; Offset mouvement (4 pixels)

; === Tables ROM Audio/Objets ===

DEF ROM_OBJECT_SOUND_TABLE     EQU $317d ; Table sons objets (5 octets/entrée)

; === Valeurs de retour spéciales ===

DEF RETURN_COLLISION_FOUND     EQU $ff   ; Collision détectée (retour fonction)
DEF RETURN_ANIM_CONTINUE       EQU $fe   ; Animation en cours (retour fonction)

; === Seuils animation objets ===

DEF ANIM_COUNTER_TRIGGER_50    EQU $32   ; Seuil déclencheur animation (50)
DEF ANIM_COUNTER_TRIGGER_8     EQU $08   ; Seuil déclencheur animation (8)
DEF ANIM_COUNTER_TRIGGER_26    EQU $1a   ; Seuil déclencheur animation (26)
DEF ANIM_COUNTER_TRIGGER_97    EQU $61   ; Seuil déclencheur animation (97)
DEF ANIM_COUNTER_TRIGGER_96    EQU $60   ; Seuil déclencheur animation (96)

; === Offset structure objet ===

DEF OBJ_FIELD_ANIM_COUNTER     EQU $0c   ; Offset vers compteur animation (12 octets)

; === Tiles niveau/eau ===

DEF TILE_WATER_REPLACED        EQU $7f   ; Tile après destruction bloc eau
DEF BLOCK_STATE_EMPTY          EQU $03   ; État bloc après collecte pièce

; === State Render (mode rendu) ===

DEF STATE_RENDER_GAME_OVER     EQU $10   ; Mode rendu écran Game Over (16)

; === Configuration max ===

DEF CONFIG_VALUE_MAX           EQU $0a   ; Valeur max configuration (10)
DEF CONFIG_VALUE_CLAMP         EQU $09   ; Valeur clamped configuration (9)

; === Tilemap ===

DEF TILEMAP_DEFAULT_COUNT      EQU $10   ; Nombre tiles par défaut (16)

; === Scroll position ===

DEF SCROLL_THRESHOLD_OSCIL     EQU $50   ; Seuil scroll pour oscillation (80)

; === Seuils tiles collision ===
; Valeurs utilisées pour classifier les tiles lors des vérifications de collision

DEF TILE_SPECIAL_THRESHOLD     EQU $f0   ; Seuil tiles spéciaux (>= $F0 = vide/traversable)

; === Configuration collision latérale (CheckPlayerSideCollision) ===
; Ces valeurs configurent la détection de collision sur les côtés du joueur
; Format combiné pour ld de: D (octet haut) = offset Y, E (octet bas) = compteur

DEF COLLISION_SIDE_CONFIG_1    EQU $0701 ; D=$07 offset Y, E=$01 (1 itération, mode normal)
DEF COLLISION_SIDE_CONFIG_2    EQU $0702 ; D=$07 offset Y, E=$02 (2 itérations, mode pipe)
DEF COLLISION_SIDE_X_NEG       EQU $fa   ; Offset X négatif collision (-6)
DEF COLLISION_SIDE_X_POS       EQU $06   ; Offset X positif collision (+6)
DEF COLLISION_LOOP_RESET       EQU $fc   ; Reset offset Y boucle collision (-4)

; === Animation crédits (UpdateCreditsStars) ===
; Constantes pour l'animation des étoiles pendant les crédits

DEF CREDITS_STAR_COUNT         EQU $03   ; Nombre d'étoiles à animer (3)
DEF CREDITS_ANIM_LOW_THRESH    EQU $01   ; Seuil bas animation (1)
DEF CREDITS_ANIM_RESET         EQU $fe   ; Valeur reset animation (254)
DEF CREDITS_ANIM_HIGH_THRESH   EQU $e0   ; Seuil haut animation (224)
DEF CREDITS_POS_RANDOM_THRESH  EQU $68   ; Seuil position aléatoire (104)

; === Tables ROM monde (SearchByteLoop) ===

DEF ROM_WORLD_TILE_TABLE       EQU $1a8a ; Table tiles par monde
DEF TABLE_END_MARKER           EQU $fd   ; Marqueur fin de table

; === Constantes mouvement joueur ===
; Utilisées dans ProcessAnimationState pour gérer l'accélération/décélération

DEF PLAYER_ACCEL_COUNTER_MAX   EQU $06   ; Compteur max accélération mouvement (6 étapes)
DEF PLAYER_STATE_OSCIL_THRESH  EQU $0f   ; Seuil état joueur pour oscillation ($0F = 15)
DEF PLAYER_DIR_CHECK_LEFT      EQU $20   ; Valeur wPlayerUnk0D = direction gauche confirmée
DEF PLAYER_ACCEL_TIMER_LEFT    EQU $10   ; Timer accélération mouvement gauche (16 frames)
DEF PLAYER_ACCEL_TIMER_RIGHT   EQU $20   ; Timer accélération mouvement droite (32 frames)

; === Audio slots ===

DEF AUDIO_SLOT_LOOP_COUNT      EQU $0a   ; Nombre de slots audio à traiter (10)

; === Valeurs d'initialisation paramètres niveau (InitLevelData) ===
; Ces constantes définissent les valeurs initiales pour wLevelData ($DA00-$DA29)

DEF LEVEL_PARAM_INIT_20        EQU $20   ; Valeur init paramètres niveau (32)
DEF LEVEL_PARAM_INIT_F6        EQU $f6   ; Valeur init paramètres niveau (-10)
DEF LEVEL_PARAM_INIT_30        EQU $30   ; Valeur init paramètres niveau (48)
DEF LEVEL_PARAM_INIT_02        EQU $02   ; Difficulté initiale niveau (2)
DEF LEVEL_PARAM_INIT_40        EQU $40   ; Timer/compteur niveau initial (64)
DEF LEVEL_PARAM_LOOP_9         EQU $09   ; Boucle init 9 octets
DEF LEVEL_PARAM_LOOP_8         EQU $08   ; Boucle init 8 octets

; === Valeur wStateRender (State12_EndLevelSetup) ===

DEF STATE_RENDER_END_SETUP     EQU $09   ; Mode rendu fin de niveau setup

; === Limites position Y sprites (collision/animation) ===
; Utilisés pour les calculs de mouvement vertical des sprites

DEF SPRITE_Y_LIMIT_MAX         EQU $a2   ; Limite Y max sprite montant (162 pixels)
DEF SPRITE_Y_LIMIT_UPPER       EQU $a8   ; Limite Y haute sprite descendant (168 pixels)
DEF SPRITE_Y_LIMIT_MIN         EQU $10   ; Limite Y min sprite (16 pixels = haut écran)
DEF SPRITE_Y_LIMIT_LOW         EQU $04   ; Limite Y basse sprite (4 pixels)

; === Ajustements position sprite (IncrementY/DecrementY) ===

DEF SPRITE_Y_ADJUST_3          EQU $03   ; Ajustement Y sprite +3 pixels
DEF SPRITE_Y_ADJUST_4          EQU $04   ; Ajustement Y sprite +4 pixels

; === Offsets collision bounding box ===
; Utilisés pour calculer les coins de la hitbox lors des tests de collision

DEF COLLISION_OFFSET_3         EQU $03   ; Offset collision 3 pixels (centre)
DEF COLLISION_OFFSET_5         EQU $05   ; Offset collision 5 pixels (coin)

; === Offsets position pipe/transition ===

DEF PIPE_EXIT_X_OFFSET         EQU $12   ; Offset X sortie tuyau (18 pixels)
DEF SCROLL_Y_CALC_OFFSET       EQU $0c   ; Offset calcul Y scroll (12 pixels)

; === Audio - Bases de calcul position ===

DEF AUDIO_PARAM_BASE_Y         EQU $10   ; Base calcul Y audio (16 pixels)
DEF AUDIO_PARAM_BASE_X         EQU $d0   ; Base calcul X audio (208 pixels)
