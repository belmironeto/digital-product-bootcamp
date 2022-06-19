module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "jboss-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false
  one_nat_gateway_per_az = false
  default_vpc_enable_dns_hostnames = true
}

module "bastion_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "Bastion-SG"
  description = "Security group para nossa instancia de Bastion"
  vpc_id      = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]
  egress_rules        = ["all-all"]
}

module "jboss_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "JBOSS-SG"
  description = "Security group para nossa instancia do JBOSS"
  vpc_id      = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "ssh-tcp", "http-8080-tcp"]
  ingress_with_cidr_blocks  = [
    {
      from_port   = 9990
      to_port     = 9990
      protocol    = "tcp"
      description = "http-9990-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 9999
      to_port     = 9999
      protocol    = "tcp"
      description = "http-9999-tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_rules        = ["all-all"]
}