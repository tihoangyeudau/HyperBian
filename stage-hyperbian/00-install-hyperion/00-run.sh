#!/bin/bash -e

# Select the appropriate download path
HYPERION_DOWNLOAD_URL="https://github.com/tihoangyeudau/hyperion.ng/releases/download"
HYPERION_RELEASES_URL="https://api.github.com/repos/tihoangyeudau/hyperion.ng/releases"

# Get the latest version
HYPERION_LATEST_VERSION=$(curl -sL "$HYPERION_RELEASES_URL" | grep "tag_name" | head -1 | cut -d '"' -f 4)
HYPERION_RELEASE=$HYPERION_DOWNLOAD_URL/$HYPERION_LATEST_VERSION/Ambilight-WiFi-$HYPERION_LATEST_VERSION-Linux-armv6l.deb

# Download latest release
echo '           Download Ambilight WiFi + rpi fan'
mkdir -p "$ROOTFS_DIR"/tmp
curl -L $HYPERION_RELEASE --output "$ROOTFS_DIR"/tmp/ambilightwifi.deb
curl -sS -L --get https://github.com/tihoangyeudau/rpi-fan/releases/download/1.0.0/rpi-fan.tar.gz | tar --strip-components=0 -C ${ROOTFS_DIR}/usr/share/ rpi-fan -xz

# Copy service file
cp ambilightwifi.service ${ROOTFS_DIR}/etc/systemd/system/ambilightwifid@.service
cp rpi-fan.service ${ROOTFS_DIR}/etc/systemd/system/rpi-fan.service

# Enable SPI and force HDMI output
sed -i "s/^#dtparam=spi=on.*/dtparam=spi=on/" ${ROOTFS_DIR}/boot/config.txt
sed -i "s/^#hdmi_force_hotplug=1.*/hdmi_force_hotplug=1/" ${ROOTFS_DIR}/boot/config.txt

# Modify /usr/lib/os-release
sed -i "s/Raspbian/HyperBian/gI" ${ROOTFS_DIR}/usr/lib/os-release
sed -i "s/^NAME=.*$/NAME=\"HyperBian ${HYPERION_LATEST_VERSION}\"/g" ${ROOTFS_DIR}/usr/lib/os-release
sed -i "s/^VERSION=.*$/VERSION=\"${HYPERION_LATEST_VERSION}\"/g" ${ROOTFS_DIR}/usr/lib/os-release

on_chroot << EOF
echo '           Install Ambilight WiFi'
apt install /tmp/ambilightwifi.deb
echo '           Register Ambilight WiFi'
systemctl -q enable ambilightwifid"@rml".service
systemctl -q enable rpi-fan"@rml".service
EOF
