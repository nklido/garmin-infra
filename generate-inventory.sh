#!/bin/bash
TERRAFORM_DIR="terraform"
ANSIBLE_DIR="ansible"

echo "Fetching public IPs from Terraform outputs..."
GARMIN_UI_IP=$(cd "$TERRAFORM_DIR" && terraform output -raw garmin_ui_public_ip)
GARMIN_DATA_IP=$(cd "$TERRAFORM_DIR" && terraform output -raw garmin_data_api_public_ip)
GARMIN_AUTH_IP=$(cd "$TERRAFORM_DIR" && terraform output -raw garmin_auth_api_public_ip)

if [ -z "$GARMIN_DATA_IP" ] || [ -z "$GARMIN_AUTH_IP" ] || [ -z "$GARMIN_UI_IP" ]; then
    echo "Error: Could not retrieve all IPs from Terraform. Is 'terraform apply' complete?"
    exit 1
fi

VENV_PYTHON=$(which python)
if [ ! -x "$VENV_PYTHON" ]; then
    echo "Error: Virtualenv Python interpreter not found at $VENV_PYTHON"
    exit 1
fi

# Define the output inventory file name
INVENTORY_FILE="$ANSIBLE_DIR/inventory.ini"

# Generate the inventory file
cat > "$INVENTORY_FILE" <<EOF
[localhost]
localhost ansible_connection=local ansible_python_interpreter=${VENV_PYTHON}

[garmin-ui]
garmin_ui ansible_host=${GARMIN_UI_IP} ansible_user=ubuntu ansible_ssh_private_key_file=../garmin-key.pem

[garmin-data-api]
garmin_data_api ansible_host=${GARMIN_DATA_IP} ansible_user=ubuntu ansible_ssh_private_key_file=../garmin-key.pem

[garmin-auth-api]
garmin_auth_api ansible_host=${GARMIN_AUTH_IP} ansible_user=ubuntu ansible_ssh_private_key_file=../garmin-key.pem
EOF

echo "Generated Ansible inventory: $INVENTORY_FILE"
echo "Garmin UI IP: $GARMIN_UI_IP"
echo "Garmin Data API IP: $GARMIN_DATA_IP"
echo "Garmin Auth API IP: $GARMIN_AUTH_IP"
