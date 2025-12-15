#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
BFS Explorer - Parcours automatique du code ASM Game Boy
=========================================================

Ce script orchestre l'exploration systématique du code en utilisant Claude
pour analyser chaque nœud (adresse/routine), puis valide avec make verify
et commit les changements.

Usage:
    python scripts/bfs_explorer.py [--dry-run] [--max-nodes N] [--push-every N]
"""

import subprocess
import json
import sys
import os
import re
import time
import argparse
import threading
import select
from pathlib import Path
from dataclasses import dataclass, field
from typing import Set, List, Optional
from enum import Enum

# Configuration
CLAUDE_TIMEOUT = 300  # 5 minutes
CLAUDE_MODEL = "sonnet"  # Alias pour la dernière version de Sonnet
STATE_FILE = "scripts/bfs_state.json"
PUSH_EVERY = 5  # Push tous les N commits


class NodeType(str, Enum):
    CODE = "code"
    DATA = "data"
    HANDLER = "handler"
    TABLE = "table"
    UNKNOWN = "unknown"


@dataclass
class Node:
    """Un nœud à explorer dans le graphe de code."""
    address: str  # Ex: "$0185" ou "SystemInit"
    node_type: NodeType
    description: str
    source: str  # D'où vient cette référence
    bank: int = 0
    priority: int = 0  # Plus bas = plus prioritaire

    def to_dict(self) -> dict:
        return {
            "address": self.address,
            "node_type": self.node_type.value,
            "description": self.description,
            "source": self.source,
            "bank": self.bank,
            "priority": self.priority
        }

    @classmethod
    def from_dict(cls, d: dict) -> "Node":
        return cls(
            address=d["address"],
            node_type=NodeType(d["node_type"]),
            description=d["description"],
            source=d["source"],
            bank=d.get("bank", 0),
            priority=d.get("priority", 0)
        )


@dataclass
class ExplorerState:
    """État persistant de l'explorateur."""
    frontier: List[Node] = field(default_factory=list)
    visited: Set[str] = field(default_factory=set)
    commits_since_push: int = 0
    total_explored: int = 0

    def save(self, path: str):
        """Sauvegarde l'état dans un fichier JSON."""
        data = {
            "frontier": [n.to_dict() for n in self.frontier],
            "visited": list(self.visited),
            "commits_since_push": self.commits_since_push,
            "total_explored": self.total_explored
        }
        with open(path, 'w') as f:
            json.dump(data, f, indent=2)
        print(f"\n💾 [STATE] Sauvegardé: {len(self.frontier)} en frontière, {len(self.visited)} visités")

    @classmethod
    def load(cls, path: str) -> "ExplorerState":
        """Charge l'état depuis un fichier JSON."""
        if not os.path.exists(path):
            return cls()

        with open(path, 'r') as f:
            data = json.load(f)

        state = cls()
        state.frontier = [Node.from_dict(n) for n in data.get("frontier", [])]
        state.visited = set(data.get("visited", []))
        state.commits_since_push = data.get("commits_since_push", 0)
        state.total_explored = data.get("total_explored", 0)

        print(f"📂 [STATE] Chargé: {len(state.frontier)} en frontière, {len(state.visited)} visités")
        return state


def get_initial_frontier() -> List[Node]:
    """Points d'entrée initiaux pour le BFS."""
    return [
        # Couche 0: Points d'entrée absolus
        Node("$0000", NodeType.CODE, "RST $00 - Soft reset", "boot", 0, 0),
        Node("$0028", NodeType.CODE, "RST $28 - Jump table dispatcher", "boot", 0, 0),
        Node("$0040", NodeType.HANDLER, "VBlank interrupt vector", "boot", 0, 0),
        Node("$0048", NodeType.HANDLER, "LCD STAT interrupt vector", "boot", 0, 0),
        Node("$0050", NodeType.HANDLER, "Timer interrupt vector", "boot", 0, 0),
        Node("$0100", NodeType.CODE, "ROM Entry point", "boot", 0, 0),

        # Couche 1: Handlers principaux
        Node("$0060", NodeType.HANDLER, "VBlankHandler", "$0040", 0, 1),
        Node("$0095", NodeType.HANDLER, "LCDStatHandler", "$0048", 0, 1),
        Node("$0185", NodeType.CODE, "SystemInit - Init système", "$0100", 0, 1),
        Node("$0226", NodeType.CODE, "GameLoop - Boucle principale", "SystemInit", 0, 1),

        # Couche 2: Tables de dispatch
        Node("$02A5", NodeType.TABLE, "StateJumpTable - 60 états", "StateDispatcher", 0, 2),
        Node("$4000:1", NodeType.TABLE, "LevelJumpTable Bank 1", "level loader", 1, 2),
        Node("$4000:2", NodeType.TABLE, "LevelJumpTable Bank 2", "level loader", 2, 2),
        Node("$4000:3", NodeType.TABLE, "LevelJumpTable Bank 3", "level loader", 3, 2),

        # Couche 3: Routines Bank 3
        Node("$47F2", NodeType.CODE, "JoypadReadHandler", "GameLoop", 3, 3),
        Node("$4823", NodeType.CODE, "AnimationHandler", "CallBank3Handler", 3, 3),
    ]


