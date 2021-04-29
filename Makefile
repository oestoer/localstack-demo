SHELL=/bin/bash
OS := `uname -s | awk '{print tolower($$0)}'`

include Makefile.helper

TERRAFORM_VERSION = 0.15.0
TERRAFORM_CLI_FILE ?= ./terraform
PLAN_OUT_FILE ?= plan.out
DEMO_PROFILE ?= localstack

.PHONY: clean init

clean: ## Cleans up all files managed by make
	rm -f ${PLAN_OUT_FILE} ${TERRAFORM_CLI_FILE} ./terraform terraform.tfstate*

init: .aws-init .tf-init .build## Init project locally (aws credentials & profile, terraform, build app container)

## TERRAFORM

.PHONY: .tf-init apply apply-out format plan plan-out provision

.tf-init: ##@terraform Initialise terraform with dependencies
.tf-init: terraform
	@${TERRAFORM_CLI_FILE} init

apply: ##@terraform Run terraform apply
apply: terraform
	@${TERRAFORM_CLI_FILE} apply

apply-out: ##@terraform Run terraform apply using a previously saved plan output
apply-out: plan-out
	@${TERRAFORM_CLI_FILE} apply "${PLAN_OUT_FILE}" && \
		rm -f ${PLAN_OUT_FILE}

fmt: ##@terraform Rewrite .tf files to canonical format
fmt: terraform
	@${TERRAFORM_CLI_FILE} fmt

plan: ##@terraform Run a terraform plan
plan: terraform
	@${TERRAFORM_CLI_FILE} plan
plan-out: ##@terraform Run a terraform plan with saving the output
plan-out: terraform
	@${TERRAFORM_CLI_FILE} plan \
		-out=${PLAN_OUT_FILE}

provision: ##@terraform Run a terraform plan (with saving the output) and apply
provision: plan-out apply-out

terraform: ##@terraform Download terraform cli tool
ifneq (${TERRAFORM_VERSION}, $(@shell ./${TERRAFORM_CLI_FILE} -version | grep -v 'provider' | grep -o -E 'v([0-9]+\.[0-9]+\.[0-9]+)' | sed 's/v\(.*\)/\1/'))
	@printf "\n\033[35;1mDownloading terraform v${TERRAFORM_VERSION}...\033[0m\n" \
	&& echo wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${OS}_amd64.zip -O terraform.zip -q --show-progress" \
	| /bin/bash - \
	&& unzip -p terraform.zip > ${TERRAFORM_CLI_FILE} \
	&& rm terraform.zip \
	&& printf "\n\033[35;1mCleaning up archives done\033[0m" \
	&& chmod 755 ${TERRAFORM_CLI_FILE} \
	&& printf "\n\033[35;1mYou can use terraform cli by running:\033[0m ${TERRAFORM_CLI_FILE}\n"

endif

## AWS

.PHONY: aws % @ .aws-init

aws: ##@aws Wrapper command for the aws cli to include `--endpoint-url` and `--profile` options. E.g: make aws s3 ls
	aws --endpoint-url http://localhost:4566 --profile ${DEMO_PROFILE} $(filter-out $@,$(MAKECMDGOALS))
%: # use for the aws wrapper to pass in arguments after the command
	@:

.aws-init: ##@aws Init aws profile and credentials
	@which aws \
		|| (printf "\n\033[31;1mCould not find aws cli\033[0m\n"; \
		echo "Please install it following these steps: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html" \
		&& exit 1)
	aws --profile ${DEMO_PROFILE} configure set aws_access_key_id "mock_id"
	aws --profile ${DEMO_PROFILE} configure set aws_secret_access_key "mock_id"
	aws --profile ${DEMO_PROFILE} configure set region "local-1"

## DOCKER

.PHONY: .build up stop down

.build: ##@docker Build app container
.build:
	docker-compose build

up: ##@docker Start all containers in the background
	docker-compose up -d

stop: ##@docker Stop and keep all containers
	docker-compose stop

down: ##@docker Stop and remove all containers
	docker-compose down --remove-orphans

## APP

.PHONY: list-buckets send-message read-queue

list-buckets: ##@app List S3 buckets with the demo application
list-buckets:
	@docker-compose run php bin/console demo:s3

send-message: ##@app Send message to the SNS topic with the demo application. Set the `msg="My message"` argument for your message
send-message:
ifdef msg
	@docker-compose run php bin/console demo:sns -m $(msg)
else
	@docker-compose run php bin/console demo:sns
endif

read-queue: ##@app Read message from the SQS queue with the demo application
read-queue:
	@docker-compose run php bin/console demo:sqs
