#!/bin/bash

# freemem.sh - Script para limpar memória do sistema
# Autor: Sebastião Neto
# Data: Abril 2025

printf "\n\033[1;34m🧠 Iniciando limpeza de memória do sistema...\033[0m\n"

printf "\n\033[1;36m📊 Estado atual da memória:\033[0m\n"
free -h

BEFORE_MEM=$(free -m | awk "/^Mem:/ {print \$3}")

printf "\n\033[1;34m🧹 Limpando caches de página, dentries e inodes...\033[0m\n"
sudo sh -c "sync && echo 3 > /proc/sys/vm/drop_caches" &&
  printf "\033[1;32m✅ Caches limpos com sucesso!\033[0m\n" ||
  printf "\033[1;31m❌ Erro ao limpar caches.\033[0m\n"

if [ -n "$(swapon --show)" ]; then
  printf "\n\033[1;34m🔄 Reiniciando área de swap...\033[0m\n"
  sudo swapoff -a && sudo swapon -a &&
    printf "\033[1;32m✅ Swap reiniciada com sucesso!\033[0m\n" ||
    printf "\033[1;31m❌ Erro ao reiniciar swap.\033[0m\n"
else
  printf "\n\033[1;33m⚠️ Nenhuma área de swap ativa detectada.\033[0m\n"
fi

printf "\n\033[1;36m📈 Estado da memória após limpeza:\033[0m\n"
free -h

printf "\n\033[1;34m📋 Processos com mais de 1%% de uso de RAM (ordenados por tempo de execução):\033[0m\n"

ps -eo pid,etimes,comm,%mem --sort=etimes | tac | awk '$4 >= 1.0' |
  awk '{printf "%-6s %-10s %-25s %s%%\n", $1, $2 "s", $3, $4}' > /tmp/freemem_procs.txt

printf "\n\033[1;36m🎯 Selecione os processos para encerrar (use espaço e enter):\033[0m\n"
sleep 1

SELECTION=$(gum choose --no-limit --header="🔪 Selecione os processos a encerrar:" < /tmp/freemem_procs.txt)

TOTAL_KILLED=0
MEM_FREED=0

if [ -n "$SELECTION" ]; then
  echo "$SELECTION" | while read -r LINE; do
    PID=$(echo "$LINE" | awk '{print $1}')
    if [[ "$PID" =~ ^[0-9]+$ ]]; then
      PROC_RSS=$(ps -p "$PID" -o rss= | tr -d "[:blank:]")
      if [ -n "$PROC_RSS" ]; then
        MEM_FREED=$(echo "$MEM_FREED + $PROC_RSS" | bc)
      fi
      sudo kill -9 "$PID" 2>/dev/null && TOTAL_KILLED=$((TOTAL_KILLED + 1))
    fi
  done
fi

AFTER_MEM=$(free -m | awk "/^Mem:/ {print \$3}")
CLEANED_MEM_MB=$((BEFORE_MEM - AFTER_MEM))
MEM_FREED_MI=$(echo "scale=2; $MEM_FREED/1024" | bc)

printf "\n\033[1;34m📦 Resumo da limpeza:\033[0m\n"
printf "   🔪 \033[1;36mProcessos encerrados:\033[0m %s\n" "$TOTAL_KILLED"
printf "   🧠 \033[1;36mMemória liberada (estimada):\033[0m \033[1;32m%s MiB\033[0m\n" "$MEM_FREED_MI"
printf "   📉 \033[1;36mUso de memória antes:\033[0m \033[1;33m%s MiB\033[0m\n" "$BEFORE_MEM"
printf "   📈 \033[1;36mUso de memória depois:\033[0m \033[1;33m%s MiB\033[0m\n" "$AFTER_MEM"

printf "\n\033[1;32m✨ Limpeza de memória concluída!\033[0m\n"
