#!/usr/bin/env bash
set -e


# Check if an input parameter is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <input_parameter>"
    exit 1
fi

# Assign the input parameter to a variable
bucket_name="$1"

# Use the input parameter as an output within the script
echo "Input parameter provided: $bucket_name"

# Create the S3 bucket
aws s3api create-bucket --bucket "$bucket_name" --region us-east-1

# Check if the bucket creation was successful
if [ $? -eq 0 ]; then
    echo "Bucket '$bucket_name' created successfully."
else
    echo "Failed to create bucket '$bucket_name'."
fi

echo "Create base terraform templates"
touch main.tf data.tf outputs.tf

if [ ! -f providers.tf ]
then
  echo "Create providers file"
  cat > providers.tf <<- PROVIDERS
provider "aws" {
  #shared_credentials_file = "~/.aws/credentials"
  profile = "cloudguru"
  region  = "us-east-1"
}
PROVIDERS
fi

if [ ! -f variables.tf ]
then
  echo "Create variables file"
  cat > variables.tf <<- VARIABLES
variable "region" {
  description = "AWS region to create resources in"
  type  = string
  default = "us-east-1"
}
VARIABLES
fi

if [ ! -f locals.tf ]
then
  echo "Create locals template file"
  cat > locals.tf <<- LOCALS
locals {
}
LOCALS
fi

if [ ! -f backend.tf ]
then
  echo "Create backend template file"
  cat > backend.tf <<- BACKEND
# Terraform Remote Statefile
terraform {
  backend "s3" {
    bucket                  = "$bucket_name"
    key                     = "shared/state"
    region                  = "us-east-1"
    shared_credentials_file = "~/.aws/credentials"
    profile                 = "cloudguru"
    #dynamodb_table          = "vfde-cloudguru893872-tf-locks"
  }
}
BACKEND
fi

echo "Create default terraform variable file"
mkdir -p tfvars && touch tfvars/main.tfvars

echo "Create .gitignore file"
cat > .gitignore <<- IGNORE
**/.terraform/**
**/.terragrunt-cache/**
IGNORE

exit 0