#!/usr/bin/env bash
# Проверяем, есть ли хотя бы один выключенный монитор
if hyprctl monitors | grep -q "dpmsStatus: 0"; then
    # Если есть выключенный — включаем все
    hyprctl dispatch dpms on
else
    # Иначе выключаем все
    hyprctl dispatch dpms off
fi
