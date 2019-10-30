pipeline {
    agent {
        label "ansible"
    }

    stages {
        stage('Clean Workspace') {
            steps {
                sh 'git clean -xdff'
            }
        }

        stage('Installing Ansible') {
            steps {
                sh 'virtualenv --system-site-packages -p python3 $HOME/ansible-tf-azure'
                withPythonEnv("$HOME/ansible-tf-azure/") {
                    sh 'pip install --upgrade pip'
                    sh 'pip install -r requirements.txt'
                }
            }
        }

        stage('Installing Terraform') {
            steps {
                def TF_VERSION = '0.12.12'

                sh 'curl -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip'
                sh 'unzip -o -d $HOME/ansible-tf-azure/bin/ /tmp/terraform.zip'
                sh 'rm -f /tmp/terraform.zip'
                withCredentials([string(credentialsId: 'ARM_CLIENT_ID', variable: 'ARM_CLIENT_ID'), string(credentialsId: 'ARM_CLIENT_SECRET', variable: 'ARM_CLIENT_SECRET'), string(credentialsId: 'ARM_SUBSCRIPTION_ID', variable: 'ARM_SUBSCRIPTION_ID'), string(credentialsId: 'ARM_TENANT_ID', variable: 'ARM_TENANT_ID')]) {
                    sh '$HOME/ansible-tf-azure/bin/terraform init -input=false'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([string(credentialsId: 'ARM_CLIENT_ID', variable: 'ARM_CLIENT_ID'), string(credentialsId: 'ARM_CLIENT_SECRET', variable: 'ARM_CLIENT_SECRET'), string(credentialsId: 'ARM_SUBSCRIPTION_ID', variable: 'ARM_SUBSCRIPTION_ID'), string(credentialsId: 'ARM_TENANT_ID', variable: 'ARM_TENANT_ID')]) {
                    sh '$HOME/ansible-tf-azure/bin/terraform plan -input=false'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([string(credentialsId: 'ARM_CLIENT_ID', variable: 'ARM_CLIENT_ID'), string(credentialsId: 'ARM_CLIENT_SECRET', variable: 'ARM_CLIENT_SECRET'), string(credentialsId: 'ARM_SUBSCRIPTION_ID', variable: 'ARM_SUBSCRIPTION_ID'), string(credentialsId: 'ARM_TENANT_ID', variable: 'ARM_TENANT_ID')]) {
                    sh '$HOME/ansible-tf-azure/bin/terraform apply -input=false'
                }
            }
        }

        stage('Check Connection Target') {
            steps {
                withPythonEnv("$HOME/ansible-tf-azure/") {
                    ansiblePlaybook colorized: true,
                                    installation: 'ansible',
                                    credentialsId: 'w2k16-target',
                                    playbook: 'winrm_ping.yml',
                                    extras: '-e target_hosts=all'
                }
            }
        }

        stage('Deploying WildFly') {
            steps {
                withPythonEnv("$HOME/ansible-tf-azure/") {
                    ansiblePlaybook colorized: true,
                                    installation: 'ansible',
                                    credentialsId: 'w2k16-target',
                                    playbook: 'deploy_wildfly.yml',
                                    extras: '-e target_hosts=all'
                }
            }
        }

        stage('Check Installation Result') {
            steps {
                withPythonEnv("$HOME/ansible-tf-azure/") {
                    ansiblePlaybook colorized: true,
                                    installation: 'ansible',
                                    credentialsId: 'w2k16-target',
                                    playbook: 'winrm_url.yml',
                                    extras: '-e target_hosts=all'
                }
            }
        }
    }
}
