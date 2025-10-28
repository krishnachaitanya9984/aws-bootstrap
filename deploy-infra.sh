#!/bin/bash

STACK_NAME=awsbootstrap
REGION=ap-south-1
CLI_PROFILE=awsbootstrap
EC2_INSTANCE_TYPE=t2.micro

# Get AWS Account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --profile $CLI_PROFILE --query "Account" --output text)
CODEPIPELINE_BUCKET="$STACK_NAME-$REGION-codepipeline-$AWS_ACCOUNT_ID"

echo -e "\n\n=========== Deploying setup.yml ==========="
aws cloudformation deploy \
  --region $REGION \
  --profile $CLI_PROFILE \
  --stack-name $STACK_NAME-setup \
  --template-file setup.yml \
  --no-fail-on-empty-changeset \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides CodePipelineBucket=$CODEPIPELINE_BUCKET

echo -e "\n\n=========== Deploying main.yml ==========="
aws cloudformation deploy \
  --region $REGION \
  --profile $CLI_PROFILE \
  --stack-name $STACK_NAME-main \
  --template-file main.yml \
  --no-fail-on-empty-changeset \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides EC2InstanceType=$EC2_INSTANCE_TYPE

# If the deploy succeeded, show the DNS name of the created instance
if [ $? -eq 0 ]; then
  echo -e "\n\n=========== Stack Outputs ==========="
  aws cloudformation list-exports \
    --profile $CLI_PROFILE \
    --region $REGION \
    --query "Exports[?Name=='InstanceEndpoint'].Value" \
    --output text
fi
