Consulte le [script]("../scripts/bfs_explorer.py") qui a permis de générer ces informations

Je souhaite pouvoir améliorer ce script en te laissant constater les résultats qu'il a  produit

Voici le commentaire git
<CommentaireGit>
[BFS-44FF] Animation frame structure
</CommentaireGit>

Le diff git
<DiffGit>
diff --git a/scripts/bfs_state.json b/scripts/bfs_state.json
index 7ad95ca..e0142d1 100644
--- a/scripts/bfs_state.json
+++ b/scripts/bfs_state.json
@@ -3504,6 +3504,14 @@
       "bank": 1,
       "priority": 3
     },
+    {
+      "address": "$44FF",
+      "node_type": "data",
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
+      "priority": 3
+    },
     {
       "address": "$47F2",
       "node_type": "code",
@@ -3665,487 +3673,423 @@
       "priority": 3
     },
     {
-      "address": "$4E74",
-      "node_type": "code",
-      "description": "Level 4-7 handler 1",
-      "source": "$4000:3",
+      "address": "$4C8D",
+      "node_type": "data",
+      "description": "Animation frame structure",
+      "source": "$4C37",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$4F1D",
-      "node_type": "code",
-      "description": "Level 4-7 handler 2",
-      "source": "$4000:3",
+      "address": "$4C91",
+      "node_type": "data",
+      "description": "Animation frame structure",
+      "source": "$4C37",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$4F41",
-      "node_type": "code",
-      "description": "Saut conditionnel vers PaddingZone_003_4f41",
-      "source": "$4F1D",
+      "address": "$4C95",
+      "node_type": "data",
+      "description": "Animation frame structure",
+      "source": "$4C37",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$4FB2",
-      "node_type": "code",
-      "description": "Call Bank 1 - Update level (non nomm\u00e9)",
-      "source": "$236D",
-      "bank": 1,
+      "address": "$4C99",
+      "node_type": "data",
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$4FD8",
-      "node_type": "code",
-      "description": "Level 4-7 handler 3",
-      "source": "$4000:3",
+      "address": "$4C9D",
+      "node_type": "data",
+      "description": "Animation frame structure",
+      "source": "$4C37",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$4FEC",
-      "node_type": "code",
-      "description": "Call Bank 1 - Update objects (non nomm\u00e9)",
-      "source": "$236D",
-      "bank": 1,
+      "address": "$4CA1",
+      "node_type": "data",
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$4c37",
-      "node_type": "table",
-      "description": "AnimFramePointerTable - Table de pointeurs vers structures d'animation",
-      "source": "$4823",
+      "address": "$4CA5",
+      "node_type": "data",
+      "description": "Animation frame structure",
+      "source": "$4C37",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$5022",
-      "node_type": "code",
-      "description": "CheckSpriteCollisionSimple - V\u00e9rification collision simple bouton A",
-      "source": "$4FEC",
-      "bank": 1,
+      "address": "$4CA9",
+      "node_type": "data",
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$5034",
-      "node_type": "code",
-      "description": "HandleJoypadButtonB_CheckCollision - Gestion collision bouton B",
-      "source": "$4FEC",
-      "bank": 1,
+      "address": "$4CAD",
+      "node_type": "data",
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$503F",
-      "node_type": "code",
-      "description": "Level 0-3 handler 1 (probablement init)",
-      "source": "$4000:3",
+      "address": "$4CB1",
+      "node_type": "data",
+      "description": "Animation frame structure",
+      "source": "$4C37",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$5074",
-      "node_type": "code",
-      "description": "Level 0-3 handler 2 (probablement update)",
-      "source": "$4000:3",
+      "address": "$4CB5",
+      "node_type": "data",
+      "description": "Animation frame structure",
+      "source": "$4C37",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$509B",
-      "node_type": "code",
-      "description": "Level 0-3 handler 3 (probablement render)",
-      "source": "$4000:3",
+      "address": "$4CB9",
+      "node_type": "data",
+      "description": "Animation frame structure",
+      "source": "$4C37",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$50C0",
+      "address": "$4CBD",
       "node_type": "data",
-      "description": "Level 4 extra pointer (donn\u00e9es sp\u00e9cifiques?)",
-      "source": "$4000:3",
+      "description": "Animation frame structure",
+      "source": "$4C37",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$50CC",
-      "node_type": "code",
-      "description": "Helper function appel\u00e9e avec param\u00e8tre c=$08",
-      "source": "$4FD8",
+      "address": "$4CC1",
+      "node_type": "data",
+      "description": "Animation frame structure",
+      "source": "$4C37",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$5118",
-      "node_type": "code",
-      "description": "Call Bank 1 - Update sprites (non nomm\u00e9)",
-      "source": "$236D",
-      "bank": 1,
+      "address": "$4CC5",
+      "node_type": "data",
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$515E",
-      "node_type": "code",
-      "description": "Call Bank 1 - Final update (non nomm\u00e9)",
-      "source": "$236D",
-      "bank": 1,
+      "address": "$4CC9",
+      "node_type": "data",
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$5179",
+      "address": "$4CCD",
       "node_type": "data",
-      "description": "Map data niveau 5",
-      "source": "$4000:1",
-      "bank": 1,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$5222",
+      "address": "$4CD1",
       "node_type": "data",
-      "description": "Entities data niveau 5",
-      "source": "$4000:1",
-      "bank": 1,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$529B",
+      "address": "$4CD5",
       "node_type": "data",
-      "description": "Tileset data niveau 6",
-      "source": "$4000:1",
-      "bank": 1,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$5311",
+      "address": "$4CD9",
       "node_type": "data",
-      "description": "Map/Entities data partag\u00e9e niveaux 4,6,7",
-      "source": "$4000:1",
-      "bank": 1,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$5405",
+      "address": "$4CDD",
       "node_type": "data",
-      "description": "Entities data partag\u00e9e niveaux 4,6,7",
-      "source": "$4000:1",
-      "bank": 1,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$54D5",
+      "address": "$4CE1",
       "node_type": "data",
-      "description": "Tileset data partag\u00e9e niveaux 5,7,8",
-      "source": "$4000:1",
-      "bank": 1,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$55BB",
+      "address": "$4CE5",
       "node_type": "data",
-      "description": "Tileset data partag\u00e9e niveaux 0-2,4",
-      "source": "$4000:1",
-      "bank": 1,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$55E2",
+      "address": "$4CE9",
       "node_type": "data",
-      "description": "Map data partag\u00e9e niveaux 0-2",
-      "source": "$4000:1",
-      "bank": 1,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$5605",
+      "address": "$4CED",
       "node_type": "data",
-      "description": "Entities data partag\u00e9e niveaux 0-2",
-      "source": "$4000:1",
-      "bank": 1,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$5630",
+      "address": "$4CF1",
       "node_type": "data",
-      "description": "Tileset data niveau 3",
-      "source": "$4000:1",
-      "bank": 1,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$5665",
+      "address": "$4CF5",
       "node_type": "data",
-      "description": "Map data niveau 3",
-      "source": "$4000:1",
-      "bank": 1,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$5694",
+      "address": "$4CF9",
       "node_type": "data",
-      "description": "Entities data niveau 3",
-      "source": "$4000:1",
-      "bank": 1,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$5832",
-      "node_type": "code",
-      "description": "State14_Handler - (Bank 1, zone donn\u00e9es)",
-      "source": "$02A5",
-      "bank": 1,
+      "address": "$4CFD",
+      "node_type": "data",
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$5835",
-      "node_type": "code",
-      "description": "State15_Handler - (Bank 1, zone donn\u00e9es)",
-      "source": "$02A5",
-      "bank": 1,
-      "priority": 3
-    },
-    {
-      "address": "$5838",
-      "node_type": "code",
-      "description": "State17_Handler - (Bank 1, zone donn\u00e9es)",
-      "source": "$02A5",
-      "bank": 1,
-      "priority": 3
-    },
-    {
-      "address": "$583B",
-      "node_type": "code",
-      "description": "State18_Handler - (Bank 1, zone donn\u00e9es)",
-      "source": "$02A5",
-      "bank": 1,
-      "priority": 3
-    },
-    {
-      "address": "$583E",
-      "node_type": "code",
-      "description": "State19_Handler - (Bank 1, zone donn\u00e9es)",
-      "source": "$02A5",
-      "bank": 1,
-      "priority": 3
-    },
-    {
-      "address": "$5841",
-      "node_type": "code",
-      "description": "State1A_Handler - (Bank 1, zone donn\u00e9es)",
-      "source": "$02A5",
-      "bank": 1,
-      "priority": 3
-    },
-    {
-      "address": "$5844",
-      "node_type": "code",
-      "description": "UpdateGameTimersAndAnimation - Timers et anim (bank 2)",
-      "source": "$0610",
-      "bank": 2,
-      "priority": 3
-    },
-    {
-      "address": "$6190",
+      "address": "$4D01",
       "node_type": "data",
-      "description": "Donn\u00e9es niveau (variante A)",
-      "source": "$4000:2",
-      "bank": 2,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$6192",
+      "address": "$4D05",
       "node_type": "data",
-      "description": "Donn\u00e9es niveau (variante B)",
-      "source": "$4000:2",
-      "bank": 2,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$61B7",
+      "address": "$4D09",
       "node_type": "data",
-      "description": "Donn\u00e9es niveau (variante C)",
-      "source": "$4000:2",
-      "bank": 2,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$61DA",
+      "address": "$4D0D",
       "node_type": "data",
-      "description": "Donn\u00e9es niveau (variante D)",
-      "source": "$4000:2",
-      "bank": 2,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$651C",
+      "address": "$4D11",
       "node_type": "data",
-      "description": "ROM_TILEMAP_POINTERS_A - Table de pointeurs vers les tilemaps (bank 3)",
-      "source": "$22A0",
+      "description": "Animation frame structure",
+      "source": "$4C37",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$651c",
-      "node_type": "table",
-      "description": "ROM_TILEMAP_POINTERS_A - Table de pointeurs vers les donn\u00e9es de tilemap",
-      "source": "$22a0",
+      "address": "$4D15",
+      "node_type": "data",
+      "description": "Animation frame structure",
+      "source": "$4C37",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$6536",
-      "node_type": "table",
-      "description": "ROM_TILEMAP_POINTERS_B - Table de pointeurs vers tilemaps en bank 3",
-      "source": "$2318",
+      "address": "$4D19",
+      "node_type": "data",
+      "description": "Animation frame structure",
+      "source": "$4C37",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$6550",
+      "address": "$4D1D",
       "node_type": "data",
-      "description": "S\u00e9quence d'inputs d\u00e9mo pour bank 0",
-      "source": "$4AE4",
-      "bank": 0,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$65E0",
+      "address": "$4D21",
       "node_type": "data",
-      "description": "S\u00e9quence d'inputs d\u00e9mo pour bank 1",
-      "source": "$4AE4",
-      "bank": 1,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$6670",
+      "address": "$4D25",
       "node_type": "data",
-      "description": "S\u00e9quence d'inputs d\u00e9mo pour bank 2",
-      "source": "$4AE4",
-      "bank": 2,
-      "priority": 3
-    },
-    {
-      "address": "$7FF0",
-      "node_type": "code",
-      "description": "AudioEntryPoint - Routine audio principale en bank 3",
-      "source": "$0050",
+      "description": "Animation frame structure",
+      "source": "$4C37",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$7FF3",
-      "node_type": "code",
-      "description": "ROM_INIT_BANK3 - Routine d'initialisation en bank 3",
-      "source": "$0185",
+      "address": "$4D2C",
+      "node_type": "data",
+      "description": "Animation frame structure",
+      "source": "$4C37",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$C0A5",
+      "address": "$4D33",
       "node_type": "data",
-      "description": "wGameConfigA5 - mode handler (0=normal, !=0=retour)",
-      "source": "$0095",
-      "bank": 0,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$C0AD",
+      "address": "$4D3A",
       "node_type": "data",
-      "description": "wPlayerVarAD - flag animation termin\u00e9e (FLAG_ANIM_DONE)",
-      "source": "$0095",
-      "bank": 0,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$C0D2",
+      "address": "$4D41",
       "node_type": "data",
-      "description": "wCollisionFlag - Flag collision r\u00e9initialis\u00e9 \u00e0 0",
-      "source": "$0E8D",
-      "bank": 0,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$C0DE",
+      "address": "$4D48",
       "node_type": "data",
-      "description": "wAudioSaveDE - flag scroll Y actif",
-      "source": "$0095",
-      "bank": 0,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$C0DF",
+      "address": "$4D4F",
       "node_type": "data",
-      "description": "wLevelInitFlag - valeur scroll Y \u00e0 appliquer",
-      "source": "$0095",
-      "bank": 0,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$C207",
+      "address": "$4D56",
       "node_type": "data",
-      "description": "wPlayerUnk07 - Variable joueur $07 r\u00e9initialis\u00e9e \u00e0 0",
-      "source": "$0E8D",
-      "bank": 0,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$C600",
+      "address": "$4D5D",
       "node_type": "data",
-      "description": "wAnimBuffer - Buffer RAM pour frames d'animation custom",
-      "source": "$23F8",
-      "bank": 0,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$FFA4",
+      "address": "$4D61",
       "node_type": "data",
-      "description": "hShadowSCX - shadow register pour effets raster",
-      "source": "$0095",
-      "bank": 0,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$FFA6",
+      "address": "$4D68",
       "node_type": "data",
-      "description": "hTimer1 - Timer principal v\u00e9rifi\u00e9 pour attendre fin",
-      "source": "$0E8D",
-      "bank": 0,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$FFB3",
+      "address": "$4D6F",
       "node_type": "data",
-      "description": "hGameState - \u00e9tat du jeu (check GAME_STATE_WINDOW=$3A)",
-      "source": "$0095",
-      "bank": 0,
-      "priority": 3
-    },
-    {
-      "address": "$FFB6",
-      "node_type": "code",
-      "description": "hDmaRoutine - Routine DMA OAM copi\u00e9e en HRAM",
-      "source": "$0040",
-      "bank": 0,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$FFF9",
+      "address": "$4D76",
       "node_type": "data",
-      "description": "hVBlankMode - Mode VBlank activ\u00e9 (mis \u00e0 1)",
-      "source": "$0E8D",
-      "bank": 0,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$FFFB",
+      "address": "$4D7D",
       "node_type": "data",
-      "description": "hOAMIndex - index OAM pour animation",
-      "source": "$0095",
-      "bank": 0,
+      "description": "Animation frame structure",
+      "source": "$4C37",
+      "bank": 3,
       "priority": 3
     },
     {
-      "address": "$44FF",
+      "address": "$4D84",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4153,7 +4097,7 @@
       "priority": 3
     },
     {
-      "address": "$4C8D",
+      "address": "$4D8B",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4161,7 +4105,7 @@
       "priority": 3
     },
     {
-      "address": "$4C91",
+      "address": "$4D92",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4169,7 +4113,7 @@
       "priority": 3
     },
     {
-      "address": "$4C95",
+      "address": "$4D99",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4177,7 +4121,7 @@
       "priority": 3
     },
     {
-      "address": "$4C99",
+      "address": "$4DA0",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4185,7 +4129,7 @@
       "priority": 3
     },
     {
-      "address": "$4C9D",
+      "address": "$4DA7",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4193,7 +4137,7 @@
       "priority": 3
     },
     {
-      "address": "$4CA1",
+      "address": "$4DAE",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4201,7 +4145,7 @@
       "priority": 3
     },
     {
-      "address": "$4CA5",
+      "address": "$4DB5",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4209,7 +4153,7 @@
       "priority": 3
     },
     {
-      "address": "$4CA9",
+      "address": "$4DBC",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4217,7 +4161,7 @@
       "priority": 3
     },
     {
-      "address": "$4CAD",
+      "address": "$4DC3",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4225,7 +4169,7 @@
       "priority": 3
     },
     {
-      "address": "$4CB1",
+      "address": "$4DCA",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4233,7 +4177,7 @@
       "priority": 3
     },
     {
-      "address": "$4CB5",
+      "address": "$4DD1",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4241,7 +4185,7 @@
       "priority": 3
     },
     {
-      "address": "$4CB9",
+      "address": "$4DD8",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4249,7 +4193,7 @@
       "priority": 3
     },
     {
-      "address": "$4CBD",
+      "address": "$4DDF",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4257,7 +4201,7 @@
       "priority": 3
     },
     {
-      "address": "$4CC1",
+      "address": "$4DE6",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4265,7 +4209,7 @@
       "priority": 3
     },
     {
-      "address": "$4CC5",
+      "address": "$4DED",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4273,7 +4217,7 @@
       "priority": 3
     },
     {
-      "address": "$4CC9",
+      "address": "$4DF4",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4281,7 +4225,7 @@
       "priority": 3
     },
     {
-      "address": "$4CCD",
+      "address": "$4DFB",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4289,7 +4233,7 @@
       "priority": 3
     },
     {
-      "address": "$4CD1",
+      "address": "$4E02",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4297,7 +4241,7 @@
       "priority": 3
     },
     {
-      "address": "$4CD5",
+      "address": "$4E09",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4305,7 +4249,7 @@
       "priority": 3
     },
     {
-      "address": "$4CD9",
+      "address": "$4E14",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4313,7 +4257,7 @@
       "priority": 3
     },
     {
-      "address": "$4CDD",
+      "address": "$4E1F",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4321,7 +4265,7 @@
       "priority": 3
     },
     {
-      "address": "$4CE1",
+      "address": "$4E2A",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4329,7 +4273,7 @@
       "priority": 3
     },
     {
-      "address": "$4CE5",
+      "address": "$4E35",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4337,7 +4281,7 @@
       "priority": 3
     },
     {
-      "address": "$4CE9",
+      "address": "$4E44",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4345,263 +4289,319 @@
       "priority": 3
     },
     {
-      "address": "$4CED",
-      "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
+      "address": "$4E74",
+      "node_type": "code",
+      "description": "Level 4-7 handler 1",
+      "source": "$4000:3",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$4CF1",
-      "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
+      "address": "$4F1D",
+      "node_type": "code",
+      "description": "Level 4-7 handler 2",
+      "source": "$4000:3",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$4CF5",
-      "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
+      "address": "$4F41",
+      "node_type": "code",
+      "description": "Saut conditionnel vers PaddingZone_003_4f41",
+      "source": "$4F1D",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$4CF9",
-      "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "address": "$4FB2",
+      "node_type": "code",
+      "description": "Call Bank 1 - Update level (non nomm\u00e9)",
+      "source": "$236D",
+      "bank": 1,
       "priority": 3
     },
     {
-      "address": "$4CFD",
-      "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
+      "address": "$4FD8",
+      "node_type": "code",
+      "description": "Level 4-7 handler 3",
+      "source": "$4000:3",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$4D01",
-      "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "address": "$4FEC",
+      "node_type": "code",
+      "description": "Call Bank 1 - Update objects (non nomm\u00e9)",
+      "source": "$236D",
+      "bank": 1,
       "priority": 3
     },
     {
-      "address": "$4D05",
-      "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
+      "address": "$4c37",
+      "node_type": "table",
+      "description": "AnimFramePointerTable - Table de pointeurs vers structures d'animation",
+      "source": "$4823",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$4D09",
-      "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
+      "address": "$5022",
+      "node_type": "code",
+      "description": "CheckSpriteCollisionSimple - V\u00e9rification collision simple bouton A",
+      "source": "$4FEC",
+      "bank": 1,
+      "priority": 3
+    },
+    {
+      "address": "$5034",
+      "node_type": "code",
+      "description": "HandleJoypadButtonB_CheckCollision - Gestion collision bouton B",
+      "source": "$4FEC",
+      "bank": 1,
+      "priority": 3
+    },
+    {
+      "address": "$503F",
+      "node_type": "code",
+      "description": "Level 0-3 handler 1 (probablement init)",
+      "source": "$4000:3",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$4D0D",
-      "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
+      "address": "$5074",
+      "node_type": "code",
+      "description": "Level 0-3 handler 2 (probablement update)",
+      "source": "$4000:3",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$4D11",
-      "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
+      "address": "$509B",
+      "node_type": "code",
+      "description": "Level 0-3 handler 3 (probablement render)",
+      "source": "$4000:3",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$4D15",
+      "address": "$50C0",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
+      "description": "Level 4 extra pointer (donn\u00e9es sp\u00e9cifiques?)",
+      "source": "$4000:3",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$4D19",
-      "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
+      "address": "$50CC",
+      "node_type": "code",
+      "description": "Helper function appel\u00e9e avec param\u00e8tre c=$08",
+      "source": "$4FD8",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$4D1D",
+      "address": "$5118",
+      "node_type": "code",
+      "description": "Call Bank 1 - Update sprites (non nomm\u00e9)",
+      "source": "$236D",
+      "bank": 1,
+      "priority": 3
+    },
+    {
+      "address": "$515E",
+      "node_type": "code",
+      "description": "Call Bank 1 - Final update (non nomm\u00e9)",
+      "source": "$236D",
+      "bank": 1,
+      "priority": 3
+    },
+    {
+      "address": "$5179",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "Map data niveau 5",
+      "source": "$4000:1",
+      "bank": 1,
       "priority": 3
     },
     {
-      "address": "$4D21",
+      "address": "$5222",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "Entities data niveau 5",
+      "source": "$4000:1",
+      "bank": 1,
       "priority": 3
     },
     {
-      "address": "$4D25",
+      "address": "$529B",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "Tileset data niveau 6",
+      "source": "$4000:1",
+      "bank": 1,
       "priority": 3
     },
     {
-      "address": "$4D2C",
+      "address": "$5311",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "Map/Entities data partag\u00e9e niveaux 4,6,7",
+      "source": "$4000:1",
+      "bank": 1,
       "priority": 3
     },
     {
-      "address": "$4D33",
+      "address": "$5405",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "Entities data partag\u00e9e niveaux 4,6,7",
+      "source": "$4000:1",
+      "bank": 1,
       "priority": 3
     },
     {
-      "address": "$4D3A",
+      "address": "$54D5",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "Tileset data partag\u00e9e niveaux 5,7,8",
+      "source": "$4000:1",
+      "bank": 1,
       "priority": 3
     },
     {
-      "address": "$4D41",
+      "address": "$55BB",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "Tileset data partag\u00e9e niveaux 0-2,4",
+      "source": "$4000:1",
+      "bank": 1,
       "priority": 3
     },
     {
-      "address": "$4D48",
+      "address": "$55E2",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "Map data partag\u00e9e niveaux 0-2",
+      "source": "$4000:1",
+      "bank": 1,
       "priority": 3
     },
     {
-      "address": "$4D4F",
+      "address": "$5605",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "Entities data partag\u00e9e niveaux 0-2",
+      "source": "$4000:1",
+      "bank": 1,
       "priority": 3
     },
     {
-      "address": "$4D56",
+      "address": "$5630",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "Tileset data niveau 3",
+      "source": "$4000:1",
+      "bank": 1,
       "priority": 3
     },
     {
-      "address": "$4D5D",
+      "address": "$5665",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "Map data niveau 3",
+      "source": "$4000:1",
+      "bank": 1,
       "priority": 3
     },
     {
-      "address": "$4D61",
+      "address": "$5694",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "Entities data niveau 3",
+      "source": "$4000:1",
+      "bank": 1,
+      "priority": 3
+    },
+    {
+      "address": "$5832",
+      "node_type": "code",
+      "description": "State14_Handler - (Bank 1, zone donn\u00e9es)",
+      "source": "$02A5",
+      "bank": 1,
+      "priority": 3
+    },
+    {
+      "address": "$5835",
+      "node_type": "code",
+      "description": "State15_Handler - (Bank 1, zone donn\u00e9es)",
+      "source": "$02A5",
+      "bank": 1,
+      "priority": 3
+    },
+    {
+      "address": "$5838",
+      "node_type": "code",
+      "description": "State17_Handler - (Bank 1, zone donn\u00e9es)",
+      "source": "$02A5",
+      "bank": 1,
       "priority": 3
     },
     {
-      "address": "$4D68",
-      "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "address": "$583B",
+      "node_type": "code",
+      "description": "State18_Handler - (Bank 1, zone donn\u00e9es)",
+      "source": "$02A5",
+      "bank": 1,
       "priority": 3
     },
     {
-      "address": "$4D6F",
-      "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "address": "$583E",
+      "node_type": "code",
+      "description": "State19_Handler - (Bank 1, zone donn\u00e9es)",
+      "source": "$02A5",
+      "bank": 1,
       "priority": 3
     },
     {
-      "address": "$4D76",
-      "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "address": "$5841",
+      "node_type": "code",
+      "description": "State1A_Handler - (Bank 1, zone donn\u00e9es)",
+      "source": "$02A5",
+      "bank": 1,
       "priority": 3
     },
     {
-      "address": "$4D7D",
-      "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "address": "$5844",
+      "node_type": "code",
+      "description": "UpdateGameTimersAndAnimation - Timers et anim (bank 2)",
+      "source": "$0610",
+      "bank": 2,
       "priority": 3
     },
     {
-      "address": "$4D84",
+      "address": "$6190",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "Donn\u00e9es niveau (variante A)",
+      "source": "$4000:2",
+      "bank": 2,
       "priority": 3
     },
     {
-      "address": "$4D8B",
+      "address": "$6192",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "Donn\u00e9es niveau (variante B)",
+      "source": "$4000:2",
+      "bank": 2,
       "priority": 3
     },
     {
-      "address": "$4D92",
+      "address": "$61B7",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "Donn\u00e9es niveau (variante C)",
+      "source": "$4000:2",
+      "bank": 2,
       "priority": 3
     },
     {
-      "address": "$4D99",
+      "address": "$61DA",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "Donn\u00e9es niveau (variante D)",
+      "source": "$4000:2",
+      "bank": 2,
       "priority": 3
     },
     {
-      "address": "$4DA0",
+      "address": "$634E",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4609,7 +4609,7 @@
       "priority": 3
     },
     {
-      "address": "$4DA7",
+      "address": "$6463",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4617,39 +4617,39 @@
       "priority": 3
     },
     {
-      "address": "$4DAE",
+      "address": "$651C",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
+      "description": "ROM_TILEMAP_POINTERS_A - Table de pointeurs vers les tilemaps (bank 3)",
+      "source": "$22A0",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$4DB5",
-      "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
+      "address": "$651c",
+      "node_type": "table",
+      "description": "ROM_TILEMAP_POINTERS_A - Table de pointeurs vers les donn\u00e9es de tilemap",
+      "source": "$22a0",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$4DBC",
-      "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
+      "address": "$6536",
+      "node_type": "table",
+      "description": "ROM_TILEMAP_POINTERS_B - Table de pointeurs vers tilemaps en bank 3",
+      "source": "$2318",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$4DC3",
+      "address": "$6550",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "S\u00e9quence d'inputs d\u00e9mo pour bank 0",
+      "source": "$4AE4",
+      "bank": 0,
       "priority": 3
     },
     {
-      "address": "$4DCA",
+      "address": "$6564",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4657,15 +4657,15 @@
       "priority": 3
     },
     {
-      "address": "$4DD1",
+      "address": "$65E0",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "S\u00e9quence d'inputs d\u00e9mo pour bank 1",
+      "source": "$4AE4",
+      "bank": 1,
       "priority": 3
     },
     {
-      "address": "$4DD8",
+      "address": "$6665",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4673,15 +4673,15 @@
       "priority": 3
     },
     {
-      "address": "$4DDF",
+      "address": "$6670",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "S\u00e9quence d'inputs d\u00e9mo pour bank 2",
+      "source": "$4AE4",
+      "bank": 2,
       "priority": 3
     },
     {
-      "address": "$4DE6",
+      "address": "$704E",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4689,7 +4689,7 @@
       "priority": 3
     },
     {
-      "address": "$4DED",
+      "address": "$7170",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4697,7 +4697,7 @@
       "priority": 3
     },
     {
-      "address": "$4DF4",
+      "address": "$7372",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4705,7 +4705,7 @@
       "priority": 3
     },
     {
-      "address": "$4DFB",
+      "address": "$7471",
       "node_type": "data",
       "description": "Animation frame structure",
       "source": "$4C37",
@@ -4713,123 +4713,123 @@
       "priority": 3
     },
     {
-      "address": "$4E02",
-      "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
+      "address": "$7FF0",
+      "node_type": "code",
+      "description": "AudioEntryPoint - Routine audio principale en bank 3",
+      "source": "$0050",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$4E09",
-      "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
+      "address": "$7FF3",
+      "node_type": "code",
+      "description": "ROM_INIT_BANK3 - Routine d'initialisation en bank 3",
+      "source": "$0185",
       "bank": 3,
       "priority": 3
     },
     {
-      "address": "$4E14",
+      "address": "$C0A5",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "wGameConfigA5 - mode handler (0=normal, !=0=retour)",
+      "source": "$0095",
+      "bank": 0,
       "priority": 3
     },
     {
-      "address": "$4E1F",
+      "address": "$C0AD",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "wPlayerVarAD - flag animation termin\u00e9e (FLAG_ANIM_DONE)",
+      "source": "$0095",
+      "bank": 0,
       "priority": 3
     },
     {
-      "address": "$4E2A",
+      "address": "$C0D2",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "wCollisionFlag - Flag collision r\u00e9initialis\u00e9 \u00e0 0",
+      "source": "$0E8D",
+      "bank": 0,
       "priority": 3
     },
     {
-      "address": "$4E35",
+      "address": "$C0DE",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "wAudioSaveDE - flag scroll Y actif",
+      "source": "$0095",
+      "bank": 0,
       "priority": 3
     },
     {
-      "address": "$4E44",
+      "address": "$C0DF",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "wLevelInitFlag - valeur scroll Y \u00e0 appliquer",
+      "source": "$0095",
+      "bank": 0,
       "priority": 3
     },
     {
-      "address": "$634E",
+      "address": "$C207",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "wPlayerUnk07 - Variable joueur $07 r\u00e9initialis\u00e9e \u00e0 0",
+      "source": "$0E8D",
+      "bank": 0,
       "priority": 3
     },
     {
-      "address": "$6463",
+      "address": "$C600",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "wAnimBuffer - Buffer RAM pour frames d'animation custom",
+      "source": "$23F8",
+      "bank": 0,
       "priority": 3
     },
     {
-      "address": "$6564",
+      "address": "$FFA4",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "hShadowSCX - shadow register pour effets raster",
+      "source": "$0095",
+      "bank": 0,
       "priority": 3
     },
     {
-      "address": "$6665",
+      "address": "$FFA6",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "hTimer1 - Timer principal v\u00e9rifi\u00e9 pour attendre fin",
+      "source": "$0E8D",
+      "bank": 0,
       "priority": 3
     },
     {
-      "address": "$704E",
+      "address": "$FFB3",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "hGameState - \u00e9tat du jeu (check GAME_STATE_WINDOW=$3A)",
+      "source": "$0095",
+      "bank": 0,
       "priority": 3
     },
     {
-      "address": "$7170",
-      "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "address": "$FFB6",
+      "node_type": "code",
+      "description": "hDmaRoutine - Routine DMA OAM copi\u00e9e en HRAM",
+      "source": "$0040",
+      "bank": 0,
       "priority": 3
     },
     {
-      "address": "$7372",
+      "address": "$FFF9",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "hVBlankMode - Mode VBlank activ\u00e9 (mis \u00e0 1)",
+      "source": "$0E8D",
+      "bank": 0,
       "priority": 3
     },
     {
-      "address": "$7471",
+      "address": "$FFFB",
       "node_type": "data",
-      "description": "Animation frame structure",
-      "source": "$4C37",
-      "bank": 3,
+      "description": "hOAMIndex - index OAM pour animation",
+      "source": "$0095",
+      "bank": 0,
       "priority": 3
     }
   ],
