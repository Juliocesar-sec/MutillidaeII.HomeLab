<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>OWASP Mutillidae II Home Lab - Kali Linux Setup</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            max-width: 800px;
            margin: 2rem auto;
            padding: 0 1rem;
            background: #f9f9f9;
            color: #333;
        }
        pre {
            background: #272822;
            color: #f8f8f2;
            padding: 1rem;
            overflow-x: auto;
            border-radius: 5px;
        }
        code {
            font-family: Consolas, monospace;
        }
        h1, h2 {
            color: #007acc;
        }
        hr {
            margin: 2rem 0;
            border: none;
            border-top: 1px solid #ccc;
        }
    </style>
</head>
<body>
    <h1>OWASP Mutillidae II Home Lab - Kali Linux Setup</h1>

    <p>Este guia explica como baixar e rodar o OWASP Mutillidae II no Kali Linux usando Docker.</p>

    <h2>Passo 1: Atualize seu sistema</h2>
    <pre><code>sudo apt update &amp;&amp; sudo apt upgrade -y</code></pre>

    <h2>Passo 2: Instale Git, Docker e Docker Compose (se ainda não instalou)</h2>
    <pre><code>sudo apt install git docker.io docker-compose -y
sudo systemctl start docker
sudo systemctl enable docker
</code></pre>

    <h2>Passo 3: Clone o repositório Mutillidae II</h2>
    <pre><code>git clone https://github.com/webpwnized/mutillidae.git</code></pre>

    <h2>Passo 4: Crie os arquivos <code>Dockerfile</code> e <code>docker-compose.yml</code></h2>

    <h3>Dockerfile</h3>
    <pre><code>FROM php:7.4-apache

RUN docker-php-ext-install mysqli pdo pdo_mysql &amp;&amp; \
    a2enmod rewrite

EXPOSE 80
</code></pre>

    <h3>docker-compose.yml</h3>
    <pre><code>version: '3.8'

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
</code></pre>

    <h2>Passo 5: Inicie o ambiente com Docker Compose</h2>
    <pre><code>docker-compose up --build</code></pre>

    <h2>Passo 6: Acesse o Mutillidae II</h2>
    <p>Abra no navegador:</p>
    <pre><code>http://localhost:8080</code></pre>

    <hr />
    <p>Pronto! Você já tem o Mutillidae II rodando no Kali Linux, via Docker.</p>
</body>
</html>
