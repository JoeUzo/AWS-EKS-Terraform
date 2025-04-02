pipeline {
    agent {
        node {
            label 'eks-node'
        }
    }
    parameters {
        choice(name: 'Deployment_Type', choices: ['apply', 'destroy'], description: 'The deployment type')
    }
    environment {
        EMAIL_TO   = 'email@email.com'
        AWS_REGION = 'us-east-2'
    }
    stages {
        stage('1. Terraform Init') {
            steps {
                echo 'Terraform init phase'
                sh 'terraform init'
            }
        }
        stage('2. Terraform Plan') {
            steps {
                echo 'Terraform plan phase'
                sh 'terraform plan'
            }
        }
        stage('3. Manual Approval') {
            steps {
                script {
                    // Prompt for manual approval
                    def userApproval = input(
                        id: 'userApproval',
                        message: 'Should we proceed?',
                        parameters: [
                            choice(name: 'manual_approval', choices: ['Approve', 'Reject'], description: 'Approve or Reject the deployment')
                        ]
                    )
                    if (userApproval == 'Reject') {
                        error "Deployment rejected by user."
                    } else {
                        echo "Deployment approved."
                    }
                }
            }
        }
        stage('4. Terraform Deploy') {
            steps {
                script {
                    if (params.Deployment_Type == 'apply') {
                        echo "Applying Terraform configuration..."
                        sh "terraform apply -auto-approve"
                    } else if (params.Deployment_Type == 'destroy') {
                        echo "Destroying Terraform managed infrastructure..."
                        sh "terraform destroy -auto-approve"
                    } else {
                        error "Invalid Deployment_Type: ${params.Deployment_Type}"
                    }
                }
            }
        }
    }
    post {
        success {
            echo "Deployment successful."
        }
        failure {
            echo "Deployment failed."
        }
    }
}
