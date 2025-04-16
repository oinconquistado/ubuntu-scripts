#!/bin/bash

# devupdate.sh - Script para atualização dos ambientes de desenvolvimento
# Autor: Sebastião Neto
# Data: Abril 2025

# Encontrar caminhos das ferramentas dinamicamente
BREW=$(command -v brew 2>/dev/null || echo "/home/linuxbrew/.linuxbrew/bin/brew")
BUN=$(command -v bun 2>/dev/null || echo "$HOME/.bun/bin/bun")
FNM=$(command -v fnm 2>/dev/null || echo "/home/linuxbrew/.linuxbrew/bin/fnm")
NPM=$(command -v npm 2>/dev/null || echo "/usr/bin/npm")
PNPM=$(command -v pnpm 2>/dev/null || echo "$HOME/.local/share/pnpm/pnpm")

echo -e "\n🛠️  Iniciando atualização dos ambientes de desenvolvimento..."

# Bun update
if command -v bun &>/dev/null; then
  echo -e "\n⚡ Atualizando Bun..."
  $BUN upgrade --stable && echo -e "\n✨ Bun atualizado com sucesso || echo -e "\n❌ Erro ao atualizar Bun."
fi

# FNM update
if command -v fnm &>/dev/null; then
  echo -e "\n📊 Atualizando Node.js via FNM..."
  $FNM install --lts && echo -e "\n✨ Node.js LTS instalado/atualizado com sucesso || echo -e "\n❌ Erro ao atualizar Node.js."
fi

# Homebrew update
if command -v brew &>/dev/null; then
  echo -e "\n🍺 Atualizando Homebrew e suas fórmulas..."
  $BREW update && echo -e "\n📋 Fórmulas do Homebrew atualizadas!" && 
  $BREW upgrade && echo -e "\n⬆️ Pacotes do Homebrew atualizados!" && 
  $BREW cleanup && echo -e "\n🧹 Cache do Homebrew limpo!" || 
  echo -e "\n❌ Erro ao atualizar Homebrew."
fi

# NPM update
if command -v npm &>/dev/null; then
  echo -e "\n📦 Atualizando pacotes globais do NPM..."
  $NPM -g update && echo -e "\n✨ Pacotes NPM atualizados || echo -e "\n❌ Erro ao atualizar pacotes npm."
  
  echo -e "\n🔄 Atualizando Corepack..."
  $NPM install --global corepack@latest && echo -e "\n✨ Corepack atualizado || echo -e "\n❌ Erro ao atualizar corepack."
fi

# PNPM update
if command -v pnpm &>/dev/null; then
  echo -e "\n🔄  Atualizando pacotes globais do PNPM..."
  $PNPM -g update && echo -e "\n✨ Pacotes PNPM atualizados || echo -e "\n❌ Erro ao atualizar pacotes pnpm."
  
  echo -e "\n⬆️ Atualizando PNPM para a última versão..."
  $PNPM self-update && echo -e "\n✨ PNPM atualizado para a versão mais recente || echo -e "\n❌ Erro ao atualizar PNPM."
fi

echo -e "\n✅ Atualização de ambientes de desenvolvimento concluída!"
