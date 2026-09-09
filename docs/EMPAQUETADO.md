# Empaquetado del Proyecto GóndolaPro

## Objetivo

El objetivo del empaquetado es preparar el sistema para que pueda instalarse en una computadora o servidor del cliente sin tener que configurar manualmente cada parte del proyecto.

La aplicación está formada por tres capas principales:

- Frontend web desarrollado con React/Vite.
- Backend API desarrollado con Node.js y Express.
- Base de datos SQL Server.

Para facilitar la instalación se utiliza Docker Compose, permitiendo levantar todos los servicios con un solo comando.

## Estructura general del sistema

El proyecto principal se encuentra organizado de la siguiente manera:

```txt
Proyecto-Deploy/
├── backend/
├── frontend/
├── docker-compose.yml
├── docs/
└── release/