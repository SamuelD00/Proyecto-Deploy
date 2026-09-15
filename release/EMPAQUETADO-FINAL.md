# Empaquetado final - GondolaPro

## Objetivo del empaquetado

El objetivo del empaquetado es preparar el sistema GondolaPro para que pueda ejecutarse de forma simple en una computadora o servidor, sin que el usuario tenga que iniciar manualmente cada parte del proyecto.

El sistema está compuesto por:

- Frontend desarrollado en React.
- Backend desarrollado con Node.js y Express.
- Base de datos SQL Server.
- Script de inicialización de base de datos.
- Docker Compose para levantar todos los servicios juntos.

## Qué se empaquetó

Se preparó una estructura de ejecución local utilizando Docker Compose.

El empaquetado permite levantar automáticamente:

1. Base de datos SQL Server.
2. Script `init.sql` para crear la base, tablas y datos iniciales.
3. Backend API.
4. Frontend web servido con Nginx.
5. Aplicación disponible desde el navegador en `http://localhost`.

## Lanzador del sistema

Se creó un archivo llamado:

`GONDOLAPRO.bat`

Este archivo funciona como lanzador principal del sistema empaquetado.

Al ejecutarlo, realiza las siguientes acciones:

1. Se posiciona automáticamente en la carpeta principal del proyecto.
2. Ejecuta Docker Compose.
3. Construye y levanta los contenedores necesarios.
4. Abre el sistema en el navegador.
5. Mantiene una ventana abierta para que el usuario pueda detener el sistema al finalizar.
6. Al presionar una tecla, detiene los contenedores de Docker.

## Ventajas del empaquetado

Este empaquetado permite:

- Evitar iniciar frontend, backend y base de datos por separado.
- Reducir errores de configuración manual.
- Ejecutar todo el sistema con un solo archivo.
- Facilitar la instalación en otra computadora.
- Documentar los requisitos y pasos de uso.
- Presentar el sistema de forma más profesional.

## Requisitos previos

Para utilizar el sistema empaquetado, la computadora debe tener instalado:

- Docker Desktop.
- Navegador web.
- Sistema operativo Windows.

## Archivos principales

La estructura principal del proyecto queda organizada de la siguiente forma:

```txt
Proyecto-Deploy/
├── backend/
├── frontend/
├── docker-compose.yml
├── init.sql
├── docs/
│   └── EMPAQUETADO.md
└── release/
    ├── README-INSTALACION.md
    ├── .env.example
    ├── GONDOLAPRO.bat
    └── EMPAQUETADO-FINAL.md