pipeline {
    agent any

    environment {
        GITREPO = 'https://github.com/kushal1997/flask_docker_jenkins.git'
        SSH_CRED = 'kushal'
        EC2_USERNAME = 'ubuntu'
        EC2_IP = "52.12.183.12"
        DOCKER_IMAGE = 'noizy23yo/hero_devops'
        DOCKER_HUB_CRED = 'dockerhub-cred-k'
        DOCKER_TAG = 'flask_latest'
    }

    stages {
        stage("parallel-build") {
            parallel {

                stage("Code Checkout") {
                    steps {
                        git branch: 'master', url: "${env.GITREPO}"
                    }
                }

                stage("Setup EC2") {
                    steps {
                        sshagent(credentials: ["${SSH_CRED}"]) {
                            sh """
                                ssh -o StrictHostKeyChecking=no ${EC2_USERNAME}@${EC2_IP} '

                                    if command -v docker &> /dev/null
                                    then
                                        echo "   "
                                        echo "   "
                                        echo "docker version is :"
                                        docker --version
                                    else
                                        echo "docker is not installed"
                                        sudo apt update -y && \
                                        sudo apt install -y docker.io && \
                                        sudo systemctl start docker && \
                                        sudo systemctl enable docker && \
                                        sudo usermod -aG docker \$USER && \
                                        echo "===========docker installed and running==========="
                                    fi
                                    
                                '
                            """
                            

                        }
                    }
                }
            }
        }

        stage("Docker Build") {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}")
                }
            }
        }

        stage("Docker Push to Hub") {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_HUB_CRED}") {
                        docker.image("${DOCKER_IMAGE}").push("${DOCKER_TAG}")
                    }
                }
            }
        }

        stage("Deploy to EC2") {
            steps {
                sshagent(credentials: ["${SSH_CRED}"]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${EC2_USERNAME}@${EC2_IP} '    
                            docker pull ${DOCKER_IMAGE}:${DOCKER_TAG}
                            docker stop flask_app || true
                            docker rm flask_app || true
                            docker run -d --name flask_app -p 3000:3000 ${DOCKER_IMAGE}:${DOCKER_TAG}
                            docker ps 
                        '
                    """
                }
            }
        }

    }

}
