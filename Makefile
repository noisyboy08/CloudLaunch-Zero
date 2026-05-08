SHELL := /bin/bash
ENV ?= staging

.PHONY: fmt init validate plan apply destroy verify rollback test

fmt:
	terraform -chdir=terraform fmt -recursive

init:
	terraform -chdir=terraform/environments/$(ENV) init

validate: fmt
	terraform -chdir=terraform/environments/$(ENV) validate

plan:
	terraform -chdir=terraform/environments/$(ENV) plan -var-file=terraform.tfvars

apply:
	terraform -chdir=terraform/environments/$(ENV) apply -var-file=terraform.tfvars -auto-approve

destroy:
	terraform -chdir=terraform/environments/$(ENV) destroy -var-file=terraform.tfvars -auto-approve

verify:
	./scripts/verify.sh $(ENV)

rollback:
	./scripts/rollback.sh $(ENV)

test:
	./scripts/test.sh
