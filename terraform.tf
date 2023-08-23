terraform {
  cloud {
    organization = "Abingwas-Foundation"

    workspaces {
      name = "Devops_Tools"
    }
  }
  required_providers {
    aws= {
        source = "hashicorp/aws"
        version = "5.5.0"
    }
}
}

provider "aws" {
  region = "us-west-1"
}
