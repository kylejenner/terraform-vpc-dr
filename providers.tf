terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}


provider "aws" {
  profile = "demo"
  region  = "eu-west-1"
  alias   = "prod"
}

provider "aws" {
  profile = "demo"
  region  = "eu-west-2"
  alias   = "dr"
}