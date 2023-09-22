provider "aws" {
  region = "ca-central-1"
}

terraform {
  backend "s3" {
    bucket         = "momotaro-state-backend"
    key            = "terraform.tfstate"
    region         = "ca-central-1"
    encrypt        = true
    dynamodb_table = "Momotaro_State_Lock"
  }
}
