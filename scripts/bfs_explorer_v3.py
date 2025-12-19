#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
BFS EXPLORER V3 - ORCHESTRATEUR ULTIME
======================================

Basé sur l'analyse de 907 explorations :
- Taux initial : 5.8%
- Objectif : 80%+

RÈGLES D'OR IMPLÉMENTÉES :
1. Log < 1500 chars → ABANDON
2. Problems >= 2 → ABANDON
3. Tools > 2 → REPENSER
4. bad_disassembly → SKIP
5. Byte battle → ABANDON IMMÉDIAT

Usage:
    python scripts/bfs_explorer_v3.py [options]
"""

import subprocess
import json
import sys
import os
import re
import time
import argparse
from pathlib import Path
from dataclasses import dataclass, field
from typing import Set, List, Optional, Dict, Any
from enum import Enum
from datetime import datetime

# ============================================================================
# CONFIGURATION BASÉE SUR PLAYBOOK
# ============================================================================

# Limites strictes (RÈGLES D'OR)
MAX_LOG_LENGTH = 1500       # RÈGLE #1
MAX_PROBLEMS = 2            # RÈGLE #2
MAX_TOOLS = 2               # RÈGLE #3
TIMEOUT_ANALYZE = 30        # Phase 1
TIMEOUT_DOCUMENT = 45       # Phase 2
TIMEOUT_VALIDATE = 60       # Phase 3

# Fichiers
STATE_FILE = "scripts/bfs_state_v3.json"
PLAYBOOK_FILE = "PLAYBOOK.md"
METRICS_FILE = "scripts/exploration_metrics.json"

# Patterns mortels (DEATH PATTERNS)
DEATH_PATTERNS = [
    r'byte par byte',
    r'byte-par-byte',
    r'décalage',
    r'inversé',
    r'WTF',
    r'frustré',
    r'bataille',
]

# Patterns de mauvais désassemblage
BAD_DISASM_PATTERNS = [
    r'db \$[0-9a-fA-F]{2}\s*\n.*db \$',  # db répétés
    r'mal désassemblé',
    r'données comme code',
]

# Couleurs
class C:
    R = "\033[0m"    # Reset
    RED = "\033[31m"
    GRN = "\033[32m"
    YEL = "\033[33m"
    BLU = "\033[34m"
    MAG = "\033[35m"
    CYN = "\033[36m"
    GRY = "\033[90m"

# ============================================================================
# STRUCTURES
# ============================================================================

class NodeType(str, Enum):
    CODE = "code"
    DATA = "data"
    HANDLER = "handler"
    TABLE = "table"
    UNKNOWN = "unknown"

class ExploreResult(str, Enum):
    SUCCESS = "success"
    FAILED_HASH = "failed_hash"
    FAILED_TIMEOUT = "failed_timeout"
    FAILED_OVERTHINK = "failed_overthink"
    FAILED_PROBLEMS = "failed_problems"
    FAILED_DEATH_PATTERN = "failed_death_pattern"
    SKIPPED_BAD_DISASM = "skipped_bad_disasm"
    SKIPPED_ALREADY_VISITED = "skipped_already_visited"

@dataclass
class Node:
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
class ExplorationMetrics:
    """Métriques en temps réel."""
    total_attempts: int = 0
    successes: int = 0
    failures_by_reason: Dict[str, int] = field(default_factory=dict)
    avg_log_length_success: float = 0
    avg_log_length_failure: float = 0
    success_rate: float = 0

    def update(self, result: ExploreResult, log_length: int):
        self.total_attempts += 1
        if result == ExploreResult.SUCCESS:
            self.successes += 1
            # Moyenne mobile
            n = self.successes
            self.avg_log_length_success = (self.avg_log_length_success * (n-1) + log_length) / n
        else:
            reason = result.value
            self.failures_by_reason[reason] = self.failures_by_reason.get(reason, 0) + 1
            n = self.total_attempts - self.successes
            if n > 0:
                self.avg_log_length_failure = (self.avg_log_length_failure * (n-1) + log_length) / n

        self.success_rate = self.successes / self.total_attempts if self.total_attempts > 0 else 0

    def to_dict(self) -> dict:
        return {
            "total_attempts": self.total_attempts,
            "successes": self.successes,
            "success_rate": f"{self.success_rate*100:.1f}%",
            "failures_by_reason": self.failures_by_reason,
            "avg_log_length_success": int(self.avg_log_length_success),
            "avg_log_length_failure": int(self.avg_log_length_failure)
        }

@dataclass
class State:
    frontier: List[Node] = field(default_factory=list)
    visited: Set[str] = field(default_factory=set)
    failed: Set[str] = field(default_factory=set)
    needs_reconstruction: Set[str] = field(default_factory=set)
    commits_since_push: int = 0
    metrics: ExplorationMetrics = field(default_factory=ExplorationMetrics)

    def save(self, path: str):
        data = {
            "frontier": [n.to_dict() for n in self.frontier],
            "visited": list(self.visited),
            "failed": list(self.failed),
            "needs_reconstruction": list(self.needs_reconstruction),
            "commits_since_push": self.commits_since_push,
            "metrics": self.metrics.to_dict()
        }
        with open(path, 'w') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)

    @classmethod
    def load(cls, path: str) -> "State":
        if not os.path.exists(path):
            return cls()
        with open(path, 'r') as f:
            data = json.load(f)
        state = cls()
        state.frontier = [Node.from_dict(n) for n in data.get("frontier", [])]
        state.visited = set(data.get("visited", []))
        state.failed = set(data.get("failed", []))
        state.needs_reconstruction = set(data.get("needs_reconstruction", []))
        state.commits_since_push = data.get("commits_since_push", 0)
        return state

# ============================================================================
# PROMPTS ATOMIQUES (basés sur PLAYBOOK)
# ============================================================================

def prompt_analyze(node: Node) -> str:
    """Prompt ANALYZE - 30s max, lecture seule."""
    bank_file = f"bank_00{node.bank}.asm" if node.bank < 10 else f"bank_0{node.bank}.asm"

    return f"""PHASE ANALYZE - LECTURE SEULE - 30s MAX

