Ótima ideia! Vamos criar um script para automatizar a configuração do seu ambiente de laboratório para o OWASP Mutillidae II Home Lab, que você mencionou anteriormente. Este script simplificará o processo de instalação do Git e Docker, clonagem do repositório e inicialização da aplicação vulnerável.
Script de Configuração Rápida do OWASP Mutillidae II Home Lab

Este script irá:

    Verificar e Instalar Pré-requisitos: Garantir que o Git, Docker e Docker Compose estejam instalados e funcionando.
    Clonar o Repositório: Baixar o projeto MutillidaeII.HomeLab do GitHub.
    Configurar o Ambiente Docker: Criar o Dockerfile e o docker-compose.yml baseados na sua solicitação inicial.
    Iniciar o Ambiente: Construir e iniciar os containers Docker para o Mutillidae II e o banco de dados.
    Fornecer Instruções de Acesso: Mostrar como acessar a aplicação no navegador.

Salve o conteúdo abaixo em um arquivo chamado setup_mutillidae_lab.sh (ou qualquer nome com a extensão .sh), torne-o executável (chmod +x setup_mutillidae_lab.sh) e execute-o (./setup_mutillidae_lab.sh).
Bash

#!/bin/bash

# --- Cores para melhor visualização ---
GREEN='\033[0;32m'
YELLOW='\033[0;33m' # Corrigido para 0;33m
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}--- Iniciando a configuração do OWASP Mutillidae II Home Lab ---${NC}"

# --- 1. Verificar e instalar pré-requisitos (Git, Docker, Docker Compose) ---
echo -e "${YELLOW}Verificando e instalando pré-requisitos (Git, Docker, Docker Compose)...${NC}"

# Atualiza e faz upgrade dos pacotes
sudo apt update && sudo apt upgrade -y || { echo -e "${RED}Erro ao atualizar/fazer upgrade dos pacotes.${NC}"; exit 1; }

# Instala Git
if ! command -v git &> /dev/null
then
    echo -e "${YELLOW}Git não encontrado. Instalando Git...${NC}"
    sudo apt install git -y || { echo -e "${RED}Erro ao instalar Git.${NC}"; exit 1; }
else
    echo -e "${GREEN}Git já está instalado.${NC}"
fi

# Instala Docker
if ! command -v docker &> /dev/null
then
    echo -e "${YELLOW}Docker não encontrado. Instalando Docker...${NC}"
    sudo apt install docker.io -y || { echo -e "${RED}Erro ao instalar Docker.${NC}"; exit 1; }
    sudo systemctl start docker || { echo -e "${RED}Erro ao iniciar o serviço Docker.${NC}"; exit 1; }
    sudo systemctl enable docker || { echo -e "${RED}Erro ao habilitar o serviço Docker.${NC}"; exit 1; }
    # Adicionar o usuário ao grupo docker para evitar o uso de sudo
    sudo usermod -aG docker "$USER"
    echo -e "${GREEN}Docker instalado. Você precisará ${YELLOW}reiniciar sua sessão ou fazer logout/login${GREEN} para que as permissões do Docker entrem em vigor.${NC}"
else
    echo -e "${GREEN}Docker já está instalado.${NC}"
    if ! sudo systemctl is-active --quiet docker; then
        echo -e "${YELLOW}O serviço Docker não está ativo. Iniciando...${NC}"
        sudo systemctl start docker || { echo -e "${RED}Erro ao iniciar o serviço Docker.${NC}"; exit 1; }
    fi
    if ! sudo systemctl is-enabled --quiet docker; then
        echo -e "${YELLOW}O serviço Docker não está habilitado para iniciar com o sistema. Habilitando...${NC}"
        sudo systemctl enable docker || { echo -e "${RED}Erro ao habilitar o serviço Docker.${NC}"; exit 1; }
    fi
fi

# Instala Docker Compose
if ! command -v docker-compose &> /dev/null
then
    echo -e "${YELLOW}Docker Compose não encontrado. Instalando Docker Compose...${NC}"
    sudo apt install docker-compose -y || { echo -e "${RED}Erro ao instalar Docker Compose.${NC}"; exit 1; }
else
    echo -e "${GREEN}Docker Compose já está instalado.${NC}"
fi

echo -e "${GREEN}Pré-requisitos verificados e instalados.${NC}"

