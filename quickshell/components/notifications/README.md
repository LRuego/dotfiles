# Quickshell Notification System

A fully native notification system for Quickshell, replacing Dunst by claiming `org.freedesktop.Notifications` directly via D-Bus.

## Architecture

### Files
- `NotificationService.qml` — singleton service, D-Bus server, state management, persistence
- `NotificationCard.qml` — popup card component
- `NotificationPopup.qml` — popup window (layer shell, overlay)
- `NotificationCenter.qml` — history panel (layer shell, overlay, slide-in)
- `NotificationCenterCard.qml` — history card component
- `UpdateService.qml` — singleton service, polls for pending pacman/AUR updates
- `UpdatesSection.qml` — updates panel component, embedded at the bottom of NotificationCenter

### Data Flow
```
D-Bus → NotificationServer → NotificationService → popupList → NotificationPopup
                                                 → historyList → NotificationCenter
                                                 → notifications.json (persistence)

checkupdates ─┐
paru -Qua     ├─→ UpdateService → extraUpdates ─┐
pacman -Sl    ┘                 → aurUpdates    ├─→ UpdatesSection → NotificationCenter
                                → checking      ┘
```

## Features

### Popup System
- **App grouping** — multiple notifications from the same app stack into one card with a badge counter instead of flooding the screen
- **Hover pause** — hovering a card pauses its dismiss timer and resumes from where it left off when you leave
- **Image previews** — automatically detects and displays images from screenshots (Satty), file transfers (Taildrop), and `image-path` hints
- **Urgency styling** — critical notifications (`urgency = 2`) render with a red border via `Theme.urgent`
- **Left click** — invokes the notification's default action if one exists (e.g. opens the relevant app/conversation)
- **Right click** — dismisses the card immediately
- **Transient support** — notifications marked transient show as popups but are never stored in history
- **DND mode** — set `NotificationService.dnd = true` to suppress all popups while still logging to history

### Notification Center
- Right-side panel that slides in with a fade + spring animation
- Grouped by app — each app shows its latest message, summary, and a count badge
- Unread count badge in header — always live, reflects current history count
- Scrollable list for large history
- "Clear all" button wipes history and persists the change
- Right-click a card to dismiss it — no dismiss button
- Image preview with "Image deleted" fallback if the file no longer exists
- Frosted glass background via Hyprland `layerrule` blur
- Click-outside to close via `FocusService` / `HyprlandFocusGrab`
- Popups are instantly dismissed when the center opens

### Updates Section
- Pinned at the bottom of the notification center
- Polls `checkupdates` (official repos) and `paru -Qua` (AUR) on startup and every hour
- Manual refresh button triggers an immediate re-check
- Packages split into `[Official]` and `[AUR]` sections
- `[core]` packages flagged with an urgent dot indicator — these warrant extra caution
- Click any package to copy `paru -S <pkg>` to clipboard
- Partial upgrade warning footer always visible when expanded
- Collapse/expand toggle — state persists in memory across notification center opens/closes
- Shows last checked timestamp
- Scrollable package list capped at 200px, footer always visible below

### Persistence
- History is saved to `~/.local/share/quickshell/notifications.json`
- Restored on startup — unread count carries over across reboots
- Cleared when you use "Clear all" or dismiss individual entries
- Only stores primitives — structure is ready for `FileView` to extend

### Bar Module
- `Notifications.qml` in `components/bar/` — drop-in bar module
- Inbox icon dims when DND is active
- Red dot indicator appears when `unreadCount > 0`, clears when center is opened

## Configuration

All tunable values live at the top of `NotificationService.qml`:

| Property | Default | Description |
|---|---|---|
| `defaultTimeout` | `5000` | Popup duration in ms when app sends no expiry |
| `minRemaining` | `500` | Minimum time left after hover resume |
| `historyMax` | `100` | Max history entries before oldest is dropped |
| `dnd` | `false` | Suppress all popups when true |

All tunable values for updates live at the top of `UpdateService.qml`:

| Property | Default | Description |
|---|---|---|
| `panelCollapsed` | `true` | Initial collapsed state of the updates section |

## Dependencies

The updates section requires the following packages:
```bash
sudo pacman -S pacman-contrib   # provides checkupdates
paru                            # AUR helper, must be in PATH
```

## Hyprland Setup

Add to your `hyprland.conf` for blur support on the notification center:
```
layerrule = blur on, match:namespace notifications-center
layerrule = ignore_alpha 0.5, match:namespace notifications-center
```

## Roadmap

### Action Buttons
**Goal:** Display interactive buttons on popup cards for notifications that include actions (e.g. Spotify play/pause/skip, email reply/archive).

- Backend already implemented — actions stored in `_activeActions`, `invokeDefault()` handles invocation
- **UI needed:** `Repeater` below the text block in `NotificationCard.qml` generating a button per action, calling `NotificationService.invokeDefault()` with the action identifier

### DND Toggle
**Goal:** Toggle DND from within the notification center header rather than requiring an external binding.

- `NotificationService.dnd` property already exists
- **UI needed:** A toggle button in the `NotificationCenter.qml` header row, bound to `NotificationService.dnd`

### Updates — Run Upgrade
**Goal:** Button in the updates section footer to run `paru -Syu` directly from the notification center, launching in a terminal.

- `UpdateService.refresh()` already exists for post-upgrade re-check
- **UI needed:** A button in the footer row that runs `paru -Syu` in the user's preferred terminal# Quickshell Notification System

