provider "aws" {
  region = var.aws_region
}

terraform {
  backend "remote" {

    hostname     = "app.terraform.io"
    organization = "foodtec"

    workspaces {
      prefix = "foodtec-wordpress-application-"
    }
  }
}
