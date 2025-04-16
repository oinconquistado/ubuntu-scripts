#!/bin/bash

# update.sh - Script para atualização completa do sistema e ambientes de desenvolvimento
# Autor: Sebastião Neto
# Data: Abril 2025

echo -e "\n🚀 Iniciando atualização completa do sistema e ambientes..."

# Verificar se os scripts existem
if [ -x "$HOME/bin/sysupdate.sh" ]; then
  # Executa a atualização do sistema
  "$HOME/bin/sysupdate.sh"
else
  echo -e "\n❌ Script de atualização do sistema não encontrado ou não executável!"
fi

if [ -x "$HOME/bin/devupdate.sh" ]; then
  # Executa a atualização dos ambientes de desenvolvimento
  "$HOME/bin/devupdate.sh"
else
  echo -e "\n❌ Script de atualização de ambientes de desenvolvimento não encontrado ou não executável!"
fi

echo -e "\n🎉 Todas as atualizações foram concluídas com sucesso!"
