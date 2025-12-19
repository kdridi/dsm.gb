Consulte le [script]("../scripts/bfs_explorer.py") qui a permis de générer ces informations

Je souhaite pouvoir améliorer ce script en te laissant constater les résultats qu'il a  produit

Voici le commentaire git
<CommentaireGit>
[BFS-70E1] Audio/music sequence data (index 7)
</CommentaireGit>

Le diff git
<DiffGit>
diff --git a/scripts/bfs_state.json b/scripts/bfs_state.json
index e1b5c4b..72fafc2 100644
--- a/scripts/bfs_state.json
+++ b/scripts/bfs_state.json
@@ -7527,6 +7527,38 @@
       "source": "$0095",
       "bank": 0,
       "priority": 3
+    },
+    {
+      "address": "$70EC",
+      "node_type": "data",
+      "description": "Donn\u00e9es audio non labellis\u00e9es - Pattern audio pour s\u00e9quence #7",
+      "source": "$70E1",
+      "bank": 3,
+      "priority": 3
+    },
+    {
+      "address": "$70F8",
+      "node_type": "data",
+      "description": "AudioDataRaw_003_70f8 - Pattern audio pour s\u00e9quence #7",
+      "source": "$70E1",
+      "bank": 3,
+      "priority": 3
+    },
+    {
+      "address": "$7104",
+      "node_type": "data",
+      "description": "Donn\u00e9es audio non labellis\u00e9es - Pattern audio pour s\u00e9quence #7",
+      "source": "$70E1",
+      "bank": 3,
+      "priority": 3
+    },
+    {
+      "address": "$7110",
+      "node_type": "data",
+      "description": "Donn\u00e9es audio non labellis\u00e9es - Pattern audio pour s\u00e9quence #7",
+      "source": "$70E1",
+      "bank": 3,
+      "priority": 3
     }
   ],
   "visited": [
@@ -7738,6 +7770,7 @@
     "$1A62",
     "$6A58",
     "$22CD",
+    "$70E1",
     "$4DDF",
     "$4CE1",
     "$2D55",
@@ -8385,6 +8418,6 @@
     "$4F41",
     "$255F"
   ],
-  "commits_since_push": 3,
-  "total_explored": 854
+  "commits_since_push": 4,
+  "total_explored": 855
 }
\ No newline at end of file
diff --git a/src/bank_003.asm b/src/bank_003.asm
index 7d82f70..2f8a09d 100644
--- a/src/bank_003.asm
+++ b/src/bank_003.asm
@@ -11526,16 +11526,18 @@ AudioMusicSequence_70CB:
 AudioMusicSequence_70D6:
     db $00
     dw AudioPatternData_7062, $77D2, $77DC, $77E6, $77F2
-    nop
-    ld [hl], a
-    ld [hl], b
-    db $ec
-    ld [hl], b
-    ld hl, sp+$70
-    inc b
-    ld [hl], c
-    db $10
-    ld [hl], c
+
+; AudioMusicSequence_70E1
+; ------------------------
+; Description: Séquence musicale #7 - Liste de pointeurs vers patterns/notes audio
+; Format: [index_byte] [dw ptr1, dw ptr2, dw ptr3, dw ptr4, dw ptr5]
+; In:  Accédée via AudioDataPointerTable[7] par ProcessAudioRequest
+; Out: Pointeurs vers données audio (5 patterns audio)
+; Utilisation: Séquence de 5 patterns audio pour musique/effets sonores
+; Références sortantes: AudioSequencePattern_7077 ($7077), $70EC, $70F8, $7104, $7110
+AudioMusicSequence_70E1:
+    db $00
+    dw AudioSequencePattern_7077, $70EC, $70F8, $7104, $7110
     jr @+$73
 
     ld b, b

</DiffGit>

