#!/bin/bash

# flush.sh - Script para encerrar processos em portas específicas
# Autor: Sebastião Neto
# Data: Abril 2025

# Create a temporary file to store the formatted output
rm -f /tmp/flush_ports.txt
touch /tmp/flush_ports.txt

# Get fresh list of listening processes
LISTEN_DATA=$(lsof -i -P -n | grep LISTEN)

# Save the raw data for debugging
echo "$LISTEN_DATA" > /tmp/flush_debug.txt

# Process the data directly without using associative arrays
if [ -n "$LISTEN_DATA" ]; then
  # Criar um arquivo temporário para processar os dados
  rm -f /tmp/flush_processed.txt
  touch /tmp/flush_processed.txt
  
  # Primeiro passo: extrair dados brutos para um formato intermediário
  echo "$LISTEN_DATA" | while read -r LINE; do
    PROC=$(echo "$LINE" | awk '{print $1}')
    PID=$(echo "$LINE" | awk '{print $2}')
    PORT_INFO=$(echo "$LINE" | awk '{print $9}')
    PORT=$(echo "$PORT_INFO" | sed 's/.*://')
    
    # Double check process is still running
    if ps -p "$PID" > /dev/null 2>&1; then
      echo "$PROC $PID $PORT" >> /tmp/flush_processed.txt
    fi
  done
  
  # Segundo passo: agrupar portas por PID
  if [ -s /tmp/flush_processed.txt ]; then
    # Ordenar por PID para facilitar o agrupamento
    sort -k2 -n /tmp/flush_processed.txt > /tmp/flush_sorted.txt
    
    # Variáveis para acompanhar o agrupamento
    CURRENT_PID=""
    CURRENT_PROC=""
    PORTS=""
    
    # Processar linha por linha e agrupar
    while read -r PROC PID PORT; do
      if [ "$PID" != "$CURRENT_PID" ]; then
        # Se mudarmos de PID, salve o anterior (se existir)
        if [ -n "$CURRENT_PID" ]; then
          echo "$CURRENT_PROC $CURRENT_PID [$PORTS]" >> /tmp/flush_ports.txt
        fi
        # Inicie um novo grupo
        CURRENT_PID="$PID"
        CURRENT_PROC="$PROC"
        PORTS="$PORT"
      else
        # Mesmo PID, adicione a porta à lista
        PORTS="$PORTS, $PORT"
      fi
    done < /tmp/flush_sorted.txt
    
    # Não esqueça de salvar o último grupo
    if [ -n "$CURRENT_PID" ]; then
      echo "$CURRENT_PROC $CURRENT_PID [$PORTS]" >> /tmp/flush_ports.txt
    fi
    
    # Limpar arquivos temporários
    rm -f /tmp/flush_processed.txt /tmp/flush_sorted.txt
  fi
fi

# Check if there are any processes to display
if [ ! -s /tmp/flush_ports.txt ]; then
 
  # Se temos dados brutos mas nenhum processado, mostra uma mensagem de diagnóstico
  if [ -s /tmp/flush_debug.txt ]; then
    printf "\n\033[1;32m✨ Não foram encontrados processos ouvindo em portas!\033[0m\n"
    cat /tmp/flush_debug.txt
  else
    printf "Nenhum processo detectado pelo lsof.\n"
  fi
  
  exit 0
fi

printf "\n\033[1;36m🎯 Selecione os processos para encerrar (use espaço e enter):\033[0m\n"
sleep 1

SELECTION=$(gum choose --no-limit --header="🔪 Selecione os processos a encerrar:" < /tmp/flush_ports.txt)

# Inicializar contadores e arrays FORA do loop para evitar perda de valores
TOTAL_KILLED=0
declare -a FAILED_PIDS
declare -a KILLED_PIDS

