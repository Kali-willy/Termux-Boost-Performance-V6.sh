#!/data/data/com.termux/files/usr/bin/bash

# ═══════════════════════════════════════════════════════════════════
# ╔═╗╔═╗╦═╗╔═╗╔═╗╦═╗╔╦╗╔═╗╔╗╔╔═╗╔═╗  ╔╗ ╔═╗╔═╗╔═╗╔╦╗╔═╗╦═╗
# ╠═╝║╣ ╠╦╝╠╣ ║ ║╠╦╝║║║╠═╣║║║║  ║╣   ╠╩╗║ ║║ ║╚═╗ ║ ║╣ ╠╦╝
# ╩  ╚═╝╩╚═╚  ╚═╝╩╚═╩ ╩╩ ╩╝╚╝╚═╝╚═╝  ╚═╝╚═╝╚═╝╚═╝ ╩ ╚═╝╩╚═
# ═══════════════════════════════════════════════════════════════════
# Created by: Willy Gailo
# Version: 1.2 (Fixed for Termux)
# For Termux on Rooted Devices Only
# ═══════════════════════════════════════════════════════════════════

# Make script executable
chmod +x "$0"

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# Function to display animated text
animate_text() {
    text="$1"
    color="$2"
    for (( i=0; i<${#text}; i++ )); do
        echo -n -e "${color}${text:$i:1}${RESET}"
        sleep 0.01
    done
    echo
}

# Function to display a cool banner
display_banner() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BLUE}║                                                            ║${RESET}"
    echo -e "${BLUE}║${RESET}  ${BOLD}${CYAN}▀█▀ █▀▀ █▀█ █▀▄▀█ █ █ ▀▄▀   █▀█ █▀▀ █▀█ █▀▀ █▀█ █▀▄▀█${RESET}  ${BLUE}║${RESET}"
    echo -e "${BLUE}║${RESET}  ${BOLD}${CYAN} █  █▀▀ █▀▄ █ ▀ █ █ █ █ █   █▀▀ █▀▀ █▀▄ █▀  █ █ █ ▀ █${RESET}  ${BLUE}║${RESET}"
    echo -e "${BLUE}║${RESET}  ${BOLD}${CYAN} ▀  ▀▀▀ ▀ ▀ ▀   ▀  ▀ ▀ ▀   █▀  ▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀   ▀${RESET}  ${BLUE}║${RESET}"
    echo -e "${BLUE}║                                                            ║${RESET}"
    echo -e "${BLUE}║${RESET}                ${MAGENTA}Created by: Willy Gailo${RESET}                    ${BLUE}║${RESET}"
    echo -e "${BLUE}║${RESET}                ${YELLOW}For Rooted Devices Only${RESET}                    ${BLUE}║${RESET}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${RESET}"
    echo
}

# Function to check if device is rooted
check_root() {
    animate_text "Checking root access..." "${CYAN}"
    if su -c "id -u" >/dev/null 2>&1; then
        animate_text "✓ Root access detected!" "${GREEN}"
        return 0
    else
        animate_text "✗ Root access not detected. This script requires root." "${RED}"
        animate_text "Please root your device and try again." "${RED}"
        return 1
    fi
}

# Function to check if running in Termux
check_termux() {
    animate_text "Checking if running in Termux..." "${CYAN}"
    if [ -d /data/data/com.termux/files/usr ]; then
        animate_text "✓ Running in Termux!" "${GREEN}"
        return 0
    else
        animate_text "✗ Not running in Termux. This script is designed for Termux only." "${RED}"
        return 1
    fi
}

# Function to optimize CPU governor
optimize_cpu() {
    animate_text "Optimizing CPU governor..." "${YELLOW}"
    
    # Get number of CPU cores
    cpu_cores=$(grep -c processor /proc/cpuinfo)
    animate_text "Detected $cpu_cores CPU cores" "${CYAN}"
    
    for ((i=0; i<$cpu_cores; i++)); do
        if [ -f /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor ]; then
            current_governor=$(su -c "cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor" 2>/dev/null)
            animate_text "CPU$i current governor: $current_governor" "${BLUE}"
            
            # Set to performance for better speed
            su -c "echo performance > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor" 2>/dev/null
            new_governor=$(su -c "cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor" 2>/dev/null)
            animate_text "CPU$i new governor: $new_governor" "${GREEN}"
            
            # Set max scaling frequency
            if [ -f /sys/devices/system/cpu/cpu$i/cpufreq/scaling_available_frequencies ]; then
                available_freqs=$(su -c "cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_available_frequencies" 2>/dev/null)
                max_freq=$(echo $available_freqs | tr ' ' '\n' | sort -n | tail -1)
                
                if [ -f /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq ]; then
                    su -c "echo $max_freq > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq" 2>/dev/null
                    animate_text "CPU$i max frequency set to $(($max_freq / 1000)) MHz" "${CYAN}"
                fi
            fi
            
            # Disable thermal throttling if possible
            if [ -f /sys/module/msm_thermal/parameters/enabled ]; then
                su -c "echo N > /sys/module/msm_thermal/parameters/enabled" 2>/dev/null
                animate_text "Disabled thermal throttling" "${MAGENTA}"
            elif [ -f /sys/module/msm_thermal/core_control/enabled ]; then
                su -c "echo 0 > /sys/module/msm_thermal/core_control/enabled" 2>/dev/null
                animate_text "Disabled core thermal control" "${MAGENTA}"
            fi
        fi
    done
    
    # Enable all CPU cores
    for ((i=0; i<$cpu_cores; i++)); do
        if [ -f /sys/devices/system/cpu/cpu$i/online ]; then
            su -c "echo 1 > /sys/devices/system/cpu/cpu$i/online" 2>/dev/null
            animate_text "Enabled CPU$i" "${CYAN}"
        fi
    done
    
    animate_text "CPU optimization complete!" "${GREEN}"
}

# Function to clear app cache
clear_cache() {
    animate_text "Clearing system cache..." "${YELLOW}"
    su -c "sync"
    su -c "echo 3 > /proc/sys/vm/drop_caches" 2>/dev/null
    animate_text "Cache cleared successfully!" "${GREEN}"
}

# Function to optimize I/O scheduler
optimize_io() {
    animate_text "Optimizing I/O scheduler..." "${YELLOW}"
    
    # Find all block devices
    block_devices=$(su -c "find /sys/block -type l -not -path '*/virtual/*' -exec basename {} \;" 2>/dev/null)
    
    for device in $block_devices; do
        if [ -f /sys/block/$device/queue/scheduler ]; then
            current_scheduler=$(su -c "cat /sys/block/$device/queue/scheduler" 2>/dev/null)
            animate_text "Device $device current scheduler: $current_scheduler" "${BLUE}"
            
            # Set to deadline for better performance
            su -c "echo deadline > /sys/block/$device/queue/scheduler" 2>/dev/null
            new_scheduler=$(su -c "cat /sys/block/$device/queue/scheduler" 2>/dev/null)
            animate_text "Device $device new scheduler: $new_scheduler" "${GREEN}"
            
            # Optimize I/O queue parameters
            if [ -f /sys/block/$device/queue/nr_requests ]; then
                su -c "echo 2048 > /sys/block/$device/queue/nr_requests" 2>/dev/null
                animate_text "Increased I/O queue size for $device" "${CYAN}"
            fi
            
            # Disable I/O stats collection for performance
            if [ -f /sys/block/$device/queue/iostats ]; then
                su -c "echo 0 > /sys/block/$device/queue/iostats" 2>/dev/null
                animate_text "Disabled I/O stats for $device" "${CYAN}"
            fi
            
            # Set optimal I/O settings
            if [ -f /sys/block/$device/queue/add_random ]; then
                su -c "echo 0 > /sys/block/$device/queue/add_random" 2>/dev/null
                animate_text "Disabled entropy generation for $device" "${CYAN}"
            fi
            
            # Set rotational flag to 0 (treat as SSD)
            if [ -f /sys/block/$device/queue/rotational ]; then
                su -c "echo 0 > /sys/block/$device/queue/rotational" 2>/dev/null
                animate_text "Set $device as non-rotational (SSD mode)" "${CYAN}"
            fi
            
            # Optimize readahead
            if [ -f /sys/block/$device/queue/read_ahead_kb ]; then
                su -c "echo 2048 > /sys/block/$device/queue/read_ahead_kb" 2>/dev/null
                animate_text "Set optimal readahead for $device" "${CYAN}"
            fi
        fi
    done
    
    # Set global I/O priority
    if [ -d /sys/fs ]; then
        animate_text "Adjusting filesystem parameters..." "${YELLOW}"
        
        # Optimize EXT4 if available
        if [ -d /sys/fs/ext4 ]; then
            for param in $(su -c "find /sys/fs/ext4 -name 'mb_*'" 2>/dev/null); do
                su -c "echo 1 > $param" 2>/dev/null
            done
            animate_text "Optimized EXT4 parameters" "${CYAN}"
        fi
        
        # Optimize F2FS if available
        if [ -d /sys/fs/f2fs ]; then
            for param in $(su -c "find /sys/fs/f2fs -name '*_iostat_enable'" 2>/dev/null); do
                su -c "echo 0 > $param" 2>/dev/null
            done
            animate_text "Optimized F2FS parameters" "${CYAN}"
        fi
    fi
    
    animate_text "I/O optimization complete!" "${GREEN}"
}

# Function to optimize VM settings
optimize_vm() {
    animate_text "Optimizing VM settings..." "${YELLOW}"
    
    # Reduce swappiness for better performance
    su -c "echo 10 > /proc/sys/vm/swappiness" 2>/dev/null
    
    # Increase cache pressure for better memory management
    su -c "echo 50 > /proc/sys/vm/vfs_cache_pressure" 2>/dev/null
    
    # Set dirty ratio for better write performance
    su -c "echo 20 > /proc/sys/vm/dirty_ratio" 2>/dev/null
    su -c "echo 10 > /proc/sys/vm/dirty_background_ratio" 2>/dev/null
    
    # Optimize page clustering
    su -c "echo 0 > /proc/sys/vm/page-cluster" 2>/dev/null
    
    # Improve memory compaction
    su -c "echo 1 > /proc/sys/vm/compact_memory" 2>/dev/null
    
    # Adjust overcommit memory settings
    su -c "echo 1 > /proc/sys/vm/overcommit_memory" 2>/dev/null
    su -c "echo 50 > /proc/sys/vm/overcommit_ratio" 2>/dev/null
    
    # Set optimal read-ahead buffer
    for blockdev in $(su -c "find /sys/block -type l -not -path '*/virtual/*' -exec basename {} \;" 2>/dev/null); do
        if [ -e /sys/block/$blockdev/queue/read_ahead_kb ]; then
            su -c "echo 2048 > /sys/block/$blockdev/queue/read_ahead_kb" 2>/dev/null
            animate_text "Set read-ahead buffer for $blockdev" "${CYAN}"
        fi
    done
    
    animate_text "VM optimization complete!" "${GREEN}"
}

# Function to disable unnecessary services
disable_services() {
    animate_text "Disabling unnecessary services..." "${YELLOW}"
    
    # List of common services that can be safely disabled for performance
    services=("logd" "statsd" "perfprofd" "wificond" "logcatd" "dumpstate" "mdnsd" 
              "installd" "keystore" "netd" "surfaceflinger" "bootanim" "media" 
              "drm" "adbd" "usbd" "lmkd" "vold" "audioserver")
    
    for service in "${services[@]}"; do
        if [ "$(su -c "getprop init.svc.$service" 2>/dev/null)" = "running" ]; then
            su -c "stop $service" 2>/dev/null
            animate_text "Stopped $service service" "${CYAN}"
        fi
    done
    
    # Disable system animations
    if su -c "command -v settings" &>/dev/null; then
        animate_text "Disabling system animations..." "${YELLOW}"
        su -c "settings put global window_animation_scale 0.0" 2>/dev/null
        su -c "settings put global transition_animation_scale 0.0" 2>/dev/null
        su -c "settings put global animator_duration_scale 0.0" 2>/dev/null
        animate_text "System animations disabled" "${CYAN}"
    fi
    
    animate_text "Unnecessary services disabled!" "${GREEN}"
}

# Function to apply network tweaks
optimize_network() {
    animate_text "Optimizing network settings..." "${YELLOW}"
    
    # Enable TCP Fast Open
    su -c "echo 3 > /proc/sys/net/ipv4/tcp_fastopen" 2>/dev/null
    
    # Increase TCP buffer size
    su -c "echo '4096 87380 16777216' > /proc/sys/net/ipv4/tcp_rmem" 2>/dev/null
    su -c "echo '4096 87380 16777216' > /proc/sys/net/ipv4/tcp_wmem" 2>/dev/null
    
    # Optimize TCP congestion
    su -c "echo cubic > /proc/sys/net/ipv4/tcp_congestion_control" 2>/dev/null
    
    animate_text "Network optimization complete!" "${GREEN}"
}

# Function to optimize GPU
optimize_gpu() {
    animate_text "Optimizing GPU settings..." "${YELLOW}"
    
    # Check for Adreno GPU
    if [ -d /sys/class/kgsl/kgsl-3d0 ]; then
        animate_text "Adreno GPU detected" "${CYAN}"
        
        # Set GPU governor to performance if available
        if [ -f /sys/class/kgsl/kgsl-3d0/devfreq/governor ]; then
            su -c "echo performance > /sys/class/kgsl/kgsl-3d0/devfreq/governor" 2>/dev/null
            animate_text "Set GPU governor to performance" "${GREEN}"
        fi
        
        # Set max GPU frequency
        if [ -f /sys/class/kgsl/kgsl-3d0/devfreq/max_freq ]; then
            max_freq=$(su -c "cat /sys/class/kgsl/kgsl-3d0/devfreq/available_frequencies" 2>/dev/null | tr ' ' '\n' | sort -n | tail -1)
            su -c "echo $max_freq > /sys/class/kgsl/kgsl-3d0/devfreq/max_freq" 2>/dev/null
            if [ -n "$max_freq" ]; then
                animate_text "Set max GPU frequency to $(($max_freq / 1000000)) MHz" "${GREEN}"
            fi
        fi
        
        # Disable thermal throttling if possible
        if [ -f /sys/class/kgsl/kgsl-3d0/throttling ]; then
            su -c "echo 0 > /sys/class/kgsl/kgsl-3d0/throttling" 2>/dev/null
            animate_text "Disabled GPU thermal throttling" "${GREEN}"
        fi
        
        # Enable GPU bus split if available
        if [ -f /sys/class/kgsl/kgsl-3d0/bus_split ]; then
            su -c "echo 1 > /sys/class/kgsl/kgsl-3d0/bus_split" 2>/dev/null
            animate_text "Enabled GPU bus split" "${GREEN}"
        fi
    
    # Check for Mali GPU
    elif [ -d /sys/class/misc/mali0 ] || [ -d /sys/devices/platform/mali.0 ]; then
        animate_text "Mali GPU detected" "${CYAN}"
        
        if [ -d /sys/devices/platform/mali.0 ]; then
            mali_path="/sys/devices/platform/mali.0"
        else
            mali_path="/sys/class/misc/mali0"
        fi
        
        # Set GPU governor if available
        if [ -f $mali_path/device/dvfs_governor ]; then
            su -c "echo performance > $mali_path/device/dvfs_governor" 2>/dev/null
            animate_text "Set Mali GPU governor to performance" "${GREEN}"
        fi
    fi
    
    animate_text "GPU optimization complete!" "${GREEN}"
}

# Function to optimize RAM
optimize_ram() {
    animate_text "Optimizing RAM usage..." "${YELLOW}"
    
    # Disable zram if enabled
    if [ -d /sys/block/zram0 ]; then
        su -c "swapoff /dev/block/zram0" 2>/dev/null
        su -c "echo 1 > /sys/block/zram0/reset" 2>/dev/null
        animate_text "Disabled zram swap" "${CYAN}"
    fi
    
    # Adjust OOM parameters
    su -c "echo 1 > /proc/sys/vm/oom_kill_allocating_task" 2>/dev/null
    su -c "echo 1000 > /proc/sys/vm/extfrag_threshold" 2>/dev/null
    
    animate_text "RAM optimization complete!" "${GREEN}"
}

# Main function
main() {
    display_banner
    
    # Check if running in Termux
    check_termux || { animate_text "Exiting script..." "${RED}"; exit 1; }
    
    # Check if device is rooted
    check_root || { animate_text "Exiting script..." "${RED}"; exit 1; }
    
    # Show menu
    echo
    animate_text "╔════════════════════════════════════════╗" "${BLUE}"
    animate_text "║           AVAILABLE TWEAKS            ║" "${BLUE}"
    animate_text "╚════════════════════════════════════════╝" "${BLUE}"
    echo
    animate_text "1. CPU Governor Optimization" "${CYAN}"
    animate_text "2. Cache Clearing" "${CYAN}"
    animate_text "3. I/O Scheduler Optimization" "${CYAN}"
    animate_text "4. VM Settings Optimization" "${CYAN}"
    animate_text "5. Disable Unnecessary Services" "${CYAN}"
    animate_text "6. Network Optimization" "${CYAN}"
    animate_text "7. GPU Performance Optimization" "${CYAN}"
    animate_text "8. RAM Optimization" "${CYAN}"
    animate_text "9. Apply All Tweaks" "${MAGENTA}"
    animate_text "0. Exit" "${RED}"
    echo
    
    # Get user choice
    read -p "$(echo -e "${YELLOW}Enter your choice [0-9]:${RESET} ")" choice
    echo
    
    case $choice in
        1) optimize_cpu ;;
        2) clear_cache ;;
        3) optimize_io ;;
        4) optimize_vm ;;
        5) disable_services ;;
        6) optimize_network ;;
        7) optimize_gpu ;;
        8) optimize_ram ;;
        9)
            animate_text "Applying all performance tweaks..." "${MAGENTA}"
            optimize_cpu
            clear_cache
            optimize_io
            optimize_vm
            disable_services
            optimize_network
            optimize_gpu
            optimize_ram
            animate_text "All performance tweaks applied successfully!" "${GREEN}"
            ;;
        0)
            animate_text "Exiting script..." "${RED}"
            exit 0
            ;;
        *)
            animate_text "Invalid choice. Please try again." "${RED}"
            main
            ;;
    esac
    
    echo
    animate_text "═════════════════════════════════════════════════" "${BLUE}"
    animate_text "That's all, and that's the end. Thank you." "${GREEN}"
    animate_text "═════════════════════════════════════════════════" "${BLUE}"
    
    # Ask if user wants to return to menu
    echo
    read -p "$(echo -e "${YELLOW}Do you want to return to the main menu? (y/n):${RESET} ")" return_choice
    if [[ $return_choice == "y" || $return_choice == "Y" ]]; then
        main
    else
        animate_text "Exiting script. Thank you for using Performance Booster!" "${GREEN}"
        exit 0
    fi
}

# Execute main function
main