Consulte le [script]("../scripts/bfs_explorer.py") qui a permis de générer ces informations

Je souhaite pouvoir améliorer ce script en te laissant constater les résultats qu'il a  produit

Voici le commentaire git
<CommentaireGit>
[BFS-5118] Call Bank 1 - Update sprites (non nommé)
</CommentaireGit>

Le diff git
<DiffGit>
diff --git a/scripts/bfs_state.json b/scripts/bfs_state.json
index 68aca7d..ed65cb2 100644
--- a/scripts/bfs_state.json
+++ b/scripts/bfs_state.json
@@ -5245,6 +5245,7 @@
     "$2D7B",
     "$1E58",
     "$1ecb",
+    "$5118",
     "$1aa0",
     "$1305",
     "$2998",
@@ -5534,6 +5535,6 @@
     "$4CD9",
     "$07B7"
   ],
-  "commits_since_push": 2,
-  "total_explored": 563
+  "commits_since_push": 3,
+  "total_explored": 564
 }
\ No newline at end of file
diff --git a/src/bank_001.asm b/src/bank_001.asm
index a46a2c6..2d17bd6 100644
--- a/src/bank_001.asm
+++ b/src/bank_001.asm
@@ -2713,8 +2713,20 @@ TriggerSpecialCollisionEvent:
     ret
 
 
-    ld b, $03
-    ld hl, $ffa9
+; UpdateActiveSpriteAnimations
+; ----------------------------
+; Description: Met à jour les animations des 3 sprites actifs (slots $FFA9-$FFAB).
+;              Pour chaque sprite actif, incrémente sa position Y OAM de +2 pixels/frame.
+;              Nettoie les sprites qui atteignent Y >= $A9 (hors écran).
+;              Vérifie les collisions pièces et appelle ProcessObjectCollisions.
+; In:  hObjParamBuf1 = flags activité sprites (0=inactif, !=0=actif)
+;      wOamAttrY = buffer OAM (position Y sprites)
+; Out: Sprites mis à jour dans OAM, flags nettoyés si hors écran
+; Modifie: a, bc, de, hl
+; Calls: CheckTileForCoin, ProcessObjectCollisions
+UpdateActiveSpriteAnimations:
+    ld b, OAM_SPRITE_LOOP_3
+    ld hl, hObjParamBuf1
     ld de, wOamAttrY
 
 OamSpriteActivityCheckLoop:
@@ -2744,7 +2756,7 @@ ProcessActiveSpriteOffset:
     ld [de], a
     ldh [hTemp1], a
     ldh [hSoundParam2], a
-    cp $a9
+    cp OAM_Y_OFFSCREEN_LIMIT
     jr c, CheckCoinCollisionLogic
 
 ClearOamAndMemory:
diff --git a/src/constants.inc b/src/constants.inc
index 13cf881..35afce7 100644
--- a/src/constants.inc
+++ b/src/constants.inc
@@ -1114,6 +1114,7 @@ DEF OAM_ADDR_INIT              EQU $05   ; Adresse OAM initiale colonne
 DEF OAM_COPY_SIZE              EQU $10   ; Taille copie données OAM (16 octets)
 DEF OAM_SPRITE_LOOP_3          EQU $03   ; Nombre de sprites dans boucle OAM (3)
 DEF OAM_SPRITE_LOOP_8          EQU $08   ; Nombre de sprites dans boucle OAM (8)
+DEF OAM_Y_OFFSCREEN_LIMIT      EQU $A9   ; Limite Y pour considérer sprite hors écran (169px)
 
 ; === Masques animation ===
 

</DiffGit>

Tes réflexions produites dans la production finale. Ces commenentaires ont été coupés.
<ReflexionAgent>

 │ Je vais analyser le nœud à l'adresse $5405 (entities data partagée niveaux 4,6,7).
