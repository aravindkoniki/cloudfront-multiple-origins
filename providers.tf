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