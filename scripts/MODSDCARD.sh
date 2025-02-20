#!/bin/bash
set -e  # Hentikan skrip jika terjadi error

. ./scripts/INCLUDE.sh

build_mod_sdcard() {
    local image_path="$1"
    local dtb="$2"
    local suffix="$3"

    log "STEPS" "Modifying boot files for Amlogic s905x devices..."

    # Validate input parameters
    if [ -z "$suffix" ] || [ -z "$dtb" ] || [ -z "$image_path" ]; then
        log "ERROR" "Missing required parameters. Usage: build_mod_sdcard <image_path> <dtb> <image_suffix>"
        return 1
    fi

    # Validate and set paths
    if ! cd "$GITHUB_WORKSPACE/$WORKING_DIR/compiled_images"; then
        log "ERROR" "Failed to change directory to compiled_images"
        return 1
    fi

    local file_to_process="$image_path"

    cleanup() {
        log "INFO" "Cleaning up temporary files..."
        sudo umount boot 2>/dev/null || true
        sudo losetup -D 2>/dev/null || true
    }

    trap cleanup EXIT

    if [ ! -f "$file_to_process" ]; then
        log "ERROR" "Image file not found: ${file_to_process}"
        return 1
    fi

    # Download modification files
    ariadl "https://github.com/rizkikotet-dev/mod-boot-sdcard/archive/refs/heads/main.zip" "main.zip"

    # Extract files
    log "INFO" "Extracting mod-boot-sdcard..."
    unzip -q main.zip || { log "ERROR" "Failed to extract mod-boot-sdcard"; return 1; }
    rm -f main.zip
    echo -e "${SUCCESS} mod-boot-sdcard successfully extracted."
    sleep 3

    # Create working directory
    mkdir -p "${suffix}/boot"

    # Copy required files
    log "INFO" "Preparing image for ${suffix}..."
    cp "$file_to_process" "${suffix}/"
    sudo cp mod-boot-sdcard-main/BootCardMaker/u-boot.bin \
        mod-boot-sdcard-main/files/mod-boot-sdcard.tar.gz "${suffix}/" || {
        log "ERROR" "Failed to copy bootloader or modification files"
        return 1
    }

    # Process the image
    cd "${suffix}" || { log "ERROR" "Failed to change directory to ${suffix}"; return 1; }

    local file_name=$(basename "${file_to_process}" .gz)

    # Decompress the OpenWRT image
    sudo gunzip "${file_name}.gz" || { log "ERROR" "Failed to decompress image"; return 1; }

    # Set up loop device
    log "INFO" "Setting up loop device..."
    local device=$(sudo losetup -fP --show "${file_name}" 2>/dev/null)
    if [ -z "$device" ]; then
        log "ERROR" "Failed to set up loop device"
        return 1
    fi

    # Mount the image
    log "INFO" "Mounting the image..."
    if ! sudo mount "${device}p1" boot; then
        log "ERROR" "Failed to mount image"
        return 1
    fi

    # Apply modifications
    log "INFO" "Applying boot modifications..."
    sudo tar -xzf mod-boot-sdcard.tar.gz -C boot || {
        log "ERROR" "Failed to extract boot modifications"
        return 1
    }

    # Update configuration files
    log "INFO" "Updating configuration files..."
    local uenv=$(grep "APPEND" boot/uEnv.txt | awk -F "root=" '{print $2}')
    local extlinux=$(grep "append" boot/extlinux/extlinux.conf | awk -F "root=" '{print $2}')
    local boot=$(sudo grep -oP '(?<=dtb=)[^"]+' boot/boot.ini)

    sudo sed -i "s|$extlinux|$uenv|g" boot/extlinux/extlinux.conf
    sudo sed -i "s|$boot|$dtb|g" boot/boot.ini
    sudo sed -i "s|$boot|$dtb|g" boot/extlinux/extlinux.conf
    sudo sed -i "s|$boot|$dtb|g" boot/uEnv.txt

    sync
    sudo umount boot

    # Write bootloader
    log "INFO" "Writing bootloader..."
    sudo dd if=u-boot.bin of="${device}" bs=1 count=444 conv=fsync 2>/dev/null
    sudo dd if=u-boot.bin of="${device}" bs=512 skip=1 seek=1 conv=fsync 2>/dev/null || {
        log "ERROR" "Failed to write bootloader"
        return 1
    }

    # Detach loop device and compress
    sudo losetup -d "${device}"
    sudo gzip "${file_name}" || { log "ERROR" "Failed to compress image"; return 1; }

    [ -f "../${file_name}.gz" ] && rm -rf "../${file_name}.gz"
    mv "${file_name}.gz" "../${file_name}.gz" || {
        log "ERROR" "Failed to rename image file"
        return 1
    }

    cd ..
    rm -rf "${suffix}"
    rm -rf mod-boot-sdcard-main
    echo -e "${SUCCESS} Successfully processed ${suffix}"
    return 0
}

# Main execution
main() {
    local exit_code=0
    
    build_mod_sdcard "$(find "$GITHUB_WORKSPACE/$WORKING_DIR/compiled_images" -name "*_s905x_k5.15*.img.gz")" "meson-gxl-s905x-p212.dtb" "HG680P"
    build_mod_sdcard "$(find "$GITHUB_WORKSPACE/$WORKING_DIR/compiled_images" -name "*_s905x_k6.6*.img.gz")" "meson-gxl-s905x-p212.dtb" "HG680P"
    build_mod_sdcard "$(find "$GITHUB_WORKSPACE/$WORKING_DIR/compiled_images" -name "*_s905x-b860h_k5.15*.img.gz")" "meson-gxl-s905x-b860h.dtb" "B860H_v1-v2"
    build_mod_sdcard "$(find "$GITHUB_WORKSPACE/$WORKING_DIR/compiled_images" -name "*_s905x-b860h_k6.6*.img.gz")" "meson-gxl-s905x-b860h.dtb" "B860H_v1-v2"

    return $exit_code
}

main
