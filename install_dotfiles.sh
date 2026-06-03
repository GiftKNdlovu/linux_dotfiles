#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────
# linux_dotfiles — install + bootstrap script
# ──────────────────────────────────────────────

RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; NC='\033[0m'
log()  { echo -e "${CYAN}==>${NC} $1"; }
ok()   { echo -e "${GREEN}  ✓${NC} $1"; }
warn() { echo -e "${YELLOW}  ⚠${NC} $1"; }
err()  { echo -e "${RED}  ✗${NC} $1"; }

# ── Detect package manager ────────────────────
detect_pm() {
    # Termux has apt but no sudo — check Termux first
    if [[ -n "${TERMUX_VERSION:-}" ]]; then echo "pkg"
    elif command -v apt &>/dev/null; then echo "apt"
    elif command -v dnf &>/dev/null; then echo "dnf"
    elif command -v pacman &>/dev/null; then echo "pacman"
    elif command -v zypper &>/dev/null; then echo "zypper"
    elif command -v pkg &>/dev/null; then echo "pkg"
    else echo "unknown"; fi
}

PM=$(detect_pm)
[[ "$PM" == "unknown" ]] && { err "No supported package manager found."; exit 1; }
ok "Detected package manager: $PM"

# ── Install packages ──────────────────────────
install_pkgs() {
    local pkgs=("$@")
    local missing=()
    for pkg in "${pkgs[@]}"; do
        if ! command -v "$pkg" &>/dev/null; then
            missing+=("$pkg")
        fi
    done
    [[ ${#missing[@]} -eq 0 ]] && return 0

    log "Installing: ${missing[*]}"
    local failed=false
    case "$PM" in
        apt)    sudo apt update || warn "apt update failed — continuing"
                sudo apt install -y "${missing[@]}" || failed=true ;;
        dnf)    sudo dnf install -y "${missing[@]}" || failed=true ;;
        pacman) sudo pacman -Sy --noconfirm "${missing[@]}" || failed=true ;;
        zypper) sudo zypper install -y "${missing[@]}" || failed=true ;;
        pkg)    pkg update || warn "pkg update failed — continuing"
                pkg install -y "${missing[@]}" || failed=true ;;
    esac
    if $failed; then
        warn "Some packages failed to install — continuing anyway"
    else
        ok "Installation complete."
    fi
}

# ── Symlink a dotfile ─────────────────────────
link_dotfile() {
    local src="$1" dst="$2"
    if [[ -e "$dst" || -L "$dst" ]]; then
        local current
        current=$(readlink "$dst" 2>/dev/null || echo "")
        if [[ "$current" == "$src" ]]; then
            ok "$dst already points here"
            return 0
        fi
        warn "Backing up $dst → $dst.bak"
        mv "$dst" "$dst.bak"
    fi
    ln -sf "$src" "$dst"
    ok "Linked $dst → $src"
}

# ── Prompt ────────────────────────────────────
echo ""
echo -e "${CYAN}┌─────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│      linux_dotfiles installer            │${NC}"
echo -e "${CYAN}└─────────────────────────────────────────┘${NC}"
echo ""

PS3="Select environment type (1/2): "
select ENV_TYPE in "tui   (server / terminal-only)" "gui   (desktop / graphical)"; do
    case "$REPLY" in
        1|tui|TUI)   ENV="tui"; break ;;
        2|gui|GUI)   ENV="gui"; break ;;
        *) echo "Invalid selection. Choose 1 (tui) or 2 (gui)." ;;
    esac
done

echo ""
log "Selected environment: ${ENV}"

# ── Define what belongs where ─────────────────
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$HOME/.config"

# Maps:  source (relative to repo) → target (absolute path)
# Only files/dirs actually committed to the repo.
declare -A ALL_DOTFILES
# .zshrc is handled separately with a prompt below
# ALL_DOTFILES[".zshrc"]="$HOME/.zshrc"
ALL_DOTFILES["kitty"]="$CONFIG_DIR/kitty"
ALL_DOTFILES["nvim"]="$CONFIG_DIR/nvim"
ALL_DOTFILES["fastfetch"]="$CONFIG_DIR/fastfetch"
ALL_DOTFILES["i3"]="$CONFIG_DIR/i3"
# keyd is handled separately with a prompt below (config goes to /etc/keyd/)
ALL_DOTFILES["picom"]="$CONFIG_DIR/picom"
ALL_DOTFILES["polybar"]="$CONFIG_DIR/polybar"
ALL_DOTFILES["rofi"]="$CONFIG_DIR/rofi"

