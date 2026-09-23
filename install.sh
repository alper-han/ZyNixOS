#!/usr/bin/env bash
set -Eeuo pipefail

script_dir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")
cd -- "$script_dir"
validate_host_name() {
  [[ "${1-}" =~ ^[A-Za-z0-9]([A-Za-z0-9_-]{0,61}[A-Za-z0-9])?$ ]]
}

is_nixos_live_iso() {
  [[ "$(findmnt -n -o TARGET --mountpoint /iso 2>/dev/null)" == /iso &&
     "$(findmnt -n -o FSTYPE --mountpoint /nix/.ro-store 2>/dev/null)" == squashfs ]]
}

# If in the live environment then start the live-install.sh script
if is_nixos_live_iso; then
  if [[ $EUID -eq 0 ]]; then
    ./live-install.sh
  else
    sudo ./live-install.sh
  fi
  exit 0
fi

if [[ $EUID -eq 0 ]]; then
  echo "This script should not be executed as root! Exiting..."
  exit 1
fi

if ! grep -qi nixos /etc/os-release; then
  echo "This installation script only works on NixOS! Download an iso at https://nixos.org/download/"
  echo "You can either use this script in the live environment or booted into a system."
  exit 1
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

success() {
  echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║                                                                       ║${NC}"
  echo -e "${GREEN}║                    ZyNixOS Installation Successful!                   ║${NC}"
  echo -e "${GREEN}║                                                                       ║${NC}"
  echo -e "${GREEN}║       Please reboot your system for the changes to take effect.       ║${NC}"
  echo -e "${GREEN}║                                                                       ║${NC}"
  echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
}

info() {
  echo -e "\n${GREEN}$1${NC}"
}

warn() {
  echo -e "${YELLOW}$1${NC}"
}

error() {
  echo -e "${RED}Error: $1${NC}" >&2
}

currentUser=$(id -un)

list_hosts() {
  local host_name
  for host_dir in ./hosts/*/; do
    [[ -d "$host_dir" ]] || continue
    host_name=${host_dir%/}
    host_name=${host_name##*/}
    # Default is a portable template, not an installed machine.
    if [[ "$host_name" != Default ]] && validate_host_name "$host_name" &&
      [[ -f "$host_dir/configuration.nix" && -f "$host_dir/variables.nix" ]]; then
      printf '%s\n' "$host_name"
    fi
  done
}