if [ -n "$SELECTION" ]; then
  while read -r LINE; do
    PID=$(echo "$LINE" | awk '{print $2}')
    PROC=$(echo "$LINE" | awk '{print $1}')
    if [[ "$PID" =~ ^[0-9]+$ ]]; then
      printf "Encerrando %s (PID: %s)... " "$PROC" "$PID"
      
      # Primeiro tenta um encerramento mais suave (SIGTERM)
      sudo kill -15 "$PID" 2>/dev/null
      sleep 1
      
      # Verifica se o processo ainda está em execução
      if ! ps -p "$PID" > /dev/null 2>&1; then
        KILLED_PIDS+=("$PID")
        TOTAL_KILLED=$((TOTAL_KILLED + 1))
        printf "\033[1;32mSucesso!\033[0m\n"
        continue
      fi
      
      # Tenta com SIGKILL se o SIGTERM não funcionou
      sudo kill -9 "$PID" 2>/dev/null
      sleep 1
      
      # Tenta encerrar processos filhos também (importante para apps como Discord)
      sudo pkill -9 -P "$PID" 2>/dev/null
      sleep 0.5
      
      # Tenta matar o processo novamente após encerrar os filhos
      sudo kill -9 "$PID" 2>/dev/null
      sleep 1
      
      # Verifica o status final
      if ! ps -p "$PID" > /dev/null 2>&1; then
        KILLED_PIDS+=("$PID")
        TOTAL_KILLED=$((TOTAL_KILLED + 1))
        printf "\033[1;32mSucesso (após múltiplas tentativas)!\033[0m\n"
      else
        FAILED_PIDS+=("$PID")
        printf "\033[1;31mFalha!\033[0m\n"
      fi
    fi
  done <<< "$SELECTION"
fi

printf "\n\033[1;34m📦 Resumo da limpeza de portas:\033[0m\n"
printf "   🔪 \033[1;36mProcessos encerrados:\033[0m %s\n" "$TOTAL_KILLED"

# Verify if all ports were actually closed with fresh check
sleep 2  # Give more time for ports to be released
STILL_OPEN=$(lsof -i -P -n | grep LISTEN)

# Check for processes we tried to kill
STILL_RUNNING=false
for PID in "${KILLED_PIDS[@]}"; do
  if ps -p $PID > /dev/null 2>&1; then
    STILL_RUNNING=true
    break
  fi
done

if [[ "$STILL_RUNNING" = true || ${#FAILED_PIDS[@]} -gt 0 ]]; then
  printf "\n\033[1;31m⚠️  Alguns processos não puderam ser encerrados!\033[0m\n"
  
  for PID in "${FAILED_PIDS[@]}"; do
    if ps -p $PID > /dev/null 2>&1; then
      printf "  - PID %s ainda está em execução\n" "$PID"
    fi
  done
  
  printf "\n   Deseja tentar métodos alternativos? (S/n): "
  read -r FORCE_KILL
  
  if [[ "$FORCE_KILL" != "n" && "$FORCE_KILL" != "N" ]]; then
    for PID in "${FAILED_PIDS[@]}"; do
      if ps -p $PID > /dev/null 2>&1; then
        printf "Tentando métodos alternativos para encerrar PID %s...\n" "$PID"
        sudo kill -9 "$PID" 2>/dev/null
        sleep 1
        
        # If still running, try more aggressive methods
        if ps -p $PID > /dev/null 2>&1; then
          sudo pkill -9 -P "$PID" 2>/dev/null  # Kill child processes
          sudo kill -9 "$PID" 2>/dev/null      # Try again
        fi
      fi
    done
    
    # Final verification
    sleep 2
    FINAL_CHECK=$(lsof -i -P -n | grep LISTEN)
    if [[ -n "$FINAL_CHECK" ]]; then
      printf "\n\033[1;33m⚠️  Ainda existem portas abertas. Considere reiniciar o sistema ou verificar manualmente com:\033[0m\n"
      printf "   \033[1;36mlsof -i -P -n | grep LISTEN\033[0m\n"
    else
      printf "\n\033[1;32m✅ Todas as portas foram fechadas com sucesso!\033[0m\n"
    fi
  fi
else
  printf "\n\033[1;32m✅ Todas as portas foram fechadas com sucesso!\033[0m\n"
fi

printf "\n\033[1;32m✨ Limpeza de portas concluída!\033[0m\n"
