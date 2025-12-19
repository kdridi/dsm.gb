#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PASS 1 : EXTRACTION MASSIVE DES 907 REPORTS
============================================

Ce script analyse EN PROFONDEUR chaque report pour extraire :
- Métriques quantitatives
- Patterns de raisonnement
- Séquences d'outils utilisés
- Corrélations succès/échec
- Vocabulaire récurrent
- Techniques identifiées

Output : extracted_knowledge.json (base pour PASS 2)
"""

import json
import re
import os
from collections import Counter, defaultdict
from dataclasses import dataclass, field, asdict
from typing import List, Dict, Set, Tuple, Optional, Any
from pathlib import Path

# ============================================================================
# STRUCTURES DE DONNÉES
# ============================================================================

@dataclass
class ToolUsage:
    """Usage d'un outil dans un log."""
    name: str
    count: int
    contexts: List[str] = field(default_factory=list)

@dataclass
class ReasoningPattern:
    """Pattern de raisonnement identifié."""
    pattern_type: str  # "investigation", "reconstruction", "abandon", etc.
    trigger: str       # Ce qui déclenche ce pattern
    outcome: str       # "success", "failure", "partial"
    frequency: int = 1

@dataclass
class NodeAnalysis:
    """Analyse complète d'un noeud exploré."""
    address: str
    commit_hash: str
    node_type: str  # code, data, table, handler

    # Métriques
    log_length: int
    diff_lines_added: int
    diff_lines_removed: int
    diff_files_modified: List[str]

    # Succès/Échec
    success: bool
    failure_reason: Optional[str]
    hash_verified: bool

    # Patterns détectés
    tools_used: List[str]
    reasoning_steps: List[str]
    problems_encountered: List[str]
    solutions_applied: List[str]

    # Références
    references_found: int
    references_addresses: List[str]

    # Temps estimé (basé sur longueur)
    estimated_complexity: str  # "simple", "medium", "complex", "nightmare"

    # Extraits importants
    key_insights: List[str]
    mistakes_made: List[str]

@dataclass
class GlobalKnowledge:
    """Connaissances globales extraites."""
    total_reports: int = 0

    # Stats par type
    stats_by_type: Dict[str, Dict] = field(default_factory=dict)

    # Taux de succès
    success_rate_global: float = 0.0
    success_rate_by_type: Dict[str, float] = field(default_factory=dict)

    # Top patterns
    top_successful_patterns: List[Dict] = field(default_factory=list)
    top_failure_patterns: List[Dict] = field(default_factory=list)

    # Outils
    tool_effectiveness: Dict[str, Dict] = field(default_factory=dict)
    tool_sequences_success: List[List[str]] = field(default_factory=list)
    tool_sequences_failure: List[List[str]] = field(default_factory=list)

    # Vocabulaire
    success_vocabulary: List[Tuple[str, int]] = field(default_factory=list)
    failure_vocabulary: List[Tuple[str, int]] = field(default_factory=list)

    # Règles découvertes
    rules_discovered: List[Dict] = field(default_factory=list)

    # Antipatterns
    antipatterns: List[Dict] = field(default_factory=list)

    # Templates
    successful_comment_templates: List[str] = field(default_factory=list)

    # Par adresse/zone
    knowledge_by_address_range: Dict[str, Dict] = field(default_factory=dict)

    # Analyses individuelles
    all_analyses: List[Dict] = field(default_factory=list)

# ============================================================================
# EXTRACTEURS
# ============================================================================

def extract_node_type(comment: str, log: str) -> str:
    """Détermine le type de noeud."""
    comment_lower = comment.lower()
    log_lower = log[:1000].lower()

    if 'handler' in comment_lower or 'handler' in log_lower:
        return 'handler'
    elif 'table' in comment_lower or 'jumptable' in comment_lower:
        return 'table'
    elif 'data' in comment_lower or 'tile' in comment_lower or 'sprite' in comment_lower:
        return 'data'
    else:
        return 'code'

