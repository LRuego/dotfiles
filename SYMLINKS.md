# Symlink Map

Repo paths (relative to this directory) and where they are linked on the system. Nothing is installed automatically; create these by hand with `ln -s`.

## Whole-directory links (`~/.config/<name>` -> `<name>/`)

| Repo path | Link |
|---|---|
| `ghostty/` | `~/.config/ghostty` |
| `hypr/` | `~/.config/hypr` |
| `lazygit/` | `~/.config/lazygit` |
| `nvim/` | `~/.config/nvim` |
| `quickshell/` | `~/.config/quickshell` |
| `rofi/` | `~/.config/rofi` |
| `satty/` | `~/.config/satty` |
| `starship/` | `~/.config/starship` |
| `xdg-desktop-portal/` | `~/.config/xdg-desktop-portal` |
| `xdg-desktop-portal-termfilechooser/` | `~/.config/xdg-desktop-portal-termfilechooser` |
| `yazi/` | `~/.config/yazi` |

## Per-file links

| Repo path | Link |
|---|---|
| `.zshrc` | `~/.zshrc` |
| `zathura/zathurarc` | `~/.config/zathura/zathurarc` |
| `zathura/atheme` | `~/.config/zathura/atheme` |
| `eza/theme.yml` | `~/.config/eza/theme.yml` |
| `systemd/user/bt-agent.service` | `~/.config/systemd/user/bt-agent.service` |
| `systemd/user/taildrop.service` | `~/.config/systemd/user/taildrop.service` |
| `systemd/user/the-tower.service` | `~/.config/systemd/user/the-tower.service` |

Enabling a unit (`systemctl --user enable <unit>`) creates its own links in `~/.config/systemd/user/*.wants/`. Those are generated state and are not tracked.

## Not tracked

Live files in `~/.config` and `~/.local` with no copy in this repo: `mimeapps.list`, `user-dirs.dirs`, `autostart/`, `~/.local/share/applications/`, and `systemd/user/adb-emulator-bridge.service`.
