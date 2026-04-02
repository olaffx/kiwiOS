#!/bin/bash
set -e

TARGET_DIR="kiwi/airootfs/etc/systemd/system"

mkdir -p "$TARGET_DIR/multi-user.target.wants"
mkdir -p "$TARGET_DIR/sockets.target.wants"
mkdir -p "$TARGET_DIR/network-online.target.wants"
mkdir -p "$TARGET_DIR/bluetooth.target.wants"
mkdir -p "$TARGET_DIR/user/default.target.wants"

cd "$TARGET_DIR"

# 1. Display Manager & Graphical Target
ln -svf /usr/lib/systemd/system/graphical.target default.target
ln -svf /usr/lib/systemd/system/sddm.service display-manager.service

# 2. Network Manager (NM)
ln -svf /usr/lib/systemd/system/NetworkManager.service multi-user.target.wants/NetworkManager.service
ln -svf /usr/lib/systemd/system/NetworkManager-wait-online.service network-online.target.wants/NetworkManager-wait-online.service
ln -svf /usr/lib/systemd/system/NetworkManager-dispatcher.service dbus-org.freedesktop.nm-dispatcher.service

# 3. Printing (CUPS)
ln -svf /usr/lib/systemd/system/cups.service multi-user.target.wants/cups.service
ln -svf /usr/lib/systemd/system/cups.socket sockets.target.wants/cups.socket
ln -svf /usr/lib/systemd/system/cups.path multi-user.target.wants/cups.path

# 4. Bluetooth
ln -svf /usr/lib/systemd/system/bluetooth.service dbus-org.bluez.service
ln -svf /usr/lib/systemd/system/bluetooth.service bluetooth.target.wants/bluetooth.service
ln -svf /usr/lib/systemd/system/bluetooth.service multi-user.target.wants/bluetooth.service

# 5. Virtualization Support
ln -svf /usr/lib/systemd/system/vmtoolsd.service multi-user.target.wants/vmtoolsd.service
ln -svf /usr/lib/systemd/system/vboxservice.service multi-user.target.wants/vboxservice.service
ln -svf /usr/lib/systemd/system/qemu-guest-agent.service multi-user.target.wants/qemu-guest-agent.service

# 6. Power, Auth & Maintenance
ln -svf /usr/lib/systemd/system/power-profiles-daemon.service multi-user.target.wants/power-profiles-daemon.service
ln -svf /usr/lib/systemd/system/fprintd.service multi-user.target.wants/fprintd.service
ln -svf /usr/lib/systemd/system/fstrim.timer multi-user.target.wants/fstrim.timer
ln -svf /usr/lib/systemd/system/systemd-timesyncd.service multi-user.target.wants/systemd-timesyncd.service

# 7. PipeWire
ln -svf /usr/lib/systemd/user/pipewire.service user/default.target.wants/pipewire.service
ln -svf /usr/lib/systemd/user/pipewire-pulse.service user/default.target.wants/pipewire-pulse.service
ln -svf /usr/lib/systemd/user/wireplumber.service user/default.target.wants/wireplumber.service
