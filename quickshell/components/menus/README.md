# Quickshell Menu System

Interactive dropdown panels anchored to bar modules. All of them extend `Menu` and are owned by their respective bar module.

## Architecture

### Files
- `Menu.qml` — base component in `components/base/`, handles focus, dismiss, and anchor.
- `MenuHeader.qml` — shared icon + title + subtitle header, in `components/base/`. Children go into a right-aligned `actions` row.
- `MenuHeaderButton.qml` — icon button for a header's `actions` row (`clicked(button)` passes left/right), in `components/base/`.
- `MenuFooter.qml` — shared single trailing-action row (icon + label), in `components/base/`. Always the last thing in a menu by convention — rounds its own bottom corners to match the popup.
- `MenuSectionLabel.qml` — shared bold section-header text (e.g. "My Devices"), in `components/base/`.
- `CalendarMenu.qml` — interactive calendar with holiday integration
- `TailscaleMenu.qml` — Tailscale peer browser and connection manager
- `BluetoothMenu.qml` — paired-device manager and new-device scanner
- `UsbMenu.qml` — connected USB/storage device manager
- `TheTowerMenu.qml` — The Tower: script switches (Auto-Run, Auto-Gem) plus a Layout page; pages swap in place via a `page` property

### Padding model
`Menu`'s content column reserves **no** structural space of its own by default — no vertical margin, `spacing: 0`. Every element is responsible for its own breathing room:
- `MenuHeader` and `MenuSectionLabel` each carry their own `topPadding`/`bottomPadding`/left inset, so they look right whether or not the popup's rows are full-bleed.
- Dividers are plain, un-padded `Rectangle`s — the gap around one comes entirely from whatever content sits on either side, never from the divider itself (a divider that owned its own margin would double up with a neighbor's padding and look wrong — learned that one the hard way).
- Rows (`MenuItem`/`MenuFooter`) carry no margin at all, so their hover fill can go edge-to-edge.

`padded: false` (set per-`Menu` instance) additionally removes the **left/right** margin, letting rows span the full width horizontally — used by Tailscale, Bluetooth, and USB so hovering a row fills the whole line instead of stopping short at an inset.

One structural minimum applies regardless of `padded`: content is always inset by exactly `border.width` (1px) on every side, so a full-bleed row's background can never paint over the popup's own border stroke.

### Rounded corners on the last row
`clip: true` on the popup's background rectangle only clips to the rectangular bounding box — it does **not** follow `radius`. So a full-bleed row sitting flush at the very bottom would show square corners against the popup's rounded shape. Rather than a shader-based mask (tried once — it broke rendering entirely when the mask source item wasn't rendering into a real texture), the fix is plain geometry: whichever row is actually the last visible thing gets `bottomLeftRadius`/`bottomRightRadius` set via Qt 6.7+'s per-corner `Rectangle` properties (`index === repeater.count - 1`). This is wired up per-popup (Bluetooth's "Available Devices" list, USB's peripheral list, and `MenuFooter` always) and doesn't yet cover every edge case — e.g. Bluetooth powered-off, or USB with only storage cards and no peripherals. Revisit only if one of those is actually seen looking wrong live.

### Pattern
Menus are instantiated inside their bar module, not in `shell.qml`. The bar module owns `open` state and `anchorItem`.
```js
ModuleItem {
    id: myModule
    onClicked: myMenu.open = !myMenu.open

    MyMenu {
        id:         myMenu
        anchorItem: myModule
    }
}
```

`Menu` registers with `FocusService` and closes automatically on click-outside. `onDismissed: root.open = false` is the default behavior — no need to add it manually.

## Features

### CalendarMenu

**Opens from:** `DateTime.qml` — left click on the date module

- Month view with prev/next navigation via `‹` `›` buttons or scroll wheel
- Current day highlighted with `ThemeState.accent`
- Days from prev/next month shown dimmed in `Theme.subtext`
- Holiday dots on days with events sourced from `CalendarService`
- Hover tooltip showing holiday name(s) on days with events
- Hover highlight circle encompassing the holiday dot
- Resets to current month every time it opens
- Configurable first day of week via `UserConfig.firstDayOfWeek`
- Header is bespoke (month navigator, not the icon+title+subtitle shape `MenuHeader` covers)

### TailscaleMenu

**Opens from:** `Connectivity.qml` — left click toggles connect/disconnect, right click opens the menu

- Header icon toggles Tailscale connection on click, pulses while transitioning
- Peer list with device icon, hostname, IP address, and online indicator
- Exit node badge on eligible peers, highlighted when active
- Left click a peer copies its IP to clipboard and shows a notification
- Hover a peer to see last seen time via tooltip
- Footer "Open Admin Console" link (`MenuFooter`)
- Peer list scrollable, capped at 5 visible items
- Auto-refreshes every 10 seconds via `TailscaleService`

### BluetoothMenu

**Opens from:** `Connectivity.qml` — left click toggles power, right click opens the menu

- Header icon toggles Bluetooth power, colored by connection state
- "My Devices": bonded devices (bluez's own pairing store — no separate persistence needed), each with battery % when available
- Connected devices shown via accent color + a persistent hover tint, no separate connect/disconnect button — click the row to toggle
- Clicking a connected row disconnects it and sets bluez's `blocked` flag, so headsets that aggressively self-reconnect can't talk their way back in; clicking again unblocks and connects
- Right click a row opens a `ContextMenu` at the cursor with "Forget Device" (red on hover) and "Auto-Connect" (accent text when on, toggles bluez's `trusted` flag)
- "Available Devices": manual-only scanning via the reload icon or a "Scan for Devices" prompt — never auto-starts, and resets every time the menu closes so stale results never linger
- Device-class icons (mouse/keyboard/gamepad/speaker) come from bluez's own freedesktop icon hint via `BluetoothService.deviceIcon()`; headphones not sourced yet, falls back to the generic bluetooth glyph

### UsbMenu

**Opens from:** `Connectivity.qml` — click toggles the menu; the bar icon also appears on storage connect

- "Storage Drives": name and size, eject button per drive, rendered as distinct spaced-apart cards (not full-bleed rows)
- "Connected Peripherals": full-bleed USB device list
- "No devices connected" placeholder when both lists are empty
- Connect/disconnect notifications are transient (never saved to notification history)

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

No additional Hyprland configuration required. Menus use `PopupWindow` which handles Wayland layer shell positioning automatically.

## Adding a New Menu

1. Create `components/menus/YourMenu.qml` extending `Menu`
2. Set `menuWidth` and add content as children — `open` and `anchorItem` are set by the parent. Use `MenuHeader`/`MenuSectionLabel`/`MenuFooter` for the standard shapes where they fit; each carries its own padding, so don't add extra `Column.spacing` around them.
3. Set `padded: false` if your rows should hover edge-to-edge; leave the default otherwise.
4. Instantiate inside your bar module's `ModuleItem` and bind `anchorItem`
5. No need to handle `onDismissed` — `Menu` closes itself by default
