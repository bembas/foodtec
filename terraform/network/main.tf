module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc-${var.project_name}-${var.env}-${var.account_prefix}"
  cidr = "10.0.0.0/16"

  azs              = ["eu-west-1a", "eu-west-1b"]
  public_subnets   = ["10.0.128.0/20", "10.0.144.0/20"]
  private_subnets  = ["10.0.0.0/19", "10.0.32.0/19"]
  database_subnets = ["10.0.224.0/23", "10.0.226.0/23"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Environment = var.env
    Project     = var.project_name
    AWS_Region  = var.aws_region
    Terraform   = true
  }
}
