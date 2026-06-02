#!/bin/bash

# Function to detect package manager
detect_package_manager() {
    if command -v apt &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v zypper &> /dev/null; then
        echo "zypper"
    elif command -v pkg &> /dev/null; then
        echo "pkg"
    fi
}

# Ask user for environment type
read -p "Are you installing on a server (tui) or a graphical environment (gui)? (tui/gui): " ENV_TYPE
ENV_TYPE=$(echo "$ENV_TYPE" | tr '[:upper:]' '[:lower:]')

if [[ "$ENV_TYPE" != "tui" && "$ENV_TYPE" != "gui" ]]; then
    echo "Invalid environment type. Please enter 'tui' or 'gui'."
    exit 1
fi

echo "Environment type selected: $ENV_TYPE"

# Detect distribution and package manager
PACKAGE_MANAGER=$(detect_package_manager)

if [[ "$PACKAGE_MANAGER" == "unknown" ]]; then
    echo "Could not detect a known package manager. Please install dependencies manually."
else
    echo "Detected package manager: $PACKAGE_MANAGER"
fi

echo "Starting installation..."

# Function to install packages
install_packages() {
    local packages=("$@")
    echo "Installing packages: ${packages[*]}"
    case "$PACKAGE_MANAGER" in
        "apt")
            sudo apt update
            sudo apt install -y "${packages[@]}"
            ;;
        "dnf")
            sudo dnf install -y "${packages[@]}"
            ;;
        "pacman")
            sudo pacman -Sy --noconfirm "${packages[@]}"
            ;;
        "zypper")
            sudo zypper install -y "${packages[@]}"
            ;;
        "pkg")
            pkg update
            pkg install -y "${packages[@]}"
            ;;
        *)
            echo "Unknown package manager. Please install packages manually: ${packages[*]}"
            ;;
    esac
}

# Ask user for environment type
read -p "Are you installing on a server (tui) or a graphical environment (gui)? (tui/gui): " ENV_TYPE
ENV_TYPE=$(echo "$ENV_TYPE" | tr '[:upper:]' '[:lower:]')

if [[ "$ENV_TYPE" != "tui" && "$ENV_TYPE" != "gui" ]]; then
    echo "Invalid environment type. Please enter 'tui' or 'gui'."
    exit 1
fi

echo "Environment type selected: $ENV_TYPE"

# Detect distribution and package manager
PACKAGE_MANAGER=$(detect_package_manager)

if [[ "$PACKAGE_MANAGER" == "unknown" ]]; then
    echo "Could not detect a known package manager. Please install dependencies manually."
else
    echo "Detected package manager: $PACKAGE_MANAGER"
fi

echo "Starting installation..."

# Define common applications and dotfiles
COMMON_APPS=("zsh" "btop" "fastfetch")
COMMON_DOTFILES=("nvim" "fastfetch" ".zshrc")

# TUI-specific installations and configurations
if [[ "$ENV_TYPE" == "tui" ]]; then
    echo "Setting up for TUI environment..."
    TUI_APPS=("${COMMON_APPS[@]}")
    TUI_DOTFILES=("${COMMON_DOTFILES[@]}")

    install_packages "${TUI_APPS[@]}"

    echo "Symlinking TUI dotfiles..."
    for dotfile in "${TUI_DOTFILES[@]}"; do
        if [[ "$dotfile" == ".zshrc" ]]; then
            ln -sf "$(pwd)/$dotfile" "$HOME/$dotfile"
        else
            # For dotfiles that are directories, ensure the target is ~/.config/
            ln -sf "$(pwd)/$dotfile" "$HOME/.config/$dotfile"
        fi
        echo "Symlinked $dotfile"
    done

    # Clean up GUI-specific dotfiles to avoid clutter
    GUI_DOTFILES_TO_CLEAN=("i3" "keyd" "kitty" "picom" "polybar" "rofi")

    echo "Cleaning up GUI-specific dotfiles in TUI environment..."
    for dotfile_dir in "${GUI_DOTFILES_TO_CLEAN[@]}"; do
        if [[ -e "$HOME/.config/$dotfile_dir" ]]; then
            echo "Removing $HOME/.config/$dotfile_dir"
            rm -rf "$HOME/.config/$dotfile_dir"
        fi
    done

fi

# GUI-specific installations and configurations
if [[ "$ENV_TYPE" == "gui" ]]; then
    echo "Setting up for GUI environment..."
    GUI_APPS=("${COMMON_APPS[@]}" "kitty" "i3" "keyd" "picom" "polybar" "rofi")
    GUI_DOTFILES=("${COMMON_DOTFILES[@]}" "i3" "keyd" "kitty" "picom" "polybar" "rofi")

    install_packages "${GUI_APPS[@]}"

    echo "Symlinking GUI dotfiles..."
    for dotfile in "${GUI_DOTFILES[@]}"; do
        if [[ "$dotfile" == ".zshrc" ]]; then
            ln -sf "$(pwd)/$dotfile" "$HOME/$dotfile"
        else
            # For dotfiles that are directories, ensure the target is ~/.config/
            ln -sf "$(pwd)/$dotfile" "$HOME/.config/$dotfile"
        fi
        echo "Symlinked $dotfile"
    done
fi

echo "Installation script finished."
