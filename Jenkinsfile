pipeline {
    agent any

    environment {
        RELEASE_DIR = "release"
        IMAGES_DIR = "release\\imagenes-docker"
        ZIP_NAME = "GondolaPro-Release.zip"
        BACKEND_IMAGE = "proyecto-deploy-backend:latest"
        FRONTEND_IMAGE = "proyecto-deploy-frontend:latest"
        SQLSERVER_IMAGE = "mcr.microsoft.com/mssql/server:2019-latest"
    }

    stages {
        stage('Preparar repositorio') {
            steps {
                echo 'Actualizando submodulos...'
                bat 'git submodule update --init --recursive'
            }
        }

        stage('Verificar backend') {
            steps {
                echo 'Instalando dependencias del backend...'
                dir('backend') {
                    bat 'npm install'
                }
            }
        }

        stage('Verificar frontend') {
            steps {
                echo 'Instalando dependencias y generando build del frontend...'
                dir('frontend') {
                    bat 'npm install'
                    bat 'npm run build'
                }
            }
        }

        stage('Construir imagenes Docker') {
            steps {
                echo 'Construyendo imagenes Docker del sistema...'
                bat 'docker-compose build'

                echo 'Etiquetando imagenes para el paquete release...'
                bat 'docker tag gondolapro-empaquetado-backend:latest proyecto-deploy-backend:latest'
                bat 'docker tag gondolapro-empaquetado-frontend:latest proyecto-deploy-frontend:latest'
    }
}

        stage('Preparar carpeta release') {
            steps {
                echo 'Preparando carpeta release...'

                bat 'if not exist "%IMAGES_DIR%" mkdir "%IMAGES_DIR%"'

                echo 'Copiando script de base de datos...'
                bat 'copy /Y init.sql release\\init.sql'
            }
        }

        stage('Exportar imagenes Docker') {
            steps {
                echo 'Exportando imagen backend...'
                bat 'docker save -o release\\imagenes-docker\\gondolapro-backend.tar %BACKEND_IMAGE%'

                echo 'Exportando imagen frontend...'
                bat 'docker save -o release\\imagenes-docker\\gondolapro-frontend.tar %FRONTEND_IMAGE%'

                echo 'Exportando imagen SQL Server...'
                bat 'docker image inspect %SQLSERVER_IMAGE% >nul 2>&1 || docker pull %SQLSERVER_IMAGE%'
                bat 'docker save -o release\\imagenes-docker\\sqlserver-2019.tar %SQLSERVER_IMAGE%'
            }
        }

               stage('Generar ZIP final') {
                   steps {
                       echo 'Generando carpeta final de entrega...'

                       bat 'if exist "GondolaPro-Release" rmdir /s /q "GondolaPro-Release"'
                       bat 'xcopy "release" "GondolaPro-Release" /E /I /Y'

                       echo 'Generando ZIP final de entrega...'

                       bat 'if exist "%ZIP_NAME%" del "%ZIP_NAME%"'
                       bat 'tar -a -c -f "%ZIP_NAME%" GondolaPro-Release'
            }
        }
    }

    post {
        success {
            echo 'Pipeline finalizado correctamente. El paquete GondolaPro-Release.zip fue generado.'
            archiveArtifacts artifacts: 'GondolaPro-Release.zip', fingerprint: true
        }

        failure {
            echo 'El pipeline fallo. Revisar los logs de Jenkins para detectar el problema.'
        }
    }
}