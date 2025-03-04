#!/bin/bash
# export TF_VAR_s3_bucket="your-s3-bucket"
# export TF_VAR_dynamodb_table="your-dynamodb-table"
# export TF_VAR_tfstate_key="your-tfstate-key"

terraform init \
  -backend-config="bucket=$TF_VAR_s3_bucket" \
  -backend-config="key=$TF_VAR_tfstate_key" \
  -backend-config="dynamodb_table=$TF_VAR_dynamodb_table" \
  -backend-config="region=us-east-2"
