OWASP Mutillidae II Home Lab

A step-by-step guide to download and run OWASP Mutillidae II, a deliberately vulnerable web application for learning web security, using Docker on Kali Linux.
Prerequisites

    Kali Linux (or any Linux distribution)

    Git installed

    Docker and Docker Compose installed and running

    Note: If Git or Docker are not installed, follow the installation instructions below.

Installing Git and Docker on Kali Linux

sudo apt update && sudo apt upgrade -y
sudo apt install git docker.io docker-compose -y
sudo systemctl start docker
sudo systemctl enable docker

Step 1: Clone the Mutillidae II Repository

Clone the official Mutillidae II repository from GitHub:

git clone https://github.com/webpwnized/mutillidae.git

Change into the cloned directory:

cd mutillidae

Step 2: Create the Dockerfile

In your project root directory (where you want to run the containers), create a file named Dockerfile with the following content:

FROM php:7.4-apache

RUN docker-php-ext-install mysqli pdo pdo_mysql && \
    a2enmod rewrite

EXPOSE 80

Step 3: Create the docker-compose.yml File

Create a file named docker-compose.yml in the same directory with the following content:

version: '3.8'

services:
  web:
    build: .
    ports:
      - "8080:80"
    volumes:
      - ./mutillidae:/var/www/html
    depends_on:
      - db

  db:
    image: mysql:5.7
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: mutillidae
      MYSQL_DATABASE: mutillidae
    volumes:
      - db_data:/var/lib/mysql

volumes:
  db_data:

Step 4: Start the Environment

Build and start the Docker containers by running:

docker-compose up --build

Once started, access Mutillidae II in your browser at:

http://localhost:8080

Step 5: Explore and Learn

Open the URL above and start exploring the security vulnerabilities in Mutillidae II for educational purposes.
