FROM jenkins/jenkins:lts
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-venv python3-pip zip unzip curl openssh-client \
    && rm -rf /var/lib/apt/lists/*
USER jenkins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt
COPY init.groovy.d/basic-security.groovy /usr/share/jenkins/ref/init.groovy.d/basic-security.groovy
