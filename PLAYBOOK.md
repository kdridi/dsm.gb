# PLAYBOOK ULTIME - Décompilation Game Boy ASM

> **Ce fichier est la BIBLE de l'orchestrateur BFS.**
> **Basé sur l'analyse de 907 explorations (53 succès, 854 échecs).**
> **Taux de succès initial : 5.8% → Objectif : 80%+**

---

## 🎯 RÈGLES D'OR (JAMAIS VIOLER)

### RÈGLE #1 : LIMITE DE RÉFLEXION
```
SI log_length > 1500 chars ALORS ABANDONNER
```
- 37/53 succès avaient un log < 1500 chars (70%)
- L'overthinking cause 17% des échecs

### RÈGLE #2 : LIMITE DE PROBLÈMES
```
SI problems_count >= 2 ALORS ABANDONNER
```
- 34/53 succès avaient 0 problème (64%)
- 199/854 échecs avaient 3+ problèmes (23%)

### RÈGLE #3 : LIMITE D'OUTILS
```
SI tools_count > 2 ALORS REPENSER L'APPROCHE
```
- 52/53 succès utilisaient max 2 outils (98%)
- Outils gagnants : `make_verify` (49), `xxd` (9)

### RÈGLE #4 : INTERDICTION RECONSTRUCTION
```
JAMAIS reconstruire du code mal désassemblé dans le flux principal
```
- `bad_disassembly` cause 36% des échecs (309/854)
- La reconstruction est une tâche SÉPARÉE

### RÈGLE #5 : FAIL FAST
```
Au premier signe de bataille de bytes → ABANDONNER
```
- Les batailles de bytes ont 100% d'échec
- Indicateurs : "byte par byte", "inversé", "décalage"

---

## 📊 STATISTIQUES DE RÉFÉRENCE

### Taux de succès par type
| Type | Succès | Total | Taux |
|------|--------|-------|------|
| code | 25 | 453 | 5.5% |
| data | 16 | 230 | 7.0% |
| table | 9 | 118 | 7.6% |
| handler | 3 | 106 | 2.8% |

### Taux de succès par complexité
| Complexité | Succès | Stratégie |
|------------|--------|-----------|
| simple | 21 | ✅ Traiter |
| medium | 21 | ✅ Traiter |
| complex | 5 | ⚠️ Prudence |
| nightmare | 6 | ❌ Éviter |

---

## 💀 ANTIPATTERNS (NE JAMAIS FAIRE)

### DEATH_BY_DISASSEMBLY (36% des échecs)
**Symptômes :**
- Instructions `db $XX` répétées
- Pas de `ret`/`jp` logiques
- Octets qui ressemblent à des données

**Action :** SKIP le noeud, le marquer pour reconstruction ultérieure

### DEATH_BY_OVERTHINKING (17% des échecs)
**Symptômes :**
- Log qui dépasse 3000 chars
- Multiples tentatives de correction
- Phrases comme "attendez", "en fait", "WTF"

**Action :** TIMEOUT après 60s ou 1500 chars

### DEATH_BY_ACCUMULATION (23% des échecs)
**Symptômes :**
- Plus de 2 problèmes détectés
- Corrections qui causent d'autres erreurs
- Hash qui change plusieurs fois

**Action :** ABANDONNER après le 2ème problème

### DEATH_BY_BYTES (4% des échecs)
**Symptômes :**
- Comparaison byte par byte
- Mots "décalage", "inversé", "manque"
- Plus de 2 appels à `xxd`

**Action :** ABANDONNER immédiatement

---

## 🏆 PATTERNS GAGNANTS

### PATTERN: CLEAN_EXECUTION (64% des succès)
```
1. Lire le code (grep/Read)
2. Identifier le type
3. Ajouter commentaire FR si code/handler
4. make verify
5. TERMINÉ
```

### PATTERN: MINIMAL_TOOLS (98% des succès)
```
Outils autorisés par phase:
- ANALYZE: grep, Read (lecture seule)
- DOCUMENT: Edit (commentaires uniquement)
- VALIDATE: make verify
```

### PATTERN: SHORT_LOG (70% des succès)
```
Prompt atomique → Réponse courte → Action unique → Validation
```

---

## 📋 TEMPLATES COMMENTAIRES FR

### Pour une ROUTINE (code)
```asm
; NomDeLaRoutine
; --------------
; Description: Ce que fait la routine en une phrase
; In:  a = param1, hl = pointeur vers données
; Out: a = résultat, carry = si erreur
; Modifie: bc, de
```

