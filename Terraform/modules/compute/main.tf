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

data "aws_subnet" "jboss_public_sub_1b" {
  filter {
    name  = "tag:Name"
    values = ["jboss-vpc-public-us-east-1b"]
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

data "aws_vpc" "jboss_vpc" {
  filter {
    name = "tag:Name"
    values = ["jboss-vpc"]
  }
}

#        Removi pois no LAB não é possível criar profile e alguns recursos do IAM

#data "aws_iam_instance_profile" "iam_profile_ec2_jboss" {
#  name = "iam_profile_ec2_jboss"
#}

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


data "aws_instance" "jboss_dc_ec2" {
  depends_on = [
    module.jboss_instances_azA
  ]
  filter {
    name  = "tag:Name"
    values = ["JBOSS01"]
  }
}

resource "aws_alb" "alb_jboss" {
  name                  = "ELB-JBOSS-Console"
  internal              = false
  load_balancer_type    = "application"

  subnets               = [data.aws_subnet.jboss_public_sub_1a.id, data.aws_subnet.jboss_public_sub_1b.id]
  security_groups       = [ data.aws_security_group.bastion_sg.id ]
}

resource "aws_lb_target_group" "elb_jboss_targetgroup" {
  name                  = "TargetGroup-JBOSS-Console"
  port                  = 9990
  protocol              = "HTTP"
  vpc_id                = data.aws_vpc.jboss_vpc.id
  
  health_check {
    healthy_threshold   = 3    
    unhealthy_threshold = 10    
    timeout             = 5    
    interval            = 10    
    path                = "/"    
    port                = 8080
  }
}

resource "aws_alb_listener" "alb_jboss_listener" {
  load_balancer_arn   = aws_alb.alb_jboss.arn
  port                = 80
  protocol            = "HTTP"
  default_action {
    target_group_arn  = aws_lb_target_group.elb_jboss_targetgroup.arn
    type              = "forward"
  }
}

resource "aws_alb_listener_rule" "listener_80" {
  depends_on = [ aws_lb_target_group.elb_jboss_targetgroup ]
  listener_arn = aws_alb_listener.alb_jboss_listener.arn
  priority = 100
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.elb_jboss_targetgroup.arn
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_alb_target_group_attachment" "target_group_attach" {
  target_group_arn = aws_lb_target_group.elb_jboss_targetgroup.arn
  target_id        = data.aws_instance.jboss_dc_ec2.id
  port             = 9990
}



resource "aws_instance" "bastion_ec2" {
  depends_on = [
    module.jboss_instances_azA
  ]

  tags = {
    Name = "Bastion-Server"
  }
  ami                    = "ami-03ededff12e34e59e"
  instance_type          = "t2.micro"
  key_name               = "vockey"
  monitoring             = true
  vpc_security_group_ids = [ data.aws_security_group.bastion_sg.id ]
  subnet_id              = data.aws_subnet.jboss_public_sub_1a.id
  iam_instance_profile   = "LabInstanceProfile"

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/labsuser.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install yum-utils git -y",
      "sudo amazon-linux-extras install ansible2 -y",
      "ansible-galaxy collection install amazon.aws",
      "git clone https://github.com/belmironeto/digital-product-bootcamp.git /tmp/digital-product-bootcamp",
      "cd /home/ec2-user/.ssh/",
      "aws s3 cp s3://gab-teste/labsuser.pem .",
      "sudo chmod 400 labsuser.pem",
      "cd /tmp/digital-product-bootcamp/Ansible",
      "ansible-playbook main.yml -i inventory --private-key /home/ec2-user/.ssh/labsuser.pem --ssh-common-args='-o StrictHostKeyChecking=no'"
    ]
  }
}

resource "aws_eip" "bastion-ip" {
  instance = aws_instance.bastion_ec2.id
  vpc = true

  tags = {
    Name = "Bastion-Server-EIP"
  }
}
