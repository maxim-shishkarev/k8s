terraform {
  required_version = "~> 0.15.3"

  required_providers {
    aws = "~> 3.39.0"
  }
}

provider "aws" {
  profile = var.profile
  region  = var.region
}
