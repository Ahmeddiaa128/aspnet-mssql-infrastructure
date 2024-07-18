pipeline {
    agent any

    parameters {
            booleanParam(name: 'PLAN_TERRAFORM', defaultValue: false, description: 'Check to plan Terraform changes')
            booleanParam(name: 'APPLY_TERRAFORM', defaultValue: false, description: 'Check to apply Terraform changes')
            booleanParam(name: 'DESTROY_TERRAFORM', defaultValue: false, description: 'Check to apply Terraform changes')
    }

    stages {
        stage('Clone Repository') {
            steps {
                // Clean workspace before cloning (optional)
                deleteDir()

                // Clone the Git repository
                git branch: 'main',
                    url: 'https://github.com/Ahmeddiaa128/aspnet-mssql-infrastructure.git'

                sh "ls -lart"
            }
        }

        stage('Terraform Init') {
                    steps {
                       withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-crendentails-rwagh']]){
                            dir('terraform') {
                            sh 'echo "=================Terraform Init=================="'
                            sh 'terraform init'
                        }
                    }
                }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    if (params.PLAN_TERRAFORM) {
                       withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-crendentails-rwagh']]){
                            dir('terraform') {
                                sh 'echo "=================Terraform Plan=================="'
                                sh 'terraform plan'
                            }
                        }
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    if (params.APPLY_TERRAFORM) {
                       withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-crendentails-rwagh']]){
                            dir('terraform') {
                                sh 'echo "=================Terraform Apply=================="'
                                sh 'terraform apply -auto-approve'
                            }
                        }
                    }
                }
            }
        }

        stage('Configure Kubernetes Context') {
            steps {
                sh 'aws eks --region us-east-1 update-kubeconfig --name aspnet-app'
            }
        }

        stage('Deploy AWS Load Balancer Controller') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-crendentails-rwagh']]) {
                    // Ensure Helm is installed
                    sh 'helm version'

                    // Add EKS Helm repository and update
                    sh 'helm repo add eks https://aws.github.io/eks-charts'
                    sh 'helm repo update'

                    // Install AWS Load Balancer Controller
                    sh 'helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
                            -n kube-system \
                            --set clusterName=aspnet-app \
                            --set serviceAccount.create=false \
                            --set region=us-east-1 \
                            --set vpcId=${params.VPC_ID} \
                            --set serviceAccount.name=aws-load-balancer-controller'
                }
            }
        }


        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    dir('k8s') {
                        script {
                            sh "kubectl apply -f web-deployment.yaml"
                            sh "kubectl apply -f db-deployment.yaml"
                            sh "kubectl apply -f mongodb-deployment.yaml"
                            sh "kubectl apply -f redis-deployment.yaml"
                            sh "kubectl apply -f ingress.yaml"
                        }
                    }
                }
            }
        }
        

}