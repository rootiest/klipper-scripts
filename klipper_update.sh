#!/bin/bash
# Copyright (C) 2025 Chris Laprade (chris@rootiest.com)
#
# This file is part of Rootiest klipper-scripts.
#
# Rootiest klipper-scripts is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Rootiest klipper-scripts is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Rootiest klipper-scripts.  If not, see <http://www.gnu.org/licenses/>.

#################################################################################
#                                                                               #
#              This script updates Klipper to the newest version.               #
#  It allows updating with modified source code (when patched with my scripts)  #
#        without losing the patches or encountering merge conflicts.            #
#  It also verifies that the patches were restored successfully after updating. #
#                                                                               #
#################################################################################

# ========== Paths ==========
KLIPPER_DIR=~/klipper
MCU_FILE="$KLIPPER_DIR/klippy/mcu.py"
NEOPIXEL_FILE="$KLIPPER_DIR/klippy/extras/neopixel.py"

# ========== Defaults ==========
DEFAULT_TIMEOUT=0.025
DEFAULT_SIZE=500

# ========== Color Constants ==========
RESET="\e[0m"
BOLD_YELLOW="\e[1;33m"
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"

# ========== Help Option ==========
if [[ "$1" == "help" || "$1" == "--help" || "$1" == "-h" ]]; then
  echo -e "${BOLD_YELLOW}Klipper Update Script${RESET}"
  echo -e ""
  echo -e "Usage: klipper_update.sh"
  echo -e ""
  echo -e "This script will:"
  echo -e "  • Detect if any files are patched."
  echo -e "  • Save the modified values if patches exist."
  echo -e "  • Remove modified files to avoid conflicts."
  echo -e "  • Pull the latest updates from the Klipper git repository."
  echo -e "  • Reapply your patches to the new files."
  echo -e "  • Restart the Klipper service automatically."
  echo -e ""
  echo -e "${BOLD_YELLOW}Arguments:${RESET}"
  echo -e "  help, --help     Show this help message and exit."
  echo -e ""
  echo -e "${YELLOW}Note:${RESET} This script assumes your Klipper directory is located at ~/klipper."
  exit 0
fi

# ========== Begin ==========
echo -e "${BOLD_YELLOW}Starting Klipper update process...${RESET}"

# ===== Check for existing patches ============================================
echo -e "${BOLD_YELLOW}Checking current file states...${RESET}"

# === === === === === === === === === === === === === === === === === === === #
#    === === === === Every available patch is handled below === === === ===   #
# === === === === === === === === === === === === === === === === === === === #

# Check mcu.py ----------------------------------------------------------------
mcu_current_timeout=$(grep -m 1 "TRSYNC_TIMEOUT" "$MCU_FILE" | grep -o "[0-9.]\+")
if [ "$mcu_current_timeout" != "$DEFAULT_TIMEOUT" ]; then
  mcu_patched=true
  echo -e "${GREEN}mcu.py is patched (timeout: $mcu_current_timeout).${RESET}"
else
  mcu_patched=false
  echo -e "${YELLOW}mcu.py is stock.${RESET}"
fi
# -----------------------------------------------------------------------------

# Check neopixel.py -----------------------------------------------------------
neopixel_current_size=$(grep -m 1 "MAX_MCU_SIZE" "$NEOPIXEL_FILE" | grep -o "[0-9]\+")
if [ "$neopixel_current_size" != "$DEFAULT_SIZE" ]; then
  neopixel_patched=true
  echo -e "${GREEN}neopixel.py is patched (size: $neopixel_current_size).${RESET}"
else
  neopixel_patched=false
  echo -e "${YELLOW}neopixel.py is stock.${RESET}"
fi
# -----------------------------------------------------------------------------

# === === === === === === === === === === === === === === === === === === === #
# === === === === === === === === === === === === === === === === === === === #
# === === === === === === === === === === === === === === === === === === === #

# ----- Prepare for update -----
echo -e "${BOLD_YELLOW}Cleaning modified files...${RESET}"
rm "$MCU_FILE"
rm "$NEOPIXEL_FILE"

# ----- Update Klipper repo -----
echo -e "${BOLD_YELLOW}Pulling latest updates from Klipper repo...${RESET}"
cd "$KLIPPER_DIR" || {
  echo -e "${RED}Failed to change directory! Exiting.${RESET}"
  exit 1
}
git pull

# ----- Re-apply patches -----
echo -e "${BOLD_YELLOW}Reapplying patches if necessary...${RESET}"

# mcu.py patch
if [ "$mcu_patched" = true ]; then
  echo -e "${YELLOW}Re-applying mcu.py patch...${RESET}"
  sed -i "s/TRSYNC_TIMEOUT = [0-9.]\+/TRSYNC_TIMEOUT = $mcu_current_timeout/" "$MCU_FILE"
  if grep -q "TRSYNC_TIMEOUT = $mcu_current_timeout" "$MCU_FILE"; then
    echo -e "${GREEN}mcu.py patch reapplied successfully.${RESET}"
  else
    echo -e "${RED}Failed to reapply mcu.py patch!${RESET}"
  fi
else
  echo "Skipping mcu.py patch (not previously applied)."
fi

# neopixel.py patch
if [ "$neopixel_patched" = true ]; then
  echo -e "${YELLOW}Re-applying neopixel.py patch...${RESET}"
  sed -i "s/MAX_MCU_SIZE = [0-9]\+/MAX_MCU_SIZE = $neopixel_current_size/" "$NEOPIXEL_FILE"
  if grep -q "MAX_MCU_SIZE = $neopixel_current_size" "$NEOPIXEL_FILE"; then
    echo -e "${GREEN}neopixel.py patch reapplied successfully.${RESET}"
  else
    echo -e "${RED}Failed to reapply neopixel.py patch!${RESET}"
  fi
else
  echo "Skipping neopixel.py patch (not previously applied)."
fi

# ----- Final summary -----
echo -e "\n${BOLD_YELLOW}Update Summary:${RESET}"

if [ "$mcu_patched" = true ]; then
  echo -e "${GREEN}• mcu.py: patched and restored.${RESET}"
else
  echo -e "${YELLOW}• mcu.py: stock.${RESET}"
fi

if [ "$neopixel_patched" = true ]; then
  echo -e "${GREEN}• neopixel.py: patched and restored.${RESET}"
else
  echo -e "${YELLOW}• neopixel.py: stock.${RESET}"
fi

# ----- Restart Klipper -----
echo -e "\n${BOLD_YELLOW}Restarting Klipper service...${RESET}"
sudo service klipper restart

if [ $? -eq 0 ]; then
  echo -e "${GREEN}Klipper restarted successfully!${RESET}"
else
  echo -e "${RED}Failed to restart Klipper! Check manually.${RESET}"
fi

echo -e "${BOLD_YELLOW}Update process complete.${RESET}"
