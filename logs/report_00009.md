Consulte le [script]("../scripts/bfs_explorer.py") qui a permis de générer ces informations

Je souhaite pouvoir améliorer ce script en te laissant constater les résultats qu'il a  produit

Voici le commentaire git
<CommentaireGit>
[BFS-4000_1] LevelJumpTable Bank 1
</CommentaireGit>

Le diff git
<DiffGit>
diff --git a/scripts/bfs_state.json b/scripts/bfs_state.json
index 2080cbe..6c29b52 100644
--- a/scripts/bfs_state.json
+++ b/scripts/bfs_state.json
@@ -161,659 +161,756 @@
       "priority": 3
     },
     {
-      "address": "$07C3",
+      "address": "$0322",
       "node_type": "code",
-      "description": "CheckInputAndPause - V\u00e9rifie input pour soft reset (A+B+Start+Select) ou toggle pause",
-      "source": "$0226",
+      "description": "State0E_LevelInit - Init niveau + HUD",
+      "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$09E8",
+      "address": "$04C3",
       "node_type": "code",
-      "description": "InitGameState - Initialise l'\u00e9tat de jeu (appel\u00e9 quand wSpecialState == 3)",
-      "source": "$0226",
+      "description": "State0F_LevelSelect - Menu s\u00e9lection",
+      "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$172D",
+      "address": "$055F",
       "node_type": "code",
-      "description": "SwitchBankAndCallBank3Handler - Appelle handler en bank 3 avec params sp\u00e9cifiques",
-      "source": "$0226",
+      "description": "State11_LevelStart - D\u00e9marrage niveau",
+      "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$1B7D",
+      "address": "$05B7",
       "node_type": "code",
-      "description": "ProcessBlockCollision - Traitement des collisions avec les blocs",
-      "source": "$0040",
+      "description": "State10_Noop - Vide (placeholder)",
+      "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$1C2A",
+      "address": "$0610",
       "node_type": "code",
-      "description": "UpdateLivesDisplay - Mise \u00e0 jour de l'affichage des vies",
-      "source": "$0040",
+      "description": "State00_MainGameplay - Init/main gameplay",
+      "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$224F",
+      "address": "$06A5",
       "node_type": "code",
-      "description": "UpdateScrollColumn - Mise \u00e0 jour du scroll colonne",
-      "source": "$0040",
+      "description": "State01_WaitClearObjects - Reset objets",
+      "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$23F8",
+      "address": "$06C5",
       "node_type": "code",
-      "description": "UpdateAnimTiles - Mise \u00e0 jour des tiles anim\u00e9es",
-      "source": "$0040",
+      "description": "State02_PrepareRender - Pr\u00e9paration rendu",
+      "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$3D61",
+      "address": "$07C3",
       "node_type": "code",
-      "description": "UpdateLevelScore - Mise \u00e0 jour du score du niveau",
-      "source": "$0040",
+      "description": "CheckInputAndPause - V\u00e9rifie input pour soft reset (A+B+Start+Select) ou toggle pause",
+      "source": "$0226",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$3F24",
+      "address": "$09E8",
       "node_type": "code",
-      "description": "UpdateScoreDisplay - Mise \u00e0 jour de l'affichage du score",
-      "source": "$0040",
+      "description": "InitGameState - Initialise l'\u00e9tat de jeu (appel\u00e9 quand wSpecialState == 3)",
+      "source": "$0226",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$47F2",
+      "address": "$0B84",
       "node_type": "code",
-      "description": "JoypadReadHandler",
-      "source": "GameLoop",
-      "bank": 3,
+      "description": "State03_SetupTransition - Setup sprites transition",
+      "source": "$02A5",
+      "bank": 0,
       "priority": 3
     },
     {
-      "address": "$4823",
+      "address": "$0BCD",
       "node_type": "code",
-      "description": "AnimationHandler",
-      "source": "CallBank3Handler",
-      "bank": 3,
+      "description": "State04_AnimTransition - Animation transition",
+      "source": "$02A5",
+      "bank": 0,
       "priority": 3
     },
     {
-      "address": "$7FF0",
+      "address": "$0C37",
       "node_type": "code",
-      "description": "AudioEntryPoint - Routine audio principale en bank 3",
-      "source": "$0050",
-      "bank": 3,
+      "description": "State07_WaitBank3 - Attente + bank 3",
+      "source": "$02A5",
+      "bank": 0,
       "priority": 3
     },
     {
-      "address": "$7FF3",
+      "address": "$0C6A",
       "node_type": "code",
-      "description": "ROM_INIT_BANK3 - Routine d'initialisation en bank 3",
-      "source": "$0185",
-      "bank": 3,
+      "description": "State05_SpecialLevel - Niveau sp\u00e9cial gestion",
+      "source": "$02A5",
+      "bank": 0,
       "priority": 3
     },
     {
-      "address": "$C0A5",
-      "node_type": "data",
-      "description": "wGameConfigA5 - mode handler (0=normal, !=0=retour)",
-      "source": "$0095",
+      "address": "$0CC2",
+      "node_type": "code",
+      "description": "State06_PostLevel - Transition post-niveau",
+      "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$C0AD",
-      "node_type": "data",
-      "description": "wPlayerVarAD - flag animation termin\u00e9e (FLAG_ANIM_DONE)",
-      "source": "$0095",
+      "address": "$0D40",
+      "node_type": "code",
+      "description": "State08_WorldProgress - Progression monde/niveau",
+      "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$C0DE",
-      "node_type": "data",
-      "description": "wAudioSaveDE - flag scroll Y actif",
-      "source": "$0095",
+      "address": "$0DF0",
+      "node_type": "code",
+      "description": "State1B_Handler - 1 byte avant State1B_BonusComplete",
+      "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$C0DF",
-      "node_type": "data",
-      "description": "wLevelInitFlag - valeur scroll Y \u00e0 appliquer",
-      "source": "$0095",
+      "address": "$0E0C",
+      "node_type": "code",
+      "description": "State1C_WaitTimerGameplay - Attente timer gameplay",
+      "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$FFA4",
-      "node_type": "data",
-      "description": "hShadowSCX - shadow register pour effets raster",
-      "source": "$0095",
+      "address": "$0E28",
+      "node_type": "code",
+      "description": "State1D_SetupVRAMPointer - Setup pointeur VRAM",
+      "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$FFB3",
-      "node_type": "data",
-      "description": "hGameState - \u00e9tat du jeu (check GAME_STATE_WINDOW=$3A)",
-      "source": "$0095",
+      "address": "$0E54",
+      "node_type": "code",
+      "description": "State1E_ClearTilemapColumn - Clear colonne tilemap",
+      "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$FFB6",
+      "address": "$0E8D",
       "node_type": "code",
-      "description": "hDmaRoutine - Routine DMA OAM copi\u00e9e en HRAM",
-      "source": "$0040",
+      "description": "State1F_EnableVBlankMode - Active mode VBlank",
+      "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$FFFB",
-      "node_type": "data",
-      "description": "hOAMIndex - index OAM pour animation",
-      "source": "$0095",
+      "address": "$0EA0",
+      "node_type": "code",
+      "description": "State20_WaitPlayerPosition - Attente position joueur",
+      "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$0610",
+      "address": "$0EC4",
       "node_type": "code",
-      "description": "State00_MainGameplay - Init/main gameplay",
+      "description": "State21_SetupEndCutscene - Setup cutscene fin",
       "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$06A5",
+      "address": "$0F09",
       "node_type": "code",
-      "description": "State01_WaitClearObjects - Reset objets",
+      "description": "State22_ScrollCutscene - Scroll cutscene",
       "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$06C5",
+      "address": "$0F2A",
       "node_type": "code",
-      "description": "State02_PrepareRender - Pr\u00e9paration rendu",
+      "description": "State23_WalkToDoor - Marche vers porte",
       "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$0B84",
+      "address": "$0F61",
       "node_type": "code",
-      "description": "State03_SetupTransition - Setup sprites transition",
+      "description": "State24_DisplayText - Affichage texte",
       "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$0BCD",
+      "address": "$0FF4",
       "node_type": "code",
-      "description": "State04_AnimTransition - Animation transition",
+      "description": "State25_SpriteBlinkAnimation - Animation clignotante",
       "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$0C6A",
+      "address": "$104C",
       "node_type": "code",
-      "description": "State05_SpecialLevel - Niveau sp\u00e9cial gestion",
+      "description": "State26_PrincessRising - Princesse montante",
       "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$0CC2",
+      "address": "$1090",
       "node_type": "code",
-      "description": "State06_PostLevel - Transition post-niveau",
+      "description": "State27_PlayerOscillation - Oscillation joueur",
       "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$0C37",
+      "address": "$110D",
       "node_type": "code",
-      "description": "State07_WaitBank3 - Attente + bank 3",
+      "description": "State29_SetupEndScreen - Setup \u00e9cran fin",
       "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$0D40",
+      "address": "$115C",
       "node_type": "code",
-      "description": "State08_WorldProgress - Progression monde/niveau",
+      "description": "State2A_DisplayEndText - Affichage texte fin",
       "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$1612",
+      "address": "$118B",
       "node_type": "code",
-      "description": "State09_PipeEnterRight - Entr\u00e9e tuyau droite",
+      "description": "State2B_PrincessDescending - Princesse descendante",
       "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$1626",
+      "address": "$11C7",
       "node_type": "code",
-      "description": "State0A_LoadSubLevel - Chargement sous-niveau",
+      "description": "State2C_SpriteOscillation - Oscillation sprite",
       "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$1663",
+      "address": "$1212",
       "node_type": "code",
-      "description": "State0B_PipeEnterDown - Descente tuyau",
+      "description": "State2D_DisplayText2 - Affichage texte 2",
       "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$16D1",
+      "address": "$124B",
       "node_type": "code",
-      "description": "State0C_PipeExitLeft - Sortie tuyau gauche",
+      "description": "State2E_DuoAnimation - Animation duo",
       "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$236D",
+      "address": "$1298",
       "node_type": "code",
-      "description": "State0D_GameplayFull - Gameplay avec objets",
+      "description": "State2F_TransferSpriteData - Transfert donn\u00e9es sprite",
       "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$0322",
+      "address": "$12B9",
       "node_type": "code",
-      "description": "State0E_LevelInit - Init niveau + HUD",
+      "description": "State30_WalkLeft - Marche gauche",
       "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$04C3",
+      "address": "$12E8",
       "node_type": "code",
-      "description": "State0F_LevelSelect - Menu s\u00e9lection",
+      "description": "State31_HorizontalScroll - Scroll horizontal",
       "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$05B7",
+      "address": "$1385",
       "node_type": "code",
-      "description": "State10_Noop - Vide (placeholder)",
+      "description": "State32_CreditsScroll - Scroll cr\u00e9dits",
       "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$055F",
+      "address": "$13E7",
       "node_type": "code",
-      "description": "State11_LevelStart - D\u00e9marrage niveau",
+      "description": "State33_DisplayCreditsText - Affichage texte cr\u00e9dits",
       "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$3D8E",
+      "address": "$1438",
       "node_type": "code",
-      "description": "State12_EndLevelSetup - Setup fin de niveau",
+      "description": "State34_WaitCreditsCounter - Attente compteur cr\u00e9dits",
       "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$3DCE",
+      "address": "$1451",
       "node_type": "code",
-      "description": "State13_DrawEndBorder - Dessin bordure fin",
+      "description": "State35_WaitTimer - Attente timer",
       "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$5832",
+      "address": "$145D",
       "node_type": "code",
-      "description": "State14_Handler - (Bank 1, zone donn\u00e9es)",
+      "description": "State36_CreditsFinalTransition - Transition finale cr\u00e9dits",
       "source": "$02A5",
-      "bank": 1,
+      "bank": 0,
       "priority": 3
     },
     {
-      "address": "$5835",
+      "address": "$147F",
       "node_type": "code",
-      "description": "State15_Handler - (Bank 1, zone donn\u00e9es)",
+      "description": "State37_FinalSpriteAnimation - Animation sprite finale",
       "source": "$02A5",
-      "bank": 1,
+      "bank": 0,
       "priority": 3
     },
     {
-      "address": "$3E9E",
+      "address": "$14D3",
       "node_type": "code",
-      "description": "State16_CopyTilemapData - Copie donn\u00e9es tilemap",
+      "description": "State38_CreditsAnimation - Animation cr\u00e9dits",
       "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$5838",
+      "address": "$1612",
       "node_type": "code",
-      "description": "State17_Handler - (Bank 1, zone donn\u00e9es)",
+      "description": "State09_PipeEnterRight - Entr\u00e9e tuyau droite",
       "source": "$02A5",
-      "bank": 1,
+      "bank": 0,
       "priority": 3
     },
     {
-      "address": "$583B",
+      "address": "$1626",
       "node_type": "code",
-      "description": "State18_Handler - (Bank 1, zone donn\u00e9es)",
+      "description": "State0A_LoadSubLevel - Chargement sous-niveau",
       "source": "$02A5",
-      "bank": 1,
+      "bank": 0,
       "priority": 3
     },
     {
-      "address": "$583E",
+      "address": "$1663",
       "node_type": "code",
-      "description": "State19_Handler - (Bank 1, zone donn\u00e9es)",
+      "description": "State0B_PipeEnterDown - Descente tuyau",
       "source": "$02A5",
-      "bank": 1,
+      "bank": 0,
       "priority": 3
     },
     {
-      "address": "$5841",
+      "address": "$16D1",
       "node_type": "code",
-      "description": "State1A_Handler - (Bank 1, zone donn\u00e9es)",
+      "description": "State0C_PipeExitLeft - Sortie tuyau gauche",
       "source": "$02A5",
-      "bank": 1,
+      "bank": 0,
       "priority": 3
     },
     {
-      "address": "$0DF0",
+      "address": "$172D",
       "node_type": "code",
-      "description": "State1B_Handler - 1 byte avant State1B_BonusComplete",
-      "source": "$02A5",
+      "description": "SwitchBankAndCallBank3Handler - Appelle handler en bank 3 avec params sp\u00e9cifiques",
+      "source": "$0226",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$0E0C",
+      "address": "$1B7D",
       "node_type": "code",
-      "description": "State1C_WaitTimerGameplay - Attente timer gameplay",
-      "source": "$02A5",
+      "description": "ProcessBlockCollision - Traitement des collisions avec les blocs",
+      "source": "$0040",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$0E28",
+      "address": "$1C2A",
       "node_type": "code",
-      "description": "State1D_SetupVRAMPointer - Setup pointeur VRAM",
-      "source": "$02A5",
+      "description": "UpdateLivesDisplay - Mise \u00e0 jour de l'affichage des vies",
+      "source": "$0040",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$0E54",
+      "address": "$1C73",
       "node_type": "code",
-      "description": "State1E_ClearTilemapColumn - Clear colonne tilemap",
+      "description": "State39_GameOver - Game Over",
       "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$0E8D",
+      "address": "$1CDB",
       "node_type": "code",
-      "description": "State1F_EnableVBlankMode - Active mode VBlank",
+      "description": "State3B_WindowSetup - Setup window",
       "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$0EA0",
+      "address": "$1CDF",
       "node_type": "code",
-      "description": "State20_WaitPlayerPosition - Attente position joueur",
+      "description": "State3A_Handler - 4 bytes avant State3A_WindowUpdate",
       "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$0EC4",
+      "address": "$224F",
       "node_type": "code",
-      "description": "State21_SetupEndCutscene - Setup cutscene fin",
-      "source": "$02A5",
+      "description": "UpdateScrollColumn - Mise \u00e0 jour du scroll colonne",
+      "source": "$0040",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$0F09",
+      "address": "$236D",
       "node_type": "code",
-      "description": "State22_ScrollCutscene - Scroll cutscene",
+      "description": "State0D_GameplayFull - Gameplay avec objets",
       "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$0F2A",
+      "address": "$23F8",
       "node_type": "code",
-      "description": "State23_WalkToDoor - Marche vers porte",
-      "source": "$02A5",
+      "description": "UpdateAnimTiles - Mise \u00e0 jour des tiles anim\u00e9es",
+      "source": "$0040",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$0F61",
+      "address": "$3D61",
       "node_type": "code",
-      "description": "State24_DisplayText - Affichage texte",
-      "source": "$02A5",
+      "description": "UpdateLevelScore - Mise \u00e0 jour du score du niveau",
+      "source": "$0040",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$0FF4",
+      "address": "$3D8E",
       "node_type": "code",
-      "description": "State25_SpriteBlinkAnimation - Animation clignotante",
+      "description": "State12_EndLevelSetup - Setup fin de niveau",
       "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$104C",
+      "address": "$3DCE",
       "node_type": "code",
-      "description": "State26_PrincessRising - Princesse montante",
+      "description": "State13_DrawEndBorder - Dessin bordure fin",
       "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$1090",
+      "address": "$3E9E",
       "node_type": "code",
-      "description": "State27_PlayerOscillation - Oscillation joueur",
+      "description": "State16_CopyTilemapData - Copie donn\u00e9es tilemap",
       "source": "$02A5",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$110D",
+      "address": "$3F24",
       "node_type": "code",
-      "description": "State29_SetupEndScreen - Setup \u00e9cran fin",
-      "source": "$02A5",
+      "description": "UpdateScoreDisplay - Mise \u00e0 jour de l'affichage du score",
+      "source": "$0040",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$115C",
+      "address": "$47F2",
       "node_type": "code",
-      "description": "State2A_DisplayEndText - Affichage texte fin",
-      "source": "$02A5",
-      "bank": 0,
+      "description": "JoypadReadHandler",
+      "source": "GameLoop",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$118B",
+      "address": "$4823",
       "node_type": "code",
-      "description": "State2B_PrincessDescending - Princesse descendante",
-      "source": "$02A5",
-      "bank": 0,
+      "description": "AnimationHandler",
+      "source": "CallBank3Handler",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$11C7",
+      "address": "$5832",
       "node_type": "code",
-      "description": "State2C_SpriteOscillation - Oscillation sprite",
+      "description": "State14_Handler - (Bank 1, zone donn\u00e9es)",
       "source": "$02A5",
-      "bank": 0,
+      "bank": 1,
       "priority": 3
     },
     {
-      "address": "$1212",
+      "address": "$5835",
       "node_type": "code",
-      "description": "State2D_DisplayText2 - Affichage texte 2",
+      "description": "State15_Handler - (Bank 1, zone donn\u00e9es)",
       "source": "$02A5",
-      "bank": 0,
+      "bank": 1,
       "priority": 3
     },
     {
-      "address": "$124B",
+      "address": "$5838",
       "node_type": "code",
-      "description": "State2E_DuoAnimation - Animation duo",
+      "description": "State17_Handler - (Bank 1, zone donn\u00e9es)",
       "source": "$02A5",
-      "bank": 0,
+      "bank": 1,
       "priority": 3
     },
     {
-      "address": "$1298",
+      "address": "$583B",
       "node_type": "code",
-      "description": "State2F_TransferSpriteData - Transfert donn\u00e9es sprite",
+      "description": "State18_Handler - (Bank 1, zone donn\u00e9es)",
       "source": "$02A5",
-      "bank": 0,
+      "bank": 1,
       "priority": 3
     },
     {
-      "address": "$12B9",
+      "address": "$583E",
       "node_type": "code",
-      "description": "State30_WalkLeft - Marche gauche",
+      "description": "State19_Handler - (Bank 1, zone donn\u00e9es)",
       "source": "$02A5",
-      "bank": 0,
+      "bank": 1,
       "priority": 3
     },
     {
-      "address": "$12E8",
+      "address": "$5841",
       "node_type": "code",
-      "description": "State31_HorizontalScroll - Scroll horizontal",
+      "description": "State1A_Handler - (Bank 1, zone donn\u00e9es)",
       "source": "$02A5",
-      "bank": 0,
+      "bank": 1,
       "priority": 3
     },
     {
-      "address": "$1385",
+      "address": "$7FF0",
       "node_type": "code",
-      "description": "State32_CreditsScroll - Scroll cr\u00e9dits",
-      "source": "$02A5",
-      "bank": 0,
+      "description": "AudioEntryPoint - Routine audio principale en bank 3",
+      "source": "$0050",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$13E7",
+      "address": "$7FF3",
       "node_type": "code",
-      "description": "State33_DisplayCreditsText - Affichage texte cr\u00e9dits",
-      "source": "$02A5",
-      "bank": 0,
+      "description": "ROM_INIT_BANK3 - Routine d'initialisation en bank 3",
+      "source": "$0185",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$1438",
-      "node_type": "code",
-      "description": "State34_WaitCreditsCounter - Attente compteur cr\u00e9dits",
-      "source": "$02A5",
+      "address": "$C0A5",
+      "node_type": "data",
+      "description": "wGameConfigA5 - mode handler (0=normal, !=0=retour)",
+      "source": "$0095",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$1451",
-      "node_type": "code",
-      "description": "State35_WaitTimer - Attente timer",
-      "source": "$02A5",
+      "address": "$C0AD",
+      "node_type": "data",
+      "description": "wPlayerVarAD - flag animation termin\u00e9e (FLAG_ANIM_DONE)",
+      "source": "$0095",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$145D",
-      "node_type": "code",
-      "description": "State36_CreditsFinalTransition - Transition finale cr\u00e9dits",
-      "source": "$02A5",
+      "address": "$C0DE",
+      "node_type": "data",
+      "description": "wAudioSaveDE - flag scroll Y actif",
+      "source": "$0095",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$147F",
-      "node_type": "code",
-      "description": "State37_FinalSpriteAnimation - Animation sprite finale",
-      "source": "$02A5",
+      "address": "$C0DF",
+      "node_type": "data",
+      "description": "wLevelInitFlag - valeur scroll Y \u00e0 appliquer",
+      "source": "$0095",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$14D3",
-      "node_type": "code",
-      "description": "State38_CreditsAnimation - Animation cr\u00e9dits",
-      "source": "$02A5",
+      "address": "$FFA4",
+      "node_type": "data",
+      "description": "hShadowSCX - shadow register pour effets raster",
+      "source": "$0095",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$1C73",
-      "node_type": "code",
-      "description": "State39_GameOver - Game Over",
-      "source": "$02A5",
+      "address": "$FFB3",
+      "node_type": "data",
+      "description": "hGameState - \u00e9tat du jeu (check GAME_STATE_WINDOW=$3A)",
+      "source": "$0095",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$1CDF",
+      "address": "$FFB6",
       "node_type": "code",
-      "description": "State3A_Handler - 4 bytes avant State3A_WindowUpdate",
-      "source": "$02A5",
+      "description": "hDmaRoutine - Routine DMA OAM copi\u00e9e en HRAM",
+      "source": "$0040",
       "bank": 0,
       "priority": 3
     },
     {
-      "address": "$1CDB",
-      "node_type": "code",
-      "description": "State3B_WindowSetup - Setup window",
-      "source": "$02A5",
+      "address": "$FFFB",
+      "node_type": "data",
+      "description": "hOAMIndex - index OAM pour animation",
+      "source": "$0095",
       "bank": 0,
       "priority": 3
+    },
+    {
+      "address": "$5179",
+      "node_type": "data",
+      "description": "Map data niveau 5",
+      "source": "$4000:1",
+      "bank": 1,
+      "priority": 3
+    },
+    {
+      "address": "$5222",
+      "node_type": "data",
+      "description": "Entities data niveau 5",
+      "source": "$4000:1",
+      "bank": 1,
+      "priority": 3
+    },
+    {
+      "address": "$529B",
+      "node_type": "data",
+      "description": "Tileset data niveau 6",
+      "source": "$4000:1",
+      "bank": 1,
+      "priority": 3
+    },
+    {
+      "address": "$5311",
+      "node_type": "data",
+      "description": "Map/Entities data partag\u00e9e niveaux 4,6,7",
+      "source": "$4000:1",
+      "bank": 1,
+      "priority": 3
+    },
+    {
+      "address": "$5405",
+      "node_type": "data",
+      "description": "Entities data partag\u00e9e niveaux 4,6,7",
+      "source": "$4000:1",
+      "bank": 1,
+      "priority": 3
+    },
+    {
+      "address": "$54D5",
+      "node_type": "data",
+      "description": "Tileset data partag\u00e9e niveaux 5,7,8",
+      "source": "$4000:1",
+      "bank": 1,
+      "priority": 3
+    },
+    {
+      "address": "$55BB",
+      "node_type": "data",
+      "description": "Tileset data partag\u00e9e niveaux 0-2,4",
+      "source": "$4000:1",
+      "bank": 1,
+      "priority": 3
+    },
+    {
+      "address": "$55E2",
+      "node_type": "data",
+      "description": "Map data partag\u00e9e niveaux 0-2",
+      "source": "$4000:1",
+      "bank": 1,
+      "priority": 3
+    },
+    {
+      "address": "$5605",
+      "node_type": "data",
+      "description": "Entities data partag\u00e9e niveaux 0-2",
+      "source": "$4000:1",
+      "bank": 1,
+      "priority": 3
+    },
+    {
+      "address": "$5630",
+      "node_type": "data",
+      "description": "Tileset data niveau 3",
+      "source": "$4000:1",
+      "bank": 1,
+      "priority": 3
+    },
+    {
+      "address": "$5665",
+      "node_type": "data",
+      "description": "Map data niveau 3",
+      "source": "$4000:1",
+      "bank": 1,
+      "priority": 3
+    },
+    {
+      "address": "$5694",
+      "node_type": "data",
+      "description": "Entities data niveau 3",
+      "source": "$4000:1",
+      "bank": 1,
+      "priority": 3
     }
   ],
   "visited": [
+    "$0185",
     "$0060",
-    "$0040",
     "$0100",
+    "$0050",
+    "$0028",
+    "$02A5",
+    "$4000:1",
     "$0226",
+    "$0048",
     "$0000",
-    "$0028",
     "$0095",
-    "$02A5",
-    "$0050",
-    "$0185",
-    "$0048"
+    "$0040"
   ],
