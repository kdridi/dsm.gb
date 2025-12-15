# Projet Game Boy ASM

## Principe
**Hash identique = test de non-régression.** `make verify` TOUJOURS après modification.

## Commandes essentielles
```bash
make verify              # Valide SHA256+MD5 identiques
xxd -s 0xADDR -l N src/game.gb  # Analyse données brutes
```

## Conventions de nommage

| Type | Format | Exemple |
|------|--------|---------|
| Routine | `VerbeCamelCase` | `UpdateScrollColumn` |
| Handler | `*Handler` | `VBlankHandler` |
| Table | `*JumpTable`, `*Data` | `StateJumpTable` |
| HRAM | `hCamelCase` | `hGameState` |
| WRAM | `wCamelCase` | `wPlayerX` |
| Constante | `UPPER_SNAKE` | `PALETTE_STANDARD` |

## Fichiers source
- `hardware.inc` : constantes hardware GB (ne pas modifier)
- `constants.inc` : constantes projet
- `macros.inc` : macros (utilitaires + free functions)
- `bank_00X.asm` : code par bank

## Reconstruction data mal désassemblée

Symptômes : `db $XX`, `ld b, $XX` répétés, pas de `ret`/`jp` logiques.

```asm
; AVANT (mal désassemblé)    ; APRÈS (reconstruit)
db $10                        dw $0610  ; État $00
ld b, $a5                     dw $06A5  ; État $01
```

## Règles
- Commits : `[BFS-$ADDR] description` ou `[ROADMAP-XXX] description`
- Code/labels : anglais | Commentaires : français
- **git commit TOUJOURS seul** (pas de `&&`)

---

## Mode BFS automatisé

Quand appelé par `scripts/bfs_explorer.py` :

### Mission
1. Lire code à l'adresse indiquée
2. Renommer labels génériques → noms descriptifs
3. Remplacer magic numbers → constantes
4. Reconstruire data si mal désassemblée
5. `make verify`
6. Produire JSON ci-dessous

### Sortie OBLIGATOIRE

```json
{
  "explored": "$XXXX",
  "type_confirmed": "code|data|table|handler",
  "label_renamed": "NouveauNom",
  "references_out": [
    {"address": "$XXXX", "type": "code", "description": "...", "bank": 0}
  ],
  "summary": "Une phrase"
}
```

### Interdits en mode BFS
- ❌ git commit (le script gère)
- ❌ Modifier hors du nœud demandé
- ❌ Oublier make verify
- ❌ Oublier le JSON final
