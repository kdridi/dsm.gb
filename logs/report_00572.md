Consulte le [script]("../scripts/bfs_explorer.py") qui a permis de générer ces informations

Je souhaite pouvoir améliorer ce script en te laissant constater les résultats qu'il a  produit

Voici le commentaire git
<CommentaireGit>
[BFS-5605] Entities data partagée niveaux 0-2
</CommentaireGit>

Le diff git
<DiffGit>
diff --git a/scripts/bfs_state.json b/scripts/bfs_state.json
index a34585e..d8bc71c 100644
--- a/scripts/bfs_state.json
+++ b/scripts/bfs_state.json
@@ -4752,6 +4752,30 @@
       "bank": 1,
       "priority": 3
     },
+    {
+      "address": "$5BA3",
+      "node_type": "data",
+      "description": "Tile data r\u00e9f\u00e9renc\u00e9e par map",
+      "source": "$55E2",
+      "bank": 1,
+      "priority": 3
+    },
+    {
+      "address": "$5C22",
+      "node_type": "data",
+      "description": "Tile data r\u00e9f\u00e9renc\u00e9e par map",
+      "source": "$55E2",
+      "bank": 1,
+      "priority": 3
+    },
+    {
+      "address": "$5CA6",
+      "node_type": "data",
+      "description": "Tile data r\u00e9f\u00e9renc\u00e9e par map",
+      "source": "$55E2",
+      "bank": 1,
+      "priority": 3
+    },
     {
       "address": "$5D32",
       "node_type": "data",
@@ -4760,6 +4784,38 @@
       "bank": 1,
       "priority": 3
     },
+    {
+      "address": "$5D8A",
+      "node_type": "data",
+      "description": "Tile data r\u00e9f\u00e9renc\u00e9e par map",
+      "source": "$55E2",
+      "bank": 1,
+      "priority": 3
+    },
+    {
+      "address": "$5E32",
+      "node_type": "data",
+      "description": "Tile data r\u00e9f\u00e9renc\u00e9e par map",
+      "source": "$55E2",
+      "bank": 1,
+      "priority": 3
+    },
+    {
+      "address": "$5F44",
+      "node_type": "data",
+      "description": "Tile data r\u00e9f\u00e9renc\u00e9e par map",
+      "source": "$55E2",
+      "bank": 1,
+      "priority": 3
+    },
+    {
+      "address": "$5FAD",
+      "node_type": "data",
+      "description": "Tile data r\u00e9f\u00e9renc\u00e9e par map",
+      "source": "$55E2",
+      "bank": 1,
+      "priority": 3
+    },
     {
       "address": "$6048",
       "node_type": "data",
@@ -5065,58 +5121,50 @@
       "priority": 3
     },
     {
-      "address": "$5BA3",
+      "address": "$6100",
       "node_type": "data",
-      "description": "Tile data r\u00e9f\u00e9renc\u00e9e par map",
-      "source": "$55E2",
+      "description": "Entity definition data",
+      "source": "$5605",
       "bank": 1,
       "priority": 3
     },
     {
-      "address": "$5C22",
+      "address": "$61B8",
       "node_type": "data",
-      "description": "Tile data r\u00e9f\u00e9renc\u00e9e par map",
-      "source": "$55E2",
+      "description": "Entity definition data",
+      "source": "$5605",
       "bank": 1,
       "priority": 3
     },
     {
-      "address": "$5CA6",
-      "node_type": "data",
-      "description": "Tile data r\u00e9f\u00e9renc\u00e9e par map",
-      "source": "$55E2",
-      "bank": 1,
-      "priority": 3
-    },
-    {
-      "address": "$5D8A",
+      "address": "$6272",
       "node_type": "data",
-      "description": "Tile data r\u00e9f\u00e9renc\u00e9e par map",
-      "source": "$55E2",
+      "description": "Entity definition data",
+      "source": "$5605",
       "bank": 1,
       "priority": 3
     },
     {
-      "address": "$5E32",
+      "address": "$6327",
       "node_type": "data",
-      "description": "Tile data r\u00e9f\u00e9renc\u00e9e par map",
-      "source": "$55E2",
+      "description": "Entity definition data",
+      "source": "$5605",
       "bank": 1,
       "priority": 3
     },
     {
-      "address": "$5F44",
+      "address": "$640D",
       "node_type": "data",
-      "description": "Tile data r\u00e9f\u00e9renc\u00e9e par map",
-      "source": "$55E2",
+      "description": "Entity definition data",
+      "source": "$5605",
       "bank": 1,
       "priority": 3
     },
     {
-      "address": "$5FAD",
+      "address": "$650D",
       "node_type": "data",
-      "description": "Tile data r\u00e9f\u00e9renc\u00e9e par map",
-      "source": "$55E2",
+      "description": "Entity definition data",
+      "source": "$5605",
       "bank": 1,
       "priority": 3
     }
