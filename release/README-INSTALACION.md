# Instalación de GóndolaPro

## Descripción

GóndolaPro es una plataforma web para el monitoreo proactivo de productos en góndola.

El sistema permite controlar productos cargados en inventario, detectar productos vencidos o próximos a vencer, registrar retiros, consultar reportes y trabajar con distintas sucursales.

## Tecnologías utilizadas

- Frontend: React + Vite
- Backend: Node.js + Express
- Base de datos: SQL Server
- Contenedores: Docker Compose

## Requisitos previos

Antes de instalar el sistema, el equipo debe tener instalado:

- Docker Desktop
- Git, solo en caso de trabajar desde el repositorio
- Navegador web actualizado

## Instalación

Abrir una terminal en la carpeta del proyecto:

```cmd
cd "C:\Users\alban\Desktop\Programacion\Tercer año\Proyecto\Proyecto-Deploy"
```

Levantar el sistema con Docker Compose:

```cmd
docker-compose up --build
```

Cuando los servicios terminen de iniciar, abrir el navegador en:

```txt
http://localhost
```

## Servicios incluidos

El sistema levanta los siguientes servicios:

- Base de datos SQL Server.
- Servicio de inicialización de base de datos.
- Backend API.
- Frontend web servido con Nginx.

## Acceso al sistema

Para ingresar al sistema se puede utilizar el login configurado en los datos iniciales del proyecto.

Ejemplo de acceso por PIN:

```txt
PIN: 0000
```

## Comandos útiles

Apagar el sistema:

```cmd
docker-compose down
```

Levantar nuevamente:

```cmd
docker-compose up --build
```

Ver contenedores activos:

```cmd
docker-compose ps
```

Ver logs:

```cmd
docker-compose logs -f
```

## Observaciones para entrega

Esta carpeta representa una primera etapa del empaquetado del sistema.

El objetivo es preparar una instalación más simple para un entorno cliente, evitando que el usuario final tenga que configurar manualmente frontend, backend y base de datos.

En una etapa posterior se puede avanzar con:

- Imagen Docker final de producción.
- Variables de entorno definitivas.
- Ofuscación o compilación del backend.
- Publicación de imágenes en un registry privado.
- Instalador o guía final para el cliente.