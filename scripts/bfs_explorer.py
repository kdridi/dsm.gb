#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
BFS Explorer V2 - Orchestrateur ultime pour décompilation Game Boy
===================================================================

Architecture en 4 phases avec agents spécialisés :
1. ANALYZE  : Lecture seule, identification du type et références
2. DOCUMENT : Ajout de commentaires (code/handler seulement)
3. VALIDATE : make verify obligatoire
4. RECONSTRUCT : Reconstruction data (optionnel, séparé)

Principes :
- Prompts atomiques (une seule tâche claire)
- JSON strict (validation du format)
- Fail fast (abandonner plutôt que battre)
- Stratégie par type (code vs data vs table)

Usage:
    python scripts/bfs_explorer.py [--dry-run] [--max-nodes N] [--phase PHASE]
"""

import subprocess
import json
import sys
import os
import re
import time
import argparse
import threading
from pathlib import Path
from dataclasses import dataclass, field
from typing import Set, List, Optional, Dict, Any
from enum import Enum
from datetime import datetime

# ============================================================================
# CONFIGURATION
# ============================================================================

CLAUDE_MODEL = "sonnet"
STATE_FILE = "scripts/bfs_state.json"
PUSH_EVERY = 10
MAX_PROMPT_TIME = 120  # Timeout agressif en secondes

# Couleurs terminal
class Colors:
    RESET = "\033[0m"
    RED = "\033[31m"
    GREEN = "\033[32m"
    YELLOW = "\033[33m"
    BLUE = "\033[34m"
    MAGENTA = "\033[35m"
    CYAN = "\033[36m"
    GRAY = "\033[90m"

# ============================================================================
# TYPES ET STRUCTURES
# ============================================================================

class NodeType(str, Enum):
    CODE = "code"
    DATA = "data"
    HANDLER = "handler"
    TABLE = "table"
    UNKNOWN = "unknown"

class Phase(str, Enum):
    ANALYZE = "analyze"
    DOCUMENT = "document"
    VALIDATE = "validate"
    RECONSTRUCT = "reconstruct"

@dataclass
class Node:
    """Un noeud à explorer dans le graphe de code."""
    address: str
    node_type: NodeType
    description: str
    source: str
    bank: int = 0
    priority: int = 0

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
            node_type=NodeType(d.get("node_type", "unknown")),
            description=d.get("description", ""),
            source=d.get("source", ""),
            bank=d.get("bank", 0),
            priority=d.get("priority", 0)
        )

@dataclass
class AnalysisResult:
    """Résultat de la phase ANALYZE."""
    address: str
    type_confirmed: NodeType
    label_current: Optional[str]
    label_suggested: Optional[str]
    references_out: List[Dict[str, Any]]
    summary: str
    needs_reconstruction: bool = False
    raw_json: Optional[dict] = None

@dataclass
class ExplorerState:
    """État persistant de l'explorateur."""
    frontier: List[Node] = field(default_factory=list)
    visited: Set[str] = field(default_factory=set)
    commits_since_push: int = 0
    total_explored: int = 0
    failed_nodes: Set[str] = field(default_factory=set)

    def save(self, path: str):
        data = {
            "frontier": [n.to_dict() for n in self.frontier],
            "visited": list(self.visited),
            "failed_nodes": list(self.failed_nodes),
            "commits_since_push": self.commits_since_push,
            "total_explored": self.total_explored
        }
        with open(path, 'w') as f:
            json.dump(data, f, indent=2)
        print(f"{Colors.GRAY}💾 État sauvegardé: {len(self.frontier)} frontière, {len(self.visited)} visités{Colors.RESET}")

    @classmethod
    def load(cls, path: str) -> "ExplorerState":
        if not os.path.exists(path):
            return cls()
        with open(path, 'r') as f:
            data = json.load(f)
        state = cls()
        state.frontier = [Node.from_dict(n) for n in data.get("frontier", [])]
        state.visited = set(data.get("visited", []))
        state.failed_nodes = set(data.get("failed_nodes", []))
        state.commits_since_push = data.get("commits_since_push", 0)
        state.total_explored = data.get("total_explored", 0)
        print(f"{Colors.CYAN}📂 État chargé: {len(state.frontier)} frontière, {len(state.visited)} visités{Colors.RESET}")
        return state