valid_host_choice() {
  local choice=$1
  [[ "$choice" =~ ^[1-9][0-9]*$ && ${#choice} -le 9 ]] || return 1
  (( choice <= ${#available_hosts[@]} ))
}

choose_drivers() {
  local host="$1"
  info "Choose GPU Drivers:"
  echo "1) nvidia"
  echo "2) amdgpu"
  echo "3) intel"
  while true; do
    IFS= read -r -p "Enter choice (1, 2 or 3): " driver_choice || return 1
    case $driver_choice in
    1)
      sed -i -e "s/videoDriver = .*/videoDriver = \"nvidia\";/" "./hosts/$host/variables.nix"
      break
      ;;
    2)
      sed -i -e "s/videoDriver = .*/videoDriver = \"amdgpu\";/" "./hosts/$host/variables.nix"
      break
      ;;
    3)
      sed -i -e "s/videoDriver = .*/videoDriver = \"intel\";/" "./hosts/$host/variables.nix"
      break
      ;;
    *) error "Invalid choice. Enter 1, 2, or 3." ;;
    esac
  done
}

open_variables() {
  local host="$1"
  local editor
  IFS= read -r -p "Edit variables.nix for host: $host? (Y/n): " edit_vars || return 1
  if [[ ! "$edit_vars" =~ ^[nN]$ ]]; then
    for editor in "${EDITOR:-}" nano vim vi; do
      [[ -n "$editor" ]] && command -v "$editor" &>/dev/null || continue
      if ! "$editor" "./hosts/$host/variables.nix"; then
        error "Editor '$editor' failed; review variables.nix before continuing."
        return 1
      fi
      return 0
    done
    error "No editor available; set EDITOR or install nano, vim, or vi."
    return 1
  fi
}

create_new_host() {
  local new_name="$1"

  if ! validate_host_name "$new_name"; then
    error "Invalid host name. Use only letters, numbers, hyphens, and underscores."
    return 1
  fi

  if [ -e "./hosts/$new_name" ] || [ -L "./hosts/$new_name" ]; then
    error "Host '$new_name' already exists"
    return 1
  fi

  if [ ! -d "./hosts/Default" ]; then
    error "Portable Default host template is missing"
    return 1
  fi

  info "Creating new host '$new_name' from portable Default template..."
  cp -R -- "./hosts/Default" "./hosts/$new_name" || {
    error "Failed to copy template"
    return 1
  }

  # Never inherit hardware generated for another machine.
  rm -f "./hosts/$new_name/hardware-configuration.nix"

  if [ -f "./hosts/$new_name/variables.nix" ]; then
    sed -i -e "s/hostname = .*/hostname = \"$new_name\";/" "./hosts/$new_name/variables.nix"
  fi

  echo "Host '$new_name' created successfully."
  return 0
}

info "NixOS Configuration Host Selection"

mapfile -t available_hosts < <(list_hosts)
current_hostname=$(hostname)
default_choice=
for i in "${!available_hosts[@]}"; do
  if [[ "${available_hosts[$i]}" == "$current_hostname" ]]; then
    default_choice=$((i + 1))
    break
  fi
done

echo -e "\nAvailable hosts:"
for i in "${!available_hosts[@]}"; do
  echo "  $((i + 1))) ${available_hosts[$i]}"
done
echo "  n) Create new host from portable Default"

while true; do
  if [[ -n "$default_choice" ]]; then
    IFS= read -r -p "Select host to use [Default: $current_hostname]: " host_choice || exit 1
  else
    IFS= read -r -p "Select host to use (n to create a host): " host_choice || exit 1
  fi
  host_choice=${host_choice:-$default_choice}

  if [[ "$host_choice" == [nN] ]]; then
    IFS= read -r -p "Enter name for new host: " new_host_name || exit 1
    if ! validate_host_name "$new_host_name"; then
      error "Invalid host name. Use only letters, numbers, hyphens, and underscores."
      continue
    fi
    if create_new_host "$new_host_name"; then
      selected_host="$new_host_name"
      break
    fi
  elif valid_host_choice "$host_choice"; then
    selected_host="${available_hosts[$((host_choice - 1))]}"
    break
  else
    error "Invalid choice. Please try again."
  fi
done

info "Using host: $selected_host"

open_variables "$selected_host"
choose_drivers "$selected_host"
sed -i -e "s/username = .*/username = \"$currentUser\";/" "./hosts/$selected_host/variables.nix"

hardware_path="./hosts/$selected_host/hardware-configuration.nix"
if [[ -L "$hardware_path" || ( -e "$hardware_path" && ! -f "$hardware_path" ) ]]; then
  error "Hardware configuration is not a regular file; refusing to replace it."
  exit 1
fi

replace_hardware=true
if [[ -f "$hardware_path" ]]; then
  IFS= read -r -p "Keep existing hardware configuration for $selected_host? (Y/n): " keep_hardware || exit 1
  [[ "$keep_hardware" == [nN] ]] || replace_hardware=false
fi

if [[ "$replace_hardware" == true ]]; then
  info "Generating hardware configuration..."
  hardware_tmp=$(mktemp -- "$hardware_path.XXXXXXXX")
  if [[ -f /etc/nixos/hardware-configuration.nix ]]; then
    if ! sudo cp -- /etc/nixos/hardware-configuration.nix "$hardware_tmp"; then
      rm -f -- "$hardware_tmp"
      error "Failed to copy hardware configuration."
      exit 1
    fi
  elif ! sudo nixos-generate-config --show-hardware-config >"$hardware_tmp"; then
    rm -f -- "$hardware_tmp"
    error "Failed to generate hardware configuration."
    exit 1
  fi
  chmod 644 -- "$hardware_tmp"
  mv -f -- "$hardware_tmp" "$hardware_path"
fi

IFS= read -r -p "Type 'BOOT $selected_host' to check and build its boot entry: " boot_confirmation || exit 1
if [[ "$boot_confirmation" != "BOOT $selected_host" ]]; then
  warn "Boot build cancelled; no Nix evaluation or rebuild was started."
  exit 0
fi

# Nix flakes include only Git-visible files. Stage intent to add for this host only.
git add -N -- "hosts/$selected_host/configuration.nix" "hosts/$selected_host/host-packages.nix" \
  "hosts/$selected_host/variables.nix" "hosts/$selected_host/hardware-configuration.nix"
info "Checking NixOS configuration for host: $selected_host"
nix flake check --no-build --no-write-lock-file
info "Building NixOS configuration for host: $selected_host"
sudo nixos-rebuild boot --flake ".#$selected_host"
echo
success
