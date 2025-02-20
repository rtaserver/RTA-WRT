#!/bin/bash

# Enable strict mode for better error handling
set -euo pipefail
IFS=$'\n\t'

# Global variables for configuration with improved type declaration
declare -A CONFIG
CONFIG=(
    ["MAX_RETRIES"]=3
    ["RETRY_DELAY"]=2
    ["SPINNER_INTERVAL"]=0.1
    ["DEBUG"]=false
    ["TEMP_DIR"]="/tmp/script-$$"  # Add process-specific temp directory
    ["LOG_DIR"]="/var/log/script"  # Add dedicated log directory
)

# Create necessary directories
mkdir -p "${CONFIG[TEMP_DIR]}" "${CONFIG[LOG_DIR]}"

# Cleanup function
cleanup() {
    printf "\e[?25h"  # Ensure cursor is visible
    rm -rf "${CONFIG[TEMP_DIR]}"
    kill $(jobs -p) 2>/dev/null || true
}

# Set up cleanup trap
trap cleanup EXIT

# Enhanced color setup with dynamic terminal capability detection
setup_colors() {
    if [ -t 1 ] && tput colors &>/dev/null && [ "$(tput colors)" -ge 8 ]; then
        PURPLE=$(tput setaf 5)
        BLUE=$(tput setaf 4)
        GREEN=$(tput setaf 2)
        YELLOW=$(tput setaf 3)
        RED=$(tput setaf 1)
        MAGENTA=$(tput setaf 5)
        CYAN=$(tput setaf 6)
        RESET=$(tput sgr0)
        BOLD=$(tput bold)
        UL=$(tput smul)
    else
        PURPLE="" BLUE="" GREEN="" YELLOW="" RED="" MAGENTA="" CYAN="" RESET="" BOLD="" UL=""
    fi

    # Export readonly variables for logging
    readonly STEPS="[${PURPLE}STEPS${RESET}]"
    readonly INFO="[${BLUE}INFO${RESET}]"
    readonly SUCCESS="[${GREEN}SUCCESS${RESET}]"
    readonly WARNING="[${YELLOW}WARNING${RESET}]"
    readonly ERROR="[${RED}ERROR${RESET}]"
    readonly BFR="\\r\\033[K"
    readonly HOLD=" "
    readonly TAB="  "
}

# Enhanced logging function
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_file="${CONFIG[LOG_DIR]}/script.log"
    
    # Ensure log directory exists
    mkdir -p "$(dirname "$log_file")"
    
    # Write to log file
    echo "[$timestamp] [$level] $message" >> "$log_file"
    
    # Output to console if not in quiet mode
    case "$level" in
        "ERROR")   echo -e "${ERROR} $message" >&2 ;;
        "WARNING") echo -e "${WARNING} $message" ;;
        "SUCCESS") echo -e "${SUCCESS} $message" ;;
        "INFO")    echo -e "${INFO} $message" ;;
        *)         echo -e "${INFO} $message" ;;
    esac
}