CIBLE: {node.address} (type supposé: {node.node_type.value}, bank {node.bank})

MISSION:
1. grep -n "{node.address.replace('$', '')}" src/{bank_file} src/game.sym
2. Identifier TYPE RÉEL: code|data|table|handler
3. Lister références sortantes (call, jp, ld hl, dw)
4. Détecter si bad_disassembly (db répétés, pas de ret/jp)

SORTIE JSON UNIQUEMENT:
```json
{{
  "address": "{node.address}",
  "type": "code|data|table|handler",
  "label": "NomActuel",
  "bad_disasm": false,
  "refs": [{{"addr": "$XXXX", "type": "code", "desc": "..."}}],
  "summary": "Une phrase"
}}
```"""


def prompt_document(node: Node, analysis: dict) -> str:
    """Prompt DOCUMENT - 45s max, commentaires FR uniquement."""
    bank_file = f"bank_00{node.bank}.asm" if node.bank < 10 else f"bank_0{node.bank}.asm"
    node_type = analysis.get('type', 'code')
    label = analysis.get('label', 'unknown')
    summary = analysis.get('summary', '')

    template = ""
    if node_type in ['code', 'handler']:
        template = f"""; {label}
; {'─' * len(label)}
; Description: {summary}
; In:  (à déterminer)
; Out: (à déterminer)
; Modifie: (à déterminer)"""

    return f"""PHASE DOCUMENT - 45s MAX - COMMENTAIRES FR

CIBLE: {node.address} dans src/{bank_file}
TYPE: {node_type}
LABEL: {label}

MISSION:
1. Ajouter ce bloc commentaire AVANT le label:
{template}

2. Si label générique (Jump_XXXX, Call_XXXX), renommer

CONTRAINTES:
- NE PAS modifier les instructions ASM
- NE PAS reconstruire les données
- Terminer par: make verify

