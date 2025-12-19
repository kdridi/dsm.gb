#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PASS 2 : ANALYSE PROFONDE DES SUCCÈS ET ÉCHECS
==============================================

Ce script analyse en détail :
1. Les 53 cas de SUCCÈS (5.8%) - POURQUOI ça a marché ?
2. Les patterns d'échec les plus fréquents
3. Les corrélations fines

Output : deep_analysis.json + lots pour analyse Claude
"""

import json
import os
from collections import Counter, defaultdict
from typing import List, Dict, Any

def load_extracted_knowledge() -> Dict:
    """Charge les données extraites par PASS 1."""
    with open('scripts/extracted_knowledge.json', 'r') as f:
        return json.load(f)

def analyze_successes(analyses: List[Dict]) -> Dict:
    """Analyse en profondeur les cas de succès."""

    successes = [a for a in analyses if a['success']]

    result = {
        'total_successes': len(successes),
        'by_type': defaultdict(list),
        'by_complexity': defaultdict(list),
        'common_patterns': [],
        'successful_addresses': [],
        'successful_insights': [],
        'successful_tools': Counter(),
        'successful_solutions': Counter(),
    }

    for s in successes:
        result['by_type'][s['node_type']].append(s['address'])
        result['by_complexity'][s['estimated_complexity']].append(s['address'])
        result['successful_addresses'].append({
            'address': s['address'],
            'type': s['node_type'],
            'complexity': s['estimated_complexity'],
            'log_length': s['log_length'],
            'insights': s['key_insights'][:3],
            'tools': s['tools_used'],
            'solutions': s['solutions_applied']
        })

        for tool in s['tools_used']:
            result['successful_tools'][tool] += 1

        for sol in s['solutions_applied']:
            result['successful_solutions'][sol] += 1

        result['successful_insights'].extend(s['key_insights'][:2])

    # Convertir pour JSON
    result['by_type'] = dict(result['by_type'])
    result['by_complexity'] = dict(result['by_complexity'])
    result['successful_tools'] = dict(result['successful_tools'])
    result['successful_solutions'] = dict(result['successful_solutions'])

    return result

def analyze_failures(analyses: List[Dict]) -> Dict:
    """Analyse en profondeur les échecs."""

    failures = [a for a in analyses if not a['success']]

    result = {
        'total_failures': len(failures),
        'by_reason': defaultdict(int),
        'by_type_and_reason': defaultdict(lambda: defaultdict(int)),
        'common_mistakes': Counter(),
        'problem_correlations': defaultdict(list),
        'nightmare_cases': [],
        'avoidable_failures': [],
    }

    for f in failures:
        reason = f['failure_reason'] or 'unknown'
        result['by_reason'][reason] += 1
        result['by_type_and_reason'][f['node_type']][reason] += 1

        for mistake in f['mistakes_made']:
            result['common_mistakes'][mistake] += 1

        # Cas cauchemars
        if f['estimated_complexity'] == 'nightmare':
            result['nightmare_cases'].append({
                'address': f['address'],
                'type': f['node_type'],
                'problems': f['problems_encountered'],
                'log_length': f['log_length']
            })

        # Corrélations problèmes
        for prob in f['problems_encountered']:
            result['problem_correlations'][prob].append(f['node_type'])

    # Convertir pour JSON
    result['by_reason'] = dict(result['by_reason'])
    result['by_type_and_reason'] = {k: dict(v) for k, v in result['by_type_and_reason'].items()}
    result['common_mistakes'] = dict(result['common_mistakes'].most_common(30))
    result['problem_correlations'] = {k: dict(Counter(v)) for k, v in result['problem_correlations'].items()}

    return result

def identify_golden_patterns(successes: List[Dict]) -> List[Dict]:
    """Identifie les patterns en or (ce qui marche toujours)."""

    patterns = []

    # Pattern 1: Log court = succès
    short_log_successes = [s for s in successes if s['log_length'] < 1500]
    if short_log_successes:
        patterns.append({
            'name': 'SHORT_LOG_SUCCESS',
            'description': f'{len(short_log_successes)} succès avec log < 1500 chars',
            'rule': 'Si le log dépasse 1500 chars, ABANDONNER',
            'examples': [s['address'] for s in short_log_successes[:5]]
        })

    # Pattern 2: Pas de problème = succès
    no_problem_successes = [s for s in successes if len(s['problems_encountered']) == 0]
    if no_problem_successes:
        patterns.append({
            'name': 'CLEAN_EXECUTION',
            'description': f'{len(no_problem_successes)} succès sans aucun problème détecté',
            'rule': 'Au premier problème, évaluer si abandon nécessaire',
            'examples': [s['address'] for s in no_problem_successes[:5]]
        })

    # Pattern 3: Outils minimaux
    minimal_tools = [s for s in successes if len(s['tools_used']) <= 2]
    if minimal_tools:
        patterns.append({
            'name': 'MINIMAL_TOOLS',
            'description': f'{len(minimal_tools)} succès avec 2 outils max',
            'rule': 'Utiliser le minimum d\'outils nécessaires',
            'examples': [{'addr': s['address'], 'tools': s['tools_used']} for s in minimal_tools[:5]]
        })

    # Pattern 4: Complexité simple
    simple_successes = [s for s in successes if s['estimated_complexity'] == 'simple']
    if simple_successes:
        patterns.append({
            'name': 'KEEP_IT_SIMPLE',
            'description': f'{len(simple_successes)} succès sur tâches simples',
            'rule': 'Décomposer les tâches complexes en tâches simples',
            'examples': [s['address'] for s in simple_successes[:5]]
        })

    return patterns

def identify_death_patterns(failures: List[Dict]) -> List[Dict]:
    """Identifie les patterns mortels (ce qui échoue toujours)."""

    patterns = []

    # Pattern 1: bad_disassembly
    bad_disasm = [f for f in failures if 'bad_disassembly' in f['problems_encountered']]
    if bad_disasm:
        patterns.append({
            'name': 'DEATH_BY_DISASSEMBLY',
            'description': f'{len(bad_disasm)} échecs liés à bad_disassembly',
            'rule': 'NE JAMAIS tenter de reconstruire du code mal désassemblé dans le flux principal',
            'mortality_rate': len(bad_disasm) / len(failures) * 100
        })

    # Pattern 2: byte_by_byte
    byte_battle = [f for f in failures if 'byte_by_byte' in f['problems_encountered'] or 'byte_battle' in f['problems_encountered']]
    if byte_battle:
        patterns.append({
            'name': 'DEATH_BY_BYTES',
            'description': f'{len(byte_battle)} échecs après bataille de bytes',
            'rule': 'Si bataille de bytes commence, ABANDONNER immédiatement',
            'mortality_rate': len(byte_battle) / len(failures) * 100 if failures else 0
        })

    # Pattern 3: Log très long
    long_log_failures = [f for f in failures if f['log_length'] > 5000]
    if long_log_failures:
        patterns.append({
            'name': 'DEATH_BY_OVERTHINKING',
            'description': f'{len(long_log_failures)} échecs avec log > 5000 chars',
            'rule': 'Timeout à 60s ou 3000 chars de réflexion',
            'avg_log_length': sum(f['log_length'] for f in long_log_failures) / len(long_log_failures)
        })

    # Pattern 4: Trop de problèmes
    multi_problem = [f for f in failures if len(f['problems_encountered']) >= 3]
    if multi_problem:
        patterns.append({
            'name': 'DEATH_BY_ACCUMULATION',
            'description': f'{len(multi_problem)} échecs avec 3+ problèmes',
            'rule': 'Après 2 problèmes, ABANDONNER le noeud',
            'avg_problems': sum(len(f['problems_encountered']) for f in multi_problem) / len(multi_problem)
        })

    return patterns

def generate_lots_for_claude(analyses: List[Dict], lot_size: int = 30) -> List[Dict]:
    """Génère des lots pour analyse Claude détaillée."""

    # Sélectionner les cas les plus intéressants
    interesting_cases = []

    # Tous les succès
    successes = [a for a in analyses if a['success']]
    interesting_cases.extend(successes)

    # Échecs avec insights
    failures_with_insights = [a for a in analyses if not a['success'] and len(a['key_insights']) > 0]
    interesting_cases.extend(failures_with_insights[:50])

    # Cas nightmare
    nightmares = [a for a in analyses if a['estimated_complexity'] == 'nightmare'][:20]
    interesting_cases.extend(nightmares)

    # Dédupliquer
    seen_addresses = set()
    unique_cases = []
    for case in interesting_cases:
        if case['address'] not in seen_addresses:
            seen_addresses.add(case['address'])
            unique_cases.append(case)

    # Créer les lots
    lots = []
    for i in range(0, len(unique_cases), lot_size):
        lot = unique_cases[i:i+lot_size]
        lots.append({
            'lot_number': len(lots) + 1,
            'size': len(lot),
            'cases': [{
                'address': c['address'],
                'type': c['node_type'],
                'success': c['success'],
                'complexity': c['estimated_complexity'],
                'problems': c['problems_encountered'],
                'solutions': c['solutions_applied'],
                'insights': c['key_insights'],
                'mistakes': c['mistakes_made'],
                'reasoning_sample': c['reasoning_steps'][:5]
            } for c in lot]
        })

    return lots

def extract_asm_templates(analyses: List[Dict]) -> List[Dict]:
    """Extrait les templates ASM des cas réussis."""

    templates = []

    # Pour chaque succès, extraire les patterns de commentaires
    successes = [a for a in analyses if a['success']]

    for s in successes:
        if s['key_insights']:
            templates.append({
                'address': s['address'],
                'type': s['node_type'],
                'insight_template': s['key_insights'][0] if s['key_insights'] else '',
                'tools_used': s['tools_used']
            })

    return templates

def main():
    print("=" * 80)
    print("PASS 2 : ANALYSE PROFONDE DES SUCCÈS ET ÉCHECS")
    print("=" * 80)
    print()

    # Charger les données
    print("📂 Chargement des données extraites...")
    knowledge = load_extracted_knowledge()
    analyses = knowledge['all_analyses']
    print(f"   ✓ {len(analyses)} analyses chargées")
    print()

    # Analyser les succès
    print("✅ Analyse des SUCCÈS...")
    success_analysis = analyze_successes(analyses)
    print(f"   ✓ {success_analysis['total_successes']} succès analysés")
    print()

    # Analyser les échecs
    print("❌ Analyse des ÉCHECS...")
    failure_analysis = analyze_failures(analyses)
    print(f"   ✓ {failure_analysis['total_failures']} échecs analysés")
    print()

    # Identifier les patterns en or
    print("🏆 Identification des GOLDEN PATTERNS...")
    successes = [a for a in analyses if a['success']]
    golden_patterns = identify_golden_patterns(successes)
    print(f"   ✓ {len(golden_patterns)} patterns identifiés")
    print()

    # Identifier les patterns mortels
    print("💀 Identification des DEATH PATTERNS...")
    failures = [a for a in analyses if not a['success']]
    death_patterns = identify_death_patterns(failures)
    print(f"   ✓ {len(death_patterns)} patterns identifiés")
    print()

    # Générer les lots pour Claude
    print("📦 Génération des lots pour analyse Claude...")
    lots = generate_lots_for_claude(analyses)
    print(f"   ✓ {len(lots)} lots générés")
    print()

    # Extraire les templates
    print("📝 Extraction des templates ASM...")
    templates = extract_asm_templates(analyses)
    print(f"   ✓ {len(templates)} templates extraits")
    print()

    # Sauvegarder
    deep_analysis = {
        'summary': {
            'total_analyses': len(analyses),
            'successes': success_analysis['total_successes'],
            'failures': failure_analysis['total_failures'],
            'success_rate': success_analysis['total_successes'] / len(analyses) * 100
        },
        'success_analysis': success_analysis,
        'failure_analysis': failure_analysis,
        'golden_patterns': golden_patterns,
        'death_patterns': death_patterns,
        'lots_for_claude': lots,
        'asm_templates': templates
    }

    output_file = 'scripts/deep_analysis.json'
    with open(output_file, 'w') as f:
        json.dump(deep_analysis, f, indent=2, ensure_ascii=False)
    print(f"💾 Sauvegardé: {output_file} ({os.path.getsize(output_file) / 1024:.1f} KB)")
    print()

    # Afficher le résumé
    print("=" * 80)
    print("RÉSUMÉ PASS 2")
    print("=" * 80)
    print()

    print("🏆 GOLDEN PATTERNS (ce qui MARCHE):")
    for p in golden_patterns:
        print(f"   [{p['name']}]")
        print(f"   {p['description']}")
        print(f"   → RÈGLE: {p['rule']}")
        print()

    print("💀 DEATH PATTERNS (ce qui TUE):")
    for p in death_patterns:
        print(f"   [{p['name']}]")
        print(f"   {p['description']}")
        print(f"   → RÈGLE: {p['rule']}")
        print()

    print("📊 SUCCÈS PAR TYPE:")
    for t, addrs in success_analysis['by_type'].items():
        print(f"   {t}: {len(addrs)} succès")

    print()
    print("📊 SUCCÈS PAR COMPLEXITÉ:")
    for c, addrs in success_analysis['by_complexity'].items():
        print(f"   {c}: {len(addrs)} succès")

    print()
    print("🔧 OUTILS DES SUCCÈS:")
    for tool, count in sorted(success_analysis['successful_tools'].items(), key=lambda x: -x[1])[:10]:
        print(f"   {tool}: {count}")

    print()
    print("💡 TOP SOLUTIONS:")
    for sol, count in sorted(success_analysis['successful_solutions'].items(), key=lambda x: -x[1])[:10]:
        print(f"   {sol}: {count}")

    print()
    print("❌ RAISONS D'ÉCHEC:")
    for reason, count in sorted(failure_analysis['by_reason'].items(), key=lambda x: -x[1])[:10]:
        print(f"   {reason}: {count}")

    print()
    print("🎯 ADRESSES RÉUSSIES (pour étude):")
    for addr_info in success_analysis['successful_addresses'][:10]:
        print(f"   {addr_info['address']} ({addr_info['type']}, {addr_info['complexity']})")

if __name__ == "__main__":
    main()
