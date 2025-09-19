pipeline {
  agent any

  environment {
    APP_NAME = 'flask-hello'     // customize if you want
    EC2_USER = 'ubuntu'          // Amazon Linux: 'ec2-user'
    APP_PORT = '8000'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        sh 'echo "Commit: $(git rev-parse --short HEAD)"'
      }
    }

    stage('Test') {
      steps {
        sh '''
          python3 -m venv venv
          . venv/bin/activate
          pip install --upgrade pip
          pip install -r app/requirements.txt pytest
          pytest -q
        '''
      }
      post {
        always {
          echo 'Tests completed.'
        }
      }
    }

    stage('Deploy to EC2 (no zip)') {
      steps {
        withCredentials([string(credentialsId: 'ec2-host', variable: 'EC2_HOST')]) {
          sshagent(credentials: ['ec2-ssh-key']) {
            sh '''
              set -eux
              ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} "sudo rm -rf /tmp/src && mkdir -p /tmp/src"
              scp -r -o StrictHostKeyChecking=no app deploy ${EC2_USER}@${EC2_HOST}:/tmp/src/
              ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} "chmod +x /tmp/src/deploy/remote_setup.sh && sudo /tmp/src/deploy/remote_setup.sh ${APP_NAME} ${APP_PORT}"
            '''
          }
        }
      }
    }

    stage('Post-deploy check') {
      steps {
        withCredentials([string(credentialsId: 'ec2-host', variable: 'EC2_HOST')]) {
          sh '''
            set -e
            curl -sSf http://${EC2_HOST}:${APP_PORT}/health
          '''
        }
      }
    }
  }

  post {
    success { echo 'Deployment succeeded.' }
    failure { echo 'Deployment failed.' }
  }
}
