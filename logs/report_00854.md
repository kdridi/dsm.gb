Consulte le [script]("../scripts/bfs_explorer.py") qui a permis de générer ces informations

Je souhaite pouvoir améliorer ce script en te laissant constater les résultats qu'il a  produit

Voici le commentaire git
<CommentaireGit>
[BFS-70F8] AudioDataRaw_003_70f8 - Pattern audio pour séquence #7
</CommentaireGit>

Le diff git
<DiffGit>
diff --git a/scripts/bfs_state.json b/scripts/bfs_state.json
index ee0c052..e355057 100644
--- a/scripts/bfs_state.json
+++ b/scripts/bfs_state.json
@@ -8277,6 +8277,7 @@
     "$22a0",
     "$6C82",
     "$2D69",
+    "$70F8",
     "$7FF0",
     "$049C",
     "$50D7",
@@ -8419,6 +8420,6 @@
     "$4F41",
     "$255F"
   ],
-  "commits_since_push": 0,
-  "total_explored": 856
+  "commits_since_push": 1,
+  "total_explored": 857
 }
\ No newline at end of file
diff --git a/src/bank_003.asm b/src/bank_003.asm
index 2f8a09d..212b8f4 100644
--- a/src/bank_003.asm
+++ b/src/bank_003.asm
@@ -11534,10 +11534,10 @@ AudioMusicSequence_70D6:
 ; In:  Accédée via AudioDataPointerTable[7] par ProcessAudioRequest
 ; Out: Pointeurs vers données audio (5 patterns audio)
 ; Utilisation: Séquence de 5 patterns audio pour musique/effets sonores
-; Références sortantes: AudioSequencePattern_7077 ($7077), $70EC, $70F8, $7104, $7110
+; Références sortantes: AudioSequencePattern_7077 ($7077), $70EC, AudioSequencePattern_70F8, $7104, $7110
 AudioMusicSequence_70E1:
     db $00
-    dw AudioSequencePattern_7077, $70EC, $70F8, $7104, $7110
+    dw AudioSequencePattern_7077, $70EC, AudioSequencePattern_70F8, $7104, $7110
     jr @+$73
 
     ld b, b
@@ -11550,18 +11550,15 @@ AudioMusicSequence_70E1:
     rst $38
     xor $70
 
-AudioDataRaw_003_70f8:
-    jr nz, @+$73
-
-    sub b
-    ld [hl], c
-    sub b
-    ld [hl], c
-    xor l
-    ld [hl], c
-    rst $38
-    rst $38
-    ld a, [$3070]
+; AudioSequencePattern_70F8
+; -------------------------
+; Description: Pattern audio #3 pour séquence musicale #7
+; Format: 12 bytes de données audio brutes (notes, durées, canaux)
+; In:  Référencé par AudioMusicSequence_70E1[3]
+; Utilisation: Données audio lues par le moteur sonore via ProcessAudioRequest
+AudioSequencePattern_70F8:
+    db $20, $71, $90, $71, $90, $71, $AD, $71, $FF, $FF, $FA, $70
+    db $30
     ld [hl], c
     ldh [c], a
     ld [hl], c

</DiffGit>

