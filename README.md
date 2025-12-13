# Projet Game Boy ASM

Exercice pédagogique : comprendre, documenter et enrichir des sources ASM Game Boy.

## Contexte

Notre prof nous a confié une quête : partir de sources ASM d'un vrai projet Game Boy, les comprendre, les documenter, puis les enrichir.

**Contrainte bit-perfect** : le binaire compilé doit être identique octet pour octet à l'original. On peut renommer des labels, ajouter des commentaires, restructurer le code... tant que le résultat binaire reste identique (vérifié par checksums SHA256 + MD5).

## Premiers pas

```bash
# 1. Installer les dépendances
./scripts/setup.sh           # Linux / macOS
./scripts/install-hooks.sh   # Hook pre-commit (protège des régressions)

# 2. Vérifier que tout fonctionne
make verify
```

Si `make verify` affiche `VERIFICATION REUSSIE`, l'environnement est prêt.

## Sources ASM

Le code est organisé en 4 banks (fichiers dans `src/`) :
- `game.asm` : point d'entrée, inclut les autres fichiers
- `bank_000.asm` : bank 0 (ROM fixe, contient le header et le code principal)
- `bank_001.asm` : bank 1
- `bank_002.asm` : bank 2
- `bank_003.asm` : bank 3
- `hardware.inc` : constantes matérielles Game Boy

## Commandes

```bash
make          # Compile (src/game.gb)
make verify   # Compile + vérifie checksums
make clean    # Nettoie
```

## Documentation

- [CLAUDE.md](CLAUDE.md) : conventions et règles du projet
- [ROADMAP.md](ROADMAP.md) : tâches et progression
- [docs/adr/](docs/adr/) : décisions d'architecture
