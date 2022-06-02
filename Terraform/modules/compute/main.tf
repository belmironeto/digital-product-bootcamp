data "aws_security_group" "jenkins_sg"{
  filter { 
    name    =  "tag:Name"
    values  =  ["Jenkins-SG"]
  }
}

data "aws_subnet" "jboss_public_sub_1a" {
  filter {
    name  = "tag:Name"
    values = ["jboss-vpc-public-us-east-1a"]
  }
}

module "jenkins_ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"
  name = "Jenkins-Server"
  ami                    = "ami-03ededff12e34e59e"
  instance_type          = "t2.micro"
  key_name               = "vockey"
  monitoring             = true
  vpc_security_group_ids = [ data.aws_security_group.jenkins_sg.id ]
  subnet_id              = data.aws_subnet.jboss_public_sub_1a.id
  user_data              = file("./modules/compute/jenkins.sh")
}

resource "aws_eip" "jenkins-ip" {
  instance = module.jenkins_ec2.id
  vpc = true

  tags = {
    Name = "Jenkins-Server-EIP"
  }
}