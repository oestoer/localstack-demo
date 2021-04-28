SHELL=/bin/bash
OS := `uname -s | awk '{print tolower($$0)}'`

include Makefile.helper

TERRAFORM_VERSION = 0.15.0
TERRAFORM_CLI_FILE ?= terraform
PLAN_OUT_FILE ?= plan.out
DEMO_PROFILE ?= localstack

clean: ##@other Cleans up all files managed by make
	rm -f ${PLAN_OUT_FILE} ${TERRAFORM_CLI_FILE}

## TERRAFORM

.PHONY: init apply apply-out format plan plan-out

init: ##@terraform Initialise terraform with dependencies
init: terraform
	@./${TERRAFORM_CLI_FILE} init

apply: ##@terraform Run terraform apply
apply: terraform
	@./${TERRAFORM_CLI_FILE} apply

apply-out: ##@terraform Run terraform apply using a previously saved plan output
apply-out: plan-out
	@./${TERRAFORM_CLI_FILE} apply "${PLAN_OUT_FILE}" && \
		rm -f ${PLAN_OUT_FILE}

fmt: ##@terraform Rewrite .tf files to canonical format
fmt: terraform
	./terraform fmt

plan: ##@terraform Run a terraform plan
plan: terraform
	@./terraform plan
plan-out: ##@terraform Run a terraform plan with saving the output
plan-out: terraform
	@./terraform plan \
		-out=${PLAN_OUT_FILE}

terraform: ##@terraform Download terraform cli tool
ifneq (${TERRAFORM_VERSION}, $(@shell ./${TERRAFORM_CLI_FILE} -version | grep -v 'provider' | grep -o -E 'v([0-9]+\.[0-9]+\.[0-9]+)' | sed 's/v\(.*\)/\1/'))
	@printf "\n\033[35;1mDownloading terraform v${TERRAFORM_VERSION}...\033[0m\n" \
	&& echo wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${OS}_amd64.zip -O terraform.zip -q --show-progress" \
	| /bin/bash - \
	&& unzip -p terraform.zip > ${TERRAFORM_CLI_FILE} \
	&& rm terraform.zip \
	&& printf "\n\033[35;1mCleaning up archives done\033[0m" \
	&& chmod 755 ${TERRAFORM_CLI_FILE} \
	&& printf "\n\033[35;1mYou can use terraform cli be running:\033[0m ./${TERRAFORM_CLI_FILE}\n"

endif

## AWS

.PHONY: aws % @

aws: ##@aws Wrapper command to aws cli to include --endpoint-url and --profile
	@aws --endpoint-url http://localhost:4566 --profile ${DEMO_PROFILE} $(filter-out $@,$(MAKECMDGOALS))
%: # use for the aws wrapper to pass in arguments after the command
	@:


## DOCKER

up: ##@docker Start all containers in the background
	docker-compose up -d

stop: ##@docker Stop and keep all containers
	docker-compose stop

down: ##@docker Stop and remove all containers
	docker-compose down --remove-orphans