# GUI-only dotfiles — these get skipped on TUI
GUI_ONLY=("i3" "kitty" "picom" "polybar" "rofi")

# TUI apps that get installed regardless
TUI_APPS=("zsh" "fastfetch")

# Extra GUI apps (keyd is not available in repos, config handled separately)
GUI_APPS=("kitty" "picom" "polybar" "rofi" "i3")

# ── Install packages ──────────────────────────
echo ""
log "Installing required packages..."
install_pkgs "${TUI_APPS[@]}"

if [[ "$ENV" == "gui" ]]; then
    install_pkgs "${GUI_APPS[@]}"
fi

# ── Create ~/.config if missing ───────────────
[[ -d "$CONFIG_DIR" ]] || mkdir -p "$CONFIG_DIR"

# ── Prompt for keyd config (both TUI and GUI) ──
if [[ -d "$REPO_DIR/keyd" ]]; then
    echo ""
    log "keyd config found in repo."
    echo "  keyd is a keyboard daemon — its config lives at /etc/keyd/default.conf"
    read -r -p "  Install keyd config to /etc/keyd/default.conf? (requires sudo) [y/N] " REPLY
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
        if [[ ! -d "/etc/keyd" ]]; then
            sudo mkdir -p /etc/keyd
        fi
        sudo cp "$REPO_DIR/keyd/default.conf" /etc/keyd/default.conf 2>/dev/null || \
        sudo cp "$REPO_DIR/keyd"/*.conf /etc/keyd/ 2>/dev/null || \
        warn "Could not copy keyd config — check the repo structure"
        ok "keyd config installed to /etc/keyd/"
    else
        ok "Skipping keyd config."
    fi
fi

# ── Prompt for .zshrc (user choice) ────────────
if [[ -e "$REPO_DIR/.zshrc" ]]; then
    echo ""
    log ".zshrc found in repo."
    if [[ -e "$HOME/.zshrc" || -L "$HOME/.zshrc" ]]; then
        echo "  An existing .zshrc is present in your home directory."
        read -r -p "  Overwrite with the repo version? [y/N] " REPLY
        if [[ "$REPLY" =~ ^[Yy]$ ]]; then
            link_dotfile "$REPO_DIR/.zshrc" "$HOME/.zshrc"
        else
            ok "Skipping .zshrc — keeping existing one."
        fi
    else
        read -r -p "  Link the repo's .zshrc to your home directory? [Y/n] " REPLY
        if [[ -z "$REPLY" || "$REPLY" =~ ^[Yy]$ ]]; then
            link_dotfile "$REPO_DIR/.zshrc" "$HOME/.zshrc"
        else
            ok "Skipping .zshrc."
        fi
    fi
fi

# ── Link dotfiles ─────────────────────────────
for src_rel in "${!ALL_DOTFILES[@]}"; do
    dst="${ALL_DOTFILES[$src_rel]}"
    src="$REPO_DIR/$src_rel"

    # Skip GUI-only dotfiles on TUI
    if [[ "$ENV" == "tui" ]]; then
        skip=false
        for gui_item in "${GUI_ONLY[@]}"; do
            if [[ "$gui_item" == "$src_rel" ]]; then
                skip=true
                break
            fi
        done
        $skip && continue
    fi

    if [[ ! -e "$src" ]]; then
        warn "$src_rel not found in repo — skipping"
        continue
    fi

    link_dotfile "$src" "$dst"
done

# ── Clean up GUI leftovers on TUI ─────────────
if [[ "$ENV" == "tui" ]]; then
    echo ""
    log "Cleaning up GUI configs from ~/.config..."
    for item in "${GUI_ONLY[@]}"; do
        target="$CONFIG_DIR/$item"
        if [[ -L "$target" || -e "$target" ]]; then
            warn "Removing leftover: $target"
            rm -rf "$target"
        fi
    done
fi

# ── Done ──────────────────────────────────────
echo ""
echo -e "${GREEN}┌─────────────────────────────────────────┐${NC}"
echo -e "${GREEN}│  Done! Log out / restart your shell.    │${NC}"
echo -e "${GREEN}└─────────────────────────────────────────┘${NC}"