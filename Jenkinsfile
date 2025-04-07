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
        EMAIL_TO   = 'your-email@example.com'  // Non-sensitive email address
        AWS_REGION = 'us-east-2'               // AWS region, typically not sensitive
    }
    stages {
        stage('Setup tfvars') {
            steps {
                script {
                    // Retrieve the Terraform variables file from Jenkins credentials
                    withCredentials([file(credentialsId: 'eks-terraform-tfvars', variable: 'TFVARS_FILE')]) {
                        sh 'cp $TFVARS_FILE terraform.tfvars'
                    }
                }
            }
        }
        stage('1. Terraform Init') {
            steps {
                script {
                    // Securely retrieve backend configuration details from Jenkins credentials
                    withCredentials([
                        string(credentialsId: 's3-bucket', variable: 'S3_BUCKET'),
                        string(credentialsId: 'eks-tfstate-key', variable: 'TFSTATE_KEY'),
                        string(credentialsId: 'dynamodb-table', variable: 'DYNAMODB_TABLE')
                    ]) {
                        // Use triple single quotes to let the shell expand the variables
                        sh '''
                            terraform init \
                            -backend-config="bucket=$S3_BUCKET" \
                            -backend-config="key=$TFSTATE_KEY" \
                            -backend-config="dynamodb_table=$DYNAMODB_TABLE" \
                            -backend-config="region=$AWS_REGION"
                        '''
                    }
                }
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
            mail to: "${env.EMAIL_TO}",
                 subject: "Deployment Successful: ${env.JOB_NAME} - Build ${env.BUILD_NUMBER}",
                 body: """\
Hello,

The deployment was successful.

Job: ${env.JOB_NAME}
Build Number: ${env.BUILD_NUMBER}
Build URL: ${env.BUILD_URL}

Regards,
Jenkins
                 """
        }
        failure {
            mail to: "${env.EMAIL_TO}",
                 subject: "Deployment Failed: ${env.JOB_NAME} - Build ${env.BUILD_NUMBER}",
                 body: """\
Hello,

The deployment has failed. Please review the build logs for more details.

Job: ${env.JOB_NAME}
Build Number: ${env.BUILD_NUMBER}
Build URL: ${env.BUILD_URL}

Regards,
Jenkins
                 """
        }
        always {
            // Always clean the workspace after the build to remove any temporary files
            cleanWs()
        }
    }
}