# ============================================================================
# PROMPTS ATOMIQUES
# ============================================================================

def prompt_analyze(node: Node) -> str:
    """Prompt pour la phase ANALYZE - lecture seule, JSON strict."""
    bank_file = f"bank_00{node.bank}.asm" if node.bank < 10 else f"bank_0{node.bank}.asm"

    return f"""Tu es un expert en reverse engineering Game Boy. PHASE ANALYZE - LECTURE SEULE.

## Cible
- Adresse: {node.address}
- Type supposé: {node.node_type.value}
- Description: {node.description}
- Bank: {node.bank}
- Fichier: src/{bank_file}

## Ta mission (LECTURE SEULE)
1. Trouve le code/données à cette adresse via grep sur les .asm ou le fichier .sym
2. Identifie le TYPE RÉEL (code, data, table, handler)
3. Liste les RÉFÉRENCES SORTANTES (call, jp, ld hl/$XXXX, dw $XXXX)
4. Note si la zone nécessite RECONSTRUCTION (instructions db/dw mal désassemblées)

## CONTRAINTES
- NE MODIFIE AUCUN FICHIER
- NE LANCE PAS make verify
- PRODUIS UNIQUEMENT LE JSON CI-DESSOUS

## SORTIE OBLIGATOIRE (JSON uniquement)
```json
{{
  "address": "{node.address}",
  "type_confirmed": "code|data|table|handler",
  "label_current": "NomActuel ou null",
  "label_suggested": "NomSuggéré ou null",
  "needs_reconstruction": false,
  "references_out": [
    {{"address": "$XXXX", "type": "code|data|table", "description": "...", "bank": 0}}
  ],
  "summary": "Une phrase décrivant ce que fait ce code/données"
}}
```

IMPORTANT: Ta réponse doit contenir UNIQUEMENT le bloc JSON ci-dessus, rien d'autre."""


def prompt_document(node: Node, analysis: AnalysisResult) -> str:
    """Prompt pour la phase DOCUMENT - ajout de commentaires seulement."""
    bank_file = f"bank_00{node.bank}.asm" if node.bank < 10 else f"bank_0{node.bank}.asm"

    return f"""Tu es un expert en reverse engineering Game Boy. PHASE DOCUMENT - COMMENTAIRES SEULEMENT.

## Cible
- Adresse: {node.address}
- Type: {analysis.type_confirmed.value}
- Label actuel: {analysis.label_current or 'générique'}
- Fichier: src/{bank_file}

## Analyse précédente
{analysis.summary}

## Ta mission
1. Ajoute un BLOC COMMENTAIRE au début de la routine/zone:
```asm
; NomFonction
; -----------
; Description: Ce que fait la fonction
; In:  registres d'entrée
; Out: registres de sortie
; Modifie: registres modifiés
```

2. Si le label est générique (Jump_XXXX, Call_XXXX), renomme-le en nom descriptif

## CONTRAINTES
- NE MODIFIE QUE les commentaires et labels
- NE TOUCHE PAS aux instructions assembleur
- NE RECONSTRUIT PAS les données mal désassemblées
- Termine par `make verify`

## SORTIE OBLIGATOIRE (JSON après les modifications)
```json
{{
  "address": "{node.address}",
  "label_renamed": "NouveauNom ou null",
  "comments_added": true,
  "make_verify": "success|failed"
}}
```"""


