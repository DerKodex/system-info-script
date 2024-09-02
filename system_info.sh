#!/bin/bash

# Color definitions
COLOR_RESET="\033[0m"
COLOR_KEY="\033[94m"
COLOR_VALUE="\033[97m"
COLOR_COLON="\033[33m"
COLOR_IDENT="\033[32m"
COLOR_AT="\033[37m"
COLOR_WARNING="\033[91m"

# Detect OS
case "$(uname -s)" in
    Linux*)     OS=Linux;;
    Darwin*)    OS=Mac;;
    CYGWIN*)    OS=Cygwin;;
    MINGW*)     OS=MinGw;;
    *)          OS="UNKNOWN:${unameOut}"
esac

os() {
    case $OS in
        Linux)
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                echo "$NAME $VERSION"
            elif [ -f /etc/lsb-release ]; then
                . /etc/lsb-release
                echo "$DISTRIB_DESCRIPTION"
            else
                echo "Linux (Unknown Distribution)"
            fi
            ;;
        Mac)
            echo "macOS $(sw_vers -productVersion)"
            ;;
        Cygwin|MinGw)
            echo "Windows $(wmic os get Version /value | grep -o '[0-9.]*')"
            ;;
        *)
            echo "Unknown OS"
            ;;
    esac
}

kernel() {
    uname -rmo
}

machine() {
    case $OS in
        Linux)
            hostnamectl 2>/dev/null | awk '/Hardware Vendor|Hardware Model/ {print $3, $4, $5}' | xargs
            ;;
        Mac)
            sysctl -n hw.model
            ;;
        Cygwin|MinGw)
            wmic computersystem get manufacturer,model /format:list | sed 's/Manufacturer=//' | sed 's/Model=//' | xargs
            ;;
        *)
            echo "Unknown Machine"
            ;;
    esac
}

up() {
    case $OS in
        Linux)
            uptime -p
            ;;
        Mac)
            boot_time=$(sysctl -n kern.boottime | awk '{print $4}' | sed 's/,//')
            current_time=$(date +%s)
            uptime=$((current_time - boot_time))
            echo "up $(printf '%d days, %d:%02d' $((uptime/86400)) $((uptime%86400/3600)) $((uptime%3600/60)))"
            ;;
        Cygwin|MinGw)
            uptime=$(powershell.exe -command "get-computerinfo | select-object OSUptime | select-object -expandproperty OSUptime")
            echo "up $(printf '%d days, %d:%02d' $((uptime/86400)) $((uptime%86400/3600)) $((uptime%3600/60)))"
            ;;
        *)
            echo "Unknown Uptime"
            ;;
    esac
}

desktop() {
    case $OS in
        Linux)
            echo "${XDG_CURRENT_DESKTOP:-$DESKTOP_SESSION}"
            ;;
        Mac)
            echo "Aqua"
            ;;
        Cygwin|MinGw)
            echo "Windows Explorer"
            ;;
        *)
            echo "Unknown Desktop"
            ;;
    esac
}

shell() {
    echo "$SHELL ($(basename $SHELL) version $($SHELL --version 2>&1 | head -n1 | awk '{print $NF}'))"
}

resolution() {
    case $OS in
        Linux)
            if command -v xrandr >/dev/null 2>&1; then
                xrandr --current | grep '*' | uniq | awk '{print $1}' | paste -sd ', '
            else
                echo "N/A (xrandr not available)"
            fi
            ;;
        Mac)
            system_profiler SPDisplaysDataType 2>/dev/null | awk '/Resolution:/ {printf "%s, ", $2 " " $3 " " $4}' | sed 's/, $//'
            ;;
        Cygwin|MinGw)
            wmic path Win32_VideoController get CurrentHorizontalResolution,CurrentVerticalResolution /format:value | sed -n 's/.*=//p' | paste -sd 'x' | sed 's/\r//'
            ;;
        *)
            echo "Unknown Resolution"
            ;;
    esac
}

pkgs() {
    case $OS in
        Linux)
            PKGS=""
            command -v dpkg >/dev/null 2>&1 && PKGS+="dpkg($(dpkg --get-selections | wc -l)) "
            command -v rpm >/dev/null 2>&1 && PKGS+="rpm($(rpm -qa | wc -l)) "
            command -v pacman >/dev/null 2>&1 && PKGS+="pacman($(pacman -Qq | wc -l)) "
            command -v flatpak >/dev/null 2>&1 && PKGS+="flatpak($(flatpak list | wc -l)) "
            command -v snap >/dev/null 2>&1 && PKGS+="snap($(snap list | wc -l)) "
            [ -z "$PKGS" ] && echo "N/A" || echo "$PKGS"
            ;;
        Mac)
            if command -v brew >/dev/null 2>&1; then
                echo "brew($(brew list | wc -l | xargs))"
            else
                echo "N/A (Homebrew not installed)"
            fi
            ;;
        Cygwin|MinGw)
            if command -v cygcheck >/dev/null 2>&1; then
                echo "cygwin($(cygcheck -cd | wc -l))"
            elif command -v pacman >/dev/null 2>&1; then
                echo "pacman($(pacman -Qq | wc -l))"
            else
                echo "N/A"
            fi
            ;;
        *)
            echo "Unknown Package Manager"
            ;;
    esac
}

