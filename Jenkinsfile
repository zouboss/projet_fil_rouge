pipeline {
    agent any

    environment {
        DOCKER_USER = 'zouboss'
        BACKEND_IMAGE = "${zouboss}/projetfilrouge_backend"
        FRONTEND_IMAGE = "${zouboss}/projetfilrouge_frontend"
        MIGRATE_IMAGE = "${zouboss}/projetfilrouge_migrate"
    }

    stages {
        stage('Cloner le dépôt') {
            steps {
                git 'https://github.com/zouboss/projet_fil_rouge.git'
            }
        }

        stage('Tests') {
            steps {
                sh 'cd backend && pip install -r requirements.txt && pytest'
                sh 'cd frontend && npm install && npm test'
            }
        }

        stage('Build des images') {
            steps {
                sh 'docker build -t $projetfilrouge_backend:latest ./backend'
                sh 'docker build -t $projetfilrouge_frontend:latest ./frontend'
                sh 'docker build -t $projetfilrouge_migrate:latest ./backend' // ou ./migrate si tu as un dossier spécifique
            }
        }

        stage('Push des images sur Docker Hub') {
            steps {
                withDockerRegistry([credentialsId: 'docker-hub-creds', url: '']) {
                    sh 'docker push $projetfilrouge_backend:latest'
                    sh 'docker push $projetfilrouge_frontend:latest'
                    sh 'docker push $projetfilrouge_migrate:latest'
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
                 subject: "Déploiement local réussi",
                 body: "L'application a été déployée localement avec succès."
        }
        failure {
            mail to: 'alassanebenzecoly@gmail.com',
                 subject: "Échec du pipeline Jenkins",
                 body: "Une erreur s’est produite, merci de vérifier Jenkins."
        }
    }
}