def prompt_reconstruct(node: Node, analysis: AnalysisResult) -> str:
    """Prompt pour la phase RECONSTRUCT - reconstruction de données."""
    bank_file = f"bank_00{node.bank}.asm" if node.bank < 10 else f"bank_0{node.bank}.asm"

    return f"""Tu es un expert en reverse engineering Game Boy. PHASE RECONSTRUCT - RECONSTRUCTION DATA.

## Cible
- Adresse: {node.address}
- Type: {analysis.type_confirmed.value}
- Fichier: src/{bank_file}

## Analyse précédente
{analysis.summary}

## Ta mission
1. Lis les bytes bruts avec: xxd -s 0x{node.address.replace('$', '')} -l 64 src/game.gb
2. Compare avec le code .asm actuel
3. Si la zone est mal désassemblée (db au lieu de dw, instructions impossibles):
   - Reconstruit avec db/dw appropriés
   - GARDE LE MÊME NOMBRE DE BYTES
4. Vérifie avec make verify

## RÈGLES CRITIQUES
- Si le hash change après ta modification: ANNULE TOUT avec `git checkout .`
- Ne bataille PAS avec les bytes plus de 2 tentatives
- Si ça ne marche pas, ABANDONNE et note le problème

## SORTIE OBLIGATOIRE (JSON)
```json
{{
  "address": "{node.address}",
  "reconstruction_attempted": true,
  "reconstruction_success": true|false,
  "bytes_changed": 0,
  "make_verify": "success|failed|abandoned"
}}
```"""

# ============================================================================
# EXÉCUTION CLAUDE
# ============================================================================

def run_claude(prompt: str, timeout: int = MAX_PROMPT_TIME) -> tuple[bool, str, Optional[dict]]:
    """Lance Claude avec streaming et parse le JSON de sortie."""

    cmd = [
        "claude",
        "-p", prompt,
        "--model", CLAUDE_MODEL,
        "--dangerously-skip-permissions",
        "--output-format", "stream-json"
    ]

    full_text = []

    try:
        process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            bufsize=1
        )

        start_time = time.time()

        # Lire stdout en streaming
        while True:
            if time.time() - start_time > timeout:
                process.terminate()
                print(f"{Colors.RED}⏱️ Timeout après {timeout}s{Colors.RESET}")
                return False, "Timeout", None

            line = process.stdout.readline()
            if not line:
                if process.poll() is not None:
                    break
                continue

            line = line.strip()
            if not line:
                continue

            try:
                msg = json.loads(line)
                msg_type = msg.get("type", "")

                if msg_type == "assistant":
                    content = msg.get("message", {}).get("content", [])
                    for block in content:
                        if block.get("type") == "text":
                            text = block.get("text", "")
                            full_text.append(text)
                            # Afficher un résumé
                            for l in text.split('\n')[-2:]:
                                if l.strip() and not l.startswith('```'):
                                    print(f"{Colors.GRAY}│ {l[:80]}{Colors.RESET}")

                elif msg_type == "tool_use":
                    tool = msg.get("tool", "")
                    print(f"{Colors.MAGENTA}🔧 {tool}{Colors.RESET}")

                elif msg_type == "result":
                    result_text = msg.get("result", "")
                    if result_text:
                        full_text.append(result_text)

            except json.JSONDecodeError:
                pass

        process.wait()
        output = '\n'.join(full_text)

        # Parser le JSON de sortie
        json_result = extract_json_from_output(output)

        success = process.returncode == 0
        return success, output, json_result

    except Exception as e:
        print(f"{Colors.RED}💥 Erreur: {e}{Colors.RESET}")
        return False, str(e), None


def extract_json_from_output(output: str) -> Optional[dict]:
    """Extrait le bloc JSON de la sortie Claude."""

    # Chercher un bloc ```json ... ```
    json_match = re.search(r'```json\s*(\{[\s\S]*?\})\s*```', output)
    if json_match:
        try:
            return json.loads(json_match.group(1))
        except json.JSONDecodeError:
            pass

    # Chercher un JSON brut
    json_match = re.search(r'\{[\s\S]*"address"[\s\S]*\}', output)
    if json_match:
        try:
            return json.loads(json_match.group(0))
        except json.JSONDecodeError:
            pass

    return None

