# 🚀 Proyecto Deploy

Repositorio orquestador del sistema de monitoreo de vencimientos. Levanta frontend, backend y base de datos con un solo comando usando Docker.

---

## 📋 Requisitos previos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) instalado y corriendo
- Git instalado

---

## ⚙️ Configuración de SQL Server (solo quien tenga SQL Server local)

Para que Docker pueda conectarse al SQL Server instalado en tu máquina, necesitás hacer estos cambios en **SQL Server Configuration Manager**:

### 1. Habilitar TCP/IP
1. Abrí **SQL Server Configuration Manager**
2. Entrá a **SQL Server Network Configuration → Protocols for SQLEXPRESS**
3. Hacé doble click en **TCP/IP** y cambiá el estado a **Enabled**

### 2. Configurar el puerto 1433
1. Con **TCP/IP** abierto, andá a la pestaña **IP Addresses**
2. Bajá hasta la sección **IPAll**
3. En **TCP Dynamic Ports** → borrá el valor y dejalo **vacío**
4. En **TCP Port** → escribí `1433`
5. Hacé click en **OK**

### 3. Reiniciar el servicio de SQL Server
1. En SQL Server Configuration Manager, entrá a **SQL Server Services**
2. Clic derecho en **SQL Server (SQLEXPRESS)** → **Restart**

O desde PowerShell como administrador:
```powershell
Restart-Service -Name 'MSSQL$SQLEXPRESS'
```

### 4. Abrir el puerto en el Firewall de Windows
Desde PowerShell como administrador:
```powershell
New-NetFirewallRule -DisplayName "SQL Server" -Direction Inbound -Protocol TCP -LocalPort 1433 -Action Allow
```

---

## 🚀 Cómo usar este repositorio

### 1. Clonar el proyecto (primera vez)
```bash
git clone --recurse-submodules https://github.com/tuusuario/Proyecto-Deploy.git
cd Proyecto-Deploy
```

### 2. Levantar todo
```bash
docker-compose up --build
```

La primera vez tarda unos minutos porque Docker descarga la imagen de SQL Server, inicializa la base de datos y buildea el frontend y backend.

### 3. Acceder a la aplicación
| Servicio | URL |
|---|---|
| Frontend | http://localhost |
| Backend | http://localhost:3000 |
| SQL Server | localhost:1433 |

### 4. Usuario admin por defecto
| Campo | Valor |
|---|---|
| Email | admin@gondola.com |
| Password | 1234 |
| PIN | 0000 |

---

## 🔧 Comandos principales

### Levantar todo
```bash
docker-compose up --build
```

### Levantar en segundo plano
```bash
docker-compose up --build -d
```

### Ver logs en tiempo real
```bash
docker-compose logs -f
```

### Ver logs de un servicio específico
```bash
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f db
```

### Apagar los contenedores (mantiene los datos de la DB)
```bash
docker-compose down
```

### Apagar y borrar la base de datos
> ⚠️ Esto borra todos los datos del contenedor. Usalo solo cuando quieras reiniciar la DB desde cero.
```bash
docker-compose down -v
```

### Reconstruir un solo servicio
```bash
docker-compose up --build backend
docker-compose up --build frontend
```

---

## 🗄️ Cómo actualizar los datos de la base de datos

Cuando quieras agregar datos nuevos o modificar los existentes seguí estos pasos:

### 1. Exportar el nuevo script desde SSMS
1. En SSMS, clic derecho en `ProyectoBD` → **Tasks** → **Generate Scripts**
2. Seleccioná todas las tablas
3. En **Establecer opciones de scripting** → **Avanzadas** → **Types of data to script** → elegí **Schema and data**
4. Guardá el archivo como `init.sql` en la carpeta raíz de este repo, reemplazando el anterior

### 2. Subir el cambio al repo
```bash
git add init.sql
git commit -m "Actualizar datos de la base"
git push
```

### 3. Reiniciar la base de datos con los datos nuevos
```bash
docker-compose down -v
docker-compose up --build
```

> El `-v` borra el volumen viejo con los datos anteriores. El nuevo `init.sql` se ejecuta automáticamente al levantar.

## 📁 Estructura del repositorio

```
Proyecto-Deploy/
├── docker-compose.yml       ← orquesta todos los servicios
├── init.sql                 ← crea y carga la base de datos
├── README.md                ← esta guía
├── Proyecto-Backend-main/   ← submodule del backend
└── ProyectoFront/           ← submodule del frontend
```
