#!/usr/bin/env bash

# Terminate already running bar instances
polybar-msg cmd quit

for m in $(polybar --list-monitors | cut -d":" -f1); do
    MONITOR=$m polybar --config=$HOME/.config/polybar/config.ini --reload example &
done
