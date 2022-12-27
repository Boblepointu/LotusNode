########################
#### Global ############
########################

data "aws_region" "main" {
  name = var.region
}

provider "aws" {
  default_tags {
    tags = {
      Environment = var.environment
      Owner       = "AG"
      Provisioner = "Terraform"
      Project     = "${var.project_name}"
    }
  }
}