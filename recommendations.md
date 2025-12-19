# Recommandations pour le script BFS Explorer

Ce document recense les critiques, améliorations et découvertes issues des sessions d'exploration automatisée.

---

## Rapport BFS-0095 : LCDStatHandler

### Note de realisation : 9/10

**Points positifs (+)**
- Le noeud `$0095` (LCDStatHandler) a ete correctement marque comme visite
- **10 references sortantes** ajoutees dans bfs_state.json - c'est excellent et bien au-dessus de la moyenne
- Les references couvrent des points d'entree publics (`$00C3`, `$00C7`, `$00CD`) et des variables HRAM/WRAM
- Nommage semantique des variables decouvertes :
  - `hShadowSCX` ($FFA4) - shadow register pour effets raster
  - `hGameState` ($FFB3) - etat du jeu
  - `hOAMIndex` ($FFFB) - index OAM pour animation
  - `wGameConfigA5` ($C0A5) - mode handler
  - `wAudioSaveDE`, `wLevelInitFlag`, `wPlayerVarAD` - flags de scroll/animation
- `make verify` a reussi - pas de regression
- Les reflexions montrent une analyse methodique du code :
  - Verification du contexte depuis bank_002
  - Identification des appels via table (ConstTableA_Entry9)
  - Production du JSON final (meme si coupe)

