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
#     This script modifies the TRSYNC_TIMEOUT in the mcu.py file in order to    #
#         relax the strict mcu timing requirements for Klipper printers.        #
#                                                                               #
#################################################################################

# Color Constants
RESET="\e[0m"
BOLD="\e[1m"

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"

# File and defaults
MCU_FILE=~/klipper/klippy/mcu.py
DEFAULT_TIMEOUT="0.025"
PATCHED_TIMEOUT="0.05"

# Help
if [ -z "$1" ] || [ "$1" == "help" ]; then
  echo -e "${BOLD}This script manages patches for${RESET} ${GREEN}mcu.py${RESET}."
  echo ""
  echo -e "The patch adjusts the ${YELLOW}TRSYNC_TIMEOUT${RESET} to help resolve 'Timeout while homing probe' errors."
  echo ""
  echo -e "${RED}Warning:${RESET} Patching will cause Klipper repo verification to fail."
  echo -e "Use the ${BLUE}klipper_update.sh${RESET} script to pull new updates and reapply the patch automatically."
  echo ""
  echo -e "${BOLD}Usage:${RESET} relax_mcu_timing.sh [install|update|reset|patch|check|help]"
  echo -e "  ${BLUE}install${RESET}: Install the custom timeout patch."
  echo -e "  ${BLUE}reset${RESET}: Restore the original mcu.py (removes patch)."
  echo -e "  ${BLUE}check${RESET}: Check if mcu.py is currently patched."
  echo -e "  ${BLUE}help${RESET}: Show this help message."
  echo ""

  if grep -q "TRSYNC_TIMEOUT = $PATCHED_TIMEOUT" "$MCU_FILE"; then
    echo -e "${GREEN}Patch is currently applied.${RESET}"
  else
    echo -e "${RED}Patch is NOT currently applied.${RESET}"
  fi
  exit 0
fi

# Install
if [ "$1" == "install" ]; then
  echo -e "${RED}WARNING:${RESET} This will modify ${GREEN}mcu.py${RESET} and break Klipper repo verification."
  echo "Press any key to continue or CTRL+C to cancel."
  read -n 1 -s
  echo "Installing custom mcu.py file..."
  sed -i "s/TRSYNC_TIMEOUT = $DEFAULT_TIMEOUT/TRSYNC_TIMEOUT = $PATCHED_TIMEOUT/g" "$MCU_FILE"

  if grep -q "TRSYNC_TIMEOUT = $PATCHED_TIMEOUT" "$MCU_FILE"; then
    echo -e "${GREEN}Patch installed successfully.${RESET}"
  else
    echo -e "${RED}Patch install failed!${RESET}"
  fi
fi

# Reset
if [ "$1" == "reset" ]; then
  echo -e "${RED}WARNING:${RESET} This will restore the original TRSYNC_TIMEOUT value in ${GREEN}mcu.py${RESET}."
  echo "Press any key to continue or CTRL+C to cancel."
  read -n 1 -s
  echo "Resetting mcu.py file..."
  sed -i "s/TRSYNC_TIMEOUT = $PATCHED_TIMEOUT/TRSYNC_TIMEOUT = $DEFAULT_TIMEOUT/g" "$MCU_FILE"

  if grep -q "TRSYNC_TIMEOUT = $DEFAULT_TIMEOUT" "$MCU_FILE"; then
    echo -e "${GREEN}Patch successfully reset.${RESET}"
  else
    echo -e "${RED}Reset failed!${RESET}"
  fi
fi

# Check
if [ "$1" == "check" ]; then
  echo "Checking mcu.py patch status..."
  if grep -q "TRSYNC_TIMEOUT = $PATCHED_TIMEOUT" "$MCU_FILE"; then
    echo -e "${RED}mcu.py is patched.${RESET}"
  else
    echo -e "${GREEN}mcu.py is NOT patched.${RESET}"
  fi
fi
