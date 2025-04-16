# Sistema de Scripts para Manutenção do Sistema Linux

Uma coleção de scripts shell para automatizar tarefas de manutenção e atualização do sistema, gerenciamento de recursos e melhoria de produtividade.

Autor: Sebastião Neto  
Data: Abril 2025

## 📋 Visão Geral

Esta coleção de scripts foi criada para facilitar manutenção e atualização do sistema Linux, principalmente focado em distribuições baseadas em Debian/Ubuntu, mas com suporte inteligente para detectar ferramentas disponíveis no seu ambiente.

Características principais:
- ✅ Detecção automática de ferramentas instaladas
- ✅ Mensagens claras com códigos de cores para melhor visualização
- ✅ Tratamento de erros para evitar falhas em ambientes variados
- ✅ Compatível com sistemas que usam diferentes localizações para ferramentas

## 🚀 Scripts Disponíveis

### update.sh
**Script principal de atualização**

Este é o script "mestre" que executa as rotinas de atualização completa do sistema. Ele chama os scripts `sysupdate.sh` e `devupdate.sh` para realizar uma atualização abrangente.

Uso:
```bash
./update.sh
```

### sysupdate.sh
**Atualização do Sistema Operacional**

Atualiza os pacotes do sistema operacional usando apt/apt-get. Realiza atualizações completas, remove pacotes desnecessários e configura pacotes pendentes.

Funcionalidades:
- Atualiza listas de repositórios
- Realiza upgrade dos pacotes instalados
- Executa full-upgrade e dist-upgrade
- Remove pacotes desnecessários (autoremove)
- Configura pacotes pendentes
- Corrige dependências quebradas
- Trata pacotes em fase de distribuição gradual (phasing)

Uso:
```bash
./sysupdate.sh
```

### devupdate.sh
**Atualização de Ambientes de Desenvolvimento**

Atualiza ferramentas e pacotes de desenvolvimento, incluindo gerenciadores de pacotes e runtime environments.

Ferramentas suportadas:
- Bun
- Node.js (via FNM)
- Homebrew
- NPM (incluindo Corepack)
- PNPM

Uso:
```bash
./devupdate.sh
```

### clean.sh
**Limpeza do Sistema**

Realiza uma limpeza abrangente do sistema, removendo caches, arquivos temporários e logs desnecessários.

Funcionalidades:
- Configura pacotes não instalados
- Remove pacotes desnecessários
- Limpa cache do APT
- Limpa logs do sistema (via journalctl)
- Remove arquivos temporários
- Limpa logs antigos
- Limpa caches de gerenciadores de pacotes (Homebrew, NPM, PNPM)

Uso:
```bash
./clean.sh
```

### freemem.sh
**Liberação de Memória**

Libera memória do sistema limpando caches e permitindo encerrar processos que consomem muita RAM.

Funcionalidades:
- Exibe estado atual da memória
- Limpa caches de página, dentries e inodes
- Reinicia área de swap (se disponível)
- Lista processos que consomem mais de 1% de RAM
- Permite seleção interativa de processos para encerrar
- Exibe resumo da memória liberada

Uso:
```bash
./freemem.sh
```

### flush.sh
**Gerenciamento de Portas e Processos**

Identifica e encerra processos que estão utilizando portas de rede específicas.

Funcionalidades:
- Lista processos escutando em portas
- Permite seleção interativa de processos para encerrar
- Tenta métodos progressivamente mais agressivos para encerrar processos resistentes
- Fornece resumo das ações realizadas

Uso:
```bash
./flush.sh
```

### pretend.sh
**Prevenção de Bloqueio de Tela**

Simula pequenos movimentos do mouse para evitar que o sistema bloqueie a tela por inatividade.

Requisitos:
- Depende do xdotool (instalado na maioria das distribuições Linux)

Uso:
```bash
./pretend.sh
```
Pressione Ctrl+C para interromper o script.

## 🛠️ Instalação

1. Clone este repositório ou baixe os scripts
2. Copie os scripts para um diretório no seu PATH (como `~/bin/`)
3. Dê permissão de execução aos scripts:
   ```bash
   chmod +x ~/bin/*.sh
   ```

## 📝 Notas

- Os scripts verificam automaticamente a disponibilidade das ferramentas, ignorando operações relacionadas a ferramentas não instaladas
- Alguns scripts requerem privilégios de administrador (sudo) para certas operações
- Todos os scripts foram projetados para serem seguros e fornecem feedback sobre cada operação realizada

## 🔄 Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para abrir problemas (issues) ou enviar pull requests com melhorias.

## 📜 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo LICENSE para detalhes.