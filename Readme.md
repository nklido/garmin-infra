# Garmin Infra

Infrastructure setup for the Garmin demo platform using Terraform and Ansible.

## Prerequisites

- Terraform
- Ansible
- An existing SSH key in AWS (used to access EC2 instances)

## Usage

Clone the repository and navigate into it:

```bash
git clone https://github.com/your-username/garmin-infra.git
cd garmin-infra
```


From the project root:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Initialize and apply Terraform to provision the infrastructure:
```
cd terraform
terraform init
terraform apply
```

Generate inventory.ini from terraform outputs:

```
./generate-inventory.sh
```

Run the Ansible playbooks to configure each service

```
cd ansible
ansible-playbook -i inventory.ini playbooks/garmin-ui.yml
ansible-playbook -i inventory.ini playbooks/garmin-data-api.yml
ansible-playbook -i inventory.ini playbooks/garmin-auth-api.yml
```