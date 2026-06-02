# linux_dotfiles

My personal dotfiles for both TUI (terminal/server) and GUI environments.

## Quick Install

Clone this repository directly into your `~/.config` directory, and run the installation script:

```bash
git clone https://github.com/GiftKNdlovu/linux_dotfiles.git ~/.config
cd ~/.config
./install_dotfiles.sh
```

## How It Works

The script detects your Linux package manager (`apt`, `dnf`, `pacman`, `zypper`, or Termux `pkg`) and prompts you to select either a **TUI** or **GUI** setup:

### 1. Server / TUI
- **Installs:** `zsh`, `btop`, `fastfetch`
- **Configures:** `nvim`, `fastfetch`, `.zshrc` (symlinked)
- **Cleans up:** Removes graphical configuration files (`i3`, `keyd`, `kitty`, `picom`, `polybar`, `rofi`) to keep the server clutter-free.

### 2. Desktop / GUI
- **Installs:** TUI packages + `kitty`, `i3`, `keyd`, `picom`, `polybar`, `rofi`
- **Configures:** All dotfiles (TUI + graphical) symlinked into place.