# --- 2. Clonar o repositório MutillidaeII.HomeLab ---
echo -e "${YELLOW}Clonando o repositório MutillidaeII.HomeLab...${NC}"

PROJECT_DIR="mutillidae-lab"
REPO_URL="https://github.com/Juliocesar-sec/MutillidaeII.HomeLab.git"
# O repositório MutillidaeII.HomeLab contém o diretório 'mutillidae' dentro dele
MUTILLIDAE_SUBDIR="mutillidae" 

if [ -d "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}Diretório '$PROJECT_DIR' já existe. Removendo para garantir uma instalação limpa...${NC}"
    rm -rf "$PROJECT_DIR" || { echo -e "${RED}Erro ao remover diretório existente.${NC}"; exit 1; }
fi

mkdir "$PROJECT_DIR" || { echo -e "${RED}Erro ao criar diretório do projeto.${NC}"; exit 1; }
cd "$PROJECT_DIR" || { echo -e "${RED}Erro ao entrar no diretório do projeto.${NC}"; exit 1; }

git clone "$REPO_URL" . || { echo -e "${RED}Erro ao clonar o repositório '$REPO_URL'.${NC}"; exit 1; } # Clona no diretório atual

if [ ! -d "$MUTILLIDAE_SUBDIR" ]; then
    echo -e "${RED}Erro: O diretório 'mutillidae' não foi encontrado após a clonagem.${NC}"
    echo -e "${RED}Verifique se o repositório '$REPO_URL' contém a pasta 'mutillidae' na raiz.${NC}"
    exit 1
fi

echo -e "${GREEN}Repositório MutillidaeII.HomeLab clonado com sucesso em '${PWD}'.${NC}"

# --- 3. Criar Dockerfile ---
echo -e "${YELLOW}Criando Dockerfile...${NC}"

cat <<EOF > Dockerfile
FROM php:7.4-apache

RUN docker-php-ext-install mysqli pdo pdo_mysql && \\
    a2enmod rewrite

EXPOSE 80
EOF

echo -e "${GREEN}Dockerfile criado com sucesso.${NC}"

# --- 4. Criar docker-compose.yml ---
echo -e "${YELLOW}Criando docker-compose.yml...${NC}"

cat <<EOF > docker-compose.yml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "8080:80"
    volumes:
      - ./$MUTILLIDAE_SUBDIR:/var/www/html # Monta o subdiretório 'mutillidae'
    depends_on:
      - db
    restart: unless-stopped # Garante que o serviço web reinicie automaticamente

  db:
    image: mysql:5.7
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: mutillidae
      MYSQL_DATABASE: mutillidae
    volumes:
      - db_data:/var/lib/mysql

volumes:
  db_data:
EOF

echo -e "${GREEN}docker-compose.yml criado com sucesso.${NC}"

# --- 5. Iniciar o ambiente Docker ---
echo -e "${YELLOW}Construindo e iniciando o ambiente Docker...${NC}"
docker-compose up --build -d || { echo -e "${RED}Erro ao iniciar o ambiente Docker.${NC}"; exit 1; }
echo -e "${GREEN}Ambiente Docker iniciado com sucesso!${NC}"

# --- 6. Instruções de Acesso ---
echo -e "${GREEN}--- Configuração do OWASP Mutillidae II Home Lab Concluída ---${NC}"
echo -e "${GREEN}Sua instância do OWASP Mutillidae II está pronta!${NC}"
echo ""
echo -e "Acesse o Mutillidae II em seu navegador através do endereço:"
echo -e "${YELLOW}http://localhost:8080${NC}"
echo ""
echo -e "Se você adicionou seu usuário ao grupo docker, pode precisar ${YELLOW}reiniciar sua sessão ou fazer logout/login${NC} para que as novas permissões entrem em vigor e você possa usar o Docker sem 'sudo'."
echo ""
echo -e "Para parar e remover os containers quando terminar, execute no diretório '${PROJECT_DIR}':"
echo -e "${YELLOW}docker-compose down${NC}"
echo ""
echo -e "Para remover completamente o diretório do projeto e seus arquivos:"
echo -e "${YELLOW}cd .. && rm -rf ${PROJECT_DIR}${NC}"
echo -e "${GREEN}Divirta-se explorando e aprendendo!${NC}"