# ============================================================================
# GIT OPERATIONS
# ============================================================================

def git_has_changes() -> List[str]:
    """Retourne la liste des fichiers modifiés."""
    result = subprocess.run(["git", "status", "--porcelain"], capture_output=True, text=True)
    return [l.strip() for l in result.stdout.strip().split('\n') if l.strip()]


def git_commit(node: Node, phase: Phase) -> bool:
    """Commit les changements."""
    changes = git_has_changes()
    if not changes:
        return True

    subprocess.run(["git", "add", "-A"], check=True)

    addr_clean = node.address.replace("$", "").replace(":", "_")
    msg = f"[BFS-{addr_clean}] {node.description}"

    commit_body = f"""{msg}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet <noreply@anthropic.com>"""

    try:
        result = subprocess.run(["git", "commit", "-m", commit_body], capture_output=True, text=True)
        if result.returncode == 0:
            print(f"{Colors.GREEN}✅ Commit: {msg[:50]}...{Colors.RESET}")
            return True
        else:
            print(f"{Colors.RED}❌ Commit échoué: {result.stderr}{Colors.RESET}")
            return False
    except Exception as e:
        print(f"{Colors.RED}💥 Erreur git: {e}{Colors.RESET}")
        return False


def git_restore():
    """Annule tous les changements."""
    subprocess.run(["git", "checkout", "."], capture_output=True)
    subprocess.run(["git", "clean", "-fd"], capture_output=True)
    print(f"{Colors.YELLOW}🔄 Fichiers restaurés{Colors.RESET}")


def git_push() -> bool:
    """Push vers origin."""
    try:
        result = subprocess.run(["git", "push"], capture_output=True, text=True, timeout=60)
        if result.returncode == 0:
            print(f"{Colors.GREEN}🚀 Push réussi{Colors.RESET}")
            return True
        return False
    except Exception:
        return False

# ============================================================================
# PHASES D'EXPLORATION
# ============================================================================

def phase_analyze(node: Node) -> Optional[AnalysisResult]:
    """Phase 1: Analyse en lecture seule."""
    print(f"\n{Colors.CYAN}📖 PHASE ANALYZE: {node.address}{Colors.RESET}")

    prompt = prompt_analyze(node)
    success, output, json_result = run_claude(prompt, timeout=60)

    if not success or not json_result:
        print(f"{Colors.RED}❌ Échec analyse - pas de JSON valide{Colors.RESET}")
        return None

    try:
        return AnalysisResult(
            address=json_result.get("address", node.address),
            type_confirmed=NodeType(json_result.get("type_confirmed", "unknown")),
            label_current=json_result.get("label_current"),
            label_suggested=json_result.get("label_suggested"),
            references_out=json_result.get("references_out", []),
            summary=json_result.get("summary", ""),
            needs_reconstruction=json_result.get("needs_reconstruction", False),
            raw_json=json_result
        )
    except Exception as e:
        print(f"{Colors.RED}❌ Erreur parsing: {e}{Colors.RESET}")
        return None


def phase_document(node: Node, analysis: AnalysisResult) -> bool:
    """Phase 2: Documentation (commentaires + labels)."""
    # Skip si c'est des données pures
    if analysis.type_confirmed in [NodeType.DATA, NodeType.TABLE]:
        print(f"{Colors.YELLOW}⏭️ Skip documentation pour {analysis.type_confirmed.value}{Colors.RESET}")
        return True

    print(f"\n{Colors.BLUE}📝 PHASE DOCUMENT: {node.address}{Colors.RESET}")

    prompt = prompt_document(node, analysis)
    success, output, json_result = run_claude(prompt, timeout=90)

    if not success:
        print(f"{Colors.RED}❌ Échec documentation{Colors.RESET}")
        git_restore()
        return False

    # Vérifier make verify
    if json_result and json_result.get("make_verify") == "failed":
        print(f"{Colors.RED}❌ make verify échoué{Colors.RESET}")
        git_restore()
        return False

    return True


