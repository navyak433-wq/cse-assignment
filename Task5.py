#!/bin/bash

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
NC="\033[0m"

echo -e "${GREEN}Welcome to your simple system report generator!${NC}"

echo -e "${YELLOW}Enter directory where you want to save the report:${NC}"
read save_dir

timestamp=$(date +%Y%m%d_%H%M%S)
report_file="$save_dir/system_report_$timestamp.txt"

{
echo "===== System Report ====="
echo ""
echo "User: $(whoami)"
echo "Hostname: $(hostname)"
echo "Date & Time: $(date)"
echo ""
echo "Disk Usage for /:"
df -h /
echo ""
echo "Memory Usage:"
free -h
echo ""
echo "Top 5 processes by memory usage:"
ps aux --sort=-%mem | head -n 6
echo "===== End of Report ====="
} > "$report_file"

echo -e "${BLUE}System report saved to:${NC} $report_file"
echo -e "${GREEN}Report generation complete!${NC}"

