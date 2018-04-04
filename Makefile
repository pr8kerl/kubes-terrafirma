%-development: clustername ?= terra
%-development: environment := development

terraform ?= docker-compose run terraform
kubeadm ?= docker-compose run kubeadm
f5er ?= docker-compose run f5er
shell ?= docker-compose run shell

token: 
	@echo "+++ Generating random kubeadm bootstrap token"
	$(kubeadm) token generate
	@echo "+++ Copy the above bootstrap token for use in your k8s_bootstrap_token variable"

plan-%: 
	@echo "+++ Running terraform plan for $(environment)"
	$(terraform) plan -var-file global.tfvars -var-file=$(environment).tfvars -state=$(environment).tfstate kluster

apply-%: 
	@echo "+++ Running terraform apply for $(environment)"
	$(terraform) apply -var-file global.tfvars -var-file=$(environment).tfvars -state=$(environment).tfstate kluster

show-%: 
	@echo "+++ Running terraform apply for $(environment)"
	$(terraform) show $(environment).tfstate

output-%: 
	@echo "+++ Running terraform output for $(environment)"
	$(terraform) output $(environment).tfstate

destroy-%: 
	@echo "+++ Running terraform apply for $(environment)"
	$(terraform) destroy -var-file global.tfvars -var-file=$(environment).tfvars -state=$(environment).tfstate kluster

certs-%: 
	@echo "+++ Running certificate setup for $(environment)"
	$(shell) ./bin/certs.sh -e $(environment)

f5er-apps-add-%: 
	@echo "+++ Adding f5 load balancer setup for apps $(clustername)-$(environment)"
	$(f5er) add stack -i /f5/$(clustername)-$(environment)-apps.json

f5er-apps-delete-%: 
	@echo "+++ Deleting f5 load balancer setup for apps $(clustername)-$(environment)"
	$(f5er) delete stack -i /f5/$(clustername)-$(environment)-apps.json

f5er-api-add-%: 
	@echo "+++ Adding f5 load balancer setup for api $(clustername)-$(environment)"
	$(f5er) add stack -i /f5/$(clustername)-$(environment)-api.json

f5er-api-delete-%: 
	@echo "+++ Deleting f5 load balancer setup for api $(clustername)-$(environment)"
	$(f5er) delete stack -i /f5/$(clustername)-$(environment)-api.json

deploy-%: 
	@echo "+++ Installing components for $(clustername)-$(environment)"
	$(shell) ./bin/deploy.sh $(environment)
