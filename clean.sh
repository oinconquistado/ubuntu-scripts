#!/bin/bash

# clean.sh - Script para limpeza do sistema
# Autor: Sebastião Neto
# Data: Abril 2025

# Encontrar caminhos das ferramentas dinamicamente
APT=$(command -v apt 2>/dev/null || echo "/usr/bin/apt")
DPKG=$(command -v dpkg 2>/dev/null || echo "/usr/bin/dpkg")
FIND=$(command -v find 2>/dev/null || echo "/usr/bin/find")
JOURNALCTL=$(command -v journalctl 2>/dev/null || echo "/usr/bin/journalctl")
RM=$(command -v rm 2>/dev/null || echo "/usr/bin/rm")
BREW=$(command -v brew 2>/dev/null || echo "/home/linuxbrew/.linuxbrew/bin/brew")
NPM=$(command -v npm 2>/dev/null || echo "/usr/bin/npm")
PNPM=$(command -v pnpm 2>/dev/null || echo "$HOME/.local/share/pnpm/pnpm")

echo -e "\n🧹 Iniciando limpeza do sistema..."

# System cleanup (requires sudo)
echo -e "\n🔐 Executando limpeza do sistema (requer sudo)..."
sudo bash -c "
  echo -e \"\\n🔧 Configurando pacotes não instalados...\" && 
  $DPKG --configure -a && $APT install -f -y;
  
  echo -e \"\\n🗑️  Removendo pacotes desnecessários...\" && 
  $APT autoremove -y;
  
  echo -e \"\\n🧹 Limpando cache do APT...\" && 
  $APT clean || echo -e \"\\n❌ Erro ao limpar cache.\";
  
  echo -e \"\\n📜 Limpando logs do sistema...\" && 
  $JOURNALCTL --vacuum-size=100M || echo -e \"\\n❌ Erro ao limpar logs do sistema.\";
  
  echo -e \"\\n🗄️ Limpando arquivos temporários...\" && 
  $RM -rf /tmp/* /var/tmp/* 2>/dev/null || true;
  
  echo -e \"\\n📋 Limpando logs antigos...\" && 
  $FIND /var/log -type f -name \"*.log\" -delete || echo -e \"\\n❌ Erro ao limpar logs antigos.\";
"

# Package managers cleanup (alphabetically sorted)

# Homebrew cleanup
if command -v brew &>/dev/null; then
  echo -e "\n🍺 Limpando cache do Homebrew..."
  $BREW cleanup --prune=all && echo -e "\n✨ Cache do Homebrew limpo!" || echo -e "\n❌ Erro ao limpar cache do Homebrew."
fi

# NPM cleanup
if command -v npm &>/dev/null; then
  echo -e "\n📦 Limpando cache do NPM..."
  $NPM cache clean --force && echo -e "\n✨ Cache do NPM limpo!" || echo -e "\n❌ Erro ao limpar cache do NPM."
fi

# PNPM cleanup
if command -v pnpm &>/dev/null; then
  echo -e "\n🔄 Limpando cache do PNPM..."
  $PNPM store prune && echo -e "\n✨ Cache do PNPM limpo!" || echo -e "\n❌ Erro ao limpar cache do PNPM."
fi

echo -e "\n✅ Limpeza concluída com sucesso!"