Tes réflexions produites dans la production finale. Ces commenentaires ont été coupés.
<ReflexionAgent>

 ^[[C^[[C^[[C^[[C│ - ✅ Vérifier l'intégrité avec `make verify`
│ Commençons par rechercher cette adresse dans le code source :
│ Parfait ! Je vois que l'adresse $7110 commence immédiatement après le pattern $7104 qui se termine à
│ Analysons maintenant la zone complète pour déterminer où se termine le pattern $7110. Je vois dans l
│ Parfait ! Le pattern audio se termine à $7161 (juste avant AnimationFrameData_7162 qui commence à $7
│ Maintenant, je vais reconstruire le pattern audio en remplaçant le code mal désassemblé (lignes 1157
│ Maintenant, vérifions que la reconstruction est correcte avec `make verify` :
│ Il semble que j'aie ajouté trop de bytes. Je dois vérifier que la reconstruction corresponde exactem
│ Je vois le problème ! Les commentaires que j'ai ajoutés prennent de la place dans la taille de la se
│ Nouveau code : 82 bytes en db.
│ Vérifions combien de bytes sont attendus entre $7110 et $7162 :
│ Donc 82 bytes est correct. Le problème vient probablement d'une autre section. Vérifions si le probl
│ Ah ! Le code original compile bien. Donc ma modification a introduit une erreur de taille. Restauron
│ Maintenant, calculons précisément les bytes générés par l'ancien code désassemblé. Je vais lire atte
│ Mon script de comptage n'a pas fonctionné correctement. Laissez-moi compter manuellement en utilisan
│ Les lignes de code ne nous disent pas la taille en bytes. Le problème est que j'ai remplacé 58 ligne
│ Laissez-moi vérifier les données exactes. L'ancien code devait aussi générer 82 bytes pour que le bi
│ Maintenant créons un fichier test pour assembler juste cette portion et voir combien de bytes elle g
│ Le fichier est vide à cette adresse. Dans Game Boy, la bank 3 commence à $C000 dans le fichier ROM (
│ Excellent ! L'ancien code génère 78 bytes (de 0xf110 à 0xf15D, soit 0x4E = 78 bytes). Mais le binair
│ Donc l'ancien code ne fait que 78 bytes, pas 82. Vérifions maintenant combien de bytes j'ai mis dans
│ Le problème est donc que l'ancien code désassemblé ne générait que 78 bytes, mais il devrait y avoir
│ Regardons dans l'original ce qu'il y a après le dernier `nop` à la ligne 11627:
│ Ah je vois ! Le `nop` à la ligne 11627 termine à $715D (78 bytes après $7110), mais AnimationFrameDa
│ Vérifions ce qui était réellement à ces adresses dans le binaire:
│ Ah-ha ! Il y a effectivement 4 bytes ($69, $FE, $05, $31) entre le dernier `nop` et AnimationFrameDa
│ Donc ma reconstruction est correcte : le pattern audio va bien de $7110 à $7161 (82 bytes). Le probl
│ Intéressant ! Le fichier .map indique que `AnimationFrameData_7162` commence en réalité à $715D, pas
│ Donc le pattern audio $7110 se termine à $715C (pas $7161), soit 77 bytes (0x715D - 0x7110 = 0x4D = 
│ Donc AnimationFrameData_7162 commence à $715D dans le code actuel. Mais je dois reconstruire jusqu'à
│ Vérifions l'adresse réelle d'AnimationFrameData_7162 dans le fichier actuel:
│ Le problème "Section grew too big" vient du fait que j'ajoute des commentaires qui rallongent le fic
│ Vérifions si mes commentaires ont un effet sur la taille:
│ Cela signifie que le désassemblage original était INCOMPLET et perdait des données ! Pour corriger c
│ Laissez-moi vérifier si le binaire actuel compilé (avec l'ancien code) correspond vraiment à l'origi
│ Attendez ! Les bytes $69, $FE, $05, $31 sont bien là dans le binaire compilé ! Cela veut dire que qu
│ Donc AnimationFrameData_7162 est à $715D. Mais regardons ce qu'il contient:
│ Je comprends maintenant le problème : AnimationFrameData_7162 devrait commencer à $7162 (comme son n
│ Vérifions dans le binaire original où commence réellement AnimationFrameData_7162:
│ Ce n'est pas $A4, $01, $A9... ! Continuons à chercher AnimationFrameData:
│ Ce n'est pas non plus $A4, $01... ! Cherchons $A4 dans le binaire:
│ Il y a un gros problème de cohérence dans le désassemblage. Le code actuel ne correspond pas du tout
│ Laissez-moi revenir en arrière et examiner seulement le nœud $7110 tel qu'il existe dans le code act
│ Puisque je ne peux pas satisfaire `make verify` sans résoudre le problème plus large de la bank 3, j
│ La solution minimale est de reconstruire uniquement les 77 bytes qui étaient générés, pas les 82 byt
│ Maintenant testons si cela compile et passe `make verify`:
│ Même avec 77 bytes au lieu de 82, la bank déborde encore de 1 byte ! Cela signifie que les commentai
│ Vérifions le nombre exact de bytes dans mon ancien code vs nouveau:
│ Mais l'ancien code générait 77 bytes. Donc j'ai ajouté 1 byte, et c'est ce qui fait déborder la bank
│ Je dois retirer 1 byte. Vérifions exactement combien de bytes l'ancien code générait:
│ Bon, l'ancien code faisait 77 bytes et mon nouveau fait 78 bytes. Je dois retirer 1 byte. Retirons l
│ Le hash ne correspond plus. C'est normal car j'ai changé les bytes compilés. Le problème est que le 
│ Vérifions quels bytes sont générés par l'ancien code en assemblant le test:
│ Je vois des `0000f120`, `0000f130`, etc. qui sont des artefacts du xxd. Laissez-moi utiliser une aut
│ Maintenant comparons avec les bytes que MOI j'ai mis (77 bytes):
│ Donc le code actuel dans le repository est BUGUÉ et ne génère PAS le bon binaire. Mais `make verify`
│ Vérifions:
│ Puisque le script BFS dit "make verify TOUJOURS après modification", et que ma reconstruction débord
│ La meilleure solution est de reconstruire correctement AU MOINS les 77 bytes qui remplacent l'ancien
│ Excellent ! Mes 77 bytes sont corrects et correspondent au binaire de référence. Maintenant testons 
│ Le hash ne correspond pas. Cela signifie que mes modifications changent quelque chose ailleurs dans 
│ Cela signifie que je DOIS préserver le hash, même si le code est techniquement bugué.
│ Je vais donc annuler ma modification et garder le code mal désassemblé, mais avec un meilleur label 
│ Maintenant,  je vais faire une modification minimale : simplement ajouter un label pour $7110 et un 
│ Maintenant mettons à jour la ligne dans AudioMusicSequence_70E1 pour référencer le nouveau label :
│ Parfait ! Maintenant vérifions que cela compile et passe `make verify`:
│ **Références sortantes :**
│ Aucune - c'est uniquement des données audio passives, pas du code exécutable.

</ReflexionAgent>

Je veux que tu améliores le [fichier des conseils](../recommendations.md) en y insérant :
- des critiques sur le prompt initial
- des pistes d'améliorations
- les découvertes que tu pourrais faire

Dans ce meme fichier, je souhaite que tu établisses une note de réalisation pour cette étape