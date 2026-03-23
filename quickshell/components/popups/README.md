# Quickshell Popup System

Interactive popup panels anchored to bar modules. All popups extend `MenuPopup` and are owned by their respective bar module.

## Architecture

### Files
- `MenuPopup.qml` — base popup component in `components/base/`, handles focus, dismiss, and anchor
- `CalendarPopup.qml` — interactive calendar with holiday integration
- `TailscalePopup.qml` — Tailscale peer browser and connection manager

### Pattern
Popups are instantiated inside their bar module, not in `shell.qml`. The bar module owns `open` state and `anchorItem`.
```js
ModuleItem {
    id: myModule
    onClicked: myPopup.open = !myPopup.open

    MyPopup {
        id:         myPopup
        anchorItem: myModule
    }
}
```

`MenuPopup` registers with `FocusService` and closes automatically on click-outside. `onDismissed: root.open = false` is the default behavior — no need to add it manually.

## Features

### CalendarPopup

**Opens from:** `DateTime.qml` — left click on the date module

- Month view with prev/next navigation via `‹` `›` buttons or scroll wheel
- Current day highlighted with `ThemeState.accent`
- Days from prev/next month shown dimmed in `Theme.subtext`
- Holiday dots on days with events sourced from `CalendarService`
- Hover tooltip showing holiday name(s) on days with events
- Hover highlight circle encompassing the holiday dot
- Resets to current month every time it opens
- Configurable first day of week via `UserConfig.firstDayOfWeek`

### TailscalePopup

**Opens from:** `Connectivity.qml` — left click on Tailscale icon, right click toggles connect/disconnect

- Header icon toggles Tailscale connection on click, pulses while transitioning
- Peer list with device icon, hostname, IP address, and online indicator
- Exit node badge on eligible peers, highlighted when active
- Left click a peer copies its IP to clipboard and shows a notification
- Hover a peer to see last seen time via tooltip
- Footer "Open Admin Console" link
- Peer list scrollable, capped at 5 visible items
- Auto-refreshes every 10 seconds via `TailscaleService`

## Configuration

| Property | Location | Description |
|---|---|---|
| `holidayCalendarUrl` | `UserConfig.qml` | Google Calendar ICS URL for holiday data |
| `firstDayOfWeek` | `UserConfig.qml` | `0` = Sunday, `1` = Monday |

**How to get your holiday calendar URL:**
1. Go to https://calendar.google.com
2. Add a holiday calendar via Other calendars → Browse calendars of interest
3. Settings → click your holiday calendar → Integrate calendar
4. Copy the Public address in iCal format

## Hyprland Setup

No additional Hyprland configuration required. Popups use `PopupWindow` which handles Wayland layer shell positioning automatically.

## Adding a New Popup

1. Create `components/popups/YourPopup.qml` extending `MenuPopup`
2. Set `menuWidth` and add content as children — `open` and `anchorItem` are set by the parent
3. Instantiate inside your bar module's `ModuleItem` and bind `anchorItem`
4. No need to handle `onDismissed` — `MenuPopup` closes itself by default
