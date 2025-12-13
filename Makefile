# =============================================================================
# Makefile - Build et vérification bit-perfect
# =============================================================================

.PHONY: all build verify clean

ROM := src/game.gb

all: build

# Compile le projet
build:
	cd src && rgbasm -o game.o game.asm
	cd src && rgblink -n game.sym -m game.map -o game.gb game.o
	cd src && rgbfix -v -p 255 game.gb

# Build et vérifie que le hash est identique à l'original
verify: build
	@echo "=== Vérification des hash ==="
	@if command -v shasum >/dev/null 2>&1; then \
		BUILT_SHA256=$$(shasum -a 256 $(ROM) | cut -d' ' -f1); \
	else \
		BUILT_SHA256=$$(sha256sum $(ROM) | cut -d' ' -f1); \
	fi; \
	EXPECTED_SHA256=$$(cat checksum.sha256); \
	if [ "$$BUILT_SHA256" = "$$EXPECTED_SHA256" ]; then \
		echo "[OK] SHA256: $$BUILT_SHA256"; \
	else \
		echo "[ERREUR] SHA256 différent!"; \
		echo "  Attendu: $$EXPECTED_SHA256"; \
		echo "  Obtenu:  $$BUILT_SHA256"; \
		exit 1; \
	fi
	@if command -v md5 >/dev/null 2>&1; then \
		BUILT_MD5=$$(md5 -q $(ROM)); \
	else \
		BUILT_MD5=$$(md5sum $(ROM) | cut -d' ' -f1); \
	fi; \
	EXPECTED_MD5=$$(cat checksum.md5); \
	if [ "$$BUILT_MD5" = "$$EXPECTED_MD5" ]; then \
		echo "[OK] MD5: $$BUILT_MD5"; \
	else \
		echo "[ERREUR] MD5 différent!"; \
		echo "  Attendu: $$EXPECTED_MD5"; \
		echo "  Obtenu:  $$BUILT_MD5"; \
		exit 1; \
	fi
	@echo "=== VERIFICATION REUSSIE ==="

# Nettoie les fichiers générés
clean:
	rm -f src/game.o src/game.gb src/game.sym src/game.map
