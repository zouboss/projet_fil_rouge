pipeline {
    agent any

    environment {
        PATH = "/opt/sonar-scanner/bin:$PATH"
        DOCKER_USER = 'zouboss'
        BACKEND_IMAGE = "${DOCKER_USER}/projetfilrouge_backend"
        FRONTEND_IMAGE = "${DOCKER_USER}/projetfilrouge_frontend"
        MIGRATE_IMAGE = "${DOCKER_USER}/projetfilrouge_migrate"
        SONAR_HOST_URL = 'https://68f3-41-82-155-229.ngrok-free.app'
        SONAR_BACK_TOKEN = credentials('projet_fil_rouge_cred')
        SONAR_FRONT_TOKEN = credentials('projet_fil_rouge_cred')
    }

    stages {
        stage('Cloner le dépôt') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/zouboss/projet_fil_rouge.git'
            }
        }

       /* stage('Tests') {
            steps {
                sh '''
                    cd Backend
                    pip install -r requirements.txt
                    pytest
                '''
                sh '''
                    cd Frontend
                    npm install
                    npm test
                '''
            }
        }
        */
        stage('Analyse SonarQube Backend') {
            steps {
                sh '''
                    sonar-scanner \
                        -Dsonar.projectKey=test_sonar_backend_fil_rouge \
                        -Dsonar.sources=Backend \
                        -Dsonar.exclusions=**/migrations/**,**/venv/**,**/.venv/**,**/__pycache__/** \
                        -Dsonar.host.url=$SONAR_HOST_URL \
                        -Dsonar.login=$SONAR_BACK_TOKEN \
                        -Dsonar.python.version=3
                '''
            }
        }

        stage('Analyse SonarQube Frontend') {
            steps {
                dir('Frontend') {
                    sh '''
                        sonar-scanner \
                            -Dsonar.projectKey=test_sonar_frontend_fil_rouge \
                            -Dsonar.sources=src \
                            -Dsonar.exclusions=**/node_modules/**,**/dist/**,**/build/** \
                            -Dsonar.host.url=$SONAR_HOST_URL \
                            -Dsonar.login=$SONAR_FRONT_TOKEN \
                            -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info
                    '''
                }
            }
        }

        stage('Build des images') {
            steps {
                sh 'docker build -t $BACKEND_IMAGE:latest ./Backend/odc'
                sh 'docker build -t $FRONTEND_IMAGE:latest ./Frontend'
                sh 'docker build -t $MIGRATE_IMAGE:latest ./Backend/odc'
            }
        }

        stage('Push des images sur Docker Hub') {
            steps {
                withDockerRegistry([credentialsId: 'docker_cred', url: '']) {
                    sh 'docker push $BACKEND_IMAGE:latest'
                    sh 'docker push $FRONTEND_IMAGE:latest'
                    sh 'docker push $MIGRATE_IMAGE:latest'
                }
            }
        }

        stage('Déploiement local avec Docker Compose') {
            steps {
                sh '''
                    docker-compose down || true
                    docker-compose pull
                    docker-compose up -d --build
                '''
            }
        }
    }

    post {
        success {
            mail to: 'alassanebenzecoly@gmail.com',
                 subject: "✅ Déploiement local réussi",
                 body: "L'application a été déployée localement avec succès."
        }
        failure {
            mail to: 'alassanebenzecoly@gmail.com',
                 subject: "❌ Échec du pipeline Jenkins",
                 body: "Une erreur s’est produite, merci de vérifier Jenkins."
        }
    }
}