def phase_validate() -> bool:
    """Phase 3: Validation avec make verify."""
    print(f"\n{Colors.GREEN}✔️ PHASE VALIDATE{Colors.RESET}")

    try:
        result = subprocess.run(["make", "verify"], capture_output=True, text=True, timeout=60)
        output = result.stdout + result.stderr

        if "VERIFICATION REUSSIE" in output or "[OK]" in output:
            print(f"{Colors.GREEN}✅ Hash vérifié{Colors.RESET}")
            return True
        else:
            print(f"{Colors.RED}❌ Hash différent{Colors.RESET}")
            return False
    except Exception as e:
        print(f"{Colors.RED}💥 Erreur: {e}{Colors.RESET}")
        return False


def phase_reconstruct(node: Node, analysis: AnalysisResult) -> bool:
    """Phase 4: Reconstruction (optionnelle, pour data/tables)."""
    if not analysis.needs_reconstruction:
        return True

    print(f"\n{Colors.MAGENTA}🔨 PHASE RECONSTRUCT: {node.address}{Colors.RESET}")

    prompt = prompt_reconstruct(node, analysis)
    success, output, json_result = run_claude(prompt, timeout=120)

    if not success:
        git_restore()
        return False

    if json_result and json_result.get("make_verify") != "success":
        git_restore()
        return False

    return True

# ============================================================================
# EXPLORATION PRINCIPALE
# ============================================================================

def explore_node(node: Node, state: ExplorerState, skip_reconstruct: bool = True) -> bool:
    """Explore un noeud complet avec le pipeline de phases."""

    print(f"\n{'═'*60}")
    print(f"{Colors.CYAN}🎯 EXPLORATION: {node.address}{Colors.RESET}")
    print(f"   Type: {node.node_type.value} | Bank: {node.bank}")
    print(f"   {node.description}")
    print(f"{'═'*60}")

    if node.address in state.visited:
        print(f"{Colors.YELLOW}⏭️ Déjà visité{Colors.RESET}")
        return True

    if node.address in state.failed_nodes:
        print(f"{Colors.YELLOW}⏭️ Déjà échoué précédemment{Colors.RESET}")
        return True

    # Phase 1: ANALYZE
    analysis = phase_analyze(node)
    if not analysis:
        state.failed_nodes.add(node.address)
        return False

    print(f"{Colors.GREEN}✓ Analyse: {analysis.type_confirmed.value} - {analysis.summary[:60]}...{Colors.RESET}")
    print(f"  Références trouvées: {len(analysis.references_out)}")

    # Phase 2: DOCUMENT (seulement pour code/handler)
    if analysis.type_confirmed in [NodeType.CODE, NodeType.HANDLER]:
        if not phase_document(node, analysis):
            state.failed_nodes.add(node.address)
            return False

    # Phase 3: VALIDATE
    if git_has_changes():
        if not phase_validate():
            git_restore()
            state.failed_nodes.add(node.address)
            return False

    # Phase 4: RECONSTRUCT (optionnelle)
    if not skip_reconstruct and analysis.needs_reconstruction:
        phase_reconstruct(node, analysis)
        if not phase_validate():
            git_restore()

    # Ajouter les nouvelles références à la frontière
    for ref in analysis.references_out:
        ref_addr = ref.get("address", "")
        if ref_addr and ref_addr not in state.visited and ref_addr not in state.failed_nodes:
            existing = [n for n in state.frontier if n.address == ref_addr]
            if not existing:
                new_node = Node(
                    address=ref_addr,
                    node_type=NodeType(ref.get("type", "unknown")),
                    description=ref.get("description", ""),
                    source=node.address,
                    bank=ref.get("bank", 0),
                    priority=3
                )
                state.frontier.append(new_node)
                print(f"{Colors.GRAY}  + {ref_addr}: {ref.get('description', '')[:40]}{Colors.RESET}")

    # Marquer comme visité
    state.visited.add(node.address)
    state.total_explored += 1

    # Sauvegarder l'état
    state.save(STATE_FILE)

    # Commit si changements
    if git_has_changes():
        if git_commit(node, Phase.DOCUMENT):
            state.commits_since_push += 1

    return True