def extract_address(comment: str) -> str:
    """Extrait l'adresse du commentaire BFS."""
    match = re.search(r'BFS-([0-9a-fA-F_:]+)', comment)
    if match:
        return f"${match.group(1).upper()}"
    return "unknown"

def extract_tools_used(log: str) -> List[str]:
    """Extrait les outils utilisés dans le log."""
    tools = []
    tool_patterns = [
        (r'🔧\s*(\w+)', 'tool_emoji'),
        (r'grep', 'grep'),
        (r'xxd', 'xxd'),
        (r'make verify', 'make_verify'),
        (r'git checkout', 'git_checkout'),
        (r'Read\s', 'Read'),
        (r'Edit\s', 'Edit'),
        (r'Glob\s', 'Glob'),
        (r'Bash\s', 'Bash'),
    ]

    for pattern, name in tool_patterns:
        if re.search(pattern, log, re.IGNORECASE):
            tools.append(name)

    return list(set(tools))

def extract_problems(log: str) -> List[str]:
    """Extrait les problèmes rencontrés."""
    problems = []

    problem_patterns = [
        (r'hash a changé', 'hash_changed'),
        (r'hash différent', 'hash_different'),
        (r'erreur', 'error_generic'),
        (r'échec', 'failure_generic'),
        (r'WTF', 'wtf_moment'),
        (r'frustré', 'frustration'),
        (r'problème', 'problem_generic'),
        (r'mal désassemblé', 'bad_disassembly'),
        (r'bataille', 'byte_battle'),
        (r'byte par byte', 'byte_by_byte'),
        (r'manque', 'missing_something'),
        (r'décalage', 'offset_error'),
        (r'inversé', 'inverted'),
        (r'supprimé', 'deleted_wrongly'),
        (r'oublié', 'forgotten'),
    ]

    log_lower = log.lower()
    for pattern, name in problem_patterns:
        if re.search(pattern, log_lower):
            problems.append(name)

    return problems

def extract_solutions(log: str) -> List[str]:
    """Extrait les solutions appliquées."""
    solutions = []

    solution_patterns = [
        (r'corrigeons', 'correction'),
        (r'corrigé', 'corrected'),
        (r'reconstruit', 'reconstructed'),
        (r'remplacé', 'replaced'),
        (r'ajouté', 'added'),
        (r'renommé', 'renamed'),
        (r'annul', 'cancelled'),
        (r'restaur', 'restored'),
        (r'vérifions', 'verification'),
        (r'simplifions', 'simplified'),
        (r'abandonn', 'abandoned'),
    ]

    log_lower = log.lower()
    for pattern, name in solution_patterns:
        if re.search(pattern, log_lower):
            solutions.append(name)

    return solutions

def extract_reasoning_steps(log: str) -> List[str]:
    """Extrait les étapes de raisonnement."""
    steps = []

    # Chercher les marqueurs de raisonnement
    step_patterns = [
        r'je vais\s+([^\.]+)',
        r'laisse-moi\s+([^\.]+)',
        r'cherchons\s+([^\.]+)',
        r'vérifions\s+([^\.]+)',
        r'analysons\s+([^\.]+)',
        r'regardons\s+([^\.]+)',
        r'comptons\s+([^\.]+)',
        r'comparons\s+([^\.]+)',
        r'testons\s+([^\.]+)',
    ]

    for pattern in step_patterns:
        matches = re.findall(pattern, log.lower())
        for match in matches[:5]:  # Limiter à 5 par type
            steps.append(match[:100])

    return steps[:20]  # Max 20 steps

def extract_references(log: str) -> Tuple[int, List[str]]:
    """Extrait les références trouvées."""
    addresses = []

    # Chercher les patterns d'adresses
    addr_patterns = [
        r'\$([0-9a-fA-F]{4})',
        r'0x([0-9a-fA-F]{4})',
    ]

    for pattern in addr_patterns:
        matches = re.findall(pattern, log)
        for match in matches:
            addr = f"${match.upper()}"
            if addr not in addresses:
                addresses.append(addr)

    return len(addresses), addresses[:50]  # Limiter à 50