@@ -4938,6 +4938,7 @@
     "$21f6",
     "$1983",
     "$2A5F",
+    "$44FF",
     "$1aa0",
     "$29F8",
     "$2AA4",
@@ -5300,6 +5301,6 @@
     "$236D",
     "$24e6"
   ],
-  "commits_since_push": 4,
-  "total_explored": 465
+  "commits_since_push": 0,
+  "total_explored": 466
 }
\ No newline at end of file
diff --git a/src/bank_003.asm b/src/bank_003.asm
index c502a8c..5faca97 100644
--- a/src/bank_003.asm
+++ b/src/bank_003.asm
@@ -1096,9 +1096,11 @@ PaddingZone_003_44a3:
     nop
     ld [$2000], sp
     nop
-    jr c, JoypadInputEntry_44c7
+    jr c, JoypadInputData_44c7
 
-JoypadInputEntry_44c7:
+; ZONE MAL DESASSEMBLEE: Table de données joypad (88 bytes, $44C7-$451E)
+; Note: $44FF pointe vers byte de donnée, pas du code
+JoypadInputData_44c7:
     ld e, $00
     rrca
     nop

</DiffGit>

Tes réflexions produites dans la production finale. Ces commenentaires ont été coupés.
<ReflexionAgent>

 │ Je vais analyser l'adresse $4CAD dans la bank 3.
