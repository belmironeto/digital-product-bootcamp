#!/bin/bash
sudo yum update -y
sudo yum install yum-utils -y

sudo yum install docker -y
sudo chmod 666 /var/run/docker.sock
sudo usermod -aG docker ec2-user 

sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo systemctl enable docker
sudo systemctl start docker

mkdir /home/ec2-user/jenkins-data /home/ec2-user/jenkins-home

sudo chown -R ec2-user /home/ec2-user

cd /home/ec2-user/jenkins-data

cat > Dockerfile <<EOF
FROM jenkins/jenkins

USER root

RUN apt-get update && apt-get install wget

# Install Terraform
RUN wget --quiet https://releases.hashicorp.com/terraform/1.0.9/terraform_1.0.9_linux_amd64.zip \
  && unzip terraform_1.0.9_linux_amd64.zip \
  && mv terraform /usr/bin \
  && rm terraform_1.0.9_linux_amd64.zip

USER jenkins
EOF

cat > docker-compose.yml <<EOF
version: '3'
services:
  jenkins:
    container_name: jenkins-server
    image: jenkins_tf
    ports:
      - "80:8080"
    volumes:
      - /home/ec2-user/jenkins-home:/var/jenkins_home
    networks:
      - net
networks:
  net:
EOF

sudo docker build . -t jenkins_tf
docker-compose up -d