@@ -5681,6 +5729,7 @@
     "$055F",
     "$2d2d",
     "$54D5",
+    "$5605",
     "$4E14",
     "$0a24",
     "$2a3b",
@@ -5697,6 +5746,6 @@
     "$4CD9",
     "$07B7"
   ],
-  "commits_since_push": 3,
-  "total_explored": 574
+  "commits_since_push": 4,
+  "total_explored": 575
 }
\ No newline at end of file
diff --git a/src/bank_001.asm b/src/bank_001.asm
index 02743e0..6233b31 100644
--- a/src/bank_001.asm
+++ b/src/bank_001.asm
@@ -9,11 +9,11 @@ SECTION "ROM Bank $001", ROMX[$4000], BANK[$1]
 ;   - +4: Pointeur entities
 LevelJumpTable:
     ; Niveau 0
-    dw SharedTilesetData_024, SharedMapData_012, $5605
+    dw SharedTilesetData_024, SharedMapData_012, SharedEntitiesData_012
     ; Niveau 1
-    dw SharedTilesetData_024, SharedMapData_012, $5605
+    dw SharedTilesetData_024, SharedMapData_012, SharedEntitiesData_012
     ; Niveau 2
-    dw SharedTilesetData_024, SharedMapData_012, $5605
+    dw SharedTilesetData_024, SharedMapData_012, SharedEntitiesData_012
     ; Niveau 3
     dw $5630, $5665, $5694
     ; Niveau 4
@@ -3397,47 +3397,21 @@ SharedMapData_012:
     dw $5E32, $5E32, $5E32, $5F44, $5F44, $5D32, $5FAD, $5CA6
     dw $5A5F
     db $FF  ; Terminateur
-    call $2756
-    ld h, e
-    daa
-    ld h, e
-    nop
-    ld h, c
-    cp b
-    ld h, c
-    ld [hl], d
-    ld h, d
-    cp b
-    ld h, c
-    nop
-    ld h, c
-    nop
-    ld h, c
-    ld [hl], d
-    ld h, d
-    ld [hl], d
-    ld h, d
-    cp b
-    ld h, c
-    daa
-    ld h, e
-    daa
-    ld h, e
-    ld [hl], d
-    ld h, d
-    ld [hl], d
-    ld h, d
-    nop
-    ld h, c
-    dec c
-    ld h, h
-    daa
-    ld h, e
-    daa
-    ld h, e
-    dec c
-    ld h, l
-    rst $38
+
+; ==============================================================================
+; SharedEntitiesData_012 - Entities data partagée niveaux 0-2 ($5605-$562F)
+; ==============================================================================
+; Description: Table de pointeurs vers les données d'entités pour niveaux 0, 1, 2
+; Format: Séquence de words (16-bit pointeurs vers entités), terminée par $FF
+;         - Chaque word pointe vers une définition d'entité (position/type)
+; Taille: 43 octets ($2B) - 21 words + terminateur
+; Référencé par: LevelJumpTable niveaux 0, 1, 2 (lignes 12, 14, 16)
+; ==============================================================================
+SharedEntitiesData_012:  ; $5605
+    dw $56CD, $6327, $6327, $6100, $61B8, $6272, $61B8, $6100
+    dw $6100, $6272, $6272, $61B8, $6327, $6327, $6272, $6272
+    dw $6100, $640D, $6327, $6327, $650D
+    db $FF  ; Terminateur
     add c
     ld l, h
     add c