SORTIE JSON:
```json
{{
  "modified": true,
  "label_renamed": "NouveauNom ou null",
  "verify": "success|failed"
}}
```"""

# ============================================================================
# EXÉCUTION CLAUDE AVEC MONITORING
# ============================================================================

def run_claude_monitored(prompt: str, timeout: int) -> tuple[bool, str, int, Optional[dict]]:
    """
    Lance Claude avec monitoring strict.
    Retourne: (success, output, log_length, json_result)
    """
    cmd = [
        "claude", "-p", prompt,
        "--model", "sonnet",
        "--dangerously-skip-permissions",
        "--output-format", "stream-json"
    ]

    full_text = []
    problems_detected = 0
    tools_used = set()
    death_pattern_found = False

    try:
        process = subprocess.Popen(
            cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            text=True, bufsize=1
        )

        start_time = time.time()

        while True:
            elapsed = time.time() - start_time

            # RÈGLE #1: Timeout
            if elapsed > timeout:
                process.terminate()
                print(f"{C.RED}⏱️ TIMEOUT {timeout}s{C.R}")
                return False, "timeout", len('\n'.join(full_text)), None

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

                            # RÈGLE #1: Limite de log
                            total_len = len('\n'.join(full_text))
                            if total_len > MAX_LOG_LENGTH:
                                process.terminate()
                                print(f"{C.RED}📏 LOG TROP LONG ({total_len} > {MAX_LOG_LENGTH}){C.R}")
                                return False, "overthink", total_len, None

                            # Détecter DEATH PATTERNS
                            for pattern in DEATH_PATTERNS:
                                if re.search(pattern, text, re.IGNORECASE):
                                    death_pattern_found = True
                                    process.terminate()
                                    print(f"{C.RED}💀 DEATH PATTERN: {pattern}{C.R}")
                                    return False, "death_pattern", total_len, None

                            # Compter les problèmes
                            if any(w in text.lower() for w in ['erreur', 'problème', 'échec', 'fail']):
                                problems_detected += 1
                                if problems_detected >= MAX_PROBLEMS:
                                    process.terminate()
                                    print(f"{C.RED}⚠️ TROP DE PROBLÈMES ({problems_detected}){C.R}")
                                    return False, "too_many_problems", total_len, None

                elif msg_type == "tool_use":
                    tool = msg.get("tool", "")
                    tools_used.add(tool)
                    print(f"{C.MAG}🔧 {tool}{C.R}")

                    # RÈGLE #3: Limite d'outils
                    if len(tools_used) > MAX_TOOLS + 1:  # +1 pour make verify
                        print(f"{C.YEL}⚠️ Beaucoup d'outils: {tools_used}{C.R}")

            except json.JSONDecodeError:
                pass

        process.wait()
        output = '\n'.join(full_text)
        json_result = extract_json(output)

        return process.returncode == 0, output, len(output), json_result

    except Exception as e:
        print(f"{C.RED}💥 {e}{C.R}")
        return False, str(e), 0, None


def extract_json(output: str) -> Optional[dict]:
    """Extrait le JSON de la sortie."""
    match = re.search(r'```json\s*(\{[\s\S]*?\})\s*```', output)
    if match:
        try:
            return json.loads(match.group(1))
        except:
            pass

    match = re.search(r'\{[^{}]*"address"[^{}]*\}', output)
    if match:
        try:
            return json.loads(match.group(0))
        except:
            pass

    return None

# ============================================================================
# GIT
# ============================================================================

def git_has_changes() -> bool:
    result = subprocess.run(["git", "status", "--porcelain"], capture_output=True, text=True)
    return bool(result.stdout.strip())

def git_commit(node: Node) -> bool:
    if not git_has_changes():
        return True

    subprocess.run(["git", "add", "-A"], check=True)
    addr = node.address.replace("$", "").replace(":", "_")
    msg = f"[BFS-{addr}] {node.description}"

    body = f"""{msg}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet <noreply@anthropic.com>"""

    result = subprocess.run(["git", "commit", "-m", body], capture_output=True, text=True)
    if result.returncode == 0:
        print(f"{C.GRN}✅ Commit{C.R}")
        return True
    return False

def git_restore():
    subprocess.run(["git", "checkout", "."], capture_output=True)
    subprocess.run(["git", "clean", "-fd"], capture_output=True)
    print(f"{C.YEL}🔄 Restauré{C.R}")

def git_push() -> bool:
    result = subprocess.run(["git", "push"], capture_output=True, text=True, timeout=60)
    return result.returncode == 0

# ============================================================================
# VALIDATION
# ============================================================================

def make_verify() -> bool:
    """Vérifie le hash."""
    try:
        result = subprocess.run(["make", "verify"], capture_output=True, text=True, timeout=60)
        output = result.stdout + result.stderr
        success = "VERIFICATION REUSSIE" in output or "[OK]" in output
        if success:
            print(f"{C.GRN}✅ Hash OK{C.R}")
        else:
            print(f"{C.RED}❌ Hash FAIL{C.R}")
        return success
    except Exception as e:
        print(f"{C.RED}💥 make verify: {e}{C.R}")
        return False

# ============================================================================
# EXPLORATION PRINCIPALE
# ============================================================================

def explore_node(node: Node, state: State) -> ExploreResult:
    """Explore un noeud selon le PLAYBOOK."""

    print(f"\n{'═'*60}")
    print(f"{C.CYN}🎯 {node.address}{C.R} ({node.node_type.value}, bank {node.bank})")
    print(f"   {node.description}")
    print(f"{'═'*60}")

    # Checks préliminaires
    if node.address in state.visited:
        print(f"{C.YEL}⏭️ Déjà visité{C.R}")
        return ExploreResult.SKIPPED_ALREADY_VISITED

    if node.address in state.failed:
        print(f"{C.YEL}⏭️ Déjà échoué{C.R}")
        return ExploreResult.SKIPPED_ALREADY_VISITED

    if node.address in state.needs_reconstruction:
        print(f"{C.YEL}⏭️ Nécessite reconstruction (tâche séparée){C.R}")
        return ExploreResult.SKIPPED_BAD_DISASM

    # ─────────────────────────────────────────────────────────
    # PHASE 1: ANALYZE
    # ─────────────────────────────────────────────────────────
    print(f"\n{C.CYN}📖 PHASE 1: ANALYZE (max {TIMEOUT_ANALYZE}s){C.R}")

    prompt = prompt_analyze(node)
    success, output, log_len, analysis = run_claude_monitored(prompt, TIMEOUT_ANALYZE)

    if not success:
        state.failed.add(node.address)
        reason = output if output in ['timeout', 'overthink', 'death_pattern', 'too_many_problems'] else 'analyze_failed'
        state.metrics.update(ExploreResult(f"failed_{reason}"), log_len)
        return ExploreResult(f"failed_{reason}")

    if not analysis:
        print(f"{C.RED}❌ Pas de JSON{C.R}")
        state.failed.add(node.address)
        state.metrics.update(ExploreResult.FAILED_HASH, log_len)
        return ExploreResult.FAILED_HASH

    # Vérifier bad_disasm
    if analysis.get('bad_disasm', False):
        print(f"{C.YEL}⚠️ bad_disassembly détecté → SKIP{C.R}")
        state.needs_reconstruction.add(node.address)
        state.metrics.update(ExploreResult.SKIPPED_BAD_DISASM, log_len)
        return ExploreResult.SKIPPED_BAD_DISASM

    print(f"{C.GRN}✓ Type: {analysis.get('type')} | Refs: {len(analysis.get('refs', []))}{C.R}")

    # ─────────────────────────────────────────────────────────
    # PHASE 2: DOCUMENT (seulement pour code/handler)
    # ─────────────────────────────────────────────────────────
    node_type = analysis.get('type', 'unknown')

    if node_type in ['code', 'handler']:
        print(f"\n{C.BLU}📝 PHASE 2: DOCUMENT (max {TIMEOUT_DOCUMENT}s){C.R}")

        prompt = prompt_document(node, analysis)
        success, output, log_len2, doc_result = run_claude_monitored(prompt, TIMEOUT_DOCUMENT)
        log_len += log_len2

        if not success:
            git_restore()
            state.failed.add(node.address)
            state.metrics.update(ExploreResult.FAILED_HASH, log_len)
            return ExploreResult.FAILED_HASH
    else:
        print(f"{C.YEL}⏭️ Skip DOCUMENT pour type {node_type}{C.R}")

    # ─────────────────────────────────────────────────────────
    # PHASE 3: VALIDATE
    # ─────────────────────────────────────────────────────────
    print(f"\n{C.GRN}✔️ PHASE 3: VALIDATE{C.R}")

    if git_has_changes():
        if not make_verify():
            git_restore()
            state.failed.add(node.address)
            state.metrics.update(ExploreResult.FAILED_HASH, log_len)
            return ExploreResult.FAILED_HASH

        # Commit
        if not git_commit(node):
            git_restore()
            state.failed.add(node.address)
            state.metrics.update(ExploreResult.FAILED_HASH, log_len)
            return ExploreResult.FAILED_HASH

        state.commits_since_push += 1

    # ─────────────────────────────────────────────────────────
    # SUCCÈS - Ajouter références
    # ─────────────────────────────────────────────────────────
    state.visited.add(node.address)

    for ref in analysis.get('refs', []):
        addr = ref.get('addr', '')
        if addr and addr not in state.visited and addr not in state.failed:
            existing = [n for n in state.frontier if n.address == addr]
            if not existing:
                new_node = Node(
                    address=addr,
                    node_type=NodeType(ref.get('type', 'unknown')),
                    description=ref.get('desc', ''),
                    source=node.address,
                    bank=ref.get('bank', node.bank),
                    priority=3
                )
                state.frontier.append(new_node)
                print(f"{C.GRY}  + {addr}{C.R}")

    state.metrics.update(ExploreResult.SUCCESS, log_len)
    return ExploreResult.SUCCESS

# ============================================================================
# FRONTIÈRE INITIALE
# ============================================================================

def initial_frontier() -> List[Node]:
    return [
        # Priorité 0: Vecteurs d'interruption
        Node("$0040", NodeType.HANDLER, "VBlank interrupt", "boot", 0, 0),
        Node("$0048", NodeType.HANDLER, "LCD STAT interrupt", "boot", 0, 0),
        Node("$0050", NodeType.HANDLER, "Timer interrupt", "boot", 0, 0),
        Node("$0100", NodeType.CODE, "ROM Entry point", "boot", 0, 0),

        # Priorité 1: Handlers principaux
        Node("$0060", NodeType.HANDLER, "VBlankHandler", "$0040", 0, 1),
        Node("$0095", NodeType.HANDLER, "LCDStatHandler", "$0048", 0, 1),
        Node("$0185", NodeType.CODE, "SystemInit", "$0100", 0, 1),
    ]

# ============================================================================
# MAIN
# ============================================================================

def print_banner():
    print(f"""
{C.CYN}╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║   🎮  BFS EXPLORER V3 - ORCHESTRATEUR ULTIME  🎮               ║
║                                                                ║
║   Basé sur PLAYBOOK.md (907 explorations analysées)            ║
║   Objectif: 80%+ de succès                                     ║
║                                                                ║
║   RÈGLES: Log<1500 | Problems<2 | Tools≤2 | NoByteWar         ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝{C.R}
""")

def print_metrics(metrics: ExplorationMetrics):
    print(f"\n{C.CYN}📊 MÉTRIQUES{C.R}")
    print(f"   Tentatives: {metrics.total_attempts}")
    print(f"   Succès: {metrics.successes} ({metrics.success_rate*100:.1f}%)")
    print(f"   Log moyen succès: {int(metrics.avg_log_length_success)} chars")
    print(f"   Log moyen échec: {int(metrics.avg_log_length_failure)} chars")
    if metrics.failures_by_reason:
        print(f"   Échecs par raison:")
        for reason, count in sorted(metrics.failures_by_reason.items(), key=lambda x: -x[1]):
            print(f"      {reason}: {count}")

def main():
    parser = argparse.ArgumentParser(description="BFS Explorer V3 - Orchestrateur Ultime")
    parser.add_argument("--max-nodes", type=int, default=10)
    parser.add_argument("--push-every", type=int, default=10)
    parser.add_argument("--reset", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    print_banner()

    # Charger l'état
    if args.reset or not os.path.exists(STATE_FILE):
        state = State(frontier=initial_frontier())
        print(f"{C.GRN}🆕 Nouvel état{C.R}")
    else:
        state = State.load(STATE_FILE)
        print(f"{C.CYN}📂 État chargé: {len(state.frontier)} frontière, {len(state.visited)} visités{C.R}")

    # Trier par priorité
    state.frontier.sort(key=lambda n: n.priority)

    explored = 0
    while state.frontier and explored < args.max_nodes:
        node = state.frontier.pop(0)

        if args.dry_run:
            print(f"\n[DRY-RUN] {node.address}: {node.description}")
            continue

        result = explore_node(node, state)

        if result == ExploreResult.SUCCESS:
            explored += 1

        # Push périodique
        if state.commits_since_push >= args.push_every:
            if git_push():
                print(f"{C.GRN}🚀 Push OK{C.R}")
                state.commits_since_push = 0

        # Sauvegarder
        state.save(STATE_FILE)

    # Résumé
    print(f"\n{'═'*60}")
    print_metrics(state.metrics)
    print(f"\n   Frontière: {len(state.frontier)}")
    print(f"   Visités: {len(state.visited)}")
    print(f"   Échecs: {len(state.failed)}")
    print(f"   À reconstruire: {len(state.needs_reconstruction)}")
    print(f"{'═'*60}")

    state.save(STATE_FILE)

if __name__ == "__main__":
    main()
