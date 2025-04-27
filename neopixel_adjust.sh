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
#    This script modifies the MAX_MCU_SIZE in the neopixel.py file based on     #
#      your LED strip configuration (RGB or RGBW and the number of LEDs).       #
#                                                                               #
#################################################################################

# Color Constants
RESET="\e[0m"
BOLD="\e[1m"

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
WHITE="\e[37m"

BOLD_YELLOW="\e[1;33m"
BOLD_RED="\e[1;31m"

# File and defaults
NEOFILE=~/klipper/klippy/extras/neopixel.py
DEFAULT_SIZE=500

# Help
if [ -z "$1" ] || [[ "$1" == "help" || "$1" == "--help" || "$1" == "-h" ]]; then
  echo -e "This script adjusts ${BOLD_YELLOW}MAX_MCU_SIZE${RESET} in ${GREEN}neopixel.py${RESET} based on your LED strip."
  echo -e "The integer value represents the number of ${BOLD_RED}channels${RESET} per strip."
  echo "This value is used to determine how many LEDs can be controlled by a microcontroller (MCU)."
  echo -e "The script will calculate this value based on the type (${RED}R${GREEN}G${BLUE}B${RESET} or ${RED}R${GREEN}G${BLUE}B${WHITE}W${RESET}) and length of your LED strip."
  echo ""
  echo -e "${RED}Warning:${RESET} Patching will cause Klipper repo verification to fail."
  echo -e "Use the ${BLUE}klipper_update.sh${RESET} script to pull new updates and reapply the patch automatically."
  echo ""
  echo -e "${BOLD}Usage:${RESET} neopixel_adjust.sh [install|reset|check|help]"
  echo -e "  ${BLUE}install${RESET}: Prompt for LED strip information and modify ${GREEN}neopixel.py${RESET} if needed."
  echo -e "  ${BLUE}reset${RESET}: Restore the default ${BOLD_YELLOW}MAX_MCU_SIZE${RESET} value (500)."
  echo -e "  ${BLUE}check${RESET}: Display the current ${BOLD_YELLOW}MAX_MCU_SIZE${RESET} value."
  echo -e "  ${BLUE}help${RESET}: Show this help message."
  echo ""
  exit 0
fi

## Install
if [ "$1" == "install" ]; then
  echo -e "${GREEN}Let's tune your LED strip settings!${RESET}"

  # Ask for RGB or RGBW
  while true; do
    echo -e "Is your strip ${RED}R${GREEN}G${BLUE}B${RESET} or ${RED}R${GREEN}G${BLUE}B${WHITE}W${RESET}? (Enter '${RED}r${GREEN}g${BLUE}b${RESET}' or '${RED}r${GREEN}g${BLUE}b${WHITE}w${RESET}'): \c"
    read -r color_type
    color_type=$(echo "$color_type" | tr '[:upper:]' '[:lower:]')
    if [ "$color_type" == "rgb" ] || [ "$color_type" == "rgbw" ]; then
      break
    else
      echo "Please enter either 'rgb' or 'rgbw'."
    fi
  done

  # Ask for number of LEDs
  while true; do
    read -rp "How many LEDs are on your strip? (numbers only): " led_count
    if [[ "$led_count" =~ ^[0-9]+$ ]]; then
      break
    else
      echo "Numbers, darling. Just numbers."
    fi
  done

  # Calculate needed size
  if [ "$color_type" == "rgb" ]; then
    total_size=$((led_count * 3))
  else
    total_size=$((led_count * 4))
  fi

  echo "Calculated MCU size needed: $total_size"

  # Fetch current size
  current_size=$(grep -m 1 "MAX_MCU_SIZE" "$NEOFILE" | grep -o "[0-9]\+")

  if [ "$total_size" -le "$DEFAULT_SIZE" ]; then
    echo -e "${GREEN}Modification not necessary. Your setup fits the default size.${RESET}"
    if [ "$current_size" -ne "$DEFAULT_SIZE" ]; then
      echo -e "${YELLOW}Resetting MAX_MCU_SIZE back to default ($DEFAULT_SIZE)...${RESET}"
      sed -i "0,/MAX_MCU_SIZE = [0-9]\+/s/MAX_MCU_SIZE = [0-9]\+/MAX_MCU_SIZE = $DEFAULT_SIZE/" "$NEOFILE"
      echo -e "${GREEN}Reset successfully!${RESET}"
    fi
    exit 0
  else
    echo -e "${RED}Modification needed! Updating MAX_MCU_SIZE...${RESET}"
    sed -i "0,/MAX_MCU_SIZE = [0-9]\+/s/MAX_MCU_SIZE = [0-9]\+/MAX_MCU_SIZE = $total_size/" "$NEOFILE"
    if grep -q "MAX_MCU_SIZE = $total_size" "$NEOFILE"; then
      echo -e "${GREEN}MAX_MCU_SIZE updated successfully to $total_size!${RESET}"
    else
      echo -e "${RED}Update failed! Please check manually.${RESET}"
    fi
  fi
fi

## Reset
if [ "$1" == "reset" ]; then
  echo -e "${RED}WARNING: This will reset${RESET} ${BOLD_YELLOW}MAX_MCU_SIZE${RESET} ${RED}back to $DEFAULT_SIZE.${RESET}"
  echo "Press any key to continue or CTRL+C to cancel."
  read -n 1 -s
  echo -e "Resetting ${BOLD_YELLOW}MAX_MCU_SIZE${RESET} to $DEFAULT_SIZE..."
  sed -i "0,/MAX_MCU_SIZE = [0-9]\+/s/MAX_MCU_SIZE = [0-9]\+/MAX_MCU_SIZE = $DEFAULT_SIZE/" "$NEOFILE"
  if grep -q "MAX_MCU_SIZE = $DEFAULT_SIZE" "$NEOFILE"; then
    echo -e "${GREEN}Reset successfully!${RESET}"
  else
    echo -e "${RED}Reset failed! Please check manually.${RESET}"
  fi
fi

## Check
if [ "$1" == "check" ]; then
  echo -e "Checking current ${BOLD_YELLOW}MAX_MCU_SIZE${RESET}..."
  current_size=$(grep -m 1 "MAX_MCU_SIZE" "$NEOFILE" | grep -o "[0-9]\+")

  if [ "$current_size" -eq "$DEFAULT_SIZE" ]; then
    echo -e "${GREEN}MAX_MCU_SIZE is default: $current_size${RESET}"
  else
    echo -e "${RED}MAX_MCU_SIZE is modified: $current_size${RESET}"
  fi
fi
