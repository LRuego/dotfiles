# InputService

`InputService.qml` is a singleton service that provides a high-level API for global keyboard events within Quickshell. It bypasses standard Wayland input limitations by reading directly from raw input devices using `evtest`.

## Setup & Permissions

For `InputService` to function, the user running Quickshell must have read access to the raw input devices in `/dev/input/`.

### 1. Install evtest
Ensure `evtest` is installed via your distribution's package manager (e.g., `apt`, `dnf`, `pacman`, `zypper`).

### 2. Configure Permissions (udev)
The most secure and modern way to grant access without using the `input` group is via a `udev` rule using the `uaccess` tag. This grants the active logged-in user permission to read the device.

Create a new udev rule file (e.g., `/etc/udev/rules.d/99-quickshell-input.rules`):

```udev
# Grant the active session user read access to all keyboard devices
SUBSYSTEM=="input", ENV{ID_INPUT_KEYBOARD}=="1", TAG+="uaccess", TAG+="seat"
```

**Why these tags?**
- `TAG+="uaccess"`: Tells systemd-logind to apply an ACL giving the current user `rw` access.
- `TAG+="seat"`: (Required on some systems, especially with custom session managers) Ensures the device is associated with your hardware seat so `logind` knows which user is "active".

After creating the file, apply the changes:
```bash
sudo udevadm control --reload-rules && sudo udevadm trigger
```

### 3. Verification
You can verify the permissions are correctly applied by checking the ACLs on your keyboard's event node:
```bash
# Replace eventX with your actual keyboard node (e.g., event12)
getfacl /dev/input/eventX
```
The output should show `user:yourusername:rw-`.

## How it Works

### 1. Keyboard Discovery
At startup (or when `refresh()` is called), the service scans `/sys/class/input/event*/device/name` to identify keyboard devices.
- It filters for devices containing "Keyboard" in their name.
- It explicitly excludes "Mouse" and "Consumer Control" nodes to avoid capturing irrelevant events.
- It maintains a `monitoredPaths` map to prevent spawning multiple watchers for the same device.

### 2. Device Monitoring
For every discovered keyboard, a `keyboardWatcher` component is created. This component spawns an `evtest` process for the specific `/dev/input/eventX` path.
- **stdout Parsing**: The service parses the raw output of `evtest` using a `SplitParser`.
- **Event Filtering**: It looks for `KEY_` patterns and their values:
    - `value 1`: Key Pressed.
    - `value 0`: Key Released.
    - `value 2`: Auto-repeat (intentionally ignored to prevent duplicate triggers).

### 3. Automatic Recovery
Each keyboard watcher independently monitors its own `evtest` process. If the process exits with a non-zero code (e.g. due to a permission loss or device disconnect), the watcher will automatically attempt to restart it after a 2 second delay. This handles transient failures — such as udev re-applying ACLs after a device reconnect — without requiring manual intervention.
- Up to 5 retry attempts are made per watcher. After that, it logs a warning and gives up to avoid spinning on a permanently dead device.
- Retry counters reset after a successful restart, so a device that recovers gets a fresh counter for any future failures.
- A clean exit (code 0) never triggers a retry — this is how `refresh()` kills watchers intentionally.

### 4. Modifier Tracking
The service maintains a real-time count of active modifier keys:
- `shiftCount`, `ctrlCount`, `altCount`, `superCount`.
- It provides boolean properties like `altHeld` which are true as long as at least one corresponding key (Left or Right) is pressed.

## Public API

The service provides several timing-based abstractions for complex key interactions:

| Function | Description |
|----------|-------------|
| `onTap(key, interval, callback)` | Triggers when a key is pressed and released within the interval. |
| `onHold(key, interval, onHeld, onReleased)` | Triggers `onHeld` after the key is held for the interval; `onReleased` triggers on release. |
| `onDoubleTap(key, interval, callback)` | Triggers if the key is tapped twice within the interval. |
| `onTapAndHold(key, interval, callback, onHeld, onReleased)` | Hybrid handler that distinguishes between a quick tap and a sustained hold. |
| `onToggle(key, onChange)` | Toggles a boolean state on every key press. |
| `refresh()` | Destroys all active watchers and re-scans the system for keyboards. Rarely needed in practice due to automatic recovery. |
