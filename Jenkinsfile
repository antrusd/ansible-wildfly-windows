pipeline {
    agent {
        label "ansible"
    }

    stages {
        stage('Workspace Prepare') {
            steps {
                sh 'echo "Stage 1, Preparing Workspace"'
                cleanWs()
                sh 'which ansible-playbook'
                sh 'pip install -r requirements.txt'
            }
        }

        stage('Check Connection Target') {
            steps {
                sh 'echo "Stage 2, Test Target Connectivity"'
                ansiblePlaybook colorized: true,
                                installation: 'ansible',
                                credentialsId: 'w2k16-target',
                                playbook: 'winrm_ping.yml',
                                extras: '-e target_hosts=w2k16-target'
            }
        }

        stage('Install WildFly') {
            steps {
                sh 'echo "Stage 3, Deploying WildFly"'
                ansiblePlaybook colorized: true,
                                installation: 'ansible',
                                credentialsId: 'w2k16-target',
                                playbook: 'deploy_wildfly.yml',
                                extras: '-e target_hosts=w2k16-target'
            }
        }

        stage('Check Installation Result') {
            steps {
                sh 'echo "Stage 2, Test WildFly Installation"'
                ansiblePlaybook colorized: true,
                                installation: 'ansible',
                                credentialsId: 'w2k16-target',
                                playbook: 'winrm_url.yml',
                                extras: '-e target_hosts=w2k16-target'
            }
        }
    }
}
