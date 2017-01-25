# Main goals

clean: vagrant-destroy

test: requirements vagrant-up syntax-check vagrant-provision idempotency-test integration-test

# Helper goals

## Setup 

requirements: role-under-test
	@ansible-galaxy install -r tests/requirements.yml -p tests/roles -f

role-under-test:
	@if [ -d tests/roles/ntp ]; then rm -rf tests/roles/ntp; fi
	@mkdir -p tests/roles/ntp
	@rsync -az --exclude tests . tests/roles/ntp/

## Tests

syntax-check:
	@echo 'Running syntax-check'
	@cd tests && ansible-playbook -i localhost, --syntax-check --list-tasks site.yml \
	  && (echo 'Passed syntax-check'; exit 0) \
	  || (echo 'Failed syntax-check'; exit 1)

idempotency-test:
	@echo 'Running idempotency test'
	@${MAKE} vagrant-provision | tee /tmp/ansible_$$$$.txt; \
	grep -q 'changed=0.*failed=0' /tmp/ansible_$$$$.txt \
	  && (echo 'Passed idempotency test'; exit 0) \
	  || (echo "Failed idempotency test"; exit 1)

integration-test:
	@echo 'Running integration test'
	@RUN_TESTS=true ${MAKE} vagrant-provision \
	  && (echo 'Passed integration test'; exit 0) \
	  || (echo 'Failed integration test'; exit 1)

## Vagrant
	
vagrant-up:
	@cd tests && vagrant up --no-provision

vagrant-destroy:
	@cd tests && vagrant destroy -f

vagrant-provision:
	@cd tests && vagrant provision