def build_prompt(node: Node, state: ExplorerState) -> str:
    """Construit le prompt pour explorer un nœud spécifique."""

    bank_file = f"bank_00{node.bank}.asm" if node.bank < 10 else f"bank_0{node.bank}.asm"

    base_prompt = f"""Tu explores le code ASM Game Boy dans le cadre d'un parcours BFS systématique.

## Nœud actuel à analyser

- **Adresse**: {node.address}
- **Type**: {node.node_type.value}
- **Description**: {node.description}
- **Source**: {node.source}
- **Bank**: {node.bank}
- **Fichier**: src/{bank_file}

## Ta mission

1. **Lire le code** à cette adresse dans src/{bank_file}
2. **Analyser** le code/données:
   - Si c'est du CODE: comprendre la logique, identifier les calls/jumps sortants
   - Si c'est une TABLE: identifier les entrées et leurs cibles
   - Si c'est des DATA: identifier le format (tiles, texte, pointeurs...)
3. **Améliorer** le code source:
   - Renommer les labels génériques (Jump_XXXX, Call_XXXX) en noms descriptifs
   - Remplacer les magic numbers par des constantes de constants.inc
   - Si c'est une zone mal désassemblée (data comme code), la reconstruire avec db/dw
   - **Commentaires de fonction OBLIGATOIRES**: Chaque routine/handler doit avoir un bloc commentaire en début:
     ```asm
     ; NomDeLaFonction
     ; ----------------
     ; Description: Ce que fait la fonction (1-2 lignes)
     ; In:  a = paramètre1, hl = pointeur vers...
     ; Out: a = résultat, carry = si erreur
     ; Modifie: bc, de (si applicable)
     ```
   - Vérifier que les commentaires existants sont à jour et cohérents avec le code
4. **Lister les références sortantes** dans ton output final

## Format de sortie attendu

À la fin de ton analyse, produis un bloc JSON avec les nouvelles adresses découvertes:

```json
{{
  "explored": "{node.address}",
  "type_confirmed": "code|data|table|handler",
  "label_renamed": "NouveauNom ou null",
  "references_out": [
    {{"address": "$XXXX", "type": "code|data|table", "description": "...", "bank": 0}},
    ...
  ],
  "summary": "Résumé en une phrase de ce que fait ce code"
}}
```

## Règles importantes

- **TOUJOURS** terminer par `make verify` pour valider que le hash est identique
- Ne fais qu'UN SEUL nœud à la fois
- Si tu découvres des zones de données mal désassemblées, note-les mais ne les reconstruis que si c'est le nœud actuel
- NE PAS faire de git commit, le script s'en charge

## Contexte du projet

- Fichier CLAUDE.md contient les conventions du projet
- `make verify` doit toujours passer (hash SHA256+MD5 identique)
- Labels: CamelCase pour routines, SNAKE_CASE pour constantes
- Préfixes: h pour HRAM, w pour WRAM, r pour registres hardware
"""

    return base_prompt


def stream_output(pipe, prefix: str, color: str = ""):
    """Lit et affiche un flux en temps réel."""
    reset = "\033[0m" if color else ""
    for line in iter(pipe.readline, ''):
        if line:
            print(f"{color}{prefix}{reset} {line.rstrip()}")
            sys.stdout.flush()


