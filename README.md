# AWS ECS over EC2 Fully Modular Deployment

## 🚀 Overview
This repository provisions a production-ready, highly available **Amazon Elastic Container Service (ECS)** cluster using the **EC2 Launch Type**.

The entire infrastructure is orchestrated using **Terraform** in a strictly modular design following AWS best practices.

### 🏗️ Architecture Stack
1. **Networking (`modules/vpc`)**: A fully Custom VPC (`jenkins-vpc`) spanning 2 Availability Zones, with 2 Public Subnets, 2 Private Subnets, an Internet Gateway, and a NAT Gateway.
2. **Security (`modules/security`)**: Security groups enforcing strict traffic flow (Internet -> ALB -> ECS cluster).
3. **Identity (`modules/iam`)**: Automatically provisions ECS Instance Profiles and Task Execution Roles.
4. **Load Balancing (`modules/alb`)**: Provisions an Application Load Balancer (ALB), Target Group, and HTTP listener to route traffic to active containers.
5. **Compute & Orchestration (`modules/ecs`)**: Provisions an ECS Cluster, an Auto Scaling Group (ASG) using the latest ECS-Optimized Amazon Linux 2 AMI, and deploys a sample NGINX Task Definition & Service.

## 🛠️ Prerequisites
1. **Terraform** installed on your local machine.
2. **AWS CLI** configured (`aws configure`) with valid credentials.
3. Your AWS IAM execution role must have permissions to create VPCs, ALBs, ASGs, SSM parameters, IAM Roles (`iam:CreateRole`), and ECS Clusters (`ecs:CreateCluster`).

## 🚀 Deployment Steps

### 1. Initialize Modules
Downloads the AWS provider and initializes the local Terraform modules.
```bash
cd terraform
terraform init
```

### 2. Validate Configuration
Ensures the syntax and module references are perfectly valid.
```bash
terraform validate
```

### 3. Review Plan (Optional)
Preview the 30+ AWS resources that will be provisioned.
```bash
terraform plan
```

### 4. Deploy Infrastructure
Provision the architecture to your AWS account.
```bash
terraform apply -auto-approve
```

## 🌐 Accessing the Application

Once `terraform apply` finishes successfully, it will output a variable called `alb_dns_name`.

```bash
# Example Output:
alb_dns_name = "ecs-project-alb-123456789.us-east-1.elb.amazonaws.com"
```
Place that URL into your web browser. You should immediately see the default **Welcome to nginx!** webpage served directly from your ECS container instances!

## 🧹 Cleanup
To avoid ongoing AWS charges, destroy the infrastructure when you are done:
```bash
terraform destroy
```