def extract_key_insights(log: str) -> List[str]:
    """Extrait les insights clés."""
    insights = []

    # Patterns d'insight
    insight_patterns = [
        r'je comprends\s+([^\.!]+)',
        r'je vois\s+([^\.!]+)',
        r'c\'est\s+([^\.!]+)',
        r'donc\s+([^\.!]+)',
        r'en fait\s+([^\.!]+)',
        r'le problème\s+([^\.!]+)',
        r'la solution\s+([^\.!]+)',
        r'parfait\s*!\s*([^\.!]+)',
        r'excellent\s*!\s*([^\.!]+)',
    ]

    for pattern in insight_patterns:
        matches = re.findall(pattern, log.lower())
        for match in matches[:3]:
            if len(match) > 20:  # Insight significatif
                insights.append(match[:150])

    return insights[:10]

def extract_mistakes(log: str) -> List[str]:
    """Extrait les erreurs commises."""
    mistakes = []

    mistake_patterns = [
        r'ah\s*!\s*([^\.!]+)',
        r'attendez\s*,?\s*([^\.!]+)',
        r'j\'ai mal\s+([^\.!]+)',
        r'erreur\s*:?\s*([^\.!]+)',
        r'je dois avoir\s+([^\.!]+)',
        r'ça n\'a pas de sens\s+([^\.!]*)',
        r'wtf\s*!?\s*([^\.!]*)',
    ]

    for pattern in mistake_patterns:
        matches = re.findall(pattern, log.lower())
        for match in matches[:3]:
            if len(match) > 10:
                mistakes.append(match[:150])

    return mistakes[:10]

def estimate_complexity(log_length: int, problems: List[str], diff_lines: int) -> str:
    """Estime la complexité du noeud."""
    if log_length < 1000 and len(problems) == 0:
        return "simple"
    elif log_length < 3000 and len(problems) <= 2:
        return "medium"
    elif log_length < 8000 and len(problems) <= 5:
        return "complex"
    else:
        return "nightmare"

def check_success(log: str, diff: str) -> Tuple[bool, Optional[str], bool]:
    """Vérifie si l'exploration a réussi."""
    log_lower = log.lower()

    # Indicateurs de succès
    hash_verified = any(p in log_lower for p in [
        'hash vérifié', 'hash identique', 'make verify réussi',
        'verification reussie', '[ok]', 'hash est validé'
    ])

    # Indicateurs d'échec
    failure_indicators = [
        ('hash a changé', 'hash_changed'),
        ('hash différent', 'hash_mismatch'),
        ('échec', 'generic_failure'),
        ('abandonn', 'abandoned'),
        ('frustré', 'gave_up'),
    ]

    failure_reason = None
    for pattern, reason in failure_indicators:
        if pattern in log_lower:
            failure_reason = reason
            break

    # Succès si hash vérifié ET pas d'abandon
    success = hash_verified and failure_reason not in ['abandoned', 'gave_up']

    return success, failure_reason, hash_verified

def parse_diff(diff: str) -> Tuple[int, int, List[str]]:
    """Parse le diff git."""
    lines_added = diff.count('\n+') - diff.count('\n+++')
    lines_removed = diff.count('\n-') - diff.count('\n---')

    files = []
    for match in re.findall(r'diff --git a/(\S+)', diff):
        files.append(match)

    return lines_added, lines_removed, files

def extract_comment_templates(log: str, diff: str) -> List[str]:
    """Extrait les templates de commentaires réussis."""
    templates = []

    # Chercher les blocs de commentaires dans le diff
    comment_blocks = re.findall(
        r'^\+;\s*(\w+)\n\+;\s*[-=]+\n\+;\s*Description:\s*([^\n]+)',
        diff,
        re.MULTILINE
    )

    for name, desc in comment_blocks:
        templates.append(f"; {name}\n; Description: {desc}")

    return templates

# ============================================================================
# ANALYSEUR PRINCIPAL
# ============================================================================

