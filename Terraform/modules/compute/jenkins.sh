#!/bin/bash
sudo yum update -y
sudo yum install yum-utils git -y
sudo amazon-linux-extras install ansible2
ansible-galaxy collection install amazon.aws

git clone https://github.com/belmironeto/digital-product-bootcamp.git /tmp/digital-product-bootcamp
