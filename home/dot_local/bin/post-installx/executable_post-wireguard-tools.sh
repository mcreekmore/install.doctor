#!/usr/bin/env bash
# @file macOS WireGuard Profiles
# @brief Installs WireGuard VPN profiles on macOS devices
# @description
#     This script installs WireGuard VPN profiles on macOS. It scans `${XDG_CONFIG_HOME:-$HOME/.config}/vpn` for all the `*.conf` files
#     and then copies those profiles to `/etc/wireguard`. It also performs a couple preparation tasks like ensuring the target
#     WireGuard system configuration file directory exists and is assigned the proper permissions.
#
#     ## Creating VPN Profiles
#
#     More details on embedding your VPN profiles into your Install Doctor fork can be found by reading the [Secrets documentation](https://install.doctor/docs/customization/secrets#vpn-profiles).
#
#     ## TODO
#
#     * Populate Tunnelblick on macOS using the VPN profiles located in `${XDG_CONFIG_HOME:-$HOME/.config}/vpn`
#     * For the Tunnelblick integration, ensure the username / password is populated from the `OVPN_USERNAME` and `OVPN_PASSWORD` variables
#
#     ## Links
#
#     * [VPN profile folder](https://github.com/megabyte-labs/install.doctor/blob/master/home/dot_config/vpn)
#     * [VPN profile documentation](https://install.doctor/docs/customization/secrets#vpn-profiles)

# TODO - Populate Tunnelblick on macOS using the .ovpn profiles located in $HOME/.config/vpn (execpt in the `openvpn` entry of software.yml)
# along with the secrets for the protonVPN OpenVPN (check vpn-linux.tmpl)

### Backs up previous network settings to `/Library/Preferences/com.apple.networkextension.plist.old` before applying new VPN profiles
logg info 'Backing up /Library/Preferences/com.apple.networkextension.plist to /Library/Preferences/com.apple.networkextension.plist.old'
sudo cp -f /Library/Preferences/com.apple.networkextension.plist /Library/Preferences/com.apple.networkextension.plist.old

### Ensures the `/etc/wireguard` directory exists and has the lowest possible permission-level
if [ ! -d /etc/wireguard ]; then
  logg info 'Creating /etc/wireguard since it does not exist yet'
  sudo mkdir -p /etc/wireguard
  sudo chmod 600 /etc/wireguard
fi

### TODO - Should adding the .conf files to /etc/wireguard only be done on macOS or is this useful on Linux as well?
### Cycles through the `*.conf` files in `${XDG_CONFIG_HOME:-$HOME/.config}/vpn` and adds them to the `/etc/wireguard` folder
find "${XDG_CONFIG_HOME:-$HOME/.config}/vpn" -mindepth 1 -maxdepth 1 -type f -name "*.conf" | while read WG_CONF; do
  WG_FILE="$(basename "$WG_CONF")"
  logg info 'Adding '"$WG_FILE"' to /etc/wireguard'
  sudo cp -f "$WG_CONF" "/etc/wireguard/$WG_FILE"
done