def analyze_single_report(item: dict) -> NodeAnalysis:
    """Analyse un seul report en profondeur."""

    log = item.get('log', '')
    diff = item.get('diff', '')
    comment = item.get('comment', '')
    commit_hash = item.get('hash', '')

    # Extractions
    address = extract_address(comment)
    node_type = extract_node_type(comment, log)
    tools = extract_tools_used(log)
    problems = extract_problems(log)
    solutions = extract_solutions(log)
    reasoning = extract_reasoning_steps(log)
    ref_count, ref_addrs = extract_references(log)
    insights = extract_key_insights(log)
    mistakes = extract_mistakes(log)
    lines_add, lines_rem, files = parse_diff(diff)
    success, failure_reason, hash_ok = check_success(log, diff)
    complexity = estimate_complexity(len(log), problems, lines_add + lines_rem)

    return NodeAnalysis(
        address=address,
        commit_hash=commit_hash,
        node_type=node_type,
        log_length=len(log),
        diff_lines_added=lines_add,
        diff_lines_removed=lines_rem,
        diff_files_modified=files,
        success=success,
        failure_reason=failure_reason,
        hash_verified=hash_ok,
        tools_used=tools,
        reasoning_steps=reasoning,
        problems_encountered=problems,
        solutions_applied=solutions,
        references_found=ref_count,
        references_addresses=ref_addrs[:20],
        estimated_complexity=complexity,
        key_insights=insights,
        mistakes_made=mistakes
    )

def compute_global_stats(analyses: List[NodeAnalysis]) -> GlobalKnowledge:
    """Calcule les statistiques globales."""

    knowledge = GlobalKnowledge()
    knowledge.total_reports = len(analyses)

    # Compteurs par type
    type_counts = Counter()
    type_success = Counter()

    # Vocabulaire succès/échec
    success_words = Counter()
    failure_words = Counter()

    # Séquences d'outils
    success_tool_seqs = []
    failure_tool_seqs = []

    # Templates de commentaires
    all_templates = []

    # Problèmes et solutions
    all_problems = Counter()
    all_solutions = Counter()

    # Par complexité
    complexity_success = defaultdict(lambda: {'success': 0, 'total': 0})

    for analysis in analyses:
        # Stats par type
        type_counts[analysis.node_type] += 1
        if analysis.success:
            type_success[analysis.node_type] += 1

        # Vocabulaire
        words = analysis.key_insights + analysis.reasoning_steps
        if analysis.success:
            for w in words:
                for word in w.split()[:10]:
                    if len(word) > 4:
                        success_words[word.lower()] += 1
            success_tool_seqs.append(analysis.tools_used)
        else:
            for w in words + analysis.mistakes_made:
                for word in w.split()[:10]:
                    if len(word) > 4:
                        failure_words[word.lower()] += 1
            failure_tool_seqs.append(analysis.tools_used)

        # Problèmes et solutions
        for p in analysis.problems_encountered:
            all_problems[p] += 1
        for s in analysis.solutions_applied:
            all_solutions[s] += 1

        # Complexité
        complexity_success[analysis.estimated_complexity]['total'] += 1
        if analysis.success:
            complexity_success[analysis.estimated_complexity]['success'] += 1

    # Calculer les taux
    knowledge.success_rate_global = sum(1 for a in analyses if a.success) / len(analyses) if analyses else 0

    for t in type_counts:
        knowledge.success_rate_by_type[t] = type_success[t] / type_counts[t] if type_counts[t] > 0 else 0
        knowledge.stats_by_type[t] = {
            'total': type_counts[t],
            'success': type_success[t],
            'rate': knowledge.success_rate_by_type[t]
        }

    # Top vocabulaire
    knowledge.success_vocabulary = success_words.most_common(100)
    knowledge.failure_vocabulary = failure_words.most_common(100)

    # Top problèmes
    knowledge.antipatterns = [
        {'problem': p, 'frequency': c, 'severity': 'high' if c > 50 else 'medium' if c > 20 else 'low'}
        for p, c in all_problems.most_common(30)
    ]

    # Règles découvertes basées sur les corrélations
    knowledge.rules_discovered = discover_rules(analyses, all_problems, all_solutions)

    # Séquences d'outils efficaces
    knowledge.tool_sequences_success = find_common_sequences(success_tool_seqs)
    knowledge.tool_sequences_failure = find_common_sequences(failure_tool_seqs)

    # Analyses individuelles (résumé)
    knowledge.all_analyses = [asdict(a) for a in analyses]

    return knowledge

