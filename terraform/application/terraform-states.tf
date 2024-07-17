# Terraform state for network(VPC) resources output
data "terraform_remote_state" "network" {

  backend = "remote"
  config = {
    hostname     = "app.terraform.io"
    organization = "foodtec"

    workspaces = {
      name = var.workspace_name
    }
  }
}
