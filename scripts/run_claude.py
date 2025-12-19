#!/usr/bin/env python3
"""
Script pour exécuter Claude CLI avec un fichier de rapport et streamer la sortie JSON.
Usage: python run_claude.py <fichier_rapport>
"""

import subprocess
import sys
import os
import json


def run_claude_with_file(file_path: str) -> int:
    """
    Exécute Claude CLI avec le fichier spécifié et streame uniquement le texte.

    Args:
        file_path: Chemin vers le fichier de rapport à traiter

    Returns:
        Code de retour du processus
    """
    if not os.path.exists(file_path):
        print(f"Erreur: Le fichier '{file_path}' n'existe pas.", file=sys.stderr)
        return 1

    # Construction de la commande
    prompt = f"fais ce qui est écrit dans @{file_path}"
    cmd = [
        "claude",
        "--verbose",
        "--output-format", "stream-json",
        "-p", prompt,
        "--dangerously-skip-permissions"
    ]

    print(f"Exécution: {' '.join(cmd)}")
    print("-" * 60)

    # Exécution avec streaming de la sortie
    process = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1  # Line buffered
    )

    # Lecture et affichage du texte uniquement
    try:
        for line in process.stdout:
            line = line.strip()
            if not line:
                continue

            try:
                msg = json.loads(line)
                msg_type = msg.get("type", "")

                # Extraire le texte des messages assistant
                if msg_type == "assistant":
                    content = msg.get("message", {}).get("content", [])
                    for block in content:
                        if block.get("type") == "text":
                            text = block.get("text", "")
                            if text:
                                print(text, flush=True)

                # Extraire le texte du résultat final
                elif msg_type == "result":
                    result_text = msg.get("result", "")
                    if result_text:
                        print(result_text, flush=True)

            except json.JSONDecodeError:
                # Ligne non-JSON, ignorer
                pass

    except KeyboardInterrupt:
        print("\n\nInterruption utilisateur (Ctrl+C)")
        process.terminate()
        process.wait()
        return 130

    # Attendre la fin du processus
    return_code = process.wait()

    print("-" * 60)
    print(f"Terminé avec code de retour: {return_code}")

    return return_code


def main():
    if len(sys.argv) < 2:
        print("Usage: python run_claude.py <fichier_rapport>")
        print("Exemple: python run_claude.py logs/report_00000.md")
        sys.exit(1)

    file_path = sys.argv[1]
    sys.exit(run_claude_with_file(file_path))


if __name__ == "__main__":
    main()
