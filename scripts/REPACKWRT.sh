#!/bin/bash

. ./scripts/INCLUDE.sh

repackwrt() {
    # Parse arguments
    local builder_type=""
    local target_board=""
    local target_kernel=""
    local tunnel_type=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --ophub|--ulo)
                builder_type="$1"
                shift
                ;;
            -t|--target)
                target_board="$2"
                shift 2
                ;;
            -k|--kernel)
                target_kernel="$2"
                shift 2
                ;;
            -tn|--tunnel)
                tunnel_type="$2"
                shift 2
                ;;
            *)
                error_msg "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    # Validate required parameters
    if [[ -z "$builder_type" ]]; then
        error_msg "Builder type (--ophub or --ulo) is required"
        exit 1
    fi
    
    if [[ -z "$target_board" ]]; then
        error_msg "Target board (-t) is required"
        exit 1
    fi
    
    if [[ -z "$target_kernel" ]]; then
        error_msg "Target kernel (-k) is required"
        exit 1
    fi

    if [[ -z "$tunnel_type" ]]; then
        error_msg "Tunnel type (-tn) is required"
        exit 1
    fi

    # Define constants
    local readonly OPHUB_REPO="https://github.com/ophub/amlogic-s9xxx-openwrt/archive/refs/heads/main.zip"
    local readonly ULO_REPO="https://github.com/armarchindo/ULO-Builder/archive/refs/heads/main.zip"
    local readonly work_dir="$GITHUB_WORKSPACE/$WORKING_DIR"
    
    # Setup directories based on builder type
    local builder_dir output_dir repo_url
    if [[ "$builder_type" == "--ophub" ]]; then
        builder_dir="${work_dir}/amlogic-s9xxx-openwrt-main"
        repo_url="${OPHUB_REPO}"
        log "STEPS" "Starting firmware repackaging with Ophub..."
    else
        builder_dir="${work_dir}/ULO-Builder-main"
        repo_url="${ULO_REPO}"
        log "STEPS" "Starting firmware repackaging with UloBuilder..."
    fi

    output_dir="${work_dir}/compiled_images"

    # Navigate to working directory
    if ! cd "${work_dir}"; then
        error_msg "Failed to access working directory: ${work_dir}"
        exit 1
    fi

    # Download and extract builder
    if ! ariadl "${repo_url}" "main.zip"; then
        error_msg "Failed to download builder"
        exit 1
    fi

    if ! unzip -q main.zip; then
        error_msg "Failed to extract builder archive"
        rm -f main.zip
        exit 1
    fi
    rm -f main.zip

    # Prepare builder directory
    if [[ "$builder_type" == "--ophub" ]]; then
        mkdir -p "${builder_dir}/openwrt-armvirt"
    else
        mkdir -p "${builder_dir}/rootfs"
    fi

    # Find and validate rootfs file
    local rootfs_files=("${work_dir}/compiled_images/"*"_${tunnel_type}.tar.gz")
    if [[ ${#rootfs_files[@]} -ne 1 ]]; then
        error_msg "Expected exactly one rootfs file, found ${#rootfs_files[@]}"
        exit 1
    fi
    local rootfs_file="${rootfs_files[0]}"

    # Copy rootfs file
    log "INFO" "Copying rootfs file..."
    local target_path
    if [[ "$builder_type" == "--ophub" ]]; then
        target_path="${builder_dir}/openwrt-armvirt/${BASE}-armsr-armv8-generic-rootfs.tar.gz"
    else
        target_path="${builder_dir}/rootfs/${BASE}-armsr-armv8-generic-rootfs.tar.gz"
    fi

    if ! cp -f "${rootfs_file}" "${target_path}"; then
        error_msg "Failed to copy rootfs file"
        exit 1
    fi

    # Change to builder directory
    if ! cd "${builder_dir}"; then
        error_msg "Failed to access builder directory: ${builder_dir}"
        exit 1
    fi

    # Run builder-specific operations
    local device_output_dir
    if [[ "$builder_type" == "--ophub" ]]; then
        log "INFO" "Running OphubBuilder..."
        if ! sudo ./remake -b "${target_board}" -k "${target_kernel}" -s 1024; then
            error_msg "OphubBuilder execution failed"
            exit 1
        fi
        device_output_dir="./openwrt/out"
    else
        # Apply ULO patches
        log "INFO" "Applying UloBuilder patches..."
        if [[ -f "./.github/workflows/ULO_Workflow.patch" ]]; then
            mv ./.github/workflows/ULO_Workflow.patch ./ULO_Workflow.patch
            if ! patch -p1 < ./ULO_Workflow.patch >/dev/null 2>&1; then
                log "WARNING" "Failed to apply UloBuilder patch"
            else
                log "SUCCESS" "UloBuilder patch applied successfully"
            fi
        else
            log "WARNING" "UloBuilder patch not found"
        fi

        # Run UloBuilder
        log "INFO" "Running UloBuilder..."
        local readonly rootfs_basename=$(basename "${rootfs_file}")
        if ! sudo ./ulo -y -m "${target_board}" -r "${rootfs_basename}" -k "${target_kernel}" -s 1024; then
            error_msg "UloBuilder execution failed"
            exit 1
        fi
        device_output_dir="./out/${target_board}"
    fi

    # Verify and copy output files
    if [[ ! -d "${device_output_dir}" ]]; then
        error_msg "Builder output directory not found: ${device_output_dir}"
        exit 1
    fi

    log "INFO" "Copying firmware files to output directory..."
    if ! cp -rf "${device_output_dir}"/* "${output_dir}/"; then
        error_msg "Failed to copy firmware files to output directory"
        exit 1
    fi

    # Verify output files exist
    if ! ls "${output_dir}"/* >/dev/null 2>&1; then
        error_msg "No firmware files found in output directory"
        exit 1
    fi

    # Safe cleanup
    if [[ -d "${builder_dir}" && "${builder_dir}" != "/" ]]; then
        sudo rm -rf "${builder_dir}"
    fi

    sync && sleep 3
    ls -lh "${output_dir}"/*
    log "SUCCESS" "Firmware repacking completed successfully!"
}

# Update the function call to include all required parameters
repackwrt --"$1" -t "$2" -k "$3" -tn "$4"