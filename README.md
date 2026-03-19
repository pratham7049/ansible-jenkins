# AWS EKS Modular Deployment

## 🚀 Overview
This repository provisions a production-ready, highly available **Amazon Elastic Kubernetes Service (EKS)** cluster natively on AWS.

The entire infrastructure is orchestrated using **Terraform** in a strictly modular design following AWS best practices.

### 🏗️ Architecture Stack
1. **Networking (`modules/vpc`)**: A fully Custom VPC (`jenkins-vpc`) spanning 2 Availability Zones, with 2 Public Subnets, 2 Private Subnets, an Internet Gateway, and a NAT Gateway. *Appropriately tagged for Native AWS Kubernetes LoadBalancers.*
2. **Security (`modules/security`)**: Security groups enforcing strict traffic flow internally between the EKS Control plane and worker nodes.
3. **Identity (`modules/iam`)**: Automatically provisions EKS Cluster Roles and EKS Node Group Roles.
4. **Compute & Orchestration (`modules/eks`)**: Provisions the EKS Cluster (Control Plane) and a managed AWS EKS Node Group.

## 🛠️ Prerequisites
1. **Terraform** installed on your local machine.
2. **AWS CLI** configured (`aws configure`) with valid credentials.
3. Your AWS IAM execution role must have permissions to create VPCs, EKS Clusters, Managed Node Groups, and IAM Roles.

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
Preview the AWS resources that will be provisioned.
```bash
terraform plan
```

### 4. Deploy Infrastructure
Provision the architecture to your AWS account.
```bash
terraform apply -auto-approve
```

## 🌐 Next Steps

Once `terraform apply` finishes successfully, it will output a variable called `eks_cluster_endpoint`. Update your local `kubeconfig` to authenticate and interact with your new cluster:

```bash
aws eks update-kubeconfig --region us-east-1 --name ecs-project-cluster
kubectl get nodes
```

## 🧹 Cleanup
To avoid ongoing AWS charges, destroy the infrastructure when you are done:
```bash
terraform destroy
```