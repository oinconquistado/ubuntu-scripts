#!/bin/bash

# devupdate.sh - Script para atualização dos ambientes de desenvolvimento
# Autor: Sebastião Neto
# Data: Abril 2025

# Encontrar caminhos das ferramentas dinamicamente
BREW=$(command -v brew 2>/dev/null)
BUN=$(command -v bun 2>/dev/null)
FNM=$(command -v fnm 2>/dev/null)
NPM=$(command -v npm 2>/dev/null)
PNPM=$(command -v pnpm 2>/dev/null)

echo -e "\n🛠️  Iniciando atualização dos ambientes de desenvolvimento..."

# Bun update
if [ -n "$BUN" ]; then
  echo -e "\n⚡ Atualizando Bun..."
  $BUN upgrade --stable && echo -e "\n✨ Bun atualizado com sucesso" || echo -e "\n❌ Erro ao atualizar Bun."
else
  echo -e "\n⏭️  Bun não encontrado, pulando atualização..."
fi

# FNM update
if [ -n "$FNM" ]; then
  echo -e "\n📊 Atualizando Node.js via FNM..."
  $FNM install --lts && echo -e "\n✨ Node.js LTS instalado/atualizado com sucesso" || echo -e "\n❌ Erro ao atualizar Node.js."
else
  echo -e "\n⏭️  FNM não encontrado, pulando atualização..."
fi

# Homebrew update
if [ -n "$BREW" ]; then
  echo -e "\n🍺 Atualizando Homebrew e suas fórmulas..."
  $BREW update && echo -e "\n📋 Fórmulas do Homebrew atualizadas!" && 
  $BREW upgrade && echo -e "\n⬆️ Pacotes do Homebrew atualizados!" && 
  $BREW cleanup && echo -e "\n🧹 Cache do Homebrew limpo!" || 
  echo -e "\n❌ Erro ao atualizar Homebrew."
else
  echo -e "\n⏭️  Homebrew não encontrado, pulando atualização..."
fi

# NPM update
if [ -n "$NPM" ]; then
  echo -e "\n📦 Atualizando pacotes globais do NPM..."
  $NPM -g update && echo -e "\n✨ Pacotes NPM atualizados" || echo -e "\n❌ Erro ao atualizar pacotes npm."
  
  echo -e "\n🔄 Atualizando Corepack..."
  $NPM install --global corepack@latest && echo -e "\n✨ Corepack atualizado" || echo -e "\n❌ Erro ao atualizar corepack."
else
  echo -e "\n⏭️  NPM não encontrado, pulando atualização..."
fi

# PNPM update
if [ -n "$PNPM" ]; then
  echo -e "\n🔄  Atualizando pacotes globais do PNPM..."
  $PNPM -g update && echo -e "\n✨ Pacotes PNPM atualizados" || echo -e "\n❌ Erro ao atualizar pacotes pnpm."
  
  echo -e "\n⬆️ Atualizando PNPM para a última versão..."
  $PNPM self-update && echo -e "\n✨ PNPM atualizado para a versão mais recente" || echo -e "\n❌ Erro ao atualizar PNPM."
else
  echo -e "\n⏭️  PNPM não encontrado, pulando atualização..."
fi

echo -e "\n✅ Atualização de ambientes de desenvolvimento concluída!"
