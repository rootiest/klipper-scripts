# Rootiest Klipper Scripts

This repository contains a collection of scripts designed to enhance
and customize the functionality of Klipper firmware.

These scripts allow you to apply patches to the Klipper firmware source code
to improve or modify its behavior/restrictions.

## Warnings \[PLEASE READ BEFORE USING!\]

> [!CAUTION]
> Applying these modifications will cause your Klipper UI
> (Mainsail, Fluidd, KlipperScreen, etc) to consider
> the Klipper installation "dirty" and will show a warning message.

This is expected behavior, as these scripts modify the source code.

However, it is important to understand that by putting the software in that state,
**you will no longer be able to update it through the UI** without losing the modifications
made by these scripts.

A [klipper_update.sh script](#3-klipper_updatesh) is provided to help you update
Klipper while preserving the modifications made by these scripts.

Using the update script you can keep your Klipper installation up to date
and continue to use the modifications.

> [!IMPORTANT]
> You will need to use the `klipper_update.sh` script
> to perform updates of Klipper after using
> any of the other scripts in this repository.

---

## Installation

To install the repository, clone it to your local machine:

```bash
git clone https://github.com/rootiest/klipper-scripts.git ~/klipper-scripts
```

The scripts can then be found in the `~/klipper-scripts` directory.

Installing the repository will give you access to all the scripts
but will not make any modifications to your Klipper installation.

No modifications are made until you run the scripts you wish to use.

Alternative, you can just download the individual scripts you need.
They all are able to function independently of each other.

However, you may wish to have the `klipper_update.sh` script
to make updating Klipper easier and there is no real disadvantage to
installing the repository so you have all the scripts available to use.

---

## Scripts Overview

### 1. `relax_mcu_timing.sh`

This script modifies the `TRSYNC_TIMEOUT` value in the `mcu.py` file
to relax strict MCU timing requirements,
helping to resolve "Timeout while homing probe" or "Timeout with MCU" errors.

#### When to Use

You may want to use this modification if you frequently encounter timeout errors
and no other solutions have helped.

#### Usage

```bash
~/klipper-scripts/relax_mcu_timing.sh [install|update|reset|patch|check|help]
```

- **install**: Apply the custom timeout patch.
- **reset**: Restore the original `mcu.py` file.
- **check**: Check if the patch is currently applied.
- **help**: Display usage instructions.

You must include a command when running the script
or it will only display the usage instructions.

---

### 2. `neopixel_adjust.sh`

This script adjusts the `MAX_MCU_SIZE` value in the `neopixel.py` file
based on your LED strip configuration (RGB or RGBW and the number of LEDs)
allowing longer LED strips to be used with Klipper.

#### When to Use

You may want to use this modification if you encounter an error with
the `chain_count` value in your neopixel configuration.

Klipper has a default limit of 500 channels, which is:

- 166 RGB LEDs (3 channels each)
- 125 RGBW LEDs (4 channels each)

If you are unsure whether you need this modification, give it a try.

This script will prompt you for the length and type of your LED strip
and apply the modification only if necessary.

#### Usage

```bash
~/klipper-scripts/neopixel_adjust.sh [install|reset|check|help]
```

- **install**: Configure the LED strip settings and modify `neopixel.py`.
- **reset**: Restore the default `MAX_MCU_SIZE` value.
- **check**: Display the current `MAX_MCU_SIZE` value.
- **help**: Display usage instructions.

You must include a command when running the script
or it will only display the usage instructions.

---

### 3. `klipper_update.sh`

This script updates Klipper to the latest version while preserving
any patches applied by other scripts in this repository.

#### Features

- Automatically detects and reapplies patches after updating.
- Ensures a smooth update process without losing custom modifications.

#### Usage

Unlike the others, this script does not require any arguments or have any user prompts.

It is designed so that it can be run automatically
or unattended for auto-update configurations.

Simply run the script to update Klipper:

```bash
~/klipper-scripts/klipper_update.sh
```

---

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE).
See the [LICENSE](./LICENSE) file for more details.

---

## Disclaimer

> [!WARNING]
> These scripts modify Klipper source files and may cause the Klipper
> repository verification to fail. Use them at your own risk
> and ensure you have backups of your configuration files.

---

## Contributions

Contributions, bug reports, and feature requests are welcome!
Feel free to open an issue or submit a pull request.

---

## Author

Created by Chris Laprade (<chris@rootiest.com>).
