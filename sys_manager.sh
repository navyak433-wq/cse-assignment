#!/bin/bash

# sys_manager.sh - User & System Management Script
# Student Assignment

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to print colored messages
print_msg() {
    echo -e "${1}${2}${NC}"
}

# Check if user is root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_msg "$RED" "Error: Need root access. Use sudo."
        exit 1
    fi
}

# Check if user exists
user_exists() {
    id "$1" &>/dev/null
}

# ==================== MODE 1: Add Users ====================
add_users() {
    local file=$1
    
    if [[ ! -f "$file" ]]; then
        print_msg "$RED" "Error: File $file not found"
        exit 1
    fi
    
    check_root
    
    local new_users=0
    local existing_users=0
    
    print_msg "$BLUE" "Adding users from $file"
    
    while IFS= read -r user || [[ -n "$user" ]]; do
        user=$(echo "$user" | xargs)
        [[ -z "$user" ]] && continue
        
        if user_exists "$user"; then
            print_msg "$YELLOW" "User $user already exists"
            ((existing_users++))
        else
            if useradd -m "$user" 2>/dev/null; then
                print_msg "$GREEN" "✓ Created user: $user"
                ((new_users++))
            else
                print_msg "$RED" "✗ Failed: $user"
            fi
        fi
    done < "$file"
    
    print_msg "$GREEN" "Done! New: $new_users, Existing: $existing_users"
}

# ==================== MODE 2: Project Setup ====================
setup_projects() {
    local user=$1
    local count=$2
    
    if ! user_exists "$user"; then
        print_msg "$RED" "Error: User $user not found"
        exit 1
    fi
    
    if ! [[ "$count" =~ ^[0-9]+$ ]]; then
        print_msg "$RED" "Error: Enter valid number"
        exit 1
    fi
    
    check_root
    
    local project_dir="/home/$user/projects"
    
    mkdir -p "$project_dir"
    print_msg "$BLUE" "Creating $count projects for $user"
    
    for ((i=1; i<=count; i++)); do
        local proj="$project_dir/project$i"
        mkdir -p "$proj"
        
        cat > "$proj/README.txt" << EOF
Project: project$i
User: $user
Created: $(date)
EOF
        print_msg "$GREEN" "✓ Created project$i"
    done
    
    chmod -R 755 "$project_dir"
    find "$project_dir" -type f -exec chmod 640 {} \;
    chown -R "$user:$user" "$project_dir"
    
    print_msg "$GREEN" "All projects created successfully!"
}

# ==================== MODE 3: System Report ====================
sys_report() {
    local out_file=$1
    
    if [[ -z "$out_file" ]]; then
        print_msg "$RED" "Error: Provide output filename"
        exit 1
    fi
    
    print_msg "$BLUE" "Generating system report..."
    
    {
        echo "=== SYSTEM REPORT ==="
        echo "Date: $(date)"
        echo ""
        echo "=== DISK USAGE ==="
        df -h
        echo ""
        echo "=== MEMORY ==="
        free -h
        echo ""
        echo "=== TOP MEMORY PROCESSES ==="
        ps aux --sort=-%mem | head -6
        echo ""
        echo "=== TOP CPU PROCESSES ==="
        ps aux --sort=-%cpu | head -6
    } > "$out_file"
    
    print_msg "$GREEN" "Report saved to: $out_file"
}

# ==================== MODE 4: Process Management ====================
process_manage() {
    local user=$1
    local action=$2
    
    if ! user_exists "$user"; then
        print_msg "$RED" "Error: User $user not found"
        exit 1
    fi
    
    case "$action" in
        "list_zombies")
            print_msg "$BLUE" "Zombie processes for $user:"
            ps -u "$user" -o pid,stat,comm | grep -w Z
            ;;
        "list_stopped")
            print_msg "$BLUE" "Stopped processes for $user:"
            ps -u "$user" -o pid,stat,comm | grep -w T
            ;;
        "kill_zombies")
            print_msg "$YELLOW" "Note: Zombies can't be killed directly"
            ;;
        "kill_stopped")
            check_root
            print_msg "$BLUE" "Killing stopped processes..."
            local stopped_pids=$(ps -u "$user" -o pid,stat | awk '$2=="T" {print $1}' | tail -n +2)
            for pid in $stopped_pids; do
                kill -9 "$pid" 2>/dev/null && print_msg "$GREEN" "Killed PID: $pid"
            done
            ;;
        *)
            print_msg "$RED" "Error: Invalid action"
            ;;
    esac
}

# ==================== MODE 5: Permissions ====================
perm_owner() {
    local user=$1
    local path=$2
    local perm=$3
    local owner=$4
    local group=$5
    
    if ! user_exists "$user"; then
        print_msg "$RED" "Error: User $user not found"
        exit 1
    fi
    
    if [[ ! -e "$path" ]]; then
        print_msg "$RED" "Error: Path $path not found"
        exit 1
    fi
    
    check_root
    
    print_msg "$BLUE" "Changing permissions..."
    chmod -R "$perm" "$path" && print_msg "$GREEN" "✓ Permissions changed"
    chown -R "$owner:$group" "$path" && print_msg "$GREEN" "✓ Ownership changed"
}

# ==================== MODE 6: Help ====================
show_help() {
    print_msg "$BLUE" "========== SYS MANAGER HELP =========="
    echo "Usage: ./sys_manager.sh <mode> [args]"
    echo ""
    echo "MODES:"
    echo "1. add_users <filename>"
    echo "2. setup_projects <user> <number>"
    echo "3. sys_report <output_file>"
    echo "4. process_manage <user> <action>"
    echo "5. perm_owner <user> <path> <perm> <owner> <group>"
    echo "6. help"
    echo ""
    echo "Examples:"
    echo "./sys_manager.sh add_users users.txt"
    echo "./sys_manager.sh setup_projects john 3"
    echo "./sys_manager.sh help"
}

# ==================== MAIN ====================
main() {
    case $1 in
        "add_users")
            add_users "$2"
            ;;
        "setup_projects")
            setup_projects "$2" "$3"
            ;;
        "sys_report")
            sys_report "$2"
            ;;
        "process_manage")
            process_manage "$2" "$3"
            ;;
        "perm_owner")
            perm_owner "$2" "$3" "$4" "$5" "$6"
            ;;
        "help")
            show_help
            ;;
        *)
            print_msg "$RED" "Error: Invalid mode"
            show_help
            exit 1
            ;;
    esac
}

# Start script
if [[ $# -eq 0 ]]; then
    show_help
    exit 1
fi

main "$@"
