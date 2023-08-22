provider "aws" {
  shared_credentials_files = "/home/ubuntu/.aws/credentials"
  profile                 = "default"
  region                  = "us-west-1"
}