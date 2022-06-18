data "aws_security_group" "jenkins_sg"{
  filter { 
    name    =  "tag:Name"
    values  =  ["Jenkins-SG"]
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

#data "aws_iam_instance_profile" "iam_profile_ec2_jboss" {
#  name = "iam_profile_ec2_jboss"
#}

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
  iam_instance_profile   = "LabInstanceProfile"
  user_data              = file("./modules/compute/jenkins.sh")
}

resource "aws_transfer_ssh_key" "labKey" {
  server_id = module.jenkins_ec2.id
  user_name = "ec2-user" 
  body = "-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAi1+zqRYEHiDtqR5hUMQK7h+p6K6SX0CkpC+xsrVKOIQ/NXXR
C/eGKNwzcNEuA/T4rwlZhN9rFiLf8xrJe5/GmFJVpZciBVkxAO5VYN8WCZIO/e11
Nw0v+vdskSKo8pGXY8aStmQcNF70Nyk3ElWe0dEOcUdybOCJa04n838Gipv4QVat
7GWvRbGaw8KzzS6PByft2DBUuMnQ5Vhntusz2fm6KggzJYrmio0C2OtE0hDQYQUs
CH1GXNhI7fyfvh85cTRk4AzBplfbGQlBSFOo42c0XcWcLUjl0p4c/yBUehaaeUYe
8kgxnydvPiKT5HD/aMYLyWCcAcTjSHO+uaRd/QIDAQABAoIBACy1W22PGW0MxRAu
JauB57uxPpDchym1E9tzTT51d0Sf76LXk2KSWV/8GyhCgc9VIv0LM8My5CgqscpL
OnzEqTEtoDnJPGmYzeZtjcfQaEJTryl3pdUuDskj25jHFIkTeQvRpDiL7pxCJXcY
aokgHB1UQZzG/Ya9lHduj9RFWDTYEDi2XI8v0EiIuxSwVJ1ozE/T+W16/8qcn0AA
CO3Let9ovBxHFJ/hVNT30E2Wm0nhT2KSiZo/Kyx7gRLF9tmjxSQJa2E34thrQwjD
bRD524D3uuooYJsOkFoP60X0nXTekVNR+tDBBbyd4G68SFThDn7ahoLrdUcToDmd
6nSEwgECgYEAxqb6wgJFM02onnlPrIGSbOCDvvi9t/RtE/jliGfndtNLYtwU/1yl
q8NszXIjawRDCsadlAXoaojd1sPXqwKm/PZOv7yZ+/XwfM9HhQ1zJ8Uo79Ms2ffS
y9DXP4rVzVsyyNn6WaYnEtGJaRdspXd3sBqAOgL2qKTEZIwkpbOKcIECgYEAs5vc
p6rNHSQqNZ2dOxNiDUWOPJ2D9iPKGkD6nJq3A6ekqoK/bSCbn08Dy8jFbdXh0wxS
n2Rd37FD5EXxvleDHPSvnCsXo0K191q9ABzWPtDUjzaFrhADupqGB6ZKtJisVmD4
O96S2Uzr+0HkvU0W4izh/J749OEA2DK0oT6D730CgYBvgb1R95pGcPoMcoXhjB3Y
FbJ+GPvNbVtpEZYuGjzX+0TeqjDzIlswbhL9w2rUIGFNhC1hsGtEma0EZ4wAxw1b
AxszDzfUMbobJPK9Yc5Y7ZfL/tq3Qx/FHmYkmdbnXaDFE24uslBOhOW/4tEulD/P
zyBY797qzQoccnoDtSMpgQKBgFtX3yZeVSaG5/iQihArUWiSgT4Olbguh3BGr63J
eV4gejxFdnlXZg3lL3cKSm4LomelErgBYUSMcIy9ja5R71pgjpcLy1+6Y7TCrvBJ
uiQELLYQ8neNqXfTcmqdhczHAI6FjnlUPrbIyhLkdiJX/FVWoi/J4a8YZ0eMshR3
KL45AoGAOIZCAXBCqbTDa9CHmmR+7ahwmPVjYrHSBpg+8cK0Xivw8bA4bcRFn7ew
teOu4FCPGCdTpGYrWN0AEZZUU5dVCdMuwvbWf6FHmzG/qtP7BRofSttcqfYHHZPG
rHeaT1/GEBNhQfn7Y+OLA1Ms3uyE8u7fW3e4mGPZCCmjA6DW4pA=
-----END RSA PRIVATE KEY-----"
}
resource "aws_eip" "jenkins-ip" {
  instance = module.jenkins_ec2.id
  vpc = true

  tags = {
    Name = "Jenkins-Server-EIP"
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

/* module "jboss_instances_azB" {
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
  
 
}  */