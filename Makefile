# =============================================================================
# Makefile - Build et vérification bit-perfect de la ROM Game Boy
# =============================================================================

.PHONY: all build verify clean

# Cible par défaut
all: build

# Build la ROM depuis les sources désassemblées
build:
	@echo "=== Build de la ROM ==="
	$(MAKE) -C src game.gb
	@echo ""
	@echo "Build terminé: src/game.gb"

# Build et vérifie que le hash est identique à l'original
verify: build
	@echo ""
	@echo "=== Vérification des hash ==="
	@echo "Vérification SHA256..."
	@if command -v shasum >/dev/null 2>&1; then \
		BUILT_SHA256=$$(shasum -a 256 src/game.gb | cut -d' ' -f1); \
	else \
		BUILT_SHA256=$$(sha256sum src/game.gb | cut -d' ' -f1); \
	fi; \
	EXPECTED_SHA256=$$(cat checksum.sha256); \
	if [ "$$BUILT_SHA256" = "$$EXPECTED_SHA256" ]; then \
		echo "[OK] SHA256: $$BUILT_SHA256"; \
	else \
		echo "[ERREUR] SHA256 différent!"; \
		echo "  Attendu:  $$EXPECTED_SHA256"; \
		echo "  Obtenu:   $$BUILT_SHA256"; \
		exit 1; \
	fi
	@echo "Vérification MD5..."
	@if command -v md5 >/dev/null 2>&1; then \
		BUILT_MD5=$$(md5 -q src/game.gb); \
	else \
		BUILT_MD5=$$(md5sum src/game.gb | cut -d' ' -f1); \
	fi; \
	EXPECTED_MD5=$$(cat checksum.md5); \
	if [ "$$BUILT_MD5" = "$$EXPECTED_MD5" ]; then \
		echo "[OK] MD5: $$BUILT_MD5"; \
	else \
		echo "[ERREUR] MD5 différent!"; \
		echo "  Attendu:  $$EXPECTED_MD5"; \
		echo "  Obtenu:   $$BUILT_MD5"; \
		exit 1; \
	fi
	@echo ""
	@echo "=== VERIFICATION REUSSIE ==="
	@echo "La ROM compilée est bit-perfect avec l'original."

# Nettoie les fichiers générés
clean:
	@echo "=== Nettoyage ==="
	$(MAKE) -C src clean
	@echo "Nettoyage terminé."