### Pour un HANDLER (interruption)
```asm
; NomHandler
; ----------
; Description: Handler d'interruption pour [événement]
; In:  (contexte interruption)
; Out: (aucun)
; Modifie: af (sauvegardé/restauré)
; Note: Appelé [fréquence] fois par seconde
```

### Pour une TABLE
```asm
; NomTable
; --------
; Description: Table de [type] pour [usage]
; Format: [description du format, ex: 2 bytes par entrée]
; Entrées: [nombre] entrées
; Référencé par: [routines qui utilisent cette table]
```

### Pour des DATA
```asm
; NomData
; -------
; Description: Données [type] pour [usage]
; Taille: [N] bytes
; Format: [description]
```

---

## 🔄 PIPELINE D'EXPLORATION

```
┌─────────────────────────────────────────────────────────────┐
│                      PHASE 1: ANALYZE                        │
│  Durée max: 30s | Outils: grep, Read | Output: JSON         │
├─────────────────────────────────────────────────────────────┤
│  1. Localiser l'adresse dans .asm ou .sym                   │
│  2. Identifier le TYPE (code/data/table/handler)            │
│  3. Lister les références sortantes                         │
│  4. Détecter si reconstruction nécessaire                   │
│  5. Produire JSON structuré                                 │
│                                                              │
│  SI needs_reconstruction ALORS marquer et SKIP              │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                      PHASE 2: DOCUMENT                       │
│  Durée max: 45s | Outils: Edit | Condition: code/handler    │
├─────────────────────────────────────────────────────────────┤
│  1. Ajouter bloc commentaire FR (template ci-dessus)        │
│  2. Renommer label si générique (Jump_XXXX → NomDescriptif) │
│  3. NE PAS modifier les instructions                        │
│  4. NE PAS reconstruire les données                         │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                      PHASE 3: VALIDATE                       │
│  Durée max: 60s | Outils: make verify                       │
├─────────────────────────────────────────────────────────────┤
│  SI hash OK:                                                │
│    → Commit                                                 │
│    → Ajouter références à la frontière                      │
│  SI hash FAIL:                                              │
│    → git checkout .                                         │
│    → Marquer noeud comme FAILED                             │
│    → NE PAS réessayer                                       │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚫 ZONES INTERDITES

### Ne JAMAIS explorer en premier
- `$4000:X` (LevelJumpTable) - Trop de déviation
- Zones avec `db $XX` répétés - Données mal désassemblées
- Adresses HRAM (`$FFXX`) sans contexte - Variables volatiles

### Explorer avec PRUDENCE
- Tables de pointeurs - Vérifier le format d'abord
- Handlers audio (`$7FXX` Bank 3) - Complexes
- Zones de tiles/sprites - Data pure, pas de commentaires

### Explorer en PRIORITÉ
- Vecteurs d'interruption (`$0040`, `$0048`, `$0050`)
- Entry points (`$0100`, `$0150`)
- Routines nommées dans .sym

---

## 📈 MÉTRIQUES DE SUCCÈS

### Un noeud est SUCCÈS si :
- ✅ `make verify` passe
- ✅ Log < 1500 chars
- ✅ 0 ou 1 problème rencontré
- ✅ Max 2 outils utilisés

### Un noeud est ÉCHEC si :
- ❌ Hash différent après modification
- ❌ Plus de 2 tentatives de correction
- ❌ Log > 3000 chars
- ❌ Bataille de bytes détectée

---

## 🔧 COMMANDES ESSENTIELLES

```bash
# Vérification hash (TOUJOURS à la fin)
make verify

# Lecture bytes bruts (si vraiment nécessaire)
xxd -s 0xADDR -l 32 src/game.gb

# Recherche dans le code
grep -n "PATTERN" src/bank_00*.asm

# Annulation modifications
git checkout .

# Ne JAMAIS faire en mode BFS
git commit  # Le script gère
```

---

## 📝 CHECKLIST AVANT EXPLORATION

- [ ] Le noeud n'est pas dans `failed_nodes` ?
- [ ] Le noeud n'est pas déjà `visited` ?
- [ ] Le type supposé est cohérent ?
- [ ] Pas de signe de `bad_disassembly` ?
- [ ] Complexité estimée < nightmare ?

---

## 🎮 OBJECTIF FINAL

> **Décompiler avec précision et commentaires FR toute ROM Game Boy**

Pour y arriver :
1. Appliquer ce PLAYBOOK à la lettre
2. Fail fast, ne jamais s'acharner
3. Accumuler les références, pas les échecs
4. La reconstruction est une tâche SÉPARÉE
5. 80%+ de succès = progression rapide

---

*Généré par analyse de 907 explorations BFS*
*Dernière mise à jour : 2025-12-18*