def run_claude_streaming(prompt: str, timeout: int = CLAUDE_TIMEOUT) -> tuple[bool, str]:
    """Lance Claude avec streaming de l'output en temps réel."""

    cmd = [
        "claude",
        "-p", prompt,
        "--model", CLAUDE_MODEL,
        "--dangerously-skip-permissions"
    ]

    print(f"\n🤖 [CLAUDE] Lancement avec timeout {timeout}s...")
    print("─" * 60)

    full_output = []

    try:
        process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            bufsize=1,
            cwd=os.getcwd()
        )

        # Threads pour lire stdout et stderr en parallèle
        def read_stdout():
            for line in iter(process.stdout.readline, ''):
                if line:
                    full_output.append(line)
                    print(f"\033[36m│\033[0m {line.rstrip()}")
                    sys.stdout.flush()

        def read_stderr():
            for line in iter(process.stderr.readline, ''):
                if line:
                    full_output.append(line)
                    print(f"\033[33m│ stderr:\033[0m {line.rstrip()}")
                    sys.stdout.flush()

        stdout_thread = threading.Thread(target=read_stdout)
        stderr_thread = threading.Thread(target=read_stderr)

        stdout_thread.start()
        stderr_thread.start()

        # Attendre avec timeout
        try:
            process.wait(timeout=timeout)
        except subprocess.TimeoutExpired:
            print(f"\n⏰ [CLAUDE] TIMEOUT après {timeout}s - arrêt forcé")
            process.kill()
            process.wait()
            return False, "TIMEOUT"

        stdout_thread.join(timeout=5)
        stderr_thread.join(timeout=5)

        print("─" * 60)

        success = process.returncode == 0
        output = ''.join(full_output)

        if success:
            print("✅ [CLAUDE] Terminé avec succès")
        else:
            print(f"❌ [CLAUDE] Échec (code {process.returncode})")

        return success, output

    except Exception as e:
        print(f"💥 [CLAUDE] Erreur: {e}")
        return False, str(e)


def run_make_verify() -> bool:
    """Lance make verify et retourne True si le hash est vérifié."""

    print("\n🔍 [VERIFY] Lancement de make verify...")

    try:
        result = subprocess.run(
            ["make", "verify"],
            capture_output=True,
            text=True,
            timeout=60
        )

        output = result.stdout + result.stderr

        # Afficher la sortie
        for line in output.split('\n'):
            if line.strip():
                if "VERIFIED" in line or "OK" in line:
                    print(f"  \033[32m✓\033[0m {line}")
                elif "FAIL" in line or "ERROR" in line:
                    print(f"  \033[31m✗\033[0m {line}")
                else:
                    print(f"  │ {line}")

        success = "VERIFICATION REUSSIE" in output or "HASH VERIFIED" in output or "[OK]" in output

        if success:
            print("✅ [VERIFY] Build vérifié")
        else:
            print("❌ [VERIFY] ÉCHEC - Hash différent!")

        return success

    except Exception as e:
        print(f"💥 [VERIFY] Erreur: {e}")
        return False


def git_status_clean() -> bool:
    """Vérifie si le repo est clean (pas de changements non commités)."""
    result = subprocess.run(
        ["git", "status", "--porcelain"],
        capture_output=True,
        text=True
    )
    return len(result.stdout.strip()) == 0


def git_has_changes() -> List[str]:
    """Retourne la liste des fichiers modifiés."""
    result = subprocess.run(
        ["git", "status", "--porcelain"],
        capture_output=True,
        text=True
    )
    files = []
    for line in result.stdout.strip().split('\n'):
        if line.strip():
            files.append(line.strip())
    return files


def git_commit(node: Node) -> bool:
    """Commit les changements avec un message formaté."""

    changes = git_has_changes()
    if not changes:
        print("📝 [GIT] Rien à commiter")
        return True

    print(f"\n📝 [GIT] Fichiers modifiés:")
    for f in changes[:5]:
        print(f"  │ {f}")
    if len(changes) > 5:
        print(f"  │ ... et {len(changes) - 5} autres")

    # Stage all changes
    subprocess.run(["git", "add", "-A"], check=True)

    # Commit
    addr_clean = node.address.replace("$", "").replace(":", "_")
    msg = f"[BFS-{addr_clean}] {node.description}"

    commit_body = f"""{msg}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"""

    try:
        result = subprocess.run(
            ["git", "commit", "-m", commit_body],
            capture_output=True,
            text=True
        )
        if result.returncode == 0:
            print(f"✅ [GIT] Commit créé: {msg[:50]}...")
            return True
        else:
            print(f"❌ [GIT] Échec commit: {result.stderr}")
            return False
    except Exception as e:
        print(f"💥 [GIT] Erreur: {e}")
        return False


