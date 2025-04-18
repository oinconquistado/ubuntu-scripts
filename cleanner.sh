#!/bin/bash

# clean.sh - Script para limpeza do sistema
# Autor: Sebastião Neto
# Data: Abril 2025

# Encontrar caminhos das ferramentas dinamicamente
APT=$(command -v apt 2>/dev/null)
DPKG=$(command -v dpkg 2>/dev/null)
FIND=$(command -v find 2>/dev/null)
JOURNALCTL=$(command -v journalctl 2>/dev/null)
RM=$(command -v rm 2>/dev/null)
BREW=$(command -v brew 2>/dev/null)
NPM=$(command -v npm 2>/dev/null)
PNPM=$(command -v pnpm 2>/dev/null)

echo -e "\n🧹 Iniciando limpeza do sistema..."

# Verificar ferramentas essenciais do sistema
if [ -z "$RM" ]; then
  echo -e "\n⚠️ rm não encontrado, algumas operações de limpeza podem falhar."
fi

# System cleanup (requires sudo)
echo -e "\n🔐 Executando limpeza do sistema (requer sudo)..."
sudo bash -c "
  # Configurando pacotes não instalados (apenas se DPKG e APT existirem)
  if [ -n \"$DPKG\" ] && [ -n \"$APT\" ]; then
    echo -e \"\\n🔧 Configurando pacotes não instalados...\" && 
    $DPKG --configure -a && $APT install -f -y;
  else
    echo -e \"\\n⏭️ dpkg ou apt não encontrados, pulando configuração de pacotes...\";
  fi
  
  # Removendo pacotes desnecessários (apenas se APT existir)
  if [ -n \"$APT\" ]; then
    echo -e \"\\n🗑️  Removendo pacotes desnecessários...\" && 
    $APT autoremove -y;
    
    echo -e \"\\n🧹 Limpando cache do APT...\" && 
    $APT clean || echo -e \"\\n❌ Erro ao limpar cache.\";
  else
    echo -e \"\\n⏭️ apt não encontrado, pulando limpeza de pacotes...\";
  fi
  
  # Limpando logs do sistema (apenas se JOURNALCTL existir)
  if [ -n \"$JOURNALCTL\" ]; then
    echo -e \"\\n📜 Limpando logs do sistema...\" && 
    $JOURNALCTL --vacuum-size=100M || echo -e \"\\n❌ Erro ao limpar logs do sistema.\";
  else
    echo -e \"\\n⏭️ journalctl não encontrado, pulando limpeza de logs do sistema...\";
  fi
  
  # Limpando arquivos temporários (apenas se RM existir)
  if [ -n \"$RM\" ]; then
    echo -e \"\\n🗄️ Limpando arquivos temporários...\" && 
    $RM -rf /tmp/* /var/tmp/* 2>/dev/null || true;
  else
    echo -e \"\\n⏭️ rm não encontrado, pulando limpeza de arquivos temporários...\";
  fi
  
  # Limpando logs antigos (apenas se FIND existir)
  if [ -n \"$FIND\" ]; then
    echo -e \"\\n📋 Limpando logs antigos...\" && 
    $FIND /var/log -type f -name \"*.log\" -delete || echo -e \"\\n❌ Erro ao limpar logs antigos.\";
  else
    echo -e \"\\n⏭️ find não encontrado, pulando limpeza de logs antigos...\";
  fi
"

# Package managers cleanup (alphabetically sorted)

# Homebrew cleanup
if [ -n "$BREW" ]; then
  echo -e "\n🍺 Limpando cache do Homebrew..."
  $BREW cleanup --prune=all && echo -e "\n✨ Cache do Homebrew limpo!" || echo -e "\n❌ Erro ao limpar cache do Homebrew."
else
  echo -e "\n⏭️ Homebrew não encontrado, pulando limpeza..."
fi

# NPM cleanup
if [ -n "$NPM" ]; then
  echo -e "\n📦 Limpando cache do NPM..."
  $NPM cache clean --force && echo -e "\n✨ Cache do NPM limpo!" || echo -e "\n❌ Erro ao limpar cache do NPM."
else
  echo -e "\n⏭️ NPM não encontrado, pulando limpeza..."
fi

# PNPM cleanup
if [ -n "$PNPM" ]; then
  echo -e "\n🔄 Limpando cache do PNPM..."
  $PNPM store prune && echo -e "\n✨ Cache do PNPM limpo!" || echo -e "\n❌ Erro ao limpar cache do PNPM."
else
  echo -e "\n⏭️ PNPM não encontrado, pulando limpeza..."
fi

echo -e "\n✅ Limpeza concluída com sucesso!"
