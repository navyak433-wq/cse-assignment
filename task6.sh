#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

show_menu() {
    clear
    print_color $CYAN "=========================================="
    print_color $CYAN "    SYSTEM HEALTH MONITORING TOOL"
    print_color $CYAN "=========================================="
    print_color $YELLOW "1. System Health Check"
    print_color $YELLOW "2. Active Processes"
    print_color $YELLOW "3. User & Group Management"
    print_color $YELLOW "4. File Organizer"
    print_color $YELLOW "5. Network Diagnostics"
    print_color $YELLOW "6. Scheduled Task Setup"
    print_color $YELLOW "7. SSH Key Setup"
    print_color $YELLOW "8. Exit"
    print_color $CYAN "=========================================="
}

system_health_check() {
    print_color $BLUE "Running System Health Check..."
    
    echo "=== SYSTEM HEALTH REPORT ===" > system_report.txt
    echo "Generated on: $(date)" >> system_report.txt
    echo "" >> system_report.txt
    
    echo "=== DISK USAGE ===" >> system_report.txt
    df -h >> system_report.txt
    echo "" >> system_report.txt
    
    echo "=== CPU INFORMATION ===" >> system_report.txt
    lscpu >> system_report.txt
    echo "" >> system_report.txt
    
    echo "=== MEMORY USAGE ===" >> system_report.txt
    free -h >> system_report.txt
    echo "" >> system_report.txt
    
    print_color $GREEN "System health report saved to system_report.txt"
    
    print_color $PURPLE "First 10 lines of the report:"
    echo "----------------------------------------"
    head -n 10 system_report.txt
    echo "----------------------------------------"
}

active_processes() {
    print_color $BLUE "Listing Active Processes..."
    
    print_color $PURPLE "All active processes:"
    ps aux
    
    echo
    print_color $YELLOW "Enter a keyword to filter processes:"
    read keyword
    
    if [ -n "$keyword" ]; then
        count=$(ps aux | grep -c "$keyword")
        
        print_color $PURPLE "Processes matching '$keyword':"
        ps aux | grep "$keyword"
        
        print_color $GREEN "Number of processes matching '$keyword': $count"
    else
        print_color $YELLOW "No keyword provided."
    fi
}

user_management() {
    print_color $BLUE "User and Group Management..."
    
    if [ "$EUID" -ne 0 ]; then
        print_color $RED "This function requires root privileges."
        return 1
    fi
    
    echo
    print_color $YELLOW "Enter new username:"
    read username
    
    if id "$username" &>/dev/null; then
        print_color $RED "User '$username' already exists!"
        return 1
    fi
    
    groupname="$username"
    
    useradd -m -s /bin/bash "$username"
    groupadd "$groupname"
    usermod -a -G "$groupname" "$username"
    
    echo "$username:password123" | chpasswd
    
    test_file="/home/$username/test_file.txt"
    echo "This is a test file for user $username" > "$test_file"
    chown "$username:$groupname" "$test_file"
    
    print_color $GREEN "User '$username' created successfully!"
    print_color $GREEN "Default password: password123"
    print_color $YELLOW "Please change the default password!"
}

