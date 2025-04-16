#!/bin/bash

# sysupdate.sh - Script para atualização do sistema
# Autor: Sebastião Neto
# Data: Abril 2025

# Encontrar caminhos das ferramentas dinamicamente
APT=$(command -v apt 2>/dev/null)
APT_GET=$(command -v apt-get 2>/dev/null)
DPKG=$(command -v dpkg 2>/dev/null)

# Verificar se estamos em um sistema baseado em Debian/Ubuntu
if [ -z "$APT" ] && [ -z "$APT_GET" ]; then
  echo -e "\n❌ Este script requer apt ou apt-get, que não foram encontrados. Pulando atualização do sistema."
  exit 1
fi

# Se apt não estiver disponível, usar apt-get
[ -z "$APT" ] && APT="$APT_GET"
# Se dpkg não estiver disponível, tentar continuar sem ele
[ -z "$DPKG" ] && echo -e "\n⚠️ dpkg não encontrado, algumas operações podem falhar."

echo -e "\n🔄 Iniciando atualização do sistema..."

sudo bash -c "
  echo -e \"\\n📋 Atualizando listas de repositórios...\" && 
  $APT update || echo -e \"\\n❌ Erro ao atualizar repositórios.\";
  
  echo -e \"\\n⬆️  Atualizando pacotes instalados...\" && 
  $APT upgrade -y || echo -e \"\\n❌ Erro ao realizar upgrade.\";
  
  echo -e \"\\n🚀 Realizando atualização completa...\" && 
  $APT full-upgrade -y || echo -e \"\\n❌ Erro ao realizar full-upgrade.\";
  
  echo -e \"\\n🗑️  Removendo pacotes desnecessários...\" && 
  $APT autoremove -y || echo -e \"\\n❌ Erro ao remover pacotes.\";
  
  # Executar dpkg apenas se disponível
  if [ -n \"$DPKG\" ]; then
    echo -e \"\\n🔧 Configurando pacotes pendentes...\" && 
    $DPKG --configure -a || echo -e \"\\n❌ Erro ao configurar pacotes.\";
  fi
  
  echo -e \"\\n🔄 Corrigindo dependências quebradas...\" && 
  $APT install -f -y || echo -e \"\\n❌ Erro ao corrigir dependências.\";
  
  echo -e \"\\n🌐 Atualizando para novas versões de distribuição...\" && 
  $APT dist-upgrade -y || echo -e \"\\n❌ Erro ao realizar dist-upgrade.\";

  # Força a atualização de pacotes específicos e resolve o aviso de WARN
  if [ -n \"$APT_GET\" ]; then
    echo -e \"\\n📦 Atualizando dependências especiais...\" && 
    $APT_GET install --only-upgrade glob inflight uuid 2>/dev/null || echo -e \"\\nℹ️ Alguns pacotes específicos não encontrados.\";

    # Tenta lidar com pacotes em phasing e não atualizados
    echo -e \"\\n⚙️  Tentando resolver pacotes em fase de distribuição gradual...\" && 
    $APT_GET dist-upgrade --assume-yes --allow-downgrades --fix-broken --no-install-recommends || echo -e \"\\nℹ️ Alguns pacotes ainda estão no phasing.\";

    # Força a atualização de pacotes que estão em phasing
    echo -e \"\\n⚡ Forçando atualização de pacotes systemd em fase de distribuição gradual...\" && 
    $APT_GET install --only-upgrade libnss-mymachines libnss-systemd libpam-systemd \
      libsystemd-shared libsystemd0 libudev1 systemd systemd-container systemd-dev \
      systemd-oomd systemd-resolved systemd-sysv systemd-timesyncd udev --assume-yes --fix-missing || true;
  fi
    
  echo -e \"\\n✅ Atualização do sistema concluída!\"
"
