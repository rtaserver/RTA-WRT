#!/bin/bash

. ./scripts/INCLUDE.sh

# Constants
readonly REQUIRED_COMMANDS=("dd" "losetup" "mount" "gzip" "tar" "unzip" "sed")
readonly MOD_BOOT_URL="https://github.com/rizkikotet-dev/mod-boot-sdcard/archive/refs/heads/main.zip"
readonly MAX_RETRIES=3
readonly MOUNT_TIMEOUT=5

# Helper functions
check_dependencies() {
    local missing_deps=()
    for cmd in "${REQUIRED_COMMANDS[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        error_msg "Missing required dependencies: ${missing_deps[*]}"
        return 1
    fi
    return 0
}

wait_for_device() {
    local device="$1"
    local timeout="$2"
    local counter=0
    
    while [ ! -b "$device" ] && [ $counter -lt "$timeout" ]; do
        sleep 1
        counter=$((counter + 1))
    done
    
    [ -b "$device" ]
}

safe_mount() {
    local device="$1"
    local mount_point="$2"
    local retries=0
    
    while [ $retries -lt $MAX_RETRIES ]; do
        if sudo mount "$device" "$mount_point"; then
            return 0
        fi
        sleep 1
        retries=$((retries + 1))
    done
    return 1
}

build_mod_sdcard() {
    local image_path="$1"
    local dtb="$2"
    local suffix="$3"

    echo -e "${STEPS} Modifying boot files for Amlogic s905x devices..."
    
    # Parameter validation with detailed error messages
    if [ -z "$image_path" ]; then
        error_msg "Image path parameter is missing"
        return 1
    elif [ -z "$dtb" ]; then
        error_msg "DTB parameter is missing"
        return 1
    elif [ -z "$suffix" ]; then
        error_msg "Suffix parameter is missing"
        return 1
    fi

    # Check dependencies first
    if ! check_dependencies; then
        return 1
    }

    # Validate and set paths with error handling
    local work_dir="$GITHUB_WORKSPACE/$WORKING_DIR/compiled_images"
    if ! cd "$work_dir"; then
        error_msg "Failed to access working directory: $work_dir"
        return 1
    fi

    local file_to_process="$image_path"

    # Enhanced cleanup function
    cleanup() {
        echo -e "${INFO} Performing cleanup..."
        local mount_point="boot"
        if mountpoint -q "$mount_point"; then
            sudo umount "$mount_point" || error_msg "Failed to unmount $mount_point"
        fi
        sudo losetup -D || error_msg "Failed to detach all loop devices"
        for dir in "$suffix" "mod-boot-sdcard-main"; do
            [ -d "$dir" ] && rm -rf "$dir"
        done
        [ -f "main.zip" ] && rm -f "main.zip"
    }

    trap cleanup EXIT ERR

    # Validate input file
    if [ ! -f "$file_to_process" ]; then
        error_msg "Image file not found: $file_to_process"
        return 1
    fi

    # Download and extract with better error handling
    echo -e "${INFO} Downloading mod-boot-sdcard..."
    if ! ariadl "$MOD_BOOT_URL" "main.zip"; then
        error_msg "Failed to download mod-boot-sdcard"
        return 1
    fi

    echo -e "${INFO} Extracting mod-boot-sdcard..."
    if ! unzip -q main.zip; then
        error_msg "Failed to extract mod-boot-sdcard"
        rm -f main.zip
        return 1
    fi
    rm -f main.zip
    echo -e "${SUCCESS} mod-boot-sdcard extracted successfully"

    # Prepare working directory
    mkdir -p "${suffix}/boot"
    
    # Copy files with verification
    echo -e "${INFO} Preparing image for ${suffix}..."
    if ! cp "$file_to_process" "${suffix}/"; then
        error_msg "Failed to copy image file"
        return 1
    fi

    local bootloader="mod-boot-sdcard-main/BootCardMaker/u-boot.bin"
    local modboot="mod-boot-sdcard-main/files/mod-boot-sdcard.tar.gz"
    
    for file in "$bootloader" "$modboot"; do
        if ! [ -f "$file" ]; then
            error_msg "Required file not found: $file"
            return 1
        fi
        if ! sudo cp "$file" "${suffix}/"; then
            error_msg "Failed to copy: $file"
            return 1
        fi
    done

    # Process image
    cd "${suffix}" || {
        error_msg "Failed to enter working directory: ${suffix}"
        return 1
    }

    local file_name=$(basename "${file_to_process%.gz}")

    # Decompress with progress
    echo -e "${INFO} Decompressing image..."
    if ! sudo gunzip "${file_name}.gz"; then
        error_msg "Failed to decompress image"
        return 1
    fi

    # Setup loop device with improved handling
    echo -e "${INFO} Setting up loop device..."
    local device
    device=$(sudo losetup -fP --show "${file_name}" 2>/dev/null)
    
    if ! wait_for_device "$device" "$MOUNT_TIMEOUT"; then
        error_msg "Loop device setup failed or timed out"
        return 1
    fi

    # Mount with improved error handling
    echo -e "${INFO} Mounting image..."
    if ! safe_mount "${device}p1" boot; then
        error_msg "Failed to mount image after $MAX_RETRIES attempts"
        return 1
    fi

    # Apply modifications with verification
    echo -e "${INFO} Applying boot modifications..."
    if ! sudo tar -xzf mod-boot-sdcard.tar.gz -C boot; then
        error_msg "Failed to extract boot modifications"
        return 1
    fi

    # Update configuration with backup
    echo -e "${INFO} Updating configuration files..."
    for file in boot/uEnv.txt boot/extlinux/extlinux.conf boot/boot.ini; do
        if [ ! -f "$file" ]; then
            error_msg "Required configuration file missing: $file"
            return 1
        fi
        cp "$file" "${file}.backup"
    done

    local uenv=$(sudo cat boot/uEnv.txt | grep APPEND | awk -F "root=" '{print $2}')
    local extlinux=$(sudo cat boot/extlinux/extlinux.conf | grep append | awk -F "root=" '{print $2}')
    local boot=$(sudo cat boot/boot.ini | grep dtb | awk -F "/" '{print $4}' | cut -d'"' -f1)

    # Update configuration with error checking
    update_config() {
        local file="$1"
        local old="$2"
        local new="$3"
        
        if ! sudo sed -i "s|$old|$new|g" "$file"; then
            error_msg "Failed to update configuration in $file"
            return 1
        fi
    }

    update_config "boot/extlinux/extlinux.conf" "$extlinux" "$uenv"
    update_config "boot/boot.ini" "$boot" "$dtb"
    update_config "boot/extlinux/extlinux.conf" "$boot" "$dtb"
    update_config "boot/uEnv.txt" "$boot" "$dtb"

    sync
    sudo umount boot

    # Write bootloader with verification
    echo -e "${INFO} Writing bootloader..."
    if ! sudo dd if=u-boot.bin of="${device}" bs=1 count=444 conv=fsync 2>/dev/null; then
        error_msg "Failed to write primary bootloader"
        return 1
    fi
    if ! sudo dd if=u-boot.bin of="${device}" bs=512 skip=1 seek=1 conv=fsync 2>/dev/null; then
        error_msg "Failed to write secondary bootloader"
        return 1
    fi

    # Cleanup and compress
    sudo losetup -d "${device}"
    echo -e "${INFO} Compressing final image..."
    if ! sudo gzip "${file_name}"; then
        error_msg "Failed to compress final image"
        return 1
    fi

    # Move final image with verification
    [ -f "../${file_name}.gz" ] && rm -f "../${file_name}.gz"
    if ! mv "${file_name}.gz" "../${file_name}.gz"; then
        error_msg "Failed to move final image"
        return 1
    fi

    cd ..
    cleanup
    echo -e "${SUCCESS} Successfully processed ${suffix}"
    cd "$GITHUB_WORKSPACE/$WORKING_DIR"
    return 0
}

