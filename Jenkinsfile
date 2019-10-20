pipeline {
    agent { label 'master' }

    stages {
        stage('Prepare') {
            steps {
                bat 'echo "Stage 1, Preparing"'
                cleanWs()

                withPythonEnv("C:\\Python\\Python37\\python"){
                    bat 'pip install -r requirements.txt'
                }
            }
        }
        stage('Install WildFly') {
            steps {
                bat 'echo "Stage 2, Building"'
            }
        }
    }
}
