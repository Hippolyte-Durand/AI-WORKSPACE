#!/usr/bin/env python3
"""
audit.py — analyse mécanique de cohérence interne des fichiers de code.
Signal de danger : mélange de responsabilités (pas taille seule).

Usage:
  python3 audit.py <path>          # fichier ou dossier récursif
  python3 audit.py <path> --json   # output JSON brut
"""

import sys
import json
import re
from pathlib import Path

SUPPORTED = {".ts", ".js", ".mjs", ".py"}
WARNING_THRESHOLD = 0.4
DANGER_THRESHOLD = 0.7
SST_IMPORT_COUNT = 3  # importé par >= N fichiers → sst_candidate


def collect_files(root: Path) -> list[Path]:
    if root.is_file():
        return [root] if root.suffix in SUPPORTED else []
    files = []
    for f in root.rglob("*"):
        if f.suffix in SUPPORTED and not any(p in f.parts for p in ("node_modules", "__pycache__", ".git", "dist", "out")):
            files.append(f)
    return sorted(files)


def parse_imports_ts(source: str) -> list[str]:
    """Extract import paths from TypeScript/JavaScript."""
    patterns = [
        r'import\s+.*?from\s+[\'"]([^\'"]+)[\'"]',
        r'require\s*\(\s*[\'"]([^\'"]+)[\'"]\s*\)',
        r'import\s*\(\s*[\'"]([^\'"]+)[\'"]\s*\)',
    ]
    paths = []
    for pat in patterns:
        paths.extend(re.findall(pat, source))
    return paths


def parse_imports_py(source: str) -> list[str]:
    """Extract import paths from Python."""
    patterns = [
        r'^\s*from\s+([\w.]+)\s+import',
        r'^\s*import\s+([\w., ]+)',
    ]
    paths = []
    for pat in patterns:
        for m in re.finditer(pat, source, re.MULTILINE):
            for name in m.group(1).split(","):
                paths.append(name.strip().split(".")[0])
    return paths


def import_domain(path: str) -> str:
    """Normalize import path to domain prefix."""
    if path.startswith("."):
        parts = Path(path).parts
        # Take first two path components for local imports
        if len(parts) >= 2:
            return "/".join(parts[:2])
        return parts[0] if parts else path
    # External: take package name (handle @scope/pkg)
    if path.startswith("@"):
        parts = path.split("/")
        return "/".join(parts[:2])
    return path.split("/")[0]


def top_level_decls(source: str, is_py: bool) -> list[str]:
    pat = r'^(?:def|class)\s+(\w+)' if is_py else r'^(?:export\s+)?(?:function|class|const|let|var|interface|type|enum)\s+(\w+)'
    return re.findall(pat, source, re.MULTILINE)


def internal_call_density(decls: list[str], source: str) -> float:
    """Ratio of declarations that are called by other declarations in the same file."""
    if len(decls) < 2:
        return 1.0
    called = sum(
        1 for d in decls
        if len(re.findall(rf'\b{re.escape(d)}\s*[(\[]', source)) > 1  # >1 = called elsewhere in file
    )
    return called / len(decls)


def analyze_file(path: Path, all_files: list[Path]) -> dict:
    try:
        source = path.read_text(encoding="utf-8", errors="replace")
    except Exception:
        return None

    lines = len(source.splitlines())
    is_py = path.suffix == ".py"

    raw_imports = parse_imports_py(source) if is_py else parse_imports_ts(source)
    domains = list(dict.fromkeys(import_domain(i) for i in raw_imports))  # unique, ordered

    decls = top_level_decls(source, is_py)
    density = internal_call_density(decls, source)

    # SST: count how many sibling files import this file
    stem = path.stem
    import_count = 0
    for other in all_files:
        if other == path:
            continue
        try:
            other_src = other.read_text(encoding="utf-8", errors="replace")
            if re.search(rf'[\'"].*{re.escape(stem)}[\'"]', other_src):
                import_count += 1
        except Exception:
            pass

    # Score: line weight + domain diversity + fragmentation
    line_score = min(lines / 250, 1.0) * 0.4
    domain_score = min(len(domains) / 3, 1.0) * 0.4
    frag_score = (1.0 - density) * 0.2
    score = round(line_score + domain_score + frag_score, 3)

    if import_count >= SST_IMPORT_COUNT and density > 0.4:
        flag = "sst"
    elif score >= DANGER_THRESHOLD:
        flag = "danger"
    elif score >= WARNING_THRESHOLD:
        flag = "warning"
    else:
        flag = "ok"

    return {
        "file": str(path),
        "lines": lines,
        "import_domains": domains,
        "top_level_decls": len(decls),
        "internal_call_density": round(density, 3),
        "imported_by": import_count,
        "score": score,
        "flag": flag,
    }


def render_table(results: list[dict]) -> None:
    ICONS = {"danger": "🔴", "warning": "🟡", "ok": "✅", "sst": "🔷"}

    sorted_r = sorted(results, key=lambda x: -x["score"])
    col_file = max(len(r["file"]) for r in results) + 2
    col_file = max(col_file, 10)

    header = f"{'Fichier':<{col_file}} {'Lignes':>6}  {'Domaines':>8}  {'Score':>5}  {'Flag'}"
    print(header)
    print("-" * len(header))

    for r in sorted_r:
        icon = ICONS.get(r["flag"], "?")
        label = "sst (SST)" if r["flag"] == "sst" else r["flag"]
        imported = f" ({r['imported_by']} imports)" if r["flag"] == "sst" else ""
        print(f"{r['file']:<{col_file}} {r['lines']:>6}  {len(r['import_domains']):>8}  {r['score']:>5.2f}  {icon} {label}{imported}")

    print()
    dangers = [r for r in sorted_r if r["flag"] == "danger"]
    warnings = [r for r in sorted_r if r["flag"] == "warning"]
    if dangers:
        print("Priorité haute :")
        for r in dangers:
            print(f"  → {r['file']} ({r['lines']} lignes, {len(r['import_domains'])} domaines import)")
    if warnings:
        print("À surveiller :")
        for r in warnings:
            print(f"  → {r['file']}")


def main():
    args = sys.argv[1:]
    json_mode = "--json" in args
    args = [a for a in args if not a.startswith("--")]

    if not args:
        print("Usage: audit.py <path> [--json|--table]", file=sys.stderr)
        sys.exit(1)

    root = Path(args[0])
    if not root.exists():
        print(f"Chemin introuvable : {root}", file=sys.stderr)
        sys.exit(1)

    all_files = collect_files(root)
    if not all_files:
        print("Aucun fichier supporté trouvé.", file=sys.stderr)
        sys.exit(1)

    results = []
    for f in all_files:
        r = analyze_file(f, all_files)
        if r:
            results.append(r)

    if json_mode:
        print(json.dumps(results, indent=2, ensure_ascii=False))
    else:
        render_table(results)


if __name__ == "__main__":
    main()
