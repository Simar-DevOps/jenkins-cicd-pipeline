pipeline {
  agent any

  environment {
    APP_NAME   = 'flask-hello'   // customize if you want
    EC2_USER   = 'ubuntu'        // Amazon Linux would be 'ec2-user'
    APP_PORT   = '8000'
    PYTHONPATH = "${WORKSPACE}"  // <-- makes 'app' importable during tests
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
          # Extra safety: ensure PYTHONPATH is set even inside the shell
          export PYTHONPATH="$PWD"
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
              # Stage files on the instance
              ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} "sudo rm -rf /tmp/src && mkdir -p /tmp/src"
              scp -r -o StrictHostKeyChecking=no app deploy ${EC2_USER}@${EC2_HOST}:/tmp/src/
              # Normalize CRLF (Windows) to LF so bash can run the script
              ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} "sed -i 's/\\r$//' /tmp/src/deploy/remote_setup.sh"
              # First-time / idempotent setup + restart
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