def discover_rules(analyses: List[NodeAnalysis], problems: Counter, solutions: Counter) -> List[Dict]:
    """Découvre des règles basées sur les corrélations."""
    rules = []

    # Règle 1: Complexité vs Succès
    simple_success = sum(1 for a in analyses if a.estimated_complexity == 'simple' and a.success)
    simple_total = sum(1 for a in analyses if a.estimated_complexity == 'simple')
    nightmare_success = sum(1 for a in analyses if a.estimated_complexity == 'nightmare' and a.success)
    nightmare_total = sum(1 for a in analyses if a.estimated_complexity == 'nightmare')

    if simple_total > 0 and nightmare_total > 0:
        rules.append({
            'rule': 'COMPLEXITY_IMPACT',
            'description': f'Les noeuds simples réussissent à {simple_success/simple_total*100:.1f}% vs {nightmare_success/nightmare_total*100:.1f}% pour les cauchemars',
            'recommendation': 'Décomposer les tâches complexes en sous-tâches simples'
        })

    # Règle 2: Problèmes mortels
    for problem, count in problems.most_common(5):
        problem_analyses = [a for a in analyses if problem in a.problems_encountered]
        if problem_analyses:
            failure_rate = sum(1 for a in problem_analyses if not a.success) / len(problem_analyses)
            if failure_rate > 0.5:
                rules.append({
                    'rule': f'AVOID_{problem.upper()}',
                    'description': f'Le problème "{problem}" cause {failure_rate*100:.1f}% d\'échecs',
                    'recommendation': f'Éviter ou abandonner rapidement si {problem} détecté'
                })

    # Règle 3: Solutions efficaces
    for solution, count in solutions.most_common(5):
        solution_analyses = [a for a in analyses if solution in a.solutions_applied]
        if solution_analyses:
            success_rate = sum(1 for a in solution_analyses if a.success) / len(solution_analyses)
            if success_rate > 0.7:
                rules.append({
                    'rule': f'USE_{solution.upper()}',
                    'description': f'La solution "{solution}" a {success_rate*100:.1f}% de succès',
                    'recommendation': f'Appliquer "{solution}" quand approprié'
                })

    # Règle 4: Type de noeud
    for node_type in ['code', 'handler', 'data', 'table']:
        type_analyses = [a for a in analyses if a.node_type == node_type]
        if type_analyses:
            avg_complexity = Counter(a.estimated_complexity for a in type_analyses).most_common(1)
            if avg_complexity:
                rules.append({
                    'rule': f'{node_type.upper()}_STRATEGY',
                    'description': f'Les noeuds {node_type} sont généralement {avg_complexity[0][0]}',
                    'recommendation': f'Adapter la stratégie pour le type {node_type}'
                })

    return rules

def find_common_sequences(tool_lists: List[List[str]]) -> List[List[str]]:
    """Trouve les séquences d'outils communes."""
    if not tool_lists:
        return []

    # Compter les combinaisons
    combos = Counter()
    for tools in tool_lists:
        if tools:
            combo = tuple(sorted(set(tools)))
            combos[combo] += 1

    # Retourner les plus communes
    return [list(combo) for combo, _ in combos.most_common(10)]

# ============================================================================
# GÉNÉRATEUR DE RAPPORT
# ============================================================================

