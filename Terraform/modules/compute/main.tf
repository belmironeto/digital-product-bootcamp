data "aws_security_group" "bastion_sg"{
  filter { 
    name    =  "tag:Name"
    values  =  ["Bastion-SG"]
  }
}

data "aws_security_group" "jboss_sg"{
  filter { 
    name    =  "tag:Name"
    values  =  ["JBOSS-SG"]
  }
}

data "aws_subnet" "jboss_public_sub_1a" {
  filter {
    name  = "tag:Name"
    values = ["jboss-vpc-public-us-east-1a"]
  }
}

data "aws_subnet" "jboss_private_sub_1a" {
  filter {
    name  = "tag:Name"
    values = ["jboss-vpc-private-us-east-1a"]
  }
}

data "aws_subnet" "jboss_private_sub_1b" {
  filter {
    name  = "tag:Name"
    values = ["jboss-vpc-private-us-east-1b"]
  }
}

#        Removi pois no LAB não é possível criar profile e alguns recursos do IAM

#data "aws_iam_instance_profile" "iam_profile_ec2_jboss" {
#  name = "iam_profile_ec2_jboss"
#}

module "bastion_ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"
  name = "Bastion-Server"
  ami                    = "ami-03ededff12e34e59e"
  instance_type          = "t2.micro"
  key_name               = "vockey"
  monitoring             = true
  vpc_security_group_ids = [ data.aws_security_group.bastion_sg.id ]
  subnet_id              = data.aws_subnet.jboss_public_sub_1a.id
  iam_instance_profile   = "LabInstanceProfile"
  user_data              = file("./modules/compute/bastion.sh")
}

resource "aws_eip" "bastion-ip" {
  instance = module.bastion_ec2.id
  vpc = true

  tags = {
    Name = "Bastion-Server-EIP"
  }
}

module "jboss_instances_azA" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = {
    JBOSS01: "10.0.1.11"
    JBOSS02: "10.0.1.12"
    }
  name                   = "${each.key}"
  private_ip             = "${each.value}"

  ami                    = "ami-03ededff12e34e59e"
  instance_type          = "t2.micro"
  key_name               = "vockey"
  monitoring             = true
  vpc_security_group_ids = [data.aws_security_group.jboss_sg.id]
  subnet_id              = data.aws_subnet.jboss_private_sub_1a.id

}

module "jboss_instances_azB" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = {
    JBOSS03: "10.0.2.13"
    JBOSS04: "10.0.2.14"
    }
  name                   = "${each.key}"
  private_ip             = "${each.value}"

  ami                    = "ami-03ededff12e34e59e"
  instance_type          = "t2.micro"
  key_name               = "vockey"
  monitoring             = true
  vpc_security_group_ids = [data.aws_security_group.jboss_sg.id]
  subnet_id              = data.aws_subnet.jboss_private_sub_1b.id
  
 
} 