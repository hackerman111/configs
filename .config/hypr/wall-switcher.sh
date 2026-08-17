#!/usr/bin/env bash

# Путь к твоему конфигу hyprpaper
CONFIG_FILE="/home/papayka/configs/.config/hypr/hyprpaper.conf"

# Пути к твоим обоям
WALL1="/home/papayka/configs/wall1.jpg"
WALL2="/home/papayka/configs/wall2.png"
WALL3="/home/papayka/configs/wall3.png"
WALL4="/home/papayka/configs/wall4.png"

# Проверяем, какие обои прописаны в конфиге прямо сейчас, и меняем их по кругу
if grep -q "$WALL1" "$CONFIG_FILE"; then
    # Если сейчас wall1, меняем на wall2
    sed -i "s|$WALL1|$WALL2|g" "$CONFIG_FILE"

elif grep -q "$WALL2" "$CONFIG_FILE"; then
    # Если сейчас wall2, меняем на wall3
    sed -i "s|$WALL2|$WALL3|g" "$CONFIG_FILE"

elif grep -q "$WALL3" "$CONFIG_FILE"; then
    # Если сейчас wall3, возвращаемся к wall1
    sed -i "s|$WALL3|$WALL4|g" "$CONFIG_FILE"

elif grep -q "$WALL4" "$CONFIG_FILE"; then
    # Если сейчас wall3, возвращаемся к wall1
    sed -i "s|$WALL4|$WALL1|g" "$CONFIG_FILE"
fi

# Перезапускаем hyprpaper, чтобы применить новый конфиг
killall hyprpaper
sleep 0.1 # Небольшая пауза, чтобы процесс успел завершиться
nohup hyprpaper --config "$CONFIG_FILE" > /dev/null 2>&1 &
