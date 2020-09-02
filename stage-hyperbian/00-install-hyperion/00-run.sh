#!/bin/bash -e

# Select the appropriate download path
HYPERION_DOWNLOAD_URL="https://github.com/tihoangyeudau/hyperion.ng/releases/download"
HYPERION_RELEASES_URL="https://api.github.com/repos/tihoangyeudau/hyperion.ng/releases"

# Get the latest version
HYPERION_LATEST_VERSION=$(curl -sL "$HYPERION_RELEASES_URL" | grep "tag_name" | head -1 | cut -d '"' -f 4)
HYPERION_RELEASE=$HYPERION_DOWNLOAD_URL/$HYPERION_LATEST_VERSION/Ambilight-WiFi-$HYPERION_LATEST_VERSION-Linux-armv6l.tar.gz

# Download latest release
echo '           Download Ambilight WiFi'
curl -sS -L --get $HYPERION_RELEASE | tar --strip-components=1 -C ${ROOTFS_DIR}/usr/share/ share/ambilightwifi -xz

# Copy service file and cleanup
cp ambilightwifi.service ${ROOTFS_DIR}/etc/systemd/system/ambilightwifid@.service
rm -r ${ROOTFS_DIR}/usr/share/ambilightwifi/service
rm -r ${ROOTFS_DIR}/usr/share/ambilightwifi/desktop 2>/dev/null

# Enable SPI and force HDMI output
sed -i "s/^#dtparam=spi=on.*/dtparam=spi=on/" ${ROOTFS_DIR}/boot/config.txt
sed -i "s/^#hdmi_force_hotplug=1.*/hdmi_force_hotplug=1/" ${ROOTFS_DIR}/boot/config.txt

# Modify /usr/lib/os-release
sed -i "s/Raspbian/HyperBian/gI" ${ROOTFS_DIR}/usr/lib/os-release
sed -i "s/^NAME=.*$/NAME=\"HyperBian ${HYPERION_LATEST_VERSION}\"/g" ${ROOTFS_DIR}/usr/lib/os-release
sed -i "s/^VERSION=.*$/VERSION=\"${HYPERION_LATEST_VERSION}\"/g" ${ROOTFS_DIR}/usr/lib/os-release

on_chroot << EOF
echo '           Install Ambilight WiFi'
chmod +x -R /usr/share/ambilightwifi/bin
ln -fs /usr/share/ambilightwifi/bin/ambilightwifid /usr/bin/ambilightwifid
ln -fs /usr/share/ambilightwifi/bin/ambilightwifi-remote /usr/bin/ambilightwifi-remote
ln -fs /usr/share/ambilightwifi/bin/ambilightwifi-v4l2 /usr/bin/ambilightwifi-v4l2
ln -fs /usr/share/ambilightwifi/bin/ambilightwifi-framebuffer /usr/bin/ambilightwifi-framebuffer 2>/dev/null
ln -fs /usr/share/ambilightwifi/bin/ambilightwifi-dispmanx /usr/bin/ambilightwifi-dispmanx 2>/dev/null
ln -fs /usr/share/ambilightwifi/bin/ambilightwifi-qt /usr/bin/ambilightwifi-qt 2>/dev/null
echo '           Register Ambilight WiFi'
systemctl -q enable ambilightwifid@.service
EOF