Tes réflexions produites dans la production finale. Ces commenentaires ont été coupés.
<ReflexionAgent>

 ^[[C^[[C^[[C^[[C│ ## Point clé à adresser
│ Identifier le format des données audio brutes à $70F8, comprendre leur structure et leurs références
│ Parfait ! Je vois que cette zone est mal désassemblée. Les données brutes montrent clairement un pat
│ Je dois regarder où se termine ce pattern. Vérifions les données suivantes et le prochain label:
│ Je vois que $7104 est le prochain pattern. Donc de $70F8 à $7103 inclus, soit 12 bytes (0x0C). Vérif
│ Parfait, 12 bytes de données. Maintenant je vais reconstruire cette zone mal désassemblée:
│ Maintenant je dois aussi mettre à jour la référence dans AudioMusicSequence_70E1:
│ Vérifions maintenant avec `make verify`:
│ J'ai une erreur. Vérifions les bytes exactement:
│ Je vois l'erreur. J'ai mal lu les bytes. Les vraies valeurs sont: `E2 FD 67 FE 02 32 67 41 82 75 67 
│ J'ai probablement supprimé trop de code. Laisse-moi regarder exactement ce qui se trouve après les 1
│ Je vois le problème. J'ai supprimé du code qui devait rester. Laisse-moi regarder le fichier origina
│ Je vois. J'ai remplacé 10 lignes de code par 1 ligne db, mais je n'aurais dû remplacer que ces 10 li
│ Il y a une différence de 1 byte. Vérifions à nouveau les données brutes pour être sûr de la bonne ta
│ Attendez, je vois maintenant `6D 6D 6B` après mes 12 bytes. Vérifions où commence réellement $7104:
│ Parfait, donc 12 bytes est correct. Le problème est que j'ai supprimé trop de lignes. Analysons l'or
│ Laissez-moi revenir à l'état original et recalculer correctement:
│ Laissez-moi analyser ça méthodiquement. Je dois mapper chaque instruction ASM à ses bytes:
│ Wait! Le premier byte est $E2, pas $20! Donc "jr nz, @+$73" ne correspond PAS à $70F8. Il y a quelqu
│ Maintenant je vois! À $70F8 commence vraiment `E2 FD 67...`. Le "jr nz, @+$73" est mal placé dans le
│ Ah! À $70E1, on a `6D` pas `00`. Le fichier actuel a peut-être déjà été modifié? Vérifions ce que di
│ Je vois le problème! Le code source dit `db $00` à $70E1, mais le binaire contient `$6D`. Il y a une
│ Excellent! Le code actuel passe make verify. Donc le binaire src/game.gb que j'ai examiné est celui 
│ Je vois! Le code après la table `dw...` n'est PAS du code exécutable mais du DATA qui continue. Le d
│ OK, donc les lignes 11541-11551 sont aussi du code mal désassemblé qui se trouve ENTRE $70EC (la fin
│ Maintenant, concentrons-nous uniquement sur AudioDataRaw_003_70f8 qui commence à la ligne 11553. Je 
│ PARFAIT! Maintenant je comprends. Le désassemblage actuel est complètement faux. Ce ne sont pas des 
│ Maintenant, mettre à jour la référence dans la table:
│ Maintenant validons avec make verify:
│ Il y a toujours une erreur. J'ai remplacé 10 lignes par 1, ce qui change la taille. Vérifions combie
│ Le problème est que jr nz a une cible relative. Essayons avec l'offset correct:
│ Laissez-moi regarder attentivement la structure. La ligne 11554 dit "jr nz, @+$73" et la ligne 11555
│ Vérifions combien de lignes je dois remplacer exactement:
│ Ah! Je vois que les lignes 11561+ sont toujours là! Cela signifie qu'elles appartiennent probablemen
│ Donc mon remplacement semble correct. Pourtant `make verify` échoue. Laissez-moi vérifier ce qui est
│ Parfait! Les bytes à $70F8 sont corrects: `E2 FD 67 FE 02 32 67 41 82 75 67 67` (mes 12 bytes), puis
│ Mais `make verify` échoue. Cela signifie que j'ai probablement cassé quelque chose d'autre. Laissez-
│ Le diff montre que j'ai remplacé 10 lignes (ligne vide incluse) par 1 ligne `db`. C'est une réductio
│ Laissez-moi restaurer et refaire plus prudemment:
│ Maintenant, analysons exactement ce qui doit être dans le db. Regardons bien la ligne vide - elle po
│ Il n'y a rien généré car ma cible label n'existe pas. Essayons avec un vrai label:
│ Ça ne fonctionne pas. Essayons autrement - créons un petit test direct:
│ TOTAL = 13 bytes, pas 12!
│ Mais je dois avoir 12 bytes de $70F8 à $7103. Donc quelque chose ne colle pas. Peut-être que le désa
│ Bon, le label est bien à $70F8 maintenant (après ma dernière compilation). Mais regardons ce qu'il y
│ OK donc l'original est bon. "No local changes to save" signifie que mon git checkout a déjà restauré
│ Donc le label AudioDataRaw_003_70f8 est bien à $70F8. Maintenant vérifions ce que contient réellemen
│ 3. Mais je dois m'assurer que le `db` génère EXACTEMENT les mêmes 12 bytes
│ Essayons encore une fois, mais cette fois je vais vérifier byte par byte ce que produit le code actu
│ Cela signifie que le label est mal placé. Regardons où il devrait vraiment être. Si $70F8 contient E
│ Regardons ce qui précède:
│ Je vois "xor $70" à la ligne 11551. Calculons combien de bytes font tous ces codes depuis la fin de 
│ Je pense que le désassemblage est incorrect dans le fichier source, mais heureusement il y a un autr
│ Vérifions s'il y a plusieurs définitions du label:
│ Mais comment? "jr nz, @+$73" = "20 73", pas "E2 FD"!
│ Attends... peut-être que la ligne 11554 n'est PAS compilée? Peut-être qu'il y a un IF/ENDIF ou quelq
│ Je vois des `\n` normales. Rien de suspect. Maintenant je suis vraiment confus. Le code source conti
│ Laissez-moi créer un test simple pour compiler juste cette partie et voir ce qui est généré:
│ Hmm, des zéros. Peut-être que l'offset est ailleurs. Bank 3 commence à $C000 dans le binaire, donc $
│ Toujours des zéros. La ROM générée est peut-être incomplète. Essayons avec rgbfix:
│ 64K, donc ça couvre jusqu'à $FFFF. Vérifions Bank 3:
│ Revenons à l'essentiel: le binaire src/game.gb actuel passe make verify et contient les bytes E2 FD 
│ Laissez-moi chercher s'il y a des directives INCBIN dans le fichier:
│ Pas d'INCBIN. Bon, je vais simplement TESTER en recompilant et en vérifiant ce qui est à $70F8:
│ OH! Je viens de réaliser... Le désassemblage montré dans le fichier source n'est PEUT-ÊTRE PAS ce qu
│ Vérifions autour du label. Y a-t-il des directives IF/ENDIF, ou des commentaires multi-lignes?
│ Non attends, `xxd -s 0x70F8` lit à l'offset $70F8 dans le FICHIER, pas dans l'espace d'adressage Gam
│ Pour Bank 3 dans le fichier, je dois calculer: Bank 3 commence à l'offset 3 * 0x4000 = $C000 dans le
│ Mais alors, pourquoi `xxd -s 0x70F8` me donnait "E2 FD 67..."? C'est parce que l'offset $70F8 dans l
│ Vérifions ce qui est vraiment à Bank 1, adresse $70F8:
│ MAIS ATTENDEZ... Si le label AudioDataRaw_003_70f8 est dans Bank 3, et qu'il génère bien les bytes 2
│ Regardons le fichier .sym pour voir à quelle bank appartient ce label:
│ Et voilà mon erreur précédente: j'utilisais les bytes de Bank 1 au lieu de Bank 3!
│ Maintenant, vérifions le bon pattern. Bank 3, $70F8, 12 bytes:
│ Le vrai désassemblage de "20 71" serait "jr nz, +$71" (sauter en avant de 113 bytes).
│ Bref, peu importe, ce sont des données. Remplaçons par un db avec les 12 bons bytes:
│ J'ai toujours un problème. Laissez-moi vérifier les bytes générés:
│ Parfait! Les 12 premiers bytes sont corrects: `20 71 90 71 90 71 AD 71 FF FF FA 70`. 
│ Mais le hash est différent. Cela signifie que j'ai changé autre chose. Probablement que j'ai supprim
│ Ah! Le problème est que "ld a, [$3070]" = 3 bytes (FA 70 30), mais je n'en ai inclus que 2 dans mon 
│ Attendez, mais je veux 12 bytes de données, pas 13. Vérifions où se termine vraiment le pattern. $70
│ Dans l'original, "ld a, [$3070]" générerait `FA 70 30` (3 bytes). Mais je n'en veux que 2 dans mon p
│ Vérifions la ligne après "ld a, [$3070]" dans l'original:
│ - FA 70 (data pattern #3) + 30 (début pattern #4??)
│ Non wait, regardons où commence le pattern #4 ($7104):
│ Mais alors la ligne "ld [hl], c" après "ld a, [$3070]" ne devrait pas être là dans le pattern #3. El
│ Regardons ce qui vient après mon db:
│ La solution simple: ajouter $30 comme premier byte du code qui suit. Mais ce code est probablement a
│ Pour l'instant, vérifions ce que l'original (git HEAD) génère à $F104:
│ Mais pour l'instant, concentrons-nous sur le pattern #3. Je vais juste m'assurer que le byte $30 est
│ En fait, regardons le code original pour voir comment il gère ce byte:
│ Ou plus simplement: ajouter "db $30" juste avant "ld [hl], c".
│ Essayons:
│   "summary": "Pattern audio de 12 bytes pour la séquence musicale #7, correctement reconstruit depui
│ }
│ ```

</ReflexionAgent>

Je veux que tu améliores le [fichier des conseils](../recommendations.md) en y insérant :
- des critiques sur le prompt initial
- des pistes d'améliorations
- les découvertes que tu pourrais faire

Dans ce meme fichier, je souhaite que tu établisses une note de réalisation pour cette étape