def get_initial_frontier() -> List[Node]:
    """Points d'entrée initiaux pour le BFS."""
    return [
        # Vecteurs d'interruption
        Node("$0000", NodeType.CODE, "RST $00 - Soft reset", "boot", 0, 0),
        Node("$0040", NodeType.HANDLER, "VBlank interrupt vector", "boot", 0, 0),
        Node("$0048", NodeType.HANDLER, "LCD STAT interrupt vector", "boot", 0, 0),
        Node("$0050", NodeType.HANDLER, "Timer interrupt vector", "boot", 0, 0),
        Node("$0100", NodeType.CODE, "ROM Entry point", "boot", 0, 0),

        # Handlers principaux
        Node("$0060", NodeType.HANDLER, "VBlankHandler", "$0040", 0, 1),
        Node("$0095", NodeType.HANDLER, "LCDStatHandler", "$0048", 0, 1),
        Node("$0185", NodeType.CODE, "SystemInit", "$0100", 0, 1),
        Node("$0226", NodeType.CODE, "GameLoop", "SystemInit", 0, 1),
    ]


def print_banner():
    print(f"""
{Colors.CYAN}╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   🎮  BFS EXPLORER V2 - Orchestrateur Ultime  🎮              ║
║                                                               ║
║   Pipeline: ANALYZE → DOCUMENT → VALIDATE → [RECONSTRUCT]     ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝{Colors.RESET}
""")


def main():
    parser = argparse.ArgumentParser(description="BFS Explorer V2 - Orchestrateur ultime")
    parser.add_argument("--dry-run", action="store_true", help="Afficher sans exécuter")
    parser.add_argument("--max-nodes", type=int, default=10, help="Nombre max de noeuds")
    parser.add_argument("--push-every", type=int, default=PUSH_EVERY, help="Push tous les N commits")
    parser.add_argument("--with-reconstruct", action="store_true", help="Activer la reconstruction")
    parser.add_argument("--reset", action="store_true", help="Réinitialiser l'état")
    args = parser.parse_args()

    print_banner()

    # Charger ou initialiser l'état
    if args.reset or not os.path.exists(STATE_FILE):
        state = ExplorerState(frontier=get_initial_frontier())
        print(f"{Colors.GREEN}🆕 Nouvel état initialisé{Colors.RESET}")
    else:
        state = ExplorerState.load(STATE_FILE)

    # Trier la frontière par priorité
    state.frontier.sort(key=lambda n: n.priority)

    nodes_explored = 0

    while state.frontier and nodes_explored < args.max_nodes:
        node = state.frontier.pop(0)

        if args.dry_run:
            print(f"\n[DRY-RUN] {node.address}: {node.description}")
            continue

        success = explore_node(node, state, skip_reconstruct=not args.with_reconstruct)

        if success:
            nodes_explored += 1

        # Push périodique
        if state.commits_since_push >= args.push_every:
            if git_push():
                state.commits_since_push = 0
            state.save(STATE_FILE)

    # Résumé final
    print(f"\n{'═'*60}")
    print(f"{Colors.GREEN}📊 RÉSUMÉ{Colors.RESET}")
    print(f"   Noeuds explorés cette session: {nodes_explored}")
    print(f"   Total explorés: {state.total_explored}")
    print(f"   Frontière restante: {len(state.frontier)}")
    print(f"   Échecs: {len(state.failed_nodes)}")
    print(f"{'═'*60}")

    state.save(STATE_FILE)


if __name__ == "__main__":
    main()
