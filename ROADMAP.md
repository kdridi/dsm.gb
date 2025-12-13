# ROADMAP

## Phase 1 : Setup & Validation bit-perfect ✓
*Terminée le 2025-12-13*

- [x] [000001] Créer scripts setup (vérifie/installe rgbds, cross-platform)
- [x] [000002] Stocker hash de référence (SHA256 + MD5)
- [x] [000003] Obtenir les sources ASM initiales
- [x] [000004] Créer Makefile (build + verify) et valider compilation bit-perfect
- [x] [000005] Hook pre-commit pour protection anti-régression

## Phase 2 : Analyse & Documentation

Objectif : comprendre le code et le documenter progressivement.

- [ ] Identifier le point d'entrée (reset vector) et la boucle principale
- [ ] Renommer les labels `Jump_000_XXXX` en noms explicites
- [ ] Documenter les routines d'initialisation (bank 0)
- [ ] Identifier les routines graphiques (VBlank, tiles, sprites)
- [ ] Localiser et documenter les données (textes, graphismes, sons)

*Ajouter des tâches au fur et à mesure des découvertes.*

## Découvertes

*Ajouter ici les découvertes au fil de l'analyse.*
