#!/bin/bash
sudo yum update -y
sudo yum install yum-utils git -y
sudo amazon-linux-extras install ansible2


ansible-galaxy collection install amazon.aws
git clone https://github.com/belmironeto/digital-product-bootcamp.git /tmp/digital-product-bootcamp

cd /home/ec2-user/.ssh/
aws s3 cp s3://gab-teste/labuser.pem
sudo chmod 400 labuser.pem

cd /tmp/digital-product-bootcamp/Ansible
ansible-playbook main.yml -i inventory --private-key /home/ec2-user/.ssh/labuser.pem