-  "commits_since_push": 0,
-  "total_explored": 11
+  "commits_since_push": 1,
+  "total_explored": 12
 }
\ No newline at end of file
diff --git a/src/bank_001.asm b/src/bank_001.asm
index a28952c..d46a45f 100644
--- a/src/bank_001.asm
+++ b/src/bank_001.asm
@@ -1,50 +1,33 @@
 SECTION "ROM Bank $001", ROMX[$4000], BANK[$1]
 
-    cp e
-    ld d, l
-    ldh [c], a
-    ld d, l
-    dec b
-    ld d, [hl]
-    cp e
-    ld d, l
-    ldh [c], a
-    ld d, l
-    dec b
-    ld d, [hl]
-    cp e
-    ld d, l
-    ldh [c], a
-    ld d, l
-    dec b
-    ld d, [hl]
-    jr nc, PreprocessData_406a
-
-    ld h, l
-    ld d, [hl]
-    sub h
-    ld d, [hl]
-    cp e
-    ld d, l
-    ld de, $0553
-    ld d, h
-    push de
-    ld d, h
-    ld a, c
-    ld d, c
-    ld [hl+], a
-    ld d, d
-    sbc e
-    ld d, d
-    ld de, $0553
-    ld d, h
-    push de
-    ld d, h
-    ld de, $0553
-    ld d, h
-    push de
-    ld d, h
-    rrca
+; LevelJumpTable
+; ----------------
+; Description: Table des pointeurs pour chaque niveau (triplets: tileset/map/entities)
+; Structure: Chaque niveau utilise 3 pointeurs (6 octets)
+;   - +0: Pointeur tileset
+;   - +2: Pointeur map data
+;   - +4: Pointeur entities
+LevelJumpTable:
+    ; Niveau 0
+    dw $55BB, $55E2, $5605
+    ; Niveau 1
+    dw $55BB, $55E2, $5605
+    ; Niveau 2
+    dw $55BB, $55E2, $5605
+    ; Niveau 3
+    dw $5630, $5665, $5694
+    ; Niveau 4
+    dw $55BB, $5311, $5405
+    ; Niveau 5
+    dw $54D5, $5179, $5222
+    ; Niveau 6
+    dw $529B, $5311, $5405
+    ; Niveau 7
+    dw $54D5, $5311, $5405
+    ; Niveau 8 (incomplet)
+    dw $54D5
+
+    rrca  ; $4032 - octet isolé (possiblement marqueur de fin de table)
 
 CalculateOffset_4033:
     rrca

</DiffGit>

Tes réflexions produites dans la production finale. Ces commenentaires ont été coupés.
<ReflexionAgent>

│ Je vais analyser le nœud à l'adresse $0150 (AfterHeader).
│ Le code à l'adresse $0150 (AfterHeader) est déjà bien documenté. Il s'agit d'un simple saut vers Sys
│ Parfait. SystemInit est à l'adresse $0185. Je vais maintenant vérifier que le code AfterHeader suit 
│ Le code est déjà bien commenté avec le format de documentation existant du projet. Cependant, je vai
│ Maintenant je vérifie que la compilation produit le même hash.
│   "summary": "Point d'entrée après header ROM, saute directement vers SystemInit pour initialiser le
│ }
│ ```

</ReflexionAgent>

Je veux que tu améliores le [fichier des conseils](../recommendations.md) en y insérant :
- des critiques sur le prompt initial
- des pistes d'améliorations
- les découvertes que tu pourrais faire

Dans ce meme fichier, je souhaite que tu établisses une note de réalisation pour cette étape