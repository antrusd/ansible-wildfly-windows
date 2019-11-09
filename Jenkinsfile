def TF_OPERATION = 'Create'
def TF_WORKSPACE = 'default'
def TF_VERSION   = '0.12.12'


pipeline {
    agent {
        label "ansible && linux"
    }

    stages {
        stage('Clean Workspace') {
            steps {
                sh 'git clean -xdff'
                sh 'env'
            }
        }

        stage('Installing Ansible') {
            steps {
                sh 'virtualenv --system-site-packages -p python3 $PWD/ansible-tf-azure'
                withPythonEnv("${WORKSPACE}/ansible-tf-azure/") {
                    sh 'pip install --upgrade pip'
                    sh 'pip install -r requirements.txt'
                }
            }
        }

        stage('Installing Terraform') {
            steps {
                sh 'curl -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip'
                sh 'unzip -o -d $PWD/ansible-tf-azure/bin/ /tmp/terraform.zip'
                sh 'rm -f /tmp/terraform.zip'
                withCredentials([string(credentialsId: 'ARM_CLIENT_ID', variable: 'ARM_CLIENT_ID'), string(credentialsId: 'ARM_CLIENT_SECRET', variable: 'ARM_CLIENT_SECRET'), string(credentialsId: 'ARM_SUBSCRIPTION_ID', variable: 'ARM_SUBSCRIPTION_ID'), string(credentialsId: 'ARM_TENANT_ID', variable: 'ARM_TENANT_ID')]) {
                    sh '$PWD/ansible-tf-azure/bin/terraform init -input=false'
                }
            }
        }

        stage('Select Terraform Operation') {
            steps {
                script {
                    TF_OPERATION = input (
                        message: 'Please Select Terraform Operation     ',
                        parameters: [
                            choice (
                                name: 'TF_OPERATION',
                                choices: ['Create', 'Delete']
                            )
                        ]
                    )
                }
            }
        }

        stage('Input Terraform Workspace') {
            steps {
                script {
                    TF_WORKSPACE = input (
                        message: 'Please Input Terraform Workspace     ',
                        parameters: [
                            string (
                                name: 'TF_WORKSPACE',
                                defaultValue: 'default',
                                trim: true
                            )
                        ]
                    )
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression {
                    TF_OPERATION == 'Delete'
                }
            }
            steps {
                withCredentials([string(credentialsId: 'ARM_CLIENT_ID', variable: 'ARM_CLIENT_ID'), string(credentialsId: 'ARM_CLIENT_SECRET', variable: 'ARM_CLIENT_SECRET'), string(credentialsId: 'ARM_SUBSCRIPTION_ID', variable: 'ARM_SUBSCRIPTION_ID'), string(credentialsId: 'ARM_TENANT_ID', variable: 'ARM_TENANT_ID')]) {
                    sh '$PWD/ansible-tf-azure/bin/terraform workspace select ${TF_WORKSPACE}'
                    sh '$PWD/ansible-tf-azure/bin/terraform destroy -input=false t_plan'
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression {
                    TF_OPERATION == 'Create'
                }
            }
            steps {
                withCredentials([string(credentialsId: 'ARM_CLIENT_ID', variable: 'ARM_CLIENT_ID'), string(credentialsId: 'ARM_CLIENT_SECRET', variable: 'ARM_CLIENT_SECRET'), string(credentialsId: 'ARM_SUBSCRIPTION_ID', variable: 'ARM_SUBSCRIPTION_ID'), string(credentialsId: 'ARM_TENANT_ID', variable: 'ARM_TENANT_ID')]) {
                    sh '$PWD/ansible-tf-azure/bin/terraform workspace new ${TF_WORKSPACE}'
                    sh '$PWD/ansible-tf-azure/bin/terraform plan -input=false -out t_plan'
                    sh '$PWD/ansible-tf-azure/bin/terraform apply -input=false t_plan'
                }
            }
        }

        stage('Check Connection Target') {
            when {
                expression {
                    TF_OPERATION == 'Create'
                }
            }
            steps {
                withPythonEnv("${WORKSPACE}/ansible-tf-azure/") {
                    ansiblePlaybook colorized: true,
                                    installation: 'ansible',
                                    credentialsId: 'w2k16-target',
                                    playbook: 'winrm_ping.yml',
                                    extras: '-e target_hosts=all'
                }
            }
        }

        stage('Deploying WildFly') {
            when {
                expression {
                    TF_OPERATION == 'Create'
                }
            }
            steps {
                withPythonEnv("${WORKSPACE}/ansible-tf-azure/") {
                    ansiblePlaybook colorized: true,
                                    installation: 'ansible',
                                    credentialsId: 'w2k16-target',
                                    playbook: 'deploy_wildfly.yml',
                                    extras: '-e target_hosts=all'
                }
            }
        }

        stage('Check Installation Result') {
            when {
                expression {
                    TF_OPERATION == 'Create'
                }
            }
            steps {
                withPythonEnv("${WORKSPACE}/ansible-tf-azure/") {
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