│ Le label existe déjà. Voyons le contexte autour de cette adresse:
│ Je vois que $4CAD est référencé dans une table de pointeurs. Vérifions les adresses cibles:
│ Je vois la structure maintenant. Regardons le contexte pour comprendre comment sont utilisées ces fr
│ Excellent! Je comprends maintenant. Vérifions où est utilisée cette structure pour mieux la nommer:
│ Maintenant je comprends la structure complète. Vérifions si AnimFrame_4CAD a un commentaire appropri
│ - Second dw $4D61 : pointeur vers données de sprites
│ Vérifions le contenu de $4D61:
│ Le fichier .sym indique que l'adresse réelle est $4CAF (et non $4CAD). Vérifions:
│ Ah, il y a un décalage. Le fichier .sym indique $4CAF mais le BFS demande $4CAD. Vérifions l'origine
│ Je vois maintenant: les données brutes ne correspondent pas à ce qui est dans le .asm. Lisons attent
│ Regardons comment rgbasm calcule les adresses. Vérifions dans le fichier .asm:
│ Donc AnimFrame_4CAD est juste après AnimFrame_4CA9 + 4 octets (2 words). Cela donne $4CA9 + $04 = $4
│ Regardons maintenant si le label a besoin d'amélioration et vérifions les données pointées:
│ Les données à $4D61 semblent être mal désassemblées (dw $7170, $7372 ressemblent plus à des caractèr
│ Les données brutes montrent que $4D61 contient bien des données (pas du code). Le désassemblage actu
│ Bank 3 = offset fichier = $3 * $4000 = $C000
│ Adresse $4CAD en Bank 3 = offset $C000 + ($4CAD - $4000) = $C000 + $CAD = $CCAD
│ Erreur de ma part! Le format est little-endian. Je lis $5D4D = dw $4D5D et $FCFC = dw $FCFC. Mais da
│ - $4D61 : pointeur vers données sprites
│ Vérifions si cette structure est cohérente avec les autres frames:
│ ```
│ Il y a une incohérence! Vérifions AnimFrame_4CA9 dans le .asm:
│ Étrange. Vérifions make verify pour voir si le hash est bon actuellement:
│ Relisons maintenant AnimFrame_4CAD et vérifions le commentaire. Je note que AnimFrame_4CA9 a un comm
│ Analysons la structure pour mieux la documenter:
│ - Donc $FCFC = offset Y=-4, X=-4
│ Regardons maintenant $4D61 pour identifier le type de données sprites:
│ C'est aussi un AnimFrame. Regardons le contexte pour comprendre si c'est vraiment une structure d'an
│ Ces données semblent suspectes (dw $7170, $7372 = "pqrs"). Vérifions le binaire brut:
│ - $4D61: `44 4E 70 71 72 73 FF 44 4E 70 71 74 73 FF 44 4E`
│ Ceci ressemble à une séquence de commandes sprite (sprite data). Vérifions le contexte précédent pou
│ - $FF terminator
│ Regardons AnimFrame_4D5D pour comprendre:
│ Cependant, **ma mission BFS est d'analyser $4CAD**, pas de reconstruire toute la zone mal désassembl
│ Revenons à AnimFrame_4CAD. Ajoutons un commentaire descriptif:
│ Maintenant vérifions que make verify passe toujours:
│ - $4D61 : AnimFrame_4D61 (données sprites mal désassemblées)
│ Vérifions aussi s'il y a d'autres références à AnimFrame_4CAD:
│   "summary": "Structure d'animation avec offset Y/X (-4,-4) pointant vers données sprites"
│ }
│ ```

</ReflexionAgent>

Je veux que tu améliores le [fichier des conseils](../recommendations.md) en y insérant :
- des critiques sur le prompt initial
- des pistes d'améliorations
- les découvertes que tu pourrais faire

Dans ce meme fichier, je souhaite que tu établisses une note de réalisation pour cette étape