cpu() {
    case $OS in
        Linux)
            grep "model name" /proc/cpuinfo | head -n1 | cut -d ':' -f2 | xargs
            ;;
        Mac)
            sysctl -n machdep.cpu.brand_string
            ;;
        Cygwin|MinGw)
            wmic cpu get name /value | sed -n 's/.*=//p' | sed 's/\r//'
            ;;
        *)
            echo "Unknown CPU"
            ;;
    esac
}

gpu() {
    case $OS in
        Linux)
            if command -v lspci >/dev/null 2>&1; then
                lspci | grep -i 'vga\|3d' | cut -d ':' -f3 | xargs
            else
                echo "N/A (lspci not available)"
            fi
            ;;
        Mac)
            system_profiler SPDisplaysDataType 2>/dev/null | awk '/Chipset Model:/ {print $3, $4, $5}' | paste -sd ', '
            ;;
        Cygwin|MinGw)
            wmic path win32_VideoController get name /value | sed -n 's/.*=//p' | sed 's/\r//'
            ;;
        *)
            echo "Unknown GPU"
            ;;
    esac
}

mem() {
    case $OS in
        Linux)
            free -m | awk '/Mem:/ {printf "%.2fGiB / %.2fGiB (%d%%)\n", $3/1024, $2/1024, $3*100/$2}'
            ;;
        Mac)
            total=$(sysctl -n hw.memsize)
            used=$(vm_stat | awk '/Pages active/ {print $3 * 4096}')
            total_gb=$((total / 1073741824))
            used_gb=$((used / 1073741824))
            percent=$((used * 100 / total))
            printf "%.2fGiB / %.2fGiB (%d%%)\n" $used_gb $total_gb $percent
            ;;
        Cygwin|MinGw)
            total=$(wmic computersystem get totalphysicalmemory /value | sed -n 's/.*=//p')
            free=$(wmic os get freephysicalmemory /value | sed -n 's/.*=//p')
            used=$((total - free))
            total_gb=$((total / 1073741824))
            used_gb=$((used / 1073741824))
            percent=$((used * 100 / total))
            printf "%.2fGiB / %.2fGiB (%d%%)\n" $used_gb $total_gb $percent
            ;;
        *)
            echo "Unknown Memory"
            ;;
    esac
}

disk() {
    df -h / | awk 'NR==2 {printf "%.2fGiB / %.2fGiB (%s, /)\n", $3, $2, $5}'
}

network() {
    case $OS in
        Linux)
            ip -4 addr show scope global | grep inet | awk '{print $2}' | cut -d'/' -f1 | paste -sd ', '
            ;;
        Mac)
            ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | paste -sd ', '
            ;;
        Cygwin|MinGw)
            ipconfig | grep IPv4 | cut -d: -f2 | xargs
            ;;
        *)
            echo "Unknown Network"
            ;;
    esac
}

log() {
    VAL=$(eval $2 2>/dev/null || echo "N/A")
    if [ -n "$VAL" ] && [ ! "$VAL" = "N/A" ]; then
        printf "${COLOR_KEY}%-12s${COLOR_COLON} : ${COLOR_VALUE}%s${COLOR_RESET}\n" "$1" "$VAL"
        return 0
    else
        printf "${COLOR_KEY}%-12s${COLOR_COLON} : ${COLOR_WARNING}%s${COLOR_RESET}\n" "$1" "$VAL"
        return 1
    fi
}

main() {
    HOSTNAME=${HOSTNAME:-${hostname:-$(hostname)}}
    USERNAME=${USER:-$(id -un)}
    printf "${COLOR_RESET}%-12s ${COLOR_IDENT}%s${COLOR_AT}@${COLOR_IDENT}%s${COLOR_RESET}\n" "" "${USERNAME:-"user"}" "${HOSTNAME:-"host"}"
    
    log "OS" "os"
    log "Kernel" "kernel"
    log "Machine" "machine"
    log "Uptime" "up"
    echo
    
    log "Desktop" "desktop"
    log "Shell" "shell"
    log "Resolution" "resolution"
    log "Packages" "pkgs"
    echo
    
    log "CPU" "cpu"
    log "GPU" "gpu"
    log "Memory" "mem"
    log "Disk" "disk"
    log "Network" "network"
    echo
}

main
