# Instalación de GondolaPro

## Descripción

GondolaPro es una plataforma web para el monitoreo proactivo de productos en góndola.

El sistema permite controlar productos cargados en inventario, detectar productos vencidos o próximos a vencer, registrar retiros, consultar reportes y trabajar con distintas sucursales.

## Tipo de empaquetado

Esta entrega corresponde a un empaquetado local mediante Docker.

El sistema se entrega sin el código fuente original del frontend y del backend.

El frontend se encuentra compilado como build de producción y servido mediante Nginx.

El backend fue empaquetado mediante bytenode, generando un archivo compilado en formato `.jsc`, evitando entregar directamente la carpeta `src` con el código fuente original.

## Tecnologías utilizadas

- Frontend: React + Vite
- Servidor web frontend: Nginx
- Backend: Node.js + Express
- Base de datos: SQL Server
- Contenedores: Docker Compose
- Empaquetado backend: bytenode

## Requisitos previos

La computadora donde se ejecute el sistema debe tener instalado:

- Docker Desktop
- Navegador web
- Sistema operativo Windows

## Archivos incluidos

La carpeta de entrega contiene:

```txt
GondolaPro-Release/
├── GONDOLAPRO.bat
├── docker-compose.yml
├── init.sql
├── README-INSTALACION.md
├── .env.example
└── imagenes-docker/
    ├── gondolapro-backend.tar
    ├── gondolapro-frontend.tar
    └── sqlserver-2019.tar