# Enhanced spinner with better process management
spinner() {
    local pid=$1
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local colors=("\033[31m" "\033[33m" "\033[32m" "\033[36m" "\033[34m" "\033[35m")
    
    printf "\e[?25l"  # Hide cursor
    
    while kill -0 $pid 2>/dev/null; do
        for ((i = 0; i < ${#frames[@]}; i++)); do
            printf "\r ${colors[i]}%s${RESET}" "${frames[i]}"
            sleep "${CONFIG[SPINNER_INTERVAL]}"
        done
    done
    
    printf "\e[?25h"  # Show cursor
    wait $pid  # Wait for process to finish and get exit status
    return $?
}

# Enhanced command installation with better error handling
cmdinstall() {
    local cmd="$1"
    local desc="${2:-$cmd}"
    local log_file="${CONFIG[TEMP_DIR]}/cmdinstall-$(date +%s).log"
    
    log "INFO" "Installing: $desc"
    
    # Run command in background and capture PID
    eval "$cmd" > "$log_file" 2>&1 &
    local cmd_pid=$!
    
    # Start spinner
    spinner $cmd_pid
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        log "SUCCESS" "$desc installed successfully"
        [ "${CONFIG[DEBUG]}" = true ] && cat "$log_file"
    else
        log "ERROR" "Failed to install $desc"
        cat "$log_file"
        return 1
    fi
}

# Enhanced dependency checking with version comparison
check_dependencies() {
    local -A dependencies=(
        ["aria2"]="aria2c --version | grep -oP 'aria2 version \K[\d\.]+'"
        ["curl"]="curl --version | grep -oP 'curl \K[\d\.]+'"
        ["tar"]="tar --version | grep -oP 'tar \K[\d\.]+'"
        ["gzip"]="gzip --version | grep -oP 'gzip \K[\d\.]+'"
        ["unzip"]="unzip -v | grep -oP 'UnZip \K[\d\.]+'"
        ["git"]="git --version | grep -oP 'git version \K[\d\.]+'"
        ["wget"]="wget --version | grep -oP 'GNU Wget \K[\d\.]+'"
    )
    
    log "STEPS" "Checking system dependencies..."
    
    # Update package lists with error handling
    if ! sudo apt-get update -qq &>/dev/null; then
        log "ERROR" "Failed to update package lists"
        return 1
    fi
    
    for pkg in "${!dependencies[@]}"; do
        local version_cmd="${dependencies[$pkg]}"
        local installed_version
        
        if ! installed_version=$(eval "$version_cmd" 2>/dev/null); then
            log "WARNING" "Installing $pkg..."
            if ! sudo apt-get install -y "$pkg" &>/dev/null; then
                log "ERROR" "Failed to install $pkg"
                return 1
            fi
            installed_version=$(eval "$version_cmd")
            log "SUCCESS" "Installed $pkg version $installed_version"
        else
            log "SUCCESS" "Found $pkg version $installed_version"
        fi
    done
    
    log "SUCCESS" "All dependencies are satisfied!"
}

# Enhanced download function with retry mechanism and better error handling
ariadl() {
    local url="$1"
    local output="${2:-$(basename "$url")}"
    local output_dir="$(dirname "$output")"
    local retry_count=0
    local temp_file="${CONFIG[TEMP_DIR]}/$(basename "$output").tmp"
    
    # Validate URL
    if ! curl --output /dev/null --silent --head --fail "$url"; then
        log "ERROR" "Invalid URL: $url"
        return 1
    fi
    
    # Create output directory
    mkdir -p "$output_dir" || {
        log "ERROR" "Failed to create output directory: $output_dir"
        return 1
    }
    
    log "STEPS" "Downloading ${url##*/}..."
    
    while [ $retry_count -lt "${CONFIG[MAX_RETRIES]}" ]; do
        log "INFO" "Attempt $((retry_count + 1))/${CONFIG[MAX_RETRIES]}"
        
        if aria2c --quiet \
                 --max-tries=3 \
                 --retry-wait=3 \
                 --dir="$(dirname "$temp_file")" \
                 --out="$(basename "$temp_file")" \
                 --continue=true \
                 "$url"; then
            
            # Verify download
            if [ -f "$temp_file" ] && [ -s "$temp_file" ]; then
                mv "$temp_file" "$output"
                log "SUCCESS" "Download complete: ${output##*/}"
                return 0
            fi
        fi
        
        ((retry_count++))
        [ $retry_count -lt "${CONFIG[MAX_RETRIES]}" ] && {
            log "WARNING" "Retrying in ${CONFIG[RETRY_DELAY]} seconds..."
            sleep "${CONFIG[RETRY_DELAY]}"
        }
    done
    
    log "ERROR" "Failed to download after ${CONFIG[MAX_RETRIES]} attempts: ${url##*/}"
    return 1
}

# Enhanced package downloader with improved URL handling and validation
download_packages() {
    local source="$1"
    shift
    local -a package_list=("$@")
    
    log "STEPS" "Downloading packages from $source..."
    mkdir -p packages
    
    case "$source" in
        github)
            for entry in "${package_list[@]}"; do
                IFS="|" read -r filename base_url <<< "$entry"
                
                # Use GitHub API if possible
                if [[ "$base_url" =~ ^https://github.com ]]; then
                    local api_url="${base_url/github.com/api.github.com/repos}/releases/latest"
                    local latest_url=$(curl -s -H "Accept: application/vnd.github.v3+json" "$api_url" | \
                                     grep -oP '"browser_download_url": "\K[^"]*\.(?:ipk|apk)"' | \
                                     grep "$filename" | head -1)
                    
                    if [ -n "$latest_url" ]; then
                        ariadl "$latest_url" "packages/$(basename "$latest_url")"
                    else
                        log "ERROR" "No matching package found: $filename"
                    fi
                else
                    log "ERROR" "Invalid GitHub URL: $base_url"
                fi
            done
            ;;
            
        custom)
            for entry in "${package_list[@]}"; do
                IFS="|" read -r filename base_url <<< "$entry"
                
                # Improved pattern matching
                local patterns=(
                    "${filename}[^\"]*\.(ipk|apk)"
                    "${filename}_.*\.(ipk|apk)"
                    "${filename}.*\.(ipk|apk)"
                )
                
                local found_url=""
                for pattern in "${patterns[@]}"; do
                    found_url=$(curl -sL "$base_url" | \
                              grep -oP "(?<=\")${pattern}(?=\")" | \
                              sort -V | \
                              tail -n 1)
                    
                    if [ -n "$found_url" ]; then
                        ariadl "${base_url}/${found_url}" "packages/$(basename "$found_url")"
                        break
                    fi
                done
                
                [ -z "$found_url" ] && log "ERROR" "No matching file found: $filename"
            done
            ;;
            
        *)
            log "ERROR" "Invalid source: $source"
            return 1
            ;;
    esac
}

# Initialize the script
setup_colors
main() {
    check_dependencies || exit 1
    # Add your main script logic here
}

# Run main function if script is not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
