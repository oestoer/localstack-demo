provider "aws" {
  access_key                  = "mock_id"
  secret_key                  = "mock_secret_key"
  region                      = "local-1"
  s3_force_path_style         = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  skip_region_validation      = true

  endpoints {
    apigateway     = "http://localhost:${var.localstack-port}" # these ports should match the forwarded port in docker-compose.yml
    cloudformation = "http://localhost:${var.localstack-port}"
    cloudwatch     = "http://localhost:${var.localstack-port}"
    dynamodb       = "http://localhost:${var.localstack-port}"
    ec2            = "http://localhost:${var.localstack-port}"
    es             = "http://localhost:${var.localstack-port}"
    firehose       = "http://localhost:${var.localstack-port}"
    iam            = "http://localhost:${var.localstack-port}"
    kinesis        = "http://localhost:${var.localstack-port}"
    lambda         = "http://localhost:${var.localstack-port}"
    route53        = "http://localhost:${var.localstack-port}"
    redshift       = "http://localhost:${var.localstack-port}"
    s3             = "http://localhost:${var.localstack-port}"
    secretsmanager = "http://localhost:${var.localstack-port}"
    ses            = "http://localhost:${var.localstack-port}"
    sns            = "http://localhost:${var.localstack-port}"
    sqs            = "http://localhost:${var.localstack-port}"
    ssm            = "http://localhost:${var.localstack-port}"
    stepfunctions  = "http://localhost:${var.localstack-port}"
    sts            = "http://localhost:${var.localstack-port}"
  }
}

resource "aws_s3_bucket" "my-bucket" {
  acl    = "public-read-write"
  bucket = "my-bucket"
}
