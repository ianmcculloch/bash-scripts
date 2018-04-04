#!/bin/bash
#======================================================================
# Title: blocklistgen.sh
# Description: Script for downloading and generating an IP blocklist
# Author: Ragnarok (http://crunchbang.org/forums/profile.php?id=13069)
# Date: 2013-04-13
# Version: 0.1
# Usage: $ bash blocklistgen.sh
# Dependencies: bash, coreutils, gzip, wget
#======================================================================


# Save path for the blocklist
blocklist="./blocklist.p2p"
# Directory for storing temporary lists
tmpfldr="/tmp"

# Beautify the blocklist after it is generated
beautify=true

# Disabled. This doesn't work as expected for some reason
#check_for_paths() {
#  if [[ ! -d "$tmpfldr" ]] && [[ ! -r "$tmpfldr" ]] && [[ ! -w "$tmpfldr" ]]; then
#    echo -e "Please make sure " "$tmpfldr" " exists and you have read/write access\nExiting"
#    exit 1
#  fi
#}

# http://wiki.bash-hackers.org/scripting/style
check_for_depends() {
  my_needed_commands="cat gunzip mv rm sed sort wget"

  missing_counter=0
  for needed_command in $my_needed_commands; do
    if ! hash "$needed_command" >/dev/null 2>&1; then
      printf "Command not found in PATH: %s\n" "$needed_command" >&2
      ((missing_counter++))
    fi
  done

  if ((missing_counter > 0)); then
    printf "Minimum %d commands are missing in PATH, aborting\n" "$missing_counter" >&2
    exit 1
  fi
}

backup_blocklist() {
  # Check for and backup blocklist
  echo "Checking for blocklist..."
  if [[ -f "$blocklist" ]]; then
    echo "Backing up blocklist and overwriting old backup if exists..."
    mv -f $blocklist ${blocklist}.old
  fi
}

downloads_lists() {
  # Download blocklists
  # This is where you add/remove blocklists
  # Downloaded lists must follow the following naming format: bl-[zero or more characters].gz
  echo "Downloading lists..."
  wget -q http://list.iblocklist.com/?list=bcoepfyewziejvcqyhqo -O $tmpfldr/bl-iana-reserved.gz
  wget -q http://list.iblocklist.com/?list=bt_ads -O $tmpfldr/bl-ads.gz
  wget -q http://list.iblocklist.com/?list=bt_bogon -O $tmpfldr/bl-bogon.gz
  wget -q http://list.iblocklist.com/?list=bt_dshield -O $tmpfldr/bl-dshield.gz
  wget -q http://list.iblocklist.com/?list=bt_hijacked -O $tmpfldr/bl-hijacked.gz
  wget -q http://list.iblocklist.com/?list=bt_level1 -O $tmpfldr/bl-level1.gz
  wget -q http://list.iblocklist.com/?list=bt_level2 -O $tmpfldr/bl-level2.gz
  wget -q http://list.iblocklist.com/?list=bt_microsoft -O $tmpfldr/bl-microsoft.gz
  wget -q http://list.iblocklist.com/?list=bt_spyware -O $tmpfldr/bl-spyware.gz
  wget -q http://list.iblocklist.com/?list=bt_templist -O $tmpfldr/bl-badpeers.gz
  wget -q http://list.iblocklist.com/?list=ijfqtofzixtwayqovmxn -O $tmpfldr/bl-primary-threats.gz
  wget -q http://list.iblocklist.com/?list=pwqnlynprfgtjbgqoizj -O $tmpfldr/bl-iana-multicast.gz
  wget -q http://list.iblocklist.com/?list=ch -O $tmpfldr/bl-ch.gz
  echo "Download complete"
}

merge_lists() {
  # Merge blocklists
  echo "Merging lists..."
  cat ${tmpfldr}/bl-*.gz > ${blocklist}.gz
}

decompress_blocklist() {
  # Decompress the gzip archive
  if [[ -f "${blocklist}.gz" ]]; then
    echo "Decompressing..."
    gunzip ${blocklist}.gz
    echo "Blocklist successfully generated"
  else
    echo -e "Unable to find ${blocklist}.gz\nExiting"
    remove_temp
    exit 1
  fi
}

beautify_blocklist () {
  # Cleanup the blocklist
  # This will remove comments, empty lines and sort the list alphabetically
  if $beautify; then
    echo -e "Beautification started\nRemoving comments and blank lines..."
    sed -i -e '/^\#/d' -e '/^$/d' $blocklist
    echo "Sorting alphabetically..."
    sort $blocklist > ${tmpfldr}/blocklist.p2p.tmp && mv -f ${tmpfldr}/blocklist.p2p.tmp $blocklist
    echo "Beautification complete"
  fi
}

remove_temp() {
  # Remove temporary blocklists
  echo "Removing temporary files..."
  rm -f ${tmpfldr}/bl-*.gz
}

check_for_depends
#check_for_paths
backup_blocklist
downloads_lists
merge_lists
decompress_blocklist
remove_temp
beautify_blocklist

echo "Done!"

exit 0
