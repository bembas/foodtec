# The default target (all) must come first
.PHONY: all
all: init plan

.PHONY: apply
apply:
	terraform apply temp-plan.tfplan
	rm temp-plan.tfplan

.PHONY: plan
plan:
	$(MAKE) test
	terraform plan -out=temp-plan.tfplan

.PHONY: test
test:
	terraform validate

.PHONY: destroy
destroy:
	terraform destroy

.PHONY: format
format:
	terraform fmt -diff

.PHONY: init
init:
	terraform init



# No need to modify the Makefile beyond this point, but DO read it!

# See https://tech.davis-hansson.com/p/make/
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
# /See

# Why Makefile with Terraform?
#
# This file is intentionally simplistic. It would have been easy to just keep
# using terraform commands directly, but it is useful to get into the habit
# of using automation for any repeatable task.
#
# The approach of having thin wrappers around common Terraform commands also
# gives us ability to augment common commands with additional pre-requisite
# checks which will then execute without having to change the way we work.
# Such checks could involve running some additional policy checks on our
# code, before we even commit it to git.
