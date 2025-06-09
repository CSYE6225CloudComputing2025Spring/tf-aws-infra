# Project Overview: Provision AWS Infrastructure using Terraform
This repository provides an Infrastructure-as-Code (IaC) setup using Terraform to provision AWS infrastructure. The Terraform configuration allows you to dynamically deploy VPCs, Subnets, Route Tables, Internet gateway, EC2, 
RDS, S3 buckets, Launch Template, Auto Scaling Group, KMS Keys, Route53 resource record in AWS.  

## Resources to be Provisioned  
Terraform will deploy the following resources in AWS:  

VPC: A Virtual Private Cloud with a custom CIDR block.  
3 Public Subnets: Spread across 3 Availability Zones.  
3 Private Subnets: Spread across the same 3 Availability Zones.  
Internet Gateway: Enables internet access for public subnets.  
Public Route Table: Routes traffic from public subnets to the Internet Gateway.  
Private Route Table: Routes traffic within the private subnets.  
Public Route: Allows internet access via the Internet Gateway.  
EC2  
RDS  
S3 buckets  
Launch Template  
AutoScalingGroup： with a minimum of 3 instances and a maximum of 5    
                   Scale up policy when average CPU usage is above 5%. Increment by 1    
                   Scale down policy when average CPU usage is below 3%. Decrement by 1    
KMS keys for each of the following resources: EC2, RDS, S3 Buckets, Secret Manager for Database Password for RDS instance  
Route53 resource record  

## Prerequisites
### AWS CLI   
1. Install AWS CLI
2. Configure AWS credentials:  
aws configure

### Terraform  
Install Terraform


### Use the AWS CLI to import an SSL certificate into AWS Certificate Manager (ACM)  
aws acm import-certificate ^  
  --certificate fileb://"C:\...\<subdomain>_<domain>_<top-level-domain>.crt" ^  
  --private-key fileb://"C:\...\<subdomain>_<domain>_<top-level-domain>.key" ^  
  --certificate-chain fileb://"C:\...\<subdomain>_<domain>_<top-level-domain>.ca-bundle" ^  
  --profile yourprofile

## Usage Instructions(tfvars)  
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





