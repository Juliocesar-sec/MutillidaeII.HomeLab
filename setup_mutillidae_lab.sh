 #!/bin/bash

# --- Colors for better visualization ---
GREEN='\033[0;32m'
YELLOW='\033[0;33m' # Corrected to 0;33m
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}--- Starting OWASP Mutillidae II Home Lab setup ---${NC}"

# --- 1. Check and install prerequisites (Git, Docker, Docker Compose) ---
echo -e "${YELLOW}Checking and installing prerequisites (Git, Docker, Docker Compose)...${NC}"

# Update and upgrade packages
sudo apt update && sudo apt upgrade -y || { echo -e "${RED}Error updating/upgrading packages.${NC}"; exit 1; }

# Install Git
if ! command -v git &> /dev/null
then
    echo -e "${YELLOW}Git not found. Installing Git...${NC}"
    sudo apt install git -y || { echo -e "${RED}Error installing Git.${NC}"; exit 1; }
else
    echo -e "${GREEN}Git is already installed.${NC}"
fi

# Install Docker
if ! command -v docker &> /dev/null
then
    echo -e "${YELLOW}Docker not found. Installing Docker...${NC}"
    sudo apt install docker.io -y || { echo -e "${RED}Error installing Docker.${NC}"; exit 1; }
    sudo systemctl start docker || { echo -e "${RED}Error starting Docker service.${NC}"; exit 1; }
    sudo systemctl enable docker || { echo -e "${RED}Error enabling Docker service.${NC}"; exit 1; }
    # Add the user to the docker group to avoid using sudo
    sudo usermod -aG docker "$USER"
    echo -e "${GREEN}Docker installed. You may need to ${YELLOW}restart your session or log out/log in${GREEN} for Docker permissions to take effect.${NC}"
else
    echo -e "${GREEN}Docker is already installed.${NC}"
    if ! sudo systemctl is-active --quiet docker; then
        echo -e "${YELLOW}Docker service is not active. Starting...${NC}"
        sudo systemctl start docker || { echo -e "${RED}Error starting Docker service.${NC}"; exit 1; }
    fi
    if ! sudo systemctl is-enabled --quiet docker; then
        echo -e "${YELLOW}Docker service is not enabled to start with the system. Enabling...${NC}"
        sudo systemctl enable docker || { echo -e "${RED}Error enabling Docker service.${NC}"; exit 1; }
    fi
fi

# Install Docker Compose
if ! command -v docker-compose &> /dev/null
then
    echo -e "${YELLOW}Docker Compose not found. Installing Docker Compose...${NC}"
    sudo apt install docker-compose -y || { echo -e "${RED}Error installing Docker Compose.${NC}"; exit 1; }
else
    echo -e "${GREEN}Docker Compose is already installed.${NC}"
fi

echo -e "${GREEN}Prerequisites checked and installed.${NC}"

# --- 2. Clone the MutillidaeII.HomeLab repository ---
echo -e "${YELLOW}Cloning the MutillidaeII.HomeLab repository...${NC}"

PROJECT_DIR="mutillidae-lab"
REPO_URL="https://github.com/Juliocesar-sec/MutillidaeII.HomeLab.git"
# The MutillidaeII.HomeLab repository contains the 'mutillidae' directory within it
MUTILLIDAE_SUBDIR="mutillidae" 

if [ -d "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}Directory '$PROJECT_DIR' already exists. Removing to ensure a clean installation...${NC}"
    rm -rf "$PROJECT_DIR" || { echo -e "${RED}Error removing existing directory.${NC}"; exit 1; }
fi

mkdir "$PROJECT_DIR" || { echo -e "${RED}Error creating project directory.${NC}"; exit 1; }
cd "$PROJECT_DIR" || { echo -e "${RED}Error entering project directory.${NC}"; exit 1; }

git clone "$REPO_URL" . || { echo -e "${RED}Error cloning repository '$REPO_URL'.${NC}"; exit 1; } # Clones into the current directory

if [ ! -d "$MUTILLIDAE_SUBDIR" ]; then
    echo -e "${RED}Error: The 'mutillidae' directory was not found after cloning.${NC}"
    echo -e "${RED}Verify that the repository '$REPO_URL' contains the 'mutillidae' folder at its root.${NC}"
    exit 1
fi

echo -e "${GREEN}MutillidaeII.HomeLab repository cloned successfully in '${PWD}'.${NC}"

# --- 3. Create Dockerfile ---
echo -e "${YELLOW}Creating Dockerfile...${NC}"

cat <<EOF > Dockerfile
FROM php:7.4-apache

RUN docker-php-ext-install mysqli pdo pdo_mysql && \\
    a2enmod rewrite

EXPOSE 80
EOF

echo -e "${GREEN}Dockerfile created successfully.${NC}"

# --- 4. Create docker-compose.yml ---
echo -e "${YELLOW}Creating docker-compose.yml...${NC}"

cat <<EOF > docker-compose.yml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "8080:80"
    volumes:
      - ./$MUTILLIDAE_SUBDIR:/var/www/html # Mounts the 'mutillidae' subdirectory
    depends_on:
      - db
    restart: unless-stopped # Ensures the web service restarts automatically

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

echo -e "${GREEN}docker-compose.yml created successfully.${NC}"

# --- 5. Start the Docker environment ---
echo -e "${YELLOW}Building and starting the Docker environment...${NC}"
docker-compose up --build -d || { echo -e "${RED}Error starting the Docker environment.${NC}"; exit 1; }
echo -e "${GREEN}Docker environment started successfully!${NC}"

# --- 6. Access Instructions ---
echo -e "${GREEN}--- OWASP Mutillidae II Home Lab Setup Complete ---${NC}"
echo -e "${GREEN}Your OWASP Mutillidae II instance is ready!${NC}"
echo ""
echo -e "Access Mutillidae II in your browser at:"
echo -e "${YELLOW}http://localhost:8080${NC}"
echo ""
echo -e "If you added your user to the docker group, you may need to ${YELLOW}restart your session or log out/log in${NC} for the new permissions to take effect and for you to use Docker without 'sudo'."
echo ""
echo -e "To stop and remove the containers when you're done, run in the '${PROJECT_DIR}' directory:"
echo -e "${YELLOW}docker-compose down${NC}"
echo ""
echo -e "To completely remove the project directory and its files:"
echo -e "${YELLOW}cd .. && rm -rf ${PROJECT_DIR}${NC}"
echo -e "${GREEN}Have fun exploring and learning!${NC}"