def generate_summary_report(knowledge: GlobalKnowledge) -> str:
    """Génère un rapport textuel résumé."""

    report = []
    report.append("=" * 80)
    report.append("PASS 1 : EXTRACTION MASSIVE - RAPPORT")
    report.append("=" * 80)
    report.append("")

    # Stats globales
    report.append(f"TOTAL REPORTS ANALYSÉS: {knowledge.total_reports}")
    report.append(f"TAUX DE SUCCÈS GLOBAL: {knowledge.success_rate_global*100:.1f}%")
    report.append("")

    # Par type
    report.append("SUCCÈS PAR TYPE:")
    for t, stats in knowledge.stats_by_type.items():
        report.append(f"  {t}: {stats['rate']*100:.1f}% ({stats['success']}/{stats['total']})")
    report.append("")

    # Antipatterns
    report.append("TOP ANTIPATTERNS (à éviter):")
    for ap in knowledge.antipatterns[:10]:
        report.append(f"  [{ap['severity']}] {ap['problem']}: {ap['frequency']} occurrences")
    report.append("")

    # Règles
    report.append("RÈGLES DÉCOUVERTES:")
    for rule in knowledge.rules_discovered:
        report.append(f"  {rule['rule']}")
        report.append(f"    → {rule['description']}")
        report.append(f"    ★ {rule['recommendation']}")
    report.append("")

    # Outils efficaces
    report.append("SÉQUENCES D'OUTILS EFFICACES:")
    for seq in knowledge.tool_sequences_success[:5]:
        report.append(f"  {' → '.join(seq)}")
    report.append("")

    # Vocabulaire
    report.append("VOCABULAIRE SUCCÈS (top 20):")
    report.append(f"  {', '.join(w for w, _ in knowledge.success_vocabulary[:20])}")
    report.append("")

    report.append("VOCABULAIRE ÉCHEC (top 20):")
    report.append(f"  {', '.join(w for w, _ in knowledge.failure_vocabulary[:20])}")

    return '\n'.join(report)

# ============================================================================
# MAIN
# ============================================================================

def main():
    print("=" * 80)
    print("PASS 1 : EXTRACTION MASSIVE DES 907 REPORTS")
    print("=" * 80)
    print()

    # Charger analyzer.json
    print("📂 Chargement de analyzer.json...")
    with open('analyzer.json', 'r') as f:
        data = json.load(f)
    print(f"   ✓ {len(data)} reports chargés")
    print()

    # Analyser chaque report
    print("🔬 Analyse en profondeur de chaque report...")
    analyses = []
    for i, item in enumerate(data):
        if i % 100 == 0:
            print(f"   Progression: {i}/{len(data)} ({i*100//len(data)}%)")
        analysis = analyze_single_report(item)
        analyses.append(analysis)
    print(f"   ✓ {len(analyses)} analyses complétées")
    print()

    # Calculer les stats globales
    print("📊 Calcul des statistiques globales...")
    knowledge = compute_global_stats(analyses)
    print("   ✓ Statistiques calculées")
    print()

    # Sauvegarder le JSON complet
    output_file = 'scripts/extracted_knowledge.json'
    print(f"💾 Sauvegarde vers {output_file}...")
    with open(output_file, 'w') as f:
        # Convertir pour JSON
        knowledge_dict = {
            'total_reports': knowledge.total_reports,
            'success_rate_global': knowledge.success_rate_global,
            'success_rate_by_type': knowledge.success_rate_by_type,
            'stats_by_type': knowledge.stats_by_type,
            'antipatterns': knowledge.antipatterns,
            'rules_discovered': knowledge.rules_discovered,
            'tool_sequences_success': knowledge.tool_sequences_success,
            'tool_sequences_failure': knowledge.tool_sequences_failure,
            'success_vocabulary': knowledge.success_vocabulary[:50],
            'failure_vocabulary': knowledge.failure_vocabulary[:50],
            'all_analyses': knowledge.all_analyses
        }
        json.dump(knowledge_dict, f, indent=2, ensure_ascii=False)
    print(f"   ✓ {os.path.getsize(output_file) / 1024:.1f} KB sauvegardés")
    print()

    # Générer le rapport texte
    report = generate_summary_report(knowledge)
    report_file = 'scripts/pass1_report.txt'
    with open(report_file, 'w') as f:
        f.write(report)
    print(f"📄 Rapport texte: {report_file}")
    print()

    # Afficher le résumé
    print(report)

if __name__ == "__main__":
    main()
