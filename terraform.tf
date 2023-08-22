/*(terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.5.0"
    }
  }
}


provider "aws" {
  # Configuration options
  profile = "default"
  region = "us-west-1"
}*/


terraform {
  cloud {
    organization = "Abingwas-Foundation"

    workspaces {
      name = "Devops_Tools"
    }
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.13.1"
    }
}
}

provider "aws" {
  profile = "default"
  region = "us-west-1"
}