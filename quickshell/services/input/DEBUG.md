# Debugging InputService

If your global keybindings (like `onDoubleTap` or `onHold`) are not working in Quickshell, follow these troubleshooting steps.

## Automatic Recovery

`InputService` will automatically attempt to restart a failed `evtest` watcher up to 5 times with a 2 second delay between attempts. In most cases — such as a device briefly losing ACL permissions after reconnect — this resolves itself without any manual intervention.

If recovery is failing, the logs will tell you:
```
[InputService] evtest exited with code 1 for /dev/input/eventX
[InputService] evtest for /dev/input/eventX failed 5 times, giving up.
```
If you see the "giving up" message, there is a persistent underlying issue. Continue with the steps below.

## Common Issue: Permission Denied

The most frequent cause of failure is `evtest` lacking read access to the raw input devices in `/dev/input/`.

### 1. Check Quickshell Logs
Monitor the output of Quickshell for error messages from the `InputService`:
```bash
# Look for "evtest: Permission denied"
quickshell --debug | grep "InputService"
```

### 2. Verify ACL Permissions
Check if your current user has read/write access to the event nodes:
```bash
getfacl /dev/input/eventX
```
A working configuration should show your username with `rw-` permissions.

### 3. Quick Fix (Manual)
To temporarily restore functionality for a specific device:
```bash
sudo setfacl -m u:$USER:rw /dev/input/eventX
```
Once permissions are restored, `InputService` will recover automatically on the next retry. If retries have already been exhausted, call `InputService.refresh()` in your QML or reload Quickshell.

## Troubleshooting Device Discovery

If `InputService` is not finding your keyboard at all:

### 1. Identify the Correct Device
Check what devices are seen as keyboards by the system:
```bash
grep -rH '' /sys/class/input/event*/device/name
```
`InputService` looks for names containing "Keyboard" but not "Mouse" or "Consumer Control".

### 2. Test Manually with evtest
Confirm that `evtest` itself can see events from the device:
```bash
evtest /dev/input/eventX
```
If this doesn't show any events when you type, the node is incorrect or the device is already grabbed by another process.

## Permanent Fix: Udev Rules

Ensure your `/etc/udev/rules.d/99-keyboards.rules` is correctly configured to apply the `uaccess` and `seat` tags:

```udev
# Example Rule
SUBSYSTEM=="input", ENV{ID_INPUT_KEYBOARD}=="1", TAG+="uaccess", TAG+="seat"
```

After modifying the rule, reload and trigger:
```bash
sudo udevadm control --reload-rules && sudo udevadm trigger
```
Note: On some systems (especially those using `uwsm`), the `seat` tag is mandatory for `uaccess` to apply correctly.