def git_push() -> bool:
    """Push les commits vers origin."""

    print("\n🚀 [GIT] Push vers origin...")

    try:
        result = subprocess.run(
            ["git", "push"],
            capture_output=True,
            text=True,
            timeout=60
        )

        if result.returncode == 0:
            print("✅ [GIT] Push réussi")
            return True
        else:
            print(f"❌ [GIT] Échec push: {result.stderr}")
            return False

    except Exception as e:
        print(f"💥 [GIT] Erreur push: {e}")
        return False


def git_restore() -> bool:
    """Annule tous les changements non commités."""
    print("🔄 [GIT] Restauration des fichiers...")
    try:
        subprocess.run(["git", "checkout", "."], check=True)
        subprocess.run(["git", "clean", "-fd"], check=True)
        print("✅ [GIT] Fichiers restaurés")
        return True
    except Exception as e:
        print(f"💥 [GIT] Erreur restauration: {e}")
        return False


def parse_references_from_output(output: str) -> List[Node]:
    """Parse les références découvertes depuis l'output de Claude."""

    # Chercher le bloc JSON dans l'output
    json_match = re.search(r'```json\s*(\{[\s\S]*?\})\s*```', output)

    if not json_match:
        print("⚠️  [PARSE] Pas de bloc JSON trouvé dans l'output")
        return []

    try:
        data = json.loads(json_match.group(1))
        refs = data.get("references_out", [])

        nodes = []
        for ref in refs:
            node = Node(
                address=ref.get("address", ""),
                node_type=NodeType(ref.get("type", "unknown")),
                description=ref.get("description", ""),
                source=data.get("explored", "unknown"),
                bank=ref.get("bank", 0),
                priority=3  # Références découvertes = priorité basse
            )
            nodes.append(node)

        if nodes:
            print(f"📍 [PARSE] {len(nodes)} nouvelles références trouvées:")
            for n in nodes[:5]:
                print(f"  │ {n.address} ({n.node_type.value}) - {n.description[:40]}")
            if len(nodes) > 5:
                print(f"  │ ... et {len(nodes) - 5} autres")

        return nodes

    except json.JSONDecodeError as e:
        print(f"⚠️  [PARSE] Erreur JSON: {e}")
        return []


def explore_node(node: Node, state: ExplorerState, dry_run: bool = False) -> bool:
    """Explore un nœud unique."""

    print(f"\n{'═'*60}")
    print(f"🎯 EXPLORATION: {node.address}")
    print(f"   Type: {node.node_type.value} | Bank: {node.bank} | Priorité: {node.priority}")
    print(f"   {node.description}")
    print(f"   Source: {node.source}")
    print(f"{'═'*60}")

    if node.address in state.visited:
        print("⏭️  [SKIP] Déjà visité")
        return True

    # Construire le prompt
    prompt = build_prompt(node, state)

    if dry_run:
        print("\n📋 [DRY-RUN] Prompt généré:")
        print("─" * 40)
        print(prompt[:800] + "..." if len(prompt) > 800 else prompt)
        print("─" * 40)
        state.visited.add(node.address)
        return True

    # Lancer Claude avec streaming
    success, output = run_claude_streaming(prompt)

    if not success:
        print(f"❌ [EXPLORE] Échec pour {node.address}")
        git_restore()
        return False

    # Vérifier le hash
    if not run_make_verify():
        print("❌ [EXPLORE] Hash invalide - annulation des changements")
        git_restore()
        return False

    # Commit si changements
    if git_has_changes():
        if not git_commit(node):
            git_restore()
            return False
        state.commits_since_push += 1

    # Parser les nouvelles références
    new_refs = parse_references_from_output(output)
    for ref in new_refs:
        if ref.address not in state.visited:
            # Éviter les doublons dans la frontière
            existing = [n for n in state.frontier if n.address == ref.address]
            if not existing:
                state.frontier.append(ref)

    # Marquer comme visité
    state.visited.add(node.address)
    state.total_explored += 1

    return True


