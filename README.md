# AWS Networking Setup using Terraform
This repository provides an Infrastructure-as-Code (IaC) setup using Terraform to create and manage AWS networking resources. The Terraform configuration allows you to dynamically deploy multiple VPCs with associated subnets, route tables, and an internet gateway in AWS.

# Prerequisites
# AWS CLI 
1. Install AWS CLI
2. Configure AWS credentials:
aws configure
# Terraform
Install Terraform

# Infrastructure Setup
Terraform will deploy the following resources in AWS:

VPC: A Virtual Private Cloud with a custom CIDR block.
3 Public Subnets: Spread across 3 Availability Zones.
3 Private Subnets: Spread across the same 3 Availability Zones.
Internet Gateway: Enables internet access for public subnets.
Public Route Table: Routes traffic from public subnets to the Internet Gateway.
Private Route Table: Routes traffic within the private subnets.
Public Route: Allows internet access via the Internet Gateway.

# Usage Instructions(tfvars)
Step 1: Clone the Repository
git clone <your-repo-url>
cd <your-project-folder>

Step 2: Initialize Terraform
terraform init

Step 3: Review the Execution Plan
Check the infrastructure changes before applying:
terraform plan

Step 4: Apply the Terraform Configuration
To deploy the infrastructure:
terraform apply

Step 5: Destroy the Infrastructure
terraform destroy

