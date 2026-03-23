# Scripts

Helper scripts used by Quickshell services. All scripts live in `scripts/` and are symlinked to `~/.config/quickshell/scripts/`. Services reference them via `Qt.resolvedUrl()` relative to the service file.

## fetch_holidays.sh

Fetches and parses a holiday ICS calendar file for `CalendarService.qml`.

**Arguments:**
1. `URL` — ICS calendar URL (set via `UserConfig.holidayCalendarUrl`)
2. `CACHE_FILE` — path to cache the downloaded ICS file

**Behavior:**
- Creates cache directory if it doesn't exist
- Refetches if cache file doesn't exist or is older than 7 days
- Parses all years from the ICS (not just current year)
- Outputs sorted `YYYY-MM-DD|Holiday Name` pairs to stdout

**Cache location:** `~/.local/share/quickshell/holidays.ics`

---

## system_resources.sh

Collects CPU, memory, GPU, and VRAM stats for `ResourceService.qml`.

**Arguments:**
1. `CPU_TEMP_PATH` — sysfs path to CPU temperature (e.g. `/sys/class/hwmon/hwmon2/temp1_input`)
2. `GPU_TEMP_PATH` — sysfs path to GPU temperature

**Output:**
- Line 1: raw `cpu` line from `/proc/stat` for CPU usage delta calculation
- Line 2: `STATS:{...}` JSON with `mem`, `mu`, `gpu`, `vru`, `vrt`, `ct`, `gt` fields

**Runs every:** 1 second via `ResourceService` timer

---

## privacy_dots.sh

Detects active microphone, camera, location, and screen sharing usage for `PrivacyService.qml`.

**Arguments:** None

**Output:** JSON with `text`, `tooltip`, and `class` fields. Class string includes `mic-on`, `cam-on`, `loc-on`, `scr-on` flags based on active state.

**Dependencies:** `pipewire` (`pw-dump`), `jq`, `fuser`, `gdbus`

**Runs every:** 2 seconds via `PrivacyService` timer

**Credit:** Based on [privacy-dots](https://github.com/alvaniss/privacy-dots) by alvaniss

---

## taildrop_notify.sh

Watches for incoming Tailscale file transfers and sends desktop notifications. Runs as a persistent systemd user service.

**Arguments:** None

**Behavior:**
- Saves received files to `~/Downloads/Taildrop/`
- Sends a `notify-send` notification for every received file
- Attaches `image-path` hint for image files so `NotificationService` shows a preview
- Supports filenames with spaces

**Dependencies:** `tailscale`, `notify-send`

**Systemd service:** `systemd/user/taildrop.service`
