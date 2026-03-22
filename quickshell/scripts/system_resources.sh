#!/usr/bin/env bash
# scripts/system-resources.sh
# Outputs CPU stats and system metrics for ResourceService.qml

CPU_TEMP_PATH="$1"
GPU_TEMP_PATH="$2"

grep 'cpu ' /proc/stat

echo "STATS:{\"mem\":$(free | awk '/Mem:/ {print int($3/$2 * 100)}'), \
\"mu\":$(free -b | awk '/Mem:/ {print $3}'), \
\"gpu\":$(cat /sys/class/drm/card1/device/gpu_busy_percent 2>/dev/null || cat /sys/class/drm/card0/device/gpu_busy_percent 2>/dev/null || echo 0), \
\"vru\":$(cat /sys/class/drm/card1/device/mem_info_vram_used 2>/dev/null || cat /sys/class/drm/card0/device/mem_info_vram_used 2>/dev/null || echo 0), \
\"vrt\":$(cat /sys/class/drm/card1/device/mem_info_vram_total 2>/dev/null || cat /sys/class/drm/card0/device/mem_info_vram_total 2>/dev/null || echo 0), \
\"ct\":$(cat "$CPU_TEMP_PATH" 2>/dev/null || echo 0), \
\"gt\":$(cat "$GPU_TEMP_PATH" 2>/dev/null || echo 0)}"
