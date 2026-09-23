#!/usr/bin/env bash
# Interactive installer for the NixOS live ISO. Never run against an installed system.

# Installer planning and validation; partition creation runs only after explicit consent.

decimal_gib() {
  local value="${1-}"
  [[ "$value" =~ ^[0-9]+$ ]] || return 1
  while [[ ${#value} -gt 1 && "$value" == 0* ]]; do
    value="${value#0}"
  done
  # Reject arithmetic overflow well before converting GiB to MiB.
  (( ${#value} <= 6 )) || return 1
  printf '%s\n' "$((10#$value))"
}

recommended_swap_gib() {
  local ram_mib="${1-}" gib
  [[ "$ram_mib" =~ ^[1-9][0-9]*$ ]] && (( ${#ram_mib} <= 9 )) || return 1
  gib=$(((ram_mib + 2047) / 2048))
  (( gib >= 2 )) || gib=2
  printf '%s\n' "$gib"
}

partition_root_start_mib() {
  local swap_mib="${1-}"
  [[ "$swap_mib" =~ ^[0-9]+$ ]] && (( ${#swap_mib} <= 9 )) || return 1
  printf '%s\n' "$((1025 + 10#$swap_mib))"
}

partition_device_name() {
  local disk="${1-}" index="${2-}"
  [[ "$disk" =~ ^[A-Za-z0-9_.-]+$ && "$index" =~ ^[1-9][0-9]*$ ]] || return 1
  if [[ "$disk" =~ [0-9]$ ]]; then printf '%sp%s\n' "$disk" "$index"
  else printf '%s%s\n' "$disk" "$index"; fi
}

validate_host_name() {
  [[ "${1-}" =~ ^[A-Za-z0-9]([A-Za-z0-9_-]{0,61}[A-Za-z0-9])?$ ]]
}
confirm_installation() {
  local reply
  IFS= read -r reply || return 1
  [[ "$reply" == "INSTALL ${1-}" ]]
}

validate_auto_capacity() {
  local disk_mib="${1-}" swap_mib="${2-}"
  [[ "$disk_mib" =~ ^[1-9][0-9]*$ ]] || return 1
  (( disk_mib - $(partition_root_start_mib "$swap_mib") >= 32768 ))
}

# Destructive primitive. Call only after validating the device and exact user approval.
create_auto_partitions() {
  local device="${1-}" swap_mib="${2-}" first=1025 end
  [[ "$swap_mib" =~ ^[0-9]+$ ]] && (( ${#swap_mib} <= 9 )) || return 1
  wipefs -af "$device" || return 1
  parted -s "$device" mklabel gpt mkpart primary fat32 1MiB 1025MiB set 1 esp on || return 1
  if (( swap_mib > 0 )); then
    end=$((first + 10#$swap_mib))
    parted -s "$device" mkpart primary linux-swap "${first}MiB" "${end}MiB" || return 1
    first="$end"
  fi
  parted -s "$device" mkpart primary "${first}MiB" 100%
}

# NixOS hardware generation imports all active non-zram swap devices. Only the
# installer-selected swap may be active, never a live ISO or other disk's swap.
validate_installer_swaps() {
  local expected="${1-}" active seen=0
  while IFS= read -r active; do
    [[ -n "$active" && ! "$active" =~ ^/dev/zram[0-9]+$ ]] || continue
    if [[ -n "$expected" && "$(readlink -f -- "$active")" == "$(readlink -f -- "$expected")" ]]; then
      seen=1
    else
      return 1
    fi
  done
  [[ -z "$expected" || "$seen" == 1 ]]
}

mount_source_matches_device() {
  local source="${1-}" expected="${2-}"
  # findmnt appends [/subvolume] for Btrfs; it is not part of the device name.
  source="${source%%\[*}"
  [[ -n "$source" && -n "$expected" && "$(readlink -f -- "$source")" == "$(readlink -f -- "$expected")" ]]
}

is_nixos_live_iso() {
  # Copy-to-RAM changes /iso to tmpfs, but the read-only Nix store stays squashfs.
  [[ "$(findmnt -n -o TARGET --mountpoint /iso 2>/dev/null)" == /iso &&
     "$(findmnt -n -o FSTYPE --mountpoint /nix/.ro-store 2>/dev/null)" == squashfs ]]
}

mapper_name_available() {
  local name="${1-}" directory="${2:-/dev/mapper}"
  [[ "$name" =~ ^[A-Za-z0-9_-]+$ && ! -e "$directory/$name" && ! -L "$directory/$name" ]]
}

safe_home_destination() {
  local home="${1-}"
  [[ -n "$home" && ! -L "$home" && ( ! -e "$home" || -d "$home" ) ]] &&
    [[ ! -e "$home/ZyNixOS" && ! -L "$home/ZyNixOS" ]]
}

home_inspection_options() {
  case "${1-}" in
    ext4) echo ro,noload ;;
    btrfs) echo ro,nologreplay ;;
    *) return 1 ;;
  esac
}
# Run from the source repository root, not a subdirectory or an empty Git repo.
preflight_repository_source() {
  local root file parent
  root=$(git rev-parse --show-toplevel 2>/dev/null) || return 1
  [[ "$(pwd -P)" == "$(cd -- "$root" && pwd -P)" ]] || return 1
  git rev-parse --verify 'HEAD^{commit}' >/dev/null 2>&1 || return 1
  while IFS= read -r -d '' file; do
    parent=$file
    while [[ "$parent" == */* ]]; do
      parent=${parent%/*}
      [[ ! -L "$parent" ]] || return 1
    done
  done < <(git ls-files -z)
}

# Copy only Git-visible current files; absent tracked paths remain absent.
copy_tracked_configuration() {
  local destination="$1" file
  preflight_repository_source || return 1
  mkdir -p -- "$destination" || return 1
  git ls-files -z | while IFS= read -r -d '' file; do
    if [[ -f "$file" || -L "$file" ]]; then printf '%s\0' "$file"; fi
  done | tar -c --no-recursion --null -T - -f - | tar -x -C "$destination" -f -
}

copy_user_repository() {
  local destination="$1" source origin
  local -a new_paths=()
  preflight_repository_source || return 1
  [[ ! -e "$destination" && ! -L "$destination" ]] || return 1
  source=$(pwd -P) || return 1
  if ! origin=$(git remote get-url origin 2>/dev/null); then origin=''; fi
  # Relative local remotes would resolve against the new home directory.
  case "$origin" in
    ""|/*|*://*|*:*|~*) ;;
    */*) origin="$(cd -P -- "${origin%/*}" && pwd -P)/${origin##*/}" || return 1 ;;
    *) origin="$source/$origin" ;;
  esac

  # A fresh clone has its own Git metadata even if the source is a linked worktree.
  git clone --quiet --no-local --no-checkout -- "$source" "$destination" || return 1
  # --no-checkout leaves an empty index; restore HEAD entries without reading files.
  git -C "$destination" read-tree HEAD || return 1
  if [[ -n "$origin" ]]; then
    git -C "$destination" remote set-url origin "$origin" || return 1
  else
    git -C "$destination" remote remove origin || return 1
  fi
  copy_tracked_configuration "$destination" || return 1
  # The installer stages new host files; retain their Git visibility in the clone.
  mapfile -d "" -t new_paths < <(git -C "$destination" ls-files --others -z)
  if (( ${#new_paths[@]} )); then git -C "$destination" add -N -f -- "${new_paths[@]}"; fi
}

info() { printf '\n%s\n' "$*"; }
warn() { printf 'Warning: %s\n' "$*" >&2; }
fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }


# Only resources opened by this process are cleaned up. Formatting is not reversible.
root_mounted=0
boot_mounted=0
home_mounted=0
root_luks_opened=0
home_luks_opened=0
swap_active=0
installation_complete=0
declare -A manual_part_ids=()
esp_check_dir='' home_check_dir='' hardware_tmp=''
esp_check_mounted=0 home_check_mounted=0 home_check_opened=0

release_preflight_resources() {
  local failed=0
  if (( home_check_mounted )); then
    if umount "$home_check_dir"; then home_check_mounted=0
    else warn "Could not unmount home inspection $home_check_dir"; failed=1; fi
  fi
  if (( home_check_opened && ! home_check_mounted )); then
    if cryptsetup close luks-home-check; then home_check_opened=0
    else warn 'Could not close temporary home LUKS mapping'; failed=1; fi
  fi
  if [[ -n "$home_check_dir" ]] && (( ! home_check_mounted )); then
    if rmdir -- "$home_check_dir"; then home_check_dir=''
    else warn 'Could not remove temporary home inspection directory'; failed=1; fi
  fi
  if (( esp_check_mounted )); then
    if umount "$esp_check_dir"; then esp_check_mounted=0
    else warn "Could not unmount EFI inspection $esp_check_dir"; failed=1; fi
  fi
  if [[ -n "$esp_check_dir" ]] && (( ! esp_check_mounted )); then
    if rmdir -- "$esp_check_dir"; then esp_check_dir=''
    else warn 'Could not remove temporary EFI inspection directory'; failed=1; fi
  fi
  return "$failed"
}

cleanup() {
  local status="$1" cleanup_failed=0
  trap - EXIT
  set +e
  release_preflight_resources || cleanup_failed=1
  if [[ -n "$hardware_tmp" && -f "$hardware_tmp" ]] && ! rm -f -- "$hardware_tmp"; then
    warn 'Could not remove temporary hardware configuration'; cleanup_failed=1
  fi
  if (( home_mounted )) && ! umount /mnt/home; then warn 'Could not unmount /mnt/home'; cleanup_failed=1; fi
  if (( boot_mounted )) && ! umount /mnt/boot; then warn 'Could not unmount /mnt/boot'; cleanup_failed=1; fi
  if (( root_mounted )) && ! umount -R /mnt; then warn 'Could not unmount /mnt'; cleanup_failed=1; fi
  if (( swap_active )) && ! swapoff "$swap_device"; then warn "Could not deactivate $swap_device"; cleanup_failed=1; fi
  if (( home_luks_opened )) && ! cryptsetup luksClose luks-home; then warn 'Could not close luks-home'; cleanup_failed=1; fi
  if (( root_luks_opened )) && ! cryptsetup luksClose luks-root; then warn 'Could not close luks-root'; cleanup_failed=1; fi
  if (( cleanup_failed )); then
    warn 'Cleanup incomplete; inspect mounted filesystems and open LUKS mappings before rebooting.'
    status=1
  fi
  if (( status == 0 && installation_complete )); then
    info 'Installation and cleanup complete. You may reboot.'
  elif (( status != 0 )); then
    warn 'Installation did not complete cleanly; disk changes already made cannot be rolled back.'
  fi
  exit "$status"
}

ask_yes_no() {
  local answer
  while true; do
    read -r -p "$1 [y/N]: " answer || return 1
    case "$answer" in
      y|Y) return 0 ;;
      ''|n|N) return 1 ;;
      *) warn 'Enter y or n.' ;;
    esac
  done
}

ask_choice() {
  local answer limit="$2"
  while true; do
    read -r -p "$1: " answer || return 1
    if [[ "$answer" =~ ^[1-9][0-9]*$ ]] && (( ${#answer} <= 2 )) && (( 10#$answer <= limit )); then
      REPLY="$((10#$answer))"
      return 0
    fi
    warn "Choose a number from 1 to $limit."
  done
}

ask_secret() {
  local label="$1" result_name="$2" first second
  while true; do
    read -r -s -p "$label: " first || return 1; printf '\n'
    read -r -s -p "Confirm $label: " second || return 1; printf '\n'
    if [[ -n "$first" && "$first" == "$second" ]]; then
      printf -v "$result_name" '%s' "$first"
      return 0
    fi
    warn 'Passwords must match and must not be empty.'
  done
}

require_commands() {
  local command
  for command in "$@"; do
    command -v "$command" >/dev/null 2>&1 || fail "Required command is missing: $command"
  done
}

mounted_or_swap() {
  local path="$1" active child
  if lsblk -nrpo MOUNTPOINT "$path" | grep -q '[^[:space:]]'; then return 0; fi
  while IFS= read -r active; do
    for child in $(lsblk -nrpo NAME "$path"); do
      [[ "$(readlink -f "$active")" == "$(readlink -f "$child")" ]] && return 0
    done
  done < <(swapon --noheadings --show=NAME 2>/dev/null)
  return 1
}

valid_disk() {
  local name="$1" path="/dev/$1"
  [[ "$name" =~ ^[A-Za-z0-9_.-]+$ && -b "$path" ]] || return 1
  [[ "$(lsblk -dnro TYPE "$path")" == disk && "$(lsblk -dnro RO "$path")" == 0 ]] || return 1
  ! mounted_or_swap "$path"
}

valid_partition() {
  local name="$1" path="/dev/$1"
  [[ "$name" =~ ^[A-Za-z0-9_.-]+$ && -b "$path" ]] || return 1
  [[ "$(lsblk -dnro TYPE "$path")" == part && "$(lsblk -dnro PKNAME "$path")" == "$disk" ]] || return 1
  ! mounted_or_swap "$path"
}

choose_disk() {
  info 'Available disks (check model and size carefully):'
  lsblk -d -o NAME,SIZE,MODEL,TRAN
  while true; do
    read -r -p 'Whole disk (for example nvme0n1): ' disk || fail 'No disk chosen.'
    disk="${disk#/dev/}"
    valid_disk "$disk" && break
    warn 'Not an available, writable, unused whole disk.'
  done
  disk_identity="$(lsblk -dnro MAJ:MIN "/dev/$disk")"
}

choose_partition() {
  local target="$1" label="$2" optional="$3" chosen other
  while true; do
    read -r -p "$label${optional:+ (blank to skip)}: " chosen || return 1
    chosen="${chosen#/dev/}"
    if [[ -z "$chosen" && -n "$optional" ]]; then printf -v "$target" '%s' ''; return 0; fi
    if valid_partition "$chosen"; then
      for other in "$part_boot" "$part_root" "$part_home" "$part_swap"; do
        if [[ -n "$other" && "$other" == "$chosen" ]]; then warn 'Each partition can have only one role.'; continue 2; fi
      done
      printf -v "$target" '%s' "$chosen"
      return 0
    fi
    warn "Invalid, busy or other-disk partition: $chosen"
  done
}


mount_tree_busy() {
  findmnt -rn -o TARGET | awk '$0 == "/mnt" || index($0, "/mnt/") == 1 { busy=1 } END { exit !busy }'
}

select_host() {
  local hosts=() dir item selected name
  for dir in ./hosts/*/; do
    [[ -d "$dir" && ! -L "${dir%/}" ]] || continue
    name="${dir%/}"; name="${name##*/}"
    [[ "$name" != Default && -f "$dir/configuration.nix" && -f "$dir/variables.nix" ]] && hosts+=("$name")
  done
  info 'Configuration hosts:'
  for item in "${!hosts[@]}"; do printf '  %s) %s\n' "$((item+1))" "${hosts[item]}"; done
  printf '  n) Create a host from the portable Default template\n'
  while true; do
    read -r -p 'Select existing host number or create new [n]: ' selected || fail 'No host chosen.'
    selected="${selected:-n}"
    if [[ "$selected" == n || "$selected" == N ]]; then
      [[ -d ./hosts/Default && ! -L ./hosts/Default ]] || fail 'Default template is missing or unsafe.'
      read -r -p 'New host name: ' name || fail 'No name entered.'
      validate_host_name "$name" || { warn 'Use letters, digits, hyphens and underscores only.'; continue; }
      [[ ! -e "./hosts/$name" && ! -L "./hosts/$name" ]] || { warn 'That host already exists.'; continue; }
      cp -a ./hosts/Default "./hosts/$name" || fail 'Could not copy the portable host template.'
      rm -f -- "./hosts/$name/hardware-configuration.nix"
      sed -i -e "s|^ *hostname = .*|  hostname = \"$name\";|" "./hosts/$name/variables.nix"
      selected_host="$name"
      break
    fi
    for item in "${!hosts[@]}"; do
      if [[ "$selected" == "$((item+1))" ]]; then selected_host="${hosts[item]}"; break 2; fi
    done
    warn 'Choose a listed host number or n.'
  done
  info "Using host: $selected_host"
}

choose_gpu() {
  info 'GPU: 1) NVIDIA  2) AMD  3) Intel'
  ask_choice 'Choose GPU driver (1-3)' 3
  case "$REPLY" in 1) gpu=nvidia ;; 2) gpu=amdgpu ;; 3) gpu=intel ;; esac
  set_host_value videoDriver "\"$gpu\""
}

set_host_value() {
  local key="$1" literal="$2" file="./hosts/$selected_host/variables.nix"
  grep -Eq "^ *${key} = " "$file" || fail "Host variable $key is missing from $file."
  sed -i -e "s|^ *${key} = .*|  ${key} = ${literal};|" "$file"
}

configure_host() {
  local editor
  while true; do
    read -r -p 'New username (lowercase): ' username || fail 'No username entered.'
    if [[ "$username" =~ ^[a-z_][a-z0-9_-]*$ && ${#username} -le 32 && "$username" != root ]]; then break; fi
    warn 'Use 1-32 lowercase letters, digits, underscores or hyphens; not root.'
  done
  ask_secret 'User password' password
  choose_gpu
  if ask_yes_no 'Edit other host variables with an installed editor?'; then
    editor=''
    for editor in "${EDITOR:-}" nano vim vi; do
      [[ -n "$editor" ]] && command -v "$editor" >/dev/null 2>&1 && break
    done
    [[ -n "$editor" ]] && command -v "$editor" >/dev/null 2>&1 || fail 'No editor found; edit the file before rerunning.'
    "$editor" "./hosts/$selected_host/variables.nix" || fail 'Editor failed; inspect variables before retrying.'
  fi
  set_host_value username "\"$username\""
  nix-instantiate --parse "./hosts/$selected_host/variables.nix" >/dev/null || fail 'Host variables are not valid Nix.'
}

# Collect every choice before formatting, including options for separate /home.
select_layout() {
  [[ -d /sys/firmware/efi ]] || fail 'Boot the live installer in UEFI mode; BIOS/Legacy boot is not supported.'
  info 'Live ISO booted in UEFI mode.'
  if compgen -G '/sys/firmware/efi/efivars/SecureBoot-*' >/dev/null; then
    local secure_file
    secure_file=$(compgen -G '/sys/firmware/efi/efivars/SecureBoot-*' | head -n 1)
    [[ "$(od -An -tu1 -j4 -N1 "$secure_file" | tr -d '[:space:]')" != 1 ]] || fail 'Secure Boot is enabled; this GRUB configuration is unsigned. Disable it before installation.'
  fi

  info 'Partitioning: 1) Automatic (entire disk erased)  2) Manual (selected partitions)'
  ask_choice 'Choose partitioning (1-2)' 2
  if [[ "$REPLY" == 1 ]]; then partitioning=auto; else partitioning=manual; fi
  choose_disk

  part_boot='' part_root='' part_home='' part_swap='' esp_action=none home_action=none
  if [[ "$partitioning" == manual ]]; then
    if ask_yes_no 'Open cfdisk to change the partition table now?'; then
      require_commands cfdisk
      mount_tree_busy && fail '/mnt is already in use; unmount it first.'
      info "cfdisk itself can write /dev/$disk BEFORE the later filesystem confirmation."
      local cfdisk_ack
      read -r -p "Type PARTITION /dev/$disk to authorize opening cfdisk: " cfdisk_ack || fail 'cfdisk not authorized.'
      [[ "$cfdisk_ack" == "PARTITION /dev/$disk" ]] || fail 'cfdisk not authorized.'
      cfdisk "/dev/$disk" || fail 'cfdisk failed.'
      udevadm settle
      valid_disk "$disk" || fail 'Disk became busy or unavailable after cfdisk.'
    fi
    info 'Choose partitions from the selected disk:'
    lsblk -o NAME,SIZE,FSTYPE,PARTTYPE "/dev/$disk"
    choose_partition part_boot 'EFI partition' ''
    local esp_type esp_guid esp_bytes
    esp_guid="$(lsblk -dnro PARTTYPE "/dev/$part_boot" | tr '[:upper:]' '[:lower:]')"
    [[ "$esp_guid" == c12a7328-f81f-11d2-ba4b-00a0c93ec93b ]] || fail 'Selected EFI partition lacks the GPT ESP type/flag.'
    esp_type="$(blkid -s TYPE -o value "/dev/$part_boot" 2>/dev/null || true)"
    esp_bytes="$(blockdev --getsize64 "/dev/$part_boot")"
    case "$esp_type" in
      vfat)
        esp_action=reuse
        if ask_yes_no 'Format the existing EFI partition and erase its boot files?'; then esp_action=format; fi
        ;;
      '') esp_action=format ;;
      *) fail "EFI partition contains $esp_type, not FAT32; select a different partition." ;;
    esac
    if [[ "$esp_action" == format ]] && (( esp_bytes < 1024 * 1024 * 1024 )); then
      fail 'A newly formatted EFI partition must be at least 1024 MiB.'
    fi
    if [[ "$esp_action" == reuse ]]; then check_esp_free_space; fi
    choose_partition part_root 'Root partition (WILL BE FORMATTED)' ''
    choose_partition part_home 'Optional home partition' optional
    choose_partition part_swap 'Optional swap partition' optional
  else
    esp_action=format
  fi

  info 'Root filesystem: 1) ext4  2) Btrfs'
  ask_choice 'Choose filesystem (1-2)' 2
  if [[ "$REPLY" == 1 ]]; then filesystem=ext4; else filesystem=btrfs; fi
  if ask_yes_no 'Encrypt root with LUKS?'; then
    luks_enabled=yes
    ask_secret 'Root LUKS passphrase' luks_password
  else
    luks_enabled=no
    luks_password=''
  fi

  local mem_mib recommended raw disk_mib
  mem_mib="$(awk '/^MemTotal:/ {print int(($2 + 1023) / 1024)}' /proc/meminfo)"
  [[ "$mem_mib" =~ ^[1-9][0-9]*$ ]] || fail 'Could not determine installed RAM.'
  recommended=$(recommended_swap_gib "$mem_mib") || fail 'Could not calculate a swap recommendation.'
  if [[ "$partitioning" == auto ]]; then
    while true; do
      read -r -p "Swap in GiB [recommended $recommended; 0 disables]: " raw || fail 'Swap choice missing.'
      raw="${raw:-$recommended}"
      swap_gib=$(decimal_gib "$raw") || { warn 'Enter a nonnegative decimal number of GiB.'; continue; }
      break
    done
    swap_mib=$((swap_gib * 1024))
    disk_mib=$(( $(blockdev --getsize64 "/dev/$disk") / 1048576 ))
    validate_auto_capacity "$disk_mib" "$swap_mib" || fail 'Disk cannot fit boot, swap and at least 32 GiB of root.'
    part_boot=$(partition_device_name "$disk" 1)
    if (( swap_mib == 0 )); then part_root=$(partition_device_name "$disk" 2)
    else part_swap=$(partition_device_name "$disk" 2); part_root=$(partition_device_name "$disk" 3); fi
  else
    swap_mib=0
    (( $(blockdev --getsize64 "/dev/$part_root") >= 32 * 1024 * 1024 * 1024 )) || fail 'Root partition must be at least 32 GiB.'
  fi
  choose_home_action
}

check_esp_free_space() {
  local avail
  esp_check_dir=$(mktemp -d /run/zy-efi-check.XXXXXX) || fail 'Could not allocate EFI inspection mountpoint.'
  mount -o ro "/dev/$part_boot" "$esp_check_dir" || fail 'Cannot read existing EFI partition.'
  esp_check_mounted=1
  avail="$(df -B1 --output=avail "$esp_check_dir" | tail -n 1 | tr -d '[:space:]')" || fail 'Could not inspect EFI free space.'
  release_preflight_resources || fail 'Could not release EFI inspection mount.'
  [[ "$avail" =~ ^[0-9]+$ ]] && (( avail >= 256 * 1024 * 1024 )) || fail 'Existing EFI partition needs at least 256 MiB free; do not format a shared ESP automatically.'
  if (( $(blockdev --getsize64 "/dev/$part_boot") < 1024 * 1024 * 1024 )); then
    warn 'Existing shared EFI is smaller than 1024 MiB; retained without resizing. Future generations may need more room.'
  fi
}

choose_home_action() {
  home_password='' home_action=none home_encrypt=no
  [[ -n "$part_home" ]] || return 0
  local kind
  kind=$(blkid -s TYPE -o value "/dev/$part_home" 2>/dev/null || true)
  if [[ "$kind" == crypto_LUKS ]]; then
    home_action=reuse-luks
    while true; do
      read -r -s -p 'Existing home LUKS passphrase: ' home_password || fail 'Home passphrase missing.'
      printf '\n'
      [[ -n "$home_password" ]] && printf '%s' "$home_password" | cryptsetup open --test-passphrase "/dev/$part_home" - >/dev/null 2>&1 && break
      warn 'Cannot unlock existing home. Try again.'
    done
  elif [[ "$kind" == ext4 || "$kind" == btrfs ]]; then
    if ask_yes_no 'Reuse existing home WITHOUT formatting?'; then home_action=reuse
    else home_action=format; fi
  elif [[ -z "$kind" ]]; then
    home_action=format
  else
    fail "Unsupported home filesystem: $kind"
  fi
  if [[ "$home_action" == format ]]; then
    if ask_yes_no 'Encrypt the new home partition with LUKS?'; then
      home_encrypt=yes
      if [[ "$luks_enabled" == yes ]] && ask_yes_no 'Reuse root LUKS passphrase for the new home?'; then
        home_password="$luks_password"
      else
        ask_secret 'New home LUKS passphrase' home_password
      fi
    else home_encrypt=no; fi
  else
    home_encrypt=no
    check_reused_home_owner
  fi
}

check_reused_home_owner() {
  local device="/dev/$part_home" owner fs inspection_options
  home_check_dir=$(mktemp -d /run/zy-home-check.XXXXXX) || fail 'Could not allocate home inspection mountpoint.'
  if [[ "$home_action" == reuse-luks ]]; then
    mapper_name_available luks-home-check || fail 'Temporary home inspection LUKS mapper is already in use.'
    printf '%s' "$home_password" | cryptsetup open --readonly "$device" luks-home-check - >/dev/null || fail 'Cannot open home read-only for preflight.'
    home_check_opened=1
    device=/dev/mapper/luks-home-check
  fi
  fs=$(blkid -s TYPE -o value "$device") || fail 'Cannot identify reused home filesystem.'
  inspection_options=$(home_inspection_options "$fs") || fail 'Reused home must contain ext4 or Btrfs.'
  mount -o "$inspection_options" "$device" "$home_check_dir" || fail 'Cannot read existing home filesystem without journal replay.'
  home_check_mounted=1
  safe_home_destination "$home_check_dir/$username" || fail 'Existing home is a symlink, non-directory, or already contains ZyNixOS.'
  if [[ -d "$home_check_dir/$username" ]]; then
    owner=$(stat -c '%u:%g' "$home_check_dir/$username") || fail 'Could not inspect existing home owner.'
    [[ "$owner" == 1000:100 ]] || fail "Existing home for $username is owned by $owner, not expected 1000:100; no recursive chown will be done."
  fi
  release_preflight_resources || fail 'Could not release home inspection resources.'
}

preflight_bootstrap() {
  require_commands git tar nix nix-instantiate nixos-install nixos-generate-config mkpasswd chpasswd \
    lsblk blkid blockdev findmnt mount umount wipefs parted udevadm cryptsetup mkswap swapon swapoff \
    mkfs.fat mkfs.ext4 mkfs.btrfs df stat od awk sed
  preflight_repository_source || fail 'Source must be a usable Git checkout at its root before partitioning.'
  mount_tree_busy && fail '/mnt or a child of /mnt is already mounted. Unmount before installing.'
  swapon --noheadings --show=NAME | validate_installer_swaps '' || fail 'Deactivate non-zram live-system swap before installing.'
  password_hash="$(printf '%s' "$password" | mkpasswd --method=yescrypt --stdin)" || fail 'Cannot generate a yescrypt password hash.'
  [[ -n "$password_hash" ]] || fail 'Password hash is empty.'
  info 'Fetching pinned flake inputs before disk partitioning (not a full system build)...'
  nix flake archive --no-write-lock-file . || fail 'Cannot fetch pinned flake inputs. Check live ISO networking.'
}

preflight() {
  mount_tree_busy && fail '/mnt or a child of /mnt is already mounted. Unmount before installing.'
  valid_disk "$disk" || fail 'Target disk changed or is in use.'
  [[ "$(lsblk -dnro MAJ:MIN "/dev/$disk")" == "$disk_identity" ]] || fail 'Selected disk identity changed.'
  if [[ "$partitioning" == manual ]]; then
    local part part_uuid
    for part in "$part_boot" "$part_root" "$part_home" "$part_swap"; do
      [[ -n "$part" ]] || continue
      valid_partition "$part" || fail "Invalid or busy partition /dev/$part."
      part_uuid=$(blkid -s PARTUUID -o value "/dev/$part") || fail "Missing stable partition UUID for /dev/$part."
      [[ -n "$part_uuid" ]] || fail "Missing stable partition UUID for /dev/$part."
      if [[ -v manual_part_ids[$part] ]]; then
        [[ "${manual_part_ids[$part]}" == "$part_uuid" ]] || fail "Selected /dev/$part changed since review."
      else
        manual_part_ids[$part]="$part_uuid"
      fi
    done
  fi
  if [[ "$luks_enabled" == yes ]]; then
    mapper_name_available luks-root || fail 'LUKS mapper luks-root is already in use.'
  fi
  if [[ "$home_action" == reuse-luks || "$home_encrypt" == yes ]]; then
    mapper_name_available luks-home || fail 'LUKS mapper luks-home is already in use.'
  fi
  if [[ "$home_action" == reuse-luks ]]; then
    mapper_name_available luks-home-check || fail 'Temporary LUKS mapper luks-home-check is already in use.'
  fi
}

review_plan() {
  local swap_label=none
  [[ -z "$part_swap" ]] || swap_label="/dev/$part_swap (unencrypted)"
  info 'Final installation plan:'
  printf '  Host/user/GPU: %s / %s / %s\n' "$selected_host" "$username" "$gpu"
  printf '  Firmware/boot: UEFI GRUB; disk /dev/%s (%s)\n' "$disk" "$disk_identity"
  printf '  Partitioning: %s\n' "$partitioning"
  printf '  EFI: /dev/%s; action %s (shared EFI is NEVER resized automatically)\n' "$part_boot" "$esp_action"
  printf '  Root: /dev/%s; FORMAT as %s; LUKS: %s\n' "$part_root" "$filesystem" "$luks_enabled"
  printf '  Home: %s; action %s\n' "${part_home:+/dev/$part_home}" "$home_action"
  printf '  Swap: %s\n' "$swap_label"
  if [[ -n "$part_swap" && "$luks_enabled" == yes ]]; then
    echo '  WARNING: swap remains unencrypted even though root is LUKS-encrypted.'
  fi
  if [[ "$partitioning" == auto ]]; then
    printf '  WARNING: wipefs and GPT replacement erase ALL existing partitions on /dev/%s.\n' "$disk"
  else
    printf '  WARNING: selected root/swap and any explicitly formatted home/EFI are irreversibly overwritten.\n'
  fi
  local confirmation
  read -r -p "Type INSTALL /dev/$disk to execute this exact plan: " confirmation || fail 'Installation not authorized.'
  printf '%s\n' "$confirmation" | confirm_installation "/dev/$disk" || fail 'Confirmation did not match; disk left unchanged by installer.'
}

partition_auto() {
  valid_disk "$disk" && [[ "$(lsblk -dnro MAJ:MIN "/dev/$disk")" == "$disk_identity" ]] || fail 'Disk changed before wipe.'
  mount_tree_busy && fail '/mnt became busy before wipe.'
  create_auto_partitions "/dev/$disk" "$swap_mib" || fail 'Automatic GPT partition creation failed.'
  udevadm settle
  local part
  for part in "$part_boot" "$part_root" "$part_swap"; do
    [[ -z "$part" ]] || valid_partition "$part" || fail "Expected partition /dev/$part was not created."
  done
}

format_filesystem() {
  local device="$1"
  if [[ "$filesystem" == ext4 ]]; then mkfs.ext4 -F "$device"
  else mkfs.btrfs -f "$device"; fi
}

prepare_storage() {
  [[ "$partitioning" != auto ]] || partition_auto
  if [[ "$luks_enabled" == yes ]]; then
    printf '%s' "$luks_password" | cryptsetup luksFormat --batch-mode "/dev/$part_root" - || fail 'Root LUKS creation failed.'
    printf '%s' "$luks_password" | cryptsetup luksOpen "/dev/$part_root" luks-root - || fail 'Root LUKS unlock failed.'
    root_luks_opened=1
    root_device=/dev/mapper/luks-root
  else root_device="/dev/$part_root"; fi
  if [[ "$esp_action" == format ]]; then
    mkfs.fat -F32 "/dev/$part_boot" || fail 'EFI format failed.'
  fi
  format_filesystem "$root_device" || fail 'Root filesystem format failed.'

  home_device=''
  if [[ -n "$part_home" ]]; then
    home_device="/dev/$part_home"
    if [[ "$home_action" == reuse-luks || "$home_encrypt" == yes ]]; then
      if [[ "$home_action" == format ]]; then
        printf '%s' "$home_password" | cryptsetup luksFormat --batch-mode "$home_device" - || fail 'Home LUKS creation failed.'
      fi
      printf '%s' "$home_password" | cryptsetup luksOpen "$home_device" luks-home - || fail 'Home LUKS unlock failed.'
      home_device=/dev/mapper/luks-home
      home_luks_opened=1
    fi
    if [[ "$home_action" == format ]]; then format_filesystem "$home_device" || fail 'Home format failed.'; fi
  fi

  swap_device=''
  if [[ -n "$part_swap" ]]; then
    swap_device="/dev/$part_swap"
    mkswap "$swap_device" || fail 'Selected swap formatting failed.'
  fi
}

mount_storage() {
  mount_tree_busy && fail '/mnt became busy; refuse to mount over existing filesystems.'
  mount "$root_device" /mnt || fail 'Root mount failed.'
  root_mounted=1
  mount_source_matches_device "$(findmnt -rn -o SOURCE --target /mnt)" "$root_device" || fail 'Root mount source mismatch.'
  mkdir -p /mnt/boot
  mount "/dev/$part_boot" /mnt/boot || fail 'EFI mount failed.'
  boot_mounted=1
  mount_source_matches_device "$(findmnt -rn -o SOURCE --target /mnt/boot)" "/dev/$part_boot" || fail 'EFI mount source mismatch.'
  if [[ -n "$home_device" ]]; then
    mkdir -p /mnt/home
    mount "$home_device" /mnt/home || fail 'Selected home mount failed; refusing installation without it.'
    home_mounted=1
    mount_source_matches_device "$(findmnt -rn -o SOURCE --target /mnt/home)" "$home_device" || fail 'Home mount source mismatch.'
    if [[ "$home_action" == reuse || "$home_action" == reuse-luks ]]; then
      safe_home_destination "/mnt/home/$username" || fail 'Reused home contains a symlink, non-directory, or existing ZyNixOS destination.'
    fi
  fi
  if [[ -n "$swap_device" ]]; then
    swapon "$swap_device" || fail 'Selected swap activation failed.'
    swap_active=1
  fi
}


install_target() {
  swapon --noheadings --show=NAME | validate_installer_swaps "$swap_device" || fail 'Unexpected active swap would be imported into target hardware configuration.'
  local config="./hosts/$selected_host/variables.nix" hardware_path
  hardware_path="./hosts/$selected_host/hardware-configuration.nix"
  hardware_tmp=$(mktemp "./hosts/$selected_host/.hardware-configuration.XXXXXX") || fail 'Could not prepare hardware configuration.'
  nixos-generate-config --root /mnt --show-hardware-config >"$hardware_tmp" || fail 'Could not generate target hardware configuration.'
  [[ -s "$hardware_tmp" ]] || fail 'Generated hardware configuration is empty.'
  nix-instantiate --parse "$hardware_tmp" >/dev/null || fail 'Generated hardware configuration is invalid Nix.'
  chmod 644 -- "$hardware_tmp" || fail 'Could not set generated hardware configuration permissions.'
  mv -f -- "$hardware_tmp" "$hardware_path" || fail 'Could not replace hardware configuration.'
  hardware_tmp=''
  nix-instantiate --parse "$config" >/dev/null || fail 'Generated host variables are invalid Nix.'
  # Expose only known generated host files; recursive staging would copy private untracked data.
  git add -N -- "hosts/$selected_host/configuration.nix" "hosts/$selected_host/host-packages.nix" \
    "hosts/$selected_host/variables.nix" "hosts/$selected_host/hardware-configuration.nix" || fail 'Cannot make generated host visible to the Git flake.'
  nix eval --raw ".#nixosConfigurations.$selected_host.config.networking.hostName" >/dev/null || fail 'Selected host does not evaluate after hardware generation.'
  copy_tracked_configuration /mnt/etc/nixos || fail 'Could not copy tracked configuration to /mnt/etc/nixos.'
  nixos-install --flake "/mnt/etc/nixos#$selected_host" --no-root-passwd || fail 'nixos-install failed.'
  if ! printf '%s:%s\n' "$username" "$password_hash" | chpasswd --root /mnt --encrypted; then
    fail 'Installed user password could not be set; installation is incomplete.'
  fi
  unset password password_hash luks_password home_password
  local uid gid user_home
  uid=$(awk -F: -v user="$username" '$1 == user {print $3}' /mnt/etc/passwd)
  gid=$(awk -F: -v user="$username" '$1 == user {print $4}' /mnt/etc/passwd)
  [[ "$uid" =~ ^[1-9][0-9]*$ && "$gid" =~ ^[1-9][0-9]*$ ]] || fail 'Installed user account UID/GID is invalid.'
  user_home="/mnt/home/$username"
  safe_home_destination "$user_home" || fail 'Home is a symlink, non-directory, or already contains ZyNixOS.'
  if [[ -d "$user_home" ]]; then
    [[ "$(stat -c '%u:%g' "$user_home")" == "$uid:$gid" ]] || fail 'Existing home ownership does not match installed user; existing files were not changed.'
  else
    install -d -m 700 -o "$uid" -g "$gid" "$user_home" || fail 'Could not create user home.'
    install -d -o "$uid" -g "$gid" "$user_home"/{Downloads,Documents,Pictures,Videos,.local/bin} || fail 'Could not create user directories.'
  fi
  safe_home_destination "$user_home" || fail 'Configuration destination changed; refusing to overwrite user data.'
  copy_user_repository "$user_home/ZyNixOS" || fail 'Could not copy a usable Git repository into the user home.'
  chown -R "$uid:$gid" "$user_home/ZyNixOS" || fail 'Could not own newly copied configuration.'
  installation_complete=1
}

live_install_main() {
  set -Eeuo pipefail
  cd -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")"
  is_nixos_live_iso || fail 'Boot the NixOS live ISO before installing.'
  (( EUID == 0 )) || fail 'Run this installer as root (sudo ./live-install.sh).'
  export NIX_CONFIG="${NIX_CONFIG:+$NIX_CONFIG$'\n'}experimental-features = nix-command flakes"
  trap 'cleanup "$?"' EXIT

  info 'Welcome to the ZyNixOS installer.'
  require_commands git tar nix nix-instantiate lsblk blkid blockdev findmnt mount umount cryptsetup udevadm
  select_host
  configure_host
  preflight_bootstrap
  select_layout
  preflight
  review_plan
  # The confirmation is for these writes, not for cfdisk operations authorized earlier.
  preflight # Revalidate selected devices and mapper names immediately after authorization.
  prepare_storage
  mount_storage
  install_target
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  live_install_main "$@"
fi
