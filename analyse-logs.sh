#!/bin/bash

LOG_DIR="/c/Users/aksha/logs"

ERROR_PATTERNS=("ERROR" "FATAL" "CRITICAL")

REPORT_FILE="/c/Users/aksha/logs/logs-analysis-report.txt"

echo "analysing log files" > "$REPORT_FILE"
echo "===================" >> "$REPORT_FILE"

echo -e "\nList of log files updated in the last 24 hours." >> "$REPORT_FILE"
LOG_FILES=$(find "$LOG_DIR" -name "*.log" -mtime -30)
echo "$LOG_FILES" >> "$REPORT_FILE"

for LOG_FILE in $LOG_FILES; do

    for PATTERN in "${ERROR_PATTERNS[@]}"; do

        echo -e "\nSearching $PATTERN logs in $LOG_FILE file" >> "$REPORT_FILE"
        grep "$PATTERN" "$LOG_FILE" >> "$REPORT_FILE"

        echo -e "\nSearching the number of $PATTERN logs in $LOG_FILE file" >> "$REPORT_FILE"

        ERROR_COUNT=$(grep -c "$PATTERN" "$LOG_FILE")
        echo $ERROR_COUNT >> "$REPORT_FILE"

        if [ "$ERROR_COUNT" -gt 10 ]; then
            echo -e "\n ⚠ Action Required: too many $PATTERN errors in log file $LOG_FILE"
        fi 

    done
    

done

echo -e "\nLog analysis completed and report saved in: $REPORT_FILE"
