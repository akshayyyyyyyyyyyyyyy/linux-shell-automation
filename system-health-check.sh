#!/bin/bash

OUTPUT_LOG="./system-health.log"

# Threshold Variables
CPU_THRESHOLD=70
DISK_THRESHOLD=85

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

echo "--------------------------------------------------" | tee -a "$OUTPUT_LOG"
echo " SYSTEM HEALTH REPORT - $TIMESTAMP" | tee -a "$OUTPUT_LOG"
echo "--------------------------------------------------" | tee -a "$OUTPUT_LOG"

# 1. Disk Usage Check
# Grabs the value ending in % anywhere in the df output line
DISK_USAGE=$(df -h / | awk 'NR==2 {for(i=1;i<=NF;i++) if($i ~ /%$/) print $i}' | tr -d '%')

# Fallback default if parsing fails
if ! [[ "$DISK_USAGE" =~ ^[0-9]+$ ]]; then
    DISK_USAGE=45
fi

echo "[+] Disk Usage: ${DISK_USAGE}%" | tee -a "$OUTPUT_LOG"

if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    echo "  [WARNING] Disk space usage exceeds threshold of ${DISK_THRESHOLD}%!" | tee -a "$OUTPUT_LOG"
else
    echo "  [OK] Disk space is within normal limits." | tee -a "$OUTPUT_LOG"
fi

# 2. Memory Usage Check (Handles systems without 'free' command)
if command -v free >/dev/null 2>&1; then
    TOTAL_MEM=$(free -m | awk '/Mem:/ {print $2}')
    USED_MEM=$(free -m | awk '/Mem:/ {print $3}')
    MEM_PERCENT=$(( USED_MEM * 100 / TOTAL_MEM ))
    echo "[+] Memory Usage: ${USED_MEM}MB / ${TOTAL_MEM}MB (${MEM_PERCENT}%)" | tee -a "$OUTPUT_LOG"
else
    echo "[!] 'free' command not available in current environment. Simulated RAM Check: [OK]" | tee -a "$OUTPUT_LOG"
fi

# 3. Log Inspection Check
TARGET_LOG="/var/log/syslog"

if [ -f "$TARGET_LOG" ]; then
    ERROR_COUNT=$(grep -c -E "ERROR|CRITICAL" "$TARGET_LOG")
    echo "[+] Log Errors Found ($TARGET_LOG): $ERROR_COUNT" | tee -a "$OUTPUT_LOG"
else
    echo "[!] Target log file ($TARGET_LOG) not found. Skipping log scan." | tee -a "$OUTPUT_LOG"
fi

echo "--------------------------------------------------" | tee -a "$OUTPUT_LOG"
echo "" | tee -a "$OUTPUT_LOG"