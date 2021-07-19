#!/bin/bash

#Global Parameters
S3_BUCKET_NAME=""
S3_PREFIX="code"

#Configure AWS API Access
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export AWS_DEFAULT_REGION=us-east-1

#Deploy Networking Stacks
aws cloudformation deploy \
    --stack-name VPC \
    --template-file deploy/vpc/vpc-3azs.yaml \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --parameter-overrides file://parameters/vpc/parameters_vpc-3azs.json

aws cloudformation deploy \
    --stack-name NAT-Gateway-A \
    --template-file deploy/vpc/vpc-nat-gateway.yaml \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --parameter-overrides ParentVPCStack=VPC SubnetZone=A

aws cloudformation deploy \
    --stack-name NAT-Gateway-B \
    --template-file deploy/vpc/vpc-nat-gateway.yaml \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --parameter-overrides ParentVPCStack=VPC SubnetZone=B

aws cloudformation deploy \
    --stack-name NAT-Gateway-C \
    --template-file deploy/vpc/vpc-nat-gateway.yaml \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --parameter-overrides ParentVPCStack=VPC SubnetZone=C

#Deploy CloudTrail Stacks    
# aws cloudformation deploy \
#     --stack-name S3-CloudTrail-Bucket \
#     --template-file deploy/s3/s3-bucket.yaml \
#     --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
#     --parameter-overrides file://parameters/s3/parameters_s3_cloudtrail.json

# aws cloudformation deploy \
#     --stack-name CloudTrail \
#     --template-file deploy/CloudTrail/cloudtrail.yaml \
#     --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
#     --parameter-overrides file://parameters/CloudTrail/parameters_cloudtrail.json

#Deploy Elk Stacks    
aws cloudformation deploy \
    --stack-name elasticsearch-kms-key \
    --template-file deploy/kms/kms-key.yaml \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --parameter-overrides file://parameters/kms/parameters_kms-key-elasticsearch.json   

aws cloudformation deploy \
    --stack-name elasticsearch \
    --template-file deploy/elk/elasticsearch.yaml \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --parameter-overrides file://parameters/elk/parameters_elasticsearch.json   

aws cloudformation deploy \
    --stack-name logstash-kms-key \
    --template-file deploy/kms/kms-key.yaml \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --parameter-overrides file://parameters/kms/parameters_kms-key-logstash.json   

aws cloudformation deploy \
    --stack-name logstash \
    --template-file deploy/elk/logstash.yaml \
    --s3-bucket ${S3_BUCKET_NAME} \
    --s3-prefix ${S3_PREFIX} \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --parameter-overrides file://parameters/elk/parameters_logstash.json  