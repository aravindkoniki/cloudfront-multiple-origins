provider "aws" {
  region  = "eu-central-1"
  profile = "MY_NETWORKING"
  alias   = "MY_NETWORKING"
}


provider "aws" {
  alias   = "us_east_1"
  region  = "us-east-1"
  profile = "MY_NETWORKING"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.8, < 6.1.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.4"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1"
    }
  }
  required_version = ">= 1.3.0"
}
