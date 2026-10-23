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
      echo "Uso: ./install.sh [--force] [--with-hooks] [--uninstall]"
      echo "  --force       Sobrescribe ~/.agents existente con las plantillas del repo (crea respaldo .bak.<timestamp>)."
      echo "                ADVERTENCIA: Si tienes contexto privado en ~/.agents/rules, se moverá al respaldo .bak."
      echo "  --with-hooks  Habilita el hook PostToolUse (ruff format / prettier) en el plugin global."
      echo "  --uninstall   Elimina el plugin global de ~/.gemini/config/plugins/hybrid-orchestration"
      echo "                (conserva ~/.agents, ~/.local/bin/asesor y respaldos en $BACKUP_DIR)."
      exit 0
      ;;
    *)
      echo "Error: Argumento desconocido '$arg'. Usa --help para ver las opciones disponibles." >&2
      exit 1
      ;;
  esac
done

if [ "$UNINSTALL" = true ]; then
  rm -rf "$PLUGIN_DIR"
  echo "[OK] Plugin global eliminado de $PLUGIN_DIR (se conservaron $AGENTS_DIR, $BIN_DIR/asesor y respaldos)."
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
    echo "[BACKUP] Elemento previo $dst respaldado en $bak"
  fi
  ln -sfn "$src" "$dst"
}

# 1. Instalar ~/.agents sin pisar configuraciones existentes a menos que se pase --force
if [ -d "$AGENTS_DIR/rules" ] && [ "$FORCE" = false ]; then
  echo "[INFO] Se detectó configuración existente en $AGENTS_DIR/rules (se conserva intacta; usa --force para reemplazar con respaldo)."
else
  if [ -d "$AGENTS_DIR" ]; then
    BAK="${AGENTS_DIR}.bak.$(date +%s)"
    cp -a "$AGENTS_DIR" "$BAK"
    echo "[BACKUP] Respaldo creado en $BAK"
  fi
  mkdir -p "$AGENTS_DIR/rules" "$AGENTS_DIR/skills/hybrid-swarm" "$AGENTS_DIR/workflows"
  cp -f "$REPO_DIR/rules/"*.md "$AGENTS_DIR/rules/"
  cp -f "$REPO_DIR/skills/hybrid-swarm/SKILL.md" "$AGENTS_DIR/skills/hybrid-swarm/SKILL.md"
  cp -f "$REPO_DIR/workflows/"*.md "$AGENTS_DIR/workflows/"
  cp -f "$REPO_DIR/hooks.json" "$AGENTS_DIR/hooks.json"
  echo "[OK] Plantillas instaladas en $AGENTS_DIR"
fi

# Asegurar que workflows y hooks.json existan en ~/.agents si faltaban
mkdir -p "$AGENTS_DIR/workflows"
for wf in "$REPO_DIR/workflows/"*.md; do
  base_wf="$(basename "$wf")"
  [ -f "$AGENTS_DIR/workflows/$base_wf" ] || cp -f "$wf" "$AGENTS_DIR/workflows/$base_wf"
done
[ -f "$AGENTS_DIR/hooks.json" ] || cp -f "$REPO_DIR/hooks.json" "$AGENTS_DIR/hooks.json"

# 2. Registrar el plugin global en ~/.gemini/config/plugins/hybrid-orchestration
cp -f "$REPO_DIR/plugin.json" "$PLUGIN_DIR/plugin.json"
safe_symlink "$AGENTS_DIR/rules" "$PLUGIN_DIR/rules"
safe_symlink "$AGENTS_DIR/skills" "$PLUGIN_DIR/skills"
safe_symlink "$AGENTS_DIR/workflows" "$PLUGIN_DIR/workflows"
if [ "$WITH_HOOKS" = true ]; then
  safe_symlink "$AGENTS_DIR/hooks.json" "$PLUGIN_DIR/hooks.json"
else
  rm -f "$PLUGIN_DIR/hooks.json"
fi

# 3. Instalar binario asesor sino existe o si se usa --force
if [ ! -f "$BIN_DIR/asesor" ] || [ "$FORCE" = true ]; then
  cp -f "$REPO_DIR/bin/asesor" "$BIN_DIR/asesor"
  chmod +x "$BIN_DIR/asesor"
  echo "[OK] CLI asesor instalado en $BIN_DIR/asesor"
else
  echo "[INFO] $BIN_DIR/asesor ya existe (conservado; usa --force para actualizarlo)."
fi

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) echo "[WARN] $BIN_DIR no está en tu PATH. Añade 'export PATH=\"\$HOME/.local/bin:\$PATH\"' a tu shell rc." ;;
esac

echo "[OK] Plugin global hybrid-orchestration activo en $PLUGIN_DIR"
