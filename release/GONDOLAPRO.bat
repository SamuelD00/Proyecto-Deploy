@echo off
chcp 65001 >nul
title GondolaPro - Sistema empaquetado

echo ==========================================
echo        GondolaPro - Sistema empaquetado
echo ==========================================
echo.

cd /d "%~dp0"

echo Verificando Docker...
docker info >nul 2>&1

if errorlevel 1 (
    echo.
    echo ERROR: Docker no esta iniciado.
    echo Abrir Docker Desktop y volver a ejecutar este archivo.
    echo.
    pause
    exit
)

echo.
echo Verificando archivos necesarios...

if not exist "docker-compose.yml" (
    echo ERROR: No se encontro docker-compose.yml en la carpeta release.
    pause
    exit
)

if not exist "init.sql" (
    echo ERROR: No se encontro init.sql en la carpeta release.
    pause
    exit
)

if not exist "imagenes-docker\gondolapro-backend.tar" (
    echo ERROR: No se encontro imagenes-docker\gondolapro-backend.tar
    pause
    exit
)

if not exist "imagenes-docker\gondolapro-frontend.tar" (
    echo ERROR: No se encontro imagenes-docker\gondolapro-frontend.tar
    pause
    exit
)

if not exist "imagenes-docker\sqlserver-2019.tar" (
    echo ERROR: No se encontro imagenes-docker\sqlserver-2019.tar
    pause
    exit
)

echo.
echo Cargando imagen de SQL Server si no existe...
docker image inspect "mcr.microsoft.com/mssql/server:2019-latest" >nul 2>&1
if errorlevel 1 (
    docker load -i "imagenes-docker\sqlserver-2019.tar"
) else (
    echo Imagen SQL Server ya cargada.
)

echo.
echo Cargando imagen del backend si no existe...
docker image inspect "proyecto-deploy-backend:latest" >nul 2>&1
if errorlevel 1 (
    docker load -i "imagenes-docker\gondolapro-backend.tar"
) else (
    echo Imagen backend ya cargada.
)

echo.
echo Cargando imagen del frontend si no existe...
docker image inspect "proyecto-deploy-frontend:latest" >nul 2>&1
if errorlevel 1 (
    docker load -i "imagenes-docker\gondolapro-frontend.tar"
) else (
    echo Imagen frontend ya cargada.
)

echo.
echo Levantando base de datos, backend y frontend...
docker-compose up -d

echo.
echo Esperando a que el sistema termine de iniciar...
timeout /t 25 /nobreak >nul

echo.
echo Abriendo GondolaPro en el navegador...
start http://localhost

echo.
echo ==========================================
echo        Sistema iniciado correctamente
echo ==========================================
echo.
echo Usa GondolaPro normalmente en el navegador.
echo.
echo Cuando termines de usar el sistema, volve a esta ventana
echo y presiona una tecla para detener Docker.
echo.
pause

echo.
echo Cerrando GondolaPro y deteniendo contenedores...
docker-compose down

echo.
echo Sistema detenido correctamente.
pause