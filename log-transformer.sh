#!/bin/bash

INPUT_LOG="/c/Users/aksha/logs/system.log"

CLEANED_LOG="./cleaned-system-log"

sed 's/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/[REDACTED]/g' "$INPUT_LOG" > "$CLEANED_LOG"

awk '{
        msg = ""
        for(i = 7; i <= NF; i++) msg = msg $i " "
        print $3, $6, msg
}' "$CLEANED_LOG"