file_organizer() {
    print_color $BLUE "File Organizer..."
    
    print_color $YELLOW "Enter directory path to organize:"
    read dir_path
    
    if [ ! -d "$dir_path" ]; then
        print_color $RED "Directory '$dir_path' does not exist!"
        return 1
    fi
    
    mkdir -p "$dir_path/images" "$dir_path/docs" "$dir_path/scripts"
    
    for img in "$dir_path"/*.jpg "$dir_path"/*.jpeg "$dir_path"/*.png; do
        if [ -f "$img" ]; then
            mv "$img" "$dir_path/images/"
            print_color $GREEN "Moved $(basename "$img") to images/"
        fi
    done
    
    for doc in "$dir_path"/*.txt "$dir_path"/*.md; do
        if [ -f "$doc" ]; then
            mv "$doc" "$dir_path/docs/"
            print_color $GREEN "Moved $(basename "$doc") to docs/"
        fi
    done
    
    for script in "$dir_path"/*.sh; do
        if [ -f "$script" ]; then
            mv "$script" "$dir_path/scripts/"
            print_color $GREEN "Moved $(basename "$script") to scripts/"
        fi
    done
    
    print_color $PURPLE "Directory structure after organization:"
    if command -v tree &> /dev/null; then
        tree "$dir_path"
    else
        ls -la "$dir_path"
    fi
}

network_diagnostics() {
    print_color $BLUE "Running Network Diagnostics..."
    
    echo "=== NETWORK DIAGNOSTICS REPORT ===" > network_report.txt
    echo "Generated on: $(date)" >> network_report.txt
    echo "" >> network_report.txt
    
    print_color $PURPLE "Pinging google.com..."
    echo "=== PING TEST ===" >> network_report.txt
    ping -c 3 google.com >> network_report.txt 2>&1
    echo "" >> network_report.txt
    
    print_color $PURPLE "Resolving DNS for google.com..."
    echo "=== DNS RESOLUTION ===" >> network_report.txt
    dig google.com >> network_report.txt 2>&1
    echo "" >> network_report.txt
    
    print_color $PURPLE "Fetching HTTP headers..."
    echo "=== HTTP HEADERS ===" >> network_report.txt
    curl -I https://example.com >> network_report.txt 2>&1
    echo "" >> network_report.txt
    
    print_color $GREEN "Network diagnostics completed."
    
    echo
    print_color $CYAN "Network Diagnostics Summary:"
    echo "----------------------------------------"
    tail -n 15 network_report.txt
    echo "----------------------------------------"
}

cron_setup() {
    print_color $BLUE "Scheduled Task Setup..."
    
    print_color $YELLOW "Enter script path:"
    read script_path
    
    if [ ! -f "$script_path" ]; then
        print_color $RED "Script '$script_path' does not exist!"
        return 1
    fi
    
    chmod +x "$script_path"
    
    echo
    print_color $YELLOW "Enter minute (0-59):"
    read minute
    print_color $YELLOW "Enter hour (0-23):"
    read hour
    
    if [[ ! "$minute" =~ ^[0-9*]+$ ]] || [[ ! "$hour" =~ ^[0-9*]+$ ]]; then
        print_color $RED "Invalid time format!"
        return 1
    fi
    
    (crontab -l 2>/dev/null; echo "$minute $hour * * * $script_path") | crontab -
    
    print_color $GREEN "Cron job added!"
    print_color $GREEN "Schedule: $minute $hour * * * $script_path"
    crontab -l
}

ssh_key_setup() {
    print_color $BLUE "SSH Key Setup..."
    
    print_color $YELLOW "Enter key type (default: rsa):"
    read key_type
    key_type=${key_type:-rsa}
    
    print_color $YELLOW "Enter key file location (default: ~/.ssh/id_rsa):"
    read key_file
    key_file=${key_file:-~/.ssh/id_rsa}
    
    print_color $PURPLE "Generating SSH key..."
    ssh-keygen -t "$key_type" -f "$key_file" -N "" -q
    
    print_color $GREEN "SSH key generated!"
    print_color $CYAN "Your public key:"
    echo "----------------------------------------"
    cat "${key_file}.pub"
    echo "----------------------------------------"
    
    echo
    print_color $YELLOW "To copy key to remote server:"
    print_color $CYAN "ssh-copy-id -i $key_file user@remote-server"
}

exit_script() {
    print_color $GREEN "Thank you for using System Health Tool!"
    print_color $GREEN "Goodbye!"
    exit 0
}

main() {
    while true; do
        show_menu
        print_color $CYAN "Select option (1-8):"
        read choice
        
        case $choice in
            1) system_health_check ;;
            2) active_processes ;;
            3) user_management ;;
            4) file_organizer ;;
            5) network_diagnostics ;;
            6) cron_setup ;;
            7) ssh_key_setup ;;
            8) exit_script ;;
            *) print_color $RED "Invalid option!" ;;
        esac
        
        echo
        print_color $YELLOW "Press Enter to continue..."
        read
    done
}

main "$@"
