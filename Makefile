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

destroy-%: 
	@echo "+++ Running terraform apply for $(environment)"
	$(terraform) destroy -var-file global.tfvars -var-file=$(environment).tfvars -state=$(environment).tfstate kluster

certs-%: 
	@echo "+++ Running certificate setup for $(environment)"
	$(shell) ./bin/certs.sh -e $(environment)

f5er-add-%: 
	@echo "+++ Adding f5 load balancer setup for $(clustername)-$(environment)"
	$(f5er) add stack -i /f5/$(clustername)-$(environment).json

f5er-update-%: 
	@echo "+++ Updating f5 load balancer setup for $(clustername)-$(environment)"
	$(f5er) update stack -i /f5/$(clustername)-$(environment).json

deploy-%: 
	@echo "+++ Installing components for $(clustername)-$(environment)"
	$(shell) ./bin/deploy.sh $(environment)
