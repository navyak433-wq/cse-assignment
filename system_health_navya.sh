#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset

# color codes for output
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RESET='\033[0m'
success(){ echo -e "${GREEN}[OK]${RESET} $*"; }
note(){ echo -e "${YELLOW}[NOTE]${RESET} $*"; }
error(){ echo -e "${RED}[ERROR]${RESET} $*"; }

check_root() {
  if [[ $EUID -ne 0 ]]; then
    note "Some operations may require root privileges."
    return 1
  fi
  return 0
}

create_report() {
  local file_name="${1:-system_report.txt}"
  success "Creating system report -> ${file_name}"
  {
    echo "==== SYSTEM REPORT ===="
    date
    echo
    echo "-- Disk Usage --"
    df -h
    echo
    echo "-- Memory Usage --"
    free
    echo
    echo "-- CPU Information --"
    if command -v lscpu >/dev/null 2>&1; then
      lscpu | grep -E 'Model|CPU|Thread' || true
    else
      grep "model name" /proc/cpuinfo | head -n 1
    fi
    echo
    echo "-- Top 5 Processes by Memory --"
    ps aux --sort=-%mem | head -n 6
  } > "$file_name"
  success "Report saved to ${file_name}"
}

show_processes() {
  local keyword="${1:-}"
  if [[ -z "$keyword" ]]; then
    ps aux | less
  else
    ps aux | grep -i -- "$keyword" | grep -v grep || note "No process found for keyword: $keyword"
  fi
}

demo_user_creation() {
  local username="$1"
  if [[ -z "$username" ]]; then error "Username is required."; return 1; fi
  local group_name="${username}_group"
  success "Demo only: would create user '$username' with group '$group_name' (no actual changes)."
}

organize_files() {
  local path="${1:-.}"
  mkdir -p "$path/images" "$path/docs" "$path/scripts"
  mv "$path"/*.jpg "$path/images" 2>/dev/null || true
  mv "$path"/*.png "$path/images" 2>/dev/null || true
  mv "$path"/*.txt "$path/docs" 2>/dev/null || true
  mv "$path"/*.md "$path/docs" 2>/dev/null || true
  mv "$path"/*.sh "$path/scripts" 2>/dev/null || true
  success "Files organized inside $path/"
}

check_network() {
  success "Pinging google.com..."
  if ping -c 2 google.com >/dev/null 2>&1; then
    success "Ping successful."
  else
    note "Ping failed."
  fi

  if command -v curl >/dev/null 2>&1; then
    success "Fetching headers from example.com"
    curl -I -s https://example.com | head -n 5
  else
    note "curl is not installed."
  fi
}

main_menu() {
  echo "=============================="
  echo "      SYSTEM TOOLKIT"
  echo "=============================="
  echo "1) System Report"
  echo "2) View Processes"
  echo "3) Demo User Creation"
  echo "4) Organize Files"
  echo "rd (optional): " kw; show_processes "$kw" ;;
    3) read -rp "Enter username: " usr; demo_user_creation "$usr" ;;
    4) read -rp "Enter directory path: " dir; organize_files "$dir" ;;
    5) check_network ;;
    6) success "Exiting..."; exit 0 ;;
    *) note "Invalid choice." ;;
  
