terraform {
  cloud {
    organization = "terraformcloudlearning"
    workspaces {
      name = "agharameeztestterraform"
    }

  }
  # required_providers {
  #   aws = {
  #     source  = "hashicorp/aws"
  #     version = "~> 4.0"
  #   }
  # }
}

# Configure the AWS Provider
# provider "aws" {
#   shared_config_files      = ["/Users/Lenovo/.aws/config"]
#   shared_credentials_files = ["/Users/Lenovo/.aws/credentials"]
#   profile                  = "eurus"
# }

# provider "aws" {
#   region     = "eu-west-1"
#   access_key = var.AWS_ACCESS_KEY
#   secret_key = var.AWS_SECRET_KEY
# }
