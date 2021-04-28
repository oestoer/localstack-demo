# localstack-demo
Demo local development environment with localstack mocking AWS services

## Requirements
- docker [Installation manual](https://docs.docker.com/get-docker/)
- docker-compose [Installation manual](https://docs.docker.com/compose/install/)
- aws cli v2 [Installation manual](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
  - run `aws configure --profile localstack` to  set up the local profile. I've set these
    ```
    AWS Access Key ID: mock_id
    AWS Secret Access Key: mock_secret_key 
    Default region name: local-1 
    Default output format: 
    ```
  - if you used a different profile name than `localstack` you should set the `$DEMO_PROFILE` env var to it, so the other
    make commands work properly (e.g: `make aws` wrapper commands)  
- terraform cli v0.15.x [Installation manual](https://learn.hashicorp.com/tutorials/terraform/install-cli) for system wide installation.
  - since we need a specific terraform version, and you might have a different system-wide installation, alternatively 
    you can install it only into the project (local folder) by running `make terraform`
  - run `make init` to initialise terraform and download the provider dependencies 