# Process images with error handling
process_images() {
    local kernel_version="$1"
    local dtb="$2"
    local suffix="$3"
    local pattern="*_${kernel_version}*.img.gz"
    
    local image_file
    image_file=$(find "$GITHUB_WORKSPACE/$WORKING_DIR/compiled_images" -name "$pattern")
    
    if [ -z "$image_file" ]; then
        error_msg "No matching image found for pattern: $pattern"
        return 1
    fi
    
    if ! build_mod_sdcard "$image_file" "$dtb" "$suffix"; then
        error_msg "Failed to process $suffix for kernel $kernel_version"
        return 1
    fi
}

# Main execution
main() {
    local exit_code=0
    
    # Process HG680P images
    process_images "s905x_k5.15" "meson-gxl-s905x-p212.dtb" "HG680P" || exit_code=1
    process_images "s905x_k6.6" "meson-gxl-s905x-p212.dtb" "HG680P" || exit_code=1

    # Process B860H v1/v2 images
    process_images "s905x-b860h_k5.15" "meson-gxl-s905x-b860h.dtb" "B860H_v1-v2" || exit_code=1
    process_images "s905x-b860h_k6.6" "meson-gxl-s905x-b860h.dtb" "B860H_v1-v2" || exit_code=1

    return $exit_code
}

main
