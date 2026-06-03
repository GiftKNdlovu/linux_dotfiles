# linux_dotfiles

Personal dotfiles for Linux — TUI (server) or GUI (desktop), picked at install time.

## Use

```bash
git clone https://github.com/GiftKNdlovu/linux_dotfiles.git ~/.config
cd ~/.config
./install_dotfiles.sh
```

A menu asks **tui** or **gui**. The script detects your package manager (`apt`, `dnf`, `pacman`, `zypper`, or Termux's `pkg`) and handles the rest.

## What goes where

### TUI (terminal/server)
- **Installs:** zsh, btop, fastfetch
- **Links:** `.zshrc`, `nvim/`, `fastfetch/`
- **Cleans up:** Removes any leftover GUI configs (i3, kitty, picom, polybar, rofi, keyd)

### GUI (desktop)
- **Installs:** everything above + kitty, i3, picom, polybar, rofi
- **Links:** all dotfiles including GUI ones

## Notes

- Existing configs get backed up with a `.bak` suffix before being replaced.
- Only installs packages that aren't already on the system.
- Run from the repo root — the script figures out its own location.