provider "aws" {
  region = "us-east-1"
  shared_credentials_files = ["/Users/BADR/.aws/credentials"]
}
provider "kubernetes" {
  config_path = "~/.kube/config" 
}

data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}