def print_banner():
    """Affiche une bannière de bienvenue."""
    print("""
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   🎮  BFS EXPLORER - Game Boy ASM Code Analysis  🎮          ║
║                                                               ║
║   Parcours automatique du code avec Claude                    ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
""")


def main():
    parser = argparse.ArgumentParser(description="BFS Explorer pour code ASM Game Boy")
    parser.add_argument("--dry-run", action="store_true", help="Afficher les prompts sans exécuter")
    parser.add_argument("--max-nodes", type=int, default=10, help="Nombre max de nœuds à explorer")
    parser.add_argument("--push-every", type=int, default=PUSH_EVERY, help="Push tous les N commits")
    parser.add_argument("--reset", action="store_true", help="Reset l'état et recommencer")
    parser.add_argument("--show-frontier", action="store_true", help="Afficher la frontière actuelle")
    parser.add_argument("--no-push", action="store_true", help="Ne pas push automatiquement")

    args = parser.parse_args()

    print_banner()

    # Charger ou initialiser l'état
    if args.reset or not os.path.exists(STATE_FILE):
        print("🆕 [INIT] Initialisation avec la frontière de départ")
        state = ExplorerState()
        state.frontier = get_initial_frontier()
        state.save(STATE_FILE)  # Sauvegarder immédiatement après reset
    else:
        state = ExplorerState.load(STATE_FILE)

    # Mode affichage
    if args.show_frontier:
        print("\n📋 FRONTIÈRE ACTUELLE")
        print("─" * 60)

        sorted_frontier = sorted(state.frontier, key=lambda n: (n.priority, n.address))
        for i, node in enumerate(sorted_frontier):
            status = "✅" if node.address in state.visited else "⬜"
            print(f"{status} {i+1:3}. [{node.priority}] {node.address:12} ({node.node_type.value:7}) - {node.description[:35]}")

        print("─" * 60)
        pending = len([n for n in state.frontier if n.address not in state.visited])
        print(f"📊 Total: {len(state.frontier)} nœuds | {pending} en attente | {len(state.visited)} visités")
        return

    # Vérification initiale
    print("🔍 Vérification initiale du build...")
    if not run_make_verify():
        print("❌ Le build initial échoue. Corrigez avant de continuer.")
        return

    # Boucle principale
    explored = 0
    start_time = time.time()

    try:
        while state.frontier and explored < args.max_nodes:
            # Trier par priorité et prendre le premier non visité
            state.frontier.sort(key=lambda n: (n.priority, n.address))

            node = None
            for n in state.frontier:
                if n.address not in state.visited:
                    node = n
                    break

            if node is None:
                print("\n🎉 [DONE] Tous les nœuds ont été visités!")
                break

            # Afficher la progression
            pending = len([n for n in state.frontier if n.address not in state.visited])
            print(f"\n📊 Progression: {explored+1}/{args.max_nodes} | En attente: {pending} | Visités: {len(state.visited)}")

            # Explorer le nœud
            success = explore_node(node, state, args.dry_run)

            if success:
                explored += 1

                # Push périodique
                if not args.dry_run and not args.no_push and state.commits_since_push >= args.push_every:
                    if git_push():
                        state.commits_since_push = 0

            # Sauvegarder l'état après chaque nœud
            state.save(STATE_FILE)

            # Petite pause entre les nœuds
            if not args.dry_run:
                time.sleep(2)

    except KeyboardInterrupt:
        print("\n\n⚠️  [INTERRUPT] Arrêt demandé par l'utilisateur")

    finally:
        # Sauvegarder l'état final
        state.save(STATE_FILE)

        # Push final si nécessaire
        if not args.dry_run and not args.no_push and state.commits_since_push > 0:
            print("\n🚀 [FINAL] Push des commits restants...")
            git_push()

    # Résumé final
    elapsed = time.time() - start_time
    print(f"""
╔═══════════════════════════════════════════════════════════════╗
║                       RÉSUMÉ FINAL                            ║
╠═══════════════════════════════════════════════════════════════╣
║  🎯 Nœuds explorés cette session:  {explored:3}                        ║
║  ✅ Total visités:                 {len(state.visited):3}                        ║
║  ⬜ En attente dans frontière:     {len([n for n in state.frontier if n.address not in state.visited]):3}                        ║
║  ⏱️  Temps écoulé:                 {elapsed/60:.1f} min                     ║
╚═══════════════════════════════════════════════════════════════╝
""")


if __name__ == "__main__":
    main()
