pipeline {
    agent { label 'linux' }

    stages {
        stage('Workspace Prepare') {
            steps {
                sh 'echo "Stage 1, Preparing Workspace"'
                cleanWs()
                sh 'which ansible-playbook'
                sh 'pip install -r requirements.txt'
            }
        }

        stage('Install WildFly') {
            steps {
                ansiblePlaybook colorized: true,
                                installation: 'ansible',
                                credentialsId: 'w2k16-target',
                                playbook: 'deploy_wildfly.yml',
                                extraVars: 'target_hosts=wildfly-win2k16'
            }
        }
    }
}
