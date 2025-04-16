#!/bin/bash

# pretend.sh - Script para simular movimento do mouse e evitar bloqueio de tela
# Autor: Sebastião Neto
# Data: Abril 2025

# Encontrar caminho do xdotool dinamicamente
XDOTOOL=$(command -v xdotool 2>/dev/null || echo "/usr/bin/xdotool")
SLEEP=$(command -v sleep 2>/dev/null || echo "/usr/bin/sleep")

echo -e "\n🐭 Iniciando simulação de movimento do mouse (Ctrl+C para parar)..."

while true; do 
  echo -e "\n👆 Movendo mouse..." 
  $XDOTOOL mousemove_relative 10 0
  $SLEEP 60
  echo -e "\n👇 Revertendo movimento..." 
  $XDOTOOL mousemove_relative -- -10 0
  $SLEEP 60
done
