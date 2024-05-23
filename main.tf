terraform {

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "blufod"

    workspaces {
      name = "getting-started"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.50.0"
    }
  }
}

locals {
  project_name = "Amaboh"
}