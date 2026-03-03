#!/usr/bin/env bash

# Путь к твоему конфигу hyprpaper
CONFIG_FILE="/home/papayka/configs/.config/hypr/hyprpaper.conf"

# Пути к твоим обоям
WALL1="/home/papayka/configs/wall1.jpg"
WALL2="/home/papayka/configs/wall2.png"

# Проверяем, какие обои прописаны в конфиге прямо сейчас
if grep -q "$WALL2" "$CONFIG_FILE"; then
    # Если сейчас wall2, меняем на wall1
    sed -i "s|$WALL2|$WALL1|g" "$CONFIG_FILE"
else
    # Иначе меняем на wall2
    sed -i "s|$WALL1|$WALL2|g" "$CONFIG_FILE"
fi

# Перезапускаем hyprpaper, чтобы применить новый конфиг
killall hyprpaper
sleep 0.1 # Небольшая пауза, чтобы процесс успел завершиться
nohup hyprpaper --config "$CONFIG_FILE" > /dev/null 2>&1 &