A fully native notification system for Quickshell, replacing Dunst by claiming `org.freedesktop.Notifications` directly via D-Bus.

## Architecture

### Files
- `NotificationService.qml` — singleton service, D-Bus server, state management, persistence
- `NotificationCard.qml` — popup card component
- `NotificationPopup.qml` — popup window (layer shell, overlay)
- `NotificationCenter.qml` — history panel (layer shell, overlay, slide-in)
- `NotificationCenterCard.qml` — history card component
- `UpdateService.qml` — singleton service, polls for pending pacman/AUR updates
- `UpdatesSection.qml` — updates panel component, embedded at the bottom of NotificationCenter

### Data Flow
```
D-Bus → NotificationServer → NotificationService → popupList → NotificationPopup
                                                 → historyList → NotificationCenter
                                                 → notifications.json (persistence)

checkupdates ─┐
paru -Qua     ├─→ UpdateService → extraUpdates ─┐
pacman -Sl    ┘                 → aurUpdates    ├─→ UpdatesSection → NotificationCenter
                                → checking      ┘
```

## Features

### Popup System
- **App grouping** — multiple notifications from the same app stack into one card with a badge counter instead of flooding the screen
- **Hover pause** — hovering a card pauses its dismiss timer and resumes from where it left off when you leave
- **Image previews** — automatically detects and displays images from screenshots (Satty), file transfers (Taildrop), and `image-path` hints
- **Urgency styling** — critical notifications (`urgency = 2`) render with a red border via `Theme.urgent`
- **Left click** — invokes the notification's default action if one exists (e.g. opens the relevant app/conversation)
- **Right click** — dismisses the card immediately
- **Transient support** — notifications marked transient show as popups but are never stored in history
- **DND mode** — set `NotificationService.dnd = true` to suppress all popups while still logging to history

### Notification Center
- Right-side panel that slides in with a fade + spring animation
- Grouped by app — each app shows its latest message, summary, and a count badge
- Unread count badge in header — always live, reflects current history count
- Scrollable list for large history
- "Clear all" button wipes history and persists the change
- Right-click a card to dismiss it — no dismiss button
- Image preview with "Image deleted" fallback if the file no longer exists
- Frosted glass background via Hyprland `layerrule` blur
- Click-outside to close via `FocusService` / `HyprlandFocusGrab`
- Popups are instantly dismissed when the center opens

### Updates Section
- Pinned at the bottom of the notification center
- Polls `checkupdates` (official repos) and `paru -Qua` (AUR) on startup and every hour
- Manual refresh button triggers an immediate re-check
- Packages split into `[Official]` and `[AUR]` sections
- `[core]` packages flagged with an urgent dot indicator — these warrant extra caution
- Click any package to copy `paru -S <pkg>` to clipboard
- Partial upgrade warning footer always visible when expanded
- Collapse/expand toggle — state persists in memory across notification center opens/closes
- Shows last checked timestamp
- Scrollable package list capped at 200px, footer always visible below

### Persistence
- History is saved to `~/.local/share/quickshell/notifications.json`
- Restored on startup — unread count carries over across reboots
- Cleared when you use "Clear all" or dismiss individual entries
- Only stores primitives — structure is ready for `FileView` to extend

### Bar Module
- `Notifications.qml` in `components/bar/` — drop-in bar module
- Inbox icon dims when DND is active
- Red dot indicator appears when `unreadCount > 0`, clears when center is opened

## Configuration

All tunable values live at the top of `NotificationService.qml`:

| Property | Default | Description |
|---|---|---|
| `defaultTimeout` | `5000` | Popup duration in ms when app sends no expiry |
| `minRemaining` | `500` | Minimum time left after hover resume |
| `historyMax` | `100` | Max history entries before oldest is dropped |
| `dnd` | `false` | Suppress all popups when true |

All tunable values for updates live at the top of `UpdateService.qml`:

| Property | Default | Description |
|---|---|---|
| `panelCollapsed` | `true` | Initial collapsed state of the updates section |

## Dependencies

The updates section requires the following packages:
```bash
sudo pacman -S pacman-contrib   # provides checkupdates
paru                            # AUR helper, must be in PATH
```

## Hyprland Setup

Add to your `hyprland.conf` for blur support on the notification center:
```
layerrule = blur on, match:namespace notifications-center
layerrule = ignore_alpha 0.5, match:namespace notifications-center
```

## Roadmap

### Action Buttons
**Goal:** Display interactive buttons on popup cards for notifications that include actions (e.g. Spotify play/pause/skip, email reply/archive).

- Backend already implemented — actions stored in `_activeActions`, `invokeDefault()` handles invocation
- **UI needed:** `Repeater` below the text block in `NotificationCard.qml` generating a button per action, calling `NotificationService.invokeDefault()` with the action identifier

### DND Toggle
**Goal:** Toggle DND from within the notification center header rather than requiring an external binding.

- `NotificationService.dnd` property already exists
- **UI needed:** A toggle button in the `NotificationCenter.qml` header row, bound to `NotificationService.dnd`

### Updates — Run Upgrade
**Goal:** Button in the updates section footer to run `paru -Syu` directly from the notification center, launching in a terminal.

- `UpdateService.refresh()` already exists for post-upgrade re-check
- **UI needed:** A button in the footer row that runs `paru -Syu` in the user's preferred terminal
