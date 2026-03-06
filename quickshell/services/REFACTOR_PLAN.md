# Quickshell Services Refactoring Plan

## Objective
Convert current per-window services into **Singletons** to provide a unified data source for the Bar and future interactive windows.

---

## Status: IN PROGRESS
- [x] **Global Singleton Switch:** All services are now proper singletons.
- [x] **Shared Access:** `Bar.qml` now uses service names directly.
- [ ] **Audio Service Optimization:** Remove `privacy_dots.sh` loop and use native Pipewire state.
- [ ] **Network Expansion:** Add Tailscale detection and Wi-Fi scanning.
- [ ] **Bluetooth Expansion:** Device list filtering for future menus.

---

## Next Priority: Audio Service
- **Logic:** Migrate from the shell script loop to native Pipewire property monitoring for "is-recording" state.
- **Cleanup:** Delete the dependency on `privacy_dots.sh`.