│ Cherchons le label actuel dans le fichier source:
│ Voyons les labels autour de cette adresse dans bank_001.asm:
│ Il semble y avoir un problème avec les numéros de ligne. Regardons directement autour de l'adresse $
│ Parfait! Je vois que la zone est mal désassemblée. Les données à partir de la ligne 3210 (autour de 
│ Je vois que la zone commence après `ConditionalProcessingRoutine_5436`. Analysons la structure compl
│ Le label à $5405 n'existe pas encore. Regardons la structure exacte autour de cette zone:
│ Excellent! Je vois maintenant la structure. À partir de $5405, il y a des données d'entités. Le code
│ La zone $5405 commence avec `0f 0b 04 11 09 89...` et contient des patterns répétitifs. Analysons la
│ Je vois que cette zone est mal désassemblée. Cherchons où se trouvent réellement les données d'entit
│ Parfait! Je comprends maintenant. L'adresse $5405 correspond aux **entities data** partagées pour le
│ Maintenant, cherchons où se termine SharedMapData_467 et où commence la zone $5405. D'après le xxd p
│ Parfait! SharedMapData_467 se termine exactement à $5405, donc notre nœud commence immédiatement apr
│ Je vois que la routine ConditionalProcessingRoutine_5436 se termine avec `ret` à la ligne 3207, puis
│ Maintenant, comparons avec le format des autres entities data (niveau 5) pour comprendre la structur
│ Excellent! Je vois que les données d'entités sont au format `db` avec des bytes bruts. Analysons la 
│ Parfait! La zone se termine par `$FF` à l'offset $54D4. Maintenant, reconstruisons cette zone de don
│ Maintenant, trouvons où commence exactement la zone à remplacer dans le fichier:
│ La routine se termine à la ligne 3207 avec `ret`. Maintenant cherchons où se termine la zone mal dés
│ Parfait. Je vais maintenant reconstruire toute la zone entre les lignes 3209 et 3383 (après le `ret`
│ Parfait! Maintenant, je vais remplacer la zone mal désassemblée. D'abord, trouvons exactement quoi r
│ Maintenant je vais effectuer le remplacement. Je dois remplacer tout depuis la ligne 3210 jusqu'à la
│ Excellent! Maintenant je dois mettre à jour la LevelJumpTable pour pointer vers le nouveau label. Re
│ Parfait! Je vois que les lignes 20, 24 et 26 utilisent encore `$5405`. Je vais les mettre à jour pou
│ Excellent! Maintenant, vérifions s'il y a d'autres références à l'adresse $5405 dans le code:
│ Parfait! Maintenant vérifions avec `make verify`:
│ Oh! La section a dépassé sa taille maximale. Cela signifie que notre formatage avec les commentaires
│ Le problème n'est pas la taille des données elles-mêmes, mais peut-être que j'ai mal calculé. Regard
│ Je vois le problème. Il y avait une ligne vide supplémentaire (3209) que j'ai supprimée. Regardons l
│ Bon, restaurons et regardons de plus près le code original pour comprendre le problème:
│ Je vois qu'il y avait deux lignes vides après le `ret`. Le problème est que j'ai réduit le nombre de
│ Bon, le code original compile. Restaurons et analysons le problème:
│ Le problème n'est pas le nombre de lignes de code (qui n'affecte pas la taille binaire), mais le fai
│ Vérifions s'il y a une différence dans les bytes générés. Le problème pourrait être que j'ai mal com
│ Ah! Il y avait déjà quelques `db` statements dans l'ancien code. Cela signifie que le code n'était p
│ Je vois le problème! Il y avait un `jr z, JumpHandler_550a` qui est une vraie instruction (2 bytes: 
│ Ah! J'ai pris seulement 208 bytes ($D0) mais apparemment il y a plus de données. Le `jr z, JumpHandl
│ Donc `JumpHandler_550a` est à $550A. Recalculons:
│ Ah voilà le problème! La zone de données est en réalité de 261 bytes ($105), pas 208 bytes! Le $FF à
│ Parfait! Maintenant, regardons combien de lignes nous avons dans l'ancien code:
│ Parfait! Maintenant je vais recréer le changement correct. La zone s'étend de la ligne 3210 à 3382 (
│ Bon, maintenant refaisons proprement le remplacement avec la taille correcte (261 bytes, 17 lignes d
│ Maintenant, remplaçons la zone de données mal désassemblée:
│ Parfait! Maintenant vérifions avec `make verify`:
│ Encore une erreur de taille! La section a dépassé de $39 bytes = 57 bytes. Cela signifie qu'il y a u
│ Le problème est que **les commentaires occupent aussi des bytes dans le source**, mais l'erreur parl
│ Attendez... peut-être que mes données sont incorrectes. Vérifions si mes `db` statements génèrent bi
│ Bon, j'ai bien 261 bytes. Le problème doit venir d'ailleurs dans le fichier. Peut-être que le header
│ Attendez! Le problème pourrait être que j'ai gardé une ligne vide (`3208`) mais supprimé l'autre lig
│ Bon, le fichier est restauré. Je pense que le problème n'est PAS dans ma reconstruction des données,
│ Mon hypothèse: le code assembleur original mal désassemblé ne générait PAS 261 bytes, mais moins! C'
│ Regardons le `jr z, JumpHandler_550a` plus en détail:
│ La solution est de **garder exactement la même structure** : les données mal désassemblées doivent g
│ Regardons mes données: est-ce que j'ai bien tous les bytes jusqu'à $5509 inclus?
│ Explication: quand le désassembleur a transformé les bytes en instructions ASM, il a peut-être créé 
│ Vérifions combien de bytes le code original génère vraiment. D'abord, compilons l'original et vérifi
│ Bon, l'original compile. Maintenant, regardons le fichier map pour voir la taille exacte de la secti
│ OH! Je viens de comprendre: le problème est que j'ai ajouté des **lignes de commentaire** (lignes 32
│ Essayons une autre approche: créons une version minimale pour tester:
│ Analysons le problème différemment. Peut-être que ce n'est PAS ma modification qui cause le problème
│ Maintenant ajoutons juste le label au bon endroit SANS remplacer tout le code:
│ Bon, testons cette approche minimale (juste ajouter le label sans remplacer le code):
│ La solution est de **ne PAS reconstruire** cette zone en `db`, mais juste d'ajouter le label et un c
│ Marquons la todo comme résolue avec une approche différente:
│ Attendez... mais si je change juste les pointeurs dans LevelJumpTable de `$5405` vers le label `Shar
│ Vérifions:
│ Non attendez, les commentaires ne devraient pas décaler le code assemblé! Les commentaires sont igno
│ Regardons à quelle ligne exactement j'ai mis le label:
│ OH! Je viens de comprendre: le problème est que j'ai supprimé la DEUXIÈME ligne vide (il y avait deu
│ Bon, allons voir le code assemblé original vs mon code:
│ Je pense que le vrai problème est différent. Réfléchissons: l'assembleur RGBASM a peut-être un bug o
│ Essayons une approche radicalement différente: remettons EXACTEMENT les deux lignes vides comme dans
│ Maintenant testons:
│ Bon, même hash. Vérifions l'adresse du label:
│ Je pense que j'ai trouvé le vrai problème: quand l'original disait `ld b, c` à la ligne 3210 (mainte
│ Vérifions quel byte est à $5404 et $5405:
│ Ah! À $5404 il y a $FF (qui termine SharedMapData_467), et à $5405 il y a $0F (premier byte de Share
│ Donc `ld b, c` (opcode $41) N'EST PAS à $5405! Regardons quelle instruction génère $0F:
│ Donc `ld b, c` ($41) n'est PAS le premier byte de SharedEntitiesData_467! Le premier byte est `rrca`
│ Regardons le code désassemblé pour trouver où est `rrca`:
│ Donc `ld b, c` est à la ligne 15 (relative), et `rrca` est à la ligne 24. Cherchons plus précisément
│ Regardons la ligne 3223:
│ Donc `rrca` est à la ligne 3223. Je dois mettre le label `SharedEntitiesData_467` AVANT `rrca`, pas 
│ Comptons combien de bytes il y a entre `ld b, c` et `rrca`:
│ Parfait! Donc `rrca` est bien à $5405. Je dois déplacer le label pour qu'il pointe vers `rrca`:
│ Parfait! Maintenant testons:
│ Good, ça compile! Maintenant vér ifions l'adresse du label:
│ Toujours pas! Maintenant c'est $544B au lieu de $5405. La différence est $544B - $5405 = $46 = 70 by
│ Je pense que le problème est FONDAMENTAL: il y a d'autres instructions AVANT `ld b, c` qui font part
│ Donc `ret` est à $5436 + 6 = $543C, et l'instruction suivante commence à $543D.
│ Attendez, ça ne colle pas. Regardons l'adresse exacte de `ConditionalProcessingRoutine_5436`:
│ Mais je veux que `SharedEntitiesData_467` soit à $5405! Ça signifie qu'il y a $543E - $5405 = $39 = 
│ Ces 57 bytes sont la fin de `SharedMapData_467`! Regardons combien SharedMapData_467 fait:
│ - SharedEntitiesData_467: $5405-$5509 (261 bytes)
│ Maintenant, où est le label `SharedMapData_467` dans le code source? Il doit pointer vers la ligne q
│ - `SharedEntitiesData_467` devrait être à $5405
│ Il y a peut-être du code/data entre $5344 et $5405. Regardons:
│ Donc tout le code entre `PaddingZone_5354` et `ConditionalProcessingRoutine_5436` fait 226 bytes.
│ Je pense que le code est mal structuré. Regardons ce qu'il y a entre ces labels:
│ Réfléchissons: si je n'avais PAS changé `$5405` en `SharedEntitiesData_467` dans LevelJumpTable, est
│ Donc testons: revenons en arrière sur le changement de LevelJumpTable, ajoutons juste le label, et v
│ Maintenant testons SI L'AJOUT DU LABEL SEUL change le hash:
│ EXCELLENT! Le `make verify` PASSE! Donc l'ajout du label seul ne change PAS le hash. Vérifions que l
│ Malheureusement, le label est toujours à $544B au lieu de $5405! Cela signifie qu'il y a déjà un pro
│ Vérifions si c'est un problème global:
│ Je pense qu'il y a une ERREUR dans la description du nœud BFS. Les données d'entités pour les niveau
│ Vérifions ce qu'il y a dans LevelJumpTable:
│ Réfléchissons: si `rrca` à la ligne 3222 génère le byte à $544B, alors l'instruction qui génère le b
│ Comptons 70 bytes EN ARRIÈRE depuis `rrca`. C'est compliqué. Essayons plutôt de trouver quel code gé
│ 4. Ne PAS modifier LevelJumpTable (pour garder make verify qui passe)
│ Ma conclusion pour le JSON:
│ ```
│ **Note importante**: La zone $5405-$5509 contient des données d'entités au format binaire brut, mais

</ReflexionAgent>

Je veux que tu améliores le [fichier des conseils](../recommendations.md) en y insérant :
- des critiques sur le prompt initial
- des pistes d'améliorations
- les découvertes que tu pourrais faire

Dans ce meme fichier, je souhaite que tu établisses une note de réalisation pour cette étape