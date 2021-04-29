# localstack-demo
Demo local development environment with localstack mocking AWS services.

It contains:
 - localstack to mock AWS infrastructure components
 - terraform infrastructure provisioning with the AWS provider for localstack
- a PHP cli application to interact with the AWS components

## Requirements
- docker [Installation manual](https://docs.docker.com/get-docker/)
- docker-compose [Installation manual](https://docs.docker.com/compose/install/)
- aws cli v2 [Installation manual](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- terraform cli v0.15.x (auto installed if you use the `make` target commands)
  - optionally for system wide installation see the [installation manual](https://learn.hashicorp.com/tutorials/terraform/install-cli)
    but if you use the make commands that come with the project it will handle it for you (on Linux and macOS)

## Usage

For a full list of available helper commands run `make help`

### Setup

Run `make init` to:
- initialise an _aws cli_ profile called _localstack_
- download terraform into the project, initialise & download the provider dependencies
- build the PHP app image

If you want to use an aws profile name different from the default _localstack_ you should set the `$DEMO_PROFILE`
env var to it (and rerun `make init`), so the make commands work properly (e.g: `make aws` wrapper commands)

Run `make up` to start the localstack container.

Run `make provision` to set up the localstack infrastructure. It creates an S3 bucket called _my-bucket_, 
an SNS topic called _my-sns_, an SQS queue called _my-queue_ and a subscription from the queue to the topic.

### App

There are three helper make commands that execute symfony command inside the PHP container.

Run `make list-buckets` to list the existing S3 buckets. 

Run `make send-message` to send a 'Hello' message. You can specify the message you want to send with the `msg` argument. 
E.g: `make send-message msg="custom message"` 

Run `make read-queue` to read one message at a time from the queue. 

### AWS CLI

You can also use the aws cli tool to interact with localstack. E.g: 
`aws --profile=localstack --endpoint-url=http://localhost:4566 s3 ls`

There's even a useful wrapper that adds the profile and endpoint-url options to the commands for you, so you don't have
to specify those every time. E.g `make aws s3 ls`. This is equivalent to the above command.
