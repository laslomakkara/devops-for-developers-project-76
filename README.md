### Hexlet tests and linter status:
[![Actions Status](https://github.com/laslomakkara/devops-for-developers-project-76/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/laslomakkara/devops-for-developers-project-76/actions)

## Application

Redmine is deployed to Yandex Cloud and is available at:

https://edavholod.ru

## Infrastructure

The project uses the following infrastructure:

* two Ubuntu virtual machines for the application
* Yandex Application Load Balancer
* Yandex Managed PostgreSQL cluster
* Yandex Cloud DNS zone
* Let's Encrypt TLS certificate
* Datadog Agent for monitoring
* security groups for the load balancer, virtual machines and database access

The application is deployed as Docker containers on two web servers. Both Redmine instances use the same managed PostgreSQL database.

The load balancer receives external HTTP and HTTPS traffic and routes it to the application servers.

## Deployment note

The infrastructure was created for this project and tested in Yandex Cloud.

Because cloud resources are paid, they may be removed after the project review is completed. To reproduce the deployment, create equivalent cloud resources, update `inventory.ini` and `group_vars/webservers/vars.yml`, then run the commands described below.

## System requirements

Before running the project commands, install:

* Ansible
* Ansible Galaxy
* Make
* SSH client

The SSH private key must be available locally. By default, `inventory.ini` uses:

```text
~/.ssh/id_rsa
```

The public key must be added to the cloud virtual machines.

## Install dependencies

Third-party Ansible roles and collections are described in `requirements.yml`.

Install them with:

```bash
make install
```

## Prepare servers

Prepare the servers for deployment:

```bash
make prepare
```

This command installs pip, Docker and required Python packages on the servers.

## Deploy application

Deploy Redmine:

```bash
make deploy
```

The deploy command starts only the Redmine application container and does not change server preparation settings.

The application port is configured with the `redmine_port` variable.

Redmine environment variables are generated from the template:

```text
templates/redmine.env.j2
```

## Monitoring

Install and configure Datadog Agent:

```bash
make monitoring
```

Datadog Agent is installed only for the `webservers` host group.

The configured Datadog `http_check` checks Redmine locally on each application server:

```text
http://localhost:3000
```

## Secrets

Secret values are stored in:

```text
group_vars/webservers/vault.yml
```

This file is encrypted with Ansible Vault and belongs to the `webservers` host group.

The vault contains:

* PostgreSQL password
* Datadog API key

To edit the vault file:

```bash
make edit-vault
```

The repository must not contain a vault password file or any decrypted secrets.

## Variables

Common non-secret variables are stored in:

```text
group_vars/all/vars.yml
```

Web server variables are stored in:

```text
group_vars/webservers/vars.yml
```

Secret web server variables are stored encrypted in:

```text
group_vars/webservers/vault.yml
```

## Makefile commands

Install Ansible dependencies:

```bash
make install
```

Prepare servers:

```bash
make prepare
```

Deploy Redmine:

```bash
make deploy
```

Install and configure monitoring:

```bash
make monitoring
```

Edit encrypted secrets:

```bash
make edit-vault
```

## Verification

Check playbook syntax:

```bash
ansible-playbook -i inventory.ini playbook.yml --syntax-check --ask-vault-pass
```

Check the application:

```bash
curl -I https://edavholod.ru
```

Expected result:

```text
HTTP/1.1 200 OK
```

Check running Docker containers:

```bash
ANSIBLE_TIMEOUT=60 ansible all -i inventory.ini --ask-vault-pass -b -a "docker ps"
```

Expected result: the Redmine container is running on both application servers.

Datadog HTTP check:

```bash
ansible all -i inventory.ini --ask-vault-pass -b -m shell -a "datadog-agent status | grep -A 20 -i http_check"
```

