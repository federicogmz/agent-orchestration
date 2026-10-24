#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="${HOME}/.agents"
PLUGIN_DIR="${HOME}/.gemini/config/plugins/hybrid-orchestration"
BACKUP_DIR="${HOME}/.gemini/config/plugins/.hybrid-orchestration-backups"
BIN_DIR="${HOME}/.local/bin"

FORCE=false
WITH_HOOKS=false
UNINSTALL=false

for arg in "$@"; do
  case "$arg" in
    --force) FORCE=true ;;
    --with-hooks) WITH_HOOKS=true ;;
    --uninstall) UNINSTALL=true ;;
    -h|--help)
      echo "Usage: ./install.sh [--force] [--with-hooks] [--uninstall]"
      echo "  --force       Overwrite existing ~/.agents with repository templates (saves a full copy to .bak.<timestamp> first)."
      echo "                WARNING: Any private project context in ~/.agents/rules will be overwritten; restore SECTION 1 from the .bak copy afterwards."
      echo "  --with-hooks  Enable the PostToolUse auto-formatting hook (ruff format / prettier) in the global plugin."
      echo "  --uninstall   Remove the global plugin from ~/.gemini/config/plugins/hybrid-orchestration"
      echo "                (preserves ~/.agents, ~/.local/bin/asesor, and backups in $BACKUP_DIR)."
      exit 0
      ;;
    *)
      echo "Error: Unknown argument '$arg'. Use --help to see available options." >&2
      exit 1
      ;;
  esac
done

if [ "$UNINSTALL" = true ]; then
  rm -rf "$PLUGIN_DIR"
  echo "[OK] Global plugin removed from $PLUGIN_DIR (preserved $AGENTS_DIR, $BIN_DIR/asesor, and backups)."
  exit 0
fi

mkdir -p "$BIN_DIR" "$PLUGIN_DIR"

safe_symlink() {
  local src="$1"
  local dst="$2"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mkdir -p "$BACKUP_DIR"
    local bak="${BACKUP_DIR}/$(basename "$dst").bak.$(date +%s)"
    mv "$dst" "$bak"
    echo "[BACKUP] Existing item $dst backed up to $bak"
  fi
  ln -sfn "$src" "$dst"
}

# 1. Install ~/.agents without overwriting existing configuration unless --force is passed
if [ -d "$AGENTS_DIR/rules" ] && [ "$FORCE" = false ]; then
  echo "[INFO] Existing configuration detected in $AGENTS_DIR/rules (kept intact; pass --force to replace with backup)."
else
  if [ -d "$AGENTS_DIR" ]; then
    BAK="${AGENTS_DIR}.bak.$(date +%s)"
    cp -a "$AGENTS_DIR" "$BAK"
    echo "[BACKUP] Backup created at $BAK"
  fi
  mkdir -p "$AGENTS_DIR/rules" "$AGENTS_DIR/skills/hybrid-swarm" "$AGENTS_DIR/workflows"
  cp -f "$REPO_DIR/rules/"*.md "$AGENTS_DIR/rules/"
  cp -f "$REPO_DIR/skills/hybrid-swarm/SKILL.md" "$AGENTS_DIR/skills/hybrid-swarm/SKILL.md"
  cp -f "$REPO_DIR/workflows/"*.md "$AGENTS_DIR/workflows/"
  cp -f "$REPO_DIR/hooks.json" "$AGENTS_DIR/hooks.json"
  echo "[OK] Templates installed in $AGENTS_DIR"
fi

# Ensure workflows and hooks.json exist in ~/.agents if missing
mkdir -p "$AGENTS_DIR/workflows"
for wf in "$REPO_DIR/workflows/"*.md; do
  base_wf="$(basename "$wf")"
  [ -f "$AGENTS_DIR/workflows/$base_wf" ] || cp -f "$wf" "$AGENTS_DIR/workflows/$base_wf"
done
[ -f "$AGENTS_DIR/hooks.json" ] || cp -f "$REPO_DIR/hooks.json" "$AGENTS_DIR/hooks.json"

# 2. Register the global plugin in ~/.gemini/config/plugins/hybrid-orchestration
cp -f "$REPO_DIR/plugin.json" "$PLUGIN_DIR/plugin.json"
safe_symlink "$AGENTS_DIR/rules" "$PLUGIN_DIR/rules"
safe_symlink "$AGENTS_DIR/skills" "$PLUGIN_DIR/skills"
safe_symlink "$AGENTS_DIR/workflows" "$PLUGIN_DIR/workflows"
if [ "$WITH_HOOKS" = true ]; then
  safe_symlink "$AGENTS_DIR/hooks.json" "$PLUGIN_DIR/hooks.json"
else
  rm -f "$PLUGIN_DIR/hooks.json"
fi

# 3. Install asesor CLI binary if missing, if --force is passed, or warn if out of sync
if [ ! -f "$BIN_DIR/asesor" ] || [ "$FORCE" = true ]; then
  cp -f "$REPO_DIR/bin/asesor" "$BIN_DIR/asesor"
  chmod +x "$BIN_DIR/asesor"
  echo "[OK] CLI binary 'asesor' installed at $BIN_DIR/asesor"
elif ! cmp -s "$REPO_DIR/bin/asesor" "$BIN_DIR/asesor"; then
  echo "[WARN] $BIN_DIR/asesor differs from repository version (run './install.sh --force' or 'cp -f bin/asesor $BIN_DIR/asesor' to update)."
else
  echo "[INFO] $BIN_DIR/asesor is up to date."
fi

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) echo "[WARN] $BIN_DIR is not in your PATH. Add 'export PATH=\"\$HOME/.local/bin:\$PATH\"' to your shell rc." ;;
esac

echo "[OK] Global plugin 'hybrid-orchestration' is active in $PLUGIN_DIR"
