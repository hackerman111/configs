#!/usr/bin/env bash
set -euo pipefail

sudo pacman -S --needed cpio cmake git meson gcc

hyprpm update
hyprpm add https://github.com/SsubezZ/hyprtoplr || true
hyprpm enable hyprtoplr

hyprpm add https://github.com/zakk4223/hyprland-easymotion || true
hyprpm enable hyprEasymotion

hyprpm add https://github.com/raybbian/hyprtasking || true
hyprpm enable hyprtasking

hyprpm reload
hyprctl reload
hyprpm list
