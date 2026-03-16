# Hyprland Dotfiles (Tokyo Night)

Personal configuration files for my Arch Linux workstation.

## Overview

*   **OS:** Arch Linux
*   **WM:** Hyprland
*   **Terminal:** Ghostty + Zsh + Starship
*   **Editor:** Neovim (LazyVim-based custom config)
*   **Launcher:** Rofi
*   **Shell/UI:** Quickshell (Bar, Menus, Notifications)
*   **Theme:** Customized [Tokyo Night](https://github.com/folke/tokyonight.nvim)

## Structure

*   `hypr/`: Hyprland configuration, keybindings, and custom scripts.
*   `quickshell/`: Programmable QML environment handling the status bar, system menus, tooltips, and notification daemon.
*   `rofi/`: Application launcher and clipboard manager themes.
*   `nvim/`: Neovim Lua configuration.
*   `ghostty/`: Terminal emulator config.
*   `.zshrc`: Shell configuration.
*   `yazi/`: TUI file manager config.
*   `zathura/`: PDF viewer config.

## Acknowledgements

*   **Privacy Dots:** The recording detection logic in Quickshell is powered by [privacy-dots](https://github.com/alvaniss/privacy-dots), originally by alibaghernejad.
* **Taildrop:** A systemd service that automatically receives files via Tailscale and triggers notifications with image previews.
*   **Tokyo Night:** Theme palette by [folke](https://github.com/folke/tokyonight.nvim).
