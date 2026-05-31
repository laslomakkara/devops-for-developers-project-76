install:
	ansible-galaxy install -r requirements.yml
	ansible-galaxy collection install -r requirements.yml

prepare:
	ansible-playbook -i inventory.ini playbook.yml --tags prepare --ask-vault-pass

deploy:
	ansible-playbook -i inventory.ini playbook.yml --tags deploy --ask-vault-pass

monitoring:
	ansible-playbook -i inventory.ini playbook.yml --tags monitoring --ask-vault-pass

edit-vault:
	ansible-vault edit group_vars/webservers/vault.yml
