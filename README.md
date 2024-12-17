# Infrastructure as Code (IaC)

## Setup

To get started, please add the group kubernetes connection yaml file into `kubectl-config` directory, with the name `group-02-kubeconfig.yaml`.  
*To use your own namespace and context, you can add your own file to `kubectl-config` with `<namespace>-kubeconfig.yaml`, and give that as the namespace to Terraform.*

To then use the kubectl to interact with the cluster, run the following command:

```bash
source configure-kubectl.sh
```

This sets your local context to the cluster, allowing you to interact with it.  
*This is not needed, in order to run the terraform code, as it uses the files directly.*

## Usage

The project is split in two;
The `platform` directory contains the terraform code for the essential elements, such as Kafka and HDFS, while the `content` directory contains the terraform code for rest of the system, such as ingestion and processing.

Do the following for both directories to deploy the infrastructure.  
To do it correctly, first deploy the platform, then the content.

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
