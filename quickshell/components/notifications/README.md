# Quickshell Notification System

This directory contains the visual components for the Quickshell Notification System. The core D-Bus server logic and state management are handled in `../../services/NotificationService.qml`.

## Current State (v1.0)
- **Native D-Bus Integration:** Replaces Dunst/Mako by natively claiming `org.freedesktop.Notifications`.
- **State-Controlled Animations:** Uses a pure QML state machine (`visible` / `hidden`) instead of `ListView` transitions to guarantee glitch-free fade-outs and prevent transparency bugs.
- **Memory Safe:** `ListModel` only stores strings and numbers. QML components (like Timers and Animations) are strictly confined to the `NotificationCard` to prevent garbage collection crashes during high-volume notification spam.
- **Smart Progress Bar:** Features a bottom-aligned, shrinking progress bar that automatically pauses when hovered and perfectly respects the card's `Theme.cornerRadius`.

---

## Future Roadmap (What to build next)

### 1. The History Center
**Goal:** A persistent window to view dismissed or missed notifications.
*   **Service Requirement:** Re-introduce an `all` ListModel in `NotificationService.qml`. Ensure it only stores raw data (`summary`, `body`, `icon`, `time`) and strictly caps at ~50-100 items to prevent RAM bloat over long uptimes.
*   **UI Requirement:** Create a `NotificationCenter.qml` window (perhaps triggered by a clock click or keybind) with a `ListView` bound to the `all` model. Includes a "Clear All" button.

### 2. Action Buttons
**Goal:** Allow users to interact with notifications (e.g., "Reply", "Open", "Skip").
*   **Service Requirement:** Pass the `n.actions` array into the `popupList` model.
*   **UI Requirement:** In `NotificationCard.qml`, add a `Repeater` below the text block that generates a `Rectangle` (button) for each action. Clicking the button should call the native `.invokeAction(identifier)` method.

### 3. Application Grouping
**Goal:** Prevent screen clutter by stacking multiple messages from the same app (e.g., 5 Discord messages become 1 visual card).
*   **Service Requirement:** Before appending a new notification, scan the `popupList` for an existing item with the same `appName`. If found, replace the old item's body with the new one, or append it to a string like "2 new messages".

### 4. Rich Media (Images & Screenshots)
**Goal:** Display actual images sent by applications (like Spotify album art or Grim/Slurp screenshots).
*   **Service Requirement:** Parse the `n.image` property or the `image-path` / `image-data` hints from the D-Bus payload.
*   **UI Requirement:** Add an `Image` component to `NotificationCard.qml` that dynamically expands if a valid image path is provided.

### 5. Urgency Styling
**Goal:** Visually distinguish between Low, Normal, and Critical alerts.
*   **Service Requirement:** Pass `n.urgency` into the model.
*   **UI Requirement:** Bind the card's `border.color` or a dedicated warning icon to change to `Theme.urgent` (red) if the urgency is Critical.
