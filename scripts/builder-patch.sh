#!/bin/bash

echo "Start Builder Patch !"
echo "Current Path: $PWD"

cd $GITHUB_WORKSPACE/$WORKING_DIR || exit

# place here for custom command to patch builder openwrt or immortalwrt
{
if [[ "${RELEASE_BRANCH%:*}" == "openwrt" ]]; then
    echo "${RELEASE_BRANCH%:*}"
elif [[ "${RELEASE_BRANCH%:*}" == "immortalwrt" ]]; then
    echo "${RELEASE_BRANCH%:*}"
    # Remove redundant default packages
    sed -i "/luci-app-cpufreq/d" include/target.mk
fi
}

# No signature check packages
sed -i '\|option check_signature| s|^|#|' repositories.conf

echo "Patching Makefile"
# Force opkg to overwrite files
sed -i "s/install \$(BUILD_PACKAGES)/install \$(BUILD_PACKAGES) --force-overwrite --force-downgrade/" Makefile

# Resize Boot and Rootfs partition size
option_squashfs=$( [ "$ROOTFS_SQUASHFS" == "true" ] && echo "CONFIG_TARGET_ROOTFS_SQUASHFS=y" || echo "# CONFIG_TARGET_ROOTFS_SQUASHFS is not set" )
sed -i "s/CONFIG_TARGET_KERNEL_PARTSIZE=.*/CONFIG_TARGET_KERNEL_PARTSIZE=128/" .config
sed -i "s/CONFIG_TARGET_ROOTFS_PARTSIZE=.*/CONFIG_TARGET_ROOTFS_PARTSIZE=1024/" .config
sed -i "s/CONFIG_TARGET_ROOTFS_SQUASHFS=y/$option_squashfs/" .config

if [ "$TYPE" == "AMLOGIC" ]; then
   sed -i "s|CONFIG_TARGET_ROOTFS_CPIOGZ=.*|# CONFIG_TARGET_ROOTFS_CPIOGZ is not set|g" .config
   sed -i "s|CONFIG_TARGET_ROOTFS_EXT4FS=.*|# CONFIG_TARGET_ROOTFS_EXT4FS is not set|g" .config
   sed -i "s|CONFIG_TARGET_ROOTFS_SQUASHFS=.*|# CONFIG_TARGET_ROOTFS_SQUASHFS is not set|g" .config
   sed -i "s|CONFIG_TARGET_IMAGES_GZIP=.*|# CONFIG_TARGET_IMAGES_GZIP is not set|g" .config
fi

if [ "$ARCH_2" == "x86_64" ]; then
   # Not generate ISO images for it is too big
   sed -i "s/CONFIG_ISO_IMAGES=y/# CONFIG_ISO_IMAGES is not set/" .config
   # Not generate VHDX images
   sed -i "s/CONFIG_VHDX_IMAGES=y/# CONFIG_VHDX_IMAGES is not set/" .config
fi
echo "Done!"
