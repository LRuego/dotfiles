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

## Key Features

### 🛠️ Quickshell: A Reactive Desktop Environment
Built with a custom QML-based shell for high-performance and deep system integration.
*   **"Peek" & "Focus" UX:** Holding `L_ALT` (via a custom `InputService`) expands the bar to reveal hidden modules (GPU, VRAM) and secondary metrics like temperatures.
*   **Dynamic UI Expansion:** Modules like `SystemResources` and `Volume` physically expand their width to reveal more info when hovered or in Peek Mode.
*   **Advanced Input Handling:** Bypassing Wayland limitations by reading `/dev/input` directly via `evtest`, enabling global Tap, Hold, and Double-tap gestures.

### 🎮 Gaming Mode Sync
*   **Automatic Trigger:** Detection of Feral GameMode (`gamemoded`) via `GamemodeService`.
*   **Environment Sync:** Automatically changing Hyprland border colors, group-bar colors, and Bar accent colors (Blue → Purple) when a game starts.

### 📡 Tailscale & Taildrop
*   **Peer Browser:** Custom QML menu listing peers, their OS (with icons), and "Last Seen" status.
*   **Taildrop Previews:** Integration with your Taildrop service to show image previews directly in notifications when receiving files.

## Structure

*   **Architectural Standard:** All Quickshell logic follows a strict "Pure Data Service" layer (raw data only) and a "Component Helper" layer (UI mapping), ensuring the system is modular and maintainable.
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