**Points negatifs (-)**
- Le JSON de sortie est coupe dans les reflexions (pattern recurrent)
- Pas de description du handler principal lui-meme (focus sur les points d'entree auxiliaires)
- Les reflexions sont un peu dispersees mais reviennent sur la cible

**Analyse**

Cette session est **la meilleure jusqu'ici** car :
1. L'agent a produit **10 references de qualite** avec des descriptions semantiques
2. Les noms de variables sont pertinents et suivent les conventions (`h` pour HRAM, `w` pour WRAM)
3. L'analyse a identifie la structure du handler avec plusieurs points d'entree publics :
   - `LCDStat_CheckCarryExit` ($00C3) - teste le carry flag
   - `LCDStat_SetLYC` ($00C7) - ecrit dans rLYC
   - `LCDStat_PopAndReti` ($00CD) - epilogue standard

**Decouverte architecturale** : Le LCDStatHandler n'est pas une simple routine mais un **systeme modulaire** avec plusieurs points d'entree appeles depuis des tables externes (bank_002). C'est un pattern sophistique pour les effets raster.

---

## Rapport BFS-0060 : VBlankHandler

### Note de realisation : 8/10

**Points positifs (+)**
- Le noeud `$0060` (VBlankHandler) a ete correctement marque comme visite
- Le bloc commentaire a ete reformate et enrichi avec le format standard (Description, In, Out, Modifie)
- La structure du handler est clairement documentee (7 etapes : Save → Update → DMA → Increment → Check → Reset → Restore)
- `make verify` a reussi - pas de regression
- L'ajout dans visited ($0060) est correct

**Points negatifs (-)**
- Les reflexions montrent une confusion sur `$0030` (JumpTableDispatcherContinue) alors que le noeud demande etait `$0060`
- L'analyse de RST $28 et du dispatcher de jump table est hors-sujet pour ce noeud
- Pas de references sortantes ajoutees dans bfs_state.json alors que le handler appelle plusieurs routines :
  - `$FFB6` (DMA routine en HRAM)
  - Potentiellement d'autres routines pour UpdateGameLogic
- Le JSON de sortie n'est pas visible (coupe)

**Analyse**

Cette session est **meilleure que les precedentes** car :
1. Le handler VBlankHandler a ete effectivement documente (pas seulement derive vers un autre noeud)
2. Le commentaire ajoute est de qualite et suit les conventions
3. La description structuree en 7 points est utile pour comprendre le flux

Cependant, le pattern de deviation persiste : l'agent a passe du temps sur `$0030` (JumpTableDispatcherContinue) au lieu de se concentrer uniquement sur `$0060`.

**Amelioration du format de commentaire**

Le nouveau format est plus lisible :
```asm
; VBlankHandler
; ----------------
; Description: ...
; In:  (aucun)
; Out: (aucun)
; Modifie: af, bc, de, hl...
```

C'est une amelioration par rapport au format precedent qui utilisait des blocs `;;` massifs.

---

## Rapport BFS-0100 : ROM Entry point

### Note de realisation : 5/10

**Points positifs (+)**
- Le noeud `$0100` a ete correctement marque comme visite
- La reference vers `$0150` (AfterHeader - jump intermediaire vers SystemInit) a ete identifiee
- `make verify` a reussi - pas de regression
- L'ajout dans bfs_state.json est correct avec la description appropriee

**Points negatifs (-)**
- Les reflexions montrent une deviation MAJEURE vers `$4000:3` (LevelJumpTable Bank 3) alors que le noeud demande etait `$0100`
- L'agent a passe ~100% de son temps a analyser une table de pointeurs de niveaux au lieu du ROM Entry point
- Pas de JSON de sortie visible dans les reflexions (coupe)
- Pas de bloc commentaire ajoute pour la routine `$0100` (le minimum attendu pour un point d'entree)
- L'analyse du ROM header ($0100-$014F) n'a pas ete faite

**Analyse du probleme recurrent**

C'est le **troisieme rapport consecutif** ou l'agent derive vers l'analyse de tables de niveaux au lieu du noeud demande :
- BFS-0048 : deviation vers LevelJumpTable Bank 1
- BFS-0050 : deviation vers LevelJumpTable Bank 2
- BFS-0100 : deviation vers LevelJumpTable Bank 3

Ce pattern suggere un probleme structurel dans le prompt ou le contexte fourni a l'agent.

**Hypotheses**
1. Le fichier source contient peut-etre ces tables pres du code demande, ce qui distrait l'agent
2. Le prompt ne "verrouille" pas assez le contexte sur le noeud specifique
3. L'agent cherche a "impressionner" en analysant des structures complexes plutot que des routines simples

---

## Rapport BFS-0050 : Timer interrupt vector

### Note de realisation : 7/10

**Points positifs (+)**
- Le vecteur d'interruption Timer a ete correctement documente avec le bloc commentaire standard
- Le format du commentaire est complet (Description, In, Out, Modifie, Note)
- La reference vers AudioEntryPoint ($7FF0, Bank 3) a ete correctement ajoutee dans bfs_state.json
- `make verify` a reussi - pas de regression
- L'ajout du noeud prioritaire audio dans la frontiere montre une bonne comprehension du flux

**Points negatifs (-)**
- Les reflexions montrent un "tunnel vision" sur LevelJumpTable Bank 2 ($4000:2) alors que le noeud demande etait $0050
- L'agent a passe ~90% de son temps sur un probleme de reconstruction de table de donnees (bataille avec les bytes)
- Pas de JSON de sortie final visible dans les reflexions (coupe)
- Le debugging byte-par-byte est contre-productif - l'agent aurait du abandonner plus tot

---

## Rapport BFS-0048 : LCD STAT interrupt vector

### Note de realisation : 6/10

**Points positifs (+)**
- Le vecteur d'interruption LCD STAT a ete correctement documente
- Le format du bloc commentaire respecte les conventions (Description, In, Out, Modifie)
- `make verify` a reussi - pas de regression

**Points negatifs (-)**
- Aucune reference sortante identifiee alors que `jp LCDStatHandler` pointe vers `$0095`
- Le JSON de sortie n'a pas ete produit (coupe dans les reflexions)
- Les reflexions montrent une confusion sur un autre noeud (LevelJumpTable Bank 1) - signe d'un prompt mal cible

---

## Critiques du prompt initial

### 1. Ambiguite sur la portee du noeud

**Probleme** : Le prompt demande d'analyser un noeud specifique mais les reflexions montrent que l'agent a derive vers l'analyse de `$4000:2` (LevelJumpTable Bank 2) au lieu de `$0050` (Timer).

**Cause probable** : Le prompt ne verrouille pas suffisamment le contexte. L'agent peut etre distrait par des informations trouvees lors de ses recherches.

**Amelioration proposee** :
```python
# Ajouter un rappel explicite ET un timeout mental
base_prompt += f"""
## RAPPEL CRITIQUE
Tu analyses UNIQUEMENT le noeud {node.address}.
Si tu decouvres d'autres zones interessantes, note-les dans references_out
mais NE LES ANALYSE PAS dans cette session.

## REGLE D'ABANDON
Si tu passes plus de 5 iterations de debugging sur un probleme de bytes,
ABANDONNE et note le probleme dans references_out pour une session ulterieure.
La perfection est l'ennemi du bien.
"""
```

### 2. Manque de structure pour les references sortantes

**Probleme** : L'agent identifie `jp LCDStatHandler` mais ne l'extrait pas comme reference sortante.

**Cause probable** : Le prompt ne donne pas d'exemple concret de ce qu'est une "reference sortante".

**Amelioration proposee** :
```python
# Ajouter des exemples concrets
"""
## Exemples de references sortantes
- `jp $1234` ou `jp MonLabel` -> reference code
- `call $5678` -> reference code
- `dw $ABCD` dans une table -> reference code ou data selon contexte
- `ld hl, $C000` -> reference data (RAM)
"""
```

### 3. Absence de validation du JSON

**Probleme** : Le JSON final est souvent absent ou mal formate.

**Amelioration proposee** :
```python
# Dans parse_references_from_output(), ajouter une verification
if not json_match:
    # Demander a Claude de regenerer le JSON
    retry_prompt = f"""
    Ton analyse precedente n'a pas produit de JSON valide.
    Genere UNIQUEMENT le bloc JSON suivant pour {node.address}:
    ```json
    {{...}}
    ```
    """
```

### 4. Contexte historique manquant

**Probleme** : L'agent ne sait pas quels noeuds ont deja ete explores.

**Amelioration proposee** :
```python
# Inclure les noeuds visites dans le prompt
visited_context = "\n".join([f"- {addr}" for addr in list(state.visited)[-10:]])
base_prompt += f"""
## Noeuds deja visites (derniers 10)
{visited_context}
Ne re-documente pas ces adresses.
"""
```

### 5. Deviation vers code non-demande (Pattern recurrent)

**Probleme** : L'agent continue de devier vers d'autres adresses :
- BFS-0048, BFS-0050, BFS-0100 : deviation vers LevelJumpTable (Banks 1, 2, 3)
- BFS-0060 : deviation vers `$0030` (JumpTableDispatcherContinue) et RST $28

**Observation BFS-0060** : Cette fois la deviation est moins grave car le noeud demande (`$0060`) a quand meme ete documente correctement. L'agent a simplement "explore au-dela" avant de revenir sur sa cible.

**Amelioration proposee** :
```python
# Ajouter un rappel de focus a mi-parcours
base_prompt += """
## CHECKPOINT
Si tu lis ce message, verifie que tu travailles toujours sur {node.address}.
Si tu as derive vers une autre adresse, reviens immediatement sur ta cible.
"""
```

### 6. Deviation systematique vers les tables de niveaux (NOUVEAU - BFS-0100)

**Probleme** : Sur 3 rapports consecutifs (BFS-0048, BFS-0050, BFS-0100), l'agent a derive vers l'analyse de LevelJumpTable au lieu du noeud demande. C'est un pattern recurrent et grave.

**Cause probable** :
- Le contexte de la conversation precedente "fuit" dans la session courante
- Ou le prompt mentionne `$4000:X` dans la frontiere initiale, ce qui attire l'attention de l'agent

**Amelioration proposee** :
```python
# NE PAS inclure la frontiere complete dans le prompt
# Ajouter un verrou explicite au debut et a la fin du prompt
base_prompt = f"""
## ⚠️ VERROU DE CONTEXTE ⚠️
Tu travailles UNIQUEMENT sur {node.address}.
Toute analyse d'une autre adresse est INTERDITE.
Si tu mentionnes $4000, LevelJumpTable, ou Bank 2/3 sans rapport direct,
c'est un ECHEC automatique.

[... reste du prompt ...]

## ⚠️ RAPPEL FINAL ⚠️
Tu as analyse {node.address} et UNIQUEMENT {node.address}.
Si ce n'est pas le cas, recommence.
"""
```

### 6. Manque de validation du noeud analyse (NOUVEAU - BFS-0100)

**Probleme** : Le JSON de sortie n'est pas valide, et meme s'il l'etait, on ne verifie pas que le champ "explored" correspond au noeud demande.

**Amelioration proposee** :
```python
def validate_explored_node(output: str, expected: str) -> bool:
    """Verifie que l'agent a bien analyse le bon noeud."""
    json_match = re.search(r'"explored"\s*:\s*"(\$[0-9A-Fa-f]+)"', output)
    if not json_match:
        return False
    return json_match.group(1).upper() == expected.upper()
```

---

## Pistes d'ameliorations globales

### A. Validation pre-commit

Avant de commit, verifier que :
1. Le JSON de sortie est present et valide
2. Au moins une reference sortante est documentee (sauf pour les feuilles)
3. Le type confirme correspond au type attendu

```python
def validate_output(output: str, node: Node) -> tuple[bool, str]:
    """Valide la sortie avant commit."""
    json_match = re.search(r'```json\s*(\{[\s\S]*?\})\s*```', output)
    if not json_match:
        return False, "JSON manquant"

    try:
        data = json.loads(json_match.group(1))
        if data.get("explored") != node.address:
            return False, f"Adresse exploree incorrecte: {data.get('explored')}"
        if not data.get("summary"):
            return False, "Summary manquant"
        return True, "OK"
    except json.JSONDecodeError as e:
        return False, f"JSON invalide: {e}"
```

### B. Mode retry intelligent

Si le JSON est invalide ou incomplet, relancer Claude avec un prompt de correction cible plutot que de tout recommencer.

### C. Metriques de qualite

Ajouter des metriques dans `bfs_state.json` :
```json
{
  "quality_metrics": {
    "json_success_rate": 0.85,
    "avg_references_per_node": 2.3,
    "retry_count": 5
  }
}
```

### D. Log des reflexions

Sauvegarder les reflexions de l'agent dans `logs/` pour analyse post-mortem. C'est deja fait mais le format pourrait etre ameliore avec un timestamp et l'adresse exploree.

### E. Detection de "tunnel vision" (NOUVEAU - BFS-0050)

**Probleme observe** : L'agent passe 90% de son temps sur un debugging byte-par-byte d'une table qui n'est meme pas le noeud demande.

**Amelioration proposee** :
```python
# Ajouter un compteur d'iterations dans le prompt
base_prompt += """
## ANTI-SPIRALE
Compte tes iterations de debugging. Si tu fais plus de 5 tentatives
pour corriger un meme probleme de bytes :
1. git restore .
2. Note le probleme dans references_out avec type="blocked"
3. Passe a la production du JSON final

Le script gerera le retry avec une approche differente.
"""
```

### F. Separation des taches complexes (NOUVEAU - BFS-0050)

**Probleme observe** : Les tables de donnees mal desassemblees (comme LevelJumpTable Bank 2) necessitent un traitement different des simples vecteurs d'interruption.

**Amelioration proposee** :
```python
# Dans get_initial_frontier(), categoriser par complexite
def get_node_complexity(node: Node) -> str:
    if node.node_type == NodeType.HANDLER:
        return "simple"  # Juste documenter le handler
    elif node.node_type == NodeType.TABLE:
        return "complex"  # Peut necessiter reconstruction
    return "medium"

# Utiliser des prompts differents selon la complexite
```

---

## Decouvertes

### Structure des vecteurs d'interruption (Bank 0, $0040-$0068)

| Adresse | Nom | Cible | Status |
|---------|-----|-------|--------|
| $0040 | VBlankInterrupt | VBlankHandler ($0060) | Documente |
| $0048 | LCDCInterrupt | LCDStatHandler ($0095) | Documente |
| $0050 | TimerInterrupt | AudioEntryPoint ($7FF0, Bank 3) | Documente (BFS-0050) |
| $0058 | SerialInterrupt | (non utilise - tombe dans le call $7FF0) | Note |
| $0060 | VBlankHandler | (handler inline) | Documente (BFS-0060) ✓ |
| $0068 | JoypadInterrupt | ? | A explorer |
| $0095 | LCDStatHandler | Systeme multi-entree ($00C3, $00C7, $00CD) | **Documente (BFS-0095)** ✓✓ |

**Correction** : `$0060` n'est pas le vecteur Joypad mais le **handler VBlank inline**. Le vecteur Joypad standard est a `$0060` mais ici il est utilise comme debut du VBlankHandler (le `jp VBlankHandler` a `$0040` pointe vers `$0060`).

### Pattern observe

Les vecteurs d'interruption suivent tous le meme pattern :
```asm
InterruptVector::
    jp Handler
```

Cela suggere que les handlers reels sont places plus loin dans la ROM pour eviter les collisions avec les vecteurs RST ($00, $08, $10, $18, $20, $28, $30, $38).

### Decouverte BFS-0050 : Systeme audio (NOUVEAU)

Le timer overflow ($0050) est utilise pour le systeme audio :
- `TimerOverflowInterrupt` sauvegarde AF, switch vers Bank 3 (BANK_AUDIO)
- Appelle `$7FF0` (AudioEntryPoint) en Bank 3
- Le Serial interrupt ($0058) n'est PAS un vrai handler - l'adresse tombe au milieu du `call $7ff0`

**Implication** : Le systeme audio fonctionne via interruptions timer, ce qui suggere un moteur sonore base sur des ticks reguliers (typique des jeux GB).

### Probleme de reconstruction de tables (BFS-0050)

L'agent a tente de reconstruire LevelJumpTable Bank 2 ($4000:2) mais s'est heurte a :
- Decalage de bytes entre source et binaire
- Differences entre patterns attendus (`02 60 73 60 FE 60`) et generes
- Problemes potentiels de cache ou de linking RGBDS

**Conclusion** : La reconstruction de tables mal desassemblees necessite une approche methodique :
1. Extraire les bytes exacts du binaire original avec `xxd`
2. Compter precisement le nombre de bytes avant/apres
3. Ne PAS modifier plusieurs zones en une seule passe

### Decouverte BFS-0095 : LCDStatHandler - Systeme raster modulaire (NOUVEAU)

Le handler LCD STAT (`$0095`) revele un **systeme d'effets raster sophistique** :

**Architecture multi-points d'entree** :
| Adresse | Nom | Role |
|---------|-----|------|
| $0095 | LCDStatHandler | Point d'entree principal (interrupt vector) |
| $00C3 | LCDStat_CheckCarryExit | Verifie carry flag (resultat de cp) et branch |
| $00C7 | LCDStat_SetLYC | Configure la prochaine ligne LYC pour l'interruption |
| $00CD | LCDStat_PopAndReti | Epilogue standard (pop af + reti) |

**Variables shadow pour effets raster** :
- `hShadowSCX` ($FFA4) : Valeur SCX pre-calculee pour effet parallax/wave
- `hGameState` ($FFB3) : Etat de jeu verifie avec `GAME_STATE_WINDOW=$3A`
- `hOAMIndex` ($FFFB) : Index courant dans l'OAM pour animation par scanline

**Pattern d'appel** :
Le handler est appele depuis une **table de dispatch en bank_002** (`ConstTableA_Entry9`). Cela suggere un systeme de "raster effects" configurable par niveau/etat de jeu.

**Implications techniques** :
1. Le jeu utilise les **interruptions LY=LYC** pour des effets par scanline
2. Le shadow SCX permet des effets de **parallax horizontal** ou de **wave distortion**
3. L'etat `$3A` est probablement un etat "in-game" avec le HUD active (Window layer)
4. Le `wGameConfigA5` agit comme **selecteur de mode** (0=normal, !=0=retour rapide)

**Comparaison avec d'autres jeux GB** :
Ce pattern multi-entree est typique des jeux avec effets graphiques avances (ex: Donkey Kong Land, Kirby). Il permet de reutiliser le code d'epilogue et de branching depuis plusieurs contextes.

---

### Decouverte BFS-0060 : VBlankHandler et architecture (NOUVEAU)

Le handler VBlank (`$0060`) revele l'architecture de la boucle principale du jeu :

**Structure en 7 phases** :
1. **SaveRegisters** - `push af/bc/de/hl` (sauvegarde contexte)
2. **UpdateGameLogic** - Scroll, vies, score, animations (logique metier)
3. **DMATransfer** - `call $FFB6` (copie OAM depuis wShadowOAM)
4. **IncrementFrame** - `hFrameCounter++` (compteur pour timing)
5. **CheckWindowEnable** - Active Window si `game_state == $3A`
6. **ResetScrollAndFlag** - SCX/SCY = 0, `hVBlankFlag = 1`
7. **RestoreRegisters** - `pop + reti` (retour d'interruption)

**Implications architecturales** :
- Le jeu utilise le pattern **double buffering OAM** (shadow OAM en WRAM copie vers OAM reel via DMA)
- L'etat `$3A` est un etat de jeu special qui active le Window (probablement HUD ou pause)
- `hVBlankFlag` est utilise pour la synchronisation CPU-GPU (attente VBlank dans la boucle principale)
- Le scroll est reinitialise a chaque frame - cela suggere que le scroll est calcule dynamiquement

**References sortantes manquees** :
- `$FFB6` : Routine DMA en HRAM (copiee au boot, execute depuis HRAM car inaccessible pendant DMA)
- La routine UpdateGameLogic devrait etre une reference si elle est un `call`

**Pattern DMA Game Boy** :
```asm
; Typiquement a $FFB6 (ou autre adresse HRAM)
DMARoutine:
    ld a, HIGH(wShadowOAM)  ; Source en WRAM ($C000+)
    ldh [rDMA], a           ; Declenche DMA
    ld a, 40                ; 160 cycles = 40 iterations
.wait:
    dec a
    jr nz, .wait
    ret
```

### Decouverte BFS-0100 : ROM Entry point et structure (NOUVEAU)

Le noeud `$0100` est le **point d'entree standard** des ROMs Game Boy :
- Adresse `$0100-$0103` : contient typiquement `nop` puis `jp $0150` (ou similaire)
- Adresse `$0104-$0133` : Nintendo logo (obligatoire pour boot)
- Adresse `$0134-$0143` : Titre du jeu (16 caracteres ASCII)
- Adresse `$0144-$014F` : Metadonnees (checksum, type cartouche, taille ROM/RAM)

La reference `$0150` (AfterHeader) est donc le vrai debut du code executable, apres le header de la cartouche.

**Pattern type a $0100** :
```asm
SECTION "Entry", ROM0[$0100]
EntryPoint::
    nop
    jp AfterHeader  ; $0150 ou SystemInit
```

**Implication** : `$0150` devrait pointer vers l'initialisation du systeme (copie en RAM, init des registres, etc.).

---

## Historique des evaluations

| Commit | Adresse | Note | Commentaire |
|--------|---------|------|-------------|
| BFS-0095 | $0095 | 9/10 | **Meilleure session** - 10 refs de qualite, nommage semantique, architecture raster |
| BFS-0060 | $0060 | 8/10 | VBlankHandler documente, format ameliore, deviation mineure |
| BFS-0100 | $0100 | 5/10 | Reference $0150 trouvee, mais reflexions sur mauvais noeud |
| BFS-0050 | $0050 | 7/10 | Doc OK, ref audio trouvee, mais tunnel vision sur Bank 2 |
| BFS-0048 | $0048 | 6/10 | Documentation OK mais pas de JSON/refs |

---

## Synthese des ameliorations prioritaires

### Priorite 0 (CRITIQUE - BFS-0100)
0. **Verrou de contexte** - Ajouter des gardes au debut ET a la fin du prompt pour empecher la deviation vers d'autres noeuds. C'est le probleme #1 apres 3 echecs consecutifs.

### Priorite 1 (Impact eleve)
1. **Regle d'abandon** - Ajouter un compteur mental dans le prompt pour eviter les spirales de debugging
2. **Rappel explicite du noeud** - Repeter l'adresse cible plusieurs fois dans le prompt
3. **Validation du noeud explore** - Verifier que le champ "explored" du JSON correspond au noeud demande

### Priorite 2 (Impact moyen)
4. **Separation par complexite** - Prompts differents pour handlers (simples) vs tables (complexes)
5. **Validation JSON** - Verifier la presence du JSON avant commit
6. **Ne pas inclure la frontiere** - La liste des noeuds en attente distrait l'agent

### Priorite 3 (Nice to have)
7. **Metriques de qualite** - Tracker le taux de succes JSON et taux de deviation
8. **Mode retry intelligent** - Relancer avec prompt de correction si JSON manquant ou noeud incorrect

---

## Score moyen des 5 derniers rapports

| Metrique | Valeur |
|----------|--------|
| Note moyenne | 7.0/10 ↑ |
| JSON avec references | 1/5 (20%) ↑ |
| Noeud documente correctement | 3/5 (60%) ✓ |
| Deviation vers autre noeud | 4/5 (80%) ⬇ |
| `make verify` OK | 5/5 (100%) ✓ |

**Evolution** :
- BFS-0048 : 6/10 - Deviation totale
- BFS-0050 : 7/10 - Deviation + tunnel vision
- BFS-0100 : 5/10 - Deviation totale
- BFS-0060 : 8/10 - Deviation mineure, noeud correctement documente ✓
- **BFS-0095 : 9/10** - Focus excellent, 10 references de qualite ✓✓

**Conclusion** : **Nette amelioration!** BFS-0095 est la premiere session ou l'agent:
1. Reste concentre sur le noeud demande
2. Produit un nombre significatif de references (10 au lieu de 0-1)
3. Utilise un nommage semantique pertinent (`hShadowSCX`, `hGameState`, etc.)

Le probleme de "deviation vers LevelJumpTable" semble resolu pour les handlers complexes. La tendance est clairement positive : 6 → 7 → 5 → 8 → **9**.

---

## Nouvelles pistes d'amelioration (post BFS-0095)

### A. Capitaliser sur le succes de BFS-0095

**Observation** : L'agent a mieux performe sur un noeud complexe (handler multi-entree) que sur des noeuds simples (vecteurs d'interruption).

**Hypothese** : Les noeuds avec plus de "substance" (code riche, references multiples) maintiennent mieux l'attention de l'agent.

**Proposition** : Prioriser les noeuds complexes (handlers, tables) plutot que les simples vecteurs. Les vecteurs peuvent etre documentes en batch par un humain.

### B. Extraction automatique des noms de variables

**Observation** : L'agent a trouve d'excellents noms pour les variables HRAM/WRAM (`hShadowSCX`, `hGameState`).

**Proposition** : Ajouter une etape post-analyse qui extrait ces noms et les ajoute automatiquement a `constants.inc` ou un fichier `symbols.inc`.

### C. Validation du nombre de references

**Observation** : BFS-0095 a produit 10 references, BFS-0048/0050/0060 en avaient 0-1.

**Proposition** : Ajouter un seuil minimal de references attendues selon le type de noeud:
- Handler complexe : >= 3 references
- Table : >= nombre_entrees references
- Vecteur simple : >= 1 reference (la cible du jp/call)

```python
MIN_REFS = {
    NodeType.HANDLER: 3,
    NodeType.TABLE: 5,
    NodeType.CODE: 1,
    NodeType.DATA: 0
}
```

---

## Rapport BFS-0185 : SystemInit - Init système

### Note de realisation : 6/10

**Points positifs (+)**
- Le noeud `$0185` (SystemInit) a ete correctement marque comme visite
- Une nouvelle reference decouverte : `$7FF3` (ROM_INIT_BANK3 en Bank 3) - routine d'initialisation en bank 3
- `make verify` a reussi - pas de regression
- L'ajout dans `visited` est correct
- La reorganisation des entrees dans bfs_state.json (tri par adresse) ameliore la lisibilite

**Points negatifs (-)**
- **DEVIATION MAJEURE** : Les reflexions montrent une analyse de `$00C5` (LCDStatHandler_UpdateLYC) au lieu de `$0185` (SystemInit)
  - Recherche de constantes pour LCDStat
  - Verification dans le fichier .sym
  - Ajout de bloc commentaire pour UpdateLYC
  - Aucune mention de SystemInit dans les reflexions !
- Seulement **1 reference sortante** ajoutee alors que SystemInit devrait avoir plusieurs cibles :
  - Initialisation memoire (copie en HRAM/WRAM)
  - Configuration des registres hardware
  - Appel vers GameLoop ou autre routine principale
- Le JSON de sortie n'est pas visible (coupe comme d'habitude)
- Les reflexions sont tres fragmentees et manquent de coherence

**Analyse du probleme**

C'est un cas classique de **deviation totale**. L'agent a :
1. Commence sur le bon noeud ($0185)
2. Derive vers l'analyse de LCDStatHandler ($0095) qui etait le noeud precedent
3. Passe tout son temps sur une sous-fonction ($00C5) qui n'etait meme pas demandee

**Cause probable** :
- Le contexte de la session precedente (BFS-0095) a "fui" dans cette session
- L'agent a peut-etre vu des references vers LCDStat depuis SystemInit et a suivi le lapin blanc

**Impact sur les metriques** :
- Le noeud est marque visite mais **pas reellement analyse**
- La seule reference ($7FF3) est peut-etre correcte mais sans analyse visible
- Le pattern de deviation vers des analyses hors-sujet persiste

---

### Critiques du prompt pour BFS-0185

#### 1. Le contexte precedent contamine la session

**Observation** : Les reflexions parlent de `LCDStatHandler_UpdateLYC`, `rLYC`, et des constantes du handler LCD alors que le noeud demande etait SystemInit.

**Amelioration proposee** :
```python
# Ajouter un separateur de contexte explicite
base_prompt = f"""
## 🚨 NOUVELLE SESSION - CONTEXTE PROPRE 🚨
Cette session est INDEPENDANTE des sessions precedentes.
Tu n'as AUCUNE memoire des noeuds precedemment analyses.
Le SEUL noeud qui t'interesse est : {node.address}

[... reste du prompt ...]
"""
```

#### 2. Absence de checkpoint de validation

**Observation** : L'agent ne verifie jamais qu'il travaille sur le bon noeud pendant son analyse.

**Amelioration proposee** :
```python
# Ajouter un rappel a mi-parcours dans le prompt
base_prompt += f"""
## ⚠️ CHECKPOINT OBLIGATOIRE
Avant d'ecrire du code, reponds a cette question :
"Est-ce que je travaille sur {node.address} ?"
Si la reponse est NON, arrete immediatement et reviens sur ta cible.
"""
```

#### 3. Manque de structure pour SystemInit specifiquement

**Observation** : SystemInit est une routine complexe d'initialisation qui devrait avoir de nombreuses references sortantes (hardware init, memory copy, jump vers main loop).

**Amelioration proposee** :
```python
# Ajouter des hints specifiques selon le type de noeud
if "Init" in node.description or "init" in node.address.lower():
    base_prompt += """
## HINTS POUR ROUTINES D'INITIALISATION
Les routines Init font typiquement :
1. Desactiver les interruptions (di)
2. Attendre VBlank pour manipuler VRAM
3. Copier des routines en HRAM (DMA)
4. Initialiser les variables WRAM
5. Configurer les registres hardware (LCD, sound, timer)
6. Reenable les interruptions (ei)
7. Sauter vers la boucle principale

Cherche ces patterns et documente chaque reference sortante.
"""
```

---

### Decouvertes BFS-0185

#### ROM_INIT_BANK3 ($7FF3, Bank 3)

Une routine d'initialisation existe en Bank 3 a l'adresse $7FF3. Cela suggere :
- Le systeme d'initialisation est **multi-bank**
- Des donnees ou routines specifiques sont en Bank 3
- Le boot sequence inclut un bank switch tot dans le processus

**A investiguer** :
- Que fait ROM_INIT_BANK3 ?
- Pourquoi l'init est-elle splitee entre Bank 0 et Bank 3 ?
- Y a-t-il d'autres ROM_INIT_BANKX ?

---

### Pistes d'amelioration specifiques a cette session

#### A. Detection de deviation en temps reel

**Probleme** : L'agent a passe 100% de son temps sur un autre noeud sans s'en rendre compte.

**Proposition** :
```python
# Dans run_claude_streaming(), detecter les deviations
def check_for_deviation(output_chunk: str, target_address: str) -> bool:
    """Detecte si l'agent parle d'un autre noeud."""
    # Liste des adresses mentionnees dans l'output
    addresses = re.findall(r'\$[0-9A-Fa-f]{4}', output_chunk)

    # Si le target n'est jamais mentionne et d'autres le sont...
    if target_address not in addresses and len(addresses) > 5:
        return True  # Deviation probable
    return False
```

#### B. Validation du noeud dans le JSON final

**Probleme** : Le JSON (s'il existe) pourrait avoir un champ "explored" different du noeud demande.

**Proposition** (deja mentionnee mais jamais implementee) :
```python
def validate_json_target(json_output: str, expected: str) -> bool:
    """Verifie que le JSON parle du bon noeud."""
    match = re.search(r'"explored"\s*:\s*"([^"]+)"', json_output)
    if not match:
        return False
    return match.group(1).upper() == expected.upper()
```

#### C. Retry automatique sur deviation

**Proposition** :
```python
# Si deviation detectee, relancer avec un prompt de correction
if deviation_detected:
    correction_prompt = f"""
    ⚠️ TU T'ES TROMPE DE NOEUD ⚠️

    Tu as analyse {detected_address} au lieu de {node.address}.

    RECOMMENCE en te concentrant UNIQUEMENT sur {node.address}.
    Ignore tout ce que tu as fait precedemment.
    """
    success, output = run_claude_streaming(correction_prompt)
```

---

## Historique des evaluations (mis a jour)

| Commit | Adresse | Note | Commentaire |
|--------|---------|------|-------------|
| BFS-0095 | $0095 | 9/10 | **Meilleure session** - 10 refs de qualite, nommage semantique |
| BFS-0060 | $0060 | 8/10 | VBlankHandler documente, format ameliore |
| BFS-0050 | $0050 | 7/10 | Doc OK, ref audio trouvee, tunnel vision |
| BFS-0048 | $0048 | 6/10 | Documentation OK mais pas de JSON/refs |
| **BFS-0185** | **$0185** | **6/10** | **Deviation totale vers LCDStat, 1 seule ref** |
| BFS-0100 | $0100 | 5/10 | Reference $0150 trouvee, reflexions hors-sujet |

---

## Score moyen des 6 derniers rapports

| Metrique | Valeur |
|----------|--------|
| Note moyenne | 6.8/10 ↓ |
| JSON avec references | 2/6 (33%) → |
| Noeud documente correctement | 3/6 (50%) ↓ |
| Deviation vers autre noeud | 5/6 (83%) ⬇ |
| `make verify` OK | 6/6 (100%) ✓ |

**Evolution** :
- BFS-0048 : 6/10 - Deviation totale
- BFS-0050 : 7/10 - Deviation + tunnel vision
- BFS-0100 : 5/10 - Deviation totale
- BFS-0060 : 8/10 - Deviation mineure, noeud correctement documente ✓
- BFS-0095 : 9/10 - Focus excellent, 10 references de qualite ✓✓
- **BFS-0185 : 6/10** - Deviation totale vers LCDStat ($00C5) ✗

**Conclusion** : **Regression apres le pic de BFS-0095.** L'agent est retombe dans le pattern de deviation. La tendance n'est plus clairement positive : 6 → 7 → 5 → 8 → 9 → **6**.

Le probleme de "fuite de contexte" entre sessions semble etre la cause principale. L'agent a clairement continue a travailler sur le handler LCD de la session precedente au lieu de SystemInit.

---

## Synthese des ameliorations prioritaires (mise a jour)

### Priorite 0 (CRITIQUE)
1. **Isolation de contexte** - Ajouter des marqueurs explicites pour separer les sessions et eviter la contamination
2. **Validation du noeud explore** - Verifier systematiquement que le JSON.explored == noeud demande AVANT commit

### Priorite 1 (Impact eleve)
3. **Detection de deviation en temps reel** - Analyser l'output streaming pour detecter si l'agent parle d'autres adresses
4. **Hints specifiques par type** - Adapter le prompt selon que c'est Init, Handler, Table, etc.
5. **Retry automatique** - Relancer avec prompt de correction si deviation detectee

### Priorite 2 (Impact moyen)
6. **Checkpoint mental** - Rappel a mi-parcours dans le prompt
7. **Metriques de deviation** - Tracker le ratio noeud_analyse/noeud_demande

---

## Rapport BFS-0226 : GameLoop - Boucle principale

### Note de realisation : 7/10

**Points positifs (+)**
- Le noeud `$0226` (GameLoop) a ete correctement marque comme visite
- **4 references sortantes de qualite** ajoutees dans bfs_state.json :
  - `$09E8` : InitGameState - Initialise l'etat de jeu (quand wSpecialState == 3)
  - `$172D` : SwitchBankAndCallBank3Handler - Appelle handler en bank 3 avec params specifiques
  - `$07C3` : CheckInputAndPause - Verifie input pour soft reset (A+B+Start+Select) ou toggle pause
  - `$02A3` : StateDispatcher - Dispatch vers handler d'etat via jump table (60 etats possibles)
- Les descriptions sont semantiques et informatives (mentions de conditions, nombre d'etats)
- `make verify` a reussi - pas de regression
- L'ajout dans `visited` est correct

**Points negatifs (-)**
- **DEVIATION PARTIELLE** : Les reflexions montrent une analyse de `$00C7` (LCDStat_SetLYC) alors que le noeud demande etait `$0226`
  - "Je vais analyser le code a l'adresse $00C7 (LCDStat_SetLYC)"
  - Recherche dans bank_003 alors que GameLoop est en bank 0
  - Ajout de commentaires pour LCDStat au lieu de GameLoop
- Le JSON de sortie n'est pas visible (coupe comme d'habitude)
- Les reflexions semblent tres fragmentees et incoherentes avec le noeud demande
- Pas de documentation visible de la structure de GameLoop elle-meme

**Analyse du probleme**

Cette session presente un **paradoxe interessant** :
1. Les references sortantes decouvertes (InitGameState, CheckInputAndPause, StateDispatcher) sont **directement liees a GameLoop** - ce sont des appels depuis la boucle principale
2. MAIS les reflexions visibles parlent de LCDStat ($00C7) qui n'a aucun rapport
3. Hypothese : L'agent a **correctement analyse GameLoop** (d'ou les bonnes refs) mais les reflexions capturees proviennent d'une autre partie de la conversation ou d'une contamination de contexte

**Impact sur les metriques** :
- 4 references de qualite = meilleur que BFS-0185 (1 ref) et BFS-0100 (1 ref)
- La coherence entre les refs et le noeud GameLoop est bonne
- Mais l'incoherence des reflexions est troublante

---

### Critiques du prompt pour BFS-0226

#### 1. Fuite de contexte des sessions precedentes

**Observation** : Les reflexions mentionnent `LCDStat_SetLYC` ($00C7), qui faisait partie de l'analyse de `$0095` (session BFS-0095). C'est le **troisieme rapport consecutif** avec ce probleme de contamination.

**Pattern observe** :
- BFS-0095 : Analyse de LCDStatHandler et ses sous-routines ($00C3, $00C7, $00CD) ✓
- BFS-0185 : Deviation vers LCDStatHandler_UpdateLYC ($00C5) ✗
- BFS-0226 : Deviation vers LCDStat_SetLYC ($00C7) ✗

**Cause probable** : Le contexte de Claude n'est pas reinitialise entre les appels, ou le script conserve un historique de conversation qui "pollue" les sessions suivantes.

**Amelioration proposee** :
```python
# Dans run_claude_streaming(), forcer un contexte propre
cmd = [
    "claude",
    "-p", prompt,
    "--model", CLAUDE_MODEL,
    "--dangerously-skip-permissions",
    "--no-context",  # NOUVEAU: ne pas charger le contexte precedent
    "--output-format", "stream-json"
]
```

#### 2. Manque de verrou de focus explicite

**Amelioration proposee** :
```python
# Ajouter au prompt un verrou de focus repete
base_prompt = f"""
## 🔒 VERROU DE FOCUS - A LIRE EN PREMIER 🔒
Tu travailles sur: {node.address} ({node.description})
Tu NE travailles PAS sur: LCDStat, $00C7, $0095, ou tout autre noeud precedent.
Si tu lis du code a une autre adresse, c'est UNIQUEMENT pour comprendre les references
depuis {node.address}, pas pour le documenter.

[... reste du prompt ...]

## 🔒 RAPPEL FINAL 🔒
Avant de produire le JSON, verifie que tu as analyse {node.address} et non un autre noeud.
"""
```

---

### Decouvertes BFS-0226 : Architecture de la GameLoop

Les 4 references sortantes revelent l'architecture de la boucle principale du jeu :

#### 1. InitGameState ($09E8)
- Appele quand `wSpecialState == 3`
- Probablement l'initialisation d'une nouvelle partie ou d'un niveau
- Le flag `wSpecialState` agit comme un compteur ou une machine a etats de haut niveau

#### 2. SwitchBankAndCallBank3Handler ($172D)
- Routine de "trampoline" pour appeler du code en Bank 3
- Passe des parametres specifiques au handler
- Pattern classique sur Game Boy pour les jeux multi-bank

#### 3. CheckInputAndPause ($07C3)
- Gere le **soft reset** (combo A+B+Start+Select) - standard Game Boy
- Gere le **toggle pause** (probablement Start seul)
- Cette routine est appelee a chaque frame pour detecter les inputs speciaux

#### 4. StateDispatcher ($02A3)
- **DECOUVERTE MAJEURE** : Le jeu a **60 etats possibles**
- Dispatch vers le handler d'etat via une jump table
- Cette jump table est probablement a `$02A5` (StateJumpTable) deja dans la frontiere

**Architecture deduite** :

```
GameLoop ($0226)
    │
    ├─► CheckInputAndPause ($07C3)
    │       └─► Soft reset ou toggle pause
    │
    ├─► InitGameState ($09E8) si wSpecialState == 3
    │       └─► Reinitialisation de l'etat de jeu
    │
    ├─► StateDispatcher ($02A3)
    │       └─► StateJumpTable ($02A5) [60 entrees]
    │               ├─► Etat 0: ???
    │               ├─► Etat 1: ???
    │               └─► ... jusqu'a Etat 59
    │
    └─► SwitchBankAndCallBank3Handler ($172D)
            └─► Handler specifique en Bank 3
```

**Implications** :
1. Le jeu utilise une **machine a etats avec 60 etats** - c'est un jeu complexe
2. La structure est modulaire avec des routines bien separees
3. Le pattern "trampoline" pour Bank 3 suggere que les niveaux ou l'audio sont en Bank 3

---

### Pistes d'amelioration specifiques a cette session

#### A. Isolation stricte du contexte

**Probleme** : La contamination de contexte persiste sur 3 sessions consecutives (BFS-0095 → BFS-0185 → BFS-0226).

**Proposition** :
```python
# Dans bfs_explorer.py, ajouter un flag pour forcer un nouveau contexte
def run_claude_streaming(prompt: str, force_new_context: bool = True) -> tuple[bool, str]:
    cmd = ["claude", "-p", prompt, "--model", CLAUDE_MODEL]

    if force_new_context:
        # Option 1: Utiliser --no-context si disponible
        cmd.append("--no-context")

        # Option 2: Ajouter un prefixe de reset au prompt
        prompt = "## SESSION COMPLETEMENT NOUVELLE\nOublie tout contexte precedent.\n\n" + prompt
```

#### B. Validation des reflexions

**Probleme** : Les reflexions capturees ne correspondent pas au noeud explore.

**Proposition** :
```python
def validate_reflexions(output: str, target_address: str) -> tuple[bool, str]:
    """Verifie que les reflexions parlent du bon noeud."""

    # Compter les mentions du target vs autres adresses
    target_count = output.lower().count(target_address.lower())
    all_addresses = re.findall(r'\$[0-9A-Fa-f]{4}', output)

    # Calculer le ratio
    other_addresses = [a for a in all_addresses if a.upper() != target_address.upper()]

    if target_count == 0 and len(other_addresses) > 5:
        return False, f"Deviation detectee: {len(other_addresses)} autres adresses mentionnees, 0 fois {target_address}"

    return True, "OK"
```

#### C. Metriques de qualite des references

**Observation** : BFS-0226 a produit 4 refs de qualite vs 1 ref pour BFS-0185. Il serait utile de tracker cela.

**Proposition** :
```json
{
  "quality_metrics": {
    "total_refs_discovered": 25,
    "avg_refs_per_node": 2.5,
    "nodes_with_zero_refs": 2,
    "nodes_with_deviation": 5,
    "make_verify_success_rate": 1.0
  }
}
```

---

## Historique des evaluations (mis a jour)

| Commit | Adresse | Note | Refs | Commentaire |
|--------|---------|------|------|-------------|
| BFS-0095 | $0095 | 9/10 | 10 | **Meilleure session** - nommage semantique, architecture raster |
| BFS-0060 | $0060 | 8/10 | 0 | VBlankHandler documente, format ameliore |
| **BFS-0226** | **$0226** | **7/10** | **4** | **GameLoop - Bonnes refs mais deviation dans reflexions** |
| BFS-0050 | $0050 | 7/10 | 1 | Doc OK, ref audio trouvee, tunnel vision |
| BFS-0048 | $0048 | 6/10 | 0 | Documentation OK mais pas de JSON/refs |
| BFS-0185 | $0185 | 6/10 | 1 | Deviation totale vers LCDStat |
| BFS-0100 | $0100 | 5/10 | 1 | Reference $0150 trouvee, reflexions hors-sujet |

---

## Score moyen des 7 derniers rapports

| Metrique | Valeur |
|----------|--------|
| Note moyenne | 6.9/10 → |
| Total references | 17 refs pour 7 noeuds |
| Moyenne refs/noeud | 2.4 refs |
| JSON avec references | 4/7 (57%) ↑ |
| Noeud documente correctement | 4/7 (57%) → |
| Deviation vers autre noeud | 5/7 (71%) ↓ (amelioration!) |
| `make verify` OK | 7/7 (100%) ✓ |

**Evolution** :
- BFS-0048 : 6/10, 0 refs - Deviation totale
- BFS-0050 : 7/10, 1 ref - Deviation + tunnel vision
- BFS-0100 : 5/10, 1 ref - Deviation totale
- BFS-0060 : 8/10, 0 refs - Deviation mineure, noeud documente ✓
- BFS-0095 : 9/10, 10 refs - Focus excellent ✓✓
- BFS-0185 : 6/10, 1 ref - Deviation totale vers LCDStat ✗
- **BFS-0226 : 7/10, 4 refs** - Bonnes refs malgre deviation dans reflexions

**Conclusion** : **Stabilisation autour de 7/10.** L'agent produit des references de qualite (4 refs pertinentes pour GameLoop) mais le probleme de contamination de contexte persiste. La tendance est legerement positive : 6 → 7 → 5 → 8 → 9 → 6 → **7**.

**Points cles** :
1. Les references decouvertes sont coherentes avec GameLoop (meme si les reflexions parlent d'autre chose)
2. L'architecture du jeu se revele : 60 etats, machine a etats, trampoline vers Bank 3
3. Le probleme #1 reste la contamination de contexte inter-sessions

---

## Synthese des ameliorations prioritaires (mise a jour finale)

### Priorite 0 (CRITIQUE)
1. **Isolation de contexte** - Ajouter `--no-context` ou prefixe de reset pour eviter la contamination entre sessions
2. **Validation du noeud explore** - Verifier que les reflexions parlent du bon noeud AVANT commit

### Priorite 1 (Impact eleve)
3. **Verification de coherence refs/noeud** - Les refs doivent etre liees au noeud explore
4. **Detection de deviation temps reel** - Analyser l'output streaming
5. **Hints par type de noeud** - Prompts differents pour GameLoop vs Handler vs Table

### Priorite 2 (Impact moyen)
6. **Metriques de qualite** - Tracker refs/noeud, taux de deviation, etc.
7. **Retry intelligent** - Relancer si deviation detectee

### Priorite 3 (Nice to have)
8. **Extraction automatique des noms** - Ajouter les symboles decouverts a constants.inc
9. **Validation minimale de refs** - Seuil selon le type de noeud

---

## Rapport BFS-02A5 : StateJumpTable - 60 etats

### Note de realisation : 10/10

**Points positifs (+)**
- **DECOUVERTE EXCEPTIONNELLE** : Le noeud `$02A5` (StateJumpTable) a permis de decouvrir **60 handlers d'etat**
- Le diff montre l'ajout massif de **60 references sortantes** de qualite dans bfs_state.json :
  - Etats 0x00-0x0F : Gameplay principal (init, objets, transitions tuyaux)
  - Etats 0x10-0x1F : Niveaux, bonus, VRAM
  - Etats 0x20-0x2F : Cutscenes fin de niveau (princesse, animations)
  - Etats 0x30-0x3B : Credits, game over, window setup
- **Nommage semantique exemplaire** :
  - `State00_MainGameplay` - Init/main gameplay
  - `State09_PipeEnterRight` - Entree tuyau droite
  - `State26_PrincessRising` - Princesse montante
  - `State32_CreditsScroll` - Scroll credits
  - `State39_GameOver` - Game Over
- `make verify` a reussi - pas de regression
- Reorganisation des noeuds dans bfs_state.json (ajout de $02A5 dans visited)
- Les etats en Bank 1 (State14, State15, State17-1A) sont correctement marques avec `"bank": 1`

**Points negatifs (-)**
- Les reflexions capturees semblent parler de `$00CC` (LCDStatHandler_Exit) - encore une contamination de contexte
- Cependant, les resultats (60 refs de qualite) prouvent que l'agent a bien analyse $02A5
- Pas de commentaire de fonction visible pour StateJumpTable dans les reflexions

**Analyse**

Cette session est **la meilleure de toutes** car :
1. **60 references de qualite** - 6x plus que la meilleure session precedente (BFS-0095 avec 10 refs)
2. Le nommage suit les conventions (`StateXX_NomDescriptif`)
3. L'architecture complete du jeu est revelee :
   - Gameplay principal (etats 0-8)
   - Transitions tuyaux (etats 9-C)
   - Fin de niveau et cutscenes (etats 0D-2F)
   - Credits et game over (etats 30-3B)
4. La distinction Bank 0 / Bank 1 est correctement geree

**Decouverte architecturale majeure** :

Le jeu utilise une **machine a etats avec 60 etats** (0x00 a 0x3B), geree par une jump table a `$02A5`. Cette architecture revele :

1. **Etats de gameplay** (0x00-0x0D) :
   - State00: Gameplay principal
   - State01-02: Reset objets, preparation rendu
   - State03-08: Transitions, niveaux speciaux, progression monde
   - State09-0C: Gestion des tuyaux (entree/sortie, horizontale/verticale)
   - State0D: Gameplay complet avec objets

2. **Etats de niveau/menu** (0x0E-0x13) :
   - State0E: Init niveau + HUD
   - State0F: Menu selection niveau
   - State10: Noop (placeholder)
   - State11-13: Demarrage niveau, fin niveau, bordures

3. **Etats Bank 1** (0x14-0x1A) :
   - 7 etats qui pointent vers Bank 1 ($5832-$5841)
   - Probablement des handlers de donnees ou routines specifiques

4. **Etats bonus/VRAM** (0x1B-0x1F) :
   - State1B: Bonus complete
   - State1C-1F: Timers, VRAM, tilemap

5. **Etats cutscene fin** (0x20-0x2F) :
   - State20-27: Animation princesse, oscillation joueur
   - State28 (absent?): A investiguer
   - State29-2F: Ecran fin, texte, animations duo

6. **Etats credits/fin** (0x30-0x3B) :
   - State30-31: Marche gauche, scroll horizontal
   - State32-38: Scroll credits, animations finales
   - State39: **Game Over**
   - State3A-3B: Window setup

**Pattern observe** : Le jeu est un **Super Mario-like** avec :
- Tuyaux (pipe) pour les transitions
- Princesse a sauver (cutscene fin)
- Systeme de credits avec scroll
- Game over standard

---

### Critiques du prompt pour BFS-02A5

#### 1. Le prompt a bien fonctionne pour les tables

**Observation** : Contrairement aux noeuds simples (vecteurs, handlers), l'agent a excellemment performe sur cette table complexe.

**Hypothese confirmee** : Les noeuds avec plus de "substance" (60 entrees a parser) maintiennent mieux l'attention de l'agent. Le pattern de deviation est moins present quand il y a beaucoup de travail concret.

**Recommandation** :
```python
# Prioriser les tables et structures complexes
# Les noeuds "riches" generent de meilleurs resultats
if node.node_type == NodeType.TABLE:
    priority -= 1  # Plus prioritaire
```

#### 2. Contamination de contexte persistante mais sans impact

**Observation** : Les reflexions parlent de `$00CC` mais les resultats sont parfaits pour `$02A5`.

**Hypothese** : L'agent peut "penser" a autre chose dans ses reflexions mais produire le bon resultat. Le veritable indicateur de qualite est le JSON/diff final, pas les reflexions intermediaires.

**Recommandation** :
```python
# Ne pas se fier aux reflexions pour evaluer la qualite
# Se baser sur:
# 1. Le nombre de refs decouvertes
# 2. La coherence des refs avec le noeud source
# 3. Le succes de make verify
```

#### 3. Format de sortie optimal pour les tables

**Observation** : L'agent a utilise le pattern `StateXX_NomDescriptif` de maniere coherente sur 60 etats.

**Recommandation** : Ajouter des hints de format dans le prompt pour les tables :
```python
if node.node_type == NodeType.TABLE:
    base_prompt += """
## FORMAT POUR TABLES
Pour chaque entree de la jump table, utilise le format:
- StateXX_NomDescriptif pour les etats
- HandlerXX_NomDescriptif pour les handlers
- EntryXX_NomDescriptif pour les donnees

Numerote sequentiellement (00, 01, 02...) meme si l'adresse interne differe.
"""
```

---

### Pistes d'ameliorations post BFS-02A5

#### A. Prioriser les tables dans le BFS

**Justification** : BFS-0095 (handler complexe) et BFS-02A5 (table 60 entrees) ont produit les meilleurs resultats.

**Proposition** :
```python
def get_node_priority(node: Node) -> int:
    """Les noeuds complexes sont plus fiables."""
    base = node.priority
    if node.node_type == NodeType.TABLE:
        return base - 2  # Haute priorite
    elif node.node_type == NodeType.HANDLER:
        return base - 1  # Priorite moyenne
    return base
```

#### B. Batch processing des etats Bank 1

**Observation** : Les etats $14-$1A pointent vers Bank 1 mais leurs adresses sont tres proches ($5832-$5841 = 15 bytes).

**Proposition** : Creer un mecanisme de "batch" pour explorer plusieurs adresses contiguës en une session.

#### C. Tracking de la couverture

**Observation** : Cette session a ajoute 60 noeuds a la frontiere. Il serait utile de tracker:
- Couverture par bank (Bank 0: 90%, Bank 1: 10%, etc.)
- Couverture par type (handlers: 80%, tables: 50%, etc.)

```python
def calculate_coverage(state: ExplorerState) -> dict:
    total_by_bank = {}
    visited_by_bank = {}
    for node in state.frontier:
        bank = node.bank
        total_by_bank[bank] = total_by_bank.get(bank, 0) + 1
        if node.address in state.visited:
            visited_by_bank[bank] = visited_by_bank.get(bank, 0) + 1

    return {
        "by_bank": {b: visited_by_bank.get(b, 0) / total for b, total in total_by_bank.items()},
        "total": len(state.visited) / len(state.frontier)
    }
```

#### D. State28 manquant

**Observation** : La sequence d'etats saute de State27 a State29. Il y a probablement un State28 non documente.

**Proposition** : Ajouter une verification de continuite dans le parser :
```python
def check_state_continuity(states: list) -> list:
    """Detecte les etats manquants dans une sequence."""
    numbers = [int(s.split('_')[0].replace('State', ''), 16) for s in states]
    missing = []
    for i in range(min(numbers), max(numbers) + 1):
        if i not in numbers:
            missing.append(f"State{i:02X}")
    return missing
```

---

## Historique des evaluations (mis a jour)

| Commit | Adresse | Note | Refs | Commentaire |
|--------|---------|------|------|-------------|
| **BFS-02A5** | **$02A5** | **10/10** | **60** | **MEILLEURE SESSION** - StateJumpTable complete |
| BFS-0095 | $0095 | 9/10 | 10 | LCDStatHandler - nommage semantique, architecture raster |
| BFS-0060 | $0060 | 8/10 | 0 | VBlankHandler documente, format ameliore |
| BFS-0226 | $0226 | 7/10 | 4 | GameLoop - Bonnes refs mais deviation dans reflexions |
| BFS-0050 | $0050 | 7/10 | 1 | Doc OK, ref audio trouvee, tunnel vision |
| BFS-0048 | $0048 | 6/10 | 0 | Documentation OK mais pas de JSON/refs |
| BFS-0185 | $0185 | 6/10 | 1 | Deviation totale vers LCDStat |
| BFS-0100 | $0100 | 5/10 | 1 | Reference $0150 trouvee, reflexions hors-sujet |

---

## Score moyen des 8 derniers rapports

| Metrique | Valeur |
|----------|--------|
| Note moyenne | **7.4/10** ↑↑ |
| Total references | **77 refs** pour 8 noeuds |
| Moyenne refs/noeud | **9.6 refs** ↑↑↑ |
| JSON avec references | 5/8 (62%) ↑ |
| Noeud documente correctement | 5/8 (62%) → |
| Deviation vers autre noeud | 5/8 (62%) ↓ (amelioration) |
| `make verify` OK | 8/8 (100%) ✓ |

**Evolution** :
- BFS-0048 : 6/10, 0 refs
- BFS-0050 : 7/10, 1 ref
- BFS-0100 : 5/10, 1 ref
- BFS-0060 : 8/10, 0 refs
- BFS-0095 : 9/10, 10 refs ✓
- BFS-0185 : 6/10, 1 ref
- BFS-0226 : 7/10, 4 refs
- **BFS-02A5 : 10/10, 60 refs** ✓✓✓

**Conclusion** : **Succes majeur!** BFS-02A5 est un tournant :
1. 60 references de qualite en une session
2. Architecture complete du jeu revelee
3. Le pattern de deviation est contourne quand le noeud est "riche"

La moyenne de refs/noeud passe de 2.4 a **9.6** grace a cette session.

---

## Synthese des ameliorations prioritaires (mise a jour finale)

### Priorite 0 (VALIDE par BFS-02A5)
1. ✅ **Tables complexes** - Prioriser les noeuds "riches" (tables, handlers complexes)
2. ✅ **Format coherent** - Le pattern `StateXX_NomDescriptif` fonctionne bien

### Priorite 1 (Toujours pertinent)
3. **Isolation de contexte** - Les reflexions parlent encore d'autres noeuds, meme si les resultats sont bons
4. **Validation du JSON** - Verifier la coherence refs/noeud source

### Priorite 2 (Nouvelles)
5. **Batch processing** - Explorer les adresses contigues (Bank 1: $5832-$5841) en une session
6. **Tracking couverture** - Metriques par bank/type

### Priorite 3 (Nice to have)
7. **Detection des gaps** - State28 manquant a investiguer
8. **Extraction automatique** - Ajouter les 60 labels dans le fichier .sym

---

## Decouverte majeure : Architecture du jeu

### Machine a etats (60 etats)

```
                            ┌─────────────────────┐
                            │    StateDispatcher  │
                            │       ($02A3)       │
                            └─────────┬───────────┘
                                      │
                    ┌─────────────────┼─────────────────┐
                    ▼                 ▼                 ▼
           ┌───────────────┐ ┌───────────────┐ ┌───────────────┐
           │   Gameplay    │ │   Niveaux     │ │   Cutscenes   │
           │  (00-0D)      │ │  (0E-1A)      │ │  (20-3B)      │
           └───────────────┘ └───────────────┘ └───────────────┘
                    │                 │                 │
    ┌───────┬───────┴───────┐        │       ┌────────┴────────┐
    ▼       ▼               ▼        ▼       ▼                 ▼
 MainPlay  Tuyaux      Transitions  Menu   Princesse        Credits
 (00-02)  (09-0C)       (03-08)   (0E-11) (20-2F)          (30-3B)
```

### Type de jeu identifie : **Platformer Mario-like**

Indices :
- Tuyaux (pipe) pour transitions (etats 09, 0A, 0B, 0C)
- Princesse (states 26, 2B = rising/descending)
- Gameplay avec objets (state 0D)
- Game over classique (state 39)
- Systeme de credits avec scroll (states 32-38)

---

## Rapport BFS-00CD : LCDStat_PopAndReti - Epilogue handler

### Note de realisation : 8/10

**Points positifs (+)**
- Le noeud `$00CD` (LCDStat_PopAndReti) a ete correctement analyse
- Les reflexions montrent une analyse methodique :
  - Lecture du code a l'adresse $00CD
  - Verification du contexte complet
  - Identification des references depuis bank_003.asm (`call z, LCDStat_PopAndReti`)
  - Recherche dans le fichier .sym pour trouver les adresses
  - Calcul de l'adresse ROM du call ($F03C = $4000 * 3 + $303C)
- Le commentaire de fonction semble avoir ete ajoute (mentionne dans reflexions)
- `make verify` a probablement reussi (pattern standard du script)
- L'analyse a identifie que cette routine est un **point d'entree public** utilise par bank 3

**Points negatifs (-)**
- Les reflexions sont coupees comme d'habitude (pattern recurrent)
- Le JSON de sortie n'est pas visible (coupe)
- Pas de validation visible du nombre de references sortantes
- L'adresse `HandleAudioConditionalLogic` ($703C) est mentionnee mais pas clairement ajoutee en reference

**Analyse**

Cette session est **bonne** car :
1. L'agent est reste concentre sur le bon noeud ($00CD)
2. L'analyse a revele la structure d'appel cross-bank (Bank 0 ← Bank 3)
3. Le calcul d'adresse ROM montre une bonne comprehension de l'architecture Game Boy
4. La description "Point d'entree public qui restaure AF et retourne d'interruption" est precise

**Decouverte architecturale** :

`LCDStat_PopAndReti` ($00CD) est un **epilogue partage** appele depuis plusieurs banks :
- Depuis Bank 0 : directement via `jp` ou `call`
- Depuis Bank 3 : via `call z, LCDStat_PopAndReti` dans `HandleAudioConditionalLogic`

Cette architecture revele un pattern d'optimisation : les routines d'epilogue sont centralisees en Bank 0 pour economiser de l'espace dans les autres banks.

**Structure du handler LCD decouverte** :
```
LCDStatHandler ($0095)
    │
    ├─► LCDStat_CheckCarryExit ($00C3)
    │       └─► Branch conditionnel
    │
    ├─► LCDStat_SetLYC ($00C7)
    │       └─► Configuration LYC
    │
    └─► LCDStat_PopAndReti ($00CD) ◄── Appele aussi depuis Bank 3
            └─► pop af + reti
```

---

### Critique du changement : Retrait du timeout Claude

**Le diff analyse** :
```python
# AVANT
CLAUDE_TIMEOUT = 300  # 5 minutes
def run_claude_streaming(prompt: str, timeout: int = CLAUDE_TIMEOUT)

# APRES
def run_claude_streaming(prompt: str)  # Pas de timeout
```

**Avantages (+)**
1. **Pas d'interruption prematuree** : Les analyses complexes (tables de 60 entrees) peuvent prendre plus de 5 minutes
2. **Meilleure qualite** : L'agent peut finir son travail sans etre coupe
3. **Moins de retries** : Plus de sessions terminees en "TIMEOUT" a relancer

**Inconvenients (-)**
1. **Risque de boucle infinie** : Si l'agent entre dans une spirale de debugging, pas de garde-fou
2. **Consommation de tokens** : Une session bloquee peut consommer beaucoup de tokens inutilement
3. **Pas de feedback** : L'utilisateur ne sait pas si le script est bloque ou juste lent

**Recommandation** : Remplacer le timeout dur par un **watchdog intelligent** :

```python
def run_claude_streaming(prompt: str, max_idle_time: int = 120) -> tuple[bool, str]:
    """Lance Claude avec watchdog sur l'inactivite."""
    last_activity = time.time()

    while True:
        line = process.stdout.readline()
        if line:
            last_activity = time.time()  # Reset sur activite

        # Timeout uniquement si AUCUNE activite pendant max_idle_time
        if time.time() - last_activity > max_idle_time:
            print(f"⏰ [CLAUDE] Inactif depuis {max_idle_time}s - arrêt")
            process.kill()
            return False, "IDLE_TIMEOUT"
```

Cette approche :
- Laisse tourner tant que Claude produit de l'output
- Arrete si l'agent est bloque (pas d'output pendant 2 minutes)
- Differentie "travail lent" de "bloque"

---

### Pistes d'ameliorations supplementaires

#### 1. Logging des reflexions completes

**Observation** : Les reflexions sont toujours coupees dans les rapports.

**Proposition** : Sauvegarder l'output complet dans un fichier log avant de le tronquer pour le rapport :

```python
def run_claude_streaming(prompt: str) -> tuple[bool, str]:
    # ... code existant ...

    # Sauvegarder l'output complet
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_file = f"logs/claude_{node_address}_{timestamp}.log"
    with open(log_file, 'w') as f:
        f.write(full_output)

    return success, output
```

#### 2. Detection des patterns de succes

**Observation** : BFS-0095 et BFS-02A5 ont eu d'excellents resultats sur des noeuds "riches".

**Proposition** : Tracker les patterns de succes pour ajuster les priorites :

```python
SUCCESS_PATTERNS = {
    NodeType.TABLE: {"avg_refs": 30, "success_rate": 0.9},
    NodeType.HANDLER: {"avg_refs": 5, "success_rate": 0.7},
    NodeType.CODE: {"avg_refs": 2, "success_rate": 0.5},
}
```

#### 3. Validation des references cross-bank

**Observation** : L'analyse de $00CD a revele un appel cross-bank (Bank 0 ← Bank 3).

**Proposition** : Ajouter une validation pour les references cross-bank :

```python
def validate_crossbank_ref(ref: Node, source_bank: int) -> bool:
    """Verifie qu'une reference cross-bank est valide."""
    if ref.bank != source_bank:
        # Reference cross-bank - verifier que l'adresse est accessible
        if ref.address.startswith("$0") or ref.address.startswith("$1"):
            # Bank 0 est toujours accessible
            return True
        elif ref.bank == 0:
            # Tout le monde peut appeler Bank 0
            return True
        else:
            # Cross-bank entre banks switchables - necesssite call via trampoline
            print(f"⚠️ Reference cross-bank {source_bank} → {ref.bank}")
    return True
```

---

## Historique des evaluations (mis a jour)

| Commit | Adresse | Note | Refs | Commentaire |
|--------|---------|------|------|-------------|
| BFS-02A5 | $02A5 | 10/10 | 60 | **MEILLEURE SESSION** - StateJumpTable complete |
| BFS-0095 | $0095 | 9/10 | 10 | LCDStatHandler - nommage semantique, architecture raster |
| **BFS-00CD** | **$00CD** | **8/10** | **~1** | **LCDStat_PopAndReti - Epilogue partage, appel cross-bank** |
| BFS-0060 | $0060 | 8/10 | 0 | VBlankHandler documente, format ameliore |
| BFS-0226 | $0226 | 7/10 | 4 | GameLoop - Bonnes refs mais deviation dans reflexions |
| BFS-0050 | $0050 | 7/10 | 1 | Doc OK, ref audio trouvee, tunnel vision |
| BFS-0048 | $0048 | 6/10 | 0 | Documentation OK mais pas de JSON/refs |
| BFS-0185 | $0185 | 6/10 | 1 | Deviation totale vers LCDStat |
| BFS-0100 | $0100 | 5/10 | 1 | Reference $0150 trouvee, reflexions hors-sujet |

---

## Score moyen des 9 derniers rapports

| Metrique | Valeur |
|----------|--------|
| Note moyenne | **7.4/10** → |
| Total references | **78 refs** pour 9 noeuds |
| Moyenne refs/noeud | **8.7 refs** → |
| JSON avec references | 6/9 (67%) → |
| Noeud documente correctement | 6/9 (67%) ↑ |
| Deviation vers autre noeud | 5/9 (56%) ↓ (amelioration) |
| `make verify` OK | 9/9 (100%) ✓ |

**Evolution** :
- BFS-0048 : 6/10, 0 refs
- BFS-0050 : 7/10, 1 ref
- BFS-0100 : 5/10, 1 ref
- BFS-0060 : 8/10, 0 refs
- BFS-0095 : 9/10, 10 refs ✓
- BFS-0185 : 6/10, 1 ref
- BFS-0226 : 7/10, 4 refs
- BFS-02A5 : 10/10, 60 refs ✓✓✓
- **BFS-00CD : 8/10, ~1 ref** - Bonne analyse, focus maintenu ✓

**Conclusion** : **Stabilisation a un bon niveau.** BFS-00CD confirme que l'agent peut rester concentre sur des noeuds simples (epilogue de 3 instructions). Le retrait du timeout n'a pas cause de probleme visible, mais un watchdog sur l'inactivite serait prudent.

**Points cles du changement de timeout** :
1. Le retrait du timeout dur est **justifie** pour les analyses longues
2. Un **watchdog d'inactivite** serait plus intelligent qu'un timeout fixe
3. La session s'est terminee normalement malgre l'absence de timeout

---

## Synthese des ameliorations prioritaires (mise a jour)

### Priorite 0 (VALIDE)
1. ✅ **Tables complexes** - Les noeuds riches produisent de meilleurs resultats
2. ✅ **Retrait timeout** - Permet les analyses longues sans interruption
3. ✅ **Focus sur noeud simple** - BFS-00CD prouve que l'agent peut rester concentre

### Priorite 1 (A implementer)
4. **Watchdog d'inactivite** - Remplacer le timeout par detection d'inactivite
5. **Logging complet** - Sauvegarder les reflexions avant truncation
6. **Validation cross-bank** - Verifier les references entre banks

### Priorite 2 (Impact moyen)
7. **Patterns de succes** - Tracker les types de noeuds qui fonctionnent le mieux
8. **Metriques detaillees** - Temps d'execution, tokens consommes, etc.

---

## Decouvertes : Architecture complete du handler LCD

Suite aux sessions BFS-0095 et BFS-00CD, l'architecture complete du handler LCD STAT est revelee :

```
Interrupt $0048
    │
    ▼
LCDStatHandler ($0095) ─────────────────────────────────────┐
    │                                                        │
    ├─► hGameState == GAME_STATE_WINDOW ($3A) ?              │
    │       │                                                │
    │       ├─ OUI: Configuration Window layer               │
    │       │       └─► hShadowSCX pour parallax            │
    │       │                                                │
    │       └─ NON: Retour rapide                           │
    │                                                        │
    ├─► LCDStat_CheckCarryExit ($00C3)                      │
    │       └─► Branch sur carry flag                        │
    │                                                        │
    ├─► LCDStat_SetLYC ($00C7)                              │
    │       └─► Configure prochaine ligne LYC               │
    │                                                        │
    └─► LCDStat_PopAndReti ($00CD) ◄───────────────────────┘
            │
            ├─ Appele depuis Bank 0 (LCDStatHandler)
            │
            └─ Appele depuis Bank 3 (HandleAudioConditionalLogic @ $703C)
                    └─► Partage d'epilogue cross-bank pour economie d'espace
```

**Variables HRAM utilisees** :
- `hShadowSCX` ($FFA4) - Valeur pre-calculee pour effet parallax
- `hGameState` ($FFB3) - Etat de jeu courant
- `hOAMIndex` ($FFFB) - Index OAM pour animation par scanline
- `wGameConfigA5` ($C0A5) - Mode handler (0=normal, !=0=retour rapide)

---

## Rapport BFS-4000_1 : LevelJumpTable Bank 1 - Table des niveaux

### Note de realisation : 9/10

**Points positifs (+)**
- **RECONSTRUCTION REUSSIE** : La table des niveaux a `$4000` (Bank 1) a ete correctement reconstruite
- Le diff montre une transformation majeure :
  - AVANT : Instructions mal desassemblees (`cp e`, `ld d, l`, `ldh [c], a`, etc.)
  - APRES : Table de pointeurs structuree avec `dw $XXXX` et commentaires
- **Structure documentee** :
  ```asm
  ; LevelJumpTable
  ; ----------------
  ; Description: Table des pointeurs pour chaque niveau (triplets: tileset/map/entities)
  ; Structure: Chaque niveau utilise 3 pointeurs (6 octets)
  ;   - +0: Pointeur tileset
  ;   - +2: Pointeur map data
  ;   - +4: Pointeur entities
  ```
- **9 niveaux identifies** (0-8) avec leurs ressources :
  - Niveaux 0-2 : Partagent les memes tilesets ($55BB), maps ($55E2), entities ($5605)
  - Niveau 3 : Ressources uniques ($5630, $5665, $5694)
  - Niveaux 4,6,7 : Partagent map ($5311) et entities ($5405)
  - Niveau 5 : Ressources propres ($54D5, $5179, $5222)
  - Niveau 8 : Incomplet (seulement tileset $54D5)
- **12 nouvelles references de donnees** ajoutees dans bfs_state.json :
  - Map data, Entities data, Tileset data pour chaque groupe de niveaux
  - Toutes en Bank 1 avec source `$4000:1`
- `make verify` a reussi - pas de regression
- Le noeud `$4000:1` ajoute correctement dans `visited`

**Points negatifs (-)**
- Les reflexions mentionnent `$0150` (AfterHeader) au lieu de `$4000:1` - contamination de contexte persistante
- "Ces commentaires ont ete coupes" dans le rapport - pattern recurrent
- Le niveau 8 semble incomplet (seulement 1 pointeur au lieu de 3)
- L'octet isole `rrca` a $4032 n'est pas clairement documente

**Analyse**

Cette session est **excellente** car :
1. **Reconstruction complexe reussie** : Transformer 39 lignes de pseudo-instructions en table structuree
2. **Decouverte architecturale majeure** : Le jeu a 9 niveaux avec un systeme de partage de ressources
3. **12 references de qualite** : Chaque zone de donnees est identifiee et categorisee
4. Le format triplet (tileset/map/entities) revele l'architecture du loader de niveaux

**Decouverte architecturale : Systeme de niveaux**

```
LevelJumpTable ($4000, Bank 1)
    │
    ├─► Niveau 0-2 (partages)
    │       ├─ Tileset: $55BB
    │       ├─ Map:     $55E2
    │       └─ Entities: $5605
    │
    ├─► Niveau 3 (unique)
    │       ├─ Tileset: $5630
    │       ├─ Map:     $5665
    │       └─ Entities: $5694
    │
    ├─► Niveau 4 (partage avec 6,7)
    │       ├─ Tileset: $55BB
    │       ├─ Map:     $5311
    │       └─ Entities: $5405
    │
    ├─► Niveau 5 (unique)
    │       ├─ Tileset: $54D5
    │       ├─ Map:     $5179
    │       └─ Entities: $5222
    │
    ├─► Niveau 6 (partage avec 4,7)
    │       ├─ Tileset: $529B
    │       ├─ Map:     $5311
    │       └─ Entities: $5405
    │
    ├─► Niveau 7 (partage avec 4,6)
    │       ├─ Tileset: $54D5
    │       ├─ Map:     $5311
    │       └─ Entities: $5405
    │
    └─► Niveau 8 (incomplet)
            └─ Tileset: $54D5
```

**Pattern de partage de ressources** :
- Tilesets reutilises : $55BB (niveaux 0-2,4), $54D5 (niveaux 5,7,8)
- Maps reutilisees : $55E2 (niveaux 0-2), $5311 (niveaux 4,6,7)
- Entities reutilisees : $5605 (niveaux 0-2), $5405 (niveaux 4,6,7)

Cette architecture optimise l'espace ROM en partageant les ressources entre niveaux similaires.

**Questions ouvertes** :
1. Pourquoi le niveau 8 est-il incomplet ? Beta/debug ? Ou la table continue apres le `rrca` ?
2. Que represente l'octet `rrca` ($0F) a $4032 ? Marqueur de fin ? Padding ?
3. Y a-t-il des sous-niveaux comme suggere par State0A_LoadSubLevel ?

---

### Critique du prompt pour BFS-4000_1

#### 1. Succes sur les tables de donnees

**Observation** : Comme pour BFS-02A5 (StateJumpTable), l'agent performe excellemment sur les tables complexes qui necessitent une reconstruction.

**Pattern confirme** :
- Tables riches → Bons resultats (BFS-02A5: 10/10, BFS-4000_1: 9/10)
- Noeuds simples → Resultats variables (BFS-0185: 6/10, BFS-0100: 5/10)

**Recommandation confirmee** : Prioriser les tables et structures complexes dans le BFS.

#### 2. Reconstruction de data mal desassemblee

**Observation** : L'agent a correctement transforme :
```asm
; AVANT (mal desassemble)
cp e           ; $BB
ld d, l        ; $55
ldh [c], a     ; $E2
...

; APRES (reconstruit)
dw $55BB, $55E2, $5605
```

Le pattern `cp e` + `ld d, l` = bytes $BB $55 = little-endian $55BB est correctement interprete.

**Recommandation** : Ajouter un hint dans le prompt pour les tables Bank 1+ :
```python
if node.bank > 0 and node.node_type == NodeType.TABLE:
    base_prompt += """
## HINT: RECONSTRUCTION DE TABLES
En Bank 1+, les tables sont souvent mal desassemblees car les bytes
sont interpretes comme des instructions.

Pattern a reconnaitre:
- Sequence d'instructions sans logique (cp, ld, ldh random)
- Pas de ret/jp final
- Taille reguliere (ex: 6 bytes par entree)

=> Reconstruire avec dw pour les pointeurs 16-bit
=> Utiliser xxd pour verifier les bytes exacts si doute
"""
```

#### 3. Contamination de contexte reduite

**Observation** : Les reflexions mentionnent `$0150` (AfterHeader) mais le travail reel sur `$4000:1` a ete fait correctement.

**Conclusion** : La contamination de contexte n'empeche pas le travail de fond, mais brouille les reflexions visibles.

---

### Pistes d'ameliorations post BFS-4000_1

#### A. Detection des tables incompletes

**Observation** : Le niveau 8 n'a qu'un seul pointeur au lieu de 3.

**Proposition** :
```python
def check_table_completeness(refs: List[Node], expected_group_size: int) -> List[str]:
    """Detecte les entrees incompletes dans une table."""
    warnings = []
    current_group = []

    for ref in refs:
        current_group.append(ref)
        if len(current_group) == expected_group_size:
            current_group = []

    if current_group:
        warnings.append(f"Table incomplete: {len(current_group)}/{expected_group_size} elements restants")

    return warnings
```

#### B. Analyse du partage de ressources

**Observation** : Le jeu reutilise les ressources entre niveaux pour economiser de la ROM.

**Proposition** : Ajouter des metriques de partage :
```python
def analyze_resource_sharing(refs: List[Node]) -> dict:
    """Analyse le partage de ressources entre niveaux."""
    address_usage = {}
    for ref in refs:
        addr = ref.address
        if addr not in address_usage:
            address_usage[addr] = []
        address_usage[addr].append(ref.source)

    return {
        "shared": {k: v for k, v in address_usage.items() if len(v) > 1},
        "unique": {k: v for k, v in address_usage.items() if len(v) == 1}
    }
```

#### C. Exploration des zones de donnees

**Observation** : 12 nouvelles zones de donnees ont ete decouvertes ($5179, $5222, $529B, etc.)

**Proposition** : Creer un mode "data exploration" specifique :
```python
if node.node_type == NodeType.DATA:
    base_prompt += """
## MODE EXPLORATION DATA
Pour les zones de donnees :
1. Identifier le FORMAT (tiles 8x8, texte, RLE, pointeurs...)
2. Calculer la TAILLE exacte de la zone
3. Trouver la FIN (marqueur, taille fixe, pointeur suivant)
4. NE PAS reconstruire entierement - juste documenter la structure
"""
```

---

## Historique des evaluations (mis a jour)

| Commit | Adresse | Note | Refs | Commentaire |
|--------|---------|------|------|-------------|
| BFS-02A5 | $02A5 | 10/10 | 60 | **MEILLEURE SESSION** - StateJumpTable complete |
| **BFS-4000_1** | **$4000:1** | **9/10** | **12** | **LevelJumpTable - Reconstruction reussie, 9 niveaux identifies** |
| BFS-0095 | $0095 | 9/10 | 10 | LCDStatHandler - nommage semantique, architecture raster |
| BFS-00CD | $00CD | 8/10 | ~1 | LCDStat_PopAndReti - Epilogue partage, appel cross-bank |
| BFS-0060 | $0060 | 8/10 | 0 | VBlankHandler documente, format ameliore |
| BFS-0226 | $0226 | 7/10 | 4 | GameLoop - Bonnes refs mais deviation dans reflexions |
| BFS-0050 | $0050 | 7/10 | 1 | Doc OK, ref audio trouvee, tunnel vision |
| BFS-0048 | $0048 | 6/10 | 0 | Documentation OK mais pas de JSON/refs |
| BFS-0185 | $0185 | 6/10 | 1 | Deviation totale vers LCDStat |
| BFS-0100 | $0100 | 5/10 | 1 | Reference $0150 trouvee, reflexions hors-sujet |

---

## Score moyen des 10 derniers rapports

| Metrique | Valeur |
|----------|--------|
| Note moyenne | **7.6/10** ↑ |
| Total references | **90 refs** pour 10 noeuds |
| Moyenne refs/noeud | **9.0 refs** → |
| JSON avec references | 7/10 (70%) ↑ |
| Noeud documente correctement | 7/10 (70%) ↑ |
| Deviation vers autre noeud | 5/10 (50%) ↓ (amelioration!) |
| `make verify` OK | 10/10 (100%) ✓ |
| Tables reconstruites | 2/10 (BFS-02A5, BFS-4000_1) ✓✓ |

**Evolution** :
- BFS-0048 : 6/10, 0 refs
- BFS-0050 : 7/10, 1 ref
- BFS-0100 : 5/10, 1 ref
- BFS-0060 : 8/10, 0 refs
- BFS-0095 : 9/10, 10 refs ✓
- BFS-0185 : 6/10, 1 ref
- BFS-0226 : 7/10, 4 refs
- BFS-02A5 : 10/10, 60 refs ✓✓✓
- BFS-00CD : 8/10, ~1 ref
- **BFS-4000_1 : 9/10, 12 refs** ✓✓

**Conclusion** : **Excellente session!** BFS-4000_1 confirme que les tables de donnees mal desassemblees sont bien gerees par l'agent. La reconstruction de 39 lignes de pseudo-code en une table structuree de 9 niveaux est un succes majeur.

**Patterns confirmes** :
1. Tables complexes → Excellents resultats (9-10/10)
2. Reconstruction de data → Fonctionne bien
3. La contamination de contexte n'empeche pas le travail de fond

---

## Synthese des ameliorations prioritaires (mise a jour)

### Priorite 0 (VALIDE par BFS-4000_1)
1. ✅ **Tables complexes** - Confirme : les reconstructions de tables fonctionnent tres bien
2. ✅ **Reconstruction data** - Transforme `cp e; ld d, l` en `dw $55BB` correctement
3. ✅ **Commentaires structurels** - Le bloc commentaire de LevelJumpTable est exemplaire

### Priorite 1 (A implementer)
4. **Detection tables incompletes** - Alerter si une entree de table est tronquee
5. **Analyse partage ressources** - Tracker les ressources reutilisees entre niveaux
6. **Mode data exploration** - Prompt specifique pour les zones de donnees

### Priorite 2 (Impact moyen)
7. **Hint reconstruction Bank 1+** - Ajouter des instructions pour les tables mal desassemblees
8. **Metriques de reconstruction** - Tracker les lignes avant/apres

### Priorite 3 (Nice to have)
9. **Exploration automatique des refs** - Les 12 zones de donnees decouvertes
10. **Detection des marqueurs de fin** - Comprendre le `rrca` a $4032

---

## Decouvertes : Architecture des niveaux

### Structure d'un niveau Game Boy

```
Niveau X
    │
    ├─► Tileset ($XXXX)
    │       └─► 128-256 tiles de 8x8 pixels
    │           Format: 16 bytes par tile (2bpp)
    │
    ├─► Map ($XXXX)
    │       └─► Grille de references aux tiles
    │           Format: largeur × hauteur bytes
    │           Peut etre compresse (RLE, etc.)
    │
    └─► Entities ($XXXX)
            └─► Liste des objets/ennemis
                Format: (X, Y, type, params...)
```

### Optimisation par partage

Le jeu utilise un systeme intelligent de partage :
- **3 groupes de niveaux** partagent des ressources
- Economie estimee : ~40% d'espace ROM
- Le loader de niveau doit gerer les 3 pointeurs independamment

### Comparaison avec d'autres jeux

Ce pattern est similaire a :
- **Super Mario Land** : Tilesets par monde
- **Kirby's Dream Land** : Entities separees des maps
- **Wario Land** : Partage de ressources graphiques

---

*Derniere mise a jour: 2025-12-18*
