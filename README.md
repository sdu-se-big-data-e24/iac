# Infrastrcutre as Code (IaC)

## Setup

To get started, please add the group kubernetes connection yaml file into `kubectl-config` directory, with the name `group-02-kubeconfig.yaml`.

## Usage

To deploy the infrastructure, run the following command:

```bash
# Initialize the terraform workspace
terraform init

# Plan the deployment
terraform plan

# Deploy the infrastructure
terraform apply
```

## Cleanup

To destroy the infrastructure, run the following command:

```bash
terraform destroy
```