</DiffGit>

Tes réflexions produites dans la production finale. Ces commenentaires ont été coupés.
<ReflexionAgent>

 │ Je vais analyser le nœud à l'adresse $5832 (State14_Handler) dans le fichier src/bank_001.asm.
│ L'adresse $5832 correspond à $4000 + $1832 = bank 1 offset $1832. Laissez-moi chercher dans le fichi
│ Les données brutes montrent des valeurs comme `31 31 31 31 5d fe f1...` qui semblent être des donnée
│ Je vois que le fichier commence à $4000. L'adresse $5832 correspond à l'offset $1832 dans la bank 1.
│ Je vais utiliser grep pour trouver les sections et naviguer plus efficacement:
│ Je vais calculer à quelle ligne environ se trouve l'adresse $5832:
│ Cherchons des labels proches de cet offset. $5832 - $4000 = $1832. Cherchons des adresses proches:
│ C'est proche! Regardons autour de la ligne 381:
│ Je vois que cette zone est mal désassemblée comme code (instructions incohérentes). Je vais chercher
│ Cherchons maintenant les labels avec "Level" ou des adresses dans la plage $58xx:
│ Parfait! Cherchons maintenant les adresses autour de $5832. L'offset $1832 correspond à quelque part
│ Continuons la lecture pour trouver la zone $5832:
│ Continuons pour atteindre la zone $5832:
│ Excellent! Je vois que la ligne 3782 contient `cp $4c` et ligne 3783 `ld h, b`. En regardant les don
│ Les données à $5832 correspondent aux lignes autour de 3800-3805. Cherchons les labels de cette sect
│ Pas de label spécifique. Cherchons tous les labels/sections dans une plus grande zone:
│ La zone $5832 est dans une section de données graphiques mal désassemblées, sans label spécifique. L
│ Maintenant, calculons précisément l'adresse. Ligne 3725 = TileGraphic_57EB ($57EB). Comptons les byt
│ Vérifions en lisant les commentaires au-dessus de cette section pour comprendre le contexte:
│ La zone va jusqu'à $574A, mais $5832 est au-delà. Cherchons s'il y a d'autres commentaires après $57
│ Bon, je vois le pattern. Cette zone après $574A continue à être des données mal désassemblées. Cherc
│ Maintenant cherchons s'il y a des références à cette adresse dans le code:
│ Excellent! L'adresse $5832 est référencée dans bank_000.asm comme "État $14". Lisons ce contexte:
│ Parfait! Je vois que $5832 est dans une table de pointeurs d'états (state handlers). C'est l'état $1
│ Regardons le contexte de cette table:
│ 2. C'est une adresse invalide/placeholder
│ Regardons les données brutes à cette adresse et aux adresses suivantes pour voir s'il y a un pattern
│ 4. Vérifier avec make verify
│ Commençons par créer un plan d'action:
│ Maintenant, regardons exactement où se trouve $5832 dans le fichier source pour créer un label appro
│ Parfait! La ligne 3801 correspond à $5832 environ. Je vais maintenant reconstruire cette zone propre
│ Maintenant, je vais extraire les données brutes et reconstruire proprement cette section. D'abord, d
│ Parfait! Je vois maintenant la structure complète. $5832 correspond à `31 31 5d fe f1` (à l'offset $
│ La zone continue à être mal désassemblée. Cherchons le prochain vrai label ou section:
│ Bon! PatternData_5a60 est le prochain label à la ligne 4211. Vérifions son adresse:
│ Parfait! PatternData_5a60 est à $5A60. Donc je dois reconstruire la zone $5754-$5A5F (environ lignes
│ Maintenant je vais modifier le fichier pour ajouter un label approprié et reconstruire cette petite 
│ - $5836: `5d fe` (opérande $FE5D)
│ OK, donc à $5832 commence bien une instruction `ld sp, $3131`. Je vais maintenant ajouter un label à
│ Maintenant, calculons précisément quelle ligne correspond à $5832. Je vais examiner autour de la lig
│ Attendez, il semble y avoir une erreur dans mon interprétation. Revérifions avec xxd:
│ Les états pointent effectivement au milieu d'un stream de bytes. C'est très inhabituel. Cela suggère
│ Pour l'instant, je vais simplement ajouter un label et un commentaire expliquant la situation. Trouv
│ Laissez-moi chercher la séquence de `ld sp, $3131` dans le fichier pour trouver la ligne précise:
│ - $5834: 5d
│ Mais xxd montre $582E = `63` puis 7x `31`. Vérifions:
│ - Instructions désassemblées: `ld sp,$3131` (31 31 31) + `ld sp,$5d31` (31 31 5d) = seulement 5 byte
│ Il y a une incohérence. Laissez-moi vérifier le source plus attentivement:
│ Exactement! Le désassembleur a mal interprété cette zone. C'est pour cela que nous devons la reconst
│ D'après mes calculs, $5832 est quelque part autour de la ligne 3819 (à ±1-2 lignes près). Je vais ma
│ Je dois d'abord lire le fichier:
│ Bon! Maintenant je dois aussi référencer ce nouveau label dans bank_000.asm. Lisons d'abord le fichi
│ Excellent! Maintenant je dois ajouter les labels pour les états $17, $18, $19, $1A dans bank_001.asm
│ Ajoutons les labels manquants. Ligne 3838 est `cp $e2`, qui est probablement State17. Continuons:
│ Parfait! Maintenant testons avec `make verify`:
│ Le hash est différent! Cela signifie que mon placement des labels a modifié le code généré. Les labe
│ Les données sont identiques à $5832, mais le hash global est différent. Cela signifie que quelque ch
│ 2. M'assurer que les labels pointent exactement vers les bonnes adresses
│ Vérifions d'abord si les labels générés pointent vers les bonnes adresses:
│ 2. Garder les adresses littérales
│ Annulons les changements:
│ 3. NE PAS casser le hash
│ La meilleure approche est d'ajouter un commentaire INLINE (sur la même ligne) plutôt que d'ajouter u
│ Je vais ajouter des labels INLINE sur les lignes existantes, sans ajouter de nouvelles lignes:
│ Parfait! Maintenant, testons le hash:
│ Excellent! Le hash est correct! Maintenant vérifions les adresses des symboles:
│ Les adresses sont encore décalées ($5868 au lieu de $5832). Le problème est que mes labels sont plac
│ Laissez-moi compter plus précisément depuis un point de référence connu. Repartons de TileGraphic_57
│ Regardons TileGraphic_57EB pour confirmer sa position:
│ Ah! TileGraphic_57EB est à $57EC (pas $57EB). Il y a un décalage d'1 byte. Peut-être un problème de 
│ Je n'ai compté que 27 bytes, il m'en faut 54. Il faut remonter encore. Cherchons plutôt dans les sym
│ TileGraphic_574A est à $574A. Calculons depuis ce point:
│ Puisque la zone est mal désassemblée, les labels ne peuvent pas pointer correctement sans reconstrui
│ Annulons mes changements actuels et ajoutons simplement une documentation au début de cette zone pro
│ Maintenant, ajoutons simplement un commentaire documentant la découverte sans déplacer de code:
│ Je vais ajouter une note dans le commentaire existant de la zone mal désassemblée ($56CB-$574A) pour
│ Parfait! Maintenant vérifions que le hash est toujours correct:
│ Excellent! Le hash est correct. Maintenant, mettons à jour nos todos et produisons le JSON de sortie
│    - Aucune référence sortante (c'est de la DATA, pas du CODE)
│ La tâche BFS pour ce nœud est terminée. Le hash a été vérifié et est correct.

</ReflexionAgent>

Je veux que tu améliores le [fichier des conseils](../recommendations.md) en y insérant :
- des critiques sur le prompt initial
- des pistes d'améliorations
- les découvertes que tu pourrais faire

Dans ce meme fichier, je souhaite que tu établisses une note de réalisation pour cette étape